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

## Phase 1: a merge base or commit list git could not read is an ERROR

### T001 Baseline on the parent commit (`efa3bbc`)

The saved text of the legitimate states is the harness itself: each is pinned byte for byte by an existing case that still passes at the tip (a missing trunk `SCOPE-025/fail`, a passing
`-All` run `SCOPE-025/pass`, the nested-repository runs `REPOS-001` and the no-trunk and no-history `REPOS-` cases, and `TERR-` for `territory-check.ps1`, which shares `Get-RepoMergeBase`). The
full-harness count on an isolated detached worktree of the parent is in T006.

### T002 Probes of the design (git 2.55.0.windows.5)

- **(a) Exit codes**, in addition to the pre-spec table: a **commit older than the base** deleted makes `git merge-base HEAD main` exit **255** while `git rev-list <base>..HEAD` exits **0**
  (the reverse of the order that would make `rev-list` reachable); a tip commit deleted gives merge-base **128**, a middle commit deleted **255**. A scratch repository of five commits was used for the
  older-than-base probe; nothing in the project was touched.
- **(b) `truncateCommit`:** `HEAD` truncates the tip on a governance fixture (`SCOPE-031/fail`) and **in a nested recipe on a code repository** (`REPOS-036/fail`): both fixtures reach the
  merge-base state (on the parent they print `UNGRADED could not resolve a merge base ...`, exit 0), so no new harness field is needed.
- **(c) `rev-list` after a successful `merge-base`:** no damage constructed makes it fail. `merge-base` walks every commit from the tip to the base, which is what `rev-list <base>..<tip>` reads, so a
  damaged tip or middle commit fails the merge base first; a damaged commit older than the base fails `merge-base` and not `rev-list`. The two commit-list sites are therefore exempt (`SCOPE-032`,
  `REPOS-037`), with that reason written in `rules.json`.
- **(d)** The CI image's git is the CI run of the branch (the second git); the fixtures pin exit 128 for a truncated tip commit.

### T003 Fixtures written first, shown failing on the parent

`SCOPE-031` (`fail`, `pass`, `pass-orphan`) and `REPOS-036` (`fail`, `pass`). On the parent commit each `fail` fails for the stated reason (observed `scope-check: UNGRADED could not resolve a merge base with main
- nothing checked` and `scope-repos: code-repo: UNGRADED could not resolve a merge base with a trunk (...)`, both exit 0) and each `pass` passes, including `pass-orphan` (a branch with no history in common: `UNGRADED`,
exit 0, which the new code keeps). The `REPOS-036/fail` expectation is two lines: the repository's `ERROR` and the run-level `UNGRADED (nothing was graded ...)`, which is true and which every repository run that
grades nothing prints.

### T004 and T005 The rules and the scripts

