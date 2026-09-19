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

    A commit may carry "hoursAgo": 25 to be dated that many hours before the moment the fixture
    is built. RELATIVE, never absolute: the rules that read a date read an ELAPSED time (the
    Critical cooling-off period), so an absolute date would be a fixture that passes today and
    fails whenever someone runs it. Fractions are allowed — "hoursAgo": 23.5 sits inside a
    24-hour window from either side of midnight.

    - "write" values are a string (used verbatim) or an array of lines (joined with LF).
    - "copy" values are paths relative to the case directory — for content too long to inline.
    - "branch" creates the branch from the current HEAD the first time it is named.
    - "shallow" clones the built repository to the given depth and returns the clone, which is
      how a depth-1 CI checkout with no reachable base is reproduced (GAP-027).
    - "truncateBlob" corrupts the object store copy of a committed file, which is the state that
      separates `cat-file -e` from `cat-file blob` (feature 014 phase 5).
    - "uncommitted" writes files after the last commit and leaves them unstaged, which is the
      state the "exists only in a working tree" rules refuse.
    - "merge" makes the commit a MERGE of the named branch into this one, with two parents and
      no content of its own. It is the one commit a recipe cannot describe with files, and the
      rule that skips merge commits (a merge authored nothing) had no fixture without it.
    - "uncommittedDelete" removes files from the working tree after the last commit without
      staging the removal — the mirror of "uncommitted", and the state the fail-closed rules
      refuse from the other side: the commit-to-commit diff still names the file, so a check
      that reads the diff and then reads the file finds nothing to read.
    - "hoursAgo" back-dates one commit's author AND committer date. Both, because which one a
      rule reads is the rule's business and a fixture that set only the one today's rule happens
      to read would quietly stop testing anything the day that changed.

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

        # A merge has two parents and no content of its own, so it takes none of the write /
        # delete / commit path below. D7 skips merge commits because a merge authored nothing;
        # until this existed, no recipe could produce a second parent and that skip was untested.
        if ($commit.PSObject.Properties.Name -contains 'merge' -and $commit.merge) {
            $mergeMessage = if ($commit.PSObject.Properties.Name -contains 'message' -and $commit.message) { $commit.message } else { "merge $($commit.merge)" }
            Invoke-FixtureGit -RepoPath $root -Arguments @('merge', '--quiet', '--no-ff', '--no-edit', '-m', $mergeMessage, $commit.merge) | Out-Null
            continue
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

        # Back-dating, for the rules that measure elapsed time rather than order. The value is
        # RELATIVE to now and resolved here, at build time, so a cooling-off fixture cannot
        # expire: "23 hours ago" means the same thing in every run, which an absolute date does
        # not. git takes the author date as an argument and the committer date only from the
        # environment, so both are set and the environment is restored whatever happens.
        $commitArgs = @('commit', '--quiet', '--allow-empty', '-m', $message)
        $previousCommitterDate = $env:GIT_COMMITTER_DATE
        try {
            if ($commit.PSObject.Properties.Name -contains 'hoursAgo' -and $null -ne $commit.hoursAgo) {
                $when = [DateTimeOffset]::UtcNow.AddHours(-1 * [double]$commit.hoursAgo)
                $stamp = $when.ToString('yyyy-MM-ddTHH:mm:sszzz')
                $env:GIT_COMMITTER_DATE = $stamp
                $commitArgs += @('--date', $stamp)
            }
            Invoke-FixtureGit -RepoPath $root -Arguments $commitArgs | Out-Null
        } finally {
            if ($null -eq $previousCommitterDate) { Remove-Item Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue }
            else { $env:GIT_COMMITTER_DATE = $previousCommitterDate }
        }
    }

    if ($Recipe.PSObject.Properties.Name -contains 'checkout' -and $Recipe.checkout) {
        Invoke-FixtureGit -RepoPath $root -Arguments @('checkout', '--quiet', $Recipe.checkout) | Out-Null
    }

    # Files written AFTER the last commit and deliberately left out of it. Two kit rules exist
    # only to refuse this state — "evidence that exists only in a working tree is not evidence" —
    # and until now no recipe could produce it, so both rules were unprovable by construction.
    if ($Recipe.PSObject.Properties.Name -contains 'uncommitted' -and $Recipe.uncommitted) {
        foreach ($prop in $Recipe.uncommitted.PSObject.Properties) {
            Write-FixtureFile -RepoPath $root -RelativePath $prop.Name -Content $prop.Value
        }
    }

    # The mirror state: a file that IS in the branch's commit-to-commit diff and is NOT on disk.
    # Staging the removal would change the diff and destroy the condition, so this deletes from
    # the working tree only.
    if ($Recipe.PSObject.Properties.Name -contains 'uncommittedDelete' -and $Recipe.uncommittedDelete) {
        foreach ($rel in @($Recipe.uncommittedDelete)) {
            $target = Join-Path $root $rel
            if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Force }
        }
    }

    if ($Recipe.PSObject.Properties.Name -contains 'truncateBlob' -and $Recipe.truncateBlob) {
        $sha = ((Invoke-FixtureGit -RepoPath $root -Arguments @('rev-parse', "HEAD:$($Recipe.truncateBlob)")) -join '').Trim()
        $objectPath = Join-Path $root (".git/objects/{0}/{1}" -f $sha.Substring(0, 2), $sha.Substring(2))
        if (Test-Path $objectPath) {
            # git writes loose objects read-only, because nothing is ever meant to rewrite one.
            # Without clearing the attribute first this throws UnauthorizedAccessException, which
            # is how a capability that shipped with the harness turned out never to have run:
            # 'truncateBlob' was documented from phase 1 and had no case until T026 used it.
            $item = Get-Item -LiteralPath $objectPath -Force
            $item.Attributes = $item.Attributes -band -bnot [IO.FileAttributes]::ReadOnly
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
