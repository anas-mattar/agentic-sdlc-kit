# Implementation Plan: Multi-line Code Spans

**Branch**: `016-multiline-code-spans` | **Date**: 2026-09-27 | **Spec**: specs/016-multiline-code-spans/spec.md
**Input**: Feature specification + research.md (R1–R5) + decisions D1–D8 below
**Gate Batching**: none
**Gate Certification**: ci-held

## Summary

Teach the one shared code-span function to see a span that wraps within a paragraph, and prove
it through both consumers before either trusts it. Then make the generator loud about any marker
it skips, so the next shape nobody modelled cannot cost a rule silently.

Three phases, each independently revertible. The fix and its proof land together in phase 1,
test-first in the sense 015's D11 defined: the cases are shown failing on the parent commit and
passing on the fix. Phase 2 adds the skipped-marker report, which is a new failure adopters can
see, so it is measured against all three adopted projects before it lands. Phase 3 tells
adopters and corrects the documents that describe the old behaviour.

The change reaches adopted projects as verbatim script updates. Research R2 predicts it changes
nothing they can see: one wrapped span holding a marker in 558 files, in a file neither consumer
reads. Phase 3 checks that prediction instead of assuming it.

## Technical Context

**Language**: PowerShell 7, the kit's only scripting surface. **Testing**: the feature-015
fixture harness (`tests/enforcement/`, Pester 5 pinned, real temporary git repositories,
hand-written literal expectations). **No new dependency.** The CommonMark renderer used in
research R1 was a measuring instrument in a scratch directory. It is not installed by the kit, and
no fixture expectation is computed with it. Every expectation is written by hand, as 015's D1
requires. **Target platform**: `ubuntu-latest` and `windows-latest`, both CI legs, as 015's SC-006
established. **Constraints**: every function in `scripts/markdown-lib.ps1` stays pure (no git, no
file system). A line with no backtick costs what it costs today. **Scale**: one shared library
(101 lines), two call sites, about ten new fixture directions.

**Phase-sizing**: three phases. Phase 1 is the whole behaviour change plus its proof, because a
fix without its cases cannot be reviewed and cases without their fix cannot be committed green.
Phase 2 is a separate new failure mode with its own adopter exposure, revertible without undoing
phase 1. Phase 3 changes no behaviour.

## Decisions

**D1 — One function, whole-document signature, length-preserving.** `Convert-CodeSpanMarkers`
changes from `-Line <string>` to `-Lines <string[]>`, returning the same number of lines, each the
same length as its input (research R3). There is no single-line wrapper. The only two callers
move to the new signature in the same phase, so no second implementation exists at any commit
(FR-001). Length preservation is what keeps `build-digests.ps1`'s substring arithmetic after a
comment closes correct.

**D2 — Paragraph pairing reuses today's pairing, over joined lines.** Within a paragraph that
holds both a backtick and a marker, the lines are joined with `"\n"` and today's algorithm runs
unchanged over the joined text: unescaped runs, pair with the next run of exactly the same
length, disarm between. The result is split back on `"\n"`. A backtick run cannot contain a
newline, so the join creates no false runs, and the reviewed pairing logic is reused rather than
rewritten.

**D3 — When in doubt, break the paragraph.** FR-003's block starts are recognised generously: any
indentation before a list marker, block quote or table row counts, and so do setext underlines
and any line beginning with an HTML tag. Every extra break moves the result back toward today's
per-line behaviour, which is the reviewed baseline, and never beyond it. A line where the
generous rule and a renderer disagree therefore costs at most what it costs today.

**D4 — HTML comment blocks are found on the raw text and left exactly as today.** A block opens on
a line whose first non-space text (at most three spaces of indent) is `<!--` and ends on the first
line, the opening line included, whose raw text holds `-->` after the opener (research R1, row 3).
Its lines join no paragraph. Each keeps today's single-line treatment, so every existing case that
touches such a line is unaffected (FR-004).

**D5 — `build-digests.ps1` precomputes, then indexes.** `Get-DocMarkers` reads the file once, calls
the function once for the whole document, and inside its loop reads `$scanLines[$i]` in place of
calling the function per line. After a comment closes mid-line, it takes the same substring of the
precomputed line (`$scanLines[$i].Substring($close + 3)`). The comment state machine, the fence
state machine and the grammar checks that read `$rawLine` do not change.

