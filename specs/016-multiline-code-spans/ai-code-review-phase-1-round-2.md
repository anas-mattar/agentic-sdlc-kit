# AI Code Review — 016 Multi-line Code Spans (Phase 1, round 2)

**Reviewer**: fresh-context agent — claude-opus-5-5
**Date**: 2026-09-30
**Branches**: agentic-sdlc-kit `016-multiline-code-spans` (tip `6f754150d56916430b1d25601f01ea89ec0612cb`)
**Scope reviewed**: phase 1 as two commits graded together: `7a770e5` (the original fix) and
`6f75415` (the round-1 remediation), read in full. The net script change is
`git diff e10da18..6f75415 -- scripts/` (`scripts/markdown-lib.ps1`, `scripts/enforcement-pack.ps1`,
`scripts/build-digests.ps1`). Also read: the three new AMEND-001 directions
(`fail-hidden-backslash-closer`, `fail-hidden-autolink-backtick`, `fail-hidden-pre-block`),
`tests/enforcement/rules.json`, and the `notes.md` and `tasks.md` changes in both commits. Also the
round-1 review `1378800` (`ai-code-review-phase-1.md`) and the amendment `44f6c94` (plan D9, tasks
T014a-T014d).
**Feature contract**: phase 1 = T001-T014d. One shared code-span function with a whole-document
signature. It returns the same line count and line lengths as its input (D1). Spans pair within a
paragraph (D2-D4). A doubtful paragraph keeps per-line pairing, and raw HTML blocks end by
CommonMark's rule (D9). Build-digests precomputes the pairing and indexes it by line (D5). No new
dependency and no new script. Territory is the three scripts plus `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: claude-opus-5-5 (the implementing session)
- **Inputs provided**: `git show` of `7a770e5`, `6f75415`, `1378800` and `44f6c94`, and
  `git diff e10da18..6f75415 -- scripts/`. For `specs/016-multiline-code-spans/`: the round-1
  review, `plan.md` (D9 in full), `tasks.md` (the phase-1 Territory and T014a-T014d) and `notes.md`
  (the T013-T014d evidence and the F2/F4 dispositions). The kit's law (`CLAUDE.md`,
  `.specify/memory/constitution.md`, `docs/sdlc/definition-of-done.md`,
  `docs/sdlc/review-process.md`, all loaded as project instructions). The review template.
  `tests/enforcement/lib/Harness.psm1`, used to drive cases against scratch kit roots. Read and run
  access to the working tree. Every experiment ran in a scratch directory outside the repository,
  using scratch kit copies of `e10da18`, `7a770e5`, `6f75415` and five mutations. No repository
  file was modified.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES.** The remediation does what its cases say. Every round-1 counterexample now
hides the record, including the four variants round 1 checked only through `Get-VisibleFromText`.
Mutations (c) and (d) fail the cases they claim to guard. I rebuilt both in scratch kits and did
not rely on `notes.md`. D1 holds under a 5,000-document fuzz. Territory is clean, and
`ritual-checks` is green. The brief's regression question still gets the answer **yes**, though.
D9 decides "doubtful" one line at a time, but the constructs it names can open on one line and hold
their backtick on the next. Some constructs are not named at all: a link reference definition, and
a raw HTML block or fence inside a list item. I built eight documents where `6f75415` counts as
visible a record that markdown-it 14 and commonmark.js both render as nothing, and `e10da18` hides
it. I ran each one end to end as an AMEND-001 commit through `Invoke-FixtureCase`: `e10da18` says
`FAIL`, exit 1, and `6f75415` says `enforcement-pack: OK`, exit 0 (F1). One shape also refutes the
implementer's claim in `notes.md` that a comment opener before both backticks is safe. The narrowing
proposed there would reopen a further shape (F1, row i). Exposure is latent: no Markdown file in
the kit or the three adopters has the new shapes. Round-1 F2's second shape is still open,
confirmed (F2). Some comments still overclaim, and `notes.md` makes two new ones (F3). Two
alternatives of `$doubtful` are guarded by no case (F4).

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | D9 as written is implemented as written: `$doubtful` at `scripts/markdown-lib.ps1:130` covers "a backslash touching a backtick; a `<` opening a tag, autolink, comment or declaration, or `](`, before a backtick" per line. The type-1/3/4/5/6-7 HTML block ends are at `:183-199`. D9's goal, that paragraph pairing reaches further only where the backticks can be read as delimiters, is not met (F1) |
| Round-1 counterexamples | Read with `Get-VisibleFromText` taken from each script's AST, the record is hidden on `e10da18` and `6f75415` and visible on `7a770e5` for all seven shapes: the backslash closer, the autolink, `<pre>` across a blank line, `<pre>` with CRLF (lines split on LF only, so each keeps its `\r`), a raw-HTML attribute `<span title="`">`, a link destination `[x](a`b)`, and `\\` before the opening backtick. Further variants also hide on `6f75415`: `<PRE>`, an indented `<pre class="x">`, `<script>`, `<?php … ?>`, and an image `![i](a`b)`. Both renderers hide the record in every one |
| T014a (fail on the unremediated fix) | The three committed cases, run against a scratch `7a770e5` kit, all fail with exit 0 (the fail-open). Against `e10da18` all three pass with exit 1. This matches `notes.md` |
| Mutations (c), (d) | Scratch kits run the 10 016 cases (AMEND-001 `*hidden*`, `*wrapped*`, `*comment-block*`; DIGEST-001 `*wrapped*`, `*comment-block*`). Unmutated: 0 failing. (c), `$doubtful = '(?!)'`: `fail-hidden-autolink-backtick` and `fail-hidden-backslash-closer` fail, exit 0. (d), the type-1 end removed: `fail-hidden-pre-block` fails, exit 0. Both claims are confirmed. Finer mutations are in F4 |
| D1 (count, length, only markers change) | A scratch fuzz over 5,000 random documents found **0 violations**. The tokens were backtick runs, escapes, `<!--`/`-->`, block starts, fences, tabs, `\r`, `<pre>`/`</pre>`/`<PRE `, `<?`/`?>`, CDATA, `<!DOCTYPE`, `<https://a`, `](`, `[r]: ` and `<span ` |
| Exposure | I compared the parent's per-line function with `6f75415`'s over 564 `.md` files (the kit, fitforge, flowboard, expense-tracker). **0** lines arm more, and **2** disarm more: the known R2 hit, `specs/014-amendment-authority/ai-code-review-phase-3.md:367-368`. F1's shapes are latent |
| F2 re-check (digest) | These are DIGEST-001 cases built from `pass-wrapped-span` with the correct digest on disk. Round-1 doc 1 gives `OK (2 marker(s))` on `e10da18` and `6f75415`, and stale on `7a770e5`, so it is **closed**. Round-1 doc 2 gives `OK (2 marker(s))` on `e10da18` and a stale digest with exit 1 on both `7a770e5` and `6f75415`, so it is **still open** |
| Feature contract held | No new dependency and no new script. The renderers ran in a scratch directory as measuring tools |
| Constitution / domain invariants | `44f6c94` is a `docs:` commit that lands before `6f75415`. It adds D9 and T014a-T014d, each with `**Amendment approved by**: anas.m, 2026-09-30`, and its message names the approver. `6f75415` changes `tasks.md` by four checkbox ticks only (diff read). `enforcement-pack` graded 8 of 8 commits, OK |
| Security | F1 is a fail-open in the check that refuses invisible approvals |
| Scope guard | `pwsh -File scripts/ritual-checks.ps1`: `scope-check: PASS phase 1 commit 7a770e5 (24 file(s))`, `PASS phase 1 commit 6f75415 (13 file(s))`, `RESULT OK`, exit 0. `6f75415` touches `scripts/markdown-lib.ps1` and `tests/**` (the phase-1 Territory), plus `notes.md` and `tasks.md` |
| Harness, targeted | `Run-Tests.ps1 -Case fail-hidden-`: 43 passed, 0 failed, exit 0. I did not re-run the full suite; `notes.md` records 823/0 |
| Rollback safety | The phase is self-contained: reverting both commits restores the parent function and both callers. No data or schema is involved |

## Findings

### F1 — D9 judges doubt per line, so the round-1 fail-open survives in eight shapes — BLOCKING

**Where**: `scripts/markdown-lib.ps1:130` (`$doubtful`, tested per line at `:135`) and `:183-199`
(the raw HTML block start, which requires a tag at the start of the line). Also `:208-212` and
`:220`: list-item content and deeper-indented lines join the paragraph. The consumer is
`Get-VisibleFromText`, `scripts/enforcement-pack.ps1:887`.

**What**: Every construct D9 names binds before a code span. The rule only asks whether the `<` or
`](` comes before a backtick *on the same line*. But inline raw HTML, link destinations, link titles
and inline comments may all span lines. Two constructs are not named at all: a link reference
definition's destination, and blocks inside list items. Those blocks are an HTML block after `- `
and a fence indented four or more columns, which `Get-FencedLineMap` (`:239`, `^ {0,3}`) does not
see. The misread backtick then pairs with a later one in the same kit paragraph and disarms a real
comment, as in round 1.

**Failing inputs**: each is the amended `plan.md` of an AMEND-001 commit, built from
`fail-hidden-after-unpaired`'s recipe with only this paragraph swapped in. Each expects FAIL, because
the record renders as nothing in both markdown-it 14 and commonmark.js. The results come from
`Invoke-FixtureCase`. Rows a-h are regressions. Row i is safe today and fails open under the
narrowing that `notes.md` proposes.

````text
(a)  - <div>
       Step a ` b <!-- ada has not signed this yet
       **Amendment approved by**: ada, 2026-01-02
       --> done `
       </div>
(b)  the same as (a) with <pre> … </pre>
(c)  - item
         ~~~
         a ` b
         ~~~
       prose <!-- ada has not signed this yet
       **Amendment approved by**: ada, 2026-01-02
       --> stray ` here.
(d)  [ref]: /a`b
     Some prose <!-- ada has not signed this yet
     **Amendment approved by**: ada, 2026-01-02
     --> stray ` here.
(e)  See <span
     title="`">x</span> and <!-- ada has not signed this yet
     **Amendment approved by**: ada, 2026-01-02
     --> stray ` here.
(f)  See [x](/u
     "t`le") and <!-- ada has not signed this yet
     (record, then  --> stray ` here.)
(g)  See [x](
     a`b) and <!-- ada has not signed this yet
     (record, then  --> stray ` here.)
(h)  Intro <!-- note
     x ` y --> then `a --> b` and
     more <!-- ada has not signed this yet
     **Amendment approved by**: ada, 2026-01-02
     --> stray ` here.
(i)  Intro <!-- note ` y --> then `a --> b` and
     more <!-- ada has not signed this yet
     **Amendment approved by**: ada, 2026-01-02
     --> stray ` here.
````

| Document | `e10da18` (parent) | `7a770e5` | `6f75415` (tip) |
|---|---|---|---|
| (a) HTML `div` block in a list item | FAIL, exit 1 (correct) | OK, exit 0 | **OK, exit 0** |
| (b) `pre` block in a list item | FAIL, exit 1 | OK, exit 0 | **OK, exit 0** |
| (c) fence at 4 columns in a list item | FAIL, exit 1 | OK, exit 0 | **OK, exit 0** |
| (d) link reference definition | FAIL, exit 1 | OK, exit 0 | **OK, exit 0** |
| (e) inline tag, attribute on the next line | FAIL, exit 1 | OK, exit 0 | **OK, exit 0** |
| (f) link title on the next line | FAIL, exit 1 | OK, exit 0 | **OK, exit 0** |
| (g) link destination on the next line | FAIL, exit 1 | OK, exit 0 | **OK, exit 0** |
| (h) backtick inside a multi-line inline comment | FAIL, exit 1 | OK, exit 0 | **OK, exit 0** |
| (i) as (h), comment on one line | FAIL, exit 1 | OK, exit 0 | FAIL, exit 1 (correct) |

In (h), the first comment opens before both of the paragraph's misread backticks and stays armed,
as `notes.md` says it would. But the shifted pairing leaves armed a `-->` that sits inside a *real*
code span (`` `a --> b` ``). So the kit's first comment ends there, and the second comment's opener
and closer are disarmed. The record shows. This refutes `notes.md:155-158`, which says that
"a comment that opens before both backticks stays armed, so everything after it is still hidden".
The narrowing proposed there (drop the comment opener from `$doubtful`) makes (i) fail open too. I
checked this with a scratch mutation that removed `!` from the pattern: (i) then shows the record.

**Why the new cases miss it**: all three T014a documents put the binding construct and its backtick
on one line, at top level. The per-line pattern is exactly what they exercise.

**Suggested fix**: judge doubt over the whole paragraph, not per line, and add the missing
constructs. As a sketch, I made a scratch kit where `$flush` also marks the paragraph doubtful when
its joined text matches any of these:

- `(?s)(<[A-Za-z/?]|\]\(|\]:).*` followed by a backtick (a tag, autolink, PI, link or reference
  definition anywhere before a later backtick);
- `(?m)^\s*` followed by a fence run (a fence-like line anywhere);
- `(?s)<!--(?:(?!-->).)*` followed by a backtick and `(?:(?!-->).)*-->` (a terminated comment that
  holds a backtick).

With those, all nine documents above and all seven round-1 variants hide the record, and all 10 of
016's committed cases still pass. That includes the three wrapped-span cases, so GAP-028 stays
fixed. A paragraph-wide `<!` rule is **not** usable: it re-breaks `pass-wrapped-span` and
`fail-wrapped-span`, because a wrapped span quoting `<!--` always has `<!` before a later backtick.
This sketch is a heuristic that I tested only against these documents. It is not a proof. Whatever
the implementer adopts should come with (a)-(i) as AMEND-001 fail directions (or a representative
subset covering each class: next-line construct, reference definition, list-item container, comment
holding a backtick), each shown passing wrongly on `6f75415`.
*Action: implementer fixes in phase 1 through an owner-approved amendment to D9 (its text says
"on the same line"), with the cases; then re-review.*

### F2 — Round-1 F2's second shape (the D5 tail) is still open — CONFIRM

**Where**: `scripts/build-digests.ps1:110` (`$scan = $scan.Substring($close + 3)`).

**What**: The implementer's disposition is accurate. This document drops the second harvested
marker on `6f75415` exactly as it did on `7a770e5`, and `e10da18` harvests both:

````text
Prose that opens a note <!-- mid-line and
closes it a ` b --> then quotes `<!--` in a span.
````

The mechanism no longer involves paragraphs. Line 2 is doubtful, so it is paired per line. But D5
takes the tail from the *whole line's* pairing, where the first backtick pairs with the second.
That strands the quoted `<!--`. The parent paired the tail alone. Round-1's first F2 document is
closed by D9. On the loss question more broadly: on a doubtful or single line, paragraph pairing
cannot arm an opener that per-line pairing disarmed. Per-line pairing can only disarm an opener
that a backtick follows on the same line, and such a line is always doubtful. This D5 tail is the
only loss mechanism I found, and no file in the 564 scanned has it.
*Action: owner decides, as `notes.md` sets out: accept it as covered by phase 2's DIGEST-020 (and add
this document as a direction), or amend D5 so the tail is re-paired alone.*

