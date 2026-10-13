# Feature Specification: Grade the content a merge commit authors in the amendment-authority check

**Feature Branch**: `026-merge-commit-amendment-grading`
**Created**: 2026-10-14
**Status**: Draft — awaiting owner approval (the shape in "Decision for the owner" is the owner's)
**Delivery Level**: Standard
**Rationale Rule**: 1
**Input**: User description: "GAP-032: grade a merge commit's own change to a spec document in the amendment-authority check. The check skips every commit with more than one parent (feature 014, D7: a merge commit authored nothing), but a merge commit can author content, and since feature 025 a `**Merge Readiness**: pending` added inside a merge turns a strict failure into a warning. Feature 025 accepted the gap as a stated limit and recorded it."

## Background

The amendment-authority check (`Invoke-AmendmentAuthorityCheck`, `scripts/enforcement-pack.ps1`; constitution I, Amendment authority) grades every commit
on a numbered branch that changes an existing `spec.md`, `plan.md`, `tasks.md` or `contracts/*` file after its creation: the commit must carry
`**Amendment approved by**: <name>, <YYYY-MM-DD>` in the amended section and name the same approver in its message. It skips every commit with more than
one parent. Feature 014 gave the reason (plan D7): "a commit with more than one parent authored none of its content", so skipping keeps the team-workflow
rules to rebase before the gate and to merge to `main` obeyable (014 FR-010: "Branch renumbering, rebases and merge commits MUST NOT be graded as amendments").

**What that sentence gets wrong.** It is true of a clean merge, whose result for every file equals what one parent already had. It is false of a merge whose
result for a file equals **neither** parent: a conflict resolved by hand, or an edit made while merging. That content was authored in the merge, by nobody
who recorded an approver. Until feature 025 the gap changed no machine verdict on a Critical branch. Since 025 a `**Merge Readiness**: pending` added
inside a merge turned a failing Critical branch into `enforcement-pack: OK` (reproduced by the phase 1 AI review of feature 025, finding F1). Feature 025
accepted the gap as a stated limit (its route 2: the warning calls the declaration "a claim", gate 6 stands behind it) and recorded it as GAP-032, with
the second finding (F12): the fixture library can only build a merge with no content of its own, so the limit is pinned by no fixture.

**What the real histories say** (measured on 2026-10-14 with git's combined diff, `git diff-tree --cc`, which lists a path only when the merge result
differs from **every** parent; spec documents only, `specs/NNN-*/{spec,plan,tasks}.md` and `contracts/**`):

| History | Merge commits (all refs) | Merges whose result differs from every parent on a spec document | Merges that change a spec document relative to the **first parent** alone |
|---|---|---|---|
| This kit | 101 | **0** | 45 |
| FitForge | 10 | **0** | not measured |
| FlowBoard | 10 | **0** | not measured |
| ExpenseTracker | 10 | **0** | not measured |

The reading: grading by "differs from every parent" would have flagged none of 131 real merges, whereas grading by "differs from the first parent" would
have flagged 45 of the kit's 101 (the ordinary merge of `main`, or of a pull request, into a branch, which brings other features' documents in). That is
the over-grading D7 feared, and the measurement says where the line has to be drawn. The counts are a first measurement made to choose the shape; the plan
re-runs it as part of the feature (FR-009).

## Decision for the owner

**Recommendation: option A, grade the documents whose merged result differs from every parent**, with the same approver-record rule as any other commit.

