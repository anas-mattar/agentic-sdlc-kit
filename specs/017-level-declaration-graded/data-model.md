# Data Model: Level Declaration Graded

**Feature**: `017-level-declaration-graded` | **Date**: 2026-10-11

No database. These are the documents and records the check reads.

## Critical Surface list (adoption record)

Source: `kit-adoption.json`, optional key `criticalSurfaces`.

| Field | Type | Rule |
|---|---|---|
| `criticalSurfaces` | array of string | optional; absent means the path check is not armed |
| entry | string | non-empty after trimming; a path or glob, governance-root-relative, repo-prefixed in a multi-repo project (feature 012); no drive prefix, no `..` segment |

Reader result (one object, read by both the check and the doctor, the pattern feature 013 set
with `Get-DeveloperMode`):

| Field | Meaning |
|---|---|
| `Armed` | true only for a valid, non-empty list |
| `Globs` | the usable entries, trimmed, duplicates collapsed |
| `Declared` | whether the key exists at all |
| `Why` | one clause naming the state, for the caller's message |
| `Problems` | zero or more `@{ Message; Fix }` for the doctor |

States: *absent* (not armed, silent verdict), *empty* (not armed, an unfinished edit),
*malformed* (cannot run, UNGRADED), *valid* (armed).

## Level Rationale (spec.md)

A `## Level Rationale` section, present on specs carrying `**Rationale Rule**: 1`.

| Field | Rule |
|---|---|
| trigger key | exactly one of `domain-invariants`, `irreversible-data`, `authn-authz-payment`, `auditable-evidence`; all four required |
| verdict | `applies` or `does not apply` |
| reason | at least one word after the dash |
| `**Critical because**:` | required only on a Critical feature whose four verdicts are all `does not apply` |

Consistency rules: a Standard feature must have no `applies`; a Critical feature must have at
least one `applies` or a `**Critical because**:` line.

## Surface Exception (spec.md)

| Field | Rule |
|---|---|
| `**Surface Exception**:` | one backticked path plus a reason; the path must be a Territory entry to count as live |
| `**Exception approved by**:` | `<name>, <YYYY-MM-DD>`; validated like an amendment approver; an unfilled, placeholder or future-dated record is no record |

States: *live* (names a Territory entry that matches a surface, approved: suppresses that
path's failure and is listed), *unapproved* (does not suppress), *stale* (names no current
Territory entry: reported, never fails).

## Territory (read, not changed)

Per-phase block in `tasks.md` for Standard, the global block in `spec.md` for Micro
(`scripts/scope-lib.ps1`). The check takes the union across phases. A missing file, no block,
or a near-miss marker makes the feature UNGRADED for this check.

## Verdict contributions

| Condition | Contribution |
|---|---|
| armed, a sub-Critical Territory path intersects a surface, no live exception | failure |
| armed, graded, clean | nothing printed beyond the check's one-line summary |
| armed, Territory unreadable or absent | UNGRADED line |
| list malformed | UNGRADED line |
| list absent or empty | one informational line |
| live exception | a listed line, not a failure |
| stale exception | a reported line, not a failure |
| rationale absent, incomplete or contradictory (marker present) | failure |
| marker absent | nothing (grandfathered) |
