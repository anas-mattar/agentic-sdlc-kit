# Implementation Plan: A merge-ready signal for a Critical feature that a commit subject cannot give

**Branch**: `025-critical-merge-ready-signal` | **Date**: 2026-10-13 | **Spec**: specs/025-critical-merge-ready-signal/spec.md
**Input**: Feature specification (approved, anas.m, 2026-10-13; option A) + decisions D1–D9 below
**Gate Batching**: none
**Gate Certification**: user-run
**Status**: Approved (anas.m, 2026-10-13) — decisions D1–D9 approved as written
**Amendment approved by**: anas.m, 2026-10-13

## Summary

A Critical feature's `plan.md` may declare `**Merge Readiness**: pending` or `ready`. `scripts/enforcement-pack.ps1` reads the line from
the committed plan and lets it override feature 024's commit-subject heuristic: `pending` is the not-yet-due warning, `ready` is the arm's
own grading, absent is feature 024 byte for byte. The declaration needs no new approval machinery: a change to an approved plan is
an amendment that, in a commit with a single parent, must name an approver, which is what makes flipping to `ready` a recorded human act; a change made inside a merge commit is graded since feature 026, when the merge authored it (D5, Risks). Two phases, each
independently revertible. First the check and its proof, fixtures first, including a fixture shaped like the real FitForge 002. Then
the guidance, the plan template, the flow-down note, the roadmap and a measurement that replays FitForge 002's real history.

The lesson feature 024 paid for governs this plan: **fixtures are built from field shapes, not the kit's conventions**, and the
measurement on real history is part of the feature, not an afterthought (D8).

## Technical Context

**Language/Version**: PowerShell 7+ (`pwsh`)
**Primary Dependencies**: none new
**Storage**: files and git state only
**Testing**: the enforcement harness (`tests/enforcement/`): real temporary git repositories, hand-written expectations, a passing and a
failing fixture per rule. All 34 feature 024 cases (`CRIT-R01`, `CRIT-R02`) and the `CRIT-S*`/`CRIT-T*` cases must pass unchanged (SC-001).
**Target Platform**: any runner with `pwsh` and `git`
**Project Type**: governance tooling (scripts plus documents)
**Constraints**: an absent marker leaves output byte-identical (FR-004); the two evidence arms are not edited; no other member changes
**Scale/Scope**: one function extended and two emission sites added in `scripts/enforcement-pack.ps1`, about fourteen fixture cases, one
template line, three documents, digests

## Constitution Check

- [x] **Specification First (I)**: `spec.md` is approved; this plan follows it; `tasks.md` follows once the plan is approved.
- [ ] **Repository Separation (III)**: not applicable, the kit is one repository.
- [x] **Architecture Consistency (IV)**: no new file; the marker is read where feature 024's readiness is decided (D1).
- [ ] **Domain Invariants (V)**: not applicable, the template's slot is unfilled.
- [x] **Security (VI)**: nothing sensitive is read; the check reads a committed `plan.md`.
- [ ] **External Integration Governance (VII)**: not applicable.
- [x] **Testing Requirements (VIII)**: every rule has a passing and a failing fixture, hand-written, failing first on the parent commit.
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI review with Reviewer Provenance. The
  independence artifact stays mandatory before merge; this feature changes only how the check learns that it is owed.
- [x] **Controlled Delivery (X)**: two phases, one at a time; this changes an enforcement member, so the owner runs the gate: no batching,
  no ci-held. T006 reads constitution X for any sentence that fixes the set of plan header fields or the timing of the artifact (D6);
  expected: none, so no amendment.

**Phase sizing rule**: phase 1 changes no output for a branch that declares nothing and is useful alone. Phase 2 is documents and a
measurement and depends on phase 1. Reverting 2, then 1, leaves a consistent kit.

**Post-design re-check**: no new violation. D2 (what `pending` bypasses), D9 (the template default) and D7 (the meaning of `ready`) are the
owner's decisions and are approved or changed by approving this plan.

## Decisions

