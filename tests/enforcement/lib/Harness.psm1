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

        $arguments = @('-NoProfile', '-NonInteractive', '-File', $scriptPath, '-Root', $repo)
        if ($command.PSObject.Properties.Name -contains 'args' -and $command.args) {
            $arguments += @($command.args)
        }

        $stdoutFile = [IO.Path]::GetTempFileName()
        $stderrFile = [IO.Path]::GetTempFileName()
        try {
            $process = Start-Process -FilePath (Get-Process -Id $PID).Path -ArgumentList $arguments `
                -NoNewWindow -Wait -PassThru -RedirectStandardOutput $stdoutFile -RedirectStandardError $stderrFile
            $rawOut = [IO.File]::ReadAllText($stdoutFile)
            $rawErr = [IO.File]::ReadAllText($stderrFile)
            $exitCode = $process.ExitCode
        } finally {
            Remove-Item $stdoutFile, $stderrFile -Force -ErrorAction SilentlyContinue
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

    $lines = @()
    $lines += "rule      : $RuleId"
    $lines += "script    : $($Result.Script)"
    $lines += "case      : $($Result.CaseDir)"
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
    $lines += "reproduce : pwsh -File tests/enforcement/Run-Tests.ps1 -Case $filter -KeepRepo"
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
