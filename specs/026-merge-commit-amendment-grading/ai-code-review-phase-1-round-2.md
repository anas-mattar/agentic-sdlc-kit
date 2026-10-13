# AI Code Review — 026 Grade the content a merge commit authors, phase 1 (round 2)

**Reviewer**: fresh-context agent, Claude Opus 5.5 (claude-opus-5-5)
**Date**: 2026-10-14
**Branches**: kit repository `026-merge-commit-amendment-grading`. Phase 1 commit `15a0e6f` (parent `fad21b7`), then `61bd6ed` (notes: gate certified), `8d3badf` (review remediation) and `a7868d2` (notes: gate certified after the remediation). Branch tip at review start: `a7868d2`.
**Scope reviewed**:
- The remediation diff, read in full: `git show 8d3badf` (`FixtureRepo.psm1`, `Harness.Tests.ps1`, `notes.md`, the round-1 review file), and `git show a7868d2`.
- `tests/enforcement/lib/FixtureRepo.psm1`: the header doc (lines 56-71) and the merge handling (lines 214-293).
- `tests/enforcement/Harness.Tests.ps1`: the whole Describe `merge commits that carry content (feature 026, plan D8)` (lines 278-436), 14 tests.
- `specs/026-merge-commit-amendment-grading/`: `notes.md` (all of it, including "Phase 1 review remediation"), `plan.md` D8 and "Phases", `tasks.md` (phase 1 = T001-T004 and its Territory), `spec.md` status line, and the round-1 review `ai-code-review-phase-1.md` (F1-F10).
- `tests/enforcement/cases/enforcement-pack/AMEND-001/pass-merge/expected.txt`, and every recipe under `tests/enforcement/cases` that uses `merge` (9).
- `docs/sdlc/review-process.md`, `specs/_templates/ai-code-review-template.md`, and `specs/025-critical-merge-ready-signal/ai-code-review-phase-1-round-2.md` for shape.

Not read: phase 2 and phase 3 territory. The full harness was not run, per instructions (one run is already in progress elsewhere).
**Feature contract**: phase 1 is plan D8 only. The fixture library gains optional `mergeWrite`, `mergeDelete` and `resolve` on a merge commit. Without them a merge behaves exactly as today. A field the library cannot honour is refused, never ignored. Self-tests are written first. No check changes, no existing fixture changes, no new package or script.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5) session
- **Inputs provided**:
  - `git show 8d3badf` (the remediation) and the notes-only commit `a7868d2`; phase 1 commit `15a0e6f` (parent `fad21b7`).
  - The round-1 review `specs/026-merge-commit-amendment-grading/ai-code-review-phase-1.md` (findings F1-F10).
  - `specs/026-merge-commit-amendment-grading/{spec.md, plan.md (D8), tasks.md (phase 1 = T001-T004), notes.md ("Phase 1 review remediation")}`.
  - `tests/enforcement/lib/FixtureRepo.psm1` (merge handling and header doc).
  - `tests/enforcement/Harness.Tests.ps1` (Describe `merge commits that carry content`).
  - `docs/sdlc/review-process.md` and `specs/_templates/ai-code-review-template.md`.
  - The prior review `specs/025-critical-merge-ready-signal/ai-code-review-phase-1-round-2.md`, for shape.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The round-1 blocker is closed on the path phase 2 depends on, and I reproduced every claim myself rather than taking it from notes.md:

- **F1 (BLOCKING in round 1).** A merge of a branch that is already an ancestor is now refused on both paths, with a clear message. No `MERGE_HEAD` and no dirty tree are left behind.
- **All 9 existing merge recipes** still build a two-parent merge, and their cases pass.
- **F2 and F4** are refused as described.
- **F3, F5 and F9** are stated where the notes say.
- **F7** adds the default-message test and the two-parent assertion on `mergeDelete`.
- **Mutations.** All seven mutations named in the brief each fail exactly their intended test or tests.
- **Scope.** `scope-check` gives PASS on `15a0e6f` and `8d3badf`. Nothing under `scripts/` or `tests/enforcement/cases/` changed, and no approved document changed.

The falsification hunt found two new gaps of the same kind, both MINOR. In each, the new guards ask "is HEAD a merge?" rather than "is HEAD the merge this recipe asked for?":

