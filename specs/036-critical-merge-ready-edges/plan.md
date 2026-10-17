# Implementation Plan: Critical merge-readiness open edges

**Branch**: `036-critical-merge-ready-edges` | **Date**: 2026-10-17 | **Spec**: specs/036-critical-merge-ready-edges/spec.md
**Input**: Feature specification (draft; decisions D1 to D3 of the spec taken by the owner, 2026-10-17) + decisions P1 to P8 below
**Gate Batching**: none
**Gate Certification**: user-run
**Status**: Draft (awaiting owner approval; nothing is implemented from it until approved)

## Summary

Three real edges of GAP-022 remain after features 024 to 026. This plan closes the one that is a hole and
makes the other two honest, in two phases. Phase 1 changes `scripts/enforcement-pack.ps1`: a Critical
plan that declares `**Merge Readiness**: pending` while every task in its committed `tasks.md` is ticked is
no longer pending (E1), and the messages of the undeclared path name the declaration as the repair (E3).
Phase 2 is guidance, flow-down, the roadmap correction and a measurement on real history (E2, E4, SC-003).
The kit's own lesson from 024 and 025 governs: fixtures come from field shapes, each pair differs in one
condition, and the measurement is part of the feature.

## Technical Context

**Language/Version**: PowerShell 7+ (`pwsh`)
**Primary Dependencies**: none new
**Storage**: files and git state only
**Testing**: the enforcement harness (`tests/enforcement/`): real temporary git repositories, hand-written
expectations, a passing and a failing fixture per rule. All feature 024 and 025 cases (`CRIT-R01`,
`CRIT-R02`, `CRIT-R03`, the `AMEND-001` merge-readiness cases) pass unchanged except where P4 names a
message suffix.
**Target Platform**: any runner with `pwsh` and `git`
**Project Type**: governance tooling (scripts plus documents)
**Constraints**: `pending` can only become stricter on positive evidence (spec FR-002); the two evidence
arms are not edited; no other member changes; no new emission site if an existing one can carry the text
**Scale/Scope**: one function extended and one hint added in `scripts/enforcement-pack.ps1`, about twelve
fixture cases, three documents, digests

## Constitution Check

- [x] **Specification First (I)**: `spec.md` exists and is a draft; this plan follows it; `tasks.md` follows once both are approved. No code before approval.
- [x] **Source of Truth (II)**: no conflict found; the roadmap's GAP-022 row listing E4 as open conflicts with feature 026's own status and is corrected in phase 2 (spec FR-007), not silently chosen.
- [ ] **Repository Separation (III)**: not applicable, the kit is one repository.
- [x] **Architecture Consistency (IV)**: no new file or pattern; the change sits in `Get-CriticalMergeReadiness`, where 024 and 025 decide readiness.
- [ ] **Domain Invariants (V)**: not applicable, the template's slot is unfilled.
- [x] **Security (VI)**: nothing sensitive is read; the check reads committed blobs.
- [ ] **External Integration Governance (VII)**: not applicable.
- [x] **Testing Requirements (VIII)**: every new behaviour has a failing and a passing fixture, written first and shown failing on the parent commit.
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI review with Reviewer Provenance. The independence artifact stays mandatory before merge.
- [x] **Controlled Delivery (X)**: two phases, one at a time; this changes an enforcement member, so the owner runs the gate: no batching, no ci-held.

**Phase sizing rule**: phase 1 changes no output for a branch that is not Critical, and none for a Critical branch with `pending` and an unticked task; it is useful alone. Phase 2 is documents and a measurement and depends on phase 1. Reverting 2, then 1, leaves a consistent kit.

**Post-design re-check**: no new violation. P2 (what counts as a task) and P4 (a changed message on the 024 path) are decisions of the owner, approved or changed by approving this plan.

## Decisions

**P1: where the new rule sits (FR-001, FR-003).** Inside the `'pending'` arm of `Get-CriticalMergeReadiness`,
after the declaration is read and before it returns `Pending = $true`. The artifact-committed step and the
marker step above it are unchanged, so a committed artifact still ends the pending state first and `ready`,
an invalid marker, an absent marker and a hidden marker take today's paths byte for byte. When the rule
fires it returns `Pending = $false` with a `Why`, so the existing `not treated as mid-feature - <Why>; the
independence artifact is demanded now` line (the `CRIT-R02` emission site) carries the contradiction and
the arm then fails for the missing artifact exactly as for `ready`. No new emission site, so no new
coverage-sweep site.

**P2: what a task is, and what "every task ticked" means (FR-002).** `tasks.md` is read from the committed
blob (`git show "HEAD:./specs/$Branch/tasks.md"`, the `./` rule of 013 phase 5) through
`Get-VisibleFromText` and `Get-FencedLineMap`, as the phase-heading read does, so a checkbox inside a
comment or a fence is example text. A task is a visible, unfenced list line matching
`^\s*[-*+]\s+\[([ xX])\]\s`, at any indent, so a ticked parent with an unticked sub-task is not complete.
The rule fires only when at least one task exists and none is unticked. Unreadable file, no file, zero
tasks, or any unticked task: the `pending` verdict is returned as today. `[X]` and `[x]` both count as
ticked. A project that does not use checkbox tasks reads as zero tasks and is unaffected.

**P3: the message (FR-001).** `Why` reads: `specs/NNN/plan.md declares **Merge Readiness**: pending but
specs/NNN/tasks.md has all <N> of its tasks ticked, so the branch is treated as ready; set it to ready (an
amendment with an approver record) and supply the review, or untick the work that is not done`. The
counts come from P2's read; the line is one line.

