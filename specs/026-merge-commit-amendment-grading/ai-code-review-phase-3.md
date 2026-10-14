# AI Code Review — 026 Grade the content a merge commit authors, phase 3

**Reviewer**: fresh-context agent, Claude Opus 5.5 (claude-opus-5-5)
**Date**: 2026-10-14
**Branches**: kit repository `026-merge-commit-amendment-grading`. Phase 3 commits `3fd1b2e` (guidance, flow-down note, roadmap, digests, measurement notes) and `c64348c` (plan amendments), parent `fa23d5b`; notes-only commit `7e7b022`. Branch tip at review start: `7e7b022`.
**Scope reviewed**:
- `git show --stat 3fd1b2e c64348c 7e7b022` and the full diffs of `adoption/updating.md` (the new "Flow-down note: the 2026-10-14 merge commit that authors a spec change"), `docs/sdlc/critical-delivery.md`, `docs/roadmap.md`, `docs/digests/**`, `specs/025-critical-merge-ready-signal/plan.md`, `specs/026-merge-commit-amendment-grading/plan.md` (D11) and `notes.md` ("Phase 3" onward).
- `scripts/enforcement-pack.ps1`: the header comment at lines 324-351, `Get-AddedRecordLines`, `Test-CheckboxOnlyChange`, `Get-FeatureDocMap`, `Get-AutoMergeTree`, `Get-MergeAuthoredPaths`, `Get-MergeRecordLines` and the whole of `Invoke-AmendmentAuthorityCheck` (lines 1769-1943), plus the dispatch.
- `spec.md` (US2, US3, Edge Cases, FR-001 to FR-010, SC-001), `plan.md` (D3, D9, D10, D11), `tasks.md` (phase 3 = T011-T017 and its Territory), `.specify/memory/constitution.md` I (Amendment authority), `kit-manifest.json`, `specs/_templates/ai-code-review-template.md`, and `ai-code-review-phase-2.md` for shape.
- The 24 merge cases that 026 added (`git diff --name-status f46f3a3 fa23d5b -- tests/enforcement/cases`), by name and description. I read only one of them in full (`AMEND-001/fail-merge-renames-and-rewrites-contract`).

**Feature contract**: phase 3 changes documents only, with no script changes. Its Territory is `docs/sdlc/critical-delivery.md`, `adoption/updating.md`, `docs/roadmap.md`, `docs/digests/**` and `specs/025-critical-merge-ready-signal/plan.md`, plus the feature's own directory. The documents that stated the merge limit must say what is now graded and what stays open (FR-008). Digests are regenerated, never hand-edited. Feature 025's plan is amended only with the owner's recorded approval (constitution I). The measurement replays real history and says plainly what it does and does not show (FR-009, SC-001).

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5) session
- **Inputs provided**:
  - Phase 3 commits `3fd1b2e` and `c64348c` (parent `fa23d5b`) and the notes-only commit `7e7b022`.
  - `specs/026-merge-commit-amendment-grading/{spec.md (FR-008 to FR-010, SC-001, US3), plan.md (D10, D11), tasks.md (phase 3 = T011-T017), notes.md}`.
  - `.specify/memory/constitution.md` I (Amendment authority), `docs/sdlc/review-process.md` and `specs/_templates/ai-code-review-template.md`.
  - The earlier reviews `ai-code-review-phase-1-round-2.md` and `ai-code-review-phase-2.md`, for shape.
  - The shipped code in `scripts/enforcement-pack.ps1` that the documents describe.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** Most of what the documents say matches the code, and I checked each claim against it. The checked claims are:
- the exemptions are asked against every parent;
- a removal is graded unless git's automatic merge also removes it;
- the record must be new against every parent;
- the strict fallback;
- the git 2.38 requirement;
- the object-database side effect, which I reproduced: `git merge-tree --write-tree` added 6 loose objects, no ref and no working-tree change;
- the unreadable-merge refusal;
- the clause appended to both failure messages;
- the roll-up line for merges that author nothing.

