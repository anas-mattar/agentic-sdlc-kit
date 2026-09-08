# Feature Specification: Micro Delivery Lane

**Feature Branch**: `009-micro-lane`
**Created**: 2026-09-09
**Status**: Draft
**Delivery Level**: Standard
**Input**: User description: "Micro delivery lane: a fourth delivery level between Lite
and Standard for small-but-real numbered features — single-page mini-spec, exactly one
phase, declared eligibility bounds enforced by the machine checks; outgrowing the lane
forces re-claim as Standard (roadmap GAP-013)"

## Problem

There is no lane between Lite and Standard (roadmap GAP-013, from the 2026-09-07
self-assessment). A small-but-real feature — a few files, real behavior change, but no
schema, no new dependency, no domain-invariant surface — faces a bad pair of choices:

- **Pay the full Standard ritual**: spec.md + plan.md + tasks.md + supporting documents
  for work whose entire intent fits on one page. The ceremony dwarfs the change, so the
  ritual gets resented — and resented rituals get skipped.
- **Squeeze into `fix/`**: illegitimate by the lane's own law (`docs/sdlc/branch-strategy.md`:
  a "fix" that grows into behavior change must stop and promote), traceable to nothing
  (no spec at all), and invisible to the machine checks that key off `NNN-` branches.

The pressure is real and the field evidence exists: the Lite lane's boundary is behavior
change, and behavior changes come in all sizes. What must NOT be diluted: **verification**.
The savings of a smaller lane must come out of *specification ceremony* (plan.md,
tasks.md, research/design documents), never out of the checks — the gate, the machine
scope check, fresh-context AI review, and human review at merge all stay.

A second input (008 phase-4 review, F5): Lite is constitutionally eligible for CI-held
certification but has no `plan.md` to declare it in. The Micro lane's mini-spec is a
natural home for that declaration — small work gets the asynchronous gate option that
Lite structurally cannot express.

This feature amends constitutional text (principles I and X define the workflow and the
delivery levels), so it carries a MINOR amendment (kit template 0.5.0 → 0.6.0) under the
documented amendment procedure; adopted projects re-express it per `adoption/updating.md`.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Deliver a small feature through the Micro lane (Priority: P1)

As a feature owner, when a change is real but small — a few files, one coherent slice, no
schema/dependency/domain risk — I want to claim it as a numbered `NNN-` feature with a
**single-page mini-spec** and deliver it in **exactly one phase**, so the ritual cost is
proportional to the change while traceability (a spec exists, a number exists) and every
verification layer survive intact.

**Why this priority**: This is the lane itself — the level definition, the mini-spec, and
the one-phase law. Everything else polices or delivers it.

**Independent Test**: A feature claimed with `**Delivery Level**: Micro` and a mini-spec
(no plan.md, no tasks.md) can lawfully proceed to exactly one phase commit and merge with
gate + scope check + AI review + human review all applied; the law documents (constitution,
DoD, branch-strategy, flow) agree this is compliant.

**Acceptance Scenarios**:

1. **Given** a claimed `NNN-` branch whose `specs/NNN-name/spec.md` is a mini-spec
   declaring `**Delivery Level**: Micro` with a filled Territory block and eligibility
   checklist, **When** the owner approves the mini-spec, **Then** implementation may start
   with no plan.md or tasks.md required — the mini-spec IS the approved specification.
2. **Given** an approved Micro feature, **When** its single phase is committed (`phase 1`
   in the subject), gated, scope-checked, AI-reviewed, and human-reviewed, **Then** it
   merges exactly like a Standard feature's final state — no verification layer was
   skipped.
3. **Given** a Micro mini-spec declaring `**Gate Certification**: ci-held`, **When** the
   phase commit's project-gate CI run is green, **Then** the owner may certify on the
   evidence triplet (constitution X, CI-held certification) — the declaration lives in the
   mini-spec because Micro has no plan.md.
4. **Given** a Lite-sized change with no behavior impact (docs, chore, true fix), **When**
   the owner chooses a lane, **Then** Lite remains the right lane — Micro is for behavior
   change; the lane menu is Lite < Micro < Standard < Critical, chosen per feature.

---

### User Story 2 - The lane is machine-policed (Priority: P2)

As the kit maintainer, I want the Micro lane's eligibility and shape enforced by the
existing machine checks — enforcement pack and scope check — so a feature cannot quietly
enjoy Micro's reduced ceremony while exceeding Micro's bounds.

**Why this priority**: The lane's credibility. An honor-system lane below Standard would
become the loophole every future feature squeezes through.

**Independent Test**: Seeded fixtures exercise every rule: a compliant Micro branch passes;
oversized territory fails; a second phase commit fails; a Micro branch carrying plan.md or
tasks.md fails naming promotion; a Critical declaration in a mini-spec fails; scope-check
reads Territory from the mini-spec and attributes the single phase commit against it.

**Acceptance Scenarios**:

