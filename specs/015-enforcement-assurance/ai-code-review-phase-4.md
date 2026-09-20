# AI Code Review — 015 Enforcement Assurance (Phase 4)

**Reviewer**: fresh-context agent — claude-opus-5
**Date**: 2026-09-19
**Branches**: agentic-sdlc-kit `015-enforcement-assurance` (tip `8778c06`)
**Scope reviewed**: commit `8778c06` in full. Tracked-file changes read line by line:
`tests/enforcement/emission-idioms.json` (+69/-…, all nine declarations),
`tests/enforcement/rules.json` (+1139, 116 new rules — read as parsed JSON, all 173 entries
enumerated), `tests/enforcement/lib/FixtureRepo.psm1` (+84: `rename`, `origin`, `detach`,
`nestedRepos`, the `$At` nesting path and the shallow/nested refusal),
`tests/enforcement/lib/Harness.psm1` (+56: `<DATE>`, `rootSuffix`, `noRoot`,
`Start-Process` splat), `tests/enforcement/Harness.Tests.ps1` (+90, the six new tests),
`specs/015-enforcement-assurance/notes.md` (+409, the whole phase 4 section, lines 1060–1427),
`specs/015-enforcement-assurance/tasks.md` (the 9 checkbox ticks). Case directories: 16
`expected.txt`/`command.json`/`recipe.json` triples read in full across all 8 new scripts
(`DOC-001/005/007`, `VK-003/011/013/018/022/025`, `DIGEST-004/008/011/016`, `CLAIM-002/003/005/007`,
`SCOPE-004/013/017/020/023/026`, `REPOS-005/009/014/021/030`, `TERR-001/003/004/006`,
`RIT-001/003/004/005`), plus a mechanical sweep of all 358 case directories for
generated-expectation signatures and for pass/fail recipe divergence. Kit scripts read as the
graded subject: `scripts/doc-lint.ps1` (all 253 lines), `scripts/verify-kit.ps1` (dimension 4 and
the report block), `scripts/territory-check.ps1` (all 123 lines),
`scripts/roadmap-claim-check.ps1` (all 128 lines), `scripts/scope-check.ps1` (dispatch + `-All`),
`scripts/scope-check-repos.ps1` (the date-read guard), `scripts/ritual-checks.ps1` (member
dispatch), `scripts/enforcement-pack.ps1` (`Invoke-ReviewProvenanceCheck`), `scripts/scope-lib.ps1`.
Law read: `CLAUDE.md`, `docs/sdlc/definition-of-done.md`, `specs/015-enforcement-assurance/`
`spec.md` / `plan.md` / `tasks.md`, `specs/_templates/ai-code-review-template.md`, and the
phase 1–3 reviews. Independently run: `Coverage.Tests.ps1` in isolation (7/7, numbers reproduced
exactly); `Run-Tests.ps1 -Case cases/doc-lint` (52/52, 58.3s); `Run-Tests.ps1 -Case
cases/roadmap-claim-check` (56/56); one `territory-check` case driven directly through
`Invoke-FixtureCase`; `scripts/scope-check.ps1` and `-All` (PASS, exit 0); a live PowerShell probe
of `-notmatch` vs `-cnotmatch` case semantics; a live probe of `Write-Error` under
`$ErrorActionPreference = 'Stop'`. The full suite was NOT run (≈50 min, out of scope for this
review).
**Feature contract**: T028–T036 only — inventory and cover the remaining eight grading scripts.
Declared Territory: `tests/**` (plus the implicit `specs/015-enforcement-assurance/**`
`scope-check.ps1` always grants). No grading script may be modified. Plan constraints in force:
D1/FR-006 (hand-written expectations, never generated), D10 (pass differs from fail only in the
condition), D9 (coverage reports, does not block until T044), D12 (real git repositories),
SC-006 (no verdict differs between ubuntu and Windows).

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5
- **Implementer**: claude-opus-5 (implementing session, separate context)
- **Inputs provided**: the phase 4 diff (`8778c06`), `spec.md`, `plan.md`, `tasks.md`, `notes.md`,
  `CLAUDE.md`, `docs/sdlc/definition-of-done.md`, `specs/_templates/ai-code-review-template.md`,
  the phase 1/2/3 reviews, and the working tree at `8778c06`
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The phase does what it claims. Territory is clean — not one file
under `scripts/` is touched, which is the hardest constraint here because the implementer found a
genuine defect in `scripts/verify-kit.ps1` mid-phase and left it unfixed with the fixture pinned
to a name that is refused on both platforms. I verified that defect independently rather than
taking it from `notes.md`: `"Backend" -notmatch '^[a-z][a-z0-9-]*$'` really does return `False`,
so a tier the message promises must be lowercase is accepted, and because `Test-Path` is
case-sensitive on Linux and not on Windows the adoption doctor really can reach two different
verdicts on the same `kit-adoption.json`. That is the single most valuable thing the phase
produced, and it exists only because the expectation was written before the run. The coverage
headline is real, not asserted: I ran `Coverage.Tests.ps1` alone and got `177 of 185` with the
per-script breakdown matching the commit message digit for digit, and the anchor-ambiguity
assertion (added in phase 3) passes, which independently rules out the two failure modes the
brief asked about — no rule's `emitAnchor` matches zero lines, and none matches more than its
declared `siteCount`. The denominator changes survive attack: I read `doc-lint.ps1` myself and
confirm the two excluded lines (`:233`, `:247`) really are printers for accumulators already
counted, and the four widenings are genuine distinct conditions with real fixtures, not padding.

