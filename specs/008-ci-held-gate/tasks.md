# Tasks: CI-Held Certifying Gate

**Input**: Design documents from `/specs/008-ci-held-gate/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: The enforcement check is business-critical logic (constitution VIII); its
deterministic validation is the seeded G1–G6 plan scenarios. The law's validation is the
read-verified L-checklist with quotes recorded. No test framework (kit convention).

**Organization**: One delivery phase per plan-table row. **Gate Batching: phases 1-3**
(declared in plan.md); **Gate Certification: user-run** — this feature is delivered under
the current law (research D7). Phase commits carry `phase N` subjects; Territory per phase
(006 law — one contiguous backtick-wrapped list under the marker).

## Phase 1: The law (US1, P1) 🎯 MVP

**Goal**: constitution X's CI-held clause (0.4.1 → 0.5.0, MINOR) and every sync-listed
mirror, in one atomic commit.

**Independent Test**: quickstart L1–L8 — every boundary present in every mirror, quotes
recorded; ritual checks green.

**Territory**:

- `.specify/memory/constitution.md`
- `.specify/templates/plan-template.md`
- `docs/sdlc/definition-of-done.md`
- `docs/sdlc/gate-command.md`
- `docs/sdlc/critical-delivery.md`
- `CLAUDE.md`

- [x] T001 [US1] Amend `.specify/memory/constitution.md`: CI-held certification clause appended to X (boundaries per research D2: Lite/Standard + declaration + owner approval on the evidence triplet + agent obligations unchanged + Critical excluded + absent = user-run); SYNC IMPACT entry (0.4.1 → 0.5.0 MINOR, rationale, mirror list naming the phase-2 enforcement half as landing next phase same branch, human-adoption note recording the owner's 2026-09-08 approval); version footer bumped; Rationale paragraph extended (trust boundary stays human, asynchronously)
- [x] T002 [P] [US1] Amend `.specify/templates/plan-template.md`: `**Gate Certification**: user-run` header field (comment documenting values/exclusion) + Constitution Check X row carries both the batched and ci-held arms
- [x] T003 [P] [US1] Amend `docs/sdlc/definition-of-done.md` gate 3: the ci-held option with identical boundaries; batching composition stated (one batch-end evidence approval)
- [x] T004 [P] [US1] Amend `docs/sdlc/gate-command.md`: new "CI-held certification (Lite/Standard only)" section — evidence triplet, worked approval-record example, kit's-own-evidence note (`ritual-checks`), red-then-green re-run visibility rule, user-run always lawful, Critical exclusion cross-ref
- [x] T005 [P] [US1] Amend `docs/sdlc/critical-delivery.md` item 4: CI-held exclusion beside the no-agent-gates and no-batching rules ("both gate frequency and gate *execution* are part of that boundary")
- [x] T006 [P] [US1] Amend `CLAUDE.md` strict rule: the ci-held arm (report the triplet, request the owner's approval — never claim success yourself)
- [x] T007 [US1] Execute quickstart L1–L8; record under Phase 1 validation; commit as `phase 1: constitution X CI-held clause (0.5.0) + mirrors`

**Checkpoint**: the law exists, complete and self-consistent; nothing enforces or uses it yet.

---

## Phase 2: The machine check (US3, P3) — ordered before US2 per plan

**Goal**: enforcement-pack `GateCertification` check per the contract.

**Independent Test**: contract G1–G6 seeded plans; regression on 001–007 (absent lines pass).

**Territory**:

- `scripts/enforcement-pack.ps1`

- [x] T008 [US3] Add `Invoke-GateCertificationCheck` to `scripts/enforcement-pack.ps1` (GateBatching parser idiom: comment-strip, absent = user-run; malformed FAIL naming legal values; ci-held + Critical FAIL citing X's exclusion); wire into the `NNN-*` dispatch; header .DESCRIPTION updated
- [x] T009 [US3] Execute contract G1–G6 on seeded fixture plans + regression (this branch, 003, 007); record under Phase 2 validation — also made this feature's own plan declare `**Gate Certification**: user-run` explicitly (D7 dogfooding, the field's first real use)
- [x] T010 [US3] Feedback-run ritual-checks, report, commit as `phase 2: GateCertification enforcement`

**Checkpoint**: a Critical feature can no longer quietly adopt ci-held.

---

## Phase 3: The delivery vehicle (US2, P2)

**Goal**: the project-gate workflow template for adopted projects + wiring law.

**Independent Test**: quickstart W-G1–W-G3 — fixture instantiation valid; inert in the kit;
manifest resolves the template surgical.

**Territory**:

- `.github/workflows/project-gate.yml.template`
- `kit-manifest.json`
- `docs/sdlc/gate-command.md`
- `docs/sdlc/branch-protection.md`

- [ ] T011 [US2] Create `.github/workflows/project-gate.yml.template`: governed-branch push triggers, `{{GATE_CHAIN}}`/`{{GATE_WORKDIR}}` slots, minimal permissions, injection-safe (env indirection — 006 lesson), header comment (copy → fill → secrets live in the CI store, never in the file/evidence)
- [ ] T012 [US2] Add the specific surgical row for the template to `kit-manifest.json` (out-ranks `.github/**` verbatim; verify with doc-lint's resolution)
- [ ] T013 [P] [US2] Amend `docs/sdlc/gate-command.md`: wiring instructions (copy, fill, push, where the triplet reads off the run page); amend `docs/sdlc/branch-protection.md`: recommend requiring the project-gate check where wired (never mandated)
- [ ] T014 [US2] Execute quickstart W-G1–W-G3; record under Phase 3 validation; feedback-run ritual-checks, report, commit as `phase 3: project-gate workflow template` — **batch end: ask the owner to run the certifying gate (user-run — research D7)**

**Checkpoint**: adopters have a paved road from "my gate is a build chain" to "evidence exists".

---

## Phase 4: Governance sweep (cross-cutting)

**Goal**: summaries and flow-down told; bookkeeping closed.

**Independent Test**: ritual-checks green; flow.md 3b row carries the option; updating.md
tells adopters how the amendment flows down; roadmap flipped.

**Territory**:

- `docs/sdlc/flow.md`
- `adoption/updating.md`
- `docs/roadmap.md`
- `kit-manifest.json`
- `docs/sdlc/branch-strategy.md`
- `docs/sdlc/review-process.md`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `specs/_templates/human-pr-review-template.md`
- `specs/_templates/rollback-template.md`
- `README.md`
- `docs/rulebooks/backend-rules-template.md`
- `docs/rulebooks/mobile-rules-template.md`
- `docs/rulebooks/compliance-checklist-template.md`

> Territory widened at specify-stage fix time (phase 1 review, F4 — owner disposition:
> sweep, not accept-as-residue): the un-swept instruments still stating the categorical
> user-run rule — above all the PR/human-review templates whose mandatory exit-code field
> a ci-held feature cannot truthfully fill — are phase 4's job, declared here before any
> phase-4 commit.

- [ ] T015 [P] Amend `docs/sdlc/flow.md`: row 3b (gate) carries the ci-held option — AND the phase-loop diagram's gate line AND the Lane-variations list (a ci-held sibling bullet beside Batched gates) — phase 1 review F5's widened scope
- [ ] T016 [P] Amend `adoption/updating.md`: flow-down note — the X amendment arrives via re-expression (§2), what an adopting project's own MINOR bump adopts, and that nothing changes until they ratify it
- [ ] T016b [P] Sweep the F4 instruments (phase 1 review): `.github/PULL_REQUEST_TEMPLATE.md` + `specs/_templates/human-pr-review-template.md` gate fields gain the ci-held alternative ("EXIT: ___ — or ci-held: run URL + commit sha"); `docs/sdlc/branch-strategy.md` merge condition and `docs/sdlc/review-process.md` step 1 qualified; `README.md` countermeasure row, the two rulebook-template gate items, and `specs/_templates/rollback-template.md` qualified the same way
- [ ] T017 Flip `docs/roadmap.md` GAP-012 row to `in progress`; final manifest sweep (expect: only phase 3's row); run ritual-checks, report, commit as `phase 4: governance sweep` — **owner runs the certifying gate**

---

## Dependencies & Execution Order

- Phases strictly sequential (constitution X); phase 1 is atomic by design (the sync rule);
  phase 2 polices the law before phase 3 encourages reliance on it; phase 4 depends on all.
- [P] tasks touch different files within a phase, before its single closing commit.
- AI review per phase: fresh-context reviewer with provenance block, findings dispositioned
  in-phase (006 law). Human review once at merge — which, with the owner's phase-1
  approval, constitutes the amendment's required human adoption (research D2).

## Implementation Strategy

MVP = phase 1 (the law stands alone; user-run remains default everywhere). Batched
certification after phase 3, then phase 4 alone — both under the CURRENT user-run law.

## Phase validation records

*(Filled during implementation — T007, T009, T014 outputs land here.)*

### Phase 1 validation (T007, 2026-09-08)

| # | Assertion | Verified |
|---|---|---|
| L1 | X clause carries all six boundaries: "Lite or Standard feature … MAY declare", "before the first phase it governs", "owner's **recorded approval on the evidence triplet**", "the agent's obligations are unchanged — it MUST NOT claim success", "Critical features MUST NOT declare or use", "Absent a declaration, the value is `user-run`" | constitution X, CI-held certification clause |
| L2 | SYNC IMPACT: 0.4.1 → 0.5.0 MINOR, rationale, full mirror list (plan-template, DoD, gate-command, critical-delivery, CLAUDE.md), enforcement half named as next-phase-same-branch, human adoption recorded (owner approval 2026-09-08 + gate-6 review at merge); footer `**Version**: 0.5.0` | constitution header + line 279 |
| L3 | Gate 3 "CI-held option (Lite/Standard only)": triplet, per-phase approval, batch composition ("one approval on the batch-end commit's evidence"), any-other-commit-certifies-nothing, agent never claims success, user-run always lawful, Critical exclusion + enforcement pointer | definition-of-done.md |
| L4 | gate-command.md section: numbered triplet, worked example record ("Gate 3 certified (ci-held): run …, conclusion success, commit `abc1234` …"), kit's-own-evidence = `ritual-checks`, red-then-green re-run rule with visibility, boundaries paragraph | gate-command.md |
| L5 | critical-delivery item 4 excludes both `**Gate Batching**` and `**Gate Certification**: ci-held`, enforcement named | critical-delivery.md |
| L6 | plan-template: `**Gate Certification**: user-run` field with values/exclusion comment; Constitution Check X row carries both arms | plan-template.md |
| L7 | CLAUDE.md strict rule: ci-held arm, "you still never claim success yourself" | CLAUDE.md |
| L8 | ritual-checks after the full amendment: doc-lint OK · enforcement-pack OK · scope-check OK · verify-kit n/a · RESULT OK | live run |

`CI-held certification` present in all five law files (grep counts 5/2/3/1/2) +
`Gate Certification` in CLAUDE.md and plan-template.

### Phase 1 validation, round 2 (post fresh-context review, 2026-09-08)

The law review (`ai-code-review-phase1.md`) returned REQUEST CHANGES: F1–F3 BLOCKING —
the amendment added the new rule everywhere but left three OLD categorical statements
standing inside the amended files themselves. All dispositioned (fix-response log in the
review). Re-validation adds the reviewer's prescribed absence check:

| # | Check | Result |
|---|---|---|
| F1 | CLAUDE.md Law bullet | both certification arms; "You never claim success" categorical |
| F2 | gate-command preamble + Agent-run-gates | both arms in the preamble; agent-run sentence narrowed to "an agent-run gate NEVER certifies in either mode" |
| F3 | DoD preamble | ci-held timing arm present ("necessarily lands **after** the phase/batch-end commit") |
| F6 | constitution sync list | names the Gate Certification legal values + Critical exclusion |
| F7/F9/F11 | plan-template timing sentence · strict-rule batch variant · `<owner>, <date>` example | present |
| Absence sweep | `grep -n "user-confirmed exit code\|user's exit code\|gate run by the user" ` over the six amended files | zero un-qualified categorical statements remain (every hit sits inside a both-arms sentence) |
| L8 regression | ritual-checks after fixes | RESULT OK |

### Phase 2 validation (T009, 2026-09-08)

Seeded fixture feature `specs/999-gc-demo` (spec + plan + tasks, deleted after);
`enforcement-pack.ps1 -Branch 999-gc-demo` per scenario:

| # | Plan/spec state | Verdict |
|---|---|---|
| G1 | no declaration line | OK (user-run default) |
| G2 | `user-run` | OK |
| G3 | `ci-held` + Delivery Level Standard | OK |
| G4 | `ci-held` + Delivery Level Critical | `FAIL … Critical features MUST NOT use CI-held certification … (constitution X …; critical-delivery.md item 4)` |
| G5 | `ci-hold` (malformed) | `FAIL … must be 'user-run' or 'ci-held'` |
| G6 | `ci-held <!-- comment -->` | OK (comment stripped, value parsed) |
| Regression | this branch (explicit `user-run` after the D7 dogfood edit), 003, 007 (absent lines) | all OK |
