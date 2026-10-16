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
        "truncateBlob": "specs/001-thing/plan.md",
        "nestedRepos": { "fitforge-api": { "commits": [ ... ], "checkout": "001-thing" } }
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
    - "shallowAllBranches": true (with "shallow") also keeps every other branch, shallowly, so origin/main
      resolves and a diff base exists in a clone that is still shallow (feature 027).
    - "truncateBlob" corrupts the object store copy of a committed file, which is the state that
      separates `cat-file -e` from `cat-file blob` (feature 014 phase 5).
    - "truncateCommit" does the same to a COMMIT object named by a rev ("HEAD~1"), which is the
      unreadable-parent state: the commit is still referenced and still resolves by name, and
      reading it fails. A check that walks parents meets this one, not a corrupt blob (GAP-027).
    - "uncommitted" writes files after the last commit and leaves them unstaged, which is the
      state the "exists only in a working tree" rules refuse.
    - "rename" maps old path -> new path and stages it with 'git mv', so git records R and not
      an add plus a delete. A rule that treats a rename differently from a delete needs the
      real thing to be tested at all.
    - "orphan": true on the commit that first names a branch creates it with NO parent and an empty
      tree (git checkout --orphan), so it shares no history with any other branch: the genuine
      no-merge-base state, which a corrupt object only imitates (feature 018 phase 3 review, F3).
    - "merge" makes the commit a MERGE of the named branch into this one, with two parents and
      no content of its own. It is the one commit a recipe cannot describe with files, and the
      rule that skips merge commits (a merge authored nothing) had no fixture without it. It may
      be an ARRAY of branch names, which makes an octopus merge (more than two parents).
    - "mergeWrite", "mergeDelete" and "resolve" (feature 026, plan D8) give a merge CONTENT OF ITS
      OWN, the thing the rule that grades what a merge authored needs and a plain merge cannot
      be: "mergeWrite" is the shape of "write" and lands in the merge result, so the result
      differs from both parents; "mergeDelete" removes files from the merge result only;
      "resolve" is the content taken for each file a conflicting merge leaves conflicted. A
      conflict with no "resolve" naming it, a "resolve" naming a file that did not conflict (or a merge
      that did not conflict at all), the same file named by both "resolve" and "mergeWrite", a merge
      that starts no merge because the named branch is already merged in (git says "Already up to date"
      and the result would be an ordinary one-parent commit), and any of the three fields on a commit that
      is not a merge are all REFUSED, never ignored. NOT expressible: an octopus merge with a conflict (git
      itself refuses one), a conflict resolved by DELETING the file ("resolve" always writes content), and
      "hoursAgo" on a merge, which is ignored (as it always was; the REPOS-016, 018 and 034 cases carry it).
    - "uncommittedDelete" removes files from the working tree after the last commit without
      staging the removal — the mirror of "uncommitted", and the state the fail-closed rules
      refuse from the other side: the commit-to-commit diff still names the file, so a check
      that reads the diff and then reads the file finds nothing to read.
    - "hoursAgo" back-dates one commit's author AND committer date. Both, because which one a
      rule reads is the rule's business and a fixture that set only the one today's rule happens
      to read would quietly stop testing anything the day that changed.
    - "origin": "self" gives the repository an origin remote pointing at itself, so its own
      branches become the claim ledger 'git ls-remote --heads origin' reads. Any other value is
      a path under the fixture — an absent one produces the unreachable-ledger state.
    - "originFetch": "<branch>" narrows origin's fetch refspec to that one branch, so the claim
      ledger (ls-remote) lists branches that 'git fetch origin' never makes a remote-tracking ref
      for. That is the state territory-check.ps1 skips out loud (TERR-012) - reachable in any
      clone configured with a single-branch refspec, and unprovable here until the phase 6
      review (F3) showed the exemption written over it was false.
    - "originPushUrl": "<path>" gives origin a separate push URL, a path under the fixture, while its fetch
      URL stays as "origin" set it. With a path that does not exist, a fetch and an ls-remote still read the
      ledger and every 'git push' fails: the state in which a claim's push is rejected with no rival, which
      claim-feature.ps1 reports as a lost allocation race (feature 023, CLF-007). It needs "origin", and is
      refused without one rather than ignored.
    - "originFailCall": N makes the Nth read of origin's refs fail (feature 030, plan P5): every
      'git fetch' and 'git ls-remote' against origin runs the remote's upload-pack, so origin's
      upload-pack is wrapped in a counting script that exits non-zero on call N and runs the real
      one on every other call. A push uses receive-pack and is not counted, so the call order a
      claim makes is fixed: the first fetch is call 1, the first ledger read call 2, the read after
      the first push call 3. The wrapper and its counter live under .git/, so the working tree
      stays clean (a claim refuses a dirty one). It needs "origin", and N must be a whole number
      of at least 1; either is refused rather than ignored.
    - "originRivalOnPush": true makes a rival claim appear on origin after every push (feature 030,
      plan P5): origin's receive-pack is wrapped in a script that runs the real one and then creates
      "<NNN>-rival", a branch carrying the number of every numbered branch just pushed. A claim then
      meets a rival with its own number after each of its attempts, which no stub can do (a stub
      runs once, before the first push): the state behind claim-feature.ps1's 'lost the allocation
      race 3 times' refusal (CLF-007). It needs "origin" and is refused without one.
    - "originPushFailsAfterLanding": N makes the Nth push to origin land and then report failure (feature
      030, plan P5 as amended): origin's receive-pack is wrapped in a counting script that runs the real
      one and exits 1 on call N. The branch is on origin afterwards and "git push" exits non-zero: the
      state in which a push errors after the remote accepted it, which a claim must read as landed. A
      deletion is a push too, so calls are counted across pushes and deletions (a claim's first push is
      call 1). It needs "origin", and N must be a whole number of at least 1. It sets the same remote
      option as "originRivalOnPush", so the two are refused together rather than one silently winning.
    - "originDenyDeletes": true makes origin refuse to delete a branch (feature 030, plan P5): git's own
      receive.denyDeletes is set on the repository origin points at, so 'git push origin --delete <branch>'
      is rejected by the remote ('deletion prohibited') while an ordinary push still lands. That is the
      state in which a claim that lost a race cannot withdraw its own branch. It needs "origin" and is
      refused without one; the repository origin points at must exist when the fixture is finished (a
      nested repository of that name, or "self"), or the build fails.
    - "detach": true leaves HEAD detached at the checked-out commit, the CI shape where the
      current branch cannot be read from the repository at all.
    - "noGit": true removes the .git directory once the fixture is written, so the directory is
      a plain tree that is not a git repository: the state territory-check.ps1 refuses first
      (TERR-008), and the one no recipe could reach because this function always initialises a
      repository. It is refused with 'shallow' or 'nestedRepos' rather than ignored, since a clone
      lands elsewhere and a nested repository is only meaningful inside a repository. No self-test
      beyond its own: a case that ignores the field runs against a healthy repository and so
      fails loudly, unlike a state whose silent skip would produce a passing wrong answer.
    - "nestedRepos" maps a directory name -> a recipe of its own, built as an INDEPENDENT git
      repository inside the outer one once the outer one is finished. That is the nested layout
      (docs/sdlc/repository-strategy.md) scope-check-repos.ps1 exists to grade, and it cannot be
      faked: the script walks each declared directory as a separate working tree, refuses one
      that is not the root of its own repository, and reads the governance declaration as of the
      CODE commit's date. A nested repository is deliberately never part of an outer commit —
      it is built after them, so the outer repository only ever sees an untracked directory.
      Cross-repository DATES are what make the ordering rules testable, so a nested commit's
      "hoursAgo" is the instrument: back-date the governance commit to put the declaration
      first, or back-date the code commit to make the declaration post-date it.

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

