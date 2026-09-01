# Research: Enforcement Pack

## 1. Script structure and invocation

**Decision**: One script, `scripts/enforcement-pack.ps1`, with named switches/checks
(`-CheckStructure`, `-CheckLite`, `-CheckCritical`, `-WarnPhaseSize`, or simply "run all"
when called with no switch — mirroring `doc-lint.ps1`'s `param()` + full-run default). It
detects the current branch name via `git rev-parse --abbrev-ref HEAD` (overridable with
`-Branch` for CI, where `git rev-parse` may report `HEAD` in a detached checkout) and
dispatches only the checks relevant to that branch's taxonomy (`NNN-*` vs `fix/`/`chore/`
vs `docs/`), per Edge Cases' "unrecognized prefix" rule.

**Rationale**: One script keeps FR-001 literally true ("a single CI-agnostic script") and
matches the one-file precedent of `doc-lint.ps1`, which this repo's CI and developers
already know how to invoke (`pwsh -File scripts/enforcement-pack.ps1`). Named checks (rather
than one monolithic always-everything run) let `quickstart.md` exercise one check per
fixture branch cleanly, and let a future adopter disable a check they don't want without
forking the file.

**Alternatives considered**: A separate script per check (rejected — FR-001 explicitly asks
for "a single script"; five files would also multiply the doc-lint-style path-integrity
surface for no benefit). A generic rules-engine/config-driven check runner (rejected — over-
engineered for five fixed checks; FR-007's single-config-block requirement is satisfied by a
`param()` block or a top-of-file `$Config` hashtable, not a plugin system).

## 2. Branch diff base

