# Feature Specification: the scope check names a phase commit whose diff cannot be read

**Feature Branch**: `032-scope-check-unreadable-commit`
**Created**: 2026-10-16
**Status**: Draft
**Delivery Level**: Standard
**Rationale Rule**: 1
**Input**: User description: "GAP-038: the machine scope check names a phase commit whose diff cannot be read instead of passing it with 0 files: Get-CommitPaths in scope-lib.ps1 and the delete-guard in scope-check.ps1 read git show --name-status with 2>$null, so an unreadable commit is an empty path list and scope-check.ps1 prints PASS (0 file(s))."

## Background

`scripts/scope-check.ps1` is the machine check behind constitution X's territory rule: a phase commit may touch only the files its
phase's **Territory** block declares. It runs in `ritual-checks` on every push, and its PASS is one of the facts the owner's gate
rests on (`docs/sdlc/review-process.md`). It learns what a commit touched from one read, `git show --name-status` of the commit,
in two places: `Get-CommitPaths` in `scripts/scope-lib.ps1:29`, and the guard that refuses a commit deleting or renaming a
feature's `tasks.md` or `spec.md` (`scripts/scope-check.ps1:123`). Both discard git's error stream with `2>$null` and never read
the exit code, so a commit git cannot read produces **an empty list of paths**, which is also what a commit that touches nothing
produces. Feature 028 closed this species in `enforcement-pack.ps1` (an unreadable diff is a named state, never `0 changed
file(s)`); `specs/032-scope-check-unreadable-commit/notes.md` measures it here, on fixtures, before any change:

| Probe (the tree object of the commit under test is made unreadable) | Intact | Unreadable |
|---|---|---|
| `scope-check.ps1`, a phase commit | `PASS phase 1 commit ac9be87 (1 file(s))`, exit 0 | `PASS phase 1 commit ac9be87 (0 file(s))`, **exit 0**; with a second file outside the Territory it is `FAIL ... not in territory`, exit 1, when intact and the same `PASS ... (0 file(s))` when unreadable |
| `scope-check.ps1`, a commit with no phase token that deletes `tasks.md` | `FAIL commit c74b86d: the commit deletes specs/001-thing/tasks.md ...`, exit 1 | `not applicable (commit c74b86d carries no 'phase N' token)`, then `UNGRADED`, **exit 0** |
| `scope-check-repos.ps1`, a code repository's phase commit | `PASS phase 1 commit 1857b42 (1 file(s))` | `ERROR cannot read the committer date of 1857b42`, exit 1 (an earlier, unrelated read fails first; the cause named is wrong, but nothing passes) |
| `scope-check.ps1`, the `tasks.md` blob of the parent unreadable | `PASS` | `FAIL ... tasks.md is missing at the parent ... a prior commit deleted the territory declaration`, exit 1 (the cause named is wrong, but nothing passes) |

The first two rows are the defect: an out-of-territory change, and a deletion of a declaration file, both pass when the diff that
would show them cannot be read. The harm is not an everyday event (a healthy repository never reads this way), but the check
exists for the day something is wrong with a branch, and on that day it says PASS.

**Why this is Standard and not Micro.** The work is `scripts/scope-lib.ps1`, `scripts/scope-check.ps1`, `tests/enforcement/rules.json`
and a fixture pair per site, each fixture being three files. A Micro feature's Territory is at most five literal file paths
(`scripts/enforcement-pack.ps1`, MicroLane); the fixtures alone exceed that.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A phase commit whose diff cannot be read is not a PASS (Priority: P1)

An owner, a CI run or an agent runs `scope-check.ps1` on a branch whose phase commit git cannot read. The check says so, in its
own words, names the commit and the read that failed, and does not exit 0.

**Why this priority**: it is the one state in which the territory rule is not enforced and the check says it was.

**Independent Test**: a fixture whose phase commit has an unreadable tree; the `fail` (the parent commit) prints
`PASS ... (0 file(s))` and exits 0, the `pass` (this feature) prints the named state and does not.

**Acceptance Scenarios**:

1. **Given** a phase commit whose diff git cannot read, **When** `scope-check.ps1` grades it (Standard or Micro lane), **Then** it
   prints a line naming the commit and saying the commit's changed files could not be read, prints no `PASS` for it, and ends
   as Decision D1 decides.
