---

description: "Task list for 005-field-lesson-harvest"
---

# Tasks: Field-Lesson Harvest

**Input**: Design documents from `/specs/005-field-lesson-harvest/`
**Prerequisites**: plan.md, spec.md, research.md, quickstart.md

**Tests**: This feature is documentation-only (no code, no business logic per plan.md
Technical Context) — constitution Principle VIII's test requirement does not apply.
Verification is the quickstart.md re-walk scenarios, run per phase and at the end.

**Organization**: Tasks are grouped by user story, matching plan.md's phase breakdown
(Phase 1 = US1, Phase 2 = US2, Phase 3 = US3). No Foundational phase: the three stories touch
disjoint files/steps and share no infrastructure to build first.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)

## Phase 1: Setup

**Purpose**: Confirm the baseline before any guidance edits.

- [x] T001 Run `pwsh -File scripts/doc-lint.ps1` on the unmodified branch and confirm exit 0
  (baseline gate proof per constitution X / `adoption/greenfield.md` step 3 discipline)

---

## Phase 2: User Story 1 - Scaffolding tool traps caught before they bite (Priority: P1) 🎯 MVP

**Goal**: Both scaffolding traps (`.env*`-gitignore swallow, skipped `git init`) are encoded
as checkable steps at the point they actually occur (greenfield step 3), with a pointer in the
existing-system track.

**Independent Test**: Run quickstart.md Scenarios 1 and 2 — read `adoption/greenfield.md`
step 3 and `adoption/existing-system.md` step 7 and confirm each trap's checkable bullet
exists and would have caught the original incident.

### Implementation for User Story 1

- [x] T002 [US1] In `adoption/greenfield.md` step 3 ("Define and PROVE the gate"), add a
  bullet documenting the `.env*`-gitignore trap: name the pattern (blanket `.env*` ignore
  rules swallowing `.env.example`), and give the concrete check (`git status --ignored` after
  scaffolding; add a `!.env.example` negation line if it shows as ignored)
- [x] T003 [US1] In the same step 3 location in `adoption/greenfield.md`, add a bullet
  documenting the skipped-`git init` trap: name the pattern (a scaffolding CLI skips or
  re-initializes git when run inside an already-initialized tree), and give the concrete check
  (`git status` and `git rev-parse --show-toplevel` immediately after scaffolding, confirming
  new files are untracked additions in the parent repo, not a stray nested `.git`)
- [x] T004 [P] [US1] In `adoption/existing-system.md` step 7 ("Grandfather deliberately"), add
  a short paragraph pointing to `adoption/greenfield.md` step 3's scaffolding-trap checklist,
  for use whenever this track adds a new scaffolded component/repo to an existing system

**Checkpoint**: Quickstart Scenarios 1–2 pass by inspection; `pwsh -File scripts/doc-lint.ps1`
exits 0; run the certifying gate here if this phase ships alone (Gate Batching declares
phases 1-3 share one batch-end gate — see plan.md).

---

## Phase 3: User Story 2 - Database connection traps caught before the first migration (Priority: P1)

**Goal**: The reused-connection-string (`Spc`) incident is encoded as a checkable rule in the
database rulebook template, cross-referenced from both adoption tracks' first-write-slice
steps.

**Independent Test**: Run quickstart.md Scenario 3 — read
`docs/rulebooks/database-rules-template.md` and the two cross-references and confirm the
check would have caught the original incident before the first migration.

### Implementation for User Story 2

- [x] T005 [US2] In `docs/rulebooks/database-rules-template.md`, add a bullet (new "Setup"
  section, or the most fitting existing section — read the file's structure first) requiring
  confirmation that a migration's target database is dedicated to the project (not a reused
  local-dev instance or a shared/production database) before the first migration runs, with a
  one-line Why citing the class of incident (silent reuse of an existing database)
