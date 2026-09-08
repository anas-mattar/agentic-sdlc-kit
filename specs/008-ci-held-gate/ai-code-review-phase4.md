# AI Code Review — 008 CI-Held Certifying Gate, Phase 4 (governance sweep)

**Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
**Date**: 2026-09-08
**Branches**: agentic-sdlc-kit `008-ci-held-gate` (tip `63fed28` — the commit under review is the tip)
**Scope reviewed**: full diff of `63fed28` (13 files); the law it must mirror
(`.specify/memory/constitution.md` X + CI-held clause lines 237–255,
`docs/sdlc/gate-command.md` lines 1–145, `docs/sdlc/definition-of-done.md` lines 7–55,
`docs/sdlc/critical-delivery.md` item 4, `CLAUDE.md` strict rules,
`.specify/templates/plan-template.md` header lines 1–16); phase 4 tasks + Territory in
`specs/008-ci-held-gate/tasks.md` (T015–T017, widening note); `plan.md` header + Summary;
`spec.md` FR-001–FR-009; `adoption/updating.md` §2–§3 vs `scripts/update-kit.ps1` (lines
149–244); flow.md diagram byte-measurement; a repo-wide categorical-statement grep sweep
(patterns: user-confirmed exit code, user runs the gate, confirms the exit code, user-run
gate, exit code 0, gate passes) over everything outside `specs/NNN-*` and `review/`;
`kit-manifest.json` branch diff; live `ritual-checks.ps1` run.
**Feature contract**: docs-only sweep phase — no script, manifest, or constitution changes;
territory = the 13 declared doc/template paths (+ `kit-manifest.json`, declared but
intentionally untouched); every edited sentence must restate constitution X's CI-held
boundaries without altering them; flow.md stays a summary that introduces no rule;
phase 4 gates alone under `user-run` (plan header, research D7).

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
- **Implementer**: Claude Fable 5 (main session that produced commit 63fed28)
- **Inputs provided**: phase 4 diff (`git show 63fed28`), spec.md, plan.md, tasks.md,
  constitution, gate-command.md, definition-of-done.md, critical-delivery.md, CLAUDE.md,
  updating.md, update-kit.ps1, live ritual-checks run
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups** — the commit does exactly what phase 4 declared: every edited
summary and instrument (flow.md 3b + diagram + lane bullet, updating.md flow-down note +
§3 template paragraph, PR/human-review gate fields, branch-strategy merge condition,
review-process step 1, README countermeasure row + non-negotiable 3, three rulebook
templates, rollback template, roadmap flip) now carries the ci-held arm, and I found **no
edited sentence that misstates a boundary**: everywhere the mode is stated it is
plan-declared, certification is the owner's recorded approval on the evidence triplet, the
agent never claims success, user-run stays lawful, and where lane eligibility is spelled
out it is Lite/Standard only with Critical excluded (README compresses the qualifier —
F4). The updating.md claims match `update-kit.ps1`'s real surgical contract (report-only,
`-Force` refused on non-verbatim) — no repeat of the phase 3 false-tool-claim defect.
Machine verdicts are green (ritual-checks RESULT OK; scope-check PASS on `63fed28`).
Residual risk sits in three places: the phase-loop diagram now implies ci-held
certification happens *before* the phase commit, contradicting DoD's timing arm (F1); the
two review-template fill-in fields invite citing only two of the triplet's three elements
(F2); and three shipped sentences outside the declared territory still state the old
categorical rule (F3 — needs an owner disposition, exactly as phase 1's F4 did).

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-007 (summaries updated where they state who certifies): flow.md:54 row 3b, flow.md:75–79 lane bullet, flow.md:25–26 diagram — all read against constitution X lines 237–247; FR-009 unaffected (CLAUDE.md/gate-command untouched this phase, both already carry the arm — CLAUDE.md:26,83–88; gate-command.md:64–73). T015/T016/T016b/T017 each traced to concrete hunks in `git show 63fed28`; tasks.md checkboxes flipped and Phase 4 validation table appended (tasks.md:236–245). |
| Visual-reference match | N/A — no UI. Closest analogue checked: flow.md ASCII diagram alignment after the edit — measured every line in bytes and normalized for multibyte chars (│┌┐└┘─▼►·→—≠ are 2–3 bytes): every interior line normalizes to 69 display chars inside a 71-char border, including the two new gate lines (79 bytes = 69 + one → + one — at 3 bytes each + 2 borders; 75 bytes = all-ASCII interior). Diagram is aligned. |
| Feature contract held | Docs-only: `git show 63fed28 --stat` = 13 files, all markdown; no script, manifest, or constitution change. Manifest-sweep claim verified: `git diff caf5fcc..HEAD -- kit-manifest.json` shows exactly one added row (phase 3's project-gate surgical row) — phase 4 added none, matching T017. `kit-manifest.json` in Territory but untouched (allowed: territory is an upper bound). |
| Constitution / domain invariants | Every edited sentence checked against X's six boundaries (constitution:237–247): flow.md:54 + 75–79 (all six present incl. Lite/Standard, default, agent-never-claims, Critical); updating.md:112–119 (six boundaries enumerated verbatim, MINOR-bump guidance matches §2 rule 2 at updating.md:56–58); branch-strategy.md:70–73, review-process.md:33–36 (batch composition "lands once, at batch end" matches DoD gate 3:51–52), rulebooks (Lite/Standard + constitution X cited), compliance checklist, rollback template, PR/human-review templates, README — none contradicts the law; deviations of compression/ordering are F1/F2/F4. flow.md header disclaimer intact (flow.md:3–6): still a summary, every new sentence restates X with citations, introduces no rule. |
| Security (authn/authz, secrets, sensitive logging) | No code, no secrets. The one behavior-adjacent text (updating.md §3, lines 129–134) verified against `scripts/update-kit.ps1`: surgical pass builds a report only (lines 228–238, no Copy-Item), `-Force` refused on non-verbatim class (line 156: "only verbatim paths may be forced"), writes happen only in the verbatim pass (lines 191–219). "Never receives it through the update channel / first-install by copy" is accurate: surgical files are never written to the target. |
| Scope guard | Live run: `scope-check: PASS phase 4 commit 63fed28 (13 file(s))` — all changed files inside the declared Phase 4 Territory (widened in tasks.md:108–112 *before* the phase-4 commit, per DoD gate 4's parent-read rule; the widening itself landed in `dc11b12`, a prior commit). Full chain: `pwsh -File scripts/ritual-checks.ps1` → doc-lint OK (64 shipped files classified, every referenced path resolves), enforcement-pack OK (one non-blocking PhaseSizeWarning on specify-stage `07dc07f`, not this commit), scope-check OK (all 7 phase commits PASS), verify-kit n/a, **RESULT OK**. `git show --stat` read for intent: 81 insertions / 21 deletions, all sweep-shaped. |
| Rollback safety | Pure-doc commit; `git revert 63fed28` restores the pre-sweep text with no cross-file coupling (the law files it summarizes are untouched, so a revert leaves law + old summaries — the pre-phase-4 state, self-consistent because summaries defer to owning docs). Roadmap row check: docs/roadmap.md:52 GAP-012 = `in progress`. |

## Findings

### F1 — Phase-loop diagram sequences ci-held certification before the phase commit — MINOR

flow.md:25–27 now reads `→ owner certifies the GATE (exit code — or ci-held evidence
approval, when the plan declares it) → commit the phase`. Under ci-held that order is
impossible: the evidence triplet requires the CI run **on the exact phase commit**
(constitution X:240–241), and DoD's preamble states it explicitly — "under a declared
`ci-held` mode, gate 3's certification necessarily lands **after** the phase/batch-end
commit, on its CI evidence" (definition-of-done.md:13–15, itself a phase-1-review F3
fix). Row 3b and the lane bullet are order-neutral and correct; only the diagram's arrow
sequence implies the wrong timing. Mitigation: flow.md declares itself a summary whose
owning documents prevail (flow.md:3–6), and the timing is not one of the six declared
boundaries — so this is drift, not a legal misstatement.
*Action: implementer, small follow-up edit — e.g. move the ci-held parenthetical to after
the commit line, or append "(ci-held: after the commit, on its CI evidence)"; re-measure
the box width after editing.*

### F2 — Review-template fill-in fields invite a two-element citation of a three-element triplet — MINOR

`.github/PULL_REQUEST_TEMPLATE.md:40` and `specs/_templates/human-pr-review-template.md:28–30`
gained the field `— or ci-held: run URL + commit sha: `___``. The law requires **all three**
elements cited — "run URL, green conclusion, and commit sha … anything less does not
certify" (FR-004, spec.md:171–173; gate-command.md:98, worked example at 113–114 includes
"conclusion success"). The checkbox line above each field does name the full triplet and
cites `docs/sdlc/gate-command.md`, and the conclusion is machine-visible on the cited run
page — but the blank literally prompts for two of three, so a filled template can produce
a formally non-certifying record. Note the implementer followed tasks.md T016b's exact
prescribed string ("EXIT: ___ — or ci-held: run URL + commit sha"), so the defect
originates in the task text, not the execution.
*Action: implementer, follow-up — extend both fields to `run URL + conclusion + commit
sha` (or `run URL (green) + commit sha`); amend T016b's wording if re-recorded.*

### F3 — Three shipped sentences outside the declared territory still state the old categorical rule — CONFIRM

The adversarial absence sweep (grep over the whole shipped kit minus `specs/NNN-*` and the
unshipped `review/` dir — `kit-manifest.json` classifies neither) leaves three hits that a
ci-held feature makes stale:

- `docs/sdlc/team-workflow.md:9–10` — "one owner: the developer whose agent implements it,
  who runs the gate for it, and who confirms the exit code". Definitional in purpose (who
  "the user" is — and the same owner holds ci-held approval), but categorical in mode.
