# AI Code Review — 003 Flow-Efficiency Pack, Phase 2 (claim + territory scripts)

**Reviewer**: Claude Code (claude-sonnet-5)
**Date**: 2026-09-01
**Branches**: agentic-sdlc-kit `003-flow-efficiency-pack` (tip `1697fdf`, phase 2 uncommitted at review time)
**Scope reviewed**: `scripts/claim-feature.ps1` (full, new), `scripts/territory-check.ps1`
(full, new), `docs/sdlc/branch-strategy.md` (Number Allocation edit in context),
`docs/sdlc/team-workflow.md` (rules 2 and 5 edits in context), `scripts/doc-lint.ps1`
(required-paths edit), `.specify/scripts/powershell/create-new-feature.ps1` (full — the
delegation target), cross-read against `contracts/claim-feature-cli.md` and
`contracts/territory-check-cli.md`
**Feature contract**: automation of existing rituals only — no rule changed; no new
packages; scripts follow existing `scripts/*.ps1` conventions; delegation to the stock
Spec Kit script rather than reimplementation.

## Verdict

**APPROVE** — two new scripts automate the claim and territory rituals exactly as the
contracts specify, verified by 15/15 deterministic scenario assertions in scratch clones
(including a real race simulation via a remote hook) plus a live read-only smoke test on
this repository. The doc amendments name the scripts and keep the manual recipes as
fallback, changing no law. Residual risk sits in untested git edge environments
(detached HEAD, shallow clones), none of which the kit's workflow produces.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-003: scenario S1 (claim → branch on remote, spec.md created), S2 (remote-ahead ledger allocates past a branch the local clone has never seen). FR-004: S3 (rival injected mid-push → losing claim withdrawn from the remote, renumbered 004→005, spec dir renamed, `RENUMBERED_FROM:"004"` in output), S4 (no remote → local claim, `PUSHED:false`, "NOT team-visible" warning observed). FR-005: S6 (overlap → exit 2 naming branch + file; disjoint → exit 0 CLEAN; JSON shape matches contract). FR-006: report text prints the rule-5 "sequenced, not forbidden" reminder (read in source; human-mode output observed in S7 run). FR-010: both scripts in doc-lint required paths — doc-lint scanned and passed. |
| Visual-reference match | N/A — no visual references. |
| Feature contract held | No packages added; both scripts use git CLI only; claim delegates to `create-new-feature.ps1 -Number` (verified the parameter bypasses local auto-allocation at its lines 204–213); doc edits add the command blocks and keep the manual recipes verbatim. |
| Constitution / domain invariants | No law changed: team-workflow rules 2 and 5 retain their original numbered recipes; branch-strategy retains its 3-step recipe. Scripts never force-push and never touch `main` (claim's only remote deletion is its own just-pushed losing branch, S3). |
| Security (authn/authz, secrets, sensitive logging) | No credentials handled; no secrets read or logged; push uses the caller's existing git auth. |
| Scope guard (`git diff --stat` — only intended files) | 4 modified + 2 new files, exactly the plan's Phase 2 list; user reviewed. |
| Rollback safety | Fully revertible: deleting the two scripts + reverting the three edits restores the manual-only state; nothing else invokes the scripts. |

## Findings

### F1 — Simultaneous mutual renumber is possible in a rare double race — MINOR

If two developers hit the same number race in the same seconds, both post-push checks can
see the other as the rival and both may withdraw and renumber (each ending on a distinct
higher number). Claims still end up valid and collision-free — the cost is one wasted
number, not a broken ledger.
*Action: none — outcome is safe; documented here for awareness.*

### F2 — Territory check includes tracked uncommitted changes only for the current branch — ACCEPTED

When invoked with `-Branch <other>`, only committed diffs are compared (the other
branch's working tree is on another machine). This matches the contract and D3
("committed diffs are the only claim that exists in git").
*Action: none — per contract.*

### F3 — Stale-only overlap exits 0 — CONFIRM (resolved in-phase)

D3/data-model say stale claims are "flagged, not treated as live conflict"; the
implementation returns exit 0 with a reclaim hint when only stale branches overlap
(scenario S7). This is a judgment call encoded in research and verified by test.
*Action: none — matches the approved research decision; flagging for the feature-level
human reviewer's attention.*

## Constitution re-check (post-implementation)

PASS. I (artifacts approved before implementation); II (docs and scripts agree — the
scripts automate the documented recipes, both re-read after editing); IV (existing
script conventions; delegation not reimplementation); V N/A; VI (no security surface
beyond caller's own git auth); VII (no external integrations); VIII (15 deterministic
scenario assertions, all passing — see below); IX (feature-level human review pending at
merge); X (single phase, independently revertible, user-run gate confirmed EXIT: 0).

## Test coverage observed

Scratch-clone harness (session scratchpad, bare remote + two clones + solo repo;
never the real remote), 15 assertions across quickstart Phase 2 scenarios 1–7:
happy path (3), remote-ahead allocation (1), race recovery via post-receive rival
injection (3), no-remote fallback (2), dirty-tree and not-on-main refusals (2), overlap
exit 2 / disjoint CLEAN (2), stale flagging + claimed-no-work handling (2). Plus live
smoke test on `003-flow-efficiency-pack`: CLEAN, exit 0. doc-lint: exit 0, 30 docs.

## Residual risk

Low, concentrated in F1's rare double-race (safe outcome) and unusual git states the
workflow never produces (detached HEAD, shallow clone). Nothing blocks merge.
