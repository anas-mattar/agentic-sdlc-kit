# Notes: Load-bearing Developer Roster (021)

Phase evidence, measurements and decisions. Not an approved document: `tasks.md` holds the agreed work, this
holds what happened.

## Phase 1: the reader and the doctor

### T001: baseline on the parent commit

Taken on an isolated detached worktree of the parent commit (the approved-`tasks.md` commit), so no edit of this
working tree could reach it.

| Measurement | Value |
|---|---|
| Full harness | **1211 passed**, 0 failed, 0 skipped, `enforcement-tests: OK` |
| Coverage | 218 of 230 declared sites fixtured; `verify-kit.ps1` 34 of 35, `enforcement-pack.ps1` 65 of 70 |

"Byte-identical" is proved at the reader, not by saving three doctor transcripts as `tasks.md` T001 proposed: the
doctor prints nothing from the record except what `Get-DeveloperMode` returns (`Declared`, `Problems`, `Count`,
`Mode`), and the enforcement pack reads `Mode` and `Why`. So the comparison is of those fields, old library
against new, over a corpus (below). Recorded as a deviation from the task's wording, with the stronger reason.

### T002/T003: the fixtures, shown failing on the parent

Eleven new cases, hand-written expectations (the doctor's messages and the exact text of each roster line were
fixed in the generator before the reader was touched):

| Rule | Variants |
|---|---|
| `VK-017` (developers declaration present and unusable) | `fail-object-no-name`, `fail-repos-not-array`, `fail-flag-not-boolean`, `fail-duplicate-forms` |
| `VK-031` (new: the roster line) | `fail` (one denied), `fail-all-permitted`, `pass` (strings only: no line) |
| `VK-032` (new: an unknown `repos` name is a WARN) | `fail`, `pass` |
| `CRIT-T01` (a Critical feature in team mode, no human review) | `fail-object-roster`, `fail-mixed-roster` |

Run against the unchanged scripts: every `fail` variant fails (the parent drops an object entry, so the arm and
the messages differ), `VK-031/pass` passes (it is the string-only state, unchanged by design), `VK-032/pass` fails
(the parent cannot read the object form), and the two coverage tests that name the missing anchors fail.
Two fixture defects were found while bringing the new ones green and are fixed in the fixtures, not the script:
the `repos` cases declare `codeRepos`, which makes the doctor print the existing "not present here" warning
unless the directory exists, so they now carry an `api/` directory, and the record line then reads `codeRepos: api`.

### T004/T005: the reader and the doctor

`Get-DeveloperMode` (`scripts/adoption-lib.ps1`) now reads each entry once, in order: a string as before; an
object when it has a usable `name`; anything else is the generic "blank or non-string entry". It returns
`Roster` (`Name`, `Repos`, `CanApproveCritical`, `Form`) and `HasObjectEntries`, and every early return carries an
empty `Roster`. Decisions the plan left open, recorded here:

- **Duplicates across forms.** The same person written twice keeps the first spelling and the first entry; if any
  copy denies Critical approval, the person is denied (the stricter reading wins). Reported by the existing
  duplicate problem, which names the later spelling.
- **Problem severity.** A problem may carry `Severity = 'warn'`; only an unknown `repos` name does. The doctor
  prints it as a WARN (the adoption stays OK), every other problem as a FAIL, exactly as before.
- **No `codeRepos` declared.** Every `repos` name is then "unknown" and warns. That is informative, not a failure,
  and `repos` is read by nothing else (spec FR-012).
- **The doctor's roster line** appears only when at least one usable entry was written as an object, so a
  strings-only project's output is unchanged; it lists the names and who may not approve Critical.

`scripts/verify-kit.ps1` gains the severity branch and the roster line; both ride the existing record dimension.

### T006: results

**Reader byte-identity.** A scratchpad corpus of 19 records, none using the object form (absent, no key, null,
empty, one, two, three developers, case duplicates, blank, number, null and array entries, all blank, a string and
a number where an array belongs, a root array, unparseable JSON, untrimmed names), run through the old library
(from the isolated parent worktree) and the new: `Mode`, `Count`, `Declared`, `Why` and every `Problems` message
and fix identical in **19 of 19**. Two object-form records differ as intended: two objects are now `team` with
count 2 and no problem (the parent said `solo`, count 0, "non-string entry"), and an object with no name is now
reported by position instead of as a generic non-string entry.

