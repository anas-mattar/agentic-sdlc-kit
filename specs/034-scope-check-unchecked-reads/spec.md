# Feature Specification: the scope checks name a merge base or commit list they cannot read

**Feature Branch**: `034-scope-check-unchecked-reads`
**Created**: 2026-10-17
**Amendment approved by**: anas.m, 2026-10-17
**Status**: Approved 2026-10-17 (owner: anas.m) <!-- D1 A, D2 A, D3 A -->
**Owner decisions**: anas.m, 2026-10-17 — D1 A (an ERROR line and exit 1 for a merge base or commit list git could not read; the legitimate UNGRADED states keep exit 0), D2 A (scope-check.ps1, scope-check-repos.ps1 and the shared Get-RepoMergeBase; territory-check.ps1 keeps its verdicts), D3 A (two phases)
**Delivery Level**: Standard
**Rationale Rule**: 1
**Input**: User description: "GAP-040: the scope checks name their other unchecked reads: Get-DiffBase and the commit-list git rev-list of scope-check.ps1 and scope-check-repos.ps1 discard their errors, so a damaged branch can end scope-check -All on UNGRADED could not resolve a merge base with exit 0."

## Background

`scripts/scope-check.ps1` and `scripts/scope-check-repos.ps1` grade a feature branch's phase commits against their declared Territory.
With `-All` (the form `ritual-checks.ps1` runs, and so CI) they first find the branch's merge base with the trunk and list the commits
since it. Feature 032 made a commit whose changed files cannot be read an `ERROR` (exit 1) instead of `PASS (0 file(s))`. The two reads
that precede it have the same flaw, which feature 032's phase 1 review found (finding F3) and recorded as GAP-040:

- the merge base: `Get-DiffBase` (`scripts/scope-check.ps1:86`) and `Get-RepoMergeBase` (`scripts/scope-lib.ps1:204`, used by
  `scope-check-repos.ps1` and by `territory-check.ps1`) run `git merge-base` with `2>$null` and return nothing on **any** non-zero exit;
- the commit list: `git rev-list --reverse --no-merges <base>..HEAD 2>$null` (`scope-check.ps1:319`, `scope-check-repos.ps1:379`) reads
  a failure as an empty list.

Their callers print `UNGRADED could not resolve a merge base with main - nothing checked` and `UNGRADED (no commits since merge base - no
commit was examined)` and exit 0. Those are honest messages for the states they were written for (no trunk, no shared history, an empty
range); they are the wrong words, and exit 0 the wrong verdict, for a branch whose commit objects are damaged.
`specs/034-scope-check-unchecked-reads/notes.md` measures it on the kit's own fixtures before any change:

| Probe (a commit object of the branch is made unreadable) | `-Commit` / tip mode | `-All` |
|---|---|---|
| `scope-check.ps1`, the **tip** commit object deleted | not run (the tip is unresolvable) | `UNGRADED could not resolve a merge base with main - nothing checked`, **exit 0** |
| `scope-check.ps1`, the tip commit object **truncated** | not run | the same, **exit 0** (`git merge-base` exits 128) |
| `scope-check.ps1`, the **middle** (spec) commit object deleted | `ERROR commit <sha>: its changed files could not be read ...`, exit 1 (feature 032) | the same `UNGRADED ... merge base`, **exit 0** |
| `scope-check-repos.ps1`, the code repository's tip commit object deleted | `ERROR '001-thing' does not resolve to a commit`, exit 1 | `UNGRADED could not resolve a merge base with a trunk (...) - NOTHING WAS GRADED`, then `UNGRADED (nothing was graded ...)`, **exit 0** |
| a branch with **no history in common** with the trunk (an orphan), `scope-check.ps1 -All` | n/a | the same `UNGRADED ... merge base`, exit 0: **a legitimate state, indistinguishable by message** |

The git exit codes tell the two apart (measured): `git merge-base` exits **1** when two commits share no history and **255 or 128** when it
cannot read the objects; `git rev-parse --verify --quiet <missing ref>` exits 1; `git rev-list <base>..HEAD` exits **128** on a damaged
range. The scripts read none of them. `ritual-checks.ps1` runs `scope-check.ps1 -All`, so CI is green for a branch whose objects it
could not read.

**Why this is Standard and not Micro.** The work is `scripts/scope-lib.ps1`, `scripts/scope-check.ps1`, `scripts/scope-check-repos.ps1`,
`tests/enforcement/rules.json` and a fixture pair per site, each fixture being three files; the fixtures alone exceed a Micro feature's
Territory (at most five literal file paths, `scripts/enforcement-pack.ps1`, MicroLane).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A branch whose merge base cannot be read is an ERROR, not "nothing checked" (Priority: P1)

