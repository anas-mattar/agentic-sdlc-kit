<#
.SYNOPSIS
    Shared readers for the adoption record's declarations: the developer roster
    (Get-DeveloperMode, feature 013) and the critical surfaces (Get-CriticalSurfaces,
    feature 017).

.DESCRIPTION
    Dot-sourced by scripts/enforcement-pack.ps1 (which enforces) and scripts/verify-kit.ps1
    (which reports). Feature 012 established this pattern with scripts/scope-lib.ps1, for the
    same reason: two graders of one rule drift, and a comment claiming they agree is not a
    mechanism.

    That is not a hypothetical here. Feature 013 shipped the logic twice, and it went wrong
    in both of the ways duplication allows, inside one feature: the copies drifted (the
    root-object guard landed in the enforcing copy only), and the reporting copy used two
    comparers that disagreed with each other. The drift was found by a reviewer reading a
    comment asserting the two copies matched exactly.

    Get-DeveloperMode returns one object describing the record, and BOTH behaviours are read
    from it: the mode the check enforces, and the problems the doctor reports. Neither script
    interprets the record itself.
#>

# The evidence mode for the Critical lane (docs/sdlc/critical-delivery.md item 5), derived
# from the project's declared developers — never declared directly, so a project cannot
# assert team independence while naming one person.
#
# Every degenerate input resolves to 'solo', the stricter arm: no record, an unreadable or
# unparsable one, a root that is not a JSON object, no field, a non-array, an empty array, an
# array of blanks. Adoptions predating this feature declare nothing, and any other default
# would silently drop a requirement in projects that never asked.
#
# Returns:
#   Mode      'solo' | 'team'
#   Count     usable developers after trimming, dropping non-strings/blanks, and collapsing
#             duplicates case-insensitively
#   Why       one clause naming the reason, for the caller's message
#   Declared  whether the record declares the field at all, so no caller needs its own notion
#             of "is this declared" — a second such notion had grown in the doctor
#   Problems  zero or more @{ Message; Fix } the doctor reports. The check ignores them, and
#             the reason is narrower than it first looks: a problem never makes a record
#             produce a LAXER mode than it would without the malformation. It does NOT mean
#             every problem lands on solo — ["ada","grace"," "] is malformed and is team.
#             Getting that reason wrong is how a maintainer talks themselves out of the
#             doctor (013 phase 5 review, NEW-4)
function Get-DeveloperMode {
    param([Parameter(Mandatory)][string]$Root)

    $problems = [System.Collections.Generic.List[object]]::new()
    $recordPath = Join-Path $Root 'kit-adoption.json'
    if (-not (Test-Path -LiteralPath $recordPath)) {
        return @{ Mode = 'solo'; Count = 0; Declared = $false; Why = 'no kit-adoption.json'; Problems = $problems }
    }

    # Inside the try: 'unreadable' is one of the degenerate records FR-003 names, and a read
    # can fail on a path Test-Path accepts — a directory, a lock, a permission denial, a
    # dangling symlink. Phase 4 moved this read out of the try and, with
    # $ErrorActionPreference = 'Stop', an unreadable record became an unhandled error that
    # skipped every check ordered after this one (013 phase 4 re-review, N2).
    try {
        # -ErrorAction Stop so the catch fires regardless of the caller's preference. Both
        # shipped callers set 'Stop', but a library that only works under one caller's
        # settings is not self-contained (013 phase 5 review, NEW-E).
        $rawRecord = "$(Get-Content -LiteralPath $recordPath -Raw -ErrorAction Stop)"
    } catch {
        return @{ Mode = 'solo'; Count = 0; Declared = $false; Why = 'kit-adoption.json could not be read'; Problems = $problems }
    }

    # The root must be a JSON OBJECT, judged from the TEXT. Testing the parsed value is not
    # enough: ConvertFrom-Json emits array elements to the pipeline one at a time, so a
    # single-element root array collapses to one PSCustomObject indistinguishable from a real
    # record. The root of a JSON document is whatever the first non-whitespace character
    # opens, so this test cannot be fooled by a brace inside a string.
    if ($rawRecord.TrimStart([char]0xFEFF, ' ', "`t", "`r", "`n") -notmatch '^\{') {
        $problems.Add(@{ Message = 'kit-adoption.json is not a JSON object at its root'; Fix = 'the record is a single JSON object; a root array is ignored entirely and the project falls back to the solo evidence rule' })
        return @{ Mode = 'solo'; Count = 0; Declared = $true; Why = 'kit-adoption.json is not a JSON object at its root'; Problems = $problems }
    }
    try {
        $record = $rawRecord | ConvertFrom-Json
    } catch {
        return @{ Mode = 'solo'; Count = 0; Declared = $false; Why = 'kit-adoption.json does not parse'; Problems = $problems }
    }
    if ($record -isnot [PSCustomObject]) {
        return @{ Mode = 'solo'; Count = 0; Declared = $false; Why = 'kit-adoption.json is not a JSON object'; Problems = $problems }
    }

    if ($null -eq $record.developers) {
        # An explicit `"developers": null` is the same unfinished edit as `[]` and is reported
        # the same way — but only when the key is really present. An ABSENT key is the
        # supported default for every adoption predating this feature and must stay silent.
        if ($rawRecord -match '(?m)"developers"\s*:') {
            $problems.Add(@{ Message = 'kit-adoption.json developers is null'; Fix = 'name the project''s developers, or remove the key — an explicit null is treated as solo, the same as an empty array' })
            return @{ Mode = 'solo'; Count = 0; Declared = $true; Why = 'developers in kit-adoption.json is null'; Problems = $problems }
        }
        return @{ Mode = 'solo'; Count = 0; Declared = $false; Why = 'no developers declared in kit-adoption.json'; Problems = $problems }
    }
    if ($record.developers -isnot [Array]) {
        $problems.Add(@{ Message = 'kit-adoption.json developers is not an array'; Fix = 'declare it as a JSON array of names, e.g. ["ada", "grace"] — a non-array is ignored and the project is treated as solo (adoption/updating.md)' })
        return @{ Mode = 'solo'; Count = 0; Declared = $true; Why = 'developers in kit-adoption.json is not an array'; Problems = $problems }
    }

    $entries = @($record.developers)
    $named = @($entries |
        Where-Object { $_ -is [string] -and -not [string]::IsNullOrWhiteSpace($_) } |
        ForEach-Object { $_.Trim() })
    if ($entries.Count -eq 0) {
        $problems.Add(@{ Message = 'kit-adoption.json developers is empty'; Fix = 'name the project''s developers, or remove the field — an empty array is indistinguishable from an unfinished edit and is treated as solo' })
    } elseif ($named.Count -ne $entries.Count) {
        $problems.Add(@{ Message = 'kit-adoption.json developers contains a blank or non-string entry'; Fix = 'every entry is a non-empty name; blanks and non-strings are dropped before the count is taken, which can silently move the project from team back to solo' })
    }

    # ONE comparer for detecting duplicates and for naming them. Two comparers that disagree
    # would dereference an empty group (013 phase 4 re-review, N6).
    $seen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $unique = [System.Collections.Generic.List[string]]::new()
    $firstDupe = $null
    foreach ($n in $named) {
        if ($seen.Add($n)) { $unique.Add($n) } elseif (-not $firstDupe) { $firstDupe = $n }
    }
    if ($firstDupe) {
        $problems.Add(@{ Message = "kit-adoption.json developers lists '$firstDupe' more than once (case-insensitively)"; Fix = 'one entry per person — duplicates are collapsed before the count is taken, so the extra entry changes nothing except how the record reads' })
    }

    $mode = if ($unique.Count -ge 2) { 'team' } else { 'solo' }
    $noun = if ($unique.Count -eq 1) { 'developer' } else { 'developers' }
    return @{
        Mode     = $mode
        Count    = $unique.Count
        Declared = $true
        Why      = "$($unique.Count) $noun declared in kit-adoption.json"
        Problems = $problems
    }
}

