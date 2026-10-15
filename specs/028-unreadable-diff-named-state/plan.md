# Implementation Plan: Make an unreadable diff a named state, not an empty changed-file list

**Branch**: `028-unreadable-diff-named-state` | **Date**: 2026-10-15 | **Spec**: specs/028-unreadable-diff-named-state/spec.md
**Input**: Feature specification (approved, anas.m, 2026-10-15; Decision 1 option B, Decision 2 the three readers in `scripts/enforcement-pack.ps1`) + decisions D1–D10 below
**Gate Batching**: none
**Gate Certification**: user-run
**Status**: Approved 2026-10-15 (owner: anas.m)

## Summary

Three places in `scripts/enforcement-pack.ps1` run `git diff ... 2>$null` and read an empty result as "nothing changed": `Get-ChangedFiles` (feeds `Invoke-LiteAndAbuseCheck`, the
Lite amendment gate and the count line), `Invoke-ReviewProvenanceCheck`'s `--name-status` read, and the Lite amendment gate's second `--no-renames` read. This feature puts
all three behind **one helper** that returns `Ok`, the lines and the exit code, and makes a non-zero exit a **named state**: the count line says the diff was unreadable
instead of `0 changed file(s)`; a numbered branch fails once with the cause; a Lite branch (`fix/`, `chore/`, `docs/`) prints one `UNGRADED:` line per check that graded
nothing and exits 0 (014 FR-009; the lane split of 027's D8). A partial list from a failing diff is discarded. Nothing about a readable, empty, base-less or shallow diff
changes.

Three phases, each independently revertible. **Phase 1** is the helper, the count line and the two lane arms for `Get-ChangedFiles`'s consumers (`LiteAndAbuse`, numbered
lane), fixtures first. **Phase 2** moves the other two readers (review-provenance, the Lite gate's second read) onto the helper. **Phase 3** is guidance, retirement of 027's limit
in the documents, and the replay. The lesson 024 to 027 paid for governs: **fixtures are built from field shapes** (the `fix/` reproduction in the spec, 026's unreadable merge parent,
a `docs/` branch, an empty-diff control), and the replay on real history is part of the feature.

**The harness needs no new capability, and the spec's guess about how to reach the state was wrong in a useful way.** The spec assumed `truncateCommit`. A truncated commit
object makes `git merge-base` fail first, so the pack lands in the already-named *no base* state, not this one. `truncateBlob` naming a **directory** path does reach it:
`rev-parse HEAD:<dir>` resolves to a tree object, and truncating the subtree the branch changed makes `git diff --name-only <base> HEAD` fail with exit 128 while the base is
still computed (checked by hand on 2026-10-15 on the reproduction repository). Phase 1 proves it with its first fixture; if a case cannot be expressed, the gap is a task of that
phase, not a surprise later.

## Technical Context

**Language/Version**: PowerShell 7+ (`pwsh`); `git` 2.38 or newer already required by 026 (this machine has 2.55)
**Primary Dependencies**: none new
**Storage**: files and git state only
**Testing**: the enforcement harness (`tests/enforcement/`): real temporary git repositories, hand-written expectations, a passing and a failing fixture per rule. Every pre-existing
case passes unchanged (FR-009).
**Target Platform**: any runner with `pwsh` and `git`
**Project Type**: governance tooling (scripts plus documents)
**Constraints**: an empty readable diff, a missing base, a shallow clone and a trunk branch print byte-identical output on every lane (FR-007); no new verdict word (UNGRADED, FAIL
and OK exist); the Lite lane is never newly failed (014 FR-009); no other member of `enforcement-pack.ps1` changes; `scripts/territory-check.ps1` is not touched (Decision 2)
**Scale/Scope**: one helper, three call sites, one dispatch line, one new failure site and one new ungraded site, about 14 fixture cases, four documents, digests

## Constitution Check

- [x] **Specification First (I)**: `spec.md` is approved; this plan follows it; `tasks.md` follows once the plan is approved. No approved document is amended by this feature.
- [ ] **Repository Separation (III)**: not applicable, the kit is one repository.
- [x] **Architecture Consistency (IV)**: no new script; the helper lives in `scripts/enforcement-pack.ps1` beside `Get-ChangedFiles` (D1).
- [ ] **Domain Invariants (V)**: not applicable, the template's slot is unfilled.
- [x] **Security (VI)**: the helper runs `git diff`, as three call sites already do; nothing sensitive is read; no object is written.
- [ ] **External Integration Governance (VII)**: not applicable.
- [x] **Testing Requirements (VIII)**: every rule has a passing and a failing fixture, hand-written, failing first on the parent commit.
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI review with Reviewer Provenance.
- [x] **Controlled Delivery (X)**: three phases, one at a time; this changes an enforcement member, so the owner runs the gate: no batching, no ci-held.

**Phase sizing rule**: phase 1 is the core and is useful alone (the reproduced hole closes). Phase 2 adds two readers that share the helper; phase 3 is documents and a
measurement. Reverting 3, then 2, then 1 leaves a consistent kit.

**Post-design re-check**: no new violation. D3 (the numbered lane fails, with one line), D4 (the Lite gate prints a line where it was silent) and D2 (the count line's new text) are
decisions the owner makes by approving or changing this plan.

## Decisions

**D1 — One helper reads the diff, and a failure is a value (FR-001, FR-008, Decision 2).** A function beside `Get-ChangedFiles`, `Read-DiffLines`, takes the `git diff`
arguments, runs `git @Arguments 2>$null`, captures `$LASTEXITCODE` **in the statement that follows the call** (before any pipeline can reset it), and returns
`@{ Ok; Lines; Exit }`. On a non-zero exit `Lines` is **empty** whatever git printed (a partial list is discarded, FR-008). On success `Lines` is the output with empty entries
removed, exactly the shape the three sites read today, so a readable diff is byte-identical. The three sites call it with their existing arguments (`--name-only <base> HEAD`;
`-c core.quotepath=off diff --name-status --diff-filter=AR <base> HEAD`; `-c core.quotepath=off diff --name-only --no-renames <base> HEAD`). No other `git` call changes.

**D2 — `Get-ChangedFiles` keeps its signature and its return type; the state is carried beside the list (FR-001, FR-002).** The function still returns the array the dispatch
passes on. On a non-zero exit it returns `@()` and sets `$script:ChangedFilesRead = @{ Ok = $false; Exit = <n> }` (set to `Ok = $true` on success and by the no-base early return,
so a missing base is **not** this state). The count line at the dispatch becomes, only when the read failed:
`enforcement-pack: branch '<b>', diff base '<sha>', diff unreadable (git diff exited <n>)`; otherwise the line is the one printed today, byte for byte. The text carries the exit
code and no git message: git's stderr stays discarded (deterministic output; the spec's assumption).

**D3 — One policy function applies the lane split (FR-003, FR-004; Decision 1 option B).** `Add-DiffUnreadable -Reader <name> -Branch <b> -Exit <n> -Consequence <text>`:

- **Numbered lane** (`^\d{3}-`): `$script:failures += "DiffUnreadable: git diff against '<base>' failed on '<b>' (exit <n>), so <Consequence> — repair the repository (a damaged
  object, or fetch the full history: 'fetch-depth: 0' on actions/checkout)"`. **Once per run**: a flag (`$script:DiffFailureReported`) stops a second reader of the same
  damaged diff from adding a second failure line; a reader whose own read fails while the first read succeeded adds its own line.
- **Lite lane** (`fix/`, `chore/`, `docs/`): `$script:ungraded += "<Reader>: the diff of '<b>' against '<base>' could not be read (git diff exited <n>), so <Consequence>"`, one line
  **per reader**, no dedupe: each check names itself, so a reader of the run can see which guards did not run. The exit code is not changed (the existing UNGRADED path ends on
  `enforcement-pack: UNGRADED`, exit 0).
- A trunk branch never reaches it (no diff is read, as today).

**D4 — The Lite amendment gate reads through the helper and names itself (FR-006).** In the Lite arm of `Invoke-AmendmentAuthorityCheck` (027 D6) the gate list is
`$ChangedFiles` plus the second `--no-renames` read. If the first read failed (`$script:ChangedFilesRead.Ok -eq $false`) or the second read fails, the arm calls the policy function
with Reader `AmendmentAuthority` and Consequence "no spec document changed on this branch could be graded", and **returns** without running the core. This is the one place a Lite
branch that touches no spec document prints a line it did not print before, and only when a base exists and the diff failed (FR-007). 027's `LIMITS` comment and its flow-down
limit (3) are superseded by this decision.

**D5 — `Invoke-ReviewProvenanceCheck` reads through the helper on every lane (FR-005).** Its `$rows = git ... --diff-filter=AR` becomes a helper call; on a failed read it calls the
policy function with Reader `ReviewProvenance` and Consequence "no review file added on this branch was inspected - the machine half of DoD gate 5 formed no opinion", and
returns (as its no-base arm does). The numbered lane's once-only flag covers the case where the dispatch already reported the same failure.

**D6 — The consumers of the empty list need no change beyond reading the state (FR-003).** `Invoke-LiteAndAbuseCheck` is called by the dispatch only on `fix/` and `chore/`: when
`$script:ChangedFilesRead.Ok` is false the dispatch calls the policy function with Reader `LiteAndAbuse` and Consequence "the prohibited-category and file-count guards graded an
EMPTY file list" **instead of** calling the check on a list it knows is not the branch's (the existing no-base arm already adds an UNGRADED line and still calls it on `@()`;
the new arm does not call it, so no failure line can be produced from an empty list). The function itself is not edited.

