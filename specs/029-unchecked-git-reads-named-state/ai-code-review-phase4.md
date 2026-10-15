# AI Code Review — 029 Unchecked git reads named state, phase 4 (`scripts/territory-check.ps1`)

**Reviewer**: fresh-context agent, Claude Sonnet 5.5 (claude-sonnet-5-5)
**Date**: 2026-10-16
**Branches**: governance repo `029-unchecked-git-reads-named-state` (phase commit `56ee63b`; branch tip at review time `9324f8f`, the later commit is docs only: plan/tasks Amendment 3)
**Scope reviewed**: `git show 56ee63b` (stat and full diff of `scripts/territory-check.ps1`, `tests/enforcement/rules.json`, the four fixtures `TERR-023/{fail,pass}` and `TERR-025/{fail,pass}` with command.json, recipe.json, expected.txt), the whole of `scripts/territory-check.ps1` at that commit (header, params, `Stop-Refused`, `Add-Ungraded`, the other-branch loop, the report/switch/exit tail), `tests/enforcement/lib/FixtureRepo.psm1:202` (autocrlf), `scripts/verify-kit.ps1` (kit file list), `kit-manifest.json`, spec/plan/tasks and notes.md phase 4 section, plan Amendment 3 and tasks Amendment 3. Phases 1-3 code not re-reviewed.
**Feature contract**: territory-check keeps its own vocabulary (plan D6): own-tree reads (uncommitted diff, `ls-remote`) refuse with `Stop-Refused` (exit 1); other-branch reads become `ungraded` records (exit 0 unless a live overlap exists); no new exit code, no new kit verdict word, no new package; `Read-CodeRef` and the code-repository paths not edited.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5 (Claude Sonnet 5.5)
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5), the session that produced the diff
- **Inputs provided**: commit `56ee63b` diff and stat; `scripts/territory-check.ps1` in full around every changed site; the four fixtures; the `rules.json` additions; notes.md phase 4 section; plan.md D6 and Amendments 1-3; tasks.md Phase 4 and Amendments. Ran, in a detached worktree at `56ee63b`: `Run-Tests.ps1 -Case` for TERR-, RIT-, REPOS-, SCOPE-, ROADMAP-, GITREAD-, DIFF-, AMEND-, CRIT-, LITE-, PACK-; `verify-kit.ps1`; `ritual-checks.ps1`; mutations U1 and U2 and a parent-script control (second worktree). Did not run the full harness.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups** — The phase wraps the four unchecked territory-check reads as the plan's D6 prescribes: `git diff --name-only HEAD` and `git ls-remote --heads origin` refuse (exit 1), the other branch's `git log -1` and `git diff` failures become `Add-Ungraded` records (`last-commit-failed`, `diff-failed`) that leave the exit code at 0 unless a live overlap exists. I found no defect in the code: exit paths, `$LASTEXITCODE` placement, healthy-run output and the `[long]$epochRead[0]` change all check out, and every family I ran is green (counts below). The residual items are documentation drift (task ids/fixture ids, a duplicated reason text, notes saying the commit diff is "21 lines" when it is 24) and the unshown claim that a damaged governance diff still compares the code repositories (mutation U3 is honestly recorded as not caught).

## What was verified (evidence)

