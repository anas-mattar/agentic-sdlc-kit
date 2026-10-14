# AI Code Review — 027 Cross-feature amendment grading, fix commit 26a356c (review F1)

**Reviewer**: fresh-context review agent (claude-sonnet-5-5), independent of the implementing session
**Date**: 2026-10-14
**Branches**: agentic-sdlc-kit `027-cross-feature-amendment-grading` (commit `26a356c`, parent `0d876a6`)
**Scope reviewed**: `git show 26a356c` for `scripts/enforcement-pack.ps1` (row routing in `Invoke-AmendmentAuthorityCheck`, `Get-OtherFeatureSubject`, `Get-GradedDocFeature`), the two new fixtures under `tests/enforcement/cases/enforcement-pack/AMEND-001/`, the `AMEND-001` entry in `tests/enforcement/rules.json`, the notes.md addition; spec.md (FR-004, FR-007), plan.md D1-D11, tasks.md phase 1, notes.md, review-process.md (AI Review), the AI review template. The earlier `ai-code-review.md` was not read. Also built about 16 throwaway fixture repos outside the repo, graded with `enforcement-pack.ps1 -Root <fixture> -Branch 002-b`.
**Feature contract**: grade another feature's approved spec/plan/tasks/contracts documents on numbered branches; exemptions unchanged (FR-004); a removal has no passing path (FR-007); no new package.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: the separate session that produced commit 26a356c (Claude Sonnet 5.5; its conversation was not supplied to this reviewer)
- **Inputs provided**: commit 26a356c (parent 0d876a6), spec.md, plan.md, tasks.md, notes.md, docs/sdlc/review-process.md, specs/_templates/ai-code-review-template.md
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The fix does what it says: a rename whose old path is a graded document of another feature is now routed to `Get-OtherFeatureSubject`, which grades the old path as a removal unless the old directory holds no graded document any more. I built fixtures around the neighbouring shapes and found no shape the new routing mishandles beyond limits that already exist for between-directory moves. The new pair differs in one condition, the expected outputs are right, the rules.json text matches the case directories, and no pre-existing case changed (additions only; `Run-Tests.ps1 -Case AMEND-001`: 191 passed, 0 failed). Residual risk is two minor nits (a misleading commit message in a fixture, the sole-document rewrite exemption inherited from the renumbering rule).

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-007 (removal has no passing path): a fixture renaming 001-a/plan.md to 002-b/notes.md (non-graded destination) fails with the 001-a clause, and the graded-destination case fails the same way (new fixture). FR-004 renumbering exemption: all four 001-a documents moved into 002-b passes AmendmentAuthority. |
| Visual-reference match | n/a (no UI) |
| Feature contract held | No package, no change to exemptions, approver rule or message text; the script diff is 13 lines (routing condition and comments). |
| Constitution / domain invariants | Constitution I (Amendment authority): the new path cannot be satisfied by a record, as for a removal elsewhere (`fail-other-feature-removal`). |
| Security | n/a |
| Scope guard | `git show --stat 26a356c`: script, 027 notes.md, two fixtures, rules.json, and the earlier review file. `scope-check.ps1` not run by me (gate belongs to the owner). |
| Rollback safety | Single commit, revertible. Mutation M10 from notes.md was not re-run by me; the fail fixture fails on the parent by construction (the old condition tested only `$path`). |

Shapes tried (fixture repo: approved 001-a with spec, plan, tasks, contracts/api.md, notes.md; 002-bc with spec; 004-d with spec; branch 002-b). Only the AmendmentAuthority outcome is listed.

| Shape | Result |
|---|---|
| Copy (status C, original stays) of 001-a/plan.md into 002-b | not graded (creation), correct: `$oldDocFeature` is set for `^R` only |
| Rename 001-a/notes.md (not a graded path) into 002-b/contracts/ | not graded, correct |
| Rename 001-a/plan.md to 002-b/notes.md (destination not graded) | fails as removal of 001-a/plan.md |
| Rename 001-a/contracts/api.md into 002-b/contracts/api.md (nested path) | fails as removal |
| All four graded documents of 001-a moved into own directory | passes (D3 step 4), correct |
| Split move: one document into own directory, the rest to 003-c | each row judged against the post-commit tree; remaining documents graded as removals |
| Other feature `002-bc` (name has own `002-b` as prefix) with a second document, spec.md moved in | fails naming 002-bc/spec.md; no prefix confusion (exact feature-string compare) |
| Sole document of 004-d moved in with a low-similarity rewrite | graded as removal (git reports D + A) |
| Rename out of specs entirely (docs/plan.md) | graded as removal (pre-existing behaviour, unchanged) |
| Own plan.md renamed inside own directory | unchanged path, unchanged output |
| Moved-in document plus a record in own files | the amended group is the old path in 001-a, so a record in 002-b approves nothing; follows from the existing per-document grouping (`fail-other-feature-record-in-own-plan`), not separately reproduced |
| Rename inside a merge | not reachable through the changed branch (a merge uses `Get-MergeAuthoredPaths`); not changed by this commit |