| Measurement | Parent | Phase 1 |
|---|---|---|
| `-Case VK-` | 167 passed | 185 passed, 0 failed |
| `-Case CRIT-` | 75 passed | 79 passed, 0 failed |
| `-Case CLAIM-` | 67 passed | 67 passed, 0 failed (untouched) |
| Full harness | 1211 passed | **1233 passed**, 0 failed, 0 skipped, `enforcement-tests: OK` |
| Coverage, `verify-kit.ps1` | 34 of 35 | 36 of 37 site(s) fixtured (the two new sites) |
| Coverage, whole | 218 of 230 | 220 of 232 (exemptions unchanged) |

The difference between the two full runs is exactly the 22 new assertions (4 + 3 + 2 + 2 = 11 cases,
each with an exit code and an output assertion). Every pre-existing case is unchanged. Run on this working tree;
the isolated-checkout run of the final commit is phase 4's T020 (the phase 1 review also ran the full harness on an
isolated checkout of `743f148`: 1233 passed).

### Deviation for owner acknowledgement

T001 asked for three saved doctor transcripts; phase 1 proves byte-identity at the reader instead (the reason is
under T001 above). The phase 1 reviewer found the deviation justified. It is a departure from approved `tasks.md`
wording, so it is listed here for the owner to acknowledge when certifying the phase 1 gate.

### Remediation of the phase 1 review (F1, F2, F5)

- **F1** (`adoption-lib.ps1`): the kept entry of a duplicate is now found through the same
  `OrdinalIgnoreCase` dictionary that detects the duplicate, so a denial in a later copy is never lost when `-ieq`
  and the ordinal comparer disagree (U+1E9B against U+1E60 now reads as one denied person; before, the assignment
  threw and the denial was dropped).
- **F2** (`adoption-lib.ps1`): `"name": ["a"]` is read as an unusable name, not as `a`; new fixture
  `VK-017/fail-name-is-array`, which fails on the phase 1 reader (2 failed there) and passes now.
- **F5**: this note's T020 reference, the missing `-Case CRIT-`/`-Case CLAIM-` counts and the header comment's
  `Count` entry are corrected; the deviation is listed above for the owner to acknowledge (not yet acknowledged).
- **Result**: full harness 1235 passed, 0 failed (1233 + the two assertions of the new fixture); `-Case VK-` 187. After round 2: 1237 passed, 0 failed.
- **Round 2 (R2-1, R2-2)**: the F1 fix has its own fixture, `VK-017/fail-duplicate-denial-kept` (U+1E9B then
  U+1E60 with `canApproveCritical: false` on the second copy; the roster line must name the person as not permitted),
  which fails on the phase 1 reader (1 assertion) and passes now; the deviation heading above no longer reads as a
  recorded acknowledgement.
- **Not changed**: F3 and F4 (nits, harmless) and F6 (carried into the phase 4 guidance).

## Phase 2: the Critical reviewer

### T007: the fixtures, shown failing on the parent

Two new rules, nine new cases, expectations written by hand before the script was touched:

| Rule | Variants |
|---|---|
| `CRIT-T08` (the Reviewer is not on the roster) | `fail` (linus, roster ada and grace), `pass` (string roster, on it), `pass-case-differs` (`GRACE`), `pass-object-roster`, `pass-solo-arm` (one developer, a human review naming a stranger, never read) |
| `CRIT-T09` (the Reviewer's entry does not permit Critical) | `fail` (`canApproveCritical: false`), `fail-flag-not-boolean` (`"no"`), `pass` (`true`), `pass-denied-other-person` (the denied developer is the Owner) |

Against the phase 1 script every `fail` fails (wrong exit code and output) and every `pass` passes, as it should:
those are the states the parent already accepted. The inventory and anchor tests fail there too, since the two rules
name emission sites the parent does not have. One expectation of mine was wrong and is corrected in the fixture, not
the script: `pass-solo-arm` counted seven changed files, and the roster file sits in the base commit, so six.

### T008: the check

`Invoke-CriticalTeamEvidence` takes the roster from `Get-DeveloperMode` (the caller passes `$mode.Roster`) and, after
the reviewer-is-not-owner check, grades a Reviewer who is neither empty nor a placeholder: not on the roster fails
with one message naming the reviewer and the roster; on it with a denied entry fails with a second. The match is
`OrdinalIgnoreCase`, the comparer the reader deduplicates with. The solo arm is untouched. The block comment that said
the roster is counted and never compared now says what membership proves and what it does not (plan D9).

### T009: results

| Measurement | Phase 1 (after round 2) | Phase 2 |
|---|---|---|
| `-Case CRIT-` | 79 passed | 97 passed, 0 failed |
| Full harness | 1237 passed | **1255 passed**, 0 failed, 0 skipped, `enforcement-tests: OK` |
| Coverage, `enforcement-pack.ps1` | 65 of 70 | 67 of 72 site(s) fixtured (the two new sites; exemptions unchanged) |

The difference is exactly the 18 new assertions (9 cases, each with an exit code and an output assertion). Every
pre-existing case is unchanged. Run on this working tree; the isolated-checkout run of the final commit is T020.

### Phase 2 gate

Certified by the owner (anas.m), 2026-10-12: the phase 2 gate was run and the owner reported exit code 0
(user-confirmed, not agent-claimed). Phase commit `6fe88b6`; scope-check PASS on it; AI review
`ai-code-review-phase-2.md` (`76482e6`), approve with follow-ups. Human review is not yet recorded.

## Phase 3: the claim ledger

### T010: the fixtures, shown failing on the parent

Five new `CLAIM-` rules (009 to 013) and one `RIT-` rule (008), 27 new cases, expectations written by hand before the
script was touched, built on the existing fixture `origin`:

| Rule | Cases |
|---|---|
| `CLAIM-009` (Owner not on the roster) | `fail`, `pass`, `pass-object-roster`, `pass-case-differs`, `pass-no-roster`, `pass-empty-roster`, `pass-blank-owner`, `pass-dash-owner`, `pass-own-claim`, `pass-idea-row` |
| `CLAIM-010` (roster, no Owner column) | `fail`, `pass`, `pass-no-roster` |
| `CLAIM-011` (over two active claims) | `fail` (three), `pass` (one), `pass-stale-not-counted`, `pass-shipped-not-counted`, `pass-different-owners`, `pass-no-roster`, `pass-own-claim-not-counted` |
| `CLAIM-012` (exactly two, noted) | `fail` (the note, exit 0), `pass` |
| `CLAIM-013` (unreadable tip date, UNGRADED) | `fail` (corrupt tip commit), `pass`, `pass-single-claim-reads-no-date` |
| `RIT-008` (the aggregate lifts UNGRADED for `roadmap-claims`) | `fail`, `pass` |

On the parent commit every case that asserts the byte-identical no-roster output (`pass-no-roster` x3,
`pass-empty-roster`, `pass-idea-row`) passes, and every case of the new behaviour fails, as it should: both
`fail` directions of `CLAIM-009` and `CLAIM-011` (exit code and output), and every roster-declared `pass` (the
new OK line). All eight existing `CLAIM-001` to `CLAIM-008` pairs pass on the parent and after.

### T011/T012: the readings

`roadmap-claim-check.ps1` dot-sources `adoption-lib.ps1` and reads the roster with `Get-DeveloperMode`.
**"Usable roster" is read as any non-empty `Roster`** (one developer included), the definition spec Key Entities
gives; a one-developer string roster whose Owner is someone else would now fail. That is the likeliest
verdict to move and phase 4's measurement (SC-003) must list it. Silence, not a note, with no roster (D5).

- Owner (D4): for each non-own claim with a non-`idea` row and a real Owner cell (not blank, not `—`), the Owner
  must be on the roster, trimmed, `OrdinalIgnoreCase`.
- Count (D7): per Owner (case-folded), claims whose row Status is `specified` or `in progress`; own claim exempt.
  Dates are read only for an Owner with two or more candidates (`git log -1 --format=%ct <sha>`, then one
  `git fetch --quiet origin <branch>`); older than 14 days is not counted. More than two fails, two prints one note,
  an unreadable date prints the reason and makes the verdict `UNGRADED` (exit 0).
- No `Owner` column under a declared roster: prints `not graded` and the visibility reading proceeds.
- The FAIL roll-up keeps its old words when every finding is a visibility finding, and says `N finding(s)` when a
  roster reading found something. The OK line gains `, Owners and claim counts graded against the declared roster`
  only when the roster was graded.

### T013: UNGRADED wiring

`roadmap-claims` joins `$ungradedCapableMembers` in `ritual-checks.ps1`; `RIT-008` fails if the name is dropped.
The member's exit code is unchanged.

Test-infrastructure edits that follow from the new sites: `emission-idioms.json` (the printed idiom now covers
`UNGRADED`, `not graded` and `note`; the FAIL roll-up not-a-rule anchor follows its new wording) and `rules.json`
(the `CLAIM-008` anchor is now `roadmap-claims: OK ($checked claim(s) visible with non-idea rows`, because the new
UNGRADED line shares the old, shorter phrase and the inventory counts hits per anchor).

### T014: results

| Measurement | Phase 2 | Phase 3 |
|---|---|---|
| `-Case CLAIM-` | not recorded | 117 passed, 0 failed |
| `-Case RIT-` | not recorded | 129 passed, 0 failed |
| Full harness | 1255 passed | **1309 passed**, 0 failed, 0 skipped, `enforcement-tests: OK` |
| Coverage, `roadmap-claim-check.ps1` | not recorded | 14 of 14 site(s) fixtured |
| `ritual-checks.ps1` | RESULT OK | RESULT OK |

The difference of 54 is exactly the new cases (27 x an exit-code and an output assertion). Every pre-existing case is
unchanged. Run on this working tree; the isolated-checkout run of the final commit is T020.

### Remediation of the phase 3 review (F1, F2, F5, F6)

`ai-code-review-phase-3.md`: approve with follow-ups. Remediated here, in phase 3 Territory only:

- **F1** (a claim took every row whose text contained its name). The Owner and count readings now bind a claim to
  its row by a delimited token (the name bounded by characters that cannot continue a branch name, so a prefix claim
  and a wildcard no longer match), preferring the row that holds `specs/<claim>`. The visibility reading is unchanged.
  Where the rows left still name different Owners the claim is **not graded** and the verdict is `UNGRADED`, never a
  guess and never a hard failure: a false failure would fail a lawful Owner. That is a new rule, `CLAIM-014`, not in the
  review's list; the review offered "name the ambiguity as not graded" as the alternative to binding by Spec cell alone.
  Fixtures: `CLAIM-009/fail-prefix-claim`, `CLAIM-011/pass-cross-reference-not-counted`, `CLAIM-014/{fail,pass,pass-same-owner-twice}`.
- **F2** (the D8 wiring is a no-op). Correct: `roadmap-claims` was already in `$naCapableMembers`, the capture set is the
  union of the two lists, and `RIT-008` is green on the parent. **Plan D8's premise ("roadmap-claims is not there, so its
  UNGRADED line would be read as OK") was wrong; recorded here as a plan inaccuracy, the plan itself not amended.** The
  `rules.json` note, the `RIT-008` fixture description and the `ritual-checks.ps1` comment now say what is true: the case
  is a regression guard on the union of the two lists, and naming the member in `$ungradedCapableMembers` changes no verdict.
  Not stated as fixed in phase 3's earlier results: "RIT-008 fails if the name is dropped" was wrong.
- **F6** (a table with no Owner column beside one that has it). A claim whose only non-idea rows sit in a table with no
  Owner column is named as not graded (`CLAIM-010`, second site), and the OK line then omits "Owners and claim counts graded
  against the declared roster". Fixture `CLAIM-010/fail-claim-in-table-without-owner`.
- **F5** (edge cases without a fixture): added `CLAIM-009/fail-stranger-with-two-claims`, `CLAIM-013/fail-ungraded-beside-a-finding`
  (exit 1, the detail line kept, no UNGRADED verdict over a FAIL) and `CLAIM-013/fail-first-tip-unreadable`. Not fixtured, checked
  by hand in the review and unchanged: the 14-day boundary and `In Progress` capitalisation.
- **Not changed**: F3 (the Owner cell carries one roster name and nothing else; `-` and `TBD` are strangers) and F4 (a
  one-developer roster is usable) go to the phase 4 guidance and the SC-003 measurement.

Shown against the pre-remediation script (`660cccb`): `CLAIM-009/fail-prefix-claim`, `CLAIM-010/fail-claim-in-table-without-owner`,
`CLAIM-011/pass-cross-reference-not-counted` and `CLAIM-014/fail` fail there (output); the F5 cases and the other `CLAIM-014` pair pass there,
because they pin behaviour that was already right.

| Measurement | Phase 3 | After remediation |
|---|---|---|
| `-Case CLAIM-` | 117 passed | 135 passed, 0 failed |
| `-Case RIT-` | 129 passed | 129 passed, 0 failed |
| Full harness | 1309 passed | **1327 passed**, 0 failed, 0 skipped, `enforcement-tests: OK` |
| Coverage, `roadmap-claim-check.ps1` | 14 of 14 | 15 of 16 site(s) fixtured (1 not a rule: the UNGRADED roll-up) |
| `ritual-checks.ps1` | RESULT OK | RESULT OK |

The difference of 18 is exactly the nine new cases (an exit-code and an output assertion each). No pre-existing case changed.

### Remediation of the phase 3 round 2 review (R2-1, R2-2, R2-5)

`ai-code-review-phase-3-round-2.md`: approve with follow-ups; F1, F2, F5 and F6 of the first review confirmed fixed. Remediated here:

- **R2-1** (a claim the visibility reading found, bound to no row by the strict token, was skipped in silence while the OK line said
  Owners were graded; the reviewer's example, a row "Alpha 011-aaa." with a stranger as Owner, was a stranger that `660cccb` failed and
  `666fddc` passed). Two changes, both mine: the binding is now **case-insensitive** (as the visibility reading is) and a **final full stop
  is not part of the name** (a dot followed by a letter or digit still is), so the reviewer's example and a row written in capitals bind
  and are graded; and a claim that passes visibility but still binds to no row prints
  `not graded — claim '<claim>' is on a roadmap row only in a form this check cannot bind to the claim (inside a longer name, say) ...`,
  adds the clause `the Owner of '<claim>' was not graded` and the verdict is `UNGRADED`, exit 0, never a silent skip. New rule `CLAIM-015`
  (`fail`: the claim only inside `011-aaa_x`; `pass`: written `011-aaa`) and two `CLAIM-009` fixtures that pin what must still bind
  (`fail-claim-written-with-final-period`, `fail-claim-written-in-capitals`). Shown against the `666fddc` script: all three `fail` cases
  fail there (the two `CLAIM-009` ones on exit code and output, `CLAIM-015/fail` on output), and the `CLAIM-015` `pass` passes.
- **R2-2** (the delimiter set is narrower than what a branch name may hold). Accepted as the safe direction (two claims that still collide
  are not graded) and the script header now says exactly what the token is rather than "characters that cannot continue a branch name".
- **R2-5** (the `CLAIM-014` summary named one of two ways to reach the line): reworded in `rules.json`.
- **Not changed, on the record**: R2-3 (a table with no Owner column stays `OK` with its line, an ambiguity or an unbound claim gives
  `UNGRADED`: the first leaves nothing the check could have read, the others a reading it tried and could not make) and R2-4 (an ambiguous or
  unbound claim is kept out of both the roster check and the WIP count, said aloud, exit 0). Both are visible in the output and neither is a
  block.

| Measurement | After the phase 3 remediation | After round 2 |
|---|---|---|
| `-Case CLAIM-` | 135 passed | 143 passed, 0 failed (the 8 are four new cases, two assertions each) |
| `-Case RIT-` | 129 passed | 129 passed, 0 failed |
| `ritual-checks.ps1` | RESULT OK | RESULT OK |

The full harness for the final commit is recorded under T020 below. No roster, an empty roster and an unusable roster still reach none of this
code, so their output is unchanged; every pre-existing case is unchanged.

## Phase 4: guidance, flow-down and bookkeeping

### T015 to T017: the documents

- `docs/sdlc/critical-delivery.md` item 5: the team arm now says the Reviewer must be on the roster and permitted, what the
  roster holds (names or objects, mixed; a missing `canApproveCritical` permits, a non-boolean denies; `repos` read by
  nothing), that names match exactly and case-insensitively, and the plan D9 sentence: membership catches a stranger, a
  typo, an undeclared name and a person the record says may not judge, and does not prove identity. One digest marker added
  (within 120 characters).
- `docs/sdlc/team-workflow.md`: a subsection after the pipelining text, "What the machine counts, and what it cannot see":
  the roster shapes, the Owner reading (one roster name per cell; a claim is bound to its row by its name as a whole word,
  preferring the row that holds `specs/<claim>/`; disagreeing rows are UNGRADED), the WIP counter (what it counts, the
  14-day stale rule, more than two fails, exactly two is a note, an unreadable date is UNGRADED), what only a human can see (a
  pull request being open, territory disjointness, identity), and that all of it is graded only where a roster is declared.
  Two digest markers.
- `adoption/updating.md`: a flow-down note for the roster (what was wrong, what it does, a table of the three newly failing
  conditions with their fixes, what flows down, what an owner may newly see, what does not change, what was measured, what to
  do) with two digest markers after the table. `adoption/greenfield.md`: the two places that describe `developers` now say
  it is the roster and that names must be written as the Owner cells and Reviewer lines write them.
- The update note is the honest place for two things the spec did not foresee: a **one-name** roster is a roster, so a solo
  project that declared `["me"]` and spells its Owners differently would go red on the first run; and `build-digests.ps1` must be
  run after the update, as after every update that moves a marker.

### T018: the measurement (SC-003, FR-011)

Method: for each project, `git clone` from its local directory into the scratchpad (never the real project), nested code
repositories cloned in beside it and excluded from the outer status as the real project does; `verify-kit.ps1`,
`enforcement-pack.ps1`, `roadmap-claim-check.ps1` and `ritual-checks.ps1` run in the installed state (S0); the kit as of
`85b944f`, the parent of this feature, applied with `update-kit.ps1` and committed in the clone (S1); `build-digests.ps1` run
and committed; the kit as it stands applied (S2); digests rebuilt. Each state is also recorded as applied, before the digests are rebuilt.
Nothing was pushed and the clones' `origin` is the real directory.

| Project | Roster | Verdicts S0, S1 and S2 (rebuilt) | Differences in output S1 to S2 |
|---|---|---|---|
| FitForge | `anas.m`, `ahmad` (strings) | `verify-kit` OK, `enforcement-pack` OK, `roadmap-claims` OK (1 claim), `ritual-checks` `RESULT OK` in S0 and after the digests are rebuilt in S1 and S2 (`RESULT FAIL` as applied, see below) | `.kit-version` commit; `enforcement-pack` changed files 19 to 22; digest markers 90 to 93; **`roadmap-claims` OK line gains `, Owners and claim counts graded against the declared roster`** |
| FlowBoard | none | the same members OK (`roadmap-claims`: no claims on `origin`) | `.kit-version` commit; changed files 19 to 22; digest markers 67 to 70 |
| ExpenseTracker | none | the same members OK (1 claim) | `.kit-version` commit; changed files 19 to 22; digest markers 67 to 70 |

**No verdict moved in any project.** What moved: `ritual-checks.ps1` is `RESULT FAIL` **as applied**, in S1 and S2 alike
and in all three projects, because the `digests` member reports the stale digests until `build-digests.ps1` is run. That is
the existing flow-down step, it fails identically after the kit as it stood before this feature (S1), and it is `RESULT OK`
after the rebuild, so it is not a verdict this feature moves; the update note tells the adopter to run it. Between the installed state and S1 the
output differs in every project (the changes of features 018 to 020), listed here only so it is not attributed to 021.

Liveness, FitForge's clone, S2: the claim `002-identity-member-profile` has Owner `anas.m` on its row. Writing the Owner as
`Anas M.` made `roadmap-claim-check.ps1` print `claim '002-identity-member-profile' is owned by 'Anas M.', who is not on the
developer roster in kit-adoption.json (anas.m, ahmad) ...` and exit 1 (finding count 1 of 1); the edit was discarded with
`git checkout` and the clone was clean. Not exercised, and said so: no adopted project has a Critical feature, two claims for one
Owner or a claim whose tip date cannot be read.

**Observation for the owner (SC-001 against FR-005 to FR-007), and a decision asked for.** SC-001 says every verdict a string-only
roster produced before is byte-identical after. Read literally that is not true. Four classes of project with a **declared** roster
move a verdict, each by design: a team project whose Reviewer or roadmap Owner is not on a string roster (FR-005, FR-006); a
**one-name** roster whose roadmap Owners are spelled otherwise (the likeliest first red run, because any declared roster now counts);
a roster with a **third active claim** for one Owner (FR-007); and a roster whose Owner cell holds more than one name or decoration
(`ada, grace`, `**ada**`), which is a stranger. What is byte-identical is the reader's mode and count, the doctor's output for a record
of names, every existing fixture, and any project with no roster, or whose names, Owners and claims already match. The measurement
found no project among the three that falls in any of the four classes. The update note names all four in "What an owner may newly
see" rather than claiming byte-identity for every roster. **Proposed for the owner's approval (not made: an amendment is never
approved by its author, constitution I): reword SC-001 to "Every verdict a string-only or absent roster produced before is
byte-identical after, except where a declared roster does not match the Reviewer, Owner or claim count the new checks read."**
### T019: digests and the roadmap