> Every claim needs evidence — a file/symbol read, a test observed, a query run.

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-002/FR-007 and D6 read against the diff: G13a `scripts/territory-check.ps1:~100-104` (`$dirty`, `$dirtyExit`, `Stop-Refused ... git exited $dirtyExit`); G13b `~110-113`; G14a/G14b `~238-247`. `$LASTEXITCODE` is captured on the very next statement after each native call (`$dirtyExit`, `$remoteHeadsExit`, `$epochExit`, `$otherFilesExit`); nothing can reset it in between (the `@(...)` wrapper is part of the same statement). |
| Visual-reference match | N/A: no UI. |
| Feature contract held (no unapproved table/migration/permission/package) | No package, no schema. `git show 56ee63b --stat` outside the Territory (`scripts/territory-check.ps1`, `tests/**`, the feature's specs dir): nothing (16 files: the script, 12 fixture files, rules.json, notes.md, tasks.md). Amendment 3 (plan + tasks, approver anas.m, 2026-10-16) is in the later commit `9324f8f`, not in the phase commit. No exit code or verdict word added. |
| Constitution / domain invariants | Read-only checks only; refusals go through the existing `Stop-Refused` (stderr, exit 1), records through the existing `Add-Ungraded`. |
| Security (authn/authz, secrets, sensitive logging) | The new messages print the exit code, the branch name and refs only; no secrets. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | Stat read: the script diff is 24 changed lines (notes.md says "21 lines", see F5). `ritual-checks.ps1` in the detached worktree: doc-lint OK, digests OK, roadmap-claims OK, scope-check UNGRADED (detached HEAD, a property of my worktree), enforcement-pack FAIL solely on `Branch naming: 'HEAD' does not match a known taxonomy` (detached worktree artifact, not a defect). I did not obtain a scope-check PASS on a named branch myself. |
| Rollback safety (phase reverts cleanly; schema additive?) | The diff is local to one script, four fixtures and additive rules; reverting the commit restores the old behaviour. |
| Exit paths (script header: 0 / 2 / 1) | Read the tail of the script: `if ($liveOverlap) { exit 2 } else { exit 0 }`; the new `ungraded` records never set `$liveOverlap`; the UNGRADED line prints only in the non-overlap arm; `-Json` computes `CLEAN = (-not $liveOverlap -and $ungraded.Count -eq 0)` and emits `UNGRADED = $ungraded`, so both new causes appear in JSON and CLEAN is false. Header text (`another feature's branch that cannot be compared` ... `still exit 0 unless a live overlap exists`) already covers them. Observed: `TERR-025/fail` expects exit 0 and the two UNGRADED lines; `TERR-025/pass` exit 2. The only exit-code change on a healthy run: none (refusals fire only when git failed). |
| G14 half-updated state | After `last-commit-failed` the `continue` skips the rest of the iteration (code repositories, status, overlap), so the already-set `$hasWork = $true` and `$latestEpoch = 0` are never read. After `diff-failed`, `$otherFiles = @()`, `$shared` is empty, the code-repository loop still runs and can still add overlaps (live overlap elsewhere still exits 2); the run ends UNGRADED, not CLEAN. |
| `[long]$epochRead[0]` vs `[long](git log ...)` | Healthy read: one line, `[long]'1700000000'` equals the old scalar. Empty output with exit 0: `$epochRead[0]` is `$null`, `[long]$null` is 0, as the old `[long]$null`. Whitespace is trimmed by the cast in both. No strict mode in the script. No difference found. |
| Healthy runs byte-identical | The 208 TERR- cases include the healthy CLEAN/OVERLAP/UNGRADED text cases (TERR-001..022): all pass unchanged. No existing text or ordering line was touched. |
| Line endings / bytes | `git ls-files --eol scripts/territory-check.ps1` in the main tree: `i/lf w/lf attr/`. Parent blob and new blob both have 0 CR bytes, so the commit diff is just the intended edit. No `.gitattributes`. `kit-manifest.json` has no hash for the file and `scripts/verify-kit.ps1:65` only lists the path (the update-kit file set); nothing depends on the bytes. `verify-kit.ps1` reports not applicable (kit template). |
| Fixtures | `TERR-023`: fail and pass recipes differ only in the `truncateCommit: HEAD:src/shared.txt` line (and the description); `uncommitted` same in both. `TERR-025`: differ only in `truncateCommit: 012-other:src` (and the description). `expected.txt` files are literal strings (not generated). `FixtureRepo.psm1:202` sets `core.autocrlf false` per fixture repo, which overrides a global `true`, so the fixture does not depend on the machine's global config. Control: with the parent (pre-phase) script restored, `TERR-023` and `TERR-025` each fail their output/exit assertions (the old code printed CLEAN). So the fixtures do fail on wrong code. |
| rules.json | `TERR-023..026` present with unique `emitAnchor` strings; the Coverage tests (`every inventoried rule still exists in the script it names`, `every anchor names exactly the emission sites its rule declares`) pass in the TERR- family (208 passed); they fail on the parent script, as expected. |
| Mutations (notes U1/U2) re-run | U1 (replace `if ($dirtyExit -ne 0)` by `if ($false)`): `TERR-023` exits-with-expected-code and prints-expected-output fail (2 failed). U2 (delete the `Add-Ungraded ... 'diff-failed'` call): `TERR-025` 3 failed (fail fixture and the two coverage tests). Both caught as claimed. Both worktrees restored (`git status` clean) and removed. U3 (code repositories dropped on a diff failure) is recorded as not caught: agreed, see F3. E10/E11 (injections) not re-run; their output strings agree with the code strings I read. |
| Verification commands | See Test coverage observed. |

## Findings

### F1 — TERR-024 and TERR-026 exemptions: reasons are sound but not strictly "no fixture possible" — ACCEPTED

TERR-026's reason is consistent with the code order (`git rev-list --count` runs first and its failure is `claim-skipped`, TERR-012). TERR-024's reason (ls-remote only fails after the earlier fetch succeeded against the same remote) is true of the self/path remotes the fixtures use; plan Amendment 3 records the owner's approval (anas.m, 2026-10-16, commit `9324f8f`). The wording "a fixture that made it fail would also make the fetch fail" is slightly strong: a stateful `remote.origin.uploadpack` shim that succeeds on the first call and fails on the second would reach it, at the cost of a platform-dependent fixture on Windows. I did not try it. The exemption is acceptable because the site stays inventoried by anchor and the injection (E10) guards it.
*Action: none; optional: soften "would also make the fetch fail" to "no portable fixture does" at the next edit of that entry.*

### F2 — Task ids and fixture ids differ from tasks.md — DOC DRIFT

tasks.md T022/T023 name `GITREAD-013`/`GITREAD-014` fixtures and rules; the work used `TERR-023..026` in the territory family, and ticked T022 and T023. T024 asks to "update the script's `LIMITS` wording"; the script has no `LIMITS` comment (grep finds none) and none was changed, as with phase 1-3 (notes record the same finding earlier). Substance met.
*Action: implementer records the id and LIMITS finding in notes.md (as the earlier phases did, F2 of phases 2/3), at the next document pass; no code change.*

### F3 — "Code repositories still compared after a diff failure" is not shown by any fixture — CONFIRM

The notes record mutation U3 as uncaught, honestly. The logic is sound by reading (`$otherFiles = @()` then the code-repository loop runs for every branch), but the plan-level statement "the branch's code repositories are still compared" is a claim without a test. Adding it needs a fixture with a declared code repository plus a damaged governance diff.
*Action: owner decides whether to accept the reading-only guarantee (my recommendation: accept, small risk) or ask for a fixture in phase 5.*

### F4 — Printed text of `last-commit-failed` has nested parentheses — MINOR

The default arm of `switch ($u.cause)` prints `UNGRADED: governance: cannot compare 012-other (git log of origin/012-other failed (git exited 128))`, while `diff-failed` prints `(git diff of main...origin/012-other failed, git exited 128)`. Correct, merely inconsistent. Only E11 (injection) exercised the first string, no fixture does (exempt).
*Action: none; optional to align the two details.*

### F5 — Notes mislead on line endings and diff size — DOC DRIFT

notes.md says the working copy was CRLF and was normalised so "the commit diff is the 21 lines of the change". In the repository both the parent and the new blob are LF (0 CR bytes in each), the stat shows 24 changed lines (`24 +++++++-----`), and nothing in the repo depends on the file's bytes (manifest has no hash; verify-kit lists only the path). No behavioural issue.
*Action: none or correct the figure in notes.md.*

### F6 — notes.md Amendment 3 paragraph contradicts itself — DOC DRIFT

notes.md (phase 4, "Resolved by Amendment 3 (approved by anas.m, 2026-10-16)") continues "the author cannot approve that exemption: it needs the owner's approval as a short Amendment 3". The approval is recorded in plan.md and tasks.md in `9324f8f`, so the sentence reads as pending when it is resolved.
*Action: implementer tidies the sentence when notes.md is next edited.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly: **none** in phase commit `56ee63b` (tasks.md changes there are tick-boxes T020-T025 only; T026 left unticked, correct). Amendment 3 (G13b injection-guarded, approver anas.m, 2026-10-16) arrived in the following docs commit `9324f8f`, recorded by the owner, not self-approved.

## Constitution re-check (post-implementation)

PASS. Principles satisfied: the check stays within its own vocabulary (D6); evidence-based exemptions are approved by the owner (Amendments 1-3); no new package, architecture or exit code. Nuance: the plan said four reads get fixtures where reachable; TERR-023 and TERR-025 do, TERR-024 and TERR-026 are exempt with written reasons.

## Test coverage observed

Run in a detached worktree at `56ee63b` with `Run-Tests.ps1 -Case <family>` (passed / failed): TERR- 208/0, RIT- 264/0, REPOS- 204/0, SCOPE- 310/0, ROADMAP- 170/0, GITREAD- 78/0, DIFF- 86/0, AMEND- 288/0, CRIT- 228/0, LITE- 122/0, PACK- 78/0. The TERR- count equals the 208 the notes report. Mutations: U1 and U2 re-run and caught (above); parent-script control fails the new fixtures and the coverage tests (TERR-023: 4 failed; TERR-025: 3 failed). `verify-kit.ps1`: not applicable (kit template, exit 0). `ritual-checks.ps1`: see the Scope guard row. Full harness not run (one is running elsewhere).

## Residual risk

Low. The only unproven statements are F3 (code repositories compared after a governance diff failure) and the injection-only guards for G13b/G14a (E10/E11 not re-run by me). No blocking item; merge after the owner's gate run and a scope-check PASS on the named branch.