- **F11.** A second plain merge of an already-merged branch, made when HEAD is already a merge commit, silently produces no commit. The module header (lines 67-68) and notes say such a merge is refused.
- **F12.** An octopus whose list includes an already-merged branch silently becomes a two-parent merge, on both paths. The header says an array makes "more than two parents".

I trialled one guard that fixes both: HEAD must move, and the parent count must equal 1 plus the distinct names. Under it all 9 existing merge recipes build, the 14 self-tests pass, and both gaps are refused. The rest is wording (F13), notes drift (F14) and accepted lenient edges (F15). Residual risk is small, and it sits in phase 2 recipes that would trip F11 or F12. Fix those before phase 2 builds its fixtures.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | **FR-006 / D8**: the content path (lines 236-292) and the plain path (lines 227-235) are as in round 1, plus four new refusals:<br>- `MERGE_HEAD` absent after a clean `merge --no-commit` (lines 241-246).<br>- Plain merge leaves HEAD with fewer than 2 parents (lines 230-233).<br>- `resolve` and `mergeWrite` name the same file (lines 254-258), with `merge --abort`.<br>- A `resolve` name is not among the conflicted files (lines 260-264), with `merge --abort`.<br><br>**"A plain merge behaves exactly as today"**: the git command at line 229 is unchanged. The only addition is a post-check that refuses a recipe that produced no merge. All 9 existing merge recipes build a 2-parent merge under it (`exp/recipes.ps1`, which also lists the merges inside nested repos):<br>- AMEND-001/pass-merge, SCOPE-014/fail, SCOPE-026/{pass,fail}<br>- REPOS-016/{pass,fail}, REPOS-018/fail<br>- REPOS-034/{fail-no-commits-since-base, fail-skipped-commits}<br><br>**FR-007**: `-Case AMEND-001` gives 106 passed, 0 failed (round 1: 101; the difference is the 5 added self-tests). |
| Visual-reference match | N/A: no UI. |
| Feature contract held (no unapproved table/migration/permission/package) | `git diff --name-status fad21b7 a7868d2` lists exactly:<br>- A `ai-code-review-phase-1.md`<br>- A `notes.md`<br>- M `Harness.Tests.ps1`<br>- M `README.md`<br>- M `FixtureRepo.psm1`<br><br>`git diff --stat fad21b7 a7868d2 -- scripts tests/enforcement/cases .specify docs specs/026-.../{spec,plan,tasks}.md` is empty. No package, no script, no new library file. |
| Constitution / domain invariants | See the re-check below. `spec.md`, `plan.md` and `tasks.md` were last touched in `7ad1ce1`, `657473c` and `fad21b7`, all before phase 1 (`git log -- <file>`). Plan D8's `--no-commit` wording (plan.md line 124) is unchanged: it is carried, not edited (F9). |
| Security (authn/authz, secrets, sensitive logging) | Test-only code. The new guards run `git -C $root rev-parse` / `rev-list` against the fixture repository only. No user config is read or written. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | In a scratch clone (`k026mut`):<br>- `pwsh -File scripts/scope-check.ps1 -Commit 15a0e6f -Branch 026-merge-commit-amendment-grading -Root .` gave `scope-check: PASS phase 1 commit 15a0e6f (4 file(s))`, exit 0.<br>- The same command with `-Commit 8d3badf` gave `PASS phase 1 commit 8d3badf (4 file(s))`, exit 0.<br><br>Territory is `tests/**` (tasks.md line 32), plus the spec directory's notes and review files. `git diff --stat` for `8d3badf` reads as intended: 29 library lines, 50 test lines, 29 notes lines and the review file. |
| Rollback safety (phase reverts cleanly; schema additive?) | Additive. The remediation only adds refusals and tests. Reverting `8d3badf` restores round-1 behaviour, and reverting `15a0e6f` restores the parent library. No existing case uses the new fields. No schema or data. |
| CRLF / LF | `exp/crlf2.ps1` built a conflicting merge with `resolve` `x.txt: "hand\r\nline2\r\n"` and `mergeWrite` `w.txt: "w\r\n"`. The blobs are LF (`x.txt` 11 bytes, `w.txt` 2 bytes) and `git status` is clean. The remediation does not touch `Write-FixtureFile`. |
| State after a throw | Every refusal probe ran with a private `TEMP` (`exp/probe.ps1`), so no other harness run could interfere. Each refusal leaked its `kit-fixture-*` directory (F6, pre-existing). In **every** leaked repository, `MERGE_HEAD` was absent and `git status --porcelain` was empty. That covers the two up-to-date refusals, stray-resolve, both-fields (with and without a conflict), merge-of-self and the falsy-merge refusals. The `MERGE_HEAD` guard throws without `merge --abort`, which is correct: no merge was started. |

