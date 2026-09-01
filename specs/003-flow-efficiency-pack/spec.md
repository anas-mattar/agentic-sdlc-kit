# Feature Specification: Flow-Efficiency Pack

**Feature Branch**: `003-flow-efficiency-pack`
**Created**: 2026-09-01
**Status**: Draft
**Delivery Level**: Standard
**Input**: User description: "Flow-efficiency pack: make the kit's workflow faster, clearer, and better at parallel work. (a) One canonical flow quickstart page with a single diagram assembling the full ritual (branch → spec → plan → tasks → phase loop → gate → review → merge) that today is spread across CLAUDE.md, definition-of-done.md, review-process.md, and team-workflow.md. (b) Automation scripts for the manual multi-developer rituals: a claim-feature script (fetch, next free NNN from local+remote ledger, create branch, push immediately) and a territory-check script (diff --stat the current branch's planned files against every open remote NNN-* branch). (c) A pipelining rule relaxing the one-active-feature-per-developer WIP limit: a developer may start a second feature while the first is gate-green and awaiting human review — safely defined, not deleting the limit. (d) A batched-gate option for Lite/Standard features letting consecutive small phases share one user-run gate, without weakening Critical."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See the whole ritual on one page (Priority: P1)

A developer new to an adopted project (or an existing developer who keeps forgetting a
step) opens one canonical flow page and sees the complete delivery ritual — pick/claim a
feature, spec → plan → tasks, the phase loop (implement one phase → gate → diff check →
AI review → commit), feature-level human review, merge — as a single diagram plus a
one-line-per-step table, each step linking to the document that owns the detail. They no
longer have to assemble the picture from CLAUDE.md, `docs/sdlc/definition-of-done.md`,
`docs/sdlc/review-process.md`, and `docs/sdlc/team-workflow.md`.

**Why this priority**: "Clear flow" was the user's core complaint; every other
improvement in this feature is easier to adopt once the whole ritual is visible in one
place. It also carries zero risk — it changes no law.

**Independent Test**: Give the page (and nothing else) to someone unfamiliar with the
kit and ask them to narrate the life of a feature from claim to merge. They should name
every mandatory checkpoint (spec approval, per-phase gate, scope check, AI review,
feature-level human review) without opening another document.

**Acceptance Scenarios**:

1. **Given** a fresh reader with only the flow page, **When** they trace the diagram,
   **Then** every stage of the ritual and every mandatory checkpoint appears exactly
   once, in order, with a link to the owning document.
2. **Given** any rule stated on the flow page, **When** it is compared against the
   owning document, **Then** the owning document says the same thing (the page
   summarizes; it never introduces or alters law), and the page itself says which
   document prevails on conflict.

---

### User Story 2 - Claim a feature with one command (Priority: P2)

A developer picks a feature and claims it by running a single command. The command
syncs with the remote, computes the next free feature number from the combined
local-and-remote ledger (branches and spec directories), creates the correctly named
branch, and pushes it immediately so the claim is visible to every teammate. If someone
else won the race to that number, the command detects it and renumbers cleanly instead
of leaving a collision.

**Why this priority**: The claim protocol exists today only as a manual 3-step recipe in
two documents; under time pressure people skip steps and numbers collide. Automating it
makes the multi-developer ledger reliable and makes starting a feature faster for solo
developers too.

**Independent Test**: On a repository with existing local and remote feature branches,
run the command twice from two clones "simultaneously" — both end up with distinct,
correctly numbered, remotely visible branches without manual repair.

**Acceptance Scenarios**:

1. **Given** a repo where the highest feature number appears only on the remote (not
   locally), **When** a developer claims a new feature, **Then** the allocated number is
   the next free one across both ledgers, and the branch exists on the remote when the
   command finishes.
2. **Given** the number was taken on the remote between allocation and push, **When**
   the push is rejected or the race is otherwise detected, **Then** the command reports
   the loss and renumbers (branch and spec directory) before any other work happens.
3. **Given** a single-developer repo with no remote, **When** the command runs, **Then**
   it allocates from the local ledger, skips the push, and says so — it never fails just
   because there is no team.

---

### User Story 3 - Check territory with one command (Priority: P2)

Before starting a phase, a developer (or their agent) runs a single command that compares
what this feature touches against every open remote feature branch and reports any file
overlap, so merge-order agreements happen before the work, not at merge time.

**Why this priority**: The territory check is mandated today (team-workflow rule 5) but
is pure manual git archaeology — fetch, list branches, run a diff per branch, eyeball the
results — so it is the most-skipped step in the ritual. One command makes the mandated
check actually happen.

**Independent Test**: With two open feature branches that both touch the same file, run
the command on either branch — the shared file and the other branch's name appear in the
report; with disjoint branches the report is clean.

**Acceptance Scenarios**:

1. **Given** another open remote feature branch whose changes overlap this branch's
   touched files, **When** the check runs, **Then** it names the overlapping files and
   the conflicting branch and reminds the owners to agree and record a merge order.
