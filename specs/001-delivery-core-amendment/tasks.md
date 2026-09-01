# Tasks: Delivery Core Amendment

**Input**: Design documents from `specs/001-delivery-core-amendment/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: This feature ships no application code, so there are no unit/integration test
tasks. Verification is the grep- and doc-lint-based checks in `quickstart.md`, run by the user
as the gate after each phase (Definition of Done gate 3).

**Organization**: Phases follow `plan.md`'s three-phase breakdown, not a strict one-phase-per-
user-story mapping — `research.md`'s "Decision: Phase ordering for this feature" records why
(urgency per `review/out/DECISION.md`'s framing, then blast radius). Each user story from
`spec.md` is still labeled on its tasks below.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task serves (US1–US6, per `spec.md`)
- Tasks with no `[Story]` label are cross-cutting (verification checkpoints)

---

## Phase 1: Core Contradiction Fix (US1, US2, US3, US5)

**Goal**: Resolve the unit-of-review contradiction and its three companion defects — the
cluster `review/out/DECISION.md` calls "one amendment, one version bump — do it first."

**Independent Test**: `quickstart.md`'s Phase 1 checks (SC-001–SC-004) all pass, and
`doc-lint.ps1` exits 0.

- [ ] T001 [P] [US1] In `docs/sdlc/definition-of-done.md`, reword gate 6 so it applies once per
      feature at merge, not per phase; keep gates 1–5 explicitly scoped to each phase commit.
- [ ] T002 [P] [US1] In `docs/sdlc/branch-strategy.md`, verify and align the merge/review rule
      with the new gate-6 scope from T001 — no document may imply a conflicting unit of review.
- [ ] T003 [P] [US1] In `docs/sdlc/review-process.md`, align the "After Each Phase" and "Human
      Review" sections so human review reads as feature-level, consistent with T001.
- [ ] T004 [P] [US2] In `.specify/memory/constitution.md`, add `tasks-template.md` to the SYNC
      IMPACT REPORT's "Templates requiring updates when this file changes" list.
- [ ] T005 [P] [US2] In `.specify/templates/tasks-template.md` line 11, replace the "Tests are
      OPTIONAL" instruction with wording consistent with constitution XI (tests required for
      business-critical functionality/calculations/regression coverage; omitted only when the
      feature genuinely has none, documented not assumed).
- [ ] T006 [P] [US3] In `.specify/templates/spec-template.md`, add a required
      `**Delivery Level**: [Lite | Standard | Critical]` header field directly under
      `**Status**: Draft`.
- [ ] T007 [P] [US5] In `CLAUDE.md`, replace the "Source of Truth Priority" section's 7-rung
      restatement with a pointer to constitution II plus the existing conflict-rule prose
      (kept, since it is operational guidance, not a restatement of the ordering).
- [ ] T008 [P] [US5] In `.specify/templates/plan-template.md`, replace the Constitution Check
      line for principle II (the "visual references → spec → plan → contracts → data model"
      5-item paraphrase) with a pointer to constitution II.
- [ ] T009 Run `quickstart.md`'s Phase 1 checks (SC-001–SC-004) and `doc-lint.ps1`; fix any
      failures before proceeding to Phase 2 (depends on T001–T008).

**Checkpoint**: Phase 1 complete when T009 passes clean — the core contradiction is gone.

---

## Phase 2: Missing Rule Definitions (US4, US6)

**Goal**: Define the two rules the review found referenced but never specified.

**Independent Test**: `quickstart.md`'s Phase 2 checks pass; a plan reviewer and a Critical-solo
developer each have a concrete rule to check their work against.

- [ ] T010 [P] [US4] In `.specify/templates/plan-template.md`, add a "Phase sizing" paragraph to
      the Constitution Check's Controlled Delivery line: a phase MUST be independently
      revertible and MUST correspond to one meaningfully independent, testable slice; a plan
      bundling unrelated concerns into one phase fails the gate and must be split before
      approval.
- [ ] T011 [US4] In `docs/sdlc/definition-of-done.md` gate 2 ("Single-phase scope respected"),
      add a cross-reference to the phase-size rule from T010 (depends on T010 for consistent
      wording).
- [ ] T012 [P] [US6] In `docs/sdlc/critical-delivery.md` item 5 ("Independent approval"), name
      the second-model-review artifact (`specs/NNN-name/second-model-review.md`, structured
      like `ai-code-review-template.md` but performed by a different model, explicitly probing
      the implementer's blind spots), a minimum 24-hour cooling-off period before merge, and add
      the sentence: "This substitutes for, but is not equivalent to, independent human review —
      it is a mitigation for the solo-developer case, not a claim of true independence."
- [ ] T013 Run `quickstart.md`'s Phase 2 checks and `doc-lint.ps1`; fix any failures before
      proceeding to Phase 3 (depends on T010–T012).

**Checkpoint**: Phase 2 complete when T013 passes clean — both previously-undefined rules are
now concrete and checkable.

---

## Phase 3: Principle Pruning & Renumbering Sweep

**Goal**: Demote principles V/VI, delete principle X, renumber what remains, and update every
cross-reference — isolated last because it has the widest blast radius and no interaction with
Phases 1–2's content.

**Independent Test**: `quickstart.md`'s Phase 3 checks pass; a repo-wide search for old
principle numbers or deleted-principle references finds nothing outside `review/`.

- [ ] T014 In `.specify/memory/constitution.md`, delete principles V (Data Standards) and VI
      (Auditability); carry their normative content (PK standard, audit fields, soft-delete
      rule) into `docs/rulebooks/database-rules-template.md`'s "Schema Standards" section as
      standalone conventions (no longer phrased as mirroring the constitution).
- [ ] T015 In `.specify/memory/constitution.md`, delete principle X (Performance
      Responsibility) outright — no replacement location (depends on T014 for a single combined
      edit pass over the principles list).
- [ ] T016 In `.specify/memory/constitution.md`, renumber the remaining principles
      contiguously: VII→V (Domain Invariants), VIII→VI (Security), IX→VII (External Integration
      Governance), XI→VIII (Testing Requirements), XII→IX (Human Review Requirement), XIII→X
      (Controlled Delivery); principles I–IV keep their numbers (depends on T014, T015).
- [ ] T017 [P] In `.specify/templates/plan-template.md`, renumber the Constitution Check gate
      list to match T016 (depends on T016).
- [ ] T018 [P] Sweep `CLAUDE.md`, `docs/sdlc/*.md`, and `docs/rulebooks/*.md` for any reference
      to a renumbered or deleted principle (by number or by name — e.g. "constitution XI",
      "principle X") and update each to the new number (depends on T016).
- [ ] T019 In `.specify/memory/constitution.md`, bump the version from 0.2.0 to 0.3.0 and
      record one amendment entry in the SYNC IMPACT REPORT covering the full feature's changes
      across all three phases (depends on T001–T018 — this is the single version bump for the
      whole feature, done last).
- [ ] T020 Run `quickstart.md`'s Phase 3 checks and a full `doc-lint.ps1` pass (SC-005, SC-006,
      SC-007 all verified); this is the feature's final gate before requesting human review at
      merge (depends on T014–T019).

**Checkpoint**: Phase 3 complete when T020 passes clean — the full feature is ready for the
one, feature-level human review (per the very fix Phase 1 made).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1**: No dependencies — can start immediately.
- **Phase 2**: Independent of Phase 1's content (different files/concerns), but per this
  feature's own controlled-delivery rule, phases are implemented and gated one at a time in
  order — do not start Phase 2 until Phase 1's checkpoint (T009) passes and the user approves.
- **Phase 3**: Depends on Phase 1 (T004, T005 touch the SYNC header Phase 3 also edits) being
  merged first, to avoid two phases racing on the same file's history. Do not start until
  Phase 2's checkpoint (T013) passes and the user approves.

### Within Each Phase

- Tasks marked `[P]` touch different files and can be done in any order or in parallel.
- Verification tasks (T009, T013, T020) always run last in their phase, after every other task
  in that phase.

## Parallel Example: Phase 1

```text
Task: "T001 [US1] Reword gate 6 in docs/sdlc/definition-of-done.md"
Task: "T004 [US2] Add tasks-template.md to constitution.md SYNC mirror list"
Task: "T006 [US3] Add Delivery Level field to spec-template.md"
Task: "T007 [US5] Replace CLAUDE.md Source of Truth section with a pointer"
# All four touch different files and have no dependency on each other.
```

## Implementation Strategy

### Incremental Delivery

1. Phase 1 → verify (T009) → request user gate + `git diff --stat` review → commit.
2. Phase 2 → verify (T013) → request user gate + `git diff --stat` review → commit.
3. Phase 3 → verify (T020) → request user gate + `git diff --stat` review → commit.
4. Push the feature branch, then request the single feature-level human review and merge
   (per this feature's own Phase 1 fix — gate 6 applies once, here).

### MVP Scope

Phase 1 alone already resolves the BLOCKER-severity contradiction (`review/out/DECISION.md`'s
"three things that matter" #1) — if this feature had to stop after one phase, Phase 1 is the
minimum viable increment. Phases 2 and 3 are MAJOR/MINOR severity and additive.

## Notes

- No `[P]` task ever shares a file with another `[P]` task in the same phase — verified during
  task generation above.
- Every task names an exact file; there are no "TODO: figure out which file" gaps.
- Commit after each phase (not each task) — the tasks within a phase are one coherent, gated
  unit per this feature's own phase-size rule (Phase 2, T010).
