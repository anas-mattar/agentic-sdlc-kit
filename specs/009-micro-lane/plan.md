# Implementation Plan: Micro Delivery Lane

**Branch**: `009-micro-lane` | **Date**: 2026-09-09 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/009-micro-lane/spec.md`
**Gate Batching**: phases 1-3 <!-- Standard feature, doc+script phases with a seconds-long
  gate and disjoint file sets — 005/006/007/008 precedent. Every phase keeps its own
  commit, machine scope check, and fresh-context AI review. -->
**Gate Certification**: ci-held <!-- research D7: first real use of constitution X's
  CI-held clause (008, ratified via PR #18). The kit's project gate IS ritual-checks; the
  batch-end evidence triplet = push-event ritual-checks run URL + green conclusion +
  batch-end commit sha, owner approval recorded per gate-command.md's worked example. -->

## Summary

Constitution 0.5.0 → 0.6.0 (MINOR): principles I and X gain a **Micro delivery lane** —
a numbered feature MAY declare `**Delivery Level**: Micro` in a single-page mini-spec
(no plan.md/tasks.md), delivered in exactly one phase within hard eligibility bounds
(≤ 5 territory files, ≤ 400 lines, no schema/packages/architecture/domain/visual-reference
surface), with every verification layer unchanged (gate, machine scope check,
fresh-context AI review, human review). CI-held certification eligibility widens to
"Lite, Micro, or Standard" — the mini-spec carries the declaration Lite structurally
cannot (008 review F5). Outgrowing promotes in place to Standard before any further phase.
Phase 1 lands the law + mini-spec template; phase 2 the machine half (scope-check territory
source + enforcement-pack MicroLane check + GateCertification source extension); phase 3
the governance sweep. Absent the declaration, numbered features remain Standard — every
existing feature and fixture is untouched.

## Technical Context

**Language/Version**: PowerShell 7 for the checks; markdown law; one new markdown template
**Primary Dependencies**: none new — git + built-ins (kit convention)
**Storage**: repository files
**Testing**: seeded fixture branches/specs for the US2/US3 scenarios (M-contract);
  regression on 001–008 and Lite-lane verdicts
**Target Platform**: kit repo + adopted projects (flow-down by re-expression + verbatim)
**Project Type**: governance kit — documents + scripts
**Performance Goals**: N/A (law + parse checks)
**Constraints**: constitution amendment procedure in full (SYNC IMPACT, sync-listed
  mirrors in the same commit, human adoption = owner spec/plan approval + gate-6 merge
  review); zero verdict change for anything not declaring Micro
**Scale/Scope**: 1 constitutional amendment (2 principles), 1 new template, ~7 law-doc
  amendments, 2 script amendments, summaries

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Specification First (I)**: spec approved with the claim; plan + tasks complete the
  specify stage before implementation. (This feature amends I itself — under the current
  I, with the full document set.)
- [x] **Source of Truth (II)**: the amendment updates every sync-listed mirror in the same
  phase-1 commit (research D2 enumerates the set); machine half named in SYNC IMPACT as
  next-phase-same-branch (008 precedent).
- [x] **Repository Separation (III)**: N/A — single repository.
- [x] **Architecture Consistency (IV)**: no new patterns — level declaration reuses the
  header-field + comment-stripped-parser idiom (Gate Batching/Certification); the MicroLane
  check joins the enforcement pack's function set; the template joins .specify/templates
  (verbatim by the existing manifest glob — no new row).
- [x] **Domain Invariants (V)**: the amendment procedure is the invariant; this plan binds
  itself to it (Constraints above).
- [x] **Security (VI)**: no secrets, no new surface.
- [x] **External Integration Governance (VII)**: no external integration.
- [x] **Testing Requirements (VIII)**: the checks are business-critical logic — seeded
  M-contract scenarios at the phase gate; regression on all prior features.
- [x] **Controlled Delivery + Certification (X)**: three phases, independently revertible;
  `**Gate Batching**: phases 1-3` and `**Gate Certification**: ci-held` declared above
  before implementation (Standard feature — both lawful; first ci-held use, research D7).
  Batch-end evidence approval certifies gate 3; the agent reports the triplet and requests
  approval, never claiming success.
- [x] **Human Review (IX)**: unchanged — gate-6 review at merge doubles as the amendment's
  human adoption together with the owner's spec/plan approval.

  **Phase sizing rule**: phase 1 = the amendment + mirrors + template (one atomic law
  change per the sync rule); phase 2 = the machine half; phase 3 = summaries. Each reverts
  cleanly (law wholesale; checks key off markers nothing yet uses; sweep is bookkeeping).

## Project Structure

### Documentation (this feature)

```text
specs/009-micro-lane/
├── spec.md              # complete
├── plan.md              # this file
├── research.md          # Phase 0 — decisions D1–D8
├── data-model.md        # declaration grammar, bounds, check behavior
├── quickstart.md        # seeded scenarios per phase (L/M checklists)
├── contracts/
│   └── micro-lane-checks.md   # the machine contract (M1–M12)
├── checklists/requirements.md # complete
└── tasks.md             # /speckit.tasks output
```

### Source Code (repository root)

```text
.specify/memory/constitution.md        # AMEND — phase 1: I + X Micro arms + SYNC IMPACT + 0.6.0
.specify/templates/micro-spec-template.md  # NEW — phase 1 (verbatim via .specify/templates/** glob)
.specify/templates/spec-template.md    # AMEND — phase 1: Delivery Level comment gains Micro
docs/sdlc/definition-of-done.md        # AMEND — phase 1: gate 1 mini-spec arm; gate 4 territory source
docs/sdlc/branch-strategy.md           # AMEND — phase 1: level menu gains Micro
docs/sdlc/critical-delivery.md         # AMEND — phase 1: exclusion restated (no Micro for Critical)
docs/sdlc/gate-command.md              # AMEND — phase 1: CI-held eligibility "Lite, Micro, or Standard";
                                       #   batching stays Lite/Standard (Micro has one phase)
