# Notes: Level Declaration Graded

Evidence and decisions that belong beside the feature but not in its approved documents.

## Approval record — 2026-10-11

The owner (anas.m) approved the spec and the plan on 2026-10-11. The Draft to Approved flip on
`spec.md` is the act that starts the amendment rule (constitution I); it is committed alone
so the status-only exemption applies as written.

What the approval covers:

- `spec.md` as committed in eb4e071, including its Edge Cases note on decorated Territory
  markers, which `research.md` R3 records as stale. The note is approved as written; it changes
  no behaviour, because an unreadable Territory is UNGRADED either way. It is not amended here.
- `plan.md` as committed in 26f72d6: decisions D1 to D9, the five-phase order, and
  `**Gate Certification**: user-run` (this feature changes enforcement scripts).
- `tasks.md` as committed in 60719c2, with each phase's Territory.
- D1's consequence: phase 1 amends constitution Principle X (0.7.0 to 0.8.0). That amendment
  needs its own approval at T006 before phase 2 begins. This approval does not stand in for it.

## Phase 1

Written 2026-10-11. T001-T005 were implemented and checked before the commit: `doc-lint` OK,
`digests` OK (84 markers; one digest line shortened to the 120-character bound),
`enforcement-pack` OK. `scope-check` was UNGRADED until the phase commit existed, as expected.

T006: the owner (anas.m) approved the constitution 0.8.0 amendment on 2026-10-11; the
approval is recorded in the SYNC IMPACT REPORT ("Human adoption of this amendment").

Baseline for later phases: `tests/enforcement/Run-Tests.ps1` on the tree at `b82e362`,
before any phase 1 edit — 899 passed, 0 failed, 0 skipped (726 s).

Gate: the user-run gate exit code for this phase had not been reported when the phase was
committed; it is the owner's to certify (constitution X) and is not claimed here.

### Gate and review — 2026-10-11

Gate: the owner ran `pwsh -File scripts/ritual-checks.ps1` on `f5bfab9`; it printed
`RESULT OK`, exit code 0, and the owner confirmed `RESULT OK` as the certification. Recorded
here as the owner's statement, not an agent claim.

Fresh-context AI review: `ai-code-review-phase-1.md`, verdict APPROVE with follow-ups, no
Blocker, no Major. Dispositions:

- F1 (Minor): fixed. The Definition of Done mirror now says the failure applies to a spec
  carrying the `**Rationale Rule**` marker.
- F2 (Minor): fixed. The two-line Surface Exception shape now lives in
  `docs/sdlc/critical-delivery.md`, which ships to adopters; the template comment points
  there instead of at this feature's contract.
- F4 (Note): fixed in the same mirror, not in the constitution: a Micro feature owes no
  rationale and is held only to the surface floor.
- F3 (Minor): carried to phase 3 and 4 as reader requirements, not changed now. The reader
  anchors the verdict word; treats text led by `[` as unfilled, so the template's placeholder
  lines never read as answers; and trims the marker line. Fixtures for each belong with
  LEVEL-008/009.
- F5 (Note): accepted as stated. The approval of the constitution amendment is prose in the
  sync report and the commit; gate-6 human review confirms it.

## Phase 2

Written 2026-10-11.

**Rule ids.** The doctor rules are `VK-029` and `VK-030`, not `LEVEL-011` and `LEVEL-012` as
`tasks.md` and the contract's working numbering say. The harness keys cases by script and the
existing doctor rules are `VK-*`; `tasks.md` states that `rules.json` is authoritative. VK-029 is
the three states of the one fact "is the surface floor armed" (`siteCount` 3; `pass` is the
declared line, `fail` and `fail-empty` are the two not-armed lines, all exit 0, the way VK-018's
fail direction is an absence). VK-030 is the unusable-list finding (`fail` is a non-array;
`fail-blank-entry` and `fail-absolute-path` are variants; `pass` is a usable list).

