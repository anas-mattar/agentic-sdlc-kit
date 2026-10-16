# AI Code Review — 031 claim-feature.ps1 tells a same-base rival from our own claim (phase 1)

**Reviewer**: fresh-context agent, Claude Sonnet 5.5 (claude-sonnet-5-5)
**Date**: 2026-10-16
**Branches**: repo `agentic-sdlc-kit` branch `031-claim-same-base-rival` (phase 1 commit `894f101`, parent `53a04eb`)
**Scope reviewed**: `git diff 53a04eb..894f101` in full: `scripts/claim-feature.ps1` (whole push loop, lines 95-230 read), `tests/enforcement/cases/claim-feature/CLF-018/{fail,pass}/*`, `CLF-017/fail/expected.txt`, `tests/enforcement/rules.json` (CLF-018 entry), and the spec/plan/tasks/notes changes. Also read `CLF-012` and `CLF-010` expectations (the other cases that quote push text). Not reviewed: phase 2 files (not in the diff), the full harness (not run, by instruction), `TERR-`/`RIT-` cases.
**Feature contract**: script-only change (`scripts/claim-feature.ps1`) plus tests; no new package, no new script, no harness recipe field; the claim stays uncommitted; a branch the script did not push is never deleted, moved or rewritten; successful claims, `-NoPush`, no-origin, the seven refusals of feature 023 and the `-Json` object are unchanged (spec FR-002 to FR-006).

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5), the session that produced the diff under review
- **Inputs provided**: spec.md, plan.md, tasks.md (Phase 1 T001-T007), the phase 1 diff `53a04eb..894f101`, notes.md (read last), `docs/sdlc/definition-of-done.md`, `docs/sdlc/review-process.md`, `specs/_templates/ai-code-review-template.md`, the full text of `scripts/claim-feature.ps1` at `894f101`; runs: `Run-Tests.ps1 -Case CLF-` (159 passed, 0 failed), `Run-Tests.ps1 -Case CLF-018` on a detached worktree of `53a04eb` (outside the repository, removed afterwards), `scripts/scope-check.ps1`.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The change makes `claim-feature.ps1` read the push's own `git push --porcelain` status: an exit-0 push whose line for our own ref starts with `=` created nothing, so the branch on origin is another claimant's. The script then warns in its own words, skips the withdrawal, drops the upstream and renumbers through the existing loop. I traced the code, ran the CLF- cases (159 pass) and ran the new `fail` fixture against the parent commit, where it fails for the stated reason (the parent prints `CLAIMED: 001-probe`). I found no way for `$sameName` to fire on a push that is the script's own, and no path that deletes, moves or rewrites a foreign branch. The follow-ups are one spec/code wording conflict (F1), one narrow residual race that the landed-by-commit rule of feature 030 still reads as ours (F2), and thin coverage of two sub-behaviours (F3, F4). None blocks the merge.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-001: `claim-feature.ps1:151` sets `$sameName`; `:183`/`:188` skip the landed-by-commit read and the rejected-push refusal; `:194-196` print a warning naming the branch and say it is theirs. Fixture `CLF-018/fail` pins that text byte for byte. FR-002: the only deletion is `git push origin --delete` under `if ($landed)` (`:202`), and `$landed = $pushOk -and -not $sameName` (`:182`), so it is unreachable for the same-name state; origin denies deletes in both fixtures, so an attempt would end in the could-not-withdraw refusal instead of the expected success. FR-003: the pass fixture and the four states of notes T005/T006 print today's text; I re-read the output paths and `-Json` object (`:223-231`), untouched by the diff. FR-004: refusals' own sentences unchanged; only the quoted git text in `CLF-017/fail` moved (P6, owner-approved). FR-005: see below. FR-006: preflight, allocation, delegation, warnings untouched in the diff. FR-001 "whatever its sha" is only partly implemented: see F1. FR-007 belongs to phase 2. |
| Visual-reference match | Not applicable: no UI, no `screenshots/`. |
| Feature contract held | Diff touches no package manifest, no new script, no harness lib (`tests/enforcement/lib` unchanged), no recipe field. Claim remains uncommitted (no `git commit` added). |
| Constitution / domain invariants | No domain-invariants pack. Principle I amendments are recorded (see Amendments). VIII: new fixture pair exists and the `fail` was shown failing on the parent (below). X: one phase, ends at the gate. |
| Security (authn/authz, secrets, sensitive logging) | The only destructive git call is gated as above. `[regex]::Escape($branch)` is applied to the branch name in the match (`:151`), so regex characters in a short name cannot widen or break it. `git branch --unset-upstream $branch` is passed a name the script itself produced. No secrets logged. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | `pwsh -File scripts/scope-check.ps1` printed `scope-check: PASS phase 1 commit 894f101 (11 file(s))`. `git diff --stat`: `scripts/claim-feature.ps1`, `tests/**` (CLF-017 expectation, CLF-018 x6 files, `rules.json`) and four `specs/031-*` files. All inside the Phase 1 Territory (`scripts/claim-feature.ps1`, `tests/**`) or the feature's own documents. |
| Rollback safety (phase reverts cleanly; schema additive?) | The diff is confined to one script, test data and the feature's own documents; no schema, no generated digest, no manifest change. Reverting `894f101` restores the parent script and removes CLF-018 with its `rules.json` entry together (the coverage test needs both, and both are in the one commit). |
| Fixtures: differ only in the condition under test | `diff` of the two recipes by reading: identical except the stub's one line `if ($Number -eq 1) { git push -q origin $b ... }` (plus its comment) and the `description`. Same `originDenyDeletes`, same commands (`command.json` identical), same exit code 0. |
| Fixtures: expectations hand-written | `expected.txt` files are short literal text; the fail's warning line is the exact string in the script, and the `Renumbered: 001-probe -> 002-probe` and `CLAIMED: 002-probe` lines follow the script's own wording. No generator or snapshot step exists in the diff. |
| `fail` really fails on the parent | I made a detached worktree of `53a04eb` under the system temp directory, copied in `CLF-018` and `rules.json`, ran `Run-Tests.ps1 -Case CLF-018`: `CLF-018/fail` exit code test passes (0) and output test fails: `first diff at line 2: expected: WARNING: Number 001 was claimed concurrently by a claimant ... observed: CLAIMED: 001-probe (pushed to origin — the claim is live)`. `CLF-018/pass` passes on the parent. The coverage tests also fail there (anchor absent), as expected. Worktree removed; `git worktree list` shows only the repository and a worktree that belongs to another session. |
| `rules.json` CLF-018 anchor/notes | `emitAnchor` `claimed concurrently by a claimant of the same short name` occurs once in the script (the warning at `:195`); the parent has only `claimed concurrently (`. Coverage tests in the `-Case CLF-` run pass. Notes correctly say the stub plants once, for the first number only. |
| stderr/stdout ordering of `$pushText` | `:142-144`: ErrorRecords (stderr) first in arrival order, then stdout lines in arrival order. Both orderings are stable because each stream keeps its own order; only the interleaving between streams, which was the unstable part, is fixed. Pre-existing push-quoting cases: `CLF-012` and `CLF-010` quote only `fatal:`/`remote:`/`error:` lines (stderr only) and are unchanged; `CLF-017/fail` is the one that moved, by design (P6). All pass in my CLF- run. |
| `-Case CLF-` run | `enforcement-tests: 159 passed, 0 failed, 0 skipped`. |

