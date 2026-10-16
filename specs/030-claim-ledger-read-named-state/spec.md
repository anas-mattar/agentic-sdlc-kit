# Feature Specification: claim-feature.ps1's ledger read and refused push are named states

**Feature Branch**: `030-claim-ledger-read-named-state`
**Created**: 2026-10-16
**Amendment approved by**: anas.m, 2026-10-16
**Status**: Approved 2026-10-16 (owner: anas.m) <!-- D1 A, D2 A, D3 A -->
**Owner decisions**: anas.m, 2026-10-16 — D1 A (the loop is widened: read failure, rejected push, withdrawal and re-fetch), D2 A (a rejected push is refused at once), D3 A (two phases)
**Delivery Level**: Standard
**Rationale Rule**: 1
**Input**: User description: "GAP-036: Get-RemoteFeatureHeads in scripts/claim-feature.ps1 ends in a terminating throw when git ls-remote fails, also after a push that succeeded; a push the remote refuses is read as a lost race and passes over three numbers; the re-fetch in the race loop is unchecked. The same species feature 023 closed for the seven Write-Error refusals (GAP-031). Name each state, prove each with a fixture, and tell adopters."

## Background

`scripts/claim-feature.ps1` is the command every team member runs to take a feature number (`docs/sdlc/branch-strategy.md`,
"Number Allocation"). Feature 023 gave its seven refusals their own message and exit 1. It left one site of the same species
open on purpose, because the spec's grep for `Write-Error` did not see it and FR-006 forbade widening the feature
(`specs/023-claim-feature-refusals/notes.md`, "Findings recorded, not fixed"; GAP-036 in `docs/roadmap.md`).

The script reads the remote ledger (the `NNN-*` branches on `origin`) through `Get-RemoteFeatureHeads`. When
`git ls-remote --heads origin` fails, that function ends in `throw`. Under `$ErrorActionPreference = 'Stop'` the process
leaves through PowerShell's error path and not through the script's own `exit 1`; the exit code a caller sees is not
measured on this site yet (the first phase measures it before anything changes, as 023 did).

The function has three callers, and they are not equal:

| Line | Caller | What is on `origin` when the read fails |
|---|---|---|
| 105 | the first read, after the first `git fetch origin --prune` succeeded | nothing of ours: no number is allocated yet |
| 134 | the rival check, after **every** `git push -u origin <branch>` | our claim, if the push succeeded: it is already live |
| 145 | the re-read after the in-loop re-fetch, when a race was lost and the script renumbers | nothing of ours, if the withdrawal at line 140 worked |

Three more reads or writes in the same flow have the same silence, and are inventoried here for the plan to decide
(line numbers as of `main` at `5aac5ec`):

| Line | Call | Silence |
|---|---|---|
| 128-129, 136 | `git push -u origin <branch>`, exit code kept in `$pushOk` | a push the remote **refuses** (a permission or hook rejection, no rival) is read as a lost race: the script warns `claimed concurrently ()` with an empty rival list, renumbers, and pushes again, three times, then refuses with `Lost the allocation race 3 times` |
| 140 | `git push origin --delete <branch>`, output and exit code discarded | a withdrawal that fails leaves our abandoned number on `origin` while the script renumbers: a stale claim in the ledger, never reported |
| 144 | `git fetch origin --prune`, output and exit code discarded | a failed re-fetch is followed by a ledger read and a number allocated from refs the fetch did not refresh; the first fetch (line 103) refuses on failure, this one does not |
| 58 | `git for-each-ref` in `Get-NextFreeNumber`, `2>$null` | a failure reads as "no local branches"; the remote ledger and `specs/` still bound the number, so the harm is bounded (see Assumptions) |

None has a fixture. No recipe field of the harness makes `git ls-remote` fail after a successful fetch or push, so the
state is unreachable today, which is why it has no rule in `tests/enforcement/rules.json`.

**Why this is Standard and not Micro.** The work is `scripts/claim-feature.ps1`, `tests/enforcement/rules.json`, the
harness's recipe fields (a way to fail the ledger read on a chosen call), and a fail and a pass fixture per reachable
site, each fixture being three files and several carrying a stub of the stock `create-new-feature.ps1`. A Micro feature's
Territory is at most five literal file paths (`scripts/enforcement-pack.ps1`, MicroLane); the fixtures alone exceed that.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A failed ledger read says whether the claim may be live (Priority: P1)

