# Feature Specification: CI-Held Certifying Gate

**Feature Branch**: `008-ci-held-gate`
**Created**: 2026-09-08
**Status**: Draft
**Delivery Level**: Standard
**Input**: User description: "CI-held certifying gate for Lite/Standard: DoD gate 3
certification may be satisfied by a green CI run of the project gate on the exact phase
commit, owner approving asynchronously on evidence; user-run gate stays law for Critical
(GAP-012)"

## Problem

The owner is the framework's synchronous bottleneck (roadmap GAP-012, from the 2026-09-07
self-assessment). Every Standard phase — or batch of three — blocks until the owner sits
down, runs the gate locally, and reports the exit code. The gate ritual's *purpose* is that
the agent can never fabricate the result; the *mechanism* (a human typing the command
synchronously) is stronger than the purpose requires:

- A CI run of the same gate command on the exact phase commit is **equally unforgeable** —
  the agent cannot mint a green run on a host it does not control, and the run is pinned to
  a commit sha the scope check already attributes.
- The verification pack (006) already moved the ritual checks to CI on this exact argument;
  007 put the adoption doctor beside them. The *project gate* (build/test) is the one
  certification still requiring a synchronous human keystroke on Lite/Standard work.
- The cost is real: throughput is capped by owner availability, and the batching clause
  (constitution X) exists purely to ration that scarce resource — rationing that becomes
  unnecessary when certification is asynchronous.

What must NOT change: the **owner still approves every phase** — this feature moves the
approval's *input* from "I ran it" to "I read the unforgeable evidence"; it never removes
the human from the loop. And **Critical is untouched**: per-phase user-run gates, no agent
runs at all, no batching — and no CI-held certification.

This is the kit's first change to constitutional text since 0.4.1: constitution X defines
who certifies, so the feature includes a constitutional amendment (MINOR) under the
documented amendment procedure — adopted projects re-express it per `adoption/updating.md`.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Certify a phase on CI evidence (Priority: P1)

As the owner of a Lite/Standard feature, when a phase commit's project gate has run green
in CI, I want to certify DoD gate 3 by approving on that evidence — the run link, its exit
status, and the exact commit it ran on — instead of running the gate locally, so phases
stop queuing on my keyboard while losing none of the no-self-certification property.

**Why this priority**: This is the feature — the law change and the evidence definition.
Everything else delivers or polices it.

**Independent Test**: On a Lite/Standard feature whose plan declares CI-held certification,
a phase is certified by the owner citing the CI evidence triplet (run URL, green
conclusion, phase-commit sha) in the phase record; the DoD, constitution, and gate-command
all agree this satisfies gate 3. A Critical feature attempting the same is refused by both
law and machine.

**Acceptance Scenarios**:

1. **Given** a Standard feature whose approved `plan.md` declares CI-held certification,
   **When** the project gate's CI run on the phase commit concludes green and the owner
   records their approval citing the evidence triplet, **Then** DoD gate 3 is satisfied
   for that phase — no local run required.
2. **Given** the same declaration, **When** the CI run is red or ran on a different commit
   than the phase commit, **Then** the evidence does not certify — the phase is remediated
   and re-run, exactly as a failed local gate would be.
3. **Given** a Critical feature, **When** its plan declares CI-held certification, **Then**
   the enforcement pack fails the branch — Critical keeps per-phase user-run gates with no
   agent runs and no CI substitution (unchanged law).
4. **Given** a feature with no declaration, **When** phases are delivered, **Then** the
   default is today's user-run gate — existing plans stay compliant unchanged (the Gate
   Batching precedent).
5. **Given** a declared batch (phases N–M) on a CI-held feature, **When** the batch ends,
   **Then** one owner approval on the batch-end commit's evidence certifies the batch —
   batching and CI-held certification compose; each phase still keeps its own commit,
   scope check, and AI review.

---

### User Story 2 - The project gate runs in CI (Priority: P2)

As an adopter whose gate is a build/test chain (the `{{GATE}}` slots), I want a kit-shipped
recipe that runs my project gate in CI on every governed-branch push — separate from the
ritual checks, since it runs *my stack's* toolchain — so the evidence US1 needs exists
without my building CI from scratch.

