# AI Code Review — 017 Level Declaration Graded (Phase 3)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-11
**Branches**: agentic-sdlc-kit `017-level-declaration-graded` (phase-3 commit `7320ed9`)
**Scope reviewed**: `git show 7320ed9` in full (157 files: `scripts/enforcement-pack.ps1`,
`tests/enforcement/rules.json`, `tests/enforcement/emission-idioms.json`, 24 new fixtures under
`tests/enforcement/cases/enforcement-pack/LEVEL-001..007`, 80 edited `expected.txt`, `notes.md`,
`tasks.md`). Read for context: `spec.md`, `plan.md`, `research.md` R1/R3/R5/R7,
`data-model.md`, `contracts/level-declaration-contract.md`, `tasks.md` Phase 3, `notes.md`
Phase 2 and 3; `CLAUDE.md`; constitution X; `scripts/scope-lib.ps1`, `scripts/adoption-lib.ps1`
(`Get-CriticalSurfaces`), the pack's `Get-ConformingRecord`; the phase-1 and phase-2 reviews.
**Feature contract**: phase 3 = T013-T023 (US1, US3, US4): `Invoke-LevelSurfaceCheck`, the surface
floor. Territory: `scripts/enforcement-pack.ps1`, `tests/**`, the feature's own spec directory.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-sonnet-5-5 (the implementing session)
- **Inputs provided**: commit `7320ed9` (`git show --stat` and full diff); the 017 feature
  documents (`spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/`, `tasks.md`,
  `notes.md`); the kit's law (`CLAUDE.md`, constitution, Definition of Done, review process); the
  review template and the phase-1 and phase-2 reviews for style; read and run access to the
  working tree. No repository file other than this review was modified; about 50 scratch git
  repos were built under `$env:TEMP` (copies of `scripts/`) and removed.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**CHANGES REQUESTED (one Major, fix in phase 3).** The check is well shaped: Territory and
