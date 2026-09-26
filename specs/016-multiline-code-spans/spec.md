# Feature Specification: Multi-line Code Spans

**Feature Branch**: `016-multiline-code-spans`  
**Created**: 2026-09-27  
**Status**: Draft  
**Delivery Level**: Standard  
**Input**: User description: "Close GAP-028: carry inline code-span state across the lines of a paragraph so a code span that wraps onto a later line cannot leave a comment marker armed and silently swallow content, proven on both consumers (digest harvest and amendment-authority grading)"

## Context

Two kit checks need to know which text a reader can see. `build-digests.ps1` harvests the
digest markers a document carries, and `enforcement-pack.ps1`'s amendment-authority check
counts only the approver records a reader can see (constitution I). Both depend on the same
question: is this `<!--` a comment opener, or literal text inside code? Both answer it with one
shared function, `Convert-CodeSpanMarkers` in `scripts/markdown-lib.ps1`, which feature 015
extracted so the answer could not drift between them.

That function reads **one line at a time**. CommonMark lets an inline code span run across the
lines of a paragraph, and the kit's prose is hard-wrapped at about 95 columns, so a span that
starts near the end of a line often closes on the next one. When such a span holds a `<!--`,
the function sees an unpaired backtick, leaves the marker armed, and the reader opens a phantom
comment. The next literal `-->` anywhere closes it, and everything in between disappears. No
message is printed. That is GAP-025's symptom in the one shape GAP-025's fix does not reach.

The two consumers fail in different directions, which is why both need a proof:

- **Digests** fail open. A swallowed marker drops a real rule from the digest, and the
  generator reports OK.
