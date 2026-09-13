# Feature Specification: Amendment Authority

**Feature Branch**: `014-amendment-authority`
**Created**: 2026-09-13
**Status**: Approved 2026-09-13 (owner: anas.m)
**Delivery Level**: Standard
**Input**: User description: "Amendment authority: any change to an approved spec.md, plan.md, tasks.md or contract records who approved it, and an implementing agent may not approve its own"

## Context

Constitution I fixes the order of work: "create **or update** `spec.md`; … `plan.md`; …
`tasks.md`; implement one approved phase only". It says nothing about who may perform the
update. The Governance section's "An amendment is adopted only after human approval" binds
amendments **to the constitution**, not to feature documents. So the kit requires approval
to *start* a feature and asks nothing of every change made to it afterwards.

Every machine check grades something other than authority. `scripts/scope-check.ps1` and
`scripts/scope-check-repos.ps1` grade paths against a declared Territory,
`scripts/doc-lint.ps1` grades path resolution, `scripts/enforcement-pack.ps1` grades levels,
lanes, tokens and dates. None of them asks who agreed to the rule being graded — so an agent
that widens its own Territory passes the scope check by construction, because the check reads
the Territory the same agent just wrote.

This was observed, not theorised. FitForge's feature 001 governance AI review (finding F3)
found that after the owner's single approval, five rule changes — a new package, a changed
contract value, two widened Territory blocks, an added phase — were written and consumed by
the same implementing session within minutes, one pair **29 seconds apart**, with every
machine check green throughout. Every one of those amendments happened to be correct, which
is precisely why the mechanism would have survived one that was not. Getting the order right
(amend, then implement) is a check on retroactivity, not a check on consent; the two had
been quietly conflated.

The adopting project then amended **its own** constitution (FitForge 1.1.0, Principle I,
"Amendment authority") and wrote the rule in full — but recorded, in the clause itself, that
it cannot host the check:

> **Enforcement, honestly stated**: this clause is enforced by review, not by machine. The
> natural home for the check is `scripts/enforcement-pack.ps1`, which `kit-manifest.json`
> classes `verbatim` — a rule added to it here would be reverted by the next kit update,
> leaving a constitutional requirement whose check had quietly disappeared. … The machine
> check is therefore owed to the kit as its own feature.

That debt is this feature. It is why GAP-019 is sequenced ahead of every other open row: it
is the only one whose rule is **already live in an adopted project with nothing enforcing
it**, and an unenforced law that people believe is enforced is worse than an absent one.

**The rule is not being invented here.** FitForge's wording was written in the field, against
a real failure, and this feature adopts it into the kit essentially verbatim — the kit's job
is to ratify it upward and give it teeth, not to produce a rival phrasing that the flow-down
would then have to reconcile.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - An amendment carries its approver (Priority: P1)

An owner has approved a feature's `spec.md` and `plan.md`, and implementation is under way.
Partway through, something must change — a package the plan never listed, a contract value
that turned out wrong, a phase that has to be added, a Territory that must widen. The person
making the change records who agreed to it, in the amended document and in the commit that
carries it, before any phase is implemented against the new text.

**Why this priority**: this is the whole feature. Without the recorded approver there is
nothing for a check to grade and nothing for a reviewer to falsify.

**Independent Test**: amend an approved `plan.md` on a feature branch, add the approver line
to the amended section, name the same approver in the commit, and run the ritual checks —
the branch stays green, and a reviewer reading the diff alone can see who agreed.

**Acceptance Scenarios**:

1. **Given** an approved `plan.md` on a numbered feature branch, **When** a commit widens its
   Territory block and the amended section carries `**Amendment approved by**: <name>,
   <YYYY-MM-DD>` with the same name in the commit message, **Then** the ritual checks pass.
2. **Given** the same amendment, **When** the approver line names a different person from the
   one the commit message names, **Then** the checks fail and say which two names disagree.
3. **Given** an approved `contracts/auth.md`, **When** a commit reinterprets one of its
   clauses without an approver line, **Then** the checks fail and name the file.

---

### User Story 2 - The machine refuses a silent amendment (Priority: P1)

An implementing agent, mid-phase, finds the plan inconvenient and edits it — a new package in
the dependency list, a task quietly reworded to match what the code already does. Nobody
approved the new text. The branch goes red on the next run of the same command CI runs, and
it says what was amended and what is missing.

**Why this priority**: the failure this feature exists to catch is not a person deciding to
cheat — it is an agent and an owner conflating "I wrote it a minute ago" with "it was
agreed". Only a check that fails on the silent case converts the clause from prose into law.

