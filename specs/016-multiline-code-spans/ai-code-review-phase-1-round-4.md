# AI Code Review — 016 Multi-line Code Spans (Phase 1, round 4)

**Reviewer**: fresh-context agent — claude-opus-5-5
**Date**: 2026-09-30
**Branches**: agentic-sdlc-kit `016-multiline-code-spans` (tip `b45cff1`)
**Scope reviewed**: phase 1 as four commits: `7a770e5`, `6f75415`, `8e45e37` and `b45cff1` (the D11
implementation). I read them through the net script change `git diff e10da18..b45cff1 -- scripts/`
(`scripts/markdown-lib.ps1`, `scripts/enforcement-pack.ps1`, `scripts/build-digests.ps1`). I also read
the five new DIGEST-001 directions and AMEND-001 `fail-wrapped-span-hidden`, the `rules.json` and
`tasks.md` changes, and the amendment `6e7e902` (spec US2 and FRs, plan D11, tasks T014i-T014l).
**Feature contract**: phase 1 = T001-T014l. There is one shared library. The amendment check keeps the
parent's per-line reading (`Convert-SpanText`), unchanged (D11). The digest generator uses the
whole-document rule (`Convert-CodeSpanMarkers`). That rule is the per-line result plus the D10 disarm
with the round-3 fixes, and it keeps line count and lengths (D1). Build-digests precomputes and indexes
(D5). No new dependency and no new script. Territory is the three scripts plus `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: claude-opus-5-5 (the implementing session)
- **Inputs provided**: `git diff e10da18..b45cff1 -- scripts/` and `-- tests/enforcement/rules.json`,
  `git show --stat` of every commit in `e10da18..b45cff1`, `git show b45cff1 -- tasks.md`, and the
  recipes of the five new DIGEST-001 guards. For `specs/016-multiline-code-spans/`: the three earlier
  reviews (`ai-code-review-phase-1.md`, `-round-2.md`, `-round-3.md`), `spec.md` (as amended),
  `plan.md` (D1-D11), `tasks.md` (phase 1 and its Territory) and `notes.md` (rounds 1-3 remediation
  and the draft gap row). The kit's law (`CLAUDE.md`, `.specify/memory/constitution.md`,
  `docs/sdlc/definition-of-done.md`, `docs/sdlc/review-process.md`), loaded as project instructions.
  The review template. The implementer's `parity.ps1`, read but not trusted: I wrote and ran my own.
  The round-3 reviewer's scratch documents, which I re-ran. I had read and run access to the working
  tree. Every experiment ran in `scratchpad/review4/`, against scratch copies of the `e10da18` and
  `b45cff1` scripts, a `git archive b45cff1` kit copy for harness runs, and 16 mutation variants. No
  repository file other than this review was modified.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES. The security gate passes; the digest side does not.**

The security question gets the answer **no**. On every document I could build or find, `b45cff1`'s
amendment check gives the same result as `e10da18`'s. I proved it three ways:

- **Code.** The bodies of `Convert-SpanText` and the parent's `Convert-CodeSpanMarkers` are identical
  once the name, the parameter name and the comments are normalised (a mechanical diff).
  `Get-VisibleFromText` changes in one call only. `Disable-CommentMarkers` and `Get-FencedLineMap` are
  untouched. The library defines no script-scope state, and the enforcement pack defines nothing that
  shadows it.
- **Corpus.** I compared both versions on 1,088 files: the kit, the three adopters, and every earlier
  reviewer's scratch document. None differ.
- **Fuzz.** 20,000 random documents built from 34 tokens. None differ.

The digest generator has the problem this time. The round-3 tracker fix closed the three shapes it
was aimed at, but it leaves raw HTML blocks that the rule ends too early or never sees. Its own
override opens four of those shapes: they pass on `8e45e37`'s tracker and fail on `b45cff1`'s. In
each, the generator harvests a marker that the renderer puts inside a real comment, and the parent
hides it (F1). That breaks FR-003 as amended: "the fix never changes the lines of … a raw HTML block".
A `<div>` followed by a one-line comment is enough. Exposure is latent: 0 lines across 566 files. The
fix is about four lines. I sketched it, and it closes every verified shape while keeping all 55
DIGEST-001 tests green. The other findings:

- F2: guard gaps. The container regex and four of the five long ends can be deleted with the suite
  green.
- F3: SC-002 and SC-004 were not amended to match D11.
- F4: overclaims in comments and notes.
- F5: the D5 tail loss is still open, and the owner has accepted it for phase 2.
- F6: FR-010's wording.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Security gate: parity by code | I extracted both per-line functions and applied `s/$Line/$Text/; s/Convert-CodeSpanMarkers/Convert-SpanText/` to the parent's. The diff is two comment lines. `Get-VisibleFromText` differs from `e10da18` in one line (`enforcement-pack.ps1:892`, the call). `git grep` at `e10da18` shows only two callers of the old function, and both have moved. Nothing else in `scripts/` or `tests/` calls either name. `markdown-lib.ps1` only defines functions: no top-level assignment, no second dot-source. `enforcement-pack.ps1` defines no function or alias with a library name |
| Security gate: parity by output | `review4/parity.ps1` loads each version's `Get-VisibleFromText` from its own script's AST into separate modules, against its own library. Corpus: **1,088 files, 0 differ**. That covers the kit, fitforge, flowboard, expense-tracker, and all of `scratchpad/review`, `review2` and `review3`: every round-1 to round-3 shape, including j1-j3, k1-k4, l1 and m1-m3. Fuzz: **20,000 documents, 0 differ**. The tokens include NBSP, form feed, tab, `<pre>`, `<div>`, containers, fences, `<?`, `<![CDATA[`, `<!D`, `<!-->`, backslashes and a conforming record |
| Security gate: harness | AMEND-001 in the scratch kit gives 77 passed, 0 failed. Mutation (i) points `Get-VisibleFromText` at the whole-document rule. Only `fail-wrapped-span-hidden` fails then (2 assertions): the pin is the only case that would catch that switch (see F2) |
| Digest direction | I built 17 documents and 8 guard documents, and ran `Get-DocMarkers` from each script's AST. Each was also rendered with markdown-it 14 and commonmark.js, and I checked whether the marker is a standalone comment in the HTML or sits inside an earlier one. **Seven distinct shapes** (eight documents) harvest a marker that sits inside a real comment on `b45cff1`, where `e10da18` hides it (F1); an eighth shape, `c1`, is speculative. None of the 8 guards is harvested on `b45cff1` |
| D1 | `review4/d1.ps1`, 15,000 random documents: **0 violations** of count, length, "only `<!--`→`<!@@` / `-->`→`@@>` changes", "every per-line disarm kept" and "disarms beyond per-line are only `<!--`". Empty input and one-line input return `String[]` |
| notes.md claims | 566 files; the digest reading differs from per-line on **5** lines, which are exactly the ones `notes.md` names. The 566-file parity matches as well |
| Mutations | 16 variants of the digest rule, each run through DIGEST-001 (55 tests) in the scratch kit and through my documents (table in F2) |
| Spec match | See "Constitution re-check" below. FR-003 is broken by F1. SC-002 and SC-004 contradict D11 (F3) |
| Feature contract held | No new dependency and no new script. The renderers ran from scratch as measuring tools |
| Constitution / amendments | `6e7e902` is a `docs:` commit that lands before `b45cff1`. Its message names the approver, and each amended section carries `**Amendment approved by**: anas.m, 2026-09-30`. `b45cff1` changes `tasks.md` by four checkbox ticks only (diff read) |
| Scope guard | `pwsh -File scripts/ritual-checks.ps1` gives `RESULT OK`: doc-lint, enforcement-pack, scope-check, digests and roadmap-claims are OK, scope-repos and verify-kit are n/a. `--stat` of `7a770e5`, `6f75415`, `8e45e37` and `b45cff1` touches only the three scripts, `tests/**`, and the feature's `notes.md`/`tasks.md` |
| Harness | Targeted runs only. DIGEST-001: 55/0. AMEND-001: 77/0. I did not re-run the full suite; `notes.md` records 843/0 |
| Rollback safety | Self-contained: reverting the four commits restores the parent's scripts and cases. No data or schema is involved |

## Findings

### F1 — The digest rule still disarms openers inside raw HTML blocks; four shapes are new in `b45cff1` — BLOCKING (FR-003; not a security finding)

**Where**: `scripts/markdown-lib.ps1:166-177`. The two mechanisms are at `:169` and `:174`:

```powershell
$htmlEnd = if ($body -match $longEnd) { $null } else { $longEnd }   # :169, and :173 on a later line
} elseif (-not $fenced[$i] -and $body -match '^<[A-Za-z/]') {       # :174
```

**What**: The rule may disarm an opener only outside raw HTML blocks (FR-003 as amended). Two cases
still break that:

1. **The override forgets the enclosing block.** A long-end start is now honoured inside a
   blank-ending block (the round-3 fix). When that inner block ends, `$htmlEnd` becomes `$null`, not
   `'blank'`, so the rest of the enclosing type-6/7 block counts as "inline". That is true whether the
   inner block ends on its own line or on a later one. In CommonMark a `<pre>` or `<!-- … -->` line
   inside a `<div>` block starts nothing; the `div` block runs on to the blank line. The commonest
   trigger is a `<div>` followed by an ordinary one-line comment, or by a digest marker line.
2. **A misread fence still masks a type-6/7 start.** The round-3 fix honours only long-end starts on
   lines the fence map calls fenced. A `<div>` (type 6) or a lone `<span class="a">` (type 7) under
   `` ``` x`y `` is still skipped. That is round-3 (l1) with `div` in place of `pre`.

**Failing inputs** (`H` = `<!-- digest: Hidden rule. -->`, `V` = `<!-- digest: Visible rule. -->`,
`␤` = blank line). Scratch files are in `review4/docs/`:

````text
(b1) <div>                 (b3) <div>          (a1) ``` x`y            (a2) ``` x`y
     <!-- a note -->            <pre>               <div>                   ␤
     z <!-- hidden              </pre>              ```                     <span class="a">
     ␤                          z <!-- hidden       z <!-- hidden           ```
     H                          ␤                   ␤                       z <!-- hidden
     ␤                          H                   H                       ␤
     V                          ␤ V                 ␤ V                     H ␤ V
(b2) as b1, line 2 = V (a digest marker inside the div)
(b4) as b3, lines 2-3 = <pre>x</pre>
(b5) - <div> / "  <!-- note -->" / "  z <!-- hidden" / ␤ / H / ␤ / V
````

| Doc | `e10da18` harvests | `b45cff1` harvests | `8e45e37` tracker (mutation h) | markdown-it / commonmark.js | sketch fix |
|---|---|---|---|---|---|
| b1 div + one-line comment | V | **H, V** | V (new in `b45cff1`) | H inside `<!-- hidden` | V |
| b2 div + marker line | V | **V, H** | V (new) | H inside | V |
| b3 div + pre…/pre | V | **H, V** | H, V | H inside | V |
| b4 div + one-line pre | V | **H, V** | V (new) | H inside | V |
| b5 list-item div + comment | V | **H, V** | V (new) | H inside | V |
| a1 div under misread fence | V | **H, V** | H, V | H inside | V |
| a2 type-7 under misread fence | V | **H, V** | H, V | H inside | V |

In each case markdown-it emits the block verbatim, for example `<div>\n<!-- a note -->\nz <!-- hidden\n<!-- digest: Hidden rule. -->`.
The browser comment that opens at `z <!--` closes at H's `-->`, so the author has commented that rule
out. The parent hides it for the right reason. `b45cff1` puts it in the digest, and
`build-digests -Check` then certifies the wrong digest as fresh. This is the fail-open direction
US1's "Why" warns about, in reverse: the digest carries a rule the source does not show.

**Suggested fix** (sketch, `review4/mutdefs.ps1` entry `fix`). Remember the enclosing blank-ending
block and return to it when the long end closes. Drop the fence condition on the type-6/7 start.
Both changes only keep more lines on the per-line result.

```powershell
if ($longEnd -and ($null -eq $htmlEnd -or $htmlEnd -eq 'blank')) {
    $inHtml = $true
    $resume = if ($htmlEnd -eq 'blank') { 'blank' } else { $null }
    $htmlEnd = if ($body -match $longEnd) { $resume } else { $longEnd }
} elseif ($htmlEnd) {
    $inHtml = $true
    if ($htmlEnd -eq 'blank') { if ($blank) { $htmlEnd = $null } }
    elseif ($raw -match $htmlEnd) { $htmlEnd = $resume; $resume = $null }
} elseif ($body -match '^<[A-Za-z/]') {
```

With the fix, DIGEST-001 gives 55/0 in the scratch kit. All eight F1 documents hide H, all 8 guards stay
hidden, and the kit/adopter corpus is unchanged (0 of 566 files' lines differ from `b45cff1`). Commit
b1, b3 and a1, or a representative subset, as DIGEST-001 `pass-hidden-*` directions, each shown
wrongly harvesting on `b45cff1`.
*Action: implementer fixes in phase 1, under an owner-approved amendment to D11's tracker wording, with
the cases; then re-review. The alternative is for the owner to amend FR-003 to accept wrong disarms in
the digest consumer. The code comment at `markdown-lib.ps1:98-99` already assumes that ("costs at most
a harvested marker"), but FR-003 as approved says the opposite, and the spec prevails.*

### F2 — Load-bearing parts of the digest tracker are still guarded by no case — MINOR

**Where**: `scripts/markdown-lib.ps1:149` (`$container`) and `:160-163` (the comment, PI, CDATA and
declaration ends).

| Mutation (scratch kit, DIGEST-001, 55 tests) | Harness | Load-bearing? (my guard documents, `review4/guards/`) |
|---|---|---|
| none / sketch fix | 0 failed / 0 failed | — |
| container reduced to indentation | **0 failed** | yes: `g-list-div`, `g-ol-div` and `g-bq-div` harvest H |
| container: list alternative removed | **0 failed** | yes: `g-list-div`, `g-ol-div` |
| container: block-quote alternative removed | **0 failed** | yes: `g-bq-div` |
| type-1 end → none | 1 case failed | yes, guarded |
| type-2 (comment) end → none | **0 failed** | yes: `g-comment` (`<!-- a` / ␤ / `z <!-- hidden` / ␤ / H) harvests H |
| PI end → none | **0 failed** | yes: `g-pi` |
| CDATA end → none | **0 failed** | yes: `g-cdata` |
| declaration end → none | **0 failed** | yes: `g-decl` |
| same-line end rule off | failed (fail-closed direction) | guarded |
| same-line closer check off | 0 failed | not observable in a harvest: a marker is its own line |
| forward scan not stopped at blank | failed (fail-closed) | guarded |
| candidate early exit removed | 0 failed | no (cost only) |
| fenced-line skip removed | 0 failed | no (Get-DocMarkers skips fence lines itself) |
| override removed (h) | failed | guarded |

Round 3's F4 asked for the container regex to be guarded. D11 moved the guards to DIGEST-001 but still
did not commit a container case. On the amendment side, the committed no-fail-open AMEND-001 cases can
no longer fail under any mutation, because the reading they guard is the parent's. Only
`fail-wrapped-span-hidden` catches a switch of `Get-VisibleFromText` to the digest rule (mutation (i)
above). The round-3 F2 documents (m1-m3, attribute and title) would also catch it, and they are the
reason D11 exists.
*Action: commit `g-list-div`, `g-bq-div`, `g-comment` and one of `g-pi`/`g-cdata`/`g-decl` as DIGEST-001
`pass-hidden-*` directions, and record the container and end mutations beside (e)-(h). Optionally commit
round-3 m1 or m2 as an AMEND-001 fail direction, so that D11's decision has a second pin.*

### F3 — SC-002 and SC-004 were not amended to D11, and the US2 amendment cites a rule that does not exist — DOC DRIFT (spec)

- **SC-002** still says "**every** visible record after a wrapped span is counted". US2 as amended
  withdraws scenario 1, and `fail-wrapped-span-hidden` pins the opposite. The round-3 amendment
  re-reads FR-001, FR-002/003, FR-005, FR-010 and FR-012, but not SC-002. The spec now contradicts
  itself, which is a rung conflict (constitution II).
- **SC-004**'s guard half ("every guard case fails when the paragraph boundary is removed") has no
  referent. There is no paragraph boundary, and the AMEND-001 guards cannot fail under any mutation of
  a reading that is by design the parent's. It is measured only by the substitute mutations (e)-(h),
  and the spec does not say so.
- The US2 amendment says the remedy is to keep a wrapped span on one line, "as this feature's own notes
  already require". `notes.md` contains no such requirement: its only "on one line" is the round-1 F4
  disposition, which is about something else.

*Action: owner-approved amendment: SC-002 reads "zero records inside a real comment are counted; a
record after a wrapped span stays hidden (the pinned limitation)". SC-004's guard half names mutations
(e)-(h) and the digest guards. Drop or correct the "notes already require" clause, or add the authoring
rule where it belongs.*

### F4 — Comments and notes overclaim — DOC DRIFT

- `markdown-lib.ps1:111-113`: "honoured even inside a block that ends at a blank line, and even on a
  line the fence map calls fenced, so a tag line or a misread fence cannot mask it". This is false by
  F1: a misread fence still masks a type-6/7 start (a1, a2), and the override itself unmasks the
  enclosing block (b1-b5).
- `notes.md:341-351`, the draft gap row: "hides every approver record after it". It hides records up
  to the next armed `-->`, or to the end of the document only when there is none (the non-greedy strip
  and then the unterminated rule, `enforcement-pack.ps1:896-899`). Otherwise the row is accurate: fail
  closed, kept on purpose, pinned by `fail-wrapped-span-hidden`, and a parser is likely needed.
- `notes.md:296-297`, "whose body is identical to the parent's … bar its name": the parameter was
  renamed too (`-Line` → `-Text`). This is harmless, since there are no other callers, but it should
  be said.
- `rules.json` DIGEST-001 notes and `notes.md` T014l say "every guard fails under the mutation it was
  written for". That is true, but it does not show the tracker is guarded (F2).

*Action: reword these with F1's fix, as a rule with named exclusions.*

### F5 — The D5 tail still loses a marker the parent kept — CONFIRM (owner-accepted, phase 2)

**Where**: `scripts/build-digests.ps1:110` (`$scan = $scan.Substring($close + 3)`).

Round-3 F6's document (`review3/ddocs/d1-tail-sameline.md`) harvests **1 marker on `e10da18` and 0 on
`b45cff1`**, and a renderer shows that marker. The cause is D5 itself, not D10. The parent paired
backticks on the tail after the close. `b45cff1` pairs them on the whole line and then takes the
substring, so a backtick before the close shifts the pairing. This is the only loss against the parent
I found. None of my other documents loses a marker against the parent, and the rule only disarms more, so `$inComment` is set no
more often than in the parent (D1 fuzz: disarms are a superset of per-line). The loss is silent until
phase 2's DIGEST-020 lands.
*Action: none in phase 1 (owner decision of 2026-09-30). Add this document as a DIGEST-020 direction
(T016). A cheap later fix is to re-pair the tail with `Convert-SpanText` and then apply the
whole-document disarms that fall inside it.*

### F6 — FR-010 as amended is met only loosely — MINOR

`markdown-lib.ps1:121-145`: any document with a `<!--` anywhere pays for the pre-pass. That means a
join of the whole document, an `IndexOf` per opener, and a forward scan to the next blank line for
every unclosed opener. FR-010 now reads "a document with no opener that the rule could disarm takes no
additional work". The pre-pass is exactly the work that decides whether there is such an opener, so
the sentence cannot be literally true. No child process is added. SC-006 (timing) is for ship.
*Action: owner may reword FR-010 to "returns before the block tracker runs"; no code change.*

### Speculation (not verified as harmful)

- **Type-4 end read on the raw line.** A declaration block (`<!DOCTYPE …`) inside a block quote ends
  at the container's own `>` (`:173` matches `$raw`, not `$body`). The document `c1` (`> <!DOCTYPE x` /
  `> a` / `> z <!-- hidden` / ␤ / H) harvests H on `b45cff1`, and the renderers' HTML puts H inside a
  comment. But a browser consumes a DOCTYPE token up to the next `>`, which swallows the `<!--`, so I
  cannot call it a real comment. Matching the ends on `$body` would close it, and only in the
  conservative direction.
- **A `<script>` or `<textarea>` inside a `div` line** (`<div><script>`) hides later text as script
  content, not as a comment. It is the unmodelled non-comment class the comment already names.

### Earlier findings — status

- **Round 1 F1** (paragraph pairing counts a hidden record): **moot for the amendment check** (parent
  reading, parity shown). **Fixed for the digest**: paragraph pairing is gone.
- **Round 1 F2** (marker loss): both documents **fixed** (`r1f2-doc1`, `r1f2-doc2`: 1 marker on both
  versions). The mechanism is **open** as F5.
- **Round 1 F3** (overclaims): **fixed**; newer overclaims are in F4.
- **Round 1 F4** (pre-016 fail-opens): **unchanged and not regressed** in the amendment check (parity).
  Still drafted beside T026.
- **Round 2 F1** (per-line doubt, shapes a-i): **moot** for the amendment check (parity over
  `review2/docs*`, 0 differ). D9 is gone.
- **Round 2 F2** (D5 tail): its document is **fixed**, the mechanism is **open** (F5), owner-accepted.
- **Round 2 F3** (overclaims): **superseded** (F4).
- **Round 2 F4** (unguarded `$doubtful`): **moot**. The class recurs as F2.
- **Round 3 F1** (tracker misses, `\s` blank): **moot for the amendment check** (j1-j3, k1-k4 and l1:
  parity, 0 differ). In the digest, the three committed shapes are **fixed**
  (`pass-hidden-nbsp-line`, `-pre-under-tag-line`, `-pre-in-misread-fence` pass, and blank is
  `[ \t]`). The class is **partially open**: F1 finds sibling shapes, four of them introduced by the
  fix.
- **Round 3 F2** (attribute, title, alt): **moot for the amendment check** (m1-m3 parity). In the
  digest it is **accepted** as not modelled, and the comment says so.
- **Round 3 F3** (FR-010): **amended**, and met loosely (F6).
- **Round 3 F4** (unguarded tracker): **partially fixed**. The type-1 end and the override are now
  guarded. The container regex and the other four ends are not (F2).
- **Round 3 F5** (overclaims): **mostly fixed**. One new overclaim remains (F4).
- **Round 3 F6** (D5 tail): **open**, owner-accepted (F5).

## Amendments in this diff

- [x] Amendments listed. `6e7e902` (a `docs:` commit before `b45cff1`) amends spec US2 (scenario 1
  withdrawn), adds the FR block that re-reads FR-001, FR-002/003, FR-005, FR-010 and FR-012 for D11,
  and adds plan D11 and tasks T014i-T014l. Each carries `**Amendment approved by**: anas.m,
  2026-09-30`, and the commit names the approver. It does not amend SC-002 or SC-004 (F3). `b45cff1`
  changes `tasks.md` by checkbox ticks only. `contracts/` is unchanged. F1's fix needs a further
  owner-approved amendment to D11's tracker bullet, and F3 needs one to the success criteria.

## Constitution re-check (post-implementation)

**PASS on VI (Security).** The amendment-authority gate reads exactly as the parent does (code, corpus
and fuzz parity). **FAIL against the spec on FR-003** for the digest consumer (F1), a tooling
correctness defect rather than a security one. I: the amendment is approved and lands before the
commit that relies on it. II: SC-002 contradicts US2 as amended (F3). IV: no new dependency or
architecture. VIII: pass and fail cases, test-first, and (e)-(h) recorded and reproduced, but part of
the tracker is unguarded (F2). IX: this review. X: one phase, Territory held, and `scope-check` is OK.

**Against the amended spec**:

| Item | Status |
|---|---|
| US1 scenarios 1-2 | Met (`pass-wrapped-span`, `fail-wrapped-span`) |
| US1 scenario 3 | Phase 2 |
| US2 scenarios 2-3 | Met by parity |
| US2 scenario 1 | Withdrawn, pinned by `fail-wrapped-span-hidden` |
| US3 | Phase 2 |
| FR-001 | Met: one library, per-line pairing shared, no copy |
| FR-002 | Met as a rule |
| FR-003 | **Unmet** (F1) |
| FR-004 | Met on the targeted runs; the full suite is 843/0 per `notes.md` |
| FR-005 (as amended), FR-006, FR-007 | Met |
| FR-008 | Met (`rules.json` counts 22 AMEND-001 directions, and I counted 22) |
| FR-009 | Phase 2 |
| FR-010 | Loosely met (F6) |
| FR-011, FR-012 | Ship. FR-012 should say GAP-028 is closed for the digest consumer *except* a span holding `-->` (FR-002's last sentence). The kit's only real instance is that shape |
| SC-001 | First half met; the F2 shape is phase 2 |
| SC-002 | Contradicted (F3) |
| SC-003 | Windows only, by me |
| SC-004 | Measured by the substitutes only (F3) |
| SC-005 | Kit digests are fresh; adopters at ship |
| SC-006 | Ship |
| SC-007 | Phase 2 |

## Test coverage observed

- The five new DIGEST-001 guards do guard what they claim. Mutation (g) turns `pass-hidden-nbsp-line`
  red, (h) the two `pre` guards, (f) `html-block-open`, and (e) `after-backslash-spans`. I confirmed
  the recipes, including the literal U+00A0 in `pass-hidden-nbsp-line`.
- `fail-wrapped-span-hidden` is the same document as the old pass case and expects FAIL. It is the
  only AMEND-001 case sensitive to a change of reading (mutation (i)).
- Missing: cases for F1's shapes (a1, b1, b3), the container regex, and the comment, PI, CDATA and
  declaration ends (F2).

## Residual risk

The security gate is where D11 put the risk, and it holds: the amendment check is the parent's, so it
fails closed on GAP-028 by design. The remaining risk is F1 in the digest generator. It is a latent
fail-open that puts commented-out rules into a digest, reachable with ordinary raw HTML (a `<div>`
followed by a comment line). It breaks an approved requirement, and a four-line conservative change
closes it. F2 and F4 travel with that fix, F3 needs an owner amendment, and F5 is phase 2's. Every
experiment ran in `scratchpad/review4/`. `git status --short scripts/` is clean, and the repository
shows no change beyond this review file and the pre-existing untracked `.claude/settings.local.json`.
