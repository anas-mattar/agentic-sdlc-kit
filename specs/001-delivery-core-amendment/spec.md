# Feature Specification: Delivery Core Amendment

**Feature Branch**: `001-delivery-core-amendment`
**Created**: 2026-09-01
**Status**: Draft
**Delivery Level**: Standard
**Input**: External review decision `review/out/DECISION.md` (Round 1 + Round 2, merged 2026-09-01) — BLOCKER/MAJOR findings #1, #2, #4, #6, #7, #14, #15, and the "Open decisions for the author" table.

## Context

This is the kit governing itself: the "user" of this feature is a developer or AI agent
following the kit's own law (`CLAUDE.md`, the constitution, `docs/sdlc/*`) on a feature they
are delivering. The review found that the delivery core — the rules that decide what "done"
means and when a phase may be committed, merged, and reviewed — contradicts itself on the
question everything else depends on, and that contradiction has never surfaced because the
kit has not yet run its own Standard lane (`review/out/DECISION.md` finding 19). This feature
is that first run, and it repairs the contradiction before any later feature inherits it.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Comply with the review checklist without owing an impossible number of human reviews (Priority: P1)

A developer finishes phase 2 of a 4-phase Standard feature. The Definition of Done
(`docs/sdlc/definition-of-done.md:35-36`) says all six gates — including human review — must
pass before a phase is "committed and merged." The branch strategy
(`docs/sdlc/branch-strategy.md:70-71`) says phases commit freely on the feature branch and the
feature merges to main once. As written today, the developer cannot satisfy both documents at
once and is forced to either skip the DoD's human-review gate on phases 1–3 (silently, with no
document telling them this is expected) or block on a human review after every phase (which
nobody will actually do). Both outcomes teach non-compliance.

**Why this priority**: This is the contradiction the whole review escalated to the top —
finding #1, sitting on the rule every other phase depends on.

**Independent Test**: Read `definition-of-done.md` and `branch-strategy.md` back to back for
this feature's phases; there is exactly one place that says which gates apply per phase-commit
and which apply once per feature at merge, and the two documents no longer disagree.

**Acceptance Scenarios**:

1. **Given** a Standard feature with N phases, **When** phase K (K < N) is committed, **Then**
   the Definition of Done requires gates 1–5 (build/lint/test, scope check, self-review,
   agent-run gate, user-confirmed exit code) but not gate 6 (human review).
2. **Given** the same feature, **When** the final phase is ready to merge to main, **Then**
   the Definition of Done requires gate 6 (human review) once, covering the full feature diff.
3. **Given** a developer reading only `CLAUDE.md` and `definition-of-done.md`, **When** they
   ask "how many human reviews does a 4-phase feature need," **Then** the answer is
   unambiguous and identical to the answer implied by `branch-strategy.md`.

---

### User Story 2 - Write tests without the tasks template telling the agent otherwise (Priority: P1)

An agent runs `/speckit.tasks` to generate the task list for a feature. The stock template
(`tasks-template.md:11`) tells the agent tests are OPTIONAL at the exact moment it decides
whether to write them — directly contradicting constitution principle XI. Because the SYNC
header's mirror list (`constitution.md:34-36`) never named `tasks-template.md`, this defect
survived every prior constitution amendment undetected.

**Why this priority**: Finding #2 — a BLOCKER that actively produces untested code, not a
latent risk.

**Independent Test**: Generate a fresh tasks list from the template; it does not contain the
word "OPTIONAL" applied to tests, and the SYNC header lists `tasks-template.md` as a mirror
that must be checked on every future constitutional amendment.

**Acceptance Scenarios**:

1. **Given** the amended `tasks-template.md`, **When** an agent generates tasks for a new
   feature, **Then** the generated task list requires tests consistent with constitution XI.
2. **Given** a future constitutional amendment, **When** the amender checks the SYNC header's
   mirror list, **Then** `tasks-template.md` appears on it.

---

### User Story 3 - Declare and detect a feature's delivery level (Priority: P1)

A developer starts a Critical feature (it touches a domain invariant). `critical-delivery.md`
and `branch-strategy.md` both require the level to be declared in the feature's `spec.md`
header, but `spec-template.md` has no field for it — so there is nothing to write it into, and
nothing later (a human reviewer, or future CI in the 002 enforcement pack) can check.

**Why this priority**: Finding #4 — the risk-classification system the rest of the kit's
tiered requirements hang on currently has no artifact.

**Independent Test**: Generate a fresh spec from the template; it contains a `Delivery Level`
field with an enumerated value, filled at spec-authoring time, matching the field this very
spec now declares.

