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
