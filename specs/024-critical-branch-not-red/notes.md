# Notes: 024 — a Critical feature's branch is not red from its first commit

Phase evidence, never law. The documents are `spec.md`, `plan.md`, `tasks.md`.

## Phase 1

### T001 — baseline on the parent commit (`5fc1274`, main as merged with #71)

- Full harness on the parent: **1410 passed, 0 failed**, 1111.67 s (about 18.5 minutes).
- Recipe check: a recipe commit carries `branch`, `message`, `write` and the rest of what the fixtures need, so a commit
  subject `phase N: ...` and a depth-1 clone (`shallow`) are reachable. **No recipe field was added.**
- The red run this feature removes is reproduced by the fixtures rather than by a throwaway branch: on the parent, every
  `pass` case below exits 1 with `CriticalEvidence: ... is missing`.
- Not measured separately, and said plainly: that `ritual-checks.ps1` passes a `WARNING:` line from the pack through unchanged
  is shown by the pack's own existing `PhaseSizeWarning` use of the same list; the ritual-checks run on this branch is
  recorded under T005 below.

### T002 / T003 — fixtures first, shown failing on the parent

Run against the parent's `scripts/enforcement-pack.ps1` (restored afterwards), `-Case enforcement-pack/CRIT-R`:

| Case | On the parent |
|---|---|
| `CRIT-R01/pass`, `pass-solo-arm` | exit code and output both fail (parent exits 1, the case expects 0 and a WARNING) |
| `CRIT-R01/fail`, `fail-solo-arm`, `fail-fence-heading-not-counted` | pass, by design: the final-phase behaviour is unchanged, so these are the controls that stop an over-relaxation |
| `CRIT-R02/pass` | exit code and output both fail (same reason as `CRIT-R01/pass`) |
| `CRIT-R02/fail`, `fail-heading-gap`, `fail-no-phase-commit`, `fail-shallow-clone` | exit code matches (1), output fails: the new `WARNING: CriticalEvidence: not treated as mid-feature` line is absent |

**Deviation, recorded here and not written into `tasks.md`** (T002/T003 say `CRIT-R01` to `CRIT-R06`, and a task is left
saying what was agreed): the coverage sweep owns one rule per emission site, and the change has **two** sites for the
WARN pair (the team and the solo message, declared as `siteCount: 2`) and **one** for the strict reason. The six conditions
therefore became variants of two rules, `CRIT-R01` and `CRIT-R02`, each with a `pass` and a `fail`. Nothing is dropped: every
condition the plan named (D6) has a case.

Expectations were written by hand from the plan's wording before the code existed. The one exception to "predicted first":
`CRIT-R02/fail-shallow-clone`, whose unchanged lines (the no-integration-branch warning, the two UNGRADED lines, the
shallow-clone AmendmentAuthority failure) were taken from the parent's real output on a kept fixture and checked against
the script's source; only the new reason line is mine.

### T004 — the change

`scripts/enforcement-pack.ps1`: `Get-CriticalMergeReadiness` added, `Invoke-CriticalEvidenceCheck` takes `-Base` and gates the
two arms (not edited), the dispatch passes `$diffBase`. Two new emission sites for the WARN (one per arm) and one for the
strict reason. The residual limit of plan Risks is stated in the comment above the function.

### T005 — runs

Agent-run, feedback only; none of this certifies (the owner holds the gate).

- Full harness on the working tree with the change: **1430 passed, 0 failed** (1410 baseline + 20 new cases: 10 case
  directories, each with an exit-code and an output assertion).
- Every pre-existing case unchanged: none of the 1410 changed outcome, including all `CRIT-S*` and `CRIT-T*`.
- Coverage report: `enforcement-pack.ps1` 70 of 75 sites fixtured (1 exempt, 4 not a rule), up from 67 of 74; overall 245 of
  257 owned, **exempt count unchanged at 3**, no unowned site.
- `ritual-checks.ps1`: doc-lint OK, enforcement-pack OK, digests OK, roadmap-claims OK; scope-check UNGRADED until a phase
  commit exists (re-run after the commit, below); scope-repos and verify-kit n/a.

### Gate 3 certification (user-run)

Gate certified (user-run): `pwsh -File scripts/ritual-checks.ps1` on the phase 1 commit `2300e44`, exit code **0**, confirmed by the
owner (anas.m, 2026-10-13). The owner's own run showed doc-lint, enforcement-pack, scope-check, digests and roadmap-claims OK;
scope-repos and verify-kit n/a.

