# AI Code Review — 016 Multi-line Code Spans (Phase 1, round 6)

**Reviewer**: fresh-context agent — claude-opus-5-5
**Date**: 2026-10-01
**Branches**: agentic-sdlc-kit `016-multiline-code-spans` (tip `517f9d2`)
**Scope reviewed**: the round-5 remediation, `git diff 115d092..517f9d2`. That is the amendment
`79b5763` (plan D11 "Amended after the phase-1 round-5 review", tasks T014n) and the fix `517f9d2`
(`scripts/markdown-lib.ps1`, four DIGEST-001 `pass-hidden-*` directions, `notes.md`, the T014n
tick). I also read the whole branch against its base (`git merge-base main HEAD` = `a1258c5`) for
regressions and scope.
**Feature contract**: phase 1 = T001-T014n. The amendment check keeps the parent's per-line
reading, unchanged (D11). The digest generator uses the whole-document rule
(`Convert-CodeSpanMarkers`). FR-003 as amended says the fix "can then never make visible anything
the per-line reading hides, except text after an opener that cannot be a comment" and "never
changes the lines of … a raw HTML block". No new dependency and no new script. Territory is the
three scripts plus `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: claude-opus-5-5 (the implementing session)
- **Inputs provided**: `git diff 115d092..517f9d2` in full. `git show` of `79b5763` and `517f9d2`
  (message, stat, the `tasks.md` hunk). `git diff --name-only a1258c5..517f9d2`. For
  `specs/016-multiline-code-spans/`: the five earlier reviews, `spec.md` (FR-003, FR-010 and their
  amendment blocks), `plan.md` D11 with both amendment blocks, `tasks.md` (T014m, T014n and their
  approval records) and `notes.md` (the round-4 and round-5 remediation sections). The four new
  recipes. The kit's law (`CLAUDE.md`, `.specify/memory/constitution.md`,
  `docs/sdlc/definition-of-done.md`, `docs/sdlc/review-process.md`), loaded as project
  instructions, and `scripts/enforcement-pack.ps1`'s `Invoke-ReviewProvenanceCheck`. I had read and
  run access to the working tree. Every experiment ran in this session's `scratchpad/r6-review/`:
  scratch copies of the `e10da18`, `b45cff1`, `c6d95a1` and `517f9d2` scripts, `git archive` kits
  of `517f9d2` and `c6d95a1` for harness runs, my own mutation runner (`mut.ps1`, 10 variants) and
  one extra library variant (`noexcl`). The round-5 reviewer's `harvest.ps1`, `corpus.ps1`,
  `render.js`, probe documents and corpus lists were reused read-only. The implementer's
  `scratchpad/r6/` mutation output was read but not trusted: I re-ran every row I cite. The
  library's hash was taken before the runs and checked after. No repository file other than this
  review was modified.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE. Round-5 F1 and F3 are closed, the overclaims are corrected, and I found no new shape of
the round-4/5 F1 class. The findings below are non-blocking.**

The fix is the one condition round 5 sketched, at `scripts/markdown-lib.ps1:185-187`. When a
long-end start is read outside any block on a tag line that is not itself a `pre`, `script`,
`style` or `textarea` start, the block to resume is `'blank'`. That only turns a `$null` state into
`'blank'`. So against `c6d95a1` it can keep more lines in HTML, never fewer. A 3,000-document fuzz
bears this out: the fix harvests a marker `c6d95a1` did not in 9 documents only, and in each of the
9 it equals the parent `e10da18` exactly. All seven round-5 shapes (n1-n7) hide their marker again,
and so do the 13 new tag-line probes of mine. Both renderers put those markers inside an earlier
comment. The four new guards fail on `c6d95a1` and pass on `517f9d2`, and mutation (n) turns all
four red.

The security gate is untouched. `enforcement-pack.ps1` and `build-digests.ps1` are byte-identical to
`c6d95a1`. In the library, every function the amendment check reaches is AST-identical to `c6d95a1`.
That includes `Get-VisibleFromText` and `Get-AddedRecordLines` in the pack. The implementer's
parity "by construction" claim therefore holds.

The non-blocking findings:

- F1: the exclusion half of the new condition has no guard.
- F2: a raw-text element closed and reopened on one line escapes the `(m)` rule. This predates
  round 6.
- F3: the conservative cost of the fix is real but stays at the parent's reading.
- F4: round-5 F2 (`c1`) is unguarded. It is now recorded in D11.
- F5 and F6 carry over: the D5 tail and the FR-010 wording.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Security gate: parity by code | `git diff --quiet c6d95a1 517f9d2 -- scripts/enforcement-pack.ps1 scripts/build-digests.ps1` exits 0. I compared AST extents (`astcmp.ps1`) of `517f9d2` against `c6d95a1`. These are identical: `Convert-SpanText`, `Disable-CommentMarkers`, `Get-FencedLineMap`, `Get-VisibleFromText`, `Get-AddedRecordLines`, `Get-BlobLines`, `Invoke-AmendmentAuthorityCheck` and `Get-DocMarkers`. Only `Convert-CodeSpanMarkers` differs. `grep` shows `Convert-CodeSpanMarkers` is called only from `build-digests.ps1:92`. Against `e10da18`, `Disable-CommentMarkers`, `Get-FencedLineMap`, `Get-AddedRecordLines`, `Get-BlobLines` and `Invoke-AmendmentAuthorityCheck` are identical. `Get-VisibleFromText` differs there by the `Convert-SpanText` extraction, which round 4 proved by corpus and fuzz and round 5 carried forward. So the "by construction" claim is sound without a file-by-file rerun |
| Full suite | `pwsh -File tests/enforcement/Run-Tests.ps1` on the working tree: **871 passed, 0 failed, 0 skipped**, `enforcement-tests: OK`, exit 0. That matches `notes.md` |
| Ritual and scope | `pwsh -File scripts/ritual-checks.ps1`: `RESULT OK`, exit 0. doc-lint, enforcement-pack, scope-check, digests (5 fresh, 82 markers) and roadmap-claims are OK; scope-repos and verify-kit are n/a. `pwsh -File scripts/scope-check.ps1`: `PASS phase 1 commit 517f9d2 (15 file(s))`, exit 0 |
| New guards fail on `c6d95a1` | I copied the four case directories into a `git archive c6d95a1` kit and ran `Run-Tests.ps1 -Case DIGEST-001` (25 cases). Result: **75 passed, 8 failed**, exit 1. The failures are exactly the four new cases, two assertions each, each `digests: FAIL - stale or hand-edited digest`. That matches `notes.md` |
| Mutations (my runner, `517f9d2` kit, `-Case DIGEST-001`) | none 83/0. **(n)** (`c6d95a1`'s resume restored) 75/8, exit 1, the four new guards. (n2) (the tag-line clause disabled) is the same. (i) 71/12: `div-after-comment-line`, `div-after-pre` and the four new guards. (m) 81/2: `script-after-tag`. (f) 49/34: 17 `pass-hidden-*`. (k) 75/8: `list-div`, `quote-div`, `list-tag-line-pre`, `quote-tag-line-script`. (h) 81/2: `pre-under-tag-line`. **`c1` 83/0** (F4). **`noexcl` 83/0** (F1). The library hash matched after every run. Each row matches the `notes.md` table, which lacks only `noexcl` |
| Round-5 probe documents | `r5/docs` and `r5/docs2`, harvested on `b45cff1`, `c6d95a1` and `517f9d2`: n1-n7 give `Visible rule.` only on the fix, as on `b45cff1`. a1, b1, b3 and c1 stay hidden, `ok1` keeps its rule, and q7 and q8 are as on `c6d95a1`. All as `notes.md` says |
| Corpus | The round-5 corpus list (567 `.md` files: the kit plus fitforge, flowboard and expense-tracker) and the 91 earlier review documents, through `corpus.ps1` (harvest plus a SHA-256 of the scan lines). `c6d95a1` and `517f9d2` give byte-identical output on both lists |
| Adversarial probes | 26 documents of mine (`r6-review/docs/`), each rendered with markdown-it 14 and commonmark.js and harvested on all four versions. They cover tag lines with attributes (`p01`), uppercase tags (`p02`), closing tags (`</div><pre>`, `</td><textarea>`: `p03`, `p04`), nested long-end blocks (`p05`, `p15`, `p16`), tag lines inside an open blank-ending block (`p06`, `p07`), container forms (`1.`, `> -`: `p08`, `p09`), two elements on one line (`p11`), a comment inside the tag line (`p12`), a self-closing tag (`p13`), a type-7 line (`p14`), a fenced tag line (`p17`), a type-1 line holding a tag (`p18`), an element closed after the blank (`v01`) and raw-text reopen shapes (`q01`-`q04`). Every document whose marker both renderers put inside an earlier comment is hidden on the fix |
| Fuzz | 3,000 generated documents (`gen.js`, seed 7) built from 44 line shapes (tag lines, raw-text open and close lines, containers, fences, PI/CDATA/declaration lines, GAP-028 spans), each with an unclosed `z <!-- hidden` line, then H and V. Against the parent, the fix harvests more in 335 documents and fewer in 18. All 18 have the markers inside an unclosed fence, where the renderers show none, and are the same on `c6d95a1`. There are **0** documents where the fix harvests a comment-hidden H that the parent hid. 11 documents flagged by the renderer heuristic harvest H on the parent too: each has a `-->` before the blank, so it is the per-line result. Against `c6d95a1`, the fix closes **267** documents where `c6d95a1` harvested a comment-hidden H the parent hid (the round-5 F1 class). It harvests nothing `c6d95a1` did not, except 9 documents where it returns to the parent's result |
| Amendments | `79b5763` is a `docs:` commit that lands before `517f9d2`. It names the approver in its subject and adds `**Amendment approved by**: anas.m, 2026-10-01` after the D11 block and after T014n (T014n added unticked). `517f9d2` ticks T014n and changes nothing else in `tasks.md`. `spec.md` and `contracts/` are unchanged |
| Scope guard | `git diff --name-only a1258c5..517f9d2` outside `specs/016-*/` and `tests/` lists only the three scripts. No package, manifest or workflow file is touched |
| Rollback safety | Self-contained. Reverting `517f9d2` restores `c6d95a1`'s library and removes four case directories. No data or schema is involved |

## Findings

### F1 — The exclusion half of the new condition has no guard — MINOR (non-blocking)

**Where**: `scripts/markdown-lib.ps1:187`,
`$body -notmatch '(?i)^<(pre|script|style|textarea)(\s|>|$)'`.

The fix's resume rule has two parts: a tag line resumes `'blank'`, and a line that is itself a
type-1 start does not. Removing that `-notmatch` clause (my variant `noexcl`) gives DIGEST-001
**83/0**. Nothing guards it. Its effect is real. On `r6-review/docs3/v05-type1-then-span.md`
(`<pre>x</pre>` / ``Quote `<!--`` / ``here` in prose.`` / ␤ / V), `517f9d2` harvests V, as
markdown-it shows it: `<pre>x</pre>`, then `<p>Quote <code>&lt;!-- here</code> in prose.</p>`, then
the V comment. `noexcl` harvests nothing, which is the parent's GAP-028 reading. `v06`
(`<script src="a.js"></script>` on its own line) behaves the same. The direction is conservative:
the mutation only loses fixes and never harvests a hidden marker. That is why it can go
unguarded, as round-5 F2 did. But plan D11 calls this rule out explicitly ("Only a line that is
itself a `pre`, `script`, `style` or `textarea` start returns to inline text"), and the `notes.md`
mutation table does not list it.
*Action: optional. Add a `pass-wrapped-span`-style DIGEST-001 direction (`v05`) that fails under
`noexcl`, or record the clause as unguarded next to `c1`.*

### F2 — A raw-text element closed and reopened on one line escapes the `(m)` rule — MINOR (non-blocking; predates round 6)

**Where**: `scripts/markdown-lib.ps1:189`, `if ($body -match $longEnd) { … }`. The check asks
whether the line holds any end tag, not whether the last element it opens is closed.

On `<div><script>a</script><script>` (`q01`), the tracker reads the line as closed and the state
ends at the blank line. The browser stays inside the second `<script>` until a later `</script>`.
So an opener after the blank is disarmed, and a marker that sits inside that script is harvested.
markdown-it and commonmark.js both emit H verbatim inside the open script. `q03` (the reopen on a
later line) and `q02` (a top-level `<script>a</script><script>`) behave the same. `e10da18` hides H
in all three. `b45cff1`, `c6d95a1` and `517f9d2` harvest it, so this is not a regression of the
fix under review. FR-003's letter allows it: after the blank, the `<!--` sits in a paragraph, so
it cannot be a comment. What hides H is a raw-text element, which the library comment's last
sentence leaves unmodelled ("Constructs other than comments that hide text … are not modelled").
But the `(m)` rule claims to take the element's end, and here it takes the wrong one. `q04`
(`<div><title>`) is the same class with an element `(m)` does not list (`title`, and likewise
`xmp`, `iframe`, `noembed`, `noframes`). The fuzz counts 117 such raw-text documents, each the
same on `c6d95a1`. Exposure is nil in the corpus, and the shape is contrived: markdown text inside
an unclosed inline script.
*Action: none required for phase 1. Optionally name "an element closed and reopened on one line,
and raw-text elements other than the four" in the library's "Not modelled" paragraph.*

### F3 — The fix's conservative cost — CONFIRM (no action)

The fix keeps lines in HTML past the element's close, so it loses some markers that `c6d95a1`
correctly harvested. Each loss returns to the parent's result:
- `p14`: `<span><script></script>` is a paragraph line, not a block, in both renderers.
- `p17`: a tag line inside a real fence.
- `v03`: ```` ```html ```` / `<div><script></script>` / ```` ``` ```` followed directly by a
  GAP-028 span. V is lost there, as on the parent.

The fuzz has 27 such documents, and the parent hides the marker in all 27. FR-003 permits this
direction. Round 5 noted the same effect for q7 and q8.
*Action: none.*

### F4 — Reading ends after the container markers (`c1`) is still unguarded — CONFIRM (owner-accepted, now recorded)

Unchanged from round-5 F2: mutation `c1` gives 83/0. Plan D11's round-5 amendment now records it
("This change has no guard, by the owner's acceptance of round-5 F2"), so the record is complete.
*Action: none.*

### F5 — The D5 tail still loses a marker the parent kept — CONFIRM (owner-accepted, phase 2)

Unchanged from round-5 F4. `review3/ddocs/d1-tail-sameline.md` harvests nothing on `517f9d2`, as on
`c6d95a1`. The 91 review documents harvest identically on the two.
*Action: none in phase 1. DIGEST-020 direction in T016.*

### F6 — FR-010's wording — MINOR (carried)

Unchanged from round-5 F5. The `spec.md` amendment block (line 247) still reads "a document with
no opener that the rule could disarm takes no additional work". `spec.md` is not in this diff.
*Action: owner may reword; no code change.*

## Earlier findings — status

- **Round 5 F1** (a tag line holding a raw-text element dropped its enclosing block): **fixed**.
  n1-n7 hide H again, and four are committed as guards: n2, n3, n6 and n7. Each fails on `c6d95a1`
  (8 assertions, reproduced) and under mutation (n), reproduced. The fix is the sketch round 5
  gave, it is monotone against `c6d95a1`, and the fuzz finds no residue of the class.
- **Round 5 F2** (`c1` unguarded): **accepted and recorded** in D11 (F4 above).
- **Round 5 F3** (T014m and D11 did not name all four tracker changes): **fixed** by `79b5763`.
  D11's round-5 block names the return to the enclosing block, blank-ending starts on fenced lines,
  ends after the container markers, and the tag-line raw-text start with its resume to the
  blank-ending block, and records mutation (n). T014n names the fix, the guards, mutation (n) and
  the corrections.
- **Round 5 overclaims**: **fixed**. The library comment (`:118-120`) now reads "Each modelled rule
  is meant to keep lines on the per-line result, but that is checked only for the shapes the cases
  guard: round 5 found a rule of round 4 that disarmed more". `notes.md:375-377` reads "Each change
  was meant to disarm less, never more. The round-5 review found that the last one disarms more …".
  Both are accurate. The sentence "on a real fence's lines the only effect is that more lines keep
  the per-line result" is still true. F3 shows that "more lines" can run past the fence to the next
  blank line.
- **Round 5 F4** (D5 tail): **open**, owner-accepted (F5).
- **Round 5 F5** (FR-010): **open**, minor (F6).
- **Rounds 1-4**: status unchanged from round 5. The amendment check's code is unchanged in this
  diff.

## Amendments in this diff

- [x] Amendments listed. `79b5763` (a `docs:` commit before `517f9d2`) amends plan D11 after round
  5 and adds tasks T014n. Each carries `**Amendment approved by**: anas.m, 2026-10-01`, and the
  commit subject names the approver. `517f9d2` ticks T014n only. `spec.md` and `contracts/` are
  unchanged.

## Constitution re-check (post-implementation)

**PASS on VI (Security).** The amendment-authority gate's code and every function it reaches are
AST-identical to `c6d95a1`. AMEND-001 is green in the 871-test suite.

**PASS on FR-003** for the digest consumer, for every shape found (round-5 F1 closed). F2 is a
non-comment construct, which the FR-003 text leaves out of scope.

- I: the amendment is approved, lands first, and covers the change made.
- II: no rung conflict.
- IV: no new dependency or architecture.
- VIII: every new guard was shown failing on `c6d95a1` and under its mutation. One conservative
  clause is unguarded (F1).
- IX: this review.
- X: one phase, Territory held, `scope-check` PASS.

**Against the amended spec** (changes from round 5 only):

| Item | Status |
|---|---|
| FR-003 | **Met** (round-5 F1 closed; 0 comment-hidden harvests against the parent in 3,000 fuzz documents and 26 probes) |
| FR-004 | Met: full suite 871/0, run by me |
| FR-008 | Met: DIGEST-001 gains four directions (25 cases, 83 assertions) |
| SC-002 (as amended) | Met for the amendment consumer (code parity) |
| SC-004 (as amended) | Met for the committed guards. `c1` and the type-1 exclusion have no guard (F4, F1) |
| FR-010 | Loosely met (F6) |

## Test coverage observed

- Each new case is a hand-written one-rule digest that must stay fresh, so a harvested hidden
  marker makes `-Check` exit 1. Together they cover a same-line close (n3), a later-line close
  (n2), a list container (n6) and a block-quote container (n7). Mutations (n), (i), (k) and (k2)
  each reach some of them.
- The new condition's `-notmatch` exclusion is not covered (F1), and neither is `c1` (F4). Both
  are on the conservative side.

## Residual risk

The security gate holds: the amendment check's code is unchanged, and its reading is the parent's.
In the digest generator, the round-4/5 F1 class (a commented-out marker harvested) has no known
shape left. The fuzz found none against the parent, and the fix only adds HTML lines to
`c6d95a1`'s reading.

What remains is all minor:
- a raw-text element that hides a marker without a comment, the declared unmodelled case (F2);
- the conservative losses, each equal to the parent's result (F3);
- two unguarded conservative clauses (F1, F4);
- F5 and F6, carried over.

Every experiment ran in `scratchpad/r6-review/`. `git hash-object scripts/markdown-lib.ps1` is
`0c3289c…` before and after. The repository shows no change beyond this review file and the
pre-existing untracked `.claude/settings.local.json`.
