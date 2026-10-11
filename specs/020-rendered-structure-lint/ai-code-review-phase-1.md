# AI Code Review — 020 Rendered-structure Lint, phase 1 (the table rules)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-11
**Branches**: kit repository `020-rendered-structure-lint` (phase commit `ef336c7`, parent `079a8a2` "docs: 020 tasks approved")
**Scope reviewed**: `git show ef336c7` in full: `scripts/markdown-lib.ps1` (`Get-StructureFindings`, `Get-StructureCellCount`,
`Test-StructureDelimiterRow`), `scripts/doc-lint.ps1`, `docs/roadmap.md`, `tests/enforcement/rules.json` (DOC-010),
`tests/enforcement/emission-idioms.json`, all 16 `DOC-010` fixtures (recipe, command, expected), `tasks.md` and `notes.md`
of the feature; against `spec.md` (FR-001..004, 006..008, US1, US2, SC-001..003), `plan.md` (D1-D3, D5, D6, D8) and
`tasks.md` Phase 1. Throwaway probe scripts (about 60 documents) were run against the scanner from a scratch directory.
**Feature contract**: no new script file, package or architecture; one scanner in the shared library, called from the
existing document walk; existing verdicts and fixtures unchanged (SC-003); OK line unchanged (D5).

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-sonnet-5-5 (separate session that produced the phase 1 commit)
- **Inputs provided**: phase 1 diff (`ef336c7`), spec.md, plan.md, tasks.md, notes.md, the scripts and fixtures at that commit
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** (one small, well-localised fix). The change does what phase 1 promises: the recorded defect (a comment
or blank line inside a table) is found, the kit is clean after a one-line roadmap repair, every fixture behaves as written,
clean-run output is byte-identical, and `ritual-checks` is green. Against about 60 adversarial documents the scanner is quiet
on every ordinary shape I could construct (lists, blockquotes, fences, escaped pipes, alignment colons, CRLF, tabs, no edge
pipes, single column). It has one real false positive, though: a table whose first body row is made only of dashes
(`| - | - |`, a common "none" placeholder) is reported as a `severed-delimiter` and **fails the run**. Under plan D8/Risks a false
positive that fails adopters' CI is the one outcome the feature must not ship; F1 is a few-line fix plus one fixture. The
remaining findings are drift and minor notes. Certification is the owner's; nothing here claims the gate passed.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FR-001..004, 006..008) | FR-001: same `$docFiles` walk, `Get-FencedLineMap` skips fences (probe: comment/rows in backtick and tilde fences silent). FR-002: severed row named by file:line of the row (probe, fixtures `fail`, `fail-blank-row`, `fail-multiline-comment`); a new header+delimiter after a gap is not flagged (probe `new-table-after-gap`). FR-003: `fail-delimiter` (comment between header and delimiter), probe blank-then-delimiter, bare delimiter. FR-004: extra/missing cell, header/delimiter mismatch, code-span pipe counted (3 cells), `\|` not counted. FR-006: ERROR block with `file:line  Rule: detail`, `doc-lint: FAIL (N issue(s)...)`, exit 1. FR-007: see roadmap row. FR-008: 16 cases, one rule id (see F5). |
| Switch/loop logic | `$i++` inside the `switch` in the `for` loop works: the delimiter row is consumed with its header (probe: delimiter never re-examined). Only one clause matches per kind; `default` (fence/other) resets all three flags. Dot-sourced and run under `Set-StrictMode -Version Latest` with `$ErrorActionPreference='Stop'`: no error, including empty, `$null` and one-line input. |
| Table-shape probes: quiet (correct) | table in list item; directly after heading; directly after paragraph; blockquote rows; `\|` at row end (counts 2); alignment colons; `\| --- \| --- \|`; edge pipes omitted; single-column; table then non-pipe line then pipe row (GFM treats the text as a row, no severing); trailing whitespace; tab-indented rows; `<!--` inside a code span; fence inside a list item; 4-space-indented row after a comment (code block); header-like row + delimiter after a gap (new table, correct). |
| Table-shape probes: findings (correct) | two gaps in one table: one finding (first orphan row), not one per gap (by design, `$orphaned`); two separate orphan runs, each flagged once; code-span pipe makes an extra cell (as GitHub); empty-cell body row `\|\|` flagged ragged; delimiter with fewer cells than header flagged at the delimiter line. |
| CRLF / LF / BOM | CRLF lines (`\r` retained) give identical results (`Trim` and the `^ {0,3}\|` regex tolerate it); `doc-lint` reads with `ReadAllLines`, which strips a BOM, so a row on line 1 is not hidden. (Raw `Get-Content`-style callers passing a BOM-prefixed first line would miss a line-1 row; not a current caller.) |
| Cost | Largest doc (`specs/020.../notes.md`, 2657 lines): 110 ms. 12 000 synthetic lines: 390 ms. Whole `doc-lint` over the kit: about 2 s wall, no measurable change. Linear. |
| doc-lint output compatibility | `git archive` of parent and of `ef336c7` into scratch dirs, both run on the clean kit: output identical except the root path in line 1 (diff shows only that line); both exit 0. Code order: slot INFO, then missing-kit, manifest, broken-reference block, then the new structure block, then the FAIL roll-up; the new count is added to `$errCount` as one more term, so existing failure kinds print exactly as before and the roll-up merely sums. Put the pre-repair roadmap back under the new script: exactly one finding, `docs/roadmap.md:55 severed-row`, exit 1, `FAIL (1 issue(s)...)`. |
| Dot-source / layout | `. (Join-Path $PSScriptRoot 'markdown-lib.ps1')` run from `/` with `-Root` pointing at the archive: works. `kit-manifest.json` ships `scripts/*.ps1` as `verbatim`, so `markdown-lib.ps1` is covered and `doc-lint.ps1` already shared it with `enforcement-pack.ps1` and `build-digests.ps1` (no new dependency edge for adopters: they already have the library). |
| rules.json / emission-idioms | DOC-010 entry: id, script, anchor `$structure += ` present in doc-lint; one site, three conditions, plausible rationale; coverage reports 11 of 11 per implementer and the harness passes. `emission-idioms.json`: accumulator pattern and printer-header exemption added, correct. The `note` text was not updated and is now stale (F2). |
| Fixtures | Read all 16 flow.md bodies. Each `fail` differs from `pass` in exactly one condition; `pass-adjacent`, `pass-fenced`, `pass-tilde-fence`, `pass-indent4`, `pass-prose-pipes`, `pass-escaped-pipe` are legal near-misses per GFM (I reasoned each independently). Line numbers in the expected files are right (fail 11, blank-row 11, multiline 13, delimiter 9, mismatch 8, extra 10, missing 10). Expected texts include the file:line and the wording the script prints. CRLF fixture really holds `\r\n` (string form in the recipe). Weakness: F4. |
| Roadmap repair (FR-007) | `git show` diff: exactly one deleted blank line between GAP-024 and GAP-025; no other roadmap change. After it `doc-lint` over all 37 documents reports no finding, so the inventory is one table and no other document needed repair (SC-001 for the kit). |
| Feature contract held | No new file, package or script; only `markdown-lib.ps1` and `doc-lint.ps1` touched among scripts. Output OK line untouched. |
| Constitution / invariants | Constitution I: tasks.md diff is checkbox ticks only; no spec/plan edit, see Amendments. |
| Security | No external input, no execution of document content, no secrets; regexes are anchored and linear (timing above). N/A otherwise. |
| Scope guard | `scope-check.ps1` via `ritual-checks`: `PASS phase 1 commit ef336c7 (55 file(s))`. All touched paths are inside the Territory (`scripts/markdown-lib.ps1`, `scripts/doc-lint.ps1`, `tests/**`, `docs/roadmap.md`) plus the spec dir (implicit). `enforcement-pack` prints a non-blocking `PhaseSizeWarning` (2057 lines, 55 files), see F6. |
| Rollback safety | Phase reverts as one commit; no schema or data; the only prose change outside scripts is one roadmap blank line. |
| Re-run by me | `Run-Tests.ps1 -Case DOC-`: **103 passed, 0 failed** (matches the notes' 71 to 103). `pwsh -NoProfile -File scripts/ritual-checks.ps1`: RESULT OK (doc-lint, enforcement-pack, scope-check PASS, digests 5 fresh/88 markers, roadmap-claims, verify-kit n/a). Not re-run: the full harness (instructed not to run it in the working directory), so "1179 passed" and "coverage 11 of 11 / 218 of 230" are the implementer's record, consistent with +32 = 16 cases x 2 assertions. |

## Findings

### F1 — A dash-only first body row is reported as a severed delimiter and fails the run — BLOCKING

`Get-StructureFindings`, the `'row'` branch. After a header and its delimiter are consumed, the next line is tested with
`Test-StructureDelimiterRow` *before* any "am I inside a table" check, so any body row whose every cell is dashes (and optional
colons) is taken for a stray delimiter. In GFM a table's body rows are arbitrary, and `| - | - |` or `| -- | -- |` or `| - |` as
a "none yet" placeholder is ordinary.

Reproduction (dot-source `markdown-lib.ps1`):

```text
| a | b |
|---|---|
| - | - |        -> 3:severed-delimiter  "this delimiter row is not directly under a header row..."
| 1 | 2 |
```

Same result for `| -- | -- |` and for the single-column `| a |` / `|---|` / `| - |`. The line directly under a header is its
delimiter; any other delimiter-shaped row inside a live table (`$inTable` and no gap) is a body row.

Related, same root cause, quieter: a body row followed by a dash-only row is read as a *new header* (the `$startsTable` test does
not ask whether the first row is already inside a table), which resets `$cols` and is then compared against the following rows.
`| a | b |` / `|---|---|` / `| 1 | 2 |` / `| - | - |` / `| 3 | 4 | 5 |` has its ragged row judged against the wrong header and can
be missed or mis-named. No such row exists in the kit (SC-001 holds), so this is not visible on the kit, which is exactly why a
fixture is needed.

Impact: adopters' CI fails on a legitimate table, with a message that tells them nothing is wrong with the table. This is the
D8/Risks false-positive class and SC-004's measurement would only find it by luck.
*Action: implementer: when `$inTable -and -not $gap -and -not $orphaned`, treat a delimiter-shaped row as a body row (cell-count
check only) and do not start a new table from it or from the row above it; add a `pass-placeholder-row` fixture (header, delimiter,
`| - | - |`, a normal row) under DOC-010. Genuine severed delimiters (after a gap, after text, bare) stay flagged, so the existing
`fail-delimiter` expectations do not move.*

### F2 — emission-idioms.json note for doc-lint is stale — DOC DRIFT

`tests/enforcement/emission-idioms.json` line 110: "Four idioms ... Two accumulators ($manifestErrors, $broken ...) plus the two
conditions computed inline". With `$structure` there are three accumulators (and the site count in the note's history, "to 10", is
now 11). The accumulator pattern and exemption were edited but the argument the note makes was not, and this file's notes are
load-bearing by its own header.
*Action: implementer: update the note to three accumulators / five idioms and the site count; docs only, no harness change.*

