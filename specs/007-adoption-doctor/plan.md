# Implementation Plan: Adoption Doctor

**Branch**: `007-adoption-doctor` | **Date**: 2026-09-08 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/007-adoption-doctor/spec.md`
**Gate Batching**: phases 1-3 <!-- Standard feature, doc+script phases with a seconds-long
  gate and disjoint file sets — 005/006 precedent. Phase 4 gates alone. Every phase keeps
  its own commit, machine scope check, and fresh-context AI review. -->

## Summary

Ship `scripts/verify-kit.ps1`: a read-only, one-command audit of an adopted project's kit
integrity across five dimensions (structure essentials, slot completeness in project-owned
files, constitution ratification, gate proof + declared-tier rulebooks from a new
`kit-adoption.json` record, `.kit-version` sanity), every failure reported in one run with
a fix pointer (US1). `init-kit.ps1` writes the adoption record and finishes with the
doctor; `update-kit.ps1` ends its apply report with the target's verdict (US2). The
ritual-checks wrapper gains the doctor as a fourth member, applicable only when
`.kit-version` marks an adopted project (US3). Grandfather posture: pre-007 adoptions get
warnings-with-instructions for the new artifacts, never new hard failures.

## Technical Context

**Language/Version**: PowerShell 7 (pwsh) — kit script conventions; runs on Windows and
  `ubuntu-latest`
**Primary Dependencies**: git CLI + PowerShell built-ins only (kit convention; JSON via
  `ConvertFrom-Json`)
**Storage**: repository files — new project-owned `kit-adoption.json` (record + gate
  proof), existing `.kit-version`, `kit-manifest.json`
**Testing**: seeded healthy/broken fixture scenarios in `quickstart.md`, exercised at
  phase gates (002/006 precedent; FR-010)
**Target Platform**: any git checkout with pwsh; CI via the existing `ritual-checks`
  workflow — no new workflow (006 supersession lesson)
**Project Type**: governance kit — documents + scripts; no application code
**Performance Goals**: doctor completes in seconds on a real adoption (doc-lint precedent)
**Constraints**: doctor is read-only (FR-008); never audits the kit repo (FR-002);
  pre-007 adoptions degrade to warnings (FR-004/SC-005); update-kit exit-code semantics
  unchanged (FR-006)
**Scale/Scope**: 1 new script, 3 amended scripts (init-kit, update-kit, ritual-checks),
  3 adoption docs + CLAUDE.md amendments, 1 new record format, manifest verification

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Specification First (I)**: spec.md approved with the claim; this plan and tasks.md
  complete the specify stage before implementation.
- [x] **Source of Truth (II)**: no conflicts; the doctor/doc-lint boundary is pinned in
  research D2 so the two checkers never claim the same job; adoption docs amended in the
  same phase as the behavior they describe.
- [x] **Repository Separation (III)**: N/A — single repository.
- [x] **Architecture Consistency (IV)**: no new patterns or dependencies — one more
  PowerShell script beside its siblings, JSON records beside `kit-manifest.json` /
  `.specify/init-options.json` precedents, CI via the existing wrapper.
- [x] **Domain Invariants (V)**: the kit's invariants are its constitution and DoD;
  nothing here changes a rule — it audits compliance with existing law.
- [x] **Security (VI)**: read-only audit; no secrets, no network; gate-proof record holds
  a command line and exit code, nothing sensitive by construction (documented caveat in
  the record's shape: never paste secrets into the proof command).
- [x] **External Integration Governance (VII)**: no external integration.
- [x] **Testing Requirements (VIII)**: the doctor is business-critical logic; seeded
  healthy/broken fixtures per dimension, fail paths first (FR-010, quickstart.md).
- [x] **Human Review (IX)**: full-feature human review at merge (gate 6), unchanged.
- [x] **Controlled Delivery (X)**: four phases, each independently revertible; Gate
  Batching phases 1-3 declared above before implementation (doc+script phases,
  seconds-long gate, disjoint file sets); phase 4 gates alone. Territory declared per
  phase in tasks.md (006 law).

  **Phase sizing rule**: one user story per phase plus its owning docs; phase 4 is
  cross-cutting bookkeeping. Each reverts cleanly: the doctor script alone (P1), the
  lifecycle hooks (P2), the wrapper membership (P3).

## Project Structure

### Documentation (this feature)

```text
specs/007-adoption-doctor/
├── spec.md              # complete
├── plan.md              # this file
├── research.md          # Phase 0 — decisions D1–D8
├── data-model.md        # Phase 1 — kit-adoption.json shape, verdict model
├── quickstart.md        # Phase 1 — fixture scenarios per dimension
├── contracts/
│   └── verify-kit-cli.md    # CLI contract for scripts/verify-kit.ps1
├── checklists/requirements.md  # complete
└── tasks.md             # /speckit.tasks output
```

### Source Code (repository root)

```text
scripts/
├── verify-kit.ps1             # NEW — phase 1 (US1): the doctor
├── init-kit.ps1               # AMEND — phase 2 (US2): write kit-adoption.json; finish with doctor
├── update-kit.ps1             # AMEND — phase 2 (US2): apply report ends with target's verdict
└── ritual-checks.ps1          # AMEND — phase 3 (US3): doctor as 4th member, gated on .kit-version

adoption/
├── greenfield.md              # AMEND — phase 2: record the gate proof (step 3); doctor at init end (step 0/1)
├── existing-system.md         # AMEND — phase 2: same touchpoints
└── updating.md                # AMEND — phase 2: update report ends with doctor verdict; post-update expectations

CLAUDE.md                      # AMEND — phase 4: task-scoped reading row (adopted-project verification)
docs/roadmap.md                # phase 4: status flip
kit-manifest.json              # verify per phase (scripts/*.ps1 verbatim glob expected to cover; kit-adoption.json is NOT kit-shipped — created per project, no manifest row)
```

**Structure Decision**: single-repo kit layout, all new/amended files beside their
siblings; no new directories. `kit-adoption.json` exists only in adopted projects (written
by init there), so the kit's manifest never classifies it — research D1.

## Phase Breakdown

| Phase | User story | Delivers | Independently revertible because |
|---|---|---|---|
| 1 | US1 (P1) | `scripts/verify-kit.ps1` (five dimensions, decline logic, grandfather warnings, fix pointers); fixture validation | Nothing else references the script yet; revert restores social-only checking |
| 2 | US2 (P2) | init-kit writes `kit-adoption.json` + finishes with doctor; update-kit apply report ends with target verdict; adoption docs name both moments + gate-proof recording | Hooks call the P1 script; reverting restores doc-lint-only finish and current docs |
| 3 | US3 (P3) | ritual-checks membership (applicable iff `.kit-version`); contract updates | Wrapper change is additive; revert returns to 3-member wrapper |
| 4 | — | CLAUDE.md reading row; roadmap flip; final manifest verification | Pure bookkeeping |

**Gate for every phase**: `pwsh -File scripts/ritual-checks.ps1` (doc-lint +
enforcement-pack + scope-check) plus the phase's seeded fixture scenarios per
`quickstart.md`; owner certifies once at the end of the phases 1-3 batch, then at phase 4.

## Complexity Tracking

No constitutional violations. Standing deviation carried forward from 006 (research D7
there): `update-agent-context.ps1` is not run — the kit's `CLAUDE.md` is itself a shipped
product file; mechanical context injection would pollute what adopters receive.
