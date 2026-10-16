---

description: "Task list for feature 032 — the scope check names a phase commit whose diff cannot be read"
---

# Tasks: the scope check names a phase commit whose diff cannot be read

**Input**: `specs/032-scope-check-unreadable-commit/spec.md`, `plan.md` (decisions P1–P8), `notes.md` (the measurements)
**Prerequisites**: spec.md approved (anas.m, 2026-10-16; D1 A, D2 A, D3 A); tasks.md approved (anas.m, 2026-10-16); no new dependency,
no new script file, no new harness recipe field.

**Amendment approved by**: anas.m, 2026-10-16

**Tests**: the state ships with a passing and a failing harness fixture in the same phase as the behaviour, expectations written by
hand (feature 015). New fixtures are run against the parent commit before the code changes and must fail there, so each is shown to
measure something. Phase evidence goes in `notes.md`, never here. Rule ids: `SCOPE-028` to `SCOPE-030` and `REPOS-035`
(`SCOPE-001` to `SCOPE-027` and `REPOS-001` to `REPOS-034` are earlier features').

**Organization**: two phases, each independently revertible; phase 2 must be reverted before phase 1. The full harness is run on an
isolated checkout of the final commit, never in a working directory someone is using.

---

## Phase 1: A commit whose changed files cannot be read is an ERROR (US1, US2; FR-001–FR-007)

**Purpose**: the one read of a commit's changed files reports a failure on a channel separate from the list; the delete guard and
both phase lanes of `scope-check.ps1` end in an `ERROR` and exit 1 where they printed `PASS (0 file(s))` or `not applicable`;
`scope-check-repos.ps1` names the state through the same function. Every readable commit, an empty one included, prints what it
printed before. Proved by fixtures written first.

**Territory**:

- `scripts/scope-lib.ps1`
- `scripts/scope-check.ps1`
- `scripts/scope-check-repos.ps1`
- `tests/**`

- [x] T001 Record the baseline on the parent commit in `notes.md`: the full harness count on an isolated detached worktree, the
      coverage report's exempt-rule count and its site counts for `scope-check.ps1`, `scope-check-repos.ps1` and `scope-lib.ps1`,
      and, in purpose-built repositories, the saved output and exit code of a passing phase commit (Standard and Micro), a failing
      one (outside the Territory), a merge commit, a commit with no phase token, a readable empty phase commit and the deletion of
      `tasks.md`, for the byte comparison of T007.
- [x] T002 Probe the design (plan P1, Risks) and record it in `notes.md` before a rule depends on it: (a) a throwaway function reading
      `git show --name-status` and the exit code on the next statement, dot-sourced by a script and called from inside
      `Push-Location`/`try`/`finally` as `scope-check-repos.ps1` calls `Get-CommitPaths`, setting `$script:` and read by the caller;
      (b) that `truncateCommit` set to `HEAD^{tree}` makes `git show --name-status` fail in a fixture and leaves `git rev-parse
      --short`, `git rev-list --parents` and `git log -1 --format=%s` working; (c) that a commit at a shallow boundary is readable
      and unchanged; (d) the same probes on the CI image's git (the CI run of the branch is the second git).
- [x] T003 Write the fixtures first (plan P5, Testing Strategy), under `tests/enforcement/cases/scope-check/`: a `fail` and a `pass`
      for `SCOPE-028` (Standard phase commit; `pass` is `SCOPE-019/pass`'s fixture, `fail` adds `truncateCommit` `HEAD^{tree}`),
      for `SCOPE-029` (Micro phase commit on `SCOPE-016/pass`'s fixture) and for `SCOPE-030` (a commit with no phase token that
      deletes `tasks.md`, unreadable, against the same commit readable and not deleting it), plus `pass-empty` for `SCOPE-028` (a
      phase commit entry with no files: `PASS ... (0 file(s))`). Expectations by hand with the P4 line; remember the harness reads
      stdout and then stderr. Run them on the parent commit and record that each `fail` fails there for the stated reason (it
      prints `PASS ... (0 file(s))` or `not applicable`) and each `pass` passes.
- [x] T004 Bring the new rules into the coverage sweep: add `SCOPE-028`, `SCOPE-029` and `SCOPE-030` to `tests/enforcement/rules.json`
      with each rule's anchor and law, and `REPOS-035` as an exempt rule with its written reason (plan P5: the committer-date read
      fails first on every damaged commit tried); add an entry to `tests/enforcement/emission-idioms.json` only if the sweep reports a
      new site. Run the sweep and classify anything else it reports.
- [x] T005 Edit the scripts (plan P1 to P4, P6, P7): `Get-CommitStatusRows` in `scripts/scope-lib.ps1` with the `$script:` flag and
      `Get-CommitPaths` calling it with `-Renames`; `scripts/scope-check.ps1` reading the flag after the guard's read (without
      `-Renames`) and after each `Get-CommitPaths` call, and one `Write-UnreadableCommit` function that prints the `ERROR` line,
      each caller returning `$false`; `scripts/scope-check-repos.ps1` reading the flag after its call and ending in
      `<repo>: ERROR cannot read the changed files of <sha7>` and `'FAIL'`. Nothing else changes: the blob reads, the date read,
      the territory grammar, the merge and no-token paths, `-All`.