**D6 — Cases join existing rules as named directions, and the one new failure is a new rule.** The
digest cases are new directions under DIGEST-001, beside GAP-025's pair: the wrapped-span document
with a correct digest (`pass-wrapped-span`) and with the rule missing (`fail-wrapped-span`). The
amendment cases are new directions under AMEND-001: a visible record after a wrapped span
(`pass-wrapped-span`), and two guards, `fail-hidden-after-unpaired` (no-fail-open, FR-006) and
`pass-comment-block-backticks` (the HTML comment block, FR-007: the record follows the block and
must stay visible). The digest consumer's comment-block guard is `pass-comment-block-backticks`
under DIGEST-001. A guard earns its place only by failing under D7(b), so each is shaped to be
sensitive to it. The skipped-marker report of phase 2 is a new rule, **DIGEST-020**, with `pass`
and `fail` directions and F2's document as a third direction (`fail-f2-shape`). Each rule's
`notes` field in `rules.json` is updated to count and name its directions, as AMEND-001's
already does.

**Amendment approved by**: anas.m, 2026-09-30

**D7 — Two mutations, recorded.** SC-004 is shown with two local mutation runs recorded in
`notes.md`: (a) the fix reverted, where every case the fix turns green must fail; (b) the paragraph
boundary removed, where every guard must fail, which proves the guards can see an over-reaching
fix. A guard that passes under (b) is rewritten until it fails there.

**D8 — The skipped-marker report fails, and names itself distinctly.** A line matching the digest
marker grammar that `Get-DocMarkers` passes over because `$inComment` is set produces
`skipped digest marker: <path>:<line> — it sits inside a comment opened earlier in the file`.
The run fails, following the fail-closed precedent of DIGEST-005 (015 review F6/F7). The message
does not begin with `malformed digest marker:`, so the two rules keep distinct emit anchors for the
coverage check (FR-008, FR-009). A marker commented out on purpose is deleted instead, and the
flow-down note says so.

**D9 — A doubtful paragraph keeps per-line pairing, and raw HTML blocks end where CommonMark
ends them (phase-1 review F1).** Paragraph pairing may reach further than per-line pairing only
where every backtick in the paragraph can be read as a span delimiter. Two shapes break that. A
backslash touching a backtick: backslash escapes do not apply inside a span, so the run scan
misreads a span's closer. And a construct that binds before a span on the same line: a `<` that
opens a tag, autolink or comment, or a link destination `](`, before a backtick. A paragraph
holding either keeps per-line pairing, the reviewed baseline. Raw HTML blocks end by CommonMark's
rule, not at the next blank line: `pre`, `script`, `style` and `textarea` blocks at their closing
tag, a processing instruction at `?>`, a declaration at `>`, CDATA at `]]>`, and any other tag
at a blank line. Their lines keep per-line pairing throughout. Both rules only move the result
toward per-line pairing, never beyond it, which is D3's direction. They are proved by three
AMEND-001 fail directions built from the review's documents, each shown passing on `7a770e5`
(the fail-open) and failing on the fix. Two more mutations are recorded beside D7's: (c) the
paragraph fallback removed, and (d) the raw HTML block ends removed.

**Amendment approved by**: anas.m, 2026-09-30

**D10 — Disarm only an opener that cannot be a comment (supersedes D2, D3 and D9; phase-1
round-2 review F1).** Pairing spans across lines could not be made safe by listing exceptions.
Two review rounds found backticks the scan misreads, in constructs that open on one line and
hold their backtick on the next, and each misread let the pairing disarm a real comment.
`Convert-CodeSpanMarkers` now returns today's per-line result (`Convert-SpanText` on each line).
It then disarms a `<!--` that result left armed only when all three of these hold:
- the line is not fenced;
- the line is not in a raw HTML block, an HTML comment block included. Such a block is tracked
  from a line whose first text, after any list or block-quote markers, is a tag, to that block's
  CommonMark end: a `pre`, `script`, `style` or `textarea` block at its closing tag, a comment at
  its closer, a processing instruction at `?>`, a declaration at `>`, CDATA at `]]>`, and any
  other tag at a blank line;
- no `-->` appears in the raw text after the opener (from its third character) through the line
  before the next blank line.

