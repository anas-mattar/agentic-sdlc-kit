# Implementation Plan: Verdicts that say what was compared (scope-repos and territory-check)

**Branch**: `022-verdict-honesty-repos-territory` | **Date**: 2026-10-12 | **Spec**: specs/022-verdict-honesty-repos-territory/spec.md
**Input**: Feature specification (approved, anas.m, 2026-10-12) + decisions D1–D9 below
**Gate Batching**: none
**Gate Certification**: user-run
**Amendment approved by**: anas.m, 2026-10-12

## Summary

Two scripts say less than they know. `scope-check-repos.ps1` ends silent over a repository that applied and graded
nothing whenever another repository graded; `territory-check.ps1` cannot reach the exit and message of four refusals
because `Write-Error` is terminating under `$ErrorActionPreference = 'Stop'`. Three phases, each independently
revertible. First the run-level verdict and the hint in `scope-check-repos.ps1`, fixtures first. Then the four
refusals in `territory-check.ps1`, which needs one small harness accommodation (a fixture that is not a repository).
Last the guidance, the flow-down note, the roadmap and a measurement over clones of the three adopted projects. No new
script, no new library file, no verdict word added, no change to `ritual-checks.ps1` (it already lifts a line that
begins `scope-repos: UNGRADED`).

## Technical Context

**Language/Version**: PowerShell 7+ (`pwsh`)
**Primary Dependencies**: none new
**Storage**: files and git state only; both scripts stay read-only
**Testing**: the enforcement harness (`tests/enforcement/`): real temporary git repositories, hand-written expectations,
a passing and a failing fixture per rule
**Target Platform**: any runner with `pwsh` and `git`
**Project Type**: governance tooling (scripts plus documents)
**Constraints**: byte-identical output wherever every applicable repository graded, and for a `territory-check` run that
hits no refusal (SC-001); the four refusals keep their wording and exit 1
**Scale/Scope**: two scripts changed, one harness recipe field, about a dozen rules' fixtures, four documents, digests

## Constitution Check

- [x] **Specification First (I)**: `spec.md` is approved; this plan follows it; `tasks.md` follows. One place where
  the spec's own text and this plan's recommendation differ is surfaced rather than resolved silently (D2).
- [ ] **Repository Separation (III)**: not applicable, the kit is one repository.
- [x] **Architecture Consistency (IV)**: no new file; both scripts keep their existing structure and their existing
  libraries (`scope-lib.ps1`, `adoption-lib.ps1`).
- [ ] **Domain Invariants (V)**: not applicable, the template's slot is unfilled.
- [x] **Security (VI)**: read-only scripts over local git state; the messages name repositories and branches only.
- [ ] **External Integration Governance (VII)**: not applicable.
- [x] **Testing Requirements (VIII)**: every rule has a passing and a failing fixture, hand-written; four rules leave
  the exemption list.
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI review with Reviewer
  Provenance. Constitution IX is unchanged.
- [x] **Controlled Delivery (X)**: three phases, one at a time. This changes enforcement scripts, so the owner runs
  the gate: no batching, no ci-held. No amendment of X is needed.

**Phase sizing rule**: phase 1 changes no verdict for a run in which every applicable repository graded and is useful
alone. Phase 2 touches a different script and depends on nothing from phase 1. Phase 3 is documents and measurement
and depends on both. Reverting 3, then 2, then 1 leaves a consistent kit.

**Post-design re-check**: no new violation. One decision needs the owner (D2).

## Decisions

**D1 — Count, per repository, whether it graded (FR-001, FR-002).** In `scope-check-repos.ps1`'s dispatch loop each
applicable repository gets its own graded counter next to the run's `$graded`, and an `$ungradedRepos` list is kept.
A repository is applicable exactly when the loop reaches the point where it has a `$commits` decision to make: it
passed the five `n/a` guards (declared and present, a repository of its own, carrying the `$Branch` branch). It joins
`$ungradedRepos` at the two existing `UNGRADED ... continue` sites (no merge base; no commits since it) and, under
`-All`, when its loop over `$commits` ends with its own counter at zero (every offered commit was skipped: a merge
commit, no `phase N` token, an unresolvable commit). A repository that graded at least one commit is never named.

