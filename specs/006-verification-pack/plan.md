# Implementation Plan: Verification Pack

**Branch**: `006-verification-pack` | **Date**: 2026-09-07 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/006-verification-pack/spec.md`
**Gate Batching**: phases 1-3 <!-- Standard feature, doc+script phases with a seconds-long
  gate and disjoint file sets — same justification as 005. Phase 4 gates alone. Every phase
  keeps its own commit, scope check, and AI review. -->

## Summary

Convert the ritual's three socially-checked gates into machine checks: (1) `tasks.md` gains a
per-phase **Territory** declaration and a new `scripts/scope-check.ps1` fails any phase commit
touching undeclared files (GAP-008); (2) the AI review template gains a mandatory **Reviewer
Provenance** block and the enforcement pack fails a branch whose newly-added reviews lack it or
attest the implementer as reviewer (GAP-009); (3) a GitHub Actions workflow runs doc-lint, the
enforcement pack, and the scope check on every push to governed branches, with a single local
wrapper (`scripts/ritual-checks.ps1`) producing identical verdicts (GAP-010). Governance docs
are amended to say gates 4 and 5 are machine-checked; who certifies what does not change.

## Technical Context

**Language/Version**: PowerShell 7 (pwsh) — same as every existing kit script; must run on
  Windows and on `ubuntu-latest` (CI)
**Primary Dependencies**: git CLI only; no modules, no package manager (kit convention)
**Storage**: N/A — all state is files in the repository (tasks.md declarations, review docs,
  kit-manifest.json)
**Testing**: seeded-violation scenarios documented in `quickstart.md` and run at each phase
  gate (the kit has no test framework; this is the 002 enforcement-pack precedent)
**Target Platform**: any git checkout with pwsh; reference CI is GitHub Actions
**Project Type**: governance kit — documents + scripts; no application code
**Performance Goals**: each check completes in seconds on this repository (doc-lint precedent)
**Constraints**: checks must be CI-agnostic scripts (FR-008); backward compatible with specs
  001–005 and with adopted projects' existing artifacts (FR-003, FR-006)
**Scale/Scope**: 2 new scripts, 1 CI workflow, 2 template amendments, 1 enforcement-pack
  extension, 4–5 governance doc amendments, manifest classification

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Specification First (I)**: spec.md approved (this plan), plan.md and tasks.md complete
  before implementation.
- [x] **Source of Truth (II)**: No conflicts. The one designed-for tension — this feature
  machine-checks rules whose prose lives in `docs/sdlc/` — is resolved by amending those docs
  in the same phase that ships each check, so prose and machine never disagree at a commit
  boundary.
- [x] **Repository Separation (III)**: N/A — the kit is a single repository.
- [x] **Architecture Consistency (IV)**: No new patterns: PowerShell scripts beside the
  existing ones, checks modeled on `enforcement-pack.ps1`, CI workflow follows
  `docs/sdlc/branch-protection.md` guidance. No new dependencies.
- [x] **Domain Invariants (V)**: The kit's domain invariants are its constitution and DoD;
  this feature strengthens their enforcement and changes no rule of substance (see research.md
  D6: no constitution amendment required).
- [x] **Security (VI)**: No auth surface, no secrets, no logging of sensitive data. The CI
  workflow needs no repository secrets (read-only checks).
- [x] **External Integration Governance (VII)**: No external integration. GitHub Actions is a
  host, not an integration with a contract surface beyond the workflow file (documented in
  contracts/ritual-checks-ci.md).
- [x] **Testing Requirements (VIII)**: Business-critical logic here is the checks themselves;
  each ships with deterministic seeded-violation scenarios (quickstart.md) exercised at the
  phase gate — pass and fail paths both.
- [x] **Human Review (IX)**: Full-feature human review at merge per DoD gate 6; this feature
  does not touch that gate.
- [x] **Controlled Delivery (X)**: Four phases, each independently revertible (a check can be
  reverted without breaking the others; docs amendments travel with their check). Gate
  Batching phases 1-3 declared above, before any implementation — justified because every
  phase is doc+script with a seconds-long gate and disjoint file sets (005 precedent). Phase 4
  (manifest + governance sweep) gates alone.

  **Phase sizing rule**: each phase is one user story (P1/P2/P3) plus its owning docs; phase 4
  is the cross-cutting bookkeeping that depends on all three. No unrelated concerns bundled.

## Project Structure

### Documentation (this feature)

```text
specs/006-verification-pack/
├── spec.md              # complete
├── plan.md              # this file
├── research.md          # Phase 0 output — decisions D1–D7
├── data-model.md        # Phase 1 output — declaration/verdict/provenance shapes
├── quickstart.md        # Phase 1 output — seeded-violation gate scenarios
├── contracts/
│   ├── scope-check-cli.md      # CLI contract for scripts/scope-check.ps1
│   └── ritual-checks-ci.md     # workflow contract (triggers, jobs, verdicts)
├── checklists/requirements.md  # complete
└── tasks.md             # /speckit.tasks output
```

### Source Code (repository root)

```text
scripts/
├── scope-check.ps1            # NEW — phase 1 (US1)
├── ritual-checks.ps1          # NEW — phase 3 (US3): local wrapper = CI verdicts
├── enforcement-pack.ps1       # AMEND — phase 2 (US2): ReviewProvenance check
└── doc-lint.ps1               # unchanged (invoked by wrapper/CI)

