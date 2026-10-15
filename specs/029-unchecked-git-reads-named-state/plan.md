# Implementation Plan: Make every unchecked `git` read a named state, not "nothing"

**Branch**: `029-unchecked-git-reads-named-state` | **Date**: 2026-10-15 | **Spec**: specs/029-unchecked-git-reads-named-state/spec.md
**Input**: Feature specification (approved, anas.m, 2026-10-15; Decision 1 option B, every unchecked read in both scripts, one phase per group; Decision 2 the 027/028 lane split) + decisions D1–D9 below
**Gate Batching**: none
**Gate Certification**: user-run
**Status**: Approved 2026-10-15 (owner: anas.m) — "Needs the owner" 1-4 as recommended

## Summary

Feature 028 made one `git diff` read honest. This feature does the same for the other reads of `git` in `scripts/enforcement-pack.ps1` and `scripts/territory-check.ps1` that discard stderr and
read an empty result as "nothing". It adds **one generic reader** beside `Read-DiffLines` (`Read-GitLines`: `Ok`, lines, exit code; a failed command returns no lines) and **one policy
function** beside `Add-DiffUnreadable` (numbered lane: a named failure; Lite lane: an `UNGRADED` line per check that graded nothing; never a new Lite failure, 014 FR-009), then moves each
unchecked read behind them, one **group** per phase. `territory-check.ps1` uses its own, existing shapes (`Stop-Refused`, the `ungraded` records), not the pack's.

**The inventory (FR-001) is the main finding, and it corrects the spec in both directions.** The spec said "~30 reads, by reading the code". Read line by line, the reads sort into
three kinds, and **a good half are already named**, so the work is smaller than the row reads:

| Kind | Meaning | Count (approx.) |
|---|---|---|
| **Named already** | exit code is read and the failure is reported (`Read-DiffLines`; `Get-GradedDocSet`/`Get-FeatureDocMap` return `$null` and the caller refuses; `Get-AutoMergeTree`; `Test-CheckAbsentForReal`; `Get-CheckPresenceSet`; the human-review, `tasks.md`, plan and commit-subject reads of the Critical arm; `Read-CodeRef`) | ~20 |
| **Graded here** | exit code is not read and an empty result changes a verdict (table below) | 14 |
| **Out of scope, reason recorded** | a failure cannot change a verdict, or git's exit code cannot tell "absent" from "unreadable" | ~6 |

The 14 graded reads are the ones where **a failure produces a wrong green**, ordered by what they hide:

| # | Read (script, site) | A failure reads as | Group / phase |
|---|---|---|---|
| G1 | `git show --numstat --format=''` in `Invoke-MicroLaneCheck` (`enforcement-pack.ps1` ~851) | 0 lines: the 400-line bound passes (**reproduced**, 028 review F2) | 1 |
| G2 | `git rev-list --no-merges` + `git log -1 --format=%s` there (~845-847) | no commit, or a commit with no phase token: the walk grades nothing | 1 |
| G3 | `git rev-list` + `git show --numstat` in `Invoke-PhaseSizeWarningCheck` (~1282-1284) | the warning disappears | 1 |
| G4 | `git log -z ... ` in `Get-CommitMetaBatch` (~1341) | an empty metadata map: commits lose their parents, day and trailers | 2 |
| G5 | `git log --name-status` in `Get-NameStatusBatch` (~1368) | every commit has no rows: **nothing is graded** by the amendment check | 2 |
| G6 | `git rev-list --reverse $range` in `Invoke-AmendmentAuthorityCheck` (~2024) | "no commits in range": `UNGRADED`, and **silent on the Lite lane** | 2 |
| G7 | `git show <ref>:<path>` in `Get-BlobLines` (~1452) | an empty blob: a document with no content, an unapproved amendment passes the visibility and checkbox comparisons | 2 |
| G8 | `git show -U0 --format='' <commit> -- <path>` in `Get-AddedRecordLines` (~1511) | no added lines: an approver record is "missing", or a record is never read | 2 |
| G9 | `git rev-parse <c>:<p>` compared with `git rev-parse <parent>:<old>` (~1874, ~2142) | **both fail: `$null -eq $null` is true**, so a rename is read as "content came across intact" and escapes grading | 2 |
| G10 | `git ls-tree -r --name-only <c> -- <dir>` (~1880) | "the old directory holds no graded document": a renumbering is assumed | 2 |
| G11 | `git log --follow --format=%aI` in the Critical cooling-off check (~541) | "no git history": it **fails**, but names the wrong cause (a commit is asked for) | 3 |
| G12 | `git log -1 --date=format:%Y-%m-%d` in `Get-SurfaceExceptions` (~972) | falls back to the runner's clock, which the comment above it says must not be the ceiling | 3 |
| G13 | `git diff --name-only HEAD` (uncommitted, `territory-check.ps1` ~97) and `git ls-remote --heads origin` (~103) | the branch's own uncommitted files drop out; "no open branches" | 4 |
| G14 | `git log -1 --format=%ct origin/<other>` and `git diff --name-only <base>...origin/<other>` (~228-229) | an open branch reads as "no overlap" | 4 |

