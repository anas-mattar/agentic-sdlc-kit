# Implementation Plan: Cross-repo Territory Reach

**Branch**: `018-cross-repo-territory-reach` | **Date**: 2026-10-11 | **Spec**: specs/018-cross-repo-territory-reach/spec.md
**Input**: Feature specification + research.md (R1–R10) + decisions D1–D8 below
**Gate Batching**: none
**Gate Certification**: user-run

## Summary

Make the pre-phase territory check see the repositories where the code lives, and never answer
`CLEAN` over a comparison it did not make. Four phases, each independently revertible. First the two
readers the scope check already owns are extracted so the territory check can share them instead of
copying them. Then the verdict vocabulary: `UNGRADED` as a first-class result of the check, applied
to the one comparison it already skips (the governance half of GAP-029) so that the new reach is built
on a check that already tells the truth. Then the reach itself: each declared code repository read as a
sibling working tree, overlap reported with repository-prefixed paths, every cause of a comparison
not made named. Last, the guidance and the flow-down.

## Technical Context

**Language/Version**: PowerShell 7+ (`pwsh`), the kit's only language
**Primary Dependencies**: none new. Reuses `scripts/adoption-lib.ps1`, `scripts/scope-lib.ps1`, git
**Storage**: files and git state only; the check writes nothing
**Testing**: the enforcement harness (`tests/enforcement/`, feature 015): real temporary git
repositories, nested independent repositories (`nestedRepos`) with `origin: self`, hand-written
expectations, a passing and a failing fixture per rule
**Target Platform**: any runner with `pwsh` and `git`; paths must read the same on Windows and Linux
**Project Type**: governance tooling (scripts plus documents)
**Performance Goals**: not applicable; a few git calls per (code repository x open claim) (research R9)
**Constraints**: a project declaring no `codeRepos` sees no change; no new hard failure; exit codes
unchanged; `scripts/scope-check-repos.ps1` must behave identically after the extraction
**Scale/Scope**: one script changed, two libraries gain one function each, one script refactored, one
document updated, about 25 new fixtures

## Constitution Check

*GATE: passed before Phase 0; re-checked after Phase 1 design (below).*

- [x] **Specification First (I)**: `spec.md` exists; this plan follows it; `tasks.md` follows via
  `/speckit.tasks`. No implementation starts before all three are approved.
- [x] **Source of Truth (II)**: one conflict is recorded rather than resolved silently: spec FR-013
  says an unusable `codeRepos` leaves output unchanged, which the spec's own constraint forbids
  (research R6). It is surfaced as an owner decision below.
- [ ] **Repository Separation (III)**: not applicable, the kit is a single repository.
- [x] **Architecture Consistency (IV)**: no new pattern. The shared functions follow where the kit
  already keeps such things; no new file, no new package.
- [ ] **Domain Invariants (V)**: not applicable, the kit template's slot is unfilled.
- [x] **Security (VI)**: no secrets, nothing logged that is sensitive. The check reads git state of
  directories the adoption record names, and the reader already refuses a path or a traversal as an
  entry (012), so it cannot be pointed outside the governance root.
- [ ] **External Integration Governance (VII)**: not applicable.
- [x] **Testing Requirements (VIII)**: every rule has a passing and a failing harness fixture,
  hand-written (spec FR-015).
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI review
  with Reviewer Provenance.
- [x] **Controlled Delivery (X)**: four phases, one at a time. This changes an enforcement script, so
  the owner runs the gate: no batching, no ci-held. The spec carries its Level Rationale
  (constitution X, Level declaration).

**Phase sizing rule**: each phase is one testable slice that does not depend on a later one. Phase 1
changes no behaviour. Phase 2 changes the verdict vocabulary for the governance comparison alone and
is useful without code repositories. Phase 3 adds the reach on top of it. Phase 4 is documents. The one
ordering constraint is that phase 3 must not be reverted without phase 4 (the guidance would describe
a check that no longer reads code repositories); reverting phases 4 then 3 leaves a consistent kit.

**Post-design re-check**: no new violation. One item needs the owner (D5, research R6).

## Decisions

**D1 — Share, do not copy (R1).** `Get-CodeRepos` moves to `scripts/adoption-lib.ps1`;
`Get-RepoMergeBase` moves to `scripts/scope-lib.ps1`. `scripts/scope-check-repos.ps1` calls both and
prints the same text. Phase 1 changes no output, and
the `REPOS-*` rules are the proof.

**D2 — The verdict is one word for the run (R5).** `OVERLAP`, else `UNGRADED`, else `CLEAN`. The
ungraded lines are printed beside an overlap, never instead of it. Exit codes are unchanged, and
ungraded exits 0.

**D3 — The governance skip becomes ungraded (spec Assumptions, phase 2).** The comparison
`territory-check.ps1` already skips with a warning (a claim with no remote-tracking ref) adds an
ungraded entry, so a skipped comparison no longer ends the run on `CLEAN`. `TERR-012`'s expectation
changes from `CLEAN` to the ungraded verdict, and that change is recorded as the departure it is. The
four terminating-write refusal paths of GAP-029 are not touched.

**D4 — Reading a code repository (R2, R3, R7).** Present and a repository of its own (the check 012
uses), then `git fetch origin --prune` (a failure makes the repository ungraded), then the trunk by the
shared candidate order, then for the branch under check and each open claim the ref
`origin/<branch>` falling back to a local head, diffed against its merge base with the trunk. A branch
in neither place is "no work there". Tracked uncommitted changes count only if the repository's current
branch is the branch under check. New reads use `core.quotepath=off` so non-ASCII paths arrive
verbatim; the existing governance read is left exactly as it is.

