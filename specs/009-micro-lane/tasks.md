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

- [x] T001 [US1] Amend `.specify/memory/constitution.md`: I gains the Micro arm (approved
      mini-spec satisfies specification-first, no plan/tasks); X gains the Micro clause
      (one phase, verification unchanged, bounds with both constants, Critical excluded,
      absent = Standard, promotion procedure) and widens CI-held eligibility to "Lite,
      Micro, or Standard" (batching stays Lite/Standard); SYNC IMPACT (0.5.0 → 0.6.0
      MINOR, rationale, mirror list, machine half next-phase-same-branch, human-adoption
      note); sync list gains the Micro constants beside the batch cap; footer bumped
- [x] T002 [P] [US1] Create `.specify/templates/micro-spec-template.md` per data-model
      (header/Intent/Acceptance/Eligibility checklist/Territory/Rollback — one page);
      amend `.specify/templates/spec-template.md` Delivery Level comment (Micro named,
      pointer to the micro template)
- [x] T003 [P] [US1] Amend `docs/sdlc/definition-of-done.md`: gate 1 mini-spec arm; gate 4
      names spec.md as the Micro territory source; gate 3's CI-held option reads "Lite,
      Micro, or Standard"
- [x] T004 [P] [US1] Amend `docs/sdlc/branch-strategy.md` (level menu Lite < Micro <
      Standard < Critical, Micro/Lite and Micro/Standard boundaries) and
      `docs/sdlc/critical-delivery.md` (exclusion restated: Critical never uses Micro,
      batching, or ci-held)
- [x] T005 [P] [US1] Amend `docs/sdlc/gate-command.md` (CI-held section eligibility +
      mini-spec as the declaration home on Micro) and `CLAUDE.md` (structure note, strict
      rules, reading-table row for Micro)
- [x] T006 [US1] Execute quickstart L1–L8; record under Phase 1 validation; commit as
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

- [x] T007 [US2] Amend `scripts/scope-check.ps1`: detect Micro via spec.md's comment-
      stripped Delivery Level at the commit's parent; read the feature-global Territory
      block from spec.md; verdict the phase commit with unchanged semantics (implicit
      spec-dir entry, anti-widening, remediation text naming promotion)
- [x] T008 [US2] Amend `scripts/enforcement-pack.ps1`: `Invoke-MicroLaneCheck` per the
      contract (single-phase, no plan/tasks, territory cap, hard line bound, no batching
      line, malformed level values) with constants in $Config; GateCertification reads
      spec.md on Micro branches; header .DESCRIPTION updated