2. **Given** a phase commit that is readable and touches no file (an empty commit), **When** it is graded, **Then** it prints what
   it prints today (`PASS ... (0 file(s))`): an empty list that git returned is not an unreadable one.
3. **Given** any readable commit, **When** it is graded, **Then** the output and exit code are those of today, byte for byte.

### User Story 2 - A guard that cannot read does not stand down (Priority: P1)

The guard that refuses a commit deleting or renaming `tasks.md` or `spec.md` reads the same rows. When it cannot read them it
does not fall through to "not applicable".

**Why this priority**: the guard exists so that a commit carrying no phase token cannot hide a deletion of the declaration; an
unreadable commit is exactly what would hide one.

**Independent Test**: a fixture with a token-less commit that deletes `tasks.md` and whose tree is unreadable.

**Acceptance Scenarios**:

1. **Given** a commit with no phase token whose diff cannot be read, **When** it is graded, **Then** it prints the same named
   state as User Story 1 and not `not applicable`.
2. **Given** a commit with no phase token whose diff is readable, **When** it is graded, **Then** it prints what it prints today.

### User Story 3 - The state is proved, and adopters are told (Priority: P2)

The state has fixtures that fail on the parent commit for the stated reason, owners in `tests/enforcement/rules.json`, and a
flow-down note adopters can act on.

**Why this priority**: GAP-029, GAP-031, GAP-036 and GAP-037 stayed open for lack of a way to reach the state. The fix is not
finished until a fixture reaches it.

**Independent Test**: the coverage report lists the new rule(s), each with a `fail` that fails on the parent commit and a `pass`
that passes on both.

**Acceptance Scenarios**:

1. **Given** the harness, **When** a recipe truncates the tree object of the commit under test (the existing `truncateCommit` field
   accepts `HEAD^{tree}`), **Then** the unreadable state is reached with no new harness field.
2. **Given** the paths that exist today (a passing phase commit, a failing one, a merge commit, a token-less commit, a Micro
   commit, a nested code repository), **When** the full harness runs, **Then** every pre-existing case passes unchanged.
3. **Given** an adopted project, **When** it updates the kit, **Then** `adoption/updating.md` says what changed, that the scripts
   flow down verbatim, and what the project may newly see.

### Edge Cases

- A commit that is readable and empty, a merge commit and a commit with no phase token whose diff is readable print what they print
  today.
- `scope-check-repos.ps1` calls `Get-CommitPaths` for each code repository's phase commit (`:271`). Today a damaged commit there
  stops earlier, at the read of the committer date (`ERROR cannot read the committer date`), which names the wrong cause but
  does not pass. After this feature the shared function names its own cause if it is reached first; the date read's message is
  not changed here.
- The `tasks.md` blob of the parent unreadable is reported today as a prior commit having deleted the declaration, which is the
  wrong cause but a FAIL, never a pass. It is a different read (`git show <parent>:<path>`), it does not pass, and it is left as
  stated here and not changed.
- `-All`, `-Commit` and `-Phase` do not change: they select commits, and an unreadable one is named wherever it is reached.

## Level Rationale *(mandatory — answers the four Critical triggers, in writing)*

- **domain-invariants**: does not apply — the kit has no domain-invariants pack; this is a command-line check that grades commits.
- **irreversible-data**: does not apply — the check reads git and writes only to the console; nothing is migrated, dropped or rewritten.
- **authn-authz-payment**: does not apply — no authentication, authorization or payment is touched.
- **auditable-evidence**: does not apply — the scope check's PASS is one input of the owner's gate, not evidence of record for an audit or contract; this feature stops that input from being wrong on an unreadable commit and does not make the check itself certifying.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: When the read of a commit's changed files (`git show --name-status`) fails, `scope-check.ps1` MUST NOT print `PASS`
  for that commit. It MUST print a line naming the commit and saying its changed files could not be read, and MUST end as
  Decision D1 decides, on the Standard lane and on the Micro lane.
- **FR-002**: A read that succeeds and returns no rows (a readable empty commit) MUST keep today's output and exit.
- **FR-003**: The guard that refuses a deletion or rename of `tasks.md` or `spec.md` MUST NOT stand down when its read fails: the
  commit is named as in FR-001, and not reported as `not applicable`.
