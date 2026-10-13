---

description: "Task list for feature 025 — a merge-ready signal for a Critical feature that a commit subject cannot give"
---

# Tasks: A merge-ready signal for a Critical feature that a commit subject cannot give

**Input**: `specs/025-critical-merge-ready-signal/spec.md`, `plan.md` (decisions D1–D9)
**Prerequisites**: spec.md approved (anas.m, 2026-10-13, option A); plan.md approved (anas.m, 2026-10-13), including D2 (`pending`
bypasses feature 024's history-dependent strict states), D7 (`ready` means "owed now") and D9 (the template ships the line absent)
before phase 1 starts; no new dependency, no new script file.

**Tests**: every rule ships with a passing and a failing harness fixture in the same phase as the behaviour, expectations
written by hand (feature 015). New fixtures are run against the parent commit before the code changes and must fail there,
so each is shown to measure something. **At least one fixture per rule is shaped from FitForge 002** (its headings, its
subjects, its out-of-order phase), not from the kit's conventions (plan D8). Phase evidence goes in `notes.md`, never here.
Rule ids: `CRIT-R03` (the declared `pending` warning) plus new variants of `CRIT-R02` and the `AMEND-*` rules.

**Organization**: two phases, each independently revertible. Phase 2 must be reverted before phase 1. The full harness is
run on an isolated checkout of the final commit, never in a working directory someone is using.

---

## Phase 1: The marker and its proof (US1, US2; FR-001–FR-007)

**Purpose**: `Get-CriticalMergeReadiness` reads `**Merge Readiness**` from the committed `plan.md` and lets it override feature
024's commit-subject heuristic; the amendment-authority check is shown by fixtures to grade a change to the line. A branch that
declares nothing, a non-Critical branch and every pre-existing `CRIT-*` case are unchanged.

**Territory**:

- `scripts/enforcement-pack.ps1`
- `tests/**`

- [ ] T001 Record the baseline on the parent commit in `notes.md`: the full harness count, the coverage report's exempt-rule
      count and site counts, and the exact enforcement-pack output and exit on a throwaway Critical branch shaped like
      FitForge 002 (a high-numbered phase landed early, `tasks: phase N done` subjects, duplicate
      `## Phase N amendment requests` headings) with no marker, in both arms. Read `AMEND-001` and `AMEND-002` in
      `tests/enforcement/cases/` for the amendment recipe, and confirm from `tests/enforcement/lib/FixtureRepo.psm1` that a
      recipe can carry a commit subject, a plan edit after creation, and a depth-1 clone; if a recipe field is missing, add it
      with its self-test in this phase and say so in `notes.md`.
- [ ] T002 Write the fixtures first (plan D8), under `tests/enforcement/cases/`, each pair differing in one condition:
      `CRIT-R03` pass = `pending` on the FitForge-shaped branch of T001 (WARN, exit 0), fail = the same branch with `ready`
      (today's failure); variants for the solo arm, `pending` with a committed invalid artifact (the arm fails it), `pending` in a
      depth-1 clone (still warns, D2), `pending` with a final-phase token in the subjects (the override 024 could not do), a
      marker inside a comment or a fence (hidden, so 024's heuristic decides), and a Standard feature carrying `pending`
      (ignored, D4); `CRIT-R02` variants for two marker lines, an unknown value (`done`) and an empty value (strict with the
      `not treated as mid-feature` reason); `AMEND-*` variants per D5 (an unapproved `pending` to `ready` change fails, an
      approved one passes, an unapproved addition of the marker to an existing plan fails; a marker added in the commit that
      creates `plan.md` is exempt). Expectations by hand. Run them on the parent commit and record that each `fail` fails there
      for the stated reason and each `pass` passes or, for the `WARN` cases, that the parent exits 1 where the new behaviour
      exits 0. If an `AMEND-*` fixture shows the check does not reach the header line, stop and amend the plan before the code
      (D5, FR-006).
- [ ] T003 Inventory the rules: add `CRIT-R03` (`siteCount: 2`, anchor `declares **Merge Readiness**: pending`) to
      `tests/enforcement/rules.json` with its law, and the new warning's entry to `tests/enforcement/emission-idioms.json` the way
      feature 024's warning is; run the recall sweep first and classify anything else it reports (a rule with a pair, an
      exemption, or a not-a-rule with a reason).
T004 grammar follows plan D1 as amended (an empty value is strict).

**Amendment approved by**: anas.m, 2026-10-14

- [ ] T004 Edit `scripts/enforcement-pack.ps1` (plan D1–D4): in `Get-CriticalMergeReadiness`, after the "artifact committed at
      `HEAD`" step and before the history-dependent steps, read the committed plan with `git show "HEAD:./specs/$Branch/plan.md"`
      through `Get-VisibleFromText`, grammar `^\*\*Merge Readiness\*\*:\s*(.*?)\s*$` (an empty value is a malformed marker, strict), value compared exactly; `ready` returns
      `Pending = $false` with no reason, `pending` returns `Pending = $true` with `Declared = $true` (bypassing the
      history-dependent states), any other value or two lines returns `Pending = $false` with a reason, absent or unreadable falls
      through unchanged. Add the declared-`pending` warning text at the two emission sites of `Invoke-CriticalEvidenceCheck`
      (one per arm). The two arms, the function's signature and `Invoke-AmendmentAuthorityCheck` are not edited (unless T002's
      `AMEND-*` fixture required the plan amendment). State the residual limit (plan Risks: `pending` is a claim) in the script
      header.
- [ ] T005 Run `-Case CRIT-`, `-Case AMEND-`, `-Case RIT-`, the full harness and `ritual-checks.ps1`: all 34 feature 024 cases and
      the `CRIT-S*`/`CRIT-T*` cases pass unchanged, every new fixture as written, the coverage report with no unowned site. Re-run
      T001's throwaway branch: no marker is byte-identical to the baseline (FR-004, SC-001); `pending` warns and exits 0; `ready`
      is today's failure.

---

## Phase 2: Guidance, template, flow-down and measurement (US3; FR-008, FR-009)

**Purpose**: say in the law documents what the check now does, ship the optional template line, tell adopters what flows down,
replay FitForge 002's real history, and close the roadmap row. No script changes.

**Territory**:

- `docs/sdlc/critical-delivery.md`
- `docs/sdlc/definition-of-done.md`
- `.specify/templates/plan-template.md`
- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/digests/**`

- [ ] T006 Read constitution X for any sentence that fixes the set of plan header fields or the timing of the independence
      artifact; record in `notes.md` whether an amendment is needed (expected: none, D6). Then update
      `docs/sdlc/critical-delivery.md` (a paragraph under item 5 beside feature 024's: the marker, what each value does, that
      `ready` is "owed now" not "approved", that `pending` is a claim and gate 6 stands behind it) and
      `docs/sdlc/definition-of-done.md` item 6 if it states when the artifact is demanded; add or amend the digest markers
      beside them (each within 120 characters) and never hand-edit `docs/digests/**`.
- [ ] T007 Add the optional `**Merge Readiness**` line to `.specify/templates/plan-template.md`, shipped absent or commented out
      with a one-line explanation (D9), so no new feature changes behaviour silently. Confirm `kit-manifest.json` already classes
      `.specify/templates/**` as `verbatim` and needs no entry.
- [ ] T008 Add a flow-down note to `adoption/updating.md` shaped like feature 024's (what was wrong, what it does now, what flows
      down, what may newly be seen, what does not change, what was measured, what to do), stating the cost: `pending` is a claim
      an owner can leave in place. Every path in it resolves in an adopted project (doc-lint).
- [ ] T009 Update `docs/roadmap.md`: GAP-022 status text (what is now closed and what stays open), a decisions-log entry dated the
      day the feature ships (recording the owner's decisions on D2, D7 and D9), and this feature's row to `shipped`. Run
      `pwsh -File scripts/build-digests.ps1` and commit the regenerated `docs/digests/**`.
- [ ] T010 Measurement (plan D8, FR-009, SC-002): in a scratch clone of FitForge (made from its local directory, never the real
      project, nothing pushed), replay the real 43 commits of `002`, each with a throwaway commit injecting
      `**Merge Readiness**: pending` (and `ready` at the last); record the `CriticalEvidence` line at each, beside feature 024's
      result at the same commits (17 warn of 43). Also run the kit's script on non-Critical branches in clones of FlowBoard and
      ExpenseTracker and list every line that moves with its cause, or say plainly that none moved. State what an injection
      shows (the mechanism on real shapes, not that an owner will use it); the throwaway commits' own AmendmentAuthority
      failures are expected and not counted.
- [ ] T011 Final run on an isolated checkout of the final commit (a detached `git worktree` outside the repository, removed
      afterwards): the full harness, `ritual-checks.ps1 -Branch 025-critical-merge-ready-signal`, and `scope-check.ps1` on each
      phase commit. Record the numbers in `notes.md`. The owner then runs the gate.

---

## Dependencies & Execution Order

- Phase 2 needs phase 1 (the guidance describes what shipped, and the measurement runs the changed script).
- Within a phase, fixtures are written and shown failing before the behaviour lands (T002 before T004).
- T002 may force a plan amendment (D5) before T004; if so, it needs an approver record like any amendment.

## Implementation Strategy

MVP is phase 1: the marker, proved. Phase 2 can be dropped without touching it. Stop after each phase for the owner's gate
(`Gate Certification: user-run`, no batching); one phase at a time, never ahead.