The residual risk is one finding, F1: the principle the phase states — *a site is a condition the
script detects* — was not applied to `doc-lint.ps1:236`, the line that says the manifest
completeness sweep was **skipped** in an adopted project. That is not a printer of any
accumulator; it is an independent branch on `.kit-version`, it is an inert "this check did not
run" verdict of exactly the kind `emission-idioms.json` says it counts on purpose for five other
scripts, it is covered by no fixture, and — because the recall sweep only looks for `FAIL|ERROR`
text — it is invisible to **both** passes. `doc-lint` therefore reports a perfect `7 of 7` while
one of its conditions is untested and unnamed, which is the exact shape D8 exists to prevent. It
is a follow-up rather than a blocker because D9 keeps coverage reporting-only until T044 and the
phase's own notes already flag T044 as needing a deliberate decision — but that decision now has
to include this line, and F1 says so. Three CONFIRM findings and four MINOR/DOC-DRIFT findings
follow; none threatens the phase's core claim.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | **FR-001/FR-002**: `rules.json` parses to 173 rules; `Get-ChildItem cases -Recurse -Filter command.json` returns 358 case directories under 173 distinct rule ids, every id matched to a rule (`Coverage.Tests.ps1` "every case directory belongs to an inventoried rule", green). All 8 target scripts now have rules (T028–T035). **FR-005/D12**: every sampled recipe builds real commits; `nestedRepos` builds a genuinely independent repository — asserted by the new self-test that runs `git -C <nested> rev-parse --show-toplevel` and requires it to equal the nested path and differ from the outer root (`Harness.Tests.ps1:150-160`). **FR-006**: see the row below. **FR-007**: every `expected.txt` I read asserts full message text, not just the code; `command.json` carries `exitCode` separately and `Cases.Tests.ps1:40-52` asserts both. **FR-016/SC-008**: `Harness.psm1:196-229` `Format-CaseFailure` emits `rule :`, `script :`, `case :`, both verdicts, a first-diff line pair and a `reproduce :` command; `Cases.Tests.ps1:36-49` passes the rule id through from the directory name. |
| Visual-reference match (Visual Compliance Loop) | **N/A** — this feature has no UI and `specs/015-enforcement-assurance/screenshots/` does not exist. No visual references exist to deviate from. |
| Feature contract held (no unapproved table/migration/permission/package) | `git show --name-only --format= 8778c06` returns 757 paths; filtering out `tests/enforcement/cases/**` leaves exactly seven: `specs/015-enforcement-assurance/{notes.md,tasks.md}` and `tests/enforcement/{Harness.Tests.ps1,emission-idioms.json,lib/FixtureRepo.psm1,lib/Harness.psm1,rules.json}`. **No file under `scripts/` is in the commit.** No new dependency: `Run-Tests.ps1` still imports only Pester ≥5 (the D2-approved package); no `Install-Module`, no network call added. |
| Constitution / domain invariants | Constitution X (one approved phase): the commit implements T028–T036 and nothing else; every tick in `tasks.md` is inside the Phase 4 block. Constitution I (amendment authority): see the Amendments section — the only `tasks.md` hunk is nine `- [ ]` → `- [x]` flips, byte-identical text otherwise (verified in `git show 8778c06 -- specs/015-enforcement-assurance/tasks.md`), and commit `c5fcdc5` ("checkbox state is progress, not amendment") is this project's standing ruling, read directly. Constitution V: the kit declares no domain-invariants pack. |
| Security (authn/authz, secrets, sensitive logging) | No credentials, tokens or network egress added. `FixtureRepo.psm1:129-132` sets a fixture-local `user.name`/`user.email` and disables `commit.gpgsign` per repository, never touching global config. The one new remote is `git remote add origin <local path>` (`FixtureRepo.psm1`, `origin` block) — a filesystem path, never a hostname, so `git ls-remote` and `git fetch` stay offline (FR-018). Fixtures live under `[IO.Path]::GetTempPath()` and are removed unless `-KeepRepo`. `git status --short` is empty after my runs — nothing leaked into the repository under review (FR-020). |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | `pwsh -File scripts/scope-check.ps1` → `scope-check: PASS phase 4 commit 8778c06 (757 file(s))`, exit 0. `pwsh -File scripts/scope-check.ps1 -All` → same single line, exit 0; this is correct, not a fail-open — PR #46 merged phases 1–3 to `main`, so `git merge-base origin/main HEAD` is `fc7eda4` and `8778c06` is the only commit in range (verified with `git log --oneline main..HEAD` and `git log --oneline origin/main -1` → `2af8503 Merge pull request #46`). Territory `tests/**` covers 755 of the 757 paths; the other two are the feature's own spec directory, which `scope-check.ps1:178,245` grants implicitly (`@("specs/$FeatureBranch/**") + $territory.Entries`). |
| Rollback safety (phase reverts cleanly; schema additive?) | The phase is additive and data-only: 128 new case directories plus append-only growth of `rules.json` (173 rules, no phase-1–3 rule deleted or renamed — the coverage integrity test would fail on a stale anchor and it is green). `git revert 8778c06` removes the new cases and restores the earlier idiom declarations; nothing under `scripts/` depends on `tests/**`, and `ritual-checks.ps1` does not run the harness, so a revert cannot break the gate. `rules.json` gains no schema field (`schemaVersion` still 1); `siteCount` was introduced in phase 3, not here. |
| Integrity property — expectations hand-written (FR-006 / D1) | Mechanical sweep of all 358 `expected.txt` files for generation signatures — `D:\`, `C:\`, `/home/`, `/Users/`, `At line:`, `CategoryInfo`, `FullyQualifiedErrorId`, `\solutions\` — **zero hits**. 16 read in full across all 8 scripts (listed in Scope above): every one is prose a human would type, with only `<ROOT>`, `<SHA>` and `<DATE>` standing in for run-varying values. Three positive proofs that at least some were written before the run, each independently checked: `VK-011` (expectation demands `back_end` be refused; the script would have produced a green run for `Backend`, so a generated expectation would have enshrined the bug — verified by probe, see F-notes), `SCOPE-020/fail/recipe.json` (records that the first attempt produced `not applicable ('main' is the trunk)` exit 0 — a different rule passing in this one's place), `CLAIM-007`. `Harness.psm1:1-10` restates and the module imports nothing from `scripts/`; I confirmed by reading its import list (only `FixtureRepo.psm1`). |
| Coverage claim 177/185 real, not asserted | `Invoke-Pester` on `tests/enforcement/Coverage.Tests.ps1` alone, 7/7 green, printing `coverage: 177 of 185 declared failure-emission site(s) inventoried across 9 grading script(s)` and the identical per-script table the commit message carries (`build-digests 19/19`, `doc-lint 7/7`, `enforcement-pack 44/45`, `ritual-checks 5/5`, `roadmap-claim-check 8/8`, `scope-check-repos 31/32`, `scope-check 27/27`, `territory-check 7/12`, `verify-kit 29/30`; 10 unclassified). Anchor hygiene: `Coverage.Tests.ps1:107-131` fails if any rule's `emitAnchor` matches a number of precise sites other than its declared `siteCount` (default 1) — it is green, so **no rule points at zero sites and none silently claims two**. Four rules declare `siteCount: 2` (`SCOPE-001`, `VK-001`, `VK-002`, `VK-004`); I listed them and read each anchor against the source lines. |
| Denominator change defensible (D) | `doc-lint.ps1` read in full. New accumulators resolve to exactly 7 lines: `:132,:139,:147,:153` (`$manifestErrors +=`), `:219` (`$broken +=`), `:228` (`ERROR: kit incomplete`), `:243` (`${level}:`). The two dropped lines are `:233` (`ERROR: manifest completeness — N issue(s):`, immediately followed by `foreach ($e in $manifestErrors)`) and `:247` (`ERROR: N referenced path(s) do not resolve:`, followed by `foreach ($b in $broken)`) — **both verified to be pure printers of collections already counted above them**; the narrowing is correct on the stated principle. `:228` is correctly kept: `$missingKit` (`:68`) is a `Where-Object` result with no per-condition append, so `:228` is where that condition is detected, not a printer of counted sites. Widenings checked by dumping every precise-matched line per script: `scope-check` 27 lines, all distinct verdicts on distinct conditions; `verify-kit` 30; `build-digests` 19; `roadmap-claim-check` 8. Padding test: the only "free" sites are the three `ok` arms owned jointly via `siteCount: 2` (`verify-kit:127/:163/:177`); removing them changes verify-kit from 29/30 (96.7%) to 26/27 (96.3%) and the kit total from 177/185 (95.68%) to 174/182 (95.60%) — **the widenings do not flatter the number**. The narrowing does move `doc-lint` (a 6-of-8 under the old declaration becomes 7-of-7), which is why F1 exists. |
| Platform divergence (SC-006) | Cannot be closed from Windows and is **not** claimed closed here. What I did verify: `origin` builds a plain local path (`$originUrl = $root`), **not** a `file://` URI — the phase 3 bug shape is structurally absent from the new state; no recipe combines `origin` with `shallow` (grep: zero), so the clone cannot silently replace the remote; `detach` (`git checkout --detach`) and `rename` (`git mv`) are portable verbs; `nestedRepos` joins paths with `Join-Path`; `rootSuffix` concatenates with `/` and still normalises to `<ROOT>/…` on both platforms because `ConvertTo-NormalisedOutput` substitutes the repo path in all three slash spellings (`Harness.psm1:70-78`); `FixtureRepo.psm1:132` sets `core.autocrlf false` per repository and `Write-FixtureFile:99` forces LF; `Harness.psm1:67` normalises CRLF before comparison; `ritual-checks.ps1:85` spawns members with `& pwsh -NoProfile -File`, portable. Enumeration-order risk checked: no expectation in the diff lists more than one item from an unsorted `Get-ChildItem` loop (only `DOC-005` has two indented lines and they come from two different fixed blocks). Residual risks are recorded as F4 and F5. |
| Harness self-tests (L) | All six new tests read. The three `nestedRepos` tests would in fact catch the failure they were written for: if the state degraded to an ordinary subdirectory, `git rev-parse --show-toplevel` from inside it would answer the **outer** root and `Should -Be (Resolve-Path $nested).Path` fails (`Harness.Tests.ps1:150-160`); the second test fails if any outer commit tracked the directory; the third asserts the shallow-nested combination throws rather than being ignored. All 20 self-tests ran green inside my `-Case cases/doc-lint` run. Gap recorded as F7. |
| The claimed `verify-kit.ps1` defect (H) | **Confirmed independently, not taken from notes.** Probe: `"Backend" -notmatch '^[a-z][a-z0-9-]*$'` → `False`; `"Backend" -cnotmatch '^[a-z][a-z0-9-]*$'` → `True`; `"BACKEND" -notmatch …` → `False`. Source read at `scripts/verify-kit.ps1:211-222`: the guard is `-notmatch`, its message promises "lowercase letters/digits/hyphens", and the next statement builds `docs/rulebooks/$tier-rules.md` and tests it with `Test-Path` (`:216-217`) — case-insensitive on Windows, case-sensitive on Linux. The two-platform divergence claim is therefore correct as stated. `VK-011/fail` pins `back_end`, whose underscore is outside `[a-z0-9-]` under either comparison, so the fixture is platform-safe; `VK-011/pass` differs in exactly one JSON value (`"back_end"` → `"backend"`). |
| The eight uncovered sites and the T044 blocker (I) | `territory-check.ps1` read in full: the five uncounted-but-uncovered sites are `Write-Error` at `:36,:46,:57,:64` and `Write-Warning` at `:81`, under `$ErrorActionPreference = 'Stop'` (`:33`). Probe run: a two-line script with `Stop` + `Write-Error` exits 1 and emits `Write-Error: <absolute path>:2 / Line | 2 | … / | <message>` on stderr — an absolute path, a line number and a caret rule, exactly as `notes.md` transcribes. The harness concatenates stderr into the comparison (`Harness.psm1:173`), and `<ROOT>` only substitutes the *fixture* path, never the kit path, so no current expectation can pin it. The claim is substantively right; see F3 for the one way it is overstated. `verify-kit.ps1:311` verified: `Write-Host "verify-kit: ERROR $($_.Exception.Message)"` inside the outer `catch` — runtime-composed text, genuinely unpinnable without making the suite version-dependent. `scope-check-repos.ps1:199` verified: the committer-date read sits after `rev-parse --verify …^{commit}` has already peeled the object. |
| SC-008 honestly reported (J) | `Format-CaseFailure` names the rule (`Harness.psm1:201`) and `Cases.Tests.ps1` supplies the id from the case path, so the harness's own report meets SC-008. The `territory-check` exception is reported, not hidden: `emission-idioms.json`'s `territory-check.ps1` note states in writing "it is the one place in the kit where SC-008 cannot be met", the five sites are **counted in the denominator** (12, not 7) rather than excluded, and `notes.md:1389-1410` names each one with its reason. That is the honest handling. |