- `docs/sdlc/team-workflow.md:127–128` — "The user-run gate remains the per-feature trust
  ritual; CI is the cross-feature one". Under ci-held, CI evidence IS the per-feature
  certification input — the sentence's dichotomy is now wrong for declared features.
- `adoption/greenfield.md:140–141` — "CI gate as second witness … The user-run gate
  remains the trust ritual; CI catches the day someone skips it". Same dichotomy; mostly
  defensible for a fresh adoption (ci-held doesn't exist there until the project ratifies
  the amendment, per updating.md:117), but stale as kit-wide framing.

All other residual hits judged lawful: constitution X:225 is the default rule the clause
itself amends; DoD:34 "by default" + gate-command:3 "by default" are both-arms sentences;
Lite-lane statements (`branch-strategy.md:56`, `critical-delivery.md:14` Lite row) remain
true in practice because a Lite branch has no `plan.md` and therefore no declaration
vehicle (see F5); plan-template.md:6's Gate Batching comment says "user-run gate at batch
end" but the adjacent Gate Certification comment (lines 9–15) carries the composition
("batch: the batch-end commit"); `docs/sdlc/deployment-standards.md:11` is descriptive;
`repository-strategy.md:103–105` is mode-neutral ("gate passes"); constitution SYNC-IMPACT
lines are history. Fixing the three hits in this commit would have failed the scope check
(none is in Phase 4 Territory), so leaving them was the lawful choice — but phase 1's F4
disposition was "sweep, not accept-as-residue", and these are the same species.
*Action: owner decision — either a small follow-up sweep (Lite lane `fix/`/`docs/` branch,
three sentences) or record them as accepted residue; not a merge blocker.*

