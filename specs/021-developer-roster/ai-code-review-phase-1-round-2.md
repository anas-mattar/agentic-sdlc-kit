# AI Code Review — 021 Load-bearing Developer Roster, phase 1 remediation (round 2)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-12
**Branches**: kit repository `021-developer-roster` (remediation commit `306cc42`, parent `993564f`; phase 1 is `743f148`, its parent `8a5af83`)
**Scope reviewed**: `git diff 743f148 306cc42` in full: `scripts/adoption-lib.ps1` (`Get-DeveloperMode` header comment, the name read, the
duplicate loop), `specs/021-developer-roster/notes.md`, the new fixture `tests/enforcement/cases/verify-kit/VK-017/fail-name-is-array/`
(`command.json`, `expected.txt`, `recipe.json`); against the phase 1 review (`ai-code-review-phase-1.md`, findings F1, F2, F5),
`spec.md`, `plan.md` (D1-D3, D10), `tasks.md`, and the callers (`scripts/enforcement-pack.ps1:301`, `scripts/verify-kit.ps1:270-285`).
Shape precedent: `specs/020-rendered-structure-lint/ai-code-review-phase-3.md`.
**Feature contract**: no new script or package; a project that writes strings only (or nothing) sees byte-identical output and
verdicts; exit codes unchanged; the reader stays the one reader in `adoption-lib.ps1`; the remediation touches only phase 1 Territory
and the spec directory.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-sonnet-5-5 (separate session that produced the remediation commit `306cc42`)
- **Inputs provided**: remediation diff (`743f148` to `306cc42`), the phase 1 review, spec.md, plan.md, tasks.md, notes.md, the scripts and fixtures at `306cc42`
- **Attestation**: This reviewer did not produce the diff under review.
- **Prior involvement**: none. Fresh context; notes.md was read as a claim and checked.
- **Commands run**: `git diff`/`git show` between `8a5af83`, `743f148`, `306cc42`; a differential probe (`adoption-lib.ps1` loaded from each of the three
  commits via `git show` into the scratchpad, 28 hand-built records incl. the two comparer-disagreement pairs, run through each library);
  `pwsh -File tests/enforcement/Run-Tests.ps1 -Case VK-`, `-Case CRIT-`, `-Case CLAIM-` on the working tree (306cc42) and on detached worktrees of
  `8a5af83` and `743f148`; the new fixture copied into the `743f148` worktree and run with `-Case VK-017`; the full harness in a detached
  `git worktree` of `306cc42` outside the repository; `pwsh -File scripts/scope-check.ps1`; `pwsh -File scripts/ritual-checks.ps1`; `git ls-files --eol`.
  All worktrees were removed afterwards (`git worktree list` shows only the main checkout; working tree clean).

## Verdict