**Decision**: `git merge-base HEAD origin/main` (falling back to local `main` when `origin`
is unavailable, matching this repo's own history of being local-only until this session) is
the base for every diff-shaped check (FR-003, FR-004, FR-006). In GitHub Actions, the
workflow checks out with `fetch-depth: 0` (full history) so `merge-base` and the git-log
date lookup in research item 4 both work — a shallow clone would silently break both.

**Rationale**: This is exactly how `docs/sdlc/team-workflow.md` and `branch-strategy.md`
already describe a feature branch's relationship to `main`; reusing it avoids inventing a
second, inconsistent notion of "the diff."

**Alternatives considered**: Diffing against the PR's declared base ref from GitHub Actions'
event payload (`github.event.pull_request.base.ref`) — rejected as the *primary* mechanism
because it would make the script GitHub-specific, contradicting FR-001's CI-agnostic
requirement; the workflow (Phase 3) may still pass it as an override for extra precision
without the script depending on it.

## 3. Lite-lane prohibition patterns and abuse-guard threshold

**Decision**: Kit-shipped defaults, all overridable in the single config block (FR-007):

| Category | Default glob(s) |
|---|---|
| Dependency manifests | `package.json`, `package-lock.json`, `*.csproj`, `requirements*.txt`, `Pipfile*`, `go.mod`, `go.sum`, `Gemfile*` |
| Auth code | `**/auth/**`, `**/*auth*.{ps1,py,ts,js,cs,go,rb}` (path- or filename-contains "auth") |
| Schema/migrations | `**/migrations/**`, `**/*migration*.{sql,ps1,py}` |
| Contracts | `**/contracts/**` |
| Domain invariants | the resolved `{{DOMAIN_INVARIANTS_PATH}}`, when filled (skipped — informational only — while the slot is unfilled, same convention `doc-lint.ps1` uses for unfilled slots) |

Abuse-guard file-count threshold: **25 changed files** for a `fix/`/`chore/` branch (a
generous default; `docs/sdlc/branch-strategy.md`'s lightweight lane is meant for small,
mechanical changes, and a real fix rarely spans 25 files). Migrations are always prohibited
on the Lite lane regardless of count (FR-004), independent of the file-count guard.

**Rationale**: These are the categories spec.md's FR-003 names verbatim; the specific globs
are the smallest reasonable set an adopter would recognize and retune for their own stack
(CLAUDE.md's Stack Profile is exactly where a project would override these). 25 files is
generous enough not to trip on a legitimate multi-file lint-fix while still catching "this
grew into a feature" drift.

**Alternatives considered**: A stricter file-count (e.g. 5) — rejected as too eager to false-
positive on innocuous fixes, undermining trust in the check early. Detecting "auth" via
AST/semantic analysis instead of path globbing — rejected as far beyond this feature's
scope (a CI-agnostic PowerShell script, not a static-analysis tool) and unnecessary: path
naming conventions are how `critical-delivery.md` itself describes the boundary.

## 4. Dating `second-model-review.md` for the cooling-off check

**Decision**: `git log --follow --format=%aI -- specs/NNN-name/second-model-review.md | Select-Object -Last 1`
— the author-date ISO-8601 timestamp of the file's *first* commit — is the artifact's
recorded time. The check computes `(Get-Date) - $recordedTime` and fails if under 24 hours.

**Rationale**: Assumption already recorded in spec.md — git history cannot be post-dated by
editing file content, so it is the only tamper-resistant timestamp available without adding
new infrastructure (a database, a signing service). Using the *first* commit (not the latest)
means later edits to the review during the cooling-off window don't reset the clock in the
developer's favor, matching the honesty intent of `critical-delivery.md` item 5.

**Alternatives considered**: An explicit `**Date**:` line inside the file, trusted as-is —
rejected (spec.md's Assumptions section already rules this out: it's editable, so it can't be
authoritative; kept as informational only, matching the human-pr-review template's existing
`**Date**` convention elsewhere in the kit). A CI-external timestamp service — rejected as
infrastructure the kit does not otherwise require and that a solo/offline adopter couldn't
use.

## 5. Phase-commit diff-size warning threshold

**Decision**: Warn (FR-006) when a single commit on the branch changes more than **400
lines** (insertions + deletions) or **15 files**, whichever trips first — checked per commit
via `git log --numstat`, not against the branch's total diff.

**Rationale**: This is deliberately generous and non-blocking (Success Criteria SC-005) —
it exists to surface an oversized phase to the human reviewer, not to second-guess the
plan-approval judgment call the phase-sizing rule (constitution X, `plan-template.md`) already
makes. 400 lines / 15 files is large enough that `001-delivery-core-amendment`'s own Phase 3
(the biggest of its three phases, a 17-file renumbering sweep) would have tripped the file
count but not by a wide margin — a reasonable calibration point from this repo's own recent
history.

**Alternatives considered**: A hard block instead of a warning — rejected; spec.md's US4 is
explicit that this is a visibility aid, and a heuristic threshold blocking merges risks
punishing a legitimate large mechanical sweep (exactly the kind Phase 3 of 001 was).

## 6. CI workflow shape

**Decision**: A single GitHub Actions workflow, `.github/workflows/enforcement-pack.yml`,
triggered on `push` and `pull_request` targeting `main`, with `fetch-depth: 0` checkout,
running `pwsh -File scripts/enforcement-pack.ps1` and surfacing its output directly (the
script's own `Write-Host` messages become the job log; a non-zero exit fails the job). One
job, not a matrix — the script already dispatches per-branch-taxonomy internally (research
item 1), so there's nothing to parallelize at the workflow level for a repo this size.

**Rationale**: Minimal, matches how a solo/small-team adopter would read and modify it
without prior GitHub Actions expertise, and keeps FR-008 satisfied without inventing
matrix/caching complexity this repo doesn't need.

**Alternatives considered**: Splitting each check into its own job (parallelism) — rejected,
premature for a script that runs in well under a second on this repo's current scale; would
also complicate the single-exit-code contract FR-001 relies on for local (non-CI) use.

## 7. PR template and branch-protection recipe content

**Decision**: `.github/PULL_REQUEST_TEMPLATE.md` embeds the exact checklist items from
`specs/_templates/human-pr-review-template.md` (kept in sync by hand — no templating engine
exists in this kit) plus one additional field: `**Gate exit code**: EXIT: ___` directly
below the existing "Gate Result" checklist item, satisfying FR-009. `docs/sdlc/branch-
protection.md` documents, as numbered steps, the GitHub UI path (Settings → Branches → branch
protection rule → Require status checks to pass → select the `enforcement-pack` job) needed
to satisfy FR-010/SC-006, written so a maintainer without prior GitHub admin experience can
follow it once.

**Rationale**: Directly satisfies FR-009/FR-010 with no new mechanism; reuses the existing
review-template content rather than forking it into a second copy (avoiding the exact kind
of triplication `001-delivery-core-amendment` just finished removing from the source-of-
truth ladder).

**Alternatives considered**: Generating the PR template from `human-pr-review-template.md`
at CI time — rejected as unnecessary tooling for a five-section checklist that changes
rarely; a doc-lint-style drift check between the two files is deferred to `v1.1+` (mechanized
mirror checks are already listed there for the source-of-truth ladder; this is the same
class of problem and can ride the same future mechanism).

## 8. Phase ordering for this feature

**Decision**: Phase 1 ships the script skeleton plus the two highest-priority checks (US1
structural presence, US2 Lite-lane/abuse-guard) *and* the CI workflow, so that from Phase 1
onward every subsequent phase is exercised by real CI on this repo, not just local runs.
Phase 2 adds the two remaining checks (US3 Critical-evidence, US4 phase-size warning) as pure
additions to the same script file. Phase 3 adds the merge-gate wiring (US5: PR template +
branch-protection recipe) last, since it depends on the workflow existing and passing
reliably first — protecting `main` on an unproven check would be premature.

**Rationale**: Satisfies the phase-sizing rule (independently revertible, one coherent slice
per phase) while front-loading the CI workflow so the pack is dogfooded on this repo as early
as possible, consistent with FR-012.

**Alternatives considered**: Shipping all five checks in one phase — rejected, fails the
phase-sizing rule's "one meaningfully testable slice" bar; the checks split cleanly by
priority and by which spec.md file section they extend, with no shared state that would make
splitting them artificial.
