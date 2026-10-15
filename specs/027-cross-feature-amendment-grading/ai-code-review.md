# AI Code Review — 027 Grade amendments of another feature's approved documents (Phase 1)

**Reviewer**: fresh-context review agent (claude-sonnet-5-5), independent of the implementing session
**Date**: 2026-10-14
**Branches**: repo `agentic-sdlc-kit` branch `027-cross-feature-amendment-grading`, phase 1 commit `0d876a6` (parent `25bb263`)
**Scope reviewed**: `git show 0d876a6` in full for `scripts/enforcement-pack.ps1` and `tests/enforcement/rules.json`; `notes.md`; the fixture recipes and expectations of the 21 new cases (`AMEND-001`, `AMEND-002`); spec.md, plan.md (D1-D5, D7, D8, D9), tasks.md (T001-T006); `-Case AMEND-` run; 21 new fixtures re-run with a longer own-branch name; three ad hoc adversarial recipes built with `New-FixtureRepo`. Not reviewed: phase 2 and phase 3 content (not in this commit); the 1627-count full harness (not re-run, the `AMEND-` subset was).
**Feature contract**: numbered branches grade a commit's (ordinary or merge) amendment of any feature's `spec.md`/`plan.md`/`tasks.md`/`contracts/**` that exists at the diff base; own-directory code not rewritten; no new script file, no new dependency; Lite lane and replay (phase 2/3) out of this phase.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: the separate session that produced commit 0d876a6 (Claude Sonnet 5.5; its conversation was not supplied to this reviewer)
- **Inputs provided**: commit 0d876a6 and its parent, specs/027-cross-feature-amendment-grading/{spec,plan,tasks,notes}.md, docs/sdlc/review-process.md, specs/_templates/ai-code-review-template.md, scripts/enforcement-pack.ps1, tests/enforcement/
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — The diff does what Phase 1 asks for the shapes it fixtured: another feature's approved document amended on a numbered branch (ordinary commit and merge) is now graded, one record per amended document, the exemptions and "exists at the diff base" line behave as planned, the own-directory block is untouched, no pre-existing case file changed (all 42 changes are additions), and the `AMEND-` subset passes (219 passed, 0 failed). One real bypass remains of the exact rule the owner accepted as "a removal of another feature's approved document has no passing path" (F1): moving such a document into the branch's own directory is graded by nothing and prints OK. That is a hole in FR-007 and in the very fixture family the task list names ("a single document moved from one feature's directory to another's"), so it should be closed in this phase, with a fixture pair, before the gate. Residual risk otherwise sits in the untested defensive branches (F3) and an undeclared plan departure (F2).

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-001/002/004: `Get-OtherFeatureSubject` (creation, absent-at-base, pure rename, whole-dir renumber, tick, Status). FR-005: per-document groups in the tail; `fail-other-feature-record-in-own-plan`, `-two-docs-one-record`. FR-006: failure names every amended file plus a clause (`expected.txt` of `fail-other-feature-no-record`). FR-007: `fail-other-feature-removal`, `-single-doc-moved`, `fail-merge-other-feature-deletes-contract` pass; a move INTO the own directory does not (F1). FR-011: range unchanged (`$range`). FR-013: `git diff --name-status 0d876a6^ 0d876a6` shows only A for tests/ and M for the script, notes.md and rules.json; no existing case edited. |
| Visual-reference match | N/A (no UI). |
| Feature contract held | No new file in scripts/, no package. Own-directory row block unchanged in the diff context (only the `if ($path -notlike ...)` guard replaced by the dispatch above it). The Lite lane is not touched; the header `LIMIT` paragraph says the Lite lane "does not run this check yet". No Phase 3 replay work in the diff. |
| Constitution / domain invariants | Constitution I amendment authority: the new arm grades other features exactly as the rule's text ("that feature's") requires. D2 "exists at the base" is a proxy for approved; the proxy is stated in the LIMIT comment. |
| Security | No secrets, no external input beyond git paths. Paths are passed to git as arguments (`ls-tree ... -- $oldFeature`); feature-dir names are constrained by `\d{3}-[^/]+`. |
| Scope guard | `git show --stat`: script, notes.md, rules.json, 21 case dirs (42 tests): all inside the phase territory (`scripts/enforcement-pack.ps1`, `tests/**`) plus the feature's own notes.md. No Lite-lane or replay code. |
| Fixtures first / one condition per pair | Pairs: `fail-other-feature-no-record`/`pass-other-feature-record` (record presence), `AMEND-002` pair (message approver only), `fail-other-feature-tick-with-rewrite`/`pass-other-feature-tick`, `fail-other-feature-removal`/`pass-other-feature-renumber-whole-dir` (directory vs one doc), `pass-other-feature-created-on-branch` (control). Notes record 13 of 21 differ on the parent and 8 are named by-design controls (rules.json lists them). I did not re-derive the parent runs. |
| Mutation evidence per guarded branch | notes.md table M1-M9. Guarded branches with NO mutation evidence: base-unreadable refusal (2 sites, exempted), `$oldFeature -eq $Dir` early return, `-not $AtBase.ContainsKey($OldPath)` early return for moves, the non-document-source rename return, tick and Status exemption arms of the other-feature function, the `$left.Count -eq 0` renumbering test for the pathFeature-null case (see F3). M7 is admitted degenerate. |
| Correctness of enforcement-pack.ps1 | Read the full diff. Re-ran all 21 new fixtures with the own branch renamed `002-bbbbbbbbbbbbbbbb` (defeats the equal-length name masking noted in notes.md M7): all 21 keep the expected exit code, so no `Substring($dir.Length+1)` leakage on other-feature paths. Ad hoc: delete of another feature's plan fails (good); move of another feature's plan into the own directory passes (F1). |
| rules.json inventory | AMEND-001 and AMEND-002 notes updated with case names and counts (sixty-four directions); AMEND-010 added as an exemption with `siteCount: 2`, reserved AMEND-009 for phase 2. Notes text is accurate against the case dirs I listed (19 + 2 new). |
| Rollback safety | Single revertible commit of script + tests + docs; no schema. Reverting restores the prior grading. |

