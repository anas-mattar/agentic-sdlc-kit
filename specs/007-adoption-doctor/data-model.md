# Data Model: Adoption Doctor

All state is repository files; "entities" are record shapes and verdict structures.

## kit-adoption.json (project-owned; written by init, owner-edited after)

| Field | Type | Rules |
|---|---|---|
| `schemaVersion` | int | `1`; unknown versions ⇒ doctor finding ("newer record than doctor") |
| `projectName` | string | non-empty |
| `topology` | string | `single` \| `multi` |
| `tiers` | string[] | subset of `backend, frontend, mobile, database, integration`; unknown value ⇒ finding, not crash (spec edge case) |
| `initDate` | string | ISO date |
| `kitVersionAtInit` | string | kit commit sha, or `copy` when init ran on a hand-copied kit |
| `gateProof` | object[] | may be empty (init writes `[]`); see below |

**gateProof entry**: `gate` (label, e.g. `backend` or `default`), `command` (the exact
chain — never include secrets), `exitCode` (int; proof requires at least one entry with
`0`), `date` (ISO), `recordedBy` (name). Attestation is human: no tool writes entries.

Lives **only in adopted projects** — the kit repo never has one and `kit-manifest.json`
never classifies it. Not overwritten by `update-kit.ps1` (not a kit-shipped path).

## Doctor dimensions and verdicts

| # | Dimension | Healthy | FAIL | WARN |
|---|---|---|---|---|
| 1 | Structure essentials | all required kit paths present (list mirrors doc-lint's `$requiredKitPaths`, sync-note in both headers) | any missing → per-path finding, fix pointer = adoption step 0 (re-copy) | — |
| 2 | Surgical-slot completeness | zero `{{SLOT}}`/`TODO(` in existing surgical-class files (manifest-resolved) | per file+marker finding, fix pointer = owning adoption step | — |
| 3 | Constitution ratification | no `TODO(RATIFICATION_DATE)`/`TODO(PROJECT_NAME)`/`{{…}}` in constitution | finding, fix pointer = adoption step 1/2 (ratify) | — |
| 4 | Adoption record + tiers + gate proof | record parses, tiers known, each declared tier has `docs/rulebooks/<tier>-rules.md`, ≥1 gateProof exit-0 entry | record invalid; declared tier missing rulebook; record present but no exit-0 proof | record absent entirely (pre-007) → WARN + creation instructions |
| 5 | `.kit-version` sanity | present, parses to non-empty sha/tag token | nonsense content (hand-edit) | absent while project is otherwise adopted → WARN + creation instructions |

**Decline** (not a verdict): kit-repo identity detected (research D5.1) → message, exit 0,
no findings.

**Output**: one line per finding (`verify-kit: FAIL <dimension>: <what> — fix: <pointer>`;
`WARN` analogous), then a summary block (`verify-kit: <n> failure(s), <m> warning(s)` /
`verify-kit: OK — adoption integrity verified`). Exit 0 iff zero FAILs (warnings never
fail — grandfather posture, research D8).

## ritual-checks member row (phase 3)

`verify-kit` appears in the verdict block as `OK` / `FAIL` / `n/a (kit repository)`;
`n/a` is excluded from the failure count. Local and CI identical by construction
(006 FR-008 inherited).
