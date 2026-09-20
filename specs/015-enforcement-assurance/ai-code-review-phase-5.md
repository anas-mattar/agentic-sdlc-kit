# AI Code Review — 015 Enforcement Assurance, Phase 5

**Reviewer**: fresh-context agent — claude-opus-5[1m]
**Date**: 2026-09-20
**Branches**: agentic-sdlc-kit `015-enforcement-assurance` (tip `377e6f4`, parent `f08159b`)
**Scope reviewed**: the whole of `377e6f4` (40 files) — `scripts/enforcement-pack.ps1`,
`scripts/ritual-checks.ps1`, `tests/enforcement/cases/enforcement-pack/GAP27-001..004/{pass,fail}`,
`tests/enforcement/cases/ritual-checks/RIT-006/{pass,fail}`, the three edited existing cases
(`AMEND-003`, `AMEND-004`, `PACK-001`), `tests/enforcement/rules.json`,
`tests/enforcement/emission-idioms.json`, `tests/enforcement/lib/FixtureRepo.psm1`,
`specs/015-enforcement-assurance/{tasks,notes}.md`. Also read for comparison, not changed by the
phase: `scripts/scope-check.ps1`, `scripts/scope-check-repos.ps1`, `scripts/doc-lint.ps1`,
`.github/workflows/ritual-checks.yml`, `.github/workflows/project-gate.yml.template`.
**Feature contract**: plan D4–D7 (the six-word vocabulary; `UNGRADED` changes the verdict and
never the exit code), D10 (a pass/fail fixture pair differs only in the condition under test),
D11 (the GAP is closed test-first), D12 (real repositories, including broken ones); FR-009 to
FR-012; `**Gate Certification**: ci-held`; `**Gate Batching**: none`; phase-5 Territory =
`tests/**` plus the nine grading scripts.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5[1m]
- **Implementer**: Claude Opus 5 (1M context) — the main implementing session that authored
  `377e6f4` (named in the commit's `Co-Authored-By` trailer). Not this reviewer.
- **Inputs provided**: the phase-5 diff (`git show 377e6f4`), `CLAUDE.md`,
  `.specify/memory/constitution.md`, `docs/sdlc/definition-of-done.md`,
  `docs/sdlc/review-process.md`, `specs/015-enforcement-assurance/{spec,plan,tasks,notes}.md`,
  `specs/_templates/ai-code-review-template.md`, plus read-only execution of
  `scripts/scope-check.ps1`, `scripts/ritual-checks.ps1` (kit and all three adopted projects),
  and `tests/enforcement/Run-Tests.ps1` at HEAD and in a reverted scratch worktree.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — the core of the phase is right, and it is right in the way the feature
argues for: `UNGRADED` is emitted from exactly the four members of `enforcement-pack.ps1` that
reach a no-opinion state on a null base (I verified the enumeration is exhaustive, not merely
plausible), the aggregator lifts it with correct precedence, the exit code is provably unchanged
in every direction of every new and edited case, and the fixtures genuinely prove the change —
reverting the two production files makes all four `GAP27-*/fail` cases and `RIT-006/fail` fail,
which I ran. But the phase declared a Territory covering all nine grading scripts, wrote the
kit's canonical verdict vocabulary into `ritual-checks.ps1`, and then left two sibling members
inside that same Territory carrying the identical GAP-027 fail-open — `scope-check.ps1:288`
prints `WARN … nothing checked` and the wrapper summarises it as **`scope-check      OK`** on the
very depth-1 clone the phase's own fixtures build (reproduced live, F1). That is FR-010 violated
in the verdict block after the phase that exists to close it, and nothing in `notes.md` or
`tasks.md` records it as deferred. Compounding it, the new canonical definition asserts "these
six words and no others" and "FAIL … is the only state that exits 1", both of which are false in
this repository today (`doc-lint.ps1` exits 1 printing `ERROR:`, F2) — a definition destined to
flow down to three adopted projects in phase 6. Both remedies are cheap; neither is this
reviewer's to choose between (fix, or record the deferral with an owner-approved phase-6 task).
Residual risk sits entirely in F1 and F2; everything else is minor.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | **FR-009 partial**: the six words are defined once, `scripts/ritual-checks.ps1:35-58`; `PENDING` is emitted by nothing — `grep -rn "PENDING" scripts/` returns only lines 53 and 57 of that header (D7 satisfied). But "every grading script reports in these six words" is not true yet — F1, F2. **FR-010 partial**: `enforcement-pack` now reports `UNGRADED` in the log, the member verdict line and the RESULT line (`enforcement-pack.ps1:1255,1262`; `ritual-checks.ps1:147,164`); `scope-check` on the same repository state still reports `OK` — F1. **FR-011 held**: see the exit-code row. **FR-012 held**: member names unchanged — I ran `ritual-checks.ps1` against the kit and all three adopted projects; see T042 row. |
| Exit codes unchanged (FR-011, D6) | Directly measured, not reasoned. In a scratch worktree at `377e6f4` with `scripts/enforcement-pack.ps1` and `scripts/ritual-checks.ps1` reverted to `f08159b`, `Run-Tests.ps1 -Case GAP27` gave **36 passed / 6 failed**: the 6 failures are the four `GAP27-00{1,2,3,4}/fail` *"prints the expected output"* assertions plus two coverage assertions. **All eight `"exits with the expected code"` assertions passed on the reverted code**, i.e. every fixture's exit code is byte-identical before and after the phase. Same result for `RIT-006`: `"exits with the expected code"` passed reverted, `"prints the expected output"` failed. Reading the code confirms it: `enforcement-pack.ps1:1261-1268` exits 0 on the ungraded path exactly as the `OK` path below it does; `ritual-checks.ps1:160-166` likewise. |
| The four emission sites are the right four, and complete | `Invoke-MicroLaneCheck` (`:565`), `Invoke-ReviewProvenanceCheck` (`:607`), `Invoke-PhaseSizeWarningCheck` (`:658`), and the Lite-lane dispatch for `Invoke-LiteAndAbuseCheck` (`:1245`). Exhaustiveness checked two ways: `grep -n "ChangedFiles\|\$changedFiles" scripts/enforcement-pack.ps1` shows `$changedFiles` (empty on a null base, `:161`) reaches **only** `Invoke-LiteAndAbuseCheck`; and only four dispatched checks take `-Base` besides `Invoke-AmendmentAuthorityCheck`, which FAILs (`:1058,:1062`) rather than declining. `Invoke-StructureCheck`, `Invoke-CriticalEvidenceCheck`, `Invoke-GateBatchingCheck`, `Invoke-GateCertificationCheck` read the worktree, not the diff. The base guards in `MicroLane` (`:565`) and `PhaseSizeWarning` (`:658`) sit **after** their applicability gates, so a non-Micro or non-`NNN-*` branch does not get a false `UNGRADED` — confirmed by `GAP27-004/fail/expected.txt`, which shows no `MicroLane` line on a Standard feature. |
| The UNGRADED scan cannot misfire (`ritual-checks.ps1:131`) | The pattern is `^${name}: UNGRADED` against captured lines, guarded by `if ($results[$name] -eq 0)` (`:124`). A FAIL run is never scanned, so `enforcement-pack` exiting 1 shows `FAIL` — confirmed live on a scratch depth-1 clone where the verdict block printed `enforcement-pack FAIL`. The detail lines the script prints are `UNGRADED: <reason>` (`:1255`), which do not start with `enforcement-pack: `, so only the run-verdict line (`:1262`) matches. `$name` values are `digests`, `roadmap-claims`, `scope-repos`, `enforcement-pack` — no regex metacharacters, so interpolation is safe today (F7). Precedence `UNGRADED > n/a > OK` is at `:147-149`; `enforcement-pack` emits no `n/a` line, so the two cannot presently collide, and if they did the ordering is correct. |
| `$captureMembers` union does not change member behaviour | `@($naCapableMembers + $ungradedCapableMembers \| Select-Object -Unique)` — `+` binds tighter than the pipeline, so this is `(a+b) \| Select-Object -Unique` = `digests, roadmap-claims, scope-repos, enforcement-pack`. The one real risk of moving `enforcement-pack` onto the capture path is `2>&1` under `$ErrorActionPreference = 'Stop'` (`:74`) turning child stderr into a terminating error. I tested it: a child `pwsh` writing to stderr and exiting 0 yields `captured=2 code=0`, one `ErrorRecord` + one `String`, **no throw** (`$PSNativeCommandUseErrorActionPreference = $false` at `:77` is what keeps it safe). Separately, `grep -n "git " scripts/enforcement-pack.ps1 \| grep -v "2>\$null"` shows the remaining bare `git` calls all use `*> $null`. Exit-code contract intact. |
| D10 — every new pair differs only in the condition under test | Diffed all five pairs myself. `GAP27-001`: `+  "shallow": 1` only. `GAP27-003`: `+  "truncateCommit": "HEAD~1"` only. `GAP27-004`: `+  "shallow": 1` only. `GAP27-002`: two lines — `defaultBranch: main→trunk` and the first commit's `branch: main→trunk`; that is one condition written twice because the recipe format names the trunk in both places, and the pass recipe's `description` says exactly that ("written in two places because the commit that creates it names it too (plan D10)"). Acceptable, and honestly stated. `RIT-006`: one stub line, `enforcement-pack: OK - stub` → `enforcement-pack: UNGRADED (1 check(s) formed no opinion)`. Every `description` I compared against its own diff is accurate — the failure mode round 2 found (F3 of the phase-4 review) is not repeated here. |
| The fixtures prove something (D11, SC-003) | Mutation-tested, not assumed. Scratch worktree at `377e6f4`, both production files reverted to `f08159b`, no other change: `Run-Tests.ps1 -Case GAP27` → exit 1, `[-] prints the expected output` on all four fail directions, plus `[-] every inventoried rule still exists in the script it names` and `[-] every anchor names exactly the emission sites its rule declares`. `-Case RIT-006` → exit 1 on the fail direction. At HEAD both run green (42 and 30 assertions). None of the five new cases is vacuous. |
| Coverage model (T043) | `Run-Tests.ps1 -Case GAP27` prints `coverage: 186 of 199 … enforcement-pack.ps1 48 of 54 … ritual-checks.ps1 6 of 6`, matching notes.md exactly. The new accumulator regex `\$(script:)?ungraded\s*\+=` matches the four `+=` sites and nothing else — `$ungraded = @()` has no `+=`, and `$ungradedCount++` / `$ungradedReasons` live in the other script's entry and would not match `\s*\+=` anyway. `ritual-checks.ps1` went 5→6 with **no pattern change**: the existing anchor `Write-Host\s+\(?['"](=== )?ritual-checks: ` picks up the new `RESULT UNGRADED` line automatically. The idioms note for that script was not updated and still says "is five" — F3. |
| Feature contract held (no unapproved package/architecture) | No new dependency, no new manifest class, no new script. `git show --stat 377e6f4`: 40 files, 791+/16−, all under `scripts/` (2), `tests/enforcement/` (36) and `specs/015-enforcement-assurance/` (2). |
| Constitution / domain invariants | Constitution **I** (Amendment authority): the only approved-document change in this commit is `tasks.md`, and `git show 377e6f4 -- specs/015-enforcement-assurance/tasks.md` shows **seven `- [ ]` → `- [x]` flips and no other character**. Ticking a checkbox is progress, not amendment; no `**Amendment approved by**` line is owed and none is claimed. `spec.md`, `plan.md` and `contracts/` untouched. Constitution **X**: one phase, `phase 5` in the commit subject, independently revertible (proved — I reverted the two files cleanly in a worktree). **V**, **VI**, **VII** N/A as at plan time. |
| Security (authn/authz, secrets, sensitive logging) | No secrets, no network, no credentials, no new file writes. The one new destructive primitive is `truncateCommit` in `FixtureRepo.psm1:275-291`, which truncates a loose object **inside a fixture repository created under `[IO.Path]::GetTempPath()`**, resolved via `rev-parse` against that fixture root, and **throws rather than silently skipping** if the object is packed. It cannot reach the repository under review. Considered and dismissed: injecting a fake verdict line through `-Branch` (the UNGRADED messages interpolate `$Branch`) — git refuses newlines in ref names and the caller already controls the invocation. |
| Scope guard | `pwsh -File scripts/scope-check.ps1` → `scope-check: PASS phase 5 commit 377e6f4 (40 file(s))`, exit 0. `git show --stat 377e6f4` read for intent: every path is `tests/**`, `scripts/enforcement-pack.ps1`, `scripts/ritual-checks.ps1` or `specs/015-enforcement-assurance/**` — inside the phase-5 Territory declared at `tasks.md:230-240`, which was approved before this commit and is unchanged by it. Full `pwsh -File scripts/ritual-checks.ps1` on the kit → all members OK/n/a, `RESULT OK`, exit 0. |
| T042 / SC-005 independently reproduced | I re-ran the claim rather than reading it. `scripts/ritual-checks.ps1 -Root D:/solutions/<project>` for all three: **expense-tracker** — 6 OK + `roadmap-claims n/a (no origin remote — no claim ledger to check against)` + `verify-kit OK`, `RESULT OK`, exit 0; **fitforge** — every member OK, `RESULT OK`, exit 0; **flowboard** — every member OK, `RESULT OK`, exit 0. Member names, verdicts and exit codes match notes.md's table line for line, including expense-tracker's surviving `n/a`. |
| Flow-down risk (a green run newly printing `RESULT UNGRADED`) | No machine consumer breaks. `grep -rn "RESULT OK"` over the repo returns **only** `ritual-checks.ps1` itself and historical `specs/**` prose — nothing in `.github/workflows/`, `adoption/`, `docs/sdlc/gate-command.md` or `project-gate.yml.template` greps the output. `.github/workflows/ritual-checks.yml:44` keys on the exit code (`run: ./scripts/ritual-checks.ps1 …`) and branch protection keys on the check *name* (`docs/sdlc/branch-protection.md`), both unchanged. The kit's shipped workflow already sets `fetch-depth: 0` (`adoption/updating.md:433`), so a conforming adopter does not reach the ungraded state at all. The human-facing flow-down note is FR-021/FR-022 and is correctly deferred to phase 6 (T049, T050). |
| Rollback safety | Clean. Reverting `scripts/enforcement-pack.ps1` and `scripts/ritual-checks.ps1` to `f08159b` in a worktree produced a working tree that runs; the only consequence is the six harness failures listed above, which is the correct signal. No schema, no migration, no state. |
| Visual-reference match | **N/A — no visual references exist.** The phase touches two PowerShell scripts and JSON/text fixtures; `specs/015-enforcement-assurance/` has no `screenshots/` directory and the plan declares none. The Visual Compliance Loop does not apply. |
| Test coverage observed | See "Test coverage observed" below. |

## Findings

### F1 — Two members inside phase 5's own Territory still print `OK` on a run that graded nothing — FR-010 is violated in the verdict block after the phase that exists to close it — BLOCKING

`Invoke-ReviewProvenanceCheck`'s bare `return` was not the only instance of GAP-027 among the
kit's grading scripts, and the phase's Territory (`tasks.md:230-240`) explicitly claims all nine.
A sweep for the same shape —
`grep -rn "not \$[Bb]ase\|nothing was graded\|nothing checked" scripts/*.ps1` — finds three
surviving sites outside `enforcement-pack.ps1`, all in Territory files:

- `scripts/scope-check.ps1:287-290` — `if (-not $base) { Write-Host 'scope-check: WARN could not
  resolve a merge base with main — nothing checked'; exit 0 }`. This is on the `-All` path, which
  is exactly how `ritual-checks.ps1:87` invokes it.
- `scripts/scope-check-repos.ps1:378-379` — `WARN … NOTHING WAS GRADED in this repository`.
- `scripts/scope-check-repos.ps1:404` — `n/a (nothing was graded in the declared code
  repositories for '$Branch' …)`, deliberately shaped as `n/a` so the wrapper lifts it
  (see the comment at `:402`).

Reproduced live, not inferred. I built a two-commit repository with a `001-thing` branch, made a
`--depth 1` clone of it, copied `scripts/` in, and ran the wrapper:

```text
=== ritual-checks: scope-check ===
scope-check: WARN could not resolve a merge base with main — nothing checked
…
ritual-checks: scope-check      OK
```

`scope-check` compared nothing, said so in its own body, and the verdict block printed the word a
fully graded pass prints. That is FR-010 verbatim — "A member that cannot grade MUST NOT report
the state that a fully graded pass reports, in the verdict block" — unmet, on the same depth-1
clone that `GAP27-001` and `GAP27-004` build. The mechanism is `ritual-checks.ps1:120`:
`scope-check` is not in `$captureMembers`, so its exit 0 becomes `'OK'` at `:149` with nothing
read from its output.

Two further consequences are worse than cosmetic:

1. `scope-check-repos.ps1:404` reports *"nothing was graded"* as **`n/a`**, which the wrapper
   lifts verbatim into the verdict. The vocabulary this same commit wrote says `N/A` means "the
   check DOES NOT APPLY" and `UNGRADED` means "it does apply and formed no opinion"
   (`ritual-checks.ps1:45-52`), and spec US3 acceptance scenario 3 says in terms that "the two
   are different claims and the vocabulary must not blur them". Here they are blurred, by a line
   whose own text says which one it is.
2. `scope-check.ps1:288` reports it as **`WARN`**, which the same header defines as "The check
   ran, formed an opinion … It observed something real" — the one thing that line is not.

What makes this blocking rather than a follow-up is not the size of the fix but the record. The
phase's commit message says "Four members reach that state, not one", and `notes.md` closes with
"no case outside `enforcement-pack` moved. The other eight scripts emit no `UNGRADED` … which is
the narrowest form of the FR-012 claim" — framed as additive restraint, never as a gap. No task
in phase 6 (T044–T053) converts these scripts, so on the current plan the feature ends with
FR-009 and FR-010 unmet and nothing in the ledger saying so. A check that stops grading and is
summarised as green, unrecorded, is the exact defect species this feature was chartered to
eliminate.

*Action: implementer — either (a) emit `UNGRADED` from `scope-check.ps1:288` and
`scope-check-repos.ps1:379/404` and add `scope-check` and `scope-repos` to
`$ungradedCapableMembers`, with fixture pairs, inside this phase; or (b) record the deferral
explicitly — a `notes.md` entry naming these three sites, plus a phase-6 task, plus owner
approval that FR-009/FR-010 are satisfied for `enforcement-pack` only in this phase. Option (b)
is legitimate; silence is not.*

### F2 — The canonical vocabulary asserts two things that are false in this repository — BLOCKING

`scripts/ritual-checks.ps1:35-36` states: *"Every grading script in this kit reports in these six
words and no others."* `:42` states: *"**FAIL** The check ran and found a violation. This is the
only state that exits 1."* Both are checkable, and both fail:

- `scripts/doc-lint.ps1:228, 233, 247` print `ERROR: …` and `:251` exits 1 — a seventh word, and
  a state other than `FAIL` that exits 1, in the wrapper's **first** member. `doc-lint.ps1:242`
  also emits `INFO:`. `scripts/verify-kit.ps1:99` (`verify-kit: ERROR root not found`) exits 1
  too; `scripts/scope-check.ps1:95, 264`, `scripts/scope-check-repos.ps1:175, 199` and
  `scripts/update-kit.ps1:57` all emit `ERROR` as well.
- `scripts/scope-check.ps1:272, 276, 280` and `scripts/scope-check-repos.ps1:182, 192, 324, 328,
  332` spell the N/A state as `not applicable (…)`, and because `scope-check` is not a capture
  member the wrapper renders those runs as `OK` — so `N/A` is neither spelled nor surfaced
  consistently either.

The spec anticipated this: US3's rationale says "today each script invents its own idiom — `FAIL`,
`ERROR`, `WARN`, `n/a`, a bare return", and FR-009 makes unifying them a requirement. Declaring
the vocabulary is T038's job and it is done well; asserting that the code already conforms is a
separate claim, it is untrue, and it is the claim phase 6 will carry outward to
`adoption/updating.md` and `docs/sdlc/review-process.md` for three adopted projects to read. A
false statement in the kit's own canonical definition is the kind of thing this feature exists to
make impossible.

*Action: implementer — reword `ritual-checks.ps1:35-36` and `:42` to state the target vocabulary
and name the known divergences (`ERROR`/`INFO` in `doc-lint.ps1`, `ERROR` in four others, spelled-out
`not applicable`), or reconcile them. If reconciliation is phase 6's or a later feature's work,
say so in the header and add the task.*

### F3 — `emission-idioms.json`'s `ritual-checks.ps1` note still says the site count "is five"; this commit made it six — MINOR

`tests/enforcement/emission-idioms.json:109` reads: *"The answer to the question this entry used
to ask … is five: the member announcement, the per-member verdict, the doctor's n/a line, and the
two run verdicts."* There are now **three** run verdicts, and the harness agrees —
`Run-Tests.ps1 -Case GAP27` prints `coverage: ritual-checks.ps1  6 of 6 site(s) inventoried`. The
count moved without a pattern change because the existing anchor matched the new line
automatically, which is a good property of the anchor and the reason the note was easy to miss.
The `enforcement-pack.ps1` note two entries above was updated carefully and at length in the same
commit; this one was not. `rules.json` is correct (`RIT-006` covers the new site), so coverage is
not wrong — only the prose.

*Action: implementer — update the enumeration at `emission-idioms.json:109` to six and name the
`RESULT UNGRADED` verdict.*

### F4 — SC-004's "CI badge" half is unreachable under D6, and the phase does not say so — CONFIRM

SC-004 requires "a verdict that no reader — **human or CI badge** — can mistake for a graded
pass". D6 and FR-011 require the exit code to stay 0, and `ritual-checks.ps1:165` duly exits 0 on
the ungraded path. `.github/workflows/ritual-checks.yml:44` derives the check conclusion from that
exit code, so a run that graded nothing still renders as a **green required status check** — a CI
badge that a reader will, correctly by its own lights, take for a pass. The log and the verdict
block are now honest; the badge is not, and cannot be while D6 holds.

This is a tension inside the approved documents, not a defect in the code: the implementation
follows D6, which is the rung that prevails. But `docs/sdlc/definition-of-done.md` conflict rule
and constitution II both say to stop and report rather than silently choose, and this phase chose
silently — `notes.md` discusses D6 at length and never mentions that SC-004's second clause is
left unsatisfiable by it.

*Action: owner — decide whether SC-004's badge clause is amended to match D6, or whether a later
feature (the "should UNGRADED ever block" question D6 defers) owes it. Record the decision;
nothing in the code changes either way.*

### F5 — The four new messages and the new header use ASCII hyphens where every neighbouring message uses em dashes, with no reason recorded — MINOR

Every pre-existing message in `enforcement-pack.ps1` and `ritual-checks.ps1` uses `—`; all four
new `UNGRADED` strings (`:566, :608, :659, :1246`) and the whole vocabulary block
(`ritual-checks.ps1:35-58`) use `-`. Given phase 4's console-codepage defect (notes.md, T036a/b),
I assume this is a deliberate dodge, and I observed the underlying problem still exists — in my
kit run, `ritual-checks.ps1:154`'s own em dash rendered as `-` on this Windows console while a
captured member's em dash came through intact. But an unexplained typographic split invites the
next contributor to "fix" the inconsistency and reintroduce whatever was being avoided. If the
reason is real it deserves one line; if it is accidental, the strings should match their
neighbours.

*Action: implementer — add a one-line note (in `notes.md` or beside the strings) stating whether
the ASCII hyphens are deliberate, or normalise them.*

### F6 — `AmendmentAuthority: graded 0 of N commit(s)` is the same no-opinion shape with a base present, and phase 5 neither named it nor said why not — MINOR

`enforcement-pack.ps1:1201` prints `AmendmentAuthority: graded $gradedCount of
$($commits.Count) commit(s) in $range$why`. When every commit in the range is skipped (all
pre-boundary, all merges, all roots), `gradedCount` is 0, the check formed an opinion about
nothing, and the run prints `OK`. The inventory already flagged exactly this —
`emission-idioms.json`'s `enforcement-pack` note calls it *"a range with no commits in it —
'nothing to grade' being GAP-027's own shape, in the check that grades amendments"* — and phase 5,
the GAP-027 phase, passed over it in silence. The deliberate exclusion of `AmendmentAuthority`
that *is* argued (it FAILs for want of a **base**, and downgrading that would be a regression) is
a different question and is argued correctly; this is the base-present arm.

I am not asserting it should emit `UNGRADED` — "all commits legitimately predate the check" is
arguably a true `N/A`, and distinguishing the arms needs care. I am asserting that the phase whose
subject is this exact shape should have reached a recorded conclusion about the one instance its
own inventory had already written down.

*Action: implementer — one line in `notes.md` stating the disposition of the `graded 0 of N` arm
(UNGRADED, N/A, or deferred with a gap id).*

### F7 — `$name` is interpolated unescaped into the verdict regex — MINOR

`ritual-checks.ps1:126` and `:131` build `"^${name}: n/a"` / `"^${name}: UNGRADED"`. All four
capture-member names (`digests`, `roadmap-claims`, `scope-repos`, `enforcement-pack`) contain no
regex metacharacters, so this is correct today, and the `n/a` half is a pre-existing idiom this
phase copied rather than introduced. It is latent, not live: a future member name containing `.`,
`+` or `(` would match loosely or throw.

*Action: implementer — optional, `[regex]::Escape($name)`. Not required for this phase.*

### F8 — `LiteAndAbuse` reported as `UNGRADED` is faithful to FR-010, not a stretch — ACCEPTED

Worth stating positively because it is the one judgement call in the four sites and the one most
likely to be second-guessed. `Invoke-LiteAndAbuseCheck` does not decline; it grades
`$ChangedFiles`, which `Get-ChangedFiles` returns as `@()` on a null base
(`enforcement-pack.ps1:161`), and both its guards — the prohibited-category loop (`:240`) and the
file-count cap (`:249`) — are vacuously satisfied by an empty list. FR-010's subject is "a member
that cannot grade", and a member handed an empty input for a reason unrelated to the branch's
contents cannot grade, whatever the shape of its control flow. Reporting the vacuous pass as `OK`
would be precisely the fail-open: the pack's own comment at `:1215` already recorded that "on a
baseless clone a `fix/` branch touching anything at all therefore went green", and `GAP27-002`'s
pass direction demonstrates the `package.json` violation that the fail direction lets through.
The one structural nit is that the line is emitted from the dispatcher (`:1245`) rather than the
function, which `rules.json` declares honestly as `"function": "(Lite lane dispatch)"`.

*Action: none.*

### F9 — `PACK-001`'s recipe description now predicts, in the future tense, something this commit made true — DOC DRIFT

`tests/enforcement/cases/enforcement-pack/PACK-001/fail/recipe.json` still reads "phase 5 gives it
a verdict state, and this case is what will show the difference", while its `expected.txt` in the
same commit was changed to the post-phase-5 output. `notes.md` defends the choice explicitly ("a
prediction that landed is worth more on the record than a tidy sentence"), and I have some
sympathy — but a fixture description is read by whoever is debugging that fixture, on a branch
where they cannot tell from the sentence whether phase 5 has landed. The record value is already
captured permanently in `notes.md`, which quotes the original.

*Action: implementer — optional; add four words ("— it now does") or leave it and accept the
drift as documented.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None.** `git show 377e6f4 -- specs/015-enforcement-assurance/tasks.md` changes exactly seven
characters: `- [ ]` → `- [x]` on T037–T043. No task text, no Territory entry, no Purpose line, no
dependency was altered. `spec.md`, `plan.md` and `contracts/` are not in the commit at all.
`notes.md` gained 159 lines, but it is an evidence log, not one of the approved documents
constitution I governs. Accordingly no `**Amendment approved by**: <name>, <YYYY-MM-DD>` line is
owed by this commit and none is claimed — correct. (For contrast, the phase-4 amendment `74f690e`
carried one, and that is the shape this commit would have needed had it touched task text.)

## Constitution re-check (post-implementation)

**PASS, with the F1/F2 caveats recorded above** (both are requirement- and documentation-level,
not constitutional).

- **I Specification First** — satisfied. Spec and plan approved 2026-09-19 and untouched; the only
  document change is checkbox progress. Amendment authority not engaged.
- **II Source of Truth** — engaged and correctly resolved for D4/D6/D7 (the plan prevails over the
  `review/` proposal, and the header cites the plan decisions by number). Engaged and **not**
  resolved for SC-004 vs D6 — see F4.
- **III Repository Separation** — N/A, single governance repository, no `codeRepos`.
- **IV Architecture Consistency** — satisfied. No new dependency, no new manifest class, no new
  script; `truncateCommit` extends an existing recipe capability the plan's D12 named in advance.
- **V Domain Invariants** — N/A, no domain-invariants pack.
- **VI Security** — satisfied; see the security row. The new destructive fixture primitive is
  confined to temp directories and fails loudly rather than silently.
- **VII External Integration Governance** — N/A.
- **VIII Testing Requirements** — satisfied, and unusually well: the phase is test-first per D11
  (the before-runs are recorded in `notes.md`) and I independently mutation-tested the result.
- **IX Human Review** — this review is gate 5; gate 6 is owed once, at merge.
- **X Controlled Delivery** — satisfied. One phase, `phase 5` in the subject, `scope-check` PASS,
  independently revertible (verified by reverting it). `**Gate Certification**: ci-held` means the
  owner's approval on the CI evidence triplet is still outstanding and this review does not
  substitute for it.

## Test coverage observed

The phase's tests are its product, so this section is unusually load-bearing.

- **Five new fixture pairs, ten cases.** `GAP27-001` (depth-1 clone, `docs/` lane —
  `Invoke-ReviewProvenanceCheck`), `GAP27-002` (trunk named `trunk`, `fix/` lane — the Lite-lane
  vacuous grade), `GAP27-003` (truncated parent commit, `NNN-*` lane — `Invoke-MicroLaneCheck`),
  `GAP27-004` (depth-1 clone, `NNN-*` lane — `Invoke-PhaseSizeWarningCheck`), `RIT-006`
  (stub-member aggregation — the `RESULT UNGRADED` line). Three distinct causes of an absent
  base, which is what makes the set more than one test written four times.
- **The critical assertion is not "quiet".** Each `GAP27-*` pair carries the **same** deliberately
  bad `ai-code-review.md` on both sides — no provenance section, no attestation,
  `**Reviewer**: the implementer, same context` (PROV-002, PROV-004, PROV-005 at once). The pass
  direction therefore *reports the violation the fail direction let through*, rather than merely
  being silent. This is the D10 property done properly and it is the strongest thing about the
  phase.
- **Both directions assert the exit code**, and the exit codes are identical across the phase
  boundary — measured, see the evidence table. `GAP27-003` and `GAP27-004` are the interesting
  ones: the run both FAILs (AmendmentAuthority) and reports `UNGRADED` lines, which is why the
  runner prints the ungraded list independently of the verdict word.
- **Three existing cases were correctly re-baselined.** `AMEND-003` and `AMEND-004` keep their
  FAIL and exit code and gain two `UNGRADED:` lines; `PACK-001` flips `OK` → `UNGRADED` with exit
  0 unchanged — which is GAP-027's own demonstration case, written in phase 3, now showing the
  difference it predicted.
- **Suite state.** At HEAD: `-Case GAP27` → 42 passed / 0 failed; `-Case RIT-006` → 30 passed / 0
  failed; coverage 186 of 199 across nine scripts (`enforcement-pack` 48/54, `ritual-checks` 6/6),
  matching notes.md. `ritual-checks` on the kit and all three adopted projects: `RESULT OK`,
  exit 0. I did not re-run the full 774-case suite; the implementer records it green on Windows
  and the ubuntu leg is CI's to certify.
- **Gaps in coverage, by construction.** No case covers the three sites named in F1 (none exists
  to cover). Coverage remains reporting-only until T044, per D9, so a short inventory still does
  not fail the run — correct for this phase, and the reason F1's gap could not have been caught
  by the harness itself.

## Residual risk

Concentrated in **F1**, and it is the same risk the feature was chartered against: after the
phase that gave the kit a word for "this check formed no opinion", `ritual-checks` still prints
`scope-check OK` for a member that compared nothing, and `scope-repos n/a` for a member that says
in its own line that nothing was graded. The behaviour is no worse than before the phase — nothing
regressed — but the *record* is worse, because the vocabulary now exists and the reader will
reasonably assume it is applied. **F2** carries the same risk forward into the documents phase 6
ships to three adopted projects; fixing it costs two sentences and is cheapest now, before T049
and T050 quote it.

Everything else is minor and none of it blocks: F3 and F5 are prose, F7 is latent, F6 and F9 are
records that should exist, F4 is an owner decision that changes no code.

Before merge: F1 resolved (fixed, or deferred on the record with owner approval) and F2 reworded.
After that, the phase deserves to stand — the exit-code contract is held and proved, the emission
sites are exhaustive for the condition they name, the fixtures fail when the code is reverted, and
the three adopted projects are unaffected. Gate 3 remains outstanding under `ci-held`: the owner's
recorded approval on the CI evidence triplet for `377e6f4`, which this review does not and cannot
supply.
