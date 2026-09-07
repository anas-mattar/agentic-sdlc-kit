# Feature Specification: Verification Pack

**Feature Branch**: `006-verification-pack`
**Created**: 2026-09-07
**Status**: Draft
**Delivery Level**: Standard
**Input**: User description: "Verification pack — convert the ritual's socially-checked gates into
machine checks: machine scope check from tasks.md-declared phase file territory (GAP-008); AI
review separation via fresh-context reviewer (GAP-009); doc-lint and enforcement-pack as required
CI on feature branches (GAP-010)"

## Problem

Three of the ritual's checkpoints rest on human attention and agent obedience rather than
machinery (roadmap GAP-008, GAP-009, GAP-010):

1. **The scope check (Definition of Done gate 4) is eyeballed.** The owner reads
   `git diff --stat` against an intent held in their head. Nothing written declares which files
   a phase was *supposed* to touch, so a drive-by refactor passes whenever the owner is busy,
   tired, or complacent — precisely the moments the framework exists for.
2. **The AI review (gate 5) is self-graded.** The same agent, in the same conversation that
   wrote the code, fills the review checklist. It is marking its own homework; its blind spots
   in implementation are the same blind spots in review.
3. **The machine checks that do exist run only by discipline.** `doc-lint.ps1` and
   `enforcement-pack.ps1` are invoked when someone remembers to. A branch that never ran them
   looks identical to a branch that passed them.

The framework's stated failure philosophy (README: "drift between the rules and reality is what
kills rule-based frameworks") applies to its own gates: a gate that can be silently skipped
will eventually be silently skipped.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Machine scope check from declared phase territory (Priority: P1)

As a feature owner, when a phase is implemented, I want the phase's changed files compared
mechanically against a territory the approved `tasks.md` declared in advance, so that an
undeclared file fails the check loudly instead of relying on me to notice it in a diff listing.

**Why this priority**: Scope creep is the highest-frequency agent failure mode the kit targets,
and the current defense degrades exactly when the human does. A declared territory also makes
the owner's approval meaningful: they approve a written boundary at plan time, once, instead of
re-deriving it from memory at every phase gate.

**Independent Test**: On a feature branch whose `tasks.md` declares per-phase territory, commit
a phase touching one undeclared file and run the scope check — it must fail naming that file;
remove the file from the diff and it must pass. Deliverable is valuable alone even before the
CI story ships (the owner runs the script instead of eyeballing).

**Acceptance Scenarios**:

1. **Given** an approved `tasks.md` declaring Phase 2's territory, **When** the Phase 2 commit's
   diff contains only files matching that territory, **Then** the scope check passes and reports
   the matched declaration.
2. **Given** the same declaration, **When** the diff contains a file outside the territory,
   **Then** the check fails, names every undeclared file, and points to the remediation choices
   (revert the stray change, or amend `tasks.md` territory with owner approval before re-running).
3. **Given** a feature whose `tasks.md` predates this feature and declares no territory,
   **When** the scope check runs, **Then** it emits a non-blocking warning (not a failure) —
   the same backward-compatibility posture as the Gate Batching clause.
4. **Given** a `fix/`, `chore/`, or `docs/` branch (no `tasks.md` exists on the Lite lane),
   **When** the scope check runs, **Then** it reports "not applicable" and exits clean — the
   Lite lane's existing prohibited-category checks remain the defense there.

---

### User Story 2 - Reviewer separation for the AI review (Priority: P2)

As a feature owner, I want the AI code review (gate 5) produced by a reviewer that did not
write the code — a fresh-context agent session or a second model — with the reviewer's
provenance recorded in the review document, so the review catches what the implementer cannot
see about its own work.

**Why this priority**: Second only to scope creep; the review gate currently provides paper
assurance. It is P2 because the periodic second-model audits already provide a weaker version
of this defense, whereas nothing at all backstops the scope check today.