A developer, a wrapper or an agent runs `claim-feature.ps1` and the ledger read fails. The script refuses in its own words
and exit 1, and the words say which of two things is true: nothing of ours is on `origin`, or our branch may already be.

**Why this priority**: a failure after a push that succeeded is a claim taken and reported as not taken. A wrapper that
reads "failed" as "no claim" and retries from a fresh checkout allocates a second number while the first stays live.

**Independent Test**: a fixture per caller of the read (105, 134, 145); each `fail` shows the refusal and exit 1 and
the message the caller's state calls for.

**Acceptance Scenarios**:

1. **Given** a clean repository on `main` whose first ledger read fails, **When** `claim-feature.ps1 -ShortName x "y"`
   runs, **Then** it prints a refusal that says the remote ledger could not be read and that nothing was claimed, creates
   no branch and no spec directory, and exits 1.
2. **Given** a push that succeeded and a ledger read that then fails, **When** it runs, **Then** it prints a refusal that
   names our branch, says it may already be on `origin` and that the remote must be checked before claiming again, leaves
   our branch on `origin` untouched, and exits 1.
3. **Given** a lost race, a withdrawal and a re-fetch, and a ledger read that then fails, **When** it runs, **Then** it
   prints the refusal of scenario 1 (nothing of ours is on `origin`, because the withdrawal worked) and exits 1.
4. **Given** any of the above with `-Json`, **When** it runs, **Then** the refusal is a message on the error stream and exit
   1, with no JSON object (as for every refusal today).

---

### User Story 2 - A refused push is not a lost race (Priority: P1)

A developer whose push the remote rejects (no rival claim) is told the push was rejected, not that someone else took the
number.

**Why this priority**: today the script warns about a concurrent claim with an empty list of claimants, burns three
numbers renumbering a branch that never reached the remote, and ends on a message that sends the developer to renumber
by hand, which is the wrong remedy for a rejected push.