## Round-1 findings: status

| Round 1 | Status | Evidence (reproduced, not taken from notes) |
|---|---|---|
| **F1** (BLOCKING): "Already up to date" became a one-parent commit carrying the merge content | **RESOLVED**, with a residual hole on the plain path (F11) and in octopus merges (F12) | `exp/probe.ps1` with the recipe `main: init; feat: feat work; feat merges main`:<br>- With `mergeWrite`, it threw `fixture merge of 'main' started no merge: the branch is already merged into 'feat' (git says 'Already up to date') ... Refused ...`.<br>- Plain, it threw `... made no merge commit ... HEAD is still a one-parent commit. Refused ...`.<br>- `mergeDelete` only, and merge-of-self (`"merge": "feat"`), are refused on both paths.<br>- An octopus whose branches are all merged is refused.<br>- In every leaked repository: `MERGE_HEAD=False status=''`.<br><br>All existing merge recipes build (above). The cases pass in scratch clone `k026r2`:<br>- `-Case AMEND-001`: 106/0<br>- `SCOPE-014`: 60/0<br>- `SCOPE-026`: 60/0<br>- `REPOS-016`: 60/0<br>- `REPOS-018`: 60/0<br>- `REPOS-034`: 70/0<br><br>Mutations MA and MB each fail exactly their self-test (see Test coverage). |
| **F2** (MINOR): a `resolve` naming a non-conflicted file was honoured as a write | **RESOLVED** | Probe `F2-stray-resolve` (`resolve` `{x.txt, a.txt}`, only `x.txt` conflicts) threw `fixture 'resolve' names 'a.txt', which did not conflict in the merge of 'main'. Use 'mergeWrite' ...`. The leaked state was clean. The "unnamed" self-test now conflicts on two files and names one (Harness.Tests.ps1 line 385), so the stray check does not mask it: mutation MF fails only the two conflict-refusal tests, and MC fails only the F2 test. |
| **F3** (CONFIRM): `hoursAgo` on a merge is ignored | **ACCEPTED** (owner decision, recorded in notes.md as "leave it as is") | The module header (lines 70-71) now reads `"hoursAgo" on a merge, which is ignored (as it always was; the REPOS-016, 018 and 034 cases carry it)`. Nothing else changed for it: `git show 8d3badf -- tests/enforcement/lib/FixtureRepo.psm1` touches no `hoursAgo` code, and the `hoursAgo` handling (after the merge `continue`s) is as in round 1. One nit: the sentence sits under "NOT expressible", while `hoursAgo` on a merge is in fact *accepted and ignored*. It is a stated limit either way. |
| **F4** (MINOR): `mergeWrite` silently overrode `resolve` | **RESOLVED** | Probe `F4-both-conflict` threw `fixture names 'x.txt' in both 'resolve' and 'mergeWrite'. Say which one ...`. Probe `F4-both-noconflict` (same names, no conflict) threw the same refusal, because the check (line 254) runs before the conflict branch. Clean state in both. Mutation MD fails only its test. |
| **F5** (MINOR): octopus conflict and conflict-by-deletion not expressible, and unstated | **RESOLVED** | Header lines 69-70: `NOT expressible: an octopus merge with a conflict (git itself refuses one), a conflict resolved by DELETING the file ("resolve" always writes content)`. |
| **F6** (MINOR): refusals leak the temp repository | **ACCEPTED** (recorded, not changed) | Still true: every refusal probe leaked one directory. Inside each, the state was clean (above). notes.md records it as library-wide and pre-existing, which is accurate. |
| **F7** (MINOR): self-tests pinned less than their titles | **RESOLVED** for the two asked-for assertions; the two admitted gaps are honest, with one notes inaccuracy (F14) | - A new test, `keeps the default merge message ...` (lines 315-321), omits `message` and asserts `merge main` and 2 parents.<br>- The `mergeDelete` test asserts 2 parents (line 336).<br><br>The notes' admitted gaps:<br>- **(a) `merge --abort` removal is unobservable.** Confirmed: mutation MI fails nothing (14/14). It is acceptable, because the abort's effect is invisible to every caller (F6), and my probes show it works.<br>- **(b) "Routing a plain merge through the new path cannot fail a test".** **No longer true**: mutation MH now fails `refuses a plain merge that made no merge commit ...`, because the content path's refusal text differs. It is caught by message text only, not by behaviour; see F14. |
| **F8** (ACCEPTED): octopus array; `resolve` refused on a non-conflicting merge | **ACCEPTED** (unchanged) | Both are still within D8. The octopus array now has a silent-downgrade edge (F12). |
| **F9** (DOC DRIFT): D8 misstates the parent's command; T001 output missing | **RESOLVED** (notes) / **carried** (plan) | notes.md carries T001's four-line output, exit 0. It matches `tests/enforcement/cases/enforcement-pack/AMEND-001/pass-merge/expected.txt` verbatim (compared). plan.md line 124 still says `git merge --no-ff --no-commit`. It was not edited, and notes.md carries it "to the next owner-approved amendment of the plan", as round 1 asked. |
| **F10** (MINOR): lenient edges | **ACCEPTED** | notes.md accepts it as consistent with `delete`. Re-probed: unchanged. A sibling (`mergeWrite` with identical content) is added under F15. |

