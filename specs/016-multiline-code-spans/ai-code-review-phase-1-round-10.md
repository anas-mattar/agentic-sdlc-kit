# AI Code Review — 016 Multi-line Code Spans (Phase 1, round 10)

**Reviewer**: fresh-context agent — claude-opus-5-5
**Date**: 2026-10-03
**Branches**: agentic-sdlc-kit `016-multiline-code-spans` (tip `5caedb7`)
**Scope reviewed**: the round-9 remediation, `git diff 8306a96..5caedb7`. That is the amendment
`bf68130` (spec FR-003, plan D11 and tasks T014r, each "amended after the phase-1 round-9
review") and the fix `5caedb7`. The fix changes comments only in `scripts/markdown-lib.ps1`: the
"Not modelled either" paragraph is restated by mechanism, and `title` is named as RCDATA. It also
adds two DIGEST-001 pins (`fail-modelled-rule-long-end-not-modelled` and
`fail-paragraph-long-end-not-modelled`), the `notes.md` section "Phase 1 round-9 remediation
(T014r)" with its corrections to the T014q record, and the T014r tick. I also read the whole
branch against its base (`git merge-base main HEAD` = `a1258c5`) for regressions and scope.
**Feature contract**: phase 1 = T001-T014r. The amendment check keeps the parent's per-line
reading, unchanged (D11). The digest generator uses the whole-document rule
(`Convert-CodeSpanMarkers`). FR-003 as amended after round 9: the fix "never changes the lines of
an HTML comment block or of a raw HTML block" **except where such a block begins inside a span
the tracker holds and CommonMark does not**. This exception is stated by mechanism, and the
round-8 routes are given as instances, not bounds. The Out of Scope line on indented code and
lazy continuation holds except through that exception. No new dependency and no new script.
Territory is the three scripts plus `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: claude-opus-5-5 (the implementing session)
- **Inputs provided**: I read `git diff 8306a96..5caedb7` in full, plus `git show` of `bf68130`
  and `5caedb7` (message, stat, and the `tasks.md` hunk between them) and `git log` of the branch.
  From `specs/016-multiline-code-spans/` I read: `spec.md` (FR-001 to FR-012, every amendment
  block, Out of Scope), `plan.md` D11 with its round-7, round-8 and round-9 amendment blocks,
  `tasks.md` (Territory, T014m-T014r and their approval records), `notes.md` (T014q and T014r
  sections), and `ai-code-review-phase-1-round-9.md` in full. I also read the two new recipes,
  the three round-8 pin recipes, the review template in `specs/_templates/`, and the kit's law
  (`CLAUDE.md`, `.specify/memory/constitution.md` I and II, `docs/sdlc/definition-of-done.md`,
  `docs/sdlc/review-process.md`), which was loaded as project instructions. I had read and run
  access to the working tree.

  Every experiment ran in my own `…/D--solutions-agentic-sdlc-kit/r10-review/`. That directory
  holds `git archive` kits of `5caedb7`, `e10da18`, `c81a12d` and `3ad7408` (each with
  `git init`), plus three `5caedb7` kits with the three scripts of `e10da18`, `c81a12d` or
  `3ad7408` swapped in. It also holds `git show` copies of the scripts at `5caedb7`, `e10da18`,
  `c81a12d` and `3ad7408`, two mutation kits, a token and call-graph comparer (`tok.ps1`), my
  own door mutations (`mut10.ps1`), a tracker-state recorder (`trk.ps1`), a generator and
  oracle (`fuzz.js`) with its classifier (`classify.js`), ten hand probes (`docs/e01`-`e10`) and
  20,000 generated documents (`fz2`-`fz5`).

  I reused some tooling read-only. From the round-8 reviewer: `mut.ps1` (MD5 `0d46111d…` before
  and after the run), `corpus.ps1`, `harvest.ps1` and `render7.js` (markdown-it 14.3.2,
  commonmark.js 0.31.2, then a simplified HTML5 tokenizer, whose tokenizer code I copied into
  `fuzz.js`). I also reused the round-5 lists `list.txt` and `rlist.txt`, and the probe
  documents of rounds 1-9, including round 9's `docs/d01`-`d08` and `docs2`.

  I did not use the implementer's output: I re-ran every number I cite. `git hash-object
  scripts/markdown-lib.ps1` was `3ff54f4…` before and after. No repository file other than this
  review was modified.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE.** Round-9 F1 is closed as option (b) asked. FR-003's exception is now defined by
mechanism: "a span the tracker holds and CommonMark does not". The spec, the plan, the tasks, the
library paragraph and the Out of Scope reconciliation all say this, and the round-8 routes appear
as instances. Round 9's `d01`-`d06` all fall inside the operative wording.

The two new pins hold their families:

- Each pin passes on `5caedb7` (and on `c81a12d`'s and `3ad7408`'s scripts).
- Each pin fails on `e10da18`'s scripts, which report a fresh digest with exit 0.
- Each pin flips under a mutation that removes only its door.

I also ran a 20,000-document generated search with a block-structure classifier. Every disarm
that lands in a CommonMark raw HTML block (328 of them) is on a block that began while the
tracker held a long-end span. Every comment-hidden marker that `5caedb7` harvests and the parent
does not (74) is explained by the restated mechanism. Nothing found reaches outside it.

The security gate is untouched:

- `enforcement-pack.ps1` and `build-digests.ps1` are byte-identical to `3ad7408`.
- The library's non-comment token stream equals `3ad7408`'s.
- The amendment check's call graph does not reach `Convert-CodeSpanMarkers`, and it reads as
  the parent `e10da18` does.

Every number in `notes.md` reproduces: suite 891/0, the mutation table, corpus 567 and review
documents 91 at parity, and 194 probe documents.

The findings:

- F1 (minor): a third kind of cause is missing from the exception's list of causes. The tag-line
  rule can match a raw-text start tag inside an attribute value or a code span.
- F2 (minor): wording nits.
- F3 to F6 carry over unchanged.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Code equals `3ad7408` | `git diff --quiet 3ad7408 5caedb7 -- scripts/enforcement-pack.ps1 scripts/build-digests.ps1`: exit 0. `git diff 8306a96..5caedb7 -- scripts/` is one comment hunk in `markdown-lib.ps1`. `tok.ps1` (PowerShell tokenizer; comments, newlines, continuations and end-of-input dropped): `markdown-lib.ps1` 975 tokens, `enforcement-pack.ps1` 5241, `build-digests.ps1` 934, each **identical** to `3ad7408` (the notes' 976 counts end-of-input). Of the library's 4 functions, only `Convert-CodeSpanMarkers`'s extent text differs (its comment) |
| Security gate: parity with `e10da18` | On `5caedb7`, the amendment check reaches 14 functions: `Convert-SpanText`, `Disable-CommentMarkers`, `Get-AddedRecordLines`, `Get-BlobLines`, `Get-CheckPresenceSet`, `Get-CommitMetaBatch`, `Get-ConformingRecord`, `Get-FencedLineMap`, `Get-NameStatusBatch`, `Get-VisibleFromText`, `Invoke-AmendmentAuthorityCheck`, `Test-CheckAbsentForReal`, `Test-CheckboxOnlyChange`, `Test-StatusOnlyChange`; `reaches Convert-CodeSpanMarkers: False`. 12 are token-identical to `e10da18`. `Convert-SpanText` (222 tokens) equals the parent's per-line `Convert-CodeSpanMarkers` once the name and `$Line`→`$Text` are normalised. `Get-VisibleFromText` differs only in calling `Convert-SpanText -Text` where the parent called `Convert-CodeSpanMarkers -Line`. `git grep` finds one call of `Convert-CodeSpanMarkers`, at `build-digests.ps1:92` |
| Full suite | `pwsh -File tests/enforcement/Run-Tests.ps1` on the `5caedb7` kit: **891 passed, 0 failed, 0 skipped**, `enforcement-tests: OK`, exit 0. Matches `notes.md` |
| Ritual and scope | `pwsh -File scripts/ritual-checks.ps1` on the working tree: `RESULT OK`, exit 0. doc-lint, enforcement-pack, scope-check, digests (5 fresh, 82 markers) and roadmap-claims are OK; scope-repos and verify-kit are n/a. `pwsh -File scripts/scope-check.ps1`: `PASS phase 1 commit 5caedb7 (9 file(s))`, exit 0. `bf68130` is not a phase commit |
| Pins on `5caedb7` / `c81a12d` / `3ad7408` | `-Case DIGEST-001` (35 cases): the `5caedb7` kit gives **103 passed, 0 failed**. The `5caedb7` kit with `c81a12d`'s scripts gives 103/0, and with `3ad7408`'s scripts 103/0. The two pins copied into a bare `3ad7408` kit give 97/0 |
| Pins on `e10da18` | The `5caedb7` kit with `e10da18`'s three scripts gives **85 passed, 18 failed**. The failures are the five long-end pins, `fail-reopen-not-modelled`, `fail-wrapped-span`, `pass-wrapped-span` and `pass-wrapped-after-closed-pre`, two assertions each, which matches `notes.md`. Each new pin observes `digests: OK (1 digest(s) fresh, 1 marker(s))`, exit 0. The two pins copied into a bare `e10da18` kit give 37 passed, 4 failed: exactly the two pins |
| Each pin flips when its door is removed | `mut10.ps1`, the `5caedb7` kit, `-Case DIGEST-001`. **`r-para`** (no long-end start on a 4+-indented raw line that follows a non-blank line, i.e. a paragraph continuation) gives 101/2 and fails **only** `fail-paragraph-…`. **`r-tagline`** (a tag line no longer takes a raw-text element's end) gives 99/4: `fail-modelled-rule-…` plus its round-5 guard `pass-hidden-script-after-tag`. `r-indent` gives 99/4 (`fail-indented-…` and `fail-paragraph-…`, as expected since both doors are an indented start), and `r-container` gives 101/2 (`fail-container-…` only). `restored: True` |
| Mutations (round-8 runner, `5caedb7` kit, 35 cases) | none 103/0. (e) 99/4: `after-backslash-spans`, `nbsp-line`. (f) 63/40: 20 guards. (g) 101/2: `nbsp-line`. (h) 101/2: `pre-under-tag-line`. (i) 91/12: six guards. `j-long` 101/2: `fail-fence-…` only. (j) 101/2: `div-in-misread-fence`. (k) 93/10: `fail-container-…` and four container guards. (l1), (l3) and (l4) 101/2 each, the matching guard. (l2) 91/12: the four PI pins (fence, indented, container, paragraph) and the two PI guards. (m) 99/4: `fail-modelled-rule-…` and `script-after-tag`. (n) 95/8: four guards. (o) 101/2: `wrapped-after-closed-pre`. **`c1` 103/0** (F4). `p-reapply` 97/6: the reopen pin and the two reopen guards. `restored: True`. Every row matches `notes.md` |
| Corpus | The 567-file list and the 91 review documents, run through `corpus.ps1` (markers plus SHA-256 of the scan lines), with the `3ad7408` and `5caedb7` libraries on the same contents: **byte-identical** on both. The marker column also equals `e10da18`'s on all 567 corpus files. On the review documents it differs from `e10da18` in three, all known: `d3-wrapped` (the fix), `e1-tab-blank` (FR-002) and `d1-tail-sameline` (F5) |
| Probe documents (194) | `notes.md` does not name its 15 directories. I rebuilt the set as follows: rounds 5-8 (8 directories, 102), round 9's `docs` (8) and `docs2` (6), and the five earliest review-round probe directories (`review/docs` 15, `review2/docs` 9, `review2/docs1` 14, `review4/docs` 17, `review5/docs` 23). That is **194 in 15 directories**. `3ad7408` and `5caedb7` give **byte-identical** harvests. Round 9's `d01`-`d06` harvest `Hidden rule. \| Visible rule.` (the parent: `Visible rule.`), and `d07`/`d08` harvest `Visible rule.` |
| Generated search (oracle-backed) | I generated 20,000 documents (4 seeds × 5,000) from 80 line shapes (all four raw-text tags and their ends, PI, declaration, CDATA, comment, type-6/7 tags, attribute-embedded tags, code spans, fences, indented code, quotes, `-`/`*`/`+`/`1.`/`2.`/`1)` markers, tabs), each with an unclosed `x <!--`, a hidden marker H and a visible marker. `trk.ps1` records the tracker's state on entering each line and the lines where `5caedb7`'s scan differs from per-line `Convert-SpanText`, i.e. the disarms. commonmark.js and markdown-it give the `html_block` line ranges. **Results:** 1,877 documents had a disarm. 328 disarmed lines lie inside a CommonMark raw HTML block (by either renderer), and **all 328** sit in a block that began on a line where the tracker held a long-end span (0 unexplained). 1,644 documents harvest H where `e10da18` does not. In 388 of those, both renderers hide H. Of those 388, **74** are hidden in a real comment, and all 74 involve a masked block (0 unexplained). The other 314 sit inside a `script`, `style` or `textarea` element, which is the library's recorded "not modelled" raw-text class. 239 of them have no CommonMark block at the disarm (inline elements) |
| Amendment | `bf68130` is a `docs:` commit. It lands before `5caedb7`, touches only `spec.md`, `plan.md` and `tasks.md`, and names `anas.m, 2026-10-03` in its subject and body. It adds `**Amendment approved by**: anas.m, 2026-10-03` after the FR-003 block, after the D11 block, and after T014r (added unticked). Between `bf68130` and `5caedb7`, the only change to `tasks.md` is T014r's checkbox. `contracts/` is unchanged |
| Scope guard | Outside `specs/016-*/` and `tests/`, `git diff --name-only a1258c5..5caedb7` lists only the three scripts. `5caedb7` touches `markdown-lib.ps1` (comments only), `tests/**`, and the feature's `notes.md`/`tasks.md`. No package, manifest or workflow is touched |

## Findings

### F1 — The exception's list of causes misses a third kind: a raw-text start tag inside an attribute or a code span — MINOR (non-blocking)

**Where**: `spec.md` FR-003 round-9 block ("— whether because the tracker misreads block
structure (a fence, an indented code block, a container, a paragraph continuation) or because it
follows the browser into an element that CommonMark's block does not contain —");
`scripts/markdown-lib.ps1:132-143` ("whether because it misreads block structure or because it
follows the browser …"). The code involved is the round-5 tag-line rule at `:176-177`, which
matches `<(pre|script|style|textarea)(\s|>|$)` anywhere on a line that begins with a tag.

Three probes in `r10-review/docs/` harvest a hidden marker. markdown-it and commonmark.js both
hide H in a real comment (`H=hid:comment V=VIS`), and `e10da18` harvests `Visible rule.` only:

| Probe | First line | What the tracker holds |
|---|---|---|
| `e01` | `<a title="<script>">`, then blank / `<?y` / `</script>` / blank / `x <!--` / blank / H / `?>` | A script span. Neither CommonMark nor the browser has a script element here, because the tag is an attribute value |
| `e03` | `<div title="<pre>">`, the same shape with `</pre>` | The same, for `pre` |
| `e04` | ``<b>`<script>`</b>``, the same shape as `e01` | A script span opened from inside a code span, which renders as `&lt;script&gt;` |

In none of these does the tracker misread block structure or follow the browser into an
element. It reads an element that does not exist.

**Why this is not blocking.** Each probe is inside the exception as written. The defining clause
("wherever the … tracker holds a block with a long end … that CommonMark does not hold at that
line") and the operative bullet ("holds except where such a block begins inside a span the
tracker holds and CommonMark does not") are stated by mechanism, with no list of causes. My
classifier puts all three in the masked class, as it does for the 74 generated cases. The
library already says "The doors are examples, not a closed list". Only the parenthetical
"whether because … or because …" reads as exhaustive. This is the distinction round 9 drew: what
it asked for was an exception that does not need a complete list, and the operative text no
longer has one. None of the three is a regression, since the code is token-identical to
`3ad7408` and `517f9d2`'s rule is the same. Corpus exposure is nil.

*Action: optional, at the next amendment. Make the cause clause explicitly non-exhaustive (for
example, "for instance because …"), and name among the library's doors "a tag line whose
raw-text start tag sits in an attribute value or a code span". No pin is needed: `e01`/`e04`
enter through the same tag-line door as `fail-modelled-rule-long-end-not-modelled`, and
`r-tagline`/(m) flip that pin.*

### F2 — Wording nits — MINOR (non-blocking)

- `spec.md` round-9 block: "it ignores the block starts CommonMark reads until its own end, and
  then returns to inline text". The library says "the end returns to inline text (or to a block
  that ends at a blank line)", and the new pin `fail-modelled-rule-…` goes through exactly that
  resume to `'blank'`. The spec is the less precise of the two.
- The three round-8 pin descriptions still say "This is FR-003's named exception as amended
  after round 8" and "If the route is ever modelled". They are still true, since the routes are
  instances, but the label predates the restatement.
- `notes.md` gives "194 in 15 directories" without naming the directories. The figure
  reproduces (see the evidence table), but only by reconstruction.

*Action: optional.*

### F3 — `j-long` is caught only by a pin — CONFIRM (recorded)

`j-long` gives 101/2 and fails only `fail-fence-long-end-not-modelled`, as recorded in D11 and
`notes.md`.
*Action: none.*

### F4 — `c1` is still unguarded — CONFIRM (owner-accepted, recorded)

`c1` gives 103/0. This is recorded in D11 (round 5).
*Action: none.*

### F5 — The D5 tail still loses a marker the parent kept — CONFIRM (owner-accepted, phase 2)

Unchanged: `d1-tail-sameline` harvests nothing on `5caedb7` and `Rule two.` on `e10da18`.
*Action: none in phase 1. DIGEST-020 direction in T016.*

### F6 — FR-010's wording — MINOR (carried)

`spec.md` is in this diff, but FR-010 is not reworded.
*Action: the owner may reword; no code change.*

## Earlier findings — status

- **Round 9 F1** (six doors outside the three named routes): **closed**. The exception is
  restated by mechanism in the spec (the definition and the operative bullet), the plan, the
  tasks, the library paragraph and the Out of Scope reconciliation. `d01`-`d06` fall inside its
  operative wording, and one pin per unpinned family (`d01` modelled-rule, `d05` paragraph) was
  shown stale on `c81a12d`/`3ad7408` and fresh on `e10da18`. Each flips under its own door
  mutation. The list of causes remains a residual wording gap (F1, minor).
- **Round 9 F2** (nits): **resolved**. The spec and the plan's round-9 block both read "rounds 4,
  5, 7, 8 and 9", and the spec records that it replaces "Five review rounds". `notes.md` states
  the setup behind the `e10da18` counts (85/14 with 33 cases, now 85/18 with 35, both of which I
  reproduced at 35) and corrects the probe count to 102. `title` is named as RCDATA.
- **Round 9 F3-F6**: carried as F3-F6 above.
- **Rounds 1-8**: unchanged. The amendment check's code equals `e10da18`'s reading.

## Amendments in this diff

- [x] Amendments listed. `bf68130` (a `docs:` commit before `5caedb7`) amends spec FR-003, plan
  D11 and tasks T014r. Each block closes with `**Amendment approved by**: anas.m, 2026-10-03`,
  and the commit subject and body name the same approver and date. `5caedb7` ticks T014r only.
  Every T014r sub-step is done and recorded: the two pins shown on `c81a12d` and `e10da18`, the
  paragraph, `title`, token parity, the suite, mutations, corpus, review documents, probes, and
  the F2 corrections. `contracts/` is unchanged.

## Constitution re-check (post-implementation)

**PASS on VI (Security).** The amendment-authority gate's code, and every function it reaches,
is token-identical to `3ad7408`, and its reading equals the parent `e10da18`'s. AMEND-001 is
green in the 891-test suite.

**PASS on FR-003 as amended after round 9** for the digest consumer. I found no change to the
lines of a raw HTML block outside "a block that begins inside a span the tracker holds and
CommonMark does not". That covers round 9's six probes, my ten, and 20,000 generated documents
(328 in-block disarms, all masked).

- I: the amendment is approved, lands first, and covers the change made.
- II: no rung conflict. The documents agree with each other and with the code; the one
  parenthetical noted in F1 does not bound the operative text.
- IV: no new dependency or architecture.
- VIII: two pins, each shown on `e10da18` and `c81a12d`, and each flips under its own door
  mutation.
- IX: this review.
- X: one phase, Territory held, `scope-check` PASS.

**Against the amended spec** (changes from round 9 only):

| Item | Status |
|---|---|
| FR-003 (as amended after round 9) | Met (F1: the cause wording is not exhaustive, but the operative clause covers the shapes found) |
| FR-004 | Met: full suite 891/0, run by me |
| FR-008 | Met: DIGEST-001 has 35 cases (103 assertions in the `-Case` run) |
| SC-002 (as amended) | Met for the amendment consumer (code parity) |
| SC-004 (as amended) | Met for the committed guards and pins. `c1` is unguarded (F4); `j-long` is detected by a pin (F3) |
| FR-010 | Loosely met (F6) |

## Test coverage observed

- There are now five long-end pins: fence, indented, container, modelled-rule and paragraph.
  Each is specific to its door (`j-long`, `r-indent`/`r-container`, `r-tagline`/(m) and `r-para`
  show it), and the four PI pins fall together under (l2).
- Not covered by a dedicated pin: an ordered-marker paragraph door (round-9 `d06`, my `e06`), a
  list item whose content is indented code (`e08`), a declaration whose `>` end the tracker
  strips as a block-quote marker (`e02`), and the attribute/code-span tag-line shapes (F1). All
  are inside the mechanism. The attribute/code-span shapes share the tag-line door with
  `fail-modelled-rule-…`. `e06`, `e08` and `e02` have no pin of their own, and that is acceptable
  under an exception stated by mechanism: round 9 asked for one pin per family, not one per door.

## Residual risk

The security gate holds: the amendment check's code is unchanged, and its reading is the
parent's.

In the digest generator, the round-4/5/7/8/9 class is still reachable. It is now recorded as a
mechanism, not a list of routes, so new doors of the same mechanism fall inside the approved
exception. The generated search found no harvest of a comment-hidden marker outside it. Corpus
exposure is nil. Every shape needs a long-end span the tracker holds and CommonMark does not, a
CommonMark block start inside it, the tracker's end, and an unclosed opener. Markers inside
inline `script`/`style`/`textarea` elements remain harvestable, as the library records.

What remains is minor: F1's list of causes, F2's nits, and F3 to F6 carried over.

Every experiment ran in `…/D--solutions-agentic-sdlc-kit/r10-review/`. `git hash-object
scripts/markdown-lib.ps1` is `3ff54f4…` before and after. The repository shows no change beyond
this review file and the pre-existing untracked `.claude/settings.local.json`.
