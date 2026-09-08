# AI Code Review — 007 Adoption Doctor — Phase 4 (governance sweep)

**Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
**Date**: 2026-09-08
**Branches**: agentic-sdlc-kit `007-adoption-doctor` (tip `b0fe413`)
**Scope reviewed**: `git show b0fe413` (full diff); `CLAUDE.md` (Task-Scoped Reading table); `docs/roadmap.md` (status flow header + GAP-011 row, pre- and post-commit); `specs/007-adoption-doctor/spec.md`, `plan.md`, `tasks.md` (T017–T019 + all validation records); `scripts/verify-kit.ps1` (decline, dim-4/dim-5 logic), `scripts/init-kit.ps1` (doctor finish, lines 286–299), `scripts/update-kit.ps1` (apply-end doctor, lines 26, 299–308), `scripts/ritual-checks.ps1` (member gating, lines 40–90); `kit-manifest.json`; `.specify/memory/constitution.md` (sync list); FR-009 staleness sweep by grep over `docs/`, `adoption/`, `README.md`, `CLAUDE.md`, `AGENTS.md`, `.specify/templates/`, `specs/_templates/` (patterns: `verify-kit`, `adoption doctor`, `enforcement-pack`, `ritual-checks`, `init-kit`, `doc-lint`, `finish`); `docs/rulebooks/README.md` (custom-tier section); `adoption/updating.md` §4; `specs/007-adoption-doctor/research.md` (D1 present); live read-only run of `pwsh -File scripts/ritual-checks.ps1`.
**Feature contract**: docs-only governance sweep; no script changes

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
- **Implementer**: Claude Fable 5 (main session that produced commit b0fe413)
- **Inputs provided**: commit b0fe413 diff; spec.md (FR-009/FR-010), plan.md (phase 4 row), tasks.md (T017–T019 + validation records); the four scripts as they stand on this branch; kit-manifest.json; constitution sync list; grep sweep of the whole kit-shipped governance set; live ritual-checks run
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — The commit does what its three tasks literally say: the CLAUDE.md updating-row now names the doctor with three verified-true run moments, the roadmap flip is legal, and the zero-edit manifest claim checks out against a live doc-lint run (63 classified, doctor under the `scripts/*.ps1` verbatim glob, `kit-adoption.json` deliberately unclassified per research D1). But phase 4's declared goal is "summaries and indexes reflect the doctor", and the sweep missed the most visible summaries of all: four kit-shipped documents still enumerate `ritual-checks` as exactly three members (doc-lint + enforcement-pack + scope-check) — one of them the CLAUDE.md table row *directly above* the row this commit edited, inside this commit's own territory. In an adopted project — where every one of these files ships — the wrapper has run four members since phase 3, and the amended row itself asserts the fourth ("in adopted-project CI"). The residual risk sits in adopter-facing drift: the exact disease class (GAP-006/007) this feature exists to end.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-009 manifest half: `kit-manifest.json` line 36 `scripts/*.ps1` verbatim glob covers `verify-kit.ps1`; live doc-lint reports "63 shipped file(s) classified"; no `kit-adoption.json` row anywhere in the manifest, matching research D1. FR-009 adoption-docs half: greenfield (steps 3/machine-assist), existing-system (step 1), updating (§4 + report table) all name the doctor at init/update moments — but the CI moment's enumerations are stale (F2). CLAUDE.md row claims verified against code: init end (`init-kit.ps1:286–299`, Test-Path-guarded child pwsh), update end (`update-kit.ps1:299–308`, non-DryRun/non-Json apply), adopted-project CI (`ritual-checks.ps1:59–63`, gated on `.kit-version` OR `kit-adoption.json`). FR-010: see Test coverage. |
| Visual-reference match | N/A — no visual references; governance docs only. |
| Feature contract held (docs-only, no script changes) | `git show --stat b0fe413`: exactly `CLAUDE.md` (1 row), `docs/roadmap.md` (1 cell), `specs/007-adoption-doctor/tasks.md` (3 checkbox lines). Zero script files touched. |
| Constitution / domain invariants | Sync-list check: constitution lines 75–81 list only `enforcement-pack.ps1` as encoding constitutional constants; grep for `$Config`/batch-cap/cooling-off constants in `verify-kit.ps1`, `init-kit.ps1`, `update-kit.ps1`, `ritual-checks.ps1` returns nothing — no sync-list addition needed. Roadmap flip `specified → in progress` is a legal step of the declared status flow; prior cell confirmed `specified` via `git show b0fe413^:docs/roadmap.md`; spec pointer resolves. |
| Security (authn/authz, secrets, sensitive logging) | Prose-only diff; no secrets; updating.md's no-secrets-in-gateProof caveat intact. |
| Scope guard | Live `pwsh -File scripts/ritual-checks.ps1` on the branch tip: `scope-check: PASS phase 4 commit b0fe413 (3 file(s))`; all three files inside the declared phase-4 territory; overall `RESULT OK` with the truthful `verify-kit n/a (no adoption markers …)` line in the kit repo. |
| Rollback safety | Single docs-only commit; `git revert b0fe413` restores the prior row/status/checkboxes with no script or record coupling. |

