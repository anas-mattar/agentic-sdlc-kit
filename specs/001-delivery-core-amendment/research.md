# Phase 0 Research: Delivery Core Amendment

No `[NEEDS CLARIFICATION]` markers remain in the Technical Context — this section instead
records the design decisions needed to turn `review/out/DECISION.md`'s findings into concrete
edits, since the review named *what* is broken but not always the exact replacement wording.

## Decision: Unit-of-review split (finding #1)

**Decision**: Gates 1–5 of the Definition of Done apply at every phase commit. Gate 6 (human
review) applies once, at the point the completed feature is merged to `main`. `branch-strategy.md`
already describes "merge once per feature, gate + review approved" — DoD gate 6 is restated to
match that, rather than the other direction.

**Rationale**: `review/out/DECISION.md`, Open decision 1, explicitly recommends Option A
("Gates 1–5 per phase, human review per feature") over Option B (review once per PR with no
phase checkpoints): "the rollback story is the kit's spine; per-phase user gates are what make
phase commits individually trustworthy. Human review already moves to the feature level, which
removes the part nobody would do." The user confirmed agreement with the decision document.

**Alternatives considered**: Option B (gate + review once per PR) — rejected per the decision
document: a bad phase-2 commit would never be independently known-good, quietly weakening the
revert-clean property that per-phase gating exists to protect.

**Mechanics**: `definition-of-done.md` gate 6 wording changes from "before it is considered
complete" (implying every phase) to explicit feature-level scope, with a note distinguishing
"phase-committed" (gates 1–5) from "feature-merged" (adds gate 6). `branch-strategy.md`'s merge
rule and `review-process.md`'s "After Each Phase" / "Human Review" sections are cross-checked so
none of the three documents implies a different unit of review. Constitution XII's rationale
("Human review is required before merge") already says *merge*, not *phase commit* — XII's
prose does not need to change, only the two operational documents that had drifted from it.

## Decision: `tasks-template.md` test-policy fix + SYNC mirror completion (finding #2)

**Decision**: Change `tasks-template.md:11` from "Tests are OPTIONAL — only include them if
explicitly requested in the feature specification" to language consistent with constitution
XI: tests are required for business-critical functionality/calculations/regression-affecting
changes, and omitted only when the feature genuinely has none of those (documented, not
assumed). Add `tasks-template.md` to the constitution's SYNC IMPACT REPORT "Templates requiring
updates when this file changes" list, alongside the existing `plan-template.md` and
`CLAUDE.md` entries.

**Rationale**: The template's OPTIONAL language sits at the exact decision point where an
agent chooses whether to write tests, and directly contradicts XI. It survived prior
amendments because the SYNC header's own mirror list never named it — fixing the list is what
prevents this specific defect class from recurring in the *next* amendment (`review/out/DECISION.md`
finding #2, citing the sync header at `constitution.md:34-36` vs. the amendment rule at
`constitution.md:204`, now XI's mirror obligation is renumbered but unchanged in Phase 3).

**Alternatives considered**: Leaving tests "optional by default, required by an explicit spec
flag" — rejected; it inverts the burden of proof constitution XI sets (tests required for
business-critical logic by default, not by opt-in).

## Decision: `Delivery Level` field placement (finding #4)

