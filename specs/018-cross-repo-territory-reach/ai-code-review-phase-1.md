# AI Code Review — 018 Cross-repo Territory Reach (Phase 1)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-11
**Branches**: agentic-sdlc-kit `018-cross-repo-territory-reach` (phase-1 commit `61cf36b`, parent `282beb9`)
**Scope reviewed**: `git show 61cf36b` in full (7 files: `scripts/adoption-lib.ps1` +56,
`scripts/scope-lib.ps1` +38, `scripts/scope-check-repos.ps1` net -22, `tests/enforcement/Coverage.Tests.ps1`,
`tests/enforcement/rules.json`, `notes.md` +47, `tasks.md` T001-T005 ticks). Read for context: `spec.md`
(FR-003, FR-005), `plan.md` (D1, Phase 1, Testing Strategy), `research.md` (R1, R3), `data-model.md`
("Declared code repositories"), `tasks.md` Phase 1 and its Territory block, `notes.md` Phase 1 section,
`CLAUDE.md`, the parent `scripts/scope-check-repos.ps1` (decoded as UTF-8), the current
`adoption-lib.ps1`, `scope-lib.ps1`, `scope-check-repos.ps1`, `verify-kit.ps1:215-252`,
`Coverage.Tests.ps1` in full, `emission-idioms.json` (scope-check-repos entry), the code-repo workflow
template, `kit-manifest.json`, and the 017 phase-4 review for style.
**Feature contract**: phase 1 = T001-T005, a refactor with no change in behaviour. Territory:
`scripts/adoption-lib.ps1`, `scripts/scope-lib.ps1`, `scripts/scope-check-repos.ps1`, `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-sonnet-5-5 (the implementing session)
- **Inputs provided**: commit `61cf36b` (`git show --stat` and the full diff of the three scripts, the
  two harness files and the feature's notes/tasks); the 018 feature documents (`spec.md`, `plan.md`,
  `research.md`, `data-model.md`, `tasks.md`, `notes.md`); the kit's law (`CLAUDE.md`, the review
  template); the 017 reviews for style; read and run access to the working tree. No repository file
  other than this review was modified. Scratch directories under the session scratchpad, two throwaway
  git worktrees (the parent commit, and `61cf36b` for two mutation probes) were created and removed.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE WITH FOLLOW-UPS (no Blocker, no Major).** The refactor does what it says. I could not make the
extracted `Get-CodeRepos` differ from the original `Get-DeclaredRepos`, in returned repositories or in
printed bytes, over 30 record shapes, and `Get-RepoMergeBase` agrees with the original inline loop over
9 repository situations. The three suites match the baseline exactly (157 / 265 / 65 tests, 0 failed), the
commit stays in Territory, no approved document was amended, and the `anchorFile` harness change cannot
pass vacuously (mutation-tested). What remains is small and mostly honesty of text: three comments assert
more than is true at this commit (F1), the harness change narrows the recall sweep's reach by exactly the
code that moved (F2), two stale labels (F3, F7), one inaccurate doc comment (F4), a pre-existing
wildcard-path fail-open the new shared reader will hand to phase 3 (F5), semantics of `Unusable` that
phase 3 must not over-trust (F6), and a T005 record shorter than T005 asks for (F8). Everything but F5/F6
can be fixed inside phase 1's Territory; none is a reason to hold the phase. The owner's gate has not been
reported and nothing here claims it.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Scope | `pwsh -File scripts/scope-check.ps1`: `PASS phase 1 commit 61cf36b (7 file(s))`. Paths: the three scripts, `tests/**`, the feature's own `notes.md`/`tasks.md` |
| Amendment authority (constitution I) | `git show 61cf36b -- specs/`: `tasks.md` is five `[ ]`→`[x]` ticks and nothing else; `notes.md` is an added section. `spec.md`, `plan.md`, `contracts/`, `data-model.md`, `research.md` untouched. Clean |
| Parity, `Get-CodeRepos` vs `Get-DeclaredRepos` | Parent function extracted verbatim from `git show 282beb9:scripts/scope-check-repos.ps1` (bytes, not console text), new `Get-DeclaredRepos` + dot-sourced `adoption-lib.ps1`, each run in a child `pwsh` under `$ErrorActionPreference = 'Stop'` with the script's own `Write-Line`. Compared printed text AND returned values (count, items, types), case-sensitively. **30 shapes, 0 differences**: normal, UTF-8 BOM, CRLF, 5000 entries, 20 mixed legal/illegal entries (`a.b`, `..`, `...`, `.`, `a b`, `é`, `a/b`, `a\\b`, `C:`, `x:y`, empty, null, 0, false, `..a`, `a..`, embedded newline), array inside array, `CodeRepos` in other case, both cases (PowerShell's duplicate-key error), duplicate `codeRepos` keys (last wins), trailing comma, comments, root `null`, empty file, whitespace-only, array root (members enumerate: returns `a`), string root, number root, string value, object value, empty array, null value, absent key, one entry, invalid UTF-8, UTF-16 without BOM, a directory named `kit-adoption.json`, no file, 5000-deep nesting, numeric entries, object entries. No exception in either side for any shape. The em dash survives in both (UTF-8 decode confirmed; no mojibake) |
| Parity, trunk resolution | Old inline loop vs `Get-RepoTrunkCandidates` + `.Base` over real scratch repositories: `main`+feature; `-BaseRef main`; `-BaseRef` naming nothing; ref that does not exist; `master` only; `main` is an orphan (no shared history) and `master` shares: both resolve `master`; only an orphan trunk; no candidate at all (`develop`); `origin/main` via a clone. 9 of 9 identical, including the candidate list that goes into the `UNGRADED could not resolve a merge base with a trunk (...)` message (`$candidates` is still defined in the script, line 358, and still what line ~363 joins). `Base` is a `[string]` (trimmed), never an array; `Tried`/`Existing` are arrays even for one element |
| Dot-sourcing | `adoption-lib.ps1` has no top-level statement at all: comments and three `function` definitions (`Get-DeveloperMode`, `Get-CriticalSurfaces`, `Get-CodeRepos`). No variable, no `Set-StrictMode`, no `$ErrorActionPreference`, no `Set-Location`, no output on load. No function name collides with `scope-lib.ps1` or `scope-check-repos.ps1`. `Get-CodeRepos` reads `$ErrorActionPreference` dynamically (the script's `Stop`), as the original did |
| Presence of the library where the scope check runs | `kit-manifest.json` has `{ "path": "scripts/*.ps1", "class": "verbatim" }`, so `adoption-lib.ps1` ships and updates with the script. `.github/workflows/code-repo-scope-check.yml.template` copies nothing: it checks out the governance repository (full history) as `governance`, nests the code repository in it, and runs `./scripts/scope-check-repos.ps1` with `working-directory: governance`, i.e. from a complete scripts directory. No standalone-copy path exists. (A project that updated only `scope-check-repos.ps1` by hand would now fail at dot-source; same exposure as `scope-lib.ps1` since 012.) |
| Return shapes | `Get-CodeRepos` returns a hashtable (not enumerated), `Repos`/`Warnings` always `@()`-typed (never `$null`, never a collapsed scalar); `Get-RepoMergeBase` likewise. `Get-RepoMergeBase -Ref ''` fails at parameter binding (Mandatory); unreachable from the scope check, whose `$Branch` is non-empty and `^\d{3}-` by the time the loop runs |
| PowerShell version | Kit scripts are PowerShell 7: `scope-check-repos.ps1` already uses `?:` (lines 198, 212, 271 and others), CI and `CLAUDE.md` run `pwsh`; no `#requires`. The new code uses nothing beyond 5.1 (hashtables, `-isnot [Array]`, `*> $null`); the files carry no BOM and the em dashes were already there in the parent, so 5.1 is no worse than before |
| Harness, targeted | `-Case REPOS-` 62 cases, **157** passed, 0 failed; `-Case SCOPE-` 116 cases, **265** passed; `-Case TERR-` 16 cases, **65** passed. Parent worktree `-Case REPOS-`: 157 passed. All equal the baseline in `notes.md` |
| Coverage numbers | Parent: `coverage: 210 of 221 declared emission site(s) owned by a fixtured rule, 7 exempt, 4 declared not a rule`; `scope-check-repos.ps1  31 of 32 site(s) fixtured (1 exempt)`. This commit: `207 of 218`, `scope-check-repos.ps1  28 of 29`. The three sites left numerator and denominator together; the figure is not flattered (95.02% to 94.95%). The loss of reach is in F2 |
| `anchorFile` can not pass vacuously | Mutation in a throwaway worktree of `61cf36b`: the `WARN kit-adoption.json is not valid JSON` line of `adoption-lib.ps1` turned into a comment. Result: `-Case REPOS-002` failed two tests: the case (`prints the expected output`) and `every anchor names exactly the emission sites its rule declares` with `REPOS-002: anchor matches 0 line(s) of adoption-lib.ps1, declared 1`. The first test (`ReadAllText`, comments included) stays green on a quoted comment, which is why the second exists; together they do not let a deleted or commented-out message through |
| Gate suites | `pwsh -File scripts/doc-lint.ps1`: exit 0, `OK — kit complete, every referenced path resolves`. `pwsh -File scripts/ritual-checks.ps1`: `RESULT OK` (doc-lint OK, enforcement-pack OK, scope-check OK, scope-repos n/a, digests OK, roadmap-claims OK, verify-kit n/a) |
| Gate honesty | `notes.md` Phase 1 claims counts and a direct comparison; it never says the gate passed or is certified. Clean |
| Rollback safety | Phase touches no data, adds no package; reverts as one commit (the readers move back; `rules.json`'s three `anchorFile` lines and the two test edits revert with it). Clean |

## Findings

### F1 — Three comments assert more than is true at this commit — MINOR

`scripts/scope-check-repos.ps1:64` says `# the one reader of codeRepos`. `scripts/adoption-lib.ps1`
(the `Get-CodeRepos` header) says "One reader, read by every script that has to walk them:
scripts/scope-check-repos.ps1 grades their commits and scripts/territory-check.ps1 compares their
branches". Two facts contradict that today. `scripts/verify-kit.ps1:230-250` still validates `codeRepos`
on its own, with the same regular expression and its own wording, and it already dot-sources
`adoption-lib.ps1` (line 42); and `territory-check.ps1` calls nothing from this library until phase 3.
The header is the very sentence the library's own description warns about ("a comment asserting the two
copies matched exactly"). The code is right (the regular expressions are character-identical and spec
FR-003 only requires that the territory check not carry a second reading); the comments overclaim.
*Action: author reword in phase 1: "the reader the scope check uses (the doctor still validates the
record separately, `verify-kit.ps1`)" and "territory-check.ps1 will read it in feature 018 phase 3", or
delete the territory-check clause until then. Making `verify-kit.ps1` read through `Get-CodeRepos` is NOT
in phase 1's Territory and not in the approved plan; it is an owner decision, offered, not required.*

### F2 — The recall sweep and the denominator no longer see the code that moved — MINOR

`Get-ScriptSites` scans only the scripts named in `emission-idioms.json`. The three `WARN` messages now
live in `adoption-lib.ps1`, which is not scanned, and the line that prints them in the scope check
(`scope-check-repos.ps1:77`, `foreach ($w in $declared.Warnings) { Write-Line $w }`) matches neither the
precise idiom (`Write-Line\s+['"]...`) nor the recall sweep. So a fourth message added to
`Get-CodeRepos` is owned by nothing and flagged by nothing. Demonstrated: in a worktree of `61cf36b` I
added `$result.Warnings += 'WARN a brand new unfixtured message'` to `Get-CodeRepos`; every
`Coverage.Tests.ps1` test stayed green and the coverage line was unchanged (`207 of 218`); only the
REPOS-002 case's expected output went red, and only because that fixture happens to run the reader. A
message in a branch no existing fixture reaches would pass entirely. Before the move the idiom would have
counted it. `anchorFile` pins the three known messages; it does not bound the library's emission set.
*Action: author, inside `tests/**`. Cheapest sound fix: one test line in `Coverage.Tests.ps1`: the
non-comment `Warnings +=` lines of every library file named by an `anchorFile` must equal the sum of the
`siteCount`s of the rules naming it, so an unowned fourth message fails by name. (An alternative, adding
`adoption-lib.ps1` to the idiom scan, drags the two other readers' emissions into the denominator and
needs `notRules` entries for them; the one-test fix is smaller and measures the same thing.)*

### F3 — `rules.json` `function` fields and the idiom note are stale — DOC DRIFT

`rules.json:856, 866, 876` still say `"function": "Get-DeclaredRepos"` for REPOS-002/003/004; the emitter
is now `Get-CodeRepos` (`Get-DeclaredRepos` only forwards). The field is informational (nothing in
`tests/` reads it; confirmed by search). `emission-idioms.json`'s scope-check-repos note says "Everything
goes through one Write-Line wrapper... the VERDICT WORD the message opens with"; three of those messages
now arrive through `Write-Line $w` with their text in a library, which the note does not say.
*Action: author, inside `tests/**`: set `function` to `Get-CodeRepos` and add one sentence to the idiom
note pointing at `anchorFile`.*

### F4 — `Existing` is documented as the full set, and on success it is only a prefix — MINOR

The `Get-RepoMergeBase` comment says `Existing  the candidates that exist in the repository at all`. The
function returns at the first candidate that yields a merge base, so on success `Existing` holds only the
candidates up to and including the trunk used. Observed: a clone with both `origin/main` and `main`
returned `Existing=origin/main`. For the stated use (phase 3 reads it only when `Base` is `$null`, to tell
"no trunk" from "this ref has no merge base") it is correct, because the loop has then visited every
candidate; but T003 says "a separate way to ask whether any candidate exists at all", and a later reader
who takes the comment at its word on the success path will be wrong. `Existing` also cannot tell a ref
that does not exist from a ref sharing no history with the trunk; the comment does not claim it can.
*Action: author reword: "the candidates found to exist before it resolved (all of them when nothing
resolved)", or keep looping and return the full set. Either is inside Territory.*

### F5 — `Get-CodeRepos` fails open on a governance path containing `[` and `]` (inherited, now shared) — CONFIRM

`Get-CodeRepos` copies the original's `Test-Path $recordPath` and `Get-Content -Path`, both wildcard
interpreting. Demonstrated: a root named `proj[1]` holding `{"codeRepos":["a"]}` returns `Repos=` (empty),
`Unusable=False`, no warning: the record is read as absent. Not a regression (the original did exactly
this, and the scope check reports `n/a`), and `Get-DeveloperMode`/`Get-CriticalSurfaces` use
`-LiteralPath`. It matters now because phase 3 will treat "no repositories declared" as "governance
alone, `CLEAN`" (data-model.md), so the shared reader hands the territory check a silent blind spot the
scope check has always had. Changing it moves scope-check behaviour (`n/a` becomes grading), so it cannot
ride in a "no change in behaviour" phase.
*Action: owner decision. Either record it as a known limit in `notes.md` for phase 3's T016 conversation,
or approve switching both calls to `-LiteralPath` (REPOS-* fixtures would show nothing moves) in phase 3.
Not a phase 1 fix.*

### F6 — What `Unusable` does and does not mean — NOTE

`Unusable` is true in exactly the three cases its comment lists (unparseable or unreadable file,
non-array, any rejected entry); I checked each, including a directory named `kit-adoption.json` (true).
It is false, silently, for: a root that is `null`, a string or a number; an array root (the members
enumerate, so `[{"codeRepos":["a"]}]` returns `a`); and entries that `Where-Object { $_ }` drops
(`""`, `0`, `false`, `null`). A numeric entry (`[1]`) is accepted as a directory named `1`, although
`data-model.md` lists "a non-array entry" as unusable. All of it is parity with the original and with
`verify-kit.ps1`. The header phrase "present and could not be read in full" is broader than the code; a
phase-3 author reading only that will believe `{"codeRepos":[""]}` ungraded when it is `CLEAN`.
*Action: none required for phase 1. Phase 3 (plan D5) should decide whether these are unusable, which
would be a behaviour change to the shared reader and so an owner-approved one; meanwhile tighten the
comment to the three listed cases.*

### F7 — The library's header still names two consumers — DOC DRIFT

T002 says "update the file's header". The SYNOPSIS was; the DESCRIPTION still reads "Dot-sourced by
scripts/enforcement-pack.ps1 (which enforces) and scripts/verify-kit.ps1 (which reports)". The scope check
is a third consumer as of this commit.
*Action: author, one clause.*

### F8 — T005's direct record is thinner than T005 asks — MINOR

T005: "call `Get-CodeRepos` directly on throwaway records ... and record what it returns in `notes.md`".
`notes.md` records that the original and new paths agreed on 21 records and states the `Unusable`
semantics in prose; it does not record what `Get-CodeRepos` returned for any record (`Repos`,
`Warnings`, `Unusable`), and the comparison it describes went through `Get-DeclaredRepos`, not the new
function's own result. The 21 figure is not checkable from the notes (the list reads as about 22 items).
The account of the mojibake incident is credible and the lesson sound (the parent source decoded through a
legacy code page would corrupt the em dash on one side); I could not reproduce the cause, since this
session's console is UTF-8, and the closing sentence about why "the owner's console shows `ΓÇö`" is an
unmeasured claim. Phase 1 introduces no claim that the gate was run.
*Action: author adds the small table (shape, `Repos`, `Warnings` count, `Unusable`) to the Phase 1
section, and either drops or labels as inference the owner's-console sentence.*

### F9 — `anchorFile` harness change: judged sound, with the limits stated — ACCEPTED

Read both edits. (a) *Existence test*: `ReadAllText` over the anchor file, so a comment quoting the
message satisfies it; the exactness test closes that (mutation above). (b) *Exactness test*: counts
non-comment lines containing the anchor and requires `siteCount` (default 1). It cannot let a rule escape
"exactly the emission sites" in the sense the precise pass means it, because an `anchorFile` rule's
emitter is by construction outside the scanned scripts (F2 is the cost). Limits, all theoretical: the
comment filter `^\s*#` treats a here-string line beginning `#` as a comment and counts a `<# #>` block line
as code; two messages on one line count once; an anchor split across lines is unfindable (equally true of
the existing mode); `anchorFile` is not validated to be a file under `scripts/` or different from `script`,
and `rules.json`'s new header says "a file under scripts/ that is not the script the case runs" as if
enforced. Nothing in the harness checks that the script the case runs actually calls the library, but the
case's expected output does (it went red in the mutation). The `rules.json` header text is accurate in
substance and the file parses (208 rules). A simpler alternative (leave the messages in the scope check
and return codes from the reader) would contradict T002's "the warning text the scope check prints today,
without its prefix" and plan D1, and still needs a second site to anchor; `anchorFile` is the smaller
change given the approved plan.
*Action: none beyond F2/F3. Optionally soften the header sentence to "by convention".*

## Checked and clean

- Message bytes: both warnings and the entry warning are character-identical (same em dash, same `'$e'`
  quoting), and now flow through `Write-Line`, so the `scope-repos: ` prefix is unchanged. Order of output
  is unchanged (nothing else prints between the reads).
- `foreach ($e in @($record.codeRepos | Where-Object { $_ }))` equals the original's two-step
  `$entries`/`foreach`; the regular expression is character-identical to the original, to `verify-kit.ps1`,
  and to the comment that cites it.
- `$result.Repos = @($clean)` and the wrapper's `return @($declared.Repos)` reproduce the original's
  one-element-array behaviour; the caller's `@(Get-DeclaredRepos ...)` is unchanged.
- No dead code left behind in `scope-check-repos.ps1` (the old reader body and the inline loop are gone; the
  `$candidates` variable is still used by the message). Performance: no added process or file read; the trunk
  loop issues the same `git` calls in the same order.
- The `-BaseRef` override, the candidate order, the `$LASTEXITCODE` handling, `"$b".Trim()` and the
  single-line `merge-base` output are preserved; `Get-RepoMergeBase` also falls back to the default list when
  handed an empty or `$null` candidate list, unreachable from the scope check (`-BaseRef` empty means the
  default list in both versions).

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly. **None.** `tasks.md` ticks only; `notes.md` additions
  only; no approved document changed.

## Constitution re-check (post-implementation)

**PASS.** I (source of truth, amendment authority): untouched. Single-reader principle (the 013/012 lesson in
the library header): advanced for the scope check and phase 3, still not complete for the doctor (F1).
Gate-claim discipline: nothing claims certification. Territory: held. No package, no architecture change, no
new file outside the feature's spec dir.

## Test coverage observed

`-Case REPOS-` 62 cases / 157 tests; `-Case SCOPE-` 116 / 265; `-Case TERR-` 16 / 65; all 0 failed, equal to the
baseline recorded from the parent. Parent `-Case REPOS-`: 157 passed, 0 failed (I did not re-run SCOPE- and
TERR- on the parent; the author's baseline is the reference and the post-change counts equal it). The three
rules that carry `anchorFile` keep their fixture pairs and still go red when the output changes. Not run, by
instruction: the full harness. Not covered: any direct unit test of `Get-CodeRepos` or `Get-RepoMergeBase`
(only through the scope check's output), which is why phase 3's TERR-* fixtures are the first to exercise
`Unusable` and `Existing` (F4, F6).

## Residual risk

Low for this phase: the behaviour is proven equal, the harness change is mutation-tested, and the commit
reverts cleanly. The risk concentrates in what phase 3 will build on: F5 (a wildcard-path blind spot that
becomes a `CLEAN`), F6 (`Unusable` is narrower than its header sentence) and F2 (an unowned fourth message in
the shared reader would not be seen). Fix F1-F4, F7, F8 in phase 1 before the gate (all small, all in
Territory); carry F5 and F6 to the owner's D5 conversation at T016.