- [x] T006 Add a self-test of `Get-CommitStatusRows` (plan P1, Risks) to `tests/enforcement/Harness.Tests.ps1`: in a fixture repository,
      a readable commit returns its rows with the flag clear; a readable empty commit returns nothing with the flag clear; a commit
      whose tree is truncated returns nothing with the flag set; the flag is reset by the next call.
- [x] T007 Run `-Case SCOPE-`, `-Case REPOS-`, `-Case RIT-`, the full harness and `ritual-checks.ps1`: every pre-existing case
      unchanged, every new fixture as written, the coverage report lists no unowned site in the three scripts and the exempt count
      is stated. Re-run T001's states under `pwsh -File` and diff against the saved text: every readable commit is byte-identical.
      Record the numbers in `notes.md`.

---

## Phase 2: Guidance, close and measurement (US3; FR-008, SC-001–SC-003)

**Purpose**: adopters are told what flows down and what a branch with a damaged commit may newly see; a measurement shows that a
phase commit of each adopted project's own history grades the same bytes before and after; the roadmap row is closed.

**Territory**:

- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/digests/**`

- [x] T008 Add a flow-down note to `adoption/updating.md` shaped like feature 031's (what was wrong, what it does now, what flows
      down, what may newly be seen — the `ERROR` line and exit 1 for a commit git cannot read, including a token-less one —, what
      does not change, what was measured, what to do). No digest marker (the adoption digest is at its 40-bullet bound). Every
      path in it resolves in an adopted project (doc-lint).
- [x] T009 Update `docs/roadmap.md`: GAP-038 status text, a decisions-log entry dated the day the feature ships (recording D1 A, D2 A,
      D3 A, the exempt `REPOS-035` and what the work corrected), and this feature's row to `shipped`. Run
      `pwsh -File scripts/build-digests.ps1 -Check` and regenerate only if a digest-marked document changed.
- [x] T010 Measurement (plan P8, SC-001, SC-002): clones of FitForge, FlowBoard and ExpenseTracker made from their local
      directories (never the real projects, nothing pushed), the kit as of the parent of this feature applied with `update-kit.ps1`,
      then the kit as it stands, digests rebuilt; in each state run `scope-check.ps1 -Branch <feature> -Commit <sha>` on a phase
      commit of each project's own history, and `doc-lint.ps1` and `ritual-checks.ps1 -Branch main`; list every line that moves in
      `notes.md` with its cause and say plainly where none moved. Then make a phase commit's tree unreadable in one clone and show
      the `ERROR` line and exit 1 where the parent printed `PASS (0 file(s))`. Do not edit kit files while `update-kit.ps1` runs.
- [ ] T011 Final run on an isolated checkout of the final commit (a detached `git worktree` outside the repository, removed
      afterwards): the full harness, `ritual-checks.ps1 -Branch 032-scope-check-unreadable-commit`, and `scope-check.ps1` on each
      phase commit. Record the numbers in `notes.md`. The owner then runs the gate.

---

## Dependencies & Execution Order

- T002 before T003 and T005 (the fixtures and the function use what the probe proved); T003 before T005 (fixtures first, shown
  failing); T004 before T005's sweep run; T006 with T005; T007 last.
- Phase 2 needs phase 1: the guidance describes what shipped and the measurement runs the changed scripts.
- Within a phase, fixtures are written and shown failing before the behaviour lands.

## Implementation Strategy

MVP is phase 1: the unreadable commit named and proved on both lanes and the guard. Phase 2 can be dropped without touching it, at the
cost of leaving adopters unaware of what a damaged commit now prints. Stop after each phase for the owner's gate; one phase at a
time, never ahead.
