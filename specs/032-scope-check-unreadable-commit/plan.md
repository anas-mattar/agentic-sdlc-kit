# Implementation Plan: the scope check names a phase commit whose diff cannot be read

**Branch**: `032-scope-check-unreadable-commit` | **Date**: 2026-10-16 | **Spec**: specs/032-scope-check-unreadable-commit/spec.md
**Input**: Feature specification (approved, anas.m, 2026-10-16; D1 A, D2 A, D3 A) + decisions P1–P8 below
**Gate Batching**: none
**Gate Certification**: user-run

## Summary

`scripts/scope-check.ps1` learns what a commit touched from one read, `git show --name-status`, in two places: `Get-CommitPaths`
(`scripts/scope-lib.ps1:29`) and the guard that refuses a deletion or rename of `tasks.md` or `spec.md` (`scripts/scope-check.ps1:123`).
Both discard git's errors and never read the exit code, so an unreadable commit is an empty list, which is also what a readable
empty commit produces (measured, `notes.md`). The plan puts both reads behind one function that reports a failure on a channel
separate from the list (the GAP-036 recipe of feature 030: a script-scoped flag, because PowerShell unrolls an empty array to
`$null`), and has `scope-check.ps1` print an `ERROR` line and fail the commit (D1 A) where it printed `PASS (0 file(s))` or
`not applicable`. `scope-check-repos.ps1` reads the same function and names the state too. The fixtures reach it with the existing
`truncateCommit` field on the commit's tree, so the harness gains no recipe field.

## Technical Context

