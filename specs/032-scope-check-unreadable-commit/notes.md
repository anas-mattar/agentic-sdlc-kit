# Notes: the scope check names a phase commit whose diff cannot be read

Evidence for feature 032 (GAP-038). Nothing here is law; `spec.md`, `plan.md` and `tasks.md` are.

## Pre-spec measurement (2026-10-16, git 2.55.0.windows.5)

Method: the kit's own fixtures materialised with `tests/enforcement/Run-Tests.ps1 -Case <case> -KeepRepo` (`scope-check/SCOPE-001/pass`
and `scope-check-repos/REPOS-001/pass`), the scripts run against them with `-Root <fixture>`, and one loose object removed from
`.git/objects` (a copy kept, restored afterwards). A second, hand-built repository (a feature branch whose `tasks.md` declares one
source file, a phase commit adding a second file outside it) gave the out-of-territory row. Nothing in the project was touched.

| # | Probe | Intact | Object unreadable |
|---|---|---|---|
| M1 | `scope-check.ps1`, a phase commit; the commit's **tree** removed | `PASS phase 1 commit ac9be87 (1 file(s))`, exit 0 | `PASS phase 1 commit ac9be87 (0 file(s))`, exit 0 |
| M1b | the same, with the phase commit adding a file outside the declared Territory | `FAIL phase 1 commit a407d84: outside/evil.ps1 not in territory`, exit 1 | `PASS phase 1 commit a407d84 (0 file(s))`, exit 0 |
| M2 | `scope-check.ps1`, a commit `chore: tidy` (no phase token) deleting `specs/001-thing/tasks.md`; its tree removed | `FAIL commit c74b86d: the commit deletes specs/001-thing/tasks.md - a feature's declaration files must never be deleted ... (review F2)`, exit 1 | `not applicable (commit c74b86d carries no 'phase N' token - not a phase commit)` then `UNGRADED no commit on '001-thing' was graded`, exit 0 |
| M3 | `scope-check-repos.ps1`, a code repository's phase commit; its tree, or a subtree, removed | `PASS phase 1 commit 1857b42 (1 file(s))`, exit 0 | `ERROR cannot read the committer date of 1857b42`, exit 1 (`git show -s` fails first, so the shared function is never reached) |
| M4 | `scope-check.ps1`, the `tasks.md` **blob** of the spec commit removed | `PASS` | `FAIL phase 1 commit ac9be87: specs/001-thing/tasks.md is missing at the parent while specs/001-thing/ exists - a prior commit deleted the territory declaration`, exit 1 (wrong cause, but a FAIL) |

Where the empty list comes from: `scripts/scope-lib.ps1:29` (`Get-CommitPaths`, `git show --name-status ... 2>$null`, no exit check)
and `scripts/scope-check.ps1:123` (the delete guard, the same read). `Get-CommitPaths` is called from `scope-check.ps1:187` (Micro
lane), `:255` (Standard lane) and `scope-check-repos.ps1:271`. The Micro lane was not run on its own: it calls the same function.
The earlier reads of `scope-check.ps1` (`git rev-parse --short`, `git rev-list --parents`, `git log -1 --format=%s`) all succeed on
a commit with a missing tree, which is why nothing stops before the changed-file read.

The harness already reaches the state: `truncateCommit` takes any revision (`git rev-parse <rev>`), and feature 026's fixture used it
on a tree (`HEAD^2^{tree}`). `HEAD^{tree}` is the object M1 and M2 removed.

Not measured here, and the plan must: the output of a **readable empty** commit (`git commit --allow-empty`), which must stay
`PASS ... (0 file(s))`; and the same probes on the CI image's git.

## Plan-time measurements (2026-10-16, git 2.55.0.windows.5)

