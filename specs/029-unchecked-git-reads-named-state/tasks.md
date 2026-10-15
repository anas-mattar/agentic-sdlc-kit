---

description: "Task list for feature 029 — make every unchecked git read a named state, not nothing"
---

# Tasks: Make every unchecked `git` read a named state, not "nothing"

**Input**: `specs/029-unchecked-git-reads-named-state/spec.md`, `plan.md` (decisions D1–D9)
**Status**: Approved 2026-10-15 (owner: anas.m)
**Prerequisites**: spec.md approved (anas.m, 2026-10-15, Decision 1 option B, Decision 2 the 027/028 lane split); plan.md approved (anas.m, 2026-10-15), including D2 (one failure per
distinct read per run), D3 (`PhaseSizeWarning` is `UNGRADED`, not a failure), D6 (`territory-check.ps1`: own-tree reads refuse, other-branch reads are `ungraded` records) and five
phases, before phase 1 starts; no new dependency, no new script file.

**Tests**: every graded read ships with a passing and a failing harness fixture in the same phase as the behaviour, expectations written by hand. New fixtures are run against the
parent commit before the code changes and must fail there (or be named controls that pass there by design). **Fixtures are built from field shapes** (plan D7): the reproduced Micro
phase over the bound, a renamed approved document, a `docs/` branch, the readable and empty controls. The damage is a `truncateBlob` (a **directory** path breaks a subtree, 028's
finding); where it cannot reach a read, the nearest state is used and `notes.md` says so. Each fixture that guards a branch of the new code is also shown failing under a mutation of
that code, restored byte for byte (feature 025's method). Phase evidence goes in `notes.md`, never here. Rule ids: `GITREAD-001`..`GITREAD-014` (one per graded read G1–G14) and the
existing `MICRO-*`, `AMEND-*`, `CRIT-*` controls.

**Organization**: five phases, each independently revertible, reverted in reverse order. The full harness is run on an isolated checkout of the final commit, never in a working
directory someone is using. G-numbers refer to the table in `plan.md`.

---

## Phase 1: The probe, the generic reader, the policy, the Micro and phase-size reads (US1; G1–G3; FR-001, FR-002, FR-005, FR-008, FR-009)

**Purpose**: the inventory is probed against a damaged repository first; `Read-GitLines` and `Add-GitReadUnreadable` exist; `Invoke-MicroLaneCheck` and
`Invoke-PhaseSizeWarningCheck` read through them, so a 700-line Micro phase whose blob is unreadable never ends on `OK`. A readable, empty or no-base run prints what it printed.

**Territory**:

- `scripts/enforcement-pack.ps1`
- `tests/**`

- [x] T001 Record the baseline on the parent commit in `notes.md`: the full harness count on an isolated detached worktree, and the exact output and exit of a readable Micro branch
      with a 700-line phase commit (the 400-line failure), a readable Micro branch under the bound, and an empty-diff branch. Reproduce the gap on a throwaway repository: the same
      700-line commit with one of its blobs truncated prints `enforcement-pack: OK`.
- [x] T002 The probe (plan D8): for **every** unchecked read in the plan's inventory (graded, out of scope and named-already), run it against a damaged repository (a deleted,
      garbage and truncated blob, an unreadable tree) and record in `notes.md` a table: read, site, exit code, whether it returned lines, and the class the probe supports. For each
      read the plan predicted *out of scope* or *named already*, state whether the probe confirms it. **If the probe moves a read into the graded set, or shows a G-read is not
      reachable, stop and report: the plan is amended only with an approver record from the owner, never by the author.** Confirm that `truncateBlob` reaches each read, or name the
      nearest state.
- [x] T003 Write the phase 1 fixtures first (plan D7): `GITREAD-001` (G1: Micro, 700 lines, blob truncated: a named `MicroLane` failure, exit 1; control: readable, the 400-line
      failure unchanged), `GITREAD-002` (G2: the rev-list / subject read fails: the walk names itself), `GITREAD-003` (G3: `PhaseSizeWarning`, blob truncated: one `UNGRADED` line,
      exit unchanged; control: readable, byte-identical, and a readable commit with zero changed lines). Each shown failing on the parent or named a control. Record each result.
- [x] T004 Inventory the rules in `tests/enforcement/rules.json`: `GITREAD-001`..`003` with anchor and law (027 D8, 028 D1, spec FR-002..FR-005); run the recall sweep first and
      classify anything else it reports.
- [x] T005 Edit `scripts/enforcement-pack.ps1` (plan D1, D2, D3): `Read-GitLines` beside `Read-DiffLines` (exit code captured in the next statement; empty `Lines` on a non-zero exit);
      `Add-GitReadUnreadable` beside `Add-DiffUnreadable` (numbered: one failure per distinct read per run; Lite: one `UNGRADED` line per reader); `Invoke-MicroLaneCheck` and
      `Invoke-PhaseSizeWarningCheck` through them. `Read-DiffLines`, `Add-DiffUnreadable` and every other member are not edited. Change the `LIMITS` comments that say these reads are
      unchecked to say what is now named and what stays open.
