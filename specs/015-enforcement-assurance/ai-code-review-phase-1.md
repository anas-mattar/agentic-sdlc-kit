# AI Code Review — 015 Enforcement Assurance (Phase 1)

**Reviewer**: fresh-context agent — claude-sonnet-5
**Date**: 2026-09-19
**Branches**: agentic-sdlc-kit `015-enforcement-assurance` (tip `4aab0e3c9ab48ac54f2679b5eba8d7cdc6e87878`)
**Scope reviewed**: commit `4aab0e3` in full (30 files: `.github/workflows/enforcement-tests.yml`,
`kit-manifest.json`, `scripts/doc-lint.ps1`, `scripts/update-kit.ps1`,
`specs/015-enforcement-assurance/notes.md`, all 25 files under `tests/enforcement/**`); plus
`spec.md`, `plan.md`, `tasks.md` for this feature; plus the pre-existing
`scripts/enforcement-pack.ps1`, `scripts/scope-check.ps1`, `scripts/scope-lib.ps1`,
`scripts/verify-kit.ps1`, `scripts/build-digests.ps1`, `scripts/roadmap-claim-check.ps1`,
`scripts/ritual-checks.ps1` read to check the harness's claims against the scripts it targets.
Not read in depth: `scripts/scope-check-repos.ps1`, `scripts/territory-check.ps1` (out of phase 1
Territory and not modified by this commit).
**Feature contract**: T001–T012 only — rule inventory for `Invoke-StructureCheck`, the fixture
runner/builder, the coverage reporter (reporting-only, D9), the `kit-only` manifest class, the
two-platform CI workflow, and the mutation proof (SC-002). No behavior change to any script other
than doc-lint.ps1/update-kit.ps1's new class-validation. Declared Territory: `tests/**`,
`kit-manifest.json`, `scripts/update-kit.ps1`, `scripts/doc-lint.ps1`,
`.github/workflows/enforcement-tests.yml`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5
- **Implementer**: Claude Opus 5 (1M context) — claude-opus-5[1m]
- **Inputs provided**: commit `4aab0e3` (`git show --stat` and full diff); `spec.md`, `plan.md`,
  `tasks.md`, `notes.md` for `specs/015-enforcement-assurance/`; the kit's law
  (`.specify/memory/constitution.md`, `docs/sdlc/definition-of-done.md`,
  `docs/sdlc/review-process.md`, `CLAUDE.md`); read/run access to the working tree.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES.** The machinery — real temporary git repositories, a child-process harness
