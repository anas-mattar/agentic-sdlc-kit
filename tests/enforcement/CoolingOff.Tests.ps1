<#
    scripts/adoption-lib.ps1's cooling-off reader, tested directly (feature 038, plan P2 to P4).

    Get-CoolingOff is the one place that reads coolingOffHours and coolingOffReason from kit-adoption.json: the
    enforcement pack reads the period it returns, and the doctor reads the problems it returns. The fixtures prove what
    those two scripts print; these tests pin the function they rest on, one row per shape the record can hold, each
    written as raw JSON text because the shapes that matter (4.0, a bare null, a number no double can hold) are exactly
    the ones a PowerShell literal would quietly normalise.

    The direction of every unusable row is the same: 24. A declared period may only ever be honored when it is a whole
    number of at least 1 and, below 24, carries a reason.
#>

BeforeDiscovery {
    # Json: the whole record, as written. Hours / Declared / Honored: what the reader must return.
    # Problems: the severities the doctor would see, in order ('fail' or 'warn').
    $script:Rows = @(
        # --- nothing declared ----------------------------------------------------------------------------------------
        @{ Name = 'no key at all';                      Json = '{}';                                                          Hours = 24;  Declared = $false; Honored = $true;  Problems = @() }
        @{ Name = 'other keys only';                    Json = '{"developers":["ada"]}';                                      Hours = 24;  Declared = $false; Honored = $true;  Problems = @() }

        # --- accepted, at or above the default ----------------------------------------------------------------------
        @{ Name = '24';                                 Json = '{"coolingOffHours":24}';                                      Hours = 24;  Declared = $true;  Honored = $true;  Problems = @() }
        @{ Name = '48, no reason needed';               Json = '{"coolingOffHours":48}';                                      Hours = 48;  Declared = $true;  Honored = $true;  Problems = @() }
        @{ Name = '24.0';                               Json = '{"coolingOffHours":24.0}';                                    Hours = 24;  Declared = $true;  Honored = $true;  Problems = @() }
        @{ Name = '24 with a reason that justifies nothing'; Json = '{"coolingOffHours":24,"coolingOffReason":"why"}';        Hours = 24;  Declared = $true;  Honored = $true;  Problems = @('warn') }
        @{ Name = '48 with a reason that justifies nothing'; Json = '{"coolingOffHours":48,"coolingOffReason":"why"}';        Hours = 48;  Declared = $true;  Honored = $true;  Problems = @('warn') }

        # --- accepted, below the default, with a usable reason -------------------------------------------------------
        @{ Name = '1 (the floor) with a reason';        Json = '{"coolingOffHours":1,"coolingOffReason":"why"}';              Hours = 1;   Declared = $true;  Honored = $true;  Problems = @() }
        @{ Name = '2 with a reason';                    Json = '{"coolingOffHours":2,"coolingOffReason":"why"}';              Hours = 2;   Declared = $true;  Honored = $true;  Problems = @() }
        @{ Name = '4 with a reason';                    Json = '{"coolingOffHours":4,"coolingOffReason":"why"}';              Hours = 4;   Declared = $true;  Honored = $true;  Problems = @() }
        @{ Name = '8 with a reason';                    Json = '{"coolingOffHours":8,"coolingOffReason":"why"}';              Hours = 8;   Declared = $true;  Honored = $true;  Problems = @() }
        @{ Name = '23 with a reason';                   Json = '{"coolingOffHours":23,"coolingOffReason":"why"}';             Hours = 23;  Declared = $true;  Honored = $true;  Problems = @() }
        @{ Name = '4.0 with a reason (a whole number written with a point)'; Json = '{"coolingOffHours":4.0,"coolingOffReason":"why"}'; Hours = 4; Declared = $true; Honored = $true; Problems = @() }
        @{ Name = '4e0 with a reason';                  Json = '{"coolingOffHours":4e0,"coolingOffReason":"why"}';            Hours = 4;   Declared = $true;  Honored = $true;  Problems = @() }

        # --- below the default without a usable reason: the value is set aside -------------------------------------
        @{ Name = '4, reason absent';                   Json = '{"coolingOffHours":4}';                                       Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = '2, reason empty';                    Json = '{"coolingOffHours":2,"coolingOffReason":""}';                 Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = '2, reason whitespace only';          Json = '{"coolingOffHours":2,"coolingOffReason":"   \t "}';           Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = '23, reason a number';                Json = '{"coolingOffHours":23,"coolingOffReason":5}';                 Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = '23, reason null';                    Json = '{"coolingOffHours":23,"coolingOffReason":null}';              Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = '8, reason an array';                 Json = '{"coolingOffHours":8,"coolingOffReason":["why"]}';            Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = '8, reason an object';                Json = '{"coolingOffHours":8,"coolingOffReason":{"a":"b"}}';          Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }

        # --- not accepted: every one is 24 ---------------------------------------------------------------------------
        @{ Name = '0';                                  Json = '{"coolingOffHours":0,"coolingOffReason":"why"}';              Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = '-0';                                 Json = '{"coolingOffHours":-0,"coolingOffReason":"why"}';             Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = '-3';                                 Json = '{"coolingOffHours":-3,"coolingOffReason":"why"}';             Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = '1.5';                                Json = '{"coolingOffHours":1.5,"coolingOffReason":"why"}';            Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = '0.5 (below the floor and fractional)'; Json = '{"coolingOffHours":0.5,"coolingOffReason":"why"}';          Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = '24.5 (fractional above the default)'; Json = '{"coolingOffHours":24.5}';                                   Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = 'a string holding a number';         Json = '{"coolingOffHours":"8","coolingOffReason":"why"}';            Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = 'a string of words';                  Json = '{"coolingOffHours":"eight","coolingOffReason":"why"}';        Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = 'true';                               Json = '{"coolingOffHours":true,"coolingOffReason":"why"}';           Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = 'false';                              Json = '{"coolingOffHours":false,"coolingOffReason":"why"}';          Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = 'an explicit null';                   Json = '{"coolingOffHours":null,"coolingOffReason":"why"}';           Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = 'an empty array';                     Json = '{"coolingOffHours":[],"coolingOffReason":"why"}';             Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = 'an array holding a valid number';    Json = '{"coolingOffHours":[8],"coolingOffReason":"why"}';            Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = 'an object';                          Json = '{"coolingOffHours":{},"coolingOffReason":"why"}';             Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = 'a number no double can hold';        Json = '{"coolingOffHours":1e999,"coolingOffReason":"why"}';          Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }

        # --- a reason that only looks like one (phase 1 review, F1): invisible or terminal-steering characters -----------
        @{ Name = '2, reason of zero-width spaces only'; Json = '{"coolingOffHours":2,"coolingOffReason":"​​"}';   Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = '2, reason a lone BOM';               Json = '{"coolingOffHours":2,"coolingOffReason":"﻿"}';           Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = '2, reason a lone NUL';               Json = '{"coolingOffHours":2,"coolingOffReason":"\u0000"}';           Hours = 24;  Declared = $true;  Honored = $false; Problems = @('fail') }
        @{ Name = '2, reason control characters only';  Json = '{"coolingOffHours":2,"coolingOffReason":"\u001b\u000b\u000c\u0085"}'; Hours = 24; Declared = $true; Honored = $false; Problems = @('fail') }
        @{ Name = '2, reason of line and paragraph separators only'; Json = '{"coolingOffHours":2,"coolingOffReason":"  "}'; Hours = 24; Declared = $true; Honored = $false; Problems = @('fail') }
        @{ Name = '2, reason carrying an ANSI escape sequence (read as a space, so it cannot erase a line)'; Json = '{"coolingOffHours":2,"coolingOffReason":"ok\u001b[2K\u001b[1Ahidden"}'; Hours = 2; Declared = $true; Honored = $true; Problems = @(); Reason = 'ok [2K [1Ahidden' }
        @{ Name = '2, reason with a line separator and a NEL (one line)'; Json = '{"coolingOffHours":2,"coolingOffReason":"a b\u0085c"}'; Hours = 2; Declared = $true; Honored = $true; Problems = @(); Reason = 'a b c' }
        @{ Name = '2, reason with a zero-width joiner inside a word (kept whole)'; Json = '{"coolingOffHours":2,"coolingOffReason":"ab‍cd"}'; Hours = 2; Declared = $true; Honored = $true; Problems = @(); Reason = 'abcd' }
        @{ Name = '2, reason with runs of spaces and tabs'; Json = '{"coolingOffHours":2,"coolingOffReason":" a  \tb "}';         Hours = 2;   Declared = $true;  Honored = $true;  Problems = @();       Reason = 'a b' }

        # --- a reason with nothing to justify ----------------------------------------------------------------------
        @{ Name = 'a reason and no value';              Json = '{"coolingOffReason":"why"}';                                  Hours = 24;  Declared = $false; Honored = $true;  Problems = @('warn') }
    )

    # Reason is what a reader sees in the pack's warning. Unless a row says otherwise it is 'why' for a period under the
    # default that is honored (every such row above uses that reason) and nothing for every other row, so a reason that
    # leaks onto the set-aside path or the 24-and-over path fails the row it leaks on (phase 1 review, F2).
    foreach ($row in $script:Rows) {
        if (-not $row.ContainsKey('Reason')) {
            $row.Reason = if ($row.Honored -and $row.Hours -lt 24 -and $row.Json -match '"coolingOffReason":"why"') { 'why' } else { $null }
        }
    }

    # The record itself cannot be used: the reader says nothing about it (Get-DeveloperMode already does) and returns 24.
    $script:Unusable = @(
        @{ Name = 'a root that is an array';            Json = '[{"coolingOffHours":2,"coolingOffReason":"why"}]' }
        @{ Name = 'a root that is a string';            Json = '"coolingOffHours"' }
        @{ Name = 'text that does not parse';           Json = '{"coolingOffHours":2,' }
        @{ Name = 'an empty file';                      Json = '' }
    )
}

