# Notes: 036 Critical merge-readiness open edges

Evidence only. The rules are in `spec.md`, `plan.md` and `tasks.md`.

## Phase 1

### T001: baseline on the parent commit (`363b57c`)

- Full harness on an isolated detached worktree of the parent: **1875 passed, 0 failed, 0 skipped** (`enforcement-tests: OK`). It took 45 min because two other harness runs were competing for the machine.
- Cases whose `expected.txt` pins a message the suffix (plan P4) changes, 18 in all:
  - the `not treated as mid-feature` line on a plan with no marker: `CRIT-R02` `fail`, `fail-gap-with-duplicate-headings`, `fail-heading-gap`, `fail-heading-number-overflow`, `fail-heading-starts-at-two`, `fail-heading-starts-at-zero`, `fail-no-phase-commit`, `fail-shallow-clone`, and `GITREAD-001/fail-cooling-off-history`;
  - the phase-token deferral warning on a plan with no marker: `CRIT-R01` `pass`, `pass-duplicate-headings-mid-feature`, `pass-field-shaped-mid-feature`, `pass-limit-final-commit-names-no-phase`, `pass-loose-phase-subjects-mid-feature`, `pass-solo-arm`, `pass-two-digit-phases`, and `CRIT-R02/pass`, `CRIT-R03/pass-marker-in-comment-falls-back-to-heuristic`.
- The `CRIT-R02/fail-marker-*` cases and every `CRIT-R03` declared-`pending` case carry a marker, so they get no suffix and their bytes do not move.
- 17 recipes declare `**Merge Readiness**: pending`; every one of them has only unticked tasks (`- [ ]`) or none, so none of them is affected by the all-ticked rule.

### T002: probes

- Constitution I and X fix neither the set of plan header fields nor the timing of the independence artifact, and say nothing of a ticked task; no amendment is needed (plan P8). The tick reading is a pack decision, not a constitutional one.
- The reader, run on a synthetic `tasks.md` (`- [x]`, an indented `- [ ]`, `- [X]`, `* [x]`, a checkbox inside an HTML comment, inside a fence, inside a code span, and `- [x]nospace`): **ticked 3, unticked 1**. A comment, a fence and a code span are not read as tasks; a box with no space after it is not a task.
- The kit's own `tasks.md` files, counted the same way: feature 033 has 9 ticked and 0 unticked, 034 has 10 and 0, **035 has 0 ticked and 10 unticked, 025 has 0 and 11**. So the tick convention is not uniform in the kit's own shipped features: some tick as they go, some never do. This is the proxy limit in plan Risks, measured: the rule would have read 033 and 034 as complete and 025 and 035 as never complete, and the second reading is the one that leaves `pending` a claim.
- `git show "HEAD:./<path>"` that fails reads as unreadable, and `Get-TaskTickCount` answers 0 tasks for it, so `pending` is honoured (no evidence, no tightening).

### Fixtures written first (T003)

`CRIT-R04`: `fail`, `fail-solo-arm`, `fail-upper-case-x`, `fail-unticked-example-in-fence-is-not-a-task`, `fail-unticked-example-in-comment-is-not-a-task`, `fail-artifact-committed-all-ticked-arm-grades`, `pass`, `pass-subtask-unticked`, `pass-checkbox-only-in-fence`, `pass-checkbox-only-in-comment`, `pass-no-checkbox-tasks`; `AMEND-001/pass-merge-readiness-added-approved`. Built from `CRIT-R03`'s FitForge-shaped fixtures by a throwaway generator in the scratchpad, not committed. Each pair differs in one condition.

Run against the parent code (`-Case CRIT-R04`): the 5 fixtures that expect the new failure fail (exit 0 where 1 is expected), the 6 pass fixtures and the committed-artifact fixture pass byte for byte, and the coverage inventory test reports the new directory as belonging to no inventoried rule until T004.

The hint cases the plan listed for T003 are not new fixtures: the 18 existing cases above carry the suffix (a plan with no marker), and the invalid-marker (`CRIT-R02/fail-marker-unknown-value`) and declared-`pending` (`CRIT-R03/pass`) cases are the ones that must not, and their bytes are unchanged.

### T004: coverage

`CRIT-R04` added to `rules.json`. Its message is built in `Get-CriticalMergeReadiness` and emitted through the existing `not treated as mid-feature` line, so the sweep found no emission site on the first anchor (the reason text, which sits in an assignment); the rule is anchored on the shared site, as `CRIT-R02` is, with the reason text in each fixture's `expected.txt`.

### T005: code

