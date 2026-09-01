# Data Model: Enforcement Pack

Not application data — this documents the check/config entities the script operates on and
the files each phase adds or edits, since this feature has no database or business entity.

## Entities

### Check

One named, independently-runnable unit inside `scripts/enforcement-pack.ps1`.

| Field | Description |
|---|---|
| Name | `Structure`, `LitePlusAbuse`, `CriticalEvidence`, `PhaseSizeWarning` |
| Applies to | Branch taxonomy pattern (`NNN-*`, `fix/*`/`chore/*`, `NNN-*` Critical only, `NNN-*`) |
| Blocking | `Structure`, `LitePlusAbuse`, `CriticalEvidence` block (non-zero exit); `PhaseSizeWarning` never blocks |
| Failure output | Human-readable line naming the offending file/artifact/branch (FR-011) |

### Config block

Single top-of-file (or `-ConfigPath`-loadable) set of overridable values, satisfying FR-007:

| Key | Default (research.md §3, §5) |
|---|---|
| `DependencyManifestGlobs` | see research.md §3 table |
| `AuthPathGlobs` | see research.md §3 table |
| `SchemaMigrationGlobs` | see research.md §3 table |
| `ContractsGlob` | `**/contracts/**` |
| `DomainInvariantsPath` | `{{DOMAIN_INVARIANTS_PATH}}` (skipped while unfilled) |
| `AbuseGuardFileCount` | `25` |
| `CoolingOffHours` | `24` |
| `PhaseWarnLines` | `400` |
| `PhaseWarnFiles` | `15` |

### Fixture branch

Throwaway branch (`999-fixture-*` naming, outside the real `NNN-` sequence to avoid
colliding with real feature numbers) created during Phase-gate verification per
`quickstart.md`, deleted afterward — never merged.

## Files by phase (mirrors plan.md's Project Structure)

| Phase | File | New/Edited |
|---|---|---|
| 1 | `scripts/enforcement-pack.ps1` | New |
| 1 | `.github/workflows/enforcement-pack.yml` | New |
| 2 | `scripts/enforcement-pack.ps1` | Edited (extends Phase 1's file) |
| 3 | `.github/PULL_REQUEST_TEMPLATE.md` | New |
| 3 | `docs/sdlc/branch-protection.md` | New |
