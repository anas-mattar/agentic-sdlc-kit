---

description: "Task list for feature 024 — a Critical feature's branch is not red from its first commit"
---

# Tasks: A Critical feature's branch is not red from its first commit

**Input**: `specs/024-critical-branch-not-red/spec.md`, `plan.md` (decisions D1–D8)
**Prerequisites**: spec.md approved (anas.m, 2026-10-13, shape B); plan.md approved (anas.m, 2026-10-13), including D3
(the precondition: phase commits `1..k`, `k` below the final phase) and D7 (one red run at the final phase) before phase 1
starts; no new dependency, no new script file.

**Tests**: every rule ships with a passing and a failing harness fixture in the same phase as the behaviour, expectations
written by hand (feature 015). New fixtures are run against the parent commit before the code changes and must fail there,
so each is shown to measure something. Phase evidence goes in `notes.md`, never here.
Rule ids: `CRIT-R01` to `CRIT-R06` (R for readiness; `CRIT-S*` and `CRIT-T*` are the existing arms).

**Organization**: two phases, each independently revertible. Phase 2 must be reverted before phase 1. The full harness is
run on an isolated checkout of the final commit, never in a working directory someone is using.

---

## Phase 1: The merge-ready gate and its proof (US1, US2; FR-001–FR-005)

**Purpose**: `Invoke-CriticalEvidenceCheck` warns instead of failing while a Critical branch is mid-feature, and behaves exactly
as before once it is merge-ready or whenever merge-readiness cannot be shown; each state is proved by a fixture pair. A
non-Critical branch and every pre-existing `CRIT-*` case are unchanged.

**Territory**:

- `scripts/enforcement-pack.ps1`
- `tests/**`

**Amendment approved by**: anas.m, 2026-10-13
**Amendment approved by**: anas.m, 2026-10-13 (T004 reworded after the phase 2 measurement)

- [ ] T001 Record the baseline on the parent commit in `notes.md`: the full harness count, the coverage report's
      exempt-rule count and site counts, and the exact enforcement-pack output and exit on a throwaway Critical branch at
      its first phase commit with no artifact, in both arms (the red run this feature removes). Confirm from
      `tests/enforcement/lib/FixtureRepo.psm1` that a recipe commit can carry its subject (the `phase N` token), and that
      `ritual-checks.ps1` passes a `WARNING:` line from the pack through without reading it as a failure (plan D4); if a
      recipe field is missing, add it with its self-test in this phase and say so in `notes.md`.
- [ ] T002 Write the fixtures first (plan D6, Testing Strategy), under `tests/enforcement/cases/`: a pair for each of
      `CRIT-R01` (team arm, a three-phase `tasks.md`, tip at `phase 2`: `WARN`, exit 0; the fail is the same branch with the
      `phase 3` commit), `CRIT-R02` (solo arm likewise), `CRIT-R03` (no `tasks.md`: strict), `CRIT-R04` (phase headings 1, 2, 4:
      strict), `CRIT-R05` (the final phase's heading only inside a fenced block: strict), `CRIT-R06` (a shallow clone or no
      diff base: strict); each pair differs only in the condition. Expectations by hand. Run them on the parent commit and
      record that each `fail` fails there for the stated reason and each `pass` passes or, for the `WARN` pairs, that the
      parent exits 1 where the new behaviour exits 0.
- [ ] T003 Inventory the rules: add `CRIT-R01` to `CRIT-R06` to `tests/enforcement/rules.json` with each rule's anchor and
      law; add the new warning's entry to `tests/enforcement/emission-idioms.json` the way `PhaseSizeWarning` is; run the
      recall sweep first and classify anything else it reports (a rule with a pair, an exemption, or a not-a-rule with a reason).