- [x] T006 Show a mutation for each fixture that guards a branch of the new code and record it: read the exit code a statement late; keep partial output; enter the state on empty
      output instead of a non-zero exit; drop the per-read key so a second read is hidden; call the old bare `git show --numstat` in one site. Each is shown failing a fixture, then
      restored byte for byte.
- [x] T007 Run `-Case GITREAD-`, `-Case MICRO-`, `-Case DIFF-`, `-Case LITE-`, the full harness and `ritual-checks.ps1`: every pre-existing case unchanged, every new fixture as
      written, no unowned emission site. Re-run T001's reproduction: the truncated 700-line Micro branch now fails with a name, not `OK`. Record the numbers. Then stop and ask the
      owner to run the gate.

---

## Phase 2: The amendment and history reads (US2; G4–G10; FR-002–FR-004, FR-006)

**Purpose**: a failed `git log`, `rev-list`, `git show`, `rev-parse` or `ls-tree` inside the amendment check is named instead of read as an empty result, and a rename whose blobs cannot be
read is graded instead of skipped (G9, the `$null -eq $null` shape).

**Territory**:

- `scripts/enforcement-pack.ps1`
- `tests/**`

- [x] T008 Record the baseline in `notes.md`: the full harness count on the parent of this phase and the exact output of phase 1's `GITREAD-*` cases. Reproduce on the parent: a renamed
      approved document whose blob is truncated is skipped (no grading, `OK`) — G9; a truncated name-status read leaves every commit with no rows — G5.
- [x] T009 Write the fixtures first (plan D7, D4): `GITREAD-004` (G4 `Get-CommitMetaBatch`), `-005` (G5 `Get-NameStatusBatch`), `-006` (G6 the range's `rev-list`: numbered refusal; Lite
      `UNGRADED`, where the parent is silent), `-007` (G7 `Get-BlobLines`), `-008` (G8 `Get-AddedRecordLines`), `-009` (G9: a renamed approved document, a blob truncated: graded, not
      skipped; control: intact content, still skipped as today), `-010` (G10 the renumbering `ls-tree`). Each with a readable control; each shown failing on the parent or named a control.
      Where one data state breaks two reads, say so in `notes.md` and guard the second by a mutation only, naming it an exemption with the reason.
- [x] T010 Inventory the rules: `GITREAD-004`..`010` with anchor and law; update the notes of the existing `AMEND-*` rules whose sites are now reached through the reader; run the recall
      sweep first.
- [x] T011 Edit `scripts/enforcement-pack.ps1` (plan D2, D3, D4): the G4–G10 reads through `Read-GitLines`; each failure uses the amendment check's existing refusal shape (numbered:
      `AmendmentAuthority: cannot grade '<b>' — ...`; Lite: `UNGRADED`), not a new message; G9 grades the rename when either `rev-parse` fails. Reads already named (`Get-GradedDocSet`,
      `Get-FeatureDocMap`, `Get-AutoMergeTree`, `Test-CheckAbsentForReal`, `Get-CheckPresenceSet`) are not edited. Update the amendment check's `LIMITS` comments.
- [x] T012 Show a mutation for each fixture that guards a branch of the new code and record it (exit code read late, partial output kept, the `$null -eq $null` arm restored, the
      per-read key dropped, the Lite arm made silent). Each restored byte for byte.
- [x] T013 Run `-Case GITREAD-`, `-Case AMEND-`, `-Case CRIT-`, `-Case LITE-`, the full harness and `ritual-checks.ps1`: every pre-existing case unchanged, every new fixture as written, no
      unowned site. Re-run T008's reproductions. Record the numbers. Then stop and ask the owner to run the gate.

---

## Phase 3: The Critical-arm and surface-exception reads (US2; G11, G12; FR-002–FR-004)

**Purpose**: the cooling-off check names a failed `git log --follow` as a failed read (not "no git history"), and `Get-SurfaceExceptions` no longer falls back to the runner's clock without saying so.

**Territory**:

- `scripts/enforcement-pack.ps1`
- `tests/**`

- [x] T014 Record the baseline in `notes.md`: the full harness count on the parent of this phase; reproduce on the parent: the cooling-off check fails with the wrong cause on a failed
      read (G11), and a surface exception is dated against the runner's clock when the commit date cannot be read (G12).
- [x] T015 Write the fixtures first: `GITREAD-011` (G11: a Critical feature whose review file's history cannot be read: the failure names the read, not "no git history"; control: a
      file with history, and an uncommitted file, which keeps its existing message), `GITREAD-012` (G12: an unreadable `HEAD` date: an `UNGRADED` note on every lane; control: readable,
      byte-identical).
- [x] T016 Inventory the rules: `GITREAD-011`, `-012` with anchor and law; run the recall sweep first.
- [x] T017 Edit `scripts/enforcement-pack.ps1` (plan D3): the two reads through `Read-GitLines`; G11 keeps its failure and names the true cause; G12 keeps the author's-day-else-clock rule
      only when git succeeds and prints no date. `LIMITS` comments updated.