## Findings

### F1 — `doc-lint.ps1:236` is a condition the script detects, is uncovered, and is invisible to both coverage passes — so `doc-lint` reports 7 of 7 — BLOCKING (for T044; ACCEPTED-if-recorded for phase 4)

The phase's governing principle, quoted from `emission-idioms.json`, is: *"a site is a CONDITION
THE SCRIPT DETECTS, never a line it prints."* The narrowing of `doc-lint` applies it correctly to
`:233` and `:247` — I read the script and both are pure printers of `$manifestErrors` and
`$broken`, collections whose per-condition appends are already counted. But the same principle,
applied consistently, adds a line the declaration leaves out:

```powershell
# scripts/doc-lint.ps1
100:  if (Test-Path (Join-Path $Root '.kit-version')) {
101:      $manifestSkipped = $true
...
235:  } elseif ($manifestSkipped) {
236:      Write-Host 'doc-lint: manifest — completeness sweep skipped (adopted project; kit-CI-only check)'
```

`:236` is not a printer of any accumulator. It is an independent branch on a condition the script
detects at `:100` — *this tree is an adopted project, so a whole sweep will not run*. That is an
**inert verdict**: the decision not to grade. `emission-idioms.json` says, twice, that this
register is counted on purpose everywhere else — for `scope-check-repos.ps1`, "the inert register
is counted on purpose: this script's whole risk surface is deciding not to grade, which is SC-004
and GAP-027"; for `roadmap-claim-check.ps1`, "for this script the inert half IS the interesting
half". `doc-lint` is the one script where an inert verdict is left out.