**Independent Test**: amend an approved document with no approver line, run
`pwsh -File scripts/ritual-checks.ps1`, and observe a non-zero exit naming the file and the
missing record.

**Acceptance Scenarios**:

1. **Given** an approved `spec.md`, **When** a commit changes a functional requirement and
   adds no approver line, **Then** the checks fail, name `spec.md`, and state what a
   conforming record looks like.
2. **Given** an amendment whose approver line is present but unfilled (a slot, a `TODO`, an
   empty name, or a date that is not a real `YYYY-MM-DD`), **Then** the checks fail — an
   unfilled record is treated as no record, never as a pass.
3. **Given** a commit that creates a feature's `spec.md`, `plan.md` or `tasks.md` for the
   first time, **Then** no approver line is required — the document's own approval is what
   constitution I already governs, and demanding a record of it would make the first commit
   of every feature red.

---

### User Story 3 - Progress is not an amendment (Priority: P1)

A developer finishes a phase and ticks its tasks off in `tasks.md`. Nothing about the agreed
work changed — the same tasks, in the same words, now done. No approver is required, nothing
goes red, and the ritual costs nothing it did not cost yesterday.

**Why this priority**: P1 alongside the others because it is what makes the rule survivable.
`tasks.md` is modified on nearly every phase commit in this kit's workflow; a rule that
demands an approver for a ticked checkbox would be routed around within a week, and the kit
already knows (GAP-020) that a check people route around is worse than one that does not
exist. The exemption is therefore part of the law, not an optimisation.

**Independent Test**: on an approved `tasks.md`, flip a task's checkbox from `- [ ]` to
`- [x]` and commit — the checks pass with no approver line anywhere.

**Acceptance Scenarios**:

1. **Given** an approved `tasks.md`, **When** a commit only flips task checkbox states,
   **Then** the checks pass with no approver required.
2. **Given** an approved `tasks.md`, **When** a commit reopens a task by changing its text —
   reworded, re-scoped, or annotated with a correction that changes what the task means —
   **Then** an approver record is required, because the agreed work changed.
3. **Given** a commit that both ticks checkboxes and reworks a task's text, **Then** an
   approver record is required — a conforming change is never inferred from the presence of
   an exempt one alongside it.

---

### User Story 4 - The adopted project's owed check arrives (Priority: P2)

FitForge carries the clause in its own constitution and says in the clause that no machine
grades it. After the next `update-kit.ps1`, the check is present, the clause's honesty
paragraph is no longer true, and the project's own CI enforces the rule its owner ratified.

**Why this priority**: P2 because it is the flow-down of P1's work rather than new behaviour,
but it is the reason this row outranks the others — a rule that is live and unenforced in a
real project is the worst state in the kit, and this is the step that ends it.

**Independent Test**: run the update in an adopted project and confirm the check is present,
runs in that project's CI, and grades that project's feature documents.

**Acceptance Scenarios**:

1. **Given** an adopted project on a kit version before this feature, **When**
   `update-kit.ps1` runs, **Then** the check arrives with the rest of the verbatim set and
   the project's CI runs it without further wiring.
2. **Given** an adopted project that has never heard of this rule, **When** the check runs
   over a branch with no amendments, **Then** it passes silently — arrival never turns an
   innocent project red.

---

### Edge Cases

- **A branch renumbered by a lost claim race.** `claim-feature.ps1` renames the branch and
  the spec directory; every feature document appears as added-at-a-new-path. This MUST read
  as creation, not as an unapproved amendment of the old path.
- **A rebase or a merge from `main`.** Commits are replayed and merge commits touch files
  they did not author. Grading a replayed or merged commit as a fresh amendment would make
  team-workflow rule 6 (rebase before gate) impossible to obey.
- **An amendment spanning several documents in one commit** — a plan change plus the tasks
  it implies. One approval covers the commit; the record must not have to be pasted five
  times to be legible.
- **A phase commit that amends and implements together.** This is the exact shape observed in
  FitForge 001 (write the rule, consume it 29 seconds later). Whether the check forbids it
  outright or merely requires the record is a design question for the plan; the spec requires
  only that it cannot happen *silently*.
- **A Micro feature**, which has `spec.md` and no `plan.md`/`tasks.md` — the mini-spec is the
  approved document, and amending it is amending the whole specification.
- **The Lite lane** (`fix/`, `chore/`, `docs/`), which has no feature documents at all and
  must be unaffected.
- **The approver is the owner and the owner drove the agent.** In a solo project the recorded
  name will be the same person who ran the session. The check cannot see intent, and must say
  so rather than implying an independence it did not verify.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The constitution MUST state the rule before any check grades it — an amendment
  to Principle I carrying the requirement, its rationale, and the honest limits of its
  enforcement. The clause MUST be compatible with the wording already ratified in FitForge
  1.1.0, so that flow-down reconciles rather than collides.
