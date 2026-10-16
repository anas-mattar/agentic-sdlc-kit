# Feature Specification: Make every unchecked `git` read a named state, not "nothing"

**Feature Branch**: `029-unchecked-git-reads-named-state`
**Created**: 2026-10-15
**Status**: Approved 2026-10-15 (owner: anas.m) — Decision 1: B (every unchecked read, one phase per group); Decision 2: the recommended lane split
**Delivery Level**: Standard
**Rationale Rule**: 1
**Input**: User description: "GAP-035: grade the unchecked git reads in scripts/enforcement-pack.ps1 and scripts/territory-check.ps1 that use 2>$null with no exit-code check, so a git failure is read as "nothing" (as feature 028 did for the diff). Inventory every unchecked read, decide which fail on the numbered lane and which print UNGRADED on the Lite lane, with one truncateBlob fixture per read. See docs/roadmap.md row GAP-035 and specs/028-unreadable-diff-named-state."

## Background

Feature 028 (GAP-034) made one read honest: a `git diff` that exits non-zero is now a named state (`Read-DiffLines`, `Add-DiffUnreadable` in `scripts/enforcement-pack.ps1`), not an empty list. Its phase 3 review (finding F2) showed the same silence in other reads and recorded it as GAP-035: a `git` command is run with `2>$null` and its exit code is never looked at, so a command git cannot run returns no lines, and no lines are read as "nothing to grade".

**Reproduced by 028's phase 3 review.** With a damaged blob, `git diff --name-only` still exits 0, but `git show --numstat --format='' <commit>` fails and is read as zero lines. On a Micro-declared branch with a 700-line phase commit, the hard 400-line failure became `enforcement-pack: OK` (exit 0), and the phase-size warning disappeared.

**Same shape, by reading the code, not probed** (the first job of the plan is to probe each one):

| Group | Reads (script, approximate line) | What "nothing" would mean |
|---|---|---|
| Phase size | `git rev-list --no-merges`, `git log -1 --format=%s`, `git show --numstat` in the Micro lane's phase walk and in `PhaseSizeWarning` (`enforcement-pack.ps1` ~845-851, ~1282-1284) | no commit, or zero lines: the 400-line bound and the size warning pass (reproduced) |
| Critical and plan artifacts | `git cat-file -e`, `git show HEAD:...` of the plan, `tasks.md`, the human-review file; `git log` subjects and phase tokens; `git log --follow` for the review file's date (~408-601, ~972) | an artifact reads as absent or empty, a phase token as missing, a review date as "no history" |
| Amendment and history | `git log`, `git show -U0` (the record lines), `ls-tree`, `rev-list`, `git rev-parse` of blobs, the self-history reads of the pack at another ref (~1341-2142) | an amendment record or a moved document is not seen. Part of this group is already named by features 026 and 027; the plan says which |
| Territory | `scripts/territory-check.ps1`: the uncommitted-tree diff (`git diff --name-only HEAD`, ~97) and an open branch's diff and counts (~220-229) | the branch's own uncommitted files drop out of the overlap check; an open branch reads as "no overlap" |

The reads that are already graded stay as they are: `Read-DiffLines` (028), the base resolver, the shallow-clone checks, and `territory-check.ps1`'s `Stop-Refused` and `Add-Ungraded` paths (028's inventory lists them).

## Decision for the owner

**Decision 1 (scope). Recommendation: B, every unchecked read in both scripts, delivered as phases by group.**

| | Shape | Cost |
|---|---|---|
| A | Only the reproduced reads (`git show --numstat`, two sites) | Smallest and provable. The roadmap row stays open for the rest, and the ~30 reads by reading-the-code stay a stated limit. |
| B (recommended) | Inventory every unchecked read in `enforcement-pack.ps1` and `territory-check.ps1`; classify each as *already named*, *graded here* or *out of scope, with a reason*; grade the rest, one phase per group | Closes the row. Largest change; each group is its own phase with its own gate and fixtures. |
| C | B plus the other scripts (`scope-check*.ps1`, `claim-feature.ps1`, ...) | Wider than the row names. Not recommended; each script becomes its own row. |

**Decision 2 (policy per lane). Recommendation: the same split as features 027 D8 and 028 D1.** On a numbered branch a failed read is a failure that names the read and the cause. On the Lite lane (`fix/`, `chore/`, `docs/`) each check that graded nothing prints one `UNGRADED` line and the exit code is unchanged (feature 014 FR-009). `territory-check.ps1` has no lanes and speaks its own vocabulary (GAP-029): it uses its existing `Stop-Refused` and `Add-Ungraded` shapes, and its exit codes are the plan's to state. Alternative: fail on every lane, which contradicts 014 FR-009 and needs an owner amendment of that rule. Not recommended.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A Micro phase over the hard bound is never reported `OK` (Priority: P1)

