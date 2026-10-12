# Notes: Verdicts that say what was compared (022)

Phase evidence, measurements and decisions. Not an approved document: `tasks.md` holds the agreed work, this
holds what happened.

## Phase 1: the repository run-level verdict

### T001: baseline on the parent commit

Taken on an isolated detached worktree of the parent commit (`c300851`, the approved-`tasks.md` commit), so no
edit of the working tree could reach it.

| Measurement | Value |
|---|---|
| Full harness | **1335 passed**, 0 failed, 0 skipped, `enforcement-tests: OK` |
| `Run-Tests.ps1 -Case REPOS-` | 161 passed, 0 failed |
| `Run-Tests.ps1 -Case TERR-` | 157 passed, 0 failed |
| `Run-Tests.ps1 -Case RIT-` | 129 passed, 0 failed |

Exact output of `scope-check-repos.ps1 -All` on a two-repository fixture where both repositories graded (the
recipe of `REPOS-034/pass`, built with the parent commit's `FixtureRepo.psm1`; exit 0; short SHAs normalised to
`<SHA>` because they change with the fixture's build time):

```text
scope-repos: code-repo: PASS phase 1 commit <SHA> (1 file(s))
scope-repos: web-repo: PASS phase 1 commit <SHA> (1 file(s))
```

### T005: working tree after T002-T004

| Measurement | Value |
|---|---|
| `-Case REPOS-` | 175 passed, 0 failed (parent: 161) |
| `-Case RIT-` | 133 passed, 0 failed (parent: 129) |
| `ritual-checks.ps1` | `doc-lint` OK, `enforcement-pack` OK, `digests` OK, `roadmap-claims` OK, `verify-kit` n/a, `scope-repos` n/a; `scope-check` UNGRADED (no phase commit on the branch yet, expected before the phase commit); no member failed |
| Two-repository output, both graded, `-All` | **byte-identical** to the saved text above after SHA normalisation |

Full harness on the working tree: **1353 passed**, 0 failed, 0 skipped, `enforcement-tests: OK` (parent: 1335; 18 more).

### T002: the new fixtures on the parent commit

The four `fail` fixtures and the changed `REPOS-015/fail` were run through the real harness on the detached
worktree of `c300851`, with the new case directories, the changed `REPOS-015/fail/expected.txt` and the new
`rules.json` copied in and the script left as it was on the parent.

| Case | On the parent | Why |
|---|---|---|
| `REPOS-034/fail` | fails | no run-level `UNGRADED (1 declared code repository ... web-repo ...)` line (observed none); the no-trunk line also still says `pass -BaseRef <ref> naming its trunk` |
| `REPOS-034/fail-beside-a-failure` | fails | same two reasons, with the run still exiting 1 |
| `REPOS-034/fail-skipped-commits` | fails | no run-level line: B's only commits are skipped, and the parent prints nothing about B |
| `REPOS-015/fail` | fails | only the hint text differs: parent prints `pass -BaseRef <ref> naming its trunk`, expected is `to grade it, run: pwsh -File scripts/scope-check-repos.ps1 -All -Repo code-repo -BaseRef <trunk>` |
| `REPOS-034/pass`, `pass-tip-mode`, `pass-absent-repository` | pass | as designed: these pin the output that must not change |
| `REPOS-015/pass-hint-as-printed` | passes | as designed: it runs `-All -Repo ... -BaseRef develop`, which the parent already grades; it pins that the printed command works, the hint text itself is pinned by `REPOS-015/fail` |
| `RIT-009/fail`, `RIT-009/pass` | both pass | as designed: `ritual-checks.ps1` is unchanged and the member is a stub, so this proves the aggregator lifts the new line, not that the parent lacks it (`REPOS-034` proves that) |

The coverage tests (`every inventoried rule still exists`, `every anchor names exactly the emission sites`) also
fail on the parent, for `REPOS-034`: its anchor is not in the parent's `scope-check-repos.ps1`. That is the
expected consequence of copying `rules.json` without the script change, not a separate finding.

### Not yet recorded

- `TERR-` was not re-run on the working tree; Phase 1 touches no territory-check code.

## Phase 2: the four refusals

### T006: baseline on the parent commit

Taken on an isolated detached worktree of the parent commit (`3ed189e`, the phase 1 remediation), so no edit of the
working tree could reach it.

| Measurement | Value |
|---|---|
| Full harness | **1355 passed**, 0 failed, 0 skipped, `enforcement-tests: OK` |
| `Run-Tests.ps1 -Case TERR-` | 157 passed, 0 failed |
| Coverage report, exempt rules | **7** (`AMEND-007`, `REPOS-033`, `TERR-008` to `TERR-011`, `VK-028`) |
| `territory-check.ps1` sites | 18 of 23 fixtured (4 exempt, 1 not a rule) |

What a human sees today from each refusal, run as `pwsh -File scripts/territory-check.ps1` from a purpose-built
directory (the four situations were built by hand outside the harness; the parent exits **1** in all four, so the
exit-97 premise of the plan is a harness fact, not a terminal fact). Each prints a PowerShell error record: the
`Write-Error: <absolute script path>:<line>` header, a `Line |` excerpt of the source with a caret rule, and the
message last:

| Rule | Message (last line of the record) | Exit under `pwsh -File` |
|---|---|---|
| `TERR-008` | `Not inside a git repository.` | 1 |
| `TERR-009` | `Branch 'feature-x' is not a numbered feature branch (NNN-name) - the territory check applies to the feature lane only.` | 1 |
| `TERR-010` | `git fetch origin failed.` | 1 |
| `TERR-011` | `Cannot diff main...HEAD - does 'main' exist?` | 1 |

(The dash in the `TERR-009` row prints as a hyphen because the capture ran in the console code page; the script's
text has an em dash, which the harness expectation pins.)

### T007: the `noGit` recipe field

`tests/enforcement/lib/FixtureRepo.psm1` removes `.git` after everything else is built; documented in the file header
and `tests/enforcement/README.md`. It is refused together with `shallow` or `nestedRepos` rather than ignored (a clone
lands elsewhere; a nested repository needs a repository to nest in). Two self-tests in `Harness.Tests.ps1`: the field
leaves the written files and no repository, and both refusals fire.

### T008: the fixtures, shown failing on the parent

Eight cases, hand-written expectations: a `fail` and a `pass` for each of `TERR-008` to `TERR-011`, each pair
differing only in the condition (the repository itself, the checked-out branch, where `origin` points, the trunk's
name). Run through the real harness on a second detached worktree of `3ed189e` carrying the new cases and the new
`FixtureRepo.psm1` but the parent's `territory-check.ps1`:

| Case | On the parent | Observed |
|---|---|---|
| `TERR-008/fail` | fails | exit **128**, not 1; the launcher's line `RunChild: the script under test threw before returning a verdict: Not inside a git repository.` |
| `TERR-009/fail` | fails | exit **97**, not 1; the launcher's line with the branch message |
| `TERR-010/fail` | fails | exit **128**, not 1; the launcher's line with `git fetch origin failed.` |
| `TERR-011/fail` | fails | exit **128**, not 1; the launcher's line with the diff message |
| the four `pass` cases | pass | as designed |

Deviation from the plan's wording ("exit 97 and the launcher's line"): only `TERR-009` exits 97. The other three exit
128, which is the exit code of the last native command (`git`) leaking through the launcher after the terminating
`Write-Error`. That is a stronger version of the same defect (the exit code is whatever the last git call left
behind), and is why the new `Stop-Refused` pins `exit 1` explicitly.

### T009 and T010: exemptions out, `Stop-Refused` in

- `rules.json`: the `exemption` and `notes` entries of `TERR-008` to `TERR-011` are removed; id, script, function,
  summary, law and anchor are kept.
- `emission-idioms.json`: the `Write-Error\s` accumulator for `territory-check.ps1` becomes `Stop-Refused\s+['"]`,
  call sites only. The first draft, `Stop-Refused\s`, also matched the line `function Stop-Refused {` and the coverage
  test reported it as an unowned site (`territory-check.ps1:61`); narrowing it to a quoted argument fixed that. The
  stale paragraph of the script's `note` (which said the four Write-Error sites were left uncovered on purpose) now
  describes the refusals as they are.
- `scripts/territory-check.ps1`: `Stop-Refused` (error stream via `[Console]::Error.WriteLine`, then `exit 1`) and the
  four sites call it with the same message text. Nothing else in the script changed (14 insertions, 5 deletions).

### T011: working tree after T007-T010

| Measurement | Value |
|---|---|
| Full harness | **1373 passed**, 0 failed, 0 skipped, `enforcement-tests: OK` (parent: 1355; 18 more: 8 new cases at two checks each, plus the 2 `noGit` self-tests) |
| `-Case TERR-` | 175 passed, 0 failed (parent: 157; 18 more = 16 from the 8 new cases at two checks each, plus the 2 `noGit` self-tests, which run under every `-Case` filter) |
| `-Case RIT-` | 135 passed, 0 failed (phase 1 recorded 133; the 2 more are the `noGit` self-tests; no RIT case changed) |
| Coverage | exempt rules **3** (was 7; `TERR-008` to `TERR-011` out); `territory-check.ps1` 22 of 23 sites fixtured, 1 not a rule (was 18 of 23, 4 exempt) |
| `ritual-checks.ps1` | `RESULT OK`: `doc-lint`, `enforcement-pack`, `scope-check`, `digests`, `roadmap-claims` OK; `verify-kit` and `scope-repos` n/a |
| T006's four refusals under `pwsh -File` | same message, same exit code **1** in all four; the error record's header, source excerpt and caret rule are gone (the planned change) |

Every pre-existing case passes unchanged; the coverage report fixtures `TERR-008` to `TERR-011` and no longer lists them
as exempt.

### Phase 2 AI review: remediation and recorded findings

Review: `ai-code-review-phase-2.md` (APPROVE with follow-ups). Fixed in the remediation commit: F1 (the `note` in
`emission-idioms.json` no longer states a site count), F2 (the `noGit` incompatibility is refused at the top of
`New-FixtureRepo`, before anything is built, so the refusal self-test no longer leaves two `kit-fixture-*` repositories
behind; the cleanup that could never run is removed from the test), F3 (the `TERR-008/fail` description says 128, the
measured exit, not 97).

**F4, recorded: `claim-feature.ps1` has the same defect, at seven sites, not the five the plan's Risks list.** The
script sets `$ErrorActionPreference = 'Stop'` (line 37), and `Write-Error` therefore throws before any `exit 1` after
it. Sites: `scripts/claim-feature.ps1:72` (not inside a git repository), `:79` (working tree not clean), `:84` (claims
start from main), `:96` (`git fetch origin` failed), `:108` (stock script not found), `:112` (`create-new-feature.ps1`
failed) and `:135` (lost the allocation race). The plan listed the first five; `:112` and `:135` were found by the
Phase 2 review. It is outside this feature's scope and Territory and is not fixed here. It is a candidate roadmap gap
for the owner to open (the same shape as GAP-029: `Stop-Refused`-style exit, fixtures, exemptions out); Phase 3's
`docs/roadmap.md` update is where it would be filed if the owner wants it, and has not been.

**F5 (confirm) and F6 (minor), not changed.** F5: `[Console]::Error.WriteLine` writes to the process's stderr, not
PowerShell's error stream, so in-process `2>&1` / `2>$null` no longer see the message; `pwsh -File` callers are
unaffected and plan D6 approved the method. Awaiting the owner's answer on whether `pwsh -File` is the only supported
contract. F6: `TERR-008` assumes the OS temp directory is not inside a git work tree (true on this machine and both CI
legs); `GIT_CEILING_DIRECTORIES` for `noRoot` cases would harden it. Optional.
