# Feature Specification: update-kit.ps1 names a recorded kit commit its kit clone does not know

**Feature Branch**: `033-update-kit-unknown-recorded-commit`
**Created**: 2026-10-16
**Amendment approved by**: anas.m, 2026-10-16
**Status**: Approved 2026-10-16 (owner: anas.m) <!-- D1 A, D2 A, D3 A -->
**Owner decisions**: anas.m, 2026-10-16 — D1 A (every surgical file reported `no baseline - review all` with one line naming the unknown commit, the run otherwise as today), D2 A (the surgical pass and the one cause line; the verbatim conflicts keep their wording), D3 A (two phases)
**Delivery Level**: Standard
**Rationale Rule**: 1
**Input**: User description: "GAP-039: update-kit.ps1 names a recorded kit commit that is unknown to the kit clone instead of printing an empty surgical report: git log recorded..HEAD with 2>$null fails, the surgical section vanishes, and the record then advances past the lost report."

## Background

`scripts/update-kit.ps1` brings an adopted project up to a kit clone's HEAD. It copies the verbatim files, never touches the surgical
ones (the project-filled documents), and **reports** the upstream commits that changed each surgical file since the kit commit the
project recorded in `.kit-version`. That report is delivered once: a real run advances `.kit-version` to the kit's HEAD, and the
report is documented as recoverable only with `git log <old recorded>..<new recorded>` in the kit clone
(`adoption/updating.md`, `specs/004-kit-update-channel/`). The surgical pass reads the log with
`git -C $Kit log "$recordedCommit..HEAD" --oneline -- <path> 2>$null` (`scripts/update-kit.ps1:258`) and counts the lines; a
failed `git log` is an empty list, which is also what a file with no upstream change produces.

The recorded commit is **not in the kit clone** when the clone is shallow, was rewritten, or is another fork than the one that
last updated the project. Then `git log` fails, the surgical section is not printed at all, and the run ends as if there was
nothing to report. `specs/033-update-kit-unknown-recorded-commit/notes.md` measures it on a clone of an adopted project:

| Probe (a clone of FitForge, the kit as it stands, `update-kit.ps1 -Target <clone>`) | Surgical section | Verbatim files | Exit |
|---|---|---|---|
| `.kit-version` names a commit the kit clone has | `Surgical - upstream changes, never applied (3)`, each with `upstream commits since your recorded kit version` | the usual | 2 |
| `.kit-version` absent | `Surgical - ... (20)`, each `no baseline - review all` | the usual | 2 |
| `.kit-version` malformed (not JSON) | the same as absent: `(20)`, `no baseline - review all` | the usual | 2 |
| `.kit-version` names a commit the kit clone does **not** have | **no Surgical section at all** | 21 conflicts, each `differs - no baseline (unknown provenance)` | 2 |
| the same, a real run | none | the same 21 conflicts | 2; `.kit-version` is rewritten to the kit's HEAD |
| the same, `-Json -DryRun` | `surgical` has **0** entries | `conflicts` has 21 | n/a |

The last three rows are the defect. The verbatim files do notice (they cannot be compared to a baseline, so they are conflicts), but
the surgical files, which are the ones carrying project-filled content, are silently reported as unchanged; and the record then
advances past the report, which is delivered once. In the case that no verbatim file differs (a project whose verbatim files are
already at the kit's current content) the run would exit 0, also silent. The sibling case, no `.kit-version`, already says
`no baseline - review all`: the unknown-commit case is the one that disagrees with it.

**Why this is Standard and not Micro.** The work is `scripts/update-kit.ps1`, a way to test it (the fixture harness runs no
`update-kit.ps1` case today), and the fixtures; the tests alone exceed a Micro feature's Territory (at most five literal file
paths, `scripts/enforcement-pack.ps1`, MicroLane).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - An unknown recorded commit is reported, not read as "nothing changed" (Priority: P1)

