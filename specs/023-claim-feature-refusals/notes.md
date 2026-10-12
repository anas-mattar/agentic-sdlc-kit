# Notes: claim-feature.ps1's refusals reach their own message and exit (023)

Phase evidence, measurements and decisions. Not an approved document: `tasks.md` holds the agreed work, this
holds what happened.

## Phase 1: the refusals and their proof

### T001: baseline on the parent commit

Taken on an isolated detached worktree of the parent commit (`3fa9b45`, the plan-approval commit), so no edit of the
working tree could reach it.

| Measurement | Value |
|---|---|
| Full harness | **1373 passed**, 0 failed, 0 skipped, `enforcement-tests: OK` |
| Coverage report | 9 grading scripts, 235 of 244 sites fixtured, **3 exempt** rules, 6 declared not a rule; `claim-feature.ps1` is not in it |

What a human sees from each refusal, and from each successful claim, run as `pwsh -File scripts/claim-feature.ps1
-ShortName probe "a probe"` from purpose-built directories (a git repository on `main` with a stub stock script; a bare
repository as `origin` where one is named):

| Case | Exit under `pwsh -File` | Output |
|---|---|---|
| line 72, not a git repository | **1** | a PowerShell error record (`Write-Error: <script path>:72`, a `Line |` excerpt with a caret rule), the message last |
| line 79, dirty working tree | **1** | the same record shape; the message and the dirty path on one line |
| line 84, not on main | **1** | the same |
| line 96, fetch of origin fails | **1** | the same |
| line 108, stock script missing | **1** | `WARNING` (no origin), `Allocating ...`, then the record |
| line 112, stock script fails | **1** | `WARNING`, `Allocating ...`, then the record with `create-new-feature.ps1 failed:` and the stub's line |
| a claim with no origin | 0 | `WARNING: No origin ...`, `Allocating ...`, `CLAIMED LOCALLY ...`, `SPEC_FILE`, `NEXT` |
| a claim with an origin that takes the push | 0 | `Allocating ...`, `CLAIMED: ... (pushed to origin ...)`, `SPEC_FILE`, `NEXT` |
| a claim with `-NoPush` | 0 | `Allocating ...`, `WARNING: Push skipped ...`, `CLAIMED LOCALLY ...`, `SPEC_FILE`, `NEXT` |

This measures the spec's premise on this script (the spec had it only from `territory-check.ps1`): at a terminal the
exit is already 1 for all six. The text of the three successful claims was saved and compared in T005.

### T002: the fixtures, shown failing on the parent

Fourteen cases under `tests/enforcement/cases/claim-feature/`, hand-written expectations, generated from one script so
that each pair differs only in the condition under test: a `fail` and a `pass` for each of `CLF-001` to `CLF-006`, plus
`CLF-003/fail-json` (the refusal under `-Json`, spec US1 scenario 7) and `CLF-004/pass-nopush`. Run through the real
harness on a second detached worktree of `3fa9b45` carrying the new cases and the new `Harness.psm1` normaliser but the
parent's `claim-feature.ps1`:

| Case | On the parent | Observed |
|---|---|---|
| `CLF-001/fail` | fails | exit **128**, not 1; the launcher's line `RunChild: the script under test threw before returning a verdict: Not inside a git repository.` |
| `CLF-002/fail` | fails | exit **97**, not 1; the launcher's line with the working-tree message |
| `CLF-003/fail` and `fail-json` | fail | exit **97**, not 1; the launcher's line with the main-branch message |
| `CLF-004/fail` | fails | exit **128**, not 1; the launcher's line with the fetch message |
| `CLF-005/fail` | fails | exit **97**, not 1; the launcher's line with the stock-script message |
| `CLF-006/fail` | fails | the exit-code check **passes** (the stub's own exit 1 leaks through, so 1 is observed by accident); the output check fails: the launcher's line, not the message |
| the seven `pass` cases and `pass-nopush` | pass | as designed |

Deviation from the plan's wording ("the launcher's line, exit 97 or 128"): for `CLF-006` the exit is 1 on the parent too,
by leakage from the stub's `exit 1`, so only its output check proves the defect. Same family as the `TERR-` finding in
feature 022 (the exit is whatever the last native command left behind).

### T003 and T004: the sweep and the script

- `rules.json`: `CLF-001` to `CLF-006`, and `CLF-007` (the lost race, site 135) exempt with the written reason of plan D2.
- `emission-idioms.json`: the script's entry, accumulators `Stop-Refused\s+['"]` and `Write-Warning\s`, three warnings
  declared not-a-rule with reasons (no origin and `-NoPush`, asserted verbatim by `CLF-001/pass` and `CLF-004/pass-nopush`;
  the per-attempt race warning, covered by `CLF-007`'s exemption).
- `Coverage.Tests.ps1`: `claim-feature.ps1` joins the list of grading scripts.
- `scripts/claim-feature.ps1`: `Stop-Refused` (error stream via `[Console]::Error.WriteLine`, then `exit 1`; plan D1, a copy)
  and the seven `Write-Error ...; exit 1` sites call it with the same message text, including the embedded dirty paths
  and the stock script's output. 17 insertions, 11 deletions; nothing else in the script changed.

**Deviations from the plan, each forced by running it.**

1. **The normaliser gained one substitution** (`tests/enforcement/lib/Harness.psm1`, with two self-tests in
   `Harness.Tests.ps1`): the rest of a path that follows `<ROOT>` is written with forward slashes. The script joins paths
   with `Join-Path`, so the `SPEC_FILE:` line and the `Stock script not found:` message print backslashes on Windows and
   slashes on Linux, and a hand-written expectation could only match one runner. No existing expectation had a
   backslash after `<ROOT>` (none found), so no pre-existing case moves. Not in the plan, which said no harness change.
2. **The pass cases that push use a nested repository as `origin`**, not `origin: self` (the plan's Risks named this
   as untested). With `origin: self` the stock stub checks out the new branch in the very repository that would receive
   the push, which git refuses; the nested repository (`origin.git`, ignored by a committed `.gitignore` so the working
   tree stays clean) takes the push. `CLF-004/fail` carries the same nested repository and `.gitignore` and differs only in
   where `origin` points. The risk is resolved by the passing cases, on Windows; the Linux CI leg is not exercised here.
3. **The stubs are written inline by the recipe's `write` field**, not placed by `copy` as the plan said: no existing case
   uses `copy`, `write` keeps the stub readable in the recipe, and the tree stays clean either way.
4. **Fourteen cases, not twelve**: `fail-json` and `pass-nopush` are variants the spec asked for (US1 scenario 7, the
   `-NoPush` warning's owner).

### T005: working tree after T002-T004

| Measurement | Value |
|---|---|
| `-Case CLF-` | 67 passed, 0 failed (14 cases, the coverage tests and the harness's own self-tests, which run under every filter) |
| Full harness | **1403 passed**, 0 failed, 0 skipped, `enforcement-tests: OK` (parent: 1373; 30 more: the 14 cases at two checks each, plus the 2 normaliser self-tests) |
| Coverage | 10 grading scripts, 241 of 254 sites fixtured; `claim-feature.ps1` **6 of 10** (1 exempt, 3 not a rule); exempt rules **4** (parent: 3, the one added is `CLF-007`) |
| `ritual-checks.ps1` | `doc-lint`, `enforcement-pack`, `digests`, `roadmap-claims` OK; `scope-check` `UNGRADED` (no phase commit on the branch yet, expected); `scope-repos` and `verify-kit` n/a; `RESULT UNGRADED`, nothing failed |
| The probe's three successful claims, new against the saved parent text | **byte-identical** (no origin; an origin that takes the push; `-NoPush`) |
| The probe's six refusals | the same message text and exit 1; what goes is PowerShell's error-record header (script path, line number, caret rule) around the message; the line-79 message now prints the dirty path on its own line (the record had flattened it onto the message's line) |

Every pre-existing case passes unchanged.

### Findings recorded, not fixed

- **An eighth terminating site, outside the spec's seven.** `scripts/claim-feature.ps1` line 47, in `Get-RemoteFeatureHeads`:
  `throw "git ls-remote failed — cannot read the remote ledger."`. It is the same species (a terminating write under
  `$ErrorActionPreference = 'Stop'`: the process exits through PowerShell's error path, not through the script's own exit),
  but a `throw`, so the spec's grep for `Write-Error` missed it and the coverage sweep does not report it. It is reachable only
  when `git ls-remote` fails right after a successful `git fetch`, which a fixture cannot produce without a new recipe
  field. Left unchanged: FR-006 forbids other behaviour changes, and widening the spec mid-phase needs an approved amendment.
  Decision (the owner's go-ahead, 2026-10-12, "go with your recommendation"): record it, do not widen; it goes in the phase 2
  decisions-log entry as open. A later feature can convert it and add the field.
