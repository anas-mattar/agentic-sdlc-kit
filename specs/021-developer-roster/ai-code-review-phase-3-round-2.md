# AI Code Review — 021 Load-bearing Developer Roster, phase 3 remediation (round 2)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-12
**Branches**: kit repository `021-developer-roster` (remediation commit `666fddc`, parent `b6057e8`; phase 3 is `660cccb`, its parent `062fbbe`)
**Scope reviewed**: `git diff 660cccb 666fddc` in full: `scripts/roadmap-claim-check.ps1` (the delimited-token binding, the `HasOwnerColumn` row flag, the
CLAIM-014 ambiguity path, the F6 no-Owner-column path, the `$ungraded` clauses and the `$gradedText` edit), the comment-only change in
`scripts/ritual-checks.ps1`, `tests/enforcement/rules.json` (CLAIM-010, CLAIM-013, new CLAIM-014, RIT-008) and `emission-idioms.json` (the UNGRADED roll-up
not-a-rule entry), the nine new fixtures (`CLAIM-009/fail-prefix-claim`, `fail-stranger-with-two-claims`; `CLAIM-010/fail-claim-in-table-without-owner`;
`CLAIM-011/pass-cross-reference-not-counted`; `CLAIM-013/fail-ungraded-beside-a-finding`, `fail-first-tip-unreadable`; `CLAIM-014/fail`, `pass`,
`pass-same-owner-twice`), the `RIT-008/fail` description, and `notes.md`; against the phase 3 review (`ai-code-review-phase-3.md`, findings F1..F6), `spec.md`
FR-005, FR-007, SC-001, SC-002, and `plan.md` D3, D4, D5, D7, D8, D9. Shape precedent: `ai-code-review-phase-1-round-2.md`.
**Feature contract**: no new script or package; roster read only through the one reader; with no usable roster the output and verdicts are byte-identical;
UNGRADED is a verdict, never an exit code; read-only on the working tree; territory is `scripts/roadmap-claim-check.ps1`, `scripts/ritual-checks.ps1`, `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-sonnet-5-5 (separate session that produced the remediation commit `666fddc`)
- **Inputs provided**: remediation diff (`660cccb` to `666fddc`), CLAUDE.md, review-process.md, the review template, spec.md, plan.md, tasks.md, notes.md, the phase 3
  review being answered, the phase 1 round 2 review as shape precedent, the scripts and fixtures at `666fddc`
- **Attestation**: This reviewer did not produce the diff under review.
- **Prior involvement**: none. Fresh context; notes.md was read as a claim and checked.
- **Commands run**: `git diff --stat` and `git diff 660cccb 666fddc`; `pwsh -File tests/enforcement/Run-Tests.ps1 -Case CLAIM-` and `-Case RIT-` on the working tree
  (the repository checkout contains `666fddc`'s scripts unchanged); three detached worktrees outside the repository (`666fddc`, `660cccb`, `062fbbe`); in the
  `660cccb` worktree the new fixtures, `rules.json` and `emission-idioms.json` copied in and run with `-Case CLAIM-`; the full harness in the `666fddc` worktree
  (1033 s); `pwsh -File scripts/ritual-checks.ps1 -Branch 021-developer-roster` in that worktree; `pwsh -File scripts/scope-check.ps1 -Commit 666fddc`; about 16 scratch
  repositories (bare origin, one branch per claim) each run with all three versions of `roadmap-claim-check.ps1` (token and Spec-cell binding, prefix/suffix claim
  names, regex characters, a claim in another row's Spec cell, case and padding of Owners, a bound `idea` row beside a live mentioning row, the own claim beside
  an ambiguity, two tables with and without an Owner column, a stranger with two claims beside an ambiguity, no roster / empty roster / unusable roster / malformed
  record with claims mentioned in other rows). The worktrees and scratch repositories were removed; nothing was run against the adopted projects in `D:\solutions`;
  `git worktree list` shows only the main checkout and `git status` is clean apart from this file (and the phase 4 review, which is not mine).

## Verdict

**APPROVE with follow-ups.** F1, F2, F5 and F6 of the phase 3 review are fixed as described, and I reproduced each. A claim is now bound to its own row by a
delimited token preferring the row that holds `specs/<claim>`; a row that merely mentions a claim, a claim that is the prefix of another, and a claim name with
regex characters no longer move an Owner's verdict or count (probed). Rows that still disagree on the Owner give an UNGRADED verdict with exit 0, never a hard
failure, and the claim is removed from the WIP count; a claim whose only rows are in a table with no Owner column is named, and the OK line then drops the
words "Owners and claim counts graded". UNGRADED is never printed over a FAIL. With no usable roster the output is byte-identical to `062fbbe`, and the
visibility reading is untouched. Full harness 1327 passed, `ritual-checks` and `scope-check` pass, notes.md counts and coverage figures match. Two follow-ups:
a claim that is visible but matched by no token is now skipped in silence while the OK line says Owners were graded (R2-1), and the delimiter set is narrower than
the set of characters a branch name may contain (R2-2). Neither blocks. Certification of the gate is the owner's; nothing here claims it passed.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| F1, the binding, my scratch runs on `062fbbe` / `660cccb` / `666fddc` | Row `015-eee` (grace) with the text "depends on 011-aaa", `011-aaa` held by ada: `660cccb` fails grace with 3 active claims, `666fddc` gives a note for two (`015-eee`, `016-ggg`) and OK. Prefix pair `011-a` / `011-a_b` (ada / stranger): `660cccb` charged both claims to stranger, `666fddc` flags only `011-a_b`. Regex characters: `011-a.b` against `011-aXb` kept apart (`[regex]::Escape`), `012-c+d` read as its own claim. |
| F1, preference for the Spec cell | `$mine` is the rows holding `specs/<claim>`; only if none do, every token row is used. Two rows bound and disagreeing, or no bound row and two mentioning rows disagreeing, both reach the CLAIM-014 line (probed). Same Owner on both rows is one distinct Owner (`pass-same-owner-twice`). |
| Owner case and padding | `$distinctOwners` uses `Sort-Object -Unique` (case-insensitive) on the trimmed cell: `Ada` and `ada` are one Owner and no ambiguity (probed); cells are trimmed in `Get-Cells`. The roster comparison and the per-Owner count key are unchanged from phase 3. |
| Bound row `idea`, mentioning row live | `idea` bound row, mentioning row `in progress` (different Owner): `$live` is empty, nothing is graded or counted for that claim. This is consistent with FR-005 (non-`idea` rows only) and with the visibility reading, which still passes on the mention (unchanged). Silent; see R2-1 for the same silence in a case where it matters. |
| Own claim and ambiguity | The own-claim `continue` precedes everything, so the own claim is never ambiguous itself. The own claim's row can still make another claim ambiguous when that claim has no `specs/<claim>` row (probed: own row "also see 011-aaa", ada's row `—` in the Spec cell: UNGRADED, exit 0). Matches the CLAIM-014 design; it needs a roadmap whose Spec cell was not flipped. |
| CLAIM-014, the path | Detail line, `$ungraded += "the Owner of '<claim>' was not graded"`, `continue` before the roster check and before `$candidates`: the claim leaves the count (probed: grace with three claims, one ambiguous, gets the note for two and UNGRADED, exit 0). UNGRADED exit 0 in every probe; there is no failure path from it. Side effect: a claim can be kept out of both the roster check and the WIP count by being mentioned in a row with another Owner and no Spec path; it is said out loud and UNGRADED, so it is visible, but it is not a block (R2-4). |
| UNGRADED beside a FAIL | `$failures.Count -gt 0` exits through the FAIL block before the UNGRADED block is reached: a stranger finding plus an ambiguity gives the detail line, the finding, `FAIL (1 finding(s) on 2 claim(s))`, exit 1, no UNGRADED line (probed; fixture `fail-ungraded-beside-a-finding` pins the unreadable-date version). |
| F6, no Owner column | A claim in a Status-only table beside an Owner table: `not graded — claim '...' is in a roadmap table with no Owner column`, OK line without "Owners and claim counts graded". A claim in both tables is graded from the table that has the column (probed). The whole-roadmap case (first CLAIM-010 site) is unchanged. A table with Owner but no Status contributes no rows (pre-existing). Verdict stays OK with the line printed, as for the whole-roadmap case (consistent, R2-3). |
| FR-005 / SC-001, byte-identity | No roster, `{"developers":[]}`, `{"developers":[1,"  "]}` and a malformed record, each over a roadmap with claims mentioned in other rows, an `idea` row and a failing visibility case: `062fbbe` and `666fddc` output identical (text and exit code) in all four. The passing no-roster variants (cross-references; an In-Progress trio) identical across all three versions. `git diff 660cccb 666fddc` modifies no pre-existing fixture (only `RIT-008/fail/recipe.json`'s description, and new files); `CLAIM-001..008` pass unchanged. The row hashtable gained a key; nothing prints it. |
| Visibility reading | Section 4 of the script is untouched by the diff (`-like` selector kept, as the review allowed and `.SYNOPSIS` says). |
| New fixtures against `660cccb` | Worktree of `660cccb` with the new fixtures and rule files copied in, `-Case CLAIM-`: 128 passed, **7 failed**: the four output assertions of `CLAIM-009/fail-prefix-claim`, `CLAIM-010/fail-claim-in-table-without-owner`, `CLAIM-011/pass-cross-reference-not-counted`, `CLAIM-014/fail`, plus the three inventory/anchor tests (CLAIM-014 and the second CLAIM-010 site do not exist in the old script). Their exit-code assertions pass there, as does everything else: `fail-stranger-with-two-claims`, `fail-ungraded-beside-a-finding`, `fail-first-tip-unreadable` and CLAIM-014 `pass`/`pass-same-owner-twice` pin behaviour that was already right, exactly as notes.md says. |
| Fixtures pass now | `-Case CLAIM-` **135 passed, 0 failed** (50 cases); `-Case RIT-` **129 passed, 0 failed** (47 cases). |
| Full harness | Detached `666fddc`: **1327 passed, 0 failed, 0 skipped, `enforcement-tests: OK`** (1033 s). 1327 = 1309 + 18 (nine cases x two assertions). Coverage: `roadmap-claim-check.ps1  15 of 16 site(s) fixtured (1 not a rule)`. |
| rules.json / idioms honesty | CLAIM-010 `siteCount: 2` with anchor `no Owner column`: both printed lines contain it (whole-roadmap and per-claim); CLAIM-013 drops `siteCount` (the verdict line's text is an interpolated variable, so only the detail line carries `the claim count for` literally); CLAIM-014 anchor `named by rows with different Owners` is one site; the UNGRADED roll-up is declared not-a-rule with a reason that names CLAIM-013 and CLAIM-014 and says it decides nothing, which is true (it prints the clauses the accumulator holds). The coverage, anchor and notRules tests all pass. One imprecise sentence in CLAIM-014's `summary` (R2-5). |
| F2 | `ritual-checks.ps1` diff is comment-only (no executable line changed); the comment, the `RIT-008/fail` description, the `rules.json` RIT-008 note and notes.md now say the case is a regression guard on the union of the two lists, green on the parent, and that plan D8's premise was wrong, recorded as an inaccuracy and the plan not amended. Accurate; no amendment made. |
| F5 | The three F5 fixtures exist and assert what notes.md says (unreadable first tip with two claims: UNGRADED exit 0 naming `011-aaa`; stranger with two claims: note plus two findings; unreadable date beside a finding: the detail line, the finding, FAIL, exit 1, no UNGRADED). The 14-day boundary and `In Progress` capitalisation stay unfixtured and are said to be (notes.md). |
| notes.md | Counts (135 CLAIM-, 129 RIT-, 1327, 15 of 16, RESULT OK), "nine new cases", "difference of 18" and the statement of which fixtures fail on `660cccb` all match what I observed. F3 and F4 are correctly deferred to phase 4. No claim of certification. |
| Scope | `pwsh -File scripts/scope-check.ps1 -Commit 666fddc`: **`scope-check: PASS phase 3 commit 666fddc (33 file(s))`**. The commit also carries the phase 3 review file, as the precedent does. |
| Ritual | `pwsh -File scripts/ritual-checks.ps1 -Branch 021-developer-roster` in the `666fddc` worktree: doc-lint, enforcement-pack, scope-check, digests, roadmap-claims OK; scope-repos and verify-kit n/a; **`RESULT OK`**. |
| Read-only | The script writes nothing; `git fetch --quiet origin <branch>` updates remote-tracking refs only. Working tree unchanged after every scratch run. |

## Findings

### R2-1 — A claim that is visible but matched by no delimited token is skipped in silence, and the OK line still says Owners were graded — MEDIUM (follow-up)

The visibility reading still uses `-like "*$claim*"` (case-insensitive, no delimiter); the Owner and count readings use a case-sensitive token with `.`, `_` and `-` as
"continues a branch name" characters on both sides. A claim that a row names in a way the token does not accept passes visibility and then falls through the Owner
reading with `$named` empty, no line printed, and the OK line reading "Owners and claim counts graded against the declared roster". Scratch run: row
"Alpha 011-aaa." (sentence-final full stop, no `specs/` path) with Owner `stranger`. `660cccb` failed the stranger; `666fddc` prints
`roadmap-claims: OK (2 claim(s) visible with non-idea rows, Owners and claim counts graded ...)`, exit 0. The same holds for a differently-cased claim in the Spec
cell, or a name preceded by `.` or `_`. The `specs/<claim>/` form that the kit's own flip instruction asks for is unaffected (it is bounded by `/`), so the
exposure is an adopter-authored or hand-edited row, but the claim is then dropped from the roster check and the WIP count without a word, which is the
"comparison not made" silence feature 015 outlawed, and it makes the new OK line's statement untrue.
*Action: implementer, within Territory: when a claim passed visibility (some `-like` row exists) but the token reading found no row, print a not-graded line and add the UNGRADED clause (or accept `.` as a terminator when it is followed by whitespace, `|` or end of cell, and match the token case-insensitively as `-like` does); add a fixture for a claim named only as "011-aaa." in a row. If the owner prefers silence for this case, record it in notes.md and drop the claim from the OK line's "graded" wording.*

### R2-2 — The delimiter class is `[A-Za-z0-9._-]`, narrower than what a branch name may contain, so some prefix claims still match the longer name — MINOR

Probed: claims `012-c` and `012-c+d` (rows `specs/012-c/` ada, `specs/012-c+d/` stranger): the token for `012-c` also matches the `012-c+d` row (`+` is not in the class), both rows hold `specs/012-c`, the owners differ, and `012-c` is reported as ambiguous (UNGRADED) instead of being graded for ada. The same holds for `@`, `=`, `%`, `#`, `,` and `/` inside a branch name. The direction is safe (UNGRADED, never a false failure, which is the plan's stated preference), the characters are rare in a `NNN-name` slug, and the characters that are not in the class are also the ones that must end a name in prose (comma, parenthesis, backtick). The `.SYNOPSIS` says "characters that cannot continue a branch name", which overstates it by that margin.
*Action: none required; adjust the comment wording to "the characters a feature slug is made of", or leave as is.*

