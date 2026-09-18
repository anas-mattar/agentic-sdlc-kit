# Review — Framework Trust Improvement Plan

**Reviewer**: Claude Opus 5 (1M context), 2026-09-18
**Reviewing**: `review/framework-trust-improvement-plan.md` (non-authoritative proposal)
**Verdict**: **Go — with one feature resequenced, one restructured, and three blocking issues
settled before 015 is specified.**

## Reviewer provenance, stated because this kit cares about it

I am **not independent** of feature 014. I implemented phase 5's remediation rounds, wrote its
F3/F4 records and its gate entries, opened and merged PR #42 today. Anything below that touches
`enforcement-pack.ps1`'s amendment check is a self-assessment and should be weighted accordingly.
The proposal's request for an outside reviewer (Fable) stands, and under `review-process.md` a
fresh-context reviewer is required for 015's fixtures over code I have touched.

## The one-line answer

The proposal correctly identifies the kit's largest untreated risk and puts it first. **Feature
015 is the most valuable thing this repository could build right now**, and the evidence is
measurable: **14 enforcement scripts, 4,264 lines, zero automated tests, zero fixtures, no
Pester.** The kit grades everyone else's work with machinery nothing grades.

Feature 016 is right in intent and **dangerous as specified**. Feature 017 is two different
features wearing one number, and half of it is already on the roadmap with an owner-approved
sequence the proposal would silently overwrite.

## What the evidence says about 015

014 needed **nine fresh-context review rounds, every one returning REQUEST CHANGES on first
pass**. Almost every blocking finding was the same species — a check that returned green having
graded nothing — and **every one of them was found by a human reading code, never by a test**.
Three such defects found during 014 are still open as GAP-025, GAP-026 and GAP-027. Phase 5 alone
took three rounds where rounds 1 and 2 each planted the next round's blocker *inside the fix for
the previous one*.

That is the exact failure profile a fixture harness eliminates, and the exact cost profile that
justifies it: nine review rounds is a lot of human attention spent on questions a fixture answers
in 200ms.

## Blocking — settle these before 015 is specified

### B1. The verdict vocabulary is being fixed one state short

015 standardizes `PASS`, `FAIL`, `WARN`, `PENDING`, `N/A`. **GAP-027 (recorded today) needs a
sixth**: a run that *could not grade* — no computable base, unreadable history — is not `N/A` (the
check doesn't apply), not `WARN` (advisory), and not `PENDING` (work legitimately unfinished). It
is "this check has no opinion and you must not read it as clean." Today that condition prints a
warning and the run reports `OK` / exit 0, including for `Invoke-ReviewProvenanceCheck` — so the
member policing whether a review happened can go silent while the badge stays green.

If 015 ratifies five states without that one, it **locks the fail-open into a taxonomy** and
GAP-027 becomes a breaking change later instead of a design input now. Add `UNGRADED` (or
equivalent) to 015's scope, and decide there whether it is exit-code-blocking (FR-009's Lite-lane
constraint says probably not; visible in the verdict block says definitely yes).

### B2. Fixtures must be real git repositories, and must not share code with what they test

Every defect the nine rounds found was about **git and parser reality**, not logic:
`cat-file -e` vs `-s` vs `blob` on a truncated object; `merge-base` returning empty; `%P` field
ordering; `core.quotepath`; CommonMark fence and inline-span visibility; a backticked `<!--`
swallowing a record. A mocked or in-memory fixture reproduces **none** of these. Require: real
temporary repositories, real commits, real shallow clones, real corrupt objects.

And the sharper one — **B7's shape must not be repeatable in the harness**. That defect existed
because the check and its own evidence went through the same parser, so both agreed and both were
wrong. A harness that asserts expected output by reusing the script's own helpers will reproduce
it exactly. Fixture expectations must be literal text, written by hand.

### B3. The prerequisite is one step short of done

