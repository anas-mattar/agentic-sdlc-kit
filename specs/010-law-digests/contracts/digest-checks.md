# Contract: Digest generator and freshness check

Binding contract for `scripts/build-digests.ps1` (generate + `-Check`) and its
`ritual-checks.ps1` wiring. Verified on seeded fixtures at the phase 1 gate and
re-verified by the fresh-context review; C-numbers are the validation scenarios.

## Inputs

- `docs/digests/digest-packs.json` (packs → member docs); source documents on disk;
  committed `docs/digests/*-digest.md`. `-Root` targets any repo (kit or adopted project);
  zero required arguments in the repo itself (SC-003).

## Scenarios

| # | Fixture state | Expected |
|---|---|---|
| C1 | No markers anywhere, no digest files (pre-adoption project shape) | check: "n/a (no digest markers)", exit 0; ritual-checks unchanged overall (SC-004) |
| C2 | Markers in two packs' docs; generator run; nothing edited | generate: two digest files, byte-stable on re-run (SC-003); check: OK, exit 0 |
| C3 | Marked rule's one-liner edited, digest NOT regenerated | check: FAIL naming `<pack>-digest.md` + the regeneration command, exit 1 |
| C4 | Digest file hand-edited (regeneration not run) | check: FAIL, same message shape |
| C5 | Digest file deleted while its pack still has markers | check: FAIL (missing digest) |
| C6 | Orphan `rogue-digest.md` in docs/digests/ (no such pack / pack has no markers) | check: FAIL (orphan) |
| C7 | Marker inside a multi-line HTML comment block (commented-out section decoy) | not extracted; digest without it is what check expects (D6) |
| C8 | Empty marker text (`<!-- digest: -->`) | FAIL naming file + line |
| C9 | Pack doc listed in manifest but missing on disk | FAIL naming the path |
| C10 | Pack's markers exceed MaxDigestContentLines (41 one-liners) | generate AND check FAIL naming the pack, the count, and the bound |
| C11 | Marker content over MaxDigestLineLength (121 chars) | FAIL naming file + line + bound |
| C12 | CRLF-checkout of a committed digest vs LF regeneration | check: OK (normalized comparison — no false drift) |

## Phase 1 review amendments (hardening beyond C1–C12)

Adopted at the phase 1 fix round (fresh-context review F1–F8); all FAILs follow the
error-message contract below:

| # | State | Expected |
|---|---|---|
| A1 | Over-bound pack whose digest is committed (F1) | the bound FAIL only — the digest is NOT also reported as an orphan |
| A2 | Manifest missing (F2) | generate: FAIL with `build-digests:` prefix + restore fix; check with digests present: FAIL naming the count + restore-or-delete fix; check with none: n/a |
| A3 | Marker example inside a fenced code block (F3) | not extracted — fences are excluded like comment blocks |
| A4 | Invalid pack name (path traversal) or duplicate pack name, case-insensitive (F4) | FAIL naming the name and the manifest — nothing written |
| A5 | ritual-checks summary on n/a (F5) | echoes the member's own n/a reason verbatim |
| A6 | Near-miss marker line: wrong case, missing colon, internal `-->`, unclosed (F6/F7) | FAIL *malformed digest marker* naming file + line + the exact grammar |
| A7 | Digest in a subdirectory of docs/digests/, or name differing only by case (F8) | seen by the recursive, case-exact orphan scan → FAIL |

## Error-message contract

Every FAIL names: the offending file (and line where applicable), the violated condition
(with the configured bound's value where one exists), and the fix — for staleness always
verbatim: `regenerate: pwsh -File scripts/build-digests.ps1`.

## Ritual-checks wiring

New member `digests` runs `build-digests.ps1 -Check -Root <root>`, reported in the summary
table like the existing members; n/a state prints as n/a, not OK. Runs in kit AND adopted
projects (the script ships verbatim).

## Non-goals

No change to doc-lint / enforcement-pack / scope-check / verify-kit verdicts; no LLM or
network use; no digest for the constitution or CLAUDE.md (D2); no writing of source
documents by the generator (markers are authored by humans/agents in ordinary edits); no
flow-down of the kit's generated digest files (kit-manifest `generated` class, D7).