**Why this priority**: US1's evidence has to come from somewhere. P2 because projects with
existing CI gates (the kit's own repo: ritual-checks IS its gate) can use US1 immediately.

**Independent Test**: Instantiating the recipe in an adopted fixture yields a workflow that
runs the project's exact gate chain on push, whose runs carry the commit sha and
conclusion — the evidence triplet is readable off the run page.

**Acceptance Scenarios**:

1. **Given** the kit-shipped project-gate workflow template with the gate slot filled,
   **When** a governed branch is pushed, **Then** the project gate runs on that commit and
   the run records command, conclusion, and sha.
2. **Given** a project whose gate cannot run in CI (secrets, licensed toolchains, local
   hardware), **When** the owner cannot wire the workflow, **Then** nothing regresses:
   the user-run gate remains fully lawful — CI-held certification is an option, never a
   mandate.
3. **Given** the kit repository itself, **When** feature 009+ declares CI-held
   certification, **Then** the existing `ritual-checks` run is its project-gate evidence
   (the kit's gate is the ritual checks — no second workflow needed).

---

### User Story 3 - The declaration is machine-checked (Priority: P3)

As the kit maintainer, I want the certification mode declared in the approved `plan.md`
(like Gate Batching) and machine-checked by the enforcement pack, so a Critical feature
can never quietly adopt CI-held certification and an invalid declaration is caught before
any phase relies on it.

**Why this priority**: The policing layer over US1's law — same relationship Gate
Batching's check has to its clause.

**Independent Test**: Seeded plans exercise the check: valid `user-run`/`ci-held`
declarations pass on Standard; `ci-held` on Critical fails naming the rule; a malformed
value fails; an absent line means `user-run` (backward compatible).

**Acceptance Scenarios**:

1. **Given** a Standard plan declaring `ci-held`, **When** the enforcement pack runs,
   **Then** it passes.
2. **Given** a Critical spec with a plan declaring `ci-held`, **When** the enforcement
   pack runs, **Then** it fails citing the Critical exclusion.
3. **Given** a plan with a malformed declaration value, **Then** it fails naming the legal
   values; **Given** no declaration line at all, **Then** it passes as `user-run`.

---

### Edge Cases

- **Evidence freshness/identity**: only a run on the **exact phase commit sha** certifies
  that phase; a run on any other commit (earlier phase, merge preview) does not. For a
  batch, the batch-end commit's run certifies the batch.
- **Owner approval is still per-phase/batch and recorded**: asynchronous never means
  automatic — a green run with no recorded owner approval certifies nothing. The record
  lives where phase approvals already live (the feature's PR/phase record), citing the
  evidence triplet.
- **Re-run flakiness**: a red run followed by a green re-run on the same sha certifies
  (the gate is deterministic by design; flaky gates are a project defect, not a law
  problem) — but the owner sees both runs on the run page and approves knowingly.
- **CI unavailable** (outage, fork PR without permissions): the user-run gate is always a
  lawful fallback — the declaration states the *permitted* mode, not a prohibition of
  stronger evidence.
- **Mixed evidence in one feature**: some phases certified user-run, others CI-held, is
  legal under a `ci-held` declaration (user-run is always lawful).
- **Constitutional flow-down**: adopted projects receive the X amendment through the
  re-expression procedure (`adoption/updating.md` §2) — their own version bump, their own
  SYNC IMPACT entry, human-approved; nothing auto-applies.
- **Agent behavior unchanged where it matters**: the agent still runs gates for fast
  feedback and still never claims success — under CI-held mode it reports the evidence
  and asks the owner to approve on it.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Constitution X MUST gain a CI-held certification clause (MINOR amendment,
  documented SYNC IMPACT entry): for Lite/Standard features whose approved plan declares
  it, gate certification MAY be a green CI run of the project gate on the exact phase
  commit, approved by the owner on that evidence; Critical features MUST NOT use it; the
  default absent any declaration remains the user-run gate.
- **FR-002**: The certification mode MUST be declarable in `plan.md` as a single header
  field (Gate Batching's shape): legal values `user-run` (default) and `ci-held`;
  declared before the first phase it governs.
- **FR-003**: The enforcement pack MUST validate the declaration: malformed values fail;
  `ci-held` on a Critical feature fails; absent means `user-run`.
- **FR-004**: The evidence triplet MUST be defined in law (gate-command.md): the CI run's
  URL, its green conclusion, and the phase-commit sha it ran on — all three, recorded with
  the owner's approval in the feature's phase record; anything less does not certify.
- **FR-005**: DoD gate 3 MUST be amended to carry the CI-held option with the same
  boundaries (Lite/Standard + declaration + owner approval on evidence; Critical excluded;
  batching composes — one batch-end evidence approval).
- **FR-006**: The kit MUST ship a project-gate CI recipe for adopted projects: a workflow
  template with the gate-command slots, classified appropriately in the manifest
  (slot-bearing ⇒ surgical), plus gate-command.md wiring instructions; projects that
  cannot run their gate in CI lose nothing (user-run remains lawful).
- **FR-007**: The plan template's Constitution Check (X row) and the templates named in
  the constitution's sync list MUST be updated in the same amendment (the constitution's
  own sync rule); `docs/sdlc/flow.md` and `docs/sdlc/critical-delivery.md` summaries
  updated where they state who certifies.
- **FR-008**: Every new rule MUST have seeded validation: enforcement-pack declaration
  scenarios (US3), and a worked evidence-record example in the docs so the first real use
  has a template to follow.
- **FR-009**: Agent-facing law (CLAUDE.md strict rules, gate-command.md agent-run section)
  MUST state the agent's unchanged obligation: it never claims success — under `ci-held`
  it reports the evidence triplet and requests the owner's approval on it.

### Key Entities

- **Certification mode declaration**: `plan.md` header field; `user-run` (default) |
  `ci-held`; machine-checked.
- **Evidence triplet**: CI run URL + green conclusion + phase-commit sha; meaningless
  without the owner's recorded approval.
- **Approval-on-evidence record**: the owner's per-phase (or batch-end) approval citing
  the triplet, in the feature's existing phase record (PR conversation / phase notes).
- **Project-gate workflow template**: kit-shipped, gate-slot-bearing, surgical-class.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On a CI-held Lite/Standard feature, the owner's per-phase synchronous work
  drops to zero commands — approval happens on evidence, asynchronously, at the owner's
  own moment; demonstrated end-to-end on a real phase of a kit feature (009+ or a fixture).
- **SC-002**: The no-self-certification property is preserved verbatim: 100% of seeded
  attempts to certify without the full triplet + recorded owner approval are identifiable
  as non-certifying from the law's text, and the agent's obligations are unchanged
  (never claims success).
- **SC-003**: 100% of seeded Critical-declares-ci-held plans fail the enforcement pack;
  absent declarations pass as user-run (zero disruption to every existing plan and
  adopted project).
- **SC-004**: The constitutional amendment lands with a complete SYNC IMPACT entry and
  every sync-listed mirror updated in the same change — doc-lint and the ritual checks
  stay green throughout, and the flow-down path for adopted projects is documented.

## Assumptions

- The constitution amendment is MINOR (new certification option in X: guidance materially
  expanded, no principle removed/redefined) — kit template version 0.4.1 → 0.5.0.
- GitHub Actions remains the reference CI; the law speaks of "a CI run the agent cannot
  forge" host-agnostically, and the shipped workflow template is the GitHub instance
  (006 precedent).
- The evidence-approval record needs no new artifact or machinery: phase approvals already
  live in the owner's messages/PR record; the law defines *what* must be cited, not a new
  file. (A machine check of the approval's presence is deliberately out of scope — that is
  the human-approval layer, same as gate 6.)
- The kit's own project gate is `ritual-checks` (its features are docs+scripts), so the
  kit needs no second workflow; the template ships for adopted projects' build/test gates.
- Batching (constitution X) remains unchanged and composes with CI-held mode; it is NOT
  deprecated by this feature (owners who prefer user-run gates still benefit from it).
- Branch-protection guidance may RECOMMEND requiring the project-gate check where wired,
  but requiring it is repository configuration, not kit-enforceable (006 precedent).
