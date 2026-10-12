# AI Code Review — 023 claim-feature.ps1's refusals reach their own message and exit (phase 1)

**Reviewer**: fresh-context agent — claude-opus-5-5
**Date**: 2026-10-12
**Branches**: agentic-sdlc-kit `023-claim-feature-refusals` (tip `d10a37a`)
**Scope reviewed**: commit `d10a37a` in full (`git show d10a37a`, 49 files). I read `scripts/claim-feature.ps1` whole and
diffed it against `git show d10a37a^:scripts/claim-feature.ps1`. I read the normaliser change in
`tests/enforcement/lib/Harness.psm1` with the rest of that module, and the two new self-tests in `Harness.Tests.ps1`. I read
all 14 cases under `tests/enforcement/cases/claim-feature/` (`recipe.json`, `command.json`, `expected.txt`) and diffed each
pair's recipe and command. I also read the seven `rules.json` entries, the `claim-feature.ps1` entry of
`emission-idioms.json`, the `Coverage.Tests.ps1` list change and `notes.md` (Phase 1). For context I read
`tests/enforcement/lib/FixtureRepo.psm1` (`New-FixtureRepo`: `noGit`, `origin`, `nestedRepos`, `write`),
`tests/enforcement/lib/RunChild.ps1`, the recall sweep in `Coverage.Tests.ps1`, `scripts/territory-check.ps1`'s
`Stop-Refused`, and the CI matrix (`.github/workflows/enforcement-tests.yml`: ubuntu-latest and windows-latest). I graded
against `spec.md` (US1, US2, FR-001 to FR-006, SC-002 to SC-004, Edge Cases), `plan.md` (D1 to D5, Testing Strategy,
Risks) and `tasks.md` (Phase 1, T001 to T005, Territory).
**Feature contract**: the seven refusals keep their wording and reach exit 1 by the script's own hand (FR-001). A
successful claim prints the same bytes (FR-002). Nothing else in the script changes (FR-006). Six reachable sites are
fixtured, and site 135 is exempt with a written reason (D2, FR-004). The script joins the coverage sweep (FR-005). There
is no new script, library, package or recipe field. Territory is `scripts/claim-feature.ps1` and `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: claude-sonnet-5-5 (Claude Code session)
- **Inputs provided**: the phase 1 commit d10a37a diff, spec.md, plan.md, tasks.md, notes.md
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — The script change is correct. `Stop-Refused` (stderr, then `exit 1`) replaces all seven
`Write-Error ...; exit 1` sites. The seven message literals are byte-identical to the parent's, including the em dashes,
the interpolations and the embedded `` `n `` of sites 79 and 112. No other line of the script changed. I verified it
several ways:

- **Parent against new.** I ran both scripts under `pwsh -File` on fixtures built from the 14 recipes. Every refusal
  exits 1 on both. The new stderr is exactly the message.
- **Successful claims.** The three successful claims (no origin, an origin that takes the push, `-NoPush`) print
  identical stdout and stderr.
- **The race.** A forced three-times-lost race withdraws the remote branch before the refusal, on both scripts.
- **The cases on the parent.** The new cases run on the parent fail exactly as `notes.md` says: 128, 97, 97, 97, 128,
  97, and the leaked 1 for `CLF-006`.
- **Mutations.** The two mutations each turn their cases red.

The change is not mergeable as committed because the exempt rule `CLF-007` rests on a premise that is false. Plan D2,
the `rules.json` exemption and the `emission-idioms.json` reason for the race warning all say site 135 needs a rival
claim to appear on origin between allocation and the check. It does not. Any push that fails does the same, because
the loop treats `-not $pushOk` as a lost race. I reached site 135 deterministically with one `git config
remote.origin.pushurl <missing path>` on the `CLF-004/pass` fixture (F1). The owner approved D2 on that premise, so
the owner has to decide again between fixturing the site and rewording the exemption. Either way, the inventory must
not ship a false reason.

Three smaller findings:

- One pair differs in two conditions, against FR-003 (F2).
- The `notes.md` description of the out-of-spec `throw` understates where it can fire (F3).
- `CLF-007`'s summary and law cite the wrong outcome and FR (F4).

