# AI Code Review — 029 Make every unchecked git read a named state (phase 3, commit 1554148)

**Reviewer**: fresh-context agent, Claude Sonnet 5.5 (claude-sonnet-5-5)
**Date**: 2026-10-16
**Branches**: kit repository `029-unchecked-git-reads-named-state` (tip `1554148`, phase 3 on top of `1d5613a`)
**Scope reviewed**: `git show 1554148 --stat` and the diff of `scripts/` and `tests/`; `scripts/enforcement-pack.ps1` at `1554148` (`Read-GitLines` 239-247, `Add-GitReadUnreadable` 255-265, `Invoke-CriticalEvidenceCheck` 556-593, `Invoke-CriticalSoloEvidence` 595-623, `Get-SurfaceExceptions` 1058-1100, `Invoke-LevelSurfaceCheck` 1103-1171, dispatch `$Branch = Get-CurrentBranch` at 2378); the two new fixtures (`command.json`, `recipe.json`, `expected.txt`) under `tests/enforcement/cases/enforcement-pack/GITREAD-001/`; `CRIT-S02/fail/expected.txt`; the two edited `notes` strings in `tests/enforcement/rules.json`; spec.md, plan.md (G11/G12 rows, D3, Amendments 1 and 2), tasks.md (Phase 3, T014-T019), notes.md (the phase 3 section).
**Feature contract**: no new script, package, rule id or verdict word; healthy runs byte-identical; a failed read on a numbered branch is a failure that names the read, on the Lite lane and for an advisory check it is one UNGRADED line, never a new Lite failure (014 FR-009); G11 keeps its failure and names the true cause; G12 keeps the author's-day-else-clock fallback only for git printing no date.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5), the session that produced the diff
- **Inputs provided**: the phase 3 commit diff (`git show 1554148`); the files listed under "Scope reviewed"; family runs of `tests/enforcement/Run-Tests.ps1` on a detached worktree of `1554148` (GITREAD-, CRIT-, LEVEL-, DIFF-, AMEND-, LITE-, MICRO-, PHASE-, PACK-, PROV-); two throwaway mutations on a second detached worktree (S1 re-run, and an injected failure of G12). Both worktrees were removed; nothing in the main tree was touched except this file.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups** — Phase 3 routes two date reads through `Read-GitLines`. G11 (`Invoke-CriticalSoloEvidence`) now names a failed `git log --follow` as a numbered-lane `GitReadUnreadable` failure instead of the false "has no git history ... commit it" message. G12 (`Get-SurfaceExceptions`) names a failed `git log` of HEAD as an advisory UNGRADED line and keeps the clock fallback. I attacked the reachability of the new branch, the old "no history" path for an uncommitted file, multi-line and empty output, the dynamic-scope use of `$Branch`, the Lite lane, the dedupe keys, the Consequence quoting, and the two fixtures. I found no defect that changes the verdict. All ten families are green at `1554148` (1348 passed, 0 failed). Residual risk sits in a few small things: a G12 UNGRADED line prints even when the spec has no Surface Exception (F1), two ticked tasks are not literally what was done (F2), and `$Branch` is read by dynamic scope in a function that does not declare it (F4).

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | G11: `scripts/enforcement-pack.ps1:602-610` reads through `Read-GitLines`, calls `Add-GitReadUnreadable -Reader 'CriticalEvidence' ... -Key 'log-follow'` and returns; the old `no git history` branch (611-614) is untouched and only reached when git exits 0 with no lines. G12: 1062-1067, `-Advisory`, fallback at 1068-1069 unchanged. Plan G11/G12 rows and D3 (plan.md:39-40, 94) match. |
| Visual-reference match | N/A: no UI. |
| Feature contract held (no unapproved table/migration/permission/package) | `git diff --name-only 1d5613a 1554148`: `scripts/enforcement-pack.ps1`, `notes.md`, `tasks.md`, six fixture files under `tests/enforcement/cases/enforcement-pack/GITREAD-001/`, `tests/enforcement/rules.json`. All within the phase Territory (`scripts/enforcement-pack.ps1`, `tests/**`, the feature's specs dir). `rules.json` changes only two `notes` strings (no new id, no new emit anchor). No package, no new script. |
| Constitution / domain invariants | No amendment to spec.md/plan.md; tasks.md only ticks T014-T018. The failure is on the numbered lane only; the Lite lane is not newly failed (see F4 and the Lite row). |
| Security (authn/authz, secrets, sensitive logging) | N/A: git's own stderr is not printed (`2>$null` in `Read-GitLines`); only the exit code is. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | `git show 1554148 --stat`: 10 files, +209/-9, listed above. I did not run `scope-check.ps1` (the owner's gate and the parallel full harness cover it). |
| G11 branch reachability and the old path | The fixture `fail-cooling-off-history` (review committed 24.5 h ago, tree of `specs/001-thing` truncated so `git log --follow` exits 128) is graded by the new code: the `-Case GITREAD-` family passes. With `-not $recordedRead.Ok` mutated to `... -and $false` (my S1 re-run on a throwaway worktree, `sed`), `-Case GITREAD-001` gave 73 passed, 1 failed ("prints the expected output"). The old message for an UNCOMMITTED review file stays byte-identical: `CRIT-S02/fail/expected.txt` still reads `has no git history — cannot verify ... (commit it to start the clock)` and no `expected.txt` of an existing case is in the diff. |
| G11 healthy read: array vs string | `Read-GitLines` returns `@(& git ...)`, an array; `$recordedRead.Lines \| Select-Object -Last 1` on a one-element or multi-element array yields the last element (a string), exactly as the old `(git log ...) \| Select-Object -Last 1` did (git prints newest first, so Last 1 is the oldest, the first commit). Exit 0 with empty output gives `$null`, so `if (-not $recorded)` takes the old path. `[DateTimeOffset]::Parse($recorded)` receives a string as before. `CRIT-` 228 passed (incl. the cooling-off cases). |
| `$Dir` vs `$dir` casing | PowerShell variables are case-insensitive: the parameter is `$Dir` (line 596) and the old messages use `$dir`; the new message prints `specs/001-thing/second-model-review.md`, which the fixture's `expected.txt` shows. |
| `$Branch` in the two functions | `Invoke-CriticalSoloEvidence` has only `param([string]$Dir)`; `$Branch` resolves by dynamic scope to the `$Branch` parameter of its only caller `Invoke-CriticalEvidenceCheck` (line 557, call at 589), which returns early unless `$Branch -match '^\d{3}-'` (line 558). `Get-SurfaceExceptions` has only `$SpecPath`; its only caller `Invoke-LevelSurfaceCheck` (call at 1137) declares `$Branch` (1104) and also returns early unless numbered. The script-level `$Branch` is set at 2378, before any check. So both reads see a numbered branch name. See F4 for fragility. |
| G12 lane and dedupe | `-Advisory` makes `Add-GitReadUnreadable` take the UNGRADED arm (lines 260-264) whatever `-Branch` is. `Get-SurfaceExceptions` is reached only on a numbered branch (above), so "every lane" is in practice every numbered lane. Dedupe key is `LevelSurface\|surface-day` (257) once per run. The Consequence string `'a Surface Exception was dated against the runner''s clock, not the author''s day'` yields one apostrophe (PowerShell single-quote doubling); notes.md quotes the same text. |
| G12 injected failure (E9) | I re-did it on a throwaway worktree: `'HEAD'` replaced by `'NOSUCHREF'` in the `git log` argument list, `-Case LEVEL-005` gave 65 passed, 3 failed (all three LEVEL-005 cases print the new UNGRADED line, so the existing fixtures that reach the armed surface check do detect the change). Worktree restored with `git checkout`. |
| G12 no-date fallback | When git exits 0 with no output, `$dayRead.Lines` is empty, `"$()".Trim()` is empty and `$day` falls to the clock, with no UNGRADED line (the old behaviour kept). |
| Healthy repositories byte-identical | Every family below is green with no `expected.txt` edited; `GITREAD-001/pass-cooling-off-history/expected.txt` is the plain OK output. |
| Fixture honesty | `expected.txt` of `fail-cooling-off-history` has 7 lines: header with `diff unreadable`, the AmendmentAuthority line (028), the CriticalEvidence not-mid-feature WARNING, the phase 1 `UNGRADED: PhaseSizeWarning`, the FAIL line `(2 issue(s))`, `DiffUnreadable` (028), the new `GitReadUnreadable`. The fixture passes, so every line is really emitted (a stale line would fail the byte comparison). `diff` of the two `recipe.json` files: the description and one line, `"truncateBlob": "specs/001-thing"`: the pair differs in exactly one condition. |
| Rollback safety | Pure script and fixture additions in one commit; `git revert 1554148` restores the parent. No schema, no data. |