- [x] T018 Show a mutation for each fixture that guards a branch of the new code and record it; restore byte for byte.
- [x] T019 Run `-Case GITREAD-`, `-Case CRIT-`, the full harness and `ritual-checks.ps1`; record the numbers. Then stop and ask the owner to run the gate.

---

## Phase 4: `scripts/territory-check.ps1` (US3; G13, G14; FR-007)

**Purpose**: the uncommitted-tree diff and `git ls-remote` refuse when they fail; an open branch whose diff or last-commit read fails is an `ungraded` record, never "no overlap".

**Territory**:

- `scripts/territory-check.ps1`
- `tests/**`

- [x] T020 Record the baseline in `notes.md`: the territory-check cases' count on the parent of this phase (the first step confirms the directory the existing cases use; plan says
      `tests/enforcement/cases/territory-check/`, to be confirmed), and the exact output and exit of a clean run. Reproduce on the parent: an open branch whose diff cannot be read is
      reported as no overlap.
- [x] T021 State, at the top of this phase's section in `notes.md`, the exit code and output shape of each of the four paths (plan D6): own committed diff (already `Stop-Refused`),
      own uncommitted diff (new refusal), `ls-remote` (new refusal), other-branch diff and last-commit reads (new `ungraded` record with cause `diff-failed`). No exit code is new; if one
      would be, stop and report.
- [x] T022 Write the fixtures first: `GITREAD-013` (G13: the uncommitted diff fails; `ls-remote` fails: each a refusal), `GITREAD-014` (G14: an open branch's diff fails: an `ungraded`
      record, not an overlap and not "no overlap"; control: readable, byte-identical). Each shown failing on the parent or named a control.
- [x] T023 Inventory the rules: `GITREAD-013`, `-014` with anchor and law; run the recall sweep first.
- [x] T024 Edit `scripts/territory-check.ps1` (plan D6): the four reads check their exit codes; no kit verdict word is added (GAP-029 stays open); `Read-CodeRef` and the other named
      paths are not edited. Update the script's `LIMITS` wording.
- [x] T025 Show a mutation for each fixture that guards a branch of the new code and record it; restore byte for byte.
- [ ] T026 Run the territory-check cases, `-Case GITREAD-`, the full harness and `ritual-checks.ps1`; record the numbers. Then stop and ask the owner to run the gate.

---

## Phase 5: Guidance, retirement of the limits, flow-down note, replay (US4; FR-010, FR-011)

**Purpose**: every document that states the limit says what is now named and what stays open; adopters get a flow-down note; the replay on real history shows no healthy output changed.

**Territory**:

- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/digests/**`
- `scripts/enforcement-pack.ps1`
- `scripts/territory-check.ps1`

- [ ] T027 Run the replay (plan D9) per merge, over real history, in the shape CI grades a pull request: the parent kit's scripts against the new ones over each merged `NNN-*`, `fix/`,
      `chore/` and `docs/` branch in this kit's history and in clones of the three adopted projects, reporting the runs, the outputs that differ (expected none), the reads each run
      exercised (counted by an instrumented copy of the reader), the merges the branch patterns miss, and what the replay does not show (damaged repositories: the fixtures do).
      Record it in `notes.md`.
- [ ] T028 Write the flow-down note in `adoption/updating.md`, in the shape of 026, 027 and 028 (what was wrong, what it does now, what flows down, what an owner may newly see, what does
      not change, the known limits, what was measured, what to do), superseding 028's open-limit wording and naming what stays open (`cat-file -e` and `rev-parse --verify --quiet`
      cannot tell absent from unreadable; silent corruption; GAP-029).
- [ ] T029 Update `docs/roadmap.md`: GAP-035 shipped (owner, spec path, merge evidence), its idea row under Ideas closed, and any new row the probe or replay produced; fix the `LIMITS`
      comments in the two scripts that still describe the old state.
- [ ] T030 Regenerate the digests with `pwsh -File scripts/build-digests.ps1`; run `pwsh -File scripts/ritual-checks.ps1` and the full harness on an isolated checkout of the final
      commit; record the numbers in `notes.md`. Then stop and ask the owner to run the gate.

---

## Amendment 1 — fixtures versus mutation guards (plan Amendment 1), 2026-10-15

The probe (T002) found seven reads with no reachable data state. The tasks stand as written with one change of guard: where a task above names a fixture for G2a, G2b, G3, G4, G6, G12 or
G14a (`GITREAD-002`, the G3 half of `-003`, `-004`, `-006`, `-012`, the G14a half of `-014`), that read is guarded by its **mutation** (T006, T012, T018, T025) and recorded in `notes.md`
as an exemption with the reason; the readable control for each still runs as part of the existing cases.

**Amendment approved by**: anas.m, 2026-10-15

---

## Amendment 2 — G8, G9, G10 are injection-guarded (plan Amendment 2), 2026-10-16

Where a task above names a fixture for G8, G9 or G10 (phase 2: T009's `-008`, `-009`, `-010`), that read is guarded by its **injected-failure check** (T012) and recorded in `notes.md` as an
exemption with the reason, as Amendment 1 does for the other unreachable reads.

**Amendment approved by**: anas.m, 2026-10-16
