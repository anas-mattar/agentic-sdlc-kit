<#
    The harness testing itself — specifically RunChild.ps1, the launcher every case goes through.

    Phase 2's fresh-context review found it reporting exit 0 for a script that never ran: a
    parameter-binding failure writes an error and leaves $LASTEXITCODE untouched, so 'exit
    $LASTEXITCODE' returned 0 and a fixture expecting 0 would have gone green against a script
    that produced nothing but an error message. None of phase 2's three fixtures happened to
    trigger it. Phases 3-6 add roughly eighty more, all through this one file.

    A fail-open in the thing that grades the graders is worth its own tests, so these assert the
    four shapes directly rather than trusting a fixture to notice. They use throwaway scripts in
    a temporary directory, never a kit script, so they stay true whatever the kit scripts do.
#>

BeforeAll {
    Import-Module (Join-Path $PSScriptRoot 'lib/FixtureRepo.psm1') -Force
    $script:Launcher = Join-Path $PSScriptRoot 'lib/RunChild.ps1'
    $script:Sandbox = Join-Path ([IO.Path]::GetTempPath()) ("kit-harness-self-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
    New-Item -ItemType Directory -Path $script:Sandbox -Force | Out-Null

    function New-ProbeScript {
        param([string]$Name, [string[]]$Body)
        $path = Join-Path $script:Sandbox $Name
        [IO.File]::WriteAllText($path, (($Body -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding($false)))
        return $path
    }

    function Invoke-Launcher {
        param([string]$Target, [string[]]$Arguments)
        $out = Join-Path $script:Sandbox 'out.txt'
        $argv = @(@('-NoProfile', '-NonInteractive', '-File', $script:Launcher, $Target) + $Arguments |
            ForEach-Object { if ($_ -match '[\s"]') { '"' + ($_ -replace '"', '\"') + '"' } else { $_ } })
        $p = Start-Process -FilePath (Get-Process -Id $PID).Path -ArgumentList $argv `
            -NoNewWindow -Wait -PassThru -RedirectStandardOutput $out -RedirectStandardError (Join-Path $script:Sandbox 'err.txt')
        return [pscustomobject]@{ ExitCode = $p.ExitCode; Output = [IO.File]::ReadAllText($out) }
    }
}

AfterAll {
    if ($script:Sandbox -and (Test-Path $script:Sandbox)) { Remove-Item $script:Sandbox -Recurse -Force -ErrorAction SilentlyContinue }
}

Describe 'RunChild exit codes' {

    It 'returns 0 when the script runs and returns normally' {
        $s = New-ProbeScript 'normal.ps1' @('param([string]$Root)', 'Write-Host "ran"')
        $r = Invoke-Launcher -Target $s -Arguments @('-Root', 'x')
        $r.ExitCode | Should -Be 0
        $r.Output.Trim() | Should -Be 'ran'
    }

    It 'returns the script''s own exit code when it reports a verdict' {
        $s = New-ProbeScript 'verdict.ps1' @('param([string]$Root)', 'Write-Host "FAIL"', 'exit 1')
        (Invoke-Launcher -Target $s -Arguments @('-Root', 'x')).ExitCode | Should -Be 1
    }

    It 'returns 97, not 0, when the script never runs because a parameter fails to bind' {
        # '-Root -Check' is the real shape: the switch is eaten as Root's argument and binding
        # fails. Before the review's F1 this exited 0 and read as a passing check.
        $s = New-ProbeScript 'mandatory.ps1' @('param([Parameter(Mandatory)][string]$Root, [switch]$Check)', 'Write-Host "ran"')
        $r = Invoke-Launcher -Target $s -Arguments @('-Root', '-Check')
        $r.ExitCode | Should -Be 97
        $r.Output | Should -Match 'did not run to a verdict'
    }

    It 'returns 97, not 0, when the script does not exist' {
        $r = Invoke-Launcher -Target (Join-Path $script:Sandbox 'absent.ps1') -Arguments @('-Root', 'x')
        $r.ExitCode | Should -Be 97
    }

    It 'returns 97 when the script throws before reporting a verdict' {
        $s = New-ProbeScript 'boom.ps1' @('param([string]$Root)', 'throw "boom"')
        $r = Invoke-Launcher -Target $s -Arguments @('-Root', 'x')
        $r.ExitCode | Should -Be 97
        $r.Output | Should -Match 'threw before returning a verdict'
    }
}

Describe 'RunChild argument and encoding fidelity' {

    It 'passes a switch as a switch and a value as a value' {
        $s = New-ProbeScript 'bind.ps1' @('param([string]$Root, [switch]$Check)', 'Write-Host "root=[$Root] check=$Check"')
        (Invoke-Launcher -Target $s -Arguments @('-Root', 'a b', '-Check')).Output.Trim() |
            Should -Be 'root=[a b] check=True'
    }

    It 'carries a non-ASCII character through unchanged' {
        # The reason this launcher exists: a redirected child writing in the console code page
        # transliterates an em dash to a hyphen AS IT WRITES, and no reader-side decoding
        # recovers it. Every kit message contains one.
        $s = New-ProbeScript 'dash.ps1' @('param([string]$Root)', 'Write-Host "a — b"')
        (Invoke-Launcher -Target $s -Arguments @('-Root', 'x')).Output.Trim() | Should -Be 'a — b'
    }

    It 'preserves a single quote inside a value' {
        $s = New-ProbeScript 'quote.ps1' @('param([string]$Root)', 'Write-Host "root=[$Root]"')
        (Invoke-Launcher -Target $s -Arguments @('-Root', "it's")).Output.Trim() | Should -Be "root=[it's]"
    }
}

Describe 'fixture file:// URI construction' {
    # The shallow-clone recipe state builds a file:// URI from a local path, and it built one that
    # was well-formed and wrong on POSIX: 'file:///' concatenated with '/tmp/x' gives four slashes,
    # which the URI parser normalises to 'file://tmp/x' with 'tmp' as the HOST. Every Windows run
    # passed - the local suite, CI's windows-latest leg, and the fresh-context review's own
    # independent run - because on Windows three slashes are right. Only CI's ubuntu leg failed.
    #
    # Asserted on BOTH shapes from either platform, because a test that exercises only the host
    # platform's shape is what let this through in the first place.

    It 'gives a POSIX path an empty authority' {
        $uri = ConvertTo-FileUri -Path '/tmp/kit-fixture-abc'
        $uri | Should -Be 'file:///tmp/kit-fixture-abc'
        ([uri]$uri).Host | Should -BeExactly ''
    }

    It 'gives a Windows path an empty authority' {
        $uri = ConvertTo-FileUri -Path 'C:\Users\x\Temp\kit-fixture-abc'
        $uri | Should -Be 'file:///C:/Users/x/Temp/kit-fixture-abc'
        ([uri]$uri).Host | Should -BeExactly ''
    }

    It 'never lets the first path segment become a host' {
        # The defect stated as the property that failed, rather than as the two paths that
        # happened to expose it.
        foreach ($p in '/tmp/x', '/var/folders/T/x', 'C:\Temp\x', 'D:\solutions\x') {
            ([uri](ConvertTo-FileUri -Path $p)).Host | Should -BeExactly '' -Because "$p must not yield a host"
        }
    }
}

Describe 'nested fixture repositories' {
    # scope-check-repos.ps1 grades independent repositories that live INSIDE the governance
    # repository, and three of its rules exist only to refuse a directory that looks nested but
    # is not one - present-but-not-a-repository, present-but-part-of-the-outer-repository, no
    # such branch here. A recipe state that quietly produced an ordinary subdirectory would make
    # every one of those fixtures pass for the wrong reason, so the shape is asserted here
    # rather than inferred from a green case.

    BeforeAll {
        $script:NestedRecipe = [pscustomobject]@{
            defaultBranch = 'main'
            commits       = @([pscustomobject]@{ branch = 'main'; message = 'init'; write = [pscustomobject]@{ 'kit-adoption.json' = "{}`n" } })
            nestedRepos   = [pscustomobject]@{
                'code-repo' = [pscustomobject]@{
                    defaultBranch = 'main'
                    commits       = @([pscustomobject]@{ branch = 'main'; message = 'code init'; write = [pscustomobject]@{ 'src/a.txt' = "a`n" } })
                }
            }
        }
    }

    It 'builds the nested directory as a repository of its own' {
        $root = New-FixtureRepo -Recipe $script:NestedRecipe
        try {
            $nested = Join-Path $root 'code-repo'
            $top = (& git -C $nested rev-parse --show-toplevel) -join ''
            $LASTEXITCODE | Should -Be 0
            (Resolve-Path "$top".Trim()).Path | Should -Be (Resolve-Path $nested).Path
            (Resolve-Path "$top".Trim()).Path | Should -Not -Be (Resolve-Path $root).Path
        } finally { Remove-FixtureRepo -Path $root }
    }

    It 'leaves the nested repository out of every commit of the outer one' {
        # The real layout has the code repositories untracked in the governance tree. A fixture
        # that committed them would be grading a directory the outer repository owns, which is
        # the one thing the script refuses.
        $root = New-FixtureRepo -Recipe $script:NestedRecipe
        try {
            $tracked = @(& git -C $root log --all --name-only --pretty=format: -- 'code-repo' | Where-Object { $_ })
            $tracked.Count | Should -Be 0
        } finally { Remove-FixtureRepo -Path $root }
    }

    It 'refuses a nested recipe that asks to be shallow instead of ignoring it' {
        # A shallow clone lands at a fresh temporary path, so honouring it here would return a
        # repository that is not nested at all - and the case would still go green. T046's rule:
        # a recipe state that cannot do what it says must say so, never skip quietly.
        $recipe = [pscustomobject]@{
            commits     = @([pscustomobject]@{ branch = 'main'; message = 'init'; write = [pscustomobject]@{ 'a.txt' = "a`n" } })
            nestedRepos = [pscustomobject]@{
                'code-repo' = [pscustomobject]@{
                    commits = @([pscustomobject]@{ branch = 'main'; message = 'c'; write = [pscustomobject]@{ 'b.txt' = "b`n" } })
                    shallow = 1
                }
            }
        }
        $root = $null
        { $root = New-FixtureRepo -Recipe $recipe } | Should -Throw -ExpectedMessage "*would not be nested*"
        if ($root) { Remove-FixtureRepo -Path $root }
    }
}

Describe 'output normalisation' {
    # A third substitution joined <ROOT> and <SHA> in T029. scope-check-repos.ps1's
    # anti-retroactivity message quotes the code commit's own committer date back to the reader,
    # so the rule's output is different in every run and no hand-written expectation could ever
    # match it. The boundary is the point: a run-varying instant is noise, a calendar date a
    # human wrote in a document is content, and normalising the second would quietly stop the
    # Critical-lane approval fixtures from pinning anything.

    BeforeAll { Import-Module (Join-Path $PSScriptRoot 'lib/Harness.psm1') -Force }

    It 'replaces an ISO-8601 instant, in either offset spelling' {
        foreach ($stamp in '2026-09-19T14:03:11+02:00', '2026-09-19T14:03:11Z', '2026-09-19T14:03:11+0200') {
            $out = ConvertTo-NormalisedOutput -Text "committed at $stamp today" -RepoPath 'no-such-path'
            $out.Trim() | Should -Be 'committed at <DATE> today'
        }
    }

    It 'leaves a calendar date with no time on it exactly as written' {
        $out = ConvertTo-NormalisedOutput -Text 'approved 2026-09-10 by the owner' -RepoPath 'no-such-path'
        $out.Trim() | Should -Be 'approved 2026-09-10 by the owner'
    }

    It 'still replaces the sha inside a line that also carries an instant' {
        $out = ConvertTo-NormalisedOutput -Text 'commit 8a0291b at 2026-09-19T14:03:11+02:00' -RepoPath 'no-such-path'
        $out.Trim() | Should -Be 'commit <SHA> at <DATE>'
    }
}

Describe 'what the harness captures is what the script printed' {
    # Phase 4 shipped green on Windows and failed 16 of 740 cases on ubuntu, every one of them
    # a case whose expectation contains a blank line. The scripts were blamed first, and they
    # were innocent: `Write-Host ''` behaves identically on both platforms. The harness was the
    # defect. `Start-Process -RedirectStandardOutput` DROPS EMPTY LINES on Linux, so the thing
    # being compared against the expectation was not what the script printed.
    #
    # Measured on ubuntu 24.04 with the same pwsh 7.6.5 CI runs (run 35437579942):
    #
    #   Start-Process -RedirectStandardOutput   first<LF>second          the blank is gone
    #   Process + ReadToEndAsync                first<LF><LF>second      the blank survives
    #
    # This drives Invoke-FixtureCase itself — a synthetic kit root and a one-line emitter —
    # rather than re-implementing the launch here. A self-test that built its own process the
    # way the harness used to would have passed while the harness stayed broken, which is the
    # mistake that produced the first attempt at this fix.

    BeforeAll { Import-Module (Join-Path $PSScriptRoot 'lib/Harness.psm1') -Force }

    It 'compares what the script actually printed, blank lines included' {
        $tmp = Join-Path ([IO.Path]::GetTempPath()) ('kit-blank-' + [guid]::NewGuid().ToString('N').Substring(0, 12))
        $kitRoot = Join-Path $tmp 'kit'
        $caseDir = Join-Path $tmp 'case'
        New-Item -ItemType Directory -Path (Join-Path $kitRoot 'scripts') -Force | Out-Null
        New-Item -ItemType Directory -Path $caseDir -Force | Out-Null
        try {
            $utf8 = New-Object System.Text.UTF8Encoding($false)
            [IO.File]::WriteAllText(
                (Join-Path $kitRoot 'scripts/blank-emitter.ps1'),
                "param([string]`$Root)`nWrite-Host 'first'`nWrite-Host ''`nWrite-Host 'second'`nexit 0`n",
                $utf8)
            [IO.File]::WriteAllText(
                (Join-Path $caseDir 'recipe.json'),
                '{"description":"a repository the emitter ignores","defaultBranch":"main","commits":[{"branch":"main","message":"init","write":{"README.md":"x\n"}}]}',
                $utf8)
            [IO.File]::WriteAllText(
                (Join-Path $caseDir 'command.json'),
                '{"script":"blank-emitter.ps1","args":[],"exitCode":0}',
                $utf8)
            [IO.File]::WriteAllText((Join-Path $caseDir 'expected.txt'), "first`n`nsecond`n", $utf8)

            $result = Invoke-FixtureCase -CaseDir $caseDir -KitRoot $kitRoot
            $result.ExitMatch | Should -BeTrue
            $result.Actual | Should -Be "first`n`nsecond`n"
            $result.OutputMatch | Should -BeTrue
        } finally {
            Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'carries a non-ASCII character through, on the real capture path' {
        # There IS a test called 'carries a non-ASCII character through unchanged' above, and it
        # passed while this was broken: it drives Invoke-Launcher, a helper defined in this file,
        # not the launch Invoke-FixtureCase actually performs. When that launch moved to
        # System.Diagnostics.Process it lost its encoding and decoded the child with the console
        # codepage, turning every em dash into three CP437 characters — in a kit where every
        # message contains one.
        #
        # It did not fail every time, and that is why this test FORCES the condition instead of
        # hoping for it. The decode only goes wrong when the PARENT's console encoding is not
        # UTF-8, so the bug appeared under Run-Tests.ps1 and vanished under a bare Invoke-Pester,
        # which normalises encoding for its own run. A version of this test that merely emitted
        # an em dash passed with the fix reverted — it proved nothing. Latin-1 rather than CP437:
        # both mangle the bytes, and only Latin-1 is built into .NET on Linux as well.
        $previousEncoding = [Console]::OutputEncoding
        [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding('iso-8859-1')
        $tmp = Join-Path ([IO.Path]::GetTempPath()) ('kit-dash-' + [guid]::NewGuid().ToString('N').Substring(0, 12))
        $kitRoot = Join-Path $tmp 'kit'
        $caseDir = Join-Path $tmp 'case'
        New-Item -ItemType Directory -Path (Join-Path $kitRoot 'scripts') -Force | Out-Null
        New-Item -ItemType Directory -Path $caseDir -Force | Out-Null
        try {
            $utf8 = New-Object System.Text.UTF8Encoding($false)
            [IO.File]::WriteAllText(
                (Join-Path $kitRoot 'scripts/dash-emitter.ps1'),
                "param([string]`$Root)`nWrite-Host 'doc-lint: OK $([char]0x2014) done'`nexit 0`n",
                $utf8)
            [IO.File]::WriteAllText(
                (Join-Path $caseDir 'recipe.json'),
                '{"description":"a repository the emitter ignores","defaultBranch":"main","commits":[{"branch":"main","message":"init","write":{"README.md":"x
"}}]}',
                $utf8)
            [IO.File]::WriteAllText(
                (Join-Path $caseDir 'command.json'),
                '{"script":"dash-emitter.ps1","args":[],"exitCode":0}',
                $utf8)
            [IO.File]::WriteAllText((Join-Path $caseDir 'expected.txt'), "doc-lint: OK $([char]0x2014) done`n", $utf8)

            $result = Invoke-FixtureCase -CaseDir $caseDir -KitRoot $kitRoot
            $result.Actual | Should -Be "doc-lint: OK $([char]0x2014) done`n"
            $result.OutputMatch | Should -BeTrue
        } finally {
            [Console]::OutputEncoding = $previousEncoding
            Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
Describe 'the harness leaves the repository it runs from alone (T047, FR-020)' {

    # FR-020 has two halves and they fail differently. A harness that WRITES to the repository
    # under it corrupts the thing it is measuring - and would do so silently, because the
    # suite's own verdict would still be green. A harness that READS the repository's branch,
    # working tree or git identity is worse in a quieter way: it passes here and fails on a
    # colleague's machine, or on CI, for reasons nobody can see from the output. Neither half
    # was asserted before phase 6; both were true by construction and by nobody's promise.

    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot 'lib/Harness.psm1') -Force
        # Harness.psm1 imports FixtureRepo but does not re-export it; the identity test below
        # builds a repository directly, so it needs the builder in scope here too.
        Import-Module (Join-Path $PSScriptRoot 'lib/FixtureRepo.psm1') -Force
        $script:KitRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
        function Get-TreeState {
            param([string]$Root)
            # --untracked-files=all, not the default: a harness that dropped a stray temporary
            # file inside an ignored directory would still be writing to this repository, and
            # the default listing would fold it into one unchanged-looking line.
            return [pscustomobject]@{
                Head   = (& git -C $Root rev-parse HEAD 2>$null | Out-String).Trim()
                Branch = (& git -C $Root rev-parse --abbrev-ref HEAD 2>$null | Out-String).Trim()
                Status = ((& git -C $Root status --porcelain=v1 --untracked-files=all 2>$null) -join "`n")
            }
        }
        # One real case, chosen because it is among the most invasive the suite has: it builds a
        # repository, clones it, runs a kit script against the clone and normalises paths.
        $script:SampleCase = Join-Path $PSScriptRoot 'cases/enforcement-pack/GAP27-001/fail'
    }

    It 'does not change the working tree, HEAD or branch of the repository under it' {
        $before = Get-TreeState -Root $script:KitRoot
        $null = Invoke-FixtureCase -CaseDir $script:SampleCase -KitRoot $script:KitRoot
        $after = Get-TreeState -Root $script:KitRoot

        $after.Head | Should -Be $before.Head
        $after.Branch | Should -Be $before.Branch
        if ($after.Status -ne $before.Status) {
            $added = @($after.Status -split "`n" | Where-Object { $_ -and $_ -notin ($before.Status -split "`n") })
            throw ("running one fixture case changed the repository it was run from (FR-020). New or changed entries:`n  " +
                ($added -join "`n  "))
        }
        $after.Status | Should -Be $before.Status
    }

    It 'gives every fixture commit the fixture identity, not this repository''s' {
        # The identity half of FR-020, asserted where it can actually be observed. If the
        # harness inherited the ambient git identity, a fixture built on a machine with no
        # user.email would fail to commit at all - which is how this dependency announces
        # itself: never here, always somewhere else.
        $repo = $null
        try {
            $recipe = Get-Content (Join-Path $script:SampleCase 'recipe.json') -Raw | ConvertFrom-Json
            $repo = New-FixtureRepo -Recipe $recipe -CaseDir $script:SampleCase
            $authors = @(& git -C $repo log --all --format='%an <%ae>' 2>$null | Sort-Object -Unique)
            $authors | Should -Not -BeNullOrEmpty
            foreach ($author in $authors) {
                $author | Should -Be 'Fixture Author <fixture@example.invalid>'
            }
            $kitIdentity = (& git -C $script:KitRoot config user.email 2>$null | Out-String).Trim()
            if ($kitIdentity) { $authors | Should -Not -Contain $kitIdentity }
        } finally {
            if ($repo) { Remove-FixtureRepo -Path $repo }
        }
    }

    It 'names no branch of this repository in any case command' {
        # The branch half. A case that passed -Branch 015-enforcement-assurance would be green
        # here and red for everyone else the day this branch merges; a case that passed the
        # CURRENT branch by reading it would be green everywhere and asserting nothing.
        $current = (& git -C $script:KitRoot rev-parse --abbrev-ref HEAD 2>$null | Out-String).Trim()
        $offenders = @()
        foreach ($dir in (Get-CaseDirectories -TestsRoot $PSScriptRoot)) {
            $text = [IO.File]::ReadAllText((Join-Path $dir 'command.json'))
            if ($current -and $text.Contains($current)) { $offenders += $dir }
        }
        if ($offenders.Count -gt 0) {
            throw ("these cases name the branch this repository happens to be on ('$current'), so their verdict depends on where they are run (FR-020):`n  " +
                ($offenders -join "`n  "))
        }
        $offenders.Count | Should -Be 0
    }
}
