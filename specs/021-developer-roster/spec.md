# Feature Specification: Load-bearing developer roster

**Feature Branch**: `021-developer-roster`
**Created**: 2026-10-11
**Amendment approved by**: anas.m, 2026-10-11
**Status**: Approved (anas.m, 2026-10-11)
**Delivery Level**: Standard
**Rationale Rule**: 1
**Input**: User description: "Load-bearing developer roster: the adoption record's developers become objects (name, repos, canApproveCritical), keeping string entries legal and 013's absent-record-defaults-to-strict rule, read three ways: a feature's Owner is in the roster, a Critical feature's reviewer is in the roster and is neither the Owner nor unpermitted, and at most one active claim per Owner (GAP-024, GAP-004)"

## Background

The `developers` array in `kit-adoption.json` exists to be counted. `Get-DeveloperMode` (`scripts/adoption-lib.ps1`,
feature 013) reduces it to a number: two or more selects the team arm of the Critical evidence check, anything else
the solo arm. Nothing else reads it. Three consequences are live today (GAP-024):

- **Names are never checked against the roster.** A feature's Owner (the roadmap row's Owner cell) and the Reviewer
  in a Critical feature's Review Provenance block are free text. The team arm compares them to each other, never to
  the declared developers, so the strictest lane's independence rests on two strings that need not name anyone the
  project has declared.
- **The owner picks their own judge**, and the roster carries no statement of who may judge a Critical feature.
- **The WIP limit is prose.** `docs/sdlc/team-workflow.md` section 3 says one active feature per developer, with a
  pipelining exception (one feature awaiting review plus one active), and no check counts a developer's open
  `NNN-*` claims (GAP-004). `scripts/roadmap-claim-check.ps1` already enumerates the claims on `origin` and maps each
  to its roadmap row and Owner, so the missing count is a join over machinery that exists.

The adopted projects today: FitForge declares `["anas.m", "ahmad"]` and its roadmap Owner is `anas.m`; FlowBoard and
ExpenseTracker declare no developers (solo arm) and their Owner is `anas.m`. A change that reads the roster cannot
be allowed to turn any of the three red without saying so.

Deliberately **not** in this feature (the roadmap row and GAP-024 say so): assignment authority, skill matrices,
capacity planning. The leaderless claim-by-push ledger is the kit's best team property, and this feature does not
buy out coordination-by-meeting.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - The roster can say more than a name, and old rosters keep working (Priority: P1)

A project may write a developer as an object (`name`, optionally `repos` and `canApproveCritical`) as well as a
plain string. A project that writes only strings, or nothing, sees exactly the verdicts it sees today.

**Why this priority**: every other story reads the roster, and none of them may change a verdict for a project that
did not opt in.

**Independent Test**: fixtures with a string-only roster, an object roster, a mixed roster and an absent roster
select the same Critical arm, report the same developer count, and a string entry equals the object
`{ "name": <that string> }` in every check.

**Acceptance Scenarios**:

1. **Given** a roster of strings only, **When** any check reads it, **Then** the developer count, the arm chosen
   and every verdict are unchanged from the parent commit.
2. **Given** an object entry with a blank or non-string `name`, a `repos` that is not an array of declared
   `codeRepos` names, or a `canApproveCritical` that is not a boolean, **When** the doctor runs, **Then** it reports
   that entry by position and what is wrong, and the entry is read as the safest reading (see FR-003).
3. **Given** the same person written twice (case-insensitively), as a string and as an object, **When** the count is
   taken, **Then** they are one developer, as feature 013 already treats two strings.

---

### User Story 2 - A feature's Owner is on the roster (Priority: P1)

When a project declares a roster, every claim on `origin` whose roadmap row names an Owner must name someone on it.
A claim whose Owner is not on the roster fails the roadmap-claim check, naming the claim, the Owner and the roster.

**Why this priority**: it is the first of the three readings and the one every later check leans on.

**Independent Test**: a fixture with a declared roster and a claim whose row Owner is a stranger fails; the same
fixture with the Owner on the roster passes; a project with no roster passes either way.

**Acceptance Scenarios**:

1. **Given** a declared roster and a claimed feature whose row Owner is on it (any case), **When**
   `roadmap-claim-check.ps1` runs, **Then** it passes the Owner.
2. **Given** a declared roster and a row Owner not on it, **When** it runs, **Then** it fails naming the claim,
   the Owner, and the declared names.
3. **Given** no declared roster (absent, empty or unusable), **When** it runs, **Then** it grades nothing about
   Owners and says so; it does not fail and does not claim the Owners were checked.

---

### User Story 3 - A Critical feature's reviewer is permitted to judge it (Priority: P1)