Three consequences, each verified:

1. **It is uncovered.** `grep -rl "completeness sweep skipped" tests/enforcement/cases` returns
   nothing, and no `doc-lint` recipe writes a `.kit-version` file (`grep -rl "kit-version"
   tests/enforcement/cases/doc-lint` → nothing). The branch at `:100-101`, and the entire
   adopted-project posture of the kit's own doc-lint, has no fixture.
2. **It is invisible to the recall pass too.** The `candidateSweep` patterns
   (`Coverage.Tests.ps1:41-50`) require `FAIL` or `ERROR` inside the string, or an accumulator
   append. `:236` is single-quoted prose with neither, so it can never surface as `UNCLASSIFIED`.
   I ran the two passes by hand over all nine scripts and the verdict-shaped lines invisible to
   **both** are: `doc-lint.ps1:236`, `doc-lint.ps1:252`, `enforcement-pack.ps1:1235`,
   `verify-kit.ps1:330`. The last three are affirmative run verdicts that print an accumulated
   state and are correctly out under the printer rule; `:236` is the only one that is a genuine
   independent condition.
3. **Therefore `doc-lint` reports a perfect score.** `7 of 7` is not a measurement of `doc-lint`;
   it is a measurement of the part that was inventoried. That is the same sentence the commit
   message writes about T028's old `13 of 13` — *"a perfect score against a denominator built from
   the part already covered"* — and the phase caught it there by heeding an `UNCLASSIFIED` line.
   Here there is no `UNCLASSIFIED` line to heed, because the recall net does not catch inert
   verdicts. That is the structural half of this finding and it applies kit-wide, not only to
   `doc-lint`: now that inert verdicts are inside the denominator, the recall pass that is supposed
   to reveal a short declaration is blind to the entire register.

Why BLOCKING is scoped to T044 rather than to this phase: D9 keeps coverage reporting-only, so
nothing is red today, and the phase's own notes already flag that T044 needs a deliberate
decision. But the notes enumerate *eight* uncovered sites and this is a ninth that the report
cannot see; a T044 that trusts the report will make the branch green on a number that is one
condition short.

