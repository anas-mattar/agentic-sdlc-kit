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

    HOW SITES ARE FOUND, and why it is two passes. The first version of this file hard-coded six
    regexes modelled on enforcement-pack.ps1 and applied them to all nine scripts. They
    undercounted three of them silently — the phase 1 review's F1. Partial blindness is worse
    than total blindness, because a half-seen script reports a plausible number instead of a
    visible zero. So:

      PRECISE  — emission-idioms.json declares, per script, how that script actually emits.
      RECALL   — a deliberately broad sweep looks for anything that smells like a failure.

    Sites the sweep finds and the declaration does not are printed as UNCLASSIFIED. That
    difference is the honest measure of what the declaration may still be missing, and it is the
    number to watch rather than the coverage percentage.
#>

BeforeAll {
    Import-Module (Join-Path $PSScriptRoot 'lib/Harness.psm1') -Force
    $script:TestsRoot = $PSScriptRoot
    $script:KitRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $script:ScriptsDir = Join-Path $script:KitRoot 'scripts'
    $script:Inventory = Get-RuleInventory -TestsRoot $PSScriptRoot
    $script:Idioms = Get-Content (Join-Path $PSScriptRoot 'emission-idioms.json') -Raw | ConvertFrom-Json

    # The recall pass. Broad on purpose: it is allowed — expected — to hit lines that are not
    # rules. Its job is not to be right, it is to be impossible to slip past, so that a genuine
    # emission site written in a new idiom shows up as UNCLASSIFIED rather than as nothing.
    $script:CandidateSweep = @(
        '\+=\s*.*(?i:fail|issue|error|problem|broken|missing|stale|invalid)',
        '\$(?i:[a-z:]*)(failures|issues|errors|problems|broken|findings)\s*\+=',
        'Add-Finding\s+FAIL',
        # Any Write-*, not Write-Host alone: scope-check-repos.ps1 emits through a Write-Line
        # wrapper, and a sweep that named only Write-Host reported zero candidates for it —
        # the recall pass reproducing the precise pass's blindness, which defeats its purpose.
        'Write-\w+\s+["''][^"'']*(FAIL|ERROR)',
        'Write-Error\s'
    )

    function Test-LineMatches {
        param([string]$Line, [string[]]$Patterns)
        foreach ($p in $Patterns) { if ([regex]::IsMatch($Line, $p)) { return $true } }
        return $false
    }

    function Get-ScriptSites {
        param([string]$ScriptPath, [string[]]$Accumulators)
        $precise = @()
        $candidates = @()
        $lineNumber = 0
        foreach ($line in [IO.File]::ReadAllLines($ScriptPath)) {
            $lineNumber++
            if ($line.TrimStart().StartsWith('#')) { continue }
            $entry = [pscustomobject]@{
                Script = Split-Path -Leaf $ScriptPath
                Line   = $lineNumber
                Text   = $line.Trim()
            }
            if ($Accumulators.Count -gt 0 -and (Test-LineMatches -Line $line -Patterns $Accumulators)) {
                $precise += $entry
            } elseif (Test-LineMatches -Line $line -Patterns $script:CandidateSweep) {
                $candidates += $entry
            }
        }
        return [pscustomobject]@{ Precise = $precise; Unclassified = $candidates }
    }

    $script:Scan = @{}
    foreach ($declared in $script:Idioms.scripts) {
        $path = Join-Path $script:ScriptsDir $declared.script
        if (Test-Path $path) {
            $script:Scan[$declared.script] = Get-ScriptSites -ScriptPath $path -Accumulators @($declared.accumulators)
        }
    }
    $script:AllSites = @($script:Scan.Values | ForEach-Object { $_.Precise })
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

    It 'every anchor names exactly the emission sites its rule declares' {
        # T023 found two anchors written in T021 that also matched ReviewProvenance lines they
        # have nothing to do with. Nothing was red: the coverage number simply counted those two
        # sites as covered by Critical-evidence fixtures that never reach them. An anchor that
        # matches a site its rule does not test is the inventory lying in the one direction D8
        # exists to prevent — upward — so ambiguity is now a failure rather than a rounding error.
        #
        # A rule MAY own more than one site (SCOPE-001's Micro and Standard arms print the same
        # sentence), but only by saying so in 'siteCount'. Declared, never inferred.
        $ambiguous = @()
        foreach ($rule in $script:Inventory.rules) {
            $idiom = $script:Idioms.scripts | Where-Object { $_.script -eq $rule.script }
            if (-not $idiom -or @($idiom.accumulators).Count -eq 0) { continue }   # idiom undeclared — T030..T034
            $scan = $script:Scan[$rule.script]
            if (-not $scan) { continue }
            $expected = if ($rule.PSObject.Properties.Name -contains 'siteCount' -and $rule.siteCount) { [int]$rule.siteCount } else { 1 }
            $hits = @($scan.Precise | Where-Object { $_.Text.Contains($rule.emitAnchor) })
            if ($hits.Count -ne $expected) {
                $where = ($hits | ForEach-Object { "$($_.Script):$($_.Line)" }) -join ', '
                $ambiguous += "$($rule.id): anchor matches $($hits.Count) emission site(s) [$where], declared $expected"
            }
        }
        if ($ambiguous.Count -gt 0) { throw ($ambiguous -join "`n") }
        $ambiguous.Count | Should -Be 0
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

Describe 'emission-idiom declaration' {

    It 'declares an idiom entry for every grading script' {
        $missing = @()
        foreach ($name in $script:Idioms.scripts.script) {
            if (-not (Test-Path (Join-Path $script:ScriptsDir $name))) { $missing += "$name is declared but does not exist" }
        }
        $declaredNames = @($script:Idioms.scripts.script)
        foreach ($name in @('enforcement-pack.ps1', 'scope-check.ps1', 'scope-check-repos.ps1', 'doc-lint.ps1',
                'verify-kit.ps1', 'build-digests.ps1', 'roadmap-claim-check.ps1', 'territory-check.ps1',
                'ritual-checks.ps1')) {
            if ($name -notin $declaredNames) { $missing += "$name has no entry in emission-idioms.json" }
        }
        if ($missing.Count -gt 0) { throw ($missing -join "`n") }
        $missing.Count | Should -Be 0
    }

    It 'every undeclared script says so in writing' {
        # An empty accumulator list is legal, but only as a stated position with a reason and the
        # task that resolves it — never as an omission nobody noticed.
        $silent = @()
        foreach ($declared in $script:Idioms.scripts) {
            if (@($declared.accumulators).Count -eq 0 -and $declared.note -notmatch 'UNDECLARED') {
                $silent += "$($declared.script): no accumulators declared and the note does not say UNDECLARED with a reason"
            }
        }
        if ($silent.Count -gt 0) { throw ($silent -join "`n") }
        $silent.Count | Should -Be 0
    }
}

Describe 'coverage report' {

    It 'reports how much of the kit is under test, and how much it may not be seeing' {
        $covered = @()
        foreach ($site in $script:AllSites) {
            $match = $script:Inventory.rules | Where-Object {
                $_.script -eq $site.Script -and $site.Text.Contains($_.emitAnchor)
            }
            if ($match) { $covered += $site }
        }

        $unclassifiedTotal = 0
        Write-Host ''
        Write-Host ('coverage: {0} of {1} declared failure-emission site(s) inventoried across {2} grading script(s)' -f `
                $covered.Count, $script:AllSites.Count, @($script:Idioms.scripts).Count)

        foreach ($declared in ($script:Idioms.scripts | Sort-Object script)) {
            $scan = $script:Scan[$declared.script]
            if (-not $scan) { continue }
            $done = @($covered | Where-Object Script -eq $declared.script).Count
            $unclassifiedTotal += $scan.Unclassified.Count
            if (@($declared.accumulators).Count -eq 0) {
                Write-Host ('coverage: {0,-24} IDIOM UNDECLARED — {1} unclassified candidate line(s)' -f $declared.script, $scan.Unclassified.Count)
            } else {
                $suffix = if ($scan.Unclassified.Count -gt 0) { ", {0} unclassified candidate(s)" -f $scan.Unclassified.Count } else { '' }
                Write-Host ('coverage: {0,-24} {1} of {2} site(s) inventoried{3}' -f $declared.script, $done, $scan.Precise.Count, $suffix)
            }
        }

        Write-Host ("coverage: {0} unclassified candidate line(s) in total — each is either a rule the declaration misses or a false positive of the recall sweep, and phases 3-4 resolve every one." -f $unclassifiedTotal)
        Write-Host 'coverage: reporting only until phase 6 (plan D9) — T044 makes an uncovered site a failure.'

        # Asserted here: the scan ran and found something to measure. A scanner that silently
        # matched nothing would report 0 of 0 and read as clean — the exact shape of GAP-027.
        $script:AllSites.Count | Should -BeGreaterThan 0
    }
}
