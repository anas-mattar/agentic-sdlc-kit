# Feature Specification: Critical merge-readiness open edges

**Feature Branch**: `036-critical-merge-ready-edges`  
**Created**: 2026-10-17  
**Status**: Draft  
**Delivery Level**: Standard
**Rationale Rule**: 1
**Input**: User description: "Close the open edges GAP-022 leaves after features 024 and 025: a pending Merge Readiness claim left in place, the plan amendment needed to gain the line, and a plan that declares nothing still getting the 024 heuristic"

## Background

GAP-022 asked that a Critical feature's branch not be red from its first commit. Feature 024 made the
independence-artifact check a `WARN` while the branch is provably mid-feature (read from phase tokens in
commit subjects). Feature 025 added an explicit owner declaration, `**Merge Readiness**: pending|ready`,
in `plan.md`, which overrides the heuristic. Feature 026 closed one of the edges 025 listed (a `pending`
added inside a merge is now graded by the amendment check). The GAP-022 row in `docs/roadmap.md` still
lists what is open. Re-read against the code on 2026-10-17, three edges remain real and one is stale:

| # | Edge | State |
|---|---|---|
| E1 | `pending` is a claim an owner can leave in place; with it set, the independence artifact is never demanded by this check and only gate 6 (the human review at merge) stands behind it | open |
| E2 | A plan written before 025 has no `**Merge Readiness**` line, and gaining it is a plan amendment that needs a recorded approver, so FitForge 002 benefits only if its owner adds it | open |
| E3 | A plan that declares nothing still gets the 024 heuristic, whose two limits (a final commit that names no phase; phases landing out of order or never named) are measured on FitForge 002 | open |
| E4 | A `pending` added inside a merge carries no approver check | **closed by feature 026**; the roadmap row still lists it and must be corrected |

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A forgotten `pending` stops being silent (Priority: P1)

An owner sets `**Merge Readiness**: pending` at the start of a Critical feature, finishes every phase,
and never flips it. Today `ritual-checks` stays on the deferral `WARN` for every later commit, including
the one that is merged.

**Why this priority**: E1 is the only edge where the check can be made to say green over a feature that is
evidently complete. It is the failure GAP-020 taught the kit to hunt: a check that cannot fail in the
direction that matters.

**Independent Test**: build a Critical branch fixture whose `tasks.md` has every task ticked, whose
`plan.md` declares `pending`, and which has no independence artifact; the run must not end on the
deferral `WARN` alone. Build the same fixture with one task unticked; the run must be unchanged.

**Acceptance Scenarios**:

1. **Given** a Critical branch whose `plan.md` declares `pending` and whose `tasks.md` has no unticked
   task, **When** the pack runs, **Then** the evidence check names the contradiction (the plan says not
   ready, the tasks say complete) and the verdict is the arm's own failure for the missing artifact,
   exactly as for `ready`.
2. **Given** the same branch with at least one unticked task, **When** the pack runs, **Then** the
   output is byte-identical to today's `pending` warning.
3. **Given** a `tasks.md` the check cannot read, or one with no task at all, **When** the pack runs,
   **Then** `pending` is honoured as today (the new rule only ever tightens on positive evidence).

---

### User Story 2 - An existing plan can adopt the declaration without a false ceremony (Priority: P2)

The owner of an in-flight Critical feature whose plan predates 025 wants the explicit declaration.

**Why this priority**: E2 is adoption friction, not a hole, so it ranks below E1. The decision it needs
(whether adding the line is an amendment at all) is constitutional, so this story is documentation and a
fixture unless the owner decides otherwise.

**Independent Test**: on a fixture whose plan has no marker, adding `**Merge Readiness**: pending` with an
approver record in the commit message passes; without it, fails, as today. The guidance names the exact
commit shape.

**Acceptance Scenarios**:

1. **Given** an approved Critical plan with no marker, **When** the owner adds `pending` with the approver
   record, **Then** the amendment check passes and the evidence check warns.
2. **Given** the same change without the record, **When** the pack runs, **Then** the amendment check
   fails naming the document, as today (no exemption is added by this feature).

---

### User Story 3 - A plan that declares nothing is told how to declare (Priority: P3)

A Critical branch with no marker is graded by the 024 heuristic. When that heuristic gives up
(`not treated as mid-feature - <reason>`) or warns, the output should name the declaration as the repair.

**Why this priority**: E3 cannot be fixed by a better heuristic (measured: it cannot see phases that are
never named). The honest fix is to point at the declaration, which already exists.

**Independent Test**: the existing 024 fixtures keep their verdicts; their message gains one sentence
naming `**Merge Readiness**` as the way to state the answer.

**Acceptance Scenarios**:

1. **Given** a Critical branch with no marker whose heuristic reports a reason, **When** the pack runs,
   **Then** the verdict and exit code are unchanged and the reason line ends with the declaration hint.

### Edge Cases

- `pending` with every task ticked but an artifact already committed: the artifact ends the pending state
  today and still does, so the new rule is not reached.
