# AI Code Review — 029 Unchecked git reads named state, phase 5 (guidance, replay evidence, digests)

**Reviewer**: fresh-context agent, Claude Sonnet 5.5 (claude-sonnet-5-5)
**Date**: 2026-10-16
**Branches**: `029-unchecked-git-reads-named-state`, phase commits `2f00c82` and `370a81d` (tip `370a81d`)
**Scope reviewed**: `git show --stat` and full diffs of both commits (`adoption/updating.md`, `docs/roadmap.md`, `docs/digests/adoption-digest.md`, `notes.md`, `tasks.md`); `scripts/enforcement-pack.ps1` and `scripts/territory-check.ps1` at HEAD (the quoted messages, lanes, refusals); plan.md (inventory, Amendments 1-3); tasks.md Phase 5; the 028 flow-down note; the phase 4 review; the replay JSON for all four histories.
**Feature contract**: documentation, replay evidence and digests only; no script logic; no constitution amendment; no gate or certification claim.

## Reviewer Provenance

- **Reviewer**: fresh-context agent, claude-sonnet-5-5 (Claude Sonnet 5.5)
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5), the session that produced the diff
- **Inputs provided**: both commit diffs; the two scripts at HEAD; plan, tasks and notes; the four `result-*.json` files. Ran in a detached worktree at `370a81d` (removed afterwards): `build-digests.ps1` (no drift, `git status` clean), `roadmap-claim-check.ps1` (OK), `doc-lint.ps1` (OK). Recomputed the replay totals from the JSON with a script. Did not run the full harness or `scope-check` on a named branch.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** No script changed and nothing claims the gate passed or certifies the phase. The replay numbers reproduce exactly from the raw JSON. One number in the adopter-facing note and the roadmap is wrong (F1) and should be fixed before merge.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Scope | The two commits touch 5 files: `adoption/updating.md`, `docs/roadmap.md`, `docs/digests/adoption-digest.md` (all in the Territory) and `specs/029-*/{notes,tasks}.md` (implicit `specs/NNN-name/**` entry, `scripts/scope-check.ps1:41`). No script is touched. notes.md records scope-check PASS on `2f00c82`; I did not re-run it. |
| Claims vs code | `GitReadUnreadable: <read> failed on '<branch>' (git exited <n>), so <consequence> - repair the repository (a damaged object, or fetch the full history: 'fetch-depth: 0' on actions/checkout)` is verbatim at `enforcement-pack.ps1:261`. The numbered/Lite/`-Advisory` split is at 260-264, and the once-per-read key (`Reader\|Key`) at 257-259. PhaseSizeWarning passes `-Advisory` (1383, 1390), Surface Exception date passes `-Advisory` (1066). `territory-check.ps1:102` and `:112` use `Stop-Refused` for the uncommitted diff and `ls-remote`; the open-branch reads are `Add-Ungraded` records. The note's quoted refusal wording is consistent. |
| Supersession | 028's limits (1) (territory-check's two unchecked reads) and (3) (the pack's other reads) are the ones the note names, per `updating.md:1327-1336`. 028's note is not edited. |
| Replay numbers | Recomputed from the JSON: fitforge 10/5 (1 numbered, 4 lite), flowboard 10/8 (4/4), expense 10/8 (3/5), kit 115/94 (31/63). Totals 145, 115, 39, 76, named-no-branch 30 (5+2+2+21). Outputs differing old vs new: 0 in all four; old vs instrumented: 0; exit codes changed: 0. Reads 93+331+154+13,457 = 14,035; largest run 1,173. Timings 27.5/24.9, 44.3/39.4, 31.7/32.3, 782.2/773.7 s. Kit exits 55 at 0 and 39 at 1, as written. Notes, flow-down note and roadmap agree with each other. |
| Overclaiming | The roadmap row says "shipped" qualified by "The owner's gate and the human review at merge are still to come", and the decisions entry repeats "'Shipped' here means built, reviewed and measured". This matches feature 028's row wording (status `shipped`, "Built, reviewed and measured; the owner's gate and the human review at merge are still to come"). Nothing says the gate passed. notes.md T030 says explicitly the phase is not AI-reviewed and the gate is not run. |
| Roadmap hygiene | GAP-035 row and the idea row (`shipped`, spec path, owner) are consistent; `roadmap-claim-check.ps1` OK. The decisions entry invents no number beyond those in plan/notes (but see F1). |
| Digests | Two new `<!-- digest: -->` lines match the two lines in `adoption-digest.md`; `build-digests.ps1` in a worktree: OK, 5 digests, 119 markers, no diff. Both lines say true things. |
| tasks.md | T027-T030 ticked. T027 backed by notes and JSON; T028 by the note; T029's "no LIMITS comment to fix" confirmed: `grep LIMITS` finds one hit in the two scripts, `enforcement-pack.ps1:427`, the merge-readiness heuristic, and none in `territory-check.ps1`; T030 backed by notes (harness count not re-run). |

## Findings

### F1 — "Seven reads have no reachable data state" is wrong; it is eleven — FOLLOW-UP
`adoption/updating.md` (flow-down note, limit 3, ~line 1387) and `docs/roadmap.md` (decisions-log entry, 029) say "seven reads ... (plan Amendments 1 to 3)". Amendment 1 names seven (G2a, G2b, G3, G4, G6, G12, G14a), Amendment 2 adds three (G8, G9, G10), Amendment 3 adds one (G13b): eleven by the plan. The parenthetical "they fail only if a prior read of the same object succeeded and then failed" also describes only Amendments 2 and 3; Amendment 1's reason is damaged commit objects landing in the no-base state. The count is a number an adopter would repeat. Fix both to eleven, or say "seven commit-object reads, three more injected reads and `ls-remote`". Notes.md carries the per-read facts correctly.

### F2 — "Fourteen graded reads" counts plan rows, not reads — MINOR
Plan inventory table G1..G14 has rows holding two reads (G2, G13, G14, and G3 and G9 compare two commands). "Fourteen" matches the plan's own phrase ("14 graded reads"), but the note and roadmap would be exact as "fourteen inventory rows". Low impact; the plan's wording is the source.

### F3 — The kit's merge count differs from 028's (113) and notes do not say why — MINOR
`git log --merges` gives 113 at `ea1d393` and 115 at HEAD; the replay's kit row is 115 (the two extra are merges after 028, the first replayed item is `docs/roadmap-gap-035-claim-029`). notes.md `specs/029-*/notes.md` (replay table) gives no one-line reconciliation. Add: "two merges since 028's 113".

### F4 — Replay limits are honest; one wording caveat — MINOR
The note states territory-check is not replayed and why, exit codes are mixed but identical, timings are one sample, and damaged repositories are shown only by fixtures. Sufficient. Caveat: "new (HEAD, e7ed935)" is the script version; the scripts are unchanged in phase 5, so correct. The instrumented copy also counted reads only in the pack (territory-check has none counted); stated.

### F5 — T029 asks for "merge evidence" in the roadmap row; none is possible yet — DOC DRIFT
tasks.md T029 says "GAP-035 shipped (owner, spec path, merge evidence)". The row has owner and spec path; merge evidence cannot exist before the merge, and the row says so. Consistent with 028's pre-merge wording; the owner should add the merge evidence at merge time, as for earlier features.

### F6 — notes.md heading joined to previous paragraph — MINOR
`specs/029-*/notes.md` lost its no-newline-at-EOF and `## Phase 5` follows the last bullet line with no blank line (diff hunk `@@ -320`). Renders correctly in most Markdown but is untidy.

## Test coverage observed

- `build-digests.ps1`, `roadmap-claim-check.ps1`, `doc-lint.ps1` in a detached worktree at `370a81d`: all OK, no drift.
- Replay totals recomputed from `result-{kit,fitforge,flowboard,expense}.json`: match every figure in notes, note and roadmap.
- Full harness (1744 passed on `2f00c82`) taken from notes.md, not re-run.