**D1 — The marker is read inside `Get-CriticalMergeReadiness`, second only to "artifact committed" (FR-001, FR-004).** Feature 024's
function already returns `@{ Pending; Why; Final; Tip }`. The new step sits after the existing first step (an artifact committed at
`HEAD` ends the pending state) and before the history-dependent steps (diff base, shallow clone, `tasks.md`, subjects), so an explicit
declaration does not depend on history. The plan is read from the committed blob (`git show "HEAD:./specs/$Branch/plan.md"`, the `./`
rule of 013 phase 5) through `Get-VisibleFromText`, the visibility reader the amendment check trusts, so a line inside a comment, a fence
or a code span declares nothing. The grammar is the one the other plan header fields use, `^\*\*Merge Readiness\*\*:\s*(.*?)\s*$`, so a line with no value is a malformed marker and not an absent one (D8: an empty value is strict, with a reason); value
compared exactly (`pending` or `ready`, lower case). The spec said "through the visibility reader the pack already uses for plan headers";
that reader, `Get-VisiblePlanLines`, takes a working-tree path, and 024 deliberately reads the committed blob, so this reads the blob
through `Get-VisibleFromText`. The function's signature is unchanged and `Invoke-CriticalEvidenceCheck` is not edited except to print the
new warning text for a declared `pending`.

Amended after the phase 1 AI review (F4): the D1 grammar is `(.*?)` in place of `(\S.*?)`, so an empty value is strict, as D8 lists it.

**Amendment approved by**: anas.m, 2026-10-14

**D2 — What each value does, and what `pending` bypasses (FR-002, FR-003, FR-004).**

| Marker | `Get-CriticalMergeReadiness` returns |
|---|---|
| absent, or the plan unreadable or not committed | falls through to feature 024's steps, unchanged |
| `ready` | `Pending = $false`, no reason: the arm grades exactly as for a merge-ready branch |
| `pending` | `Pending = $true` with `Declared = $true`: the not-yet-due warning, whatever the subjects, headings or history say, **including a shallow clone and no diff base** |
| any other value, or two `**Merge Readiness**` lines | `Pending = $false` with a reason (the existing `not treated as mid-feature` line): strict |

`pending` therefore bypasses feature 024's strict states, on purpose, because an explicit declaration needs no history. The artifact
committed at `HEAD` still ends the pending state first (D1), so a committed artifact is always graded by its arm. **Owner's decision:**
whether `pending` should instead leave the history-dependent strict states in force (safer in a depth-1 CI checkout, where it would then
print the strict reason and not warn). Recommended as written: a declaration the owner made should not be
silently ignored by a shallow clone.

**D3 — The warning and its two emission sites (FR-002).** For a declared `pending` the check prints
`WARNING: CriticalEvidence: <artifact> is not yet due - specs/<NNN>/plan.md declares **Merge Readiness**: pending (the owner's
declaration in the plan, a claim and not a verified approval; gate 6 stands behind it) and <the review> is owed once it is set to ready (<team mode ($why) | solo mode>;
docs/sdlc/critical-delivery.md item 5; a WARN, not a pass)`, one line per run, one emission site per arm like feature 024's. The text says "a claim" deliberately, because the amendment check does not grade merge commits (D5). The
sweep owns one rule per emission site, so these are `CRIT-R03` with `siteCount: 2` and the anchor `declares **Merge Readiness**: pending`.
The strict reason for a malformed marker reuses feature 024's `not treated as mid-feature` site (`CRIT-R02`, new variants).

**D4 — Non-Critical features ignore the marker with no code (FR-005).** `Invoke-CriticalEvidenceCheck` returns for any level but Critical
before it reads anything, so the marker on a Standard, Lite or Micro feature is never read. A fixture proves it (a Standard feature carrying
`pending` prints nothing new), rather than trusting the early return.

**D5 — The amendment-authority check already grades the flip; the fixtures prove it (FR-006).** Read, not assumed:
`Invoke-AmendmentAuthorityCheck` grades every commit that changes an existing `spec.md`, `plan.md`, `tasks.md` or `contracts/*` file after
its creation (`scripts/enforcement-pack.ps1`, around line 1670), exempting only a first appearance, a pure rename, tasks ticks, and a
change to the `**Status**` line alone. A `**Merge Readiness**` line is none of those, so adding the marker to an existing plan, and
flipping it, are amendments that need a conforming approver record and the approver named in the commit message. Adding it in the commit
that **creates** `plan.md` is a first appearance and is exempt, correctly: that is before approval. Fixtures, as variants of the existing
`AMEND-*` rules and in their shape (T001 reads `AMEND-001` and `AMEND-002` for the recipe): an unapproved `pending` to `ready` change
fails, an approved one passes, and an unapproved addition of the marker to an existing plan fails. **If a fixture shows the check does
not reach the line, extending it is in scope** (FR-006), and the plan is amended before the code is.

