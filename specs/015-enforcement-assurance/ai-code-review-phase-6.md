# AI Code Review — 015 Enforcement Assurance, Phase 6

**Reviewer**: fresh-context agent — claude-opus-5-5
**Date**: 2026-09-26
**Branches**: agentic-sdlc-kit `015-enforcement-assurance` (tip `28a99fa`, parent `1f05bb3`)
**Scope reviewed**: the whole of `28a99fa` (23 files): `tests/enforcement/{Coverage.Tests.ps1,
Harness.Tests.ps1,lib/Harness.psm1,rules.json,emission-idioms.json}`, the two new fixture pairs
(`cases/enforcement-pack/{AMEND-006,PACK-003}/{pass,fail}`), `scripts/enforcement-pack.ps1`
(header), `adoption/updating.md`, `docs/sdlc/review-process.md`,
`docs/digests/adoption-digest.md`, `specs/015-enforcement-assurance/{tasks,notes}.md`. Also read,
not changed by this commit: `scripts/territory-check.ps1`, `scripts/scope-check.ps1`,
`scripts/scope-check-repos.ps1`, `scripts/ritual-checks.ps1` (vocabulary block),
`tests/enforcement/lib/RunChild.ps1`, `tests/enforcement/lib/FixtureRepo.psm1` (origin model),
`tests/enforcement/Run-Tests.ps1`, `.github/workflows/enforcement-tests.yml`.
**Feature contract**: phase 6 = T044–T053; Territory `tests/**`,
`.github/workflows/enforcement-tests.yml`, `scripts/enforcement-pack.ps1`,
`adoption/updating.md`, `docs/sdlc/review-process.md`, `docs/digests/*-digest.md`
(`tasks.md:266-273`); FR-003, FR-004, FR-016, FR-019, FR-020, FR-021, FR-022, SC-002, SC-007;
plan D6 (UNGRADED never moves an exit code), D9; `**Gate Certification**: ci-held`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: Claude Opus 5 (1M context) — the implementing session that authored `28a99fa`
  (named in the commit's `Co-Authored-By` trailer). Not this reviewer.
- **Inputs provided**: `git show --stat 28a99fa`, `git show 28a99fa`, `git diff 1f05bb3 28a99fa`,
  `CLAUDE.md`, `.specify/memory/constitution.md`, `docs/sdlc/definition-of-done.md`,
  `docs/sdlc/review-process.md`, `specs/015-enforcement-assurance/{spec,plan,tasks,notes}.md`,
  the prior phase reviews, `specs/_templates/ai-code-review-template.md`; `gh run view` of runs
  35547650371, 35547650549, 35518845272, 35518845283; execution of `scope-check.ps1`,
  `ritual-checks.ps1` and the full harness at HEAD; seven coverage mutations in a detached scratch
  worktree; two SC-002 inversions in a second scratch worktree; the T047 branch test in a scratch
  clone checked out detached and as `main`; a hand-built repository reaching
  `territory-check.ps1:81`.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES.** Most of the phase is sound and was verified rather than read: coverage now
genuinely blocks (a new unowned `$failures +=` site fails the run), all three exemption guards
fire exactly as claimed (emptied reason, gesture-length reason, exemption over a fixtured rule
all go red), the two new rules' fixtures discriminate (inverting AMEND-006's guard fails its
`fail` case), the Territory holds, the digests are fresh, and `ritual-checks` is green. Four
things stop an approval, and three of them are this feature's own species. (1) The new FR-020
test — written to prove the harness does not depend on the branch it runs from — **depends on the
branch it runs from**: it is red on a detached checkout (every `pull_request` CI run) and on
`main` (the post-merge push). The only CI run of this commit was a push to the named feature
branch, which is the one checkout where it is green. (2) `notRules` is a second exemption channel
with none of the three guards the exemption channel got, and the claim that each one "is printed
on every run" is false. (3) One of the eight written exemptions (TERR-012) is justified by a false
statement about PowerShell and hides a reachable, fixturable rule. (4) The T049/T050 prose lists
"an unreadable parent commit" as an UNGRADED cause; in the code it is a FAIL.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match | T044 blocking: mutation A (new `$failures +=` in `enforcement-pack.ps1`) → `coverage` FAIL naming `enforcement-pack.ps1:1289`. T045 guards: mutation C (TERR-012 exemption `''`) FAIL, D (AMEND-007 reason `cannot be built`) FAIL, F (80-char exemption over PACK-003) FAIL. T046 verdict block observed in a real failure report (`verdict : expected 'enforcement-pack: OK' / observed ...`). T047: see F1. T048: see "Test coverage observed". |
| Visual-reference match | N/A — no UI. |
| Feature contract held | No package, no workflow change, no exit-code change: `enforcement-pack.ps1` diff is header-comment only (`:75-91`). |
| Constitution / domain invariants | Amendment authority: `tasks.md` diff is ten checkbox flips, no text change — no amendment. |
| Security | N/A — test code and prose. |
| Scope guard | `pwsh -File scripts/scope-check.ps1` → `scope-check: PASS phase 6 commit 28a99fa (23 file(s))`. Every changed file is in the phase-6 Territory or the feature's own directory. |
| Rollback safety | Tests, fixtures, prose; reverts cleanly. |
| Digests (T052) | `ritual-checks.ps1` at HEAD: `digests: OK (5 digest(s) fresh, 82 marker(s))`, `RESULT OK`, exit 0. |
| Cost (T053) | `gh run view`: see F7. |