| Probe (the kept fixture repository of `SCOPE-001/pass`) | Result |
|---|---|
| a readable **empty** phase commit (`git commit --allow-empty -m "phase 1: ..."`): `git show --name-status --format=` | empty output, exit 0; `scope-check.ps1` prints `PASS phase 1 commit 5eca3ec (0 file(s))`, exit 0. This is the output FR-002 keeps. |
| the phase commit's tree object **truncated to half its bytes** (the damage `truncateCommit` makes) | `git show` prints `error: corrupt loose object ...` and `fatal: loose object ... is corrupt`; `scope-check.ps1` prints `PASS phase 1 commit ac9be87 (0 file(s))`, exit 0 (the same state as removing the object). |

The harness commits every recipe entry with `--allow-empty` (`FixtureRepo.psm1:412`), so an entry with no files is the empty
readable commit of FR-002. The CI image's git and the flag's scope across both callers are the phase 1 tasks T001 and T002.

## Phase 1: a commit whose changed files cannot be read is an ERROR

### T001 Baseline on the parent commit (`8f31ab9`)

Full harness on an isolated detached worktree: **1809 passed, 0 failed, exit 0**. Coverage: `scope-check.ps1` 28 of 28 sites fixtured,
`scope-check-repos.ps1` 29 of 30 (1 exempt), 6 rules exempt from a fixture pair. The saved text for the byte comparison of T007 is the
harness itself: every readable state is already pinned byte for byte by an existing case (a passing Standard phase commit `SCOPE-019`,
a Micro one `SCOPE-016`, a failing one `SCOPE-001`/`SCOPE-011`, a merge commit `SCOPE-014`, a commit with no phase token `SCOPE-015`,
the deletion of `tasks.md` `SCOPE-004`, the nested-repository commit `REPOS-001`); the readable empty commit, which no case pinned,
is measured above (`PASS phase 1 commit 5eca3ec (0 file(s))`, exit 0) and pinned by the new `SCOPE-028/pass-empty`.

### T002 The design probes

- **(a)** A throwaway library function reading `git show --name-status` and `$LASTEXITCODE` on the next statement, dot-sourced by a
  script and called from inside `Push-Location`/`try`/`finally` (as `scope-check-repos.ps1` calls `Get-CommitPaths`), set a
  `$script:` flag the caller read: readable `rows=1 failed=False`, tree truncated `rows=0 failed=True`.
- **(b)** On the same commit with the tree truncated, `git rev-parse --short`, `git rev-list --parents -n 1` and `git log -1 --format=%s`
  all work (`ac9be87`, the parent, `phase 1: the thing`): nothing stops before the changed-file read, which is why the parent
  printed `PASS (0 file(s))`. The tree truncated to half its bytes and the tree removed behave alike (`fatal: ... corrupt` / `unable to read tree`).
- **(c)** A commit at a shallow boundary (`git clone --depth 1`) is readable: `git show --name-status` exits 0 and lists every file as added;
  unchanged by this feature.
- **(d)** The CI image's git is the CI run of the branch (the second git); not run here.

### T003 Fixtures written first, shown failing on the parent

`SCOPE-028` (`fail`, `pass`, `pass-empty`), `SCOPE-029` (`fail`, `pass`), `SCOPE-030` (`fail`, `pass`). On the parent commit each `fail`
fails for the stated reason and each `pass` passes: `SCOPE-028/fail` observed `PASS phase 1 commit <SHA> (0 file(s))`,
`SCOPE-029/fail` observed `PASS phase 1 commit <SHA> (0 file(s), Micro territory from spec.md)`, `SCOPE-030/fail` observed
`not applicable (commit <SHA> carries no 'phase N' token ...)`. `SCOPE-030/pass` is the same token-less deleting commit readable: the
guard refuses it (`FAIL commit <SHA>: the commit deletes specs/001-thing/tasks.md ...`), so the pair differs only in the tree.
(The first draft of the fixture script used a function named `Rd`, which PowerShell resolves to the `Remove-Item` alias, and deleted
three existing case files; they were restored with `git checkout` before anything was committed, and the helpers were renamed.)

### T004 to T006 The rules, the scripts, the self-test