**Independent Test**: File an AI review whose provenance block declares the implementing
session as reviewer — the enforcement check must fail it; re-file from a fresh-context
reviewer with provenance recorded and it must pass.

**Acceptance Scenarios**:

1. **Given** a completed phase, **When** the AI review is produced, **Then** the review document
   records who reviewed (fresh-context agent or second model, with model/session identity),
   what it was given (the diff, the spec, the plan), and an explicit statement that the reviewer
   did not produce the diff.
2. **Given** a review document missing the provenance block, or one declaring the implementer
   as reviewer, **When** the ritual checks run on the branch, **Then** the branch fails with a
   message naming the review file and the rule.
3. **Given** pre-006 feature directories (001–005) with reviews in the old format, **When** the
   ritual checks run, **Then** old reviews are not retroactively failed — the rule applies to
   phases reviewed after adoption of this feature.

---

### User Story 3 - Ritual checks as CI on feature branches (Priority: P3)

As a kit maintainer (and as an adopter), I want doc-lint, the enforcement pack, the scope
check, and the review-provenance check to run automatically on every push to a feature branch,
so that compliance is a visible check on the branch instead of an act of discipline, and a
branch that skipped the ritual is mechanically distinguishable from one that passed it.

**Why this priority**: P3 because it is the delivery vehicle for the first two stories rather
than a new defense in itself — but it is the story that changes the framework's character: the
checks stop being optional. It also lays the foundation for the roadmap's CI-held certifying
gate (GAP-012), which is out of scope here.

**Independent Test**: Push a feature branch violating any single check (unresolved doc
reference, undeclared scope file, missing review provenance) — the branch's CI status must go
red naming the failing check; fix it and the status goes green — with no human having initiated
either run.

**Acceptance Scenarios**:

1. **Given** the kit repository with the workflow installed, **When** any `NNN-*`, `fix/`,
   `chore/`, or `docs/` branch is pushed, **Then** the ritual checks run automatically and
   report pass/fail per check on the branch.
2. **Given** an adopted project that received this feature through the kit-update channel,
   **When** the update is applied, **Then** the workflow arrives classified by the kit manifest
   and runs in that project's CI without hand-assembly.
3. **Given** a repository host without CI configured (or a topology where the adopted project's
   CI lives elsewhere), **When** the workflow cannot run, **Then** the checks remain runnable
   locally by one documented command, and the adoption docs state that wiring them as required
   checks is part of finishing adoption.

---

### Edge Cases

- **Deliberately shared files across phases** (e.g. a template synced in every phase): territory
  declarations are per-phase and may repeat a path — overlap is legal; the check compares one
  phase's diff to that phase's declaration only.
- **Renames and deletions**: a rename touches two paths; both must fall inside the territory.
  A deletion is a touch of the deleted path.
- **Territory amendments mid-feature**: legitimate scope discovery happens. The remediation path
  is an owner-approved `tasks.md` amendment committed *before* the phase commit that uses it —
  the check must therefore read the declaration as of the commit under test, so a stray file
  can never be legalized retroactively in the same commit.
- **Batched gates**: per-phase scope checks already survive batching (gate-command.md); the
  machine check preserves that — it runs per phase commit, batch or not.
- **The `docs/` lane inside the kit repo itself**: doc-lint applies, scope check reports
  not-applicable, enforcement-pack already handles the lane.
- **CI unavailable or offline work**: local runs remain first-class; CI is the enforcement
  layer, not the only execution path.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The tasks template MUST provide a per-phase territory declaration: an explicit
  list of paths and/or path patterns each phase is allowed to touch, authored at planning time
  and approved with the plan.
- **FR-002**: A scope-check script MUST compare a phase commit's changed files (relative to the
  feature's diff base) against that phase's declared territory and exit non-zero when any
  changed file is undeclared, naming every such file.
- **FR-003**: The scope check MUST treat an absent territory declaration as a non-blocking
  warning on `NNN-*` branches (backward compatibility) and as not-applicable on Lite-lane
  branches.