## Findings

### F1 — FR-001 says "whatever its sha"; the code covers only the same sha — DOC DRIFT

Spec FR-001 and User Story 1 say a branch of our name pushed by another claimant, "whatever its sha (including our own)", must not be reported as ours and must be reported in the script's own words as a claimant who got there first. The code detects only `=` (same sha, exit 0). A same-name branch at a different sha still ends in feature 030's rejected-push refusal ("git push of X was rejected ... Nothing was claimed") because the push is non-fast-forward and `$rivals` excludes our own name (`:155`). The spec's Edge Cases and plan P4 say that state is "unchanged", and spec Background scopes the feature to the same-sha case, so the code follows the more specific text and the behaviour is safe (nothing claimed, nothing withdrawn). But FR-001 as written overpromises and the same-sha-only warning is not shown for the different-sha state.
*Action: the owner (or whoever may amend the spec) narrows FR-001 to "at our own sha" or states that the different-sha case is feature 030's refusal; the implementer must not amend it unilaterally. Before phase 2 text for `adoption/updating.md` is written, make sure it does not claim the wider behaviour.*

### F2 — A simultaneous create at the same sha that makes our push exit non-zero is still read as ours — CONFIRM

`$sameName` requires exit 0. If two claimants both connect while the ref is absent, git reports `*` on the winner and the loser's ref update (old value zero) should be refused by receive-pack with a non-zero exit. Then `$sameName` is false, and feature 030's landed-by-commit rule (`:183-185`) compares origin's tip for our name with our local tip: they are equal (both are `main`'s sha), so `$landed` is true and, with no numeric rival, the script prints the "reported an error, but ... is on origin ... treating the claim as made" warning and exits 0 as claimed (`:187-195`). This is the same false belief the feature removes, in a much narrower window (both pushes in flight at once rather than one before the other). I could not reproduce it: my attempt (a `pre-receive` hook that creates the ref) is blocked by git's quarantine environment, so this finding is by trace of the code, not by observation. The user is not misled silently (a warning is printed), but the exit and the output still say the claim is made.
*Action: owner decides whether to accept the residual (document it beside feature 030's other stated limits in `notes.md`/roadmap) or open a follow-up gap; no change is requested in this phase.*

### F3 — `git branch --unset-upstream` (P3) has no fixture that can fail — MINOR

In `CLF-018/fail` the script renumbers and pushes `002-probe` with `-u`, which sets a new upstream whatever the old one was, so removing `git branch --unset-upstream` at `:197` would not change any fixture output. P3's purpose (no tracking of a branch we do not own when the loop ends in a refusal) is reachable only through the three-times path that `CLF-019` would have covered; it was dropped with an approved amendment. I traced the line: it runs after the warning, before the rename, discards output and ignores the exit code (measured 128 on no upstream), and cannot refuse.
*Action: none required in this phase; consider a unit-style assertion (the case could run `git config branch.<b>.remote` afterwards) in a later feature if the path matters.*

### F4 — Second git version probe is deferred; the `=` match depends on one measured line shape — MINOR

The match `^=\s+refs/heads/<branch>:` is anchored on the flag and the ref, not on git's bracket words, which is the right shape, and `--porcelain`'s `<flag>\t<from>:<to>\t<summary>` form is documented. Only git 2.55.0.windows.5 was measured (notes T002 says the CI image's git is the second probe, "the CI run of this branch"). If a CI git printed a different flag column the new fixture would fail loudly rather than silently pass, so the risk is detection, not safety. Windows CRLF is not a problem: git emits LF and PowerShell splits lines before the match. A `fail` run on the parent proves the fixture reaches `=` only on this git.
*Action: confirm the CI run of the branch is green on the Linux runner before merge; no code change.*

### F5 — Plan and tasks were amended by the implementing phase — ACCEPTED

The phase dropped `CLF-019` from plan P5, Source Code, Testing Strategy, tasks T003/T004 and the rule-id line, adding `**Amendment approved by**: anas.m, 2026-10-16` lines. The stated reason is credible and I verified part of it: the stub runs once, before the first push (`CLF-018/fail` stub has `if ($Number -eq 1)`), so a later number cannot be planted. The approval is recorded as required, but I cannot verify it from the repository alone, and the amender and the implementer are the same session.
*Action: owner confirms the amendment lines record an approval he gave; no other action.*

### F6 — Foreign branch "unmoved" is only indirectly asserted — MINOR

Because the rival's branch is at the same sha as ours, a move or rewrite of it would be invisible, and the only observable proof that nothing was withdrawn is the deny-deletes remote making a withdrawal fail the claim. That does fully cover deletion. The mixed state (`$also`, a same-name rival plus a numeric rival; `:194`) has no fixture, though its output differs.
*Action: none required; note the untested `$also` branch for a later fixture.*

## Amendments in this diff

- [x] Amendments listed. Plan P5 (CLF-019 not built), plan Source Code and Testing Strategy, and tasks T003/T004 plus the rule-id line were amended in this commit; each carries `**Amendment approved by**: anas.m, 2026-10-16` (see F5). Spec.md is not changed by the diff. No other amendment.

## Constitution re-check (post-implementation)

PASS. I (specification first) satisfied: spec, plan, tasks approved before the code; amendments recorded. III, V, VII: N/A as at plan time. IV: no new file; the script remains standalone. VI: the script still deletes only a branch it pushed, and the new state never reaches the deletion. VIII: the fail/pass pair exists and the `fail` fails on the parent. IX: this review and a human review at merge. X: one phase, owner-run gate, no batching or ci-held.

## Test coverage observed

`-Case CLF-`: 159 passed, 0 failed, including the Coverage tests (CLF-018 anchor found once, a passing and a failing case) and the harness self-tests. `CLF-018/fail`: planted same-name same-sha branch gives the pinned warning, renumbering to 002 and `CLAIMED: 002-probe`, exit 0, with deletes denied. `CLF-018/pass`: no rival, `CLAIMED: 001-probe`, exit 0. `CLF-017/fail` was re-expected for the porcelain layout. The full harness (1809 claimed in notes), `TERR-` and `RIT-` were not re-run by me. Not covered: F2's concurrent-create race, the `$also` text, the unset-upstream effect.

## Residual risk

Concentrated in F2 (a simultaneous same-name, same-sha create whose push exits non-zero is still treated as ours via the landed-by-commit rule, with a warning) and F1 (spec wording wider than the behaviour). Before merge: owner decides F1 wording and F2 acceptance; the branch's CI run is green on a second git. After merge: phase 2 text for adopters should describe the same-sha state only.
