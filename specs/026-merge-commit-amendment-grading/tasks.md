---

description: "Task list for feature 026 — grade the content a merge commit authors in the amendment-authority check"
---

# Tasks: Grade the content a merge commit authors in the amendment-authority check

**Input**: `specs/026-merge-commit-amendment-grading/spec.md`, `plan.md` (decisions D1–D11)
**Prerequisites**: spec.md approved (anas.m, 2026-10-14, option A, amended the same day for plan D2); plan.md approved (anas.m, 2026-10-14), including D2
(the automatic-merge refinement with its fail-closed fallback), D3 (exemptions against every parent), D4 (a record new against every parent) and three
phases, before phase 1 starts; no new dependency, no new script file; `git` 2.38 or newer for `merge-tree --write-tree`.

**Tests**: every rule ships with a passing and a failing harness fixture in the same phase as the behaviour, expectations written by hand (feature 015). New
fixtures are run against the parent commit before the code changes and must fail there (or be named controls that pass there by design), so each is shown to
measure something. **At least one fixture per rule is shaped from a real merge** (`Merge branch 'main' into NNN-...`, with other features' documents and a
roadmap change arriving) and one from feature 025's reproduction, not from the kit's conventions (plan D9). Each fixture that guards a branch of the new
code is also shown failing under a mutation of that code, and the code is restored byte for byte (feature 025's method). Phase evidence goes in `notes.md`,
never here. Rule ids: `AMEND-008` (the unreadable-parent refusal) plus new variants of `AMEND-001` and `AMEND-002`.

**Organization**: three phases, each independently revertible. Phase 3 must be reverted before phase 2, and phase 2 before phase 1. The full harness is run on
an isolated checkout of the final commit, never in a working directory someone is using.

---

## Phase 1: A merge can carry content (fixture library) (FR-006)

**Purpose**: `tests/enforcement/lib/FixtureRepo.psm1` can build a merge commit whose result differs from its parents (the capability behind review finding
F12 of feature 025), with its self-test. No check changes and no existing fixture changes; a merge without the new fields behaves exactly as today.

**Territory**:

- `tests/**`

- [ ] T001 Record the baseline on the parent commit in `notes.md`: the full harness count, and the exact output and exit of the existing
      `AMEND-001/pass-merge` case. Read the `merge` handling in `tests/enforcement/lib/FixtureRepo.psm1` (it runs `git merge --no-ff --no-edit` and takes no
      content) and confirm that feature 025's reproduction (an approved `plan.md` gaining a line inside a merge) cannot be expressed today.
- [ ] T002 Write the self-tests first in `tests/enforcement/Harness.Tests.ps1`, in the shape of the existing recipe self-tests, and run them on the parent to
      show each failing: a merge with `mergeWrite` has two parents and a result differing from both; `mergeDelete` removes a file from the merge result only;
      a conflicting merge with `resolve` lands the resolution; a conflicting merge **without** `resolve` is refused, never ignored; `mergeWrite`, `mergeDelete`
      or `resolve` on a commit that is not a merge is refused; a plain merge is unchanged.
- [ ] T003 Edit `tests/enforcement/lib/FixtureRepo.psm1` (plan D8): optional fields `mergeWrite` (files written into the merge result, `write`'s shape),
      `mergeDelete`, and `resolve` (content taken for a conflicting merge, written and staged before the commit); the merge runs `--no-commit`, applies the
      fields, stages and commits with the recipe's message. Update the field list in the module header and the README so the fields are documented where the
      other recipe fields are.
- [ ] T004 Run `-Case AMEND-`, the harness self-tests and the full harness on the working tree: every pre-existing case unchanged, the new self-tests passing,
      and the count recorded (baseline plus the new tests).

---

## Phase 2: The check and its proof (US1, US2; FR-001–FR-007)

**Purpose**: `Invoke-AmendmentAuthorityCheck` grades the content a merge authored, with the same record and message rule as any commit; a merge that authored
nothing is skipped and counted exactly as today; a merge it cannot read is refused. Each state is proved by a fixture pair built from real shapes.

**Territory**:

- `scripts/enforcement-pack.ps1`
- `tests/**`

- [ ] T005 Record the baseline in `notes.md`: the full harness count on the parent of this phase, and, on a throwaway Critical branch built with the phase 1
      field, feature 025's reproduction (an approved `plan.md` gains `**Merge Readiness**: pending` inside a merge, no record) showing `enforcement-pack: OK`,
      exit 0, on the parent: the gap this phase closes.
- [ ] T006 Write the fixtures first (plan D9), as variants of `AMEND-001` and `AMEND-002` and the new `AMEND-008`, each pair differing in one condition and
      each shown failing on the parent or named as a control that passes there by design: a real-shaped `Merge branch 'main' into NNN-...` (control, output
      byte-identical); a conflict resolved taking the branch's side whole and main's side whole (controls); 025's reproduction without and with a conforming record;
      the record in the file but the approver missing from the merge message; a hand-merged conflict without and with a record; a merge combining a parent's
      already-approved amendment with another's, without a fresh record; two parents each amending `plan.md` in different places, a clean automatic merge, as
      both the exempt case (D2) and, in a fixture that forces the fallback, the graded case; a tick-only and a `**Status**`-only merge change (exempt) and a tick
      against one parent with a rewrite against the other (graded); an octopus merge that authors `plan.md`; a merge that deletes an approved document; a merge
      with an unreadable parent in a depth-1 clone (`AMEND-008`). Expectations by hand. Record, for each, how it behaves on the parent.
- [ ] T007 Inventory the rules: add `AMEND-008` to `tests/enforcement/rules.json` with its anchor and law, update the `AMEND-001` and `AMEND-002` notes for the
      merge variants, and run the recall sweep first, classifying anything else it reports (a rule with a pair, an exemption, or a not-a-rule with a reason).
- [ ] T008 Edit `scripts/enforcement-pack.ps1` (plan D1–D7): add a function that decides a merge's authored documents (candidate documents from `git ls-tree -r`
      of the merge and its parents; blob ids per parent; first appearance when absent in every parent; the existing tick-only and `**Status**`-only helpers asked
      per parent; `git merge-tree --write-tree` for two parents with the fallback for an octopus merge, an old git or any failure other than a conflict); add a
      merge-aware helper for the record lines (new against every parent, through `git diff -U0` and `Get-VisibleFromText`); in the loop, replace the
      unconditional merge skip with the grading branch that falls into the **same** record and message tail, appending the one merge clause to the existing failure
      sentence; keep `$skipMerge` and its wording for a merge that authored nothing; add the unreadable-parent refusal (`AMEND-008`). Replace the script header's
      `LIMIT` paragraph with what is now graded and what stays open. The ordinary-commit path and `Get-AddedRecordLines` are not edited.
- [ ] T009 Show a mutation for each fixture that guards a branch of the new code, and record it in `notes.md`: drop the per-parent exemption check; take the
      record from the first parent only; skip the automatic-merge comparison; compare with the first parent only. Each must fail exactly the fixture meant to catch
      it, and the script is restored byte for byte (`cmp`).
- [ ] T010 Run `-Case AMEND-`, `-Case CRIT-`, the full harness and `ritual-checks.ps1`: every pre-existing case unchanged, every new fixture as written, the
      coverage report with no unowned site. Re-run T005's reproduction: it now fails AmendmentAuthority, and with a conforming record passes it (SC-002).

---

## Phase 3: Guidance, retirement of the limit, flow-down and measurement (US3; FR-008, FR-009, FR-010)

**Purpose**: say in the documents that stated the limit what is now graded and what stays open, tell adopters, close GAP-032, and replay real history to show no
merge is newly failed. No script changes.

**Territory**:

- `docs/sdlc/critical-delivery.md`
- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/digests/**`
- `specs/025-critical-merge-ready-signal/plan.md`

- [ ] T011 Read constitution I for any sentence about merge commits or about who authors a merge; record in `notes.md` whether an amendment is needed
      (expected: none, plan D11).
- [ ] T012 Update `docs/sdlc/critical-delivery.md` (the declaration paragraph of feature 025 and its limits: a `pending` added inside a merge is now graded when
      the merge authored it, what stays open) and add or amend the digest markers beside it (each within 120 characters); never hand-edit `docs/digests/**`.
- [ ] T013 Amend feature 025's `plan.md` (its D5 limit and its Risks bullet on merge commits) to say the limit is retired by feature 026 and what remains,
      **with `**Amendment approved by**: <name>, <date>` in the amended section and the approver named in the commit message; this needs the owner's approval
      before the commit, and the agent never approves its own amendment** (constitution I).
- [ ] T014 Add a flow-down note to `adoption/updating.md` shaped like feature 025's (what was wrong, what it does now, what flows down, what an owner may newly
      see, what does not change, the known limits, what was measured, what to do), stating the narrowing of feature 014's D7, the git 2.38 requirement and the
      fail-closed fallback, the object-database side effect of `merge-tree --write-tree`, and that the record remains a written claim. Every path in it resolves
      in an adopted project (doc-lint).
- [ ] T015 Update `docs/roadmap.md`: the GAP-032 inventory row's status, its roadmap row to `shipped`, and a decisions-log entry dated the day the feature
      ships (recording the owner's decisions on shape A, the sub-decision, D2, D3, D4 and the phase count). Run `pwsh -File scripts/build-digests.ps1` and commit
      the regenerated `docs/digests/**`.
- [ ] T016 Measurement (plan D10, FR-009, SC-001): clones of FitForge, FlowBoard and ExpenseTracker made from their local directories (never the real
      projects, nothing pushed), and the kit's own repository; run the parent kit's `enforcement-pack.ps1` and the new one with the analysis replay
      (`-ReplayBase`, `-ReplayTip`, `-IgnoreAmendmentBoundary`) over every `NNN-*` branch range, each version placed inside the clone; report per history the merge
      commits in range, the merges the new rule grades, the failures that are new, and the run time on the largest. Say plainly what it shows and does not show
      (history before this feature carries no merge approver records; the earlier combined-diff count was 0 of 131).
- [ ] T017 Final run on an isolated checkout of the final commit (a detached `git worktree` outside the repository, removed afterwards): the full harness,
      `ritual-checks.ps1 -Branch 026-merge-commit-amendment-grading`, and `scope-check.ps1` on each phase commit. Record the numbers in `notes.md`. The owner then
      runs the gate.

---

## Dependencies & Execution Order

- Phase 2 needs phase 1 (its fixtures use the merge-content field). Phase 3 needs phase 2 (the guidance describes what shipped and the measurement runs the
  changed script).
- Within a phase, fixtures and self-tests are written and shown failing before the behaviour lands (T002 before T003, T006 before T008).
- T013 needs the owner's approval of the wording before it is committed.

## Implementation Strategy

MVP is phase 2 with phase 1 beneath it: the check, proved. Phase 3 can be dropped without touching the others. Stop after each phase for the owner's gate
(`Gate Certification: user-run`, no batching); one phase at a time, never ahead.