## Findings

### F1 — The FR-020 branch-independence test is branch-dependent; red on every PR and on main — BLOCKING

`tests/enforcement/Harness.Tests.ps1:386-401` reads `git rev-parse --abbrev-ref HEAD` and fails if
any `command.json` **contains that string as a substring** (`:394`). Two ordinary checkouts break it:

- **Detached HEAD** (what `actions/checkout` does for every `pull_request` event, and this
  workflow runs on `pull_request: branches: [main]`): `$current` is `HEAD`, and
  `AMEND-006/{pass,fail}` (`-ReplayBase HEAD`) and the pre-existing `SCOPE-013/pass` contain it.
- **`main`** (the push after merge; the workflow runs on `push: main`): `PACK-003/fail` passes
  `-Branch main` — a fixture repository's own trunk, which is exactly what it should name.

Measured in a scratch clone of `28a99fa`:

```text
branch=HEAD  [-] names no branch of this repository in any case command
             ... ('HEAD') ... AMEND-006\fail, AMEND-006\pass, SCOPE-013\pass     RESULT failed=1
branch=main  [-] names no branch of this repository in any case command
             ... ('main') ... PACK-003\fail                                     RESULT failed=1
```

CI run 35547650549 is green only because it was a `push` to `015-enforcement-assurance`, the one
checkout name no fixture uses. The premise is also wrong: `main` and `HEAD` in a fixture refer to
the fixture repository, not to this one, and substring containment cannot tell them apart. This is
the defect the test's own comment describes — "green here and red for everyone else the day this
branch merges" — reproduced by the test.
*Action: implementer — assert the real property instead (e.g. run one case from two different
host checkouts, or at minimum skip `HEAD`, require the current name to be a numbered/feature branch
and match whole `-Branch` argument values rather than substrings); then prove it green detached and
on a branch named `main` before re-requesting review.*

### F2 — `notRules` is an unguarded exemption channel, and its "printed on every run" claim is false — BLOCKING

`Get-SiteOwner` (`Coverage.Tests.ps1:272-275`) excuses any unowned site whose text *contains* a
`notRules` anchor. Compared with the exemption channel, it has:

- **no bound** — rules are held to `siteCount` by the ambiguity test (`:141-163`); a `notRules`
  anchor may excuse any number of sites. Mutation B added a second, different lane decline that
  exits 0 (`...is the lightweight docs/ lane AND also a brand-new silent decline"; exit 0`) and the
  whole coverage file stayed green (`passed=10 failed=0`). That falsifies the notes' "A new
  emission site added to any of the nine scripts fails the suite until someone says, in writing,
  what it is" — this one said nothing new.
