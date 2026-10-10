---

description: "Task list for feature 017 — level declaration graded"
---

# Tasks: Level Declaration Graded

**Input**: `specs/017-level-declaration-graded/spec.md`, `plan.md` (decisions D1–D9), `research.md`
(R1–R10), `data-model.md`, `contracts/level-declaration-contract.md`
**Prerequisites**: spec.md and plan.md approved; no new dependency. Phase 1 additionally needs the
owner's approval of the constitution amendment before phase 2 starts (plan D1).

**Tests**: every rule ships with a passing and a failing harness fixture in the same phase as
the behaviour, expectations written by hand (spec FR-014; feature 015). Each new fixture is run
against the parent commit and must FAIL there for the behavioural rules, so it is shown to
measure something. Phase evidence goes in `notes.md`, never here.

**Organization**: five phases, each independently revertible. Phases 3 and 4 must be reverted
before phase 1 (plan, phase sizing note). Rule ids `LEVEL-001`..`LEVEL-012` are the plan's
working numbering; `tests/enforcement/rules.json` is authoritative once the cases land.

---

## Phase 1: The law — the level is a written claim, stated before it is enforced (US2)

**Purpose**: amend constitution Principle X first, because the kit must not enforce a rule it has
not ratified (plan D1, feature 014's order), and add the rationale block and marker to the spec
template. Documents only.

**Territory**:

- `.specify/memory/constitution.md`
- `.specify/templates/spec-template.md`
- `docs/sdlc/critical-delivery.md`
- `docs/sdlc/definition-of-done.md`
- `docs/sdlc/branch-strategy.md`
- `docs/digests/**`

- [x] T001 [US2] Draft the *Level declaration* clause in `.specify/memory/constitution.md`
      Principle X: a numbered feature states its level in writing against the four triggers of
      `docs/sdlc/critical-delivery.md`; a project may declare critical surfaces in its adoption
      record; a Standard or Micro feature whose Territory reaches one must be promoted, narrow
      its Territory, or carry an approved Surface Exception; a Critical feature is never failed
      by the surface floor. State plainly what a machine cannot verify: that the rationale is
      true, that the approver agreed, and that a deleted `**Rationale Rule**` line cannot be
      seen (research R4). Bump the version 0.7.0 to 0.8.0 (MINOR) and add the SYNC IMPACT REPORT
      entry, including the new constants (the four trigger keys, the marker value) in the
      `scripts/enforcement-pack.ps1` sync-list line (plan D1, research R8).
- [x] T002 [P] [US2] Add the `**Rationale Rule**: 1` header line and the `## Level Rationale`
      section (four bullets keyed `domain-invariants`, `irreversible-data`,
      `authn-authz-payment`, `auditable-evidence`, each `applies | does not apply — reason`,
      plus the `**Critical because**:` line for the all-`does not apply` Critical case) to
      `.specify/templates/spec-template.md`, with a comment pointing at the contract's
      section 2 (plan D7, research R6).
- [x] T003 [P] [US2] Mirror the clause in `docs/sdlc/critical-delivery.md`: the four triggers
      now have stable keys, the level is a written claim, and the surface floor exists.
      Name `scripts/enforcement-pack.ps1` as the enforcer without describing its internals.
      Keep every existing digest marker; add one for the new rule.
- [x] T004 [P] [US2] Mirror it in `docs/sdlc/definition-of-done.md` (the gate that reads the
      declared level) and in the level menu of `docs/sdlc/branch-strategy.md`.
- [x] T005 [US2] Regenerate the digests with `pwsh -File scripts/build-digests.ps1`, then run
      `pwsh -File scripts/ritual-checks.ps1`; `doc-lint` and `digests` must be OK (the one expected
      failure on this branch is closed by this file existing).
- [x] T006 [US2] STOP. Ask the owner to approve the amendment. Record the approver in the
      constitution's SYNC IMPACT REPORT ("Human adoption of this amendment") and name them in
      the commit. Phase 2 does not start before this. An implementing agent never approves
      its own amendment (constitution I).

---

## Phase 2: The record and its reader, with the doctor (US3)

**Purpose**: `criticalSurfaces` becomes a real, validated key, read by one function that both
the enforcement check and the doctor use. Nothing enforces yet, so no run changes.

**Territory**:

- `scripts/adoption-lib.ps1`
- `scripts/verify-kit.ps1`
- `adoption/updating.md`
- `docs/digests/**`
- `tests/**`

- [ ] T007 [P] [US3] Write the doctor cases under `tests/enforcement/cases/verify-kit/` for
      `LEVEL-011` (`pass-declared`: a valid list prints `criticalSurfaces: N declared`;
      `pass-not-declared`: no key prints `criticalSurfaces: not declared` and does not fail) and
      `LEVEL-012` (`fail-not-array`, `fail-blank-entry`, `fail-absolute-path`: each finding
      names the key and a fix). Expectations are hand-written (plan D8, spec US3 scenarios 2-3).
- [ ] T008 [US3] Run T007 against the current scripts and record in `notes.md`: the
      `fail-*` cases must show no finding today (the defect is real), the `pass-*` cases must
      already pass.
- [ ] T009 [US3] Add `Get-CriticalSurfaces` to `scripts/adoption-lib.ps1` returning `Armed`,
      `Globs`, `Declared`, `Why`, `Problems` (data-model.md). Follow `Get-DeveloperMode`'s shape
      and its degenerate-input discipline: no record, unreadable or unparsable record, root not an
      object, key absent, non-array, empty array, blank or non-string entries, duplicates
      (case-insensitive), absolute or drive-prefixed entry, a `..` segment. Update the file's
      header comment, which currently says it reads the developer declaration only. A problem
      never makes the result *more* armed than the same record without the problem.
- [ ] T010 [US3] Print the doctor lines from that reader in `scripts/verify-kit.ps1`, beside the
      existing developers block, using the reader's `Problems` verbatim. Never fail a project
      that declares none (FR-013).
- [ ] T011 [P] [US3] Add a flow-down note to `adoption/updating.md`: the optional key, its
      shape, that absence changes no verdict, and that the doctor reports it. Run
      `pwsh -File scripts/build-digests.ps1` if the adoption digest is affected.
- [ ] T012 [US3] Add `LEVEL-011` and `LEVEL-012` to `tests/enforcement/rules.json` with
      summary, law, emit anchor and notes, then run `pwsh -File tests/enforcement/Run-Tests.ps1`
      and `pwsh -File scripts/ritual-checks.ps1`. Every case passes; no existing verdict moves.

---

## Phase 3: A sub-Critical feature cannot reach a critical surface unnoticed (US1, US3, US4)

**Purpose**: the path floor in `scripts/enforcement-pack.ps1`, with its exception mechanism and
its honest non-answers, proved by fixtures including the nested multi-repo layout.

**Territory**:

- `scripts/enforcement-pack.ps1`
- `tests/**`

- [ ] T013 [P] [US1] Write the fixtures for `LEVEL-001` under
      `tests/enforcement/cases/enforcement-pack/LEVEL-001/`: `fail-standard-literal` (a Territory
      file under a surface), `fail-standard-glob-prefix` (Territory `src/**`, surface
      `src/auth/`; research R1), `fail-micro` (the global block in `spec.md`), `fail-multirepo`
      (repo-prefixed Territory and surface in the nested layout; SC-001), `pass-no-overlap`,
      `pass-critical` (same Territory, level Critical; FR-011) and `pass-case-and-slash` (a
      backslash and a different case still match). Expectations are hand-written.
- [ ] T014 [P] [US3] Write fixtures for `LEVEL-002` (`pass-no-key`, `pass-empty-list`: one
      info line, exit code and verdict unchanged) and `LEVEL-003` (`fail-malformed-list`: the
      run ends UNGRADED, exit 0, names the key).
- [ ] T015 [P] [US1] Write fixtures for `LEVEL-004` (`fail-spec-only`: armed, Standard, no
      `tasks.md` yet; `fail-near-miss`: a `**Territory**` marker with no colon): UNGRADED,
      never a pass (research R3).
- [ ] T016 [P] [US4] Write fixtures for `LEVEL-005` (`pass-live-exception`: approved exception
      for the exact path; the run lists it), `LEVEL-006` (`pass-stale-exception`: names a path
      no longer in the Territory; reported, no failure) and `LEVEL-007`
      (`fail-unapproved-exception`, `fail-placeholder-approver`, `fail-wrong-path`).
- [ ] T017 [US1] Run T013-T016 against the current script and record in `notes.md`: every
      `fail-*` that should fail must pass today (the gap is real), and every `pass-*` must
      already pass.
- [ ] T018 [US1] In `scripts/enforcement-pack.ps1`, add the Territory reader for the check: the
      union over every `## Phase N` block of `tasks.md` for Standard, the global block of
      `spec.md` for Micro, using the existing `Get-Territory` and nothing else (plan D4). Missing
      file, no block or a `NearMiss` returns "unreadable" so the caller reports UNGRADED.
- [ ] T019 [US1] Add the intersection rule (plan D3, research R1): the literal directory prefix
      of an entry, both-way prefix test, a no-prefix pattern intersects everything, `\` normalised
      to `/`, case-insensitive. Literal paths go through `Test-InTerritory`. Place it in
      `scripts/enforcement-pack.ps1` unless T018's review shows `scripts/scope-lib.ps1` is the
      right shared home, in which case stop and request a Territory amendment rather than
      editing it.
- [ ] T020 [US4] Parameterise the pattern of `Get-ConformingRecord` (default unchanged) so the
      Surface Exception approval line reuses its validation (plan D6). Every `AMEND-*` fixture
      must still pass byte-for-byte: this is the guard that the refactor changed nothing.
- [ ] T021 [US1] [US3] [US4] Add `Invoke-LevelSurfaceCheck` and call it from the `NNN-*`
      dispatch after the Structure check: read the level with `Get-DeliveryLevel`; skip Lite and
      Critical; read the surfaces with `Get-CriticalSurfaces` (phase 2); apply the verdict table
      of data-model.md; name the feature, level, path, glob and the three ways forward on failure
      (contract section 3). A Critical feature is never failed. Update the file's `.DESCRIPTION`
      block with the new member.
- [ ] T022 [US1] Add `LEVEL-001` through `LEVEL-007` to `tests/enforcement/rules.json`, then run
      `pwsh -File tests/enforcement/Run-Tests.ps1`: all LEVEL and all pre-existing cases pass,
      and the coverage test reports no rule without both directions (SC-006).
- [ ] T023 [US1] Run `pwsh -File scripts/enforcement-pack.ps1` and
      `pwsh -File scripts/ritual-checks.ps1` on this branch. This feature's own record declares
      no surfaces, so the only change is the one `not armed` line. Record it in `notes.md`.

---

## Phase 4: The level is a written claim a reviewer can falsify (US2)

**Purpose**: the rationale check in `scripts/enforcement-pack.ps1`, applied only to specs
carrying the marker (plan D7).

**Territory**:

- `scripts/enforcement-pack.ps1`
- `tests/**`

- [ ] T024 [P] [US2] Write fixtures for `LEVEL-008` (`fail-absent`: marker present, no block;
      `pass-no-marker`: a pre-rule spec with no block is exempt, FR-008), `LEVEL-009`
      (`fail-missing-trigger` for each of the four keys, `fail-no-reason`, `fail-bad-verdict`) and
      `LEVEL-010` (`fail-standard-applies`, `fail-critical-all-no`, `pass-critical-because`,
      `pass-critical-applies`, `pass-standard-all-no`). Expectations are hand-written.
- [ ] T025 [US2] Run T024 against the current script and record in `notes.md`: the `fail-*`
      cases pass today (the gap is real), the `pass-*` cases already pass.
- [ ] T026 [US2] Add `Invoke-LevelRationaleCheck` to `scripts/enforcement-pack.ps1`, called from
      the `NNN-*` dispatch after the surface check: read the marker, the section and its four
      bullets from visible text only (comment-stripped, like `Get-DeliveryLevel`); apply the
      consistency rules of data-model.md; every failure names the feature and the trigger or the
      contradiction (contract section 3). Update the file's `.DESCRIPTION` block.
- [ ] T027 [US2] Add `LEVEL-008` through `LEVEL-010` to `tests/enforcement/rules.json` and run
      `pwsh -File tests/enforcement/Run-Tests.ps1`. Everything passes, including every phase 3
      case and every pre-existing `enforcement-pack` case.
- [ ] T028 [US2] Run `pwsh -File scripts/ritual-checks.ps1` on this branch. This spec carries no
      marker (it predates the rule), so nothing changes; record that in `notes.md`.

---

## Phase 5: Flow-down and bookkeeping

**Purpose**: tell adopters, prove no adopted project's verdict moves, close the roadmap row.
No kit script changes.

**Territory**:

- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/digests/**`
- `kit-manifest.json`

- [ ] T029 Run the updated scripts over each of the three adopted projects, read-only, and
      compare every verdict with its current one (SC-004). Expect no new failure and exactly one
      new informational line each. Record the table in `notes.md`. A project whose verdict
      moves is a finding to report, not to round.
- [ ] T030 [P] Finish the flow-down note in `adoption/updating.md`: which scripts change, that
      no surgical file is touched, how to declare `criticalSurfaces`, and that the spec template
      gained the rationale block.
- [ ] T031 [P] Confirm every file the feature added or changed that ships to adopters is
      classified in `kit-manifest.json`; change it only if a file is new and unclassified.
- [ ] T032 Regenerate the digests (`pwsh -File scripts/build-digests.ps1`), flip the roadmap row
      for GAP-023 to `shipped` with its spec link unbracketed, and add the decisions-log entry
      (what shipped, what stays open by decision: the rationale is a claim, the marker can be
      deleted, the prefix rule over-reports).
- [ ] T033 Run `pwsh -File scripts/ritual-checks.ps1` and
      `pwsh -File tests/enforcement/Run-Tests.ps1`. Every member OK. Then stop and ask the owner
      to run the gate.

---

## Dependencies & Execution Order

- Phase 1 first, and T006's approval gates everything after it.
- Phase 2 needs phase 1; phases 3 and 4 need phase 2's reader (phase 4 does not call it, but
  shares the dispatch site with phase 3, so run it after).
- Phase 5 needs all four.
- Within a phase, fixtures are written and shown failing before the behaviour lands. `[P]` tasks
  touch different files.

## Implementation Strategy

MVP is phases 1-3: the law, the record, and the path floor. That closes the gap's silent half.
Phase 4 adds the written claim that catches what no path glob can. Stop after each phase for the
owner's gate; one phase at a time, never ahead.