In the team arm of the Critical evidence check, the Reviewer must be on the roster, must not be the Owner (already
checked), and must not be a developer whose `canApproveCritical` is `false`.

**Why this priority**: it closes the strictest lane's honesty gap (GAP-024 a and b).

**Independent Test**: a team-arm fixture whose Reviewer is a stranger fails, one whose Reviewer is flagged
`canApproveCritical: false` fails, one whose Reviewer is on the roster and permitted passes; the solo arm is
untouched.

**Acceptance Scenarios**:

1. **Given** the team arm and a Reviewer who is not on the roster, **When** the check runs, **Then** it fails
   naming the Reviewer and the roster.
2. **Given** a Reviewer whose entry says `canApproveCritical: false`, **When** it runs, **Then** it fails saying so.
3. **Given** a string-only roster, **When** it runs, **Then** every named developer is permitted (a string entry is
   permitted unless the record says otherwise), so a project that has only ever written names is not newly locked out.

---

### User Story 4 - The WIP limit has a counter (Priority: P2)

`roadmap-claim-check.ps1` counts, per Owner, the claims on `origin` that are not stale, and reports the count. A
project that declares a roster fails when an Owner holds more than the hard cap the team-workflow document already
states; an Owner at the pipelining level is noted, never failed, because "review formally requested" is a fact
about a pull request that git history cannot show.

**Why this priority**: GAP-004 is the second half of the row, and it is advisory-shaped by nature.

**Independent Test**: fixtures with one, two and three active claims for one Owner: one passes, two passes with a
note naming the pipelining conditions the machine cannot see, three fails.

**Acceptance Scenarios**:

1. **Given** an Owner with three non-stale claims, **When** it runs, **Then** it fails naming the Owner and the claims.
2. **Given** an Owner with two, **When** it runs, **Then** it passes and prints a note that two claims are lawful
   only under the pipelining conditions, which a human confirms.
3. **Given** a stale claim (no commits for two weeks), **When** counting, **Then** it is not counted, as the
   document says stale claims may be reclaimed.

---

### User Story 5 - Adopters are told what changes, with a measurement (Priority: P2)

The guidance says what the roster can hold and what each check now does, the flow-down note says what flows down
and what an owner may newly see, and the change is measured on clones of the three adopted projects.

**Why this priority**: a check that reads a record adopters wrote cannot ship unmeasured (features 018 and 020).

**Independent Test**: the measurement table in `notes.md` shows, for each of the three projects, every verdict
before and after, with none moved or each moved verdict explained.

**Acceptance Scenarios**:

1. **Given** the three adopted projects, **When** the update is applied to clones, **Then** no verdict moves, or
   each that does is reported as a finding with the document that causes it.

---

### Edge Cases

