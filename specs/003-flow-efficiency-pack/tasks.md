# Tasks: Flow-Efficiency Pack

**Input**: Design documents from `/specs/003-flow-efficiency-pack/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: The business-critical logic in this feature (the two scripts and the new
enforcement-pack check) is verified by the deterministic scripted scenarios in
`quickstart.md` — the same approach 002 used — rather than a unit-test framework the kit
does not have. That determination is recorded here per the template's test policy; every
phase ends with a verification task that runs its quickstart scenarios and must pass
before the phase's gate is requested.

**Organization**: Tasks are grouped into the plan's four implementation phases (one
commit + one user-run gate each). No Setup or Foundational phase is needed — the feature
adds to existing surfaces (`docs/sdlc/`, `scripts/`, `.specify/`) with no shared
prerequisite work. Phase → user story mapping: Phase 1 = US1, Phase 2 = US2 + US3,
Phase 3 = US4, Phase 4 = US5.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1–US5)

---

## Phase 1: Canonical flow page (US1, Priority P1) 🎯 MVP

**Goal**: The whole delivery ritual visible on one page — diagram + step table, each
step linking to the owning document; zero law change.

**Independent Test**: quickstart.md Phase 1 — a reader with only `docs/sdlc/flow.md`
names all five mandatory checkpoints in order; doc-lint fails if the page goes missing.

- [x] T001 [US1] Create `docs/sdlc/flow.md`: ASCII flow diagram (claim → spec → plan →
      tasks → phase loop [implement → gate → scope check → AI review → commit] →
      feature-level human review → merge) plus a `| Step | One line | Owning document |`
      table, and the explicit "owning documents prevail on conflict" note (FR-001,
      FR-002, research D1)
- [x] T002 [US1] Reference the flow page from `CLAUDE.md`: one line in the Workflow
      section intro and a row in the Task-Scoped Reading table (FR-002, FR-010)
- [x] T003 [US1] Add `docs/sdlc/flow.md` to the kit-integrity required-paths list in
      `scripts/doc-lint.ps1` (FR-010)
- [x] T004 [US1] Verification: run quickstart.md Phase 1 scenarios 1–4 (doc-lint green,
      rename-detection, checkpoint read test, CLAUDE.md grep); fix until all pass

**Checkpoint**: request user gate (`scripts/doc-lint.ps1` exit 0) + `git diff --stat`
review → AI review → commit. STOP for user approval before Phase 2.

---

## Phase 2: Claim + territory scripts (US2 + US3, Priority P2)

**Goal**: The two manual multi-developer rituals become one command each; the rituals
themselves are unchanged — the docs now name the scripts as the standard way to run them.

**Independent Test**: quickstart.md Phase 2 — scratch-clone pair scenarios: happy path,
remote-ahead ledger, lost race + renumber, no-remote fallback, dirty-tree refusal,
overlap detection (exit 2), stale-claim flagging.

- [ ] T005 [P] [US2] Implement `scripts/claim-feature.ps1` per
      `contracts/claim-feature-cli.md`: preflight (clean tree, on main), fetch,
      remote+local ledger allocation, delegate to
      `.specify/scripts/powershell/create-new-feature.ps1 -Number`, immediate push,
      race recovery (≤3 renumber attempts), no-remote fallback with warning, `-Json`
      output (FR-003, FR-004, research D2)
- [ ] T006 [P] [US3] Implement `scripts/territory-check.ps1` per
      `contracts/territory-check-cli.md`: fetch, per-open-branch
      `git diff --name-only main...origin/NNN-*` intersection with current branch's
      touched set, live/stale/no-work-yet classification (14-day default), rule-5
      sequencing reminder, exit codes 0/2/1, `-Json` output (FR-005, FR-006, research D3)
- [ ] T007 [P] [US2] Amend `docs/sdlc/branch-strategy.md` "Number Allocation": name
      `scripts/claim-feature.ps1` as the standard way to run the existing 3-step recipe
      (recipe kept as the manual fallback)
- [ ] T008 [US2] Amend `docs/sdlc/team-workflow.md` rule 2 (number reservation) to name
      `scripts/claim-feature.ps1`
- [ ] T009 [US3] Amend `docs/sdlc/team-workflow.md` rule 5 (territory check) to name
      `scripts/territory-check.ps1` and its exit-code contract (same file as T008 —
      sequential, not parallel)
- [ ] T010 [US2] Add both new scripts to the kit-integrity required-paths list in
      `scripts/doc-lint.ps1` (FR-010)
- [ ] T011 [US2] Verification: run quickstart.md Phase 2 scenarios 1–7 against a scratch
      clone pair under the session scratchpad (never the real remote); fix until all pass

**Checkpoint**: request user gate + `git diff --stat` review → AI review → commit.
STOP for user approval before Phase 3.

---

## Phase 3: Pipelining clause (US4, Priority P3)

**Goal**: A developer whose feature is awaiting review may start the next one — the WIP
limit is relaxed for the review-wait state under explicit conditions, not deleted.

**Independent Test**: quickstart.md Phase 3 — the amended rule text answers all three
scenarios (awaiting-review → may claim; mid-phase → may not; change requests mid-phase →
finish current phase, then return) without a judgment call.

- [ ] T012 [US4] Amend `docs/sdlc/team-workflow.md` rule 3 WIP limit with the pipelining
      clause: second claim allowed only when the first feature has all phases committed
      gate-green, is pushed, and review is formally requested; cap = one awaiting-review
      + one active; territory disjoint from (or explicitly sequenced behind) the first;
      change requests → finish current phase to gate-green, then return before any
      further phase (FR-007, research D6, data-model Pipeline State)
- [ ] T013 [US4] Update `docs/sdlc/flow.md` with a short parallel-work note pointing to
      the amended rule 3 (page stays non-authoritative)
- [ ] T014 [US4] Verification: run quickstart.md Phase 3 scenarios 1–4 (three-scenario
      walk + doc-lint); fix until all pass

**Checkpoint**: request user gate + `git diff --stat` review → AI review → commit.
STOP for user approval before Phase 4.

---

## Phase 4: Batched gate (US5, Priority P3)

**Goal**: Opt-in batched certification for Lite/Standard features (max 3 consecutive
phases per batch), via a constitution X amendment with all mirrors synced and a
merge-blocking enforcement check; Critical provably untouched.

**Independent Test**: quickstart.md Phase 4 — constitution at 0.4.0 with clause; all
four mirrors agree; enforcement fixtures: Critical+batch FAILS, span>3 FAILS,
none/absent passes (001/002 plans unchanged).

- [ ] T015 [US5] Amend `.specify/memory/constitution.md`: add the Batched-gates clause
      to principle X (Lite/Standard only; declared in the approved plan before the batch
      starts; max 3 consecutive phases; per-phase commit/scope-check/AI-review retained;
      agent-run feedback gates per phase; one certifying user-run gate at batch end;
      Critical excluded), bump 0.3.0 → 0.4.0, update the SYNC IMPACT REPORT (FR-008,
      FR-009, research D5)
- [ ] T016 [P] [US5] Sync `.specify/templates/plan-template.md`: Constitution Check X
      item mirrors the amended wording; add the `**Gate Batching**: none | phases N-M`
      declaration line to the template (data-model Gate Batch; depends on T015 wording)
- [ ] T017 [P] [US5] Amend `docs/sdlc/definition-of-done.md` gate 3 with the batched
      option (one user-run gate certifies a declared batch; per-phase obligations 1–2
      and 4–5 unchanged; Critical excluded) (depends on T015 wording)
- [ ] T018 [P] [US5] Amend `docs/sdlc/gate-command.md` with a "Batched gates" section
      (when allowed, what the owner runs, agent feedback gates unchanged) (depends on
      T015 wording)
- [ ] T019 [P] [US5] Amend `docs/sdlc/critical-delivery.md` with the explicit
      prohibition: Critical features never batch; a declared batch on a Critical
      feature fails the enforcement pack (depends on T015 wording)
- [ ] T020 [P] [US5] Implement the GateBatching check in `scripts/enforcement-pack.ps1`:
      parse the `**Gate Batching**` line from the feature's plan.md (absent ⇒ none);
      FAIL on Critical + batch; FAIL on span > 3 or non-consecutive span; same
      bold-field parser shape as the existing Delivery Level check (FR-009, research D4)
- [ ] T021 [P] [US5] Update `docs/sdlc/flow.md` gate step with a one-line batched-gate
      note (page stays non-authoritative)
- [ ] T022 [US5] Verification: run quickstart.md Phase 4 scenarios 1–4 (version +
      clause, mirror consistency FR-011, enforcement fixtures on a scratch branch,
      backward compatibility against specs/001-* and specs/002-*, doc-lint +
      enforcement-pack green on this branch); fix until all pass

**Checkpoint**: request user gate + `git diff --stat` review → AI review → commit. Then
push the branch and request the single feature-level human review (DoD gate 6) — this
review is also the human approval that adopts the constitution amendment.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1**: No dependencies — can start immediately after tasks.md approval.
- **Phase 2**: Independent of Phase 1's content, but per the kit's controlled-delivery
  law, starts only after Phase 1's checkpoint passes and the user approves.
- **Phase 3**: Amends the same file Phase 2 touches (`docs/sdlc/team-workflow.md`) —
  starts only after Phase 2's checkpoint passes and the user approves.
- **Phase 4**: The largest and only constitution-touching slice; deliberately last.
  Starts only after Phase 3's checkpoint passes and the user approves.

**This feature does NOT use batched gates for itself** — the current constitution X
(per-phase user gate) governs all four phases; the amendment only takes effect for
future features after this feature merges.

### Within Each Phase

- Tasks marked [P] touch different files and can be done in any order; T016–T021 all
  depend on T015 fixing the clause's final wording first.
- T008 → T009 are sequential (same file).
- Verification tasks (T004, T011, T014, T022) always run last in their phase.

## Parallel Example: Phase 4

```text
# After T015 (constitution wording) lands:
Task: "T016 Sync plan-template.md Constitution Check + Gate Batching line"
Task: "T017 Amend definition-of-done.md gate 3"
Task: "T018 Amend gate-command.md batched-gates section"
Task: "T019 Amend critical-delivery.md prohibition"
Task: "T020 Implement GateBatching check in scripts/enforcement-pack.ps1"
Task: "T021 Update flow.md gate note"
# Six different files, no shared state — all parallelizable once T015 is done.
```

## Implementation Strategy

### Incremental Delivery

1. Phase 1 → verify (T004) → user gate + `git diff --stat` → AI review → commit.
2. Phase 2 → verify (T011) → user gate + `git diff --stat` → AI review → commit.
3. Phase 3 → verify (T014) → user gate + `git diff --stat` → AI review → commit.
4. Phase 4 → verify (T022) → user gate + `git diff --stat` → AI review → commit.
5. Push the branch; request the single feature-level human review; merge on approval.

### MVP Scope

Phase 1 alone (the flow page) already delivers the user's core "clear flow" complaint
with zero risk — if this feature had to stop after one phase, that is the minimum viable
increment. Each later phase adds an independent capability: automation (2), pipelining
law (3), batching law + enforcement (4).

## Notes

- No [P] task shares a file with another [P] task in the same phase (verified above;
  T008/T009 and T015 are explicitly sequential).
- Every task names an exact file; no "figure out which file" gaps.
- Commit after each phase, not each task — each phase is one coherent, gated unit per
  the phase-sizing rule (constitution X).
