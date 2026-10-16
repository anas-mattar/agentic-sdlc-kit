# AI Code Review — 030 claim-feature.ps1 ledger read and refused push named states (phase 2)

**Reviewer**: fresh-context agent, Claude Sonnet 5.5 (claude-sonnet-5-5)
**Date**: 2026-10-16
**Branches**: repo `agentic-sdlc-kit` `030-claim-ledger-read-named-state` (phase 2 commits `53af25d`, `0e1d252`; tip `0e1d252`; base `a42b053`)
**Scope reviewed**: `git diff a42b053..0e1d252` (`scripts/claim-feature.ps1` race loop; `tests/enforcement/lib/FixtureRepo.psm1` and its self-tests; fixtures `CLF-013/{fail,pass}`, `CLF-014/{fail,pass,fail-unpushed}`, `CLF-011/fail-unpushed`; `tests/enforcement/rules.json`; `adoption/updating.md`; `docs/roadmap.md`; `docs/digests/adoption-digest.md`; `tasks.md` ticks); spec.md, plan.md, tasks.md, notes.md of the feature; definition-of-done, review-process, the AI review template, the 029 phase 1 review; feature 023/029 flow-down notes. Not read: the full harness (not run), the measurement's raw outputs (not in the repo).
**Feature contract**: a failed withdrawal and a failed re-fetch in the race loop are named refusals (exit 1); a successful claim and feature 023's seven refusals print what they printed; adopters are told what flows down; no new package or script; phase 2 Territory is `scripts/claim-feature.ps1`, `tests/**`, `adoption/updating.md`, `docs/roadmap.md`, `docs/digests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5), the session that produced the diff
- **Inputs provided**: phase 2 diff (`a42b053..0e1d252`), spec.md, plan.md, tasks.md, notes.md, definition-of-done, review-process, AI review template, 029 phase 1 review, feature 023/029 flow-down notes, build-digests.ps1 and digest-packs.json; runs in detached worktrees (below)
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The code change is small, correct and well fixtured: the withdrawal check, then the MaxAttempts check, then the re-fetch check, then the ledger re-read, in that order; each refusal is reached by a fixture whose pass twin differs in exactly one condition; and every fail fails on the phase 1 script for the stated reason. I found no code defect, no unowned message site, and no change to a successful claim or to the seven refusals of feature 023. The follow-ups are all in the adopter-facing and status text: the flow-down note and the roadmap say a measurement was run and "every line that changed is listed in the notes of feature 030", but `notes.md` holds no phase 2 section and no measurement at all (F1); the note says feature 023's note "is not edited" while one of its digest markers was deleted, undisclosed (F2); and the roadmap row reads `shipped` with T011, T014 and T015 still open (F3). None changes behaviour; F1 should be fixed before merge because it is an adopter-facing claim with no record behind it.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | `scripts/claim-feature.ps1:160-178` read. `git push origin --delete $branch 2>$null \| Out-Null` is followed in the next statement by `if ($LASTEXITCODE -ne 0)` (the pipe ends in `Out-Null`, a cmdlet, which leaves `$LASTEXITCODE` as git's). The withdrawal check precedes the MaxAttempts check, so a failed withdrawal on the last attempt is named instead of the three-times text. `$gone` is computed after the MaxAttempts check from `$pushOk`: with a push that landed and was withdrawn it reads "was withdrawn from origin", with a rejected push and a rival it reads "never reached origin" (no deletion is attempted when `$pushOk` is false: `if ($pushOk)` guards it). The re-fetch's `$LASTEXITCODE` is read on the line after the call; the re-read's `$script:LedgerReadFailed` follows. Rejected push with a rival falls past the `-not $pushOk -and $rivals.Count -eq 0` refusal, warns, skips the withdrawal, and renumbers (fixtured: CLF-014/fail-unpushed). |
| Visual-reference match | N/A: no UI. |
| Feature contract held | No new package, no new script file. Territory check: `git diff --name-only a42b053..0e1d252` lies in `scripts/claim-feature.ps1`, `tests/**`, `adoption/updating.md`, `docs/roadmap.md`, `docs/digests/adoption-digest.md`; the one outside file is the feature's own `tasks.md` (ticks T008-T010, T012, T013; no wording changed). |
| Constitution / domain invariants | The ledger-held fact is not claimed: the script still never says "claimed"; refusals leave local state in place and name origin's. |
| Security (authn/authz, secrets, sensitive logging) | N/A. The new messages print the branch name only; git's stderr for the withdrawal and the fetch is discarded (`2>$null`), so the user is told to retry by hand but never shown why (see F6). |
| Scope guard | `scripts/scope-check.ps1 -Branch 030-claim-ledger-read-named-state` in a detached worktree at `0e1d252`: `PASS phase 2 commit 0e1d252 (4 file(s))`. `git diff --stat` read for intent. |
| Rollback safety | Phase 2 touches the loop's four statements plus additive harness fields, fixtures, rules and docs; reverting restores the phase 1 tip. The two roadmap rows and the digest revert with it. |
| Fixture truthfulness (b) | Read all five new expected.txt and recipes. CLF-013 `fail` vs `pass` recipes differ only in `originDenyDeletes: true` (and the description). CLF-014 `fail` vs `pass` differ only in `originFailCall` 4 vs 99. `fail-unpushed` differs from `fail` only by `originPushUrl`. Expectations are right by reasoning from the script's strings: stdout `Allocating...`, then stderr warning and refusal, in the harness's stdout-then-stderr order. Call count: first `git fetch` (1), first `ls-remote` (2), the `ls-remote` after the push (3), the re-fetch (4); `push` and `push --delete` are receive-pack and do not count. The `fail` output ending `... 001-probe was withdrawn from origin.` can only occur if call 4 is the re-fetch (call 4 as a re-read would print the ls-remote message), and the `fail-unpushed` text only if the push was rejected. `originDenyDeletes` sets `receive.denyDeletes` on the repository `origin` points at, after nested repos exist, and is refused without `origin` or when the target does not exist (self-tests added, Harness.Tests.ps1 +49 lines, passing). |
| Run on the phase 1 tip (c) | Detached worktree at `0e1d252` with `scripts/claim-feature.ps1` restored from `772a93d`, `-Case claim-feature`: `CLF-013/fail` fails on exit code and output (parent continues and exits 0); `CLF-014/fail` fails on exit code and output (parent continues past the stale re-fetch); `CLF-014/fail-unpushed` fails on output; `CLF-011/fail-unpushed` PASSES (it pins phase 1 behaviour, as a phase 1 fixture should); all `pass` twins pass; the inventory test additionally fails, naming CLF-013 and CLF-014 anchors "no longer found", i.e. the anchors measure the new code. |
| Run on the phase 2 tip | Detached worktree at `0e1d252`, `pwsh -File tests/enforcement/Run-Tests.ps1 -Case claim-feature`: `Tests Passed: 138, Failed: 0, Skipped: 0`. I did NOT run the full harness (20+ minutes; T011 and T015 are the implementer's and the owner's). |
| Anchors (d) | `grep -F` over the script: `unreachable ledger.'` (CLF-004) matches line 112 only; `unreachable ledger. $gone` (CLF-014) line 173 only; `could not withdraw` (CLF-013) line 165 only; `Lost the allocation race $MaxAttempts times` (CLF-007) line 168 only (line 165's `Lost the allocation race but` is not matched). The old anchors `git fetch origin failed` and `Lost the allocation race` each matched two or more sites, so narrowing was needed and left no site of the old messages unowned: 112 CLF-004, 168 CLF-007, 165 CLF-013, 173 CLF-014. |
| Doc checks | `doc-lint.ps1`: `OK - kit complete, every referenced path resolves`. `build-digests.ps1 -Check`: `digests: OK (5 digest(s) fresh, 119 marker(s))`. |
| 023's refusals and successful claims unchanged (i) | The diff adds statements only on the lost-race path after the warning; lines 112, 168, preflight, allocation, delegation, success output untouched (read). The one reachable change to a 023 refusal: on the last attempt, with a push that landed and a denied withdrawal, the old "Lost the allocation race 3 times" is replaced by the withdrawal refusal (F5). CLF-001..CLF-007 and every `pass` stay green. |
| Roadmap (g) | Decisions-log entry and GAP-036/GAP-031 status text read in full; see F3. |
| Flow-down note (e) | Every claim read against the code; see F1, F2, F4. |

## Findings

### F1 — The flow-down note cites a measurement and a notes.md list that the repository does not hold — BLOCKING (docs, not code)

`adoption/updating.md` (the new note, "What was measured") says clones of three projects were measured, the outputs listed, and closes with "Every line that changed is listed in the notes of feature 030 in the kit repository." `docs/roadmap.md` (decisions log) quotes "the harness 1744 passed on the parent and 1774 on the phase 1 commit". `specs/030-.../notes.md` has only a Phase 1 section; it has no phase 2 section, no measurement, none of the numbers 1744 or 1774 (`grep` for 1744, 1774, FitForge, FlowBoard, ExpenseTracker returns nothing), and its own "Numbers" subsection still reads "(Filled in after the full harness and `ritual-checks.ps1` run...)". T014 (measurement, which says "list every line that moves in `notes.md`") and T011 are unticked. A claim in the document an adopter reads says a list exists in the repository; it does not, so an adopter or reviewer cannot check the "byte-identical in all three projects" claim, and the roadmap quotes two harness counts with no source. The paragraph itself is honest about what it did not exercise (the withdrawal and re-fetch refusals, child-process wrappers, a permission-rejecting remote), which is correct, and the claims it makes are plausible against the code; I could not and did not re-run it. The flaw is that the stated evidence location is empty.
*Action: implementer: before merge, write the Phase 2 section and the T001 and T014 numbers into `notes.md` (the saved outputs, the lines that moved and their cause, the two harness counts), or remove the sentence "Every line that changed is listed in the notes" and the 1744/1774 figures until they are recorded. Blocks merge, not the code.*

### F2 — "Feature 023's note ... is not edited" is untrue to the letter: its digest marker was deleted, undisclosed — DOC DRIFT

The same note says it supersedes the "known limits" paragraph of feature 023's note, "which stands as history and is not edited". The commit deletes the marker `<!-- digest: claim-feature still dies in a throw if ls-remote fails, and a push the remote refuses reads as a lost race. -->` from that note (`adoption/updating.md` hunk at line 1039), and nothing in notes.md, the roadmap or the commit message says so. Precedent: feature 029 added markers for 028's area without deleting any of 028's (`git show 2f00c82` adds two markers, removes none); the adoption digest was already at its 40-bullet bound (40 at `a42b053`, 40 at `0e1d252`; `build-digests.ps1` line 61, `MaxDigestContentLines = 40`; it fails above the bound), so one marker had to go. The choice is defensible, since the deleted bullet now states a limit that no longer exists and keeping it would make the digest wrong, and `build-digests.ps1 -Check` passes; the kit's rules do not forbid editing a marker, but the digest is orientation only, so no obligation is lost. What is wrong is the sentence and the silence: the deletion is real and not disclosed.
*Action: implementer: either say in the flow-down note and notes.md that one marker of 023's note was retired because the digest is at its bound and the limit it announced is closed by this feature, or reword "is not edited" to "its body is not edited". Owner: confirm the fold of two markers into one is acceptable.*

### F3 — Roadmap row reads `shipped` while T011, T014, T015, both AI reviews and the gate are open — DOC DRIFT

The 030 row is flipped to `shipped` (task T013 asked for this) and the decisions-log entry opens "built and measured". Its last sentence does state that the AI review of each phase, the owner's gate and the human review are still to come, and the GAP-036 and GAP-031 status text repeats it, so no review or gate is claimed as done; the wording is within the 023/029 precedent. Two residual points: "measured" has no record behind it (F1), and `shipped` with tasks.md showing T011, T014 and T015 unticked tells a roadmap-only reader the opposite of tasks.md.
*Action: implementer: after the owner's gate, tick T011, T014 and T015 with their numbers, or hold the row at `in progress` until then. Not blocking if F1 is fixed.*

### F4 — Two statements in the flow-down note are accurate but incomplete — MINOR

(a) "What it does now" lists the withdrawal refusal but "What an owner may newly see" omits it and the re-fetch refusal, which are the new states that need an action (delete the branch by hand; return to `main`). The "what to do" paragraph does not mention the withdrawal refusal either. (b) "What does NOT change ... the genuine lost-race loop (warn, withdraw, renumber, push again, up to three attempts)" holds unless the withdrawal fails, which is exactly the new behaviour; F5.
*Action: implementer: add one sentence to "What to do": a refusal that says it could not withdraw leaves the branch on origin; run the printed `git push origin --delete` command (with permission) and claim again.*

### F5 — Last-attempt, denied-withdrawal case replaces a 023 refusal's text — MINOR

Reasoning-only (not fixtured): at `$attempt -eq $MaxAttempts` with a landed push, a rival and a denied deletion, the pre-030 text was "Lost the allocation race 3 times" and the new text is the withdrawal refusal. This is the right outcome (the stale branch is the more important fact) and the note's "seven messages unchanged" is true of each message. It contradicts only the unqualified statement in F4(b).
*Action: none beyond F4's wording.*

### F6 — The withdrawal and re-fetch refusals hide git's reason — MINOR

`2>$null` discards why the deletion or the fetch failed (permission, network); the phase 1 rejected-push refusal does show git's text. The note's limit list does not mention it. Not a defect against the plan (P2 rows 6 and 7 specify the messages as written).
*Action: none; optional note in the "known limits" list.*

### F7 — Fixture coverage gap: the withdrawal-denied case on the last attempt and the combined rejected-push-plus-failed-fetch case — MINOR

CLF-013 covers attempt 1; no fixture drives the MaxAttempts-versus-withdrawal ordering (F5), and the ordering is the thing most likely to regress. Reasoning-only.
*Action: none required; owner may ask for one fixture (two rival-after-push attempts with denied deletions).*

## Amendments in this diff

- [x] **None.** The only change to `tasks.md` is ticking T008, T009, T010, T012, T013; `spec.md` and `plan.md` are untouched.

## Constitution re-check (post-implementation)

PASS. Within the plan's approved architecture, no package, no new script. The machine-held-check principle is engaged: a failed withdrawal and a failed re-fetch no longer read as success. Principle on honest status: engaged late and not yet satisfied for the measurement record (F1).

## Test coverage observed

`-Case claim-feature` at `0e1d252`: 138 passed, 0 failed (includes the harness's structural and inventory tests). New cases: `CLF-013/{fail,pass}`, `CLF-014/{fail,pass,fail-unpushed}`, plus `CLF-011/fail-unpushed` from phase 1; self-tests for `originDenyDeletes` (refusal without `origin`, refusal when the target repository is missing, deletion refused while an ordinary push lands). On the phase 1 script the same suite fails exactly the three new fail cases (and the two anchor entries), as it should.

## Residual risk

Low in the code. It concentrates in F1: an adopter-facing "measured" claim and a "listed in the notes" pointer with no record in the repository. Merge after notes.md carries the phase 2 record (or the sentence is removed), F2's disclosure is added, and the owner has run the gate and the full harness (T011, T015) and recorded the exit code; the implementer must not claim success.
