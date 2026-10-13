# Implementation Plan: Grade the content a merge commit authors in the amendment-authority check

**Branch**: `026-merge-commit-amendment-grading` | **Date**: 2026-10-14 | **Spec**: specs/026-merge-commit-amendment-grading/spec.md
**Input**: Feature specification (approved, anas.m, 2026-10-14; option A) + decisions D1–D11 below
**Gate Batching**: none
**Gate Certification**: user-run
**Status**: Approved (anas.m, 2026-10-14) — decisions D1–D11 approved as recommended: D2 (the auto-merge refinement), D3, D4 and three phases
**Amendment approved by**: anas.m, 2026-10-14

## Summary

`Invoke-AmendmentAuthorityCheck` (`scripts/enforcement-pack.ps1`) stops skipping a commit with more than one parent unconditionally. For each of the
branch's spec documents it asks one question of a merge commit: **does the merged result equal what a parent already had?** If so, nothing was authored
and the merge is skipped and counted exactly as today. If not, the merge authored that document's content and is graded like any amendment: a conforming
`**Amendment approved by**: <name>, <date>` added in the merged file (new relative to **every** parent) and the approver named in the merge commit
message. The grading tail (record, message, failure text) is reused, so a merge's failure reads like any other with one added clause.

**One finding the owner must see before approving.** The approved spec says "differs from every parent". Reading the check, and the way CI checks out a
pull request (a synthetic merge of the PR into its base, which lands inside the graded range as `HEAD`), shows that rule also flags a **clean automatic
merge of two parents that each amended the same document in different places**: the result equals neither parent although nobody wrote anything. The
owner's brief for this feature said such a merge must not be flagged; the approved FR-001 and FR-002 do not say so. D2 proposes the fix (compare also with
what git's own automatic merge of the parents produces) and needs a spec amendment with the owner's approver record. Without it the feature still closes
GAP-032, but it fails closed on a rare shape (0 of 131 real merges, but not 0 by construction).

Three phases, each independently revertible. First the fixture library, so a merge can carry content of its own (the missing capability behind review
finding F12), with its self-test, changing no check. Then the check and its proof, fixtures first and shown failing on the parent, built from the shapes
real merges have. Then the guidance, the retirement of the limit in the documents that state it, the flow-down note, the roadmap and a re-run of the
measurement. The lesson features 024 and 025 paid for governs the plan: **fixtures are built from field shapes, not from the kit's conventions**, and the
measurement on real history is part of the feature.

## Technical Context

**Language/Version**: PowerShell 7+ (`pwsh`); `git` 2.38 or newer for `git merge-tree --write-tree` (D2; this machine has 2.55)
**Primary Dependencies**: none new
**Storage**: files and git state only
**Testing**: the enforcement harness (`tests/enforcement/`): real temporary git repositories, hand-written expectations, a passing and a failing fixture per
rule. Every existing `AMEND-*` case, including `AMEND-001/pass-merge` (a merge that authors nothing), must pass unchanged (SC-004).
**Target Platform**: any runner with `pwsh` and `git`
**Project Type**: governance tooling (scripts plus documents)
**Constraints**: a branch whose merges authored nothing produces byte-identical output (FR-002); the check's ordinary-commit path is not edited; no other
member changes; the shallow-clone refusal is not weakened
**Scale/Scope**: one new function and a small branch in the grading loop of `scripts/enforcement-pack.ps1`, one recipe field in
`tests/enforcement/lib/FixtureRepo.psm1` with its self-test, about fifteen fixture cases, five documents, digests

## Constitution Check

- [x] **Specification First (I)**: `spec.md` is approved; this plan follows it; `tasks.md` follows once the plan is approved. This feature extends the
  check that implements constitution I's amendment record: the record and the approver-in-the-message rule are **unchanged** (D5); T012 re-reads
  constitution I for any sentence about merge commits (D11).
