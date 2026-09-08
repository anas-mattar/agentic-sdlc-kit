# Contract: ritual checks — wrapper script and CI workflow

**Purpose**: one entry point that runs every ritual machine check with identical verdicts
locally and in CI (spec FR-007, FR-008; research D5).

## Wrapper: scripts/ritual-checks.ps1

```powershell
pwsh -File scripts/ritual-checks.ps1 [-Branch <name>] [-Root <path>]
```

Runs, in order, stopping never (all members always run so one push reports every problem):

1. `scripts/doc-lint.ps1`
2. `scripts/enforcement-pack.ps1` (which includes the ReviewProvenance check after phase 2)
3. `scripts/scope-check.ps1 -All` (every phase commit since `merge-base HEAD origin/main`)
4. `scripts/verify-kit.ps1` *(amended by feature 007)* — the adoption doctor, run only when
   `.kit-version` marks an adopted project; in the kit repository the verdict block shows
   an explicit `verify-kit  n/a (kit repository)` line, excluded from the failure count

Output ends with a verdict block, one line per member (OK/FAIL, derived from the member's
exit code — member WARNs stay visible in that member's own output above):

```text
ritual-checks: doc-lint         OK
ritual-checks: enforcement-pack OK
ritual-checks: scope-check      FAIL
ritual-checks: RESULT FAIL (1 of 3 member(s) failed)
```

Exit 0 iff every member exits 0. Read-only; no repository writes.

**Supersession**: `ritual-checks.yml` replaces feature 002's per-check workflows
(`doc-lint.yml`, `enforcement-pack.yml`) — one check name, one code path. Migration of
required-check names: `docs/sdlc/branch-protection.md`.

## Workflow: .github/workflows/ritual-checks.yml

| Aspect | Value |
|---|---|
| Trigger | `push` to branches `[0-9][0-9][0-9]-*`, `fix/**`, `chore/**`, `docs/**`; plus `pull_request` into `main` |
| Runner | `ubuntu-latest` (pwsh preinstalled; proves cross-platform on every push) |
| Checkout | `fetch-depth: 0` — merge-base and per-commit parent reads need full history |
| Steps | checkout → `pwsh -File scripts/ritual-checks.ps1` with `-Branch` passed explicitly through an env var (detached-HEAD attribution; injection-hardened) — nothing else, so CI can never drift from the local command |
| Permissions | `contents: read` only; no secrets |
| Status | single check named `ritual-checks`; branch protection SHOULD require it (documented in `docs/sdlc/branch-protection.md`, applied by repository configuration — the kit cannot enforce host settings) |

## Adopted-project behavior

- The workflow and both scripts are **verbatim** kit files (kit-manifest.json), so
  `update-kit.ps1` flows them down unchanged.
- A project whose CI is not GitHub Actions keeps FR-008: run the same wrapper from any CI, or
  locally; adoption docs state that wiring it as a required check is part of finishing adoption
  (spec US3, acceptance 3).