No renderer reads such an opener as a comment, so disarming it reveals only text a reader sees,
and the result is otherwise the parent's. D1 and D4-D8 stand; D7(b) no longer describes an
over-reach this design can make, and is replaced by the two mutations below. Proved by four
AMEND-001 fail directions: three from the round-2 review's documents (a), (b) and (h), each
shown passing on `6f75415`, and one guard with a comment opened inside a raw HTML block and
left open across a blank line. Also by a DIGEST-001 pass direction for round-1 F2's second
document, which D10 fixes. Mutations recorded beside D7's: (e) the closer check removed, so
every inline opener is disarmed, where the no-fail-open cases must fail; (f) the raw HTML
exclusion removed, where the raw-HTML-block cases must fail.

**Amendment approved by**: anas.m, 2026-09-30

**D11 — The fix is the digest consumer's only; the amendment consumer keeps the per-line
reading (phase-1 round-3 review; spec US2 as amended).** Three rounds showed that any change to
how the amendment check reads a document can let a hidden record count. Round 3's F2 shows why
no version of D10 can be proved safe there. The parent's unterminated-comment rule also hid text
that renderers hide for other reasons, such as a tag attribute or a link title spanning lines,
so disarming even an opener that is truly not a comment can reveal such text.
- `Get-VisibleFromText` goes back to the parent's reading: `Convert-SpanText` on each non-fenced
  line. That function's logic is byte-identical to the parent's per-line function, bar its name
  and comments. The amendment check's result then equals the parent's on every document.
- `Get-DocMarkers` keeps `Convert-CodeSpanMarkers` (D10), with the round-3 F1 fixes:
  - a line is blank only when it is spaces and tabs;
  - a line that starts a block ending somewhere other than a blank line switches the tracker to
    that end. That covers a `pre`, `script`, `style` or `textarea` block, a comment, a
    processing instruction, CDATA and a declaration. It applies even inside a block that ends at
    a blank line, and even on a line the fence map calls fenced.
  - a document with no opener the rule could disarm returns the per-line result before the
    tracker runs (FR-010 as amended).
- **Cases.**
  - AMEND-001 `pass-wrapped-span` is replaced by `fail-wrapped-span-hidden`. It is the same
    document, expects FAIL, and pins the limitation.
  - DIGEST-001 gains a guard for each D10 safety rule, in the digest direction. Each holds a
    marker inside a real comment that the generator must not harvest, with a correct digest on
    disk. They are `pass-hidden-nbsp-line`, `pass-hidden-pre-under-tag-line`,
    `pass-hidden-pre-in-misread-fence`, `pass-hidden-html-block-open` and
    `pass-hidden-after-backslash-spans`.
  - The AMEND-001 no-fail-open cases stay, guarding the unchanged reading.
- **Mutations** are recorded beside D7's, each failing the digest guard it names: (e) the closer
  check removed; (f) the raw HTML exclusion removed; (g) blank read as .NET whitespace; (h) the
  long-end override removed. A further check compares `Get-VisibleFromText` with the parent's
  on every `.md` file in the kit and the three adopted projects: equal on every file.

**Amendment approved by**: anas.m, 2026-09-30

**Amended after the phase-1 round-5 review** (round-5 F1, F3). The digest tracker of
`Convert-CodeSpanMarkers` makes four changes beyond the bullets above, and each is named here:
- **Return to the enclosing block.** When a block with a longer end closes inside a block that
  ends at a blank line, the tracker goes back to the blank-ending block, not to inline text.
- **Blank-ending starts on fenced lines.** A start of a block that ends at a blank line is
  honoured on a line the fence map calls fenced, as the long-end starts already are.
- **Ends after the container markers.** A block's end is read on the line with its list and
  block-quote markers removed (round-4 `c1`). This change has no guard, by the owner's
  acceptance of round-5 F2; it only keeps more lines in HTML.
- **A raw-text element opened later on a tag line.** A tag line that opens `pre`, `script`,
  `style` or `textarea` after its first tag takes that element's end. The tag line itself starts
  a block that ends at a blank line, so when the element closes the tracker returns to that
  blank-ending block (round-5 F1). Only a line that is itself a `pre`, `script`, `style` or
  `textarea` start returns to inline text.
