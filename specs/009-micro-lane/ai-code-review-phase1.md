# AI Code Review — 009 Micro Delivery Lane — Phase 1 (the law)

**Reviewer**: fresh-context subagent session (claude-fable-5), spawned solely for this review
**Date**: 2026-09-09
**Branches**: agentic-sdlc-kit `009-micro-lane` (tip `66b3dff`) — single repository
**Scope reviewed**: the full phase-1 commit `66b3dff` (9 files) plus the complete post-change
text of `.specify/memory/constitution.md`, `.specify/templates/micro-spec-template.md`,
`.specify/templates/spec-template.md`, `CLAUDE.md`, `docs/sdlc/branch-strategy.md`,
`docs/sdlc/critical-delivery.md`, `docs/sdlc/definition-of-done.md`, `docs/sdlc/gate-command.md`;
the feature's law/design docs (`spec.md`, `plan.md`, `tasks.md`, `research.md`, `data-model.md`,
`quickstart.md`, `contracts/micro-lane-checks.md`); `scripts/scope-check.ps1` (Territory parser,
read-only, to test the new template against the declared machine format); plan-template.md and a
repo-wide grep sweep for residual `Lite/Standard` eligibility statements; a reviewer-run
`pwsh -File scripts/ritual-checks.ps1`.
**Feature contract**: documents + one new template only; no scripts touched (phase 2), no
packages, no architecture change; phase-1 Territory = constitution, micro-spec-template,
spec-template, definition-of-done, branch-strategy, critical-delivery, gate-command, CLAUDE.md;
constitution 0.5.0 → 0.6.0 MINOR with complete SYNC IMPACT and every sync-listed mirror in the
same commit.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-fable-5 (subagent session spawned solely for this
  review, no prior context from the implementing session)
- **Implementer**: Claude Fable 5 (`Co-Authored-By: Claude Fable 5` on commit `66b3dff`,
  implementing session on branch `009-micro-lane`)
- **Inputs provided**: phase 1 diff (`git show 66b3dff`), full post-change text of all 8
  territory files, specs/009-micro-lane/{spec.md, plan.md, tasks.md, research.md, data-model.md,
  quickstart.md, contracts/micro-lane-checks.md}, scripts/scope-check.ps1 (parser),
  .specify/templates/plan-template.md, repo-wide grep sweep, reviewer-run ritual-checks
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — The amendment itself is well-constructed: Principle I's Micro arm and
Principle X's Micro lane clause say what FR-001/FR-002 require, both constants (5 files /
400 lines) appear with their exclusions in every place the tasks demand, the SYNC IMPACT entry
is honest and matches the diff, and the seven in-diff mirrors are genuinely synchronized on
the headline rules. Three blocking defects remain, all small and all fixable in-branch:
(F1) the shipped mini-spec template marks Territory with a `## Territory` heading while the
constitution, DoD, data-model, contract, and the actual scope-check parser all define the
machine-readable marker as `**Territory**:` — a mini-spec authored from the shipped template
is unreadable by the machine the lane depends on; (F2) CLAUDE.md's always-loaded "The Law"
bullet still states the pre-amendment ci-held eligibility ("Lite/Standard, plan-declared"),
contradicting both the amended constitution and CLAUDE.md's own strict rule three screens
below; (F3) four shipped instruments that state ci-held eligibility — including
plan-template.md, a constitution-sync-listed mirror that 0.5.0's own SYNC IMPACT treated as
mandatory — now contradict constitution X and sit outside every declared phase territory, so
the feature as planned can never fix them. Residual risk concentrates in F1 (the lane's
machine contract) and F3 (a sync-rule gap that needs an owner-approved territory amendment).

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-001: constitution I Micro arm ("steps (2) and (3) are skipped") + X Micro lane clause read in full — one phase, verification layers enumerated, Critical excluded, absent ⇒ Standard, promotion in place, all present. FR-002: both constants verified verbatim in constitution X ("at most **5 files** (the feature's own `specs/NNN-name/**` excluded)", "at most **400 lines** — a failure for Micro where other lanes get a warning"), micro-spec-template comment, branch-strategy.md, CLAUDE.md strict rule. FR-003: template has all six data-model sections (header w/ optional Gate Certification, Intent, Acceptance checks, Eligibility checklist, Territory, Rollback) in 55 lines — but see F1 on the Territory marker. FR-006 law half: eligibility reads "Lite, Micro, or Standard" in constitution X, gate-command.md header + section, DoD gate 3. FR-008 phase-1 slice: branch-strategy menu, DoD gates 1/3/4, critical-delivery table + item 4, CLAUDE.md structure/strict-rule/reading-table, spec-template comment — all read. FR-004/005/007-machine/FR-009 are phases 2–3 (not flagged). |
| Visual-reference match | N/A — governance documents, no UI, no `screenshots/`. |
| Feature contract held (no unapproved table/migration/permission/package) | `git show 66b3dff --stat`: 9 files, all markdown; no scripts, packages, workflows, or config touched. |
| Constitution / domain invariants | Amendment procedure followed: SYNC IMPACT updated, version footer bumped to 0.6.0, MINOR rationale (guidance materially expanded — correct per the versioning policy), prior history preserved, sync list extended with the Micro constants. Mirror completeness has one gap — F3. |
| Security (authn/authz, secrets, sensitive logging) | Checked and clean — no secrets, no credentials, no sensitive paths; the new template instructs nothing security-relevant. |
| Scope guard | Reviewer-run `ritual-checks.ps1` on the branch tip: `scope-check: PASS phase 1 commit 66b3dff (9 file(s))`; the 9th file (`specs/009-micro-lane/tasks.md`) is the implicit spec-dir entry. `enforcement-pack: OK` (only pre-existing non-blocking PhaseSizeWarning on specify commit `bcf436e`), `doc-lint: OK — 65 shipped file(s) classified` (64 → 65, the new template picked up by the `.specify/templates/**` glob as planned). `ritual-checks: RESULT OK` — matches the L8 claim in the validation record. |
| Rollback safety | Single docs-only commit; `git revert 66b3dff` restores the 0.5.0 law wholesale; nothing outside the commit references Micro yet (phase 2 checks unwritten). Clean. |

