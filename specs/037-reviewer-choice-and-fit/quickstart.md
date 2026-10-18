# Quickstart: Reviewer choice and pull-time fit

How to see each behaviour working once built. Run in a clone whose roster has two developers (`ada`, `grace`) and
a Critical feature `007-payments` owned by `ada`.

## Pull a review (US1)

```powershell
pwsh -File scripts/claim-review.ps1 -Feature 007-payments -As grace
git ls-remote --heads origin "refs/heads/review/007-payments/*"
```

Expect one ref, `review/007-payments/grace`. A second run prints "already claimed" and exits 0.

## The check reads it (US1)

```powershell
pwsh -File scripts/enforcement-pack.ps1
```

With `human-pr-review.md` naming `grace` as Reviewer and the claim present, the claim adds nothing. Delete the
claim ref (`git push origin --delete review/007-payments/grace`) and the check fails naming the Reviewer and
`scripts/claim-review.ps1`. With no review file and no claim, the "missing" failure says the review is unclaimed.
A claim by `ada` (the Owner) does not count.

## The fit note (US2)

With a roadmap `Repos` column and `ada` declared with `repos: ["api"]`:

```powershell
pwsh -File scripts/claim-feature.ps1 -ShortName web-checkout -Row "Checkout page" -As ada "Checkout page"
```

If the row declares `web`, one `Fit` note names the row, `web` and who covers it, and the claim goes ahead. Without
`-Row`, or with no roster, the output is unchanged.
