# Implementation Plan: A Critical feature's branch is not red from its first commit

**Branch**: `024-critical-branch-not-red` | **Date**: 2026-10-13 | **Spec**: specs/024-critical-branch-not-red/spec.md
**Input**: Feature specification (approved, anas.m, 2026-10-13; shape B) + decisions D1–D8 below
**Gate Batching**: none
**Gate Certification**: user-run

## Summary

`Invoke-CriticalEvidenceCheck` demands the independence artifact on every commit of a Critical feature's branch, though the
artifact cannot exist before the final phase. Shape B (approved): while the branch is **not merge-ready** the check emits one
`WARN` and does not fail; from the final-phase commit on it behaves exactly as it does today; wherever merge-readiness
cannot be shown it stays strict. Two phases, each independently revertible. First the check and its proof, fixtures first.
Then the guidance, the flow-down note, the digests and the roadmap. No new script, no new library file, no new recipe field
if the harness's commit recipe already carries a subject (T001 confirms), and no new verdict word (`WARN` already exists in
the pack as the `$warnings` list).

## Technical Context

**Language/Version**: PowerShell 7+ (`pwsh`)
**Primary Dependencies**: none new
**Storage**: files and git state only
**Testing**: the enforcement harness (`tests/enforcement/`): real temporary git repositories, hand-written expectations, a
passing and a failing fixture per rule. The existing `CRIT-S01..S03` and `CRIT-T01..T07` fixtures are Critical branches
whose commits carry no `phase N` subject, so under D3 they stay strict and must pass unchanged (SC-004).
**Target Platform**: any runner with `pwsh` and `git`
**Project Type**: governance tooling (scripts plus documents)
**Constraints**: the strict state is today's behaviour byte for byte (FR-002, SC-003); no other member changes (FR-004);
the lane is Standard
**Scale/Scope**: one function changed and one added in `scripts/enforcement-pack.ps1`, about eight rules' fixtures, four
documents, digests

## Constitution Check

- [x] **Specification First (I)**: `spec.md` is approved; this plan follows it; `tasks.md` follows.
- [ ] **Repository Separation (III)**: not applicable, the kit is one repository.
- [x] **Architecture Consistency (IV)**: no new file; the check stays in `enforcement-pack.ps1` beside its arms (D1).
- [ ] **Domain Invariants (V)**: not applicable, the template's slot is unfilled.
- [x] **Security (VI)**: nothing sensitive is read; the check reads a committed `tasks.md` and commit subjects.
- [ ] **External Integration Governance (VII)**: not applicable.
- [x] **Testing Requirements (VIII)**: every rule has a failing and a passing fixture, hand-written, failing first on the
  parent commit.
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI review with Reviewer
  Provenance. Constitution IX is unchanged: the independence artifact is still required before merge.
- [x] **Controlled Delivery (X)**: two phases, one at a time; this changes an enforcement member, so the owner runs the
  gate: no batching, no ci-held. Constitution X names the Critical lane's evidence only through the docs this feature edits;
  T006 reads it and records whether an amendment is needed (expected: none, the rule "evidence required" is unchanged).

**Phase sizing rule**: phase 1 changes no output for a non-Critical feature or for a merge-ready or undeterminable
Critical branch, and is useful alone. Phase 2 is documents and depends on phase 1. Reverting 2, then 1, leaves a
consistent kit.

**Post-design re-check**: no new violation. D3 and D7 are the owner's, and are approved or changed by approving this plan.

## Decisions

**D1 — The change lives in `Invoke-CriticalEvidenceCheck`, as a gate in front of the two arms (FR-001, FR-002).** The
function already resolves the level and the arm. A new `Get-CriticalMergeReadiness` returns `@{ Pending = bool; Why = string; Final; Tip }`; when `Pending` the
function adds one entry to `$script:warnings` and returns, and otherwise calls the arm unchanged (adding a `WARNING` naming
`Why` first when the branch could not be shown mid-feature). The two arms (`Invoke-CriticalSoloEvidence`, `Invoke-CriticalTeamEvidence`) are not edited, so their messages
and order cannot drift (FR-002). The signature gains `-Base`, the diff base the dispatch already computes, as the other
members that read history take it.
**Amendment approved by**: anas.m, 2026-10-13

