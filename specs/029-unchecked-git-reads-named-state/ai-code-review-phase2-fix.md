# AI Code Review — 029 Make every unchecked git read a named state (phase 2 fix, commit 92c2371)

**Reviewer**: fresh-context agent, Claude Sonnet 5.5 (claude-sonnet-5-5)
**Date**: 2026-10-16
**Branches**: kit repository `029-unchecked-git-reads-named-state` (tip `92c2371`, fixing phase 2 commit `02a065d`)
**Scope reviewed**: `git diff 02a065d 92c2371 -- scripts tests specs`; `scripts/enforcement-pack.ps1` at `92c2371` (`Read-GitLines` 239-247, `Set-AmendmentReadFailure`/`Read-AmendmentGit`/`Test-AmendmentReadFailed` 275-293, `Get-NameStatusBatch` 1452-1481, `Invoke-AmendmentAuthorityCore` 2150-2360); spec.md, plan.md (Amendments 1, 2), tasks.md, notes.md ("Correction to phase 2 after the full harness"); the earlier review `ai-code-review-phase2.md`.
**Feature contract**: no new script, package or verdict word; healthy runs byte-identical; numbered lane fails by name, Lite lane never newly failed (014 FR-009); a genuine amendment failure is kept beside a refusal on the Lite lane (027); one cause prints one line.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5), the session that produced the diff
- **Inputs provided**: `git diff 02a065d 92c2371` (scripts, tests, specs), `enforcement-pack.ps1` at `92c2371`, spec.md, plan.md, tasks.md, notes.md, the earlier phase 2 review, the AI review template; a throwaway git repository built to probe git's partial output; the enforcement harness run per family on a detached worktree at `92c2371` (DIFF-, AMEND-, GITREAD-, LITE-, CRIT-, MICRO-, PHASE-, PACK-, PROV-; the full harness was not run, one is running elsewhere).
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups** — The fix keeps the rows `git log --name-status` printed before it failed (`Read-GitLines -KeepPartial`), notes a graded commit that has no record (`$nameStatusMissing`), and refuses after the walk unless the walk already ended on its own refusal. I attacked the "git prints nothing for the commit it fails on" claim, every exit path of the walk, scoping, the Lite conversion and healthy-run output, and found no defect that changes the verdict. Every family I ran is green at `92c2371`, including the five fixtures that `02a065d` broke, with no `expected.txt` edited. Residual risk sits in one assumption git does not document (a failed commit leaves no partial record, F1) and in mutation evidence recorded in notes.md that I could not re-run (F3).

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-002..FR-004: the name-status failure is still a named refusal (`git log --name-status of <range> failed (git exited N)`), now emitted once after the walk (enforcement-pack.ps1:2343-2347) through the same `Set-AmendmentReadFailure`/`Test-AmendmentReadFailed` pair, so the prefix `AmendmentAuthority: cannot grade ` (line 289) is unchanged and the Lite conversion rule applies as before. `AMEND-011/fail-name-status` and the Lite twins pass. |
| Visual-reference match | N/A: governance tooling, no UI. |
| Feature contract held | `git diff 02a065d 92c2371 --stat`: `scripts/enforcement-pack.ps1` (28 lines), four AMEND-011 `recipe.json` files (description text only), `tests/enforcement/rules.json` (one `notes` string), and under `specs/029-...` `ai-code-review-phase2.md`, notes.md, plan.md, tasks.md. No `expected.txt` appears in the stat, so the five fixtures that `02a065d` broke (DIFF-001/fail, DIFF-001/fail-with-review-file, DIFF-002/pass, AMEND-009/fail-lite-failure-kept-beside-refusal, AMEND-009/fail-lite-unreadable-merge-parent) pass on their original expectations. No package, script or verdict word added. |
| Constitution / domain invariants | Constitution I: plan.md Amendment 2 and tasks.md Amendment 2 (arriving in this range from `6549d35`) each record `Amendment approved by: anas.m, 2026-10-16`; the implementer did not self-approve. |
| Security | Only read-only `git` calls; stderr still discarded (`2>$null`), exit code only. |
| Scope guard | All changed paths are inside the phase 2 Territory (`scripts/enforcement-pack.ps1`, `tests/**`, the feature's specs directory). Nothing else changed. `scope-check.ps1` was not re-run by me. |
| Rollback safety | A single commit on top of `02a065d`; reverting restores `02a065d` (known broken). |
| Healthy-run byte identity | `-KeepPartial` only changes the failure branch of `Read-GitLines` (line 245); the success return is untouched. `$script:NameStatusRead` is written in `Get-NameStatusBatch` (1468) and in Core (2189), read only at 2240 and 2344. `$nameStatusMissing` is a function-local in `Invoke-AmendmentAuthorityCore`, assigned at 2190 and 2241 and read at 2343 in the same function (no scoping defect). On a healthy read `.Ok` is true, so the new `elseif` (2240) is never taken and no new line prints. The healthy-output comparisons in the GITREAD-/AMEND-/LITE- cases pass. |
| Claim: git prints nothing for the commit it fails on | Probe in a throwaway repo (4 commits; c3 renames `f1.txt` to `h1.txt` with an edit; the blob of `h1.txt` deleted): `git log --reverse --format=%x1e%H --name-status` printed c2 completely (`\x1e<sha>`, blank, `A<TAB>g.txt`), then `fatal: unable to read <blob>`, exit 128; c3 printed no header at all, and c4 nothing. Consistent with git running `diffcore_std` (the blob-reading step) before `show_log` for a commit. Observed for one damage mode only (see F1). |
| Walk exit paths vs the after-walk refusal | Read lines 2205-2347. The note (2240) sits after the boundary decision and after `$gradedCount++`, so a pre-boundary, root or merge commit with no record is never noted (correct: they are not graded; a merge takes `Get-MergeAuthoredPaths`). Every `return` in the loop is a refusal of the walk's own, which the notes document as winning. The `continue` at the bad-record arm (2330) keeps the genuine failure and lets the loop reach 2343. The after-walk refusal can be lost only to a prior `return` or a pending `AmendmentReadFailure` printed at 2342, both intended. |
| Family runs at `92c2371` (detached worktree) | DIFF-: 86 passed, 0 failed (59 s). AMEND-: 288 passed, 0 failed (380 s). GITREAD-: 74 passed, 0 failed. LITE-: 122 passed, 0 failed. CRIT-: 228 passed, 0 failed. MICRO-: 100 passed, 0 failed. PHASE-: 88 passed, 0 failed. PACK-: 78 passed, 0 failed. PROV-: 86 passed, 0 failed. Total 1150 passed, 0 failed. |

## Findings

### F1 — A record that git started and did not finish would be graded as complete — MINOR

`Get-NameStatusBatch` (1468-1480) opens `$map[$sha] = @()` on every record-separator line and appends rows after it, and Core treats `ContainsKey($commit)` as "has a record" (2240). If git ever printed the header of a commit and then failed before printing all of its rows, that commit would be graded on a subset of its rows (or none), failing open. My probe (rename with a deleted blob) shows git prints nothing for the failing commit, and git's order (diff queue and `diffcore_std` before `show_log`; name-status output needs no further object reads) says the same. I did not test a damaged tree, a damaged commit object mid-walk, `--reverse` with many commits, or output past the stdio buffer size, so the claim is observed for one mode and reasoned for the rest, not proven. The code carries no defence if it is wrong.
*Action: implementer, optional hardening: on a failed read, treat the last record as incomplete (set `$nameStatusMissing` for it), at the cost of one possible extra refusal on an already damaged repository. Otherwise note in notes.md that the claim was measured on one damage mode.*

### F2 — A failed read whose missing commits are all ungraded passes without mentioning the failure — ACCEPTED

When the name-status read fails but every commit without a record is a root, a merge or pre-boundary, nothing is refused and the normal roll-up prints. That is correct for grading (those commits never needed rows) and consistent with 014 FR-009 on Lite; I found no case where a graded commit is unprotected, only an unreported failed read.
*Action: none; deliberate (the fix notes say it refuses "if a graded commit had none").*

### F3 — Mutations R1 to R3 are asserted in notes.md and were not re-run — DOC DRIFT

notes.md claims R1 (partial rows discarded) is caught by `AMEND-009/fail-lite-failure-kept-beside-refusal`, and R2 (after-walk refusal dropped) and R3 (missing record never noted) are both caught by `AMEND-011/fail-name-status`. I did not mutate the script (instructed not to touch scripts/). R1 is plausible from the code (it is exactly the `02a065d` state that exited 0 where 1 is expected). R2 and R3 share one fixture, so the guards are not independent, and no fixture shows a missing record beside a genuine failure on the numbered lane.
*Action: implementer, optional: add one numbered-lane fixture with a genuine failure plus a missing record, or note the shared guard in notes.md.*

### F4 — AMEND-011 descriptions changed with the fix; the exit-255 claim is unverified — MINOR

Four `recipe.json` descriptions and one rules.json `notes` string changed (G8 to G7, "exits 128" to "exits 255"). The fixtures still measure what they say: `fail`, `fail-tick-blob` and `fail-lite-show-record` damage a blob and expect the named refusal, `pass` is the readable twin, and all AMEND-011 cases passed within the 288 AMEND- count. I did not measure the exit code 255 for a truncated blob; the expectations do not depend on the number.
*Action: none.*

### F5 — The earlier approval of 02a065d carries no pointer to the correction — DOC DRIFT

`ai-code-review-phase2.md` approved `02a065d` after running only AMEND-011; notes.md records the miss and the lesson, but the earlier review file gives no forward reference.
*Action: owner, optional: add a one-line pointer to this review, or leave the dated, sequential files as they are.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

Range `02a065d..92c2371` carries plan.md Amendment 2 and tasks.md Amendment 2 (G8, G9, G10 injection-guarded), each recording `Amendment approved by: anas.m, 2026-10-16`. The fix commit `92c2371` itself edits no spec.md, plan.md or tasks.md text beyond those recorded amendments and a notes.md correction section.

## Constitution re-check (post-implementation)

PASS. I: amendments approved by a named person other than the implementer. No new rung or contract. The fix restores 027's pinned behaviour (a genuine failure kept beside a refusal on the Lite lane) and 014 FR-009 (Lite never newly failed on a condition the check cannot compute); the `AMEND-009` cases demonstrate both.

## Test coverage observed

On a detached worktree at `92c2371`: DIFF- 86/0, AMEND- 288/0, GITREAD- 74/0, LITE- 122/0, CRIT- 228/0, MICRO- 100/0, PHASE- 88/0, PACK- 78/0, PROV- 86/0 (passed/failed). The five fixtures that `02a065d` broke pass unedited. Critical assertions: `AMEND-009/fail-lite-failure-kept-beside-refusal` (kept genuine failure), `AMEND-009/fail-lite-unreadable-merge-parent`, `AMEND-011/fail-name-status` and its Lite twin (the after-walk refusal), DIFF-001/002 (the `graded 0 of N` roll-up on a damaged-subtree branch). Not run by me: the full harness, `scope-check.ps1`, `ritual-checks.ps1`, any mutation of the script.

## Residual risk

Concentrated in F1: the fix depends on git leaving no partial record for the failed commit, observed for a deleted-blob rename and reasoned for other modes. A violation fails open for one commit on an already damaged repository. Nothing here blocks merge; the owner's gate on this commit remains required, since the earlier "both exit 0" report is recorded in notes.md as not certifying phase 2.
