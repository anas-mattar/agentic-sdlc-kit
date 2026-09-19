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