### F3 — Comments and notes still overclaim — DOC DRIFT

Round-1 F3 is **partially fixed**. The D8 sentence is now future tense ("is scoped to"), and the raw
HTML description at `:107-110` matches the code. The following still overstate the model:

- `scripts/markdown-lib.ps1:20-21`: "only where pairing further than one line cannot disarm a real
  comment". This is false by F1.
- `:90-91`: "a stray backtick in one block cannot pair into a later block and disarm a real comment
  there". This is round-1's sentence, kept. F1 (c) shows a backtick in a fenced block pairing into
  the following paragraph.
- `:91-94`: "Pairing reaches past one line ONLY where that can never disarm more than per-line
  pairing would …". This is false by F1, and the sentence is garbled: it reads as if doubtful
  paragraphs are the ones paired across lines.
- `:98`: "only when every backtick in it can be read as a span delimiter". This describes a goal,
  not the per-line regex.
- New, in `notes.md:144`: "Raw HTML blocks now run to their CommonMark end". That is true only for a
  block whose tag starts the line, and F1 (a)/(b) are not.
- New, in `notes.md:155-158`: the safety claim for narrowing, refuted by F1 (h)/(i).

*Action: implementer rewords these with the F1 fix, to describe the heuristic as a heuristic and
state what it does not catch. Withdraw the narrowing proposal in `notes.md`.*