- [x] T009 [US2] Execute contract M1–M13 on seeded fixtures (fixture spec dir + branches,
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

- [x] T010 [P] Amend `docs/sdlc/flow.md` (lane-variations Micro bullet) and
      `docs/sdlc/review-process.md` (after-each-phase wording where it assumes tasks.md
      Territory; promotion named as the FAIL remediation for Micro)
- [x] T011 [P] Amend `.github/PULL_REQUEST_TEMPLATE.md` +
      `specs/_templates/human-pr-review-template.md`: spec/plan/tasks link lines gain the
      Micro arm (mini-spec only)
- [x] T012 [P] Amend `adoption/updating.md`: flow-down note for the 0.6.0 amendment
      (re-expression per §2, adopter's own MINOR bump, template + scripts arrive verbatim,
      nothing changes until ratified)
- [x] T013 Flip `docs/roadmap.md` GAP-013 row to `in progress`; W4 absence sweep; run
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

### Phase 1 (T006) — quickstart L1–L8, executed 2026-09-09

| # | Verdict | Evidence (quote) |
|---|---|---|
| L1 | PASS | Constitution I, Micro arm: "a feature declared **Micro** (Principle X, Micro lane) satisfies this principle with an approved **single-page mini-spec** — its `spec.md`, authored from `.specify/templates/micro-spec-template.md` — alone: steps (2) and (3) are skipped" |
| L2 | PASS | Constitution X, Micro lane: "A Micro feature has **exactly one phase**"; "Every verification layer is unchanged: user-held gate certification, the machine scope check (Territory read from `spec.md`), fresh-context AI review, and human review at merge"; "at most **5 files** (the feature's own `specs/NNN-name/**` excluded)"; "at most **400 lines** — a failure for Micro where other lanes get a warning"; "Critical features MUST NOT use the Micro lane"; "Absent a `**Delivery Level**` declaration, a numbered feature is Standard"; "**promoted in place to Standard** … in a commit made **before** any further phase commit; promotion is one-way and all-or-nothing" |
| L3 | PASS | X CI-held clause: "for a Lite, Micro, or Standard feature … (for a Micro feature: in its approved mini-spec `spec.md`, the lane's only specification document)"; gate-command.md section header "CI-held certification (Lite, Micro, or Standard only)"; Batched gates unchanged "for a Lite or Standard feature"; gate-command.md: "**Micro features never batch either** — the lane is exactly one phase, so there is nothing to batch" |
| L4 | PASS | SYNC IMPACT: "Version change: 0.5.0 → 0.6.0 (kit template …)", MINOR rationale with GAP-013; full mirror list ("micro-spec-template.md (new), spec-template.md, definition-of-done.md (gates 1, 3, 4), gate-command.md, branch-strategy.md, critical-delivery.md, CLAUDE.md"); machine half: "lands in this same feature's next phase on the same branch"; human adoption: "the owner's spec/plan approval (2026-09-09) plus the feature's gate-6 human review at merge"; footer "**Version**: 0.6.0"; sync list gains "the Micro-lane bounds (territory-file cap 5, phase-line hard bound 400, single-phase rule) and the Delivery Level legal values" |
| L5 | PASS | `.specify/templates/micro-spec-template.md` created with all data-model sections (header + optional Gate Certification / Intent / Acceptance checks / Eligibility checklist / Territory / Rollback, one page); spec-template.md field now "[Lite \| Micro \| Standard \| Critical]" with the micro-template pointer; doc-lint: "manifest - 65 shipped file(s) classified" (was 64) |
| L6 | PASS | DoD gate 1: "**Micro arm**: … the approved single-page mini-spec … alone satisfies this item"; gate 3: "**CI-held option (Lite, Micro, or Standard only)** … on a Micro feature the declaration lives in the mini-spec `spec.md`"; gate 4: "for a Micro feature, the feature-global **Territory** block in its mini-spec `spec.md`"; branch-strategy: "**Lite < Micro < Standard < Critical**" with both boundary paragraphs; critical-delivery: four-level table, Critical row "**never** Micro, gate batching, or ci-held", item 4 names the Micro exclusion |
| L7 | PASS | CLAUDE.md: "**Micro exception** (constitution X, Micro lane): … holds `spec.md` alone"; strict rule "A Micro feature is exactly one phase inside hard bounds (≤5 territory files, ≤400 lines) … never stretch the lane"; reading-table row "A feature declared Micro (small, bounded, one phase)" |
| L8 | PASS | `ritual-checks.ps1` on the fully amended tree: doc-lint OK (65 files), enforcement-pack OK (pre-existing non-blocking PhaseSizeWarning on specify commit bcf436e only), scope-check OK, **RESULT OK** |

### Phase 2 (T009) — contract M1–M13 on seeded fixtures, executed 2026-09-09

Fixtures: a scratch clone of this repo (deleted after) with branches `998-micro-demo`
(M2–M4), `997-micro-cap`, `996-micro-twophase`, `995-micro-halfpromo`, `994-micro-batch`,
`993-micro-ciheld`, `992-micro-malformed`, `991-micro-promo`, `990-micro-oversize`,
`989-micro-decoy`, `fix/demo-lite`; the kit's own (amended) scripts run against the clone
via `-Root`/`-Branch`/`-Commit`.

| # | Verdict | Evidence (quote) |
|---|---|---|
| M1 | PASS | Regression, absent Delivery Level ⇒ unchanged verdicts: this branch "scope-check: PASS phase 1 commit 66b3dff (9 file(s))" + "PASS phase 1 commit 310e4ad", enforcement-pack OK; 008 "PASS phase 4 commit 63fed28 (13 file(s))", "PASS phase 3 commit c72b54c", "PASS phase 4 commit 4429624"; 007 "PASS phase 1 commit 6410ffb"; pre-006 WARN unchanged: 003 "WARN commit 6e5988d: no territory declared for phase 3 … non-blocking, pre-006 compatibility", 005 "WARN commit 42b9cd9: … tasks.md not found …" |
| M2 | PASS | "scope-check: PASS phase 1 commit 1451bd8 (2 file(s), Micro territory from spec.md)", exit 0; "enforcement-pack: OK", exit 0 |
| M3 | PASS | "scope-check: FAIL phase 1 commit 6742577: demo/d.txt not in territory" + Micro remediation naming the 5-entry cap and promotion, exit 1 |
| M4 | PASS | Territory widened + used in the same commit: "FAIL phase 1 commit 8ba72d9: demo/e.txt not in territory" — declaration read from the parent (anti-widening), exit 1 |
| M5 | PASS | "MicroLane: … declares 6 territory entries — a Micro feature's Territory covers at most 5 files … shrink the territory, or promote to Standard …", exit 1 |
| M6 | PASS | "MicroLane: the branch carries commits for phases 1, 2 — a Micro feature has exactly 1 phase; promote to Standard …", exit 1 (distinct phase NUMBERS counted — 'phase 1 fixes' remediation commits stay legal) |
| M7 | PASS | "MicroLane: specs/995-micro-halfpromo/plan.md exists while spec.md still declares Micro — promotion is all-or-nothing …", exit 1 |
| M8 | PASS | "MicroLane: … declares '**Gate Batching**' — a Micro feature is exactly one phase; there is nothing to batch …", exit 1 |
| M9 | PASS | ci-held declared in the mini-spec: "enforcement-pack: OK", exit 0 (GateCertification reads spec.md on Micro) |
| M10 | PASS | "Structure: … **Delivery Level** header is unfilled or invalid: 'Micr0' (legal values: Lite, Micro, Standard, Critical — constitution X)", exit 1 (plus fail-closed missing-plan/tasks failures, since a malformed level is not Micro) |
| M11 | PASS | Micro-era commit against old spec territory: "PASS phase 1 commit 517df6a (1 file(s), Micro territory from spec.md)"; post-promotion "PASS phase 2 commit b7e227f"; "enforcement-pack: OK" (Standard rules from the promotion commit onward) |
| M12 | PASS | "MicroLane: phase commit b43f0e1 changes 401 line(s) — a Micro phase commit changes at most 400 lines, a hard bound on this lane …", exit 1 |
| M13 | PASS | Commented-out `**Delivery Level**: Micro` decoy above a visible `Standard`: "enforcement-pack: OK", exit 0 — not Micro (comment-stripped parsing; no MicroLane failure despite plan.md/tasks.md present) |
| Lite | PASS | `fix/demo-lite`: "enforcement-pack: OK"; "scope-check: not applicable (fix/ lane …)" |

Design note (recorded for review): on Micro, territory entries must be **literal file
paths** — a glob or trailing-slash subtree entry fails the MicroLane check, because one
`src/**` entry would defeat the 5-file cap outright (data-model: "lists more
entries/expands to more files"). The spec-dir exclusion is unchanged (implicit entry,
uncounted). scope-check also now protects spec.md from deletion on any numbered branch
(it is the Micro lane's declaration file; deleting it was never legitimate).

### Phase 3 (T013) — quickstart W1–W4, executed 2026-09-09

| # | Verdict | Evidence |
|---|---|---|
| W1 | PASS | flow.md Lane variations gains the **Micro** bullet (mini-spec, one phase, bounds, promotion — summary-only, pointing at constitution X and branch-strategy); steps 2/3b/3d gain the Micro arms; review-process "After Each Phase" items 1/3/4 now read correctly for a Micro feature (territory in spec.md; promotion named as the standing FAIL remediation) |
| W2 | PASS | PULL_REQUEST_TEMPLATE.md spec/plan/tasks link line + Gate Result checkbox carry the Micro arm; human-pr-review-template.md gains the spec/plan/tasks line (mini-spec alone, eligibility re-verified) and the ci-held Gate Result arm |
| W3 | PASS | updating.md "Flow-down note: the 2026-09-09 Micro-lane amendment (kit 0.5.0 → 0.6.0)" added (re-expression, adopter's own MINOR bump, machine half + template verbatim but inert until ratified); roadmap GAP-013 row flipped to `in progress` |
| W4 | PASS with known holds | Sweep greps ("then \`plan.md\`, then \`tasks.md\`" and non-batching "Lite/Standard"): every hit is either fixed in this batch, a historical record left as written (constitution SYNC IMPACT prior-history, updating.md's 0.5.0 note, roadmap gap description), or one of the four out-of-territory instruments held for owner approval since phase 1 review F3 (plan-template.md Constitution Check X ci-held arm, team-workflow.md, backend-rules-template.md, mobile-rules-template.md); ritual-checks RESULT OK (recorded below) |
