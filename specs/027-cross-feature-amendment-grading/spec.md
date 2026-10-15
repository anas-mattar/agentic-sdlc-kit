# Feature Specification: Grade amendments of another feature's approved documents in the amendment-authority check

**Feature Branch**: `027-cross-feature-amendment-grading`
**Created**: 2026-10-14
**Status**: Approved 2026-10-14 (owner: anas.m)
**Delivery Level**: Standard
**Rationale Rule**: 1
**Input**: User description: "GAP-033: the amendment-authority check reads only `specs/<branch>/`, so an amendment of another feature's approved `spec.md`, `plan.md`, `tasks.md` or `contracts/*`, made on a later feature's branch or on a `docs/`, `fix/` or `chore/` branch, is graded by no machine rule. Reproduced by feature 026's phase 3 review (finding F2): an unapproved line appended to `specs/025-critical-merge-ready-signal/plan.md` on the 026 branch printed `enforcement-pack: OK`, while the same line in 026's own plan failed."

## Background

Constitution I, Amendment authority, says: once **a feature's** `spec.md` or `plan.md` has been approved, any later change to **that feature's** `spec.md`, `plan.md`,
`tasks.md` or `contracts/` MUST record who approved it (`**Amendment approved by**: <name>, <YYYY-MM-DD>` in the amended section, the same approver named in
the commit message). The rule is about every approved feature. The machine half, `Invoke-AmendmentAuthorityCheck` (`scripts/enforcement-pack.ps1`), grades
one directory only: `$dir = "specs/$Branch"`, and it runs only on `NNN-*` branches. So the rule is written for the whole `specs/` tree and graded for one
feature's directory of it.

**Two ways to slip through, both reproduced or observed:**