An adopter (or an agent acting for one) runs `update-kit.ps1` against a project whose `.kit-version` names a commit the kit clone
cannot find. The run says so, in its own words, and the surgical files are reported for review the way they are when there is no
`.kit-version` at all.

**Why this priority**: the surgical report is the only place an adopter learns that a project-filled document (the constitution
slots, the gate commands, the rulebooks) has an upstream change to hand-apply, and it is delivered once.

**Independent Test**: a fixture whose `.kit-version` names an unknown commit; the `fail` (the parent commit) prints no Surgical
section, the `pass` (this feature) prints every surgical file as needing review, and says why.

**Acceptance Scenarios**:

1. **Given** a project whose recorded kit commit the kit clone does not have, **When** `update-kit.ps1` runs (dry run, real run
   and `-Json`), **Then** every surgical file is reported `no baseline - review all` and one line says which recorded commit is
   unknown to the kit clone, and the exit code is the one the existing rules give (2 while anything is pending).
2. **Given** a project whose recorded commit the kit clone has, **When** it runs, **Then** the output and exit are those of today.
3. **Given** no `.kit-version`, or one that is not valid JSON, **When** it runs, **Then** the output and exit are those of today.

### User Story 2 - The state is proved, and adopters are told (Priority: P2)

The state has a fixture that fails on the parent commit for the stated reason, and a flow-down note adopters can act on.

**Why this priority**: the harness runs no `update-kit.ps1` case today, which is how the state stayed unreachable; the fix is not
finished until a test reaches it.

**Independent Test**: the new test shows the fail on the parent commit and the pass after, and the full harness passes unchanged.

**Acceptance Scenarios**:

1. **Given** a way to run `update-kit.ps1` against a kit repository and a target built with plain git, **When** the recorded commit
   is unknown, known, absent and malformed, **Then** each state has its own expectation, written by hand.
2. **Given** an adopted project, **When** it updates the kit, **Then** `adoption/updating.md` says what changed, that the script
   flows down verbatim, and what the project may newly see.

### Edge Cases

- A recorded commit that exists in the kit clone but is not an ancestor of HEAD (another branch): `git log recorded..HEAD` works
  and lists the commits not reachable from it; unchanged here.
- A shallow kit clone whose boundary lies beyond the recorded commit is the unknown-commit state; the message names it as a
  possible cause.
- `-DryRun` writes nothing and `-Json` prints no prose: the surgical entries carry the same note, and the cause line is text-mode
  only unless the plan decides otherwise.
- The verbatim files' `differs - no baseline (unknown provenance)` conflicts are unchanged: they already say there is no baseline.
- The preflight refusals (kit not a repository, target dirty, target missing essentials), `-Force` and `-Kit`/`-Target` do not change.

## Level Rationale *(mandatory — answers the four Critical triggers, in writing)*

- **domain-invariants**: does not apply — the kit has no domain-invariants pack; this is a command-line script that copies files and prints a report.
- **irreversible-data**: does not apply — the script copies verbatim files and writes `.kit-version`, both reviewable in the target's git; this feature changes what the report says and never what the script writes.
- **authn-authz-payment**: does not apply — no authentication, authorization or payment is touched.
- **auditable-evidence**: does not apply — the surgical report is guidance printed to a terminal, not evidence of record for an audit or contract.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: When the recorded kit commit is not a commit in the kit clone, the surgical pass MUST NOT treat the failed
  `git log` as "no upstream commits". Every surgical file MUST be reported as it is when `.kit-version` is absent (Decision D1),
  and one line MUST name the recorded commit and say the kit clone does not know it (possibly a shallow or rewritten clone, or
  another fork).
- **FR-002**: A recorded commit the kit clone has, an absent `.kit-version` and an unparseable one MUST keep today's output and exit code.
- **FR-003**: The verbatim pass MUST keep its output: the files that cannot be compared to a baseline stay conflicts with their
  current reason.
