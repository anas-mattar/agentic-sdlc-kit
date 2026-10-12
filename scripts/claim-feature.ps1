<#
.SYNOPSIS
    One-command feature claim: remote-aware number allocation, branch + spec creation,
    immediate push, race recovery.

.DESCRIPTION
    Automates the claim ritual in docs/sdlc/branch-strategy.md ("Number Allocation") and
    docs/sdlc/team-workflow.md (rule 2) — the ritual itself is unchanged:

      1. Preflight: clean working tree, current branch is main.
      2. git fetch origin; allocate the next feature number free across local branches,
         remote branches, and specs/ directories.
      3. Delegate branch + spec-directory creation to the stock Spec Kit script
         (.specify/scripts/powershell/create-new-feature.ps1 -Number).
      4. git push -u origin <branch> immediately — the remote branch IS the claim.
      5. If another claim reached the remote first with the same number, renumber the
         branch and spec directory and push again (max 3 attempts).

    With no remote configured (or -NoPush), the claim is created locally and a warning
    states it is not team-visible.

    Contract: specs/003-flow-efficiency-pack/contracts/claim-feature-cli.md

.EXAMPLE
    pwsh -File scripts/claim-feature.ps1 -ShortName user-invitations "Invite users by email"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ShortName,
    [switch]$Json,
    [switch]$NoPush,
    [Parameter(Mandatory, Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$FeatureDescription
)

$ErrorActionPreference = 'Stop'
$MaxAttempts = 3

function Write-Info([string]$Message) {
    if (-not $Json) { Write-Host $Message }
}

function Get-RemoteFeatureHeads {
    # Returns the NNN-* branch names currently on origin (authoritative ledger).
    $heads = git ls-remote --heads origin 2>$null
    if ($LASTEXITCODE -ne 0) { throw "git ls-remote failed — cannot read the remote ledger." }
    $names = @()
    foreach ($line in $heads) {
        if ($line -match 'refs/heads/(\d{3,}-\S+)$') { $names += $matches[1] }
    }
    return $names
}

function Get-NextFreeNumber {
    param([string[]]$RemoteHeads)
    [long]$highest = 0
    $localBranches = git for-each-ref --format='%(refname:short)' refs/heads 2>$null
    $specDirs = if (Test-Path 'specs') {
        Get-ChildItem 'specs' -Directory | ForEach-Object Name
    } else { @() }
    foreach ($name in @($localBranches) + @($RemoteHeads) + @($specDirs)) {
        if ($name -match '^(\d{3,})-' -and $name -notmatch '^\d{8}-\d{6}-') {
            [long]$num = 0
            if ([long]::TryParse($matches[1], [ref]$num) -and $num -gt $highest) { $highest = $num }
        }
    }
    return $highest + 1
}

# A refusal: the claim cannot be made, so it says why on the error stream and exits 1. Not
# Write-Error: under ErrorActionPreference = Stop that THROWS, the 'exit 1' beneath it never runs, and
# the reader gets a PowerShell error record and an exit code that is whatever the launcher or the last
# git call left behind, not the script's (feature 023, GAP-031; the same function as territory-check.ps1).
function Stop-Refused {
    param([Parameter(Mandatory)][string]$Message)
    [Console]::Error.WriteLine($Message)
    exit 1
}

$repoRoot = git rev-parse --show-toplevel 2>$null
if ($LASTEXITCODE -ne 0) { Stop-Refused 'Not inside a git repository.' }
Push-Location $repoRoot
try {

# --- 1. Preflight (mirrors CLAUDE.md workflow step 1) ---------------------------------
$dirty = git status --porcelain
if ($dirty) {
    Stop-Refused "Working tree is not clean — commit or stash before claiming a feature.`n$($dirty -join "`n")"
}
$currentBranch = git branch --show-current
if ($currentBranch -ne 'main') {
    Stop-Refused "Claims start from main (currently on '$currentBranch'). Checkout main first."
}

# --- 2. Sync with the ledger -----------------------------------------------------------
$hasRemote = $false
git remote get-url origin 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) { $hasRemote = $true }

$remoteHeads = @()
if ($hasRemote) {
    git fetch origin --prune 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) { Stop-Refused 'git fetch origin failed — cannot claim against an unreachable ledger.' }
    $remoteHeads = Get-RemoteFeatureHeads
} else {
    Write-Warning 'No origin remote configured — allocating from the LOCAL ledger only. This claim is NOT team-visible.'
}

# --- 3+4. Allocate and create (delegated to the stock Spec Kit script) -----------------
$number = Get-NextFreeNumber -RemoteHeads $remoteHeads
Write-Info "Allocating feature number $('{0:000}' -f $number) (next free across local + remote + specs/)."

$createScript = Join-Path $repoRoot '.specify/scripts/powershell/create-new-feature.ps1'
if (-not (Test-Path $createScript)) {
    Stop-Refused "Stock script not found: $createScript — partial kit install? Run scripts/doc-lint.ps1."
}
$createOut = & $createScript -Json -Number $number -ShortName $ShortName ($FeatureDescription -join ' ')
if ($LASTEXITCODE -ne 0) { Stop-Refused "create-new-feature.ps1 failed:`n$createOut" }
$created = $createOut | ConvertFrom-Json
$branch = $created.BRANCH_NAME
$renumberedFrom = $null

# --- 5. Push immediately — the remote branch IS the claim ------------------------------
$pushed = $false
if ($hasRemote -and -not $NoPush) {
    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        git push -u origin $branch 2>&1 | Out-Null
        $pushOk = ($LASTEXITCODE -eq 0)

        # Same-number races don't always reject the push (a different slug with the same
        # NNN pushes fine), so re-read the ledger and look for a rival with our number.
        $numPrefix = $branch -replace '^(\d{3,})-.*', '$1'
        $rivals = @(Get-RemoteFeatureHeads | Where-Object { $_ -match "^$numPrefix-" -and $_ -ne $branch })

        if ($pushOk -and $rivals.Count -eq 0) { $pushed = $true; break }

        # Lost the race. Withdraw our remote branch if it landed, then renumber.
        Write-Warning "Number $numPrefix was claimed concurrently ($($rivals -join ', ')) — renumbering."
        if ($pushOk) { git push origin --delete $branch 2>$null | Out-Null }
        if ($attempt -eq $MaxAttempts) {
            Stop-Refused "Lost the allocation race $MaxAttempts times — renumber manually (docs/sdlc/branch-strategy.md, Number Allocation)."
        }
        git fetch origin --prune 2>$null | Out-Null
        $remoteHeads = Get-RemoteFeatureHeads
        $newNumber = Get-NextFreeNumber -RemoteHeads $remoteHeads
        $newBranch = $branch -replace '^\d{3,}', ('{0:000}' -f $newNumber)
        if (-not $renumberedFrom) { $renumberedFrom = $branch -replace '-.*$', '' }
        git branch -m $branch $newBranch
        if (Test-Path "specs/$branch") { Rename-Item "specs/$branch" $newBranch }
        Write-Info "Renumbered: $branch -> $newBranch"
        $branch = $newBranch
    }
} elseif ($NoPush) {
    Write-Warning 'Push skipped (-NoPush) — this claim is NOT team-visible until you push the branch.'
}

# --- Output ----------------------------------------------------------------------------
$specFile = Join-Path $repoRoot "specs/$branch/spec.md"
if ($Json) {
    [PSCustomObject]@{
        BRANCH_NAME     = $branch
        SPEC_FILE       = $specFile
        FEATURE_NUM     = ($branch -replace '-.*$', '')
        PUSHED          = $pushed
        RENUMBERED_FROM = $renumberedFrom
    } | ConvertTo-Json -Compress
} else {
    if ($pushed) { Write-Host "CLAIMED: $branch (pushed to origin — the claim is live)" }
    else { Write-Host "CLAIMED LOCALLY: $branch (not pushed — not team-visible)" }
    Write-Host "SPEC_FILE: $specFile"
    Write-Host "NEXT: flip the roadmap row for $branch (Status, Owner, Spec ``specs/$branch/``) in a main-side docs commit — ritual-checks fails while a claim's row still reads 'idea' (GAP-017)."
}
exit 0

} finally { Pop-Location }
