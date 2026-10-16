# AI Code Review — 030 claim-feature.ps1's ledger read and refused push are named states (phase 1)

**Reviewer**: fresh-context agent, Claude Sonnet 5.5 (claude-sonnet-5-5)
**Date**: 2026-10-16
**Branches**: repo `agentic-sdlc-kit` `030-claim-ledger-read-named-state` (phase 1 commit `772a93d`, parent `1d5914c`)
**Scope reviewed**: `git diff 1d5914c..772a93d`: `scripts/claim-feature.ps1`; `tests/enforcement/lib/FixtureRepo.psm1` (`originFailCall`, `originRivalOnPush`); `tests/enforcement/Harness.Tests.ps1`; fixtures `claim-feature/CLF-007..CLF-012`; `tests/enforcement/rules.json`; `notes.md` and the `tasks.md` ticks. Spec, plan (P1-P8) and tasks (phase 1, Territory) read as the contract. Not read: phase 2 (withdrawal, re-fetch, docs), the full harness (not run).
**Feature contract**: a failed ledger read and a rejected push (no rival) become named refusals; a successful claim and feature 023's seven refusals print the same bytes; no new package or script; Territory is `scripts/claim-feature.ps1` and `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5), the session that produced the diff
- **Inputs provided**: the phase 1 diff (`1d5914c..772a93d`), spec.md, plan.md, tasks.md, notes.md, `docs/sdlc/definition-of-done.md`, `docs/sdlc/review-process.md`, `specs/_templates/ai-code-review-template.md`, the 029 phase 1 review as a shape example. Ran: `-Case claim-feature` in a detached worktree at `772a93d` (124 passed, 0 failed); the same case in a detached worktree at `1d5914c` with the new tests/enforcement files copied over the unchanged parent script (110 passed, 14 failed, itemised below); one hand-built repro of a push that exits non-zero after landing (F1); `gh pr checks 92` for the CI record. Did not run the full harness, `scope-check.ps1`, or the mutation runs.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The script change is small and, on every path I traced, correct. `$script:LedgerReadFailed` is reset at the top of `Get-RemoteFeatureHeads`, set only on a non-zero `ls-remote`, and read immediately after each of the three calls (lines 113-114, 144-150, 174-177), so the empty-ledger and failed-read states are told apart. The race loop follows plan P3. The fixtures are real: on the parent script the seven `fail` fixtures are red for the stated reasons, and the pairs differ in one condition. The follow-ups are one message that can state something false (F1), an unchecked withdrawal that phase 1's new wording leans on (F2), and notes/test-honesty items (F3-F6). None is a defect in the success path. Residual risk sits in F1 and in the Linux/Windows behaviour of the two shell wrappers, which I could confirm only from CI (Linux) and my own Windows run.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| (a) States of a failed or empty `ls-remote` | `Get-RemoteFeatureHeads` has exactly three callers (grep): lines 113, 144, 174 at `772a93d`. Each wraps the call in `@(...)` and reads the flag on the very next statement; the function sets the flag to `$false` on entry, so a successful call after a failed one cannot inherit it. A successful empty ledger returns `$names` empty, flag `$false`: allocation proceeds (CLF-008/pass uses an empty-ledger origin). Failure in the exit-0-but-no-output case does not exist (a zero exit with no lines is a valid empty read). No path reads a failure as an empty ledger. |
| (b) Decision table vs plan P3 | Read lines 137-160. push ok + no rival = success (153); push failed + no rival = refused once (157); rival with any push result = warning, withdrawal only if the push landed, renumber (160-185); ledger unreadable: pushOk -> "may already be live" (148), failed -> rejection + "ledger could not be read either" (149). Rows match P3 and spec scenarios. Gap: push failed but landed, see F1. |
| (c) Wording vs plan P2 | Rows 1, 2, 3 are byte-equal to P2 (CLF-008/009/010 expected.txt written by hand, matched by the run). Row 5 deviates in layout only: plan reads `rejected: <git's text>. Nothing was claimed; ...`, the script prints `rejected:` + newline + git's text + newline + `Nothing was claimed; ...`, as notes deviation 1 says. The added closing sentence (check origin) is the plan's own Risks sentence, as notes deviation 2 says; it is in the message of every rejected-push refusal and so inside CLF-010/012 expected text. Row 4 has the second wording `never reached origin` (line 170 in the current tree, `$gone`), as notes deviation 3 says, with its own fixture `CLF-011/fail-unpushed`. All three deviations are as described; none is recorded as a plan amendment, which is consistent with "second wording, not amended" but see F5. |
| (d) Fixtures fail on the parent for the stated reason | Ran `claim-feature` at `1d5914c` with the new fixtures and harness copied in and the parent script unchanged: failures are exactly CLF-008/fail, CLF-009/fail, CLF-010/fail, CLF-010/pass, CLF-011/fail, CLF-011/fail-unpushed, CLF-012/fail (7 fixtures, 12 assertions) plus the two rule-inventory tests (anchors absent from the parent script): 14 failed. CLF-008/009/011-pass, CLF-012/pass and the CLF-007 pair pass on the parent, as notes claim. CLF-010/pass fails on the parent because the parent printed three warnings and the three-times refusal for that state. Pair diffs (`diff` of recipe.json, CR stripped): 008, 009, 010, 011 differ only in `originFailCall` (N vs 99; description line aside); 012 only in `originPushUrl`; 007 only in `originRivalOnPush`. `fail-unpushed` differs from `fail` only in `originPushUrl`. Expectations reasoned by hand against the call order (first fetch 1, first read 2, read after push 3, re-fetch 4, re-read 5); all agree with the script. |
| (e) Recipe fields | Both refused without `origin` (`FixtureRepo.psm1` guards before building); `originFailCall` refused for 0, -1, `'two'` (self-test; 1.5 or `true` also fail the `-is [int]` test by reading). Self-tests also pin: Nth read fails and no other (`0,128,0`), a push is not counted, working tree clean, nothing configured when not asked, rival only for numbered branches and not rivals. Wrappers live under `.git/` (tree stays clean; a clean-tree claim ran). Counter file starts absent and is created by the wrapper. Windows: ran green here. Linux: the ubuntu `enforcement-tests` jobs on PR #92 (runs 38845755277 and 38845750502) passed; the windows jobs were still pending when I looked. Quoting: wrapper path is single-quoted into `sh '<path>'`, so spaces are safe on both; an apostrophe in the temp path would break it (F6, reasoning only). |
| (f) Success paths and 023's refusals | Diff touches only failure branches and the ledger helper; the push call's output was `Out-Null` before and is captured into `$pushText` now, never printed on success. `-Case claim-feature` 124 passed, 0 failed at `772a93d`, including CLF-001..006 and every `pass` fixture unchanged. `Stop-Refused` writes to the error stream and prints no object under `-Json`; all new refusals go through it. |
| (g) CLF-007 and CLF-012 sites; rules.json | CLF-007/fail expected shows two `claimed concurrently (00N-rival)` warnings, two `Renumbered:` lines and `Lost the allocation race 3 times`: the three-attempt site is reached through a real rival after each push. It passes on the parent too (the behaviour is unchanged), so it proves reachability, not new behaviour. The withdrawals it implies are not asserted (F4). CLF-012/fail reaches `Stop-Refused "$rejection"`. Anchors are present in the script (the two inventory tests pass at `772a93d`, fail on the parent only because the anchors do not exist there). The ` The ledger could not be read either.` anchor has a leading space and matches the single emission site. |
| (h) Scope | `git diff --stat`: 42 files; script, `tests/**`, plus `specs/030-.../notes.md` and `tasks.md` ticks. Nothing outside the phase 1 Territory (notes/tasks are the feature's own documents). Lines for the withdrawal and the re-fetch are untouched at `772a93d` as the plan requires. `scope-check.ps1` not run by me. |
| (i) notes.md claims | "124 passed" and the T001/T002 baselines for the parent: 124 reproduced; the parent-side claims are consistent with my 14 failures. Not measured by me or not measured at all: "12 of 15 sites fixtured" (coverage report, not run), "`-Json` keeps the refusal on the error stream" (read, not run), the Linux run ("exercised by CI on the PR": passed, see (e)). The `Numbers` section is explicitly unfilled and T007 is unticked, correctly. |
| Rollback | One script and test files; reverts cleanly; phase 2 depends on this phase. |

## Findings

### F1 — A push that exits non-zero but landed is reported as "Nothing was claimed" although the script has just read the proof — CONFIRM (not blocking)

`scripts/claim-feature.ps1:157` (`$rejection`, line 139): when `git push` fails and there is no rival, the script refuses with `git push of <b> was rejected: ... Nothing was claimed`. But the script has just read the ledger into `$ledger` and can tell whether `$branch` is in it. Reproduced: a `receive-pack` wrapper that runs the real `git-receive-pack` and then `exit 1` (a push that lands but reports failure) gives: `git push of 001-probe was rejected: ... * [new branch] 001-probe -> 001-probe ... Nothing was claimed; ...`, exit 1, while `git ls-remote --heads origin` lists `refs/heads/001-probe`. The text says "rejected" and "Nothing was claimed" for a claim that is live on origin, with a hedge sentence the reader has to act on. Plan Risks admits the case and the spec lists it out of scope, so this is consistent with the contract; but it is the same kind of state the feature exists to name (the CLF-009 refusal says "may already be live"), and the information is already in hand. Cheap fix inside this phase: if `$ledger -contains $branch` on a failed push, say so instead.
*Action: owner decides: accept as the plan's recorded risk (the hedge is there), or have the implementer branch on `$ledger -contains $branch` with a P2-style wording and a fixture (a receive-pack wrapper like the one above).*

### F2 — Phase 1 asserts "was withdrawn from origin" while the withdrawal is still unchecked — CONFIRM (not blocking)

`scripts/claim-feature.ps1` at `772a93d`, the `$gone` text on the re-read refusal (`"$branch was withdrawn from origin"` when `$pushOk`) follows `if ($pushOk) { git push origin --delete $branch 2>$null | Out-Null }`, whose exit code nobody reads in this phase (plan P4 defers it to phase 2). If the delete fails, phase 1 prints a statement of fact that is false, and CLF-011/fail cannot catch it because no fixture asserts origin's state after the run. Phase 2's check closes it, and phase 2 is in this PR, but plan says phase 1 is "useful alone" and "independently revertible"; reverting phase 2 alone would leave this claim unbacked.
*Action: owner: accept because phase 2 lands with it (and say so), or soften phase 1's wording to "was pushed and a withdrawal was attempted". Reviewer of phase 2 should confirm the unchecked delete is gone.*

### F3 — CLF-010/pass duplicates CLF-012/fail byte for byte — MINOR

`CLF-010/pass/expected.txt` equals `CLF-012/fail/expected.txt` and the recipes differ only by `originFailCall: 99` (a never-reached value). The pair is valid, and notes/rules.json say a pass for CLF-010 exits 1 because it is "the rule not firing"; still, two rules guard one printed state, so a regression of the rejected-push text trips both and one of them (CLF-010/pass) says nothing about the unreadable-ledger rule. Not a blind path.
*Action: none required; optionally note the duplication in CLF-010's rules.json `notes`.*

### F4 — No fixture asserts the withdrawals CLF-007 and CLF-011 claim — MINOR

CLF-007's description and rules.json notes say "withdraws its own branch each time"; CLF-011/fail says "withdrawn". The harness compares output and exit code only, so these are not measured by the fixtures; they rest on the script reading and on the notes' hand run (the `pwsh -File` states in notes are only those of T001). The output text alone would be identical if the delete were removed.
*Action: none for the phase (harness limit); reword the descriptions to say what is measured, or add an origin-state assertion in a later phase.*

### F5 — Three recorded deviations from approved P2 are outside the plan, with no approver — CONFIRM (not blocking)

Notes deviations 1 (multi-line layout), 2 (closing sentence in every rejected-push message) and 3 (the `never reached origin` wording of row 4) change text plan P2 said the fixtures would pin "byte for byte". They are disclosed and match what I read, and the owner told in the plan that wording was "worth a look before approving". Constitution I says an amendment to the plan needs a recorded approver and the implementer cannot approve its own; the notes explicitly say "not amended into the plan". As written, the plan and the pinned fixtures disagree.
*Action: owner: approve the three wordings (in plan.md as an amendment with `Amendment approved by`) or ask for the plan wording to be restored.*

### F6 — Wrapper path quoting and line endings — MINOR (reasoning-only for the quoting point)

`FixtureRepo.psm1`: the config value is `sh '<path>'`; a path containing an apostrophe (e.g. a Windows user profile `O'Brien`) breaks the quoting and every `originFailCall`/`originRivalOnPush` fixture would fail with a confusing error. Spaces are fine. Not run. Separately, `git ls-files --eol` shows the committed `CLF-007/{fail,pass}/recipe.json` and `CLF-008/fail/recipe.json` as `i/mixed`, and the CLF-007 pass recipe diff rewrites every line (CRLF to LF) for a one-line change, so the real change is hard to see in review.
*Action: implementer: normalise to one line ending and (optionally) refuse an apostrophe in the fixture path with a clear message; neither blocks.*

## Amendments in this diff

- [x] **None** to `spec.md`, `plan.md` or `tasks.md` beyond ticking T001-T006 in tasks.md (T007 correctly left open). The three wording deviations are recorded in notes.md only (see F5).

## Constitution re-check (post-implementation)

PASS. The change stays inside the plan's approved architecture, adds no package or file, keeps `-Json` refusals object-free, and reaches the refusals through the existing `Stop-Refused`. Constitution I (amendment authority) is engaged by F5.

## Test coverage observed

`-Case claim-feature` at `772a93d`: 124 passed, 0 failed (includes the harness self-tests for both recipe fields). New fixtures: CLF-008, 009, 010, 012 pairs; CLF-011 `fail`, `pass` and `fail-unpushed`; CLF-007 rebuilt through `originRivalOnPush`. Critical assertions: first read fails -> own refusal, exit 1 (not 128); read fails after a landed push -> "may already be live"; rejected push + unreadable ledger -> rejection plus noted; lost race + unreadable re-read -> names what is and is not on origin; rejected push alone -> once, no warning, no renumbering. At the parent script the same fixtures produce 14 failures (7 fixtures plus 2 inventory tests), confirming each measures a change.

## Residual risk

Low in the code. It concentrates in F1 (a landed-but-failed push still prints "Nothing was claimed") and F2 (a "withdrawn" statement that phase 1 does not back), and in untested environments for the shell wrappers (Linux covered only by CI; Windows windows-latest job pending when I looked). T007 and the full-harness numbers are still owed; the implementer must not claim success. Merge after the owner decides F1, F2 and F5 and the user-run gate exit code is recorded.
