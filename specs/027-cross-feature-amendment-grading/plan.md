# Implementation Plan: Grade amendments of another feature's approved documents in the amendment-authority check

**Branch**: `027-cross-feature-amendment-grading` | **Date**: 2026-10-14 | **Spec**: specs/027-cross-feature-amendment-grading/spec.md
**Input**: Feature specification (approved, anas.m, 2026-10-14; option B, removal accepted) + decisions D1–D11 below
**Gate Batching**: none
**Gate Certification**: user-run
**Status**: Draft — awaiting the owner's approval of decisions D1–D11 and the three phases

## Summary

`Invoke-AmendmentAuthorityCheck` (`scripts/enforcement-pack.ps1`) grades one directory, `specs/<branch>/`, and only on `NNN-*` branches. This feature makes it
grade a commit's change to a `spec.md`, `plan.md`, `tasks.md` or `contracts/**` file of **any** `specs/NNN-*` directory that **exists at the diff base**
(approved on the integration branch), on a numbered branch **and** on a `fix/`, `chore/` or `docs/` branch. The grading tail (the record, the approver in the
message, the exemptions, the failure text) is reused: a cross-feature amendment fails exactly like an own-feature one, with one clause that says the file
belongs to another feature. Nothing about the branch's own directory changes.

Three phases, each independently revertible. **Phase 1** generalises the grading on numbered branches, for ordinary commits and for merges (feature 026's
authored-content rule, applied to every feature's documents), fixtures first. **Phase 2** adds the Lite lane, which is where the refusals turn into
UNGRADED lines and where byte-identical output is the hard constraint. **Phase 3** is the guidance, the retirement of the limit in the documents and the replay
over real history (per commit, Lite branches included). The lesson 024, 025 and 026 paid for governs the plan: **fixtures are built from field shapes** (026's
reproduction, the 007 and fix/ merges of the table in the spec), and the replay on real history is part of the feature.

**No harness capability is needed.** A recipe already puts documents on `main`, branches from it with any branch name (`docs/x`, `fix/x`), and builds merges,
renumberings and octopus merges (026). Phase 1 verifies this by writing the first fixture; if a recipe cannot express a shape, the gap is a task of that phase,
not a surprise in phase 2.

## Technical Context

**Language/Version**: PowerShell 7+ (`pwsh`); `git` 2.38 or newer for the merge comparison already built in 026 (this machine has 2.55)
**Primary Dependencies**: none new
**Storage**: files and git state only
**Testing**: the enforcement harness (`tests/enforcement/`): real temporary git repositories, hand-written expectations, a passing and a failing fixture per
rule. Every existing `AMEND-*` and `LITE-*` case must pass unchanged (FR-013).
**Target Platform**: any runner with `pwsh` and `git`
**Project Type**: governance tooling (scripts plus documents)
**Constraints**: a branch that changes no spec document of any other feature prints byte-identical output on every lane (FR-009); the branch's own directory is
graded by the code that grades it today, not rewritten (D3); no other member changes; the shallow-clone and unreadable-parent refusals are not weakened on a
numbered branch
**Scale/Scope**: a generalisation of the row filter and the merge helper in `scripts/enforcement-pack.ps1`, a Lite-lane call in the dispatch, about 25 fixture
cases, five documents, digests

## Constitution Check

- [x] **Specification First (I)**: `spec.md` is approved; this plan follows it; `tasks.md` follows once the plan is approved. This feature makes the check
  implement what constitution I already says ("**that feature's** `spec.md`, `plan.md`, `tasks.md` or `contracts/`", for every approved feature); the record
  and the approver-in-the-message rule are **unchanged** (D5). T-tasks re-read the clause (D11).
- [ ] **Repository Separation (III)**: not applicable, the kit is one repository.
- [x] **Architecture Consistency (IV)**: no new script; the grading stays inside `Invoke-AmendmentAuthorityCheck` and its helpers (D1, D3).
- [ ] **Domain Invariants (V)**: not applicable, the template's slot is unfilled.
- [x] **Security (VI)**: the check reads commits, trees and blobs; nothing sensitive is read; no object is written beyond the `merge-tree` objects 026 already
  documents.
- [ ] **External Integration Governance (VII)**: not applicable.
- [x] **Testing Requirements (VIII)**: every rule has a passing and a failing fixture, hand-written, failing first on the parent commit.
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI review with Reviewer Provenance.
- [x] **Controlled Delivery (X)**: three phases, one at a time; this changes an enforcement member, so the owner runs the gate: no batching, no ci-held.

**Phase sizing rule**: phase 1 is the core and is useful alone (numbered branches). Phase 2 depends on phase 1 and adds the lane whose output must not
change; phase 3 is documents and a measurement. Reverting 3, then 2, then 1 leaves a consistent kit.

**Post-design re-check**: no new violation. D2 (the line "exists at the diff base"), D3 (own directory untouched), D6 (a Lite branch is graded only when its
diff touches a spec document) and D8 (three kinds of refusal) are decisions the owner makes by approving or changing this plan.

## Decisions

**D1 — Which paths are graded (FR-001).** One pattern decides, replacing the `"$dir/*"` filter of the row loop and the directory argument of the merge helper:
`^specs/(\d{3}-[^/]+)/(spec\.md|plan\.md|tasks\.md|contracts/.+)$`. The first capture is the **feature directory** of the path. A path whose feature directory is
the branch's own (`$dir`) is graded **as today**. Any other feature directory is "another feature's" (a numbered branch) or "a feature's" (a Lite branch, which
has no own directory). `specs/_templates/`, `notes.md`, `quickstart.md`, `checklists/`, review files and `screenshots/` do not match, as today.

