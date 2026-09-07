# AI Code Review — 005 Field-Lesson Harvest (phases 1–4, batched)

**Reviewer**: Claude Code (claude-fable-5)
**Date**: 2026-09-07
**Branches**: agentic-sdlc-kit `005-field-lesson-harvest` (tip `cdf07a8`; phase commits
`d6146db` US1, `9712d29` US2, `2e6ba81` US3, `42b9cd9` polish, `cdf07a8` review fixes)
**Scope reviewed**: full branch diff vs `main` (`git diff main...HEAD`) — every hunk of
`adoption/greenfield.md`, `adoption/existing-system.md`,
`docs/rulebooks/database-rules-template.md`, `docs/sdlc/gate-command.md`, `docs/roadmap.md`;
spec.md FR-001–FR-007 + edge cases; plan.md Technical Context, Constitution Check, Gate
Batching declaration; research.md placement decisions D1–D2 + file-touch table; all five
quickstart.md scenarios; tasks.md T001–T014
**Feature contract**: documentation-only — no code, no new files outside `specs/005-*/`, no
new dependencies, no schema; five traps encoded at their trigger points in existing files;
no rewriting of unrelated adoption/rulebook content (plan.md Constraints)

> Plan.md's Gate Batching note promises each phase its own AI review; this single document
> discharges that per-phase, with per-phase evidence below, since all four phases were
> complete before review began.

## Verdict

**APPROVE with follow-ups** — the branch encodes all five GAP-003 adoption traps as
checkable steps at the exact point each incident occurred (per research.md's evidence-based
placement), touches only the five governance files plan.md names plus the feature's own spec
artifacts, and stays inside the documentation-only contract. Two findings surfaced during
review (F1: the database rule read as a ban on reuse where spec edge case demands
confirmation-not-prohibition; F4: two cross-references used **bold** for a kit path doc-lint
should guard) — both fixed in `cdf07a8` and re-linted green. Residual risk is low and sits in
prose interpretation, not machinery: the guidance is only as good as adopters reading it, and
the new literal `{{SLOT}}` mentions marginally grow the informational slot count (F3).

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-001/002: greenfield step 3 "Scaffolding-tool traps" bullets with concrete commands (`git status --ignored` + `!.env.example`; `git status` + `git rev-parse --show-toplevel`) — diff hunk read. FR-003: database-rules-template.md "Setup" MUST-rule + cross-refs in greenfield step 5 and existing-system step 4 — all three hunks read. FR-004: gate-command.md "Strict-build flags vs transitive-dependency vulnerabilities" section, three-step triage, blanket disable prohibited. FR-005: normalization paragraphs in greenfield step 2 and existing-system step 7. FR-006: every trap sits inside the named step, none in a standalone lessons doc. FR-007: roadmap row `idea → shipped` with owner + `specs/005-field-lesson-harvest/`, format matches rows 001–004. |
| Visual-reference match | N/A — no `screenshots/` directory; documentation-only feature, no UI. |
| Feature contract held (no unapproved table/migration/permission/package) | `git diff main...HEAD --stat`: 11 files — the 5 governance files from plan.md's Project Structure + 6 files under `specs/005-field-lesson-harvest/`. No new root-level files, no code, no scripts touched. |
| Constitution / domain invariants | Plan's Constitution Check re-evaluated post-implementation — see section below; PASS. Domain invariants N/A (kit template, none instantiated). |
| Security (authn/authz, secrets, sensitive logging) | No secrets, credentials, or auth surfaces in any hunk. The Setup rule (Phase 2) is itself a data-safety control against migrating into the wrong database. |
| Scope guard (`git diff --stat` — only intended files) | Per-phase commits inspected: `d6146db` (greenfield step 3, existing-system step 7, tasks scaffolding), `9712d29` (db template + 2 cross-refs + tasks), `2e6ba81` (gate-command + greenfield steps 2/3 + existing-system step 7 + tasks), `42b9cd9` (roadmap + tasks), `cdf07a8` (3 files, review fixes). Research.md's "No file outside this table is touched" holds. |
| Rollback safety (phase reverts cleanly; schema additive?) | No schema. Each phase is a disjoint set of prose additions in distinct sections — each commit reverts cleanly and independently; verified the three user-story phases share no hunk. |

## Findings

### F1 — Setup rule banned database reuse instead of requiring confirmation — BLOCKING (fixed)

