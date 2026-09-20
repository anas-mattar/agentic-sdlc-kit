---

description: "Task list for feature 015 — enforcement assurance"
---

# Tasks: Enforcement Assurance

**Input**: `specs/015-enforcement-assurance/spec.md` and `plan.md` (decisions D1–D12)
**Prerequisites**: plan.md approved; Pester 5 approved as this feature's one dependency (D2)

**Tests**: This feature is tests. Every phase's deliverable is either a fixture, the machinery
that runs one, or a fix proved by one. Phase evidence — the test-first runs D11 requires, the
mutation samples SC-002 requires, measured timings — goes in `notes.md`, never here.

**Organization**: Six phases, each independently revertible, each mapped to the user stories it
serves. Phase order is value-first: the harness exists, then it proves itself on defects that
really happened, then it grows, then it changes what a verdict means.

---

## Phase 1: The harness exists and is proved once (US1)

**Purpose**: The inventory, the fixture format, the runner, the coverage reporter, and the CI
legs — demonstrated end to end on exactly one check, so the shape is reviewable before ~120
fixtures are written against it.

**Territory**:

- `tests/**`
- `kit-manifest.json`
- `scripts/update-kit.ps1`
- `scripts/doc-lint.ps1`
- `.github/workflows/enforcement-tests.yml`

- [x] T001 Write `tests/enforcement/rules.json` covering `Invoke-StructureCheck` only: one entry
      per distinct failure condition, each with a stable id, owning script and function, the law
      it enforces, and the literal message shape it emits (FR-001).
- [x] T002 Build `tests/enforcement/lib/FixtureRepo.psm1`: materialise a JSON recipe into a real
      temporary git repository — files, commits, branches, a fixture-local git identity — with
      shallow clone, absent base and corrupt object as first-class recipe states (D12, FR-005).
- [x] T003 [P] Build `tests/enforcement/lib/Harness.psm1`: run one case as a child process,
      capture stdout and exit code, compare against the case's literal expectation file. The
      module MUST NOT import or dot-source any script under test (D1, FR-006, FR-007).
- [x] T004 Define the case layout under `tests/enforcement/cases/<script>/<rule-id>/<direction>/`
      — `recipe.json`, `command.json`, `expected.txt` — and document it in a README beside it.
- [x] T005 Write the pass-and-fail case pair for every `Invoke-StructureCheck` rule in T001,
      both directions over the same recipe so a check that never ran fails the pair (D10, FR-008).
- [x] T006 Write `tests/enforcement/Coverage.Tests.ps1`: cross-check the inventory against the
      scripts' failure-emission sites, and the inventory against the cases present. Reports counts
      and names; does not fail the run yet (D8, D9).
- [x] T007 Write `tests/enforcement/Run-Tests.ps1` — the one documented local command, no network
      at run time, imports Pester with an explicit minimum version so the machine's Pester 3.4.0
      cannot satisfy it (D2, FR-018).
- [x] T008 Add the `kit-only` class to `kit-manifest.json` with its reason, and classify
      `.github/workflows/enforcement-tests.yml` under it (D3).
- [x] T009 Teach `scripts/update-kit.ps1` to skip `kit-only` paths the way it skips `generated`,
      and `scripts/doc-lint.ps1` to count `kit-only` as classified (D3).
- [x] T010 Add `.github/workflows/enforcement-tests.yml`: `ubuntu-latest` and a Windows runner,
      each installing the pinned Pester version explicitly rather than trusting the image
      (FR-017, SC-006).
- [x] T011 Prove it: invert one `Invoke-StructureCheck` condition locally, confirm a named case
      fails, restore it, confirm green. Record both runs in `notes.md` (SC-002).
- [x] T012 Confirm `update-kit.ps1 -DryRun -Target` against one adopted project reports neither
      `tests/` nor the new workflow. Record the output in `notes.md` (D3).

---

## Phase 2: The two parser fail-opens close, test-first (US2)

**Purpose**: GAP-025 and GAP-026 — the harness's first real proof, on defects that really
happened rather than invented ones.

**Territory**:

- `tests/**`
- `scripts/build-digests.ps1`
- `scripts/scope-lib.ps1`
- `docs/digests/*-digest.md`
- `scripts/markdown-lib.ps1`
- `scripts/enforcement-pack.ps1`
- `scripts/scope-check.ps1`
- `scripts/scope-check-repos.ps1`

