# AI Code Review — 015 Enforcement Assurance, Phase 6 (round 4)

**Reviewer**: fresh-context agent — claude-opus-5-5
**Date**: 2026-09-26
**Branches**: agentic-sdlc-kit `015-enforcement-assurance` (tip `045f182`, parent `a885790`)
**Scope reviewed**: I read all of `045f182` (5 files) and judged it against the phase as it now
stands (`git diff 1f05bb3 045f182`, 40 files). Read in full this round:
- the 015 flow-down note in `adoption/updating.md`, including the new five-row table;
- `docs/sdlc/review-process.md` step 3 and the `UNGRADED` paragraph under it;
- the T047 describe in `tests/enforcement/Harness.Tests.ps1`;
- the param blocks of all nine graded scripts;
- every `UNGRADED` emission site, which I listed myself:
  - `scripts/scope-check.ps1:278`, `:304`, `:309`, `:323`;
  - `scripts/scope-check-repos.ps1:328`, `:387`, `:392`, `:415`;
  - `scripts/enforcement-pack.ps1:586`, `:628`, `:679`, `:1099`, `:1266`;
- the code around those sites: `scope-check.ps1`'s `Invoke-ScopeCheck` skip paths and its HEAD
  vs `-All` modes, both scripts' `Get-DiffBase`, `scope-check-repos.ps1`'s per-repository loop,
  `enforcement-pack.ps1`'s lane dispatch, and the `UNGRADED` capture and precedence in
  `scripts/ritual-checks.ps1:184-240`.

**Feature contract**: phase 6 = T044–T053. The phase-6 Territory is:
- `tests/**`
- `.github/workflows/enforcement-tests.yml`
- `scripts/enforcement-pack.ps1`
- `adoption/updating.md`
- `docs/sdlc/review-process.md`
- `docs/digests/*-digest.md`
- the feature directory

Plan D6 holds: `UNGRADED` never moves an exit code. `**Gate Certification**: ci-held`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: Claude Opus 5.5, the implementing session that wrote `045f182`, named by the
  commit's `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` trailer. It is not this
  reviewer.
- **Inputs provided**:
  - Diffs: `git show 045f182`; `git diff 1f05bb3 045f182`.
  - Earlier reviews: the round-3 review with the implementer's Dispositions
    (`ai-code-review-phase-6-round-3.md`); rounds 1 and 2 (`ai-code-review-phase-6.md`,
    `ai-code-review-phase-6-round-2.md`).
  - Feature and law documents: `specs/015-enforcement-assurance/{spec,plan,tasks,notes}.md`;
    `CLAUDE.md`; `.specify/memory/constitution.md`; `docs/sdlc/definition-of-done.md`;
    `docs/sdlc/review-process.md`; `specs/_templates/ai-code-review-template.md`.
  - Commands in the main tree: `gh run list`/`gh run view` for sha `045f182`; `scope-check.ps1`
    and `ritual-checks.ps1` at HEAD.
  - In a scratch clone of `045f182`: the Harness and Coverage Pester files; two T047 mutations;
    and `scope-check.ps1`, `scope-check-repos.ps1` and `enforcement-pack.ps1` against six
    hand-built full-history fixture repositories (described below).
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES.**

**The mechanical fixes check out.** I measured each one:
- **F3**: a foreign `-BaseRef` now fails T047; removing `-BaseRef` from the list makes the same
  mutation pass.
- **F4**: zero control bytes in 1,192 files.
- **No regressions**: Harness + Coverage 33/33; `scope-check` PASS; `ritual-checks` RESULT OK.

**The table is a real improvement.** Its five rows are accurate for the cases they describe; I
reproduced rows 1–4 on fixtures. Round 3's specific counter-examples are now handled: spec-only
branches, governance CI and a trunk not named `main`.

**F1 blocks.** The table carries the same kind of claim that blocked rounds 2 and 3. It says
"This table is every state that produces the word; it was written from the thirteen places … not
from memory." I found two full-history states it does not list:
- `scope-check.ps1` in its default HEAD mode, the exact command `CLAUDE.md` step 7 and
  review-process step 3 prescribe, run on a non-phase `HEAD` of a branch that already has graded
  phase commits.
- A multi-repo run where one code repository grades and another prints its own `UNGRADED`.

