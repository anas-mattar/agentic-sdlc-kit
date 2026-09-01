# CLI Contract: `scripts/territory-check.ps1`

One-command territory check: compares the current feature's touched files against every
open remote feature branch and reports overlap. Automates team-workflow rule 5; the
stance stays *sequenced, not forbidden*.

## Invocation

```powershell
pwsh -File scripts/territory-check.ps1 [-Branch <name>] [-BaseBranch main] [-StaleDays 14] [-Json]
```

| Parameter | Required | Meaning |
|---|---|---|
| `-Branch` | no | feature branch to check (default: current branch; must match `NNN-*`) |
| `-BaseBranch` | no | merge base (default `main`) |
| `-StaleDays` | no | reclaim window for stale-claim flagging (default 14, matching team-workflow rule 3) |
| `-Json` | no | machine-readable output |

## Behavior

1. `git fetch origin`; enumerate open remote `NNN-*` branches other than the one under
   check. No remote → exit 0 with `no remote — nothing to check against`.
2. Current feature's touched set: `git diff --name-only <base>...HEAD` ∪ tracked
   uncommitted changes.
3. Per other branch: `git diff --name-only <base>...origin/<branch>`; intersect.
4. Classify each overlapping branch: `live`, `stale — reclaimable` (last commit older
   than `-StaleDays`), or `claimed, no work yet` (no commits beyond base — never an
   error, even with no plan.md).
5. Report overlapping files per branch; on any live overlap, print the rule-5 reminder:
   agree merge order with that owner and record it in both features' plan.md.

## Output

Human mode: one block per conflicting branch (status + files), or `CLEAN`.
`-Json` mode: `{"BRANCH", "CLEAN": bool, "OVERLAPS": [{"branch", "status",
"files": []}]}`.

## Exit codes

| Code | Meaning |
|---|---|
| 0 | clean — no overlap with any open feature branch |
| 2 | overlap found (report printed; sequencing required, work not forbidden) |
| 1 | execution error (not a git repo, bad branch name, git failure) |

## Non-goals

Does not block or fail a build by itself (callers decide what exit 2 means for them);
does not parse plan.md prose; does not check `fix/`, `chore/`, `docs/` lanes.
