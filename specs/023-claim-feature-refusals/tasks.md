---

description: "Task list for feature 023 — claim-feature.ps1's refusals reach their own message and exit"
---

# Tasks: claim-feature.ps1's refusals reach their own message and exit

**Input**: `specs/023-claim-feature-refusals/spec.md`, `plan.md` (decisions D1–D7)
**Prerequisites**: spec.md approved (anas.m, 2026-10-12); plan.md approved, including D1 (a copy of `Stop-Refused`) and D2
(site 135 fixtured through `originPushUrl`, as amended) before phase 1 starts; no new dependency, no new script file.
**Amendment approved by**: anas.m, 2026-10-13

**Tests**: every reachable refusal ships with a passing and a failing harness fixture in the same phase as the behaviour,
expectations written by hand (feature 015). New fixtures are run against the parent commit before the code changes and
must fail there, so each is shown to measure something. Phase evidence goes in `notes.md`, never here.
Rule ids: `CLF-001` to `CLF-007` (`CLAIM-` belongs to `roadmap-claim-check.ps1`).

**Organization**: two phases, each independently revertible. Phase 2 must be reverted before phase 1. The full harness is
run on an isolated checkout of the final commit, never in a working directory someone is using.

---

## Phase 1: The refusals and their proof (US1, US2; FR-001–FR-006)

**Purpose**: the seven refusals of `claim-feature.ps1` reach their own message and exit 1; each is proved by a fail and a pass
(the lost-race site through a new `originPushUrl` recipe field); the script is in the coverage sweep. A successful claim
prints what it printed before.
This purpose, T002, T003 and T005 were reworded after the phase 1 AI review (F1): the lost-race site is fixtured, not exempt.
**Amendment approved by**: anas.m, 2026-10-12

**Territory**:

- `scripts/claim-feature.ps1`
- `tests/**`

- [ ] T001 Record the baseline on the parent commit in `notes.md`: the full harness count, the coverage report's
      exempt-rule count (three) and its site counts, and, run as `pwsh -File scripts/claim-feature.ps1 -ShortName probe
      "a probe"` in purpose-built directories, each of the six reachable refusals' message and exit code, and the exact
      output and exit of a successful claim with no origin, with an origin that takes the push, and with `-NoPush`, as
      saved text for the byte comparison. Measure the terminal exit here; the spec's claim that it is already 1 is
      measured on `territory-check.ps1` only.
- [ ] T002 Write the fixtures first (plan D4, Testing Strategy), under `tests/enforcement/cases/claim-feature/`: a `fail`
      and a `pass` for each of `CLF-001` (`noGit`), `CLF-002` (`uncommitted`), `CLF-003` (checked-out branch), `CLF-004`
      (where `origin` points; the pass pushes to a repository nested as `origin`), `CLF-005` (no stub `create-new-feature.ps1`
      against a stub present), `CLF-006` (a stub that exits non-zero against one that succeeds) and `CLF-007` (the pass with and
      without an `originPushUrl` that does not exist: every push fails, the loop reads it as a lost race), differing only in the
      condition; add the `originPushUrl` recipe field to `FixtureRepo.psm1` with its self-tests; the stubs are plain files
      written by the recipe, each carrying a comment naming the output contract the real script
      reads (`BRANCH_NAME`). Add success-path `pass` cases for a claim with no origin, one with an origin that takes the
      push, and one with `-NoPush`. Expectations by hand; remember the harness reads stdout and then stderr. Run them on
      the parent commit and record that each `fail` fails there for the stated reason (the launcher's line, exit 97 or
      128) and each `pass` passes.
- [ ] T003 Bring the script into the coverage sweep: add `CLF-001` to `CLF-007` (site 135 included, plan D2 as amended)
      to `tests/enforcement/rules.json`, with each rule's anchor and law; add the script to the
      list in `tests/enforcement/Coverage.Tests.ps1`; add its entry to `tests/enforcement/emission-idioms.json` with the
      `Stop-Refused\s+['"]` and `Write-Warning\s` accumulators and the three warnings declared not-a-rule with written
      reasons (plan D4). Run the sweep and classify anything else it reports.
- [ ] T004 Edit `scripts/claim-feature.ps1` (plan D1): add `Stop-Refused` (error stream via `[Console]::Error.WriteLine`,
      then `exit 1`) before its first use and replace the seven `Write-Error ...; exit 1` sites with calls carrying the same
      message text, including the embedded dirty paths and the stock script's output. Nothing else in the script changes.
- [ ] T005 Run `-Case CLF-`, `-Case TERR-`, `-Case RIT-`, the full harness and `ritual-checks.ps1`: every pre-existing case
      unchanged, every new fixture as written, the coverage report lists `claim-feature.ps1` with no unowned site and the
      exempt count unchanged at three. Re-run T001's refusals and successful claims under `pwsh -File` and diff against the saved text:
      the message is the same, the exit is the same, and a successful claim is byte-identical.

---

## Phase 2: Guidance, flow-down and bookkeeping (US3; FR-007)

**Purpose**: tell adopters what flows down and what a wrapper may newly observe, prove with a measurement that a
successful claim prints the same bytes, and close the roadmap row. No script changes.

**Territory**:

- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/digests/**`

- [ ] T006 Add a flow-down note to `adoption/updating.md` shaped like feature 022's (what was wrong, what it does now,
      what flows down, what may newly be seen, what does not change, what was measured, what to do). Keep digest markers
      within 120 characters, and every path in it resolving in an adopted project (doc-lint).
- [ ] T007 Update `docs/roadmap.md`: GAP-031 status text, a decisions-log entry dated the day the feature ships (recording
      the owner's decisions on D1 and D2), and this feature's row to `shipped`. Run `pwsh -File scripts/build-digests.ps1`
      and commit the regenerated `docs/digests/**`.
- [ ] T008 Measurement (plan D6, SC-001): clones of FitForge, FlowBoard and ExpenseTracker made from their local
      directories (never the real projects, nothing pushed), the kit as of the parent of this feature applied, then the kit
      as it stands, digests rebuilt; in each state run `claim-feature.ps1 -NoPush -ShortName probe "a probe"` on a fresh
      clone, `doc-lint.ps1` and `ritual-checks.ps1`; list every line that moves in `notes.md` with its cause, and say plainly
      where none moved. Do not edit kit files while `update-kit.ps1` runs.
- [ ] T009 Final run on an isolated checkout of the final commit (a detached `git worktree` outside the repository, removed
      afterwards): the full harness, `ritual-checks.ps1 -Branch 023-claim-feature-refusals`, and `scope-check.ps1` on each
      phase commit. Record the numbers in `notes.md`. The owner then runs the gate.

---

## Dependencies & Execution Order

- Phase 2 needs phase 1 (the guidance describes what shipped, and the measurement runs the changed script).
- Within a phase, fixtures are written and shown failing before the behaviour lands.

## Implementation Strategy

MVP is phase 1: the refusals reaching their message and exit, proved. Phase 2 can be dropped without touching it.
Stop after each phase for the owner's gate; one phase at a time, never ahead.
