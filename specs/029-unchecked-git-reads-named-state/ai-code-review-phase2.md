# AI Code Review — 029 Make every unchecked git read a named state (phase 2)

**Reviewer**: fresh-context agent, Claude Sonnet 5.5 (claude-sonnet-5-5)
**Date**: 2026-10-16
**Branches**: kit repository `029-unchecked-git-reads-named-state` (phase 2 commit `02a065d`)
**Scope reviewed**: `git show 02a065d` for `scripts/enforcement-pack.ps1` (`Read-AmendmentGit`, `Set-AmendmentReadFailure`, `Test-AmendmentReadFailed`, `Get-CommitMetaBatch`, `Get-NameStatusBatch`, `Test-SameBlobContent`, `Get-BlobLines`, `Get-AddedRecordLines`, `Get-OtherFeatureSubject`, `Invoke-AmendmentAuthorityCore` and the Lite conversion in `Invoke-AmendmentAuthority`), `tests/enforcement/rules.json` (AMEND-011), the eight `tests/enforcement/cases/enforcement-pack/AMEND-011/*` fixtures, and the phase 2 section of `notes.md`. Read as contract: `spec.md`, `plan.md` (D1-D9, Amendment 1), `tasks.md` (T008-T013). Not re-run: the injections E4-E8 and mutations P1-P6/Q2 (read, not reproduced); the full harness (in progress elsewhere).
**Feature contract**: no new script, package or verdict word; healthy runs byte-identical; numbered lane fails by name, Lite lane is never newly failed (014 FR-009); one cause prints one line.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5), the session that produced the diff
- **Inputs provided**: commit `02a065d` diff (scripts, tests, rules.json), spec.md, plan.md, tasks.md, notes.md, `docs/sdlc/definition-of-done.md`, `docs/sdlc/review-process.md`, the AI review template; phase 1 helpers `Read-GitLines` and `Add-GitReadUnreadable` for context
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups** — Phase 2 routes the amendment check's git reads (metadata batch, name-status batch, range rev-list, blob read, `-U0` read, rename compare, renumbering ls-tree) through `Read-AmendmentGit`, records the first failure, and refuses by name at the walk's boundaries. The Lite lane reuses the existing `cannot grade ` prefix conversion. I found no code defect. I traced every call site and every `return`/`continue` after a possible failed read, and each reaches a later check: the top-of-loop check, the amended-stage check, the verdict-stage check or the after-loop check. The `ls-tree` absent-vs-unreadable probe is sound. The eight fixtures fail on the parent script (8 failures with it swapped in, in my own worktree) and pass on the commit (78/78 for `-Case AMEND-011`). Residual risk sits in documentation: the shipped fixture descriptions and the `rules.json` note name reads (G8) that the fixtures do not reach, and exemptions for G8, G9 and G10 are cited to an Amendment 1 that does not list them.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-002..FR-004, FR-006: the seven reads of the amendment check go through `Read-AmendmentGit` (enforcement-pack.ps1:278-282; call sites 1432, 1460, 1625, 1990-1994, 2139-2142). G9 `Test-SameBlobContent` (1544-1551) returns false when either read fails, so the path is graded, not skipped (D4). Traced and sound. |
| Visual-reference match | N/A: governance tooling, no UI. |
| Feature contract held | No package, script or verdict word added. `git diff 08b1c49 02a065d --stat` outside specs/029: `scripts/enforcement-pack.ps1`, `tests/enforcement/rules.json`, and the fixtures. The `docs/roadmap.md` change in that range is the main-merge commit, not `02a065d`. |
| Constitution / domain invariants | Constitution I: tasks.md T008-T012 are ticked without amendment; T009/T010 name `GITREAD-004..010` but the work used `AMEND-011` (see F2). No plan/spec text changed in this commit. |
| Security | Only read-only `git` calls; no secrets or new output of git's stderr (exit code only). |
| Scope guard (`git diff --stat` read for intent) | 28 files: script, rules.json, 8 fixtures x 3 files, notes.md, tasks.md. All inside the phase 2 Territory (`scripts/enforcement-pack.ps1`, `tests/**`, the feature dir). `scope-check.ps1` not run by me; the file set was read against the Territory. |
| Rollback safety | One commit touching the script and fixtures; reverting restores phase 1 state. The reader and policy functions from phase 1 are untouched. |
| First-failure-wins / flag clearing (attack 1) | `Set-AmendmentReadFailure` (273-276) keeps the first. `Test-AmendmentReadFailed` (283-291) clears after printing, and every call site `return`s. `Invoke-AmendmentAuthorityCore` resets it at entry (2137). Only one `Core` call exists (grep: line 2090). |
| Boundary coverage (attack 1) | A read can fail in: batches (check at 2140, 2142-2144, 2181-2182), `Get-MergeAuthoredPaths` (merge path: `Get-BlobLines` via `Test-CheckboxOnlyChange`/`Test-StatusOnlyChange`; every exit is `continue` -> top-of-loop check at 2188, or `return` with its own refusal), `Get-OtherFeatureSubject`/own-dir rows (check at 2275 after the rows loop), `Get-AddedRecordLines`/`Get-MergeRecordLines` (check at 2298 before `$bad`), last commit (check at 2327). I found no path from a failed read to a verdict without an intervening check. |
| `Get-BlobLines` probe (attack 2) | `git ls-tree <ref> -- <path>` exits 0 and prints nothing for an absent path; non-zero or output means unreadable (1563-1566). A truncated blob (255) and a damaged tree both flag. A path absent in one parent only is treated as absent (correct: the four deleted-document merge fixtures are the controls). Glob characters: in a scratch repo `ls-tree HEAD -- 'specs/001-a/contracts/a[12].md'` and `'specs/001-a/*'` exit 0 with no output, same as `git show` (exit 0, scratch run), so a path with wildcard characters is not misread. Cache: a failed read caches `@()` (1568), but the flag is set at that moment and the walk refuses at the next boundary before any other caller can use it; no second `Core` call exists. |
| `Test-SameBlobContent` (attack 3) | Both reads are issued and both recorded; either failing returns `$false`. `.Substring(0,7)` is on full 40-char shas from rev-list/name-status parents (never empty: the root-commit `continue` precedes). Healthy: `-join ''` of one-line arrays equals the old string `-eq`. E7 injection result in notes.md read, not re-run. |
| Lite lane (attack 4) | The refusal text begins `AmendmentAuthority: cannot grade '` (288); conversion regex at `Invoke-AmendmentAuthority` line ~2095 matches `^AmendmentAuthority: (cannot grade|could not parse commit metadata) `. Fixture `fail-lite-show-record` expects UNGRADED, exit 0; on the parent that branch failed (notes.md; my parent-swap run failed 8 expectations in total). |
| Healthy byte-identity (attack 5) | `--format=$fmt` is one array element with the same string; `git show -U0 --format= <c> -- <p>` equals the old `--format=''`; the `-join "`n"` in `Get-CommitMetaBatch` is unchanged on `.Lines`. `Read-GitLines` returns the unfiltered lines on success. Phase 2 healthy fixtures (`pass`, `pass-tick`, `pass-name-status`, `pass-lite-show-record`) match; the AMEND-011 run passed 78/78 including the harness's anchor-uniqueness and recall tests. |
| Fixtures (attack 6) | `diff` of each fail/pass recipe pair differs only in the description and one line: `truncateBlob` (fail, fail-tick-blob, fail-lite-show-record) or `truncateCommit` (fail-name-status). Swapping the parent script (`08b1c49`) into my own worktree: 8 failures (6 case expectations plus the 2 rules.json inventory tests), so the fixtures fail without the code. `expected.txt` files are hand-written with `<SHA>` normalisation; the exit codes in 8 `command.json` match. `rules.json` AMEND-011: `emitAnchor` appears once in `rules.json` and once in the script (grep -c = 1/1); the harness's anchor test passed. |
| Mutations P1-P6, Q2 (attack 7) | P3: nothing runs between the check at 2182 and the top-of-loop check at 2188 except `Get-CheckPresenceSet` (own reads, no flag use), and `$commits.Count -gt 0` is guaranteed, so the first check is dead redundancy: equivalent, honestly reported. P5: every call site returns after printing and `Core` resets at entry (2137), so equivalent. P4: redundant with the verdict-stage check except for wasted reads, and Q2 (both dropped) shown by hand; I did not reproduce it. P6 (last wins) is untested: see F4. |
| Out-of-Territory changes (attack 8) | None. `docs/roadmap.md` differs only through the earlier main merge. |

