# AI Code Review — 026 Grade the content a merge commit authors, phase 2

**Reviewer**: fresh-context agent, Claude Opus 5.5 (claude-opus-5-5)
**Date**: 2026-10-14
**Branches**: kit repository `026-merge-commit-amendment-grading`. Phase 2 commit `bb08af7` (parent `2977ca5`), then `9d899c9` (notes: gate certified). Branch tip at review start: `9d899c9`.
**Scope reviewed**:
- `git show --stat bb08af7`; the full diff of `scripts/enforcement-pack.ps1` and `tests/enforcement/rules.json` (`git diff 2977ca5 bb08af7 -- ...`).
- `scripts/enforcement-pack.ps1`: the whole of `Invoke-AmendmentAuthorityCheck` (lines 1755-1929) and the helpers it calls: `Get-BlobLines`, `Get-VisibleFromText`, `Get-AddedRecordLines`, `Test-CheckboxOnlyChange`, `Test-StatusOnlyChange`, `Get-ConformingRecord`, and the new `Get-FeatureDocMap`, `Get-AutoMergeTree`, `Get-MergeAuthoredPaths`, `Get-MergeRecordLines`.
- Every new case under `tests/enforcement/cases/enforcement-pack/AMEND-001/*merge*` (17) and `AMEND-002/*merge*` (2). I read the deletion recipe in full and diffed six fail/pass pairs recipe against recipe.
- `specs/026-merge-commit-amendment-grading/`: `spec.md` (FRs, Edge Cases, Assumptions), `plan.md` (D1-D11, Risks), `tasks.md` (phase 2 = T005-T010 and its Territory), `notes.md` ("Phase 2"), and `ai-code-review-phase-1-round-2.md` for shape.
- `tests/enforcement/lib/FixtureRepo.psm1` lines 413-446 (`truncateBlob`, `truncateCommit`).
- `specs/_templates/ai-code-review-template.md`.

**Feature contract**: plan D1-D7 and D9. A merge is skipped only when it authored nothing for the feature's graded documents. A document is authored unless one of these holds:
- it is absent in every parent;
- it equals a parent's blob;
- it equals git's automatic merge of two parents;
- a tick-only or Status-only exemption holds against every parent.