- **no reason check** — mutation E emptied every enforcement-pack `notRules.reason`; green.
- **no printing** — the report prints only a count (`:335`, "3 declared not a rule"); the
  per-exemption print loop (`:363-375`) covers `rules.json` exemptions only. Yet
  `emission-idioms.json:33-34` says "each is printed by the coverage report" and `notes.md:2277`
  says "printed on every run. That is the difference."

The commit's argument that `notRules` "prevents the real loophole" is fair, but as built it is the
loophole with fewer guards than the one it replaced.
*Action: implementer — apply the exemption channel's guards: a declared site count per entry
(default 1) enforced like `siteCount`, a reason-length floor, and print every entry with its
reason; or correct both documents to claim only what the code does.*

### F3 — TERR-012's written exemption is false, and the rule is reachable — BLOCKING

TERR-012's anchor is `Write-Warning "Skipping origin/${other}: cannot compare with $BaseBranch."; continue`
(`scripts/territory-check.ps1:81`). The exemption, copied verbatim to all five TERR rules
(`rules.json` TERR-012), says "Write-Error (or Write-Warning) under ... ErrorActionPreference =
Stop ... makes the write TERMINATING". `$ErrorActionPreference` does not govern `Write-Warning`:

```text
pwsh -c '$ErrorActionPreference="Stop"; Write-Warning "w"; "after-warning"'
WARNING: w
after-warning
```

And the line is reachable through the harness launcher: a repository whose origin fetch refspec
covers only `main`, with a numbered branch `012-other`, run via `RunChild.ps1`:

```text
WARNING: Skipping origin/012-other: cannot compare with main.
CLEAN — '011-thing' shares no files with any open feature branch.
exit=0
```

So the fixture model needs one recipe knob (a restricted `remote.origin.fetch`, in
`tests/enforcement/lib/FixtureRepo.psm1`, inside Territory), not a script fix. "Five of the eight
exemptions are one real defect" is four. An exemption that a false reason keeps green is exactly
what FR-004's written-reason rule exists to prevent — the length guard cannot catch a reason that
is long and wrong.
*Action: implementer — give TERR-012 a fixture pair (or, if the knob is rejected, a true reason),
and correct the count in `notes.md` and the commit record.*

### F4 — T049/T050 prose names "an unreadable parent commit" as an UNGRADED cause; the code FAILs it — BLOCKING

- `scripts/enforcement-pack.ps1:75-79` (T050): "A check in this pack can RUN AND FORM NO OPINION:
  ... a parent commit this clone cannot read ... Such a check adds a line to $ungraded". In this
  pack an unreadable parent goes to `$script:failures` (`enforcement-pack.ps1:1138`, exit 1). All
  four `$ungraded +=` sites (`:583, :625, :676, :1260`) are "no diff base".
- `adoption/updating.md:449` (T049): lists "an unreadable parent commit" among states that used
  to print `OK` and now print `UNGRADED`. The same file, eight lines up (`:431-432`), correctly
  says the amendment check **fails** on it.
- `docs/sdlc/review-process.md:64` (T051) repeats it.

I found no `UNGRADED`/`$ungraded` path for an unreadable parent in any of the nine scripts
(grep for `parent|readable|shallow` against every UNGRADED emission). Phase 5 took three review
rounds over prose claiming a property the code does not have; this is the same class, in the
flow-down note adopters will act on.
*Action: implementer — remove the unreadable-parent example from all three, or name the member
that actually reports it UNGRADED.*

### F5 — `notRules` classifications contradict the idiom file's own stated principle — CONFIRM

