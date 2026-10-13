# AI Code Review — 024 Critical branch not red, phase 1

**Reviewer**: fresh-context agent, Claude Sonnet 5.5 (claude-sonnet-5-5)
**Date**: 2026-10-13
**Branches**: kit repository `024-critical-branch-not-red` (phase 1 commit `2300e44`; branch tip at review start `926b37d`)
**Scope reviewed**: `git diff 2300e44~1 2300e44`: `scripts/enforcement-pack.ps1` (`Get-CriticalMergeReadiness`, `Invoke-CriticalEvidenceCheck`, the dispatch call), `tests/enforcement/rules.json` (CRIT-R01, CRIT-R02), all ten case directories under `tests/enforcement/cases/enforcement-pack/CRIT-R01` and `CRIT-R02` (command.json, expected.txt, recipe.json read for the discriminating ones), `specs/024-critical-branch-not-red/notes.md`. Also read: `Get-VisibleFromText`, `Get-FencedLineMap`, `Get-DiffBase`, spec.md, plan.md (D1-D8, Risks), tasks.md phase 1, the review template. Not read in full: phase 2 content (not in this commit), `ritual-checks.ps1`.
**Feature contract**: shape B. A Critical branch gets one WARN, not a FAIL, for a not-yet-due independence artifact while provably mid-feature. It is strict (today's behaviour) from the final-phase commit on and wherever mid-feature cannot be shown. Arms unedited; no other member or non-Critical branch changed; no new file or package.

## Reviewer Provenance

- **Reviewer**: fresh-context agent, claude-sonnet-5-5
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5), the same session that wrote 024 plan/tasks
- **Inputs provided**: the phase 1 diff (`git diff 2300e44~1 2300e44`), specs/024-critical-branch-not-red/spec.md, plan.md, tasks.md, notes.md, CLAUDE.md, the review template, the new fixtures, and a detached worktree of `2300e44` for running tests and adversarial repos
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The change does what FR-001 to FR-005 ask, and I found no way for a branch that should be strict to get the WARN through a *parsing* weakness: every misread I tried (comment, tilde/backtick/unclosed fence, indented or code-span heading, gap, duplicate, phase 0, CRLF, `phase 10` against `phase 1`, uppercase subjects, mid-subject "phase 3") resolved to either the correct state or the strict one. The fixtures are real: a mutant that counts fenced headings fails 2 of the 52 CRIT-R01 assertions. The remaining fail-open surface is the one the plan discloses (a final commit not named `phase N`, plus an amended `tasks.md` that adds a trailing phase), and I judge the disclosure honest but the mitigation thin, because a cheap tighter signal exists (F1). Two real defects need follow-up: an `[int]` overflow that crashes the whole pack on a huge phase number (F2), and a committed-but-invalid independence artifact that is no longer graded mid-feature (F3). Neither blocks, because neither lets a bad branch merge: F2 fails closed (exit 1) and F3 is re-graded at the final phase. Residual risk sits in F1 and F3 and in gate 6 being a human check.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-001: mid-feature gives one `WARNING: CriticalEvidence: ... is not yet due` line, exit 0, naming the arm's artifact and the final phase (observed in my repos: "phase 2 of 3 ... owed once the phase 3 commit lands"). FR-002: when `tip >= final`, `Why` is `$null`, so no new line is added and the unedited arms run (observed: "phase 3: done" and "PHASE 3: c" give the same single `second-model-review.md is missing` failure as the parent). FR-003: no base, shallow, no blob, no heading, gap, log failure, no phase commit each return `Pending=$false` with a reason (code read; shallow, gap, no-heading, no-phase-commit observed). FR-004: the gate sits after the `^\d{3}-` and `Delivery Level -notmatch '^Critical\b'` early returns, so a non-Critical branch never reaches it (code read; the 124-case run below includes the pre-existing CRIT-S/T cases). FR-005: pairs exist, see Test coverage. |
| Visual-reference match | N/A: no UI, no visual references. |
| Feature contract held | `git diff --stat`: one script, `rules.json`, `notes.md`, fixtures. No new script, library file, package, or recipe field (notes T001, consistent with the diff). The two arms are not touched (diff read). |
| Constitution / domain invariants | See re-check below. Domain invariants slot unfilled in this kit. |
| Security (authn/authz, secrets, sensitive logging) | The check reads a committed blob and commit subjects, prints neither. No secrets. Untrusted input (subject text, heading digits) reaches an `[int]` cast: see F2. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | Not re-run by me. notes.md records the owner's gate-3 run (exit 0, scope-check OK) on `2300e44`. `git diff --stat` read: 33 files, 1013 insertions; 30 are fixtures. The `PhaseSizeWarning` (1015 lines / 33 files) is real and explained in notes; I accept the explanation (the fixtures-first rule puts proof and behaviour in one phase). |
| Rollback safety (phase reverts cleanly; schema additive?) | Pure additive function plus one parameter and one call-site change; revert restores the parent. No schema, no data. |

## Findings

### F1 — A final commit not named `phase N` leaves the branch on the WARN; a tighter signal is cheap — CONFIRM