## Findings

### F1 — Pass fixture's commit message names the wrong target — MINOR

`tests/enforcement/cases/enforcement-pack/AMEND-001/pass-other-feature-sole-doc-moved-in/recipe.json` (last commit): the message reads "move 001-a plan to 003-c" while the rename goes to `specs/002-b/contracts/moved.md`. It was copied from a sibling. The message does not enter expected.txt, so nothing fails, but a reader of the control is misled about its one condition.
*Action: implementer rewords it to "move 001-a plan into 002-b (the only document of 001-a)".*

### F2 — A sole graded document moved in and edited in the same commit is not graded — MINOR

When the old directory holds no other graded document, `Get-OtherFeatureSubject` returns `$null` before any content comparison, so a rename git reports as R with an edit goes ungraded. This is the same limit as the existing between-directories renumbering exemption (D3 step 4, J3). I could not reproduce it: my attempts used small files that git reported as D + A, which fail. This finding is derived from the code, not observed. notes.md's limits list does not name it for move-in.
*Action: implementer adds one line to the limits comment/notes.md ("a sole document moved in and edited stays ungraded, like a renumbering"), or none if the owner accepts it as inherited.*

### F3 — Failure wording for a removal tells the author to add a record — MINOR (pre-existing)

For the moved-in removal the output says "Add '**Amendment approved by**…' to the amended section", but the amended path is gone, so no record can pass (FR-007). Identical to `fail-other-feature-removal` and `fail-other-feature-single-doc-moved`; this commit did not introduce it. FR-007 says the guidance should say so.
*Action: owner decides whether a later phase's guidance covers it; none for this commit.*

### F4 — Pass fixture's `command.json` has no trailing newline — MINOR

Cosmetic; the sibling fail fixture has one. The harness reads it fine.
*Action: none required.*

## Amendments in this diff

- [x] None. The diff touches no spec.md, plan.md, tasks.md or contracts/ of any feature other than 027's notes.md, which is not a graded document.

## Constitution re-check (post-implementation)

PASS. Constitution I (Amendment authority) now holds for the move-in shape; no other principle engaged.

## Test coverage observed

`pwsh -File tests/enforcement/Run-Tests.ps1 -Case AMEND-001`: 191 passed, 0 failed, 0 skipped. The directory holds 66 cases, with 12 fail and 9 pass among the `other-feature` ones, matching the rules.json text ("sixty-six", "twenty-one", "Twelve fail", "Nine pass"). The new pair differs in exactly one condition: commit 0 of the fail fixture adds `specs/001-a/spec.md`, `tasks.md` and `contracts/api.md`; the later commits and the rename are identical, so the control leaves the old directory empty and the fail leaves it holding documents. Expected outputs match what the check prints (roll-up "graded 2 of 2", one failure naming 001-a/plan.md with the other-feature clause). `git diff 0d876a6 26a356c --stat -- tests` shows only added files and the one rules.json line; no existing case changed.

## Residual risk

Low. The routing now sends every rename with a graded old path in another feature through the one function that already owned the removal and renumbering rules. The remaining exposure is the inherited sole-document exemption (F2) and cosmetic fixture hygiene (F1, F4). Merge after the owner runs the gate.

### Implementer dispositions (appended; the reviewer's text above is unedited)

| Finding | Disposition |
|---|---|
| F1 | **Fixed.** Commit message in the pass fixture's `recipe.json` now reads "move 001-a plan into 002-b". |
| F2 | **Recorded as a limit** in `notes.md` and the LIMITS comment of `scripts/enforcement-pack.ps1`; not fixed (same exemption as the whole-directory renumbering, D3 step 4). |
| F3 | **Deferred**: pre-existing text of two earlier cases; to be considered with phase 3's guidance. |
| F4 | **Rejected**: cosmetic, no effect on the harness. |
