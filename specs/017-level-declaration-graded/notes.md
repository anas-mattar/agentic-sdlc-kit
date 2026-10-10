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