An owner runs the pack on a Micro-declared branch whose phase commit exceeds 400 lines and whose blob git cannot read.

**Why this priority**: it is the hole, reproduced: a hard failure became `OK`.

**Independent Test**: a fixture (a Micro branch, a 700-line phase commit, a blob named by `truncateBlob`) fails on the parent commit with `OK`, and after the change names the unreadable read and does not end on `OK`.

**Acceptance Scenarios**:

1. **Given** a numbered Micro branch whose `git show --numstat` fails, **Then** one failure names the read, the commit and the consequence, and the exit code is 1.
2. **Given** the same branch with a readable 700-line commit, **Then** the 400-line failure is unchanged.
3. **Given** a readable commit with zero changed lines, **Then** the output is unchanged.

---

### User Story 2 - Every other graded read names its failure (Priority: P1)

For each read in the inventory classed "graded here", a failure of that read is named, never read as an empty result.

**Why this priority**: an unprobed read that swallows a failure is the same hole waiting for a damaged object.

**Independent Test**: one fixture per read, built with `truncateBlob` (or the nearest state the fixture library can reach), each shown failing on the parent commit.

**Acceptance Scenarios**:

1. **Given** a numbered branch and a read in the inventory that fails, **Then** a failure names that read and its cause (once per read per run).
2. **Given** a Lite branch and the same failure, **Then** an `UNGRADED` line names the check that graded nothing, the verdict is not `OK`, and the exit code is unchanged.
3. **Given** the same branches with readable objects, **Then** the output is byte-identical to today's.

---

### User Story 3 - `territory-check.ps1` does not read a failed diff as "no overlap" (Priority: P2)

**Why this priority**: an open branch whose diff cannot be read must not be reported as touching nothing, and a dirty tree whose diff cannot be read must not drop the branch's own files.

**Independent Test**: a fixture with an open branch whose diff fails, and one with an uncommitted-tree diff that fails; each prints a named result instead of an empty overlap.

**Acceptance Scenarios**:

1. **Given** an open branch whose diff against the base fails, **Then** the run names that branch as not graded rather than as "no overlap".
2. **Given** an uncommitted-tree diff that fails, **Then** the run says so and does not continue as if the tree were clean.
3. **Given** readable diffs, **Then** the output and exit code are unchanged.

---

### User Story 4 - Healthy runs are unchanged, and the limit is retired in the documents (Priority: P1)

**Why this priority**: the new states must be told apart from true empty results, and every green run on real history must stay green.

**Independent Test**: the existing harness passes unchanged; a replay of the kit's history and the three adopted projects' histories shows no output differing; grep of the documents named in FR-011 finds no statement of the old limit as current.

**Acceptance Scenarios**:

1. **Given** a read that exits 0 with empty output (an empty diff, a file with no history, no matching commits), **Then** it prints exactly as today.
2. **Given** the feature merged, **Then** `adoption/updating.md` carries a flow-down note in the shape of 026, 027 and 028, naming what stays open.

---

### Edge Cases

- **Exit 0 with empty output is not a failure.** The new state is entered on a non-zero exit, never on an empty result. Some reads legitimately return nothing (`git log --follow` of an uncommitted file, `git grep` with no hit, `git show -U0` of an unchanged path).
- **Non-zero exit that is a normal answer.** `git cat-file -e` and `git rev-parse --verify --quiet` use the exit code to say "absent". The plan classifies each such read so that absent is told apart from unreadable (for example `cat-file -e` exits 1 for an absent object and 128 for a damaged repository, to be confirmed by probe).
- **Partial output with a failing exit** is discarded, as in 028, never graded.
- **A read already named by 026, 027 or 028** is not named twice; one cause prints one line.
- **A shallow clone or a missing base** keep the existing output; a read that fails only because the history is absent is the already-named cause.
- **`git` unavailable or not a repository:** the scripts already stop before any member runs; unchanged.
- **Reads inside `-ReplayBase`/`-ReplayTip` replay:** unchanged for readable ranges.

## Level Rationale *(mandatory — answers the four Critical triggers, in writing)*