Rules `SCOPE-028` to `SCOPE-030` (one shared emission site, the line `Write-UnreadableCommit` prints) and `REPOS-035` (exempt, with the
reason of plan P5). `scripts/scope-lib.ps1`: `Get-CommitStatusRows` with `$script:CommitReadFailed`, and `Get-CommitPaths` calling it
with `-Renames`. `scripts/scope-check.ps1`: the guard reads through the helper (no `-M`, as before), the two phase lanes read the flag
after `Get-CommitPaths`, and every unreadable commit ends in the `ERROR` line and `$false`. `scripts/scope-check-repos.ps1`: the flag is
read after its call (`<repo>: ERROR cannot read the changed files of <sha7>`, `'FAIL'`), unreachable today. New file
`tests/enforcement/ScopeLib.Tests.ps1` (5 tests of `Get-CommitStatusRows` and the flag, in a repository built with plain git).
End to end on the kept fixture: intact `PASS phase 1 commit ac9be87 (1 file(s))`, tree truncated `ERROR commit ac9be87: its changed files
could not be read ... run git fsck.`, exit 1, restored `PASS ... (1 file(s))`.

### T007 Numbers (isolated detached worktrees outside the repository; the changed files copied into the second)

| | Parent `8f31ab9` | Phase 1 working tree |
|---|---|---|
| full harness | 1809 passed, 0 failed, exit 0 | **1828 passed, 0 failed, exit 0** (the 19 more: 5 `ScopeLib` tests and the 14 tests of the 7 new cases) |
| `-Case SCOPE-` / `-Case REPOS-` | inside the full run | 339 and 219 passed, 0 failed |
| `scope-check.ps1` sites fixtured | 28 of 28 | 29 of 29 |
| `scope-check-repos.ps1` sites fixtured | 29 of 30 (1 exempt) | 29 of 31 (2 exempt: the new `REPOS-035`) |
| rules exempt from a fixture pair | 6 | 7 |
| readable commits, byte for byte | every existing case pinned | every pre-existing case passes unchanged (no case was re-expected) |

### Phase 1 review follow-ups (`ai-code-review-phase1.md`, APPROVE with follow-ups, no blocking finding)

- **F1 (line endings), fixed in `d02ecc9`:** the phase 1 commit had converted `scripts/scope-lib.ps1` and `scripts/scope-check-repos.ps1` from LF to
  CRLF (the cause is not established: both files were edited with the editor tool, and `scope-check.ps1`, edited the same way, had been rewritten to LF by a later script); the real change is 18 and 6 lines, and the diff of those two files against the parent is now 18 and 6
  lines again (`git diff --stat 8f31ab9`: 36 insertions, 2 deletions across the three scripts). `-Case SCOPE-` 344 passed and `-Case REPOS-` 224 passed after the fix.
- **F6 (numbers):** the 339 and 219 recorded for `-Case SCOPE-` and `-Case REPOS-` were taken before `ScopeLib.Tests.ps1` existed; with the case
  filter the five `ScopeLib` tests also run, so the runs at the tip are **344 and 224**, as the reviewer observed. T006 names `Harness.Tests.ps1`; the
  self-test is the new file `tests/enforcement/ScopeLib.Tests.ps1`, because `Harness.Tests.ps1` tests the harness with throwaway scripts and never a kit
  function (its own header); the file is inside `tests/**`.
- **F5 (the `SCOPE-030` pair):** plan P5 and task T003 describe `pass` as the commit "readable and not deleting"; the shipped `pass` is the same
  token-less commit readable **and still deleting**, so the guard refuses it (`FAIL commit ...: the commit deletes specs/001-thing/tasks.md`). That is the
  stricter pair: `pass` and `fail` differ only in the truncated tree, and the pair shows the guard working and then failing to see. No document is amended.
