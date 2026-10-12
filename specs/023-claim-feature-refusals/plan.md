# Implementation Plan: claim-feature.ps1's refusals reach their own message and exit

**Branch**: `023-claim-feature-refusals` | **Date**: 2026-10-12 | **Spec**: specs/023-claim-feature-refusals/spec.md
**Input**: Feature specification (approved, anas.m, 2026-10-12) + decisions D1–D7 below
**Gate Batching**: none
**Gate Certification**: user-run
**Amendment approved by**: anas.m, 2026-10-12

## Summary

`scripts/claim-feature.ps1` reports seven refusals with `Write-Error` under `$ErrorActionPreference = 'Stop'`, so the
`exit 1` after each is unreachable: the same defect feature 022 closed in `scripts/territory-check.ps1`. Two phases,
each independently revertible. First the script and its proof, fixtures first: `Stop-Refused` at the seven sites, a
fail and a pass fixture for each of the six that a fixture can reach, the script brought into the coverage sweep. Then
the guidance, the flow-down note, the roadmap and a measurement over clones of the three adopted projects. No new
script, no new library file, no new recipe field, no verdict word (the script has none).

## Technical Context

**Language/Version**: PowerShell 7+ (`pwsh`)
**Primary Dependencies**: none new
**Storage**: files and git state only
**Testing**: the enforcement harness (`tests/enforcement/`): real temporary git repositories, hand-written expectations,
a passing and a failing fixture per rule. Recipe fields that already exist reach every fixtured site: `noGit`,
`uncommitted`, `origin`, `checkout`, `copy`, run with the case's `noRoot` (the script has no `-Root`).
**Target Platform**: any runner with `pwsh` and `git`
**Project Type**: governance tooling (scripts plus documents)
**Constraints**: a successful claim prints the same bytes and exits 0 (SC-001); the seven refusals keep their wording and
exit 1; the lane is Standard (spec, "Why this is Standard and not Micro")
**Scale/Scope**: one script changed, one coverage list and one idiom entry extended, about eight rules' fixtures, three
documents, digests

## Constitution Check

- [x] **Specification First (I)**: `spec.md` is approved; this plan follows it; `tasks.md` follows.
- [ ] **Repository Separation (III)**: not applicable, the kit is one repository.
- [x] **Architecture Consistency (IV)**: no new file; `claim-feature.ps1` keeps its structure and stays standalone (D1).
- [ ] **Domain Invariants (V)**: not applicable, the template's slot is unfilled.
- [x] **Security (VI)**: the script already pushes and may delete its own branch; the change touches only how it refuses.
  The messages name paths and branches only.
- [ ] **External Integration Governance (VII)**: not applicable.
- [x] **Testing Requirements (VIII)**: every reachable refusal has a passing and a failing fixture, hand-written; the one
  that is not reachable is exempt with a written reason (D2), subject to the owner.
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI review with Reviewer
  Provenance. Constitution IX is unchanged.
- [x] **Controlled Delivery (X)**: two phases, one at a time. This changes an enforcement-adjacent script, so the owner
  runs the gate: no batching, no ci-held. No amendment of X is needed.

**Phase sizing rule**: phase 1 changes no output of a successful claim and is useful alone. Phase 2 is documents and
measurement and depends on phase 1. Reverting 2, then 1, leaves a consistent kit.

**Post-design re-check**: no new violation. Two decisions are the owner's (D1, D2), and are approved or changed by
approving this plan.

## Decisions

**D1 — `Stop-Refused` is copied into `claim-feature.ps1`, not shared (FR-001).** The function is six lines
(`[Console]::Error.WriteLine($Message)` then `exit 1`) and already exists in `territory-check.ps1`. Sharing it would need
a library dot-sourced by both, which means editing `territory-check.ps1` (shipped by 022, outside this feature's
Territory) and a new flowing file. It would also make the claim depend on a file whose absence is exactly what the
script's own site 108 is about: `claim-feature.ps1` runs before any feature exists, including in a kit that may be half
installed, and a missing library would break the command that reports exactly that. The cost is six duplicated lines, both copies fixtured. Alternative:
a shared helper in `scope-lib.ps1`; say if you want it, and the plan grows a phase that touches `territory-check.ps1`.

