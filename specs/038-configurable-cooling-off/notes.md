# Notes: Configurable cooling-off period

Evidence for the phases, in order. Decisions are in `plan.md`; this file records what was measured.

## Phase 1: the reader (T001 to T007)

**Baseline on the parent commit (T001).** `08a7cef` (the approved spec, plan and tasks; no script differs from `main`),
a full harness run on an isolated detached worktree: **2047 passed, 0 failed, 0 skipped**, exit 0. The coverage report
on that commit: 291 of 308 declared emission sites owned by a fixtured rule, 8 exempt, 9 declared not a rule, across 11
grading scripts. `enforcement-pack.ps1`: 86 of 93 sites fixtured (3 exempt, 4 not a rule); `verify-kit.ps1`: 36 of 37
(1 exempt). `CRIT-S02/fail` and `CRIT-S03/fail` and `/pass` all pass. Saved output: the scratchpad's `baseline-p1.txt`.

**Probes (T002).**

- `Run-Tests.ps1` sets `Run.Path` to `tests/enforcement/`, so a new `*.Tests.ps1` is discovered with no registration.
  `Coverage.Tests.ps1` scans fixture cases and the grading scripts' emission sites, not the Pester files, so the new
  file needs no inventory entry.
- `ScopeLib.Tests.ps1` dot-sources the library from `../../scripts/`, builds a throwaway directory under the temp path in
  `BeforeAll`, and removes it in `AfterAll`; `CoolingOff.Tests.ps1` does the same.
- `Get-DeveloperMode` returns a hashtable, reads the record inside a try with `-ErrorAction Stop`, tests the root as text
  for a leading `{`, and reports `Problems` as `@{ Message; Fix }` with `Severity = 'warn'` only for a warning; a problem
  with no `Severity` is a failure. `Get-CoolingOff` follows all four.
- `ConvertFrom-Json` (pwsh 7.6.7) types a JSON number as `Int64`, `Double` or `BigInteger`; `4.0` and `1e3` are
  `Double`; `1e999` is `Double` infinity (not a parse error); `-0` is `Int64` 0; a bare `null` is `$null` and is
  indistinguishable from an absent key unless the property list is asked (`PSObject.Properties['coolingOffHours']`),
  which is why the reader asks it. Strict mode throws on `$record.coolingOffHours` for an absent key, so the reader never
  uses that form.

**The tests first (T003).** `tests/enforcement/CoolingOff.Tests.ps1`: 51 tests, one row per shape (nothing declared, 24
and above, 1 to 23 with a usable reason, 1 to 23 with an absent, empty, whitespace, numeric, null, array and object
reason, thirteen unaccepted values, a reason with no value) plus the unusable records (missing, a directory by that name,
a root array, a root string, text that does not parse, an empty file), the reason's line-break rule, the whole-number
rule, nested and quoted keys not counting, and the two constants. Run against the parent commit: **51 failed, 0 passed**,
50 because `Get-CoolingOff` does not exist and 1 because the constants are undefined, as they should.

**The reader (T004, T005).** `Get-CoolingOff` and the two constants (`$script:CoolingOffDefaultHours = 24`,
`$script:CoolingOffFloorHours = 1`) in `scripts/adoption-lib.ps1`, inserted between `Get-DeveloperMode` and
`Get-CriticalSurfaces`; the file's header comment names it. No existing function was edited. Run: **51 passed, 0 failed**.
A strict-mode smoke run (`Set-StrictMode -Version Latest`, `$ErrorActionPreference = 'Stop'`) over `{}`, a justified 4,
`"8"`, a twenty-digit integer and `null` gave 24, 4, 24, a finite double and 24.

**One edge to know about.** A whole number past 2^53 (about 9e15) hours is accepted and returned as a double, because the
plan's rule is "finite", not "small"; `99999999999999999999` therefore comes back as a period of about 1e20 hours and
prints in scientific notation. Nothing can merge under it. It is a typo no honest record contains, and the plan states no
upper bound (spec Assumptions), so the reader does not invent one; if the owner wants a ceiling it is a spec change.