*Action: implementer — before T044, add `doc-lint.ps1:236` to the `doc-lint` accumulator list (it
is a condition, by this phase's own principle), write its `DOC-00n` rule and its fixture pair (a
recipe carrying `.kit-version` is enough; `VK-011`'s recipe already shows the shape), and widen the
recall `candidateSweep` to catch inert/affirmative verdict prose (`n/a`, `not applicable`,
`skipped`, `OK`, `WARN`, `PASS`) so the register that is now inside the denominator is also inside
the net that audits it. If the owner instead rules that inert verdicts are out of the denominator,
that ruling must be applied to `scope-check-repos`, `roadmap-claim-check`, `build-digests` and
`scope-check` too, and the four notes that justify counting them rewritten — the one thing that
must not stand is the current split.*

### F2 — D10's escape clause is used but never written down, and nothing checks it — CONFIRM

Plan D10 ends: *"A rule whose pass and fail fixtures do not share a recipe must state why in the
inventory."* I measured the divergence of every pair mechanically (`Compare-Object` over the two
`recipe.json` files with the `description` line excluded): **27 of 173 pairs differ by more than
10 lines**, led by `REPOS-006` (65), `SCOPE-020` (56), `DIGEST-008` (52), `STRUCT-001` (45),
`SCOPE-017` (38), `CRIT-T02` (36), `REPOS-013` (28), `REPOS-011` (25), `REPOS-012` (24).

I read the four largest new-in-phase-4 ones and each is *defensible*: `SCOPE-020` and `REPOS-006`
test an unborn `HEAD`, so the nearest state in which the condition does not hold necessarily has
commits; `SCOPE-017` tests "no `tasks.md` at the commit or its parent", so the pass must add one;
`DIGEST-008` tests a 41-marker pack, so the pass must carry the freshly generated 40-line digest
that the fail case's over-long pack cannot have. The affirmative and inert rules the phase
deliberately inventoried (`CLAIM-003`, `REPOS-011/012/013`, `VK-018`) have the same inherent shape.

But none of those nine `rules.json` entries **states why** — I read every one of their `notes`
fields. `SCOPE-020`'s says "Reachable with an unborn HEAD. Exits 1 rather than guessing"; nothing
about the recipe divergence. And nothing in `Coverage.Tests.ps1` or `Cases.Tests.ps1` measures
recipe divergence at all, so D10's second sentence is an unenforced convention. The two cases the
implementer reports catching mid-phase (`SCOPE-020`, `CLAIM-007`) were caught by reading, exactly
as the nine rounds of feature 014 were — which is the cost profile this feature exists to remove.

What protects the suite today is not D10 but the full-output expectation: `DIGEST-008/fail`
asserts `RESULT FAIL (1 issue(s))`, so a second condition firing in the enlarged pass recipe would
change the text and fail the case. That is a real and strong defence, and it deserves to be the
stated one.

*Action: owner/implementer to decide, before T044 — either add the one-line "why" to the `notes`
of the pairs that do not share a recipe (the nine above are the material ones), or amend D10 to say
that the literal full-output expectation, not recipe minimality, is what proves the rule was
exercised, and record that amendment with its approver per constitution I. A machine check on
divergence would be better than either, but it belongs in phase 6 with T044, not here.*

### F3 — "No hand-written expectation can pin that" is overstated: the `territory-check` sites are unpinnable under the current normalisers, not in principle — CONFIRM

`emission-idioms.json` and `notes.md:1345` both assert that the five host-written
`territory-check` diagnostics cannot be pinned by any expectation. I confirmed the substance — the
error record carries an absolute kit path, a line number and a caret rule (live probe, output
transcribed in the evidence table), and `ConvertTo-NormalisedOutput` substitutes only the *fixture*
path, so the kit path survives into the comparison and the line number moves whenever
`territory-check.ps1` is edited.

But the obstacle is the harness's substitution set, which is `tests/**` and therefore inside this
phase's territory. A `<KITROOT>` substitution plus a line-number normaliser (and ANSI stripping,
which `RunChild.ps1` may already suppress under `-NonInteractive`) would make four of the five
pinnable — brittle, tied to the PowerShell host's error-record format, and arguably not worth it,
but not impossible. The distinction matters because T044's choice is being framed as "declare an
unreachable category, or change the scripts", and there is a third option the framing hides.

The related claim that `scope-check-repos.ps1:199` is "unreachable by construction" because
peeling reads the object is plausible and I could not construct a counter-example, but I did not
prove it either — a deliberately corrupted commit object is a recipe state `truncateBlob` does not
currently produce, so "unreached" is what I can confirm, not "unreachable".

*Action: implementer — when T044 writes the "no fixture can reach this" category, record for each
member which of the three it is (host-written text, runtime-composed text, or unreached), and note
that the `territory-check` five are unpinnable *given the current normalisers*. No change needed in
this phase.*

### F4 — `noRoot` cases depend on the temp path being symlink-free, which is true on `ubuntu-latest` but is an unverified assumption — CONFIRM

`territory-check.ps1:35-37` does `$repoRoot = git rev-parse --show-toplevel` and `Push-Location
$repoRoot`. `git` returns the *physical* path. The harness sets the child's `WorkingDirectory` to
`$repo` (`Harness.psm1:161`), which is `[IO.Path]::GetTempPath()` + a guid. If the platform's temp
directory contains a symlink (macOS `/var` → `/private/var`, or a runner with a symlinked
`TMPDIR`), the path the script prints and the path `ConvertTo-NormalisedOutput` substitutes are
different strings, `<ROOT>` substitution misses, and all 14 `territory-check` cases fail — on that
platform only, which is precisely the SC-006 shape. The harness partially guards this by adding
`Resolve-Path` variants (`Harness.psm1:71-75`), but PowerShell's `Resolve-Path` does not
canonicalise symlinks the way `git` does.

