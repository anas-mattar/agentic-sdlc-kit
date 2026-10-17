# Implementation Plan: the enforcement pack names the cause when its diff base cannot be read

**Branch**: `035-pack-diff-base-cause` | **Date**: 2026-10-17 | **Spec**: specs/035-pack-diff-base-cause/spec.md
**Input**: Feature specification (approved, anas.m, 2026-10-17; D1 A, D2 A, D3 A) + decisions P1–P7 below
**Gate Batching**: none
**Gate Certification**: user-run

## Summary

`Get-DiffBase` in `scripts/enforcement-pack.ps1` (`:186`) reads `git merge-base HEAD <trunk>` and treats any non-zero exit as "no base". A numbered branch whose commit objects git
cannot read is then reported exactly like a branch with no integration branch: a `WARNING` that speaks of a missing integration branch, an `AmendmentAuthority` failure that says "this
check does not distinguish them", and an `UNGRADED` line for `ReviewProvenance` that advises `fetch-depth: 0` (measured, `notes.md`). The verdicts are right (the numbered lane is red,
the Lite lane `UNGRADED` at exit 0 by feature 014 FR-009 and feature 015 D6) and stay; the **cause** is wrong. The plan gives `Get-DiffBase` git's own distinction, the recipe of
feature 034: `rev-parse --verify --quiet` and `merge-base` exit 1 are answers, any other non-zero exit is a failure to read, kept in `$script:DiffBaseFailure` when no candidate gave a base.
Three messages then say what happened when the flag is set (the dispatch warning, the `AmendmentAuthority` failure, the `ReviewProvenance` `UNGRADED` line) and are otherwise untouched. The
fixtures reach the state with the existing `truncateCommit` field, on both lanes.

## Technical Context

