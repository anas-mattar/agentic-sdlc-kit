# AI Code Review — 015 Enforcement Assurance (Phase 2)

**Reviewer**: fresh-context agent — claude-sonnet-5
**Date**: 2026-09-19
**Branches**: agentic-sdlc-kit `015-enforcement-assurance` (tip `c5c7e268c32f1bcc05f461d2495ed01b38c56cc9`)
**Scope reviewed**: commit `c5c7e26` in full (30 files: `scripts/build-digests.ps1`,
`scripts/enforcement-pack.ps1`, new `scripts/markdown-lib.ps1`, `scripts/scope-check-repos.ps1`,
`scripts/scope-check.ps1`, `scripts/scope-lib.ps1`, `specs/015-enforcement-assurance/notes.md`,
`specs/015-enforcement-assurance/tasks.md`, `tests/enforcement/README.md`, all 18 fixture files
under `tests/enforcement/cases/{build-digests/DIGEST-001,scope-check/SCOPE-001,scope-check/SCOPE-002}/**`,
`tests/enforcement/lib/Harness.psm1`, new `tests/enforcement/lib/RunChild.ps1`,
`tests/enforcement/rules.json`); the amendment commit `06b1b30` in full; phase 1 commits `4aab0e3`
and `c488560` read for context (not re-reviewed — already gated). Also read: `spec.md`, `plan.md`,
`tasks.md`, `notes.md` for this feature; `.specify/memory/constitution.md`; `CLAUDE.md`;
`docs/sdlc/definition-of-done.md`; `docs/sdlc/review-process.md`; `kit-manifest.json`;
`scripts/territory-check.ps1`; `specs/014-amendment-authority/tasks.md` (full history, to check
the decorated-marker claim against the kit's own live governance data). Independently run:
`pwsh -File tests/enforcement/Run-Tests.ps1` (full and per-case), `pwsh -File
scripts/ritual-checks.ps1`, six mutation experiments against `scripts/build-digests.ps1`,
`scripts/scope-lib.ps1`, `scripts/scope-check.ps1` and `tests/enforcement/lib/RunChild.ps1` (all
reverted; working tree confirmed clean with `git status --short` after each and at the end).
**Feature contract**: T013–T019 only — close GAP-025 (`build-digests.ps1` comment-in-code-span
fail-open), GAP-026 (`Get-Territory` decorated-marker fail-open) and FR-015 (undeclared Territory
must FAIL, not WARN, when a sibling phase declares); move three Markdown-visibility helpers to a
new shared `scripts/markdown-lib.ps1`; add `tests/enforcement/lib/RunChild.ps1` to fix a UTF-8
harness defect found along the way. Declared Territory (as amended by `06b1b30`): `tests/**`,
`scripts/build-digests.ps1`, `scripts/scope-lib.ps1`, `docs/digests/*-digest.md`,
`scripts/markdown-lib.ps1`, `scripts/enforcement-pack.ps1`, `scripts/scope-check.ps1`,
`scripts/scope-check-repos.ps1`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5
- **Implementer**: claude-opus-5 (implementing agent session)
- **Inputs provided**: commit `c5c7e26` (`git show --stat` and full diff); commit `06b1b30` in
  full; phase 1 commits `4aab0e3` and `c488560` for context; `spec.md`, `plan.md`, `tasks.md`,
  `notes.md` for `specs/015-enforcement-assurance/`; the kit's law
  (`.specify/memory/constitution.md`, `docs/sdlc/definition-of-done.md`,
  `docs/sdlc/review-process.md`, `CLAUDE.md`); read/run/write access to the working tree
  (mutation testing, reverted).
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES.** GAP-025, GAP-026 and FR-015 are each genuinely closed for the shapes their
own fixtures exercise, test-first as D11 requires: I reverted each fix in turn
(`build-digests.ps1`'s disarm call, `scope-lib.ps1`'s decorated-marker regex, `scope-check.ps1`'s
FR-015 branch) and watched the matching fixture fail every time, then restored and watched all 30
tests go green again. The `markdown-lib.ps1` move is byte-identical to what `enforcement-pack.ps1`
carried at `c488560` — diffed programmatically, not eyeballed. The amendment `06b1b30` is
well-formed and lands before the phase commit it authorizes. But the new shared test launcher this
phase ships, `tests/enforcement/lib/RunChild.ps1`, has a real and reproducible fail-open of its
own: when the target script's parameters fail to bind (a plausible, easy-to-hit authoring mistake
in a `command.json`, not a contrived scenario), `RunChild.ps1` reports **exit code 0** — a false
PASS — even though the script under test never ran. I reproduced this against the real
`build-digests.ps1`, not just a synthetic stand-in. Every future fixture (phases 3–6, on the order
of 80 more rules) routes through this exact launcher, so this is a fail-open in the harness's own
new infrastructure, of precisely the species this feature exists to close (FR-008, D10, the
spec's own "Edge Cases" entry on a fixture that passes because the check never ran). It should be
fixed before phase 3 builds more fixtures on top of it. Two secondary findings — a still-open
variant of GAP-025's defect class for multi-line code spans, and a still-unmatched decorated
Territory marker already live in the kit's own history — are lower severity and can go forward as
CONFIRM/tracked follow-ups rather than blocking this phase.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FR-013, FR-014, FR-015 implemented as specified) | Read `Get-DocMarkers` (`scripts/build-digests.ps1:76-140`), `Get-Territory`/`Test-AnyTerritoryDeclared` (`scripts/scope-lib.ps1:71-131`), and the new FR-015 branches in `scripts/scope-check.ps1:225-232` and `scripts/scope-check-repos.ps1:253-260`. Ran `pwsh -File tests/enforcement/Run-Tests.ps1` — **30 passed, 0 failed** (matches the commit message and `notes.md`). Ran `pwsh -File scripts/ritual-checks.ps1` — `RESULT OK`, `digests: OK (5 digest(s) fresh, 80 marker(s))`, `scope-check: PASS phase 2 commit 06b1b30 (1 file(s))`, `scope-check: PASS phase 2 commit c5c7e26 (30 file(s))`. |
| Visual-reference match | N/A — no UI in this phase, no visual references for this feature. |
| Feature contract held (no unapproved table/migration/permission/package) | No new package; Pester 5 is D2's approved dependency, unchanged this phase. `kit-manifest.json` untouched by this commit — confirmed `scripts/*.ps1` is already classed `verbatim` as a glob, so `markdown-lib.ps1` (and `scope-lib.ps1` before it) needs no separate manifest entry; not a gap. |
| Constitution / domain invariants | Constitution I (Amendment authority): amendment `06b1b30` verified — see "Amendments in this diff" below. No domain-invariants pack declared for this kit repository (N/A, as plan.md states). |
| Security (authn/authz, secrets, sensitive logging) | No secrets, no network, no new external surface. `RunChild.ps1` builds a PowerShell command line from `command.json` data (repository-controlled, not runtime-external) — see F1 for a correctness (not security) concern about how that reconstruction fails. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | `scope-check: PASS phase 2 commit 06b1b30 (1 file(s))` and `scope-check: PASS phase 2 commit c5c7e26 (30 file(s))`, both observed directly from a live `ritual-checks.ps1` run. `git show --stat c5c7e26` read in full; every changed file maps to the amended Territory. |
| Rollback safety (phase reverts cleanly; schema additive?) | No schema. The move to `markdown-lib.ps1` is purely additive/relocating (diffed identical, see F-none below); `git revert c5c7e26` would cleanly restore both the old duplicated functions and the old regexes — no destructive change to test. |
| Pure-move claim (notes.md: "the functions are unchanged, only their home is") | `git show c488560:scripts/enforcement-pack.ps1` and `git show c5c7e26:scripts/markdown-lib.ps1`, both functions extracted with `sed` and diffed with `diff` — **byte-identical**, confirmed programmatically, not by eye. |
| Dot-source ordering (both consumers) | `scripts/build-digests.ps1:59` dot-sources before `Get-DocMarkers` is defined (76) and long before it is called; `scripts/enforcement-pack.ps1:803` dot-sources before `Get-VisibleFromText` (807) is defined, and its calls to `Get-FencedLineMap`/`Disable-CommentMarkers`/`Convert-CodeSpanMarkers` (825-829, 963-964) are inside that function's body, not top-level statements that would execute before line 803. No forward-reference. |
| GAP-025 fixture actually exercises the fix (D10) | Reverted `build-digests.ps1`'s disarm call to the pre-fix two-line form; ran `Run-Tests.ps1 -Case build-digests/DIGEST-001`: **8 passed, 2 failed** (`DIGEST-001/pass` fails exactly as `notes.md`'s pre-fix measurement shows). Restored; `10 passed, 0 failed`. |
| GAP-026 fixture actually exercises the fix (D10) | Reverted `Get-Territory`'s anchor to `^\*\*Territory\*\*:`; ran `Run-Tests.ps1 -Case scope-check/SCOPE-001`: **7 passed, 3 failed** — both directions broke, with the observed message correctly showing the *new* FR-015 wording rather than the old WARN (proving `Test-AnyTerritoryDeclared`, left unmutated, is a genuinely separate code path). Restored; `14 passed, 0 failed`. |
| FR-015 fixture actually exercises the fix (D10) | Neutralized the FR-015 branch in `scope-check.ps1` (`if ($false -and ...)`); ran `Run-Tests.ps1 -Case scope-check/SCOPE-002`: **8 passed, 2 failed**. Restored; full suite `30 passed, 0 failed` again. `git status --short` confirmed clean after every mutation and at the end. |
| RunChild.ps1 argument reconstruction | Built a dummy target script and tested: value beginning with `-` (binds correctly, PASS), value containing an embedded single quote (binds correctly, no injection — "INJECTED" never printed), empty-string argument (binds correctly), a value equal to `-eq` (binds correctly). But a value equal to an *actual declared parameter name of the target* (`-Root -Check` against a script that declares `[switch]$Check`) mis-binds, throws `ParameterBindingException`, and — critically — **the launcher still exits 0**. Reproduced against both a synthetic script and the real `scripts/build-digests.ps1`. See F1. |
| Multi-line code span (GAP-025's failure class, variant shape) | Reproduced `Get-DocMarkers`'s exact control flow in a standalone script against a constructed 7-line document containing a genuine CommonMark multi-line inline code span with a real digest marker sitting inside the phantom comment window it opens. Harvested 2 of 3 markers — the middle one silently vanished. See F2. |
| Decorated-marker fix's real-world coverage | `grep -n '^\*\*Territory\*\* ('` across `specs/**/tasks.md` found exactly one live occurrence, `specs/014-amendment-authority/tasks.md:322`, whose annotation wraps across 3 physical lines. Neither the old nor the new `Get-Territory` anchor matches it (no colon on the line containing `**Territory**`). Traced its origin with `git log -S` to `28d2f0a`. See F3. |
| "Coverage counts anchors, not tested sites" (notes.md's own disclosed gap) | `grep -n "not in territory" scripts/scope-check.ps1` — confirmed exactly 2 sites (line 186, Micro lane; line 246, Standard lane), matching the claim that `SCOPE-001`'s `emitAnchor` overcounts by one untested site. |
| T015's "zero measurement, latent defect" claim | `ritual-checks.ps1`'s live output: `digests: OK (5 digest(s) fresh, 80 marker(s))` — unchanged from the phase 1 baseline recorded in `notes.md` ("digests unchanged at 80 markers"), corroborating that no real document in the kit's own five packs tripped the old parser. |

## Findings

### F1 — `RunChild.ps1` reports exit code 0 when the target script fails to even start (a parameter-binding failure), defeating FR-008 for every fixture that routes through it — **BLOCKING**

`tests/enforcement/lib/RunChild.ps1` reconstructs the argument vector and invokes the target via
`& ([scriptblock]::Create($tokens -join ' '))`, then unconditionally does `exit $LASTEXITCODE`.
When the reconstructed call itself fails to bind — for example, an argument value that happens to
equal one of the target script's own real parameter names, so PowerShell binds it as that
parameter instead of as the preceding parameter's value — the invocation throws a
`ParameterBindingException` (a genuine, terminating PowerShell error; the target script's own
logic never runs) but `$LASTEXITCODE` is left at whatever it was *before* the call (native exit
codes and PowerShell-level binding errors are different mechanisms), and `RunChild.ps1` exits with
that stale value. Reproduced twice:

```
$target = build-digests.ps1
& RunChild.ps1 $target -Root -Check
  -> build-digests.ps1: Missing an argument for parameter 'Root'. ...
  -> exit code observed by caller: 0
```

(Sentinel-tested: `$LASTEXITCODE` was deliberately set to `99` before the call to rule out an
accidental pre-existing `0`; it still came back `0`, confirming the failure path genuinely masks
itself rather than merely inheriting a stale-but-nonzero value.) By contrast, an explicit `throw`
*inside* the target script's own logic correctly propagates as exit `1` — so this is specifically
the parameter-binding-failure path that is swallowed, not "any error."

This is exactly the harness's-own-fail-open shape the spec calls out by name ("A fixture that
passes because the check never ran... the harness MUST verify that the rule under test was
actually exercised, not merely that the run was quiet," spec Edge Cases) and that D10 exists to
catch via paired recipes — but D10's protection only works if a genuine failure surfaces as a
non-matching exit code or output in the first place. Here it does not: a case whose `command.json`
accidentally collides with the target script's own parameter names would report a false `OK`/PASS
with **no visible diff at all**, because the harness never even reaches the golden-file
comparison in a state that reveals the problem — the process just exits 0 having run nothing.
`Harness.psm1` now routes *every* case through `RunChild.ps1` (that was this phase's own change,
`tests/enforcement/lib/Harness.psm1:87-94`), so this affects the ~80 remaining rules phases 3–6
will add, not just this phase's 3.

None of this phase's own 3 fixtures (`DIGEST-001`, `SCOPE-001`, `SCOPE-002`) happen to pass an
argument value that collides with a target parameter name — I checked every `command.json` in the
tree — so today's 30 green tests are not currently affected. But the defect is in code this commit
ships as permanent shared infrastructure, is trivially reachable by an honest authoring mistake
(not a contrived adversarial input), and its failure mode is the single worst one a test harness
can have: silent success where there should be visible failure.

*Action: implementer — fix `RunChild.ps1` to detect and propagate a failed invocation explicitly
(e.g., wrap the `&` call in `try { ... } catch { Write-Error $_; exit 70 }`, or check `$?` /
inspect `$Error[0]` immediately after the call and force a distinct nonzero exit when the
scriptblock itself did not complete), before phase 3 begins adding fixtures on top of this
launcher. A regression case for this exact shape (a `command.json` arg colliding with a real
target parameter name) would be a reasonable addition to `tests/enforcement/lib/`'s own coverage,
though the harness's own correctness is reviewed rather than tested per plan.md's Testing
Strategy — owner's call whether that extends to a meta-case here.*

### F2 — The GAP-025 fix does not cover a genuine multi-line CommonMark inline code span; the same marker-swallowing failure class recurs in a narrower shape — **CONFIRM**

`Convert-CodeSpanMarkers` (`scripts/markdown-lib.ps1`) operates strictly per-line
(`param([string]$Line)`), so it cannot see a code span whose closing backtick run is on a
*different* line than its opening run. CommonMark inline code spans are legitimately allowed to
span lines within a paragraph. I constructed a 7-line document reproducing `Get-DocMarkers`'s
exact control flow (fence tracking, in-comment state, the GAP-025 disarm call) with:

```
line 3: 'A digest marker opens with `<!-- unclosed on this line'
line 4: '<!-- digest: this marker should be visible but sits inside the phantom comment window -->'
line 5: 'closing backtick example` more prose here, no bearing now'
```

Harvested markers: 2 of 3. The marker on line 4 vanished silently — no "malformed marker" message,
no error, just gone, exactly GAP-025's original symptom ("the generator wrote a digest missing
real rules and reported OK"). The mechanism: line 3's unmatched single backtick means
`Convert-CodeSpanMarkers` sees only one backtick run (`$runs.Count -lt 2`) and returns the line
unchanged, so the `<!--` on it stays armed and opens a real (phantom) comment state; the *next*
literal `-->` anywhere — here, the real marker's own closing `-->` on line 4 — closes it,
swallowing everything in between, including a legitimate marker.

This is not a new defect introduced by this phase — `Convert-CodeSpanMarkers` itself is an
unchanged, pure-moved function (confirmed byte-identical to its `c488560` form), and its per-line
design is an explicit, previously-reviewed tradeoff from feature 014 rather than something phase 2
chose. But phase 2's own commit message states the class of defect is closed ("The PASS direction
is the demonstration... a correct two-bullet digest was called stale") without the single-line
qualifier, and FR-013's acceptance scenario is written generally ("a comment opener quoted inside
an inline code span"). The fix closes the single-line shape completely (verified) but leaves this
multi-line variant of the identical failure open in the exact script GAP-025 was filed against.

*Action: implementer/owner — file a fast-follow GAP for the multi-line code-span case (it affects
both `build-digests.ps1` and, via the same shared function, `enforcement-pack.ps1`'s
`Get-VisibleFromText`), and consider narrowing `notes.md`'s and the commit message's "closed"
language to name the single-line scope explicitly. Not blocking this phase: the fixed shape is the
one GAP-025 was filed against and demonstrated failing (D11), and the residual risk is a known,
previously-accepted characteristic of the shared line-based scanner rather than a regression.*

### F3 — The decorated-marker fix does not recognize the one decorated Territory marker currently live in the kit's own governance history, because its annotation wraps across three physical lines — **CONFIRM**

`specs/014-amendment-authority/tasks.md:322-324` currently reads:

```
**Territory** (widened by amendment 2026-09-16 — `plan.md`, for T069's exemption record;
reviewer N10): `scripts/enforcement-pack.ps1`, `specs/014-amendment-authority/tasks.md`,
`specs/014-amendment-authority/plan.md`
```

Neither the old anchor (`^\*\*Territory\*\*:`) nor the new one
(`^\*\*Territory\*\*[^:]*:`) matches line 322, because the colon that ends the annotation is on
line 323 — `Get-Territory` and `Test-AnyTerritoryDeclared` both match within a single element of
`$TasksLines`, and this marker's colon is not in the same line-array element as `**Territory**`.
Traced via `git log -S` to `28d2f0a` ("amend 014 tasks: widen phase 3 territory to plan.md (N10)");
it has never been repaired the way the *other* decorated marker in this file (phase 4's, introduced
and then manually un-decorated by `3a51f5c`) was.

This also means the phase 2 commit message's citation is imprecise: it attributes the "wrote it
TWICE" pattern to `ca88da5` and `3a51f5c`, but `ca88da5`'s diff does not introduce a decorated
marker at all (it appends entries under an already-plain `**Territory**:` block) — the actual
second decorated-marker introduction still standing in the file is `28d2f0a`, uncited.

Practical risk today is low: 014's branch is merged, so this specific instance is no longer being
graded by `scope-check.ps1` (it only walks the *current* feature branch's history). But it
demonstrates the fix's real-world coverage is narrower than its own commit message implies, and
the same prose style (a long annotation that a human line-wraps for readability) is exactly the
kind of decoration a future feature amending its own Territory is likely to reach for again — 014
did it under this same review pressure at least twice.

*Action: implementer — correct the `28d2f0a`/`3a51f5c` citation in a follow-up note if this file
is touched again, and consider documenting the single-line limitation explicitly in
`Get-Territory`'s docstring (it already documents the single-line assumption implicitly via "Lines
are pre-stripped of HTML comments by the caller" but not the multi-line-annotation case). Not
blocking: no live commit is mis-graded by this today, and FR-014's acceptance scenario used a
single-line example.*

## Amendments in this diff

Constitution I, Amendment authority — one amendment in this diff, and it is well-formed:

- **`06b1b30`** — "amend 015 tasks: phase 2 territory reaches its own tasks - approved by anas.m,
  2026-09-19" — widens phase 2's Territory to add `scripts/markdown-lib.ps1`,
  `scripts/enforcement-pack.ps1`, `scripts/scope-check.ps1`, `scripts/scope-check-repos.ps1` (the
  approved Territory had only listed `scripts/build-digests.ps1` and `scripts/scope-lib.ps1`).
  - The amended section of `specs/015-enforcement-assurance/tasks.md` carries
    `**Amendment approved by**: anas.m, 2026-09-19.` — present, verified by direct read.
  - The commit message names the same approver and date ("approved by anas.m, 2026-09-19") —
    matches.
  - `06b1b30` is the direct parent of the phase commit `c5c7e26` (`git log --oneline`, confirmed)
    — the amendment lands **before** the phase commit that relies on it, satisfying DoD gate 4's
    ordering requirement (the check reads the declaration from the commit's parent).
  - The amendment commit's author is `anas.m <anas.m@dpointernational.com>` (human owner, per this
    solo project's established pattern across every prior feature) — not the implementing agent
    identity (`Claude Opus 5`, which appears only as `Co-Authored-By` on the phase commit, never
    as the amendment's author or approver). No self-approval indicator found.
  - **Verdict: well-formed.** I cannot verify that the named person actually agreed
    (constitution I is explicit that this half is "held by review alone" and is the human
    reviewer's to judge at merge, not this AI review's) — but the record exists, is correctly
    shaped, agrees with its commit, and is correctly sequenced.

## Constitution re-check (post-implementation)

- **I. Specification First** — PASS. `spec.md`/`plan.md` approved before phase 1; the phase 2
  amendment is recorded and sequenced correctly (see above).
- **II. Source of Truth Hierarchy** — PASS. No conflict found between `spec.md`, `plan.md`,
  `tasks.md` and the implementation; where the phase discovered gaps in its own Territory it
  amended forward rather than silently overriding.
- **III. Repository Separation** — N/A (single-repo kit, as plan.md states).
- **IV. Architecture Consistency** — PASS. No new package, no new architecture. The
  `markdown-lib.ps1` extraction follows the precedent `scope-lib.ps1` already set for the two
  scope graders — consistent with existing pattern, not a new one.
- **V. Domain Invariants** — N/A.
- **VI. Security** — PASS, with a correctness caveat (F1) rather than a security one: no secrets,
  no network, and the single-quote injection vector I specifically tested against
  `RunChild.ps1`'s command-line reconstruction is properly neutralized.
- **VII. External Integration Governance** — N/A.
- **VIII. Testing Requirements** — **engaged, partially unmet.** This feature's entire subject is
  testing; F1 is a defect in the test infrastructure itself, which is the highest-stakes place for
  one to exist given this principle.
- **IX. Human Review Requirement** — in progress; this is that review.
- **X. Controlled Delivery** — PASS on phase scope and Territory (post-amendment); phase-size
  guideline exceeded (857 lines / 30 files) — non-blocking per constitution, and consistent with
  phase 1's already-accepted pattern of large-but-coherent harness phases; owner's call at gate, as
  with phase 1.

## Test coverage observed

`tests/enforcement/Run-Tests.ps1`: **30 passed, 0 failed** (up from phase 1's 18) — the 12 new
tests are exactly the 3 new rules × 2 directions × 2 assertions (exit code, output) for
`DIGEST-001`, `SCOPE-001`, `SCOPE-002`. `Coverage.Tests.ps1`'s 5 structural tests (inventory
integrity ×3, emission-idiom declaration ×2) still pass; the reporting-only coverage line moved
from "3 of 88" (phase 1) to "7 of 89 declared failure-emission site(s)" (one new site: FR-015's
new FAIL branch in `scope-check.ps1`; three new inventoried rules). Critical assertions are
golden-file, full-text comparisons (not "contains" checks) against hand-written `expected.txt`
files — confirmed by reading all 6 `expected.txt`/`recipe.json` pairs directly; each pass/fail pair
differs from its sibling only in the condition under test (D10), verified by diffing the recipe
JSON bodies. Independently confirmed via mutation (see evidence table) that each of the three new
rules' fixtures is actually exercised by the corresponding fix, not merely present. `notes.md`'s
self-reported gap — the coverage report counts anchor matches rather than tested sites, so
`SCOPE-001` is credited for 2 sites when only 1 is under test — is independently verified true and
correctly deferred to T044 rather than silently inherited.

## Residual risk

The concentration of risk is F1: a fail-open in shared test infrastructure that every future
fixture will depend on, currently latent because no existing fixture happens to trigger it. Its
blast radius grows with every phase that adds cases without fixing it first — recommend fixing
before phase 3 starts, rather than after. F2 and F3 are narrower and lower-stakes: F2 is a known
class of residual risk in a previously-reviewed, unchanged shared function, worth a tracked
follow-up rather than a blocker; F3 has no live grading impact today (the affected branch is
merged) but is worth a docstring note so the next amendment doesn't reach for the same
multi-line-wrapped decoration. None of the three change the phase's core, well-evidenced claim:
GAP-025 and GAP-026 are closed for the shapes their own fixtures target, test-first, with the
harness itself (mostly) catching what it claims to catch.

---

## Implementer dispositions (appended below the reviewer's text; nothing above is edited)

Written by the implementing agent after the review. Every finding was reproduced before it was
acted on; where the reviewer's reasoning is what mattered, it is kept in the code comments.

### F1 — BLOCKING — **FIXED**, `RunChild.ps1` + new `Harness.Tests.ps1`

Reproduced exactly as reported, against the real `build-digests.ps1`: `-Root -Check` fails to
bind, the launcher prints the binding error and exits **0**. The reviewer's framing is the part
worth keeping — a fail-open in shared harness infrastructure, in a file that ~80 further fixtures
will route through, and none of phase 2's own three cases happens to trip it.

Success is now tracked separately from the exit code. Ran normally → 0; called `exit 1` → 1 (a
real FAIL verdict must still pass through); never ran, or threw → **97**, a code no kit script
emits, with a printed line saying the launcher is speaking so the case fails on both channels.

Added `tests/enforcement/Harness.Tests.ps1` — eight tests over the exit shapes, argument binding,
the non-ASCII round trip and a quoted value — because this defect should not have needed a review
to find, and the next one should not need one either.

**Those self-tests then found a second defect the reviewer did not see, in `Harness.psm1`.**
`Start-Process` joins an `-ArgumentList` array with spaces and quotes nothing, so a fixture path
containing a space (`C:\Users\A B\…`) reached the child truncated. No fixture could have caught
it; every fixture so far runs from a space-free temporary path. Fixed alongside. Tests 30 → 38.

### F2 — CONFIRM — **open, owner's call**; not remediated in this phase

Verified. `Convert-CodeSpanMarkers` is per-line by construction, so a code span whose closing
backtick run lands on a later line leaves its `<!--` armed, and the next literal `-->` — possibly
a real marker's own — closes the phantom comment, swallowing what lies between.

I agree with the reviewer that this is not a phase 2 regression: the function is byte-identical to
its `c488560` form, and its per-line design is feature 014's reviewed tradeoff. I also agree the
"closed" language is wider than the fix. My recommendation is to file it as a GAP rather than
widen phase 2, because it reaches `enforcement-pack.ps1`'s `Get-VisibleFromText` through the same
shared function and therefore touches amendment-authority grading — a change that deserves its own
demonstration and its own review, not a tail-end edit to a phase already under review.

### F3 — CONFIRM — **the factual error is corrected; the remaining scope question is open**

Two separable things.

*The citation was wrong, and that part is not a decision.* Measured: `ca88da5` touches no
`**Territory**` line; `3a51f5c` is the **repair** (it rewrites the decorated spelling and says in
its own diff that the form is invisible); `28d2f0a` — uncited — shows the form at least three
times, its parent line already reading `**Territory** (unchanged):`. Corrected in `notes.md`,
since a commit message cannot be. This is feature 014's G5 repeating: a comparative claim repeated
without measuring it.

*The scope question is open.* A marker whose annotation **wraps across lines** still matches
neither anchor, so `specs/014-amendment-authority/tasks.md:322` remains invisible. No live verdict
depends on it (that branch is merged and is not re-graded), and the entries there are inline prose
rather than backtick list items, so even a matching anchor would collect zero of them.

My recommendation, for the owner rather than for me to take: do **not** teach the parser to join
continuation lines, but make the near-miss **loud** — a line beginning `**Territory**` with no
colon on it is currently silent, and `build-digests.ps1` already has exactly this pattern for a
malformed digest marker (014 review F6/F7). That converts the remaining silence into a named
error without adding a multi-line scanner. It is a behaviour change beyond FR-014 as written,
which is why it is a recommendation and not a commit.
