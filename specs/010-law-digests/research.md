# Research: Law Digests

Decisions for the plan; each records the choice, the rationale, and the rejected
alternatives. Owner ratifies D4's constants and D2's pack composition at approval.

## D1 — "Generated" means assembled from in-document curated markers

**Decision**: each binding rule gets a one-line digest text authored IN the source
document, on a standalone marker line beside the rule (`<!-- digest: <one-liner> -->`).
The digest FILE is written only by `scripts/build-digests.ps1`, which deterministically
assembles each pack's marker lines in document order. **Rejected**: (a) hand-written
digest files — the gap's stated failure mode (drift); (b) LLM summarization in CI —
non-deterministic, unreviewable, and the digest would still need human vetting; (c)
extracting the rule sentences themselves — law prose is multi-line and cross-referential,
so verbatim extraction produces a bad page; the curated one-liner is reviewed WITH the
rule it sits beside, which is exactly where a reviewer can see them disagree.

**Drift property**: editing a rule without touching the adjacent marker is visible in
every diff (they are adjacent lines); editing a marker without regenerating fails CI
(D5). Hand-editing a digest file fails CI the same way. The artifact cannot drift; the
one-liner's fidelity is reviewed at the same moment as the rule text itself.

## D2 — Packs mirror the Task-Scoped Reading table

**Decision**: `docs/digests/digest-packs.json` (single source of pack composition):

| Pack | Member documents |
|---|---|
| delivery | docs/sdlc/definition-of-done.md, docs/sdlc/gate-command.md, docs/sdlc/flow.md |
| branching | docs/sdlc/branch-strategy.md, docs/sdlc/repository-strategy.md, docs/sdlc/team-workflow.md |
| review | docs/sdlc/review-process.md, docs/sdlc/rollback-process.md |
| critical | docs/sdlc/critical-delivery.md |
| adoption | adoption/updating.md |

The constitution and CLAUDE.md are deliberately EXCLUDED: they are the always-loaded
core and the supreme law — a digest of the constitution would invite acting on a summary
of the one document that must always prevail. definition-of-done.md is in the delivery
pack even though it is also always-loaded: its digest lines serve the pack's page.
**Rejected**: per-document digests (too many small files; the reading table's unit is
the pack); a constitution digest (authority risk, above).

## D3 — Output shape

**Decision**: `docs/digests/<pack>-digest.md`, opening with a fixed generated-file header
(generator name + regeneration command, non-authoritative notice, the full-read rule),
then one bullet per marker: `- <one-liner> (<source path>)`, in manifest-then-document
order. LF-normalized content; the freshness comparison normalizes line endings (spec edge
case). **Rejected**: per-rule anchors/links into source line numbers — line numbers rot;
the path is stable.

## D4 — Bounds (constitutional force NOT claimed; generator-enforced constants)

**Decision**: `MaxDigestContentLines = 40` per pack (header excluded) and
`MaxDigestLineLength = 120` characters per one-liner — the generator FAILs when exceeded,
which keeps digests one-page by construction. These are script constants, not
constitution amendments (the feature adds no law — FR-009/Assumptions; the constitution
stays 0.6.0). Owner ratifies both values at approval. **Rejected**: soft warnings — a
digest that outgrows a page quietly stops being a digest.

## D5 — Freshness check inside ritual-checks

**Decision**: `build-digests.ps1 -Check` regenerates in-memory and compares against the
committed files: any difference (stale content, hand-edit, missing digest for a pack with
markers, orphan file in docs/digests/ not named by the manifest) → exit 1 naming each
offending file and printing the fix (`pwsh -File scripts/build-digests.ps1`).
`ritual-checks.ps1` gains a `digests` member wired exactly like the existing four.
**Inertness rule** (US3/SC-004): when NO member document carries a marker AND
docs/digests/ has no digest files, the check reports "n/a (no digest markers)" and exits
0 — adopted projects that haven't opted in stay green. **Rejected**: putting the check
inside doc-lint (doc-lint is structure/pointer integrity; freshness is a different
verdict with a different fix command).

## D6 — Decoy defense (the 008/009 comment precedent, adapted)

**Decision**: a marker line counts only when it is a standalone single-line marker
(`^\s*<!-- digest: ... -->\s*$`) NOT inside a multi-line comment block opened on an
earlier line. Line-scanning with an in-comment state flag — deterministic and testable
(contract scenario). A commented-out section's markers vanish with the section.

## D7 — Manifest classification: digests are generated, never synced

**Decision**: `scripts/build-digests.ps1` and `docs/digests/digest-packs.json` ship
verbatim (kit-manifest entries); `docs/digests/*-digest.md` are added to kit-manifest as
a new class `generated` — update-kit must NEVER copy them into a project (an adopted
project's digests summarize ITS surgical law, so the kit's digests would be wrong there).
The kit's own committed digests are the dogfood + worked example (FR-008). If update-kit
treats unknown classes conservatively (skip), `generated` degrades safely; phase 1
verifies actual behavior and records it. **Rejected**: shipping kit digests verbatim
(actively wrong content in adopted projects).

## D8 — Delivery shape and certification

**Decision**: 3 phases — (1) the machine: generator + manifest + ritual-checks wiring +
kit-manifest classes, contract-validated on fixtures; (2) the content: markers into the
ten pack documents + committed kit digests; (3) the sweep: CLAUDE.md reading table,
updating.md flow-down note, roadmap flip. Machine first so phase 2's content lands under
an already-armed freshness check. Plan declares `**Gate Batching**: phases 1-3` and
`**Gate Certification**: ci-held` (the 009-proven mode).

## D9 — Non-changes

No constitution amendment (0.6.0 stands); no change to doc-lint, enforcement-pack,
scope-check, verify-kit verdicts; no change to the source-of-truth ladder; no digest for
Lite-lane or per-feature documents; adopted-project marker adoption is opt-in and
documented, never pushed.