### F3 — Two narrow disagreements with GitHub, both silent, not findings — MINOR

(a) A line that opens a comment and carries text after the close (`<!-- x --> text`) is classified `other`, which resets the
table state, so a table severed by such a line is not found (false negative; GitHub ends the table at the HTML block). Matches
the stated "comment-only line" definition (D3), so within spec; worth one line in `notes.md` as a known blind spot.
(b) `Get-StructureCellCount` removes `\|` before counting, so `\\|` (escaped backslash, then a real boundary) is counted as one
fewer cell than the author wrote; `| 1 \\| 2 |` under a 2-cell header reports `ragged-row` (1 cell). Whether GitHub also treats
`\\|` as an escaped pipe is renderer-dependent; D2 says "where renderers disagree the rule is silent", which this is not quite.
Rare; no instance in the kit.
*Action: owner/implementer: record both in notes.md as accepted blind spots, or treat `\\` as an escape in the count; no blocking.*

### F4 — Two fixtures cannot fail, and CRLF is only tested in the pass direction — MINOR

`pass-eof` (no trailing newline): `[IO.File]::ReadAllLines` does not distinguish a missing final newline, so this case passes
for any scanner and verifies nothing about the scanner; `pass-crlf` is real (the recipe carries `\r\n`) but no `fail` variant is
CRLF, so a regression that made CRLF documents blind to findings would stay green. The rules.json note lists the pair as "legal
near-misses", which overstates what they pin.
*Action: implementer: optional: add a CRLF copy of `fail` (expect the same file:line); keep or drop `pass-eof` but do not count it
as evidence.*

