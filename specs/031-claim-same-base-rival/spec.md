# Feature Specification: claim-feature.ps1 tells a same-base rival from our own claim

**Feature Branch**: `031-claim-same-base-rival`
**Created**: 2026-10-16
**Amendment approved by**: anas.m, 2026-10-16
**Status**: Approved 2026-10-16 (owner: anas.m) <!-- D1 B', D2 A, D3 A -->
**Owner decisions**: anas.m, 2026-10-16 — D1 B' (read the push's own created-or-up-to-date status; the first decision, B the push lease, was measured not to refuse a same-sha push and was replaced), D2 A (the loser renumbers through the existing loop and withdraws nothing), D3 A (two phases)
**Delivery Level**: Standard
**Rationale Rule**: 1
**Input**: User description: "GAP-037: claim-feature.ps1 must tell a same-base rival (a foreign branch of our own name at our own sha) from our own claim, so two claimants of one number and short name cannot both believe they hold it. The shape (unique claim tip, push lease on the absent ref, refusal before the push) is an open decision for the owner."

## Background

`scripts/claim-feature.ps1` is the command that takes a feature number: the branch pushed to `origin` **is** the claim
(`docs/sdlc/branch-strategy.md`, "Number Allocation"). Feature 030 made its ledger read and refused push named states and
decided "landed" by commit, not by branch name, after its phase 3 review found that a branch of our name is not
necessarily ours (finding F1, `specs/030-claim-ledger-read-named-state/ai-code-review-phase3-fix.md`, "Residual risk").
It stated the case where the foreign branch and ours share a sha as a limit and left it open (GAP-037 in `docs/roadmap.md`).

`specs/031-claim-same-base-rival/notes.md` measures that case on a throwaway `origin` before any change:

| Question | Measured |
|---|---|
| Does a claim commit anything? | No. The new branch tip is `main`'s sha and `specs/NNN-name/` is untracked. |
| What does a second push of the same name and sha do? | `Everything up-to-date`, exit 0. |
| What does the script conclude? | `CLAIMED: 031-same-name (pushed to origin - the claim is live)`, exit 0, no warning, with a rival's branch already on `origin`. |

Two claimants who each allocate the same number and short name from the same `main` commit therefore each end with a
success message for one branch at one sha. The script cannot see it, for two reasons: the rival filter excludes the
branch's own name (`$_ -ne $branch`, `scripts/claim-feature.ps1:155`), and the commit comparison of feature 030
(`:162-165`) runs only after a push that exited non-zero, and would be equal here in any case.

The harm is not a wrong word on a screen: both owners then work on one branch under one number, each believing it is
theirs, and find out at merge, which `docs/sdlc/team-workflow.md` calls a process failure.

**Why this is Standard and not Micro.** The work is `scripts/claim-feature.ps1`, `tests/enforcement/rules.json`,
fixtures that plant a same-name, same-sha branch on `origin` just before our push, and a fail and a pass fixture per
state, each fixture being three files. A Micro feature's Territory is at most five literal file paths
(`scripts/enforcement-pack.ps1`, MicroLane); the fixtures alone exceed that.

**Amendment approved by**: anas.m, 2026-10-16

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Only one of two same-name claimants holds the claim (Priority: P1)

Two developers run `claim-feature.ps1 -ShortName <same>` from the same `main` commit before either has pushed. One push
reaches `origin` first. The other claimant is told it did not get the claim, and what happens next, in the script's own
words, instead of being told its claim is live.

**Why this priority**: it is the one state in which the script gives a wrong verdict. Every other limit feature 030 stated
makes a message thinner; this one makes two people believe they own the same number.

**Independent Test**: a fixture in which a branch of our own name at our own sha is on `origin` before our push; the `fail`
(the parent commit) prints `CLAIMED:` and exits 0, the `pass` (this feature) does not.

**Acceptance Scenarios**:

1. **Given** a branch of our name at our sha is already on `origin`, **When** our claim reaches its push, **Then** the script
   does not report our claim as live, says a claimant of the same number and short name got there first, and exits as the
   decided shape requires (Decision D1, D2).
