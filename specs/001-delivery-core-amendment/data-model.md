# Data Model: Delivery Core Amendment

This feature has no application data model — it amends governance documents. In place of
entities/fields, this document maps the "entities" that actually change: the governance
documents themselves, the section each edit lands in, and the state transition each undergoes.
This is the artifact a reviewer checks the diff against, phase by phase.

## Entity: Governance Document

- **Path**: repository-relative path to the file.
- **Section**: the heading or clause changed.
- **Before → After**: the substantive change, one line.
- **Phase**: which of this feature's three phases carries the change.

| Path | Section | Before → After | Phase |
|---|---|---|---|
| `docs/sdlc/definition-of-done.md` | Gate 6 | "before it is considered complete" (implies per-phase) → explicit feature-merge scope; gates 1–5 stay per-phase | 1 |
| `docs/sdlc/branch-strategy.md` | Merge rule | Cross-checked against DoD gate 6 wording; no content change expected, verified not contradicted | 1 |
| `docs/sdlc/review-process.md` | After Each Phase / Human Review | Aligned so "Human Review" section reads as feature-level, not per-phase | 1 |
| `.specify/memory/constitution.md` | SYNC IMPACT REPORT, mirror list | `tasks-template.md` added to "Templates requiring updates" list | 1 |
| `.specify/templates/tasks-template.md` | Tests line (`:11`) | "Tests are OPTIONAL..." → tests required for business-critical logic per constitution XI (renumbered VIII in Phase 3) | 1 |
| `.specify/templates/spec-template.md` | Header | `**Delivery Level**:` field added under `**Status**` | 1 |
| `CLAUDE.md` | Source of Truth Priority | Full 7-rung restatement → pointer to constitution II + conflict-rule prose retained | 1 |
| `.specify/templates/plan-template.md` | Constitution Check, principle II line | 5-item inline paraphrase → pointer to constitution II | 1 |
| `.specify/templates/plan-template.md` | Constitution Check, Controlled Delivery line | Phase-size rule added (independently revertible, one testable slice) | 2 |
| `docs/sdlc/definition-of-done.md` | Gate 2 | Cross-reference to the new phase-size rule added | 2 |
| `docs/sdlc/critical-delivery.md` | Item 5, Independent approval | Undefined "second-model review plus cooling-off" → named artifact (`second-model-review.md`) + 24-hour minimum duration + honesty sentence | 2 |
| `.specify/memory/constitution.md` | Principles V, VI | Deleted from constitution; content moved | 3 |
| `docs/rulebooks/database-rules-template.md` | Schema Standards | Receives V/VI content as standalone conventions (no longer "mirroring" the constitution) | 3 |
| `.specify/memory/constitution.md` | Principle X | Deleted outright, no replacement | 3 |
| `.specify/memory/constitution.md` | Principles VII–XIII | Renumbered to V–X (contiguous) | 3 |
| `.specify/templates/plan-template.md` | Constitution Check list | Renumbered to match | 3 |
| `CLAUDE.md`, `docs/sdlc/*.md`, `docs/rulebooks/*.md` | Any numbered-principle reference | Swept and updated to new numbers | 3 |
| `.specify/memory/constitution.md` | SYNC IMPACT REPORT, version | 0.2.0 → 0.3.0, one amendment entry covering all three phases | 3 (recorded at feature completion) |

## Relationships

- The constitution is the root: every other document either mirrors it (and is now reduced to
  a pointer where finding #7 applies) or implements it operationally (DoD, branch-strategy,
  review-process implement XII/XIII; templates implement I).
- `spec-template.md`'s new `Delivery Level` field is read by `critical-delivery.md` and
  `branch-strategy.md`, which already assume it exists — this feature makes that assumption
  true rather than introducing a new relationship.
- The SYNC IMPACT REPORT's mirror list is the dependency graph the constitution's own amendment
  procedure relies on to avoid finding #2's failure mode recurring — this feature completes
  that list (adds `tasks-template.md`) as part of Phase 1.

## State Transitions

Not applicable in the entity-lifecycle sense — the closest analogue is the constitution's own
version state: `0.2.0` (unratified kit template) → `0.3.0` (unratified kit template, amended),
recorded in the SYNC IMPACT REPORT header per the existing versioning policy (MINOR: principle
additions/removals and materially expanded guidance — this amendment is MINOR under that
policy, not MAJOR, since removed principles V/VI/X are demoted/deleted governance content, not
a backward-incompatible change to a *ratified* project's already-adopted rules; this repository
has never ratified a project-level constitution, so no adopter is broken by the renumbering).