**T008, against the parent commit (cf930f2).** All six new cases failed as expected, with one
departure from the task's wording: the three `pass-*` cases did NOT already pass. The doctor
had to learn to print a line about the key at all, so even the pass directions expected output
the parent could not produce. The three unusable-list cases exited 0 where the fixtures expect 1,
which is the defect: the parent never told a project its declared list was being ignored.

**Existing expectations changed.** The doctor now prints one informational line on every run that
reaches the record, so 50 pre-existing `verify-kit` `expected.txt` files gained the line
`criticalSurfaces not declared`. The line was placed by hand-written rule (before the first
`adoption record valid` / `no gate proof` line, or before the `kit-version` line when a record
finding stops those), and the full `VK-` set passes: 155 passed, 0 failed.

**Reader decisions that differ from, or extend, `data-model.md`.**
- An empty array is State `empty`, and is NOT a problem. `data-model.md` and research R7 call it
  an unfinished edit as for developers; an explicit empty list is more naturally a statement
  that the project has none, and failing the doctor on it would punish that. The behaviour R7's
  table specifies (not armed, informational line) is unchanged. The doctor reports it as
  `criticalSurfaces is empty`.
- A root-not-an-object or unparseable record returns `absent`, not a problem: `Get-DeveloperMode`
  already reports that defect, and printing it twice would be noise.
- Duplicates are collapsed silently (no problem), unlike developers, because a duplicated glob
  changes nothing.
- Any problem sets State `malformed` and leaves Armed false even when other entries are usable.
  A dropped unusable entry would otherwise leave an armed list with a hole in it, the one shape
  this reader must not produce.
- The record-reading preamble is repeated from `Get-DeveloperMode`, not factored out, to leave
  013's reviewed function untouched in this phase. A shared helper is a candidate cleanup, not
  done here.

**Verification.** See "Review and remediation" below; the figures there supersede any earlier count.

### Review and remediation — phase 2

Fresh-context AI review: `ai-code-review-phase-2.md`, verdict APPROVE with follow-ups, no
Blocker, no Major. About 45 hostile inputs to the reader (root shapes, null, string, number,
object, empty and blank entries, nested arrays, duplicates, backslashes, drive letters, `..`,
UNC, a BOM, 20,000 entries, StrictMode on and off) never made the result more armed than the same
record without the problem.

Dispositions:

- F1 (Minor): fixed. The doctor's "armed" line promised the ritual checks would fail a
  feature, which nothing does until phase 3. It now says only that the surface floor is
  *recorded*. VK-029 `pass` and VK-030 `pass` pin the new text.
- F4 (Minor): fixed. The count of existing expectations that gained the line is 50, not 41
  (41 by the first positional rule, 9 more where a record finding stops the usual anchor lines).
  The earlier figure in this file and in the phase 2 commit message was wrong.
- F5 (Minor): fixed. New fixtures: VK-030 `fail-null`, `fail-non-string`, `fail-drive-letter`,
  `fail-dotdot`; VK-029 `pass-normalised` (backslashes read as slashes, case-insensitive
  duplicates collapse). The drive-letter and `..` fixtures exist because deleting those
  alternatives from the reader's pattern passed every earlier case. The VK-029 note in
  `rules.json` named a directory that does not exist (`fail-not-declared`); it is corrected.
- F6 (Note): carried to phase 3. An entry such as `./src/auth/` arms the floor but can never
  match, the same class of hole the reader refuses for drive letters and `..`; `Get-Territory`
  has the same property, so the two agree. Phase 3's matcher must normalise `\` to `/` on both
  the surface side and the Territory side, and a leading `./` is worth deciding on there.
