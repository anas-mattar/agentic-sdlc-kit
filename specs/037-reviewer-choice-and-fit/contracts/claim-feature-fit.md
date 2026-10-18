# Contract: `scripts/claim-feature.ps1 -Row -As`

```text
pwsh -File scripts/claim-feature.ps1 -ShortName <name> [-Row <fragment>] [-As <roster name>] "<description>"
```

With neither `-Row` nor `-As`, the script's output and exit codes are byte-identical to today's.

With `-Row`: the roadmap table in `docs/roadmap.md` is read; exactly one row whose first cell contains the
fragment (case-insensitive) is the row. Before the number is allocated, at most one line is printed, then the claim
proceeds unchanged:

| Situation | Line |
|---|---|
| every declared repository is in the claimant's `repos`; row declares none; claimant has no `repos`; no roster | none |
| a declared repository is not covered | `Fit: row '<row>' declares <repos>; <claimant> does not list <uncovered>; listed by: <names, or "no one declared it">` |
| `-As` or the git `user.name` is not a roster name | `Fit: not read - cannot tell who is claiming ('<strings compared>')` |
| no row, or several rows, match | `Fit: not read - <how many> roadmap rows match '<fragment>'` |
| the roadmap has no `Repos` column or cannot be read | `Fit: not read - <cause>` |

The note never changes the claim, the number allocated, any other output line or the exit code.
