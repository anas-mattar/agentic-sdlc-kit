# Implementation Plan: Law Digests

**Branch**: `010-law-digests` | **Date**: 2026-09-09 | **Spec**: specs/010-law-digests/spec.md
**Input**: Feature specification + research.md decisions D1–D9
**Gate Batching**: phases 1-3
**Gate Certification**: ci-held

## Summary

Per-pack law digests that cannot drift: curated one-line digest markers live beside the
rules they summarize in the governance documents; `scripts/build-digests.ps1`
deterministically assembles one one-page digest per pack (packs declared once, in
`docs/digests/digest-packs.json`); a `-Check` mode inside `scripts/ritual-checks.ps1`
fails any branch whose committed digests differ from regeneration. The kit dogfoods
(markers + committed digests for all five packs); adopted projects receive the generator
verbatim and generate digests of their own law, opt-in and inert until then. No
constitutional amendment — constitution stays 0.6.0.

## Technical Context

**Language**: PowerShell 7 (the kit's only scripting surface) + Markdown/JSON.
**Testing**: seeded fixture scenarios (contract C1–C12) + kit self-run; no test framework
(kit convention). **Target**: the kit repo itself + adopted projects via update-kit.
**Constraints**: deterministic byte-stable output (LF-normalized comparison); Windows +
POSIX shells; zero new dependencies; backward compatible (SC-004).

## Constitution Check

- **I Specification First**: this spec/plan/tasks set precedes implementation. PASS.
- **II Source of Truth**: digests sit OUTSIDE the ladder; every digest header says the
  source prevails; FR-009 documents it. No ladder change. PASS.
- **IV Architecture Consistency**: extends the existing script + manifest + ritual-checks
  pattern; no new patterns or packages. PASS.
- **VIII Testing Requirements**: the generator/check is business-critical governance
  logic → deterministic validation via seeded contract scenarios C1–C12 with recorded
  verdicts; regression = kit self-run + no-marker inertness fixture. PASS.
- **IX Human Review**: once per feature at merge. PASS.
- **X Controlled Delivery**: 3 phases, each independently revertible and testable;
  **Gate Batching: phases 1-3**; **Gate Certification: ci-held** (Standard feature —
  eligible; declared here before phase 1). Agent runs ritual-checks per phase for
  feedback; certification = owner's recorded approval on the batch-end push-event
  ritual-checks run triplet. PASS.

**Phase-sizing**: phase 2 touches ~15 files (ten source docs + five digests) but each
change is a handful of marker lines — expect a non-blocking PhaseSizeWarning on file
count at most; still one coherent, revertible slice (markers + their generated outputs
must land together or the freshness check fails the phase).

## Source Code (repository root)

```text
scripts/build-digests.ps1          # NEW  phase 1 — generate + -Check mode
scripts/ritual-checks.ps1          # MOD  phase 1 — 'digests' member wired
docs/digests/digest-packs.json     # NEW  phase 1 — pack manifest (D2)
kit-manifest.json                  # MOD  phase 1 — verbatim entries + 'generated' class (D7)
adoption/updating.md               # MOD  phase 1 ('generated' class doc) + phase 3 (flow-down note)
docs/sdlc/definition-of-done.md    # MOD  phase 2 — markers (delivery pack)
docs/sdlc/gate-command.md          # MOD  phase 2 — markers (delivery pack)
docs/sdlc/flow.md                  # MOD  phase 2 — markers (delivery pack)
docs/sdlc/branch-strategy.md       # MOD  phase 2 — markers (branching pack)
docs/sdlc/repository-strategy.md   # MOD  phase 2 — markers (branching pack)
docs/sdlc/team-workflow.md         # MOD  phase 2 — markers (branching pack)
docs/sdlc/review-process.md        # MOD  phase 2 — markers (review pack)
docs/sdlc/rollback-process.md      # MOD  phase 2 — markers (review pack)
docs/sdlc/critical-delivery.md     # MOD  phase 2 — markers (critical pack)
docs/digests/*-digest.md           # NEW  phase 2 — five generated digests (kit dogfood)
CLAUDE.md                          # MOD  phase 3 — reading table orientation column
docs/roadmap.md                    # MOD  phase 3 — GAP-014 → in progress
```

(adoption/updating.md gets its `adoption` pack markers in phase 2 as well — it is both an
instrument and a pack member.)

## Phases

| # | Name | Delivers | Territory (see tasks.md) |
|---|---|---|---|
| 1 | The machine | build-digests.ps1 (generate/-Check, bounds D4, decoy defense D6, inertness D5), digest-packs.json, ritual-checks wiring, kit-manifest classes; contract C1–C12 validated on fixtures | scripts/build-digests.ps1, scripts/ritual-checks.ps1, docs/digests/digest-packs.json, kit-manifest.json, adoption/updating.md |
| 2 | The content | Digest markers beside the binding rules of all ten pack documents; five generated digests committed; freshness check live on the kit itself | the ten pack documents + docs/digests/** |
| 3 | The sweep | CLAUDE.md reading-table orientation pointers; updating.md flow-down note; roadmap flip | CLAUDE.md, adoption/updating.md, docs/roadmap.md |

## Complexity Tracking

Nothing exceeds the constitution's defaults. No new packages; no architecture change; no
schema. The one deliberate novelty — a third kit-manifest class (`generated`) — exists
precisely to PREVENT wrong behavior (kit digests overwriting project digests) and is
verified against update-kit's actual unknown-class handling in phase 1 (D7).
