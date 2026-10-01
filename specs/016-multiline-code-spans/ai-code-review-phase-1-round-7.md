# AI Code Review — 016 Multi-line Code Spans (Phase 1, round 7)

**Reviewer**: fresh-context agent — claude-opus-5-5
**Date**: 2026-10-01
**Branches**: agentic-sdlc-kit `016-multiline-code-spans` (tip `c565240`)
**Scope reviewed**: the round-6 follow-up, `git diff edc9bb7..c565240`. That is the amendment
`bdcd773` (plan D11 "Amended after the phase-1 round-6 review", tasks T014o) and the fix `c565240`
(`scripts/markdown-lib.ps1`: the new `Test-HtmlBlockEnd`, its two call sites and the "Not modelled"
paragraph; four DIGEST-001 cases; `notes.md`; the T014o tick). I also read the whole branch against
its base (`git merge-base main HEAD` = `a1258c5`) for regressions and scope.
**Feature contract**: phase 1 = T001-T014o. The amendment check keeps the parent's per-line
reading, unchanged (D11). The digest generator uses the whole-document rule
(`Convert-CodeSpanMarkers`). FR-003 as amended says the fix "can then never make visible anything
the per-line reading hides, except text after an opener that cannot be a comment" and "never
changes the lines of an HTML comment block or of a raw HTML block". No new dependency and no new
script. Territory is the three scripts plus `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: claude-opus-5-5 (the implementing session)
- **Inputs provided**: `git diff edc9bb7..c565240` in full, and `git log` of the branch. For
  `specs/016-multiline-code-spans/`: the six earlier reviews (round 6 read in full), `spec.md`
  (FR-003, FR-010 and their amendment blocks), `plan.md` D11 with its round-5 and round-6
  amendment blocks, `tasks.md` (T014m-T014o and their approval records) and `notes.md` ("Phase 1
  round-6 follow-up (T014o)"). The four new recipes. The kit's law (`CLAUDE.md`,
  `.specify/memory/constitution.md`, `docs/sdlc/definition-of-done.md`,
  `docs/sdlc/review-process.md`), loaded as project instructions. I had read and run access to the
  working tree. Every experiment ran in this session's `scratchpad/r7-review/`: `git archive` kits
  of `c565240` and `517f9d2`, `git show` copies of the `e10da18`, `c6d95a1`, `517f9d2` and
  `c565240` scripts, my own mutation runner (`mut.ps1`, 13 variants), an AST and call-graph
  comparer (`astcmp.ps1`), 41 probe documents of mine (`docs/`, `docs-b/`) and a renderer check
  (`render7.js`: markdown-it 14 and commonmark.js, then a simplified HTML5 tokenizer that reports
  whether each marker's `<!--` starts a comment in the data state or sits inside a comment, a
  raw-text, RCDATA or plaintext element). The round-5 reviewer's `harvest.ps1`, `corpus.ps1` and
  corpus lists, and the round-6 reviewer's probe documents and 3,000-document fuzz set, were
  reused read-only. The implementer's mutation output was not used: I re-ran every row I cite.
  `git hash-object scripts/markdown-lib.ps1` was `11eed88…` before and after. No repository file
  other than this review was modified.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES. Round-6 F1 and F2 are closed as specified, but the reopen model introduces a
new shape of the round-4/5 F1 class (F1 below, blocking): a commented-out marker that `517f9d2`,
`c6d95a1` and the parent `e10da18` all hid is harvested.**

The security gate is untouched. `enforcement-pack.ps1` and `build-digests.ps1` are byte-identical to
`517f9d2`. Of the 38 functions in the three scripts, only `Convert-CodeSpanMarkers` and the new
`Test-HtmlBlockEnd` differ from `517f9d2`. The call graph from `Invoke-AmendmentAuthorityCheck` and
`Get-VisibleFromText` reaches 14 functions, and neither `Test-HtmlBlockEnd` nor
`Convert-CodeSpanMarkers` is among them. The amendment check's reading is therefore unchanged.

Everything `notes.md` claims for T014o reproduces: the suite count, the three guards failing on
`517f9d2`, mutations (o), (p), (p1), (p2) and the earlier rows, the corpus and the probe documents.
The defect is in what the guards do not reach. When a raw-text element is reopened on a line where
CommonMark ends its type-1 block, CommonMark goes back to reading blocks on the next line. The
tracker does not: it stays inside the element and ignores any block start. So a `<div>` or `<?`
block that starts inside the reopened element is lost. When the element closes, the tracker drops
to "outside any block" in the middle of a raw HTML block, and the rule disarms a real comment
opener there.

The findings:

- F1 (blocking): a block that starts inside a reopened element is lost, and a real comment is
  disarmed.
- F2: residual reopen forms the opener regex misses, and naming gaps in "Not modelled".
- F3: the conservative cost of the reopen check.
- F4 to F6 carry over: `c1` unguarded, the D5 tail, the FR-010 wording.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Security gate: parity by code | `git diff --quiet 517f9d2 c565240 -- scripts/enforcement-pack.ps1 scripts/build-digests.ps1` exits 0. `astcmp.ps1` (AST extents of all 38 functions, `517f9d2` against `c565240`) reports only `Convert-CodeSpanMarkers` and `Test-HtmlBlockEnd` differing. Its call-graph walk from `Invoke-AmendmentAuthorityCheck` and `Get-VisibleFromText` reaches `Convert-SpanText`, `Disable-CommentMarkers`, `Get-AddedRecordLines`, `Get-BlobLines`, `Get-CheckPresenceSet`, `Get-CommitMetaBatch`, `Get-ConformingRecord`, `Get-FencedLineMap`, `Get-NameStatusBatch`, `Test-CheckAbsentForReal`, `Test-CheckboxOnlyChange` and `Test-StatusOnlyChange`. That gives `reaches Test-HtmlBlockEnd: False; reaches Convert-CodeSpanMarkers: False`. `grep` shows `Convert-CodeSpanMarkers` called only at `build-digests.ps1:92` and `Test-HtmlBlockEnd` only at `markdown-lib.ps1:204,210` |
| Full suite | `pwsh -File tests/enforcement/Run-Tests.ps1` on the working tree: **879 passed, 0 failed, 0 skipped**, `enforcement-tests: OK`, exit 0. That matches `notes.md` |
| Ritual and scope | `pwsh -File scripts/ritual-checks.ps1`: `RESULT OK`, exit 0. doc-lint, enforcement-pack, scope-check, digests (5 fresh, 82 markers) and roadmap-claims are OK; scope-repos and verify-kit are n/a. `pwsh -File scripts/scope-check.ps1`: `PASS phase 1 commit c565240 (15 file(s))`, exit 0 |
| New guards on `517f9d2` | I copied the four case directories into a `git archive 517f9d2` kit and ran `Run-Tests.ps1 -Case DIGEST-001` (29 cases): **85 passed, 6 failed**, exit 1. The failures are exactly `pass-hidden-reopen-same-line`, `-reopen-type1` and `-reopen-later-line`, two assertions each, each `digests: FAIL - stale or hand-edited digest`. `pass-wrapped-after-closed-pre` passes there, by design |
| Mutations (my runner, `c565240` kit, `-Case DIGEST-001`) | none 91/0. **(o)** (exclusion removed) 89/2, exit 1: `pass-wrapped-after-closed-pre`. **(p)** (`Test-HtmlBlockEnd` reduced to `$Body -match $End`) 85/6: the three reopen guards. **(p1)** (start line only) 87/4: `reopen-same-line`, `reopen-type1`. **(p2)** (later line only) 89/2: `reopen-later-line`. My extra `q-lastopen` (the last-open comparison forced true) 85/6: the three reopen guards. (n) 83/8: the four round-5 guards. (i) 79/12. (m) 85/6: `script-after-tag`, `reopen-same-line`, `reopen-later-line`. (f) 51/40: 20 cases. (k) 83/8. (h) 89/2: `pre-under-tag-line`. **`c1` 91/0** (F4). Each row matches `notes.md`. The library hash matched after every run (`restored: True`) |
| Round-6 F1 closed | (o) turns `pass-wrapped-after-closed-pre` red (above). The case is round-6 `v05`, and the recipe carries a visible marker the digest must hold |
| Round-6 F2 closed | `q01`-`q03` harvest `Visible rule.` only on `c565240`; `517f9d2` and `c6d95a1` harvest the hidden marker too. Both renderers put it inside the open `<script>`. My probes `a01` (`<div><pre>a</pre><script>`), `a02` (`</script><style>` on a later line), `a03` (uppercase with attributes), `a08` (an opener with no `>` at the end of the line), `a09` (list), `a10` (block quote, later line) and `a24` (a reopen on a tag line inside an open `<div>` block) all hide their marker on the fix, as the renderers do |
| Corpus | The 567-file corpus list and the 91 review documents through `corpus.ps1` (markers plus a SHA-256 of the scan lines): `517f9d2` and `c565240` give byte-identical output on both lists |
| Probe documents of rounds 5 and 6 | 42 documents (`r5/docs`, `r5/docs2`, `r6-review/docs`, `r6-review/docs3`) on `517f9d2` and `c565240`: only `q01`-`q03` change, each now hiding the marker. `q04` (`title`) still harvests. All as `notes.md` says |
| Fuzz | The round-6 3,000 documents, harvested on `c565240` and classified with `render7.js`. Against `517f9d2`, 9 differ: 6 hide a marker that `517f9d2` harvested from inside a raw-text element, 1 loses a visible marker, and 2 (`f00548`, `f01774`) harvest a marker hidden by an unclosed `<style>`. That last pair is the F2 class, not a comment (see F2). Markers hidden by a comment and harvested by the fix: **1**, and the parent harvests it too. The generator never produces the F1 shape |
| Amendments | `bdcd773` is a `docs:` commit that lands before `c565240`. It names the approver in its subject and adds `**Amendment approved by**: anas.m, 2026-10-01` after the D11 block and after T014o (T014o added unticked). `c565240` ticks T014o. `spec.md` and `contracts/` are unchanged |
| Scope guard | `git diff --name-only a1258c5..c565240` outside `specs/016-*/` and `tests/` lists only the three scripts. No package, manifest or workflow file is touched |

## Findings

### F1 — A block that starts inside a reopened raw-text element is lost, so a real comment is disarmed — BLOCKING

**Where**: `scripts/markdown-lib.ps1:204` and `:210`, the two `Test-HtmlBlockEnd` calls. The
block-start branches (`:194`, `:212`) are taken only when `$htmlEnd` is `$null` or `'blank'`.

**Reproduction** (`scratchpad/r7-review/docs-b/b04-type1-reopen-then-div.md`):

```text
<script>a</script><script>
<div>
</script>
x <!--