On `ubuntu-latest` `TMPDIR` is `/tmp`, a real directory, so this should not bite today. I could not
test it — SC-006 is only closable by the CI run, and this phase records no CI evidence (F6).

*Action: none required now; implementer to confirm the `ubuntu-latest` leg is green on the
`territory-check` cases specifically before treating SC-006 as held for this phase.*

### F5 — Unsorted `Get-ChildItem` enumerations are a latent cross-platform ordering hazard the current fixtures happen to avoid — MINOR

`doc-lint.ps1:116,123,163`, `build-digests.ps1:169` and `verify-kit.ps1:141` all enumerate with
`Get-ChildItem -Recurse` and no `Sort-Object`. On Windows NTFS that yields a stable alphabetical
order; on Linux it yields `readdir` order, which is not guaranteed. Any expectation that lists two
or more items produced by one of those loops would be platform-dependent.

I checked every `expected.txt` in the diff for this shape and **none is currently exposed**: the
only multi-item expectations are `DOC-005/fail` (two indented lines, but from two different fixed
blocks — `$missingKit` then `$manifestErrors`) and the `verify-kit` cases (findings appended in
fixed source order: structure, slots, constitution, record, kit-version). So this is a trap for the
next fixture author, not a defect in this one.

*Action: implementer — note it in the case-layout README so a future case with two broken paths in
two different documents, or two unclassified files, is not written with a guessed order. No change
to existing cases.*

### F6 — The phase records no verification run and no CI evidence, unlike phase 3 — MINOR

`notes.md`'s phase 4 section (lines 1060–1427) ends with the coverage record. It carries no
"verification run" entry: no full-suite result, no timing, and no CI evidence triplet — where
phase 3 has a dedicated section for each (`### The phase 3 CI result`, `### Phase 3 gate`, and the
run URLs at lines 939, 1048). The gate-3 certification legitimately lands *after* the phase commit
under `ci-held`, so its absence at review time is expected; the absence of any local full-suite
result is not, given that phase 3's own lesson was that a Windows-only verification missed a POSIX
bug that four passes had blessed.

What I can attest from my own runs: the coverage suite is 7/7 and reproduces the claimed numbers;
`cases/doc-lint` is 52/52 (58.3s) and `cases/roadmap-claim-check` is 56/56 on Windows 11 /
pwsh 7.6.6 / Pester 5.7.1. I did not run the full suite and make no claim about it. SC-007's
measured figure and SC-002's per-script mutation sample are T053 and T048, i.e. phase 6, so their
absence here is per plan.

*Action: implementer — record the phase 4 verifying run and, once CI has run on `8778c06`, both
legs' conclusions in `notes.md`, as phases 1–3 did. Owner — gate 3 for this phase is not yet
certifiable; the evidence triplet is not in the record.*

### F7 — The three new recipe states are unequally self-tested, and the reasoning is only recorded for one of them — MINOR

