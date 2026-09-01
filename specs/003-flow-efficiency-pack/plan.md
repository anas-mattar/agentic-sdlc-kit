# Implementation Plan: Flow-Efficiency Pack

**Branch**: `003-flow-efficiency-pack` | **Date**: 2026-09-01 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/003-flow-efficiency-pack/spec.md`

## Summary

Make the kit's delivery ritual faster, clearer, and better at parallel work, in four
independently revertible slices: (1) one canonical flow page assembling the whole ritual
into a single diagram + step table; (2) two PowerShell scripts automating the manual
multi-developer rituals (claim-feature, territory-check); (3) an explicit pipelining
clause relaxing the one-active-feature WIP limit for the review-wait state; (4) an opt-in
batched-gate option for Lite/Standard features (max 3 phases per batch), which requires a
constitution X amendment (0.3.0 → 0.4.0) plus an enforcement-pack check that rejects
batching on Critical features.

## Technical Context

**Language/Version**: PowerShell 7 (pwsh) for scripts; Markdown for documents — the kit's
existing conventions (`scripts/*.ps1`, `docs/**/*.md`)
**Primary Dependencies**: git CLI only; existing kit scripts reused
(`.specify/scripts/powershell/create-new-feature.ps1` — verified to accept `-Number`;
`scripts/doc-lint.ps1`; `scripts/enforcement-pack.ps1`)
**Storage**: N/A — git branches (local + remote) are the only ledger
**Testing**: scripted verification scenarios per script (see `quickstart.md`);
`scripts/doc-lint.ps1` and `scripts/enforcement-pack.ps1` green locally and in CI
**Target Platform**: anywhere pwsh 7 + git run (kit standard; Windows-first, cross-platform)
**Project Type**: documentation/governance kit + CLI tooling scripts (single repo)
**Performance Goals**: claim completes in under 1 minute (SC-002); territory check in
seconds for repos with ≤ ~20 open feature branches
**Constraints**: no new dependencies; scripts degrade gracefully with no remote/offline;
every backticked path in amended docs must resolve (doc-lint authoring convention)
**Scale/Scope**: 1 new doc page, 2 new scripts, 6 amended documents, 1 amended template,
1 constitution amendment, 1 new enforcement-pack check

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Specification First (I)**: `spec.md` exists and is approved (checklist green,
  both clarifications resolved by the user); this plan precedes `tasks.md`; no
  implementation has started.
- [x] **Source of Truth (II)**: No conflicts. The flow page is explicitly
  non-authoritative (FR-002) — it summarizes and defers to the owning documents, so it
  adds no new rung to the ladder.
- [x] **Architecture Consistency (IV)**: No new patterns. Scripts follow the existing
  `scripts/*.ps1` conventions (CmdletBinding, `$ErrorActionPreference='Stop'`, non-zero
  exit on violation, config block at top); the claim script delegates number/branch/spec
  creation to the stock `create-new-feature.ps1` rather than reimplementing it.
- [x] **Domain Invariants (V)**: The kit template has no instantiated domain invariants;
  not applicable.
- [x] **Security (VI)**: No auth surfaces, no secrets, no logging of sensitive data. The
  scripts only run git read/branch/push operations in the current repo.
- [x] **External Integration Governance (VII)**: No external integrations. (CI reuses
  the existing enforcement-pack workflow; no new services.)
- [x] **Testing Requirements (VIII)**: The business-critical logic here is the two
  scripts and the new enforcement check. Each gets deterministic verification scenarios
  in `quickstart.md` (same approach 002 used), and the doc changes are covered by
  doc-lint.
- [x] **Human Review (IX)**: One feature-level human review at merge, per DoD gate 6.
  Phase 4 amends the constitution, so that review doubles as the human approval the
  amendment procedure requires — the amendment is not adopted until this feature's
  review approves it.
- [x] **Controlled Delivery (X)**: Four phases, each independently revertible and one
  testable slice (see Phase Breakdown). Note: Phase 4 amends principle X itself via the
  documented amendment procedure (SYNC IMPACT REPORT updated, mirror templates synced,
  human approval at review) — until that phase merges, the current X applies unchanged
  to this feature's own delivery, i.e. this feature does NOT use batched gates for
  itself.

  **Phase sizing rule**: verified per phase below — no phase bundles unrelated concerns;
  reverting any phase leaves the others correct.

## Project Structure

### Documentation (this feature)

```text
specs/003-flow-efficiency-pack/
├── spec.md              # complete
├── plan.md              # this file
├── research.md          # Phase 0 output — all decisions resolved
├── data-model.md        # Phase 1 output — states & declaration formats
├── quickstart.md        # Phase 1 output — verification scenarios
├── contracts/           # Phase 1 output — CLI contracts for both scripts
│   ├── claim-feature-cli.md
│   └── territory-check-cli.md
├── checklists/requirements.md
└── tasks.md             # /speckit.tasks output — NOT created by this command
```

### Source Code (repository root)

```text
docs/sdlc/
├── flow.md                      # NEW — canonical flow page (P1)
├── team-workflow.md             # AMEND — rule 2/5 point to scripts; rule 3 pipelining clause
├── branch-strategy.md           # AMEND — Number Allocation points to claim script
├── gate-command.md              # AMEND — batched-gate section
├── definition-of-done.md        # AMEND — gate 3 batched option
└── critical-delivery.md         # AMEND — explicit no-batching statement

scripts/
├── claim-feature.ps1            # NEW — one-command claim (US2)
├── territory-check.ps1          # NEW — one-command territory check (US3)
├── enforcement-pack.ps1         # AMEND — GateBatching check (Critical rejection + span cap)
└── doc-lint.ps1                 # AMEND — add new files to kit-integrity required paths

.specify/memory/constitution.md          # AMEND — principle X batching clause, 0.3.0 → 0.4.0
.specify/templates/plan-template.md      # AMEND — Gate Batching declaration line + X mirror
CLAUDE.md                                # AMEND — flow page reference + batching/pipelining rows
```

**Structure Decision**: single-repo kit; all changes land in the existing `docs/sdlc/`,
`scripts/`, `.specify/` surfaces. No new directories.

## Phase Breakdown (implementation phases, one commit each)

**Phase 1 — Flow page (US1, zero law change).**
Create `docs/sdlc/flow.md`: ASCII diagram of the full ritual + one-line-per-step table,
each step linking to the owning document; explicit "owning documents prevail" note.
Reference it from CLAUDE.md (Task-Scoped Reading + Workflow intro). Add it to doc-lint's
required-paths list. Revertible: deleting the page restores today's state exactly.

**Phase 2 — Claim + territory scripts (US2, US3).**
`scripts/claim-feature.ps1` (preflight: clean tree + on main; fetch; remote+local ledger
scan; delegate to `create-new-feature.ps1 -Number`; push immediately; detect lost race →
renumber; offline fallback with warning) and `scripts/territory-check.ps1` (fetch; diff
current branch vs `main...origin/NNN-*` per open branch; report overlaps; exit 0 clean /
2 overlap / 1 error; stale-claim flagging). Amend branch-strategy "Number Allocation"
and team-workflow rules 2 and 5 to name the scripts as the standard way to perform the
existing rituals (rituals unchanged — automation only). Revertible: docs revert to the
manual recipes, which remain in place as fallback.

**Phase 3 — Pipelining clause (US4, team-workflow law change).**
Amend team-workflow rule 3 WIP limit: a second feature may be claimed when the first has
all phases committed gate-green, is pushed, and review is formally requested; cap = one
awaiting-review + one active; second feature's territory must be disjoint from (or
explicitly sequenced behind) the first; on change requests, finish the current phase to
gate-green, then return to the first feature before starting any further phase. Update
flow.md's parallel-work note. Revertible: restoring the old rule 3 text restores the
strict WIP limit; no other document depends on the clause.

**Phase 4 — Batched gate (US5, constitution amendment + enforcement).**
Amend constitution X with the batching clause (Lite/Standard only; declared in plan.md
before the batch starts; max 3 consecutive phases; per-phase commit/scope-check/AI-review
retained; user-run gate certifies at batch end; Critical excluded) — version 0.4.0,
SYNC IMPACT REPORT updated. Sync mirrors: plan-template Constitution Check X wording +
new `**Gate Batching**: none | phases N–M` declaration line; DoD gate 3; gate-command
new section; critical-delivery explicit prohibition. Extend enforcement-pack with a
GateBatching check: parse the declaration line; FAIL when a Critical feature declares a
batch or a batch spans more than 3 phases; missing line ⇒ treated as `none` (backward
compatible with 001/002 plans). Update flow.md. Revertible: reverting restores X as-is;
phases 1–3 are unaffected.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| `update-agent-context.ps1` not run in Phase 1 design | In this repo CLAUDE.md is a hand-curated product artifact (the kit's always-loaded law), not a generated context file; the script would inject a tech-stack block into a template that ships to adopters. No new technology was introduced anyway. | Running it and hand-reverting the damage — pointless churn on the kit's most-read file. |
| Phase 4 amends constitution X while X governs this very feature | Batched gates contradict X's current per-phase user-gate wording; the spec (FR-008) requires the relaxation, and the constitution's amendment procedure exists exactly for this. | Putting the batching rule only in docs/sdlc/ — would create a doc-vs-constitution conflict, which the kit's own conflict rule forbids. |
