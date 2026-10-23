# AI Code Review — 038 Configurable cooling-off period (review fixes and phase 5: the team-mode doctor and the constitution PATCH)

**Reviewer**: fresh-context agent: claude-opus-5-5
**Date**: 2026-10-23
**Branches**: agentic-sdlc-kit `038-configurable-cooling-off` (tip `9328f16`), reviewed as `git diff 40cb039..HEAD`: `c185c0a` (phase 2 review fixes), `0a02f48` (phase 4 review fixes), `5578b7f` (amendments), `c5bace3` (first review and dispositions), `e8b0f86` (tasks Territory), `9328f16` (phase 5)
**Scope reviewed**: `scripts/verify-kit.ps1` (the cooling-off block and the `developers` block it depends on); `scripts/adoption-lib.ps1` (`Get-DeveloperMode` return shapes, `Get-CoolingOff`, the two edited comments); `scripts/enforcement-pack.ps1` (`Invoke-CriticalEvidenceCheck`, `Get-CriticalMergeReadiness` returns, `Invoke-CriticalSoloEvidence`, `Get-EvidenceMode`); `scripts/update-kit.ps1` (surgical report); `kit-manifest.json` (constitution class); every fixture added or moved in the range (`VK-037/*`, `CRIT-C01/fail-review-missing`, `CRIT-C02/fail-review-missing`, `CRIT-S03/fail-record-unreadable`, `CRIT-S03/fail-record-unparsable`) and `tests/enforcement/rules.json`; `.specify/memory/constitution.md` (diff, Principle I Amendment authority, versioning policy, the 0.4.1 entry); `docs/sdlc/critical-delivery.md` item 5; `adoption/updating.md` (the 038 flow-down note and "Declaring the solo cooling-off period"); the amended `spec.md`, `plan.md`, `contracts/kit-adoption-cooling-off.md`, `data-model.md`, `tasks.md`; each commit's message and file list; the earlier review; `notes.md` last.
**Feature contract**: one reader (`Get-CoolingOff`) holds the default (24) and the floor (1) and is the only interpreter; solo verdicts unchanged byte for byte; in team mode a malformed value or a missing reason is a doctor warning, not a failure (amended FR-011, P6); constitution PATCH 0.8.0 to 0.8.1, sync list only; no package, no new script.

## Reviewer Provenance

