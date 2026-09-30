# AI Code Review — 016 Multi-line Code Spans (Phase 1)

**Reviewer**: fresh-context agent — claude-opus-5-5
**Date**: 2026-09-30
**Branches**: agentic-sdlc-kit `016-multiline-code-spans` (tip `7a770e53b765b5728cc3ea752165285675f396e1`)
**Scope reviewed**: commit `7a770e5` in full (24 files: `scripts/markdown-lib.ps1`,
`scripts/enforcement-pack.ps1`, `scripts/build-digests.ps1`, `tests/enforcement/rules.json`,
the 18 fixture files of the six new directions under
`tests/enforcement/cases/build-digests/DIGEST-001/` and
`tests/enforcement/cases/enforcement-pack/AMEND-001/`, `specs/016-multiline-code-spans/notes.md`,
`specs/016-multiline-code-spans/tasks.md`). Also the amendment commit `85c8650` in full. Read for
context: `spec.md`, `plan.md` (D1-D8), `research.md` (R1-R5), `tasks.md`, `notes.md`;
`CLAUDE.md`; `.specify/memory/constitution.md`; `docs/sdlc/definition-of-done.md`;
`docs/sdlc/review-process.md`; `tests/enforcement/lib/Harness.psm1` (to drive cases from outside
the repository); `specs/015-enforcement-assurance/ai-code-review-phase-2.md` (house style).
**Feature contract**: phase 1 = T001-T014. One shared code-span function, whole-document
signature, same line count and line lengths out as in (D1); paragraph pairing over joined lines
(D2); generous block starts (D3); HTML comment blocks per-line (D4); build-digests precomputes
and indexes (D5); six fixture directions (D6); two recorded mutations (D7). No new dependency, no
new script. Territory: the three scripts and `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: claude-opus-5-5 (the implementing session)
- **Inputs provided**: commit `7a770e5` (`git show --stat` and full diff); commit `85c8650` in
  full; `spec.md`, `plan.md`, `research.md`, `tasks.md`, `notes.md` for
  `specs/016-multiline-code-spans/`; the kit's law (`CLAUDE.md`,
  `.specify/memory/constitution.md`, `docs/sdlc/definition-of-done.md`,
  `docs/sdlc/review-process.md`); the review template and a 015 review for style; read and run
  access to the working tree. Every experiment ran from a scratch directory outside the repository
  (scratch copies of the parent `e10da18` scripts and of a mutated kit), so no repository file was
  modified.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES.** The fix does what its six cases say. I reproduced every recorded result
independently: the three green-turning cases fail on the parent scripts and pass on the fix, and
all three guards fail under mutation (b) (whole-document pairing), which I rebuilt in a scratch
kit copy rather than trust `notes.md`. D1's invariants hold under a 3,000-document fuzz (line
count, line length, and only marker characters change). Territory is clean, and `ritual-checks`
is green. The answer to the brief's fail-open question, though, is **yes**. Pairing across the
lines of a paragraph lets a record inside a real HTML comment count as visible to the amendment
check, in shapes the parent refused. I built three such documents, confirmed with two CommonMark
renderers (markdown-it 14, commonmark.js) that the record renders as nothing, and ran each one
end to end through `Invoke-FixtureCase` as an AMEND-001 commit. `7a770e5` says
`enforcement-pack: OK`, exit 0, and `e10da18` says FAIL, exit 1 (F1). That is 014's H1 again,
through a door the guards don't watch: they catch a span that reaches across a paragraph
boundary, but none catches a misread of the backtick runs within one paragraph. The exposure is
latent. Across all 563 Markdown files in the kit and the three adopted projects, the new function
differs from the old on exactly two lines, the known R2 hit. It still belongs in phase 1, since
phase 1 is the phase that opens the hole. F2 (the pairing can also arm a marker the old reading
disarmed) and F3 (comments that overstate the model) are smaller.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-001: one implementation. `Convert-CodeSpanMarkers -Lines` is the only span entry point, and both callers moved (`enforcement-pack.ps1:887`, `build-digests.ps1:92`); the old `-Line` form is gone. FR-002, FR-003, FR-004: read against D2-D4 and exercised by the six cases plus my own documents. FR-005, FR-006, FR-007 (phase-1 part): the cases exist, and I reproduced their parent and fix results (below). FR-010: no process is added, and the early returns stay at document and paragraph level. FR-012: deferred to ship, as `notes.md` says, but see F3 |
| Visual-reference match | N/A. No UI |
| Feature contract held | No new dependency or script. The CommonMark renderers I used were installed in a scratch directory as measuring tools, as R1 did |
| Constitution / domain invariants | Constitution I: `85c8650` carries `**Amendment approved by**: anas.m, 2026-09-30` in both amended sections and lands before the phase commit. The phase commit's `tasks.md` change is checkbox-only (every changed line is a `- [x] T0nn` tick, checked by filtering the diff). No domain-invariants pack |
| Security | This phase changes the gate that refuses invisible approvals. F1 is a fail-open in it |
| Scope guard | `pwsh -File scripts/ritual-checks.ps1`: `scope-check: PASS phase 1 commit 7a770e5 (24 file(s))`, `RESULT OK`, exit 0. The `--stat` touches only the phase-1 Territory plus the feature's own `notes.md` and `tasks.md` |
| Rollback safety | The commit is self-contained. Reverting it restores the parent function and both callers together, and no data or schema is involved |
| D1 (count and length) | A scratch fuzz of 3,000 random documents built from backtick runs, escapes, markers, block starts, fences, tabs and indentation gave **0 violations** of line count, line length, or "only marker characters change" |
| D5 (precompute and index, substring after a mid-line close) | `build-digests.ps1:95` indexes `$scanLines[$lineNo - 1]`, and `:110` takes `$scan.Substring($close + 3)` with `$close` computed on the raw line. Because length is preserved, the offsets line up. The semantics changed, though: the tail is now paired as part of its whole paragraph, not alone (F2, second shape) |
| Six cases, fix vs parent vs mutation (b) | Driven with `Invoke-FixtureCase` against three kit roots: HEAD, a scratch copy of the `e10da18` scripts, and a scratch copy of HEAD with `Convert-CodeSpanMarkers` returning `Convert-SpanText` over the whole joined document. HEAD: 6/6 pass. Parent: the three wrapped-span cases fail and the three guards pass. (b): the three guards fail, `fail-hidden-after-unpaired` with exit 0, which is the fail-open it guards. This matches `notes.md` T006 and T013 exactly |
| Harness, targeted | `Run-Tests.ps1 -Case wrapped-span` 39/0, `-Case comment-block-backticks` 37/0, `-Case hidden-after-unpaired` 35/0, each exit 0. I did not re-run the full suite; `notes.md` records the owner's 817/0 run |
| Exposure | A scratch comparison of the old per-line and new whole-document functions over 563 `.md` files (kit, fitforge, flowboard, expense-tracker): **2** lines differ, both in `specs/014-amendment-authority/ai-code-review-phase-3.md` (367-368, the R2 hit), and both disarm more. **0** lines arm more |

## Findings

### F1 — Paragraph pairing lets a record inside a real comment count as a grant (014 H1 reopened) — BLOCKING

**Where**: `scripts/markdown-lib.ps1:60` (the run finder that paragraph pairing now feeds),
`:114-118` (the join over the paragraph), and `:153-159` (raw HTML "runs to the next blank line").
The consumer is `Get-VisibleFromText`, `scripts/enforcement-pack.ps1:887`.

**What**: `Convert-SpanText` treats every unescaped backtick run as a span delimiter, and treats
any backtick preceded by a backslash as escaped. CommonMark disagrees in three places, and so does
the kit's paragraph model:

1. A backtick inside an autolink (`<https://…>`), a raw HTML tag's attribute value, or a link
   destination is not a delimiter. That construct binds first, because it starts further left.
