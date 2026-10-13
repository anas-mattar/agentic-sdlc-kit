# AI Code Review — 026 Grade the content a merge commit authors, phase 1

**Reviewer**: fresh-context agent, Claude Opus 5.5 (claude-opus-5-5)
**Date**: 2026-10-14
**Branches**: kit repository `026-merge-commit-amendment-grading`. Phase 1 commit `15a0e6f` (parent `fad21b7`), then `61bd6ed` (notes: gate certified). Branch tip at review start: `61bd6ed`.
**Scope reviewed**:
- `git show 15a0e6f`, read in full (4 files: `FixtureRepo.psm1`, `Harness.Tests.ps1`, `tests/enforcement/README.md`, `notes.md`), and `git show 61bd6ed`.
- `tests/enforcement/lib/FixtureRepo.psm1`, all of it (header lines 14-108, `Invoke-FixtureGit` 114-121, `Write-FixtureFile` 123-132, `New-FixtureRepo` 134-442).
- `tests/enforcement/Harness.Tests.ps1`, the new Describe `merge commits that carry content (feature 026, plan D8)` (lines 278-388) and the file's `BeforeAll`.
- `specs/026-merge-commit-amendment-grading/`: `plan.md` D8 and "Phases"; `tasks.md` (all of it); `spec.md` FR-006/FR-007; `notes.md` (all of it).
- `tests/enforcement/cases/enforcement-pack/AMEND-001/pass-merge/recipe.json`, and every other recipe that uses `merge` (9 in all).
- `specs/_templates/ai-code-review-template.md`, and `specs/025-critical-merge-ready-signal/ai-code-review-phase-1-round-2.md` for shape.

Not read: phase 2 and phase 3 territory (`scripts/enforcement-pack.ps1` beyond its absence from the diff). The full harness was not run, per instructions.
**Feature contract**: phase 1 is plan D8 only. The fixture library gains optional `mergeWrite`, `mergeDelete` and `resolve` on a merge commit. Without them a merge behaves exactly as today. A conflicting merge without `resolve` is refused, never ignored. A self-test covers the fields, written first. No check changes, no existing fixture changes, no new package or script.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5) session
- **Inputs provided**:
  - `git show 15a0e6f` (the phase 1 commit; parent `fad21b7`).
  - `specs/026-merge-commit-amendment-grading/{spec.md, plan.md, tasks.md, notes.md}` (phase 1 = T001-T004 and its Territory block; plan D8).
  - `tests/enforcement/lib/FixtureRepo.psm1` (the merge handling and the header doc).
  - `tests/enforcement/Harness.Tests.ps1` (the new Describe `merge commits that carry content (feature 026, plan D8)`).
  - `tests/enforcement/README.md`.
  - `tests/enforcement/cases/enforcement-pack/AMEND-001/pass-merge`.
  - `docs/sdlc/review-process.md` and `specs/_templates/ai-code-review-template.md`.
  - The prior review `specs/025-critical-merge-ready-signal/ai-code-review-phase-1-round-2.md`, for shape.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** (one small, contained fix). The change does what D8 asks in the ordinary case, and I reproduced it:
- `mergeWrite`, `mergeDelete` and `resolve` work.
- An octopus merge builds.
- The refusals are loud, and `git merge --abort` leaves no merge state behind.
- A plain merge runs the identical git command with the identical default message.
- The blobs are LF whatever `core.autocrlf` says.
- The self-tests fail 8 of 9 on the parent, and each targeted mutation fails exactly the test meant to catch it.
- Scope is clean: `scope-check` PASS, and nothing under `scripts/` or `tests/enforcement/cases/` changed.