- **Reviewer**: fresh-context agent: claude-opus-5-5 (launched with the Agent tool's `model: opus`)
- **Implementer**: claude-sonnet-5-5 (the Claude Code session that produced the diff under review)
- **Inputs provided**: the diff `40cb039..HEAD`, spec.md, plan.md, contracts/, data-model.md, tasks.md, CLAUDE.md, the constitution, definition-of-done.md, review-process.md, the earlier review; notes.md read last
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups** (approve with changes; the should-fix items land before merge). The doctor change is correct. I ran it against every combination of mode and declaration I could build: team, solo with no roster, a one-developer roster, and unusable rosters (a string, `[]`, case-insensitive duplicates, an object entry with no name), each with every kind of cooling-off declaration. Solo and unusable-roster projects still FAIL with the reader's fix, byte for byte. Team projects get a WARN and exit 0. The reader's own warnings are untouched. The earlier review's F2, F3 and F4 are resolved in the code and the documents. I mutation-tested F4's pin and it holds. F1 and F5 were built as decided. Nothing is blocking. Four things should be fixed before merge:

- **G1**: the flow-down note now says "Nothing surgical" in the same sentence that announces a change to the constitution, which is a surgical-class file.
- **G2**: the new team-mode text hardcodes the 24-hour default, a second copy of the constant the design says lives only in `adoption-lib.ps1`.
- **G3**: no fixture would fail if the team test were widened to any declared roster.
- **G4**: the earlier F6 contradiction still stands in a contract this range amended under an approver record.

The rest are notes.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | Amended FR-011 / P6: `verify-kit.ps1:304-306`. A `warn` problem stays a WARN. A `fail` problem becomes a WARN only when `$devMode.Mode -eq 'team'`, otherwise it stays a FAIL with the reader's fix. `$devMode` is assigned unconditionally at line 270 in the same block, and `Get-DeveloperMode` always returns `Mode` (`adoption-lib.ps1:93-207`). The pack picks its arm from the same function (`enforcement-pack.ps1:421`), so the doctor's "team" is the pack's "team". **Scratch fixtures** (copies of `VK-037/fail` with the record edited, run through the harness's own `Invoke-FixtureCase` against this checkout): team + `null`, `"48"`, blank reason → one WARN each with the team fix, exit 0. Team + reason only → the reader's unchanged unused-reason WARN. Team + `4` with a reason → `ok` line plus the team WARN. Team with an object entry missing its name (still 2 developers) → roster FAIL, the cooling-off problem as a WARN, exit 1. One developer `["ada"]`, `"developers": "ada, grace"`, `[]`, `["ada","ADA"]`, and no roster, each with `0` → **FAIL** with the solo fix, exit 1. Fail-closed holds. |
| Solo behaviour byte-identical | No `VK-033` file is in the diff. `Run-Tests.ps1 -CI -Case "verify-kit/VK-03"` → **244 passed, 0 failed**. |
| New fixtures discriminate | `VK-037/fail` and `fail-no-reason` run against `scripts/` extracted from `40cb039` (`git archive`, in scratch): both **fail** (output and exit 1); `pass` passes. F4 pin: I moved the reader block (`enforcement-pack.ps1:657-664`) below the missing-review return in a scratch copy, and both `CRIT-C01/fail-review-missing` and `CRIT-C02/fail-review-missing` **fail** (output mismatch). Gap: G3. |
| Pack fixtures | `-Case "enforcement-pack/CRIT-C0"` → 204 passed, 0 failed. `-Case "enforcement-pack/CRIT-S03"` → 180 passed, 0 failed. The two new `CRIT-S03` expectations are identical to `fail-record-root-array`'s. `fail-record-unparsable`'s record carries no reason, so a lenient parser would print a set-aside WARN and fail the case; it discriminates. |
| Feature contract held | No package. No new script. `adoption-lib.ps1` diff is comment lines only (`git diff 40cb039..HEAD -- scripts/adoption-lib.ps1`). One code line was added to `verify-kit.ps1`, and it carries the hardcoded default (G2). |
| Constitution / domain invariants | Constitution diff: version line, new SYNC IMPACT entry, the old top entry relabelled "Prior version history (0.7.0 → 0.8.0):", sync list (one entry added, "Critical cooling-off hours," removed from the `enforcement-pack.ps1` entry), footer 0.8.1. No principle text and no earlier rationale changed. The version agrees in the header, SYNC entry and footer. `git grep 0.8.0` finds only historical references (017 flow-down note, adoption digest, roadmap) that remain correct. PATCH matches the 0.4.1 precedent, which added this very entry as "sync-list bookkeeping only" (`constitution.md:137-141`) and the policy ("PATCH — clarifications, wording, and non-semantic refinements"). No domain-invariants pack. |
| Security | Nothing new is read or printed beyond the reader's existing messages. Earlier F8 (bidi characters in `(read: …)`) is unchanged and recorded. |
| Scope guard | `scope-check.ps1 -Commit c185c0a` → PASS phase 2 (13 files). `-Commit 0a02f48` → PASS phase 4 (2 files). `-Commit 9328f16` → PASS phase 5 (18 files). `enforcement-pack.ps1` on the branch: `AmendmentAuthority: graded 16 of 16 commit(s)`, `enforcement-pack: OK`. It prints `PhaseSizeWarning` for `9328f16` (369 lines / 16 files, above the 15-file guideline; non-blocking, and the extra files are fixtures). |
| Rollback safety | Phase 5 reverts cleanly: one `elseif` line, fixtures, comments, docs. The constitution PATCH reverts as text. No schema. |
| Docs and digests | `doc-lint.ps1` → OK. `build-digests.ps1 -Check` → OK (5 fresh, 124 markers). Statement-by-statement check against the code: G1, G6, G8, G9. |