**D7 — Verdicts and exit codes use the existing machinery (FR-003).** No new verdict word, no new exit code: a numbered failure exits 1 through `$failures`; a Lite state exits 0
through `$ungraded`, with the verdict `enforcement-pack: UNGRADED (N check(s) formed no opinion)`. `docs/` branches keep the lane line (its wording is already conditioned on what
ran, 027 phase 2).

**D8 — Unchanged states, by construction (FR-007).** The state is entered only on a non-zero exit with a base present. `Get-ChangedFiles` returns before running git when there is no base,
so the missing-base warning and the Lite UNGRADED line print exactly as today and the new line cannot double them. A shallow clone with a base reads its diff normally (the two trees of
the diff exist in a shallow clone; only the parents are cut), so the shallow fixtures of 027 are controls and stay byte-identical. An empty diff exits 0 with no lines. The helper
adds no `git` call.

**D9 — Fixtures, built from field shapes (FR-009, SC-001 to SC-003).** Each pair differs in one condition. Rule ids: a new `DIFF-001` (the numbered failure site) and `DIFF-002`
(the Lite UNGRADED site, whose `pass` direction is the numbered twin and exits 1, as `AMEND-009` does), plus variants under `LITE-*` for `LiteAndAbuse`; every emission site
inventoried in `tests/enforcement/rules.json`. The base holds a README; the damage is a `truncateBlob` that names a **directory** path.

