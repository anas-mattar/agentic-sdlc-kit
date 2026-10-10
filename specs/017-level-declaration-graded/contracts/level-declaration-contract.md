# Contract: Level Declaration

**Feature**: `017-level-declaration-graded` | **Date**: 2026-10-11

The interfaces this feature adds: one adoption-record key, three spec blocks, and the lines
`scripts/enforcement-pack.ps1` and the doctor print. Messages are quoted by anchor, because the
enforcement harness (feature 015) pins each rule to the text it emits.

## 1. Adoption record

```json
{
  "criticalSurfaces": ["src/auth/", "api/Payments/**", "migrations/"]
}
```

- Optional. Entries are governance-root-relative paths or globs; in a multi-repo project they
  are repo-prefixed, the way Territory is (feature 012).
- A trailing slash means the whole subtree, as in Territory.
- Not prompted for by `scripts/init-kit.ps1`: an adopter writes it when they know their
  surfaces. An absent key changes no verdict.

## 2. Spec blocks

Level Rationale (on a spec carrying `**Rationale Rule**: 1`):

```text
## Level Rationale

- **domain-invariants**: does not apply — <reason>
- **irreversible-data**: does not apply — <reason>
- **authn-authz-payment**: does not apply — <reason>
- **auditable-evidence**: does not apply — <reason>
```

Critical with every trigger answered `does not apply`: add `**Critical because**: <reason>`.

Surface Exception:

```text
**Surface Exception**: `src/auth/README.md` — documentation only, no behaviour
**Exception approved by**: <name>, <YYYY-MM-DD>
```

## 3. Check output

All lines are emitted by `scripts/enforcement-pack.ps1` on `NNN-*` branches.

| Rule | Where | Anchor text (stable) |
|---|---|---|
| LEVEL-001 | failure | `LevelSurface: <feature> is declared <level> but its Territory reaches critical surface` |
| LEVEL-002 | info | `LevelSurface: not armed` |
| LEVEL-003 | UNGRADED | `LevelSurface: criticalSurfaces in kit-adoption.json is unusable` |
| LEVEL-004 | UNGRADED | `LevelSurface: no readable Territory` |
| LEVEL-005 | info | `LevelSurface: exception live` |
| LEVEL-006 | info | `LevelSurface: exception stale` |
| LEVEL-007 | failure | `LevelSurface: exception not counted` |
| LEVEL-008 | failure | `LevelRationale: <feature> spec.md has no Level Rationale` |
| LEVEL-009 | failure | `LevelRationale: <feature> spec.md leaves trigger` |
| LEVEL-010 | failure | `LevelRationale: <feature> spec.md contradicts its level` |

A LEVEL-001 failure names the feature, level, Territory path and matched glob, then the three
ways forward: promote to Critical, narrow the Territory, or record a Surface Exception.

The rule ids above are the plan's working numbering. The harness's `rules.json` is the
authoritative index once phase 3 lands.

## 4. Doctor

`scripts/verify-kit.ps1` prints, from the same reader the check uses:

- `criticalSurfaces: N declared` (informational) or `criticalSurfaces: not declared`
  (informational, never a failure);
- one finding per problem the reader reports, with its fix.

## 5. What does not change

The Lite lane and its abuse guard, the Micro floor, `CriticalEvidence`, `GateBatching`,
`GateCertification`, `ReviewProvenance`, `AmendmentAuthority` and the exit code of any run
whose record declares no surfaces.