## Findings

Ranked most severe first. Severity uses the brief's scale; status uses the template's.

### G1 — The 038 flow-down note says "Nothing surgical" while announcing a change to the constitution, a surgical file — should-fix — DOC DRIFT

**Where:** `adoption/updating.md:1579`: "…The kit's own fixtures stay in the kit. Nothing surgical. The kit's constitution takes a **PATCH, 0.8.0 → 0.8.1** … It is never applied by the update."

**Defect:** `kit-manifest.json:10` classes `.specify/memory/constitution.md` as `surgical`. `scripts/update-kit.ps1:262-271` lists every surgical file with upstream commits since the recorded kit commit, and `:297` makes such a report "attention needed" (exit 2, per the header at `:31`). So the update **will** report the constitution as a surgical item. The note tells the adopter there is nothing surgical. The 017 note, the precedent for a constitution change (`updating.md:546-555`), says "**One surgical item is reported, the constitution.**"

**Scenario:** an adopted project takes the update. `update-kit.ps1` exits 2 with a surgical report naming `.specify/memory/constitution.md`. The owner reads the 038 note, sees "Nothing surgical", and has to work out which one is wrong. The sentence was correct before phase 5 and was not revisited when the PATCH was added.

**Evidence:** the lines above (code read; I did not run `update-kit.ps1`).

*Action: implementer, phase 5 Territory (`adoption/updating.md`). Replace "Nothing surgical." with "One surgical item is reported, the constitution:" and keep the existing explanation.*

### G2 — The team-mode fix hardcodes the 24-hour default in `verify-kit.ps1`, a second copy of the constant — should-fix — MINOR

**Where:** `scripts/verify-kit.ps1:305`: `'… and solo the value is set aside and 24 hours applies until it is fixed'`.

**Defect:** plan P2 and the `Get-CoolingOff` header (`adoption-lib.ps1:215-216`: "The default and the floor live HERE and nowhere else … a second constant in either would be a second opinion") forbid this. The new constitution sync entry names only `adoption-lib.ps1` as the place the default must change in lockstep, and T034 says "Do not interpret the record in this script". The pack already reads `$script:CoolingOffDefaultHours` (`enforcement-pack.ps1:658`), and the doctor dot-sources the same library (`verify-kit.ps1:42`). This is the only literal default outside `adoption-lib.ps1` (`grep -n 24 scripts/verify-kit.ps1`).

**Scenario:** I set `$script:CoolingOffDefaultHours = 12` in a scratch copy of `scripts/`. The solo case printed `… — until then 12 hours applies`. The team case on the same scratch copy still printed `… and solo the value is set aside and 24 hours applies until it is fixed`. The two arms of one doctor now disagree about the default, and no fixture would catch it, because every fixture uses 24.

*Action: implementer: build the string from `$script:CoolingOffDefaultHours` (fixture text unchanged at 24).*

### G3 — No fixture distinguishes "team" from "any declared roster": the fail-closed boundary is unpinned — should-fix — MINOR

**Where:** `verify-kit.ps1:305` and the `VK-033` to `VK-037` fixtures. Every solo cooling-off fixture (`VK-033/*`, `VK-034/*`, `VK-036/*`) declares **no** `developers` key. Every fixture with a roster (`VK-035/*`, `VK-037/*`) declares exactly `["ada", "grace"]` (grep of every `recipe.json` carrying both keys).

**Defect:** the decision is "team mode only; solo mode still fails". Nothing tests a solo project that **does** declare a roster: one developer, or an unusable roster that falls back to solo.

