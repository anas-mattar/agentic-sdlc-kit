# AI Code Review — 011 Roadmap-claim visibility check

**Reviewer**: fresh-context agent — claude-fable-5
**Date**: 2026-09-09
**Branches**: agentic-sdlc-kit `011-roadmap-claim-check` (tip `e154ea8`)
**Scope reviewed**: phase 1 commit `e154ea8` in full (`git show`); `scripts/roadmap-claim-check.ps1`
(all 128 lines), `scripts/ritual-checks.ps1` (full file post-change), `scripts/claim-feature.ps1`
(output section + claim regex at lines 50/63), `docs/roadmap.md` row change; context law:
mini-spec `specs/011-roadmap-claim-check/spec.md`, constitution X (Micro lane, 0.6.0),
`kit-manifest.json` (flow-down classes), `.github/workflows/ritual-checks.yml`,
`scripts/enforcement-pack.ps1` (ReviewProvenance/MicroLane interplay)
**Feature contract**: Micro lane — one phase, declared Territory of 4 files, ≤400 changed
lines; new check is read-only (never mutates git state or files); n/a instead of synthetic
failure with no remote / unreachable ledger / no Status-bearing roadmap table; no new
packages; `-Json` output of claim-feature unchanged

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-fable-5
- **Implementer**: claude-fable-5 (interactive Claude Code session)
- **Inputs provided**: phase 1 diff (e154ea8), specs/011-roadmap-claim-check/spec.md, the four territory files, review template, review-process/constitution law
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups** — the phase adds a `roadmap-claims` member to ritual-checks:
every `NNN-*` branch on origin (the claim ledger, same regex `claim-feature.ps1` uses at
its line 50, with the same datestamp exclusion) must have a roadmap row whose Status is
not `idea`, with an own-number exemption so a fresh claim's first CI run cannot deadlock,
and deliberate n/a states mirroring verify-kit. All six acceptance checks verified by
running the scripts (live tree + a scratch sandbox exercising fail, exempt, empty-ledger,
no-table, no-file, unreachable, and no-remote paths). The wrapper change is a faithful
generalization of the digests n/a capture and preserves its behavior exactly; the
claim-feature reminder is inside the non-`-Json` else branch. Micro bounds hold (4
territory files, 153 changed lines, one phase commit; scope-check PASS observed). Residual
risk sits in flow-down: adopted projects receive the script via the manifest's verbatim
`scripts/*.ps1` glob, and one with a kit-style Status-bearing roadmap plus stale `NNN-*`
branches will start failing CI after the next kit update — intended enforcement, but worth
a sentence at flow-down time (F6).

## What was verified (evidence)