An owner, a CI run or an agent runs `scope-check.ps1 -All` (or `scope-check-repos.ps1 -All`) on a branch with a damaged commit. The
check says that the merge base could not be read, names git's failure, and does not exit 0.

**Why this priority**: it is the one place `ritual-checks` and CI still print a green UNGRADED for a branch the check could not read.

**Independent Test**: a fixture whose tip commit object is truncated; the `fail` (the parent commit) prints `UNGRADED ... merge base`
and exits 0, the `pass` (this feature) prints the named state and does not.

**Acceptance Scenarios**:

1. **Given** a branch whose commit objects git cannot read, **When** `scope-check.ps1 -All` looks for the merge base, **Then** it prints
   an `ERROR` line saying the merge base could not be read (git failed, not that the trunk is absent) and ends as Decision D1 decides.
2. **Given** a branch with no shared history with the trunk, **or** no trunk ref at all, **When** it runs, **Then** it prints what it
   prints today (`UNGRADED could not resolve a merge base ...`, exit 0): git answered, and the answer was "none".
3. **Given** a repository that git reads fine, **When** it runs, **Then** every output and exit code is today's, byte for byte.

### User Story 2 - A commit list git could not read is not an empty range (Priority: P1)

**Why this priority**: an empty list ends the run with `UNGRADED (no commits since merge base)` and exit 0.

**Independent Test**: a fixture in which `git rev-list <base>..HEAD` fails while the merge base was read.

**Acceptance Scenarios**:

1. **Given** the merge base was read and `git rev-list` over its range fails, **When** the check runs, **Then** it prints an `ERROR` naming
   the failed list and ends as D1 decides, in both scripts.
2. **Given** a range that git read and found empty, **When** it runs, **Then** it prints `UNGRADED (no commits since merge base ...)` as today.

### User Story 3 - The states are proved, and adopters are told (Priority: P2)

**Why this priority**: GAP-029, GAP-031, GAP-036, GAP-037 and GAP-038 stayed open for lack of a way to reach the state.

**Independent Test**: the coverage report lists the new rules, each with a `fail` that fails on the parent commit and a `pass` that passes
on both, or an exemption with a written reason; the full harness passes unchanged.

**Acceptance Scenarios**:

1. **Given** the harness, **When** a recipe truncates the tip commit (`truncateCommit` accepts `HEAD`), **Then** the merge-base state is reached
   with no new harness field; a state that no recipe can reach is exempt with a written reason.
2. **Given** an adopted project, **When** it updates the kit, **Then** `adoption/updating.md` says what changed, that the scripts flow down
   verbatim, and what a CI run on a damaged branch now shows.

### Edge Cases

- No trunk ref (`origin/main`, `main` absent), a branch that shares no history with the trunk, and a range that is empty keep their
  `UNGRADED` text and exit 0 (FR-002): git answered.
- `-Commit` and tip mode do not change: an unresolvable sha is already an `ERROR` and a damaged commit is feature 032's `ERROR`.
- `territory-check.ps1` calls `Get-RepoMergeBase` too and keeps its own verdicts (feature 018): the shared function reports a failure on a
  channel of its own, and whether `territory-check.ps1` reads it is Decision D2.
- The reads behind the guard (`git rev-list --parents`, `git log -1 --format=%s`, the `rev-parse` of the branch name) and the
  `tasks.md`/`spec.md` blob reads are covered by feature 032's guard or stated limits and are not changed here.

## Level Rationale *(mandatory — answers the four Critical triggers, in writing)*

- **domain-invariants**: does not apply — the kit has no domain-invariants pack; these are command-line checks that grade commits.
- **irreversible-data**: does not apply — the checks read git and write only to the console; nothing is migrated, dropped or rewritten.
- **authn-authz-payment**: does not apply — no authentication, authorization or payment is touched.
- **auditable-evidence**: does not apply — the scope check's verdict is one input of the owner's gate, not evidence of record for an audit or contract; this feature stops that input being green on a branch it could not read.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: When `git merge-base` (or its trunk lookup) fails with an error, as opposed to answering that there is no merge base,
  `scope-check.ps1 -All` and `scope-check-repos.ps1 -All` MUST print an `ERROR` line saying so and MUST end as Decision D1 decides,
  never `UNGRADED ... merge base` with exit 0.
- **FR-002**: When git answers that there is no trunk ref, or no shared history, or an empty range, the `UNGRADED` text and exit 0 of today
  MUST be kept.
