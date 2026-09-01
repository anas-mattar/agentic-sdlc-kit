# Implementation Plan: Delivery Core Amendment

**Branch**: `001-delivery-core-amendment` | **Date**: 2026-09-01 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `specs/001-delivery-core-amendment/spec.md`

## Summary

One constitutional amendment (version 0.2.0 → 0.3.0) that resolves every verified internal
contradiction in the kit's own delivery core, as decided in `review/out/DECISION.md`. No
application code changes: this feature edits governance documents and templates only. The
approach is three independently revertible phases, ordered by dependency and blast radius —
core contradiction fix, missing rule definitions, then a mechanical renumbering sweep.

## Technical Context

**Language/Version**: N/A — Markdown governance documents and Spec Kit templates; no
application code.
**Primary Dependencies**: None. Uses the kit's existing tooling: `scripts/doc-lint.ps1`
(structural integrity check) and `git grep` (content-presence checks defined in Success
Criteria).
**Storage**: N/A.
**Testing**: `scripts/doc-lint.ps1` (path/structure integrity) plus targeted `git grep`
searches per SC-001–SC-007 in `spec.md`, run by the user at each phase gate — the kit has no
other test harness for its own documents.
**Target Platform**: N/A — this repository itself (Windows/PowerShell tooling).
**Project Type**: Documentation / governance amendment (the kit governing itself).
**Performance Goals**: N/A.
**Constraints**: Every changed document must keep `doc-lint.ps1` green (no broken path
references introduced by renumbering or file moves — no files are moved or renamed).
**Scale/Scope**: 9 documents touched: `.specify/memory/constitution.md`,
`docs/sdlc/definition-of-done.md`, `docs/sdlc/branch-strategy.md`,
`docs/sdlc/review-process.md`, `docs/sdlc/critical-delivery.md`, `CLAUDE.md`,
`.specify/templates/tasks-template.md`, `.specify/templates/spec-template.md`,
`.specify/templates/plan-template.md`, `.specify/templates/checklist-template.md`,
`docs/rulebooks/database-rules-template.md`. (11 files, listed individually since "9" above
undercounts — corrected in Project Structure below.)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

This feature amends the constitution itself; the gate below is evaluated against the
**current, unamended** constitution (0.2.0), since amendments take effect only after human
approval at merge (constitution Governance § Amendment procedure). Most principles are
inapplicable because this feature ships no application code, schema, or integration —
inapplicability is recorded explicitly rather than silently skipped, per constitution II's
conflict rule.

- [x] **Specification First (I)**: spec.md exists and is approved (user confirmed agreement
      with `review/out/DECISION.md`, which this spec operationalizes); this plan.md and the
      forthcoming tasks.md complete the sequence before implementation.
- [x] **Source of Truth (II)**: No conflict between spec.md and this plan — and resolving II's
      own triplicated restatement (finding #7) is in scope of this feature. No visual
      references apply (no `screenshots/`).
- [x] **Repository Separation (III)**: N/A — single-repo kit, principle marked optional for
      single-repo projects; not touched by this feature.
- [x] **Architecture Consistency (IV)**: PASS — no new pattern, framework, or persistence
      approach introduced; this feature edits existing governance documents in place.
- [x] **Data Standards (V)**: N/A — no schema touched. (Note: this feature demotes principle V
      itself to the database rulebook as a documentation change; it does not violate V.)
- [x] **Auditability (VI)**: N/A — no business entities. (Same demotion note as V.)
- [x] **Domain Invariants (VII)**: N/A — `{{DOMAIN_INVARIANTS_PATH}}` is unfilled at kit level;
      no domain module is edited by this feature.
- [x] **Security (VIII)**: N/A — no auth, no secrets, no logging surfaces touched.
- [x] **External Integration Governance (IX)**: N/A — no integrations.
- [x] **Performance Responsibility (X)**: N/A — documentation only.
- [x] **Testing Requirements (XI)**: PASS by the kit's own equivalent — `doc-lint.ps1` plus the
      grep-based checks in spec.md's Success Criteria are this feature's regression coverage,
      since there is no business-critical *code* to test. Fixing XI's own contradiction with
      `tasks-template.md` (finding #2) is itself in scope.
- [x] **Human Review Requirement (XII)**: PASS — this plan schedules human review once, at
      merge, per the very unit-of-review fix this feature makes (finding #1); see Phase
      breakdown below.
- [x] **Controlled Delivery (XIII)**: PASS — delivered as three phases below, each
      independently revertible and gated by the user-run `doc-lint.ps1` + grep checks.

No violations requiring Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/001-delivery-core-amendment/
├── spec.md                      # already written
├── plan.md                      # this file
├── research.md                  # Phase 0 output
├── data-model.md                # Phase 1 output — documents amendment-map, not app data
├── quickstart.md                # Phase 1 output — post-merge verification steps
└── tasks.md                     # Phase 2 output (/speckit.tasks — not this command)
```

No `contracts/` — this feature exposes no external interface (no API, no CLI, no library
surface); the template's Phase 1 contracts step is skipped per its own "skip if purely
internal" instruction.

### Governance documents changed (repository root, by phase)

```text
Phase 1 — Core contradiction fix
├── docs/sdlc/definition-of-done.md        # gate 6 scoped to feature, not phase
├── docs/sdlc/branch-strategy.md           # merge/review language aligned
├── docs/sdlc/review-process.md            # "After Each Phase" / "Human Review" sections aligned
├── .specify/memory/constitution.md        # XII/XIII wording aligned; SYNC header updated
├── .specify/templates/tasks-template.md   # test-policy line fixed
├── .specify/templates/spec-template.md    # Delivery Level field added
├── .specify/templates/checklist-template.md (N/A — checklist content lives per-feature;
│                                              spec-quality check added via spec-template's
│                                              companion instructions instead — see research.md)
├── CLAUDE.md                              # Source of Truth section → pointer, not restatement
└── .specify/templates/plan-template.md    # Source of Truth Constitution Check line → pointer

Phase 2 — Missing rule definitions
├── .specify/templates/plan-template.md    # phase-size rule added to Controlled Delivery check
├── docs/sdlc/definition-of-done.md        # phase-size rule referenced at gate 2
└── docs/sdlc/critical-delivery.md         # Critical-solo artifact + cooling-off duration defined

Phase 3 — Principle pruning & renumbering sweep
├── .specify/memory/constitution.md        # V/VI demoted, X deleted, remaining renumbered
├── docs/rulebooks/database-rules-template.md  # V/VI content received as conventions
├── .specify/templates/plan-template.md    # Constitution Check list renumbered
├── CLAUDE.md                              # any numbered-principle references updated
└── docs/sdlc/*.md                         # grep sweep for stale principle numbers
```

**Structure Decision**: No `src/`/`tests/` split applies — this is a documentation-only
feature. The three phases above are the "source structure" for this feature; each is one git
commit on `001-delivery-core-amendment`, independently revertible.

## Complexity Tracking

*No entries — Constitution Check has no unjustified violations.*