**P4: the repair hint for an undeclared plan (FR-005).** The hint is appended where the 024 path already
prints, and only when the plan carries no `**Merge Readiness**` line: the `not treated as mid-feature`
line at its single site and the two phase-token deferral warnings (one per arm). Suffix, identical in
all three: `; the plan can state the answer with **Merge Readiness**: pending or ready (docs/sdlc/critical-delivery.md item 5)`.
`Get-CriticalMergeReadiness` gains `Marked` (true when a marker line, valid or not, was found) on its
returned tables; the three sites test `-not $readiness.Marked`. Verdicts and exit codes are unchanged.
**Owner's decision:** this changes the bytes of the 024 messages, so every 024 and 025 fixture whose
`expected.txt` pins one of them is updated in phase 1, and SC-002 is stated as "every verdict
unchanged". The alternative, a separate additional `WARN` line, adds a site and noise on every run and is
not recommended.

**P5: no exemption for gaining the line, and the E2 proof (FR-004).** No code changes the
amendment-authority check. The kit already has `fail-merge-readiness-added-unapproved` and
`pass-merge-readiness-flip-approved`; phase 1 adds `pass-merge-readiness-added-approved` (a marker added to
an approved plan with the approver record, passing) so the commit shape the guidance names is a fixture
and not a claim. Phase 2 writes the shape into `docs/sdlc/critical-delivery.md`.

**P6: fixtures, field shapes, each pair differing in one condition (FR-006).**

| Rule | Fail fixture | Pass fixture |
|---|---|---|
| `CRIT-R04` new: pending with all tasks ticked | team arm, `pending`, every task ticked, no artifact: the arm's failure with the P3 line | same, one task unticked: today's deferral `WARN`, byte-identical |
| variants of the above | solo arm; sub-task unticked under a ticked parent; `[X]` upper case | a checkbox only inside a fence or a comment (not counted, so zero tasks, `pending` honoured); `tasks.md` with no checkbox; `tasks.md` absent |
| undeclared plan hint (extends `CRIT-R01`, `CRIT-R02`) | an undeclared plan whose heuristic reports a reason: suffix present | an invalid marker (`done`): no suffix, as the marker exists |
| `AMEND-001` variant | marker added, no record (exists) | marker added with record (new) |

Built from field shapes: the all-ticked fixture uses FitForge 002's shape (high-numbered phase landed
early, `tasks: phase N done` subjects, duplicate `## Phase N amendment requests` headings) as 025 did.

**P7: the measurement and its honesty (SC-003).** Phase 2 replays FitForge 002's real `tasks.md` history
in a scratch clone if the clone is available to the owner's machine, and reports at how many of its
commits the P1 rule would change the verdict and what the tick counts were. It says plainly what the
replay shows (the rule on a real file, not that an owner will leave `pending` in place). If the clone is
not available, SC-003 is reported as not measured, with the reason, and not replaced by a synthetic
number. No throwaway commit changes anything but a scratch clone.

**P8: guidance, flow-down, roadmap, digests (FR-004, FR-007, FR-008).** `docs/sdlc/critical-delivery.md`:
a paragraph beside the 025 one (the all-ticked rule, its proxy nature, the E2 commit shape, the hint).
`adoption/updating.md`: a flow-down note stating the cost and what does not change. `docs/roadmap.md`:
the GAP-022 row records what 036 closes, that E4 was closed by 026, and what stays open (a `pending`
with an unticked task, a convention other than checkbox tasks, `pending` as a claim). Digests rebuilt by
`scripts/build-digests.ps1` only. No constitution amendment: T-level check that constitution X fixes
neither the set of plan header fields nor the timing of the artifact, recorded in `notes.md`.

## Phases

Detailed tasks and the per-phase **Territory** blocks go in `tasks.md`.

1. **The rule and its proof.** P1 to P6. Delivers US1, US3 and FR-001 to FR-003, FR-005, FR-006: the
   fixtures first and shown failing on the parent, then the change in `scripts/enforcement-pack.ps1`.
2. **Guidance, flow-down, roadmap, measurement.** P5's text, P7, P8. Delivers US2, FR-004, FR-007, FR-008,
   SC-003, SC-004.

## Risks and limits, stated rather than hidden

- Ticks are a proxy for complete, like 024's phase tokens. An owner can tick tasks early (the rule then
  demands the artifact early, the safe direction) or never tick (the rule never fires; `pending` stays a
  claim, gate 6 behind it). Closed here for the evident case only.
- A project that does not use `- [ ]` tasks is outside the rule.
- The hint changes message bytes for 024's existing fixtures (P4); a consumer that parses those lines
  would notice. The kit's own scripts do not parse them.
- No new approval machinery: the amendment record stays a written claim.

## Project Structure

### Documentation (this feature)

```text
specs/036-critical-merge-ready-edges/
├── spec.md
├── plan.md              # this file
├── tasks.md             # next, via /speckit.tasks
└── notes.md             # baseline, probes, the replay
```

### Source Code (repository root)

```text
scripts/enforcement-pack.ps1                     # Get-CriticalMergeReadiness, three message sites
tests/enforcement/rules.json                     # CRIT-R04 and the changed anchors
tests/enforcement/cases/enforcement-pack/        # new and updated fixtures
docs/sdlc/critical-delivery.md                   # guidance
adoption/updating.md                             # flow-down note
docs/roadmap.md                                  # GAP-022 row
docs/digests/                                    # regenerated by scripts/build-digests.ps1
```

**Structure Decision**: no new file or directory outside the feature's own; the rule lives with the
readiness decision it refines.

## Complexity Tracking

No constitution violations.
