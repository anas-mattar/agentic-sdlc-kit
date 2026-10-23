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

**Phase 1, final state, gated (owner, 2026-10-23).** On the final phase 1 commit `633d63c`: full harness **2114 passed, 0
failed** (the baseline's 2047 plus 67), `doc-lint.ps1` OK, coverage report unchanged (291 of 308 sites). Run by the agent
on a clean checkout and, separately, by the owner on the working tree with the same totals. This is the baseline phase 2
is measured against.

## Phase 2: the check reads it (T008 to T017)

**Baseline (T008).** The phase 1 commit above: 2114 passed, 0 failed. Every existing `CRIT-S*`, `CRIT-R*` and `CRIT-T*` case
passed in it, and they are unchanged by this phase.

**Fixtures first (T009 to T013).** 25 new cases, generated with hand-written expectations (the wording was fixed in
`plan.md` P4 and P5 before any was written): `CRIT-C01` (6: an honored 4h either side, the 1h floor either side, a whole
number written `4.0`, a reason with a line break), `CRIT-C02` (13: no reason, a blank reason, a numeric reason, and each
unusable value: 0, negative, fractional, a string, a boolean, null, an array, an object, with a pass at 25h and fails at
23.5h), five `CRIT-S03` variants (a declared 24 either side, a declared 48 either side, a record whose root is an array) and
two `CRIT-T01` team-arm variants copied from the existing team fixtures with only the record changed. Against the unchanged
`enforcement-pack.ps1`: all 6 `CRIT-C01` and all 13 `CRIT-C02` cases failed, and of the five new `CRIT-S03` variants only
`fail-declared-48` failed; the declared-24 pair, `pass-declared-48` and the root-array record passed because they are the
byte-identical controls they were written to be, and so did both team-arm variants.

**The change (T014, T015).** `Invoke-CriticalSoloEvidence` in `scripts/enforcement-pack.ps1` reads `Get-CoolingOff -Root $Root`
first; a value set aside prints one WARN carrying the reader's own message and "the 24h default applies instead"; an honored
period under the default prints one WARN naming the period and quoting the reason; the "recorded too recently" failure
compares against the period in effect and, only when that is not 24, gains `declared in kit-adoption.json coolingOffHours;`
inside its parenthesis, so at 24 it is word for word the old message. `$Config.CoolingOffHours` is removed and says where the
default now lives; the header comment is updated. `Invoke-CriticalTeamEvidence`, the clock read and the merge-readiness code
are untouched. `rules.json` gains `CRIT-C01` and `CRIT-C02` (the two new emission sites) and `CRIT-S03`'s `law` and notes are
updated; no new idiom was needed. Two deviations from the task text, both within its note that the ids are provisional: the
explicit-24, above-default and unreadable-record cases are variants of `CRIT-S03`, and the team-arm cases are variants of
`CRIT-T01`.

**Run (T016), 2026-10-23, on the phase 2 working tree.** `-Case` runs of `enforcement-pack/CRIT-C01`, `CRIT-C02`, `CRIT-S03`
and `CRIT-T01` passed first (174, 188, 176 and 174, 0 failed; each also runs the coverage, inventory and reader tests). An
earlier full-harness attempt was killed by the system for low memory; it was rerun alone and finished. Full harness **2166
passed, 0 failed, 0 skipped** (phase 1's 2114 plus 52), exit 0, 2656s. `doc-lint.ps1` OK. `ritual-checks.ps1` RESULT OK
(doc-lint, enforcement-pack, scope-check on the three phase 1 commits, digests 5 fresh, roadmap-claims OK; scope-repos and
verify-kit n/a). Coverage sweep: 293 of 310 sites owned by a fixtured rule, against phase 1's 291 of 308: the two new sites
(`CRIT-C01`, `CRIT-C02`) are both fixtured, the exempt and not-a-rule counts are unchanged, and `enforcement-pack.ps1` reads
88 of 95. Every pre-existing case passed in the same run. This is agent-run evidence only; the owner's gate is the
certification.

**Phase 2, final state, gated (owner, 2026-10-23).** Committed as `942d7b5`; `scope-check.ps1` PASS (82 files). The owner ran
`pwsh -File scripts/ritual-checks.ps1` on that commit: RESULT OK (doc-lint, enforcement-pack, scope-check on all four phase
commits, digests, roadmap-claims; scope-repos and verify-kit n/a), exit code 0 confirmed. `PhaseSizeWarning` on `942d7b5`
(2122 lines, 82 files, non-blocking): 75 of the 82 files are the 25 fixture cases at three files each; the script change is
28 lines. This is the baseline phase 3 is measured against (T018).

## Phase 3: the doctor reports it (T018 to T023)

**Baseline (T018).** The phase 2 commit `942d7b5` (gated by the owner, exit 0): full harness 2166 passed, 0 failed. `-Case
verify-kit/` on that tree, run alone before any phase 3 file existed: **316 passed, 0 failed**, exit 0, over the 77 existing
`VK-*` cases (VK-001 to VK-032; VK-028 is the exempt top-level catch, so the new ids start at VK-033). Existing expectations
are not edited in this phase, so "a record declaring neither key prints nothing new" is shown by every existing `VK-*` case
passing with its `expected.txt` untouched; `git diff` against `942d7b5` for `tests/enforcement/cases/verify-kit/` shows only
new `VK-033` to `VK-036` directories.

**Fixtures first (T019, T020).** 26 cases in four rules, expectations written by hand from the wording in `plan.md` P6 and
`contracts/kit-adoption-cooling-off.md`, generated from the `VK-031` project by changing only the `kit-adoption.json` lines:
`VK-033` (the FAIL: eleven failing directions, one per unusable shape, and one pass), `VK-034` (the unused-reason WARN: a
reason alone, a reason on 48, and a pass), `VK-035` (the team-mode WARN: a short period, 48, an unusable value, and a pass
with neither key) and `VK-036` (the accepted declaration stated back: a short period with a reason, 48, an explicit 24, 4.0,
a reason with a line break, the floor of one hour, and a pass with neither key). The four rules were added to `rules.json`
with their anchors and laws before the first run, because the harness refuses a case whose rule it does not know. No change
to `emission-idioms.json`: the existing `Add-Finding (FAIL|WARN|ok)` accumulator already sees every new site, and the four
new lines are four new sites, each anchored by its own rule. Against the unchanged `verify-kit.ps1`, **23 of the first 25
cases failed** (output or exit code) and the two controls passed: `VK-035/pass` and `VK-036/pass`, the records that must print
nothing new. `VK-036/fail-floor-1h` was added after the doctor edit, when its singular wording was written, so it was never
shown failing on the parent; it passes now and its expectation was written before it was run.

**The change (T021).** One block in `scripts/verify-kit.ps1` after the `developers` block, gated on `Get-CoolingOff`'s own
`AnyDeclared`: each reader problem is reported with the severity it carries (FAIL or WARN, the doctor never decides it); an
accepted declaration prints one `ok` line stating the period and, below 24, quoting the reason; either key declared when
`$devMode.Mode` is `team` adds one WARN that the setting has no effect there. A record declaring neither key prints nothing.
The doctor does not interpret the record: hours, reason and every message come from the library. One deviation worth the
owner's eye: in team mode the `ok` line is still printed, as plan P6 says the warning is *added*; it says "declares", not
"applies", and the WARN beside it says no period applies there.

**Edit hazard, recorded.** The edit tool rewrote `scripts/verify-kit.ps1` with CRLF endings (git showed 769 changed lines for a
29-line edit). It was normalised back to the repository's LF before this run completed; `git diff --stat` is now 29 insertions.

**Run (T022), 2026-10-23, on the phase 3 working tree.** Full harness **2218 passed, 0 failed, 0 skipped** (phase 2's 2166
plus 52, the 26 new cases at two assertions each), exit 0, 2396s, run alone. `-Case verify-kit/`: **368 passed, 0 failed**
(the baseline's 316 plus the same 52), rerun after the new fixtures were normalised to the repository's LF endings (they were
first written with CRLF; `git ls-files --eol` now reads `i/lf w/lf` for all 78 files). `doc-lint.ps1` OK. `ritual-checks.ps1`
RESULT OK (verify-kit and scope-repos n/a). Coverage sweep: 297 of 314 sites owned by a fixtured rule, against phase 2's 293
of 310: the four new sites are `VK-033` to `VK-036`, the exempt and not-a-rule counts are unchanged, and `verify-kit.ps1`
reads 40 of 41 (the one exempt site is the top-level catch). Every pre-existing case passed in the same run with its
expectation unedited. Agent-run evidence only; the owner's gate is the certification.

**Phase 3, final state, gated (owner, 2026-10-23).** Committed as `fa7f412`; `scope-check.ps1` PASS (82 files). The owner ran
`pwsh -File scripts/ritual-checks.ps1` on that commit: RESULT OK (doc-lint, enforcement-pack, scope-check on all phase
commits, digests, roadmap-claims; scope-repos and verify-kit n/a), exit code 0 confirmed. `PhaseSizeWarning` on `fa7f412`
(3421 lines, 82 files, non-blocking): 78 of the 82 files are the 26 fixture cases at three files each; the script change is
29 lines. This is the baseline phase 4 is measured against.

## Phase 4: guidance, flow-down and digests (T024 to T030)

**Search before editing (T024), 2026-10-23.** Searched `scripts/`, `tests/enforcement/` and every governance doc for the
phrases "24-hour", "24h", "24 hours", "cooling-off" and `coolingOff`, and read each hit that is not feature history.

- **Machine rules keyed on the wording of item 5: none.** No script other than the three this feature already changed
  (`adoption-lib.ps1`, `enforcement-pack.ps1`, `verify-kit.ps1`) mentions it; `doc-lint.ps1`, `build-digests.ps1` and
  `ritual-checks.ps1` match nothing. The pack and the doctor cite the rule as "docs/sdlc/critical-delivery.md item 5", a
  label this phase does not change. `rules.json` `law` fields that name the period (`CRIT-S03`, `CRIT-C01`, `CRIT-C02`,
  `VK-033` to `VK-036`) were written or updated in phases 2 and 3.
- **The one generated coupling is the digest marker** for item 5 (`docs/sdlc/critical-delivery.md`, the line reading "solo
  devs substitute a second-model review + 24h cooling-off"), which feeds `docs/digests/critical-digest.md`. It is inside this
  phase's Territory and is rewritten here; the digest is rebuilt by the script, never edited.
- **In Territory, edited:** `docs/sdlc/critical-delivery.md` (item 5: the rule text, the solo arm line, the honesty
  sentence, a new paragraph "The cooling-off period", the "24 hours old in solo mode" passage under feature 024's heading,
  the marker); `adoption/updating.md` (the two passages that call the wait 24 hours, the arm table row, a section on
  declaring the period, a flow-down note).
- **Outside Territory, not edited, listed for the owner.** (1) `.specify/memory/constitution.md` lines 122, 154 and 195. Lines
  122 and 154 are prior-version history (the 0.4.1 and 0.3.0 rationales) and stay true as history. Line 195 is in the
  "Templates requiring updates" list: it says `scripts/enforcement-pack.ps1` "encodes constitutional constants (...
  Critical cooling-off hours ...)" that must change in lockstep with an amendment. After this feature the default and the
  floor live in `scripts/adoption-lib.ps1`, and `enforcement-pack.ps1` no longer holds the constant. The constitution's
  principles do not state the 24 hours (item 5 of `critical-delivery.md` does), so no principle conflicts; the list entry is
  now a stale pointer, a bookkeeping matter. Touching it is a constitution edit, which this phase may not do and which would
  need the owner's recorded approval. (2) `specs/_templates/human-pr-review-template.md` line 17 says "the cooling-off period"
  without a number: still true. (3) `docs/roadmap.md` lines 31, 49, 51 and 601 describe the 24-hour period in rows about earlier
  gaps and features: history. (4) `tests/enforcement/lib/FixtureRepo.psm1` comments: harness text.
- **Not in a Territory-bound rule:** nothing above is a rule that fails on the phrase, so T024's stop condition (a rule
  outside Territory that keys on it) did not arise.

**The edits (T025 to T027).** Item 5 now says: 24 hours by default; a project may declare a shorter period (down to one hour)
or a longer one; a period under 24 needs a written reason and every run that applies one says so; a shorter period is a
further weakening the record and the warning show and do not remove; the doctor reports every case; and, in one place beside
the rule, that the declaration sits in the same repository as the feature and is checked by review at gate 6 (plan P9). Two
deviations from the task text, for the owner's eye: (a) the team-arm Honesty paragraph ended "The solo arm is unchanged and
never reads the human review"; "is unchanged" would now be untrue for a project that declares a period, so it reads "The solo
arm never reads the human review". Every other mention of the team arm is untouched. (b) The passage under feature 024's heading
in `critical-delivery.md` that said a solo branch is red until the artifact is "24 hours old" now says "as old as the
cooling-off period (24 hours by default)", the same fact as the two passages T027 names in `updating.md`.

**Digest marker length.** The item 5 marker is capped at 120 characters by `build-digests.ps1`; my first wording was 137 (measured against the limit before the first
build, so the build never saw it). It reads "Critical 5: reviewer is never the owner; solo devs: second-model review +
cooling-off, 24h default, less needs a reason." (120). A marker added to `adoption/updating.md` for the flow-down note was
dropped: the adoption digest was already at its 40-line cap and one more made it 41, so the build refused. The other markers
were not touched to make room; the rule is carried by the critical digest.

**Digest rebuild (T028).** `pwsh -File scripts/build-digests.ps1` then `-Check`: OK, 5 digests fresh, 124 markers. Only
`docs/digests/critical-digest.md` changed, by one line; no other digest changed. It was written by the script alone.

**Determination and limits (T029).**

- **No constitution amendment is needed (plan P8).** The independence rule of Principles IX and X is parameterised, not
  changed: the constitution delegates the Critical-solo substitute to `docs/sdlc/critical-delivery.md` item 5 and states no
  number in a principle. The one stale reference, the sync-list entry above, is a bookkeeping pointer and is the owner's to
  decide on; it is not part of this feature's approved scope.
- **The limit (plan P9).** The declaration is read from the working tree of the repository being checked, so an owner can
  shorten their own wait in the same pull request that needs it; the reason is a written claim, not a verified one; and
  shortening the period after the review was committed applies against the original first-commit time, because the clock
  does not restart. The warning prints on every run and the change shows in the diff; gate 6 is where it is caught. The
  guidance says so beside the rule, in item 5 and in the flow-down note.
- **Follow-up the owner may want, as a note and not as work:** read the declaration from the diff base rather than the working
  tree, which would close the same-branch limit. That is a separate feature with its own spec.

**Run (T028), 2026-10-23, on the phase 4 working tree.** Full harness **2218 passed, 0 failed, 0 skipped** (identical to
phase 3's count: this phase adds no case and changes no script), exit 0, 2344s, run alone. `doc-lint.ps1` OK.
`scripts/build-digests.ps1 -Check` OK (5 digests fresh, 124 markers). `ritual-checks.ps1` RESULT OK (verify-kit and
scope-repos n/a). Coverage sweep unchanged at 297 of 314. `git diff --stat` before the commit: `adoption/updating.md`,
`docs/sdlc/critical-delivery.md`, `docs/digests/critical-digest.md` (one line) and this file; nothing under `scripts/` or
`tests/`. Agent-run evidence only; the owner's gate is the certification, then the fresh-context AI review and the human
review (T030).

**Phase 4, final state, gated (owner, 2026-10-23).** Committed as `527c099`; `scope-check.ps1` PASS (5 files). The owner ran
`pwsh -File scripts/ritual-checks.ps1` on that commit: RESULT OK (doc-lint, enforcement-pack, scope-check on all four phase
commits, digests, roadmap-claims; scope-repos and verify-kit n/a), exit code 0 confirmed. All four phases are gated. T030's
two reviews remain: the fresh-context AI review (never self-graded, with the Reviewer Provenance block) and the human review.
Open for the owner: the constitution sync-list pointer at `.specify/memory/constitution.md` line 195 (listed above), not edited.

## AI review of phases 2 to 4 (T030), 2026-10-23

Filed as `ai-code-review-phases-2-4.md`: a fresh-context agent on a different model from the implementer (reviewer
claude-opus-5-5, implementer claude-sonnet-5-5), verdict **approve with changes**, nothing blocking in the scripts. The reviewer
ran `CRIT-C0` (200 passed) and `VK-03` (240 passed) and did not run the full harness. The review file is the reviewer's own and
is not edited here; the dispositions are recorded in this section.

| Finding | Disposition |
|---|---|
| F1 constitution wording (history lines 119-123, sync list 194-198) | **Decided by the owner, 2026-10-23: correct it as a constitution PATCH, 0.8.0 to 0.8.1** (sync-list bookkeeping, no principle text, earlier history untouched). Amended into spec Assumptions, plan P8 and the phases list, and built in phase 5 (T035, T036). |
| F2 "a typo can never shorten it" is false above 24 | **Fixed** (owner's instruction, 2026-10-23). `docs/sdlc/critical-delivery.md` and `adoption/updating.md` now say every fallback lands on 24 hours, never below it, and that a typo in a period meant to be longer (`"48"`) also falls to 24, shorter than meant, with the pack's WARN and the doctor's FAIL naming the value read. **The same overclaim in two comments of `scripts/adoption-lib.ps1` (lines 221 and 293, phase 1 code) is corrected in phase 5 (T037), and `spec.md` line 77 was amended with an approver record, both on the owner's decision of 2026-10-23.** |
| F3 "the WARN prints on every run, whether or not the review exists yet" is false mid-feature | **Fixed.** Both documents now say it prints on every run that grades the solo arm, including when the review is missing, and not while the branch is evidently mid-feature or the plan says `**Merge Readiness**: pending`, where the check returns before it reads the review. Confirmed by reading `enforcement-pack.ps1` lines 620-639 against the call at line 646. |
| F4 no fixture pins the reader call before the missing-review return; T011's unreadable record absent | **Fixed.** Four cases, expectations written by hand: `CRIT-C01/fail-review-missing` and `CRIT-C02/fail-review-missing` (no review committed: the WARN prints, then the run fails on the missing review) and `CRIT-S03/fail-record-unreadable` (`kit-adoption.json` is a directory) and `CRIT-S03/fail-record-unparsable`, each expecting the root-array output. Mutation check: with the missing-review return moved ahead of the reader call, the two `fail-review-missing` cases fail (163 passed, 3 failed) and the pre-existing fixtures did not; the script was restored and `git diff scripts/` is empty. |
| F5 team-mode doctor FAIL says "24 hours applies" where no period applies | **Decided by the owner, 2026-10-23: a warning in team mode** (the doctor still names the field and the value read, and says the 24-hour default applies if the project goes solo). Amended into spec FR-011 and its edge case, plan P6, the contract and the data model; built in phase 5 (T032 to T034). |
| F6 the failure's extra clause is worded differently from the approved contract | **Recorded, not changed.** FR-008 is met; the wording is the contract's clause with `declared in kit-adoption.json coolingOffHours;` inside the existing parenthesis, shown in notes under Phase 2. Whether that needs an approver record is the owner's call. |
| F7 T011 to T013 name rules (`CRIT-C03`, `CRIT-C04`, `CRIT-C05`) that do not exist | **Fixed by amendment.** The three task texts now say where each shipped (`fail-unaccepted-*` of `CRIT-C02`; the `CRIT-S03` variants; the `CRIT-T01` variants). **Amendment approved by**: anas.m, 2026-10-23, on the owner's instruction in this session to fix F7; the amendment commit names the same approver. |
| F8 a rejected value is echoed without filtering direction-override characters | **Recorded, not changed.** Cosmetic, phase 1 code, outside this fix. |
| F9 the doctor prints "adoption record valid" beside a cooling-off FAIL | **Recorded, not changed.** Existed before this feature. |

**Run after the fixes, 2026-10-23.** Full harness **2226 passed, 0 failed, 0 skipped** (2218 plus the 8 assertions of the four new
cases), exit 0, 2566s, run alone. `doc-lint.ps1` OK, `build-digests.ps1 -Check` OK (the digest marker is unchanged, so no
digest changed), `ritual-checks.ps1` RESULT OK. Coverage sweep unchanged at 297 of 314 (no new emission site). Agent-run evidence
only; the owner's gate is the certification.

## Phase 5: the owner's decisions on the AI review (T031 to T039)

**Baseline (T031).** The tree at `c5bace3`, whose code is the phase 4 code plus the review-fix fixtures: full harness **2226
passed, 0 failed, 0 skipped**, coverage 297 of 314 sites, `ritual-checks.ps1` RESULT OK (run by the agent, 2026-10-23). The
owner's gate stands on `527c099`; the review fixes and this phase are not yet gated.

**Fixtures first (T032, T033).** New rule `VK-037` (a malformed `coolingOffHours` or a missing reason in team mode is a
warning), three cases with hand-written expectations: `fail` (team, `0` with a reason), `fail-no-reason` (team, `4`, no
reason) and `pass` (team, an accepted `48`). `VK-035/fail-unaccepted-value`, whose expectation was a failure, was removed:
its scenario is now `VK-037/fail`, with a warning and exit 0. The `VK-035` note was updated. Against the unchanged
`verify-kit.ps1`: both new failing cases failed on both assertions and the `pass` control passed; the run showed 6
failures, the 4 assertions plus the 2 coverage tests that cannot find the new anchor.

**The change (T034).** In the cooling-off block of `scripts/verify-kit.ps1`, a reader problem of severity `fail` is reported as
a warning when `$devMode.Mode` is `team`, with the reader's message unchanged and a team-mode fix ("correct it before the
project goes solo: in team mode no cooling-off period applies, so it changes no verdict today, and solo the value is set aside
and 24 hours applies until it is fixed"); in solo mode it is the failure it was, byte for byte. The reader's own warnings (an
unused reason) keep their text in both modes. One added code line and a comment.

**The constitution (T035).** PATCH 0.8.0 to 0.8.1, sync-list bookkeeping: a new SYNC IMPACT entry above the former top one (which
moved down as "Prior version history (0.7.0 → 0.8.0)"), the footer, and the "Templates requiring updates" list: the entry for
`scripts/enforcement-pack.ps1` no longer names the Critical cooling-off hours, and a new entry names `scripts/adoption-lib.ps1`
for the default and the floor. `git diff` removes exactly three lines (the version-change line, the old list line, the
footer); no principle and no historical rationale changed. The edit tool left the file with CRLF endings and it was
normalised back to LF, as `verify-kit.ps1` was earlier in this feature.

**The guidance and the comments (T036, T037).** The feature 038 flow-down note in `adoption/updating.md` now says the
constitution takes a PATCH, what an adopter does about it (re-express only the one sync-list entry, only if their list carries
it), that a malformed value in team mode is a warning, and the section that declares the keys says the same. The two comments
in `scripts/adoption-lib.ps1` that said a typo can only get the longer wait now say it can never get a wait below the default
and that a mistyped longer period also falls to the default; `git diff` for that file shows comment lines only.

**Run (T038), 2026-10-23, on the phase 5 working tree.** Full harness **2230 passed, 0 failed, 0 skipped** (the baseline's 2226,
minus the 2 assertions of the moved case, plus the 6 of the three new ones), exit 0, 2332s, run alone. A first attempt was killed
by the system for low memory before it finished; it was not restarted until asked, and the rerun finished. `-Case verify-kit/`:
**372 passed, 0 failed**. `doc-lint.ps1` OK. `build-digests.ps1 -Check` OK (5 digests fresh, 124 markers; no marker changed).
Coverage sweep **298 of 315** (297 of 314 plus the one new site, covered by `VK-037`), `verify-kit.ps1` 41 of 42, exempt and
not-a-rule counts unchanged. Every pre-existing case passed with its expectation unedited, apart from the one that moved.
Agent-run evidence only; the owner's gate is the certification.
## AI review of the review fixes and phase 5, 2026-10-23

Filed as `ai-code-review-phase5.md`: a fresh-context agent on a different model from the implementer (reviewer claude-opus-5-5,
implementer claude-sonnet-5-5), scope `40cb039..HEAD`, verdict **approve with changes**, nothing blocking. It judged F2, F3 and
F4 actually fixed, F1 and F5 built as decided, the constitution PATCH to change exactly what it says (three removed lines, no
principle or history touched) and PATCH to be the right bump, and the doctor correct for every combination of roster and
declaration it tried. It marked one thing unverified: every approver record was written by the implementing session, so the
repository alone cannot show the owner made these decisions; they rest on the owner's instructions in the session, and the
owner's human review is where that is read. The review file is the reviewer's own and is not edited here. The owner's decision
on its findings (2026-10-23): go with the implementer's recommendation.

| Finding | Disposition |
|---|---|
| G1 `updating.md` says "Nothing surgical" beside the constitution change | **Fixed.** The 038 flow-down note now says one surgical item is reported, the constitution (the update lists it and exits 2), and that a project whose sync list does not carry the old entry has nothing to re-express. |
| G2 the team-mode message hardcodes "24 hours" | **Fixed.** It reads `$script:CoolingOffDefaultHours` from the library, as the pack does. `VK-037`'s anchor changed to the double-quoted form. |
| G3 nothing catches the team check widening to "any roster" | **Fixed.** New case `VK-033/fail-one-developer` (a roster of one is the solo arm: the failure stands, exit 1). Mutation check: with the team test widened to `$devMode.Declared`, the new case fails (186 passed, 2 failed) and the script was restored from a backup; `git diff` shows only the intended edit. |
| G4 the contract words the failure clause differently from the code (F6) | **Owner decision: amend the documents to match the code.** Contract, plan P5, quickstart and task T009 now say the clause `declared in kit-adoption.json coolingOffHours;` opens the existing parenthesis, before the hours remaining. Approver record in the amendment commit. |
| G5 `e8b0f86` ticks T031 to T038 one commit before the work that ticks them | **Recorded.** It was the commit that carried the Territory fix, made after the work existed in the working tree and before it was committed. The history shows the ticks first; the tree at `9328f16` had all of it. |
| G6 `critical-delivery.md` says the doctor reports a mistyped value "as a failure" | **Fixed.** It says "a failure (a warning in team mode, where no period applies)". `docs/sdlc/critical-delivery.md` was added to phase 5's Territory by an amendment commit made before the fix (record in its commit). |
| G7 in team mode the doctor's `ok` line says the pack prints a warning on every Critical solo check | **Fixed.** The clause is omitted in team mode; solo output is byte-identical. `VK-035/fail`'s expectation changed accordingly. |
| G8 "a typo cannot take the wait under the default" is too broad (`2` for `24` is accepted as 2 hours) | **Fixed** in `critical-delivery.md`, `updating.md`, spec User Story 3 (amended with a record) and the two comments in `adoption-lib.ps1`: an unusable value never gets a wait below 24, and a typo that is itself a valid number is read as written, needs a reason, and warns. |
| G9 "the plan says pending, so no warning prints" is untrue once the review is committed or every task is ticked | **Recorded, not changed.** The statement is true for the case it describes (a mid-feature or pending branch with no review committed) and is incomplete for the others, which `critical-delivery.md` "When the check demands the artifact" already states in full. The owner chose not to widen the fix. |
| G10 in team mode every problem gets one generic fix sentence, dropping the specific remedy | **Recorded, not changed.** The message still names the field and the value read; the generic sentence is the point (no period applies, so there is nothing specific to fix today). The owner chose not to change it. |

**Run after the fixes, 2026-10-23.** `-Case verify-kit/VK-03`: **246 passed, 0 failed**; `-Case enforcement-pack/CRIT-C`: **204
passed, 0 failed**; each also runs the coverage, inventory and reader tests. Coverage sweep unchanged at **298 of 315** (no new
emission site; the one new case is under an existing rule). `doc-lint.ps1` OK, `build-digests.ps1 -Check` OK (no marker
changed). **The full harness was started on this tree and was killed by the system for low memory before it finished, for the
second time in this feature, so there is no full-suite result for these fixes from the agent; it was not restarted.** The last
complete run, 2230 passed, 0 failed, was on the tree before these fixes (the phase 5 commit); this round adds one case (2
assertions) and edits no other expectation than `VK-035/fail`. The owner's gate is the certification.