## Findings

### F11 — The plain-path guard counts parents instead of checking that a merge was made, so a second merge of an already-merged branch still vanishes silently — MINOR

**Where**: `FixtureRepo.psm1` lines 229-233. After `git merge --no-ff --no-edit`, the guard refuses only when HEAD has fewer than 2 parents. When the named branch is already merged in **and HEAD is already a merge commit**, git says "Already up to date", makes no commit, and HEAD still has 2 parents, so the guard passes.

**Evidence**: probe `plain-uptodate-after-merge`. The recipe is `main: init; feat: feat work; main: main2; feat merges main ("merge one"); feat merges main ("merge two")`. It built `parents=2 msg='merge one'`, and the log has no `merge two` commit. The recipe's last merge disappeared with no error. The content path is not affected: the same shape with `mergeWrite` (probe `content-uptodate-after-merge`) is refused by the `MERGE_HEAD` check, which tests the right thing.

**Why it matters**:
- The header (lines 67-68) and notes.md (F1 row: "Both paths now refuse") say such a merge is refused, and for this shape it is not.
- Phase 2 builds plain "authors nothing" merges beside content merges. A recipe that merges the same branch twice without moving it gets one merge fewer than it declares. A grading count in an `expected.txt` (`graded N of M`, `1 merge commit(s)`) would then be pinned to the wrong history.
- The shape needs a specific recipe mistake, so the impact is small.

*Action: implementer, inside `tests/**`, before phase 2 builds fixtures. Record `git rev-parse HEAD` before the merge, and refuse when HEAD did not move, together with F12's parent-count check. One self-test (the two-merge recipe above). I trialled this guard in a scratch copy (`exp/guard2.ps1`): all 9 existing merge recipes build, the 14 self-tests pass, this probe is refused, and the module was restored byte-identical.*

### F12 — An octopus whose list includes an already-merged branch silently builds a two-parent merge — MINOR

**Where**: both merge paths. git reduces the merge heads, so a branch that is already an ancestor is dropped from the octopus. Neither guard compares the parent count with the number of names. The content path sees `MERGE_HEAD` present and proceeds. The plain path sees 2 parents and proceeds.

**Evidence**: `feat` is created after `main` moved, so `main` is an ancestor of `feat`; `left` is new.
- Probe `octopus-plain-one-merged` (`"merge": ["main","left"]`) built `parents=2 msg='octo'`, with parents `feat` and `left`.
- Probe `octopus-content-one-merged` (the same plus `mergeWrite`) built `parents=2 msg='octo'`.
- When *all* listed branches are merged, it is correctly refused (probe `octopus-content-all-merged`).
- `[main, main]` (the same branch twice) builds 2 parents on both paths. git deduplicates, which is reasonable and needs no refusal.

