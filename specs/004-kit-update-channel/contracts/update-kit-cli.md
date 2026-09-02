# CLI Contract: `scripts/update-kit.ps1`

One-command kit update for an adopted project. Runs FROM the kit clone; transports
manifest-listed files only; never modifies surgical-class content.

## Invocation

```powershell
pwsh -File scripts/update-kit.ps1 -Target <adopted-project-root> [-Kit <kit-root>] [-DryRun] [-Force <path[]>] [-Json]
```

| Parameter | Required | Meaning |
|---|---|---|
| `-Target` | yes | adopted governance repo root — never defaulted, so self-update is impossible by omission |
| `-Kit` | no | kit root (default: the running script's own repo root) |
| `-DryRun` | no | full report, no writes (no file copies, no `.kit-version`) |
| `-Force` | no | list of kit-root-relative verbatim paths whose conflicts are resolved by taking the kit version |
| `-Json` | no | machine-readable report |

## Behavior

1. **Preflight** (exit 1 on failure): `-Kit` is a git repo containing
   `kit-manifest.json`; `-Target` ≠ `-Kit` (resolved paths); `-Target` passes the
   kit-integrity essentials (same required-paths list doc-lint asserts); `-Target`'s
   working tree is clean (updates must land reviewable).
2. **Read state**: manifest from the kit; `.kit-version` from the target (absent ⇒
   degraded mode per data-model).
3. **Verbatim pass**: per data-model's three-way table, CRLF-normalized (D4/D5);
   `-Force` entries take kit HEAD regardless of baseline.
4. **Surgical pass**: per D6, report upstream commits `recordedCommit..HEAD` per file;
   never write.
5. **Record**: on any non-dry-run without execution error, write `.kit-version`
   (kit constitution version + kit HEAD sha + date).
6. **Report** per data-model; exit `0` clean / `2` attention needed / `1` error.

## Idempotence

A second run immediately after a clean run reports "up to date", writes nothing
byte-identical, and exits 0 (SC-005).

## Non-goals

Never touches nested code repos, unlisted paths, or the target's git state (no commits,
no branches — the owner reviews and commits per their own docs-lane ritual); never
deletes target files (a file removed from the kit is reported, not deleted).
