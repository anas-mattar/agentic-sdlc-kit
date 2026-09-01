# Data Model: Flow-Efficiency Pack

No database or persisted schema — git branches and markdown fields are the only state.
This file defines the conceptual entities, their states, and the machine-readable
formats the scripts and enforcement pack depend on.

## Feature Claim

A feature claim is a remote branch; nothing else counts (team-workflow rule 3).

| Attribute | Source | Values |
|---|---|---|
| Number | branch name prefix `NNN-` | next free across local+remote branches and `specs/` dirs |
| Name | branch name slug | kebab-case, stable for branch lifetime |
| Visibility | remote branch existence | `team-visible` (pushed) / `local-only` (no remote configured — warned) |
| Liveness | age of last commit | `live` (< 14 days) / `stale — reclaimable` (≥ 14 days, adjustable) |

**State transitions**: unclaimed → claimed (branch pushed) → live ↔ stale → merged or
adopted-by-new-owner. A lost allocation race transitions back to unclaimed for that
number; the claimant renumbers before any other work.

## Pipeline State (per developer)

| State | Definition | May claim another feature? |
|---|---|---|
| `idle` | no open feature branch owned | yes (becomes `active`) |
| `active` | a feature with any phase not yet gate-green-committed, or review not yet requested | no |
| `awaiting-review` | all phases committed gate-green, branch pushed, human review formally requested | yes — one more (cap below) |
| `changes-requested` | reviewer returned change requests on the awaiting feature | no new claims; finish current phase of the second feature, then return to the first |

**Invariant (cap)**: at most one `awaiting-review` + one `active` feature per developer.
A third claim is number squatting under existing rule 3.

**Invariant (territory)**: the `active` feature's touched files are disjoint from the
`awaiting-review` feature's, or explicitly sequenced behind it in both plans.

## Gate Batch

| Attribute | Format | Rules |
|---|---|---|
| Declaration | `**Gate Batching**: none` or `**Gate Batching**: phases N-M` in plan.md | absent line ⇒ `none`; declared before the batch's first phase is implemented |
| Span | `N-M`, consecutive | `M - N + 1 ≤ 3`; phases must be consecutive |
| Eligibility | spec.md `Delivery Level` | `Lite`/`Standard` only; `Critical` + a batch ⇒ enforcement-pack FAIL |
| Per-phase obligations retained | — | commit, `git diff --stat` scope check, AI review, agent-run feedback gate |
| Certification | user-run gate at batch end | one exit code certifies the batch; failure localizes via per-phase commits |

## Territory Report (territory-check output)

| Field | Meaning |
|---|---|
| Branch | the other open remote `NNN-*` branch |
| Overlapping files | intersection of both branches' changed-vs-main file sets |
| Branch status | `live` / `stale — reclaimable` / `claimed, no work yet` |
| Exit code | `0` clean · `2` overlap found · `1` execution error |
