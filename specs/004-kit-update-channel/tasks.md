# Tasks: Kit-Update Channel

**Input**: Design documents from `/specs/004-kit-update-channel/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: The business-critical logic (the update script that guards ratified
constitutions, and the manifest completeness check) is verified by the deterministic
scripted scenarios in `quickstart.md` — the kit's established approach (002/003); there
is no unit-test framework to add tests to. Every phase ends with a verification task
that must pass before the phase's gate is requested.

**Organization**: The plan's three implementation phases (one commit + one user-run gate
each — `Gate Batching: none` per plan.md). Phase → story mapping: Phase 1 = US1,
Phase 2 = US2, Phase 3 = US3.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1–US3)

---

## Phase 1: Manifest + completeness check (US1, Priority P1) 🎯 MVP

**Goal**: Every kit-shipped file has exactly one declared update class, enforced by the
kit's own CI.

**Independent Test**: quickstart.md Phase 1 — unclassified file fails doc-lint;
double-classed file fails; known-surgical and known-verbatim spot-checks resolve
correctly.

- [x] T001 [US1] Author `kit-manifest.json` at the kit root per data-model.md: schema
      v1; verbatim entries covering all kit-owned prose and scripts; surgical entries
      (with reasons) for the known surgical set — constitution, CLAUDE.md, AGENTS.md,
      README.md, gate-command.md, repository-strategy.md, review-process.md,
      rollback-process.md, deployment-standards.md, `docs/rulebooks/**`, `modules/**`
      (FR-001, research D1)
- [x] T002 [US1] Implement the manifest completeness check in `scripts/doc-lint.ps1`
      (new section after kit-integrity): enumerate shipped surfaces per research D7,
      resolve each file against the manifest (most-specific match wins), fail on
      unclassified files and equal-specificity class conflicts; report the classified
      count (FR-002)
- [x] T003 [US1] Verification: run quickstart.md Phase 1 scenarios 1–4 (green baseline,
      unclassified-fails, double-class-fails, spot-checks); fix until all pass

**Checkpoint**: request user gate (doc-lint) + `git diff --stat` → AI review → commit.
STOP for user approval before Phase 2.

---

## Phase 2: Update script (US2, Priority P1)

**Goal**: One command updates an adopted project — verbatim copies applied, surgical
files reported never touched, local edits never clobbered, kit version recorded.

**Independent Test**: quickstart.md Phase 2 — scratch kit clone + scratch adoption:
degraded first run, clean update + idempotence, SC-002 hostile surgical sequence,
verbatim conflict + targeted `-Force`, all preflight refusals, CRLF immunity.

- [ ] T004 [US2] Implement `scripts/update-kit.ps1` per `contracts/update-kit-cli.md`:
      preflights (kit has manifest; Target ≠ Kit; Target passes kit-integrity
      essentials; Target tree clean), manifest resolution, CRLF-normalized comparison
      (research D4), three-way verbatim pass incl. absent-in-target copy
      (data-model state table, research D5), `-Force` restricted to verbatim paths,
      surgical report via `git log recordedCommit..HEAD` (research D6), `-DryRun`
      zero-write mode, `.kit-version` write (research D2), report + exit codes 0/2/1
      (FR-003..FR-008)
- [ ] T005 [US2] Add `scripts/update-kit.ps1` and `kit-manifest.json` to the
      kit-integrity required-paths list in `scripts/doc-lint.ps1`, and add manifest
      entries classifying both as verbatim in `kit-manifest.json` (FR-010; the manifest
      classifies itself and the updater so adoptions receive them)
- [ ] T006 [US2] Verification: build the scratch fixtures (kit clone + pre-004-style
      adoption under the session scratchpad) and run quickstart.md Phase 2 scenarios
      1–7; fix until all pass

**Checkpoint**: request user gate + `git diff --stat` → AI review → commit.
STOP for user approval before Phase 3.

---

## Phase 3: Flow-down guidance + anchors (US3, Priority P2)

**Goal**: The update procedure and the constitution amendment flow-down are written kit
documentation, reachable from the always-loaded anchor.

**Independent Test**: quickstart.md Phase 3 — the guidance answers the SC-004 questions
without external context; doc-lint green; CLAUDE.md row present; optional dry-run dress
rehearsal against the real expense-tracker reports sanely with zero writes.

- [ ] T007 [US3] Author `adoption/updating.md`: running the update (command, report
      reading, conflict resolution), the constitution amendment flow-down procedure
      (project's own version bump + SYNC IMPACT entry; verify demoted content lives in
      the project's rulebooks before deletion; citation sweep; project human approval
      adopts), worked example = the 2026-09-01 kit 0.3.0/0.4.0 flow-back; no backticked
      kit-internal `specs/NNN-*` paths (branch-protection portability lesson) (FR-009)
- [ ] T008 [P] [US3] Add the CLAUDE.md Task-Scoped Reading row ("Updating an adopted
      project from the kit" → `adoption/updating.md`) (FR-010)
- [ ] T009 [P] [US3] Add `adoption/updating.md` to doc-lint's required-paths list and a
      verbatim manifest entry for it
- [ ] T010 [US3] Verification: run quickstart.md Phase 3 scenarios 1–4 (doc-lint,
      content walk against SC-004, CLAUDE.md grep, dry-run dress rehearsal against
      `D:\solutions\expense-tracker` — zero writes); fix until all pass

**Checkpoint**: request user gate + `git diff --stat` → AI review → commit. Then push
and request the single feature-level human review (DoD gate 6); at merge, flip the
roadmap row 004 → shipped.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1**: none — starts on tasks.md approval.
- **Phase 2**: consumes the manifest (T001) and extends the same doc-lint file as T002 —
  starts only after Phase 1's checkpoint passes and the user approves.
- **Phase 3**: documents the script's behavior (T004) — starts only after Phase 2's
  checkpoint passes and the user approves.

### Within Each Phase

- T001 → T002 sequential in intent (the check needs the manifest to validate) though
  different files; T003 last.
- T004 → T005 sequential (T005 registers what T004 creates); T006 last.
- T007 first in Phase 3; T008/T009 are [P] (different files); T010 last.

## Implementation Strategy

1. Phase 1 → verify (T003) → user gate + diff review → AI review → commit.
2. Phase 2 → verify (T006) → user gate + diff review → AI review → commit.
3. Phase 3 → verify (T010) → user gate + diff review → AI review → commit → push →
   human review → merge (roadmap row → shipped).

### MVP Scope

Phase 1 alone ends classification-by-archaeology: even a fully manual update can then
trust the manifest. Phases 2–3 add the mechanics and the judgment guidance.

## Notes

- No [P] task shares a file with another [P] task in its phase (T008 CLAUDE.md /
  T009 doc-lint + manifest — disjoint).
- Every task names exact files; verification tasks run last per phase; commit per phase
  (constitution X, no batching declared).