function Assert-FixtureMergeShape {
    # A merge the recipe names must be the merge it builds. Git quietly leaves a branch out when it is
    # already merged into the current one ("Already up to date"), so a plain merge can make no commit
    # at all, and an octopus can shrink to fewer parents than it names. Either is a fixture that is not
    # the merge its recipe describes, and a rule graded against it would pass or fail for the wrong
    # reason (feature 026 phase 1 review, F1, F11 and F12).
    param([string]$Root, [string]$HeadBefore, [string[]]$Names, [string]$Branch)
    $headAfter = ((& git -C $Root rev-parse HEAD) -join '').Trim()
    $parents = @(((& git -C $Root rev-list --parents -n 1 HEAD) -join '') -split '\s+' | Where-Object { $_ }).Count - 1
    $expected = 1 + @($Names | Sort-Object -Unique).Count
    if ($headAfter -eq $HeadBefore -or $parents -ne $expected) {
        $moved = if ($headAfter -eq $HeadBefore) { ' and HEAD did not move' } else { '' }
        throw "fixture merge of '$($Names -join ' ')' into '$Branch' did not build the merge it names: HEAD has $parents parent(s) where $expected were expected$moved. Git leaves a branch out of a merge when it is already merged into the current one ('Already up to date'). Refused rather than silently building a fixture that is not the merge the recipe describes."
    }
}
function New-FixtureRepo {
    <#
    .SYNOPSIS
        Materialise a recipe into a temporary git repository. Returns its root path.
    #>
    param(
        [Parameter(Mandatory)]$Recipe,
        [string]$CaseDir,
        [string]$At
    )

    # Refused FIRST, before a directory exists: a refusal that fired after the build would leave
    # a repository (and a shallow clone) behind in the temp directory on every refusal. 'shallow'
    # and 'nestedRepos' would quietly make noGit mean something else, so they are refused, not ignored.
    if ($Recipe.PSObject.Properties.Name -contains 'noGit' -and $Recipe.noGit) {
        foreach ($incompatible in 'shallow', 'nestedRepos') {
            if ($Recipe.PSObject.Properties.Name -contains $incompatible -and $Recipe.$incompatible) {
                throw "fixture 'noGit' cannot be combined with '$incompatible': a fixture with no repository has nothing to clone or nest into. Refused rather than silently ignored."
            }
        }
    }

    if ($Recipe.PSObject.Properties.Name -contains 'originPushUrl' -and $Recipe.originPushUrl) {
        if (-not ($Recipe.PSObject.Properties.Name -contains 'origin' -and $Recipe.origin)) {
            throw "fixture 'originPushUrl' needs 'origin': a push URL belongs to a remote, and there is none. Refused rather than silently ignored."
        }
    }

    if ($Recipe.PSObject.Properties.Name -contains 'originFailCall' -and $null -ne $Recipe.originFailCall) {
        if (-not ($Recipe.PSObject.Properties.Name -contains 'origin' -and $Recipe.origin)) {
            throw "fixture 'originFailCall' needs 'origin': a read of a remote's refs belongs to a remote, and there is none. Refused rather than silently ignored."
        }
        if (-not ($Recipe.originFailCall -is [int] -or $Recipe.originFailCall -is [long]) -or $Recipe.originFailCall -lt 1) {
            throw "fixture 'originFailCall' must be a whole number of at least 1 (the Nth read of origin's refs fails), got '$($Recipe.originFailCall)'. Refused rather than silently ignored."
        }
    }

    if ($Recipe.PSObject.Properties.Name -contains 'originPushFailsAfterLanding' -and $null -ne $Recipe.originPushFailsAfterLanding) {
        if (-not ($Recipe.PSObject.Properties.Name -contains 'origin' -and $Recipe.origin)) {
            throw "fixture 'originPushFailsAfterLanding' needs 'origin': a push to a remote that then errors belongs to a remote, and there is none. Refused rather than silently ignored."
        }
        if (-not ($Recipe.originPushFailsAfterLanding -is [int] -or $Recipe.originPushFailsAfterLanding -is [long]) -or $Recipe.originPushFailsAfterLanding -lt 1) {
            throw "fixture 'originPushFailsAfterLanding' must be a whole number of at least 1 (the Nth push lands and then fails), got '$($Recipe.originPushFailsAfterLanding)'. Refused rather than silently ignored."
        }
        if ($Recipe.PSObject.Properties.Name -contains 'originRivalOnPush' -and $Recipe.originRivalOnPush) {
            throw "fixture 'originPushFailsAfterLanding' cannot be combined with 'originRivalOnPush': both wrap origin's receive-pack, so one would silently replace the other. Refused rather than silently ignored."
        }
    }

    if ($Recipe.PSObject.Properties.Name -contains 'originDenyDeletes' -and $Recipe.originDenyDeletes) {
        if (-not ($Recipe.PSObject.Properties.Name -contains 'origin' -and $Recipe.origin)) {
            throw "fixture 'originDenyDeletes' needs 'origin': a remote that refuses deletions is a remote, and there is none. Refused rather than silently ignored."
        }
    }

    if ($Recipe.PSObject.Properties.Name -contains 'originRivalOnPush' -and $Recipe.originRivalOnPush) {
        if (-not ($Recipe.PSObject.Properties.Name -contains 'origin' -and $Recipe.origin)) {
            throw "fixture 'originRivalOnPush' needs 'origin': a rival claim appears on a remote, and there is none. Refused rather than silently ignored."
        }
    }

    if ($At) {
        # A nested repository: it must be built where the outer recipe asked for it, because its
        # whole reason to exist is the path it occupies inside the outer working tree.
        if ($Recipe.PSObject.Properties.Name -contains 'shallow' -and $Recipe.shallow) {
            throw "nested repository recipe for '$At' uses 'shallow': a shallow clone lands at a new temporary path, so the result would not be nested. Refused rather than silently ignored."
        }
        $root = $At
        if (-not (Test-Path $root)) { New-Item -ItemType Directory -Path $root -Force | Out-Null }
    } else {
        $root = Join-Path ([IO.Path]::GetTempPath()) ("kit-fixture-" + [guid]::NewGuid().ToString('N').Substring(0, 12))
        New-Item -ItemType Directory -Path $root -Force | Out-Null
    }

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
        if ($commit.PSObject.Properties.Name -contains 'orphan' -and $commit.orphan -and $seenBranches -contains $branch) {
            # Refused rather than ignored: an orphan knob that silently did nothing would give a case that
            # passes for the wrong reason (feature 018 phase 3 review, R2-F2).
            throw "fixture 'orphan' names branch '$branch', which already exists. It applies only to the commit that first names a branch."
        }
        if ($branch -ne $current) {
            if ($seenBranches -contains $branch) {
                Invoke-FixtureGit -RepoPath $root -Arguments @('checkout', '--quiet', $branch) | Out-Null
            } else {
                if ($commit.PSObject.Properties.Name -contains 'orphan' -and $commit.orphan) {
                    # A branch with NO history in common with any other: the real no-merge-base state.
                    # The index still holds the previous tree, so it is emptied before the commit's own files.
                    Invoke-FixtureGit -RepoPath $root -Arguments @('checkout', '--quiet', '--orphan', $branch) | Out-Null
                    Invoke-FixtureGit -RepoPath $root -Arguments @('rm', '-rf', '--quiet', '--ignore-unmatch', '.') | Out-Null
                } else {
                    Invoke-FixtureGit -RepoPath $root -Arguments @('checkout', '--quiet', '-b', $branch) | Out-Null
                }
                $seenBranches += $branch
            }
        }

        $isMerge = $commit.PSObject.Properties.Name -contains 'merge' -and $commit.merge
        $mergeFields = @('mergeWrite', 'mergeDelete', 'resolve' | Where-Object { $commit.PSObject.Properties.Name -contains $_ -and $commit.$_ })
        if ($mergeFields.Count -gt 0 -and -not $isMerge) {
            # Refused rather than ignored: a field that silently did nothing would give a case that passes
            # for the wrong reason (the rule applied to 'orphan' and 'rename' before it).
            throw "fixture '$($mergeFields[0])' applies only to a merge commit, and this commit has no 'merge'. Refused rather than silently ignored."
        }
        # A plain merge has two parents and no content of its own, so it takes none of the write /
        # delete / commit path below. D7 skips merge commits because a merge authored nothing;
        # until this existed, no recipe could produce a second parent and that skip was untested.
        if ($isMerge) {
            $mergeMessage = if ($commit.PSObject.Properties.Name -contains 'message' -and $commit.message) { $commit.message } else { "merge $(@($commit.merge) -join ' ')" }
            $mergeNames = @($commit.merge)
            $headBefore = ((& git -C $root rev-parse HEAD) -join '').Trim()
            if ($mergeFields.Count -eq 0) {
                # Exactly the command a plain merge has always run.
                Invoke-FixtureGit -RepoPath $root -Arguments (@('merge', '--quiet', '--no-ff', '--no-edit', '-m', $mergeMessage) + $mergeNames) | Out-Null
                Assert-FixtureMergeShape -Root $root -HeadBefore $headBefore -Names $mergeNames -Branch $branch
                continue
            }
            # A merge with content of its own (feature 026): merge without committing, put the content
            # in, then commit, so the result is a two-parent commit that differs from its parents.
            $mergeOut = & git -C $root merge --quiet --no-ff --no-commit @mergeNames 2>&1
            $mergeExit = $LASTEXITCODE
            $conflicted = @((& git -C $root diff --name-only --diff-filter=U 2>$null) | Where-Object { $_ })
            if ($mergeExit -eq 0) {
                & git -C $root rev-parse -q --verify MERGE_HEAD 2>$null | Out-Null
                if ($LASTEXITCODE -ne 0) {
                    throw "fixture merge of '$($mergeNames -join ' ')' started no merge: the branch is already merged into '$branch' (git says 'Already up to date'), so committing would make an ordinary one-parent commit that carries the merge's own content. Refused rather than silently building a fixture that is not a merge."
                }
            }
            $resolveNames = @()
            if ($commit.PSObject.Properties.Name -contains 'resolve' -and $commit.resolve) {
                $resolveNames = @($commit.resolve.PSObject.Properties.Name)
            }
            if ($mergeExit -ne 0 -and $conflicted.Count -eq 0) {
                throw "fixture git failed: git merge $($mergeNames -join ' ')`n$($mergeOut -join "`n")"
            }
            $both = @($resolveNames | Where-Object { $commit.PSObject.Properties.Name -contains 'mergeWrite' -and $commit.mergeWrite -and (@($commit.mergeWrite.PSObject.Properties.Name) -contains $_) })
            if ($both.Count -gt 0) {
                & git -C $root merge --abort 2>&1 | Out-Null
                throw "fixture names '$($both -join ', ')' in both 'resolve' and 'mergeWrite'. Say which one the merge result takes: refused rather than letting one silently win."
            }
            if ($conflicted.Count -gt 0) {
                $stray = @($resolveNames | Where-Object { $conflicted -notcontains $_ })
                if ($stray.Count -gt 0) {
                    & git -C $root merge --abort 2>&1 | Out-Null
                    throw "fixture 'resolve' names '$($stray -join ', ')', which did not conflict in the merge of '$($mergeNames -join ' ')'. Use 'mergeWrite' for content the merge authors: refused rather than silently treated as a write."
                }
                $unnamed = @($conflicted | Where-Object { $resolveNames -notcontains $_ })
                if ($unnamed.Count -gt 0) {
                    & git -C $root merge --abort 2>&1 | Out-Null
                    throw "fixture merge of '$($mergeNames -join ' ')' leaves a conflict in $($unnamed -join ', ') and 'resolve' does not name it. Say what the merge takes for each conflicted file: refused rather than left half done."
                }
            } elseif ($resolveNames.Count -gt 0) {
                & git -C $root merge --abort 2>&1 | Out-Null
                throw "fixture 'resolve' names $($resolveNames -join ', ') but the merge of '$($mergeNames -join ' ')' did not conflict: there is nothing to resolve. Use 'mergeWrite' for content the merge authors. Refused rather than silently ignored."
            }
            if ($resolveNames.Count -gt 0) {
                foreach ($prop in $commit.resolve.PSObject.Properties) {
                    Write-FixtureFile -RepoPath $root -RelativePath $prop.Name -Content $prop.Value
                }
            }
            if ($commit.PSObject.Properties.Name -contains 'mergeWrite' -and $commit.mergeWrite) {
                foreach ($prop in $commit.mergeWrite.PSObject.Properties) {
                    Write-FixtureFile -RepoPath $root -RelativePath $prop.Name -Content $prop.Value
                }
            }
            if ($commit.PSObject.Properties.Name -contains 'mergeDelete' -and $commit.mergeDelete) {
                foreach ($rel in @($commit.mergeDelete)) {
                    $full = Join-Path $root $rel
                    if (Test-Path $full) { Remove-Item $full -Recurse -Force }
                }
            }
            Invoke-FixtureGit -RepoPath $root -Arguments @('add', '-A') | Out-Null
            Invoke-FixtureGit -RepoPath $root -Arguments @('commit', '--quiet', '--allow-empty', '-m', $mergeMessage) | Out-Null
            Assert-FixtureMergeShape -Root $root -HeadBefore $headBefore -Names $mergeNames -Branch $branch
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
        # A rename, staged with 'git mv' so git records it as R rather than as an add plus a
        # delete. The distinction is the rule: scope-check refuses a declaration file renamed
        # AWAY, and a fixture that deleted-and-added instead would exercise the delete arm and
        # leave the rename arm - 'a delete wearing a costume' - untested.
        if ($commit.PSObject.Properties.Name -contains 'rename' -and $commit.rename) {
            foreach ($prop in $commit.rename.PSObject.Properties) {
                $from = Join-Path $root $prop.Name
                if (-not (Test-Path -LiteralPath $from)) { throw "recipe rename source not found: $($prop.Name)" }
                $toDir = Split-Path -Parent (Join-Path $root $prop.Value)
                if ($toDir -and -not (Test-Path $toDir)) { New-Item -ItemType Directory -Path $toDir -Force | Out-Null }
                Invoke-FixtureGit -RepoPath $root -Arguments @('mv', $prop.Name, $prop.Value) | Out-Null
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

    # A detached HEAD — a CI job that checked out a sha rather than a branch, which is the state
    # where 'rev-parse --abbrev-ref HEAD' answers the word HEAD and a check that believes it
    # classifies the lane wrongly. Expressed as a flag rather than as a sha in the recipe,
    # because a recipe cannot name a sha it has not built yet.
    if ($Recipe.PSObject.Properties.Name -contains 'detach' -and $Recipe.detach) {
        Invoke-FixtureGit -RepoPath $root -Arguments @('checkout', '--quiet', '--detach') | Out-Null
    }

    # An 'origin' remote, because one kit rule reads the CLAIM LEDGER rather than the history:
    # roadmap-claim-check.ps1 asks 'git ls-remote --heads origin' which numbered features exist,
    # and without a remote every one of its verdicts is the n/a. "self" points origin at this
    # very repository, so its own branches ARE the ledger — a real ls-remote over real refs, no
    # network and nothing mocked. Any other value is treated as a path under the fixture, which
    # is how the unreachable-ledger state is produced without reaching for a hostname.
    if ($Recipe.PSObject.Properties.Name -contains 'origin' -and $Recipe.origin) {
        $originUrl = ("$($Recipe.origin)" -eq 'self') ? $root : (Join-Path $root "$($Recipe.origin)")
        Invoke-FixtureGit -RepoPath $root -Arguments @('remote', 'add', 'origin', $originUrl) | Out-Null
        if ($Recipe.PSObject.Properties.Name -contains 'originFetch' -and $Recipe.originFetch) {
            $only = "$($Recipe.originFetch)"
            Invoke-FixtureGit -RepoPath $root -Arguments @('config', 'remote.origin.fetch', "+refs/heads/${only}:refs/remotes/origin/${only}") | Out-Null
        }
        if ($Recipe.PSObject.Properties.Name -contains 'originPushUrl' -and $Recipe.originPushUrl) {
            Invoke-FixtureGit -RepoPath $root -Arguments @('config', 'remote.origin.pushurl', (Join-Path $root "$($Recipe.originPushUrl)")) | Out-Null
        }
        if ($Recipe.PSObject.Properties.Name -contains 'originFailCall' -and $null -ne $Recipe.originFailCall) {
            # The Nth upload-pack call fails; every other call runs the real one. Written under .git/ so the
            # working tree stays clean, with LF endings (it is run by sh), and run as 'sh <script>' so it
            # needs no execute bit on any platform. The counter file sits beside it, starting absent.
            $gitDir = Join-Path $root '.git'
            $wrapper = Join-Path $gitDir 'fixture-upload-pack.sh'
            $lines = @(
                '#!/bin/sh',
                '# Fixture wrapper (feature 030, plan P5): fails the Nth call to upload-pack, runs git-upload-pack otherwise.',
                'here=$(dirname "$0")',
                'f="$here/fixture-upload-pack.count"',
                'n=$(cat "$f" 2>/dev/null || echo 0)',
                'n=$((n + 1))',
                'echo "$n" > "$f"',
                "if [ `"`$n`" = `"$([int]$Recipe.originFailCall)`" ]; then",
                '  echo "fixture: upload-pack call $n is made to fail" >&2',
                '  exit 1',
                'fi',
                'exec git-upload-pack "$@"'
            )
            [System.IO.File]::WriteAllText($wrapper, (($lines -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding($false)))
            $wrapperPath = $wrapper.Replace('\', '/')
            Invoke-FixtureGit -RepoPath $root -Arguments @('config', 'remote.origin.uploadpack', "sh '$wrapperPath'") | Out-Null
        }
        if ($Recipe.PSObject.Properties.Name -contains 'originRivalOnPush' -and $Recipe.originRivalOnPush) {
            # After the real receive-pack, every numbered branch on origin gets a rival carrying its number.
            # git runs this as '<receivepack> <repo path>', so $1 is the repository that was pushed to.
            $wrapper = Join-Path (Join-Path $root '.git') 'fixture-receive-pack.sh'
            $lines = @(
                '#!/bin/sh',
                '# Fixture wrapper (feature 030, plan P5): a rival claim appears after every push.',
                'git-receive-pack "$@"; rc=$?',
                'for b in $(git -C "$1" for-each-ref --format=''%(refname:short)'' ''refs/heads/[0-9]*''); do',
                '  case "$b" in *-rival) continue ;; esac',
                '  git -C "$1" branch "${b%%-*}-rival" main 2>/dev/null',
                'done',
                'exit $rc'
            )
            [System.IO.File]::WriteAllText($wrapper, (($lines -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding($false)))
            Invoke-FixtureGit -RepoPath $root -Arguments @('config', 'remote.origin.receivepack', "sh '$($wrapper.Replace('\', '/'))'") | Out-Null
        }
        if ($Recipe.PSObject.Properties.Name -contains 'originPushFailsAfterLanding' -and $null -ne $Recipe.originPushFailsAfterLanding) {
            # The real receive-pack runs to completion (so the branch lands); the Nth call then exits 1.
            $wrapper = Join-Path (Join-Path $root '.git') 'fixture-receive-pack-fail.sh'
            $lines = @(
                '#!/bin/sh',
                '# Fixture wrapper (feature 030, plan P5 as amended): the Nth push lands and then reports failure.',
                'f="$(dirname "$0")/fixture-receive-pack-fail.count"',
                'n=$(cat "$f" 2>/dev/null || echo 0)',
                'n=$((n + 1))',
                'echo "$n" > "$f"',
                'git-receive-pack "$@"; rc=$?',
                "if [ `"`$n`" = `"$([int]$Recipe.originPushFailsAfterLanding)`" ]; then exit 1; fi",
                'exit $rc'
            )
            [System.IO.File]::WriteAllText($wrapper, (($lines -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding($false)))
            Invoke-FixtureGit -RepoPath $root -Arguments @('config', 'remote.origin.receivepack', "sh '$($wrapper.Replace('\', '/'))'") | Out-Null
        }
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

    # The parent-shaped sibling of truncateBlob. A blob corruption is met by a check that reads a
    # FILE out of history; a check that walks the commit graph never touches one. GAP-027's third
    # state is an unreadable PARENT, so the object truncated here is a commit.
    if ($Recipe.PSObject.Properties.Name -contains 'truncateCommit' -and $Recipe.truncateCommit) {
        $sha = ((Invoke-FixtureGit -RepoPath $root -Arguments @('rev-parse', "$($Recipe.truncateCommit)")) -join '').Trim()
        $objectPath = Join-Path $root (".git/objects/{0}/{1}" -f $sha.Substring(0, 2), $sha.Substring(2))
        if (-not (Test-Path $objectPath)) {
            # Refused rather than ignored, the same way a nested 'shallow' recipe is refused: a
            # silently absent corruption gives a case that passes for the wrong reason, which is
            # the defect class this whole feature exists to find.
            throw "fixture 'truncateCommit' names '$($Recipe.truncateCommit)' ($sha), whose loose object is not at $objectPath - it may be packed. Refused rather than silently ignored."
        }
        $item = Get-Item -LiteralPath $objectPath -Force
        $item.Attributes = $item.Attributes -band -bnot [IO.FileAttributes]::ReadOnly
        $bytes = [IO.File]::ReadAllBytes($objectPath)
        [IO.File]::WriteAllBytes($objectPath, $bytes[0..([Math]::Max(0, [int]($bytes.Length / 2)))])
    }

    if ($Recipe.PSObject.Properties.Name -contains 'shallow' -and $Recipe.shallow) {
        $clone = Join-Path ([IO.Path]::GetTempPath()) ("kit-fixture-" + [guid]::NewGuid().ToString('N').Substring(0, 12))
        $branch = if ($Recipe.PSObject.Properties.Name -contains 'checkout' -and $Recipe.checkout) { $Recipe.checkout } else { $defaultBranch }
        $uri = ConvertTo-FileUri -Path $root
        # "shallowAllBranches" (feature 027): clone every branch shallowly instead of only the checked-out
        # one, so origin/main resolves and a base can be computed in a clone that is still shallow
        # (a depth-N CI checkout that also fetched main). Without it a shallow fixture has no base.
        $cloneArgs = @('clone', '--quiet', '--depth', $Recipe.shallow, '--branch', $branch)
        if ($Recipe.PSObject.Properties.Name -contains 'shallowAllBranches' -and $Recipe.shallowAllBranches) { $cloneArgs += '--no-single-branch' }
        & git @cloneArgs $uri $clone 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "fixture shallow clone failed for $root" }
        Invoke-FixtureGit -RepoPath $clone -Arguments @('config', 'user.name', 'Fixture Author') | Out-Null
        Invoke-FixtureGit -RepoPath $clone -Arguments @('config', 'user.email', 'fixture@example.invalid') | Out-Null
        Remove-Item $root -Recurse -Force -ErrorAction SilentlyContinue
        # Reassigned rather than returned: the nested repositories below must be built into
        # whatever root the case ends up with, and an early return here would have built them
        # into a directory this function had just deleted.
        $root = $clone
    }

    # A directory that is not a repository. Removed AFTER everything else so the tree that remains
    # is exactly what the recipe wrote. The incompatible fields were refused at the top, before
    # anything was built.
    if ($Recipe.PSObject.Properties.Name -contains 'noGit' -and $Recipe.noGit) {
        # git writes loose objects read-only; -Force clears that, as Remove-FixtureRepo relies on.
        Remove-Item -LiteralPath (Join-Path $root '.git') -Recurse -Force
    }

    # Independent repositories inside this one, built last (recursively, through this same
    # function) so that no commit of the outer repository can contain them — which is exactly
    # the relationship the real nested layout has.
    if ($Recipe.PSObject.Properties.Name -contains 'nestedRepos' -and $Recipe.nestedRepos) {
        foreach ($prop in $Recipe.nestedRepos.PSObject.Properties) {
            New-FixtureRepo -Recipe $prop.Value -CaseDir $CaseDir -At (Join-Path $root $prop.Name) | Out-Null
        }
    }

    # After the nested repositories exist, because origin is usually one of them.
    if ($Recipe.PSObject.Properties.Name -contains 'originDenyDeletes' -and $Recipe.originDenyDeletes) {
        $originDir = ("$($Recipe.origin)" -eq 'self') ? $root : (Join-Path $root "$($Recipe.origin)")
        if (-not (Test-Path -LiteralPath $originDir)) {
            throw "fixture 'originDenyDeletes': origin points at '$originDir', which does not exist, so there is no repository to make refuse deletions. Refused rather than silently ignored."
        }
        Invoke-FixtureGit -RepoPath $originDir -Arguments @('config', 'receive.denyDeletes', 'true') | Out-Null
    }

    return $root
}

function ConvertTo-FileUri {
    <#
    .SYNOPSIS
        A local directory as a file:// URI, on either platform.

    .DESCRIPTION
        git needs a file:// URI rather than a path for '--depth' to mean anything: a plain local
        path is cloned by hardlinking the object store, which copies the whole history and leaves
        the fixture with the very base it is supposed to lack.

        The count of slashes is the whole problem. A Windows path carries no leading slash, so the
        URI needs three; a POSIX path supplies its own, so a third makes 'file:////tmp/x' - and the
        URI parser reads that run as an empty authority followed by '//tmp/x', then normalises it
        to 'file://tmp/x', where 'tmp' is now the HOST. git dutifully tries to reach a machine
        called tmp. Concatenation is what hid it: the result is a perfectly well-formed URI, just
        not to the thing that was asked for.

        Found by CI's ubuntu leg and by nothing else (SC-006) - the Windows leg, every local run
        and the fresh-context review's own independent suite run all passed, because all three are
        the platform where three slashes happen to be right.
    #>
    param([Parameter(Mandatory)][string]$Path)
    $normalised = $Path -replace '\\', '/'
    $prefix = if ($normalised.StartsWith('/')) { 'file://' } else { 'file:///' }
    return ([uri]($prefix + $normalised)).AbsoluteUri
}


function Remove-FixtureRepo {
    param([Parameter(Mandatory)][string]$Path)
    if ($Path -and (Test-Path $Path)) {
        Remove-Item $Path -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Export-ModuleMember -Function New-FixtureRepo, Remove-FixtureRepo, ConvertTo-FileUri