that never imports the code under test, literal hand-written expectations, the mutation proof
that (verifiably) caught two real fail-opens in the harness's own `-Case` filter, the `kit-only`
manifest class correctly out-ranking the `.github/**` verbatim glob — is sound, and every claim I
checked against it (16 tests/23s, the "3 of 78" coverage line, the FitForge dry-run output, the
mutation-proof transcript) reproduced exactly. But the coverage scanner this phase ships
(`Coverage.Tests.ps1`'s `$EmissionPatterns`) silently undercounts real failure-emission sites in
at least three of the nine grading scripts it already claims to have scanned successfully —
not scripts it flags as blind, scripts it reports a plausible-looking non-zero count for. That is
the exact species this feature exists to close (a denominator that quietly shrinks to fit), it is
demonstrable today with grep, and it sits underneath every coverage number phases 3, 4 and
especially 6 (T044, where coverage becomes blocking) will be built on.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (T001–T012 implemented as specified) | Read `tasks.md` phase 1 against the diff: `rules.json` (3 STRUCT-* rules), `lib/FixtureRepo.psm1`, `lib/Harness.psm1`, `Cases.Tests.ps1`, `Coverage.Tests.ps1`, `Run-Tests.ps1`, the `kit-only` class + doc-lint/update-kit enforcement, and the CI workflow are all present and match their task descriptions. |
| Harness runs and passes as claimed | Ran `pwsh -File tests/enforcement/Run-Tests.ps1` myself: `16 passed, 0 failed`, `Tests completed in 23.06s` — matches notes.md's "16 tests, green, 24s" and the commit message. |
| Mutation proof (SC-002) is real, not narrated | Independently inverted `scripts/enforcement-pack.ps1:200` (`if (-not (Test-Path $p))` → `if ($false)`), ran `Run-Tests.ps1 -Case STRUCT-001`: `6 passed, 2 failed` (the STRUCT-001/fail case's two assertions), then restored with `git checkout -- scripts/enforcement-pack.ps1` and reran: `8 passed, 0 failed`. `git status` clean afterward. |
| The two "fail-opens in the harness itself" are actually fixed | Ran `Run-Tests.ps1 -Case STRUCT-999-TYPO` (a filter matching nothing): `enforcement-tests: FAIL — '-Case STRUCT-999-TYPO' matches no case under tests/enforcement/cases.` exit 1 — confirmed the pre-Pester-discovery guard (Run-Tests.ps1 lines 64–78) actually catches a typo filter, including the four coverage tests that previously carried a matchless run to green. |
| FR-006 structural enforcement (harness borrows nothing from scripts under test) | Read `lib/Harness.psm1` in full: it dot-sources/imports only `FixtureRepo.psm1`; the script under test is launched via `Start-Process -FilePath (Get-Process -Id $PID).Path` as a genuine child process, output captured from redirected files, never invoked in-process. |
| `kit-only` class outranks `.github/**` verbatim glob | Read `Get-PatternSpecificity` in both `doc-lint.ps1` and `update-kit.ps1`: a pattern with no `*` gets `1000000 + length`; `.github/**` gets the index of its first `*` (9). The exact-path entry always wins. Confirmed empirically: `pwsh -File scripts/update-kit.ps1 -Target D:/solutions/fitforge -DryRun` → `Applied (3): kit-manifest.json, scripts/doc-lint.ps1, scripts/update-kit.ps1` — neither `tests/**` nor the workflow appears, matching notes.md T012 exactly. |
| `update-kit.ps1`/`doc-lint.ps1` reject an unrecognised class | Read both diffs: both now check `$class -notin @('verbatim','surgical','generated','kit-only')` and fail/error rather than silently skip (T009). |
| CI actually ran and gates the merge | `gh run view 35368886673`: both `enforcement-tests (windows-latest)` and `enforcement-tests (ubuntu-latest)` jobs **succeeded** on this exact commit — SC-006 has real, not merely claimed, two-platform evidence. `ritual-checks` also green on the same push (`gh run list`). |
| Scope guard | `pwsh -File scripts/scope-check.ps1` → `scope-check: PASS phase 1 commit 4aab0e3 (30 file(s))`. Manually cross-checked the 30 changed files against the declared Territory + the always-implicit `specs/015-enforcement-assurance/**` (covers `notes.md`): all resolve. `git diff --stat` confirms nothing outside `tests/**`, the manifest, `doc-lint.ps1`, `update-kit.ps1`, the workflow, and `notes.md`. |
| **Coverage scanner undercounts real failure-emission sites (see F1)** | See F1 below — reproduced independently with a standalone script running the exact six patterns from `Coverage.Tests.ps1` against `doc-lint.ps1`, `verify-kit.ps1`, `build-digests.ps1`. |
| Constitution / domain invariants | N/A per plan's own Constitution Check — no domain-invariants pack declared for this repository; verified `{{DOMAIN_INVARIANTS_PATH}}` is still an unfilled slot in `enforcement-pack.ps1`'s `$Config`. |
| Security (authn/authz, secrets, sensitive logging) | Fixture repos carry a fixture-local git identity (`Fixture Author <fixture@example.invalid>`), never read the caller's `user.name`/`user.email`/signing key (read `New-FixtureRepo`: explicit `git config` calls set these locally per fixture, never `--global`). No secrets or network calls in any new file (`Run-Tests.ps1`, workflow use only `Install-Module`/PSGallery at setup time, not run time, matching FR-018 and D2). |
| Rollback safety | Phase is additive only (new `tests/` tree, one manifest entry, two small guard blocks in existing scripts); reverting the commit removes the harness and the two guards cleanly — no schema, no migration. |

## Findings

### F1 — The coverage scanner's emission-site patterns silently undercount at least 3 of 9 grading scripts, and the phase's own claims overstate what it guards against — BLOCKING

`tests/enforcement/Coverage.Tests.ps1` (lines 28–35) hard-codes six regex patterns to find
"failure-emission sites" across the nine grading scripts, and its own comment (lines 24–27)
asserts: *"Each grading script has its own [idiom]; **all of them put the message in a
double-quoted literal on the emitting line**. A site this misses is a site the inventory can
never be measured against, so the patterns are listed here in the open."* `tests/enforcement/README.md`
repeats the framing: *"A script the scanner finds no sites in is printed as `NO EMISSION SITE
FOUND` rather than omitted. A denominator that quietly shrinks to fit is the defect this whole
feature exists to close."*

Both claims are false for scripts the scanner does *not* report as blind. I reproduced the exact
six patterns against three scripts outside `enforcement-pack.ps1` (the one script the patterns
were evidently modeled on, where all 41 `$script:failures +=` sites are double-quoted and all 41
are found):

- **`scripts/doc-lint.ps1`** — scanner finds 3 sites (lines 132, 139, 147, all
  `$manifestErrors += "..."`). It misses:
  - line 153: `$manifestErrors += 'kit-manifest.json not found at kit root'` — single-quoted, so
    the `'\$manifestErrors\s*\+=\s*"(?<msg>.*)"'` pattern never matches it.
  - line 219: `$broken += [pscustomobject]@{ File = $relFile; Line = $lineNo; Ref = $ref }` —
    **this is doc-lint's own headline rule** (its `.SYNOPSIS` calls doc-lint "asserts every
    repository path referenced by the governance docs resolves" — this is that check), and it is
    entirely invisible to every pattern because the failure is accumulated as an object, not a
    string literal.
  - the `$missingKit` kit-integrity check (lines 108–124-ish, `Where-Object`-filtered, never
    accumulated via a matched `+=` idiom at all).
  So doc-lint.ps1's real distinct failure-emission surface is at least 6, not 3 — and the missed
  ones include the check's actual purpose.

- **`scripts/verify-kit.ps1`** — scanner finds 11 sites. There are **16** `Add-Finding FAIL ...`
  call sites in the file; 7 are missed: lines 165, 190, 196, 204, 280, 305 (single-quoted third
  argument, e.g. `Add-Finding FAIL 'record' 'kit-adoption.json does not parse as JSON' '...'`)
  and line 273 (`Add-Finding FAIL 'record' $problem.Message $problem.Fix` — not a string literal
  at all).

- **`scripts/build-digests.ps1`** — scanner finds 7 sites, but they are almost entirely generic
  wrapper/summary `Write-Host "...FAIL — ..."` lines (169, 172, 229, 230, 239, 240, 253), several
  of which print a **loop variable** (`foreach ($i in $issues) { Write-Host "digests: FAIL — $i" }`,
  line 229) rather than a distinct rule. The **10 real distinct rules** — missing document, empty
  marker, line too long, malformed marker, invalid pack name, duplicate pack name, digest too
  long, missing digest, stale digest, orphan digest (lines 77, 108, 110, 119, 187, 191, 199, 220,
  222, 226, all `$issues +=` / `$script:issues +=`) — are **all** invisible to the scanner, because
  none of the six patterns reference the variable name `issues`. This is the script GAP-025
  (phase 2) fixes; its coverage baseline going into that phase is silently wrong in the direction
  that hides the gap.

This matters because of what phase 1 itself says the mechanism is for. D8/D9 (plan.md) and
`Coverage.Tests.ps1`'s own docstring frame this exact failure mode — "the inventory silently
omits a rule, so coverage reads 100% of a list that is wrong" — as the thing the scanner
cross-checks against. The guard that exists today only catches *total* blindness (a script with
**zero** matched sites, correctly surfaced as `NO EMISSION SITE FOUND` for
`scope-check-repos.ps1` and `territory-check.ps1`). It does not catch *partial* blindness — a
script where the scanner finds some real sites and silently ignores others using a different
quoting or accumulation idiom — which is strictly worse, because it produces a plausible,
non-alarming number instead of a visible "0 of N" or "NO EMISSION SITE FOUND" flag. When T044
(phase 6) makes coverage blocking against this same scanner, a rule the scanner cannot see can
never be required to have a fixture and will never surface as "the inventory is short" — it will
simply never enter the inventory's denominator at all, forever, which is precisely the outcome
this feature's own narrative (commit message, notes.md, README) says it exists to prevent.

*Action: before merge, either (a) generalise `$EmissionPatterns` to also match single-quoted
literals and the `Add-Finding`/array-accumulation idioms actually used in doc-lint.ps1,
verify-kit.ps1 and build-digests.ps1 (and re-verify the other five scripts don't hide the same
gap), or (b) if the patterns are deliberately scoped to `enforcement-pack.ps1`'s idiom for now,
correct the comment in `Coverage.Tests.ps1` and the README so they no longer claim "all of them
put the message in a double-quoted literal" and no longer claim a script with a non-zero count is
"printed... rather than omitted" as if that made its count trustworthy — and record the known
undercount in `notes.md` the same way the `scope-check-repos.ps1`/`territory-check.ps1` blindness
is already recorded, so phases 3/4 inventory against a denominator they know is short rather than
one presented as complete.*

### F2 — `Get-EvidenceMode`/git-identity and no-network constraints hold; fixture repos never touch the caller's git config or the network — ACCEPTED (verified, no defect)

Checked specifically because FR-020/D12 forbid it: `New-FixtureRepo` sets `user.name`,
`user.email`, `commit.gpgsign`, `core.autocrlf` with plain `git config` (repo-local, not
`--global`) before any commit, and the shallow-clone path re-sets identity on the clone rather
than inheriting it. No `git config --global` or `git clone` against a remote URL appears anywhere
in `FixtureRepo.psm1` or `Harness.psm1` — the "shallow" clone source is a `file://` URI of the
just-built local repo. `Run-Tests.ps1`'s only network-touching command
(`Install-Module Pester -RequiredVersion 5.7.1`) lives in the CI workflow's setup step, not in the
run itself, matching FR-018's "no network access at run time" (setup-time is explicitly excused
by plan.md, Assumptions).

*Action: none — recorded as verified rather than assumed, since it is a hunted-for risk (FR-020) with a specific, checkable mechanism.*

## Amendments in this diff

Commit `4aab0e3` does not touch `specs/015-enforcement-assurance/spec.md`, `plan.md`, `tasks.md`,
or any `contracts/` file — confirmed via `git show 4aab0e3 --stat` (only `notes.md` changes under
the spec directory, and `notes.md` is explicitly exempted from the amendment rule by its own
header, which constitution I corroborates: only `spec.md`, `plan.md`, `tasks.md` and `contracts/`
are graded). **None.**

## Constitution re-check (post-implementation)

Re-evaluated `.specify/memory/constitution.md` v0.7.0 against the code as built, not just the
plan's pre-implementation checklist:

- **I (Specification First)**: PASS. No amendment in this diff (see above).
- **II (Source of Truth)**: PASS. No conflict found between spec/plan/tasks and the code.
- **III (Repository Separation)**: N/A, unchanged from plan.
- **IV (Architecture Consistency)**: PASS. Pester 5 (D2) and `kit-only` (D3) are the only additions, both approved in plan.md and both used exactly as decided.
- **V (Domain Invariants)**: N/A, unchanged from plan.
- **VI (Security)**: PASS — see F2.
- **VII (External Integration)**: N/A, unchanged from plan.
- **VIII (Testing Requirements)**: **Engaged, partially undermined by F1.** The harness itself is real and proven (mutation proof, two-platform CI). Its coverage-accounting sub-mechanism is not yet trustworthy across the scripts it claims to measure, which is the exact principle this feature exists to serve.
- **IX (Human Review)**: Satisfied by this review's existence; the Reviewer Provenance block above is filled per gate 5.
- **X (Controlled Delivery)**: PASS on phase boundaries and Territory (scope-check PASS, verified above); phase is oversized relative to the 400-line/15-file guideline (1,270 lines/30 files) but the commit message states the reason (machinery + first proof as one revertible slice) and `enforcement-pack`'s own PhaseSizeWarning fired non-blocking on this exact commit when I ran it, which is the correct, honest outcome for a deliberately-oversized-and-explained phase.

## Test coverage observed

- `tests/enforcement/Cases.Tests.ps1`: 6 fixture cases (STRUCT-001/002/003 × pass/fail) = 12
  Pester `It` assertions (exit code + output match per case). All literal, hand-written
  `expected.txt` files, normalized only for `<ROOT>`/`<SHA>` and line endings.
- `tests/enforcement/Coverage.Tests.ps1`: 4 assertions — inventory-vs-script staleness, inventory
  completeness (pass+fail per rule), orphan-case detection, and the "scanner found something"
  sanity check. The last one is the weakest: it only asserts `$script:AllSites.Count -gt 0`
  globally, which cannot and does not catch F1's per-script undercount.
- Total: 16 tests, 16 passing, reproduced independently (23.06s, Pester 5.7.1, pwsh 7.6.6,
  Windows) and on CI (`gh run 35368886673`, both `ubuntu-latest` and `windows-latest` legs green).
- Critical assertion I specifically stress-tested rather than trusted: the mutation proof (SC-002)
  — inverted a real condition, watched the correct fixture fail with the correct diagnostic, restored,
  watched all 16 pass again.

## Residual risk

The risk concentrates entirely in F1: nothing in phase 1 is unsound as machinery, but the
denominator that phases 3, 4 and 6 will build on and eventually block on is already known (by me,
today, with three concrete scripts and thirteen named line numbers) to be short in a way that is
invisible in the harness's own output. If phase 2 (GAP-025, `build-digests.ps1`) proceeds before
F1 is resolved, its own coverage claims for that script inherit the same blind spot the scanner
has for exactly the rules GAP-025 touches (`$issues +=`/`$script:issues +=`, lines 77–226). I
recommend resolving F1 before or alongside phase 2's start, not deferred to phase 6, since phase 6
is precisely when D9's "reporting-only" grace period ends and this number starts blocking merges.

---

## Implementer dispositions (appended — the reviewer's text above is unedited)

**Round 1, 2026-09-19.** `docs/sdlc/review-process.md` step 4: each finding's disposition is
appended here, never edited into the reviewer's section.

### F1 — coverage scanner undercounts 3 of 9 scripts — BLOCKING — **FIXED**

Verified before acting, because a review's arithmetic is a claim like any other:

```text
verify-kit.ps1     Add-Finding FAIL sites          16   (scanner found 11)
  of which single-quoted third argument             6
build-digests.ps1  $issues += / $script:issues +=  10   (scanner found 0 real rules; its 7
                                                        were the wrapper printing them)
doc-lint.ps1       line 153  $manifestErrors += '…' single-quoted, missed
doc-lint.ps1       line 219  $broken += [pscustomobject]…  the headline rule, missed
```

Every count reproduced. The finding is correct, and its framing is the part worth keeping:
**partial blindness is worse than total blindness**, because a half-seen script reports a
plausible number instead of a visible zero.

Fixed by taking both halves of the suggested action rather than choosing between them.

1. **The patterns are gone.** `tests/enforcement/emission-idioms.json` (new) declares, per
   script, how that script actually emits — three separate idioms for `doc-lint.ps1`,
   `Add-Finding FAIL` for `verify-kit.ps1`, the `$issues` accumulator for `build-digests.ps1`.
   The patterns stop before the message, so quote style is no longer part of matching and a
   non-literal message is still a site.
2. **A second pass measures what the first might be missing.** A deliberately broad recall sweep
   runs alongside, and its hits minus the declared ones print as `unclassified candidate(s)`.
   This is the part that answers F1's real objection: the old guard caught only *total*
   blindness, so a half-seen script passed unremarked. Now the gap has a number.
3. **Undeclared is a written position, not an omission.** A script with no declared idiom must
   say `UNDECLARED` in its note with a reason and the task that resolves it — asserted by a new
   test, so an idiom cannot go missing quietly.
4. **The false claims are corrected.** `Coverage.Tests.ps1`'s docstring no longer asserts that
   every script puts its message in a double-quoted literal, and `README.md`'s coverage section
   now says which three scripts were undercounted, by how much, and why the unclassified count
   is the number to watch rather than the coverage percentage.

The recall sweep was itself wrong on first run and the fix caught it: written as `Write-Host`,
it reported **0** candidates for `scope-check-repos.ps1`, whose `Write-Line` wrapper is exactly
why that script is undeclared — the recall pass reproducing the precise pass's blindness.
Broadened to `Write-\w+`, it now reports 10 there.

What the numbers became:

```text
before   3 of 78 sites, no unclassified measure
after    3 of 88 sites, 31 unclassified candidate line(s) across 6 scripts
         build-digests 7 -> 10 real rules   doc-lint 3 -> 8   verify-kit 11 -> 16
```

Tests: 16 -> **18 passed, 0 failed** (the two new idiom-declaration assertions).

*Reviewer's sequencing point accepted*: this was fixed now, in phase 1, not deferred to phase 6.
Phase 2 fixes `build-digests.ps1`, the script whose real rules were 100% invisible, so its
baseline had to be right before that phase starts.

### F2 — fixture git-identity / no-network isolation sound — ACCEPTED — **no action**

Recorded as verification, not a defect. *Action: none.*