Families run at `1554148` (detached worktree, `pwsh -NoProfile -File tests/enforcement/Run-Tests.ps1 -Case X`, one at a time, all exit 0): GITREAD- 78 passed; CRIT- 228; LEVEL- 194; DIFF- 86; AMEND- 288; LITE- 122; MICRO- 100; PHASE- 88; PACK- 78; PROV- 86. **Total 1348 passed, 0 failed, 0 skipped.**

## Findings

### F1 — The G12 UNGRADED line prints even when the spec has no Surface Exception — MINOR

`Get-SurfaceExceptions` reads `git log` of HEAD at its first statement (1062), before it looks for any `**Surface Exception**` line (1070-1073). The date is only used to grade an exception's approval date, so on a branch with a damaged HEAD commit and no exception, the run now prints an UNGRADED line about a date nothing used, and the verdict can move from OK to UNGRADED. In practice a damaged HEAD commit breaks the diff base first (notes.md, the probe; plan Amendment 1), so the state is nearly unreachable, and the line is accurate ("a Surface Exception was dated against the runner's clock" is only conditionally true). It is consistent with plan D3's intent (name the fallback) and is advisory-only, so it can never fail a branch.
*Action: none required; the implementer may defer the read until the first matching exception line is found if the owner wants the line only when it matters.*

