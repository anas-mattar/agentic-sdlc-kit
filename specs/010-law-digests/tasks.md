# Tasks: Law Digests

**Input**: Design documents from `/specs/010-law-digests/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: the generator/check is business-critical governance logic (constitution VIII);
its deterministic validation is the seeded C1–C12 contract scenarios. The content phase's
validation is the read-verified L-checklist with quotes recorded. No test framework (kit
convention).

**Organization**: one delivery phase per plan-table row. **Gate Batching: phases 1-3** and
**Gate Certification: ci-held** (both declared in plan.md). Phase commits carry `phase N`
subjects; Territory per phase (006 law).

## Phase 1: The machine (US2, P1 + US3 machine half) 🎯 MVP

**Goal**: generator + `-Check`, pack manifest, ritual-checks wiring, manifest classes —
contract-validated before any marker exists.

**Independent Test**: contract C1–C12 on seeded fixtures; kit self-run shows `digests`
n/a; D7 update-kit class behavior recorded.

**Territory**:

- `scripts/build-digests.ps1`
- `scripts/ritual-checks.ps1`
- `docs/digests/digest-packs.json`
- `kit-manifest.json`
- `adoption/updating.md`

- [ ] T001 [US2] Create `scripts/build-digests.ps1`: manifest load; per-doc marker
      extraction (standalone line, in-comment state exclusion — D6; empty-text FAIL);
      deterministic assembly (data-model header + bullets, LF); bounds constants
      MaxDigestContentLines=40 / MaxDigestLineLength=120 (D4, FAIL); `-Check` mode
      (normalized compare; stale/hand-edit/missing/orphan/absent-doc FAILs; n/a
      inertness — D5); `-Root` portability; error-message contract
- [ ] T002 [P] [US2] Create `docs/digests/digest-packs.json` per data-model (five packs,
      D2)
- [ ] T003 [P] [US2] Wire ritual-checks member `digests` (n/a distinct from OK);
      kit-manifest.json: verbatim entries for the script + manifest, `generated` class
      for `docs/digests/*-digest.md`; adoption/updating.md gains the `generated` class
      one-liner in its class table (full flow-down note is phase 3)
- [ ] T004 [US2] Execute contract C1–C12 on seeded fixtures (scratch clone, deleted
      after); verify D7 (update-kit run against a fixture target — `generated` never
      copied; record actual handling); kit self-run n/a; record under Phase 1
      validation; commit as `phase 1: digest generator + freshness check`

**Checkpoint**: the machine exists and is armed; no digest content exists yet.

---

## Phase 2: The content (US1, P1 — kit dogfood, FR-008)

**Goal**: markers beside the binding rules of all ten pack documents; five digests
generated and committed under the live check.

**Independent Test**: quickstart L1–L4 with quotes recorded.

**Territory**:

- `docs/sdlc/definition-of-done.md`
- `docs/sdlc/gate-command.md`
- `docs/sdlc/flow.md`
- `docs/sdlc/branch-strategy.md`
- `docs/sdlc/repository-strategy.md`
- `docs/sdlc/team-workflow.md`
- `docs/sdlc/review-process.md`
- `docs/sdlc/rollback-process.md`
- `docs/sdlc/critical-delivery.md`
- `adoption/updating.md`
- `docs/digests/**`

- [ ] T005 [P] [US1] Author digest markers beside the binding rules: delivery pack (DoD
      gates 1–6 essentials, gate-command certification law, flow checkpoints)
- [ ] T006 [P] [US1] Author markers: branching pack (taxonomy, levels incl. Micro,
      claim/number rules, merge rules; team-workflow ownership/territory/pipelining;
      repository-strategy cross-repo rule)
- [ ] T007 [P] [US1] Author markers: review pack (visual loop exit rule, after-each-phase
      steps, reviewer separation, human review), critical pack (the five additions +
      exclusions), adoption pack (verbatim/surgical/generated classes, re-expression
      rule, once-only surgical report)
- [ ] T008 [US1] Run the generator; commit digests with the markers; execute quickstart
      L1–L4 (including the live drift tripwire); record under Phase 2 validation; commit
      as `phase 2: kit law digests — markers + generated digests`

**Checkpoint**: the kit's own digests exist and cannot drift; nothing points agents at
them yet.

---

## Phase 3: The sweep (US1 pointer half + US3 doc half)

**Goal**: reading-table orientation pointers; flow-down note; bookkeeping.

**Independent Test**: quickstart W1–W4.

**Territory**:

- `CLAUDE.md`
- `adoption/updating.md`
- `docs/roadmap.md`

- [ ] T009 [P] Amend CLAUDE.md Task-Scoped Reading: per-pack digest offered as the
      orientation read (`docs/digests/<pack>-digest.md`), full documents remain the
      acting read; always-load row untouched; authority note (digest never a ladder rung
      — FR-009)
- [ ] T010 [P] Amend adoption/updating.md: flow-down note for 010 (generator + manifest
      verbatim; digests generated per project, never synced; opt-in by marking own docs;
      inert until then — SC-004)
- [ ] T011 Flip roadmap GAP-014 → in progress; W4 authority sweep; ritual-checks; commit
      as `phase 3: digest pointers + flow-down note` — **batch end: report the ci-held
      evidence triplet (push-event ritual-checks run on this commit) and request the
      owner's recorded approval**

---

## Dependencies & Execution Order

Phases strictly sequential (machine → content → pointers: content must land under an
armed check — D8; pointers must not precede content). AI review per phase: fresh-context
reviewer with provenance block, findings dispositioned in-phase (006 law). Human review
once at merge (constitution IX).

## Implementation Strategy

MVP = phase 1 (an armed, inert checker is independently valuable and fully testable).
All three phases batched; certification once, at batch end, on CI evidence (ci-held —
the plan's declared mode).

## Phase validation records

*(Filled during implementation — T004, T008, T011 outputs land here.)*
