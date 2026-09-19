<#
.SYNOPSIS
    Runs the enforcement-assurance harness. The one documented local command (FR-018).

.DESCRIPTION
    Feature 015. Builds a real temporary git repository per fixture case, runs the kit script
    the case names, and compares the output to the case's hand-written expectation.

    No network at run time. Nothing is written to the repository this is run from (FR-020).

.PARAMETER Case
    Run only cases whose path contains this text — a rule id (STRUCT-001), a direction, or any
    fragment of the case path.

.PARAMETER KeepRepo
    Leave each fixture repository on disk and print its path, for inspecting a failure (FR-019).

.EXAMPLE
    pwsh -File tests/enforcement/Run-Tests.ps1
    pwsh -File tests/enforcement/Run-Tests.ps1 -Case STRUCT-001 -KeepRepo
#>

[CmdletBinding()]
param(
    [string]$Case,
    [switch]$KeepRepo,
    [switch]$CI
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# Pester 5 explicitly. A bare Import-Module finds the Pester 3.4.0 that ships inside Windows
# PowerShell on this development machine, whose Describe/It mean something different — a
# harness that silently ran under it would report green having asserted nothing (plan D2).
$RequiredPesterMajor = 5
$pester = Get-Module -ListAvailable Pester |
    Where-Object { $_.Version.Major -ge $RequiredPesterMajor } |
    Sort-Object Version -Descending |
    Select-Object -First 1

if (-not $pester) {
    Write-Host "enforcement-tests: Pester $RequiredPesterMajor or newer is required and was not found."
    Write-Host "enforcement-tests: install it with  Install-Module Pester -RequiredVersion 5.7.1 -Scope CurrentUser"
    Write-Host "enforcement-tests: (feature 015 plan D2 — this is the feature's one approved dependency)"
    exit 2
}
Import-Module $pester.Path -Force

$testsRoot = $PSScriptRoot
$configuration = New-PesterConfiguration
$configuration.Run.Path = $testsRoot
$configuration.Output.Verbosity = 'Detailed'
$configuration.Run.PassThru = $true

# The case filter reaches discovery through the environment (see Cases.Tests.ps1): Pester's
# own FullName filter matches the unexpanded Describe template and selects nothing.
$env:KIT_HARNESS_CASE_FILTER = $Case

# A filter that matches no case is checked HERE, before Pester runs, because the coverage
# tests always run and would carry the run to a green verdict on their own — so "-Case typo"
# would report OK having asserted nothing about any rule. Found in phase 1 by the mutation
# proof, which is exactly what a mutation proof is for (notes.md).
if ($Case) {
    $casesRoot = Join-Path $testsRoot 'cases'
    $needle = $Case.Replace('\', '/')
    $matched = @()
    if (Test-Path $casesRoot) {
        $matched = @(Get-ChildItem $casesRoot -Recurse -Filter 'command.json' -File |
                Where-Object { $_.DirectoryName.Replace('\', '/') -like "*$needle*" })
    }
    if ($matched.Count -eq 0) {
        Write-Host "enforcement-tests: FAIL — '-Case $Case' matches no case under tests/enforcement/cases."
        Write-Host 'enforcement-tests: nothing was asserted about any rule. Run without -Case, or name an existing case.'
        exit 1
    }
    Write-Host "enforcement-tests: -Case $Case selects $($matched.Count) case(s)"
}

if ($KeepRepo) { $env:KIT_HARNESS_KEEP_REPO = '1' } else { $env:KIT_HARNESS_KEEP_REPO = '' }

Write-Host "enforcement-tests: Pester $($pester.Version), pwsh $($PSVersionTable.PSVersion), $([System.Runtime.InteropServices.RuntimeInformation]::OSDescription.Trim())"

$result = Invoke-Pester -Configuration $configuration

Write-Host ''
Write-Host ("enforcement-tests: {0} passed, {1} failed, {2} skipped" -f $result.PassedCount, $result.FailedCount, $result.SkippedCount)

# A run that asserted nothing is not a run that passed. The first version of this script
# reported OK after a filter selected zero tests - the same shape as GAP-027, committed by the
# harness built to close it. Zero executed tests is a failure, and it names why.
if (($result.PassedCount + $result.FailedCount) -eq 0) {
    if ($Case) {
        Write-Host "enforcement-tests: FAIL - the filter '-Case $Case' matched no case. Nothing was asserted."
    } else {
        Write-Host 'enforcement-tests: FAIL - no tests ran. Nothing was asserted.'
    }
    exit 1
}

if ($result.FailedCount -gt 0) {
    Write-Host 'enforcement-tests: FAIL'
    exit 1
}
Write-Host 'enforcement-tests: OK'
exit 0
