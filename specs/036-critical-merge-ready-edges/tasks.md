---

description: "Task list for feature 036 — the open edges of GAP-022: a forgotten pending, an undeclared plan, the adoption commit shape"
---

# Tasks: Critical merge-readiness open edges

**Input**: `specs/036-critical-merge-ready-edges/spec.md` (approved, anas.m, 2026-10-17; D1 failure, D2 no exemption, D3 Standard), `plan.md` (approved, anas.m, 2026-10-17; decisions P1–P8, P4 the suffix), `notes.md` (the measurements)
**Prerequisites**: spec.md and plan.md approved; tasks.md awaiting approval; no new dependency, no new script file, no new harness recipe field.

**Tests**: every new behaviour ships with a passing and a failing harness fixture in the same phase, expectations written by hand (feature 015). New fixtures are run against the parent commit before the code changes and must fail there, so each is shown to measure something. Phase evidence goes in `notes.md`, never here. New rule id: `CRIT-R04` (the family of features 024 and 025).

**Organization**: two phases, each independently revertible; phase 2 must be reverted before phase 1. The full harness is run on an isolated checkout of the final commit, never in a working directory someone is using. Every file is checked for carriage returns before it is committed (this working tree has tracked files that are CRLF on disk).

---

## Phase 1: The rule and its proof (US1, US3; FR-001–FR-003, FR-005, FR-006)

**Purpose**: a Critical plan that declares `**Merge Readiness**: pending` while its committed `tasks.md` has at least one task and every task is ticked is no longer pending: the existing `not treated as mid-feature` line carries the contradiction and the arm fails for the missing artifact exactly as for `ready`. The messages of the undeclared path end with a sentence naming `**Merge Readiness**` as the repair. `ready`, an invalid or hidden marker, an artifact already committed, any unticked task, zero tasks and an unreadable `tasks.md` keep their verdicts and, except for the suffix, their bytes. Proved by fixtures written first.

**Territory**:

- `scripts/enforcement-pack.ps1`
- `tests/**`

- [ ] T001 Record the baseline on the parent commit in `notes.md`: the full harness count on an isolated detached worktree, the coverage report's exempt-rule count and its site counts for `enforcement-pack.ps1`, and the saved output and exit code of every existing `CRIT-R01`, `CRIT-R02`, `CRIT-R03` and `AMEND-001` merge-readiness case for the byte comparison of T006. List which `expected.txt` files pin a message the suffix (plan P4) will change.
- [ ] T002 Read constitution X and I for any sentence that fixes the set of plan header fields, the timing of the independence artifact or the meaning of a ticked task (plan P8); record the answer in `notes.md`. Probe the design before a rule depends on it: (a) what `Get-VisibleFromText` and `Get-FencedLineMap` do with a checkbox inside a comment, a fence and a code span; (b) that the kit's own `tasks.md` files (this repository, `specs/0*/tasks.md`) read as the plan P2 regex expects, including indented sub-tasks and `[X]`, and what count each of the last three shipped features' `tasks.md` gives (all ticked); (c) that `git show "HEAD:./specs/$Branch/tasks.md"` with a failing exit reads as unreadable and not as zero tasks.
- [ ] T003 Write the fixtures first (plan P5, P6), under `tests/enforcement/cases/enforcement-pack/`: `CRIT-R04` `fail` (team arm, `pending`, every task ticked, no artifact, FitForge-002-shaped history: a high-numbered phase landed early, `tasks: phase N done` subjects, duplicate `## Phase N amendment requests` headings; the arm's failure carrying the plan P3 line) and `pass` (the same with one task unticked: today's deferral `WARN`, byte-identical); variants `fail-solo-arm`, `pass-subtask-unticked` (a ticked parent with an unticked sub-task stays pending), `fail-upper-case-x`, `pass-checkbox-only-in-fence`, `pass-checkbox-only-in-comment`, `pass-no-checkbox-tasks`, `pass-tasks-absent`, `pass-ready-all-ticked-unchanged` and `pass-artifact-committed-all-ticked`; hint fixtures `CRIT-R01`/`CRIT-R02` variants (an undeclared plan whose heuristic reports a reason: suffix present; an invalid marker `done`: no suffix; a declared `pending` warning: no suffix); and the `AMEND-001` `pass-merge-readiness-added-approved` (a marker added to an approved plan with the approver record). Expectations by hand; remember the harness reads stdout and then stderr. Run them on the parent commit and record that each new `fail` fails there for the stated reason and each `pass` passes.
- [ ] T004 Bring the new rule into the coverage sweep: add `CRIT-R04` to `tests/enforcement/rules.json` with its anchor (the plan P3 text, `has all` and `of its tasks ticked`) and law; update the anchors of the changed 024 and 025 messages only if the sweep requires. Add an entry to `tests/enforcement/emission-idioms.json` only if the sweep reports a new site (plan P1 expects none). Run the sweep and classify anything else it reports.
- [ ] T005 Edit `scripts/enforcement-pack.ps1` (plan P1 to P4): in the `'pending'` arm of `Get-CriticalMergeReadiness`, read `tasks.md` at `HEAD` through the visibility readers and return `Pending = $false` with the P3 `Why` when at least one task exists and none is unticked; add `Marked` to every table the function returns; append the P4 suffix at the `not treated as mid-feature` site and the two phase-token deferral sites when `-not $readiness.Marked`. Update the explanatory comment above the function (the E1 limit is now partly closed, with the proxy named). Nothing else changes: the arms, the amendment check, the other members.
- [ ] T006 Update every `expected.txt` T001 listed for the suffix and nothing else. Run `-Case enforcement-pack/`, the full harness and `ritual-checks.ps1`: every pre-existing case keeps its verdict and exit code, every new fixture as written, the coverage report lists no unowned site and the exempt count is stated. Re-run T001's saved states and diff: the only moved bytes are the suffix. Record the numbers in `notes.md`.