## Findings

### F1 — Fixture descriptions and the AMEND-011 note name reads and exit codes the fixtures do not reach — DOC DRIFT

`fail/recipe.json` says "git show -U0 exits 128" and "(feature 029, G8)", but its `expected.txt` prints `git show <SHA>:specs/001-thing/plan.md failed (git exited 255)`, the blob read. `fail-tick-blob/recipe.json` says "git show of the blob exits 128" against an expected 255. `pass/recipe.json` and `pass-tick` descriptions refer to a twin named `fail-show-record` that does not exist (the cases are `fail`, `fail-lite-show-record`). `tests/enforcement/rules.json` AMEND-011 `notes` says fixtures reach "git show -U0 of an amended path (G8 ...)". `notes.md` itself says G8 has no fixture state. The expectations are right; the labels around them are wrong, and the rules.json note is the inventory the harness treats as authoritative.
*Action: implementer corrects the three descriptions and the rules.json note before the gate (docs only; expected.txt unchanged).*

### F2 — Tasks T009/T010 ticked with different rule ids and no recorded amendment; notes misattribute the plan's number — DOC DRIFT

`tasks.md` T009/T010 call for `GITREAD-004..010`, one fixture and rule per read. The phase delivered one rule `AMEND-011` with eight fixtures. `notes.md` says "The plan numbered the rule `AMEND-010`", but neither plan.md nor tasks.md contains AMEND-010 (grep); AMEND-010 is an existing exempted rule. T011's "update the amendment check's `LIMITS` comments" is ticked but the diff changes no LIMITS comment (grep of the script shows only the Critical `LIMITS` block at 425). The ids are labels, as phase 1's notes already argued, so this is not a behaviour issue.
*Action: implementer adds one line to notes.md recording the id decision and saying whether any amendment-check LIMITS comment needed changing; no approved-document edit needed (phase 1 handled T003 the same way).*

