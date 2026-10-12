# Feature Specification: claim-feature.ps1's refusals reach their own message and exit

**Feature Branch**: `023-claim-feature-refusals`
**Created**: 2026-10-12
**Status**: Draft
**Delivery Level**: Standard
**Rationale Rule**: 1
**Input**: User description: "GAP-031: scripts/claim-feature.ps1 reports seven refusals with Write-Error under ErrorActionPreference = 'Stop', so the exit 1 after each is unreachable. The same defect feature 022 closed in territory-check.ps1 (GAP-029). Give each refusal its own message and exit 1, prove each with a fixture, and tell adopters."

## Background

`scripts/claim-feature.ps1` is the command every team member runs to take a feature number (`docs/sdlc/branch-strategy.md`,
"Number Allocation"). It runs under `$ErrorActionPreference = 'Stop'` and reports seven refusals with `Write-Error`
followed by `exit 1`. Under `Stop`, `Write-Error` is terminating: the script dies at the write, the `exit 1` beneath it is
unreachable, and the exit code a caller sees is PowerShell's or the last native command's, not the script's. Measured on
`territory-check.ps1` (feature 022), the same shape gave exit 97 through the enforcement harness's launcher for one
refusal and a leaked 128 (the last `git` call's code) for three, and `pwsh -File` at a terminal already exited 1 for all four.
The mechanism is the same here; it is not yet measured on this script, and the first phase measures it before anything
changes. What is missing is a script that refuses in its own words and exit and can be proved to.

The seven sites, as of `main` at `12e9a1f`:

| Line | Refusal | Condition |
|---|---|---|
| 72 | `Not inside a git repository.` | the working directory is not in a git repository |
| 79 | `Working tree is not clean — commit or stash before claiming a feature.` + the dirty paths | `git status --porcelain` is not empty |
| 84 | `Claims start from main (currently on '<branch>'). Checkout main first.` | the current branch is not `main` |
| 96 | `git fetch origin failed — cannot claim against an unreachable ledger.` | `origin` is configured and the fetch fails |
| 108 | `Stock script not found: <path> — partial kit install? Run scripts/doc-lint.ps1.` | `.specify/scripts/powershell/create-new-feature.ps1` is absent |
| 112 | `create-new-feature.ps1 failed:` + its output | the stock script exits non-zero |
| 135 | `Lost the allocation race 3 times — renumber manually (docs/sdlc/branch-strategy.md, Number Allocation).` | a rival claim with the same number is on `origin` after each of three pushes |

None has a fixture, and `claim-feature.ps1` is not one of the harness's nine grading scripts, so none appears in
`tests/enforcement/rules.json` or in the coverage report.

**Why this is Standard and not Micro.** The roadmap row named Micro as a candidate, to be checked when the spec was
written. It does not fit: a Micro feature's Territory is at most five *literal file paths* (no globs, no subtrees;
`scripts/enforcement-pack.ps1`, MicroLane), and the work is `scripts/claim-feature.ps1`, `tests/enforcement/rules.json`,
`tests/enforcement/emission-idioms.json`, the coverage test's list of grading scripts, and a fail and a pass fixture per
reachable site, each fixture being three files, several carrying a stub of the stock `create-new-feature.ps1`. The
fixtures alone exceed five files.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A refused claim says why and exits 1 (Priority: P1)

A developer runs `claim-feature.ps1` in a state it refuses. The message is the one the script has always printed, and the
process exits 1 because the script exited, not because PowerShell threw.

**Why this priority**: a wrapper, a CI job or an agent that reads the exit code and the message gets neither from a
terminating `Write-Error`; for the script that allocates feature numbers, a refusal read wrongly is a claim not taken, or
taken twice.

**Independent Test**: a fixture per reachable refusal; the `fail` case shows the message and exit 1 and not the launcher's
exit 97 or 128.

**Acceptance Scenarios**:

1. **Given** a directory that is not a git repository, **When** `claim-feature.ps1 -ShortName x "y"` runs, **Then** it
   prints `Not inside a git repository.` and exits 1.