**Why it matters**:
- The header (line 59) promises that an array "makes an octopus merge (more than two parents)".
- Approved `tasks.md` T006 requires "an octopus merge that authors `plan.md`". If a phase 2 recipe gets the branch order wrong, it gets an ordinary two-parent merge, and the octopus-specific grading (the result compared with every parent) is never exercised. That is the "passes for the wrong reason" class again.
- The octopus array is new in this phase (`15a0e6f`), so this is a phase 1 defect. Round 1 did not probe this shape.

*Action: implementer, with F11. After either path commits, refuse when the parent count is not `1 + @($mergeNames | Select-Object -Unique).Count`. One self-test (the recipe above). Shown safe in the same trial (`exp/guard2.ps1`): both probes refused, existing recipes and self-tests unaffected.*

### F13 — The refusal messages describe the wrong case in two places, and a blank line is missing — MINOR

**Evidence**:
- **Content-path "started no merge" message (line 244).** It says "would make an ordinary one-parent commit that carries the mergeWrite content" even when the recipe has only `mergeDelete` or `resolve` (probe `F1-mergeDelete-only-uptodate`).
- **Plain-path message (line 232).** It always says "HEAD is still a one-parent commit". The F11 fix will reach this text in a case where HEAD has two parents.
- **Missing blank line.** `Harness.Tests.ps1` line 427/428 has no blank line between two `It` blocks, unlike every other pair in the Describe.

*Action: implementer, with F11/F12. Say "the merge content" rather than "the mergeWrite content", word the plain message by what failed (no new commit, or a wrong parent count), and add the blank line.*

### F14 — notes.md's F7 row is stale in two details — DOC DRIFT

**Evidence**:
- **"Cannot fail a test" is no longer true.** The row says routing a plain merge through the new path "cannot fail a test because both paths build the same merge". After the remediation it does: mutation MH (`if ($mergeFields.Count -eq 0)` changed to `if ($false)`) fails `refuses a plain merge that made no merge commit ...`, because the content path refuses with "started no merge" instead of "made no merge commit". The tests still do not tell the two paths apart by *behaviour*, only by refusal text, so the substance of the admission stands.
- **The control itself was not changed.** The row says "The plain-merge control now pins the default message". In fact the control (lines 306-313) is unchanged and still sets `message`. A **new** test (lines 315-321) pins the default. The effect is what round 1 asked for. Only the description is off.

*Action: implementer, a one-line correction in notes.md when the F11/F12 fix lands. No code change.*

### F15 — Content fields that author nothing, and a falsy `merge` on its own, are accepted — ACCEPTED

**Evidence**:
- **`mergeWrite` with identical content.** Probe `mergeWrite-identical` (`mergeWrite` `a.txt: "one\n"`, the same as both parents) builds a normal 2-parent merge, and the field authors nothing. It is the same class as round-1 F10 (`mergeDelete` of a missing path), which the owner accepted.
- **Falsy `merge` alone.** `"merge"` set to `false`, `""`, `[]`, `null` or `0` with no content field builds an ordinary one-parent commit (probes `falsy-merge-*-alone`). This is the parent's own truthiness rule (`git show fad21b7:tests/enforcement/lib/FixtureRepo.psm1` line 204), unchanged by this phase.
- **Falsy `merge` with a content field.** It is correctly refused in all five cases (probes `falsy-merge-*-with-field`: `'mergeWrite' applies only to a merge commit`).

*Action: none. It is consistent with F10's acceptance. A phase 2 fixture that means "the merge authored X" should assert the authored change in its expected output, which the amendment check's own grading line already does.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None.**
- `8d3badf` changes no approved document. Under `specs/` it touches only `notes.md` and adds the round-1 review file. Neither is law.
- `a7868d2` changes `notes.md` only.
- `spec.md` (`**Status**: Approved (anas.m, 2026-10-14)`), `plan.md` (`**Status**: Approved (anas.m, 2026-10-14)`) and `tasks.md` were last changed before phase 1 (`7ad1ce1`, `657473c`, `fad21b7`).
- The D8 wording drift is carried in notes.md for the next owner-approved plan amendment, not edited without an approver record, which is correct under constitution I.

## Constitution re-check (post-implementation)

