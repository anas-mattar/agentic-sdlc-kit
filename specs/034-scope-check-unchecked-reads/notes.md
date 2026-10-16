# Notes: the scope checks name a merge base or commit list they cannot read

Evidence for feature 034 (GAP-040). Nothing here is law; `spec.md`, `plan.md` and `tasks.md` are.

## Pre-spec measurement (2026-10-17, git 2.55.0.windows.5)

Method: the kit's own fixtures materialised with `tests/enforcement/Run-Tests.ps1 -Case <case> -KeepRepo` (`scope-check/SCOPE-025/pass`, a feature branch and a trunk,
and `scope-check-repos/REPOS-001/pass`, a governance repository and a code repository), the scripts run against them with `-Root <fixture>`, and one loose object
removed or truncated in `.git/objects` (a copy kept, restored afterwards). Nothing in the project was touched.

| # | Probe | Result |
|---|---|---|
| M1 | `scope-check.ps1 -All`, intact | `not applicable (commit ... carries no 'phase N' token)` then `PASS phase 1 commit 1879554 (1 file(s))`, exit 0 |
| M2 | the same, the **tip** commit object deleted | `UNGRADED could not resolve a merge base with main - nothing checked`, **exit 0** |
| M3 | the same, the tip commit object **truncated** to half its bytes | the same, **exit 0** (`git merge-base HEAD main` exits 128) |
| M4 | the same, the **middle** (spec) commit object deleted | the same, **exit 0**; `-Commit <tip>` on that branch gives feature 032's `ERROR commit 1879554: its changed files could not be read ...`, exit 1 |
| M5 | `scope-check.ps1 -All` on a branch with **no history in common** with the trunk (an orphan branch) | the same `UNGRADED could not resolve a merge base with main`, exit 0: a legitimate state with the same message |
| M6 | `scope-check-repos.ps1 -All`, intact | `PASS phase 1 commit bbd36e9 (1 file(s))`, exit 0 |
| M7 | the same, the code repository's tip commit object deleted | `code-repo: UNGRADED could not resolve a merge base with a trunk (origin/main, main, origin/master, master, origin/HEAD) - NOTHING WAS GRADED in this repository ...`, then `UNGRADED (nothing was graded ...)`, **exit 0** |
| M8 | the same, default (tip) mode | `code-repo: ERROR '001-thing' does not resolve to a commit`, exit 1 |

git's exit codes on the same states (the scripts read none of them):

| Command | State | Exit |
|---|---|---|
| `git merge-base HEAD main` | the middle commit object deleted | **255** |
| `git merge-base HEAD main` | the tip commit object truncated | **128** |
| `git merge-base HEAD main` | no shared history (orphan) | **1** |
| `git rev-parse --verify --quiet main` | main intact | 0 |
| `git rev-parse --verify --quiet nosuchref` | the ref does not exist | **1** |
| `git rev-list --reverse --no-merges <main>..HEAD` | the middle commit object deleted | **128** |

So "git answered: none" (exit 1) and "git could not read" (128 or 255) are different exits for `merge-base`, which the scripts collapse into `$null`. `rev-list` over a range that
`merge-base` has just walked is the likely unreachable state: both read the same commit objects, so a fixture that makes `rev-list` fail after a successful merge base is probably not constructible
(the plan decides, and exempts with a reason).

Where it comes from: `scripts/scope-check.ps1:86-95` (`Get-DiffBase`: `git merge-base HEAD $c 2>$null`, return `$null` unless exit 0), `:319` and `scope-check-repos.ps1:379` (`git rev-list ... 2>$null`),
`scripts/scope-lib.ps1:204-217` (`Get-RepoMergeBase`, also called by `territory-check.ps1:143`, whose comment says the scope check reports "no shared history" and "no trunk" as one message and "may keep doing so").
`ritual-checks.ps1` runs `scope-check.ps1 -All` (the phase 2 review of feature 033 read `:150`), so CI is green on M2 to M4 and M7.

Not measured here, and the plan must: the same probes on the CI image's git; the exit code of `git merge-base` when the *trunk* object is damaged rather than the branch's; and whether
`territory-check.ps1` is affected the same way (it reads the same function; D2).