| Variant | Expected |
|---|---|
| `fix/x` adds `package.json` and `src/db/migrations/001.sql`, readable (the spec's reproduction, control by design) | three `LiteAndAbuse` failures, exit 1, byte-identical to the parent |
| the same with the `src` subtree truncated | count line `diff unreadable (git diff exited 128)`, one `UNGRADED` line for `LiteAndAbuse`, `ReviewProvenance` and the verdict `UNGRADED`, exit 0 (parent: `0 changed file(s)`, `OK`) |
| `chore/x`, same | as `fix/x` |
| `docs/x` changes `README.md` only, readable | byte-identical to the parent's |
| `docs/x`, a subtree truncated | `UNGRADED` lines for the amendment gate and review-provenance, exit 0, the lane line names only what ran |
| `002-b` (numbered) with a truncated subtree (026's merge-parent shape) | count line named, one `DiffUnreadable` failure, exit 1 (parent: `0 changed file(s)`) |
| a numbered branch with a readable diff, an empty diff, no base | byte-identical to the parent's |
| `fix/x` with a **partial** diff: `a/package.json` readable, `z/` truncated, so git prints `a/package.json` then fails | `UNGRADED`, **not** a `LiteAndAbuse` failure from the one name it printed (FR-008; parent: grades the partial list and fails) |
| a Lite branch whose diff is readable but the review-provenance read alone fails | one `ReviewProvenance` line (Phase 2) |
| a shallow clone with a base (027's fixtures) | byte-identical to the parent's |
| a trunk branch (`main`) | prints nothing new |

**D10 — The replay is per merge, over real history, Lite branches included (FR-010, SC-004).** The method of 027's D10: the parent kit's `enforcement-pack.ps1` and the new one,
from a scratch directory with `-Root` a clone, over each merged `NNN-*`, `fix/`, `chore/` and `docs/` branch in this kit's history and in clones of FitForge, FlowBoard and
ExpenseTracker, in the shape CI grades a pull request (the clone detached at the merge, `main` at its first parent, `-ReplayBase`, `-ReplayTip`, `-IgnoreAmendmentBoundary`), reporting
the number of runs, outputs that differ (expected none: a diff that cannot be read has never occurred in these histories), and the byte-identity of every other output. **It says
plainly what it shows:** that no healthy branch changes; it does **not** show how the new state reads on a damaged repository (the fixtures do), and it matches branches by the
subject patterns it uses, with the merges they miss counted, as 027's review found.

## Phases

Detailed tasks and the per-phase **Territory** blocks are in `tasks.md`.

1. **The helper, the count line and the first two lane arms.** D1, D2, D3, D6, D7, D8 (the `Get-ChangedFiles` consumers: the dispatch's count line, `LiteAndAbuse`, the numbered
   failure). Delivers US1, US2, US3 and FR-001 to FR-004, FR-007, FR-008, FR-009: fixtures first and shown failing on the parent, then the code, with the script's `LIMITS` comments
   changed with the code they describe (the lesson of 026's D11).
2. **The other two readers.** D4 and D5. Delivers FR-005 and FR-006: the review-provenance read and the Lite gate's second read onto the helper, with their fixtures.
3. **Guidance, retirement of the limit, flow-down, replay.** D10 and the documents. The flow-down note, the roadmap, digests, the supersession of 027's limit (3) and the replay
   (US4, FR-010, FR-012, SC-004).

## Project Structure

### Documentation (this feature)

```text
specs/028-unreadable-diff-named-state/
├── spec.md
├── plan.md              # this file
├── tasks.md
├── notes.md             # phase evidence, the baseline, the replay
└── checklists/requirements.md
```

### Source Code (repository root)

```text
scripts/enforcement-pack.ps1               # phase 1: the helper, Get-ChangedFiles, the count line, the policy function, the dispatch arms; phase 2: the two other readers
tests/enforcement/rules.json               # phases 1 and 2: DIFF-001, DIFF-002 and the LITE variants
tests/enforcement/cases/enforcement-pack/  # phases 1 and 2: the fixtures
adoption/updating.md                       # phase 3: flow-down note
docs/roadmap.md                            # phase 3: GAP-034
docs/digests/**                            # phase 3
```

**Structure Decision**: no new script and no new library file; `scripts/enforcement-pack.ps1` already ships verbatim, so `kit-manifest.json` needs no entry. `Invoke-LiteAndAbuseCheck` is not
edited; `scripts/territory-check.ps1` is not touched (Decision 2).

## Testing Strategy

- Each rule is first written as a failing fixture and shown failing on the parent commit, then the behaviour lands. Where the parent passes by design (readable, empty, no base,
  shallow, trunk) the fixture is a control, named as such.
- Every pre-existing case passes unchanged after each phase; `-Case DIFF-`, `-Case LITE-`, `-Case AMEND-`, `-Case CRIT-` per phase; the full harness on an isolated checkout of the final
  commit (feature 022's method).
- **Field-shaped fixtures are required, not optional** (D9): the `fix/` reproduction, 026's numbered unreadable shape, a `docs/` branch, the partial list.
- A mutation is shown for each new fixture that guards a branch of the new code (the exit-code capture, the discard of a partial list, the no-base early return, the numbered
  once-only flag, the Lite no-dedupe, the "do not call `LiteAndAbuse` on an empty list" arm): the code is mutated, the fixture is shown failing, the code is restored byte for byte
  (feature 025's method).
- Phase 3's replay over real history, recorded in `notes.md`.

## Risks

- **A numbered branch can newly fail.** That is the owner's decision (option B). It is a failure that names a damaged repository, a state in which the amendment check would fail on
  the same damage (an unreadable commit is refused there already); the replay counts it on real history (expected none) and the flow-down note says what to do (repair or re-fetch).
- **`$LASTEXITCODE` is easy to lose.** A pipeline or an intervening command resets it. D1 captures it in the statement after the call and a fixture per reader guards it; the
  mutation that reads it a statement late must fail a fixture.
- **A Lite branch that touches no spec document now prints a line when its diff is unreadable** (D4). This is the named state working as intended, in a damaged repository only;
  every readable run is byte-identical (SC-003).
- **A partial list is the dangerous case** (FR-008): git prints rows, then fails. The helper discards it; the `a/`-then-`z/` fixture is built to make a graded partial list visible.
- **The pack's other `git` reads** (`git log`, `git show --numstat`, `ls-tree`) may share the silence; they are outside this feature. If the replay or the fixtures show one
  swallowing a failure, it becomes its own roadmap row, not an edit here.
- **`scripts/territory-check.ps1`'s two unchecked reads stay open** (Decision 2) and are named in the flow-down note and the roadmap entry.
- **The Lite gate and the count line trust a non-zero exit as the whole truth.** A `git diff` that exits 0 with wrong content (silent corruption) is not detectable here; stated, not
  narrowed.

## Needs the owner

1. **D3, the numbered lane's failure is one line per run** (the first reader reports, later readers of the same damage stay quiet). Recommended as written. Alternative: one line per
   reader, which names every check that graded nothing at the cost of repeating the cause.
2. **D2, the text carries git's exit code and not git's message.** Recommended: deterministic output and fixtures that do not depend on git's wording. Alternative: append git's first
   stderr line, which helps a reader find the damaged object and ties expected output to a git version.
3. **D4, a Lite branch with no spec change prints an `UNGRADED` line when its diff is unreadable.** Recommended as written, the point of the feature. Alternative: stay silent when the
   first read failed and the branch touches no spec document, which keeps the gate's silence and leaves the diff unnamed for that check only.
4. **The phase count.** Recommended three (the list and the dispatch, the other two readers, the documents and the replay). Alternative: two, folding the second reader pair into
   phase 1, at the cost of a larger phase.
5. **The plan's approval.** `tasks.md` follows once it is given.

## Complexity Tracking

No constitution violation to justify.
