---

description: "Task list for feature 030 — claim-feature.ps1's ledger read and refused push are named states"
---

# Tasks: claim-feature.ps1's ledger read and refused push are named states

**Input**: `specs/030-claim-ledger-read-named-state/spec.md`, `plan.md` (decisions P1–P8)
**Prerequisites**: spec.md approved (anas.m, 2026-10-16; D1 A, D2 A, D3 A); plan.md approved (anas.m, 2026-10-16); no new
dependency, no new script file.

**Tests**: every state the work names ships with a passing and a failing harness fixture in the same phase as the
behaviour, expectations written by hand (feature 015). New fixtures are run against the parent commit before the code
changes and must fail there, so each is shown to measure something. Every harness field is probed in a throwaway fixture
before a rule depends on it (plan P5). Phase evidence goes in `notes.md`, never here. Rule ids: `CLF-008` to `CLF-014`
(`CLF-001` to `CLF-007` are feature 023's; `CLAIM-` belongs to `roadmap-claim-check.ps1`).

**Organization**: two phases, each independently revertible. Phase 2 must be reverted before phase 1. The full harness is
run on an isolated checkout of the final commit, never in a working directory someone is using.

---

## Phase 1: The ledger read and the rejected push (US1, US2; FR-001–FR-003, FR-006 in part)

**Purpose**: a failed ledger read reaches the script's own refusal and exit 1 from each of its three callers, and says
whether the claim may be live; a push the remote rejects, with no rival, is refused once and not read as a lost race. Each
is proved by a fail and a pass; the harness gains its first way to fail a ledger read on a chosen call. A successful claim and
feature 023's seven refusals print what they printed before. The withdrawal and the re-fetch are phase 2.

**Territory**:

- `scripts/claim-feature.ps1`
- `tests/**`

- [x] T001 Record the baseline on the parent commit in `notes.md`: the full harness count, the coverage report's exempt-rule
      count and its site counts for `claim-feature.ps1`, and, run as `pwsh -File scripts/claim-feature.ps1 -ShortName probe
      "a probe"` in purpose-built directories, the exit code and output of (a) a ledger read that fails (the throw: measure its
      exit under `pwsh -File` and through the harness's launcher, which the spec leaves unmeasured on purpose), (b) the
      existing `CLF-007` push that fails with no rival (three warnings and the three-times refusal), and (c) a successful claim
      with no origin, with an origin that takes the push, with `-NoPush`, and with one genuine renumbering, as saved text for the
      byte comparison.
- [x] T002 Probe the harness fields (plan P5) in throwaway fixtures and record the result in `notes.md` before any rule
      depends on it: (a) a counting wrapper on `remote.origin.uploadpack` that runs the real `git-upload-pack` and exits
      non-zero on the chosen call, checking the call order (first fetch, first read, then each later read and re-fetch) on this
      machine and on a CI runner; if it misbehaves, the `PATH` shim fallback; (b) a stub `create-new-feature.ps1` that creates a
      branch with our number in the nested origin as a rival; (c) whether a `pre-push` hook can make a rival appear at every
      attempt, which decides `CLF-007` (plan P6).
- [x] T003 Write the fixtures first (plan P2, P3, P6, Testing Strategy), under `tests/enforcement/cases/claim-feature/`: a
      `fail` and a `pass` for each of `CLF-008` (the first read fails against one that succeeds), `CLF-009` (the read after a
      push that succeeded fails against one that does not), `CLF-010` (the read after a push that failed fails against one
      that does not), `CLF-011` (the read after a lost race and a withdrawal fails against one that does not; needs T002(b)) and
      `CLF-012` (a push that fails with no rival against one that is accepted; this is the existing `CLF-007` `fail` and `pass`
      moved and re-expected, plan P6). Add success-path `pass` cases for one genuine renumbering (a stub that creates a rival)
      and one empty ledger (plan P1's empty-versus-failed read). Expectations by hand with the P2 messages; remember the
      harness reads stdout and then stderr. Run them on the parent commit and record that each `fail` fails there for the
      stated reason and each `pass` passes. `CLF-007` keeps its id for the three-rivals state only if T002(c) built it;
      otherwise it is exempt in T005 with a written reason.
- [x] T004 Add the `originFailCall` recipe field to `tests/enforcement/lib/FixtureRepo.psm1` (refused without `origin`, with a
      self-test in `tests/enforcement/Harness.Tests.ps1`), as probed in T002(a), and the counting wrapper under the case
      directory. Nothing else in the harness changes.
- [x] T005 Bring the new rules into the coverage sweep: add `CLF-008` to `CLF-012` (and `CLF-007` as decided in T003) to
      `tests/enforcement/rules.json` with each rule's anchor and law; update `CLF-007`'s summary, law and notes to say it was
      re-expected; add an entry to `tests/enforcement/emission-idioms.json` only if the sweep reports a new site. If
      `CLF-007` is exempt, say why in its `notes`. Run the sweep and classify anything else it reports.
- [x] T006 Edit `scripts/claim-feature.ps1` (plan P1, P2, P3): `Get-RemoteFeatureHeads` reports a failure on a channel
      separate from an empty ledger; the three callers refuse with the P2 messages through `Stop-Refused`; the push's output is
      captured; the race loop follows the P3 decision table. Lines 140 and 144 and `Get-NextFreeNumber` do not change. Nothing
      else changes: the preflight order, the allocation, the delegation, the genuine lost-race loop, the warnings and the
      `-Json` object.
- [x] T007 Run `-Case CLF-`, `-Case TERR-`, `-Case RIT-`, the full harness and `ritual-checks.ps1`: every pre-existing case
      unchanged except the one named in plan P6, every new fixture as written, the coverage report lists no unowned site in
      `claim-feature.ps1` and the exempt count is stated. Re-run T001's states under `pwsh -File` and diff against the saved
      text: the seven refusals and the successful claims are byte-identical, and the states that changed say what the plan
      says they say. Record the numbers in `notes.md`.

---

## Phase 2: The withdrawal, the re-fetch, guidance and measurement (US3, US4; FR-004, FR-006, FR-008)

**Purpose**: a failed withdrawal and a failed re-fetch in the race loop are named; the new states are all proved; adopters are
told what flows down and what a wrapper may newly observe; a measurement shows that a successful claim and the seven
refusals print the same bytes; the roadmap row is closed.

**Territory**:

- `scripts/claim-feature.ps1`
- `tests/**`
- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/digests/**`

- [x] T008 Probe `receive.denyDeletes` on the nested origin as the way to fail `git push origin --delete` (plan P5) and record
      it in `notes.md`. Write the fixtures first: a `fail` and a `pass` for `CLF-013` (a withdrawal that fails against one that
      works, after a lost race built by T002(b)'s stub) and `CLF-014` (a re-fetch that fails against one that does not, reusing
      `originFailCall`); add the `originDenyDeletes` recipe field to `FixtureRepo.psm1` with its self-test. Run them on the
      phase 1 tip and record that each `fail` fails there for the stated reason (the claim continues on a ledger it did not
      refresh, or leaves a stale branch unreported).
- [x] T009 Add `CLF-013` and `CLF-014` to `tests/enforcement/rules.json`; run the sweep and classify anything else it reports.
- [x] T010 Edit `scripts/claim-feature.ps1` (plan P4, P2 rows 6 and 7): the withdrawal at line 140 and the re-fetch at line
      144 are checked and refuse with the P2 messages. Nothing else changes.
- [x] T011 Run `-Case CLF-`, `-Case TERR-`, `-Case RIT-`, the full harness and `ritual-checks.ps1`: every pre-existing case
      unchanged, every new fixture as written, no unowned site. Record the numbers in `notes.md`.
- [x] T012 Add a flow-down note to `adoption/updating.md` shaped like feature 023's (what was wrong, what it does now, what
      flows down, what may newly be seen, what does not change, what was measured, what to do). Keep digest markers within 120
      characters, and every path in it resolving in an adopted project (doc-lint).
- [x] T013 Update `docs/roadmap.md`: GAP-036 status text, a decisions-log entry dated the day the feature ships (recording
      D1 A, D2 A, D3 A and what the work corrected, including the `CLF-007` outcome), and this feature's row to `shipped`. Run
      `pwsh -File scripts/build-digests.ps1` and commit the regenerated `docs/digests/**`.
- [x] T014 Measurement (plan P8, SC-001): clones of FitForge, FlowBoard and ExpenseTracker made from their local directories
      (never the real projects, nothing pushed), the kit as of the parent of this feature applied, then the kit as it stands,
      digests rebuilt; in each state run `claim-feature.ps1 -NoPush -ShortName probe "a probe"` on a fresh clone,
      `doc-lint.ps1` and `ritual-checks.ps1`; list every line that moves in `notes.md` with its cause, and say plainly where
      none moved. Do not edit kit files while `update-kit.ps1` runs.
- [x] T015 Final run on an isolated checkout of the final commit (a detached `git worktree` outside the repository, removed
      afterwards): the full harness, `ritual-checks.ps1 -Branch 030-claim-ledger-read-named-state`, and `scope-check.ps1` on
      each phase commit. Record the numbers in `notes.md`. The owner then runs the gate.

---

## Phase 3: A push that reports failure but landed (amendment, 2026-10-16; US2 scenarios 4 and 5, FR-003)

**Amendment approved by**: anas.m, 2026-10-16

**Purpose**: the review finding F1 of phase 1: a push that exits non-zero after the remote accepted it is read as landed, from the ledger the script has just read, so the claim is made (or withdrawn when a rival is also there) instead of reported as rejected with `Nothing was claimed`. The first three tasks write what is new and show it failing; nothing else in the script changes.

**Territory**:

- `scripts/claim-feature.ps1`
- `tests/**`
- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/digests/**`

- [ ] T016 Write the fixtures first: a `fail` and a `pass` for `CLF-015` (a push whose `receive-pack` exits 1 after landing, no rival, against the same claim without it) and `CLF-016` (the same landed push beside a stub rival, against one that exits 0), differing only in the condition, with the `originPushFailsAfterLanding` recipe field in `tests/enforcement/lib/FixtureRepo.psm1` and its self-tests. Run them on the current `main` script and record that each `fail` fails there for the stated reason.
- [ ] T017 Edit `scripts/claim-feature.ps1` (plan P3 as amended): compute `landed` from the exit code and the ledger just read, use it for the success, the withdrawal and the `` wording, and print the P2 warning when a push that exited non-zero is taken as landed. Add `CLF-015` and `CLF-016` to `tests/enforcement/rules.json`; run the coverage sweep.
- [ ] T018 Run `-Case claim-feature`, `-Case TERR-`, `-Case RIT-`, the full harness on an isolated checkout and `ritual-checks.ps1`: every earlier fixture unchanged, no unowned site. Update the flow-down note in `adoption/updating.md` (what a wrapper may newly see: a failed push whose branch landed is now a claim made, with a warning), `docs/roadmap.md` and the digests; record the numbers and the amendment in `notes.md`. A fresh-context AI review of this phase, then the owner's gate.

---

## Dependencies & Execution Order

- T002 before T003 and T004 (the fixtures use what the probe proved); T003 before T006 (fixtures first, shown failing).
- Phase 2 needs phase 1 (it uses `originFailCall`, the P2 message shape and the moved `CLF-007` case); the guidance describes
  what shipped, and the measurement runs the changed script.
- Within a phase, fixtures are written and shown failing before the behaviour lands.

## Implementation Strategy

MVP is phase 1: a failed ledger read and a rejected push named, proved. Phase 2 can be dropped without touching it, at the cost
of leaving the withdrawal and the re-fetch silent (spec D1 B's shape). Stop after each phase for the owner's gate; one phase at
a time, never ahead.