Spec edge case (spec.md §Edge Cases): an intentionally shared database "must ask for explicit
confirmation, not forbid reuse outright." The Phase 2 wording ("MUST be confirmed as dedicated
to this project — not a reused local-dev instance and not a shared/production database") made
deliberate sharing unconfirmable — a prohibition, not a confirmation. Fixed in `cdf07a8`:
deliberate sharing is now "permitted only as an explicit, plan-approved decision: the rule is
confirmation, not a ban on reuse."
*Action: none — fixed and re-linted (exit 0).*

### F2 — FR-001/FR-002 satisfied in the existing-system track by pointer, not inline steps — ACCEPTED

FR-001/002 ask both tracks for a checkable step "at the point where scaffolding happens."
In Track B scaffolding only happens when the adoption adds a new component; the step-7
paragraph is itself checkable ("run it past `adoption/greenfield.md` step 3's … checklist
before the first commit") and avoids duplicating the checklist in two files. This placement is
the documented decision in research.md D1 and tasks.md T004.
*Action: none — deliberate, documented deviation from a literal reading; human reviewer may
confirm.*

### F3 — Literal `{{SLOT}}` mentions raise the informational slot count — MINOR

The two normalization paragraphs mention `{{SLOT}}` literally, raising doc-lint's
informational marker count from 109 to 111. Same pre-existing pattern as greenfield step 1
("fill every `{{SLOT}}` and `TODO(...)`"); informational in the kit, but an adopted project
running `-FailOnSlots` over copied `adoption/` docs would count them.
*Action: none now — consistent with existing precedent; revisit only if `-FailOnSlots`
bites an adopted project.*

### F4 — Cross-references used **bold** for a path that exists in the kit — MINOR (fixed)

`docs/rulebooks/database-rules-template.md` ships with the kit, so per the authoring
convention (doc-lint header: backticked paths MUST resolve; bold is for post-adoption paths)
the two Phase 2 cross-references should be backticked so doc-lint guards them. Fixed in
`cdf07a8`; doc-lint re-run green, confirming it now verifies the path.
*Action: none — fixed.*

### F5 — Phase numbering differs across artifacts — MINOR

Plan.md/quickstart.md number the user stories Phases 1–3; tasks.md numbers Setup/US1/US2/US3/
Polish as Phases 1–5; commit messages follow plan numbering (Phase 1=US1 … Phase 4=polish).
No substantive drift — every artifact agrees on content and order.
*Action: none — cosmetic; noted for the human reviewer tracing commits to tasks.*

## Constitution re-check (post-implementation)

**PASS.** I (Specification First): spec → plan → tasks preceded implementation; no scope
beyond the five named traps (Assumptions honored — no sixth trap invented). II (Source of
Truth): additions restate no constitution text; gate-command.md section complements, not
contradicts, the batched-gates and Minimum Gate clauses. IV (Architecture Consistency): prose
follows each file's existing voice/structure (MUST+Why rulebook idiom, bold-trap-name bullet
idiom in greenfield step 3). V/VII: N/A — engaged never (no invariants instantiated, no
integrations). VI (Security): improved, not touched adversely. VIII (Testing): quickstart
re-walk substitutes for tests per plan; executed and recorded in tasks.md (2026-09-07).
IX (Human Review): pending — this review does not discharge it. X (Controlled Delivery):
per-phase commits + declared Gate Batching phases 1–3 honored; batch-end gate user-certified
exit 0; the two post-batch commits (`42b9cd9` polish, `cdf07a8` fixes) each agent-linted
green and await the owner's final gate run before merge.

## Test coverage observed

No automated tests, by design (documentation-only; constitution VIII test requirement
inapplicable per tasks.md preamble). Verification substitute: the five quickstart.md scenarios,
each re-walked against the committed state — validation record with per-scenario evidence in
tasks.md Phase 5 (2026-09-07). Machine check: `scripts/doc-lint.ps1` exit 0 at every phase
boundary and after the review fixes (asserts every backticked path in the new prose resolves,
including the F4-restored cross-references).

## Residual risk

Low, concentrated in prose efficacy rather than correctness: the traps are only caught if
adopting engineers read the steps at the right moment — no machine check enforces the
dedicated-database confirmation or the normalization pass (accepted by spec: "an automated
machine check is a bonus, not a requirement"). F3's slot-count growth is the only mechanical
tail. Before merge: owner runs the certifying gate once more over the two post-batch commits
(`42b9cd9`, `cdf07a8`) and human review per constitution IX.