One falsification succeeded, and it is the defect class this library exists to refuse (F1). When the merged branch is already an ancestor ("Already up to date"), `git merge --no-ff --no-commit` exits 0 and creates no `MERGE_HEAD`. The new path then commits with `--allow-empty` and produces a **single-parent** commit. That commit is titled `merge main` and carries the `mergeWrite` content. A phase 2 fixture built that way would grade an ordinary commit while claiming to grade a merge: it would pass, or fail, for the wrong reason. The fix is a few lines, and a guard of this shape passes all 9 existing merge recipes. Everything else is MINOR, ACCEPTED, DOC DRIFT, or one CONFIRM about a pre-existing silent `hoursAgo` on merges (F3). Residual risk sits in the field combinations the refusals do not cover (F2, F4, F5) and in tests that pin less than their titles say (F7).

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | **FR-006 / D8 / T003**: `FixtureRepo.psm1` lines 209-268.<br>- `mergeWrite` and `resolve` go through `Write-FixtureFile` (lines 249-258).<br>- `mergeDelete` removes files (lines 259-264).<br>- Then `add -A` and a commit with the recipe's message (lines 265-266).<br>- The three refusals are at lines 211-215 (not a merge), 239-244 (unnamed conflict, with `merge --abort`) and 245-248 (nothing to resolve, with `merge --abort`).<br><br>**"A plain merge behaves exactly as today"**: line 224 runs `@('merge','--quiet','--no-ff','--no-edit','-m',$mergeMessage) + $mergeNames`. For a string `merge` that is the parent's argument list exactly. The default message `"merge $(@($commit.merge) -join ' ')"` gives `merge main` for `"merge": "main"` (probe `default-msg-plain`: `msg='merge main'`), as before. All 9 existing merge recipes set `message` anyway. `-Case AMEND-001`: 101 passed, 0 failed.<br><br>**T002, tests first**: I put the parent's `FixtureRepo.psm1` (`git show fad21b7:...`) into a scratch clone and ran the new Describe: `passed=1 failed=8`. The one that passes is the plain-merge control, as notes.md says. Restored with `git checkout --`; `git status` clean.<br><br>**FR-007**: `-Case AMEND-001` passes unchanged, including `pass-merge`. |
| Visual-reference match | N/A: no UI. |
| Feature contract held (no unapproved table/migration/permission/package) | `git diff --name-only fad21b7 15a0e6f` lists exactly `notes.md`, `Harness.Tests.ps1`, `README.md` and `FixtureRepo.psm1`. `git diff --stat fad21b7 15a0e6f -- scripts tests/enforcement/cases` is empty. No package, no script, no new library file. |
| Constitution / domain invariants | See the re-check below. No approved document is touched: under `specs/`, `15a0e6f` adds only `notes.md` (`git show 15a0e6f --name-status -- specs docs .specify` gives `A notes.md`). |
| Security (authn/authz, secrets, sensitive logging) | Test-only code. Fixture repositories keep their own identity (lines 177-180). The new merge path runs git with `-C $root`, under the repository-local `core.autocrlf=false`, `commit.gpgsign=false` and the fixture identity. No user config is read or written. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | In a scratch clone: `pwsh -File scripts/scope-check.ps1 -Commit 15a0e6f -Branch 026-merge-commit-amendment-grading -Root <clone>` gave `scope-check: PASS phase 1 commit 15a0e6f (4 file(s))`, exit 0. The Territory is `tests/**`, plus the feature's own `notes.md`. `git diff --stat` reads as intended: 70 library lines, 112 test lines, 2 README lines, 44 notes lines. |
| Rollback safety (phase reverts cleanly; schema additive?) | Additive. The new fields are optional, and the plain-merge branch is unchanged. Reverting `15a0e6f` restores the parent library, and no existing case uses the new fields. No schema or data. |
| CRLF / platform (brief item 3) | `exp/crlf.ps1` built a conflicting merge with `resolve` and `mergeWrite`, both given CRLF content, in three modes: default, `core.autocrlf=true` forced through `GIT_CONFIG_COUNT` (overriding the repo-local `false`), and default again. In every mode the blobs are LF: `a.txt` 4 bytes, `x.txt` 11 bytes, `z.txt` 7 bytes, and the status is clean.<br><br>Under the forced `autocrlf=true`, only the **working-tree** copy of a file git itself merged in (`z.txt`) gets CRLF. Every checkout in this library already behaves that way, and the repository-local `false` prevents it in practice. This machine's global `core.autocrlf` is `true` and was overridden as designed.<br><br>`Write-FixtureFile` (line 130) strips CR from recipe content. The conflict list comes from git's own `diff --name-only --diff-filter=U`, which prints `/`-separated paths whatever the platform. |
| `hoursAgo`, `checkout`, `detach` after a merge with content (brief item 4) | **`checkout` / `detach`**: unaffected. Probe `detach-after-content-merge`: `head=HEAD`, 2 parents. Probe `checkout-main-after-content-merge`: `head=main`, clean.<br><br>**`hoursAgo`**: ignored on **both** merge paths. Probes `hoursAgo-content-merge` and `hoursAgo-plain-merge` are both dated the build time. This is pre-existing on the plain path, and the new path keeps it. See F3. |

