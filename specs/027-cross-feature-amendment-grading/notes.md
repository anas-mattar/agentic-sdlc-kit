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

### After the second AI review (`ai-code-review-f1-fix.md`, APPROVE with follow-ups on 26a356c)

- **F1 (label):** the pass fixture's rename commit message said "to 003-c" while the rename goes into 002-b; corrected. The expected output does not carry the message.
- **F2 (limit, recorded not fixed):** a sole graded document of another feature moved into the own directory AND edited in the same commit stays ungraded: `Get-OtherFeatureSubject` returns `$null` for a move that empties the old directory before any content comparison, as the whole-directory renumbering exemption always has (D3 step 4). Derived from the code by the reviewer, not reproduced. Now in the LIMITS comment.
- **F3 (pre-existing):** a removal's failure text asks for an approver record that cannot pass (FR-007); the text belongs to `fail-other-feature-removal` and `fail-other-feature-single-doc-moved` and predates this fix. To be considered with phase 3's guidance.
- **F4:** the missing trailing newline in one `command.json` is cosmetic; left.

### D5 amendment (review F2 closed)

The owner (anas.m) approved the D5 amendment on 2026-10-14: plan.md D5 now carries a "D5 as built" paragraph with the record `**Amendment approved by**: anas.m, 2026-10-14`, describing the per-document grouping and the clause as built. Decision 1 above is therefore settled; the implementer did not approve it.

## Phase 2: the Lite lane

### Baseline (T007)

- Parent of this phase: `4982b51` (the phase 1 tip, pushed, CI green). Full harness on it: **1631 passed, 0 failed** (run on `91f88af`; `4982b51` only ticks checkboxes). The Lite and docs/ cases hold their expectations unchanged: `LITE-001/pass` prints `enforcement-pack: OK` after its header line; `LITE-002/*` and `LITE-003/*` print their `LiteAndAbuse` lines only; the docs/ lane line (`GAP27-001/*`, `PACK-004/fail`) reads "review-provenance is the only scripted check that applies".
- The gap this phase closes, reproduced on the unchanged script with the fixtures below (a throwaway `docs/x` branch off a base holding approved `001-a`): `docs/x` amending `001-a/plan.md` with no record printed `enforcement-pack: OK` and exited **0** with no `AmendmentAuthority` line at all; the same on `fix/x` and `chore/x`; and `docs/x` removing `001-a/contracts/api.md` also exited 0. Measured by running all 28 Lite-relevant cases against the parent script (`4982b51`): 11 differ, 17 are byte-identical. Five differ in the verdict, exiting 0 where 1 is expected: `fail-lite-docs-no-record`, `fail-lite-fix-no-record`, `fail-lite-chore-no-record`, `fail-lite-docs-removal`, `fail-lite-docs-moved-off-specs`. Four differ only by the new roll-up line, with the same exit: the three record twins (`pass-lite-docs-record`, `pass-lite-fix-record`, `pass-lite-chore-record`) and `fail-lite-fix-contract-refused-first` (the same single LiteAndAbuse failure as before). Two differ because the parent says OK where this phase says UNGRADED: `AMEND-009/fail` and `fail-lite-unreadable-parent`. The other 17 are the controls and the pre-existing `LITE-*`, `PACK-004` and `GAP27-001` cases, unchanged.

### What was built (T008-T010)