2. **Given** a repository with an untracked or modified file, **When** it runs, **Then** it prints `Working tree is not
   clean — commit or stash before claiming a feature.` followed by the dirty paths, one per line, and exits 1.
3. **Given** a clean repository on a branch other than `main`, **When** it runs, **Then** it prints `Claims start from
   main (currently on '<branch>'). Checkout main first.` and exits 1.
4. **Given** a clean repository on `main` whose `origin` points at a path that does not exist, **When** it runs, **Then**
   it prints `git fetch origin failed — cannot claim against an unreachable ledger.` and exits 1.
5. **Given** a clean repository on `main` that has no `create-new-feature.ps1` under `.specify/scripts/powershell/`,
   **When** it runs, **Then** it prints `Stock script not found: <path> — partial kit install? Run scripts/doc-lint.ps1.`
   and exits 1.
6. **Given** a stock script that exits non-zero, **When** it runs, **Then** it prints `create-new-feature.ps1 failed:`
   followed by that script's output and exits 1.
7. **Given** any of the above, **When** it runs with `-Json`, **Then** the refusal is as in 1 to 6: a message on the error
   stream and exit 1, with no JSON object (as today).

---

### User Story 2 - The refusals are proved, not assumed (Priority: P1)

Seven rules the kit ships are unproved because the harness has never run this script. Each reachable refusal gets a
failing and a passing fixture; the one that is not reachable is accounted for in writing.

**Why this priority**: the territory-check refusals stayed unproved until feature 022 for the same reason (GAP-029). A fix
without fixtures is the state that produced the defect.

**Independent Test**: the coverage report names `claim-feature.ps1` and shows each of its emission sites owned by a
fixtured rule, or declared exempt with a written reason.

**Acceptance Scenarios**:

1. **Given** the fixtures for the six reachable refusals, **When** the harness runs them on the parent commit, **Then**
   each `fail` fails for the stated reason (the launcher's line, exit 97 or 128) and each `pass` passes.
2. **Given** the change, **When** the harness runs, **Then** every `fail` shows its message and exit 1 and every `pass`
   shows a successful claim, differing from its `fail` in the one condition under test.
3. **Given** the seventh refusal (lost the race three times), **When** the plan is written, **Then** it is either
   fixtured or exempt with a written reason, and the coverage report shows which.

---

### User Story 3 - Adopters are told what changes (Priority: P2)

`scripts/claim-feature.ps1` flows down verbatim. An adopter reading the update note learns that a claim that already
printed a message and exited 1 at a terminal still does, now from the script itself.

**Why this priority**: it is a kit-owned script; the update changes what a caller observes in-process and through a
wrapper, and says nothing about a verdict because the script has none.

**Independent Test**: the update note exists in the shape of feature 022's; a claim run on a clone of an adopted project,
with `-NoPush`, prints what it printed before.

**Acceptance Scenarios**:

1. **Given** the update note, **When** an adopter reads it, **Then** it says what flows down, what a wrapper may newly
   observe (the message and exit 1 from the script, not a PowerShell error record), and what does not change.
2. **Given** a clone of each adopted project, **When** a successful claim is run with `-NoPush` before and after the
   update, **Then** the output differs only in the branch the clone allocates, or the note says exactly where it does.

---

### Edge Cases

- A successful claim, the no-remote claim, a `-NoPush` claim and a claim that loses the race once and renumbers print what
  they print today, byte for byte, and exit 0.
- The messages of sites 79 and 112 carry text the script did not write (the dirty paths, the stock script's output);
  that text is preserved as the script emits it today, including its line breaks.
- The seventh refusal withdraws the remote branch it pushed (`git push origin --delete`) before it renumbers; losing the
  race the third time leaves no claim of ours on `origin`, and that stays true after the change.
- `-Json` does not change the refusals: there is no JSON error object today and none is added.

## Level Rationale *(mandatory — answers the four Critical triggers, in writing)*

- **domain-invariants**: does not apply — the kit has no domain-invariants pack; this is a command-line script that allocates a branch name.
- **irreversible-data**: does not apply — the script creates a branch and a spec directory, and may delete its own just-pushed branch when it loses a race; nothing is migrated, dropped or rewritten, and this feature changes how it refuses, not what it does.
- **authn-authz-payment**: does not apply — no authentication, authorization or payment is touched.
- **auditable-evidence**: does not apply — a claim is a coordination signal on a remote, not evidence of record for any audit or contract.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Each of the seven refusals of `scripts/claim-feature.ps1` MUST print its existing message, unchanged in
  wording and in any embedded text it carries, and MUST end with exit 1 reached by the script itself, so that a caller and
  the enforcement harness observe the message and exit 1 and never exit 97 or a leaked exit code of a git call.
- **FR-002**: A claim that succeeds (with a remote, with no remote, with `-NoPush`, and after renumbering) MUST print
  exactly what it prints today and exit 0 (SC-001). The `-Json` object keeps its shape and its fields.
- **FR-003**: Each refusal that a fixture can reach (sites 72, 79, 84, 96, 108, 112) MUST gain a failing and a passing
  fixture that differ only in the condition under test, written first and shown failing on the parent commit, each new
  rule inventoried in `tests/enforcement/rules.json` with its anchor.
- **FR-004**: The seventh refusal (site 135) MUST NOT be left unowned: the plan either fixtures it or exempts it with a
  written reason of the kind feature 015 FR-004 requires, and the coverage report shows which.
- **FR-005**: The coverage sweep MUST see `scripts/claim-feature.ps1`: it has an entry in
  `tests/enforcement/emission-idioms.json`, the coverage test's list of grading scripts includes it, and the report counts
  its sites.
- **FR-006**: No other behaviour of the script changes: the preflight order, ledger allocation, the delegation to the
  stock script, the push and renumber loop, the warnings and the `-Json` object are as they were.
- **FR-007**: `adoption/updating.md` MUST gain a flow-down note in the shape of feature 022's (what was wrong, what it does
  now, what flows down, what may newly be seen, what does not change, what was measured, what to do), and
  `docs/roadmap.md` MUST close GAP-031, record the decision, and mark this feature's row `shipped`.

### Key Entities

- **Refusal**: a condition under which `claim-feature.ps1` allocates and creates nothing and says so with its message and
  exit 1. A refusal is an error, not a verdict word; the script has no verdicts.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A successful claim (with a remote, none, `-NoPush`, and one renumbering) prints the same bytes and exits 0
  before and after, on fixtures and on a clone of each adopted project.
- **SC-002**: Each of the six reachable refusals has a `fail` that fails on the parent commit for the stated reason and
  passes after, and a `pass` that passes on both.
- **SC-003**: The coverage report lists `claim-feature.ps1` with no unowned site; the exempt-rule count rises by at most one
  (site 135), and only with a written reason.
- **SC-004**: The full harness passes with every pre-existing case unchanged.

## Assumptions

- The harness reaches this script the way it reaches `territory-check.ps1`: with the working directory set to the fixture
  (the script has no `-Root`), the fixture carrying a stub `create-new-feature.ps1` where a claim should succeed or fail on
  purpose. Recipe fields that exist today (`noGit`, `uncommitted`, `origin`, `checkout`, `copy`) reach sites 72, 79, 84, 96,
  108 and 112; none reaches 135, which needs a rival claim to appear between allocation and push.
- The refusal text stays on the error stream, as in feature 022, so a human at a terminal sees the same stream as before.
  Whether the helper is a second copy of `Stop-Refused` or a shared one is a plan decision.
- Tip-of-spec questions left to the plan: how site 135 is accounted for (fixture by a means the recipe cannot offer today,
  or an exemption), and whether the helper is shared between `territory-check.ps1` and this script.
- The script is kit-owned and flows down verbatim; no adopted project has a verdict from it to move.
