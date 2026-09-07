# Definition of Done

The single, authoritative checklist a feature's phases MUST satisfy before the feature is
considered complete. It is the operational form of constitution **X. Controlled Delivery**
and **IX. Human Review Requirement**.

## Two units of review

Gates apply at two different points, not uniformly at every phase:

- **Gates 1–5** MUST pass at **every phase commit** — a phase is not Done, and MUST NOT be
  committed, until items 1–5 below are all true.
- **Gate 6** (human review) applies **once per feature**, at the point the feature's final
  phase is ready to merge to `main` — not after every individual phase commit. A 4-phase
  feature owes one human review, not four.

> A phase commit requires gates 1–5. A feature merge additionally requires gate 6. If any
> required item is false, stop and resolve it before proceeding.

## Gates (all required, in order)

1. **Specification approved** — `spec.md`, `plan.md`, and `tasks.md` for the feature
   exist and are approved before implementation begins (constitution I).
2. **Single-phase scope respected** — only the one approved phase was implemented; no
   unrelated changes are bundled in (constitution X), and the phase itself satisfies the
   phase-sizing rule (`.specify/templates/plan-template.md`, Controlled Delivery check):
   independently revertible, one meaningfully independent and testable slice.
3. **Gate passed with user-confirmed exit code** — the user (not AI) ran the gate
   (`docs/sdlc/gate-command.md`) and confirmed the exit code. AI MUST NOT claim
   success without that confirmation (constitution X). The AI MAY run the gate
   during implementation for fast feedback, but an agent-run gate never satisfies
   this item — and is not used at all for Critical features
   (`docs/sdlc/critical-delivery.md`).
   **Batched option (Lite/Standard only)**: when the feature's `plan.md` declares
   `**Gate Batching**: phases N-M` (max 3 consecutive phases, declared before the
   batch starts — constitution X, Batched gates), this item is satisfied for the
   batch's phases by **one** user-run gate at batch end; items 1–2 and 4–5 still
   apply to every phase individually, and each phase keeps its own commit. Critical
   features MUST NOT batch (`scripts/enforcement-pack.ps1` fails the branch).
4. **Diff reviewed / scope guard** — the phase commit passes the machine scope check
   (`pwsh -File scripts/scope-check.ps1`): every changed file falls inside the phase's
   **Territory** declared in `tasks.md` (`.specify/templates/tasks-template.md`, Phase
   Territory). A PASS verdict is required; a WARN verdict (no territory declared) is
   acceptable only for features specified before the verification pack. Undeclared
   changes are reverted — or, when the scope discovery is legitimate, the territory is
   amended with owner approval in a commit made **before** the phase commit that relies
   on it (the check reads the declaration from the commit's parent, so a stray file can
   never be legalized in the commit that introduces it). The owner still reviews
   `git diff --stat` for intent; the machine makes a skipped or sloppy scope check
   visible (`docs/sdlc/review-process.md`).
5. **AI review complete — by a reviewer that did not write the code** — the AI review
   checklist (`specs/_templates/ai-code-review-template.md`) was completed: spec/visual-
   reference match, stack rulebooks, security, tests, migrations, unrelated changes,
   rollback safety. For phases touching a tier with a compliance checklist
   (`docs/rulebooks/`), this includes passing that checklist — any FAIL blocks the phase.
   The review MUST be produced by a **fresh-context agent session or a second model** —
   never self-graded by the implementing agent in the same context — and MUST carry the
   template's **Reviewer Provenance** block (reviewer identity, inputs supplied, and the
   verbatim attestation that the reviewer did not produce the diff).
   `scripts/enforcement-pack.ps1` fails the branch when a review file added on it lacks
   the block or attests the implementer as reviewer; reviews committed before the
   verification pack are grandfathered (only files added in the branch's diff are
   checked). The machine verifies the block's presence and consistency; the truth of the
   attestation remains the owner's to audit — but it is now a falsifiable written
   statement, not an unstated assumption.
6. **Human review approved (once per feature, at merge)** — after the feature's final phase
   passes gates 1–5, a human reviewer verified business requirements, domain correctness,
   security implications, visual-reference compliance, and architectural compliance across the
   **full feature diff**, and approved the change. **Human review is required before merge**
   (constitution IX; `specs/_templates/human-pr-review-template.md`).

Each phase may be **committed** to the feature branch once items 1–5 are true. The **feature**
may be **merged** to `main` only after its final phase satisfies items 1–5 and the feature as a
whole satisfies item 6.

## Conflict rule

If any artifact conflicts with another, or with the constitution, **stop and report**
rather than silently choosing one. The constitution
(`.specify/memory/constitution.md`) prevails.

## Equivalence to the constitution

This Definition of Done is equivalent to constitution **X** (incremental delivery,
one approved phase at a time, no unrelated changes, every phase passes the gate) plus
**IX** (mandatory human review before merge). Applying this checklist to a phase
yields the same pass/fail outcome as applying those principles directly. If this
document and the constitution ever diverge, the constitution prevails and this
document MUST be corrected.