**Independent Test**: the existing fixture of the push that fails (feature 023's `originPushUrl` recipe field) shows the
new message and exit 1, and a fixture of a genuine rival still renumbers.

**Acceptance Scenarios**:

1. **Given** a push that fails and no rival with our number on `origin`, **When** it runs, **Then** it prints a refusal that
   says the push was rejected and what git said, does not warn of a concurrent claim, does not renumber, and exits 1.
2. **Given** a rival claim with our number on `origin`, **When** it runs, **Then** it warns, withdraws, renumbers and pushes
   exactly as it does today (the genuine lost race is unchanged).
3. **Given** a push that fails and a rival with our number that appears at the same time, **When** it runs, **Then** it is
   treated as the lost race it is (a rival exists), unchanged.

---

### User Story 3 - A withdrawal or re-fetch that fails is named (Priority: P2)

When the script loses a race it withdraws its own branch and re-fetches before it renumbers. If either step fails it says
so instead of continuing on a ledger it did not refresh, or leaving an abandoned claim unreported.

**Why this priority**: the second claim is the one the team sees; a stale claim of ours on `origin` blocks a number and
reads as a live feature in `scripts/roadmap-claim-check.ps1` and `scripts/territory-check.ps1`.

**Independent Test**: fixtures that fail the withdrawal and the re-fetch after a lost race.

**Acceptance Scenarios**:

1. **Given** a lost race and a withdrawal that fails, **When** it runs, **Then** it refuses, names the branch left on
   `origin`, says to delete it, and exits 1.
2. **Given** a lost race and a re-fetch that fails, **When** it runs, **Then** it refuses with the message of the first
   fetch (`git fetch origin failed — cannot claim against an unreachable ledger.`), says our abandoned branch is already
   withdrawn, and exits 1.

---

### User Story 4 - The new states are proved, and adopters are told (Priority: P2)

Each named state has a failing and a passing fixture, and `adoption/updating.md` says what flows down.

**Why this priority**: GAP-029 and GAP-031 stayed open for lack of a way to reach the state. The fix is not finished until
the harness can reach it.

**Independent Test**: the coverage report lists the new rules, each with a `fail` that fails on the parent commit for the
stated reason and a `pass` that differs in one condition.

**Acceptance Scenarios**:

1. **Given** the fixtures, **When** the harness runs them on the parent commit, **Then** each `fail` fails for the stated
   reason (a leaked or launcher exit code, or a wrong message) and each `pass` passes.
2. **Given** the change, **When** the harness runs, **Then** each `fail` shows its message and exit 1 and each `pass` shows a
   claim that succeeds, and every pre-existing rule is unchanged.
3. **Given** the update note, **When** an adopter reads it, **Then** it says what flows down, what a wrapper may newly
   observe, and what does not change.

---

### Edge Cases

- A successful claim, a no-remote claim, a `-NoPush` claim, a claim that loses the race once and renumbers, and each of the
  seven refusals of feature 023 print what they print today, byte for byte, with the same exit.
- The ledger read fails after a push that **failed**: nothing of ours is on `origin`. The refusal for the failed push
  (User Story 2) wins over the read failure, because the push is the older fact; the message still says nothing is claimed.
- The read fails after a push that succeeded **and** the branch was withdrawn by an earlier attempt: the withdrawal happens
  before the re-read, so the state is the same as scenario 3 of User Story 1.
- A push that reports failure but landed (a timeout after the remote accepted it): the script cannot tell from the exit code
  alone. The refusal says to check `origin` for our branch before claiming again; deciding it from the ledger is out of
  scope (see Assumptions).
- `-Json` does not change the refusals: there is no JSON error object today and none is added.

## Level Rationale *(mandatory — answers the four Critical triggers, in writing)*

- **domain-invariants**: does not apply — the kit has no domain-invariants pack; this is a command-line script that allocates a branch name.
- **irreversible-data**: does not apply — the script creates a branch and a spec directory and may delete its own just-pushed branch when it loses a race; nothing is migrated, dropped or rewritten, and this feature changes how it refuses and what it says, not what it does to data.
- **authn-authz-payment**: does not apply — no authentication, authorization or payment is touched; a push the remote refuses for permission reasons is named, not worked around.
- **auditable-evidence**: does not apply — a claim is a coordination signal on a remote, not evidence of record for any audit or contract.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A failure of the remote ledger read (`git ls-remote --heads origin`) MUST end in the script's own refusal and
  exit 1, from each of its three callers (lines 105, 134, 145), never in a terminating `throw`, so that a caller and the
  enforcement harness observe the message and exit 1 and never the launcher's exit 97 or a leaked exit code of a git call.
- **FR-002**: The refusal for a failed read MUST say which state holds. After a push that succeeded it MUST name our branch,
  say it may already be on `origin` and that the remote must be checked before claiming again, and MUST NOT delete or move
  it. Where nothing of ours can be on `origin` (the first read, and the re-read after a withdrawal that worked) it MUST say
  nothing was claimed.
- **FR-003**: A push that fails with no rival claim carrying our number on `origin` MUST be refused as a rejected push,
  once, with git's own text, without the concurrent-claim warning, without renumbering and without retrying. A push whose
  failure is accompanied by a rival, and a push that succeeded beside a rival, MUST behave as they do today.
- **FR-004**: A withdrawal (`git push origin --delete <branch>`) that fails MUST refuse, naming the branch left on `origin`
  and saying to delete it; a re-fetch (line 144) that fails MUST refuse with the existing first-fetch message and MUST say
  our abandoned branch is already withdrawn.
- **FR-005**: A claim that succeeds (with a remote, with no remote, with `-NoPush`, and after a renumbering caused by a
  genuine rival) MUST print exactly what it prints today and exit 0 (SC-001). The seven refusals of feature 023 MUST keep
  their text, stream and exit 1. The `-Json` object keeps its shape and its fields.
- **FR-006**: Each state of FR-001 to FR-004 (sites 105, 134 after a successful push, 134 after a failed push, 145, the
  rejected push, the failed withdrawal, the failed re-fetch) MUST gain a failing and a passing fixture that differ only in the
  condition under test, written first and shown failing on the parent commit, each new rule inventoried in
  `tests/enforcement/rules.json` with its anchor. The harness MUST gain the recipe field(s) it needs to fail the ledger
  read, the withdrawal and the re-fetch on a chosen call; where a state cannot be reached the plan MUST exempt it with a
  written reason of the kind feature 015 FR-004 requires, and the coverage report shows which.
- **FR-007**: No other behaviour of the script changes: the preflight order, ledger allocation, the delegation to the stock
  script, the genuine lost-race loop, the warnings and the `-Json` object are as they were. The three reads left as stated
  limits (Assumptions) are not changed.
- **FR-008**: `adoption/updating.md` MUST gain a flow-down note in the shape of feature 023's (what was wrong, what it does
  now, what flows down, what may newly be seen, what does not change, what was measured, what to do), and
  `docs/roadmap.md` MUST close GAP-036, record the decision, and mark this feature's row `shipped`.

