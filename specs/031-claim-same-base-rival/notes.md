# Notes: claim-feature.ps1 tells a same-base rival from our own claim

Evidence for feature 031 (GAP-037). Nothing here is law; `spec.md`, `plan.md` and `tasks.md` are.

## Pre-spec measurement (2026-10-16)

Measured on a throwaway bare `origin` cloned from `main` at `7d933f4` (the merge of PR #96), with two or three working
clones of it, outside the repository. Nothing of the real project was pushed.

| Question | Measured |
|---|---|
| Does a claim commit anything? | No. After `claim-feature.ps1 -NoPush` the new branch tip equals `main`'s sha (`7d933f4`) and `specs/NNN-name/` is untracked. |
| What does a second push of the same name and sha do? | Claimant B fetched, claimant A claimed and pushed `031-same-name`, then B ran `git push -u origin 031-same-name`: `Everything up-to-date`, exit 0. |
| What does the script conclude? | With a `git` shim ahead of the real one on `PATH` that made a rival push `031-same-name` just before the script's own push, the script printed `CLAIMED: 031-same-name (pushed to origin - the claim is live)` and exited 0, with no warning. `origin` held one branch at `main`'s sha. |

Why the script misses it: the rival filter is `$_ -ne $branch` (`scripts/claim-feature.ps1:155`), so a same-name branch is never a
rival, and the push exited 0, so the feature 030 commit comparison (`:162-165`, which runs only after a non-zero push) is never
consulted. Both claimants hold `031-same-name` at one sha.

Not measured here: the `--force-with-lease=<ref>:` push, a claim commit carrying the claimant, and the harness recipe field
that plants a same-name, same-sha branch. They are the plan's first tasks, before any change to the script.

## Plan-time measurement of decision D1 B (2026-10-16, git 2.55.0.windows.5)

Same throwaway `origin` (a bare repository outside the project), the same-name, same-sha race, three pushes of the same
branch from two clones.

| Push | Output | Exit |
|---|---|---|
| `git push --force-with-lease=refs/heads/<name>: -u origin <name>`, no rival | `[new branch]` | 0 |
| the same command from a second clone, a rival's same-name, same-sha branch already on `origin` | `Everything up-to-date` | **0** |
| the same command again, the rival's ref now fetched locally | `Everything up-to-date` | **0** |
| `git push --porcelain -u origin <name>`, no rival | `*  refs/heads/<name>:refs/heads/<name>  [new branch]` | 0 |
| the same command from a second clone, same name and sha already on `origin` | `=  refs/heads/<name>:refs/heads/<name>  [up to date]` | 0 |

**D1 B does not work as written.** A push whose sha already equals the remote's is short-circuited by git as up to date before
any lease is consulted, so the lease cannot refuse the one case this feature exists for. The lease is only useful against a
rival at a different sha, which feature 030 already handles.

What does separate the two claimants is the push's own status: only the claimant that creates the ref sees `[new branch]`
(porcelain `*`); the other sees `[up to date]` (porcelain `=`). A script-only variant of B's intent (git decides, the claim
stays uncommitted) is therefore to read `git push --porcelain` and treat `=` for our own new branch as "the name already
existed", that is, a rival. This is not yet in the spec: D1 as approved names the lease.

### The rejected-push text under `--porcelain` (2026-10-16, git 2.55.0.windows.5)

A bare `origin` whose `pre-receive` hook exits 1, one push of a new branch:

| | stdout | stderr |
|---|---|---|
| `git push -u origin <b>` | `To <url>` and ` ! [remote rejected] <b> -> <b> (pre-receive hook declined)` are on stderr with the rest | `remote: denied by hook`, `To <url>`, ` ! [remote rejected] <b> -> <b> (pre-receive hook declined)`, `error: failed to push some refs to '<url>'` |
| `git push --porcelain -u origin <b>` | `To <url>`, `!<TAB>refs/heads/<b>:refs/heads/<b><TAB>[remote rejected] (pre-receive hook declined)`, `Done` | `remote: denied by hook`, `error: failed to push some refs to '<url>'` |

