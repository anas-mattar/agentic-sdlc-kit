# Implementation Plan: Field-Lesson Harvest

**Branch**: `005-field-lesson-harvest` | **Date**: 2026-09-03 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/005-field-lesson-harvest/spec.md`
**Gate Batching**: phases 1-3 <!-- Lite/Standard only. All three phases are pure documentation
  edits to adoption/ and docs/rulebooks/ — the gate is doc-lint (seconds), there is no code
  behavior to isolate between phases, and each phase touches a disjoint trap/file set. One
  certifying user-run gate at the end of phase 3; each phase still gets its own commit, scope
  check, and AI review. -->

## Summary

Encode five field-discovered adoption traps (GAP-003) as concrete, checkable steps at the
exact point in kit guidance where each actually occurred (verified against the incident
records in kit memory, not assumed — see research.md), in three independently revertible
phases, one per spec user story: (1, US1) the scaffolding traps — `.env*`-gitignore
swallowing `.env.example` and skipped `git init` — added to `adoption/greenfield.md` step 3
("prove the gate", where both actually happened) plus a pointer in
`adoption/existing-system.md` step 7; (2, US2) the reused-connection-string (`Spc`) incident —
a rule added to `docs/rulebooks/database-rules-template.md` (the trap struck at a project's
first migration, not during onboarding), cross-referenced from both adoption tracks'
first-write-slice steps; (3, US3) the strict-build-vs-transitive-vulnerability trap — a new
`docs/sdlc/gate-command.md` section cross-referenced from `adoption/greenfield.md` step 3 (the
same step where the real incident happened) — and the raw-imported-docs trap, added at the
rulebook-authoring step in both adoption tracks (`greenfield.md` step 2,
`existing-system.md` step 7), where that incident actually occurred. No code changes; no new
dependencies; no schema.

## Technical Context

**Language/Version**: N/A — Markdown documentation edits only (kit convention: prose +
checkable steps, no code)
**Primary Dependencies**: None new. Existing `scripts/doc-lint.ps1` is the only machine check
touched (path additions only, if any new file is introduced — expected: no new files, only
edits to existing adoption/rulebook files)
**Storage**: N/A
**Testing**: Manual verification per `quickstart.md` — re-walk each of the five original
incident sequences against the updated guidance and confirm the trap is now surfaced before
its original downstream effect (per spec SC-002); doc-lint stays green
**Target Platform**: N/A (documentation)
**Project Type**: governance kit documentation (single repo)
**Performance Goals**: N/A
**Constraints**: no new files unless a trap has no existing home (expected: all five traps
slot into existing adoption/rulebook files); no rewriting of unrelated adoption/rulebook
content; no invented sixth trap beyond the five named in spec.md
**Scale/Scope**: 5 traps, 5 files edited (`adoption/greenfield.md`,
`adoption/existing-system.md`, `docs/rulebooks/database-rules-template.md`,
`docs/sdlc/gate-command.md`, `docs/roadmap.md` at merge)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Specification First (I)**: spec.md approved (checklist green, no open markers); this
  plan precedes tasks.md; no implementation started.
- [x] **Source of Truth (II)**: No conflicts. This feature adds steps to `adoption/` and
  `docs/rulebooks/` templates — it does not restate or override the constitution, CLAUDE.md,
  or any spec/plan of another feature.
- [x] **Architecture Consistency (IV)**: No new patterns, frameworks, or tooling — plain
  Markdown additions following each target file's existing structure and voice.
- [x] **Domain Invariants (V)**: N/A (kit template has none instantiated).
- [x] **Security (VI)**: No secrets, no auth surfaces. The database-connection-trap guidance
  (Phase 2) is itself a security/data-safety improvement — it makes accidental reuse of a
  connection string harder to do silently.
- [x] **External Integration Governance (VII)**: No external integrations introduced.
- [x] **Testing Requirements (VIII)**: Not business logic; verification is the quickstart
  re-walk against the five original incident sequences (spec SC-002), which is the correct
  substitute for automated tests on prose guidance.
- [x] **Human Review (IX)**: One feature-level human review at merge.
- [x] **Controlled Delivery (X)**: 3 phases, each independently revertible (below);
  **Gate Batching: phases 1-3** declared above per the batched-gates clause — justified
  because every phase is a doc-only edit with a seconds-long gate and disjoint file/trap sets,
  so per-phase certifying gates would add owner interruptions without added safety. Phase
  sizing verified per phase below.

  **Phase sizing rule**: each phase below is independently revertible and corresponds to one
  testable slice (one user story from spec.md).

## Project Structure

### Documentation (this feature)

```text
specs/005-field-lesson-harvest/
├── spec.md              # complete
├── plan.md              # this file
├── research.md          # Phase 0 — decisions on rulebook placement + doc-lint scope
├── quickstart.md        # Phase 1 — five re-walk verification scenarios
├── checklists/requirements.md
└── tasks.md             # /speckit.tasks output
```

No `data-model.md` and no `contracts/` — this feature introduces no entities and no external
or programmatic interface; it edits existing guidance documents only.

### Source Code (repository root)

```text
adoption/
├── greenfield.md             # AMEND — Phase 1 (US1): step 3, env-gitignore + git-init bullets
                               #         Phase 2 (US2): step 5, cross-ref to database-rules bullet
                               #         Phase 3 (US3): step 3, strict-build cross-ref bullet;
                               #                         step 2, raw-imported-docs paragraph
└── existing-system.md        # AMEND — Phase 1 (US1): step 7, scaffolding-trap pointer
                               #         Phase 2 (US2): step 4, cross-ref to database-rules bullet
                               #         Phase 3 (US3): step 7, raw-imported-docs paragraph
docs/rulebooks/
└── database-rules-template.md  # AMEND — Phase 2 (US2): connection-string-trap rule
docs/sdlc/
└── gate-command.md            # AMEND — Phase 3 (US3): strict-build/transitive-vuln triage
                                #         section
docs/roadmap.md                 # AMEND — at merge: GAP-003 row + roadmap row → shipped
```

**Structure Decision**: single repo, kit-root documentation tree. No new files are created —
every trap is inserted as a step in an existing adoption track or rulebook template, at the
exact point each trap actually occurred in the source incidents (research.md), per FR-006's
requirement that traps live at their trigger point rather than in a standalone lessons-learned
document.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| — none — | | |
