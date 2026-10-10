# AI Code Review — 017 Level Declaration Graded (Phase 2)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-11
**Branches**: agentic-sdlc-kit `017-level-declaration-graded` (phase-2 commit `5eeae60`)
**Scope reviewed**: `git show 5eeae60` in full (78 files: `scripts/adoption-lib.ps1`,
`scripts/verify-kit.ps1`, `adoption/updating.md`, `docs/digests/adoption-digest.md`,
`tests/enforcement/rules.json`, 7 new fixtures under `tests/enforcement/cases/verify-kit/VK-029`
and `VK-030`, 50 edited `expected.txt` files, `notes.md`, `tasks.md`).
Read for context: `spec.md` (US3, FR-004, FR-005, FR-013), `plan.md`, `research.md` R7,
`data-model.md` ("Critical Surface list"), `contracts/level-declaration-contract.md` sections 1
and 4, `tasks.md` Phase 2 and its Territory, `notes.md` Phase 2; `CLAUDE.md`; constitution X;
`scripts/adoption-lib.ps1` in full (`Get-DeveloperMode`); `scripts/verify-kit.ps1` dimension 4;
`scripts/scope-lib.ps1` (`Get-Territory`, `Test-InTerritory`); `scripts/init-kit.ps1`;
`tests/enforcement/Coverage.Tests.ps1`, `emission-idioms.json`; the phase-1 review (house style).
**Feature contract**: phase 2 = T007-T012 (US3): the optional `criticalSurfaces` key, its shared
reader `Get-CriticalSurfaces`, the doctor's reporting, rules and fixtures, a flow-down note.
Nothing enforces yet. Territory: `scripts/adoption-lib.ps1`, `scripts/verify-kit.ps1`,
`adoption/updating.md`, `docs/digests/**`, `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-sonnet-5-5 (the implementing session)
- **Inputs provided**: commit `5eeae60` (`git show --stat` and full diff); the 017 feature
  documents (`spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/`, `tasks.md`,
  `notes.md`); the kit's law (`CLAUDE.md`, constitution, Definition of Done, review process); the
  review template and the phase-1 review for style; read and run access to the working tree.
  No repository file other than this review was modified; scratch files were kept under
  `$env:TEMP` and removed.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The phase does what T007-T012 say, inside Territory, and the reader
obeys its own design rule on every input I could construct: no problem ever yields a result more
armed than the same record without it, and an unusable entry is never dropped from an armed list.
No existing expectation was weakened (50 files, one added line each, zero deletions); all 155 tests
selected by `-Case VK-` pass. There is no Blocker and no Major. The follow-ups: the doctor's
"armed" line states an enforcement that does not exist yet (F1, wording), the reader reports a
broken record as "absent", which phase 3 cannot tell from "no key" (F2, needs a decision before
phase 3), and two of the author's departures from approved documents are recorded only in
`notes.md` (F3, owner to acknowledge). The remaining items are record accuracy and fixture gaps.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (US3, FR-004, FR-005, FR-013) | No key: not armed, one informational line, exit 0 (VK-029 `fail`, 8 lines, exit 0). Empty / malformed / valid each print a distinct line (US3 independent test): `fail-empty`, VK-030 `fail*`, `pass`. Malformed is reported by key in the doctor's FAIL form (`kit-adoption.json criticalSurfaces ...`) and is not treated as empty (`adoption-lib.ps1:193-195`, `:215-222`). Nothing required of phase 2 is missing |
| Scope | `pwsh -File scripts/scope-check.ps1`: `PASS phase 2 commit 5eeae60 (78 file(s))`. `git show --stat`: every path is `adoption/updating.md`, `docs/digests/`, two scripts, `tests/`, or the feature's own `notes.md`/`tasks.md`. No package, no other script |
| Reader: shapes tried | I called `Get-CriticalSurfaces` (dot-sourced) on about 45 inputs, normally and again under `$ErrorActionPreference='Stop'` plus `Set-StrictMode -Version Latest`; results identical. No file, directory named `kit-adoption.json`, root array, root string, unparseable, case-duplicate keys (PS7 parse error), key absent: `absent`, Armed false, Declared false. BOM + valid: `valid`. `null`, `"x"`, `5`, `{}`, `[""]`, `["a",5]`, `["a",null]`, `[null]`, `[[]]`, `[["a"]]`, `[{"a":1}]`, `[true]`, `[[],"a"]`, `["C:/x"]`, `["c:x"]`, `["a:b"]`, `["../x"]`, `["a/../b"]`, `["a/.."]`, `["/abs"]`, `["\\abs"]` (backslash), `["\\\\srv\\x"]`, `["..\\x"]`: all `malformed`, Armed false, one Problem per class (blank/non-string once; each unsafe entry once). `[]`: `empty`, Armed false, no Problem. `["a"]` (single element): `valid`, `Globs` is an array of 1 (the `@()` wrapping holds). `["a","A"]`, `["Src/Auth","src\\auth"]`: `valid`, collapsed to one. `["src\\auth\\"]`: `valid`, Globs `src/auth/`. `{"CriticalSurfaces":[..]}`: read as the key (`-contains` and property access are both case-insensitive, same as `Get-DeveloperMode`; the doctor and the future check share it). 20,000 entries: `valid`, 0.9 s. Mixed valid+invalid never arms: `["a",5]` returns `malformed` with Globs `[a]` and Armed false |
| Reader: Globs misuse | Globs is populated for `malformed` (usable entries only), as the header comment says ("for messages only"). Armed is the single safe gate; a phase 3 caller that tests `Armed` cannot grade against a partial list |
| Doctor behaviour | Block sits after the developers block and before gate proof (`verify-kit.ps1:289-307`). It runs on every path that reaches the record object. I ran the doctor on a root-array record and a root-string record (F7) and on an unparseable one: for the unparseable record the block is not reached and no criticalSurfaces line prints (`does not parse as JSON` only). Multi-repo and tier-failure records still print the line (VK-009 `fail`, a bad topology, shows it). The loop variable rename to `$surfaceProblem` is sound: it no longer shadows `$problem` from the developers loop; both loops use `Add-Finding FAIL 'record'` with the reader's `Message`/`Fix` verbatim |
| Harness | `Run-Tests.ps1 -Case VK-`: `Tests Passed: 155, Failed: 0, Skipped: 0` (128 s). `-Case VK-029`: 39 passed, 0 failed. The coverage assertions in `Coverage.Tests.ps1` (anchor matches exactly `siteCount` emission sites; every rule has a pass and a fail case) are part of those runs and pass |
| No expectation weakened | `git show 5eeae60 --numstat -- tests/enforcement/cases/verify-kit`: the 50 modified `expected.txt` show `1 0` (one insertion, zero deletions); the 7 new ones show `8 0`. The inserted line is the same text in all 51 files (50 modified + new VK-029 `fail`): `verify-kit: ok record — criticalSurfaces not declared — the surface floor is not armed (adoption/updating.md)`. No removed line, so no line-ending artefact either. I read eight at random (VK-001, 004, 009, 012, 016, 019, 023, 027): the line sits where the doctor prints it, before `adoption record valid`, or before `kit-version` when a record FAIL suppresses the valid line (VK-009, VK-027). The harness compares exact output, so the passing run confirms every placement |
| Fixtures honest | `pass` (two distinct valid entries) fails if the armed line is not printed, or counts wrong. `fail-empty` exits 0 with the empty line: a wrong implementation treating `[]` as malformed would exit 1 and fail it. `fail-blank-entry` is `["src/auth/", "  "]`, a usable entry beside a blank: an implementation that drops the blank and arms prints the armed line and exits 0, failing the exit-code 1 and the expected FAIL line. `fail` (string) pins non-array; `fail-absolute-path` pins the unsafe branch via a leading slash. `siteCount: 3` with anchor `the surface floor is `: the armed, "is not armed" (empty) and "is not armed" (absent) messages are the three sites; the coverage test counts them exactly, so a fourth message under the anchor fails the suite. Sound |
| Law and honesty (docs) | `adoption/updating.md` note: `scripts/init-kit.ps1` does not prompt for the key (read `init-kit.ps1`: parameters are developers, repos, topology; no `criticalSurfaces`; matches contract section 1). "On every run that reaches the record" is true (F7 qualifies the wording, not the claim). "A project script matching complete doctor output needs the line added" is true: the doctor prints one more line. The note says plainly that nothing changes how any run grades. Digest marker is 111 characters (bound 120); `scripts/build-digests.ps1 -Check`: `digests: OK (5 digest(s) fresh, 85 marker(s))`; `adoption-digest.md` gains exactly one line |
| Honesty of the gate | Neither the commit message nor `notes.md` claims the owner's gate. `notes.md` reports test counts and a ritual-checks result, not certification. Task ticks are progress only (F4 notes one dangling phrase) |
| Amendment authority (constitution I) | `git show --stat 5eeae60 -- specs/`: only `tasks.md` (T007-T012 `[ ]` to `[x]`, no other text) and `notes.md` (a section appended). `spec.md`, `plan.md`, `contracts/`, `data-model.md`, `research.md` unchanged: no amendment, no approver needed |
| PowerShell version | The doctor already uses `?:` (`verify-kit.ps1`, the `$hint = ... ? ... :` line), so it is PowerShell 7 only; the new code uses nothing 5.1 lacks or 7 lacks. `[PSCustomObject]` / `[Array]` tests behave under 7. Em dashes are the kit's existing style (the doctor already sets `[Console]::OutputEncoding` to UTF-8 at line 41) |

## Findings

### F1 — The doctor's "armed" line asserts an enforcement that phase 3 has not built — MINOR

`scripts/verify-kit.ps1:301`: "N critical surface(s) declared — the surface floor is armed: a
Standard or Micro feature whose Territory reaches one fails the ritual checks
(docs/sdlc/critical-delivery.md)". On the branch tip nothing reads the list
(`grep Get-CriticalSurfaces scripts/`: only the doctor), so the sentence is false today, and it
contradicts the same commit's `adoption/updating.md` note ("nothing here changes how any run
grades"). It is also unconditional: the design lets a feature carry an approved Surface
Exception, and a Critical feature is never failed by the floor. VK-029 `pass` and VK-030 `pass`
pin the text. Same class as phase-1 F1. The "not armed" lines are true and need no change.
In scope: yes. Fix: until phase 3, say what is true, for example `N critical surface(s)
declared — recorded for the surface floor (docs/sdlc/critical-delivery.md)`, update the two
`expected.txt`, and let phase 3 strengthen the wording when the check exists (rules.json
`VK-029.notes` says the same thing about the armed line, so it follows).

### F2 — A record the reader cannot read returns "absent", which phase 3 cannot tell from "no key" — MINOR (owner decision before phase 3)

`adoption-lib.ps1:170-180` returns `State 'absent'`, `Declared $false` for: no file, unreadable
file, root not an object, unparseable, root not a `PSCustomObject`. The author's reason is sound
for the doctor (the defect is already reported once, by `Get-DeveloperMode` and the doctor's
own parse check), and the design rule holds (absent is never more armed). But phase 3 will call
this reader without the doctor. A project that *did* declare surfaces and then broke the JSON
syntax gets `absent`: not armed, silent, exit 0, from the enforcement check, while
research R7 and US3 scenario 2 reserve "UNGRADED, not silent" for a declared list the check
cannot use. What stops the silence today is only that the doctor runs in adopted-project CI.
Distinguish the two for the caller without making the doctor double-report: for example a
`Readable = $false` field (or a State `unreadable` with an empty `Problems`), which phase 3 maps
to UNGRADED and the doctor ignores. In scope: yes (reader contract), but the choice shapes the
check, so the owner should decide it now rather than discover it in phase 3.

### F3 — Three departures from approved documents are recorded only in `notes.md` — NOTE (owner to acknowledge)

`notes.md` (Phase 2, "Reader decisions") departs from `data-model.md` and research R7 on: (a) an
empty array is State `empty` and "not a problem" (R7 and the data model call it "an unfinished
edit, as for developers"); (b) duplicates collapse silently (the data model says "duplicates
collapsed"; no problem is required either way); (c) root/parse failures return `absent`
(F2). I judge each defensible and none breaks FR-004, FR-005, FR-013 or an acceptance scenario:
(a) leaves R7's table behaviour unchanged (not armed, informational line, exit 0) and is
better matched to "an explicit empty list says none"; (b) agrees with the data model. Only the
rationale sentence in R7/data-model is now untrue, and the approved documents were rightly not
edited by the implementer. If the owner agrees, the one-line change to R7 and the data model is
an amendment that carries an approver; the implementer must not approve it. Also, contract
section 4 names the lines `criticalSurfaces: N declared` / `not declared`; the doctor prints
`N critical surface(s) declared — ...` / `criticalSurfaces not declared — ...`. The contract
describes content, and the lines are informational; no change needed beyond the same owner
acknowledgement. In scope: no (documents the implementer cannot amend).

### F4 — The commit message and `notes.md` say 41 existing expectations changed; 50 did — MINOR

`git show --diff-filter=M --name-only 5eeae60 -- tests/enforcement/cases/verify-kit` lists 50
files (27 distinct VK-0xx directories); the new line appears in 51 files, one of which is the
new VK-029 `fail`. The commit subject body and `notes.md` ("41 pre-existing `verify-kit`
`expected.txt` files") both say 41. The change itself is correct (each is one added line, run
passes); the stated count is wrong, which matters because the count is how a reviewer checks the
hand edit was complete. Also `notes.md` ends "Full harness: see below." with nothing below. In
scope: yes. Fix: correct the count to 50 in `notes.md`; replace the dangling sentence with the
actual full-harness result once it is reported, or remove it. (The commit message cannot be
changed without a rewrite; the correction in `notes.md` is enough.)

### F5 — Several states the reader distinguishes are pinned by no fixture — MINOR

The reader's behaviour is checked only through the doctor's printed lines, which never show
`Globs` or `Armed`. Unpinned: the drive-letter and `..` alternatives of the regex at
`adoption-lib.ps1:212` (only a leading slash is fixtured; deleting the other two alternatives
passes every case); `null` (shares the non-array message but is a separate branch,
`:190-192`); duplicate collapse; backslash normalisation; the singular "1" count; a non-string
entry (only a blank one is fixtured). Phase 3 will read `Globs` and `Armed` directly, so their
content (normalisation, collapse) needs pins there. In scope: yes for the doctor-visible gaps.
Fix: add `fail-dotdot` and `fail-null` variants to VK-030 (each an existing recipe with one line
changed), and pin `Globs` normalisation in phase 3's check cases. Also `rules.json` `VK-029.notes`
names a case `fail-not-declared`; the directory is `fail` (the author's notes call the
directory `fail`): fix the text.

### F6 — An entry such as `./src/auth/` arms the floor but can never match — NOTE

`adoption-lib.ps1:212` refuses drive letters, leading slashes and `..` because such entries
"sit in the list looking like coverage and match nothing". A leading `./` (or `~/`) has the same
effect: `valid`, Armed, Globs `./src/auth/`, and `Test-InTerritory` (`scope-lib.ps1:152-162`,
a `-like` on git paths) never matches it. This is the same posture `Get-Territory` has, so
the reader is consistent with it, and an entry equal to `*`/`**` arms everything, which is lawful.
Related for phase 3: the reader converts `\` to `/`, but `Get-Territory` keeps entries as written
(`scope-lib.ps1:123-130` only validates), so a Territory entry `src\auth\` would not match a
normalised glob; phase 3 must normalise both sides. Decide in phase 3 whether to refuse or strip
a leading `./`; no change is needed for phase 2.

### F7 — "criticalSurfaces not declared" prints beside a root-not-an-object FAIL — NOTE

On a root-array record the doctor prints the FAIL "kit-adoption.json is not a JSON object at its
root" and, a line later, `criticalSurfaces not declared`. The second is true of the reader's
view but a reader of the output may take it as a second fact. The developers block already does
the same (`0 developer(s) declared`, run above), so this is the established precedent, and the
declaration is genuinely unreadable. No change required; mention only so F2's fix considers it.

### F8 — `Why` and the singular noun in the valid state are not used by the doctor — NOTE

`adoption-lib.ps1:224-225` builds `$noun` and a `Why` ("1 critical surface declared ...") that the
doctor ignores, printing its own "critical surface(s)" at `verify-kit.ps1:301`. It mirrors
`Get-DeveloperMode` and phase 3 may use `Why`, so it is not dead, but the doctor's count text
and the reader's `Why` can drift. No change required.

## Amendments in this diff

None. No approved feature document changed other than `tasks.md` checkbox ticks; `notes.md` is the
implementer's own progress file. F3 describes a possible amendment that the owner, not the
implementer, would approve.

## Constitution re-check (post-implementation)

Principle I (spec first, amendment authority): held, see above. Principle II (source of truth):
no conflict between rungs found. Principle X (Level declaration, optional `criticalSurfaces`): the
reader reflects the clause (optional, repo-prefixed, trailing slash a subtree); the clause's
wording that a project's floor "fails" a feature is not yet true in code, which is F1. No
principle is weakened; the kit's own constitutional constants are untouched.

## Test coverage observed

`Run-Tests.ps1 -Case VK-`: 155 passed, 0 failed (includes Coverage assertions and the 7 new
cases). `-Case VK-029`: 39 passed. `scope-check`: PASS. `build-digests -Check`: OK. I did not run
the full harness (about 12 minutes; another run was in progress) or `ritual-checks.ps1`. The 45
reader shapes above are my own scratch runs, not repository tests; none is pinned in the harness
except through the six fixtures (see F5).

## Residual risk

The gate for phase 2 has not been reported by the owner; nothing here certifies it. The reader's
contract with phase 3 (`Armed`, `Globs`, `Declared`, `Why`, `Problems`) is exercised only through
the doctor until phase 3 adds its own cases: normalisation, collapse and the F2 distinction should
be pinned there. Nothing enforces yet, so rolling the phase back changes no verdict.
