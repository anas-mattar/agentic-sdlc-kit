# Tasks: Enforcement Pack

**Input**: Design documents from `specs/002-enforcement-pack/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: This feature ships process-critical CI tooling, not business-domain-critical logic
(constitution VIII), and the kit has no automated-test harness for its own scripts — same
determination `001-delivery-core-amendment` made for `doc-lint.ps1`. Verification is the
fixture-branch checks in `quickstart.md`, run by the user as the gate after each phase
(Definition of Done gate 3).

**Organization**: Phases follow `plan.md`'s three-phase breakdown (script+workflow skeleton,
then two more checks, then merge-gate wiring), not a strict one-phase-per-user-story mapping
— `research.md`'s "Decision: Phase ordering for this feature" records why. Each user story
from `spec.md` is still labeled on its tasks below.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task serves (US1–US5, per `spec.md`)
- Tasks with no `[Story]` label are cross-cutting (verification checkpoints)

---

## Phase 1: Structure Check + Lite-Lane/Abuse Guard + Workflow Skeleton (US1, US2)

**Goal**: Stand up `scripts/enforcement-pack.ps1` with the two highest-priority checks and
wire it into GitHub Actions so every subsequent phase is exercised by real CI, not just local
runs (FR-012).

**Independent Test**: `quickstart.md`'s Phase 1 fixture checks (SC-001, SC-002, and the
"clean fixture passes" portion of SC-004) all pass; pushing the phase's commit shows the
workflow run in the GitHub Actions tab.

- [ ] T001 [US1] Create `scripts/enforcement-pack.ps1` with a `param()` block, the single
      config block from `data-model.md` (dependency-manifest/auth/schema/contracts globs,
      `AbuseGuardFileCount=25`, `CoolingOffHours=24`, `PhaseWarnLines=400`,
      `PhaseWarnFiles=15`), current-branch detection (`git rev-parse --abbrev-ref HEAD`,
      overridable via `-Branch`), and a dispatcher that routes to per-taxonomy checks
      (`NNN-*` vs `fix/*`/`chore/*` vs unrecognized prefix, per spec.md's Edge Cases) —
      matching `scripts/doc-lint.ps1`'s style (`Write-Host` messages, exit 0/1).
- [ ] T002 [US1] In `scripts/enforcement-pack.ps1`, implement the Structure check (FR-002):
      for a `NNN-*` branch, verify `specs/NNN-name/spec.md`, `plan.md`, `tasks.md` all exist
      and that `spec.md`'s `**Delivery Level**:` header is filled with exactly `Lite`,
      `Standard`, or `Critical` (not the template placeholder) — fail naming whichever is
      missing/unfilled (depends on T001).
- [ ] T003 [P] [US2] In `scripts/enforcement-pack.ps1`, implement the Lite-lane prohibition
      check (FR-003): for a `fix/*` or `chore/*` branch, diff against
      `git merge-base HEAD origin/main` (research.md §2) and fail, naming the file and
      category, if any changed path matches the dependency-manifest, auth, schema/migration,
      contracts, or (when filled) domain-invariants glob from the config block (depends on
      T001).
- [ ] T004 [P] [US2] In `scripts/enforcement-pack.ps1`, implement the abuse guard (FR-004),
      independent of T003's category match: fail if the same diff touches any
      schema/migration path regardless of file count, or if the number of changed files
      exceeds `AbuseGuardFileCount`, with a message suggesting promotion to a numbered
      feature (depends on T001).
- [ ] T005 [P] Create `.github/workflows/enforcement-pack.yml`: triggers on `push` and
      `pull_request` targeting `main`, checks out with `fetch-depth: 0` (required for
      merge-base and later git-log dating, research.md §2/§4), runs
      `pwsh -File scripts/enforcement-pack.ps1`, fails the job on non-zero exit (FR-008).
- [ ] T006 Run `quickstart.md`'s Phase 1 fixture checks and confirm the workflow fires on
      GitHub after pushing; fix any failures before proceeding to Phase 2 (depends on
      T001–T005).

**Checkpoint**: Phase 1 complete when T006 passes clean — structural drift and Lite-lane
abuse are now caught by CI, not by a human noticing first.

---

## Phase 2: Critical-Evidence Check + Phase-Size Warning (US3, US4)

**Goal**: Add the two remaining checks as pure extensions of the same script — no change to
Phase 1's logic.

**Independent Test**: `quickstart.md`'s Phase 2 fixture checks (SC-003, SC-005) pass.

- [ ] T007 [US3] In `scripts/enforcement-pack.ps1`, implement the Critical-evidence check
      (FR-005): for a `NNN-*` branch whose `spec.md` declares `Delivery Level: Critical`,
      fail if `specs/NNN-name/second-model-review.md` does not exist; if it exists, resolve
      its recorded time via `git log --follow --format=%aI -- <path> | Select-Object -Last 1`
      (research.md §4) and fail if less than `CoolingOffHours` have elapsed; pass (or skip
      for non-Critical features) otherwise — each failure naming the missing artifact or the
      remaining cooling-off time (depends on T001, independent of T002–T004's files).
- [ ] T008 [US4] In `scripts/enforcement-pack.ps1`, implement the phase-commit diff-size
      warning (FR-006): for a `NNN-*` branch, walk each commit via `git log --numstat` and
      emit a non-blocking warning (never affecting the exit code) for any commit exceeding
      `PhaseWarnLines` lines or `PhaseWarnFiles` files (depends on T001, independent of
      T007).
- [ ] T009 Run `quickstart.md`'s Phase 2 fixture checks; fix any failures before proceeding
      to Phase 3 (depends on T007, T008).

**Checkpoint**: Phase 2 complete when T009 passes clean — all four scripted checks (FR-002
through FR-006) are implemented and CI-verified.

---

## Phase 3: Merge-Gate Wiring (US5)

**Goal**: Make the pack an actual merge gate on GitHub, not just an informative CI run.

**Independent Test**: `quickstart.md`'s Phase 3 manual verification (SC-006, SC-007) against
this live repository.

- [ ] T010 [P] [US5] Create `.github/PULL_REQUEST_TEMPLATE.md` embedding the checklist items
      from `specs/_templates/human-pr-review-template.md` plus a `**Gate exit code**:
      EXIT: ___` field directly below the existing "Gate Result" item (FR-009,
      research.md §7).
- [ ] T011 [P] [US5] Create `docs/sdlc/branch-protection.md`: numbered steps for configuring
      GitHub branch protection on `main` to require the `enforcement-pack` workflow as a
      passing status check before merge (FR-010, research.md §7).
- [ ] T012 Follow `quickstart.md`'s Phase 3 steps against this repository: apply the recipe
      from T011, open a throwaway PR from a deliberately failing fixture branch, confirm the
      merge button is disabled (SC-006) and the PR description is pre-populated from T010's
      template (SC-007), then close the PR and delete the branch without merging (depends on
      T010, T011).

**Checkpoint**: Phase 3 complete when T012 passes — the enforcement pack now blocks a bad
merge on GitHub itself (FR-012), not just in a local script run.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1**: No dependencies — can start immediately.
- **Phase 2**: Extends `scripts/enforcement-pack.ps1` from Phase 1; per this feature's own
  controlled-delivery rule, do not start until Phase 1's checkpoint (T006) passes and the
  user approves.
- **Phase 3**: Depends on Phase 1's workflow (T005) existing and running reliably — wiring
  branch protection to an unproven check would be premature. Do not start until Phase 2's
  checkpoint (T009) passes and the user approves.

### Within Each Phase

- Tasks marked `[P]` touch different files (or, within `scripts/enforcement-pack.ps1`,
  independent functions with no shared state) and can be done in any order.
- Verification tasks (T006, T009, T012) always run last in their phase.

## Parallel Example: Phase 1

```text
Task: "T003 [US2] Implement Lite-lane prohibition check in scripts/enforcement-pack.ps1"
Task: "T004 [US2] Implement abuse guard in scripts/enforcement-pack.ps1"
Task: "T005 Create .github/workflows/enforcement-pack.yml"
# T003/T004 are independent functions in the same file (no shared state); T005 is a
# different file entirely. T002 runs first since T003/T004 build on T001's dispatcher,
# same as T002.
```

## Implementation Strategy

### Incremental Delivery

1. Phase 1 → verify (T006) → request user gate + `git diff --stat` review → commit.
2. Phase 2 → verify (T009) → request user gate + `git diff --stat` review → commit.
3. Phase 3 → verify (T012) → request user gate + `git diff --stat` review → commit.
4. Push the feature branch, then request the single feature-level human review and merge.

### MVP Scope

Phase 1 alone already delivers the highest-blast-radius protection (US1: no more silently
incomplete feature branches; US2: no more Lite-lane drift) — if this feature had to stop
after one phase, Phase 1 is the minimum viable increment. Phases 2 and 3 are additive and
narrower in scope (Critical-only; then the merge-gate wiring that makes all of it binding).

## Notes

- No `[P]` task ever shares a file with another `[P]` task in the same phase, except where
  explicitly noted as independent functions within `scripts/enforcement-pack.ps1` (T003/T004
  in Phase 1; T007/T008 in Phase 2) — verified during task generation above.
- Every task names an exact file; there are no "TODO: figure out which file" gaps.
- Commit after each phase (not each task) — the tasks within a phase are one coherent, gated
  unit per this feature's own phase-sizing rule (constitution X).