**D2 — Which mode the run-level line covers (FR-001; the one decision for the owner).** Spec FR-001 says "grades no
commit in the run" without naming a mode. In tip mode (no `-All`; the per-phase command `docs/sdlc/review-process.md`
step 3 tells a human to run) a repository whose tip is not a phase commit prints `not applicable (... carries no
'phase N' token)` by design, and the same document says that is the right answer for a phase that touches no code
repository. Counting that as ungraded would turn every per-phase run on a two-repository feature `UNGRADED` whenever
one repository was not touched by the phase: noise that trains the reader to ignore the word, which is the failure
this feature exists to remove. CI runs `-All` (`scripts/ritual-checks.ps1:151`), where the range is the feature's
whole history and zero graded commits in an applicable repository is a real hole. **The plan implements: the
partly-graded run-level line under `-All` only; tip mode keeps today's behaviour (the existing line when nothing graded
anywhere, nothing otherwise).** FR-001 was amended to say so (anas.m, 2026-10-12); see Needs the owner (1).

**D3 — The line's words (FR-001, FR-003).** The existing line, for a run that graded nothing anywhere, is kept
verbatim. A new line is printed when at least one repository graded and `$ungradedRepos` is not empty:
`scope-repos: UNGRADED (<n> declared code repositor(y|ies) applied to '<branch>' and graded nothing: <names> — the reason is on the line(s) above; graded: <names>)`.
It begins `scope-repos: UNGRADED` so `ritual-checks.ps1`'s anchored match lifts it with no change. It is printed under
a `FAIL` too (the run exits 1 regardless, and the line names the unread repository); under `FAIL` the member verdict
is `FAIL` and the aggregator reads the line only on exit 0, as it does today. Exit code: 0 on this account alone.

**D4 — The hint (FR-004).** The text after the dash on the no-merge-base line, `pass -BaseRef <ref> naming its trunk`,
becomes `to grade it, run: pwsh -File scripts/scope-check-repos.ps1 -All -Repo <repo> -BaseRef <trunk>`, with the
repository's own name filled in. The rest of the line is unchanged. This is the one change to an existing
expectation: `REPOS-015/fail`'s `expected.txt`, shown failing and then passing. `-BaseRef` itself is not changed: it
still replaces the trunk candidates of every repository when `-Repo` is absent, and the note says so.

**D5 — No pass-through in `ritual-checks.ps1` (FR-005).** Not added; the per-repository form exists and the aggregator
already lifts the new line. `ritual-checks.ps1` is untouched, which the scope check will show.

**D6 — The refusals reach their exit (FR-006).** `territory-check.ps1` gains one small function, `Stop-Refused`,
which writes the message to the error stream with `[Console]::Error.WriteLine` and calls `exit 1`; the four
`Write-Error ...; exit 1` sites become `Stop-Refused ...` calls with the **same** message text. The message stays on
the error stream, where `Write-Error` put it for a human at a terminal, and the harness already reads both streams.
What a human no longer sees is PowerShell's "At line:..." position noise that `Write-Error` appended; the wording the
spec pins is the message. `exit` inside the function terminates the script, and the `try`/`finally` that pops the
location still runs. `emission-idioms.json` gains an accumulator for the new call so the coverage sweep still sees the
four sites; the `Write-Error\s` accumulator is removed from this script's entry because no site uses it after the change.