2. Backslash escapes do not work inside a code span, so the closing run of a span ending in a
   backslash is a real closer. Windows paths quoted in backticks, common in this kit, have exactly
   this shape. A backtick after an escaped backslash is also a real delimiter.
3. Type-1 raw HTML blocks (`<pre>`, `<script>`, `<style>`, `<textarea>`) end at their closing tag,
   not at a blank line. Their content is raw HTML, so a comment inside one is hidden by the browser.

On the parent these misreads could only disarm a real comment's opener when the second backtick
sat on the same line as the opener. Paragraph pairing lets the pair reach any later line of the
paragraph. An inline HTML comment that opens mid-line and spans several lines, with the record on
its own line inside it, now has its opener and closer disarmed, so the record counts. Note that
this is not the "not modelled" shape the comments name, a mid-line opener left unterminated.
These comments are terminated, and both the kit's comment model and the renderer agree they are
comments. The span model is what misreads them.

**Failing inputs**. Each is the amended `plan.md` of an AMEND-001 commit, built from
`fail-hidden-after-unpaired`'s recipe with only this paragraph swapped in. Each expects FAIL,
because the record renders as nothing in both markdown-it and commonmark.js. Results come from
`Invoke-FixtureCase`:

````text
Paths end in a separator, as in `scripts\` and <!-- ada has not signed this yet
**Amendment approved by**: ada, 2026-01-02
--> the rest, see `tests\` too.
````

````text
See <https://example.com/a`b> for detail <!-- ada has not signed this yet
**Amendment approved by**: ada, 2026-01-02
--> and a stray ` here.
````

````text
<pre>

Step a ` b <!-- ada has not signed this yet
**Amendment approved by**: ada, 2026-01-02
--> done `
</pre>
````

| Document | `e10da18` (parent) | `7a770e5` (fix) |
|---|---|---|
| backslash closer (two well-formed spans, no stray backtick) | FAIL, exit 1 (correct) | **OK, exit 0** (fail-open) |
| autolink holding a backtick | FAIL, exit 1 | **OK, exit 0** |
| `<pre>` block across a blank line | FAIL, exit 1 | **OK, exit 0** |

`Get-VisibleFromText` alone shows the same flip for a raw-HTML attribute (`<span title="`">`), a
link destination (`[x](a`b)`), a `\\` before the opening backtick, and the `<pre>` document with
CRLF line endings. All four hide the record on the parent and show it on the fix.