**Language/Version**: PowerShell 7 (`pwsh`), git 2.55 (measured; feature 034's CI showed the exit codes hold on Linux, and this feature's CI run is the second probe again)
**Primary Dependencies**: none new
**Storage**: N/A
**Testing**: the fixture harness (`tests/enforcement/`, Pester), real temporary git repositories, hand-written expectations
**Target Platform**: Windows and Linux runners (the kit's CI)
**Project Type**: governance kit; command-line script
**Performance Goals**: N/A (the same git calls, with their exit codes read)
**Constraints**: every readable repository, a missing trunk, no shared history and a shallow clone print today's bytes and exit with today's code; both verdicts (numbered red, Lite `UNGRADED` at exit 0) stay (spec FR-003, FR-004)
**Scale/Scope**: one script, three rules, one flow-down note

## Constitution Check

- [x] **Specification First (I)**: `spec.md` is approved (anas.m, 2026-10-17); this plan follows it; `tasks.md` follows.
- [ ] **Repository Separation (III)**: not applicable, the kit is one repository.
- [x] **Architecture Consistency (IV)**: no new file; `enforcement-pack.ps1` keeps its structure and stays standalone.
- [ ] **Domain Invariants (V)**: not applicable, the template's slot is unfilled.
- [x] **Security (VI)**: the change only changes what is said; nothing is written, no secret is read, no verdict moves.
- [ ] **External Integration Governance (VII)**: not applicable.
- [x] **Testing Requirements (VIII)**: every reachable site has a passing and a failing fixture, hand-written (P5).
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI review with Reviewer Provenance.
- [x] **Controlled Delivery (X)**: two phases, one at a time. This changes the pack that grades every branch on every push, so the owner runs the gate: no batching, no ci-held.

**Phase sizing rule**: phase 1 changes the function, three messages and their fixtures and is useful alone. Phase 2 is documentation, the roadmap and the measurement on adopted-project
clones, and depends on phase 1 only for the text it describes. Reverting 2, then 1, leaves a consistent kit.

**Post-design re-check**: no new violation. There is no decision left to the owner beyond approving the plan (Needs the owner).

## Decisions

- **P1 - the base and the failure (FR-001).** `Get-DiffBase` keeps its candidates (`origin/main`, `main`) and gains feature 034's classification, per candidate: `git rev-parse --verify --quiet <c>` exiting 1
  means the ref is absent (continue); any other non-zero exit is a failure; `git merge-base HEAD <c>` exiting 0 with output is the base (returned as today); exiting 1 means no shared history
  (continue); any other non-zero exit is a failure. The exit code is read on the statement after the call: the current `@(git merge-base ... 2>$null | Where-Object { $_ })` pipeline is split into
  an assignment, a `$LASTEXITCODE` read, and the filter, so the filter cannot clobber it. A failure is remembered, not acted on at once; only when **no candidate yields a base and at least one failed**
  is `$script:DiffBaseFailure` set (to `git merge-base failed with exit <n>`, or `git rev-parse of <c> failed with exit <n>`). A later candidate's base wins over an earlier failure, as in feature 034.
  `$script:DiffBaseFailure` is reset at the top of each call. Nothing else reads it but the three messages below.
- **P2 - the dispatch warning (FR-002).** `:2401`: when `$script:DiffBaseFailure` is set, the warning reads
  `enforcement-pack: the diff base could not be read (<failure>), so nothing on '<branch>' was compared - the object store may be damaged: run git fsck, or re-clone. This run is not evidence that the branch is clean ...`
  (the rest of today's sentence about what the checks did or did not grade is kept); otherwise today's text, byte for byte.
- **P3 - the numbered lane (FR-002, FR-003).** `:2143`: when the flag is set, the failure reads
  `AmendmentAuthority: cannot grade '<branch>' — the diff base could not be read (<failure>), so what the branch changed is unknown - the object store may be damaged: run git fsck, or re-clone (constitution I, Amendment authority)`,
  still a failure (exit 1); otherwise today's text. The shallow-clone failure above it (`:2139`) is asked first and is unchanged.
- **P4 - the Lite lane's advice (FR-002).** `:1316`: when the flag is set, the `ReviewProvenance` `UNGRADED` line reads
  `ReviewProvenance: the diff base could not be read (<failure>), so no review file on '<branch>' was inspected - the machine half of DoD gate 5 formed no opinion. The object store may be damaged: run git fsck, or re-clone`,
  still `UNGRADED` (exit 0 on the Lite lane); otherwise today's line with its `fetch-depth: 0` advice. The other three "no diff base" lines (`MicroLane`, `PhaseSizeWarning`, `LiteAndAbuse`) state a consequence that is still
  true of a damaged branch and are not changed (D2 A).
- **P5 - tests (FR-005).** Written first, shown failing on the parent commit; `fail` is the state, `pass` the same fixture readable. Three rules, one emission site each, in the `BASE-` family:
  - **`BASE-001`** (the dispatch warning, Lite lane): `fail` is a `docs/x` branch (`AMEND-001`'s Lite fixtures are the source) with `truncateCommit` `HEAD`: the new warning, the new `ReviewProvenance` line, `UNGRADED (1 check(s) formed no opinion)`, exit 0;
    `pass` the same readable (`OK`); **`pass-orphan`**: a `docs/y` orphan branch keeps today's warning text and `fetch-depth: 0` advice and exit 0 (FR-004).
  - **`BASE-002`** (the numbered lane's `AmendmentAuthority`): `fail` is `STRUCT-001/pass`'s fixture with `truncateCommit` `HEAD`: the new warning and the new failure, exit 1; `pass` the same readable; **`pass-orphan`**: a numbered orphan keeps today's
    `no integration branch` failure text (with its missing-document failures), exit 1.
  - **`BASE-003`** (the `ReviewProvenance` line): the Lite damaged fixture again, as its own case directory so the rule has its own pair (the output is the same as `BASE-001`'s; the rules differ by emission site, as `SCOPE-028` to `SCOPE-030` do).
  The shallow clone, the missing trunk and the other no-base states are pinned by existing cases (`AMEND-003`, `AMEND-001/pass-lite-docs-readme-only-shallow`, `CRIT-R02`, `CRIT-R03`) and must pass unchanged. Each rule is inventoried in `tests/enforcement/rules.json` with its
  `emitAnchor`; the coverage report must show no unowned site; the exempt count stays 7.
- **P6 - guidance and close (FR-006, phase 2).** `adoption/updating.md` gains a flow-down note in the shape of feature 034's (no digest marker: the adoption digest is at its 40-bullet bound); `docs/roadmap.md` closes GAP-041, records the decision and marks the row `shipped`;
  the measurement runs the pack before and after on the three adopted projects' clones with probe branches (intact, orphan, damaged) on both lanes.
- **P7 - what does not change (FR-003, FR-004).** The verdicts and exit codes; the shallow-clone detection and its text; `-ReplayBase`/`-ReplayTip` and `-IgnoreAmendmentBoundary`; the `Add-DiffUnreadable` and `Add-GitReadUnreadable` states of features 028 and 029 (they need a base);
  the other "no diff base" lines; every readable repository.

## Phases

Detailed tasks and the per-phase **Territory** blocks are in `tasks.md`.

1. **Measure, prove, change.** Baseline harness and the re-measurement of `notes.md` on the parent commit and, through CI, on the CI image's git; the P5 fixtures first and shown failing; P1 to P4 and P7 in the script. Delivers User Story 1 and FR-001 to FR-005.
2. **Guidance, close, measure on clones.** P6, the measurement of SC-002 on a clone of each adopted project, and the full harness on an isolated checkout. Delivers User Story 2, FR-006 and SC-001 to SC-003.

## Project Structure

### Documentation (this feature)

```text
specs/035-pack-diff-base-cause/
├── spec.md
├── plan.md              # this file
├── tasks.md
├── notes.md             # the measurements, the baseline, the cases
└── checklists/requirements.md
```

No `research.md`, `data-model.md` or `contracts/`: the script has no data model, and its CLI contract (`specs/006-verification-pack/contracts/`) is unchanged: arguments, exit codes and verdicts stay, only the cause named in three messages changes for a failed read.

### Source Code (repository root)

```text
scripts/enforcement-pack.ps1                       # phase 1: P1 to P4 (Get-DiffBase and three messages)
tests/enforcement/rules.json                       # phase 1: BASE-001 to BASE-003
tests/enforcement/cases/enforcement-pack/          # phase 1: BASE-001 (fail, pass, pass-orphan), BASE-002 (fail, pass, pass-orphan), BASE-003 (fail, pass)
adoption/updating.md                               # phase 2: flow-down note
docs/roadmap.md                                    # phase 2
docs/digests/**                                    # phase 2, only if a digest-marked document changes
```

**Structure Decision**: no new script and no new library file; `scripts/enforcement-pack.ps1` ships verbatim, so `kit-manifest.json` needs no entry. `tests/enforcement/lib/FixtureRepo.psm1` is untouched (`truncateCommit` takes `HEAD`).

## Testing Strategy

- Each rule is written as a failing fixture and shown failing on the parent commit, then the behaviour lands. The harness runs the script with the case's working directory set to the fixture.
- `BASE-001` to `BASE-003` differ from their neighbours only in the truncated object or the orphan flag; every other `enforcement-pack` case is unchanged and pins the byte-identical output of FR-004, including the shallow-clone and missing-trunk cases.
- The full harness runs on an isolated checkout of the final commit (feature 022's method); `-Case enforcement-pack/` (and `-Case TERR-`, which shares scope-lib but not the pack) per phase. The baseline (1859 on `7a96899`, as feature 034 left it) is re-taken on the parent commit and recorded.
- The measurement of SC-002 runs the pack before and after on branches made in each adopted project's clone (both lanes; intact, orphan, damaged) and compares the bytes.

## Risks

- **Exit-code assumptions.** `merge-base` 1 for "none", 128 or 255 for a failure is measured on git 2.55 for Windows and held on Linux in feature 034's CI; this feature's CI run is a second confirmation. A git that exits 1 for a failure falls back to today's text, never to a false cause.
- **`$LASTEXITCODE` after a pipeline.** `Get-DiffBase` today reads it after `| Where-Object`; P1 splits the statement, and the fixtures pin the result.
- **The shallow-clone failure is asked first.** A shallow clone with a damaged object is reported as shallow (the existing order); the plan does not reorder them.
- **Three emission sites with similar words.** The anchors are distinct substrings (`enforcement-pack: the diff base could not be read`, `cannot grade '<branch>' — the diff base could not be read`, `ReviewProvenance: the diff base could not be read`); the coverage sweep proves each belongs to one rule.
- **A truncated object that is packed.** `truncateCommit` refuses a packed object loudly, so a case cannot pass for the wrong reason.

## Needs the owner

1. **Decided (anas.m, 2026-10-17, by D1 A, D2 A and D3 A in the spec):** the behaviour, the reach and the two phases. P1 to P7 follow them.
2. **Worth a look before approving the plan**: the wording of the three new messages (the fixtures pin it byte for byte), and P5's choice to give `ReviewProvenance` its own rule beside the dispatch warning although a Lite-lane fixture shows both.

## Complexity Tracking

No constitution violation to justify.
