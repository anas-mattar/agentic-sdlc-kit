# AI Code Review — 020 Rendered-structure Lint, phase 3 (guidance, flow-down, bookkeeping)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-11
**Branches**: kit repository `020-rendered-structure-lint` (phase commits `427a538`, parent `67dc753`, and `7fbf8a7`)
**Scope reviewed**: `git show 427a538` and `git show 7fbf8a7` in full: the new flow-down note in `adoption/updating.md`, the new bullet
and marker in `docs/sdlc/review-process.md`, the GAP-015 row and the new decisions-log entry in `docs/roadmap.md`, the two digest
diffs, `tasks.md` (checkbox diff), `notes.md` ("Phase 3"); against `spec.md` (US4, FR-007, FR-009, FR-010, FR-011, SC-001, SC-003,
SC-004), `plan.md` (D7, D8), `tasks.md` Phase 3 (T013-T017) and the phase 1 and 2 reviews (accepted limits not re-reported).
**Feature contract**: documents and digests only; no script, package or manifest change; a structure finding fails an adopted
project too (FR-011); Territory `docs/sdlc/review-process.md`, `adoption/updating.md`, `docs/roadmap.md`, `docs/digests/**`,
`kit-manifest.json`, the spec directory.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-sonnet-5-5 (separate session that produced the phase 3 commits)
- **Inputs provided**: phase 3 diffs (`427a538`, `7fbf8a7`), spec.md, plan.md, tasks.md, notes.md, phase 1 and 2 reviews, the scripts at the branch tip
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The phase delivers what US4 and FR-010 ask for: a flow-down note that says what the check reads, what
it newly fails, the fix per finding, that it fails adopted projects, and a measurement that honestly says "no real adopter document
was flagged". Every finding name, fix and rule statement I tried against the scanner behaves as written, the kit's own documents
pass the new rules (doc-lint OK, zero structure findings in all three edited files), the digests are fresh, scope-check passes and
the territory is held. Two small defects: the roadmap lost its trailing newline (the 018 F8 precedent), and the note says
`markdown-lib.ps1` and `doc-lint.ps1` "must arrive together" without saying what a half-applied update does, which is a hard
crash, and markdown-lib is not new to adopters (it predates this feature, without the new function). Neither is blocking.
Certification is the owner's; nothing here claims the gate passed.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (US4, FR-010, FR-011) | The note has the five parts FR-010 names (reads / fails / what to do / measured result / flagged documents = none, with "Not exercised, and said so"). FR-011: the note says the check "is **not a Markdown renderer**", names the four rules, and states "A finding **fails the run in an adopted project too**... no information-only release". |
| Finding names and fixes | Ran throwaway documents through `Get-StructureFindings` (dot-sourced): comment inside a table -> `severed-row`; blank inside a table -> `severed-row`; digest marker after a blank line following the table -> none; delimiter row under a non-header -> `severed-delimiter`; 3-cell row under a 2-cell header -> `ragged-row`; 3-cell delimiter under a 2-cell header -> `ragged-row` (line 2); `` `x|y` `` in a cell -> `ragged-row`; `` `x\|y` `` -> none; list, column-zero comment, list -> `severed-list`; comment after the list -> none; comment indented into the item -> none; blank line between items -> none. Every "fix" column entry clears its finding and every claim about pipes and blank lines holds. "A comment that is never closed hides the rest of its document" is also true (unclosed comment above a ragged table -> no finding; phase 1 N1 limit, stated correctly). |
| GitHub cell counts of the note's own table | Four rows, three cells each. Row 3's last cell holds `` `\|` `` inside a code span; cmark-gfm's table scanner strips the backslash from `\|` before inline parsing, including in code spans, so it is one literal pipe and the cell count stays 3. The lib agrees (0 findings on `adoption/updating.md`). The finding names in the first column are code spans without pipes. The delimiter row is a plain `\|---\|---\|---\|`. |
| Scanned-document list | The note's list (`CLAUDE.md`, `AGENTS.md`, `README.md`, constitution, `docs/`, `adoption/`, `modules/`, `specs/_templates/`) equals `$docFiles` in `scripts/doc-lint.ps1` lines 165-172. The "doc-lint: OK line is unchanged": the final line still reads `doc-lint: OK - kit complete, every referenced path resolves` and the structure findings are an added `ERROR:` block (lines 263-266). |
| "The kit had one such table of its own... until feature 020 repaired it" | Consistent with notes.md phase 1 and with the phase 1 review; the roadmap table now renders as one table (`Get-StructureFindings` over `docs/roadmap.md`: 0 findings). |
| Verbatim file list / manifest | `kit-manifest.json` classifies `scripts/*.ps1` as verbatim (line 40) and `update-kit.ps1` enumerates `scripts/*.ps1` (lines 143-145); `docs/` and `adoption/` are shipped surfaces. `git diff 67dc753 7fbf8a7 -- kit-manifest.json` is empty and nothing needs to change there. See F2 for the half-applied case. |
| Digest claims | `git diff c292d62 427a538 -- docs/digests`: review digest +1 line, adoption digest +2 lines, no other digest touched (no CRLF churn). `pwsh -NoProfile -File scripts/build-digests.ps1 -Check`: `digests: OK (5 digest(s) fresh, 91 marker(s))`. Marker lengths: the content after `<!-- digest: ` is 114, 111 and 103 characters, exactly as notes/note say; the whole comment lines are 131, 128 and 120. The cap in `build-digests.ps1` is 120 of marker content (line 41), so all three are inside it. The note's "114 and 111 characters" is correct only in that sense (F3). |
| review-process.md bullet | Placed in the AI review "Check:" list, the right place for a reviewer; the list is intact (the new item continues the bullet list with indented wrap lines, then a blank line, then the marker after the block, as the bullet preaches); scanner: 0 findings. Content is accurate (the four rules, "not a markdown renderer", naming file and line). |
| Roadmap | Row GAP-015 reads `shipped` with `` `specs/020-rendered-structure-lint/` `` unbracketed and the directory exists. The entry follows a blank line (doc-lint list rule satisfied), uses the precedent wording ("built, reviewed and measured: the human review at merge is still to come") and lists accepted limits correctly against the reviews (phase 1 N1 unclosed/empty comment, N2 double backslash; phase 2 F1 different-type lists, F2a indented comment; "phase 1 repair of the inventory table" matches notes.md). Not listed there: phase 1 N3-N5 and phase 2 F2b (see F4). `roadmap-claims: OK`. File ends without a newline (F1). |
| Territory, scope | `pwsh -NoProfile -File scripts/scope-check.ps1 -Commit 427a538`: PASS (7 files); default (`7fbf8a7`): PASS (2 files). Every touched path is within Territory or the implicit spec directory. |
| tasks.md | `git show` diffs: T013-T016 `[ ]` -> `[x]` in `427a538`, T017 in `7fbf8a7`; nothing else changed. No amendments. |
| Ritual | `pwsh -NoProfile -File scripts/ritual-checks.ps1`: doc-lint OK, enforcement-pack OK, scope-check OK, scope-repos n/a, digests OK, roadmap-claims OK, verify-kit n/a, `RESULT OK`. `pwsh -NoProfile -File scripts/doc-lint.ps1`: OK, 37 docs, no structure findings. |
| Tests re-run by me | `tests/enforcement/Run-Tests.ps1 -Case DOC-`: 135 passed, 0 failed. I did NOT re-run the full harness (1211, T017 in an isolated checkout) nor the T015 clone measurement (38/42/54 documents, RESULT OK x3 per project); both rest on the implementer's record. The scanned counts equal the phase 2 prototype's, a consistency, not an independent confirmation. |

