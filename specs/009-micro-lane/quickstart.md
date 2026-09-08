# Quickstart: Micro Delivery Lane — validation script

Per-phase seeded scenarios. Executed at each phase's gate (agent feedback runs) and
recorded under "Phase validation records" in tasks.md.

## Phase 1 — the law (checklist L)

Read-verify, quotes recorded in the validation table:

- **L1** Constitution I carries the Micro arm: an approved single-page mini-spec satisfies
  specification-first with no plan.md/tasks.md, for a feature declared Micro.
- **L2** Constitution X carries: exactly one phase; every verification layer unchanged;
  the eligibility bounds with both constants; Critical MUST NOT use Micro; absent
  declaration ⇒ Standard; promotion procedure named.
- **L3** X's CI-held clause (and gate-command.md's section) reads "Lite, Micro, or
  Standard"; Batched gates stays Lite/Standard and Micro is stated as never batching.
- **L4** SYNC IMPACT: 0.5.0 → 0.6.0 MINOR, rationale, full mirror list, machine half named
  as next-phase-same-branch, human-adoption note; footer bumped.
- **L5** `micro-spec-template.md` exists with all data-model sections; spec-template's
  Delivery Level comment gains Micro; doc-lint classifies it (verbatim glob — file count
  goes 64 → 65).
- **L6** DoD gate 1 carries the mini-spec arm; gate 4 names spec.md as the Micro territory
  source; branch-strategy level menu reads Lite < Micro < Standard < Critical;
  critical-delivery restates the exclusion.
- **L7** CLAUDE.md: structure note (Micro = spec.md only), strict rule, reading-table row.
- **L8** ritual-checks after the full amendment: RESULT OK.

## Phase 2 — the machine (contract M1–M13)

Seeded fixture feature (`specs/998-micro-demo` shape, deleted after) + fixture branches as
needed; run `scope-check.ps1` / `enforcement-pack.ps1 -Branch <fixture>` per scenario;
record verdict quotes in the validation table. Regression: this branch, 003, 007, 008
(absent Delivery Level lines ⇒ unchanged verdicts), plus a Lite fixture branch name.

## Phase 3 — the sweep (checklist W)

- **W1** flow.md lane variations carry Micro (one bullet, summary-only); review-process
  after-each-phase steps read correctly for a Micro feature (territory in spec.md).
- **W2** PR template + human-review template link lines carry the Micro arm (mini-spec
  only, no plan/tasks links).
- **W3** updating.md flow-down note for 0.6.0 (re-expression, adopter's own MINOR bump,
  nothing changes until ratified); roadmap GAP-013 flipped to in progress.
- **W4** Final grep sweep: no shipped instrument still states "spec.md, then plan.md, then
  tasks.md" without the Micro arm where it binds numbered features; ritual-checks RESULT
  OK.

## Batch-end certification (ci-held — plan declaration)

After phase 3's commit: push; cite the **push-event** `ritual-checks` run on the batch-end
commit (URL + green conclusion + sha) and request the owner's recorded approval on it
(gate-command.md worked example). The agent never claims success.
