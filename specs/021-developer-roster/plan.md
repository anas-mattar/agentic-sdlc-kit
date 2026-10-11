# Implementation Plan: Load-bearing developer roster

**Branch**: `021-developer-roster` | **Date**: 2026-10-11 | **Spec**: specs/021-developer-roster/spec.md
**Input**: Feature specification (approved; FR-007 decided) + decisions D1–D10 below
**Gate Batching**: none
**Gate Certification**: user-run
**Amendment approved by**: anas.m, 2026-10-11

## Summary

Make the `developers` array in `kit-adoption.json` something checks read, not just count, without moving any
verdict for a project that writes strings only or nothing. Four phases, each independently revertible. First the
reader: `Get-DeveloperMode` learns the object form and exposes a normalised roster, and the doctor reports it.
Then the first of the three readings that needs only the reader and one existing check: a Critical feature's
Reviewer must be on the roster and permitted. Then the two readings that live in the claim ledger: a claim's Owner
is on the roster, and an Owner's non-stale claims are counted against the WIP cap. Last the guidance, the
flow-down and the measurement on clones of the three adopted projects.

## Technical Context

**Language/Version**: PowerShell 7+ (`pwsh`)
**Primary Dependencies**: none new. Reuses `scripts/adoption-lib.ps1` (the reader), git, `scripts/roadmap-claim-check.ps1`'s table reader
**Storage**: files and git state only; the checks write nothing (the claim check fetches claim tips, a ref update)
**Testing**: the enforcement harness (`tests/enforcement/`): real temporary git repositories (a claim ledger is a
fixture `origin`), hand-written expectations, a passing and a failing fixture per rule
**Target Platform**: any runner with `pwsh` and `git`
**Project Type**: governance tooling (scripts plus documents)
**Constraints**: a project that writes strings only, or nothing, sees byte-identical output from every check; no
new hard failure for a project with no roster; exit codes unchanged; no new package, no new script file
**Scale/Scope**: one library function extended, three scripts changed, one wiring list in `ritual-checks.ps1`,
three documents, about 30 new fixtures

## Constitution Check

- [x] **Specification First (I)**: `spec.md` is approved; this plan follows it; `tasks.md` follows.
- [x] **Source of Truth (II)**: one conflict is recorded rather than resolved silently: spec US2 scenario 3,
  FR-005 and FR-007 say the check "says so" when no roster is declared, while SC-001 requires every existing
  verdict, and the existing fixtures' output, to be byte-identical. Both cannot hold (D5). It is surfaced as an
  owner decision below.
- [ ] **Repository Separation (III)**: not applicable, the kit is one repository.
- [x] **Architecture Consistency (IV)**: the reader stays the one reader in `scripts/adoption-lib.ps1`, which its
  own header exists to guarantee ("two graders of one rule drift"); no new file.
- [ ] **Domain Invariants (V)**: not applicable, the template's slot is unfilled.
- [x] **Security (VI)**: reads local records and git state; logs names and claim ids, nothing sensitive. See D9 on
  what membership does and does not prove.
- [ ] **External Integration Governance (VII)**: not applicable.
- [x] **Testing Requirements (VIII)**: every rule has a passing and a failing fixture, hand-written.
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI review with Reviewer
  Provenance. Constitution IX is unchanged.
- [x] **Controlled Delivery (X)**: four phases, one at a time. This changes enforcement scripts, so the owner runs
  the gate: no batching, no ci-held. No amendment of X is needed (spec Assumptions).

**Phase sizing rule**: phase 1 changes no verdict for any existing record and is useful alone (the doctor reports a
roster). Phase 2 depends on phase 1's reader only. Phase 3 depends on it and on nothing from phase 2. Phase 4 is
documents and measurement. Reverting 4, then 3, 2, 1 leaves a consistent kit; phase 4 must not be reverted last.

**Post-design re-check**: no new violation. One spec inconsistency needs the owner (D5).

## Decisions

**D1 — One reader (FR-001, FR-002).** `Get-DeveloperMode` stays the only interpreter of the record. It keeps every
field it returns today (`Mode`, `Count`, `Declared`, `Why`, `Problems`) with identical values for a string-only or
absent roster, and gains `Roster`: the usable entries, deduplicated case-insensitively, each `@{ Name; Repos;
CanApproveCritical }`. A string entry is `@{ Name = <s>; Repos = @(); CanApproveCritical = $true }`. `Mode` and
`Count` are taken over the unique names of both forms, so `["ada", {"name":"Ada"}]` is one developer.

**D2 — Entry grammar and the safe reading of each degenerate input (FR-003).**
- A string entry: non-blank after trimming, as today.
- An object entry needs a `name` that is a non-blank string; without one the entry is dropped and reported.
- `repos`, when present, must be an array of strings; anything else is reported and read as no repos. A name the
  record's `codeRepos` does not declare is reported by the doctor and kept as written (spec FR-012: never a reason
  to fail a feature).
