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
