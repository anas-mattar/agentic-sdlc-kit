# AI Code Review — 038 Configurable cooling-off period (phase 1: the reader)

**Reviewer**: fresh-context agent — claude-opus-5-5
**Date**: 2026-10-23
**Branches**: agentic-sdlc-kit `038-configurable-cooling-off` (tip `5ec28ac`, reviewed as `git diff 08a7cef 5ec28ac`)
**Scope reviewed**: `scripts/adoption-lib.ps1` (the added `Get-CoolingOff`, the two constants, the header lines; `Get-DeveloperMode` read for conventions), `tests/enforcement/CoolingOff.Tests.ps1`, the `tasks.md` and `notes.md` changes in the commit. Graded against `spec.md` (FR-001..FR-005, FR-011 first half, edge cases), `plan.md` (P1-P4, P9), `contracts/kit-adoption-cooling-off.md`, `data-model.md`, `tasks.md` phase 1 (T001-T007). Callers in `scripts/enforcement-pack.ps1` and `scripts/verify-kit.ps1` were read only to judge how phase 2 and 3 will use the return value. Uncommitted working-tree changes were not reviewed.
**Feature contract**: one reader, no caller yet, no verdict change; no new package or script; every unusable input resolves to 24; under 24 is honored only with a non-blank reason; default and floor live only in `adoption-lib.ps1`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: claude-sonnet-5-5 (Claude Code session)
- **Inputs provided**: phase 1 commit `5ec28ac` (`git show`, `git diff 08a7cef 5ec28ac`), spec.md, plan.md, tasks.md, data-model.md, contracts/kit-adoption-cooling-off.md, notes.md (read last), specs/_templates/ai-code-review-template.md
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — The reader is sound in its core direction: every unusable value, null, string, boolean, array, object, non-finite number, unreadable or non-object record I tried resolved to 24, nothing leaked into the pipeline, strict mode and `$ErrorActionPreference = 'Stop'` are handled, and no existing function was touched. Two small, in-territory gaps should be closed before phase 2 starts printing `Reason`. First, the "non-blank reason" test accepts a reason that is invisible (zero-width characters, a lone U+FEFF) or that carries terminal control sequences, which can hide the very warning FR-006 and SC-003 exist to print (F1). Second, the Pester table does not assert `Reason` per row as T003 requires, and a mutation that leaks the reason on the 24-and-over path survives all 51 tests (F2). The remaining findings are minor or are decisions for phase 3.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | Ran `Get-CoolingOff` under `Set-StrictMode -Version Latest` and `$ErrorActionPreference='Stop'` on 49 hand-written records (scratch `probe.ps1`). FR-002/003: `0`, `-0`, `-0.0`, `-3`, `1.5`, `24.5`, `"8"`, `"eight"`, `true`, `null`, `[]`, `[8]`, `{}`, a deep object, `1e999`, `-1e999`, bare `NaN`/`Infinity` each gave Hours 24, Honored false, one `fail`. `4.0`, `1e3`, `4e0` gave Int64 whole numbers. FR-004: missing file, a directory named `kit-adoption.json`, a root array, a root string, an empty or whitespace-only file, unparsable text, two concatenated roots, trailing garbage each gave 24, Declared false, no problem. FR-005: under-24 values with absent, empty, whitespace, NBSP-only, numeric, null, array or object reasons gave 24 and `fail`. BOM plus CRLF parsed correctly. A key nested in another object, or inside a string, did not count. Exceptions are F1 (reason), F5 (fractional rounding) and F6 (duplicate keys). |
| Visual-reference match | n/a: no UI. |
| Feature contract held (no unapproved table/migration/permission/package) | `git diff 08a7cef 5ec28ac --stat`: 4 files. `adoption-lib.ps1` +114/-2, and the only removed lines are the two header lines. No package, no new script, nothing calls `Get-CoolingOff` (grep of the committed `enforcement-pack.ps1`: `$Config.CoolingOffHours` is still used at lines 161 and 670-672). |
| Constitution / domain invariants | Fail-closed direction held for every unusable shape probed. The `Problems` shape always carries `Severity`. This deviates from `Get-DeveloperMode`'s optional key, but `data-model.md` lists `@{ Message; Fix; Severity }`, and the function comment documents the deviation. No domain-invariants pack exists. |
| Security (authn/authz, secrets, sensitive logging) | Nothing sensitive is read. The record's text reaches output through `Reason` and the `(read: …)` excerpt. See F1: control characters pass through unfiltered. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | `pwsh -NoProfile -File scripts/scope-check.ps1 -Commit 5ec28ac` printed `scope-check: PASS phase 1 commit 5ec28ac (4 file(s))`, exit 0. The `tasks.md` diff contains only the seven T001-T007 checkbox ticks. |
| Rollback safety (phase reverts cleanly; schema additive?) | The phase is additive: one new function, two new script variables, one new test file, and nothing reads them yet. Reverting `5ec28ac` restores the parent byte-for-byte in `adoption-lib.ps1`. |