Rules `SCOPE-031` and `REPOS-036` (one emission site each) and `SCOPE-032`, `REPOS-037` exempt, with the reason above. `scripts/scope-lib.ps1`: `Get-RepoMergeBase` classifies `rev-parse --verify --quiet`
(exit 1: no such ref) and `merge-base` (exit 1: no shared history) as answers, any other non-zero exit as a failure, and returns `Failed` and `FailedWith` beside the existing members, true only when no candidate
gave a base and one could not be read (a later candidate's base wins over an earlier failure). `scripts/scope-check.ps1`: `Get-DiffBase` the same, with `$script:DiffBaseFailure`; `-All` prints
`ERROR could not read the merge base with main (<command> failed with exit <n>)` and exits 1, and checks `git rev-list` on the next statement (`ERROR could not list the commits since the merge base`).
`scripts/scope-check-repos.ps1`: the same two lines, prefixed with the repository, setting `$failed` and going on to the next repository. `territory-check.ps1` is not changed. End to end on the kept fixture:
intact `PASS`; the tip commit object deleted `ERROR ... (git merge-base failed with exit 128)`, exit 1; the middle commit object deleted `ERROR ... exit 255`, exit 1; restored `PASS`.

### T006 Numbers (isolated detached worktrees outside the repository; the changed files copied into the second)

| | Parent `efa3bbc` | Phase 1 working tree |
|---|---|---|
| full harness | 1838 passed, 0 failed, exit 0 | **1848 passed, 0 failed, exit 0** (the 10 more are the 5 cases of `SCOPE-031` and `REPOS-036`) |
| `scope-check.ps1` sites fixtured | 29 of 29 | 30 of 31 (1 exempt: `SCOPE-032`) |
| `scope-check-repos.ps1` sites fixtured | 29 of 31 (2 exempt) | 30 of 33 (3 exempt: `REPOS-037` added) |
| rules exempt from a fixture pair | 7 | 9 (`SCOPE-032`, `REPOS-037`) |
| `-Case SCOPE-`, `-Case REPOS-`, `-Case TERR-` | inside the full run | 364, 238 and 238 passed, 0 failed (the filters overlap: `SCOPE-` also matches `scope-check-repos`) |
| the legitimate states (no trunk, no shared history, an empty range, a readable run) | pinned by existing cases | every pre-existing case passes unchanged; none was re-expected |

`territory-check.ps1` is untouched; `-Case TERR-` passes unchanged (it reads `Base` and `Existing` of `Get-RepoMergeBase`, which keep their meaning).

### Phase 1 review follow-ups (`ai-code-review-phase1.md`, APPROVE with follow-ups, no blocking finding)

- **F1 (the exemptions were wrong), fixed with the owner's approval of the amendment (anas.m, 2026-10-17):** the reasons written for `SCOPE-032` and `REPOS-037` (in `rules.json`, plan P5 and T002(c) above) said
  `git rev-list` over the range can fail only after `git merge-base` has failed. With a **commit-graph**, git answers `merge-base` from the graph without reading the commit objects, so a truncated tip commit leaves
  `merge-base` exiting 0 while `rev-list` exits 128; the reviewer reproduced it through both scripts (the parent printed `UNGRADED (no commits since merge base)`, exit 0; the tip, the new `ERROR`). The line is live code,
  not defence in depth. Phase 1 therefore gained one recipe field, `commitGraph` (`FixtureRepo.psm1` runs `git commit-graph write --reachable` after the commits and before any truncation, with a three-test self-test in
  `Harness.Tests.ps1`: the graph file is written; with it, `merge-base` exits 0 and `rev-list` fails; without it both fail), and `SCOPE-032` and `REPOS-037` have real `fail`/`pass` fixtures, shown failing on the parent
  (`UNGRADED (no commits since merge base - no commit was examined)`, exit 0) and passing at the tip. The exempt count stays 7. The spec (Assumptions), plan (P5, Source Code, Complexity Tracking) and tasks (T003, T004) were
  amended, each with the approver record.
- **F2 (a garbage ref file):** a corrupt `refs/heads/main` file makes `rev-parse --verify --quiet` exit 1, which reads as "no such ref": `UNGRADED`, exit 0, on parent and tip. A stated limit; git itself answers "no ref" there.
- **F3 (accepted):** an unborn HEAD with `origin/main` present, or a trunk that is a tag of a tree, now gives `ERROR` where the parent gave `UNGRADED`, because `git merge-base` exits 128 for them. FR-006's "byte for byte" is for
  readable repositories; these two states are not readable in git's sense.
- **F4 (accepted):** when `origin/main` is damaged and `main` is readable, `main` wins silently (plan P1). A stale `main` only widens the range, so a branch commit is never missed; at worst other features' commits are graded, which can
  produce a spurious FAIL and never a PASS.
- **F5 (a second `Get-DiffBase`):** `scripts/enforcement-pack.ps1:186-200` has its own `Get-DiffBase` with the same discarded read. Its consequences are the pack's named states (feature 028), so it is not in this spec; it is recorded
  for phase 2 (a stated limit in the flow-down note and, if the owner agrees, a roadmap row).
- **F6 (shallow CI checkouts):** a depth-1 clone (the default `actions/checkout`) has no merge base with the trunk: git answers exit 1, so it stays `UNGRADED`, exit 0, as before. The flow-down note will say CI needs
  `fetch-depth: 0` for `-All` to read a merge base at all.
- **F7 (accepted):** the fixtures pin `exit 128` for a truncated tip commit, measured on git 2.55.0.windows.5; the CI run of the branch is the second probe.
- **F8 (notes):** the damaged **trunk** object case was not in T002: the reviewer measured it, `git merge-base` exits 128 (and `rev-parse --verify --quiet` of a corrupt ref file exits 1, F2). `scope-lib.ps1` has no line in the coverage
  sweep's site counts (only the two scripts do); T001 recorded the two scripts' counts and the harness total.

### T006 again, after the amendment: numbers at `c565660`

The full harness on an isolated detached worktree of `c565660` (below, recorded when it finishes) replaces the 1848 of T006: the changed code plus `commitGraph`, its three self-tests and the 8 cases of `SCOPE-032` and `REPOS-037`.

| Measure (isolated detached worktree of `c565660`) | Result |
|---|---|
| full harness | **1859 passed, 0 failed, exit 0** (the parent's 1838 plus the 10 of `SCOPE-031`/`REPOS-036`, the 8 of `SCOPE-032`/`REPOS-037` and the 3 self-tests of `commitGraph`) |
| `scope-check.ps1` sites fixtured | 31 of 31 (no exemption) |
| `scope-check-repos.ps1` sites fixtured | 31 of 33 (2 exempt: the two it already had; `REPOS-037` is real) |
| rules exempt from a fixture pair | 7 (unchanged from the parent) |

## Phase 2: guidance, close and measurement

### T009 The measurement (plan P6, SC-001, SC-002)

Method (features 030 to 033, with the lesson of 033): the script of the kit before this feature (`07b7ed1`) and the script as it stands (`336c410`), each run with `-Root <clone> -Branch <probe> -All` against **the same fresh clones**
of FitForge, FlowBoard and ExpenseTracker (the real projects never touched, nothing pushed). Three probe branches per project, made in the clones: an **intact** feature branch (`099-probe`: a spec commit declaring a Territory
and a phase commit inside it), an **orphan** branch (`098-orphan`, no history in common with the project's `main`), and the intact branch with its **tip commit object truncated** to half its bytes. Clones are made with `--no-hardlinks`.

| Probe | FitForge, FlowBoard, ExpenseTracker |
|---|---|
| intact branch, `-All` | **byte-identical before and after**: `not applicable (commit ... carries no 'phase N' token)` then `PASS phase 1 commit ... (1 file(s))`, exit 0 |
| orphan branch, `-All` | **byte-identical before and after**: `UNGRADED could not resolve a merge base with main - nothing checked`, exit 0 (a legitimate state, kept) |
| tip commit truncated, `-All`, before | `UNGRADED could not resolve a merge base with main - nothing checked`, **exit 0** |
| the same, now | `ERROR could not read the merge base with main (git merge-base failed with exit 128), so nothing on the branch was graded - the object store may be damaged: run git fsck.`, **exit 1** |

The real projects were checked afterwards: no probe or orphan branch in any of them, and the same working-tree state as before (FitForge one untracked path, FlowBoard two, ExpenseTracker none).

A first run of this measurement was discarded: the damaged clone was made from the intact one with a plain local `git clone`, which hardlinks loose objects, so truncating the tip commit in one corrupted the same file in the other and the
"intact" probe printed the damaged result in both states. It was rerun with `--no-hardlinks`. Not exercised: `scope-check-repos.ps1` on an adopted project (a governance clone has no code repository present, so it prints `n/a`; the fixtures prove
it, including the nested code repository), the commit-list `ERROR` on a project clone (it needs a commit-graph; `SCOPE-032` and `REPOS-037` prove it), and the Linux platform (the CI run of the branch).

### T007 and T008 Guidance and close

`adoption/updating.md`: a flow-down note in the shape of feature 033's, no digest marker (the adoption digest is at its 40-bullet bound; `build-digests.ps1 -Check` is OK, 5 digests, 119 markers). It states the six limits (the
pack's own `Get-DiffBase`, the depth-1 clone and `fetch-depth: 0`, the corrupt ref file, `territory-check.ps1`, the pinned exit 128, the message wording), what turns red, and what to do. `docs/roadmap.md`: GAP-040's status text,
the row `shipped`, a decisions-log entry, and **GAP-041** (the pack's own `Get-DiffBase`, owner decision) as an inventory row and an `idea` row at P3. The pack's `Get-DiffBase` is less severe than the scope check's was: a numbered branch with
no base still fails there, with the wrong cause named, and only a Lite-lane branch merely warns.

### T009 again: `scope-check-repos.ps1` on the three real projects (phase 2 review, finding F2)

The measurement script above ran only `scope-check.ps1`; the review asked for the other grader. All three projects declare code repositories that exist locally, as separate repositories, so a governance clone does not carry them and
copying the projects (`node_modules` and all) was not practical. The scripts only read git, so `scope-check-repos.ps1 -All -Root D:/solutions/<project> -Branch <feature>` was run **in place**, once with the script of `07b7ed1` and once with
`7a96899` (two detached kit worktrees, removed afterwards), on a feature branch each code repository carries: FitForge `002-identity-member-profile`, FlowBoard `008-realtime-sync`, ExpenseTracker `003-expense-entry`.

| Project | Before and after | Content |
|---|---|---|
| FitForge | **byte-identical** | 14 `PASS` lines (10 in `fitforge-api`, 4 in `fitforge-web`), exit 0 |
| FlowBoard | **byte-identical** | `UNGRADED (no commits since merge base - no commit was examined)` for both repositories (the branch is merged), exit 0 |
| ExpenseTracker | **byte-identical** | its own pre-existing result (24 lines including a territory WARN and the empty-range `UNGRADED` lines), exit 1 both before and after |

The working-tree state of each project was checked afterwards (FitForge one untracked path, FlowBoard two, ExpenseTracker none). The damaged-branch state of this grader remains proved by `REPOS-036` and `REPOS-037` only.

### Phase 2 review follow-ups (`ai-code-review-phase2.md`, APPROVE with follow-ups, no blocking finding)

- **F1 (a third state):** a project root git cannot open as a repository (no `.git`, or a `safe.directory` refusal) now gives `ERROR ... (git rev-parse of origin/main failed with exit 128)` where it gave `UNGRADED`;
  the flow-down note names it, and says the `git fsck` hint does not fit it.
- **F2 (`scope-check-repos.ps1` on adopted projects):** measured in place on the real projects, byte-identical before and after (the table above); the note says what was and was not exercised.
- **F3 (GAP-041):** recorded at the owner's instruction (anas.m, 2026-10-17: "record GAP-041 and start phase 2"); the roadmap entry now says so.
- **F4 to F7 (wording):** the repository lines are described as the same sentences worded for a repository; `RESULT UNGRADED` with exit 0 is named as what CI counted as passing; the open list of the decisions log names T010 and the phase 2 review;
  the phantom `-Json` flag is removed from the note. Phase 1's superseded T002(c) and T006 text in this file stays as history, flagged as superseded.
### T010 Final run on an isolated checkout of `7a96899`, and the CI result of phase 1

A detached `git worktree` of the phase 2 change commit outside the repository, removed afterwards.

| Measure | Result |
|---|---|
| full harness (`tests/enforcement/Run-Tests.ps1`) | **1859 passed, 0 failed, exit 0** (the parent's 1838 plus the 21 of phase 1: `SCOPE-031`, `SCOPE-032`, `REPOS-036`, `REPOS-037` and the three `commitGraph` self-tests; phase 2 adds no test) |
| coverage | 7 rules exempt from a fixture pair (unchanged); no unowned site |
| `ritual-checks.ps1 -Branch 034-scope-check-unchecked-reads` in that checkout | `RESULT OK` |
| `scope-check.ps1 -Commit` | PASS on `987563a` (21 files), `c565660` (15), `7a96899` (4) and `e1ad134` (4) |
| CI, `enforcement-tests` on the pushed phase 1 commits `987563a` and `336c410` | **success on `ubuntu-latest` and on `windows-latest`** for both: the second git. The fixtures that pin `git merge-base failed with exit 128` and the `commitGraph` fixtures pass on Linux (review finding F7 of phase 1, T002(d)) |

The 1859 is measured at the phase 2 change commit and carries to the tip (the later commits touch only this file, `adoption/updating.md`, `docs/roadmap.md` and the review files). The CI runs of the latest commits were still in
progress when this was written. Open, and not claimed here: the owner's gate run on phase 2, the human review at merge.
