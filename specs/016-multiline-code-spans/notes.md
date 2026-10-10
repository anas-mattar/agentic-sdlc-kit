# 016 Multi-line Code Spans — phase evidence

Evidence and decisions that are not themselves law. This file is not graded by the amendment
rule (constitution I grades `spec.md`, `plan.md`, `tasks.md` and `contracts/` only), which is
why recording evidence here never costs an approver record.

## Approval

**2026-09-27 — the owner approved `spec.md` and `plan.md`.** The spec content was first approved
in session as "approved". The plan then corrected that Draft spec (research R1: F2's shape is a
comment-model loss, and HTML comment blocks need their own boundary), and the owner approved the
corrected spec and the plan together in session as "go ahead". The approval covers:

- the spec as corrected in `806db42`, including its Out of Scope list (full CommonMark
  conformance, the comment model and its unterminated-comment rule, other document readers);
- **D1** — `Convert-CodeSpanMarkers` changes signature to `-Lines`, with no single-line wrapper;
- **D8** — the new DIGEST-020 failure in a verbatim script, which fails rather than warns;
- the three-phase sequence and `**Gate Certification**: ci-held`;
- no new dependency. The CommonMark renderer used in research R1 was a scratch measuring tool,
  not a kit dependency.

The spec's `**Status**` line moved `Draft` → `Approved` in the same commit as this record. That
transition is the act that *starts* the amendment rule rather than a change to an approved
document, so it owes no approver record (constitution I, and the exemption feature 014 shipped
as D3d). The commit is kept to exactly that shape so the exemption applies as written.

## Phase 1 — a wrapped code span hides nothing

### The guards as planned could not see an over-reaching fix

Before any case was written, each planned guard was traced under D7(b), the mutation it exists
to catch (spans paired across the whole document). Two of the planned shapes would have passed
under it, and so measured nothing:

- **T005 as written** put the record *inside* the HTML comment block and expected FAIL. The
  over-reaching fix only hides more, so the record stays hidden and the case still passes. The
  shape that can fail puts the record *after* the block and expects PASS: a correct reader shows
  it, and the over-reaching fix disarms the block's `-->` so the unterminated-comment rule hides
  it. Built as `AMEND-001/pass-comment-block-backticks`.
- **T002 as written** (a comment block holding backticks, then a marker) cannot fail under
  D7(b) at all. `build-digests.ps1` closes a comment by reading the **raw** line, not the
  disarmed one, so pairing across the block changes nothing it harvests. The digest guard became
  sensitive by giving the block's closing line a second backtick: the over-reaching fix pairs
  the first-line backtick with the first closing-line one, leaves the second unpaired, pairs it
  into a later paragraph, and leaves that paragraph's `<!--` armed, so the last marker vanishes.

Both changes alter case names and one expected verdict in `tasks.md` (T002, T005) and plan D6,
so they need the owner's amendment record before the phase commit.

### T006 — the cases against the parent commit's scripts

Run on the unchanged scripts (`e10da18`) with `tests/enforcement/Run-Tests.ps1 -Case <filter>`:

| Case | Expected on the fix | On the parent | Meaning |
|---|---|---|---|
| DIGEST-001 `pass-wrapped-span` | OK, exit 0 | **FAIL** (exit and output) | the defect is real: a correct digest called stale |
| DIGEST-001 `fail-wrapped-span` | stale, exit 1 | **FAIL** (the check said OK) | the fail-open direction: a stale digest called fresh |
| AMEND-001 `pass-wrapped-span` | pass, exit 0 | **FAIL** | a visible record hidden: 014 B7's shape |
| DIGEST-001 `pass-comment-block-backticks` | OK | pass | guard holds today |
| AMEND-001 `pass-comment-block-backticks` | pass | pass | guard holds today |
| AMEND-001 `fail-hidden-after-unpaired` | FAIL, exit 1 | pass | guard holds today (no-fail-open) |

`-Case wrapped-span`: 33 passed, 6 failed (the three green-turning cases, two assertions each).
`-Case comment-block-backticks`: 37 passed, 0 failed. `-Case hidden-after-unpaired`: 35 passed,
0 failed. The other passes in each run are the harness's own self-tests and coverage checks,
which run on every filter.

On the fix: `wrapped-span` 39/0, `comment-block-backticks` 37/0, `hidden-after-unpaired` 35/0.

### T010 — comments, and the FR-012 text outside Territory

The per-line descriptions are corrected in the `scripts/markdown-lib.ps1` header and the
`Disable-CommentMarkers` / `Convert-CodeSpanMarkers` comments, the GAP-025 comment in
`scripts/build-digests.ps1`, and the helper note in `scripts/enforcement-pack.ps1`. Each says
what is modelled (pairing within a paragraph) and what is not (a `<!--` opened mid-line in
prose that runs on into later lines).

FR-012 also asks, on ship, for GAP-028 to be recorded as closed and for kit text claiming
GAP-025 closed without qualification to be corrected. The only live text is the GAP-028 row
in `docs/roadmap.md` (line 58), which is already the qualification. The 015 documents that say
"GAP-025 closed" are that feature's records and are not rewritten. `docs/roadmap.md` is in no
phase's Territory, so closing the row needs either an owner-approved Territory amendment for
phase 3 or the main-side docs PR that T026 already plans. Not edited here.

### T012 — the full suite on the fix

`pwsh -File tests/enforcement/Run-Tests.ps1`, run by the owner on 2026-09-30 against the working
tree holding T007-T011 (PowerShell 7, Pester 5.7.1): **817 passed, 0 failed, 0 skipped**,
`enforcement-tests: OK`, 586 s. The six 016 cases are in that count, and no pre-existing
expectation was edited in this phase (`git diff` touches no existing `expected.txt`), so every
pre-existing case passed unchanged (SC-003). The exit code was not captured separately; the
runner's `OK` verdict is what it prints only on exit 0.

### T013 — the two mutations (D7, SC-004)

Run 2026-09-30 through the harness (pwsh 7.6.6, Pester 5.7.1) by a scratch script that backs up
the three scripts, applies each mutation, runs the named cases and restores them; the restore was
hash-checked against the backup (`True`).

| Mutation | What changes | Cases | Result |
|---|---|---|---|
| (a) | the three scripts reverted to `e10da18` (T007-T009 undone), today's tests | `-Case wrapped-span`: 3 cases | **all 3 fail**, both assertions each; 33 passed, 6 failed, exit 1 |
| (b) | no paragraph boundary: `Convert-CodeSpanMarkers` pairs spans over the whole document joined | `-Case comment-block-backticks`: 2 cases | **both fail**; 33 passed, 4 failed, exit 1 |
| (b) | as above | `-Case hidden-after-unpaired`: 1 case | **fails**; 33 passed, 2 failed, exit 1 |

Every green-turning case fails without the fix, and every guard fails under the over-reaching
fix, so no guard survived (b) and none needed rewriting. Under (b) `fail-hidden-after-unpaired`
fails by counting the hidden record as a grant, which is the fail-open direction it guards. The
33 passes in each run are the harness's own self-tests and coverage checks.

### T014 — cost (FR-010, SC-006)

Deterministic cost: child processes per check are unchanged. `scripts/markdown-lib.ps1` starts no
process, `Get-VisibleFromText` and `Get-DocMarkers` each make one call where they made one per
line, and neither caller gained a git or process call.

Wall clock, `pwsh -File scripts/build-digests.ps1 -Check` on the kit, three runs each on this
machine: parent `0.57 0.54 0.51` s, fix `0.64 0.58 0.59` s. The means differ by about 0.06 s,
which is the same size as the spread within each set of three. Three samples cannot separate a
cost that small from noise, so it is reported as at most tens of milliseconds on the digest
check, not as zero. The amendment check was not timed separately; it calls the same function.

The T002/T005 and D6 amendment was approved by the owner on 2026-09-30 and committed alone as
`85c8650`, before this phase's commit; `enforcement-pack.ps1` graded it (4 of 4 commits, OK).

