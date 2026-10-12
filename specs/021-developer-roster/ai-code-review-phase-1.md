# AI Code Review — 021 Load-bearing Developer Roster, phase 1 (the reader and the doctor)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-12
**Branches**: kit repository `021-developer-roster` (phase commit `743f148`, parent `8a5af83` "docs: 021 tasks")
**Scope reviewed**: `git diff 8a5af83 743f148` in full: `scripts/adoption-lib.ps1` (`Get-DeveloperMode`),
`scripts/verify-kit.ps1` (record dimension), `tests/enforcement/rules.json` (VK-031, VK-032), the 11 new fixtures
(`VK-017` x4, `VK-031` x3, `VK-032` x2, `CRIT-T01` x2), `notes.md`, `tasks.md`; against `spec.md` (FR-001..004, 008, 009),
`plan.md` (D1-D3, D9, D10) and `tasks.md` Phase 1 (T001-T006, Territory). Every caller of `Get-DeveloperMode` was grepped
(`enforcement-pack.ps1:301`, `verify-kit.ps1:270`; nothing else).
**Feature contract**: no new script file or package; a project that writes strings only (or nothing) sees byte-identical
output and verdicts; exit codes unchanged; the reader stays the one reader in `adoption-lib.ps1`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-sonnet-5-5 (separate session that produced the phase 1 commit)
- **Inputs provided**: phase 1 diff (`743f148` against `8a5af83`), spec.md, plan.md, tasks.md, notes.md, the scripts and fixtures at that commit
- **Attestation**: This reviewer did not produce the diff under review.
- **Prior involvement**: none. Fresh context; the author's notes were read as claims and checked.
- **Commands run**: `git diff/show 8a5af83 743f148`; `pwsh -File scripts/scope-check.ps1`; `pwsh -File scripts/ritual-checks.ps1`;
  `pwsh -File tests/enforcement/Run-Tests.ps1 -Case VK-` and `-Case CRIT-T01`; the full harness in a detached `git worktree`
  of `743f148` outside the repository (removed afterwards); a differential probe script (old library from
  `git show 8a5af83:scripts/adoption-lib.ps1`, new library from the working tree, 40 hand-built records, all in the scratchpad,
  outside the repository); a Unicode comparer probe over the whole BMP.

## Verdict