So `--porcelain` changes the layout of the git text quoted in feature 030's rejected-push refusal (plan P6). The stub
`create-new-feature.ps1` of `CLF-017` already plants a same-name branch on `origin` at `main`'s sha (`git -C origin.git branch $b main`),
after the ledger read and before the push, which is the race window; plan P7 uses it instead of a new harness recipe field.

## Phase 1: tell a same-base rival from our own claim

### T001 Baseline on the parent commit (`53a04eb`)

Four states run as `pwsh -File scripts/claim-feature.ps1 -ShortName probe "a probe"` in purpose-built repositories (a stub
`create-new-feature.ps1`, a bare `origin` cloned from the repository's own commit, paths normalised to `<REPO>`): no origin,
an origin that takes the push, `-NoPush`, and one genuine renumbering (the stub pushes `001-other` to origin before the
script's push). The saved text of each is the byte comparison of T007.

### T002 Probe of `git push --porcelain` (git 2.55.0.windows.5; the CI image's git is the second probe, in T007)

| Push | Status line (stdout) | Exit |
|---|---|---|
| creates the ref | `*<TAB>refs/heads/<b>:refs/heads/<b><TAB>[new branch]` | 0 |
| ref already on origin at our sha | `=<TAB>refs/heads/<b>:refs/heads/<b><TAB>[up to date]` | 0 |
| rejected by a `pre-receive` hook | `!<TAB>refs/heads/<b>:refs/heads/<b><TAB>[remote rejected] (pre-receive hook declined)` | 1 |
| `receive-pack` exits 1 after landing (feature 030's wrapper) | `*<TAB>...<TAB>[new branch]` | 1 |
| the same sha pushed again after that | `=<TAB>...<TAB>[up to date]`, plus `error: failed to push some refs` | 1 |

- A landed push that exits non-zero reads `*` and not `=`, so the same-name test (exit 0 and `=`) never fires for it and
  feature 030's landed-by-commit rule keeps that state.
- `git branch --unset-upstream <b>` on a branch with no upstream exits **128** (`fatal: branch '<b>' has no upstream
  information`): the script discards its output and does not read the exit code (plan P3).
- stdout and stderr of a push arrive in no fixed order through `2>&1`; the script groups the error records first and the
  status lines after, so the text quoted in a refusal is the same each run.

### T003 Fixtures written first, shown failing on the parent

`CLF-018/fail` and `CLF-018/pass`. On the parent commit (`scripts/claim-feature.ps1` unchanged) the `pass` passes and the
`fail` fails for the stated reason: first diff at line 2, expected the same-short-name warning, observed
`CLAIMED: 001-probe (pushed to origin - the claim is live)`. The rejected-push text is quoted in two existing cases:
`CLF-017/fail` (re-expected, T006) and `CLF-015/fail` (it quotes only the `error:`, `fatal:` and `remote:` lines, so it did not move).

**Deviation from the plan, approved by the owner (anas.m, 2026-10-16) and recorded as an amendment of plan P5 and tasks T003/T004: `CLF-019` is not built.** The plan lists a fixture in which
the rival is planted at every attempt so the claim ends in `Lost the allocation race 3 times`. The stub
`create-new-feature.ps1` runs once per claim, before the first push, so it can plant the first number only; a planted branch
for a later number is visible to the ledger read and the allocation skips it; and nothing on the server side can plant the
name of the branch being pushed before the push's advertisement (the name is not known until the client sends it). The loop
that ends in the three-times refusal is the existing one that `CLF-007` covers with a numeric rival at every attempt, and
this feature does not change it. `CLF-018/fail` already proves the new state, including that nothing is withdrawn (origin
refuses deletions in both directions, so an attempted withdrawal of the foreign branch would end the claim with the
could-not-withdraw refusal instead of the renumbered success).

### T005 and T006 The script and the one re-expected case

`scripts/claim-feature.ps1`: `git push --porcelain -u origin <b>`; `$sameName` is true when the push exited 0 and a status line
is `=` for our own ref; `$landed` is `$pushOk -and -not $sameName` and feature 030's landed-by-commit read is skipped for it;
the refusal for a rejected push without a rival is skipped for it; the warning names the other claimant, `git branch
--unset-upstream` drops the upstream `-u` pointed at their branch, and the next steps are the loop's own (no withdrawal, the
`$gone` text says the branch is theirs). Four states printed the same text before and after (saved text compared with `diff -r`).

Re-expected by hand: `CLF-017/fail` only. Its refusal quotes git's rejected-push text; under `--porcelain` that text is
`error: failed to push some refs to '<ROOT>/origin.git'`, `To <ROOT>/origin.git`, the tab-separated `!` status line and `Done`,
in that order, where it was the human `To`, ` ! [rejected]` and `error:` lines. The script's own sentences did not change.

### T007 Numbers (isolated detached worktrees outside the repository; the changed files copied into the second)

| | Parent `53a04eb` | Phase 1 working tree (code as committed) |
|---|---|---|
| full harness | 1805 passed, 0 failed | **1809 passed, 0 failed** (the 4 more are the two cases of `CLF-018`) |
| `claim-feature.ps1` coverage | 15 of 18 sites fixtured (3 not a rule) | 16 of 19 sites fixtured (3 not a rule) |
| `-Case CLF-` | not run on its own (inside the full run) | 159 passed, 0 failed |
| four claim states, saved text | saved | `diff -r` against the parent: byte-identical |
| `ritual-checks.ps1` (exit code) | n/a | EXIT 0: `doc-lint`, `enforcement-pack`, `digests`, `roadmap-claims` OK; `scope-check` UNGRADED until this commit exists |

Every pre-existing case passed unchanged except `CLF-017/fail`, re-expected by hand (T006). The coverage report lists no unowned
site in `claim-feature.ps1`; the exempt count is the baseline's (6 rules). The second probe of `--porcelain` on the CI image's git
is the CI run of this branch. The measurement of the same-base race through the shim, and on clones of the adopted projects, is
phase 2 (T010).

## Phase 2: guidance, close and measurement

### T010 The measurement (plan P8, SC-001, SC-002)

Method (the one of feature 030): for each project a `git clone` from its local directory into a scratch area (the real projects never
touched) and a **bare copy** of the clone's own tree as its `origin`, so a claim with a push could be run. The kit before this
feature (`7d933f4`) applied with `update-kit.ps1`, `build-digests.ps1` run and committed ("measure: kit before"); the kit as it
stands (`38da677`, whose `scripts/claim-feature.ps1` is the phase 1 file) applied the same way ("measure: kit now"). Probes in each
state on a fresh copy of the committed clone and its origin: a successful claim with `-NoPush`; one with a push; **the race**, in
which a `git` shim first on `PATH` pushes the claim's own branch (same name, same commit) to `origin` just before the script's
push; `doc-lint.ps1`; `ritual-checks.ps1 -Branch main`.

| Probe | FitForge, FlowBoard, ExpenseTracker |
|---|---|
| `-NoPush` claim; claim with a push | exit 0; **byte-identical before and after** in all three |
| `doc-lint.ps1` | exit 0; **byte-identical before and after** |
| `ritual-checks.ps1 -Branch main` | `RESULT OK`, exit 0, in every state; **two lines moved, and only two:** the enforcement-pack diff base commit (each clone's own commit) and `verify-kit`'s recorded kit commit (`7d933f4...` to `38da677...`) |
| the race, before | exit 0, `CLAIMED: <n>-probe (pushed to origin — the claim is live)`, one branch on `origin` |
| the race, now | exit 0, `WARNING: Number <n> was claimed concurrently by a claimant of the same short name (<n>-probe was already on origin; it is theirs and is left alone) — renumbering.`, `Renumbered: <n>-probe -> <n+1>-probe`, `CLAIMED: <n+1>-probe`, **both branches on `origin`** (`002`/`003`, `010`/`011`, `004`/`005`) |

The real projects were checked afterwards: no `probe` branch in any of them, and the same working-tree state as before
(FitForge: one untracked file; FlowBoard: two; ExpenseTracker: none). Not exercised: a push that exits non-zero beside a simultaneous
create (stated limit 1 of the flow-down note), anything run through a wrapper that starts the script as a child process, the Linux
platform (the CI run of the branch), and a real remote's hooks. The measured throwaway-`origin` race of "Pre-spec measurement"
above is the same state as the shim's, now printing the warning and renumbering instead of `CLAIMED:`.

### T008 and T009 Guidance and close

`adoption/updating.md`: a flow-down note in the shape of feature 030's, with no digest marker (the adoption digest is at its
40-bullet bound; `build-digests.ps1 -Check` is OK, 5 digests, 119 markers, so nothing regenerates). It states the limit of review
finding F2 and the one text that moved (the git lines quoted in a rejected-push refusal). `docs/roadmap.md`: GAP-037's status text,
a decisions-log entry, and the row `shipped`. Note for the merge: PR #97 flips the same row from `idea` to `in progress`; it merges
first and the row here then conflicts on one line, resolved by taking `shipped`.

### Phase 2 review follow-ups (`ai-code-review-phase2.md`, APPROVE with follow-ups, no blocking finding)

- **F1 to F4 (wording), fixed in the follow-up commit:** the roadmap entry now records the open simultaneous-create limit, the
  pending gate, human review and Linux CI run, and says the 1809 was measured on a detached worktree of the parent with the
  changed files copied in; the flow-down note says a third consecutive same-name loss ends in `Lost the allocation race 3 times`
  (claim again), qualifies "each refusal prints what it printed before" and "nothing, byte for byte" against the moved git text,
  quotes the `; so did <rivals>` form of the warning, and says it supersedes, for a push that exits 0, feature 030's sentence that
  two claimants from the same `main` tip "behave as they always did".
- **F5 (re-check), done:** a clone of FitForge, the kit as it stands (with the new section) applied by `update-kit.ps1`,
  `build-digests.ps1` run and committed: the section is in the clone's `adoption/updating.md`, `doc-lint.ps1` exit 0 (`OK`),
  `ritual-checks.ps1 -Branch main` `RESULT OK`, `verify-kit` OK.
- **F6:** the Linux CI run is the second git; it is not confirmed here and must be green before merge.
- Two phase 2 commits therefore exist: `c91472e` (the change) and the follow-up. The full harness runs on `c91472e`; the
  follow-up touches only `adoption/updating.md`, `docs/roadmap.md` and this file, so its count carries, and `scope-check.ps1`
  is run on both.

### T011 Final run on an isolated checkout of `c91472e`

A detached `git worktree` of the phase 2 change commit outside the repository, removed afterwards.

| Measure | Result |
|---|---|
| full harness (`tests/enforcement/Run-Tests.ps1`) | **1809 passed, 0 failed, exit 0** (the parent's 1805 plus the 4 cases of `CLF-018`) |
| `claim-feature.ps1` coverage | 16 of 19 sites fixtured (3 not a rule), no unowned site |
| `ritual-checks.ps1 -Branch 031-claim-same-base-rival` in that checkout | `RESULT OK` (`doc-lint`, `enforcement-pack`, `scope-check`, `digests`, `roadmap-claims` OK) |
| `scope-check.ps1 -Commit` | PASS on `894f101` (11 files), `c91472e` (4 files) and `5097ee6` (3 files) |

The review follow-up commit `5097ee6` and the review commit `40c7e5e` touch only `adoption/updating.md`, `docs/roadmap.md` and this
feature's own files, so the count carries to them; their `ritual-checks` is `RESULT OK`. Open, and not claimed here: the owner's gate
run, the human review at merge, and the CI run on the Linux runner (the second git).
