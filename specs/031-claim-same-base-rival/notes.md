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
