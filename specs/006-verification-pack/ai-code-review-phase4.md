# AI Code Review — 006 Verification Pack, Phase 4 (Governance Sweep)

**Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
**Date**: 2026-09-08
**Branches**: agentic-sdlc-kit `006-verification-pack` (tip `8fd95f6`)
**Scope reviewed**: `git show 327ce02` and `git show 8fd95f6` (full diffs); `CLAUDE.md`; `docs/sdlc/flow.md`; `docs/sdlc/gate-command.md`; `docs/sdlc/definition-of-done.md`; `docs/roadmap.md`; `specs/006-verification-pack/tasks.md` (Phase 4 territory + amendment note, T022–T025), `plan.md` (phase table), `research.md` (D6); owning docs `docs/sdlc/review-process.md`, `.specify/memory/constitution.md` (I, II, X, sync list); scripts `scripts/scope-check.ps1`, `scripts/ritual-checks.ps1` (headers + full wrapper), `scripts/doc-lint.ps1` (manifest sweep logic); `kit-manifest.json`; repo-wide straggler grep over `docs/`, `adoption/`, `.specify/`, `.github/`, `specs/_templates/`, `README.md`, `AGENTS.md` (`git diff --stat` claims, self-completed-review claims, deleted 002 workflow names); live run of `scripts/ritual-checks.ps1 -Branch 006-verification-pack`
**Feature contract**: docs-only governance sweep; no script changes

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
- **Implementer**: Claude Fable 5 (main session that produced commits 327ce02/8fd95f6)
- **Inputs provided**: commits 327ce02 + 8fd95f6 (shas), the six changed files, feature spec directory (tasks.md, plan.md, research.md), owning docs, the shipped scripts, and read-only execution of the ritual checks — never the implementer's conversation or reasoning
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — the sweep's substance is largely correct: gate-command's batched-gates bullet now mirrors constitution X exactly, the DoD gate-4/5 summaries in CLAUDE.md and flow.md match the owning documents and the scripts' actual behavior, the roadmap flip is legal and its pointer resolves, T024's "no constitution sync-list addition" claim verifies against both scripts (no encoded constants), T025's manifest claim verifies (doc-lint excludes `docs/roadmap.md` by design; ritual-checks RESULT OK reproduced). But a docs-only consistency phase is judged on consistency, and two defects sit inside the phase's own edits: CLAUDE.md step 6 now orders the intent diff review *after* the commit (where `git diff --stat` is literally empty), contradicting review-process.md; and flow.md's step table keeps the old 3c-scope-check → 3d-review → 3e-commit order while the diagram two paragraphs above it says commit → scope check → review. Both are one-edit fixes inside declared territory. Residual risk sits in the constitution-I ordering question (F4) — a wording tension the phase surfaced but did not report.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | T022–T025 each traced to a concrete hunk in `8fd95f6`; Phase 4 Independent Test reproduced: doc-lint OK, roadmap flipped, ritual-checks `RESULT OK` on the branch (live run) |
| Visual-reference match (where references exist) | N/A — no UI, no `screenshots/` directory in this feature |
| Feature contract held (no unapproved table/migration/permission/package) | `git show --stat` both commits: only the six declared markdown files; zero script/workflow changes |
| Constitution / domain invariants | Constitution X batched-gates clause read against gate-command.md bullet (consistent); constitution I step order read against the new DoD preamble — tension found, see F4; sync list read for D6 — confirmed, no constants in `scope-check.ps1`/`ritual-checks.ps1` (no `$Config`, no batch/cooling values; grep verified) |
| Security (authn/authz, secrets, sensitive logging) | N/A — markdown-only diff; no secrets introduced (diff read in full) |
| Scope guard (`git diff --stat` — only intended files) | `scope-check: PASS phase 4 commit 327ce02 (1 file(s))`, `PASS phase 4 commit 8fd95f6 (6 file(s))` — live run; amendment commit lands before the phase commit, so the parent-read rule is satisfied, matching the documented remediation path |
| Rollback safety (phase reverts cleanly; schema additive?) | Single phase commit + single amendment commit; reverting both restores the pre-sweep docs exactly (docs-only) |

## Findings

### F1 — CLAUDE.md step 6 puts the `git diff --stat` intent review after the commit, where it shows nothing — BLOCKING

`CLAUDE.md` Workflow step 6 (added in `8fd95f6`): "Commit the phase (`phase N` in the subject), then run the machine scope check … **and review `git diff --stat`**; fix only current-phase issues." The owning document, `docs/sdlc/review-process.md` "After Each Phase" step 2, orders it the other way: "Review the **working diff** for intent (`git diff --stat`), fix only current-phase issues, **and commit the phase**." After committing, `git diff --stat` on the working tree is empty — the instruction as written is mechanically inert, and the pre-commit intent review (the step that lets you fix issues *before* the commit exists) has vanished from the always-loaded summary. This also matters for F4: the pre-commit intent review is the reading that reconciles the new flow with constitution I's "(6) review changes; (7) commit."
*Action: implementer — reword step 6 to match review-process.md's order: review the working diff for intent, commit with the `phase N` subject, then run the machine scope check against the commit. In territory; one-line fix.*