### F2 — T015 and T017 are ticked but are not literally what was done — DOC DRIFT

T015 says to write `GITREAD-011` and `GITREAD-012` fixtures including a control for an uncommitted file; only the G11 pair exists, and G12 is guarded by injection (plan Amendment 1, approved 2026-10-15; the plan ids are labels, as notes.md says). The uncommitted-file control is the pre-existing `CRIT-S02/fail`, unchanged (verified above). T017 says "`LIMITS` comments updated"; the diff adds inline comments only and the `LIMITS` block at line 427 is untouched (it concerns the merge-readiness heuristic, so nothing was owed there). The tasks are met in substance.
*Action: owner decides whether to reword T015/T017 in tasks.md (an amendment with a recorded approver, constitution I; the implementer must not approve its own); otherwise none.*

### F3 — The fail fixture is coupled to two unrelated lines — ACCEPTED

`fail-cooling-off-history/expected.txt` also pins 028's `DiffUnreadable` and phase 1's `PhaseSizeWarning` UNGRADED line, because truncating the feature tree damages the diff and a commit's numstat too (notes.md says so). A future change to either line will fail this fixture for a reason unrelated to G11. The guard still bites: my S1 re-run fails it. The readable twin (`pass-cooling-off-history`, OK) means something real: the same history with every object readable passes the cooling-off window, so the failure is caused by the unreadable read alone. I did not re-run S2 (the failure printed as UNGRADED); by reading, it would change the FAIL count and the `GitReadUnreadable` line and so fail the same fixture.
*Action: none.*

### F4 — `Invoke-CriticalSoloEvidence` and `Get-SurfaceExceptions` read `$Branch` by dynamic scope — MINOR

Neither function declares `$Branch`; both depend on their only caller having one (verified, F-table above). A future caller from a context without `$Branch` would pass an empty branch to `Add-GitReadUnreadable`: G11 would then silently downgrade from a failure to an UNGRADED line (the `^\d{3}-` test fails), a quiet weakening. Today the call chain makes this unreachable, and the Lite lane cannot reach G11 at all (`Invoke-CriticalEvidenceCheck` returns on a non-numbered branch), so the change never newly fails a Lite branch.
*Action: none now; a follow-up may pass `-Branch` as an explicit parameter to `Invoke-CriticalSoloEvidence`.*

### F5 — Mutation S2 was not re-run — MINOR

notes.md records S1, S2 and E9. I re-ran S1 (1 fixture failed) and a G12 injection (3 LEVEL-005 cases failed). I did not re-run S2 and did not re-check the "script restored byte for byte" hash claim.
*Action: none.*

## Amendments in this diff

- [x] **None.** `git diff 1d5613a 1554148` touches `spec.md` and `plan.md` not at all; `tasks.md` only ticks T014-T018 (no wording change), and no amendment record is owed.

## Constitution re-check (post-implementation)

PASS. The change adds no package, script, rule id or verdict word; healthy output is byte-identical (all families green, no existing `expected.txt` edited); a failure on the numbered lane names the read and the exit code and does not print git's stderr; the Lite lane is never newly failed (G11 unreachable there, G12 advisory); the advisory line is UNGRADED, which is "not the same as passing". Nothing was claimed as certified: T019 (the full harness, `ritual-checks.ps1`, the gate) is correctly left unticked.

## Test coverage observed

`-Case GITREAD-` 78 passed (74 before the two fixtures, plus the two new cases counted in both Pester contexts); `-Case CRIT-` 228; LEVEL- 194; DIFF- 86; AMEND- 288; LITE- 122; MICRO- 100; PHASE- 88; PACK- 78; PROV- 86; total 1348, 0 failed. Critical assertions: `fail-cooling-off-history` (exit 1, names `git log --follow of specs/001-thing/second-model-review.md` and the consequence) and its readable twin (exit 0); `CRIT-S02/fail` (the old "no git history" message, byte-identical). G12 has no dedicated fixture by design (Amendment 1); my injected failure made all three `LEVEL-005` cases fail, so existing fixtures notice any change in the armed path. I did not run the full harness (one runs elsewhere) nor `ritual-checks.ps1`.

## Residual risk

Low. The G11 path depends on a single `Read-GitLines` call and the existing helper, both already reviewed and gated. Remaining risk: F1 (a harmless extra line in a near-unreachable state), F4 (a latent downgrade if a future caller omits `$Branch`), and the unchecked T019 items: the full harness on an isolated checkout of `1554148` and the owner's gate. Merge only after those and the owner's approval.