**D2 — "Exists at the diff base" is the line for another feature's documents (FR-002).** The set of graded paths present at the base is read once per run,
`git ls-tree -r --name-only -z <existBase> -- specs`, filtered by D1's pattern. `existBase` is `$Base` (the merge base of `HEAD` and `origin/main`/`main`, which
**moves forward when `main` is merged into the branch**, so a document that arrived by that merge counts as existing) and `$ReplayBase` when the analysis path
replays a range. A subject path of another feature is graded only when it is in the set; one that is not (created on this branch, or on a claim branch) is a
creation. The branch's own directory is **not** tested against the set. An unreadable base tree is a refusal (D8). Why the base and not the commit's parent:
a document created by commit 1 of the branch and amended by commit 2 was never approved on the integration branch, and the parent test would grade it.

**D3 — The own directory keeps its code; other directories get a parallel arm (FR-002, FR-009).** The row loop keeps the existing block for a row whose
(new) path is in `$dir`, verbatim: that is what keeps a branch with no cross-feature change byte-identical and the existing fixtures untouched. A row whose
path is in another feature's directory goes through a new arm with the same exemptions, in this order:

1. status `A`: skip (first appearance).
2. **Subject**: for `M`, `D` and `T` the path; for `R` or `C` within the same feature directory, the new path (as the own-directory arm does, with the same
   `sameContent` blob test: a pure rename passes, a rename that rewrites is graded); for a `R` or `C` **between feature directories**, the **old** path.
