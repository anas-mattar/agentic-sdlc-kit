# AI Code Review — 016 Multi-line Code Spans (Phase 1, round 9)

**Reviewer**: fresh-context agent — claude-opus-5-5
**Date**: 2026-10-02
**Branches**: agentic-sdlc-kit `016-multiline-code-spans` (tip `c81a12d`)
**Scope reviewed**: the round-8 remediation, `git diff 793efbd..c81a12d`. That is the amendment
`43e607c` (spec FR-003 gains a named exception, plan D11 "Amended after the phase-1 round-8
review", tasks T014q) and the fix `c81a12d` (`scripts/markdown-lib.ps1`, comments only: the "Not
modelled" paragraph names three routes, the "only effect" sentence at the long-end start is
replaced, the F2 wording; three DIGEST-001 pins `fail-{fence,indented,container}-long-end-not-modelled`;
the `fail-reopen-not-modelled` description; `notes.md` "Phase 1 round-8 remediation (T014q)"; the
T014q tick). I also read the whole branch against its base (`git merge-base main HEAD` =
`a1258c5`) for regressions and scope.
**Feature contract**: phase 1 = T001-T014q. The amendment check keeps the parent's per-line
reading, unchanged (D11). The digest generator uses the whole-document rule
(`Convert-CodeSpanMarkers`). FR-003 as amended after round 8: the fix "never changes the lines of
an HTML comment block or of a raw HTML block" **except where such a block begins inside a span
the tracker opened through one of these three routes**: a long-end start "on a real fenced line,
in an indented code block, or in a list item or block quote that CommonMark then closes". The Out
of Scope line on indented code and lazy continuation holds except through that exception. No new
dependency and no new script. Territory is the three scripts plus `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: claude-opus-5-5 (the implementing session)
- **Inputs provided**: `git diff 793efbd..c81a12d` in full, `git diff e10da18..c81a12d --
  scripts/`, `git show` of `43e607c` and `c81a12d` (message, stat, the `tasks.md` hunks) and
  `git log` of the branch. For `specs/016-multiline-code-spans/`: `spec.md` (FR-001 to FR-012,
  every amendment block, Out of Scope), `plan.md` D11 with its round-3, round-5, round-6, round-7
  and round-8 amendment blocks, `tasks.md` (Territory, T014m-T014q and their approval records),
  `notes.md` (T014p and T014q sections), and `ai-code-review-phase-1-round-8.md` in full (rounds 5
  to 7 searched as needed). The three new recipes and the amended reopen pin. The kit's law
  (`CLAUDE.md`, `.specify/memory/constitution.md` I and II, `docs/sdlc/definition-of-done.md`,
  `docs/sdlc/review-process.md`), loaded as project instructions. I had read and run access to the
  working tree. Every experiment ran in my own `…/D--solutions-agentic-sdlc-kit/r9-review/`:
  `git archive` kits of `c81a12d`, `3ad7408` and `e10da18`, `git show` copies of the three scripts
  at those commits, a `c81a12d` kit with `e10da18`'s three scripts swapped in, two mutation kits,
  my own route mutations (`mut9.ps1`), a scan printer (`scan.ps1`), a fixture builder (`mkg.ps1`),
  eight probe documents of mine (`docs/d01`-`d08`) and six of them as DIGEST-001 fixtures. The
  round-8 reviewer's `mut.ps1`, `astcmp.ps1`, `corpus.ps1`, `harvest.ps1` and `render7.js`
  (markdown-it 14, commonmark.js, then a simplified HTML5 tokenizer), the round-5 corpus lists
  and the probe documents of rounds 5-8 were reused read-only (`mut.ps1`'s MD5 checked unchanged
  after the run); the r8 `lib-517f9d2` and r7 `lib-c6d95a1` copies were read only. The
  implementer's output was not used: I re-ran every number I cite. `git hash-object
  scripts/markdown-lib.ps1` was `fd300f7…` before and after. No repository file other than this
  review was modified.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES. Round-8 F1 is closed exactly as option (b) asked for the three routes it
named: spec, plan, tasks, the library comment and the three pins agree, the code is
token-identical to `3ad7408`, and each pin fails on `e10da18`, passes on `3ad7408`/`c81a12d`, and
flips when its own route is modelled. But the exception is written as a closed list of three
routes, and the same mechanism is reachable through at least six documents that enter by other
doors (F1 below, blocking): a commented-out marker that the parent `e10da18` and both renderers
hide is harvested, and the exception's wording does not cover it.**

The security gate is untouched. `enforcement-pack.ps1` and `build-digests.ps1` are byte-identical
to `3ad7408` (`git diff --quiet` exit 0), and the library's non-comment token stream equals
`3ad7408`'s (976 tokens; of 37 function extents only `Convert-CodeSpanMarkers`'s differs, in
comments). Independently against the parent `e10da18`: the call graph from
`Invoke-AmendmentAuthorityCheck` and `Get-VisibleFromText` reaches 14 functions and not
`Convert-CodeSpanMarkers`; 12 of them are token-identical to `e10da18`'s; `Get-VisibleFromText`
differs only in calling `Convert-SpanText -Text` where the parent called `Convert-CodeSpanMarkers
-Line`; and `Convert-SpanText` equals the parent's per-line `Convert-CodeSpanMarkers` token for
token (223 tokens) once the name and the parameter `$Line`→`$Text` are normalised. The amendment
check's reading is therefore the parent's.

Everything `notes.md` claims for T014q reproduces (suite 887/0, every mutation row, corpus and
review-document parity, probe parity), with two counting nits (F2).

The findings:

- F1 (blocking): six more doors into the round-7/round-8 mechanism, outside the recorded
  exception.
- F2: wording and count nits in the amendment and `notes.md`.
- F3 to F6 carry over: `j-long` (now caught by the fence pin), `c1`, the D5 tail, the FR-010
  wording.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Code equals `3ad7408` | `git diff 793efbd..c81a12d -- scripts/` is two comment hunks in `markdown-lib.ps1`. `astcmp.ps1 -RevA 3ad7408 -RevB c81a12d` (PowerShell tokenizer, comments and newlines dropped): `markdown-lib.ps1` 976 tokens, `enforcement-pack.ps1` 5242, `build-digests.ps1` 935, each **identical**. Functions 37/37; extents differing: `Convert-CodeSpanMarkers` only (its comment) |
| Security gate: parity with `e10da18` | Reachable from the amendment check on `c81a12d`: `Convert-SpanText`, `Disable-CommentMarkers`, `Get-AddedRecordLines`, `Get-BlobLines`, `Get-CheckPresenceSet`, `Get-CommitMetaBatch`, `Get-ConformingRecord`, `Get-FencedLineMap`, `Get-NameStatusBatch`, `Get-VisibleFromText`, `Invoke-AmendmentAuthorityCheck`, `Test-CheckAbsentForReal`, `Test-CheckboxOnlyChange`, `Test-StatusOnlyChange`; `reaches Convert-CodeSpanMarkers: False`. Token comparison with `e10da18`: the 12 others equal; `Get-VisibleFromText` differs in the one call; `Convert-SpanText` vs the parent's `Convert-CodeSpanMarkers`: 223 tokens each, the only differences the function name and nine `$Line`/`$Text` tokens (normalised: equal). `git grep Convert-CodeSpanMarkers c81a12d -- scripts` finds one call, `build-digests.ps1:92`. `git diff e10da18 c81a12d -- scripts/enforcement-pack.ps1` is a comment hunk plus that one call |
| Full suite | `pwsh -File tests/enforcement/Run-Tests.ps1` on a `git archive c81a12d` kit: **887 passed, 0 failed, 0 skipped**, `enforcement-tests: OK`, exit 0. Matches `notes.md` |
| Ritual and scope | `pwsh -File scripts/ritual-checks.ps1` on the working tree: `RESULT OK`, exit 0. doc-lint, enforcement-pack, scope-check, digests (5 fresh, 82 markers) and roadmap-claims OK; scope-repos and verify-kit n/a. `scope-check: PASS phase 1 commit c81a12d (13 file(s))`; `43e607c` is not a phase commit |
| Pins on `c81a12d` / `3ad7408` | The `c81a12d` kit, `-Case DIGEST-001` (33 cases): **99 passed, 0 failed**. The three pin directories copied into the `3ad7408` kit: **99 passed, 0 failed**, so each was shown failing-as-expected (stale digest, exit 1) on `3ad7408`, as T014q asks |
| Pins on `e10da18` | The three pins copied into a `git archive e10da18` kit, `-Case DIGEST-001`: **37 passed, 6 failed**, exactly the three pins (two assertions each), each observing `digests: OK (1 digest(s) fresh, 1 marker(s))`, exit 0. On the `c81a12d` kit with `e10da18`'s three scripts swapped in: 85 passed, 14 failed — the three pins plus the four cases the parent cannot pass (`fail-reopen-not-modelled`, `fail-wrapped-span`, `pass-wrapped-span`, `pass-wrapped-after-closed-pre`) |
| Pins exercise their route | Each pin's document, harvested: `e10da18` gives `Visible rule.`; `c81a12d` gives `Hidden rule. \| Visible rule.`; the scan lines show `x <!@@` on the line after `?>`. Both renderers put H in a comment (`hid:comment`) for all three. Controls with the `<?x` start replaced by `x` (same fence, indentation and quote) harvest `Visible rule.` on `c81a12d`: the long-end start, not the container, fence or indentation alone, is what disarms the opener |
| Each pin flips when its route is modelled | `j-long` (no long-end start on fenced lines) fails **only** `fail-fence-…` (97/2). My `r-indent` (no long-end start on a raw line indented 4+ spaces or a tab) fails **only** `fail-indented-…` (97/2). My `r-container` (no long-end start on a block-quote line) fails **only** `fail-container-…` (97/2). (k) fails `fail-container-…` with the four container guards; (l2) fails all three pins with the two PI guards |
| Mutations (round-8 runner, `c81a12d` kit, `-Case DIGEST-001`) | none 99/0. (e) 95/4: `after-backslash-spans`, `nbsp-line`. (f) 59/40: 20 cases. (g) 97/2: `nbsp-line`. (h) 97/2: `pre-under-tag-line`. (i) 87/12: six cases. (j) 97/2: `div-in-misread-fence`. (k) 89/10. (l1), (l3), (l4) 97/2 each, the matching guard; (l2) 89/10. (m) 97/2: `script-after-tag`. (n) 91/8: four cases. (o) 97/2: `pass-wrapped-after-closed-pre`. **`c1` 99/0** (F4). **`j-long` 97/2**, `fail-fence-…` only (F3). `p-reapply` 93/6: the reopen pin and the two reopen guards. `restored: True`. Every row matches `notes.md` |
| Corpus | The 567-file list and the 91 review documents through `corpus.ps1` (markers plus SHA-256 of the scan lines), `3ad7408` vs `c81a12d` libraries on the same contents: **byte-identical** on both. The marker column also equals `e10da18`'s on all 567 corpus files. On the review documents it differs from `e10da18` in three, all known: `d3-wrapped` (the fix), `e1-tab-blank` (FR-002: a tab-only line is blank) and `d1-tail-sameline` (F5) |
| Probe documents of rounds 5-8 | 102 documents in `r5/docs`, `r5/docs2`, `r6-review/docs`, `r6-review/docs3`, `r7-review/docs`, `r7-review/docs-b`, `r7-review/ddocs`, `r8-review/docs`: `3ad7408` and `c81a12d` give **byte-identical** harvests. Round-8 `c01`-`c18` all harvest H, and every one enters by a fence, an indented code block or a container, so all are inside the exception |
| Amendment | `43e607c` is a `docs:` commit, lands before `c81a12d`, touches only `spec.md`, `plan.md`, `tasks.md`, names `anas.m, 2026-10-02` in its subject and body, and adds `**Amendment approved by**: anas.m, 2026-10-02` after the FR-003 block, after the D11 block and after T014q (added unticked). `c81a12d`'s `tasks.md` change is the checkbox alone (progress, not amendment). `contracts/` unchanged |
| Scope guard | `git diff --name-only a1258c5..c81a12d` outside `specs/016-*/` and `tests/` lists only the three scripts. `c81a12d` touches `markdown-lib.ps1`, `tests/**`, and the feature's `notes.md`/`tasks.md`. No package, manifest or workflow |

## Findings

### F1 — The exception names three routes; the same mechanism has at least six more doors, outside its wording — BLOCKING

**Where**: `spec.md` FR-003 amendment after round 8 ("… where CommonMark has none: on a real
fenced line, in an indented code block, or in a list item or block quote that CommonMark then
closes"; "… holds except where such a block begins inside a span the tracker opened through
**one of these three routes**"); `plan.md` D11 round-8 block; `scripts/markdown-lib.ps1:132-138`
(the "Not modelled either" paragraph), against the code at `:188-217`, which is unchanged since
`517f9d2`.

**Mechanism** (the one round 8 described, as the spec now states it): while a long-end span the
tracker opened is open, it ignores block starts; at its end it returns to `$resume` (`$null`, or
`'blank'` that the next blank line clears). If CommonMark started a raw HTML block inside the span
and is still in it, a later `x <!--` with no closer before the blank line is read as inline and
disarmed, although it is a line of that raw HTML block and a real comment in the browser.

The tracker opens such spans in more places than the three routes. Each of these documents is in
`r9-review/docs/`. For every one, markdown-it and commonmark.js both put H inside a comment
(`render7.js`: `H=hid:comment V=VIS`), `e10da18` harvests `Visible rule.`, and `c81a12d` (and
`3ad7408`, `517f9d2`, `c6d95a1`) harvest `Hidden rule. | Visible rule.`, with `x <!@@` in the scan
lines:

| Probe | Door | Why it is outside the three routes |
|---|---|---|
| `d01` | `<div><script>` / blank / `<?y` / `</script>` / blank / `x <!--` / blank / H / `?>` | The round-5 tag-line rule: the line is a type-6 block, the tracker takes `</script>`'s end (true for the browser) and ignores CommonMark's PI block started at `<?y`. At `</script>` it resumes `'blank'`, the blank clears it, and `x <!--` (still inside CommonMark's PI block) is disarmed. No fence, indent or container |
| `d02` | `<span> <script>` (a paragraph: not a type-7 line), then as `d01` | The tag-line rule on a paragraph line |
| `d03` | `<div>` / `<script>` / blank / `<?y` / `</script>` / … | The round-4 rule: a long-end start honoured inside a blank-ending block, where CommonMark has only div content |
| `d04` | `<div>` / `<?x` / blank / `<script>` / `?>` / blank / `x <!--` / blank / H / `</script>` | Same rule with a PI inside the div; CommonMark starts a script block at `<script>`, still open at `x <!--` |
| `d05` | `para` / `    <?x` / `<div>` / `?>` / `x <!--` | A 4-space line that continues a paragraph (indented code cannot interrupt one): not "an indented code block". The container regex strips the indentation, so the tracker opens a PI CommonMark never has |
| `d06` | `para` / `2. <?x` / `<div>` / `?>` / `x <!--` | An ordered marker other than `1.` cannot interrupt a paragraph, so this is paragraph text, not "a list item"; the container regex strips `2. ` anyway |

commonmark.js output for `d05` shows the shape: `<p>para\n&lt;?x</p>\n<div>\n?>\nx <!--\n<!--
digest: Hidden rule. -->` — the `x <!--` is raw HTML.

**Reproduction as committed cases**: `r9-review/mkg.ps1` writes each probe into the
`pass-hidden-div-in-reopen` recipe (document swapped, the visible-only digest kept, expecting
exit 0). In a `c81a12d` kit, `-Case DIGEST-001`: **99 passed, 12 failed** — exactly the six
`pass-r9-*` cases, each observing `digests: RESULT FAIL (1 issue(s))` (stale digest), exit 1. In
the same kit with `e10da18`'s three scripts: all six pass (the 14 failures are the pins and the
four cases the parent cannot pass, as above). My controls `d07` (a comment block inside a div)
and `d08` (a PI inside a div with a nested `<div>`, resuming `'blank'`) hide H on `c81a12d`, as
they should.

**Why this blocks**: under FR-003 as amended, `x <!--` in each probe is a line of a raw HTML
block that does not begin inside a span opened by a fence, an indented code block or a closing
container, so the fix must not change it, and it does. The owner accepted the three named routes,
not the class; nothing records `d01`-`d06`. Rounds 4, 5, 7 and 8 treated unrecorded shapes of
this class as blocking, and I do the same. It is **not a regression of this round** (all six
harvest H on `c6d95a1` and `517f9d2`), the corpus exposure is nil (567-file marker parity with
`e10da18`), and `d01`/`d03` are the most plausible forms (an HTML example with an unclosed
`<script>` followed by a PI or declaration).

The pattern matters more than the six probes. Round 8 enumerated the doors it found, and the
amendment turned that list into a closed exception. Doors `d01`-`d04` come from the tracker's own
modelled rules (round-4 and round-5 amendments), and `d05`/`d06` from the container regex, which
strips any indentation and any `\d{1,9}[.)]` marker whether CommonMark reads it as a container or
not. More are likely (for example any other text the container regex strips where CommonMark sees
a paragraph). Another route-by-route list will be incomplete again.

*Action: amend FR-003 and D11 with the owner's approval and either (a) model, which the amendment
itself says needs CommonMark's block structure, or (b) restate the exception **by mechanism**,
not by route: for example, "wherever the tracker holds a long-end span that CommonMark does not
(whether because it misreads block structure — a fence, indented code, a container, a paragraph
continuation — or because it follows the browser into an element CommonMark's block does not
contain), a raw HTML block CommonMark starts inside that span is not seen, and a real comment's
opener after the span's end may be disarmed". Then make the library's "Not modelled either"
paragraph and the Out of Scope reconciliation say the same, and add one pin per family not yet
pinned (a modelled-rule door such as `d01` or `d03`, and a paragraph door such as `d05`), shown
on `c81a12d` (stale) and on `e10da18` (fresh). The existing three pins can stay.*

### F2 — Wording and count nits — MINOR (non-blocking)

- `spec.md`: "Five review rounds found this class through a new route each time"; `plan.md` D11
  says "Rounds 4, 5, 7 and 8", four. One of them should change (or name the fifth).
- `notes.md`: "On `e10da18`'s three scripts the pins give 33 passed, 6 failed" reproduces only
  when the three pins are run alone (33 harness assertions + 6). In an `e10da18` kit with its own
  two DIGEST-001 cases plus the pins I get 37/6; with `c81a12d`'s cases and `e10da18`'s scripts,
  85/14. Say which setup.
- `notes.md`: "Probe documents of rounds 5 to 8 (101)": the eight directories hold 102 (the
  round-8 review counted 83 + `r7-review/ddocs`'s one + 18). Harmless: all 102 match.
- The library's "the other elements whose text the browser reads raw (title, …)" — `title` (like
  `textarea`) is RCDATA. Harmless.

*Action: optional.*

### F3 — `j-long` is now caught only by a pin — CONFIRM (recorded)

`j-long` gives 97/2, failing only `fail-fence-long-end-not-modelled`. D11 records the half of
"every start is read on fenced lines" as unguarded beside `c1`, and the pin now detects its
removal (in the direction of modelling the fence route, which is what the pin is meant to flag).
The plan's "93/0" is the pre-change figure; `notes.md` gives the new one.
*Action: none.*

### F4 — `c1` still unguarded — CONFIRM (owner-accepted, recorded)

`c1` (`$raw` for `$body` at the end check) gives 99/0. Recorded in D11 (round 5).
*Action: none.*

### F5 — The D5 tail still loses a marker the parent kept — CONFIRM (owner-accepted, phase 2)

Unchanged: `d1-tail-sameline` harvests nothing on `c81a12d`, `Rule two.` on `e10da18`, as on
`3ad7408`.
*Action: none in phase 1. DIGEST-020 direction in T016.*

### F6 — FR-010's wording — MINOR (carried)

`spec.md` is in this diff, but FR-010 is not reworded.
*Action: owner may reword; no code change.*

## Earlier findings — status

- **Round 8 F1** (a long-end start in a fence, in indented code or in a closing container masks
  a later block start): **closed by naming, for those three routes**. Spec, plan, tasks, library
  comment and pins say the same thing; the exception is not wider than the behaviour, and every
  round-8 probe (`c01`-`c18`) falls inside it. It is narrower than the mechanism (F1).
- **Round 8 F2** (wording): **fixed**. `pre` and `textarea` are no longer called raw-text
  elements; the reopen pin's description now says the digest check passes and the case fails.
- **Round 8 F3** (`j-long` unguarded): **recorded**, now detected by the fence pin (F3).
- **Round 8 F4** (`c1`): **accepted and recorded** (F4).
- **Round 8 F5** (D5 tail): **open**, owner-accepted (F5).
- **Round 8 F6** (FR-010): **open**, minor (F6).
- **Rounds 1-7**: unchanged. The amendment check's code equals `e10da18`'s reading.

## Amendments in this diff

- [x] Amendments listed. `43e607c` (a `docs:` commit before `c81a12d`) amends spec FR-003, plan
  D11 and tasks T014q, each block closed by `**Amendment approved by**: anas.m, 2026-10-02`; the
  commit subject and body name the same approver and date. `c81a12d` ticks T014q only. Every
  T014q sub-step is done and recorded (pins shown on `3ad7408` and `e10da18`, paragraph, "only
  effect" sentence, F2 wording, token parity, suite, mutations, corpus, review documents, probes,
  F3). `contracts/` unchanged.

## Constitution re-check (post-implementation)

**PASS on VI (Security).** The amendment-authority gate's code and every function it reaches are
token-identical to `3ad7408`, and its reading equals the parent `e10da18`'s. AMEND-001 is green in
the 887-test suite.

**FAIL on FR-003 as amended** for the digest consumer: F1's six probes harvest comment-hidden
markers by changing the lines of a raw HTML block outside the three named routes.

- I: the amendment is approved, lands first, and covers the change made.
- II: no rung conflict between documents; the documents' closed list of routes does not match
  the code's behaviour (F1).
- IV: no new dependency or architecture.
- VIII: the three pins were shown on `3ad7408` and `e10da18`, and each flips when its route is
  modelled. F1's doors have no pin.
- IX: this review.
- X: one phase, Territory held, `scope-check` PASS.

**Against the amended spec** (changes from round 8 only):

| Item | Status |
|---|---|
| FR-003 (as amended after round 8) | **Not met** (F1: `d01`-`d06`) |
| FR-004 | Met: full suite 887/0, run by me |
| FR-008 | Met: DIGEST-001 has 33 cases (99 assertions in the `-Case` run) |
| SC-002 (as amended) | Met for the amendment consumer (code parity) |
| SC-004 (as amended) | Met for the committed guards and pins. `c1` unguarded (F4); `j-long` detected by a pin (F3); F1 has no pin |
| FR-010 | Loosely met (F6) |

## Test coverage observed

- The three new pins hold the three named routes, and each is specific to its route
  (`j-long`, `r-indent`, `r-container` each fail exactly one).
- Not covered: a long-end span from the tag-line rule or from a start inside a blank-ending block
  that masks a CommonMark long-end block start (`d01`-`d04`); a long-end start on a line the
  container regex strips but CommonMark reads as paragraph text (`d05`, `d06`).

## Residual risk

The security gate holds: the amendment check's code is unchanged, and its reading is the
parent's.

In the digest generator, the round-4/5/7/8 F1 class remains reachable through doors the
exception does not name (F1). Exposure in the corpus is nil, and every shape needs a long-end
span followed by a CommonMark block start, the tracker's end and an unclosed opener. The fix for
F1 can be documentary (an exception stated by mechanism, plus pins), but as written the spec
promises more than the code delivers.

What remains besides F1 is minor: F2's nits, and F3 to F6, carried over.

Every experiment ran in `…/D--solutions-agentic-sdlc-kit/r9-review/`. `git hash-object
scripts/markdown-lib.ps1` is `fd300f7…` before and after. The repository shows no change beyond
this review file and the pre-existing untracked `.claude/settings.local.json`.