**Full run on the phase 1 working tree (T006).** The first run, before a fix, gave 2076 passed and **22 failed**, all in
`CoolingOff.Tests.ps1`: `Run-Tests.ps1` sets strict mode, and the test read `$_.Severity` on a problem hashtable that
carries no such key for a failure (the convention `Get-DeveloperMode` follows), which throws under strict mode. The same
table passed when run alone, outside strict mode, which is why the defect only showed in the full run. The reader now
always sets `Severity` (`'fail'` or `'warn'`), its header comment says why, and the test reads it directly. The second
full run: **2098 passed, 0 failed, 0 skipped** (the baseline's 2047 plus the 51 new tests), exit 0. Coverage report
identical to the baseline: 291 of 308 sites, 8 exempt, 9 not a rule, every per-script count unchanged. `doc-lint.ps1`
OK; `ritual-checks.ps1` reports nothing failed (the scope check is UNGRADED until a phase commit exists).

The phase 3 consumer in `verify-kit.ps1` must keep reading `Severity` the way the roster loop does
(`$problem.Severity -eq 'warn'` is warn, anything else is a failure); both forms work with this reader.

Diff: `scripts/adoption-lib.ps1` (+114, -2: the two header lines) and one new file under `tests/enforcement/`. No existing
function was edited.

**Fresh-context review of phase 1 (`ai-code-review-phase1.md`, claude-opus-5-5): REQUEST CHANGES.** Ten findings. What was
done, in a remediation commit with `phase 1` in its subject:

- **F1 (BLOCKING), fixed.** Reproduced first: a reason of zero-width spaces, a lone BOM or a NUL was honored as a real
  reason, and an ESC sequence passed into `Reason`. The reader now removes invisible format characters (`\p{Cf}`), turns
  control characters and line and paragraph separators (`\p{Cc}`, `\p{Zl}`, `\p{Zp}`) into a space, collapses and trims,
  and only then tests for blank. Format characters are removed, not spaced, so a word written with a zero-width joiner
  (common in Persian and Arabic text) stays whole. **Not done, and an owner call:** a length limit on the reason. None is
  imposed; the review notes a 100,000-character reason is honored whole.
- **F2 (BLOCKING), fixed.** The table now has a `Reason` per row (derived: `'why'` for an honored period under 24, `$null`
  elsewhere, or stated on the row), rows for each blank-looking reason, an ANSI-bearing one, a separator one and a joiner
  one, and dedicated tests for four huge whole numbers, `Why` per branch and the warning stream. 66 tests, up from 51.
  Eight mutants of the library were then run on a scratch copy, and each fails at least one test: the reviewer's M1 (a
  reason leaked on the 24-and-over path: 5 failures), M3 (a constant `Why`: 1), M4 (a 64-bit cast: 4), the old blank rule
  (7), control characters left alone (3), format characters kept (2), the warning not suppressed (1), the plural (1).
- **F3 (CONFIRM), open: an owner decision before phase 3.** `Declared` reflects `coolingOffHours` only, so a doctor block
  gated on it (T021) would drop the reason-with-no-value warning and could not tell that either key is declared in team
  mode. Options are in the report to the owner; nothing was changed.
- **F4 (MINOR), accepted.** Past 2^53 hours `Hours` is a double, not "always an integer". Nothing in the pack's
  arithmetic is affected; recorded here rather than amending `data-model.md`, whose wording an approver would have to sign.
- **F5 (MINOR), accepted.** Fractional is judged after double rounding; the difference is under 1e-15 hours and goes both
  ways.
- **F6 (MINOR), accepted.** The last of two duplicate keys wins and key names are case-insensitive, as in
  `Get-DeveloperMode`. Phase 3 could warn on a duplicated key if the owner wants it (a question, not work).
- **F7 (MINOR), fixed,** with a test that merges the warning stream into the output and finds no record.
- **F8 (MINOR), partly.** The test was renamed to what it asserts. The constants stay ordinary script variables: a
  `ReadOnly` option makes a second dot-source of the library throw, and no shipped caller assigns them.
- **F9 (MINOR), fixed:** "1 hour", and every record-level `Why` now names the 24-hour default.
- **F10 (DOC DRIFT), fixed:** the file's `.DESCRIPTION` names the reader and why the constants live here.

**Phase 2 fixtures, written first (T009 to T013), parked.** They were generated, with hand-written expectations, and run
against the unchanged `enforcement-pack.ps1`. On the parent: all 6 `CRIT-C01` cases failed, all 13 `CRIT-C02` cases
failed, and of the new `CRIT-S03` variants only `fail-declared-48` failed, the other four (declared 24 either side, 48
passing, a root-array record) passing as the byte-identical controls they are; the two `CRIT-T01` team-arm variants pass,
as they must. They were then removed from the working tree so phase 1's remediation could be gated on its own, and are
regenerated by the generator script before phase 2 resumes. Two deviations from the task text, within its note that the
ids are provisional: the cases for an explicit 24, a value above 24 and a record that cannot be read are variants of the
existing rule `CRIT-S03` (they exercise its message), and the team-arm cases are variants of `CRIT-T01`, so the new
rules are `CRIT-C01` (the honored-period warning) and `CRIT-C02` (the set-aside warning) only.

**Owner decisions on the review's two open points (anas.m, 2026-10-23).** F3: the reader gains `AnyDeclared` (true when the
record carries either key, a reason with no value included) now, while nothing calls it, and phase 3's doctor block gates
on it; this amends `plan.md` P2 and P6 and `tasks.md` T004 and T021 (each carries an `Amendment approved by` line) and
`data-model.md`. Tests: a column's worth of assertions on every row, the null-reason row, and the unusable, missing,
directory and nested-key cases; two mutants of the new field fail 2 and 27 tests. F1's open question: **no length limit**
on the reason, so the contract stands as approved.
