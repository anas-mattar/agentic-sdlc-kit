# Implementation Plan: CI-Held Certifying Gate

**Branch**: `008-ci-held-gate` | **Date**: 2026-09-08 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/008-ci-held-gate/spec.md`
**Gate Batching**: phases 1-3 <!-- Standard feature, doc+script phases with a seconds-long
  gate and disjoint file sets — 005/006/007 precedent. Phase 4 gates alone. Every phase
  keeps its own commit, machine scope check, and fresh-context AI review. -->
**Gate Certification**: user-run <!-- research D7: this feature does not certify itself
  under the mode it introduces; declared explicitly once the field existed (phase 2). -->

## Summary

The kit's first constitutional amendment since 0.4.1: constitution X (0.4.1 → 0.5.0,
MINOR) gains a **CI-held certification** clause — for Lite/Standard features whose approved
plan declares `**Gate Certification**: ci-held`, DoD gate 3 MAY be satisfied by the owner
approving on the evidence triplet (CI run URL + green conclusion + exact phase-commit sha)
instead of running the gate locally; Critical is untouched and machine-excluded. Phase 1
lands the law (constitution + SYNC IMPACT + every sync-listed mirror in one commit);
phase 2 the enforcement-pack `GateCertification` check; phase 3 the project-gate workflow
template for adopted projects; phase 4 the summary sweep. Defaults preserve every existing
plan: absent declaration = `user-run`.

## Technical Context

**Language/Version**: PowerShell 7 for the enforcement check; markdown law; one YAML
  workflow template (inert `.template` file in the kit)
**Primary Dependencies**: none new — git + built-ins (kit convention)
**Storage**: repository files; the approval-on-evidence record reuses the existing phase
  record channel (no new artifact — spec assumption)
**Testing**: seeded plan-declaration scenarios for the enforcement check; a worked
  evidence-record example in gate-command.md (FR-008); fixture instantiation of the
  workflow template
**Target Platform**: kit repo + adopted projects; GitHub Actions as reference CI host,
  law host-agnostic
**Project Type**: governance kit — documents + scripts
**Performance Goals**: N/A (law + a parse check)
**Constraints**: constitution amendment procedure applies in full (SYNC IMPACT entry,
  sync-listed mirrors updated in the same change, human approval — the owner's explicit
  phase-1 approval plus gate-6 merge review constitute it); zero behavior change for
  undeclared plans and for Critical
**Scale/Scope**: 1 constitution amendment, 4–5 law-doc amendments, 1 template field,
  1 enforcement check, 1 workflow template + manifest row, summaries

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Specification First (I)**: spec approved with the claim; plan + tasks complete the
  specify stage before implementation.
- [x] **Source of Truth (II)**: the amendment updates every sync-listed mirror in the same
  phase-1 commit, so prose and mirrors never diverge at a commit boundary; research D2
  enumerates the mirror set.
- [x] **Repository Separation (III)**: N/A — single repository.
- [x] **Architecture Consistency (IV)**: no new patterns — the declaration reuses Gate
  Batching's exact header shape and parser idiom; the check joins the enforcement pack's
  existing function set; the template joins the kit's slot-bearing-template class.
- [x] **Domain Invariants (V)**: this feature AMENDS the kit's own constitutional law via
  the documented amendment procedure — the procedure is the invariant, and the plan binds
  itself to it (Constraints above; research D2).
- [x] **Security (VI)**: no secrets; the workflow template documents that gate chains with
  secrets belong in CI secret stores, never in the recorded evidence or the workflow file.
- [x] **External Integration Governance (VII)**: no external integration (CI host is a
  runner of the project's own command, contract-documented in the template's header).
- [x] **Testing Requirements (VIII)**: the enforcement check is business-critical logic —
  seeded declaration scenarios (valid/malformed/Critical/absent) at the phase gate;
  the law's edge cases carry a worked example.
- [x] **Human Review (IX)**: unchanged — and this feature's own amendment adoption is
  explicitly human: owner approves phase 1, gate-6 review at merge.
- [x] **Controlled Delivery (X)**: four phases, independently revertible; Gate Batching
  phases 1-3 declared above before implementation; phase 4 alone. This feature is
  delivered under the CURRENT law (user-run/batched gates) — it does not certify itself
  under the mode it introduces.

  **Phase sizing rule**: phase 1 = the amendment + its mirrors (one atomic law change —
  splitting it would put the constitution and its mirrors in different commits, violating
  the sync rule); phase 2 = the machine check; phase 3 = the delivery vehicle for
  adopters; phase 4 = summaries. Each reverts cleanly.

## Project Structure

### Documentation (this feature)

```text
specs/008-ci-held-gate/
├── spec.md              # complete
├── plan.md              # this file
├── research.md          # Phase 0 — decisions D1–D7
├── data-model.md        # Phase 1 — declaration grammar, evidence triplet, check behavior
├── quickstart.md        # Phase 1 — seeded scenarios per phase
├── contracts/
│   └── gate-certification.md   # the declaration + evidence + check contract
├── checklists/requirements.md  # complete
└── tasks.md             # /speckit.tasks output
```

### Source Code (repository root)

```text
.specify/memory/constitution.md      # AMEND — phase 1: X clause + SYNC IMPACT + 0.5.0
.specify/templates/plan-template.md  # AMEND — phase 1: Gate Certification field + X check row
docs/sdlc/definition-of-done.md      # AMEND — phase 1: gate 3 CI-held option
docs/sdlc/gate-command.md            # AMEND — phase 1: CI-held section (evidence triplet,
                                     #   worked record example, kit's-own-gate note);
                                     #   phase 3: template wiring instructions