surface are normalised together, Critical is never graded, every unusable-record and
unreadable-Territory path is UNGRADED by name, exceptions are read from visible text and an
unapproved one never passes, and the suggested two lines work when pasted. All 12 enforcement-pack
prefixes pass with no failures. But the intersection rule has a real fail-open (F1): a surface
that ends in `/` AND contains a wildcard (`**/auth/`, `*/auth/`, `api/*/Payments/`) is compared as
a whole string, not by its literal prefix, so a Standard Territory such as `src/**` or `src/` that
plainly contains `src/auth/` comes out clean. That is the one input class where a feature that
reaches a surface passes, and no fixture uses a wildcard surface, which is why it went unseen.
Everything else is Minor or Note.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Scope | `pwsh -File scripts/scope-check.ps1`: `PASS phase 3 commit 7320ed9 (157 file(s))`. Paths are the pack, `tests/`, and the feature's own `notes.md`/`tasks.md` |
| Amendment authority (constitution I) | `git show --stat 7320ed9 -- specs/`: `notes.md` (+63) and `tasks.md` (T013-T023 ticks) only. `spec.md`, `plan.md`, `contracts/`, `data-model.md`, `research.md` untouched |
| Harness, targeted | `-Case LEVEL-`: 81 passed, 0 failed. `AMEND-` 97, `BATCH-` 49, `CERT-` 41, `CRIT-` 73, `GAP27-` 49, `LITE-` 45, `MICRO-` 69, `PACK-` 49, `PHASE-` 37, `PROV-` 57, `STRUCT-` 45: all 0 failed. `Get-ConformingRecord` default is unchanged (AMEND- is the guard) |
| The 80 edited expectations | `git show 7320ed9 -- tests/enforcement/cases/enforcement-pack`: no `-` line anywhere; every modified `expected.txt` is `1 0` in `--numstat`; the line is `LevelSurface: not armed ...` right after the header. By recipe: 20 Micro, 60 Standard (3 of them replay/002 variants); none Critical, none on a Lite or missing-spec branch |
| Fixtures vs script wording | `expected.txt` text matches the emitting strings (lines 777-838 of the pack) and the contract anchors; the three `LevelSurface: exception ...` and `not armed`/`graded` wordings agree. The Critical guard (`LEVEL-001/pass-critical`) is honest: it fails only on the Critical lane's own review |
| Not-stale `$matches` | `Invoke-LevelSurfaceCheck` (line 772): `$levelName = $matches[1]` follows `-notmatch '^(Micro\|Standard)\b'` that did NOT return, so `$matches` is from that match. Same in `Get-SurfaceExceptions` (line 733). `ConvertTo-LevelPath` runs in function scope and cannot clobber it. Only cosmetic residue: see F4 |
| Normalisation (phase 2 F6) | Verified on both sides in real runs: Territory `./src/auth/x`, `src\auth\x`, `SRC/AUTH/x`, trailing spaces: all FAIL against `src/auth/`; surface `./src/auth/` and `src\auth\` against Territory `src/auth/x`: both FAIL (reached). `Get-CriticalSurfaces` also folds `\` itself |
| UNGRADED by name (phase 2 F2) | State `unreadable` and `malformed` each add an UNGRADED line (script 756-760 range); LEVEL-003 `fail-unreadable` and `fail` pin both. Exit code stays 0 (feature 015 D6) |
| Literal vs glob directions | Surface glob against a literal file (`src/*/secret*` vs `src/a/secret.txt`): FAIL. Territory glob (`src/**/login.*`, `*`, `src/**`) vs `src/auth/`: FAIL. `[id]` brackets are literal in both directions (scope-lib D1), consistent. Glob vs glob (`src/auth/*.ps1` vs `src/**/*.md`): reached, the documented over-report |
| Phases | Territory only in a later phase, and two phases where only the second reaches: FAIL (union). `## Phase 2 - x` counts; `### Phase 2` is not a phase (same as `Get-Territory`, so no divergence from the scope check); a Phase/Territory inside an HTML comment is hidden (correct); a `**Territory**:` inside a code fence is counted (over-reports, safe) |
| Level parse | `Standard (draft)` grades as Standard; `standard` grades (message says `standard`, F4); `Critical` returns silently, no verdict change. Micro with no Territory: UNGRADED by name |
| Exceptions: cannot pass what they should not | Different case, `./` prefix, `-` vs em dash: counted, correctly (exact entry after normalisation). Broader exception (`src/auth/` for `src/auth/x`): not counted, FAIL, reported stale. An entry that merely contains the path (`x.ps1.bak`): not counted. Approval separated by prose: not counted, named. Approval dated 2099: not counted ("later than the commit's own author date"). `{{NAME}}`, `<name>`, empty: not counted, named. Approval inside an HTML comment: not counted. Exception inside an HTML comment: not counted. Two exceptions then one approval: only the second gets it, the first is named (the line is not shared). A blank line between exception and approval is allowed (documented "next non-blank line") |
| Message advice works | Filling the suggested two lines (`<reason>`, `<name>, <YYYY-MM-DD>` replaced) produces a passing run; leaving the placeholders produces "the reason '<reason>' is a placeholder". The path in the message is the entry as written, which the exact-match rule accepts |
| Robustness | No path in the new code throws: `git log -1 HEAD 2>$null` falls back to the local day; I found no input that terminates the pack. A 500-entry Territory is O(entries x surfaces) over cheap `-like`, no measurable cost |
| Reuse / drift | `Get-ConformingRecord` gains `-Pattern` defaulting to `$script:AmendmentRecordPattern` evaluated at call time; loop body otherwise byte-identical (diff is the signature and one variable). `$script:` patterns are defined before the dispatch at the bottom, so ordering is safe. `$Root` is the resolved script-scope value (line 134) and is what `Get-CriticalSurfaces` receives when `-Root` is passed |
| PowerShell version | Non-ASCII in code (`[—–]` at line 640) follows the existing precedent at line 470 (`[-–]`); `[Console]::OutputEncoding` is set at the top. The pack already runs under pwsh 7 |

## Findings

### F1 (Major) — a wildcard surface that ends in `/` is compared whole, so a containing Territory passes

`scripts/enforcement-pack.ps1:662`: `Get-LevelPathPrefix` returns the whole path first when it
ends with `/`, before it looks for a wildcard. For a surface such as `**/auth/` or `api/*/Payments/`
the "prefix" is therefore the whole pattern string, which no real Territory path starts with, so
`Test-LevelPathsIntersect` reports no overlap. Research R1 says the surface is reduced to its
literal prefix (`src/auth/**` becomes `src/auth/`); this branch does not do it for the trailing-slash
spelling.