**Scenario:** I replaced the condition with `elseif ($devMode.Declared)` in a scratch copy. All 28 `VK-033`…`VK-037` cases still passed (`output=True exit=True` for each). Yet on a `["ada"]` roster with `coolingOffHours: 0`, that mutant prints a WARN and `OK — adoption integrity verified`, **exit 0**, where the real code prints FAIL, exit 1. The same mutant on `"developers": "ada, grace"` demotes the cooling-off failure to a warning. A test that cannot tell these apart does not pin the owner's "solo still fails".

*Action: implementer: add a `VK-033` variant with `"developers": ["ada"]` and an unusable value (FAIL, exit 1). Optionally add one with an unusable roster.*

### G4 — Earlier F6 is still open, in a contract this range amended and approved — should-fix — CONFIRM

**Where:** `contracts/kit-adoption-cooling-off.md:43` ("at any other value it gains `(declared in kit-adoption.json coolingOffHours)`"), against `enforcement-pack.ps1`'s actual message `… requires 4h (declared in kit-adoption.json coolingOffHours; 1 h remaining, …)` (`CRIT-C01/fail`).

**Defect:** commit `5578b7f` amended this contract and added `**Amendment approved by**: anas.m, 2026-10-23`, so the approved text now carries a fresh approval. The clause the earlier review said must not be left disagreeing ("leaving them disagreeing is not [fine]") was not touched. `notes.md` marks F6 "Recorded, not changed … the owner's call", with no decision recorded.

*Action: owner decides before merge. Either amend line 43 to the shipped form (approver record), or change the code. Do not merge with the contract and the code disagreeing.*

### G5 — `e8b0f86` ticks T031 to T038 before the work exists in history — note — MINOR

**Where:** `e8b0f86` ("T031 to T038 are ticked (progress, not amendment)"); the work lands in the next commit, `9328f16`.

**Defect:** at `e8b0f86`, `tasks.md` records T034 and T035 as done, but `git show e8b0f86:scripts/verify-kit.ps1 | grep -c 'correct it before the project goes solo'` → `0`, and `git show e8b0f86:.specify/memory/constitution.md` still reads `0.7.0 → 0.8.0`. This is an artifact of the history rewrite (both commits carry the timestamp 20:04:30). Anyone bisecting or reading the history sees completion recorded before the work. It does not affect the tip.

*Action: none required. If the history is rewritten again, put the ticks in or after the phase commit.*

### G6 — `critical-delivery.md` still says the doctor reports a mistyped value "as a failure", which phase 5 made untrue in team mode — note — DOC DRIFT

**Where:** `docs/sdlc/critical-delivery.md:193` ("…also falls to 24, which is shorter than meant; the doctor reports it as a failure"), with ":The doctor … reports each of these cases" a few lines down. The document is not in phase 5's Territory, so phase 5 could not correct it. `updating.md:1735-1737` does qualify the same statement for team mode.

**Scenario:** team project, `"coolingOffHours": "48"` → my scratch run: `WARN record: … (read: "48") — fix: correct it before the project goes solo…`, exit 0. Not a failure. The paragraph is framed around the solo arm, so the harm is small. But it is a verbatim file, and it now differs from `updating.md`.

*Action: optional, with an approved Territory widening: add "(a warning in team mode, where no period applies)".*

### G7 — In team mode the doctor's `ok` line still says the pack prints a WARN "on every Critical solo check" — note — MINOR

**Where:** `verify-kit.ps1:312`. This was the second half of the earlier F5. The amendment addressed only the FAIL half.

**Scenario:** team + `{"coolingOffHours": 4, "coolingOffReason": "small"}` → my scratch run prints `ok record — … declares 4 hours with a recorded reason: "small" — the pack prints a WARN naming it on every Critical solo check`. The very next line says no cooling-off period applies. The text is literally true, since there are no solo checks in team mode, but it reads as if the period were in force.

*Action: none required. Optionally, in team mode, end the line with "(not applied while the project is in team mode)".*

### G8 — "a typo cannot take the wait under the default" is still broader than the code — note — DOC DRIFT

**Where:** `critical-delivery.md:191-192`; `updating.md:1728-1729`; spec User Story 3 (amended); `adoption-lib.ps1:221`.