That run carried one non-blocking `PhaseSizeWarning`: commit `2300e44` changes 1015 lines across 33 files (guideline: 400 lines
and 15 files, constitution X). 30 of the 33 files are fixtures (ten cases of three files each); the rest are
`scripts/enforcement-pack.ps1` (about 75 lines), `tests/enforcement/rules.json` and this file. It is one coherent slice (the gate
and its proof), and the fixtures-first rule puts them in the same phase as the behaviour.

Awaiting: the fresh-context AI review (Reviewer Provenance) and the owner's decision on the two-rule layout (deviation above).

### Phase 1 review remediation (review F1–F7, owner decisions of 2026-10-13)

Owner decisions, in the owner's words in the session: approve both F1 options; fix F1 to F5 in phase 1. The D3 change is
recorded in `plan.md` with the approver line (commit "plan: 024 D3 amended after the first AI review").

| Finding | What was done |
|---|---|
| F1 (CONFIRM) | Both options built: an artifact already committed at `HEAD` ends the pending state (the arm grades it as today, no WARN), and a phase token anywhere in a subject, naming the final phase or beyond, counts as the final phase having landed. The anchored form is kept only to show the branch is mid-feature at all. The residual limit (a final commit naming no phase, with no artifact committed) is **asserted by a fixture** (`CRIT-R01/pass-limit-final-commit-names-no-phase`), not hidden. |
| F2 | `ConvertTo-PhaseNumber` uses `[long]::TryParse`; a number too large to read is "beyond any phase" in a subject and a strict reason in a heading. Fixtures: `CRIT-R01/fail-phase-number-overflow-in-subject`, `CRIT-R02/fail-heading-number-overflow`. |
| F3 | Falls out of F1 option (a): a committed artifact, valid or not, is graded now. Fixture: `CRIT-R01/fail-artifact-committed-invalid-mid-feature`. |
| F4 | Solo cooling-off fixtures, mid-feature: `pass-solo-artifact-old-mid-feature` (25 h) and `fail-solo-artifact-young-mid-feature` (23.5 h), differing only in the review's age. |
| F5 | `fail-comment-heading-not-counted`, `pass-two-digit-phases`, `fail-two-digit-final`. **Not done:** a fixture for `git log` failing, which the code handles as a strict reason; no recipe field makes `git log` fail while the rest of the pack still runs, and inventing one for a one-line branch was judged out of proportion. It is read in review, not proved by a case; say so rather than count it. |
| F6 | Recorded above (the two-rule layout). Owner's confirmation is still outstanding. |
| F7 | The pre-existing `CRIT-S*` and `CRIT-T*` cases print no new line because their branches are ready (a one-phase `tasks.md`, a `phase 1` commit) or already carry the artifact, and `Why` is then null. `emission-idioms.json` needed no entry: its `enforcement-pack.ps1` entry already lists `$script:warnings +=` as an accumulator, which is why the sweep saw the new sites. |

Failing first on the code as phase 1 left it (`-Case enforcement-pack/CRIT-R`, before the change): the fixtures for F1 (b),
F2, F3 and the young solo artifact fail (exit code and output), the two artifact-present `pass` variants fail on output (a WARN is
printed where none should be), and the controls (the limit, comment heading, two-digit phases) pass.

Runs after the remediation (agent-run, feedback only; certification stays with the owner): full harness **1452 passed, 0 failed**
(1430 + 11 new cases); every pre-existing case unchanged; coverage report unchanged in shape (`enforcement-pack.ps1` 70 of 75
sites fixtured, 1 exempt, 4 not a rule; overall exempt count still 3; no unowned site).

### Gate 3 certification, remediation commit (user-run)

Gate certified (user-run): `pwsh -File scripts/ritual-checks.ps1` on the remediation commit `4c8fe99`, `RESULT OK`, exit code **0**,
confirmed by the owner (anas.m, 2026-10-13). Two non-blocking `PhaseSizeWarning` lines (`4c8fe99`: 1255 lines across 35 files;
`2300e44`: 1015 across 33), the same cause as before: the fixtures.

### Owner confirmation of the two-rule layout

