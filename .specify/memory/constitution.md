<!--
SYNC IMPACT REPORT
==================
Version change: 0.5.0 → 0.6.0 (kit template — not yet ratified by a project)
Bump rationale: MINOR — Micro delivery lane added (feature 009, micro-lane; roadmap
  GAP-013), amending Principles I and X. Principle I gains the Micro arm: for a feature
  declared Micro, an approved single-page mini-spec (spec.md authored from
  .specify/templates/micro-spec-template.md) satisfies specification-first alone — no
  plan.md or tasks.md while the feature remains Micro. Principle X gains the Micro lane
  clause: exactly one phase; every verification layer unchanged (user-held gate
  certification, machine scope check with Territory read from spec.md, fresh-context AI
  review, human review at merge); hard eligibility bounds — declared Territory of at most
  5 files (the feature's own specs/NNN-name/** excluded) and a phase total of at most
  400 changed lines, summed across every commit carrying the phase's token (a hard
  failure for Micro, where other lanes get a per-commit warning) —
  plus checklist-affirmed non-measurable bounds (no schema/migration, no new packages, no
  architecture change, no domain-invariant surface, no visual-reference UI); no
  **Gate Batching** declaration (one phase — nothing to batch); Critical features MUST
  NOT use the lane; absent declaration ⇒ Standard, so every existing feature is
  unaffected. Outgrowing any bound promotes the feature IN PLACE to Standard (full
  spec.md + plan.md + tasks.md in a commit before any further phase commit; one-way,
  all-or-nothing). X's CI-held certification clause widens from "Lite or Standard" to
  "Lite, Micro, or Standard", with the declaration read from the mini-spec on Micro
  (the lane has no plan.md); Batched gates stays Lite/Standard only. The machine half —
  scripts/scope-check.ps1 (spec.md territory source) and scripts/enforcement-pack.ps1
  (MicroLane bounds check, GateCertification source extension) — lands in this same
  feature's next phase on the same branch. Human adoption of this amendment: the owner's
  spec/plan approval (2026-09-09) plus the feature's gate-6 human review at merge.
  Mirrors synced in the same change: micro-spec-template.md (new), spec-template.md
  (Delivery Level values + pointer), definition-of-done.md (gates 1, 3, 4),
  gate-command.md (CI-held eligibility + declaration home), branch-strategy.md (level
  menu), critical-delivery.md (level table + exclusion), CLAUDE.md (structure note,
  strict rule, reading-table row).

