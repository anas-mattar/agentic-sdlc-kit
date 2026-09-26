# AI Code Review — 015 Enforcement Assurance, Phase 6 (round 5)

**Reviewer**: fresh-context agent — claude-opus-5-5
**Date**: 2026-09-26
**Branches**: agentic-sdlc-kit `015-enforcement-assurance` (tip `ab49230`, parent `045f182`)
**Scope reviewed**: all of `ab49230` (4 files), judged against the whole phase
(`git diff 1f05bb3 ab49230`, 41 files). Read in full this round:
- the 015 flow-down note in `adoption/updating.md`, with the six-row "What to do about it" table
  and the paragraph after it;
- `docs/sdlc/review-process.md` step 3;
- the round-4 review and the implementer's appended Dispositions, plus the new round-4 section of
  `notes.md`;
- every `UNGRADED` emission site, listed again by `grep`:
  - `scripts/scope-check.ps1:278`, `:304`, `:309`, `:323`;
  - `scripts/scope-check-repos.ps1:328`, `:387`, `:392`, `:415`;
  - `scripts/enforcement-pack.ps1:586`, `:628`, `:679`, `:1099`, `:1266`, which all print
    through `:1281`;
- the code behind them: `Invoke-ScopeCheck`'s skip paths (`scope-check.ps1:98-270`), both
  `Get-DiffBase` functions, the param blocks of `scope-check.ps1`, `enforcement-pack.ps1` and
  `ritual-checks.ps1`, the member table and `UNGRADED` capture in `ritual-checks.ps1:132-215`,
  and `scope-check-repos.ps1`'s `Invoke-RepoScopeCheck` and per-repository loop (`:174-418`).

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
- **Implementer**: Claude Opus 5.5, the implementing session that wrote `ab49230`, named by the
  commit's `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` trailer. It is not this
  reviewer.
- **Inputs provided**:
  - Diffs: `git show ab49230`; `git diff 1f05bb3 ab49230`.
  - Reviews: `ai-code-review-phase-6-round-4.md` with its Dispositions. Earlier rounds
    (`ai-code-review-phase-6.md`, `-round-2.md`, `-round-3.md`) for history.
  - Feature documents: `specs/015-enforcement-assurance/{spec,plan,tasks,notes}.md`.
  - Law: `CLAUDE.md`, `.specify/memory/constitution.md`, `docs/sdlc/definition-of-done.md`,
    `specs/_templates/ai-code-review-template.md`.
  - Experiments ran only in a scratch clone at `ab49230` and in throwaway fixture repositories
    under this session's scratchpad.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE.** `ab49230` changes prose only. It withdraws the table's completeness claim, which
was the round-4 blocker, and replaces it with a disclaimer that I checked against all 13 emission
sites and found true. I measured every new factual claim on fixtures:
- the partly graded multi-repo row;
- the "feature, not phase" correction;
- the `ritual-checks` → `scope-repos OK` claim;
- the `git branch main origin/<trunk>` remedy.