Confirmed by the owner (anas.m, 2026-10-13): the plan's six rules, `CRIT-R01` to `CRIT-R06`, stand as variants of `CRIT-R01` and
`CRIT-R02`, because the coverage sweep owns one rule per emission site. `tasks.md` is left as approved; this note is the record.

### Round 2

A fresh-context re-review of `4c8fe99` was started on the owner's instruction (2026-10-13); its file will be
`ai-code-review-phase-1-round-2.md`, filed verbatim.

### Round 2 review remediation (owner decisions of 2026-10-13)

Owner decisions: approve the plan amendment, extend the F2 token, run a round 3. The amendment is recorded with the approver
in `plan.md` and `tasks.md` (commit "plan and tasks: 024 text brought in line with the code ...").

| Round 2 finding | What was done |
|---|---|
| F1 DOC DRIFT | `plan.md` D1 (the return shape and the gate), D3 (a second amended paragraph), Risks (bullets 1 and 2) and `tasks.md` T004 rewritten to say what the code does, each with an approver line. |
| F2 MINOR | The final-phase token is `\bphases?\s*(\d+)`, so `phase3`, `phase 3a` and `phases 3` count. Fixtures: `CRIT-R01/fail-phase-token-no-space`, `fail-phase-token-suffix`, `fail-phase-token-plural`, each differing from `pass-limit-final-commit-names-no-phase` only in the subject; they failed on the code as round 2 left it. |
| F3 MINOR | A design consequence, not a defect: committing the artifact early turns the branch red for the rest of the feature; an uncommitted artifact leaves the WARN where the parent failed; an unparsable `kit-adoption.json` resolves to solo, so a committed team artifact does not end the pending state. Recorded in plan Risks now and **to be said in the phase 2 guidance** (T006, T007). |
| F4 MINOR | `CRIT-R01/pass-artifact-committed-mid-feature` added, so `fail-artifact-committed-invalid-mid-feature` now has a pair differing only in the review's validity. It passed on the code as it stood: a fixture gap, not a behaviour change. |

Runs (agent-run, feedback only): full harness **1460 passed, 0 failed** (1452 + 4 cases); every pre-existing case unchanged;
coverage unchanged (`enforcement-pack.ps1` 70 of 75 fixtured, overall exempt count 3).

### Round 3 review remediation (owner decision of 2026-10-13: approve the doc fixes)

Round 3 found no code defect; its three findings were wording. Done in `plan.md`, each with an approver line: the residual-hole wording
(Risks, bullet 1) now says what the pattern does not read (no phase word; a separator it does not read; a list or range whose first
number is lower) instead of "names no phase"; the D1 rewrite has its own approver line and the stray one inside the Risks list is
gone (one at the end of the section); D3's first paragraph carries a note that the amended paragraphs supersede its anchored-form
description. `tasks.md` T004 keeps the single approver line in its phase block. No code, fixture or test changed, so no harness
re-run is owed; the gate for `20855f5` was certified by the owner (exit 0, 2026-10-13).

## Phase 2

### T006 / T007 (drafted, uncommitted while the finding below is open)

Constitution X was read for any sentence that says when the independence artifact is demanded: it names Critical only in the
level, the cooling-off hours and the CI-held exclusion, never the timing, so **no amendment is needed**. `critical-delivery.md`
(item 5, a "When the check demands the artifact" paragraph and two digest markers), `definition-of-done.md` (item 6 and one marker)
and the `adoption/updating.md` flow-down note are drafted in the working tree; `doc-lint` is OK on them.

### T009 — the measurement, and what it found