**The new review-process text (the F2 fix) is false for the common multi-repo case.** It says "a
phase that touches no code repository gets `not applicable` on each repository's line and then
a run-level `UNGRADED`". Once any earlier phase of the feature touched a code repository, that
phase instead gets `PASS phase 1 commit …` under both invocation forms. Table row 5 repeats the
same wrong gloss.

The fix is prose only, and small: scope the completeness claim or add the rows, and say
"feature" where the text says "phase".

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match | **F1 table, row by row**, in fixtures with full history. See "Row-by-row" below. |
| Visual-reference match | N/A — no UI. |
| Feature contract held | `045f182` has no package, workflow or script change. All five files are inside the phase-6 Territory or the feature directory. |
| Constitution / domain invariants | `spec.md`, `plan.md`, `tasks.md` and `contracts/` are untouched by `045f182`, so there is no amendment. |
| Security | N/A — tests and prose. |
| Scope guard | `pwsh -File scripts/scope-check.ps1` → `scope-check: PASS phase 6 commit 045f182 (5 file(s))`, exit 0. |
| Whole-run verdict | `pwsh -File scripts/ritual-checks.ps1` at HEAD → doc-lint, enforcement-pack, scope-check, digests and roadmap-claims `OK`; scope-repos and verify-kit `n/a`; `RESULT OK`, exit 0. |
| F3 (T047 `-BaseRef`) | **Completeness**: the ref-naming parameters declared across the nine graded scripts are `-Branch`, `-Commit`, `-ReplayBase`, `-ReplayTip` (enforcement-pack), `-BaseBranch` (territory-check) and `-BaseRef` (scope-check-repos). `-Repo` is a directory name and `-Root` is a path. The scanned list is now complete. **Mutation**: `REPOS-017/pass` args + `-BaseRef 015-enforcement-assurance` → the T047 test fails with "passes -BaseRef '015-enforcement-assurance', which its fixture never creates (it creates: 001-thing, main)" (0/1). **Control**: with `-BaseRef` removed from `$revisionArgs`, the same mutation passes (1/1). Clean HEAD → 1/1. No case uses an abbreviated parameter name (the args in use are `-All -Branch -Check -Commit -FailOnSlots -Json -ReplayBase -ReplayTip -Repo`), so PowerShell's prefix binding does not open a gap today. |
| F4 (0x08) | I byte-scanned every tracked file in the phase-6 Territory and the feature directory (1,192 files) for bytes 0x00–0x08, 0x0B, 0x0C and 0x0E–0x1F: **zero hits**. `notes.md:2381` and `:2555` now read `` `\b` ``. |
| Rollback safety | Reverts cleanly: prose, one test list entry, notes. |

### Row-by-row: the `adoption/updating.md` table against the code

I independently enumerated 13 `UNGRADED`-printing sites, the same count the implementer gives:
- 4 in `scope-check`;
- 4 in `scope-check-repos`: 2 run-level, 2 per-repository;
- 5 `$ungraded +=` sites in `enforcement-pack`, printed via `:1281`/`:1292`.

| Row | Measured | Verdict |
|---|---|---|
| 1 Detached HEAD | Detached fixture: `scope-check: UNGRADED detached HEAD — pass -Branch …` (`:278`). `scope-check-repos:328` is the same, reached only after `codeRepos` is declared. | Correct. |
| 2 No merge base | Trunk `master`, `001-thing` with a spec commit. `scope-check`: `UNGRADED could not resolve a merge base with main`. `enforcement-pack`: the `WARNING: … no integration branch …` line, then `UNGRADED: ReviewProvenance`, then `UNGRADED: PhaseSizeWarning`, then `FAIL` (amendment check). The lane lists match the dispatch at `enforcement-pack.ps1:1253-1275`. | Correct, except two MINOR points (F3). **MicroLane** appears only on a feature whose spec declares Micro (`:522` returns first otherwise), and the fixture run did not print it. The "trunk not named `main`" cell says what does not help, but not what does. |
| 3 Empty range | Code paths `scope-check.ps1:309` and `enforcement-pack.ps1:1099`. The amendment line clears with any commit; scope-check's clears with the first graded phase commit. | Correct. |
| 4 All commits skipped | Spec-only `001-thing` with trunk `main`: `not applicable (… no 'phase N' token …)`, then `UNGRADED no commit on '001-thing' was graded`. | Correct for `-All`. One pre-006 cause is missing: **no `tasks.md` at all** (`scope-check.ps1:215` WARN). Measured: `002-thing` with `phase 1: thing` and no `tasks.md` → `WARN … tasks.md not found …` then `UNGRADED`. The row names only "a `tasks.md` that declares no Territory". MINOR (F3). |
| 5 Multi-repo, nothing graded | The listed per-repository reasons match `:349`, `:368`, `:387`, `:392` and a SKIP verdict. | Two omitted reasons: `:357` "present but not a git repository" and `:363` "not a repository of its own". The gloss "no feature branch there (a phase that touched no code repository)" is wrong; see F1(b). |