Every one holds. The two findings below are MINOR. Both concern remedy wording or precision that
an adopter would notice from the member's own output, so neither would lead an adopter to act
wrongly on an unseen result. Deferring round-4 F2 to the owner is acceptable (see "Round-4
dispositions, verified"). The residual risk is the known F2 gap, now disclosed, not the prose.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match | FR-009/FR-010/FR-011: no script changed in `ab49230`, so exit codes are unchanged. The adopter note and review-process step 3 now match the code for every claim listed below. |
| Visual-reference match | N/A: no UI. |
| Feature contract held | No package, workflow or script change in this commit. Every file is inside the phase-6 Territory (the feature directory, `adoption/updating.md`, `docs/sdlc/review-process.md`). |
| Constitution / domain invariants | See the re-check below. |
| Security | N/A: prose only. |
| Scope guard | `scope-check.ps1` in the scratch clone: `PASS phase 6 commit ab49230 (4 file(s))`. The `git show --stat` intent (prose, review file, notes) matches the commit message. |
| Rollback safety | Prose-only commit. It reverts cleanly. |

### The disclaimer is true

The claim under test is "every `UNGRADED` line either names its reason or points at the line
above it that does". I checked each script:
- **`scope-check.ps1`.** `:278`, `:304` and `:309` name their reason inline. `:323` ("the reason
  is on the line(s) above") is reached only when `gradedCommits -eq 0` and nothing failed. Every
  non-FAIL, non-PASS return from `Invoke-ScopeCheck` prints a line first:
  - merge: `:110`;
  - no phase token: `:147`;
  - no `tasks.md`: `:215`;
  - no Territory: `:252`.
  So there is always a line above that names the reason.
- **`scope-check-repos.ps1`.** `:328`, `:387` and `:392` name their reason inline. `:415` is
  preceded by one line per repository: `:348`, `:356`, `:362` and `:366` in the loop, or the
  `SKIP` lines `:191`/`:201`/`:278` in `Invoke-RepoScopeCheck`.
- **`enforcement-pack.ps1`.** Every `$ungraded` entry (`:586`, `:628`, `:679`, `:1099`, `:1266`)
  carries its reason, and `:1281` prints each one as `UNGRADED: <reason>`.

### Row-by-row, against the code

| Row | Claim | Verified |
|---|---|---|
| 1 Detached HEAD | Printed text; full history does not fix it; pass `-Branch` | Yes: `scope-check.ps1:278`, `scope-check-repos.ps1:328`. |
| 2 No merge base | `scope-check -All` text; pack `WARNING`; ReviewProvenance + PhaseSizeWarning on `NNN-*`, MicroLane only on Micro; LiteAndAbuse + ReviewProvenance on `fix/`/`chore/`; ReviewProvenance on `docs/`. No trunk parameter. Amendment check FAILs. | Yes. Lane dispatch is at `:1252-1268`. MicroLane's `:586` sits inside the Micro-only check. `scope-check.ps1` and `enforcement-pack.ps1` take no trunk parameter (param blocks `:63-69`, `:102-116`), and both `Get-DiffBase` functions try `origin/main`, `main` only. Amendment check: `:1082` adds to `$failures`. **Measured** below. |
| 3 No commits since the merge base | Texts and remedy | Yes: `scope-check.ps1:309`, `enforcement-pack.ps1:1099`. |
| 4 All commits skipped | Skip kinds, including both pre-006 WARNs | Yes. The WARN paths at `:215` and `:252` return `$true` without incrementing `gradedCommits`. |
| 5 (new) No `-All`, HEAD not a phase commit | Grades HEAD only | Yes: `:318` passes `$Commit` (default `HEAD`). A token-less HEAD prints `:147`, then `:323`. |
| 6 Multi-repo, nothing graded | The listed reasons match `:348`/`:356`/`:362`/`:366`/`:387`/`:392` plus the SKIP returns. `ritual-checks` does not pass `-BaseRef`. | The reasons are right: the list is complete except the code-repository WARN skip (`:278`), which the disclaimer now covers. `ritual-checks.ps1:147` passes `-All -Root` + `-Branch` only. The remedy wording is imprecise: see F1. |
| 7 (new) Partly graded | The run-level line prints only at `$graded -eq 0`, so `ritual-checks` shows `OK` | Yes: `:415`, and `ritual-checks.ps1:199` anchors on `^scope-repos: UNGRADED`. **Measured** below. Incomplete in one respect: see F2. |

### Measurements

**Fixture A: multi-repo.** A governance repository `gov` with `codeRepos: [api, web]` and
`specs/001-thing/tasks.md`, where phase 1 = `api/**`, `web/**` and phase 2 = `docs/**`.
- `api` has trunk `main`. `web` has trunk `develop` and no `origin/HEAD`.
- Each code repository has a `phase 1: code` commit on `001-thing`.
- The governance tip is `phase 2: docs only`.

| Command | Output |
|---|---|
| `scope-check-repos.ps1 -All` | `api: PASS phase 1 commit cce4cd9`, then `web: UNGRADED could not resolve a merge base with a trunk (…)`, **no run-level line**, exit 0. This confirms row 7. |
| `scope-check-repos.ps1` (the review-process form) | `api: PASS phase 1 …`, `web: PASS phase 1 …`. The docs-only phase 2 shows the earlier phase's real `PASS`, which confirms the new paragraph and step 3. |
| `ritual-checks.ps1` | `ritual-checks: scope-repos      OK`. The other members FAIL only because the fixture has no constitution or doctor record. This confirms "ritual-checks shows `scope-repos` as `OK`". |

**Fixture B: trunk not named `main`.** A clone of a repository whose only trunk is `develop`,
on `001-thing` with a `phase 1` commit.

| State | `scope-check -All` | `enforcement-pack` |
|---|---|---|
| Before | `UNGRADED could not resolve a merge base with main` | `diff base ''`, the WARNING, `UNGRADED: ReviewProvenance …` and `UNGRADED: PhaseSizeWarning …`. No MicroLane line on this Standard feature. |
| After `git branch main origin/develop` | `PASS phase 1 commit 4069acc` | `diff base 'bb73a06…', 2 changed file(s)`, with no `UNGRADED` lines. |

This confirms the row-2 remedy exactly as written.

## Findings

### F1 — The `-BaseRef` remedy omits `-All`, and does not warn that `-BaseRef` applies to every repository — MINOR

Row 6 says: "A code repository whose trunk is not `main`/`master`: run
`scope-check-repos.ps1 -BaseRef <trunk>` directly". The code reads `-BaseRef` only inside the
`-All` branch (`scope-check-repos.ps1:374-378`). When it is set, it **replaces** the candidate
list for every repository graded in the run. Measured on fixture A:

| Command | Output |
|---|---|
| `scope-check-repos.ps1 -BaseRef develop` (no `-All`) | `api: PASS …`, `web: PASS …`. The flag is inert: this is the plain tip-only form. |
| `-All -BaseRef develop` | `api: UNGRADED could not resolve a merge base with a trunk (develop)`, `web: PASS …`. The fix for `web` ungrades `api`. |
| `-All -BaseRef develop -Repo web` | `web: PASS phase 1 …`. This is the form that works. |

So the remedy as written either does nothing to the base, or trades one repository's
`UNGRADED` for another's. It is MINOR, not BLOCKING:
- every outcome is visible on the member's own per-repository lines, which the disclaimer
  directs the reader to;
- no outcome is a false `PASS`;
- the script's own hint at `:387` ("pass -BaseRef <ref> naming its trunk") has the same gap.
  Round 4 F3 had suggested `-All -BaseRef`.

*Action: implementer, optional, one clause in row 6: "run
`scope-check-repos.ps1 -All -Repo <repo> -BaseRef <trunk>` directly — `-BaseRef` replaces the
trunk candidates for every repository in the run". This can land with the owner's F2 follow-up
instead; it does not block this phase.*

### F2 — A sibling repository can go ungraded without printing `UNGRADED` at all — and step 3 says "latest phase commit" where the code grades the branch tip — MINOR

Row 7 describes the ungraded sibling as printing `<repo>: UNGRADED …` on its line. There is a
second way for a sibling to go ungraded: every commit it offers is a `SKIP`, meaning no phase
token, a merge, or the code-repository WARN at `:278`. Then it prints only `not applicable` or
`WARN`, and the run is still summarised `OK`.
- **Measured.** On fixture A, add a token-less `notes` commit on `web`'s `001-thing`. The plain
  form then prints `api: PASS phase 1 …` and
  `web: not applicable (commit 0513279 carries no 'phase N' token …)`, exits 0, and
  `ritual-checks` still shows `scope-repos OK`.

The same measurement shows that step 3's "shows those branches' latest phase commit instead" is
imprecise. The plain form grades the code branch's **tip** (`:398`). A tip that is not a phase
commit is skipped, not replaced by the latest phase commit, so the reviewer gets
`not applicable`, not an earlier `PASS`.

Neither point sends a reader wrong:
- the disclaimer tells them the per-repository lines are the authority, and those lines are
  accurate;
- row 7 already says "Read the per-repository lines, not the summary".

This is the same family as round-4 F2, one step wider.

*Action: implementer or owner, optional:*
- *In row 7, say "a repository graded and another not (its line says `UNGRADED`, or only
  `not applicable`/`WARN`)".*
- *In step 3, replace "latest phase commit" with "branch tip (graded if it is a phase commit)".*
- *Mention the skip case when the owner decides round-4 F2.*

## Round-4 dispositions, verified

| Finding | Claimed | Verified? |
|---|---|---|
| F1 (BLOCKING) | Fixed by withdrawing the completeness claim, with rows added for (a) and (c) and "feature" for (b) | **Yes.** No completeness claim is left (`grep` for "thirteen", "every state", "exactly the states" finds nothing in the note or step 3). The disclaimer is true (verified above). Rows (a) and (c) are accurate, with F2's small gap. The "feature, not phase" wording is right in both documents, and I measured it. |
| F2 | Deferred to the owner; recorded in `notes.md` and disclosed in row 7 | **Yes, recorded and disclosed.** It is acceptable for approving this phase: the fix is in `scope-check-repos.ps1:415` / `ritual-checks.ps1:199`, outside the phase-6 Territory. Phase 5 shaped the behaviour, so it is not a regression, and it was `OK` before 015 too. The adopter-facing table now states the gap instead of hiding it. The owner should record the decision (accept, or open a GAP row) before merge, as `notes.md` proposes. |
| F3 | Fixed | **Yes, with one wording residue (F1 above).** MicroLane is scoped to Micro. The trunk remedy is present and measured correct. The missing-`tasks.md` WARN and both not-a-repository reasons are listed. The `-BaseRef` remedy now says to run it directly and names `ritual-checks` as the reason, but omits `-All`/`-Repo`. |

No regression from earlier rounds:
- The enforcement-pack header, `tests/enforcement/*.json` notes and the T047 describe are
  untouched by `ab49230`.
- Coverage figures are identical to round 4.

## Amendments in this diff

- [x] **None.** `ab49230` does not touch `spec.md`, `plan.md`, `tasks.md` or `contracts/`.

## Constitution re-check (post-implementation)

**PASS.**
- **I**: no amendment made.
- **II (source of truth)**: the adopter- and reviewer-facing prose no longer asserts what the code
  does not do. The one gap (F2 here, round-4 F2) is disclosed.
- **X / D6**: no exit code moved; no script changed.
- **Territory**: all four files are inside the phase-6 Territory.

## Test coverage observed

**Local, scratch clone at `ab49230`** (branch `015-enforcement-assurance` recreated at that sha):

| Check | Result |
|---|---|
| `scope-check.ps1` | `PASS phase 6 commit ab49230 (4 file(s))`, exit 0 |
| `build-digests.ps1 -Check` | `digests: OK (5 digest(s) fresh, 82 marker(s))`, exit 0 |
| `ritual-checks.ps1` | doc-lint, enforcement-pack, scope-check, digests and roadmap-claims `OK`; scope-repos and verify-kit `n/a` (kit repository); `RESULT OK` |
| `Harness.Tests.ps1` + `Coverage.Tests.ps1`, Pester 5.7.1 | **33 passed, 0 failed**. Coverage: `191 of 200 declared emission site(s) owned by a fixtured rule, 7 exempt, 2 declared not a rule, across 9 grading script(s)`, the same as round 4. |

I did not re-run the full case suite locally, because `ab49230` changes no fixture, test or
script.

**CI on sha `ab492300aa7f1efa6a817e3cbee1e9eb92d6a2bb`:**

| Run | Result |
|---|---|
| ritual-checks run 36219679685 (push) | **success** |
| enforcement-tests run 36219679677 (push) | **success** |
| — `enforcement-tests (ubuntu-latest)` | success, completed 05:09:14Z |
| — `enforcement-tests (windows-latest)` | success, completed 05:17:21Z |

## Residual risk

- The only substantive open item is round-4 F2, now disclosed. This round's F2 widens it slightly:
  a multi-repo `ritual-checks` summary can say `scope-repos OK` while one declared code repository
  graded nothing. The adopter note tells readers to read the per-repository lines. The owner should
  record the decision (accept, or open a GAP row) before merge, as `notes.md` proposes.
- F1 is remedy wording that self-corrects on first use.
- The prose defects that drove rounds 2–4 (completeness claims about `UNGRADED`) are gone rather
  than patched: the table now defers to the emission lines, and I verified those lines against the
  code.
- Phase 6 can be approved on this commit. The owner still has to record approval on the CI
  evidence triplet (ci-held).

---

## Dispositions (appended by the implementer — the reviewer's text above is unedited)

| Finding | Disposition | Where |
|---|---|---|
| F1 (MINOR) | **Fixed (owner chose to fix both MINORs before certification).** The remedy now reads `scope-check-repos.ps1 -All -Repo <repo> -BaseRef <trunk>`, and says why both flags matter: without `-All` the script ignores `-BaseRef`, and without `-Repo` it applies the one trunk to every repository. The script's own hint has the same gap. It is in `scripts/scope-check-repos.ps1`, outside the phase-6 Territory, and goes to the owner's follow-up alongside round-4 F2. | `adoption/updating.md`, table row 6 |
| F2 (MINOR) | **Fixed.** The partly-graded row now says the ungraded repository may print only `not applicable` / `WARN` lines and no `UNGRADED`. Step 3 now says the command grades each code branch's tip: a real `PASS` for an earlier phase when the tip is that phase's commit, `not applicable` when the tip has no `phase N` token. It also says that a repository going ungraded either way leaves the run-level verdict unchanged. The widened round-4 F2 is part of the owner's follow-up. | `adoption/updating.md` table row 7; `docs/sdlc/review-process.md` step 3 |
