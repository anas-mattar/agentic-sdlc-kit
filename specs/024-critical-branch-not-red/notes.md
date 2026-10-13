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