Observed: with a 3-phase `tasks.md` and subjects `phase 1: a`, `phase 2: b`, `final: the rest of the feature`, the pack prints the WARN and exits 0. The same holds for a final commit written `docs: phase 3 complete`, or a single squashed commit. The disclosure in the function header and plan Risks is honest and accurate (it says the branch "can stay on the WARN by not naming it" and that gate 6 stands behind it). The mitigation is thin for a check whose own lesson is "a relaxation that can be used to skip the thing it relaxes": the person who would skip is the person who writes the subject, and gate 6 is not a machine check. Two cheap, strictly-tighter signals, both of which only move toward strict:
(a) Use asymmetric matching: keep the anchored `^phase\s+N\b` to establish "mid-feature" (so unrelated notes do not qualify a branch), but count *any* subject matching `\bphase\s+N\b` with N >= final as "final reached", the looser form scope-check already uses. Cost: a `notes: ... phase 3` commit flips to strict early, the safe, noisy direction plan D3 already accepts.
(b) Treat the presence of the arm's artifact file (even invalid) as "the author believes it is due" and go strict (see F3, same fix).
Related, also disclosed by contiguity but not closed: adding a trailing `## Phase 4` heading to `tasks.md` in the last commit moves final to 4 and keeps the WARN (observed: "phase 3 of 4"). That amendment is graded by the amendment-authority check, which the plan names, so I do not raise it separately.
*Action: owner decides whether to take (a) and/or (b) in phase 1 follow-up or phase 2; if not, keep the disclosure and record the decision in notes.*

### F2 — A phase number beyond Int32 crashes the whole pack — MINOR

`[int]$matches[1]` on a heading or subject with a huge number throws a terminating error. Observed on `## Phase 99999999999999` in `tasks.md` and on a commit subject `phase 99999999999999: z`: `enforcement-pack.ps1: Cannot convert value "99999999999999" to type "System.Int32"`, exit 1, no other member's output. It fails closed, so it is not a fail-open, but one hostile or typo'd commit subject (including one merged in from elsewhere) blanks the entire pack's verdict instead of yielding the strict reason line. The plan names "phase numbers above 99" as a case to consider; there is no fixture for it. Cheap fix: parse with `[long]` (or `[int]::TryParse` and treat failure as undeterminable, strict, with a reason), plus a fixture.
*Action: implementer, in a follow-up commit within this phase or phase 2; add a fixture variant under CRIT-R02.*

### F3 — A committed but invalid independence artifact is not graded while mid-feature — MINOR

Observed: with phases 1 and 2 of 3 committed and a `second-model-review.md` containing only "garbage no provenance", the pack prints the WARN and exits 0. The parent would have failed it. The artifact is re-graded in full once the final commit lands, so nothing merges unchecked, but a forged or malformed review sits unexamined for the whole feature, and the WARN text ("is not yet due") is wrong when the file already exists. FR-002 only demands unchanged behaviour once merge-ready, so this is conformant; it is a missed chance to stay stricter. Same one-line fix as F1(b): if the arm's artifact exists in `HEAD`, do not relax.
*Action: owner decides with F1; if accepted as is, one line in notes.*

### F4 — Fixtures do not exercise the solo arm's cooling-off, mid-feature or at final — MINOR

