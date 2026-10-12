# AI Code Review — 021 Load-bearing Developer Roster, phase 3 (the claim ledger)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-12
**Branches**: kit repository `021-developer-roster` (phase 3 commit `660cccb`, parent `062fbbe`)
**Scope reviewed**: `git diff 062fbbe 660cccb` in full: `scripts/roadmap-claim-check.ps1`, the `$ungradedCapableMembers` edit in `scripts/ritual-checks.ps1`,
`tests/enforcement/rules.json` (CLAIM-009..013, RIT-008, the CLAIM-008 anchor change) and `emission-idioms.json` (widened printed idiom, FAIL roll-up
not-a-rule anchor), the 27 new fixtures (`CLAIM-009..013`, `RIT-008`), `specs/021-developer-roster/notes.md` and `tasks.md`; against `spec.md` FR-005, FR-007,
US2, US4, SC-001, SC-002, `plan.md` D3, D4, D5, D7, D8, D9 and Risks, and the reader `Get-DeveloperMode` in `scripts/adoption-lib.ps1`.
**Feature contract**: no new script or package; roster read only through the one reader; with no usable roster the output and verdicts are byte-identical;
UNGRADED is a verdict, never an exit code; read-only on the working tree; territory is `scripts/roadmap-claim-check.ps1`, `scripts/ritual-checks.ps1`, `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-sonnet-5-5 (separate session that produced the phase 3 commit `660cccb`)
- **Inputs provided**: phase 3 diff (`062fbbe` to `660cccb`), CLAUDE.md, review-process.md, the review template, spec.md, plan.md, tasks.md, notes.md, the phase 2 and phase 1 round 2 reviews as shape precedent
- **Attestation**: This reviewer did not produce the diff under review.
- **Prior involvement**: none. Fresh context; notes.md was read as a claim and checked.
- **Commands run**: `git diff --stat` and `git diff 062fbbe 660cccb`; `pwsh -File tests/enforcement/Run-Tests.ps1 -Case CLAIM-` and `-Case RIT-` on the working
  tree (660cccb); a detached worktree of `062fbbe` outside the repository with the new fixtures, `rules.json` and `emission-idioms.json` copied in, run with
  `-Case CLAIM-` and `-Case RIT-008`; two hand-built scratch repositories (origin a bare clone) run with the parent's and the new `roadmap-claim-check.ps1`
  (padded/case-different Owner, `In Progress`, several names in one cell, decoration, a claim number inside another row's text, a table with no Owner column,
  an Owner not on the roster holding two claims, tip commits dated 14 days minus and plus two minutes); the full harness in a detached worktree of `660cccb`
  (930 s); `pwsh -File scripts/ritual-checks.ps1`; `pwsh -File scripts/scope-check.ps1`. Worktrees and scratch repositories were removed; `git worktree list`
  shows only the main checkout and `git status` is clean apart from this file.

## Verdict

**APPROVE with follow-ups.** The script does what FR-005, FR-007 and D4/D7/D8 specify: with a usable roster each non-own, non-`idea` row's real Owner must be on
the roster (trimmed, case-insensitive), per-Owner active claims are counted, more than two fails, exactly two is a note with exit 0, dates are read only for an
Owner with two or more candidates, an unreadable date prints the reason and the verdict becomes `UNGRADED` with exit 0, and with no usable roster nothing new is
printed and every pre-existing fixture is untouched and passes. Full harness, `ritual-checks` and `scope-check` pass. Two things should be fixed or recorded
before the phase is called done: the Owner reading and the count both attribute a claim to every row whose *text* contains its name, so a row that merely
mentions another claim gives its Owner that claim (F1); and the D8 wiring change is behaviourally a no-op, so `RIT-008` passes on the parent and the notes' claim
that it guards the name is wrong (F2). Neither blocks. Certification of the gate is the owner's; nothing here claims it passed.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match, FR-005 | Diff read. Owner graded only for non-own claims, Status present and not `idea`, Owner cell non-empty and not `—`; failure names claim, Owner and roster names. `ADA ` (padded, upper case) against roster `ada` passes in a scratch run; `-notcontains` is case-insensitive and the cell is trimmed. Blank and `—` Owners are not graded (fixtures `pass-blank-owner`, `pass-dash-owner`). |
| Spec match, FR-007 | `specified` / `in progress` only, compared with `-in` (case-insensitive): `In Progress` counted in a scratch run. Per-Owner key is the lower-cased trimmed Owner. More than two fails, two is a note, exit 0. Boundary: a tip dated 14 days minus 120 s counted, 14 days plus 120 s not counted (`<=` the 14-day window); the boundary has no fixture (F4). |
| Own claim | `$ownNumber` exempt in the new loop, before both the Owner and the count; `pass-own-claim` and `pass-own-claim-not-counted` assert it. |
| Dates only where they matter | `if ($entry.Claims.Count -lt 2) { continue }` precedes every `git log`; `pass-single-claim-reads-no-date` puts a corrupt tip on a lone claim and gets a clean pass. |
| `$LASTEXITCODE` after substitution | `"$(git log ...)".Trim()` then `$LASTEXITCODE -ne 0 -or $ct -notmatch '^\d+$'`: the native exit code set inside the subexpression is the one read in the same scope; the fetch is followed by a second `git log` whose code is then the one tested. `CLAIM-013/fail` (corrupt tip, fetch from a self origin cannot supply it) reaches `UNGRADED` through this path. |
| UNGRADED and exit codes | UNGRADED line then `exit 0`; findings `exit 1`; the note is a `Write-Host` and does not move the exit code (`CLAIM-012/fail` expects exit 0). If another finding exists the run fails (exit 1) and the not-graded lines are still printed above the FAIL line; acceptable. |
| Byte-identity, SC-001 | The diff modifies no pre-existing fixture file (all 87 changed paths are new fixtures, `rules.json`, `emission-idioms.json`, the two scripts, spec files). `CLAIM-001..008` pass unchanged against the new script (117 passed). On the parent, with the new fixtures copied in, the existing eight pairs and every `pass-no-roster` / `pass-empty-roster` / `pass-idea-row` case pass, and the failures are exactly the new-behaviour cases. In a scratch no-roster run the parent's and the new script's output (OK line) is identical; the OK line gains `, Owners and claim counts graded against the declared roster` only when `$graded -and $ownerColumnSeen`; the FAIL roll-up keeps its words when every finding is a visibility finding. A malformed or unreadable `kit-adoption.json` returns an empty `Roster` from the reader (no throw), so such a project stays on the old output. |
| Reader | The roster is read only through `Get-DeveloperMode` (dot-sourced if present; if `adoption-lib.ps1` is absent the roster is empty and the script behaves as the parent). The dot-source defines functions only; no side effects. |
| Fixtures fail on the parent | Worktree of `062fbbe` with the new fixtures and rule files copied in: `-Case CLAIM-` **91 passed, 26 failed**: 22 case assertions across `CLAIM-009` (`fail` x2, `pass`, `pass-blank-owner`, `pass-case-differs`, `pass-dash-owner`, `pass-object-roster`, `pass-own-claim`), `CLAIM-010`, `CLAIM-011`, `CLAIM-012`, `CLAIM-013`, plus 4 inventory/anchor tests (the new anchors do not exist in the parent). **`RIT-008` does not fail on the parent**: both its cases pass there (F2). |
| Fixtures pass now | `-Case CLAIM-` **117 passed, 0 failed**; `-Case RIT-` **129 passed, 0 failed** (working tree, 660cccb). |
| Full harness | Detached worktree of `660cccb`: **1309 passed, 0 failed, 0 skipped, `enforcement-tests: OK`** (930 s); `coverage: roadmap-claim-check.ps1 14 of 14 site(s) fixtured`. 1309 = 1255 + 54 (27 cases x 2 assertions), as notes.md says. |
| rules.json / idioms | `CLAIM-008` anchor moved to `roadmap-claims: OK ($checked claim(s) visible with non-idea rows`, needed because the UNGRADED line shares the shorter phrase; `CLAIM-013` declares `siteCount: 2` (the detail line and the verdict line); the FAIL roll-up is declared not-a-rule with a reason naming CLAIM-009/011. The coverage tests accept all of it. |
| notes.md | Case counts (10/3/7/2/3/2 = 27), assertion count 54, results table (117, 129, 1309, 14 of 14, RESULT OK) all match what I observed. Two statements are inexact: "every case of the new behaviour fails [on the parent]" (RIT-008 does not) and "`RIT-008` fails if the name is dropped" (F2). |
| Scope | `git diff --stat`: `scripts/roadmap-claim-check.ps1`, `scripts/ritual-checks.ps1`, `tests/**`, `specs/021-developer-roster/notes.md`, `tasks.md`. `pwsh -File scripts/scope-check.ps1`: **`scope-check: PASS phase 3 commit 660cccb (87 file(s))`**. |
| Ritual | `pwsh -File scripts/ritual-checks.ps1`: doc-lint, enforcement-pack, scope-check, digests, roadmap-claims OK; scope-repos and verify-kit n/a; **`RESULT OK`**. |
| Read-only | The script writes nothing; `git fetch --quiet origin <branch>` updates remote-tracking refs only (D7). Working tree unchanged after every scratch run. |
| Security | Owner cells and branch names appear only in output strings; the branch name goes to `git fetch` as an argument (a `-`-leading name is excluded by the `^\d{3,}-` claim pattern). No secrets. |
| Rollback safety | One commit, no data; a revert returns the parent behaviour. |

## Findings

### F1 — A claim is attributed to every row whose text contains its name, so a mention in another row moves an Owner's count and verdict — MEDIUM (follow-up)

The Owner and count readings select rows with `$_.Text -like "*$claim*"` (the same selector the visibility reading already used). With the new readings this has
consequences it did not have before. Scratch roadmap: row `015-eee` (Owner `grace`) has the text ``specs/015-eee/ depends on 011-aaa``; row `011-aaa` has Owner
`ada`. Result: `grace` is reported as holding `011-aaa` and `015-eee` (a note for two claims), and `011-aaa` is counted for both `ada` and `grace`. A third
mention would turn a lawful two into a WIP failure for an Owner who holds one claim, and a row that mentions a claim of someone not on the roster would fail
the roster check for the wrong claim. Likewise `-like` wildcard characters in a branch name and a claim whose name is a prefix of another (`011-a` against
`011-aaa`) match more rows than intended. Real roadmaps routinely cross-reference features in free text.
*Action: implementer, in a follow-up commit within the same Territory: bind a claim to its row by the Spec cell or a delimited token (`specs/<claim>/` or a match bounded by non-branch characters), or at least require one Owner per claim (first matching row) and name the ambiguity as not graded when two rows disagree; add a fixture for a claim mentioned in another row's text. If the owner prefers to keep the visibility selector, record in notes.md that the Owner/count readings inherit it and why that is acceptable.*

### F2 — The D8 wiring change is a no-op: `roadmap-claims` was already in `$captureMembers`, and `RIT-008` passes on the parent — MEDIUM (follow-up)

`ritual-checks.ps1` builds `$captureMembers = @($naCapableMembers + $ungradedCapableMembers | Select-Object -Unique)`, and `$naCapableMembers` already contains
`roadmap-claims`. The UNGRADED line is detected for every capture member, so the parent already lifted a `roadmap-claims: UNGRADED` line to the verdict and the
`RESULT UNGRADED` line. Observed: in the parent worktree both `RIT-008/fail` and `RIT-008/pass` pass. So the plan's D8 premise ("`roadmap-claims` is not there,
so its UNGRADED line would be read as OK") was wrong; the edit is harmless and tidy, but it fixes nothing, `RIT-008` is not a fixture that fails for a stated reason
(SC-002), and dropping the name from `$ungradedCapableMembers` alone would not fail it (only dropping it from both lists would). notes.md ("`RIT-008` fails if the
name is dropped") and the `rules.json` note ("without 'roadmap-claims' in it that word would be summarised as OK") state the contrary.
*Action: implementer corrects the notes.md and `rules.json` wording to what is true (the fixture is a regression guard on the union of the two lists, and was green on the parent); the plan's D8 premise is recorded as a plan inaccuracy by the owner or in notes.md. No code change needed. This is a statement of fact, not a request to amend the plan.*

### F3 — Owner cells that are not one bare name fail, with a message that does not say why — MINOR

`ada, grace`, `**grace**`, `@ada`, `Ada (backend)` and an ASCII `-` / `TBD` placeholder are treated as a stranger Owner (`-` and `TBD` are not exempt; only blank
and `—` are). Scratch run: `'ada, grace'` and `'**grace**'` each produced the "not on the developer roster" finding. This follows D3/D4 (exact match, no fuzzy)
and the message lists the roster, so the fix is visible, but an adopter's existing roadmap with a co-owner or markdown emphasis starts failing the moment a roster
is declared, and phase 4's SC-003 measurement and guidance (`team-workflow.md`) should say the Owner cell carries one roster name and nothing else.
*Action: phase 4 guidance states the Owner cell format; consider whether `-` and `n/a` should be exempt like `—` (owner's call; no change needed for approval).*

### F4 — "Usable roster" is any non-empty `Roster`, including one developer: faithful to the spec, with one practical risk — MINOR

Spec Edge Cases: "A roster of one developer is solo mode ... and every roster-membership check still applies to that one name"; Key Entities: Roster is "the usable
entries"; `Get-DeveloperMode` returns a non-empty `Roster` for one string. The interpretation is correct, and notes.md flags it. The risk: a solo project that
once wrote `"developers": ["me"]` and has roadmap Owners spelled otherwise (a person's full name, a handle) fails the first CI run after the update, in the
Critical and the roadmap paths alike. It is the most likely SC-003 verdict move.
*Action: none for this phase; phase 4 lists it in the SC-003 measurement and the updating guidance.*

### F5 — Edge cases with no fixture of their own — MINOR

Covered: stranger, case difference, object roster, blank, dash, own claim, idea row, no Owner column, one/two/three claims, stale, shipped, different Owners,
unreadable tip, single claim with a corrupt tip, no roster and empty roster. Not covered: the 14-day boundary (verified by hand, scratch run), `In Progress`
capitalisation and padding (verified by hand), an Owner with two claims where one tip is unreadable, an Owner not on the roster who also holds two claims (both
the roster finding and the note print; verified by hand), a roadmap with two tables where only one has an Owner column, and F1's cross-reference. I read the code
for each and it behaves as intended. A double space in `in  progress` is not counted as active (the Status must equal `in progress` exactly); that matches D7's words.
*Action: optional fixtures; the unreadable-tip-with-two-claims and the second-table-without-Owner cases first, plus F1's.*

### F6 — A non-Owner-column table beside an Owner-column table is silently skipped — MINOR

`$ownerColumnSeen` is true if any Status-bearing table has an Owner column; rows from a Status table without one carry `Owner = $null` and are not graded, with
no line saying so (scratch table `F` in a Status-only table: not graded, not reported). Arguably correct (nothing to read) and consistent with the n/a idiom, but
the OK line then says "Owners ... graded" for a roadmap in which some claims were not.
*Action: none required; note it in notes.md or print a line when a claim's only non-idea rows lack an Owner column.*

## Amendments in this diff

- [x] **None.** `tasks.md` changes tick T010-T014 only; `spec.md`, `plan.md` and `contracts/` are untouched. The finding in F2 (the D8 premise was wrong) is
  recorded here as a fact, not made as an amendment.

## Constitution re-check (post-implementation)

**PASS.** No new script or package; the roster is read only through the single reader; the change stays inside its Territory; a comparison that cannot be made
is said (UNGRADED), never OK, honouring the feature 015 rule; fixtures were written before the readings and fail on the parent for the stated reason, except
RIT-008 (F2). Silence with no roster follows the owner's D5 decision.

## Test coverage observed

- `-Case CLAIM-`: 117 passed (existing 001..008 pairs unchanged, plus 22 + 4 inventory differences on the parent as listed above).
- `-Case RIT-`: 129 passed.
- Full harness on a detached `660cccb`: 1309 passed, 0 failed, 0 skipped; `roadmap-claim-check.ps1` 14 of 14 sites fixtured.
- Critical assertions: byte-identical no-roster output (`pass-no-roster` x3, `pass-empty-roster`, `pass-idea-row`); the exit-0 note (`CLAIM-012/fail`); UNGRADED
  with exit 0 through a corrupt tip (`CLAIM-013/fail`); no date read for a lone claim.

## Residual risk

Concentrated in F1: the row-selection by free-text containment now drives a pass/fail verdict on Owners and WIP, and real roadmaps cross-reference claims. F2 is a
documentation accuracy issue with no behavioural effect. F3 and F4 are adopter-facing consequences of the exact-match and one-developer-roster decisions and
belong to phase 4's guidance and SC-003 measurement. Merge after the owner's gate certification and human review; F1 should be addressed or explicitly accepted by the
owner first.