**Why the guards miss it**: `fail-hidden-after-unpaired` and both `pass-comment-block-backticks`
cases are sensitive to D7(b), a span crossing a paragraph or comment-block boundary. Every
counterexample above stays inside a single paragraph as the kit models it, so D7(b) is the wrong
mutation to prove them against.

**Suggested fix** (the smallest one that stays fail-closed relative to the parent, in the spirit
of D3's "when in doubt, break the paragraph"):
(a) Let type-1 HTML blocks run to their closing tag (case-insensitive `</pre>`, `</script>`,
`</style>`, `</textarea>`), or to the end of the document, with per-line treatment throughout.
(b) Fall a paragraph back to per-line pairing when any of its lines holds a backslash next to a
backtick, or a `<` that opens a tag or autolink before a backtick on the same line. The more
faithful alternative is a CommonMark run scanner that honours those constructs and applies
escapes only outside spans. That is a bigger change, and a heuristic that skips a real delimiter
shifts the pairing and can fail open in its own way, so it would need its own guards.
Either way, add the three documents above as AMEND-001 fail directions (for example
`fail-hidden-backslash-closer`, `fail-hidden-autolink-backtick`, `fail-hidden-pre-block`). Show
each one failing on `7a770e5` and passing after the fix, and add a mutation that removes the new
fallback.
*Action: implementer fixes in phase 1 (a re-roll or a follow-up phase-1 commit), with the cases;
re-review.*

### F2 — The paragraph reading can ARM a marker the per-line reading disarmed, so a harvested marker is lost in a new way — CONFIRM

**Where**: `scripts/markdown-lib.ps1:114-118` (the pairing shifts across lines) and
`scripts/build-digests.ps1:110` (the tail after a mid-line close is now paired in paragraph
context).

**What**: The change does not only disarm more. A backtick left unpaired on one line can pair
with the first backtick of the next line, which strands a `<!--` that per-line reading had inside
a span. I built both documents below as DIGEST-001 cases (from `pass-wrapped-span`'s recipe, with
the correct digest on disk and both markers expected):

````text
A paragraph with a stray backtick ` here, and then
the syntax `<!--` quoted on its next line.

<!-- digest: A rule marked after the wrapped span, which GAP-028 made invisible. -->
````

````text
Prose that opens a note <!-- mid-line and
closes it a ` b --> then quotes `<!--` in a span.

<!-- digest: A rule marked after the wrapped span, which GAP-028 made invisible. -->
````

Both give `digests: OK (1 digest(s) fresh, 2 marker(s))` on the parent and
`stale or hand-edited digest`, exit 1, on the fix, so the second marker is no longer harvested. A
digest *regenerated* on the fix drops that rule and reports OK, which is silent until phase 2's
DIGEST-020 lands. In the amendment check the same shape hides a later record, which is fail-closed
(014 B7's shape). The renderer's view differs between the two. In the first, markdown-it pairs as
the fix does, and the stranded `<!--` is plain text: F2's shape, the comment model's loss, which
phase 2 is scoped to make loud. In the second, markdown-it reads `<!-- mid-line … -->` as an
inline comment and the later `` `<!--` `` as code, which agrees with the parent. The tail pairing
D5 prescribed is simply less correct there.

**Exposure**: zero today. No line in the 563 files scanned arms more under the fix.

*Action: owner decides. Either accept it as covered by phase 2 (DIGEST-020 turns the silent loss
into a named failure) and record that in `notes.md`, or ask for the D5 tail to be re-paired on its
own as the parent did. Either way, one of the two documents above is worth a DIGEST-020 direction
in phase 2.*

### F3 — Comments state behaviour this commit does not have — DOC DRIFT

- `scripts/markdown-lib.ps1:21-22` and `:99-101` say build-digests "reports a marker it passes
  over inside" such a comment (016 D8). At `7a770e5` it does not: `skipped digest marker` appears
  nowhere in `scripts/build-digests.ps1`. That is phase 2's behaviour, and the plan calls phase 2
  independently revertible, so this sentence would be false after such a revert.
- `scripts/markdown-lib.ps1:88-89`: "a stray backtick cannot pair into a later block and disarm a
  real comment there". F1 shows this is not true of what a reader sees.
- `scripts/markdown-lib.ps1:153`: "Raw HTML runs to the next blank line, and spans do not apply
  inside it." Type-1 blocks do not end at a blank line, and the code does apply spans inside HTML
  blocks, per line (`:157`). The header at `:96-97` says "keep per-line pairing", which is
  accurate.

`notes.md` T010 says each corrected comment states what is and is not modelled. That is true for
the mid-line opener, but these three sentences overstate the model.
*Action: implementer rewords them with the F1 fix: the D8 sentence goes to future tense or waits
for phase 2, and `:88-89` and `:153` match what is modelled after F1.*

### F4 — Fail-open shapes that predate this feature, found while answering the brief — MINOR

These fail open on **both** `e10da18` and `7a770e5` (record hidden in both renderers, counted by
`Get-VisibleFromText`), so this diff did not introduce them. They answer the brief's question, and
the owner should know they exist:

- A backtick fence line whose info string holds a backtick, for example ```` ``` inline `x` then ````.
  It is not a fence in CommonMark, but `Get-FencedLineMap`
  treats it as an unclosed fence, so every later marker is disarmed, including a real comment
  block holding a record.
- F1's autolink and escaped-backslash shapes with the second backtick on the comment's opening
  line: per-line pairing was already fooled.
- A `<div>` HTML block whose line holds a backtick pair around a mid-line `<!--`. Spans do not
  apply in raw HTML, but per-line pairing disarms it anyway.

*Action: none in this phase (out of scope: the comment model and the fence model). I recommend the
owner records them beside T026's planned gap, since they are the same fail-open class the H1 line
of work exists to close.*

## Amendments in this diff

- [x] Amendments listed. `85c8650` (a `docs:` commit before the phase commit) amends plan D6 and
  tasks T002 and T005. Each amended section carries `**Amendment approved by**: anas.m,
  2026-09-30`, the commit message names the approver, and the reasoning is in `notes.md`
  ("The guards as planned could not see an over-reaching fix"). I checked that reasoning: both
  original shapes would pass under D7(b), and both replacements fail under it (reproduced). The
  phase commit `7a770e5` changes `tasks.md` by checkbox ticks only (exempt, D3c). No change to
  `spec.md` or `contracts/`.

## Constitution re-check (post-implementation)

**FAIL on VI (Security), until F1 is fixed.** The amendment-authority gate can be satisfied by an
invisible record in shapes it refused before this commit. Otherwise PASS. I (specification first)
and the amendment authority rule are satisfied, the amendment landing approved and before the
phase that relies on it. II: no conflict between rungs. III: N/A. IV: no new dependency or
architecture, and one function changed signature with both callers moved in one commit. V: N/A.
VII: N/A. VIII: pass and fail cases, test-first, both mutations recorded, and I reproduced them.
The cases are sound for the over-reach they target but do not cover F1. IX: this review. X: one
phase, Territory held, scope-check PASS, `ci-held` declared in the plan.

## Test coverage observed

- DIGEST-001 `pass-wrapped-span` and `fail-wrapped-span`: the green-turning pair for the digest
  consumer. Hand-written expectations, the correct digest called OK and a stale one called stale.
  On the parent, `fail-wrapped-span` exits 0, which is the fail-open direction.
- AMEND-001 `pass-wrapped-span`: the green-turning case for the amendment consumer (014 B7's
  shape).
- Guards: DIGEST-001 `pass-comment-block-backticks`, AMEND-001 `pass-comment-block-backticks`, and
  AMEND-001 `fail-hidden-after-unpaired`. Each fails under whole-document pairing (reproduced), and
  the descriptions in their `recipe.json` explain the mechanism accurately.
- `rules.json` notes for DIGEST-001 and AMEND-001 count and name the new directions (AMEND-001's
  "Fifteen directions" is 12 + 3).
- Missing, per F1: any case where the over-reach happens *inside* one paragraph.

## Residual risk

The risk sits in F1: a fail-open in the check that stops an agent approving its own amendment,
reachable with ordinary-looking prose (a Windows path in backticks), and latent today in 563
files. Fix it before merge, with fail-direction cases and a mutation that removes the fallback,
then re-review. F2 is contained by phase 2's report if the owner accepts it. F3 is wording. F4
predates this feature and needs an owner decision on a new gap, not work in this phase. Every
experiment in this review ran in scratch copies. `git status --short` shows no change to the
repository beyond this review file and the pre-existing untracked `.claude/settings.local.json`.