## Findings

### F1 — A blank-looking or terminal-hostile reason is accepted as "non-blank" — BLOCKING

`Get-CoolingOff` decides whether a reason is usable with `($reasonProp.Value -replace '\s*[\r\n]+\s*', ' ').Trim()` followed by `[string]::IsNullOrWhiteSpace`. That catches Unicode whitespace: an NBSP-only reason was correctly rejected in my probe. It does not catch characters that render as nothing or that control the terminal. Probe results under strict mode, all for `coolingOffHours: 2`:

- `"​​"` (two zero-width spaces) gave Hours **2**, Honored true, Reason of length 2.
- `"﻿"` gave Hours **2**, Honored true.
- `"\u0000"` gave Hours **2**, Honored true.
- `"ok\u001b[2K\u001b[1Ahidden"` gave Hours **2**, and the ESC bytes come back intact in `Reason`. Phase 2 quotes `Reason` in the pack's WARN (P4/P5). An ANSI erase-line or cursor-up sequence there lets the record hide the warning in a terminal or an ANSI-rendering CI log. SC-003 says no passing sub-24 run may omit the warning, and FR-006 says it must be visible.
- `"a b"`, and `"a\u0085b\u000bc\u000cd"` (NEL, VT, FF), are not folded, so "a warning stays on one line" (function comment, contract "Reading rules") does not hold for every line break.

The spec's edge case reads "a reason that is only whitespace counts as blank", so the letter is met. But the reader is the single definition of "non-blank" for both the pack and the doctor, and the governing intent is a visible, auditable justification. P9 accepts that the owner can edit the record. It does not accept that the edit can make the warning disappear. A 100,000-character reason is also honored and returned whole (probe "very long reason"). The contract says "one line" but sets no length limit, which is an owner call (see Action).

*Action: implementer, in phase 1 territory. Replace every `\p{Cc}`, `\p{Cf}`, `\p{Zl}` and `\p{Zp}` character in the reason with a space (this covers CR/LF, ESC, NUL, ZWSP, BOM, U+2028 and NEL), collapse runs of whitespace, trim, then test `IsNullOrWhiteSpace`. Add table rows for a ZWSP-only reason (24, `fail`), an ESC-bearing reason (honored, `Reason` free of U+001B) and a U+2028 reason (one line). Owner to CONFIRM whether a length cap or truncation for display is wanted. If so, it is a contract amendment.*

### F2 — The table does not assert `Reason` per row; a reason leak survives every test — BLOCKING

T003 says every row asserts "`Hours`, `Declared`, `Honored`, `Reason` and the problem list". The row data has no `Reason` column, and the `It` block never reads `$r.Reason`. Only two dedicated tests touch `Reason`: the line-break test and the `{"coolingOffHours":4}` test. I ran mutations on scratch copies of the library (never on repo files) with the committed test file:

- **M1**: return `Reason = 'leak'` on the `>= 24` path. Result: **51 passed, 0 failed (survives)**. Phase 2 is likely to print the short-period warning when `Reason` is non-null. A leak like this would then put a warning on a 48-hour record, which is an FR-007 violation that nothing would catch.
- **M2b**: return `Reason = "leak"` on the set-aside path. Result: 50/1, caught by only one dedicated test.
- **M3**: `Why` replaced by a constant. Result: 51/0 (survives); `Why` is asserted only as non-empty and single-line.
- **M4**: always `[long]$d`. Result: 51/0 (survives), yet this mutant **throws** `Arithmetic operation resulted in an overflow` on `{"coolingOffHours":1000000000000000000000000000000}`. The BigInteger and over-2^53 branch has no test row.
- **M5**: drop the whole-number check. Result: 49/2, caught. **M6**: `Declared` false on set-aside. Result: 29/22, caught. **M7**: no line-break fold. Result: 50/1, caught. **M8**: accept numeric strings. Result: 50/1, caught.

The table is strong on `Hours`, `Declared`, `Honored` and the severities. It is weak on `Reason`, on `Why`, and on the huge-integer path.