**Limit, accepted by the owner (phase 1 review F1, route 2):** the check skips every commit with more than one parent (feature 014, D7), so a `pending` added inside a merge commit carries no approver check, and gate 6 is the only thing behind that case. This feature does not extend the check to merges: that changes a decision feature 014 made on purpose and belongs to a feature of its own. No fixture pins the limit (the fixture library cannot build a merge with content of its own), so it is stated here and in the script header instead. This amendment also changes the Summary, D2, D3 and Risks to say so.

**Amendment approved by**: anas.m, 2026-10-14

**Retired by feature 026 (2026-10-14):** the limit above no longer holds. The amendment check grades a merge commit for the spec documents it authored: a document equal to a parent's, to git's own automatic merge of the two parents, or absent in every parent is not authored and the merge is skipped as before; one that is authored needs the `**Amendment approved by**` record, new against every parent, and the approver named in the merge message, so a `pending` or `ready` change inside a merge is graded like any amendment. What remains, as feature 026 states it: a merge that keeps one parent's version whole is trusted on that parent's content, even when its only grading was a creation exemption; an octopus merge, a git older than 2.38 or a failing `git merge-tree` is graded the strict way; the record is a written claim. This amendment also changes the Summary and Risks to say so; the text above is left as the history of the decision.

**Amendment approved by**: anas.m, 2026-10-14