- A roster entry written as an object with only `name` is identical to a string.
- A roster of one developer is solo mode (feature 013's count) and every roster-membership check still applies to
  that one name.
- An Owner written as `Ada` against a roster entry `ada` matches; matching is case-insensitive and exact otherwise
  (no fuzzy matching, no prefix matching).
- A roadmap row whose Owner cell is `—` or empty (an `idea` row) is not a claim and is not graded.
- A claim on `origin` with no roadmap row, or an `idea` row, is already a failure (GAP-017); this feature adds
  nothing to it.
- `repos` naming a repository `codeRepos` does not declare is reported by the doctor, and is never a reason to fail
  a feature.
- A record that is not valid JSON, or whose `developers` is not an array, selects the solo arm as today and the
  roster-membership checks grade nothing.

## Level Rationale *(mandatory — answers the four Critical triggers, in writing)*

- **domain-invariants**: does not apply — the kit has no domain-invariants pack; these are checks over governance records.
- **irreversible-data**: does not apply — nothing is migrated, dropped or rewritten; the record gains an optional shape and old shapes stay legal.
- **authn-authz-payment**: does not apply — the roster says who may judge a Critical feature, but it is read by a lint over documents and git history; no product authentication or authorization flow is built. This is the closest of the four to the line, and it is the owner's call at approval.
- **auditable-evidence**: does not apply — the Critical evidence check is changed to read the roster, and the independence evidence it grades already exists (feature 013); nothing here is evidence a regulator or contract can ask for.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Each entry of `developers` in `kit-adoption.json` MUST be either a non-empty string (unchanged
  meaning) or an object with a non-empty string `name`, an optional `repos` (an array of names the record's
  `codeRepos` declares) and an optional `canApproveCritical` (a boolean).
- **FR-002**: A string entry MUST be read as an object holding only that `name`; a project that writes strings only
  MUST see the same developer count, the same Critical arm and the same verdicts as before this feature, in every
  check, including the doctor's messages about the count.
- **FR-003**: A missing `canApproveCritical` MUST mean permitted. An entry that is not a string or a well-formed
  object MUST be dropped from the roster, reported by the doctor by position and cause, and, when its absence would
  make a check fail, MUST NOT be silently counted as someone; the direction of every degenerate input is the one that
  keeps feature 013's strictness (nothing usable declared means the solo arm).
- **FR-004**: Developer names MUST be compared case-insensitively after trimming, across string and object entries,
  and two entries naming the same person MUST count once.
- **FR-005**: When a roster is declared and usable, `scripts/roadmap-claim-check.ps1` MUST fail a claim on `origin`
  whose non-`idea` roadmap row names an Owner not on the roster, naming the claim, the Owner and the declared names.
  With no usable roster it MUST grade no Owner and say so in its output.
- **FR-006**: In the team arm, the Critical evidence check MUST fail a Reviewer who is not on the roster and a
  Reviewer whose entry sets `canApproveCritical` to `false`, in addition to the existing Reviewer-is-not-Owner check.
  The solo arm MUST be unchanged.
- **FR-007**: `scripts/roadmap-claim-check.ps1` MUST count, per Owner, the non-stale claims on `origin` and fail an
  Owner whose count exceeds the cap `docs/sdlc/team-workflow.md` states (more than two); an Owner at two MUST be
  noted, never failed; a stale claim (no commits for two weeks) MUST NOT be counted. The count is graded **only where
  a roster is declared and usable**; a project with none keeps its CI as it is, and the output says the count was
  not graded (decided by the owner, anas.m, 2026-10-11).
- **FR-008**: `scripts/verify-kit.ps1` MUST report, by entry position and cause, every malformed roster entry, an
  unknown `repos` name and a duplicate, and MUST state the mode and roster it read, the way it states the mode today.
- **FR-009**: Every new rule MUST have a passing and a failing fixture in the enforcement harness, anchored in
  `tests/enforcement/rules.json`, so the coverage test grades it (feature 015), and no existing fixture's
  expectation changes.
- **FR-010**: `docs/sdlc/critical-delivery.md` (the team arm and its worked sentence), `docs/sdlc/team-workflow.md`
  (the roster, the WIP counter and what the machine cannot see) and `adoption/updating.md` MUST describe the
  roster shapes and each new check, with a flow-down note naming what flows down and what an owner may newly see.
- **FR-011**: The change MUST be measured on clones of FitForge, FlowBoard and ExpenseTracker, never the real
  projects; a verdict that moves is a finding, not a rounding error.
- **FR-012**: The `repos` field MUST be validated and recorded but is read by no check in this feature; matching
  developers to features by repository is the assignment authority the roadmap row deliberately excludes. A `repos` entry
  that does not cover a feature's Territory repositories is therefore not even a note; this stands as written at
  the owner's approval of the spec (anas.m, 2026-10-11).

### Key Entities

- **Roster entry**: a developer as the record writes them: a string, or an object `{ name, repos?, canApproveCritical? }`.
- **Roster**: the usable entries of `developers`, deduplicated case-insensitively; empty when the record declares
  nothing usable.
- **Claim**: a remote `NNN-*` branch; its Owner is the Owner cell of its roadmap row.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every verdict a string-only or absent roster produced before this feature is byte-identical after it
  (the whole harness passes with only new fixtures added).
- **SC-002**: Each of FR-005, FR-006 and FR-007 has a failing fixture that fails for the stated reason and a passing
  fixture that differs only in the condition under test; the coverage test reports every new site fixtured.
- **SC-003**: On clones of the three adopted projects, no verdict moves, or every one that moves is listed with its
  cause.
- **SC-004**: A reader of `docs/sdlc/team-workflow.md` can tell, from one page, what the machine now counts and what
  it still cannot see (a pull request being open).

## Assumptions

- The roadmap row's Owner cell is the project's record of a feature's owner; the Review Provenance block's Owner
  line, in a Critical feature, must agree with it only as far as feature 013 already requires.
- No constitution amendment is needed. The WIP limit and the cross-review rule live in
  `docs/sdlc/team-workflow.md`; the Critical evidence check lives in `docs/sdlc/critical-delivery.md` and
  `scripts/enforcement-pack.ps1`. Constitution IX (a human reviewer approves before merge) is unchanged.
- `canApproveCritical` defaults to permitted so that no project that has only ever written names is locked out of
  its own Critical lane; `false` is the only way to deny. (Whether the default should instead be to deny is the
  stricter alternative and would change FitForge's Critical lane today.)
- Claim staleness is the document's rule (no commits for two weeks) and is read from the branch's latest commit.
- Existing `developers` handling in `Get-DeveloperMode` keeps its problem reports unchanged for string-only records.