### Key Entities

- **Ledger read**: the list of `NNN-*` branches on `origin`, read to allocate a number and to look for a rival. A failure to
  read it is an error of the script, not a verdict.
- **Claim state at refusal**: whether our branch is on `origin` (taken), is not (nothing claimed), or cannot be known (a
  push that reported failure). The refusal's text is the carrier of this state; the script has no verdict words.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A successful claim (with a remote, none, `-NoPush`, and one genuine renumbering) and each of feature 023's
  seven refusals print the same bytes and exit the same way before and after, on fixtures and on a clone of each adopted
  project.
- **SC-002**: Every state of FR-006 has a `fail` that fails on the parent commit for the stated reason and passes after,
  and a `pass` that passes on both.
- **SC-003**: After a push that succeeded and a failed ledger read, a reader of the refusal alone can tell that the claim
  may be live and what to check; no fixture shows it saying "nothing was claimed" in that state.
- **SC-004**: A rejected push ends after one push attempt and allocates no further number; a genuine rival still renumbers.
- **SC-005**: The coverage report shows no unowned site in `scripts/claim-feature.ps1`; the exempt count rises only with a
  written reason; the full harness passes with every pre-existing case unchanged.

## Decisions for the owner

Each has a recommendation. **Decided by the owner (anas.m, 2026-10-16): D1 A, D2 A, D3 A**, as recommended.

- **D1 - how far the loop is widened.** (A, recommended) The read failure (FR-001/002), the rejected push (FR-003) and
  the withdrawal and re-fetch (FR-004): one loop, one species, and the withdrawal failure is the only path that leaves a
  stale claim unreported. (B) Only the read failure and the rejected push; record the withdrawal and re-fetch as open. B is
  smaller and keeps the feature in the lane of the GAP-036 row as written, at the cost of leaving two silent paths in the
  same ten lines.
- **D2 - what a rejected push does.** (A, recommended) Refuse at once with git's text: a rejection is the remote's answer,
  and three more pushes of a renumbered branch repeat it. (B) Retry the same number once before refusing, for a transient
  failure; this keeps a retry the script does not make today and cannot tell transient from permanent.
- **D3 - the phase shape.** (A, recommended) Two phases: the ledger read and the rejected push first (User Stories 1 and 2,
  with the harness recipe field), the withdrawal, the re-fetch and the adopter note second. (B) One phase, if D1 is B.

## Assumptions

- The harness reaches this script the way feature 023 did: the working directory set to the fixture, a stub
  `create-new-feature.ps1` where a claim should succeed, and the recipe fields that exist (`noGit`, `uncommitted`, `origin`,
  `checkout`, `originPushUrl`). A way to fail `git ls-remote` after a successful fetch or push is not built today; building
  it is part of FR-006 and a plan decision (for example a wrapper on `PATH` that fails the nth call), which is why no state
  of this feature has a fixture yet.
- The refusal text stays on the error stream through the script's `Stop-Refused`, as in feature 023.
- Left as stated limits, not changed here: the `git for-each-ref` in `Get-NextFreeNumber` (line 58), because the remote
  ledger and `specs/` still bound the number it chooses, so a failure there can lower the choice but not below a number the
  ledger or `specs/` shows; the local `git branch -m` and `Rename-Item` of the renumbering; a push that failed but landed;
  and `scripts/claim-feature.ps1`'s interaction with the stock `create-new-feature.ps1`, which feature 023 covers.
- The script is kit-owned and flows down verbatim; no adopted project has a verdict from it to move.
- The throw's exit code and the launcher's reading of it are measured in phase 1, before the change, not assumed.