1. **Given** a Micro branch whose mini-spec declares Territory, **When** the phase commit
   lands, **Then** `scope-check.ps1` reads the Territory from `spec.md` (not tasks.md) and
   verdicts PASS/FAIL exactly as it does for Standard phases.
2. **Given** a Micro feature whose declared Territory exceeds the eligibility cap, or whose
   branch carries a second `phase N` commit, **Then** the enforcement pack fails the branch
   citing the Micro bounds and naming promotion to Standard as the remediation.
3. **Given** a Micro branch that also contains `plan.md` or `tasks.md`, **Then** the
   enforcement pack fails it as inconsistent — either it is Micro (mini-spec only) or it
   promoted to Standard (full set, level re-declared); the halfway state is illegal.
4. **Given** a mini-spec declaring `**Delivery Level**: Critical` or a `**Gate Batching**`
   line, **Then** the enforcement pack fails it — Critical never uses reduced ceremony,
   and a one-phase lane has nothing to batch.
5. **Given** every pre-009 feature and fixture (001–008, Lite branches), **When** the
   amended checks run, **Then** all verdicts are unchanged — absent Micro markers, nothing
   new applies (backward compatible, the Gate Batching precedent).

---

### User Story 3 - Outgrowing the lane forces promotion to Standard (Priority: P3)

As the kit maintainer, I want a defined, enforced exit when a Micro feature turns out to
be bigger than declared — more files, a second phase, a schema/dependency surprise — so
the lane bounds are a ratchet, not a suggestion.

**Why this priority**: Scope discovery is normal; what matters is that discovery upgrades
the ceremony instead of stretching the lane.

**Independent Test**: On a seeded Micro branch, an over-bounds change or second-phase
attempt produces a machine FAIL whose remediation text names the promotion procedure;
following the procedure (full spec + plan.md + tasks.md, level re-declared Standard,
promotion committed before the next phase commit) turns the branch green again with
history intact.

**Acceptance Scenarios**:

1. **Given** a Micro feature that needs more than its declared Territory or more than one
   phase, **When** the owner approves promotion, **Then** the feature promotes **in place**
   — same number, same branch: spec.md expands to the full template (level: Standard),
   plan.md and tasks.md are added, and the promotion lands in its own commit before any
   further phase commit.
2. **Given** a promoted branch, **When** the machine checks run, **Then** Standard rules
   apply from the promotion commit onward: Territory moves to tasks.md, further phases are
   lawful, and prior Micro-era commits remain attributed (history is not rewritten).
3. **Given** an over-bounds Micro branch that has NOT promoted, **Then** the branch stays
   red — remediation is promote or shrink; merging red is already impossible under
   branch protection.

---

### Edge Cases

- **Micro vs Lite boundary**: behavior change ⇒ at least Micro; no behavior change (docs,
  tooling, true regression fix) ⇒ Lite remains correct. The mini-spec's one page is the
  traceability Lite never had — that is the point of the lane.
- **Micro vs Standard boundary**: the eligibility checklist (no schema/migration, no new
  packages, no architecture change, no domain-invariant surface, no UI with visual
  references, fits the Territory cap and one phase). Any "no" ⇒ Standard. Visual-reference
  UI work is excluded because the Visual Compliance Loop assumes spec Visual Inventory —
  full template territory.
- **Ci-held on Micro**: the mini-spec carries `**Gate Certification**` (resolves 008 F5's
  structural gap for small work); `user-run` remains the default absent the line. The
  GateCertification machine check must read the mini-spec on Micro branches (it reads
  plan.md today).
- **Gate Batching on Micro**: illegal and meaningless — exactly one phase exists. The
  machine check fails a mini-spec carrying the field.
- **Claim races and numbering**: unchanged — Micro features are ordinary `NNN-` claims
  (`scripts/claim-feature.ps1`); only the spec directory's contents differ.
- **AI review provenance**: unchanged — the review file is still required with the
  Reviewer Provenance block (enforcement pack already checks files added on the branch).
- **Territory declared where the check can trust it**: scope-check reads the declaration
  from the phase commit's parent (same anti-widening rule as tasks.md Territory) — a Micro
  spec.md edit widening Territory in the phase commit itself never passes.
- **Adopted projects**: the amendment flows down by re-expression (updating.md §2 — their
  own MINOR bump); the mini-spec template and amended scripts flow as verbatim files.
  Nothing changes for them until ratified.
- **Micro is a menu entry, not a mandate**: an owner who prefers full ceremony for a small
  change just uses Standard; the lane is opt-in per feature at claim time.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Constitution I and X MUST gain the Micro arm (MINOR amendment, documented
  SYNC IMPACT): a numbered feature MAY be declared Micro in its spec; a Micro feature's
  approved single-page mini-spec satisfies specification-first with no plan.md/tasks.md;
  Micro features are delivered in exactly one phase; every verification layer (gate,
  scope check, AI review, human review) applies unchanged; Critical work MUST NOT use
  Micro; the default for a numbered feature absent the declaration remains Standard.