- **Amendment authority** fails closed today. A swallowed approver record makes a legitimate
  amendment impossible to approve (014's B7 was this shape). A careless fix could turn it into
  a fail-open: carry the span state too far, disarm a *real* comment, and a hidden record
  starts counting as a grant (014's H1 was this shape).

**Measured exposure (2026-09-27).** Scanning the kit and the three adopted projects (558
Markdown files) finds exactly one multi-line code span holding a comment marker:
`specs/014-amendment-authority/ai-code-review-phase-3.md:365`. Neither consumer reads that file. The defect is latent,
which is the right time to close it. The roadmap row (P1) and the 2026-09-27 decisions-log
entry authorize this feature, and feature 015's phase 2 review (finding F2) is where it was
found.

**A correction to the recorded reproduction.** F2 demonstrated the failure on a document whose
marker line began with `<!--`. In CommonMark a line that begins with `<!--` starts an HTML
block, which ends the paragraph above it, so the backtick before it pairs with nothing and the
code span F2 described is not one a renderer would show. Measured with a CommonMark renderer
(markdown-it-py, 2026-09-27): the `<!--` on F2's line 3 renders as **plain text**, neither code
nor comment, and all three markers render as real comments. What swallows the middle marker is
therefore not the code-span rule. It is the kit's comment model, which treats an unclosed `<!--`
as hiding everything after it, and that model is out of scope here. So two different shapes are
in play:

- **The code-span shape** (GAP-028 proper): a span wrapping *within one paragraph* holds a
  `<!--`, and a marker follows after the paragraph ends. A renderer shows the span as code. This
  feature fixes it: the marker is harvested (US1, scenario 1).
- **F2's shape** (the comment model): an unpaired `<!--` in prose. This feature does not change
  how the kit reads it. It stops the loss being **silent**: the generator names the skipped
  marker and fails (US3, and US1 scenario 3).

The renderer also shows why the paragraph boundary is a requirement (FR-003). A multi-line HTML
comment ends at the first line containing `-->`, whatever backticks it holds, so a span may never
pair across those lines either.

**Amendment approved by**: anas.m, 2026-09-27

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A digest keeps every rule its author marked (Priority: P1)

A maintainer writes law prose that mentions the marker syntax inside a code span. The line
wraps, so the span closes on the next line. Further down the document they add a digest marker.
The generated digest must contain that rule, exactly as it would if the span had fit on one
line.

**Why this priority**: This is the fail-open direction. A digest that silently drops a rule is
wrong while every check stays green. It is the harm GAP-025 was opened to prevent.

**Independent Test**: Generate the digest for a fixture document that has a wrapped code span
holding `<!--` followed by a digest marker, and confirm that every marker is harvested.

**Acceptance Scenarios**:

1. **Given** a paragraph whose code span opens on one line, holds `<!--`, and closes on the next
   line, followed by a separate digest marker, **When** digests are generated, **Then** the
   marker appears in the digest and the run reports OK.
2. **Given** the same document with the digest on disk missing that rule, **When** the digest
   check runs, **Then** it reports the digest as stale, and does not report OK.
3. **Given** F2's recorded document (an unpaired `<!--` in prose, the marker on the next line),
   **When** digests are generated, **Then** the run fails and names the skipped marker's file and
   line. It does not report OK with a marker missing, as it does today.

---

### User Story 2 - An approver record is counted exactly when a reader can see it (Priority: P1)

An owner approves an amendment to a feature document that, earlier on, quotes the comment syntax
in a code span that wraps across lines. The approver record they add must count. A record that
really is inside a comment must never count, however the code spans around it are shaped.

**Why this priority**: The same defect, in the check that decides who approved a change to
approved law. The fix must remove the fail-closed trap without opening the fail-open that
014's H1 already paid for once.

**Independent Test**: Grade a fixture commit that adds a conforming approver record after a
wrapped code span holding `<!--`, and confirm the amendment check passes. Grade a second
commit whose record sits inside a real comment and confirm it fails.

**Acceptance Scenarios**:

1. **Given** an approved feature document with a wrapped code span holding `<!--` and, after
   it, a newly added conforming approver record named in the commit message, **When** the
   amendment check grades the commit, **Then** it passes.
2. **Given** the same document where the record sits inside a real HTML comment, **When** the
   check grades the commit, **Then** it fails for a missing visible record.
3. **Given** a paragraph with an unpaired backtick run, followed by a later paragraph holding a
   real comment that contains a record, **When** the check grades the commit, **Then** the
   record stays hidden: a span never reaches across the paragraph boundary to disarm the
   comment.

---

### User Story 3 - A marker the generator skips is never skipped silently (Priority: P2)

Whatever hides a digest marker, whether a shape this feature does not model or a real comment
someone forgot to close, the maintainer is told. The generator names the file and line of any
line shaped like a digest marker that it passed over because it sat inside a comment.

**Why this priority**: This is defence in depth for the whole class. Stories 1 and 2 close the
shape that was found. This story makes the next unmodelled shape loud instead of silent, the
same principle as 015's UNGRADED state and build-digests' existing near-miss rule. It is P2
because the P1 fix alone closes GAP-028.

**Independent Test**: Generate digests for a fixture where a digest marker sits inside an
unclosed comment, and confirm that the run fails and names that line.

**Acceptance Scenarios**:

1. **Given** a digest marker line inside a comment opened earlier in the document, **When**
   digests are generated or checked, **Then** the run fails and names the file and line of the
   skipped marker.
2. **Given** a document where every marker is outside any comment, **When** digests are
   generated, **Then** no such report appears.

---

### Edge Cases

- **The span wraps inside a list item.** A continuation line of the same list item is the same
  paragraph, so the span closes there. A new list item begins a new paragraph.
- **The paragraph ends before the span closes** (blank line, fence, heading, list item, block
  quote, table row, a line beginning with `<!--`, a thematic break). The opening run pairs with
  nothing, so it is a literal backtick and the markers after it stay armed, as they are today.
- **Multi-backtick spans** (opened by two or more backticks) pair only with a run of the same
  length, across lines as on one line.
- **Escaped backticks** (a backslash before the backtick) delimit nothing, across lines as on one line.
- **A `-->` inside a wrapped span** is disarmed too, so it cannot close a real comment early.
- **Inside a real comment**, backticks mean nothing: a backticked `-->` there really does close
  the comment. build-digests already handles this and it must stay that way.
- **A multi-line HTML comment block** (a line beginning with `<!--`, running to the first line
  holding `-->`) is not a paragraph. A backtick on its first line and another after its `-->` do
  not pair, so the `-->` still closes it. Per-line reading gets this right today by accident, and
  a paragraph-wide fix must not break it.
- **Fenced blocks** keep their existing handling. A fence line ends any open paragraph.
- **Lines with no backtick at all**, the overwhelming majority, must cost no more than they do
  today (014's SC-006 found that a per-character walk over every line cost about 9× the whole
  check's runtime).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The kit MUST keep exactly one implementation of the code-span rule, shared by
  both consumers. No consumer may carry a private copy or a private patch.
- **FR-002**: A code span whose opening and closing backtick runs fall on different lines of
  the same paragraph MUST be recognised, and every comment marker (`<!--` and `-->`) inside it
  MUST be treated as literal text by both consumers.
- **FR-003**: A code span MUST NOT extend beyond its paragraph. A paragraph ends at a blank line,
  a fence line, or a line that begins a new block: an ATX heading, a list item, a block quote, a
  table row, a line beginning with `<!--`, or a thematic break. The lines of an HTML comment
  block, from a line beginning with `<!--` through the first line holding `-->`, belong to no
  paragraph, so no span pairs into or out of them. Each of their lines keeps exactly today's
  single-line treatment, and the block's end is found on the raw text. An opening run with no partner
  before the paragraph ends opens no span.
- **FR-004**: Everything the single-line rule does today MUST continue to hold: run-length
  pairing, escaped backticks, fenced blocks, and the unterminated-comment rule. Every existing
  harness case MUST pass unchanged.
- **FR-005**: The harness MUST carry, for each consumer, a case where the wrapped span holds
  a marker and the result is correct (pass), and the nearest case where the condition under test
  fails. Each case the fix is meant to turn green MUST be written first and shown failing on the
  current code before the fix lands. Each guard case, one that holds today and must keep holding
  (FR-006, FR-007), MUST be shown passing on the current code.
- **FR-006**: The harness MUST carry a no-fail-open case for the amendment consumer: a record
  inside a real comment stays hidden when unpaired backtick runs sit in earlier paragraphs
  (US2, scenario 3).
- **FR-007**: The harness MUST carry F2's recorded document as a case for the digest consumer,
  expecting the skipped-marker report of FR-009 (US1, scenario 3). It MUST also carry the
  HTML-comment-block case from Edge Cases for both consumers, expecting the result the current
  per-line code already gives.
- **FR-008**: Any rule this feature adds or changes MUST enter the rule inventory with a passing
  and a failing case, and the coverage check MUST grade it as it grades every other rule.
- **FR-009**: The digest generator MUST report, by file and line, any line shaped like a digest
  marker that it skipped because the line sat inside a comment, and the run MUST fail. The
  report MUST be distinct from the existing malformed-marker message (US3).
- **FR-010**: Lines with no backtick MUST take no additional work. The change MUST add no child
  process to any check.
- **FR-011**: Before the feature ships, digests MUST be regenerated and ritual-checks run on the
  kit and on all three adopted projects. Any digest or verdict that changes MUST be named in an
  `adoption/updating.md` flow-down note. If nothing changes, the note MUST say so.
- **FR-012**: On ship, GAP-028 MUST be recorded as closed, and the comment in the shared library
  that describes the rule as per-line MUST be corrected. So must any kit text that still claims
  GAP-025 is closed without qualification.

### Out of Scope

- Full CommonMark conformance. Indented code blocks, setext headings, lazy continuation lines
  and inline raw-HTML semantics keep their current handling. Where the paragraph model differs
  from a renderer, the difference is recorded in the plan, not modelled.
- The kit's comment model itself (what counts as a comment once code is excluded), including
  the unterminated-comment rule. It disagrees with a renderer on F2's shape (an unpaired `<!--`
  in prose is plain text to a renderer). This feature makes that disagreement loud (FR-009) and
  records it as a new gap for the owner. It does not resolve it.
- Other document readers (territory parsing, doc-lint path extraction), which do not use the
  shared function.

### Key Entities

- **Paragraph**: a run of consecutive non-blank lines that no block-starting line interrupts.
  It is the unit within which a code span may wrap.
- **Code span**: a backtick run and the next run of exactly the same length, both unescaped and
  both in the same paragraph. The text between them is literal.
- **Comment marker**: `<!--` or `-->`. It is armed outside code and literal inside it.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The wrapped-paragraph document yields **every** marker harvested (today one is
  lost). F2's recorded document yields **zero** silent losses: its skipped marker is reported by
  file and line and the run fails (today: 2 of 3 harvested, and OK).
- **SC-002**: Across the amendment consumer's new cases, **zero** records inside a real comment
  are counted, and **every** visible record after a wrapped span is counted.
- **SC-003**: **Every** harness case that existed before this feature passes unchanged, on both
  CI platforms (Windows and Linux).
- **SC-004**: **Every** case the fix turns green fails again when the fix is reverted, and
  **every** guard case fails when the paragraph boundary is removed (the over-reaching fix). Both
  are shown by recorded mutation runs, because a guard that passes without its fix measures
  nothing (015's keeper).
- **SC-005**: Regenerated digests for the kit and the three adopted projects are
  **byte-identical** to the committed ones, except where a marker was previously swallowed. The
  2026-09-27 scan predicts no such case.
- **SC-006**: Every check spawns the same number of child processes, and the per-run time
  difference stays within this machine's measurement noise, reported as such rather than as a
  number.
- **SC-007**: The generator's skipped-marker report finds **zero** occurrences across the kit
  and the three adopted projects at ship time. Any it does find are resolved in the flow-down.

## Assumptions

- CommonMark is the reference for what counts as a code span and a paragraph. GitHub renders
  CommonMark with GFM extensions, and GFM's table rows are treated as block starts (FR-003).
- The fixture harness from feature 015 (`tests/enforcement/`, real temporary git repositories,
  hand-written expectations, `rules.json` inventory with coverage grading) is the proving
  ground. No new test infrastructure is needed.
- Standard, not Critical: the feature changes kit tooling, not a regulated or high-risk domain.
  It does touch the amendment-authority check, so the no-fail-open case (FR-006) is mandatory
  rather than optional.
- The skipped-marker report (FR-009) fails the run rather than warning, following the precedent
  of build-digests' existing near-miss rule (015 review F6/F7). A maintainer who comments a marker
  out on purpose deletes it instead.
- The adopted projects receive the change as verbatim script updates through the normal
  flow-down. No constitution amendment is needed.
