# Research: Field-Lesson Harvest

Phase 0 output. Placement was re-derived from the actual incident records (kit memory:
`expense-tracker-sample-adoption.md`, `flowboard-adoption.md`) rather than guessed — the
original spec draft mis-scoped two traps before this correction, caught here before any file
was edited.

## Evidence: where each trap actually happened

Both source adoptions (expense-tracker, flowboard) used the **greenfield** track
(`adoption/greenfield.md`), nested multi-repo layout:

- `.env*`-gitignore trap and skipped-`git init` trap: both hit during greenfield **step 3**
  ("Define and PROVE the gate ... scaffold the empty project(s)") — flowboard's
  `create-next-app` run (commit 0ef1d7c) and expense-tracker's 001 scaffold.
- `--warnaserror` vs transitive-vulnerability trap: also greenfield **step 3** — flowboard
  pinned `Microsoft.OpenApi` 2.12.2 because the template's transitive 2.0.0 failed
  `--warnaserror` on GHSA-v5pm-xwqc-g5wc.
- Reused-connection-string (`Spc`) incident: expense-tracker **feature 002**
  (`expenses-read`, its first `dotnet ef database update`) — i.e. the project's first
  write/migration, which greenfield step 5 names as "read-only slices before write slices" —
  **not** during adoption steps 0-8 at all, and **not** an existing-system-track incident.
- Raw-imported-docs-break-doc-lint trap: flowboard's rulebook instantiation (step 7,
  "Grandfather deliberately" — the user provided rule packs from a prior project), when
  authoring `docs/rulebooks/backend/*` and `docs/rulebooks/frontend/*` from that external
  source.

This evidence overturns two placements assumed in the initial spec draft: the connection-
string trap is not Track-B-only (User Story 2 and FR-003 were corrected to be track-agnostic,
anchored to "first migration" instead), and the raw-imported-docs trap belongs at rulebook
authoring, not generic ongoing doc-lint upkeep (FR-005 corrected accordingly).

## D1: Where do the scaffolding-tool traps go (env-gitignore, skipped git init)?

**Decision**: A new subsection inside `adoption/greenfield.md` step 3 ("Define and PROVE the
gate"), immediately after "scaffold the empty project(s)" — not a new top-level step. Add a
parallel, shorter cross-reference in `adoption/existing-system.md` at the point a new
component/repo is scaffolded into an existing system (existing-system.md has no such step
today; add one short paragraph to step 7, where new tier rulebooks are instantiated for a
newly-added component, pointing back to greenfield step 3's checklist) — evidence for this
trap is greenfield-only, but the mechanism (a scaffolding CLI) is identical if Track B ever
adds a new component, so a pointer avoids duplicating the content.

**Rationale**: Step 3 is where both real incidents happened — it is literally the step whose
prose already says "scaffold the empty project(s)". Inserting a new top-level step (as
originally planned) would separate the guidance from its trigger action, which is exactly the
anti-pattern FR-006 prohibits.

**Alternatives considered**: A new standalone step between 1 and 2 (the original plan draft)
— rejected once the evidence showed scaffolding happens in step 3, not before step 2.

## D2: Where does the connection-string trap go?

**Decision**: `docs/rulebooks/database-rules-template.md`, new bullet in an existing or new
"Setup" section: *"Before the first migration runs, confirm the connection string's target
database is dedicated to this project (not a reused local-dev instance or shared/production
database)."* Cross-referenced from `adoption/greenfield.md` step 5 ("read-only slices before
write slices" — the step that names the first write slice) and
`adoption/existing-system.md` step 4 (golden-fixture tests before the agent touches critical
logic — the step closest to first-write risk in that track).

**Rationale**: The real incident happened at a project's first migration, a moment that
belongs to the database tier generically (any project, any track) rather than to one
adoption-track step. `database-rules-template.md` is exactly the file the kit uses for rules
that must hold throughout a project's life, not just during onboarding — matching how the
initial plan draft's "alternatives considered" already flagged this as the more scalable
option before evidence confirmed it as the primary one.

**Alternatives considered**: `adoption/existing-system.md` alone, scoped to Track B (the
initial plan draft) — rejected once evidence showed the actual incident was a greenfield
project's feature 002, not an existing-system adoption.

## D3: Where do the strict-build and raw-imported-doc traps go?

**Decision (strict-build)**: `docs/sdlc/gate-command.md`, new section after "Minimum Gate",
cross-referenced from `adoption/greenfield.md` step 3 (same step as D1, since the flowboard
incident happened at the same "prove the gate" moment).

**Rationale**: Confirmed unchanged from the initial draft — `gate-command.md` is the kit's one
generic, stack-agnostic home for gate behavior, and the real incident (Microsoft.OpenApi pin)
happened at the exact step-3 gate-proving moment, so the cross-reference belongs there too.

**Alternatives considered**: `docs/rulebooks/backend-rules-template.md` — rejected (ties a
cross-cutting, any-stack gate-triage pattern to one tier's template; a frontend-only adopter
hitting the same class of failure via `npm audit` would never see it there).

**Decision (raw-imported-docs)**: A new short paragraph in `adoption/greenfield.md` step 2
("Fill CLAUDE.md" — the step that already says "instantiate a rulebook only for each tier")
and `adoption/existing-system.md` step 7 ("Grandfather deliberately" — the step that
instantiates rulebooks descriptively), pointing at the authoring convention already documented
in `scripts/doc-lint.ps1`'s header comment (bold/bracket wrapping for non-kit paths, the
`-FailOnSlots` flag), with a one-line worked example: content copied from an external rule
pack must have its own repo-code-paths written in **bold**, not backticks, and any
`{{SLOT}}`-looking placeholder either filled or removed before it is added.

**Rationale**: This is exactly where the flowboard incident happened — the user provided rule
packs at rulebook-instantiation time, not during a later doc-lint maintenance pass. Anchoring
the guidance to the rulebook-authoring step (not a generic "keep the framework honest" bullet,
as the initial draft assumed) puts it where an adopter will actually be looking when the
mistake is about to happen.

**Alternatives considered**: `adoption/greenfield.md` / `existing-system.md` step 7/8 ("Keep
the framework honest") — the initial draft's placement; rejected once evidence showed the
trigger moment is rulebook authoring, which precedes ongoing doc-lint upkeep by potentially
weeks. Modifying `doc-lint.ps1` to auto-normalize imported docs — rejected as scope creep
(spec Assumptions restrict this feature to guidance, not new tooling).

## Summary of file touches (confirms plan.md Project Structure)

| File | Change |
|---|---|
| `adoption/greenfield.md` | step 3 addition (env-gitignore + git-init + strict-build traps, Phase 1 & Phase 3); step 2 addition (raw-imported-docs, Phase 3) |
| `adoption/existing-system.md` | step 7 addition (scaffolding-trap pointer, Phase 1); step 7 addition (raw-imported-docs, Phase 3) |
| `docs/rulebooks/database-rules-template.md` | new Setup bullet (connection-string trap, Phase 2) |
| `adoption/greenfield.md` step 5 / `adoption/existing-system.md` step 4 | cross-reference to the new database-rules-template.md bullet (Phase 2) |
| `docs/sdlc/gate-command.md` | new section after "Minimum Gate" (strict-build triage, Phase 3) |
| `docs/roadmap.md` | GAP-003 row + roadmap row → shipped, at merge |

No file outside this table is touched. `docs/rulebooks/backend-rules-template.md` is
deliberately left unchanged (D3).
