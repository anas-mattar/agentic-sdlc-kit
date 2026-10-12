---

description: "Task list for feature 021 — load-bearing developer roster"
---

# Tasks: Load-bearing Developer Roster

**Input**: `specs/021-developer-roster/spec.md`, `plan.md` (decisions D1–D10)
**Prerequisites**: spec.md and plan.md approved (including the D5 amendment); no new dependency, no new script file.
**Amendment approved by**: anas.m, 2026-10-11

**Tests**: every rule ships with a passing and a failing harness fixture in the same phase as the behaviour,
expectations written by hand (feature 015). New fixtures are run against the parent commit before the code
changes and must fail there, so each is shown to measure something. Phase evidence goes in `notes.md`, never here.
Rule ids below say "next free" where the number is assigned at the time, from `tests/enforcement/rules.json`.

**Organization**: four phases, each independently revertible. Phase 4 must be reverted before phase 3, 3 before 2,
2 before 1. The full harness is run on an isolated checkout of the final commit, never in a working directory
someone is using.

---

## Phase 1: The reader and the doctor (US1; FR-001–FR-004, FR-008, FR-009 for these)

**Purpose**: `Get-DeveloperMode` learns the object form and returns a normalised `Roster`; the doctor reports it.
No existing verdict moves.

**Territory**:

- `scripts/adoption-lib.ps1`
- `scripts/verify-kit.ps1`
- `tests/**`

- [x] T001 Record the baseline on the parent commit in `notes.md`: the full harness count, the counts from
      `Run-Tests.ps1 -Case VK-`, `-Case CRIT-` and `-Case CLAIM-`, and the doctor's exact output on three throwaway
      records (no `developers`; a string-only roster of two; a string-only roster of one), so "byte-identical"
      is measured against saved text.
- [x] T002 Write the fixtures first: for each roster shape a doctor case and, where the arm changes, an
      enforcement-pack case. `fail`/`pass` pairs for: an object entry with no usable `name` (dropped, reported);
      `repos` that is not an array; a `repos` name `codeRepos` does not declare; `canApproveCritical` that is not a
      boolean (reported, read as not permitted); the same person as a string and an object (one developer);
      and as `pass` a string-only roster, an object roster, a mixed roster, an object with only `name`, an
      absent roster. Expectations by hand. Run them on the parent commit and record that each `fail` fails there
      for the stated reason.
- [x] T003 Add the rules to `tests/enforcement/rules.json` (next free ids; anchors, law, summary) and any new
      accumulator to `tests/enforcement/emission-idioms.json`, so the coverage test sees every new site.
- [x] T004 Extend `Get-DeveloperMode` in `scripts/adoption-lib.ps1` (plan D1–D3): accept the object form,
      return `Roster` (`Name`, `Repos`, `CanApproveCritical`), deduplicate across both forms, keep `Mode`, `Count`,
      `Declared`, `Why` and `Problems` identical for a string-only or absent record, add the new `Problems` for the
      cases in plan D2. Update the file's header.
- [x] T005 Edit `scripts/verify-kit.ps1` (plan D10): report each malformed entry by position and cause and each
      unknown `repos` name; state the roster read only when at least one entry is an object, so a string-only
      project's doctor output is byte-identical.
- [x] T006 Run `-Case VK-`, `-Case CRIT-`, `-Case CLAIM-`, the full harness and `ritual-checks.ps1`: every
      pre-existing case unchanged, every new fixture as written, coverage reports each new site fixtured. Re-run
      the doctor on T001's three records and diff against the saved output: no byte differs.

---

## Phase 2: The Critical reviewer (US3; FR-006)

**Purpose**: in the team arm, the Reviewer of a Critical feature must be on the roster and permitted to approve.

**Territory**:

- `scripts/enforcement-pack.ps1`
- `tests/**`

- [x] T007 Fixtures first, next free `CRIT-T` ids: `fail` a Reviewer who is not on the roster, `fail` a Reviewer
      whose entry sets `canApproveCritical` to `false`, `fail` one whose flag is a non-boolean; `pass` a Reviewer
      on the roster and permitted, a Reviewer on a string-only roster (permitted by default), and a case in the
      solo arm showing it is untouched. Expectations by hand; run them on the parent commit.
- [x] T008 Edit `Invoke-CriticalTeamEvidence` in `scripts/enforcement-pack.ps1` (plan D6): after the existing
      reviewer-is-not-owner check, fail a Reviewer not on `Roster` and a Reviewer whose entry is not permitted,
      two messages naming the reviewer and the roster; do not grade a placeholder or empty Reviewer twice. Rewrite
      the block comment that says the roster is "counted and nothing more" to state what membership now proves
      and does not (plan D9).
- [x] T009 Run `-Case CRIT-`, the full harness and `ritual-checks.ps1`; nothing pre-existing moves.

---

## Phase 3: The claim ledger (US2, US4; FR-005, FR-007)

**Purpose**: a claim's Owner is on the roster, and an Owner's non-stale active claims are counted against the cap;
neither changes a project with no roster, and an unreadable tip date is UNGRADED.

