# AI Code Review — 010 Law Digests, Phase 1 (the machine)

**Reviewer**: fresh-context general-purpose subagent (Claude Fable 5, claude-fable-5)
**Date**: 2026-09-09
**Branches**: agentic-sdlc-kit `010-law-digests` (tip `dc6bbd6` — the commit under review)
**Scope reviewed**: full commit diff of `dc6bbd6`; full current content of
`scripts/build-digests.ps1`, `scripts/ritual-checks.ps1`, `docs/digests/digest-packs.json`,
`kit-manifest.json`, `adoption/updating.md` (diff hunk); governing docs
`specs/010-law-digests/{spec.md,plan.md,tasks.md,research.md,data-model.md,quickstart.md,contracts/digest-checks.md}`;
class-handling code in `scripts/update-kit.ps1` (manifest resolution, lines 99–164),
`scripts/verify-kit.ps1` (Get-ManifestClass), `scripts/doc-lint.ps1` (manifest sweep).
Live runs: contract rows C1, C2 (byte-stability), C3, C7 (decoy), C8, C10, C12 plus
missing-manifest, duplicate-pack, path-traversal, and code-fence probes on scratch
fixtures (deleted after); kit self-runs of `build-digests.ps1 -Check`, `scope-check.ps1`,
and full `ritual-checks.ps1`.
**Feature contract**: `specs/010-law-digests/contracts/digest-checks.md` C1–C12 +
error-message contract + ritual-checks wiring + non-goals; plan phase 1 Territory of five
files; no new packages; no constitution change; SC-003 determinism; SC-004 inertness.

## Reviewer Provenance

- **Reviewer**: fresh-context general-purpose subagent (separate context; second-model review lane) — Claude Fable 5 (claude-fable-5)
- **Implementer**: the agent session that produced commit `dc6bbd6` (unknown to this reviewer beyond the commit metadata)
- **Inputs provided**: review instructions naming the commit sha only; spec.md, plan.md, tasks.md, research.md, data-model.md, quickstart.md, and contracts/digest-checks.md read from the repo; the phase diff via `git show dc6bbd6`
- **Attestation**: This reviewer did not produce the diff under review.
- **Context**: this reviewer was given only the review instructions and read the spec/plan/contract from the repo; no implementation conversation or reasoning was shared.

## Verdict

**APPROVE with follow-ups** — the commit delivers exactly the phase 1 Territory: a
deterministic marker-extraction generator with a `-Check` freshness mode, the five-pack
manifest, the `digests` ritual-checks member with a distinct n/a verdict, and the
kit-manifest `generated` class. I independently re-verified the load-bearing contract
rows on my own fixtures (C1, C2 byte-stability, C3, C7 decoy defense, C8, C10, C12 CRLF
tolerance — all behave as recorded in tasks.md), confirmed the D7 record against
update-kit.ps1's actual code (work lists filter to `verbatim`/`surgical`, so `generated`
is skipped by construction), and confirmed the kit self-run (`digests: n/a`, ritual-checks
RESULT OK, scope-check PASS on `dc6bbd6`). Nothing blocking. The residual risk sits in
error-message quality on compound failure states (F1, F2), fail-open handling of a
malformed pack manifest (F4), and a forward-looking extraction trap for phases 2–3 (F3 —
a literal marker example in documentation prose will be harvested into a digest).

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-002 determinism: two generate runs on a fixture produced identical SHA-256 for the digest (`byte-stable: True`); LF assembly read in `Get-PackDigestContent` (`-join "`n"` + trailing `"`n"`). FR-003 header: generated fixture digest carries the exact data-model header (generator name, regeneration command, non-authoritative notice, full-read rule) and per-bullet source paths. FR-004: C3 stale FAIL reproduced verbatim incl. fix command. FR-005: C7 decoy (marker inside a multi-line comment block) NOT extracted — verified live. FR-007: `-Root` run against a scratch tree worked; C1/no-marker inertness verified (`digests: n/a (no digest markers)`, exit 0). Bounds 40/120 present as constants (build-digests.ps1 lines 53–54) with FAIL paths (C10 message reproduced live, C11 code path read: `-gt $MaxDigestLineLength` names file:line + bound). |
| Visual-reference match | N/A — no UI, no `specs/010-law-digests/screenshots/`. |
| Feature contract held (no unapproved table/migration/permission/package) | Diff adds one script, one JSON manifest, two kit-manifest entries, one updating.md table row, one ritual-checks member — no packages, no schema, no workflow change, no constitution edit (0.6.0 untouched, checked `git show dc6bbd6 --stat`). Non-goals held: doc-lint/enforcement-pack/scope-check/verify-kit verdict logic untouched by the diff. |
| Constitution / domain invariants | II: digest header states non-authoritative + source-prevails + constitution II unchanged — matches FR-009/plan. IV: extends the existing script+manifest+ritual-checks pattern, `ConvertTo-GlobRegex`-compatible manifest entries. VIII: C1–C12 validation record in tasks.md independently re-verified (7 of 12 rows re-run live; the rest read against the code paths, which are direct). |
| Security (authn/authz, secrets, sensitive logging) | No network, no secrets, read-only in `-Check`. One robustness gap: unvalidated pack `name` flows into the output path — see F4. Marker text flows only into markdown bullets via string interpolation, never into a regex or command — no injection channel found. |
| Scope guard | `pwsh -File scripts/scope-check.ps1` → `scope-check: PASS phase 1 commit dc6bbd6 (6 file(s))`. Diff touches exactly the five Territory files + `specs/010-law-digests/tasks.md` (spec-dir exempt). `git diff --stat` of the commit read for intent — nothing unrelated. |
| Rollback safety | Purely additive: reverting `dc6bbd6` removes the script/manifest/member/entries cleanly; no data, no schema; the `digests` member disappears with the revert and the other four members are untouched. The `generated` manifest class degrades safely in older update-kit copies (skipped by the verbatim/surgical filter — verified in update-kit.ps1 lines 155–156). |

