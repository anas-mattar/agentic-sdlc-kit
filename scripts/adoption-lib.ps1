<#
.SYNOPSIS
    Shared readers for the adoption record's declarations: the developer roster
    (Get-DeveloperMode, feature 013), the critical surfaces (Get-CriticalSurfaces,
    feature 017) and the nested code repositories (Get-CodeRepos, feature 012, shared since
    feature 018).

.DESCRIPTION
    Dot-sourced by scripts/enforcement-pack.ps1 (which enforces) and scripts/verify-kit.ps1
    (which reports) for the developer and surface readers, and by scripts/scope-check-repos.ps1
    for Get-CodeRepos (and, from feature 018 phase 3, scripts/territory-check.ps1). Feature 012 established this pattern with scripts/scope-lib.ps1, for the
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
#   State     'absent' | 'unreadable' | 'empty' | 'malformed' | 'valid'
#   Armed     true only for State 'valid'
#   Globs     the usable entries: trimmed, `\` read as `/`, duplicates collapsed
#             case-insensitively. Populated for 'malformed' too, for messages only — a caller
#             must not grade against it unless Armed
#   Declared  whether the key is present at all (an explicit null counts as present)
#   Why       one clause naming the state, for the caller's message
#   Problems  zero or more @{ Message; Fix } the doctor reports as findings
#
# An empty array is NOT a problem. 'criticalSurfaces': [] reads as an explicit statement that
# the project has none, which is lawful; it is simply not armed. A record that exists but cannot
# be read (unreadable, not parseable, root not an object) is State 'unreadable', distinct from
# 'absent' so the check can say so by name instead of grading it as unarmed; it carries no
# Problems, because Get-DeveloperMode and the doctor already report that defect and the doctor
# must not print it twice.
function Get-CriticalSurfaces {
    param([Parameter(Mandatory)][string]$Root)

    $problems = [System.Collections.Generic.List[object]]::new()
    $absent = { param($why) @{ State = 'absent'; Armed = $false; Globs = @(); Declared = $false; Why = $why; Problems = $problems } }
    # 'unreadable' is NOT 'absent' (017 phase 2 review F2, approved by the owner). Absent means
    # the project said nothing, which is lawful and merely not armed. Unreadable means the
    # record exists and this reader cannot tell what it says, so it cannot know whether the
    # project asked for a floor. A caller that folded the two together would grade a project
    # with broken JSON exactly like one that never asked, which is the quiet clean grade spec
    # FR-012 forbids. No Problems here: the defect is reported once, by the doctor itself and
    # by Get-DeveloperMode, and a second report would be noise.
    $unreadable = { param($why) @{ State = 'unreadable'; Armed = $false; Globs = @(); Declared = $false; Why = $why; Problems = $problems } }

    $recordPath = Join-Path $Root 'kit-adoption.json'
    if (-not (Test-Path -LiteralPath $recordPath)) { return (& $absent 'no kit-adoption.json') }
    try {
        $rawRecord = "$(Get-Content -LiteralPath $recordPath -Raw -ErrorAction Stop)"
    } catch {
        return (& $unreadable 'kit-adoption.json could not be read')
    }
    if ($rawRecord.TrimStart([char]0xFEFF, ' ', "`t", "`r", "`n") -notmatch '^\{') {
        return (& $unreadable 'kit-adoption.json is not a JSON object at its root')
    }
    try { $record = $rawRecord | ConvertFrom-Json } catch { return (& $unreadable 'kit-adoption.json does not parse') }
    if ($record -isnot [PSCustomObject]) { return (& $unreadable 'kit-adoption.json is not a JSON object') }

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

# The nested code repositories a project declares (feature 012; shared by feature 018). The reader
# the scripts that WALK those repositories share: scripts/scope-check-repos.ps1 grades their commits
# today, and scripts/territory-check.ps1 will compare their branches (feature 018, phase 3). It used
# to live inside the scope check, and a second script that needed it would have carried a second
# interpretation of the record, which is what 013 paid for. The scope check now calls this and
# prints exactly what it printed before.
#
# It is NOT the only place the key is read: scripts/verify-kit.ps1 validates codeRepos for the
# doctor with its own checks (feature 012 phase 2). The two are about different questions (what to
# walk, and what to report as a finding), and this function does not replace that one.
#
# The messages are RETURNED, not printed, because each caller speaks in its own voice: the scope
# check prefixes them with its own name, the territory check prints them as warnings. The text is
# byte-identical to what the scope check printed, so the REPOS-* rules are the guard.
#
# Returns:
#   Repos     the usable entries, in the record's order: single directory names, never a path
#   Warnings  zero or more message strings, each beginning 'WARN '
#   Unusable  true when the declaration was PRESENT and could not be read in full: unparseable JSON,
#             a non-array, or any rejected entry. An absent record, an absent key and an empty array
#             are lawful statements that there are none and are NOT unusable. A caller that needs to
#             tell "declared nothing" from "declared something I cannot use" reads this.
function Get-CodeRepos {
    param([Parameter(Mandatory)][string]$Root)
    $result = @{ Repos = @(); Warnings = @(); Unusable = $false }
    $recordPath = Join-Path $Root 'kit-adoption.json'
    if (-not (Test-Path $recordPath)) { return $result }
    try {
        $record = Get-Content -Raw -Path $recordPath | ConvertFrom-Json
    } catch {
        $result.Warnings += 'WARN kit-adoption.json is not valid JSON — no code repositories read (fix the record; scripts/verify-kit.ps1 explains the shape)'
        $result.Unusable = $true
        return $result
    }
    if ($null -ne $record.codeRepos -and $record.codeRepos -isnot [Array]) {
        $result.Warnings += 'WARN kit-adoption.json codeRepos is not an array — ignoring it (shape: adoption/updating.md)'
        $result.Unusable = $true
        return $result
    }
    # Entries are single directory names (012 D2). A path, a traversal or a drive prefix would address
    # a directory outside the governance root: read-only here, but it grades the wrong tree. The
    # doctor FAILs these too; the readers refuse them because a code repository's CI may never run
    # the doctor (012 phase 1 review, F7).
    $clean = @()
    foreach ($e in @($record.codeRepos | Where-Object { $_ })) {
        if ("$e" -notmatch '^(?!\.+$)[A-Za-z0-9._-]+$') {
            $result.Warnings += "WARN ignoring codeRepos entry '$e' — entries are plain directory names under this repository, not paths (scripts/verify-kit.ps1 explains the shape)"
            $result.Unusable = $true
            continue
        }
        $clean += "$e"
    }
    $result.Repos = @($clean)
    return $result
}