Validation-record integrity: every quote in the tasks.md Phase 1 (L1–L8) table was checked
against the actual post-change file text; all match. The record does not overclaim.

## Findings

### F1 — Shipped mini-spec template's Territory marker is unreadable by the declared machine format — BLOCKING

`.specify/templates/micro-spec-template.md` marks the Territory block as a plain heading:

```
## Territory

<!-- … scripts/scope-check.ps1 reads this block from the commit's parent (anti-widening). -->

- `path/to/file-one`
```

Every other artifact defines the machine marker as bold-colon `**Territory**:`. Constitution X
(this commit): the mini-spec "carries the feature-global **Territory** block". DoD gate 4
(this commit): "the feature-global **Territory** block in its mini-spec `spec.md`".
data-model.md: "Same block format scope-check already parses (one contiguous backtick-wrapped
list under `**Territory**:`)". contracts/micro-lane-checks.md M2: "territory read from spec.md"
under the same format. And the actual parser, `scripts/scope-check.ps1` `Get-Territory`,
matches only `^\*\*Territory\*\*:` (line 113) — a `## Territory` heading never matches. A Micro
feature authored from the shipped template would therefore declare no machine-readable
Territory at all: phase 2 implemented per its own contract would verdict "no territory
declared" on every lawful lane user, and the lane's central promise ("machine scope check
unchanged, Territory read from spec.md") fails on its own template. The template even asserts
scope-check reads "this block" — a claim that is false as shipped.
*Action: implementer — fix the template before phase 2: place a `**Territory**:` marker line
(with the backtick-wrapped entries under it) inside the section, or replace the heading with
the marker; the file is phase-1 territory, so a remediation commit on this branch is lawful.
Alternatively (owner decision) amend data-model/contract to bless `## Territory` and commit
phase 2 to parsing it — but one of the two sides must move; they currently contradict.*

### F2 — CLAUDE.md "The Law" bullet still states the pre-amendment ci-held eligibility — BLOCKING

CLAUDE.md line 26 (untouched by the commit, in phase-1 territory, and CLAUDE.md is a
constitution-sync-listed mirror):

> "the user-confirmed exit code, or (Lite/Standard, plan-declared `ci-held` — constitution X)"

