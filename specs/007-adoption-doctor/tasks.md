# Tasks: Adoption Doctor

**Input**: Design documents from `/specs/007-adoption-doctor/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: The doctor is this feature's business-critical logic (constitution VIII); its
deterministic validation is the seeded-fixture suite (contracts V1–V10, quickstart L/W
scenarios), fail paths first. No test framework exists or is added (kit convention).

**Organization**: One delivery phase per user story, matching plan.md's phase table.
**Gate Batching: phases 1-3** (declared in plan.md). Phase commits carry `phase N`
subjects; each phase declares its Territory below (006 law — one contiguous
backtick-wrapped list right under the marker).

## Phase 1: The doctor (US1, P1) 🎯 MVP

**Goal**: `scripts/verify-kit.ps1` — five dimensions, decline logic, grandfather
warnings, fix pointers, `-Json`; validated against V1–V10.

**Independent Test**: contracts/verify-kit-cli.md V1–V10 on a hand-built adopted fixture —
every seeded break named with a fix pointer, healthy fixture zero findings, kit repo
declined.

**Territory**:

- `scripts/verify-kit.ps1`
- `scripts/doc-lint.ps1`
- `kit-manifest.json`

- [x] T001 [US1] Implement `scripts/verify-kit.ps1` per `contracts/verify-kit-cli.md` and data-model.md: decline check (research D5.1), five dimensions never short-circuiting, FAIL/WARN/ok lines with fix pointers, summary block, exit 0 iff zero FAILs, `-Root` usable from a different repo (update-kit's calling shape), `-Json` output, UTF-8/quotepath hygiene from day one (006 lessons) — dimension 2 resolves surgical class through the target's own `kit-manifest.json` with doc-lint's exact glob/specificity rules; constitution excluded from dim 2 (dim 3 owns it)
- [x] T002 [US1] Add the keep-in-sync cross-note for the structure-essentials list to `scripts/doc-lint.ps1`'s header (research D2) — no behavior change
- [x] T003 [US1] Build the scratch adopted fixture per quickstart.md and execute V1–V10, fail paths first; record verdicts + exits in this file under Phase 1 validation
- [x] T004 [US1] Verify `kit-manifest.json` classification — confirmed: `scripts/*.ps1` verbatim glob covers the doctor (doc-lint count 62→63); no edit
- [x] T005 [US1] Feedback-run `pwsh -File scripts/ritual-checks.ps1`, report output, commit as `phase 1: adoption doctor script`

**Checkpoint**: every known adoption-integrity incident class is machine-nameable.

---

## Phase 2: Lifecycle hooks (US2, P2)

**Goal**: init writes `kit-adoption.json` and finishes with the doctor; update-kit's
apply report ends with the target's verdict (exit 2 on red — research D6); adoption docs
name both moments and the gate-proof recording step.

**Independent Test**: quickstart L1–L6 — init writes the record and ends red-with-to-dos
at exit 0; filled fixture goes green; update apply ends with the verdict (exit 2 when
red); DryRun untouched; owner tier-addition passes.

**Territory**:

- `scripts/init-kit.ps1`
- `scripts/update-kit.ps1`
- `adoption/greenfield.md`
- `adoption/existing-system.md`
- `adoption/updating.md`

- [x] T006 [US2] Amend `scripts/init-kit.ps1`: write `kit-adoption.json` (data-model shape, `gateProof: []`, `kitVersionAtInit` from the constitution's kit version string — an adopted copy has no kit clone to ask, so the constitution's `**Version**:` line is the available truth, falling back to `copy`); finish by running `verify-kit.ps1` (child pwsh — it terminates with `exit`) instead of bare doc-lint, printing the verdict as the remaining-work list; init exits 0 regardless of doctor color (research D6)
- [x] T007 [US2] Amend `scripts/update-kit.ps1`: after a non-DryRun, non-Json apply, run the kit clone's `verify-kit.ps1 -Root <target>` (child pwsh) and end the report with the verdict; red doctor ⇒ exit 2 (documented "attention needed"); DryRun untouched; `-Json` callers run the doctor themselves (documented in updating.md)
- [x] T008 [P] [US2] Amend `adoption/greenfield.md`: step 3 gains "record the proof in `kit-adoption.json`" (shape pointer + no-secrets caveat); machine-assist paragraph notes the record + doctor finish (step 7 already names the doctor since 006's ritual-checks wiring)
- [x] T009 [P] [US2] Amend `adoption/existing-system.md`: step 1's "record the command + exit code" now lands in `kit-adoption.json` as the gateProof entry
- [x] T010 [P] [US2] Amend `adoption/updating.md`: report table gains the Adoption-doctor row (verdict ends the apply run; red = exit 2; green before committing the flow-down); new section 4 documents the doctor, the full `kit-adoption.json` shape (review F7 — the doctor's fix pointers target this doc), hand-creating `.kit-version`, and the roadmap-header decline caveat (contract V8)
- [x] T011 [US2] Execute quickstart L1–L6 on fresh fixtures; record outputs in this file under Phase 2 validation
- [x] T012 [US2] Feedback-run ritual-checks, report output, commit as `phase 2: lifecycle hooks`

**Checkpoint**: both integrity-changing moments end with a machine verdict.

---

## Phase 3: Wrapper membership (US3, P3)

**Goal**: `ritual-checks.ps1` runs the doctor as a fourth member iff `.kit-version`
present; contract updated.

**Independent Test**: quickstart W1–W3 — kit repo shows `n/a (kit repository)` with
unchanged RESULT; adopted fixture goes red/green with the doctor named.

**Territory**:

- `scripts/ritual-checks.ps1`
- `specs/006-verification-pack/contracts/ritual-checks-ci.md`

- [x] T013 [US3] Amend `scripts/ritual-checks.ps1`: fourth member `verify-kit` gated on `.kit-version` at `-Root`; `n/a (kit repository)` line excluded from the failure count; verdict-block format otherwise unchanged (F9 JSON-shape alignment stays deferred: the wrapper consumes the exit code, never the JSON)
- [x] T014 [US3] Amend `specs/006-verification-pack/contracts/ritual-checks-ci.md` — it documents the living wrapper, so it gains the fourth member + applicability rule with an "amended by 007" note (declared in this phase's territory; leaving it stale would be exactly the drift the kit hunts)
- [x] T015 [US3] Execute quickstart W1–W3; record outputs under Phase 3 validation
- [x] T016 [US3] Feedback-run ritual-checks (now 4 members in adopted fixtures, 3+n/a here), report output, commit as `phase 3: wrapper membership` — **batch end: ask the owner to run the certifying gate**

**Checkpoint**: integrity regressions turn adopted-project branches red unattended.

---

## Phase 4: Governance sweep (cross-cutting)

**Goal**: summaries and indexes reflect the doctor; bookkeeping closed.

**Independent Test**: ritual-checks RESULT OK; CLAUDE.md row present; roadmap flipped.

**Territory**:

- `CLAUDE.md`
- `docs/roadmap.md`
- `kit-manifest.json`

- [ ] T017 [P] Amend `CLAUDE.md` Task-Scoped Reading: the "Updating an adopted project from the kit" row also points at the doctor (`pwsh -File scripts/verify-kit.ps1` — adoption-integrity verdicts)
- [ ] T018 Flip `docs/roadmap.md` adoption-doctor row to `in progress` (`shipped` at merge)
- [ ] T019 Final `kit-manifest.json` verification sweep (expected: zero edits; doctor covered by `scripts/*.ps1`), run `pwsh -File scripts/ritual-checks.ps1`, report output, commit as `phase 4: governance sweep` — **owner runs the certifying gate**

---

## Dependencies & Execution Order

- Phases strictly sequential (constitution X); no setup/foundational phases — the
  repository is the infrastructure. P2's hooks call P1's script; P3 wraps it; P4 sweeps.
- [P] tasks touch different files and may execute in any order before the phase's single
  closing commit.
- AI review per phase: fresh-context reviewer with provenance block
  (`ai-code-review-phaseN.md`), findings dispositioned in-phase (006 law). Human review
  once at merge.

## Implementation Strategy

MVP = Phase 1 alone (the audit is the product). Batched certification after Phase 3, then
Phase 4 alone. Each phase reverts by its single commit.

## Phase validation records

*(Filled during implementation — T003, T011, T015 outputs land here.)*

### Phase 1 validation (T003, 2026-09-08)

Fixture: `git archive HEAD` copy in the session scratchpad, adopted via
`init-kit.ps1 -ProjectName Demo -Topology single -Tiers backend,database
-DeleteUnusedTemplates -NonInteractive`, roadmap header renamed to `# Roadmap — Demo`
(a real adoption's roadmap names the project — keeping the kit header would wrongly
trigger the decline path in V8b), remaining surgical markers filled with dummies,
hand-written `kit-adoption.json` (record + one exit-0 gateProof), 40-hex `.kit-version`.
Doctor invoked from the KIT's working copy with `-Root <fixture>` (update-kit's calling
shape). All verdicts per `contracts/verify-kit-cli.md`:

| # | Break | Verdict (verbatim head) | Exit |
|---|---|---|---|
| V1 | none | `verify-kit: OK — adoption integrity verified` (5 ok dimensions) | 0 |
| V2 | `.specify/templates` removed | `FAIL structure: required kit path missing: .specify/templates — fix: re-copy the kit …` | 1 |
| V3 | `{{FRONTEND_GATE}}` re-inserted in gate-command.md | `FAIL slots: docs/sdlc/gate-command.md has 1 unfilled marker(s), first: {{FRONTEND_GATE}}` | 1 |
| V4 | `TODO(RATIFICATION_DATE)` re-inserted in constitution | `FAIL constitution: … template marker(s) … — fix: ratify …` | 1 |
| V5 | record declares `frontend`, no rulebook | `FAIL record: declared tier 'frontend' has no instantiated rulebook at docs/rulebooks/frontend-rules.md` | 1 |
| V6 | `gateProof: []` | `FAIL record: no gate proof with exit code 0 … ("a gate that has never been green is not a gate")` | 1 |
| V7 | no `kit-adoption.json` | `WARN record: … (adoption predates the doctor?)` + `OK … (1 warning(s))` | 0 |
| V8a | `.kit-version` = multiline garbage | `FAIL kit-version: … not a plausible kit commit/tag (hand-edited?)` | 1 |
| V8b | `.kit-version` absent (roadmap = Demo's, so no decline) | `WARN kit-version: … (adopted by copy, never updated?)` + OK | 0 |
| V9 | kit repository itself | `verify-kit: not applicable (this is the kit template, not an adoption)` | 0 |
| V10 | V2+V3+V5 simultaneously | all three FAILs named in one run | 1 |

V1 re-run after all restores: OK, exit 0 (fixture restoration clean).

### Phase 1 validation, round 2 (post fresh-context review, 2026-09-08)

The review (`ai-code-review-phase1.md`) returned REQUEST CHANGES: F1/F2/F3 BLOCKING —
crucially, round 1's healthy V1 was achieved by dummy-filling kit-shipped menu/template
prose no real adopter edits, so dim 2 would have false-FAILed every realistic adoption.
All findings dispositioned (fix log in the review). Round 2 ran on a **realism-corrected
fixture** (`fixture007b`): real `init-kit` run *without* `-DeleteUnusedTemplates`, only
judgment slots + instantiated rulebooks + surgical sdlc docs filled; tier templates, the
menu README, and `modules/**` left exactly as shipped.

| # | Scenario | Verdict | Exit |
|---|---|---|---|
| V1+V11 | realistic healthy fixture, all kit example/menu prose retained | all 5 dimensions ok, `OK — adoption integrity verified` | 0 |
| V12a | empty (0-byte) `.kit-version` | `FAIL kit-version … (hand-edited or empty?)` — all other dimensions still reported (crash eliminated; root cause: PowerShell's AutomationNull survives a `[string]` cast in assignment — reads switched to interpolation form) | 1 |
| V12b | empty `.md` under a surgical surface | scans clean, no crash, `OK` | 0 |
| V13 | `TODO(LAST_AMENDED_DATE)` in constitution | `FAIL constitution` (generic `TODO\(` — F5) | 1 |
| V14 | record with `tiers: []` | `FAIL record: kit-adoption.json declares no tiers` (F6) | 1 |
| V8-strict | `.kit-version` = single token `garbage` | `FAIL kit-version` (F4 strict rule: 7–40 hex or v/dotted tag) | 1 |
| F2 veto | kit roadmap header kept + record present + no `.kit-version` | **audited** (WARN kit-version, `OK … (1 warning(s))`) — no false decline | 0 |
| V9 regression | kit repository | decline, zero findings | 0 |

### Phase 1 addendum (discovered during phase 2, fixed in commit `8b033b7`)

`.kit-version` is NOT a bare sha: `update-kit.ps1` writes JSON
(`{kitVersion, kitCommit, updatedOn}`). Rounds 1–2 validated dim 5 against a bare-sha
fixture update-kit never writes — the strict F4 rule would have FAILed every genuinely
updated project. Fixed: healthy = the JSON record with a 7–40-hex `kitCommit`, or a bare
hex token (hand-created per updating.md); contract V8 corrected. Validated: real JSON ok /
bare sha ok / JSON without hex kitCommit FAIL — and end-to-end in L3, where the doctor
reads the `.kit-version` update-kit itself just wrote.

### Phase 2 validation (T011, 2026-09-08)

Fixture `fixture007c`: fresh `git archive` copy + current scripts, then a real
`init-kit.ps1 -ProjectName Demo2 -Topology single -Tiers backend,database
-DeleteUnusedTemplates -NonInteractive` run; later made a clean git repo for update-kit's
preflight.

| # | Scenario | Result |
|---|---|---|
| L1 | init on fresh copy | `kit-adoption.json` written exactly (tiers backend+database, `kitVersionAtInit: "0.4.1"`, `gateProof: []`); init output ends with the doctor verdict — 11 FAILs + 1 WARN, precisely the open judgment slots + missing proof; **init exit 0** with the "remaining human work, not an init failure" note |
| L2 | judgment slots + rulebooks filled, proof recorded | doctor `OK … (1 warning(s))` — only the `.kit-version` WARN remains (created by the first update run) |
| L5 | `update-kit -DryRun` | report only; **no doctor run, no `.kit-version` written** |
| L3 | apply run | report ends with `--- adoption doctor ---` + `verify-kit: OK`; `.kit-version` written as the JSON record and dim 5 reads it green end-to-end; committed re-run: clean + green ⇒ **exit 0** |
| L4 | declared-tier rulebook deleted, committed; re-run | report ends with `verify-kit: FAIL record: declared tier 'database' …`; **exit 2** with no conflicts/surgical pending — the doctor alone drives "attention needed" |
| L6 | owner adds `frontend` to the record + instantiates the rulebook | doctor `ok record — tiers: frontend, backend, database; gate proven` → OK (record is owner-editable) |

### Phase 3 validation (T015, 2026-09-08)

| # | Scenario | Result |
|---|---|---|
| W1 | wrapper in the kit repo | verdict block: 3 member OKs + `verify-kit       n/a (kit repository)` + `RESULT OK` — kit CI behavior unchanged except the explicit n/a line |
| W2 | wrapper in the healthy adopted fixture (`-Root`, current scripts copied in) | 4 member OKs, `RESULT OK` |
| W3 | declared-tier rulebook deleted in the fixture | `verify-kit FAIL` named in the block, all members still ran, `RESULT FAIL (2 of 4 member(s) failed)`, exit 1 — doc-lint ALSO failed because the deletion broke a CLAUDE.md path reference: the two checkers catch the same incident from their respective angles |
