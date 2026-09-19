# Feature Specification: Enforcement Assurance

**Feature Branch**: `015-enforcement-assurance`  
**Created**: 2026-09-19  
**Status**: Approved 2026-09-19 (owner: anas.m)  
**Delivery Level**: Standard  
**Input**: User description: "Fixture-based test harness over every enforcement script, proven by closing the three recorded fail-opens"

## Context

The kit grades everyone else's work with machinery nothing grades. Nine scripts decide
whether a phase passes: `enforcement-pack.ps1`, `scope-check.ps1`, `scope-check-repos.ps1`,
`doc-lint.ps1`, `verify-kit.ps1`, `build-digests.ps1`, `roadmap-claim-check.ps1`,
`territory-check.ps1` and `ritual-checks.ps1` — 4,264 lines across `scripts/`, with **zero
automated tests and zero fixtures**.

The cost is measured, not asserted. Feature 014 needed **nine fresh-context review rounds,
every one returning REQUEST CHANGES on first pass**. Almost every blocking finding was one
species — *a check that returned green having graded nothing* — and every one was found by a
human reading code. Three such defects are still open (GAP-025, GAP-026, GAP-027). In phase 5,
rounds 1 and 2 each planted the next round's blocker *inside the fix for the previous one*.

That is the failure profile a fixture harness eliminates, and the cost profile that pays for
it: nine review rounds of human attention spent on questions a fixture answers in milliseconds.

This feature builds the harness and proves it on the three defects that really happened. The
roadmap row and the 2026-09-18 decisions-log entries are what authorize it; the documents in
`review/` are why, and are not rungs on the source-of-truth ladder (constitution II).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A check that stops grading is caught by a test, not by a reviewer (Priority: P1)

A maintainer changes an enforcement script — adds a rule, fixes a parser, refactors a helper.
Before the diff reaches a reviewer, a harness runs every rule against fixtures that make it
pass and fixtures that make it fail, and reports which rules changed verdict.

**Why this priority**: This is the whole feature. Every other story is a consequence. Without
it, the kit's only defence against a fail-open is a human noticing — which is what the nine
rounds of feature 014 cost, and what GAP-025, GAP-026 and GAP-027 escaped anyway.

**Independent Test**: Take any shipped rule, break it deliberately (invert a condition, drop a
branch), run the harness, and confirm a named test fails. Restore it and confirm green.

**Acceptance Scenarios**:

1. **Given** a rule with a passing and a failing fixture, **When** the rule's condition is
   inverted, **Then** the harness fails and names the rule, the fixture, the expected verdict
   and the observed one.
2. **Given** an enforcement script whose behaviour is unchanged, **When** the harness runs
   twice, **Then** both runs produce identical results and neither depends on the machine's
   git configuration, locale, or the order the fixtures ran in.
3. **Given** a rule that emits a failure message, **When** its fixture runs, **Then** the
   fixture asserts the message text that a user would read, not merely the exit code.

---

### User Story 2 - The three recorded fail-opens are closed, each by the fixture that would have caught it (Priority: P1)

GAP-025, GAP-026 and GAP-027 are fixed, and each fix ships with the fixture that fails before
it and passes after.

**Why this priority**: A harness demonstrated on invented defects proves it runs; a harness
that closes three defects which really happened proves it *works*, on the failure species that
actually occurs here. These three were chosen for that reason (decisions log, 2026-09-18) — they
are this feature's subject matter, not a convenient bundle.

**Independent Test**: Check out the commit before each fix, run its fixture, watch it fail for
the recorded reason; check out the fix, watch it pass.

**Acceptance Scenarios**:

1. **Given** a governance document that mentions `<!--` inside backticks, **When**
   `build-digests.ps1` harvests markers, **Then** every marker after that line is still
   harvested (GAP-025 — measured: 79 markers harvested where 80 existed).
2. **Given** a `tasks.md` whose phase writes `**Territory** (widened by amendment …):`,
   **When** the scope check reads it, **Then** the declaration is seen (GAP-026).
3. **Given** a `tasks.md` in which one phase declares Territory and another declares none,
   **When** the scope check grades the undeclared phase, **Then** it FAILs rather than
   excusing it as pre-006 compatibility (GAP-026, second half).