## Findings

### F1 — `docs/roadmap.md` lost its trailing newline — MINOR

`git show 427a538:docs/roadmap.md | tail -c 5 | od -c` ends `. ` with no `\n`; at `67dc753` the file ended `\n`. The diff prints
`\ No newline at end of file`. This is the 018 phase 4 F8 precedent. No check fails (doc-lint, roadmap-claims and digests are green), but the
next appended entry will touch this line and the file now differs from every other document in the repository.
*Action: implementer appends a newline in a docs-only follow-up commit (roadmap is in Territory).*

### F2 — The note says the two scripts "must arrive together" but not what happens when they do not — MINOR

`markdown-lib.ps1` is not new to adopters: at `c292d62` it exists (feature 015, used by `enforcement-pack.ps1`) but has no
`Get-StructureFindings` (`git show c292d62:scripts/markdown-lib.ps1 | grep -c Get-StructureFindings` is 0), and the old `doc-lint.ps1` did not
dot-source it (count 0). Therefore: old doc-lint plus new lib is harmless; new doc-lint plus old lib fails hard
(`Get-StructureFindings` is not recognized under `$ErrorActionPreference = 'Stop'`) — not a quiet pass, which is the safe direction, but
a half-applied or cherry-picked update (e.g. an interrupted `update-kit.ps1` run, which copies alphabetically, `doc-lint.ps1` before
`markdown-lib.ps1`) leaves doc-lint, and so `ritual-checks`, red until the update is finished. The parenthesis reads as if
`markdown-lib.ps1` were a new file.
*Action: implementer adds one sentence to the note: "markdown-lib.ps1 already exists in your project without the new function; a project with the new doc-lint and the old lib fails doc-lint with an unrecognized-function error — re-run update-kit." Within `adoption/updating.md`, no behaviour change.*