**D7 — The harness needs one recipe field (FR-007).** `TERR-009` (a branch that is not `NNN-name`), `TERR-010` (a
failed fetch: `origin` pointing at a path that does not exist) and `TERR-011` (a base that cannot be diffed: the
fixture's trunk is not `main`) are all reachable with fields the recipe already has. `TERR-008` (outside a git
repository) is not: `tests/enforcement/lib/FixtureRepo.psm1` always initialises a repository. A recipe field `noGit`
removes the `.git` directory after the fixture is written, with a self-test per the harness's own convention (a case
that ignores the field fails loudly against the healthy fixture). That edit is inside `tests/**` and is the only
harness change.

**D8 — Exemptions come out (FR-007).** The `exemption` and `notes` entries of `TERR-008` to `TERR-011` in
`tests/enforcement/rules.json` are removed and replaced by `fixtures`-bearing entries like their neighbours, so the
coverage test's "exempt rule has no fixtures" and "every rule has a pair" checks hold in the other direction. The count
of exempt rules in the coverage report drops from seven to three.

**D9 — Adopter guidance and measurement (FR-009, FR-010).** `docs/sdlc/review-process.md` step 3 today says one
repository going ungraded does not change the run-level verdict while another graded, so read the per-repository
lines: that sentence becomes the statement of what the run-level line now guarantees (under `-All`) and keeps "read
the per-repository lines" for tip mode. `adoption/updating.md` gains a flow-down note shaped like feature 021's, and
its feature 015 disclosure and feature 018 territory paragraph stop describing behaviour the scripts no longer have.
`docs/roadmap.md` marks GAP-029 and GAP-030 closed with the decisions-log entry and the feature's row `shipped`. The
measurement of SC-003 clones FitForge, FlowBoard and ExpenseTracker from their local directories (never the real ones,
never pushed), applies the kit before and after this feature, and runs `scope-check-repos.ps1 -All` and
`ritual-checks.ps1` on each, listing every line that moves; FitForge, the only project with declared code
repositories, is the one that can.

## Phases

Detailed tasks and the per-phase **Territory** blocks are written by `/speckit.tasks`.

1. **The run-level verdict and the hint.** D1, D2, D3, D4, D5. Delivers US1 and US2 and FR-001 to FR-005. Fixtures
   first, shown failing on the parent; new rules `REPOS-034` (a partly graded run under `-All` is `UNGRADED` at run
   level) and the changed `REPOS-015` expectation.
2. **The four refusals.** D6, D7, D8. Delivers US3 and FR-006, FR-007: `Stop-Refused`, the `noGit` recipe field, the
   `TERR-008` to `TERR-011` fixtures, the exemptions removed.
3. **Guidance, flow-down, measurement.** D9. `docs/sdlc/review-process.md`, `adoption/updating.md`,
   `docs/roadmap.md`, digests, and the measurement over the three clones (US4, FR-009, FR-010, SC-003).

## Project Structure

### Documentation (this feature)

```text
specs/022-verdict-honesty-repos-territory/
├── spec.md
├── plan.md              # this file
├── tasks.md             # /speckit.tasks, not this command
└── notes.md             # phase evidence, the measurement
```

### Source Code (repository root)

```text
scripts/scope-check-repos.ps1            # phase 1: per-repository counter, run-level line, hint
scripts/territory-check.ps1              # phase 2: Stop-Refused at the four sites
tests/enforcement/lib/FixtureRepo.psm1   # phase 2: the noGit recipe field
tests/enforcement/rules.json             # phases 1-2: REPOS-034, REPOS-015, TERR-008..011 leave the exemptions
tests/enforcement/emission-idioms.json   # phases 1-2: accumulators for the new emission sites
tests/enforcement/cases/                 # phases 1-2: fixtures
docs/sdlc/review-process.md              # phase 3
adoption/updating.md                     # phase 3: flow-down note
docs/roadmap.md                          # phase 3
docs/digests/**                          # phase 3
```

**Structure Decision**: no new script and no new library file. Both scripts ship verbatim, so `kit-manifest.json`
needs no entry. `scripts/ritual-checks.ps1` is deliberately absent from the list.

## Testing Strategy