.github/workflows/
└── ritual-checks.yml          # NEW — phase 3 (US3)

.specify/templates/
└── tasks-template.md          # AMEND — phase 1 (US1): Territory declaration per phase

specs/_templates/
└── ai-code-review-template.md # AMEND — phase 2 (US2): Reviewer Provenance block

docs/sdlc/
├── definition-of-done.md      # AMEND — phase 1 (gate 4 wording), phase 2 (gate 5 wording)
├── review-process.md          # AMEND — phase 1 (scope check), phase 2 (reviewer separation)
└── branch-protection.md       # AMEND — phase 3: require the ritual-checks workflow

kit-manifest.json              # AMEND — phases 1–3 as files land (doc-lint enforces)
CLAUDE.md                      # AMEND — phase 4: task-scoped reading row for the checks
docs/sdlc/flow.md              # AMEND — phase 4: summary rows reflect machine-checked gates
adoption/greenfield.md, adoption/existing-system.md
                               # AMEND — phase 3/4: wiring required checks is part of adoption
docs/roadmap.md                # phase 4: status flip
```

**Structure Decision**: single-repo kit layout; every new file sits beside its existing
siblings (scripts with scripts, workflow under `.github/workflows/`, template amendments in
place). No new directories except `.github/workflows/` (first workflow the kit ships).

## Phase Breakdown

| Phase | User story | Delivers | Independently revertible because |
|---|---|---|---|
| 1 | US1 (P1) | Territory syntax in tasks-template; `scope-check.ps1`; DoD gate-4 + review-process amendments; manifest rows | Removing it restores eyeballed scope checks; nothing else references the script yet |
| 2 | US2 (P2) | Provenance block in ai-code-review template; enforcement-pack `ReviewProvenance` check; DoD gate-5 amendment; manifest rows | Check keys off newly-added reviews only; revert restores old template and check set |
| 3 | US3 (P3) | `ritual-checks.ps1` wrapper; `.github/workflows/ritual-checks.yml`; branch-protection + adoption doc amendments; manifest rows | CI layer sits on top of phases 1–2; revert returns to discipline-run checks |
| 4 | — | CLAUDE.md reading row; flow.md sync; roadmap flip; constitution sync-list check (research D6); final manifest sweep | Pure bookkeeping over the shipped phases |

**Gate for every phase**: `pwsh -File scripts/doc-lint.ps1` + `pwsh -File scripts/enforcement-pack.ps1`
+ (from phase 1 onward) the seeded-violation scenarios for the phase's check per `quickstart.md`;
from phase 3 onward the single command is `pwsh -File scripts/ritual-checks.ps1`. Owner-certified
once at the end of the phases 1-3 batch, then at phase 4.

## Complexity Tracking

No constitutional violations to justify. One documented deviation from the stock `/speckit.plan`
flow: `update-agent-context.ps1` is deliberately **not** run — the kit's `CLAUDE.md` is itself a
shipped, slot-bearing product file, and mechanical injection of an "active technologies" section
would pollute what adopters receive (research D7).
