# Notes: feature 027 — grade amendments of another feature's approved documents

Evidence and decisions, kept out of the graded documents (a `Status` line takes only the bounded form `Approved <date> (owner: <name>)`, so the detail lives here).

## Owner decisions

- **Spec approved** (anas.m, 2026-10-14): option B (grade another feature's approved documents on numbered branches **and** the Lite lane, only for documents that exist at the diff base), with the removal sub-decision as recommended (a removal of another feature's approved document is graded and has no passing path in an ordinary commit). The owner's words: "option B, accept the removal, push the claim and write the plan".
- **Plan approved** (anas.m, 2026-10-14): decisions D1-D11 as recommended, and the three phases (D2 exists at the diff base; D3 a whole-directory move is a renumbering, a single moved document a removal; D6 the Lite gate is the changed-file list; D8 UNGRADED on the Lite lane; D11 the documents edited). The owner's words: "approve the plan, flip the roadmap row and push".

## Process note

The first approval commits of this feature carried a free-text `Status` line ("Approved (anas.m, ...) — option B chosen ..."). The status-only exemption of the amendment check (`StatusApprovedPattern`) accepts only the bounded form, so the check graded both commits as unapproved amendments and the branch failed `enforcement-pack`. A later commit cannot repair an earlier commit's grade, so the five commits were rebuilt with the bounded form and the detail moved here. This is the exemption working as specified (014 K2), not a defect in it.

## Phase 1: numbered branches grade any feature's documents

### Baseline (T001)