- Each rule is first written as a failing fixture and shown failing on the parent commit, then the behaviour lands.
  The two-repository fixtures for phase 1 use the harness's `nestedRepos`.
- Phase 1 fixtures: `REPOS-034` `fail` (one repository graded `PASS`, the other with no resolvable trunk, `-All`:
  the line and exit 0), `fail-skipped-commits` (the other repository's only commits are merge or non-phase commits),
  `fail-beside-a-failure` (a `FAIL` beside an ungraded repository: exit 1, the line present), `pass` (both graded:
  byte-identical to the parent, no line), `pass-tip-mode` (D2: the same fixture without `-All` prints no new line),
  `pass-absent-repository` (a declared but absent repository stays `n/a` and does not make the run `UNGRADED`).
  `REPOS-015/fail` changes its expected output for the hint (D4); a case runs the printed hint against a trunk-named
  fixture and expects a graded verdict (SC-005).
- Phase 2 fixtures: a `fail` and a `pass` for each of `TERR-008` to `TERR-011` differing only in the condition, the
  `fail` expecting the message and exit 1 (not 97); the full existing territory-check set unchanged.
- A member-level case (`ritual-checks`) for SC-004: one graded and one ungraded repository gives the member
  `UNGRADED`, and both graded gives `OK`.
- The full harness runs on an isolated checkout of the final commit (feature 021's method); `-Case REPOS-`, `-Case
  TERR-`, `-Case RIT-` per phase.
- The measurement of D9, recorded in `notes.md`.

## Risks

- **A new `UNGRADED` in FitForge's CI.** FitForge declares two code repositories and CI runs `-All`. A repository that
  carries the feature branch but no `phase N` commit yet (setup commits only, say) now makes the member `UNGRADED`
  where it was `OK`. That is true (nothing was compared there) and exits 0, but it is a verdict that moves. Mitigation:
  the phase 3 measurement lists it, the update note names it, and `UNGRADED is not a pass` is the existing guidance.
- **Tip mode unchanged is a narrower fix than the spec's text.** See D2 and Needs the owner (1).
- **`Stop-Refused` and stream order.** The harness concatenates stdout then stderr; a refusal prints nothing on stdout
  before it, so the order is not observable. A later refusal added after other output would need the case written with
  that in mind.
- **The `noGit` recipe field relies on the fixture directory being outside any repository.** The harness builds
  fixtures under the system temp directory; if that sits inside a repository the case would read that repository, so
  the case's expected output names the refusal and fails loudly rather than passing.
- **`claim-feature.ps1` has the same defect** (`Write-Error` then `exit 1` under `$ErrorActionPreference = 'Stop'`, at
  `scripts/claim-feature.ps1:72`, `:79`, `:84`, `:96`, `:108`). It is outside this feature's scope and territory; it is
  recorded in `notes.md` as a candidate roadmap gap, not fixed here.

## Needs the owner

1. **Decided (anas.m, 2026-10-12): D2, the scope of FR-001.** FR-001, US1 scenario 2, the edge-case bullet and the assumption now say `-All`; the
   original question follows. The spec's FR-001 reads as covering tip mode too; the plan covers `-All` only, for the
   reason in D2. Recommended: approve an amendment of FR-001 to "under `-All`", of the edge-case bullet to match, and of
   US1 scenario 2 to say "under `-All`". The alternative is the spec as written, under which every per-phase tip run on
   a multi-repository feature whose phase touched one repository ends `UNGRADED`; say if you want that, and the plan's
   `pass-tip-mode` fixture and D2 change.
2. **Decided (anas.m, 2026-10-12, by approving the plan as written): the error stream, D6.** The stream (Assumptions; spec leaves it to the plan). D6 keeps the refusal on the error stream. Say if you want
   it on standard output instead, as `scope-check-repos.ps1` prints its own errors; it changes only which stream, never
   the wording.
3. **The plan's approval**: given (anas.m, 2026-10-12), then `tasks.md`.

## Complexity Tracking

No Constitution Check violation to justify.