**Acceptance Scenarios**:

1. **Given** the amended `spec-template.md`, **When** an agent runs `/speckit.specify`,
   **Then** the generated `spec.md` contains a `**Delivery Level**:` header with one of
   `Lite | Standard | Critical`.
2. **Given** a spec with no `Delivery Level` filled in, **When** the spec-quality checklist
   (`checklists/requirements.md`) is evaluated, **Then** it fails a specific, named check.

---

### User Story 4 - Know how big a "phase" is allowed to be (Priority: P2)

A developer under deadline pressure is tempted to fold three logical phases into one large
commit, since nothing in the kit bounds phase size. Doing so silently destroys the
revert-clean property the whole per-phase-commit design exists to protect.

**Why this priority**: Finding #6 — a MAJOR gap in the control the rest of the DoD assumes
exists.

**Independent Test**: Read `plan.md` for a feature after `/speckit.plan`; each declared phase
carries a stated boundary (independently revertible, one meaningfully-testable slice) that a
reviewer can check the plan against before approving it.

**Acceptance Scenarios**:

1. **Given** a plan with a phase that bundles unrelated concerns (e.g., a schema change and an
   unrelated UI change), **When** the plan is reviewed against the phase-size rule, **Then**
   the reviewer has a concrete, named reason to reject or split it before approval.
2. **Given** a plan where every phase is independently revertible and testable, **When** it is
   checked against the rule, **Then** it passes without modification.

---

### User Story 5 - Read one source-of-truth ladder, not three (Priority: P2)

A developer resolving a conflict between `spec.md` and `plan.md` checks the source-of-truth
ladder to see which wins. The constitution states a 9-rung ladder, `CLAUDE.md` states a
different 7-rung ladder, and `plan-template.md` states a third 5-rung ladder. The developer now
has to decide which "law" to trust about which document is law — the exact failure mode the
kit's own README says drift-prone frameworks fall into (`README.md:83-84`).

**Why this priority**: Finding #7 — the kit demonstrating its own diagnosed failure mode,
pre-adoption.

**Independent Test**: Search the repository for the ordered list of source-of-truth rungs; it
exists in exactly one place, and every other reference points at that location instead of
restating the list.

**Acceptance Scenarios**:

1. **Given** the amended documents, **When** searching for "source of truth" ladder content,
   **Then** the full ordered rung list appears in exactly one canonical file.
2. **Given** `CLAUDE.md` and `plan-template.md`, **When** read for ladder guidance, **Then**
   each contains a pointer to the canonical file, not an independent list.

---

### User Story 6 - Know what a solo Critical review actually requires (Priority: P2)

A solo developer delivers a Critical feature. `critical-delivery.md` says it needs
"second-model review plus cooling-off," citing a broad audit procedure with no defined
artifact, duration, or merge-blocking mechanism — leaving the highest-risk lane less
falsifiable than the Standard lane beneath it.

