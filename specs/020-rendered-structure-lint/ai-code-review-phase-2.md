# AI Code Review — 020 Rendered-structure Lint, phase 2 (the list rule)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-11
**Branches**: kit repository `020-rendered-structure-lint` (phase commit `7b301b3`, parent `3d22585`)
**Scope reviewed**: `git show 7b301b3` in full: the new list loop in `scripts/markdown-lib.ps1` (`Get-StructureFindings`), `scripts/doc-lint.ps1`
(confirmed untouched), `tests/enforcement/rules.json` (DOC-010 summary and notes), the nine new `DOC-010` list fixtures
(recipe, command, expected), `tasks.md` and `notes.md` ("Phase 2: the list rule"); against `spec.md` (US3, FR-005, edge cases, SC-002,
SC-003), `plan.md` (D4, D6), `tasks.md` Phase 2 (T008-T012) and the phase 1 review (N1-N5, not re-reported). About 40 throwaway
documents were run through the scanner, dot-sourced, under `Set-StrictMode -Version Latest`, from the scratchpad directory.
**Feature contract**: no new script or package; the rule reports through the existing `$structure` accumulator (one site); existing
verdicts and fixtures unchanged (SC-003); Territory `scripts/markdown-lib.ps1`, `tests/**`, spec directory.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-sonnet-5-5 (separate session that produced the phase 2 commit)
- **Inputs provided**: phase 2 diff (`7b301b3`), spec.md, plan.md, tasks.md, notes.md, phase 1 review, the scripts and fixtures at that commit
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The rule is narrow and behaves as the spec asks: a column-zero comment followed (before any other
text) by a list item is a finding named by that item; blank lines, indented comments, fences, thematic breaks, paragraphs and
headings never produce one. I found no false positive on the shapes in the brief (blockquote, table cell, setext underline, `---`,
`***`, `- - -`, `_ _ _`, `2026.` aside, `1.5`, `-5 degrees`, lazy continuation, heading-then-comment, front matter, unclosed
comment, comment-then-text-then-item). One narrow false-positive class exists (F1: the item after the comment is a different list
type, so it would be a separate list with or without the comment), plus two harmless false negatives (F2). The fixtures are
correct, minimal and exercise what they claim, doc-lint.ps1 is unchanged, and the DOC- harness is green at 135. Certification is
the owner's; nothing here claims the gate passed.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FR-005, US3) | Comment-only line between two items is a finding (`fail-list` line 10, `fail-list-ordered-blank` line 11); blank-only separation is not (`pass-list-loose`, `pass-list-paren`). The measurement gate in FR-005/D4 is met: rule reports 0 on the kit (see next row). |
| Measurement (T008/T009) | Re-ran the rule over all 277 tracked `.md` files outside `tests/`: 0 `severed-list` findings (the only 6 findings are pre-existing `ragged-row` hits in review/prose files outside doc-lint's governance set, a phase 1 matter). `pwsh -NoProfile -File scripts/doc-lint.ps1`: OK on the 37 governance docs. The clones of the three adopted projects were not re-run by me; that part of the claim rests on the implementer. Arithmetic in notes.md checks out: 37 + 38 + 42 + 54 = 171. |
| doc-lint.ps1 unchanged | `git diff 3d22585 7b301b3 -- scripts/doc-lint.ps1` is empty. Output shape is the phase 1 `ERROR:` block (fixture expectations show it). |
| Existing table findings | `Run-Tests.ps1 -Case DOC-`: 135 passed, 0 failed (117 phase 1 plus 18 new), so all 16 prior DOC-010 variants and the other DOC cases behave identically. My probes: table + comment + row still yields only `severed-row`, no duplicate list finding; a pipe row inside a list item and a table directly after a list produce no list finding. |
| Fixtures (T010) | Read all nine flow.md bodies. Fail pair: `- one / - two / <!-- --> / - three` (line 10) and `1. one / blank / <!-- --> / blank / 2. two` (line 11); expected.txt line numbers match. Each pass differs from a fail by one condition: loose = ordered-blank minus the comment; comment-after = fail with the comment moved after the last item; comment-indented = fail with the comment indented; fenced = fail inside a fence; two-lists = fail with a paragraph between. `pass-list-paren` differs from `fail-list-ordered-blank` by two conditions (marker `1)` and no comment), but it is its own loose-list-with-parenthesis case, so acceptable. Expectations are hand-written plain text. |
| Fixtures really exercise the exclusions | Probed with the thematic exclusion removed from the item regex in a scratch copy: `- one / <!-- x --> / * * *` then fails (3 `*` separated by spaces match `^ {0,3}[-*+]\s+`), so `pass-list-thematic` passes for the right reason. `pass-list-two-lists`: the paragraph at column zero resets `$inList`, so the comment and `- two` are quiet (reasoned from the code, not mutation-tested). `pass-list-fenced`: the `fence` kind resets state (likewise reasoned, not mutation-tested). |
| Feature contract held | No new file, package or architecture; one loop added to the existing function; one accumulator. |
| Constitution / domain invariants | N/A beyond the contract; no amendment to approved documents (see below). |
| Security | N/A: read-only text scanner, no I/O added, regexes are linear (no nested quantifiers). |
| Scope guard | `pwsh -NoProfile -File scripts/scope-check.ps1`: `PASS phase 2 commit 7b301b3 (31 file(s))`. `scripts/ritual-checks.ps1`: RESULT OK (doc-lint, enforcement-pack, scope-check, digests, roadmap-claims OK; scope-repos and verify-kit n/a). |
| rules.json | Parses (`ConvertFrom-Json`), summary and notes edits accurate: the nine named variants match the nine fixtures (two failing, seven passing: loose, comment-after, comment-indented, paren, fence, thematic, two lists). |
| Rollback safety | One-commit revert removes the loop and fixtures; no schema, no data. |

Not re-run, by instruction: the full enforcement harness (implementer's record 1211 passed) and the isolated-checkout run (T017).
The adopted-project clones were not re-measured.

## Findings

### F1 — A comment between two lists of different type is reported though the comment changes nothing — MINOR

The rule fires on any list item after a column-zero comment, at any indent and with any marker. If the item is of a different
list type than the list above (bullet then number, or `-` then `+`), GitHub renders two lists with or without the comment, so
the finding is not about a *severed* list and the document is not rendering differently from what the author wrote. Plan D4 says
"two items at the same indent", which the code does not check either.

Reproductions (all report `3:severed-list`):
`- a / <!-- c --> / 1. b`; `- a / <!-- c --> / + b`; `- a / <!-- c --> / 2026. Something` (the last is a real ordered-list item
starting at 2026, so by the spec's own item definition it is a list item, just of another type). A deeper-indented `  - b` after
the comment also fires and that one is a true positive (the item was nested and now renders as a top-level list).

Likelihood is low (a digest marker between a bullet list and a numbered list, not separated by prose) and the effect is a failed
CI run with a message the author can resolve by moving the marker, so this does not block. Measured 0 on 171 documents.
*Action: implementer or owner may optionally record in notes.md as a known limit, or compare marker class (bullet char / number
delimiter) of the open list with the item after the comment and stay silent when they differ. Not required for merge.*

### F2 — Two conservative false negatives — MINOR

(a) A comment indented one to three spaces (` <!-- c -->`) is also an HTML block that ends the list in CommonMark, but the loop only
remembers comments that `StartsWith('<!--')`. `- a / " <!-- c -->" / - b`: no finding. (b) A tab-indented or one-space continuation
line (`\tnested`, or a lazy column-zero text line after an item) resets `$inList` because the continuation test is `^\s{2,}\S`.
`- a / <tab>- n / <!-- c --> / - b` and `- a / lazy / <!-- c --> / - b` (GitHub: lazy text continues the item, the comment still
ends the list) report nothing. Both err toward silence, which is the D2/D4 stance (where renderers or shapes are uncertain the rule
is silent), and the kit has none.
*Action: none; optionally mention in notes.md alongside the phase 1 limits.*

### F3 — notes.md wording: "no false positive" rests on a quiet measurement — MINOR

"No finding in 171 documents, so no false positive and, equally, nothing to repair" is correct arithmetic and the logic is sound
for the FR-005 gate, but a zero result cannot show absence of false positives on shapes the 171 documents do not contain
(F1 is one such shape). The synthetic-document check described right after it is the better evidence and is stated honestly.
The "0 of 17 tables ragged" figure is a phase 1 number I did not re-derive. The table in T012 says "1211 passed" for the full
harness; I did not re-run it, and it is correctly labelled as measured on the working tree, not the isolated checkout.
*Action: none required; the wording could say "no finding the rule should not make among 171 documents".*

### Confirmed behaviours (not findings)

- `<!-- c -->` directly after an item with no blank line (`- a / <!-- c --> / - b`) is reported. In CommonMark an HTML block of
  type 2 (`<!--`) may interrupt a paragraph and, at indent 0 (below the item's content indent), it closes the list; I am confident
  (about 90 percent; I could not run GitHub's renderer from here, so this is from the spec) that this matches GitHub, and the
  common separator idiom `- a / <!-- --> / - b` in the CommonMark spec is the same shape.
- Multi-line comment: reported at the item after the closing line. Two comments in a row, or comment, blank, item: reported.
  Nested list severed by a comment: reported at the nested item (now a top-level one).
- Unclosed comment: nothing reported (the rest of the document is the comment, as in phase 1 N1; no new interaction).
- Comment followed by text then an item, heading directly after a list then a comment then an item, setext underline, `---`,
  `***`, `- - -`, `_ _ _`, `1.5 is a number`, `-5 degrees`, `**bold**`, `*emph*`: quiet. `1.` alone and `-` alone after a comment
  count as empty items and are reported (correct: they are list items).
- Blockquoted lists (`> - a`, `> <!-- c -->`, `> - b`) are quiet (a false negative by design; lines starting with `>` are not items).
- A table cell holding `- x` or a comment, a pipe row inside a list item, and a list directly after a table: no list finding.
  A table severed by a comment yields only the table's `severed-row`, never a second list finding on the same line, because
  list items are lines that do not start with a pipe.
- Front matter: the `---` pair is not an item; a list after it behaves normally.
- Strict mode: the loop runs without unset-variable errors on every probe above.

## Amendments in this diff

- [x] None stated explicitly: `spec.md` and `plan.md` are unchanged in `7b301b3`; `tasks.md` changed only to tick the Phase 2 tasks
  (10 lines), `notes.md` is the phase record.

## Constitution re-check (post-implementation)

PASS. One site, one accumulator, no new script, no package, existing verdict path unchanged; the rule ships only because the
plan's measurement gate (D4, FR-005) was met, and that gate was run before the rule was written, as the task order requires.

## Test coverage observed

`tests/enforcement/Run-Tests.ps1 -Case DOC-`: 135 passed, 0 failed, 0 skipped (re-run by me, about 60 s). The new cases are the nine
`DOC-010` list variants (two failing, seven passing) at two assertions each. Critical assertions: exit code 1 plus the named
`docs/sdlc/flow.md:<line>  severed-list` line for the failing pair, exit code 0 plus the unchanged OK line for the passing ones.
Also re-run: `doc-lint.ps1` (OK), `scope-check.ps1` (PASS), `ritual-checks.ps1` (RESULT OK). Not re-run: the full harness, and the
isolated-checkout run.

## Residual risk

Low. The one realistic false-positive class (F1, list-type change across a marker) is rare, produces a clear message, and is
cheaper to resolve than to engineer around; the false negatives (F2) are conservative. Residual risk sits in renderer variance
(GitHub vs. other GFM renderers), which D2/D4 accept by design, and in the unverified-by-me adopted-clone measurement, which the
implementer recorded. Merge after the owner's gate decision on the phase.
