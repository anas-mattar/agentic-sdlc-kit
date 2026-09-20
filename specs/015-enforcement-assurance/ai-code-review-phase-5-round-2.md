# AI Code Review — 015 Enforcement Assurance, Phase 5 (round 2)

**Reviewer**: fresh-context agent — claude-opus-5[1m]
**Date**: 2026-09-20
**Branches**: agentic-sdlc-kit `015-enforcement-assurance` (tip `24e7100`, parent `377e6f4`)
**Scope reviewed**: the whole of `24e7100` (52 files) — `scripts/doc-lint.ps1`,
`scripts/ritual-checks.ps1`, `scripts/scope-check.ps1`, `scripts/scope-check-repos.ps1`,
`tests/enforcement/cases/scope-check/SCOPE-027/{pass,fail}`,
`tests/enforcement/cases/ritual-checks/RIT-007/{pass,fail}`, the twenty edited `expected.txt`
files, `tests/enforcement/rules.json`, `tests/enforcement/emission-idioms.json`,
`specs/015-enforcement-assurance/{notes.md,ai-code-review-phase-5.md}`. Also read, not changed
by this commit: the other five grading scripts (`verify-kit.ps1`, `build-digests.ps1`,
`roadmap-claim-check.ps1`, `territory-check.ps1`, `enforcement-pack.ps1`),
`tests/enforcement/Coverage.Tests.ps1`, `kit-manifest.json`,
`.github/workflows/ritual-checks.yml`, `.github/workflows/code-repo-scope-check.yml.template`,
`specs/006-verification-pack/contracts/scope-check-cli.md`,
`specs/012-cross-repo-scope-check/contracts/scope-check-repos-cli.md`,
`docs/sdlc/{definition-of-done,review-process}.md`.
**Feature contract**: plan D4–D7 (the six-word vocabulary; the pass word stays `OK`; `UNGRADED`
changes the verdict and never the exit code), D9 (coverage reporting-only until phase 6), D10 (a
pass/fail pair differs only in the condition under test), D11 (test-first), D12 (real
repositories); FR-009 to FR-012; US3 acceptance scenarios 1–3; `**Gate Certification**: ci-held`;
phase-5 Territory = `tests/**` plus the nine grading scripts (`tasks.md:230-240`).

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5[1m]
- **Implementer**: Claude Opus 5 (1M context) — the main implementing session that authored
  `24e7100` (named in the commit's `Co-Authored-By` trailer). Not this reviewer.
- **Inputs provided**: the round-1 review (`ai-code-review-phase-5.md`), the remediation diff
  (`git show 24e7100`, `git diff 377e6f4 24e7100`), `CLAUDE.md`,
  `.specify/memory/constitution.md`, `docs/sdlc/definition-of-done.md`,
  `docs/sdlc/review-process.md`, `specs/015-enforcement-assurance/{spec,plan,tasks,notes}.md`,
  `specs/_templates/ai-code-review-template.md`, plus read-only execution of
  `scripts/scope-check.ps1`, `scripts/ritual-checks.ps1` (kit, a synthetic depth-1 clone, and a
  scratch clone of `flowboard`) and `tests/enforcement/Run-Tests.ps1` at HEAD and under two
  mutations in a scratch worktree.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — **round 1's F1 is closed and closed well; round 1's F2 is not.** The F1 work
is the strongest thing in this commit: ten sites converted across the two scope scripts, the
general all-skips case found by the implementer's own sweep rather than by the review, a
`$script:gradedCommits` counter whose every return path I traced and found correct, and the
end-to-end reproduction that failed in round 1 now printing
`ritual-checks: scope-check UNGRADED could not resolve a merge base with main` on the same
depth-1 clone (reproduced live). Both new rules are mutation-proved — I reverted the production
hunks and watched `SCOPE-027/fail` and `RIT-007/fail` fail, and independently confirmed the
narrower mutation the implementer claims (drop `'scope-check'` from `$ungradedCapableMembers` →
`RIT-007/fail` fails, `RIT-006` still passes). The suite is green at 782/0 and coverage 187 of
200, both matching `notes.md` to the digit. F2, however, was answered by rewriting the canonical
vocabulary block, and the rewrite asserts two new things that are false in this repository today:
*"Every grading script in this kit ends its run on a VERDICT LINE … and the word is one of these
six"* (`territory-check.ps1` never does and exits 2; `verify-kit.ps1:114` says `not applicable`)
and *"Only the last line of a member's output is its verdict"* (on an ordinary graded run
`scope-check`'s last line is `scope-check: PASS phase 5 commit 24e7100 (52 file(s))`, and
`enforcement-pack`'s last line on a FAIL is an indented issue bullet — both captured live). The
second sentence is not decoration: it is the rule the new KNOWN DIVERGENCES block relies on to
license leaving forty detail lines alone, and it is false for the two members the commit is
about. That is round 1's F2 again, in the same block, in a file `kit-manifest.json` classes
`verbatim` and phase 6 will quote outward to three adopted projects. Three further items need an
owner decision rather than my judgement (F3–F5), and the residual risk sits in F2.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | **FR-010 now held for the two scope checks** — reproduced end-to-end, not inferred: built a two-commit repo, `git clone --depth 1 --branch 001-thing`, copied `scripts/` in, ran the wrapper → `ritual-checks: scope-check      UNGRADED could not resolve a merge base with main — nothing checked` (round 1 got `scope-check      OK` on the same construction). **FR-009 still partial** — the shared vocabulary is not spoken by `territory-check.ps1` (`CLEAN —`/`OVERLAP with`/`no remote —`, exit 2 at `:121`) or by `verify-kit.ps1:114` (`not applicable`), and the header now asserts otherwise (F2). **US3-AS3 (n/a vs UNGRADED must not blur)** — honoured in the `scope-repos` conversion, violated in `roadmap-claim-check.ps1:57` (F4) and arguably inverted by the new run-level line over `not applicable` commits (F5). **FR-011/D6 held** — no `command.json` `exitCode` value is touched anywhere in the diff (`git show --stat 24e7100` lists no existing `command.json`), and under both mutations every `"exits with the expected code"` assertion still passed while only `"prints the expected output"` failed. **FR-012 held** — member names unchanged; `ritual-checks` on the kit gives the same seven names, `RESULT OK`, exit 0. |
| The F1 sweep, re-run independently across all nine scripts | `grep -n "not \$[Bb]ase\|nothing was graded\|nothing checked\|no commits since\|exit 0\|not applicable\|WARN\|n/a" scripts/*.ps1`, then read around every hit. **No site remains that runs, grades nothing, exits 0 and is summarised `OK`.** `build-digests.ps1:178,226` (`n/a (no digest manifest)`, `n/a (no digest markers)`) are honest N/A and lifted by the wrapper. `verify-kit.ps1` reads the worktree, has no diff base and no no-opinion arm. `territory-check.ps1` is not a wrapper member. `enforcement-pack.ps1` was done in `377e6f4`. **One residual instance of the *blur*, not of the fail-open**: `roadmap-claim-check.ps1:57` reports an unreadable ledger as `n/a` — F4. |
| `$script:gradedCommits` — every return path of `Invoke-ScopeCheck` traced | Correct. Increments at exactly the two `strays.Count -eq 0` PASS sites (`:182-183` Micro, `:251-252` Standard) — the only two paths that compare a commit's files against a territory. Every other `return $true` graded nothing: merge commit (`:103`), no `phase N` token (`:142`), `tasks.md` absent at commit and parent (`:207`), no territory declared (`:242`). Every `return $false` path reaches `if (-not $ok) { exit 1 }` at `:311` **before** the new branch at `:312`, so a FAILing run can never print `UNGRADED` — the comment at `:286-291` is accurate. Initialisation order is safe: `$script:gradedCommits = 0` at `:292` precedes both the `-All` loop (`:306`) and the `-Commit` call (`:308`); no `Set-StrictMode` is set in any `scripts/*.ps1` (`grep -rn "StrictMode" scripts/` → no hits), and the variable would be safe under one anyway. The `-Commit` path is covered too — `SCOPE-014/015/017/018` all invoke without `-All` and now carry the run-level line. |
| `not applicable` → `n/a` is non-breaking for machine consumers | `grep -rn "RESULT OK\|scope-check:\|not applicable" .github/ adoption/ docs/` returns only prose and one workflow comment; `.github/workflows/ritual-checks.yml:44` is `run: ./scripts/ritual-checks.ps1 -Branch $env:RITUAL_BRANCH` — exit code only, no parsing. Branch protection keys on the check *name*. **Flow-down reproduced independently**, not read: `git clone --no-hardlinks /d/solutions/flowboard` into scratch, baseline run → all seven `OK`, `RESULT OK`, exit 0; then `cp /d/solutions/agentic-sdlc-kit/scripts/*.ps1 scripts/` and re-run → `scope-check n/a ('main' is the trunk)`, `scope-repos n/a ('main' is the trunk)`, five members unchanged, `RESULT OK`, exit 0. `notes.md`'s measured claim is accurate. `D:\solutions\flowboard` itself was not touched. |
| The verdict-line/detail-line distinction the header draws | **Not the distinction the code makes** — F2. Captured live: `scope-check: PASS phase 5 commit 24e7100 (52 file(s))` is the *last* line of an ordinary graded run (no run-level line is printed when `gradedCommits > 0`), and `SCOPE-027/pass/expected.txt` in this very commit ends on that same shape. `enforcement-pack.ps1:1260-1262` prints its `FAIL` verdict and *then* the issue bullets — observed on a scratch run: `enforcement-pack: FAIL (2 issue(s)):` followed by two `  - Structure: …` lines. |
| F2's new claims, sentence by sentence | `PENDING` reserved — **true**, `grep -rn "PENDING" scripts/` outside `ritual-checks.ps1` → no hits. `update-kit.ps1` outside Territory — **true**, `tasks.md:230-240` lists nine scripts and not it, and the spec's Assumptions excludes it from the nine. `doc-lint` now prints a verdict before every `exit 1` — **true and complete**: `grep -n "exit 1" scripts/doc-lint.ps1` returns exactly one hit (`:258`), immediately after the new line, and the `$FailOnSlots` arm is inside the same condition. `$errCount` arithmetic — correct, no double count: `DOC-005/fail` = 1 `missingKit` + 1 `manifestErrors` → `2 issue(s)`, matching its `expected.txt`. `verify-kit.ps1:99`/`:312` — both `ERROR … exit 1`, covered by the new sentence, though `:312` is a catch-all around the whole grading body, so it also catches a mid-run exception, which is not "an invocation error". Sentences A and B — **false**, see F2. |
| The fixtures (D10) | Diffed both new pairs myself. `SCOPE-027`: `diff fail/recipe.json pass/recipe.json` → exactly two lines, the `description` and `"message": "work: the thing"` → `"phase 1: the thing"`. `RIT-007`: exactly two lines, the `description` and one stub's `Write-Host` string. Both `description` texts describe their own diff accurately — the phase-4 F3 defect is not repeated. The twenty edited `expected.txt` files were read as a diff (`git show 24e7100 -- tests/enforcement/cases/`): every change is a verdict-word substitution or the addition of a line the code now prints; **no expectation was loosened** — nothing was deleted, no assertion weakened, no `exitCode` touched, and the eight `doc-lint` additions and four `SCOPE-01x` additions are strictly *more* text asserted than before. |
| The fixtures prove something (D11, SC-003) | Mutation-tested twice in a scratch worktree at `24e7100`. (1) The four production files reverted to `377e6f4`: `-Case SCOPE-027` → `[-] prints the expected output` on `SCOPE-027/fail` plus both inventory-integrity assertions; `-Case RIT-007` → `[-]` on `RIT-007/fail`, 27 passed / 3 failed. (2) The narrow mutation the implementer claims — only `'scope-check'` removed from `$ungradedCapableMembers` — `-Case RIT-00` → **53 passed / 1 failed, the one failure being `RIT-007/fail`, with `RIT-006` green**. That is exactly the claim, independently reproduced: `RIT-006` cannot see this defect and `RIT-007` can. In both mutations the `"exits with the expected code"` assertions passed, confirming no exit code moved. |
| Coverage / inventory | Full suite at HEAD on a clean tree (`git status --porcelain` empty, HEAD `24e7100`): **`Tests Passed: 782, Failed: 0`**, `coverage: 187 of 200 … scope-check.ps1 28 of 28 … scope-check-repos.ps1 31 of 32 … ritual-checks.ps1 6 of 6` — matching `notes.md`'s "782 passed, 0 failed (was 774). Coverage 187 of 200" exactly. All eight moved anchors verified unique: `grep -Fc` for each of the four scope-check and four scope-check-repos anchors returns `1`. `RIT-006`/`RIT-007` sharing one anchor is sound — see F8. One shortfall the report itself surfaces: `doc-lint.ps1 10 of 10 site(s) inventoried, 3 unclassified candidate(s)` — F6. |
| Feature contract held (no unapproved table/migration/permission/package) | No new dependency, no new script, no new manifest class. 52 files: 4 under `scripts/`, 46 under `tests/enforcement/`, 2 under `specs/015-enforcement-assurance/`. `kit-manifest.json:40` classes `scripts/*.ps1` as **`verbatim`**, which is why the header text in F2 and F3 reaches three adopted projects unedited. |
| Constitution / domain invariants | **I (Amendment authority)**: `git show --stat 24e7100` shows `spec.md`, `plan.md`, `tasks.md` and `contracts/` are **not in the commit at all** — the only `specs/` files are `notes.md` (an evidence log) and the round-1 review document. No `**Amendment approved by**` record is owed and none is claimed — correct, and correctly different from the phase-4 amendment `74f690e`, which carried one. **X**: subject carries `phase 5`; `pwsh -File scripts/scope-check.ps1` → `scope-check: PASS phase 5 commit 24e7100 (52 file(s))`, exit 0; `-All` PASSes every commit on the branch; the commit reverts cleanly (proved — I reverted its four production files in a worktree and the tree ran). **II**: engaged for D4/D6/D7 and resolved by citation; engaged and unresolved for SC-004 vs D6 (round 1's F4, still open). **III/V/VII** N/A. |
| Security (authn/authz, secrets, sensitive logging) | Nothing new. No network, no credentials, no writes, no new fixture primitive. The only interpolations added are `$Branch` into `UNGRADED` messages (git refuses newlines in ref names) and `$errCount` into doc-lint's FAIL line (an integer). `$name` is still interpolated unescaped into the verdict regexes at `ritual-checks.ps1:152,157` — round 1's F7, still latent, and the two names added to `$ungradedCapableMembers` (`scope-check`, `scope-repos`) contain no regex metacharacters, so it remains correct today. |
| Scope guard | `pwsh -File scripts/scope-check.ps1` → PASS (above). `git show --stat 24e7100` read for intent: every path is `tests/**`, one of four Territory scripts, or `specs/015-enforcement-assurance/**` (implicitly in territory). `pwsh -File scripts/ritual-checks.ps1` on the kit → doc-lint/enforcement-pack/scope-check/digests/roadmap-claims `OK`, scope-repos and verify-kit `n/a`, `RESULT OK`, exit 0. |
| Rollback safety | Clean, and measured. Reverting the four production files to `377e6f4` in a worktree left a tree that runs; the only consequence is the harness failures listed in the mutation row, which is the correct signal. No schema, no migration, no state, no data. |
| Visual-reference match | **N/A — no visual references exist.** Four PowerShell scripts and JSON/text fixtures; `specs/015-enforcement-assurance/` has no `screenshots/` and the plan declares none. The Visual Compliance Loop does not apply. |
| Test coverage observed | See "Test coverage observed" below. |

## Findings

### F1 — Round 1's F1 is closed, and closed more thoroughly than it was asked to be — ACCEPTED

Stated plainly because it is the headline answer: **F1 is closed.** The three sites the review
named are converted (`scope-check.ps1:296`, `scope-check-repos.ps1:379,407`), and the conversion
did not stop there. The implementer's own sweep found a fourth shape the review missed —
`Invoke-ScopeCheck` skips merge commits, token-less commits and pre-006 trees, so a branch made
only of those exited 0 having printed no run-level line at all, leaving the wrapper nothing to
lift. That case is now covered by `$script:gradedCommits` and by a new rule, `SCOPE-027`. Finding
the general case rather than patching the three named instances is the right instinct and is the
difference between closing a finding and closing a defect.

I verified the closure the way round 1 verified the defect, by building the state rather than
reading the code: a two-commit repository, `git clone --depth 1 --branch 001-thing`, `scripts/`
copied in, `ritual-checks.ps1 -Branch 001-thing` — the verdict block now reads
`ritual-checks: scope-check      UNGRADED could not resolve a merge base with main — nothing
checked` where round 1 recorded `scope-check      OK`. I also traced every return path of
`Invoke-ScopeCheck` (evidence table) and found the counter's placement correct: it increments at
exactly the two paths that compare a commit against a territory, no FAILing path can reach the
ungraded branch, and the initialisation precedes every call.

Two judgement calls inside the conversion deserve explicit endorsement. The `scope-repos`
`n/a (nothing was graded …)` → `UNGRADED` change reverses a deliberate feature-012 decision and
is right to: US3 acceptance scenario 3 says the two claims must not be blurred, and a declared
code repository does apply. The `not applicable` → `n/a` respelling is not cosmetic either — the
wrapper lifts `^<member>: n/a`, so those three correct claims were being rendered `OK`; I
reproduced the improvement on a scratch `flowboard` clone.

*Action: none.*

### F2 — Round 1's F2 is not closed: the rewritten vocabulary block replaces one false assertion with two more, in a file that flows down verbatim — BLOCKING

`scripts/ritual-checks.ps1:35-40` now states: *"Every grading script in this kit ends its run on
a VERDICT LINE - `<member>: <WORD> [reason]` - and the word is one of these six."* `:77` states:
*"Only the last line of a member's output is its verdict."* Both are checkable and both fail.

**Sentence A is false for two of the nine grading scripts.**

- `scripts/territory-check.ps1` is one of the nine (spec, Assumptions; it has its own entry in
  `tests/enforcement/emission-idioms.json`). It ends on `CLEAN — '<branch>' shares no files with
  any open feature branch.` (`:105`), `OVERLAP with …` (`:108`) or `no remote — nothing to check
  against` (`:53`) — no `<member>: ` prefix, no vocabulary word — and at `:121` it exits **2**,
  an exit code the header's FAIL/ERROR sentence does not admit exists.
- `scripts/verify-kit.ps1:114` ends a declined run on
  `verify-kit: not applicable (this is the kit template, not an adoption)` — the spelled-out form
  this very commit respelled `n/a` in the two scope scripts, precisely because the wrapper cannot
  lift it. I checked the reachability carefully and it is fair to the implementer: the decline
  requires neither `.kit-version` nor `kit-adoption.json`, and wrapper membership requires one of
  them (`ritual-checks.ps1:120-124`), so this line can never appear *as a member's* verdict. But
  sentence A's subject is "every grading script", not "every member", and `adoption/updating.md`
  runs the doctor directly at init end and update end.

**Sentence B is false for three members, including the two this commit is about** — and it is the
load-bearing one, because the KNOWN DIVERGENCES block uses it to license leaving forty detail
lines unconverted.

- `scope-check` under `-All` prints **no run-level line at all** when it graded something
  (`:312` is guarded by `gradedCommits -eq 0`). Its last line on a healthy run is a per-commit
  detail line — measured on this very commit:
  `scope-check: PASS phase 5 commit 24e7100 (52 file(s))`. Apply the header's rule and
  `scope-check`'s verdict is `PASS`, which is not one of the six words and is the word plan **D4
  explicitly decided against**. This commit's own `SCOPE-027/pass/expected.txt` ends on that
  shape.
- `scope-repos` behaves the same way: `:407` is guarded by `$graded -eq 0`, so a graded run ends
  on `<repo>: PASS phase N commit …`.
- `enforcement-pack.ps1:1260-1261` prints its verdict line and *then* the issue bullets. Captured
  on a scratch run: `enforcement-pack: FAIL (2 issue(s)):` followed by two `  - Structure: …`
  lines. The last line is a detail.

This matters for the same reason round 1 said it mattered, and the commit message says so
itself: *"an unstated intention is how F1 happened."* `kit-manifest.json:40` classes
`scripts/*.ps1` as `verbatim`, so this text reaches FitForge, flowboard and expense-tracker
unedited, and T049/T050/T051 will quote it into `adoption/updating.md` and
`docs/sdlc/review-process.md` in phase 6. A canonical definition that is wrong about the two
members it was rewritten to describe is the kind of thing this feature exists to make impossible.

The fix is cheap and does not require reconciling anything: say what is true. A member's verdict
line is the line matching `<member>: <WORD>` with `WORD` one of the six; it is not necessarily
the last line (enforcement-pack's issue bullets follow it; the scope checks print one only when
they graded nothing, and otherwise end on a per-commit `PASS`/`WARN`/`not applicable` line);
`PASS` is the per-commit affirmative word in both scope checks and is deliberately not a run
verdict (D4); and `territory-check.ps1` and `verify-kit.ps1`'s decline path are named in KNOWN
DIVERGENCES alongside `update-kit.ps1`.

*Action: implementer — rewrite `scripts/ritual-checks.ps1:35-40` and `:77` so that every sentence
is true of this repository as it stands, and extend KNOWN DIVERGENCES to name `territory-check.ps1`
(no verdict line, exit 2) and `verify-kit.ps1:114` (`not applicable`). Both files are inside phase
5's Territory; no amendment is needed.*

### F3 — The recorded deferral is materially incomplete: two script headers inside Territory and two prior contracts now describe verdicts the code no longer prints — CONFIRM

`notes.md`'s "Doc drift this remediation creates, and does not fix" names three prose lines
(`definition-of-done.md:103`, `review-process.md:59`,
`code-repo-scope-check.yml.template:37`) and says *"They are incomplete, not wrong"* and *"None of
the three is machine-read"*. I verified both sub-claims and both hold: the three lines are at
those exact locations, and nothing under `.github/` parses a verdict word —
`.github/workflows/ritual-checks.yml:44` runs the script and reads its exit code. Recording the
deferral rather than meeting it with silence is the right response to round 1's F1, and it
explicitly asks for an owner decision, which is correct under constitution I.

The list is short by four, and two of the four are *wrong*, not merely incomplete:

- `scripts/scope-check.ps1:46-48` — *"Verdicts and exit codes (data-model.md): `PASS /
  not-applicable / WARN -> exit 0`"*. The script no longer prints `not applicable` at the run
  level (it prints `n/a`), and it now prints `UNGRADED` at four sites. `:14` still says the Lite
  lanes get "`not applicable` (exit 0)". **Inside Territory, inside a file this commit edited.**
- `scripts/scope-check-repos.ps1:30-31` — *"`PASS / not applicable / n/a / WARN -> 0`"*, omitting
  `UNGRADED`. Same.
- `specs/006-verification-pack/contracts/scope-check-cli.md:16,22-23,44,60-61` — "detached HEAD
  yields a WARN no-op" (now `UNGRADED`), `scope-check: not applicable (<lane> lane)` (now `n/a`),
  and scenario S5's expected verdict.
- `specs/012-cross-repo-scope-check/contracts/scope-check-repos-cli.md:34,36,100,102,106` — the
  verdict table row `not applicable | … trunk` (now `n/a`), `WARN | … detached HEAD` (now
  `UNGRADED`), and the C11/C14/C16 evidence rows.

The first two are the more pressing: they sit in `verbatim`-class files (`kit-manifest.json:40`)
that flow down to three adopted projects, they are inside this phase's Territory, and fixing them
costs nothing. The contracts are prior features' approved documents and their disposition is not
mine to choose — amend them, record them as historical, or fold them into a phase-6 task.

*Action: owner — decide the contracts (`006` and `012`). Implementer — update the two script
`.DESCRIPTION` verdict tables in this phase (Territory-legal, zero cost), and extend `notes.md`'s
deferral list to name all four so the record is the complete one round 1's F1 asked for.*

### F4 — `roadmap-claim-check.ps1:57` still reports a ledger it could not read as `n/a` — the same blur this commit converted two lines away — CONFIRM

`scripts/roadmap-claim-check.ps1:51-58`:

```powershell
git -C $Root remote get-url origin 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Host 'roadmap-claims: n/a (no origin remote — no claim ledger to check against)'; exit 0 }
$heads = git -C $Root ls-remote --heads origin 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host 'roadmap-claims: n/a (origin unreachable — cannot read the claim ledger)'; exit 0 }
```

The second line is reached only after the first has proved an origin remote exists. The check
therefore *applies*, ran, and formed no opinion because the history was unreadable — which is the
new header's definition of `UNGRADED` almost verbatim (`ritual-checks.ps1:53-55`: *"The check
applies and RAN AND FORMED NO OPINION: no computable diff base, unreadable history…"*). It is the
identical argument this commit uses to convert `scope-check-repos.ps1:407`: *"a declared code
repository DOES apply - that is what declaring it means"*. `roadmap-claim-check.ps1` is in phase
5's Territory (`tasks.md:230-240`). Both halves of the defect the commit message describes are
present: the member's own word, and `roadmap-claims` being absent from
`$ungradedCapableMembers` (it is in `$naCapableMembers` only).

I am deliberately rating this CONFIRM rather than BLOCKING, and the reason is a real difference of
degree. Round 1's F1 was blocking because the verdict block printed the bare word `OK`;
here it prints `roadmap-claims  n/a (origin unreachable — cannot read the claim ledger)`, so
FR-010's "must not report the state a fully graded pass reports" is met and a reader is told what
happened. What is violated is FR-009 and US3 acceptance scenario 3 — *n/a* and *ungraded* are
being blurred by a line whose own text says which one it is. The first arm (`no origin remote`)
is a defensible N/A and I am not asking for it. What I am asking is that the same sweep standard
the commit applied to the two scope checks be applied here or recorded as declined — round 1's
words, which this commit quotes approvingly, were "option (b) is legitimate; silence is not".

*Action: owner/implementer — either convert `:57` to `UNGRADED` and add `roadmap-claims` to
`$ungradedCapableMembers` with a fixture pair (both files are in Territory), or record the
declension in `notes.md` with a reason, as F3's deferral does.*

### F5 — The new run-level `UNGRADED` fires over commits the same run calls `not applicable`, and the measured flow-down record omits the state adopters will meet most often — CONFIRM

Two connected observations about `scope-check.ps1:312-317`, the general case F1 added.

**The blur runs the other way here.** `SCOPE-014/fail/expected.txt`, written by this commit,
reads in full:

```text
scope-check: not applicable (commit <SHA> is a merge commit)
scope-check: UNGRADED no commit on '001-thing' was graded — the reason is on the line(s) above
```

The same run says, about the same single commit, both *this does not apply* and *this applies and
I formed no opinion*. `SCOPE-015` is the same shape for a token-less commit. Both states are
documented as `not applicable` in feature 006's contract (`scope-check-cli.md:41,44` and scenario
S6). The commit message lumps three reasons together — *"a merge commit, no 'phase N' token, a
pre-006 tree with no tasks.md"* — but only the third is an ungraded state in the header's own
terms; the first two are honest N/A. There is a coherent defence (the *run* applies even when
none of its commits does, so the run-level word is about the run), and if that is the intent it
should be the one sentence that says so, because the fixture's own expected output is where a
future reader will first meet the tension.

**The consequence was not measured.** `notes.md`'s "What flow-down will actually look like,
measured" records only the trunk case (`n/a ('main' is the trunk)`, `RESULT OK`). I reproduced
that and it is accurate — and then built the other state. On a scratch `flowboard` clone with
this branch's `scripts/` installed, a numbered feature branch carrying a spec/plan/tasks commit
and no phase commit yet — the ordinary state of every feature between `claim-feature.ps1` and its
first phase commit — now gives:

```text
ritual-checks: scope-check      UNGRADED no commit on '099-probe' was graded — the reason is on the line(s) above
ritual-checks: scope-repos      UNGRADED (nothing was graded in the declared code repositories for '099-probe' — the reason is on the line(s) above)
ritual-checks: RESULT UNGRADED (2 of 7 member(s) formed no opinion; nothing failed)
exit=0
```

Exit 0 is unchanged and SC-005's exception covers the verdict change, so nothing is broken. But
`RESULT UNGRADED` on every feature branch's first CI runs is the headline thing an adopter will
see, and it is absent from the only section of the record that claims to measure flow-down —
which T049 is going to be written from.

*Action: owner — confirm that `UNGRADED` (not `n/a`) is the intended run verdict when every
commit was `not applicable`, and have the disposition written beside the code. Implementer —
extend `notes.md`'s measured flow-down section with the pre-first-phase-commit case above, so
T049 is written from the complete measurement.*

### F6 — `doc-lint`'s new verdict line is outside the declared emission idiom, so coverage reports `doc-lint.ps1 10 of 10` for a script that now has eleven verdict-bearing lines — MINOR

`tests/enforcement/emission-idioms.json`'s `doc-lint.ps1` accumulators include
`Write-Host\s+['"]doc-lint: (manifest|OK)`, which does not match the line this commit added at
`scripts/doc-lint.ps1:257`. Measured, not inferred — I replicated the scanner
(`Coverage.Tests.ps1:58-77`) against both revisions:

```text
== HEAD     precise=10  unclassified=3   (233, 247, and 257: doc-lint: FAIL …)
== 377e6f4  precise=10  unclassified=2   (233, 247)
```

So the run prints `coverage: doc-lint.ps1  10 of 10 site(s) inventoried, 3 unclassified
candidate(s)` — 100% of a denominator that missed the verdict word the commit just added. The
recall sweep does catch it, which is the harness working as designed and why this is MINOR rather
than more. But it is the exact mistake the same commit's neighbouring idiom note describes as a
lesson: *"T028 declared this as 'Write-Host "scope-check: FAIL' and the reporter answered 13 of
13 — a perfect score against a denominator that counted one of six verdict words."* The
`doc-lint.ps1` note was carefully widened in T030 and again in T036b and argues twice that the
verdict register is counted on purpose; it was not widened here. The new line is asserted by
eight `expected.txt` files, so it is under test — it is only uninventoried.

*Action: implementer — widen the `doc-lint.ps1` accumulator to `(manifest|OK|FAIL)`, add a rule
for the site (its pass/fail coverage already exists in `DOC-001`..`DOC-007`), and update the note.
Cheap now; T044 makes coverage blocking.*

### F7 — The counter, the aggregator wiring and the exit-code contract are correct — ACCEPTED

Recorded positively because it is the part most likely to hide a defect and I looked for one.
Every return path of `Invoke-ScopeCheck` is classified correctly (evidence table); the ordering
`if (-not $ok) { exit 1 }` before the ungraded branch means no FAILing run can print `UNGRADED`;
the counter is initialised before every call and is safe with or without `Set-StrictMode`; the
`-Commit` path is exercised by four existing cases. On the wrapper side, `$captureMembers`
correctly becomes `digests, roadmap-claims, scope-repos, enforcement-pack, scope-check`, the
`^${name}: UNGRADED` anchor cannot be matched by a per-repository detail line (those read
`scope-repos: <repo>: UNGRADED …`, so the prefix does not match) or by a per-commit line in
`scope-check` (all four of its `UNGRADED` strings are run-level), and the precedence
`UNGRADED > n/a > OK` at `:171-174` is the right order for `scope-repos`, which is now the one
member that can emit both.

*Action: none.*

### F8 — `RIT-006` and `RIT-007` sharing one `emitAnchor` is sound, and does not inflate coverage — ACCEPTED

The implementer's argument (`rules.json`, `RIT-007` notes) is that the allow-list is not itself an
emission site, so the site it governs is the one `RIT-006` already names. I checked the harness
rather than the argument. `Coverage.Tests.ps1:107-130` counts *hits per rule* — for each rule,
`$hits = @($scan.Precise | Where-Object { $_.Text.Contains($rule.emitAnchor) })` compared against
`siteCount` (default 1) — so both rules see one site each and both pass. The coverage report
(`:189-203`) iterates over **sites** and appends each site once if *any* rule matches it, so the
numerator cannot double-count; `ritual-checks.ps1 6 of 6` in my run confirms it. The ambiguity
check exists to stop the inventory lying *upward* about how much is covered, and two rules on one
site does not do that. All eight moved anchors resolve to exactly one site each (`grep -Fc` → 1
for every one).

*Action: none.*

### F9 — Round 1's F3, F4, F5, F6, F7 and F9 remain open; the commit claims only F1 and F2 — MINOR

Recorded so the ledger is complete, not as a complaint: the commit's subject and body scope
themselves to F1 and F2 honestly, and `notes.md` does the same. The six others stand as round 1
left them, and three are worth re-flagging now rather than at merge:

- **F3** — `emission-idioms.json`'s `ritual-checks.ps1` note still reads *"is five: … and the two
  run verdicts"*; there are six sites and three run verdicts, and the harness prints `6 of 6`.
  This commit edited two other notes in the same file and left this one, so the stale count is
  now two commits old.
- **F4** — SC-004's "CI badge" clause remains unsatisfiable under D6, unrecorded. An owner
  decision, unchanged by this commit.
- **F5** — the typographic split persists and is now internal to the remediation: the four new
  runtime strings use em dashes (`— nothing checked`, `— the reason is on the line(s) above`)
  while the rewritten header block uses ASCII hyphens throughout. Still unexplained.
- **F6** (`AmendmentAuthority: graded 0 of N`), **F7** (`[regex]::Escape($name)`) and **F9**
  (`PACK-001`'s future-tense description) are unchanged.

*Action: implementer — fold F3 and F5 into the F2/F3 edit (same files, no extra risk); leave F6,
F7 and F9 as round 1 dispositioned them; F4 is the owner's.*

### F10 — The twenty re-baselined expectations and both new pairs are honest — ACCEPTED

The failure mode worth hunting here is an expectation quietly relaxed to make a run green, and it
is not present. Every one of the twenty changes is either a verdict-word substitution on an
existing line or a line *added*: eight `doc-lint` cases gained the new `FAIL` line, four
`SCOPE-01x` cases gained the run-level `UNGRADED` line, eight lines changed word in
`SCOPE-021..026` and twelve in `REPOS-007..032`. Nothing was deleted, no assertion weakened, and
no `command.json` `exitCode` was touched anywhere in the diff — which is what makes the commit's
"no exit code moved" claim checkable, and it checks out under both mutations. Both new pairs meet
D10 strictly (`SCOPE-027`: one commit subject; `RIT-007`: one stub line), and both
`description` texts describe their own diffs accurately. `DOC-009/pass` gaining a `FAIL` line is
the correct D10 idiom, not a defect: its pass direction reports the violation its fail direction
lets through.

*Action: none.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None.** `git show --stat 24e7100` lists 52 files; the only two under `specs/` are
`specs/015-enforcement-assurance/notes.md` (an evidence log, not one of the approved documents
constitution I governs) and `specs/015-enforcement-assurance/ai-code-review-phase-5.md` (the
round-1 review being placed on the record). `spec.md`, `plan.md`, `tasks.md` and `contracts/` are
**not in the commit at all** — not even a checkbox flip. Accordingly no
`**Amendment approved by**: <name>, <YYYY-MM-DD>` line is owed by this commit, none is claimed,
and no self-approval occurred. `notes.md` explicitly declines to widen Territory for the three
deferred prose lines on exactly this ground, which is the correct reading of constitution I.

## Constitution re-check (post-implementation)

**PASS, with F2 outstanding** (a documentation-accuracy finding, not a constitutional one).

- **I Specification First / Amendment authority** — satisfied. No approved document changed; no
  approver record owed; the one place an amendment *would* have been needed (reaching the three
  prose lines outside Territory) was declined and escalated to the owner rather than self-approved.
- **II Source of Truth** — engaged and correctly resolved for D4/D6/D7. Engaged and **not**
  resolved for SC-004 vs D6 (round 1's F4, still open), and newly engaged for the two prior
  contracts in F3, which are rungs this commit's behaviour has moved away from.
- **III Repository Separation** — N/A, single governance repository, no `codeRepos`.
- **IV Architecture Consistency** — satisfied. No new dependency, no new script, no new manifest
  class; `$script:gradedCommits` copies the `$graded` pattern `scope-check-repos.ps1` has used
  since feature 012, which is convergence rather than a new idea.
- **V Domain Invariants** — N/A, no domain-invariants pack.
- **VI Security** — satisfied; see the security row.
- **VII External Integration Governance** — engaged. Two CLI contracts (`006`, `012`) now describe
  verdicts the implementation no longer prints — F3, owner's call.
- **VIII Testing Requirements** — satisfied, and demonstrably so: both new rules are
  mutation-proved by me independently, and the narrow mutation the implementer claims for
  `RIT-007` reproduces exactly.
- **IX Human Review** — this document is gate 5, round 2; gate 6 is owed once, at merge.
- **X Controlled Delivery** — satisfied. One phase, `phase 5` in the subject, `scope-check` PASS
  on the commit, independently revertible (verified). `**Gate Certification**: ci-held` means the
  owner's recorded approval on the CI evidence triplet is still outstanding; this review does not
  and cannot substitute for it.

## Test coverage observed

- **Two new fixture pairs, four cases.** `SCOPE-027` (a branch whose every commit is skipped —
  the general case the per-site conversions do not reach; the pair differs in one commit's
  subject line) and `RIT-007` (the aggregator lifts `UNGRADED` for the *second* member that can
  reach it; the pair differs in one stub's verdict word). Both are honest D10 pairs.
- **The critical assertion is not "quiet".** `SCOPE-027/pass` does not merely stop printing the
  ungraded line — it prints `scope-check: PASS phase 1 commit <SHA> (1 file(s))`, i.e. it shows
  the grading the fail direction never performed. `RIT-007/pass` shows the `RESULT OK` the fail
  direction turns into `RESULT UNGRADED`.
- **Both directions assert the exit code, and it is 0 on both sides of both pairs** — the whole of
  plan D6. Confirmed twice over: the `command.json` files declare `"exitCode": 0` in all four
  cases, and under both mutations every `"exits with the expected code"` assertion passed while
  only output assertions failed.
- **Mutation results, run by me.** Full revert of the four production files → `SCOPE-027/fail`
  and `RIT-007/fail` both fail, plus the two inventory-integrity assertions (stale anchors).
  Narrow mutation (`'scope-check'` removed from `$ungradedCapableMembers`, nothing else) →
  `-Case RIT-00`: 53 passed / 1 failed, the single failure being `RIT-007/fail` with `RIT-006`
  green. Neither new case is vacuous, and `RIT-007` proves the specific thing it claims to.
- **Suite state at HEAD, clean tree.** `Tests Passed: 782, Failed: 0, Skipped: 0`. Coverage
  `187 of 200` across nine scripts: `scope-check.ps1 28/28`, `scope-check-repos.ps1 31/32`,
  `ritual-checks.ps1 6/6`, `enforcement-pack.ps1 48/54`, `doc-lint.ps1 10/10 (3 unclassified)`,
  `territory-check.ps1 7/12`, `verify-kit.ps1 30/31`, `build-digests.ps1 19/19`,
  `roadmap-claim-check.ps1 8/8`. Matches `notes.md` exactly, including the 774→782 and
  186/199→187/200 deltas, whose arithmetic (four new cases × two assertions; one new declared
  site) is internally consistent.
- **Known gaps, by construction.** No case covers `roadmap-claim-check.ps1:57` (F4) or
  `doc-lint.ps1:257` as an inventoried site (F6). Coverage remains reporting-only until T044 per
  D9, so neither shortfall reddens the run today — which is exactly why F6 is worth closing
  before phase 6 rather than after.

## Residual risk

Concentrated in **F2**, and it is narrower than round 1's but the same species: the kit's single
canonical statement of its own verdict vocabulary asserts two things that are false about the two
members this commit was written to fix, in a file classed `verbatim` that three adopted projects
will receive unedited and that phase 6 will quote into `adoption/updating.md` and
`docs/sdlc/review-process.md`. Nothing behaves wrongly because of it; what is wrong is the
record, and the record is this feature's product. The fix is two paragraphs and touches only
files already in Territory.

**F3, F4 and F5 are the owner's** and none of them changes behaviour: four documents the deferral
record does not name (two of them inside Territory and in the edited files), one remaining
`n/a`/`UNGRADED` blur in a Territory script, and a run-level word whose most common new effect on
adopters was not measured. **F6 and F9** are cheap hygiene best folded into the F2 edit.

Round 1's two blocking findings, judged plainly: **F1 is closed** — verified by rebuilding the
failing state, by tracing every return path, by two independent mutations, and by a green 782-case
suite. **F2 is not closed** — the false claim was replaced rather than removed. Fix F2, decide
F3–F5, and the phase deserves to stand: the exit-code contract is held and proved, the emission
sites are complete for the condition they name, the fixtures fail when the code is reverted, and
the three adopted projects see a change that is visible, non-breaking and more honest than what it
replaces. Gate 3 remains outstanding under `ci-held`: the owner's recorded approval on the CI
evidence triplet for `24e7100`, which this review does not and cannot supply.
