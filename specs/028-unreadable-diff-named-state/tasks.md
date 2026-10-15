---

description: "Task list for feature 028 — make an unreadable diff a named state, not an empty changed-file list"
---

# Tasks: Make an unreadable diff a named state, not an empty changed-file list

**Input**: `specs/028-unreadable-diff-named-state/spec.md`, `plan.md` (decisions D1–D10)
**Prerequisites**: spec.md approved (anas.m, 2026-10-15, Decision 1 option B, Decision 2 the three readers); plan.md approved (anas.m, 2026-10-15), including D3 (the numbered lane
fails once per run, the Lite lane names each check), D2 (git's exit code, not its message), D4 (the Lite gate names itself) and three phases, before phase 1 starts; no new
dependency, no new script file.

**Tests**: every rule ships with a passing and a failing harness fixture in the same phase as the behaviour, expectations written by hand (feature 015). New fixtures are run
against the parent commit before the code changes and must fail there (or be named controls that pass there by design), so each is shown to measure something. **Fixtures are built
from field shapes** (plan D9): the spec's `fix/` reproduction, 026's numbered unreadable shape, a `docs/` branch, the partial list. The damage is a `truncateBlob` naming a
**directory** path (a subtree), not `truncateCommit` (a truncated commit lands in the already-named no-base state, plan Summary). Each fixture that guards a branch of the new code
is also shown failing under a mutation of that code, and the code is restored byte for byte (feature 025's method). Phase evidence goes in `notes.md`, never here. Rule ids: `DIFF-001`
and `DIFF-002` and `LITE-*` variants.

**Organization**: three phases, each independently revertible. Phase 3 must be reverted before phase 2, and phase 2 before phase 1. The full harness is run on an isolated checkout of
the final commit, never in a working directory someone is using.

---

## Phase 1: The helper, the count line and the first two lane arms (US1, US2, US3; FR-001–FR-004, FR-007–FR-009)

**Purpose**: `Get-ChangedFiles` reads through one helper; an unreadable diff is named in the count line, fails once on a numbered branch, and is named UNGRADED for
`LiteAndAbuse` on `fix/` and `chore/`; a partial list is discarded. A readable, empty, base-less, shallow or trunk run prints exactly what it printed. The other two readers are phase 2.

**Territory**:

- `scripts/enforcement-pack.ps1`
- `tests/**`

- [x] T001 Record the baseline on the parent commit in `notes.md`: the full harness count on an isolated detached worktree, and the exact output and exit of a readable `fix/`
      branch carrying `package.json` and a migration, a `docs/` branch changing only `README.md`, an empty-diff branch and `AMEND-009/pass`. Reproduce the gap on a throwaway
      repository (the spec's table): the `src` subtree of the branch's commit truncated prints `0 changed file(s)` and `enforcement-pack: OK`. Confirm from a recipe that
      `truncateBlob` naming a directory path reaches the state (plan Summary); if a shape cannot be expressed, add a task for it here.
- [x] T002 Write the fixtures first (plan D9, phase 1 rows), each pair differing in one condition and each shown failing on the parent or named as a control that passes there
      by design: a readable `fix/` branch adding `package.json` and a migration (control: three `LiteAndAbuse` failures, exit 1); the same with the `src` subtree truncated
      (count line named, one UNGRADED line for `LiteAndAbuse`, verdict `UNGRADED`, exit 0); `chore/x` likewise; a `docs/` branch changing only `README.md`, readable (control,
      byte-identical); a numbered branch with a truncated subtree (026's shape: the count line named and one `DiffUnreadable` failure, exit 1) and its readable, empty-diff and
      no-base controls; a `fix/` branch with `a/package.json` readable and `z/` truncated, so git prints a row and then fails (UNGRADED, not a failure from the one name printed:
      FR-008); a shallow clone with a base and a trunk branch (controls). Expectations by hand. Record, for each, how it behaves on the parent. (A `docs/` branch with a truncated
      subtree belongs to phase 2: its consumers are the two readers moved there.)
- [x] T003 Inventory the rules in `tests/enforcement/rules.json`: `DIFF-001` (the numbered failure site) and `DIFF-002` (the Lite UNGRADED site; its `pass` direction is the
      numbered twin and exits 1, as `AMEND-009` does) with anchor and law (014 FR-009, 027 D8, plan D3); run the recall sweep first and classify anything else it reports (a
      rule with a pair, an exemption, or a not-a-rule with a reason).
- [x] T004 Edit `scripts/enforcement-pack.ps1` (plan D1, D2, D3, D6, D7, D8): the helper `Read-DiffLines` (runs git, captures the exit code in the next statement, discards a
      partial result); `Get-ChangedFiles` through it, keeping its signature and return type and setting `$script:ChangedFilesRead` (success and the no-base early return are `Ok`);
      the count line, in its new text only when the read failed; the policy function `Add-DiffUnreadable` (numbered: one failure per run, flagged; Lite: one UNGRADED line per
      reader); the dispatch: the numbered failure, and on `fix/` and `chore/` the `LiteAndAbuse` UNGRADED line instead of calling the check on an empty list. Replace the
      `LIMITS` wording that says `Get-ChangedFiles` returns an empty list when git diff fails (the header paragraph at the amendment check, and the dispatch comment above the
      no-base warning) with what is now named, and say that the Lite gate and review-provenance arrive in phase 2. `Invoke-LiteAndAbuseCheck` and every other member are not edited.
- [x] T005 Show a mutation for each fixture that guards a branch of the new code, and record it in `notes.md`: read the exit code a statement late; keep the partial list; drop the
      no-base early return so a missing base enters the state; drop the numbered once-only flag; call `LiteAndAbuse` on the empty list anyway; enter the state on an empty
      result instead of a non-zero exit; print the old count line on a failed read. Each is shown failing a fixture, then restored byte for byte (the working script ends with no diff).
- [x] T006 Run `-Case DIFF-`, `-Case LITE-`, `-Case AMEND-`, `-Case CRIT-`, the full harness and `ritual-checks.ps1`: every pre-existing case unchanged (FR-009), every new fixture as
      written, no unowned emission site. Re-run T001's reproduction: the truncated `fix/` branch is now `UNGRADED`, not `OK`. Record the numbers in `notes.md`. Then stop and ask
      the owner to run the gate.

---

## Phase 2: The other two readers (US1, US2; FR-005, FR-006)

**Purpose**: `Invoke-ReviewProvenanceCheck`'s `--name-status` read and the Lite amendment gate's second `--no-renames` read go through the helper and enter the same named state on
their lanes, so a review file cannot pass and a spec document cannot go ungated because a diff was never read.

**Territory**:

- `scripts/enforcement-pack.ps1`
- `tests/**`

- [x] T007 Record the baseline in `notes.md`: the full harness count on the parent of this phase and the exact output of the phase 1 `DIFF-*` and `LITE-*` cases. Reproduce
      on the parent of this phase: a `docs/` branch with a truncated subtree prints the named count line and nothing else (no UNGRADED line, `OK`), because its two checks still read
      an empty list.
- [x] T008 Write the fixtures first (plan D9, phase 2 rows): a `docs/` branch with a truncated subtree (UNGRADED lines for the amendment gate and review-provenance, exit 0, the lane
      line naming only what ran); a numbered branch with a truncated subtree and a review file added on it (the failure is reported once, by the dispatch, and review-provenance adds no
      second line); the readable controls (`docs/` with a review file lacking provenance, byte-identical). If no data state makes a second read fail while the first succeeds (both
      read the same trees), say so in `notes.md` and guard that branch by a mutation only, naming it an exemption with the reason.
- [x] T009 Inventory the rules: update the notes of `DIFF-001` and `DIFF-002` for the new emission sites (they own the same two sites, called from three readers); run the recall sweep
      first.
- [x] T010 Edit `scripts/enforcement-pack.ps1` (plan D4, D5): `Invoke-ReviewProvenanceCheck` reads through the helper and calls the policy function on a failed read; the Lite arm of
      `Invoke-AmendmentAuthorityCheck` reads its second list through the helper, names itself through the policy function when either read failed, and returns before the core. Update
      the amendment check's `LIMITS` comment: the Lite gate no longer says nothing for want of a list.
- [x] T011 Show a mutation for each fixture that guards a branch of the new code, and record it in `notes.md`: keep reading review-provenance's rows through the old bare `git diff`;
      drop the Lite gate's second-read check; run the core after an unreadable first read; drop the numbered dedupe flag for the second reader.
- [x] T012 Run `-Case DIFF-`, `-Case LITE-`, `-Case AMEND-`, `-Case CRIT-`, the full harness and `ritual-checks.ps1`: every pre-existing case unchanged except the outputs phase 1 and this
      phase intend to change, every new fixture as written, no unowned site. Re-run T007's reproduction: the `docs/` branch now names both checks UNGRADED. Record the numbers. Then
      stop and ask the owner to run the gate.

---

## Phase 3: Guidance, retirement of the limit, flow-down and replay (US4; FR-010, FR-012, SC-004)

**Purpose**: say in the documents that state the limit what is now named and what stays open, tell adopters, close GAP-034, and replay real history per merge, Lite branches
included. No script changes.

**Territory**:

- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/digests/**`

- [x] T013 Grep `docs/sdlc/`, `adoption/`, `docs/roadmap.md` and the script headers for sentences that say an unreadable diff is graded as empty or "prints as before", and record in
      `notes.md` which are now false (expected, from the planning grep: feature 027's flow-down limit (3), a historical note not edited; the script comments edited in phases 1 and 2;
      nothing in `docs/sdlc/`). If a sentence in `docs/sdlc/` is false, add its file to this phase's Territory by an amendment recorded as the owner's.
- [x] T014 Edit only the sentences T013 found false in documents inside this phase's Territory, with their digest markers within 120 characters; never hand-edit `docs/digests/**`.
- [x] T015 Add a flow-down note to `adoption/updating.md` shaped like 026's and 027's (what was wrong, what it does now, what flows down, what an owner may newly see on a numbered
      and on a Lite branch, what does not change, the known limits: `scripts/territory-check.ps1`'s two unchecked reads, a non-zero exit as the whole truth, the pack's other `git`
      reads, git's message not shown; what was measured; what to do), stating that 027's limit (3) is superseded. Every path in it resolves in an adopted project (doc-lint).
- [x] T016 Update `docs/roadmap.md`: the GAP-034 inventory row and its roadmap row to `shipped` (drop the brackets from the Spec cell), and a decisions-log entry dated the day the
      feature ships (recording the owner's decisions: Decision 1 option B, Decision 2 the three readers, D1–D10 and Needs-the-owner items 1–4, and the phase count). Run
      `pwsh -File scripts/build-digests.ps1` and commit the regenerated `docs/digests/**`.
- [x] T017 Replay (plan D10, FR-010, SC-004): clones of FitForge, FlowBoard and ExpenseTracker made from their local directories (never the real projects, nothing pushed) and the kit's
      own repository; run the parent kit's `enforcement-pack.ps1` and the new one with `-ReplayBase`, `-ReplayTip` and `-IgnoreAmendmentBoundary` over each merged `NNN-*`, `fix/`,
      `chore/` and `docs/` branch, per merge in the shape CI grades (the clone detached at the merge, `main` at its first parent), from a scratch directory outside every clone; report
      per history the runs, the outputs that differ (expected none), the merges the subject patterns missed (counted, and any such merge replayed by name) and the run time on the
      largest. Say plainly what it shows and does not show (plan D10).
- [ ] T018 Final run on an isolated checkout of the final commit (a detached `git worktree` outside the repository, removed afterwards): the full harness,
      `ritual-checks.ps1 -Branch 028-unreadable-diff-named-state`, and `scope-check.ps1` on each phase commit. Record the numbers in `notes.md`. The owner then runs the gate.

---

## Dependencies & Execution Order

- Phase 2 needs phase 1 (it reuses the helper and the policy function). Phase 3 needs phase 2 (the guidance describes what shipped and the replay runs the changed script).
- Within a phase, fixtures are written and shown failing before the behaviour lands (T002 before T004, T008 before T010).
- T017 needs the clones of the adopted projects; if one is unavailable the replay says so and does not claim it.

## Implementation Strategy

MVP is phase 1: the reproduced hole closes (a `fix/` branch with an unreadable diff is no longer `OK`) and the numbered lane names the state. Phase 2 closes the two other readers;
phase 3 can be dropped without touching the others. Stop after each phase for the owner's gate (`Gate Certification: user-run`, no batching); one phase at a time, never ahead.
