# AI Code Review — 022 Verdicts that say what was compared (phase 2)

**Reviewer**: fresh-context agent — claude-opus-5-5
**Date**: 2026-10-12
**Branches**: agentic-sdlc-kit `022-verdict-honesty-repos-territory` (tip `6c3c27f`)
**Scope reviewed**: commit `6c3c27f` in full (`git show 6c3c27f`). That covers `scripts/territory-check.ps1`, which I read whole
and not only the hunks, and diffed against `git show 6c3c27f^:scripts/territory-check.ps1`. It also covers the
`noGit` block and header entry in `tests/enforcement/lib/FixtureRepo.psm1`, read together with `New-FixtureRepo` and
`Remove-FixtureRepo` in full, and the two `noGit` self-tests in `tests/enforcement/Harness.Tests.ps1`. The other files
in the commit are the README paragraph, the eight `TERR-008` to `TERR-011` cases (`recipe.json`, `command.json`,
`expected.txt`, each pair's recipes diffed), the four `rules.json` entries, the `territory-check.ps1` entry of
`emission-idioms.json` and `notes.md` (Phase 2). For context I read how the harness invokes a script
(`tests/enforcement/lib/Harness.psm1`, `noRoot` and the process launch) and `tests/enforcement/lib/RunChild.ps1`.
I graded against `spec.md` (US3, FR-006 to FR-008, SC-001, SC-002), `plan.md` (D6, D7, D8, Testing Strategy, Risks)
and `tasks.md` (Phase 2, T006 to T011 and the Territory block).
**Feature contract**: the four refusals keep their wording byte for byte and reach exit 1 by the script's own hand
(FR-006). Nothing else in `territory-check.ps1` changes (FR-007, SC-001). The only harness change is the `noGit` recipe
field (D7). There is no new script, library or package. Territory is `scripts/territory-check.ps1` and `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: claude-sonnet-5-5 (Claude Code session)
- **Inputs provided**: the phase 2 commit 6c3c27f diff, spec.md, plan.md, tasks.md, notes.md
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups** — The phase does what FR-006 and FR-007 ask. `Stop-Refused` writes the unchanged message
to the process's stderr and calls `exit 1`, and the four former `Write-Error ...; exit 1` sites call it. All four
message strings are byte-identical to the parent's, including the em dashes and the interpolated
`$Branch` / `$BaseBranch` / `$ownRef`. The 14 insertions and 5 deletions touch nothing else.

I checked this three ways:

- **Parent against new, side by side.** I ran both scripts under `pwsh -File` and in-process on every recipe built
  from `FixtureRepo.psm1`.
- **The new cases against the parent script.** I ran them through the real harness on a temp worktree of `3ed189e`
  carrying the new `tests/**`. All four `fail` cases fail there. Exits are 128, 97, 128 and 128, exactly as
  `notes.md` records.
- **A mutation.** With `exit 1` dropped from `Stop-Refused`, the `TERR-010` and `TERR-011` fail cases go red and
  print `CLEAN`.

`-Case TERR-` passes 175/0 in the main tree, and coverage reports 3 exempt and `territory-check.ps1` 22 of 23. The
findings are small:

- The rewritten `emission-idioms.json` note re-asserts a site count that is false (F1).
- The `noGit` refusal self-test leaks two temporary repositories on every run, because the refusal fires only after
  the fixture is built (F2).
- One fixture description repeats the exit-97 premise that `notes.md` itself corrected (F3).
- A plan Risk says the identical `claim-feature.ps1` defect is "recorded in `notes.md`", and it is not (F4).
- The new stream is the process's stderr and not PowerShell's error stream, which changes what an in-process caller
  can redirect (F5, confirm).
- `TERR-008`'s fixture can escape into an enclosing repository if the OS temp directory sits inside one (F6).

None of these changes a verdict. The residual risk is in documentation accuracy and harness hygiene, not in the script.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | **FR-006, wording.** I extracted the message argument from each `-`/`+` line of `git diff 6c3c27f^ 6c3c27f -- scripts/territory-check.ps1`. Each of the four strings occurs exactly twice (once removed, once added) under `uniq -c`, so they are byte-identical, quotes and interpolation included. **FR-006, exit.** The fail recipes run under `pwsh -File` from the fixture directory. **Parent:** exit 1 in all four cases, stderr carrying the full error record (`Write-Error: <abs path>:58`, a `Line \|` excerpt, a caret rule, then the message). **New:** exit 1, and stderr is exactly the one message line. Under the harness, the parent exits 128 (`TERR-008`, `-010`, `-011`) or 97 (`-009`) and the launcher prints its `RunChild: the script under test threw...` line. The new script exits 1. **`exit` inside the function.** `TERR-008` exits before `Push-Location`. The other three exit inside `try { } finally { Pop-Location }`. In-process (`Push-Location <fixture>/src; & territory-check.ps1`) all four leave `$LASTEXITCODE` 1 with the caller's location unchanged, so `finally` ran and the location was restored. **Other terminating sites (US3 scope).** `grep Write-Error\|throw\|exit` over the script and its two dot-sourced libraries finds no `Write-Error` and no `throw`. The remaining exits are `exit 0` (no remote, `:85`) and the final `exit 2/0` (`:303`). The only other diagnostic is `Write-Warning` (`:222`, TERR-012), which does not terminate under `Stop`. FR-006's four sites are therefore the complete set. **FR-007.** Each pair's recipes differ only in the condition plus the `description` string. `TERR-008` differs by `noGit: true`. `-009` differs by `checkout` (`main` against `011-thing`). `-010` differs by `origin` (`no-such-origin` against `self`). `-011` differs by `defaultBranch` and the first commit's branch (`master` against `main`), which is one condition, the trunk's name. Each `fail` hits its own refusal and not a neighbour: `-011` printed `Cannot diff main...HEAD`, so the fetch succeeded and it was not stopped at `-010`, and `-009` printed `Branch 'main'`. All four `pass` cases print `CLEAN — '011-thing' ...`, exit 0, on both parent and new. |
| Visual-reference match (where references exist): Visual Compliance Loop deviation table attached, empty or user-approved (`docs/sdlc/review-process.md`) | Not applicable: no UI, no visual references. |
| Feature contract held (no unapproved table/migration/permission/package) | Not touched: no package, no new script or library file. `ritual-checks.ps1` and every other `scripts/` file outside the one named are untouched (`git show --name-only` lists `scripts/territory-check.ps1`, `notes.md` and 29 files under `tests/`). Only one harness capability was added: `noGit`. The `noRoot` command flag already existed, so `Harness.psm1` and `RunChild.ps1` are unchanged. |
| Constitution / domain invariants | I: no spec, plan or tasks change (see Amendments). VIII: the expectations are hand-written one-liners that match the spec's pinned messages. The fail cases are shown failing on the parent (my run, above), and every new rule has a pair. X: one phase, subject `phase 2`. No domain-invariants pack. |
| Security (authn/authz, secrets, sensitive logging) | Read-only script. The refusal output now omits the kit's absolute script path and source excerpt that the error record used to print, so it discloses less. The new `Remove-Item -LiteralPath (Join-Path $root '.git') -Recurse -Force` is confined to `$root`. `$root` is a fresh `kit-fixture-<guid>` under the OS temp directory, or the `-At` path inside an outer fixture for a nested recipe, so it cannot reach outside a fixture. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | `pwsh -File scripts/scope-check.ps1 -Commit 6c3c27f` printed `scope-check: PASS phase 2 commit 6c3c27f (31 file(s))`, exit 0. I read the stat for intent: every file is in `scripts/territory-check.ps1` or `tests/**`, apart from the feature's own `notes.md`, which the scope check accepts as feature evidence (as in phase 1). |
| Rollback safety (phase reverts cleanly; schema additive?) | `git revert 6c3c27f` restores the four `Write-Error` sites, the exemptions and the idiom together. That combination is green on the parent (1355 per `notes.md`). The new cases would leave with the revert. No schema. |

## Findings

### F1 — The rewritten `emission-idioms.json` note still says "Twelve sites"; the coverage report says 23 — DOC DRIFT

The commit rewrote the `territory-check.ps1` entry's `note`. The sentence now reads "Twelve sites: five prose
verdicts, two JSON emitters, four refusals and one Write-Warning (TERR-012)". Twelve was the T034 count. Since
feature 018 the entry's own `accumulators` also list `Add-Ungraded` and `$notes +=`, and the coverage report in this
same run prints `coverage: territory-check.ps1 22 of 23 site(s) fixtured (1 not a rule)`. The number was stale before
this phase. This phase edited the sentence to make it current and kept the number, so it now states something false
in the paragraph the phase owns. The rest of the rewritten paragraph is accurate: the exit 97 or leaked git exit code
is measured above, the record carried the absolute path and caret rule (seen in the parent's stderr), and
`Stop-Refused` exits 1.
*Action: implementer changes the count, for example "Twenty-three sites (as the coverage report counts them): the
original twelve ... plus the Add-Ungraded and notes accumulators of feature 018". Alternatively, drop the number in a
phase 2 remediation commit and re-run `-Case TERR-` (no expectation changes).*

### F2 — The `noGit` refusal fires after the fixture is built, so the self-test leaks two temporary repositories per run — MINOR

In `New-FixtureRepo`, the `noGit`-versus-`shallow`/`nestedRepos` check sits after the repository has been built,
and for `shallow` after the clone has been made and `$root` reassigned. The throw therefore leaves a complete
`kit-fixture-*` repository behind, and the caller never receives a path it could remove. The self-test's cleanup
cannot help: `{ $root = New-FixtureRepo ... }` assigns inside the `Should -Throw` scriptblock's own scope, so the outer
`$root` stays `$null` and `if ($root) { Remove-FixtureRepo ... }` never runs. I measured it with `Invoke-Pester
-FullNameFilter '*noGit*'` and a before/after listing of `kit-fixture-*` in the temp directory. The tests passed
(2/0), and two new directories remained (`.git` + `a.txt`): one from the `nestedRepos` refusal and one from the
`shallow` clone. I removed them. The existing nested-`shallow` refusal in the same function runs before anything is
built (`-At` branch, top of the function), which is the pattern to follow.
*Action: implementer moves the `noGit` incompatibility check to the top of `New-FixtureRepo`, before `git init`, and
keeps the `.git` removal where it is. Then re-run the two self-tests and confirm that no `kit-fixture-*` directory
remains.*

### F3 — `TERR-008/fail/recipe.json` says the refusal "used to die in the launcher's exit 97"; it was 128 — MINOR

`notes.md` (T008) measured, and corrected the plan on this point: only `TERR-009` exited 97 on the parent, and
`TERR-008`, `-010` and `-011` exited 128, the leaked `git` exit code. I reproduced the same four codes through the
harness on the parent worktree. The `TERR-008` fail recipe's `description` still carries the uncorrected premise.
That description is the documentation a future reader of the case sees first.
*Action: implementer replaces "the launcher's exit 97" with "exit 128, the last git call's code leaking through the
launcher" in the same remediation commit as F1.*

### F4 — Plan Risk "claim-feature.ps1 has the same defect … recorded in `notes.md`" is not recorded — MINOR

Under Risks, `plan.md` says the same `Write-Error`-then-`exit 1` defect in `scripts/claim-feature.ps1` (`:72`, `:79`,
`:84`, `:96`, `:108`) "is recorded in `notes.md` as a candidate roadmap gap, not fixed here". `grep claim-feature`
over `notes.md` and `docs/roadmap.md` finds nothing. The defect is real: the current file still has `Write-Error`
at those lines and at `:112` and `:135`, seven sites, two more than the plan lists. Phase 2 is the phase that
measured this defect class, so its notes are the natural place for the record. It is not a phase 2 task by name,
though, so phase 3 (which owns `docs/roadmap.md`) could take it instead.
*Action: implementer records the seven `claim-feature.ps1` sites in `notes.md` as a candidate GAP now, or in phase 3
alongside the roadmap edits. The owner decides which; it must not be dropped.*

### F5 — "Error stream" is the process's stderr, not PowerShell's error stream; in-process redirection no longer reaches the message — CONFIRM

`[Console]::Error.WriteLine` writes past the PowerShell pipeline. I measured this in-process (`& territory-check.ps1
2>$null` from a pwsh session): the message still printed to the console. Under the parent, `2>$null`, `2>&1` and
`-ErrorVariable` could catch or silence the error record. Under `pwsh -File`, the way the kit, CI and the harness
call the script, there is no difference: the text arrives on stderr either way, and the harness passes. Plan D6
chose `[Console]::Error.WriteLine` explicitly and the owner approved it, so this is not a defect against the plan.
But the plan, the script comment ("says why on the error stream") and the `emission-idioms.json` note all say "error
stream", which a PowerShell reader takes to mean stream 2. No kit script calls `territory-check.ps1` in-process (grep
over `scripts/`).
*Action: owner confirms that the `pwsh -File` contract is the only one the kit promises. If so, optionally have the
script comment say "stderr (the process's, not PowerShell stream 2)". No code change is needed.*

### F6 — `TERR-008/fail` depends on the OS temp directory not being inside a git work tree — MINOR

`noGit` removes `.git`, and `territory-check.ps1` then runs `git rev-parse --show-toplevel` from the fixture
directory. If any ancestor of `[IO.Path]::GetTempPath()` is a work tree, git walks up and finds it. That happens with
a dotfiles repository in `$HOME` and `TMPDIR` under `$HOME`, or with Windows `%TEMP%` under a profile that is a
repository. In that case the case reads the enclosing repository. The plan's Risks section accepts this because the
case "fails loudly". That holds for the verdict. If the enclosing repository is on an `NNN-` branch with an `origin`,
though, the script also runs `git fetch origin --prune` against it, a side effect on a repository outside the
fixture (feature 015 FR-020 spirit). Here `%TEMP%` is not in a repository (`git -C $TEMP rev-parse` printed `fatal:
not a git repository`). Both CI legs use runner temp directories outside the checkout, so CI is not affected.
*Action: none required for merge. Optional hardening: `Harness.psm1` sets `GIT_CEILING_DIRECTORIES` to the fixture's
parent for `noRoot` cases (one line in the child's environment), or the `noGit` self-test asserts the precondition
with a message naming it. The owner decides.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None.** `git show 6c3c27f --stat -- specs/022-verdict-honesty-repos-territory/spec.md .../plan.md .../tasks.md`
lists no file. The only file under `specs/` is `notes.md`, an evidence record. The T006 to T011 checkboxes in
`tasks.md` remain unticked, as in phase 1. That is not an amendment.

## Constitution re-check (post-implementation)

PASS.

- **I.** The code follows D6 to D8 as approved, and the phase changed no governing document. One recorded deviation
  is disclosed in `notes.md` rather than written into the plan: the plan's "exit 97" premise held for one refusal
  out of four. That is the right way to handle it.
- **II.** No conflict between rungs.
- **IV.** No new file outside `tests/**`. The existing idiom/inventory structure is used, and the idiom was narrowed
  to call sites (`Stop-Refused\s+['"]`). I checked by hand that it matches `:68`, `:78`, `:88` and `:95` and not
  `function Stop-Refused {` at `:61`. The coverage test's "every anchor names exactly the emission sites" passes.
- **VI.** Less output: the absolute path is no longer printed.
- **VIII.** Hand-written pairs; the fail cases fail on the parent for the stated reason (independently reproduced).
  The `Write-Error\s` recall sweep in `Coverage.Tests.ps1:75` still catches any future `Write-Error` as
  UNCLASSIFIED, so removing the accumulator does not blind coverage.
- **IX.** This review, then human review.
- **X.** One phase, owner-run gate, scope check PASS.

## Test coverage observed

- `pwsh -NoProfile -File tests/enforcement/Run-Tests.ps1 -Case TERR-` in the main tree: 69 cases, **175 passed, 0
  failed**, `enforcement-tests: OK`. Coverage lines: `235 of 244 ... 3 exempt`, `territory-check.ps1 22 of 23
  site(s) fixtured (1 not a rule)`. "Exempted rule has no fixtures" and "every rule has a pair" both pass. This
  matches `notes.md` T011. The arithmetic (157 + 8 cases × 2 + 2 self-tests = 175) is consistent with the claimed
  full harness of 1373. I did not re-run the full harness or `ritual-checks.ps1`.
- Parent worktree (`3ed189e`, detached in my scratchpad, with `tests/` overlaid from `6c3c27f`, removed afterwards),
  `-Case TERR-008` / `TERR-009` / `TERR-01`:
  - `TERR-008/fail`: exit 128, `RunChild: ... threw ...: Not inside a git repository.`
  - `TERR-009/fail`: exit 97.
  - `TERR-010/fail`: exit 128.
  - `TERR-011/fail`: exit 128.
  - All four `pass` cases are green.

  This confirms `notes.md` T008 row by row.
- `pwsh -File` (purpose-built fixtures from the eight recipes, parent and new script): all four refusals exit 1 on
  both. Parent stderr is a full error record; new stderr is the bare message. This confirms the `notes.md` T006 claim
  that the parent already exited 1 at a terminal, and T011's "same message, same exit".
- Mutation (in the temp worktree, never the main tree): `exit 1` removed from `Stop-Refused`. `TERR-010/fail` and
  `TERR-011/fail` go red with exit 0 and `CLEAN`, and the `pass` cases stay green. The parent run above is in effect
  the "revert to Write-Error" mutation for all four sites.
- `noGit` self-tests (`Invoke-Pester -FullNameFilter '*noGit*'`): 2 passed. The first asserts that `a.txt` exists,
  `.git` does not, and `git rev-parse` fails, so a harness that ignored the field would fail on `.git`. The second
  asserts that both refusals throw with `'noGit' cannot be combined`, so a harness that ignored the refusal would fail
  `Should -Throw`. The leak is F2.
- Baseline 1355 / 157 / 7 exempt (`notes.md` T006): not re-run in full. The 7 → 3 exempt delta and the 157 → 175
  delta both reconcile with what I observed.

## Residual risk

Low. The script change is four call-site substitutions and an eight-line function. I verified it for wording, exit
code, location restoration and the absence of any other terminating site. The risk sits in three places:

- **Documentation accuracy (F1, F3).** A false site count, and a fixture description repeating a corrected premise.
  Fix both in a phase-2 remediation commit before the gate.
- **Harness hygiene (F2, F6).** Leaked temp repositories on every self-test run, and an environmental precondition
  for `TERR-008`. F2 is a cheap fix. For F6 the owner chooses.
- **Unrecorded sibling defect (F4).** `claim-feature.ps1` has the same defect in seven places. It must land in
  `notes.md` or the roadmap in this feature, as the plan says.

F5 needs the owner's confirmation only. Merge after F1 to F3 are remediated (or accepted by the owner), F4 is placed
in a phase, the owner runs the gate and confirms the exit code, and the human review is complete.