**Defect:** the property holds for typos that produce an **unusable** value. A typo that produces a **valid** whole number under 24 is honored whenever a reason is already present. For example, a project that had `4` with a reason and meant to restore `24` types `2`.

**Evidence:** in-process, `Get-CoolingOff` on `{"coolingOffHours": 2, "coolingOffReason": "small features, reviewed same day"}` → `Hours=2 Honored=True Problems=0`. The pack's honored-period WARN does name it on every graded run, so the change is visible, not silent.

*Action: none required. Optionally reword to "an unusable value can never take the wait under the default".*

### G9 — "or the plan says `Merge Readiness: pending` … prints none" is not true once the review is committed — note — DOC DRIFT

**Where:** `updating.md:1581` and `:1724-1726`; `critical-delivery.md:187-189`.

**Defect:** `Get-CriticalMergeReadiness` returns `Pending = $false` as soon as the artifact is committed at HEAD, whatever the plan says (`enforcement-pack.ps1:490-491`). It does the same when `pending` is declared but every task is ticked (`:519`). In both cases the solo arm is graded and the cooling-off WARN **does** print. The phrase "returns before it reads the review" implies there is no review, which softens the claim, but "the plan says pending … prints none" is stated without that condition. The error is in the harmless direction (more output than promised), so this is a note.

*Action: none required. Optionally add "and the review is not yet committed".*

### G10 — The team-mode fix is one generic sentence that drops the specific remedy — note — MINOR

**Where:** `verify-kit.ps1:305`; contract lines 49-50 ("it still names the field, the value read and the fix").

**Defect:** in solo mode the fix says what to write: "write a whole number of hours at or above 1, for example 8", or "add coolingOffReason … or write 24 or more". In team mode every problem gets "correct it before the project goes solo". The reader's message still names the field and the value, so the remedy can be inferred. The no-reason case, however, loses the "or write 24 or more" alternative.

*Action: none required. Optionally prefix the reader's own `Fix` with the team-mode clause instead of replacing it.*

### Status of the earlier review's findings

| Earlier finding | Status at `9328f16` (verified) |
|---|---|
| F1 constitution sync-list wording | **Resolved as decided.** The sync list is corrected. The 0.4.1 history entry (`constitution.md:137-141`, "the Critical cooling-off hours") is left as history, and the new SYNC entry tells the reader how to read it. The flow-down note is updated, but see G1. |
| F2 "a typo can never shorten it" | **Resolved** in both documents, the two comments and the spec. The residual wording is G8. |
| F3 "WARN on every run" | **Resolved** in the three places. The residual edge is G9. The `ok`-line wording the earlier review mentioned is unchanged (G7). |
| F4 ordering pin and unreadable record | **Resolved**: the mutation fails both new cases (above), and the unreadable and unparsable records are covered. |
| F5 team-mode FAIL | **Resolved as decided** for the FAIL half. The `ok`-line half remains (G7). |
| F6 contract clause | **Open** (G4). |
| F7 T011 to T013 ids | **Resolved** by amendment (`5578b7f`, approver record present). |
| F8, F9 | Recorded, unchanged. Acceptable as notes. |

### Areas found sound

- **Doctor logic and strict-mode safety:** every combination listed in the evidence table behaves as specified. `verify-kit.ps1` sets no strict mode, and every property the new line reads (`Severity`, `Message`, `Mode`) exists on every return shape. Output order is: the problem, then the `ok` line if honored, then the team WARN. Exit 0 in team mode unless another FAIL exists.
- **Comments in `adoption-lib.ps1`:** comment-only, accurate.
- **Constitution PATCH:** exactly what it says. PATCH is the right bump by the policy and the 0.4.1 precedent. I see one arguable counter-case and I do not hold it: removing the hours from the "constitutional constants" list means a project can now change them without an amendment, which is a governance effect. The principles never stated the number, so no principle is redefined.
- **Territory and packages:** all three phase commits PASS the scope check. No package.

## Amendments in this diff