- **FR-004**: `-Json` MUST keep its keys (`applied`, `surgical`, `conflicts`, `dryRun`, `result`); its `surgical` array carries the
  entries of FR-001.
- **FR-005**: The state, and each state of FR-002, MUST gain a test that fails on the parent commit for the stated reason and
  passes after, written first, expectations by hand, run on a kit repository and a target built with plain git (the harness has
  no `update-kit.ps1` case; the plan decides whether it is a Pester file like `ScopeLib.Tests.ps1` or a harness extension).
- **FR-006**: No other behaviour changes: the preflight refusals, the three-way verbatim rule, `-Force`, the recorded-commit write,
  the adoption doctor verdict and the exit codes are as they were.
- **FR-007**: `adoption/updating.md` MUST gain a flow-down note in the shape of feature 032's, and `docs/roadmap.md` MUST close
  GAP-039, record the decision and mark this feature's row `shipped`.

### Key Entities

- **Recorded kit commit**: the `kitCommit` of the project's `.kit-version`, the baseline of the surgical report. It is unknown when
  the kit clone has no such commit.
- **Surgical report**: the per-file list of upstream commits since the recorded commit, delivered once per update.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: With a recorded commit the kit clone does not have, a dry run and a real run print every surgical file as needing
  review and the line naming the unknown commit, and `-Json` carries the same entries; on the measured clone the 0 entries
  become 20.
- **SC-002**: A recorded commit the kit clone has, an absent `.kit-version` and a malformed one print the same bytes and exit the
  same way before and after, on the test and on a clone of each adopted project.
- **SC-003**: Every state of FR-005 has a test that fails on the parent commit for the stated reason and passes after; the full
  harness passes with every pre-existing case unchanged.

## Decisions for the owner

**Amendment approved by**: anas.m, 2026-10-16

Each has a recommendation. **Decided by the owner (anas.m, 2026-10-16): D1 A, D2 A, D3 A**, as recommended.

- **D1 - what the run does about an unknown recorded commit.** (A, recommended) Report every surgical file `no baseline - review all`
  with one line naming the unknown commit, and go on as today (the record advances; exit 2 while anything is pending): the
  same as the absent `.kit-version`, non-blocking, the full backlog shown once. (B) Refuse with exit 1 and write nothing: the
  record never advances past a report that could not be computed, at the cost that an adopter with a shallow kit clone cannot
  update until the clone is deepened or `.kit-version` is deleted. (C) As A, but hold the record where it is: contradicts the
  documented ratchet fix (the record always advances, `fix/update-kit-version-ratchet`) and is not recommended.
- **D2 - how far it reaches.** (A, recommended) The surgical pass and the one cause line; the verbatim conflicts keep their
  wording. (B) Also change the verbatim conflicts' reason from `unknown provenance` to name the unknown recorded commit: more
  precise, but it changes text a wrapper may match.
- **D3 - the phase shape.** (A, recommended) Two phases: the script, the way to test it and the tests first (User Story 1 and the
  tests of User Story 2), the flow-down note, the roadmap and the measurement on clones second. (B) One phase.

## Assumptions

- The kit's tests today reach `update-kit.ps1` only through the adopted-project measurements recorded in the notes of features
  004, 007, 030 and 031; there is no case directory for it. A test is built here, and the plan chooses its shape. It builds a kit
  repository and a target with plain git, as `ScopeLib.Tests.ps1` builds its repository.
- The script is kit-owned and flows down verbatim; no adopted project has a verdict from it to move.
- The measured behaviour (`notes.md`) holds for the git in use here (2.55 for Windows); the plan's first task re-measures the
  chosen shape on the CI image's git before any change to the script.
- Left as stated limits, not changed here: the other `2>$null` reads of `update-kit.ps1` that are named already (the dirty-tree
  check refuses; the `git show` baseline read of a verbatim file falls to the `no baseline` conflict), and the `rev-parse HEAD`
  of the kit at `:186`, which is not guarded.