## Findings

### F1 — Over-bound pack with a committed digest also reports a misleading "orphan" FAIL — MINOR

`build-digests.ps1` check mode: when a pack exceeds `MaxDigestContentLines`, the pack is
`continue`d out of `$expected` (line ~153), so its legitimately committed digest then
fails the orphan scan too. Reproduced live (41 markers, digest committed):

```
digests: FAIL — digest too long: pack 'alpha' has 41 content lines (bound: MaxDigestContentLines = 40) — …
digests: FAIL — orphan digest: docs/digests/alpha-digest.md — no manifest pack with markers produces it; delete it or add markers to its pack's documents
```

The second line's advice is the opposite of the real fix (the pack has too many markers;
"add markers" makes it worse, "delete it" deletes a digest the pack should keep once
trimmed). Exit code and the first message are correct, so C10 passes as written — but the
error-message contract's spirit ("names … the fix") is violated by the companion line.
*Action: implementer — suppress the orphan report for digests whose pack failed the
bounds check (e.g. track over-bound pack names and exclude their `<pack>-digest.md` from
the orphan scan), or reword. Small, in-territory.*

### F2 — Missing-manifest FAIL message is inaccurate in generate mode and omits the fix — MINOR

`build-digests.ps1` lines 135–142: when the manifest is absent, every non-n/a path prints
`digests: FAIL — docs/digests/digest-packs.json not found (digest files exist without a
pack manifest)`. Reproduced live in generate mode with **zero** digest files present —
the parenthetical is then false. The line also carries no fix command (error-message
contract: every FAIL names the fix) and uses the `digests:` prefix even in generate mode,
where every other message is prefixed `build-digests:`. Low impact — the manifest ships
verbatim with the kit, so adopted projects always have it — but the message lies in the
one state where someone deleted it.
*Action: implementer — branch the message per mode/state and append a fix (e.g. "restore
docs/digests/digest-packs.json from the kit"). Optional polish; not blocking.*

### F3 — No code-fence awareness: a literal marker example in documentation prose is harvested — CONFIRM

Extraction is HTML-comment-aware only (per D6 — spec-compliant), so a standalone marker
line inside a fenced code block IS extracted. Verified live: a doc containing
```` ```markdown ```` + `<!-- digest: example syntax shown in docs -->` + ```` ``` ````
produced a digest bullet `- example syntax shown in docs (…)`. This is not a phase 1
defect (the contract only demands comment-stripping), but it is a loaded trap for phases
2–3: `adoption/updating.md` is itself an adoption-pack member, and the phase 3 flow-down
note must document the marker syntax for adopters — a literal standalone example line
there would pollute the adoption digest (deterministically, so the freshness check would
happily enforce the pollution). The marker docs currently live only in
`build-digests.ps1`'s comment header (not scanned), which is fine.
*Action: owner/implementer decision — either (a) phase 2/3 authors show the syntax
non-standalone or inside an HTML comment / with indentation-breaking text, or (b) add
fence-awareness to extraction. At minimum, carry this note into phase 3's T010 authoring.*

### F4 — Pack manifest handled fail-open: duplicate names silently drop markers; unvalidated pack name escapes docs/digests — MINOR

Two reproduced robustness gaps against the spec's fail-closed edge-case posture:

1. **Duplicate pack names**: two packs named `alpha` → `$expected["alpha-digest.md"]` is
   silently overwritten; the run reported `OK (1 digest(s), 2 marker(s))` and the digest
   carried only the second pack's marker — the first pack's law vanished from the digest
   with no verdict.
2. **Path traversal via pack name**: `"name": "../evil"` → generate wrote
   `docs/digests/../evil-digest.md` (verified: file landed at `docs/evil-digest.md`,
   outside the digests dir and invisible to the non-recursive orphan scan).

Severity is capped because `digest-packs.json` is a kit-owned verbatim file (anyone who
can edit it can edit anything), and doc-lint sweeps the kit's own copy. Still, the spec
says malformed state fails closed, and both states are malformed manifests that pass
silently.
*Action: implementer — validate pack names (`^[A-Za-z0-9._-]+$`) and reject duplicate
names/duplicate output filenames with a FAIL. A few lines, in-territory; fine to fold
into a later phase's fix batch if the owner prefers.*

### F5 — ritual-checks summary hardcodes the n/a reason — MINOR

`scripts/ritual-checks.ps1` line 89 prints `n/a (no digest markers)` whenever the member
matched `^digests: n/a`, but the member has a second n/a state, `digests: n/a (no digest
manifest)` (build-digests.ps1 line 137) — the summary would then state the wrong reason.
The regex wiring itself is sound: I probed for misfires — `n/a` lines are printed only on
the two exit-0 early-return paths, the guard also requires exit 0, FAIL/OK lines can
never begin `digests: n/a`, and the child-process `2>&1` capture stringifies cleanly
(verified in the live kit run: member output re-echoed, summary row distinct from OK,
RESULT OK).
*Action: implementer — optionally echo the member's actual n/a line into the summary
(e.g. capture the matched line's parenthetical). Cosmetic; "none" is acceptable.*

### F6 — Greedy marker regex diverges from HTML comment semantics on internal `-->` — MINOR

`'^\s*<!--\s*digest:(.*)-->\s*$'` captures greedily to the LAST `-->`: the line
`<!-- digest: has --> arrow --> inside -->` produced the digest bullet
`- has --> arrow --> inside` (verified). An HTML renderer would close the comment at the
FIRST `-->` and display ` arrow --> inside -->` as visible text — so the doc's rendered
appearance and its digest disagree for such a line. Deterministic and pathological
(nobody should write `-->` in a one-liner), and phase 2's authored markers are reviewed
with their rules.
*Action: none required for phase 1; phase 2 authors avoid `-->` inside marker text (a
lazy `(.*?)` match would align with HTML if ever revisited).*

### F7 — Marker matching is case-insensitive; a colon-less marker vanishes silently — MINOR

PowerShell `-match` is case-insensitive, so `<!-- DIGEST: x -->` counts as a marker
(deterministic, harmless, but undocumented in the grammar). Conversely a typo'd
`<!-- digest x -->` (missing colon) matches nothing and is silently ignored — the
fail-closed net catches only the empty-text-after-colon case (C8). A rule the author
believed marked would simply be absent from the digest, and the freshness check would
enforce the absence.
*Action: none mandatory. Optionally add a lint for near-miss lines
(`<!--\s*digest\b` without the exact grammar) in a later phase; phase 2's L1
quote-verification is the compensating control.*

### F8 — Orphan scan is non-recursive and case-sensitivity varies by OS — MINOR

`Get-ChildItem $digestsDir -Filter '*-digest.md' -File` (line 132) does not recurse, so a
rogue digest in a subdirectory of `docs/digests/` is never seen; and on Linux CI the
filter is case-sensitive, so `Delivery-Digest.md` would evade the orphan scan there while
matching on Windows. Both are corner-of-a-corner states.
*Action: none required; note for a hardening pass.*

## Constitution re-check (post-implementation)

**PASS.** I: spec/plan/tasks preceded the commit (git history: `f7c0591` claim,
`6b65afc` specify-stage, then `dc6bbd6`). II: the ladder is untouched; the generated
header names the source documents as prevailing and constitution II as unchanged —
FR-009 satisfied in the artifact itself. IV: no new patterns — the script mirrors the
existing member-script conventions (`-Root`, exit codes, `verdict: message` lines), and
the manifest entries use the established glob grammar (checked against
`ConvertTo-GlobRegex`: `docs/digests/*-digest.md` and the exact-path entry conflict with
no existing pattern; doc-lint's completeness sweep classifies `digest-packs.json` via the
new verbatim entry — kit self-run OK). VIII: business-critical governance logic validated
by the seeded C1–C12 record, which this review independently re-executed in substantial
part. IX: pending at merge (as planned). X: phase 1 only; Gate Batching phases 1-3 and
Gate Certification ci-held both declared in the approved plan before phase 1 — the
tasks.md record correctly defers certification to the batch end. Constitution remains
0.6.0; no clause engaged late.

## Test coverage observed

No test framework (kit convention, per plan). Coverage = the seeded contract record in
`specs/010-law-digests/tasks.md` (Phase 1 validation): C1–C12 with quoted verdicts + exit
codes, the D7 update-kit record, and the kit self-run. This review independently re-ran
C1, C2 (SHA-256 byte-stability), C3, C7, C8, C10, C12 plus five adversarial probes beyond
the contract (missing-manifest × mode matrix, duplicate pack names, path-traversal name,
code-fence extraction, over-bound + committed digest) on scratch fixtures — all recorded
verdict quotes matched the actual behavior character-for-character where I reproduced
them (modulo em-dash rendering in my shell). D7's "silently skipped by construction"
claim was verified directly against `scripts/update-kit.ps1` (lines 151–156: work lists
built only from `verbatim`/`surgical`). Kit self-run re-verified: `digests: n/a`,
`scope-check: PASS phase 1 commit dc6bbd6`, `ritual-checks: RESULT OK`.

## Residual risk

Concentrated in F3: phase 2/3 will put marker syntax documentation and ten marked
documents into the extraction path, and the extractor harvests any standalone marker line
regardless of fences — the phase 3 flow-down note in `adoption/updating.md` (an adoption
pack member) is the likeliest place to trip it. F1/F2/F4 are message-quality and
malformed-manifest robustness gaps that cannot fire on a well-formed kit but will confuse
the first adopter who hits a compound state; they are small, in-territory fixes if taken
now. F5–F8 are cosmetic or pathological. Nothing here blocks the phase; certification is
correctly deferred to the batch end under the plan's declared ci-held mode.

---

## Dispositions (implementer — appended after the review; reviewer text above unedited)

All eight findings fixed in the phase 1 remediation commit; all fixes are in-territory
(`scripts/build-digests.ps1`, `scripts/ritual-checks.ps1`; design-doc addenda live in the
exempt spec dir). Validation: new scenarios A1–A7 recorded in
`contracts/digest-checks.md` (Phase 1 review amendments) and quoted in tasks.md; original
C1–C12 re-run in full afterwards — no regression.

| # | Disposition |
|---|---|
| F1 | **Fixed.** Over-bound packs' digest names are tracked and excluded from the orphan scan; A1 shows the bound FAIL as the only issue. |
| F2 | **Fixed.** Missing-manifest messages branch per mode/state: generate FAILs with the `build-digests:` prefix + restore fix; check with digests present FAILs naming the count + restore-or-delete fix; check with none is n/a (A2, all three quoted). |
| F3 | **Fixed structurally** (reviewer's option b): extraction now skips fenced code blocks (``` and ~~~, CommonMark open/close lengths), so documentation may show the marker syntax literally inside a fence — verified for both fence styles (A3). Phase 2/3 authoring no longer depends on discipline here. |
| F4 | **Fixed.** Pack names validated against `^[A-Za-z0-9][A-Za-z0-9._-]*$` (no separators — `../evil` FAILs, nothing written, no escaped file) and case-insensitive duplicates FAIL naming both (A4). |
| F5 | **Fixed.** The summary row now echoes the member's own n/a reason verbatim (covers both `no digest markers` and `no digest manifest`). |
| F6 | **Fixed beyond the ask** (bundled with F7): a marker line with internal `-->` is no longer harvested greedily — it FAILs as *malformed digest marker*, keeping the digest and the rendered document in agreement (A6 line 5). |
| F7 | **Fixed.** Grammar is now case-sensitive (`-cmatch`), and any standalone near-miss (`<!-- DIGEST: … -->`, missing colon, unclosed comment) FAILs naming file + line + the exact grammar instead of vanishing (A6 lines 3, 4, 6). The unclosed case still opens a comment block for sane downstream parsing. |
| F8 | **Fixed.** The orphan scan is recursive with exact (case-sensitive) name matching — a nested `sub/rogue-digest.md` is FAILed (A7); a case-variant name no longer evades on Linux. |