### F4 — README lines compress away the "Lite/Standard only" qualifier — MINOR

README.md:13 and README.md:71–74 both say "(plan-declared `ci-held`)" without the
Lite/Standard restriction that every law file and flow.md:54,75 carry. Not a misstatement
— a Critical plan *cannot* lawfully declare it and `enforcement-pack.ps1` fails one that
tries (verified phase 2, G4) — but a pitch-page reader could infer universal
availability. The categorical invariant that matters ("the agent may never self-certify")
is preserved verbatim in both lines.
*Action: none required; optional two-word insertion ("Lite/Standard, plan-declared
`ci-held`") if the owner wants the pitch page boundary-complete.*

### F5 — Latent eligibility tension: Lite is named eligible but has no declaration vehicle — MINOR (pre-existing, noted for the record)

Constitution X:237–238 grants ci-held to "a Lite or Standard feature" via "`plan.md`",
while the Lite lane by definition has no spec directory and no plan.md (flow.md:67–69,
branch-strategy.md:56). Net effect: Lite can never actually declare ci-held, so every
pure-Lite-lane "user-run gate" sentence stays true — which is why F3 excludes them. This
is phase-1 law (already reviewed twice), not a phase 4 defect; phase 4's sweep sentences
consistently write "Lite/Standard" following the constitution's own wording, which is the
correct behavior for a mirror.
*Action: none for this phase; owner may want a future clarification (e.g. "Standard — and
Lite, should it ever carry a plan") in a later amendment.*

## Constitution re-check (post-implementation)

**PASS.** I (spec/plan/tasks approved before the phase; T015–T017 pre-declared, F4-widening
note recorded in tasks.md before the commit). II (the sweep *mirrors* the constitution
X clause it summarizes — every edited sentence traced back to constitution:237–247; no new
rule introduced anywhere, flow.md disclaimer intact). III N/A. IV (no new patterns,
packages, or architecture — markdown only). V (the amendment procedure itself was phase
1's concern; phase 4 touches no constitutional text). VI (no secrets; the one operational
claim verified against update-kit.ps1). VII N/A. VIII N/A this phase (no
business-critical logic; the enforcement check landed and was scenario-tested in phase 2).
IX (this review is gate 5 by a non-implementing reviewer; gate 6 human review still owed
at merge). X (exactly one phase; 13 files vs the ≤15-file guideline, 81 insertions — well
inside phase-size limits; independently revertible; phase 4 gates alone under `user-run`
per plan.md:8–9 and T017's "owner runs the certifying gate" — this review does NOT certify
the phase, and the phase-4 user-run gate is still owed by the owner).

## Test coverage observed

No test framework (kit convention); validation is machine checks plus the recorded
L/G/W-checklists. Re-executed by this reviewer: `pwsh -File scripts/ritual-checks.ps1` →
doc-lint OK (manifest classifies 64 shipped files, every referenced path resolves,
112 expected slot markers), enforcement-pack OK (this branch's own plan parses with both
Gate fields; one non-blocking PhaseSizeWarning on the non-phase commit `07dc07f`),
scope-check PASS on all seven phase commits including `63fed28` (13 files), verify-kit
n/a, **RESULT OK**. The Phase 4 validation table (tasks.md:236–245) matches what I
independently observed, including the manifest-sweep single-row claim (verified via
`git diff caf5fcc..HEAD -- kit-manifest.json`). The batch 1–3 user-run certification
record (tasks.md:227–234) is present and cites the six phase commits.

## Residual risk

Low and doc-shaped. F1 (diagram timing) is the only place a reader could take away a
wrong sequence, and the owning documents correct it; F2 could yield a formally incomplete
certification record on the templates' first ci-held use — worth fixing before feature
009 or the first real ci-held feature exercises them; F3 needs an owner disposition so
the sweep's own completeness standard (phase 1 F4: "sweep, not accept-as-residue") is
either met or consciously waived. Nothing blocks merge: no edited sentence misstates a
boundary, the machine verdicts are green, and the phase reverts cleanly. Before Done: the
owner's user-run gate on the phase-4 tree (plan-declared mode for this feature), then
gate 6 human review at merge.

## Fix-response log (implementer, 2026-09-08)

| # | Disposition |
|---|---|
| F1 | **Fixed** — diagram gate lines now read "owner certifies the GATE (exit code — or, plan-declared ci-held, evidence approval AFTER the phase commit below)"; timing matches DoD's ci-held arm; box alignment preserved (69-char interiors). |
| F2 | **Fixed** — both fill-in fields (`.github/PULL_REQUEST_TEMPLATE.md`, `specs/_templates/human-pr-review-template.md`) now prompt for the full triplet: run URL + green conclusion + commit sha. |
| F3 | **Fixed (owner disposition 2026-09-08: sweep)** — Territory amended in its own prior commit (`18b4749`) to add team-workflow.md and adoption/greenfield.md; the three categorical sentences (team-workflow.md ownership definition + rule 8, greenfield.md CI-second-witness bullet) now carry both certification arms with the Lite/Standard qualifier and gate-command pointer. |
| F4 | **Fixed** — both README lines restore the "Lite/Standard only" qualifier. |
| F5 | **Accepted** — pre-existing constitutional nuance (Lite has no plan.md to declare in); no phase-4 action; candidate input for the micro-lane feature (GAP-013). |