**APPROVE with follow-ups.** The reader does what phase 1 promises. Across 40 records I constructed, every string-only,
absent and degenerate record (the 19 the author used plus null entries, nested arrays, blank/untrimmed names, a root array,
unparseable JSON, `developers` as object/string/null/empty) returns byte-identical `Mode`, `Count`, `Declared`, `Why` and
`Problems` (message and fix) to the parent; every record that differs is one that uses an object entry, which is the point of
the feature. Every return path carries `Roster` and `HasObjectEntries`. The doctor prints its new line only when an object
entry exists, a WARN does not fail the adoption, scope-check passes, and ritual-checks is green. Two small defects in the new
code path (F1, F2) and some doc drift are worth fixing before phase 2 builds on `Roster`; neither moves a verdict for any
record an adopted project writes today. F1 is the one that matters for later phases: it can silently lose a denial.
Certification of the gate is the owner's; nothing here claims it passed.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Scope | `git diff --name-only`: `scripts/adoption-lib.ps1`, `scripts/verify-kit.ps1`, `specs/021-developer-roster/{notes,tasks}.md`, and 34 paths under `tests/**`. All inside the Phase 1 Territory (`scripts/adoption-lib.ps1`, `scripts/verify-kit.ps1`, `tests/**`) plus the feature's own spec directory. `pwsh -File scripts/scope-check.ps1`: **`scope-check: PASS phase 1 commit 743f148 (38 file(s))`**. No Phase 2-4 work: `enforcement-pack.ps1`, `roadmap-claim-check.ps1`, `ritual-checks.ps1`, `docs/**` are untouched. |
| Spec match (FR-001..004, 008, 009) | FR-001/D1: one reader, `Roster` of `{Name; Repos; CanApproveCritical; Form}`, dedup via an `OrdinalIgnoreCase` set, string entry = no repos + permitted. FR-002: all five old fields kept. FR-003/D2: nameless object dropped and reported by position; non-array/blank/non-string `repos` reported and read as none; non-boolean `canApproveCritical` (`null`, `0`, `"true"`) reported and read as NOT permitted (probed: `flagNull`, `flag0`, `flagTrueStr` all `False`); unknown keys ignored. FR-008/D10: see the doctor row. FR-004/009 (no verdict moves): see the differential row. |
| Differential, old vs new library (my records) | Identical on: absent, null, empty, not-array, `developers` as object, root array, unparseable, strings only, string dup (`"ada","ADA "`), blank string, number entry, `null` entry, nested-array entry. Differences only where an object entry exists, all as D1/D2 intend: `[{"name":"a"},"b"]` is now team/2 with no problem (parent: solo/1 plus a "blank or non-string entry" problem); nameless/blank-name/non-string-name object is now named by position; two objects `[{"name":"ada"}]` count 1 (parent 0). The parent could even move a project **to** solo by dropping an object; the new reader cannot. |
| Safe-direction rule (D2) and duplicates | `["ada",{"name":"ADA","canApproveCritical":false},"b"]`: person denied, roster entry is the first spelling `ada` (Form `string`), `HasObjectEntries` true. Denial in the first copy (`[{"name":"Ada","canApproveCritical":false},"ada"]`): denied. Both objects, flag `0` in the second: denied. Three copies with a denial in the middle: denied. Case-different `repos` (`API` vs `codeRepos` `api`): no warning (case-insensitive, D3). Padded `" api "`: trimmed. Exception: F1. |
| Callers | `enforcement-pack.ps1:301` wraps it; `:313` reads only `.Mode` and `:314` `.Why`, both unchanged for string-only input. `verify-kit.ps1:270` is the only other caller; it reads `.Declared`, `.Problems`, `.Count`, `.Mode`, and now `.HasObjectEntries`/`.Roster`. Nothing else dot-sources the function. |
| Contract on every return path | 8 early returns (no record, unreadable, root not object, unparseable, not PSCustomObject, null, not array) each add `Roster = @(); HasObjectEntries = $false`; the final return sets both. Probed under all of them. |
| Doctor (`verify-kit.ps1:270-285`) | `Severity -eq 'warn'` selects `Add-Finding WARN`, otherwise `FAIL` as before; a hashtable without the key yields `$null`, safe under strict mode. The roster `ok` line is gated on `HasObjectEntries`. VK-031/pass (strings only) has no such line and its text equals the existing pass transcripts; VK-032/fail ends `OK — adoption integrity verified (1 warning(s))`, exit 0, so a WARN never fails an adoption (FR-012). |
| Fixtures | Read all `expected.txt` and the record bodies. Each `fail` carries the stated cause: `fail-object-no-name` (position 1, nameless), `fail-repos-not-array`, `fail-flag-not-boolean` (message plus roster line naming `ada` as denied), `fail-duplicate-forms` (`'ADA'` named, count 1, solo), VK-031 `fail` (grace denied) and `fail-all-permitted` (the other branch of the roster line), VK-032 `fail` (`ops` not in `codeRepos: api`). `pass` states are the nearest non-firing state: strings-only record (no roster line), declared repo (no warning). The two CRIT-T01 cases prove an object or mixed roster is `team` (human-pr-review.md demanded), which the parent mis-read as solo. Expectations are hand-written literals, not generated from script output. Note the harness `fail`/`pass` naming is the rule firing, so VK-031/032 `fail` exit 0 by design (same as VK-018). |
| rules.json | VK-031 anchor `roster read from kit-adoption.json` (one site), VK-032 anchor `Add-Finding WARN 'record' $problem.Message $problem.Fix` (one site); VK-017's anchor still names exactly one line after the `if/else` rewrite. The coverage tests pass (`-Case VK-` below); the author's coverage figures (verify-kit 36 of 37, whole 220 of 232) are consistent with +2 sites. |
| Tests run by me | `Run-Tests.ps1 -Case VK-`: **185 passed, 0 failed**. `-Case CRIT-T01`: **43 passed, 0 failed**. Full harness in an isolated worktree of `743f148`: see "Test coverage observed". `ritual-checks.ps1`: **RESULT OK** (doc-lint OK, enforcement-pack OK, scope-check OK, scope-repos n/a, digests OK 5 fresh / 91 markers, roadmap-claims OK, verify-kit n/a). |
| Line endings / style | `adoption-lib.ps1`, `verify-kit.ps1`, `rules.json`, `notes.md` contain no CR (pure LF), as at the parent; the new code follows the surrounding comment-heavy style and the one-hashtable-per-return convention. |
| Rollback safety | Phase reverts as one commit; additive keys on the returned hashtable; no record or schema change. |
| Constitution / security | No external input beyond the local record; no secrets or logging beyond names and positions already printed. Constitution I: `tasks.md` diff is ticks only (see Amendments). |

