---

description: "Task list for feature 033 — update-kit.ps1 names a recorded kit commit its kit clone does not know"
---

# Tasks: update-kit.ps1 names a recorded kit commit its kit clone does not know

**Input**: `specs/033-update-kit-unknown-recorded-commit/spec.md`, `plan.md` (decisions P1–P7), `notes.md` (the measurements)
**Prerequisites**: spec.md approved (anas.m, 2026-10-16; D1 A, D2 A, D3 A); tasks.md approved (anas.m, 2026-10-16); no new dependency, no new script file.

**Amendment approved by**: anas.m, 2026-10-16

**Tests**: the state ships with tests in the same phase as the behaviour, expectations written by hand. The new test is run against the
parent commit before the code changes and must fail there for the unknown-commit states, so it is shown to measure something. Phase
evidence goes in `notes.md`, never here. The test is `tests/enforcement/UpdateKit.Tests.ps1`; `update-kit.ps1` is not a grading script and
has no rule in `tests/enforcement/rules.json`.

**Organization**: two phases, each independently revertible; phase 2 must be reverted before phase 1. The full harness is run on an
isolated checkout of the final commit, never in a working directory someone is using.

---

## Phase 1: An unknown recorded commit is reported (US1 and the tests of US2; FR-001–FR-006)

**Purpose**: `update-kit.ps1` decides once whether the recorded kit commit is a commit of the kit clone; when it is not, every surgical
file is reported `no baseline - review all` and one line names the commit, so the run no longer prints `Result: up to date` over a
lost report. Every other state prints what it printed before. Proved by a test written first.

**Territory**:

- `scripts/update-kit.ps1`
- `tests/**`

- [x] T001 Record the baseline on the parent commit in `notes.md`: the full harness count on an isolated detached worktree and the
      coverage report's counts, and, on the small kit and target of plan P5 (built with plain git), the saved output and exit code of
      the known, absent, malformed and unknown recorded-commit states, dry run and real run, and `-Json -DryRun`, for the byte
      comparison of T006.
- [x] T002 Probe the design (plan P1, Risks) and record it in `notes.md` before the script depends on it: `git -C <kit> cat-file -e
      "<value>^{commit}"` and `git log "<value>..HEAD"` on a full sha the kit has, an abbreviated sha, an unknown sha, a branch name, a
      value that is not a string, and a shallow kit clone whose boundary lies beyond the recorded commit; which of them `cat-file`
      and `git log` accept alike (the condition must never call unknown a value `git log` could read); on this machine and, through
      the CI run of the branch, on the CI image's git.
- [x] T003 Write the test first (plan P5), `tests/enforcement/UpdateKit.Tests.ps1`: a Pester file that builds the small kit and target
      in a temporary directory with plain git (`core.autocrlf` false, a committed `.kit-version`) and runs `pwsh -NoProfile -File
      scripts/update-kit.ps1 -Kit <kit> -Target <target>`; cases for the recorded commit known, `.kit-version` absent and malformed
      (the three pass on the parent commit), and for the recorded commit unknown as a dry run, as a real run (the record advances and
      the delivered-once NOTE is printed) and with `-Json -DryRun` (`surgical` has one entry, the keys are unchanged). Expectations by
      hand from `notes.md`. Run it on the parent commit and record that the three known-good states pass and each unknown-commit
      state fails for the stated reason (`Result: up to date`, exit 0, no surgical entry).
- [x] T004 Edit `scripts/update-kit.ps1` (plan P1 to P4): after `$recordedCommit` is read, decide `$recordedKnown` with the call T002
      validated; make the surgical pass's baseline condition `-not $recordedCommit -or -not $recordedKnown`; print the P3 line once in
      text mode, before the sections, when the commit is unknown. Nothing else changes: the verbatim pass, `-Force`, the preflight, the
      record write, the doctor, `-Json`'s keys, the exit codes.
- [x] T005 Run the new test, `-Case RIT-`, the full harness and `ritual-checks.ps1`: every pre-existing case unchanged, the new test as
      written, the coverage report lists no unowned site and the exempt count is stated. Re-run T001's states under `pwsh -File` and diff
      against the saved text: the known, absent and malformed states are byte-identical, and the unknown states say what the plan says.
      Record the numbers in `notes.md`.

---

## Phase 2: Guidance, close and measurement (US2; FR-007, SC-001–SC-003)

**Purpose**: adopters are told what flows down and what a wrapper that matched `Result: up to date` may newly see; a measurement shows that
the known, absent and malformed states print the same bytes on each adopted project's clone and that the unknown state now reports; the
roadmap row is closed.

**Territory**:

- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/digests/**`

- [x] T006 Add a flow-down note to `adoption/updating.md` shaped like feature 032's (what was wrong, what it does now, what flows down,
      what may newly be seen — the NOTE line, the surgical entries and exit 2 where it printed `up to date` —, what does not change,
      what was measured, what to do: deepen or re-clone the kit, or accept the full review). No digest marker (the adoption digest is at
      its 40-bullet bound). Every path in it resolves in an adopted project (doc-lint).
- [x] T007 Update `docs/roadmap.md`: GAP-039 status text, a decisions-log entry dated the day the feature ships (recording D1 A, D2 A,
      D3 A and what the work corrected), and this feature's row to `shipped`. Run `pwsh -File scripts/build-digests.ps1 -Check` and
      regenerate only if a digest-marked document changed.
- [x] T008 Measurement (plan P6, SC-001, SC-002): clones of FitForge, FlowBoard and ExpenseTracker made from their local directories
      (never the real projects, nothing pushed); the kit as of the parent of this feature, then the kit as it stands, each run against
      a fresh copy of a clone with a known, an absent and an unknown recorded commit, dry run and `-Json -DryRun`; list every line that
      moves in `notes.md` with its cause and say plainly where none moved. The clones must be created with the same line-ending
      configuration for both states and the commits chosen once. Do not edit kit files while `update-kit.ps1` runs.
- [ ] T009 Final run on an isolated checkout of the final commit (a detached `git worktree` outside the repository, removed afterwards):
      the full harness, `ritual-checks.ps1 -Branch 033-update-kit-unknown-recorded-commit`, and `scope-check.ps1` on each phase commit.
      Record the numbers in `notes.md`. The owner then runs the gate.

---

## Dependencies & Execution Order

- T002 before T003 and T004 (the test and the script use what the probe proved); T003 before T004 (the test first, shown failing); T005 last.
- Phase 2 needs phase 1: the guidance describes what shipped and the measurement runs the changed script.
- Within a phase, the test is written and shown failing before the behaviour lands.

## Implementation Strategy

MVP is phase 1: the unknown recorded commit reported and proved. Phase 2 can be dropped without touching it, at the cost of leaving adopters
unaware of what a wrapper now sees. Stop after each phase for the owner's gate; one phase at a time, never ahead.