1. **Another feature's directory, on a numbered branch.** Feature 026 amended feature 025's approved `plan.md` on its own branch (the retirement of a limit, with
   the owner's record). The check printed `AmendmentAuthority: graded 21 of 21 ... enforcement-pack: OK`; the phase 3 review reproduced that the same unapproved
   line in 025's plan also prints `OK`, and in 026's own plan fails. That amendment was checked by human review only.
2. **A branch with no amendment check at all.** `fix/`, `chore/` and `docs/` branches run no amendment check (branch-strategy: the Lite lane "skips
   spec.md/plan.md/tasks.md"). A `docs/` branch is the natural home of a cross-feature correction, and PR #81 (026's FR-003 amendment) was exactly that, and
   carried its record because the owner's process asked for one, not because anything graded it.

**What the real history says** (a first measurement, made 2026-10-14 to choose the shape; the plan re-runs it per commit, FR-010). Over the 107 merge commits in
this kit's `main`, taking each merged branch's net change from its merge base to its second parent and counting a spec document that exists in the base and is
modified or removed in a directory that is not the branch's own:

| Merge | Branch (lane) | Document amended | Graded today |
|---|---|---|---|
| `abb4d47` | `026-merge-commit-amendment-grading` (numbered) | `specs/025-critical-merge-ready-signal/plan.md` | no |
| `22f2af4` | `007-adoption-doctor` (numbered) | `specs/004-kit-update-channel/contracts/update-kit-cli.md`, `specs/006-verification-pack/contracts/ritual-checks-ci.md` | no |
| `c28a867` | `fix/enforcement-pack-main-branch` (Lite) | `specs/002-enforcement-pack/spec.md` | no |
| `59deae2` | `docs/026-fr-003-rename-amendment` (Lite) | `specs/026-merge-commit-amendment-grading/spec.md` | no |

Four of 107 merges: rare, real, and half of them on a lane that runs no check. No history in this repository, on any ref, removes a spec document
(`git log --all --diff-filter=D -- 'specs/NNN-*'` is empty), so the removal case below is a stated shape, not an observed one. Whether the three older ones carried a record is
not known from this table (the first two predate or sit beside feature 014); the replay measures it. This measurement is of a branch's *net* change, and the
check grades *commits*; it chooses the shape and proves nothing about the verdict.

## Decision for the owner

**Recommendation: option B, grade the amendments of every approved feature's documents on every branch that can carry them**, by the same record rule as today.

| | Shape | What it does | Cost |
|---|---|---|---|
| A | On `NNN-*` branches only, also grade the other features' directories | Closes the 025 reproduction. `fix/`, `chore/` and `docs/` branches stay unchecked. | Leaves the more natural carrier of a cross-feature correction (a `docs/` branch) ungraded: 2 of the 4 real cases above. The gap moves, it does not close. |
| B (recommended) | A, and the Lite lane (`fix/`, `chore/`, `docs/`) grades the same documents. Both lanes grade only a document that **exists at the diff base** (approved on the integration branch). | An amendment of any approved feature's document needs the usual record and the approver in the message, whichever branch carries it. The check says nothing on a Lite branch that changes no such document. | A Lite branch that amends an approved spec without a record newly fails: that is the point, and the replay (FR-010) counts how many real branches it would have. A Lite lane that cannot grade (no base, shallow clone) is named UNGRADED and never newly failed (014 FR-009 stands). |
| C | Leave the check alone; state the limit | Nothing built. | The gap stays on the record in the roadmap only; the constitution says "that feature's" and the machine grades one directory. |

**Why "exists at the diff base" is the line.** The existing check calls any change to a document after its creation an amendment, so a branch's own spec is
graded from its second commit on. For another feature's directory the equivalent is: the document is already on the integration branch (it was approved at
that feature's merge, gate 6), so a change to it from a later branch is an amendment of an approved document. A document of another feature that this branch
itself created (a `docs/claim-*` branch adds a new directory and edits it again) is not yet approved and is not graded. The existing exemptions stay, because they
express what is not an amendment: a creation, a task tick, a `**Status**` line alone, and a renumbering (a whole feature directory moves).

**Sub-decision inside B: a removal.** A document of another feature removed on a branch is graded like any other change, and the only record that could pass
it would be read from a file that no longer exists, so, as for an own document today (feature 014), it has no passing path in an ordinary commit. Recommended:
accept, because deleting an approved document is what the rule exists to catch and the history holds no removal to protect. The alternative (a removal needs
no record) is a hole the owner would have to name.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A later feature cannot amend an earlier feature's approved plan unseen (Priority: P1)

An owner, or an agent, edits `specs/NNN-earlier/plan.md` on a later feature's branch with no approver record. The check treats that as the amendment it is.

**Why this priority**: it is the gap, reproduced, and it is the amendment feature 026 itself made.

**Independent Test**: a fixture built from the shape the 026 phase 3 review reproduced (branch `NNN-b`, an approved `specs/NNN-a/plan.md` already on the base, a
commit on `NNN-b` that appends a line to it with no record): the run fails with the amendment message and names the other feature's file; the same commit with a
conforming record in that document and the approver in the message passes.

**Acceptance Scenarios**:

1. **Given** `specs/<other>/plan.md` exists on the base and a commit on the numbered branch changes it with no record, **Then** AmendmentAuthority fails and
   names the file.
2. **Given** the same commit with `**Amendment approved by**: <name>, <date>` in the amended section and the name in the commit message, **Then** it passes.
3. **Given** a commit that only ticks a box in another feature's `tasks.md`, or changes only its `**Status**` line, **Then** the exemptions apply.

---

### User Story 2 - A `docs/`, `fix/` or `chore/` branch cannot amend an approved document unseen (Priority: P1)

**Why this priority**: the Lite lane is where cross-feature corrections naturally land, and it runs no amendment check at all.

**Independent Test**: the same fixture on a `docs/x` branch (and `fix/x`, `chore/x`): fails without a record, passes with one; a branch whose commits touch no
spec document prints exactly what it printed before.

**Acceptance Scenarios**:

1. **Given** a `docs/` branch whose commit changes an approved document of any feature with no record, **Then** AmendmentAuthority fails and names the file.
2. **Given** a `docs/` branch that changes no spec document (a roadmap change, a guide), **Then** the output is byte-identical to today's.
3. **Given** a Lite branch in a clone where the check cannot compute a base or the clone is shallow, **Then** the run reports AmendmentAuthority UNGRADED with the
   reason and does not fail (014 FR-009).

---

### User Story 3 - Creation, claims and renumbering are not newly flagged (Priority: P1)

**Why this priority**: the check is useless to a team that has to work around it; the data is why this is a requirement and not a hope.

**Independent Test**: fixtures of a `docs/claim-*` branch that adds a new feature directory and edits it in a second commit; a renumbering that moves a whole
feature directory; a merge of `main` into a branch that brings other features' documents; none newly fails.

**Acceptance Scenarios**:

1. **Given** a document of another feature that is absent from the base and created on this branch, **Then** it is not graded (first appearance).
2. **Given** a whole `specs/NNN-name/` directory moved to a new number, **Then** it is not graded.
3. **Given** a merge of `main` into the branch, **Then** feature 026's authored-content rule decides it for the other features' documents exactly as it does for
   the branch's own: a result equal to a parent's, or to git's automatic merge, is not graded.

---

### User Story 4 - The limit is retired in the documents, and adopters are told (Priority: P2)

**Acceptance Scenarios**:

1. **Given** the shipped feature, **Then** the script header, the roadmap (GAP-033) and an `adoption/updating.md` flow-down note say what is now graded and
   what stays open, and no kit document says an amendment of another feature's document is ungraded without also saying that it is now graded.

---

### Edge Cases

- A document of another feature that exists on the base is changed in the same commit as the branch's own document: both are graded; the failure names every
  amended file; one conforming record per amended document.
- The record is read from the amended document of the *other* feature, so an owner amending 025's plan puts `**Amendment approved by**` in 025's plan (as 026
  did), and a record in this branch's own `notes.md` approves nothing (the H4 rule is unchanged).
- A `specs/_templates/` path, a path outside `specs/NNN-*`, a feature's `notes.md`, `quickstart.md`, `checklists/`, review files and `screenshots/`: not graded,
  as today (the graded set is `spec.md`, `plan.md`, `tasks.md`, `contracts/**`).
- A document that exists on the base but was already changed by an earlier commit of this same range: graded per commit, against that commit's own parent, as
  today.
- A branch with no readable base, a shallow clone, an unreadable parent: the existing refusals apply on a numbered branch; on a Lite branch each is named
  UNGRADED and never newly failed.
- A trunk branch (`main`, `master`): no scripted checks apply, as today.
- A rebase or squash of the branch: one-parent commits, graded as ordinary commits, as today.
- A rename of a document from one feature's directory to another's is a renumbering only when the whole directory moves; a single file moved between feature
  directories is graded as the removal of the old path and a creation of the new one.
- The 026 spec's edge case "a document the merge changes for another feature: not this branch's documents, so not graded, as today" is superseded by this
  feature for the documents that exist on the base. Feature 026's documents are not edited; the flow-down note says so, in the shape 026 used for 014's D7.

## Level Rationale *(mandatory — answers the four Critical triggers, in writing)*

- **domain-invariants**: does not apply — the kit has no domain-invariants pack; this changes which paths a script grades.
- **irreversible-data**: does not apply — nothing is migrated, dropped or rewritten; commits are read, never changed.
- **authn-authz-payment**: does not apply — no authentication, authorization or payment is touched.
- **auditable-evidence**: does not apply — the check is the machine half of constitution I's amendment record, which is a written claim a reviewer can falsify and
  not proof of who approved; this feature widens what is *graded*, adds no new evidence a regulator would rely on, and gate 6 (human review at merge) is
  unchanged and stands behind the record. The honest counter-argument is that the check is part of an approval trail; the answer given is Standard, as for 026.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `Invoke-AmendmentAuthorityCheck` MUST grade, on a numbered branch, a commit's change to a `spec.md`, `plan.md`, `tasks.md` or `contracts/**` file of
  **any** `specs/NNN-*` directory, not only `specs/<branch>/`, by the rules it applies to the branch's own directory today.
- **FR-002**: A document of a directory other than the branch's own MUST be graded only when it exists at the diff base. A document that does not exist there
  (created on this branch or another) is a creation and is not graded. The branch's own directory is graded as today.
- **FR-003**: On a `fix/`, `chore/` or `docs/` branch the check MUST grade the same documents by the same rules (FR-001, FR-002, FR-004), and MUST print
  nothing new and change no verdict when no commit changes such a document.
- **FR-004**: The exemptions MUST be unchanged and apply to another feature's document as to the branch's own: first appearance, a task tick in either
  direction, a `**Status**`-only change, a renumbering (the whole feature directory moves), and feature 026's rule for the content a merge authored.
- **FR-005**: The approver rule MUST be unchanged: `**Amendment approved by**: <name>, <YYYY-MM-DD>` added in the amended document, and the approver named in
  the commit message (the commit-message half unchanged, 014 D5). A record in a document other than the amended one approves nothing.
- **FR-006**: The failure text MUST name every amended file with its feature directory, and say that the file belongs to another feature when it does.
- **FR-007**: A removal of an approved document of another feature MUST be graded like any other change (sub-decision: no passing path in an ordinary commit,
  as for an own document today); the guidance says so.
- **FR-008**: Where the check cannot grade, a numbered branch keeps the existing refusals (shallow clone, no base, unreadable parent or merge, `AMEND-008`);
  a Lite branch MUST report the same conditions as UNGRADED with the reason and MUST NOT newly fail on them (014 FR-009).
- **FR-009**: A branch whose commits change no spec document of any feature (and, on a numbered branch, none beyond its own) MUST produce byte-identical output
  to today's, on every lane.
- **FR-010**: The measurement MUST be re-run **per commit**, in the shape CI grades a pull request, on this kit's history and on clones of the three adopted
  projects, Lite branches included, old script against new, and report: how many commits are newly graded, how many newly fail, how many of those carried a
  record, and that every other output is byte-identical; and MUST say plainly what it does and does not show.
- **FR-011**: The check MUST keep grading only the commits of the branch's own range and MUST NOT grade already-merged history retroactively.
- **FR-012**: The fixture library MUST gain what the cases need (a base that already holds the other feature's documents, a Lite branch name), and every
  behaviour in this spec MUST have a failing and a passing fixture written first and shown failing on the parent, including shapes taken from 026's
  reproduction, a `docs/` branch, a claim branch, a renumbering and a merge of `main`. Each new rule is inventoried in `tests/enforcement/rules.json`.
- **FR-013**: The existing amendment-authority fixtures MUST pass unchanged.
- **FR-014**: Every document that states the limit MUST say what is now graded and what stays open: the script header, `docs/roadmap.md` (GAP-033), an
  `adoption/updating.md` flow-down note, and `docs/sdlc/critical-delivery.md` and the branch-strategy Lite-lane text wherever they say the Lite lane runs no
  amendment check; digests are regenerated by `scripts/build-digests.ps1`, never by hand.

### Key Entities

- **Approved document of another feature**: a `spec.md`, `plan.md`, `tasks.md` or `contracts/**` file under a `specs/NNN-*` directory other than the branch's own
  (or, on a Lite branch, any such directory), that exists at the diff base.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The shape reproduced in 026's phase 3 review (an unapproved line in another feature's approved plan, on a numbered branch) fails the amendment
  check, and the same change with a conforming record passes.
- **SC-002**: The same change on a `docs/`, a `fix/` and a `chore/` branch fails without a record and passes with one.
- **SC-003**: A claim branch, a renumbering and a merge of `main` into a feature branch are not newly flagged.
- **SC-004**: Across the kit's history and the three adopted projects, the replay (FR-010) reports its counts, and no output differs for a commit that changes no
  other feature's document.
- **SC-005**: The full harness passes with every pre-existing case unchanged and no unowned emission site.

## Assumptions

- The constitution already says "that feature's `spec.md`, `plan.md`, `tasks.md` or `contracts/`" for every approved feature, so no constitution amendment is
  expected; the plan confirms by reading constitution I and the Amendment authority clause.
- "Exists on the diff base" is the machine's definition of "already approved": a document reaches the integration branch through gate 6.
- The diff base the pack already computes (`Get-DiffBase`) is the right base; a branch's own creation of a document is invisible to it, which is the intent.
- Feature 014's and 026's documents are history and are not edited; this spec records the supersession, as 026 did for 014's D7.
- The record is a written claim, not proof of who approved; that is a stated limit of the rule, not of this feature.