**D2 — The declared final phase is the highest `## Phase N` heading of the committed `tasks.md` (FR-003).** Read from the
committed blob at `HEAD` (`git show "HEAD:./specs/$Branch/tasks.md"`, the `./` rule of 013 phase 5), through
`Get-VisibleFromText`, the visibility reader the amendment check already trusts, so a heading inside a comment, a fence or a
code span declares nothing. The grammar is the one `Get-Territory` reads, `^##\s+Phase\s+(\d+)\b`, reused rather than
re-invented. Headings must number `1..N` without a gap; a gap, a duplicate, no heading, or a missing or unreadable blob
leaves the branch **not-proven-pending**, i.e. strict (D3). Contiguity is what makes an invented high phase number visible
as a gap, the one way to hold a branch in `WARN` forever.

**D3 — Merge-ready means the branch carries a commit for the final phase; anything undeterminable is strict (FR-001,
FR-003).** The commit list is `git log --format=%s <base>..HEAD`. A subject counts as phase N when it matches
`^(?i)phase\s+N\b` **anchored at the start**; scope-check's looser `\bphase\s+(\d+)\b` is not reused, because it also reads
`notes: 023 T009 … phase 2` as a phase-2 commit, which here would flip a branch to merge-ready early (the safe direction,
but noisy). Anchoring is the narrower reading of the same convention the kit's own history follows (`phase 2: remediation …`).
Strict, with the reason in the message, when: no base (`$null`), a shallow clone, the log unreadable, `tasks.md`
undeterminable (D2), or no commit for the final phase **and** none for any phase at all. The last case matters:
a Critical branch with zero phase commits is exactly the state of every existing `CRIT-*` fixture and of a branch that
skipped phase naming; it stays strict, so the relaxation applies only to a branch that has *shown* it is mid-feature, by
carrying phase commits `1..k` with `k < N` (FR-003). This is the owner's decision: the alternative, WARN when merely
"no final-phase commit", is simpler and is exactly the shape that lets a branch avoid the artifact by never naming a phase.

*Superseded in part by the two amended paragraphs below.* The anchored form (`^(?i)phase\s+N\b`) and the decision not to reuse
scope-check's looser token, as described above, now apply only to showing that the branch is mid-feature at all; the final phase
is read with a looser token anywhere in a subject, as the amendments say.
**Amendment approved by**: anas.m, 2026-10-13

*Amended after the phase 1 AI review (F1, F3).* Two tighter signals, both approved by the owner, close most of the disclosed hole
and leave the rest named. (a) **An artifact already committed ends the pending state**: if the active arm's artifact file
(`human-pr-review.md` in team mode, `second-model-review.md` in solo mode) is committed on the branch at `HEAD`, the branch is
treated as owing the evidence now, the arm grades it exactly as it does today, and no `WARN` is printed. Someone who has produced
the artifact has said the work is ready, whatever the last commit was called, and it also means a committed but invalid artifact is
no longer left ungraded mid-feature (review F3). (b) **Final-phase detection reads a phase token anywhere in a subject**: a
subject matching `\bphase\s+N\b` (case-insensitive, any position) for the declared final phase `N` or beyond counts as the final
phase having landed, so `feat: phase 3` is seen; the anchored `^phase\s+k` form is kept only to establish that the branch is
mid-feature at all (`k` below `N`). The cost, accepted: a subject that merely mentions the final phase early (`phase 2: prepare
for phase 3`) makes the branch strict early, which is the safe direction and merely noisy. Phase numbers are parsed with
`[long]::TryParse` and an unparseable or overflowing number is treated as strict, never as a crash (review F2).
**Amendment approved by**: anas.m, 2026-10-13

*Amended again after the round 2 review (F2).* The token of (b) is widened from `\bphase\s+(\d+)\b` to
`\bphases?\s*(\d+)`: it is read with no space (`phase3`), with a suffix (`phase 3a`) and in the plural (`phases 3`), all of which
name a phase and none of which the first form saw. Still any position, still case-insensitive, still `[long]`-safe. The
anchored mid-feature form is unchanged. The cost is the same accepted one, noise in the safe direction: `phases` also
matches a subject such as `phases 3 and 4 reordered`, which makes the branch strict early.
**Amendment approved by**: anas.m, 2026-10-13

