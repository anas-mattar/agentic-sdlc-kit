# AI Code Review — 021 Load-bearing Developer Roster, phase 4 remediation (round 2)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-12
**Branches**: kit repository `021-developer-roster` (remediation commit `447ad7b`, parent `f8303cc`; phase 4 is `382f5da`; HEAD `3aef320` adds only a notes.md update)
**Scope reviewed**: the phase 4 part of `git diff 382f5da 447ad7b` (`adoption/updating.md`, `docs/sdlc/critical-delivery.md`, `docs/sdlc/team-workflow.md`,
`docs/roadmap.md`, `specs/021-developer-roster/notes.md`, and the phase 4 review file itself), against the phase 4 review (`ai-code-review-phase-4.md`,
F1..F6) and the scripts as they stand (`adoption-lib.ps1` `Get-DeveloperMode`, `verify-kit.ps1`, `roadmap-claim-check.ps1`, `doc-lint.ps1`, `build-digests.ps1`,
`ritual-checks.ps1`). The range also contains `f8303cc` (the phase 3 round 2 remediation, scripts and fixtures), which is not phase 4 Territory and is not
re-reviewed here; I used it only as the behaviour the phase 4 documents describe.
**Feature contract**: phase 4 Territory is documents and bookkeeping only (`critical-delivery.md`, `team-workflow.md`, `adoption/updating.md`,
`adoption/greenfield.md`, `docs/roadmap.md`, `docs/digests/*`, the feature's notes and tasks); every sentence about what a check does must match the script;
no verdict moves in an adopted project (FR-011, SC-003).

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-sonnet-5-5 (separate session that produced the remediation commit `447ad7b`)
- **Inputs provided**: the diff `382f5da`..`447ad7b`, CLAUDE.md, review-process.md, the review template, spec.md, plan.md, tasks.md, notes.md, the phase 4 review
  being answered, the phase 3 round 2 review as shape precedent, `3aef320`'s notes change, and the scripts named above
- **Attestation**: This reviewer did not produce the diff under review.
- **Prior involvement**: none. Fresh context; notes.md was read as a claim and checked.
- **Commands run**: `git log`, `git show 447ad7b`, `git show 3aef320`; in a detached worktree of `447ad7b` outside the repository: `pwsh -File scripts/doc-lint.ps1`,
  `scripts/build-digests.ps1 -Check`, `scripts/scope-check.ps1 -Commit 447ad7b -Branch 021-developer-roster`, `scripts/ritual-checks.ps1 -Branch 021-developer-roster`;
  a scratch copy of that tree with `specs/0*`, `specs/1*`, `tests/` and `docs/roadmap.md` removed (the adopter-created or kit-only files) run through `doc-lint.ps1`;
  in the same copy, the digests restored from `85b944f` then `build-digests.ps1 -Check`, `build-digests.ps1`, `-Check` again; a local `git clone` of
  `D:\solutions\flowboard` into the scratchpad (origin removed, never pushed) with `scripts/update-kit.ps1 -Target .` from the detached worktree, then
  `ritual-checks.ps1`, `build-digests.ps1`, `ritual-checks.ps1`; reading `Get-DeveloperMode`, `verify-kit.ps1` and `roadmap-claim-check.ps1`. The worktree, the copy
  and the clone are removed; `git worktree list` shows only the main checkout; nothing was run against, or written to, the adopted projects in `D:\solutions`.
  I did **not** re-run the 1335-case harness (see Test coverage).

## Verdict

**APPROVE with follow-ups.** F1, the blocking finding, is fixed: the path-shaped token is gone, and in a simulated adopted tree and in a real clone of FlowBoard
`doc-lint` is `OK` as applied and after the digest rebuild, and `ritual-checks` is `RESULT FAIL (1 of 7)` as applied (digests stale) and `RESULT OK` after, exactly
as the corrected text now says. F2, F3 and F6 are accurate against the code, and F5 now states the SC-001 conflict completely and proposes a rewording without
approving it. F4 is rightly left to the owner. The diff touches documents only, and the digests are fresh. The follow-ups are small: one measurement figure I could
not reproduce, SC-001 still false as written until the owner decides, and two cosmetic items. Certification of the gate is the owner's; nothing here claims it passed.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| F1, no unresolved path in a flowing document | `git show 382f5da:adoption/updating.md` held one `specs/021` token; `447ad7b` has none (now "the notes of feature 021 in the kit repository"). Scratch tree with the feature directories, `tests/` and `docs/roadmap.md` removed: `doc-lint.ps1` reports only references to `docs/roadmap.md` (an adopter-created file, deleted by me to make the copy; present in a real adoption), so no `specs/0NN` path in any flowing document fails. `doc-lint` has no fence exemption, so the earlier mention in the 013/014 text resolves only because it is not path-shaped or is pattern-skipped; none failed. |
| F1, end to end on a clone | FlowBoard clone (origin removed): `update-kit.ps1 -Target .` from `447ad7b`, `verify-kit` OK. `ritual-checks`: doc-lint **OK**, enforcement-pack OK, digests **FAIL**, `RESULT FAIL (1 of 7)`. After `build-digests.ps1` (72 markers): digests OK, doc-lint OK, `RESULT OK`. (`roadmap-claims` n/a only because I removed origin.) This is the opposite of the phase 4 review's reproduction, which failed on doc-lint. |
| F2, digests as applied | In the scratch tree, digests restored from `85b944f`: `build-digests.ps1 -Check` reports `branching`, `critical` and `adoption` stale, `RESULT FAIL (3 issue(s))`; after `build-digests.ps1` it is `OK (5 digest(s) fresh, 96 marker(s))`. The updated text ("once the digests were rebuilt every member was OK ... As applied, before `build-digests.ps1`, the `digests` member reports the digests stale and the run is `RESULT FAIL`") is true; notes.md's FitForge table row and the paragraph below it now agree. The clause "it fails identically after the kit as it stood before this feature" rests on notes.md S1 (I did not apply the `85b944f` kit); the mechanism is the same, so I accept it. |
| F3, roster wording against the reader | `Get-DeveloperMode` keeps a non-blank string (trimmed) and an object with a usable `name`; it drops a blank string, a number, an array, null, and an object whose `name` is missing, not a string or blank, and reports the last as an entry problem. "every entry that is neither a non-blank name nor an object with a usable `name` is dropped" is exact, in `team-workflow.md`, `critical-delivery.md` ("a number, a blank, an object with no name") and `updating.md` (both places, including feature 013's older paragraph). Duplicates collapse through `OrdinalIgnoreCase`, as written. |
| F6, the `not graded` line | `roadmap-claim-check.ps1` prints `not graded — a roster is declared but docs/roadmap.md has no Owner column ...` (no UNGRADED clause, so the verdict stays OK and `$gradedText` is dropped) and, per claim, `not graded — claim '...' is in a roadmap table with no Owner column ...` with `$skippedNoOwner = $true`, also OK. The update note says exactly this: a `not graded` line, "the run stays `OK`". |
| F6, the UNGRADED reasons | The script yields `UNGRADED` (exit 0) for three reasons: the first tip commit unreadable (`the claim count for ... was not made`), a claim named by rows with different Owners, and a claim that passed visibility but binds to no row ("only in a form this check cannot bind ... inside a longer name, say"). The note names these three, in that order and with that parenthesis; `team-workflow.md` names the second and third. `ritual-checks.ps1` lifts `UNGRADED` (unchanged from the phase 4 review). |
| F6, the doctor line | `verify-kit.ps1` prints `roster read from kit-adoption.json: ...` only `if ($devMode.HasObjectEntries)`, and `HasObjectEntries` is set only when an object with a usable `name` was parsed; "only when an entry is an object with a usable `name`" is exact. |
| F6, trailing newlines | `docs/roadmap.md` and `notes.md` end with a newline in `447ad7b` (the diff shows the `\ No newline` marker removed). |
| F5 | notes.md now lists four classes (team Reviewer/Owner not on a string roster; one-name roster with other spellings; a third active claim; an Owner cell with more than one name or decoration) and proposes, **for the owner's approval and not made**, the rewording of SC-001. Each class is backed by code (FR-005 to FR-007, `Invoke-CriticalTeamEvidence`, the counter, exact-cell compare). No amendment is applied; `spec.md` is untouched. |
| F4 | Left for the owner, in notes.md, with the decisions-log entry as the correction. The roadmap row is unchanged. Acceptable. |
| Digests | `build-digests.ps1 -Check`: `OK (5 digest(s) fresh, 96 marker(s))`, on the same marker count as the phase 4 commit: the remediation changes no marker line (`git diff 382f5da 447ad7b -U0 -- docs adoption` has no `<!--` line) and no digest file. `-Check` enforces the 120-character limit and the standalone-line rule (markers inside a table, list or comment are reported); it passes, and doc-lint passes. My own awk length count came out at up to 122, but it counts bytes of multi-byte characters and a path prefix, and I rely on the script's verdict, as the phase 4 review did. |
| Territory | `scope-check.ps1 -Commit 447ad7b -Branch 021-developer-roster`: **`PASS phase 4 commit 447ad7b (6 file(s))`** (four documents, notes.md, the review file). No script, test, manifest or digest change in this commit. |
| Ritual | `ritual-checks.ps1 -Branch 021-developer-roster` in the detached worktree: doc-lint, enforcement-pack, scope-check, digests, roadmap-claims OK; scope-repos and verify-kit n/a; **`RESULT OK`**. |
| notes.md T020 | `3aef320` records 1335 passed = 1327 + 8 (four new round 2 fixture cases, `fail-claim-written-in-capitals`, the second new fail case, `CLAIM-015` fail and pass, two assertions each, matching the four new case directories in the diff stat) and 16 of 17 sites fixtured (CLAIM-015 adds one site). Plausible and consistent with the phase 3 round 2 review's own arithmetic; not re-run by me. |

## Findings

### R2-1 — The re-measurement claims `doc-lint` OK in every S2 state of all three clones, but the T018 table does not record it and one marker count does not reproduce — MINOR (follow-up)

The update note says `doc-lint.ps1` was part of the `RESULT OK` in every project. notes.md states it in the remediation section ("`doc-lint` is `OK` in every S2 state ... in all three") but the T018
table itself, the measurement of record, has no `doc-lint` column or row, so the claim has no per-project line to check. On my one clone (FlowBoard, the project the note says went 67 to 70 digest
markers) the rebuilt digests report **72 markers**, not 70. FlowBoard may simply have moved since the measurement, or the count may be off by two; either way it is a figure in the measurement table
that I could not reproduce. It does not move a verdict.
*Action: implementer, notes.md only: add `doc-lint` to the T018 table per project, and re-check the FlowBoard marker count (or say the clone's current marker count differs and why).*

### R2-2 — SC-001 is still false as written, and two owner decisions are still open — MINOR (awareness, owner's call)

The remediation lists the four classes honestly and proposes the rewording, but until the owner decides, `spec.md` SC-001 ("byte-identical") contradicts FR-005 to FR-007 and the shipped checks, and the roadmap row
(F4) still reads "at most one active claim per Owner" beside a shipped rule of "more than two fails, two is a note". The documents shipped to adopters (`updating.md`, `team-workflow.md`) are correct on both points, so no adopter is
misled; only the spec and the roadmap row are. 3aef320's "still to come" list names both decisions, which is the right place.
*Action: owner: approve or amend the SC-001 wording and F4's row before the merge; the implementer does not amend either (constitution I).*

### R2-3 — Missing blank line before two headings in notes.md — NIT

`notes.md` now runs "... `roadmap.md` and `notes.md` have their trailing newline back." straight into `### T020: the final run ...`, and the paragraph before `### T019` likewise; renderers that need a blank
line before a heading will show them as text. `doc-lint` does not flag it. No verdict is affected.
*Action: optional; add one blank line before each heading.*

### R2-4 — Very long unwrapped lines in the update note — NIT

The remediation re-flowed lines in `adoption/updating.md` (and `team-workflow.md`) without re-wrapping: several lines run past 200 characters where the file wraps near 120. A reader of a diff or a
narrow terminal sees the cost; the rendered document is unchanged.
*Action: optional.*

## Phase 4 findings, one by one

| Finding | Status |
|---|---|
| F1 — dangling `specs/021-.../notes.md` in the update note, `doc-lint` and `ritual-checks` fail after update | **Fixed, verified.** No kit-only path in the five flowing documents; simulated adopted tree and a real clone both pass `doc-lint`. Re-measured as asked (see R2-1 for one figure). |
| F2 — "every member OK in every state" overstates | **Fixed, verified.** Table row and update note now say FAIL as applied (digests), OK after the rebuild; reproduced. |
| F3 — "non-string entries are dropped" no longer exact | **Fixed, verified** in all four places against `Get-DeveloperMode`. |
| F4 — roadmap row says "at most one active claim" | **Left for the owner**, recorded. No change expected. |
| F5 — SC-001 observation narrow, asks nothing | **Fixed**: four classes, rewording proposed for approval, not applied. See R2-2 for what is still open. |
| F6 — omissions in the "does not change" paragraph | **Fixed, verified** against `roadmap-claim-check.ps1` and `verify-kit.ps1`; trailing newlines restored. |

## Amendments in this diff

- [x] **None.** `spec.md`, `plan.md` and the scope of `tasks.md` are untouched by `447ad7b`. The proposed SC-001 rewording is explicitly not made and is recorded as awaiting the owner's approval. Nothing is
  claimed as approved by the implementer.

## Constitution re-check (post-implementation)

**PASS.** I (no spec or plan change; no self-approved amendment), IV (the guidance follows the approved spec and plan; every behavioural sentence I checked matches the script), VIII (no script or fixture
change in this commit), IX (this review is fresh-context; human review at merge), X (one phase; no gate claim; the notes end with the owner's gate still to come).

## Test coverage observed

I did not re-run the full harness: the remediation commit changes no script, fixture or rule file (`git show 447ad7b --stat`: four documents, notes.md and a review file). The scripts and fixtures are those of `f8303cc`,
reviewed in the phase 3 round 2 review at 1327 passed and now recorded at 1335. Observed instead: `doc-lint`, `build-digests -Check`, `scope-check -Commit 447ad7b` and `ritual-checks -Branch 021-developer-roster` on the
kit; `doc-lint` in a simulated adopted tree; an update and rebuild on one real-project clone with `ritual-checks` before and after. The class of defect behind F1 (a kit-only path in a verbatim document) is still
caught by nothing in the kit's own CI, as the phase 4 review noted; it was found by an adopted-project run, which is what this remediation re-did.

## Residual risk

Small and documentary. The owner's two decisions (SC-001, the roadmap row) and the human reviews are the open items. The standing risk the phase 4 review named remains: any later edit to a verbatim document that
mentions a kit-only path fails an adopted project's CI, and a kit-side guard would be a candidate roadmap gap, not this phase. Merge after the owner's gate certification and the human review; R2-1 is a notes
correction that can ride with the owner's decisions.
