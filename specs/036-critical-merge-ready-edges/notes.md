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

### Review follow-ups of `6e24d98` (fresh-context agent, verdict APPROVE WITH FOLLOW-UPS)

- **F1 (low, fixed).** `Get-TaskTickCount` required a whitespace character after the box, so a bare `- [ ]` line was not counted as a task; a `tasks.md` with ticked tasks and one bare unticked box read as all ticked. The pattern now ends `(\s|$)`; a box glued to text (`- [x]nospace`) is still not a task. Probe on the four shapes: `- [ ]` and `- [x]` old no / new yes, `- [ ] t` old yes / new yes, `- [x]nospace` no / no. New fixture `CRIT-R04/pass-bare-unticked-checkbox` (one task written as a bare `- [ ]`): pending is honoured, output byte-identical to `pass`. Under the old pattern that task is not counted, the file reads as all ticked and the case would fail.
- **F2 (low, pinned as a stated limit).** An unterminated `<!--` hides every later line (`Get-VisibleFromText`, the same reader the phase-heading read uses), so an unticked task below it is not seen. New fixture `CRIT-R04/fail-unterminated-comment-hides-later-tasks` pins the behaviour: all 2 visible tasks ticked, the rule fires. It errs toward demanding the review earlier, never later. To be listed with the limits in the Phase 2 guidance (T007, T008).
- **F3 to F5 (low and informational), accepted, no change.** F3: `pass-checkbox-only-in-fence` and `pass-checkbox-only-in-comment` are not minimal pairs against `fail`, but they measure the claim, and the `fail-unticked-example-in-*` fixtures are the one-condition versions. F4: `fail-tasks-absent-pending-honoured` exits 1 only through `Structure`, by design. F5: the invalid-marker hint is covered by the existing `CRIT-R02/fail-marker-*` cases.
- `-Case CRIT-R04` after the follow-ups: **125 passed, 0 failed, 0 skipped**.
- Full harness after the follow-ups (F1 regex, two new fixtures): **1907 passed, 0 failed, 0 skipped** (`enforcement-tests: OK`). Phase 1 commit `6e24d98` was 1903; the 4 more are the two new fixtures, two checks each.
- The owner ran the gate command again on the working tree with the follow-ups and confirmed **exit code 0**, 2026-10-18.

## Phase 2

### T010: measurement (plan P7, SC-003), 2026-10-18

Method: a fresh clone of FitForge made with `--no-hardlinks` into the scratchpad (the real project never touched, nothing pushed), the branch `002-identity-member-profile` replayed at each of its **43** commits beyond `main`. At each commit a throwaway commit in the clone injected `**Merge Readiness**: pending` after the plan's `**Gate Certification**` line (the line does not exist in that history, so this is a simulation: it shows the rule on a real file, not that an owner will leave `pending` in place). The enforcement pack of the kit before this feature (`0f35653`, a detached worktree, removed afterwards) and as it stands at the phase 1 follow-up (`e8ac2e0`) were each run with `-Root <clone> -Branch 002-identity-member-profile` and the `CriticalEvidence` line classified. The two commits that precede `plan.md` carry no plan to inject into.

- **Verdict changed at 0 of 43 commits.** Before and after, the 41 commits that carry a plan print the same `pending` deferral warning.
- Tick counts read by the new rule (visible, unfenced checkbox items): 102 tasks with 102 unticked at the first plan commit, 106 with 1 unticked at the lowest point (commit 32, `5c740f1`), 128 with **6 unticked at the tip** (`b9e1d88`). The count of unticked tasks was never 0, so the rule never fired.
- What the tip's 6 unticked tasks are: T077 and T078 (Vitest tests, T078 marked "Record corrected, phase 12 (F11): was `[x]`"), T084 and T085 (the BFF `me` route and the back-button check, both marked corrected from `[x]`), T096 (the Visual Compliance Loop against the profile screenshots) and **T100, filing the independent `human-pr-review.md` itself**. The case the rule exists for (every task ticked, `pending` left in place) did not occur in this history, and the rule stayed silent while T100 was open. **The ticks in that list were not reliable, though** (fresh-context review of phase 2, F2): T078, T084 and T085 carry a later "Record corrected, phase 12 (F11): was `[x]`" note (T078 says its test does not exist), so work was ticked before it was done and unticked later, and at commits 32 and 33 (`5c740f1`, `aef4c85`; verified with `git show`) T100 was the only open task, so one task separated the list from the rule firing. That is the proxy limit in a real history: a tick is not proof the work is done.
- What the replay shows: on a real 128-task file the reader counts 128 tasks, and a list that never reaches "every task ticked" is not touched. What it does not show: a branch where every task is ticked and `pending` is left in place (none exists in this history), nor that an owner will declare `pending` at all.
- The kit's own last features' `tasks.md` at `HEAD` with the final reader (bare boxes counted): 033 ticked 9 unticked 0, 034 ticked 10 unticked 0, **035 ticked 0 unticked 10**, 036 ticked 6 unticked 5 (phase 2 open). So the convention is not uniform in the kit: the rule would read 033 and 034 as complete and 035 as never complete (the second reading leaves `pending` a claim, the stated proxy limit).

