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