CLAUDE.md                              # AMEND — phase 1: structure note, strict rules, reading table
scripts/scope-check.ps1                # AMEND — phase 2: Micro branches read Territory from spec.md
scripts/enforcement-pack.ps1           # AMEND — phase 2: MicroLane check + GateCertification source
                                       #   extension + constants in $Config
docs/sdlc/flow.md                      # AMEND — phase 3: lane variations gain Micro
docs/sdlc/review-process.md            # AMEND — phase 3: after-each-phase wording where it assumes tasks.md
.github/PULL_REQUEST_TEMPLATE.md       # AMEND — phase 3: spec/plan/tasks link line gains the Micro arm
specs/_templates/human-pr-review-template.md  # AMEND — phase 3: same
adoption/updating.md                   # AMEND — phase 3: flow-down note for the 0.6.0 amendment
docs/roadmap.md                        # phase 3: status flip to in progress
```

**Structure Decision**: the mini-spec stays `spec.md` (Feature Structure law untouched,
research D1); the template is verbatim via the existing `.specify/templates/**` manifest
glob — no manifest change anywhere in this feature.

## Phase Breakdown

| Phase | User story | Delivers | Independently revertible because |
|---|---|---|---|
| 1 | US1 (P1) | The law: constitution I+X Micro arms (0.6.0) + SYNC IMPACT + all sync-listed mirrors + micro-spec-template, ONE commit | Reverting restores 0.5.0 law wholesale; nothing references Micro yet |
| 2 | US2 (P2) + US3 machine half (P3) | scope-check Micro territory source; enforcement-pack MicroLane check (bounds, single-phase, promotion consistency, no-batching) + GateCertification mini-spec source; seeded M-contract validation | Checks key off a declaration nothing yet uses; revert returns to prose-only law |
| 3 | US3 doc half + sweep | Promotion procedure in summaries, flow.md lane, review-process/PR-template arms, updating.md flow-down note, roadmap flip | Pure bookkeeping |

**Phase ordering note**: machine before summaries (006/008 precedent) — the law is policed
before the kit's one-pagers advertise it.

**Gate for every phase**: `pwsh -File scripts/ritual-checks.ps1` + the phase's seeded
scenarios per quickstart.md; agent runs are feedback. **Certification is ci-held**: at
batch end (phase 3's commit), the agent reports the evidence triplet (push-event
ritual-checks run URL + green conclusion + batch-end sha) and the owner records approval
on it — the feature's only certification event.

## Complexity Tracking

No constitutional violations — a constitutional amendment executed under the amendment
procedure. Standing deviation carried from 006/007/008: `update-agent-context.ps1` not run
(kit CLAUDE.md is a shipped product file).