BeforeAll {
    . (Join-Path $PSScriptRoot '../../scripts/adoption-lib.ps1')

    function script:New-RecordRoot {
        # Untyped on purpose: a [string] parameter turns $null into '' and a "no record" case would write an empty one.
        param([AllowNull()]$Json)
        $root = Join-Path ([IO.Path]::GetTempPath()) ("kit-cooloff-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
        New-Item -ItemType Directory -Path $root -Force | Out-Null
        if ($null -ne $Json) { [IO.File]::WriteAllText((Join-Path $root 'kit-adoption.json'), $Json) }
        return $root
    }
    $script:Made = [System.Collections.Generic.List[string]]::new()
}

AfterAll {
    foreach ($m in $script:Made) { Remove-Item -LiteralPath $m -Recurse -Force -ErrorAction SilentlyContinue }
}

Describe 'Get-CoolingOff (feature 038, plan P2 to P4)' {
    It 'reads <Name>: <Hours> hour(s), declared=<Declared>, honored=<Honored>' -ForEach $script:Rows {
        $root = New-RecordRoot -Json $Json; $script:Made.Add($root)
        $r = Get-CoolingOff -Root $root
        $r.Hours | Should -Be $Hours
        $r.Declared | Should -Be $Declared
        $r.Honored | Should -Be $Honored
        $r.Reason | Should -Be $Reason
        # Severity is always there, so this read cannot throw under the strict mode Run-Tests.ps1 sets.
        $severities = @($r.Problems | ForEach-Object { $_.Severity })
        $severities | Should -Be $Problems
        foreach ($p in $r.Problems) {
            $p.Message | Should -Match 'coolingOff'
            $p.Fix | Should -Not -BeNullOrEmpty
        }
        # Why is one clause naming where the period came from, for a caller to put in its own message.
        $r.Why | Should -Not -BeNullOrEmpty
        $r.Why | Should -Not -Match '[\r\n]'
    }

    # A whole number past what a 64-bit integer holds is accepted (the spec sets no ceiling) and must not throw: a cast
    # to [long] on this path overflows (phase 1 review, F2, mutation M4). The period is returned as a double there.
    It 'accepts <Name> without throwing, as a period of at least the default' -ForEach @(
        @{ Name = 'a twenty-digit integer';        Json = '{"coolingOffHours":99999999999999999999}' }
        @{ Name = 'the largest 64-bit integer';    Json = '{"coolingOffHours":9223372036854775807}' }
        @{ Name = 'a thirty-one-digit integer';    Json = '{"coolingOffHours":1000000000000000000000000000000}' }
        @{ Name = '1e20';                          Json = '{"coolingOffHours":1e20}' }
    ) {
        $root = New-RecordRoot -Json $Json; $script:Made.Add($root)
        $r = Get-CoolingOff -Root $root
        $r.Hours | Should -BeGreaterThan 24
        $r.Declared | Should -BeTrue
        $r.Honored | Should -BeTrue
        @($r.Problems).Count | Should -Be 0
    }

    It 'names the period in Why, singular for one hour, and the default period whenever the record gives none' {
        $one = New-RecordRoot -Json '{"coolingOffHours":1,"coolingOffReason":"why"}'; $script:Made.Add($one)
        (Get-CoolingOff -Root $one).Why | Should -Be 'coolingOffHours declares 1 hour with a recorded reason'
        $four = New-RecordRoot -Json '{"coolingOffHours":4,"coolingOffReason":"why"}'; $script:Made.Add($four)
        (Get-CoolingOff -Root $four).Why | Should -Be 'coolingOffHours declares 4 hours with a recorded reason'
        $long = New-RecordRoot -Json '{"coolingOffHours":48}'; $script:Made.Add($long)
        (Get-CoolingOff -Root $long).Why | Should -Be 'coolingOffHours declares 48 hours'
        $none = New-RecordRoot -Json '{}'; $script:Made.Add($none)
        (Get-CoolingOff -Root $none).Why | Should -Be 'no coolingOffHours declared, so the default period of 24 hours applies'
        $gone = New-RecordRoot -Json $null; $script:Made.Add($gone)
        (Get-CoolingOff -Root $gone).Why | Should -Be 'no kit-adoption.json, so the default period of 24 hours applies'
        $typo = New-RecordRoot -Json '{"coolingOffHours":"8"}'; $script:Made.Add($typo)
        (Get-CoolingOff -Root $typo).Why | Should -Be 'coolingOffHours is not usable, so the default period of 24 hours applies'
        $bare = New-RecordRoot -Json '{"coolingOffHours":4}'; $script:Made.Add($bare)
        (Get-CoolingOff -Root $bare).Why | Should -Be 'coolingOffHours 4 has no recorded reason, so the default period of 24 hours applies'
    }

    It 'writes nothing to the warning stream for a value nested deeper than it prints' {
        $root = New-RecordRoot -Json '{"coolingOffHours":{"a":{"b":{"c":{"d":{"e":1}}}}}}'; $script:Made.Add($root)
        # 3>&1 merges the warning stream into the output, so a warning the function leaves on it shows up as a record here.
        $out = @(Get-CoolingOff -Root $root 3>&1)
        @($out | Where-Object { $_ -is [System.Management.Automation.WarningRecord] }).Count | Should -Be 0
        @($out | Where-Object { $_ -is [hashtable] })[0].Hours | Should -Be 24
    }

    It 'returns the period as a whole number, not a double, so a message prints "4" and never "4.0"' {
        $root = New-RecordRoot -Json '{"coolingOffHours":4.0,"coolingOffReason":"why"}'; $script:Made.Add($root)
        $r = Get-CoolingOff -Root $root
        "$($r.Hours)" | Should -Be '4'
    }

    It 'returns the reason trimmed, with a line break read as one space, so a warning stays on one line' {
        $root = New-RecordRoot -Json "{`"coolingOffHours`":4,`"coolingOffReason`":`"  first line\r\nsecond line  `"}"; $script:Made.Add($root)
        $r = Get-CoolingOff -Root $root
        $r.Hours | Should -Be 4
        $r.Reason | Should -Be 'first line second line'
    }

    It 'returns no reason when the value is not below the default or is not honored' {
        $root = New-RecordRoot -Json '{"coolingOffHours":4}'; $script:Made.Add($root)
        (Get-CoolingOff -Root $root).Reason | Should -BeNullOrEmpty
    }

    It 'names the field, the value it read, the period that applies and the fix, for a value it does not accept' {
        $root = New-RecordRoot -Json '{"coolingOffHours":"eight","coolingOffReason":"why"}'; $script:Made.Add($root)
        $p = @((Get-CoolingOff -Root $root).Problems)[0]
        $p.Message | Should -Match 'coolingOffHours'
        $p.Message | Should -Match 'eight'
        ($p.Message + ' ' + $p.Fix) | Should -Match '24'
    }

    It 'names the missing reason, and that 24 hours applies, for a value below the default' {
        $root = New-RecordRoot -Json '{"coolingOffHours":4}'; $script:Made.Add($root)
        $p = @((Get-CoolingOff -Root $root).Problems)[0]
        $p.Message | Should -Match 'coolingOffReason'
        ($p.Message + ' ' + $p.Fix) | Should -Match '24'
    }

    It 'returns 24, undeclared and with no problem, when there is no kit-adoption.json' {
        $root = New-RecordRoot -Json $null; $script:Made.Add($root)
        $r = Get-CoolingOff -Root $root
        $r.Hours | Should -Be 24
        $r.Declared | Should -BeFalse
        @($r.Problems).Count | Should -Be 0
    }

    It 'returns 24, undeclared and with no problem, when kit-adoption.json cannot be read (a directory by that name)' {
        $root = New-RecordRoot -Json $null; $script:Made.Add($root)
        New-Item -ItemType Directory -Path (Join-Path $root 'kit-adoption.json') | Out-Null
        $r = Get-CoolingOff -Root $root
        $r.Hours | Should -Be 24
        $r.Declared | Should -BeFalse
        @($r.Problems).Count | Should -Be 0
    }

    It 'returns 24, undeclared and with no problem for <Name>' -ForEach $script:Unusable {
        $root = New-RecordRoot -Json $Json; $script:Made.Add($root)
        $r = Get-CoolingOff -Root $root
        $r.Hours | Should -Be 24
        $r.Declared | Should -BeFalse
        @($r.Problems).Count | Should -Be 0
    }

    It 'does not let a reason that sits in another key, or inside a string, count as a declaration' {
        $root = New-RecordRoot -Json '{"note":"coolingOffHours: 2","nested":{"coolingOffHours":2,"coolingOffReason":"why"}}'; $script:Made.Add($root)
        $r = Get-CoolingOff -Root $root
        $r.Hours | Should -Be 24
        $r.Declared | Should -BeFalse
        @($r.Problems).Count | Should -Be 0
    }

    It 'reads the same period whatever the caller preference for errors' {
        $root = New-RecordRoot -Json '{"coolingOffHours":4,"coolingOffReason":"why"}'; $script:Made.Add($root)
        $saved = $ErrorActionPreference
        try {
            $ErrorActionPreference = 'Stop'
            (Get-CoolingOff -Root $root).Hours | Should -Be 4
            $ErrorActionPreference = 'Continue'
            (Get-CoolingOff -Root $root).Hours | Should -Be 4
        } finally { $ErrorActionPreference = $saved }
    }

    It 'defines the default and the floor in this library, as 24 and 1' {
        $script:CoolingOffDefaultHours | Should -Be 24
        $script:CoolingOffFloorHours | Should -Be 1
    }
}