- [ ] **Repository Separation (III)**: not applicable, the kit is one repository.
- [x] **Architecture Consistency (IV)**: no new script; the grading stays inside `Invoke-AmendmentAuthorityCheck` and its helper functions (D1, D5).
- [ ] **Domain Invariants (V)**: not applicable, the template's slot is unfilled.
- [x] **Security (VI)**: the check reads commits and blobs; nothing sensitive is read; `git merge-tree --write-tree` writes tree objects into the object
  database of the repository it runs in (D2 states the side effect and how it is bounded).
- [ ] **External Integration Governance (VII)**: not applicable.
- [x] **Testing Requirements (VIII)**: every rule has a passing and a failing fixture, hand-written, failing first on the parent commit.
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI review with Reviewer Provenance.
- [x] **Controlled Delivery (X)**: three phases, one at a time; this changes an enforcement member, so the owner runs the gate: no batching, no ci-held.

**Phase sizing rule**: phase 1 changes no check and is useful alone (a harness capability). Phase 2 depends on phase 1. Phase 3 is documents and a
measurement and depends on phase 2. Reverting 3, then 2, then 1 leaves a consistent kit. The split is also what keeps phase 2 near the size guideline:
feature 025's single phase 1 carried 54 files, almost all fixtures.

**Post-design re-check**: no new violation. D2 (the auto-merge refinement), D3 (per-parent exemptions) and D4 (the record must be new against every parent)
are decisions the owner makes by approving or changing this plan.

## Decisions

**D1 — "The merge's own change" is decided per document, by comparing blobs (FR-001, FR-002).** For a merge commit `M` on branch `NNN-name`, the candidate
documents are `specs/NNN-name/spec.md`, `plan.md`, `tasks.md` and every file under `specs/NNN-name/contracts/` present in `M` or in any parent (a
`git ls-tree -r` per commit, four paths plus a directory). For each candidate the blob id at `M` is compared with the blob id at each parent
(`git rev-parse <commit>:<path>`, an absent file being its own value). If `M`'s blob equals **any** parent's blob, nothing was authored in `M` for that
document. Comparing blob ids, not parsing a combined diff, is the same method the check already uses to decide a rename (`sameContent`, J3), has no
output format to parse, and decides identity and absence uniformly. If no candidate document has an authored change the merge is skipped and counted under
the existing `merge commit(s)` reason, so the roll-up line is byte-identical to today's for such a branch (D6).