## Findings

### F1 — CLAUDE.md's adjacent row still enumerates ritual-checks as three members, contradicting the row this commit added — BLOCKING

`CLAUDE.md:101` ("Reviewing / finishing a phase") reads "…verdicts come from `pwsh -File scripts/ritual-checks.ps1` (doc-lint + enforcement-pack + scope-check — same command CI runs)". One line below, the amended row (this commit) states the doctor "runs … in adopted-project CI" — which is true precisely because `ritual-checks.ps1:59–63` added verify-kit as a fourth member in any tree bearing `.kit-version` or `kit-adoption.json`. `CLAUDE.md` is surgical-class (kit-manifest.json line 4) and ships to every adopter, where the three-member parenthetical is now false and contradicted by its own table. `CLAUDE.md` is inside this phase's declared territory; the sweep edited line 102 and left line 101 stale.
*Action: implementer amends line 101's parenthetical in a phase-4 fixes commit (e.g. "…scope-check, plus the adoption doctor in adopted projects") — territory already covers the file.*

### F2 — Three more kit-shipped docs describe the adopter's CI wrapper as three members (FR-009 gap) — BLOCKING

Stale enumerations, each describing the wrapper as run *in the adopted project*, where it has four members since phase 3:
- `adoption/greenfield.md:133` — step 7 "Keep the framework honest": "runs `scripts/ritual-checks.ps1` (doc-lint + enforcement-pack + scope-check) on every push…"
- `adoption/existing-system.md:104–105` — step 8, same sentence shape.
- `docs/sdlc/branch-protection.md:6` — "the checks in `scripts/ritual-checks.ps1` (doc-lint + enforcement-pack + scope-check) run but nothing stops a PR…" (verbatim-class, line 26 of the manifest — flows down as-is).

FR-009 requires the adoption docs to name the doctor at the steps where it runs; US3/SC-004 make CI one of those steps, and these are the paragraphs describing exactly that step. These files sit outside phase 4's declared territory, so the fix needs a territory amendment before the fixes commit — the branch has direct precedent (commit `3a37d57` amended phase 2's territory for the same "the contract lies about the shipped script" argument, and tasks.md records it).
*Action: implementer amends phase-4 territory (named files, recorded in tasks.md as in phase 2), updates the three enumerations, re-runs ritual-checks.*

### F3 — Doctor's closed known-tier set contradicts the kit's custom-tier law — CONFIRM