*Out of scope, with the reason* (recorded in `notes.md` with the probe): `git cat-file -e HEAD:./<artifact>` (~408) and `git rev-parse --verify --quiet` (~1793, ~223 of territory-check):
git gives the **same exit code (128 / 1) for absent and for unreadable**, so the read cannot be graded on its exit code alone, and the arm that follows is already strict by design (an
artifact not found is a failure, not a pass); `git rev-parse --is-shallow-repository` (~440, ~1997): a failed answer reads as "not shallow", which is the safe direction (the history
is then read and its own reads are checked); `git rev-parse --abbrev-ref HEAD` (~183) and the territory-check `git branch --show-current` reads: the pack and the check stop earlier
if there is no repository, and an empty branch name fails the lane dispatch loudly. **Each of these is a claim the plan's phase 1 probe confirms before it stands (D8); a read the
probe shows to swallow a verdict-changing failure moves into the graded set.**

## Technical Context

**Language/Version**: PowerShell 7+ (`pwsh`); `git` 2.38 or newer already required (026); this machine has 2.55
**Primary Dependencies**: none new
**Storage**: files and git state only
**Testing**: the enforcement harness (`tests/enforcement/`): real temporary git repositories, hand-written expectations, a passing and a failing fixture per rule; every pre-existing case passes unchanged (FR-008)
**Target Platform**: any runner with `pwsh` and `git`
**Project Type**: governance tooling (scripts plus documents)
**Constraints**: a read that exits 0 with empty output prints byte-identical output on every lane; no new verdict word; the Lite lane is never newly failed; one cause prints one line (no double of 026/027/028's named states); no `git` call is added to a healthy run
**Scale/Scope**: two scripts, one generic reader, one policy function, 14 graded reads, about 30 fixture cases, four documents, digests

## Constitution Check

- [x] **Specification First (I)**: `spec.md` is approved (anas.m, 2026-10-15); this plan follows it; `tasks.md` follows once the plan is approved. No approved document is amended.
- [ ] **Repository Separation (III)**: not applicable, the kit is one repository.
- [x] **Architecture Consistency (IV)**: no new script; the reader and policy sit beside 028's helpers in `scripts/enforcement-pack.ps1` (D1, D2); `territory-check.ps1` keeps its own vocabulary (D6).
- [ ] **Domain Invariants (V)**: not applicable, the template's slot is unfilled.
- [x] **Security (VI)**: only `git` reads that already run; nothing sensitive read; no object written (the merge-tree read already exists and is unchanged).
- [ ] **External Integration Governance (VII)**: not applicable.
- [x] **Testing Requirements (VIII)**: every graded read has a failing and a passing fixture, written first and shown failing on the parent commit; mutations guard the new branches.
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI review with Reviewer Provenance.
- [x] **Controlled Delivery (X)**: five phases, one at a time, each independently revertible; this changes an enforcement member, so the owner runs the gate: no batching, no ci-held.

**Phase sizing rule**: each group is one independently revertible slice with its own fixtures; reverting 5, then 4, 3, 2, 1 leaves a consistent kit (the generic reader and policy land in
phase 1 and are unused code if later phases are reverted, which is harmless).

**Post-design re-check**: no new violation. D3 (numbered lane fails once per read), D4 (Lite lane silence becomes a line) and D6 (territory-check's exit behaviour) are decisions the owner makes by approving or changing this plan.

## Decisions

**D1 — One generic reader; `Read-DiffLines` is not edited (FR-002, FR-008).** `Read-GitLines -GitArguments <string[]>` runs `& git @GitArguments 2>$null`, captures `$LASTEXITCODE` in the statement
after the call, and returns `@{ Ok; Lines; Exit }`; on a non-zero exit `Lines` is empty (a partial result is discarded, as 028 FR-008). On success `Lines` is the output exactly as the
call site receives it today (no filtering the site did not do), so a healthy read is byte-identical. `Read-DiffLines` stays as it is (it filters empty entries, which the other sites do
not); the two are siblings, not a refactor of 028's merged code.

**D2 — One policy function per script, by lane (FR-003, FR-004).** `Add-GitReadUnreadable -Reader -Read -Branch -Exit -Consequence`: numbered lane (`^\d{3}-`) appends
`GitReadUnreadable: <Read> failed on '<b>' (git exited <n>), so <Consequence> - repair the repository (a damaged object, or fetch the full history)` to `$failures`, **once per distinct
`Read` per run** (028's once-per-run flag would hide a second, different failed read); Lite lane appends one `<Reader>: <Read> could not be read (git exited <n>), so <Consequence>`
to `$ungraded`, no dedupe. Trunk branches never reach it. Reads inside the amendment check keep that check's existing refusal text ("cannot grade '<b>' — ...") instead of a new one, so
a failure there reads as it does for the unreadable-parent case of 026 (D6 of that feature): the policy function is for the reads that had no refusal at all.

**D3 — The group's check names what it graded (FR-003, FR-005).** G1-G3 (phase 1): `MicroLane` on the numbered lane fails with the commit and the consequence ("the phase's size could not be
measured, so the 400-line bound graded nothing"); `PhaseSizeWarning` (a warning check on every numbered branch) prints one `UNGRADED` line, not a failure, because the check is advisory today.
G4-G10 (phase 2) reuse the amendment check's refusal shape. G11 (phase 3) keeps its failure and names the true cause (the read failed, not "no history"). G12 names the fallback as an
`UNGRADED` note on every lane and keeps the author's-day-else-clock rule only when git says the commit has no date.

**D4 — The `$null -eq $null` shape (G9) is a comparison bug, not a message bug.** The two `rev-parse` calls feeding `$sameContent` are read through `Read-GitLines`; if **either** fails
the rename is **not** "content intact" and is graded (refused on the numbered lane, `UNGRADED` on Lite), never skipped. Fixture: a renamed approved document whose blob is
truncated, expected to be graded, failing on the parent (which skips it).

**D5 — Phases follow the groups, smallest-blast-radius first (FR-012).** 1: Micro and phase-size (reproduced, shallow dependency surface). 2: the amendment and history reads (the largest
group; G9 is the most dangerous, G5 the broadest). 3: Critical-arm and surface-exception reads. 4: `territory-check.ps1`. 5: documents and the replay. The inventory and the probe come
first, in phase 1, and **the probe runs before any code changes**.

**D6 — `territory-check.ps1`, its own vocabulary and exit behaviour (FR-007).** The own-tree reads (G13: the uncommitted diff, `ls-remote`) are refusals, as the script's own committed-diff
read already is (`Stop-Refused`, the script's existing exit). The other-branch reads (G14) become an `ungraded` record with cause `diff-failed` (the shape of `claim-skipped`), so "no overlap"
is never printed for a branch that was not compared. The plan states the exit codes of the four paths in a table at the top of phase 4's tasks; none is a new code. GAP-029 (the script
speaks no kit vocabulary) stays open and is not fixed here.

**D7 — Fixtures, one per graded read, built from field shapes (FR-009).** The harness reaches the state with `truncateBlob` (naming a **directory** path to break a subtree, 028's finding).
Each fixture differs from its control in one condition: the read's object is truncated vs readable. Rule ids: a new `GITREAD-001`..`GITREAD-014` family (one id per graded read; the pass
direction is the readable control) plus the existing `MICRO-*`/`AMEND-*` ids for the controls. Where `truncateBlob` cannot reach a read (e.g. `git ls-remote` against a remote), the fixture
uses the nearest state (a remote URL that fails) and the task says so. Every emission site is inventoried in `tests/enforcement/rules.json`.

**D8 — The probe comes before the classification stands (FR-001, FR-006).** Phase 1's first task runs every read in the inventory against a damaged repository and records, in `notes.md`,
the exit code and whether the read returned lines. The classes above are the plan's prediction; the probe is the authority. A read predicted *named already* or *out of scope* that the probe
shows to swallow a verdict-changing failure is added to the graded set **in its group's phase**, and the plan is amended with an approver record (the owner approves the amendment, not
the author).

**D9 — The replay is per merge, over real history (FR-010, SC-005).** 028's D10 method, reporting the number of runs, outputs that differ (expected none), the reads each run exercised
(counted by an instrumented copy of the reader), and what it does **not** show (damaged repositories: the fixtures do).

## Phases

Detailed tasks and the per-phase **Territory** blocks are in `tasks.md`.

1. **Probe, generic reader, policy, Micro and phase-size reads (G1-G3).** D1, D2, D3, D8. Delivers US1, FR-001, FR-002, FR-005, FR-008, FR-009 for the reproduced hole: the probe table in `notes.md`, then fixtures first (shown failing on the parent), then the code.
2. **Amendment and history reads (G4-G10).** D2, D3, D4. FR-002 to FR-004, FR-006.
3. **Critical-arm and surface-exception reads (G11, G12).** D3. FR-002 to FR-004.
4. **`scripts/territory-check.ps1` (G13, G14).** D6. US3, FR-007.
5. **Guidance, retirement of the limits, flow-down, replay.** D9 and the documents (US4, FR-010, FR-011, FR-012 of the spec's numbering).

## Project Structure

### Documentation (this feature)

```text
specs/029-unchecked-git-reads-named-state/
├── spec.md
├── plan.md              # this file
├── tasks.md
├── notes.md             # the probe table, phase evidence, the replay
└── checklists/requirements.md
```

### Source Code (repository root)

```text
scripts/enforcement-pack.ps1               # phases 1-3: Read-GitLines, Add-GitReadUnreadable, the graded reads, the LIMITS comments
scripts/territory-check.ps1                # phase 4: G13, G14
tests/enforcement/rules.json               # phases 1-4: GITREAD-001..014 and the controls
tests/enforcement/cases/enforcement-pack/  # phases 1-3: the fixtures
tests/enforcement/cases/territory-check/   # phase 4 (the directory the existing territory cases use; the first task confirms the path)
adoption/updating.md                       # phase 5: flow-down note (supersedes 028's open-limit wording)
docs/roadmap.md                            # phase 5: GAP-035 shipped
docs/digests/**                            # phase 5
```

**Structure Decision**: no new script and no new library file; both scripts already ship verbatim, so `kit-manifest.json` needs no entry. Checks that already name their failure are not
edited. `specs/028-*` is history and is not edited.

## Testing Strategy

- Each rule is first written as a failing fixture and shown failing on the parent commit, then the behaviour lands; controls (readable, empty, no base, shallow, trunk) are named as such.
- Every pre-existing case passes unchanged after each phase; `-Case GITREAD-`, `-Case MICRO-`, `-Case AMEND-`, `-Case CRIT-` per phase; the full harness on an isolated checkout of the final commit.
- A mutation is shown for each new fixture that guards a branch of the new code (the exit-code capture, the discard of partial output, the per-read once-only key, the Lite no-dedupe, the
  `$null -eq $null` arm), restored byte for byte (feature 025's method).
- Phase 5's replay over real history, recorded in `notes.md`.

## Risks

- **A numbered branch can newly fail** on a damaged repository (the owner's Decision 2). The replay counts it on real history (expected none).
- **The inventory is by reading.** D8: the probe is the authority; a read that the probe moves is an owner-approved amendment, not an author's edit.
- **G9 changes behaviour on a damaged repository from skip to graded.** Intended; healthy runs are byte-identical (SC-004).
- **`git cat-file -e` and `rev-parse --verify --quiet` cannot tell absent from unreadable** by exit code. Stated as a limit, with the probe; not narrowed here.
- **A read that exits 0 with wrong content (silent corruption) is not detectable.** Stated, not narrowed.
- **Five phases** is long for one gap; the alternative (fewer, larger phases) trades review size for ceremony. See "Needs the owner".

## Needs the owner

1. **D2, one failure per distinct read per run** (so two different failed reads are two lines). Recommended. Alternative: one line per run, as 028, which hides the second read.
2. **D3, `PhaseSizeWarning` becomes `UNGRADED`, not a failure, when its read fails** (it is advisory today). Recommended. Alternative: fail on the numbered lane, which turns an advisory check into a gate.
3. **D6, `territory-check.ps1`'s own-tree reads refuse and the other-branch reads are `ungraded` records.** Recommended. Alternative: refuse on every read, which stops a check for a branch it cannot compare.
4. **D5, five phases.** Recommended. Alternative: fold phase 3 into phase 2 (about 12 reads in one phase).
5. **The plan's approval.** `tasks.md` follows once it is given.

## Complexity Tracking

No constitution violation to justify.