## Findings

### F1 — A merge that is "Already up to date" silently becomes a single-parent commit carrying the merge content — BLOCKING

**Where**: `FixtureRepo.psm1` lines 229-266. The new path runs `git merge --quiet --no-ff --no-commit`, and when the named branch is already an ancestor of HEAD, git prints `Already up to date`, exits 0, and writes no `MERGE_HEAD`. Then:
- `$conflicted` is empty and `$mergeExit` is 0, so no refusal fires.
- The `mergeWrite` content is written.
- `commit --allow-empty -m 'merge main'` makes an **ordinary one-parent commit**.

**Evidence**: `exp/probe.ps1`, case `uptodate-mergeWrite`. Here `feat` branches from `main`, `main` does not move, and `feat` merges `main` with `mergeWrite`. The output was `parents=1 msg='merge main' MERGE_HEAD=False` and `a.txt=edited`, with log `3064a0e 7ba0d68 merge main`, which has one parent.

**Why it matters**:
- This is the "passes for the wrong reason" class the library refuses everywhere else. It is also the class D8 itself names ("refused, never ignored").
- Phase 2 (T006) builds every merge fixture with these fields. A recipe that forgets to move the other branch gets a commit that the amendment check grades as an **ordinary** commit. A `fail-*` fixture would then fail through the ordinary-commit path, and phase 2's new merge-grading code would never run.
- The header (lines 56-66) promises "a MERGE ... with two parents".

**Pre-existing sibling**: the plain path has the same hole in a different form. Case `uptodate-plain` gave `msg='feat work' parents=1`: no commit is made at all, silently, and the recipe's merge entry vanishes. It is outside this diff's change, but it is the same one-line guard.

**Fix shown safe**: in a scratch copy (`exp/guard.ps1`), I added a guard after both merge paths that refuses when HEAD has fewer than two parents.
- All 9 existing merge recipes still build: AMEND-001/pass-merge, SCOPE-014/fail, SCOPE-026/{pass,fail}, REPOS-016/{pass,fail}, REPOS-018/fail and REPOS-034/{fail-no-commits-since-base, fail-skipped-commits}.
- Both up-to-date probes are now refused.
- The module was restored byte-identical (hash compared).

