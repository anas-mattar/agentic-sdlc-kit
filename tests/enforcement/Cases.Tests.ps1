<#
    Runs every fixture case under cases/ and compares the script's output to the case's
    hand-written expectation.

    One Pester test per case directory. The case name carries the rule id and the direction,
    so a failure names the rule without the reader opening anything (FR-016).
#>

BeforeDiscovery {
    $script:TestsRoot = $PSScriptRoot
    Import-Module (Join-Path $PSScriptRoot 'lib/Harness.psm1') -Force
    # The -Case filter narrows discovery here rather than through Pester's FullName filter:
    # these Describe names are templated, so a name filter matches the unexpanded template and
    # silently selects nothing — which is how the first version of this harness reported OK
    # having run no tests at all (phase 1, notes.md).
    $script:CaseFilter = $env:KIT_HARNESS_CASE_FILTER
    $script:AllCases = @(Get-CaseDirectories -TestsRoot $PSScriptRoot |
        Where-Object { -not $script:CaseFilter -or ($_.Replace('\', '/') -like "*$($script:CaseFilter.Replace('\', '/'))*") } |
        ForEach-Object {
            $relative = [IO.Path]::GetRelativePath((Join-Path $PSScriptRoot 'cases'), $_) -replace '\\', '/'
            $parts = $relative -split '/'
            [pscustomobject]@{
                Dir       = $_
                Relative  = $relative
                RuleId    = if ($parts.Count -ge 3) { $parts[$parts.Count - 2] } else { $relative }
                Direction = $parts[$parts.Count - 1]
            }
        })
}

Describe 'fixture case <_.Relative>' -ForEach $script:AllCases {

    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot 'lib/Harness.psm1') -Force
        $kitRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
        $script:Result = Invoke-FixtureCase -CaseDir $_.Dir -KitRoot $kitRoot
        $script:RuleId = $_.RuleId
    }

    It 'exits with the expected code' {
        if (-not $script:Result.ExitMatch) {
            throw (Format-CaseFailure -Result $script:Result -RuleId $script:RuleId)
        }
        $script:Result.ExitMatch | Should -BeTrue
    }

    It 'prints the expected output' {
        if (-not $script:Result.OutputMatch) {
            throw (Format-CaseFailure -Result $script:Result -RuleId $script:RuleId)
        }
        $script:Result.OutputMatch | Should -BeTrue
    }
}
