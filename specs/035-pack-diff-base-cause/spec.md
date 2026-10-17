# Feature Specification: the enforcement pack names the cause when its diff base cannot be read

**Feature Branch**: `035-pack-diff-base-cause`
**Created**: 2026-10-17
**Status**: Draft
**Delivery Level**: Standard
**Rationale Rule**: 1
**Input**: User description: "GAP-041: the enforcement pack names the cause when its diff base cannot be read: Get-DiffBase in enforcement-pack.ps1 takes any non-zero git merge-base exit for no integration branch, so a damaged numbered branch fails with the wrong cause and a Lite-lane branch only warns."

## Background

`scripts/enforcement-pack.ps1` grades a branch's documents against the integration branch. Its `Get-DiffBase` (`scripts/enforcement-pack.ps1:186`) tries
`origin/main` and `main` and returns the merge base, or nothing. Like the two scope checks before feature 034, it reads `git merge-base HEAD <trunk>` with
`2>$null` and treats **any** non-zero exit as "no base", so a branch whose commit objects git cannot read looks like a branch with no integration branch
(a shallow clone, a missing `origin/main`, unrelated histories). Feature 034 gave the scope checks git's own distinction (`merge-base` exits 1 for "no shared
history", 128 or 255 when it cannot read); the pack still reads it as one state, and says so: its `AmendmentAuthority` message ends "this check does not
distinguish them, and says so". `specs/035-pack-diff-base-cause/notes.md` measures what an owner then sees, on the kit's own fixtures before any change:

| Probe (`enforcement-pack.ps1 -Root <fixture> -Branch <b>`) | Result |
|---|---|
| a numbered branch, intact | `diff base '17952ff...', 3 changed file(s)`, `AmendmentAuthority: graded ...`, `OK`, exit 0 |
| the same, the **tip commit truncated** | `diff base ''`, a `WARNING: ... no integration branch to diff against`, `UNGRADED: ReviewProvenance: no diff base ... Fetch the full history ('fetch-depth: 0' ...)`, `UNGRADED: PhaseSizeWarning ...`, then `FAIL (1 issue(s)): AmendmentAuthority: cannot grade '001-thing' - no integration branch to diff against. Either neither 'origin/main' nor 'main' resolves here, or one of them resolves but shares no commit with HEAD (a truncated clone, or unrelated histories) - this check does not distinguish them`, **exit 1** |
| a Lite-lane branch (`docs/x`), intact | `diff base '...', 1 changed file(s)`, `OK`, exit 0 |
| the same, the **tip commit truncated** | `diff base ''`, the same `WARNING` and `UNGRADED: ReviewProvenance ... Fetch the full history`, `UNGRADED (1 check(s) formed no opinion)`, **exit 0** |
| a numbered **orphan** branch (no shared history: legitimate) | the same `WARNING`, `UNGRADED` lines and `AmendmentAuthority: cannot grade ... no integration branch` (plus the missing-document failures of a branch with no spec), exit 1 |

The numbered lane is red for a damaged branch, so a damaged branch is not green there (unlike the scope check before feature 034). What is wrong is the **cause**:
the WARNING and the failure speak of a missing integration branch and a shallow clone, and the `UNGRADED` line for `ReviewProvenance` advises `fetch-depth: 0`, none
of which helps an owner whose objects are damaged: the remedy is `git fsck` or a fresh clone. The Lite lane stays `UNGRADED`, exit 0, by a standing decision (feature 014
FR-009 forbids newly failing a Lite branch on a null base; feature 015 D6 keeps `UNGRADED` at exit 0); only its words can improve.

**Why this is Standard and not Micro.** The work is `scripts/enforcement-pack.ps1`, `tests/enforcement/rules.json` and a fixture pair per site, each fixture being
three files; the fixtures alone exceed a Micro feature's Territory (at most five literal file paths, `scripts/enforcement-pack.ps1`, MicroLane).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A damaged branch is named as damaged, not as a missing integration branch (Priority: P1)

An owner, a CI run or an agent runs `enforcement-pack.ps1` on a branch whose commit objects git cannot read. The pack says that the diff base could not be read,
names git's failure, and points at repairing the repository, instead of telling an owner with an intact `main` to fetch more history.

**Why this priority**: it is the one place the pack sends the owner to the wrong remedy for a state it already treats as red or ungraded.

**Independent Test**: a fixture whose tip commit is truncated; the `fail` (the parent commit) prints `no integration branch to diff against` and the `fetch-depth: 0` advice, the
`pass` (this feature) names the unreadable base.

**Acceptance Scenarios**:

1. **Given** a numbered branch whose commit objects git cannot read, **When** the pack looks for the diff base, **Then** the dispatch warning and the `AmendmentAuthority` failure say
   that the base could not be read (git failed, not that no integration branch exists), keep the numbered lane failing with exit 1, and name the repair; the shallow-clone advice is not given.
2. **Given** a Lite-lane branch in the same state, **When** the pack runs, **Then** it says the same, stays `UNGRADED`, and exits 0 (feature 014 FR-009).
3. **Given** a branch with no shared history, no `origin/main` and `main` at all, or a shallow clone, **When** the pack runs, **Then** it prints what it prints today, byte for byte.

### User Story 2 - The states are proved, and adopters are told (Priority: P2)

**Why this priority**: GAP-029 to GAP-040 stayed open for lack of a way to reach the state.

**Independent Test**: the coverage report lists the new rule(s), each with a `fail` that fails on the parent commit and a `pass` that passes on both, or an exemption with a written reason.

**Acceptance Scenarios**:

1. **Given** the harness, **When** a recipe truncates the tip commit (`truncateCommit` accepts `HEAD`), **Then** the state is reached with no new harness field.
2. **Given** an adopted project, **When** it updates the kit, **Then** `adoption/updating.md` says what changed, that the script flows down verbatim, and what an owner now reads on a damaged branch.

