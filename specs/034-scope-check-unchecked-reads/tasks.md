---

description: "Task list for feature 034 — the scope checks name a merge base or commit list they cannot read"
---

# Tasks: the scope checks name a merge base or commit list they cannot read

**Input**: `specs/034-scope-check-unchecked-reads/spec.md`, `plan.md` (decisions P1–P8), `notes.md` (the measurements)
**Prerequisites**: spec.md approved (anas.m, 2026-10-17; D1 A, D2 A, D3 A); tasks.md approved (anas.m, 2026-10-17); no new dependency, no new script file, no new harness recipe field.

**Amendment approved by**: anas.m, 2026-10-17

**Tests**: the state ships with a passing and a failing harness fixture in the same phase as the behaviour, expectations written by hand (feature 015). New fixtures
are run against the parent commit before the code changes and must fail there, so each is shown to measure something. Phase evidence goes in `notes.md`, never here.
Rule ids: `SCOPE-031`, `SCOPE-032` (exempt), `REPOS-036` and `REPOS-037` (exempt) (`SCOPE-001` to `SCOPE-030` and `REPOS-001` to `REPOS-035` are earlier features').

**Organization**: two phases, each independently revertible; phase 2 must be reverted before phase 1. The full harness is run on an isolated checkout of the final commit,
never in a working directory someone is using. Every file is checked for carriage returns before it is committed (this working tree has tracked files that are CRLF on disk).

---

## Phase 1: A merge base or commit list git could not read is an ERROR (US1, US2; FR-001–FR-007)

**Purpose**: `scope-check.ps1 -All` and `scope-check-repos.ps1 -All` read git's own exit codes: "no trunk", "no shared history" and "an empty range" keep their `UNGRADED` text and exit 0;
a merge base or commit list git could not read ends in an `ERROR` and exit 1, where the check printed `UNGRADED` and exit 0. The failure reaches the callers on a channel of its own.
Every readable repository, `-Commit` and tip mode print what they printed before. Proved by fixtures written first.

**Territory**:

- `scripts/scope-lib.ps1`
- `scripts/scope-check.ps1`
- `scripts/scope-check-repos.ps1`
- `tests/**`

- [ ] T001 Record the baseline on the parent commit in `notes.md`: the full harness count on an isolated detached worktree, the coverage report's exempt-rule count and its site counts for
      `scope-check.ps1`, `scope-check-repos.ps1` and `scope-lib.ps1`, and the saved output and exit code of the legitimate states for the byte comparison of T007 (the existing cases
      `SCOPE-025` fail and pass, the no-shared-history and empty-range cases, and `REPOS-001` with `-All`).
- [ ] T002 Probe the design (plan P1, P2, Risks) and record it in `notes.md` before a rule depends on it: (a) `git merge-base`, `git rev-parse --verify --quiet` and `git rev-list` exit
      codes for a missing trunk ref, no shared history (an orphan branch), a deleted commit object, a truncated commit object and a damaged trunk object, on this machine and, through the CI
      run of the branch, on the CI image's git; (b) that `truncateCommit` set to `HEAD` makes `merge-base` fail on a governance fixture and, in a **nested** recipe, on a code repository;
      (c) whether any recipe makes `git rev-list <base>..<tip>` fail after `git merge-base` succeeded (the plan expects not, which is the exemption of `SCOPE-032` and `REPOS-037`).
- [ ] T003 Write the fixtures first (plan P5, Testing Strategy), under `tests/enforcement/cases/`: `scope-check/SCOPE-031` (`fail`: `SCOPE-025/pass`'s fixture with `truncateCommit` `HEAD`, `-All`;
      `pass`: `SCOPE-025/pass`; `pass-orphan`: a branch with no history in common with the trunk, which keeps `UNGRADED ... merge base` and exit 0) and `scope-check-repos/REPOS-036` (`fail`: `REPOS-001/pass`
      with `-All` and `truncateCommit` `HEAD` in the nested recipe; `pass`: the same readable). Expectations by hand with the P4 lines; remember the harness reads stdout and then stderr. Run them on
      the parent commit and record that each `fail` fails there for the stated reason (the parent prints `UNGRADED ... merge base`, exit 0) and each `pass` passes.
- [ ] T004 Bring the new rules into the coverage sweep: add `SCOPE-031` and `REPOS-036` to `tests/enforcement/rules.json` with each rule's anchor and law, and `SCOPE-032` and `REPOS-037` as exempt
      rules with their written reason (plan P5: `rev-list` can fail only on objects `merge-base` has just walked, measured in T002(c)); add an entry to `tests/enforcement/emission-idioms.json`
      only if the sweep reports a new site. Run the sweep and classify anything else it reports.
- [ ] T005 Edit the scripts (plan P1 to P4, P7): `Get-RepoMergeBase` in `scripts/scope-lib.ps1` with the exit-code classification and the `Failed` and `FailedWith` members;
      `Get-DiffBase` in `scripts/scope-check.ps1` with the same classification and `$script:DiffBaseReadFailed`; both commit-list reads checked on the next statement; the four `ERROR` lines of
      P4 (two in `scope-check.ps1`, each exit 1; two in `scope-check-repos.ps1`, each setting `$failed`). Nothing else changes: `-Commit`, `-Phase`, tip mode, the `UNGRADED` text and exit for a missing
      trunk, no shared history and an empty range, `territory-check.ps1`, the blob reads, the date read.
- [ ] T006 Run `-Case SCOPE-`, `-Case REPOS-`, `-Case TERR-` (territory-check shares `Get-RepoMergeBase`) and `-Case RIT-`, the full harness and `ritual-checks.ps1`: every pre-existing case unchanged,
      every new fixture as written, the coverage report lists no unowned site and the exempt count is stated. Re-run T001's states under `pwsh -File` and diff against the saved text: every legitimate state
      is byte-identical. Record the numbers in `notes.md`.

---

## Phase 2: Guidance, close and measurement (US3; FR-008, SC-001–SC-003)

**Purpose**: adopters are told what flows down and what a CI run on a damaged branch now shows; a measurement shows that the legitimate states print the same bytes on each adopted project's
clone and that a damaged branch is now red; the roadmap row is closed.

**Territory**:

- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/digests/**`

- [ ] T007 Add a flow-down note to `adoption/updating.md` shaped like feature 033's (what was wrong, what it does now, what flows down, what may newly be seen — the `ERROR` lines and exit 1 on a damaged
      branch, red where it was green —, what does not change, the stated limits including `territory-check.ps1`, what was measured, what to do: `git fsck`, re-fetch, re-clone). No digest marker (the adoption
      digest is at its 40-bullet bound). Every path in it resolves in an adopted project (doc-lint).
- [ ] T008 Update `docs/roadmap.md`: GAP-040 status text, a decisions-log entry dated the day the feature ships (recording D1 A, D2 A, D3 A, the two exempt rules and what the work corrected), and this
      feature's row to `shipped`. Run `pwsh -File scripts/build-digests.ps1 -Check` and regenerate only if a digest-marked document changed.
- [ ] T009 Measurement (plan P6, SC-001, SC-002): clones of FitForge, FlowBoard and ExpenseTracker made from their local directories (never the real projects, nothing pushed); the scripts of the kit as of the
      parent of this feature and as they stand, **both run against the same kit content** (feature 033's lesson: the kit's own copies of the scripts are verbatim files); `scope-check.ps1 -All` and, where a
      project declares code repositories, `scope-check-repos.ps1 -All` on a feature branch of each clone, intact and with a commit object made unreadable; list every line that moves in `notes.md` with its
      cause and say plainly where none moved. Do not edit kit files while `update-kit.ps1` runs; check that an argument array of one element is not splatted character by character.
- [ ] T010 Final run on an isolated checkout of the final commit (a detached `git worktree` outside the repository, removed afterwards): the full harness,
      `ritual-checks.ps1 -Branch 034-scope-check-unchecked-reads`, and `scope-check.ps1` on each phase commit. Record the numbers in `notes.md`. The owner then runs the gate.

---

## Dependencies & Execution Order

- T002 before T003 and T005 (the fixtures and the functions use what the probe proved); T003 before T005 (fixtures first, shown failing); T004 before T005's sweep run; T006 last.
- Phase 2 needs phase 1: the guidance describes what shipped and the measurement runs the changed scripts.
- Within a phase, fixtures are written and shown failing before the behaviour lands.

## Implementation Strategy

MVP is phase 1: the unreadable merge base and commit list named and proved on both scripts. Phase 2 can be dropped without touching it, at the cost of leaving adopters unaware of what a damaged branch
now shows. Stop after each phase for the owner's gate; one phase at a time, never ahead.
