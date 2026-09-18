<#
.SYNOPSIS
    Builds a real temporary git repository from a declarative fixture recipe.

.DESCRIPTION
    Feature 015, plan D12: every defect feature 014's nine review rounds found was about git
    reality — truncated objects, an empty merge-base, %P field ordering, core.quotepath — and a
    mocked or in-memory repository reproduces none of them. So every fixture gets a real
    repository, with real commits, built here.

    This module knows nothing about the scripts under test. It never imports one, and nothing
    in a recipe executes: a recipe declares files and commits, not behaviour (plan D1).

    Recipe shape (recipe.json beside a case):

      {
        "description": "prose, for the reader",
        "defaultBranch": "main",
        "commits": [
          { "branch": "main",      "message": "init", "write": { "README.md": "kit\n" } },
          { "branch": "001-thing", "message": "spec",
            "write":  { "specs/001-thing/spec.md": ["line one", "line two"] },
            "copy":   { "specs/001-thing/plan.md": "files/plan.md" },
            "delete": ["obsolete.md"] }
        ],
        "checkout": "001-thing",
        "shallow": 1,
        "truncateBlob": "specs/001-thing/plan.md"
      }

    - "write" values are a string (used verbatim) or an array of lines (joined with LF).
    - "copy" values are paths relative to the case directory — for content too long to inline.
    - "branch" creates the branch from the current HEAD the first time it is named.
    - "shallow" clones the built repository to the given depth and returns the clone, which is
      how a depth-1 CI checkout with no reachable base is reproduced (GAP-027).
    - "truncateBlob" corrupts the object store copy of a committed file, which is the state that
      separates `cat-file -e` from `cat-file blob` (feature 014 phase 5).

    Fixture repositories carry their own git identity. The user's name, email, signing key and
    global configuration are never read or written.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-FixtureGit {
    param([Parameter(Mandatory)][string]$RepoPath, [Parameter(Mandatory)][string[]]$Arguments)
    $out = & git -C $RepoPath @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "fixture git failed: git $($Arguments -join ' ')`n$($out -join "`n")"
    }
    return $out
}

function Write-FixtureFile {
    param([string]$RepoPath, [string]$RelativePath, $Content)
    $full = Join-Path $RepoPath $RelativePath
    $dir = Split-Path -Parent $full
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $text = if ($Content -is [System.Array]) { ($Content -join "`n") + "`n" } else { [string]$Content }
    # LF always: a fixture's bytes must not depend on the platform that built it (SC-006).
    $text = $text -replace "`r`n", "`n"
    [IO.File]::WriteAllText($full, $text, (New-Object System.Text.UTF8Encoding($false)))
}