*Action: implementer, inside phase 1 territory (`tests/**`).*
- **Content path (required)**: after `merge --no-commit`, refuse when `.git/MERGE_HEAD` is absent ("merge of X is already up to date: there is nothing to merge, so the result would not be a merge commit. Refused rather than silently made a non-merge"). Alternatively, assert two or more parents after the commit.
- **Self-test**: add one in the same Describe, shown failing before the fix.
- **Plain path (owner's choice)**: apply the same guard. It changes no existing outcome (shown above). "Exactly as today" in D8 means behaviour for valid recipes, and this only refuses a recipe that produced no merge.

### F2 — `resolve` naming a non-conflicted file beside a conflicted one is silently honoured as a write — MINOR

**Where**: lines 239-253. The unnamed-conflict check only looks one way: every conflicted path must appear in `resolve`. Nothing checks the reverse, that every `resolve` name was conflicted.

**Evidence**: probe `resolve-extra-nonconflicted` used `resolve` `{ "x.txt": "hand", "a.txt": "sneaky" }`, where only `x.txt` conflicts. It built with 2 parents, `a.txt=sneaky` and `x.txt=hand`.

**Why it matters**: the notes justify refusing `resolve` on a non-conflicting merge with the argument that "a silently ignored resolve would give a fixture that passes for the wrong reason". The same argument covers a `resolve` entry that is really a `mergeWrite`. A phase 2 fixture meant to show "a conflict resolved taking one side whole" (T006) could also author an unrelated file without the author noticing. The amendment check grades content, not field labels, so the effect is limited, but the field's documented meaning ("content taken for each file a conflicting merge leaves conflicted") is not enforced.

*Action: implementer, with F1's fix. Refuse any `resolve` name not in `$conflicted` (abort first), with one self-test. Alternatively, document the looser meaning in the header.*

### F3 — `hoursAgo` on a merge commit is silently ignored, on both paths, and existing fixtures declare it — CONFIRM

**Where**: both merge branches `continue` before the `hoursAgo` handling at lines 311-324.

**Evidence**:
- Probes `hoursAgo-content-merge` and `hoursAgo-plain-merge` (`"hoursAgo": 30`) are both dated the build time.
- Grep: `REPOS-016/{pass,fail}`, `REPOS-018/fail` and `REPOS-034/fail-no-commits-since-base` put `"hoursAgo": 1` on a merge commit, and `REPOS-034/fail-skipped-commits` puts `"hoursAgo": 0` on one.
- `scope-check-repos.ps1` reads committer dates (header lines 103-105), so those declarations look meaningful, and they are not honoured.

**Why it matters**: it is pre-existing, so this phase did not cause it, and the brief's "unaffected" holds in the narrow sense. But the new path repeats the silent ignore, against the library's own rule, and phase 2/3 fixtures may want a dated merge (the D2 ordering, or a Critical cooling-off).

*Action: owner. Either (a) honour `hoursAgo` on merge commits (both paths), and re-run the REPOS cases whose merges carry it; or (b) refuse `hoursAgo` on a merge. Do not leave it silently ignored. Changing the plain path changes "a merge behaves exactly as today", so it needs the owner's word, either here or as a later feature.*

### F4 — `mergeWrite` silently overrides `resolve` for the same path — MINOR

**Evidence**: probe `resolve+mergeWrite-same` used `resolve` `x.txt: resolved` and `mergeWrite` `x.txt: written` on a conflicting merge. It built with `x.txt=written`. The code applies `mergeWrite` after `resolve` (lines 249-258), and neither the header nor the README says so.

*Action: implementer. Either refuse a path named in both fields, or state the precedence in the header. Refusing is the library's usual choice.*

### F5 — Two conflict shapes cannot be expressed, and the header does not say so: an octopus conflict, and a conflict resolved by deletion — MINOR

**Octopus conflict**: git's octopus strategy refuses to leave conflicts. Probe `octopus-conflict-resolve` threw `fixture git failed: git merge main left | ... Should not be doing an octopus. | Merge with strategy octopus failed.`. The failure is loud, the state is clean (status empty, no `MERGE_HEAD`), and git rolled the tree back. But the header says `resolve` is "the content taken for each file a conflicting merge leaves conflicted", and for an octopus that can never apply.

**Conflict resolved by deletion**: in a modify/delete conflict, `resolve` always **writes** content. Probe `modify-delete-conflict-resolve` built with `x.txt` present. `mergeDelete` does not count as naming the conflict: probe `modify-delete-conflict-mergeDelete-only` threw the unnamed-conflict refusal. So "the merge takes the deletion" cannot be expressed. T006's "a merge that deletes an approved document" can still be built without a conflict, through `mergeDelete`.

*Action: implementer. Add one sentence to the header (an octopus merge cannot carry a conflict, since git refuses it; `resolve` writes content, so a conflict resolved by deletion is not expressible), or extend `resolve` (for example, a null value means delete). This is not needed for T006 as written.*

### F6 — Refusals after the build leave the temporary repository on disk, and the new refusal self-tests leak one per run — MINOR

**Evidence**:
- Every refusal probe left a `kit-fixture-*` directory behind (`leaked=...`), which I deleted.
- In every leaked directory, `MERGE_HEAD` was absent and `git status --porcelain` was empty, so `merge --abort` works and nothing is "half done" *inside* the repository.
- But `New-FixtureRepo` has no `try/finally` around the build, and the four new `Should -Throw` tests (`Harness.Tests.ps1` lines 359-388) cannot clean up, because they never receive the path.
- `%TEMP%` on this machine holds 1280 `kit-fixture-*` directories, so the leak is pre-existing and wider than this phase. The `orphan`, `rename` and `truncateCommit` refusals leak the same way.
- The header comment at lines 145-147 explicitly values "refused FIRST, before a directory exists".

*Action: none required for phase 1. Optionally, wrap the build in `try { ... } catch { if (-not $At) { Remove-Item $root -Recurse -Force }; throw }`, as a library-wide follow-up.*

### F7 — Some self-tests pin less than their titles say — MINOR

I ran 13 mutations in a scratch clone (`exp/mutate.ps1`, running Pester on the new Describe only). The module was restored byte-identical (hash compared).

| Mutation | Failed tests |
|---|---|
| M1 drop `mergeWrite` application | mergeWrite, octopus |
| M2 drop the unnamed-conflict refusal | both conflict refusals |
| M3 drop the non-merge refusal | non-merge refusal |
| M4 merge always commits (`--no-edit` for `--no-commit`) | mergeWrite, octopus |
| M5 drop the nothing-to-resolve refusal | that test |
| M6 drop `resolve` application | resolve |
| M7 drop `mergeDelete` application | mergeDelete |
| M10 octopus array flattened to one string | octopus |
| **M8** plain merges routed through the content path | **none** |
| **M9** default message changed to `merge of a,b` | **none** |
| **M11** `merge --abort` removed before the unnamed-conflict refusal | **none** |
| **M12** `--no-ff` dropped from the plain merge | **none** |

Each targeted mutation fails exactly its intended test or tests. The gaps:
- **The plain-merge control cannot fail.** "Leaves a plain merge exactly as it was" asserts two parents, `a.txt` equal to `HEAD^1`, and `c.txt` present. It does not pin the command (M8, M12) or the default message (M9). No existing case pins the default message either, because all 9 merge recipes set `message`. M12 survives only because the test merge cannot fast-forward, which is git's behaviour, not a test property.
- **No test checks the state after a refusal (M11).** The repository leaks anyway (F6), so the abort is unobservable to every caller today. It is still correct, as F6's evidence shows.
- **The mergeDelete test does not assert two parents.** Under M4 the deletion lands in a separate one-parent commit after the merge, and the test still passes, because `HEAD^1` (the real merge) holds `b.txt`. M1 and M4 are caught by the other tests, so this matters only for the mergeDelete test read on its own.

*Action: implementer, with F1's fix:*
- *Add `Get-ParentCount -Root $root | Should -Be 2` to the mergeDelete test.*
- *Pin the default message in the plain-merge control: omit `message` and assert the subject is `merge main`.*

*M8, M11 and M12 need no test. M8 is only observable through F1.*

### F8 — The two details beyond the plan's words (octopus as an array; `resolve` refused on a merge with nothing to resolve) — ACCEPTED

- **Octopus as an array**: within D8. D8's purpose is "a merge can carry content". Approved `tasks.md` T006 requires "an octopus merge that authors `plan.md`", which the parent library could not express. The change makes no new field and no new behaviour for a string value: the argument list is identical, and the default message is `merge <a> <b>` (probe `octopus-plain-default-msg`: `msg='merge main left'`, 3 parents). It has its own self-test, which M10 fails. Its limit is F5.
- **`resolve` refused on a merge with nothing to resolve**: within D8. D8 itself cites "the library's rule that a field it cannot honour fails loud", and this is that rule applied. F2 is its incomplete half.

Neither needs a plan amendment or a separate owner decision. notes.md records both openly (lines 27-32 of the phase 1 commit), which is the right place.

*Action: none.*

### F9 — Plan D8 misstates the parent's merge command, and notes.md lacks T001's "exact output and exit" of `pass-merge` — DOC DRIFT

- **plan.md D8** says the library "makes a `merge` commit with `git merge --no-ff --no-commit` and commits it". The parent ran `git merge --quiet --no-ff --no-edit -m <message> <branch>` (`git show fad21b7:tests/enforcement/lib/FixtureRepo.psm1`, line 206). `--no-commit` is what the **new** path does. notes.md T001 records the true command, so the code is right and the approved text is stale.
- **T001** asks to record "the exact output and exit of the existing `AMEND-001/pass-merge` case". notes.md says only that it is "the only existing merge fixture", and T004 reports `-Case AMEND-` at 121/0. My `-Case AMEND-001` run gives 101 passed, 0 failed, so the case is unchanged, but the evidence T001 names is absent.

*Action: implementer, for notes.md: record `pass-merge`'s output and exit, or say that the unchanged `expected.txt` comparison under `-Case AMEND-` stands in for it. The plan.md wording needs no action now; correct it at the next owner-approved plan amendment (for example phase 3's), with an approver record (constitution I).*

