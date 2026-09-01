<!--
SYNC IMPACT REPORT
==================
Version change: 0.2.0 → 0.3.0 (kit template — not yet ratified by a project)
Bump rationale: MINOR — delivery-core amendment (feature 001, `review/out/DECISION.md`) fixing
  every verified internal contradiction in the delivery core, in three phases on one branch,
  recorded here as one amendment covering all three:
  1. Unit-of-review split: Definition of Done gate 6 (human review) now applies once per
     feature at merge, not per phase commit; gates 1-5 remain per-phase. Aligned
     docs/sdlc/definition-of-done.md with branch-strategy.md and review-process.md, which
     already assumed feature-level review. tasks-template.md no longer instructs agents that
     tests are optional (contradicted Principle XI, now VIII); this file's own mirror list
     (below) now names tasks-template.md so this class of drift is caught on the next
     amendment. spec-template.md gained a required Delivery Level header field. The
     source-of-truth ladder is now canonical in Principle II only; CLAUDE.md and
     plan-template.md point here instead of restating it.
  2. Added a phase-sizing rule (plan-template.md, Controlled Delivery check): a phase MUST be
     independently revertible and one testable slice, checked at plan approval. Defined the
     Critical-solo review substitute (docs/sdlc/critical-delivery.md item 5) concretely: a
     named artifact (second-model-review.md), a minimum 24-hour cooling-off period, and an
     explicit sentence that it is a mitigation, not true independence.
  3. Demoted Principle V (Data Standards) and VI (Auditability) — schema conventions, not
     constitutional law — to docs/rulebooks/database-rules-template.md. Deleted Principle X
     (Performance Responsibility) outright — unfalsifiable guidance with no checkable claim.
     Renumbered the remaining principles contiguously: VII->V (Domain Invariants), VIII->VI
     (Security), IX->VII (External Integration Governance), XI->VIII (Testing Requirements),
     XII->IX (Human Review Requirement), XIII->X (Controlled Delivery); I-IV unchanged. Every
     cross-reference to a renumbered or deleted principle was swept and updated.

Prior version history:
  (template / unversioned) → 0.1.0: Initial extraction of the portable constitution from a
  production deployment of this framework (17 principles, 68 shipped features). Domain-specific
  principles were moved to an optional domain module; parameterizable principles
  received {{SLOT}} placeholders. A project ratifies this as ITS constitution v1.0.0
  after filling every slot and resolving every TODO.
  0.1.0 → 0.2.0: Principle IV (Architecture Consistency) gained a bootstrap clause for
  greenfield projects (`adoption/greenfield.md` step 4).

Principles defined (10):
  I.    Specification First
  II.   Source of Truth Hierarchy
  III.  Repository Separation            (optional — remove for single-repo projects)
  IV.   Architecture Consistency
  V.    Domain Invariants                (slot — see modules/)
  VI.   Security
  VII.  External Integration Governance
  VIII. Testing Requirements
  IX.   Human Review Requirement
  X.    Controlled Delivery

