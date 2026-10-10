# Research: Cross-repo Territory Reach

**Feature**: `018-cross-repo-territory-reach` | **Date**: 2026-10-11

Every decision below resolves a question the spec left to planning. Each was answered by reading
the scripts and fixtures it touches; none needed anything outside the repository.

## R1 — Where the shared readers live

**Decision**: two functions are extracted from `scripts/scope-check-repos.ps1` and shared, and no
new file is created.

- `Get-CodeRepos` goes into `scripts/adoption-lib.ps1`, beside the other readers of the adoption
  record (`Get-DeveloperMode`, `Get-CriticalSurfaces`). It returns the usable directory names and the
  warnings the scope check prints today, as data, so each caller prints them in its own voice.
- `Get-RepoMergeBase` (a ref against the trunk candidates, `main`, `master` and their `origin/`
  forms plus `origin/HEAD`) goes into `scripts/scope-lib.ps1`, which already exists to be shared by
  the two scope scripts for exactly this reason: two graders of one rule drift.

`scripts/territory-check.ps1` dot-sources both. `scripts/scope-check-repos.ps1` is edited to call
them and must behave identically; its 32 `REPOS-*` rules are the guard.

**Rationale**: spec FR-003 and FR-005 forbid a second interpretation of `codeRepos` and of the trunk
order. Copying `Get-DeclaredRepos` into the territory check would be the defect feature 013 shipped
and paid for. A new `repos-lib.ps1` would also need a manifest entry and would flow down as a new
file to every adopter, for no gain over the two libraries that already ship verbatim.