`scripts/verify-kit.ps1:182` hardcodes `$knownTiers = 'backend','frontend','mobile','database','integration'` and FAILs any declared tier outside it; `adoption/updating.md:147–148` documents the record's `tiers` as "from the menu (backend, frontend, mobile, database, integration)". But `docs/rulebooks/README.md:46–50` ("A tier with no template — worker, desktop, CLI, data pipeline, …: Author your own… treat it as a first-class tier") and CLAUDE.md's own menu comment ("add a row per extra tier … a worker/CLI") promise first-class custom tiers. A project that follows that instruction cannot declare its worker tier in `kit-adoption.json` without going permanently red in CI, so the tier silently escapes the doctor's rulebook check. The spec's edge case ("unknown tier name … a named finding") sanctions the FAIL, so this is a spec-vs-older-kit-law conflict — exactly the "two rungs conflict → stop and report" case. Out of this commit's diff (phase 1 behavior), but squarely inside a governance *consistency* sweep's remit, and no prior review disposition covers it (phase-1 F6 was `tiers: []`).
*Action: owner decides — (a) widen dim 4 to accept any declared tier whose `docs/rulebooks/<tier>-rules.md` exists (closed set becomes a hint, not a wall), or (b) amend rulebooks README + CLAUDE.md menu comment to state custom tiers are not declared in the record (and accept they're invisible to the doctor). Record the ratification either way.*

### F4 — CLAUDE.md row says "runs at … update end" without the DryRun/-Json qualification — MINOR

`update-kit.ps1` runs the doctor only on a non-DryRun, non-Json apply (lines 26, 299–308); `-Json` callers are told to run it themselves (`adoption/updating.md:28`). The new row states "update end" unqualified. CLAUDE.md's own framing makes rows summaries that lose to the linked documents, and `adoption/updating.md` — the row's first pointer — carries the caveats.
*Action: none — summary-level truth with the qualifying law one pointer away; tighten only if the row is reworded for F1 anyway.*

### F5 — FR-010: dimension-4 sub-branches are handled in code but have no recorded fixture scenario — MINOR

Every check dimension has recorded healthy+broken scenarios (see Test coverage), so FR-010's letter is met. But `verify-kit.ps1:188–199` also handles: record that does not parse as JSON, `schemaVersion ≠ 1`, missing `projectName`, bad `topology`, and unknown tier name — and the spec's edge case explicitly promises "unknown tier name, missing field: a named finding, not a crash". No V/L/W row nor any round-2 table exercises these branches; likewise `kitVersionAtInit`'s `copy` fallback (phase-2 round-2 F3 records only the `0.4.1` path — informational field, never doctor-validated, so not itself a dimension).
*Action: implementer adds a malformed-record + unknown-tier fixture row to the validation records (one run each) in the fixes commit, or owner explicitly accepts sub-branch coverage as out of FR-010's scope.*

### F6 — Task text rewritten at check-off; README/existing-system machine-assist paragraphs undersell init — MINOR

T017's parenthetical was changed at check-off from the planned "(… — adoption-integrity verdicts)" to the shipped "(… runs at init end, update end, and in adopted-project CI)", and T019 was rewritten into its result record. This matches the branch's established convention (T004 was rewritten identically in phase 1) and the substance matches the plan, but the original ask is now recoverable only from git history. Separately, `README.md:53–57` and `adoption/existing-system.md:84–87` describe init-kit without mentioning the adoption record or the doctor finish — not false (nothing claims a doc-lint finish anywhere; that stale claim class is fully gone), just thinner than greenfield's updated parallel paragraph, and README is outside FR-009's named set.
*Action: none required; optionally fold a one-clause record/doctor mention into both paragraphs if F2's territory amendment already opens the adoption docs.*

## Constitution re-check (post-implementation)

**PASS with F1–F3 engaged under II.** I (Specification First): phase 4 delivered against approved spec/plan/tasks — satisfied. II (Source of Truth): the sweep's own product violates the no-silent-conflict rule in four places (F1/F2) and F3 is a live two-rungs conflict this review duly stops and reports — the fixes commits restore compliance. III: N/A (single repo). IV/V/VII: N/A for a docs-only diff. VI: satisfied (prose only). VIII: FR-010 satisfied at dimension granularity (F5 nuance). IX: human review pending at merge, as planned. X: phase 4 gates alone per the declared batching; single revertible commit; scope-check PASS observed live. Sync-list re-check confirms the plan-time judgment: no constitutional constants entered any script this feature touched.

## Test coverage observed

No test framework (kit convention); the deterministic suite is the recorded fixture validation in `specs/007-adoption-doctor/tasks.md`. Coverage per dimension, all with verdict + exit recorded: dim 1 structure (V2 fail / V1+V11 healthy), dim 2 slots (V3, plus round-2 realism-corrected fixture V11 proving zero false findings with kit menu prose retained, and V12b empty-file no-crash), dim 3 constitution (V4, V13), dim 4 record (V5 missing rulebook, V6 empty proof, V7 grandfather WARN, V14 empty tiers, L4 CI-shaped regression, L6 owner tier addition), dim 5 kit-version (V8a/V8b, V12a empty-file crash-fix, V8-strict, phase-1 addendum real-JSON/bare-sha/bad-kitCommit triple, phase-2 round-2 F1 7-char kitCommit), decline (V9 + V9 regression, F2-veto no-false-decline), multi-fail single run (V10), lifecycle (L1–L6 incl. L5 DryRun-skip and L3 end-to-end `.kit-version` write-then-read), wrapper (W1–W3 + phase-3 round-2 widened-gate pair and kit-repo regression). Gaps: F5's dimension-4 sub-branches and the `kitVersionAtInit: "copy"` fallback have no recorded run. Live re-verification this review: ritual-checks on the tip → 3 OK + truthful n/a + RESULT OK; doc-lint 63 classified (T019's exact claim).