The Territory as approved did not reach two of this phase's own tasks. T014 says to reuse
feature 014's CommonMark logic rather than write a third parser, and that logic lives in
`scripts/enforcement-pack.ps1`; sharing it means a new `scripts/markdown-lib.ps1` dot-sourced by
both, which is what `scripts/scope-lib.ps1` already exists to do for the two scope graders. T018
makes an undeclared Territory FAIL (FR-015), and that verdict is emitted by `scope-check.ps1` and
`scope-check-repos.ps1`, neither of which was listed. The enforcement-pack edit is a pure move —
the functions are unchanged, only their home is.

**Amendment approved by**: anas.m, 2026-09-19.

- [x] T013 Write the GAP-025 case: a document mentioning a comment opener inside an inline code
      span, with a digest marker after it. Demonstrate it failing against the current
      `build-digests.ps1` and record that run in `notes.md` before any fix (D11).
- [x] T014 Fix `scripts/build-digests.ps1` to treat a comment opener inside an inline code span as
      literal text, reusing feature 014's CommonMark-shaped visibility logic rather than writing a
      third line-based parser (FR-013).
- [x] T015 Regenerate the digests and confirm the marker count changes by exactly the markers the
      old parser swallowed; record before and after in `notes.md`.
- [x] T016 Write the GAP-026 case: a `tasks.md` phase whose marker reads
      `**Territory** (widened by amendment …):`. Demonstrate it failing first (D11).
- [x] T017 Fix `Get-Territory` in `scripts/scope-lib.ps1` to accept a decorated marker — annotation
      between the marker and its colon — as a declaration (FR-014).
- [x] T018 Write the second GAP-026 case: one phase declares Territory, another declares none.
      Demonstrate the current non-blocking WARN, then make it FAIL (FR-015).
- [x] T019 Add both GAPs' rules to the inventory and confirm the coverage reporter counts them.

- [x] T019a Make the near-miss loud (phase 2 review, F3): a line that begins `**Territory**` and
      carries no colon — an annotation that wraps across lines — declares nothing and is
      currently silent. Report it as a FAIL naming the line, in both scope graders, rather than
      teaching the parser to join continuation lines. Same pattern `build-digests.ps1` uses for a
      malformed digest marker (014 review F6/F7). Demonstrate it failing first (D11).

**Amendment approved by**: anas.m, 2026-09-19.

---

## Phase 3: The enforcement pack under test (US1)

**Purpose**: Fixtures for the nine checks in `scripts/enforcement-pack.ps1` — 41 measured
failure-emission sites, the largest single surface in the kit.

**Territory**:

- `tests/**`
- `scripts/enforcement-pack.ps1`
- `scripts/scope-lib.ps1`

Phase 2 widened `Get-Territory`'s marker anchor and left `Invoke-MicroLaneCheck`'s inline copy
of the same grammar strict, so the two now disagree about the same mini-spec — a divergence the
comment on that very line was written to prevent. The fix is to delete the copy rather than to
widen it, which needs both files.

**Amendment approved by**: anas.m, 2026-09-19.

- [x] T020a Close the divergence phase 2 created: `Invoke-MicroLaneCheck` parses the Territory
      block with its own strict copy of the grammar, so a decorated marker leaves the Micro
      file cap, the duplicate check and the glob check all passing vacuously. Replace the copy
      with `Get-Territory -Global` from `scripts/scope-lib.ps1`. Demonstrate it failing first
      (D11).

- [x] T020 Inventory every rule in `Invoke-StructureCheck`, `Invoke-LiteAndAbuseCheck` and
      `Invoke-MicroLaneCheck`, then write both case directions for each.
- [x] T021 Inventory and cover `Invoke-CriticalEvidenceCheck`, including both arms — solo
      substitute and team evidence — and the cooling-off boundary.
- [x] T022 Inventory and cover `Invoke-GateBatchingCheck` and `Invoke-GateCertificationCheck`.
- [x] T023 Inventory and cover `Invoke-ReviewProvenanceCheck` — the machine half of gate 5, and
      the member GAP-027 showed going silent.
- [x] T024 Inventory and cover `Invoke-AmendmentAuthorityCheck`: creation versus amendment, the
      checkbox exemption, the status-line exemption, the renumbering exemption, a record hidden
      by an unterminated comment, and a record whose commit message does not name its approver.
- [x] T025 [P] Inventory and cover `Invoke-PhaseSizeWarningCheck`.
- [x] T026 Cover the git-reality conditions feature 014 paid for in review rounds: a truncated
      object, an empty `merge-base`, a multi-parent commit, and a path affected by
      `core.quotepath` (D12).