- **Mutation (n)**, recorded beside (e)-(m): the tag-line start returns to inline text instead
  of the blank-ending block. It fails the round-5 F1 guards.

**Amendment approved by**: anas.m, 2026-10-01

**Amended after the phase-1 round-6 review** (round-6 F1, F2; the review approved, the owner
asked for both minor findings to be fixed in phase 1):
- **The raw-text-start exclusion is guarded** (round-6 F1). A line that is itself a `pre`,
  `script`, `style` or `textarea` start returns to inline text when its element closes. A
  DIGEST-001 direction with a visible marker after a closed `<pre>x</pre>` line and a wrapped
  span pins it. **Mutation (o)** removes the exclusion and fails that direction.
- **A raw-text element is closed only when the last one the line opens is closed** (round-6
  F2). A line that closes one of the four elements and opens another after it, such as
  `<div><script>a</script><script>` or `</script><script>`, keeps the element's end. This holds
  both on the line that starts the block and on a later line that would end it. **Mutation (p)**
  goes back to "the line holds an end tag" and fails the round-6 F2 guards.
- **Not modelled, named:** raw-text elements other than the four (`title`, `xmp`, `iframe`,
  `noembed`, `noframes`; round-6 `q04`) stay on the per-line reading. The library's "Not
  modelled" paragraph names them.

**Amendment approved by**: anas.m, 2026-10-01

**Amended after the phase-1 round-7 review** (round-7 F1). The reopen rule above is
**withdrawn**. Keeping the element open past a line where CommonMark ends its block hid the
blocks that start inside it, and the close then returned to inline text, so a real comment's
opener was disarmed (round-7 `b04`-`b09`). That breaks FR-003; the reopen it fixed does not, since
what hides the marker there is a script, not a comment.
- **A raw-text end counts wherever it falls on the line**, as on `517f9d2`. `Test-HtmlBlockEnd`
  and mutations (p), (p1), (p2) are removed.
- **The raw-text-start exclusion stays guarded**: `pass-wrapped-after-closed-pre` and mutation
  (o) are kept.
- **Not modelled, named:** an element closed and reopened on one line (round-6 `q01`-`q03`),
  besides the other raw-text elements and the reopen forms round-7 F2 lists (`<script/>`, an end
  tag inside an attribute, an end tag of another element, `noscript`, `plaintext`). A marker
  inside such an element may be harvested. One DIGEST-001 case pins the reopen: the digest that
  carries only the visible rule is read as stale.
- **Guards**: round-7 `b04` (div inside the reopen), `b08` (the reopen on a later line) and `b09`
  (a PI past a blank line) become DIGEST-001 `pass-hidden-*` cases, each harvesting the hidden
  marker on `c565240`.

**Amendment approved by**: anas.m, 2026-10-01

## Constitution Check

Source: `.specify/memory/constitution.md` (version 0.7.0).

- [x] **Specification First (I)**: `spec.md` is written, and the owner approved its content on
      2026-09-27. The Draft → Approved flip is deferred to the joint spec-and-plan approval
      commit, as 015 did, so the correction this plan made to the spec (see Complexity
      Tracking) lands before the amendment rule starts. `tasks.md` follows this file.
- [x] **Source of Truth (II)**: No conflict. Research R1 corrects a claim in 015's review (F2's
      reproduction). A review is not a rung, and the correction is stated openly in the spec.
- [x] **Repository Separation (III)**: N/A. The kit is a single governance repository with no
      `codeRepos` declared.
- [x] **Architecture Consistency (IV)**: No new dependency, no new manifest class, no new script.
      One shared function changes signature, and both callers move with it in one phase.
- [x] **Domain Invariants (V)**: N/A. The kit declares no domain-invariants pack.
- [x] **Security (VI)**: No secrets, no network at run time. The one hazard is a fail-open in
      amendment grading, which FR-006's guard and D7(b)'s mutation exist to exclude.
- [x] **External Integration Governance (VII)**: N/A. No external integration.
- [x] **Testing Requirements (VIII)**: Every behaviour change arrives with pass and fail cases in
      the harness, shown failing on the parent commit and backed by two recorded mutation runs.
- [x] **Human Review (IX)**: Every phase takes a fresh-context AI review with the Reviewer
      Provenance block, then human review before merge. Phase 1's review brief names the
      fail-open direction explicitly.