Reproduced with real repos (Standard feature, surface in `kit-adoption.json`, Territory in
`tasks.md`; exit 0 and `0 reached` in every row):

| Surface | Territory entry | Result | Should be |
|---|---|---|---|
| `**/auth/` | `src/**` | clean | reached |
| `**/auth/` | `src/` | clean | reached |
| `*/auth/` | `src/**` | clean | reached |
| `src/*/auth/` | `src/a/` | clean | reached |
| `api/*/Payments/` | `api/` | FAIL (reached) | correct, only because `api/` is checked the other way round |

(The last row is correct only by accident: the Territory prefix `api/` happens to be a string
prefix of the whole-pattern text `api/*/Payments/`. `src/a/` and `src/**` are not prefixes of
`src/*/auth/`, and `**/auth/` starts with a wildcard, so those miss.) A Territory that is a literal FILE still fails correctly (it goes through
`Test-InTerritory`), which is why every fixture passes. Surfaces ending `/` with a wildcard in the
middle are a common spelling (`**/auth/`, `**/migrations/`), so this is a fail-open on the very
class of input the check exists for: a Standard feature declaring `src/**` can rewrite any `auth`
directory and read green.

Fix (in phase 3's scope): in `Get-LevelPathPrefix`, take the wildcard branch first, and only
return the whole path when it has no wildcard:

```powershell
$w = $Path.IndexOfAny([char[]]@('*', '?'))
if ($w -lt 0) { return $Path }          # literal directory or file: whole path
$head = $Path.Substring(0, $w); $slash = $head.LastIndexOf('/')
if ($slash -lt 0) { return '' }
return $head.Substring(0, $slash + 1)
```

Add fixtures to LEVEL-001: surface `**/auth/` with Territory `src/**` (FAIL), surface
`src/*/auth/` with Territory `src/a/` (FAIL), and a clean pair for each (`docs/**` against
`src/*/auth/` stays clean).

### F2 (Minor) — no fixture uses a wildcard surface, a `./` form, or a union of phases

All 24 fixtures use the literal surface `src/auth/` (or `api/src/Auth/`). That is why F1 passed
review of the diff and the harness. The wrong implementations they would NOT catch: a surface-side
`./` or `\` normaliser removed (phase 2 F6 is verified by me above, not by a fixture), a
matcher that only handles a trailing-slash surface, a Territory read from only the current/last
phase (union), `Test-LevelPathsIntersect` treating a pattern-vs-pattern pair as no-overlap.
Worth adding (cheap, same recipe shape): `LEVEL-001/fail-surface-glob` (F1), `fail-surface-dot-slash`
(`./src/auth/` surface, Territory `src/auth/x`), `fail-second-phase` (clean Phase 1, reaching Phase 2),
and a Micro-with-approved-exception `LEVEL-005/pass-micro`. Fixtures that ARE honest, checked
against the wrong implementation each is meant to catch: `fail-glob-prefix` (literal-only matcher),
`fail-micro` (ignoring Micro), `pass-critical` (grading Critical), `LEVEL-004/fail` (absent Territory
treated as pass), `LEVEL-003/fail-unreadable` (unreadable treated as absent), `LEVEL-007/fail*`
(unapproved or wrong-path exception counted).

### F3 (Minor) — `TODO` as an approver or a reason is accepted

`Get-ConformingRecord` (line 1268) refuses `TODO(` only, so `**Exception approved by**: TODO,
2026-01-01` counts and prints `exception live ... approved by TODO`; and a reason of `TODO` is
accepted (the reason placeholder test, line ~735, covers `[...]` and `<...>` only). The first is
inherited from the amendment check's definition (the intent of reusing it) and the second is new.
Not a bypass of review (a human approval is the control, constitution I), but the run lists an
exception as "live" that a reader would call unfilled. Fix: extend the reason check to
`^(TODO|TBD|\.\.\.)\b` and, if the owner agrees, the approver check in `Get-ConformingRecord`
(that would change the amendment check too, so it is an owner call, not phase 3's).

### F4 (Minor) — `levelName` echoes the spec's case

Line 772 uses `$matches[1]`, so `**Delivery Level**: standard` prints `declared standard ... a
standard feature may not` and `(standard)` in the roll-up. Cosmetic; the Structure check
independently judges the level's legality. Fix: `$levelName = (Get-Culture).TextInfo.ToTitleCase($matches[1].ToLower())`,
or branch on `-match '^Micro'`.

### F5 (Minor) — wording says "approved by" where only the shape of the approval is checked

`exception live for '...' — approved by <name>, <date>` (line ~810) asserts approval; the script
verified a well-formed, dated, non-placeholder line, not that the named person approved or is not
the author (constitution I holds that to review alone, and the rationale text in `rules.json` says
so). The phase-1 and 2 reviews flagged the same class of overclaim. Fix: `exception live for '...'
— approval recorded by <name>, <date> (shape checked, not verified)`; update LEVEL-005 expectations.

### F6 (Note) — an exception inside a fenced code block, or in a list item, behaves unevenly

A `**Surface Exception**:` / `**Exception approved by**:` pair inside a code fence is counted
(`Get-VisiblePlanLines` strips only HTML comments). A bulleted pair (`- **Surface Exception**: ...`)
is not recognised and nothing says why: the path simply fails, with the standard message that
shows the exact format. Both are the safe direction (the first needs a human to have written the
pair; the second fails closed). No change requested; a sentence in the contract would help.

### F7 (Note) — author-date ceiling can fail a same-day approval locally

The date ceiling is HEAD's author day (line 727). An approval dated today, written in the working
tree before the first commit that day, is "later than the commit's own author date" until it is
committed. Same behaviour as the amendment check by design (H6); the message names the date, so
it is diagnosable. No change.

### F8 (Note) — `?` in a surface is a literal in the matcher but a wildcard in `Test-LevelPathIsPattern`

Surface `src/secre?.ps1` against Territory `src/secret.ps1` is clean, because `Test-InTerritory`
escapes `?` (scope-lib D1: only `*` and `**` are wildcards). The kit's glob dialect has no `?`
wildcard, so this is consistent with the scope check, and the doctor line `1 critical surface(s)`
does not warn. Worth one sentence in `adoption/updating.md` ("`?` and `[` are literal") when the
owner next touches it. Not a defect of this phase.

## Amendments in this diff

None. No approved feature document changed (`spec.md`, `plan.md`, `contracts/`, `data-model.md`,
`research.md` untouched; `notes.md` appended, `tasks.md` ticks only). F1's fix aligns the code with
research R1 as written; it needs no document change.

## Constitution re-check (post-implementation)

Principle X, Level declaration: Critical is never failed (FR-011); Standard and Micro are failed
on a reaching Territory; a project that declares nothing sees one line and no verdict change
(FR-005, verified on the 80 unchanged-but-one-line expectations); every inability to grade is
UNGRADED by name (FR-012), with the F1 exception noted: a reaching Territory compared wrongly is
currently NOT named, which is why F1 is a Major rather than a Minor. Principle I: no approved
document amended. Principle II/VII unaffected.

## Test coverage observed

`-Case LEVEL-`: 81 passed. Existing pack prefixes `AMEND-`, `BATCH-`, `CERT-`, `CRIT-`, `GAP27-`,
`LITE-`, `MICRO-`, `PACK-`, `PHASE-`, `PROV-`, `STRUCT-`: 97, 49, 41, 73, 49, 45, 69, 49, 37, 57,
45 passed, 0 failed. I did not run the full harness. Gaps: see F2.

## Residual risk

After F1, the surface floor is still a literal-prefix over-reporter by design: glob against glob
(e.g. `src/**/*.md` against `src/auth/*.ps1`) fails and needs a written exception, which is the
documented cost. A Territory entry that is a directory written without a trailing slash (`src/auth`)
is a literal file name to the kit's matcher and does not reach `src/auth/`; the scope check treats
it identically, so it cannot authorise a commit into the directory either. A Territory that
the author writes truthfully but incompletely is outside any static check (the scope check holds
the commit against it). The approver's identity is a recorded string, never verified.
