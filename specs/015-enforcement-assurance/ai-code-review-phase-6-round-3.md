# AI Code Review — 015 Enforcement Assurance, Phase 6 (round 3)

**Reviewer**: fresh-context agent — claude-opus-5-5
**Date**: 2026-09-26
**Branches**: agentic-sdlc-kit `015-enforcement-assurance` (tip `a885790`, parent `9ae7b53`)
**Scope reviewed**: the whole of `a885790` (6 files), judged against the phase as it now stands
(`git diff 1f05bb3 a885790`, 39 files). Read in full for this round: the 015 flow-down note and the
amendment-check section above it in `adoption/updating.md`; `docs/sdlc/review-process.md` step 3;
`tests/enforcement/emission-idioms.json` (enforcement-pack entry); the recall sweep, the `notRules`
guard and the report in `tests/enforcement/Coverage.Tests.ps1`; the T047 describe in
`tests/enforcement/Harness.Tests.ps1`; the round-2 remediation section and the two "Superseded"
notes in `specs/015-enforcement-assurance/notes.md`. Also read, not changed by this commit: every
`UNGRADED` emission site in `scripts/scope-check.ps1` (`:278`, `:304`, `:309`, `:323`),
`scripts/scope-check-repos.ps1` (`:328`, `:387`, `:392`, `:415`) and `scripts/enforcement-pack.ps1`
(`:586`, `:628`, `:679`, `:1099`, `:1266`), both scripts' `Get-DiffBase`, the wrapper's
precedence in `scripts/ritual-checks.ps1`, and the fixtures `REPOS-011`, `REPOS-012`, `REPOS-014`
and `REPOS-032`.
**Feature contract**: phase 6 = T044–T053. Territory is `tests/**`,
`.github/workflows/enforcement-tests.yml`, `scripts/enforcement-pack.ps1`, `adoption/updating.md`,
`docs/sdlc/review-process.md`, `docs/digests/*-digest.md` and the feature directory. Plan D6 holds:
`UNGRADED` never moves an exit code. `**Gate Certification**: ci-held`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: Claude Opus 5.5, the implementing session that wrote `a885790`. The commit's
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` trailer names it. It is not this
  reviewer.
- **Inputs provided**: `git show a885790`; `git diff 1f05bb3 a885790`; the round-2 review with the
  implementer's Dispositions table (`ai-code-review-phase-6-round-2.md`); the round-1 review
  (`ai-code-review-phase-6.md`); `specs/015-enforcement-assurance/{spec,plan,tasks,notes}.md`;
  `CLAUDE.md`; `.specify/memory/constitution.md`; `docs/sdlc/definition-of-done.md`;
  `docs/sdlc/review-process.md`; `specs/_templates/ai-code-review-template.md`. Tools: `gh run
  list` / `gh run view` for runs on `a885790`; `scope-check.ps1` and `ritual-checks.ps1` at HEAD
  in the main tree. In a scratch clone of `a885790`: the Coverage suite at HEAD; seven OK-variant
  mutations of `enforcement-pack.ps1`; the T047 describe detached and on a local `main`; four
  T047 mutations; `scope-check.ps1` and `enforcement-pack.ps1` against two hand-built full-history
  fixture repositories.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES.** F4, F6 and F7 are fixed as claimed, and I proved each by running it:

- **F4.** A double-quoted `OK` fails the Coverage suite, and so do an `'OK (reason)'` line and an
  `OK - …` early exit. The denominator stays at 200.
- **F6.** The T047 describe is green detached and on `main`. It catches a foreign `-ReplayTip`.
- **F7.** The numbers match what the report prints at HEAD.

**F1 is not fixed.** The round-2 finding was a false universal in the adopter-facing flow-down
note. The remediation replaced it with a narrower universal, and that one is also false. The new
text says: "With full history you will see it only where there is genuinely nothing to grade: an
`NNN-*` branch with no commits of its own yet (or one already merged) … Everywhere else a
full-history checkout does not produce it." I found two ordinary full-history states that produce
`UNGRADED`:

- **A numbered branch that has only spec/plan/tasks commits.** Every feature branch is in this
  state from `/speckit.specify` until phase 1 is committed.
- **Every multi-repo governance repository's CI.** The kit's own fixture `REPOS-011` describes it
  as "what CI for the governance repository actually looks like". A phase that touches no code
  repository lands here too.

Both states have commits of their own. The note's remedy sentence also fails the first state: "the
word goes away with its first commit". In fact it survives every commit until the first **phase**
commit. The note also contradicts itself. Its first sentence ("Only in the states listed above")
points to a list that names "a trunk not named `main`" and "a branch every one of whose commits
was skipped", and both of those occur with full history. This is the defect this feature keeps
producing: prose that claims a property the code does not have. The fix is prose only.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match | **F4**: the OK idiom is now `Write-Host\s+['"]enforcement-pack: ('\$Branch' is\|OK\b)` (`emission-idioms.json:49`). I injected one-line early exits before the trunk dispatch in `enforcement-pack.ps1`, one at a time, and ran `Coverage.Tests.ps1`. `Write-Host "enforcement-pack: OK"; exit 0`, `Write-Host 'enforcement-pack: OK (hotfix lane, nothing graded)'` and `Write-Host "enforcement-pack: OK - nothing graded"` each failed the `notRules` test with "excuses 2 site(s) [enforcement-pack.ps1:1249, enforcement-pack.ps1:1296], declared 1" (10 passed / 1 failed). The summary moved to 201 sites / 3 not-a-rule, which shows the site entered the denominator. Four exits stayed green, 11/11: `'enforcement-pack: OKAY'`, `Write-Host -Object '…: OK'`, `Write-Output '…: OK'` and `'enforcement-pack: all clear'`. All four are exactly the recorded known limit ("a success-shaped early exit in an idiom no precise pattern names"), so that recording is honest. `\b` cannot widen into other lines: the idiom list is per-script, and the only `Write-Host '…enforcement-pack: …'` lines in the script are `:1232` (preamble; the idiom doesn't match it), `:1250`/`:1272` (lanes; already matched) and `:1283`/`:1292`/`:1295`. Only `:1295` matches the OK branch. Denominator at HEAD: 200, unchanged. **F6**: the T047 describe is 3/3 on a detached `HEAD` and 3/3 on a local branch `main`. Mutations: `AMEND-006/fail -ReplayTip 015-enforcement-assurance` fails ("passes -ReplayTip '015-enforcement-assurance', which its fixture never creates (it creates: 001-thing, main)"). `SCOPE-013/pass -Commit main` passes, which is correct because that fixture creates `main`. `-Commit no-such-015-enforcement-assurance` passes (the allowance; see F3). `REPOS-017/pass … -BaseRef 015-enforcement-assurance` **passes**, because `-BaseRef` is not scanned (F3). |
| Visual-reference match | N/A — no UI. |
| Feature contract held | No package, no workflow change, no script change in `a885790`. All 6 files are inside the phase-6 Territory or the feature directory. |
| Constitution / domain invariants | `spec.md`, `plan.md` and `tasks.md` are untouched by `a885790`, so there is no amendment. The implementer records one owner decision as owed: whether the success-shaped blind spot gets a roadmap GAP row. `docs/roadmap.md` is outside this Territory, so recording it as owed is correct. |
| Security | N/A — tests and prose. |
| Scope guard | `pwsh -File scripts/scope-check.ps1` → `scope-check: PASS phase 6 commit a885790 (6 file(s))`, exit 0. |
| Whole-run verdict | `pwsh -File scripts/ritual-checks.ps1` at HEAD → `RESULT OK`, exit 0. doc-lint, enforcement-pack, scope-check, digests and roadmap-claims are OK. scope-repos and verify-kit are `n/a`. |
| Coverage report at HEAD | `191 of 200 declared emission site(s) owned by a fixtured rule, 7 exempt, 2 declared not a rule`. `enforcement-pack.ps1 51 of 54 (1 exempt, 2 not a rule)`. `territory-check.ps1 8 of 12 (4 exempt)`. `13 line(s) declared not a rule … (the summary above counts only the 2 of them in the denominator; the rest are recall-sweep sites)`. These are exactly the figures in `notes.md`'s new "Superseded" note and in the F7 disposition. |
| CI | See "Test coverage observed". |
| Rollback safety | Reverts cleanly. The only non-prose changes are a test pattern and a test's scan width. |

