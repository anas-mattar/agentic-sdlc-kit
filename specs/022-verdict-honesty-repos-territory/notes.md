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