### F3 — "digest markers of 114 and 111 characters" counts the content, not the comment — MINOR

notes.md T014 says "Two digest markers of 114 and 111 characters"; the note's lines are 131 and 128 characters. It is true under the
tool's definition (120 characters of marker content) and that is what the check enforces, but a reader counting the line gets another
number. The same phrasing covers the 103-character bullet marker (line 120).
*Action: none required; optionally say "of content" in notes.md.*

### F4 — The accepted-limits list in the roadmap entry is a selection — MINOR

The entry says the phase 1 and 2 reviews' accepted limits "stand" and lists four. Not listed: phase 1 N3 (near-delimiters with a backslash are
accepted), N4 (adjacent tables merge, as on GitHub), N5 (`Some text` followed by a bare `| - | - |` row is a `severed-delimiter`: header-less
pipe prose is a possible adopter false positive) and phase 2 F2b (tab-indented or lazy continuation resets the list state). N5 is the only
one that can fail an adopter's run on a legitimate document; the flow-down note's "most likely cause is a `digest:` marker or a blank
line inside a table" does not mention it. The wording "stand" covers the rest honestly; nothing listed is misstated.
*Action: optional: add N5 to the flow-down note's "what to do" (a header-less pipe line is reported as `severed-delimiter`; add a header row or drop the dash row).*

### F5 — Measurement disclosures: adequate, with two soft spots — MINOR

(a) The dry run named in T015 was not taken and notes.md says so ("Recorded rather than claimed"), which is the honest handling; the flow-down
note does not repeat it, and does not need to. (b) "No pass was discarded", "Every ritual member was OK or `n/a` in every state" and "the
change was discarded" are the implementer's unverifiable records; I did not re-run the clones. The note's own caveat ("proved by the kit's
fixtures, not by an adopter's case"; "a statement about their documents today, not a guarantee about their next edit") is accurate and
sufficient. No statement overstates beyond what notes.md records.
*Action: none.*

## Amendments in this diff

- [x] None. `tasks.md` changes are checkbox ticks only (T013-T016 in `427a538`, T017 in `7fbf8a7`); `spec.md` and `plan.md` untouched.

## Constitution re-check (post-implementation)

