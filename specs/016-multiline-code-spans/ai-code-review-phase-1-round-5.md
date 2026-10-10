# AI Code Review — 016 Multi-line Code Spans (Phase 1, round 5)

**Reviewer**: fresh-context agent — claude-opus-5-5
**Date**: 2026-10-01
**Branches**: agentic-sdlc-kit `016-multiline-code-spans` (tip `c6d95a1`)
**Scope reviewed**: the round-4 remediation, `git diff 5d1706b..c6d95a1`. That is the amendment
`641a3f5` (spec SC-002/SC-004, the US2 wording, tasks T014m) and the fix `c6d95a1`
(`scripts/markdown-lib.ps1`, ten DIGEST-001 `pass-hidden-*` directions, the `rules.json` notes,
`notes.md`). I also read the whole branch against its base (`git merge-base main HEAD` =
`a1258c5`) for regressions and scope.
**Feature contract**: phase 1 = T001-T014m. The amendment check keeps the parent's per-line reading,
unchanged (D11). The digest generator uses the whole-document rule (`Convert-CodeSpanMarkers`).
FR-003 as amended says the fix "never changes the lines of … a raw HTML block". No new dependency
and no new script. Territory is the three scripts plus `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: claude-opus-5-5 (the implementing session)
- **Inputs provided**: `git diff 5d1706b..c6d95a1` in full. `git show` of `641a3f5` and `c6d95a1`
  (message, stat, the `tasks.md` hunks). `git diff --name-only a1258c5..c6d95a1`. For
  `specs/016-multiline-code-spans/`: the four earlier reviews, `spec.md` (FR-002/003, FR-010, the
  round-3 and round-4 amendment blocks), `plan.md` D11, `tasks.md` (T014m and the Notes section)
  and `notes.md` (the round-4 remediation section). The kit's law (`CLAUDE.md`,
  `.specify/memory/constitution.md`, `docs/sdlc/definition-of-done.md`,
  `docs/sdlc/review-process.md`), loaded as project instructions. I had read and run access to the
  working tree. Every experiment ran in this session's `scratchpad/r5/`, against scratch copies of
  the `e10da18`, `b45cff1` and `c6d95a1` scripts, a `git archive c6d95a1` kit copy for harness
  runs, and 11 library variants (one sketch fix, ten mutations). The markdown-it 14 and
  commonmark.js packages from the earlier reviewers' scratch were used read-only as measuring
  tools. The library's hash was taken before the runs and checked after. No repository file other
  than this review was modified.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES. The round-4 findings are closed, but one of the fix's own additions opens a new
shape of the round-4 F1 class.**

The security gate is untouched. `c6d95a1` does not change `enforcement-pack.ps1` or
`build-digests.ps1`. In the library, `Convert-SpanText`, `Disable-CommentMarkers` and
`Get-FencedLineMap` are byte-identical to `b45cff1` (AST extents compared). So the amendment
check's reading is still the parent's, which round 4 proved by code, corpus and fuzz. AMEND-001 is
green in the full suite.

On the digest side, every round-4 F1 document now hides its marker: a1, a2, b1-b5, c1, f1 and
`div-fence`. Round-4 F2's container and end guards exist and do guard (I reproduced (i)-(m)). The
SC-002/SC-004 and US2 wording are amended (F3), and the round-4 F4 overclaims are corrected.

But T014m did more than its two approved tracker changes. The fix also made "a tag line that opens
`pre`, `script`, `style` or `textarea` later on the line takes that element's end" (mutation (m)).
That branch drops the enclosing block. When the inner element closes, the tracker returns to
`$resume`, and `$resume` is `$null` because the tag line *is* the enclosing block. So the rest of a
`<div>` block is read as inline. `<div><script src="a.js"></script>`, `<div><pre></pre>` or
`<td><textarea>a</textarea></td>`, followed by an ordinary comment line, is enough. Seven documents
hide their marker on `b45cff1` and `e10da18`, and harvest it on `c6d95a1` (F1). That is round-4
F1's mechanism ("the override forgets the enclosing block") on a path the fix itself added. It
breaks FR-003 as amended. The comment and `notes.md` also say this change "disarms less, never
more", which is false. Exposure is latent: 0 of 567 kit and adopter files change. The fix is one
condition, and I sketched it. It keeps all 75 DIGEST-001 tests green and changes no line of the
corpus.

The other findings:

- F2: the `c1` change (ends read after the container markers) is still unguarded. That is
  acceptable, but the record should say so.
- F3: T014m and plan D11 do not name two of the four tracker changes (the `c1` and `(m)` changes).
- F4: the D5 tail loss is still open, owner-accepted (round-4 F5).
- F5: FR-010's wording is unchanged (round-4 F6).

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Security gate: parity by code | `git diff --quiet b45cff1 c6d95a1 -- scripts/enforcement-pack.ps1 scripts/build-digests.ps1` exits 0. I extracted the `Convert-SpanText`, `Disable-CommentMarkers` and `Get-FencedLineMap` AST extents from both libraries: identical. Every library hunk is in `Convert-CodeSpanMarkers` or its header comment. Round 4's parity proof (1,088 files, a 20,000-document fuzz) therefore carries over unchanged |
| Full suite | `pwsh -File tests/enforcement/Run-Tests.ps1` on the working tree: **863 passed, 0 failed, 0 skipped**, `enforcement-tests: OK`, exit 0. That matches `notes.md` |
| Ritual and scope | `pwsh -File scripts/ritual-checks.ps1`: `RESULT OK`, exit 0. doc-lint, enforcement-pack, scope-check, digests (5 fresh, 82 markers) and roadmap-claims are OK; scope-repos and verify-kit are n/a. `pwsh -File scripts/scope-check.ps1`: `PASS phase 1 commit c6d95a1 (34 file(s))`, exit 0 |
| Round-4 F1 closed | 91 documents from rounds 1-4 (`scratchpad/review*/`), harvested by each version's `Get-DocMarkers` (loaded from its own script's AST, against its own library). `b45cff1` → `c6d95a1` changes exactly 10 documents, and each now hides its marker: a1, a2, b1, b2, b3, b4, b5, c1, f1 and `div-fence`. `e10da18` → `c6d95a1` differs on 3 documents only. `d3-wrapped` is GAP-028 fixed. `d1-tail-sameline` is F4. `e1-tab-blank` is the `notes.md` exception: markdown-it and commonmark.js both render its marker as a standalone comment, so the claim holds |
| Guards and mutations | In the scratch kit, DIGEST-001 `-Case DIGEST-001` (75 tests) gives 75/0 on `c6d95a1` and 75/0 with my sketch fix. These mutations each exit 1: (i) 4 failed, (j) 2, (k) 4, (k2) 2, (l1) 2, (l2) 2, (l3) 2, (l4) 2, (m) 2. A scratch harvest names the guard each one turns, exactly as the `notes.md` table says. Mutation `c1`, which reads ends on `$raw` again, gives **75/0** (F2) |
| Guards on `b45cff1` | `div-after-comment-line`, `div-after-pre`, `div-in-misread-fence` and `script-after-tag` harvest the hidden marker. The other six pass. This matches the `rules.json` note and the `notes.md` table |
| Corpus | 567 `.md` files: the kit plus fitforge, flowboard and expense-tracker. The harvest is equal on all 567 for `e10da18`, `b45cff1`, `c6d95a1` and the sketch fix. The scan lines (a SHA-256 of `Convert-CodeSpanMarkers`' output) are equal on all 567 for `b45cff1`, `c6d95a1` and the sketch fix |
| New probes | 12 documents of mine (`r5/docs/`) and 2 more (`r5/docs2/`), table in F1. Each was rendered with markdown-it 14 and commonmark.js, and I checked whether the hidden marker sits inside an earlier comment |
| Amendments | `641a3f5` is a `docs:` commit that lands before `c6d95a1`, names the approver, and adds `**Amendment approved by**: anas.m, 2026-09-30` after the SC block and after T014m (T014m added unticked). `c6d95a1` ticks T014m in `tasks.md` and changes nothing else there. Plan D11 is not amended (F3) |
| Scope guard | `git diff --name-only a1258c5..c6d95a1` outside `specs/016-*/` and `tests/` is the three scripts only. No package, manifest or workflow file is touched |
| Rollback safety | Self-contained: reverting `c6d95a1` restores `b45cff1`'s library and removes ten case directories. No data or schema is involved |

## Findings

### F1 — A tag line holding a raw-text element drops its enclosing block; seven shapes are new in `c6d95a1` — BLOCKING (FR-003; not a security finding)

**Where**: `scripts/markdown-lib.ps1:171-184`. The new `-or` alternative on `$longEnd` is at
`:171-172`, and `$resume` is set at `:181`:

```powershell
$longEnd = if ($body -match '(?i)^<(pre|script|style|textarea)(\s|>|$)' -or
               ($body -match '^<[A-Za-z/]' -and $body -match '(?i)<(pre|script|style|textarea)(\s|>|$)')) { ... }
