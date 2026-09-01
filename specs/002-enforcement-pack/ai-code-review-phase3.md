# AI Code Review — 002 Enforcement Pack (Phase 3: Merge-Gate Wiring)

**Reviewer**: Claude Code (Sonnet 5)
**Date**: 2026-09-01
**Branches**: `agentic-sdlc-kit` `002-enforcement-pack` (commits `bdfc250`, `43567a2`, `0399b71`)
**Scope reviewed**: `.github/PULL_REQUEST_TEMPLATE.md` (new), `docs/sdlc/branch-protection.md`
(new), plus the *live* GitHub repository state (branch protection rule on `main`, this
feature's own PR/CI runs, one out-of-scope `fix/` PR triggered by verification)
**Feature contract**: PR template + recipe doc only; the actual branch-protection
configuration is repo administration performed *following* the recipe, not code shipped by
this feature.

## Verdict

**APPROVE with follow-ups** — FR-009/FR-010 are implemented and the mechanism is
live-verified end-to-end (a failing PR was genuinely blocked from merge on this repository).
Two follow-ups are required **after** this feature merges (not before): re-tighten branch
protection to require `enforcement-pack` again, and verify SC-007 (PR template
auto-population) against a fresh PR once the template file actually exists on `main`.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-009: `.github/PULL_REQUEST_TEMPLATE.md` embeds `human-pr-review-template.md`'s checklist verbatim plus the `**Gate exit code**` field; FR-010: `docs/sdlc/branch-protection.md` documents both the web-UI steps and a `gh api` recipe |
| Feature contract held | `git diff --stat`: 2 new files, both under `.github/` and `docs/sdlc/` |
| Constitution / domain invariants | N/A |
| Security | Branch-protection application used the existing authenticated `gh` session (`anas-mattar`, repo-scoped token); no secret introduced into any tracked file |
| Scope guard | Matches plan.md's Phase 3 file list |
| Rollback safety | Two new docs; reverts cleanly. The *live* branch-protection setting is not code and does not revert with `git revert` — see Residual risk |

Live verification performed (not a fixture — this repository's actual GitHub state):

1. Pushed `002-enforcement-pack`; confirmed both `doc-lint` and `enforcement-pack` workflows
   ran successfully (`gh run watch`).
2. Applied `docs/sdlc/branch-protection.md`'s recipe to `main` (`gh api`, JSON-file form —
   the originally-documented `-f`/`-F` flag form was rejected by GitHub as an invalid
   type; fixed in the doc, see F1).
3. Opened a throwaway PR from a branch deliberately missing `plan.md`/`tasks.md`. Confirmed
   `mergeStateStatus: BLOCKED` and a failing required check — **SC-006 confirmed live**.
   Closed the PR and deleted the branch without merging.
4. Attempted to verify SC-007 (PR template auto-population) but found `.github/
   PULL_REQUEST_TEMPLATE.md` returns 404 on `main` — GitHub only reads the template from the
   **base** branch, and it only exists on this unmerged feature branch. Not a defect; see F3.

## Findings

### F1 — `branch-protection.md`'s original `gh api` recipe was wrong, fixed after live testing — DOC DRIFT (found and fixed in this phase)

The `-f required_status_checks[strict]=true` flag form does not express a nested
boolean/array correctly; GitHub rejected it (`"strict" ... is not a boolean`). Replaced with
a JSON-input-file form, confirmed working live (see commit `43567a2`).
*Action: none further — already fixed and confirmed against the real API.*

### F2 — A required check with no run on the target branch permanently blocks merge; discovered mid-verification — BLOCKING, resolved via a separate out-of-scope fix

Applying the full protection rule (`doc-lint` + `enforcement-pack`) before
`enforcement-pack.yml` existed on `main` meant *any* branch created before this feature
merges (including an unrelated `fix/` branch created during this same verification session)
has no `enforcement-pack` run at all, so GitHub reports the required check as permanently
unmet — even `--admin` cannot override it with `enforce_admins: true`. This also
transitively blocked `002-enforcement-pack`'s own eventual merge for the same reason
(no prior run existed on `main` before this feature introduces the workflow). Resolved by
temporarily relaxing the required-checks list to `doc-lint` only (user-approved, since the
change touches live repo administration), letting the (separately-necessary — see F4) `fix/
track-review-artifacts` PR merge, then confirming `002-enforcement-pack` itself now has a
clean run against updated `main`. **`docs/sdlc/branch-protection.md`'s existing
"Prerequisite" note already states the correct order** ("the workflow must have run at least
once... before it can be required") — this finding is that the order was violated during
this feature's own bootstrap, not a gap in the documentation.
*Action (post-merge, required): once this PR merges, re-apply the full protection rule
(`doc-lint` + `enforcement-pack`) — the workflow will then have a real run on `main` and the
prerequisite is satisfied. Tracked as this review's primary follow-up.*

### F3 — SC-007 (PR template auto-population) could not be verified pre-merge — ACCEPTED, deferred

GitHub reads `.github/PULL_REQUEST_TEMPLATE.md` from the PR's *base* branch at PR-creation
time, not the head branch. Since the template only exists on `002-enforcement-pack` so far,
no PR opened before this feature merges can demonstrate SC-007. This is expected
bootstrapping (the same class of chicken-and-egg as F2), not a defect in the template file
itself (confirmed present, correctly named and located, at the exact path GitHub's
convention requires).
*Action (post-merge, required): open one real PR against `main` after this feature merges
and confirm its description is pre-populated from the template — this is SC-007's actual
acceptance test, deferred by necessity rather than skipped.*

### F4 — Verification surfaced a real, pre-existing bug unrelated to this feature: `review/` was never committed — OUT OF SCOPE, fixed separately

`doc-lint` failed in CI on `main` itself (not on any 002 branch) because
`constitution.md`'s SYNC IMPACT REPORT (added by the already-merged `001-delivery-core-
amendment`) cites `review/out/DECISION.md`, but `review/` was only ever present in the local
working tree, never committed. This is a defect in `001`'s merged state, not in `002`'s
scope — `002-enforcement-pack`'s job is to *catch* this class of drift going forward, and it
did: this is exactly the kind of gap that a doc-lint CI gate (which pre-dates this feature,
`.github/workflows/doc-lint.yml`) exists to catch, and it never had the chance to run against
`main` in CI until this feature's live-verification pushed something and forced the check to
actually execute. Fixed via a separate, user-approved `fix/track-review-artifacts` branch and
PR (#2), merged to `main` ahead of this feature, following the Lite-lane rules in
`docs/sdlc/branch-strategy.md` — not folded into `002-enforcement-pack`'s own commits, since
it is unrelated to the enforcement pack's actual scope.
*Action: none further within this feature — already resolved on `main`, and this feature's
branch has since merged `main` back in (commit `0399b71`) so both are consistent.*

## Constitution re-check (post-implementation)

PASS. No new principle engaged. Principle IX (Human Review) — this document exists
precisely so the human reviewer sees the full live-administration story (F1–F4) rather than
just the two new files' diff, since a chunk of this phase's real work was operational
(branch protection, PR lifecycle) rather than code.

## Test coverage observed

No automated tests (governance tooling, per Phase 1/2's determination). Coverage is the live
verification steps enumerated above — the only way to test "does GitHub actually block a bad
merge" is to make GitHub actually try.

## Residual risk

**Medium until the F2 follow-up lands.** `main`'s branch protection currently requires only
`doc-lint` (temporarily relaxed) — `enforcement-pack` is implemented, CI-green, and would
correctly block a bad merge if required, but is **not currently required** on `main`. A
merge to `main` between now and the F2 follow-up would not be blocked by a failing
`enforcement-pack` check. This must be closed out immediately after this feature's own
merge — recommend doing so in the same sitting as the merge, not deferred further.