### Edge Cases

- A branch with no `origin/main` or `main`, an orphan branch, and a shallow clone keep today's text: git answered, and the answer was "none" (`rev-parse --verify --quiet` and `merge-base` exit 1).
- The pack's own shallow-clone detection (`git rev-parse --is-shallow-repository`) is separate and unchanged.
- The `UNGRADED` lines of `MicroLane`, `ReviewProvenance`, `PhaseSizeWarning` and `LiteAndAbuse` say "no diff base"; that stays true of a damaged branch. Only the line that gives the `fetch-depth: 0` advice is a wrong remedy for it.
- `enforcement-pack.ps1 -ReplayBase/-ReplayTip` and `-IgnoreAmendmentBoundary` do not use `Get-DiffBase`'s result and do not change.

## Level Rationale *(mandatory — answers the four Critical triggers, in writing)*

- **domain-invariants**: does not apply — the kit has no domain-invariants pack; this is a command-line check that grades a branch's documents.
- **irreversible-data**: does not apply — the pack reads git and writes only to the console; nothing is migrated, dropped or rewritten.
- **authn-authz-payment**: does not apply — no authentication, authorization or payment is touched.
- **auditable-evidence**: does not apply — the pack's verdict is one input of the owner's gate, not evidence of record for an audit or contract; this feature changes what it says about a damaged branch, not whether it fails.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: When `git merge-base` (or its trunk lookup) fails with an error, as opposed to answering that there is no merge base, `Get-DiffBase` MUST report the failure
  on a channel separate from its value (no base is a valid answer), the way `scripts/scope-check.ps1` does since feature 034.
- **FR-002**: When that happens, the dispatch warning and the numbered lane's `AmendmentAuthority` failure MUST say that the diff base could not be read, name git's failure
  and exit code, and name the repair (`git fsck`, a fresh clone); they MUST NOT describe the state as a missing integration branch or advise `fetch-depth: 0`.
- **FR-003**: The verdicts MUST NOT change: a numbered branch fails (exit 1) and a Lite-lane branch is `UNGRADED` at exit 0 (feature 014 FR-009, feature 015 D6); the pack's exit
  codes are as today.
- **FR-004**: A missing trunk, no shared history and a shallow clone MUST keep today's text and verdicts, byte for byte, as does every readable repository.
- **FR-005**: Each site that gives the cause MUST gain a failing and a passing fixture that differ only in the condition under test, written first and shown failing on the parent commit,
  each new rule inventoried in `tests/enforcement/rules.json` with its anchor; where no recipe can reach a state the plan MUST exempt it with a written reason (feature 015 FR-004).
- **FR-006**: `adoption/updating.md` MUST gain a flow-down note in the shape of feature 034's, and `docs/roadmap.md` MUST close GAP-041, record the decision and mark this feature's row `shipped`.

### Key Entities

- **Diff base**: the merge base of the branch with the integration branch, from which the pack reads the diff it grades. `git merge-base` answers it, answers "none" (exit 1), or fails (128 or 255).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On the measured fixtures (a numbered branch and a Lite-lane branch with the tip commit truncated), the pack no longer says `no integration branch to diff against` or advises `fetch-depth: 0`, and says the base could not be read; the exit codes are unchanged (1 and 0).
- **SC-002**: A readable repository, a branch with no shared history, a missing trunk and a shallow clone print the same bytes and exit the same way before and after, on fixtures and on a clone of each adopted project.
- **SC-003**: Every site of FR-005 has a `fail` that fails on the parent commit for the stated reason and a `pass` that passes on both, or an exemption; the coverage report shows no unowned site; the full harness passes with every pre-existing case unchanged.

## Decisions for the owner

Each has a recommendation, given as a recommendation and not a decision.

- **D1 - what the pack does.** (A, recommended) Name the cause, keep the verdicts: the numbered lane stays red with the cause named, the Lite lane stays `UNGRADED` at exit 0 with the cause named,
  as feature 014 FR-009 and feature 015 D6 decided. (B) Also fail the Lite lane on a failed read: a damaged `docs/` branch would be red, at the cost of overriding feature 014 FR-009 (which would
  need its own amendment). (C) Leave the pack as it is and record the non-distinction it already states as a limit: no change, the wrong remedy stays in the output.
- **D2 - how far it reaches.** (A, recommended) `Get-DiffBase`, the dispatch warning and the `AmendmentAuthority` failure, and the one `UNGRADED` line that advises `fetch-depth: 0` (`ReviewProvenance`); the other
  "no diff base" `UNGRADED` lines stay (they state a consequence that is still true). (B) Also reword every "no diff base" line to carry the cause: more consistent, but four more lines and fixtures for each.
- **D3 - the phase shape.** (A, recommended) Two phases: the function, the messages and their fixtures first (User Story 1), the flow-down note, the roadmap and the measurement on adopted-project clones second (User Story 2). (B) One phase.

## Assumptions

- The harness reaches the pack the way earlier features did; `truncateCommit` takes `HEAD` (as in feature 034's fixtures), so no new recipe field is needed. If the plan finds a state no recipe reaches, it says so and exempts it with a written reason.
- The scripts are kit-owned and flow down verbatim; no adopted project has a verdict from them to move.
- The measured exit codes of git (`merge-base` 1 for no merge base, 128 or 255 for a failure) hold for git 2.55 for Windows and, per feature 034's CI, for Linux; the plan's first task re-measures them before any change.
- Left as stated limits, not changed here: the other "no diff base" `UNGRADED` lines (D2), the pack's shallow-clone detection, and the Lite lane's exit 0 (D1).