- [x] T027 Run the coverage reporter and record in `notes.md` which enforcement-pack rules remain
      uncovered and why.

---

## Phase 4: The remaining grading scripts under test (US1)

**Purpose**: `scope-check.ps1`, `scope-check-repos.ps1`, `doc-lint.ps1`, `verify-kit.ps1`,
`build-digests.ps1`, `roadmap-claim-check.ps1`, `territory-check.ps1`, `ritual-checks.ps1`.

**Territory**:

- `tests/**`
- `scripts/ritual-checks.ps1`
- `scripts/territory-check.ps1`

CI proved what a Windows-only run could not: `Write-Host ''` emits a blank line on
`windows-latest` and nothing on `ubuntu-latest`, on identical `pwsh 7.6.5` and identical harness
code. Every one of the sixteen cases whose expectation contains an interior blank line failed on
ubuntu, and no other case did — the two sets are the same set. The divergence is in the two
scripts that print a blank line, not in the fixtures, so nothing confined to `tests/**` can fix
it honestly: normalising the blank away would blind the harness to precisely the class of
difference SC-006 exists to catch.

**Amendment approved by**: anas.m, 2026-09-19.

T036a's text is rewritten below. The diagnosis that justified the widening above was wrong, and
the task now says what was actually done. The rationale paragraph is deliberately left standing
as approved: what was believed, and on what evidence, is part of the record — the correction is
written in `notes.md` rather than over the top of it.

**Amendment approved by**: anas.m, 2026-09-20.

- [x] T036a Stop the harness losing blank lines on Linux. `Start-Process
      -RedirectStandardOutput` drops empty lines there, so `Invoke-FixtureCase` compared its
      expectation against a stream the script never printed; `System.Diagnostics.Process` with
      `ReadToEndAsync` replaces it. Add a self-test that drives `Invoke-FixtureCase` itself.
      **The two scripts are NOT touched**: the first diagnosis blamed `Write-Host ''`, and
      measuring on ubuntu 24.04 + pwsh 7.6.5 showed all four emission forms work there. The
      Territory widened by `74f690e` turned out not to be needed. The replacement carried its
      own defect — unset, `StandardOutputEncoding` decodes the child with the console codepage,
      so every em dash arrived mangled, intermittently. Both streams are pinned to UTF-8, and
      the guard test forces a non-UTF-8 console rather than inheriting one.
- [x] T036b Close the phase 4 review's F1: `doc-lint.ps1:236` — the manifest sweep declining in
      an adopted project — is a condition the script detects on its own `.kit-version` branch,
      not a printer of any accumulator. It is outside the declared idiom and outside the recall
      sweep, so `doc-lint` reports `7 of 7` against a denominator built from the covered part.
      Widen the declaration to 8 and cover the inert verdict. (`tests/**`; no amendment needed.)

- [x] T028 Inventory and cover `scripts/scope-check.ps1`, including the anti-retroactivity rule —
      a declaration that post-dates the commit it would legalise.
- [x] T029 Inventory and cover `scripts/scope-check-repos.ps1`, including a code repository on the
      wrong branch, a missing repository, and a trunk that is not `main`.
- [x] T030 [P] Inventory and cover `scripts/doc-lint.ps1`, including manifest completeness and an
      unresolvable referenced path.
- [x] T031 [P] Inventory and cover `scripts/verify-kit.ps1` across its five dimensions.
- [x] T032 [P] Inventory and cover `scripts/build-digests.ps1` beyond phase 2 — drift, bounds, and
      a near-miss marker line that must fail rather than vanish.
- [x] T033 [P] Inventory and cover `scripts/roadmap-claim-check.ps1`, including all three inert
      states, which must report `N/A` and never a silent pass.
- [x] T034 [P] Inventory and cover `scripts/territory-check.ps1`.
- [x] T035 Cover `scripts/ritual-checks.ps1` as an aggregator: one failing member fails the run,
      member names are stable, and an inert member does not mask a failing one.
- [x] T036 Run the coverage reporter and record the full uncovered list in `notes.md`.

---

## Phase 5: A run that graded nothing says so (US3)

**Purpose**: The verdict vocabulary, and the `UNGRADED` state that closes GAP-027. The only
phase whose behaviour change reaches adopted projects.

**Territory**:

- `tests/**`
- `scripts/enforcement-pack.ps1`
- `scripts/ritual-checks.ps1`
- `scripts/scope-check.ps1`
- `scripts/scope-check-repos.ps1`
- `scripts/doc-lint.ps1`
- `scripts/verify-kit.ps1`
- `scripts/build-digests.ps1`
- `scripts/roadmap-claim-check.ps1`
- `scripts/territory-check.ps1`

- [ ] T037 Write the GAP-027 cases first: a depth-1 clone with an absent base, an unresolvable
      diff base, and an unreadable parent. Demonstrate each producing `OK` today, and record those
      runs in `notes.md` before any fix (D11).
- [ ] T038 Define the vocabulary in one place — `OK`, `FAIL`, `WARN`, `PENDING`, `N/A`,
      `UNGRADED` — with `PENDING` documented as reserved and emitted by nothing (D4, D7, FR-009).
- [ ] T039 Emit `UNGRADED` from every member that can return without grading, starting with
      `Invoke-ReviewProvenanceCheck` (FR-010).
- [ ] T040 Carry the state into `scripts/ritual-checks.ps1`'s verdict block so it is visible where
      a reader and a status badge look, distinct from both `OK` and `N/A` (FR-010).
- [ ] T041 Hold the exit code unchanged on the Lite lane and prove it with a case that asserts the
      code as well as the verdict (D6, FR-011).
- [ ] T042 Confirm member names and verdicts are otherwise unchanged by running `ritual-checks` on
      the kit and on all three adopted projects, recording each result in `notes.md` (FR-012,
      SC-005).
- [ ] T043 Add the `UNGRADED` cases to the inventory and confirm coverage counts them.

---

## Phase 6: Coverage blocks, and adopters are told (US4, US5)

**Purpose**: Flip coverage from reporting to blocking now that coverage exists, sharpen the
failure reports, and write the flow-down note for the one change adopters will see.

**Territory**:

- `tests/**`
- `.github/workflows/enforcement-tests.yml`
- `scripts/enforcement-pack.ps1`
- `adoption/updating.md`
- `docs/sdlc/review-process.md`
- `docs/digests/*-digest.md`

- [ ] T044 Make `Coverage.Tests.ps1` blocking: an uncovered rule, a rule present in a script but
      absent from the inventory, and a rule with only one direction each fail the run (FR-003, D9).
- [ ] T045 Implement declared exemptions — a rule may opt out of coverage only with a written
      reason in the inventory, and every exemption prints in the harness output (FR-004).
- [ ] T046 Make every harness failure name the script, the rule id, the case, the expected verdict
      and the observed one, and print how to reproduce the fixture repository (FR-016, FR-019).
- [ ] T047 Confirm the harness does not modify the repository it runs from and does not depend on
      its branch, working tree or git identity (FR-020).
- [ ] T048 Sample-verify SC-002 across at least one rule per grading script: invert the condition,
      confirm a named case fails, restore. Record the sample and its results in `notes.md`.
- [ ] T049 Write the flow-down note in `adoption/updating.md`: what a green run meant before, what
      it means now, and what an adopter will newly see (FR-021).
- [ ] T050 Name the `UNGRADED` state in `scripts/enforcement-pack.ps1`'s description header and in
      the Lite-lane paragraph of `adoption/updating.md`, neither of which mentions it today
      (FR-022).
- [ ] T051 Add the reviewer's line to `docs/sdlc/review-process.md`: an `UNGRADED` member is not a
      pass, and a review that accepts one says why.
- [ ] T052 Regenerate the digests and confirm the freshness check is green.
- [ ] T053 Record the measured cost in `notes.md` — the harness's runtime on both CI legs against
      `ritual-checks`'s current 82.2s / 80.0s baseline — and state whether the harness runs inside
      `ritual-checks` or beside it (SC-007).

---

## Dependencies

- Phase 1 blocks everything: no case can be written before the format and runner exist.
- Phases 3 and 4 are independent of each other and of phase 2; either may be reverted alone.
- Phase 5 depends on phase 3 for the enforcement-pack cases that prove the vocabulary change
  breaks nothing else.
- Phase 6 depends on phases 2 through 5 for the coverage it makes blocking.

## Notes

- A defect found while writing a case for a script outside the current phase's Territory is
  **recorded in `notes.md`, not fixed in place**. Widening Territory mid-phase requires an
  owner-approved amendment committed before the phase commit that relies on it (constitution I;
  the check reads the declaration from the commit's parent).
- Every phase commit carries a `phase N` token in its subject so the scope check can attribute
  it, and every phase takes a fresh-context AI review with the Reviewer Provenance block before
  human review.
