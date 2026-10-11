# Notes: Rendered-structure Lint (020)

Phase evidence, measurements and decisions. Not an approved document: `tasks.md` holds the agreed work, this
holds what happened.

## Phase 1: the table rules

### T001: baseline on the parent commit

Taken on an isolated detached worktree of the parent commit (the approved-`tasks.md` commit), so no edit of
this working tree could reach it.

| Measurement | Value |
|---|---|
| `Run-Tests.ps1 -Case DOC-` | 71 passed, 0 failed (every DOC fixture plus the harness's own structure tests) |
| Full harness | **1147 passed**, 0 failed, 0 skipped, `enforcement-tests: OK` |
| Coverage for `doc-lint.ps1` | 10 of 10 site(s) fixtured |
| `doc-lint.ps1` | `OK`, 37 documents scanned, 79 shipped files classified, 115 unfilled-slot markers (information) |

The throwaway prototype (a scratchpad script, not committed) was run over the 37 scanned documents before any
code was written: 17 tables, **one** finding, none ragged — `docs/roadmap.md` line 55, the row after the blank
line that follows the GAP-024 row of the inventory table. It was checked against a synthetic document (an extra
cell and a code-span pipe flagged, an escaped pipe not) so a quiet result could not be a dead scanner.

### T002: the fixtures, shown failing on the parent

`DOC-010`, 16 cases built from the clean-kit recipe of `DOC-009/fail` with `docs/sdlc/flow.md` replaced:

| Direction | Variants |
|---|---|
| `fail` (7) | comment between two rows (the recorded defect), blank line between rows, multi-line comment block between rows, comment between header and delimiter, header and delimiter disagreeing on cell count, extra cell, missing cell |
| `pass` (9) | marker after the table (the nearest state), escaped pipe, two adjacent tables, backtick fence, tilde fence, row indented four spaces, prose that starts with a pipe, table ending the file with no newline, CRLF document |

Run against the parent commit before the scanner existed (`-Case DOC-010`): the seven `fail` variants fail (14
assertions: exit code and output), all nine `pass` variants pass, and the two coverage tests that name the
missing anchor fail. Each failing fixture therefore fails for the stated reason and the passing ones are
legal near-misses, not accidents of the old script.

Expectations are hand-written: the ERROR text and the `file:line` of each finding were written before the
scanner and are not generated from its output.

One site, one rule. Plan D6 said "`DOC-010` onward"; the scanner returns findings and `doc-lint.ps1`
accumulates them in one place (`$structure +=`), so the coverage test sees one site. One rule with sixteen
variants, not one rule per finding. Phase 2's list rule, if shipped, adds variants to `DOC-010` for the same
reason.

### T004/T005: the scanner and the wiring

`Get-StructureFindings` (with two small helpers) is appended to `scripts/markdown-lib.ps1`; `scripts/doc-lint.ps1`
dot-sources the library, collects the findings per document into `$structure`, prints them under one `ERROR:`
block after the manifest and slot lines, and counts them into the existing `FAIL` roll-up. The OK line is
**unchanged** (plan D5): it now also means no structure finding, and no existing expectation moves.

### T006: the repair

`docs/roadmap.md`: the blank line inside the inventory table is removed (one line). The scanner then reports
nothing on any of the 37 documents, so no other document needed a repair.

### T007: results

Run on this working tree after the repair (the isolated-checkout run of the final commit is T017):

| Measurement | Parent | Phase 1 |
|---|---|---|
| `-Case DOC-` | 71 passed | 103 passed (+32 = 16 cases x 2 assertions) |
| Full harness | 1147 passed | **1179 passed**, 0 failed, 0 skipped, `enforcement-tests: OK` |
| Coverage, `doc-lint.ps1` | 10 of 10 | 11 of 11 site(s) fixtured |
| Coverage, whole | 217 of 229 | 218 of 230 (the new site, fixtured; exemptions unchanged) |
| `doc-lint.ps1` on the kit | OK | OK, no structure finding |
| `ritual-checks.ps1` | n/a | doc-lint, enforcement-pack, digests, roadmap-claims OK; scope-check graded on the commit |

Every pre-existing case is unchanged: the difference between the two full runs is exactly the 32 new
assertions.

### Phase 1 review remediation (review: `ai-code-review-phase-1.md`, REQUEST CHANGES)

F1 (blocking), F2, F3 and F4 fixed; F5 to F7 left as recorded.

- **F1.** Inside a live table (no gap since the last row) every row is a body row, a row of dashes included:
  only after a gap, or outside a table, can a header or a delimiter start. `| - | - |` as the first body row
  was reported as `severed-delimiter`, which would have failed an adopter's CI on a valid table, and a body row
  followed by a dash-only row reset the header's cell count. New fixtures: `pass-placeholder-row`,
  `pass-placeholder-single-column`, `fail-placeholder-ragged` (a three-cell dash row under a two-cell header is
  a ragged row, line 9).
- **F2.** The `doc-lint.ps1` note in `emission-idioms.json` now says five idioms and three accumulators and
  names `$structure`.
- **F3.** A line that *starts* with a comment opener is an HTML block that ends at the line holding the closer,
  whatever follows it, so it ends a table like a comment-only line (`fail-comment-with-text`). A backslash now
  escapes the next character, so an escaped backslash followed by a pipe leaves the pipe as a boundary
  (`pass-escaped-backslash`); the old count removed only the two-character sequence for an escaped pipe.
- **F4.** `pass-eof` cannot fail on its own (the line reader hides a missing final newline), so the same
  severed table is added with no trailing newline (`fail-eof`) and with CRLF endings (`fail-crlf`), putting both
  conditions in the failing direction too. These two pass on the pre-fix scanner by design: they are
  regression cover, not new behaviour.

Run on the pre-fix scanner (the library file stashed), the five behaviour fixtures fail (`-Case DOC-010/<name>`:
two failed assertions each, one for `fail-placeholder-ragged`, whose exit code was already 1), and `fail-eof`
and `fail-crlf` pass. With the fix, `-Case DOC-` is 117 passed, 0 failed (103 plus 14 = 7 cases x 2), and the full harness on this
working tree is **1193 passed**, 0 failed, 0 skipped, `enforcement-tests: OK` (1179 plus the same 14), with
`doc-lint.ps1` still 11 of 11 sites fixtured.

## Phase 2: the list rule

### T008: the measurement

A throwaway prototype of the rule (a scratchpad script, not committed): a list item is a line starting, after at
most three spaces, with `-`, `*`, `+` or a number and `.` or `)`, then whitespace; a column-zero comment while a
list is open, followed by another list item before any other text, is a candidate. Run over the same document
set `doc-lint.ps1` scans, in the kit and in clones of the three adopted projects (cloned `--no-hardlinks` into a
scratch directory; the real projects were not touched).

| Tree | Documents scanned | Candidate findings |
|---|---|---|
| The kit | 37 | **0** |
| ExpenseTracker clone | 38 | **0** |
| FitForge clone | 42 | **0** |
| FlowBoard clone | 54 | **0** |

To show a quiet result is not a dead scanner, the same prototype was run on a synthetic document holding an
unordered and an ordered list each split by a column-zero comment, a loose list, and a comment indented into an
item: it reported exactly the two split lists and nothing else.

### T009: the decision

No finding in 171 documents, so no false positive and, equally, nothing to repair. Plan D4 says to ship the rule
only if the measurement reports nothing that is not a genuinely severed list; it reported nothing at all, so the
rule ships. It guards a defect that none of the four trees currently has, which is the honest reading: it is
the same preventive rule as the table check was for ragged rows (0 of 17 tables ragged). One refinement the
measurement did not need but the review of phase 1 taught: a thematic break (`* * *`, `- - -`) is not a list
item, so it is excluded.

### T010: the fixtures, shown against the parent

Nine variants added to `DOC-010` (same site, same rule): `fail-list` and `fail-list-ordered-blank` as the failing
pair, and `pass-list-loose`, `pass-list-comment-after`, `pass-list-comment-indented`, `pass-list-paren`,
`pass-list-fenced`, `pass-list-thematic`, `pass-list-two-lists` as the legal near-misses. Run before the rule
existed, each `fail` fails (it expects a finding the scanner did not yet make) and all seven `pass` variants
pass. (`-Case DOC-010/fail-list` also selects `fail-list-ordered-blank`, as the filter is a substring, so it
reported 4 failed assertions: 2 per fail variant.)

### T011: the rule

`Get-StructureFindings` gains a second loop (plan D4): a list item opens a list; a comment line starting at
column zero while a list is open is remembered; the next list item before any other text is a `severed-list`
finding, named by that item. Blank lines, indented continuation lines and a comment indented into an item
never end a list; any other text at column zero does; fenced lines reset it; a thematic break written with
spaces is excluded from the item test. The finding is reported through the same `$structure` accumulator and
the same `ERROR:` block, so `doc-lint.ps1` is untouched in this phase, and `rules.json`'s `DOC-010` summary and
note now mention lists.

### T012: results

| Measurement | Phase 1 (after remediation) | Phase 2 |
|---|---|---|
| `-Case DOC-` | 117 passed | 135 passed (+18 = 9 cases x 2) |
| Full harness | 1193 passed | **1211 passed**, 0 failed, 0 skipped, `enforcement-tests: OK` |
| Coverage, `doc-lint.ps1` | 11 of 11 | 11 of 11 (no new site: one accumulator) |
| `doc-lint.ps1` on the kit | OK | OK, no list finding (matches the measurement: 0) |

Every pre-existing case is unchanged: the full-run difference is exactly the 18 new assertions. Run on this
working tree; the isolated-checkout run of the final commit is T017.