<!-- digest: Hidden rule. -->

<!-- digest: Visible rule. -->
```

CommonMark (markdown-it and commonmark.js agree) ends the type-1 block on line 1, because the line
holds `</script>`. Line 2 then starts a type-6 `<div>` block that runs to the blank line. So lines
2-4 are raw HTML, and both renderers emit them verbatim. In the browser, line 1's second `<script>`
is still open, `<div>` is script text, and `</script>` on line 3 closes it. `x <!--` then opens a
**real comment**, which runs past the blank line and swallows the Hidden marker. Both renderers'
output, tokenized, puts H `hid:comment`.

Here is how each library reads it:

| Library | Harvest | Why |
|---|---|---|
| `e10da18` | `Visible rule.` | the per-line result |
| `c6d95a1`, `517f9d2` | `Visible rule.` | line 1 reads as closed, and `<div>` on line 2 starts a blank-ending block, so line 4 is in HTML |
| `c565240` | `Hidden rule. \| Visible rule.` | line 1 reads as open, so line 2's `<div>` is ignored. Line 3 closes the element and `$resume` is `$null` (a type-1 start), so line 4 counts as inline. Its `<!--` has no `-->` before the blank, so it is disarmed |

The same holds for `b05` (a `<?x` processing instruction instead of `<div>`), `b06` (in a block
quote), `b07` (`<style>`), `b08` (`<pre>` / `</pre><script>`: the later-line reopen, path p2) and
`b09`. In `b09`, a `<?x` block runs past a blank line to `?>`, so it would also defeat a "resume
`'blank'`" patch. In every one, both renderers hide H in a comment, `e10da18`, `c6d95a1` and
`517f9d2` hide it, and `c565240` harvests it. As committed guards in the scratch kit (the
`pass-hidden-reopen-type1` recipe with the document swapped), `b04` and `b09` give 4 failed
assertions on `c565240`, each `digests: FAIL - stale or hand-edited digest`, and pass on `517f9d2`.

The tag-line reopen is safe: `b03` and `b10` resume `'blank'` and keep line 4 in HTML. So is a
`<!--` block start in place of `<div>` (`b01`, `b02`), because that opener is itself left armed.

This breaks FR-003 twice. Line 4 is a line of a raw HTML block, which the fix must never change.
Its opener can be a comment, and is one. It is the round-4/5 F1 class, a commented-out marker
harvested, which both earlier rounds treated as blocking. Exposure in the corpus is nil (the
corpus is identical), and the shape is contrived. But the class is the one D11's rules exist to
exclude, and T014o's "on the start line and on a later line alike" creates it on both paths.

*Action: before phase 1 closes, either (a) model both readers on the lines of a reopened element,
or (b) narrow the reopen model and record the consequence. For (a): from the line where CommonMark
closes its type-1 block, keep reading CommonMark block starts (a tag line gives `'blank'`, a long-end
start gives its own end). Resume that block, not `$null`, when the element closes, so a line is
inline only when both readers say so. For (b): name the reopen as not modelled, and accept round-6
F2's harvest. Either way, add `b04` (start line), `b08` (later line) and `b09` (a long-end block past
a blank line) as DIGEST-001 `pass-hidden-*` guards shown failing on `c565240`. Mutation (p) should
then also turn them green, which shows the guards pin the interaction. This needs a D11/T014
amendment approved by the owner.*

### F2 — Reopen forms the opener regex misses, and the "Not modelled" list — MINOR (non-blocking)

**Where**: `Test-HtmlBlockEnd`, `:99`, `'(?i)<(pre|script|style|textarea)(\s|>|$)'`, and the "Not
modelled" paragraph at `:134-139`.

These shapes have the marker hidden by an open raw-text element, not by a comment. Both renderers
show this, and `c565240` harvests it. Each is the same on `517f9d2` (not a regression), and FR-003's
letter allows it, since the opener after the blank line cannot be a comment:

| Probe | Shape | Classification |
|---|---|---|
| `a07`, `a27` | `<script/>` as the reopen. The browser ignores the `/` and opens a script; the regex needs `\s`, `>` or the line end | harvests hidden |
| `a06`, `a26` | the reopening tag carries `</script>` in a quoted attribute: `<script data-x="</script>">`. The last "close" falls after the last open | harvests hidden |
| `a11`, `a12`, fuzz `f00548`, `f01774` | an end tag of another of the four (`<script>` … `</pre>`). This follows CommonMark's end condition, but the browser stays inside the element | harvests hidden |
| `a18` | `<script>a</script><script>` on a paragraph line inside a `<div>` block, which is not a tag line | harvests hidden |
| `a17`, `a16` | `noscript` (raw text with scripting enabled) and `plaintext` (never ends). `plaintext` is harvested by `e10da18` too, so it is the per-line result | harvests hidden |

The new paragraph names `title`, `xmp`, `iframe`, `noembed` and `noframes`. It does not name
`noscript`, `plaintext`, `<script/>`, a mismatched end tag, an end tag inside an attribute, or a
reopen on a line that is not a tag line. Also, `pre` is not a raw-text element in the browser: its
content is parsed as HTML. The helper's comment and D11's "a raw-text element is closed only when
the last one the line opens is" group it with the other three. That is harmless, because treating
`pre` as raw only keeps lines in HTML (see `a23` in F3).
*Action: optional. Widen the opener regex to `(\s|/|>|$)` if F1's remediation touches the helper,
and complete the "Not modelled" sentence.*

### F3 — The reopen check's conservative cost — CONFIRM (no action)

An opener-like string after the line's last end tag keeps the element open, though the browser has
closed it. Each case loses a marker that `517f9d2` harvested correctly, and in each the result
equals the parent's:
- `a05`, `a30`: `<span title="<script>">` after the close.
- `a13`: `<!-- <script> -->` after the close.
- `a23`: a `<pre>` reopen, where the marker is visible in the browser.

`a04` (`x = "<script>"` inside a closed script) and `a14` (`<script>` inside a textarea) are read
correctly as closed. `a15` (`</script >`) loses its marker on every version, as CommonMark's end
condition does. FR-003 permits this direction.
*Action: none.*

### F4 — Reading ends after the container markers (`c1`) is still unguarded — CONFIRM (owner-accepted, recorded)

Mutation `c1`, now applied at the `Test-HtmlBlockEnd` call (`$raw` for `$body`), gives 91/0. D11's
round-5 amendment records it as unguarded.
*Action: none.*

### F5 — The D5 tail still loses a marker the parent kept — CONFIRM (owner-accepted, phase 2)

`review3/ddocs/d1-tail-sameline.md` harvests `Rule two.` on `e10da18` and nothing on `517f9d2` or
`c565240`.
*Action: none in phase 1. DIGEST-020 direction in T016.*

### F6 — FR-010's wording — MINOR (carried)

Unchanged. The `spec.md` amendment block still reads "a document with no opener that the rule could
disarm takes no additional work". `spec.md` is not in this diff.
*Action: owner may reword; no code change.*

## Earlier findings — status

- **Round 6 F1** (the exclusion unguarded): **fixed**. `pass-wrapped-after-closed-pre` fails
  under (o), reproduced.
- **Round 6 F2** (a raw-text element closed and reopened on one line): **fixed for the guarded
  shapes**. `q01`-`q03` and seven probes of mine hide their marker, and (p), (p1), (p2) and
  `q-lastopen` each turn the matching guards red. The remediation opens F1, and the regex leaves
  the F2 residue above. The "Not modelled" paragraph names five of the other raw-text elements,
  but not all of them (F2).
- **Round 6 F3** (conservative cost): **confirmed**. The cost now includes F3's opener-like strings.
- **Round 6 F4** (`c1`): **accepted and recorded** (F4).
- **Round 6 F5** (D5 tail): **open**, owner-accepted (F5).
- **Round 6 F6** (FR-010): **open**, minor (F6).
- **Rounds 1-5**: unchanged. The amendment check's code is unchanged in this diff.

## Amendments in this diff

- [x] Amendments listed. `bdcd773` (a `docs:` commit before `c565240`) amends plan D11 after round
  6 and adds tasks T014o. Each carries `**Amendment approved by**: anas.m, 2026-10-01`, and the
  commit subject names the approver. `c565240` ticks T014o only. `spec.md` and `contracts/` are
  unchanged.

## Constitution re-check (post-implementation)

**PASS on VI (Security).** The amendment-authority gate's code and every function it reaches are
AST-identical to `517f9d2`. AMEND-001 is green in the 879-test suite.

**FAIL on FR-003** for the digest consumer: F1 harvests a comment-hidden marker, by changing the
lines of a raw HTML block.

- I: the amendment is approved, lands first, and covers the change made.
- II: no rung conflict.
- IV: no new dependency or architecture.
- VIII: every new guard was shown failing on `517f9d2` and under its mutation. F1's shape has no
  guard.
- IX: this review.
- X: one phase, Territory held, `scope-check` PASS.

**Against the amended spec** (changes from round 6 only):

| Item | Status |
|---|---|
| FR-003 | **Not met** (F1: `b04`-`b09`) |
| FR-004 | Met: full suite 879/0, run by me |
| FR-008 | Met: DIGEST-001 gains four cases (29 cases, 91 assertions in the `-Case` run) |
| SC-002 (as amended) | Met for the amendment consumer (code parity) |
| SC-004 (as amended) | Met for the committed guards. `c1` is still unguarded (F4), and F1 has no guard |
| FR-010 | Loosely met (F6) |

## Test coverage observed

- The direction `pass-wrapped-after-closed-pre` pins the exclusion. The three reopen guards cover a
  tag-line reopen, a type-1 reopen and a later-line reopen, each with the marker inside the open
  script.
- Not covered: a CommonMark block start between the reopen and the element's close (F1), and the
  regex's residue (F2).

## Residual risk

The security gate holds: the amendment check's code is unchanged, and its reading is the parent's.

In the digest generator, the reopen model brings back the round-4/5 F1 class in one new shape: a
block that starts inside a reopened `pre`, `script`, `style` or `textarea` element (F1). Exposure in
the corpus and in the 3,000-document fuzz is nil, but the shape is a plain violation of FR-003's
letter.

What remains besides F1 is minor:
- markers hidden by a raw-text element rather than a comment (F2), the same on `517f9d2`;
- the conservative losses, each equal to the parent's result (F3);
- F4 to F6, carried over.

Every experiment ran in `scratchpad/r7-review/`. `git hash-object scripts/markdown-lib.ps1` is
`11eed88…` before and after. The repository shows no change beyond this review file and the
pre-existing untracked `.claude/settings.local.json`.
