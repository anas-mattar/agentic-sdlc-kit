# Implementation Plan: update-kit.ps1 names a recorded kit commit its kit clone does not know

**Branch**: `033-update-kit-unknown-recorded-commit` | **Date**: 2026-10-16 | **Spec**: specs/033-update-kit-unknown-recorded-commit/spec.md
**Input**: Feature specification (approved, anas.m, 2026-10-16; D1 A, D2 A, D3 A) + decisions P1–P7 below
**Gate Batching**: none
**Gate Certification**: user-run

## Summary

`scripts/update-kit.ps1` builds its surgical report from `git -C $Kit log "$recordedCommit..HEAD" --oneline -- <path> 2>$null`
(`:258`) and counts the lines. When the recorded kit commit is not in the kit clone, `git log` fails, the list is empty, and the file
is reported as unchanged; the run can end `Result: up to date`, exit 0, and a real run then advances `.kit-version` past a report
that was never made (measured twice, `notes.md`: on a clone of FitForge with 21 verbatim conflicts, and on a small kit and target
built with plain git where every verbatim file is current, which is the fully silent case). The plan decides, once, whether the
recorded commit is a commit of the kit clone (`git cat-file -e <sha>^{commit}`), and when it is not, reports every surgical file
exactly as the script does when `.kit-version` is absent (`no baseline - review all`, D1 A) with one line naming the commit. The
verbatim pass, `-Json`'s keys, the exit codes and the record write do not change. The test is a new Pester file that builds that
small kit and target (the harness has no `update-kit.ps1` case), so it does not depend on the depth of the CI checkout.

## Technical Context