**Decision**: Add `**Delivery Level**: [Lite | Standard | Critical]` as a required header field
in `spec-template.md`, positioned directly under `**Status**: Draft`, matching the shape this
feature's own `spec.md` already manually adopted. Add a corresponding checklist item to the
Spec Quality Checklist section of `speckit.specify`'s validation flow via the checklist content
generated at spec-authoring time (not `checklist-template.md`, which is a generic, per-request
checklist tool used by `/speckit.checklist` for arbitrary custom checklists — the spec-quality
checklist is generated inline by `/speckit.specify` itself, per its own instructions, so the
fix lives in `spec-template.md`'s adjacent guidance comment, not in `checklist-template.md`).

**Rationale**: `branch-strategy.md` and `critical-delivery.md` both say the level is "declared
in the feature's spec.md header" but the template had no field for it (finding #4) — the fix is
mechanical: add the field where the rule already says it belongs.

**Alternatives considered**: A separate `delivery-level.md` file per feature — rejected as
unnecessary ceremony; a header field is consistent with how `Status` and `Branch` are already
declared, and keeps the declaration in the one document every downstream reader already opens.

## Decision: Phase-size rule (finding #6)

**Decision**: State the rule where phases are first planned, not where they are later audited:
add a "Phase sizing" paragraph to `plan-template.md`'s Constitution Check section (under
Controlled Delivery), and a matching one-line cross-reference in `definition-of-done.md` gate 2
("Single-phase scope respected"). Rule: a phase MUST be independently revertible (no other
phase's correctness depends on this phase being present) and MUST correspond to one
meaningfully independent, testable slice of the feature — not "whatever fits before the
deadline." A plan that bundles unrelated concerns into one phase (e.g., a schema change and an
unrelated UI change) fails the Constitution Check gate and must be split before approval.

**Rationale**: `review/out/DECISION.md` finding #6: nothing bounds what a phase is, and the
agent being controlled by "one phase at a time" draws its own phase boundaries — under
deadline pressure the rational move is fewer, fatter phases, which silently destroys the
revert-clean property. Checking the rule *at plan approval* (before implementation, not after)
is the recommended action in the decision document's Action column for finding #6.

**Alternatives considered**: A numeric bound (e.g., "no phase touches more than N files") —
rejected here; deferred to the 002 `enforcement-pack`'s diff-size warning (the decision
document explicitly splits this finding's action across "001: phase-size rule checked at plan
approval; 002: diff-size warning" — 001 ships the qualitative rule a human/agent can reason
about at plan time, 002 ships the mechanical CI check).

## Decision: Source-of-truth ladder — one canonical copy (finding #7)

**Decision**: Constitution principle II remains the single canonical, ordered ladder (9 rungs).
`CLAUDE.md`'s "Source of Truth Priority" section is replaced with a short pointer to
constitution II plus the operational conflict-rule prose (which is guidance, not a restatement
of the ordering, so it stays). `plan-template.md`'s Constitution Check line for principle II
drops its inline 5-item paraphrase ("visual references → spec → plan → contracts → data
model") and instead reads "No conflict between artifacts, per the source-of-truth ladder
(constitution II) — conflicts stop work."

**Rationale**: Three divergent shapes of the same ladder is the review's headline
self-referential finding — the kit's own README names "drift" as the failure mode rule-based
frameworks succumb to, and three copies of one ordered list is exactly that drift, pre-adoption.
One canonical source removes the possibility of the copies disagreeing again.

**Alternatives considered**: A mechanized mirror check (grep-diff the three copies in
`doc-lint.ps1`) — this is `review/out/DECISION.md`'s rejected-findings entry "Eliminate the
mirrored Constitution Check": the *disease* is manual sync, the *cure* the decision document
assigns is a mechanized check, but explicitly as v1.1 work, not this feature. This feature
removes two of the three copies instead, which is a strictly smaller, immediately verifiable
fix that doesn't preclude the mechanized check later.

## Decision: Critical-solo review artifact + cooling-off duration (finding #14)

**Decision**: `critical-delivery.md` item 5 ("Independent approval") is expanded to name: (a)
the artifact — a written second-model adversarial review recorded as
`specs/NNN-name/second-model-review.md`, following the same structure as
`ai-code-review-template.md` but performed by a different model than the one that implemented
the feature, explicitly probing for the implementer's likely blind spots; (b) the duration — a
minimum 24-hour cooling-off period between the second-model review being recorded and the
feature being merged, during which the solo developer does not act on the feature further; and
(c) an explicit honesty sentence: "This substitutes for, but is not equivalent to, independent
human review — it is a mitigation for the solo-developer case, not a claim of true
independence."

**Rationale**: `review/out/DECISION.md` finding #14 and Open decision 5 (Option A, the
recommended choice): "defined in 001 with an explicit honesty sentence... The kit's audience is
solo devs; option B [requiring an external human] amputates the lane they most need." A named
artifact and a numeric duration are what make this checkable rather than aspirational — the
review's core complaint was that the existing clause was "operationally undefined."