- **FR-003**: When `git rev-list` over `<base>..<tip>` fails, both scripts MUST print an `ERROR` naming the failed list and end as D1 decides.
- **FR-004**: `scope-check-repos.ps1` MUST name the repository in each of those lines, as its other lines do.
- **FR-005**: The failure MUST reach the callers on a channel separate from the value (an empty or null base is a valid answer),
  from `Get-RepoMergeBase` in `scope-lib.ps1` and from `Get-DiffBase`; what `territory-check.ps1` does with it is Decision D2.
- **FR-006**: Every readable repository, `-Commit` and tip mode, and every state of FR-002 MUST print today's text and exit with
  today's code, byte for byte.
- **FR-007**: Each site MUST gain a failing and a passing fixture that differ only in the condition under test, written first and shown
  failing on the parent commit, each new rule inventoried in `tests/enforcement/rules.json` with its anchor; where no recipe can reach a
  state the plan MUST exempt it with a written reason of the kind feature 015 FR-004 requires.
- **FR-008**: `adoption/updating.md` MUST gain a flow-down note in the shape of feature 033's, and `docs/roadmap.md` MUST close GAP-040,
  record the decision and mark this feature's row `shipped`.

### Key Entities

- **Merge base**: the commit the feature branch shares with the trunk, from which `-All` lists the commits to grade. `git merge-base` answers
  it, answers "none" (exit 1), or fails (exit 128 or 255).
- **Commit list**: the commits `git rev-list` returns for `<base>..<tip>`; empty is a valid answer, a failure is not.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On the measured fixtures (a tip commit truncated, `-All`), `scope-check.ps1` and `scope-check-repos.ps1` no longer print
  `UNGRADED ... merge base` and no longer exit 0.
- **SC-002**: A readable repository, a branch with no shared history, a missing trunk and an empty range print the same bytes and exit the
  same way before and after, on fixtures and on a clone of each adopted project.
- **SC-003**: Every site of FR-007 has a `fail` that fails on the parent commit for the stated reason and a `pass` that passes on both, or
  an exemption; the coverage report shows no unowned site; the full harness passes with every pre-existing case unchanged.

## Decisions for the owner

**Amendment approved by**: anas.m, 2026-10-17

Each has a recommendation. **Decided by the owner (anas.m, 2026-10-17): D1 A, D2 A, D3 A**, as recommended.

- **D1 - the verdict.** (A, recommended) An `ERROR` line and exit 1, as feature 032 decided for an unreadable commit: a branch whose
  merge base or commit list could not be read is red, and the legitimate `UNGRADED` states keep exit 0 because git answered. (B)
  `UNGRADED` with a different message and exit 0: never red, at the cost that CI stays green on a damaged branch, which is the defect. (C) A
  warning and continue with the next candidate trunk: leaves a damaged branch graded against whichever trunk happens to resolve.
- **D2 - how far it reaches.** (A, recommended) `scope-check.ps1`, `scope-check-repos.ps1` and the shared `Get-RepoMergeBase`, which
  reports the failure on a flag; `territory-check.ps1` keeps its verdicts and does not read the flag (stated as a limit). (B) Also make
  `territory-check.ps1` name a failed merge base: it has its own verdict vocabulary (feature 018) and its own contract, so it is a larger
  change to a different check.
- **D3 - the phase shape.** (A, recommended) Two phases: the shared function, both scripts and the fixtures first (User Stories 1 and 2), the
  flow-down note, the roadmap and the measurement on adopted-project clones second (User Story 3). (B) One phase.

## Assumptions

- The harness reaches these scripts the way features 032 and earlier did; `truncateCommit` takes any revision (`HEAD` for the tip commit), so no
  new recipe field is built. If the plan finds a state no recipe reaches (the `rev-list` failure after a successful merge base is the likely one,
  because both walk the same objects), it says so and exempts it with a written reason.
- The scripts are kit-owned and flow down verbatim; no adopted project has a verdict from them to move.
- The refusal and error text stay on the streams they use today (`Write-Host` and `Write-Line`).
- The measured exit codes of git (`merge-base` 1 for no merge base, 128 or 255 for a failure; `rev-list` 128) hold for git 2.55 for Windows; the
  plan's first task re-measures them on the CI image's git before any change.
- Left as stated limits, not changed here: the `tasks.md` and `spec.md` blob reads (a failure FAILs with the wrong cause, never a pass), the
  committer-date read of `scope-check-repos.ps1`, and `territory-check.ps1` (D2).