### R2-3 — A claim in a table with no Owner column prints a line but the verdict stays OK, while an ambiguity gives UNGRADED — MINOR (awareness)

Two "not graded" lines with two verdicts: the whole-roadmap no-Owner-column line (existing idiom, OK) and the new per-claim line (OK, with the "graded" words dropped) versus
CLAIM-014 and the unreadable tip (UNGRADED). notes.md and the CLAIM-010 note state the OK deliberately and the OK line is honest (its "graded" words are gone), so this is
within the existing idiom and the phase 3 review (F6) asked only for a line. A reader of `RESULT` alone will not see the F6 case, though. Phase 4's guidance could say that the
Owner column is needed in every table that carries claims.
*Action: none; owner's call whether F6 should have been UNGRADED.*

### R2-4 — An ambiguity removes the claim from both the roster check and the WIP count, with exit 0 — MINOR (awareness)

By design (UNGRADED, never a guess), and confirmed: an Owner with three claims, one of them named by a row with another Owner and no Spec path, gets the two-claim note
instead of the WIP failure, and a stranger Owner on that claim is not reported. The verdict says UNGRADED, names the claim, and the line says "its Owner and its place in a count were not graded". The consequence is only that the ritual's `RESULT UNGRADED` (exit 0) must be read by the human reviewer before merge; the review process already makes that so.
*Action: none.*