- **F4 (exemption wording):** the `REPOS-035` exemption now says its reason is a property of git 2.55, with the CI run as the second git.
- **F2 (T002 item d):** the probe on the CI image's git is the CI run of the branch; its result is recorded below when it finishes.
- **F3 (open, for the owner):** with a phase commit **object deleted**, `scope-check.ps1 -All` prints `UNGRADED could not resolve a merge base` and
  exits 0 (`Get-DiffBase`, `:81-93`), and the same discarded-error pattern is in the `git rev-list` of `scope-check.ps1` (`:319`) and
  `scope-check-repos.ps1` (`:379`); `git rev-list --parents` (`:118`) and `git log -1 --format=%s` (`:156`) discard errors too but sit behind the new guard.
  `-Commit` on the same commit gives the new ERROR. Decision for the owner: a new GAP (GAP-040) recorded in phase 2's roadmap commit, or a stated
  limit in the flow-down note, or both.

## Phase 2: guidance, close and measurement

### T010 The measurement (plan P8, SC-001, SC-002)

Method (the one of features 030 and 031): for each project a `git clone` from its local directory into a scratch area (the real projects never touched).
The kit before this feature (`989411f`, the merge of PR #100) applied with `update-kit.ps1`, `build-digests.ps1` run and committed ("measure: kit before"); the kit as
it stands (`937cde6`, whose three scope scripts are the phase 1 files) applied the same way ("measure: kit now"). Four commits were chosen **once**, from each
project's own history before any measure commit (two with a phase token, one without, one merge), so both states grade the same shas. Probes in each state, on a
fresh copy of the committed clone: `scope-check.ps1 -Commit <sha> -Branch <feature>` on each; `doc-lint.ps1`; `ritual-checks.ps1 -Branch main`; and the damage probe: a fresh
branch `099-probe` whose phase commit adds one file inside its declared Territory and one outside, graded intact, then with that commit's tree object truncated
(the clones' own objects are packed, so a new loose commit is built).

(A first run of this measurement was discarded: the clones' `core.autocrlf` was set after cloning, which made the working tree dirty, `update-kit.ps1` refused the "before"
apply, and the commits were chosen with `HEAD~1`, which is a different commit in each state. Both were fixed and the whole measurement was run again.)

| Probe | FitForge, FlowBoard, ExpenseTracker |
|---|---|
| four commits of the project's own history | **byte-identical before and after** in all three (a PASS of 1 or 2 files, `not applicable` for a commit with no phase token and for a merge, a WARN for a phase with no declared territory) |
| `doc-lint.ps1` | exit 0; **byte-identical before and after** |
| `ritual-checks.ps1 -Branch main` | `RESULT OK` in every state; **two lines moved, and only two:** the enforcement-pack diff base commit (each clone's own commit) and `verify-kit`'s recorded kit commit (`989411f...` to `937cde6...`) |
| the damage probe, intact | `FAIL phase 1 commit <sha>: elsewhere/outside.txt not in territory`, exit 1 |
| the damage probe, tree unreadable, **before** | `PASS phase 1 commit <sha> (0 file(s))`, **exit 0**: the out-of-territory file passes |
| the damage probe, tree unreadable, **now** | `ERROR commit <sha>: its changed files could not be read (git show --name-status failed) ... run git fsck.`, **exit 1** |

The real projects were checked afterwards: no `probe` branch in any of them, and the same working-tree state as before (FitForge: one untracked file; FlowBoard: two;
ExpenseTracker: none). Not exercised: the Micro lane and the delete guard on a project's own history (the fixtures prove them), the nested-repository grader, the
Linux platform (the CI run of the branch), and a damaged object that is not a loose tree.

### T008 and T009 Guidance and close

`adoption/updating.md`: a flow-down note in the shape of feature 031's, with no digest marker (the adoption digest is at its 40-bullet bound; `build-digests.ps1 -Check` is OK,
5 digests, 119 markers). It states the F3 limit (`-All` can still end on UNGRADED when a commit object is missing), the unchanged blob reads and the git version. `docs/roadmap.md`:
GAP-038's status text, the row `shipped`, a decisions-log entry, and **GAP-040** (the other unchecked reads, owner decision "both") as an inventory row and an `idea` row.
Main had already taken the claim flip of PR #101, so `main` was merged into the branch before the row was edited and nothing conflicts at the merge.
