# Feature Specification: Field-Lesson Harvest

**Feature Branch**: `005-field-lesson-harvest`  
**Created**: 2026-09-03  
**Status**: Draft  
**Delivery Level**: Standard

**Input**: User description: "Field-lesson harvest: encode the adoption traps discovered
during expense-tracker and flowboard adoptions into permanent kit guidance so future
adoptions don't rediscover them by accident (docs/roadmap.md GAP-003): the create-next-app
`.env*` gitignore trap, the skipped-`git init`-in-existing-tree trap, the reused-connection-
string (`Spc`) incident, the `--warnaserror`-vs-transitive-vulnerability trap, and the raw-
imported-docs-break-doc-lint trap. Encode each as concrete, checkable guidance in `adoption/`
and, where tier-specific, in the relevant `docs/rulebooks/` template."

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - Scaffolding tool traps caught before they bite (Priority: P1)

An engineer (or agent) adopting the kit into a new or existing repo runs a frontend
scaffolding tool (e.g. `create-next-app`) as part of the greenfield or existing-system
adoption track. Following the adoption steps as written, they avoid the two scaffolding
traps: the tool's generated `.gitignore` silently swallowing `.env.example` via a blanket
`.env*` pattern, and the tool skipping `git init` (or reinitializing git) when run inside an
already-initialized repo tree.

**Why this priority**: Both traps were hit on the very first scaffold of an adoption
(expense-tracker 001, flowboard scaffolds) — they strike before any feature work begins, so
they gate everything downstream. Silently losing `.env.example` or ending up in an unexpected
git state is invisible until much later (a teammate can't find the env template; commits land
on the wrong repo root).

**Independent Test**: Can be fully tested by running the frontend scaffolding step of the
adoption track in a fresh existing-repo tree and confirming that `.env.example` is tracked in
git and that the resulting git state matches the parent repo's root — without needing any
other adoption step to be updated first.

**Acceptance Scenarios**:

1. **Given** the adoption track's frontend scaffolding step, **When** an engineer scaffolds a
   JS/TS frontend with a tool that generates a `.env*`-pattern `.gitignore`, **Then** the step
   explicitly instructs checking that `.env.example` is not excluded (or amending the ignore
   pattern) before the first commit.
2. **Given** the adoption track's frontend scaffolding step, **When** the scaffolding tool is
   run inside a directory that is already part of a git repository, **Then** the step
   explicitly instructs verifying git state afterward (no stray nested repo, no skipped
   `git init` leaving files untracked) before proceeding.

---

### User Story 2 - Database connection traps caught before the first migration (Priority: P1)

An engineer runs a project's first database migration (or first `database update`) — on a
greenfield project's first write-slice feature, or against a database inherited from an
existing system — and, following kit guidance, verifies the connection string resolves to an
isolated, project-owned database before the migration runs. This prevents a repeat of the
reused-connection-string ("`Spc`") incident, where a local development database that already
held unrelated data was silently reused because a config default pointed at it.

**Why this priority**: This trap caused a real incident with actual (if non-production) data
at risk — destructive schema changes ran against a database the project did not own. It is
the highest-severity trap in the set, and it is not confined to one adoption track: it strikes
at the first migration of *any* project, greenfield or existing-system.

**Independent Test**: Can be fully tested by walking a project up to the point of its first
migration with a connection string inherited from a default or reused config, and confirming
that guidance forces an explicit check of the target database's identity and ownership before
that migration runs — independent of any other trap's fix.

**Acceptance Scenarios**:

1. **Given** a project about to run its first database migration, **When** the connection
   string was inherited from a default, an existing `.env`/config file, or a local development
   server that hosts other unrelated databases, **Then** kit guidance requires confirming which
   database the string resolves to and that it is dedicated to this project before the
   migration runs.
2. **Given** the check surfaces that the connection string targets a shared or unrelated
   existing database, **Then** the guidance directs the engineer to point at (or create) an
   isolated database before proceeding, rather than proceeding with a destructive operation
   against unknown existing state.

---

### User Story 3 - Strict-build and doc-lint traps caught before they block a gate (Priority: P2)

An engineer sets up the project's gate command with a strict-build flag (e.g.
`--warnaserror`), or imports documentation from an external source into `docs/`. Following the
relevant rulebook/adoption guidance, they know how to handle a strict-build failure caused by
a vulnerability in a transitive, template-generated dependency (rather than their own code),
and how to bring imported documentation into doc-lint compliance before it lands.

**Why this priority**: Both traps surface later than the P1 traps (during gate-proving or
ongoing doc maintenance, not the first scaffold) and have known, low-risk workarounds — they
block progress and cause confusion but carry no data-loss risk.

**Independent Test**: Can be fully tested by (a) proving the gate on a scaffold with a known
transitive-dependency vulnerability and confirming the guidance resolves it without disabling
strict-build wholesale, and (b) importing a raw external doc and confirming the guidance's
steps bring it to a doc-lint-passing state — either half testable without the other.

**Acceptance Scenarios**:

1. **Given** a strict-build flag is enabled per the backend/frontend rulebook, **When** the
   gate fails due to a vulnerability in a transitive, template-generated dependency, **Then**
   the rulebook or gate-command guidance documents how to triage and resolve it (upgrade,
   pin, or narrowly-scoped suppression with a recorded reason) without blanket-disabling the
   strict flag.
2. **Given** an engineer wants to add documentation copied from an external source into
   `docs/`, **When** they follow the adoption or doc-lint guidance, **Then** they are directed
   to normalize the doc to the kit's conventions (front matter, heading structure, path
   references) before it is added, so it passes doc-lint on first run.

---

### Edge Cases

- What happens when the scaffolding tool used isn't `create-next-app` but another generator
  with the same blanket-ignore behavior (e.g. other framework CLIs)? Guidance should name the
  pattern (blanket `.env*` ignores swallowing example files), not just the one tool.
- How does the check handle a case where the "reused" connection string is intentional (e.g.
  deliberately sharing a database across services)? It must ask for explicit confirmation, not
  forbid reuse outright.
- What happens when a `--warnaserror`-style flag is required by the stack profile itself
  (not optional)? Guidance must give a resolution path, not just a warning.
- What happens when imported documentation is large (e.g. a whole external handbook)? Guidance
  should scale to a partial/summarized import, not assume a single short doc.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The greenfield (`adoption/greenfield.md`) and existing-system
  (`adoption/existing-system.md`) tracks MUST each include an explicit, checkable step (not
  narrative-only prose) that catches a scaffolding tool's `.gitignore` silently excluding
  `.env.example` via a blanket `.env*` pattern, at the point where scaffolding happens.
- **FR-002**: The same tracks MUST include an explicit, checkable step verifying git state
  (no skipped `git init`, no unexpected nested repo) immediately after running a scaffolding
  tool inside an already-initialized repo tree.
- **FR-003**: Kit guidance MUST include an explicit, checkable step requiring confirmation of
  the target database's identity and isolation before a project's first migration or write
  operation runs against a connection string that was inherited, defaulted, or reused from
  existing configuration — placed where it governs every project regardless of adoption track
  (a database-tier rule), with adoption-track guidance pointing to it at the first-write-slice
  milestone (`adoption/greenfield.md` step 5; `adoption/existing-system.md` step 4).
- **FR-004**: The relevant rulebook template(s) (backend and/or database, per
  `docs/rulebooks/`) or `docs/sdlc/gate-command.md` MUST document how to triage a strict-build
  failure caused by a vulnerability in a transitive, template-generated dependency, without
  recommending a blanket disable of the strict flag.
- **FR-005**: Adoption guidance MUST document, at the point where rulebook content is authored
  or imported from an external source (`adoption/greenfield.md` step 2;
  `adoption/existing-system.md` step 7), the steps to normalize that content so it passes the
  kit's doc-lint checks before being added under `docs/`.
- **FR-006**: Each of the five traps MUST be encoded as a concrete, checkable step (a
  numbered instruction, a checklist item, or a machine check) at the specific point in the
  adoption flow or rulebook where the trap would otherwise be triggered — not as a standalone
  "lessons learned" narrative document disconnected from the steps.
- **FR-007**: `docs/roadmap.md` MUST be updated to mark the field-lesson-harvest roadmap row
  (covering GAP-003) with this feature's spec path and move its status forward once shipped,
  consistent with how prior shipped features (001–004) are recorded.

### Key Entities

- **Adoption trap**: A specific, previously-unencoded failure mode discovered during a real
  kit adoption (expense-tracker, flowboard). Attributes: the triggering action, the point in
  the adoption flow or rulebook where it occurs, the concrete guidance that prevents it, and
  the source session it came from.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All five named adoption traps have a corresponding checkable step in
  `adoption/` or the relevant `docs/rulebooks/` template, verifiable by a straight read-through
  of the updated files (no trap remains "tribal knowledge only").
- **SC-002**: Re-walking the exact sequence of actions that caused each of the five traps in
  the expense-tracker/flowboard sessions, against the updated adoption steps, results in the
  trap being caught (surfaced to the engineer) before it causes the original downstream
  effect (lost `.env.example`, unexpected git state, migration against the wrong database,
  a blocked gate, or a doc-lint failure).
- **SC-003**: `docs/roadmap.md`'s GAP-003 row and the field-lesson-harvest feature row are
  updated to reflect the shipped status, keeping the roadmap's authored table accurate.

## Assumptions

- The five traps as described in the feature input are the complete initial harvest; no
  additional undocumented traps are pulled in scope, per constitution I (no invented scope
  beyond an approved spec).
- "Checkable" means a human or agent following the step can determine pass/fail without
  needing to have witnessed the original incident — plain, unambiguous instructional text
  satisfies this bar; an automated machine check is a bonus, not a requirement of this feature.
- The `--warnaserror` trap's resolution guidance targets whichever backend/frontend stack the
  adopting project actually uses; this feature documents the triage pattern (upgrade, pin, or
  recorded, scoped suppression), not a fix for one specific dependency.
- No existing adopted project (flowboard, expense-tracker) is retroactively modified by this
  feature — it changes the kit's own `adoption/` and `docs/rulebooks/` guidance only; flowing
  the changes down to already-adopted projects is a separate, later kit-update-channel action.