014 merged to `main` today (`f02760f`, PR #42; roadmap flipped by PR #43). Steps 1 and 2 of the
prerequisite are satisfied. **Steps 3 and 4 are not**: no kit version has been published and no
adopted project has been updated. FitForge still carries the constitution clause whose
"Enforcement, honestly stated" paragraph says no machine grades this rule — a sentence 014 made
false. That is 014's own SC-005, and it is owed work, not 015's work. Do the flow-down first; it
is also the cheapest possible rehearsal of the migration path 016 will need.

## High — restructure 016 before building it

### H1. `evidence.json` as specified makes self-certification easier, not harder

The document asks the tooling to "generate gate, repository, commit, and diff evidence
automatically" and gives `dev.ps1 submit` the job of producing an evidence draft. Combine those
and you get **the implementing agent producing the artifact that certifies its own work** — the
precise shape this kit's constitution is built to prevent, and the one 014 spent six days
closing for amendments.

Today's `ci-held` gate is stronger than the proposed evidence file in one specific way: its
triplet (run URL + conclusion + head sha) is **fetched from GitHub**, not asserted locally. A
locally generated `evidence.json` is a claim about a run; the run is the evidence.

Make these requirements of 016, not later refinements:

- No evidence field may be written by the process that performed the work it attests to.
- Gate, commit and diff evidence is read from the CI API, keyed on the immutable head sha —
  never from the working tree.
- The proposal's own line — *"Protected hosting-platform identities should become the source of
  human approval"* — moves from Compatibility ("should", "if later introduced") into 016's
  acceptance criteria. Without it, a JSON field named `approvedBy` is **weaker** than today's
  free-text record, because today's record at least requires a human to have written a commit
  message that a later edit cannot fake (constitution I, D5).

### H2. "Reject completed tasks whose evidence is missing" is a constitutional amendment

Constitution I states that a `tasks.md` checkbox moving in either direction is **progress, not
amendment** — deliberately, so the rule is not absurd in its commonest case. Requiring evidence
before a box may be ticked changes that bargain. It may well be the right change, but it arrives
through `.specify/memory/constitution.md` and an amendment record, not through a script's
behaviour. Ship it as a clause first, exactly as 014 shipped its clause before its check.

### H3. 017 is two features, and one half is already sequenced

The `dev.ps1` diagnostics half is good, cheap, and additive. The team half is **already on the
roadmap**, and the proposal neither cites nor supersedes it:

| 017 bullet | Existing row |
|---|---|
| Expand the developer roster (name, repo permissions, Critical eligibility) | **GAP-024 + GAP-004**, "Load-bearing developer roster", P2 |
| Detect territory overlap across declared code repositories | **GAP-018**, "Cross-repo territory reach", P2 |
| *(absent)* | **GAP-023**, "Level declaration graded", **P1** |

The roadmap's decisions log carries an owner-approved sequencing ruling from 2026-09-13:
*"GAP-023 first, because it is the only one that changes what a check dispatches on and because a
level chosen wrongly costs the strictest lane silently"*, with the roster explicitly sequenced
**behind** it. Shipping 017's roster without GAP-023 reverses that decision without recording the
reversal — in a kit whose newest feature exists to stop exactly that. Either honour the sequence
or amend it in the open.

### H4. The 5-second target has no baseline in the document

Measured today on this repository (Windows 11, pwsh 7, warm): **`ritual-checks` 82.2s / 80.0s**;
`enforcement-pack` alone ~20s; the amendment boundary probe ~3.7s of it. A 5-second fast path is
therefore not a flag on the current pipeline — it is a different code path. Specify what `--fast`
*drops*, and how the kit prevents `--fast` from quietly becoming the only thing anyone runs. (A
green `--fast` that reads like a certification is a new fail-open, in a proposal about fail-opens.)

## Medium

- **M1. GAP-025 and GAP-026 should be 015's first two fixtures.** Both are parser fail-opens
  (`build-digests.ps1` blind to inline code spans; `Get-Territory` blind to a decorated marker,
  degrading to a non-blocking WARN). Closing them *with* the harness proves the harness works on
  defects that really happened, rather than on invented ones.
- **M2. "Windows PowerShell" in CI would lose coverage the kit has.** `ritual-checks.yml` runs
  `ubuntu-latest` with `shell: pwsh`, while all development here is Windows. That split is itself
  a fail-open source (CRLF, path separators, case sensitivity — CRLF warnings appear on every
  commit in this repo). Run the harness on **both**, and treat a platform-dependent verdict as a
  test failure.
- **M3. GAP-022 is 015's `PENDING` in disguise, and it is unrowed by choice.** The bullet "report
  final Critical human review as PENDING during implementation and FAIL only at merge readiness"
  is precisely GAP-022 — a Critical branch red from first commit to last, training its owner that
  red is normal. Observed live on FitForge 002 across ten phases. If 015 fixes it, say so and give
  it its row; it is the one item here with a real observed victim.
- **M4. No migration blast-radius statement.** When 011 shipped, adopted projects with stale
  `NNN-*` branches newly failed CI and that needed an announcement. 015–017 will newly fail
  projects whose evidence predates the schema. The proposal promises a migration report; it should
  also promise the *pre-announcement* and a way to see, before updating, which of an adopter's
  branches will turn red.

## What I would actually do, in order

1. **Flow-down 014** to FitForge and the other adopted projects; publish the kit version. Closes
   014's SC-005 and rehearses the migration channel. (Days, not weeks.)
2. **Feature 015, scoped as proposed plus B1/B2**, and prove it by closing GAP-025, GAP-026 and
   GAP-027 as its first fixtures. This is the highest-value work available.
3. **GAP-023 (level declaration graded)** — small, P1, owner-sequenced first, and it makes every
   later check dispatch on something verified.
4. **017's `dev.ps1` diagnostics half** — read-only, no new authority, immediate daily value.
5. **016**, restructured per H1/H2: the constitution clause first, CI-sourced evidence second,
   platform identity for approval third. This is the largest and riskiest item; it should be last,
   and it should be a Critical-level feature by its own criteria.
6. **017's team half**, as the existing GAP-024/GAP-018 rows, after a roster has something to
   dispatch on.

## What the proposal gets right and should keep

The compatibility posture is correct throughout: legacy readable, explicit opt-in, migration
report, diagnostics before automatic remediation, break-glass that expires and never manufactures
a `PASS`. The insistence that every failure names the governing rule, the evidence inspected and a
safe remediation is the single best line in the document — it is what FR-008 asks of one check,
generalised to all of them. And the framing block at the top ("this document does not authorize
implementation") is exactly right under constitution II: a proposal is not a rung on the ladder.