### R2-5 — CLAIM-014's `summary` says "none of them holds its own Spec path", which is not the only way into the path — MINOR (wording)

`rules.json` CLAIM-014 `summary`: "named by rows with different Owners and none of them holds its own Spec path". Two rows that both hold `specs/<claim>/` with different Owners also reach the line
(probed). The `notes` field and the script's comment describe it correctly ("when that still leaves rows that disagree").
*Action: reword the summary to "the rows left after binding name different Owners".*

## Phase 3 findings, one by one

| Finding | Status |
|---|---|
| F1 — claim attributed to every row whose text names it | **Fixed as described.** Delimited token, Spec-cell preference, ambiguity as UNGRADED; fixtures for the prefix claim, the cross-reference and CLAIM-014; the visibility reading kept and said so. Residuals: R2-1, R2-2. |
| F2 — D8 wiring is a no-op, `RIT-008` green on the parent | **Fixed as described.** Wording corrected in notes.md, `rules.json`, the fixture description and the script comment; the plan inaccuracy recorded, not amended. |
| F3 — Owner cell must be one bare name | Deferred to phase 4 guidance, as the review allowed. |
| F4 — one-developer roster is usable | Deferred to phase 4 / SC-003, as the review allowed. |
| F5 — edge cases without a fixture | **Fixed for the three the review named first** (unreadable first tip with two claims, the F1 cross-reference, the second table without an Owner column) and the stranger-with-two-claims case; the boundary and `In Progress` capitalisation remain by hand, said so. |
| F6 — second table without an Owner column skipped in silence | **Fixed as described.** Line printed, OK line withdraws the "graded" words; see R2-3. |

