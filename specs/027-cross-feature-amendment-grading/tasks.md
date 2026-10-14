---

description: "Task list for feature 027 — grade amendments of another feature's approved documents in the amendment-authority check"
---

# Tasks: Grade amendments of another feature's approved documents in the amendment-authority check

**Input**: `specs/027-cross-feature-amendment-grading/spec.md`, `plan.md` (decisions D1–D11)
**Prerequisites**: spec.md approved (anas.m, 2026-10-14, option B, removal accepted); plan.md approved (anas.m, 2026-10-14), including D2 ("exists at the diff
base"), D3 (the own directory keeps its code), D6 (the Lite gate is the changed-file list), D8 (UNGRADED on the Lite lane) and three phases, before phase 1
starts; no new dependency, no new script file.

**Tests**: every rule ships with a passing and a failing harness fixture in the same phase as the behaviour, expectations written by hand (feature 015). New
fixtures are run against the parent commit before the code changes and must fail there (or be named controls that pass there by design), so each is shown to
measure something. **Fixtures are built from field shapes** (plan D9): 026's reproduction, a `Merge branch 'main' into NNN-...` merge that brings another
feature's documents, a claim branch, a renumbering. Each fixture that guards a branch of the new code is also shown failing under a mutation of that code, and
the code is restored byte for byte (feature 025's method). Phase evidence goes in `notes.md`, never here. Rule ids: variants of `AMEND-001` and `AMEND-002`
(phase 1), the new `AMEND-009` and `LITE-*` variants (phase 2).

**Organization**: three phases, each independently revertible. Phase 3 must be reverted before phase 2, and phase 2 before phase 1. The full harness is run on
an isolated checkout of the final commit, never in a working directory someone is using.

---

## Phase 1: Numbered branches grade any feature's documents (US1, US3; FR-001, FR-002, FR-004–FR-007, FR-011, FR-013)

**Purpose**: on an `NNN-*` branch, `Invoke-AmendmentAuthorityCheck` grades a commit's change (ordinary or merge) to a `spec.md`, `plan.md`, `tasks.md` or
`contracts/**` file of **another** feature that exists at the diff base, by the rules the own directory has today. The own directory's code is not rewritten.
Each state is proved by a fixture pair built from real shapes.

**Territory**:

- `scripts/enforcement-pack.ps1`
- `tests/**`

- [ ] T001 Record the baseline on the parent commit in `notes.md`: the full harness count, and the exact output and exit of `AMEND-001/pass`, `AMEND-001/pass-merge`
      and `AMEND-001/pass-renumber`. Reproduce the gap on a throwaway branch: an unapproved line appended to another feature's approved `plan.md` on a numbered
      branch prints `enforcement-pack: OK` (the shape 026's phase 3 review found). Confirm from a recipe that nothing is needed from the fixture library (a base
      holding another feature's documents, a numbered branch, a merge that carries content); if a shape cannot be expressed, add a task for it here.
- [ ] T002 Write the fixtures first (plan D9, numbered lane), as variants of `AMEND-001` and `AMEND-002`, each pair differing in one condition and each shown
      failing on the parent or named as a control that passes there by design: another feature's `plan.md` amended with no record (fail) and with the record in
      that document plus the approver in the message (pass); the record in the branch's own `notes.md`, and in its own plan (fail: it approves nothing); the
      record present and the approver missing from the message (`AMEND-002` pair); a contract of another feature amended; two documents of another feature
      amended in one commit with a record in one (fail, naming the other); another feature's own **and** the branch's own document amended in one commit
      (the failure names both and carries the clause only for the other); a document of another feature **created on this branch** and edited again (control:
      absent at the base); a tick and a `**Status**`-only change in another feature's document (exempt) and a tick with a text rewrite (graded); the whole
      directory of an approved feature renumbered (control); a single document moved from one feature's directory to another's (fail: the old path is graded
      as a removal); an approved document of another feature removed (fail, no passing path); a merge of `main` into the branch where `main` changed another
      feature's `plan.md`, with the shape of the kit's real merges (control, byte-identical); a merge that hand-resolves another feature's `plan.md` without and
      with a record; a merge that deletes another feature's contract while merging. Expectations by hand. Record, for each, how it behaves on the parent.
- [ ] T003 Inventory the rules in `tests/enforcement/rules.json`: update the notes of `AMEND-001` and `AMEND-002` for the cross-feature variants, and run the
      recall sweep first, classifying anything else it reports (a rule with a pair, an exemption, or a not-a-rule with a reason).
- [ ] T004 Edit `scripts/enforcement-pack.ps1` (plan D1–D5, D7, D8 numbered arm): the graded-path pattern and a helper returning a path's feature directory
      (D1); the base set of graded paths read once per run, `$existBase` being `$Base` or `$ReplayBase` (D2); the row loop keeps its existing block for a path in
      `$dir` and gains the parallel arm for another feature's directory in the order of D3 (creation, subject, graded-and-at-the-base, whole-directory
      renumbering, the two existing exemptions); `Get-FeatureDocMap` and `Get-MergeAuthoredPaths` read the graded paths of every feature directory and ask D2
      **first** for a path outside `$dir` (D4); the failure tail gains the one clause of D5, only when an amended path is outside `$dir`, in both failure messages;
      an unreadable base tree is a failure on a numbered branch (D8). Replace the script header's `LIMIT` paragraph with what is now graded and what stays open
      (the Lite lane arrives in phase 2, so the paragraph says so and phase 2 updates it). The own-directory row block, `Get-AddedRecordLines`,
      `Get-MergeRecordLines` and the exemption helpers are not edited.
- [ ] T005 Show a mutation for each fixture that guards a branch of the new code, and record it in `notes.md`: drop the exists-at-the-base test; test existence
      in the commit's parent instead of the base; drop the whole-directory test; read the record from the branch's own files; drop the clause. Each must fail
      exactly the fixture meant to catch it, and the script is restored byte for byte (`cmp`).
- [ ] T006 Run `-Case AMEND-`, `-Case CRIT-`, `-Case LITE-`, the full harness and `ritual-checks.ps1`: every pre-existing case unchanged (FR-013), every new
      fixture as written, the coverage report with no unowned site. Re-run T001's reproduction: it now fails AmendmentAuthority, and with a conforming record
      passes it (SC-001). Time the new merge reading on a real merge of this repository and record it against 026's 170 ms.

---

## Phase 2: The Lite lane (US2; FR-003, FR-008, FR-009)

**Purpose**: a `fix/`, `chore/` or `docs/` branch whose diff touches a spec document is graded by the same arm; a branch whose diff touches none prints exactly
what it prints today, including in a shallow clone; a Lite branch the machine cannot grade is named UNGRADED and never newly failed.

**Territory**:

- `scripts/enforcement-pack.ps1`
- `tests/**`

- [ ] T007 Record the baseline in `notes.md`: the full harness count on the parent of this phase, the exact output of `LITE-001/pass`, `LITE-002/*`, `LITE-003/*`
      and `AMEND-006/*` (the `docs/` lane line), and a throwaway `docs/x` branch amending another feature's approved plan with no record showing exit 0 with no
      amendment line: the gap this phase closes.
- [ ] T008 Write the fixtures first (plan D9, Lite lane), as `LITE-*` variants and the new `AMEND-009`, each shown failing on the parent or named as a control:
      the same cross-feature change on `docs/x`, `fix/x` and `chore/x` without a record (fail) and with one (pass; never a contract path, which LiteAndAbuse
      refuses first, and a fixture saying so); a `docs/x` branch that changes only `README.md` and the roadmap (control, output byte-identical, **in a depth-1
      clone as well**); a `docs/claim-*` branch that adds a feature directory and edits it in a second commit (control); a Lite branch that changes a spec
      document in a shallow clone, and one whose parent tree is unreadable (`AMEND-009`: an `UNGRADED` line, exit 0), each with its numbered-lane twin (the
      existing refusal); the `docs/` lane line when the roll-up printed (it names both checks) and when it did not (unchanged); a Lite branch whose only spec
      change is a creation (control, prints nothing). Expectations by hand.
- [ ] T009 Inventory the rules: add `AMEND-009` to `tests/enforcement/rules.json` with its anchor and law (014 FR-009, plan D8), update the `AMEND-006` and
      `LITE-*` notes for the changed `docs/` line and the Lite variants, and run the recall sweep first.
- [ ] T010 Edit `scripts/enforcement-pack.ps1` (plan D6, D7, D8 Lite arm): a Lite-lane call in the dispatch passing the changed-file list; the check returns
      silently on a Lite branch unless the list contains a graded path (D1); no own directory; the refusals append `UNGRADED` instead of failing; an empty range
      prints nothing; the roll-up prints only when a commit changed a document that exists at the base; the `docs/` lane line names both checks when the roll-up
      printed. Update the `LIMIT` paragraph written in T004. The numbered arm and the own-directory block are not edited.
- [ ] T011 Show a mutation for each fixture that guards a branch of the new code, and record it in `notes.md`: drop the changed-file gate; fail instead of
      UNGRADED on the Lite lane; print the roll-up unconditionally; call the check on `main`. Each must fail exactly the fixture meant to catch it; restore byte for
      byte.
- [ ] T012 Run `-Case AMEND-`, `-Case LITE-`, `-Case PACK-`, `-Case CRIT-`, the full harness and `ritual-checks.ps1`: every pre-existing case unchanged except
      the intended `docs/` line variant, every new fixture as written, no unowned site. Re-run T007's reproduction: the `docs/x` branch now fails, and passes with a
      conforming record (SC-002).

---

## Phase 3: Guidance, retirement of the limit, flow-down and replay (US4; FR-010, FR-014, SC-004)

**Purpose**: say in the documents that state the limit what is now graded and what stays open, tell adopters, close GAP-033, and replay real history per commit,
Lite branches included. No script changes.

**Territory**:

- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/sdlc/branch-strategy.md`
- `docs/sdlc/critical-delivery.md`
- `docs/digests/**`

- [ ] T013 Read constitution I's Amendment authority clause and the Lite-lane text of `docs/sdlc/branch-strategy.md` and `docs/sdlc/critical-delivery.md`;
      record in `notes.md` whether a constitution amendment is needed (expected: none, plan D11) and which sentences are now false.
- [ ] T014 Edit only the sentences T013 found false in `docs/sdlc/branch-strategy.md` and `docs/sdlc/critical-delivery.md` (the Lite lane runs no amendment
      check), with their digest markers within 120 characters; never hand-edit `docs/digests/**`.
- [ ] T015 Add a flow-down note to `adoption/updating.md` shaped like 026's (what was wrong, what it does now, what flows down, what an owner may newly see on a
      numbered and on a Lite branch, what does not change, the known limits — "exists at the base" as a proxy for approved, a move out of the own directory, a
      whole directory moved inside a merge, GAP-034's weakness behind the Lite gate, the record as a written claim — what was measured, what to do), stating that
      026's edge case "a document the merge changes for another feature: not graded" is superseded for documents that exist at the base. Every path in it
      resolves in an adopted project (doc-lint).
- [ ] T016 Update `docs/roadmap.md`: the GAP-033 inventory row and its roadmap row to `shipped` (drop the brackets from the Spec cell), and a decisions-log
      entry dated the day the feature ships (recording the owner's decisions: option B, the removal sub-decision, D1–D11 and the phase count). Run
      `pwsh -File scripts/build-digests.ps1` and commit the regenerated `docs/digests/**`.
- [ ] T017 Replay (plan D10, FR-010, SC-004): clones of FitForge, FlowBoard and ExpenseTracker made from their local directories (never the real projects,
      nothing pushed) and the kit's own repository; run the parent kit's `enforcement-pack.ps1` and the new one with the analysis replay (`-ReplayBase`,
      `-ReplayTip`, `-IgnoreAmendmentBoundary`) over each merged `NNN-*` branch **and** each merged `fix/`, `chore/` and `docs/` branch, per merge in the shape CI
      grades (`<merge>^1..<merge>`), each version placed inside the clone; report per history the commits newly graded, newly failing, **how many of the newly
      failing carry a record in the amended document**, the byte-identity of every other output and the run time on the largest. Say plainly what it shows and
      does not show (plan D10).
- [ ] T018 Final run on an isolated checkout of the final commit (a detached `git worktree` outside the repository, removed afterwards): the full harness,
      `ritual-checks.ps1 -Branch 027-cross-feature-amendment-grading`, and `scope-check.ps1` on each phase commit. Record the numbers in `notes.md`. The owner then
      runs the gate.

---

## Dependencies & Execution Order

- Phase 2 needs phase 1 (the Lite arm calls the same grading). Phase 3 needs phase 2 (the guidance describes what shipped and the replay runs the changed
  script).
- Within a phase, fixtures are written and shown failing before the behaviour lands (T002 before T004, T008 before T010).
- T017 needs the clones of the adopted projects; if one is unavailable the replay says so and does not claim it.

## Implementation Strategy

MVP is phase 1: the check, proved, on numbered branches. Phase 2 closes the lane that carries half the real cases; phase 3 can be dropped without touching the
others. Stop after each phase for the owner's gate (`Gate Certification: user-run`, no batching); one phase at a time, never ahead.