**Language/Version**: PowerShell 7 (`pwsh`), git 2.55 (measured; the plan's first task re-measures on the CI image's git)
**Primary Dependencies**: none new
**Storage**: N/A (`.kit-version` is the existing record)
**Testing**: Pester 5 (`tests/enforcement/`, discovered by `Run-Tests.ps1`), real temporary git repositories, hand-written expectations
**Target Platform**: Windows and Linux runners (the kit's CI)
**Project Type**: governance kit; command-line script
**Performance Goals**: N/A (one extra `git cat-file` per run)
**Constraints**: every state of FR-002 prints today's bytes and exits with today's code (spec FR-002, FR-006)
**Scale/Scope**: one script, one new test file, one flow-down note

## Constitution Check

- [x] **Specification First (I)**: `spec.md` is approved (anas.m, 2026-10-16); this plan follows it; `tasks.md` follows.
- [ ] **Repository Separation (III)**: not applicable, the kit is one repository.
- [x] **Architecture Consistency (IV)**: no new script; `update-kit.ps1` keeps its structure and stays standalone; the test file follows `ScopeLib.Tests.ps1`.
- [ ] **Domain Invariants (V)**: not applicable, the template's slot is unfilled.
- [x] **Security (VI)**: the change adds a read and a line of output; nothing is written that was not, no secret is read.
- [ ] **External Integration Governance (VII)**: not applicable.
- [x] **Testing Requirements (VIII)**: every state of the spec has a test, hand-written, the failing ones shown failing on the parent commit (P5).
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI review with Reviewer Provenance.
- [x] **Controlled Delivery (X)**: two phases, one at a time. This changes the script that updates every adopted project, so the owner runs the gate: no batching, no ci-held.

**Phase sizing rule**: phase 1 changes the script and proves it, and is useful alone. Phase 2 is documentation, the roadmap and the
measurement on adopted-project clones, and depends on phase 1 only for the text it describes. Reverting 2, then 1, leaves a consistent kit.

**Post-design re-check**: no new violation. There is no decision left to the owner beyond approving the plan (Needs the owner).

## Decisions

- **P1 - is the recorded commit the kit's? (FR-001).** After `$recordedCommit` is read (`:183-186`), one call decides:
  `git -C $Kit cat-file -e "$recordedCommit^{commit}" 2>$null`, `$recordedKnown = ($LASTEXITCODE -eq 0)`, taken only when
  `$recordedCommit` is set (an absent or unparseable `.kit-version` leaves it null and is unchanged, FR-002). The first task measures
  the call on a full sha, an abbreviated sha, an unknown sha, a ref name and a non-string value, and on a shallow kit clone, and
  records which are accepted; the verbatim pass keeps reading its baselines with `git show`, so it needs no change (FR-003).
- **P2 - the surgical pass (D1 A).** The condition at `:254`, `if (-not $recordedCommit)`, becomes
  `if (-not $recordedCommit -or -not $recordedKnown)`: every surgical file gets the entry the absent case gives
  (`Note = 'no baseline — review all'`, no commits), so a dry run, a real run and `-Json` agree. A known recorded commit takes the
  `git log` branch, unchanged.
- **P3 - the one line (FR-001).** In text mode, once, before the sections:
  `NOTE: the recorded kit commit <sha> is not in the kit clone (a shallow or rewritten clone, or another fork), so every surgical file is listed as having no baseline - the verbatim files below could not be compared to a baseline either.`
  It is a single `Write-Host` and is printed whenever the commit is unknown, including when the manifest has no surgical file, because
  the verbatim pass lacks its baseline too. `-Json` keeps its keys (FR-004): the cause is not a key, and the surgical entries are
  those of the absent case.
- **P4 - what does not change (FR-002, FR-003, FR-006).** The preflight refusals, the three-way verbatim rule and its `differs - no baseline
  (unknown provenance)` conflicts, `-Force`, the `.kit-version` write (the record still advances to the kit's HEAD, the ratchet fix
  stands), the adoption doctor and the exit codes. With the entries of P2 the run is no longer `up to date` in the measured silent case:
  `$upToDate` already requires an empty surgical report, so it falls out; `exit 2` is the existing rule for a pending surgical file.
  The "delivered once" NOTE (`:320`) is now printed on a real run in this state, which is the warning that was missing.
- **P5 - tests (FR-005).** One new file, `tests/enforcement/UpdateKit.Tests.ps1`, a Pester `Describe` that builds in a temporary directory
  a small kit (a manifest with one verbatim and one surgical entry, a constitution with a version, two commits, the second changing the
  surgical file) and a target (the 14 kit-integrity essentials, the verbatim file at the kit's current content, the surgical file
  project-filled, a committed `.kit-version`), and runs `pwsh -NoProfile -File scripts/update-kit.ps1 -Kit <kit> -Target <target> ...`.
  Written first, shown failing on the parent commit:
  - the recorded commit is the kit's first: `Surgical ... (1)` with the upstream commit, exit 2 (a pass on both);
  - `.kit-version` absent, and malformed: `Surgical ... (1)`, `no baseline - review all`, exit 2 (a pass on both);
  - **the recorded commit is unknown**, a dry run: the surgical file is listed `no baseline - review all`, the P3 line is present, exit 2
    (on the parent: `Result: up to date`, exit 0);
  - the same real run: `.kit-version` advances, the "delivered once" NOTE is printed;
  - the same with `-Json -DryRun`: `surgical` has one entry, the keys are unchanged.
  The expectations are written by hand from the measurement in `notes.md`. The file is not a rule of `tests/enforcement/rules.json`
  (`update-kit.ps1` is not a grading script and is not in the emission sweep); the plan's first task checks the coverage tests
  still pass with the new `Write-Host`.
- **P6 - guidance and close (FR-007, phase 2).** `adoption/updating.md` gains a flow-down note in the shape of feature 032's (no digest
  marker: the adoption digest is at its 40-bullet bound); `docs/roadmap.md` closes GAP-039, records the decision and marks the row
  `shipped`; the measurement runs the changed script on clones of the three adopted projects with a known, an absent and an unknown
  recorded commit, before and after (SC-002, SC-001).
