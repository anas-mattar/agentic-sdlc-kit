# AI Code Review — 038 Configurable cooling-off period (phases 2 to 4: the check, the doctor, the guidance)

**Reviewer**: fresh-context agent: claude-opus-5-5
**Date**: 2026-10-23
**Branches**: agentic-sdlc-kit `038-configurable-cooling-off` (tip `40cb039`, reviewed as `git diff 633d63c..HEAD`: phase commits `942d7b5`, `fa7f412`, `527c099`; notes-only commits `24e1d40`, `7443fa7`, `40cb039`)
**Scope reviewed**: `scripts/enforcement-pack.ps1` (`Invoke-CriticalSoloEvidence`, the `$Config` block, the header comment, and the caller `Invoke-CriticalEvidenceCheck` read to see when the solo arm is reached); `scripts/verify-kit.ps1` (the new block and the dimension-4 code around it); `scripts/adoption-lib.ps1` `Get-CoolingOff` (phase 1, read only to judge how the callers use it); every new fixture under `tests/enforcement/cases/enforcement-pack/` (CRIT-C01, CRIT-C02, the CRIT-S03 and CRIT-T01 variants) and `tests/enforcement/cases/verify-kit/VK-033` to `VK-036` (expected output, exit codes, the recipes that matter); `tests/enforcement/rules.json` diff; `docs/sdlc/critical-delivery.md` item 5, `adoption/updating.md` (all four hunks), `docs/digests/critical-digest.md`; `kit-manifest.json` (to check the flow-down claims); `.specify/memory/constitution.md` (the cooling-off mentions); `tasks.md` diff. `notes.md` read last.
**Feature contract**: one reader (`Get-CoolingOff`) used by both the check and the doctor; default 24, floor 1; under 24 needs a non-blank reason and always warns; every unusable shape gives 24; a WARN never changes the exit code; the team arm, the clock and the default message unchanged byte for byte; no package, no new script, no constitution amendment.

## Reviewer Provenance