The enforcement-pack note in `emission-idioms.json:49` still says "the run verdict UNGRADED is a
printer, while the run verdict OK is a site, because OK asserts that conditions did not occur" —
and the same entry now declares `enforcement-pack: OK` not a rule. The docs-lane decline
(`enforcement-pack.ps1:1266`) is declared not a rule while the trunk decline beside it (`:1244`),
the same shape, became PACK-003; the note written in T036b listed both as "conditions ... counted
nowhere". Its stated reason — "Reached and asserted by GAP27-001 in both directions" — is an
argument for owning it by a rule, not for excusing it. `notes.md:2279` also says "Fifteen lines
are declared not-rules"; `emission-idioms.json` holds 14 (4+3+2+4+1), and the notes' list omits
the docs-lane line.
*Action: owner — decide whether lane declines and the OK verdict are sites (then give them rules)
or not (then update the note that says otherwise); implementer fixes the count.*

### F6 — AMEND-006 certifies GAP-027's shape as expected behaviour — CONFIRM

The commit and notes call "no commits in <range> — nothing to grade" "GAP-027's own shape ...
surviving the feature written to close GAP-027". The new fixture pins it: `AMEND-006/fail/expected.txt`
ends on `enforcement-pack: OK`, exit 0. `scope-check.ps1:309` reports the same condition ("no
commits since merge base") as `UNGRADED`. The fixture is honest about today's behaviour, but the
defect it names is neither fixed nor listed under "What phase 6 does not do" (`notes.md`), so it
has no owner.
*Action: owner — decide whether AmendmentAuthority's empty range should add to `$ungraded`
(in Territory: `scripts/enforcement-pack.ps1`), or record it as an open item / GAP.*

### F7 — T053's measurements are from the parent commit, not from phase 6 — MINOR

`notes.md` T053 cites runs 35518845272/35518845283 (`1f05bb3`): 16s, 3m46s, 12m12s — confirmed
by `gh run view`. The phase-6 runs are 35547650371 (ritual-checks, 16s) and 35547650549
(ubuntu 5m37s, windows 10m54s). The conclusion — beside, not inside — stands either way.
*Action: implementer — cite the phase-6 runs or say the figures are the parent's.*

### F8 — TERR-008..011: the exemption is partly a harness-fidelity choice, and its GAP row is owed — MINOR

Measured: under `pwsh -File`, `territory-check.ps1` on `main` exits 1 with the message on stderr;
through `RunChild.ps1` it exits 97. The unreachable `exit 1` lines are real, but the rule's
production behaviour is observable and `RunChild.ps1` (in Territory) is what makes it
unassertable. Recording and exempting is defensible; the notes say the GAP row is an owner action.
*Action: owner — promote the territory-check finding to a roadmap GAP row.*

### F9 — `review-process.md` step 3 reads as self-contradictory — MINOR

`:59-61` lists `UNGRADED` among "lawful non-blocking verdicts", then `:63` says it "is not one of
the acceptable ones in the same sense". The substance of the reviewer's line (T051) is right; the
lead-in list should not include it.
*Action: implementer — drop `UNGRADED` from the list and let the next paragraph carry it.*

## Amendments in this diff

- [x] **None.** `tasks.md` changes are ten `[ ]`→`[x]` flips (T044–T053); `spec.md` and `plan.md`
  are untouched.

## Constitution re-check (post-implementation)

PASS on scope (I, Territory) and on amendment authority (no amendment). The findings are against
the feature's own FRs (FR-004, FR-020, FR-022) and the review-process standard that prose claims
only what the code does, not against a constitutional principle.

## Test coverage observed

- **Coverage.Tests.ps1** at `28a99fa`: 10/10 passed; report `189 of 200 ... 8 exempt, 3 declared
  not a rule`. Mutations (detached scratch worktree, reverted after each): A new unowned site →
  FAIL; B second site under a `notRules` anchor → PASS (F2); C empty exemption → FAIL; D short
  exemption → FAIL; E empty `notRules` reasons → PASS (F2); F exemption over fixtured rule → FAIL;
  G (confounded — renaming the anchor un-owned an existing site; not used as evidence).
- **SC-002 sample (my own)**: AMEND-006 guard `$commits.Count -eq 0` inverted → `AMEND-006/fail`
  fails (observed `AmendmentAuthority: graded 0 of 0 commit(s) in HEAD..HEAD`), and so does
  `AMEND-006/pass` (observed `no commits in HEAD~1..HEAD`). PACK-003 trunk guard inverted
  (`-in` → `-notin`, `enforcement-pack.ps1:1243`) → both `PACK-003/fail` (exit 0→1) and
  `PACK-003/pass` (observed `'fix/thing' is the trunk`) fail. 2 of 2 caught, tree clean after.
  A small T046 nit seen here: when only the body differs, the report prints
  `verdict: expected 'enforcement-pack: OK' / observed 'enforcement-pack: OK'`, which is
  accurate but draws the eye to the one line that matched; the first-diff line beneath it carries
  the finding.
- **Full harness at HEAD** (main working tree, branch `015-enforcement-assurance`): `Tests Passed: 796, Failed: 0`, exit 0 —
  matching the commit's claim. Wall time 13705s (≈3.8 h) on this machine, run alongside the
  mutation work, so it says nothing about the CI figures. Green here is expected: this checkout
  is the named branch, the one on which F1 does not fire.
- **T047**: the write-half test is sound as written (`--untracked-files=all`, HEAD and branch
  snapshot); the identity-half asserts `Fixture Author <fixture@example.invalid>` on every fixture
  commit; the branch-half is F1.

## Residual risk

Concentrated in F1 (the next PR against `main` goes red on both legs of `enforcement-tests`, and
so would `main` after merge) and in F2/F3, which are ways for coverage to read complete while a
reachable condition has no fixture. F4 lands in the adopter-facing flow-down note. Fix F1–F4,
decide F5/F6, and re-review; F7–F9 can ride along.

---

## Dispositions (implementer, appended — the reviewer's text above is unedited)

Owner decisions on F5, F6 and F8 recorded 2026-09-26 (anas.m: "go with your recommendation").
Detail and mutation evidence: `notes.md`, "Phase 6 review round 1 — remediation".

| Finding | Disposition |
|---|---|
| F1 | **Fixed.** `Harness.Tests.ps1`: the test now asserts that every `-Branch` value is, as a whole value, a branch the case's own recipe creates — nothing is read from the host checkout. Mutation: `-Branch 015-enforcement-assurance` in a case fails it. Host-independence to be demonstrated on a detached checkout and on a branch named `main` before re-review. |
| F2 | **Fixed.** `notRules` now carries the exemption channel's three guards: reason ≥ 60 characters, `siteCount` (default 1) matched exactly, every entry printed with its reason. Four short reasons rewritten. Mutations: a second site under `AmendmentAuthority: graded ` fails; an emptied reason fails. |
| F3 | **Fixed.** `FixtureRepo.psm1` gains `originFetch`; TERR-012 has a pass/fail pair instead of an exemption. The four remaining TERR exemptions' reason no longer mentions `Write-Warning` and counts four. `RunChild.ps1` now asks the child for plain-text rendering, because pwsh decorated the warning with ANSI escapes. |
| F4 | **Fixed.** The unreadable-parent example is removed from all three documents; the `enforcement-pack.ps1` header now names the states that are UNGRADED and those AmendmentAuthority FAILS on. |
| F5 | **Fixed, owner decision.** The docs-lane decline is rule PACK-004 with a fixture pair; `enforcement-pack: OK` stays a not-rule and the idiom note is corrected. The notes' count is corrected (14 declared; 13 after PACK-004). |
| F6 | **Fixed, owner decision.** The empty amendment range adds to `$ungraded` (exit 0 unchanged, D6); `AMEND-006/fail` expects `UNGRADED`. |
| F7 | **Fixed.** The T053 table cites phase 6's runs beside the parent's. |
| F8 | **Deferred — owner action, separate docs PR:** a roadmap GAP row for territory-check (four unassertable error paths; `CLEAN` printed over a skipped comparison, surfaced by the F3 fixture). |
| F9 | **Fixed.** `UNGRADED` removed from the list of lawful non-blocking verdicts in `review-process.md`. |

**New, found during remediation (for round 2 to weigh):** a line worded as a variant of the success verdict (`Write-Host 'enforcement-pack: OK (…)'`) is seen by neither the precise pass nor the recall sweep. Recorded in `notes.md`; not changed.