`scripts/build-digests.ps1` regenerated (5 digests, 96 markers). The roadmap row for the developer roster is `shipped`, Owner
`anas.m`, spec link `specs/021-developer-roster/` unbracketed; the decisions-log entry states what stays open by decision:
membership is not identity, `repos` is read by nothing, assignment authority (GAP-024 b and c) is out, and the row's old wording
("at most one active claim per Owner") is corrected to the shipped rule (more than two fails, two is a note). The inventory rows
carry no closed marker in the kit's precedent, so none was added.

### Remediation of the phase 4 review (F1 to F6)

`ai-code-review-phase-4.md`: **request changes**; F1 blocked. Remediated in phase 4 Territory only (documents):

- **F1** (blocking): `adoption/updating.md` named a path in the feature's spec directory, which does not flow down, so `doc-lint`
  failed in an adopted project after the update. Mine: the measurement ran before that sentence was written and I did not re-run it.
  The path-shaped token is gone (the note says "the notes of feature 021 in the kit repository"); no other kit-only path appears in the
  five flowing documents. The T018 measurement was **re-run on fresh clones of all three projects with the documents as shipped**:
  `doc-lint` is `OK` in every S2 state, as applied and after the rebuild, in all three. The Owner probe was repeated on FitForge's
  clone with the final script (Owner `Anas M.` named with the roster, exit 1, discarded, clone clean).