### T007 to T009: guidance, flow-down, roadmap, digests

- `docs/sdlc/critical-delivery.md`: a paragraph after feature 025's (the all-ticked rule, the repair the line names, the amendment shape with no exemption, the hint suffix, the limits including the unterminated comment and the glued box) and two digest markers; the critical digest regenerated (+2 lines).
- `adoption/updating.md`: a flow-down note shaped like 025's. Its two digest markers were dropped: the adoption digest was already at `MaxDigestContentLines = 40` (42 with them, `build-digests.ps1` refused), and T007 allows markers only when the digest has room. `docs/digests/adoption-digest.md` is unchanged. Every path in the note resolves in an adopted project (doc-lint OK).
- `docs/roadmap.md`: the GAP-022 row gains an update (the merge-commit edge was closed by feature 026, what 036 closes, the 0 of 43 measurement, what stays open) and a decisions-log entry dated 2026-10-18; this feature's own row stays `specified` until the human review at merge (T009).
- `build-digests.ps1 -Check`: OK, 5 digests fresh, 121 markers.

### Phase 2 gate

The owner ran the gate command (`docs/sdlc/gate-command.md`) on the working tree before the phase commit and confirmed **exit code 0**, 2026-10-18.

### Review follow-ups of `94352c4` (fresh-context agent, verdict APPROVE with follow-ups)

F1 `critical-delivery.md` had been committed as CRLF (244 CR bytes in 244 lines against 0 at `e8ac2e0`), so the diff read as a whole-file rewrite: converted back to LF, diff against `e8ac2e0` is +15 lines again, CR bytes checked on every file touched. F2 "ticked honestly" was contradicted by FitForge's own list (three of the six open tasks were later marked "record corrected: was `[x]`"; commits 32 and 33 had T100 as the only open task, checked with `git show`): reworded in the flow-down note, the roadmap row and this file. F3 the log entry's "still open" list named the phase 2 gate, now moved to certified. F4 `*` and `+` bullets are tasks too and a numbered `1. [ ]` is not: stated in the guidance and the flow-down note. The review is in `ai-code-review-phase2.md`. `build-digests.ps1 -Check` OK and `ritual-checks.ps1` `RESULT OK` after the edits.

The owner ran the gate command again on the working tree with the phase 2 review follow-ups and confirmed **exit code 0**, 2026-10-18.

### T011: final run on an isolated checkout

A detached `git worktree` outside the repository, removed afterwards.

- **Full harness at `94352c4`**: **1907 passed, 0 failed, 0 skipped** (`enforcement-tests: OK`), 1761 s. The only commit after it, `c905933`, changes documents and this feature's notes and review files, no script or test, and the commit before it, `e8ac2e0`, is the last that changed code; the harness was not re-run on `c905933`.
- **`ritual-checks.ps1 -Branch 036-critical-merge-ready-edges` at the final commit `c905933`**: doc-lint OK, enforcement-pack OK (`AmendmentAuthority` graded 10 of 10 commits), scope-check OK, digests OK, roadmap-claims OK, scope-repos and verify-kit n/a; **RESULT OK**. (The same run on `94352c4` also gave RESULT OK, 9 of 9 commits.)
- **`scope-check.ps1 -Branch 036-critical-merge-ready-edges` on each phase commit**: PASS `6e24d98` (64 files), PASS `e8ac2e0` (9), PASS `94352c4` (6), PASS `c905933` (5). A first attempt without `-Branch` answered UNGRADED for the detached checkout, which is the script's own refusal to guess a lane, and was discarded.
- Not yet recorded: CI on the pushed branch (the branch is local only) and the human review of each phase.

### Human review and CI

- CI on the pushed branch, tip `fcd8947`: `ritual-checks` success, `enforcement-tests (ubuntu-latest)` success, `enforcement-tests (windows-latest)` success.
- The owner (anas.m) reported on 2026-10-18 that the human review of both phases is done and **approved**. No `human-pr-review.md` is committed on the branch (it is required only for a Critical feature); this line records the owner's report, not a review file. The roadmap row is flipped to `shipped` on the branch ahead of the merge, with the merge itself the one thing still open.