- `scripts/enforcement-pack.ps1`: `Invoke-AmendmentAuthorityCheck` is now a thin entry point and the body is `Invoke-AmendmentAuthorityCore` (same name kept on the entry because the boundary asks a parent tree whether it defines that function). The entry: the Lite arm runs only when the diff holds a graded path (plan D6, read from the dispatch's changed-file list plus a second read without rename detection); it calls the core with `-Lite` (no own directory, `$dir = ''`); and a refusal text the numbered lane fails on is moved to `$ungraded` (plan D8). The core: an empty range prints nothing on a Lite branch (D7), the roll-up prints only when a commit touched a document that exists at the base (D6), and the other-feature clause reads without an "own directory" on a Lite branch. The dispatch calls the entry from the `fix|chore` arm (after LiteAndAbuse) and the `docs` arm; the `docs/` lane line names both checks when the roll-up printed. The numbered arm and the own-directory block are not edited.
- 19 new fixtures: 14 under `AMEND-001` (the Lite variants), 1 under `AMEND-006` (`pass-lite-docs-empty-range`), 4 under the new rule `AMEND-009`; expectations written by hand from the numbered fixtures' wording, then checked against the run (the first twelve matched on the first run; the rest were written after the shallow and unreadable-parent states were measured). Plus one recipe field, `shallowAllBranches`, in `tests/enforcement/lib/FixtureRepo.psm1` with two harness self-tests: a plain shallow fixture has no diff base, so the Lite shallow condition (a clone that is shallow and still has a base) could not be built without it. It sits in `tests/**`, the phase's territory.

### Decisions taken at implementation, for the owner to see

1. **One conversion site, not one site per condition.** Plan D8 says "one `ungraded` per condition". I did not touch the numbered lane's emission sites (each `$script:failures +=` keeps its rule and count): the Lite arm moves the refusal text from the failures to `$ungraded` after the core returns, matching on the texts' stable prefixes (`cannot grade`, `could not parse commit metadata`). The behaviour is D8's (each condition appends one UNGRADED line with its reason and no failure); the mechanism is a single `$script:ungraded += $f` site, owned by `AMEND-009`. If the owner wants per-condition sites, that is a plan amendment; I have made none.
2. **The gate list is read twice.** `Get-ChangedFiles` reports a renamed file by its new path only, so a spec document moved off `specs/` would never reach the gate. The entry reads `git diff --name-only --no-renames <base> HEAD` as well; `fail-lite-docs-moved-off-specs` and its control pin it.
3. **Reachable UNGRADED fixtures: the shallow clone and the unreadable parent** (the latter by `truncateBlob` of the script copy, AMEND-005's damage mode; truncating a parent TREE does not work: `git log --name-status` then returns nothing and the walk ends on `graded N of N` and OK, the same blind spot `AMEND-010` records for the base tree). That empty-batch behaviour is pre-existing on the numbered lane too and is not addressed here.
4. **`AMEND-009` uses the directory names `pass` and `fail` for the shallow pair** (the coverage check requires them); the `pass` direction is the numbered twin, which exits 1 because the numbered lane keeps its refusal, as `GAP27-001/pass` already does.

### Mutations (T011)

Each applied to a copy of the script placed beside it, run over the 28 Lite-relevant cases (all Lite fixtures, `LITE-*`, `PACK-004`, `GAP27-001`), then removed; the working script was never edited. Unmutated: 28 checked, 0 differing.

| Mutation | Fixtures that failed |
|---|---|
| M11 drop the changed-file gate | `AMEND-001/pass-lite-docs-readme-only-shallow`, `GAP27-001/fail` |
| M12 fail instead of UNGRADED on the Lite lane | `AMEND-009/fail`, `AMEND-009/fail-lite-unreadable-parent` |
| M13 print the roll-up unconditionally | `pass-lite-docs-claim-creation`, `pass-lite-fix-creation-only` |
| M14 drop the rename-blind second read of the gate | `fail-lite-docs-moved-off-specs` |
| M15 own-directory clause on a Lite branch | the 5 Lite fail fixtures that print the clause |
| M16 move amendment failures to UNGRADED too | the same 5 |
| M17 the docs/ line never names both checks | `fail-lite-docs-no-record`, `fail-lite-docs-removal`, `fail-lite-docs-moved-off-specs`, `pass-lite-docs-record` |
| M18 an empty range on a Lite branch names itself | `AMEND-006/pass-lite-docs-empty-range` |

The task's fourth mutation, "call the check on `main`", cannot be caught by any fixture: on the trunk the diff base is `HEAD` itself, so the changed-file list is empty and the gate is silent whatever the dispatch calls. Recorded as degenerate rather than papered over with a fixture that would pass either way.

### Limits stated (and in the LIMITS comment)

- A Lite branch with no diff base is not graded and prints nothing from this check (the dispatch's existing warning stands); `Get-ChangedFiles` returns an empty list when `git diff` fails (plan D6, GAP-034).
- The Lite shallow UNGRADED fixture needs a clone that is shallow and still has a base; a plain depth-1 checkout has no base, so the gate is silent there, as the control `pass-lite-docs-readme-only-shallow` shows.

### Results (T012)

- Full harness on the working tree: **1671 passed, 0 failed, 0 skipped** (1631 + 19 new fixtures x 2 tests + 2 harness self-tests = 1671), coverage with no unowned site. Every pre-existing case is unchanged except the intended `docs/` line variant, which only appears where the roll-up printed.
- Re-run of T007's reproduction on the new script: `docs/x`, `fix/x` and `chore/x` amending `001-a/plan.md` with no record now exit **1** and name the file and its feature; with a record and the approver in the message they exit 0 and print the roll-up (SC-002).

### After the Phase 2 AI review (`ai-code-review-phase2.md`, APPROVE with follow-ups on 8c52853)

- **F1 accepted as a limit by the owner.** A branch that only CREATES a spec document, in a clone that is shallow but still has a base, prints an UNGRADED refusal where it used to print nothing (exit code unchanged): the gate sees a spec path before the walk can tell a creation from an amendment. Stated in the LIMITS comment.
- **F2 recorded as a limit.** The gate reads the net diff, so amend-then-revert with no record, or a replay over a range whose net diff is empty, is silent. Stated in the LIMITS comment.
- **F3 fixed.** The conversion is coupled to the text of the refusals. A guard now holds the two sides apart (`Coverage.Tests.ps1`, "the Lite lane converts refusals by their text"): every refusal literal of the core matches the conversion pattern, and no grading failure does. Fixtures added under `AMEND-009`: `fail-lite-unreadable-merge-parent` (the merge refusal, with the damage on a side branch because AMEND-008's placement on main, the diff base, empties the gate's diff) and `fail-lite-failure-kept-beside-refusal` (its twin with no record: a real amendment failure stays a failure, the refusal beside it is UNGRADED). The no-base refusal is dead on Lite (a null base keeps the gate silent), and the base-tree and metadata refusals stay exemptions (`AMEND-010`, `AMEND-007`); the guard covers their text.
- **F4 fixed.** Lite merge pair under `AMEND-001`: `fail-lite-merge-hand-merged-no-record` and `pass-lite-merge-hand-merged-record`, whose roll-up line can only come from the merge-path `touchedApproved` line.
- **F5 fixed.** The literal `\n` in a comment in `Harness.Tests.ps1`. The `AMEND-009/pass` direction is the numbered twin and exits 1, as already disclosed.
- **A line the review did not raise, found while building F3's fixture:** on a Lite branch that ends on a refusal, the docs/ lane line still reads "review-provenance is the only scripted check that applies", because the plan words the rule as "names both checks when the roll-up printed" and the core returns before printing it. Stated in the LIMITS comment; changing it would be a plan amendment.

Mutations for the new guards, same method as T011 (copy beside the script, or the real script restored by `finally`; the working script ends with no diff):

| Mutation | Caught by |
|---|---|
| M19 drop the merge-path `touchedApproved` line | `fail-lite-merge-hand-merged-no-record`, `pass-lite-merge-hand-merged-record` |
| M20 drop the `could not parse commit metadata` branch of the conversion pattern | the Coverage guard |
| M21 widen the conversion pattern to every `AmendmentAuthority:` text | the Coverage guard, and the Lite fail fixtures (their exit and output) |

## Phase 3: guidance, retirement of the limit, flow-down and replay

### T013 — what the documents say

- **Constitution I, Amendment authority** (`.specify/memory/constitution.md`, the clause at "Amendment authority"): it already says "that feature's `spec.md`, `plan.md`,
  `tasks.md` or `contracts/`" for every approved feature, and the record and the approver in the commit message are unchanged by this feature. **No constitution amendment is
  needed** (plan D11, as expected).
- **`docs/sdlc/critical-delivery.md`:** no sentence says the Lite lane runs no amendment check. Its merge-readiness limits paragraph speaks of the branch's own plan and merges
  and stays true. **Not edited.**
- **`docs/sdlc/branch-strategy.md`:** the Lite lane text ("skips spec.md/plan.md/tasks.md, but still requires the user-run gate, the scope check and human review") is true
  about creating spec documents, but read alone it implies a Lite branch owes nothing about an approved spec document, which is the premise the spec quoted. It is incomplete
  rather than false, and FR-014 asks for the guidance to say what is now graded, so **one sentence and one digest marker were added to it** (no existing sentence changed).
  This is a small step past T014's "only the false sentences"; it is flagged for the owner.
- **`docs/sdlc/flow.md`** (Lite bullet) and the critical-delivery level table row for Lite list the gate, scope check and human review; neither says no amendment check, and
  neither is in this phase's Territory. Left.
- **`adoption/updating.md`, feature 026's note** says "the Lite lane (`fix/`, `chore/` and `docs/` branches do not run this check)" and its edge case "a document the merge
  changes for another feature: not graded". Both are superseded by this feature for documents that exist at the base; 026's note is history and is not edited, the new note says so.

### T017 — replay on real history (plan D10, FR-010, SC-004)

Method: clones of FitForge, FlowBoard and ExpenseTracker made from their local directories and of this repository (`git clone --local --no-hardlinks`, `core.autocrlf=false`; the
real projects untouched, nothing pushed). For every merge commit reachable from any ref whose subject names a merged branch (`Merge pull request #N from <owner>/<branch>`, or
`Merge branch '<branch>'` not followed by `into`), taking the branch name from the subject: the clone is checked out detached at the merge, `main` and `origin/main` are set to
the merge's first parent, so the run has the shape CI grades a pull request (`<merge>^1..<merge>`); each run passes `-Branch <name> -ReplayBase <merge>^1 -ReplayTip <merge>
-IgnoreAmendmentBoundary`. The parent kit's `enforcement-pack.ps1` (`25bb263`, the parent of the first script change `0d876a6`) against this one (`c94bac1`), each taken with
its own `scripts/` from a scratch directory outside every clone with `-Root` the clone (a deviation from T017's wording "placed inside the clone": placing them inside would have
dirtied the tree being checked out per merge; each version reads the clone as its project either way, as in 026's method). The driver and its JSON are kept outside the
repository. Merges whose subject names no branch (a `main` merged into a branch, `governance:` merges) were not replayed: the first are inside their branch's range, the rest have no
branch name to grade.

| History | Merge commits | Replayed | Numbered | Lite | Newly graded | Newly failing | Newly failing with a record in the amended document | Outputs that differ | Largest run, old (new) |
|---|---|---|---|---|---|---|---|---|---|
| FitForge | 10 | 5 | 1 | 4 | 0 | 0 | 0 | 0 | 26 commits, 9.2 s (8.9 s) |
| FlowBoard | 10 | 8 | 4 | 4 | 0 | 0 | 0 | 0 | 23 commits, 5.5 s (4.5 s) |
| ExpenseTracker | 10 | 8 | 3 | 5 | 0 | 0 | 0 | 0 | 9 commits, 4.0 s (3.5 s) |
| this kit | 107 | 88 | 28 | 60 | 2 | 2 | 1 | 3 | 50 commits, 7.2 s (6.9 s) |
| **Total** | **137** | **109** | **36** | **73** | **2** | **2** | **1** | **3** | |

**106 of 109 runs are byte-identical** (output and exit code), including every run on the three adopted projects. The three that differ, all in this kit's history:

- **`59deae2`, `docs/026-fr-003-rename-amendment`: exit 0 to 1, newly graded.** Commit `c6f383d` amends 026's `spec.md`, **carries** `**Amendment approved by**: anas.m, 2026-10-14` in
  that document, but its commit message does not name the approver. This is the "PR #81" shape the spec cites. An honest owner would have been blocked, by the missing approver
  in the message and not by a missing record.
- **`c28a867`, `fix/enforcement-pack-main-branch`: exit 0 to 1, newly graded.** Commit `40142f2` edits 002's `spec.md` (an Edge Cases line) with no record and no approver; it predates
  feature 014, so there was nothing to comply with. **Carries no record.**
- **`22f2af4`, `007-adoption-doctor`: exit 1 to 1** (the 007 branch already fails on its own directory under the old script, the shape 026 reported). The new run adds the
  cross-feature clause to three more lines (commits `2462b41`, `dddcf1f`, `1fe7b9b` also amend 006's and 004's contracts). Not newly failing, no commit newly failing.

**What it shows:** no unrelated branch would have changed: 106 of 109 runs are byte-identical, the adopted projects' histories are untouched, and per-run time is unchanged within noise
(the new run is no slower on any of the four largest runs). **What it does not show:** how easy a newly failing branch is to satisfy (two cases, one of them predating the rule), how
often a Lite branch will amend a spec document from now on, anything about a run in an adopted project's own CI, a shallow clone (a clone from a local directory is complete) or
an octopus merge (none exists in these histories). A run grades the documents as they stood, with the version of the script under test and the clone's own files.
