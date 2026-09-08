# AI Code Review — 008 CI-Held Certifying Gate (phase 1: the law)

**Reviewer**: fresh-context agent — Claude Fable 5
**Date**: 2026-09-08
**Branches**: agentic-sdlc-kit `008-ci-held-gate` (tip `aad06e1`)
**Scope reviewed**: full diff of `aad06e1`; complete amended texts of `.specify/memory/constitution.md`, `docs/sdlc/definition-of-done.md`, `docs/sdlc/gate-command.md`, `docs/sdlc/critical-delivery.md`, `.specify/templates/plan-template.md`, `CLAUDE.md`; governing artifacts `specs/008-ci-held-gate/` (spec.md, plan.md, research.md D1–D7, data-model.md, contracts/gate-certification.md, quickstart.md, tasks.md); cross-text sweep of `docs/sdlc/flow.md`, `branch-strategy.md`, `review-process.md`, `team-workflow.md`, `README.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `specs/_templates/human-pr-review-template.md`, `specs/_templates/rollback-template.md`, `docs/rulebooks/*` (grep over every "exit code / user-run / claim success" statement in the repo); `.specify/templates/spec-template.md` (Delivery Level semantics); `kit-manifest.json` class of gate-command.md; live run of `scripts/ritual-checks.ps1`
**Feature contract**: law-only phase: constitution amendment + sync-listed mirrors, atomic; no scripts changed

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
- **Implementer**: Claude Fable 5 (main session that produced commit aad06e1)
- **Inputs provided**: phase 1 diff (`git show aad06e1`); specs/008-ci-held-gate/ artifacts (spec, plan, research, data-model, contract, quickstart, tasks); the seven amended/mirror documents read in full post-amendment; repo-wide grep sweep for competing statements of the certification rule; ritual-checks live run
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — The clause itself is well-drafted: all six boundaries (Lite/Standard only; plan-declared before the first governed phase; recorded owner approval on the full triplet; agent never claims success; Critical excluded; absent = user-run) are stated compatibly in constitution X, DoD gate 3, gate-command.md, critical-delivery.md item 4, the plan-template X row, and the CLAUDE.md strict rule; the SYNC IMPACT entry matches the diff exactly, 0.5.0/MINOR is correct under the versioning policy's own text, and the feature correctly does not certify itself under the mode it introduces (D7). What blocks is that the amendment updated the *new* statements of the rule but left three *old* categorical statements standing inside the very files it amended — CLAUDE.md's "The Law" bullet, gate-command.md's preamble and Agent-run-gates sentence, and the DoD preamble's "Gates 1–3 hold before the commit" — each of which now flatly contradicts the clause twenty lines away. For a phase whose entire contract is "seven documents state the same rule, atomically," these are in-territory, one-line, must-fix defects (F1–F3). A wider tail of untouched instruments (PR template's exit-code field, branch-strategy's merge condition, review-process step 1) is a scope decision for the owner (F4). Residual risk sits in mixed signals to future agents reading the un-qualified sentences.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-001: constitution X clause carries all six boundaries verbatim (constitution.md:236–246); FR-002 grammar matches D1 in plan-template.md:10–14 (but see F7 on timing); FR-004 triplet + worked example in gate-command.md:87–116; FR-005 DoD gate 3 CI-held option with batch composition (definition-of-done.md:44–53); FR-007 plan-template X row both arms (plan-template.md:60); FR-009 CLAUDE.md:82–86. FR-003/006/008-machine-half are phases 2–3, correctly deferred per plan |
| Visual-reference match | N/A — no visual references (law documents) |
| Feature contract held (no unapproved table/migration/permission/package) | Diff touches exactly the 6 territory files + tasks.md bookkeeping; no scripts, no packages; `scope-check: PASS phase 1 commit aad06e1 (7 file(s))` observed live |
| Constitution / domain invariants | Amendment procedure followed: rationale + mirror impact + human-adoption note in SYNC IMPACT (constitution.md:4–21); MINOR correct per "guidance materially expanded" (:268–271); mirror list = diff file set exactly (5 mirrors + constitution; tasks.md is bookkeeping, not a mirror); enforcement half explicitly named as next-phase-same-branch. But see F1–F3 for mirror-internal contradictions and F6 for the sync-list constants |
| Security (authn/authz, secrets, sensitive logging) | No secrets in the amended texts; the clause pins evidence to a CI host the agent does not control; secrets-in-evidence prohibition deferred to phase 3 template per data-model.md |
| Scope guard | `git diff --stat` matches Territory (6 files) + tasks.md; ritual-checks live: doc-lint OK, enforcement-pack OK (PhaseSizeWarning is on the *specify* commit 07dc07f, not this phase), scope-check PASS, RESULT OK — L8 claim reproduced |
| Rollback safety | Reverting `aad06e1` restores the complete 0.4.1 law wholesale (constitution + all five mirrors in one commit); nothing else references the clause yet — plan's revertibility claim holds |
| Self-application (D7) | `specs/008-ci-held-gate/plan.md` declares `**Gate Batching**: phases 1-3` and no Gate Certification line (= `user-run` by absence, lawful); tasks.md Organization states user-run explicitly; quickstart Phase-gates section confirms "this feature does not certify itself with the mode it introduces" — consistent |

## Findings

### F1 — CLAUDE.md "The Law" bullet still states the unqualified rule the same commit amends — BLOCKING

CLAUDE.md:25–26 ("Gate command: `docs/sdlc/gate-command.md` — the user runs it; you never claim success without the user-confirmed exit code.") was left untouched while the strict-rules bullet (:82–86) gained the ci-held arm. An agent reading CLAUDE.md top-to-bottom now receives two rules: "never without the user-confirmed exit code" (categorical) and "or recorded approval on the evidence triplet" (conditional). CLAUDE.md is a sync-listed mirror whose sync-list condition is precisely "strict rules must not contradict this file['s constitution]" — the amendment introduced an internal contradiction inside a mirror it was editing. Under the ci-held mode there is no user-confirmed exit code at all, so the two sentences cannot be reconciled by reading charitably.
*Action: implementer — qualify CLAUDE.md:25–26 the same way the strict rule was qualified (or point it at the strict rule), in-phase before batch certification.*

### F2 — gate-command.md's preamble and Agent-run-gates section contradict its own new CI-held section — BLOCKING

Two categorical sentences in the amended file were not qualified: (a) line 3, "The user must run the gate locally. AI must not claim success without the user's exit code." — the document's framing sentence, now false under the mode defined at line 87 of the same document; (b) line 64 (Agent-run gates), "a phase is only **Done** against a gate run by the user, with the exit code confirmed by the user (`docs/sdlc/definition-of-done.md`, item 3)" — this cites DoD item 3, which now carries the option, while itself stating the pre-0.5.0 rule as the only path to Done. A reader of the Agent-run-gates section alone would conclude ci-held certification is impossible. The section's *point* (an agent-run gate never certifies) survives ci-held intact — the fix is to narrow the sentence to that point ("only against a certification held by the owner — user-run exit code or recorded approval on CI evidence"), not to weaken it.
*Action: implementer — qualify gate-command.md:3 and :64 to admit the declared ci-held path while preserving "agent runs never certify," in-phase.*

### F3 — DoD preamble "Gates 1–3 hold before the commit" is unsatisfiable under ci-held — BLOCKING

definition-of-done.md:12–13 says "Gates 1–3 hold before the commit (for a declared batch, gate 3's certifying user-run gate lands once at batch end — gate 3, Batched option)". Under ci-held, gate 3's evidence is the CI run **on the exact phase-commit sha** — the evidence cannot exist until after the commit is made and pushed, so gate 3 can *never* hold before the commit in this mode. The preamble carries a batching qualification but no ci-held one; it now contradicts the CI-held option ten lines below in the same file. This is a genuine timing rule, not pedantry: it governs whether a ci-held phase commit may lawfully exist before certification (it must — the whole feature depends on it).
*Action: implementer — extend the parenthetical: "…batch end — gate 3, Batched option; under a declared `ci-held` mode, gate 3's certification necessarily lands after the phase/batch-end commit, on its evidence", in-phase.*

### F4 — Un-swept instruments still state the categorical user-run rule with no planned fix — CONFIRM

Beyond flow.md and critical-delivery.md (the only summaries FR-007 names), these documents state "who certifies" and are in no phase's territory, so they will be live on `main` after the feature merges: `docs/sdlc/branch-strategy.md:70` ("Merge to `main` only **after the gate passes (user-confirmed exit code)**" — a merge *condition*); `docs/sdlc/review-process.md:33` ("1. User runs the gate command" — step 1 of the per-phase loop); `.github/PULL_REQUEST_TEMPLATE.md:38` and `specs/_templates/human-pr-review-template.md:28` (a mandatory `Gate exit code: EXIT: ___` field/checkbox that a ci-held feature cannot truthfully fill — the operational instrument of gate 3 at merge time); `README.md:13`; `docs/rulebooks/backend-rules-template.md:62`, `mobile-rules-template.md:68`, `compliance-checklist-template.md:48` ("Gate run by the user with confirmed exit code 0 (constitution X)" — cites the amended principle); `specs/_templates/rollback-template.md:29`. The constitution's conflict rule resolves each in law's favor, but the PR/review templates are where an owner *records* certification — under ci-held they demand evidence that does not exist. This is a spec-scope gap (FR-007 was drawn narrowly), not an implementation error, so it needs an owner decision, and several of these files are flow-down verbatim/surgical kit surfaces.
*Action: owner — either extend phase 4's territory (T015–T017) to sweep at minimum the PR template, human-pr-review-template, branch-strategy:70, and review-process:33 (adding a ci-held alternative to the exit-code fields), or record the residue as an accepted deviation in the phase record before merge.*

### F5 — flow.md stale mid-batch — ACCEPTED

flow.md row 3b ("**User-run gate**: the owner runs it and confirms the exit code"), the diagram line 25, and the Lane-variations list carry no ci-held mention. This is planned (T015, phase 4), the batch merges as one PR so `main` never sees the stale state, and flow.md self-disclaims ("This page is a summary, not law… the owning document prevails"). Deliberate and documented. One caveat: T015 names only "row 3b (gate)" — the diagram box (line 25) and the Lane-variations bullets (a Batched-gates bullet exists; a ci-held sibling is the natural mirror) also state the rule and must not be missed.
*Action: implementer — in phase 4, widen T015's edit to cover the diagram line and Lane variations, not just row 3b; none in this phase.*

### F6 — Constitution sync list not extended for the new constitutional constants — CONFIRM

The 0.4.1 amendment exists solely to record (per GAP-002) that `scripts/enforcement-pack.ps1` "encodes constitutional constants — batch-phase cap, Critical cooling-off hours — its $Config MUST change in lockstep" (constitution.md:99–101). This amendment introduces new constitutional constants that phase 2's check will encode: the legal value strings `user-run`/`ci-held` and the Critical exclusion (D6). The "Templates requiring updates" parenthetical was not extended to name them, so the very drift-catch mechanism 0.4.1 built is one amendment behind the moment the phase-2 check lands. The SYNC IMPACT entry does name the enforcement half as landing next phase — the gap is only the sync-list enumeration.
*Action: owner decision — extend the parenthetical (add "Gate Certification legal values / Critical exclusion") either now in-phase (cleanest: the amendment commit is the constants' birthplace) or atomically with phase 2's commit; per the 0.4.1 precedent this is sync-list bookkeeping and needs no further version bump if folded into this amendment.*

### F7 — plan-template's Gate Certification field comment omits the timing boundary — DOC DRIFT

plan-template.md:10–14: the new field's comment documents values, the ci-held semantics, the Critical exclusion, and absent-means-user-run — but not "declare BEFORE the first phase it governs; never retroactively," which constitution X (:237), FR-002, and D1 all state, and which the adjacent Gate Batching comment (:5–8) explicitly carries. The template is the artifact a plan author actually reads while declaring; a mid-feature retroactive `ci-held` declaration would look template-legal. (Phase 2's check cannot police timing, making the prose the only guard.)
*Action: implementer — add the timing sentence to the field comment, in-phase (file is in territory).*

### F8 — "Lite" in the clause is near-vacuous but internally resolvable — MINOR

The clause says "for a Lite or Standard feature, the approved plan MAY declare…"; the Lite *lane* (fix/chore/docs) skips the spec directory entirely and has no plan.md to declare in. The tension resolves via spec-template.md:6–9: Delivery Level applies to numbered features — a numbered feature *may* be declared Lite and then has a plan. So lane-Lite can never use ci-held (nothing to declare in), spec-declared-Lite can — consistent, if marginal. The wording is inherited verbatim from the 0.4.0 Batched-gates clause, so this phase introduces no new drift; all seven texts agree with each other.
*Action: none required for this phase; owner may note for a future PATCH that "Lite" here means the spec-declared level, not the fix/ lane.*

### F9 — CLAUDE.md strict rule states only the phase-commit sha, not the batch-end variant — MINOR

CLAUDE.md:82–85 defines the triplet as "CI run URL + green conclusion + exact phase-commit sha"; constitution X, DoD gate 3, gate-command.md, and the plan-template row all add "(for a declared batch: the batch-end commit)". Under batching+ci-held composition, an agent applying CLAUDE.md literally would demand per-phase-commit evidence a batch does not produce. Mitigated: the rule cites gate-command.md, and the batch-end commit is itself a phase commit.
*Action: implementer — optionally append "(batch: the batch-end commit)" in the strict rule for exact parity; low priority, in-phase if F1 is being edited anyway.*

### F10 — Dangling forward reference to "this document's wiring section" — MINOR

gate-command.md:96 ("for adopted projects that's the project-gate workflow (this document's wiring section)") references a section that does not exist until phase 3 (T013). Resolves at merge since the batch ships as one PR; doc-lint does not check intra-document anchors, so nothing machine-catches it if phase 3 were abandoned.
*Action: implementer — none if phases proceed as planned; if phase 3 is descoped, rewrite the parenthetical before merge.*

### F11 — Worked example hard-codes the kit author's identity in a shipped law doc — MINOR

gate-command.md:109's example approval reads "approved, anas.m, 2026-09-08" while data-model.md's version of the same example uses `<owner>, <date>` placeholders. gate-command.md is a shipped kit file (manifest class surgical), so fresh adoptions receive a personal name baked into their law's worked example.
*Action: implementer — replace with `<owner>, <date>` (matching data-model.md) in-phase or in phase 3's gate-command edit.*

## Constitution re-check (post-implementation)

**PASS with nuance.** I (Specification First): satisfied — full specify stage preceded the commit. II (Source of Truth): the amendment's *new* statements never diverge across the seven texts, but the plan's claim that "prose and mirrors never diverge at a commit boundary" is undermined by the stale sentences *inside* two mirrors (F1–F3) — the atomicity held for additions, not for supersessions. IV: satisfied — Gate Batching's exact shape reused. V (the amendment procedure as invariant): satisfied — rationale, mirror impact, human-adoption note, MINOR bump all present and correct per the Governance section's own text. IX/X: this phase itself is delivered one-phase, in-batch, under the current user-run law (D7 honored). VIII engages at phase 2 (seeded G1–G6), correctly not claimed here.

## Test coverage observed

No test framework (kit convention). Phase-1 validation is the read-verified L1–L8 checklist, recorded with quotes in tasks.md — all eight entries present and, on re-verification, accurate as far as they go: the quoted boundary phrases exist verbatim in the cited files, and L8's ritual-checks green was reproduced live by this reviewer. Structural gap in the validation design: L1–L7 verify the *presence* of the new rule in each text but never verify the *absence of surviving contradicting text* in the same or neighboring documents — which is exactly where F1–F4 live. A "no un-qualified statement of the old rule remains in the amended files" assertion would have caught F1–F3 mechanically (the grep sweep in this review took one command).

## Residual risk

Concentrated in F1–F3: until fixed, an agent obeying CLAUDE.md:25 or gate-command.md:64 literally will refuse (correctly, by that text) to treat ci-held certification as Done — a fail-safe direction, but a live law contradiction that the DoD's own conflict rule says must halt work. F4 is the post-merge risk: the PR and human-review templates demand an exit code a ci-held feature cannot produce, so the first real ci-held use hits a form it cannot fill truthfully unless the owner disposes of F4 before merge. F6 risks the sync-list drift-catch being one amendment stale when phase 2 encodes the value strings. All blocking items are one-to-three-line prose edits inside phase-1 territory, fixable in-phase before the batch-end certification; nothing here requires unwinding the amendment.

---

## Implementer fix-response log (post-review, same phase territory)

*Appended by the implementing agent after acting on the review; the review text above is
unmodified.*

| Finding | Disposition |
|---|---|
| F1 | **Fixed** — CLAUDE.md's Law bullet now states certification-is-held-by-the-user with both arms; "You never claim success" kept categorical. |
| F2 | **Fixed** — gate-command.md's preamble states both certification forms; the Agent-run-gates sentence narrowed to its surviving point ("a certification held by the owner … an agent-run gate NEVER certifies in either mode"). |
| F3 | **Fixed** — DoD preamble parenthetical gains the ci-held arm ("certification necessarily lands **after** the phase/batch-end commit, on its CI evidence"). |
| F4 | **Owner disposition: sweep** — phase 4's territory widened (named files, recorded in tasks.md) and T016b added covering the PR/human-review template gate fields (ci-held alternative), branch-strategy's merge condition, review-process step 1, README's row, the two rulebook-template gate items, and rollback-template. |
| F5 | **Encoded in phase 4** — T015's text now names the diagram line and Lane-variations bullet explicitly. |
| F6 | **Fixed in-phase (the constants' birthplace)** — the sync-list parenthetical names the Gate Certification legal values and the Critical ci-held exclusion; no separate version bump (0.4.1 bookkeeping precedent, folded into this amendment). |
| F7 | **Fixed** — the timing sentence ("Declare BEFORE the first phase it governs; never retroactively") added to the plan-template field comment. |
| F8 | **Accepted** — inherited Batched-gates wording; the spec-declared-Lite reading documented by the reviewer stands; PATCH candidate noted for a future amendment. |
| F9 | **Fixed** — the strict rule carries the batch-end variant. |
| F10 | **Accepted** — phases proceed as planned; the wiring section lands in phase 3 of this same batch. |
| F11 | **Fixed** — worked example uses `<owner>, <date>`. |