### F10 — Lenient edges: `mergeDelete` of a missing path, and empty-valued fields on a non-merge commit — MINOR

- **`mergeDelete` of a missing path**: probe `mergeDelete-nonexistent` (`["nope.txt"]`) built a merge whose diff against `HEAD^1` is only `A c.txt`, with no error. A misspelt path therefore gives a merge that authored nothing, which is the *skipped* path, silently. This mirrors the existing `delete` (line 286), so it is consistent, but it is the same wrong-reason risk.
- **Empty values on a non-merge commit**: `"mergeDelete": []` and `"resolve": ""` on a non-merge commit are accepted (probes `nonmerge-empty-mergeDelete` and `nonmerge-resolve-empty-string`), because the presence test is truthiness. `"mergeWrite": {}` is refused.
- **Falsy `merge` with a field present**: `merge` of `false`, `""`, `[]` or `null`, combined with `mergeWrite`, is correctly refused in all four cases (probe `falsy[...]`).
- **Unknown branch**: an unresolvable branch name fails loud on both paths (`merge: nosuch - not something we can merge`).

*Action: none required. Optionally, refuse a `mergeDelete` path that is absent from the merge result.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None.**
- `15a0e6f` changes no approved document. Under `specs/` it only adds `specs/026-merge-commit-amendment-grading/notes.md`, which is phase evidence, not law. `spec.md`, `plan.md`, `tasks.md` and `contracts/` are untouched.
- `61bd6ed` changes `notes.md` only.
- The two details beyond D8's words are recorded in notes.md, not written into the plan. I judge them within D8 (F8).
- The D8 wording drift (F9) is pre-existing text, not an amendment.