## Amendments in this diff

- [x] **None.** `spec.md`, `plan.md`, `tasks.md` and `contracts/` are untouched by `666fddc`. The plan D8 inaccuracy is recorded in notes.md as a fact, not applied as an amendment. CLAIM-014 is a new rule but not a new requirement: it implements the review's "name the ambiguity as not graded" alternative inside the existing FR-005/FR-007 and D4.

## Constitution re-check (post-implementation)

**PASS.** I (no spec/plan/tasks change; no self-approved amendment), IV (the one reader, no new file), VIII (fixtures hand-written; the four pinning new behaviour shown failing on `660cccb`), IX (this review is fresh-context; human review at merge), X (one phase, user-run gate). Feature 015's rule (a comparison not made is never OK) is honoured by the ambiguity path and, except for R2-1, by the token path.

## Test coverage observed

- `-Case CLAIM-` on `666fddc`: 135 passed, 0 failed. On `660cccb` with the new fixtures copied in: 128 passed, 7 failed (4 output assertions, 3 inventory tests), all expected.
- `-Case RIT-`: 129 passed, 0 failed.
- Full harness, detached `666fddc`: **1327 passed, 0 failed, 0 skipped**; `roadmap-claim-check.ps1` 15 of 16 sites fixtured (1 not a rule).
- Scratch probes (not fixtures): delimiter set (R2-2), sentence-final full stop (R2-1), bound `idea` row beside a live mention, two rows both bound, ambiguity beside a stranger finding, ambiguity and the WIP count, no-roster byte identity against `062fbbe` for four roster states.

## Residual risk

Small. The binding now follows what a roadmap row says about a claim instead of every row that contains its name, and every case in which it cannot decide ends in UNGRADED with exit 0. The remaining exposure is the one silent path (R2-1): a claim that is visible by loose matching but absent by strict matching. Merge after the owner's gate certification and human review; R2-1 should be fixed or explicitly accepted by the owner first.
