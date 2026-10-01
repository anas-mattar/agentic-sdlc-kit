# AI Code Review — 016 Multi-line Code Spans (Phase 1, round 8)

**Reviewer**: fresh-context agent — claude-opus-5-5
**Date**: 2026-10-01
**Branches**: agentic-sdlc-kit `016-multiline-code-spans` (tip `3ad7408`)
**Scope reviewed**: the round-7 remediation, `git diff 2477ad9..3ad7408`. That is the amendment
`f7b9bb3` (plan D11 "Amended after the phase-1 round-7 review", tasks T014p) and the fix `3ad7408`
(`scripts/markdown-lib.ps1`: `Test-HtmlBlockEnd` and its two call sites removed, the "Not modelled"
paragraph rewritten; three T014o reopen guards removed; four DIGEST-001 cases; `notes.md`; the T014p
tick). I also read the whole branch against its base (`git merge-base main HEAD` = `a1258c5`) for
regressions and scope.
**Feature contract**: phase 1 = T001-T014p. The amendment check keeps the parent's per-line
reading, unchanged (D11). The digest generator uses the whole-document rule
(`Convert-CodeSpanMarkers`). FR-003 as amended says the fix "can then never make visible anything
the per-line reading hides, except text after an opener that cannot be a comment" and "never
changes the lines of an HTML comment block or of a raw HTML block". The spec's Out of Scope says
indented code blocks and lazy continuation lines "keep their current handling". No new dependency
and no new script. Territory is the three scripts plus `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: claude-opus-5-5 (the implementing session)
- **Inputs provided**: `git diff 2477ad9..3ad7408` in full, `git diff 517f9d2..3ad7408 --
  scripts/`, `git show` of `f7b9bb3` and `3ad7408` (message, stat, the `tasks.md` hunks) and
  `git log` of the branch. For `specs/016-multiline-code-spans/`: the seven earlier reviews (rounds
  6 and 7 read in full), `spec.md` (FR-002, FR-003, Out of Scope), `plan.md` D11 with its round-5,
  round-6 and round-7 amendment blocks, `tasks.md` (T014m-T014p and their approval records) and
  `notes.md` ("Phase 1 round-7 remediation (T014p)"). The four new recipes. The kit's law
  (`CLAUDE.md`, `.specify/memory/constitution.md`, `docs/sdlc/definition-of-done.md`,
  `docs/sdlc/review-process.md`), loaded as project instructions. I had read and run access to the
  working tree. Every experiment ran in this session's `scratchpad/r8-review/`: `git archive` kits
  of `3ad7408`, `517f9d2` and `c565240`, `git show` copies of the three scripts at those commits
  (plus the round-7 copy of `e10da18`), my own mutation runner (`mut.ps1`, 19 variants), a
  comment-blind token and AST comparer with a call-graph walk (`astcmp.ps1`), 18 probe documents
  of mine (`docs/c01`-`c18`) and three of them as DIGEST-001 fixtures in the `517f9d2` kit. The
  round-5 reviewer's `harvest.ps1`, `corpus.ps1` and corpus lists, the round-6 reviewer's probe
  documents and 3,000-document fuzz set, and the round-7 reviewer's probe documents and
  `render7.js` (markdown-it 14, commonmark.js, then a simplified HTML5 tokenizer) were reused
  read-only. The implementer's mutation output was not used: I re-ran every row I cite.
  `git hash-object scripts/markdown-lib.ps1` was `655ac2b…` before and after. No repository file
  other than this review was modified.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES. Round-7 F1 is closed exactly as claimed: the library's code is token-identical
to `517f9d2`, and the three new guards fail on `c565240` and pass on the fix. But the round-7 F1
mechanism is reachable on `3ad7408` (and on `517f9d2`) through three other doors that no round
recorded (F1 below, blocking): a commented-out marker that the parent `e10da18` hides is
harvested.**

The security gate is untouched. `enforcement-pack.ps1` and `build-digests.ps1` are byte-identical
to `517f9d2`, and the library's non-comment token stream is identical to `517f9d2`'s (976 tokens).
All 37 function extents match. The call graph from `Invoke-AmendmentAuthorityCheck` and
`Get-VisibleFromText` reaches 14 functions, and `Convert-CodeSpanMarkers` is not among them. The
amendment check's reading is therefore unchanged.

Everything `notes.md` claims for T014p reproduces: the suite count, the four cases failing on
`c565240`, mutations (e)-(o) and `c1`, the library hash, the corpus and the probe documents.

The defect is the one round 7 described, entered from a different side. The tracker opens a
long-end block (`pre`/`script`/`style`/`textarea`, `<!--`, `<?`, `<!X`, `<![CDATA[`) where
CommonMark has none, or keeps one open after CommonMark has closed it. Inside that span it ignores
CommonMark block starts. When its own end arrives it drops to "outside any block", in the middle of
a raw HTML block CommonMark did start, and the rule disarms a real comment opener there. The three
doors are a real fenced code block, an indented code block, and a list item or block quote that
closes.

The findings:

- F1 (blocking): a long-end start in a fence, in indented code or in a closing container masks a
  later block start, and a real comment is disarmed.
- F2: wording nits in the "Not modelled" paragraph and the pin's description.
- F3: the long-end start on fenced lines has no guard.
- F4 to F6 carry over: `c1` unguarded, the D5 tail, the FR-010 wording.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Code equals `517f9d2` | `git diff 517f9d2..3ad7408 -- scripts/` is one hunk in the comment block above `Convert-CodeSpanMarkers`. `astcmp.ps1` (PowerShell tokenizer, comments and newlines dropped): `markdown-lib.ps1`, `enforcement-pack.ps1` and `build-digests.ps1` each give an identical token stream for `517f9d2` and `3ad7408`. Function extents: 37 on each side, none differing. Against `c565240`: only `Convert-CodeSpanMarkers` and `Test-HtmlBlockEnd` differ, and `Test-HtmlBlockEnd` is gone |
| Security gate: parity | `git diff --quiet 517f9d2 3ad7408 -- scripts/enforcement-pack.ps1 scripts/build-digests.ps1` exits 0. The call-graph walk from `Invoke-AmendmentAuthorityCheck` and `Get-VisibleFromText` reaches `Convert-SpanText`, `Disable-CommentMarkers`, `Get-AddedRecordLines`, `Get-BlobLines`, `Get-CheckPresenceSet`, `Get-CommitMetaBatch`, `Get-ConformingRecord`, `Get-FencedLineMap`, `Get-NameStatusBatch`, `Test-CheckAbsentForReal`, `Test-CheckboxOnlyChange` and `Test-StatusOnlyChange`: `reaches Convert-CodeSpanMarkers: False`. `grep` shows `Convert-CodeSpanMarkers` called only at `build-digests.ps1:92` |
| Full suite | `pwsh -File tests/enforcement/Run-Tests.ps1` on the working tree: **881 passed, 0 failed, 0 skipped**, `enforcement-tests: OK`, exit 0. That matches `notes.md` |
| Ritual and scope | `pwsh -File scripts/ritual-checks.ps1`: `RESULT OK`, exit 0. doc-lint, enforcement-pack, scope-check, digests (5 fresh, 82 markers) and roadmap-claims are OK; scope-repos and verify-kit are n/a. `pwsh -File scripts/scope-check.ps1`: `PASS phase 1 commit 3ad7408 (24 file(s))`, exit 0 |
| New cases on `c565240` | I copied the four new case directories and `pass-wrapped-after-closed-pre` into a `git archive c565240` kit and ran `Run-Tests.ps1 -Case DIGEST-001` (33 cases): **91 passed, 8 failed**, exit 1. The failures are exactly `pass-hidden-div-in-reopen`, `-div-in-later-reopen`, `-pi-in-reopen` (each `digests: FAIL - stale or hand-edited digest`) and `fail-reopen-not-modelled` (observed `digests: OK (1 digest(s) fresh, 1 marker(s))`, exit 0), two assertions each. The same five directories in the `517f9d2` kit: 93/0, exit 0, as code identity predicts |
| The pin is meaningful | `fail-reopen-not-modelled` flips on `c565240`, which models the reopen (above). My `p-reapply` mutation (a start-line-only reopen check put back into the `3ad7408` kit) fails it too, together with `div-in-reopen` and `pi-in-reopen`: 87/6, exit 1. So the pin and the guards bracket the withdrawn rule from both sides |
| Mutations (my runner, `3ad7408` kit, `-Case DIGEST-001`, 30 cases) | none 93/0. (e) 89/4: `after-backslash-spans`, `nbsp-line`. (f) 53/40: 20 cases, including the three new guards. (g) 91/2: `nbsp-line`. (h) 91/2: `pre-under-tag-line`. (i) 81/12: six cases. (j) (blank-ending starts skipped on fenced lines) 91/2: `div-in-misread-fence`. (k) 85/8: four cases. (l1)-(l4) 91/2 each, the matching guard; (l2) 89/4, also `pi-in-reopen`. (m) 91/2: `script-after-tag`. (n) 85/8: the four round-5 guards. **(o)** 91/2: `pass-wrapped-after-closed-pre`. **`c1` 93/0** (F4). My extra **`j-long`** (long-end starts skipped on fenced lines) **93/0** (F3). The library hash was `d58196a0…` after every run (`restored: True`), as `notes.md` records |
| Corpus | The 567-file corpus list and the 91 review documents through `corpus.ps1` (markers plus a SHA-256 of the scan lines): `517f9d2` and `3ad7408` give byte-identical output on both, and `c565240` equals them on the corpus. The marker column also equals the parent `e10da18`'s on all 567 files: F1's exposure in the corpus is nil |
| Probe documents of rounds 5-7 | 83 documents (`r5/docs`, `r5/docs2`, `r6-review/docs`, `r6-review/docs3`, `r7-review/docs`, `r7-review/docs-b`; `notes.md` counts 84 with `r7-review/ddocs`): `517f9d2` and `3ad7408` give byte-identical harvests. Against `c565240`: `b04`-`b10` hide the marker again; `q01`-`q03`, `a01`-`a03`, `a08`-`a10` and `a24` harvest it again (raw-text hidden, now named); `a05`, `a13` and `a23` harvest it again and `a30` regains its visible marker (round-7 F3's conservative cost is gone) |
| Fuzz | The round-6 3,000 documents harvested on `3ad7408`: byte-identical to the round-6 reviewer's `fz-517f9d2.txt`. The round-6 classification of that file therefore stands. The generator does not produce fences, indented code or containers around long-end starts, so it does not reach F1 |
| Amendments | `f7b9bb3` is a `docs:` commit that lands before `3ad7408`, touches only `plan.md` and `tasks.md`, names the approver in its subject and adds `**Amendment approved by**: anas.m, 2026-10-01` after the D11 block and after T014p (added unticked). `3ad7408` ticks T014p. `spec.md` and `contracts/` are unchanged in this round |
| Scope guard | `git diff --name-only a1258c5..3ad7408` outside `specs/016-*/` and `tests/` lists only the three scripts. No package, manifest or workflow file is touched |

## Findings

### F1 — A long-end start the tracker reads where CommonMark has none masks a later block start, so a real comment is disarmed — BLOCKING

**Where**: `scripts/markdown-lib.ps1:179-195` (the long-end start, read on every line, fenced or
not, after any whitespace), `:196-201` (inside a long-end block, block starts are ignored and the
end returns to `$resume`, `$null` for a block opened outside any block), and `:162` (container
markers stripped on every line, so a closing container is not seen).

**Reproduction** (`scratchpad/r8-review/docs/c01-fence-pi-then-div.md`):

````text
```
<?x
```
<div>
?>
x <!--

<!-- digest: Hidden rule. -->

<!-- digest: Visible rule. -->
````

CommonMark (markdown-it and commonmark.js agree) renders lines 1-3 as a code block, `&lt;?x`
escaped. Line 4 starts a type-6 `<div>` block that runs to the blank line, so lines 4-6 are raw HTML
and both renderers emit them verbatim. `x <!--` opens a **real comment** in the browser. It runs
past the blank line and ends at the Hidden marker's own `-->`, so the Hidden marker is inside it.
Both renderers' output, tokenized, puts H `hid:comment`.

Here is how each library reads it:

| Library | Harvest | Why |
|---|---|---|
| `e10da18` | `Visible rule.` | the per-line result: `x <!--` stays armed and hides H |
| `517f9d2`, `c565240`, `3ad7408` | `Hidden rule. \| Visible rule.` | line 2 (fenced) starts a PI block in the tracker, so line 4's `<div>` is ignored. Line 5's `?>` ends it and `$resume` is `$null`, so line 6 counts as inline. Its `<!--` has no `-->` before the blank, so it is disarmed (`x <!@@` in the scan lines) |

The same holds for 13 more documents of mine, in three families. In every one, both renderers hide H
in a comment, `e10da18` hides it, and `517f9d2`, `c565240` and `3ad7408` harvest it:

| Door | Probes | Shape |
|---|---|---|
| A real fence | `c01`, `c05`, `c06`, `c10`, `c11`, `c13`, `c14`, `c17`, `c18` | a fenced `<?x`, `<script>`, `<!-- a`, `<!DOCTYPE`, `<![CDATA[` (backtick and tilde fences, with and without an info string), then a CommonMark block start after the fence, then the tracker's end, then the opener. `c17` uses a `<?y` PI that runs past a blank line, so a "resume `'blank'`" patch would not cover it. `c18` is the realistic form: a fenced HTML example `<script>` / `init();`, then `<details>` … `</script> is required.` / `See the note <!-- todo` |
| Indented code | `c02`, `c07`, `c16` | `    <?x` or `    <script>` as an indented code block (`c16`: inside a list item), a blank line, then `<div>` |
| A closing container | `c03`, `c04`, `c08`, `c09` | `> <?x` or `- <?x` (or `<script>`), then an unquoted or unindented `<div>`. HTML blocks take no lazy continuation, so CommonMark closes the container and its block; `c09` closes the block quote with a blank line |

As committed guards in the scratch kit (the `pass-hidden-div-in-reopen` recipe with the document
swapped), `c01`, `c02` and `c03` give **6 failed assertions on the `517f9d2` kit** (code-identical to
`3ad7408`), each `digests: FAIL - stale or hand-edited digest`. My controls `c12` and `c15`
(the opener is in a paragraph, H visible in both renderers) harvest H on the fix, correctly.

This breaks FR-003 in the round-4/5/7 F1 class: line 6 is a line of a raw HTML block, which the fix
must never change, and its opener is a comment. It is not recorded as accepted:

- The library says the long-end start is read on fenced lines so "a misread fence masks none; on a
  real fence's lines the only effect is that more lines keep the per-line result" (`:111-115`,
  `:174-176`). `c01` refutes this: the effect reaches past the fence and *removes* a raw HTML block.
  Rounds 5 and 6 noted that "more lines" can run past the fence, but only in the conservative
  direction.
- "Containers are otherwise not modelled (a container that closes does not end a block here)"
  (`:117-118`) names the cause of the third door, but under "What the model counts" and with no
  consequence stated. Neither D11 nor the "Not modelled" paragraph says a real comment can be
  disarmed through it.
- The spec's Out of Scope keeps indented code blocks and lazy continuation on "their current
  handling"; `c02` and `c03` change it.

This is not a regression of this round: `517f9d2`, which round 6 approved, has the same code, and
the corpus and fuzz exposure is nil. But the scope of this round asked whether any shape of this
class is reachable on `3ad7408` beyond what was recorded, and fourteen are. Rounds 4, 5 and 7
treated the class as blocking, and I do the same.

*Action: before phase 1 closes, amend D11/T014 with the owner's approval and either (a) model the
three doors or (b) record them. For (a), one way that follows round 7's option (a): while a
long-end block is open, keep reading CommonMark block starts on the lines where CommonMark itself
would read them, and on the tracker's end return to what CommonMark is in, not to `$null`. A data
point: skipping long-end starts on fenced lines (my `j-long`) hides H in all nine fence probes and
keeps DIGEST-001 at 93/0, but it gives up what the misread-fence rule was for (F3), and leaves the
indented and container doors open. For (b): name the three doors as not modelled, with the
consequence that a real comment's opener may be disarmed, correct the "only effect" sentence, and
reconcile the spec's Out of Scope line; that is an FR-003 exception, so the spec would need its
own amendment. Either way, add `c01`, `c02` and `c03` (or their equivalents) as DIGEST-001 guards
or pins, shown failing or flipping on `3ad7408`.*

### F2 — Wording of the "Not modelled" paragraph and the pin — MINOR (non-blocking)

**Where**: `scripts/markdown-lib.ps1:124-130`; the `fail-reopen-not-modelled` description.

The paragraph is accurate and complete relative to round-7 F2. It names the same-line reopen (which
also covers round-7 `a18`, a reopen on a paragraph line), `<script/>`, an end tag inside an
attribute, an end tag of another element, and `noscript` and `plaintext` beside the five round 6
named. D11 and T014p describe what the code does. Two nits:

- "Raw-text elements are modelled only as far as … a pre, script, style or textarea end tag" still
  calls `pre` and `textarea` raw-text elements. In the browser `pre` is ordinary HTML and
  `textarea` is RCDATA (as is `title`). This is harmless, as round 7 noted.
- The pin says "If the reopen is ever modelled, this case turns into a pass." The *digest check*
  then passes; the *case* fails (it expects exit 1), which is what makes it a pin. A reader may
  take the sentence the other way.

*Action: optional.*

### F3 — The long-end start on fenced lines has no guard — MINOR (non-blocking)

**Where**: `scripts/markdown-lib.ps1:179-187`, as D11 describes it ("even on a line the fence map
calls fenced").

My mutation `j-long` (`$longEnd = $null` on fenced lines) gives DIGEST-001 **93/0**.
`pass-hidden-pre-in-misread-fence` stays green under it because the blank-ending tag branch, which
(j) guards, still sees the `<pre` line. So half of the "every start is read on fenced lines" rule is
unguarded, and it is the half F1's fence door runs through. Any F1 remediation that touches it
should come with a guard showing what the rule buys.
*Action: record the gap beside `c1`, or add a misread-fence guard whose long end matters.*

### F4 — Reading ends after the container markers (`c1`) is still unguarded — CONFIRM (owner-accepted, recorded)

Mutation `c1` (`$raw` for `$body` at the end check) gives 93/0. D11's round-5 amendment records it.
*Action: none.*

### F5 — The D5 tail still loses a marker the parent kept — CONFIRM (owner-accepted, phase 2)

Unchanged by this round: the code equals `517f9d2`'s.
*Action: none in phase 1. DIGEST-020 direction in T016.*

### F6 — FR-010's wording — MINOR (carried)

Unchanged. `spec.md` is not in this diff.
*Action: owner may reword; no code change.*

## Earlier findings — status

- **Round 7 F1** (a block starting inside a reopened element is lost): **fixed**, by withdrawing
  the rule. `b04`-`b10` hide their marker; the three new guards fail on `c565240`, pass on the fix,
  and `p-reapply` turns two of them red again. The mechanism survives through other doors (F1).
- **Round 7 F2** (reopen forms the regex missed; naming gaps): **closed by naming**. The reopen
  itself is now not modelled, the forms are named in the library and in D11, and the pin holds the
  accepted limitation (F2 nits only).
- **Round 7 F3** (the reopen check's conservative cost): **moot**. `a05`, `a13`, `a23` and `a30`
  read as on `517f9d2`.
- **Round 7 F4** (`c1`): **accepted and recorded** (F4).
- **Round 7 F5** (D5 tail): **open**, owner-accepted (F5).
- **Round 7 F6** (FR-010): **open**, minor (F6).
- **Rounds 1-6**: unchanged. The amendment check's code is unchanged in this diff.

## Amendments in this diff

- [x] Amendments listed. `f7b9bb3` (a `docs:` commit before `3ad7408`) amends plan D11 after round
  7 and adds tasks T014p. Each carries `**Amendment approved by**: anas.m, 2026-10-01`, and the
  commit subject names the approver. `3ad7408` ticks T014p only. `spec.md` and `contracts/` are
  unchanged.

## Constitution re-check (post-implementation)

**PASS on VI (Security).** The amendment-authority gate's code and every function it reaches are
token-identical to `517f9d2`. AMEND-001 is green in the 881-test suite.

**FAIL on FR-003** for the digest consumer: F1 harvests comment-hidden markers by changing the lines
of a raw HTML block.

- I: the amendment is approved, lands first, and covers the change made.
- II: no rung conflict. The library's "only effect" sentence and the spec's Out of Scope line do
  not match the code's behaviour (F1).
- IV: no new dependency or architecture.
- VIII: every new guard was shown failing on `c565240`, and the pin flips there. F1's shapes have
  no guard.
- IX: this review.
- X: one phase, Territory held, `scope-check` PASS.

**Against the amended spec** (changes from round 7 only):

| Item | Status |
|---|---|
| FR-003 | **Not met** (F1: `c01`-`c11`, `c13`, `c14`, `c16`-`c18`) |
| FR-004 | Met: full suite 881/0, run by me |
| FR-008 | Met: DIGEST-001 has 30 cases (93 assertions in the `-Case` run) |
| SC-002 (as amended) | Met for the amendment consumer (code parity) |
| SC-004 (as amended) | Met for the committed guards. `c1` and `j-long` are unguarded (F3, F4), and F1 has no guard |
| FR-010 | Loosely met (F6) |

## Test coverage observed

- The three new guards pin round-7 F1's shapes; the pin holds the withdrawn reopen;
  `pass-wrapped-after-closed-pre` and (o) still hold the round-6 exclusion.
- Not covered: a long-end start in a real fence, in indented code or in a container that closes,
  followed by a CommonMark block start (F1); the long-end start on fenced lines (F3).

## Residual risk

The security gate holds: the amendment check's code is unchanged, and its reading is the parent's.

In the digest generator, the round-4/5/7 F1 class is reachable through three doors the model does
not see: a real fence, an indented code block and a container that closes (F1). Exposure in the
corpus and the fuzz set is nil, and every shape needs a long-end start in code or a container
followed by a block start and the tracker's end before the opener. But `c18` is a plausible
document (a fenced HTML example with an unclosed `<script>`), and the shapes are plain violations of
FR-003's letter.

What remains besides F1 is minor:
- markers hidden by a raw-text element rather than a comment, now named as not modelled;
- the wording nits (F2) and the unguarded half of the fenced-start rule (F3);
- F4 to F6, carried over.

Every experiment ran in `scratchpad/r8-review/`. `git hash-object scripts/markdown-lib.ps1` is
`655ac2b…` before and after. The repository shows no change beyond this review file and the
pre-existing untracked `.claude/settings.local.json`.