## Constitution re-check (post-implementation)

**PASS, with VIII engaged (F1).**
- **I (Amendment authority)**: no approved document amended, and no self-approval.
- **II**: the code follows the plan and tasks. The one approved-text inaccuracy (D8's description of the parent) is DOC DRIFT (F9), not a conflict in what is required.
- **III, V, VI, VII**: N/A. There is no UI, no data, nothing sensitive and no external integration.
- **IV**: no new file outside `tests/**` and notes, and no package.
- **VIII (tests measure something)**:
  - The self-tests were written first and fail 8 of 9 on the parent.
  - Mutations M1-M7 and M10 each fail exactly the intended test.
  - F1 is a hole in the "refused, never ignored" guarantee that D8 states.
  - F7 lists the tests that pin less than their titles say.
- **IX**: the review file carries Reviewer Provenance.
- **X**: one phase, with a user-run gate (certified by the owner per `61bd6ed`). `scope-check` PASS.

## Test coverage observed

All runs were in a scratch clone (`<scratchpad>/k026`) of the branch tip. The working repository was never mutated, and `git status --porcelain` in the clone was empty after every mutation.

| Run | Result |
|---|---|
| `Run-Tests.ps1 -Case NOTHING` (self-tests plus coverage) | 53 passed, 0 failed, `enforcement-tests: OK` |
| `Run-Tests.ps1 -Case AMEND-001` (includes `pass-merge`) | 101 passed, 0 failed |
| The new Describe against the **parent** library | 1 passed (plain-merge control), 8 failed |
| Mutations (13; table in F7) | 9 caught exactly as intended; M8, M9, M11, M12 caught by nothing (F7) |
| Edge probes (`exp/probe.ps1`, 30 cases) | Every brief item exercised. One defect (F1). The rest are MINOR or ACCEPTED |
| CRLF (`exp/crlf.ps1`) | Blobs LF in all modes |
| Guard trial (`exp/guard.ps1`) | All 9 existing merge recipes build under a two-parent guard. Both up-to-date probes are refused |
| `scope-check.ps1 -Commit 15a0e6f` | PASS, 4 files |
| Full harness | Not run, per instructions. notes.md records 1529/0/0 (1520 + 9) |

The edge probes covered:
- up-to-date and fast-forwardable merges;
- an unnamed conflict;
- `resolve` with an extra name;
- `resolve` and `mergeWrite` on the same path;
- `mergeWrite` on a conflicted path without `resolve`;
- `mergeDelete` of a missing path;
- modify/delete conflicts;
- falsy `merge` values;
- empty field values on a non-merge commit;
- octopus merges with and without conflict;
- an unknown branch;
- default messages;
- `hoursAgo`, `detach` and `checkout` after a merge with content;
- CRLF content under a forced `core.autocrlf=true`;
- `resolve` given as an array.

## Residual risk

- **Before phase 2 starts**: fix F1. Phase 2 builds every merge fixture on this path, and an up-to-date recipe would silently test the ordinary-commit path. Fold in F2 and F7's two assertions, which are cheap and in the same territory. The owner decides F3 (`hoursAgo` on merges: honour or refuse).
- **Accepted**: the octopus array and the nothing-to-resolve refusal are within D8 (F8).
- **Low**: the documentation gaps (F4, F5), leaked temp repositories on refusal (F6, library-wide), lenient empty values (F10), and the D8 wording and T001 evidence (F9).
- **Before merge**: the owner's gate on the remediated phase 1 commit, and the human review.
