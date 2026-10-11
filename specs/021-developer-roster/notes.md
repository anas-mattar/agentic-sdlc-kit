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
