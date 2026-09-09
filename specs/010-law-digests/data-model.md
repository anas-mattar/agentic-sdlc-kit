# Data Model: Law Digests

No database — the "data" is a marker grammar, a pack manifest, generated artifacts, and
check verdicts.

## Digest marker (in source documents)

```text
<!-- digest: <one-line rule statement, ≤ 120 chars of content> -->
```

- Standalone line (only whitespace around it); authored beside the rule it summarizes.
- Counted only when NOT inside a multi-line HTML comment block opened on an earlier line
  (line-scan with in-comment state — research D6; a commented-out section's markers
  vanish with it).
- Empty digest text (`<!-- digest: -->` / whitespace) → check FAIL naming the file and
  line (fail-closed).
- Order of extraction = document order; document order = manifest member order.

## Pack manifest — `docs/digests/digest-packs.json`

```json
{
  "schemaVersion": 1,
  "packs": [
    { "name": "delivery",  "docs": ["docs/sdlc/definition-of-done.md", "docs/sdlc/gate-command.md", "docs/sdlc/flow.md"] },
    { "name": "branching", "docs": ["docs/sdlc/branch-strategy.md", "docs/sdlc/repository-strategy.md", "docs/sdlc/team-workflow.md"] },
    { "name": "review",    "docs": ["docs/sdlc/review-process.md", "docs/sdlc/rollback-process.md"] },
    { "name": "critical",  "docs": ["docs/sdlc/critical-delivery.md"] },
    { "name": "adoption",  "docs": ["adoption/updating.md"] }
  ]
}
```

- The single source of pack composition (FR-002). A doc missing from disk → check FAIL.
- A pack whose docs carry zero markers produces NO digest file, and none is demanded.

## Generated digest — `docs/digests/<pack>-digest.md`

```markdown
# <pack> pack — law digest (GENERATED)

<!-- GENERATED FILE — do not edit. Regenerate: pwsh -File scripts/build-digests.ps1
     Non-authoritative: for orientation only. The source documents prevail (constitution
     II is unchanged); read the full document before acting on its area. -->

- <one-liner> (`<source path>`)
- ...
```

- Written only by the generator; LF line endings; deterministic (same inputs → same
  bytes).
- Bounds (generator constants, owner-ratified at approval — research D4):
  `MaxDigestContentLines = 40` (bullets, header excluded), `MaxDigestLineLength = 120`
  (marker content). Exceeding either → generator/check FAIL naming the pack and count.

## Check behavior (`build-digests.ps1 -Check`, wired as ritual-checks member `digests`)

| Condition | Verdict |
|---|---|
| No marker in any manifest doc AND no `*-digest.md` in docs/digests/ | n/a — "no digest markers" (exit 0; SC-004 inertness) |
| Committed digest ≠ regenerated content (LF-normalized) | FAIL naming the file + fix command |
| Markers exist for a pack but its digest file is missing | FAIL (generate it) |
| `*-digest.md` present for a pack with zero markers, or not named by the manifest | FAIL (orphan — delete or add markers) |
| Empty marker text; manifest doc missing; bounds exceeded | FAIL naming file/line/bound |
| Everything regenerates byte-identically | OK |

Exit codes: OK/n-a → 0; any FAIL → 1 (ritual-checks aggregates as with existing members).

## kit-manifest.json additions (research D7)

| Path | Class |
|---|---|
| `scripts/build-digests.ps1` | verbatim |
| `docs/digests/digest-packs.json` | verbatim |
| `docs/digests/*-digest.md` | `generated` — update-kit must never copy these into a project (each project generates its own from its own law); phase 1 verifies update-kit's actual handling of the class and records it |