## Findings

### F1 — The flow-down note's replacement universal is also false: two common full-history states produce `UNGRADED`, and the remedy sentence mis-states when the word goes away — BLOCKING

`adoption/updating.md`, 015 flow-down note, "What you will newly see" item 1 now reads: "With full
history you will see it only where there is genuinely nothing to grade: an `NNN-*` branch with no
commits of its own yet (or one already merged), where `scope-check` and the amendment check both
say so. Everywhere else a full-history checkout does not produce it." The "What to do about it"
paragraph adds: "When it names an empty commit range … the word goes away with its first commit."

I measured these, all with full history:

1. **Spec-only numbered branch.** This is a single-repo fixture: `main` plus `001-thing` carrying
   one commit, `spec: 001 thing`. `scope-check.ps1 -All -Branch 001-thing` prints `not applicable
   (commit 8d2a99b carries no 'phase N' token - not a phase commit)`, then `scope-check: UNGRADED no
   commit on '001-thing' was graded - the reason is on the line(s) above`, and exits 0. The code
   path is `scope-check.ps1:323` (`$script:gradedCommits -eq 0`). The same happens on any branch
   whose commits all carry the pre-006 `WARN`. This branch has commits of its own, and it is not
   empty or merged. The first commit does not clear the word; only the first `phase N` commit does.
   The amendment check does **not** "say so" here, because it grades the non-empty range. Every
   numbered branch passes through this state between `/speckit.specify` and phase 1.
