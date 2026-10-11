# Data Model: Cross-repo Territory Reach

**Feature**: `018-cross-repo-territory-reach` | **Date**: 2026-10-11

No database. These are the values the check reads and produces in one run.

## Declared code repositories (read)

Source: `kit-adoption.json`, key `codeRepos`, read by `Get-CodeRepos` (feature 012's reader,
extracted into `scripts/adoption-lib.ps1`).

| State | Meaning | Territory check |
|---|---|---|
| absent, or an empty array | the project declares no code repositories | unchanged: governance repository alone, existing output |
| usable | an array of plain directory names (no path, no traversal, no drive) | each is compared |
| present but unusable | not an array, or a non-array entry, or an entry that is a path | UNGRADED by name (research R6), governance compared as before |

Reader result: `Repos` (the usable names, in order) and `Warnings` (the messages the scope check
prints today, without its prefix) and `Unusable` (true when a declaration was present and could not be
read in full).

## Comparison

One comparison is one repository read for one party. The check makes, for each declared code
repository, one for the branch under check and one for each open claim; and the governance repository
for each open claim. Each ends in exactly one of:

| Outcome | Meaning | Contributes |
|---|---|---|
| compared, no shared file | a definitive answer | nothing |
| compared, shared files | an overlap | files, repo-prefixed |
| no work there | the party has no branch in this repository | nothing (definitive) |
| not made | a named cause | one UNGRADED entry |

## Causes of a comparison not made

| Cause key | Scope | Meaning |
|---|---|---|
| `not-present` | a repository | the declared directory does not exist here |
| `not-a-repository` | a repository | it exists but is not the root of a git repository of its own |
| `no-trunk` | a repository | none of the trunk candidates exists in it |
| `fetch-failed` | a repository | `git fetch origin` failed |
| `branch-uncomparable` | a repository and a feature | a ref exists but has no merge base with the trunk, or its diff cannot be computed |
| `claim-skipped` | the governance repository and a feature | an open claim with no remote-tracking ref (GAP-029's case) |
| `declaration-unusable` | the run | `codeRepos` is present and cannot be read in full |

## Overlap record

| Field | Meaning |
|---|---|
| `branch` | the other feature's governance branch |
| `status` | `live`, `stale - reclaimable`, or `claimed, no work yet` |
| `files` | every shared file, governance paths as today and code paths prefixed with the repository directory name |

Status is taken from the latest commit across every repository the feature has a branch in.

## Verdict

| Condition | Verdict | Exit |
|---|---|---|
| a live overlap exists | `OVERLAP` (with the ungraded lines beside it, if any) | 2 |
| otherwise, any comparison not made | `UNGRADED` | 0 |
| otherwise | `CLEAN` | 0 |

A governance repository with no remote is none of these: it prints its existing line and exits 0
before any comparison is attempted (research R5).

## JSON shape

Existing: `BRANCH`, `CLEAN`, `OVERLAPS`. `CLEAN` is false whenever anything was not compared. New:
`UNGRADED`, a list of `{ repo, feature, cause, detail }`, empty when everything was compared.