function New-FixtureRepo {
    <#
    .SYNOPSIS
        Materialise a recipe into a temporary git repository. Returns its root path.
    #>
    param(
        [Parameter(Mandatory)]$Recipe,
        [string]$CaseDir
    )

    $root = Join-Path ([IO.Path]::GetTempPath()) ("kit-fixture-" + [guid]::NewGuid().ToString('N').Substring(0, 12))
    New-Item -ItemType Directory -Path $root -Force | Out-Null

    $defaultBranch = if ($Recipe.PSObject.Properties.Name -contains 'defaultBranch' -and $Recipe.defaultBranch) { $Recipe.defaultBranch } else { 'main' }
    Invoke-FixtureGit -RepoPath $root -Arguments @('init', '--quiet', '-b', $defaultBranch) | Out-Null
    Invoke-FixtureGit -RepoPath $root -Arguments @('config', 'user.name', 'Fixture Author') | Out-Null
    Invoke-FixtureGit -RepoPath $root -Arguments @('config', 'user.email', 'fixture@example.invalid') | Out-Null
    Invoke-FixtureGit -RepoPath $root -Arguments @('config', 'commit.gpgsign', 'false') | Out-Null
    Invoke-FixtureGit -RepoPath $root -Arguments @('config', 'core.autocrlf', 'false') | Out-Null

    $seenBranches = @($defaultBranch)
    foreach ($commit in @($Recipe.commits)) {
        $branch = if ($commit.PSObject.Properties.Name -contains 'branch' -and $commit.branch) { $commit.branch } else { $defaultBranch }
        # symbolic-ref, not rev-parse: an unborn HEAD (the repository before its first commit)
        # has no revision to parse, and that is exactly the state the first commit runs in.
        $current = ((Invoke-FixtureGit -RepoPath $root -Arguments @('symbolic-ref', '--short', 'HEAD')) -join '').Trim()
        if ($branch -ne $current) {
            if ($seenBranches -contains $branch) {
                Invoke-FixtureGit -RepoPath $root -Arguments @('checkout', '--quiet', $branch) | Out-Null
            } else {
                Invoke-FixtureGit -RepoPath $root -Arguments @('checkout', '--quiet', '-b', $branch) | Out-Null
                $seenBranches += $branch
            }
        }

        if ($commit.PSObject.Properties.Name -contains 'write' -and $commit.write) {
            foreach ($prop in $commit.write.PSObject.Properties) {
                Write-FixtureFile -RepoPath $root -RelativePath $prop.Name -Content $prop.Value
            }
        }
        if ($commit.PSObject.Properties.Name -contains 'copy' -and $commit.copy) {
            if (-not $CaseDir) { throw 'recipe uses "copy" but no -CaseDir was supplied' }
            foreach ($prop in $commit.copy.PSObject.Properties) {
                $source = Join-Path $CaseDir $prop.Value
                if (-not (Test-Path $source)) { throw "recipe copy source not found: $source" }
                Write-FixtureFile -RepoPath $root -RelativePath $prop.Name -Content ([IO.File]::ReadAllText($source))
            }
        }
        if ($commit.PSObject.Properties.Name -contains 'delete' -and $commit.delete) {
            foreach ($rel in @($commit.delete)) {
                $full = Join-Path $root $rel
                if (Test-Path $full) { Remove-Item $full -Recurse -Force }
            }
        }

        Invoke-FixtureGit -RepoPath $root -Arguments @('add', '-A') | Out-Null
        $message = if ($commit.PSObject.Properties.Name -contains 'message' -and $commit.message) { $commit.message } else { 'fixture commit' }
        Invoke-FixtureGit -RepoPath $root -Arguments @('commit', '--quiet', '--allow-empty', '-m', $message) | Out-Null
    }

    if ($Recipe.PSObject.Properties.Name -contains 'checkout' -and $Recipe.checkout) {
        Invoke-FixtureGit -RepoPath $root -Arguments @('checkout', '--quiet', $Recipe.checkout) | Out-Null
    }

    if ($Recipe.PSObject.Properties.Name -contains 'truncateBlob' -and $Recipe.truncateBlob) {
        $sha = ((Invoke-FixtureGit -RepoPath $root -Arguments @('rev-parse', "HEAD:$($Recipe.truncateBlob)")) -join '').Trim()
        $objectPath = Join-Path $root (".git/objects/{0}/{1}" -f $sha.Substring(0, 2), $sha.Substring(2))
        if (Test-Path $objectPath) {
            $bytes = [IO.File]::ReadAllBytes($objectPath)
            [IO.File]::WriteAllBytes($objectPath, $bytes[0..([Math]::Max(0, [int]($bytes.Length / 2)))])
        }
    }

    if ($Recipe.PSObject.Properties.Name -contains 'shallow' -and $Recipe.shallow) {
        $clone = Join-Path ([IO.Path]::GetTempPath()) ("kit-fixture-" + [guid]::NewGuid().ToString('N').Substring(0, 12))
        $branch = if ($Recipe.PSObject.Properties.Name -contains 'checkout' -and $Recipe.checkout) { $Recipe.checkout } else { $defaultBranch }
        $uri = ([uri]("file:///" + ($root -replace '\\', '/'))).AbsoluteUri
        & git clone --quiet --depth $Recipe.shallow --branch $branch $uri $clone 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "fixture shallow clone failed for $root" }
        Invoke-FixtureGit -RepoPath $clone -Arguments @('config', 'user.name', 'Fixture Author') | Out-Null
        Invoke-FixtureGit -RepoPath $clone -Arguments @('config', 'user.email', 'fixture@example.invalid') | Out-Null
        Remove-Item $root -Recurse -Force -ErrorAction SilentlyContinue
        return $clone
    }

    return $root
}

function Remove-FixtureRepo {
    param([Parameter(Mandatory)][string]$Path)
    if ($Path -and (Test-Path $Path)) {
        Remove-Item $Path -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Export-ModuleMember -Function New-FixtureRepo, Remove-FixtureRepo
