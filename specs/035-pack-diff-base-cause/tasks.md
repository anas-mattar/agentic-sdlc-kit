---

description: "Task list for feature 035 — the enforcement pack names the cause when its diff base cannot be read"
---

# Tasks: the enforcement pack names the cause when its diff base cannot be read

**Input**: `specs/035-pack-diff-base-cause/spec.md`, `plan.md` (decisions P1–P7), `notes.md` (the measurements)
**Prerequisites**: spec.md approved (anas.m, 2026-10-17; D1 A, D2 A, D3 A); tasks.md approved (anas.m, 2026-10-17); no new dependency, no new script file, no new harness recipe field.

**Amendment approved by**: anas.m, 2026-10-17

**Tests**: the states ship with a passing and a failing harness fixture in the same phase as the behaviour, expectations written by hand (feature 015). New fixtures are run against the parent commit
before the code changes and must fail there, so each is shown to measure something. Phase evidence goes in `notes.md`, never here. Rule ids: `BASE-001` to `BASE-003` (a new family; `DIFF-` and `GITREAD-` are features 028 and 029's).

**Organization**: two phases, each independently revertible; phase 2 must be reverted before phase 1. The full harness is run on an isolated checkout of the final commit, never in a working directory someone is using.
Every file is checked for carriage returns before it is committed (this working tree has tracked files that are CRLF on disk).

---

## Phase 1: The pack names a diff base it could not read (US1; FR-001–FR-005)

**Purpose**: `Get-DiffBase` reads git's own exit codes; when no base is found and git failed, the dispatch warning, the numbered lane's `AmendmentAuthority` failure and the `ReviewProvenance` `UNGRADED` line say that the base
could not be read and name the repair, instead of speaking of a missing integration branch and advising `fetch-depth: 0`. The numbered lane stays red and the Lite lane stays `UNGRADED` at exit 0. A missing trunk, no shared history, a
shallow clone and every readable repository print what they printed before. Proved by fixtures written first.

**Territory**:

- `scripts/enforcement-pack.ps1`
- `tests/**`

- [ ] T001 Record the baseline on the parent commit in `notes.md`: the full harness count on an isolated detached worktree, the coverage report's exempt-rule count and its site counts for `enforcement-pack.ps1`, and the saved
      output and exit code of the legitimate no-base states for the byte comparison of T006 (the existing shallow-clone and missing-trunk cases `AMEND-003`, `AMEND-001/pass-lite-docs-readme-only-shallow`, `CRIT-R02`,
      `CRIT-R03`, and a numbered orphan and a Lite orphan built in a scratch fixture).
- [ ] T002 Probe the design (plan P1, Risks) and record it in `notes.md` before a rule depends on it: (a) `git rev-parse --verify --quiet`, `git merge-base` exit codes for a missing trunk, no shared history, a truncated tip commit and a
      damaged trunk object, on this machine and, through the CI run of the branch, on the CI image's git; (b) that `$LASTEXITCODE` read after a split `git merge-base` statement is the exit of git and not of a following pipeline; (c) that
      `truncateCommit` set to `HEAD` makes the pack take its no-base path on both a numbered and a Lite-lane fixture and leaves the shallow-clone detection (`git rev-parse --is-shallow-repository`) answering "not shallow".
- [ ] T003 Write the fixtures first (plan P5, Testing Strategy), under `tests/enforcement/cases/enforcement-pack/`: `BASE-001` (`fail`: a `docs/x` Lite branch with `truncateCommit` `HEAD`, built from `AMEND-001`'s Lite fixtures; `pass`: the
      same readable; `pass-orphan`: a `docs/y` orphan branch keeping today's text), `BASE-002` (`fail`: `STRUCT-001/pass`'s fixture with `truncateCommit` `HEAD`; `pass`: the same readable; `pass-orphan`: a numbered orphan keeping today's text and
      failures) and `BASE-003` (`fail` and `pass`: the Lite pair again, as its own case directory). Expectations by hand with the P2 to P4 messages; remember the harness reads stdout and then stderr. Run them on the parent commit and
      record that each `fail` fails there for the stated reason (the parent prints `no integration branch to diff against` and the `fetch-depth: 0` advice) and each `pass` and `pass-orphan` passes.
- [ ] T004 Bring the new rules into the coverage sweep: add `BASE-001`, `BASE-002` and `BASE-003` to `tests/enforcement/rules.json` with each rule's anchor (`enforcement-pack: the diff base could not be read`, `cannot grade '` plus
      `— the diff base could not be read`, `ReviewProvenance: the diff base could not be read`) and law; add an entry to `tests/enforcement/emission-idioms.json` only if the sweep reports a new site. Run the sweep and classify anything else it reports.
- [ ] T005 Edit `scripts/enforcement-pack.ps1` (plan P1 to P4, P7): `Get-DiffBase` with the exit-code classification, the split statement and `$script:DiffBaseFailure` (reset at the top of each call); the dispatch warning
      (`:2401`), the `AmendmentAuthority` failure (`:2143`) and the `ReviewProvenance` `UNGRADED` line (`:1316`) each print the P2 to P4 text when the flag is set and today's text otherwise. Nothing else changes: the verdicts, the shallow-clone
      failure above `:2143`, the other "no diff base" lines, `-ReplayBase`/`-ReplayTip`, `-IgnoreAmendmentBoundary`.
- [ ] T006 Run `-Case enforcement-pack/`, the full harness and `ritual-checks.ps1`: every pre-existing case unchanged, every new fixture as written, the coverage report lists no unowned site and the exempt count is stated. Re-run T001's states
      under `pwsh -File` and diff against the saved text: every legitimate no-base state is byte-identical. Record the numbers in `notes.md`.

---

## Phase 2: Guidance, close and measurement (US2; FR-006, SC-001–SC-003)

**Purpose**: adopters are told what flows down and what an owner now reads on a damaged branch; a measurement shows that the legitimate states print the same bytes on each adopted project's clone and that a damaged branch now names its cause;
the roadmap row is closed.

**Territory**:

- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/digests/**`

- [ ] T007 Add a flow-down note to `adoption/updating.md` shaped like feature 034's (what was wrong, what it does now, what flows down, what may newly be seen — the three messages, and that no verdict moved —, what does not change, the stated
      limits including the other "no diff base" lines, what was measured, what to do: `git fsck`, re-clone). No digest marker (the adoption digest is at its 40-bullet bound). Every path in it resolves in an adopted project (doc-lint).