**Territory**:

- `scripts/roadmap-claim-check.ps1`
- `scripts/ritual-checks.ps1`
- `tests/**`

- [x] T010 Fixtures first, next free `CLAIM-` ids, built on the existing fixture `origin`: `fail` a declared
      roster and a claim whose row Owner is a stranger; `pass` the Owner on the roster in another case; `pass`
      (and unchanged, byte for byte) a project with no roster, a string-only roster whose Owner is on it, an
      `idea` row, a blank or `—` Owner, the checked branch's own claim; WIP: one claim passes, two pass with the
      one note, three fail, a stale claim is not counted, a `shipped` claim is not counted; a roadmap with no
      `Owner` column under a declared roster prints that it graded neither; an unreadable tip date is UNGRADED.
      Expectations by hand; run them on the parent commit.
- [x] T011 Edit `scripts/roadmap-claim-check.ps1` (plan D4): dot-source `scripts/adoption-lib.ps1`, find the
      `Owner` column of the same table, and for each claim with a non-`idea` row and a real Owner cell fail an
      Owner not on `Roster`, naming the claim, the Owner and the declared names. Graded only with a usable roster;
      with none, output is byte-identical to today.
- [x] T012 In the same script (plan D7): per Owner, count the claims whose row Status is `specified` or `in
      progress` and whose tip is not stale (14 days), reading tip dates only for an Owner with two or more
      candidate claims, by `git log -1 --format=%ct` on the sha `ls-remote` returns and, if the object is
      absent, `git fetch --quiet origin <branch>`; more than two fails, exactly two passes with one note, an
      unreadable date makes that Owner's count `UNGRADED` with the reason. Graded only with a usable roster.
- [x] T013 Edit `scripts/ritual-checks.ps1` (plan D8): add `roadmap-claims` to the members that can report
      UNGRADED, with its harness fixture; the member's exit code is unchanged.
- [x] T014 Run `-Case CLAIM-`, `-Case RITUAL-` (or the ritual-checks cases), the full harness and
      `ritual-checks.ps1`; nothing pre-existing moves.

---

## Phase 4: Guidance, flow-down and bookkeeping (US5; FR-010, FR-011)

**Purpose**: tell owners what the roster can hold and what each check now does, tell adopters what flows down and
what they may newly see, prove with a measurement that no adopted project's verdict moves unannounced, and close
the roadmap row. No script changes.

**Territory**:

- `docs/sdlc/critical-delivery.md`
- `docs/sdlc/team-workflow.md`
- `adoption/updating.md`
- `adoption/greenfield.md`
- `docs/roadmap.md`
- `docs/digests/**`
- `kit-manifest.json`

- [x] T015 [P] Update `docs/sdlc/critical-delivery.md` item 5: the team arm now also requires the Reviewer on
      the roster and permitted; the roster shapes; and the plan D9 sentence, that membership catches a stranger or
      a name the project did not declare and does not prove identity. Keep digest markers within 120 characters.
- [x] T016 [P] Update `docs/sdlc/team-workflow.md`: the roster shapes, the Owner reading, the WIP counter (what
      it counts, the stale and the pipelining cases, what only a human can see: a pull request being open), and
      that all of it is graded only where a roster is declared.
- [x] T017 [P] Add a flow-down note to `adoption/updating.md`, and update `adoption/greenfield.md` where it
      describes the `developers` field: what flows down, what an owner may newly see, what to do, the
      measurement, and that a string-only roster is unchanged.
- [x] T018 Measure on clones of the three adopted projects, never touching the real ones: apply the update,
      run the old and new checks (`verify-kit.ps1`, `enforcement-pack.ps1`, `roadmap-claim-check.ps1`,
      `ritual-checks.ps1`) in each state, list every verdict that moved with its cause. A moved verdict is a
      finding, not a rounding error. Record the table in `notes.md`.
- [x] T019 Regenerate the digests (`pwsh -File scripts/build-digests.ps1`). Flip the roadmap row for the
      developer roster to `shipped` with its spec link unbracketed, and add the decisions-log entry, stating what
      stays open by decision (membership is not identity; `repos` is read by nothing; assignment authority is out).
- [ ] T020 Run `pwsh -File scripts/ritual-checks.ps1`, and the full
      `pwsh -File tests/enforcement/Run-Tests.ps1` on an isolated checkout of the final commit. Every member
      OK. Then stop and ask the owner to run the gate.

---

## Dependencies & Execution Order

- Phase 1 first; the reader changes nothing observable and must be green before anything depends on it.
- Phase 2 needs phase 1's reader only.
- Phase 3 needs phase 1's reader and nothing from phase 2; it can be reviewed on its own.
- Phase 4 needs phases 1–3 (the guidance describes what shipped).
- Within a phase, fixtures are written and shown failing before the behaviour lands. `[P]` tasks touch
  different files.

## Implementation Strategy

MVP is phases 1–2: the roster readable, and the strictest lane's reviewer checked against it. Phase 3 can be
dropped without touching them. Stop after each phase for the owner's gate; one phase at a time, never ahead.
