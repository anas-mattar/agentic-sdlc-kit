---

description: "Task list for feature 031 — claim-feature.ps1 tells a same-base rival from our own claim"
---

# Tasks: claim-feature.ps1 tells a same-base rival from our own claim

**Input**: `specs/031-claim-same-base-rival/spec.md`, `plan.md` (decisions P1–P8), `notes.md` (the measurements)
**Prerequisites**: spec.md approved (anas.m, 2026-10-16; D1 B' as amended, D2 A, D3 A); plan.md approved with it (the two
amendments of FR-004 and FR-005 are recorded in the spec); tasks.md approved (anas.m, 2026-10-16); no new dependency, no new script file, no new harness recipe field.

**Amendment approved by**: anas.m, 2026-10-16

**Tests**: the state ships with a passing and a failing harness fixture in the same phase as the behaviour, expectations
written by hand (feature 015). New fixtures are run against the parent commit before the code changes and must fail there, so
each is shown to measure something. Phase evidence goes in `notes.md`, never here. Rule id: `CLF-018`
(`CLF-001` to `CLF-017` are features 023 and 030's; `CLF-019` is not built, plan P5 as amended).

**Organization**: two phases, each independently revertible; phase 2 must be reverted before phase 1. The full harness is run
on an isolated checkout of the final commit, never in a working directory someone is using.

---

## Phase 1: Tell a same-base rival from our own claim (US1; FR-001–FR-006)

**Purpose**: a push whose branch already existed on `origin` at our own sha is read as a same-name rival, not as our claim: the
script warns in its own words, withdraws nothing, and renumbers through its existing loop. A claim with no rival, `-NoPush`, no
`origin`, a genuine rival of another short name and every refusal of features 023 and 030 print what they printed before, except
the layout of git's own text quoted inside the rejected-push refusal (plan P6, approved). Proved by fixtures written first.

**Territory**:

- `scripts/claim-feature.ps1`
- `tests/**`

- [x] T001 Record the baseline on the parent commit in `notes.md`: the full harness count, the coverage report's exempt-rule
      count and its site counts for `claim-feature.ps1`, and, run as `pwsh -File scripts/claim-feature.ps1 -ShortName probe
      "a probe"` in purpose-built directories, the exit code and output of a successful claim with no origin, with an origin
      that takes the push, with `-NoPush`, and with one genuine renumbering, as saved text for the byte comparison.
- [x] T002 Probe `git push --porcelain` (plan P1, P3) and record the result in `notes.md` before any rule depends on it, on
      this machine and on the CI image's git: the status line of a push that creates the ref (`*`), of one whose branch already
      exists at our sha (`=`), of a rejected push, and of a push that lands and then exits non-zero (feature 030's
      `originPushFailsAfterLanding`); whether the flag and the ref are in the same columns on both; and whether
      `git branch --unset-upstream` exits non-zero on a branch with no upstream.

**Amendment approved by**: anas.m, 2026-10-16

- [x] T003 Write the fixtures first (plan P5, Testing Strategy), under `tests/enforcement/cases/claim-feature/`: a `fail` and
      a `pass` for `CLF-018` (the stub `create-new-feature.ps1` pushes `NNN-S` to `origin` at `main`'s sha after the ledger read,
      as `CLF-017`'s stub does, against the same fixture without the rival) with `originDenyDeletes` in both directions, so an attempted withdrawal of the foreign branch would show. Expectations by hand; the warning text of P2 is pinned byte for byte; remember the harness reads stdout and
      then stderr. Run them on the parent commit and record that each `fail` fails there for the stated reason (the parent prints
      `CLAIMED:` for a branch it did not push) and each `pass` passes. List in `notes.md` every existing case whose
      `expected.txt` quotes git's rejection lines, which T006 re-expects.
- [x] T004 Bring the new rules into the coverage sweep: add `CLF-018` to `tests/enforcement/rules.json` with each
      rule's anchor and law; add an entry to `tests/enforcement/emission-idioms.json` only if the sweep reports a new site. Run
      the sweep and classify anything else it reports.
- [x] T005 Edit `scripts/claim-feature.ps1` (plan P1 to P4): push with `--porcelain`, call the push a same-name rival when it
      exited 0 and the status line for our own branch is `=`, make `$landed` `$pushOk -and -not $sameName`, print P2's warning,
      run `git branch --unset-upstream` (P3), word `$gone` for this state, and leave the withdrawal, the `$rivals` filter and
      feature 030's landed-by-commit rule alone. Nothing else changes: the preflight order, the allocation, the delegation, the
      genuine lost-race loop, the other warnings and the `-Json` object.
- [x] T006 Re-expect by hand the cases T003 listed (at least `CLF-012` and `CLF-017`; plan P6): only the git text quoted in the
      refusal changes layout, the script's own sentences do not. Say in `notes.md` which cases moved and why.
- [x] T007 Run `-Case CLF-`, `-Case TERR-`, `-Case RIT-`, the full harness and `ritual-checks.ps1`: every pre-existing case
      unchanged except the ones T006 names, every new fixture as written, the coverage report lists no unowned site in
      `claim-feature.ps1` and the exempt count is stated. Re-run T001's states under `pwsh -File` and diff against the saved text:
      successful claims are byte-identical. Record the numbers in `notes.md`.

---

## Phase 2: Guidance, close and measurement (US2; FR-007, SC-001–SC-003)

**Purpose**: adopters are told what flows down and what a wrapper may newly observe; the throwaway-`origin` race of `notes.md`
is run again against the changed script; a measurement shows that a successful claim prints the same bytes; the roadmap row is
closed.

**Territory**:

- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/digests/**`

- [ ] T008 Add a flow-down note to `adoption/updating.md` shaped like feature 030's (what was wrong, what it does now, what
      flows down, what may newly be seen — the same-name rival warning and the rejected-push text's layout — what does not change,
      what was measured, what to do). Keep digest markers within 120 characters, and every path in it resolving in an adopted
      project (doc-lint).
- [ ] T009 Update `docs/roadmap.md`: GAP-037 status text, a decisions-log entry dated the day the feature ships (recording D1 B'
      with B's measured failure, D2 A, D3 A, the FR-004 carve-out, FR-005's no-field decision, and what the work corrected), and
      this feature's row to `shipped`. Run `pwsh -File scripts/build-digests.ps1` and commit the regenerated `docs/digests/**`.
- [ ] T010 Measurement (plan P8, SC-001, SC-002): repeat the throwaway-`origin` race of `notes.md` (a rival pushes the same name
      and sha just before our push, through the `git` shim) against the changed script and say what it prints; then clones of
      FitForge, FlowBoard and ExpenseTracker made from their local directories (never the real projects, nothing pushed), the kit
      as of the parent of this feature applied, then the kit as it stands, digests rebuilt; in each state run
      `claim-feature.ps1 -NoPush -ShortName probe "a probe"` on a fresh clone, `doc-lint.ps1` and `ritual-checks.ps1`; list every
      line that moves in `notes.md` with its cause, and say plainly where none moved. Do not edit kit files while
      `update-kit.ps1` runs.
- [ ] T011 Final run on an isolated checkout of the final commit (a detached `git worktree` outside the repository, removed
      afterwards): the full harness, `ritual-checks.ps1 -Branch 031-claim-same-base-rival`, and `scope-check.ps1` on each phase
      commit. Record the numbers in `notes.md`. The owner then runs the gate.

---

## Dependencies & Execution Order

- T002 before T003 and T005 (the fixtures and the match use what the probe proved); T003 before T005 (fixtures first, shown
  failing); T005 before T006 (the cases are re-expected against the new output); T007 last.
- Phase 2 needs phase 1: the guidance describes what shipped and the measurement runs the changed script.
- Within a phase, fixtures are written and shown failing before the behaviour lands.

## Implementation Strategy

MVP is phase 1: the same-base rival detected and proved. Phase 2 can be dropped without touching it, at the cost of leaving
adopters unaware of what a wrapper may newly see. Stop after each phase for the owner's gate; one phase at a time, never ahead.
