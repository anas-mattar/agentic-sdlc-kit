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

- [x] T008 [US2] Add the mandatory `## Reviewer Provenance` block (data-model.md shape: Reviewer, Implementer, Inputs provided, verbatim attestation sentence) to `specs/_templates/ai-code-review-template.md`
- [x] T009 [US2] Add `ReviewProvenance` check to `scripts/enforcement-pack.ps1`: on `NNN-*` branches, for each review file **added** in the diff vs base (`--diff-filter=A`, research D4), require the section, a non-empty `Reviewer:` not equal to `implementer`, and the attestation sentence; failure names the file and rule — plus two hardening cases: unfilled template placeholders (`[…]` reviewer value) fail, and `specs/_templates/` is exempt
- [x] T010 [US2] Execute quickstart provenance scenarios P1–P5; record actual outputs in this file under Phase 2 validation
- [x] T011 [P] [US2] Amend `docs/sdlc/definition-of-done.md` gate 5: AI review must be produced by a fresh-context agent or second model with the provenance block; self-graded reviews are invalid; grandfather clause stated
- [x] T012 [P] [US2] Amend `docs/sdlc/review-process.md`: reviewer-separation procedure (what the reviewer is given, fresh context as minimum, second model encouraged)
- [x] T013 [US2] Verify `kit-manifest.json` classifications for the amended template and script remain correct (no new rows expected) — verified: `specs/_templates/**` and `scripts/*.ps1` globs already cover both, doc-lint still classifies 62 files
- [x] T014 [US2] Feedback-run doc-lint + enforcement-pack + scope-check on this branch, report output, commit as `phase 2: reviewer separation`

**Checkpoint**: a self-graded review can no longer be filed undetected.

---

## Phase 3: Ritual checks as CI (US3, P3)

**Goal**: one wrapper = one CI check; pushes to governed branches get automatic verdicts.

**Independent Test**: quickstart R1–R4 — wrapper aggregates all members and fails iff any
member fails; pushed violation turns the `ritual-checks` check red; fix turns it green.

**Territory**:

- `scripts/ritual-checks.ps1`
- `.github/workflows/**`
- `docs/sdlc/branch-protection.md`
- `adoption/greenfield.md`
- `adoption/existing-system.md`
- `kit-manifest.json`

> Territory amended before the phase commit (scope-check remediation path): implementation
> discovered the kit already ships `.github/workflows/doc-lint.yml` and
> `.github/workflows/enforcement-pack.yml` (feature 002). The contract's single-check
> design (`contracts/ritual-checks-ci.md`) supersedes them — keeping both would run every
> check twice and split the required-check name — so this phase **replaces** them with
> `ritual-checks.yml`, which needs the directory glob rather than the single file.

