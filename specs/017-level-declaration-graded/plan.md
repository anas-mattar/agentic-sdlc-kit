# Implementation Plan: Level Declaration Graded

**Branch**: `017-level-declaration-graded` | **Date**: 2026-10-11 | **Spec**: specs/017-level-declaration-graded/spec.md
**Input**: Feature specification + research.md (R1–R10) + decisions D1–D9 below
**Gate Batching**: none
**Gate Certification**: user-run

## Summary

Make the delivery level something the kit grades, with two complementary pieces. A **path
floor**: the adoption record lists critical-surface globs, and a Standard or Micro feature
whose Territory reaches one fails, unless it carries an approved, listed exception. A **written
claim**: new specs answer the four Critical triggers in a Level Rationale block, and the check
fails an absent, incomplete or self-contradicting one. The law is amended first (constitution
Principle X), then the shared reader, then the two checks, each proven with a passing and a
failing fixture. The change touches no feature's behaviour in a project that declares no
surfaces.

## Technical Context

**Language/Version**: PowerShell 7+ (`pwsh`), the kit's only language
**Primary Dependencies**: none new. Reuses `scripts/scope-lib.ps1` (Territory parsing and
matching), `scripts/adoption-lib.ps1` (the record reader pattern), and the amendment check's
approver validation in `scripts/enforcement-pack.ps1`
**Storage**: files only (`kit-adoption.json`, `spec.md`, `tasks.md`)
**Testing**: the enforcement harness (`tests/enforcement/`, feature 015): real temporary git
repositories, hand-written expectations, a passing and a failing fixture per rule
**Target Platform**: any runner that has `pwsh` and `git`; paths must match the same on
Windows and Linux (case-insensitive, both slash forms)
**Project Type**: governance tooling (scripts plus documents), not a service
**Performance Goals**: not applicable; the check adds a handful of file reads to a run that
already does dozens
**Constraints**: no new hard failure on the Lite lane; exit code unchanged for a project that
declares no surfaces; no verdict change for the three adopted projects (SC-004)
**Scale/Scope**: one new reader, two new checks, one doctor line, one constitution clause,
about nine documents mirrored

## Constitution Check

*GATE: passed before Phase 0; re-checked after Phase 1 design (below).*

- [x] **Specification First (I)**: `spec.md` exists and this plan follows it; `tasks.md` follows
  via `/speckit.tasks`. No implementation starts before all three are approved.
- [x] **Source of Truth (II)**: no conflict between artifacts. One stale premise in the spec
  (Edge Cases on GAP-026) is recorded in `research.md` R3 and does not change any behaviour.
- [ ] **Repository Separation (III)**: not applicable, the kit is a single repository.
- [x] **Architecture Consistency (IV)**: no new pattern. The reader copies
  `Get-DeveloperMode`'s shape, the matcher is `Test-InTerritory`, the approver validation is
  `Get-ConformingRecord`, the verdicts are the kit's own. No new package.
- [ ] **Domain Invariants (V)**: not applicable, the kit template's slot is unfilled.
- [x] **Security (VI)**: no secrets, no logging of sensitive data, no authentication surface.
- [ ] **External Integration Governance (VII)**: not applicable, no external integration.
- [x] **Testing Requirements (VIII)**: every rule has a passing and a failing harness fixture,
  hand-written (FR-014).
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI
  review with Reviewer Provenance.
- [x] **Controlled Delivery (X)**: five phases, one at a time, each independently revertible
  (see the sizing note below). No batching, no ci-held: this is a change to the enforcement
  scripts, so the owner runs the gate.

**Phase sizing rule**: each phase is one testable slice that does not depend on a later one.
Phase 1 is documents only. Phase 2 adds a reader nothing calls yet. Phases 3 and 4 each add
one check and its fixtures and neither needs the other. Phase 5 is flow-down and bookkeeping.
Reverting any phase leaves the kit consistent, with one exception stated in D1: reverting
phase 1 while 3 or 4 stand would leave a check enforcing a rule the constitution does not
carry, so phases 3 and 4 must be reverted first.

**Post-design re-check**: no new violation. The only item that needs the owner is D1 (a
constitutional amendment), which the process already requires.

## Decisions

**D1 — Law first (R8).** Phase 1 amends constitution Principle X with a *Level declaration*
clause, MINOR 0.7.0 to 0.8.0: a numbered feature states its level in writing against the four
triggers; a project may declare critical surfaces; a sub-Critical feature that touches one
needs promotion, a narrower Territory or an approved exception. The clause says what a machine
cannot verify. The amendment needs the owner's recorded approval before phase 2, per the
amendment procedure. It is mirrored into `docs/sdlc/critical-delivery.md`,
`docs/sdlc/definition-of-done.md`, `docs/sdlc/branch-strategy.md` and the spec template.

**D2 — The record key and its reader (R7).** `criticalSurfaces` in `kit-adoption.json`,
read by one function in `scripts/adoption-lib.ps1` returning `Armed`, `Globs`, `Declared`,
`Why` and `Problems`. The enforcement check and the doctor both read from it; neither
interprets the record. The states are absent, empty, malformed and valid, as in data-model.md.

**D3 — The intersection rule (R1).** Literal Territory paths are tested with the existing
matcher. A Territory glob is reduced to its literal directory prefix, and so is each surface;
they intersect when one prefix starts with the other. A pattern with no literal prefix
intersects everything. Paths are compared case-insensitively with `\` normalised to `/`.
Conservative by construction: a false positive costs an exception, a false negative costs the
feature.

**D4 — Reading Territory (R3).** Standard: the union across every `## Phase N` block in
`tasks.md`. Micro: the global block in `spec.md`. Neither found, or a near-miss marker:
UNGRADED, never a pass. The check runs on every push, so a Territory widened by amendment is
re-graded on the next one (spec Edge Cases).