### F3 — Exemptions for G8, G9, G10 cite Amendment 1, which does not cover them — CONFIRM

Plan Amendment 1 (owner-approved) lists G2a, G2b, G3, G4, G6, G12, G14a as mutation-guarded. `notes.md` and the rules.json note say G4, G6, G8, G9 and G10 are "guarded by injected failures (Amendment 1)". G4 and G6 are covered. G8 (`git show -U0`), G9 (rename compare) and G10 (renumbering ls-tree) are not in the amendment, and tasks T009 asked for G9 and G10 fixtures. D8 says a read moved out of the fixture set needs an owner-approved amendment, not an author's edit. Substantively the claim is plausible: for G8, the blob read (255) always fails before `-U0` in any fixture state I could construct; G9 and G10 read objects a successful read just read. But it is an unapproved exemption set.
*Action: owner decides (approve a short Amendment 2 listing G8, G9, G10 as injection-guarded, or ask for fixtures); the implementer then records the approver. I did not re-run injections E6-E8; the owner may want one shown.*

### F4 — First-failure-wins and the G9 `$null -eq $null` arm have no guard that CI runs — MINOR

P6 (last failure wins) is not caught by any fixture; the only effect is which read is named when two fail, and notes.md says so. The G9 arm (`Test-SameBlobContent` returning false when both reads fail) is guarded only by injection E7 recorded in notes.md. T012 listed "the `$null -eq $null` arm restored" and "the Lite arm made silent" as mutations; the Lite arm is caught by the fixtures (P2), the G9 mutation is not recorded as such.
*Action: none required for merge; the implementer may add the G9 mutation result to notes.md. ACCEPTED as a limit by plan Amendment 1's method once F3 is decided.*

### F5 — Dead check after the name-status batch, and a redundant amended-stage check — MINOR

The check at line 2182 can never print anything the top-of-loop check at 2188 would not (P3), and the amended-stage check at 2275 is redundant with the verdict-stage check except for avoiding wasted reads (P4/Q2). They are cheap and make each stage's contract explicit; they cost nothing on a healthy run.
*Action: none.*

## Amendments in this diff

- [x] **None** stated explicitly: `02a065d` changes `tasks.md` only by ticking T008-T012 and adds notes; it edits no spec.md, plan.md or contracts/ text. (Ticking is exempt in constitution I.)

## Constitution re-check (post-implementation)

PASS. I (specification first): no approved text amended; the exemption set needs the owner's confirmation (F3). IV (architecture consistency): the helpers sit beside phase 1's, no new script. VIII (testing): four failing fixtures with readable twins plus injected checks for the unreachable reads; fixtures fail on the parent and pass on the commit. IX and X: this is an enforcement member, so the owner runs the gate (user-run, no batching).

## Test coverage observed

`-Case AMEND-011` on a detached worktree of `02a065d`: 78 passed, 0 failed, 0 skipped (8 cases x 2 expectations, plus the harness's generic recall, anchor-uniqueness and normalisation tests that run with every selection). With the pack from `08b1c49` swapped in: 8 failed (the new expectations, plus the rule-inventory and anchor tests), restored afterward. Critical assertions: the numbered refusal text, the Lite UNGRADED line with exit 0, and the readable twins' unchanged output. I did not run `-Case AMEND-` as a whole (notes.md says the four deleted-document merge fixtures are the controls for the probe) or the full harness.

## Residual risk

Code risk is low: the failure paths are reachable only on a damaged repository, healthy output is unchanged by construction, and the Lite lane cannot newly fail. The open items are F3 (owner decision on the G8/G9/G10 exemption set) and the labels in F1/F2, which should be corrected before the owner runs the gate. The full-harness count (T013) and the gate are still owed and are not part of this review.