The F2 limit from phase 2 (a parent's version taken whole is trusted) is stated honestly in all four places.

The measurement's conclusions reproduce exactly with my own driver:
- every run's whole output is byte-identical between `2977ca5` and the new script;
- every run reaches the AmendmentAuthority line;
- every merge inside every range is counted under `merge commit(s)`.

An independent git-only scan covered every graded spec document of every feature in every merge. It found no merge in any of the four histories that authored a spec document: 0 of 132. So "no output differs" is not an artefact of which branches were selected or of the boundary flag. The adopted-project counts reproduce exactly. The kit's counts differ slightly: I get 102 / 39 / 63 where the notes give 103 / 38 / 62.

What the documents get wrong, or leave out:
- **F1 (MAJOR).** A deletion or rename of a graded document made inside a merge can never pass. That includes a **pure** rename, which an ordinary commit passes and spec FR-003 lists as exempt. The new note lists this case among those an owner may see, and then gives a fix that cannot work for it.
- **F2 (MINOR).** notes.md claims the amendment check graded the feature 025 plan amendment. It did not, and it cannot from this branch.

Neither finding is a regression against the code reviewed in phase 2. Both are about the documents telling the truth, so both should be fixed or stated before merge.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | **FR-008**: all five places now say what is graded and what stays open:<br>- the script header, lines 341-351, from phase 2 (`git log -S"IS graded since feature 026"` → `bb08af7`);<br>- 025 `plan.md`: Summary, a new "Retired by feature 026" paragraph after D5, and Risks;<br>- `critical-delivery.md`;<br>- `adoption/updating.md`: a new note, with the 025 note left as history;<br>- `roadmap.md` GAP-032.<br><br>Digests are regenerated, not hand-edited: `build-digests.ps1 -Check` → `digests: OK (5 digest(s) fresh, 112 marker(s))`. US3 acceptance holds: wherever a document still says "ungraded" (the 025 note, the 025 decisions-log entry), the same document also says the limit is now retired.<br><br>**FR-009 / SC-001**: reproduced (see Test coverage), with the count discrepancy in F5.<br><br>**FR-010**: untouched by this phase. |
| Visual-reference match | N/A: no UI. |
| Feature contract held | No script changed in phase 3: `git diff --stat fa23d5b HEAD -- scripts/` is empty. No package. |
| Constitution / domain invariants | I read constitution I. T011's reading is right: it says nothing about merges, so no amendment is needed.<br><br>**Amendments**: both carry `**Amendment approved by**: anas.m, 2026-10-14`, and the `c64348c` message names anas.m. The 025 record covers changes to three sections from one place (F4). The 025 amendment is not machine-graded on this branch (F2).<br><br>I did not verify that the owner actually gave the quoted approval. |
| Security | N/A: documents only. |
| Scope guard | `scope-check.ps1 -Commit 3fd1b2e` → `PASS phase 3 commit 3fd1b2e (6 file(s))`. `-Commit c64348c` → `PASS ... (3 file(s))`. Every file is in the phase 3 Territory or in the feature's own directory. |
| Rollback safety | Documents only. Reverting `c64348c` and then `3fd1b2e` restores the parent's texts. The digests would need regenerating, which CI's digests member would catch. |
| Branch checks | `enforcement-pack.ps1 -Branch 026-merge-commit-amendment-grading` printed:<br>`AmendmentAuthority: graded 20 of 20 commit(s) in f46f3a3..HEAD`<br>`enforcement-pack: OK` (exit 0)<br>plus two non-blocking PhaseSizeWarnings, for `e661139` and `bb08af7`.<br><br>`ritual-checks.ps1 -Branch 026-...` → `RESULT OK`: doc-lint OK ("every referenced path resolves"), digests OK, roadmap-claims OK, scope-check OK. |

## Findings

### F1 — A deletion or rename of a graded document inside a merge has no path to green, and the note offers a fix that does not work for it — MAJOR

**What the documents say.** The new note in `adoption/updating.md` lists "a deletion or rename-and-rewrite of a contract" among the things an owner may newly see. It then says the failure is "fixed the way any such line is fixed: add the record to the merged file and name the approver in the merge message".

**Why that cannot work.** `Get-MergeRecordLines` reads records only from the amended paths. For a removal, the amended path is the old path, and it does not exist in the merge. The new path of a rename is "absent in every parent", so it is a first appearance and is never read. No record can satisfy either case.

**A pure rename is caught too.** This also applies to a **pure** rename (identical content) made inside a merge. An ordinary commit passes that rename, and spec FR-003 lists "pure rename" among the exemptions that apply to a merge's own change. Plan D3 decided instead that "a rename is not detected inside a merge". Spec and plan disagree here, and per the conflict rule I report it rather than choose. The guidance states neither the unsatisfiable state nor the disagreement.

**Reproduced.** I built recipes from `AMEND-001/fail-merge-renames-and-rewrites-contract` with `New-FixtureRepo` and ran them with `enforcement-pack.ps1 -Root <fixture> -Branch 001-thing`:

| Probe | What it does | Result |
|---|---|---|
| P1 | merge renames and rewrites the contract; record `**Amendment approved by**: ada, 2026-01-01` in the new file; message names ada | exit 1, `commit … amends specs/001-thing/contracts/api.md after approval with no conforming approver record … (this commit is a merge: …)` |
| P2 | merge deletes the contract; message names ada | exit 1, same line |
| P6 | merge makes a **pure** rename (identical content); message names ada | exit 1, same line |
| P7 | the same pure rename in an ordinary commit | `enforcement-pack: OK`, exit 0 |
| P3 | an ordinary commit deletes the contract (for comparison) | exit 1 |
| P4 | an ordinary rename-and-rewrite that git sees as D+A (for comparison) | exit 1 |

**What is pre-existing.** P3 and P4 show that deleting a graded document has no passing path in an ordinary commit either; that is feature 014 behaviour. A pure rename inside a merge, though, is newly unpassable while the same rename in an ordinary commit passes.

**Also unsaid.** The "What to do about it" paragraph's alternatives ("take one side's version whole", "let git's automatic merge produce the result") do not apply to a removal. Nothing tells an adopter that the only way out is to do the move in an ordinary commit, and that a deletion cannot be made green at all.

*Action:* implementer, with an owner decision.
- State the case plainly as a limit in the note, in `critical-delivery.md`'s "what stays open" if it applies, and in the GAP-032 "still open" text. Say: a document removed or renamed inside a merge is graded and no record satisfies it; make the move in an ordinary commit (a pure rename passes there); a deletion of a graded document has no passing path anywhere (014).
- Record the spec FR-003 ("pure rename") versus plan D3 conflict for the owner. Either amend FR-003 with an approver record, or open a follow-up to read the record from the new path or to detect pure renames inside a merge.

### F2 — notes.md says the amendment check graded the 025 plan amendment; it did not and cannot from this branch — MINOR

`notes.md` (T013) says: "Both commits name the approver. The amendment check grades them like any amendment (`ritual-checks.ps1` RESULT OK)." But `Invoke-AmendmentAuthorityCheck` grades only `specs/$Branch/` (`$dir = "specs/$Branch"`). An amendment to `specs/025-…/plan.md` made on the 026 branch is never graded by any run.

I tested this in a scratch clone at `7e7b022` by appending one unapproved line to each plan, with no record and no approver, and running `enforcement-pack.ps1 -Branch 026-merge-commit-amendment-grading`:

| Edit | Result |
|---|---|
| unapproved line in `specs/025-critical-merge-ready-signal/plan.md` | `AmendmentAuthority: graded 21 of 21 …`, `enforcement-pack: OK` |
| unapproved line in `specs/026-…/plan.md` | `FAIL … commit 17b4e10 amends specs/026-merge-commit-amendment-grading/plan.md after approval with no conforming approver record` |

The 025 record is present and well formed by hand, and the commit names anas.m. Only the claim that the machine checked it is false. The underlying gap is pre-existing and wider than this feature: no branch's amendment of another feature's approved documents is ever graded.

*Action:* implementer. Correct the notes sentence: the 026 D11 amendment is machine-graded; the 025 amendment is checked by review only. Consider opening a roadmap gap for cross-feature amendments; that needs the owner's decision.

### F3 — "What does NOT change" says the Micro and Critical lanes are unchanged except for the merge-readiness flip — DOC DRIFT

The note says nothing changes on "the Lite, Micro and Critical lanes except that a merge-readiness flip made inside a merge is no longer exempt". The check has no lane parameter: dispatch calls `Invoke-AmendmentAuthorityCheck` for every `NNN-*` branch. So on a Micro or Critical branch, **any** spec document a merge authors is now graded, exactly as on Standard. That includes a Micro `spec.md` and a Critical `contracts/*`, not only the readiness flip. The sentence reads as copied from feature 025's note shape. It is true only for Lite, whose `fix/` and `chore/` branches never run the check.

*Action:* implementer. Reword, for example: "the Lite lane (fix/, chore/, docs/ branches do not run this check)", and say that Micro and Critical branches are graded for merge-authored documents like Standard ones.

### F4 — The 025 plan amendment changes three sections and carries one record — MINOR

Constitution I says "the amended section carries an `**Amendment approved by**` line". `c64348c` rewrites the 025 Summary sentence, adds the "Retired by feature 026" paragraph after D5, and replaces the Risks bullet. The one record sits after the D5 paragraph. That paragraph does say "This amendment also changes the Summary and Risks to say so", so the change is disclosed, not hidden. The machine would accept it either way, because it grades per file (and does not grade this file at all; F2).

Two smaller points about the same commit:
- The replaced Risks bullet omits "a failing `git merge-tree`" from the strict-fallback list; the D5 paragraph includes it.
- The original Summary and Risks wording is not kept as history; only the D5 paragraph is.

*Action:* owner's call. Either accept the one-record-per-amendment reading (the Summary and Risks edits are consequential to D5), or add the record to the Risks bullet. Optionally add "or a failing `git merge-tree`" to the Risks bullet.

### F5 — The kit's measurement counts do not reproduce exactly, and the method is not fully recorded — MINOR

My driver (`<scratch>/work/replay.ps1`, kept outside the repository) follows the method in notes.md:
- clones with `--local --no-hardlinks` and `core.autocrlf=false`, plus the source repository's `refs/remotes/*`, so that `--all` matches the original repository;
- for each merge, the features from `git diff --name-only $(merge-base M^1 M^2) M^2` matching `^specs/(\d{3}-[^/]+)/`;
- `-ReplayBase M^1 -ReplayTip M -IgnoreAmendmentBoundary`, with `-Root` the clone;
- `2977ca5` and HEAD scripts extracted with `git archive`;
- runs from a non-repository scratch directory.

Results:

| History | Merges | No feature | Feature runs | Merges in ranges | Outputs differ | AA line differs | New failures | Runs without AA line |
|---|---|---|---|---|---|---|---|---|
| FitForge | 10 | 9 | 1 | 3 | 0 | 0 | 0 | 0 |
| FlowBoard | 10 | 6 | 4 | 4 | 0 | 0 | 0 | 0 |
| ExpenseTracker | 10 | 7 | 3 | 3 | 0 | 0 | 0 | 0 |
| kit | **102** | 65 | **39** | **63** | 0 | 0 | 0 | 0 |

The three adopted projects match the notes exactly. The kit gives 102 / 39 / 63 against the notes' 103 / 38 / 62:
- `git rev-list --merges --all` in the real kit repository today returns 102.
- One merge, `22f2af4` (PR #16), touched three features (004, 006, 007), which gives the extra runs here.

The notes do not record the ref set, the driver or the feature-detection rule precisely enough to settle which count is right. The conclusions (0 newly graded, 0 new failures, 0 differing outputs) hold either way.

The method also departs from T016's text without saying so:
- T016 says "over every `NNN-*` branch range ... each version placed inside the clone";
- the notes replay per merge, from a scratch directory with `-Root`.

The per-merge method is reasonable and arguably closer to CI. It covers a main-into-branch merge only when that merge falls inside a later merge's range, which in these histories they all did.

*Action:* implementer. Record in notes.md the ref set (for example "`--all` after cloning, N refs"), the feature-detection rule, and that the method differs from T016's wording. Reconcile or annotate the kit's 103 / 38 / 62.

### F6 — The tick and Status exemptions can never apply inside a main-into-branch merge, which the note does not make plain — NIT

"The task-tick and `**Status**` exemptions apply to a merge only when the change is of that kind against **every** parent" is accurate. A reader will not infer, though, that in the usual `Merge branch 'main' into NNN-…` (main never holds the feature directory) the exemptions **never** apply: against main the file is a whole-file creation.

Probe P5 ticks `T001` inside such a merge. It gave exit 1, `amends specs/001-thing/tasks.md after approval with no conforming approver record … (this commit is a merge: …)`. That case is satisfiable with a record, and it is rare.

*Action:* optional. Add one clause: "in a merge of main into the branch, where main lacks the document, no exemption applies: tick in an ordinary commit".

### F7 — Small textual points — NIT

- The GAP-032 inventory text now says both "the limit is also pinned by no fixture today" and "pinned by twenty-four merge fixtures". The 24 is right: 20 `AMEND-001` merge cases, 2 `AMEND-002` and 2 `AMEND-008` were added by 026. Marking the old sentence "(at the time)" would help.
- "The failure text is the existing one with one clause appended": there are two failure texts (no record; approver not named in the message), and both get the clause, which is correct in the code.
- The 170 ms per merge is the phase 2 reviewer's measurement (notes F7 row), not this phase's replay. The replay's slowest run was only 0.3 s slower.
- The first adoption digest marker says a merge "that only combines two histories is skipped as before". On a git older than 2.38, a clean combination of two amended parents is graded. That is fine for a digest, but it is the same nuance F3 is about.

*Action:* optional wording fixes.

## Amendments in this diff

- [x] Amendments listed:
  - `specs/025-critical-merge-ready-signal/plan.md`: the Summary sentence, a "Retired by feature 026" paragraph after D5, and the Risks bullet. Record: `**Amendment approved by**: anas.m, 2026-10-14`; the `c64348c` message names anas.m. Not machine-graded on this branch (F2); one record for three sections (F4).
  - `specs/026-merge-commit-amendment-grading/plan.md` D11: the `LIMIT` comment is placed in phase 2. Record: `**Amendment approved by**: anas.m, 2026-10-14`. Machine-graded and passing.
  - The claim is true: the header text "IS graded since feature 026" first appears in `bb08af7` (phase 2), is absent in `2977ca5`, and T008 says "Replace the script header's `LIMIT` paragraph".
  - The owner's approval is quoted in notes.md. I could not verify that it was given.

## Constitution re-check (post-implementation)

PASS, with F2 and F4 as nuances.
- I: the amendments carry records and name the approver. The agent did not record itself as approver; the approver is the owner, anas.m, per the quote, which I could not verify.
- II: the source of truth is respected, and the spec FR-003 versus plan D3 conflict is reported (F1), not chosen.
- X: phase discipline holds. These are document-only commits inside the Territory, and the gate is user-run and recorded in `7e7b022`.

## Test coverage observed

- **Replay (my own driver)**: see F5. Every run's whole output was byte-identical between the two versions. All 47 runs printed an `AmendmentAuthority: graded …` line. Every not-graded reason was `N merge commit(s)` only, so no run graded nothing and no merge was graded. The boundary flag only lifts the boundary; no output showed the "made before the check existed" reason.
- **Independent check against the branch-selection artefact** (`<scratch>/work/authored.sh`, git only). For every merge reachable from any ref and every `specs/NNN-*/{spec,plan,tasks}.md` and `contracts/*` in the merge or a parent, it counted documents that are not a creation, equal no parent and differ from `git merge-tree --write-tree`. Tick and Status exemptions are not applied, so it over-reports. Results: FitForge 0 of 10 merges, FlowBoard 0 of 10, ExpenseTracker 0 of 10, kit 0 of 102. So no merge in any of the four histories authored a spec document of any feature, whichever branch is selected.
- **Probes P1-P7** (F1, F6), built with the kit's own `New-FixtureRepo` and removed afterwards.
- **Not run by me**: the full harness (forbidden here), any `-Case` subset, a git older than 2.38, a CI that forbids object writes, and an octopus merge in real history (none exists).

## Residual risk

The residual risk sits in F1: an adopter who moves or retires a contract during a merge meets a red that nothing in the guidance resolves. It is rare, and gate 6 stands behind it, but the guidance currently promises a fix. F2 is a false statement of evidence in notes.md about an amendment only a human checked.

The measurement shows only that history authored nothing (the documents say so honestly). It says nothing about how often a hand-merged conflict will occur. Before merge:
- fix or state F1 and F3, and correct F2;
- the owner decides on the FR-003 versus D3 conflict and on F4;
- T017's full-harness count is still pending. Apart from that count, T017's other items are recorded in `7e7b022`: ritual-checks RESULT OK, scope-check PASS on all 13 phase commits, and the gate exit 0 confirmed by the owner.

What I did not check: whether the owner's quoted approval was given; behaviour on git older than 2.38; the full harness; the content of most of the 24 merge fixture recipes beyond their names and descriptions.