The amended constitution X reads "for a Lite, Micro, or Standard feature … (for a Micro
feature: in its approved mini-spec `spec.md` …)", and CLAUDE.md's own strict rule (line 88–89,
updated in this commit) reads "Lite/Micro/Standard feature whose approved plan (Micro:
mini-spec) declares". So the always-loaded file now contradicts both the constitution it
mirrors and itself, two sections apart — exactly the drift class the atomic-sync rule exists
to prevent, in the one file every agent reads every session. "plan-declared" is also wrong for
Micro (the declaration home is the mini-spec).
*Action: implementer — update the Law bullet to "Lite/Micro/Standard, declared in the plan
(Micro: mini-spec)"; CLAUDE.md is phase-1 territory, remediate on this branch.*

### F3 — Four shipped instruments state stale ci-held eligibility and no phase territory covers them — BLOCKING

Constitution X now says ci-held is for "a Lite, Micro, or Standard feature". A repo-wide sweep
finds these shipped files still asserting the 0.5.0 eligibility, none of them inside ANY of the
three phases' declared territories (phase 2 = scripts only; phase 3 = flow.md,
review-process.md, PR templates, updating.md, roadmap.md):

- `.specify/templates/plan-template.md` line 13 ("Lite/Standard only — a Critical feature
  declaring ci-held fails scripts/enforcement-pack.ps1") and line 61, Constitution Check X
  ("for a Lite/Standard feature with `**Gate Certification**: ci-held` declared above"). This
  file is on the constitution's own "Templates requiring updates when this file changes" list
  ("Constitution Check gate must mirror the principles 1:1 … regenerate these items"), and the
  0.5.0 SYNC IMPACT entry itself listed "plan-template.md (Gate Certification field +
  Constitution Check X)" among its mirrors — the 0.6.0 entry omits it, so the SYNC IMPACT
  mirror list is incomplete by the amendment's own precedent.
- `docs/sdlc/team-workflow.md` line 11: "`ci-held` (Lite/Standard only, constitution X)".
- `docs/rulebooks/backend-rules-template.md` line 62 and
  `docs/rulebooks/mobile-rules-template.md` line 68: "plan-declared `ci-held` (Lite/Standard …)".

Spec FR-008 binds the feature: "Every summary and instrument that enumerates delivery levels
or lanes MUST carry Micro in the same change." The stale statements that ARE in phase-3
territory (flow.md 54/75, review-process.md 34, PULL_REQUEST_TEMPLATE.md 37, updating.md) are
plan-covered and not flagged; the four files above have no legal path to a fix anywhere in the
plan, so under the parent-read anti-widening rule the branch can never correct them without an
owner-approved territory amendment.
*Action: owner + implementer — amend a phase's Territory (owner approval, in a commit before
the phase commit that relies on it; phase 3 is the natural home) to add plan-template.md,
team-workflow.md, and the two rulebook templates, then sweep them; and correct the 0.6.0 SYNC
IMPACT mirror list to name plan-template.md.*

### F4 — CLAUDE.md Workflow step 4 keeps the unqualified spec→plan→tasks sequence — MINOR

