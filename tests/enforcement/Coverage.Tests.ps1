<#
    Coverage: the inventory against the scripts, and the inventory against the cases.

    EVERYTHING HERE IS ASSERTED. Plan D9 held the coverage number to a printed report while
    fixtures arrived over phases 1-5, because asserting completeness earlier would have left
    the branch red from its first commit to its last, which is GAP-022's disease. T044 closes
    that window: as of phase 6 an emission site that no rule owns and no declaration excuses
    FAILS THE RUN.

    Three claims, and the third is the new one:

      HONEST     — a rule whose anchor no longer appears in its script is stale, and a rule
                   with only one fixture direction is a coverage claim the harness cannot keep.
                   An inventory that can lie is the thing D8 exists to prevent.
      COMPLETE   — every emission site the declaration finds belongs to an inventoried rule or
                   to a written 'notRules' entry. No silent remainder.
      SEEN       — every line the broad recall sweep finds is accounted for too, so a site
                   written in an idiom the declaration does not know cannot hide in the gap
                   between the two passes.

    THREE WAYS A SITE MAY BE ACCOUNTED FOR, and each is a stated position rather than an
    absence:

      a rule with both fixture directions     the ordinary case
      a rule with an 'exemption' (FR-004)     a faithful fixture cannot be built; the reason
                                              is written in rules.json and printed every run
      a 'notRules' entry in the idiom file    the line is not a distinct failure condition -
                                              a verdict roll-up, a per-issue renderer, a lane
                                              statement, a success line

    The third category exists so that blocking is achievable HONESTLY. Without it the only ways
    to make the number reach the total were to invent a rule per roll-up line, or to tighten the
    accumulator regex until the remainder vanished. Tightening the instrument until the number
    comes out right is the defect this feature has already hit three times, and it would have
    been indistinguishable from progress.

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

    function Split-Reason {
        # Wrap a written exemption reason for the report. Pure presentation: no reason is
        # shortened, only folded, because FR-004 is satisfied by the reader seeing all of it.
        param([Parameter(Mandatory)][string]$Text, [int]$Width = 96)
        $out = @(); $line = ''
        foreach ($word in ($Text -split '\s+' | Where-Object { $_ })) {
            if ($line.Length -gt 0 -and ($line.Length + 1 + $word.Length) -gt $Width) { $out += $line; $line = $word }
            else { $line = if ($line.Length -eq 0) { $word } else { "$line $word" } }
        }
        if ($line.Length -gt 0) { $out += $line }
        return $out
    }

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

    It 'every inventoried rule has a passing and a failing case, or a written exemption' {
        # FR-002, and FR-004's one way out. An exemption is not a TODO: it is a claim that a
        # faithful fixture cannot be built, it carries the reason in the inventory, and the
        # report below prints every one of them on every run. A bare 'exempt: true' would be
        # the inventory lying with fewer words, so the reason is required and is length-checked
        # - not to grade prose, but because an empty string would satisfy a presence test and
        # that is precisely the shape of exemption this rule exists to refuse.
        $incomplete = @()
        foreach ($rule in $script:Inventory.rules) {
            $exempt = $rule.PSObject.Properties.Name -contains 'exemption' -and $rule.exemption
            if ($exempt) {
                if ("$($rule.exemption)".Trim().Length -lt 60) {
                    $incomplete += "$($rule.id): exemption is present but says almost nothing - FR-004 requires a written reason, and a reader must be able to tell what would be needed instead"
                }
                continue
            }
            foreach ($direction in 'pass', 'fail') {
                $expected = Join-Path (Join-Path (Join-Path $script:TestsRoot 'cases') ($rule.script -replace '\.ps1$', '')) (Join-Path $rule.id $direction)
                if (-not (Test-Path (Join-Path $expected 'command.json'))) {
                    $incomplete += "$($rule.id): no '$direction' case at $expected (and no 'exemption' in rules.json)"
                }
            }
        }
        if ($incomplete.Count -gt 0) { throw ($incomplete -join "`n") }
        $incomplete.Count | Should -Be 0
    }

    It 'an exempted rule has no fixtures pretending otherwise' {
        # The mirror of the rule above, and the one a future edit is likelier to break: an
        # exemption written over a rule that DOES have cases would quietly stop those cases
        # being required, so the pair could then be deleted with nothing going red.
        $contradictory = @()
        foreach ($rule in $script:Inventory.rules) {
            if (-not ($rule.PSObject.Properties.Name -contains 'exemption' -and $rule.exemption)) { continue }
            foreach ($direction in 'pass', 'fail') {
                $dir = Join-Path (Join-Path (Join-Path $script:TestsRoot 'cases') ($rule.script -replace '\.ps1$', '')) (Join-Path $rule.id $direction)
                if (Test-Path (Join-Path $dir 'command.json')) {
                    $contradictory += "$($rule.id): exempted from coverage, yet a '$direction' case exists at $dir - delete the exemption or delete the case, but the inventory must not say both"
                }
            }
        }
        if ($contradictory.Count -gt 0) { throw ($contradictory -join "`n") }
        $contradictory.Count | Should -Be 0
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

Describe 'coverage' {

    BeforeAll {
        # One classification, three tests read it. Order matters and is the order a reader
        # would apply: a rule owns the site, or a written notRules entry excuses it, or
        # nothing does and the run fails.
        function Get-SiteOwner {
            param([Parameter(Mandatory)]$Site)
            $rule = $script:Inventory.rules | Where-Object {
                $_.script -eq $Site.Script -and $Site.Text.Contains($_.emitAnchor)
            } | Select-Object -First 1
            if ($rule) {
                $exempt = $rule.PSObject.Properties.Name -contains 'exemption' -and $rule.exemption
                return [pscustomobject]@{ Kind = ($exempt ? 'exempt' : 'covered'); Id = $rule.id }
            }
            $idiom = $script:Idioms.scripts | Where-Object { $_.script -eq $Site.Script } | Select-Object -First 1
            if ($idiom -and $idiom.PSObject.Properties.Name -contains 'notRules' -and $idiom.notRules) {
                $declared = @($idiom.notRules | Where-Object { $Site.Text.Contains($_.anchor) }) | Select-Object -First 1
                if ($declared) { return [pscustomobject]@{ Kind = 'not-a-rule'; Id = $declared.anchor } }
            }
            return [pscustomobject]@{ Kind = 'unowned'; Id = $null }
        }

        $script:Owned = @{}
        foreach ($site in $script:AllSites) {
            $script:Owned["$($site.Script):$($site.Line)"] = (Get-SiteOwner -Site $site)
        }
        $script:UnclassifiedOwned = @{}
        foreach ($scan in $script:Scan.Values) {
            foreach ($site in $scan.Unclassified) {
                $script:UnclassifiedOwned["$($site.Script):$($site.Line)"] = (Get-SiteOwner -Site $site)
            }
        }
    }

    It 'every declared emission site belongs to a rule or to a written not-a-rule entry' {
        # T044, FR-003. Until phase 6 this was a printed percentage; a site nobody owned was a
        # number going down, which reads as information rather than as a defect. It is now the
        # run's verdict. The failure names the line, because "coverage fell" is not actionable
        # and "enforcement-pack.ps1:1076 is owned by nothing" is.
        $unowned = @()
        foreach ($site in $script:AllSites) {
            $owner = $script:Owned["$($site.Script):$($site.Line)"]
            if ($owner.Kind -eq 'unowned') {
                $text = if ($site.Text.Length -gt 100) { $site.Text.Substring(0, 100) + '...' } else { $site.Text }
                $unowned += "$($site.Script):$($site.Line) is owned by nothing - add a rule to rules.json with a fixture pair, an 'exemption' with a written reason (FR-004), or a 'notRules' entry in emission-idioms.json saying why it is not a distinct failure condition`n    $text"
            }
        }
        if ($unowned.Count -gt 0) { throw (($unowned -join "`n") + "`n`n$($unowned.Count) unowned emission site(s).") }
        $unowned.Count | Should -Be 0
    }

    It 'every line the recall sweep finds is accounted for too' {
        # The gap between the two passes is where a site written in an unknown idiom hides: the
        # precise pass does not see it, so the test above cannot fail on it, and before phase 6
        # it was printed as an UNCLASSIFIED count that nobody had to act on. Same rule, applied
        # to the broad sweep - it may be a rule, or declared not to be one, but it may not be
        # merely noticed.
        $undeclared = @()
        foreach ($scan in $script:Scan.Values) {
            foreach ($site in $scan.Unclassified) {
                $owner = $script:UnclassifiedOwned["$($site.Script):$($site.Line)"]
                if ($owner.Kind -eq 'unowned') {
                    $text = if ($site.Text.Length -gt 100) { $site.Text.Substring(0, 100) + '...' } else { $site.Text }
                    $undeclared += "$($site.Script):$($site.Line) was found by the recall sweep and is declared nowhere - either the emission idiom for this script is missing it (add the pattern), or it is not a rule (add a 'notRules' entry)`n    $text"
                }
            }
        }
        if ($undeclared.Count -gt 0) { throw (($undeclared -join "`n") + "`n`n$($undeclared.Count) undeclared candidate line(s).") }
        $undeclared.Count | Should -Be 0
    }

    It 'every notRules entry has a written reason and excuses exactly the sites it declares' {
        # The not-a-rule channel is an exemption channel, and until the phase 6 review (F2) it
        # had none of the exemption channel's guards: an anchor could excuse any number of sites,
        # the reason could be empty, and the report printed only a count. A second lane decline
        # added under an existing anchor stayed green. So the same three guards apply here - a
        # reason a reader can act on, a declared 'siteCount' (default 1) the anchor must match
        # exactly, and (in the report below) every entry printed with its reason.
        $problems = @()
        foreach ($declared in $script:Idioms.scripts) {
            if (-not ($declared.PSObject.Properties.Name -contains 'notRules' -and $declared.notRules)) { continue }
            foreach ($entry in $declared.notRules) {
                $label = "$($declared.script) notRules '$($entry.anchor)'"
                if ("$($entry.reason)".Trim().Length -lt 60) {
                    $problems += "${label}: the reason is missing or says almost nothing - a line declared not to be a rule needs the same written reason an exemption does (FR-004)"
                }
                $expected = if ($entry.PSObject.Properties.Name -contains 'siteCount' -and $entry.siteCount) { [int]$entry.siteCount } else { 1 }
                $keys = @($script:Owned.Keys) + @($script:UnclassifiedOwned.Keys)
                $hits = @($keys | Where-Object {
                        $o = if ($script:Owned.ContainsKey($_)) { $script:Owned[$_] } else { $script:UnclassifiedOwned[$_] }
                        $_.StartsWith("$($declared.script):") -and $o.Kind -eq 'not-a-rule' -and $o.Id -eq $entry.anchor
                    } | Sort-Object -Unique)
                if ($hits.Count -ne $expected) {
                    $problems += "${label}: excuses $($hits.Count) site(s) [$($hits -join ', ')], declared $expected - a new line under an existing anchor is a new condition until someone says otherwise, and an anchor that excuses nothing is stale"
                }
            }
        }
        if ($problems.Count -gt 0) { throw ($problems -join "`n") }
        $problems.Count | Should -Be 0
    }

    It 'reports what is covered, what is exempt, and what is declared not to be a rule' {
        $byKind = { param($k) @($script:Owned.Values | Where-Object Kind -eq $k).Count }
        $covered = & $byKind 'covered'
        $exempt = & $byKind 'exempt'
        $notRule = & $byKind 'not-a-rule'

        Write-Host ''
        Write-Host ('coverage: {0} of {1} declared emission site(s) owned by a fixtured rule, {2} exempt, {3} declared not a rule, across {4} grading script(s)' -f `
                $covered, $script:AllSites.Count, $exempt, $notRule, @($script:Idioms.scripts).Count)

        foreach ($declared in ($script:Idioms.scripts | Sort-Object script)) {
            $scan = $script:Scan[$declared.script]
            if (-not $scan) { continue }
            $keys = @($scan.Precise | ForEach-Object { "$($_.Script):$($_.Line)" })
            $mine = @($keys | ForEach-Object { $script:Owned[$_] })
            $c = @($mine | Where-Object Kind -eq 'covered').Count
            $e = @($mine | Where-Object Kind -eq 'exempt').Count
            $n = @($mine | Where-Object Kind -eq 'not-a-rule').Count
            if (@($declared.accumulators).Count -eq 0) {
                Write-Host ('coverage: {0,-24} IDIOM UNDECLARED' -f $declared.script)
                continue
            }
            $extra = @()
            if ($e -gt 0) { $extra += "$e exempt" }
            if ($n -gt 0) { $extra += "$n not a rule" }
            $suffix = if ($extra.Count -gt 0) { ' (' + ($extra -join ', ') + ')' } else { '' }
            Write-Host ('coverage: {0,-24} {1} of {2} site(s) fixtured{3}' -f $declared.script, $c, $scan.Precise.Count, $suffix)
        }

        # FR-004: every exemption appears in the output. Printed in full, not counted - the
        # point of a written reason is that someone reads it, and a reason nobody ever sees
        # again is the same as no reason.
        $exemptions = @($script:Inventory.rules | Where-Object {
                $_.PSObject.Properties.Name -contains 'exemption' -and $_.exemption } | Sort-Object id)
        Write-Host ''
        Write-Host ('coverage: {0} rule(s) exempt from a fixture pair (FR-004), each with its reason:' -f $exemptions.Count)
        # Grouped by reason, not listed per rule. Four of the seven share one cause, and
        # printing that paragraph four times trains the reader to skip it - which defeats the
        # requirement that the reason be seen.
        foreach ($group in ($exemptions | Group-Object exemption | Sort-Object { $_.Group[0].id })) {
            foreach ($rule in $group.Group) {
                Write-Host ('coverage:   {0} [{1}] {2}' -f $rule.id, $rule.script, $rule.summary)
            }
            foreach ($line in (Split-Reason -Text "$($group.Name)" -Width 96)) {
                Write-Host ('coverage:       ' + $line)
            }
            Write-Host 'coverage:'
        }

        # The not-a-rule declarations, printed the same way and for the same reason: a line the
        # inventory says is not a rule is a claim, and a claim nobody sees is not reviewed.
        $declaredNot = @(foreach ($declared in ($script:Idioms.scripts | Sort-Object script)) {
                if ($declared.PSObject.Properties.Name -contains 'notRules' -and $declared.notRules) {
                    foreach ($entry in $declared.notRules) { [pscustomobject]@{ Script = $declared.script; Entry = $entry } }
                }
            })
        Write-Host ('coverage: {0} line(s) declared not a rule, each with its reason:' -f $declaredNot.Count)
        foreach ($item in $declaredNot) {
            Write-Host ('coverage:   [{0}] {1}' -f $item.Script, $item.Entry.anchor)
            foreach ($line in (Split-Reason -Text "$($item.Entry.reason)" -Width 96)) {
                Write-Host ('coverage:       ' + $line)
            }
        }
        Write-Host 'coverage:'

        # Asserted here: the scan ran and found something to measure. A scanner that silently
        # matched nothing would report 0 of 0 and read as clean - the exact shape of GAP-027,
        # and the reason this assertion outlived the reporting-only window it was written in.
        $script:AllSites.Count | Should -BeGreaterThan 0
    }
}