2. **Given** no overlap with any open feature branch, **When** the check runs, **Then**
   it reports clean and exits successfully.
3. **Given** overlap was found, **When** the command exits, **Then** its exit status is
   distinguishable from the clean case, so the check can be wired into an agent's
   pre-phase routine — while the docs still say overlap is *sequenced, not forbidden*.

---

### User Story 4 - Keep working while a feature awaits review (Priority: P3)

A developer whose feature has passed its final phase gate and is waiting on cross-review
starts their next feature instead of idling, under an explicit pipelining rule: the
second feature may begin only when the first is fully done from the owner's side
(all phases gate-green, branch pushed, review formally requested), and the in-flight cap
is still enforced — the WIP limit is relaxed for the review-wait state, not deleted.

**Why this priority**: Review-wait is the longest human-latency window in the flow and
today the WIP rule ("one active feature per developer") forces the developer to idle
through it. This is the biggest per-developer throughput win — but it changes law, so it
lands after the risk-free items.

**Independent Test**: Walk the amended rule against three situations — feature awaiting
review (may start next), feature mid-phase (may not), review returns change requests
while the second feature is mid-phase (rule says which feature gets priority and what
happens to the other) — and get an unambiguous answer for each.

**Acceptance Scenarios**:

1. **Given** a developer's feature has every phase committed gate-green, is pushed, and
   has review formally requested, **When** they claim a second feature, **Then** the
   rule permits it and the claim is not "number squatting".
2. **Given** the reviewer requests changes on the first feature, **When** the developer
   is mid-phase on the second, **Then** the rule states the resolution order explicitly
   (which feature they return to, and at what boundary) — no judgment call needed.
3. **Given** a developer already has one feature awaiting review and one active,
   **When** they attempt to claim a third, **Then** the rule forbids it.

---

### User Story 5 - Batch small phases behind one gate (Priority: P3)

For a Lite or Standard feature whose plan declares a run of small consecutive phases, the
owner may pre-approve gating them as one batch: the agent still implements one phase at a
time (with agent-run gates for feedback and a per-phase commit and AI review), but the
owner runs the certifying gate once at the end of the batch instead of after every phase.
Critical features are untouched — every phase keeps its own user-run gate and agent-run
gates remain prohibited there.

**Why this priority**: The per-phase user gate is the flow's biggest serializer (a
3-phase feature = 3 synchronous human checkpoints before review). Batching cuts human
interruptions for low-risk work — but it loosens the strongest rule in the kit, so it is
last, opt-in, and bounded.

**Independent Test**: For a 3-phase Standard feature with a declared batch, count the
mandatory owner interruptions: one certifying gate at batch end plus one human review —
while the per-phase commits, scope checks, and AI reviews all still exist; for a
Critical feature, confirm the addendum still requires a user-run gate per phase.

**Acceptance Scenarios**:

1. **Given** a Standard feature whose plan declares phases 2–3 as a batch, **When** the
   batch completes, **Then** one user-run gate certifies the batch, and each phase still
   has its own commit, `git diff --stat` scope check, and AI review.
2. **Given** the batch-end user gate fails, **When** the failure is localized, **Then**
   the per-phase commits allow reverting only the offending phase (the batch never
   compromises per-phase revertibility).
3. **Given** a Critical feature, **When** its plan attempts to declare a batch, **Then**
   the rule (and the enforcement pack) rejects it.

---

### Edge Cases

- Claim command in a repo with no remote configured, or offline: allocate locally, skip
  the push, warn that the claim is not team-visible.
