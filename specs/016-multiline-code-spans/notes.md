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