PASS. No constitution amendment (the note's title says so and the diff confirms). Principle on source of truth: guidance lives in
review-process.md and updating.md, the digests are generated by `build-digests.ps1` and fresh; the owner decision on FR-011 is
carried into the flow-down note verbatim in effect. No new package, no manifest change.

## Test coverage observed

Phase 3 adds no script or fixture; its checks are the existing ones. Re-run by me: `-Case DOC-` 135 passed, 0 failed; `doc-lint.ps1` OK;
`build-digests.ps1 -Check` OK; `ritual-checks.ps1` RESULT OK; `scope-check.ps1` PASS on both commits. Not re-run: the full harness (1211,
implementer's isolated-checkout record) and the clone measurement.

## Residual risk

Low. The risk sits in (1) the half-applied update failure mode of F2 (loud, fixed by finishing the update), (2) the N5 header-less-pipe-prose
false-positive class carried from phase 1 and not mentioned to adopters (F4), and (3) the unreviewed-by-me clone measurement. Fix F1 and
F2 in a docs-only follow-up commit before the owner's gate; the human review at merge is still to come.


# Round 2 — review of the remediation commit `7dd11b7` (parent `7fbf8a7`)

## Reviewer Provenance (Round 2)

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-sonnet-5-5 (separate session that produced `7dd11b7`)
- **Inputs provided**: `git show 7dd11b7`, spec.md, plan.md, tasks.md Phase 3, notes.md ("Phase 3 review remediation"), the Round 1 findings above, the phase 1 and 2 reviews, scripts at the branch tip and at `c292d62`
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict (Round 2)

**APPROVE with one follow-up.** F1, F2 and F3 are fixed and true. F4's list of accepted limits is accurate item by item, but the new
flow-down sentence (and the roadmap phrase and the notes.md paragraph that echo it) over-generalizes the header-less pipe case and is
incomplete about where a dash-only row is read as a delimiter (new finding R2-1, MINOR, documents only). Nothing executable changed.
Certification is the owner's; nothing here claims the gate passed.

## Evidence (Round 2)

| Check | Result |
|---|---|
| F1 newline | `docs/roadmap.md` ends `...to come.` plus exactly one `\n` (`od -c`); index and worktree both LF (`git ls-files --eol`). The file diff is 7 insertions, 3 deletions: no whole-file churn. `adoption/updating.md` is `w/crlf` in the worktree only (autocrlf, `i/lf`); numstat 9/3, so no churn. |
| F2 half-applied | Built a throwaway full tree from `git archive HEAD` and swapped in `c292d62:scripts/markdown-lib.ps1`. The new doc-lint dies with `The term 'Get-StructureFindings' is not recognized...`, exit 1; `ritual-checks` prints `doc-lint FAIL` and `RESULT FAIL (3 of 6 member(s) failed)`. The sentence "stops with an unrecognized-function error and doc-lint.ps1 and ritual-checks.ps1 stay red" is TRUE. |
| F2 reverse | `c292d62:scripts/doc-lint.ps1` has zero references to `markdown-lib` (grep count 0), so it never loads the library. Old doc-lint beside the new library ran `doc-lint: OK`, exit 0. "Harmless" is therefore TRIVIALLY true: the old script cannot see the library at all (R2-2). |
| "not new to you" | True for adopters: `scripts/markdown-lib.ps1` predates feature 020 (it exists in `c292d62` without `Get-StructureFindings`; its history runs through the 016 commits), and `kit-manifest.json` line 40 classes `scripts/*.ps1` as `verbatim`, so `update-kit.ps1` replaces it. |
| 2b dash-only row after a blank line | `text / (blank) / \|---\|---\|` gives `3 severed-delimiter`. Reproduced. Header row added above it: no finding. Written without pipes (`--- ---`, `- -`): no finding. Both suggested fixes clear it. |
| 2b dash-only row after a comment line | `text / <!-- c --> / \|---\|---\|` gives `3 severed-delimiter`. Reproduced. |
| 2b "prose that starts with a pipe and has no header above it" | OVER-GENERALIZED. `Some text / \| a \| b \|` and a lone `\| just a note \| more words \|` give no finding. Only a delimiter-shaped pipe line (every cell dashes) fires: `Some text / \| - \| - \|` gives `2 severed-delimiter`; `text / (blank) / \| --- \|` gives `3 severed-delimiter`. See R2-1. |
| F3 counts | Recounted from the files with CRLF stripped. review-process.md (line 148, the block-structure marker): 103 chars of marker text, 120 as a whole line. updating.md lines 819 and 820: 114 / 131 and 111 / 128. All match notes.md. `build-digests.ps1` defines `MaxDigestLineLength = 120 chars of marker content` (lines 41, 62), so all three are inside the cap, and the notes.md statement that the cap measures the text after `digest: ` is accurate. |
| Roadmap structure | `Get-StructureFindings` over `docs/roadmap.md`: 0 findings (the inventory table is one table; the entry follows a blank line, so the list rule is met). Also 0 for `adoption/updating.md` and `docs/sdlc/review-process.md`. Precedent wording kept: "built, reviewed and measured: the human review at merge is still to come." |
| Nothing executable changed | `git show 7dd11b7 --stat`: only `adoption/updating.md`, `docs/roadmap.md`, `ai-code-review-phase-3.md`, `notes.md`. No script, fixture, rules file, digest, manifest or `tasks.md`. |
| Digests | `build-digests.ps1 -Check`: `digests: OK (5 digest(s) fresh, 91 marker(s))`; `git status` clean afterwards, so no CRLF-only digest churn. |
| Scope and ritual | `scope-check.ps1`: `PASS phase 3 commit 7dd11b7 (4 file(s))`. `ritual-checks.ps1`: doc-lint OK, enforcement-pack OK, scope-check OK, scope-repos n/a, digests OK, roadmap-claims OK, verify-kit n/a, `RESULT OK`. |
| Tests | `Run-Tests.ps1 -Case DOC-`: 135 passed, 0 failed. Full harness NOT re-run (no executable changed, so the notes.md claim holds). |

F4, limit by limit (roadmap entry):

| Limit stated | Verdict |
|---|---|
| An unclosed comment, or an empty one without its dashes, hides the rest of its document | Accurate (phase 1 N1: `<!-->`, `<!--->`, plain `<!-- start`). |
| A double backslash before a pipe is an escaped backslash then a boundary; a delimiter row holding one is accepted where GitHub would not | Accurate for `\\` (N2, N3). N3 also covers a single `\-` or `\|` in a delimiter, which the clause does not name; narrow, not wrong. |
| Two tables with no blank line are one table; differing counts give several ragged-row reports | Accurate: repro gives `4, 5, 6 ragged-row` (N4). |
| A row of only dashes after a gap, or pipe prose with no header, is reported as a severed delimiter; the rest of that run is not graded | First half and "rest not graded" accurate (N5; repro `x / blank / \|---\|---\| / \| a \| b \| c \|` reports only line 3). "pipe prose with no header" over-generalizes (R2-1). |
| A comment between lists of different type is still reported | Accurate (phase 2 F1). |
| Silent by design: an indented comment is not remembered; a tab continuation or lazy text resets a list | Accurate (phase 2 F2a, F2b). The one-space continuation variant is not named; immaterial. |
| Anything from the phase 1 and 2 reviews still omitted? | No. |

## New findings (Round 2), ranked

### R2-1 — The new "what to do" sentence over-generalizes the header-less pipe case — MINOR (documents only)

`adoption/updating.md` now says: "a row of only dashes directly after a blank or comment line, or prose that starts with a pipe and
has no header above it, is read as a delimiter row and reported as `severed-delimiter`". Two problems:

1. Ordinary prose that starts with a pipe is NOT reported. Repro: `Some text` then `| a | b |` gives no finding; a lone
   `| just a note | more words |` gives no finding. Only a pipe line whose cells are all dashes (optionally with colons) fires, for
   example `| - | - |` or `| --- |`. A reader may strip pipes from prose that was never at risk, or wrongly conclude that a failing run must be
   this case. The roadmap clause ("pipe prose with no header") and the notes.md paragraph ("header-less pipe prose reported as
   `severed-delimiter`") repeat the wording; phase 1 N5 was precise ("a bare `| - | - |` row").
2. The sentence names only "after a blank or comment line", but the dash-only row also fires directly under an ordinary text line
   (`Some text` then `| - | - |` gives `2 severed-delimiter`). That is the actual N5 case and the likeliest adopter form, and the sentence
   does not cover it.

The suggested fixes work (verified), so no adopter is stuck; the harm is imprecision in a sentence meant to tell adopters what to look for.
*Action: reword to "a pipe row made only of dashes (for example `| - | - |`) that is not directly under a header row of the same width, after
a blank or comment line or under plain text, is reported as `severed-delimiter`; give it a header row, or write it without pipes", and change the
roadmap clause and the notes.md sentence from "pipe prose" to "a dash-only pipe row". Documents only; not blocking.*

### R2-2 — "Harmless" in the reverse direction is trivially true — INFO

The old `doc-lint.ps1` never dot-sources `markdown-lib.ps1`, so "an old `doc-lint.ps1` beside a new library is harmless" holds because the
old script ignores the library, not because of anything about the library. True and safe as written; "never loads it" would be more
exact. No action required.

## Residual risk

Low. (1) R2-1 imprecision in the flow-down note (documents only, and any fix the note names clears the finding). (2) The T015 clone
measurement and the T017 isolated-checkout full-harness count (1211) still rest on the implementer's record; I re-ran neither and did not
run the full harness. (3) The human review at merge is still to come; certification is the owner's.