2. **Given** the same state, **When** the script ends, **Then** it did not delete, move or rewrite the foreign branch (it is
   not ours; feature 030's rule that a foreign branch of our name is never withdrawn holds).
3. **Given** no branch of our name on `origin`, **When** we claim, **Then** the claim succeeds with the output it has today.
4. **Given** a genuine rival with the same number and a different short name, **When** we claim, **Then** the script behaves
   as it does today (renumber after the rival check).

### User Story 2 - The new state is proved, and adopters are told (Priority: P2)

**Amendment approved by**: anas.m, 2026-10-16

The state has a fixture that fails on the parent commit for the stated reason, an owner in `tests/enforcement/rules.json`,
and a flow-down note adopters can act on.

**Why this priority**: GAP-029, GAP-031 and GAP-036 stayed open for lack of a way to reach the state. The fix is not finished
until a fixture can plant it.

**Independent Test**: the coverage report lists the new rule(s), each with a `fail` that fails on the parent commit and a
`pass` that passes on both.

**Acceptance Scenarios**:

1. **Given** a fixture whose stub creates a same-name, same-sha branch on `origin` after the ledger read and before our push,
   **When** the claim runs, **Then** the rival is planted by the case itself (the harness gains no recipe field), and the case
   is inventoried with its own rule.
2. **Given** the claim paths that exist today (success with a remote, none, `-NoPush`, a renumber after a genuine rival, the
   seven refusals of feature 023, the named states of feature 030), **When** the full harness runs, **Then** every
   pre-existing case passes unchanged.
3. **Given** an adopted project, **When** it updates the kit, **Then** `adoption/updating.md` says what changed, that the
   script flows down verbatim, and what the project may newly see.

### Edge Cases

**Amendment approved by**: anas.m, 2026-10-16

- A claim whose push landed and whose branch of our name on `origin` is at our sha **because we pushed it** (no rival): the
  claim succeeds as today. The new check must not read our own push as a rival's.
- A same-name branch on `origin` at a **different** sha: feature 030's existing handling (a foreign branch is not ours,
  never withdrawn) is unchanged.
- A same-name, same-sha branch that appears **between** the ledger read and our push, and one that exists **before** the
  ledger read, are different states: before the read, allocation already sees the name and picks the next number, so the
  race exists only for the window after the read. The plan names which of them each shape covers.
- **Stated limit.** Two claimants that create the ref at the same moment, where our push then exits non-zero, are not told apart:
  the same-name test needs an exit 0, and feature 030's landed-by-commit rule sees the same sha and reads the claim as ours, with its
  warning and exit 0. The window is the push itself; it was traced in the phase 1 review (finding F2), not reproduced, and is not
  changed here.
- `-NoPush` and no `origin` never reach the push and are unchanged.
- `-Json` does not change: there is no JSON error object today and none is added.

## Level Rationale *(mandatory — answers the four Critical triggers, in writing)*

- **domain-invariants**: does not apply — the kit has no domain-invariants pack; this is a command-line script that allocates a branch name.
- **irreversible-data**: does not apply — the script creates a branch and a spec directory and may delete its own just-pushed branch when it loses a race; this feature changes which claimant is told it won, and never makes the script delete a branch it did not push.
- **authn-authz-payment**: does not apply — no authentication, authorization or payment is touched.
- **auditable-evidence**: does not apply — a claim is a coordination signal on a remote, not evidence of record for any audit or contract.

## Requirements *(mandatory)*

### Functional Requirements

**Amendment approved by**: anas.m, 2026-10-16

- **FR-001**: When a branch of our own name already on `origin` at our own sha was pushed by another claimant, the script MUST
  NOT report our claim as made. It MUST say so in its own words, naming the branch, and MUST end as Decision D2 decides. A branch
  of our name at another sha is not this state: it ends as feature 030's rejected-push refusal, unchanged.
- **FR-002**: The script MUST NOT delete, move or rewrite a branch it did not push, in this state or any other.
- **FR-003**: A claim with no branch of our name on `origin` before our push, and a claim whose only branch of our name is
  the one we just pushed, MUST print exactly what it prints today and exit 0. The `-Json` object keeps its shape and fields.
- **FR-004**: The seven refusals of feature 023 and the named states of feature 030 MUST keep their text, stream and exit
  code. A genuine rival of another short name keeps its renumbering loop. The one exception is the layout of git's own
  text quoted inside feature 030's rejected-push refusal, which may change because the push reads git's machine-readable status;
  the script's own sentences are unchanged.
- **FR-005**: The state MUST gain a failing and a passing fixture that differ only in the condition under test, written first
  and shown failing on the parent commit, each new rule inventoried in `tests/enforcement/rules.json` with its anchor. The
  fixture MUST plant a same-name, same-sha branch on `origin` between the ledger read and our push (the stub
  `create-new-feature.ps1` may do it, as in feature 030's `CLF-017`; a harness recipe field is built only if the plan finds the
  stub cannot); where a state cannot be reached the plan MUST exempt it with a written reason of the kind feature 015 FR-004 requires.