4. **Given** a repository state in which a member cannot compute a diff base — a depth-1
   clone whose base is absent — **When** `enforcement-pack.ps1` runs, **Then** its verdict is
   not `OK` (GAP-027).

---

### User Story 3 - A run that graded nothing cannot be read as a clean one (Priority: P1)

Every grading script reports its outcome in one shared vocabulary, and that vocabulary has a
word for *this check formed no opinion*.

**Why this priority**: Today each script invents its own idiom — `FAIL`, `ERROR`, `WARN`,
`n/a`, a bare return — and the one state that matters most has no name at all. On a shallow
clone, `Invoke-ReviewProvenanceCheck` (the machine half of gate 5 itself) can grade nothing
while the run says `OK` and exits 0. Standardising five states without a sixth would **lock
that fail-open into the taxonomy** and make GAP-027 a breaking change later instead of a design
input now.

**Independent Test**: Produce a repository state in which a member cannot grade, run
`ritual-checks.ps1`, and confirm the verdict block distinguishes it from a graded pass — by
eye, in the log, and in whatever a required-status badge reports.

**Acceptance Scenarios**:

1. **Given** a member that graded nothing, **When** the verdict block prints, **Then** its
   state is visibly distinct from `OK` and from `n/a`.
2. **Given** a Lite-lane branch on which a member cannot grade, **When** the run finishes,
   **Then** the exit code is unchanged from today's behaviour (FR-009 of feature 014 forbids a
   new hard failure on that lane) while the verdict still says the check formed no opinion.
3. **Given** a check that genuinely does not apply, **When** it reports, **Then** it reports
   `n/a` and not the ungraded state — the two are different claims and the vocabulary must not
   blur them.

---

### User Story 4 - A new rule cannot ship untested (Priority: P2)

Coverage is itself graded: a rule with no passing-and-failing fixture pair fails the harness.

**Why this priority**: The alternative — coverage as an acceptance criterion a reviewer
eyeballs — is the same shape as every gap in this ledger: a rule nothing grades. It decays on
the first busy day. It is P2 rather than P1 only because the harness must exist before its
coverage can be graded.

**Independent Test**: Add a new failure condition to any enforcement script without adding
fixtures, run the harness, and watch it fail naming the uncovered rule.

**Acceptance Scenarios**:

1. **Given** a rule present in a script but absent from the inventory, **When** the harness
   runs, **Then** it fails — "the inventory is short" MUST NOT be a state that reads as green.
2. **Given** a rule in the inventory with a passing fixture but no failing one, **When** the
   harness runs, **Then** it fails naming the missing direction.
3. **Given** a rule deliberately exempted from coverage, **When** the harness runs, **Then**
   the exemption is declared in the inventory with a stated reason, and is visible in the
   harness output rather than silent.

---

### User Story 5 - A reviewer can tell why a fixture failed without reading the harness (Priority: P3)

Harness output identifies the governing rule, the fixture responsible, what was expected, what
was observed, and where the fixture's repository was left for inspection.

**Why this priority**: It is the proposal's best line — every failure names its rule, its
evidence and a remediation — applied first to the harness itself. Lower priority because a
harness with terse output still catches the defects; it just costs more to read.

**Independent Test**: Break a rule, hand the harness output alone to someone who has not read
the harness code, and confirm they can name the rule and the fixture.

**Acceptance Scenarios**:

1. **Given** a failing fixture, **When** the harness reports, **Then** the report names the
   script, the rule, the fixture and both verdicts.
2. **Given** a failing fixture, **When** the harness reports, **Then** the fixture's working
   repository is preserved or reproducible by a printed command.

---

### Edge Cases

- **A fixture that passes because the check never ran.** The harness's own fail-open. A
  fixture asserting "no failure reported" is indistinguishable from a check that returned
  early — the same defect the feature exists to close. Every fixture pair MUST include the
  failing direction, and the harness MUST verify that the rule under test was actually
  exercised, not merely that the run was quiet.
- **Expectations built from the script's own helpers.** GAP-025 and feature 014's B7 both
  existed because a check and its evidence went through the same parser, so both agreed and
  both were wrong. A harness that computes expected output by calling the script's helpers
  reproduces that exactly.