**D2 — Site 135 (lost the allocation race three times) is exempt with a written reason, not fixtured (FR-004).** The
refusal fires only when, after each of three pushes, a rival claim with the same number is on `origin`. The script
allocates the next number free across the remote ledger, so a rival present *before* allocation is never the same number;
the rival has to appear between allocation and the check, on every attempt. The recipe cannot build that, and a git hook
on the fixture's origin would be a new recipe field (hooks are shell scripts, behaving differently on Windows and Linux
runners) that asserts the hook, not the rule. The exemption has the shape of `AMEND-007` and `REPOS-033`: reachable only by a
state the fixture model cannot produce honestly, written down rather than faked. Effect: the exempt-rule count goes from
three to four (SC-003 allows at most one). Site 135 still gets `Stop-Refused` and its message is covered by reading,
the review and the same function every other site calls, which the six fixtures exercise. Alternative: build the hook
field; say if you want it, and phase 1 gains a harness task.

**D3 — The refusals keep to the error stream and `-Json` is unchanged (FR-001, FR-006).** As in 022: the message goes to
the error stream, so a human at a terminal sees the same stream as before. With `-Json` a refusal is still a message and
exit 1 with no JSON object (spec US1 scenario 7); no error object is added.

**D4 — Fixtures, rule ids and the coverage sweep (FR-003, FR-005).** Rule ids `CLF-001` to `CLF-006` for sites 72, 79, 84,
96, 108, 112 and `CLF-007` for site 135 (exempt). `CLAIM-` is taken by `roadmap-claim-check.ps1`. Cases live under
`tests/enforcement/cases/claim-feature/`. Each pair differs only in the condition: `noGit` (72), `uncommitted` (79), the
checked-out branch (84), where `origin` points (96), the presence of the stub `create-new-feature.ps1` (108), whether that
stub exits non-zero (112). Stubs are plain files under the case directory placed by the recipe's `copy` field; the
success stub creates the branch and spec directory and prints the JSON the script reads. Expectations are written by hand
(the harness concatenates stdout then stderr, so a refusal's message comes after every `Allocating ...` and `WARNING`
line that preceded it). The script is added to the coverage test's list of grading scripts and gets an entry in
`emission-idioms.json` with `Stop-Refused\s+['"]` and `Write-Warning\s` as accumulators; its three warnings (no origin,
`-NoPush`, and the per-attempt race warning) are declared not-a-rule with written reasons, the first two because the
success-path `pass` cases assert them verbatim, the third because it sits in CLF-007's unreachable path, so the exempt-rule
count rises only by CLF-007. The recall sweep is run first and anything else it reports is classified the same way.

**D5 — A baseline measures the parent before anything changes (spec, Background).** The spec says the terminal exit is
already 1 for these refusals; it is measured on territory-check, not here. Phase 1's first task records, on the parent
commit, each refusal's message and exit under `pwsh -File` and through the harness, and a successful claim's exact
output (no origin, an origin that takes the push, `-NoPush`) as saved text for the byte comparison.

**D6 — Adopter guidance and measurement (FR-007).** `adoption/updating.md` gains a flow-down note in the shape of 022's.
`scripts/claim-feature.ps1` flows verbatim, so nothing is surgical. The measurement clones FitForge, FlowBoard and
ExpenseTracker from their local directories (never the real projects, nothing pushed), applies the kit before this
feature, then the kit as it stands, and runs a claim with `-NoPush` in each state on a fresh clone, plus `doc-lint.ps1`
and `ritual-checks.ps1`; every line that moves is listed with its cause. A claim creates a branch and a spec directory in
the clone only; the clone's `origin` is the project on disk and `-NoPush` makes no push.

**D7 — `docs/roadmap.md` closes GAP-031 and marks the row `shipped`, with a decisions-log entry dated the day the feature
ships.** The same entry records what the owner decided on D1 and D2.

## Phases

Detailed tasks and the per-phase **Territory** blocks are in `tasks.md`.