Two more observations need no action in this phase (F5, F6). The residual risk is in the inventory's honesty, not in
the script.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | **FR-001, wording.** I extracted each `Write-Error <literal>` from the parent and each `Stop-Refused <literal>` from the new script with the same regex, and `diff` printed nothing for all 7 lines: byte-identical, `—`, `$currentBranch`, `$createScript`, `$MaxAttempts`, `` `n$($dirty -join "`n") `` and `` `n$createOut `` included. **FR-001, exit.** I ran my own probe (`pwsh -File`, working directory = fixture built by `New-FixtureRepo` from each fail recipe), parent then new. All 7 refusals (6 sites plus `-Json`) exit 1 on both. Parent stderr is the coloured error record (`Line \|`, caret rule, the message flattened onto one line). New stderr is the message alone, with site 79's dirty path and site 112's stub output on their own lines. **`exit` inside the function.** In-process (`Push-Location <fixture>/sub; & claim-feature.ps1`), `CLF-001/fail` (before `Push-Location`), `CLF-003/fail` and `CLF-006/fail` (inside `try { } finally { Pop-Location }`) all leave `$LASTEXITCODE` 1 and the caller's location unchanged, so `finally` ran. **Site 135 inside the for-loop.** I made temp copies of both scripts with `$rivals` forced to `@("$numPrefix-rival")` and ran them on the `CLF-004/pass` fixture. Both print three renumber warnings and the lost-race message and exit 1. The nested origin's heads are `[main]` afterwards, so `git push origin --delete` ran before `Stop-Refused` on every attempt (Edge Case 3 holds). **FR-002.** The `CLF-001/pass`, `CLF-004/pass` and `CLF-004/pass-nopush` runs give `stdout identical=True; stderr identical=True` parent against new. Under `-Json` (no origin, and origin) the objects differ only in the fixture's temp directory name. **FR-006.** `diff` of the two scripts with the `Write-Error`/`Stop-Refused` lines removed shows only the added function plus comment and the four removed `exit 1` lines. **FR-003.** 6 fail/pass pairs, plus `fail-json` and `pass-nopush`. Each fail reaches its own refusal (the observed message in each case) and not a neighbour. `CLF-004/fail` reaches the fetch message, not the ls-remote `throw`. `CLF-006/fail` passes sites 72 to 108 (its output carries `WARNING` and `Allocating`). One pair is not single-condition (F2). **FR-004.** Exempt, but on a false premise (F1). **FR-005.** The coverage report lists `claim-feature.ps1 6 of 10 site(s) fixtured (1 exempt, 3 not a rule)`. |
| Visual-reference match (where references exist): Visual Compliance Loop deviation table attached, empty or user-approved (`docs/sdlc/review-process.md`) | Not applicable: no UI, no visual references. |
| Feature contract held (no unapproved table/migration/permission/package) | No package and no new script or library. One harness behaviour was added that the plan did not foresee: the `<ROOT>` path-separator substitution in `ConvertTo-NormalisedOutput`. `notes.md` discloses it as deviation 1, it lies inside `tests/**` and it is self-tested. The `write`-instead-of-`copy` stubs and the nested origin (deviations 2 and 3) use existing recipe fields. |
| Constitution / domain invariants | I: no spec, plan or tasks change (see Amendments). VIII: expectations are hand-written and match the spec's pinned wording (US1 scenarios 1 to 7). Fail cases were shown failing on the parent (re-run by me). One pair is not single-condition (F2). One exemption reason is false (F1). X: one phase, subject `phase 1`, owner-run gate. No domain-invariants pack. |
| Security (authn/authz, secrets, sensitive logging) | The refusal output no longer prints the kit's script path or source excerpt (less disclosure). The stubs run only inside the fixture. The nested `origin.git` lies inside the fixture's temp directory, so pushes never leave it. No secrets. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | `pwsh -File scripts/scope-check.ps1 -Commit d10a37a`: `scope-check: PASS phase 1 commit d10a37a (49 file(s))`, exit 0. `git show --name-only` minus `tests/**` and `scripts/claim-feature.ps1` leaves only `specs/023-claim-feature-refusals/notes.md`. |
| Rollback safety (phase reverts cleanly; schema additive?) | `git revert d10a37a` restores the seven `Write-Error` sites and removes the cases, rules, idiom entry, coverage-list entry and normaliser line together. That is the parent state, measured green at 1373 by `notes.md` T001. The normaliser line is symmetric (below), so reverting it cannot move a pre-existing case. No schema. |

## Findings

### F1 — `CLF-007`'s exemption (plan D2) rests on a false premise: site 135 is reachable by a fixture whose push fails — BLOCKING

The `rules.json` exemption says: "A claim loses the allocation race three times only if, after each of three pushes,
a rival claim with the same number is on origin … the rival has to appear between allocation and the check … The
recipe cannot build that". The `emission-idioms.json` reason for `was claimed concurrently` and plan D2 say the same.
The loop says otherwise:

```powershell
if ($pushOk -and $rivals.Count -eq 0) { $pushed = $true; break }
# Lost the race. ...
```

A **failed push** with no rival takes the lost-race path on every attempt. I measured it on the `CLF-004/pass` fixture
plus one line, `git config remote.origin.pushurl <fixture>/no-such-push-target`. `git fetch` and `git ls-remote` still
read `origin.git`, and the tree stays clean. The new script then printed three `WARNING: Number NNN was claimed
concurrently () - renumbering.` lines, `Renumbered:` twice, and `Lost the allocation race 3 times — renumber manually
(...)`, then exited 1, with origin heads `[main]`. Nothing is racy, nothing is hook-based, and nothing is
platform-specific. The fixture needs one recipe field shaped like the existing `originFetch` (for example
`originPushUrl`), and the pair is `CLF-004/pass` with and without it.

The exemption therefore records something false in the inventory. Feature 015 FR-004 asks for a reason, and this
kit's own exemptions are justified as "exempted rather than faked". The owner approved D2 on this reasoning, so the
decision is the owner's again; the reviewer cannot pick the remedy.
*Action: owner re-decides D2. Then the implementer does one of these in a phase 1 remediation commit:*

- *(a) Add an `originPushUrl` recipe field to `FixtureRepo.psm1`, with a self-test, and a `CLF-007` fail/pass pair. The
  fail expects the three warnings, the two `Renumbered:` lines and the message, exit 1. The pass is `CLF-004/pass`.
  Remove the exemption (exempt count back to 3), and reword the race-warning not-a-rule reason to "asserted by
  CLF-007/fail". This is a plan amendment (a new recipe field), recorded with the owner's approval.*
- *(b) Keep the exemption and rewrite the reason and the not-a-rule reason truthfully: reachable by a failing push,
  not fixtured because no recipe field sets a push URL and the plan forbids a new one.*

*Either way, `notes.md` records the correction.*

### F2 — `CLF-003/pass` drops the `feature-x` branch, so the pair differs in two conditions, not one — MINOR

`CLF-003/fail` builds `main` plus a `feature-x` commit and checks out `feature-x`. `CLF-003/pass` builds `main` only and
checks out `main` (`diff` of the recipes: the whole `feature-x` commit is missing as well as the `checkout` value). Its
description says "the same two branches with HEAD on main", which is untrue, and FR-003 / plan D4 require the pair to
differ "only in the condition under test". The fix does not change the expectation. I copied the fail recipe, changed
only `"checkout"` to `"main"`, and ran it through `Invoke-FixtureCase` with the pass `command.json` and `expected.txt`:
output match True, exit match True. Allocation stays `001` because `feature-x` carries no number.
*Action: implementer adds the `feature-x` commit to `CLF-003/pass/recipe.json` (keeping `"checkout": "main"`) in the
remediation commit and re-runs `-Case CLF-003`.*

### F3 — `notes.md` understates where the unconverted `throw` (line 47) can fire — MINOR