- Ticks inside a fenced block or an HTML comment: not counted, as the phase-heading read already does.
- A plan with two `**Merge Readiness**` lines or an unknown value: strict with the reason, unchanged.
- A new Critical feature at phase 1 with tasks not yet written: no task, so `pending` is honoured (US1-3).
- A completed `tasks.md` on a branch that is genuinely waiting on an external approval: the check cannot
  tell; the owner flips to `ready` and supplies the artifact, which is what the lane requires at merge.

## Level Rationale *(mandatory — answers the four Critical triggers, in writing)*

- **domain-invariants**: does not apply — the kit has no domain-invariants pack; this changes when a script reports a verdict.
- **irreversible-data**: does not apply — nothing is migrated, dropped or rewritten.
- **authn-authz-payment**: does not apply — no authentication, authorization or payment is touched.
- **auditable-evidence**: does not apply — the independence artifact stays mandatory at merge and the arm that grades it is not edited. The feature narrows when the deferral applies, so it can only demand the artifact earlier, never later. The reviewer should falsify this claim specifically: that "only earlier" holds for every input, including an unreadable `tasks.md`.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: When a Critical feature's committed plan declares `**Merge Readiness**: pending`, the
  committed `tasks.md` contains at least one task, and every task is ticked, the evidence check MUST NOT
  treat the branch as pending; it MUST grade as it does for `ready` and say, in one line, that the plan
  and the tasks disagree.
- **FR-002**: A task is a checkbox list item read as the existing phase-heading read reads text (comments
  removed, fenced blocks excluded). Unreadable `tasks.md`, zero tasks, or any unticked task MUST leave the
  `pending` verdict and its message byte-identical to today's.
- **FR-003**: FR-001 MUST apply to the declared-`pending` path only. The 024 heuristic path, the `ready`
  path, the artifact-committed path and the invalid-marker path MUST be unchanged except for FR-005.
- **FR-004**: No new exemption to the amendment-authority check is added. Adding `**Merge Readiness**` to
  an approved plan stays an amendment with a recorded approver. `docs/sdlc/critical-delivery.md` MUST say
  so, with the commit shape for an existing plan (E2).
- **FR-005**: Where the 024 path prints a `not treated as mid-feature` reason or the phase-token deferral
  warning on a plan with no marker, the message MUST end with a sentence naming `**Merge Readiness**` as the
  way to state the answer. Verdicts and exit codes MUST NOT change.
- **FR-006**: Every changed or added behaviour MUST have a failing and a passing fixture in
  `tests/enforcement/rules.json`, and the coverage sweep MUST stay green.
- **FR-007**: `docs/roadmap.md`'s GAP-022 row MUST be corrected: E4 is closed by feature 026, and this
  feature's status is recorded.
- **FR-008**: Flow-down: `adoption/updating.md` and the digests carry the one-paragraph note; digests are
  regenerated by `scripts/build-digests.ps1` only.

### Key Entities

- **Declared readiness**: the `**Merge Readiness**` line of a Critical `plan.md` (`pending`, `ready`,
  absent, or invalid), as feature 025 defined it.
- **Task completeness**: derived from `tasks.md` at HEAD: count of ticked and unticked checkbox tasks.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On a fixture with `pending` and all tasks ticked, the pack no longer ends on the deferral
  warning alone; with one task unticked its output is byte-identical to the pre-change output.
- **SC-002**: Every verdict the enforcement fixture suite produced before this feature is unchanged,
  except the new rule's own fixtures and the FR-005 message suffix.
- **SC-003**: Replayed against FitForge 002's real task file (measured, not assumed), the report states how
  many of its commits would have changed verdict under FR-001, as feature 025 did.
- **SC-004**: `pwsh -File scripts/ritual-checks.ps1` is green on the branch.

## Assumptions

- The kit's own `tasks.md` convention (`- [ ]` / `- [x]`) is what adopted projects use; a project that
  uses another convention reads as zero tasks and keeps today's behaviour, which is the safe direction.
- E1 is closed "for the evident case" only. A branch whose tasks are not all ticked can still hold a
  forgotten `pending`; the gate 6 human review remains the backstop and the guidance keeps calling the
  declaration a claim.
- Staleness by elapsed time was considered and not chosen: git dates are authored, not trusted, and a
  long Critical feature is legitimately pending for weeks.
- Reading task ticks is a proxy for "complete", the same class of proxy as feature 024's phase tokens, and
  is disclosed as such in the guidance.

## Decisions

Recorded 2026-10-17 on the owner's instruction to take the recommended option for each. These are
decisions of the owner, taken before approval of this spec; the spec is still a draft until approved.

- **D1, E1 strength**: all tasks ticked with `pending` still declared is the arm's own failure (FR-001),
  not a stronger `WARN`. A `WARN` would leave the branch green over a feature the tasks call finished,
  which is the failure this feature exists to remove. If ticks are batched at the end, the owner flips
  to `ready` and supplies the artifact, which the lane requires at merge anyway.
- **D2, E2 exemption**: none (FR-004). An exemption needs a constitution I amendment, and feature 026
  just closed the route by which a `pending` could be added unapproved.
- **D3, level**: Standard. The surface is `scripts/enforcement-pack.ps1` and guidance, as for 024 to 026.
