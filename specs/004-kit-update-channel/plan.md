# Implementation Plan: Kit-Update Channel

**Branch**: `004-kit-update-channel` | **Date**: 2026-09-01 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/004-kit-update-channel/spec.md`
**Gate Batching**: none <!-- gates here are doc-lint (seconds); batching would save nothing,
  and this feature builds the updater the adoptions depend on — keep the full ritual. -->

## Summary

Give adopted projects a defined update channel, in three independently revertible
phases: (1) `kit-manifest.json` — a machine-readable classification of every kit-shipped
file as verbatim or surgical, with a completeness check wired into doc-lint so an
unclassified file fails the kit's own CI; (2) `scripts/update-kit.ps1` — one command
that copies changed verbatim files into an adopted project, never touches surgical
files (reporting instead which changed upstream, using the kit's git history between
the project's recorded kit commit and HEAD), refuses to clobber local edits, and writes
a `.kit-version` record; (3) `adoption/updating.md` — the update procedure plus the
constitution amendment flow-down guidance (own version bump, SYNC IMPACT, demotion
verification, citation sweep, human approval), with the 2026-09-01 flow-back as the
worked example.

## Technical Context

**Language/Version**: PowerShell 7 (pwsh) for the script; JSON for the manifest;
Markdown for the guidance — all existing kit conventions
**Primary Dependencies**: git CLI (baseline/report via `git show` / `git log` against
the kit clone); existing kit scripts extended (`scripts/doc-lint.ps1`)
**Storage**: `kit-manifest.json` at kit root (ships to adoptions); `.kit-version` JSON
record at the adopted project root, written by the update
**Testing**: deterministic verification scenarios in `quickstart.md` against a scratch
kit clone + scratch adopted-project (the 002/003 approach); doc-lint + enforcement-pack
green
**Target Platform**: anywhere pwsh 7 + git run (kit standard)
**Project Type**: governance kit + CLI tooling (single repo)
**Performance Goals**: full update run on a real adoption in under 1 minute (SC-001)
**Constraints**: no new dependencies; CRLF/LF differences never count as changes
(FR-008); update never modifies surgical-class or unlisted paths (FR-003/FR-007);
kit-internal material never ships (manifest exclusion)
**Scale/Scope**: 1 manifest, 1 new script, 1 doc-lint extension, 1 new adoption doc,
2 anchor rows (CLAUDE.md), ~40 classified paths/globs

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Specification First (I)**: spec.md approved (checklist green, no open markers);
  this plan precedes tasks.md; no implementation started.
- [x] **Source of Truth (II)**: No conflicts. The manifest classifies files; it does not
  restate any rule. `adoption/updating.md` documents procedure and defers to the
  constitution's amendment section for authority.
- [x] **Architecture Consistency (IV)**: One new convention — a JSON manifest at kit
  root — approved here (D1): JSON parses natively in PowerShell, no dependency; the
  previously rejected YAML manifest (improvement-proposal review) was a *context/reading*
  manifest duplicating the Task-Scoped Reading table — this one is update tooling with
  no doc-reading semantics, a different animal. Scripts follow existing `scripts/*.ps1`
  conventions.
- [x] **Domain Invariants (V)**: N/A (kit template has none instantiated).
- [x] **Security (VI)**: No secrets, no auth surfaces; the script reads two local
  directories and writes only manifest-listed paths inside the target.
- [x] **External Integration Governance (VII)**: No external integrations.
- [x] **Testing Requirements (VIII)**: The update script and the completeness check are
  business-critical (they guard ratified constitutions); both get deterministic
  scenarios in quickstart.md, including the hostile overwrite sequence from SC-002.
- [x] **Human Review (IX)**: One feature-level human review at merge.
- [x] **Controlled Delivery (X)**: 3 phases, each independently revertible (below);
  **Gate Batching: none** declared above — first feature planned under the 0.4.x
  batching law, deliberately not using it (gate is seconds; updater deserves maximal
  ritual). Phase sizing verified per phase below.

## Project Structure

### Documentation (this feature)

```text
specs/004-kit-update-channel/
├── spec.md              # complete
├── plan.md              # this file
├── research.md          # Phase 0 — decisions D1–D7
├── data-model.md        # Phase 1 — manifest schema, version record, report
├── quickstart.md        # Phase 1 — verification scenarios
├── contracts/
│   └── update-kit-cli.md
├── checklists/requirements.md
└── tasks.md             # /speckit.tasks output
```

### Source Code (repository root)

```text
kit-manifest.json                 # NEW — Phase 1 (US1)
scripts/
├── update-kit.ps1                # NEW — Phase 2 (US2)
└── doc-lint.ps1                  # AMEND — Phase 1: manifest completeness check;
                                  #         Phase 2: required-paths additions
adoption/
└── updating.md                   # NEW — Phase 3 (US3)
CLAUDE.md                         # AMEND — Phase 3: Task-Scoped Reading rows
docs/roadmap.md                   # AMEND — at merge: row 004 → shipped
```

**Structure Decision**: single repo; the manifest sits at kit root so the update script
can resolve it relative to the kit clone, and so it ships to adoptions like every other
kit file (self-reporting drift).

## Phase Breakdown (implementation phases, one commit each)

**Phase 1 — Manifest + completeness check (US1).**
Author `kit-manifest.json` (schema per data-model.md; ~40 path/glob entries in two
classes, surgical entries carrying a `reason`). Extend `scripts/doc-lint.ps1` with a
manifest section: every file in the kit's shipped surfaces resolves to exactly one
class; unclassified or double-classified files fail (FR-002). Revertible: delete
manifest + revert doc-lint hunk.

**Phase 2 — Update script (US2).**
`scripts/update-kit.ps1` per `contracts/update-kit-cli.md`: kit-root self-detection,
target preflight (not the kit, kit-integrity present), CRLF-normalized comparison,
verbatim copy, local-modification conflict detection against the git baseline at the
recorded kit commit, surgical upstream-change report via `git log recorded..HEAD`,
`.kit-version` write, idempotence. Add script + manifest to doc-lint required paths.
Verification per quickstart (scratch kit clone + scratch adoption, incl. SC-002 hostile
sequence). Revertible: delete script + revert doc-lint hunk; manifest stands alone.

**Phase 3 — Flow-down guidance + anchors (US3).**
`adoption/updating.md`: run-the-update procedure, resolving the surgical report, the
constitution amendment flow-down steps (FR-009, worked example = the 2026-09-01
flow-back), partial-install refusal note. CLAUDE.md Task-Scoped Reading rows ("Updating
an adopted project from the kit" → adoption/updating.md). Revertible: delete doc +
revert rows.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| — none — | | |