docs/sdlc/critical-delivery.md       # AMEND — phase 1: explicit CI-held exclusion mirror
CLAUDE.md                            # AMEND — phase 1: strict-rule wording (never claim
                                     #   success; under ci-held, report evidence + request approval)
scripts/enforcement-pack.ps1         # AMEND — phase 2: GateCertification check
.github/workflows/project-gate.yml.template
                                     # NEW — phase 3: slot-bearing, inert in kit CI;
                                     #   kit-manifest.json gains a specific surgical row
docs/sdlc/branch-protection.md       # AMEND — phase 3: recommend requiring the project-gate
                                     #   check where wired
kit-manifest.json                    # AMEND — phase 3: surgical row for the template
docs/sdlc/flow.md                    # AMEND — phase 4: 3b row carries the ci-held option
adoption/updating.md                 # AMEND — phase 4: flow-down note for the X amendment
docs/roadmap.md                      # phase 4: status flip
```

**Structure Decision**: the workflow template carries a `.template` suffix so it is inert
in the kit's own CI (the kit's gate is `ritual-checks`); adopters copy it to
`project-gate.yml` and fill the gate slots. It is slot-bearing ⇒ **surgical** — the
manifest needs a row more specific than the `.github/**` verbatim glob (most-specific-wins
resolution, research D4).

## Phase Breakdown

| Phase | User story | Delivers | Independently revertible because |
|---|---|---|---|
| 1 | US1 (P1) | The law: constitution X clause (0.5.0) + SYNC IMPACT + all sync-listed mirrors (plan-template, DoD gate 3, gate-command CI-held section, critical-delivery exclusion, CLAUDE.md strict rule) in ONE commit | Reverting restores 0.4.1 law wholesale; nothing else references the clause yet |
| 2 | US3 (P3) | enforcement-pack `GateCertification` check + seeded validation | Check keys off a declaration nothing yet uses; revert returns to prose-only law |
| 3 | US2 (P2) | `project-gate.yml.template` + manifest surgical row + gate-command wiring + branch-protection recommendation | Template is inert in the kit; revert deletes an unused file |
| 4 | — | flow.md summary, updating.md flow-down note, roadmap flip, final sweep | Pure bookkeeping |

**Phase ordering note**: US3 (machine check) lands before US2 (delivery vehicle) — the law
must be policed before the kit encourages adopters to rely on it; spec priorities order by
value, the plan orders by safety (same call as 006).

**Gate for every phase**: `pwsh -File scripts/ritual-checks.ps1` + the phase's seeded
scenarios per quickstart.md; owner certifies once at the end of the phases 1-3 batch, then
at phase 4 — under the CURRENT user-run law.

## Complexity Tracking

No constitutional violations — this feature IS a constitutional amendment, executed under
the amendment procedure (rationale, SYNC IMPACT, mirror updates, human approval). Standing
deviation carried from 006/007: `update-agent-context.ps1` not run (kit CLAUDE.md is a
shipped product file).