- `canApproveCritical`, when present, must be a boolean. A non-boolean (`"false"`, `0`, `null`) is reported and read
  as **not permitted**: the safe direction for a permission, as feature 013's every degenerate input resolves to
  the stricter arm. Missing means permitted (spec FR-003).
- Unknown keys on an object entry are ignored silently, so a later feature can add one without a failure here.
Before this feature an object entry was reported as "a blank or non-string entry" and dropped, which could move a
project to solo; no adopted project writes one, and the doctor message for a string-only record is unchanged.

**D3 — Matching.** Names compare after trimming, ordinal and case-insensitive, exact otherwise. No prefix, no
fuzzy, no mapping between a handle and a display name: a roadmap Owner `Anas M.` against a roster entry `anas.m` is
a mismatch and the failure names both, so the fix is visible (D9, Risks).

**D4 — Reading one, the Owner (FR-005).** `scripts/roadmap-claim-check.ps1` already reads the roadmap tables and
maps a claim to its row by text. It additionally finds the `Owner` column of the same table and, for each claim on
`origin` whose matching row has a non-`idea` Status and a real Owner cell (not blank, not `—`), requires the Owner on
the roster. It dot-sources `scripts/adoption-lib.ps1` for the roster (a verbatim script already in every adopted
project). The checked branch's own claim stays exempt, as for visibility: its row may ride the very change
(precedent, the script's own header). Graded only with a usable roster.

**D5 — The "says so" conflict, and what the plan does until the owner rules.** Spec US2 scenario 3, FR-005 and
FR-007 each say that with no usable roster the check "says so"; SC-001 says every existing verdict and every
existing fixture's expectation stays byte-identical, and nearly every roadmap-claim fixture has no roster. A line
printed for a no-roster project changes the OK line of each of them. The plan implements **silence** for a
no-roster project (the OK line is unchanged and already states exactly what was graded: "claim(s) visible with
non-idea rows"), because byte-identity is the stronger, testable guarantee and the OK line makes no claim about
Owners it did not check. The owner ruled for silence and approved the amendment of the three sentences (spec US2 scenario 3, FR-005,
FR-007).
**Decided**: silence. **Amendment approved by**: anas.m, 2026-10-11.

**D6 — Reading two, the Critical reviewer (FR-006).** In `Invoke-CriticalTeamEvidence`, after the existing
reviewer-is-not-owner check, the Reviewer must appear in `Roster` and its entry must not be non-permitted. Two
failures, two messages (a stranger; a name whose entry denies). Placeholders and an empty Reviewer are already
failures and are not graded twice. The solo arm is untouched. The block comment that says the roster is "COUNTED
and nothing more... never compared" is rewritten: it recorded a real argument (cross-checking free text against
free text reads as verification while providing none), and the honest restatement is D9.

**D7 — Reading three, the WIP count (FR-007).** In `roadmap-claim-check.ps1`, per Owner: the claims on `origin`
whose matching row Status is `specified` or `in progress` (`idea`, `shipped` and `dropped` are not
active) and whose tip commit is not stale (no commit for 14 days, the document's two weeks). More than two fails,
naming the Owner and the claims; exactly two passes with one note that two claims are lawful only under the
pipelining conditions, which a human confirms; graded only with a usable roster. Tip dates come from `git log -1
--format=%ct <sha>` on the sha `ls-remote` already returns, and are read only for an Owner with two or more
candidate claims, so most runs read none. If a tip object is absent the script runs `git fetch --quiet origin
<branch>` for that claim; if the date is still unreadable, that Owner's count is **UNGRADED** and says why, never
silently counted or silently dropped (feature 015's rule: a comparison not made is never `OK`). The script stays
read-only on the working tree; a fetch updates remote-tracking refs only, as `territory-check.ps1` does.

**D8 — UNGRADED needs a wiring change.** `scripts/ritual-checks.ps1` lists the members that can report UNGRADED
(`enforcement-pack`, `scope-check`, `scope-repos`); `roadmap-claims` is not there, so its UNGRADED line would be
read as OK. Adding it is part of phase 3, with a fixture; the member's exit code is unchanged (UNGRADED is a
verdict, never an exit code).

**D9 — What membership proves, written down.** Feature 013 declined this cross-check on the ground that a
free-text roster compared with free-text names reads as verification while providing none. The ground stands and
the guidance says so: the roster is a declared set, so the check catches a stranger, a typo, a name the project did
not declare and a person the record says may not judge; it does **not** prove the person is who the name says.
Independence is still the human reviewer's to judge (the review-process document already says that of
amendments). `docs/sdlc/critical-delivery.md` and `docs/sdlc/team-workflow.md` carry that sentence.

**D10 — The doctor.** `scripts/verify-kit.ps1` reports each malformed entry by position and cause and each
unknown `repos` name (FR-008), and states the roster it read only when at least one entry is an object, so a
string-only project's doctor output is byte-identical. The doctor never fails on `repos`.

## Phases

Detailed tasks and the per-phase **Territory** blocks are written by `/speckit.tasks`.

1. **The reader and the doctor.** D1, D2, D3, D10. Delivers US1 and FR-008; no existing verdict moves.
2. **The Critical reviewer.** D6. Delivers US3.
3. **The claim ledger.** D4, D5, D7, D8. Delivers US2 and US4, including the UNGRADED wiring.
4. **Guidance, flow-down, measurement.** `docs/sdlc/critical-delivery.md`, `docs/sdlc/team-workflow.md`,
   `adoption/updating.md` (and `adoption/greenfield.md` where it describes the record), digests, the roadmap row
   and decisions-log entry, and a measurement over clones of FitForge, FlowBoard and ExpenseTracker (SC-003).

## Project Structure

### Documentation (this feature)

```text
specs/021-developer-roster/
├── spec.md
├── plan.md              # this file
├── tasks.md             # /speckit.tasks, not this command
└── notes.md             # phase evidence, measurements
```

### Source Code (repository root)

```text
scripts/adoption-lib.ps1                 # phase 1: Get-DeveloperMode returns Roster
scripts/verify-kit.ps1                   # phase 1: the doctor reports the roster
scripts/enforcement-pack.ps1             # phase 2: the Critical reviewer reading
scripts/roadmap-claim-check.ps1          # phase 3: the Owner and WIP readings
scripts/ritual-checks.ps1                # phase 3: roadmap-claims becomes UNGRADED-capable
tests/enforcement/rules.json             # phases 1-3: new rules, anchors
tests/enforcement/emission-idioms.json   # phases 1-3: new accumulators if any
tests/enforcement/cases/                 # phases 1-3: fixtures
docs/sdlc/critical-delivery.md           # phase 4
docs/sdlc/team-workflow.md               # phase 4
adoption/updating.md                     # phase 4: flow-down note
adoption/greenfield.md                   # phase 4, if it describes the developers field
docs/roadmap.md                          # phase 4
docs/digests/**                          # phase 4
```

**Structure Decision**: no new script and no new library file. Everything lands in scripts that already ship
verbatim, so `kit-manifest.json` needs no entry.

## Testing Strategy

- Each rule: a passing and a failing fixture in real temporary git repositories (the claim ledger is a fixture
  `origin`, as the `CLAIM-*` cases already build), expectations by hand, coverage graded by the harness's own
  coverage test (SC-002).
- Phase 1 proves "no verdict moves" by the existing suites: every existing case unchanged, the whole harness
  passing with only fixtures added (SC-001), plus new cases for each roster shape.
- The new rules are first written as failing fixtures, shown failing on the parent commit, then the behaviour
  lands.
- Phase 3 includes the three counts (one, two, three claims for one Owner), a stale claim excluded, an Owner not on
  the roster, a no-roster project unchanged, and an unreadable tip date reported UNGRADED.
- Phase 4 applies the update to clones of the three adopted projects, runs the old and new checks, and lists every
  verdict that moved (SC-003); a moved verdict is a finding, not a rounding error.
- `pwsh -File scripts/ritual-checks.ps1` and `pwsh -File tests/enforcement/Run-Tests.ps1` are the gate; the full
  harness is run on an isolated checkout of the final commit.

## Risks

- **A new hard failure in a team project's CI.** FitForge declares two developers, so the Owner and Reviewer
  checks apply to it from the update. Its Owner cells today read `anas.m`, which is on its roster, but an Owner
  written in another form would fail. Mitigation: the phase 4 measurement lists every verdict before the update
  ships, and D3's messages name both strings.
- **The count could be wrong in the fail direction.** Counting a stale or shipped claim would fail a lawful
  Owner. Mitigation: active means a Status of `specified` or `in progress`, tip age is read rather than assumed,
  and an unreadable age is UNGRADED, not counted.
- **Shallow or offline CI.** A claim tip may be absent. D7's fetch and its UNGRADED fallback keep that visible.
- **Roadmap shape.** Adopter roadmaps are adopter-authored; a table with no `Owner` column leaves the Owner and WIP
  readings with nothing to read, and the check says it graded neither rather than passing silently (the existing
  `n/a` idiom).
- **Over-reading the roster.** D9: membership is not identity; the guidance says so in the documents an owner reads.

## Needs the owner

1. **Decided (anas.m, 2026-10-11).** D5, the inconsistency in the approved spec. US2 scenario 3, FR-005 and FR-007 say the check "says so" when
   no roster is declared; SC-001 requires every existing fixture's expectation to stay byte-identical. The plan
   implements silence and asks the owner to approve an amendment of those three sentences to "grades nothing and
   does not claim the Owners were checked" (recommended), or to direct that the OK line gains a note for every
   no-roster project and the existing `CLAIM-*` expectations change.
2. **The checked branch's own claim**, exempt from the Owner and WIP readings as it is from visibility (D4, D7).
   Say if it should be graded when its row already exists. **Approved as written with the plan (anas.m, 2026-10-11).**
3. **The plan's approval** (given, anas.m, 2026-10-11), then `tasks.md`.

## Complexity Tracking

No Constitution Check violation to justify.