**D4 — The `WARN` is an entry in the existing `$warnings` list (FR-001).** It prints as `WARNING: CriticalEvidence: …`,
before the verdict, like `PhaseSizeWarning`, and does not change the exit code or the final `OK`. The message names the
artifact of the active arm, the phase that makes the branch merge-ready, and the phase the tip is at. One line per run.
The harness's verdict vocabulary already defines `WARN`; `ritual-checks.ps1` lifts failures and `UNGRADED`, and T001 confirms
a `WARNING:` line from the pack reaches the member's log unchanged and is not mistaken for a failure.

**D5 — The merge-time run needs no separate case (spec Assumptions).** A pull-request run checks out a merge preview whose
history still carries the branch's phase commits, so the final-phase commit is visible and the check is strict there. A
branch that has not reached its final phase has nothing to merge. On `main` the pack grades no feature branch, as today.

**D6 — Fixtures, rule ids and the coverage sweep (FR-005).** New rules `CRIT-R01` to `CRIT-R06` (R for readiness),
inventoried in `tests/enforcement/rules.json` with an `emitAnchor`, each a pair differing in one condition:
`R01` team arm, final phase not reached: `WARN`, exit 0 (the fail case is the same branch with the final-phase commit);
`R02` solo arm likewise; `R03` no `tasks.md` → strict; `R04` a `tasks.md` whose phases have a gap → strict; `R05` phase
commits present but the final one absent *and* the heading hidden in a fence → strict (the fence is not a heading);
`R06` shallow clone / no base → strict. The harness's `fail` cases are the ones that exit 1 with today's message; the
`WARN` pair expects exit 0 and the warning text. Existing `CRIT-*` cases run unchanged. A rule whose emission is the new
`WARN` is added to `emission-idioms.json` the way `PhaseSizeWarning` is, and the recall sweep is run first so nothing the
change emits is left unclassified.

**D7 — The merge-ready signal is the final phase's commit, and the review that follows it is part of "red".** From that
commit the branch is red until the artifact is committed, which is the truthful state: the final phase is written and its
reviews are owed (definition-of-done item 6, "after the feature's final phase"). The owner may therefore see one red run
at the final phase. That is the intended meaning of "red", not a regression (spec Background, SC-001).

**D8 — Guidance and flow-down (FR-006, FR-007).** `docs/sdlc/critical-delivery.md` (item 5 and its evidence paragraph),
`docs/sdlc/definition-of-done.md` item 6 and any digest marker that says when the artifact is demanded are updated to say
what the check does; `scripts/build-digests.ps1` regenerates the digests and nothing is hand-edited there.
`adoption/updating.md` gains a flow-down note in the shape of 022's and 023's. The measurement clones FitForge, FlowBoard
and ExpenseTracker from their local directories (never the real projects, nothing pushed) and compares enforcement-pack
output before and after on every non-Critical branch (SC-003) and on FitForge's Critical 002 branch if present.
`docs/roadmap.md` closes GAP-022, records the decision and marks the row `shipped`.

## Phases

Detailed tasks and the per-phase **Territory** blocks are in `tasks.md`.

1. **The check and its proof.** D1–D6. Delivers US1 and US2 and FR-001 to FR-005: `Get-CriticalMergeReadiness`, the gate in
   `Invoke-CriticalEvidenceCheck`, the `WARN`, fixtures first and shown failing on the parent, the idiom entry.
2. **Guidance, flow-down, measurement.** D7, D8. The three documents, digests, `adoption/updating.md`, `docs/roadmap.md`
   and the measurement over three clones (US3, FR-006, FR-007, SC-003).

## Project Structure

### Documentation (this feature)

```text
specs/024-critical-branch-not-red/
├── spec.md
├── plan.md              # this file
├── tasks.md
└── notes.md             # phase evidence, the baseline, the measurement
```

### Source Code (repository root)

