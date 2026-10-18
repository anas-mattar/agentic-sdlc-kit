# Contract: `scripts/claim-review.ps1`

```text
pwsh -File scripts/claim-review.ps1 -Feature <NNN-name> [-As <roster name>] [-Json]
```

| Input | Meaning |
|---|---|
| `-Feature` | the feature whose review is being taken; must be a branch on `origin` |
| `-As` | the reviewer, a roster name; default the git `user.name` |
| `-Json` | print `{ FEATURE, REVIEWER, REF, ALREADY }` instead of text |

**Success** (exit 0): the ref `refs/heads/review/<feature>/<slug>` exists on `origin` and the output names it; if
it already existed, the output says `already claimed` and nothing is pushed.

**Refusals** (message on the error stream, exit 1, through `Stop-Refused`; each has a fixture):

1. not inside a git repository
2. no `origin` remote
3. `origin` cannot be reached or its ledger cannot be read
4. `-Feature` is not on `origin`
5. no team roster declared (fewer than two developers: the solo arm uses no claim)
6. `-As` is not on the roster, or two roster entries slug alike
7. `-As` is a developer whose entry has `canApproveCritical` not true
8. the push was rejected

The script never selects, ranks or proposes a reviewer and does not compare the claimant with the Owner (the check
does, at grading time).