The spec (US2 scenario 4) and the rules.json notes claim the cooling-off is "not demanded either while mid-feature". `CRIT-R01/pass-solo-arm` has no `second-model-review.md` at all, so it proves only that a *missing* file is not demanded. `fail-solo-arm` expects the "is missing" failure, which comes before any cooling-off logic, so no new fixture shows the cooling-off being demanded at final either (the pre-existing CRIT-S fixtures do, on branches with no phase commits). An implementation that relaxed "missing" but still ran the cooling-off check on an existing young file would pass every new case, and so would one that dropped the cooling-off at final. Ten cases are not hand-written to the claim as worded.
*Action: implementer adds a pass variant (young review file present, tip at phase 2: WARN) and a fail variant (same file, tip at final: today's cooling-off message).*

### F5 — Unfixtured states the code handles — MINOR

Not covered by any case, though I observed each correct by hand: case-insensitive subject (`PHASE 3`), `phase 10` against `phase 1` prefix, comment-hidden heading, tilde fence, unclosed fence, CRLF `tasks.md`, phase 0 heading, duplicate headings, mid-subject "phase 3", `git log` failure. The fence and gap cases are fixtured and are the ones that matter most; the rest are regression risk only.
*Action: none required; add the comment-hidden heading and the `phase 10`/`phase 1` case if the fixtures are touched for F2 or F4.*

### F6 — Deviation from the plan: six planned rules became two with variants — ACCEPTED

Plan D6 and tasks T002/T003 name `CRIT-R01..R06`; the commit ships `CRIT-R01` (siteCount 2) and `CRIT-R02` (one site, four variants). Justified: the coverage sweep owns one rule per emission site and there are two sites for the WARN (team, solo) and one for the strict reason; every condition D6 listed has a case (R03 no tasks.md, R04 gap, R05 fence, R06 shallow map to `fail`, `fail-heading-gap`, `fail-fence-heading-not-counted`, `fail-shallow-clone`; no-phase-commit is extra). It is recorded in notes.md and in the rules.json `notes`, and the notes say it is left for the owner's decision. One small gap: T003 also said to add an entry to `emission-idioms.json`; the commit does not touch it and notes do not say whether it was unnecessary. `tasks.md` still says six rules; the notes say that is deliberate so the task stays "what was agreed".
*Action: owner confirms the two-rule layout (already requested in notes); implementer adds one line to notes on why `emission-idioms.json` needed no entry.*

### F7 — Strict reasons add a WARNING line to previously identical output — ACCEPTED

For undeterminable states the output now carries `WARNING: CriticalEvidence: not treated as mid-feature - <reason>` before the unchanged failure. FR-003 asks for the reason in the message, so this is intended, and FR-002's byte-identity applies to merge-ready (verified: no extra line when `tip >= final`). It does change output for every pre-existing CRIT-S/T style branch with no phase commits; the 124-case run shows they still pass, which means the harness compares in a way that tolerates the added line (it is an exact-output harness per notes, and those cases are Critical branches with no `phase N` subject, so this should have changed their output; I did not trace why they pass, see Test coverage).
*Action: implementer states in notes why the pre-existing CRIT-S/T expectations are unchanged (if the harness only checks the listed lines, say so; if the cases take a different path, say which).*

## Amendments in this diff

- [x] **None.** `git diff 2300e44~1 2300e44 --stat` touches no `spec.md`, `plan.md`, `tasks.md` or `contracts/` (the only file under `specs/` is `notes.md`, which is evidence, not law). The deviation in F6 is recorded in notes and not written into `tasks.md`, which is the correct way to avoid self-amending.

## Constitution re-check (post-implementation)

PASS. I (Specification First), III, V, VII N/A or satisfied: the spec and plan were approved before the phase, no repository separation or integration involved. IV (Architecture Consistency): no new file, check stays beside its arms. VI: nothing sensitive read. VIII (Testing): failing and passing fixtures, hand-written, shown failing on the parent (notes table), the sweep inventory updated. IX (Human Review): unchanged, and this relaxation is the one place where its only backstop is human (F1). X (Controlled Delivery): one phase, owner-run gate; the phase exceeds the 400-line / 15-file guideline by fixtures (warned, explained).

## Test coverage observed

- `pwsh -File tests/enforcement/Run-Tests.ps1 -Case enforcement-pack/CRIT-` in a detached worktree of `2300e44`: **124 passed, 0 failed, 0 skipped** (99.7 s). That includes the ten new cases and the pre-existing CRIT-S/T cases.
- Mutation: in the worktree I removed the `-not $fenced[$i]` guard (so headings inside fences count). `-Case enforcement-pack/CRIT-R01` then failed 2 assertions (the fence fixture's exit code and output), so the fence fixture measures what it claims. Worktree restored and removed; no change made inside the repo (`git status` clean).
- Pairs: CRIT-R01 `pass`/`fail` differ in exactly one commit (`phase 3`); solo likewise; `fail-fence-heading-not-counted` has headings 1, 2 and a fenced 3 with tip 2, which a fence-blind or "any missing artifact is WARN" implementation fails. CRIT-R02 variants (`fail` no tasks.md, `fail-heading-gap` 1,2,4, `fail-no-phase-commit`, `fail-shallow-clone`) each expect exit 1 and the new reason line. `fail` in CRIT-R02 is not strictly a one-condition pair with `pass` (different recipe files), acceptable.
- Own adversarial repos (throwaway, outside the repo, scripts copied in; 20 scenarios) are summarised in the findings: baseline WARN; `PHASE 3` and `phase 3: done` strict; tip 10 of 11 WARN (no `phase 1` prefix confusion); gap, phase 0, duplicate heading strict with reason; heading in a comment, tilde fence, unclosed fence, indented and code-span heading strict; `##   Phase   1`, a tab and a lowercase `## phase 3` heading read as phases; CRLF `tasks.md` read correctly; mid-subject "phase 3" not counted as a phase commit; misnamed final commit WARN (F1); invalid artifact WARN (F3); huge numbers crash (F2).
- Gap, F7: the full harness (about 18 minutes) was not run by me. I did not trace how pre-existing Critical cases still match after the added reason line.
- Not tested by me: team-arm variants of the scenarios (same code path through `$mode.Mode`), `git log` failure injection, a diff base given as a branch ref rather than a merge-base (`Get-DiffBase` returns a merge-base SHA, so the question does not arise in the pack).

## Residual risk

Concentrated in F1 and F3: the relaxation is bypassable by a final commit that does not begin `phase N`, and the only stop is the human gate at merge; the WARN is visible but not blocking. Taking the looser-for-final matching and the "artifact present means strict" rule would shrink this without costing the feature anything. F2 is a crash, not a bypass. Nothing in the change affects a non-Critical branch, a merge-ready Critical branch (byte-identical output) or any other member. Before merge: owner decision on F1/F3 and on the two-rule layout (F6); F2 and F4 should be fixed or recorded.
