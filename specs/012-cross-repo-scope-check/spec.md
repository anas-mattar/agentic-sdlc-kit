# Feature Specification: Cross-Repo Scope-Check Reach

**Feature Branch**: `012-cross-repo-scope-check`
**Created**: 2026-09-09
**Status**: Draft
**Delivery Level**: Standard
**Input**: User description: "Extend the machine scope check (Definition of Done gate 4) to
reach nested code repositories in the multi-repo layout, so code phase commits are
machine-verified against the feature's declared Territory instead of reviewer-verified prose
(GAP-016)"

## Problem

In the nested layout the kit recommends (`docs/sdlc/repository-strategy.md`, "Nested Layout"),
the governance repository holds `CLAUDE.md`, `specs/`, and `scripts/`, and the code lives in
independent repositories cloned inside it — `<project>-api/`, `<project>-web/`. The machine
scope check runs against one repository: it resolves the current branch, reads
`specs/NNN-name/tasks.md`, and compares the commit's paths to the declared **Territory** — all
inside `$Root`, the governance repository (`scripts/scope-check.ps1`, Dispatch).

The consequence is that gate 4 is machine-enforced exactly where nothing risky happens and
absent everywhere it matters. A phase that adds a controller, a migration and three components
across two code repositories produces commits the check never sees; its Territory declaration
is graded by a human reading a diff — which is the eyeballed check GAP-008 already ruled
insufficient, reintroduced through the back door for every multi-repo adopter. Both currently
adopted projects (FlowBoard, Expense Tracker) run this way today, and the kit is about to be
adopted by a two-developer, two-code-repo project, where an undeclared drive-by change in one
developer's repository is invisible to the other's territory check as well.

Two fix shapes were recorded when the gap was logged: ship a thin `scripts/` set into each code
repository at adoption, or have the governance repository read the code repositories as sibling
working trees. The first duplicates kit-owned scripts into repositories that `update-kit.ps1`
does not manage — the same sync ratchet GAP-006 and GAP-007 cost two flow-downs to unwind — and
it still cannot read the Territory declaration, which lives in the governance repository. This
feature takes the second shape.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A code phase commit is graded against its declaration (Priority: P1)

A developer implements phase 2 of a feature, touching files in `<project>-api/` and
`<project>-web/`, and commits in each code repository with a `phase 2` subject token. Running
the check from the governance repository reports one verdict per repository, comparing every
touched path — repo-prefixed — against the phase's **Territory** in the governance repo's
`specs/NNN-name/tasks.md`. An undeclared file fails the check by exit code, naming the file and
the remediation.

**Why this priority**: this is the gap. Without it, no multi-repo project has a machine gate 4.

**Independent Test**: create two throwaway sibling repositories with a matching `NNN-*` branch,
commit one in-territory phase commit and one out-of-territory phase commit, and confirm PASS
(exit 0) and FAIL (exit 1) respectively, with the stray path named.

**Acceptance Scenarios**:

1. **Given** a governance repo on `012-x` whose `tasks.md` declares phase 1 territory
   `` `demo-api/src/**` ``, **When** the sibling `demo-api` repository's `012-x` branch has a
   `phase 1` commit touching only `src/Foo.cs`, **Then** the verdict is PASS and the exit code 0.
2. **Given** the same declaration, **When** that commit also touches `README.md` at the code
   repo root, **Then** the verdict is FAIL, the output names `demo-api/README.md` as not in
   territory, and the exit code is 1.
3. **Given** a code repository with no branch matching the governance branch, **When** the check
   runs, **Then** that repository reports `not applicable` and does not fail the run.

---

### User Story 2 - The check cannot be defeated by amending the declaration afterwards (Priority: P1)

A developer commits a phase that touches an undeclared file, then widens the phase's
**Territory** in the governance repository to cover it. The check still fails: a declaration
only governs code commits made after it landed.

**Why this priority**: the in-repo check already enforces this by reading the declaration from
the commit's parent (`scripts/scope-check.ps1`, anti-retroactivity). A cross-repo check without
an equivalent rule is a gate that any developer can pass retroactively, which is worse than no
gate because it looks like one.

**Independent Test**: commit an out-of-territory code phase commit, then widen the governance
declaration; re-run and confirm the verdict is still FAIL, naming the ordering as the reason.

**Acceptance Scenarios**:

1. **Given** a code phase commit dated after the governance commit that declares its territory,
   **When** the check runs, **Then** the declaration applies and the paths are graded against it.
2. **Given** a code phase commit dated **before** the governance commit that declares the
   territory covering it, **When** the check runs, **Then** the verdict is FAIL and the output
   states that the declaration post-dates the commit.

---

### User Story 3 - CI and single-repo projects are unaffected (Priority: P2)

The wrapper every developer and every CI run already uses (`scripts/ritual-checks.ps1`) gains
the new member. In the kit's own repository, in a single-repo adoption, and in governance CI —
where only the governance repository is checked out — the member reports `n/a` and the run stays
green. A code repository's own CI can run the check for itself by checking out the governance
repository alongside.

**Why this priority**: a check that turns existing green runs red on adoption day gets disabled
on adoption day.

**Independent Test**: run `scripts/ritual-checks.ps1` in this kit repository (no `codeRepos`
declared, no sibling trees) and confirm `n/a` and overall exit 0.

