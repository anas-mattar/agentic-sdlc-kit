# AI Code Review — 015 Enforcement Assurance (Phase 4, round 2)

**Reviewer**: fresh-context agent — claude-opus-5
**Date**: 2026-09-20
**Branches**: agentic-sdlc-kit `015-enforcement-assurance` (tip `317e7d3`)
**Scope reviewed**: commit `317e7d3` in full (`git show 317e7d3`, and `git diff 8778c06..317e7d3`
for the delta against the reviewed-at-round-1 state). Read line by line:
`tests/enforcement/lib/Harness.psm1` (the whole `Invoke-FixtureCase` launch block, +76/−40, and
the removal of `ConvertTo-ProcessArgument`), `tests/enforcement/Harness.Tests.ps1` (+98, both new
`It`s and the pre-existing `Invoke-Launcher` helper they depend on or avoid),
`tests/enforcement/emission-idioms.json` (all four changed declarations plus the unchanged
top-level `_comment`), `tests/enforcement/rules.json` (the three added entries `DOC-008`,
`DOC-009`, `VK-027`, and the `_comment` DIRECTIONS paragraph they invoke),
`specs/015-enforcement-assurance/notes.md` lines 1428–1676 (the whole new section) and
lines 1380–1427 (the phase 4 record it contradicts),
`specs/015-enforcement-assurance/tasks.md` (the amendment, diffed against `74f690e` rather than
against `8778c06` so the true text change is visible). All twelve new case files read in full
(`DOC-008`, `DOC-009`, `VK-027` × `pass`/`fail` × `command.json`/`expected.txt`/`recipe.json`).
Round 1 (`ai-code-review-phase-4.md`) read in full, including every action line, and each of its
nine findings checked for whether `317e7d3` addresses it. Kit scripts read as the graded subject:
`scripts/doc-lint.ps1` (the whole emission block, `:218–253`), `scripts/verify-kit.ps1` (every
emission line), `scripts/enforcement-pack.ps1` (`Invoke-AmendmentAuthorityCheck` `:1000–1100`, the
runner tail `:1183–1235`, and the failure message at `:1162`), `scripts/ritual-checks.ps1`,
`scripts/build-digests.ps1`, `scripts/scope-check.ps1`, `scripts/scope-check-repos.ps1`,
`scripts/territory-check.ps1`, `tests/enforcement/Coverage.Tests.ps1`,
`tests/enforcement/lib/RunChild.ps1`. Law read: `.specify/memory/constitution.md` (Principle I
including the Amendment-authority and Progress-is-not-amendment clauses, Principle X),
`docs/sdlc/definition-of-done.md`, `adoption/updating.md` §amendment, `specs/014-amendment-authority/plan.md`
D3c, `specs/015-enforcement-assurance/spec.md` / `plan.md` / `tasks.md`,
`specs/_templates/ai-code-review-template.md`.
**Independently run** (all on Windows 11 / pwsh 7.6.6 / Pester 5.7.1 unless stated): my own
emission sweep over all nine grading scripts against their declarations; `Coverage.Tests.ps1` in
isolation; `Run-Tests.ps1 -Case cases/doc-lint/DOC-008`, `-Case cases/doc-lint/DOC-009`, `-Case
cases/verify-kit/VK-027`; a mutation run with the UTF-8 pin deleted from `Harness.psm1`; a direct
byte probe of `Start-Process -RedirectStandardOutput` on Windows; two mutated-fixture probes that
isolate the non-condition half of the `DOC-009` and `VK-027` recipe divergence;
`scripts/scope-check.ps1`; `scripts/enforcement-pack.ps1`; `gh run view 35492844050` and its
ubuntu job log. Every file I mutated was restored with `git checkout --` and `git status
--porcelain` is empty. The full 754-case suite was NOT run locally (~25–40 min); CI's two legs are
used for that and cited as CI, never as my own run.
**Feature contract**: T036a and T036b only — the phase 4 remediation. Declared Territory:
`tests/**`, plus `scripts/ritual-checks.ps1` and `scripts/territory-check.ps1` obtained by the
`74f690e` amendment, plus the implicit `specs/015-enforcement-assurance/**`. Plan constraints in
force: D1/FR-006 (hand-written expectations), D9 (coverage reports, does not block until T044),
D10 (pass differs from fail only in the condition), D12 (real git repositories), SC-006 (no
verdict differs between ubuntu and Windows). Governing conventions: constitution I (amendment
authority, progress-is-not-amendment), feature 014 D3c / `adoption/updating.md` (a task's text is
fixed at approval).

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5
- **Implementer**: claude-opus-5[1m] (the session that produced `317e7d3`)
- **Inputs provided**: the phase 4 remediation diff `317e7d3`, `spec.md`, `plan.md`, `tasks.md`,
  `notes.md`, the round 1 review (`ai-code-review-phase-4.md`), `.specify/memory/constitution.md`,
  and the working tree at `317e7d3`
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — narrowly, and not about the engineering. The code in this commit is right
and I could break it only by breaking it deliberately. Round 1's F1 is closed, and closed wider
than it was written: I ran my own sweep of every `Write-Host`/`Write-Line`/`Write-Error` line in
all nine grading scripts against that script's own declaration, and after this commit there is no
tenth unowned condition — the nine are the nine. I reproduced `181 of 194` exactly, with the
per-script split matching the commit message digit for digit, and the direction of travel is the
honest one. The harness fix is correct: the child is always `RunChild.ps1`, which sets
`[Console]::OutputEncoding` to UTF-8 before the script under test runs, so pinning the *reader* to
UTF-8 is pinning it to what the writer already emits rather than imposing a guess; stdin is not
redirected, so no other stream was missed. I deleted the two pin lines and the guard test failed
(`28 passed, 2 failed` in my slice) — the mutation proof is real, unlike the version the notes
confess to. And the strongest evidence for the revised diagnosis is one I could verify without a
Linux box: `317e7d3` changes no file under `scripts/` anywhere on the branch (`git diff
--name-only origin/main..HEAD | grep ^scripts/` is empty) and the ubuntu leg is green at 754/0, so
the kit scripts really were innocent and the amendment really was unnecessary.

What I am blocking on is the record, which for this feature is not a side channel. This is the
remediation commit for a review whose F8 said *"two internal descriptions in the diff are
inaccurate… this feature's whole argument is that a record nobody checks drifts"*. Neither of
those two was corrected, and the commit adds three more of the same kind — one of which I
disproved by running it. `VK-027/pass/recipe.json` states *"Differs only in the condition under
test (plan D10)"*; it differs in two places, and I proved the second is inert by editing it back
and re-running the case, which still matched. `DOC-009`'s pair carries an equivalent undeclared
second difference. And `notes.md` tells phase 6 that of the thirteen uncovered sites *"five are
unreachable by any fixture and the remaining eight are ordinary work"*, when the same file, 180
lines earlier, classifies seven of the pre-existing eight as unreachable or unpinnable. That
sentence understates T044's problem — which is the exact failure mode round 1's F1 was about, one
document over. All of it is inside `tests/**` and `notes.md`, both in Territory; the fixes are
minutes of work; none of them requires re-opening the engineering.