> Every claim needs evidence — a file/symbol read, a test observed, a query run. A row
> without evidence is an assumption, not a verification.

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | All 6 acceptance checks executed. (1) `pwsh -File scripts/ritual-checks.ps1 -Branch 011-roadmap-claim-check` → member printed `roadmap-claims: OK (7 claim(s) visible with non-idea rows, own claim 011 exempt)`, verdict block lists `roadmap-claims OK`, `RESULT OK`, exit 0. (2) Sandbox root with a doctored roadmap: claim with an `idea` row and claims with no row each failed with a message naming the branch and the flip remedy; `FAIL (5 of 6 claim(s) …)`, exit 1. (3) On this branch (own number 011, tip pushed to origin) the direct run exits 0 with `own claim 011 exempt`; prefix test `-Branch 0021-something` did NOT exempt claim `002-*` (still 5 of 6 failed) — `^$ownNumber-` requires the dash, so `011` never exempts `0112-x` and vice versa. (4) Sandbox with origin removed → `n/a (no origin remote …)` exit 0; origin set to a nonexistent path → `n/a (origin unreachable …)` exit 0. (5) The `NEXT: flip the roadmap row…` Write-Host sits in the `else` branch of `if ($Json)` in claim-feature.ps1 (line 166) — `-Json` emits only the ConvertTo-Json object, unchanged. (6) `docs/roadmap.md` GAP-017 row flipped to `in progress | anas.m | specs/011-roadmap-claim-check/` in the diff; `roadmap-claim-check.ps1 -Branch main` on this tree → `OK (8 claim(s) visible with non-idea rows)`, exit 0. |
| Visual-reference match (where references exist): Visual Compliance Loop deviation table attached, empty or user-approved (`docs/sdlc/review-process.md`) | N/A — no UI, no `screenshots/` (eligibility box checked in the mini-spec, consistent with the diff). |
| Feature contract held (no unapproved table/migration/permission/package) | Diff touches exactly the 4 declared territory files; no packages, no schema, no workflow change needed (`.github/workflows/ritual-checks.yml` already routes through the wrapper and passes `-Branch` from `head_ref \|\| ref_name`, so the own-number exemption works on detached-HEAD CI checkouts). New script is read-only: only `git remote get-url`, `git ls-remote`, `git rev-parse`, `Get-Content`. |
| Constitution / domain invariants | Constitution X Micro lane: one phase commit (`e154ea8` is the only commit carrying `phase 1`), Territory 4 ≤ 5 files (feature's own `specs/011-*/**` excluded), 144 insertions + 9 deletions = 153 ≤ 400 changed lines; ci-held declared in the mini-spec (legal for Micro per 0.6.0); eligibility boxes match the diff. n/a-not-failure mirrors verify-kit precedent (constitution-adjacent 007 US3 semantics). |
| Security (authn/authz, secrets, sensitive logging) | No secrets, no network beyond `git ls-remote origin`. Claim names interpolated into `-like` patterns come from git refnames, which cannot contain the wildcard metacharacters `*`, `?`, `[` (git check-ref-format), so no pattern injection (see F1 for the exotic backtick corner). CI workflow already passes the branch via env var, never shell-interpolated. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | Wrapper run printed `scope-check: PASS phase 1 commit e154ea8 (4 file(s), Micro territory from spec.md)`. `git show --stat e154ea8`: 4 files, matching the declared Territory exactly. |
| Rollback safety (phase reverts cleanly; schema additive?) | Single commit; one new file + three additive edits; `git revert e154ea8` restores the prior tree including the roadmap row. No schema. Matches the mini-spec's Rollback section. |

## Findings

> One `### F<n> — <title> — <status>` block per finding.

### F1 — Claim regex admits slash-bearing sub-branches — MINOR

`refs/heads/(\d{3,}-\S+)$` in `scripts/roadmap-claim-check.ps1` (ledger loop): `\S` matches
`/`, so a branch `011-foo/wip` would be treated as claim `011-foo/wip` and demand a roadmap
row containing that exact string — a false failure if anyone pushes a sub-branch under a
claim. This is, however, byte-identical to the regex `claim-feature.ps1` uses (line 50),
which the mini-spec names as the ledger definition, and branch-strategy law does not
sanction sub-branches under claims. (Related exotic corner: a refname containing a backtick
would be mis-escaped inside the `-like` wildcard pattern; git allows backticks in refnames
but nothing in this kit produces one.)
*Action: none — consistent with the ledger definition by design; revisit only if sub-branch
workflows ever become sanctioned.*

### F2 — Substring row matching could mark a claim visible via a superstring — MINOR

`$_.Text -like "*$claim*"` matches any row merely containing the claim name, so a row for a
hypothetical `011-roadmap-claim-check-v2` would also satisfy claim `011-roadmap-claim-check`.
In practice `claim-feature.ps1` allocates unique numbers (Get-NextFreeNumber), so two live
claims cannot share a number, and a row naming a superstring of a claim would be
extraordinary. Verified the live tree matches each of the 8 claims to its own row.
*Action: none — number uniqueness makes the collision unrealizable under the kit's own
claim ritual.*

### F3 — 'Status' header match is ordinal case-sensitive — MINOR

`[array]::IndexOf($cells, 'Status')` is case-sensitive: a roadmap whose header reads
`status` or `STATUS` yields the `n/a (no table with a Status column)` verdict rather than
being checked. That errs on the lenient side, which is exactly the mini-spec's stated
posture for adopter-authored roadmaps ("never a synthetic failure"), and the kit's own
roadmap uses `Status`. Verified empirically: a sandbox table with a `State` column reported
n/a, exit 0.
*Action: none — leniency is the declared design; adopters wanting the check simply use a
`Status` header.*

### F4 — Empty Status cell reported with the "still reads 'idea'" message — MINOR

A matched row whose Status cell is empty (or a row shorter than the Status index) fails via
`$_.Status -and $_.Status -ne 'idea'` and is reported as "its roadmap row still reads
'idea'" — slightly inaccurate wording for a blank cell, though failing is correct
(fail-closed on a malformed row) and the remedy line is right. Note also `-ne` is
case-insensitive, so `Idea` counts as idea — the strict, correct direction.
*Action: none — behavior correct; wording nit only, not worth reopening a Micro phase.*

### F5 — The claim-time roadmap-flip ritual lives only in script messages, not in law docs — ACCEPTED

`docs/sdlc/branch-strategy.md` and `docs/sdlc/flow.md` do not mention the now-mandatory
main-side roadmap flip at claim time (grep for "roadmap" in docs/sdlc/ finds nothing); the
rule is taught by claim-feature's `NEXT:` line, the check's failure message, and the
script's comment header. The mini-spec explicitly designed this ("the rule teaches itself
at the moment it fires"), and adding a law doc would have grown the Micro territory.
*Action: optional post-merge docs commit adding one line to branch-strategy.md's claim
ritual; acceptable to defer — the check itself is the enforcement.*

### F6 — Flow-down behavior change is unannounced — MINOR

`kit-manifest.json` ships `scripts/*.ps1` verbatim, so `roadmap-claim-check.ps1` and the
new ritual-checks member flow to adopted projects automatically (no manifest edit needed —
verified the glob covers it, and `docs/roadmap.md` itself is NOT in the manifest, so
adopter roadmaps are untouched). An adopted project with no roadmap, or a roadmap without a
`Status` table, gets n/a — safe. But one with a kit-style Status table AND in-flight
`NNN-*` origin branches whose rows are missing/`idea` will start failing CI on the first
post-update push. That is the intended enforcement, yet `adoption/updating.md` carries no
note about it.
*Action: owner mentions the new member (and its remedy) in the next flow-down to
expense-tracker/flowboard; consider a one-line note in updating.md then — outside this
Micro territory now.*

## Constitution re-check (post-implementation)

PASS. Principle X (Micro lane): exactly one phase commit carrying the phase token; declared
Territory of 4 files honored byte-for-byte (scope-check PASS on `e154ea8`); 153 changed
lines ≤ 400; all five eligibility boxes truthful against the diff (no schema, no packages,
no architecture change, no domain-invariant surface, no UI); no Gate Batching declaration;
ci-held certification declared in the mini-spec, which 0.6.0 X permits for Micro. Principle
I (specification-first, Micro arm): approved mini-spec (`a9ddeb7`) precedes the phase
commit. n/a-not-failure semantics follow the verify-kit precedent the spec cites.
Verification layers untouched: the new member joins the same wrapper CI already runs, and
the wrapper's exit-code contract (exit 0 iff every member exits 0, never short-circuiting)
is preserved — verified by reading the generalized `$naCapableMembers` loop against the
pre-change digests-only branch: identical capture, re-echo, `$LASTEXITCODE` handling, and
verdict-line substitution, now keyed by member name.

## Test coverage observed

No test suite exists in this kit (scripts are self-verdicting); verification is by
execution. Observed: (a) live run on this branch — OK with own-claim exemption, 7 checked;
(b) live run `-Branch main` — OK, 8 checked; (c) full `ritual-checks.ps1` wrapper — all
members OK, digests member output unchanged (`digests: OK (5 digest(s) fresh, 68
marker(s))`), `RESULT OK`, exit 0; (d) sandbox fail path — idea-row and missing-row
messages each name the branch and the remedy, exit 1 with correct failed/checked counts;
(e) own-number prefix tests — `0021-x` does not exempt `002-*`, `002-enforcement-pack`
exempts exactly its own claim (4 of 5 vs 5 of 6); (f) all four n/a states (no remote,
unreachable remote, no roadmap.md, no Status table) — correct message, exit 0; (g) empty
ledger (bare remote with no branches) — `OK (no NNN-* claims on origin)`, exit 0; (h)
escaped-pipe cell (`\|` inside a cell) parsed as content, Status column read correctly
(the GAP-015 shielding in Get-Cells works); (i) datestamped `\d{8}-\d{6}-` branches
excluded by the same guard claim-feature uses.

## Residual risk

Concentrated in flow-down (F6): the check activates silently in adopted projects at the
next kit update, and a project with stale claims will see a new red CI with a
self-explanatory remedy — low harm, but the owner should say one sentence about it when
flowing down. F5's undocumented ritual is mitigated by the three self-teaching surfaces and
can be closed with a one-line docs commit any time. F1–F4 are corner-case notes with no
realizable path under the kit's own claim ritual. Nothing blocks merge; under ci-held, the
owner's approval on the evidence triplet (CI run URL + green conclusion + `e154ea8`)
remains the certification step.

## Finding dispositions *(implementer — appended per docs/sdlc/review-process.md step 4)*

- **F1 (claim regex admits slash-bearing sub-branches)** — rejected-why: deliberate parity
  with `claim-feature.ps1`'s ledger regex; the two must agree on what a claim is, and
  diverging here would be the actual bug.
- **F2 (substring row match vs superstring claim)** — rejected-why: unrealizable while
  number allocation is unique (`claim-feature.ps1` allocates across local + remote +
  specs/); a duplicate number is itself a defect the claim ritual prevents.
- **F3 ('Status' header match is case-sensitive)** — rejected-why: the lenient direction —
  a non-kit-shaped roadmap degrades to n/a, never to a false failure; matches the
  declared adopted-project posture in the mini-spec.
- **F4 (empty Status cell wording)** — rejected-why: fail-closed is the correct behavior;
  the remedy line is identical either way.
- **F5 (flip ritual absent from branching law docs)** — deferred-where: one-line addition
  to `docs/sdlc/branch-strategy.md` (Number Allocation) as a Lite docs follow-up — kept
  out of this phase deliberately, since editing a branching-pack member forces a digest
  regeneration and would widen the Micro territory.
- **F6 (flow-down behavior change unannounced)** — deferred-where: to the next flow-down
  session — announce the new `roadmap-claims` member when updating the two adopted
  projects; an adopted project with kit-style Status rows and stale `NNN-*` branches will
  newly fail CI, which is the intended teaching moment, but it must not arrive unexplained.
