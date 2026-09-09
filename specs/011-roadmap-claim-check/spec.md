# Micro Spec: Roadmap-claim visibility check

**Feature Branch**: `011-roadmap-claim-check`
**Created**: 2026-09-09
**Status**: Approved (owner, 2026-09-09)
**Delivery Level**: Micro
**Gate Certification**: ci-held

## Intent

Close GAP-017: a paused or in-flight feature branch makes `main`'s roadmap lie, and
nothing checks it. In the first post-010 field use, a feature sat 13 days on an unmerged
branch with an approved spec and a gated phase while `main`'s roadmap row still read
`idea` — an agent orienting from `main` would have re-specced it.

The fix is the first shape recorded in the roadmap row: a new ritual-checks member,
`roadmap-claims`, asserts that every `NNN-*` branch on origin (the claim ledger, same
regex `claim-feature.ps1` uses) has a matching row in the roadmap table of
`docs/roadmap.md` whose Status is not `idea`. The row flip therefore becomes part of the
claim ritual — it lands main-side at claim time instead of hiding on the feature branch
until merge. `claim-feature.ps1` prints that reminder after each successful claim, and
the check's failure message states the remedy, so the rule teaches itself at the moment
it fires. The branch currently being checked is exempt for its own number, so a fresh
claim's first CI run cannot deadlock on itself. No remote (or an unreachable one) means
`n/a`, mirroring verify-kit's semantics — never a synthetic failure. Cell parsing counts
only unescaped pipes (the GAP-015 lesson).

## Acceptance checks

1. `pwsh -File scripts/ritual-checks.ps1` runs a `roadmap-claims` member; on a tree where
   every remote `NNN-*` claim has a roadmap-table row containing `NNN-name` with Status
   not `idea`, it prints OK and the aggregate RESULT stays OK.
2. A remote claim whose row is missing, or still reads `idea`, fails the member with a
   message naming the branch and the remedy (flip the row — Status, Owner, Spec path — in
   a main-side docs commit at claim time).
3. When the current branch is itself `NNN-name`, that number is exempt: a freshly claimed
   branch's first CI run does not fail on its own not-yet-flipped row.
4. With no `origin` remote or `git ls-remote` unreachable, the member reports `n/a` and
   does not fail the run.
5. `scripts/claim-feature.ps1` prints the flip reminder after a successful claim (and in
   its `-Json` output stays silent, as with its other Write-Info messages).
6. The kit's own roadmap row for this feature is flipped (`in progress`, owner, spec
   path), so the merged tree satisfies its own check.

## Eligibility checklist *(all boxes MUST be checkable — one unchecked box means this is not a Micro feature)*

- [x] No schema change or migration
- [x] No new packages or dependencies
- [x] No architecture change
- [x] No domain-invariant surface (constitution V)
- [x] No UI with visual references (`screenshots/`)

**Territory**:

- `scripts/roadmap-claim-check.ps1`
- `scripts/ritual-checks.ps1`
- `scripts/claim-feature.ps1`
- `docs/roadmap.md`

## Rollback

Revert the single phase commit (`git revert <sha>`).