- **Reviewer**: fresh-context agent: claude-opus-5-5 (launched with the Agent tool's `model: opus`)
- **Implementer**: claude-sonnet-5-5 (the Claude Code session that produced the diff under review)
- **Inputs provided**: the diff `633d63c..HEAD`, spec.md, plan.md, contracts/, data-model.md, tasks.md, CLAUDE.md, the constitution, definition-of-done.md, review-process.md; notes.md read last
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**Approve with changes** (template wording: APPROVE with follow-ups, where the follow-ups below land before merge). The code does what the spec asks. `Invoke-CriticalSoloEvidence` applies `Get-CoolingOff`'s period and prints the two WARNs. The default message stays byte-identical. The team arm is not edited and never reaches the reader. The doctor reports every case through the same reader. Every fixture that existed before the feature passes with its `expected.txt` unedited. I found no blocking defect in the scripts. The problems are elsewhere. The guidance makes two claims the code does not back (F2, F3). The ordering decision in plan P5 has no fixture that would fail if it were reverted (F4). The constitution still calls the cooling-off hours a constitutional constant held in `scripts/enforcement-pack.ps1`, and the plan's "no amendment needed" check overlooked that wording. The owner needs to rule on it before merge (F1). The implementer did disclose it in `notes.md`. The other findings are notes.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-001/006/007/008: `enforcement-pack.ps1` lines 657-664 call the reader and print the honored WARN (below 24) or the set-aside WARN (`-not Honored`); lines 685-691 compare against `$period.Hours` and add the clause only when `Hours -ne 24`. FR-003/005 in the pack: CRIT-C02's 13 cases (no, blank or numeric reason; `0`, `-3`, `1.5`, `"8"`, `true`, `null`, `[]`, `{}`) sit at 23.5h with the unchanged 24h message, or at 25h passing with the WARN. These discriminate: a period wrongly honored at 4h would pass the 23.5h cases. FR-004: `CRIT-S03/fail-record-root-array` declares `[{"coolingOffHours": 2, ...}]` at 23.5h and expects the default failure. FR-010: `Invoke-CriticalTeamEvidence` is absent from the diff, and both `CRIT-T01/*-cooling-keys-ignored` records declare 2h with a reason, so any reader call on the team path would add a WARN line and fail the case. FR-011: VK-033 to VK-036 (26 cases). Ran `Run-Tests.ps1 -CI -Case "enforcement-pack/CRIT-C0"`: 200 passed, 0 failed. Ran `-Case "verify-kit/VK-03"`: 240 passed, 0 failed. Gaps: F2, F3, F4. |
| Visual-reference match | n/a: no UI. |
| Feature contract held (no unapproved table/migration/permission/package) | `git diff --name-status 633d63c..HEAD`: the only modified (`M`) files are the three docs, the two scripts, `rules.json`, `notes.md` and `tasks.md`. Every fixture file is `A`, so no pre-existing `expected.txt` was edited (SC-004). No package and no new script. `grep CoolingOffHours` finds no remaining `$Config.CoolingOffHours` reader in `scripts/`. |
| Constitution / domain invariants | See F1: `.specify/memory/constitution.md` lines 119-123 and 194-198. No domain-invariants pack exists. |
| Security (authn/authz, secrets, sensitive logging) | Nothing sensitive is read. Record text reaches output through `Reason` (sanitized in phase 1) and the set-aside `(read: …)` excerpt, which is not sanitized for bidi or format characters (F8, cosmetic). |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | `scope-check.ps1 -Commit 942d7b5` gave PASS phase 2 (82 files). `-Commit fa7f412` gave PASS phase 3 (82 files). `-Commit 527c099` gave PASS phase 4 (5 files). Each phase commit touches only its Territory plus the implicit `specs/038-…/**`. |
| Rollback safety (phase reverts cleanly; schema additive?) | Phase 4 is documents only. Phase 3 is one additive block. Reverting phase 2 removes the reader call but would leave no `$Config.CoolingOffHours`. Plan's phasing rule covers this: phase 2's revert restores it, since it is the same commit. No schema. |
| Docs and digests | `doc-lint.ps1`: OK. `build-digests.ps1 -Check`: OK, 5 digests fresh, 124 markers. The flow-down "Verbatim" list matches `kit-manifest.json` (`scripts/*.ps1`, `docs/sdlc/critical-delivery.md`, `adoption/**` are `verbatim`; digests are `generated`). |

## Findings

Ranked most severe first. "Severity" uses the brief's scale (blocking, should-fix, note); "status" uses the template's.

### F1 — The constitution still names the cooling-off hours a constitutional constant held in `enforcement-pack.ps1` — should-fix — CONFIRM

**Where:** `.specify/memory/constitution.md` lines 119-123 (0.4.1 rationale: `scripts/enforcement-pack.ps1` "encodes constitutional constants (the batch-phase cap …, the Critical cooling-off hours) that MUST change in lockstep with any amendment touching them") and lines 194-198 (the present-tense "Templates requiring updates" list, same wording). Against: `plan.md` Constitution Check II and spec Assumptions ("mentions 24 hours only in a historical bump rationale").

**Defect:** the constitution classifies the cooling-off hours as a *constitutional constant*, yet the feature turns it into a project setting that can go down to 1 hour, moves it into `scripts/adoption-lib.ps1` (which the sync list does not name), and does so without an amendment. The plan's determination rests on a reading that missed this wording.

**Scenario:** a maintainer later amends the Critical independence rule and follows the sync list to `enforcement-pack.ps1`. Line 164 there now says the period is not in that file. Meanwhile, `adoption-lib.ps1`, which actually holds the default, is not on the list. Separately, an adopted project's ratified constitution carries the same sync-list wording (`kit-manifest.json` classes the constitution `surgical`), and after the update it describes a constant that the project itself can now set.

**Evidence:** I read the lines quoted above. `notes.md` (Phase 4, T024 item (1), and its last line) discloses line 195 and calls it a "stale pointer, a bookkeeping matter", left for the owner. That handled the CLAUDE.md conflict rule correctly (stop and report). It does not settle the question: the 0.4.1 rationale calls the value a constitutional constant, not only a file location.

*Action: the owner rules before merge. Either amend the sync list (name `scripts/adoption-lib.ps1` and say the hours are a project-declared value with a kit default and floor), recorded with an approver per constitution I, or record in `plan.md` why "constitutional constant" does not cover the default. Do not leave it as an open note at merge.*

### F2 — The docs say every fallback lands on the longer wait; for a value meant to be above 24, the fallback is shorter — should-fix — DOC DRIFT

**Where:** `docs/sdlc/critical-delivery.md` line 187 ("every fallback lands on the longer wait, so a typo can never shorten it"); `adoption/updating.md` line 1726 ("Every fallback lands on the **longer** wait, so a typo cannot shorten it"). The same claim is in phase 1's `scripts/adoption-lib.ps1` line 221 ("one that mistypes it can only ever get the longer wait").

**Defect:** the claim holds only when the intended value is under 24. A project that meant a stricter period and mistyped it gets 24, which is shorter than what it declared. The pack then passes, with only a WARN.

**Scenario:** I built a scratch fixture from `CRIT-S03/fail-declared-48` (review 30.5 hours old) with the record changed to `{"coolingOffHours": "48"}`, and a second with `{"coolingOffHours": 48.5}`. I ran both through the harness's own `Invoke-FixtureCase` against this checkout. Result for both: **exit 0, `enforcement-pack: OK`**, with `WARNING: CriticalEvidence: kit-adoption.json coolingOffHours is not a whole number of hours of at least 1 (read: "48") - the 24h default applies instead …`. With a correctly typed `48`, the same review fails (`CRIT-S03/fail-declared-48`). So a typo shortened the wait from 48 to 24.

The code matches spec FR-003, which says 24. The guidance overstates the safety property to adopters, in a verbatim file every adopted project receives. The doctor does catch it as a FAIL, but the pack (the merge gate) does not.

*Action: implementer, in phase-4 Territory: reword both doc sentences to "every fallback lands on the 24-hour default, so a typo can never take the wait below 24 hours". Optionally fix the phase-1 comment in a later change, since it is outside phase 4's Territory. If the owner wants "never shorter than declared", that is a spec change.*

### F3 — The docs say the honored-period WARN prints on every run, including when the review does not exist yet; mid-feature it does not print — should-fix — DOC DRIFT

**Where:** `adoption/updating.md` line 1581 ("a period under 24 prints one on every run, whether or not the review exists yet"); line 1722 ("every run of `scripts/enforcement-pack.ps1` prints a `WARN` naming the period"); `docs/sdlc/critical-delivery.md` line 196 ("The warning is printed on every run"). Related wording in the doctor's `ok` line (`verify-kit.ps1` line 308, "on every Critical solo check").

**Defect:** the WARN is printed only inside `Invoke-CriticalSoloEvidence`. `Invoke-CriticalEvidenceCheck` returns before calling it whenever the branch is mid-feature or the plan declares `Merge Readiness: pending` (`enforcement-pack.ps1` lines 620-639), and it never runs on a non-Critical branch or on `main`. So for most of a Critical feature's life, and at exactly the time the review is not there, no period WARN prints.

**Scenario:** a scratch fixture with a solo Critical feature, `tasks.md` with `## Phase 1` and `## Phase 2`, a `phase 1:` commit, no `second-model-review.md`, and `{"coolingOffHours": 4, "coolingOffReason": "small"}`. Harness output: exit 0, one line `WARNING: CriticalEvidence: specs/001-thing/second-model-review.md is not yet due - the branch is at phase 1 of 2 …`, and **no** cooling-off WARN. This contradicts "whether or not the review exists yet". With the final phase landed and no review (second scratch case), the WARN does print, before the "is missing" failure. So the narrower claim, "whenever the solo arm is graded", is true.

SC-003 itself is met: no run that *applies* a short period omits the warning. The defect is that the guidance's "every run" is the audit property P9 leans on ("the warning prints on every run … gate 6 is where it is caught"). A reviewer reading a mid-feature CI log sees nothing about the shortened period.

*Action: implementer, phase-4 Territory: replace "every run" with "every run that grades the solo arm (from the final phase, or once the review is committed)" in the three places. Owner: decide whether P9's reliance on the warning needs the doctor's `ok` line named as the always-on trace instead.*

### F4 — No fixture pins plan P5's ordering (WARN before the missing-review return); T011's unreadable-record pack case is absent — should-fix — MINOR

**Where:** `enforcement-pack.ps1` lines 654-664 (the call is deliberately placed before the missing-file return, per P5 and T015). Every new pack fixture.

**Defect:** every `CRIT-C01` and `CRIT-C02` recipe commits `second-model-review.md`. I checked: a grep over all 19 `CRIT-C0*/*/recipe.json` finds the file in each one. So moving the `Get-CoolingOff` block below the `if (-not (Test-Path $reviewPath)) { … return }` would pass every fixture, and the documented behavior ("even when the review is missing", the code comment at line 655 and `updating.md` line 1581) would silently disappear.

The behavior is correct today: my scratch case "B" (honored 4h, final phase landed, no review) printed the WARN and then the `is missing` failure, exit 1. Separately, T011 asked for "an unreadable record" pack variant beside the root-array one. Only the root array exists in the pack fixtures; the directory-named-`kit-adoption.json` case is covered only by the phase 1 Pester table.

*Action: implementer: add a `CRIT-C01` variant with no review committed (expect the honored WARN and the `is missing` failure, exit 1). Optionally add an unreadable-record `CRIT-S03` variant, or record why the Pester row suffices.*

### F5 — In team mode the doctor FAILs an inert setting and says "24 hours applies", which is false there — note — CONFIRM

**Where:** `verify-kit.ps1` lines 299-303 (the reader's problems are reported as-is) and 312-314 (team WARN). Fixture `VK-035/fail-unaccepted-value`, `exitCode: 1`.

**Defect:** with two developers and `coolingOffHours: 0`, the doctor prints `FAIL record: … (read: 0) — fix: … until then 24 hours applies` and exits 1. Its own next line says no cooling-off period applies in team mode. The adoption doctor runs in adopted-project CI (`ritual-checks`), so a team project goes red over a key no check reads. FR-011 asks that each report "state the period that applies", and in team mode that is none. Similarly, `VK-035/fail` prints an `ok` line ending "the pack prints a WARN naming it on every Critical solo check" right before saying the setting has no effect.

This is defensible as fail-closed: the record may return to solo. But the period stated is wrong for the mode the project is in.

*Action: owner decides: keep it (and accept the misstatement), or in team mode report the reader's FAILs as WARNs, or suffix them with "(no effect while the project is in team mode)". Any change is a plan P6 amendment.*

### F6 — The failure-message clause differs from the approved contract text — note — DOC DRIFT

**Where:** `contracts/kit-adoption-cooling-off.md` line 41 and `plan.md` P5 line 99 say the message "gains `(declared in kit-adoption.json coolingOffHours)`". The code (`enforcement-pack.ps1` line 689-690) instead inserts `declared in kit-adoption.json coolingOffHours; ` inside the existing parenthesis, giving `… requires 4h (declared in kit-adoption.json coolingOffHours; 1 h remaining, docs/sdlc/critical-delivery.md item 5)` (CRIT-C01/fail).

FR-008 is met, and the default message is byte-identical (CRIT-S03/fail and fail-declared-24 unchanged). The approved contract's literal text is not what shipped, and `notes.md` describes the deviation without an approver record.

*Action: owner accepts the shipped form and the contract is amended with an approver line, or the code is changed to match. Either is fine; leaving them disagreeing is not.*

### F7 — `tasks.md` T011 to T013 are ticked but name rules that do not exist — note — DOC DRIFT

**Where:** `tasks.md` lines 49-51 (`CRIT-C03`, `CRIT-C04`, `CRIT-C05`, all `[x]`).

**Defect:** the cases were folded into `CRIT-C02` (unaccepted shapes), `CRIT-S03` variants (48 at 30.5h and 48.5h rather than 30h and 49h; a root array) and `CRIT-T01` variants (team arm). This falls within the tasks' "ids are provisional" note and is recorded in `notes.md` (Phase 1, "Two deviations"; Phase 2). The ticked task text still describes artifacts nobody can find by id, and T011's unreadable-record case was not built (F4).

*Action: none required for merge; optionally add one line under T011 to T013 pointing to where each case lives.*

### F8 — The set-aside message echoes bidi and format characters from a string value — note — MINOR

**Where:** `adoption-lib.ps1` lines 307-309 (phase 1). The text reaches the pack WARN (`enforcement-pack.ps1` line 661) and the doctor FAIL.

**Scenario:** `{"coolingOffHours": "‮84‬"}`. I ran `Get-CoolingOff` in-process: the message contains code points 8238 and 8236 (U+202E, U+202C), unescaped. `ConvertTo-Json` escapes control characters but not these. Phase 1's F1 sanitized the *reason* for this reason, but the `(read: …)` excerpt was not sanitized. Impact is cosmetic: the value is set aside to 24 whatever it renders as.

*Action: optional: apply the same `\p{Cf}` strip to `$shown` in a later change (phase 1 Territory).*

### F9 — "adoption record valid" prints beside a cooling-off FAIL — note — MINOR

**Where:** `verify-kit.ps1` line 341-343. The condition ignores the cooling-off, developers and surfaces problems.

**Scenario:** every `VK-033/fail*` expected output contains both `FAIL record: kit-adoption.json coolingOffHours …` and `ok record — adoption record valid`. This pattern predates 038 (the roster's FAILs behave the same way), and the exit code is still 1, so it is not a regression.

*Action: none for this feature.*

### Areas found sound

- **Team arm unchanged:** `Invoke-CriticalTeamEvidence` is not in the diff, and the reader is called only inside `Invoke-CriticalSoloEvidence`. The `CRIT-T01` variants would catch a leak (see the evidence table).
- **Byte-identical default:** at `Hours -eq 24` the `$source` clause is empty and the WARN branches are skipped (`Honored` is true and `Hours` is not below 24). `CRIT-S03/fail` and `/pass` are unedited, and `fail-declared-24` and `pass-declared-24` expect the identical text.
- **Clock unchanged:** the `git log --follow --format=%aI` read and `Select-Object -Last 1` are untouched (FR-009). No new fixture exercises a revised review under a declared period, but the code path is the same one the old fixtures cover.
- **Reader used correctly:** the pack reads `Hours`, `Honored`, `Reason` and the `fail` problem. Every `Honored = $false` return in `Get-CoolingOff` adds exactly one `Severity = 'fail'` problem, so `$setAside` is never `$null`. The doctor gates on `AnyDeclared`, prints the `ok` line only when `Declared -and Honored`, and never interprets the record. No `$Config` remnant remains.
- **Strict mode and errors:** `Get-CoolingOff` always returns `Severity` and never throws on missing, unreadable or malformed records (phase 1). The pack runs with `$ErrorActionPreference = 'Stop'`, and every new property it reads exists on every return shape.
- **Digest:** the item 5 marker was rewritten, and `critical-digest.md` changed by one line, consistent with a build (`-Check` OK).

## Amendments in this diff

- [x] **None.** `git diff 633d63c..HEAD` touches no `spec.md`, `plan.md`, `contracts/` or `data-model.md`. The `tasks.md` changes are checkbox ticks for T008 to T029 (and T023 ticked in `7443fa7`), with no text change. The plan, tasks and data-model amendments (approved by anas.m, 2026-10-23) were made in phase 1 (`633d63c`) and are outside this review's diff.

## Constitution re-check (post-implementation)

**PASS, with F1 open for the owner.** I (Specification First): code follows the approved spec and plan. The deviations (F6, F7) are disclosed in `notes.md` but not approver-recorded. II (Source of Truth): F1 is a constitution-level wording conflict, reported by the implementer and not yet resolved. IV (Architecture): the reader sits beside its siblings, with no new pattern. VI (Security): nothing sensitive (F8 is cosmetic). VIII (Testing): failing and passing cases exist per new emission site. The coverage gap is F4. IX and X (Human Review, Controlled Delivery): four phases, each committed, scope-checked PASS and owner-gated per `notes.md`. This fresh-context review precedes gate 6. III, V and VII: n/a.

## Test coverage observed

- **Pack, `CRIT-C01` (6 cases):** honored 4h at 4.5h (pass) and 3.5h (fail, with clause); the 1h floor either side; `4.0` printed as `4h`; a reason with a line break printed on one line. Each expects the honored WARN with the quoted reason.
- **Pack, `CRIT-C02` (13 cases):** set-aside WARN for no, blank or numeric reason and for 8 unaccepted shapes. The fails at 23.5h prove 24 applied (a wrongly honored 4h would pass); the passes at 25h prove the WARN never fails a run.
- **Pack, `CRIT-S03` (5 new variants):** declared 24 either side (byte-identical text, no WARN), declared 48 at 30.5h (fail, with clause, no WARN; discriminates against a 24h fallback) and 48.5h, and a root-array record.
- **Pack, `CRIT-T01` (2 new variants):** team arm with 2h plus a reason, output identical to the unmodified pair.
- **Doctor, `VK-033` to `VK-036` (26 cases):** FAIL per unusable shape and per missing, blank or non-string reason; unused-reason WARN (alone, and on 48); team-mode WARN (with a short period, with 48, with an unusable value); the `ok` line (short, 48, explicit 24, `4.0`, line break, singular "1 hour"); two neither-key controls printing nothing new.
- **Runs I made:** `-Case "enforcement-pack/CRIT-C0"`: 200 passed, 0 failed. `-Case "verify-kit/VK-03"`: 240 passed, 0 failed. `doc-lint.ps1`: OK. `build-digests.ps1 -Check`: OK. `scope-check.ps1` PASS on all three phase commits. The full harness was not run (per instructions). `notes.md`'s full-harness totals (2166, 2218, 2218, 0 failed) are unverified by me.
- **Not covered:** see F4 (review missing under a declared period; unreadable record in the pack). `VK-036/fail-floor-1h` was never shown failing on the parent (disclosed in `notes.md`).

## Residual risk

The scripts are sound, and the default path is protected by unedited fixtures. The risk sits in what adopters are told and in governance bookkeeping. Before merge:

1. The owner rules on F1 (constitution sync-list wording), with a recorded approver if the constitution is touched.
2. Fix the two doc overclaims (F2, F3) in `critical-delivery.md` and `updating.md`, both verbatim files that flow to every adopted project.
3. Add the missing-review `CRIT-C01` variant (F4).

F5 and F6 are owner decisions that can be recorded rather than coded. F7, F8 and F9 need nothing for merge.