## Findings

### F1 — The table's "every state" claim and the new review-process sentence are both measured false — BLOCKING

Three separate problems, all in text written by `045f182`.

**(a) Missing state: HEAD mode on a non-phase HEAD.** `CLAUDE.md` Workflow step 7 and
review-process step 3 both prescribe the plain command `pwsh -File scripts/scope-check.ps1`,
without `-All`. In that mode only `HEAD` is examined (`scope-check.ps1:316`). If `HEAD`
carries no `phase N` token, `:323` prints `UNGRADED`, however many phase commits were graded
before it.

- **Measured** on fixture `s1`: `main`, then `001-thing` with commits `spec: 001 thing`,
  `phase 1: code` (inside its declared Territory), then `notes: record owner decision`.
- Default mode printed `not applicable (commit 343c78c carries no 'phase N' token …)`, then
  `scope-check: UNGRADED no commit on '001-thing' was graded — the reason is on the line(s)
  above`, and exited 0.
- `-All` on the same fixture printed `PASS phase 1 commit bf28711`.

No row describes this state. Row 4 ("whose commits are all skipped … the word goes with the
first phase commit") is contradicted by it: this branch has a graded phase commit, and the word
comes back with every later non-phase commit. The note is framed around `ritual-checks`, which
always passes `-All`. The table's sentence, though, says "every state that produces the word"
from "the thirteen places … that print it", and `:323` is one of those places.

**(b) Wrong condition: code-free phase vs code-free feature.** Review-process step 3 now says
"A phase that touches no code repository gets `not applicable` on each repository's line and
then a run-level `UNGRADED`". Table row 5 glosses the per-repository reason as "no feature branch
there (a phase that touched no code repository)" and gives "code-free phases" as its expected
case.

The code keys on whether the code repository has a branch named after the **feature**
(`scope-check-repos.ps1:366-368`). It does not look at whether the current phase touched that
repository.

- **Measured** on fixture `gov`: `codeRepos: ["api"]`, and the governance `001-thing` declares
  phase 1 = `api/src/**` and phase 2 = `docs/**`. `api/001-thing` carries `phase 1: code`. The
  governance repository's last commit is `phase 2: docs only`, which touches no code repository.
- `scope-check-repos.ps1 -All -Branch 001-thing` printed `scope-repos: api: PASS phase 1 commit
  43e6c07 (1 file(s))` and exited 0. The review-process form (no `-All`, no `-Branch`) printed
  the same.
- Neither run printed `not applicable` or `UNGRADED`.

So the sentence is true only for a feature that has no branch in any present code repository.
For phase 2 onward of any feature whose phase 1 touched code, it is false. That is the ordinary
multi-repo shape: FitForge's features all touch `fitforge-api` or `fitforge-web`.

A reviewer who follows step 3 is told to expect `UNGRADED` and write a reason. What they get
instead is a `PASS` for an earlier phase's commit, and the text does not warn them it is not a
grade of this phase.

**(c) Missing state: partial multi-repo grading.** A run can have one code repository graded and
another printing a per-repository `UNGRADED`.

- **Measured** on fixture `gov` with `web` added: trunk `develop`, no `origin/HEAD`, and a
  `phase 1` commit on `001-thing`.
- Output: `api: PASS phase 1 commit …`, then `web: UNGRADED could not resolve a merge base with
  a trunk (…) — NOTHING WAS GRADED in this repository; pass -BaseRef <ref> naming its trunk`,
  then exit 0 with no run-level line.
- The table's only multi-repo row requires "nothing graded in **any** declared code
  repository".

The wrapper consequence is recorded separately as F2.

This is the defect this feature keeps producing: a completeness claim in adopter- and
reviewer-facing prose that the emission sites do not support. The implementer's disposition
strengthened the claim ("every state … not from memory") without closing it. The harm is
smaller than in round 3, because nothing here sends an adopter to the wrong remedy. Two things
still make it blocking:
- review-process step 3 is the text reviewers act on, and it now describes a verdict the code
  does not produce;
- the note asserts a completeness it does not have.

*Action: implementer, prose only, in `adoption/updating.md` and `docs/sdlc/review-process.md`.*
- *Scope the completeness sentence to what the table actually enumerates (for example, "every
  state in which a `ritual-checks` run reports a member `UNGRADED`"), or add rows for (a) and
  (c).*
- *For (a), state that the plain `scope-check.ps1` form grades `HEAD` only, so a non-phase `HEAD`
  reads `UNGRADED` regardless of earlier phases.*
- *In step 3 and row 5, replace "a phase that touches no code repository" with "a feature that
  has no branch in any present code repository".*
- *In step 3, say that a later code-free phase of a feature that touched code earlier gets
  `PASS` for that earlier phase's commit(s). That is not a grade of the current phase.*

### F2 — A code repository that graded nothing is summarised as `OK` when a sibling repository graded — NON-BLOCKING

This follows from F1(c). `ritual-checks.ps1:199` reads a member as `UNGRADED` only on a line
anchored `^scope-repos: UNGRADED`. The per-repository line is `scope-repos: web: UNGRADED …`.
`scope-check-repos.ps1:415` prints the run-level `UNGRADED` only when `$graded -eq 0`. So in the
measured `api`+`web` fixture the member exits 0 with no run-level line, and the wrapper renders
`scope-repos OK`, while `web` was not graded at all.

That is GAP-027's shape at the repository level: FR-010 says "a member that cannot grade MUST
NOT report the state that a fully graded pass reports". Whether FR-010 is meant to reach a
partially graded member is a design question. The fix would be in `scope-check-repos.ps1` or
`ritual-checks.ps1`, and both are outside the phase-6 Territory. It is not a regression: phase 5
shaped `:415` this way, and before 015 the same run was `OK` too.

*Action: owner decision, recorded in `notes.md`. Either accept "some repository graded" as a
graded member and say so in the note, or open a roadmap row for a later feature. No change to
phase 6 code.*

### F3 — Smaller inaccuracies in the table — MINOR

- **Row 2** lists `MicroLane` "on `NNN-*`". It fires only on a feature whose spec declares
  Micro (`enforcement-pack.ps1:522`), and my Standard-feature fixture did not print it.
- **Row 2**'s trunk-not-`main` cell says what does not help ("no fetch setting helps") but gives
  no action. Round 3 suggested stating that the governance repository's trunk must be `main`.
- **Row 4** omits the other pre-006 WARN, where no `tasks.md` exists at the commit or its parent
  (`scope-check.ps1:215`). Measured: this produces `UNGRADED`.
- **Row 5** omits two per-repository reasons: "present but not a git repository" (`:357`) and
  "not a repository of its own" (`:363`).
- **Row 5**'s remedy "pass `-BaseRef <trunk>`" cannot be applied through `ritual-checks.ps1`,
  which takes only `-Branch`/`-Root` and forwards no `-BaseRef` (`:132-151`). A CI run through
  the single entry point therefore stays `UNGRADED`. The row should say to run
  `scope-check-repos.ps1 -All -BaseRef <trunk>` directly. Note that `origin/HEAD` is also a
  candidate, so a normal clone of a `develop`-trunk repository usually resolves anyway.

*Action: implementer, alongside F1. One clause each.*

## Round-3 dispositions, verified

| Finding | Claimed | Verified? |
|---|---|---|
| F1 (BLOCKING) | Fixed by rebuilding as a table from the 13 sites | **Partly.** The 13-site count is right, and rows 1–4 are accurate for what they describe. Round 3's three counter-examples (spec-only branch, governance CI, trunk not `main`) are now rows. **Not fixed**: the "every state" claim is still false (F1(a), F1(c)), and row 5's "code-free phase" gloss is wrong (F1(b)). |
| F2 | Fixed | **No.** The old contradiction ("lawful n/a" beside "write a reason") is gone. The replacement sentence is measured false for any phase after a code-touching one (F1(b)). |
| F3 | Fixed | **Yes.** The mutation and control are above, and the list is complete against all nine param blocks. |
| F4 | Fixed in 015; 014 left alone | **Yes.** Zero control bytes in the Territory and the feature directory. Leaving `specs/014-amendment-authority/notes.md` alone is correct, because it is outside this Territory. |

Earlier rounds show no regression:
- Coverage 191/200, with 7 exempt and 2 not-a-rule, identical to round 3's figures.
- The T047 describe and the recall/`notRules` guards pass.
- The round-2 F4 idiom is unchanged.

## Amendments in this diff

- [x] **None.** `045f182` does not touch `spec.md`, `plan.md`, `tasks.md` or `contracts/`.

## Constitution re-check (post-implementation)

**PASS, except F1.**

- **I**: no amendment made.
- **II (source of truth)**: F1 is a case where reviewer- and adopter-facing documents disagree
  with the code that runs.
- **X / D6**: no exit code moved; `045f182` changes no script.
- **Territory**: all five files are inside the phase-6 Territory.

## Test coverage observed

**Local, scratch clone at `045f182`:**
- `Harness.Tests.ps1` + `Coverage.Tests.ps1`: **33 passed, 0 failed**.
- Coverage report: `191 of 200 declared emission site(s) owned by a fixtured rule, 7 exempt, 2
  declared not a rule, across 9 grading script(s)`.
- T047 mutations: listed above.
- I did not re-run the full 805-case suite locally. `045f182` changes no fixture, and changes
  only one test's list.

**CI on sha `045f182b63c5463e1b5671b4fb2166aecafd2c08`:**
- ritual-checks run 36218378703: **success**.
- enforcement-tests run 36218378654 (push): **success**.
  - `enforcement-tests (ubuntu-latest)`: success, completed 04:43:02Z.
  - `enforcement-tests (windows-latest)`: success, completed 04:50:10Z.
  - I could not fetch per-leg test totals: the job-log API returned nothing to this session.

## Residual risk

The code is sound: every mechanical claim this round makes, I proved by mutation or byte scan.
The remaining risk is the prose again, now narrower:
- A multi-repo reviewer on phase 2+ is told to expect an `UNGRADED` that will not appear, and is
  not told that the `PASS` they see belongs to an earlier phase.
- An adopter running the prescribed plain `scope-check.ps1` on a notes commit meets an
  `UNGRADED` the "every state" table does not list.

F1 is a prose fix of a few sentences. F2 is an owner decision about a later feature and does not
block this phase. F3 is a set of one-clause corrections. With F1 fixed, I would expect to
approve.

---

## Dispositions (appended by the implementer — the reviewer's text above is unedited)

| Finding | Disposition | Where |
|---|---|---|
| F1 (BLOCKING) | **Fixed, by withdrawing the completeness claim.** The table now says the member's own line is the authority and that the table is a guide, not a complete list. (a) Added a row: `scope-check` without `-All` on a HEAD that is not a phase commit. (c) Added a row: one code repository graded and another not, including that the run-level verdict stays `OK`. (b) Row 5 and `review-process.md` step 3 now say **feature**, not phase, and explain that a docs-only phase after a code phase shows the earlier phase's real `PASS`. | `adoption/updating.md`, 015 flow-down note; `docs/sdlc/review-process.md` step 3 |
| F2 | **Deferred to the owner.** Recorded in `notes.md` (round 4 section) and disclosed in the table's last row. The fix is in `scripts/scope-check-repos.ps1` / `scripts/ritual-checks.ps1`, outside phase 6's Territory. Proposed: a roadmap GAP row, added to docs PR #49 next to GAP-029. | `notes.md` |
| F3 | **Fixed.** MicroLane is scoped to Micro-declared features. The trunk-not-`main` cell gives a remedy. The missing-`tasks.md` WARN and the two not-a-repository reasons are listed. The `-BaseRef` remedy says to run `scope-check-repos.ps1` directly. | `adoption/updating.md` table |