2. **Multi-repo governance repository in CI, or a phase that touches no code repository.** The
   kit pins this in its own fixtures:
   - `REPOS-011/fail`: "a governance-only checkout, which is what CI for the governance repository
     actually looks like". Output: `code-repo: n/a (declared but not present here …)`, then
     `scope-repos: UNGRADED (nothing was graded in the declared code repositories for '001-thing'
     …)`.
   - `REPOS-014/fail`: a code repository with no feature branch, i.e. a phase or feature that
     touches no code repository. Same run-level `UNGRADED`.
   - `REPOS-032/fail`: both at once.

   The fixture repositories have full history. The wrapper ranks `UNGRADED` above `n/a`
   (`ritual-checks.ps1:213-215`), so an adopter such as FitForge sees `scope-repos UNGRADED` on
   every numbered-branch run of its governance CI. The note says that cannot happen.
3. **Trunk not named `main`.** A fixture with trunk `master` and branch `001-thing` carrying
   `phase 1: thing` prints `scope-check: UNGRADED could not resolve a merge base with main -
   nothing checked`. `enforcement-pack.ps1` on the same fixture prints `UNGRADED: ReviewProvenance:
   no diff base …` and `UNGRADED: PhaseSizeWarning: …`. Both scripts' `Get-DiffBase` try only
   `origin/main` and `main`. The note's own first list names this state ("a trunk not named
   `main`"), so item 1 contradicts the sentence right before it. This member line also "names a
   missing base", so the remedy paragraph sends the adopter to `fetch-depth: 0`, which does not
   fix it. That is round-2 F1's misdirection again, in a narrower case.

This is the same species as round 2's F1 and as round 1's F4: a general sentence written about
the case the author had in mind, not about the emission sites. The measurement needed to check it
is to list the `UNGRADED` sites (13 across three scripts) and ask of each whether full history
makes it unreachable. Most of them are still reachable.