- Claim command finds working tree dirty or current branch is not `main`: stop before
  creating anything (mirrors the kit's existing "stop if unrelated uncommitted changes
  exist" rule).
- Territory check when the other branch has no `plan.md` yet (just claimed): fall back to
  comparing actual committed diffs; report "claimed, no plan yet" rather than crashing.
- Territory check against a stale claim (no commits for the reclaim window): flag it as
  reclaimable per team-workflow rule 3 instead of treating it as a live conflict.
- Pipelining: the second feature's territory overlaps the first (awaiting-review) feature
  — the rule must forbid or sequence this explicitly, since the first may come back with
  change requests touching the same files.
- Batched gate: an agent-run gate fails mid-batch — the batch pauses at that phase
  boundary; the owner is asked to gate what is committed so far, not to push on.
- Flow page drifting from the law after a later governance change: the page must be
  covered by the same machine check that catches broken paths today, and must carry the
  conflict rule ("detail documents prevail").

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The kit MUST provide one canonical flow page presenting the complete
  delivery ritual — claim → spec → plan → tasks → phase loop (implement → gate → scope
  check → AI review → commit) → feature-level human review → merge — as a single diagram
  plus a step table, with each step linking to the document that owns its detail.
- **FR-002**: The flow page MUST NOT introduce or alter any rule; it MUST state that on
  any conflict the owning documents prevail, and it MUST be referenced from the kit's
  always-loaded anchor (CLAUDE.md) so new sessions find it.
- **FR-003**: The kit MUST provide a one-command claim ritual that: syncs with the
  remote, allocates the next feature number free across local and remote branches and
  spec directories, creates the branch and spec directory in the canonical layout, and
  pushes the claim immediately.
- **FR-004**: The claim command MUST detect a lost allocation race (number taken on the
  remote first) and renumber the branch and spec directory before any other work, and
  MUST degrade gracefully (local allocation, explicit warning) when no remote exists.
- **FR-005**: The kit MUST provide a one-command territory check that compares the
  current feature's touched files against every open remote feature branch and reports
  overlapping files per conflicting branch, with a machine-readable distinction between
  "clean" and "overlap found".
- **FR-006**: The territory check MUST present overlap as *sequenced, not forbidden* —
  its report reminds owners to agree and record merge order in both features' plans,
  matching existing team-workflow rule 5.
- **FR-007**: The team-workflow WIP rule MUST be amended with an explicit pipelining
  clause: a developer may claim a second feature only when their first has all phases
  committed gate-green, is pushed, and has human review formally requested; at most one
  feature awaiting review plus one active feature per developer; and the clause MUST
  state the resolution order when review returns change requests while the second
  feature is mid-phase: the developer finishes the current phase of the second feature
  to a clean gate-green commit, then returns to the first feature and addresses the
  change requests before starting any further phase — no half-done phase is ever left
  behind, and review turnaround waits at most one phase.
- **FR-008**: The kit MUST define an opt-in batched-gate option for Lite and Standard
  features: a run of consecutive small phases, declared in advance in the feature's
  plan, may share one certifying user-run gate at batch end, while each phase keeps its
  own commit, scope check, and AI review, and the agent still runs the gate per phase
  for feedback. A batch covers at most **3 consecutive phases**; longer features use
  multiple batches, each with its own certifying user-run gate.
- **FR-009**: The batched-gate option MUST NOT apply to Critical features: the
  critical-delivery addendum keeps a user-run gate per phase, and the enforcement pack
  MUST fail when a Critical feature's artifacts declare a batch.
- **FR-010**: Every new or amended rule in this feature MUST follow the kit's
  encode-gaps convention: stated in the owning document, surfaced in an always-loaded
  anchor (CLAUDE.md), and covered by a machine check where one exists (doc-lint for
  documents and paths; the enforcement pack for merge-blocking rules).
- **FR-011**: All amended documents (team-workflow, branch-strategy, gate-command,
  definition-of-done, CLAUDE.md) MUST stay mutually consistent — the same rule stated
  in two places must say the same thing, per the kit's conflict rule.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A reader given only the flow page can correctly narrate the full life of a
  feature, naming all five mandatory checkpoints, without opening any other document.
- **SC-002**: Claiming a feature takes one command and under one minute, and two
  developers claiming concurrently never end up sharing a number (any race is detected
  and auto-resolved).
- **SC-003**: Territory overlap between open features is surfaced before a phase starts,
  in one command, rather than discovered at merge time.
- **SC-004**: A developer whose feature is awaiting review can start their next feature
  the same day without violating any rule, and the rules answer every
  change-request-arrives scenario without a judgment call.
- **SC-005**: For a 3-phase Standard feature using a declared batch, mandatory owner
  interruptions drop from 4 (three gates + one review) to 2 (one batch gate + one
  review), with per-phase revertibility preserved.
- **SC-006**: Critical features are provably unaffected: their per-phase user-run gate
  obligations are unchanged and a declared batch on a Critical feature is rejected by
  the merge-blocking check.

## Assumptions

- The flow page is a summary artifact, not new law: the constitution and the
  `docs/sdlc/` documents remain the only authorities, and the page carries an explicit
  conflict-precedence note.
- The claim and territory commands live alongside the kit's existing scripts and follow
  the same conventions (fail loudly, non-zero exit on violation, runnable on the kit's
  supported shells); they automate the rituals already written in branch-strategy and
  team-workflow rather than defining new ones.
- The pipelining cap defaults to exactly two features in flight per developer (one
  awaiting review + one active); a third claim is number squatting under the existing
  rule.
- Pipelining requires the second feature's territory to be disjoint from the
  awaiting-review feature, or explicitly sequenced behind it, since change requests may
  reopen the first feature's files.
- Batched gates are opt-in per feature, declared in the plan before the batch starts —
  never applied retroactively to phases already implemented.
- Single-developer projects benefit passively (faster claim, flow page) and may ignore
  the pipelining and territory rules, consistent with team-workflow's "single-developer
  projects can ignore this file" stance.
- This feature amends governance documents in the kit repository itself, where numbered
  features amending governance are the established pattern (001, 002); adopted projects
  receive the changes by re-copying the kit per the existing adoption process.
