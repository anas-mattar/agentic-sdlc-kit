# AI Code Review — 025 Critical merge-ready signal, phase 1

**Reviewer**: fresh-context agent, Claude Opus 5.5 (claude-opus-5-5)
**Date**: 2026-10-14
**Branches**: kit repository `025-critical-merge-ready-signal` (phase 1 commit `003c96a`, parent `890b5e4`; branch tip at review start `003c96a`)
**Scope reviewed**: `git show 003c96a`: `scripts/enforcement-pack.ps1` (`Get-CriticalMergeReadiness`, `Invoke-CriticalEvidenceCheck`, the new header comment), `tests/enforcement/rules.json` (CRIT-R01 anchor, new CRIT-R03), every new case directory (`CRIT-R03/*` x11, `CRIT-R02/fail-marker-*` x3, `AMEND-001/*merge-readiness*` x3: recipe, command, expected all read), `specs/025-critical-merge-ready-signal/notes.md`. Also read: spec.md, plan.md (D1-D9, Risks), tasks.md, `Get-VisibleFromText`, `Get-VisiblePlanLines`, `Invoke-AmendmentAuthorityCheck` (lines 1617-1756), `specs/014-amendment-authority/plan.md` D7, `tests/enforcement/emission-idioms.json` header, `docs/sdlc/review-process.md` (AI review section), the review template, `specs/024-critical-branch-not-red/ai-code-review-phase-1.md` for shape. Not read: phase 2 territory (not in this commit), `ritual-checks.ps1`, the full harness output (not run, per instructions).
**Feature contract**: option A. A Critical `plan.md` may declare `**Merge Readiness**: pending | ready`, read from the committed blob at `HEAD`; `pending` overrides feature 024's heuristic toward the WARN (but never past a committed artifact), `ready` hands over to the arm, malformed is strict with a reason, absent is feature 024 byte for byte. Arms and `Invoke-AmendmentAuthorityCheck` unedited; no new script, library, package or recipe field. Changing the marker is claimed to be a recorded, approver-carrying plan amendment.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5) session
- **Inputs provided**: the phase 1 diff (`git show 003c96a`, parent `890b5e4`); specs/025-critical-merge-ready-signal/{spec.md, plan.md, tasks.md, notes.md}; scripts/enforcement-pack.ps1 (Get-CriticalMergeReadiness, Invoke-CriticalEvidenceCheck); tests/enforcement/rules.json; the new fixture cases under tests/enforcement/cases/enforcement-pack/{CRIT-R03, CRIT-R02/fail-marker-*, AMEND-001/*merge-readiness*}; docs/sdlc/review-process.md; specs/_templates/ai-code-review-template.md; specs/024-critical-branch-not-red/ai-code-review-phase-1.md (for shape)
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES.** The parsing side holds up. Every misreading I tried came out as the correct state or the strict one: CRLF, trailing whitespace, a trailing `<!-- -->` comment, a case variant (`Pending`), a code span, a multi-line comment, a fence, two lines, an empty value, and a Standard feature. The order of steps is right: a committed artifact still wins over `pending`. All 79 `CRIT-` cases pass on `003c96a`, including the 34 feature 024 cases, which the commit leaves byte-identical. The notes.md table of parent results reproduces exactly. Two problems block the merge.

- **F1, the feature's safety claim.** The marker's value rests on "changing it is a recorded amendment". I added `**Merge Readiness**: pending` to an approved plan inside a merge commit, with no approver record. AmendmentAuthority skips merge commits (014 D7), so the branch went from feature 024's strict FAIL to `OK` with exit 0. The new warning then told the reader the declaration is "a recorded plan amendment", which was false. FR-006 says that where the check does not reach the line, the feature "MUST say so and extend it, not assume".
- **F2, a fixture that measures nothing.** The two committed comment fixtures (FR-001, "comments hide it") still pass with the visibility reader removed. FR-007 requires a fixture per FR that measures something.

Both fixes are small. Residual risk after them sits in the disclosed `pending`-left-in-place cost (spec option A) and in gate 6.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | **FR-001**: read from `git show "HEAD:./specs/$Branch/plan.md"` (line 362), through `Get-VisibleFromText` + `Get-FencedLineMap` (364-365), anchored `^\*\*Merge Readiness\*\*:` (368). Experiments in a scratch clone (`-Case CRIT-R03/x`, 4 throwaway cases, all passed on `003c96a`): multi-line `<!--\n**Merge Readiness**: pending\n-->` → absent → strict; `` `**Merge Readiness**: pending` `` → absent → strict; `pending   <!-- pending \| ready -->   ` → pending, WARN, exit 0; `Pending` → strict with `'Pending', which is neither pending nor ready`. CRLF/tab/trailing spaces: `pwsh -Command` regex test returned `[pending]` / `[ready]`. **FR-002**: `pending` returns `Declared=$true` (378); one WARN per arm (455, 457); the committed-artifact step (355-356) runs first. `CRIT-R03/fail-artifact-committed-invalid-under-pending` shows it. **FR-003**: `ready` returns `@{Pending=$false;Why=$null}` (377) → arms run unchanged (`CRIT-R03/fail`, `fail-solo-arm`). **FR-004**: absent/hidden/unreadable falls through. The added block emits nothing on that path (code read: assignments only, `2>$null`). `-Case CRIT-` on `003c96a`: 79 cases, 200 assertions, 0 failed. `git show --stat` shows no pre-existing case file changed. Malformed: `CRIT-R02/fail-marker-{two-lines,unknown-value,empty-value}`. **FR-005**: `Invoke-CriticalEvidenceCheck` returns at line 448 before the reader. Control fixture `pass-standard-feature-ignores-marker`. **FR-006**: see F1 (merge commits not reached). Non-merge commits are reached (`AMEND-001/fail-merge-readiness-flip-unapproved`: the only change is the marker line, and it fails). **FR-007**: see F2, F3. **FR-008/009**: phase 2, not in scope. |
| Visual-reference match | N/A: no UI, no visual references. |
| Feature contract held | Diff read: arms (`Invoke-CriticalSoloEvidence`, `Invoke-CriticalTeamEvidence`), signature of `Get-CriticalMergeReadiness`, and `Invoke-AmendmentAuthorityCheck` untouched. No new script, library, package, recipe field (`FixtureRepo.psm1` unchanged in the diff). `emission-idioms.json` untouched (see F6). |
| Constitution / domain invariants | See re-check below. Domain-invariants slot unfilled in the kit. |
| Security (authn/authz, secrets, sensitive logging) | Reads a committed blob; echoes only the marker's value (quoted) in the strict reason. No secrets. The security-relevant surface is the approval bypass in F1. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | `pwsh -NoProfile -File scripts/scope-check.ps1` in a scratch clone at `003c96a`: `scope-check: PASS phase 1 commit 003c96a (54 file(s))`, exit 0. Territory (`scripts/enforcement-pack.ps1`, `tests/**`) plus `notes.md` covers all 54 files. `enforcement-pack.ps1` on the branch: OK, with `PhaseSizeWarning` 1727 lines / 54 files (F8). |
| Rollback safety (phase reverts cleanly; schema additive?) | Additive block + two emission sites + new fixtures + one anchor string. Reverting `003c96a` restores the parent exactly. No schema or data. |

## Findings

### F1 — An unapproved `pending` added in a merge commit turns a strict FAIL into OK, and the warning calls it "a recorded plan amendment" — BLOCKING

`Invoke-AmendmentAuthorityCheck` skips every commit with more than one parent (`scripts/enforcement-pack.ps1` line 1685, `# D7: merge commit authored nothing`; rationale `specs/014-amendment-authority/plan.md` D7). An "evil merge" does author content.

Reproduction in `<scratchpad>/evil`, run with `pwsh -File <scratch clone of 003c96a>/scripts/enforcement-pack.ps1 -Branch 001-thing -Root <evil>`:
1. A Critical `001-thing` with a 2-phase `tasks.md` and the AmendmentAuthority boundary stub.
2. A `tasks: phase 2 done` commit, which feature 024 reads as final-landed and strict.
3. `git merge --no-ff --no-commit main`, then `**Merge Readiness**: pending` inserted into the approved `plan.md`, committed as `merge main`. No approver record anywhere.

Output: `AmendmentAuthority: graded 1 of 3 commit(s) ... (2 not graded: 1 merge commit(s); ...)`, then `WARNING: CriticalEvidence: ... declares **Merge Readiness**: pending (the owner's declaration, a recorded plan amendment) ...`, then `enforcement-pack: OK`, exit 0.

Before this feature, a silent plan edit in a merge changed no machine verdict on a Critical branch. Now it relaxes CriticalEvidence. The spec's US2 ("cannot be done by the agent alone") and FR-006 ("If the check does not reach a plan header line, this feature MUST say so and extend it, not assume") rest on the amendment check. Notes T002 concludes "the existing check does reach a plan header line" from non-merge fixtures only.

*Action: implementer, with the owner deciding the route, before merge. Either (a) extend the amendment grading to a merge commit's own changes to spec documents, for example where the merge result of `plan.md` differs from every parent. That edits `Invoke-AmendmentAuthorityCheck`, which plan D5 / T004 permit only via a plan amendment with an approver record. Or (b) have the owner accept the limit in writing: a plan amendment recording it as a known gap, beside the `pending` cost in Risks, plus rewording the warning so it does not assert "a recorded plan amendment" as fact (e.g. "a plan amendment that must carry a recorded approver"). Add an AMEND-001 or CRIT-R03 fixture for whichever route is taken. The fixture lib's `merge` field currently builds content-less merges only (`FixtureRepo.psm1` lines 201-206), so (a) needs a recipe field and its self-test.*

### F2 — The committed comment fixtures do not measure the visibility reader; FR-001's "comments hide it" is unproven — BLOCKING

`CRIT-R03/fail-marker-in-comment-is-absent` and `pass-marker-in-comment-falls-back-to-heuristic` put the marker on one line, `<!-- **Merge Readiness**: ... -->`. That line starts with `<!--`, so the `^\*\*Merge Readiness` anchor already rejects it without any comment stripping.

Mutation run in a scratch clone: replacing `@(Get-VisibleFromText -Lines $planBlob)` with `@($planBlob)` and running `-Case comment` (14 cases). Both committed comment cases still passed. Only my throwaway multi-line-comment and trailing-comment cases failed (4 assertions).

By contrast, removing the fence test (`-not $planFenced[$i]`) is caught by `fail-marker-in-fence-is-absent`, which is good. FR-007 requires the FR-001 fixtures to measure something, and feature 024's T009 lesson was green fixtures that tested nothing.

*Action: implementer adds a variant with the marker inside a multi-line comment block (`<!--` / marker / `-->` on separate lines). Ideally also add one where the visible line carries a trailing comment (`pending <!-- pending | ready -->`), which the mutation also breaks. Show both failing under the mutation and record that in notes.md.*

### F3 — Case sensitivity and the code-span rule have no fixture — MINOR

Removing `-CaseSensitive` from the `switch` (line 376) is caught by no committed case. Only my throwaway `Pending` case failed under that mutation (`-Case CRIT-R03/x`: 2 failed). FR-001 names code spans and D1 says "value compared exactly". The code is correct on both (experiments above), but neither is pinned.

*Action: add a `CRIT-R02/fail-marker-case-variant` (`Pending`) and a code-span variant (`` `**Merge Readiness**: pending` `` → absent → strict) alongside the F2 cases.*

### F4 — The empty-value grammar deviates from plan D1 and T004 as written — CONFIRM

D1 and T004 both give the grammar `^\*\*Merge Readiness\*\*:\s*(\S.*?)\s*$`, under which an empty value is "absent" (feature 024's behaviour). D8 and T002 list "an empty value" as a strict `CRIT-R02` variant. The code uses `(.*?)` and a dedicated `''` arm (line 379), so empty is strict with a reason.

The plan contradicts itself. The implementer took the stricter reading, disclosed it (notes "Deviations" 1), and changed no document. That is the right direction and not a silent choice. Still, the approved text the code is graded against says otherwise in two places, and CLAUDE.md's conflict rule is "stop and report — never silently choose".

*Action: owner confirms the strict reading. If confirmed, D1's and T004's grammar should be brought in line by a plan/tasks amendment carrying the owner's approver record (the implementer may draft it, not approve it), so the approved text matches the code. Alternatively the owner records the acceptance in the human review.*

### F5 — CRIT-R01's `emitAnchor` narrowed — ACCEPTED

`rules.json` CRIT-R01 `emitAnchor` changed from `is not yet due` to `is not yet due - the branch is at phase`. The warning text plan D3 dictated contains `is not yet due`, so the old anchor would have matched four sites against a declared `siteCount: 2`. The new anchor matches exactly lines 463 and 465, feature 024's two sites. The new CRIT-R03 anchor matches exactly 455 and 457. The comment line 336 is excluded by the sweep's `^\s*#` filter, and the strict reason at 380 quotes the value, so it never contains `: pending` unquoted. Coverage tests passed in my `-Case CRIT-` run: "every anchor names exactly the emission sites its rule declares", "every declared emission site belongs to a rule". Feature 024's fixtures, emission sites and messages are unchanged. `rules.json` is in phase 1 territory (`tests/**`) and is test inventory, not an approved feature document, so this needs no approver record. It is disclosed (notes "Deviations" 2).

*Action: none. It is a mechanical consequence of the approved D3 wording.*

### F6 — notes.md and rules.json text drift from the fixtures and tasks — DOC DRIFT

(a) `rules.json` CRIT-R03 `notes` says the variants include "a missing tasks.md". The case is `pass-no-phase-headings-declaration-needs-none`, and notes.md explains a missing tasks.md cannot be used because the Structure check fails it first. The same entry says "The parent fails or reads differently on every pass here", but `pass-marker-in-comment-falls-back-to-heuristic` and `pass-standard-feature-ignores-marker` pass identically on the parent. I confirmed this by running `-Case CRIT-R03` against the parent's script: only `pass`, `pass-solo-arm`, `pass-no-phase-headings…` and `pass-shallow…` failed. notes.md itself calls those two controls.

(b) T003 asks for "the new warning's entry to `tests/enforcement/emission-idioms.json` the way feature 024's warning is". Feature 024 has no entry there (`grep` for `not yet due|CriticalEvidence|CRIT` in that file finds nothing), and this commit adds none. That is correct, but notes.md does not say so.

(c) T001 asks for the baseline's full-harness count and the exact output of a throwaway FitForge-shaped branch with no marker. T005 asks for the full harness and a byte-identical re-run of that branch. notes.md records neither ("running at the time of the phase commit"). The targeted T005 run listed (`CRIT-R03`, `fail-marker`, `merge-readiness`) does not include `-Case CRIT-` for the 024 cases. I ran it myself: 79 cases, 0 failed.

*Action: implementer corrects the CRIT-R03 `notes` text, adds a line to notes.md on the emission-idioms decision, and appends the full-harness counts (baseline and change) before the owner's gate.*

### F7 — Spec edge case "pending and the heuristic would have warned anyway: no difference" is true for the verdict, not the text — MINOR

With `pending` declared on a branch feature 024 reads as mid-feature, the printed line is the declared-pending text, not 024's "at phase X of N" text. Line 453 runs before 461. The exit and the verdict are the same. Plan D3 specifies the declared text, so the code follows the plan. The spec sentence should be read as "no difference in verdict" when phase 2 writes the guidance.

*Action: phase 2's guidance (`critical-delivery.md`) states that the declared warning replaces 024's wording when both would apply. No code change.*

### F8 — PhaseSizeWarning: 1727 lines / 54 files — MINOR

`enforcement-pack.ps1` on the branch prints `PhaseSizeWarning: commit 003c96a changes 1727 line(s) across 54 file(s)`. The script change is 41 lines. The remainder is 17 fixture directories (51 files) plus notes.md and the `rules.json` entry, required by the fixtures-first rule in the same phase (tasks T002). That is the same explanation accepted for feature 024 phase 1. Non-blocking by the check's own terms.

*Action: none; recorded for the human reviewer.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None.** `git show --stat 003c96a -- specs/` lists only `specs/025-critical-merge-ready-signal/notes.md`, which is phase evidence and not an approved document. `spec.md`, `plan.md`, `tasks.md` and `contracts/` are untouched, so no approver record was needed and none was self-granted. Two deviations from approved text are disclosed in notes.md rather than amended: the empty-value grammar (F4, needs the owner) and the CRIT-R01 anchor (F5, in test inventory, accepted). The tasks.md checkboxes T001-T005 remain unticked, consistent with feature 024's practice. AmendmentAuthority on the branch: `graded 6 of 6 commit(s)`, OK.

## Constitution re-check (post-implementation)

**PASS, with F1 engaging I late.**

- **I (Specification First / Amendment authority)**: the implementer approved no document. However, the feature's reliance on I for the marker has the merge-commit hole in F1, so the "recorded human act" is not yet guaranteed for every way a plan can change on a branch.
- **III**: N/A.
- **IV**: no new file; the reader sits where plan D1 put it.
- **V**: N/A.
- **VI**: nothing sensitive is read or printed.
- **VII**: N/A.
- **VIII**: fixtures-first holds, and the parent results reproduce the notes.md table exactly (four `pass` cases and three `CRIT-R02` cases fail on the parent; three AMEND cases differ in output only). F2 and F3 are gaps in what the fixtures measure.
- **IX**: this review has provenance; gate 6 stands behind `pending`.
- **X**: one phase, user-run gate, no batching or ci-held declared (plan header).

## Test coverage observed

All runs were in a scratch clone of `003c96a` (`<scratchpad>/kit`). The working repository was not touched, and the full harness was not run.

- **`-Case CRIT-` on `003c96a`**: 79 cases, 200 passed, 0 failed. This covers all of feature 024's CRIT-R01/R02 cases (unchanged files) and CRIT-S*/T*, plus the coverage suite: inventory integrity, anchors equal declared site counts, every site owned, the recall sweep accounted for.
- **New cases against the parent's script** (`git checkout 890b5e4 -- scripts/enforcement-pack.ps1`, then restored):
  - `CRIT-R03`: `pass`, `pass-solo-arm` and `pass-no-phase-headings-declaration-needs-none` fail on exit and output; `pass-shallow-clone…` fails on output only. The five `fail*` cases and two pass controls pass.
  - `fail-marker-*` (CRIT-R02): all three fail on exit and output.
  - `merge-readiness` (AMEND-001): all three fail on output only.

  This matches the notes.md table.
- **Critical assertions**:
  - `CRIT-R03/pass` (FitForge shape: duplicate `Phase 1 amendment requests` / `Phase 3 amendment request` headings, `tasks: phase N done` subjects, phase 3 landing with phase 2 never committed) gives the declared WARN and exit 0. Its `fail` twin differs only in `ready` and gives today's `human-pr-review.md is missing`.
  - `pass-shallow-clone…` shows the declaration bypassing the no-base state (D2) while AmendmentAuthority still fails the shallow run.
  - `fail-artifact-committed-invalid-under-pending` shows the arm still grades a committed artifact.
  - `AMEND-001/fail-merge-readiness-flip-unapproved` (a commit whose only change is the marker line) fails AmendmentAuthority. Its approved twin passes AmendmentAuthority, and the arm still fails because no review is committed.
- **Mutation results**:
  - Removing the fence test is caught (`fail-marker-in-fence-is-absent`).
  - Removing the comment stripping is not caught (F2).
  - Removing case sensitivity is not caught (F3).
- **Throwaway experiments** (deleted afterwards): `xfail-multiline-comment`, `xfail-codespan`, `xfail-case-variant` and `xpass-trailing-comment` all passed on `003c96a`. A hand-built evil-merge repository reproduced F1.

## Residual risk

- **F1** carries the main risk. Until merge-commit changes to `plan.md` are graded, or the limit is accepted and the warning reworded, `pending` can be introduced without a recorded approver on a Critical branch. The only backstop is then gate 6, reading a warning that wrongly says an amendment was recorded.
- After F1 and F2, the residual risk is the disclosed cost of option A: `pending` is a claim an owner can leave in place, and the machine then never demands the artifact, so gate 6 holds it. Also disclosed: a marker in the commit that creates `plan.md` needs no approver (first appearance, plan Risks).
- **Before merge**: fix F1 (route chosen by the owner) and F2, settle F4 with the owner, correct F6's text and record the full-harness counts. Then the owner runs the gate.