Method: clones of FitForge, FlowBoard and ExpenseTracker made from their local directories (nothing in place touched, nothing
pushed, `origin` is the project on disk). Three states per clone: S0 installed (kit `a1258c5`), S1 the kit before this feature
(`5fc1274`, applied with `update-kit.ps1`, digests rebuilt, committed), S2 the kit as it stands (`37f4bc9`: `7ca9be6` plus the three
drafted documents, applied the same way). In each state `ritual-checks.ps1` and `enforcement-pack.ps1` on `main` and on every
`NNN-*` branch, `doc-lint.ps1`. Every clone was asserted to end on the right kit: the new function is in `HEAD` and absent from
`HEAD~1` in all three. **First-pass defect, found and discarded**: the first driver ran each feature branch with the branch's own
older `scripts/`, so a branch probe could not move between states (the same species as feature 023's first driver). The corrected
driver switches to the branch and merges the updated `main` into it first, the way an adopter meets a kit update on a live branch
(no merge conflicts in any project).

| Probe | S1 -> S2 |
|---|---|
| `doc-lint.ps1`, all three projects | exit 0, byte-identical |
| `ritual-checks` and `enforcement-pack` on `main`, all three | `RESULT OK`; the only differences are bookkeeping (one more commit, two more digest markers, the recorded kit commit) |
| ExpenseTracker `003-expense-entry` (non-Critical) | same members, same verdicts; the only differences are the second update's bookkeeping (changed-file count, one more commit graded, the phase-size line's counts) |
| **FitForge `002-identity-member-profile` (Critical)**, at the tip and at two earlier points (`81d7424` after phase 4, `398e75f` after phase 9) | **FAIL in S1 and still FAIL in S2.** S2 adds one line: `WARNING: CriticalEvidence: not treated as mid-feature - the '## Phase N' headings of specs/002-identity-member-profile/tasks.md are not numbered 1 to N without a gap (found 1, 1, 2, 3, ..., 11)` |

**The finding.** The one real Critical feature the kit has ever run is **not helped** by this feature at any point in its history.
Two independent mismatches between the check and real field data, each sufficient on its own:

1. **The heading grammar.** FitForge's `tasks.md` carries `## Phase 1 amendment requests (awaiting an approver)` and
   `## Phase 10 amendment request` beside its `## Phase N: ...` headings. `^##\s+Phase\s+(\d+)\b` reads them as a second phase 1 and a
   second phase 10, so the "numbered 1 to N without a gap" test fails (found 1, 1, 2, ... 10, 10, ... 17) and the branch stays strict.
   The same grammar is `Get-Territory`'s, so scope-check reads those headings as phase sections too; here it only costs the relaxation.
2. **The commit-subject convention.** The relaxation needs a subject that **begins** `phase k` to show the branch is mid-feature. On
   `002`, **0 of 43** branch commits begin that way; **34 of 43** carry a phase token elsewhere (`tasks: phase 4 done - credentials`,
   `docs: phase 13 web gate exits 0`). Predicted from reading, not run (fixing the first would expose the second): with the headings
   accepted the branch would still stay strict, on "no commit on the branch carries a phase subject yet".

CLAUDE.md asks for `phase N` in a phase commit's subject, and FitForge's real code-phase commits may follow it; its bookkeeping commits
do not, and a mid-feature branch is mostly bookkeeping. The fixtures never showed this because they were built from the kit's own
convention: **the harness proves the check does what the plan says; the measurement shows the plan does not match the field.**

### Remediation of the measurement finding (owner decisions of 2026-10-13: approve both fixes, run a round 4)

Plan D2 and D3 and tasks T004 amended, with the approver, in their own commit before any code ("plan and tasks: 024 D2 and D3
amended after the second-phase measurement ..."). The code: the heading test is now "the DISTINCT numbers are exactly 1..N" (a
duplicate such as `## Phase 1 amendment requests` is allowed, a gap is not; the message still lists every number found), and one
token `\bphases?\s*(\d+)` anywhere in a subject reads both finality (at or above `N`) and the evidence that the branch is
mid-feature (below `N`); the anchored `^phase k` form is gone. The accepted cost, recorded in plan D3: a branch earns the WARN a
little more easily (any subject mentioning an earlier phase), and zero phase tokens still stays strict.

Fixtures first, built from FitForge's real shapes, shown failing on the code as it stood: `CRIT-R01/pass-duplicate-headings-mid-feature`,
`pass-loose-phase-subjects-mid-feature` and `pass-field-shaped-mid-feature` (each differs from the control pass in one condition, the
third in both) fail on exit code and output; `fail-field-shaped-final` fails on output (the old code printed a gap reason); the control
`CRIT-R02/fail-gap-with-duplicate-headings` passes on the old code, as a control should. Full harness after the change:
**1470 passed, 0 failed** (1460 + 5 cases); every pre-existing case unchanged, including `CRIT-R02/fail-no-phase-commit`
(subjects with no phase token stay strict); coverage unchanged (`enforcement-pack.ps1` 70 of 75 fixtured, exempt count 3).

### Round 4 review remediation (owner decision of 2026-10-13: option 1, ship with the limit said plainly)