- **domain-invariants**: does not apply — the kit has no domain-invariants pack; this changes what two scripts say when a `git` command fails.
- **irreversible-data**: does not apply — commits are read, never changed; nothing is migrated, dropped or rewritten.
- **authn-authz-payment**: does not apply — no authentication, authorization or payment is touched.
- **auditable-evidence**: does not apply — the pack is a machine aid behind human review at merge, which is unchanged; this feature makes its verdict honest about what it graded and adds no evidence an auditor would rely on (the answer 026, 027 and 028 gave).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The plan MUST publish an inventory of every `git` read in `scripts/enforcement-pack.ps1` and `scripts/territory-check.ps1` that discards stderr and does not check the exit code, with each read classified as *already named*, *graded here* or *out of scope with a reason* (Decision 1, option B).
- **FR-002**: Every read classed *graded here* MUST tell a failed command (non-zero exit) apart from an empty result, and MUST NOT return lines from a failed command.
- **FR-003**: On a numbered branch, a failed read MUST be a failure naming the read, the object or range, and the consequence, once per read per run.
- **FR-004**: On the Lite lane, each check that graded nothing because a read failed MUST print one `UNGRADED:` line, the verdict MUST NOT be `OK`, and the exit code MUST NOT change (feature 014, FR-009).
- **FR-005**: The Micro lane's phase walk and `PhaseSizeWarning` MUST NOT read a failed `git show --numstat` as zero lines; a 700-line phase whose blob is unreadable MUST NOT end on `OK`.
- **FR-006**: Reads whose exit code is itself the answer (`cat-file -e`, `rev-parse --verify --quiet`) MUST distinguish "absent" from "unreadable" where git's exit codes allow it; where they do not, the plan MUST say so and name the limit.
- **FR-007**: `scripts/territory-check.ps1` MUST NOT read a failed uncommitted-tree diff as a clean tree, nor a failed open-branch diff as "no overlap"; each is named in the script's existing vocabulary.
- **FR-008**: A read that exits 0 with empty output MUST print exactly what it prints today.
- **FR-009**: Every behaviour here MUST have a failing and a passing fixture written first, shown failing on the parent commit, one `truncateBlob` fixture (or the nearest reachable state, named in the plan) per read classed *graded here*, with a readable-object control for each. Each new emission site is owned by a rule in the harness.
- **FR-010**: The measurement MUST be re-run per merge in the shape CI grades a pull request, on this kit's history and on clones of the three adopted projects, old script against new, and report how many outputs differ (expected: none) and how many reads were exercised.
- **FR-011**: Every document that states the limit MUST say what is now named and what stays open: the scripts' `LIMITS` comments, `docs/roadmap.md` (GAP-035 shipped, with owner and spec path), `adoption/updating.md` (a flow-down note that supersedes 028's open-limit wording), and `specs/028-*` is not edited (history).
- **FR-012**: The work MUST be delivered one phase per read group (Decision 1), each ending on the user-confirmed gate.

### Key Entities

- **Unchecked read**: a `git` command whose stderr is discarded and whose exit code is not examined before its output is graded.
- **Named read failure**: the state in which such a command exits non-zero; a property of the run, carried beside the lines, not a value of them.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The reproduced case (a 700-line Micro phase, an unreadable blob) no longer ends on `OK`; with a readable blob it still fails the 400-line bound.
- **SC-002**: The inventory classifies 100% of the unchecked reads in the two scripts; none is left unclassified.
- **SC-003**: Every read classed *graded here* has one fixture that failed on the parent commit and passes after the change.
- **SC-004**: Output for readable repositories, empty results, a missing base and a shallow clone is byte-identical to the parent commit.
- **SC-005**: Across the kit's history and the three adopted projects, no output differs, and the replay reports how many reads it exercised.
- **SC-006**: The full harness passes with every pre-existing case unchanged and no unowned emission site.

## Assumptions

- A non-zero exit of the `git` command is the machine's definition of "unreadable"; git's message is not parsed (028's rule).
- The fixture library's `truncateBlob` reaches a damaged blob (028 built its fixtures with it); reads it cannot reach are named in the plan with the nearest state used.
- The verdict vocabulary (`OK`, `FAIL`, `WARN`, `N/A`, `UNGRADED`, `PENDING`) is defined once in `scripts/ritual-checks.ps1`; this feature adds no word to it.
- Feature 014 FR-009 stands; features 027 D8 and 028 D1 are the lane-split precedent.
- The line numbers above are from the parent commit and are orientation only; the plan's inventory is the authority.
- The inventory may show reads that are safe as they are (a failure is already caught downstream); those are recorded as *already named* with the evidence, not changed.