- **FR-006**: No other behaviour changes: preflight order, ledger allocation, delegation to the stock `create-new-feature.ps1`,
  and the warnings are as they were. The two other feature 030 residuals (an unreadable ledger after a failed push, and the
  unchecked `git for-each-ref` in `Get-NextFreeNumber`) are not changed here.
- **FR-007**: `adoption/updating.md` MUST gain a flow-down note in the shape of feature 030's, and `docs/roadmap.md` MUST close
  GAP-037, record the decision and mark this feature's row `shipped`.

### Key Entities

- **Claim tip**: the commit a claim branch points at when it is pushed. Today it is `main`'s own sha, so every claim of a
  given name from a given `main` is the same ref value.
- **Same-base rival**: a branch of our own name on `origin` that another claimant pushed, whose sha equals ours. Today it is
  indistinguishable from our own push.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In the measured race (a rival pushes the same name and sha just before our push), the script no longer prints
  `CLAIMED:` for a branch it did not push, on a fixture and on the throwaway `origin` of `notes.md`.
- **SC-002**: A claim without a rival, with a remote, none, `-NoPush`, and one genuine renumbering, prints the same bytes and
  exits the same way before and after, on fixtures and on a clone of each adopted project.
- **SC-003**: The new rule has a `fail` that fails on the parent commit for the stated reason and a `pass` that passes on
  both; the coverage report shows no unowned site; the exempt count rises only with a written reason; the full harness passes
  with every pre-existing case unchanged.

## Decisions for the owner

**Amendment approved by**: anas.m, 2026-10-16

Each has a recommendation. **Decided by the owner (anas.m, 2026-10-16): D1 B', D2 A, D3 A.** D1 was first decided as B and amended to B' the same day, after the plan's measurement.

- **D1 - the shape.** (A) A unique claim tip: the claim makes a commit carrying the claimant, so two claimants' branches
  of the same name are different refs and the second push is rejected as non-fast-forward; this reuses feature 030's
  rejected-push handling and needs no new git feature, but it changes what a claim *is* (a branch with a commit of its own)
  and the stock `create-new-feature.ps1` is not ours to edit. (B, recommended) A push lease on the absent ref
  (`--force-with-lease=<ref>:`): git refuses the push if the name already exists on `origin`, whatever its sha; the claim
  stays uncommitted and the change is in the script alone; the plan must measure that git version(s) in use refuse it.
  (C) A refusal before the push when the name is on the ledger: **measured not to suffice alone**, because the rival
  pushes after the ledger was read; it is a candidate only as a backstop beside A or B.
  **Measured at plan time (`notes.md`): B does not refuse a push whose sha already equals the remote's: git returns
  `Everything up-to-date` before it looks at the lease, so B was replaced by B'.** (B', decided) The script reads
  `git push --porcelain`: the claimant that creates the ref sees `*  [new branch]`; one whose branch already existed at its
  sha sees `=  [up to date]` and is the loser. The claim stays uncommitted and the change is in the script alone.
- **D2 - what the loser does.** (A, recommended) Treat it as a lost race: renumber and push again through the existing loop,
  withdrawing nothing, since the rival's branch is not ours. (B) Refuse at once and say to claim again, as feature 030 does
  for a rejected push with no rival.
- **D3 - the phase shape.** (A, recommended) Two phases: the shape and its fixtures first (User Story 1), the flow-down note, the roadmap and the digest second (User Story 2). (B) One phase.

## Assumptions

**Amendment approved by**: anas.m, 2026-10-16

- The harness reaches this script the way features 023 and 030 did: the working directory set to the fixture, a stub
  `create-new-feature.ps1` where a claim should succeed, and the recipe fields that exist (including feature 030's
  `originRivalOnPush`, `originFailCall`, `originDenyDeletes`). No recipe field is built: the fixture's stub `create-new-feature.ps1` plants the rival, as in feature 030's `CLF-017`.
- The script is kit-owned and flows down verbatim; no adopted project has a verdict from it to move.
- The refusal and warning text stay on the streams they use today, through the script's `Stop-Refused` and `Write-Warning`.
- The measured behaviour (`notes.md`) holds for the git in use here; the first task of the plan re-measures the chosen shape
  before any change to the script, as feature 030 measured its states first.