- [ ] T004 Edit `scripts/enforcement-pack.ps1` (plan D1–D4): add `Get-CriticalMergeReadiness` (final phase from the committed
      `tasks.md` through `Get-VisibleFromText`, headings `^##\s+Phase\s+(\d+)\b` contiguous from 1; commit subjects
      read with one token `\bphases?\s*(\d+)` anywhere in a subject: below the final phase it shows the branch is
      mid-feature, at or above it the final phase has landed (plan D3 as amended, twice); distinct heading numbers exactly 1 to
      N, duplicates allowed (plan D2 as amended); an artifact already committed ending the pending state;
      the D3 precondition; every undeterminable state strict with its reason), give
      `Invoke-CriticalEvidenceCheck` a `-Base` parameter and the gate in front of the two arms, and pass `-Base $diffBase`
      from the dispatch. The two arms are not edited. State the residual limit (plan Risks) in the script header.
- [ ] T005 Run `-Case CRIT-`, `-Case RIT-`, the full harness and `ritual-checks.ps1`: every pre-existing case unchanged,
      every new fixture as written, the coverage report with no unowned site. Re-run T001's throwaway branch: `WARN` and
      exit 0 at the first phase, today's failure at the final phase, byte-identical output once the artifact is valid
      (SC-001, SC-003).

---

## Phase 2: Guidance, flow-down and bookkeeping (US3; FR-006, FR-007)

**Purpose**: say in the law documents what the check now does, tell adopters what flows down and what they may newly see,
prove with a measurement that no non-Critical branch moves, and close the roadmap row. No script changes.

**Territory**:

- `docs/sdlc/critical-delivery.md`
- `docs/sdlc/definition-of-done.md`
- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/digests/**`

- [ ] T006 Read constitution X for any sentence that says when the independence artifact is demanded; record in `notes.md`
      whether an amendment is needed (expected: none). Then update `docs/sdlc/critical-delivery.md` (item 5 and the evidence
      paragraph) and `docs/sdlc/definition-of-done.md` item 6 to say what the check now does: pending and `WARN` before the
      final phase, owed from the final-phase commit, strict when merge-readiness cannot be shown; add or amend the digest
      markers beside them (each within 120 characters) and never hand-edit `docs/digests/**`.
- [ ] T007 Add a flow-down note to `adoption/updating.md` shaped like feature 022's and 023's (what was wrong, what it does
      now, what flows down, what may newly be seen, what does not change, what was measured, what to do), stating the
      residual limit of plan Risks. Every path in it resolves in an adopted project (doc-lint).
- [ ] T008 Update `docs/roadmap.md`: GAP-022 status text, a decisions-log entry dated the day the feature ships (recording the
      owner's decisions on shape B, D3 and D7), and this feature's row to `shipped`. Run
      `pwsh -File scripts/build-digests.ps1` and commit the regenerated `docs/digests/**`.
- [ ] T009 Measurement (plan D8, SC-003): clones of FitForge, FlowBoard and ExpenseTracker made from their local directories
      (never the real projects, nothing pushed), the kit as of the parent of this feature applied, then the kit as it
      stands, digests rebuilt; in each state run `enforcement-pack.ps1` on every non-Critical branch present, and on
      FitForge's Critical `002` branch if present, plus `doc-lint.ps1` and `ritual-checks.ps1`; list every line that moves in
      `notes.md` with its cause, and say plainly where none moved. Do not edit kit files while `update-kit.ps1` runs.
- [ ] T010 Final run on an isolated checkout of the final commit (a detached `git worktree` outside the repository, removed
      afterwards): the full harness, `ritual-checks.ps1 -Branch 024-critical-branch-not-red`, and `scope-check.ps1` on each
      phase commit. Record the numbers in `notes.md`. The owner then runs the gate.

---

## Dependencies & Execution Order

- Phase 2 needs phase 1 (the guidance describes what shipped, and the measurement runs the changed script).
- Within a phase, fixtures are written and shown failing before the behaviour lands.

## Implementation Strategy

MVP is phase 1: the gate, proved. Phase 2 can be dropped without touching it. Stop after each phase for the owner's gate;
one phase at a time, never ahead.