- [x] T006 [P] [US2] In `adoption/greenfield.md` step 5 ("read-only slices before write
  slices"), add a one-line cross-reference to the new database-rules-template.md bullet at the
  point the first write slice is planned
- [x] T007 [P] [US2] In `adoption/existing-system.md` step 4 ("Golden-fixture tests BEFORE the
  agent touches critical logic"), add a one-line cross-reference to the same bullet

**Checkpoint**: Quickstart Scenario 3 passes by inspection; `pwsh -File scripts/doc-lint.ps1`
exits 0.

---

## Phase 4: User Story 3 - Strict-build and doc-lint traps caught before they block a gate (Priority: P2)

**Goal**: The `--warnaserror`-vs-transitive-vulnerability trap and the raw-imported-docs trap
are each encoded at their real trigger points (gate-proving step; rulebook-authoring step).

**Independent Test**: Run quickstart.md Scenarios 4 and 5 independently of each other and of
US1/US2 — each targets a disjoint file/step.

### Implementation for User Story 3

- [ ] T008 [US3] In `docs/sdlc/gate-command.md`, add a new section after "Minimum Gate"
  documenting the strict-build-vs-transitive-vulnerability triage pattern: upgrade the
  dependency, pin a patched transitive version, or record a narrowly-scoped, reasoned
  suppression — never a blanket disable of the strict flag; name `--warnaserror` as one
  example among stack-agnostic equivalents
- [ ] T009 [P] [US3] In `adoption/greenfield.md` step 3, add a one-line cross-reference to the
  new `docs/sdlc/gate-command.md` section, alongside the T002/T003 bullets
- [ ] T010 [P] [US3] In `adoption/greenfield.md` step 2 ("Fill CLAUDE.md" — the tier-rulebook
  instantiation step), add a short paragraph on normalizing externally authored rulebook
  content before it is added: repo-code paths written in **bold**, not backticks; any
  `{{SLOT}}`-looking placeholder filled or removed; point at `scripts/doc-lint.ps1`'s header
  comment for the authoring convention
- [ ] T011 [P] [US3] In `adoption/existing-system.md` step 7 ("Grandfather deliberately"), add
  the equivalent short paragraph on normalizing externally authored rulebook content

**Checkpoint**: Quickstart Scenarios 4–5 pass by inspection; `pwsh -File scripts/doc-lint.ps1`
exits 0.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Close out the feature once all three stories are merged-ready.

- [ ] T012 Run all five quickstart.md scenarios end-to-end in one pass and record the result
- [ ] T013 Run `pwsh -File scripts/doc-lint.ps1` one final time and confirm exit 0
- [ ] T014 At merge: update `docs/roadmap.md` — GAP-003 row and the field-lesson-harvest
  roadmap row → `shipped`, with this feature's spec path, per FR-007

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — run first.
- **User Story 1 (Phase 2)**: Depends on Setup only. No dependency on US2/US3.
- **User Story 2 (Phase 3)**: Depends on Setup only. No dependency on US1/US3.
- **User Story 3 (Phase 4)**: Depends on Setup only. No dependency on US1/US2.
- **Polish (Phase 5)**: Depends on all three user stories being complete.

All three user stories touch disjoint files (US1: `greenfield.md` step 3 +
`existing-system.md` step 7 pointer; US2: `database-rules-template.md` +
two one-line cross-refs; US3: `gate-command.md` + `greenfield.md` steps 2/3 +
`existing-system.md` step 7) — they can be implemented in any order, or in parallel by
different people, and each is independently revertible per plan.md's Constitution Check.

### Within Each User Story

- T004, T006, T007, T009, T010, T011 are marked [P] — each touches a file/section no other
  task in-flight touches.
- T002/T003 are NOT marked [P] — both edit `adoption/greenfield.md` step 3 and should be done
  as one coherent edit to avoid merge noise in the same section.
- T010 and T002/T003 both touch `adoption/greenfield.md` but different steps (2 vs 3) — safe
  to parallelize across stories, but note both land in the same file, so apply sequentially if
  one person is doing all the edits (still independent, just not literally simultaneous saves).

### Parallel Opportunities

- After T001 (Setup), all of US1, US2, US3 can start in parallel (different people or a single
  agent working story-by-story).
- Within US2: T006 and T007 in parallel once T005 lands (both just add a cross-reference line).
- Within US3: T009, T010, T011 in parallel once T008 lands.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: User Story 1 (both scaffolding traps).
3. **STOP and VALIDATE**: run quickstart Scenarios 1–2.
4. This alone closes the two highest-frequency traps (both hit on literally the first scaffold
   of every adoption so far).

### Incremental Delivery

1. Setup → Phase 2 (US1) → validate → commit.
2. Phase 3 (US2) → validate → commit.
3. Phase 4 (US3) → validate → commit.
4. Phase 5 (Polish) → roadmap update → one certifying gate for the batch (plan.md Gate
   Batching: phases 1-3) → human review → merge.

## Notes

- No `data-model.md`, no `contracts/`: this feature has no entities and no interfaces.
- No test tasks: plan.md's Technical Context records this as documentation-only, and
  quickstart.md's five scenarios are the verification substitute.
- Read each target file's current structure before editing (T002–T011 all specify the
  section/step to land in per research.md's evidence-based placement) — do not renumber or
  restructure existing steps to insert a bullet; add within the named step.
