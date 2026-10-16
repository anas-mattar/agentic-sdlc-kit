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
