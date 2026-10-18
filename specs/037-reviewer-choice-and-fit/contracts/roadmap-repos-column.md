# Contract: the roadmap `Repos` column

An optional column named `Repos` in any roadmap table that already has `Status` and `Owner`.

- A cell is repository names separated by commas, trimmed, compared case-insensitively, in the names `codeRepos`
  in `kit-adoption.json` uses.
- An empty cell or an em dash declares nothing. A table with no `Repos` column declares nothing.
- The column is advisory input to the fit note only. No check reads it for a verdict, and
  `scripts/roadmap-claim-check.ps1` finds `Status` and `Owner` by header name, so the column changes none of its
  readings.