- [x] Amendments listed:
  - `5578b7f`: `spec.md` (header record; User Story 3; edge case; FR-011; Assumptions), `plan.md` (Summary; Constitution Check II; P6; P8; Phases item 5, record after the list plus the existing header record at line 8), `contracts/kit-adoption-cooling-off.md` (Doctor WARN bullet; record at top), `data-model.md` (team-mode sentence; record at top), `tasks.md` (T011 to T013 text; Phase 5 added with a record). The commit message carries `**Amendment approved by**: anas.m, 2026-10-23`.
  - `e8b0f86`: `tasks.md` (Phase 5 Territory bullet de-annotated, note moved; record repeated; ticks). The commit message carries the same record.
  - The machine check reads them all: `AmendmentAuthority: graded 16 of 16 commit(s)`, no failure.
  - Every changed text is covered by decisions F1, F2, F5 or F7, except that the contract's F6 clause was left as it was (G4).
  - **Who approved (unverified):** each record names the owner, anas.m. Every commit is authored under the owner's git identity with a `Co-Authored-By: Claude Sonnet` trailer, and the records were written by the implementing session. The repository holds no artifact authored independently by the owner that records these decisions. The decisions are consistent with the earlier review's "owner decides" actions, and `notes.md` attributes them to the owner's instruction in session. Whether the owner actually decided cannot be shown from the repository. The constitution says as much ("It cannot verify that the named person agreed"). Gate 6 is where this is confirmed.

## Constitution re-check (post-implementation)

**PASS, with G4 open.**

- **I (Specification First, Amendment authority):** amendments are recorded and machine-graded. Self-approval cannot be judged from the repository (see above).
- **II (Source of Truth):** the F1 conflict is resolved by the PATCH. The contract and the code still disagree on F6 (G4).
- **IV:** the single-reader architecture is kept, except for G2's literal.
- **VIII (Testing):** the new behaviour has fixtures shown failing on the parent. The coverage gap is G3.
- **IX and X:** phase 5 is committed and scope-checked PASS. Per `notes.md`, the review-fix commits and phase 5 are **not yet owner-gated**; that gate is owed before merge.
- **III, V, VII:** n/a.

## Test coverage observed

- `VK-037` (3 cases): team + `0` with a reason (WARN, exit 0), team + `4` with no reason (WARN, exit 0), team + `48` control. The two "fail" cases fail on the parent's doctor.
- `VK-035/fail-unaccepted-value` was removed. Its scenario is `VK-037/fail`. The `VK-035` rules note is updated accordingly.
- `CRIT-C01/fail-review-missing` and `CRIT-C02/fail-review-missing` pin plan P5's ordering (mutation-verified).
- `CRIT-S03/fail-record-unreadable` (a directory) and `fail-record-unparsable` cover the unreadable record in the pack.
- Runs I made: `-Case "verify-kit/VK-03"` 244/0. `-Case "enforcement-pack/CRIT-C0"` 204/0. `-Case "enforcement-pack/CRIT-S03"` 180/0. Doc-lint OK. Digests OK. Scope check PASS ×3. Enforcement pack OK.
- I did not run the full harness (per instructions). The `notes.md` totals (2226, 2230) are unverified by me.
- **Not covered:** a solo project with a declared roster or an unusable roster plus an unusable cooling-off value (G3); any default other than 24 (G2).

## Residual risk

The behaviour is right. The risk is in what adopters are told and in what the tests would miss. Before merge:

1. Correct "Nothing surgical" (G1). It is a verbatim document, and it contradicts what `update-kit.ps1` will print.
2. Derive the team-mode text from `$script:CoolingOffDefaultHours` (G2).
3. Add a one-developer-roster solo fixture (G3).
4. The owner rules on F6 / G4 with a recorded amendment or a code change.
5. The owner gates the review-fix commits and phase 5. Gate 6 confirms the owner decisions recorded in `5578b7f` and `e8b0f86`.

G5 to G10 need nothing for merge.