## Phase 1 remediation — the review's F1 (plan D9)

The fresh-context review of `7a770e5` (`ai-code-review-phase-1.md`, REQUEST CHANGES) found that
paragraph pairing let a record inside a real HTML comment count as a grant (F1, 014's H1 shape).
The owner approved plan D9 and tasks T014a-T014d on 2026-09-30, committed alone as `44f6c94`.

### T014a — the fail-open, shown on the unremediated fix

Three AMEND-001 fail directions from the review's documents, run on `7a770e5` with
`Run-Tests.ps1 -Case <name>`: `fail-hidden-backslash-closer`, `fail-hidden-autolink-backtick` and
`fail-hidden-pre-block` each **fail as cases**, because the check printed `enforcement-pack: OK`, exit
0, for a record no renderer shows. The fail-open is real.

### T014b-T014c — the fix and the comments

`Convert-CodeSpanMarkers` pairs a paragraph as one text only when no line has a backslash
touching a backtick, or a `<` opening a tag, autolink, comment or declaration, or a link
destination, before a backtick. Otherwise the paragraph is paired line by line. Raw HTML blocks
now run to their CommonMark end, so a `pre` block no longer ends at a blank line. The review's F3
sentences are corrected: the phase-2 report is described as scoped, not present; the header no
longer claims a stray backtick cannot disarm a real comment; the raw HTML description matches
the code. AMEND-001's `notes` in `rules.json` name the three new directions.

**A cost D9 accepts, for the owner to see.** The rule treats a comment opener before a backtick
as doubtful, as approved. So a span that wraps with its opener on the *second* line, before the
closing backtick, gets per-line pairing and is not fixed. In that shape, one line holds the
opening backtick, and the next holds the comment opener followed by the closing backtick. That is
the fail-closed direction (the amendment check hides; the
digest check loses the marker, which phase 2's report is scoped to name). The committed cases
put the opener on the first line and stay fixed. This note first said that narrowing the rule to
exclude the comment opener looked safe on analysis. **That claim was wrong, and is withdrawn.**
The round-2 review refuted it with shape (h): the shifted pairing arms a `-->` inside a real
code span, which ends a comment early and exposes the record. Its one-line form (i) reopens
under the narrowing (`ai-code-review-phase-1-round-2.md`, F1).

### T014d — suite and mutations

On the remediated scripts, run 2026-09-30 (pwsh 7.6.6, Pester 5.7.1):

- Full suite: **823 passed, 0 failed, 0 skipped**, `enforcement-tests: OK`, exit 0 (817 before,
  plus the three new cases at two assertions each).
- Mutation (c), the doubtful-paragraph fallback removed (`$doubtful` set to a pattern that never
  matches): `-Case backslash-closer` 33 passed, 2 failed, exit 1; `-Case autolink-backtick` 33
  passed, 2 failed, exit 1. Both cases fail.
- Mutation (d), the `pre`/`script`/`style`/`textarea` block end removed, so such a block ends at a
  blank line again: `-Case pre-block` 33 passed, 2 failed, exit 1. It fails.
- The library was restored and hash-checked after each mutation (`True`).
- The targeted 016 runs on the fix: `fail-hidden-` 43/0 (five cases), `wrapped-span` 39/0,
  `comment-block-backticks` 37/0.

### Review F2 and F4 — dispositions

- **F2** (the paragraph reading can arm a marker the per-line reading disarmed): D9 closes its
  first document. That line quotes the opener in a span, so it is doubtful and paired per line,
  and both markers are harvested again. The second document is **still open**. It is the D5
  tail after a mid-line comment close, and 1 marker is harvested where the parent got 2: D5
  takes the tail from the whole line's pairing, and the parent paired the tail alone. No file in
  the kit or the three adopters has the shape (the review's scan). **The owner decides** between
  two options. One is to accept it as covered by phase 2's DIGEST-020 report and add that
  document as a DIGEST-020 direction. The other is an amendment to D5 that re-pairs the tail on
  its own, as the parent did.
- **F4** (fail-open shapes that predate 016: a fence info string holding a backtick, F1's shapes
  kept on one line, a backtick pair inside a `div` block): not in this feature's scope. They are
  drafted beside T026's gap for the owner's main-side docs PR.

### Round-2 review, and the owner's F2 decision

The fresh-context round-2 review of `7a770e5` + `6f75415` (`ai-code-review-phase-1-round-2.md`)
is **REQUEST CHANGES**. Its F1 is BLOCKING: D9 judges doubt one line at a time, so the round-1
fail-open is still reachable through eight shapes, (a)-(h). Each counts a record as visible on
`6f75415` that both renderers hide and `e10da18` hides. The implementer reproduced all eight
through `Get-VisibleFromText`.

**F2, owner's decision, 2026-09-30**: the D5 tail loss is accepted as covered by phase 2's
DIGEST-020 report, which names a marker skipped because a comment is open. Whether F2's second
document joins DIGEST-020 as a direction is a change to T016, proposed to the owner when phase 2
starts.

## Phase 1 round-2 remediation — the redesign (plan D10)

The owner approved spec FR-002/FR-003, plan D10 and tasks T014e-T014h on 2026-09-30, committed
alone as `b58d3f3`. D10 supersedes D2, D3 and D9. It returns the parent's per-line pairing,
then disarms only an opener that no renderer can read as a comment. It was prototyped in scratch
before the owner decided, and the prototype and the committed code give identical results on
every document below.

### T014e-T014f — the cases, on `6f75415`

`Run-Tests.ps1 -Case <name>` against `6f75415`'s scripts:

| Case | On `6f75415` | Meaning |
|---|---|---|
| AMEND-001 `fail-hidden-list-div` (round-2 shape a) | fails as a case: the check said OK | the fail-open is real |
| AMEND-001 `fail-hidden-list-pre` (shape b) | fails as a case | the fail-open is real |
| AMEND-001 `fail-hidden-comment-tick` (shape h) | fails as a case | the fail-open is real |
| AMEND-001 `fail-hidden-html-block-open` (guard) | passes | holds there, and on the parent |
| DIGEST-001 `pass-tail-after-close` (round-1 F2, second document) | fails as a case: stale | the marker loss is real |

### T014g — the rewrite

`Convert-CodeSpanMarkers` is per-line `Convert-SpanText` on every line, plus the D10 rule. Paragraph
pairing and the D9 doubt pattern are gone. The comments that described paragraph pairing are
corrected in all three scripts (round-2 F3): the library header, the function comment, the
`Convert-SpanText` comment, the two `build-digests.ps1` comments and the two
`enforcement-pack.ps1` comments. Round-2 F4 (two D9 alternatives unguarded) no longer applies,
because D9's pattern is removed. The DIGEST-001 and AMEND-001 `notes` in `rules.json` name the
five new directions.

### T014h — suite, mutations, D1, and the review documents

Run 2026-09-30 (pwsh 7.6.6, Pester 5.7.1), scripts backed up and restored by hash (`True`):

- Full suite on the fix: **833 passed, 0 failed, 0 skipped**, `enforcement-tests: OK`, exit 0
  (823 before, plus five cases at two assertions each).
- Mutation (a), the three scripts reverted to `e10da18`: `-Case wrapped-span` fails all 3 cases
  (6 failed assertions), exit 1. `-Case tail-after-close` **passes** on the parent. That is
  expected, because the parent paired the tail alone and harvested both markers. The loss was
  introduced by 016's first design, so this case guards against 016 regressing, not against
  the fix being reverted.
- Mutation (e), the closer check removed so every inline opener is disarmed: `-Case fail-hidden-`
  fails 3 of 9 (6 assertions), exit 1. By name: `fail-hidden-autolink-backtick`,
  `fail-hidden-backslash-closer` and `fail-hidden-comment-tick`.
- Mutation (f), the raw HTML exclusion removed: `-Case fail-hidden-` fails 2 of 9 (4
  assertions), exit 1. By name: `fail-hidden-html-block-open` and the pre-existing
  `fail-hidden-record`.
- `fail-hidden-list-div` and `fail-hidden-list-pre` fail under neither mutation, because the closer
  check alone keeps their records hidden. They guard against paragraph pairing returning, and
  they failed on `6f75415`, which is what they are for.
- D1 over all 233 `.md` files in the kit: 0 violations of line count or line length.
- Every review document from rounds 1 and 2 was run through `Get-VisibleFromText`. All 21 that
  hide the record in a renderer are hidden, including the eight round-2 shapes (a)-(h) and the
  narrowing shape (i). The two where a real code span holds the record (`x-multirun`,
  `x-pre-sameline`) are also hidden, as the parent hides them. That is the fail-closed
  direction, a fix not made rather than a regression.
- Four more documents put a comment inside raw HTML and leave it open across a blank line: a
  `div`, a `div` in a list item, a `pre`, and a `div` in a block quote. All four stay hidden,
  and all four become visible under mutation (f).
- Round-1 F2's two documents: both markers are harvested for each. The owner's decision to leave
  F2 to phase 2 stands as recorded, and it is now moot for these two documents.

## Phase 1 round-3 remediation — the fix is the digest generator's (plan D11)

The round-3 review of `8e45e37` (`ai-code-review-phase-1-round-3.md`, committed as `1960f51`) is
**REQUEST CHANGES**. Its F1 found three ways D10 still counted a hidden record as visible: a tag
line masking a `pre` block, a misread fence masking one, and a Unicode "blank" line. Its F2 showed
something deeper. The parent's unterminated-comment rule also hid text that renderers hide for
other reasons (a tag attribute, a link title), so disarming even a true non-comment opener can
reveal it. The implementer's earlier claim that D10 was "safe by construction" was wrong, and is
withdrawn with the comments that made it (round-3 F5).

The owner chose the digest-only fix and approved spec US2 as amended, plan D11 and tasks
T014i-T014l on 2026-09-30, committed alone as `6e7e902`.

### T014i — the digest guards, on `8e45e37` and the parent

`Get-DocMarkers` harvest against the digest on disk (both carry the two markers outside the comment):

| DIGEST-001 case | `8e45e37` | `e10da18` |
|---|---|---|
| `pass-hidden-nbsp-line` | harvests 3 — **wrong** | 2 |
| `pass-hidden-pre-under-tag-line` | harvests 3 — **wrong** | 2 |
| `pass-hidden-pre-in-misread-fence` | harvests 3 — **wrong** | 2 |
| `pass-hidden-html-block-open` | 2 | 2 |
| `pass-hidden-after-backslash-spans` | 2 | 2 |

Through the harness on `8e45e37`, `-Case pass-hidden-` fails 3 of the 5 cases (6 assertions).

### T014j — the amendment check keeps the parent's reading

`Get-VisibleFromText` calls `Convert-SpanText` on each non-fenced line. Compared with `e10da18`,
comments aside, the function differs in one line: the call names the per-line helper, whose body
is identical to the parent's `Convert-CodeSpanMarkers -Line` bar its name and its parameter's
name (`-Line` became `-Text`; the round-4 review corrected this note). On every `.md` file in
the kit and the three adopted projects, **566 files**, this branch's `Get-VisibleFromText`
returns exactly what the parent's returns: **0 differ**. AMEND-001 `pass-wrapped-span` is now
`fail-wrapped-span-hidden`. It is the same document, expects FAIL, and pins the limitation.

### T014k — the digest rule's round-3 fixes

These are in `Convert-CodeSpanMarkers`:
- a blank line is spaces and tabs only (`^[ \t]*\r?$`);
- a block start whose end is not a blank line switches the raw HTML tracker, even inside a
  blank-ending block and on a line the fence map calls fenced. That covers `pre`, `script`,
  `style` and `textarea`, a comment, a processing instruction, CDATA and a declaration;
- candidates are found first, and a document with none returns the per-line result before the
  tracker runs (FR-010 as amended).

The comments no longer claim "no renderer can", "never less strict" or "never fewer"
(round-3 F5). They say the model is the digest generator's, and name what it does not model,
attributes and titles included. The DIGEST-001 and AMEND-001 `notes` in `rules.json` are updated.

### T014l — suite, mutations, D1, parity

Run 2026-09-30 (pwsh 7.6.6, Pester 5.7.1), scripts backed up and restored by hash (`True`):

- Full suite: **843 passed, 0 failed, 0 skipped**, `enforcement-tests: OK`, exit 0 (833 before,
  plus five cases at two assertions each).
- Mutation (a), the three scripts at `e10da18`: `-Case wrapped-span` fails 2 of 3 cases, the
  DIGEST-001 `pass-wrapped-span` and `fail-wrapped-span`, exit 1. `fail-wrapped-span-hidden`
  passes on the parent, which is right: it pins the parent's behaviour.
- Mutations of the digest rule, `-Case pass-hidden-` each, with the failing cases named from a
  scratch harvest under the same mutation:

  | Mutation | What it removes | Harness result | Failing cases |
  |---|---|---|---|
  | (e) | the closer check | 4 failed, exit 1 | `after-backslash-spans`, `nbsp-line` |
  | (f) | the raw HTML exclusion | 6 failed, exit 1 | `html-block-open`, `pre-in-misread-fence`, `pre-under-tag-line` |
  | (g) | blank as spaces and tabs (read as `\s` again) | 2 failed, exit 1 | `nbsp-line` |
  | (h) | the long-end override (`8e45e37`'s tracker) | 4 failed, exit 1 | `pre-in-misread-fence`, `pre-under-tag-line` |

  Every guard fails under the mutation it was written for.
- D1 over the kit's 234 `.md` files: 0 violations.
- The digest reading differs from per-line pairing on 5 lines across the kit and adopters, all in
  review documents that quote these shapes. `ritual-checks`' digest freshness check covers the
  committed digests.

### Draft for the owner — the GAP-028 limitation (beside T026's gap, main-side docs PR)

> GAP-0NN — The amendment-authority check reads code spans one line at a time
> (`Get-VisibleFromText`, `scripts/enforcement-pack.ps1`), so a code span that wraps across lines
> and holds `<!--` hides every approver record after it, up to the next `-->` the reading
> leaves armed (to the end of the document when there is none): the check refuses a legitimate
> amendment (014 B7's shape). This fails closed, and the remedy is to keep such a span on one
> line. It is kept on purpose. Feature 016 tried three readings that disarm more, and each let
> some record inside a real comment, or hidden by a tag attribute or link title, count as a
> grant (016 phase-1 reviews, rounds 1-3). A future fix needs a reading proved never to reveal
> what a renderer hides, which likely means a real CommonMark parser, not a regex model.
> Pinned by AMEND-001 `fail-wrapped-span-hidden`.

## Phase 1 round-4 remediation (T014m)

The fresh-context round-4 review of `b45cff1` (`ai-code-review-phase-1-round-4.md`, committed as
`5d1706b`) is **REQUEST CHANGES**, but it **confirmed the security gate**. The amendment check's
reading equals the parent's on 1,088 files and a 20,000-document fuzz, and the code differs only
in the renamed helper. Its F1 is on the digest side (FR-003): the raw HTML tracker forgot an
enclosing blank-ending block when an inner block closed, and a misread fence still masked a
`div` or type-7 start. The owner approved spec SC-002/SC-004 and task T014m on 2026-09-30,
committed alone as `641a3f5`.

### The fix

These changes are in `Convert-CodeSpanMarkers`, digest generator only:
- a block with a longer end opened inside a blank-ending block returns to it when it closes;
- every block start is read on fenced lines too;
- block ends are read after the container markers, so a block quote's `>` does not end a
  declaration (the review's speculative `c1`);
- a tag line that opens `pre`, `script`, `style` or `textarea` later on the line takes that
  element's end.

Each change was meant to disarm less, never more. The round-5 review found that the last one
disarms more: the tag line's own blank-ending block was lost when the element closed (round-5
F1, corrected by T014n below).

Across all 59 documents from reviews 2-4, the digest harvest now equals the parent's except on
one: `e1-tab-blank`. There a tab-only line is blank in CommonMark, so the inline `<!--` ends with
its paragraph and the marker after it is a standalone comment. This branch harvests it and the
parent loses it, which is GAP-028 itself.

### Guards: ten DIGEST-001 cases, each with a hand-written one-rule digest

| Case | `b45cff1` | `e10da18` | The fix |
|---|---|---|---|
| `pass-hidden-div-after-comment-line` (round-4 b1) | harvests the hidden marker | right | right |
| `pass-hidden-div-after-pre` (b3) | harvests it | right | right |
| `pass-hidden-div-in-misread-fence` (a1) | harvests it | right | right |
| `pass-hidden-script-after-tag` (f1) | harvests it | right | right |
| `pass-hidden-list-div`, `pass-hidden-quote-div` (container markers) | right | right | right |
| `pass-hidden-comment-block-open`, `-pi-block`, `-cdata-block`, `-declaration-block` | right | right | right |

The last six guard code that round-4 F2 showed could be deleted with every case still green, so
they pass on `b45cff1` by design and fail under its removal (below).

### Suite and mutations, run 2026-09-30, library restored by hash (`True`)

- Full suite: **863 passed, 0 failed, 0 skipped**, `enforcement-tests: OK`, exit 0 (843 before,
  plus ten cases at two assertions each).
- Each mutation was run with `-Case pass-hidden-` (15 cases), and a scratch harvest under the
  same mutation names the failing cases:

  | Mutation | Removes | Failing guards |
  |---|---|---|
  | (e) | the closer check | `after-backslash-spans`, `nbsp-line` |
  | (f) | the raw HTML exclusion | 13 of 15 |
  | (g) | blank as spaces and tabs | `nbsp-line` |
  | (h) | the long-end override | `pre-under-tag-line` |
  | (i) | the return to the enclosing block | `div-after-comment-line`, `div-after-pre` |
  | (j) | block starts read on fenced lines | `div-in-misread-fence` |
  | (k) | the container markers | `list-div`, `quote-div` |
  | (k2) | the block-quote alternative | `quote-div` |
  | (l1)-(l4) | the comment, PI, CDATA and declaration ends | one each, the matching guard |
  | (m) | the raw-text element opened later on a tag line | `script-after-tag` |

  Every mutation fails, exit 1. `pre-in-misread-fence`, which (h) alone failed on `b45cff1`, is
  now also covered by (j). Removing (h) alone leaves it green, because (j) sees the `pre` line
  as a block start. **Unguarded:** reading ends after the container markers (the `c1` change)
  has no case. It is a conservative-direction change, and the review marked its shape
  speculative.
- Amendment-reading parity with `e10da18`: **567 files, 0 differ** (the new review file makes
  it 567). D1 over 235 kit `.md` files: 0 violations. The digest reading still differs from
  per-line on the same 5 review-document lines, and the digest freshness check covers the
  committed digests.

## Phase 1 round-5 remediation (T014n)

The fresh-context round-5 review of `c6d95a1` (`ai-code-review-phase-1-round-5.md`, committed as
`115d092`) is **REQUEST CHANGES**. Round-4 F1-F4 are closed and the security gate is untouched.
Its F1 is on the digest side (FR-003): the tag-line raw-text branch added in `c6d95a1` left the
tracker's resume unset, so the tag line's own blank-ending block was lost when the element
closed, and an unclosed `<!--` later in that block was disarmed. Seven shapes (n1-n7) were right
on `e10da18` and `b45cff1` and wrong on `c6d95a1`. The owner approved plan D11 (amended after
round 5) and task T014n on 2026-10-01, committed alone as `79b5763`.

### The fix

In `Convert-CodeSpanMarkers` only: when a long-end start is read outside any block, and the line
is a tag line that is not itself a `pre`, `script`, `style` or `textarea` start, the block to
resume is the blank-ending block that line starts. The library comment's "never fewer" claim is
replaced by what is actually checked: the rules keep lines on the per-line result for the shapes
the cases guard. The round-4 "never more" sentence above is corrected the same way.

### Guards: four DIGEST-001 cases, test-first

| Case | Shape | `c6d95a1` | The fix |
|---|---|---|---|
| `pass-hidden-tag-line-script-closed` | n3, `<div><script src="a.js"></script>` | harvests the hidden marker | right |
| `pass-hidden-tag-line-pre-later-close` | n2, `<div><pre>` / `x</pre>` | harvests it | right |
| `pass-hidden-list-tag-line-pre` | n6, `- <div><pre>x</pre>` | harvests it | right |
| `pass-hidden-quote-tag-line-script` | n7, `> <div><script></script>` | harvests it | right |

On `c6d95a1` the four fail, 8 assertions, each `digests: FAIL - stale or hand-edited digest`.

### Suite, mutations, parity and corpus, run 2026-10-01

- Full suite: **871 passed, 0 failed, 0 skipped**, `enforcement-tests: OK`, exit 0 (863 before,
  plus four cases at two assertions each).
- Mutations, each run with `-Case DIGEST-001` (25 cases) in a scratch copy of the working tree,
  the library restored by hash after each (`ce05a3e3…`, unchanged):

  | Mutation | Removes | Result | Failing guards |
  |---|---|---|---|
  | (e) | the closer check | 4 failed, exit 1 | `after-backslash-spans`, `nbsp-line` |
  | (f) | the raw HTML exclusion | 34 failed, exit 1 | 17 of 19 `pass-hidden-*` |
  | (g) | blank as spaces and tabs | 2 failed, exit 1 | `nbsp-line` |
  | (h) | the long-end override inside a blank-ending block | 2 failed, exit 1 | `pre-under-tag-line` |
  | (i) | every return to an enclosing block | 12 failed, exit 1 | `div-after-comment-line`, `div-after-pre`, and the four new guards |
  | (j) | block starts read on fenced lines | 2 failed, exit 1 | `div-in-misread-fence` |
  | (k) | the container markers | 8 failed, exit 1 | `list-div`, `quote-div`, `list-tag-line-pre`, `quote-tag-line-script` |
  | (k2) | the block-quote alternative | 4 failed, exit 1 | `quote-div`, `quote-tag-line-script` |
  | (l1)-(l4) | the comment, PI, CDATA and declaration ends | 2 failed each, exit 1 | the matching guard |
  | (m) | the raw-text element opened later on a tag line | 2 failed, exit 1 | `script-after-tag` |
  | **(n)** | the tag-line start's return to its own block (`c6d95a1`'s resume) | 8 failed, exit 1 | the four new guards |
  | `c1` | ends read after the container markers | 83 passed, exit 0 | none (unguarded, round-5 F2 accepted) |

- Round-5 probe documents (`r5/docs`, `r5/docs2`), harvested on `b45cff1`, `c6d95a1` and the fix:
  n1-n7 hide the marker on the fix, as on `b45cff1`; a1, b1, b3 and c1 stay hidden; `ok1` keeps its
  visible rule; q7 and q8 are as on `c6d95a1` (the conservative direction the review noted).
- Corpus: the 567 `.md` files (kit plus the three adopted projects) and the 91 earlier review
  documents harvest identically on `c6d95a1` and the fix, markers and scan lines alike.
- Amendment-reading parity: the fix touches only `Convert-CodeSpanMarkers`, which the amendment
  check does not call; `scripts/enforcement-pack.ps1` and `scripts/build-digests.ps1` are
  unchanged from `c6d95a1`. The reading therefore still equals the parent's, by construction; the
  file-by-file comparison was not rerun this round.

## Phase 1 round-6 follow-up (T014o)

The fresh-context round-6 review of `517f9d2` (`ai-code-review-phase-1-round-6.md`, committed as
`edc9bb7`) is **APPROVE**, with two minor findings the owner asked to fix in phase 1. F1: the
raw-text-start exclusion of T014n's resume rule had no guard. F2: a raw-text element closed and
reopened on one line (`<div><script>a</script><script>`, or `</script><script>` on a later line)
was read as closed, so a marker inside the reopened script was harvested; `e10da18` hid it, and
`b45cff1` to `517f9d2` harvested it. The owner approved plan D11 (amended after round 6) and task
T014o on 2026-10-01, committed alone as `bdcd773`.

### The fix

`Test-HtmlBlockEnd` (new, pure) decides whether a line ends a raw HTML block. A `pre`, `script`,
`style` or `textarea` end counts only when no such element opens after the line's last end tag;
every other end counts wherever it falls, as before. `Convert-CodeSpanMarkers` uses it on the line
that starts a block and on a later line that would end one. The library's "Not modelled"
paragraph now names the browser's other raw-text elements (`title`, `xmp`, `iframe`, `noembed`,
`noframes`; round-6 `q04` still harvests its marker, by that record).

### Cases: four DIGEST-001 cases, test-first

| Case | Shape | `517f9d2` | The fix |
|---|---|---|---|
| `pass-wrapped-after-closed-pre` (direction) | round-6 `v05`: `<pre>x</pre>`, a wrapped `` `<!--`` span, a visible marker | right | right; fails under (o) |
| `pass-hidden-reopen-same-line` | `q01`: `<div><script>a</script><script>` | harvests the hidden marker | right |
| `pass-hidden-reopen-type1` | `q02`: `<script>a</script><script>` | harvests it | right |
| `pass-hidden-reopen-later-line` | `q03`: `<div><script>` / `</script><script>` | harvests it | right |

On `517f9d2` the three guards fail, 6 assertions, each `digests: FAIL - stale or hand-edited
digest`. The direction passes there by design: it pins the exclusion, and fails only under its
removal.

### Suite, mutations, corpus and probes, run 2026-10-01

- Full suite: **879 passed, 0 failed, 0 skipped**, `enforcement-tests: OK`, exit 0 (871 before,
  plus four cases at two assertions each).
- Mutations, each run with `-Case DIGEST-001` (29 cases) in a scratch copy of the working tree,
  the library restored by hash after each (`9eb08565…`, unchanged). (e)-(n) fail as in T014n's
  table, now with the new guards where they apply: (f) 40 failed, 20 of 23 guards; (m) also
  fails `reopen-same-line` and `reopen-later-line`. The new ones:

  | Mutation | Removes | Result | Failing cases |
  |---|---|---|---|
  | (o) | the raw-text-start exclusion from the tag-line resume | 2 failed, exit 1 | `pass-wrapped-after-closed-pre` |
  | (p) | the reopen check (an end tag anywhere closes the element) | 6 failed, exit 1 | the three reopen guards |
  | (p1) | the reopen check on the start line only | 4 failed, exit 1 | `reopen-same-line`, `reopen-type1` |
  | (p2) | the reopen check on a later line only | 2 failed, exit 1 | `reopen-later-line` |
  | `c1` | ends read after the container markers | 91 passed, exit 0 | none (unguarded, owner-accepted) |

- Corpus: the 567 `.md` files (kit plus the three adopted projects), harvested by `517f9d2`'s
  library and the fix on the same file contents: identical, markers and scan lines. The 91
  earlier review documents: identical.
- Probe documents of rounds 5 and 6 (42): only round-6 `q01`-`q03` change, each now hiding the
  marker. `q04` (`title`) harvests it, as recorded above.
- Amendment-reading parity: `Test-HtmlBlockEnd` and `Convert-CodeSpanMarkers` are called by the
  digest generator only; `scripts/enforcement-pack.ps1` and `scripts/build-digests.ps1` are
  unchanged from `517f9d2`, so the amendment check's reading is unchanged.

## Phase 1 round-7 remediation (T014p)

The fresh-context round-7 review of `c565240` (`ai-code-review-phase-1-round-7.md`, committed as
`2477ad9`) is **REQUEST CHANGES**. Its F1: T014o's reopen check kept a raw-text element open past
the line where CommonMark ends its block, so a `div` or processing-instruction block starting
inside it was missed, and the close returned to inline text, disarming a real comment's opener
(round-7 `b04`-`b10`, all hidden on `517f9d2`). That breaks FR-003; the reopen it fixed hides a
marker by a script, which FR-003 allows. The owner chose to withdraw the reopen rule and approved
plan D11 (amended after round 7) and task T014p on 2026-10-01, committed alone as `f7b9bb3`.

### The change

- `Test-HtmlBlockEnd` is removed; a raw-text end tag anywhere on a line closes the element, as on
  `517f9d2`. `Convert-CodeSpanMarkers` is again byte-identical in code to `517f9d2`'s; the
  library differs from it only in the "Not modelled" paragraph, which now names the reopen, the
  round-7 F2 forms (`<script/>`, an end tag inside an attribute or of another element) and the
  browser's other raw-text elements, `noscript` and `plaintext` included.
- The T014o reopen guards (`pass-hidden-reopen-same-line`, `-reopen-type1`, `-reopen-later-line`)
  are removed with the rule. One case, `fail-reopen-not-modelled` (round-6 `q01`), pins the
  limitation: the digest carrying only the visible rule is read as stale.
- `pass-wrapped-after-closed-pre` and mutation (o) stay.

### Cases: four DIGEST-001 cases, test-first

| Case | Shape | `c565240` | The change |
|---|---|---|---|
| `pass-hidden-div-in-reopen` | round-7 `b04`: `<script>a</script><script>` / `<div>` / `</script>` / `x <!--` | harvests the hidden marker | right |
| `pass-hidden-div-in-later-reopen` | `b08`: `<pre>` / `</pre><script>` / `<div>` / `</script>` / `x <!--` | harvests it | right |
| `pass-hidden-pi-in-reopen` | `b09`: `<script>a</script><script>` / `<?x` … past a blank line | harvests it | right |
| `fail-reopen-not-modelled` (pin) | round-6 `q01`: `<div><script>a</script><script>` | reads the digest fresh | reads it stale, exit 1 |

On `c565240` each of the four fails, 2 assertions each.

### Suite, mutations, corpus and probes, run 2026-10-01

- Full suite: **881 passed, 0 failed, 0 skipped**, `enforcement-tests: OK`, exit 0 (879 before,
  less three removed cases, plus four new, at two assertions each).
- Mutations (e)-(o), each run with `-Case DIGEST-001` (30 cases) in a scratch copy of the working
  tree, the library restored by hash after each (`d58196a0…`, unchanged). Each fails, exit 1, as
  in T014o's table, with the new guards where they apply: (f) 40 failed, 20 guards including the
  three new ones; (l2) also fails `pi-in-reopen`; (o) fails `pass-wrapped-after-closed-pre`.
  (p), (p1) and (p2) are retired with the rule. `c1`: 93 passed, exit 0 (unguarded,
  owner-accepted).
- Corpus: the 567 `.md` files, harvested by `517f9d2`'s library and this one on the same file
  contents: identical, markers and scan lines. The 91 earlier review documents: identical.
- Probe documents of rounds 5, 6 and 7 (84): every one harvests as on `517f9d2`. Round-7
  `b04`-`b10` hide the marker again; round-6 `q01`-`q03` harvest it, by the record above.
- Amendment-reading parity: `scripts/enforcement-pack.ps1` and `scripts/build-digests.ps1` are
  unchanged from `517f9d2`, and the library's code equals `517f9d2`'s, so the amendment check's
  reading is unchanged.

## Phase 1 round-8 remediation (T014q)

The fresh-context round-8 review of `3ad7408` (`ai-code-review-phase-1-round-8.md`, committed as
`793efbd`) is **REQUEST CHANGES**. Its F1: a long-end start the tracker reads where CommonMark has
none (on a real fence's line, in an indented code block, or in a container that closes) masks a
later block start, and on the tracker's end a real comment's opener is disarmed (round-8 `c01`-
`c18`; present since `517f9d2`). The owner chose to record the routes rather than model them, and
approved spec FR-003 (a named exception), plan D11 and task T014q (all amended after round 8) on
2026-10-02, committed alone as `43e607c`.

### The change

- No behaviour change. The library's non-comment token stream equals `3ad7408`'s (976 tokens);
  `scripts/enforcement-pack.ps1` and `scripts/build-digests.ps1` are unchanged. The amendment
  check reaches 14 functions, and `Convert-CodeSpanMarkers` is not among them.
- The "Not modelled" paragraph names the three routes and the consequence: a real comment's
  opener may be disarmed and a marker inside it harvested (FR-003's named exception).
- The long-end start's comment no longer claims that on a real fence "the only effect is that
  more lines keep the per-line result"; a start there can mask a block start after the fence.
- F2 wording: `pre` and `textarea` are no longer called raw-text elements, and
  `fail-reopen-not-modelled`'s description says that if the reopen is ever modelled the digest
  check passes, so the case fails and must be retired or turned into a guard.

### Cases: three DIGEST-001 pins

| Case | Shape | `e10da18` (parent) | `3ad7408` and this change |
|---|---|---|---|
| `fail-fence-long-end-not-modelled` | round-8 `c01`: a fenced `<?x`, then `<div>` / `?>` / `x <!--` | reads the digest fresh (case fails) | reads it stale, exit 1 |
| `fail-indented-long-end-not-modelled` | `c02`: an indented `    <?x`, a blank line, then the same | reads it fresh (case fails) | reads it stale, exit 1 |
| `fail-container-long-end-not-modelled` | `c03`: `> <?x`, then an unquoted `<div>` / `?>` / `x <!--` | reads it fresh (case fails) | reads it stale, exit 1 |

On `e10da18`'s three scripts the pins give 33 passed, 6 failed: each marks a limitation the
parent did not have, and each flips if its route is ever modelled.

### Suite, mutations, corpus and probes, run 2026-10-02

- Full suite: **887 passed, 0 failed, 0 skipped**, `enforcement-tests: OK`, exit 0 (881 before,
  plus three cases at two assertions each).
- Mutations, the round-8 reviewer's runner reused read-only, each run with `-Case DIGEST-001`
  (33 cases) in a scratch copy of the working tree, the library restored by hash after each
  (`True`). Unmutated: 99 passed. (e)-(o) each fail, exit 1, as in T014p's record; the pins fail
  where a mutation touches their route: (k) also fails `container-long-end`, (l2) all three.
  `p-reapply` fails `fail-reopen-not-modelled` and the two reopen guards. `c1`: 99 passed, exit 0
  (unguarded, owner-accepted).
- F3: `j-long` (no long-end start on fenced lines) now gives 97 passed, 2 failed, but only
  through the pin `fail-fence-long-end-not-modelled`. A pin detects the change; no guard shows
  what the misread-fence half of the rule buys. Recorded beside `c1`, as D11 says.
- Corpus: the 567 `.md` files, harvested by `3ad7408`'s library and this one on the same file
  contents: identical, markers and scan lines. The 91 earlier review documents: identical.
- Probe documents of rounds 5 to 8 (101): every one harvests as on `3ad7408`. Round-8 `c01`-`c03`
  harvest the hidden marker, by the record above.

## Phase 1 round-9 remediation (T014r)

The fresh-context round-9 review of `c81a12d` (`ai-code-review-phase-1-round-9.md`, committed as
`8306a96`) is **REQUEST CHANGES**. Its F1: the round-8 exception named three routes, and six more
documents (`d01`-`d06`) reach the same mechanism by other doors, through the tracker's own round-4
and round-5 rules and through paragraph lines whose indentation or ordered marker the container
pattern strips (present since `517f9d2`). The owner chose option (b), the exception restated by
mechanism, and approved spec FR-003, plan D11 and task T014r (all amended after round 9) on
2026-10-03, committed alone as `bf68130`.

### The change

- No behaviour change. The library's non-comment token stream equals `3ad7408`'s (976 tokens);
  `scripts/enforcement-pack.ps1` and `scripts/build-digests.ps1` are unchanged since `3ad7408`.
- The "Not modelled either" paragraph states the mechanism: wherever the rule holds a block with
  a longer end that CommonMark does not hold at that line, from misread block structure or from
  following the browser into an element CommonMark's block does not contain. The doors it lists
  are examples, not a closed list: the three round-8 routes, a start honoured inside a block
  that ends at a blank line, a tag line that takes its element's end, and a paragraph line whose
  indentation or ordered marker the container pattern strips.
- F2 wording: `title` is no longer listed among the raw-text elements; it is named as RCDATA.

### Cases: two DIGEST-001 pins

| Case | Shape | `e10da18` (parent) | `c81a12d` and this change |
|---|---|---|---|
| `fail-modelled-rule-long-end-not-modelled` | round-9 `d01`: `<div><script>` / blank / `<?y` / `</script>` / blank / `x <!--` | reads the digest fresh, exit 0 (case fails) | reads it stale, exit 1 |
| `fail-paragraph-long-end-not-modelled` | round-9 `d05`: `para` / `    <?x` / `<div>` / `?>` / `x <!--` | reads it fresh, exit 0 (case fails) | reads it stale, exit 1 |

Setup: this branch's 35 DIGEST-001 cases, run with `-Case DIGEST-001` in a `HEAD` kit with the
three scripts of the commit named. `e10da18`: 85 passed, 18 failed (the five pins, the reopen pin
and the three cases the parent cannot pass, two assertions each). `c81a12d`: 103 passed, 0 failed.
The three round-8 pins stay.

### Corrections to the T014q record (round-9 F2)

- "On `e10da18`'s three scripts the pins give 33 passed, 6 failed" holds only for the three pins
  run alone. With `c81a12d`'s 33 cases and `e10da18`'s scripts the round-9 review measured 85
  passed, 14 failed; with this change's 35 cases it is 85 passed, 18 failed (above).
- "Probe documents of rounds 5 to 8 (101)": the round-9 review counted the eight directories at
  102. All of them harvested as on `3ad7408`, so the conclusion stands.
- The plan's "rounds 4, 5, 7 and 8" and the spec's "five review rounds" now read alike, as
  "rounds 4, 5, 7, 8 and 9" (spec and plan as amended after round 9).

### Suite, mutations, corpus and probes, run 2026-10-03

- Full suite: **891 passed, 0 failed, 0 skipped**, `enforcement-tests: OK`, exit 0 (887 before,
  plus two cases at two assertions each).
- Mutations, the round-8 reviewer's runner reused read-only (MD5 `0d46111d…` before and after),
  each run with `-Case DIGEST-001` (35 cases) in a scratch copy of the working tree, the library
  restored by hash after each (`True`). Unmutated: 103 passed. (e)-(o) each fail, exit 1, on the
  same guards as in T014q's record; the pins fail where a mutation touches their door: (k) also
  fails `container-long-end`, (l2) the four processing-instruction pins (fence, indented,
  container, paragraph), and (m) `modelled-rule-long-end`. `p-reapply` fails
  `fail-reopen-not-modelled` and the two reopen guards. `j-long`: 101 passed, 2 failed (the fence
  pin only, as recorded). `c1`: 103 passed, exit 0 (unguarded, owner-accepted).
- Corpus: the 567 `.md` files, harvested by `3ad7408`'s library and this one on the same file
  contents: identical, markers and scan lines. The 91 earlier review documents: identical.
- Probe documents of the earlier review rounds and round 9 (194 in 15 directories, including round
  9's `d01`-`d08` and its six fixtures): every one harvests as on `3ad7408`. Round-9 `d01`-`d06`
  harvest the hidden marker, inside FR-003's exception as amended after round 9; the controls
  `d07` and `d08` hide it.

### Phase 1 gate — CERTIFIED

> Gate 1 certified (user-run): `pwsh -File tests/enforcement/Run-Tests.ps1 && pwsh -File
> scripts/ritual-checks.ps1` on commit `5caedb7` (phase 1, T014r) — 891 passed, 0 failed,
> `ritual-checks: RESULT OK`, `EXIT: 0` confirmed by the owner — approved, anas.m, 2026-10-03.

The plan declares `ci-held`, but no CI run exists on `5caedb7`: the branch was pushed with the
round-10 review `2f6726d` on top, so CI ran on that commit (ritual-checks run 37102222178,
enforcement-tests run 37102222026), and a run on any other commit certifies nothing
(`docs/sdlc/gate-command.md`). The owner took the user-run gate, which remains lawful always.
The round-10 review (`ai-code-review-phase-1-round-10.md`, `2f6726d`) is APPROVE; its F1 and F2
are minor and left for a later amendment, F3-F6 carried.

## Phase 2: a skipped marker is never skipped silently (T015-T021)

Phase 1's gate was certified on 2026-10-03 (above). At the start of phase 2 the owner settled the
change to T016 left open on 2026-09-30: the D5-tail document joins DIGEST-020 as a fourth
direction, `fail-d5-tail` (plan D6 and task T016a, amended at the start of phase 2, committed
alone as `2a51c55`).

### T015 — measured first: zero hits (SC-007)

The phase-2 report (T018's lines) applied to a scratch copy of `build-digests.ps1` beside this
branch's `markdown-lib.ps1`, then `-Check -Root <root>` on each root, read-only:

| Root | Skipped-marker reports | Result |
|---|---|---|
| the kit (`D:/solutions/agentic-sdlc-kit`, `f240e21`) | 0 | `digests: OK (5 digest(s) fresh, 82 marker(s))`, exit 0 |
| `D:/solutions/fitforge` (`40ec9e2`) | 0 | `digests: OK (5 digest(s) fresh, 82 marker(s))`, exit 0 |
| `D:/solutions/flowboard` (`3d7a472`) | 0 | `digests: OK (5 digest(s) fresh, 59 marker(s))`, exit 0 |
| `D:/solutions/expense-tracker` (`4dca06a`) | 0 | `digests: OK (5 digest(s) fresh, 59 marker(s))`, exit 0 |

The generator reads the documents its pack manifest names, so this covers every digested
document in each root. Control: the same scratch build on the D5-tail document alone reports
`skipped digest marker: docs/sdlc/law.md:4`, exit 1, so the zeros are not a dead report.

### T016, T016a — four DIGEST-020 directions, test-first

| Case | Document | Expected |
|---|---|---|
| `fail` | `<!-- a note left open`, then a marker on line 4, then a visible marker | report names line 4, exit 1 |
| `pass` | the same note closed by `-->` on its own line before the marker | both harvested, `digests: OK`, exit 0 |
| `fail-f2-shape` | 015 phase-2 review F2's document | report names line 4, exit 1 |
| `fail-d5-tail` | the D5-tail document (`d1-tail-sameline`) verbatim | report names line 4, exit 1 |

Each fixture's digest on disk carries exactly the markers the generator harvests, so the report
is the run's only issue. **`fail-f2-shape` is not wholly verbatim**: the 015 review records its
7-line document only as lines 3-5 and says two of three markers were harvested. Lines 3-5 are
verbatim at lines 3-5; lines 1 and 7 are markers of my wording (`The first marker is harvested.`,
`The third marker is harvested.`) and lines 2 and 6 are blank. The case's description says so.

### T017 — none of the three produces the report today (FR-005)

`-Case DIGEST-020` on the phase-1 scripts (`f240e21`): `pass` passes; `fail` observes `digests: OK
(1 digest(s) fresh, 1 marker(s))`, `fail-f2-shape` observes `digests: OK (1 digest(s) fresh, 2
marker(s))` (the middle marker swallowed with an OK, the silent loss this phase closes), and
`fail-d5-tail` observes `digests: n/a (no digest markers)`; each exits 0 where 1 is expected.

### T018 — the report

`Get-DocMarkers` in `scripts/build-digests.ps1`: inside the `$inComment` branch, a raw line that
begins like a marker (`^\s*<!--\s*digest\b`, the same test DIGEST-005 uses) adds `skipped digest
marker: <path>:<line> — it sits inside a comment opened earlier in the file`, and `-Check` and
generation both fail on it (D8, FR-009). The test runs before the close is looked for, because a
marker line carries its own `-->` and closes the open comment, which is how its rule was lost.
Lines outside a comment take no additional work, and no child process is added (FR-010).

### T019 — DIGEST-020 in the inventory (FR-008)

`tests/enforcement/rules.json` gains DIGEST-020 (`(marker extraction)`, emit anchor `skipped
digest marker:`, law FR-009/US3/D8, notes naming the four directions). The coverage check counts
it: `build-digests.ps1 20 of 20 site(s) fixtured` (19 before).

### T020 — DIGEST-005 unchanged (SC-003)

Both DIGEST-005 cases pass with their expectations untouched. Its `fail` marker is malformed but
closed on its own line (`<!-- digest The whole ritual on one page. -->`) and nothing follows it,
so no comment is open after it and the report cannot fire. No expectation changed, so nothing was
raised with the owner.

### T020a — the 22 phase-1 guards expect the report (owner's decision)

The first full-suite run with T018 gave **855 passed, 44 failed**: all 22 DIGEST-001
`pass-hidden-*` guards that phase 1 added, two assertions each, each observing `digests: RESULT
FAIL (1 issue(s))` with the skipped-marker line for its hidden marker. Each guard puts a marker
inside a real comment, which is exactly what D8 makes fail, and the report cannot tell a real
comment from a phantom one without modelling CommonMark. No case that existed before this feature
failed (SC-003). Following T020's stop rule this went to the owner, who chose on 2026-10-03 to keep
D8 and change the guards (plan D8/D11 and task T020a, amended during phase 2, committed alone as
`f4b544e`). Each guard now expects the `skipped digest marker` line naming its hidden marker and
exit 1; its document and digest are untouched, its description gains one sentence, and DIGEST-001's
notes in `rules.json` say so. The reported line was checked against the document (for example
`pass-hidden-nbsp-line`: line 7, its hidden marker).

Mutations re-run (the round-8 reviewer's runner, MD5 `0d46111d…` before and after, `-Case
DIGEST-001` in a scratch copy of the working tree, library restored by hash, `True`): every
mutation fails exactly the cases it failed in T014r's table, (e)-(o) and `p-reapply`; `c1` still
103 passed (unguarded, owner-accepted). The counts halve, for example (f) 83 passed, 20 failed
where T014r had 63/40: a mutation that harvests a guard's marker still exits 1 (the digest reads
stale), so a guard now fails on its output assertion only. Each guard still fails under its
mutation.

### T021 — full suite and mutation (a) (SC-004)

- Full suite: **899 passed, 0 failed, 0 skipped**, `enforcement-tests: OK`, exit 0 (891 at phase 1,
  plus four DIGEST-020 cases at two assertions each). Coverage: `build-digests.ps1 20 of 20
  site(s) fixtured`.
- Mutation (a), T018 reverted in a scratch copy of the final tree, `-Case DIGEST-0` (75 cases): 131
  passed, 52 failed. `fail`, `fail-f2-shape` and `fail-d5-tail` fail (both assertions each), as do
  the 22 guards (they now expect the report) and the inventory's anchor check; `pass` passes.
  Measured before T020a too, on the phase-2 cases alone: the same three fail and `pass` passes.

## Phase 3 (T022, T023)

### T022 — what would flow down (SC-005, FR-011)

`pwsh -File scripts/update-kit.ps1 -DryRun -Target <project>` from `08cbee9`. Zero writes. The
target must be a clean git tree, so `fitforge` (untracked `.claude/settings.local.json`) and
`flowboard` (that file plus `docs/product/flowboard-prototype.html`) were refused in place.
Neither was touched. Both were graded as `git clone` copies of their committed HEAD instead
(`fitforge` `40ec9e2`, `flowboard` `3d7a472`); `expense-tracker` (`4dca06a`) ran in place.

| Project | Applied (verbatim, clean update) | Surgical | Conflicts | Result |
|---|---|---|---|---|
| fitforge | `scripts/build-digests.ps1`, `scripts/enforcement-pack.ps1`, `scripts/markdown-lib.ps1` | none | none | kit 0.7.0 @ `08cbee9`, not written |
| flowboard | the same three | none | none | the same |
| expense-tracker | the same three | none | none | the same |

Exactly the three scripts, no surgical file, as predicted. No constitution or law document
flows down, so no adopter has an amendment to re-express.

### T023 — digests and verdicts in a scratch copy of each project (SC-005, FR-011)

Per project, in a clone of its committed HEAD: `ritual-checks.ps1` before, copy this branch's
three scripts over, `build-digests.ps1`, `ritual-checks.ps1` after.

| Project | `ritual-checks` before | After | Regenerated digests vs committed blobs | Markers |
|---|---|---|---|---|
| fitforge | `RESULT OK` | `RESULT OK`, member lines unchanged | 5 of 5 byte-identical | 82 |
| flowboard | `RESULT OK` | `RESULT OK`, member lines unchanged | 5 of 5 byte-identical | 59 |
| expense-tracker | `RESULT OK` | `RESULT OK`, member lines unchanged | 5 of 5 byte-identical | 59 |

The first comparison read as a difference (md5 of the working files moved) and was wrong: the
clones check out with CRLF (`core.autocrlf=true`) and the generator writes LF. Comparing the
regenerated file to `git show HEAD:<file>` byte for byte gives identical for all 15 digests,
and `git diff --ignore-cr-at-eol` is empty. Nothing an adopter sees changes: no digest, no
verdict, no new skipped-marker report (zero hits, as T015 measured).

The kit itself is T025's: its digests are regenerated there, because T024 edits a digest
source.

### T024 — the flow-down note

Written in `adoption/updating.md` under "Flow-down note: the 2026-10-03 multi-line code spans and
the skipped-marker report", before "3. Other surgical files". It says what changed (a span
wrapping within a paragraph now hides nothing), the DIGEST-020 failure and its two remedies,
that F2's shape is reported and not fixed, and what T022 and T023 measured (three scripts, no
surgical file; every digest byte-identical, every verdict unchanged). It carries one digest
marker, within the 120-character bound (the first draft was 132 and the generator refused it).

### T025 — the kit's digests

`build-digests.ps1` regenerated the kit's digests: only `docs/digests/adoption-digest.md` changed
(one added line, the new marker; 82 markers became 83). `build-digests.ps1 -Check` reports
`digests: OK (5 digest(s) fresh, 83 marker(s))`. `ritual-checks.ps1` on the kit: doc-lint,
enforcement-pack, scope-check, digests and roadmap-claims `OK`; scope-repos and verify-kit `n/a`
(the kit is a single-repo, unadopted tree); `RESULT OK`.

### T026 — draft for the owner: the new gap (for a main-side docs PR after merge)

**Title**: the kit's comment model disagrees with a renderer on an unpaired `<!--` in prose.

**What is wrong.** The kit reads an unpaired `<!--` as the start of an HTML comment that runs
to the next `-->`, or to the end of the file. A CommonMark renderer shows the same text as
plain prose when the `<!--` sits mid-line in a paragraph, and each marker line after it is
still a marker block. So a document can hide a digest marker from the generator that the
renderer shows.

**Evidence** (research R1, row 2, `markdown-it-py` CommonMark preset): a paragraph with an
unpaired backtick and `<!--`, then a marker line, then the closing backtick. The renderer reads
line 3 as plain text (no `code_inline`, no `html_inline`) and both markers as `html_block`s. The
kit reads `<!--` armed and swallows the middle marker: 2 of 3 are harvested. The tail form is
pinned as `fail-d5-tail` under DIGEST-020.

**Why this feature did not fix it.** The amendment check relies on the unterminated-comment
rule; changing the comment model to agree with a renderer changes what that check grades
(research R1, alternatives; spec Out of Scope). The owner accepted the loss as covered by a
report (round-2 F2, 2026-09-30).

**What exists now.** The loss is loud: `skipped digest marker: <path>:<line>` fails the run
(DIGEST-020). Zero hits in the kit and in all three adopted projects (T015, T023).

**Open question for the owner.** Whether the comment model should follow the renderer for
mid-line `<!--` in a paragraph, and what that does to amendment grading. Until then the report
is the control.

### Phase 3 review round 1 remediation (review F1, F2)

- **F1 (blocking)**: T022 was run at `08cbee9`, before the flow-down note existed, so it saw
  three files. From the branch tip the update applies **four**: the three scripts and
  `adoption/updating.md` itself, the adoption digest pack's only member. The T023 "after" column
  above is the **scripts-only** state: with only the three scripts, all 15 digests are
  byte-identical and verdicts unchanged. With the tip's `updating.md` as well, the adoption
  digest gains one line (the note's marker) and an adopter must regenerate. The flow-down note
  now says exactly that (four files; scripts change nothing; the document adds one digest line;
  regenerate and commit).
- **F2**: the note's "no longer silent" is now limited to a marker on its own line; a marker
  after a same-line `-->` is stated as still not reported (phase-2 review F1).

### Phase 3 gate — CERTIFIED

> Gate 3 certified (ci-held): CI evidence triplet on the phase-3 commit `3cb0671` (the remediation
> that closes round-1 F1-F2 of the phase-3 review; the phase's first commit is `6fbee08`) —
> enforcement-tests run https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/38063119973
> (`success`) and ritual-checks run
> https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/38063119968 (`success`), both
> push-event runs on `3cb0671747d5d3869845e72ff6b2e02bcb7ca7dc` — approved, anas.m, 2026-10-10.

The certified sha is the last phase-3 commit, as phase 1 certified its last remediation commit
`5caedb7`. `6fbee08` also carries green runs of both workflows (enforcement-tests 38062630922,
ritual-checks 38062630924) but it is superseded by the remediation. The phase-3 AI review is
round 2 APPROVE (`ai-code-review-phase-3-round-2.md`; round 1 REQUEST CHANGES, F1-F2 resolved by
`3cb0671`). Its non-blocking items are carried, not closed: `tasks.md` T022's "three scripts"
wording needs an owner-approved amendment, and the `docs/roadmap.md` GAP-028 and GAP-025 rows
(FR-012) sit outside phase 3's Territory.

Phase 2's gate (`7158c4c`) is not recorded here. Its CI evidence exists (enforcement-tests run
37107680349, ritual-checks run 37107680181, both `success`) and its AI review is APPROVE
(`ai-code-review-phase-2.md`); the owner's approval on that triplet has not been recorded.

### Phase 2 gate — CERTIFIED

> Gate 2 certified (ci-held): CI evidence triplet on the phase-2 commit `7158c4c` (T015-T021, the
> only phase-2 commit; no remediation followed) — enforcement-tests run
> https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/37107680349 (`success`) and
> ritual-checks run https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/37107680181
> (`success`), both push-event runs on `7158c4c31089fae80940b0e2bc9c85582fa563bb` — approved,
> anas.m, 2026-10-10.

This supplies the approval the phase-3 record above says was missing. The runs were green when
the phase was pushed on 2026-10-03 and were re-read on 2026-10-10. The phase-2 AI review is
APPROVE (`ai-code-review-phase-2.md`, `08cbee9`); its non-blocking findings F1 (a marker after a
same-line `-->` is neither harvested nor reported), F2 (the 22 amended `pass-hidden-*`
descriptions still say "the check must say OK") and F3 (the report matches case-insensitively by
design) are carried, not closed. Phase 2's code is unchanged by phase 3: `scripts/build-digests.ps1`
has no commit after `7158c4c`.