### F4 — Two `$doubtful` alternatives are guarded by no case — MINOR

**Where**: `scripts/markdown-lib.ps1:130`.

**What**: I made scratch kit mutations and ran all 10 of 016's cases. Removing the `\]\(.*`
alternative (link destination): **0 cases fail**. Removing `!` from `<[A-Za-z/!?]` (the comment
opener): **0 cases fail**. Removing the backslash alternatives fails only
`fail-hidden-backslash-closer`, and removing `<` fails only `fail-hidden-autolink-backtick`. So the
link-destination and comment-opener parts of D9 could be deleted with the suite green. The
comment-opener part is exactly the one `notes.md` proposes to drop, and F1 (i) is what it protects.
*Action: add F1 (i) and a single-line link-destination direction (round-1's `[x](a`b)` shape) with
the F1 cases.*

### Round-1 findings — status

- **F1**: **partially fixed**. All round-1 documents and their variants now hide the record. The
  same fail-open is reachable through the eight shapes in F1 above. BLOCKING remains.
- **F2**: first document **fixed**, second document **open** (confirmed, F2 above), pending the
  owner.
- **F3**: **partially fixed** (F3 above).
- **F4**: **unchanged**. Its shapes predate 016, and `notes.md` records the disposition beside
  T026's gap. I did not re-test them.

## Amendments in this diff

- [x] Amendments listed. `44f6c94` (a `docs:` commit before `6f75415`) amends `plan.md` (adds D9)
  and `tasks.md` (adds T014a-T014d). Each carries `**Amendment approved by**: anas.m, 2026-09-30`,
  and the commit message names the approver. `6f75415` changes `tasks.md` by checkbox ticks only.
  No change to `spec.md` or `contracts/`. The F1 fix will need a further owner-approved amendment,
  because D9's text says "on the same line".

## Constitution re-check (post-implementation)

**FAIL on VI (Security), until F1 is fixed.** The amendment-authority gate still accepts, in shapes
the parent refused, a record that no renderer shows. Otherwise PASS. I: the amendment is approved
and lands before the commit that relies on it. II: no conflict between rungs. IV: no new dependency
or architecture. VIII: pass and fail cases, test-first, and the mutations are recorded and
reproduced, but two alternatives are unguarded (F4). IX: this review. X: one phase, Territory held,
scope-check PASS on both phase commits.

## Test coverage observed

- The three new AMEND-001 fail directions each fail on `7a770e5` (exit 0, the fail-open) and pass
  on `6f75415`. Mutations (c) and (d) kill them as claimed.
- The six round-1 cases still pass. `-Case fail-hidden-` gives 43/0.
- Missing: any case with a binding construct and its backtick on different lines, a reference
  definition, list-item containers, a comment that holds a backtick, a link destination, or the
  comment-opener alternative (F1, F4).

## Residual risk

The risk is concentrated in F1: a fail-open in the check that stops an agent approving its own
amendment. It is latent across 564 files, but it is reachable with ordinary constructs (a reference
definition, a wrapped link, HTML in a list item). Fix it before merge with paragraph-wide doubt and
cases for each class, then re-review. F2 waits on the owner. F3 and F4 travel with the F1 fix.
Every experiment ran in scratch copies. `git status --short` shows no change to the repository
beyond this review file and the pre-existing untracked `.claude/settings.local.json`.