CLAUDE.md line 70: "Create/update `spec.md`, then `plan.md`, then `tasks.md` (the `/speckit.*`
commands do this)" — no Micro arm, in a file inside phase-1 territory. Mitigated by the new
"Micro exception" note ten lines above, but an agent skimming the numbered workflow gets the
old law. Note the phase-3 W4 sweep ("no shipped instrument still states 'spec.md, then
plan.md, then tasks.md' without the Micro arm") cannot fix this occurrence — CLAUDE.md is not
in phase-3 territory.
*Action: implementer — add a "(Micro: mini-spec only — see Feature Structure)" arm to step 4
while remediating F2 in the same file.*

### F5 — branch-strategy.md taxonomy row and directory tree keep unconditional plan.md/tasks.md — MINOR

`docs/sdlc/branch-strategy.md` (phase-1 territory): the Branch Taxonomy row for `NNN-<name>`
still reads "full spec workflow", and the "Spec Directory Contents" tree lists `spec.md`,
`plan.md`, `tasks.md` unconditionally. The new Delivery Levels paragraph in the same file is
correct and nearby, so this is drift within one document rather than missing law.
*Action: implementer — one-line arm on the tree (e.g. "Micro: spec.md only") or a pointer from
the taxonomy row; low urgency, but the file is only in phase-1 territory.*

### F6 — Lite-vs-Micro boundary wording is softer than the spec's rule — MINOR

branch-strategy.md line 72–74: "the moment a small change alters behavior **and deserves
written, approved intent**, it is at least Micro." Spec edge case: "behavior change ⇒ at least
Micro; no behavior change … ⇒ Lite". The conjunction invites the reading that a behavior
change which "doesn't deserve" written intent may stay Lite — the loophole the lane exists to
close. The same file's Lightweight-lane paragraph ("If a 'fix' grows into behavior change …
stop and promote") supports the spec's stricter reading, so this is ambiguity, not
contradiction.
*Action: implementer — drop "and deserves written, approved intent" or invert it ("alters
behavior, it is at least Micro — behavior change is what deserves written, approved intent");
owner may instead accept the softer wording deliberately.*

### F7 — Template ships Gate Certification as a bracket placeholder rather than a prefilled default — MINOR

micro-spec-template.md: `**Gate Certification**: [user-run | ci-held]` with a comment saying
"delete for the default (user-run)". plan-template.md's convention for the same field is a
prefilled `user-run`. Under the 008 grammar (which phase 2 extends to spec.md: "case-
insensitive, comment-stripped, empty = absent, absent = user-run"), a mini-spec whose author
keeps the line but forgets to resolve the brackets carries a malformed value; a prefilled
`user-run` is fail-safe and matches the sibling template.
*Action: implementer — prefill `user-run` (keeping the comment); or none, if the owner prefers
the delete-or-fill instruction and trusts phase 2's malformed-value FAIL to catch mistakes.*

### F8 — DoD gate 2's phase-sizing reference has no Micro arm — MINOR

definition-of-done.md gate 2 grounds phase sizing in "`.specify/templates/plan-template.md`,
Controlled Delivery check" — an artifact a Micro feature never has. Micro's sizing law is
constitution X's 400-line hard bound, which gate 2 never mentions. Not a contradiction (gate 2
is vacuously satisfiable for Micro) and outside T003's named scope (gates 1/3/4), but a Micro
implementer following DoD literally is sent to a nonexistent plan.
*Action: implementer — optional one-clause arm on gate 2 ("Micro: the constitution X hard
bounds apply instead"); or none, recorded as accepted, since constitution X governs directly.*

### F9 — critical-delivery.md "Three already exist under other names" — MINOR

`docs/sdlc/critical-delivery.md` line 9: "The kit has four delivery levels. Three already
exist under other names; this file defines only the last." Lite and Standard pre-exist under
other names ("lightweight lane", "numbered-feature workflow"); Micro does not — it is newly
defined by constitution X under its own name. Cosmetic inaccuracy only.
*Action: none required; a wording touch-up ("the first three are defined elsewhere") can ride
any later commit to this file.*

### F10 — Present-tense enforcement claims precede the machine half — ACCEPTED

Constitution X ("`scripts/enforcement-pack.ps1` fails a Micro branch that violates any of
these bounds") and critical-delivery.md item 4 ("fails the branch on any of these", now
including the Micro declaration) speak in the present tense while the MicroLane check lands in
phase 2. The SYNC IMPACT entry discloses this explicitly ("The machine half … lands in this
same feature's next phase on the same branch"), matching the 008 precedent for the identical
pattern. Between phases 1 and 2 a mini-spec's ci-held declaration would also be machine-
unvalidated (the live GateCertification check reads plan.md only). Deliberate, documented
sequencing — not a defect.
*Action: none — disclosed in SYNC IMPACT; verify closure at the phase-2 review (M1–M13).*

**Checked and clean** (explicitly, per category): (a) no contradiction found between the
amended constitution and the in-diff mirrors on the headline rules — one phase, 5/400 with the
spec-dir exclusion, Critical exclusion, absent ⇒ Standard, promotion in place, batching
staying Lite/Standard ("Batched gates" wording in constitution/DoD/gate-command is correct by
design, with gate-command adding "Micro features never batch either"); (b) spec/plan/tasks
conformance of the constitutional text itself — FR-001/002 language present in full, T001–T005
delivered as written; (d) SYNC IMPACT version, MINOR rationale, machine-half disclosure, and
mirror-list-vs-diff (the list names exactly the seven mirrors the diff touches; the
incompleteness in F3 concerns files the diff should also have named); (e) certification
wording — "user-held gate certification" in the Micro clause is consistent with gate-command's
definition of user-held as covering both user-run and ci-held forms, and every ci-held passage
keeps "the agent … never claims success".

## Constitution re-check (post-implementation)

**PASS with the F1–F3 caveats.** I (Specification First): satisfied — this feature itself ran
the full Standard set, and the amendment to I is internally coherent. II (Source of Truth):
engaged and mostly honored — the atomic-sync intent is met for the in-diff mirrors; F2/F3 are
sync-rule residue (one in-territory miss, four out-of-plan misses including a sync-listed
template). III: N/A (single repo). IV: no new patterns — the level declaration reuses the
header-field idiom as planned. V: the amendment procedure was followed (SYNC IMPACT, rationale,
version bump, human-adoption path named). VI: clean. VII: N/A. VIII: law phase — validation is
the L-checklist, executed and honestly recorded; the machine half's M1–M13 correctly deferred
to phase 2. IX: pending at merge (gate 6), as planned. X: one phase implemented, commit
subject carries `phase 1`, scope-check PASS, 257 changed lines (under the 400 guideline), the
phase reverts wholesale; Gate Batching phases 1-3 and ci-held were both declared in the
approved plan before implementation — lawful for this Standard feature.

## Test coverage observed

No test framework (kit convention). Phase-1 validation = quickstart checklist L1–L8, recorded
in tasks.md with verbatim quotes; this reviewer re-verified every quoted string against the
post-change files (all present, none paraphrased into something stronger than the text) and
independently re-ran `pwsh -File scripts/ritual-checks.ps1`: doc-lint OK (65 files,
64 → 65 as predicted by L5), enforcement-pack OK (sole warning is the pre-existing
non-blocking PhaseSizeWarning on specify commit `bcf436e`), scope-check PASS on `66b3dff`,
RESULT OK — matching L8. The machine contract (M1–M13, seeded fixtures, 001–008 regression)
is phase-2 scope and correctly absent here.

## Residual risk

Concentrated in F1 and F3. F1 is the lane's machine contract: if phase 2 is implemented
against the written contract while the template ships `## Territory`, every lawful Micro
feature authored from the template is invisible to scope-check — fix the template (or
re-decide the format) before phase 2 is written, not after. F3 is a governance gap the branch
cannot legally close as planned: plan-template.md (a sync-listed mirror), team-workflow.md,
and two rulebook templates now contradict constitution X's ci-held eligibility, and no phase
territory covers them — an owner-approved territory amendment is required, and the 0.6.0 SYNC
IMPACT mirror list should be corrected in the same stroke. F2/F4/F5 are one-file wording fixes
inside phase-1 territory. Under the declared ci-held batch, merge waits for phase 3; all three
blockers can and should be remediated in-branch before the batch-end evidence is presented for
the owner's approval.

---

## Disposition (implementing session, 2026-09-09)

| # | Severity | Disposition |
|---|---|---|
| F1 | BLOCKING | **Fixed** — micro-spec-template.md now carries the machine-parsed `**Territory**:` marker (comment moved above it; heading removed), matching constitution X, DoD gate 4, data-model, contract, and `scope-check.ps1`'s parser. |
| F2 | BLOCKING | **Fixed** — CLAUDE.md "The Law" gate-command bullet now reads "Lite/Micro/Standard, `ci-held` declared in the plan — or the Micro mini-spec". |
| F3 | BLOCKING | **Held for owner approval** — plan-template.md, team-workflow.md, backend-rules-template.md, mobile-rules-template.md sit outside every phase's territory; recommendation: owner-approved amendment adding all four to phase 3's sweep territory + SYNC IMPACT mirror-list correction (constitution edit is in phase-1 territory). Requested in the phase report. |
| F4 | MINOR | **Fixed** — CLAUDE.md workflow step 4 gains the Micro arm. |
| F5 | MINOR | **Fixed** — branch-strategy taxonomy row gains the Micro arm; Micro directory-contents note added under the tree. |
| F6 | MINOR | **Fixed** — Lite/Micro boundary tightened: "behavior change ⇒ at least Micro — behavior change always gets written, approved intent". |
| F7 | MINOR | **Fixed** — template's Gate Certification line prefilled `user-run` with change/delete guidance; bracketed placeholder removed. |
| F8 | MINOR | **Fixed** — DoD gate 2 names constitution X's Micro bounds as the sizing rule for plan-less features. |
| F9 | MINOR | **Fixed** — critical-delivery wording: first three levels "defined elsewhere", Micro attributed to constitution X. |
| F10 | ACCEPTED | **No change** — present-tense enforcement claims pending the phase-2 machine half are disclosed in SYNC IMPACT (008 precedent). |
