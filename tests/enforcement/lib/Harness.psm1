<#
.SYNOPSIS
    Runs one fixture case against a kit script and compares the output to a literal expectation.

.DESCRIPTION
    Feature 015, plan D1 and FR-006: this module MUST NOT import, dot-source, or otherwise
    borrow anything from the scripts it tests. Expectations are literal text written by hand.
    That rule is not fussiness — feature 014's B7 defect and GAP-025 both exist because a check
    and its evidence went through the same parser, so the two agreed with each other and both
    were wrong.

    A case is a directory holding:

      recipe.json    the repository to build (see FixtureRepo.psm1)
      command.json   which script to run, with which arguments, and the expected exit code
      expected.txt   the normalised output, verbatim

    command.json:

      {
        "script":   "enforcement-pack.ps1",
        "args":     ["-Branch", "001-thing"],
        "exitCode": 1
      }

    The harness always supplies -Root itself, pointing at the fixture repository.

    NORMALISATION. Raw output carries values that legitimately differ per run — the temporary
    repository path and commit shas. Those, and only those, are replaced before comparison:

      <ROOT>   the fixture repository path, in any slash direction
      <SHA>    a 7-to-40 character hex run that git produced
      <DATE>   an ISO-8601 instant with a time on it — git's %cI, which scope-check-repos.ps1
               quotes back in its anti-retroactivity message

    <DATE> was added in T029 for a reason worth recording: the cross-repository POST-DATES rule
    prints the commit's own committer date, so its message is different in every run and the
    rule could not be pinned by a fixture at all. A DATE-only string ('2026-09-10') is left
    alone — the Critical lane's approval dates are content, not run-varying noise, and
    normalising them would stop a fixture from pinning them.

    Line endings are normalised to LF and trailing whitespace is stripped, so a fixture's
    verdict cannot depend on the platform that ran it (SC-006).
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'FixtureRepo.psm1') -Force