`notes.md` says the `throw "git ls-remote failed …"` in `Get-RemoteFeatureHeads` "is reachable only when `git
ls-remote` fails right after a successful `git fetch`". The function has three callers: after the first fetch (`:105`),
**after every push** (`:132`, the rival check), and after the in-loop re-fetch (`:144`). In the `:132` case a push that
succeeded has already made the claim live on origin. The script then dies through PowerShell's error path, so a
wrapper sees a failure for a claim that was in fact taken. That is the very misreading US1's priority note warns about.

The other claims hold:

- The recall sweep cannot see it. `throw` matches no `CandidateSweep` pattern (`Coverage.Tests.ps1:67-76`), and the
  sweep reported 10 sites for the script, none at `:47`.
- Leaving it unconverted is consistent with FR-001 (seven named sites) and FR-006 (no other behaviour change).
- The owner's go-ahead to record rather than widen is quoted.

*Action: implementer corrects the `notes.md` sentence to name the post-push caller and its consequence, so the
phase 2 decisions-log entry carries the accurate risk. No code change in this feature.*

### F4 — `CLF-007`'s summary says "rather than left half made", and its law cites FR-003; it is left half made, and the FR is FR-004 — MINOR

In both the forced-rival run and the push-failure run, the refusal leaves the local branch `003-probe` checked out,
with its `specs/003-probe/` directory, after renumbering twice. Only the remote branch is withdrawn. The summary
therefore describes a guarantee the script does not give. The `law` field copies `FR-001, FR-003` from the fixtured
rules, but the exemption is governed by FR-004.
*Action: implementer rewords the summary (for example "… is refused, with the remote claim withdrawn, rather than
pushed under a contested number") and sets the law to `FR-001, FR-004`, in the same commit as F1.*

### F5 — A failed push is reported as a lost race and burns three numbers — MINOR

The F1 probe also shows pre-existing behaviour that is out of this feature's scope (FR-006). An authentication or
network failure on `git push` is reported as `Number NNN was claimed concurrently ()`, with an empty rival list. The
script renumbers three times and ends with "Lost the allocation race 3 times". The message misdiagnoses the cause.
*Action: none in this feature (FR-006). Implementer records it in `notes.md` as a candidate roadmap gap, next to the
line-47 `throw`, for the phase 2 decisions-log entry.*

### F6 — The refusal reaches the process's stderr, not PowerShell stream 2 — MINOR

This is the same property as feature 022 phase 2's F5, now in a second script. In-process, `& claim-feature.ps1
2>$null` still printed `Claims start from main ...` and `Not inside a git repository.` in my probe. `pwsh -File`
callers, the harness and CI are unaffected. Plan D3 and D1 chose this deliberately ("a copy", "error stream").
*Action: none. The owner's answer to 022 F5 applies here too.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None.** `git show d10a37a --name-only` lists no `spec.md`, `plan.md`, `tasks.md` or `contracts/` file. The only file
under `specs/` is `notes.md`, an evidence record. The T001 to T005 checkboxes stay unticked, as in feature 022; that is
not an amendment. Plan departures (the normaliser line, the nested origin, `write` instead of `copy`, 14 cases instead
of 12) are disclosed in `notes.md` as deviations and not written into the plan. Note that F1, remedy (a), would be an
amendment and needs the owner's recorded approval.

## Constitution re-check (post-implementation)

**FAIL on VIII until F1 is resolved; PASS otherwise.**

- **I.** The implementation follows D1 (a copy of `Stop-Refused`, byte-identical to `territory-check.ps1:61-65`), D3,
  D4 and D5. D2 is implemented as approved, but its premise is false (F1).
- **II.** No conflict between rungs.
- **IV.** No new file outside `tests/**`, and `claim-feature.ps1` stays standalone. The accumulator
  `Stop-Refused\s+['"]` matches lines 82, 89, 93, 104, 116, 119 and 142 and not `function Stop-Refused {` (line 75).
  `Write-Warning\s` matches 107, 139 and 155. Each of the ten anchors occurs exactly once in the script (`grep -cF`).
- **VI.** Less output on refusal.
- **VIII.** Hand-written pairs, shown failing on the parent. However:
  - one exemption reason is false (F1);
  - one pair is not single-condition (F2).

  The notRules for `No origin remote configured` and `Push skipped (-NoPush)` are true. `CLF-001/pass` (and four other
  pass cases) assert the first line verbatim, and `CLF-004/pass-nopush` asserts the second.
- **IX.** This review, then human review.
- **X.** One phase, owner-run gate, scope check PASS.

## Test coverage observed

- **`-Case CLF-` in the main tree.** `pwsh -NoProfile -File tests/enforcement/Run-Tests.ps1 -Case CLF-`: 14 cases, **67
  passed, 0 failed**, `enforcement-tests: OK`. Coverage prints `241 of 254 … 4 exempt, 9 declared not a rule, across 10
  grading script(s)` and `claim-feature.ps1 6 of 10 site(s) fixtured (1 exempt, 3 not a rule)`. This matches
  `notes.md` T005, and the parent's 235/244, 3 exempt, 6 not a rule, 9 scripts reconcile (+6 fixtured, +1 exempt, +3
  not a rule = +10 sites).
- **Parent worktree.** Detached worktree of `3fa9b45` in my scratchpad with `tests/` from `d10a37a`, removed afterwards;
  `-Case CLF-` gives 53 passed, 14 failed:

  | Case | Exit on the parent |
  |---|---|
  | `CLF-001/fail` | 128 |
  | `CLF-002/fail` | 97 |
  | `CLF-003/fail` and `fail-json` | 97 |
  | `CLF-004/fail` | 128 |
  | `CLF-005/fail` | 97 |
  | `CLF-006/fail` | output check only (exit 1, leaked from the stub) |

  Each fail case prints the launcher's `RunChild: … threw …` line. The coverage anchor test also fails there,
  because the parent has no `Stop-Refused` call sites. All 8 pass cases are green. This confirms `notes.md` T002 row
  by row.
- **Mutations (temp worktree of `d10a37a`, never the main tree):**
  - (1) Site 112 reverted to `Write-Error …; exit 1`: `CLF-006/fail` goes red on output (exit still 1 by leakage), and
    the coverage anchor test goes red.
  - (2) `exit 1` dropped from `Stop-Refused`: all seven fail cases go red, and the pass cases stay green.
    - `CLF-001`: 128.
    - `CLF-002` and `-003`: exit 0, with the claim then made.
    - `CLF-004`: the script falls through to the ls-remote `throw`.
    - `CLF-005`: 97.
    - `CLF-006`: output only.
  - (3) The normaliser line removed: the 7 pass cases and `CLF-005/fail` go red on Windows (`SPEC_FILE:
    <ROOT>\specs\001-probe\spec.md`), and the self-test "writes a path under the repository with forward slashes" goes
    red. The substitution is load-bearing and self-tested.
- **Normaliser, pre-existing expectations.** The substitution runs on both the expectation and the output, so two texts
  that were equal stay equal: no passing case can turn red, and the change can only widen. No pre-existing
  `expected.txt` has `<ROOT>` followed by a backslash. The distinct tokens are 50 × bare `<ROOT>` (doc-lint),
  `<ROOT>/no-such-directory` (`VK-025`) and `<ROOT>)` (`REPOS-013`). I ran `-Case doc-lint/` (139 passed),
  `-Case scope-check-repos/REPOS-013` (43 passed) and `-Case verify-kit/VK-025` (43 passed), all OK. The regex
  `<ROOT>[^\s'"`]*` stops at whitespace and quotes, so a later path with a space would be half-normalised; no case has
  one.
- **Windows 8.3 temp path (the windows-latest runner's `%TEMP%` is a short name).** This is the first family of `noRoot`
  cases that prints a git-derived repository path. With `TMP`/`TEMP` set to an 8.3 alias (`LONGDI~1`),
  `[IO.Path]::GetTempPath()` already returns the long form, and `CLF-001/pass` passed. Not a risk.
- **Linux portability (reasoned, not run).**
  - The stubs run in-process through `&`, so the executable bit is irrelevant.
  - `Write-FixtureFile` writes LF and `core.autocrlf=false`.
  - `git init -b main` is explicit, so `init.defaultBranch` is irrelevant.
  - Pushing a new branch into a non-bare repository whose checked-out branch is `main` is permitted
    (`receive.denyCurrentBranch` guards only the checked-out ref).
  - `/origin.git/` and `.specify/scripts/powershell/create-new-feature.ps1` are spelled identically everywhere, so case
    sensitivity is safe.
  - `CLF-001/fail`'s `noGit` has the same temp-inside-a-work-tree precondition as `TERR-008` (022 phase 2 F6). It is no
    new exposure, and CI runner temp directories are outside the checkout.

  The ubuntu leg has not run this commit. `notes.md` says so.
- **Full harness.** Run on a clean detached worktree of `d10a37a` in my scratchpad (removed afterwards): **1403 passed, 0
  failed, 0 skipped**, `enforcement-tests: OK`, and coverage `241 of 254 … 4 exempt, 9 declared not a rule, across 10
  grading script(s)`. This confirms `notes.md` T005 (1373 + 14 cases × 2 + 2 self-tests = 1403). I did not re-run
  `ritual-checks.ps1`.

## Residual risk

The script change is low-risk. Seven call-site substitutions and a five-line function were verified for wording, exit,
location restoration, race withdrawal and successful-claim bytes. The risk sits elsewhere:

- **Inventory honesty (F1, F4).** An exemption whose stated reason is false, approved by the owner on that reason. This
  blocks merge until the owner re-decides D2 and the text, or a fixture, is corrected.
- **Fixture discipline (F2).** A one-commit fix with no expectation change.
- **Recorded-not-fixed (F3, F5).** The line-47 `throw` can fire after a live push, and a push failure is misreported
  as a lost race. Both are out of scope by FR-006, and both must reach the phase 2 decisions-log entry accurately.
- **Platform.** The ubuntu CI leg is the first run of the nested-origin push and the normaliser line on Linux. I found
  no reason for it to fail, but it has not been observed.

Merge after F1 is decided and remediated, F2 to F4 are fixed in the same remediation commit, `-Case CLF-` and the full
harness are re-run, the owner runs the gate and confirms the exit code, and the human review is complete.
