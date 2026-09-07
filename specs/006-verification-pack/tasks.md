# Tasks: Verification Pack

**Input**: Design documents from `/specs/006-verification-pack/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: The checks are this feature's business-critical logic (constitution VIII). Their
deterministic validation is the seeded-violation scenario suite in `quickstart.md` — executed
as explicit tasks inside each story, fail paths first. No test framework exists or is added.

**Organization**: One delivery phase per user story, in priority order, matching plan.md's
phase table 1:1. **Gate Batching: phases 1-3** (declared in plan.md). Phases below double as
this feature's delivery phases — commit subjects must carry `phase N` (research D2).

**Dogfooding note**: each phase declares its own **Territory** using the syntax this feature
introduces (data-model.md). Until `scope-check.ps1` exists the declarations are inert prose;
from phase 1 onward the script must PASS against this very branch's phase commits — that run
is part of each phase's validation. The feature's own spec directory is implicit territory.

## Phase 1: Machine scope check (US1, P1) 🎯 MVP

**Goal**: `tasks.md` territory declarations + `scripts/scope-check.ps1`; DoD gate 4 and the
review process say the scope check is machine-run.

**Independent Test**: quickstart S1–S7 — seeded stray file FAILs naming the file; same-commit
territory widening still FAILs; Lite lane not-applicable; pre-006 features only WARN.

**Territory**:

- `.specify/templates/tasks-template.md`
- `scripts/scope-check.ps1`
- `docs/sdlc/definition-of-done.md`
- `docs/sdlc/review-process.md`
- `kit-manifest.json`

- [x] T001 [US1] Add the per-phase `**Territory**:` declaration (syntax, glob semantics, implicit spec-dir entry, amendment rule per research D3) to `.specify/templates/tasks-template.md`, replacing nothing — additive section in the phase blocks and Notes
- [x] T002 [US1] Implement `scripts/scope-check.ps1` per `contracts/scope-check-cli.md`: lane classification, phase attribution from commit subject (`-Phase` override), parent-read of tasks.md (`<commit>^:` fallback `<commit>:`), rename/delete handling, verdicts and exit codes per data-model.md, `-All` mode over merge-base..HEAD
- [x] T003 [US1] Execute quickstart scope-check scenarios S1–S7 on a throwaway `999-scope-demo` branch and the backward-compat WARN run against a pre-006 feature branch; record actual outputs in this file under Phase 1 validation
- [x] T004 [P] [US1] Amend `docs/sdlc/definition-of-done.md` gate 4: scope check = `scope-check.ps1` verdict (PASS required; WARN allowed only for pre-006 features), owner still approves the phase; remediation path = revert or prior-commit territory amendment
- [x] T005 [P] [US1] Amend `docs/sdlc/review-process.md` scope-check section to reference the script and the territory-amendment remediation path
- [x] T006 [US1] Classify `scripts/scope-check.ps1` as verbatim in `kit-manifest.json` — verified already covered: the existing `scripts/*.ps1` verbatim glob classifies it (doc-lint manifest count rose 61→62); no manifest edit needed
- [x] T007 [US1] Run `pwsh -File scripts/doc-lint.ps1` and `pwsh -File scripts/enforcement-pack.ps1` (agent feedback run), run `scripts/scope-check.ps1` against this branch's phase 1 commit, report all output, commit as `phase 1: machine scope check`

**Checkpoint**: scope creep is machine-detectable; feature valuable if stopped here.

---

## Phase 2: Reviewer separation (US2, P2)

**Goal**: Reviewer Provenance block in the AI review template; enforcement pack fails newly
added reviews without it; DoD gate 5 says reviews are never self-graded.

**Independent Test**: quickstart P1–P5 — review missing provenance FAILs; `Reviewer: implementer`
FAILs; branch adding no reviews passes; `main` (001–005 reviews) passes untouched.

**Territory**:

- `specs/_templates/ai-code-review-template.md`
- `scripts/enforcement-pack.ps1`
- `docs/sdlc/definition-of-done.md`
- `docs/sdlc/review-process.md`
- `kit-manifest.json`

- [ ] T008 [US2] Add the mandatory `## Reviewer Provenance` block (data-model.md shape: Reviewer, Implementer, Inputs provided, verbatim attestation sentence) to `specs/_templates/ai-code-review-template.md`
- [ ] T009 [US2] Add `ReviewProvenance` check to `scripts/enforcement-pack.ps1`: on `NNN-*` branches, for each review file **added** in the diff vs base (`--diff-filter=A`, research D4), require the section, a non-empty `Reviewer:` not equal to `implementer`, and the attestation sentence; failure names the file and rule
- [ ] T010 [US2] Execute quickstart provenance scenarios P1–P5; record actual outputs in this file under Phase 2 validation
- [ ] T011 [P] [US2] Amend `docs/sdlc/definition-of-done.md` gate 5: AI review must be produced by a fresh-context agent or second model with the provenance block; self-graded reviews are invalid; grandfather clause stated
- [ ] T012 [P] [US2] Amend `docs/sdlc/review-process.md`: reviewer-separation procedure (what the reviewer is given, fresh context as minimum, second model encouraged)
- [ ] T013 [US2] Verify `kit-manifest.json` classifications for the amended template and script remain correct (no new rows expected)
- [ ] T014 [US2] Feedback-run doc-lint + enforcement-pack + scope-check on this branch, report output, commit as `phase 2: reviewer separation`

**Checkpoint**: a self-graded review can no longer be filed undetected.

---

## Phase 3: Ritual checks as CI (US3, P3)

**Goal**: one wrapper = one CI check; pushes to governed branches get automatic verdicts.

**Independent Test**: quickstart R1–R4 — wrapper aggregates all members and fails iff any
member fails; pushed violation turns the `ritual-checks` check red; fix turns it green.

**Territory**:

- `scripts/ritual-checks.ps1`
- `.github/workflows/ritual-checks.yml`
- `docs/sdlc/branch-protection.md`
- `adoption/greenfield.md`
- `adoption/existing-system.md`
- `kit-manifest.json`

- [ ] T015 [US3] Implement `scripts/ritual-checks.ps1` per `contracts/ritual-checks-ci.md`: run doc-lint, enforcement-pack, scope-check `-All`; never short-circuit; per-member verdict block; exit 0 iff all OK
- [ ] T016 [US3] Create `.github/workflows/ritual-checks.yml` per the contract: push triggers on `[0-9][0-9][0-9]-*`, `fix/**`, `chore/**`, `docs/**` + `pull_request` to main; `ubuntu-latest`; `fetch-depth: 0`; `contents: read`; single step invoking the wrapper
- [ ] T017 [US3] Execute quickstart R1–R2 locally; push this branch and verify R3–R4 on the actual GitHub check; record outputs/links in this file under Phase 3 validation
- [ ] T018 [P] [US3] Amend `docs/sdlc/branch-protection.md`: require the `ritual-checks` status check on protected branches (repository configuration step, host-agnostic wording per spec assumption)
- [ ] T019 [P] [US3] Amend `adoption/greenfield.md` and `adoption/existing-system.md`: wiring `ritual-checks` as a required check (or invoking the wrapper from the project's CI) is part of finishing adoption; local wrapper is the CI-less fallback
- [ ] T020 [US3] Classify `scripts/ritual-checks.ps1` and `.github/workflows/ritual-checks.yml` as verbatim in `kit-manifest.json`
- [ ] T021 [US3] Feedback-run `pwsh -File scripts/ritual-checks.ps1`, report output, commit as `phase 3: ritual checks as CI` — **batch end: ask the owner to run the certifying gate** (quickstart “Phase gates”)

**Checkpoint**: a branch that skipped the ritual is mechanically distinguishable from one that passed.

---

## Phase 4: Governance sweep (cross-cutting)

**Goal**: every summary and index reflects the machine-checked gates; bookkeeping closed.

**Independent Test**: doc-lint OK; flow.md/CLAUDE.md mention the checks where their tables
summarize gates 4–5; roadmap row flipped; ritual-checks RESULT OK on the branch.

**Territory**:

- `CLAUDE.md`
- `docs/sdlc/flow.md`
- `docs/sdlc/gate-command.md`
- `docs/roadmap.md`
- `kit-manifest.json`

- [ ] T022 [P] Add a Task-Scoped Reading row (or amend the existing review row) in `CLAUDE.md` pointing at the ritual checks; keep it summary-only per house style
- [ ] T023 [P] Sync `docs/sdlc/flow.md` step rows 3b–3d wording with the machine-checked gates (summary only, owning docs prevail) and `docs/sdlc/gate-command.md` where it names the scope check
- [ ] T024 Flip `docs/roadmap.md` verification-pack row to `in progress → shipped` at merge; confirm constitution sync-list needs no addition (research D6) and state that in the commit message
- [ ] T025 Final manifest sweep in `kit-manifest.json` (all 006 files classified), run `pwsh -File scripts/ritual-checks.ps1`, report output, commit as `phase 4: governance sweep` — **ask the owner to run the certifying gate**

---

## Dependencies & Execution Order

- Phase 1 → Phase 2 → Phase 3 → Phase 4, strictly sequential (one approved phase at a time,
  constitution X); no setup/foundational phases — the repository is the infrastructure.
- Phase 2's enforcement-pack amendment is independent of Phase 1's script, but the batch order
  is fixed by priority; Phase 3's wrapper depends on Phases 1–2 existing; Phase 4 depends on all.
- [P] tasks within a phase touch different files and may be executed in any order before the
  phase's closing commit task; every phase ends in exactly one commit.
- Human review: once, at merge (DoD gate 6). AI review: per phase, from the amended template
  starting the moment Phase 2 lands (Phases 1–2 reviews use the pre-006 template lawfully;
  Phase 3–4 reviews must carry provenance).

## Implementation Strategy

MVP = Phase 1 alone (the scope check delivers standalone value). Batched certification: owner
gates once after Phase 3 (batch declared in plan.md), then once after Phase 4. Stop at any
checkpoint; each phase reverts cleanly by its single commit.

## Phase validation records

*(Filled during implementation — T003, T010, T017 outputs land here.)*

### Phase 1 validation (T003, 2026-09-08)

Executed on throwaway branch `999-scope-demo` (Territory: `demo/allowed/**`; branch deleted
after the run). Every verdict matched `contracts/scope-check-cli.md`:

| # | Commit under test | Output (verbatim) | Exit |
|---|---|---|---|
| S1 | `phase 1: in territory` (adds `demo/allowed/a.txt`) | `scope-check: PASS phase 1 commit 670d4e1 (1 file(s))` | 0 |
| S2 | `phase 1: stray` (adds `demo/stray.txt`) | `scope-check: FAIL phase 1 commit 8839e48: demo/stray.txt not in territory` + remediation line | 1 |
| S3 | stray file **and** territory widened in the same commit | `scope-check: FAIL phase 1 commit 03cf2b0: demo/stray2.txt not in territory` (parent-read blocks retroactive legalization) | 1 |
| S4 | widening committed first, stray committed after | `scope-check: PASS phase 1 commit c36818b (1 file(s))` | 0 |
| S5 | `fix/demo` branch | `scope-check: not applicable (fix/ lane — enforcement-pack's Lite-lane checks apply instead)` | 0 |
| S6 | subject without `phase N` token | `scope-check: WARN commit 41e33a0: no 'phase N' token in the commit subject … non-blocking, pre-006 compatibility` | 0 |
| S7 | `git mv demo/allowed/a.txt demo/moved.txt` as phase 1 | `scope-check: FAIL phase 1 commit 61347bf: demo/moved.txt not in territory` | 1 |
| BC | pre-006 commit `6e5988d` (`003 phase 3`), `-Branch 003-flow-efficiency-pack` | `scope-check: WARN commit 6e5988d: no territory declared for phase 3 in specs/003-flow-efficiency-pack/tasks.md … non-blocking, pre-006 compatibility` | 0 |