**D5 — A malformed `codeRepos` is ungraded, and this needs the owner (R6).** Absent or empty is
unchanged. Present and unusable is ungraded by name, with the scope check's warning wording. This
tightens spec FR-013 and US3 scenario 2 by one case; either the owner approves an amendment to those
sentences, or the plan is changed to implement them as written and record the gap. The plan recommends
the former.

**D6 — Liveness across repositories (R4).** A feature's status uses its latest commit in any
repository it has a branch in; "claimed, no work yet" means no commits in any of them.

**D7 — Output and JSON (contract).** The new lines and the JSON field are in
`contracts/territory-check-output.md`. A project with no `codeRepos` keeps its existing `CLEAN` text
byte for byte; a fully compared run in a project with code repositories names what it compared.

**D8 — Fixtures.** Rule ids `TERR-013` onward, in `tests/enforcement/rules.json`, one `pass` and one
`fail` recipe each, built from nested independent repositories (research R8). Expectations are
hand-written. The `emission-idioms.json` entry for this script gains the new line shapes as accumulator
patterns, so the coverage test sees them.

## Phases

Detailed tasks and the per-phase **Territory** blocks are written by `/speckit.tasks`. The outline fixes
the order and the boundaries.

1. **Shared readers.** Extract `Get-CodeRepos` and `Get-RepoMergeBase`; `scope-check-repos.ps1` uses
   them. No behaviour change; guarded by the existing `REPOS-*`, `SCOPE-*` and `TERR-*` cases.
2. **The ungraded verdict.** D2, D3, the JSON field, the `TERR-012` expectation change, the emission
   registration. Delivers the spec's US2 for the governance repository and is useful on its own.
3. **The reach.** D4 to D7: code repositories read, overlap reported with prefixes, every cause named,
   liveness across repositories. Delivers US1, US2 for code repositories and US3.
4. **Guidance and flow-down.** `docs/sdlc/team-workflow.md` section 5, the `adoption/updating.md` note,
   digests, the roadmap row and decisions-log entry, and a measurement over clones of the three adopted
   projects.

## Project Structure

### Documentation (this feature)

```text
specs/018-cross-repo-territory-reach/
├── spec.md
├── plan.md              # this file
├── research.md          # R1-R10
├── data-model.md
├── quickstart.md
├── contracts/
│   └── territory-check-output.md
├── checklists/
│   └── requirements.md
└── tasks.md             # /speckit.tasks, not this command
```

### Source Code (repository root)

```text
scripts/adoption-lib.ps1                 # phase 1: Get-CodeRepos
scripts/scope-lib.ps1                    # phase 1: Get-RepoMergeBase
scripts/scope-check-repos.ps1            # phase 1: calls the shared readers, prints the same text
scripts/territory-check.ps1              # phases 2 and 3
tests/enforcement/rules.json             # phases 2 and 3: TERR-013 onward, TERR-012 changed
tests/enforcement/emission-idioms.json   # phases 2 and 3: new line shapes
tests/enforcement/cases/territory-check/ # phases 2 and 3: fixtures
docs/sdlc/team-workflow.md               # phase 4: section 5
adoption/updating.md                     # phase 4: flow-down note
docs/roadmap.md                          # phase 4
```

**Structure Decision**: no new script and no new library file. The two shared functions live in the two
libraries that already ship verbatim to every adopter, so no new file enters the flow-down and
`kit-manifest.json` needs no entry.

## Testing Strategy

- Each rule: a passing and a failing fixture in real temporary git repositories, built from nested
  independent repositories, expectations written by hand, coverage graded by the harness's own coverage
  test (SC-006).
- Phase 1 proves "no behaviour change" by the existing suites: every `REPOS-*`, `SCOPE-*` and `TERR-*`
  case unchanged.
- Phase 3 includes a no-overlap case in the layout where the governance repositories look disjoint and
  the code repositories do not (SC-001), and one fixture per cause in the data model's table (SC-002).
- Phase 4 runs the old and new script over clones of the three adopted projects (SC-004), and reports a
  verdict that moved as a finding, not a rounding error.
- `pwsh -File scripts/ritual-checks.ps1` and `pwsh -File tests/enforcement/Run-Tests.ps1` are the gate,
  and are what CI runs. The full harness is run on an isolated checkout of the final commit, not in the
  working directory a developer is using.

## Risks

- **A shared function changes the scope check.** The extraction touches a shipped, reviewed script. The
  mitigation is that phase 1 changes nothing observable and is graded by 32 existing rules before
  anything is built on it.
- **Ungraded may surprise owners.** A project whose code repository has no `origin` will now see a
  note and, if a fetch cannot be made, an ungraded verdict where it saw `CLEAN`. That is the point of
  the feature, and the guidance explains each cause (spec US4).
- **Pushed work only.** The check reads what is on the remotes (and local heads). Another developer's
  unpushed commits are invisible; the output says what was compared, so the limit is visible.

## Needs the owner

1. **D5 / research R6**: spec FR-013 and US3 scenario 2 versus the spec's own constraint, for a present
   but unusable `codeRepos`. Approve an amendment to those two sentences (the plan's recommendation), or
   direct the plan to implement them as written.
2. **The spec's status**: it still reads Draft; approval is the owner's act.

## Complexity Tracking

No Constitution Check violation to justify.