**Acceptance Scenarios**:

1. **Given** a project whose `kit-adoption.json` declares no `codeRepos`, **When**
   `ritual-checks.ps1` runs, **Then** the member reports `n/a` and the wrapper's verdict is
   unchanged.
2. **Given** `codeRepos` are declared but the sibling directories are absent (a bare CI
   checkout), **When** the member runs, **Then** it reports `n/a` with the reason, exit 0.
3. **Given** a code repository's CI checks out the governance repository as a sibling, **When**
   it runs the check for its own repository, **Then** it produces the same verdict a developer
   gets locally.

### Edge Cases

- A declared code repository directory exists but is not a git repository → `not applicable`
  with the reason, not a crash.
- The code repository is on a detached HEAD (CI checkout of a sha) → the branch must be passed
  explicitly, mirroring the in-repo check's detached-HEAD rule.
- A code repo commit carries no `phase N` token (scaffolding, merge, revert) → `not applicable`,
  as in-repo.
- A Micro feature: territory comes from the mini-spec `spec.md`'s feature-global block, since
  the lane has no `tasks.md` (constitution X, Micro lane).
- A phase whose work is entirely in the governance repository (docs, specs) → the code
  repositories report `not applicable`; the existing in-repo check still governs.
- Territory entries that name a code repository which is not declared in `codeRepos` → reported
  as a configuration warning, so a typo does not silently pass everything.
- Two code repositories with the same basename in different parents — out of scope; `codeRepos`
  entries are single-segment directory names under the governance root.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The kit MUST provide a check, run from the governance repository, that grades a
  feature's phase commits in each declared nested code repository against that phase's
  **Territory** declaration in the governance repository.
- **FR-002**: Territory entries for a multi-repo project MUST be written repo-prefixed relative
  to the governance root (e.g. `` `demo-api/src/**` ``), and the check MUST compare each code
  repository's touched paths with that repository's directory name prefixed.
- **FR-003**: The check MUST reuse the existing scope-check semantics without divergence: phase
  attribution from the `phase N` subject token, Micro-lane territory from `spec.md`, glob
  matching rules, rename/delete path handling, and the PASS / not-applicable / WARN / FAIL
  verdict-to-exit-code contract.
- **FR-004**: A declaration MUST NOT govern code commits that predate it; a code phase commit
  older than the governance commit declaring its territory MUST FAIL.
- **FR-005**: The set of code repositories MUST be declared in `kit-adoption.json` and MUST be
  optional; a project that declares none behaves exactly as today.
- **FR-006**: `scripts/ritual-checks.ps1` MUST run the check as a member and MUST report
  `n/a` (exit 0) when no code repositories are declared, when the declared directories are
  absent, or when they are not git repositories.
- **FR-007**: The kit MUST ship a CI workflow template that lets a code repository run this
  check for itself by checking out the governance repository as a sibling.
- **FR-008**: `scripts/verify-kit.ps1` MUST validate the `codeRepos` field's shape when present,
  and MUST warn when a multi-topology adoption declares none.
- **FR-009**: The governance documents that state where territory is declared and which checks
  run (`docs/sdlc/repository-strategy.md`, `docs/sdlc/definition-of-done.md`,
  `docs/sdlc/review-process.md`, `docs/sdlc/flow.md`, `CLAUDE.md`) MUST state the multi-repo
  rule and name the new wrapper member, with digests regenerated.
- **FR-010**: Every FAIL message MUST name the offending path and the remediation, in the style
  of the existing check (revert, or amend the declaration in a commit made before the phase
  commit).

### Key Entities

- **Code repository**: a nested, independent git repository under the governance root, declared
  by directory name in `kit-adoption.json`; carries the feature's code on a branch of the same
  `NNN-name`.
- **Territory declaration**: the existing per-phase (or Micro feature-global) list in the
  governance repository, now able to carry repo-prefixed paths.
- **Adoption record** (`kit-adoption.json`): gains an optional `codeRepos` array.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In a nested multi-repo project, 100% of phase commits containing code are graded
  by a machine check; today the figure is 0%.
- **SC-002**: An undeclared file in any declared code repository fails the check with exit
  code 1 and is named in the output.
- **SC-003**: Widening a territory declaration after a code phase commit does not turn its FAIL
  into a PASS.
- **SC-004**: `scripts/ritual-checks.ps1` exits 0 unchanged in this kit repository and in a
  single-repo adoption — no adopted project's CI turns red on receiving this feature.
- **SC-005**: One developer can run one command from the governance root and see a verdict per
  repository for the current phase.

## Assumptions

- The nested layout is the multi-repo layout the kit recommends; code repositories are direct
  children of the governance root and are ignored by it.
- Code repositories use the matching `NNN-name` branch, per the Cross-Repository Feature Rule
  (`docs/sdlc/repository-strategy.md`).
- Commit dates within one developer's machine and one CI run are monotonic enough to order a
  governance declaration against a code commit; the ordering rule is a guard against
  after-the-fact widening, not against a determined adversary with a rewritten clock.
- Adopters receive this through `update-kit.ps1`; the `codeRepos` field is added to their
  adoption record by hand or by re-running `init-kit.ps1` (documented, not automated migration).