*Action: implementer. Rewrite item 1 and the remedy paragraph from the emission sites, not from
the cause the author had in mind. Name the full-history states: no phase commit yet (every commit
skipped: spec/plan/tasks-only or pre-006); an empty or merged range; a multi-repo governance
checkout, or a phase that touches no code repository (`scope-repos`); a trunk not named `main`.
Give a remedy per state. Two cases need their own remedy: for the trunk case, `fetch-depth: 0`
does not help (the governance repository's trunk must be `main`); for the spec-only case, the word
goes with the first phase commit, not the first commit. Alternatively, drop the universal and
point at the member's own reason line, which already says what it could not grade. Either way,
the text should promise nothing the scripts do not do. Prose only; no script change is needed.*

### F2 — `review-process.md` step 3 now contradicts itself for a phase that touches no code repository — NON-BLOCKING

Step 3 still says that `n/a`, `not applicable` and `WARN` "are the cross-repo check's lawful
non-blocking verdicts, and a phase that touches no code repository legitimately produces one".
Phase 6 added the next paragraph directly below it: "`UNGRADED` is not a pass … **a review that
accepts one says in writing why**." For a phase that touches no code repository, the run-level
verdict is `UNGRADED`, not `n/a` (fixtures `REPOS-014` and `REPOS-032`, code path
`scope-check-repos.ps1:415`). So a multi-repo reviewer is told this is legitimate, and in the next
breath is told a written justification is owed. The first sentence became stale when phase 5
turned this run-level line from `n/a` to `UNGRADED`. Phase 6 edited the paragraph and did not
reconcile the two. It is the same underlying gap as F1, seen from the reviewer's side.

*Action: implementer, together with F1. Either say that a phase touching no code repository
produces a per-repository `not applicable` and a run-level `UNGRADED`, and that the written reason
is one line naming that fact; or have the owner decide that this state should print `n/a`. That
second option is a script change and a later feature's question. Prose fix only in this phase.*

### F3 — The T047 ref scan's comment says "every ref-naming value", but `-BaseRef` is not scanned — NON-BLOCKING

`scope-check-repos.ps1` takes `-BaseRef <ref>`, which names the trunk in the nested repository.
The T047 test scans `-Branch`, `-Commit`, `-ReplayBase`, `-ReplayTip` and `-BaseBranch`. I
listed the parameters of all nine grading scripts, and `-BaseRef` is the only ref-naming
parameter missing. Mutation: `REPOS-017/pass` with `-BaseRef 015-enforcement-assurance` appended
stays green (1 passed). No case passes `-BaseRef` today, so the host dependence is latent. The
comment ("every ref-naming value is, as a whole value, a branch the case's recipe creates") and
the notes' Superseded paragraph (which lists the five arguments as though complete) overstate it.

The allowances are not a loophole. `HEAD` / `HEAD~n` / `HEAD^n` resolve in the fixture repository
the child runs in, not in the host. A `no-such-*` value can only matter if the host has such a
ref, and the scripts never read the host. Those two allowances are sound.

*Action: implementer. Add `-BaseRef` to `$revisionArgs` (the HEAD / no-such allowances are fine
for it), or narrow the comment to the arguments actually scanned. One line either way.*

### F4 — `notes.md` carries two literal backspace characters where `\b` was meant — MINOR

`notes.md:2381` ("the enforcement-pack `OK` idiom now ends on `^H`") and `:2555` ("It now ends on
`^H`"): `cat -A` shows byte 0x08 inside the code spans. The `\b` was interpreted as an escape when
the text was written. The text renders as an empty code span, so the note never states the fix it
describes. The JSON note, the Coverage comment and the Dispositions table spell `\b` correctly.
`git grep` finds the same control byte in `specs/014-amendment-authority/notes.md`, so this has
happened before. doc-lint does not catch control characters.

*Action: implementer. Replace both bytes with `\b`. Optionally, a later feature could add a
control-character check to doc-lint; that is not this phase.*

## Round-2 dispositions, verified

| Finding | Claimed | Verified? |
|---|---|---|
| F1 (BLOCKING) | Fixed | **No.** The replacement sentence is still a false universal, and the remedy is wrong for the spec-only and trunk cases (this review's F1). |
| F2 | No action | Correct. The guards still fire: the F4 mutations tripped the `siteCount` guard. |
| F3 | No action | Correct. Nothing in `a885790` touches `RunChild.ps1`. |
| F4 | Fixed (narrow); known limit recorded | **Yes.** The three OK-shaped variants fail the suite, the denominator is unchanged, and the four escapes are exactly the recorded limit. Owner decision on a GAP row is correctly recorded as owed. |
| F5 | No action beyond F1 | Carried into this review's F1. |
| F6 | Fixed | **Yes**, for the four arguments named. It is host-independent (detached and `main`) and catches a foreign `-ReplayTip`. One ref parameter was missed (this review's F3). |
| F7 | Fixed | **Yes.** The coverage figures, the per-script lines, the 13-vs-2 heading and the rewritten "FIVE OF THESE" passage all match the report at HEAD and the fixtured rules (AMEND-006, PACK-003, PACK-004). |

## Amendments in this diff

- [x] **None.** `a885790` does not touch `spec.md`, `plan.md`, `tasks.md` or `contracts/`.

## Constitution re-check (post-implementation)

**PASS, except F1.**

- **I (amendment authority)**: no amendment made.
- **II (source of truth)**: F1 and F2 are adopter- and reviewer-facing documents asserting what
  the scripts do. Where they disagree with the code, the code is what runs. That is the reason F1
  blocks: `adoption/updating.md` is what an adopter reads to decide whether an `UNGRADED` is worth
  chasing.
- **X / D6**: no exit code moved; `a885790` changes no script.
- **Territory**: all six files are inside the phase-6 Territory.

## Test coverage observed

- **Coverage.Tests.ps1** at HEAD: 11/11 in the scratch clone. The seven mutations are listed
  above.
- **T047 describe**: 3/3 detached, 3/3 on `main`.
- **CI on `a885790`**:
  - ritual-checks run 36217260684: **success**.
  - enforcement-tests run 36217260681: **success**. ubuntu-latest: `Tests Passed: 805, Failed: 0`
    (225.3s, completed 04:19:12Z). windows-latest: `Tests Passed: 805, Failed: 0` (772.3s,
    completed 04:28:30Z). Both are `push` runs on the branch, sha `a885790`.

I did not re-run the full 805-case suite locally. The phase-6 fixtures are unchanged by
`a885790`.

## Residual risk

The code is in good shape. Every mechanical fix this round claims, I proved by mutation. The risk
is where it was in round 2: the adopter-facing note. A FitForge developer who opens a new feature
branch, or who looks at governance CI on any numbered branch, sees `UNGRADED`. The note says that
cannot happen with full history and suggests `fetch-depth: 0`. Fixing F1 is a paragraph rewrite
from the 13 emission sites. F2 and F3 are one-liners that can ride with it, and F4 is a two-byte
fix. After that I would expect to approve.

---

## Dispositions (appended by the implementer — the reviewer's text above is unedited)

| Finding | Disposition | Where |
|---|---|---|
| F1 (BLOCKING) | **Fixed by rebuilding, not patching.** "What to do about it" is now a table of five states derived from the thirteen `UNGRADED` sites across `scope-check.ps1`, `scope-check-repos.ps1` and `enforcement-pack.ps1`. Each row gives the member line, whether full history fixes it, and the remedy. Spec-only commits, governance CI / code-free phases, and a trunk not named `main` are rows; `fetch-depth: 0` is offered for the shallow-clone cause only. Item 1 of "What you will newly see" no longer states a universal; it points to the table. | `adoption/updating.md`, 015 flow-down note |
| F2 | **Fixed.** Step 3 now says a code-free phase (and every governance-repository CI run) gets per-repository `not applicable` and a run-level `UNGRADED`, and that the written-reason rule applies. | `docs/sdlc/review-process.md` step 3 |
| F3 | **Fixed.** `-BaseRef` added. The list was checked against every ref-naming `[string]` parameter in the graded scripts' `param` blocks. Mutation: `REPOS-017/pass` + `-BaseRef 015-enforcement-assurance` → the test fails naming it; reverted. | `tests/enforcement/Harness.Tests.ps1` |
| F4 | **Fixed in 015; 014 left alone.** Both 0x08 bytes in `notes.md` replaced with a literal backslash-b; no other 0x08 in the phase-6 Territory or the feature directory. `specs/014-amendment-authority/notes.md` is outside this Territory. | `specs/015-enforcement-assurance/notes.md` |
