# AI Code Review — 036 Critical merge-readiness open edges (phase 1)

**Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
**Date**: 2026-10-18
**Branches**: agentic-sdlc-kit `036-critical-merge-ready-edges` (phase 1 commit `6e24d98`; parent `0f35653`)
**Scope reviewed**: `git show 6e24d98` / `git diff 0f35653 6e24d98`: `scripts/enforcement-pack.ps1` (`Get-CriticalMergeReadiness`, the new `Get-TaskTickCount`, `Invoke-CriticalEvidenceCheck`) and its surrounding code, the `tests/enforcement/rules.json` diff, every `CRIT-R04` `expected.txt` and `command.json` with the recipe diffs between `fail` and each variant, `AMEND-001/pass-merge-readiness-added-approved`, and a sample of the 18 changed `expected.txt` files. Read in full: `spec.md`, `plan.md` (P1 to P8), `tasks.md` (T001 to T006), the head of `notes.md`, the review template.
**Feature contract**: Standard lane, two phases; no new package, no new script file, no new harness recipe field; the rule only ever demands the independence artifact earlier, never later; a plan that declares `pending` beside an unticked task, or beside a `tasks.md` with no checkbox task, keeps today's deferral warning byte for byte.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5), the session that produced commit `6e24d98` on `036-critical-merge-ready-edges`
- **Inputs provided**: commit `6e24d98` (`git show`, diff against `0f35653`); `spec.md`, `plan.md`, `tasks.md`, the head of `notes.md`; `specs/_templates/ai-code-review-template.md`. The reviewer did not read `docs/sdlc/review-process.md` in full and did not run the full harness.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The change makes a plan that says `pending` beside a `tasks.md` with at least one checkbox task and none unticked graded as `ready`, and appends the declaration hint to the heuristic's messages when the plan carries no marker. The reviewer found no correctness bug against `spec.md` or `plan.md`; the two reader gaps it found were confirmed by running code and err toward demanding the review earlier, never later. Residual risk is the stated proxy limit: a tick is not proof of completion.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match | `Marked` is on every return path of `Get-CriticalMergeReadiness` except the first early return (an artifact already committed), which has `Why = $null` and `Pending = $false`, so the hint is never used there. The suffix is applied at exactly the three intended sites and on no path where a marker exists, including the new all-ticked path. An unreadable or absent `tasks.md` gives `Total = 0`, so `pending` is honoured. |
| Fixtures | `-Case CRIT-R04` selected 13 cases, 121 of 121 passed; `AMEND-001/pass-merge-readiness-added-approved` differs from `fail-merge-readiness-added-unapproved` only by the approver record, in the plan and in the commit message. The 18 `expected.txt` diffs sampled each add only the suffix. |
| Feature contract held | Only `scripts/enforcement-pack.ps1`, `tests/**` and the feature's own `notes.md` and `tasks.md` ticks moved. |
| Constitution / domain invariants | The kit has no domain-invariants pack. The phase commit carries `phase 1` in its subject and the owner-confirmed gate. |
| Security | The change only changes what a check says and reads git; nothing is written or echoed beyond the existing messages. |
| Scope guard | `scope-check.ps1`: `PASS phase 1 commit 6e24d98 (64 file(s))`. |
| Rollback safety | A script, fixtures, an inventory and notes; `git revert` restores the parent. No schema. |

## Findings

### F1 — `Get-TaskTickCount` does not count a bare `- [ ]` — FIXED

The pattern `^\s*[-*+]\s+\[([ xX])\]\s` needs whitespace after the box, so a bare `- [ ]` or `- [x]` was not a task. A `tasks.md` of ticked tasks plus one bare unticked box read as all ticked. It contradicts FR-002 and plan P2 ("any unticked task leaves `pending`"), and errs toward earlier demand. Verified by running the pattern.
*Action: done in the follow-up commit: the pattern ends `(\s|$)`; fixture `CRIT-R04/pass-bare-unticked-checkbox` fails under the old pattern.*

### F2 — An unterminated `<!--` hides every later line — ACCEPTED

`Get-VisibleFromText` hides all text after an unterminated comment, so an unticked task below it is not seen. Consistent with how the phase-heading read behaves; errs toward earlier demand. Verified by running a four-line probe.
*Action: pinned by fixture `CRIT-R04/fail-unterminated-comment-hides-later-tasks`; listed with the limits in the phase 2 guidance (T007, T008).*

### F3 — `pass-checkbox-only-in-fence` and `pass-checkbox-only-in-comment` are not minimal pairs — MINOR

They differ from `fail` in several conditions at once (no real tasks, no Territory blocks, no amendment headings). They still measure the claim: if fences or comments were counted the rule would fire. The `fail-unticked-example-in-*` fixtures are the one-condition versions.
*Action: none.*

### F4 — `fail-tasks-absent-pending-honoured` exits 1 only through `Structure` — MINOR

It exercises the absent-`tasks.md` branch as named; the `fail-` prefix is the harness convention for exit 1.
*Action: none.*

### F5 — No fixture isolates the invalid marker `done` as a minimal pair — MINOR

The existing `CRIT-R02/fail-marker-*` cases cover it.
*Action: none.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None.** The phase commit changes no line of `spec.md`, `plan.md` or `contracts/`. `tasks.md` changes only task checkboxes (T001 to T006 ticked), which the amendment check exempts; `notes.md` is evidence.

## Constitution re-check (post-implementation)

**PASS**, as the reviewer found no violation: specification first held (spec, plan and tasks approved with recorded approvers before the phase commit), no new file or package, and nothing outside the territory moved.

## Test coverage observed

`CRIT-R04`: 13 cases at `6e24d98` (121 checks with the harness suites), now 15 cases after the follow-ups (125). Full harness at `6e24d98`: 1903 passed; after the follow-ups: 1907 passed, 0 failed (run by the implementer, not the reviewer). The 18 changed `expected.txt` files differ from the parent by exactly the suffix.

## Residual risk

The tick is a proxy for "complete": a project that does not tick, or does not use checkbox tasks, keeps `pending` as a claim, and an unterminated comment or a bare mid-list box can only move the verdict earlier. Both are stated limits for the phase 2 guidance. Merge after the owner's human review.
