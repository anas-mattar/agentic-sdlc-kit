# AI Code Review — 016 Multi-line Code Spans (Phase 1, round 3)

**Reviewer**: fresh-context agent — claude-opus-5-5
**Date**: 2026-09-30
**Branches**: agentic-sdlc-kit `016-multiline-code-spans` (tip `8e45e37`)
**Scope reviewed**: phase 1 as three commits: `7a770e5`, `6f75415` and `8e45e37` (the D10 redesign),
read through the net script change `git diff e10da18..8e45e37 -- scripts/`
(`scripts/markdown-lib.ps1`, `scripts/enforcement-pack.ps1`, `scripts/build-digests.ps1`). Also read:
the five new directions in `8e45e37` (AMEND-001 `fail-hidden-list-div`, `fail-hidden-list-pre`,
`fail-hidden-comment-tick`, `fail-hidden-html-block-open`; DIGEST-001 `pass-tail-after-close`), the
`rules.json` and `tasks.md` changes, and the amendment `b58d3f3` (spec FR-002/FR-003, plan D10, tasks
T014e-T014h). Also both earlier reviews, `notes.md` (T014e-T014h), and the full spec and plan.
**Feature contract**: phase 1 = T001-T014h. One shared code-span function with a whole-document
signature. It returns the same line count and line lengths as its input (D1). The result is the parent's
per-line pairing, plus the D10 disarm: an opener that is not fenced, not in a raw HTML block, and has no
`-->` before the next blank line (FR-002, FR-003 as amended). Build-digests precomputes and indexes the
result (D5). No new dependency and no new script. Territory is the three scripts plus `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: claude-opus-5-5 (the implementing session)
- **Inputs provided**: `git diff e10da18..8e45e37 -- scripts/`, `git show --stat` of `7a770e5`,
  `6f75415` and `8e45e37`, and `git show` of `b58d3f3`. For `specs/016-multiline-code-spans/`:
  `ai-code-review-phase-1.md`, `ai-code-review-phase-1-round-2.md`, `spec.md` (FR-001-FR-012, success
  criteria), `plan.md` (D1-D10), `tasks.md` (phase 1 and its Territory) and `notes.md` (T014e-T014h and
  the dispositions). The kit's law (`CLAUDE.md`, `.specify/memory/constitution.md`,
  `docs/sdlc/definition-of-done.md`, `docs/sdlc/review-process.md`), which was loaded as project
  instructions. The review template. `tests/enforcement/lib/Harness.psm1`, which drove cases against
  scratch kit roots. The round-2 reviewer's scratch documents, re-run. Read and run access to the
  working tree. Every experiment ran in a scratch directory outside the repository, using scratch
  copies of the `e10da18` and `8e45e37` scripts, 14 mutation kits and two sketch-fix kits. No
  repository file was modified.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES.** D10 is a much better design than D2/D9. It is simpler, and it removes the
whole class of misread-backtick fail-opens. All 23 documents from rounds 1 and 2 now hide the
record. D1 holds under a 5,000-document fuzz. Mutations (e) and (f) fail the cases `notes.md` names,
which I confirmed in scratch kits. Territory is clean, and `ritual-checks` is green. But the brief's
regression question still gets the answer **yes**. The "cannot be a comment" claim rests on two
inputs, and both are wrong in ordinary cases:

- **The raw-HTML tracker has one state and too few starts.** A paragraph line that merely *begins*
  with inline HTML or an autolink (`<kbd>K</kbd> …`, `<https://…>`) is read as a blank-ending block.
  While that state is set, the tracker ignores a following `<pre>`/`<script>` line. Types 1-5 interrupt
  a paragraph, and that line really does start a block that runs past the blank line. A fence that
  `Get-FencedLineMap` misreads hides the start in the same way.
- **"Blank" is .NET `\s`.** It includes NBSP, form feed and U+3000, and CommonMark's blank line
  does not.

