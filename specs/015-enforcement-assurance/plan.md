# Implementation Plan: Enforcement Assurance

**Branch**: `015-enforcement-assurance` | **Date**: 2026-09-19 | **Spec**: specs/015-enforcement-assurance/spec.md
**Input**: Feature specification + decisions D1–D12 below
**Gate Batching**: none
**Gate Certification**: ci-held

## Summary

Build a fixture-based test harness over the nine scripts that decide a verdict, prove it by
closing the three recorded fail-opens, and give the kit one verdict vocabulary with a word for
*this check formed no opinion*.

Six phases, each independently revertible. The harness arrives first and is proved on one
script; the two parser fail-opens (GAP-025, GAP-026) close second, because closing defects that
really happened is the only honest demonstration that the harness works; the bulk of the
fixtures follow; the vocabulary change (GAP-027) comes late, after enough of the pack is under
test to notice what it breaks; and coverage becomes blocking last, when there is coverage to
block on.

The harness is **kit-only**. It never reaches an adopted project — a new manifest class says so
and `update-kit.ps1` honours it. What does reach them is the verdict vocabulary, and that is the
one part of this feature with a flow-down note.

## Technical Context

**Language**: PowerShell 7 (the kit's only scripting surface) + JSON for the rule inventory and
fixture recipes. **Testing**: Pester 5, pinned — the one new dependency this feature asks for
(D2). **Target platform**: `ubuntu-latest` with `shell: pwsh` (what CI runs today) **and** a
Windows runner (what development uses); SC-006 makes a divergence between them a failure.
**Storage**: temporary git repositories under the system temp directory, created and destroyed
per fixture. **Constraints**: no network at run time; the harness must not touch the repository
it runs from; expectations are literal text, never computed through the code under test.
**Scale**: nine grading scripts, 4,264 lines, a rule inventory whose measured floor is ~120
distinct failure conditions.

**Phase-sizing**: six phases. Phase 1 builds machinery and proves it on one check, so its own
shape is reviewable before 120 fixtures are written against it. Phases 3 and 4 are bulk fixture
work split by script family, either revertible without the other. Phase 5 is the only behaviour
change to shipped scripts that adopters will see. Phase 6 flips coverage from reporting to
blocking, which is a one-line policy change that must come after the coverage exists.

## Decisions

**D1 — Fixtures are data; the runner is borrowed.** A fixture is a JSON recipe (files, commits,
branches, clone depth) plus a literal expected-output file. Nothing in a fixture is PowerShell.
This keeps FR-006 structurally enforceable: an expectation that cannot execute cannot call the
parser it is meant to check.

**D2 — Pester 5, pinned, installed explicitly.** The alternative — hand-rolling a test runner —
is what this kit would flag in someone else's repository: a bespoke framework is itself untested
machinery, and the harness's whole claim is that untested machinery is how fail-opens happen.
Pester is the PowerShell standard. Two constraints ride along, both from SC-006: CI installs a
**pinned version explicitly** rather than trusting a runner image's preinstalled module, and the
harness imports it with an explicit minimum version, because this development machine carries
Pester **3.4.0** in `C:\Program Files\WindowsPowerShell\Modules` and an unqualified
`Import-Module Pester` finds it. This is the package `plan.md` must approve (CLAUDE.md, Strict
Rules); approving this plan approves it.

**D3 — The harness is kit-only, and the manifest gains a class to say so.**
`kit-manifest.json` has three classes — `verbatim`, `surgical`, `generated` — and no way to
state *this file belongs to the kit and never flows down*. Today that concept exists as a
hard-coded exclusion for `docs/roadmap.md` inside `doc-lint.ps1`. A fourth class, **`kit-only`**,
names it. Without it the test workflow under `.github/` matches the `.github/**` verbatim glob
and would be copied into every adopted project by the next update — a CI job for tests they do
not have, failing on a module they never installed. `tests/` itself needs no entry: it is not
one of doc-lint's shipped surfaces.

**D4 — The pass word stays `OK`.** The proposal standardised on `PASS`; the kit has printed `OK`
since feature 002, in nine scripts, three adopted projects, and every gate record written to
date. Renaming it buys consistency with a document that is not a rung on the ladder
(constitution II) and costs a sweep of every adopter's expectations. The vocabulary is therefore
**`OK`, `FAIL`, `WARN`, `PENDING`, `N/A`, `UNGRADED`**.

**D5 — `UNGRADED` is the state this feature exists to name.** It means *the check ran and formed
no opinion* — no computable diff base, unreadable history, a depth-1 clone whose base is absent.
It is not `N/A` (the check does not apply — a different and honest claim), not `WARN` (advisory
about something observed), and not `FAIL`. Feature 014 phase 5 made this condition audible in
the log body; this feature makes it **visible in the verdict**, which is what a reader and a
status badge actually see.

**D6 — `UNGRADED` changes the verdict, not the exit code.** FR-009 of feature 014 forbids a new
hard failure on the Lite lane, and that constraint stands: a run that grades nothing keeps
today's exit code. What changes is that no one can read it as clean. Whether `UNGRADED` should
ever block is a question for a later feature with its own evidence; this plan deliberately does
not answer it.

**D7 — `PENDING` is reserved and emitted by nothing.** It belongs to GAP-022 — a Critical branch
red from its first commit to its last — which is out of scope (spec, Out of Scope). Defining the
word now costs one row in the vocabulary and means GAP-022's eventual fix is not also a
vocabulary change. A state nothing emits is documented as reserved, not left implicit.

**D8 — Coverage is graded against an inventory, and a short inventory fails.** The obvious
failure mode of coverage-by-inventory is that the inventory silently omits a rule, so coverage
reads 100% of a list that is wrong. The harness therefore cross-checks the inventory against the
scripts themselves — every failure-emission site must resolve to an inventoried rule — and fails
when it finds one that does not. "The inventory is short" must never be the state that reads as
green; that is the same defect as every gap in the ledger, committed by the tool built to
prevent it.

**D9 — Coverage grading is reporting-only until phase 6.** With ~120 rules and fixtures arriving
over three phases, a blocking coverage check would make the branch red from phase 1 to phase 5 —
which is GAP-022's disease, and this feature is not allowed to catch it while filing it as out of
scope. Coverage reports a count and a list from phase 1 and becomes blocking in phase 6, when
there is coverage to block on.

**D10 — A fixture must prove the rule was exercised.** A passing fixture that asserts "no
failure reported" is indistinguishable from a check that returned early and graded nothing —
precisely GAP-027's shape. Every rule's pass-direction fixture is therefore paired with its
fail-direction fixture over the *same* repository recipe, differing only in the condition under
test, so a check that never ran fails the pair. A rule whose pass and fail fixtures do not share
a recipe must state why in the inventory.

**D11 — The three GAPs are closed test-first.** For each, the fixture is written and demonstrated
failing against the current implementation *before* the fix lands, and the phase's notes record
both runs. This is the difference between a harness that documents a fix and a harness that
proves one. GAP-025 and GAP-026 are phase 2; GAP-027 is phase 5, because its fix is the
vocabulary itself.

**D12 — Fixtures build real repositories, including broken ones.** Every defect the nine review
rounds of feature 014 found was about git reality: `cat-file -e` vs `-s` vs `blob` on a truncated
object, `merge-base` returning empty, `%P` field ordering, `core.quotepath`, CommonMark fence and
inline-span visibility. The recipe format therefore supports shallow clones, absent bases, and
deliberately corrupt objects as first-class fixture states, because those are the states where
the checks were wrong.

## Constitution Check

Source: `.specify/memory/constitution.md` (version 0.7.0).

- [x] **Specification First (I)**: `spec.md` is written and approved before this plan;
      `tasks.md` follows this file. Amendments to any of the three record their approver.
- [x] **Source of Truth (II)**: No conflict. The `review/` documents are explicitly not rungs;
      where this plan departs from the proposal (D4, and GAP-022's exclusion) it says so.
- [x] **Repository Separation (III)**: N/A — the kit is a single governance repository with no
      `codeRepos` declared.
- [x] **Architecture Consistency (IV)**: One new dependency (Pester 5, D2) and one new manifest
      class (`kit-only`, D3), both approved here and nowhere else.
- [x] **Domain Invariants (V)**: N/A — the kit declares no domain-invariants pack.
- [x] **Security (VI)**: No secrets, no network at run time, no credentials. Fixtures run git
      against temporary directories with a fixture-local identity, never the user's.
- [x] **External Integration Governance (VII)**: N/A — no external integration. PSGallery is a
      setup-time package source, not a runtime integration.
- [x] **Testing Requirements (VIII)**: This feature *is* the item this principle has been owed
      since feature 002.
- [x] **Human Review (IX)**: Every phase takes a fresh-context AI review with the Reviewer
      Provenance block, then human review before merge. The harness does not review itself.
- [x] **Controlled Delivery (X)**: Six phases, one at a time, each independently revertible,
      each its own commit with a declared Territory. `ci-held` certification, declared here
      before the first phase, as features 009, 011 and 014 did.

## Project Structure

### Documentation (this feature)

```text
specs/015-enforcement-assurance/
├── spec.md
├── plan.md              # this file
├── tasks.md
├── notes.md             # per-phase evidence, incl. the test-first runs of D11
├── ai-code-review.md    # per phase, from specs/_templates/
├── human-pr-review.md   # at merge, from specs/_templates/
└── rollback.md          # from specs/_templates/
```

### Source Code (repository root)

```text
tests/enforcement/rules.json              # NEW  phase 1 — the rule inventory (FR-001)
tests/enforcement/lib/FixtureRepo.psm1    # NEW  phase 1 — builds a repository from a recipe (D1, D12)
tests/enforcement/lib/Harness.psm1        # NEW  phase 1 — runs a case, compares literal output (D1, FR-007)
tests/enforcement/Run-Tests.ps1           # NEW  phase 1 — the one documented local command (FR-018)
tests/enforcement/Coverage.Tests.ps1      # NEW  phase 1 — inventory vs scripts, vs fixtures (D8, D9)
tests/enforcement/cases/**                # NEW  phases 1-5 — one directory per rule/direction
kit-manifest.json                         # MOD  phase 1 — the kit-only class (D3)
scripts/update-kit.ps1                    # MOD  phase 1 — kit-only is never copied (D3)
scripts/doc-lint.ps1                      # MOD  phase 1 — kit-only counts as classified (D3)
.github/workflows/enforcement-tests.yml   # NEW  phase 1 — both platforms, pinned Pester (FR-017)
scripts/build-digests.ps1                 # MOD  phase 2 — inline code spans hide no marker (GAP-025)
scripts/scope-lib.ps1                     # MOD  phase 2 — decorated Territory marker; WARN becomes FAIL (GAP-026)
scripts/enforcement-pack.ps1              # MOD  phase 5 — the UNGRADED verdict (GAP-027, D5, D6)
scripts/ritual-checks.ps1                 # MOD  phase 5 — the verdict block carries UNGRADED
adoption/updating.md                      # MOD  phase 6 — the flow-down note (FR-021)
docs/sdlc/review-process.md               # MOD  phase 6 — what a reviewer does with UNGRADED
```

**Structure Decision**: The harness lives under a new top-level `tests/`, which is not one of
`doc-lint.ps1`'s shipped surfaces and therefore never flows down. The one file that *would*
flow down is the workflow, and D3's `kit-only` class is what stops it.

## Testing Strategy

The feature's subject is testing, so the risk of circularity is real and is handled explicitly:

- **The harness is proved against known-bad code, not against itself.** Phase 2's two fixtures
  are demonstrated failing on the parent commit of their fix (D11). Phase 1's proof is the same
  move on a smaller scale: one check, one deliberately inverted condition, one named failure.
- **Mutation sampling, not coverage percentage.** SC-002 is verified by inverting a sampled
  rule's condition and confirming a named fixture fails — a claim about the fixtures' power,
  which a coverage count cannot make.
- **The harness's own correctness is reviewed, not tested.** There is no meta-harness. Phase 1
  is therefore the phase most in need of a hostile fresh-context review, and its review brief
  says so.
- **Platform divergence is a test failure** (SC-006), not an environment note. Both CI legs run
  the same fixtures.

## Complexity Tracking

| Addition | Why needed | Simpler alternative rejected because |
|---|---|---|
| Pester 5 (D2) | A test framework for a harness whose argument is that untested machinery fails silently | A hand-rolled runner is bespoke untested machinery — the exact thing this feature exists to remove |
| `kit-only` manifest class (D3) | The test workflow under `.github/` otherwise matches the verbatim glob and lands in three adopted projects | Guarding the job with `hashFiles()` leaves a permanently skipped job in every adopter's CI and still copies the file |
| A rule inventory (D8) | Coverage cannot be graded without a denominator | Counting test files measures effort, not coverage |

**The risk this plan carries knowingly.** Phase 5 changes what a green `enforcement-pack` line
means for three adopted projects. It is late in the sequence for that reason, and it is the only
phase whose flow-down note (phase 6) is mandatory rather than courteous.