- **FR-002**: Once a feature's `spec.md` or `plan.md` has been approved, any later change to
  that feature's `spec.md`, `plan.md`, `tasks.md` or `contracts/` MUST record who approved
  it, as `**Amendment approved by**: <name>, <YYYY-MM-DD>` on the amended section, with the
  same approver named in the amending commit.
- **FR-003**: An implementing agent MUST NOT approve its own amendment. The system MUST state
  precisely what it verifies about this and what it does not.
- **FR-004**: A machine check in `scripts/enforcement-pack.ps1` MUST grade FR-002 on numbered
  feature branches, run as part of `scripts/ritual-checks.ps1`, and fail the branch when a
  change to an approved document carries no conforming record.
- **FR-005**: The check MUST treat the first appearance of a feature document as creation,
  not amendment, and MUST NOT require a record for it.
- **FR-006**: The check MUST NOT require a record for a change to `tasks.md` that alters only
  task checkbox state; it MUST require one for any change to the text of the agreed work.
- **FR-007**: An unfilled record MUST fail: an empty name, an unreplaced slot, a `TODO`
  marker, or a malformed or future date is not a record.
- **FR-008**: A failure message MUST name the file, what class of change was detected, and
  what a conforming record looks like — a developer must never have to read the script to
  learn what the check wants.
- **FR-009**: The check MUST NOT fire on the Lite lane (`fix/`, `chore/`, `docs/`), and MUST
  handle a Micro feature's `spec.md`-only structure without special-casing by the caller.
- **FR-010**: Branch renumbering, rebases and merge commits MUST NOT be graded as amendments.
- **FR-011**: The rule and its check MUST reach adopted projects through the existing
  verbatim update channel, requiring no per-project wiring, and MUST pass silently on a
  project with no amendments.
- **FR-012**: The amendment MUST be reflected wherever the kit already restates the law —
  the sync list, the affected templates, the task-scoped reading table, and the relevant law
  digest — so that no document keeps the pre-amendment reading.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A change to an approved feature document with no approver record fails
  `pwsh -File scripts/ritual-checks.ps1` with a non-zero exit, on this repository and in an
  adopted project, with no per-project configuration.
- **SC-002**: The five amendments recorded in FitForge 001's finding F3 — a new package, a
  changed contract value, two widened Territory blocks, an added phase — would each have
  failed the check as they were actually committed. Verified against the real commits, not
  against reconstructions.
- **SC-003**: A full phase commit that ticks tasks off an approved `tasks.md` and changes no
  agreed text passes with no approver record, measured across this kit's own existing
  feature branches: **zero** retroactive failures attributable to progress marks.
- **SC-004**: Running the check over this repository's merged history produces no failure
  that a reviewer judges spurious; every flagged commit is one where the agreed content
  changed.
- **SC-005**: After flow-down, FitForge's constitution clause no longer needs its
  "Enforcement, honestly stated" paragraph, and the project's CI fails a silent amendment.
- **SC-006**: The check adds no more than a small, stated fraction to the runtime of
  `ritual-checks`, so that nobody is tempted to skip the command that carries it.

## Assumptions

- **The approver is recorded, not authenticated.** The check grades that a name and a date
  are present, well-formed, and consistent between document and commit. It cannot verify that
  the named person agreed — that is review's job, and the clause must say so plainly, the way
  `docs/sdlc/critical-delivery.md` says it of the team arm.
- **Checkbox state is the only exempt change**, because it is the only change whose meaning is
  unambiguous to a machine. Everything else in an approved document is agreed content.
- **"Approved" is taken to begin when the document first exists on the feature branch.** The
  kit has no separate approval token, and inventing one would make this feature a workflow
  change rather than an enforcement change.
- The declared-developer roster (GAP-024) does not exist yet. When it does, it is what would
  let the check verify that an approver is a real declared person; this feature is specified
  so that arrival strengthens it without rework.
- The kit's own in-flight work is unaffected: this branch's documents are themselves subject
  to the rule from the moment the clause lands.

## Out of scope

- Authenticating approvers (signed commits, identity providers, GitHub review state as the
  record). The record is a written claim a reviewer can falsify, exactly like the Reviewer
  Provenance block.
- Approving *level* changes (GAP-023) and checking approver identity against a roster
  (GAP-024). Both are separate rows; this feature must not quietly absorb them.
- Any change to who may approve what. The clause records authority; it does not redistribute
  it.
- Retroactive enforcement over already-merged history. The check grades branches going
  forward; SC-002 and SC-004 read history only as evidence that it works.