- [x] **Controlled Delivery (X)**: Three phases, one at a time, each its own commit with a declared
      Territory. `ci-held` certification, declared here before the first phase.

## Project Structure

### Documentation (this feature)

```text
specs/016-multiline-code-spans/
├── spec.md
├── plan.md              # this file
├── research.md          # R1-R5, the measured evidence
├── tasks.md
├── notes.md             # per-phase evidence: parent-commit runs, mutation runs, flow-down measurements
├── checklists/requirements.md
├── ai-code-review-phase-N.md   # per phase, from specs/_templates/
└── human-pr-review.md          # at merge, from specs/_templates/
```

No `data-model.md`, `contracts/` or `quickstart.md`. The feature adds no data, no external
interface and no new command. The function's contract is D1, and the key entities are defined in
the spec.

### Source Code (repository root)

```text
scripts/markdown-lib.ps1                 # MOD  phase 1 — paragraph-aware Convert-CodeSpanMarkers (D1-D4); header corrected (FR-012)
scripts/enforcement-pack.ps1             # MOD  phase 1 — Get-VisibleFromText calls the whole-document form
scripts/build-digests.ps1                # MOD  phase 1 — precompute and index (D5); phase 2 — the skipped-marker report (D8)
tests/enforcement/cases/enforcement-pack/AMEND-001/**   # NEW directions, phase 1 (D6)
tests/enforcement/cases/build-digests/DIGEST-001/**     # NEW directions, phase 1 (D6)
tests/enforcement/cases/build-digests/DIGEST-020/**     # NEW rule, phase 2 (D6, D8)
tests/enforcement/rules.json             # MOD  phases 1-2 — direction notes; DIGEST-020
adoption/updating.md                     # MOD  phase 3 — the flow-down note (FR-011)
```

**Structure Decision**: Everything the feature changes already exists, except the DIGEST-020 case
directory. `tests/` is `kit-only` (015's D3) and never flows down. The three scripts do, as
verbatim files.

## Testing Strategy

- **Proved against the parent commit, not against itself.** Phase 1's green-turning cases are run
  against the parent commit's scripts and shown failing, then against the fix and shown passing
  (015's D11). Both runs go in `notes.md`.
- **Guards proved by the mutation they guard against** (D7(b)). A no-fail-open guard that cannot
  fail under an over-reaching fix measures nothing.
- **Expectations are hand-written.** No expected output is produced by running the code under
  test or the research renderer (015's D1).
- **The whole suite, both platforms.** Every pre-existing case must stay green on both CI legs
  (SC-003). 015's keeper is that a check green on one platform proved nothing about the other.
- **Adopter reality before shipping.** Phase 2 runs the generator against all three adopted
  projects before its commit (SC-007). Phase 3 regenerates their digests and runs `ritual-checks`
  (SC-005, FR-011).

## Complexity Tracking

| Addition | Why needed | Simpler alternative rejected because |
|---|---|---|
| A paragraph model inside the shared function (D3, D4) | A span may only pair within its paragraph, or it disarms real comments in later blocks (FR-003, 014's H1) | Pairing across the whole document is the H1 fail-open. Pairing across adjacent lines without a boundary rule breaks multi-line HTML comments that work today (research R1, row 3) |
| The skipped-marker report (D8) | F2's shape stays a comment-model disagreement after the fix. Without the report it keeps costing a rule silently | Fixing the comment model to agree with a renderer changes the unterminated-comment rule amendment grading relies on (research R1, alternatives) |

**A spec correction this plan made, before approval.** Research R1 showed that the spec's first
draft promised 3 of 3 markers on F2's document, which a code-span fix cannot deliver: that
document's loss comes from the comment model. It also showed the HTML comment block needs its own
boundary. The spec was corrected on this branch while still Draft (US1 scenario 3, FR-003,
FR-005, FR-007, SC-001, SC-004, Context, Edge Cases, Out of Scope). The owner's approval of the
joint spec and plan covers the corrected text.

**The risk this plan carries knowingly.** D8 introduces a new failure in a verbatim script. An
adopted project with a digest marker inside a comment would go red on its next update. Phase 2
measures all three before landing, and phase 3's flow-down note names the rule and the remedy.
