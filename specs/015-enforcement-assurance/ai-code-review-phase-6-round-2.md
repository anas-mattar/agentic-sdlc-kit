# AI Code Review — 015 Enforcement Assurance, Phase 6 (round 2)

**Reviewer**: fresh-context agent — claude-opus-5-5
**Date**: 2026-09-26
**Branches**: agentic-sdlc-kit `015-enforcement-assurance` (tip `9ae7b53`, parent `28a99fa`)
**Scope reviewed**: the whole of `9ae7b53` (24 files). I also judged the phase as it now stands,
`git diff 1f05bb3 9ae7b53` (38 files). Read in full: `scripts/enforcement-pack.ps1` (header,
`Invoke-AmendmentAuthorityCheck`, dispatch and verdict tail), `tests/enforcement/{Coverage.Tests.ps1,
Harness.Tests.ps1,rules.json,emission-idioms.json}`, `tests/enforcement/lib/{RunChild.ps1,
FixtureRepo.psm1}`, the capture path in `lib/Harness.psm1`, the new and changed fixture pairs
(`PACK-004`, `TERR-012`, `AMEND-006`), `adoption/updating.md` (the 015 flow-down note and the
amendment-check section above it), `docs/sdlc/review-process.md` step 3, and
`specs/015-enforcement-assurance/notes.md` ("Phase 6" and "Phase 6 review round 1 —
remediation"). Also read, not changed by this commit: `scripts/territory-check.ps1`, the
UNGRADED sites in `scripts/scope-check.ps1` and `scripts/scope-check-repos.ps1`, and docs PR #49.
**Feature contract**: phase 6 = T044–T053. Territory is `tests/**`,
`.github/workflows/enforcement-tests.yml`, `scripts/enforcement-pack.ps1`, `adoption/updating.md`,
`docs/sdlc/review-process.md` and `docs/digests/*-digest.md` (`tasks.md`). Requirements in scope:
FR-003, FR-004, FR-010, FR-016, FR-019–FR-022, SC-002 and SC-007. Plan D6 applies (UNGRADED never
moves an exit code), and so does `**Gate Certification**: ci-held`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: Claude Opus 5.5 is the implementing session that wrote `9ae7b53`. The commit's
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` trailer names it. It is not this
  reviewer.
- **Inputs provided**: `git show 9ae7b53`, `git diff 1f05bb3 9ae7b53`, the round-1 review with
  its Dispositions table (`ai-code-review-phase-6.md`), `CLAUDE.md`,
  `.specify/memory/constitution.md`, `docs/sdlc/definition-of-done.md`,
  `docs/sdlc/review-process.md`, `specs/015-enforcement-assurance/{spec,plan,tasks,notes}.md`,
  `specs/_templates/ai-code-review-template.md` and the earlier round-2/round-3 reviews. I also
  used `gh run view` on runs 36213578824 and 36213578783, plus both enforcement-tests job logs,
  and `gh pr view/diff 49`. At HEAD in the main tree I ran `scope-check.ps1` and
  `ritual-checks.ps1`. In a scratch clone of `9ae7b53` I ran: the T047 describe detached and on a
  local `main`; one T047 mutation; three `notRules` guard mutations; the TERR-012 case against a
  disabled `originFetch` knob and against a removed `PlainText` line; PACK-004 and AMEND-006
  mutations, including a revert of the F6 change; a probe of the OK-variant blind spot; and
  `enforcement-pack.ps1` / `ritual-checks.ps1` on a simulated post-merge NNN branch and on a
  fresh NNN branch, both with full history.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES.** The remediation is good work, and I proved each fix by running it, not by
reading it:

- F1 is host-independent. The T047 describe is green detached and on a branch named `main`, and
  it still catches a case that names a branch its fixture never creates.
- F2's three guards each fire under mutation.
- F3's TERR-012 pair discriminates on the refspec knob.
- PACK-004 discriminates.
- AMEND-006 now pins the rule and not the defect.
- CI shows 805/805 on both OS legs.

One thing still stops an approval, and it is this feature's recurring species. The adopter-facing
flow-down note (T049) says "On a healthy checkout with full history you will not see
[`UNGRADED`] at all", then gives `fetch-depth: 0` as the remedy. F6, which this remediation made,
adds a full-history state that produces `UNGRADED`: an NNN branch with no commits of its own. I
measured it on a full-history clone, where two members report `UNGRADED` and no fetch setting
changes that. The sentence was already false for `scope-check` at `28a99fa`. The remediation
edited the paragraph right above it, named the empty range as a cause, and left the universal
standing. That is a one-sentence fix. The remaining findings are non-blocking.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match | **F1/FR-020**: I ran the T047 describe (3 tests) in a scratch clone. Detached `HEAD`: 3/3 passed. Local branch `main`: 3/3 passed. As a mutation I changed `PACK-003/fail` to `-Branch 015-enforcement-assurance`, and the test failed with "passes -Branch '015-enforcement-assurance', which its fixture never creates (it creates: main)". **F2/FR-004**: see F2 below. **F3**: TERR-012 is green at HEAD. With the `originFetch` config line disabled, `TERR-012/fail` fails (observed `CLEAN — ...` where `WARNING: Skipping origin/012-other ...` was expected) and `pass` stays green. **F5**: I deleted the docs-lane `Write-Host` (`enforcement-pack.ps1:1272`), and `PACK-004/fail` failed (verdict line and first diff named). **F6**: I inverted `$commits.Count -eq 0` (`:1095`) and both AMEND-006 directions failed. I also reverted the F6 change to the old `Write-Host` form, and `AMEND-006/fail` failed. |
| Visual-reference match | N/A — no UI. |
| Feature contract held | No package and no workflow change. Every file changed in `9ae7b53` is in the phase-6 Territory or the feature directory. The one behavioural change to a script (`enforcement-pack.ps1:1099`, F6) keeps exit 0 (`:1287-1293`), as D6 requires. |
| Constitution / domain invariants | `spec.md`, `plan.md` and `tasks.md` are untouched by `9ae7b53`, so there is no amendment. The owner decisions on F5/F6/F8 are recorded in the Dispositions table and in `notes.md`. |
| Security | N/A — tests, fixtures and prose. |
| Scope guard | `pwsh -File scripts/scope-check.ps1` → `scope-check: PASS phase 6 commit 9ae7b53 (24 file(s))`, exit 0. |
| Whole-run verdict | `pwsh -File scripts/ritual-checks.ps1` at HEAD → `RESULT OK`, exit 0. All members OK or `n/a`. |
| CI | ritual-checks run 36213578824: success, push, `9ae7b53`, 19s. enforcement-tests run 36213578783: success. The job logs show `Tests Passed: 805, Failed: 0` on both ubuntu (310.8s) and windows (826.8s). Both runs are `push` events on the named branch. I proved the detached and `main` checkouts locally, as above; CI has not run them. |
| Rollback safety | Reverts cleanly. The only production-behaviour change is a verdict word on an empty amendment range, and its exit code is unchanged. |

## Findings

### F1 — The flow-down note's "you will not see it at all" is false on a full-history checkout, and its remedy does not apply there — BLOCKING

`adoption/updating.md:460-461`: "**`UNGRADED` where you used to see `OK`.** Only in the states
listed above. On a healthy checkout with full history you will not see it at all." Then
`:478-480`: "the usual cause is `fetch-depth: 0` missing ... Fixing that turns the word back into a
real `OK`."

I measured the post-merge state in a scratch clone with full history (not shallow). There,
`origin/main` = `main` = `9ae7b53`, and the branch `015-enforcement-assurance` sits at the same
commit:

```text
UNGRADED: AmendmentAuthority: no commits in 9ae7b53..HEAD — nothing to grade, so no amendment on '015-enforcement-assurance' was checked for its approval record
ritual-checks: enforcement-pack UNGRADED (1 check(s) formed no opinion)
ritual-checks: scope-check      UNGRADED (no commits since merge base — no commit was examined)
ritual-checks: RESULT UNGRADED (2 of 6 member(s) formed no opinion; nothing failed)
```

F6's change is correct: it matches `scope-check.ps1:309`. The fixture and the D6 exit code are
right too, and the list above the sentence now names "a commit range with no commits in it". But
the universal right after that list still says a healthy checkout never shows the word. The
remedy paragraph then sends an adopter who does see it to chase `fetch-depth`, which cannot change
this verdict. `scope-check` already made the sentence false at `28a99fa`, and round 1 missed it.
The remediation widened the gap and edited the sentences on either side of it. This is the same
class as round 1's F4 and as phase 5's three rounds: prose in the note adopters act on, claiming
a property the code does not have.

*Action: implementer. Replace the universal with what the code does. For example: "With full
history you will see it only where there is genuinely nothing to grade: an `NNN-*` branch with no
commits of its own yet (or already merged), where `scope-check` and the amendment check both say
so." Also scope the `fetch-depth` remedy to the no-base causes.*

### F2 — `notRules` guards: fixed, and each one fires — resolved (no action)

These mutations ran in a scratch clone and were reverted after each run:

- **New site under an existing anchor.** I added
  `if ($gradedCount -eq 0) { Write-Host "AmendmentAuthority: graded nothing silently" }` after
  `:1224`. The test fails with "excuses 2 site(s) [enforcement-pack.ps1:1224,
  enforcement-pack.ps1:1225], declared 1".
- **Empty reason.** The notRules test fails with "the reason is missing or says almost nothing".
  The report test also fails, because `Split-Reason` rejects an empty string.
- **Short reason** (45 characters): the test fails, same message.
- **Report prints every entry.** The report prints 13 entries, which equals the 13 entries in
  `emission-idioms.json`, each with its reason.

The siteCount scan covers precise-pass and recall-pass sites alike (`Coverage.Tests.ps1`, the
`$script:Owned` + `$script:UnclassifiedOwned` keys). That is correct, because most notRules
anchors are recall-sweep sites.
*Action: none.*

### F3 — The `PlainText` change in `RunChild.ps1` is a legitimate request to the child, not an instrument rewriting what it grades — resolved (no action)

**Measured.** With `tests/enforcement/lib/RunChild.ps1:38` removed, `TERR-012/fail` fails at line
1. The expected and observed lines are textually identical once escapes are stripped for display,
so the capture carried ANSI decoration around the `WARNING:` line.

**Why this is not the T036a / codepage family.** Those defects changed the script's characters, or
dropped them, after the script wrote them. This change sets the child host's rendering mode
before the script runs. No kit script authors ANSI itself: grep for `PSStyle`, `` `e[ `` and
`[char]27` over `scripts/*.ps1` finds nothing. So `PlainText` can suppress only host decoration,
never script-authored bytes. Nothing is stripped after capture: the harness does no ANSI
normalisation (`Harness.psm1` capture path, `ConvertTo-NormalisedOutput` unchanged).

**No other case moved.** No `expected.txt` in `cases/` contains an ESC byte (grep). The only
pre-existing expectation changed in `9ae7b53` is `AMEND-006/fail`, which is F6. There is no
stripping, so any case whose capture had carried escapes would already have failed.

`TERR-012` is the first case to assert a `Write-Warning`. That is true: the other `WARNING:`
expectations come from `enforcement-pack.ps1:1277`, which is `Write-Host "WARNING: $w"`. The
TERR-012 exemption is gone. The four remaining TERR exemptions now claim only `Write-Error`, which
matches `territory-check.ps1:36,46,57,64`.
*Action: none.*

### F4 — The OK-variant blind spot the implementer recorded is real, wider than recorded, and cheaply narrowable in Territory — NON-BLOCKING

I confirmed it by mutation. I added two early exits to the dispatch:
`Write-Host "enforcement-pack: OK"; exit 0` (double-quoted, exact) and
`Write-Host 'enforcement-pack: OK (hotfix lane, nothing graded)'; exit 0`. `Coverage.Tests.ps1`
stayed 11/11 green with the denominator unchanged at 200.

The precise idiom (`emission-idioms.json:49`,
`enforcement-pack: ('\$Branch' is|OK')`) needs a single quote right after `OK`. The recall sweep
looks only for failure words (`FAIL|ERROR`, failure-named accumulators). A success-shaped early
return is exactly GAP-027's shape, and it is structurally invisible to both passes. That makes
the notes' sentence "A new emission site added to any of the nine scripts fails the suite until
someone says, in writing, what it is" (`notes.md:2371-2372`) still false. The Coverage.Tests
comment "impossible to slip past" overclaims the same way.

This is not a regression: the idiom dates from phase 4. It is disclosed in the notes. And
fixtures still pin the real `OK` line through 49 expectations. So it is non-blocking. The narrow
fix is in Territory: widen the idiom to `OK\b` for either quote. Then the existing
`enforcement-pack: OK` notRules entry (siteCount 1) would fail on any second OK-shaped site. The
general case (any `Write-Host '<benign text>'; exit 0/return`) needs a success-shaped recall
pattern, or it should be recorded as a known limit.
*Action: implementer. Widen the enforcement-pack OK idiom (or record why not), and correct or
qualify the notes' universal. Owner: decide whether the structural limit gets a GAP row.*

### F5 — F6's new UNGRADED state on real repositories: acceptable and consistent — resolved, with one observation

I ran `enforcement-pack.ps1` in two simulated states.

- **Fresh `016-fresh` branch at the trunk, no specs:** it still FAILs on Structure, as before.
  The new `UNGRADED` line prints alongside. The verdict is unchanged (FAIL, exit 1).
- **Post-merge NNN branch** (specs present, no commits of its own): it moves from `OK` to
  `UNGRADED`, exit 0. That matches `scope-check`, which already said `UNGRADED` there.

Neither trunk runs nor Lite branches reach AmendmentAuthority (`:1071`). A `pull_request` CI run
grades a merge commit, so its range is non-empty. The kit's own branch at HEAD stays `OK`. So the
only newly-UNGRADED real state is the genuinely empty one, which is what FR-010 asks for. The
documentation gap is F1.
*Action: none beyond F1.*

### F6 — The T047 branch test guards `-Branch` only; other ref-naming arguments are unguarded — MINOR

`Harness.Tests.ps1:402` collects values that follow `-Branch` only. Cases also pass refs through
`-Commit` (`SCOPE-013`, `REPOS-017`), `-ReplayBase`/`-ReplayTip` (`AMEND-006`), and could pass
`-BaseBranch` (`territory-check.ps1:28`). A case passing `-ReplayBase 015-enforcement-assurance`
would pass this test and be host-dependent. Today every such value is `HEAD`, `HEAD~1`,
`no-such-ref` or `001-thing`, all fixture-local, so nothing is wrong now. The test's title
("names ... only branches that case's own fixture creates") promises more than it checks.
*Action: implementer, optional. Extend the scan to `-Commit`, `-ReplayBase`, `-ReplayTip` and
`-BaseBranch`, allowing `HEAD`-relative revisions and names the recipe creates, or narrow the
title to `-Branch`.*

### F7 — Stale present-tense claims left behind by the remediation — MINOR

- `emission-idioms.json:52` (enforcement-pack note): "FIVE OF THESE ARE DECLARED AND UNCOVERED ON
  PURPOSE". Of the five, three are now fixtured rules (AMEND-006, PACK-003, PACK-004) and two are
  notRules. The same note was edited in this commit to say the lanes are "both rules since phase
  6", which contradicts it.
- `notes.md:2354-2372` ("The coverage report now") still shows `189 of 200 ... 8 exempt, 3
  declared not a rule` and `territory-check.ps1 7 of 12 (5 exempt)`. HEAD reports `191 of 200 ...
  7 exempt, 2 declared not a rule` and `8 of 12 (4 exempt)`.
- `notes.md:2403-2412` (T047) still describes the host-substring test. The remediation section
  supersedes it, but the section heading reads as current.
- Presentation: the report's summary line says "2 declared not a rule" (precise-pass sites in the
  200) and the list below says "13 line(s) declared not a rule" (entries, mostly recall-sweep
  sites). Both numbers are accurate, but nothing tells a reader why they differ.

*Action: implementer. Annotate or correct these in the next commit; they ride along with F1.*

## Round-1 findings: disposition check

| Round-1 finding | Disposition claimed | Verified |
|---|---|---|
| F1 | Fixed | **Yes.** Green detached and on `main` in a scratch clone. The mutation is caught. Nothing is read from the host. (See this review's F6 for the scan's width.) |
| F2 | Fixed | **Yes.** All three guards fire (this review's F2). |
| F3 | Fixed | **Yes.** The pair discriminates on the knob. The `PlainText` change is legitimate and moved no other case (this review's F3). |
| F4 | Fixed | **Yes** for the unreadable-parent example. It is gone from all three documents, and the new header (`enforcement-pack.ps1:75-80`) matches the code: empty range → `$ungraded` at `:1099`; shallow, missing base and unparsed commit → `$script:failures`. The paragraph it sits in has a new false universal (this review's F1). |
| F5 | Fixed (owner) | **Yes.** PACK-004 exists and discriminates. The OK note now agrees with the entry. The count of 13 matches the report. |
| F6 | Fixed (owner) | **Yes.** Exit 0 is kept. AMEND-006 pins UNGRADED. No other fixture moved. Real-repo effect assessed in this review's F5. |
| F7 | Fixed | **Yes.** The T053 table cites runs 35547650371/35547650549 beside the parent's. |
| F8 | Deferred to owner / docs PR | **Consistent.** PR #49 (`docs/gap-029-territory-check`, `docs/roadmap.md` only) is OPEN and records GAP-029, including the CLEAN-over-skipped finding. It is not merged, so the TERR exemptions correctly still say "awaiting promotion". |
| F9 | Fixed | **Yes.** `review-process.md:59-61` no longer lists `UNGRADED` among the lawful verdicts. The listed causes (no diff base, empty range, missing history) match `scope-check.ps1:304,309` and `scope-check-repos.ps1:387,392`. |

## Amendments in this diff

- [x] **None.** `9ae7b53` does not touch `spec.md`, `plan.md` or `tasks.md`. The owner decisions
  (F5, F6, F8) are recorded in the round-1 Dispositions and in `notes.md`. None of them amends a
  feature document.

## Constitution re-check (post-implementation)

PASS on scope (Territory: `scope-check` PASS for both phase-6 commits), on amendment authority (no
amendment), and on D6 (no exit code moved; the F6 state exits 0, measured). F1 is a
prose-accuracy finding against the feature's own flow-down deliverable (T049). It is not a breach
of a constitutional principle.

## Test coverage observed

- **CI, `9ae7b53`**: 805 passed and 0 failed on ubuntu-latest and on windows-latest (run
  36213578783). That is up from 796 at `28a99fa`, by 9: the PACK-004 and TERR-012 pairs, plus the
  notRules test.
- **Coverage.Tests.ps1, scratch, HEAD**: 11/11. Report: `191 of 200 ... 7 exempt, 2 declared not a
  rule`. 13 notRules entries are printed with reasons, and 7 exemptions are printed grouped.
- **Mutations** (scratch, each reverted, `git status` clean after each): T047 foreign branch →
  FAIL; notRules new site → FAIL; empty reason → FAIL; short reason → FAIL; `originFetch`
  disabled → `TERR-012/fail` FAIL; `PlainText` removed → `TERR-012/fail` FAIL; docs-lane line
  deleted → `PACK-004/fail` FAIL; empty-range guard inverted → both AMEND-006 directions FAIL; F6
  reverted → `AMEND-006/fail` FAIL; OK-variant sites added → **green** (F4).
- **Full local harness: not run** in this round. I did not observe the transient
  SCOPE-013/TestDrive failure the brief mentions, and I make no claim about it.

## Residual risk

Low in the code. It sits in the adopter-facing note (F1): an adopter who sees `UNGRADED` on a
full-history checkout is told that cannot happen and is sent to fix `fetch-depth`. Fix F1 and this
phase is approvable. F4 is the one remaining way for coverage to read complete while a
success-shaped silent exit goes unseen. It is disclosed and narrowable, and it is worth closing
(or recording as a GAP) before 015 is called done.

---

## Dispositions (appended by the implementer — the reviewer's text above is unedited)

| Finding | Disposition | Where |
|---|---|---|
| F1 (BLOCKING) | **Fixed.** The universal is replaced with what the code does: with full history `UNGRADED` appears only on an `NNN-*` branch with no commits of its own (fresh or merged), where `scope-check` and the amendment check both say so. The remedy paragraph now splits the causes: a missing base or missing history → `fetch-depth: 0`; an empty commit range → no fetch setting changes it, and the word goes with the branch's first commit. | `adoption/updating.md`, 015 flow-down note, "What you will newly see" item 1 and "What to do about it" |
| F2 | No action (resolved). | — |
| F3 | No action (resolved). | — |
| F4 | **Fixed (the narrow case); general case recorded as a known limit.** The enforcement-pack `OK` idiom now ends on `\b`. Mutation: a double-quoted `"enforcement-pack: OK"` early exit and an `'enforcement-pack: OK (hotfix lane, nothing graded)'` early exit were added to the dispatch, and the notRules guard failed with "excuses 3 site(s) [enforcement-pack.ps1:1295, :1296, :1297], declared 1". Reverted. The recall sweep's comment and the notes' "A new emission site … fails the suite" universal are qualified: failure-shaped lines only. **Owner decision owed:** whether the structural limit (a success-shaped early exit in an idiom no precise pattern names) gets a roadmap GAP row. `docs/roadmap.md` is outside this Territory. | `tests/enforcement/emission-idioms.json:49` and its note; `tests/enforcement/Coverage.Tests.ps1` recall-sweep comment; `notes.md` |
| F5 | No action beyond F1. | — |
| F6 | **Fixed.** The test now scans `-Commit`, `-ReplayBase`, `-ReplayTip` and `-BaseBranch` as well as `-Branch`, and walks the whole recipe for created names. The four revision arguments may also carry a `HEAD`-relative revision or a deliberately absent `no-such-*` ref; `-Branch` gets neither allowance. The title now says "refs". Mutation: `AMEND-006/pass` with `-ReplayBase 015-enforcement-assurance` → the test fails naming the case, the argument and the fixture's branches. Reverted. | `tests/enforcement/Harness.Tests.ps1`, T047 describe |
| F7 | **Fixed.** `emission-idioms.json`'s "FIVE OF THESE ARE DECLARED AND UNCOVERED" now says what became of the five. The two superseded `notes.md` passages (coverage figures; T047's substring test) each carry a "Superseded" note rather than being rewritten. The report's notRules heading says why its count (13 entries) differs from the summary's (2 sites in the denominator). | `emission-idioms.json` note; `notes.md`; `Coverage.Tests.ps1` report |