- **A fixture repository that is not a real repository.** Every defect the nine rounds found
  was about git and parser reality — `cat-file -e` vs `-s` vs `blob` on a truncated object,
  `merge-base` returning empty, `%P` field ordering, `core.quotepath`, CommonMark fence and
  inline-span visibility. Mocks reproduce none of them.
- **Platform divergence.** CI runs `ubuntu-latest` with `shell: pwsh`; all development here is
  Windows, and CRLF warnings appear on every commit in this repository. A rule that passes on
  one platform and fails on the other is a defect, not an environment quirk.
- **A fixture that outlives its rule.** A rule deleted or renamed leaves fixtures asserting
  behaviour nothing implements; they must fail loudly rather than pass vacuously.
- **The harness changing what a green run means for adopted projects.** Three projects consume
  these scripts verbatim. A new verdict state is a change to what their CI reports.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A **rule inventory** MUST exist, enumerating every distinct failure condition in
  every grading script, each with a stable identifier, the script and function that owns it,
  and the governing law it enforces.
- **FR-002**: Every rule in the inventory MUST have at least one fixture that makes it pass
  and at least one that makes it fail.
- **FR-003**: The harness MUST fail when a rule exists in a script but not in the inventory,
  and when an inventoried rule lacks either fixture direction.
- **FR-004**: A rule MAY be exempted from FR-002, and every exemption MUST carry a written
  reason in the inventory and appear in the harness's output.
- **FR-005**: Fixtures that exercise git behaviour MUST use real temporary git repositories
  with real commits — including, where the rule requires it, shallow clones, absent bases and
  corrupt objects. Mocked or in-memory git is prohibited for those rules.
- **FR-006**: Fixture expectations MUST be literal, hand-written text. The harness MUST NOT
  compute an expected value by calling the parsing or visibility helpers of the script under
  test.
- **FR-007**: Fixtures MUST assert the user-visible failure message, not only the exit code.
- **FR-008**: The harness MUST verify that the rule under test was exercised, so that a silent
  or early-returning check cannot satisfy a passing fixture.
- **FR-009**: Every grading script MUST report in one shared verdict vocabulary. The
  vocabulary MUST include a state meaning *this check formed no opinion* — distinct from a
  pass, from a failure, from an advisory warning, and from *does not apply*.
- **FR-010**: A member that cannot grade MUST NOT report the state that a fully graded pass
  reports, in the verdict block, the log, and any status a CI badge reflects.
- **FR-011**: FR-010 MUST NOT introduce a new hard failure on the Lite lane; the ungraded state
  is a verdict change, and any exit-code change is stated explicitly and separately.
- **FR-012**: `scripts/ritual-checks.ps1` MUST remain the single entry point adopted projects
  run, with its member names unchanged; the harness is additive.
- **FR-013**: `scripts/build-digests.ps1` MUST recognise a comment opener quoted inside an
  inline code span as literal text, so a marker after it is still harvested (GAP-025).
- **FR-014**: The Territory parser MUST accept a decorated marker — annotation between
  `**Territory**` and its colon — as a declaration (GAP-026).
- **FR-015**: An undeclared Territory MUST FAIL rather than WARN when another phase in the same
  `tasks.md` declares one (GAP-026).
- **FR-016**: Every failure the harness reports MUST name the script, the rule identifier, the
  fixture, the expected verdict and the observed one.
- **FR-017**: The harness MUST run in the kit's CI on both `ubuntu-latest` and a Windows
  runner, and a verdict that differs between them MUST be reported as a failure.
- **FR-018**: The harness MUST be runnable locally by one documented command, with no network
  access at run time.
- **FR-019**: Fixture repositories MUST be created under a temporary location and removed on
  success; on failure they MUST be preserved or exactly reproducible from printed output.
- **FR-020**: The harness MUST NOT modify the repository it is run from, and MUST NOT depend on
  the branch, working-tree state, or git identity of that repository.
- **FR-021**: The verdict-vocabulary change MUST be documented for adopters — what a green run
  meant before, what it means after, and what an adopter will newly see — in
  `adoption/updating.md` as a flow-down note.
- **FR-022**: `scripts/enforcement-pack.ps1`'s `.DESCRIPTION` header and the Lite-lane
  paragraph of `adoption/updating.md` MUST name the ungraded state, since neither mentions it
  today.

### Key Entities