...
if ($longEnd -and ($null -eq $htmlEnd -or $htmlEnd -eq 'blank')) {
    $resume = if ($htmlEnd -eq 'blank') { 'blank' } else { $null }          # :181
    if ($body -match $longEnd) { $htmlEnd = $resume; $resume = $null } else { $htmlEnd = $longEnd }
```

**What**: A line such as `<div><script src="a.js"></script>` starts a CommonMark type-6 block,
which runs to the next blank line. On `b45cff1` the tracker read it so: `htmlEnd = 'blank'`. On
`c6d95a1` the new alternative makes it a long-end start. But the enclosing block is this same line,
so `$htmlEnd` is `$null` when it starts, and `$resume` becomes `$null`. When the element closes,
the tracker returns to `$null`, either on the same line or on a later one before the blank. So the
rest of the `div` block counts as inline, and an unclosed `<!--` there is disarmed. This is round-4
F1 (1), "the override forgets the enclosing block", on the branch the fix added. It was not in
round 4's sketch, and neither T014m nor D11 names it (F3).

**Failing inputs** (`H` = `<!-- digest: Hidden rule. -->`, `V` = `<!-- digest: Visible rule. -->`,
`␤` = blank line; each document is `L1` / `L2` / ␤ / H / ␤ / V). The files are in `r5/docs/`:

| Doc | L1 | L2 | `e10da18` | `b45cff1` | `c6d95a1` | markdown-it / commonmark.js | sketch fix |
|---|---|---|---|---|---|---|---|
| n1 | `<div><pre></pre>` | `z <!-- hidden` | V | V | **H, V** | H inside `<!-- hidden` | V |
| n2 | `<div><pre>` then `x</pre>` | `z <!-- hidden` | V | V | **H, V** | H inside | V |
| n3 | `<div><script src="a.js"></script>` | `z <!-- hidden` | V | V | **H, V** | H inside | V |
| n4 | `<td><textarea>a</textarea></td>` | `z <!-- hidden` | V | V | **H, V** | H inside | V |
| n5 | `<p><style>p{}</style>` | `z <!-- hidden` | V | V | **H, V** | H inside | V |
| n6 | `- <div><pre>x</pre>` | `  z <!-- hidden` | V | V | **H, V** | H inside | V |
| n7 | `> <div><script></script>` | `> z <!-- hidden` | V | V | **H, V** | H inside | V |

(n2 has three lines before the blank.) markdown-it emits n3 verbatim as
`<div><script src="a.js"></script>\nz <!-- hidden\n<!-- digest: Hidden rule. -->\n<!-- digest: Visible rule. -->`.
The browser comment that opens at `z <!--` closes at H's `-->`, so the author has commented that
rule out. `b45cff1` and the parent hide it, and `c6d95a1` puts it in the digest. `build-digests
-Check` then certifies a digest carrying a rule the source does not show. The cause is confirmed by
mutation: removing the `(m)` alternative alone makes all seven hide H again.

Reproduce: `pwsh -File r5/harvest.ps1 -LibDir r5/c6d95a1 -DocDir r5/docs` prints
`n3.md: Hidden rule. | Visible rule.`, and the same command with `-LibDir r5/b45cff1` prints
`n3.md: Visible rule.`. In a kit, the DIGEST-001 recipe of `pass-hidden-script-after-tag` with
`fixture-law.md` replaced by n3, and the same one-rule digest, would fail on `c6d95a1` and pass on
`b45cff1`.

**Suggested fix** (sketch, `r5/mutate.ps1` entry `fix`). When the long end comes from a tag line,
the line itself opens a blank-ending block, so return to `'blank'`:

```powershell
$resume = if ($htmlEnd -eq 'blank' -or
              ($null -eq $htmlEnd -and $body -match '^<[A-Za-z/]' -and
               $body -notmatch '(?i)^<(pre|script|style|textarea)(\s|>|$)')) { 'blank' } else { $null }
```

This only keeps more lines in HTML. With it, DIGEST-001 gives 75/0 in the scratch kit. All 15
`pass-hidden-*` documents and n1-n7 hide H. The 91 earlier review documents harvest as on
`c6d95a1`. The 567-file corpus is unchanged, both harvest and scan lines.
*Action: implementer fixes in phase 1, with n3 (or n1) as a DIGEST-001 `pass-hidden-*` direction,
shown harvesting H on `c6d95a1`. Record a mutation that sets `$resume` back to `$null` for the
tag-line start. Correct the two "never more" sentences (`markdown-lib.ps1:116-118`, "which keeps
more lines on the per-line result, never fewer", and `notes.md`, "Each change disarms less, never
more"). Then re-review. Under F3, the T014m/D11 wording should name the change.*

**Also noted, not a finding.** A real fence that shows an unclosed raw-text tag line (`` ```html `` /
`<div><textarea>` / `` ``` ``) now holds the long-end state to the end of the document. Every later
GAP-028 span then keeps the parent's reading. `r5/docs2/q7.md` harvests V on `b45cff1` and loses
it on `c6d95a1` and on the parent. This is the conservative direction (the parent's result), and
`b45cff1` already did the same for a fenced `<script src="a.js">` (`q8.md`). The comment's "on a
real fence's lines the only effect is that more lines keep the per-line result" is accurate, but
"more lines" can mean the rest of the document.

### F2 — Reading ends after the container markers (`c1`) is unguarded — MINOR (recorded; acceptable)

**Where**: `scripts/markdown-lib.ps1:189` (`elseif ($body -match $htmlEnd)`).

Confirmed: the mutation back to `$raw -match $htmlEnd` gives DIGEST-001 **75/0**. My document `c1`
(`> <!DOCTYPE x` / `> a` / `> z <!-- hidden` / ␤ / H / ␤ / V) does catch it: it harvests H under the
mutation and hides it on `c6d95a1`. `notes.md` declares this gap honestly, and I agree it need not
block. The change only keeps more lines in HTML. The shape is also unclear in a browser: a DOCTYPE
token runs to the next `>`, which can swallow the `<!--`, so a guard would pin a reading that
markdown-it and commonmark.js support and that a browser may not.
*Action: none required. Optionally commit `c1` as a guard with that caveat in its description, or
leave the declared gap as it stands.*

### F3 — T014m and plan D11 do not describe two of the four tracker changes — DOC DRIFT (process)

The approved T014m names two tracker changes: "returns to the enclosing block" and "a start of a
block ending at a blank line is honoured on a line the fence map calls fenced". `c6d95a1` makes
four. The other two are "ends are read after the container markers" (`c1`) and "a tag line that
opens a raw-text element later on the line takes that element's end" (`m`). The `c1` change is
round-4 speculation, and the `m` change is new behaviour (round-4 listed f1 only as a document).
Both are in the phase's Territory, and both went through the harness test-first (`notes.md`), so
scope-check is right to pass. But the behaviour was not in the approved task, and F1 is exactly
in the unapproved part. Plan D11's tracker bullet also still reads "even on a line the fence map
calls fenced" for long-end starts only, and has no resume rule. Round 4 asked for D11's tracker
wording to be amended, and `641a3f5` amended the spec and tasks only.
*Action: with F1's fix, an owner-approved amendment to T014m (and D11's tracker bullet) names all
four changes and the F1 correction.*

### F4 — The D5 tail still loses a marker the parent kept — CONFIRM (owner-accepted, phase 2)

Unchanged from round-4 F5. `review3/ddocs/d1-tail-sameline.md` harvests `Rule two.` on `e10da18`
and nothing on `c6d95a1`. It is the only loss against the parent among the 91 review documents.
*Action: none in phase 1 (owner decision of 2026-09-30). DIGEST-020 direction in T016.*

### F5 — FR-010's wording — MINOR (carried)

Unchanged from round-4 F6. The FR-010 amendment block still reads "a document with no opener that
the rule could disarm takes no additional work", and the candidate pre-pass is that work.
*Action: owner may reword; no code change.*

## Earlier findings — status

- **Round 4 F1** (the tracker forgot the enclosing block; a misread fence masked a type-6/7
  start): the documents are **fixed**. All eight round-4 F1 documents, plus `f1` and `div-fence`,
  hide their marker. Three are committed as guards (`div-after-comment-line`, `div-after-pre`,
  `div-in-misread-fence`), and each fails under mutation (i) or (j), reproduced. The class is
  **reopened** by the `(m)` branch (F1 above).
- **Round 4 F2** (unguarded container and ends): **fixed**. `list-div`, `quote-div`,
  `comment-block-open`, `pi-block`, `cdata-block` and `declaration-block` are committed. Mutations
  (k), (k2) and (l1)-(l4) each turn their guard red, reproduced. The one declared residue is F2
  above.
- **Round 4 F3** (SC-002/SC-004 and the US2 citation): **fixed** by `641a3f5`. SC-002 and SC-004
  are re-read for D11. The US2 text now cites the Notes section of `tasks.md`, which does carry the
  rule ("confirm none of those spans wraps across lines").
- **Round 4 F4** (overclaims): **fixed** as listed: the code comment, the gap row's "up to the next
  `-->`", the `-Line`→`-Text` note and the `rules.json` wording. One **new** overclaim comes with
  F1 ("never fewer" / "never more").
- **Round 4 F5** (D5 tail): **open**, owner-accepted (F4).
- **Round 4 F6** (FR-010): **open**, minor (F5).
- **Rounds 1-3**: status unchanged from round 4. The amendment-check reading is the parent's, and
  no file it uses changed in this diff.

## Amendments in this diff

- [x] Amendments listed. `641a3f5` (a `docs:` commit before `c6d95a1`) amends spec SC-002/SC-004
  for D11, corrects the US2 citation, and adds tasks T014m. Each carries `**Amendment approved
  by**: anas.m, 2026-09-30`, and the commit message names the approver. `c6d95a1` ticks T014m
  only. Plan D11 is not amended, and T014m does not name two of the four changes made (F3).
  `contracts/` is unchanged.

## Constitution re-check (post-implementation)

**PASS on VI (Security).** The amendment-authority gate's code is untouched by this diff, and
AMEND-001 is green in the 863-test suite. **FAIL against the spec on FR-003** for the digest
consumer (F1). This is a tooling correctness defect, not a security one. I: the amendment is
approved and lands first, but it does not cover two of the changes made (F3). II: no rung conflict
remains from round 4. IV: no new dependency or architecture. VIII: every new guard was shown
failing on `b45cff1` or under its mutation, but the `(m)` branch's own regression has no case
(F1). IX: this review. X: one phase, Territory held, `scope-check` PASS.

**Against the amended spec** (changes from round 4 only):

| Item | Status |
|---|---|
| FR-003 | **Unmet** (F1: seven shapes new in `c6d95a1`; the round-4 shapes are closed) |
| FR-004 | Met: full suite 863/0, run by me |
| FR-008 | Met: DIGEST-001 gains ten directions, and `rules.json` names them |
| SC-002 (as amended) | Met for the amendment consumer (code parity) |
| SC-004 (as amended) | Met for the committed guards. The `(m)` branch's resume and the `c1` end have no guard (F1, F2) |
| FR-010 | Loosely met (F5) |

## Test coverage observed

- The ten new DIGEST-001 directions guard what they claim. Each is a hand-written one-rule digest
  that must stay fresh, so a harvested hidden marker makes `-Check` exit 1. Four harvest on
  `b45cff1`, as the notes say, and six guard code that round 4 showed could be deleted.
- `pass-hidden-script-after-tag` covers the `(m)` branch only where the element stays open past
  the blank line. Nothing covers an element that closes inside its enclosing block (F1).
- `pre-in-misread-fence` is now caught by (j) as well as (h), as `notes.md` says.

## Residual risk

The security gate holds: the amendment check's code is unchanged, and its reading is the parent's.
The remaining risk is F1 in the digest generator. It is a latent fail-open that puts a
commented-out rule into a digest, reachable with ordinary inline raw HTML such as
`<div><script src="…"></script>` followed by a comment line. It breaks an approved requirement,
the fix that caused it introduced it, and a one-condition conservative change closes it. F3 travels
with that fix. F2 is declared, F4 is phase 2's, and F5 is wording. Every experiment ran in
`scratchpad/r5/`. `git hash-object scripts/markdown-lib.ps1` equals the pre-run hash, and
`git diff --quiet` exits 0. The repository shows no change beyond this review file and the
pre-existing untracked `.claude/settings.local.json`.