- **FR-004**: The failure MUST reach the callers on a channel separate from the list of paths (an empty list is a valid result),
  so `scope-check-repos.ps1`, which calls the same function, names it too.
- **FR-005**: Every readable commit, merge commits and no-token commits included, MUST print today's text and exit with today's
  code, byte for byte. The `-Json`-less console output of a passing run, the `UNGRADED` summary and `-All` do not change.
- **FR-006**: Each site (the phase commit on each lane, the guard, the nested-repository call) MUST gain a failing and a passing
  fixture that differ only in the condition under test, written first and shown failing on the parent commit, each new rule
  inventoried in `tests/enforcement/rules.json` with its anchor; where a state cannot be reached the plan MUST exempt it with a
  written reason of the kind feature 015 FR-004 requires.
- **FR-007**: No other behaviour changes: the `tasks.md` and `spec.md` blob reads, the committer-date read of
  `scope-check-repos.ps1`, the territory grammar and the other verdicts are as they were.
- **FR-008**: `adoption/updating.md` MUST gain a flow-down note in the shape of feature 031's, and `docs/roadmap.md` MUST close
  GAP-038, record the decision and mark this feature's row `shipped`.

### Key Entities

- **Changed-file read**: the list of paths a commit touches, as `git show --name-status` returns it. It is a result of the check
  or an error of the check, never a verdict; today an error is indistinguishable from an empty result.
- **Named state**: a line in the script's own words that says what could not be read and that no grading took place.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On the measured fixture (a phase commit whose tree is unreadable), `scope-check.ps1` no longer prints `PASS` and no
  longer exits 0; on the token-less deleting commit it no longer prints `not applicable`.
- **SC-002**: A passing phase commit, a failing one, a merge commit, a no-token commit, an empty commit and a nested-repository
  commit print the same bytes and exit the same way before and after, on fixtures and on a clone of each adopted project.
- **SC-003**: Every site of FR-006 has a `fail` that fails on the parent commit for the stated reason and a `pass` that passes on
  both; the coverage report shows no unowned site; the exempt count rises only with a written reason; the full harness passes with
  every pre-existing case unchanged.

## Decisions for the owner

Each has a recommendation, given as a recommendation and not a decision.

- **D1 - the verdict.** (A, recommended) An `ERROR` line and exit 1 for the commit: the same verdict the script already gives a
  commit that does not resolve (`scope-check: ERROR '<sha>' does not resolve to a commit`), so a branch whose diff cannot be read
  is red, as a numbered branch's unreadable diff is red in `enforcement-pack` (feature 028). (B) `UNGRADED` and exit 0, the
  verdict of a run that graded nothing: smaller and never red, at the cost that CI stays green on a branch the check could not
  grade, which is the defect in a quieter form. (C) A warning and continue with the commits that can be read: leaves one commit
  ungraded inside a graded run.
- **D2 - how far it reaches.** (A, recommended) The path read, the delete guard and the nested-repository call, which is one
  shared function and one guard reading the same rows. (B) The path read only, leaving the guard to be fixed alone: the guard is
  the part a token-less deleting commit hides behind.
- **D3 - the phase shape.** (A, recommended) Two phases: the function, the guard and their fixtures first (User Stories 1 and 2),
  the flow-down note, the roadmap and the measurement on adopted-project clones second (User Story 3). (B) One phase.

## Assumptions

- The harness reaches these scripts the way features 023 to 031 did: the working directory set to the fixture, and the recipe
  fields that exist; `truncateCommit` accepts any revision, including `HEAD^{tree}` (as feature 026's fixture used it for a
  second parent's tree), so no new recipe field is built. If the plan finds a tree it cannot truncate (a packed object), it
  says so and exempts that site with a written reason.
- The scripts are kit-owned and flow down verbatim; no adopted project has a verdict from them to move.
- The refusal and error text stay on the streams they use today (`Write-Host`, as the script's existing `ERROR` lines).
- The measured behaviour (`notes.md`) holds for the git in use here (2.55 for Windows); the plan's first task re-measures the
  chosen shape on the CI image's git before any change to the scripts.
- Left as stated limits, not changed here: the reads of the `tasks.md` and `spec.md` blobs of the parent (they FAIL, with a
  cause named wrongly), and the committer-date read of `scope-check-repos.ps1`.