**D5 — Verdicts (R7).** Failure for a reachable surface or a contradictory or absent
rationale; UNGRADED for a malformed list or an unreadable Territory; one informational line
for an absent or empty list, so no project's verdict changes by updating. Critical features
are never failed by the surface check (FR-011).

**D6 — Exceptions (R5).** Two lines in `spec.md`; the approval line is validated by the
function the amendment check uses, parameterised on its pattern, not copied. A live exception
is listed in the run output, a stale one is reported and never fails, an unapproved one does
not count. Self-approval is held by review alone, and the constitution clause says so.

**D7 — The rationale block and its marker (R4, R6).** The spec template gains
`**Rationale Rule**: 1` and the `## Level Rationale` section. The check applies only to specs
carrying the marker, so every shipped feature and every adopted project's existing specs are
exempt without any date or number logic.

**D8 — Fixtures.** Rule ids `LEVEL-001` to `LEVEL-010`, indexed in
`tests/enforcement/rules.json`, one `pass` and one `fail` recipe each under
`tests/enforcement/cases/enforcement-pack/`. Expectations are hand-written (feature 015). The
fixtures include the nested multi-repo layout for SC-001.

**D9 — Skipped on purpose (R9).** `update-agent-context.ps1` is not run: it edits the
always-loaded `CLAUDE.md`, which is law and outside this feature's Territory, and there is no
technology to add.

## Phases

Detailed tasks and the per-phase **Territory** blocks are written by `/speckit.tasks`. The
outline fixes the order and the boundaries.

1. **The law.** Constitution amendment (D1) and its mirrors, the spec-template block and
   marker (D7). Documents only. Needs the owner's approval of the amendment before phase 2.
2. **The record and its reader.** `criticalSurfaces`, the reader (D2), the doctor lines,
   `adoption/updating.md`. Nothing enforces yet.
3. **The surface check.** D3 to D6 in `scripts/enforcement-pack.ps1`, with fixtures
   LEVEL-001 to LEVEL-007 and the harness index. Delivers US1, US3 and US4.
4. **The rationale check.** The block parser and the consistency rules in
   `scripts/enforcement-pack.ps1`, with fixtures LEVEL-008 to LEVEL-010. Delivers US2.
5. **Flow-down.** Update the three adopted projects' verdicts (SC-004), rebuild the digests,
   register any new file in `kit-manifest.json`, the updating note, and the roadmap row and
   decisions-log entry. Bookkeeping only; the kit scripts do not change.

## Project Structure

### Documentation (this feature)

```text
specs/017-level-declaration-graded/
├── spec.md
├── plan.md              # this file
├── research.md          # R1–R10
├── data-model.md
├── quickstart.md
├── contracts/
│   └── level-declaration-contract.md
├── checklists/
│   └── requirements.md
└── tasks.md             # /speckit.tasks, not this command
```

### Source Code (repository root)

```text
.specify/memory/constitution.md          # phase 1: Principle X clause, 0.8.0
.specify/templates/spec-template.md      # phase 1: rationale block and marker
docs/sdlc/critical-delivery.md           # phase 1: mirror
docs/sdlc/definition-of-done.md          # phase 1: mirror
docs/sdlc/branch-strategy.md             # phase 1: level menu mirror
scripts/adoption-lib.ps1                 # phase 2: the reader
scripts/verify-kit.ps1                   # phase 2: doctor lines
adoption/updating.md                     # phases 2 and 5: flow-down note
scripts/enforcement-pack.ps1             # phases 3 and 4: both checks
tests/enforcement/rules.json             # phases 3 and 4: rule index
tests/enforcement/cases/enforcement-pack/   # phases 3 and 4: LEVEL-001 to LEVEL-010 fixtures
docs/roadmap.md                          # phase 5
```

**Structure Decision**: no new script. The checks live in the existing enforcement pack, which
is where feature 014 concluded a check of this kind belongs: a project-side check would be
overwritten by the next `update-kit.ps1` run (GAP-019).

## Testing Strategy

- Each rule: a passing and a failing fixture in a real temporary git repository, expectations
  written by hand, coverage graded by the harness's own coverage test (SC-006).
- The nested multi-repo layout is fixtured for the surface check (SC-001).
- Phase 5 re-runs the updated scripts over the three adopted projects and compares verdicts
  against their current ones (SC-004). A project that changes verdict is a finding, not a
  rounding error.
- `pwsh -File scripts/ritual-checks.ps1` and `pwsh -File tests/enforcement/Run-Tests.ps1` are
  the gate; both are what CI runs.

## Risks

- **Prefix rule over-reporting.** A broad Territory glob will fail against any surface under
  it. This is intended, and the exception path exists for it. If adopters find it noisy, the
  fix is a narrower Territory, not a looser rule.
- **The marker can be deleted** (R4). Stated in the constitution clause rather than hidden.
- **The rationale is a claim, not proof.** A determined owner can write `does not apply`. The
  value is that it is written, visible in the diff and falsifiable in review, the strength of
  Reviewer Provenance and no more.
- **Declared-but-unusable list.** UNGRADED exits 0 by the kit's standing decision (feature 015
  D6), so a malformed list cannot block. The doctor reports it as a finding.

## Complexity Tracking

No Constitution Check violation to justify.
