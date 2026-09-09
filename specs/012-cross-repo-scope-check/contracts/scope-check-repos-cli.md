# Contract — `scripts/scope-check-repos.ps1` CLI

Companion to `specs/006-verification-pack/contracts/scope-check-cli.md`, which this check
mirrors. Where the two disagree in wording but not intent, the 006 contract governs the shared
semantics (parsing, matching, verdicts) — they run the same code (`scripts/scope-lib.ps1`).

## Surface

```powershell
pwsh -File scripts/scope-check-repos.ps1                        # HEAD of each declared repo
pwsh -File scripts/scope-check-repos.ps1 -All                   # every phase commit since merge-base (CI mode)
pwsh -File scripts/scope-check-repos.ps1 -Repo fitforge-api     # one declared repository only
pwsh -File scripts/scope-check-repos.ps1 -Branch 012-x -All     # explicit branch (detached HEAD / CI)
pwsh -File scripts/scope-check-repos.ps1 -Root D:\solutions\fitforge
```

| Parameter | Meaning | Default |
|---|---|---|
| `-Root` | governance repository root (holds `specs/`, `kit-adoption.json`) | the script's parent directory |
| `-Branch` | feature branch name, in both the governance and code repositories | current branch of the governance repository |
| `-Commit` | grade this one commit in each code repository | `HEAD` |
| `-Phase` | override phase attribution | parsed from the commit subject |
| `-All` | grade every non-merge commit since the merge base with `main` | off |
| `-Repo` | restrict to one declared repository (a code repo's own CI) | all declared |

Read-only: the script never writes, fetches, or checks out.

## Verdicts and exit codes

| Verdict | Meaning | Exit |
|---|---|---|
| PASS | every touched path is inside the declared territory | 0 |
| not applicable | nothing to grade (no matching branch, no phase token, merge commit, trunk) | 0 |
| n/a | the check cannot apply here (no `codeRepos`, tree absent, not a git repo) | 0 |
| WARN | no declaration as of the code commit; detached HEAD without `-Branch` | 0 |
| FAIL | an undeclared path, or a malformed/duplicated declaration | 1 |

Overall exit is 1 iff at least one repository FAILs. One verdict block per repository, prefixed
with the repository name, so a multi-repo run reads top to bottom.

## Territory resolution

1. Territory entries are **repo-prefixed, governance-root-relative** (D3):
   `` `fitforge-api/src/Training/**` ``. Each code repository's touched paths are prefixed
   with its declared directory name before matching.
2. The declaration is read **as of the code commit** (D4): the newest governance commit whose
   committer date is not after the code commit's, via `git rev-list -1 --before=`. Widening the
   declaration later is invisible to an earlier commit's verdict.
3. Source file: `specs/<branch>/tasks.md` under the phase heading; on a feature whose `spec.md`
   declares `**Delivery Level**: Micro`, the feature-global block in `spec.md` (the lane has no
   `tasks.md`).
4. The feature's own spec directory is implicitly in territory, as in the governance check —
   it never appears in a code repository, so it is inert here.

## FAIL message shapes

```text
scope-repos: fitforge-api: FAIL phase 2 commit ab12cd3: fitforge-api/src/Legacy/Helper.cs not in territory
scope-repos: fitforge-api: remediation — revert the undeclared change, or amend the phase's
  **Territory** in specs/<branch>/tasks.md (owner approval) in a governance commit made BEFORE
  the code phase commit, then re-commit the phase
```

Every FAIL names the offending path — repo-prefixed, exactly as a territory entry is written —
and the remediation (FR-010). The output prefix is `scope-repos`, matching the ritual-checks
member name (the `build-digests.ps1` → `digests` precedent), so the wrapper can read the
member's own `n/a` line into its summary.

## Scenarios

Fixtures are throwaway repositories seeded under the scratchpad by
`seed-fixtures.sh` (a governance repo with a Standard feature `013-demo`, a Micro feature
`014-micro`, a graded code repo `demo-api`, a non-participating `demo-web`, an absent
`demo-ghost`, and a plain directory `demo-plain`), all commit dates fixed so the D4 ordering is
deterministic. Verdicts recorded on the 2026-09-09 run, phase 1.

| # | Scenario | Expected | Recorded |
|---|---|---|---|
| C1 | in-territory code phase commit | PASS, exit 0 | **PASS, exit 0** — `demo-api: PASS phase 1 commit dc6bffd (1 file(s))` |
| C2 | out-of-territory path | FAIL, exit 1, path named | **FAIL, exit 1** — `demo-api/README.md not in territory` + remediation |
| C3 | code repo has no matching branch | not applicable, exit 0 | **not applicable** — `no '013-demo' branch here` |
| C4 | declared repo directory absent | n/a, exit 0 | **n/a, exit 0** — declared `demo-ghost` absent |
| C5 | declared directory is not a git repository | n/a with reason, exit 0 | **n/a, exit 0** — `demo-plain` sits inside the governance repo, so it is not a repository of its own |
| C6 | commit without a `phase N` token | not applicable, exit 0 | **not applicable** — `carries no 'phase N' token` |
| C7 | Micro feature — territory from `spec.md` | graded, PASS and FAIL both reachable | **PASS** (`Micro territory from spec.md`) and **FAIL** (`src/Outside.cs`) both reached |
| C8 | declaration widened after the code commit | FAIL, exit 1 | **FAIL, exit 1** — declaration widened at 2026-09-04 is invisible to the 2026-09-03 commit |
| C9 | no declaration as of the code commit | WARN, exit 0 | **WARN, exit 0** — no `tasks.md` in the governance repo as of 2026-09-01T11:00 |
| C10 | territory names an undeclared repo prefix | config warning, grading continues | **WARN, graded on** — `demo_api/typo/**` reported once per run |
| C11 | detached HEAD without `-Branch` | WARN, exit 0 | **WARN, exit 0** — detached governance HEAD without `-Branch` |

Behavior preservation: after the `scope-lib.ps1` extraction, the 006 contract scenarios re-run
against `scripts/scope-check.ps1` must produce identical verdicts.
