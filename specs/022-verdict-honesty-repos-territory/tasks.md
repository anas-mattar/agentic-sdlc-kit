---

description: "Task list for feature 022 — verdicts that say what was compared (scope-repos and territory-check)"
---

# Tasks: Verdicts that say what was compared

**Input**: `specs/022-verdict-honesty-repos-territory/spec.md`, `plan.md` (decisions D1–D9)
**Prerequisites**: spec.md and plan.md approved (including the FR-001 amendment to `-All`); no new dependency, no new script file.
**Amendment approved by**: anas.m, 2026-10-12

**Tests**: every rule ships with a passing and a failing harness fixture in the same phase as the behaviour,
expectations written by hand (feature 015). New fixtures are run against the parent commit before the code
changes and must fail there, so each is shown to measure something. Phase evidence goes in `notes.md`, never here.
Rule ids: `REPOS-034` is the next free `REPOS` id; `TERR-008` to `TERR-011` already exist and are fixtured here.

**Organization**: three phases, each independently revertible. Phase 3 must be reverted before phase 2, phase 2
before phase 1 (phase 2 depends on nothing from phase 1, so either order of reverting 1 and 2 is consistent). The
full harness is run on an isolated checkout of the final commit, never in a working directory someone is using.

---

## Phase 1: The run-level verdict and the hint (US1, US2; FR-001–FR-005, FR-008 for these)

**Purpose**: `scope-check-repos.ps1` names, under `-All`, every applicable repository that graded nothing even when
another repository graded, and its no-trunk line names the command that works. A run in which every applicable
repository graded is byte-identical.

**Territory**:

- `scripts/scope-check-repos.ps1`
- `tests/**`

- [ ] T001 Record the baseline on the parent commit in `notes.md`: the full harness count, the counts from
      `Run-Tests.ps1 -Case REPOS-`, `-Case TERR-` and `-Case RIT-`, and the exact output of `scope-check-repos.ps1
      -All` on a two-repository fixture where both graded, so "byte-identical" is measured against saved text.