**D2 — Auto-merge refinement (FR-001, FR-002 as amended). Owner's decision, with a recommendation.** Two parents that each amended the same document in
different places produce a result equal to neither parent, by a clean automatic merge that authored nothing. Recommended: a document is **not** authored
by `M` when its blob also equals the one in the tree git itself would produce by merging the two parents
(`git merge-tree --write-tree <parent1> <parent2>`, first output line the tree id; read the path's blob from that tree). A conflict leaves marker text in
that tree, so a hand-resolved conflict still differs from it and is graded, as the owner decided. Three cases fall back to the unrefined rule (graded
when it differs from every parent, a record satisfies it): an octopus merge (`merge-tree` takes two parents), a git older than 2.38 (detected by the
command failing with an unknown option, never assumed), and any `merge-tree` failure other than a conflict. The fallback is fail-closed on purpose, and
the output says nothing different because the grading message is the same. **Side effect, stated:** `merge-tree --write-tree` writes tree and blob objects
into the repository's object database (unreferenced, collected by `git gc`); it changes no ref and no working-tree file. **Why recommended, with a case
that is not hypothetical:** GitHub's `pull_request` event checks out a synthetic merge of the PR into its base, and that commit is `HEAD` and inside the
graded range (feature 014 D2b, J2, already knows it). If `main` advanced and touched the same feature document in a different place, the synthetic
merge differs from both parents. Without D2 the required CI check would demand an approver record for a merge nobody wrote. **Requires amending the
approved spec:** the "Option A" row and FR-001 and FR-002 gain "and from git's automatic merge of the parents"; the amendment needs the owner's approver
record (the owner's brief already stated this constraint; the approved text omitted it).

**D3 — The exemptions apply to the merge's own change, against each parent (FR-003).** The first-appearance exemption applies when the document is absent in
every parent. The task-tick exemption (`Test-CheckboxOnlyChange`) and the `**Status**`-line exemption (`Test-StatusOnlyChange`) are existing functions that
compare two commits; for a merge they are asked **per parent**, and the document is exempt only if the change against **every** parent is of that kind.
The strict reading is deliberate: an exemption that held against one parent only would let a merge carry a substantive edit that happens to be
tick-only relative to the other. A rename is not detected inside a merge (a path present in the result and absent in every parent is a first appearance;
a path present in a parent and absent in the result is a deletion, which is graded). The first appearance rule makes a document created by both sides
identically a non-event, as today.

**D4 — The record must be new against every parent (FR-003).** A record the merged file already carried because a parent carried it approved *that
parent's* change, not the merge's. So the merge's record lines are those whose visible occurrence count in the merged file exceeds the count in **every**
parent (the existing counting method of `Get-AddedRecordLines`, J1/H5, applied once per parent and intersected). A merge that legitimately combines two
parents that were each approved on their own branch therefore needs a fresh record, which is what "a hand-merged conflict counts as authored" (the owner's
sub-decision) already means. The existing helper reads `git show -U0 --format= <commit>`, which for a merge prints a **combined** diff, so it cannot be
reused for a merge: a new helper takes the two blobs through `git diff -U0 <parent> <commit> -- <path>` and the visibility reader the pack already trusts
(`Get-VisibleFromText`). The ordinary-commit helper is **not edited**.

**D5 — One grading tail, one failure site (FR-003, FR-004).** The loop keeps its shape. For a merge it computes `$amended` (D1 to D3) and `$recordLines`
(D4), then falls into the **same** tail as an ordinary commit: conforming record, then the approver named in the message with git's own trailers removed
(J4). The failure text is the existing sentence with one clause appended only for a merge ("this commit is a merge: its own change is what is graded,
because no parent holds this content"), so the rule's emission site, its anchor and its count do not change and a fix an owner already knows (add the record
and name the approver) is the fix. A graded merge increments the graded count; a merge that authored nothing is still counted under `merge commit(s)`.

**D6 — The roll-up line stays what it is (FR-002, FR-004).** The existing reasons string `N merge commit(s)` keeps its wording for merges that authored
nothing, so every pre-existing expectation is untouched. A graded merge is part of `graded K of M`, which is already how the line tells a run that graded
everything from one that graded nothing. No new reason is printed.

**D7 — A merge the machine cannot read is a refusal, not a skip (FR-005).** Before grading, each parent of a merge is tested with
`git cat-file -e <parent>^{commit}`; an unreadable parent produces the existing failure shape for an unreadable commit ("cannot grade ... fetch the
full history", T080), never a silent skip, because a skipped merge on a wrong reason is the shape of GAP-027. The shallow-clone refusal that already runs
before the loop is not weakened. This is one new emission site, owned by a new rule (`AMEND-008`, D8).

**D8 — Fixture library: a merge can carry content (FR-006; review finding F12).** `tests/enforcement/lib/FixtureRepo.psm1` makes a `merge` commit with
`git merge --no-ff --no-commit` and commits it, taking no content. It gains optional fields on a merge commit, in the shape of the existing `write` and
`delete`: `mergeWrite` (files written into the merge result, the content a hand-merge or an edit made while merging produces), `mergeDelete`, and
`resolve` (for a conflicting merge: the content to take, written and `git add`ed before the commit). Without them a merge behaves exactly as today. The
fields have a self-test in `tests/enforcement/Harness.Tests.ps1` in the shape of the existing recipe self-tests (the merge has two parents; its result
differs from both when `mergeWrite` is used; a conflicting merge without `resolve` is refused, never ignored: the library's rule that a field it cannot
honour fails loud). Phase 1 delivers this and nothing else.

**D9 — Fixtures, built from field shapes (FR-006, SC-002, SC-003).** Each pair differs in one condition. As variants of the existing rules and in their
shape (`AMEND-001`, `AMEND-002`; the recipe is read from `AMEND-001/pass-merge` and `AMEND-001/fail-merge-readiness-flip-unapproved`):

| Variant | Expected |
|---|---|
| a `Merge branch 'main' into NNN-...` shaped like the kit's real ones (main brings other features' specs, a roadmap change, a kit flow-down) | not graded; output byte-identical to today's (US2) |
| a conflict in `plan.md` resolved by taking the branch's side whole, and the same by taking main's side whole | not graded for that document |
| the shape of 025's review reproduction: a Critical branch the heuristic fails, `**Merge Readiness**: pending` added **inside** a merge, no record | fails AmendmentAuthority; the CriticalEvidence line is the strict one (SC-002) |
| the same merge with `**Amendment approved by**` in the merged file and the approver in the merge message | passes AmendmentAuthority |
| the record in the file but the approver absent from the merge message | fails (the message half, 014 D5) |
| a hand-merged conflict in `plan.md`, no record / with a record | fails / passes |
| a merge combining a parent's already-approved amendment with another parent's, no fresh record | fails (D4) |
| two parents each amended `plan.md` in different places, a clean automatic merge, no record | not graded under D2 as recommended; **graded under the fallback** (variant pins both so the owner's decision is visible) |
| a merge whose only own change is a task tick, and one whose only change is the `**Status**` line | exempt (D3) |
| a merge whose change is a tick against one parent and a rewrite against the other | graded (D3) |
| an octopus merge that authors `plan.md` | graded against all parents (D2 fallback) |
| a merge that deletes an approved document | graded (D3) |
| a merge whose parent is unreadable (a depth-1 clone) | refused with the existing wording (D7, `AMEND-008`) |

**D10 — The measurement replays real history and is part of the feature (FR-009, SC-001).** `scripts/enforcement-pack.ps1` already has the analysis
path feature 014 built for this (`-ReplayBase`, `-ReplayTip`, `-IgnoreAmendmentBoundary`, "no gate, no ritual-checks and no CI workflow passes it").
Phase 3 runs the parent kit's script and the new one over every `NNN-*` branch range in clones of the three adopted projects, and over the kit's own
merged history, and reports for each: merge commits in range, merges the new rule grades, and failures that are new. **It says plainly what the replay
shows:** history before this feature has no approver records for merges, so "none newly failed" is true because those merges authored nothing, which the
combined-diff measurement in the spec already found for 131 of 131; it is not evidence that an owner will find the new failures easy to satisfy.

**D11 — No constitution amendment, and the documents that state the limit (FR-008).** The amendment record and the approver-in-the-message rule are
unchanged, so constitution I needs no amendment; T012 re-reads it for any sentence about merge commits and records the answer in `notes.md`. The limit is
stated in five places, each updated in phase 3: the script header's `LIMIT` comment, feature 025's `plan.md` (D5's limit and Risks) **by an approved
amendment of that plan with its approver record**, `docs/sdlc/critical-delivery.md`, the 025 flow-down note in `adoption/updating.md` (a new note for 026
is added; the 025 note's limit paragraph is left as history), and `docs/roadmap.md` (GAP-032). Feature 014's FR-010 is not edited; the 026 flow-down note
records the narrowing of D7.

## Phases

Detailed tasks and the per-phase **Territory** blocks are in `tasks.md`.

1. **A merge can carry content (fixture library).** D8 only. Delivers the capability behind review finding F12, with its self-test, and changes no check
   and no existing fixture. Independently revertible.
2. **The check and its proof.** D1 to D7 and D9. Delivers US1 and US2 and FR-001 to FR-007: fixtures first and shown failing on the parent, then the grading
   of a merge's own change, built from the shapes real merges have.
3. **Guidance, retirement of the limit, flow-down, measurement.** D10 and D11. The documents, 025's plan amendment, the roadmap, digests and the replay
   over real history (US3, FR-008, FR-009, SC-001).

## Project Structure

### Documentation (this feature)

```text
specs/026-merge-commit-amendment-grading/
├── spec.md
├── plan.md              # this file
├── tasks.md
├── notes.md             # phase evidence, the baseline, the replay
└── checklists/requirements.md
```

### Source Code (repository root)

```text
tests/enforcement/lib/FixtureRepo.psm1     # phase 1: mergeWrite, mergeDelete, resolve
tests/enforcement/Harness.Tests.ps1        # phase 1: the self-test
scripts/enforcement-pack.ps1               # phase 2: Get-MergeAuthoredPaths and the merge branch of the loop
tests/enforcement/rules.json               # phase 2: AMEND-008, AMEND-001 and AMEND-002 variants
tests/enforcement/cases/enforcement-pack/  # phase 2: the fixtures
docs/sdlc/critical-delivery.md             # phase 3
adoption/updating.md                       # phase 3: flow-down note
docs/roadmap.md                            # phase 3
docs/digests/**                            # phase 3
specs/025-critical-merge-ready-signal/plan.md   # phase 3: an approved amendment (D11)
```

**Structure Decision**: no new script and no new library file; `scripts/enforcement-pack.ps1` already ships verbatim, so `kit-manifest.json` needs no
entry. The ordinary-commit path of the loop and `Get-AddedRecordLines` are not edited.

## Testing Strategy

- Each rule is first written as a failing fixture and shown failing on the parent commit, then the behaviour lands. Where the parent passes by design
  (a merge that authored nothing) the fixture is a control, named as such.
- Every pre-existing case passes unchanged after each phase; `-Case AMEND-`, `-Case CRIT-` per phase; the full harness on an isolated checkout of the
  final commit (feature 022's method).
- **Field-shaped fixtures are required, not optional** (D9): the real-merge shape (main into the branch) and 025's reproduction.
- A mutation is shown for each new fixture that guards a branch of the new code (the per-parent exemption, the intersection of records, the auto-merge
  comparison): the code is mutated, the fixture is shown failing, the code is restored byte for byte (feature 025's method, round 1 F2).
- Phase 3's replay over real history, recorded in `notes.md`.

## Risks

- **The fail-closed fallback is reachable.** An octopus merge, or a git older than 2.38, grades a clean combination of two amended parents as authored. It
  is rare (0 of 131 real merges) and satisfiable (a record), and D2 says so; the owner may choose to accept it as the whole rule and skip the refinement.
- **`merge-tree --write-tree` writes objects.** Unreferenced and collectable, no ref or working-tree change (D2). If an adopter's CI forbids writes to the
  object database the call fails and the fallback grades the merge (fail-closed), which is stated, not hidden.
- **A merge that takes a file whole from a parent inherits that parent's grading** (spec Assumptions): content brought in from a branch that was never
  graded stays ungraded. That is the same as today and is bounded by gate 6.
- **The record is still a written claim.** Grading a merge extends the approver rule to a case it did not cover; it does not make the approver's name
  proof of who approved (feature 025's Risks, unchanged).
- **A graded merge of an existing `main`-into-branch shape could surprise an owner** if `main` and the branch both amended the same feature document. D2
  makes that clean case silent; a conflicting one needs a record, which is the point.
- **The new helper reads more blobs per merge** (per candidate document, per parent). The batch cost the loop was optimised for (SC-006 of 014) is
  unchanged for ordinary commits; the replay in phase 3 reports the run time on the largest history.

## Needs the owner

1. **D2, the auto-merge refinement.** Recommended: exempt a document equal to git's automatic merge of the parents, with the fail-closed fallback for an
   octopus merge or an old git. This **amends the approved spec** (Option A row, FR-001, FR-002), so it carries your approver record. Alternative: keep
   "differs from every parent" as approved and accept that a clean automatic merge of two amended parents needs a record (and may appear in CI's
   synthetic merge when `main` touched the same document).
2. **D3, the exemptions per parent.** Recommended as written (a tick-only or `**Status**`-only change must hold against every parent). Alternative: against
   the first parent only.
3. **D4, the record must be new against every parent.** Recommended as written. Alternative: new against the first parent only, which would let a record a
   side branch already carried approve the merge's own change.
4. **The phase count.** Recommended three (harness capability, check, documents). Alternative: two, folding the harness capability into the check phase,
   at the cost of a phase over the size guideline.
5. **The plan's approval.** `tasks.md` follows once it is given.

## Complexity Tracking

No constitution violation to justify.