- [ ] T008 Update `docs/roadmap.md`: GAP-041 status text, a decisions-log entry dated the day the feature ships (recording D1 A, D2 A, D3 A and what the work corrected), and this feature's row to `shipped`. Edit the row with a tool
      that keeps UTF-8 (the em dash of a row that is not edited must not be rewritten through a console code page). Run `pwsh -File scripts/build-digests.ps1 -Check` and regenerate only if a digest-marked document changed.
- [ ] T009 Measurement (plan P6, SC-001, SC-002): the script of the kit as of the parent of this feature and as it stands, **both run against the same fresh clones** of FitForge, FlowBoard and ExpenseTracker (`-Root <clone>`, nothing in place touched,
      nothing pushed; clones made with `--no-hardlinks`), on probe branches made in each clone: a numbered branch and a Lite-lane branch, each intact, an orphan, and damaged (the tip commit truncated); list every line that moves in `notes.md` with its
      cause and say plainly where none moved. Check that an argument array of one element is not splatted character by character, and that the real projects are untouched afterwards.
- [ ] T010 Final run on an isolated checkout of the final commit (a detached `git worktree` outside the repository, removed afterwards): the full harness, `ritual-checks.ps1 -Branch 035-pack-diff-base-cause`, and `scope-check.ps1` on each phase commit.
      Record the numbers in `notes.md`. The owner then runs the gate.

---

## Dependencies & Execution Order

- T002 before T003 and T005 (the fixtures and the function use what the probe proved); T003 before T005 (fixtures first, shown failing); T004 before T005's sweep run; T006 last.
- Phase 2 needs phase 1: the guidance describes what shipped and the measurement runs the changed script.
- Within a phase, fixtures are written and shown failing before the behaviour lands.

## Implementation Strategy

MVP is phase 1: the unreadable diff base named on both lanes and proved. Phase 2 can be dropped without touching it, at the cost of leaving adopters unaware of what a damaged branch now says. Stop after each phase for the owner's gate; one phase at a time, never ahead.