**Alternatives considered**: Requiring an external human reviewer for all Critical work
(Option B in the decision document) — rejected per the recommendation above. Leaving the
duration unspecified ("a cooling-off period") — rejected; an unspecified duration is exactly
the kind of unfalsifiable requirement finding #14 objects to.

## Decision: Principle demotion and renumbering (finding #15)

**Decision**: Delete principle V (Data Standards) and VI (Auditability) from the constitution;
move their normative content into `docs/rulebooks/database-rules-template.md`'s existing
"Schema Standards" section (which already carries `{{PK_STANDARD}}` and `{{AUDIT_FIELDS}}` as
comments referencing the constitution — those become the primary statement instead of a
mirror). Delete principle X (Performance Responsibility) outright — no replacement location;
its content is generic "consider performance" advice with no falsifiable check, per the
decision document's characterization ("unfalsifiable vibes"). Renumber the remaining ten
principles contiguously (old VII→V Domain Invariants, VIII→VI Security, IX→VII External
Integration Governance, XI→VIII Testing Requirements, XII→IX Human Review Requirement,
XIII→X Controlled Delivery — old IV Architecture Consistency and I–III keep their numbers).
Sweep every cross-reference to a renumbered principle across the repository (`CLAUDE.md`,
`plan-template.md`, `docs/sdlc/*.md`, `docs/rulebooks/*.md`) and update it.

**Rationale**: `review/out/DECISION.md` finding #15: V and VI are schema conventions dressed as
constitutional principles (project-specific formatting choices, not law that "supersedes
everything"); X is unfalsifiable and dilutes the principles that carry real weight. Demoting
rather than deleting V/VI preserves their content (schema conventions still matter — they just
aren't constitutional).

**Alternatives considered**: Keeping V/VI at constitutional rank but marked "advisory" —
rejected; a two-tier constitution (binding vs. advisory principles in the same numbered list)
recreates the "which rule actually governs" ambiguity finding #15 is trying to remove.
Renumbering with gaps (retiring V/VI/X as "deleted" placeholders, e.g. "V. [reserved]") —
rejected; gaps read as unfinished editing and every future reference would still need to know
which numbers are alive, which is no simpler than renumbering once, correctly, now.

## Decision: Phase ordering for this feature

**Decision**: Phase 1 ships the core contradiction fix (findings #1, #2, #4, #7) — every action
the decision document's "three things that matter" section frames as one bundled, urgent
amendment. Phase 2 ships the two missing rule *definitions* (#6, #14) — additive, no existing
document is self-contradictory without them, so they're lower urgency than Phase 1's active
contradictions. Phase 3 ships the principle pruning and renumbering sweep (#15) — isolated last
because it has the widest blast radius (every cross-reference to a principle number, repo-wide)
and zero interaction with Phases 1–2's content, so a mistake here is cheapest to isolate and
revert independently.

**Rationale**: Satisfies this feature's own phase-size rule (Decision above): each phase is one
independently revertible, coherently-testable slice, ordered by (a) urgency per the decision
document's own framing, then (b) blast radius, smallest first.

**Alternatives considered**: One single phase for the whole feature — rejected; violates the
phase-size rule this feature itself introduces, and the renumbering sweep in particular is
mechanically distinct enough (a repo-wide find/replace of principle numbers) that bundling it
with prose edits would make a bad edit in either half harder to isolate and revert.
