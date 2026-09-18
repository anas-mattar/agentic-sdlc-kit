<#
    Coverage: the inventory against the scripts, and the inventory against the cases.

    Two different claims live here, and plan D9 separates them deliberately:

      REPORTED (not asserted, until phase 6) — how much of the kit is covered. With ~120
      failure-emission sites and fixtures arriving over three phases, asserting completeness
      now would leave this branch red from phase 1 to phase 5, which is GAP-022's disease.
      T044 flips it.

      ASSERTED (today) — whether the inventory is honest about what it does claim. A rule whose
      anchor no longer appears in its script is stale, and a rule with only one direction is a
      coverage claim the harness cannot keep. Neither of those is "not yet covered"; both are
      the inventory lying, and an inventory that can lie is the thing D8 exists to prevent.
#>

BeforeAll {
    Import-Module (Join-Path $PSScriptRoot 'lib/Harness.psm1') -Force
    $script:TestsRoot = $PSScriptRoot
    $script:KitRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $script:ScriptsDir = Join-Path $script:KitRoot 'scripts'
    $script:Inventory = Get-RuleInventory -TestsRoot $PSScriptRoot

    # Failure-emission sites, found by their idiom rather than by parsing PowerShell. Each
    # grading script has its own; all of them put the message in a double-quoted literal on
    # the emitting line. A site this misses is a site the inventory can never be measured
    # against, so the patterns are listed here in the open rather than hidden in a helper.
    $script:EmissionPatterns = @(
        '\$script:failures\s*\+=\s*"(?<msg>.*)"',
        '\$failures\s*\+=\s*"(?<msg>.*)"',
        '\$problems\s*\+=\s*"(?<msg>.*)"',
        '\$manifestErrors\s*\+=\s*"(?<msg>.*)"',
        'Add-Finding\s+FAIL\s+''[^'']+''\s+"(?<msg>.*)"',
        'Write-Host\s+"(?<msg>[^"]*FAIL[^"]*)"'
    )

    function Get-EmissionSites {
        param([string]$ScriptPath)
        $sites = @()
        $lineNumber = 0
        foreach ($line in [IO.File]::ReadAllLines($ScriptPath)) {
            $lineNumber++
            $trimmed = $line.TrimStart()
            if ($trimmed.StartsWith('#')) { continue }
            foreach ($pattern in $script:EmissionPatterns) {
                $m = [regex]::Match($line, $pattern)
                if ($m.Success) {
                    $sites += [pscustomobject]@{
                        Script  = Split-Path -Leaf $ScriptPath
                        Line    = $lineNumber
                        Message = $m.Groups['msg'].Value
                    }
                    break
                }
            }
        }
        return $sites
    }

    $script:GradingScripts = @(
        'enforcement-pack.ps1', 'scope-check.ps1', 'scope-check-repos.ps1', 'doc-lint.ps1',
        'verify-kit.ps1', 'build-digests.ps1', 'roadmap-claim-check.ps1', 'territory-check.ps1',
        'ritual-checks.ps1'
    )

    $script:AllSites = @()
    foreach ($name in $script:GradingScripts) {
        $path = Join-Path $script:ScriptsDir $name
        if (Test-Path $path) { $script:AllSites += Get-EmissionSites -ScriptPath $path }
    }

    $script:CaseDirs = @(Get-CaseDirectories -TestsRoot $PSScriptRoot)
}

Describe 'rule inventory integrity' {

    It 'every inventoried rule still exists in the script it names' {
        $stale = @()
        foreach ($rule in $script:Inventory.rules) {
            $path = Join-Path $script:ScriptsDir $rule.script
            if (-not (Test-Path $path)) { $stale += "$($rule.id): script $($rule.script) not found"; continue }
            $text = [IO.File]::ReadAllText($path)
            if (-not $text.Contains($rule.emitAnchor)) {
                $stale += "$($rule.id): emitAnchor no longer found in $($rule.script) — the rule was reworded or removed, and this entry now measures nothing"
            }
        }
        if ($stale.Count -gt 0) { throw ($stale -join "`n") }
        $stale.Count | Should -Be 0
    }

    It 'every inventoried rule has a passing and a failing case' {
        $incomplete = @()
        foreach ($rule in $script:Inventory.rules) {
            foreach ($direction in 'pass', 'fail') {
                $expected = Join-Path (Join-Path (Join-Path $script:TestsRoot 'cases') ($rule.script -replace '\.ps1$', '')) (Join-Path $rule.id $direction)
                if (-not (Test-Path (Join-Path $expected 'command.json'))) {
                    $incomplete += "$($rule.id): no '$direction' case at $expected"
                }
            }
        }
        if ($incomplete.Count -gt 0) { throw ($incomplete -join "`n") }
        $incomplete.Count | Should -Be 0
    }

    It 'every case directory belongs to an inventoried rule' {
        $orphans = @()
        foreach ($dir in $script:CaseDirs) {
            $ruleId = Split-Path -Leaf (Split-Path -Parent $dir)
            if (-not ($script:Inventory.rules | Where-Object { $_.id -eq $ruleId })) {
                $orphans += "$dir names rule '$ruleId', which is not in rules.json"
            }
        }
        if ($orphans.Count -gt 0) { throw ($orphans -join "`n") }
        $orphans.Count | Should -Be 0
    }
}

Describe 'coverage report' {

    It 'reports how much of the kit is under test' {
        $covered = @()
        $uncovered = @()
        foreach ($site in $script:AllSites) {
            $match = $script:Inventory.rules | Where-Object {
                $_.script -eq $site.Script -and $site.Message.Contains($_.emitAnchor)
            }
            if ($match) { $covered += $site } else { $uncovered += $site }
        }

        Write-Host ''
        Write-Host ('coverage: {0} of {1} failure-emission site(s) inventoried across {2} grading script(s)' -f `
                $covered.Count, $script:AllSites.Count, $script:GradingScripts.Count)

        # Every script is listed, including the ones the scanner found nothing in. A script
        # silently absent from this report would be a denominator that shrank to fit — which is
        # the shape of the defect this whole feature exists to close, committed by the tool
        # built to close it.
        $blind = @()
        foreach ($name in ($script:GradingScripts | Sort-Object)) {
            $sites = @($script:AllSites | Where-Object Script -eq $name)
            $done = @($covered | Where-Object Script -eq $name)
            if ($sites.Count -eq 0) {
                Write-Host ('coverage: {0,-24} NO EMISSION SITE FOUND — the scanner misses this script''s idiom, or it reports no failures' -f $name)
                $blind += $name
            } else {
                Write-Host ('coverage: {0,-24} {1} of {2} site(s) inventoried' -f $name, $done.Count, $sites.Count)
            }
        }
        if ($blind.Count -gt 0) {
            Write-Host ("coverage: {0} script(s) the scanner is blind to — resolve each while inventorying it (phases 3-4): {1}" -f $blind.Count, ($blind -join ', '))
        }
        Write-Host 'coverage: reporting only until phase 6 (plan D9) — T044 makes an uncovered site a failure.'

        # Asserted here: the report ran and found something to measure. A scanner that silently
        # matched nothing would report 0 of 0 and read as clean — the exact shape of GAP-027.
        $script:AllSites.Count | Should -BeGreaterThan 0
    }
}