Review: `ai-code-review-phase-1-round-4.md` (fresh-context, APPROVE with follow-ups), filed verbatim. It found no code regression and
confirmed the measurement independently by running the pack at all 43 commits of FitForge 002: 17 `WARN` (8 early, 9 after the
amendment that raised the declared phases to 17), 19 strict in the stretch after phase 11 ran ahead of phases 4 to 9, 4 strict at the
start with a printed reason, 3 strict at the end of which one (`declare phase 17`) is early and noisy.

| Round 4 finding | What was done |
|---|---|
| F1 CONFIRM (the measurement) | **Owner decision: option 1.** Ship as measured; the limit is stated in plan D3 (current reading), Risks, the script header, `critical-delivery.md`, the flow-down note and the roadmap, with the numbers. A new `idea` row asks for a better merge-ready signal. No code change. |
| F2 DOC DRIFT | `plan.md` D3 and Risks tidied: the stale "superseded" note replaced, the earlier amended paragraphs marked as withdrawn where they are, the wrong "`1..k`" wording fixed, and a "current reading" paragraph added that governs. Committed with the approver. The script-header paragraph rewritten (comment only; diff outside comments is empty). |
| F3 MINOR (accepted) | The mid-feature evidence is weak by design (incidental subjects, merge subjects, `phases 1-3` earn the WARN); recorded in plan D3. |
| F4 MINOR | Fixtures added that pin existing behaviour (they pass on the code as it stands, by design, and guard against wrong implementations): `CRIT-R02/fail-heading-starts-at-two`, `fail-heading-starts-at-zero`, `CRIT-R01/fail-single-phase-duplicate-headings`, `fail-out-of-order-final-phase-lands-early` (the last asserts the measured limit). |

Runs (agent-run, feedback only): full harness **1478 passed, 0 failed** (1470 + 4 cases); every pre-existing case unchanged; coverage
unchanged (`enforcement-pack.ps1` 70 of 75 fixtured, exempt count 3).

### T006 to T009, final (phase 2, after the owner chose option 1)

**T006.** `critical-delivery.md` (a "When the check demands the artifact" paragraph with both limits and two digest markers) and
`definition-of-done.md` (item 6 and one marker). **T007.** The flow-down note in `adoption/updating.md` (what was wrong, what it does,
what flows down, what an owner may newly see, what does not change, both limits, what was measured, what to do, two markers). Four
verbatim files flow down: `scripts/enforcement-pack.ps1`, the two documents and the updating document; the kit's fixtures do not.
**T008.** `docs/roadmap.md`: the GAP-022 inventory row gains a status that says **partly closed** and why; this feature's row is
`shipped` with the spec path unbracketed; a new `idea` row asks for a better merge-ready signal; a decisions-log entry dated 2026-10-13
records what shipped, what the owner decided, what the work corrected (four times, by reviewers and by the measurement) and what stays
open. `build-digests.ps1`: 105 markers (100 before), `docs/digests/adoption-digest.md`, `critical-digest.md` and `delivery-digest.md` changed.

**T009, the final pass** on the final documents (kit `ac029d3` = `2b9c24b` plus the six drafted files, applied to clones of the three
projects, kit before `5fc1274`; each clone asserted to end on the right kit: the new function is in `HEAD` and not in `HEAD~1`):
`doc-lint.ps1` byte-identical and `OK` in all three; `main` `RESULT OK` in every state of every project, the only differences being the
second update's own bookkeeping; ExpenseTracker's non-Critical `003-expense-entry` the same member verdicts (`RESULT UNGRADED`, 2 of 7
formed no opinion, in both states) with only bookkeeping lines moved; FitForge `002-identity-member-profile` strict (the arm's own
failure, no `WARNING: CriticalEvidence` line) at the tip, at `81d7424` and at `398e75f` in S2, as in S1, with the pack also failing
`scope-check` in both states (unchanged by this feature). Identical to the pass before the documents were finalised. The mid-feature
behaviour on real data is therefore **not** demonstrated by these three probes; the fresh-context reviewer's run at all 43 commits is
the evidence (17 `WARN`, 19 strict while phase 11 ran ahead, 4 strict with a reason, 3 strict at the end).

### Gate 3 certification, phase 1 final (user-run)

