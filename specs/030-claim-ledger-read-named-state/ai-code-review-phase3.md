# AI Code Review — 030 claim-feature.ps1 a push that reports failure but landed (phase 3)

**Reviewer**: fresh-context agent, Claude Sonnet 5.5 (claude-sonnet-5-5)
**Date**: 2026-10-16
**Branches**: repo `agentic-sdlc-kit` `030-claim-ledger-read-named-state` (phase 3 commits `ac731a0` amendment, `a26da6e` phase; base `d33e908`)
**Scope reviewed**: `git diff d33e908..a26da6e` (`scripts/claim-feature.ps1` race loop; `tests/enforcement/lib/FixtureRepo.psm1`, `Harness.Tests.ps1`, `rules.json`; fixtures `CLF-015` and `CLF-016`; spec.md, plan.md, tasks.md amendment; `adoption/updating.md`; `docs/roadmap.md`).
**Feature contract**: spec FR-003 and User Story 2 scenarios 1/4/5 as amended 2026-10-16; plan P2-P6, Risks, Phases as amended; tasks Phase 3 (T016-T018) and its Territory.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5), the session that produced the diff
- **Inputs provided**: the diff above; spec.md, plan.md, tasks.md; the phase 1 and phase 2 reviews; definition-of-done, review-process, the review template. Ran: `Run-Tests.ps1 -Case claim-feature` on a detached worktree of `a26da6e` (149 passed, 0 failed) and on a detached worktree of `a26da6e` with only `scripts/claim-feature.ps1` restored from `d33e908` (143 passed, 6 failed: CLF-015/fail both checks, CLF-016/fail both checks, and the two coverage checks for the new anchors); Pester on the three `originPushFailsAfterLanding` self-tests (3 passed); `doc-lint.ps1` OK; `build-digests.ps1 -Check` OK; a hand-built probe fixture (below). Not run: the full harness (in progress elsewhere), notes.md (no phase 3 section yet: known gap, not a finding).
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES.** The mechanism, fixtures and harness field are sound, but the premise of `landed` ("our number was free, so the branch can only be there if our push put it there") is false for a same-number, same-slug race, and there the script now reports a claim it does not hold (and can delete someone else's branch).

## Evidence

| Check | Result |
|---|---|
| `-Case claim-feature` on the phase 3 commit | 149 passed, 0 failed |
| Same on the script of `d33e908` with the new tests | 6 failed: CLF-015/fail and CLF-016/fail each fail on exit code and output, plus the two rule-inventory checks. CLF-015/pass and CLF-016/pass pass on both. Each `fail` fails for its stated reason (old: rejection exit 1 / skipped withdrawal then renumber exit 0). |
| `originPushFailsAfterLanding` self-tests | 3 passed (Nth push lands and exits non-zero, others succeed; absent field leaves `receivepack` unset; refused without origin, with 0/-1/'one', and with `originRivalOnPush`) |
| Probe: origin already holds an unrelated `001-probe` (different commit) when our `001-probe` is pushed | Push rejected (non-fast-forward), ledger lists `001-probe`, no rival: script prints the warning, `CLAIMED: 001-probe (pushed to origin - the claim is live)`, exit 0. Local branch has no upstream. See F1. |
| `-Json` / warning stream | `Write-Warning` is stream 3; the JSON object is still the only stdout write (reasoning from the code; not run in `-Json` mode) |
| Territory | Changed files are all inside the Phase 3 Territory (`scripts/claim-feature.ps1`, `tests/**`, `adoption/updating.md`, `docs/roadmap.md`) plus the feature's own spec/plan/tasks (amendment); `docs/digests/**` untouched and still fresh |
| Amendment records | spec.md, plan.md, tasks.md each carry `**Amendment approved by**: anas.m, 2026-10-16`; both commit messages name the approver |

## Findings

**F1 — HIGH, blocks. `landed` is true when someone else's branch of the same name is on origin; the claim is reported live and the withdrawal can delete their branch.**
`scripts/claim-feature.ps1:156` (`$landed = $pushOk -or ($ledger -contains $branch)`), used at `:158`, `:174`, `:185`. The rival test at `:151` excludes our exact branch name, so a rival with the same number AND the same slug is invisible as a rival. Scenario (reproduced): two people run `claim-feature -ShortName probe` at once; theirs reaches origin first as `001-probe`; ours is rejected as non-fast-forward; the ledger read lists `001-probe`; `landed` is true; no rival; the script warns (showing only `error: failed to push some refs`, the `! [rejected]`/hint lines are filtered out), prints `CLAIMED: ... the claim is live`, exit 0. Before this phase it refused with the rejection. The user now works on a number that another branch holds. Beside a real rival the same mistake makes `git push origin --delete` (`:174`) delete the other person's branch. The plan's premise (our number was free) is true of the number, not of the name. Fix: decide landing by sha, not name (compare `git ls-remote --heads origin <branch>` with local `HEAD`, or `git rev-parse` of the branch), and add a CLF fixture pair for the foreign same-name branch (fail: foreign tip, refused; pass: our tip, claim made). The amendment text, the roadmap entry and `updating.md` ("the branch is on origin ... now read as landed") repeat the premise and should state the sha condition once it is fixed.

**F2 — LOW, does not block. The warning's git text is filtered to `error:`/`fatal:`/`remote:` lines (`:160`).** Disclosed in plan P2's amendment (judged adequate: it names the three prefixes and the all-text fallback). Cost: it drops `! [rejected]` and `hint:` lines, which are exactly what would have told F1's user the push was refused. After F1 is fixed this matters less. CLF-015's expectation has one git line (`error: failed to push some refs to '<ROOT>/origin.git'`); on Linux git may add a `fatal: ... hung up` or `remote:` line for a receive-pack that exits 1 (reasoning-only, not run on Linux); worth a look when CI runs.

**F3 — NIT, does not block.** tasks.md T017 reads "the `` wording": the `$gone` token was lost to PowerShell backtick/dollar expansion when the file was written. Restore it.

**F4 — NIT, does not block.** The self-test "leaves origin alone when the recipe does not ask" only checks that `remote.origin.receivepack` is unset; it does not prove the wrapper is inert. Acceptable, but the weakest of the three.

## Checks with nothing found

(b) The decision table matches plan P3 as amended, FR-003 and scenarios 4/5 for landed x rival; last attempt: landed + rival withdraws, then `Lost the allocation race N times` as before. Unreadable ledger: exit code only, as the amendment states. (c) `$pushed = $true` after a failed push in the genuine case leaves upstream tracking set (plan's probe; the wrapper runs the real receive-pack to completion). (e) The wrapper counts every push including deletions, lives under `.git/` (working tree clean), is refused without origin, on bad values and with `originRivalOnPush`. (f) CLF-016 sharing CLF-013's `could not withdraw` anchor: the coverage sweep passes, nothing became unowned. CLF-015/016 pairs differ in exactly one condition and the expectations follow from the plan's wording by reasoning. (j) Feature 023's refusals and every phase 1/2 fixture pass unchanged. (h) updating.md and roadmap claims match the code except for the F1 premise; nothing claims a review, gate or numbers that have not happened.
