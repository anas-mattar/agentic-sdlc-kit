# Data Model: Kit-Update Channel

## Manifest (`kit-manifest.json`, kit root — ships to adoptions)

```json
{
  "schemaVersion": 1,
  "entries": [
    { "path": "docs/sdlc/flow.md", "class": "verbatim" },
    { "path": "scripts/*.ps1", "class": "verbatim" },
    { "path": ".specify/memory/constitution.md", "class": "surgical",
      "reason": "ratified per project — amendments flow down by re-expression (adoption/updating.md)" },
    { "path": "docs/sdlc/gate-command.md", "class": "surgical",
      "reason": "project-filled gate commands" }
  ]
}
```

| Field | Rules |
|---|---|
| `path` | kit-root-relative; `*`/`**` globs allowed; forward slashes |
| `class` | `verbatim` (update copies it) or `surgical` (update only reports it) |
| `reason` | required on surgical entries; states what makes the file project-instantiated |

**Resolution**: most-specific match wins (exact path > glob); a file matching two
entries of *different* classes at equal specificity is a completeness-check failure.
Files in shipped surfaces matching no entry: failure. Files outside shipped surfaces
(`specs/NNN-*`, `review/`, `docs/roadmap.md`): kit-internal, never shipped, never
touched.

**Known surgical set** (from the 2026-09-01 flow-back): constitution, CLAUDE.md,
AGENTS.md, README.md, gate-command.md, repository-strategy.md (project layout named
inside), review-process.md / rollback-process.md / deployment-standards.md (projects
customize; citations swept per amendment), `docs/rulebooks/**` (instantiated),
`modules/**` (worked examples projects replace), `adoption/**`? — no: adoption docs are
verbatim (pure kit prose). Everything else shipped is verbatim.

## Version record (`.kit-version`, adopted project root)

```json
{ "kitVersion": "0.4.1", "kitCommit": "<40-hex sha>", "updatedOn": "2026-09-01" }
```

Written on every successful (non-dry-run) update. Absent record ⇒ degraded first run:
no verbatim baseline (all diffs are conflicts-without-baseline), full surgical report.

## Verbatim file states (three-way, per D5)

| target vs baseline (kit@recordedCommit) | target vs kit@HEAD | Meaning | Action |
|---|---|---|---|
| — | equal | up to date | none |
| equal | differs | clean kit update | copy |
| differs | differs | locally modified | skip + conflict report; `-Force <path>` overrides |
| no baseline (no record) | differs | unknown provenance | skip + "no baseline" report |
| absent in target | (kit file exists) | never installed | copy — nothing local to protect (any record state) |

All comparisons on CRLF-normalized content (D4).

## Update report (script output)

| Section | Content |
|---|---|
| Applied | verbatim files copied (path, old→new state) |
| Surgical | surgical files with upstream commits `recorded..HEAD` + pointer to SYNC IMPACT / adoption/updating.md |
| Conflicts | locally-modified verbatim files + resolution options |
| Skipped | unlisted / kit-internal paths encountered (informational) |
| Result | new `.kit-version` content; "up to date" when nothing applied and nothing pending |

Exit codes: `0` clean (applied or already current, no conflicts, no pending surgical),
`2` attention needed (conflicts and/or pending surgical work reported), `1` execution
error / preflight refusal.