function ConvertTo-NormalisedOutput {
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Text, [Parameter(Mandatory)][string]$RepoPath)

    $text = $Text -replace "`r`n", "`n"

    # The repository path, in every spelling a tool might print it.
    $variants = @($RepoPath, ($RepoPath -replace '\\', '/'), ($RepoPath -replace '/', '\'))
    try {
        $resolved = (Resolve-Path $RepoPath -ErrorAction Stop).Path
        $variants += @($resolved, ($resolved -replace '\\', '/'), ($resolved -replace '/', '\'))
    } catch { }
    foreach ($variant in ($variants | Select-Object -Unique | Sort-Object Length -Descending)) {
        $text = $text.Replace($variant, '<ROOT>')
    }

    # Instants, before shas: an ISO-8601 timestamp is the other value a run cannot repeat.
    # Anchored on the 'T' and a time, so a plain calendar date stays exactly as written.
    $text = [regex]::Replace($text, '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:?\d{2})?', '<DATE>')

    # Commit shas. Bounded to hex runs of 7+ so ordinary words survive.
    $text = [regex]::Replace($text, '\b[0-9a-f]{7,40}\b', '<SHA>')

    $lines = $text -split "`n" | ForEach-Object { $_.TrimEnd() }
    return (($lines -join "`n").TrimEnd() + "`n")
}

function Invoke-FixtureCase {
    <#
    .SYNOPSIS
        Build the case's repository, run its command, return the comparison result.
    #>
    param(
        [Parameter(Mandatory)][string]$CaseDir,
        [Parameter(Mandatory)][string]$KitRoot,
        [switch]$KeepRepo
    )

    foreach ($required in 'recipe.json', 'command.json', 'expected.txt') {
        $p = Join-Path $CaseDir $required
        if (-not (Test-Path $p)) { throw "case $CaseDir is missing $required" }
    }

    $recipe = Get-Content (Join-Path $CaseDir 'recipe.json') -Raw | ConvertFrom-Json
    $command = Get-Content (Join-Path $CaseDir 'command.json') -Raw | ConvertFrom-Json
    $expected = ConvertTo-NormalisedOutput -Text ([IO.File]::ReadAllText((Join-Path $CaseDir 'expected.txt'))) -RepoPath 'no-such-path'

    $repo = New-FixtureRepo -Recipe $recipe -CaseDir $CaseDir
    try {
        $scriptPath = Join-Path (Join-Path $KitRoot 'scripts') $command.script
        if (-not (Test-Path $scriptPath)) { throw "case $CaseDir names a script that does not exist: $($command.script)" }

        # Through RunChild.ps1, never straight to the script: a fresh pwsh on Windows writes
        # redirected stdout in the console code page and transliterates every non-ASCII
        # character on the way out, so an em dash in a kit message would reach the expectation
        # as a hyphen. The launcher sets UTF-8 inside the child before the script runs.
        $launcher = Join-Path $PSScriptRoot 'RunChild.ps1'
        # -Root normally IS the fixture. One family of rules needs it not to be: verify-kit.ps1's
        # first guard refuses a root that does not exist, and a case cannot reach it by passing a
        # second -Root (PowerShell refuses the duplicate and the script never runs). 'rootSuffix'
        # appends to the fixture path, so the value stays inside the fixture's own namespace and
        # normalises to <ROOT>/... identically on both platforms. No self-test: ignoring this
        # field makes its case FAIL loudly against the healthy fixture, unlike a recipe state
        # whose silent skip would produce a passing wrong answer.
        $rootArg = $repo
        if ($command.PSObject.Properties.Name -contains 'rootSuffix' -and $command.rootSuffix) {
            $rootArg = "$repo/$($command.rootSuffix)"
        }
        $arguments = @('-NoProfile', '-NonInteractive', '-File', $launcher, $scriptPath)
        # 'noRoot': the one script in scope that has no -Root parameter. territory-check.ps1
        # locates the repository with 'git rev-parse --show-toplevel' from the CURRENT
        # DIRECTORY, so passing -Root fails to bind (the launcher would answer 97) and not
        # passing it would point the script at the kit checkout this suite runs from. Such a
        # case runs with its working directory set to the fixture instead. The accommodation
        # lives here rather than in the script because phase 4 may only touch tests/** — and
        # the inconsistency itself is recorded as a finding, not quietly absorbed: eight
        # grading scripts can be aimed at another tree and the ninth cannot.
        $workingDir = $null
        if ($command.PSObject.Properties.Name -contains 'noRoot' -and $command.noRoot) {
            $workingDir = $repo
        } else {
            $arguments += @('-Root', $rootArg)
        }
        if ($command.PSObject.Properties.Name -contains 'args' -and $command.args) {
            $arguments += @($command.args)
        }

        # NOT Start-Process. `Start-Process -RedirectStandardOutput` DROPS EMPTY LINES on
        # Linux: the harness was comparing a stream the script never printed, so any rule
        # whose output contains a blank line failed on ubuntu and passed on Windows. Sixteen
        # cases in ritual-checks and territory-check did exactly that, and the fixtures were
        # blamed before the harness was (run 35437579942). Measured on ubuntu 24.04 with the
        # same pwsh 7.6.5 CI runs, against all four ways a script can emit a blank line:
        #
        #   Start-Process -RedirectStandardOutput   a<LF>b        the blank is gone
        #   Process + ReadToEndAsync                a<LF><LF>b    the blank survives
        #
        # ArgumentList also replaces the hand-rolled quoting this function used to need:
        # Start-Process joins an array with spaces and quotes nothing, so '-Root /a b/c'
        # arrived as two arguments and the case ran against a path that does not exist
        # (phase 2 review F1). ProcessStartInfo.ArgumentList passes each element as one
        # argument, so the escaping is the runtime's problem rather than ours.
        $psi = [System.Diagnostics.ProcessStartInfo]::new()
        $psi.FileName = (Get-Process -Id $PID).Path
        foreach ($argument in $arguments) { $psi.ArgumentList.Add($argument) }
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        # Pin both streams to UTF-8. Unset, .NET decodes the child with the console's
        # codepage, so an em dash (E2 80 94) arrives as three CP437 characters and the case
        # fails on a line the script printed correctly. It did NOT fail every time: the same
        # case decoded cleanly under Pester and mojibaked when run directly, which is the
        # worse half of the bug — an instrument that grades correctly only sometimes.
        # PowerShell 7 writes redirected output as UTF-8, so this pins the reader to what
        # the writer already emits rather than imposing a choice.
        $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
        $psi.StandardOutputEncoding = $utf8NoBom
        $psi.StandardErrorEncoding = $utf8NoBom
        # Only for a 'noRoot' case: every other case names its tree explicitly, and moving
        # them all into the fixture would change the ground under two hundred green cases
        # for no rule's sake.
        if ($workingDir) { $psi.WorkingDirectory = $workingDir }

        $process = [System.Diagnostics.Process]::Start($psi)
        try {
            # Both streams are read asynchronously BEFORE waiting. A child that fills one
            # pipe while the parent blocks on the other deadlocks, and a fixture that hangs
            # is worse than one that fails.
            $outTask = $process.StandardOutput.ReadToEndAsync()
            $errTask = $process.StandardError.ReadToEndAsync()
            $process.WaitForExit()
            $rawOut = $outTask.GetAwaiter().GetResult()
            $rawErr = $errTask.GetAwaiter().GetResult()
            $exitCode = $process.ExitCode
        } finally {
            $process.Dispose()
        }

        $actual = ConvertTo-NormalisedOutput -Text ($rawOut + $rawErr) -RepoPath $repo
        $expectedExit = if ($command.PSObject.Properties.Name -contains 'exitCode') { [int]$command.exitCode } else { 0 }

        return [pscustomobject]@{
            Case         = Split-Path -Leaf $CaseDir
            CaseDir      = $CaseDir
            RepoPath     = $repo
            Script       = $command.script
            Expected     = $expected
            Actual       = $actual
            ExpectedExit = $expectedExit
            ActualExit   = $exitCode
            OutputMatch  = ($actual -eq $expected)
            ExitMatch    = ($exitCode -eq $expectedExit)
        }
    } finally {
        # Run-Tests.ps1 -KeepRepo reaches the case through the environment, because the Pester
        # test that calls this has no channel of its own to pass a switch down.
        $keep = $KeepRepo -or ($env:KIT_HARNESS_KEEP_REPO -eq '1')
        if ($keep) { Write-Host "harness: fixture repository kept at $repo" } else { Remove-FixtureRepo -Path $repo }
    }
}

function Format-CaseFailure {
    <#
    .SYNOPSIS
        FR-016: name the script, the rule, the case, both verdicts, and how to reproduce it.
    #>
    param([Parameter(Mandatory)]$Result, [string]$RuleId)

    # The verdict, named as a word rather than left to be read out of a diff. FR-016 asks for
    # the expected verdict and the observed one, and a reader handed 'first diff at line 7' has
    # been given the evidence and not the finding. The verdict is the LAST line matching
    # '<name>: <WORD>' - the kit's verdict-line shape, whose vocabulary scripts/ritual-checks.ps1
    # defines. Taking the last one is right here for the reason it is wrong in that wrapper: a
    # fixture's expectation is the whole of one run's output, not a stream being searched, so
    # its final verdict-shaped line IS that run's answer.
    $verdictOf = {
        param([string]$Text)
        $found = $null
        foreach ($line in ($Text -split "`n")) {
            if ($line -match '^[A-Za-z][A-Za-z0-9_.-]*: (OK|FAIL|WARN|UNGRADED|PENDING|n/a|N/A|PASS|ERROR|RESULT [A-Z]+)\b') {
                $found = $line.Trim()
            }
        }
        return $found
    }
    $expectedVerdict = & $verdictOf $Result.Expected
    $observedVerdict = & $verdictOf $Result.Actual

    $lines = @()
    $lines += "rule      : $RuleId"
    $lines += "script    : $($Result.Script)"
    $lines += "case      : $($Result.CaseDir)"
    if ($expectedVerdict -or $observedVerdict) {
        # '<none>' is a finding in itself: a run that printed no verdict-shaped line at all is
        # how doc-lint.ps1 exited 1 for four features without naming a verdict (phase 5, F2).
        $lines += "verdict   : expected $(if ($expectedVerdict) { "'$expectedVerdict'" } else { '<none>' })"
        $lines += "            observed $(if ($observedVerdict) { "'$observedVerdict'" } else { '<none>' })"
    }
    if (-not $Result.ExitMatch) {
        $lines += "exit code : expected $($Result.ExpectedExit), observed $($Result.ActualExit)"
    }
    if (-not $Result.OutputMatch) {
        $expectedLines = $Result.Expected -split "`n"
        $actualLines = $Result.Actual -split "`n"
        $max = [Math]::Max($expectedLines.Count, $actualLines.Count)
        for ($i = 0; $i -lt $max; $i++) {
            $e = if ($i -lt $expectedLines.Count) { $expectedLines[$i] } else { '<no line>' }
            $a = if ($i -lt $actualLines.Count) { $actualLines[$i] } else { '<no line>' }
            if ($e -ne $a) {
                $lines += "first diff at line $($i + 1):"
                $lines += "  expected: $e"
                $lines += "  observed: $a"
                break
            }
        }
    }
    $marker = [IO.Path]::DirectorySeparatorChar + 'cases' + [IO.Path]::DirectorySeparatorChar
    $index = $Result.CaseDir.IndexOf($marker)
    $filter = if ($index -ge 0) { $Result.CaseDir.Substring($index + $marker.Length).Replace('\', '/') } else { Split-Path -Leaf $Result.CaseDir }
    # FR-019: a failed case must be reproducible from the printed output alone. -KeepRepo
    # rebuilds the same fixture and leaves it on disk with its path printed, so the reader can
    # run the script against it by hand instead of reasoning about a diff.
    $lines += "reproduce : pwsh -File tests/enforcement/Run-Tests.ps1 -Case $filter -KeepRepo"
    $lines += "            (rebuilt from $($Result.CaseDir)/recipe.json; -KeepRepo prints the path it lands at)"
    return ($lines -join "`n")
}

function Get-RuleInventory {
    param([Parameter(Mandatory)][string]$TestsRoot)
    $path = Join-Path $TestsRoot 'rules.json'
    if (-not (Test-Path $path)) { throw "rule inventory not found at $path" }
    return (Get-Content $path -Raw | ConvertFrom-Json)
}

function Get-CaseDirectories {
    param([Parameter(Mandatory)][string]$TestsRoot)
    $casesRoot = Join-Path $TestsRoot 'cases'
    if (-not (Test-Path $casesRoot)) { return @() }
    return @(Get-ChildItem $casesRoot -Recurse -Filter 'command.json' -File | ForEach-Object { $_.DirectoryName })
}

Export-ModuleMember -Function Invoke-FixtureCase, Format-CaseFailure, ConvertTo-NormalisedOutput, Get-RuleInventory, Get-CaseDirectories
