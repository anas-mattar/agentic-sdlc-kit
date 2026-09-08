# Tasks: CI-Held Certifying Gate

**Input**: Design documents from `/specs/008-ci-held-gate/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: The enforcement check is business-critical logic (constitution VIII); its
deterministic validation is the seeded G1–G6 plan scenarios. The law's validation is the
read-verified L-checklist with quotes recorded. No test framework (kit convention).

**Organization**: One delivery phase per plan-table row. **Gate Batching: phases 1-3**
(declared in plan.md); **Gate Certification: user-run** — this feature is delivered under
the current law (research D7). Phase commits carry `phase N` subjects; Territory per phase
(006 law — one contiguous backtick-wrapped list under the marker).

## Phase 1: The law (US1, P1) 🎯 MVP

**Goal**: constitution X's CI-held clause (0.4.1 → 0.5.0, MINOR) and every sync-listed
mirror, in one atomic commit.

**Independent Test**: quickstart L1–L8 — every boundary present in every mirror, quotes
recorded; ritual checks green.

**Territory**:

- `.specify/memory/constitution.md`
- `.specify/templates/plan-template.md`
- `docs/sdlc/definition-of-done.md`
- `docs/sdlc/gate-command.md`
- `docs/sdlc/critical-delivery.md`
- `CLAUDE.md`

- [ ] T001 [US1] Amend `.specify/memory/constitution.md`: CI-held certification clause appended to X (boundaries per research D2: Lite/Standard + declaration + owner approval on the evidence triplet + agent obligations unchanged + Critical excluded + absent = user-run); SYNC IMPACT entry (0.4.1 → 0.5.0 MINOR, rationale, mirror list naming the phase-2 enforcement half as landing next phase same branch); version footer bumped
- [ ] T002 [P] [US1] Amend `.specify/templates/plan-template.md`: `**Gate Certification**: user-run` header field (comment documenting values/exclusion) + Constitution Check X row mentions the certification mode
- [ ] T003 [P] [US1] Amend `docs/sdlc/definition-of-done.md` gate 3: the ci-held option with identical boundaries; batching composition stated (one batch-end evidence approval)
- [ ] T004 [P] [US1] Amend `docs/sdlc/gate-command.md`: new "CI-held certification (Lite/Standard)" section — evidence triplet, worked approval-record example, kit's-own-evidence note (`ritual-checks`), red-then-green re-run visibility rule, user-run always lawful
- [ ] T005 [P] [US1] Amend `docs/sdlc/critical-delivery.md`: explicit CI-held exclusion mirror (beside the no-agent-gates and no-batching items)
- [ ] T006 [P] [US1] Amend `CLAUDE.md` strict rule: "Do not claim success until the user runs the gate and confirms the exit code" gains the ci-held arm (report the triplet, request the owner's approval on it — never claim success)
- [ ] T007 [US1] Execute quickstart L1–L8 (read-verification with quotes + green runs); record under Phase 1 validation; commit as `phase 1: constitution X CI-held clause (0.5.0) + mirrors`

**Checkpoint**: the law exists, complete and self-consistent; nothing enforces or uses it yet.

---

## Phase 2: The machine check (US3, P3) — ordered before US2 per plan

**Goal**: enforcement-pack `GateCertification` check per the contract.

**Independent Test**: contract G1–G6 seeded plans; regression on 001–007 (absent lines pass).

**Territory**:

- `scripts/enforcement-pack.ps1`

- [ ] T008 [US3] Add `Invoke-GateCertificationCheck` to `scripts/enforcement-pack.ps1` (GateBatching parser idiom: comment-strip, absent = user-run; malformed FAIL naming legal values; ci-held + Critical FAIL citing X's exclusion); wire into the `NNN-*` dispatch; header .DESCRIPTION updated
- [ ] T009 [US3] Execute contract G1–G6 on seeded fixture plans + 001–007 regression; record under Phase 2 validation
- [ ] T010 [US3] Feedback-run ritual-checks, report, commit as `phase 2: GateCertification enforcement`

**Checkpoint**: a Critical feature can no longer quietly adopt ci-held.

---

## Phase 3: The delivery vehicle (US2, P2)

**Goal**: the project-gate workflow template for adopted projects + wiring law.

**Independent Test**: quickstart W-G1–W-G3 — fixture instantiation valid; inert in the kit;
manifest resolves the template surgical.

**Territory**:

- `.github/workflows/project-gate.yml.template`
- `kit-manifest.json`
- `docs/sdlc/gate-command.md`
- `docs/sdlc/branch-protection.md`

- [ ] T011 [US2] Create `.github/workflows/project-gate.yml.template`: governed-branch push triggers, `{{GATE_CHAIN}}`/`{{GATE_WORKDIR}}` slots, minimal permissions, injection-safe (env indirection — 006 lesson), header comment (copy → fill → secrets live in the CI store, never in the file/evidence)
- [ ] T012 [US2] Add the specific surgical row for the template to `kit-manifest.json` (out-ranks `.github/**` verbatim; verify with doc-lint's resolution)
- [ ] T013 [P] [US2] Amend `docs/sdlc/gate-command.md`: wiring instructions (copy, fill, push, where the triplet reads off the run page); amend `docs/sdlc/branch-protection.md`: recommend requiring the project-gate check where wired (never mandated)
- [ ] T014 [US2] Execute quickstart W-G1–W-G3; record under Phase 3 validation; feedback-run ritual-checks, report, commit as `phase 3: project-gate workflow template` — **batch end: ask the owner to run the certifying gate (user-run — research D7)**

**Checkpoint**: adopters have a paved road from "my gate is a build chain" to "evidence exists".

---

## Phase 4: Governance sweep (cross-cutting)

**Goal**: summaries and flow-down told; bookkeeping closed.

**Independent Test**: ritual-checks green; flow.md 3b row carries the option; updating.md
tells adopters how the amendment flows down; roadmap flipped.

**Territory**:

- `docs/sdlc/flow.md`
- `adoption/updating.md`
- `docs/roadmap.md`
- `kit-manifest.json`

- [ ] T015 [P] Amend `docs/sdlc/flow.md` row 3b (gate): the ci-held option named, owning docs cited (summary only)
- [ ] T016 [P] Amend `adoption/updating.md`: flow-down note — the X amendment arrives via re-expression (§2), what an adopting project's own MINOR bump adopts, and that nothing changes until they ratify it
- [ ] T017 Flip `docs/roadmap.md` GAP-012 row to `in progress`; final manifest sweep (expect: only phase 3's row); run ritual-checks, report, commit as `phase 4: governance sweep` — **owner runs the certifying gate**

---

## Dependencies & Execution Order

- Phases strictly sequential (constitution X); phase 1 is atomic by design (the sync rule);
  phase 2 polices the law before phase 3 encourages reliance on it; phase 4 depends on all.
- [P] tasks touch different files within a phase, before its single closing commit.
- AI review per phase: fresh-context reviewer with provenance block, findings dispositioned
  in-phase (006 law). Human review once at merge — which, with the owner's phase-1
  approval, constitutes the amendment's required human adoption (research D2).

## Implementation Strategy

MVP = phase 1 (the law stands alone; user-run remains default everywhere). Batched
certification after phase 3, then phase 4 alone — both under the CURRENT user-run law.

## Phase validation records

*(Filled during implementation — T007, T009, T014 outputs land here.)*