*Action: implementer. Add a `Reason` column to `$script:Rows` and assert it in the `It` block. It is the trimmed reason for the seven honored sub-24 rows and `$null` everywhere else. Add rows for a twenty-digit integer and for `9223372036854775807`, asserting the call does not throw, the period is at least 24, and Honored is true. Optionally pin one `Why` per branch with `-Match`.*

### F3 — The return shape cannot tell phase 3 that only `coolingOffReason` is declared — CONFIRM

`Declared` reflects `coolingOffHours` only. A reason-only record returns `Declared = $false` with one `warn`, as I probed for `{"coolingOffReason":"why"}`, `{"coolingOffReason":""}` and a key with a trailing space. T021 / P6 say the doctor block is "gated on the library's own `Declared`". Gated that way, the doctor would drop the reason-only warning that `data-model.md` requires ("a reason with no value: unused, warn"). The team-mode warning is due when "either key [is] declared" (contract, FR-011), but the doctor cannot detect a reason-only declaration without reading the record itself, which T021 forbids.

*Action: owner to decide before phase 3. Either add a field to the reader, such as `ReasonDeclared` or `AnyDeclared`, now while it has no caller, or record in tasks.md that phase 3 gates on `Declared -or @(Problems).Count -gt 0` and accepts that a reason-only record in team mode gets the "unused" warning rather than the "no effect in team mode" one.*

### F4 — `Hours` is not always an integer, and the same number prints two ways — MINOR

Plan P2 and `data-model.md` say `Hours` is "always an integer". A whole number past 2^53 comes back as `[double]`: `1e20` gives `1E+20`, a 31-digit integer gives `9.999999999999999E+29`, and `9223372036854775807` gives `9.223372036854776E+18`. For the 31-digit case, `Why` interpolates `1E+30` while `Hours.ToString('R')` prints `9.999999999999999E+29`. `2^53+1` is silently returned as `9007199254740992`, one hour shorter than declared; the shortfall does not matter in practice. The implementer's notes acknowledge the double. Today's pack arithmetic (`TotalHours -lt`, `[math]::Ceiling`) tolerates doubles, so nothing breaks. A later caller that uses `[TimeSpan]::FromHours` would overflow above about 2.56e8 hours, though.

*Action: none required for phase 1. Either amend `data-model.md` and the contract to say "a whole number, possibly a double past 2^53", or clamp to a documented ceiling (a spec change, per the notes). Cover the branch with the test rows from F2.*

### F5 — "Fractional" is judged after double rounding — MINOR

Newtonsoft parses decimals to `[double]`, so the reader never sees the written digits. `0.99999999999999999999` is accepted as **1** (honored with a reason), even though the contract calls it fractional and below the floor. `23.99999999999999999999` is accepted as **24**, with no reason needed. `1.00000000000000000001` and `4.00000000000000001` become 1 and 4. Each difference is below 1e-15 hours, and the rounding goes up as often as down, so the wait is never meaningfully shortened. The contract's "any fractional number is not accepted" is still not literally true.

*Action: none in code. Optionally add one sentence to the contract: "judged on the value as a double; digits beyond double precision are not seen".*

### F6 — Duplicate and case-variant keys, and lenient JSON — MINOR

- `{"coolingOffHours":48,"coolingOffHours":2,"coolingOffReason":"x"}`: the last value wins, giving **2** honored, with no problem reported. Someone reading the record top-down sees 48.
- `{"CoolingOffHours":2,"COOLINGOFFREASON":"x"}` is honored, because property lookup is case-insensitive. A record with two case-variant keys fails to parse, giving 24 and silence from this reader.
- Newtonsoft also accepts single quotes, unquoted keys, comments, trailing commas and `0x8` (read as 8). Leading-zero `08` fails to parse and gives 24.

None of these shortens the wait against what the author wrote, and the leniency matches `Get-DeveloperMode`. Phase 2 will print the short-period warning on every run, so a hidden duplicate still shows.

*Action: none for phase 1. Phase 3 may add a doctor warning for a duplicated `coolingOffHours` key if the owner wants one. Record that decision in tasks.md either way.*

### F7 — `ConvertTo-Json -Depth 3` writes a stray PowerShell WARNING for a deep value — MINOR

`{"coolingOffHours":{"a":{"b":{"c":{"d":{"e":1}}}}}}` correctly gives 24 and `fail`. The `$shown` excerpt also emits `WARNING: Resulting JSON is truncated as serialization has exceeded the set depth of 3.` to the warning stream, which I observed in the probe output. In the doctor (phase 3), that line would appear in the console between its own lines.

*Action: implementer. Add `-WarningAction SilentlyContinue` to the `ConvertTo-Json` call. This is cheap now and avoids an unexplained line in a fixture later.*