| | Shape | What it does | Cost |
|---|---|---|---|
| A (recommended) | Grade a merge commit for each spec document of its own feature whose merged result differs from **every** parent | A clean merge, a pull-request merge, and a conflict resolved by taking one side's file whole are not graded (the file equals a parent's). Content the merge authored (a hand-merged conflict, an edit made while merging) needs the usual record: `**Amendment approved by**` in the amended section of the merged file and the approver named in the merge commit message. | A hand-merged conflict in a spec document needs an approver, which is correct and rare (0 of 131 in the field data). A merge that takes a file wholesale from a parent is not graded, so content that already sat in a parent is only as graded as that parent's own commits were. |
| B | Grade every merge against its first parent | Catches everything the merge changes relative to the branch | Flags the ordinary merge of `main` into a branch (45 of the kit's 101 merges change some spec document relative to the first parent): the over-grading D7 exists to avoid, and it would make team-workflow rule 8 unobeyable. Rejected on the data. |
| C | Leave the check alone; state the limit | Nothing built | The gap stays: a `pending` (or any amendment) can be added in a merge with no approver, and 025's `pending` bypass is only as honest as the merges are. The known limit stays on the record in five places. |

**Sub-decision inside A: a hand-merged conflict.** The machine cannot tell "the author resolved a conflict by combining both sides" from "the author wrote
new text during the merge": both are content that equals no parent. Recommended: treat both as authored, so both need the record. The alternative
(exempt conflict resolution) is not implementable without trusting the author to say which it was.

**How D7 is treated, explicitly.** D7 is narrowed, not overturned: a merge commit that authored no content is still skipped (that is every clean merge, so
rules 6 and 8 stay obeyable), and a rebase is still not special (a replayed commit keeps its message and diff, so a conforming amendment stays conforming).
What changes is the premise "a merge commit authored none of its content": it holds for a clean merge and not for a merge that authors a file.
Feature 014's FR-010 is read as "a merge commit **that authored nothing** is not graded". Feature 014's documents are not edited; this spec supersedes the
sentence for merges that author content, and the flow-down note says so.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A merge cannot carry an unapproved change to an approved document (Priority: P1)

An owner, or an agent, resolves a conflict in a feature's approved `plan.md` while merging, or edits it during the merge, with no approver record. The
check now treats that content as an amendment.

**Why this priority**: it is the gap itself. Since feature 025 it can relax a Critical verdict.

**Independent Test**: a fixture built from the shape the phase 1 review of 025 reproduced (a Critical branch the heuristic fails, an approved `plan.md`
that gains `**Merge Readiness**: pending` inside a merge, no approver record): the run fails with the amendment message; the same merge carrying a
conforming record and the approver in its message passes.

**Acceptance Scenarios**:

1. **Given** a merge whose result for `specs/NNN-name/plan.md` equals neither parent's version, with no approver record, **When** the pack runs, **Then**
   AmendmentAuthority fails on the merge commit and names the file.
2. **Given** the same merge with `**Amendment approved by**: <name>, <date>` in the amended section and the name in the merge commit message, **Then** it
   passes.
3. **Given** a merge that changes a `tasks.md` checkbox or a `**Status**` line only, **Then** the existing exemptions apply to the merge's own change.

---

### User Story 2 - An ordinary merge is not newly flagged (Priority: P1)

**Why this priority**: the check is useless to a team that has to work around it on every pull request; the measurement above is the reason this is a
requirement and not a hope.

**Independent Test**: fixtures of `Merge branch 'main' into NNN-...` shapes (main brought in new specs, a roadmap change, a kit flow-down; a conflict
resolved by taking one side's file whole): no new failure, and output byte-identical to today's for a branch whose merges authored nothing.

**Acceptance Scenarios**:

1. **Given** a merge of `main` into the feature branch, **Then** it is not graded and the run's output is unchanged.
2. **Given** a conflict in a spec document resolved by taking one parent's version whole, **Then** it is not graded for that document.
3. **Given** the real kit history and the three adopted projects' histories, **Then** no merge in them is newly failed (FR-009, SC-001).

---

### User Story 3 - The limit is retired in the documents, and adopters are told (Priority: P2)

**Independent Test**: the five places that state the limit (the script header, 025's plan D5 and Risks, `critical-delivery.md`, the 025 flow-down note,
the roadmap) are updated by this feature to say what is closed and what stays open; a flow-down note exists in the shape of 025's.

**Acceptance Scenarios**:

1. **Given** the shipped feature, **Then** no kit document says a `pending` added in a merge is ungraded without also saying it is now graded when the
   merge authored it.

---

### Edge Cases

- A merge with more than two parents (an octopus merge): graded the same way, against every parent; where the merge's own change cannot be computed the
  run reports it UNGRADED with the reason, never as a silent skip.
- `git merge -s ours` (the result equals the first parent): not graded for any file; what the merge discarded from the second parent is not an authored change.
- A merge made through a hosting service's pull-request merge button on `main`: outside the branch range the check grades (`<base>..HEAD`), as today.
- A squash merge or a rebase is not a merge commit (one parent): graded as an ordinary commit, as today.
- A merge that creates a spec document the parents did not have (both sides added it, or neither): the existing first-appearance exemption applies.
- A merge whose approver record exists in the merged file but whose message does not name the approver: fails exactly as for any commit (the message half
  cannot be edited later; 014 D5).
- A document the merge changes for another feature (`specs/<other>/...`): not this branch's documents, so not graded, as today.
- A shallow clone: the history the combined diff needs is missing; the existing shallow-clone refusal applies and is not weakened.
- The existing rule `"is a merge commit)"` (a merge authored nothing) stays true for a clean merge; its wording changes and its fixtures stay.

## Level Rationale *(mandatory — answers the four Critical triggers, in writing)*

- **domain-invariants**: does not apply — the kit has no domain-invariants pack; this changes which commits a script grades.
- **irreversible-data**: does not apply — nothing is migrated, dropped or rewritten; a merge commit is read, never changed.
- **authn-authz-payment**: does not apply — no authentication, authorization or payment is touched.
- **auditable-evidence**: does not apply — the check implements constitution I's amendment record, which is a written claim a reviewer can falsify and not proof of who approved; this feature narrows a hole in what is *graded*, and adds no new evidence a regulator would rely on. The honest counter-argument is that the check is the machine half of an approval trail, so a change to it is a change to evidence handling; the answer given is Standard because the human review at merge (gate 6) is unchanged and is what stands behind the record.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `Invoke-AmendmentAuthorityCheck` MUST, for a commit with more than one parent on a numbered branch, grade each of the feature's `spec.md`,
  `plan.md`, `tasks.md` and `contracts/**` files whose merged content differs from **every** parent's version, as the merge's own change.
- **FR-002**: A merge commit whose result for a document equals any parent's version of it MUST NOT be graded for that document, and a branch whose
  merges authored no content MUST produce byte-identical output to today's.
- **FR-003**: The approver-record rule MUST be unchanged for a merge's own change: `**Amendment approved by**: <name>, <YYYY-MM-DD>` in the amended section
  of the merged file, the approver named in the merge commit message, and the same exemptions (first appearance, pure rename, task ticks, a `**Status**`
  line alone).
- **FR-004**: The roll-up line MUST keep counting what it grades and what it skips, and MUST distinguish a merge skipped because it authored nothing from
  a merge graded because it authored content.
- **FR-005**: Where a merge's own change cannot be computed (an unreadable parent, more than two parents the machine cannot resolve), the check MUST report
  it UNGRADED with a reason and never skip it silently.
- **FR-006**: The fixture library MUST gain a recipe field that lets a merge carry content of its own, with its own self-test, and every behaviour in this
  spec MUST have a failing and a passing fixture written first and shown failing on the parent, including a fixture shaped like a real
  `Merge branch 'main' into NNN-...` merge (main brings in other features' documents and a roadmap change) and one shaped like feature 025's reproduction.
  Each new rule is inventoried in `tests/enforcement/rules.json`.
- **FR-007**: The existing amendment-authority fixtures (including the merge-commit skip) MUST pass unchanged.
- **FR-008**: Every document that states the merge-commit limit MUST say what is now graded and what stays open: the script header, feature 025's
  `plan.md` D5 and Risks (by an approved amendment of that plan, with its approver record), `docs/sdlc/critical-delivery.md`, `adoption/updating.md`
  (a flow-down note), and `docs/roadmap.md` (GAP-032); digests are regenerated by `scripts/build-digests.ps1`, never by hand.
- **FR-009**: The measurement MUST be re-run on the kit's own history and clones of the three adopted projects, and MUST report, for each, how many merge
  commits exist, how many the new rule grades, and that none is newly failed; and MUST say plainly what it does and does not show (history before this
  feature had no approver records for merges, so "none newly failed" is about merges that authored nothing, which the data says is all of them).
- **FR-010**: The check MUST keep grading only the commits of the branch's own range, as today, and MUST NOT grade already-merged history retroactively.

### Key Entities

- **Merge's own change**: the content of a merge commit's result for a document that equals no parent's version of it (git's combined diff).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Across this kit's 101 merge commits and the 30 in FitForge, FlowBoard and ExpenseTracker, no merge is newly failed.
- **SC-002**: The shape reproduced in feature 025's phase 1 review (an unapproved `pending` added inside a merge) fails the amendment check, and the same
  merge with a conforming record passes.
- **SC-003**: A merge of `main` into a feature branch, and a conflict resolved by taking one side's file whole, are not flagged.
- **SC-004**: The full harness passes with every pre-existing case unchanged and no unowned emission site.

## Assumptions

- Git's combined diff (the paths where a merge result differs from every parent) is the machine's definition of "content a merge authored"; it is the
  definition the measurement used, and the plan confirms it on the fixture shapes.
- A merge that takes a file whole from a parent inherits that parent's grading: the content was authored in the parent's own commits, on whatever branch,
  and is graded wherever those commits are in a graded range.
- `**Amendment approved by**` and the commit-message rule are unchanged, so no constitution amendment is expected; the plan confirms by reading
  constitution I.
- The kit's feature 014 documents are history and are not edited; this spec records the narrowing of D7.