Prior version history (0.4.1 → 0.5.0):
Bump rationale: MINOR — CI-held certification clause added to Principle X (feature 008,
  ci-held-gate; roadmap GAP-012). For Lite and Standard features only, the approved plan
  MAY declare `**Gate Certification**: ci-held`, under which gate certification is the
  owner's recorded approval on the evidence triplet — the CI run's URL, its green
  conclusion, and the exact phase-commit sha it ran on (for a declared batch: the
  batch-end commit) — instead of a locally-run gate. The agent's obligations are
  unchanged: it never claims success; under ci-held it reports the evidence and requests
  the owner's approval on it. Critical features MUST NOT declare or use CI-held
  certification (docs/sdlc/critical-delivery.md); scripts/enforcement-pack.ps1 fails a
  Critical plan declaring it (the amendment's machine half, landing in this same
  feature's next phase on the same branch). The default absent any declaration remains
  the per-phase user-run gate, so every existing plan stays compliant unchanged.
  Human adoption of this amendment: the owner's explicit phase approval (2026-09-08)
  plus the feature's gate-6 human review at merge. Mirrors synced in the same change:
  plan-template.md (Gate Certification field + Constitution Check X), definition-of-done.md
  (gate 3), gate-command.md (CI-held certification section), critical-delivery.md
  (exclusion), CLAUDE.md (strict rule).

Prior version history (0.4.0 → 0.4.1):
Bump rationale: PATCH — sync-list bookkeeping only, no rule change (003 phase 4 AI
  review, finding F3): scripts/enforcement-pack.ps1 added to the "Templates requiring
  updates" list below, because it encodes constitutional constants (the batch-phase cap
  from Principle X's Batched-gates clause, the Critical cooling-off hours) that MUST
  change in lockstep with any amendment touching them.

Prior version history (0.3.0 → 0.4.0):
Bump rationale: MINOR — batched-gates clause added to Principle X (feature 003, flow-efficiency
  pack). For Lite and Standard features only, a run of at most 3 consecutive phases MAY be
  declared in the approved plan (before the batch starts, as `**Gate Batching**: phases N-M`)
  to share one certifying user-run gate at batch end; each phase still requires its own commit,
  scope check, and AI review, and the agent still runs the gate per phase for feedback.
  Critical features are excluded — their per-phase user-run gate obligation is unchanged
  (docs/sdlc/critical-delivery.md), and scripts/enforcement-pack.ps1 fails a Critical feature
  that declares a batch. The default (no declaration) remains the per-phase user-run gate, so
  existing plans stay compliant unchanged. Mirrors synced in the same change:
  plan-template.md (Constitution Check X + Gate Batching field), definition-of-done.md
  (gate 3), gate-command.md (Batched gates section), critical-delivery.md (prohibition).

Prior version history (0.2.0 → 0.3.0):
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
  - scripts/enforcement-pack.ps1 (encodes constitutional constants — batch-phase cap,
    Critical cooling-off hours, the Gate Certification legal values `user-run`/`ci-held`
    and the Critical ci-held exclusion, the Micro-lane bounds (territory-file cap 5,
    phase-line hard bound 400, single-phase rule) and the Delivery Level legal values —
    these MUST change in lockstep with amendments touching them)

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

**Micro arm**: a feature declared **Micro** (Principle X, Micro lane) satisfies this
principle with an approved **single-page mini-spec** — its `spec.md`, authored from
`.specify/templates/micro-spec-template.md` — alone: steps (2) and (3) are skipped, and no
`plan.md` or `tasks.md` exists while the feature remains Micro. Every other step is
unchanged. Absent a Micro declaration, the full workflow above applies.

**Rationale**: Documented intent prevents rework, makes review meaningful, and ties every code
change to an approved requirement. The Micro arm keeps all of that — intent is still written
and approved before implementation — while dropping only the planning ceremony that adds
nothing to a change small enough to fit the lane's machine-policed bounds.

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

**Batched gates**: for a Lite or Standard feature, the approved plan MAY declare — before the
batch's first phase is implemented, as `**Gate Batching**: phases N-M` in `plan.md` — that a
run of at most **3 consecutive phases** shares one certifying user-run gate at the end of the
batch. Within a batch, every phase still requires its own commit, its own scope check, and its
own AI review, and the agent still runs the gate per phase for feedback; only the user-run
certification moves to batch end. Critical features MUST NOT declare batches — their per-phase
user-run gate obligation is unchanged. Absent a declaration, the per-phase user-run gate above
applies in full.

**CI-held certification**: for a Lite, Micro, or Standard feature, the approved plan MAY
declare — as `**Gate Certification**: ci-held` in `plan.md` (for a Micro feature: in its
approved mini-spec `spec.md`, the lane's only specification document), before the first
phase it governs — that
gate certification is satisfied by the owner's **recorded approval on the evidence triplet**:
the CI run of the project gate on the **exact phase commit** (for a declared batch, the
batch-end commit), cited by run URL, green conclusion, and commit sha, recorded in the
feature's phase record. The approval is per phase (or per declared batch), never blanket;
a run on any other commit certifies nothing; the agent's obligations are unchanged — it
MUST NOT claim success, and under this mode it reports the evidence and requests the
owner's approval on it. The user-run gate remains lawful always. Critical features MUST NOT
declare or use CI-held certification. Absent a declaration, the value is `user-run` — the
gate law above applies in full.

**Micro lane**: a numbered feature MAY be declared **Micro** — `**Delivery Level**: Micro`
in its `spec.md` — when it fits the lane's bounds. A Micro feature has **exactly one
phase**; its specification is the approved single-page mini-spec (Principle I, Micro arm),
which carries the feature-global **Territory** block and, optionally, a
`**Gate Certification**` declaration; it MUST NOT declare `**Gate Batching**` (one phase —
nothing to batch). The measurable bounds are hard: the declared Territory covers at most
**5 files** (the feature's own `specs/NNN-name/**` excluded), and the phase changes at
most **400 lines in total** — counted across every commit carrying its `phase N` token,
so remediation commits cannot split the bound — a failure for Micro where other lanes
get a per-commit warning. The
non-measurable bounds — no schema or migration, no new packages, no architecture change,
no domain-invariant surface, no visual-reference UI — are affirmed in the mini-spec's
eligibility checklist and verified in human review. Every verification layer is unchanged:
user-held gate certification, the machine scope check (Territory read from `spec.md`),
fresh-context AI review, and human review at merge. Critical features MUST NOT use the
Micro lane. Absent a `**Delivery Level**` declaration, a numbered feature is Standard.
When work outgrows any bound, the feature is **promoted in place to Standard**: `spec.md`
is expanded to the full template (level re-declared Standard) and `plan.md` + `tasks.md`
are added (Territory moves under the phase headings), in a commit made **before** any
further phase commit; promotion is one-way and all-or-nothing.
`scripts/enforcement-pack.ps1` fails a Micro branch that violates any of these bounds.

**Rationale**: Small, gated increments keep changes reviewable, reversible, and low-risk; the
user-held exit code keeps the trust boundary human. Batching trades gate frequency — never
per-phase revertibility or review — for fewer owner interruptions on low-risk work, and only
when declared in an approved plan. CI-held certification moves the owner's approval input
from "I ran it" to "I read unforgeable evidence" — the agent cannot mint a green run on a
host it does not control — without ever removing the human approval itself; the trust
boundary stays human, asynchronously. The Micro lane trades specification ceremony — never
verification — for speed on provably small work: every measurable bound is machine-policed,
and outgrowing a bound forces promotion to Standard rather than quiet stretching.

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

**Version**: 0.6.0 | **Ratified**: TODO(RATIFICATION_DATE) | **Last Amended**: TODO(RATIFICATION_DATE)