### F8 — The constants are mutable script variables; a test name over-claims — MINOR

`$script:CoolingOffDefaultHours` and `$script:CoolingOffFloorHours` are plain variables in the dot-sourcing caller's script scope. When a caller assigned `$script:CoolingOffDefaultHours = 0` after dot-sourcing (probe2), `{"coolingOffHours":4}` with no reason came back **Hours 4, Honored true**. No shipped caller does this, and a constant collision is unlikely. The test titled "keeps the default and the floor in this library and nowhere a caller could change them silently" asserts only their initial values. Resolution under other dot-source contexts is fine: dot-sourced inside a function, and via `New-Module`, both gave 24.

*Action: optional. Declare them with `Set-Variable -Scope Script -Option ReadOnly -Force`, or rename the test to what it asserts.*

### F9 — `Why` wording — MINOR

"coolingOffHours declares 1 hours with a recorded reason" uses "1 hours". The record-level `Why` clauses ("…, so the default period") do not name 24, unlike the set-aside clauses. Callers will put `Why` in their own messages.

*Action: implementer, optional. Use singular "hour" for 1, and say "the default period of 24 hours" consistently.*

### F10 — Header `.DESCRIPTION` not extended — DOC DRIFT

T005 asks the header to name the reader (done in `.SYNOPSIS`) and to say in one sentence why the constants live here. That sentence is in the function's comment block, not the file header. The `.DESCRIPTION` still says the pack and the doctor dot-source the file "for the developer and surface readers".

*Action: implementer, optional now or in phase 2/3 when the callers exist. Extend the `.DESCRIPTION` caller sentence.*

## Amendments in this diff

- [x] **None.** The only change to the feature's documents is `tasks.md` T001-T007 ticked from `[ ]` to `[x]` (diff read line by line), plus the evidence in `notes.md`. `spec.md`, `plan.md`, `data-model.md` and `contracts/` are unchanged.

## Constitution re-check (post-implementation)

**PASS, with F1 and F2 open.** The checks below re-run the plan's constitution check:

- **I (specification first)**: the code follows the approved plan, and no amendments were made.
- **II (source of truth)**: no conflict; the contract was followed except where F5 notes otherwise.
- **IV (architecture consistency)**: the reader sits beside `Get-DeveloperMode` and reuses its read guard, root-as-text test and `-ErrorAction Stop`.
- **VI (security)**: engaged by F1. Record text is echoed unfiltered.
- **VIII (testing)**: a Pester table exists and passes. F2 records gaps against T003's stated assertions.
- **IX (human review)**: this review is fresh-context, and gate-6 human review is still due.
- **X (controlled delivery)**: one phase, a `phase 1` subject, and scope-check PASS.
- **III, V, VII**: n/a, as planned.

## Test coverage observed

`tests/enforcement/CoolingOff.Tests.ps1`: **51 passed, 0 failed**. I ran it from a scratch copy of the committed files, with `Set-StrictMode -Version Latest` and Pester 5.7.1. The 51 tests break down as follows:

- 37 table rows. Each asserts `Hours`, `Declared`, `Honored`, the ordered severities, that every problem's `Message` matches `coolingOff` with a non-empty `Fix`, and that `Why` is non-empty and single-line.
- 4 unusable-record rows: root array, root string, unparsable text, empty file.
- Dedicated tests for:
  - the whole-number print (`"4"`, not `"4.0"`);
  - the reason fold and trim;
  - a null reason for `{"coolingOffHours":4}`;
  - the unaccepted-value message naming the field and value;
  - the missing-reason message;
  - a missing record;
  - a directory as the record;
  - nested and quoted keys;
  - two `$ErrorActionPreference` values;
  - the constants' values.

Critical assertions: every rejected shape gives 24, and the root-array row guards the collapse that `Get-DeveloperMode` documents. The gaps are listed in F2: `Reason` is not asserted per row, `Why` content is not checked, and there is no BigInteger or over-2^53 row. The full harness was not run by this reviewer, as instructed. The implementer's notes report 2098 passed and coverage identical to baseline, which I did not verify.

## Residual risk

The risk sits at the seam with phase 2, where `Reason` becomes printed output. F1 lets a record honor a short period with an invisible reason, or suppress its own warning on screen. F2 means a phase 2 change that keys a warning on `Reason` would not be caught by the reader's tests. Both fixes fit inside phase 1's territory (`scripts/adoption-lib.ps1`, `tests/enforcement/**`) and should land before phase 2 consumes the reader. F3 needs an owner decision before phase 3 is written. Everything else is minor. The fail-closed core (unusable means 24) held under every input I could construct.
