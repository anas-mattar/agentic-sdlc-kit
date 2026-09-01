# Implementation Plan: Enforcement Pack

**Branch**: `002-enforcement-pack` | **Date**: 2026-09-01 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `specs/002-enforcement-pack/spec.md`

## Summary

Convert five previously-prose non-negotiables into a mechanically-enforced CI check: spec-
artifact presence + declared Delivery Level, Lite-lane prohibition list + abuse guard,
Critical-evidence presence (`second-model-review.md` + 24h cooling-off), and a non-blocking
phase-commit diff-size warning — plus the CI wiring (GitHub Actions workflow, PR template,
branch-protection recipe) that makes the checks actually block a bad merge instead of being
advisory. Delivered as three independently revertible phases: (1) structural checks
(spec-artifact presence, Lite-lane prohibition/abuse guard) with the CI workflow skeleton;
(2) Critical-evidence check + phase-size warning; (3) PR template + branch-protection recipe
that wires the pack into the actual merge gate on GitHub.

## Technical Context

**Language/Version**: PowerShell 7+ (pwsh), matching `scripts/doc-lint.ps1`'s existing style
and invocation convention.
**Primary Dependencies**: `git` CLI (merge-base, diff, log — already a hard dependency of
every script in `.specify/scripts/powershell/`); GitHub Actions (workflow YAML) as the CI
runner, since `origin` is `https://github.com/anas-mattar/agentic-sdlc-kit.git`. No new
package dependency.
**Storage**: N/A.
**Testing**: Fixture branches (throwaway branches in known-failing / known-passing states,
per spec.md's "Fixture branch" entity) exercised against the script and, once Phase 3 lands,
against the live GitHub workflow — this is the kit's existing verification pattern (used by
`001-delivery-core-amendment`'s `quickstart.md`), extended here because there is now a script
with branch/logic to exercise, not just prose to grep.
**Target Platform**: GitHub Actions runner (`ubuntu-latest`, `pwsh` is cross-platform and
preinstalled) for CI; same script also runs locally on the Windows/PowerShell dev machine
this repository is developed on, matching `doc-lint.ps1`.
**Project Type**: CLI script + CI workflow (governance/process tooling, not an application).
**Performance Goals**: N/A — governance script operating on one branch's diff per invocation;
sub-second expected at this repository's current scale.
**Constraints**: Must run with no secrets and no external network calls (Edge Cases: fork-PR
safety — only the checked-out diff and file tree are available); the underlying script
(FR-001) MUST remain CI-agnostic — GitHub Actions is only the wiring layer (FR-008), not a
dependency baked into the check logic itself.
**Scale/Scope**: One new script (`scripts/enforcement-pack.ps1`), one new GitHub Actions
workflow file, one PR template, one branch-protection recipe doc, plus fixture branches
created and deleted during verification (not part of the merged tree).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Evaluated against the current constitution (0.3.0, 10 principles, post-`001-delivery-core-
amendment`).

- [x] **Specification First (I)**: spec.md exists and is validated (checklist all-pass); this
      plan.md and the forthcoming tasks.md complete the sequence before implementation.
- [x] **Source of Truth (II)**: No conflict between spec.md and this plan; no visual
      references apply (no `screenshots/`).
- [x] **Repository Separation (III)**: N/A — single-repo kit, principle marked optional for
      single-repo projects.
- [x] **Architecture Consistency (IV)**: PASS — no new framework or persistence approach.
      The new script follows the existing pattern set by `scripts/doc-lint.ps1` (a standalone
      PowerShell script, no package manager, no build step) rather than introducing a new
      tooling paradigm.
- [x] **Domain Invariants (V)**: N/A — `{{DOMAIN_INVARIANTS_PATH}}` is unfilled at kit level;
      this feature touches no domain module.
- [x] **Security (VI)**: PASS — no auth surface, no secrets. FR-011/Edge Cases explicitly
      require the checks to run without secrets so fork-based PRs are not blocked or granted
      unintended access; the GitHub Actions workflow (Phase 3) uses only the default,
      read-only `GITHUB_TOKEN` scope needed to post a check result.
- [x] **External Integration Governance (VII)**: N/A — GitHub Actions is CI wiring, not an
      external integration the feature *depends on* to function (the script itself stays
      CI-agnostic per FR-001/FR-007); no contract document is warranted for "run this script
      on a schedule/trigger."
- [x] **Testing Requirements (VIII)**: PASS by the kit's own equivalent, same adaptation used
      by `001-delivery-core-amendment`: this is process-critical, not business-domain-critical,
      logic, so the kit has no existing automated-test harness for it. Verification is the
      fixture-branch mechanism spec.md defines (SC-001–SC-005) — a known-failing and a
      known-passing branch exercised per check, which is this feature's regression coverage.
- [x] **Human Review Requirement (IX)**: PASS — human review happens once at merge (per the
      unit-of-review fix `001-delivery-core-amendment` made); this plan's phases are gated by
      the user-run doc-lint/script/fixture checks, not a claim of automated approval.
- [x] **Controlled Delivery (X)**: PASS — three phases below, each independently revertible.
      Phase sizing rule: Phase 1 (script + two structural checks + workflow skeleton) is the
      largest slice since the workflow skeleton has to exist for any check to be exercised in
      CI at all; Phases 2 and 3 each add one self-contained capability (two more checks; then
      the merge-gate wiring) without touching Phase 1's files' logic, only appending to them.

No violations requiring Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/002-enforcement-pack/
├── spec.md                      # already written
├── plan.md                      # this file
├── research.md                  # Phase 0 output
├── data-model.md                # Phase 1 output — documents check/config entities
├── quickstart.md                # Phase 1 output — fixture-branch verification steps
└── tasks.md                     # Phase 2 output (/speckit.tasks — not this command)
```

No `contracts/` in the API sense — the "contract" this feature exposes is the script's CLI
surface and exit-code semantics, documented in `research.md` and exercised directly by
`quickstart.md`'s fixture-branch steps rather than a separate interface-contract file.

### Files changed/added (repository root, by phase)

```text
Phase 1 — Structural checks + workflow skeleton
├── scripts/enforcement-pack.ps1          # new — spec-artifact presence + Delivery Level
│                                            check (FR-002); Lite-lane prohibition list +
│                                            abuse guard (FR-003, FR-004); config block
│                                            (FR-007) for thresholds/patterns
└── .github/workflows/enforcement-pack.yml  # new — runs the script on push/PR to main
                                              (FR-008), fails the run on non-zero exit

Phase 2 — Critical-evidence check + phase-size warning
└── scripts/enforcement-pack.ps1          # extended — Critical-evidence check (FR-005),
                                             non-blocking phase-commit diff-size warning
                                             (FR-006)

Phase 3 — Merge-gate wiring
├── .github/PULL_REQUEST_TEMPLATE.md      # new — embeds specs/_templates/human-pr-review-
│                                            template.md's checklist + gate exit-code field
│                                            (FR-009)
└── docs/sdlc/branch-protection.md        # new — recipe for requiring the workflow as a
                                             required status check on `main` (FR-010)
```

**Structure Decision**: No `src/`/`tests/` split applies — this is a governance-tooling
feature, one script plus its CI wiring. The three phases above are the "source structure"
for this feature; each is one git commit on `002-enforcement-pack`, independently
revertible, matching `001-delivery-core-amendment`'s precedent.

## Complexity Tracking

*No entries — Constitution Check has no unjustified violations.*
