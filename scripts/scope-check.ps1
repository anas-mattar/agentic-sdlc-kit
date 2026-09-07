<#
.SYNOPSIS
    Machine scope check: verifies a phase commit's diff stays inside the territory the
    feature's tasks.md declared for that phase (Definition of Done gate 4).

.DESCRIPTION
    Contract: specs/006-verification-pack/contracts/scope-check-cli.md.

    Lane classification:
      - fix/*, chore/*, docs/* branches: not applicable (exit 0) — the Lite lane's defense
        is enforcement-pack's prohibited-category and abuse-guard checks.
      - NNN-* branches: every phase commit is checked against the **Territory** list under
        its phase heading in specs/NNN-name/tasks.md.

    Phase attribution: the commit subject must carry a 'phase N' token (research D2);
    -Phase overrides. A commit with no parseable phase, or a phase with no territory
    declaration, produces a NON-BLOCKING warning (compatibility with features specified
    before the verification pack).

    Anti-retroactivity (research D3): the declaration is read from the commit's PARENT
    (<commit>^:tasks.md), falling back to the commit itself only when the parent predates
    the feature directory (the claim commit). A territory amendment therefore only takes
    effect for commits made after it lands.

    Matching: PowerShell -like semantics; '*' (and the conventional '**') matches across
    path separators. The feature's own spec directory (specs/NNN-name/**) is always
    implicitly in territory. Renames touch both paths; deletes touch the deleted path.

    Verdicts and exit codes (data-model.md):
      PASS / not-applicable / WARN  -> exit 0
      FAIL (any undeclared path)    -> exit 1

.EXAMPLE
    pwsh -File scripts/scope-check.ps1                    # check HEAD
    pwsh -File scripts/scope-check.ps1 -Commit abc1234 -Phase 2
    pwsh -File scripts/scope-check.ps1 -All               # every phase commit since merge-base (CI mode)
#>
[CmdletBinding()]
param(
    [string]$Commit = 'HEAD',
    [int]$Phase = 0,
    [string]$Branch,
    [switch]$All,
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path $Root).Path
Push-Location $Root
try {

function Get-CurrentBranch {
    param([string]$Override)
    if ($Override) { return $Override }
    (git rev-parse --abbrev-ref HEAD 2>$null).Trim()
}

function Get-DiffBase {
    foreach ($c in @('origin/main', 'main')) {
        git rev-parse --verify --quiet $c *> $null
        if ($LASTEXITCODE -eq 0) {
            $base = (git merge-base HEAD $c 2>$null).Trim()
            if ($LASTEXITCODE -eq 0 -and $base) { return $base }
        }
    }
    return $null
}

# Paths a commit touches: renames contribute both sides, deletes the deleted path.
function Get-CommitPaths {
    param([string]$Sha)
    $paths = @()
    $rows = git show --name-status --format='' -M $Sha 2>$null
    foreach ($row in $rows) {
        if (-not $row) { continue }
        $parts = $row -split "`t"
        if ($parts.Count -lt 2) { continue }
        if ($parts[0] -match '^[RC]') {
            if ($parts.Count -ge 3) { $paths += $parts[1]; $paths += $parts[2] }
        } else {
            $paths += $parts[1]
        }
    }
    $paths | Where-Object { $_ } | Select-Object -Unique
}

# Territory list for phase N, from a specific blob of tasks.md.
# Returns @{ Found = bool; Entries = string[]; Invalid = string[] }
function Get-Territory {
    param([string[]]$TasksLines, [int]$PhaseNumber)
    $result = @{ Found = $false; Entries = @(); Invalid = @() }
    $inPhase = $false
    $collecting = $false
    foreach ($line in $TasksLines) {
        if ($line -match '^##\s+Phase\s+(\d+)') {
            $inPhase = ([int]$matches[1] -eq $PhaseNumber)
            $collecting = $false
            continue
        }
        if (-not $inPhase) { continue }
        if ($line -match '^\*\*Territory\*\*:') { $result.Found = $true; $collecting = $true; continue }
        if (-not $collecting) { continue }
        if ($line -match '^\s*$') { continue }                       # blank lines inside the list are fine
        if ($line -match '^\s*[-*]\s+(.*)$') {
            $entry = $matches[1].Trim() -replace '^`|`$', ''
            if ($entry -match '^\s*$') { continue }
            if ($entry -match '^([A-Za-z]:|[/\\])' -or $entry -match '(^|[/\\])\.\.([/\\]|$)') {
                $result.Invalid += $entry
            } else {
                $result.Entries += $entry
            }
            continue
        }
        $collecting = $false                                          # first non-list, non-blank line ends the list
    }
    return $result
}

function Test-InTerritory {
    param([string]$Path, [string[]]$Globs)
    foreach ($g in $Globs) {
        $pattern = $g -replace '\*\*', '*'
        if ($Path -like $pattern) { return $true }
    }
    return $false
}

# Check one commit; returns $true when the verdict is not FAIL.
function Invoke-ScopeCheck {
    param([string]$Sha, [string]$FeatureBranch, [int]$PhaseOverride)

    $sha7 = (git rev-parse --short $Sha 2>$null).Trim()

    # Merge commits are not phase commits.
    $parents = ((git rev-list --parents -n 1 $Sha 2>$null) -split '\s+')
    if ($parents.Count -gt 2) {
        Write-Host "scope-check: not applicable (commit $sha7 is a merge commit)"
        return $true
    }

    # Phase attribution (research D2).
    $phaseN = $PhaseOverride
    if ($phaseN -le 0) {
        $subject = (git log -1 --format=%s $Sha 2>$null)
        if ($subject -match '(?i)\bphase\s+(\d+)\b') { $phaseN = [int]$matches[1] }
    }
    if ($phaseN -le 0) {
        Write-Host "scope-check: WARN commit ${sha7}: no 'phase N' token in the commit subject (declare territory in tasks.md and name the phase — non-blocking, pre-006 compatibility)"
        return $true
    }

    # Declaration as of the parent (research D3); fall back to the commit itself only when
    # the parent predates the feature directory (the claim commit).
    $tasksRel = "specs/$FeatureBranch/tasks.md"
    $tasksBlob = git show "${Sha}^:$tasksRel" 2>$null
    if ($LASTEXITCODE -ne 0) { $tasksBlob = git show "${Sha}:$tasksRel" 2>$null }
    if ($LASTEXITCODE -ne 0 -or -not $tasksBlob) {
        Write-Host "scope-check: WARN commit ${sha7}: $tasksRel not found at the commit or its parent (declare territory in tasks.md — non-blocking, pre-006 compatibility)"
        return $true
    }

    $territory = Get-Territory -TasksLines @($tasksBlob) -PhaseNumber $phaseN
    if ($territory.Invalid.Count -gt 0) {
        foreach ($bad in $territory.Invalid) {
            Write-Host "scope-check: FAIL phase $phaseN commit ${sha7}: invalid territory entry '$bad' (entries must be repo-relative, no '..')"
        }
        return $false
    }
    if (-not $territory.Found -or $territory.Entries.Count -eq 0) {
        Write-Host "scope-check: WARN commit ${sha7}: no territory declared for phase $phaseN in $tasksRel (declare territory in tasks.md — non-blocking, pre-006 compatibility)"
        return $true
    }

    $globs = @("specs/$FeatureBranch/**") + $territory.Entries      # implicit spec-dir entry
    $paths = @(Get-CommitPaths -Sha $Sha)
    $strays = @($paths | Where-Object { -not (Test-InTerritory -Path $_ -Globs $globs) })

    if ($strays.Count -eq 0) {
        Write-Host "scope-check: PASS phase $phaseN commit $sha7 ($($paths.Count) file(s))"
        return $true
    }
    foreach ($s in $strays) {
        Write-Host "scope-check: FAIL phase $phaseN commit ${sha7}: $s not in territory"
    }
    Write-Host "scope-check: remediation — revert the undeclared change, or amend the phase's **Territory** in $tasksRel (owner approval) in a commit made BEFORE the phase commit, then re-commit the phase"
    return $false
}

# --- Dispatch ---
$Branch = Get-CurrentBranch -Override $Branch

if ($Branch -match '^(fix|chore|docs)/') {
    Write-Host "scope-check: not applicable ($($matches[1])/ lane — enforcement-pack's Lite-lane checks apply instead)"
    exit 0
}
if ($Branch -in @('main', 'master')) {
    Write-Host "scope-check: not applicable ('$Branch' is the trunk)"
    exit 0
}
if ($Branch -notmatch '^\d{3}-') {
    Write-Host "scope-check: not applicable ('$Branch' is not a numbered feature branch)"
    exit 0
}

$ok = $true
if ($All) {
    $base = Get-DiffBase
    if (-not $base) {
        Write-Host 'scope-check: WARN could not resolve a merge base with main — nothing checked'
        exit 0
    }
    $commits = @((git rev-list --reverse --no-merges "$base..HEAD" 2>$null) | Where-Object { $_ })
    if ($commits.Count -eq 0) {
        Write-Host 'scope-check: PASS (no commits since merge base)'
        exit 0
    }
    foreach ($c in $commits) {
        if (-not (Invoke-ScopeCheck -Sha $c -FeatureBranch $Branch -PhaseOverride 0)) { $ok = $false }
    }
} else {
    $ok = Invoke-ScopeCheck -Sha $Commit -FeatureBranch $Branch -PhaseOverride $Phase
}

if (-not $ok) { exit 1 }
exit 0

} finally {
    Pop-Location
}