### F5 — One rule id carries sixteen variants, deviating from plan D6's wording — ACCEPTED

Plan D6 said "`DOC-010` onward, one pass and one fail per rule"; notes.md T002 explains the deviation (the coverage test sees one
site, `$structure +=`). Reasonable, disclosed in notes.md and in the rules.json note, and the fixtures are individually named by
condition. A reader of D6 alone would not expect it.
*Action: none; consider a one-line D6 amendment note at phase end, approved by the owner (not by the implementer).*

### F6 — Phase size warning — MINOR

`enforcement-pack` emits `PhaseSizeWarning: 2057 lines across 55 files` (constitution X guideline 400/15). Non-blocking and
explained by 16 fixtures at about 110 lines each (47 of the 55 files are fixtures); the script and doc changes are about 150 lines.
*Action: none; owner may want it noted for the review record.*

### F7 — notes.md evidence that I could not or did not confirm — MINOR

Not re-run: full harness (1179 passed), coverage counts (11 of 11, 218 of 230), the T001 baseline on a detached worktree, and the
prototype's "17 tables, one finding" measurement. The claim "expectations were written before the scanner" cannot be audited from
a single commit. Verified: 71 to 103 `DOC-` cases, kit doc-lint OK, one finding on the pre-repair roadmap (same line the notes
name). Also note the notes call the ragged rules "a block that renders differently from how it is written"; for an *under*-filled
body row GitHub pads the cell, so "ragged" is a strictness rule by FR-004, not strictly a rendering divergence (the doc-lint
header and ERROR wording say it grades these rules only; no overclaim of rendering, consistent with FR-011).
*Action: none beyond F1; the implementer's T017 isolated-checkout run should include the F1 fixture.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None.** `tasks.md` changes are T001..T007 checkboxes only; `spec.md` and `plan.md` are untouched. (F5 notes a disclosed
interpretation of D6 that would need an owner-approved note if recorded as an amendment.)