### Deviation: byte-identity at the reader instead of three saved doctor transcripts (T001)

**Justified.** The doctor prints nothing from the record except `Declared`, `Problems`, `Count`, `Mode` (and `HasObjectEntries`,
which is false for strings), and the enforcement pack reads only `Mode` and `Why`; so equality of those fields over a corpus is
a stricter proof than three transcripts, and I reproduced it on a wider corpus. It is, however, an edit of an approved task's
wording that the plan did not authorise, so it should be recorded as an owner-visible deviation (F5), and the notes record
neither the `-Case CRIT-` nor `-Case CLAIM-` counts that T001/T006 asked for (F5).

## Findings

### F1 — minor (carries the most risk for phase 2) — a denial is silently lost, and the doctor can error, when two names are equal only under ordinal comparison — `scripts/adoption-lib.ps1:178-185`

The duplicate loop detects a duplicate with an `OrdinalIgnoreCase` `HashSet`, then finds the kept copy with
`Where-Object { $_.Name -ieq $n }`. The two comparers are not the same (the library's own comment at the line above warns:
"ONE comparer ... two comparers that disagree would dereference an empty group (013 phase 4 re-review, N6)"). I found two
code points where they disagree (U+0345 vs U+0399, U+1E9B vs U+1E60). Record:
`{"developers":["ẛ",{"name":"Ṡ","canApproveCritical":false},"b"]}`. Result: `$kept` is `$null`, `$kept.CanApproveCritical = $false` (line 185) raises
`InvalidOperation` at line 185 (non-terminating under the default preference, fatal in a `Stop` context), the denial is
dropped and `Roster[0].CanApproveCritical` is `True`: the permissive direction, against D2. Exotic and unlikely in a real
roster, but it is the same defect class the file's own comment records, and phase 2 will make `CanApproveCritical` load-bearing.
*Suggested fix:* key the kept entries by name in a `Dictionary[string,object]` constructed with
`[StringComparer]::OrdinalIgnoreCase` (or look the name up through the same `HashSet`'s comparer) so detection and lookup are one
comparer; add a fixture case of a denial in a second copy.

### F2 — minor — a single-element array is accepted as an object entry's `name` — `scripts/adoption-lib.ps1:130`

`$name = if ($props -contains 'name') { $e.name } else { $null }`: an `if` used as an expression enumerates its output, so
`"name": ["a"]` becomes the string `a` and passes the `-isnot [string]` test (probe `nameArr`: roster `a`, no problem). An empty
array becomes `$null` (dropped, correct), a two-element array stays an array (dropped, correct). D2 says a name must be a
non-blank string. Effect: the entry is accepted where it should be reported; benign today but a laxer reading than specified.
*Suggested fix:* `$name = $null; if ($props -contains 'name') { $name = $e.name }` (assignment, no unrolling), or read
`$e.PSObject.Properties['name'].Value`. Add a `fail` case for `"name": ["ada"]`.

### F3 — nit — key and flag names match case-insensitively — `scripts/adoption-lib.ps1:130-153`

`$props -contains 'name'` is case-insensitive, so `{"Name":"ada"}`, `{"Repos":[...]}`, `{"CanApproveCritical":false}` are read as
the documented keys (probe `objNameInherited`). The denial case is the safe direction (a flag written in any case is honoured),
and `ConvertFrom-Json` already rejects a record whose keys collide by case. Harmless, but D2/D3 speak of exact matching; say in a
comment that key names are not case-sensitive, or match with `-ceq`.
*Action:* decide and document; no behaviour is wrong today.

### F4 — nit — a repeated name inside one `repos` array is kept — `scripts/adoption-lib.ps1:143`

`"repos": ["api","api"]` yields `Repos = api,api` with no problem (probe `reposDupInside`). Nothing reads `repos` (FR-012), so no
effect. *Action:* none, or dedupe when a later feature reads it.

### F5 — doc drift — notes and the header comment — `notes.md:80`, `notes.md` T001/T006, `scripts/adoption-lib.ps1` header

- `notes.md:80` ends "the isolated-checkout run of the final commit is T020": T020 is phase 4's task; the phase 1 run is
  T006 (already stated as run on the working tree). Correct the reference.
- T001 required `-Case CRIT-` and `-Case CLAIM-` baseline counts; `notes.md` records only `VK-` (parent "n/a"). The author's
  full-harness figures are the only record that CRIT-/CLAIM- cases were unchanged. Add the counts, or record the omission.
- The `Count` entry in the header comment ("dropping non-strings/blanks") is now incomplete: an object with a usable name counts.
- The deviation from T001's wording (byte-identity at the reader, see above) is recorded in `notes.md` but not in `tasks.md`;
  the plan owner should acknowledge it, since `tasks.md` is an approved document I may not edit.
*Action:* the author fixes the notes and the header comment; the owner acknowledges the deviation.

### F6 — nit — the "no `codeRepos`" WARN is noisy for a single-repo project — `scripts/adoption-lib.ps1:137-148`

A project with `repos` entries and no `codeRepos` gets one WARN per unknown name (probe `reposNoCode`). Documented in the notes and
correct per FR-008, and a WARN does not fail the doctor, so this is awareness only: it will show in adopted projects' CI logs as
`(N warning(s))`. Phase 4's guidance should say a roster using `repos` should declare `codeRepos`.
*Action: none now; carry into phase 4 documents.*

## Amendments in this diff

- [x] None. `tasks.md` changes are the six checkbox ticks T001-T006; `spec.md`, `plan.md` and contracts are untouched. (The reader
  deviation in notes.md is not an amendment of an approved document; see F5.)

## Constitution re-check (post-implementation)

**PASS.** I (spec first, no amendments), II (no new conflict; the plan's recorded D5 conflict is phase 3), IV (one reader, no new file),
VI (names and positions only), VIII (a failing and a passing hand-written fixture per new rule), IX (this review, human review at
merge), X (one phase, owner runs the gate: `**Gate Certification**: user-run`). III, V, VII not applicable.

## Test coverage observed

- `-Case VK-`: 185 passed, 0 failed (reproduced). `-Case CRIT-T01`: 43 passed, 0 failed.
- Full harness, detached worktree of `743f148` outside the repository: **1233 passed, 0 failed, 0 skipped** (parent per the author: 1211; difference 22), coverage verify-kit.ps1 36 of 37 site(s) fixtured
- New assertions: 11 cases x 2 (exit code, output) = 22, plus the rule-coverage assertions, matching the author's 1211 to 1233.
- Not covered by any fixture: object-form `name` of non-string type (F2), the comparer-disagreement case (F1), `canApproveCritical`
  `null`/`0`/`"true"` beyond the single `fail-flag-not-boolean` record, `codeRepos` absent with `repos` set. My differential probe
  covers these; the gaps are worth one fixture each only for F1 and F2.

## Residual risk

Concentrated in `Roster` becoming load-bearing in phase 2: F1 (a lost denial on an exotic spelling) and F2 (an array accepted as a
name) are in the one function phase 2 trusts. Neither changes any verdict for string-only or absent records, which I verified
differentially. Fix F1 and F2 (a few lines and two fixtures) and correct the F5 notes before or with phase 2; none blocks the
owner running the gate on phase 1.