3. The subject must be a graded document (D1) in a directory that is not `$dir`, and must exist at the base (D2); otherwise skip.
4. A move between feature directories (step 2's last case) is a **renumbering** and skipped when the old directory holds **no** graded document in the
   commit's tree afterwards (the whole directory moved: `git ls-tree -r --name-only <commit> -- <oldDir>` filtered by D1); otherwise the old path is graded as
   a removal, which has no passing path (the spec's sub-decision, FR-007).
5. `tasks.md`: the existing `Test-CheckboxOnlyChange`. `spec.md`, `plan.md`: the existing `Test-StatusOnlyChange`.
6. Otherwise the subject joins `$amended`.

A row moving a document **out of** the branch's own directory is not graded, as today (stated as a limit). A row moving a document **into** the own directory
keeps today's renumbering skip.

**D4 — Merges (FR-004; feature 026's rule, widened).** `Get-FeatureDocMap` takes a prefix and reads `git ls-tree -r <commit> -- specs`, keeping the paths D1
matches; `Get-MergeAuthoredPaths` stops taking one `Dir`: it computes the leaf from each path's own feature directory, and for a path outside `$dir` it
**first** asks D2 (not in the base set: skip). Everything else in it (the unreadable-parent refusal, the creation, "equals a parent", the automatic-merge
comparison, the per-parent exemptions, a removal graded unless git removes it too) is untouched, so a merge of `main` into the branch, whose result for
another feature's document equals its second parent, authors nothing for it. A whole directory moved inside a merge is graded as the removal of the old paths
(026's D3: a rename is not detected inside a merge); the move belongs in an ordinary commit, where D3 step 4 skips it. **Cost:** a `ls-tree -r specs` per
merge and per parent instead of per feature directory; the replay measures it against 026's 170 ms.

**D5 — One grading tail, with one added clause (FR-005, FR-006).** The loop's tail is not changed: `Get-AddedRecordLines` and `Get-MergeRecordLines` already take
the paths they are given, so the record is read from **the amended file of the other feature** and a record elsewhere approves nothing (H4). The failure text
gains one clause, **only** when an amended path is outside `$dir`: ` Of these, <files> belong(s) to feature <NNN-name>: a document is amended where it lives,
so the record goes in that document` (both failure messages, the missing record and the approver missing from the message). A failure about the own
directory alone reads as it does today.

**D6 — The Lite lane runs the check only when its diff touches a spec document (FR-003, FR-009).** `fix/`, `chore/` and `docs/` branches have no own
directory. The dispatch passes the changed-file list it already computes (`Get-ChangedFiles`, the base-to-`HEAD` diff) and the check returns silently unless
a changed file matches D1's pattern. A branch that changes no spec document therefore prints exactly what it prints today, **including in a shallow clone or
without a base**, which is the property the spec's FR-009 needs and the reason the gate is the changed-file list and not the lane. When the list contains a spec
document the check runs, grades each commit by D2 to D5, and prints its roll-up line (`AmendmentAuthority: graded N of M commit(s) in <range>`) **only if** at
least one commit changed a document that exists at the base (a tick, a `**Status**` line and a record-carrying change count; a branch whose only spec change
is a creation prints nothing). The `docs/` lane's existing line ("review-provenance is the only scripted check that applies") is unchanged unless the roll-up
printed, in which case it names both checks, so it is never false. The pre-existing `fix/` and `chore/` prohibition on a contracts path
(`LiteAndAbuse`) stands; this check grades a `docs/` change to a contract, and a `fix/` or `chore/` one is already refused before it.
**A stated limit:** `Get-ChangedFiles` returns an empty list when `git diff` fails (GAP-034), which this gate reads as "no spec document changed"; GAP-034
is its own row and is not fixed here.

**D7 — The boundary and the empty range apply as they do (FR-011).** The per-commit boundary (D2b, the check present in the commit's parent), the sticky
flag, `-ReplayBase`/`-ReplayTip`, `-IgnoreAmendmentBoundary` and the range `<base>..HEAD` are unchanged and shared by both lanes, so already-merged history is
never graded (FR-011). On a Lite branch an empty range prints nothing (the numbered lane's UNGRADED line for an empty range is kept for numbered branches).

**D8 — Refusals: the numbered lane keeps them, the Lite lane names them UNGRADED (FR-008).** On a numbered branch the shallow-clone refusal, the missing base,
the unreadable parent or merge (`AMEND-008`) and the unparsed metadata remain failures with their texts. On a Lite branch, **after** D6 has found a spec
document in the diff, the same conditions append one `UNGRADED:` line each with the reason and **no failure** (014 FR-009 forbids newly failing a Lite
branch on a condition it cannot compute; the run reads as "not graded", never clean). New emission sites: one `ungraded` per condition, owned by a new rule
(`AMEND-009`), with a fail-direction fixture per condition that applies (the shallow clone, an unreadable parent tree) and the numbered-lane twin as the pass
direction. An unreadable **base tree** (D2) is the same: a failure on a numbered branch, UNGRADED on a Lite one.

**D9 — Fixtures, built from field shapes (FR-012, SC-001 to SC-003).** Each pair differs in one condition. Rule ids: variants of `AMEND-001` (record
missing / approver not in message), `AMEND-002` (the record's position), a new `AMEND-009` (Lite UNGRADED), and `LITE-*` for the lane. The base holds
`specs/001-a/` (approved) and the branch is `002-b` or `docs/x`, `fix/x`, `chore/x`:

| Variant | Expected |
|---|---|
| `002-b` appends a line to `001-a/plan.md`, no record (the shape 026's review reproduced) | **fails**, names `001-a/plan.md` and says it belongs to another feature (parent: passes, by design the bug) |
| the same with the record in `001-a/plan.md` and the approver in the message | passes |
| the record in `002-b`'s own `notes.md` or own plan | **fails** (H4: the record goes in the amended document) |
| the same change on `docs/x`, on `fix/x` and on `chore/x` (a spec change, never a contract path, which LiteAndAbuse refuses first) | fails without a record, passes with one |
| a `docs/x` branch that changes `README.md` and the roadmap only | passes, output **byte-identical** to the parent's (control by design) |
| a `docs/claim-*` branch that adds `specs/003-c/spec.md` and edits it in a second commit | passes (D2: not at the base) |
| a `002-b` branch that adds a document of another feature absent from the base and edits it | passes |
| the whole directory `001-a/` renumbered to `009-a/` on a branch | passes (D3 step 4) |
| a single document moved from `001-a/` to `003-c/`, the rest staying | fails (the old path is graded as a removal) |
| a document of `001-a` removed (a `docs/` branch) | fails, no passing path (the sub-decision) |
| a tick and a `**Status**`-only change in `001-a` | exempt |
| a tick in `001-a/tasks.md` together with a text rewrite | graded |
| a merge of `main` into `002-b`, `main` having changed `001-a/plan.md` | not graded, output unchanged |
| a merge on `002-b` that hand-resolves `001-a/plan.md`, no record / with a record | fails / passes |
| a merge that deletes `001-a/contracts/x.md` while merging | graded (026's rule, widened) |
| a Lite branch changing `001-a/plan.md` in a shallow clone, and with an unreadable parent tree | `UNGRADED` line, exit 0 (`AMEND-009`) |
| the same two on a numbered branch | the existing refusals (failures) |
| two `001-a` documents amended in one commit, one with a record | fails naming the one without |
| a `docs/x` branch with **no** spec change in a shallow clone | prints nothing new (byte-identical to the parent's) |

**D10 — The replay is per commit, over real history, Lite branches included (FR-010, SC-004).** `-ReplayBase`, `-ReplayTip` and
`-IgnoreAmendmentBoundary` already exist for this and are passed by no gate. Phase 3 runs the parent kit's script and the new one, from a scratch directory
with `-Root` a clone, over: each merged `NNN-*` branch's range, and each merged `fix/`, `chore/` and `docs/` branch's range (the branch name read from the
merge subject), in this kit's history and in clones of the three adopted projects, in the shape CI grades a pull request (`<merge>^1..<merge>`). It reports,
per history: commits newly graded, newly failing, **how many of the newly failing carry a record in the amended document** (the table in the spec says four
merges amend another feature's documents, and the answer to "would an honest owner have been blocked" is in that column), and that every other output is
byte-identical. **It says plainly what it shows:** that no unrelated branch would have changed; it does **not** show how easy a newly failing branch is to
satisfy, and it grades documents as they stood, with the repository's own helper functions (the clone's, not the working tree's).

**D11 — No constitution amendment, and the documents that state the limit (FR-014).** Constitution I already says "that feature's" for every approved
feature; a task re-reads the clause and records the answer in `notes.md`. The limit is stated in: the script header's `LIMIT` comment (changed in **phase 1**
with the code it describes, the lesson of 026's D11), `docs/roadmap.md` (GAP-033: shipped, with the owner and spec path), `adoption/updating.md` (a flow-down
note in the shape of 026's, saying what an adopter may newly see on a Lite branch, what to do, the stated limits, and that 026's edge case "a document the merge
changes for another feature: not graded" is superseded for documents that exist at the base), and `docs/sdlc/branch-strategy.md` and
`docs/sdlc/critical-delivery.md` wherever they say the Lite lane runs no amendment check (a task greps both, and edits only the sentence that is now false,
with a digest regeneration by `scripts/build-digests.ps1`). Feature 014's and 026's documents are not edited; feature 025's plan is not touched.

## Phases

Detailed tasks and the per-phase **Territory** blocks are in `tasks.md`.

1. **Numbered branches: any feature's documents, ordinary commits and merges.** D1 to D5, D7, D8 (the numbered arm) and the `LIMIT` comment. Delivers US1 and
   US3 and FR-001, FR-002, FR-004 to FR-007, FR-011, FR-013: fixtures first and shown failing on the parent, then the generalised row loop and merge helper.
2. **The Lite lane.** D6 and D8 (the Lite arm). Delivers US2 and FR-003, FR-008, FR-009: the dispatch call, the changed-file gate, UNGRADED lines, byte-identity
   proof on branches that touch no spec document.
3. **Guidance, retirement of the limit, flow-down, replay.** D10 and D11. The documents, the roadmap, digests, and the replay over real history (US4, FR-010,
   FR-014, SC-004).

## Project Structure

### Documentation (this feature)

```text
specs/027-cross-feature-amendment-grading/
├── spec.md
├── plan.md              # this file
├── tasks.md
├── notes.md             # phase evidence, the baseline, the replay
└── checklists/requirements.md
```

### Source Code (repository root)

```text
scripts/enforcement-pack.ps1               # phase 1: the row loop, Get-FeatureDocMap, Get-MergeAuthoredPaths, the LIMIT comment; phase 2: the dispatch and the Lite arm
tests/enforcement/rules.json               # phases 1 and 2: AMEND-001 and AMEND-002 variants, AMEND-009, LITE variants
tests/enforcement/cases/enforcement-pack/  # phases 1 and 2: the fixtures
docs/sdlc/branch-strategy.md               # phase 3, only where a sentence is now false
docs/sdlc/critical-delivery.md             # phase 3, only where a sentence is now false
adoption/updating.md                       # phase 3: flow-down note
docs/roadmap.md                            # phase 3: GAP-033
docs/digests/**                            # phase 3
```

**Structure Decision**: no new script and no new library file; `scripts/enforcement-pack.ps1` already ships verbatim, so `kit-manifest.json` needs no entry.
`Get-AddedRecordLines`, `Get-MergeRecordLines`, the exemption helpers and the own-directory row block are not edited.

## Testing Strategy

- Each rule is first written as a failing fixture and shown failing on the parent commit, then the behaviour lands. Where the parent passes by design (a
  branch that changes no spec document, a claim branch) the fixture is a control, named as such.
- Every pre-existing case passes unchanged after each phase; `-Case AMEND-`, `-Case LITE-`, `-Case CRIT-` per phase; the full harness on an isolated checkout of
  the final commit (feature 022's method).
- **Field-shaped fixtures are required, not optional** (D9): 026's reproduction, a `main`-into-branch merge, a claim branch, a renumbering.
- A mutation is shown for each new fixture that guards a branch of the new code (the exists-at-base test, the whole-directory test, the Lite gate, the
  per-lane refusal): the code is mutated, the fixture is shown failing, the code is restored byte for byte (feature 025's method).
- Phase 3's replay over real history, recorded in `notes.md`.

## Risks

- **A Lite branch can newly fail.** That is the decision the owner took (option B). The replay counts it on real history and the flow-down note says what to
  do (add the record in the amended document, name the approver in the commit message). It cannot newly fail on a condition the machine cannot compute (D8).
- **"Exists at the base" is a proxy for "approved".** A document on `main` was approved at its feature's gate 6, but a document that landed on `main` while
  still `Draft` is graded as approved. The own-directory rule has the same shape (any change after the first commit). Stated, not narrowed.
- **A move of a document out of the branch's own directory is not graded**, as today (D3). A whole directory moved inside a merge is graded as a removal (D4,
  026's D3). Both are stated limits.
- **The Lite gate trusts `Get-ChangedFiles`**, which returns an empty list when `git diff` fails (GAP-034): a Lite branch with an unreadable diff is not graded
  and prints as before. Named, and fixed by its own row, not here.
- **The record is still a written claim.** Grading more documents extends the approver rule; it does not make a name proof of who approved (constitution I).
- **A merge's `ls-tree -r specs` reads more entries per merge.** The replay reports the run time on the largest history against 026's 170 ms per merge.
- **A flow-down surprise on adopted projects** that amended an older feature's plan on a later branch with no record: the first run after the update fails
  with the new clause. The note says so, and the replay on the three adopted histories says how many.

## Needs the owner

1. **D2, "exists at the diff base" for another feature's documents.** Recommended as written. Alternative: "exists in the commit's parent", which grades a
   document that the same branch created and then edited again (a claim branch's second commit).
2. **D6, the Lite lane's gate is the changed-file list.** Recommended: it keeps a branch with no spec change byte-identical even in a shallow clone, at the
   cost of trusting `Get-ChangedFiles` (GAP-034). Alternative: run the check on every Lite branch and print an UNGRADED line when it cannot compute, which
   changes the output of every Lite run in a shallow clone.
3. **D3 step 4, a whole-directory move is a renumbering; a single moved document is a removal.** Recommended as written. Alternative: any move between feature
   directories is skipped (the 014 behaviour into the own directory), which lets a single document be moved out of an approved feature with no record.
4. **D11, the documents edited, and that no document of 014, 025 or 026 is touched.** Recommended as written.
5. **The phase count.** Recommended three (numbered, Lite, documents). Alternative: two, folding the Lite lane into phase 1, at the cost of a larger phase.
6. **The plan's approval.** `tasks.md` follows once it is given.

## Complexity Tracking

No constitution violation to justify.