An authored merge goes through the same record and approver-in-message tail as any commit, and the record must be new against every parent. A merge that authored nothing produces byte-identical output. An octopus merge, an old git or a failing merge-tree falls back fail-closed. An unreadable merge is refused (`AMEND-008`). The ordinary-commit path and `Get-AddedRecordLines` are not edited. The code Territory is `scripts/enforcement-pack.ps1` and `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5) session
- **Inputs provided**:
  - Phase 2 commit `bb08af7` (parent `2977ca5`) and the notes-only commit `9d899c9`.
  - `specs/026-merge-commit-amendment-grading/{spec.md, plan.md (D1-D11), tasks.md (phase 2 = T005-T010), notes.md ("Phase 2")}`.
  - `.specify/memory/constitution.md` I (Amendment authority), `docs/sdlc/review-process.md` and `specs/_templates/ai-code-review-template.md`.
  - The prior review `specs/026-merge-commit-amendment-grading/ai-code-review-phase-1-round-2.md`, for shape.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES.** The core works for the shapes the fixtures build. I reproduced the following myself:
- `-Case merge`: 105 passed, 0 failed.
- Three of the claimed mutations each fail exactly the fixtures notes.md names.
- A replay of six real merges in the kit's own history gives the same output under the old and the new script.
- A clean automatic merge over contracts whose names hold non-ASCII, space, quote and bracket characters is correctly skipped, and a hand edit to one is correctly graded.

Three problems stop approval.

**F1 (BLOCKING).** A merge that deletes, or renames and rewrites, a graded contract is still skipped in the ordinary field shape, where the other parent never had the file. That is a fail-open. It contradicts plan D3 ("a path present in a parent and absent in the result is a deletion, which is graded") and the D9 row for deletion. The deletion fixture passes only because it was built with the file in both parents.

**F3 (MAJOR).** `AMEND-008` is declared unreachable in `rules.json`, and it is not. A recipe field that already exists reaches it.

**F2 (MAJOR, owner decision).** A whole-side resolution can take a document from a parent whose own commit was exempt as a first appearance. That launders a full replacement of an approved plan with no record.

The rest are MINOR or documentation. Residual risk sits in the equality rule of D1 (F1, F2) and in the inventory (F3).

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | **FR-001, FR-002, FR-003**: implemented for modifications. The clean-automatic and conflict shapes behave as the fixtures pin them. Deletion and rename inside a merge do not (F1).<br><br>**FR-004**: the count line is unchanged for merges that authored nothing. Authored merges count as graded.<br><br>**FR-005**: the refusal exists (F3 concerns its inventory).<br><br>**FR-007, SC-004**: `-Case merge` in a detached worktree of `9d899c9` printed `Tests Passed: 105, Failed: 0`. The full harness on the same worktree: see Test coverage.<br><br>**SC-001 spot check**: in a clone of the repository, I ran the old (`2977ca5`) and new scripts with `-ReplayBase m^1 -ReplayTip m^2 -IgnoreAmendmentBoundary` over five feature ranges with six merges (025, 024, 021 ×2, 017, 016). The `AmendmentAuthority` lines were identical, for example `graded 26 of 28 commit(s) ... (2 not graded: 2 merge commit(s))` for 021 under both. |
| Visual-reference match | N/A: no UI. |
| Feature contract held (no unapproved table/migration/permission/package) | No package and no new script. `git merge-tree --write-tree` is the only new git verb, and it is stated in plan D2. Two lines of the ordinary path were edited, but neither changes behaviour (F8). `Get-AddedRecordLines` is untouched: the diff has no hunk in it. |
| Constitution / domain invariants | Constitution I is extended to merges as planned, with no amendment. F1 and F2 are places where a merge still changes an approved document with no record. |
| Security (authn/authz, secrets, sensitive logging) | The check is read-only except for `merge-tree` writing unreferenced objects, which is stated. On a 40-merge branch where no merge touched the feature directory, the object count was 424 before the run and 424 after: merge-tree is lazy and was never called. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | `pwsh -NoProfile -File scripts/scope-check.ps1 -Commit bb08af7` gave `scope-check: PASS phase 2 commit bb08af7 (60 file(s))`. The commit touched `scripts/enforcement-pack.ps1`, `tests/**` (57 files) and the feature's `notes.md`, which is allowed. |
| Rollback safety (phase reverts cleanly; schema additive?) | Reverting `bb08af7` restores the unconditional skip and removes the fixtures. No data and no schema. |

## Findings

### F1 — A merge that deletes, or renames and rewrites, a graded contract is skipped when the other parent never had it — BLOCKING

**Where.** In `Get-MergeAuthoredPaths`, the line `if ($inParents.Contains($m)) { continue }` treats absence as a value ("absence counts as a value"). If the merge removed the file (`$m = ''`) and any parent lacks it, the merge counts as "equal to a parent".

**Why the usual merge hits this.** In a `Merge branch 'main' into NNN-...`, `main` never holds the branch's `specs/NNN-name/`. So every deletion inside such a merge is exempt. A contract renamed and reinterpreted inside the merge is also fully exempt:
- the new path is absent in every parent, so it counts as a first appearance;
- the old path is absent in `main`, so it is exempt by the same equality.

An ordinary commit grades both shapes (H3, `fail-rename-content`). Structure catches a deleted `spec.md`, `plan.md` or `tasks.md`, but nothing catches `contracts/**`.

**Why the fixture misses it.** `AMEND-001/fail-merge-deletes-approved-document` forks `side` from the branch after the contract exists, so both parents carry it (its own description says "which both parents carry"). That is not the field shape D9 requires.

**Evidence.** I built a scratch repository with `scratchpad/mk.sh`:
- `main`: init;
- `001-thing`: approved docs, a stub check and `contracts/api.md`, then a phase commit;
- `main` advances.

Each merge below was then run with `pwsh -File scripts/enforcement-pack.ps1 -Branch 001-thing -Root <repo>`:
- `git merge --no-ff --no-commit main; git rm specs/001-thing/contracts/api.md; git commit` printed `AmendmentAuthority: graded 1 of 3 commit(s) ... (2 not graded: 1 merge commit(s); 1 made before the check existed (plan D2b))` and `enforcement-pack: OK`.
- `git mv contracts/api.md contracts/api-v2.md` with the body changed to "returns 204 and deletes everything", inside the same merge, gave the same `OK`.
- The same rename-and-rewrite as an ordinary commit gave `FAIL ... commit aa85245 amends specs/001-thing/contracts/api.md after approval with no conforming approver record`.

**Conflict between rungs.** spec FR-002 ("equals any parent's version") and the spec's Assumption (git's combined diff is the definition) can be read to exempt this. Plan D3 and D9 say a deletion is graded. Per the conflict rule this is reported, not chosen.

*Action: implementer, with the owner confirming the reading.*
- For a document absent from the merge, do not accept "equal to a parent" from a parent that never had it. One way: when `$m -eq ''`, skip only if every parent lacks it, or if the automatic-merge tree also lacks it. That keeps `-s ours` and both-sides-deleted silent.
- Add field-shaped fixtures: main merged into the branch and deleting a contract, and renaming and rewriting a contract. Show both failing on `bb08af7`.

### F2 — A whole-side resolution launders a full replacement through a parent whose own commit was a first appearance — MAJOR (CONFIRM: owner decision)

**How.** D1 accepts a document equal to any parent's blob. Its stated justification is that the parent's own commits were graded (spec Assumptions). Suppose the parent's commit added the file:
- it is status `A`, so the first-appearance exemption applies;
- or it is a root commit, skipped as D2;
- or its parent predates the check.

Then nothing ever graded that content.

**Evidence.**
1. Starting from the same scratch repository, run `git checkout -b launder <root commit of main>`.
2. Add `specs/001-thing/plan.md` with `**Gate Certification**: ci-held` and "Five phases, no review.", then commit.
3. On `001-thing`, run `git merge --no-ff --no-commit launder`. The result is an add/add conflict.
4. Run `git checkout --theirs specs/001-thing/plan.md` and commit.

The approved plan is fully replaced. The run printed `graded 2 of 4 commit(s) ... (2 not graded: 1 merge commit(s); 1 made before the check existed (plan D2b))` and `enforcement-pack: OK`.

**Status.** This is not a regression: the parent `2977ca5` skipped every merge. But it is a two-commit path around the gap this feature closes, and it is not what plan Risks or the new `LIMIT` comment say. The comment says "a branch never graded stays ungraded", but here the side commit is in the graded range and passes through an exemption.

*Action: owner.*
- **Either** accept it and state it precisely in the `LIMIT` comment and the phase 3 documents (a parent's version is trusted even when its only grading was a creation exemption),
- **or** narrow D1 for two-parent merges. For example, when the automatic merge is computable and conflicted on that path, accept only equality with the automatic merge or with the parent whose version descends from the merge base. Add a fixture either way.

### F3 — `AMEND-008` is reachable; the `rules.json` exemption is not true — MAJOR

**What the inventory says.** The exemption says a merge whose "parent commit (or tree) cannot be read" cannot be reached while the earlier guards succeed. `notes.md` T006 says the same.

**Why it is reachable.** `git merge-base` and `rev-list` walk commits, not trees. `Get-CommitMetaBatch`'s `git log --name-status` prints no diff for a merge, and the `main`-side parent is outside the range. So a parent whose commit object is intact and whose tree is not passes every earlier guard. The existing recipe field `truncateCommit` passes its value to `git rev-parse`, which accepts `HEAD^2^{tree}`.

**Evidence, by hand.** I built a clean main-into-branch merge, then truncated the tree object of `HEAD^2` (`head -c` to half size). Output:
```
enforcement-pack: branch '001-thing', diff base '1ece492...', 0 changed file(s)
enforcement-pack: FAIL (1 issue(s)):
  - AmendmentAuthority: cannot grade '001-thing' — 1ece492 (the merge 980c8eb or one of its parents) is not readable in this clone, so what the merge authored is unknown; ...
```
Exit 1. The same happens when the object is deleted instead of truncated.

**Evidence, through the harness.** In a scratch worktree, I made the recipe of `AMEND-001/pass-merge` with `"truncateCommit": "HEAD^2^{tree}"` added. Then I ran the kit script on the kept fixture repository (`-KeepRepo`). It printed the `AMEND-008` sentence: `cf22a86 (the merge cf22a86 or one of its parents) is not readable`. Here the merge shares its tree with `HEAD^2`, so the merge itself is named. I then removed the probe case.

**Side observation, outside this phase.** In that state the dispatch line says `0 changed file(s)`. `Get-ChangedFiles` swallowed the unreadable tree silently.

*Action: implementer.*
- Replace the exemption with a fail fixture, and a pass twin (`pass-merge` itself), built with `truncateCommit: "HEAD^2^{tree}"`.
- Correct the `rules.json` text and `notes.md` T006.
- Optionally make the message not say "Fetch the full history" for a corrupt object.
- Log the silent `0 changed file(s)` as a separate follow-up.

### F4 — `Get-MergeRecordLines` is not "the same set" as `Get-AddedRecordLines` — MINOR

**The difference.**
- The ordinary helper takes candidates from the raw added diff lines, trimmed, and requires that exact text among the visible lines.
- The merge helper pattern-matches the visible lines, after inline comments are stripped.

So a record line with a trailing inline comment counts in a merge and not in an ordinary commit.

**Evidence.** I appended `**Amendment approved by**: bob, 2026-01-01 <!-- ok -->` plus new text to `plan.md`, with "approved by bob" in the message:
- inside a merge: `graded 2 of 3 ... enforcement-pack: OK`;
- the same edit as an ordinary commit: `FAIL ... amends specs/001-thing/plan.md after approval with no conforming approver record`.

**Drift.** `notes.md` T008 claims equivalence ("it is the same set"). Plan D4 and tasks T008 specify `git diff -U0` per parent, and the implementation deviates from that.

*Action: implementer. Make the merge helper apply the pattern to the raw trimmed line of the merged blob and require that same text among the visible lines, which mirrors the ordinary helper. Or record the difference as deliberate. Add a pinning fixture either way.*

### F5 — Required evidence missing from `notes.md`; small claims inconsistent — MINOR

- T005 and T010 require the full-harness count on the parent and on the phase.
- `notes.md` line 113 says "recorded below ('Full harness, parent and phase 2')", and no such section exists.
- T010 says "The full-harness count for the phase 2 commit is recorded below when its run finishes", and it is not.
- The commit message says "five mutations shown"; the notes' T009 table has seven.
- T010's re-run of T005's reproduction is only implied by the fixtures.

**Update after the review started.** `22ac126` landed while I was reviewing: "notes: 026 phase 2 full-harness counts, parent 1537 and phase 2 commit 1575, all passed". It closes the missing counts, and its 1575 matches my independent run. I did not review that commit beyond `--stat` (it changes `notes.md` only, 6 lines).

*Action: implementer. Correct the "five mutations" claim if it is repeated anywhere. This review's own full run on `9d899c9` is under Test coverage.*

### F6 — Inventory and plan drift — DOC DRIFT

- The `AMEND-001` notes still open with "Twenty-two directions"; the rule now has 39.
- Plan D11 places the script header's `LIMIT` comment in phase 3, while tasks T008 (followed) puts it in phase 2.
- The rewritten comment understates F2.

*Action: implementer. Fix the count, and align D11 with tasks in phase 3. If the plan needs amending, the owner approves it.*

### F7 — Per-merge cost when the merge did not touch the feature — MINOR

Every two-parent merge spawns two `cat-file -e` and three `ls-tree -r -z` processes, even when the feature directory is the same as in a parent.

**Evidence.** A synthetic branch of 40 main-into-branch merges plus 41 ordinary commits, timed with `time`:
- old script: 4.6 s;
- new script: 11.5 s;
- that is about 170 ms per merge on this Windows machine.

`merge-tree` was never invoked: no objects were written.

*Action: optional. One `git rev-parse M:specs/NNN P1:specs/NNN P2:specs/NNN` comparing directory tree ids can skip a merge whose feature directory equals a parent's: every document then equals that parent. Phase 3's replay timing should report this cost.*

### F8 — "The ordinary-commit path is not edited" is literally untrue, behaviourally true — NIT

Two kinds of line in the ordinary path changed, both inert for ordinary commits:
- the `foreach ($row in ...)` header now wraps an `if ($isMerge)`;
- both failure sentences gain `$mergeNote`, which is empty for an ordinary commit.

`foreach` over a `$null` subexpression iterates zero times, and the old `@($null)` iterated once and `continue`d, so the result is the same. Every pre-existing `AMEND-*` case passes.

Also: a merge that authored content and whose first parent predates the check is now counted under "made before the check existed", not "merge commit(s)". `notes.md` states this.

*Action: none. Word the claim as "behaviour of the ordinary path unchanged" in phase 3 documents.*

## Mutations re-run (T009 claims)

Each mutation was applied in its own detached worktree outside the repository, so the working tree was never touched. Each worktree then ran `-Case merge`:

| Mutation | Observed failing cases | Matches notes.md |
|---|---|---|
| `$exempt = $true` → `$exempt = $false` | `pass-merge-status-only`, `pass-merge-tick-only-both-parents` (101 passed, 4 failed) | yes |
| `if ($autoTree) {` → `if ($false) {` | `pass-merge-clean-automatic` (103 passed, 2 failed) | yes |
| `Get-MergeRecordLines`: `foreach ($p in $Parents)` → `foreach ($p in @($Parents[0]))` | `fail-merge-combines-approved-amendments`, `fail-merge-hand-merged-conflict`, `fail-merge-octopus-clean-combination` (102 passed, 3 failed) | yes |

Working tree after all runs: `sha256sum scripts/enforcement-pack.ps1` gives `2289ec82...aacdaa4`, the same as at the start. `git status --short` is empty.

## Fixtures

I diffed six pairs recipe against recipe:
- AMEND-002 `fail-merge` / `pass-merge`;
- `fail-merge-hand-merged-conflict` / `pass-...-record`;
- `fail-merge-octopus-clean-combination` / `pass-merge-octopus-record`;
- `fail-merge-readiness-added-in-merge-unapproved` / `pass-...-approved`;
- `pass-merge-status-only` / `fail-merge-status-plus-text`;
- `pass-merge-tick-only-both-parents` / `fail-merge-tick-vs-rewrite`.

Each pair differs in the one stated condition: the message, the record lines, one requirement line, or the second parent's task text. The count lines in `expected.txt` separate "merge commit(s)" from "made before the check existed", so `pass-merge-status-only` cannot pass by the boundary. The exemption mutation fails it. The one fixture built off the field shape is the deletion case (F1).

## Amendments in this diff

- [x] **None.** `bb08af7` and `9d899c9` change no `spec.md`, `plan.md`, `tasks.md` or `contracts/` of this feature (`git show --stat`: `notes.md` only, under `specs/026-...`).

## Constitution re-check (post-implementation)

**PASS with exceptions.**
- **I (Amendment authority)** is extended to merges as planned, with no constitution change. F1 and F2 are remaining paths where a merge changes an approved document with no record.
- **VIII (Testing)**: fixtures were written first and shown failing on the parent, but `AMEND-008` lacks its pair on a false exemption (F3).
- **X (Controlled Delivery)**: one phase, gate certified by the owner, and scope-check PASS.
- **III, V, VII**: N/A.

## Test coverage observed

- `-Case merge` on a detached worktree of `9d899c9`: **105 passed, 0 failed**, in 136 s.
- Full harness on the same detached worktree (outside the repository): **1575 passed, 0 failed, 0 skipped** (758 cases, 1428 s). That is 1529 after phase 1 plus 46 new assertions.
- Three mutations: see the table above.
- Seven ad-hoc scratch repositories (F1, F2, F3, F4, special-character paths, timing) and a replay of six real merges.

## What I did not check

- The pre-2.38 git fallback path: this machine has a newer git, so the unknown-option exit was only read, not run.
- Whether GitHub's server-side `pull_request` synthetic merge always equals local `git merge-tree --write-tree`. If it ever differs, the required CI check grades a merge nobody wrote, fail-closed.
- Linux or macOS runners.
- The adopted projects' history.
- `-Case CRIT-`.
- The four T009 mutations I did not re-run.
- A path containing a newline (`ls-tree -z` output is split by PowerShell on newlines before the `-split "\0"`).

## Residual risk

The risk concentrates in D1's equality rule:
- **F1** is a fail-open in the most common merge shape for `contracts/**`.
- **F2** is a two-commit laundering path the owner should decide on.
- **F3** leaves an emission site without a fixture, on a claim that is false.

Merge after F1 and F3 are fixed with field-shaped fixtures, and after the owner records a decision on F2.