Retired: former V (Data Standards) and VI (Auditability) — demoted to conventions in
  docs/rulebooks/database-rules-template.md, 0.3.0. Former X (Performance Responsibility) —
  deleted outright, 0.3.0, no replacement (unfalsifiable; see review/out/DECISION.md finding
  #15).

Templates requiring updates when this file changes:
  - .specify/templates/plan-template.md (Constitution Check gate must mirror the principles 1:1)
  - .specify/templates/tasks-template.md (test-policy language must not contradict Principle VIII)
  - CLAUDE.md (strict rules must not contradict this file)

Follow-up TODOs (resolve before ratification):
  - TODO(PROJECT_NAME): replace every {{PROJECT_NAME}} occurrence
  - TODO(RATIFICATION_DATE): set on first adoption
  - TODO(SLOTS): fill every {{...}} slot; delete principles marked optional if unused
-->

# {{PROJECT_NAME}} Constitution

## Core Principles

### I. Specification First

All work MUST begin with specification and planning before implementation. The required
workflow is: (1) create or update `spec.md`; (2) create or update `plan.md`; (3) create or
update `tasks.md`; (4) implement one approved phase only; (5) run the project gate; (6) review
changes; (7) commit the approved phase. Implementation MUST NOT start before requirements are
documented.

**Rationale**: Documented intent prevents rework, makes review meaningful, and ties every code
change to an approved requirement.

### II. Source of Truth Hierarchy

The following order of precedence MUST always be respected:

1. Feature visual references (screenshots / prototype captures) — *include this rung only if
   the project has an authoritative visual reference; otherwise delete it*
2. {{UI_GUIDELINES_PATH}} — *project-wide UI guidelines, if any*
3. `spec.md`
4. `plan.md`
5. API contracts
6. Data model
7. `tasks.md`
8. Research documents
9. Notes

If a higher rung and a lower rung conflict, implementation MUST stop and the conflict MUST be
reported. Lower-fidelity artifacts MUST NOT silently override higher-fidelity intent. When
visual references exist, new UI layouts MUST NOT be invented.

**Rationale**: A single, ordered source of truth removes ambiguity and prevents lower-fidelity
artifacts from silently overriding higher-fidelity intent.

### III. Repository Separation

<!-- OPTIONAL: delete this principle (and renumber) for single-repository projects. -->

{{PROJECT_NAME}} uses separate repositories. The backend repository is `{{BACKEND_REPO}}`. The
frontend repository is `{{FRONTEND_REPO}}`. Backend and frontend code MUST NOT be mixed in the
same repository unless explicitly approved in the technical plan.

**Rationale**: Separation keeps deployment, security boundaries, and ownership clean across
tiers.

### IV. Architecture Consistency

The existing architecture is the source of truth. New features MUST follow the existing
architecture. New architectural patterns, new frameworks, new UI libraries, and new persistence
approaches MUST NOT be introduced unless explicitly approved in the technical plan.

**Bootstrap clause**: at project creation there is no existing architecture to follow. During
the initial scaffold feature (the project's first numbered feature — see
`adoption/greenfield.md`, step 4), "the existing architecture" means the architecture selected
and approved in that feature's `plan.md`, which MUST record the decision ADR-style: options
considered, the decision, and its consequences. Once the scaffold feature is merged, that
architecture becomes the existing architecture and this principle applies in full.

**Rationale**: Consistency lowers maintenance cost and keeps the system reviewable by the whole
team. Without the bootstrap clause, "follow the existing architecture" is undefined on an empty
repository — the clause anchors the rule to an approved plan instead of leaving the agent to
improvise one.

### V. Domain Invariants

The non-negotiable rules of this project's domain are defined in
`{{DOMAIN_INVARIANTS_PATH}}` <!-- e.g. docs/domain/invariants.md; see modules/finance/ in the
kit for a worked example from a financial system. --> and carry constitutional force. Agents
and reviewers MUST treat a domain-invariant violation exactly like a violation of this file.

**Rationale**: Every serious domain has rules that must survive any refactor (immutability of
postings, consent trails, order-state machines). Naming them once, with constitutional force,
stops an agent from "creatively" violating them.

### VI. Security

Authentication is required for protected functionality. Authorization is required for protected
operations. Secrets MUST NEVER be stored in source code. Sensitive information MUST NOT be
logged. All external integrations MUST use secure authentication mechanisms.

**Rationale**: Security controls are non-negotiable architecture concerns, not cleanup tasks.

### VII. External Integration Governance

All external integrations require documented contracts. Each contract MUST define purpose,
authentication, endpoints, request schema, response schema, error schema, timeout policy, retry
policy, idempotency strategy, and audit requirements. Undocumented integrations are prohibited.

**Rationale**: Documented contracts make integrations testable, recoverable, and safe to change.

### VIII. Testing Requirements

Business-critical functionality requires automated tests. Business-critical calculations require
deterministic validation (golden fixtures where outputs must be exact). Changes affecting
business-critical logic require regression coverage.

**Rationale**: Deterministic, regression-covered tests are the only credible guarantee that
critical logic remains correct across changes — especially changes made by an AI agent.

### IX. Human Review Requirement

AI review alone is insufficient. Human review is required before merge. Human reviewers MUST
verify business requirements, domain correctness, security implications, visual-reference
compliance (where visual references exist), and architectural compliance.

**Rationale**: Business and architectural correctness require human accountability that
automated review cannot replace.

### X. Controlled Delivery

Work MUST be delivered incrementally. Only one approved phase MAY be implemented at a time.
Unrelated changes MUST NOT be included in the same feature implementation. Every completed phase
MUST pass project gates — run by the user, with the exit code confirmed by the user — before
proceeding. An AI agent MUST NOT claim success without that confirmation.

**Rationale**: Small, gated increments keep changes reviewable, reversible, and low-risk; the
user-held exit code keeps the trust boundary human.

## Governance

This constitution supersedes all other development practices. When any rule, document, or
generated artifact conflicts with this constitution, the constitution prevails. This file is the
project's ONLY constitution — do not create a second copy elsewhere in the repository; other
documents may point here.

**Amendment procedure**: Amendments MUST be proposed as a documented change to this file,
including rationale and impact on dependent templates (`plan-template.md`, `spec-template.md`,
`tasks-template.md`) and runtime guidance (`CLAUDE.md`, `docs/`). An amendment is adopted only
after human approval. Update the SYNC IMPACT REPORT header with every amendment.

**Versioning policy**: This constitution is versioned using semantic versioning.
MAJOR — backward-incompatible governance or principle removals or redefinitions.
MINOR — a new principle or section is added, or guidance is materially expanded.
PATCH — clarifications, wording, and non-semantic refinements.

**Compliance review**: All specs, plans, tasks, pull requests, and reviews MUST verify
compliance with these principles. The Constitution Check gate in `plan-template.md` MUST be
evaluated before Phase 0 research and re-evaluated after Phase 1 design. Any violation MUST be
justified in the plan's Complexity Tracking section or the work MUST stop and be reported. Use
`CLAUDE.md` and the `docs/` guidance files for runtime development guidance.

**Version**: 0.3.0 | **Ratified**: TODO(RATIFICATION_DATE) | **Last Amended**: TODO(RATIFICATION_DATE)