## Residual risk

Concentrated in adopter-facing drift, not in code: F1/F2 ship four documents that misdescribe the CI wrapper adopters rely on — in a kit whose stated thesis is that doc/reality drift is the fatal disease, these should not survive to merge (both are cheap prose fixes; F2 needs the territory-amendment ritual the branch has already exercised). F3 is the one behavioral risk: the first adopter who follows the rulebook README's custom-tier instruction and declares it honestly turns their CI permanently red — an owner ratification either way before this feature's flow-down would prevent a field-feedback entry. F5/F6 carry no merge risk. Merge after the phase-4 fixes commit (F1/F2), the F3 ratification recorded, and the owner-run certifying gate.

---

## Implementer fix-response log (post-review)

*Appended by the implementing agent after acting on the review; the review text above is
unmodified.*

| Finding | Disposition |
|---|---|
| F1 | **Fixed** — CLAUDE.md's reviewing-row parenthetical now reads "…scope-check, plus the adoption doctor in adopted projects — same command CI runs". |
| F2 | **Fixed (territory amendment, named files)** — the three-member enumerations in greenfield step 7, existing-system step 8, and branch-protection.md all name the fourth member. |
| F3 | **Fixed in code (option a, owner-ratified)** — separate phase-1-territory commit: any declared tier passes iff `docs/rulebooks/<tier>-rules.md` exists; tier names validated as lowercase `[a-z][a-z0-9-]*`; custom-tier FAIL hint points at the README skeleton; updating.md prose and data-model.md amended. Validated: `worker` with rulebook OK, without rulebook FAIL-with-skeleton-hint. |
| F4 | **Accepted** — summary-level truth; caveats live one pointer away. |
| F5 | **Fixed (validation rows added)** — malformed-record FAIL (not crash) and `schemaVersion: 2` FAIL recorded in the phase-4 round-2 table alongside the F3 scenarios; `kitVersionAtInit: "copy"` fallback accepted as out of FR-010 scope (informational, never doctor-validated). |
| F6 | **Accepted** — task-rewrite convention noted; the thinner README/existing-system machine-assist paragraphs left as-is (README outside FR-009's set; existing-system's step 1 already carries the record). |