- Parent of the phase: `25bb263`, full harness on an isolated detached worktree: **1585 passed, 0 failed** (exit 0).
- The gap, on the parent: `AMEND-001/fail-other-feature-no-record` (a numbered branch appends to another feature's approved `plan.md`, no record) prints `enforcement-pack: OK`, exit 0. Thirteen of the 21 new cases differ from the parent's output (the eleven fail-direction `AMEND-001` cases, which print OK there, `AMEND-002/fail-other-feature`, and the merge twin `pass-merge-other-feature-hand-merged-record`, whose roll-up line differs because the parent skips the merge); eight pass on the parent by design (the named controls in `rules.json`).
- No fixture-library capability was needed: a base holding another feature's documents, a numbered branch, `rename`/`delete`, and a merge carrying content (`mergeWrite`, `mergeDelete`) already express every shape.

### What was built (T002-T004)

- 21 cases (42 tests): 19 under `AMEND-001` and 2 under `AMEND-002`, all with hand-written expectations (the generator lives in the session scratchpad, not in the repository). Every fail case matched its hand-written expected output on the first run of the new code, including the exact failure text and counts.
- `scripts/enforcement-pack.ps1`: `Get-GradedDocFeature` (the one pattern, plan D1), `Get-GradedDocSet` (the graded documents at the diff base, one `git ls-tree`, plan D2), `Get-OtherFeatureSubject` (the parallel arm of plan D3: creation, existence at the base, pure rename, whole-directory renumbering, tick, `**Status**` approval), `Get-OtherFeatureNote` (the clause of plan D5), `Get-FeatureDocMap` and `Get-MergeAuthoredPaths` widened to every feature (plan D4), and the tail grouped by document. The own directory's row block is verbatim; `Get-AddedRecordLines`, `Get-MergeRecordLines` and the exemption helpers are not edited.
- `tests/enforcement/rules.json`: notes of `AMEND-001` and `AMEND-002`, and `AMEND-010` (an exemption, below).

### Decisions taken at implementation, for the owner to see

1. **Plan D5 says "the tail is not changed", but its own fixture table and the spec (FR-005, "one conforming record per amended document") need per-document records for another feature's files.** With one record covering every amended path, a record in the branch's own approved plan would approve the other feature's amendment (`fail-other-feature-record-in-own-plan`). Implemented as the table and the spec say: the branch's own amended files are one group read as before (so a failure about the own directory alone is byte-identical), and each amended document of another feature is its own group. The D5 sentence is the imprecise one; if the owner wants the plan text corrected that is an amendment with an approver record, which I did not make.
2. **`AMEND-010` (the diff base's tree cannot be read) is an exemption, not a fixture.** I tried to reach it (a truncated `main^{tree}` with `-IgnoreAmendmentBoundary`) and the run ended on `graded 2 of 2` because the name-status batch comes back empty first, so a fixture would pin a different outcome under this rule's name. Two emission sites share the one text (`siteCount: 2`). The id `AMEND-009` stays reserved for phase 2 (plan D8).
3. **Order of reads in a merge:** the base tree is read only after the merge and its parents proved readable, so a damaged parent is still reported as itself (`AMEND-008`). The first version read the base first and `AMEND-008/fail` caught it in the full harness.
4. **A move out of the branch's own directory is not graded** (as today), stated in the function comment together with the other open limits.

### Mutations (T005)

Each applied to a copy of the script (the working script was never edited; `cmp` identical after), each shown failing exactly the fixtures meant to catch it:

| Mutation | Fixtures that failed |
|---|---|
| M1 drop the exists-at-the-base test (ordinary row) | `pass-other-feature-created-on-branch` |
| M2 test existence in the commit's parent instead of the base | `pass-other-feature-created-on-branch` |
| M3 drop the whole-directory test | `pass-other-feature-renumber-whole-dir` |
| M4 one record group for every amended file | `fail-other-feature-record-in-own-plan`, `fail-other-feature-two-docs-one-record` |
| M5 drop the other-feature clause | the 10 fail cases that print it, plus `AMEND-002/fail-other-feature` |
| M6 merge: drop the exists-at-the-base filter | `pass-merge-other-feature-created-on-branch` |
| M8 the other-feature arm returns nothing | the 8 ordinary fail cases and `AMEND-002/fail-other-feature` |
| M9 the merge reads only the own directory | 2 merge fails, `pass-merge-other-feature-hand-merged-record`, `pass-merge-other-feature-main-into-branch`, `pass-merge-other-feature-created-on-branch` |
| M7 never enter the arm (degenerate) | only 2: the fixture directories have names of equal length, so the own block happens to grade the other path; M8 is the meaningful version |

### Results (T006)

- `Run-Tests.ps1` on the working tree: **1627 passed, 0 failed** (1585 + 21 cases x 2 = 1627), coverage with no unowned site. `ritual-checks.ps1` is run by the owner as the gate.
- Cost: replaying two real merges of this repository, old script against new, took 1766 ms vs 1977 ms (abb4d47, two merges in range) and 1210 ms vs 1413 ms (22f2af4, one merge), so about 100-200 ms more per merge on this Windows machine (the base-tree read and a `ls-tree -r specs` per merge and parent), against 026's 170 ms.
- A first real-history signal, not the replay (phase 3 does that): replaying merge `22f2af4` (the 007 branch) under a numbered branch name now fails on commit `2462b41`, which amended feature 006's contract with no record, exactly the case the spec's table lists.

### After the AI review (`ai-code-review.md`, REQUEST CHANGES on 0d876a6)

- **F1 fixed.** A rename that moves another feature's graded document INTO the branch's own directory was routed to the own block, which skipped it (`$oldFeatureDir -ne $dir`). The row loop now sends a rename whose old path belongs to another feature to `Get-OtherFeatureSubject` too, which already graded the old path as a removal (or none when the old directory holds no graded document any more). Pair: `fail-other-feature-doc-moved-in` (001-a keeps its other documents) and its control `pass-other-feature-sole-doc-moved-in` (001-a held only `plan.md`, so the old directory is left empty). One condition differs. Mutation M10: reverting the fix on the working script fails exactly `fail-other-feature-doc-moved-in` (2 harness tests, "expected 1, observed 0, enforcement-pack: OK") and leaves the control green; restored afterwards.
- **Recorded gaps (F3, F5), not fixed in this phase:**
  - No mutation evidence yet for: the base-unreadable refusal (`AMEND-010`, exempt, 2 sites); the early returns for a move out of the own directory and for a move source absent at the base; the tick and **Status** exemption arms inside `Get-OtherFeatureSubject` (the merge twins exercise the same exemptions through another path); a move out of `specs/NNN-*` altogether. M7 stays degenerate (equal-length fixture directory names), and the reviewer's rerun with a much longer branch name found no defect behind it.
  - Cost grows with the number of features: a merge does `ls-tree -r` of `specs` per parent and for the base. Now stated in the function's LIMITS comment together with the move-in rule; phase 3's real-history replay is where it is measured at scale.
- **F2 is not mine to close:** the per-document regrouping of the tail departs from plan D5 ("the tail is not changed"). It needs the owner's amendment record or a redirect; no amendment is made here.
- **F4:** the task ticks and the CRIT-/LITE-/ritual-checks results wait for the gate run.
