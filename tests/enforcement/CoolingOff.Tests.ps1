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

        # --- a reason with nothing to justify ----------------------------------------------------------------------
        @{ Name = 'a reason and no value';              Json = '{"coolingOffReason":"why"}';                                  Hours = 24;  Declared = $false; Honored = $true;  Problems = @('warn') }
    )

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

    It 'keeps the default and the floor in this library and nowhere a caller could change them silently' {
        $script:CoolingOffDefaultHours | Should -Be 24
        $script:CoolingOffFloorHours | Should -Be 1
    }
}
