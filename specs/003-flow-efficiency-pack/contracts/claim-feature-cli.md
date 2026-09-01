# CLI Contract: `scripts/claim-feature.ps1`

One-command feature claim: remote-aware number allocation, branch + spec creation
(delegated to the stock Spec Kit script), immediate push, race recovery.

## Invocation

```powershell
pwsh -File scripts/claim-feature.ps1 -ShortName <kebab-slug> [-Json] [-NoPush] "<feature description>"
```

| Parameter | Required | Meaning |
|---|---|---|
| `-ShortName` | yes | 2–4 word kebab-case slug for the branch/spec directory |
| feature description | yes | positional; recorded in spec.md's Input field |
| `-Json` | no | machine-readable output (same convention as the stock scripts) |
| `-NoPush` | no | allocate and create but skip the push (explicitly opts out of team visibility; prints the same warning as the no-remote case) |

## Behavior

1. **Preflight**: working tree clean AND current branch is `main`, else exit 1 with the
   reason. (Mirrors CLAUDE.md workflow step 1.)
2. **Sync**: `git fetch origin`. No remote configured → local allocation, skip push,
   warn `claim is not team-visible` (exit 0).
3. **Allocate**: next number free across local branches, remote branches
   (`git ls-remote --heads origin`), and `specs/` directories.
4. **Create**: delegate to `.specify/scripts/powershell/create-new-feature.ps1
   -Number <n> -ShortName <slug> -Json <description>` — branch, spec directory, and
   template copy are owned by the stock script.
5. **Claim**: `git push -u origin <branch>`.
6. **Race recovery**: if the push is rejected because the number is taken, rename the
   branch and spec directory to the next free number and push again (max 3 attempts,
   then exit 1 instructing manual renumber).

## Output

Human mode: progress lines + final `CLAIMED: <branch>` (or warning variant).
`-Json` mode: `{"BRANCH_NAME", "SPEC_FILE", "FEATURE_NUM", "PUSHED": true|false,
"RENUMBERED_FROM": null|"NNN"}`.

## Exit codes

| Code | Meaning |
|---|---|
| 0 | claimed (pushed, or local-only with explicit warning) |
| 1 | preflight failure, git error, or race unrecoverable after 3 attempts |

## Non-goals

Does not write a roadmap row (that is the owner's first commit, team-workflow rule 3);
does not choose the feature or its reviewer; never force-pushes; never deletes branches.