## Constitution re-check (post-implementation)

PASS with F1 open. The plan's Constitution Check still holds: one scanner in the shared library, no new script or package, no
architecture change, OK line unchanged, hand-written expectations with a passing and a failing fixture per condition (II/VII
engaged as planned). The check does not claim to render Markdown (FR-011 wording present in the doc-lint header and output).

## Test coverage observed

`tests/enforcement/cases/doc-lint/DOC-010`: 7 fail variants (comment between rows, blank row, multi-line comment, comment between
header and delimiter, delimiter/header mismatch, extra cell, missing cell) and 9 pass variants (marker after table, escaped pipe,
adjacent tables, backtick fence, tilde fence, 4-space row, pipe prose, EOF, CRLF); each asserts exit code and the full output.
Observed: `-Case DOC-` 103 passed. Gaps: dash-only body row (F1), CRLF in the fail direction and a vacuous EOF case (F4), a table
in a list item / blockquote (not required by the plan, probe-verified quiet), the pre-existing-format interaction with a slot
or broken-reference failure printed in the same run (not fixtured; code order verified by reading).

## Residual risk

Concentrated in F1: shipping as is risks failing an adopter's CI on a valid placeholder row, and phase 3's clone measurement
(SC-004) is the only net that would catch it. Fix it now while the scanner is small. F3 blind spots are silent (false negative) and
cheap. Nothing here changes the previously recorded kit result: the kit itself is clean and the roadmap repair is correct. Merge only
after F1 is fixed and re-reviewed, and the owner has run the gate.