**APPROVE with follow-ups.** F1, F2 and F5 of the phase 1 review are fixed as described and I reproduced each. On `743f148`'s library a denial
written in the second spelling of a name that is equal only under `OrdinalIgnoreCase` (U+1E9B/U+1E60, U+0345/U+0399) raised an
`InvalidOperation` and the person stayed permitted; on `306cc42` the denial is kept, with no error, in the second copy, the first copy and a
three-copy case. `"name": ["a"]` is now reported as an unusable name, and every other non-string or blank name reads as before. String-only
records return identical `Mode`, `Count`, `Why` and `Problems` to the parent `8a5af83`. The new fixture fails on the old reader (2 assertions) and
passes now; counts in notes.md are right; `scope-check` and `ritual-checks` pass. Two minor follow-ups: the F1 fix has no fixture of its own
(R2-1), and notes.md's heading and wording around the deviation could be read as an owner act that has not happened (R2-2). Neither blocks.
Certification of the gate is the owner's; nothing here claims it passed.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| F1, reproduced on the old library | Probe over `743f148`'s library: `["ẛ",{"name":"Ṡ","canApproveCritical":false},"b"]` returned roster `ẛ/True` and 1 error; `["ͅ",{"name":"Ι","canApproveCritical":false},"b"]` (U+0345 then U+0399) the same. Denial in the FIRST copy worked on the old library (it is the kept entry), and a three-copy case worked, as the phase 1 review said. On `306cc42`: second-copy denials give `False`, error count 0; first-copy denials `False`; three copies (`ẛ`, `Ṡ`, `ẛ` denied) `False`; plain `ada`/`ADA` denied `False`. |
| F1, one comparer | `$seen` is a `Dictionary[string,object]` built with `[StringComparer]::OrdinalIgnoreCase` (`adoption-lib.ps1:178`); detection (`ContainsKey`), the kept entry (`$seen[$n]`) and the unique count (`$unique`) all go through it, so they cannot disagree; no `-ieq`, `-eq`, `-contains` or `Where-Object` name lookup remains in the loop. `Roster` keeps the first spelling and `Form` of the kept entry (probed). Callers: `enforcement-pack.ps1:301-314` reads only `.Mode`/`.Why`; `verify-kit.ps1:270-285` reads `.Declared/.Problems/.Count/.Mode/.HasObjectEntries` and filters `.Roster` by `CanApproveCritical` and prints `.Name`; no second name comparison anywhere (`grep Roster\|\.Name` in both scripts). |
| String-only records vs the parent | 28 records, three libraries. For the string-only ones (`strs`: blanks, number, null, nested array, padded duplicate; `strs1`; `strsdup`: `ß/SS`, `ǆ/ǅ`, `İ`, `K/k`) `Mode`, `Count`, `Why` and every `Problems` message are identical to `8a5af83`; the only column that differs is the new `Roster`. Every record that differs from the parent contains an object entry, as the phase 1 review established. Differences between `743f148` and `306cc42` over all 28 records: exactly the three records expected (`f1b_second`, `f1c_second`, `nameArr1`). |
| F2, name forms | `["a"]`, `["a","b"]`, `[]`, `{}`, `5`, `null`, `true`, `"   "`, `[["a"]]`: all read as solo 1 with problem "developers entry 2 is an object with no usable name" (only `["a"]` changed; it was accepted as `a` on `743f148`). `" ada "`: team 2, roster `ada`, no problem. String-form entries are unaffected (`strs`, `strs1`). The cause is real: `$x = if (...) { $e.name }` enumerates its output; the new `$name = $null; if (...) { $name = $e.name }` assigns without unrolling. |
| F2, the same hazard on other properties | `$r = $e.repos` and `$e.canApproveCritical` are plain assignments and comparisons, never `if`-as-expression, so no unrolling. Probed: `repos: ["api"]` kept as `[api]`; `repos: "api"`, `[["api"]]` and `null` reported and read as none; `repos: []` fine; `canApproveCritical: [true]` and `"false"` reported, read as NOT permitted; `true`/`false` read as written. No change from `743f148` for any of them (identical lines in the diff of the two outputs). |
| Fixture `VK-017/fail-name-is-array` | `recipe.json` differs from the sibling `fail-object-no-name` in two lines only (the description and `"developers": ["ada", { "name": ["grace"] }]`); `command.json` is identical (`verify-kit.ps1`, exit 1). `expected.txt` is the sibling's with the failing line unchanged ("developers entry 2 is an object with no usable name") and "1 developer(s) declared ... solo evidence rule" — correct by hand: entry 2 is dropped before the count, so one developer, solo; a record problem is a FAIL, so exit 1, `FAIL (1 failure(s), 0 warning(s))`. The description is accurate. On `743f148` (worktree, fixture copied in) `-Case VK-017` gives 47 passed, **2 failed** (exit code and output: the old reader counted `grace`, printing "2 developer(s) ... team"); on `306cc42` it passes. The harness discovers it by directory: `-Case VK-` is 187 here against 185 at phase 1. |
| F5, counts | Run by me: parent `8a5af83` `-Case VK-` **167**, `CRIT-` **75**, `CLAIM-` **67**; phase 1 `743f148` `VK-` **185**, `CRIT-` **79**, `CLAIM-` **67** (the phase 1 `VK-` run with the new fixture copied in showed 185 passed, 2 failed, i.e. 187 cases' worth); `306cc42` `VK-` **187**, `CRIT-` **79**, `CLAIM-` **67**, 0 failed. Full harness, detached worktree of `306cc42`: **1235 passed, 0 failed, 0 skipped, `enforcement-tests: OK`** (893 s). notes.md's table rows, the "1233 + the two assertions of the new fixture" arithmetic and the T020 correction (the isolated run of the final commit is phase 4's task; the phase 1 review's own isolated run of `743f148` was 1233) all match. |
| F5, header comment | `Count` entry now reads "dropping blank or non-string entries and objects with no usable name, and collapsing duplicates case-insensitively across both forms": matches the code (blank/non-string counted in `$generic`, nameless objects in `$entryProblems`, duplicates across forms by the dictionary). |
| Claims notes.md must not make | notes.md says the deviation "is listed here for the owner to acknowledge" and "(not yet acknowledged)"; it does not claim an acknowledgement and `tasks.md`/`spec.md`/`plan.md` are untouched (`git diff --stat`). See R2-2 for wording only. |
| Scope | `git show --stat 306cc42`: `scripts/adoption-lib.ps1`, `specs/021-developer-roster/notes.md`, three files of one fixture under `tests/**`. `pwsh -File scripts/scope-check.ps1` on the repo: **`scope-check: PASS phase 1 commit 306cc42 (5 file(s))`**. |
| Ritual | `pwsh -File scripts/ritual-checks.ps1`: doc-lint OK, enforcement-pack OK, scope-check OK, scope-repos n/a, digests OK, roadmap-claims OK, verify-kit n/a, **`RESULT OK`**. |
| Line endings / style | `git ls-files --eol`: `adoption-lib.ps1`, `notes.md` and the fixture's `command.json`/`expected.txt` are `i/lf w/lf`; `recipe.json` is `i/lf w/mixed`, the same as the neighbour `fail-object-no-name/recipe.json` (autocrlf working-tree artefact, index is LF). Comments follow the file's reference-the-review style. |
| Amendments | None (see below). |

## Findings

### R2-1 — The F1 fix has no fixture, so nothing in the harness would catch the denial being lost again — MINOR

`306cc42` adds one fixture (`fail-name-is-array`, F2) and none for F1, although the phase 1 review's suggested fix said "add a fixture case of a denial in a
second copy", and its coverage section named the comparer-disagreement case as an uncovered gap. The two lookup lines are the only place a roster
denial is merged, and phase 2 makes `CanApproveCritical` load-bearing. A fixture is cheap: the doctor already prints
`roster read from kit-adoption.json: ... — not permitted to approve Critical: <name>`, so a `VK-017`/`VK-031`-style record
`"developers": ["ẛ", { "name": "Ṡ", "canApproveCritical": false }, "b"]` (U+1E9B then U+1E60, written as JSON escapes `ẛ` and `Ṡ` so the
file is robust to editors and CRLF/encoding) would fail on `743f148` (the denial line would be missing, "every developer may approve Critical")
and pass now. The behaviour is correct today, only unguarded. Not a blocker: the assertion belongs naturally with phase 2's
evidence tests, where `CanApproveCritical` is consumed.
*Action: implementer adds the fixture in phase 2 (or as a phase 1 follow-up commit), or records in notes.md that F1 is covered by review probe only.*

### R2-2 — notes.md headline "Deviation acknowledgement (owner)" reads as a record of an acknowledgement — MINOR

`notes.md` adds a section titled "Deviation acknowledgement (owner)" whose text says the deviation is "listed here for the owner to acknowledge" and the
remediation bullet says "(not yet acknowledged)". The body is accurate and claims nothing; the heading alone would be read by a skimmer, or by a tool grepping
headings, as the acknowledgement itself. Nothing in the repo records the owner acknowledging it, and the approved `tasks.md` T001 still says three transcripts.
*Action: retitle to "Deviation from T001 — for owner acknowledgement" (or similar); the owner acknowledges when certifying, as noted. No code change.*

### R2-3 — F3, F4, F6 deferral is reasonable — ACCEPTED

F3 (key names match case-insensitively; the denial direction is the safe one), F4 (duplicate repo names inside one `repos` array; nothing reads `repos`) are nits
with no effect on any verdict; F6 (WARN noise for a roster that uses `repos` without `codeRepos`) is a documentation matter and the notes carry it into phase 4's
guidance. I re-probed F3-style keys and F4 on `306cc42`: unchanged from `743f148`, as deferred.
*Action: none now; phase 4 guidance carries F6.*

### R2-4 — Observation: `Roster[i].Form` records the FIRST copy's form when copies are merged — MINOR (awareness)

`f1b_second` yields roster entry `ẛ/False/string`: the person is denied, but `Form` says `string` because the first spelling was a string. `Form` is not read by
any caller (`verify-kit.ps1` reads `Name` and `CanApproveCritical` only) and D1 says the first spelling is kept, so this is by design. If a later phase wants
to say "written as an object", it must not read `Form` of a merged entry.
*Action: none.*

## Amendments in this diff

- [x] None. `spec.md`, `plan.md`, `tasks.md` and `contracts/` are untouched by `306cc42`; `notes.md` is a working document. The T001 deviation remains
  unamended and is waiting for the owner (R2-2).

## Constitution re-check (post-implementation)

**PASS.** I (no spec/plan/tasks change; no self-approved amendment), IV (the one reader, no new file), VI (names and positions only), VIII (a failing
fixture, hand-written, shown to fail on the old reader; but see R2-1 for F1), IX (this review is fresh-context; human review at merge), X (one phase,
user-run gate). II, III, V, VII not engaged.

## Test coverage observed

- `-Case VK-` on `306cc42`: 187 passed, 0 failed (parent 167, phase 1 185). `-Case CRIT-`: 79 passed, 0 failed (parent 75, phase 1 79). `-Case CLAIM-`: 67 passed, 0 failed (unchanged).
- Full harness, detached worktree of `306cc42`: **1235 passed, 0 failed, 0 skipped**.
- New assertions: the fixture `fail-name-is-array` (exit code and output); shown failing on `743f148` and passing now.
- Not covered by any fixture: the comparer-disagreement denial (F1, R2-1); `canApproveCritical` as a one-element array; `repos` as a bare string. My probe covers
  these and they behave as D2 says.

## Residual risk

Small. The code path both findings touched is correct on every record I constructed, and no string-only record changed. What remains is regression protection for
the exotic F1 case (R2-1) and a wording point in notes.md (R2-2). Phase 2 should add the F1 fixture alongside its first use of `CanApproveCritical`, and the
owner should acknowledge the T001 deviation when certifying the phase 1 gate.