---

## Phase 2: Guidance, flow-down, roadmap, measurement (US2; FR-004, FR-007, FR-008, SC-001–SC-004)

**Purpose**: owners are told what the all-ticked rule is and is not, the commit shape for adding the declaration to an existing plan, and what the suffix means; adopters get the flow-down note; the roadmap's GAP-022 row is corrected; a measurement shows the rule on a real task file.

**Territory**:

- `docs/sdlc/critical-delivery.md`
- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/digests/**`

- [ ] T007 Add a paragraph to `docs/sdlc/critical-delivery.md` beside feature 025's: the all-ticked rule (a plan that says `pending` while every task is ticked is graded as `ready`), that ticks are a proxy for complete and `pending` stays a claim otherwise, the commit shape for adding the line to an existing approved plan (the `**Amendment approved by**` record in the document, the approver named in the commit message; no exemption), and the repair hint. Digest markers only if the document's digest has room (check `docs/digests/digest-packs.json` bounds).
- [ ] T008 Add a flow-down note to `adoption/updating.md` shaped like feature 025's: what was wrong, what the check does now, what flows down, what may newly be seen (a failure on a finished branch that still says `pending`, and the suffix on 024's messages), what does not change, the stated limits (ticks as a proxy, a convention other than checkbox tasks, `pending` as a claim), what was measured, what to do. Every path in it resolves in an adopted project (doc-lint).
- [ ] T009 Update `docs/roadmap.md`: the GAP-022 row records what 036 closes, that its merge-commit edge was closed by feature 026, and what stays open; a decisions-log entry dated the day the feature ships (D1, D2, D3 and P4); this feature's row to `shipped` only after the human review at merge. Edit with a tool that keeps UTF-8. Run `pwsh -File scripts/build-digests.ps1 -Check` and regenerate only if a digest-marked document changed.
- [ ] T010 Measurement (plan P7, SC-003): in a fresh clone of FitForge made with `--no-hardlinks` (nothing in place touched, nothing pushed), replay the real history of feature 002's `tasks.md` and report at how many commits the new rule would change the verdict and the tick counts at each; say plainly what the replay shows and does not. If the clone is not available on this machine, record SC-003 as not measured with the reason; do not substitute a synthetic number. Also run the rule on this kit's last three features' tasks and record the result.
- [ ] T011 Final run on an isolated checkout of the final commit (a detached `git worktree` outside the repository, removed afterwards): the full harness, `ritual-checks.ps1 -Branch 036-critical-merge-ready-edges`, and `scope-check.ps1` on each phase commit. Record the numbers in `notes.md`. The owner then runs the gate.

---

## Dependencies & Execution Order

- T002 before T003 and T005 (the fixtures and the function use what the probe proved); T003 before T005 (fixtures first, shown failing); T004 before T005's sweep run; T006 last in phase 1.
- Phase 2 needs phase 1: the guidance describes what shipped and the measurement runs the changed script.
- Within a phase, fixtures are written and shown failing before the behaviour lands.

## Implementation Strategy

MVP is phase 1: a forgotten `pending` on a finished branch no longer reads green, the undeclared path says how to declare, all proved by fixtures. Phase 2 can be dropped without touching it, at the cost of owners and adopters not being told. Stop after each phase for the owner's gate; one phase at a time, never ahead.
