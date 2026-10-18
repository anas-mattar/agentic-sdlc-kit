# Data Model: Reviewer choice and pull-time fit

No stored data beyond git refs and two existing declarations. These are the shapes the checks read.

## Review claim

A remote ref and the commit it points at.

| Field | Source | Rule |
|---|---|---|
| Feature | ref path `review/<feature>/...` | an `NNN-name` that exists on `origin` |
| Slug | last ref path segment | the slug of a roster name: lower-case `[a-z0-9._-]` |
| Sha | the ref's tip | a commit whose parent is the feature tip at claim time |
| AuthorName, AuthorEmail | the commit | read by `git log`; unreadable makes the reading `Failed` |

The slug of a name: trim, lower-case, every character outside `[a-z0-9._-]` becomes `-`, runs collapse, leading
and trailing `-` and `.` are removed. Two roster entries with one slug are ambiguous and unusable for claims.

A claim **counts** for a Reviewer when: its slug is the slug of the Reviewer's roster entry; it is not the slug of
the Owner; and its commit author (name, or the part of the email before `@`, slugged) is not the Owner's slug.
It carries no date; staleness is guidance, not a reading.

## Reading result (`Get-ReviewClaims`)

| Field | Meaning |
|---|---|
| Failed | true when the ledger, or a claim's author, could not be read |
| Cause | one clause naming why, when Failed |
| Claims | zero or more claims, only meaningful when not Failed |

## Roster entry (unchanged, feature 021)

`{ name, repos?, canApproveCritical? }` or a bare name. `repos` gains its one reader (`Get-RepoFit`).

## Roadmap row repositories

An optional `Repos` column of the roadmap table: names separated by commas, in the names `codeRepos` uses; empty or
an em dash declares nothing; a table without the column declares nothing.

## Fit result (`Get-RepoFit`)

| Result | When | Printed |
|---|---|---|
| Match | every declared repository is in the claimant's `repos` | nothing |
| Partial | at least one is not | one note: row, uncovered repositories, who covers them (or "no one declared it") |
| NoDeclaration | row declares none, or claimant has no `repos`, or no roster | nothing |
| Unplaced | the claimant is not a roster name | one line: cannot tell who is claiming, the strings compared |
| not read | row not found or ambiguous, no `Repos` column, roadmap unreadable | one line naming why |

State transitions: none. A claim exists or does not; a fit is computed and printed once.
