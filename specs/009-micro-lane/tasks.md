# Tasks: Micro Delivery Lane

**Input**: Design documents from `/specs/009-micro-lane/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: The machine checks are business-critical logic (constitution VIII); their
deterministic validation is the seeded M1–M13 contract scenarios. The law's validation is
the read-verified L-checklist with quotes recorded. No test framework (kit convention).

**Organization**: One delivery phase per plan-table row. **Gate Batching: phases 1-3** and
**Gate Certification: ci-held** (both declared in plan.md — the ci-held declaration is
research D7's dogfooding, the clause's first real use). Phase commits carry `phase N`
subjects; Territory per phase (006 law).

## Phase 1: The law (US1, P1) 🎯 MVP

**Goal**: constitution I + X Micro arms (0.5.0 → 0.6.0, MINOR), every sync-listed mirror,
and the mini-spec template, in one atomic commit.

**Independent Test**: quickstart L1–L8 — every boundary present in every mirror, quotes
recorded; ritual checks green.

**Territory**:

- `.specify/memory/constitution.md`
- `.specify/templates/micro-spec-template.md`
- `.specify/templates/spec-template.md`
- `docs/sdlc/definition-of-done.md`
- `docs/sdlc/branch-strategy.md`
- `docs/sdlc/critical-delivery.md`
- `docs/sdlc/gate-command.md`
- `CLAUDE.md`

- [ ] T001 [US1] Amend `.specify/memory/constitution.md`: I gains the Micro arm (approved
      mini-spec satisfies specification-first, no plan/tasks); X gains the Micro clause
      (one phase, verification unchanged, bounds with both constants, Critical excluded,
      absent = Standard, promotion procedure) and widens CI-held eligibility to "Lite,
      Micro, or Standard" (batching stays Lite/Standard); SYNC IMPACT (0.5.0 → 0.6.0
      MINOR, rationale, mirror list, machine half next-phase-same-branch, human-adoption
      note); sync list gains the Micro constants beside the batch cap; footer bumped
- [ ] T002 [P] [US1] Create `.specify/templates/micro-spec-template.md` per data-model
      (header/Intent/Acceptance/Eligibility checklist/Territory/Rollback — one page);
      amend `.specify/templates/spec-template.md` Delivery Level comment (Micro named,
      pointer to the micro template)
- [ ] T003 [P] [US1] Amend `docs/sdlc/definition-of-done.md`: gate 1 mini-spec arm; gate 4
      names spec.md as the Micro territory source; gate 3's CI-held option reads "Lite,
      Micro, or Standard"
- [ ] T004 [P] [US1] Amend `docs/sdlc/branch-strategy.md` (level menu Lite < Micro <
      Standard < Critical, Micro/Lite and Micro/Standard boundaries) and
      `docs/sdlc/critical-delivery.md` (exclusion restated: Critical never uses Micro,
      batching, or ci-held)
- [ ] T005 [P] [US1] Amend `docs/sdlc/gate-command.md` (CI-held section eligibility +
      mini-spec as the declaration home on Micro) and `CLAUDE.md` (structure note, strict
      rules, reading-table row for Micro)
- [ ] T006 [US1] Execute quickstart L1–L8; record under Phase 1 validation; commit as
      `phase 1: constitution I+X micro lane (0.6.0) + mirrors + mini-spec template`

**Checkpoint**: the lane exists in law; nothing enforces or summarizes it yet.

---

## Phase 2: The machine (US2, P2 + US3 machine half)

**Goal**: scope-check Micro territory source; enforcement-pack MicroLane check +
GateCertification source extension; contract M1–M13 validated.

**Independent Test**: contract scenarios on seeded fixtures; regression on 001–008 + Lite.

**Territory**:

- `scripts/scope-check.ps1`
- `scripts/enforcement-pack.ps1`

- [ ] T007 [US2] Amend `scripts/scope-check.ps1`: detect Micro via spec.md's comment-
      stripped Delivery Level at the commit's parent; read the feature-global Territory
      block from spec.md; verdict the phase commit with unchanged semantics (implicit
      spec-dir entry, anti-widening, remediation text naming promotion)
- [ ] T008 [US2] Amend `scripts/enforcement-pack.ps1`: `Invoke-MicroLaneCheck` per the
      contract (single-phase, no plan/tasks, territory cap, hard line bound, no batching
      line, malformed level values) with constants in $Config; GateCertification reads
      spec.md on Micro branches; header .DESCRIPTION updated
- [ ] T009 [US2] Execute contract M1–M13 on seeded fixtures (fixture spec dir + branches,
      deleted after); regression run (this branch, 003, 007, 008, one Lite name); record
      under Phase 2 validation; feedback-run ritual-checks; commit as
      `phase 2: micro-lane machine checks`

**Checkpoint**: the lane cannot be quietly stretched; nothing advertises it yet.

---

## Phase 3: The sweep (US3 doc half + cross-cutting)

**Goal**: promotion procedure and lane summaries everywhere; flow-down told; bookkeeping.

**Independent Test**: quickstart W1–W4; ritual-checks green.

**Territory**:

- `docs/sdlc/flow.md`
- `docs/sdlc/review-process.md`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `specs/_templates/human-pr-review-template.md`
- `adoption/updating.md`
- `docs/roadmap.md`

- [ ] T010 [P] Amend `docs/sdlc/flow.md` (lane-variations Micro bullet) and
      `docs/sdlc/review-process.md` (after-each-phase wording where it assumes tasks.md
      Territory; promotion named as the FAIL remediation for Micro)
- [ ] T011 [P] Amend `.github/PULL_REQUEST_TEMPLATE.md` +
      `specs/_templates/human-pr-review-template.md`: spec/plan/tasks link lines gain the
      Micro arm (mini-spec only)
- [ ] T012 [P] Amend `adoption/updating.md`: flow-down note for the 0.6.0 amendment
      (re-expression per §2, adopter's own MINOR bump, template + scripts arrive verbatim,
      nothing changes until ratified)
- [ ] T013 Flip `docs/roadmap.md` GAP-013 row to `in progress`; W4 absence sweep; run
      ritual-checks, report; commit as `phase 3: micro-lane governance sweep` — **batch
      end: report the ci-held evidence triplet (push-event ritual-checks run on this
      commit) and request the owner's recorded approval (plan declaration, research D7)**

---

## Dependencies & Execution Order

- Phases strictly sequential (constitution X); phase 1 atomic (sync rule); machine before
  summaries (D6). AI review per phase: fresh-context reviewer with provenance block,
  findings dispositioned in-phase (006 law). Human review once at merge — which, with the
  owner's spec/plan approval, constitutes the amendment's human adoption.
- [P] tasks touch different files within a phase, before its single closing commit.

## Implementation Strategy

MVP = phase 1 (the law stands alone; Standard remains the default everywhere). All three
phases batched; certification once, at batch end, on CI evidence (ci-held — the plan's
declared mode).

## Phase validation records

*(Filled during implementation — T006, T009, T013 outputs land here.)*
