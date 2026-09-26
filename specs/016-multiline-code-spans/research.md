# Research: Multi-line Code Spans

**Feature**: `specs/016-multiline-code-spans/spec.md` | **Date**: 2026-09-27

Every finding below was measured, not recalled. The scratch tools used to measure them are not
part of the kit and are not dependencies of this feature.

## R1 — What a CommonMark renderer shows

**Method**: `markdown-it-py` (CommonMark preset) installed into a session scratch directory,
four documents parsed, and the block and inline tokens printed.

| Document | Renderer's reading | Today's kit reading |
|---|---|---|
| A span wrapping inside one paragraph, holding `<!--`, then a marker in its own block | The span is `code_inline` (its `<!--` is code). The marker is an `html_block` | The backtick pairs with nothing on its line, so `<!--` stays armed and the marker is swallowed |
| F2's document: an unpaired `` ` `` + `<!--` in prose, then a marker line, then the closing backtick | Line 3 is plain text: no `code_inline`, no `html_inline`. Both markers are `html_block`s | `<!--` armed, the middle marker swallowed: 2 of 3 |
| A line beginning with `<!--` and holding a backtick, a next line holding `-->` and another backtick | One `html_block` ending at the `-->` line. The backticks mean nothing | Correct, because per-line reading never pairs the two backticks |
| A wrapped span holding `a <!-- b`, followed by more prose in the same paragraph | One `code_inline` spanning the line break | `<!--` armed |

**Decision**: pair code spans across the lines of a paragraph (row 1). Keep HTML comment blocks
out of any paragraph (row 3). Treat F2's shape (row 2) as a comment-model question outside this
feature's scope, and make its loss loud instead (spec FR-009).

**Alternatives considered**: a full inline scanner that resolves code spans and inline comments
by left-to-right precedence, as CommonMark does. It would also get F2's shape right. Rejected for
this feature because it changes the comment model that both consumers rely on, including the
unterminated-comment rule (J5) that amendment grading depends on to fail closed. That is its own
decision, recorded for the owner as a new gap.

## R2 — Exposure today

**Method**: a paragraph-aware scan (blank lines, fences and block-start lines end a paragraph)
of every `.md` file in the kit and the three adopted projects, looking for a code span whose
opening and closing runs fall on different lines and which holds `<!--` or `-->`.

**Result**: 558 files, **1** hit: `specs/014-amendment-authority/ai-code-review-phase-3.md:365`. Neither consumer reads
that file: it is not a digest source, and review files are not among the paths amendment
authority grades. The defect is latent in all four repositories.

**Consequence**: SC-005 predicts byte-identical digests everywhere after the fix, and the
flow-down (FR-011) is expected to change no adopter's verdict. Both predictions are checked,
not assumed, in the last phase.

## R3 — Where the rule is called

| Caller | How | What it needs from the shared function |
|---|---|---|
| `enforcement-pack.ps1` `Get-VisibleFromText` | Holds the whole document as lines and a fence map. Disarms fenced lines itself, calls the span function per unfenced line | A whole-document call returning the same lines, disarmed |
| `build-digests.ps1` `Get-DocMarkers` | Streams lines with its own fence and comment state. Calls the span function per line **for the comment-state update only**, including on the remainder of a line after a comment closes (`$line.Substring($close + 3)`) | A per-line result it can index into, with offsets preserved so the substring still lines up |

Both needs are met by one function that takes a document's lines and returns the same number of
lines, each the **same length** as its input. `Disable-CommentMarkers` already preserves length,
which is what makes the offset arithmetic safe.

## R4 — Fence detection differs between the two consumers

`Get-FencedLineMap` closes a fence on any line whose leading run is the same character and at
least as long. `build-digests.ps1` also requires that nothing but whitespace follows the closing
run, which is what CommonMark specifies. The two disagree only on a line such as
<code>```&nbsp;text</code> inside an open fence. This feature does not reconcile them. The span
function uses `Get-FencedLineMap` to find paragraph breaks, and `build-digests.ps1` keeps its own
fence state for skipping. On the one line where they disagree, the effect is at worst a paragraph
break where a renderer has none, which falls back to today's per-line behaviour (plan D3). This
is recorded here so a reviewer does not rediscover it as a finding.

## R5 — Cost

014's SC-006 measured a per-character walk over every line at about 9× the whole check's
runtime, which is why today's function returns early on any line without a backtick or a
marker. The paragraph-level version keeps that shape at two levels: a document with no backtick
or no marker returns its input unchanged, and so does a paragraph with no backtick or no marker.
Only paragraphs holding both are scanned, with the same regex run-matching as today over the
paragraph's lines joined by newlines (a backtick run cannot contain a newline, so the join adds
no false runs). No child process is added. Wall-clock timing on this machine is too noisy to
quote (±10 s on a 20 s script, measured during feature 014), so SC-006 is reported as the
deterministic cost plus a statement that the delta is inside the noise.