`scripts/enforcement-pack.ps1` only: `Get-CriticalMergeReadiness` carries `Marked` in every table it returns; the `'pending'` arm reads `tasks.md` at `HEAD` through the new `Get-TaskTickCount` and returns `Pending = $false` with the plan P3 `Why` when there is at least one task and none unticked; the P4 suffix is appended at the `not treated as mid-feature` site and the two phase-token deferral sites when the plan carries no marker. The explanatory comment above the function names the proxy.

### T006: full harness on the changed working tree

- `-Case CRIT-R04`: **117 passed, 0 failed, 0 skipped** (`enforcement-tests: OK`).
- Full harness, no filter: **1899 passed, 0 failed, 0 skipped** (`enforcement-tests: OK`), 1841 s. Baseline was 1875, so 24 more tests than the parent.
- The 18 `expected.txt` files T001 listed carry the suffix; the full run passes with them.
- Not yet run: `ritual-checks.ps1`, and the diff of T001's saved states for byte movement (both T006 requirements). T006 is open until they are.
- T003 listed `pass-tasks-absent` and `pass-ready-all-ticked-unchanged`; they were not written (the fixtures as built are in the section above). Open for T006 or a recorded decision.

### T003 completion and T006 ritual-checks

- The two fixtures T003 listed and the first pass left out are written. `pass-ready-all-ticked-unchanged` (a `ready` plan, every task ticked, a valid committed review) passes. `pass-tasks-absent` could not be a pass: a Critical branch without a committed `tasks.md` fails `Structure` whatever the readiness read says. It is `fail-tasks-absent-pending-honoured`: the only issue is `Structure`, and the `pending` deferral warning is byte-identical to the one in `pass`, so no all-ticked line appears. `-Case CRIT-R04`: **121 passed, 0 failed, 0 skipped**.
- `ritual-checks.ps1 -Branch 036-critical-merge-ready-edges`: doc-lint OK, digests OK, roadmap-claims OK, scope-check UNGRADED (no phase commit yet), **enforcement-pack FAIL**: `AmendmentAuthority` on commit `363b57c` ("approve spec and plan, two-phase task list"). That commit changed `Status` from Draft to Approved in `spec.md` and `plan.md`, and the check wants an `**Amendment approved by**` record in the amended section and the same approver in the commit message. It is in committed history, not in the Phase 1 working tree. Not remediated: approval records are the owner's.

### Approval commits redone

`363b57c` amended the approved spec and plan (Draft to Approved) with no approver record, and `AmendmentAuthority` failed on it. It was unpushed, so it was redone, on the owner's instruction, as four commits in the shape of features 034 and 035: `269e640` (spec), `26f7637` (plan), `b59dfb7` (task list, awaiting approval), `0f35653` (task-list approval), each approval carrying `**Amendment approved by**: anas.m, 2026-10-17` in the document and the approver in the message. The owner ran the tasks approval commit and the branch move; the old commit stays reachable by `363b57c` until garbage collection.

`ritual-checks.ps1 -Branch 036-critical-merge-ready-edges` after the redo: `AmendmentAuthority` graded 6 of 6 commits, **enforcement-pack OK**, doc-lint OK, digests OK, roadmap-claims OK, scope-check UNGRADED (no phase commit yet). Result UNGRADED, nothing failed.

### T006: closing numbers

- Full harness on the working tree after the approval commits were redone and the two extra fixtures were written: **1903 passed, 0 failed, 0 skipped** (`enforcement-tests: OK`). Parent baseline 1875.
- Byte comparison of the 18 `expected.txt` files T001 listed, against the parent commit, byte level: each differs by exactly one line, and that line is the old line plus the plan P4 suffix (`; the plan can state the answer with **Merge Readiness**: pending or ready (docs/sdlc/critical-delivery.md item 5)`); 0 exceptions. No `command.json` or `recipe.json` of an existing case changed, so no existing case moved its exit code or inputs. The cases that must carry no suffix (`CRIT-R02/fail-marker-*`, every `CRIT-R03` declared-`pending` case) are not in the changed set.
- Line endings: the first pass of the `expected.txt` edits had written 17 of the 18 files, and two new recipe files, with CRLF where the repository uses LF, which made every line of those files differ. They were converted back to LF. After the conversion `CRIT-R01` (145), `CRIT-R02` (121), `CRIT-R03` (123), `CRIT-R04` (121), `GITREAD-001` (107) and `AMEND-001` (261) each pass with 0 failed.
- `ritual-checks.ps1 -Branch 036-critical-merge-ready-edges`: no member failed; result UNGRADED only because no phase commit exists yet for scope-check.

### Phase 1 gate

The owner ran the gate command (`docs/sdlc/gate-command.md`) on the working tree before the phase commit and confirmed **exit code 0**, 2026-10-18.