In each case a record that the renderer puts inside a real HTML comment counts as a grant on `8e45e37`,
and the parent refuses it. I ran eight such documents end to end as AMEND-001 commits: `e10da18` gives
`FAIL`, exit 1, and `8e45e37` gives `enforcement-pack: OK`, exit 0 (F1). Three further documents flip
the same way because a `<!--` sits inside a link title, a tag attribute or image alt text. That is
not a comment, but the parent hid it through the unterminated-comment rule, and the comments claim D10
"only ever reveals text a reader sees" (F2). The exposure is latent: over 565 `.md` files in the kit
and the three adopters, D10 changes 3 lines, all correctly. The fix is small. I sketched one in scratch
that closes all eight F1 documents and keeps all 28 AMEND-001 and DIGEST-001 cases green. The other
findings are guard gaps (F4), overclaiming comments (F5), FR-010's wording (F3) and the surviving D5
tail loss (F6).

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-001: one implementation. `Convert-CodeSpanMarkers -Lines` is called once per document by both consumers (`enforcement-pack.ps1:889`, `build-digests.ps1:92`), and `Convert-SpanText` is private to the library. FR-002/FR-003: the three D10 conditions are at `markdown-lib.ps1:115-163` as the plan words them. The claim FR-002 rests on ("no renderer can read [it] as a comment") is false (F1, F2). FR-004: the pre-existing AMEND-001/DIGEST-001 directions pass on `8e45e37` (28/28 in a scratch run). FR-010: see F3 |
| Earlier review documents | All round-2 shapes (a)-(i) and all 14 round-1/extra documents run through `Get-VisibleFromText` (taken from `8e45e37`'s AST) hide the record, as `notes.md` says |
| D1 (count, length, only markers change) | A 5,000-document scratch fuzz (the round-2 reviewer's token set) against `8e45e37`'s library found **0 violations**. The empty-input and single-line edges return `string[]` |
| Mutations (e), (f) | Scratch kits over the 15 016 cases (AMEND-001 `*hidden*`, `*wrapped*`, `*comment-block*`; DIGEST-001 `*wrapped*`, `*comment-block*`, `pass-tail-after-close`). Unmutated: 0 failing. (e): `fail-hidden-autolink-backtick`, `fail-hidden-backslash-closer` and `fail-hidden-comment-tick` fail with exit 0. (f): `fail-hidden-html-block-open` and `fail-hidden-record` fail with exit 0. Both match `notes.md` exactly. My own mutations are in F4 |
| Exposure | The parent's per-line function against `8e45e37`'s, over 565 `.md` files (kit, fitforge, flowboard, expense-tracker): **0** lines arm more, and **3** disarm more (`013…/ai-code-review-logic-round2.md:91`, `014…/ai-code-review-phase-3-remediation.md:169`, `:479`). Each is a `<!--` left outside a span by an adjacent backtick, with no closer in its paragraph, so it is literal text to a renderer, and D10 is right. The original R2 hit (`014…/ai-code-review-phase-3.md:367-368`) is no longer changed: its wrapped span holds `-->` too, so it keeps today's handling. That is the case FR-002 names as not recognised |
| Feature contract held | No new dependency and no new script. The renderers (markdown-it 14, commonmark.js) ran from a scratch directory as measuring tools |
| Constitution / domain invariants | `b58d3f3` is a `docs:` commit that lands before `8e45e37`. It amends spec FR-002/FR-003, plan D10 and tasks T014e-T014h, each carrying `**Amendment approved by**: anas.m, 2026-09-30`, and its message names the approver. `8e45e37` changes `tasks.md` by four checkbox ticks only (diff read). `enforcement-pack` is OK in `ritual-checks` |
| Security | F1 is a fail-open in the check that refuses invisible approvals |
| Scope guard | `pwsh -File scripts/ritual-checks.ps1`: doc-lint, enforcement-pack, scope-check, digests (`5 digest(s) fresh, 82 marker(s)`) and roadmap-claims are OK, `RESULT OK`. The `--stat` of all three phase commits touches only the three scripts, `tests/**`, and the feature's `notes.md`/`tasks.md` |
| Harness | Targeted scratch runs only (the 15 016 cases, and all 28 AMEND-001 and DIGEST-001 directions). I did not re-run the full suite; `notes.md` records 833/0 |
| Rollback safety | The phase is self-contained: reverting its three commits restores the parent function and both callers. No data or schema is involved |

## Findings

### F1 — D10 disarms real comments: the raw-HTML tracker misses block starts, and "blank" is `\s` — BLOCKING

**Where**: `scripts/markdown-lib.ps1:125` and `:156` (`'^\s*$'`), `:127-131` (a set `$htmlEnd` is never
re-examined, and a line `Get-FencedLineMap` calls fenced is never examined), and `:133` (any
tag-initial line opens a blank-ending block). The consumer is `Get-VisibleFromText`,
`scripts/enforcement-pack.ps1:889`.

**What**: D10's safety claim needs two facts to be exactly right: which lines are raw HTML, and where
a blank line is. Three mechanisms break them:

1. **A tag-initial paragraph line occupies the tracker.** `<kbd>K</kbd> is the key.` or
   `<https://example.com> has the detail.` is a paragraph to CommonMark: it is not a type-7 start,
   because the tag is not alone on its line, and an autolink is not a tag. The code reads it as a
   block that ends at a blank line. A `<pre>`, `<script>`, `<style>` or `<textarea>` line directly
   under it is a real type-1 start, since types 1-5 may interrupt a paragraph. That block runs past
   the blank line to `</pre>`. The code is already "in HTML", so it never sees that start, and it
   leaves HTML at the blank. An opener after the blank, inside the renderer's `<pre>`, is then
   "inline" and gets disarmed. The comment's generous reading (`:105-106`, "so more lines stay on the
   per-line result, never fewer") is what produces *fewer*.
2. **A fence misread hides the start.** On `` ``` x`y ``, which is not a fence in CommonMark because
   the info string holds a backtick (round-1 F4), `Get-FencedLineMap` opens a fence. The `<pre>` on the
   next line is then skipped by `elseif (-not $fenced[$i])`, and the map closes the fence on the next
   ```` ``` ````. In the renderer that `<pre>` block is still open.
3. **Unicode whitespace is "blank".** .NET `\s` matches NBSP, form feed, vertical tab and U+3000.
   CommonMark's blank line is spaces and tabs only, so an NBSP-only line continues the paragraph, and
   an inline comment runs straight through it. The same regex also ends a blank-ending HTML block
   early (`:129`).

**Failing inputs**: each is the amended `plan.md` of an AMEND-001 commit. It is built from
`fail-hidden-after-unpaired`'s recipe with only this body swapped in (`R` is
`**Amendment approved by**: ada, 2026-01-02`, and `␣` is U+00A0). Each expects FAIL, because both
markdown-it 14 and commonmark.js put the record inside a comment, which the browser then hides.
Results come from `Invoke-FixtureCase`:

````text
(j1) <kbd>K</kbd> is the key to press.      (j2) as j1, first line <https://example.com> has the detail.
     <pre>                                  (j3) as j1, with <script> … </script>
                                            
     Step a <!-- ada has not signed this yet
                                            
     R
     -->
     </pre>
(l1) ``` x`y                                 (k1) Some prose <!-- ada has not signed this yet
     <pre>                                        ␣
     ```                                          R
     z <!-- ada has not signed this yet           --> the rest.
                                             (k2) as k1 with a form feed; (k3) with U+3000
     R                                       (k4) <div> / ␣ / x <!-- … / (blank) / R / --> / </div>
     -->
     </pre>
````

| Document | `e10da18` (parent) | `8e45e37` (tip) | sketch fix (below) |
|---|---|---|---|
| (j1) `<kbd>` line, then `<pre>` | FAIL, exit 1 (correct) | **OK, exit 0** | hidden |
| (j2) autolink line, then `<pre>` | FAIL, exit 1 | **OK, exit 0** | hidden |
| (j3) `<kbd>` line, then `<script>` | FAIL, exit 1 | **OK, exit 0** | hidden |
| (l1) misread fence hides a `<pre>` start | FAIL, exit 1 | **OK, exit 0** | hidden |
| (k1) NBSP line inside an inline comment | FAIL, exit 1 | **OK, exit 0** | hidden |
| (k2) form-feed line | FAIL, exit 1 | **OK, exit 0** | hidden |
| (k3) U+3000 line | FAIL, exit 1 | **OK, exit 0** | hidden |
| (k4) NBSP line ends a `div` block early | FAIL, exit 1 | **OK, exit 0** | hidden |

These are real comments: the kit's comment model and both renderers agree that they are comments. The
parent hides each record for the right reason, because its opener and closer pair. This is not the
"not modelled" mid-line-opener shape. No committed case exercises any of them. `fail-hidden-html-block-open`
starts its block on a clean `<div>` line with ASCII blank lines.

**Suggested fix** (a sketch, tested only against these documents and the harness). I made the
following changes in a scratch copy of the library, run in a scratch kit:
(a) Blank is `'^[ \t]*$'` at `:125` and `:156`.
(b) A line whose body starts a type 1-5 block is examined whether or not `$htmlEnd` is already
`'blank'`, and whether or not the fence map calls it fenced. It switches the tracker to the longer
end. Both changes only move lines back to the per-line result.
All eight documents then hide the record, and all 28 AMEND-001 and DIGEST-001 directions pass. The
exposure over 565 files is unchanged (the same 3 lines). Mutation `l-blankFix`, which is (a) alone,
also keeps the 15 016 cases green. Worth considering as well: GAP-028's opener always has an unpaired
backtick before it on its line. Disarming only such an opener (a further scratch variant) also hides
F2's documents, keeps all 28 cases green, and meets FR-010 (F3). It is a narrowing, not a proof. Add
(j1), (l1), (k1) and (k4), or a representative subset of the three mechanisms, as AMEND-001 fail
directions, each shown passing wrongly on `8e45e37`.
*Action: implementer fixes in phase 1 through an owner-approved amendment to D10 (its block-start and
blank-line wording), with the cases; then re-review.*

### F2 — A `<!--` inside a link title, tag attribute or image alt now reveals a record the parent hid — CONFIRM

**Where**: `scripts/markdown-lib.ps1:151-160`. The claim is at `:96-98` and in plan D10 ("disarming it
reveals only text a reader sees").

**What**: A link reference definition's title, an inline tag's attribute value and image alt text may
all span lines. None of them is visible text. If one holds a `<!--`, the parent's unterminated-comment
rule hides everything after it, the record included. D10 disarms the opener, because it really is not
a comment, and the record counts:

````text
(m1) [ref]: /url "a title <!-- note     (m2) See <span title="<!-- note     (m3) ![a picture <!-- note
     R                                        R                                  R
     "                                        ">x</span> here.                   ](x.png)
````

End to end, all three give `FAIL`, exit 1 on `e10da18` and `OK`, exit 0 on `8e45e37`. Both renderers
show no record text in any of them. I rank this below F1 on purpose. The same documents *without*
the `<!--` count the record on both commits, which I checked: this is the kit's known blind spot for
non-comment hiding, and the parent refused it only by accident. It does answer the brief's question on
its letter, and it refutes "only ever reveals text a reader sees". The backtick narrowing in F1 closes
these three documents. It would not close them if a backtick were added before the opener.
*Action: owner decides whether this is accepted as the existing non-comment blind spot (record it
beside T026's gap with the round-1 F4 shapes) or closed with the backtick narrowing. Either way, the
comment and D10 stop claiming it cannot happen (F5).*

### F3 — FR-010's "no additional work on lines with no backtick" no longer holds — CONFIRM

**Where**: `scripts/markdown-lib.ps1:113-163`, and spec FR-010, which is not amended.

**What**: The only early return is document-wide (`:115`, no `<!--` anywhere). In any document with
an opener, every line gets the container regex and the HTML-block tests. Every armed opener, with or
without a backtick, gets a forward scan to the next blank line. (k1) has no backtick at all, and D10
still rewrote it. No child process is added, and I did not measure the time (SC-006 is scheduled for
ship). FR-010 as worded is not met, though the amendment preamble reads only stories, edge cases,
entities and success criteria through the new FR-002/FR-003, not FR-010.
*Action: owner decides: amend FR-010's wording to D10's shape, or adopt the backtick narrowing (F1),
which restores it for the disarm step.*

### F4 — Load-bearing parts of the tracker are guarded by no case — MINOR

**Where**: `scripts/markdown-lib.ps1:119` (`$container`), `:135` (the type-1 end), and `:125`/`:156`.

**What**: I mutated scratch kits and ran the 15 016 cases:

| Mutation | 016 cases failing | Load-bearing? (my guard documents, `Get-VisibleFromText`) |
|---|---|---|
| (e) closer check removed | 3, as `notes.md` says | yes |
| (f) raw-HTML exclusion removed | 2, as `notes.md` says | yes |
| container regex reduced to indentation only | **0** | yes: `- <div>` / `  x <!--` / blank / record, and the same under `> `, both reveal the record |
| list alternative removed | **0** | yes (the list-item `div` document) |
| block-quote alternative removed | **0** | yes (the block-quote `div` document) |
| type-1 end replaced by a blank-line end | **0** | yes: `<pre>` / blank / `x <!--` / blank / record / `-->` / `</pre>` reveals it, and the parent hides it |
| comment, PI, CDATA or declaration end replaced by a blank-line end | 0 | not found: an opener inside a comment block leaves the block's own opener armed, which already hides to the closer |
| same-line end rule removed | 3 (`fail-wrapped-span`, `pass-wrapped-span`, `pass-tail-after-close`) | guarded, fail-closed direction |
| closer search from the 5th character, not the 3rd | 0 | no (only `<!-->`/`<!--->`, which hide nothing) |
| fenced-line skip removed | 0 | no (the caller disarms fenced lines itself) |
| blank as `[ \t]*` (F1 fix a) | 0 | n/a; it keeps all cases green |

`notes.md` T014h says four raw-HTML documents (a `div`, a `div` in a list item, a `pre`, and a `div` in a
block quote) stay hidden and fail under (f). Only the top-level `div` was committed, which is why the
container regex and the type-1 end can be deleted with the suite green. `fail-hidden-list-div` and
`fail-hidden-list-pre` fail under neither (e) nor (f), which `notes.md` already records. So neither
shows that the container regex matters.
*Action: commit the list-item, block-quote and `pre` guard documents as AMEND-001 fail directions with
the F1 fix, and record a container-regex mutation and a type-1-end mutation beside (e) and (f).*

### F5 — Comments and notes overclaim the rule — DOC DRIFT

- `scripts/markdown-lib.ps1:24-25`, `:88`, `enforcement-pack.ps1:861-862` and `build-digests.ps1:138`
  say "an opener that no renderer can read as a comment". This is false by F1.
- `markdown-lib.ps1:96-98`: "The change only ever reveals text a reader sees, so the result is never
  less strict than the per-line reading about a real comment". False by F1 (real comments) and by F2
  (text no reader sees).
- `markdown-lib.ps1:105-106`: "so more lines stay on the per-line result, never fewer". False by F1
  (j1)-(j3): the generous start is what hides the real one.
- Plan D10, "No renderer reads such an opener as a comment, so disarming it reveals only text a reader
  sees", is the same claim in the approved plan.
- `notes.md` T014h, round-1 F2: "it is now moot for these two documents". That is true of the two
  documents, but the mechanism survives (F6).

Round-2 F3's specific sentences are gone. The new text is more careful, since it names the two
unmodelled shapes, but it still states the safety claim as a proof.
*Action: implementer rewords these with the F1 fix, as a rule with named exclusions and not an
impossibility claim.*

### F6 — The D5 tail can still lose a harvested marker the parent kept — CONFIRM (owner-accepted class)

**Where**: `scripts/build-digests.ps1:110` (`$scan = $scan.Substring($close + 3)`).

**What**: The tail after a mid-line close still comes from the *whole line's* pairing. D10 rescues
round-1 F2's second document only because no `-->` follows its stranded opener. Add one, inside a
real span, and the loss returns:

````text
Prose that opens a note <!-- mid-line and
closes it a ` b --> then `<!--` and ``-->`` x.

<!-- digest: Rule two. -->
````

`Get-DocMarkers` from each script's AST gives 1 marker on `e10da18` and **0** on `8e45e37`. markdown-it
reads lines 1-2 as one inline comment followed by two code spans, so the marker is real and the parent
is right. The digest direction otherwise only gains: D10 disarms, so `$inComment` is set less often. A
marker is lost only where the renderer agrees it sits in a real fence. The owner accepted this
mechanism as phase 2's DIGEST-020 on 2026-09-30, and this shape *is* reported by DIGEST-020 (the marker
is skipped with a comment open).
*Action: none in phase 1 beyond F5's wording; add this document as a DIGEST-020 direction in phase 2
(T016).*

### Earlier findings — status

- **Round 1 F1** (paragraph pairing disarms a real comment): **fixed**. Paragraph pairing is removed,
  and all seven round-1 documents and their variants hide the record. The fail-open *class* reopens
  through a different mechanism (F1 above).
- **Round 1 F2** (marker loss): both documents are **fixed** (each harvests 2 markers on `8e45e37`,
  and `pass-tail-after-close` passes). The second document's mechanism is **open** in a variant
  (F6), within the owner's phase-2 acceptance.
- **Round 1 F3** (overclaiming comments): its sentences are **fixed**, and new overclaims replace
  them (F5).
- **Round 1 F4** (pre-016 fail-opens): **unchanged**, as dispositioned beside T026. It now also
  feeds F1 (l1).
- **Round 2 F1** (per-line doubt, shapes a-h): **fixed** for all nine documents, and three are
  committed as cases. BLOCKING moves to F1 above.
- **Round 2 F2** (D5 tail): **fixed for its document**, and the mechanism survives (F6). The owner's
  decision stands.
- **Round 2 F3** (overclaims): **partially fixed** (F5).
- **Round 2 F4** (unguarded `$doubtful` alternatives): **no longer applies**, since D9's pattern is
  gone. The same gap recurs for D10's container regex and type-1 end (F4).

## Amendments in this diff

- [x] Amendments listed. `b58d3f3` (a `docs:` commit before `8e45e37`) amends spec FR-002/FR-003 and
  adds the preamble that reads the stories and success criteria through them. It also adds plan D10
  (superseding D2, D3 and D9) and tasks T014e-T014h. Each carries `**Amendment approved by**: anas.m,
  2026-09-30`, and the commit names the approver. `8e45e37` changes `tasks.md` by checkbox ticks only.
  No change to `contracts/`. The F1 fix will need a further owner-approved amendment to D10 (and
  FR-003's block-start sentence), and F3 may need one to FR-010.

## Constitution re-check (post-implementation)

**FAIL on VI (Security), until F1 is fixed.** The amendment-authority gate accepts, in shapes the parent
refused, a record inside a real comment that no renderer shows. Otherwise PASS. I: the amendment is
approved and lands before the commit that relies on it. II: no conflict between rungs, though FR-010
and D10 disagree (F3). IV: no new dependency or architecture. VIII: pass and fail cases, test-first,
and (e)/(f) recorded and reproduced, but the container regex and type-1 end are unguarded (F4). IX:
this review. X: one phase, Territory held, and `scope-check` is OK.

**Success criteria against the amended spec**: SC-001's first half is met (the wrapped document
harvests every marker), and its second half is phase 2. SC-002 is met for the committed cases, but the
property it stands for is not (F1). SC-003 is met on Windows; Linux is not checked by me. SC-004: the
green-turning half is shown by mutation (a). The guard half, worded as "the paragraph boundary
removed", no longer maps onto D10. (e) and (f) stand in for it, and two committed guards fail under
neither, so SC-004 is now measured only by the recorded substitute mutations. SC-005: the kit's digests
are fresh (82 markers); the adopters are for ship. SC-006: not yet measured (ship). SC-007: phase 2.
FR-012's "GAP-028 recorded as closed" should say which shape is closed: the kit's only real instance
(`014…/ai-code-review-phase-3.md:367-368`) wraps a `-->` as well and is deliberately left unchanged.

## Test coverage observed

- The five new directions behave as `notes.md` says. The three round-2 shapes pass on `8e45e37`, the
  `div` guard holds, and `pass-tail-after-close` harvests both markers. (e) and (f) kill the cases
  they name.
- All 28 AMEND-001 and DIGEST-001 directions pass on `8e45e37` and on the sketch fix.
- Missing: any case with a tag-initial paragraph line before a type-1 block, a misread fence before a
  block start, a non-ASCII whitespace line, or a raw HTML block inside a list item or block quote with
  the opener after the blank line (F1, F4).

## Residual risk

The risk is concentrated in F1: a fail-open in the check that stops an agent approving its own
amendment. It is reachable with ordinary Markdown (a line starting with `<kbd>` or an autolink above a
`<pre>`) and with invisible characters (an NBSP-only line). It is latent across 565 files. The fix is
two small, conservative changes plus cases, and it fits D10's structure. Fix it before merge, then
re-review. F2 and F3 need owner decisions, F4 and F5 travel with the F1 fix, and F6 is phase 2's.
Every experiment ran in scratch copies. `git status --short` shows no change to the repository beyond
this review file and the pre-existing untracked `.claude/settings.local.json`.
