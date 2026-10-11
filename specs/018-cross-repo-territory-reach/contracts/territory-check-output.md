# Contract: territory-check output and exit codes

**Feature**: `018-cross-repo-territory-reach` | **Date**: 2026-10-11

The interface this feature changes: what `scripts/territory-check.ps1` prints and returns. The
existing contract is `specs/003-flow-efficiency-pack/contracts/territory-check-cli.md`; this extends
it and changes nothing it does not name. The enforcement harness pins each line by anchor.

## Unchanged

Parameters (`-Branch`, `-BaseBranch`, `-StaleDays`, `-Json`), the refusal of a non-numbered branch, the
`no remote - nothing to check against` state, the `OVERLAP with <branch> [<status>]:` block, the
sequencing guidance, and the exit codes: 0 clean or stale-only or ungraded, 2 live overlap, 1 execution
error.

A project that declares no `codeRepos` sees the same text on a fully compared run:

```text
CLEAN — '<branch>' shares no files with any open feature branch.
```

## New lines

| Anchor | When |
|---|---|
| `UNGRADED: <repo>: not present in this checkout` | the declared directory does not exist |
| `UNGRADED: <repo>: not a repository of its own` | it exists but is not the root of its own git repository |
| `UNGRADED: <repo>: no resolvable trunk` | none of the trunk candidates exists; the candidates are named |
| `UNGRADED: <repo>: fetch failed` | `git fetch origin` failed in it |
| `UNGRADED: <repo>: cannot compare <feature>` | that feature's ref has no merge base, or its diff failed |
| `UNGRADED: governance: cannot compare <feature>` | an open claim with no remote-tracking ref |
| `UNGRADED: codeRepos: declaration unusable` | present and not readable in full |
| `compared <repo>: local branches only` | a code repository with no `origin` |

The verdict line when anything was not compared and nothing overlaps:

```text
UNGRADED — '<branch>' was NOT fully compared (<n> comparison(s) not made, listed above), so this is not a clean result.
```

The verdict line for a fully compared run in a project that declares code repositories:

```text
CLEAN — '<branch>' shares no files with any open feature branch (compared governance and <repo>[, <repo>...] against <n> open claim(s)).
```

The exact wording is fixed by the fixtures' hand-written expectations; this table fixes the anchors.

## Overlap lines

Code-repository files are listed in the same block as governance files, each with its repository
prefix, so a path can be pasted into a Territory block unchanged:

```text
OVERLAP with 004-other [live]:
  specs/shared.md
  api/src/Controllers/Orders.cs
```

## JSON

```text
{ "BRANCH": "...", "CLEAN": false, "OVERLAPS": [ { "branch": "...", "status": "live", "files": [ "api/src/A.cs" ] } ],
  "UNGRADED": [ { "repo": "web", "feature": "004-other", "cause": "branch-uncomparable", "detail": "..." } ] }
```

`CLEAN` is false whenever `UNGRADED` is non-empty. `UNGRADED` is always present, empty when everything
was compared.

## What does not change in exit codes

An ungraded run with no overlap exits 0. An overlap keeps exit 2 whether or not anything was ungraded.