- **F2**: the T018 table row and the update note now say `ritual-checks` is `RESULT FAIL` as applied (the `digests` member, stale until
  `build-digests.ps1`) and `RESULT OK` after, identically for the kit as it stood before this feature.
- **F3**: "blank and non-string entries are dropped" is replaced by "every entry that is neither a non-blank name nor an object with a
  usable `name` is dropped" in `team-workflow.md`, `critical-delivery.md` and the update note, and in feature 013's older paragraph of
  `updating.md` that said the same.
- **F4** (the roadmap row said "at most one active claim per Owner"): **amended on the owner's approval, anas.m, 2026-10-12 ("go with your recommendation"): the row now reads "at most two active claims per Owner, exactly two being a note". Earlier text, kept for the record: left for the owner**; the decisions-log entry is the
  correction. Say if the row's parenthesis should be amended to "at most two active claims per Owner, exactly two being a note".
- **F5**: the observation above now lists all four classes and proposes the SC-001 rewording for the owner's approval.
- **F6**: the update note documents the `not graded` line for a roster over a roadmap with no `Owner` column (and for a claim that binds
  to no row), says the doctor's roster line needs an object with a usable `name`, and `roadmap.md` and `notes.md` have their trailing
  newline back.
### T020: the final run, on an isolated checkout of the phase 4 commit