### F2 — flow.md step table (3c scope check → 3d AI review → 3e commit) contradicts the diagram in the same file — BLOCKING

The phase-loop diagram (flow.md lines 24–30, rewritten this phase) shows the correct order: gate → **commit** → scope check → AI review, matching review-process.md exactly. The step table below it was reworded (T023) but **not resequenced**: rows still run 3c Scope check → 3d AI review → 3e Commit. Row 3c even says the script "verifies the **phase commit**" — a commit the table doesn't produce until 3e, two rows later. A summary page whose diagram and step list disagree on step order is precisely the defect class this phase exists to eliminate, and flow.md is a verbatim kit doc.
*Action: implementer — reorder rows to 3c Commit, 3d Scope check, 3e AI review (keeping each row's current text and the owning-doc citations); re-check the "five bold entries" sentence below the table still maps bold rows to gates 1, 3–5, 6 after the renumber.*

### F3 — New DoD preamble "Gates 1–3 hold before the commit" contradicts gate 3's own batched option — CONFIRM

The rewritten preamble (`docs/sdlc/definition-of-done.md` lines 11–15) asserts gates 1–3 hold **before** the commit. Gate 3's Batched option in the same document (and constitution X) says the certifying user-run gate for a declared batch lands **once at batch end** — i.e., after the batch's earlier phase commits, with only agent feedback runs before them. This very feature batched phases 1–3 that way. The old preamble had the same latent tension, but this phase rewrote the sentence under an amended territory specifically to fix staleness, and the new wording states the unqualified claim more crisply than before.
*Action: owner decision — either accept "gates 1–3 hold before the commit" as describing the default (non-batched) flow, since gate 3's own text carries the exception and prevails, or add a short qualifier ("gate 3 at batch end when batching is declared — gate 3, Batched option"). Recommend the qualifier; in territory.*

### F4 — Constitution I orders review (step 6) before commit (step 7); the DoD now codifies commit-then-verify, with the constitution unamended — CONFIRM

Constitution I: "(5) run the project gate; (6) review changes; (7) commit the approved phase." The DoD preamble and closing clause now state gates 4–5 are verified **against the committed phase**. There is a defensible reading — step (6) maps to the pre-commit intent review that review-process.md step 2 preserves, and the machine scope check plus fresh-context review are *verification of* the committed phase, not the constitution's "review changes" step — but that reading survives only in review-process.md, and F1's CLAUDE.md edit currently deletes it from the summary layer. Research D6 checked constitution X and promised to "stop and report" if constitution wording contradicted the amended DoD; principle I's numbered workflow was not examined, and the commit message reports only X. Per the DoD's own conflict rule and equivalence section, a divergence is resolved *toward* the constitution or the constitution is amended — not silently encoded.
*Action: owner decision — either record the defensible reading (fix F1 so the pre-commit intent review survives everywhere, and note the I↔DoD mapping in the phase record or the D6 entry), or PATCH-amend constitution I's step list to name post-commit verification explicitly. This should be resolved before merge; it is a report-the-conflict obligation, not necessarily a wording change.*

### F5 — team-workflow.md still says "The owner completes the AI review" — DOC DRIFT

`docs/sdlc/team-workflow.md` §4 (line 81), a **verbatim** kit doc: "The owner completes the AI review; a different developer completes `human-pr-review.md`…" Under gate 5 as amended, the AI review is *produced by* a fresh-context agent or second model — never self-graded; the owner initiates and dispositions it. As written, a team reading only this page concludes reviewer separation applies to human review alone. The sweep's stated goal ("every summary and index reflects the machine-checked gates") reaches this sentence; it was outside the declared territory, so fixing it needs an amendment or follow-up, but the sweep should at least have flagged it.
*Action: implementer/owner — territory amendment or immediate follow-up commit: reword to "The owner initiates the fresh-context AI review (DoD gate 5 — never self-graded); a different developer completes `human-pr-review.md`…".*

### F6 — ai-code-review-template.md evidence row still names `git diff --stat` as the scope guard — DOC DRIFT

`specs/_templates/ai-code-review-template.md` line 42 (verbatim template, amended by this feature in phase 2): the evidence table row reads "Scope guard (`git diff --stat` — only intended files)". Gate 4's scope guard is now the `scope-check.ps1` verdict; the diff-stat read is the owner's supplementary intent check. Every future review filed from this template will cite the superseded mechanism as the scope evidence.
*Action: implementer/owner — follow-up (or territory amendment): reword the row to "Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent)".*

### F7 — Weaker stragglers: README countermeasure row, critical-delivery audit-evidence list, rulebook checklist template — MINOR

(a) `README.md` line 14 (surgical — adopters replace it, but it is the kit's own front page): "Scope creep / drive-by refactors | One approved phase at a time; `git diff --stat` after every phase" — the headline countermeasure is now the machine scope check and it goes unmentioned. In passing: line 25 still says "13 principles"; the constitution has 10 (pre-existing, off-mission for this sweep). (b) `docs/sdlc/critical-delivery.md` line 46 (verbatim): audit evidence retained lists "the gate command + exit code, the `git diff --stat` output, and both completed review checklists" — for a Critical (numbered) feature the gate-4 evidence is now the scope-check verdict; the list is incomplete rather than wrong. Its line 14 (Lite lane = `git diff --stat` scope check) is *correct* — `scope-check.ps1` is not-applicable on `fix/`/`chore/`/`docs/` lanes by design. (c) `docs/rulebooks/compliance-checklist-template.md` line 47 (surgical) — "`git diff --stat` reviewed" as the scope item. The PR/human-review templates' diff-stat lines are gate-6 human checks and are fine as-is. No stragglers found for the deleted `doc-lint.yml`/`enforcement-pack.yml`: all remaining mentions are the migration note in branch-protection.md, a supersession comment in ritual-checks.yml, and historical feature dirs/`review/`.
*Action: owner — batch these into the F5/F6 follow-up (or a `docs/` lane commit): README row + principle count, critical-delivery item 3 evidence list, rulebook template row. None blocks this phase.*

## Constitution re-check (post-implementation)

**PASS with one open report (F4).** I (spec-first): satisfied procedurally — spec/plan/tasks preceded the phase; the step-order wording tension is F4, reported here rather than silently resolved (II, conflict rule — this review is the report). II: no ladder rung overridden; summaries defer to owning docs explicitly. IV/V/VI/VII/VIII: N/A or unchanged (docs-only; the checks themselves were validated in phases 1–3). IX: human review pending at merge, correctly framed as gate 6. X: exactly one phase implemented; one phase commit plus one sanctioned pre-commit territory amendment, matching the documented remediation path; scope-check PASS on both commits; phase 4 gates alone (batch was 1–3), per plan.

## Test coverage observed

No test framework (per plan; constitution VIII satisfied by seeded-violation scenarios in earlier phases). For this docs-only phase I re-ran the machine suite read-only: `pwsh -File scripts/ritual-checks.ps1 -Branch 006-verification-pack` → `doc-lint OK` (manifest sweep clean; `docs/roadmap.md` excluded by design in `doc-lint.ps1`), `enforcement-pack OK` (one non-blocking PhaseSizeWarning on the pre-phase specify commit 645fbf0), `scope-check OK` with per-commit verdicts including `PASS phase 4 commit 8fd95f6 (6 file(s))` — `RESULT OK`, matching T025's recorded claim. T024's D6 claim independently verified: neither `scope-check.ps1` nor `ritual-checks.ps1` contains a `$Config` block or any batch-cap/cooling-off constant; the constitution sync list already names `enforcement-pack.ps1`.

## Residual risk

Concentrated in F1/F2 (a verbatim summary layer that currently contradicts its owning doc and itself — cheap to fix, in territory, must land before merge) and F4 (constitution I's step order vs the codified commit-then-verify ritual — a wording decision only the owner can make; left unresolved it becomes the next feature's "stale clause discovered mid-sweep"). F5/F6 mean the reviewer-separation and machine-scope-guard rules are still misdescribed in two verbatim files adopters will read; harmless to this branch, but the flow-down channel will propagate the stale wording until the follow-up lands. Merge after F1/F2 are fixed, F3/F4 are dispositioned by the owner, and the F5–F7 follow-up is scheduled.

---

## Implementer fix-response log (post-review, same phase territory)

*Appended by the implementing agent after acting on the review; the review text above is
unmodified. Fixes land in a `phase 4 fixes` commit under a second (named-files) territory
amendment.*

| Finding | Disposition |
|---|---|
| F1 | **Fixed** — CLAUDE.md steps 6–7 reordered to match review-process.md: pre-commit intent review (`git diff --stat`) → commit with `phase N` subject → machine scope check against the commit → fresh-context AI review. |
| F2 | **Fixed** — flow.md table resequenced to 3c Commit → 3d Scope check → 3e AI review; the "five bold entries" mapping still holds (bold rows = gates 1, 3, 4, 5 per phase + 6 at merge). |
| F3 | **Fixed (qualifier option)** — DoD preamble now carries the batched-gate exception inline ("for a declared batch, gate 3's certifying user-run gate lands once at batch end"). |
| F4 | **Reported + defensible reading recorded** — research.md D6 now documents the constitution-I mapping: I's step (6) is the pre-commit intent review (preserved everywhere after the F1 fix); gates 4–5 are additional post-commit verification, not a relocation of step (6). A PATCH amendment to constitution I remains available if the owner prefers explicit wording — flagged for the merge decision. |
| F5 | **Fixed (territory amendment, named file)** — team-workflow.md §4 reworded: the owner *initiates* the fresh-context AI review; separation stated. |
| F6 | **Fixed (territory amendment, named file)** — template evidence row now reads "Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent)". |
| F7 | **Fixed (territory amendment, named files)** — README countermeasure row names the machine scope check; "13 principles" corrected to 10; critical-delivery audit-evidence list now includes the scope-check verdict; compliance-checklist template scope item updated. |