1. **The refusals and their proof.** D1–D5. Delivers US1 and US2 and FR-001 to FR-006: `Stop-Refused` at seven sites,
   fixtures first and shown failing on the parent, the script in the coverage sweep, the exempt rule for site 135.
2. **Guidance, flow-down, measurement.** D6, D7. `adoption/updating.md`, `docs/roadmap.md`, digests and the measurement
   over three clones (US3, FR-007, SC-001).

## Project Structure

### Documentation (this feature)

```text
specs/023-claim-feature-refusals/
├── spec.md
├── plan.md              # this file
├── tasks.md
└── notes.md             # phase evidence, the measurement
```

### Source Code (repository root)

```text
scripts/claim-feature.ps1                 # phase 1: Stop-Refused at the seven sites
tests/enforcement/rules.json              # phase 1: CLF-001..CLF-007
tests/enforcement/emission-idioms.json    # phase 1: the script's idiom entry
tests/enforcement/Coverage.Tests.ps1      # phase 1: the list of grading scripts
tests/enforcement/cases/claim-feature/    # phase 1: fixtures and stubs
adoption/updating.md                      # phase 2: flow-down note
docs/roadmap.md                           # phase 2
docs/digests/**                           # phase 2
```

**Structure Decision**: no new script and no new library file; `scripts/claim-feature.ps1` already ships verbatim, so
`kit-manifest.json` needs no entry. `scripts/territory-check.ps1` is deliberately absent from the list (D1).

## Testing Strategy

- Each rule is first written as a failing fixture and shown failing on the parent commit, then the behaviour lands.
  The harness runs the script with the case's working directory set to the fixture (`noRoot`).
- Phase 1 fixtures: a `fail` and a `pass` for each of `CLF-001` to `CLF-006`, differing only in the condition; the `fail`
  expects the message and exit 1 (not the launcher's 97 or 128). Success-path `pass` cases pin the output a successful
  claim prints today: no origin (with its warning), an origin that takes the push, and `-NoPush` (with its warning), each
  exit 0; these also own the warning sites.
- The full harness runs on an isolated checkout of the final commit (feature 022's method); `-Case CLF-`, `-Case TERR-` and
  `-Case RIT-` per phase. Every pre-existing case is unchanged.
- The measurement of D6, recorded in `notes.md`.

## Risks

- **The `pass` fixture for site 96 pushes to `origin: self`.** Pushing a new branch to a non-bare repository's own
  checked-out repository is allowed, but it has not been run through the harness. If it misbehaves on a runner, the pass
  case uses a different `origin` and the pair's difference is reworded; it must still differ from the fail case in one
  condition.
- **The stub is test code the harness runs.** It lives under the case directory and does only what the real script
  would be asked to: create a branch and a spec directory. A stub that drifts from the real script's output contract
  (`BRANCH_NAME`) would make the success cases pass for a script that cannot claim; the stub's contract is a comment
  in each stub, and the real script is exercised in phase 2's measurement.
- **The recall sweep may report more than the three warnings.** Every reported line is classified (a rule with a pair, an
  exemption or a not-a-rule with a reason); none is left unclassified.
- **Duplicated `Stop-Refused`.** Two copies can drift. Both are fixtured; D1 records the alternative.
- **Message text with line breaks.** Sites 79 and 112 carry the dirty paths and the stock script's output; the
  expectation is written by hand with those breaks, and the fixture's dirty file and stub output are fixed strings.

## Needs the owner

1. **Decided (anas.m, 2026-10-12, by approving the plan as written): D1, copy `Stop-Refused`.** Recommended and approved:
   a copy (six lines, the claim stays standalone, `territory-check.ps1` stays untouched). The alternative, a shared
   helper in `scope-lib.ps1`, would add a phase that touches `territory-check.ps1`.
2. **Decided (anas.m, 2026-10-12, by approving the plan as written): D2, exempt site 135.** Recommended and approved: exempt,
   with the written reason in D2 (exempt rules three to four). The alternative, a hook recipe field, would add a harness task
   to phase 1.
3. **The plan's approval**: given (anas.m, 2026-10-12); `tasks.md` is already written and follows it.

## Complexity Tracking

No constitution violation to justify. One duplication (D1) and one exemption (D2), both stated above.