Residual risk sits in two places. First, the sweep that produced the nine was one-directional: it
looked for conditions the declarations miss and never for lines the declarations wrongly count, so
`ritual-checks.ps1` still counts a per-member banner (`RIT-001`) and a `RESULT FAIL (N of M)`
summary (`RIT-004`) as emission sites, which are the two categories this commit's own reasoning
excludes elsewhere. The affirmative/FAIL asymmetry is applied consistently within the three scripts
this commit touched, and is contradicted by a fourth it did not look at in that direction. Second,
the new blank-line guard cannot fail on Windows — I measured `Start-Process
-RedirectStandardOutput` preserving the blank line here byte for byte — so it is load-bearing only
on the ubuntu leg, and nothing in the record says so.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | **T036a** (harness fix): `Harness.psm1:153-186` read in full — `ProcessStartInfo` with `ArgumentList`, `RedirectStandardOutput/Error`, `UseShellExecute=$false`, both encodings pinned, `ReadToEndAsync` on both streams *before* `WaitForExit()` (the deadlock order is correct), `Dispose()` in `finally`. `ConvertTo-ProcessArgument` is deleted and has no remaining callers (`grep -rn ConvertTo-ProcessArgument tests/` → zero hits outside the removed block). **T036b** (declaration + rules): three new `rules.json` entries and six new case directories; `Coverage.Tests.ps1` run in isolation prints `coverage: 181 of 194 … across 9 grading script(s)` with `doc-lint 10 of 10`, `verify-kit 30 of 31`, `enforcement-pack 44 of 50` — my run, not a quoted number. **FR-006/D1**: all six new `expected.txt` files read; every line is prose a human would type, with `<ROOT>` and `<SHA>` the only substitutions; no `D:\`, `/home/`, `At line:` or `FullyQualifiedErrorId` signature. **FR-007**: each `expected.txt` asserts the full message text and `command.json` carries `exitCode` separately. |
| Visual-reference match (Visual Compliance Loop) | **N/A** — no UI in this feature; `specs/015-enforcement-assurance/screenshots/` does not exist. Nothing to deviate from. |
| Feature contract held (no unapproved table/migration/permission/package) | `git show --name-only --format= 317e7d3` → 24 paths: 2 under `specs/015-enforcement-assurance/`, 4 under `tests/enforcement/` (`Harness.Tests.ps1`, `emission-idioms.json`, `rules.json`, `lib/Harness.psm1`), 18 under `tests/enforcement/cases/`. **No path under `scripts/`.** No new dependency: the launch moved from a PowerShell cmdlet to `System.Diagnostics.Process`, both in the BCL; `Run-Tests.ps1` is untouched and still imports only Pester ≥5 (the D2-approved package). No network call added; the child is still `(Get-Process -Id $PID).Path`, i.e. the running pwsh. |
| Constitution / domain invariants | **Constitution X (one approved phase)**: every tick in `tasks.md` is T036a/T036b; no other task's state moved (`git diff 74f690e..317e7d3 -- specs/…/tasks.md` is a single 24-line hunk, read in full). `enforcement-pack.ps1` run locally → `PhaseSizeWarning` on `317e7d3` (1159 lines / 24 files) — non-blocking by design, and the commit is 1119 insertions of which ~640 are the six case directories. **Constitution I**: one amendment, recorded — see the Amendments section, and F7 for the part a machine cannot check. **Constitution V**: the kit declares no domain-invariants pack. |
| Security (authn/authz, secrets, sensitive logging) | No credentials, tokens or egress added. The launch change does not widen the child's rights: `UseShellExecute=$false` means no shell interposition (strictly safer than `Start-Process`, which can invoke the shell), `ArgumentList` passes each element as one argument so a fixture path can no longer be split or injected, and the working directory is still only set for a `noRoot` case. `$psi.Environment` is untouched, so the child inherits as before. Fixtures still live under `[IO.Path]::GetTempPath()`; both new self-tests `Remove-Item` their temp tree in a `finally`. `git status --porcelain` is empty after all my runs, including the two mutation runs. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | `pwsh -NoProfile -File scripts/scope-check.ps1` → `scope-check: PASS phase 4 commit 317e7d3 (24 file(s))`, exit 0. Territory claim checked the hard way, not by trusting the commit message: `git diff --name-only origin/main..HEAD \| grep '^scripts/'` → nothing, and `git diff origin/main..HEAD -- scripts/ritual-checks.ps1 scripts/territory-check.ps1` → empty. **Both amendment-granted scripts are byte-identical to `origin/main` at the branch tip**, so the `74f690e` Territory widening is unused, exactly as claimed. |
| Rollback safety (phase reverts cleanly; schema additive?) | Additive apart from the launch rewrite. `git revert 317e7d3` would restore `Start-Process` + `ConvertTo-ProcessArgument` (reintroducing the ubuntu blank-line defect), drop three rules and six case directories, and narrow three declarations — a coherent whole, with no dependency in either direction on `scripts/**`. `rules.json` gains no schema field (`schemaVersion` still 1; `DOC-008` uses `siteCount`, introduced in phase 3). Nothing under `scripts/` reads `tests/**`, and `ritual-checks.ps1` does not run the harness, so a revert cannot turn the gate red. |
| Round 1 F1 closed — the count of nine, verified independently | I wrote my own sweep (PowerShell: for each `emission-idioms.json` entry, every non-comment line in that script matching `Write-(Host\|Line\|Error\|Warning\|Output)` that no declared accumulator pattern matches) and read all 32 survivors. Post-commit they are: four printer loops (`doc-lint:229,234,248`, `enforcement-pack:1229,1232`, `build-digests:241,251`, `roadmap-claim-check:123`, `verify-kit:318-320`, `ritual-checks:90`, `territory-check:109`), five FAIL summaries printing a count already accumulated (`doc-lint:233,247`, `enforcement-pack:1231`, `verify-kit:326`, `build-digests:242,252`, `roadmap-claim-check:124`), two preambles (`doc-lint:225`, `enforcement-pack:1191`), three remediation continuations (`scope-check:188,256`, `scope-check-repos:289`), two JSON emitters (`verify-kit:115,338`), the `Write-Line` function definition itself (`scope-check-repos:59`), and three blank/continuation lines in `territory-check`/`ritual-checks`. **No tenth unowned condition exists. Nine is right.** The regexes were checked against the source by hand: `Write-Host\s+['\"]AmendmentAuthority: ` picks up `:1058` and `:1183` and nothing else; `enforcement-pack: ('\$Branch' is\|OK')` picks up `:1209`, `:1224`, `:1235` and deliberately not `:1191`/`:1231`; `doc-lint: (manifest\|OK)` picks up `:236`, `:238`, `:252`; `verify-kit: OK` picks up `:330`. 5 + 3 + 1 = 9. |
| The arithmetic 177/185 → 181/194 | Derived, then measured. Derived: +9 declared (5 + 3 + 1 above) → 194; +4 covered (`DOC-008` owns `:236` and `:238` via `siteCount: 2`, `DOC-009` owns `:252`, `VK-027` owns `:330`) → 181. Measured: `Coverage.Tests.ps1` alone, 7/7 green, prints `181 of 194`. The per-script deltas match the notes table (`doc-lint 7/7→10/10`, `verify-kit 29/30→30/31`, `enforcement-pack 44/45→44/50`). Percentage 95.7% → 93.3%, i.e. **down**, which is the direction the commit claims and the one that cannot be self-serving. |
| The affirmative/FAIL asymmetry, applied or bent | Applied consistently **within the three scripts this commit touched** — I checked every candidate: `doc-lint` counts `:228` (a condition: `$missingKit` is a `Where-Object` result with no per-item append) and excludes `:233`/`:247` (headers over `foreach` loops over `$manifestErrors`/`$broken`); `verify-kit` counts `:330` and excludes `:326` (`$failCount`/`$warnCount`); `enforcement-pack` counts `:1209`/`:1224`/`:1235` and excludes `:1191`/`:1231`. It also matches the pre-existing `scope-check` (whose FAIL lines are inline conditions with no accumulator), `build-digests` and `roadmap-claim-check`. It is **contradicted by `ritual-checks.ps1`**, which the sweep did not examine in that direction — see F2. |
| Encoding fix correct and complete | `RunChild.ps1` read in full: line 32 sets `[Console]::OutputEncoding = UTF8(no BOM)` and line 33 sets `$OutputEncoding` — **inside the child, before the script under test runs**. The harness never launches anything but `pwsh -File RunChild.ps1`, so "a child that might not write UTF-8" does not arise; pinning the reader to UTF-8 pins it to what the writer is already forced to emit. `StandardInputEncoding` is correctly absent: `RedirectStandardInput` is never set, so stdin is inherited exactly as under `Start-Process`. No other decode in the path: `expected.txt` and `recipe.json` go through `[IO.File]::ReadAllText`/`Get-Content -Raw` (UTF-8 default with BOM detection) and fixture files are written with `UTF8Encoding($false)`. The one remaining encoding-sensitive launch is in the *test* file, not the harness — F4. |
| The encoding guard actually guards | Mutation run, mine: deleted the two `$psi.Standard*Encoding = $utf8NoBom` lines from `Harness.psm1`, ran `Run-Tests.ps1 -Case cases/doc-lint/DOC-008` → `28 passed, 2 failed`; the failures are `carries a non-ASCII character through, on the real capture path` and one `DOC-008` case. Restored with `git checkout --` and re-verified the pin is present. The notes' claim (19/0 → 18/1 on `Harness.Tests.ps1` alone) is consistent with mine: that file now holds exactly 19 `It`s (5 + 3 + 3 + 3 + 3 + 2, counted). **The guard is real.** Equally verified: the pre-existing `carries a non-ASCII character through unchanged` test **still passed** in the mutated run, confirming the notes' admission that it watches the wrong object. |
| The blank-line guard, and what it can and cannot catch | Ran it green (`compares what the script actually printed, blank lines included`, 1.96s). Then measured the mutation it is supposed to catch, on this platform: a probe script emitting `first`/``/`second` through `Start-Process -RedirectStandardOutput` returns bytes `102,105,114,115,116,13,10,13,10,115,...` — **the blank line survives on Windows**. So reverting the fix cannot make this test fail here; it is load-bearing only on the ubuntu leg. See F5. |
| The revised diagnosis (scripts innocent, harness guilty) | I cannot run Linux, so the four-way `Write-Host ''` measurement in `ubuntu:24.04` is taken on trust and flagged as such. But the conclusion is independently provable from CI: `gh run view 35492844050` → `headSha` `317e7d3a89b302c26d2c8b8c14330809d780c57c`, both jobs `success`; the ubuntu job log (`gh run view --job 106030622867 --log`) reads `enforcement-tests: Pester 5.9.0, pwsh 7.6.5, Ubuntu 24.04.5 LTS` then `Tests Passed: 754, Failed: 0`. `317e7d3` changes no script. **Sixteen cases that failed on ubuntu at `8778c06` now pass with the scripts unchanged and only the harness changed** — that is the diagnosis, demonstrated. The prior failing run is also as described: `gh run view 35437579942` → `headSha` `8778c06…`, conclusion `failure`. |
| "Sixteen cases with an interior blank line" | Counted myself across all 364 case directories (awk over every `expected.txt` for a blank line after a non-blank one): exactly 16 — `RIT-001..005` × both directions (10) and `TERR-002/fail`, `TERR-003/fail`, `TERR-004` × both, `TERR-005` × both (6). Matches the claim exactly, and matches the `Write-Host ''` sites I found at `ritual-checks.ps1:100`, `territory-check.ps1:112` and `:116`. |
| The new cases pass, and cover what they claim | `Run-Tests.ps1 -Case cases/doc-lint/DOC-008` → 30/0; `-Case cases/doc-lint/DOC-009` → 30/0; `-Case cases/verify-kit/VK-027` → 30/0 (each slice = 19 harness self-tests + 7 coverage + 4 case assertions). `DOC-008`'s two directions exercise different sites, read from the expectations: `fail` pins `manifest — completeness sweep skipped`, `pass` pins `manifest — 18 shipped file(s) classified`; the `siteCount: 2` ambiguity assertion in `Coverage.Tests.ps1:107-131` is green, so the anchor matches exactly those two. |
| "The first rules whose exit code inverts against the direction name" | Checked mechanically, not accepted: parsed every `pass`/`fail` `command.json` pair in the suite for `pass.exitCode == 1 && fail.exitCode == 0`. Result: **`DOC-009`, `VK-027` — and only those two.** The claim is exact. |
| D10 (pass differs from fail only in the condition) on the three new pairs | Measured with `diff` and then with mutated-fixture probes. `DOC-008` is exemplary: the only difference is `".kit-version": "b067ead\n"`. `DOC-009` differs in **two** places — the broken reference (the condition) *and* the `kit-manifest.json` form (10 explicit entries vs one `**`). `VK-027` differs in **two** places — the constitution's `TODO(...)` markers (the condition) *and* `"Every feature begins with a spec."` vs `"…a specification."`. I proved both second differences inert by copying each `fail` case into a scratch directory, substituting the `pass` spelling, and driving `Invoke-FixtureCase` directly: both returned `OutputMatch=True ExitMatch=True`. See F3. |
| Round 1's other findings | F2 (D10's escape clause unwritten, unenforced) — **open**, and the two new pairs add to it. F3 (the "no expectation can pin that" overstatement) — **open**, and the new notes move the number the wrong way (F1 here). F4 (`noRoot` symlink assumption on ubuntu) — **discharged by evidence, unrecorded**: round 1 asked the implementer to confirm the ubuntu leg is green on the `territory-check` cases specifically; 754/0 on ubuntu at `317e7d3` does that, and nothing in `notes.md` says so. F5 (unsorted `Get-ChildItem` note for the case-layout README) — **open**; `tests/enforcement/README.md` exists and is not in the commit. F6 (no verification run / CI evidence) — **partly addressed**: `notes.md` now records run 35437579942 and a pre-fix local `752 passed, 1 failed`, but there is no phase 4 gate-evidence block of the kind phases 1, 2 and 3 each have (`notes.md:157, 421, 1047`), and the clean full-suite figure (754) appears only in the commit message. F7 (`FixtureRepo.psm1` self-test rule) — **open**; the file is not in the commit. F8 (two inaccurate descriptions) — **both unfixed**: `emission-idioms.json:27` still says `"three of its 'ERROR:' lines are the PRINTERS"` (two are), and `CLAIM-007/pass/recipe.json` still says `"Differs only in one cell (plan D10)"`. F9 (promote the `verify-kit` `-notmatch` defect to a roadmap GAP row) — **open**; `grep -n "notmatch\|case-sensit" docs/roadmap.md` returns nothing across its 110 GAP rows. |
| Amendment record well-formed (machine half) | `pwsh -NoProfile -File scripts/enforcement-pack.ps1` → `AmendmentAuthority: graded 3 of 3 commit(s) in fc7eda4..HEAD`, then `enforcement-pack: OK`, exit 0. So the `**Amendment approved by**: anas.m, 2026-09-20.` line, the amended section it sits in, and the approver named in the commit message all agree, and `317e7d3`'s `tasks.md` change passes the kit's own check. What the check cannot test is in F7. |

## Findings

### F1 — `notes.md` tells phase 6 that eight of the thirteen uncovered sites are "ordinary work", contradicting the same file — CONFIRM

The new section closes with a handover to T044:

> The five declared-uncovered `enforcement-pack.ps1` sites. They join the eight already listed
> under T036, so **T044 now faces thirteen uncovered sites, of which five are unreachable by any
> fixture** and the remaining eight are ordinary work.

The thirteen is right — I derived it independently (`194 − 181`, split as `territory-check` 5,
`enforcement-pack` 6, `verify-kit` 1, `scope-check-repos` 1). The classification is not. The same
file, at lines 1389–1410, enumerates the pre-existing eight with reasons, and prefaces them:
*"three of the four reasons below cannot be fixed by writing a fixture"*. Read against that list:

- `territory-check.ps1:36,:46,:57,:64,:81` — "reachable and unpinnable" (5 sites)
- `verify-kit.ps1:311` — "**Reachable and unpinnable**: its text is `$_.Exception.Message`…
  Pinning it would make the suite's verdict depend on the PowerShell version, which SC-006
  forbids" (1 site)
- `scope-check-repos.ps1:199` — "**Unreachable by construction**: peeling reads the object"
  (1 site)
- `enforcement-pack.ps1:1066` — "Reachable in principle, unreached" (1 site)

So by the phase's own record **seven**, not five, are unreachable-or-unpinnable, and of the
remaining eight in the new arithmetic, two (`verify-kit:311`, `scope-check-repos:199`) were
explicitly declared not-ordinary 180 lines earlier. The sentence hands T044 a smaller, easier
problem than the one it will meet, and T044 is the task that turns this report into a blocking
assertion. This is the same defect round 1's F1 named — a number that describes the part already
understood — relocated from the coverage report into the prose that explains it.

Two smaller drifts in the same handover: it says the five new `enforcement-pack` sites take the
uncovered count from eight to thirteen, but `enforcement-pack` goes from 1 uncovered to 6, which
is the same total by a different route and is stated correctly in the table above it; and no task
anywhere in `tasks.md` says who writes the ten missing `enforcement-pack` fixtures. T044 makes an
uncovered site a failure and T045 implements declared exemptions, so the five will land on one of
those two by default rather than by decision — which is the thing the paragraph says it is trying
to avoid ("for phase 6 to decide rather than discover").

*Action: implementer — correct the sentence to the classification the same file already carries
(seven unreachable-or-unpinnable, one unreached, five newly uncovered and ordinary), and say
plainly that the five new ones have no task yet. `notes.md` is in Territory; this is a text fix.
Owner — decide at T044/T045 whether the five `enforcement-pack` affirmative/inert sites get
fixtures or declared exemptions; either is defensible, but not by default.*

### F2 — The sweep that found the nine was one-directional, and `ritual-checks.ps1` still counts a banner and a FAIL summary as conditions — CONFIRM

The commit's claim is a completed audit: *"Sweeping every `Write-Host` line in all nine scripts
against that script's own declaration turned up nine unowned conditions in three scripts."* I
reproduced that sweep and confirm the nine (evidence table). But it only asks one question — *what
does the declaration miss?* — and never the converse, *what does the declaration wrongly count?*
The converse has answers, in the one script the commit's reasoning never revisited:

```text
ritual-checks.ps1 accumulator:  Write-Host\s+\(?['"](=== )?ritual-checks:

  :86   Write-Host "=== ritual-checks: $name ==="            <- a per-member BANNER
  :108  Write-Host ('ritual-checks: {0,-16} {1}' -f …)       <- the per-member verdict
  :111  Write-Host ('ritual-checks: … 'n/a (no adoption …')  <- an inert verdict
  :114  Write-Host "ritual-checks: RESULT FAIL ($failedCount of $($results.Count) member(s) …)"
  :117  Write-Host 'ritual-checks: RESULT OK'
```

`:86` is a preamble — and `rules.json` carries a rule for it: `RIT-001`, summary *"each member
announces itself by name before it runs"*. `:114` is a summary that counts verdicts `:108` has
already printed — and `RIT-004` owns it. Those are precisely the two categories this commit's new
prose excludes elsewhere: `enforcement-pack.ps1:1191` is declared out as "the preamble line naming
the branch and diff base"; `doc-lint.ps1:225` is silently out for the same reason (and, unlike
`:1191`, is not even listed in `doc-lint`'s "deliberately OUT" note); every other script's
`RESULT FAIL (N)` / `FAIL (N issue(s))` summary is out.

The letter of the rule does let `ritual-checks` through — "a FAIL line that prints a count the
accumulator already holds" needs an accumulator, and `ritual-checks` declares none. But that is a
technicality, not the principle: `:114` counts what `:108` emitted, exactly as `doc-lint:233`
counts what `$manifestErrors` holds. The result is that `ritual-checks` reports a flattering
`5 of 5` in which two of the five are a banner and a tally, while `doc-lint`'s and `verify-kit`'s
equivalents are excluded — the opposite asymmetry to the one the commit defends, in the same
report, unremarked.

This does not change any verdict today (D9), and it does not undermine the nine. It matters
because T044 turns this denominator into law, and because the commit presents the sweep as
finished.

*Action: implementer — run the converse sweep (every line a declaration matches, judged against
"a site is a condition the script detects") and record the result in `notes.md`, whatever it says.
Owner — rule on `RIT-001` and `RIT-004` before T044: either the banner and the RESULT summary are
sites, in which case `doc-lint:225`, `enforcement-pack:1191/:1231`, `verify-kit:326` and the two
`build-digests` RESULT lines come in too, or they are not, in which case `ritual-checks` goes to
`3 of 3` and two rules are retired. The one thing that must not stand is the split.*

### F3 — Both new rule pairs violate D10, and `VK-027`'s description asserts the opposite — BLOCKING

Plan D10: *pass differs from fail only in the condition under test.* `DOC-008` obeys it perfectly
— one added `.kit-version` file, nothing else. The other two do not, and one of them says it does.

**`VK-027`.** `diff pass/recipe.json fail/recipe.json` shows two content changes besides the
`description`:

```text
39c39  "**Version**: TODO(VERSION) | **Ratified**: TODO(DATE)"   <- the condition
       "**Version**: 2.0.0 | **Ratified**: 2026-01-01"
43c43  "Every feature begins with a spec."                        <- not the condition
       "Every feature begins with a specification."
```

`pass/recipe.json`'s description reads: *"Differs only in the condition under test (plan D10)."*
That is false. I proved the second change is inert rather than arguing it: I copied
`VK-027/fail` to a scratch directory, substituted `"…begins with a spec."`, and drove
`Invoke-FixtureCase` against it — `OutputMatch=True ExitMatch=True`, the six expected lines
unchanged. So the divergence buys nothing and the description claims a property the file does not
have.

**`DOC-009`.** The pair differs in the unresolvable reference (the condition) *and* in the
`kit-manifest.json` body: `fail` lists ten explicit entries, `pass` collapses them to a single
`{"path": "**", "class": "verbatim"}`. Both descriptions characterise the difference as the
reference alone. Same probe, same result: swapping `fail`'s ten-entry manifest for `pass`'s `**`
left the case matching (`OutputMatch=True ExitMatch=True`, still `18 shipped file(s) classified`).

Round 1 raised exactly this as F2 (D10's escape clause is used but never written down, and nothing
checks it) and as F8 (a recipe description asserting a minimality the file does not have —
`CLAIM-007`, whose text is still uncorrected in this tree). A remediation commit that reproduces
both, in new files, while the originals stand, is the drift this feature exists to argue against.
I am marking it BLOCKING rather than DOC DRIFT for one reason: the descriptions are the only place
D10 compliance is recorded, no machine checks them, and a *false* one is worse than an absent one
— it tells the next reader the question was asked and answered.

*Action: implementer — either make both pairs actually minimal (delete the gratuitous half of each
divergence: restore `DOC-009/pass`'s ten-entry manifest, restore `VK-027/pass`'s "specification"),
which is the cheaper and better fix since both are provably inert; or correct both descriptions to
state the second difference and why it is there. Also correct the two F8 items round 1 asked for
and this commit left: `emission-idioms.json`'s `_comment` ("three of its 'ERROR:' lines are the
PRINTERS" — two are, and the sentence now narrates a narrowing this commit reversed) and
`CLAIM-007/pass/recipe.json`'s description. All four are inside `tests/**`.*

### F4 — Eight self-tests still run through a hand-rolled copy of the launch path, in the file whose new comment names that as the defect — MINOR

`Harness.Tests.ps1:28-36` defines `Invoke-Launcher`, which launches the child with
`Start-Process -FilePath … -RedirectStandardOutput $out`, hand-quotes its argument vector with the
regex `ConvertTo-ProcessArgument` used to use, and reads the result with `[IO.File]::ReadAllText`.
Eight `It`s depend on it: the five `RunChild exit codes` tests and the three `RunChild argument and
encoding fidelity` tests.

The commit names the pattern precisely — *"a self-test that builds its own copy of the thing under
test measures the copy"* — and demonstrates it: the `carries a non-ASCII character through
unchanged` test, whose comment reads *"The reason this launcher exists"*, stayed green throughout
the mojibake incident, and stayed green in my mutation run with the UTF-8 pin deleted. The new test
routes around the copy for the encoding property. The copy itself is left in place, unmarked, for
the other eight — and it carries the *other* defect this commit just fixed: `Start-Process
-RedirectStandardOutput` drops blank lines on Linux, so if any future probe script emits one, the
launcher tests will silently measure something the launcher did not produce, on the ubuntu leg
only.

These eight test `RunChild.ps1` as a target, so they cannot simply become `Invoke-FixtureCase`
calls; but `Invoke-Launcher` can be rewritten to the same `ProcessStartInfo` + `ReadToEndAsync` +
pinned-encoding shape the harness now uses, which is ten lines.

*Action: implementer — rewrite `Invoke-Launcher` to the production launch shape, or add a comment
at `Harness.Tests.ps1:28` stating that it is a deliberate copy, which properties it therefore
cannot attest, and that no probe script may emit a blank line through it. Low risk either way;
this is hygiene in the instrument that grades the instrument.*

### F5 — The blank-line guard cannot fail on Windows, and nothing says so — MINOR

`compares what the script actually printed, blank lines included` is the self-test for T036a's
headline fix. I measured what it can catch on this platform: a probe emitting `first`, ``,
`second` through `Start-Process -RedirectStandardOutput` returns
`102,105,114,115,116,13,10,13,10,115,101,99,111,110,100,13,10` — the blank line is intact. So
reverting `Harness.psm1` to `Start-Process` leaves this test green on Windows; it is load-bearing
only on the ubuntu leg.

That is not a defect — the bug was Linux-only and the test is right to assert the property
unconditionally. It matters because the notes present a clean mutation table for the *encoding*
guard (19/0 → 18/1, which I reproduced) and no equivalent for this one, and a reader will assume
both were proved the same way. They cannot have been, on Windows. The honest statement is that
the blank-line guard's mutation proof lives in CI run 35437579942 (16 failures) versus run
35492844050 (0), which is strong evidence — it is just a different kind of evidence, and it should
be labelled.

*Action: implementer — one sentence in `notes.md` or in the test's comment saying the guard is
platform-asymmetric: on Windows it asserts a property that cannot currently break, and the ubuntu
leg is where it bites. No code change.*

### F6 — The encoding guard mutates `[Console]::OutputEncoding` outside its own `try` — MINOR

`Harness.Tests.ps1:286-295`:

```powershell
$previousEncoding = [Console]::OutputEncoding
[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding('iso-8859-1')
$tmp     = Join-Path ([IO.Path]::GetTempPath()) ('kit-dash-' + …)
$kitRoot = Join-Path $tmp 'kit'
$caseDir = Join-Path $tmp 'case'
New-Item -ItemType Directory -Path (Join-Path $kitRoot 'scripts') -Force | Out-Null
New-Item -ItemType Directory -Path $caseDir -Force | Out-Null
try { … } finally { [Console]::OutputEncoding = $previousEncoding; … }
```

Two `New-Item` calls sit between the mutation and the `try`. `$ErrorActionPreference` is `Stop` in
this module's world, so an IO failure in either — a full or read-only temp volume, a transient
lock — throws with the console left on Latin-1 for the remainder of the Pester process. Every
subsequent case would then mojibake its em dash, and the suite would report a cascade of
unrelated failures whose cause is three hundred lines upstream. That is the same class of defect
this phase spent itself on: an instrument whose verdict depends on ambient state a test forgot to
restore. Probability is low; blast radius is the whole run.

*Action: implementer — move the two `New-Item` calls above the encoding mutation, or move the
mutation inside the `try`. One-line change.*

### F7 — The T036a amendment is well-formed but contradicts the kit's own published convention, and the same commit applies the opposite convention ten lines above — CONFIRM

The machine half is clean, verified not assumed: `tasks.md` carries
`**Amendment approved by**: anas.m, 2026-09-20.` immediately above the rewritten T036a, the commit
message names the same approver on the same date, and `scripts/enforcement-pack.ps1` run locally
returns `AmendmentAuthority: graded 3 of 3` and `enforcement-pack: OK`. `git diff
74f690e..317e7d3 -- specs/…/tasks.md` is a single hunk: T036a's body fully replaced, T036a and
T036b ticked, one explanatory paragraph and one approver line added. Nothing else in any approved
document moved.

Three things the machine cannot check, and a review must.

**1. The remedy chosen is the one the kit tells adopters not to choose.** `enforcement-pack.ps1:1162`
— the failure text of the very check that graded this commit — reads: *"rewriting a task's text
while ticking it is not [exempt]: record what was done in `notes.md`, and leave the task saying
what was agreed (plan D3c)."* That is not a stray string. It restates feature 014's owner-approved
decision D3c (`specs/014-amendment-authority/plan.md:194`, *"A task's text is fixed at approval …
What was actually done — evidence, results, corrections, the narrative of a phase — goes to
`notes.md`"*, approved by anas.m 2026-09-14), which the kit ships to every adopted project at
`adoption/updating.md:329`. D3c was adopted precisely because the kit's own history was full of
commits that *"rewrote task descriptions while ticking them, expanding each line to say what had
been done"* — which is, to the word, what T036a's new body does.

**2. The same commit applies the correct convention to the paragraph above.** The Territory
rationale is left standing with the correction written in `notes.md` — exactly D3c — and the
commit explains why in a sentence that applies with undiminished force to T036a: *"what was
believed, and on what evidence, is part of the record."* Two adjacent pieces of the same approved
section, the same kind of falsified statement, opposite treatments, no stated rule distinguishing
them. The distinction that does exist is uncomfortable: the paragraph preserved is the one whose
falsity is now safely historical; the text rewritten is the one that would otherwise stand as a
ticked task describing work nobody did.

I do not think the rewrite was dishonest, and there is a genuine tension D3c does not resolve:
ticking a task whose text says "change these two scripts" when the right answer was "do not touch
them" records a false completion, and D3c's remedy leaves that falsehood in the checkbox. But the
resolution of a tension between a rule and a case is the owner's, and the route the kit publishes
is the other one — un-tick it, or tick it and put the correction in `notes.md` where the reader
is already sent.

**3. Self-approval cannot be excluded from the record.** Constitution I: *"An implementing agent
MUST NOT approve its own amendment."* Every commit on this branch is authored by `anas.m` with
`Co-Authored-By: Claude Opus 5 (1M context)`, and the sole evidence that the owner approved is a
line in a commit message written by the implementing session. That is the strength constitution I
itself concedes ("the record has the strength of the Reviewer Provenance block, not of an
authentication"), and it is the same for `74f690e`. I record it rather than allege anything: a
reviewer cannot verify it, and the owner is the only one who can confirm it at gate 6.

**On leaving the known-false Territory rationale standing** (the brief's question): acceptable, as
implemented. The false claim (*"`Write-Host ''` emits a blank line on `windows-latest` and nothing
on `ubuntu-latest`"*) is not left bare — the correcting paragraph begins four lines below it, in
the same section, before any task text. A reader cannot reach the tasks without passing the
correction. What I would add is one clause at the false sentence itself, because the paragraph
will outlive this branch and `git blame` is not a reading strategy. The residual mechanical
consequence is that phase 4's declared Territory permanently grants two grading scripts it does not
need; `scope-check` would therefore pass a future phase-4 commit that edited either one. Phase 4
is complete, so the exposure is small, but narrowing it is an owner's call and should be made
rather than left.

*Action: owner — (a) confirm you approved the 2026-09-20 amendment, since only you can; (b) rule
on whether rewriting a ticked task's text is permitted on this branch given D3c and
`adoption/updating.md:329`, and if it is, say so in `notes.md` so the next reader is not left
choosing between the tasks file and the check's own error message; (c) decide whether to narrow
phase 4's Territory back to `tests/**`. Implementer — add one clause to the 2026-09-19 rationale
paragraph marking the diagnosis superseded and pointing at `notes.md`, which needs no new
approval only if the owner rules an in-place marker is itself an amendment requiring one; ask
first.*

### F8 — T036b's text describes neither the work nor the result, and was left unamended while T036a was rewritten — DOC DRIFT

T036b, unchanged since `74f690e`, reads: *"…Widen the declaration to 8 and cover the inert
verdict. (`tests/**`; no amendment needed.)"* What was delivered widens `doc-lint` to **10**,
`enforcement-pack` to **50** and `verify-kit` to **31** — nine sites across three scripts, three
new rules, six new cases. The commit message says so plainly ("nine unowned conditions in three
scripts"), so the task and the commit that closes it disagree in the same push.

Under D3c leaving T036b's text alone is the *correct* handling — and I note it without irony: it
is the right call, made in the same commit as the opposite call for T036a, which is what makes the
pair worth a finding rather than a shrug. The substantive point is narrower: the work delivered
under T036b materially exceeds the approved task (two scripts the task does not name), no
amendment records that expansion, and constitution I does not require one because no document
text changed. The expansion is inside Territory (`tests/**`), is the same kind of work, and lowers
the coverage number rather than raising it, so I am not treating it as a scope breach. But a
reader reconciling `tasks.md` against the branch will find the task understating the phase by a
factor of three with nothing to explain it.

*Action: implementer — the reconciliation belongs in `notes.md` (which is where D3c sends it) and
is one sentence: T036b was executed wider than written, here is the sweep that justified it, here
is the number. No amendment.*

### F9 — Invalid JSON in the encoding guard's fixture, which works only by parser leniency — MINOR

`Harness.Tests.ps1:296-299` writes the second test's `recipe.json` as a PowerShell single-quoted
literal that contains an actual line break inside a JSON string value:

```powershell
'{"description":"…","write":{"README.md":"x
"}}]}'
```

RFC 8259 forbids unescaped control characters inside a string; this parses only because
PowerShell's `ConvertFrom-Json` is lenient about it. Its sibling test, twenty lines above, writes
the same fixture correctly with `\n`. It works on both CI legs today (754/0 on each), so nothing
is broken — but a fixture in a byte-fidelity guard test is the last place to depend on a parser's
tolerance for malformed input, and the divergence between two adjacent tests reads as a slip
rather than a decision.

*Action: implementer — replace the literal break with `\n`, matching the test above it. One
character.*

### F10 — Round 1's F4 is discharged by evidence that the record does not contain — MINOR

Round 1's F4 asked the implementer to *"confirm the `ubuntu-latest` leg is green on the
`territory-check` cases specifically before treating SC-006 as held for this phase"*, because
`noRoot` cases assume a symlink-free temp path. The ubuntu job at `317e7d3` reports
`Tests Passed: 754, Failed: 0`, which includes all 28 `territory-check` case assertions, so the
concern is answered. Nothing in `notes.md` says so, and F4 is not mentioned anywhere in the
commit. The same is true of F5, F7 and F9, which the commit neither addresses nor acknowledges as
deferred.

*Action: implementer — add a short "round 1 findings" disposition to `notes.md`: which were closed
(F1), which are discharged by the CI run (F4), which are deferred to phase 6 with their task
number (F2, F3, F5, F7), which are still owed (F6's gate block, F8's two corrections, F9's roadmap
row). A review whose findings vanish without disposition is the reviewing equivalent of the
coverage report this feature exists to fix.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**One amendment**, to `specs/015-enforcement-assurance/tasks.md`. Verified against the true base
(`git diff 74f690e..317e7d3 -- specs/015-enforcement-assurance/tasks.md`, read in full) rather
than against `8778c06`, where the whole block reads as an addition and the amendment would be
invisible:

- **`specs/015-enforcement-assurance/tasks.md` — T036a's text replaced in full**, plus a
  four-line paragraph explaining the replacement and stating that the Territory rationale above is
  deliberately left standing. Recorded as `**Amendment approved by**: anas.m, 2026-09-20.`,
  immediately above the amended task. The commit message body carries the matching line
  *"T036a's text amended to say what was actually done - approved by anas.m, 2026-09-20."* The
  approver and date agree between document and commit; `scripts/enforcement-pack.ps1` grades the
  range `fc7eda4..HEAD` as `graded 3 of 3` with no failure, so the record is machine-conforming.
  See **F7** for the three things the machine cannot check: whether the owner actually approved,
  whether the rewrite was the right remedy given D3c and `adoption/updating.md:329`, and the
  self-approval prohibition.
- **T036a and T036b checkbox ticks** — `- [ ]` → `- [x]`, both inside the amended hunk.
  Progress, not amendment, under constitution I's explicit exemption ("a checkbox moving in
  **either** direction"). T036b's text is byte-identical to `74f690e`; see F8 for why that is
  correct and still leaves the document understating the work.
- **The prior amendment `74f690e`** (Territory widened by `scripts/ritual-checks.ps1` and
  `scripts/territory-check.ps1`, `**Amendment approved by**: anas.m, 2026-09-19.`) is **not**
  narrowed or rewritten by this commit and remains on the record, by stated intent. Its
  justification is now known false; the correction is adjacent in the same section and detailed in
  `notes.md`. Its granted Territory is unused — both scripts are byte-identical to `origin/main`
  at the tip, verified by `git diff origin/main..HEAD -- scripts/ritual-checks.ps1
  scripts/territory-check.ps1` returning empty.
- `specs/015-enforcement-assurance/spec.md` — **not in the commit**
  (`git show --name-only --format= 317e7d3 | grep spec.md` returns nothing).
- `specs/015-enforcement-assurance/plan.md` — **not in the commit**. Every decision this phase is
  graded against (D1, D9, D10, D12) is unchanged; D10 is observed in the breach (F3), not amended.
- `specs/015-enforcement-assurance/contracts/` — does not exist for this feature.
- `specs/015-enforcement-assurance/notes.md` — in the commit, +249 lines, all appended below the
  existing phase 4 section (`git diff 8778c06..317e7d3 -- …/notes.md` shows no deletion and no
  edit above line 1427). `notes.md` is the phase evidence record, not an approved specification
  document, so it is not an amendment surface — which is precisely why D3c sends corrections there.

The standard this phase is graded against is therefore the one the owner approved, with one
recorded and well-formed amendment whose *appropriateness* — not whose form — is F7's question.

## Constitution re-check (post-implementation)

**PASS**, re-evaluated against the code as built, with one clause referred to the owner.

- **I. Specification First** — satisfied in form. `spec.md` and `plan.md` predate the phase and are
  unamended. `tasks.md` is amended once, with a conforming record that the kit's own check accepts
  (`enforcement-pack: OK`). The self-approval prohibition and the D3c question are referred to the
  owner as **F7**; neither is a machine-detectable breach, and neither is something a reviewer can
  clear.
- **II. Source of Truth** — **engaged, and one rung is in tension.** `adoption/updating.md:329` and
  feature 014's D3c say a task's text is fixed at approval and corrections go to `notes.md`; this
  commit rewrote a task's text with an approver line, which constitution I permits. The conflict
  rule says stop and report rather than silently choose — the commit chose, and explained the
  choice for the paragraph it did *not* rewrite while not explaining it for the task it did. F7
  reports it. Elsewhere the principle is honoured well: the phase states in writing that its own
  earlier diagnosis was wrong rather than quietly re-measuring, which is the behaviour this rung
  asks for.
- **III. Repository Separation** — N/A. Single governance repository, no `codeRepos`.
- **IV. Architecture Consistency** — satisfied. No new dependency (`ProcessStartInfo` and
  `Process` are BCL types; Pester remains the one D2-approved package), no architectural change —
  the launch mechanism changed inside `Invoke-FixtureCase`, whose contract and return shape are
  unaltered, and `RunChild.ps1` is untouched.
- **V. Domain Invariants** — N/A. The kit declares no domain-invariants pack.
- **VI. Security** — satisfied, and marginally improved: `UseShellExecute=$false` removes any shell
  interposition and `ArgumentList` removes the hand-rolled quoting that phase 2's F1 was about. No
  secrets, no network, fixture-local git identity, temp-scoped repositories, and
  `git status --porcelain` empty after my runs including two mutations.
- **VII. External Integration Governance** — N/A.
- **VIII. Testing Requirements** — engaged fully; this commit is a test-infrastructure repair plus
  three new rules. The one gap is F4: eight self-tests still run on a copy of the launch path.
- **IX. Human Review** — engaged as designed. This round-2 fresh-context review discharges gate 5
  for the remediation; gate 6 remains owed at merge over the full feature diff, and F7 puts three
  owner decisions on it.
- **X. Controlled Delivery** — satisfied. One phase's remediation (T036a, T036b) and nothing else;
  `phase 4` is in the subject so `scope-check` attributes it (`PASS phase 4 commit 317e7d3`); the
  commit is independently revertible. `PhaseSizeWarning` fires (1159 lines / 24 files vs the
  400/15 guideline) and is non-blocking by design; ~640 of those lines are the six case
  directories and ~250 are `notes.md`, leaving roughly 170 lines of executable and declarative
  change. One nuance versus the plan-time check: T036b was executed materially wider than its
  approved text (F8), which is more work against the task rather than different work, but it is
  unrecorded.

## Test coverage observed

**`tests/enforcement/Coverage.Tests.ps1`** — 7 tests, run in isolation, 7/7 green. Four are
integrity assertions that bite: every rule's `emitAnchor` still appears in its script; every
anchor matches exactly `siteCount` precise sites (this is what makes `DOC-008`'s two-site claim
checkable, and it is green, so the anchor `doc-lint: manifest` matches `:236` and `:238` and
nothing else); every rule has both directions (so `DOC-008`, `DOC-009` and `VK-027` could not have
shipped one-sided); every case directory maps to an inventoried rule. One reports the figure and
asserts only `> 0`, per D9 — so `181 of 194` is a printed measurement, not an assertion, and
nothing in the suite would go red if it fell.

**`tests/enforcement/Cases.Tests.ps1`** — now 364 case directories × 2 `It`s. The three new pairs
run green in my slices (30/0 each, where 30 = 19 self-tests + 7 coverage + 4 case assertions). The
load-bearing property is unchanged and still strong: `expected.txt` is compared as **full
normalised output**, so a second unintended condition firing in a divergent recipe changes the text
and fails the case — which is exactly why the two gratuitous divergences in F3 are provable as
inert rather than merely arguable, and also why they are survivable.

**`tests/enforcement/Harness.Tests.ps1`** — 19 `It`s (17 before this commit, 2 new), all green.
The two new ones are genuine assertions, not smoke, but they are unequal in strength. The encoding
guard is the stronger: it forces `[Console]::OutputEncoding` to `iso-8859-1` itself rather than
inheriting whatever the run started with, and I confirmed by mutation that it fails when the pin is
removed while the eight-months-older test with almost the same name does not. The blank-line guard
is unfalsifiable on Windows (F5) and rests on the CI delta between runs 35437579942 and
35492844050 for its proof. Both drive `Invoke-FixtureCase` against a synthetic kit root rather than
re-implementing the launch, which is the correction the notes claim; the eight tests that still use
the re-implementation are F4.

**Not observed by me**: the full 754-case suite locally (~25–40 min); any Linux execution. The
ubuntu leg is cited from CI (754/0, pwsh 7.6.5, Ubuntu 24.04.5 LTS, run 35492844050, job log read)
and is CI's evidence, not mine. SC-002 mutation sampling across grading scripts is T048 (phase 6);
SC-007's measured cost is T053. For what it is worth toward T053, the same run gives
ubuntu ≈ 4m47s and windows ≈ 10m21s for the harness step.

## Residual risk

The engineering risk is low and I want to say so plainly: the harness defect was real, the fix is
right, the diagnosis is provable from CI without trusting the container measurement, F1 is closed
wider than it was written, and my own sweep says no tenth condition is hiding. Nothing in this
commit is broken.

The risk that remains is in the record, and for this feature that is not a lesser category — the
whole thesis of 015 is that an unaudited record drifts, and the coverage report is about to become
law at T044. Three things carry it. **F3** puts a provably false D10 claim into the suite, in the
commit whose job was to close a review that flagged the identical defect twice; the fix is to
delete two inert lines, and until it is done the branch ships a fixture description that says the
question was answered when it was not. **F1** hands phase 6 a classification of the uncovered
thirteen that the same file contradicts, understating by two the sites no fixture can reach — a
smaller version of exactly what round 1's F1 was about. **F2** shows the audit that produced the
nine only ever asked one of the two questions, and the unasked one has answers: `ritual-checks`
still counts a banner and a tally as conditions, so the asymmetry this commit defends at length is
not actually the kit's practice.

Second-order risk is instrument hygiene: eight self-tests on a copy of the launch path (F4), a
guard that mutates global console state outside its own `try` (F6), and a guard that cannot fail
on the platform most of this work is done on (F5). None is urgent; all three are in the class of
defect this phase just spent a commit discovering, in the file where it discovered it.

Before this remediation can be called done: F3 fixed (it is four small edits, all in `tests/**`),
F1's sentence corrected, and round 1's F8 pair finally corrected — three reviews have now asked.
Before merge (gate 6, once, over the full feature diff): F7's three owner decisions — whether the
2026-09-20 approval is real, whether rewriting a ticked task's text stands against D3c and
`adoption/updating.md:329`, and whether phase 4's Territory is narrowed back; F2 ruled on before
T044; F9 (the `verify-kit` `-notmatch` defect) given a roadmap row, since it still has none and it
reaches three adopted projects through a script they consume verbatim. And the gate itself:
`plan.md` declares `**Gate Certification**: ci-held`, run 35492844050 is green on both legs at
`317e7d3`, and the evidence triplet is therefore available — but `notes.md` carries no phase 4
gate block of the kind phases 1, 2 and 3 each have, and nothing in this review certifies the gate.
That approval is the owner's to record.