- **Rule**: one distinct failure condition in one grading script — identifier, owning script
  and function, the law it enforces, and the message it emits. The unit coverage is measured in.
- **Fixture**: a repository state plus the command that grades it, paired with a hand-written
  expected verdict and message. Belongs to exactly one rule and one direction (pass or fail).
- **Verdict**: the outcome vocabulary shared by every grading script, including the state for a
  check that formed no opinion.
- **Rule inventory**: the machine-readable list FR-001 requires, which FR-003 grades coverage
  against.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every rule in the inventory has a passing and a failing fixture, or a written
  exemption; the harness fails if that stops being true.
- **SC-002**: Deliberately breaking any covered rule — inverting its condition — makes at least
  one named fixture fail. Verified by sampling, not asserted.
- **SC-003**: GAP-025, GAP-026 and GAP-027 are closed, and each has a fixture that fails on the
  parent commit of its fix and passes on the fix.
- **SC-004**: A repository state in which a member cannot grade produces a verdict that no
  reader — human or CI badge — can mistake for a graded pass.
- **SC-005**: `scripts/ritual-checks.ps1` reports the same member names and the same verdicts on
  the kit and on all three adopted projects as it did before this feature, except where a
  verdict changes from a quiet `OK` to the ungraded state.
- **SC-006**: The harness runs green on `ubuntu-latest` and on a Windows runner, with no rule
  reporting a different verdict between them.
- **SC-007**: The harness's wall-clock cost is stated as a measured figure against
  `ritual-checks`'s current runtime (82.2s / 80.0s measured on this repository, Windows 11,
  pwsh 7, warm), and the plan states whether it runs inside `ritual-checks` or beside it.
- **SC-008**: A person who has not read the harness can, from a failure report alone, name the
  rule and the fixture responsible.

## Assumptions

- The scripts in scope are the nine that decide a verdict: `enforcement-pack.ps1`,
  `scope-check.ps1`, `scope-check-repos.ps1`, `doc-lint.ps1`, `verify-kit.ps1`,
  `build-digests.ps1`, `roadmap-claim-check.ps1`, `territory-check.ps1` and
  `ritual-checks.ps1`. `init-kit.ps1`, `update-kit.ps1`, `claim-feature.ps1` and
  `create-new-feature.ps1` perform actions rather than grade; their failure messages are
  covered only where a rule the inventory names lives in them.
- The rule count is not yet known. Counted by failure-emission sites on 2026-09-19:
  `enforcement-pack` 41, `scope-check-repos` 25, `scope-check` 11, `update-kit` 11,
  `build-digests` 10, `verify-kit` ~14, `doc-lint` 3, `territory-check` 3,
  `roadmap-claim-check` 2 — a floor near 120, several of which will merge or split once the
  inventory is written. Producing the exact inventory is the first phase's output, and the
  number belongs in `plan.md`, not here.
- Whether the harness uses an existing test framework or a purpose-built runner is a `plan.md`
  decision. Any dependency it introduces must be approved there (constitution; CLAUDE.md
  Strict Rules), and FR-018's no-network constraint applies to the run, not to setup.
- The three adopted projects consume `scripts/` verbatim, so every change here reaches them at
  the next update. The harness itself need not flow down; the verdict vocabulary does.
- Feature 014's phase-5 behaviour is the baseline for FR-009 to FR-011: the ungraded condition
  is already *audible* in the log body, and this feature makes it *visible* in the verdict.

## Out of Scope

- **GAP-022** — a Critical branch is red from its first commit to its last. The original
  proposal folded this into 015 as "report final Critical human review as PENDING during
  implementation"; it is excluded here because it changes when a rule fires, not whether the
  rule is tested, and it is the one item with a live victim (FitForge 002, ten phases) that
  deserves its own row. FR-009's vocabulary gives its eventual fix a word to use.
- **GAP-023** (level declaration graded), **GAP-024/GAP-004** (the load-bearing roster) and
  **GAP-018** (cross-repo territory reach) — existing rows, sequenced after this one.
- **`evidence.json`** and the developer-facing `dev.ps1` entry point — features 016 and 017 in
  the proposal, both restructured by its review and neither claimed.
- Rewriting every existing failure message to the "rule + evidence + remediation" shape. This
  feature asserts the messages that exist (FR-007) and requires the shape only of messages it
  adds (FR-016).
