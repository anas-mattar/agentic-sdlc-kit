# AI Code Review — 028 Unreadable Diff Named State, Phase 1 (the helper, the count line, two lane arms)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-15
**Branches**: agentic-sdlc-kit `028-unreadable-diff-named-state` (code commit `3587912`, reviewed as `git diff d4609b8 3587912`; `655df07` adds notes only)
**Scope reviewed**: `scripts/enforcement-pack.ps1` (`Read-DiffLines`, `Add-DiffUnreadable`, `Get-ChangedFiles`, the count line, the numbered and `fix/`/`chore/` dispatch arms, the amendment check's LIMITS comment); the nine new `DIFF-001`/`DIFF-002` fixtures; the `rules.json` hunks; notes.md Phase 1; spec.md, plan.md D1-D9, tasks.md T001-T006.
**Feature contract**: a readable, empty, base-less, shallow or trunk input is byte-identical; the numbered lane fails once; a Lite branch is never newly failed on a condition it cannot compute (014 FR-009); no new package.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: the agent session that produced commit 3587912 (a different session; not this reviewer)
- **Inputs provided**: the phase 1 diff (`git diff d4609b8 3587912`), CLAUDE.md, docs/sdlc/review-process.md, specs/_templates/ai-code-review-template.md, spec.md, plan.md, tasks.md, notes.md, the 027 phase 2 review (format)
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES.** One pre-existing fixture regresses: `enforcement-pack/AMEND-008/fail` (an unreadable merge tree on a numbered branch) now prints the new `diff unreadable` count line and a second failure, so its hand-written `expected.txt` no longer matches. The notes claim every pre-existing case is unchanged (FR-009 / T006) and list only `-Case DIFF-` and `-Case LITE-`; the author's own harness log already shows this failure. Everything else I could build holds: the exit code is captured correctly, the readable, empty, no-base and shallow shapes are byte-identical to the parent, the lane arms behave as D3/D6 say, the new fail fixtures fail on the parent as claimed, and the mutation claims (including both "not caught") are true. The fix is a one-file expectation update plus an honest note; it is small, but it is a failing test in the tree, so it blocks.

## What was verified (evidence)

Harness runs, from my own worktree at `3587912` (NOT the full harness): `-Case DIFF-` 78 passed / 0 failed; `-Case LITE-` 118 / 0; `-Case GAP27` 78 / 0; `-Case PACK-` 78 / 0; `-Case AMEND-` **271 passed / 1 failed** (`AMEND-008/fail`). Parent script (`git show d4609b8:scripts/enforcement-pack.ps1` placed in a second worktree) over `-Case DIFF-`: 70 passed / 8 failed.

| Area | Evidence |
|---|---|
| Exit code capture (D1) | `$lines = @(& git @args 2>$null)` then `$code = $LASTEXITCODE` on the next statement; no pipeline between. `$ErrorActionPreference='Stop'` does not throw on redirected native stderr under pwsh 7.6.7 (every fail fixture runs through to exit 128). No `Push-Location`/`try-finally` sits between the call and the read, and the function does not change directory. Mutation M1 (a native `git --version` between the diff and the read) reproduced: 6 failures in `-Case DIFF-`. |
| Return shape (D2) | Readable list: `return $read.Lines` unrolls as `(git diff) \| Where-Object {$_}` did; one file unrolls to a scalar and zero files to `$null`, as on the parent (`$null.Count` is 0, `[string[]]` binds). Controls `pass-lite-readable` (2 files), `pass-docs-readable` (1 file) and `pass-lite-empty-diff` (0): output and exit byte-identical on parent and phase (both scripts run over the same built repo, compared with `cmp`). |
| No-base is not the state | `Get-ChangedFiles` returns before running git with no base and leaves `Ok = $true`. `GAP27-002/fail` (no base) is byte-identical on parent and phase; the dispatch warning and both UNGRADED lines print once. M3 (drop the early return) fails 1 case in `-Case LITE-` and 4 in `-Case GAP27`, 0 in `-Case DIFF-`. |
| Lane arms (D3, D6, D7) | Numbered: one `DiffUnreadable:` failure, exit 1 (the once-only flag is unobservable with one reader). `fix/` and `chore/`: one `UNGRADED: LiteAndAbuse: ...` line, verdict `UNGRADED (1 check(s)...)`, exit 0. `-ReplayBase/-ReplayTip HEAD` and `-IgnoreAmendmentBoundary` over the unreadable `fix/` repository print exactly what the plain run prints (no effect on the new state). The numbered arm sits first in its branch, before the structure checks. |
| Trunk | `-Branch main` over the unreadable repository: count line reads `diff unreadable (git diff exited 128)` (parent: `0 changed file(s)`), then the trunk line, `OK`, exit 0. Verdict and exit unchanged; the text changes (F4). |
| docs/ lane in phase 1 | `docs/x` over the same damage: `diff unreadable (git diff exited 128)`, "review-provenance is the only scripted check that applies", `enforcement-pack: OK`, exit 0, **no UNGRADED line** (parent: `0 changed file(s)` and the same OK). Phase 1 names the state on the count line only; the lane stays OK until phase 2 moves the amendment gate and review-provenance onto the helper. The script's LIMITS comment says so ("THIS gate still says nothing"); the notes and the DIFF-002 note do not (F3). No fixture holds docs/ unreadable. |
| Partial list (D1, FR-008) | Refuted that git can print rows then fail, for every form I tried. Tree damage under `src`: `--name-only` prints nothing, exit 128. Blob damage that rename detection must read (inexact rename off a truncated base blob): `--name-only` and `--name-status` print nothing and exit 128; with `--no-renames` the same repository diffs cleanly. Git builds the diff queue before output, so no partial result exists. The notes' claim holds, and M2 (keep the partial list) is unobservable (`-Case DIFF-`: 78 passed under M2). The blob-read damage is a second real field shape the fixtures do not hold (F5). |
| Fixtures on the parent | Parent script: `DIFF-001/fail`, `DIFF-002/fail`, `fail-chore` and `DIFF-002/pass` (numbered twin) fail; `DIFF-001/pass`, `pass-lite-readable`, `pass-docs-readable`, `pass-lite-empty-diff` pass. 6 case failures plus the two rule-inventory tests = 8. Controls are named honestly. Expectations read by hand against plan D2/D3 text: correct. |
| Truncation is a tree-read failure | `truncateBlob: "src"` resolves `HEAD:src` to a tree object; truncating it gives git exit 128 with the base commit intact, so `merge-base` succeeds and the base sha is printed (not `''`). |
| Platform robustness | The recipe reuses the 014/027 truncate code (read-only cleared, loose object halved) and `rev-parse HEAD:<dir>`, which behaves the same on Linux. The expected text carries only the exit code, never git's wording, and git exits 128 for any `fatal:`. Residual: `truncateBlob` silently does nothing if the object is not loose, which would make a fail fixture fail loudly and a control still pass; fixtures are built fresh and loose, so not a present risk. I did not run the Linux job. |
| rules.json | DIFF-001 anchor `DiffUnreadable: git diff against '` and DIFF-002 anchor `could not be read (git diff exited ` each name one site; function `Add-DiffUnreadable`; the inventory-integrity tests pass on the phase (and fail on the parent, as they should). Note text accurate except for the docs/ omission (F3). |
| Mutations (my worktree) | M1 6 failures (DIFF-). M3 as above. M6 (enter the state on an empty result): 1 in DIFF-, 1 in LITE-. M8 (drop the lane split): 4 in DIFF-. M2 not caught. M5 (call `LiteAndAbuse` on the empty list): `Invoke-LiteAndAbuseCheck` read, every failure sits inside the file loop, the count test or `$migrationHit`, so an empty list is silent: unobservable. Extra: never naming the `LiteAndAbuse` reader fails 2; changing the interpolated exit code in the numbered message fails 2. |
| Territory / strict rules | The code commit's 26 files are in `scripts/enforcement-pack.ps1` and `tests/**`; the `docs/roadmap.md` row in `d4609b8..3587912` came in with merge `3c81989` (`git diff 3c81989 3587912` has no roadmap change). spec.md, plan.md, tasks.md untouched; no package added; one phase. tasks.md T001-T006 are not yet ticked. |
| Other consumers | `Get-ChangedFiles` is called only at the dispatch (count line, `LiteAndAbuse`, `-ChangedFiles` for the Lite amendment gate, which still receives the empty list on an unreadable diff until phase 2). No other script calls it; `roadmap-claim-check`, `territory-check` etc. have their own readers and were not touched. |

## Findings

### F1 — `AMEND-008/fail` regresses: a pre-existing fixture now reaches the new state — REQUEST CHANGES (blocking)

`tests/enforcement/cases/enforcement-pack/AMEND-008/fail` damages the tree of a merge's second parent (`truncateCommit: HEAD^2^{tree}`) on numbered branch `001-thing`. The base resolves and `git diff --name-only <base> HEAD` exits 128, so the phase prints `diff unreadable (git diff exited 128)` where the expectation reads `0 changed file(s)`, and the verdict is `FAIL (2 issue(s))` (the new `DiffUnreadable:` line first, then the existing `AmendmentAuthority: cannot grade ...` refusal) where the expectation holds one. Reproduced by `-Case AMEND-` (271 passed, 1 failed) and by building the recipe by hand. The author's harness log (scratchpad `p1-harness.txt`) shows the same failing case, yet notes.md T006 lists only DIFF- and LITE-, and the plan's "every pre-existing case unchanged" is untrue for this case. The behaviour is correct by design (a damaged tree on a numbered branch is now named), so the correction belongs in the expectation, not the script.
*Suggested fix*: hand-edit `AMEND-008/fail/expected.txt` (new count line, `FAIL (2 issue(s))`, the `DiffUnreadable` line, then the existing refusal line); say in notes.md that one existing case changes by design and why; run and record `-Case AMEND-` plus the other cases that name truncate recipes (`GAP27-003`, `AMEND-005`, `AMEND-009`). Decide and record whether two failure lines for one damaged merge parent is the intended numbered output (the once-only flag covers only repeats of `DiffUnreadable`, not the amendment refusal).

### F2 — The notes' test counts are off — MINOR

Notes: `-Case DIFF-` 77 and `-Case LITE-` 117 after the empty-diff control (76 and 116 before). Pester counts two tests per fixture, so the control adds 2; I get 78 and 118 on the phase.
*Suggested fix*: correct the numbers when T006's results are rewritten.

### F3 — In phase 1 a `docs/` branch with an unreadable diff ends `OK`, exit 0, with no UNGRADED line; undisclosed in notes and unfixtured — MINOR

`docs/x` over the src-truncated shape prints the new count line, "review-provenance is the only scripted check that applies" and `enforcement-pack: OK`. That is the intermediate state the plan prescribes (docs/ gets UNGRADED lines from the two phase 2 readers) and the script's LIMITS comment says it, but notes.md and the DIFF-002 rules.json note speak only of `fix/` and `chore/`. Between phases 1 and 2 an unreadable docs/ diff is named on one line and graded OK.
*Suggested fix*: one sentence in notes.md and the DIFF-002 note that docs/ is named on the count line only until phase 2; optionally add a docs/ unreadable fixture now so phase 2 flips its expectation visibly.

### F4 — The trunk branch's count line changes under damage, against plan D3 "never reaches it" — MINOR

On `main`/`master` the diff is read before dispatch, so a failing diff changes the printed count line (verdict and exit stay OK/0). Harmless, but plan D3's "no diff is read, as today" is not literally true and no fixture holds trunk.
*Suggested fix*: record in notes.md (a plan rewording would need the owner's record); optionally a trunk fixture.

### F5 — Fixtures guard one damage shape; a second git-observable shape is unguarded — MINOR

Damage to a blob that rename detection must read also makes `--name-only` exit 128 with no stdout (`--no-renames` reads cleanly). Same code path and outcome, so no defect, but the "damaged branch is never graded empty" claim is evidenced for tree damage only. The `Reader` label for `LiteAndAbuse` and the base in the message are guarded only through the paths the fixtures reach.
*Suggested fix*: optional second fixture for the rename-read damage; no code change.

### F6 — Unobservable properties remain documentation — INFO

M2 and M5 are genuinely unobservable, as the notes say; FR-008 stays a stated property. The numbered once-only flag has no phase 1 guard (M4 waits for phase 2's second reader).
*Suggested fix*: none now; keep M4 on the phase 2 list.

## Amendments in this diff

**None.** spec.md, plan.md, tasks.md and contracts are unchanged (notes.md only).

- [x] Amendments listed, or **none** stated explicitly

## Constitution re-check (post-implementation)

PASS on I (no self-approval: not engaged), II/X (no Lite branch newly fails; fix/chore fixtures and docs/ exit 0), IV (no new script or package). The notes' "pre-existing cases unchanged" statement is inaccurate for one case (F1): a report-accuracy defect, not an amended law.

## Test coverage observed

Nine new fixtures, each pair differing in one condition; expectations hand-written and consistent with the plan; controls cover readable, empty and docs/ diffs. Not held: docs/ unreadable, trunk unreadable, rename-read blob damage, the once-only flag, a Lite branch with an unreadable diff and a second failing reader.

## Residual risk

The state is reached on any damage that `git diff --name-only` must read, so any existing fixture that damages objects on a numbered branch may print differently; `AMEND-008/fail` is the one I found in the `AMEND-`, `GAP27`, `PACK-`, `LITE-` runs, and the author's full harness should be checked for others. Throwaway repositories and worktrees lived under the scratchpad `review1` folder and were removed afterwards. I did not run the full harness or the Linux job.

### Implementer dispositions (appended; the reviewer's text above is unedited)

Fixes are in commit `4efabf2` (the review reviewed `3587912`).

| Finding | Disposition |
|---|---|
| F1 | **Fixed, and the owner decided to keep both failure lines** (anas.m, 2026-10-15). `AMEND-008/fail` is re-expected by hand: the count line reads `diff unreadable (git diff exited 128)` and the run ends on two failures, the new `DiffUnreadable` line first and the existing `AmendmentAuthority: cannot grade` refusal second; its exit code stays 1. The first draft of `notes.md` claimed no pre-existing case changed; it now says one does, and why. The full harness on `3587912` was 1695 passed, 1 failed (this case, the only one). Re-run on the fixed tree: `AMEND-` 272, `DIFF-` 80, `GAP27` 78, `PACK-` 78, `LITE-` 118, `CRIT-` 228, all passing. |
| F2 | **Fixed.** The counts in `notes.md` are corrected (each fixture is two tests; `-Case LITE-` matches the substring `lite-` in fixture names). |
| F3 | **Stated, not fixed: it is the plan's intermediate state.** A `docs/` branch with an unreadable diff prints the named count line and then `OK` until phase 2 moves its two readers. `notes.md` and the `DIFF-002` note in `rules.json` now say so; phase 2's `docs/` fixture (T008) flips it. |
| F4 | **Stated as a limit** in `notes.md`: the count line can change on a trunk branch under damage (verdict and exit unchanged); plan D3's "never reaches it" is true of the policy function and not of the count line. No fixture can reach it (on `main` the base is `HEAD`). The approved plan is not edited. |
| F5 | **Fixed.** `DIFF-002/fail-blob-rename-detection`: a second damage shape (a blob that rename detection must read, a manifest moved with one line added). On the parent it printed `0 changed file(s)` and `OK`; now `UNGRADED`, exit 0. A first draft with byte-identical content was paired by hash, read no blob and did not fail, which is why the content differs by a line. |
| F6 | **Information.** M2 (keep the partial list) and M5 (call `LiteAndAbuse` on the empty list) are confirmed unobservable by the reviewer; stated in `notes.md` and in `rules.json`. M4 (the numbered once-only flag) is shown in phase 2. |