- **FR-002**: The eligibility bounds MUST be defined in law and stated in the mini-spec as
  a checklist the owner affirms at approval: one phase; declared Territory of at most
  **5 files** (excluding `specs/NNN-name/**`); no schema/migration; no new packages; no
  architecture change; no domain-invariant surface; no UI work with visual references;
  the phase-size guideline (400 lines) applies as a hard bound rather than advice.
- **FR-003**: The kit MUST ship a single-page mini-spec template
  (`.specify/templates/micro-spec-template.md`, classified in the manifest): header
  (branch, date, level Micro, optional Gate Certification), intent (what/why, a few
  sentences), acceptance checks, eligibility checklist, Territory block (scope-check
  format), rollback note.
- **FR-004**: `scripts/scope-check.ps1` MUST read a Micro branch's Territory from the
  mini-spec (`spec.md`), from the phase commit's parent (anti-widening preserved), and
  verdict the single phase commit exactly as it verdicts Standard phases.
- **FR-005**: `scripts/enforcement-pack.ps1` MUST police the lane: Micro + more than one
  `phase N` commit fails; Micro + plan.md/tasks.md present fails (promotion is all-or-
  nothing); declared Territory over the cap fails; mini-spec carrying Gate Batching fails;
  Critical + Micro impossible by construction but a malformed level value fails naming the
  legal values; absent Micro markers, all existing verdicts are unchanged.
- **FR-006**: The GateCertification check MUST read the declaration from the mini-spec on
  Micro branches (plan.md remains the source for Standard/Critical); ci-held on Micro is
  lawful (Lite/Standard/Micro share the clause; Critical stays excluded).
- **FR-007**: The promotion procedure MUST be documented and enforced: outgrowing = expand
  spec.md to the full template (level Standard), add plan.md + tasks.md (Territory moves
  there), in a promotion commit that precedes any further phase commit; machine remediation
  messages MUST name this procedure.
- **FR-008**: Every summary and instrument that enumerates delivery levels or lanes MUST
  carry Micro in the same change: branch-strategy (level menu), flow.md (lane variations),
  DoD (gate 1's specification arm), critical-delivery (untouched exclusions restated),
  CLAUDE.md (structure + strict rules + reading table), review-process, PR/human-review
  templates where they assume plan.md/tasks.md exist, plan-template/spec-template comments
  naming the levels.
- **FR-009**: Every new rule MUST have seeded validation (fixture branches/specs) for the
  US2/US3 scenarios, recorded in the feature's validation record; regression on 001–008
  verdicts required.

### Key Entities

- **Delivery level `Micro`**: declared in the mini-spec header; menu position
  Lite < Micro < Standard < Critical; default for numbered features remains Standard.
- **Mini-spec**: single-page `specs/NNN-name/spec.md` from the micro template — the only
  specification artifact a Micro feature carries.
- **Eligibility bounds**: one phase · ≤ 5 territory files · ≤ 400 lines · no
  schema/packages/architecture/domain/visual-reference surface — checklist-affirmed at
  approval, machine-checked where measurable.
- **Promotion**: in-place upgrade Micro → Standard (full spec + plan + tasks, own commit,
  before further phases).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A real small feature is delivered through the lane end-to-end (claim →
  mini-spec → one phase → merge) with specification ceremony of exactly one page, and
  with 100% of the verification layers of a Standard phase applied (gate, scope check,
  fresh-context AI review, human review).
- **SC-002**: 100% of seeded over-bounds attempts (second phase, oversized territory,
  plan/tasks on a Micro branch, batching declaration, malformed level) fail the machine
  checks with remediation text naming promotion; zero verdict changes on 001–008 and Lite
  fixtures.
- **SC-003**: A Micro feature can lawfully declare `ci-held` in its mini-spec and be
  certified on the evidence triplet — closing 008 F5's structural gap for small work.
- **SC-004**: The constitutional amendment lands with a complete SYNC IMPACT entry, every
  sync-listed mirror updated in the same change, ritual checks green throughout, and the
  flow-down path documented for adopted projects.

## Assumptions

- The amendment is MINOR (principles I and X materially expanded, none removed/redefined):
  kit template 0.5.0 → 0.6.0.
- **Territory cap 5 files and the 400-line hard bound are proposed values** — the owner
  ratifies or adjusts them at spec approval; they become constitutional constants encoded
  in the enforcement pack (the batch-cap precedent).
- The mini-spec stays named `spec.md` so the Feature Structure law ("exactly these names")
  survives unchanged — Micro is a smaller spec.md, not a new filename.
- Lite remains for non-behavior change and keeps no spec directory; Micro does not replace
  or absorb it.
- The 007 adoption doctor needs no change (it audits kit integrity, not delivery levels);
  ritual-checks composition is unchanged — the amended enforcement-pack/scope-check ride
  the existing chain.
- specs/_templates (AI review, human review, rollback) remain shared across levels; only
  documents that assume plan.md/tasks.md existence need a Micro arm (FR-008).