- **FR-004**: The scope check MUST read the territory declaration as of the commit under test,
  so a declaration cannot be widened in the same commit that exploits the widening.
- **FR-005**: The AI review template MUST carry a mandatory provenance block recording reviewer
  identity (fresh-context agent or second model), inputs supplied, and an explicit
  reviewer-is-not-implementer attestation.
- **FR-006**: The enforcement pack MUST fail an `NNN-*` branch whose committed AI review lacks
  the provenance block or attests the implementer as reviewer — applying only to reviews
  created after this feature's adoption (grandfather clause for 001–005 and adopted projects'
  existing reviews).
- **FR-007**: The kit MUST ship a CI workflow that runs doc-lint, the enforcement pack, the
  scope check, and the review-provenance check on every push to `NNN-*`, `fix/`, `chore/`, and
  `docs/` branches, reporting per-check results.
- **FR-008**: All checks MUST remain runnable locally by a single documented command producing
  the same verdicts as CI.
- **FR-009**: The new files MUST be classified in the kit manifest (verbatim vs surgical) so
  the update channel flows them to adopted projects, and the constitution's template-sync list
  MUST name any file that encodes constitutional constants (GAP-002 precedent).
- **FR-010**: Governance docs (definition-of-done, review-process, gate-command where affected,
  CLAUDE.md task-scoped reading table) MUST be amended to state that gates 4 and 5 are
  machine-checked, what the machine checks, and what remains the human's judgment (the owner
  still approves; the machine only makes skipping visible).

### Key Entities

- **Territory declaration**: per-phase list of allowed paths/patterns inside `tasks.md`;
  authored at planning, amendable only by owner-approved commit preceding its use.
- **Scope verdict**: pass / fail-with-named-strays / warning-undeclared / not-applicable, per
  phase commit.
- **Review provenance block**: structured section of the AI review recording reviewer identity,
  inputs, and the non-implementer attestation.
- **Ritual CI workflow**: the automated run binding doc-lint, enforcement pack, scope check,
  and provenance check to branch pushes.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A phase commit containing a file outside its declared territory is rejected by
  the machine 100% of the time, with the stray file named — demonstrated by seeded-violation
  tests for each check.
- **SC-002**: The owner's per-phase scope review reduces from reading a full diff listing to
  confirming one check verdict; the approval of file boundaries moves to plan time (once per
  feature instead of once per phase).
- **SC-003**: A self-graded AI review can no longer be filed undetected: 100% of reviews
  missing provenance or attesting the implementer as reviewer fail the branch.
- **SC-004**: Every push to a governed branch in the kit repository produces a ritual-check
  verdict with zero human initiation; a branch that never passed the checks is mechanically
  distinguishable from one that did.
- **SC-005**: Feature 007+ in this repository, and the next feature in each adopted project
  after flow-down, run under the new checks with zero false-positive blocks that require
  disabling a check (territory amendments are the sanctioned path and do not count).

## Assumptions

- GitHub Actions is the reference CI for the shipped workflow (this repository and both known
  adoptions host on GitHub); the checks themselves stay host-agnostic scripts so another CI can
  invoke the same single command (FR-008).
- Backward compatibility follows the Gate Batching precedent: absent declarations warn rather
  than fail; existing specs and reviews are grandfathered (FR-003, FR-006).
- The scope check governs phase commits on `NNN-*` branches only; Lite-lane defense remains the
  enforcement pack's prohibited-category and abuse-guard checks.
- Making the CI checks *required* (branch protection) is repository configuration, documented
  but not enforceable by the kit itself — the kit ships the workflow and the instruction
  (`docs/sdlc/branch-protection.md` precedent).
- The CI-held **certifying** gate (owner approves on CI evidence instead of running the gate
  locally — GAP-012) is explicitly out of scope; this feature does not change who certifies
  anything. Constitution's user-held-gate principle is untouched.
- Reviewer separation prescribes *fresh context* as the minimum (second model encouraged, not
  required), so the rule is satisfiable with a single model subscription.