`nestedRepos` gets three self-tests and `<DATE>` gets three. `origin`, `detach` and `rename` get
none. For `rootSuffix` the module states the reason explicitly and it is a good one
(`Harness.psm1:120-126`: "ignoring this field makes its case FAIL loudly against the healthy
fixture, unlike a recipe state whose silent skip would produce a passing wrong answer"), and I
agree that reasoning extends to `origin`, `detach` and `rename` — a silently ignored `origin`
turns every `CLAIM` case into `n/a (no origin remote…)`, a silently ignored `detach` makes the
branch readable, and a silently ignored `rename` produces a delete-plus-add whose `SCOPE-005`
expectation would not match. But that argument is written down only for `rootSuffix`, so a reader
sees three states asserted and three not, with no stated rule.

Two smaller gaps in the `nestedRepos` tests themselves: neither asserts that the nested recipe's
own `checkout` was honoured, nor that its commits exist — a `nestedRepos` implementation that built
an empty repository on the default branch would pass all three self-tests and fail only in the
`REPOS` cases.

*Action: implementer — add one sentence to `FixtureRepo.psm1`'s header stating the rule the module
actually follows (a state whose silent omission fails its case loudly needs no self-test; a state
whose silent omission would produce a *passing* wrong answer does), and consider one assertion that
the nested repository's `checkout` landed. Optional.*

### F8 — Two internal descriptions in the diff are inaccurate — DOC DRIFT

Both are small, both are in text this phase wrote to explain itself, and this feature's whole
argument is that a record nobody checks drifts.

1. `emission-idioms.json`, top-level `_comment`: *"doc-lint.ps1's was NARROWED, because **three**
   of its 'ERROR:' lines are the PRINTERS for accumulators already counted above them."* The old
   pattern `Write-Host\s+"ERROR` matched three lines (`:228`, `:233`, `:247`), but only **two** are
   printers; `:228` (`ERROR: kit incomplete`) is a genuine condition and is **kept** in the new
   declaration. The per-script `doc-lint` note gets this right and names exactly two — so the file
   contradicts itself. The commit message repeats the wrong version ("8 counted three printers").
   The real arithmetic: 8 → 7 is two printers removed and one previously-invisible condition
   (`:243`, the `${level}:` line) added.
2. `tests/enforcement/cases/roadmap-claim-check/CLAIM-007/pass/recipe.json`, `description`: *"The
   same row flipped off 'idea'. Differs only in one cell (plan D10)."* `diff` of the two recipes
   shows the row changes in **all four cells**: `| 011-thing — roadmap claim check | idea | — | — |`
   becomes `| Roadmap claim check | in progress | anas.m | \`specs/011-thing/\` |`. The claim
   substring even moves from the Item cell to the Spec cell. The case still tests the right rule
   (`roadmap-claim-check.ps1:114` matches the row by `-like "*$claim*"` anywhere in the line, and
   `:117` reads the Status cell), and a regression in the matching would surface as `CLAIM-006`'s
   message rather than a silent pass — but the description asserts a minimality the file does not
   have, and `CLAIM-007` is one of the two cases the commit message cites as proof of the
   hand-written discipline.

*Action: implementer — correct the `_comment` sentence in `emission-idioms.json` to "two of its
'ERROR:' lines", and correct `CLAIM-007/pass/recipe.json`'s description to say what actually
differs. Both are inside `tests/**`, so either a follow-up commit on this branch or a phase 5/6
fix is lawful.*

### F9 — The `verify-kit.ps1` defect is "proposed as a GAP" but not yet recorded anywhere a process reads — MINOR

The commit message ends the defect report with "Proposed as a GAP." `notes.md` carries the full
story at lines 1258–1307. Neither is a ledger: `docs/roadmap.md` is outside this phase's Territory
and correctly untouched, so the finding currently lives only in a phase record. This kit's own
field-feedback discipline is that a defect found by use gets a row; feature 014's GAP-019 and this
feature's GAP-025/026/027 all came through that route. A defect that makes the adoption doctor
return different verdicts on Linux and Windows for the same `kit-adoption.json` — reaching three
adopted projects that consume `scripts/` verbatim — is not a note-only item.

*Action: owner — promote the `-notmatch`/`-cnotmatch` finding to a roadmap GAP row (and decide
whether the one-character fix rides phase 5, whose Territory already includes several
`scripts/*.ps1` but not `verify-kit.ps1`, or its own commit). Nothing to change in this phase.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None.** Verified, not assumed:

- `specs/015-enforcement-assurance/spec.md` — **not in the commit**. `git show --name-only
  --format= 8778c06 | grep spec.md` returns nothing.
- `specs/015-enforcement-assurance/plan.md` — **not in the commit**. Same evidence. Every decision
  this phase relies on (D1, D9, D10, D12) is graded as written, unchanged.
- `specs/015-enforcement-assurance/contracts/` — does not exist for this feature.
- `specs/015-enforcement-assurance/tasks.md` — in the commit, **checkbox ticks only**. The full
  diff hunk is nine lines, each changing `- [ ] T0NN` to `- [x] T0NN` for T028–T036, with the task
  text, the Territory block and every surrounding line byte-identical. I read the hunk in full
  rather than the `+18/-…` stat. This project has ruled that checkbox state is progress and not an
  amendment — commit `c5fcdc5`, subject *"docs: tick T020 and T025 - checkbox state is progress,
  not amendment"*, which I read directly (`git show --stat c5fcdc5`: one file, 2 insertions,
  2 deletions). `6e50608` records the same ruling for T019a. The ruling is consistent with
  constitution I, which governs changes to the *content* of an approved document; a tick records
  that the approved task was done, it does not restate the task.
- `specs/015-enforcement-assurance/notes.md` — in the commit, +409 lines, all appended under a new
  `## Phase 4` heading. `notes.md` is the phase evidence record, not an approved specification
  document (`tasks.md` header: *"Phase evidence … goes in `notes.md`, never here"*), so it is not
  an amendment surface. No earlier phase's notes were edited — the diff is pure append below
  line 1060.

No approver line is therefore required or missing, and the standard this phase is graded against
is the one the owner approved.

## Constitution re-check (post-implementation)

**PASS**, re-evaluated against the code as built.

- **I. Specification First** — satisfied. `spec.md`, `plan.md`, `tasks.md` all predate the phase
  and are unamended by it (see Amendments). T028–T036 are implemented as written, including T028's
  re-opening, which is *more* work against the approved task rather than a redefinition of it.
- **II. Source of Truth** — satisfied. No conflict surfaced. Where the phase departs from a prior
  position it says so in writing (the `doc-lint` narrowing, the T028 reversal) rather than
  silently re-measuring. F8 records two places where that writing is inaccurate, which is drift
  inside the record, not a conflict between rungs.
- **III. Repository Separation** — N/A. The kit is a single governance repository with no
  `codeRepos`; `scope-check-repos.ps1` reports `n/a` here by design, and the `nestedRepos` fixture
  state exists precisely so that the multi-repo rules can be tested without the kit becoming
  multi-repo.
- **IV. Architecture Consistency** — satisfied. No new dependency and no architectural change:
  `Run-Tests.ps1` is untouched, Pester remains the single D2-approved package, and the three new
  recipe states plus three new command flags are extensions of the D1 recipe format the plan
  already approved.
- **V. Domain Invariants** — N/A. The kit declares no domain-invariants pack
  (`{{DOMAIN_INVARIANTS_PATH}}` is an unfilled slot in the template).
- **VI. Security** — satisfied. No secrets, no network at run time (the one new remote is a local
  filesystem path), fixture-local git identity, temp-scoped repositories, and the working tree of
  the repository under test is unmodified after my runs (`git status --short` empty).
- **VII. External Integration Governance** — N/A. No external integration.
- **VIII. Testing Requirements** — this phase *is* the principle being discharged. Engaged fully.
- **IX. Human Review** — engaged as designed: this fresh-context review satisfies gate 5 for the
  phase; gate 6 remains owed once at merge over the full feature diff.