- **P7 - the other reads (spec Assumptions).** The dirty-tree check, the baseline `git show` of the verbatim pass and the unguarded
  `rev-parse HEAD` of the kit (`:186`, which the preflight already protects by refusing a non-repository) are left as stated.

## Phases

Detailed tasks and the per-phase **Territory** blocks are in `tasks.md`.

1. **Measure, prove, change.** Baseline harness and the probe of P1 on the parent commit and on the CI image's git; the P5 test first,
   shown failing on the unknown-commit cases; P1 to P4 in the script. Delivers User Story 1, the tests of User Story 2 and FR-001 to FR-006.
2. **Guidance, close, measure on clones.** P6, the measurement of SC-001 and SC-002 on a clone of each adopted project, and the full
   harness on an isolated checkout. Delivers User Story 2's guidance, FR-007 and SC-001 to SC-003.

## Project Structure

### Documentation (this feature)

```text
specs/033-update-kit-unknown-recorded-commit/
├── spec.md
├── plan.md              # this file
├── tasks.md
├── notes.md             # the measurements, the baseline, the test
└── checklists/requirements.md
```

No `research.md`, `data-model.md` or `contracts/`: the script has no data model, and its CLI contract
(`specs/004-kit-update-channel/contracts/update-kit-cli.md`) is unchanged: arguments, exit codes and the `-Json` keys stay, only a state
that printed `Result: up to date` or no Surgical section prints the absent case's entries and one line.

### Source Code (repository root)

```text
scripts/update-kit.ps1                    # phase 1: P1 to P4
tests/enforcement/UpdateKit.Tests.ps1     # phase 1: P5 (new)
adoption/updating.md                      # phase 2: flow-down note
docs/roadmap.md                           # phase 2
docs/digests/**                           # phase 2, only if a digest-marked document changes
```

**Structure Decision**: no new script and no new library file; `scripts/update-kit.ps1` ships verbatim, so `kit-manifest.json`
needs no entry. `tests/enforcement/rules.json` and `emission-idioms.json` are untouched unless the first task finds the sweep needs an entry.

## Testing Strategy

- The test is written first and shown failing on the parent commit for the unknown-commit cases, then the behaviour lands.
- The known, absent and malformed cases pass on both commits and pin the unchanged output of FR-002.
- The full harness runs on an isolated checkout of the final commit (feature 022's method); the new file is discovered by `Run-Tests.ps1`.
  The baseline (1828 on `8ae5794`, as feature 032 left it) is re-taken on the parent commit and recorded.
- The measurement of SC-002 runs the script before and after on a clone of each adopted project with the three recorded-commit states and
  compares the bytes; SC-001's state is the one the notes measured (FitForge: 0 entries become 20).

## Risks

- **`cat-file -e` and abbreviated or odd values.** An abbreviated sha, a branch name, or a `kitCommit` that is not a string behave
  differently under `cat-file` and under `git log`; the first task measures them, and the condition is the same one `git log` would
  have failed on (an unresolvable revision), so a value `git log` could read is never reported as unknown.
- **The new test builds a repository with plain git on Windows and Linux.** Line endings and `core.autocrlf` are set in the repositories
  the test creates (the lesson of feature 032's CRLF finding, and of the discarded measurement run); read-only objects are not touched.
- **A shallow kit clone in CI.** The test builds its own kit repository, so it does not depend on the depth of the CI checkout; the real
  kit clone's depth is exactly the state the feature reports.
- **A wrapper that matched `Result: up to date`.** In the unknown-commit state it now sees `Surgical ...`, the P3 line and exit 2.
  That is the point; the flow-down note says so.

## Needs the owner

1. **Decided (anas.m, 2026-10-16, by D1 A, D2 A and D3 A in the spec):** the behaviour, the reach and the two phases. P1 to P7 follow them.
2. **Worth a look before approving the plan**: P3's wording of the one line, and P5's choice of a Pester file over a harness extension
   (a harness extension would build a kit repository inside `FixtureRepo.psm1` for one script).

## Complexity Tracking

No constitution violation to justify.