**Why this priority**: Finding #14 — a BLOCKER-adjacent gap in the kit's highest-risk lane,
and the audience most likely to use Critical solo (the kit's primary solo-developer audience)
is the audience least protected today.

**Independent Test**: Read `critical-delivery.md`'s Critical-solo clause; it names a specific
artifact (what gets produced), a specific minimum duration (the cooling-off window), and states
in one explicit sentence that this is a mitigation, not independence.

**Acceptance Scenarios**:

1. **Given** a solo developer merging a Critical feature, **When** they check
   `critical-delivery.md`, **Then** they find a named artifact they must produce and a stated
   minimum cooling-off duration before merge.
2. **Given** the same clause, **When** read by a new adopter, **Then** it states plainly that
   this substitute does not provide true independent review.

---

### Edge Cases

- What happens to a feature already mid-flight on the old (contradictory) rules when this
  amendment lands? → Out of scope: this is the kit's own first Standard-lane feature: there is
  no other mid-flight feature to migrate.
- What happens if a future amendment edits the constitution but misses a mirror named in the
  now-complete SYNC header? → Out of scope for this feature; the mechanized mirror check is
  explicitly deferred to v1.1 (`review/out/DECISION.md` rejected findings, "Eliminate the
  mirrored Constitution Check").
- What happens to principles V, VI, and X during the amendment? → V (PK standard) and VI
  (audit fields) move to the database rulebook as conventions; X is deleted outright (finding
  #15). This is in scope because it rides the same constitution version bump as the rest of
  this amendment, per `review/out/DECISION.md`'s "one amendment, one version bump" framing.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Definition of Done MUST state, unambiguously, that gates 1–5 apply at every
  phase commit and gate 6 (human review) applies once per feature at merge to main, for the
  Standard lane.
- **FR-002**: `docs/sdlc/branch-strategy.md`, `docs/sdlc/review-process.md`, and constitution
  principle XII MUST be consistent with FR-001 — no document may state a conflicting
  unit-of-review.
- **FR-003**: `.specify/templates/tasks-template.md` MUST NOT instruct the agent that tests are
  optional; its test-policy language MUST be consistent with constitution principle XI.
- **FR-004**: The constitution's SYNC header mirror list MUST enumerate every template and
  document that restates constitutional content, including `tasks-template.md`.
- **FR-005**: `.specify/templates/spec-template.md` MUST include a required `Delivery Level`
  field (enumerated: Lite, Standard, Critical) in the spec header.
- **FR-006**: The spec-quality checklist template MUST include a check that fails when
  `Delivery Level` is unfilled or not one of the three enumerated values.
- **FR-007**: The kit MUST state a phase-size rule — criteria for what may be bundled into one
  phase (e.g., independently revertible, one meaningfully-testable slice) — and this rule MUST
  be checked at plan approval, before implementation begins.
- **FR-008**: The source-of-truth ladder MUST exist in exactly one canonical document; every
  other document that currently restates it (`CLAUDE.md`, `plan-template.md`) MUST instead
  reference that canonical document.
- **FR-009**: Constitution principles V and VI MUST be removed from the constitution and
  restated as conventions in the database rulebook template; principle X MUST be deleted.
  Remaining principles MUST be renumbered contiguously, and every cross-reference to a
  renumbered principle MUST be updated.
- **FR-010**: `docs/sdlc/critical-delivery.md`'s Critical-solo review substitute MUST name a
  concrete artifact to be produced and a minimum cooling-off duration before merge, and MUST
  state explicitly that this substitute is a mitigation, not independent review.
- **FR-011**: The constitution's version number MUST be incremented and the amendment recorded
  in its amendment history, covering all changes in this feature as a single version bump.
- **FR-012**: After this feature merges, `scripts/doc-lint.ps1` MUST still exit 0 (kit
  structural integrity preserved) and a full-text search for the old per-phase human-review
  language, the optional-tests instruction, and the duplicated ladder rungs MUST return zero
  matches outside of `review/` (the review artifacts stay as a historical record).

### Key Entities

- **Definition of Done**: the six gates a phase or feature must pass; this feature changes
  which gates apply at which unit (phase vs. feature).
- **Source-of-truth ladder**: the ordered list of documents an agent consults to resolve
  conflicting guidance; this feature collapses three copies into one.
- **Delivery Level**: Lite / Standard / Critical, declared per feature; this feature gives it
  a home in `spec.md`.
- **Constitution principle**: a numbered, amendment-controlled rule; this feature renumbers and
  prunes the set.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A search of the repository (excluding `review/`) for text stating a per-phase
  human-review requirement returns zero matches.
- **SC-002**: `tasks-template.md` contains zero instances of tests described as optional.
- **SC-003**: `spec-template.md` contains exactly one required `Delivery Level` field, and this
  spec (`001-delivery-core-amendment/spec.md`) already conforms to that field's shape.
- **SC-004**: The source-of-truth ladder's full ordered rung list appears in exactly one file
  in the repository.
- **SC-005**: The constitution version number after this feature is strictly greater than
  before, with exactly one new amendment entry covering this feature's full scope.
- **SC-006**: `scripts/doc-lint.ps1` exits 0 after this feature's changes.
- **SC-007**: `critical-delivery.md`'s Critical-solo clause names a specific artifact and a
  specific minimum duration (a number, not a vague phrase like "some time").

## Assumptions

- This feature covers documentation and template changes only — no application code, no
  runtime enforcement (that is feature 002, `enforcement-pack`, explicitly out of scope here
  per `review/out/DECISION.md`'s v1 plan).
- "Gates 1–5 per phase, gate 6 per feature" (Open decision 1, Option A in `DECISION.md`) is the
  adopted resolution — the user has already agreed with the decision document's
  recommendations, including this one.
- Renumbering constitution principles after deleting X and demoting V/VI is in scope for this
  feature since it rides the same version bump; it does not require a separate feature.
- This spec follows the existing `spec-template.md` (which does not yet have the `Delivery
  Level` field this feature adds) — the field is included manually here since this feature is
  what defines it; once merged, future specs get it from the template directly.
- No `screenshots/` directory applies; the Visual Inventory section is omitted per the
  template's own instruction.