**Alternatives considered**: duplicating the function with a comment saying the copies must match
(rejected: a comment is not a mechanism, 013's lesson); a new shared script file (rejected above);
calling `scope-check-repos.ps1` as a subprocess to learn the repositories (rejected: it grades
commits and prints a verdict, it does not return a list).

## R2 — How another feature's work in a code repository is found

**Decision**: for each declared code repository the check runs `git fetch origin --prune` in it, then
looks for the other feature's branch as `refs/remotes/origin/<branch>`, falling back to
`refs/heads/<branch>`. A branch found in neither means that feature did no work there: not an overlap
and not a failure (spec FR-004). A branch found whose diff cannot be computed is ungraded, naming the
feature and the repository. A fetch that fails makes that **repository** ungraded: the check does not
fall back to the stale local view and call it complete (spec FR-009).

A code repository with no `origin` is compared against its local branches only, and the output says
so on that repository's line (spec Assumptions).

**Rationale**: the claim ledger is the governance repository's remote branches. A code repository's
branch for the same feature is where the code lives, and 012 already fixed the name convention.
Remote-tracking first matches how the governance comparison reads other branches today
(`origin/$other`).

**Alternatives considered**: reading only local heads (rejected: it misses every other developer's
pushed work, which is the whole point); `git ls-remote` per code repository to learn which branches
exist without fetching (rejected: it cannot give a diff, and a second round trip buys nothing the
fetch does not).

## R3 — The merge base is per ref, and an unresolvable one is ungraded

**Decision**: the touched set of a ref in a code repository is `git diff --name-only <base> <ref>`,
where `<base>` is the merge base of the ref and the first trunk candidate that exists and shares a
history with it. The candidate order is the scope check's. A ref for which no base resolves is
ungraded.

Two different causes are named separately because they mean different things to the owner. If **no**
trunk candidate exists in the repository, the cause is "no resolvable trunk", naming the candidates
tried. If a trunk exists but one feature's ref shares no history with it, the cause is "branch cannot
be compared", naming the feature.

**Rationale**: the existing governance comparison uses a three-dot diff against a configurable
`-BaseBranch` that defaults to `main`. A code repository's trunk is often `master` or `develop`
(012 phase 1 review, F5), so it has to be resolved, and per ref because two branches may fork from it
at different points.

**Alternatives considered**: a single trunk ref and three-dot diffs (equivalent in result, but it
cannot distinguish the two causes above); a new `-CodeBaseBranch` parameter (rejected: nothing in the
spec asks for configuration, and 012 deliberately added none).

## R4 — Liveness is judged across repositories

**Decision**: a feature's status is taken from its **latest commit in any repository it has a branch
in** (governance and every declared code repository), against the existing stale window, and "claimed,
no work yet" means no commits in any of them.

**Rationale**: the existing rule reads only the governance branch. A feature whose spec is two weeks
old and whose controller was pushed yesterday is live, and reporting it stale-and-reclaimable would
invite a second developer to adopt a claim that has a developer working on it (spec edge case).

## R5 — The verdict is one word for the whole run

**Decision**: the run's verdict is `OVERLAP` (a live overlap exists), else `UNGRADED` (something it
was asked to compare was not compared), else `CLEAN`. The ungraded lines are printed beside an overlap
and never instead of it (spec FR-010). Exit codes are unchanged: 2 for a live overlap, 1 for an
execution error, 0 otherwise, including ungraded (the kit's convention, feature 015 D6).

`CLEAN` for a project that declares code repositories names what was compared. For a project that
declares none the text is exactly what it is today, so no existing expectation moves.

The `-Json` object keeps `BRANCH`, `CLEAN` and `OVERLAPS`. `CLEAN` is false whenever anything was not
compared, and the object gains `UNGRADED`, a list of `{ repo, feature, cause, detail }`.

**One state is deliberately left alone**: a governance repository with **no remote** prints
`no remote - nothing to check against` and exits 0 before any comparison is attempted (`TERR-001`).
There is no claim ledger to compare against, so no comparison was asked for and none was skipped; the
line is already not the word `CLEAN`. It stays as it is, and the JSON form of it keeps its existing
shape.

**Rationale**: spec FR-008. A single verdict line cannot be honest about half a run, which is why the
spec brought the governance-skip half of GAP-029 in.

## R6 — A malformed `codeRepos` declaration: the spec and the constraint pull apart

**Decision, needing the owner**: spec FR-013 says a project that declares no **usable** `codeRepos`
sees its existing output unchanged. Read literally that includes a declaration that is present and
broken (a string where an array belongs, a path where a directory name belongs), and unchanged output
means a warning and then `CLEAN`. That is GAP-029's exact shape, and the spec's own constraint
forbids it.

The plan therefore implements: **absent or empty `codeRepos` is unchanged** (a lawful statement that
there are none); **a present but unusable declaration is UNGRADED, by name**, with the scope check's
own warning wording. This tightens FR-013 and spec US3 scenario 2 by one case.

The alternative is to implement FR-013 as written and record the gap. The plan recommends against it
for the reason above; either way the spec sentence needs the owner's approval line, because the plan
does not amend an approved document.

**Alternatives considered**: failing (exit 1) on a malformed declaration (rejected: a malformed record
is a configuration problem the doctor already reports, and an exit-1 here would block a pre-phase
check for a reason unrelated to overlap).

## R7 — Uncommitted changes in a code repository

**Decision**: tracked uncommitted changes in a code repository count as touched by the branch under
check **only if that repository's current branch is the branch under check**. Otherwise they belong to
some other feature and are ignored.

**Rationale**: spec FR-006 mirrors the governance rule ("tracked, uncommitted"), but the governance
rule reads `git diff HEAD` and so is correct only because the check is run on the branch it grades. In
a code repository the checkout can be on any branch, and attributing its working-tree edits to this
feature would manufacture overlaps.

## R8 — The harness shape

**Decision**: fixtures use the harness's existing nested-repository support (`nestedRepos`, built
recursively through the same function, with `origin: self` so each code repository is its own claim
ledger). The causes map onto states the recipe vocabulary already builds:

| Cause | Recipe |
|---|---|
| repository not present | declared in `codeRepos`, no `nestedRepos` entry |
| not a git repository | a plain directory written as files |
| no resolvable trunk | a nested repository whose only branch is the feature branch |
| remote cannot be fetched | `origin` pointing at a path that does not exist |
| branch cannot be compared | a feature branch sharing no history with the trunk |
| local-only comparison | a nested repository with no `origin` |

Rule ids continue the territory-check series: `TERR-013` onward. `TERR-012`'s expectation changes
(R5) and is recorded as the change.

## R9 — Cost

**Decision**: no optimisation. Per run the check makes a handful of git calls per (code repository x
open claim). A project has a few code repositories and a few open claims, and the governance check
already makes the same shape of calls per claim.

## R10 — Agent-context update

**Decision**: skip `update-agent-context.ps1`, for the reason feature 017 gave: it rewrites the
always-loaded `CLAUDE.md`, which is kit law and outside this feature's Territory, and there is no
technology to record.