A detached `git worktree` of `447ad7b` (the phase 4 commit with its review remediation, after the phase 3 round 2 commit
`f8303cc`), outside the repository, removed afterwards (the main checkout was untouched and `git worktree list` shows only it). An earlier run
of the same kind on `382f5da` (1327 passed) is superseded by this one:

| Measurement | Result |
|---|---|
| Full harness | **1335 passed**, 0 failed, 0 skipped, `enforcement-tests: OK` (1327 after the phase 3 remediation, plus 8 assertions for the four round 2 cases; the phase 4 commits add only documents) |
| Coverage, `roadmap-claim-check.ps1` | 16 of 17 site(s) fixtured (1 not a rule: the UNGRADED roll-up) |
| `ritual-checks.ps1 -Branch 021-developer-roster` | every member OK (`scope-repos` and `verify-kit` `n/a`, as for the kit), `RESULT OK` |
| `scope-check.ps1` | PASS on `f8303cc` (16 files, phase 3 round 2) and on `447ad7b` (6 files, phase 4) |

Run without `-Branch` in the detached checkout, `ritual-checks.ps1` is `RESULT FAIL` on `enforcement-pack` ("Branch naming: 'HEAD'
does not match a known taxonomy") and `scope-check` is `UNGRADED` (detached HEAD): the tool's own message says a wrapper must pass
`-Branch`, as CI does. Recorded so it is not mistaken for a finding; the run above is the one that counts.

Still to come: the owner's gate for phases 3 and 4, the human reviews for phases 2 to 4, the owner's decisions on F4 (the roadmap row's wording)
and on the proposed rewording of SC-001, and the phase 2 F2 fixtures decision.