## Findings

### F1 — A move of another feature's approved document INTO the branch's own directory passes ungraded — BLOCKING

`scripts/enforcement-pack.ps1`, row loop (about lines 1988-2010) and the unchanged own block (about lines 2012-2024). The dispatch sends a row to `Get-OtherFeatureSubject` only when the NEW path's feature differs from `$dir`. A rename whose new path is inside the own directory and whose old path is in another feature's directory goes to the own block, which hits `if ($oldFeatureDir -and $oldFeatureDir -ne $dir) { continue }` (the J3 renumbering exemption) and drops the row. The old path, an approved document of another feature, is removed from its feature and nobody grades the removal. Reproduced: I took the fixture `fail-other-feature-single-doc-moved`, changed its last commit to rename `specs/001-a/plan.md` to `specs/002-b/contracts/moved.md`; result `AmendmentAuthority: graded 2 of 2 ... enforcement-pack: OK`, exit 0. The same document deleted outright (`D`) fails correctly. The spec's accepted sub-decision (FR-007; notes "Owner decisions") is that removing another feature's approved document has no passing path; this is a one-step way to do it. The implementer's note 4 lists only the move OUT of the own directory as open; the move IN is not listed anywhere, not in the LIMIT comment and not in the fixtures.
*Action: implementer: add a fixture pair (move of another feature's single document into the own directory = fail; the whole-directory move into the own directory, if it is reachable, = control), grade the old path as a removal in the own-block rename branch by the same test D3 uses (`Get-OtherFeatureSubject` on the old path), keep the J3 whole-directory exemption, add a mutation, update rules.json notes. If the owner prefers to leave it open, it must be declared in the LIMIT comment, plan and spec as an accepted gap (an amendment with an approver record, which the owner records).*

### F2 — Implementation departs from approved plan D5 without an amendment — CONFIRM

Plan D5 says "The loop's tail is not changed" and prescribes the clause text " Of these, <files> belong(s) to feature <NNN-name>: a document is amended where it lives, so the record goes in that document". The commit rewrites the tail (record groups, per-approver message check) and uses different clause wording ("the amended file(s) outside this branch's own directory (...) belong to feature(s) ..."). The implementer disclosed this in notes.md (decision 1) and the regrouping is required for FR-005 and for fixtures `fail-other-feature-record-in-own-plan` and `-two-docs-one-record`; I agree the sentence in D5 is the imprecise one. Behavior for an own-directory-only failure is byte-identical (I confirmed the text path is unchanged for `ownPaths` only, and the existing cases pass). But a plan decision approved by the owner was implemented differently, and the CLAUDE.md rule is that an approved-document amendment records its approver; the implementer did not and must not approve its own amendment.
*Action: owner: either approve a plan amendment of D5 (tail regrouped per document; the clause as built) with the `**Amendment approved by**` record, or direct a different implementation. Implementer: do not self-approve. No code change needed.*

### F3 — Defensive branches without mutation or fixture evidence — MINOR

T005 asks a mutation for "each fixture that guards a branch of the new code". notes.md has none for: the base-unreadable refusal (AMEND-010, exempted as unreachable; two emission sites, never executed by any test, and a mistake in it, for instance returning from the wrong scope, would not be seen), the two early returns for moves out of the own directory and for a move source absent at the base, the exemption arms in `Get-OtherFeatureSubject` (the tick and Status controls pass on the parent by design, so a regression that dropped them in the new arm would be caught only by those two passes, which no mutation shows), and the `$pathFeature` null move (document moved out of `specs/NNN-*` entirely, graded as a removal; no fixture). The notes show the M7 mutation as degenerate by the implementer's own words (equal-length fixture dir names); my longer-name rerun (all 21 as expected) suggests the code is fine, but that rerun is not a fixture.
*Action: implementer: add mutation lines for the tick/Status arms and the move-out-to-non-specs shape, or record why not; consider a fixture with a longer own-branch name so the length coincidence stops hiding defects (one existing recipe changed only in the name is enough). AMEND-010's exemption reason is acceptable, noted.*

### F4 — `tasks.md` not ticked and ritual-checks/T006 items partly deferred — MINOR

The commit does not tick T001-T006, and notes.md says `ritual-checks.ps1` "is run by the owner as the gate". T006 lists `-Case CRIT-`/`LITE-` runs, the full harness and ritual-checks, and the SC-001 re-run; notes record only the full harness (1627 passed) and reasoning for SC-001 via `pass-other-feature-record`. I ran only `-Case AMEND-` (219 passed); I did not re-run CRIT-, LITE- or the full harness.
*Action: implementer: tick tasks at the point the gate is run, and record the CRIT-/LITE- results in notes.md, or state they were included in the 1627 run.*

### F5 — Cost and limits stated but one limit is understated — MINOR

The merge path now does `ls-tree -r -z` of the whole `specs` tree per parent and for the merge, plus the base set: notes measured +100-200 ms per merge on this machine, against 026's 170 ms; it grows with the number of features and with large contract directories. Acceptable now; the LIMIT comment does not mention it, and the move-in gap (F1) is not in the limits list.
*Action: none beyond F1's declaration of limits; note for phase 3's real-history replay.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

None of the feature's own `spec.md`, `plan.md`, `tasks.md` or `contracts/` was changed by commit 0d876a6 (only `notes.md` among the feature files). The departure from D5 (F2) is an implementation choice, not a document change, and carries no approver record.

## Constitution re-check (post-implementation)

PASS with one open item. Principle I (amendment authority): the machine now grades the rule as written for every approved feature, but F1 leaves a removal path ungraded and F2 needs the owner's ruling on D5. Other principles (single source of rules in `rules.json`, fixtures by hand, no new dependency) are satisfied; I found no engagement of the domain-invariant principles.

## Test coverage observed

`tests/enforcement/cases/enforcement-pack/AMEND-001` gains 19 cases and `AMEND-002` gains 2 (21 cases, 42 tests with their harness twins), all hand-written expectations; `-Case AMEND-` ran 219 passed, 0 failed, 0 skipped. Critical assertions: exact failure text with the other-feature clause (`fail-other-feature-no-record`, `fail-other-and-own-no-record`), record-in-wrong-file failures, the removal and moved-document fails, created-on-branch and renumber controls, merge arm of both. Missing: a move INTO the own directory (F1), the base-unreadable refusal (exempted), a non-`specs/` destination of a moved document, a longer own-branch name.

## Residual risk

Concentrated in F1: a trivially expressible bypass of the removal rule on the numbered lane, introduced alongside the very rule that claims to close the class. Merge only after F1 is fixed with a fixture pair and a mutation, F2 is ruled on by the owner, and the implementer's disposition of F3/F4 is recorded. The Lite lane and the real-history replay remain for phases 2 and 3.

## Dispositions

<!-- Left for the implementer. -->

### Implementer dispositions (appended; the reviewer's text above is unedited)

| Finding | Disposition |
|---|---|
| F1 | **Fixed.** Row loop routes a rename out of another feature's graded directory to `Get-OtherFeatureSubject`, graded as the removal of the old path. Fixture pair `fail-other-feature-doc-moved-in` / `pass-other-feature-sole-doc-moved-in`; mutation M10 (fix reverted) fails the fail fixture only. Recorded in `notes.md` and `rules.json` (sixty-six directions). |
| F2 | **Deferred to the owner.** Needs a recorded D5 amendment or a redirect; the implementer does not approve their own amendment. |
| F3 | **Deferred, recorded as a gap** in `notes.md` (the unmutated branches are listed). |
| F4 | **Deferred to the gate run**: ticks and CRIT-/LITE-/ritual-checks results are recorded after the owner runs it. |
| F5 | **Recorded as a limit** in the LIMITS comment of `scripts/enforcement-pack.ps1`; measured at scale in phase 3's replay. |

**F2 update (appended):** closed. The owner approved the D5 amendment (anas.m, 2026-10-14); the record is in `plan.md` D5 and the amendment commit names the approver.