# The project's critical surfaces (constitution X, Level declaration; feature 017): path globs
# naming where its critical code lives, from the optional `criticalSurfaces` key. A Standard or
# Micro feature whose Territory reaches one is graded by scripts/enforcement-pack.ps1, and the
# doctor (scripts/verify-kit.ps1) reports the declaration. Both read it HERE and nowhere else,
# the way Get-DeveloperMode is read: two interpreters of one record is what 013 shipped and
# paid for.
#
# The direction of every degenerate input is the OPPOSITE of Get-DeveloperMode's. There, the
# unusable record falls to the stricter arm (solo). Here the strict state is ARMED, and a list
# nobody can read in full must never arm a floor that has a hole in it, nor read as an armed
# floor that is clean: so any problem leaves Armed false, State 'malformed', and the check
# reports UNGRADED. A problem therefore never makes this result MORE armed than the same record
# without it, and an unusable entry is never silently dropped from an otherwise armed list.
#
# Returns:
#   State     'absent' | 'empty' | 'malformed' | 'valid'
#   Armed     true only for State 'valid'
#   Globs     the usable entries: trimmed, `\` read as `/`, duplicates collapsed
#             case-insensitively. Populated for 'malformed' too, for messages only — a caller
#             must not grade against it unless Armed
#   Declared  whether the key is present at all (an explicit null counts as present)
#   Why       one clause naming the state, for the caller's message
#   Problems  zero or more @{ Message; Fix } the doctor reports as findings
#
# An empty array is NOT a problem. 'criticalSurfaces': [] reads as an explicit statement that
# the project has none, which is lawful; it is simply not armed. The root-object and parse
# failures are reported once, by Get-DeveloperMode's Problems, and here fall to 'absent', so
# the doctor does not print the same defect twice.
function Get-CriticalSurfaces {
    param([Parameter(Mandatory)][string]$Root)

    $problems = [System.Collections.Generic.List[object]]::new()
    $absent = { param($why) @{ State = 'absent'; Armed = $false; Globs = @(); Declared = $false; Why = $why; Problems = $problems } }

    $recordPath = Join-Path $Root 'kit-adoption.json'
    if (-not (Test-Path -LiteralPath $recordPath)) { return (& $absent 'no kit-adoption.json') }
    try {
        $rawRecord = "$(Get-Content -LiteralPath $recordPath -Raw -ErrorAction Stop)"
    } catch {
        return (& $absent 'kit-adoption.json could not be read')
    }
    if ($rawRecord.TrimStart([char]0xFEFF, ' ', "`t", "`r", "`n") -notmatch '^\{') {
        return (& $absent 'kit-adoption.json is not a JSON object at its root')
    }
    try { $record = $rawRecord | ConvertFrom-Json } catch { return (& $absent 'kit-adoption.json does not parse') }
    if ($record -isnot [PSCustomObject]) { return (& $absent 'kit-adoption.json is not a JSON object') }

    $present = $record.PSObject.Properties.Name -contains 'criticalSurfaces'
    if (-not $present) { return (& $absent 'no criticalSurfaces declared in kit-adoption.json') }

    $malformed = {
        param($message, $fix, $globs)
        $problems.Add(@{ Message = $message; Fix = $fix })
        @{ State = 'malformed'; Armed = $false; Globs = @($globs); Declared = $true; Why = $message; Problems = $problems }
    }
    if ($null -eq $record.criticalSurfaces) {
        return (& $malformed 'kit-adoption.json criticalSurfaces is null' 'declare it as a JSON array of path globs, or remove the key — an explicit null leaves the surface floor unarmed (adoption/updating.md)' @())
    }
    if ($record.criticalSurfaces -isnot [Array]) {
        return (& $malformed 'kit-adoption.json criticalSurfaces is not an array' 'declare it as a JSON array of path globs, e.g. ["src/auth/", "api/Payments/**"] — a non-array leaves the surface floor unarmed (adoption/updating.md)' @())
    }

    $entries = @($record.criticalSurfaces)
    if ($entries.Count -eq 0) {
        return @{ State = 'empty'; Armed = $false; Globs = @(); Declared = $true; Why = 'criticalSurfaces is empty'; Problems = $problems }
    }

    $seen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $usable = [System.Collections.Generic.List[string]]::new()
    $sawBlank = $false
    $unsafe = [System.Collections.Generic.List[string]]::new()
    foreach ($e in $entries) {
        if ($e -isnot [string] -or [string]::IsNullOrWhiteSpace($e)) { $sawBlank = $true; continue }
        $glob = $e.Trim().Replace('\', '/')
        # The same shape Get-Territory refuses (scripts/scope-lib.ps1): a drive or leading slash
        # can never match a repo-relative Territory path, and a '..' segment addresses outside
        # the tree. Either would sit in the list looking like coverage and match nothing.
        if ($glob -match '^([A-Za-z]:|/)' -or $glob -match '(^|/)\.\.(/|$)') { $unsafe.Add($glob); continue }
        if ($seen.Add($glob)) { $usable.Add($glob) }
    }
    if ($sawBlank) {
        $problems.Add(@{ Message = 'kit-adoption.json criticalSurfaces contains a blank or non-string entry'; Fix = 'every entry is a non-empty path or glob; the floor is not armed until the whole list is usable, because a dropped entry would silently weaken it' })
    }
    foreach ($u in $unsafe) {
        $problems.Add(@{ Message = "kit-adoption.json criticalSurfaces entry '$u' is not a repo-relative path"; Fix = 'write surfaces governance-root-relative (repo-prefixed in a multi-repo project) with no drive letter, leading slash or .. segment — an entry that can never match leaves a hole in the floor' })
    }
    if ($problems.Count -gt 0) {
        return @{ State = 'malformed'; Armed = $false; Globs = @($usable); Declared = $true; Why = 'criticalSurfaces holds an entry that cannot be used'; Problems = $problems }
    }
    $noun = if ($usable.Count -eq 1) { 'critical surface' } else { 'critical surface(s)' }
    return @{ State = 'valid'; Armed = $true; Globs = @($usable); Declared = $true; Why = "$($usable.Count) $noun declared in kit-adoption.json"; Problems = $problems }
}