**D6 — No constitution amendment, and the template is a kit file (FR-008).** `.specify/templates/**` is classed `verbatim` in
`kit-manifest.json`, so the plan template flows down by `update-kit.ps1`. The field is optional and its absence is the default; the
constitution names `**Gate Batching**` and `**Gate Certification**` and their legal values as constants but fixes neither the set of plan
header fields nor the timing of the independence artifact (feature 024's T006 read it for the second). T006 re-reads constitution X for
the first and records the answer in `notes.md`.

**D7 — The flip is the owner's act, and `ready` means "owed now", not "approved" (spec Edge Cases).** `ready` makes the arm grade the
artifact: absent, it fails exactly as today. The approver on the flip is a recorded human, but the check does not verify who they are
(the Reviewer Provenance limit: a written, falsifiable claim, not proof). Stated in the guidance, not left implicit.

**D8 — Fixtures from field shapes, and a measurement that replays real history (FR-007, FR-009, SC-002).**
Fixtures (phase 1), each pair differing in one condition: `CRIT-R03` pass = `pending` on a branch shaped like FitForge 002 (a
high-numbered phase landed early, `tasks: phase N done` subjects, duplicate `## Phase N amendment requests` headings): warns, exit 0;
fail = the same branch with `ready`: today's failure. Variants: the solo arm; `pending` with a committed invalid artifact (the arm fails
it); `pending` in a depth-1 clone (still warns, D2); `pending` with a high-numbered phase token in the subjects (the override that
feature 024 could not do, the point of the feature); a marker inside a comment or a fence (hidden, so feature 024's heuristic decides);
a Standard feature carrying `pending` (ignored, D4). `CRIT-R02` variants: two marker lines, an unknown value (`done`), an empty value.
`AMEND-*` variants per D5. The measurement (phase 2) replays FitForge 002's real 43 commits in a scratch clone, each with a throwaway commit
that injects `**Merge Readiness**: pending` (and, at the last, `ready`), and reports the `CriticalEvidence` line at each, beside feature
024's result at the same commits (17 warn of 43). **It says plainly what an injection shows:** the mechanism on real shapes, not that an
owner will use it, and the throwaway commits' own AmendmentAuthority failures are expected and not counted.

**D9 — Guidance, template, flow-down, roadmap (FR-008).** `docs/sdlc/critical-delivery.md` (a paragraph under item 5 beside feature
024's), `.specify/templates/plan-template.md` (the optional line with its comment, absent by default), `adoption/updating.md` (a flow-down
note in the shape of 024's, stating the cost: `pending` is a claim an owner can leave in place, and gate 6 stands behind it),
`docs/roadmap.md` (GAP-022: what is now closed and what stays open), digests rebuilt. **Owner's decision (item 2 of "Needs the owner" below):** the
template ships the line **commented out / absent**, so no new feature changes behaviour silently; the alternative, a default of `pending`,
would make every new Critical plan declare it at creation, exempt from an approver, and rely on someone remembering to flip it.

## Phases

Detailed tasks and the per-phase **Territory** blocks are in `tasks.md`.

1. **The marker and its proof.** D1–D5, D8's fixtures. Delivers US1 and US2 and FR-001 to FR-007: the declaration read, overriding feature
   024, the amendment grading shown by fixtures, fixtures first and shown failing on the parent.
2. **Guidance, template, flow-down, measurement.** D6, D8's measurement, D9. The documents, the template line, the roadmap, digests and
   the replay of FitForge 002 (US3, FR-008, FR-009, SC-001 to SC-003).

## Project Structure

### Documentation (this feature)

```text
specs/025-critical-merge-ready-signal/
├── spec.md
├── plan.md              # this file
├── tasks.md
└── notes.md             # phase evidence, the baseline, the replay
```

### Source Code (repository root)

```text
scripts/enforcement-pack.ps1              # phase 1: the marker in Get-CriticalMergeReadiness, two emission sites
tests/enforcement/rules.json              # phase 1: CRIT-R03
tests/enforcement/cases/enforcement-pack/ # phase 1: CRIT-R03 and the CRIT-R02 / AMEND-* variants
docs/sdlc/critical-delivery.md            # phase 2
.specify/templates/plan-template.md       # phase 2: the optional line
adoption/updating.md                      # phase 2: flow-down note
docs/roadmap.md                           # phase 2
docs/digests/**                           # phase 2
```

**Structure Decision**: no new script and no new library file; `scripts/enforcement-pack.ps1` already ships verbatim, so
`kit-manifest.json` needs no entry. The two evidence arms and the amendment check are not edited unless D5's fixtures show the latter does
not reach a plan header line.

## Testing Strategy

- Each rule is first written as a failing fixture and shown failing on the parent commit, then the behaviour lands. For the `WARN` cases
  the parent's failure is the strict failure or the heuristic's reading.
- All 34 feature 024 cases and the `CRIT-S*`/`CRIT-T*` cases pass unchanged after the edit; `-Case CRIT-`, `-Case AMEND-` and `-Case RIT-`
  per phase; the full harness on an isolated checkout of the final commit (feature 022's method).
- **Field-shaped fixtures are required, not optional** (D8): at least one fixture per rule is shaped from FitForge 002 (its headings,
  its subjects, its out-of-order phase), because feature 024's fixtures all passed while the feature did nothing on that branch.
- Phase 2's replay of the real history, recorded in `notes.md`.

## Risks

- **The amendment record covers a merge commit only for what the merge authored (feature 026 retired the limit of D5).** A `pending` added inside a merge is graded like any amendment. What remains: a merge that takes one parent's version whole is trusted on that parent's content, an octopus merge or a git older than 2.38 is graded the strict way, and the record is a written claim an owner can leave in place; gate 6 stands behind it. The guidance and the flow-down notes say so.

- **`pending` is a claim an owner can leave in place.** The honest cost of the whole feature, and feature 024's hole in a new place. It
  is visible (a warning on every run, the declaration and its approver in the diff gate 6 reads) and not closed: after `pending` the
  machine does not demand the artifact, and the human review at merge does. The guidance and the flow-down note say so; the decision
  to accept it is the owner's (spec, option A).
- **`ready` is "owed now", not "approved", and the approver is a name.** The amendment record is a written claim a reviewer can falsify,
  no more; stated, not hidden.
- **An existing approved plan needs an amendment to gain the marker.** Adoption friction by design (an approver is recorded), and the
  reason FitForge 002 would add it with an approver rather than silently.
- **The replay injects the marker, so it is a simulation.** It shows the mechanism on real shapes; D8 requires it to say so.
- **Reading the plan from the committed blob** means an uncommitted marker is not read, which is the right direction (evidence that
  exists only in a working tree is not evidence), and the same rule as 013's.
- **A marker added in the commit that creates `plan.md` needs no approver** (a first appearance). Correct, since it precedes approval.

## Needs the owner

1. **D2, what `pending` bypasses.** Recommended: it bypasses feature 024's history-dependent strict states, so an explicit declaration
   works in a shallow clone. Alternative: it leaves them in force.
2. **D9, the template default.** Recommended: the line ships absent (commented), so nothing changes silently. Alternative: a default
   of `pending`.
3. **D7, the meaning of `ready`.** Accepted as "owed now"; say if you would rather it also require the artifact to be committed in the
   same commit (a stricter flip).
4. **The plan's approval.** `tasks.md` follows once it is given.

## Complexity Tracking

No constitution violation to justify.
