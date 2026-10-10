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
