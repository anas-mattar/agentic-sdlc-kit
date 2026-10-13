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