Gate certified (user-run): `pwsh -File scripts/ritual-checks.ps1` on the phase 1 final commit `2b9c24b` (run on a working tree that also
held the uncommitted phase 2 files), exit code **0**, confirmed by the owner (anas.m, 2026-10-13). Phase 1's gate history: `2300e44`
(exit 0), `4c8fe99` (exit 0), `20855f5` (exit 0), `2b9c24b` (exit 0); each remediation commit was re-gated.

### Phase 2 AI review and its remediation

Review: `ai-code-review-phase-2.md` (fresh-context, APPROVE with follow-ups), filed verbatim. It confirmed the mid-feature definition and the
strict-state list match the code, the four-file flow-down list matches `kit-manifest.json`, the roadmap and decisions log are
consistent and the claim check passes, no contradiction with `team-workflow.md`, `review-process.md`, `branch-strategy.md` or the
constitution, and it **reproduced the FitForge headline** by overlaying this kit's scripts on all 43 commits of the branch in a scratchpad
clone (17 `WARN`, 19 strict, 3 other strict, 4 strict with a printed reason; 81d7424, 398e75f and the tip strict). It did not re-run the
three-project update measurement or the full harness.

| Finding | What was done |
|---|---|
| F1 DOC DRIFT | "Committing the artifact early turns the branch red for the rest of the feature" overstated the code: a valid artifact committed early **passes** (`pass-artifact-committed-mid-feature`, `pass-solo-artifact-old-mid-feature`). Corrected in `critical-delivery.md`, the flow-down note (bold sentence), the roadmap entry and the digest marker (now 115 characters): graded from that commit on, red until valid (team) or 24 hours old (solo), passing once it is. **Plan Risks and D3 carry the same sentence and wait for the owner's approval of the amendment.** |
| F2 DOC DRIFT | "never a pass it should not have" contradicted limit 1 (an unnamed final commit can get a `WARN` where it should fail). Replaced in both documents by what is true: the out-of-order effect is in the safe direction, the first limit is the unsafe one, which is why gate 6 stays behind it. "In both directions" is gone; "provably mid-feature" became "evidently mid-feature (by the heuristic below, which is evidence and not proof)" in the documents, the roadmap and a digest marker. |
| F3 MINOR | "3 strict at the end" became "3 other strict (two near the end, one early at `declare phase 17`)" in the roadmap (twice) and the flow-down note. **Plan D3's "strict at 3" and its "phases 4 to 9" / "4 to 10" wording wait for the owner's approval of the amendment.** |
| F4 MINOR | The decisions log said "green at 1470 cases"; those are test results (two per case) and not the state where the failure was found. Now "1460 test results, two per case, when the measurement ran; 1478 as shipped". |
| F5 cosmetic | A blank line before `## 3. Other surgical files` in `adoption/updating.md`. |

### T010 — final run on an isolated checkout

A detached `git worktree` outside the repository at `dc7ad52` (the phase 2 commit), removed afterwards. **Full harness: 1478 passed, 0 failed,
0 skipped** (1261 s), exit 0. `ritual-checks.ps1 -Branch 024-critical-branch-not-red`: doc-lint OK, enforcement-pack OK, scope-check
OK, digests OK (105 markers), roadmap-claims OK, scope-repos and verify-kit n/a, `RESULT OK`, exit 0. `scope-check.ps1` on every phase
commit: PASS for `dc7ad52` (8 files), `2b9c24b` (14), `76879f2` (17), `20855f5` (14), `4c8fe99` (35) and `2300e44` (33).

What the run does not cover, said plainly: the commits after `dc7ad52` (the phase 2 review file, its remediation `949e563`, and a plan
wording amendment approved by the owner) change documents, `notes.md` and `plan.md` only (`git diff --stat dc7ad52 HEAD`: no script, no
test), so the harness result carries over by the diff and was not re-run on them; `ritual-checks` was re-run on each, `RESULT OK`.
The owner's phase 2 gate and the human review at merge are still to come.

### Gate 3 certification, phase 2 (user-run)

Gate certified (user-run): `pwsh -File scripts/ritual-checks.ps1` on the feature branch at `6ebc583` (phase 2 and its remediation, the plan
wording amendment, the T010 notes), exit code **0**, confirmed by the owner (anas.m, 2026-10-13). Gate 3 is therefore certified for both phases;
gate 5 (fresh-context AI review) was done five times (four on phase 1, one on phase 2, each filed verbatim in this directory); gate 6, the human
review at merge, is not done and belongs to a reviewer who is not the owner.
