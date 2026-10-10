# Quickstart: Cross-repo Territory Reach

**Feature**: `018-cross-repo-territory-reach` | **Date**: 2026-10-11

How to see each behaviour once it is built. Run from the governance repository root.

## 1. See an overlap in a code repository

In a project whose `kit-adoption.json` declares `"codeRepos": ["api"]`, with two feature branches
that each commit the same file inside `api/`:

```text
pwsh -File scripts/territory-check.ps1
```

Expect an `OVERLAP with <other> [live]:` block listing the file as `api/<path>`, and exit code 2.

## 2. See a comparison that was not made

Rename the `api` directory (or point its `origin` at nothing). Run again. Expect an
`UNGRADED: api: ...` line naming the cause and a final `UNGRADED - ...` verdict, exit 0, and no
`CLEAN` anywhere in the output.

## 3. See a clean, fully compared run

Restore the repository and make the two features touch different files. Expect a `CLEAN` line that
names the repositories it compared and how many open claims.

## 4. See that a project without code repositories is unchanged

Remove `codeRepos` from the record. Expect the original `CLEAN` line and nothing new.

## 5. Prove it

```text
pwsh -File tests/enforcement/Run-Tests.ps1 -Case TERR-
pwsh -File tests/enforcement/Run-Tests.ps1 -Case REPOS-
pwsh -File scripts/ritual-checks.ps1
```

`REPOS-` is the guard that extracting the shared readers changed nothing for the scope check.