- **X. Controlled Delivery** — satisfied. One approved phase (T028–T036), nothing unrelated
  bundled, independently revertible (see the Rollback row), `phase 4` token present in the subject
  so `scope-check` can attribute it, and `ci-held` certification declared in `plan.md` before the
  first phase. **Nuance versus the plan-time check**: the plan's phase-sizing note called phases 3
  and 4 "bulk fixture work"; at +20,274 lines this is by far the largest phase, but it is data —
  128 case directories and 116 inventory rows — with 230 lines of executable change across the two
  modules and the self-tests. The sizing rule asks for one meaningfully independent, testable,
  revertible slice, and it is one. **Second nuance**: T028 was re-opened and redone inside this
  phase rather than raised as a separate remediation. That is the right call (it was a defect in
  phase 3's *measurement*, not in phase 3's committed behaviour, and re-measuring is what T036
  asks for), but it means phase 3's recorded `49 of 94` reading is superseded and the phase 3
  review's coverage numbers no longer describe the branch.

## Test coverage observed

**`tests/enforcement/Coverage.Tests.ps1`** — 7 tests, all asserting. Run in isolation, 7/7 green in
2.52s. Four are integrity assertions that bite today: every rule's `emitAnchor` still appears in
its script (stale-rule guard); every anchor matches exactly `siteCount` precise sites (the
ambiguity guard phase 3 added — this is the one that makes the 177 credible, because without it a
loose anchor could claim two sites for one fixture); every rule has both a `pass` and a `fail`
`command.json`; every case directory maps to an inventoried rule. Two assert the idiom declaration
is complete and that an empty declaration says `UNDECLARED` in writing — the latter is now vacuous,
since no script is undeclared. One reports the coverage figure and asserts only
`$AllSites.Count | Should -BeGreaterThan 0`, per D9.

**`tests/enforcement/Cases.Tests.ps1`** — one `Describe` per case directory, two `It`s each (exit
code, full output). 358 case directories × 2 = 716 assertions across 173 rules; 173 rules have
both directions and three (`AMEND-001` with 12, `PROV-002` and `PROV-004` with 3) carry extra
named directions from phase 3. I ran 30 of them (`cases/doc-lint` 14, `cases/roadmap-claim-check`
16) plus one `territory-check` case driven directly: all green. The critical assertion is not the
count but the shape — `expected.txt` is compared as **full normalised output**, so a case cannot
pass while a second, unintended condition also fires. `DIGEST-008/fail` is the clean illustration:
its expectation ends `RESULT FAIL (1 issue(s))`, which would break if the enlarged pass-side recipe
divergence (F2) had introduced a second issue.

**`tests/enforcement/Harness.Tests.ps1`** — 20 tests (14 before this phase, 6 new), all green in my
runs. The new six are real assertions, not smoke: the three `nestedRepos` tests each fail against
the specific degradation they were written for (see the evidence table), and the three `<DATE>`
tests pin the boundary in both directions — an instant with any of three offset spellings is
replaced, a bare calendar date is not, and a line carrying both a sha and an instant gets both
substitutions. I checked the ordering question the brief raised: `<DATE>` before `<SHA>` is not
strictly required for git's `%cI` output (the `\b[0-9a-f]{7,40}\b` pattern cannot cross the `T` or
the `-`), but it *is* required for a fractional-second instant with no trailing offset, where the
7+-digit fraction would otherwise be eaten as a sha. The ordering is correct and the pattern cannot
swallow a calendar date, a version number or a duration — only one expectation in the whole suite
uses `<DATE>` (`REPOS-027/fail`) and no recipe pins a date-with-time, so nothing legitimate is at
risk.

**Not observed**: the full suite (≈50 min, deliberately not run), the `ubuntu-latest` leg, and any
mutation sample for this phase's scripts (SC-002 sampling is T048, phase 6; and the review brief
forbids modifying `scripts/`, so I could not run one myself). Coverage of the *harness* remains
review-only by design (plan, Testing Strategy: "there is no meta-harness").

## Residual risk

The risk concentrates in one place and it is F1: the coverage number is now the artifact the rest
of the feature leans on, and the recall pass that is supposed to audit it cannot see the register
the denominator just absorbed. Everything else this phase did makes the number *more* honest — the
`scope-check` widening, the `verify-kit` widening, the `doc-lint` narrowing, the ambiguity
assertion inherited from phase 3 — and I verified each of those independently. But one condition
(`doc-lint.ps1:236`) sits outside both passes, and the report says `7 of 7`. T044 is where that
matters: a blocking assertion built on this report would go green one condition short, and the
phase's own notes enumerate eight uncovered sites when there are nine.

Second-order risk sits with F4 and F6 together. SC-006 is the criterion this feature has already
been burned by once, phase 4 adds three fixture states whose platform behaviour I could inspect but
not execute, and the phase record carries no CI evidence. The inspection was reassuring — `origin`
builds a plain path rather than the `file://` URI that broke phase 3, and the only symlink exposure
is on a temp layout `ubuntu-latest` does not have — but reassurance is not the ubuntu leg.

Before merge (gate 6, once, over the full feature diff): F1 resolved or explicitly deferred with
the owner's decision recorded; F2 settled one way or the other, since it is a plan decision being
observed in the breach; F8's two inaccuracies corrected, because this feature's argument is that an
unchecked record drifts and both are in records this phase wrote about itself; F9 promoted to a
roadmap row, since the `verify-kit` case-sensitivity defect reaches three adopted projects through
a script they consume verbatim. Before the phase can be called done: the CI evidence triplet on
`8778c06` and the owner's recorded approval — gate 3 under `ci-held` is not satisfied by anything
in the record today, and nothing in this review certifies it.