**Language/Version**: PowerShell 7 (`pwsh`), git 2.55 (measured; the plan's first task re-measures on the CI image's git)
**Primary Dependencies**: none new
**Storage**: N/A
**Testing**: the fixture harness (`tests/enforcement/`, Pester), real temporary git repositories, hand-written expectations
**Target Platform**: Windows and Linux runners (the kit's CI)
**Project Type**: governance kit; command-line scripts
**Performance Goals**: N/A (the same one git call per commit, plus an exit-code read)
**Constraints**: every readable commit prints today's text and exits with today's code (spec FR-005); the blob reads and the
committer-date read are not changed (FR-007)
**Scale/Scope**: two scripts and one library, three rules (four fixtures pairs and one control), one flow-down note

## Constitution Check

- [x] **Specification First (I)**: `spec.md` is approved (anas.m, 2026-10-16); this plan follows it; `tasks.md` follows.
- [ ] **Repository Separation (III)**: not applicable, the kit is one repository.
- [x] **Architecture Consistency (IV)**: no new file; the scripts keep their structure, and `scope-lib.ps1` stays the one place both graders read commits.
- [ ] **Domain Invariants (V)**: not applicable, the template's slot is unfilled.
- [x] **Security (VI)**: the change makes a check fail where it passed; nothing is written, no secret is read.
- [ ] **External Integration Governance (VII)**: not applicable.
- [x] **Testing Requirements (VIII)**: every reachable site has a passing and a failing fixture, hand-written; the one unreachable site is exempt with a written reason (P5).
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI review with Reviewer Provenance.
- [x] **Controlled Delivery (X)**: two phases, one at a time. This changes the check that grades every phase commit, so the owner runs the gate: no batching, no ci-held.

**Phase sizing rule**: phase 1 changes the library, the grader and their fixtures and is useful alone. Phase 2 is documentation, the
roadmap and the measurement on adopted-project clones, and depends on phase 1 only for the text it describes. Reverting 2, then 1,
leaves a consistent kit.

**Post-design re-check**: no new violation. There is no decision left to the owner beyond approving the plan (Needs the owner).

## Decisions

- **P1 - one read, a failure channel (FR-001, FR-004).** `scope-lib.ps1` gains `Get-CommitStatusRows -Sha <sha> [-Renames]`: it runs
  `git -c core.quotepath=off show --name-status --format='' [-M] <sha> 2>$null`, reads `$LASTEXITCODE` on the very next statement,
  sets `$script:CommitReadFailed = ($LASTEXITCODE -ne 0)`, and returns the rows. `Get-CommitPaths` calls it with `-Renames` and
  keeps its return shape (a list of paths). The flag is the channel, not a return value or a sentinel, because PowerShell unrolls an
  empty array to `$null`: a function that returned `$null` for a failure would be indistinguishable from a readable empty commit
  (the same reasoning as feature 030's `$script:LedgerReadFailed`). The flag is reset at the top of every call; a caller reads it
  immediately after the call.
- **P2 - the guard (FR-003).** `scope-check.ps1:123` calls `Get-CommitStatusRows` without `-Renames`, as it reads today (the two reads
  differ by `-M` and the plan keeps that, so every readable commit prints what it printed). If the flag is set, the commit ends in
  P4's `ERROR` before phase attribution: the guard runs on every non-merge commit, so a token-less commit with an unreadable diff is
  named, and no longer reported as `not applicable`.
- **P3 - the phase paths (FR-001).** The two calls of `Get-CommitPaths` (`scope-check.ps1:187`, Micro lane; `:255`, Standard lane)
  read the flag after the call and end in the same `ERROR`. After the guard has succeeded a second failure is unlikely, but the
  read is a separate git call and is checked, not assumed.
- **P4 - the verdict and the words (D1 A).** One function in `scope-check.ps1`, `Write-UnreadableCommit`, prints the line and the
  callers `return $false` (an `ERROR` that fails the commit, as the script already does for a commit that does not resolve, `:98`):
  `scope-check: ERROR commit <sha7>: its changed files could not be read (git show --name-status failed), so nothing about it was graded - the object store may be damaged: run git fsck.`
  A single emission site, so the rule's anchor names it once. The exit is 1, as for every failed commit; `-All` counts it
  as a failure and goes on to the next commit.
- **P5 - tests (FR-006).** Written first, shown failing on the parent commit, each `fail` the state and each `pass` the same
  fixture readable, with `truncateCommit` set to `HEAD^{tree}` in the `fail` only:
  - **`SCOPE-028`** (Standard phase commit): `fail` prints P4's `ERROR`, exit 1; `pass` is `SCOPE-019/pass`'s fixture (`PASS ... (1 file(s))`).
    A second `pass-empty` case (a phase commit entry with no `write`, `copy` or `delete`: the harness commits with `--allow-empty`,
    `FixtureRepo.psm1:412`) pins FR-002: `PASS ... (0 file(s))`, measured on the parent in `notes.md`.
  - **`SCOPE-029`** (Micro phase commit): the same pair on `SCOPE-016/pass`'s fixture.
  - **`SCOPE-030`** (the guard): a commit with no phase token that deletes `tasks.md`; `fail` is the unreadable tree (P4's `ERROR`, exit 1,
    where the parent printed `not applicable` and `UNGRADED`), `pass` is the same commit readable and not deleting (today's
    `not applicable (... carries no 'phase N' token)`).
  - **`REPOS-035`** (`scope-check-repos.ps1:271`): exempt, with a written reason (FR-006): the committer-date read
    (`git show -s --format=%cI`) fails first on every damaged commit tried (a removed tree, a removed subtree, a truncated tree;
    measured, `notes.md`), so the shared function is never reached with a failure there; the line is kept as defence in depth
    and stays inventoried so it cannot be reworded away unnoticed.
  Each rule is inventoried in `tests/enforcement/rules.json` with its `emitAnchor`; the coverage report must show no unowned site.
- **P6 - `scope-check-repos.ps1` (D2 A).** After `Get-CommitPaths` at `:271` the flag is read and the repository's phase commit
  ends in `<repo>: ERROR cannot read the changed files of <sha7>` and `'FAIL'`, in the shape of its own date-read line. It is
  unreachable today (P5) and is there so a future change to the date read cannot reopen the hole.
- **P7 - what does not change (FR-005, FR-007).** The `tasks.md` and `spec.md` blob reads (`:159-:212`), the committer-date read,
  the territory grammar and every other verdict are untouched; an empty readable commit still prints `PASS ... (0 file(s))`.
- **P8 - guidance and close (FR-008, phase 2).** `adoption/updating.md` gains a flow-down note in the shape of feature 031's (no
  digest marker: the adoption digest is at its 40-bullet bound); `docs/roadmap.md` closes GAP-038, records the decision and marks
  the row `shipped`; the measurement runs the changed scripts on a phase commit of each adopted project's own history (SC-002).

## Phases

Detailed tasks and the per-phase **Territory** blocks are in `tasks.md`.

1. **Measure, prove, change.** Baseline harness and the re-measurement of `notes.md` on the parent commit and on the CI image's
   git; P5 fixtures first and shown failing; P1 to P4, P6 and P7 in the scripts. Delivers User Stories 1 and 2 and FR-001 to FR-007.
2. **Guidance, close, measure on clones.** P8, the measurement of SC-002 on a clone of each adopted project, and the full harness on
   an isolated checkout. Delivers User Story 3, FR-008 and SC-001 to SC-003.

## Project Structure

### Documentation (this feature)

```text
specs/032-scope-check-unreadable-commit/
├── spec.md
├── plan.md              # this file
├── tasks.md
├── notes.md             # the measurements, the baseline, the cases
└── checklists/requirements.md
```

No `research.md`, `data-model.md` or `contracts/`: the scripts have no data model, and their CLI contracts
(`specs/006-verification-pack/contracts/`, `specs/012-cross-repo-scope-check/contracts/scope-check-repos-cli.md`) are unchanged:
arguments and exit codes stay, only a state that used to print `PASS` or `not applicable` prints an `ERROR` and exits 1.

### Source Code (repository root)

```text
scripts/scope-lib.ps1                     # phase 1: P1 (Get-CommitStatusRows, Get-CommitPaths)
scripts/scope-check.ps1                   # phase 1: P2, P3, P4
scripts/scope-check-repos.ps1             # phase 1: P6
tests/enforcement/rules.json              # phase 1: SCOPE-028 to SCOPE-030, REPOS-035 (exempt)
tests/enforcement/cases/scope-check/      # phase 1: the new cases
adoption/updating.md                      # phase 2: flow-down note
docs/roadmap.md                           # phase 2
docs/digests/**                           # phase 2, only if a digest-marked document changes
```

**Structure Decision**: no new script and no new library file; the three scripts ship verbatim, so `kit-manifest.json` needs no
entry. `tests/enforcement/lib/FixtureRepo.psm1` is untouched (`truncateCommit` takes `HEAD^{tree}`).

## Testing Strategy

- Each rule is written as a failing fixture and shown failing on the parent commit, then the behaviour lands. The harness runs
  the script with the case's working directory set to the fixture.
- `SCOPE-028` to `SCOPE-030` differ from their neighbours only in the truncated object; every other `SCOPE-` and `REPOS-` case
  is unchanged and pins the byte-identical output of FR-005.
- The full harness runs on an isolated checkout of the final commit (feature 022's method); `-Case SCOPE-`, `-Case REPOS-` and
  `-Case RIT-` per phase. The baseline (1809 on `c91472e`, as feature 031 left it) is re-taken on the parent commit and recorded.
- The empty readable commit (FR-002) is measured in `notes.md` before the change and pinned by a case after it.
- The measurement of SC-002 runs `scope-check.ps1 -Commit <phase commit>` before and after on a phase commit of each adopted
  project's history, in a clone, and compares the bytes.

## Risks

- **`$LASTEXITCODE` is clobbered.** Any statement between the `git` call and the read can change it; P1 reads it on the next
  statement and the self-test of the function pins that.
- **The flag's scope.** `$script:` in a dot-sourced library is the caller's script scope; `scope-check-repos.ps1` calls the function
  inside `Push-Location`/`try`/`finally`. The first task proves the flag survives both callers before a rule depends on it.
- **A packed tree cannot be truncated.** `truncateCommit` refuses a packed object, which is the fixture's own guard; the fixtures are
  built on fresh loose objects. If the CI image packs, the case fails loudly and does not pass for the wrong reason.
- **More red on a damaged repository.** Every non-merge commit with an unreadable diff is now an `ERROR`, token-less ones included
  (the guard runs before phase attribution). That is the point, and `-All` shows one line per damaged commit.
- **A shallow clone.** A commit at the shallow boundary is readable (git lists its files as added); nothing changes for it, and the
  first task confirms it.

## Needs the owner

1. **Decided (anas.m, 2026-10-16, by D1 A, D2 A and D3 A in the spec):** the verdict, the reach and the two phases. P1 to P8 follow them.
2. **Worth a look before approving the plan**: P4's wording of the `ERROR` line (the fixtures pin it byte for byte), and P5's
   exemption of `REPOS-035` with its reason.

## Complexity Tracking

No constitution violation to justify. The exempt count rises by one (`REPOS-035`), disclosed here and in `notes.md` once measured.