**PASS.**
- **I (Amendment authority)**: no approved document amended. The plan drift (F9) is carried, not self-approved.
- **II**: the code follows D8 and T001-T004. The owner's F3 decision is recorded in notes.md, in the owner's words.
- **III, V, VI, VII**: N/A. There is no UI, no data, nothing sensitive and no external integration.
- **IV**: no new file outside `tests/**` and the spec directory, and no package.
- **VIII (tests measure something)**:
  - Each new refusal has a self-test, and each named mutation fails exactly its test or tests (Test coverage).
  - The remaining gaps are F11 and F12 (the guards accept a merge other than the one asked for) and MI (unobservable, honestly stated).
- **IX**: this file and the round-1 file carry Reviewer Provenance.
- **X**: one phase. A user-run gate was certified by the owner on `8d3badf` (notes.md, `a7868d2`). `scope-check` PASS on both phase commits.

## Test coverage observed

All runs were in scratch clones of the branch tip `a7868d2`: `<scratchpad>/k026r2` for the case runs and probes, and `<scratchpad>/k026mut` for mutations and the guard trial. Probes ran under a private `TEMP`. The working repository was never mutated: `git status --porcelain` was empty in it and in both clones at the end. Each mutation restored `FixtureRepo.psm1` byte-identical (hash compared).

| Run | Result |
|---|---|
| `Run-Tests.ps1 -Case NOTHING` | 58 passed, 0 failed (53 in round 1, plus the 5 added) |
| `-Case AMEND-001` (includes `pass-merge`) | 106 passed, 0 failed |
| `-Case SCOPE-014` / `SCOPE-026` / `REPOS-016` / `REPOS-018` / `REPOS-034` | 60/0, 60/0, 60/0, 60/0, 70/0, all `enforcement-tests: OK` |
| Direct build of all 9 existing merge recipes (`exp/recipes.ps1`, nested repos included) | All build, and every merge has exactly 2 parents |
| Mutations (Pester on the merge Describe only, 14 tests) | MA (drop `MERGE_HEAD` guard): 1 failed, the up-to-date `mergeWrite` refusal<br>MB (drop plain parent-count guard): 1 failed, the up-to-date plain refusal<br>MC (drop stray-resolve refusal): 1 failed, its test<br>MD (drop both-fields refusal): 1 failed, its test<br>ME (drop `mergeWrite` application): 2 failed, the `mergeWrite` and octopus tests<br>MF (drop unnamed-conflict refusal): 2 failed, both conflict refusals<br>MG (drop non-merge refusal): 1 failed, its test<br>MH (plain routed through the content path): 1 failed, the up-to-date plain refusal (message text only; F14)<br>MI (`merge --abort` removed before the unnamed refusal): **0 failed** (as notes.md admits)<br>Unmutated: 14/14 |
| Edge probes (`exp/probe.ps1`, 28 cases) | F1, F2 and F4 reproduced as refused, with clean state<br>New: F11 and F12<br>Same branch twice: 2 parents (git dedup)<br>Merge of self: refused<br>Identical `mergeWrite` and falsy `merge`: F15 |
| CRLF (`exp/crlf2.ps1`) | `resolve` and `mergeWrite` blobs LF; clean status |
| Guard trial (`exp/guard2.ps1`: HEAD must move; parents = 1 + distinct names) | 9/9 recipes build, Describe 14/14, F11 and both F12 probes refused; restored byte-identical |
| `scope-check.ps1` on `15a0e6f` and `8d3badf` | PASS (4 files each) |
| Full harness | Not run, per instructions |

Overlap check on the 5 added self-tests:
- The default-message test complements the control: the control sets `message`, the new test omits it.
- The two up-to-date tests cover different paths and messages.
- The stray-resolve and unnamed-conflict tests are isolated from each other (MC and MF each fail only their own).
- The both-fields test does not collide with the nothing-to-resolve test, because it uses a conflicting merge.
- No contradiction with any earlier test.

## Residual risk

- **Before phase 2 builds fixtures**: close F11 and F12 with one guard (HEAD moved; parent count = 1 + distinct names) and a self-test each. The fix is a few lines in `tests/**`, and the trial above showed it is safe. Fold in F13's wording and F14's notes correction.
- **Accepted by the owner**: `hoursAgo` ignored on merges (F3), leaked temp repositories (F6), and lenient empty or no-op fields (F10, F15).
- **Carried**: the plan D8 wording (F9), to be fixed at the next owner-approved plan amendment with an approver record.
- **Before merge**: the owner's gate on whichever commit closes F11/F12 (if made), and the human review.