- F7, F8 (Notes): accepted. The doctor prints `criticalSurfaces not declared` beside a root-shape
  FAIL, as it already prints `0 developer(s) declared` there; and the reader's `Why` is not
  used by the doctor (it is for phase 3's messages).
- F2 (Minor): **approved by the owner (anas.m, 2026-10-11) and fixed.** The reader now returns
  State `unreadable` (no file stays `absent`) for a record that exists but cannot be read: an
  unreadable file, unparseable JSON, a root that is not an object. It is not `absent`, so
  phase 3 can say so by name (spec FR-012) and report UNGRADED instead of grading a broken record
  like a project that never asked. It carries no Problems, so the doctor does not print the same
  defect twice, and it prints nothing for it. `data-model.md` gained the state and the verdict
  row, with the owner's `**Amendment approved by**` line. Verified by calling the reader on
  seven shapes (no file, a directory in place of the file, bad JSON, root array, root string,
  no key, a valid list). No harness fixture reaches the state in this phase: an unparseable
  record already fails earlier in the doctor and never arrives at the new block, so all 66
  `VK-` cases (165 tests) pass unchanged. Phase 3 must fixture it through the check (an
  UNGRADED run on a record that does not parse), alongside LEVEL-003's malformed-list case.

**Open, for the owner (not decided by the implementer):**

- F3 (Note): `data-model.md` and research R7 still call an empty list "an unfinished edit"; the
  reader treats it as lawful and not a problem, which breaks no requirement. Duplicates
  collapse silently and the doctor's line wording differs from contract section 4's schematic.
  Amending those sentences needs the owner's approval line; until then this file is the record.

## Phase 3

Written 2026-10-11. Implemented, not yet committed when this section was first written.

**T017, against the parent commit (4f75682).** All 24 new cases were run before any code changed.
23 failed for the right reason: the script printed none of the new `LevelSurface` lines and
exited 0 where the fixture expects 1 (inspected for `LEVEL-001/pass`, `fail-micro`,
`LEVEL-004/fail` and `fail-near-miss`, `LEVEL-003/fail-unreadable`). The one that already
passed is `LEVEL-001/pass-critical`, a guard: the same Territory on a Critical feature adds no
`LevelSurface` failure, and the parent had no `LevelSurface` check at all. After the change all
24 pass and the coverage test reports 59 of 63 `enforcement-pack` sites fixtured.

**Rule ids and shape.** `LEVEL-001`..`LEVEL-007` as in `tasks.md`; the doctor's two are `VK-029`
and `VK-030` (phase 2). `LEVEL-003` has `siteCount` 2 (a malformed list, and an unreadable
record), sharing one anchor. The roll-up `LevelSurface: graded ...` is declared a not-a-rule in
`emission-idioms.json` with a written reason, the counterpart of the AmendmentAuthority line.

**Decisions made in the implementation (none changes an approved document).**
- *Intersection.* A literal Territory path is tested with the kit's own `Test-InTerritory`. Two
  patterns are compared by literal directory prefix, either nesting in the other. A pattern with
  no literal prefix intersects everything. It over-reports by design (research R1).
- *Phase 2 review F6, handled here.* Both sides are read through one normaliser: a backslash is
  a slash and a leading `./` is dropped. `fail-case-and-slash` pins case folding and the
  backslash. A leading `./` on a surface is normalised too, so it can no longer arm the floor and
  never match. This was decided here, as the F6 note asked.
- *Territory source.* Standard: the union of every `## Phase N` block in `tasks.md`. Micro: the
  global block in `spec.md`. A missing file, no block, an empty block, or a near-miss marker
  (no colon) is UNGRADED by name. Invalid entries (absolute, `..`) are not compared; the scope
  check and the Micro lane already fail them.
- *Exceptions.* Two lines in `spec.md`, the approval on the next non-blank line. The approval is
  validated by `Get-ConformingRecord`, now parameterised on its pattern (default unchanged: every
  `AMEND-*` case passes). The date ceiling is the author's own day of HEAD, not the runner's
  clock, for the reason 014 H6 gives. A placeholder reason is rejected. An exception counts only
  when it names the entry exactly (case-insensitive, normalised); it does not cover a different
  path, and the exception is then reported stale.
- *When it runs.* On `NNN-*` branches whose level reads Standard or Micro. Critical is never
  failed (FR-011). Lite, an unfilled or invalid level, and a missing spec return silently: the
  Structure check owns those findings.
- *Where it sits.* In `scripts/enforcement-pack.ps1` right after the Structure check. The helpers
  stay in that file; `scripts/scope-lib.ps1` is untouched, so no Territory amendment was needed
  (T019's condition did not arise).

**Existing expectations changed.** The one informational line `LevelSurface: not armed` now
prints on every `NNN-*` run whose spec reads Standard or Micro and whose project declares no
surfaces, so 80 existing `enforcement-pack` expectations gained it. It was placed by a written
rule, with each case's level read from its own recipe rather than from the script's output:
directly after the header line, with the branch and level named. No expectation was otherwise
touched. This is the "exactly one new informational line" SC-004 allows.

**Two departures from the task wording, stated plainly.**
- `LEVEL-001/pass-critical` exits 1 (named `pass` for the rule, not the run): the Critical lane's
  own check fails for the missing second-model review, and the case pins that `LevelSurface`
  adds nothing to it.
- `LEVEL-004/fail` exits 1 because the Structure check separately fails the missing `tasks.md`;
  the UNGRADED line is the finding under test.

**Evidence status.** Targeted runs on the working tree: `LEVEL-` 24 cases pass (81 tests);
every existing `enforcement-pack` rule's cases pass; `ritual-checks` RESULT OK. A full harness
run on a clean checkout of the phase 3 commit is still to come. The earlier full run "on phase 2"
that finished mid-phase 3 is NOT evidence for either phase: it ran while this phase's files
changed under it and reported 7 failures, all of them this phase's work in progress. Phase 2's
own result comes from a separate run on a clean checkout of `4f75682`.

### Review and remediation — phase 3

Fresh-context AI review: `ai-code-review-phase-3.md`, verdict CHANGES REQUESTED on one Major, now
fixed. The reviewer ran every existing `enforcement-pack` rule prefix and `LEVEL-` (0 failed in
each), confirmed the 80 edited expectations each gained exactly one line and lost none, and tried
exceptions, Territory forms, phase headings and level spellings without finding another way past
the check.

- **F1 (Major, fail-open): fixed.** `Get-LevelPathPrefix` returned a pattern ending in `/` whole
  before looking for a wildcard, so a surface such as `**/auth/` was compared as the literal
  string it ends with, and a Territory of `src/**` came out clean ("0 reached", exit 0) against a
  surface it can plainly reach. Reproduced first: `LEVEL-001/fail-wildcard-surface` failed on
  the unfixed script and passes now. The wildcard test now comes first.
  *Evidence beyond the fixtures.* A property check over 33 patterns (1,089 ordered pairs, a
  universe of 60 concrete paths, "really intersect" defined by the kit's own matcher): the
  unfixed code under-reported 62 pairs (`src/` vs `**/auth/`, `src/auth/` vs `*/auth/`, ...), the
  fixed code reports 0, and over-reports 160 pairs, which is the stated, allowed direction.
  That property check is not a harness case; it is recorded here and could become one.
- **F2 (Minor): fixed.** New fixtures: `LEVEL-001` `fail-wildcard-surface`,
  `fail-wildcard-mid-surface` (a guard; it passed before the fix by accident of the prefix test),
  `fail-surface-dot-slash` (a surface written `./src\auth\`; phase 2 F6, correct before but
  unpinned), `fail-second-phase` (the union across phases); `LEVEL-005` `pass-micro` (an exception
  in a mini-spec); `LEVEL-007` `fail-todo-reason`.
- **F3 (Minor): half fixed, half yours.** A reason that is `TODO`, `TBD`, `FIXME` or `XXX` is now a
  placeholder and the exception does not count. That an *approver* named `TODO` is accepted is
  inherited from `Get-ConformingRecord`, which rejects only `TODO(`; the amendment check shares
  that function, so tightening it changes what feature 014 accepts. Left as is, for the owner.
- **F4 (Minor): fixed.** The message names the canonical level (`Standard`, `Micro`), not the
  spec's own spelling.
- **F5 (Minor): fixed.** The live-exception line says "approval recorded by", because only the
  shape of the approval line is verified, not that the person agreed (constitution I).
- **F6, F7, F8 (Notes): accepted.** An exception inside a code fence counts, and a bulleted one is
  not recognised (both safe directions); a same-day approval fails locally until committed (the
  HEAD author-date ceiling, as in the amendment check); `?` in a surface is a wildcard for the
  intersection test and a literal for the kit's matcher, consistent with `scope-lib`.

### Evidence status

- Phase 2, full harness on a clean, isolated checkout of `4f75682`: **923 passed, 0 failed,
  0 skipped**, exit 0. (The baseline before any phase 1 edit was 899; the difference is the 24 new
  doctor cases, so every pre-existing test still passes.) An earlier "full" run on the live
  working tree is not evidence and is not cited: it ran while phase 3's files changed under it.
- Phase 3: targeted runs on the working tree only so far (`LEVEL-` 30 cases, 93 tests, 0 failed).
  A full run on a clean checkout of the remediation commit follows.

- Phase 3, full harness on a clean, isolated checkout of `2e93252` (the remediation commit):
  **983 passed, 0 failed, 0 skipped**, exit 0. That is 923 (phase 2) plus the 60 tests the 30
  `LEVEL-` cases and the rule entries added, with every pre-existing test still passing.

## Phase 4

Written 2026-10-11. Implemented, not yet committed when this section was first written.

**T025, against the parent commit (2e93252).** All 25 new cases were run before any code changed.
24 failed for the right reason (the script printed none of the new `LevelRationale` lines and
exited 0 where a fixture expects 1). The one that already passed is `LEVEL-008/pass-no-marker`,
a guard: a spec from before the rule is exempt, silent, and the run is what it was. After the
change all pass; `LEVEL-` is 51 cases (135 tests) and the coverage test reports 64 of 69
`enforcement-pack` sites fixtured.

**Rule ids.** `LEVEL-008`..`LEVEL-010` as in `tasks.md`, plus `LEVEL-011` (a marker value other
than `1`, UNGRADED), which `tasks.md` does not list. It exists because the alternatives are worse:
a spec from a newer rule version silently exempt, or graded by rules it was not written for.
`LEVEL-010` has `siteCount` 2 (the two directions of contradiction), sharing one anchor.

**Decisions made in the implementation (none changes an approved document).**
- *Who owes a rationale.* Standard and Critical specs that carry `**Rationale Rule**: 1`. Micro
  does not (its mini-spec has no such section; spec FR-002 names Standard and Critical). A spec
  without the marker is exempt and silent, so the 80 existing expectations and every shipped
  feature are untouched.
- *Phase 1 review F3, honoured.* The marker line is read from visible text and trimmed, so the
  template's trailing space and multi-line comment do not matter (`pass-template-marker`); the
  verdict is anchored to the start of the bullet; text that starts with `[` or `<`, or whose reason
  is `TODO`/`TBD`/`FIXME`/`XXX`, is unfilled, so the template as shipped can never read as four
  answers (`fail-template-placeholder`); the same rule applies to a `**Critical because**` line.
- *One finding per unanswered trigger*, so an unedited template names all four. (The first
  version of that fixture expected only the first one named; the design changed before the code
  was written and the expectation with it.)
- *Graded line.* When all four triggers are answered the check prints one line
  (`LevelRationale: graded ... 4 of 4 triggers answered, N apply`), declared a not-a-rule like the
  other roll-ups. It prints before any contradiction finding.
- *Duplicates.* A trigger answered twice is an unanswered trigger ("answered more than once"):
  neither answer silently wins.
- *Where it sits.* In `scripts/enforcement-pack.ps1` right after the surface check.

**Beyond the fixtures: the real template, end to end.** Using `.specify/templates/spec-template.md`
as shipped, in a throwaway git repository: with only the level filled in it fails with four
findings (one per trigger); with the four bullets filled in the way an author would, and the
template's bracketed `**Critical because**` placeholder left in place, it passes with
`0 apply`; with one answer flipped to `applies` on a Standard feature it fails as a
contradiction. This is not a harness case; it is recorded here.

**Evidence status.** Targeted runs on the working tree: `LEVEL-` 51 cases pass (135 tests); every
existing `enforcement-pack` rule prefix passes with 0 failed; `ritual-checks` RESULT OK. A full
harness run on a clean checkout of the phase 4 commit follows.

### Review and remediation — phase 4

Fresh-context AI review: `ai-code-review-phase-4.md`, verdict APPROVED WITH MINOR FINDINGS, no
Blocker, no Major. About 100 throwaway-repository probes (marker, heading, bullet, verdict, level
and Critical-because variants) found nothing that let a missing or contradictory rationale pass
by accident; `$matches` handling was confirmed correct; no input threw; a 5,000-line spec graded
in under 2 seconds. The commit changed no approved document.

All six cheap findings are fixed. For each, the new fixtures were run on the unfixed script first:
8 failed for the right reason (`pass-fenced-marker`, `fail-fenced-section`, `fail-second-section`,
`fail-two-markers`, `fail-near-miss-marker`, `fail-near-miss-spaced-colon`,
`fail-reason-says-nothing`, `fail-reason-placeholder`) and the other 7 already passed and now pin
directions the first suite lacked.

- **F1 (Minor): fixed.** Fenced code is not content. A fenced `**Critical because**`, a fenced
  whole section, or a quoted marker used to count. The check now reads visible text with fenced
  lines removed, through `Get-FencedLineMap` (feature 015's reader, already used by the amendment
  check), not a second idea of what a fence is.
- **F2 (Minor): fixed.** Answers are collected across every `## Level Rationale` section, so a
  second section that contradicts the first makes the trigger "answered more than once".
- **F3 (Minor): fixed.** The marker is every header-shaped line, not the first. A value other than
  `1` anywhere is UNGRADED, so `1` then `2` and `2` then `1` say the same thing.
- **F4 (Minor): fixed.** A line that looks like the marker and is not one (indented, quoted, a space
  before the colon) is UNGRADED by name, not silently exempt, the way a Territory marker the parser
  cannot read already is. `LEVEL-011` now has two sites.
- **F5 (Minor): fixed.** A reason needs a word of at least two characters, so `x`, `-` and `n/a`
  are not reasons. The same helper serves the `**Critical because**` line.
- **F6 (Minor): fixed.** New directions: a Micro spec carrying the marker (silent), the marker
  after the section, a fenced marker, a Critical spec missing a trigger, a Standard spec with two
  triggers applying (one finding naming both), a Critical because reason that merely contains
  brackets.
- **F8 (Note): partly fixed.** A verdict followed by a placeholder or empty reason now says the
  reason is the problem ("its reason 'TODO' is a placeholder or says nothing") instead of saying the
  verdict is missing. NOT done: the exact bullet syntax lives in the spec template and the check's
  messages, not in `docs/sdlc/critical-delivery.md` or the constitution. Those documents are outside
  phase 4's Territory; the template and messages agree with each other and with the check. Carried
  to the owner's attention, not changed. (The template comment saying an absent level means
  Standard, while Structure fails it, predates this feature.)

**Open, for the owner (not decided by the implementer):**

- F7 (Note): `LEVEL-011`, the UNGRADED verdict for a marker this check cannot read, is not in
  `tasks.md`, the contract's section 3 anchor table or `data-model.md`'s verdict table. The reviewer
  agrees UNGRADED is the right verdict: it fits FR-012, does not conflict with FR-008, and exits 0
  with "not the same as passing it". Adding the contract line and a data-model row is an amendment to
  approved documents, so it needs your approval line. Until then this file and `rules.json` are the
  record.

**Evidence status for phase 4.** Targeted runs on the working tree: `LEVEL-` 66 cases (165 tests)
pass; every existing `enforcement-pack` prefix passes with 0 failed; `ritual-checks` RESULT OK; the
real spec template, run end to end, still fails when unfilled (four findings), passes when filled,
and fails as a contradiction when a Standard feature answers `applies`. A full harness run on a
clean checkout of the remediation commit follows.

## Phase 5

Written 2026-10-11.

### T029 — the three adopted projects (SC-004)

Method, the same as feature 016's: each project cloned from its committed HEAD into a scratch
directory (`fitforge` `40ec9e2`, `flowboard` `3d7a472`, `expense-tracker` `4dca06a`); the real
projects were not touched. `scripts/update-kit.ps1 -DryRun -Target <clone>` from this branch
(`815733e`), then the ten files it named applied to the clone, then the old and new scripts run.

**What flows down (dry run, identical for all three).** Applied cleanly, ten: the spec template, the
three law documents (`branch-strategy`, `critical-delivery`, `definition-of-done`),
`adoption/updating.md`, and five scripts: `adoption-lib`, `enforcement-pack`, `verify-kit` (this
feature) and `build-digests`, `markdown-lib` (feature 016, which the three have not applied yet).
Surgical, one: `.specify/memory/constitution.md`, reported and never applied. No conflict.
Two consequences are in the flow-down note: each adopter re-expresses the 0.8.0 amendment by hand, and
a spec made from the new template carries the marker and so owes the Level Rationale.

**Every shipped feature, graded by the project's own pack and then by the new one**
(`enforcement-pack.ps1 -Branch <feature>`):

| Project | Features | Exit code moved | Verdict moved | Line removed | Lines added |
|---|---|---|---|---|---|
| fitforge | 1 | 0 | 0 | 0 | 1 x `LevelSurface: not armed` |
| flowboard | 9 | 0 | 0 | 0 | none (see below) |
| expense-tracker | 3 | 0 | 0 | 0 | 1 x `LevelSurface: not armed` |

Flowboard's shipped specs mostly have no readable `**Delivery Level**` header (two write the value
in bold: `**Critical** (...)`), so they fail the Structure check on the old script AND the new one,
identically; the new checks are silent about a level they cannot read, and that pre-existing finding
is unchanged. It is not caused by this feature and is not fixed here. Where a Standard level is
readable the one line appears: fitforge's single feature is Standard, and so is expense-tracker's
`003`; expense-tracker's `001` and `002` have no readable level and fail Structure on both scripts
alike. Neither project has a shipped Critical feature, so the Critical exemption was not exercised
on real specs here (the harness covers it).

`verify-kit.ps1`: verdict unchanged (`OK`, 2 warnings) in all three; exactly one line added,
`criticalSurfaces not declared`.

**`ritual-checks.ps1` on each project's trunk.** `RESULT OK` before. After the ten files:
`RESULT FAIL (1 of 7)`, the `digests` member, in all three: the law documents changed, so the
critical and adoption digests no longer match their sources. This is the regenerate step the note
tells an adopter to take, and it is the cost of the update, not a defect. After
`scripts/build-digests.ps1`: `RESULT OK` in all three, markers 82 to 85 (fitforge) and 59 to 62
(flowboard, expense-tracker).

**Digests, compared by git with line endings ignored.** `adoption-digest` +2 lines (feature 016's
marker, which none of the three has taken, and this feature's), `critical-digest` +1, the other
three byte-identical. (A first comparison of mine reported +10/-10 on every digest. That was my
comparison script splitting lines differently from git, not a difference in the files, and is not
cited.)

### T030-T032

- The flow-down note in `adoption/updating.md` is finished: what flows down, the amendment to
  re-express, both checks, the exception, what the checks are not, the doctor line, and the
  measurement above. It had to avoid inline example paths: `doc-lint` resolves path-looking inline
  code, so the example is in a fenced block.
- `kit-manifest.json`: no change. Every file this feature changed was already classified, and it adds
  no new shipped file (`doc-lint` classifies all 79 and passes). Only `specs/` and `tests/` gained
  files, and neither ships.
- The roadmap row is `shipped` with its spec link unbracketed; the GAP-023 inventory row carries a
  status sentence naming what stays open by decision; the decisions log has the entry.

### Evidence status

`ritual-checks` RESULT OK on the working tree. Full harness: phase 4's run on a clean checkout of
`815733e` is the evidence for the scripts and tests, which phase 5 does not change; a run on the
phase 5 commit follows.

### Review and remediation — phase 5

Fresh-context AI review: `ai-code-review-phase-5.md`, verdict APPROVED WITH MINOR FINDINGS, no
Blocker, no Major. The reviewer reproduced the three-project measurement end to end on its own
clones (every shipped feature graded by the old pack, the ten files copied, graded again): the only
output change anywhere is the `LevelSurface: not armed` line (fitforge, and expense-tracker's `003`);
flowboard has zero changed lines; no exit code moved; the doctor gains one line; `ritual-checks` is
OK, fails on `digests`, and is OK again after regeneration; markers 85 and 62 after; digests adoption
+2 and critical +1. It did not separately reproduce the "before" counts 82 and 59. Lint, digests,
roadmap-claims and the dry run (ten files, the constitution as the one surgical item) are clean, and
the commit changed no approved document.

- **F1 (Minor): fixed.** The note said an "unfilled name" approver does not count. Only an unfilled
  slot does (double-braced, bracketed, angle-bracketed, or `TODO(` followed by a name); a bare `TODO`
  or `TBD` approver is accepted. The note now says so, and says that tightening the shared validator
  is the kit owner's decision and review holds that line until then.
- **F2 (Minor): fixed.** The decisions log now lists the `LEVEL-011` item (the UNGRADED verdict for a
  marker the check cannot read exists in the code and fixtures but not in the approved contract or
  data model, which need the owner's approval line), which was in `notes.md` and the phase 4 review
  but not where a reader of the roadmap would look.
- **F3 (Minor): fixed in part.** A missing full stop before the GAP-023 status sentence is added, and
  the log says that "shipped" and "closed" mean built, reviewed and measured, with the owner's gate and
  the human review at merge still to come. The status flip itself is what T032 asked for and follows
  the precedent of features 015 and 016.
- **F4 (Note): fixed.** The note now has a "When they start" paragraph: the checks run as soon as the
  scripts land, whether or not the adopter has ratified 0.8.0; a new-template spec owes its rationale
  from that day; Micro and Lite owe no rationale.
- **F5 (Note): accepted, and disclosed here.** The measurement runs at each clone's trunk HEAD, so the
  diff base is HEAD: zero changed files, and `AmendmentAuthority` is UNGRADED in every run, before and
  after. SC-004's "exactly one new informational line" is therefore not literally met for flowboard
  (no readable level, so no line) or for expense-tracker's `001` and `002`; the note says why. The
  phase 5 task wording "no surgical file" is superseded by the dry-run finding that the constitution is
  surgical, which the note and the log both state.
- **F6 (Note): fixed.** `docs/roadmap.md` now ends with a newline.

### Evidence status, final for the scripts and tests

- Phase 4, full harness on a clean, isolated checkout of `815733e`: **1055 passed, 0 failed,
  0 skipped**, exit 0. That is 983 (phase 3) plus the 72 tests the 36 new phase 4 cases added.
- Phases 2 and 3: 923 and 983, recorded above.
- Phase 5 changes no script and no test, so the phase 4 run is the evidence for them; a run on the
  final tip follows this commit anyway.
- Owner gate: only phase 1's is recorded (exit 0, `RESULT OK`, confirmed in words by the owner). The
  owner pasted a `ritual-checks` run on `815733e` showing `RESULT OK`; no exit code was stated and it
  has not been recorded as certification. Phases 2 to 5 are uncertified until the owner says so.