- [x] T015 [US3] Implement `scripts/ritual-checks.ps1` per `contracts/ritual-checks-ci.md`: run doc-lint, enforcement-pack, scope-check `-All`; never short-circuit; per-member verdict block; exit 0 iff all OK (members run as child pwsh processes because each terminates with `exit`)
- [x] T016 [US3] Create `.github/workflows/ritual-checks.yml` per the contract: push triggers on `[0-9][0-9][0-9]-*`, `fix/**`, `chore/**`, `docs/**` + `pull_request` to main; `ubuntu-latest`; `fetch-depth: 0`; `contents: read`; single step invoking the wrapper with `-Branch "${{ github.head_ref || github.ref_name }}"` (detached-HEAD note from the phase 1 review) — **supersedes and deletes 002's `doc-lint.yml` + `enforcement-pack.yml`** (territory amendment note above)
- [x] T017 [US3] Execute quickstart R1–R2 locally; push this branch and verify R3–R4 on the actual GitHub check; record outputs/links in this file under Phase 3 validation
- [x] T018 [P] [US3] Amend `docs/sdlc/branch-protection.md`: require the `ritual-checks` status check on protected branches (repository configuration step, host-agnostic wording per spec assumption) — includes the migration note for repos requiring the old 002 check names
- [x] T019 [P] [US3] Amend `adoption/greenfield.md` and `adoption/existing-system.md`: wiring `ritual-checks` as a required check (or invoking the wrapper from the project's CI) is part of finishing adoption; local wrapper is the CI-less fallback
- [x] T020 [US3] Classify `scripts/ritual-checks.ps1` and `.github/workflows/ritual-checks.yml` as verbatim in `kit-manifest.json` — verified covered by the existing `scripts/*.ps1` and `.github/**` verbatim globs (no manifest edit; file count stays 62: two added, two superseded files deleted)
- [x] T021 [US3] Feedback-run `pwsh -File scripts/ritual-checks.ps1`, report output, commit as `phase 3: ritual checks as CI` — **batch end: ask the owner to run the certifying gate** (quickstart "Phase gates")

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
- `docs/sdlc/definition-of-done.md`
- `docs/roadmap.md`
- `kit-manifest.json`
- `docs/sdlc/team-workflow.md`
- `specs/_templates/ai-code-review-template.md`
- `README.md`
- `docs/sdlc/critical-delivery.md`
- `docs/rulebooks/compliance-checklist-template.md`

> Territory amended before the phase commit: syncing flow.md to the post-review phase
> order (commit → machine scope check → AI review) exposed a stale clause in the DoD
> **preamble** ("MUST NOT be committed until items 1–5 are true"), written when gates 4–5
> were pre-commit eyeball checks. Gates 4–5 are now verified against the committed phase
> (a failing commit is redone). Fixing that one clause needs `definition-of-done.md` in
> this phase's territory.
>
> Second amendment (before the `phase 4 fixes` commit): the phase 4 fresh-context review
> (F5–F7) found sweep-goal stragglers outside the declared list — stale `git diff --stat`
> / self-completed-review wording in `docs/sdlc/team-workflow.md`,
> `specs/_templates/ai-code-review-template.md`, `README.md`,
> `docs/sdlc/critical-delivery.md`, and `docs/rulebooks/compliance-checklist-template.md`.
> Named files added to the territory list above (least-territory per that review's own F5
> guidance). Dogfood note: the first attempt appended these as a *separate* list after
> this note — `scope-check.ps1` correctly refused to read it (entries must be one
> contiguous list, phase 1 F1 parser) and FAILed the fixes commit, which was redone per
> the standard remediation path. The machine caught its own author.

- [x] T022 [P] Add a Task-Scoped Reading row (or amend the existing review row) in `CLAUDE.md` pointing at the ritual checks; keep it summary-only per house style — also synced Workflow steps 6–7 (commit → machine scope check → fresh-context review)
- [x] T023 [P] Sync `docs/sdlc/flow.md` step rows 3c–3e + phase-loop diagram with the machine-checked gates (summary only, owning docs prevail) and `docs/sdlc/gate-command.md` batched-gates wording — this exposed the stale DoD preamble clause fixed under the amended territory (gates 4–5 verified against the committed phase; both preamble and closing clause corrected)
- [x] T024 Flip `docs/roadmap.md` verification-pack row to `in progress` (`shipped` at merge); confirmed constitution sync-list needs no addition (research D6: scope-check/ritual-checks encode no constitutional constants — batch cap and cooling-off hours remain enforcement-pack's, already listed)
- [x] T025 Final manifest sweep in `kit-manifest.json` — verified complete with zero edits: every 006 file is classified by existing globs (`scripts/*.ps1`, `.github/**`, `.specify/templates/**`, `specs/_templates/**`, named docs/sdlc entries, `adoption/**`, `CLAUDE.md`); doc-lint classifies 62 shipped files, ritual-checks RESULT OK — commit as `phase 4: governance sweep`, **owner runs the certifying gate** (batch 1–3 + phase 4)

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

### Phase 1 validation, round 2 (post fresh-context review, 2026-09-08)

The fresh-context AI review (`ai-code-review-phase1.md`) returned REQUEST CHANGES (F1
BLOCKING + F2–F8); all findings were fixed inside phase 1 territory (disposition table in
the review's fix-response log) and the full suite re-ran on a fresh `999-scope-demo`
branch whose fixture tasks.md uses the kit's REAL layout (territory list followed by a
task checklist containing `*`, `[x]`, and `/absolute/path` in prose — the F1 blind spot):

| # | Scenario | Verdict | Exit |
|---|---|---|---|
| S1+S8 | in-territory commit, real tasks.md layout with checklist | `PASS phase 1 commit b3733fe (1 file(s))` — checklist not parsed as territory | 0 |
| S2 | stray file | `FAIL … demo/stray.txt not in territory` | 1 |
| S3 | stray + same-commit widening | `FAIL` (parent-read) | 1 |
| S4 | widening in prior commit, then stray | `PASS` | 0 |
| S5 | `fix/demo` branch | `not applicable (fix/ lane …)` | 0 |
| S6 | commit without `phase N` token | `not applicable (… not a phase commit)` (was WARN — F8 taxonomy fix) | 0 |
| S7 | rename out of territory | `FAIL … demo/moved.txt not in territory` | 1 |
| S9 | unicode path `demo/allowed/héllo café.txt` in territory | `PASS` (quotepath off — F3) | 0 |
| S10 | tasks.md deleted in a phase commit / token-less commit; re-add + stray | deleting commit `FAIL` (checked before phase attribution); `-All` over the branch exit 1 — sequence cannot stay green (F2) | 1 |
| S11 | `**Territory**:` marker with empty entry list (checkbox right after marker) | `FAIL … entry list is empty` | 1 |
| F4 | `-Commit deadbeef123` | `ERROR 'deadbeef123' does not resolve to a commit` (no stack trace) | 1 |
| BC | `-Commit 6e5988d -Branch 003-flow-efficiency-pack` | `WARN … pre-006 compatibility` (unchanged) | 0 |

### Phase 2 validation (T010, 2026-09-08)

Executed on throwaway branch `999-prov-demo` (minimal valid structure: spec.md with
`Delivery Level: Standard`, plan.md with `Gate Batching: none`, tasks.md; branch deleted
after the run). `scripts/enforcement-pack.ps1` verdicts:

| # | Setup | Result | Exit |
|---|---|---|---|
| P1 | Added review from the amended template, provenance filled, `Reviewer: fresh-context agent — Claude Fable 5 (subagent)` | OK — no ReviewProvenance failure | 0 |
| P2 | Added review with no `## Reviewer Provenance` section | `FAIL … has no '## Reviewer Provenance' section` naming the file | 1 |
| P3 | Added review with `Reviewer: implementer` | `FAIL … attests 'implementer' as reviewer` | 1 |
| P3b | Added review with the unfilled template placeholder as Reviewer | `FAIL … template placeholders must be filled` | 1 |
| P3c | Added review with a reworded attestation sentence | `FAIL … missing the verbatim attestation sentence` | 1 |
| P4 | Bad reviews deleted in a later commit (endpoint diff adds no review files) | OK | 0 |
| P5 | Run on `006-verification-pack` itself: 001–005 reviews exist at base (grandfathered by construction); this branch's added `ai-code-review-phase1.md` passes via its retrofitted provenance block | OK | 0 |

P2/P3/P3b/P3c ran as one commit adding four bad reviews: enforcement-pack reported all
four failures in a single run (each check independent, none short-circuits).

### Phase 2 validation, round 2 (post fresh-context review, 2026-09-08)

The phase 2 fresh-context review (`ai-code-review-phase2.md`) returned REQUEST CHANGES
(F1 BLOCKING + F2–F7); dispositions in its fix-response log. Re-validation on throwaway
branches `999-prov2-demo` and `docs/prov-lane-demo` (deleted after):

| # | Scenario | Verdict | 
|---|---|---|
| P6 | header `Reviewer: fresh-context agent`, provenance block `Reviewer: implementer` | `FAIL … attests 'implementer' as reviewer` — the block is checked, the header no longer shadows it (F1) |
| P7 | provenance block filled, header left as template placeholder | OK — exactly one failure in the P6+P7 combined run, and it was P6's (F1 mirror) |
| P8 | `ai-code-review-phasé3.md` (non-ASCII) without provenance | `FAIL … has no '## Reviewer Provenance' section` — quotepath off + UTF-8 console decoding (F2); before the encoding fix it still failed closed (file-missing message), never silently passed |
| P9 | grandfathered 001 review `git mv`-ed into the feature dir | `FAIL` on the rename target — AR filter (F3) |
| P10 | review added on a `docs/` branch | `FAIL` — provenance check now runs on every recognized lane (F7) |
| Regression | enforcement-pack on `006-verification-pack` after all fixes | OK (own reviews carry compliant provenance blocks) |

### Phase 3 validation (T017, 2026-09-08)

| # | Scenario | Evidence |
|---|---|---|
| R1 | `pwsh -File scripts/ritual-checks.ps1` on this branch | three `OK` member lines + `ritual-checks: RESULT OK`, exit 0 |
| R2 | single violation mid-implementation (branch-protection.md still referenced the deleted 002 workflows) | `ritual-checks: doc-lint FAIL`, other members still ran, `RESULT FAIL (1 of 3 member(s) failed)` — never short-circuits |
| R3 (green) | push of `phase 3: ritual checks as CI` (f548b1b) | GitHub check `ritual-checks` completed **success**, run 34144751539, 18s, ubuntu-latest — zero human initiation |
| R3 (red) | throwaway branch `998-ci-red-demo`: phase commit adding `demo/stray.txt` outside declared territory, pushed | GitHub check `ritual-checks` completed **failure**, run 34145125813 — CI log shows the byte-identical local verdict: `scope-check: FAIL phase 1 commit 04bda2b: demo/stray.txt not in territory` → `RESULT FAIL (1 of 3 member(s) failed)`; branch then deleted locally + remotely |
| R4 | next green push on the real branch (`phase 2 fixes`, b91bdde) | GitHub check `ritual-checks` completed **success**, run 34145110674, 16s — red→green with no human initiation |

Wrapper/CI verdict parity (contract guarantee) is demonstrated by R3-red: the CI log line
equals the local run's output verbatim, because CI executes the same wrapper command.
