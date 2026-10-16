# AI Code Review — 030 Claim ledger read: phase 3 fix (finding F1 of phase 3)

**Reviewer**: fresh-context agent, Claude Sonnet 5.5 (claude-sonnet-5-5)
**Date**: 2026-10-16
**Branches**: kit `030-claim-ledger-read-named-state` (diff `a26da6e..95d4725`, tip `95d4725`)
**Scope reviewed**: `git diff a26da6e..95d4725` in full: `scripts/claim-feature.ps1` (the whole race loop, lines 100-215), `tests/enforcement/rules.json` (CLF-017 entry), the three CLF-017 fixture directories, spec.md / plan.md / tasks.md / roadmap / `adoption/updating.md` hunks, the commit messages of a26da6e, ac731a0 and 95d4725. Not read: the phase 3 review beyond its role as background.
**Feature contract**: no new package, table or script; `claim-feature.ps1` behaviour on successful claims byte-identical; feature 023 refusals and phase 1/2 wordings unchanged.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5), the session that produced the diff
- **Inputs provided**: `git diff a26da6e..95d4725`; `scripts/claim-feature.ps1` at 95d4725; the CLF-017 fixtures and rules entry; the greps and `Run-Tests.ps1 -Case claim-feature` runs listed under Evidence; `.specify/scripts/powershell/create-new-feature.ps1` (grep only)
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The fix does what it claims: `landed` is now true only when the push exited 0 or origin's sha for our branch equals our local `refs/heads/<branch>` tip, and `$script:LedgerShas` is reset and refilled on every ledger read, so it is never stale at a use. CLF-017's `fail` and `fail-rival` fail on the script of a26da6e and pass at 95d4725; CLF-001..CLF-016 and the rest of the claim-feature suite still pass. Two follow-ups, neither blocking: F1 (reasoning only) is a residual case the sha test cannot separate in the real flow, which the docs state more strongly than the code delivers; F2 (verified) is markdown damage in plan.md introduced by this diff.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| (a) Truth table of `landed` | Read lines 142-170. push exit 0: `landed` true, the ledger sha is never consulted (as before). Push non-zero: if origin has no branch of our name, `ContainsKey` is false and `landed` stays false; if it has one, `landed` is true only when `rev-parse` succeeded and the shas are equal. Numeric rival present/absent is orthogonal: `$rivals` excludes our own name, so a same-name foreign branch is never a rival, and with no rival and not landed the claim is refused once as the rejected push; with a rival and not landed there is no withdrawal (the withdrawal is inside `if ($landed)`). Ledger unreadable: `Stop-Refused` fires before `landed` is computed on both paths, unchanged. |
| Staleness of `$script:LedgerShas` | `Get-RemoteFeatureHeads` resets `LedgerReadFailed` and `LedgerShas` on entry and fills it in the same loop that builds the names. Its four call sites (initial read, the per-attempt read at the loop top, the post-renumber re-read) are each followed by use only in the same iteration: the only reader is the `landed` test, directly after the per-attempt read, with no intervening call. After a renumber, `$branch` is the new name and the next iteration re-reads, so the first attempt's shas cannot leak into the second or the last attempt. |
| (b) `rev-parse` and `$LASTEXITCODE` | `$tip = @(git rev-parse ... 2>$null)` is the only native call between the command and the `$LASTEXITCODE` read; the read is on the next statement. `$tip[0]` is evaluated only when `$LASTEXITCODE -eq 0` (short-circuit `-and`), and `--verify --quiet` prints exactly one line on success, so the array is never empty there. Comparison: PowerShell `-eq` on strings is case-insensitive; both sides come from git (lowercase hex), the ls-remote side is split on `\s+` and the local side `.Trim()`med, so CRLF and trailing whitespace are handled. `refs/heads/$branch` is the fully-qualified name; the script itself renames the local branch with `git branch -m` to the new name before the next attempt, and `create-new-feature.ps1` checks the branch out under that name, so a different local name is not a path. Abbreviated shas are not an issue (full 40-hex from ls-remote and rev-parse). |
| (c) Other ways to misread ownership | See F1. A partly landed push does not exist at ref granularity (one ref update is atomic); a local branch that moved between push and read cannot happen inside this script (no commit, no checkout in the window). If the local branch moved it would only make `landed` false, the safe direction. |
| (d) CLF-017 by reasoning | The stub creates the foreign branch on origin at origin's `main`, a commit unrelated to the fixture's local `main`. The claim's first `git fetch origin --prune` ran before the stub, so origin's `main` commit is already a local object; the push of our unrelated-history branch onto that name is therefore reported `[rejected] ... (non-fast-forward)` and not `(fetch first)`, which git prints only when the remote tip is missing locally. Confirmed by the observed run: the `fail` case produced exactly the expected text. `advice.pushUpdateRejected false` removes the version-varying hint paragraph. `pass` differs from `fail` only in the foreign branch (and the config line that has no effect without it). `fail-rival` differs from `fail` in the rival and `originDenyDeletes`. |
| (d) Run against a26da6e | Detached worktree at a26da6e outside the repo, with CLF-017 and rules.json from 95d4725 copied over: `Run-Tests.ps1 -Case claim-feature` gave **151 passed, 4 failed** (exactly the two `fail` cases' two `it` blocks each: exit code and output); the `pass` case passes on the old script, as expected. A second detached worktree at 95d4725: **155 passed, 0 failed**. Both worktrees removed. |
| (d) Platform stability of the fail expectation | The five git lines are the `To <origin>` line, `! [rejected] 001-probe -> 001-probe (non-fast-forward)`, and `error: failed to push some refs to ...`. The hint block (`hint:` lines) is the version-dependent part and is switched off by the config line; the `To` line has the root normalised (`<ROOT>`). Reasoning only: the `To` URL shape for a local bare path is stable on the git builds I know; a very old git that prints `error: failed to push some refs to` with a different quoting is not a realistic concern. |
| (e) Text corrections | `grep -rniE "can only be there|number was free"` over `*.md *.ps1 *.json`: the premise survives only in the script comment at claim-feature.ps1:158, which now continues "our branch NAME is not" (corrected history, not asserted as truth), and plan.md:93 quoting it as the thing found wrong. The spec, roadmap and adopter note state the corrected rule. Approver records: the 95d4725 commit message carries `Amendment approved by: anas.m, 2026-10-16`; spec.md's amendment line and tasks.md T019 name it; plan.md carries `**Amendment approved by**: anas.m, 2026-10-16` above P3. |
| (f) Earlier behaviour | CLF-001..CLF-016 are in the 155 passes at 95d4725; the rest of the suite under `-Case claim-feature` passed too. The diff touches `claim-feature.ps1` only in `Get-RemoteFeatureHeads` and the `landed` computation, so feature 023's refusals and phase 1/2 wordings are untouched by inspection as well. |
| Scope guard / rollback | `git diff --stat` read: 17 files, all within feature 030's territory by name; the change reverts cleanly (one script hunk, fixtures, docs). `scope-check.ps1` was not run by this reviewer. |

## Findings

### F1 — A foreign same-name branch at the same sha is indistinguishable from ours — MINOR (reasoning only, not blocking)

`create-new-feature.ps1` creates the branch with `git checkout -q -b` and makes no commit (only `checkout`/branch creation appear in it), so two claimants on the same `main` tip who allocate the same number and short name hold branches at the *same* sha. If theirs reaches origin first, our push is "Everything up-to-date" and exits 0, so `$pushOk` is true and the claim is reported made. Before the fix this was equally true. If the push errored instead, the sha test is also true. The commit test therefore closes F1 of phase 3 only for claimants whose bases differ; in the common real race (same base) the two claims look identical and one claimant's work will later be pushed onto the other's branch. Plan.md:93, spec.md and `adoption/updating.md` say a same-name branch "is theirs" without this qualification. *Action: state it as a known limit in the plan and the adopter note (or follow up in a later feature, e.g. by detecting a branch that already existed on origin before our push); not a regression of this diff.*

### F2 — Code fences in plan.md were damaged by this diff — DOC DRIFT

In `specs/030-claim-ledger-read-named-state/plan.md` (lines 154, 161, 169, 179) the two code blocks that used to open with ```` ```text ```` and close with ```` ``` ```` now read ``` ``text ``` and ``` `` ```. They no longer render as fenced blocks (the file tree and the source list collapse into a paragraph). The same hunk correctly repairs the stray double-backtick spans in the CLF-015/CLF-016 sentence and in tasks.md T017 (`$gone`), so this looks like a find-and-replace that went one backtick too far. The harness and doc-lint passed, so nothing enforced it. *Action: implementer restores the four fences to three backticks (a docs-only fix in the same feature; note it as an amendment-free typo repair or record the approver per constitution I if the owner reads it as an amendment).*

### F3 — Script comment still contains the old premise sentence — MINOR

scripts/claim-feature.ps1:158 reads "Our number was free when it was allocated, our branch NAME is not": the old premise is cited and immediately corrected, so it is not asserted as truth; mentioned only so the reader knows the grep hit was checked. *Action: none.*

## Amendments in this diff

- [x] Amendments listed: spec.md (User Story 2 scenario 4, FR-003, edge case; amendment line extended), plan.md (P3 paragraph; `**Amendment approved by**: anas.m, 2026-10-16`), tasks.md (T017 reworded, T019 added with the approver). The approver is recorded in each place and in the commit message; the owner's approval was reported by the caller as given in this session, which this reviewer cannot independently verify.

## Constitution re-check (post-implementation)

PASS for the parts reviewed. Amendment authority (I): approver named, not self-approved by the reviewer. No package, architecture or territory change.

## Test coverage observed

`-Case claim-feature` at 95d4725: 155 passed, 0 failed. At a26da6e with CLF-017 and the 95d4725 rules.json copied in: 151 passed, 4 failed (the `fail` and `fail-rival` cases), 0 for `pass`. CLF-017 pins: exit code and text of the rejected-push refusal with a foreign same-name branch; and that the foreign branch is not withdrawn (a remote that refuses deletions would otherwise turn the claim into the could-not-withdraw refusal).

## Residual risk

F1: the same-base race, where the foreign branch and ours share a sha, remains read as ours. That is the realistic same-name collision and is unchanged by this fix; it should be stated as a limit. F2 is cosmetic but should be repaired before merge since the file is a feature document.
