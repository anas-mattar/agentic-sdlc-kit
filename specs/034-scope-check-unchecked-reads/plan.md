# Implementation Plan: the scope checks name a merge base or commit list they cannot read

**Branch**: `034-scope-check-unchecked-reads` | **Date**: 2026-10-17 | **Spec**: specs/034-scope-check-unchecked-reads/spec.md
**Input**: Feature specification (approved, anas.m, 2026-10-17; D1 A, D2 A, D3 A) + decisions P1–P8 below
**Gate Batching**: none
**Gate Certification**: user-run

## Summary

`scope-check.ps1 -All` and `scope-check-repos.ps1 -All` find the branch's merge base with the trunk, then list the commits since it. Both reads
discard git's errors and take any non-zero exit for "none", so a damaged branch ends `UNGRADED could not resolve a merge base ...` with exit 0,
the same words and the same exit as a branch that legitimately shares no history with the trunk; and `ritual-checks`, which runs `-All`, is green
(measured, `notes.md`). The plan reads git's own distinction: `git merge-base` exits **1** for "no merge base" and **128 or 255** when it cannot read,
`git rev-parse --verify --quiet` exits 1 for a missing ref, and `git rev-list` exits 128 on a damaged range. A failure becomes an `ERROR` line and exit 1
(D1 A); the legitimate states keep their text and exit 0. The failure reaches the callers on a channel of its own (a script-scoped flag in
`scope-check.ps1`, a `Failed` member of `Get-RepoMergeBase`'s result in `scope-lib.ps1`), the way features 030 and 032 did it. `territory-check.ps1`, which
shares `Get-RepoMergeBase`, is not changed (D2 A). The fixtures reach the merge-base state with the existing `truncateCommit` field, on the governance
repository and, because a nested recipe is built by the same function, on a code repository.

## Technical Context

**Amendment approved by**: anas.m, 2026-10-17

**Language/Version**: PowerShell 7 (`pwsh`), git 2.55 (measured; the plan's first task re-measures on the CI image's git)
**Primary Dependencies**: none new
**Storage**: N/A
**Testing**: the fixture harness (`tests/enforcement/`, Pester), real temporary git repositories, hand-written expectations
**Target Platform**: Windows and Linux runners (the kit's CI)
**Project Type**: governance kit; command-line scripts
**Performance Goals**: N/A (the same git calls, with their exit codes read)
**Constraints**: every readable repository, `-Commit` and tip mode, and every legitimate UNGRADED state print today's bytes and exit with today's code (spec FR-002, FR-006)
**Scale/Scope**: two scripts and one library function, four rules (none exempt), one new recipe field, one flow-down note

## Constitution Check

**Amendment approved by**: anas.m, 2026-10-17

- [x] **Specification First (I)**: `spec.md` is approved (anas.m, 2026-10-17); this plan follows it; `tasks.md` follows.
- [ ] **Repository Separation (III)**: not applicable, the kit is one repository.
- [x] **Architecture Consistency (IV)**: no new file; the scripts keep their structure, and `scope-lib.ps1` stays the one place both graders share.
- [ ] **Domain Invariants (V)**: not applicable, the template's slot is unfilled.
- [x] **Security (VI)**: the change makes a check fail where it passed; nothing is written, no secret is read.
- [ ] **External Integration Governance (VII)**: not applicable.
- [x] **Testing Requirements (VIII)**: every reachable site has a passing and a failing fixture, hand-written; the commit-list sites are reached with the `commitGraph` recipe field and have real fixtures (P5 as amended).
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI review with Reviewer Provenance.
- [x] **Controlled Delivery (X)**: two phases, one at a time. This changes the check that grades every phase commit on every push, so the owner runs the gate: no batching, no ci-held.

**Phase sizing rule**: phase 1 changes the library function, both graders and their fixtures and is useful alone. Phase 2 is documentation, the roadmap
and the measurement on adopted-project clones, and depends on phase 1 only for the text it describes. Reverting 2, then 1, leaves a consistent kit.

**Post-design re-check**: no new violation. There is no decision left to the owner beyond approving the plan (Needs the owner).

## Decisions

**Amendment approved by**: anas.m, 2026-10-17

- **P1 - the merge base of `scope-check.ps1` (FR-001, FR-002).** `Get-DiffBase` (`:86`) keeps its candidates (`origin/main`, `main`) and gains the
  classification, per candidate: `git rev-parse --verify --quiet <c>` exiting 1 means the ref is absent (continue, as today); any other non-zero exit is a
  failure; `git merge-base HEAD <c>` exiting 0 with output is the base (returned as today); exiting 1 means no shared history (continue, as today); any
  other non-zero exit is a failure. A failure is remembered, not acted on at once: if a later candidate yields a base, that base is returned and nothing is
  reported (the check can still grade); only when **no candidate yields a base and at least one failed** is `$script:DiffBaseReadFailed` set, with the
  command and exit code in `$script:DiffBaseFailure`. The caller, `-All`, prints P4's `ERROR` and exits 1 when the flag is set, and prints today's
  `UNGRADED ... merge base` line and exit 0 otherwise.
- **P2 - the shared function (FR-005, D2 A).** `Get-RepoMergeBase` (`scope-lib.ps1:204`) gets the same classification and returns a `Failed` member
  (and `FailedWith`, the command and exit code) beside `Base`, `Trunk`, `Tried` and `Existing`, which keep their meaning for `territory-check.ps1` (it reads
  `Base` and `Existing` only and is not changed; stated as a limit). `Failed` is true only under P1's rule (no base found, at least one failure).
- **P3 - the commit list (FR-003).** In both scripts `git rev-list --reverse --no-merges <base>..<tip> 2>$null` is assigned first and `$LASTEXITCODE` read on the
  next statement; a non-zero exit ends in P4's second `ERROR`, an exit 0 with no commits in today's `UNGRADED (no commits since merge base ...)`.
- **P4 - the verdict and the words (D1 A, FR-004).** Two `Write-Host` lines in `scope-check.ps1`, each exit 1, each a single emission site:
  `scope-check: ERROR could not read the merge base with main (<command> failed with exit <n>), so nothing on the branch was graded - the object store may be damaged: run git fsck.`
  and `scope-check: ERROR could not list the commits since the merge base (git rev-list failed with exit <n>), so nothing on the branch was graded - the object store may be damaged: run git fsck.`
  In `scope-check-repos.ps1` the same sentences through `Write-Line`, prefixed with the repository (`<repo>: ERROR could not read the merge base with a trunk (...) ...`),
  setting `$failed` and going on to the next repository, so the run ends exit 1 and the other repositories are still graded and named.
- **P5 - tests (FR-007).** Written first, shown failing on the parent commit; `fail` is the state, `pass` the same fixture readable:
  - **`SCOPE-031`** (the merge base): `fail` is `SCOPE-025/pass`'s fixture with `truncateCommit` `HEAD` and `-All`: P4's first line, exit 1, where the parent printed
    `UNGRADED could not resolve a merge base with main - nothing checked`, exit 0; `pass` is `SCOPE-025/pass` unchanged; **`pass-orphan`** is a branch with no
    history in common with the trunk (`"orphan": true`): the `UNGRADED ... merge base` line and exit 0, pinning FR-002 (git answered "none"). The no-trunk-ref state is
    already pinned by `SCOPE-025/fail`.
  - **`SCOPE-032`** (the commit list): `fail` is `SCOPE-025/pass`'s fixture with `commitGraph` and `truncateCommit` `HEAD`: git answers `merge-base` from the commit-graph and succeeds,
    `git rev-list` over the range exits 128, and P4's second line ends the run, exit 1; `pass` the same readable. (First planned as exempt, on the belief that every damage fails the merge base first;
    the phase 1 review, finding F1, showed the state is reachable with a commit-graph, and the field is built.)
  - **`REPOS-036`** (the code repository's merge base): `fail` is `REPOS-001/pass`'s fixture with `-All` and `truncateCommit` `HEAD` in the **nested** recipe (the nested repository is
    built by the same function, so the field applies to it): P4's repository line, `UNGRADED`-free, exit 1; `pass` the same readable.
  - **`REPOS-037`** (the code repository's list): the same with `commitGraph` and `truncateCommit` in the nested recipe, two lines (the repository's `ERROR` and the run-level `UNGRADED`), exit 1; `pass` readable.
  Each rule is inventoried in `tests/enforcement/rules.json` with its `emitAnchor`; the coverage report must show no unowned site; the exempt count stays 7.
  The new recipe field is `commitGraph`: `FixtureRepo.psm1` writes the commit-graph (`git commit-graph write --reachable`) after the commits and before any truncation, with a self-test in `Harness.Tests.ps1`.
- **P6 - guidance and close (FR-008, phase 2).** `adoption/updating.md` gains a flow-down note in the shape of feature 033's (no digest marker: the adoption digest is at its
  40-bullet bound); `docs/roadmap.md` closes GAP-040, records the decision and marks the row `shipped`; the measurement runs the changed scripts on clones of the
  three adopted projects with `-All` on a feature branch, before and after, and on a damaged one (SC-002, SC-001).
- **P7 - what does not change (FR-006).** `-Commit`, `-Phase` and tip mode; the `UNGRADED` text and exit 0 for a missing trunk, no shared history and an empty range;
  `territory-check.ps1`; the `tasks.md` and `spec.md` blob reads; the committer-date read; the territory grammar and every other verdict.
- **P8 - the exit code of a failure that is not damage.** A `git merge-base` that fails for a reason other than damaged objects (a permissions error on
  `.git`, a lock) also exits non-zero and non-1; it is reported by the same `ERROR`, which is the honest verdict: the check could not read.

## Phases

Detailed tasks and the per-phase **Territory** blocks are in `tasks.md`.

1. **Measure, prove, change.** Baseline harness and the re-measurement of `notes.md` on the parent commit and, through CI, on the CI image's git; the P5 fixtures first and shown
   failing; P1 to P4 and P7 in the scripts and the library. Delivers User Stories 1 and 2 and FR-001 to FR-007.
2. **Guidance, close, measure on clones.** P6, the measurement of SC-002 on a clone of each adopted project, and the full harness on an isolated checkout. Delivers User Story 3,
   FR-008 and SC-001 to SC-003.

## Project Structure

### Documentation (this feature)

```text
specs/034-scope-check-unchecked-reads/
├── spec.md
├── plan.md              # this file
├── tasks.md
├── notes.md             # the measurements, the baseline, the cases
└── checklists/requirements.md
```

No `research.md`, `data-model.md` or `contracts/`: the scripts have no data model, and their CLI contracts (`specs/006-verification-pack/contracts/`,
`specs/012-cross-repo-scope-check/contracts/scope-check-repos-cli.md`) are unchanged: arguments and exit codes stay, only a state that printed `UNGRADED` over a failed read prints an `ERROR` and exits 1.

### Source Code (repository root)

**Amendment approved by**: anas.m, 2026-10-17

```text
scripts/scope-lib.ps1                     # phase 1: P2 (Get-RepoMergeBase)
scripts/scope-check.ps1                   # phase 1: P1, P3, P4 (Get-DiffBase, the commit list)
scripts/scope-check-repos.ps1             # phase 1: P2 caller, P3, P4
tests/enforcement/lib/FixtureRepo.psm1    # phase 1: the commitGraph recipe field (P5 as amended)
tests/enforcement/Harness.Tests.ps1         # phase 1: the self-test of commitGraph
tests/enforcement/rules.json              # phase 1: SCOPE-031, SCOPE-032, REPOS-036, REPOS-037
tests/enforcement/cases/scope-check/      # phase 1: SCOPE-031 (fail, pass, pass-orphan), SCOPE-032 (fail, pass)
tests/enforcement/cases/scope-check-repos/ # phase 1: REPOS-036 (fail, pass), REPOS-037 (fail, pass)
adoption/updating.md                      # phase 2: flow-down note
docs/roadmap.md                           # phase 2
docs/digests/**                           # phase 2, only if a digest-marked document changes
```

**Structure Decision**: no new script and no new library file; the three scripts ship verbatim, so `kit-manifest.json` needs no entry. `tests/enforcement/lib/FixtureRepo.psm1`
gains one recipe field, `commitGraph` (`truncateCommit` takes `HEAD` and applies to a nested recipe, as before).

## Testing Strategy

- Each rule is written as a failing fixture and shown failing on the parent commit, then the behaviour lands. The harness runs the script with the case's working directory set to the fixture.
- `SCOPE-031` and `REPOS-036` differ from their neighbours only in the truncated object; every other `SCOPE-` and `REPOS-` case is unchanged and pins the byte-identical output of FR-006,
  including `SCOPE-025/fail` (no trunk) and the existing no-shared-history and empty-range cases.
- The full harness runs on an isolated checkout of the final commit (feature 022's method); `-Case SCOPE-`, `-Case REPOS-`, `-Case TERR-` (territory-check shares the function) and `-Case RIT-`
  per phase. The baseline (1838 on `fe9a02d`, as feature 033 left it) is re-taken on the parent commit and recorded.
- The measurement of SC-002 runs `scope-check.ps1 -All` and `scope-check-repos.ps1 -All` before and after on a feature branch of each adopted project's clone and compares the bytes.

## Risks

- **Exit-code assumptions.** `merge-base` 1 for "none", 128 or 255 for a failure is measured on git 2.55 for Windows; the first task re-measures on the CI image's git, and the CI run is the second
  probe. If a git exits 1 for a failure the state falls back to today's `UNGRADED`, never to a false ERROR.
- **A failing first candidate and a working second.** P1 returns the later base without reporting the earlier failure. That is a choice: a damaged `origin/main` with a readable `main` still grades; the plan says so.
- **`territory-check.ps1` shares the function.** `-Case TERR-` must pass unchanged: it reads `Base` and `Existing`, which keep their meaning.
- **The nested truncation.** `truncateCommit` on a nested recipe is probed in the first task before a rule depends on it; if it does not apply there, `REPOS-036` is built another way or exempt with a reason.
- **A truncated object that is packed.** `truncateCommit` refuses a packed object loudly (the fixture's own guard), so a case cannot pass for the wrong reason.

## Needs the owner

**Amendment approved by**: anas.m, 2026-10-17

1. **Decided (anas.m, 2026-10-17, by D1 A, D2 A and D3 A in the spec):** the verdict, the reach and the two phases. P1 to P8 follow them.
2. **Worth a look before approving the plan**: P1's choice that a later candidate's base wins over an earlier candidate's failure, P4's wording of the two `ERROR` lines (the fixtures pin it
   byte for byte), and P5's `commitGraph` field and the real fixtures of `SCOPE-032` and `REPOS-037`.

## Complexity Tracking

**Amendment approved by**: anas.m, 2026-10-17

No constitution violation to justify. The exempt count stays 7: the two commit-list sites were first planned as exempt and were made real in phase 1 (review finding F1), with one new harness recipe field.