- [ ] T002 Write the fixtures first (plan Testing Strategy): `REPOS-034` `fail` (repository A graded `PASS`,
      repository B with no resolvable trunk, `-All`: B's own line, the run-level line, exit 0),
      `fail-skipped-commits` (B's only commits are a merge commit and a commit with no `phase N` token),
      `fail-beside-a-failure` (A graded `FAIL`, B ungraded: exit 1 and the line present), and as `pass` both graded
      (no line, byte-identical), `pass-tip-mode` (the same fixture without `-All`: no new line), and
      `pass-absent-repository` (a declared but absent repository stays `n/a`). Change `REPOS-015/fail`'s expected
      output for the hint and add a case that runs the printed hint against a trunk-named fixture and expects a
      graded verdict (SC-005). Add a `ritual-checks` case for SC-004 (one graded, one ungraded: member `UNGRADED`;
      both graded: `OK`). Expectations by hand. Run them on the parent commit and record that each `fail` fails there
      for the stated reason.
- [ ] T003 Add `REPOS-034` and update `REPOS-015` in `tests/enforcement/rules.json` (anchors, law, summary) and any
      new accumulator in `tests/enforcement/emission-idioms.json`, so the coverage test sees every new site.
- [ ] T004 Edit `scripts/scope-check-repos.ps1` (plan D1, D3, D4): a per-repository graded counter and an
      `$ungradedRepos` list; join it at the two `UNGRADED ... continue` sites and, under `-All`, when a repository's
      own counter is zero after its loop; print the new run-level line only when `-All` is set, something graded and
      the list is non-empty, also under `FAIL`; keep the existing nothing-graded line verbatim; replace the hint text.
      Update the script header's description of the run-level verdict. `-BaseRef` itself is unchanged.
- [ ] T005 Run `-Case REPOS-`, `-Case RIT-`, the full harness and `ritual-checks.ps1`: every pre-existing case
      unchanged except `REPOS-015/fail`'s expectation, every new fixture as written, coverage reports each new site
      fixtured. Re-run T001's two-repository output and diff against the saved text: no byte differs.

---

## Phase 2: The four refusals (US3; FR-006, FR-007, FR-008 for these)

**Purpose**: the refusals of `territory-check.ps1` reach their own message and exit 1, are proved by fixtures, and
leave the exemption list. No other territory-check behaviour changes.

**Territory**:

- `scripts/territory-check.ps1`
- `tests/**`

- [ ] T006 Record the baseline on the parent commit in `notes.md`: the full harness count, `Run-Tests.ps1 -Case
      TERR-`, the coverage report's exempt-rule count (seven), and what a human sees today from each of the four
      refusals under `pwsh -File` (message, exit code), so "same wording, same exit" is measured against saved text.
- [ ] T007 Add the `noGit` recipe field to `tests/enforcement/lib/FixtureRepo.psm1` (plan D7) with the harness's
      own self-test convention (a case that ignores the field fails loudly against the healthy fixture), documented in
      the file's header comment and `tests/enforcement/README.md` where recipe fields are listed.
- [ ] T008 Write the fixtures first: a `fail` and a `pass` for each of `TERR-008` (outside a git repository, `noGit`),
      `TERR-009` (a branch that is not `NNN-name`), `TERR-010` (`origin` pointing at a path that does not exist) and
      `TERR-011` (a trunk that is not `main`), differing only in the condition under test; each `fail` expects the
      message and exit 1. Run them on the parent commit and record that each `fail` fails there (exit 97 and the
      launcher's line, not the message).
- [ ] T009 Edit `tests/enforcement/rules.json`: remove the `exemption` and `notes` entries of `TERR-008` to
      `TERR-011` and keep each rule's anchor and law; edit `tests/enforcement/emission-idioms.json` so the
      `Stop-Refused` call sites are the accumulator for this script and the `Write-Error\s` entry is removed.
- [ ] T010 Edit `scripts/territory-check.ps1` (plan D6): add `Stop-Refused` (error stream via
      `[Console]::Error.WriteLine`, then `exit 1`) and replace the four `Write-Error ...; exit 1` sites with calls
      carrying the same message text. Nothing else in the script changes.
- [ ] T011 Run `-Case TERR-`, `-Case RIT-`, the full harness and `ritual-checks.ps1`: every pre-existing case
      unchanged, every new fixture as written, the coverage report shows the exempt count at three and `TERR-008` to
      `TERR-011` fixtured. Re-run T006's four refusals under `pwsh -File` and diff against the saved text: the message
      is the same, the exit code is the same.

---

## Phase 3: Guidance, flow-down and bookkeeping (US4; FR-009, FR-010)

**Purpose**: tell reviewers what the run-level line now guarantees, tell adopters what flows down and what they may
newly see, prove with a measurement that no adopted project's verdict moves unannounced, and close the roadmap
rows. No script changes.

**Territory**:

- `docs/sdlc/review-process.md`
- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/digests/**`

- [ ] T012 [P] Update `docs/sdlc/review-process.md` step 3: the run-level `UNGRADED` line under `-All` now names a
      repository that applied and graded nothing even beside a graded one; tip mode and "read the per-repository
      lines" stay for the per-phase command; `UNGRADED` is still not a pass. Keep digest markers within 120
      characters.
- [ ] T013 [P] Add a flow-down note to `adoption/updating.md` shaped like feature 021's (what flows down, what may
      newly be seen, what was measured, the one verdict that can move) and bring the feature 015 `-BaseRef`
      disclosure and the feature 018 territory paragraph up to date. Paths in flowing documents must resolve in an
      adopted project (doc-lint).
- [ ] T014 Update `docs/roadmap.md`: GAP-029 and GAP-030 status text, a decisions-log entry dated the day the
      feature ships, and this feature's row to `shipped`. Run `pwsh -File scripts/build-digests.ps1` and commit the
      regenerated `docs/digests/**`.
- [ ] T015 Measurement (plan D9, SC-003): clones of FitForge, FlowBoard and ExpenseTracker made from their local
      directories (never the real projects, nothing pushed), the kit as of the parent of this feature applied, then the
      kit as it stands, digests rebuilt; run `scope-check-repos.ps1 -All`, `ritual-checks.ps1`, `doc-lint.ps1` in each
      state; list every line that moves in `notes.md` with its cause, and say plainly where none moved. Do not edit
      kit files while `update-kit.ps1` runs.
- [ ] T016 Final run on an isolated checkout of the final commit (a detached `git worktree` outside the repository,
      removed afterwards): the full harness, `ritual-checks.ps1 -Branch 022-verdict-honesty-repos-territory`, and
      `scope-check.ps1` on each phase commit. Record the numbers in `notes.md`. The owner then runs the gate.

---

## Dependencies & Execution Order

- Phase 1 and phase 2 are independent of each other; do phase 1 first.
- Phase 3 needs phases 1 and 2 (the guidance describes what shipped, and the measurement runs both scripts).
- Within a phase, fixtures are written and shown failing before the behaviour lands. `[P]` tasks touch different files.

## Implementation Strategy

MVP is phase 1: the run-level verdict is the defect that can turn a CI signal green over an unread repository.
Phase 2 can be dropped without touching it. Stop after each phase for the owner's gate; one phase at a time, never ahead.