```text
scripts/enforcement-pack.ps1              # phase 1: Get-CriticalMergeReadiness, the gate, the WARN
tests/enforcement/rules.json              # phase 1: CRIT-R01..CRIT-R06
tests/enforcement/emission-idioms.json    # phase 1: the new warning's idiom entry
tests/enforcement/cases/CRIT-R*/          # phase 1: fixtures
docs/sdlc/critical-delivery.md            # phase 2
docs/sdlc/definition-of-done.md           # phase 2
adoption/updating.md                      # phase 2: flow-down note
docs/roadmap.md                           # phase 2
docs/digests/**                           # phase 2
```

**Structure Decision**: no new script and no new library file; `scripts/enforcement-pack.ps1` already ships verbatim, so
`kit-manifest.json` needs no entry. `scripts/scope-check.ps1` and `scripts/scope-lib.ps1` are deliberately absent: the
phase grammar is read, not changed (D2, D3).

## Testing Strategy

- Each rule is first written as a failing fixture and shown failing on the parent commit, then the behaviour lands. For the
  `WARN` pair the parent's failure is the exit 1 the branch gets today.
- The pre-existing `CRIT-S*` and `CRIT-T*` cases run unchanged after the edit; the full harness on an isolated checkout of
  the final commit (feature 022's method); `-Case CRIT-` and `-Case RIT-` per phase.
- Phase 2's measurement, recorded in `notes.md`: before/after on the three clones, every line that moves listed with its cause.

## Risks

- **A branch can stay in `WARN` by never naming its final phase commit.** The relaxation's one real hole, narrowed again after the phase 1 review by D3's two added signals (an artifact already committed ends the pending state; a phase token anywhere in a subject counts as the final phase) and not closed: a final commit the pattern does not read as final, on a branch with no artifact committed yet, still reads as mid-feature. D3 narrows it
  (only a branch that already carries phase commits `1..k`, `k < N`, qualifies; contiguity D2 blocks an invented phase) but
  does not close it: a final commit whose subject carries no token that `\bphases?\s*(\d+)` reads as the final number is not seen as final: no phase word at all, a separator the pattern does not read (`phase-3`, `phase: 3`, `phase #3`, `Phase III`), or a list or range whose first number is lower (`phase 1 and 3`, `phases 2-3`, `phase 2/3`). What still stands behind it is gate 6,
  the human review at merge, which is held by a person and is not a machine check; the `WARN` is printed on every run so the
  artifact cannot be forgotten silently. Disclosed in the script header and in the flow-down note, as 013 disclosed its limit.
- **Mid-feature is anchored, final is not.** Only a subject that BEGINS with `phase k` shows the branch is mid-feature at all
  (narrower than scope-check, on purpose); a final-phase token anywhere in a subject (`feat: phase 4`, `Phase 4 —`, `phase4`)
  counts as the final phase having landed. A subject that mentions the final phase early makes the branch strict early:
  noisy, and the safe direction. A committed artifact also ends the pending state, so committing it early turns the branch
  red for the rest of the feature, and an uncommitted artifact leaves the branch on the WARN where the parent failed; the
  phase 2 guidance says so. An unparsable `kit-adoption.json` resolves to solo mode, so a committed team artifact does not end
  the pending state there (round 2, F3).
- **A mid-feature `tasks.md` amendment moves the final phase.** The branch goes back to `WARN`; correct, and the amendment
  is already graded by the amendment-authority check.
- **`Get-VisibleFromText` is not a markdown parser.** It hides comments, fences and code spans; an exotic construct could
  show or hide a heading. Contiguity (D2) turns most such misreads into strict.
- **The recall sweep may report more than the one warning.** Every reported line is classified; none is left unclassified.

**Amendment approved by**: anas.m, 2026-10-13

## Needs the owner

1. **D3, the precondition for the relaxation.** Recommended: WARN only when the branch already carries at least one phase
   commit and not the final one; zero phase commits stays strict. Alternative: WARN whenever the final-phase commit is
   absent. Simpler, and weaker: it removes the red from a branch that names no phase at all.
2. **D7, one red run at the final phase.** Accepted as the meaning of "merge-ready"; say if you would rather the check also
   wait for the review commit (a larger signal, and a second heuristic).
3. **The plan's approval.** `tasks.md` follows once it is given.

## Complexity Tracking

No constitution violation to justify.
