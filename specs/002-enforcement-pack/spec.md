# Feature Specification: Enforcement Pack

**Feature Branch**: `002-enforcement-pack`
**Created**: 2026-09-01
**Status**: Draft
**Delivery Level**: Standard <!-- Governance/tooling feature, no domain-invariant, auth, or
  schema surface — see docs/sdlc/critical-delivery.md. Not Lite because it introduces a new
  checked artifact (the check script) and CI workflow, which is more than a fix/chore/docs
  change. -->
**Input**: User description: "002-enforcement-pack: Convert the kit's five non-negotiables
from prose into physics (review/out/DECISION.md finding, v1 plan item 002)." Full text in
`review/out/DECISION.md`, v1 plan row 002.

## User Scenarios & Testing *(mandatory)*

<!--
  This is a governance/tooling feature: there is no end-user. The "user" is the developer
  or AI agent working in a kit-adopting repository, and the reviewer/maintainer who relies
  on CI to catch process violations before a human ever looks at the diff.
-->

### User Story 1 - CI catches a structurally incomplete feature branch (Priority: P1)

A developer (or their agent) opens a PR from a `NNN-*` branch that is missing `plan.md` or
`tasks.md`, or whose `spec.md` still has the `Delivery Level` placeholder unfilled. Today
this is only caught if a human reviewer happens to notice. The enforcement pack makes CI
fail the PR automatically, with a message naming exactly what is missing.

**Why this priority**: This is the check with the widest blast radius — every numbered
feature goes through it — and it is the most mechanical of the five (pure presence checks),
so it anchors the whole pack.

**Independent Test**: Push a fixture branch `999-fixture-missing-plan` with only `spec.md`
(no `plan.md`/`tasks.md`) and confirm the workflow run fails, naming the missing file(s).
Push a complete fixture branch and confirm the same check passes.

**Acceptance Scenarios**:

1. **Given** a `NNN-*` branch with `spec.md` but no `plan.md`, **When** the workflow runs,
   **Then** it fails and reports "missing plan.md" for that feature directory.
2. **Given** a `NNN-*` branch whose `spec.md` header reads `**Delivery Level**: [Lite |
   Standard | Critical]` (unfilled placeholder), **When** the workflow runs, **Then** it
   fails and reports the placeholder was not replaced.
3. **Given** a `NNN-*` branch with `spec.md`, `plan.md`, and `tasks.md` present and a filled
   `Delivery Level`, **When** the workflow runs, **Then** this check passes.

---

### User Story 2 - CI catches a Lite-lane branch smuggling in prohibited changes (Priority: P1)

A developer opens a `fix/`, `chore/`, or `docs/` branch (the lightweight lane, which skips
the full spec workflow) that actually touches a dependency manifest, auth code, a
schema/migration path, `contracts/`, or the domain-invariants pack — the exact drift
`docs/sdlc/branch-strategy.md` and `docs/sdlc/critical-delivery.md` say should have been a
numbered (and possibly Critical) feature instead. The enforcement pack fails the PR and
names the offending file(s), so the drift is caught before human review rather than by it.

**Why this priority**: This is the check that most directly prevents "we can fix it in a
follow-up" scope creep from bypassing the level system — the exact failure mode
`docs/sdlc/critical-delivery.md` exists to close. Bundled with the abuse guard (a `fix/`/
`chore/` branch touching more than a configurable file count, default generous, or any
migration file) since both are Lite-lane diff-shape checks with the same fixture mechanics.

**Independent Test**: Push a fixture `fix/fixture-lite-schema` branch that edits a file
under a configured migrations path, and confirm the workflow fails naming that file. Push a
fixture `fix/fixture-lite-clean` branch that only touches an unrelated doc, and confirm it
passes.

**Acceptance Scenarios**:

1. **Given** a `fix/*` branch whose diff touches a path matching the schema/migrations
   pattern, **When** the workflow runs, **Then** it fails and names the file and the
   prohibited category (schema/migration).
2. **Given** a `chore/*` branch whose diff touches a dependency manifest (e.g.
   `package.json`, `requirements.txt` — configurable list), **When** the workflow runs,
   **Then** it fails and names the file and category (dependency manifest).
3. **Given** a `fix/*` branch whose diff changes more files than the configured abuse-guard
   threshold, **When** the workflow runs, **Then** it fails with a message suggesting
   promotion to a numbered feature.
4. **Given** a `fix/*` branch that only touches files outside every prohibited category and
   under the file-count threshold, **When** the workflow runs, **Then** this check passes.

---

### User Story 3 - CI catches a Critical feature missing its independence evidence (Priority: P2)

A developer opens a PR for a feature declared `Delivery Level: Critical` but has not yet
recorded `specs/NNN-name/second-model-review.md`, or recorded it less than the required
24-hour cooling-off period before the PR is opened for merge. `docs/sdlc/critical-delivery.md`
item 5 requires this file and the cooling-off period as the solo-developer substitute for
independent review; today nothing checks it exists or that time has actually elapsed.

**Why this priority**: Narrower blast radius than US1/US2 (only Critical features hit this
path) but the highest-consequence gap — it is the one substitute for independent review a
solo developer has, and DECISION.md's finding was that it was previously undefined and
therefore unenforceable.

**Independent Test**: Push a fixture Critical-declared branch with no
`second-model-review.md` and confirm the check fails naming the missing artifact. Add the
file dated less than 24 hours before the check run and confirm it still fails, citing the
cooling-off window. Back-date it (or wait) past 24 hours and confirm the check passes.

**Acceptance Scenarios**:

1. **Given** a feature branch whose `spec.md` declares `Delivery Level: Critical` and whose
   feature directory has no `second-model-review.md`, **When** the workflow runs, **Then**
   it fails and reports the missing artifact.
2. **Given** the same branch with `second-model-review.md` present but recorded (by file
   history / an explicit dated line inside it) less than 24 hours before the check runs,
   **When** the workflow runs, **Then** it fails and reports the cooling-off period has not
   elapsed.
3. **Given** the same branch with `second-model-review.md` present and recorded 24+ hours
   before the check runs, **When** the workflow runs, **Then** this check passes.
4. **Given** a feature branch declared `Standard` (not Critical), **When** the workflow
   runs, **Then** this check is skipped for that feature (not applicable).

---

### User Story 4 - CI warns (non-blocking) when a single phase commit is oversized (Priority: P3)

A developer's agent commits a phase that touches far more than one coherent, independently
revertible slice — the exact drift the phase-size rule (`.specify/templates/plan-template.md`,
added in `001-delivery-core-amendment`) exists to catch at plan-approval time, but plan
approval is a human judgment call made before any code exists. This check is a mechanical
backstop: it warns (does not block) when a phase commit's diff size crosses a generous
threshold, so an oversized phase is visible to the human reviewer without the check
second-guessing a legitimate large phase.

**Why this priority**: Explicitly non-blocking and lowest-consequence of the five — a
visibility aid, not a gate — so it is fine to land last and to degrade gracefully (warn,
never fail the build) if the heuristic is imperfect.

**Independent Test**: Push a fixture branch with one phase commit changing an unusually
large number of lines/files and confirm the workflow posts a warning annotation but still
reports overall success. Push a fixture branch with normally-sized phase commits and confirm
no warning appears.

**Acceptance Scenarios**:

1. **Given** a feature branch where a single commit's diff exceeds the configured line/file
   threshold, **When** the workflow runs, **Then** it posts a visible warning naming the
   commit and its size, and the overall workflow still succeeds (does not block merge).
2. **Given** a feature branch where every commit is under the threshold, **When** the
   workflow runs, **Then** no warning is posted.

---

### User Story 5 - A maintainer requires the enforcement pack before merge on GitHub (Priority: P2)

A maintainer sets up branch protection on `main` so that the enforcement-pack workflow must
pass (US1–US3; US4 is a warning, never a blocker) before a PR can be merged, and so the PR
template embeds the human-review checklist and a field for the gate command's confirmed exit
code, keeping the two review layers (constitution IX/X) visible on every PR instead of
relying on memory.

**Why this priority**: Without this, the checks in US1–US4 run but nothing stops a merge
that fails them — the pack becomes advisory rather than enforced, defeating the feature's
purpose ("physics", not prose).

**Independent Test**: Follow the branch-protection recipe doc against a live GitHub
repository (this one) and confirm a PR with a failing required check cannot be merged
through the GitHub UI (merge button disabled / blocked).

**Acceptance Scenarios**:

1. **Given** the branch-protection recipe has been applied to `main`, **When** a PR's
   enforcement-pack check run is failing, **Then** GitHub's merge button is disabled for
   that PR.
2. **Given** a new PR is opened against `main`, **When** the PR is created, **Then** its
   description is pre-populated from the PR template, including the human-review checklist
   items and a field for the gate command's confirmed exit code.

---

### Edge Cases

- What happens when a PR branch is not `NNN-*`, `fix/*`, `chore/*`, or `docs/*` (an
  unrecognized prefix)? The workflow reports the branch-naming violation itself
  (`docs/sdlc/branch-strategy.md`'s taxonomy) rather than silently skipping all checks.
- How does the script handle a `NNN-*` feature directory that legitimately spans **multiple
  repositories** (`docs/sdlc/repository-strategy.md`)? Only the repository the branch lives
  in is checked; cross-repo consistency is out of scope for this feature.
- What happens when `second-model-review.md` exists but has no discoverable date (git log
  and no explicit date line)? Treated as fresh (cooling-off not yet started) — fail closed,
  not open.
- How does the abuse-guard file-count threshold interact with a `fix/` branch that
  legitimately reformats many files (e.g. a lint-fix)? The threshold is configurable in one
  place precisely so an adopting project can tune it; this feature ships a documented
  default, not a hardcoded number that can't be revisited.
- What happens on a fork-based PR where secrets/tokens aren't available? All five checks
  operate only on the diff and file tree already available to a standard PR checkout — no
  external calls or secrets are required.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The pack MUST provide a single CI-agnostic script (PowerShell, matching the
  existing `scripts/doc-lint.ps1` style and invocable the same way) that runs all of the
  checks in FR-002 through FR-006 and reports a clear pass/fail per check plus an overall
  exit code.
- **FR-002**: For any `NNN-*` branch, the script MUST verify `specs/NNN-name/spec.md`,
  `plan.md`, and `tasks.md` all exist, and that `spec.md`'s `Delivery Level` header is
  filled with exactly one of `Lite`, `Standard`, or `Critical` (not the template
  placeholder).
- **FR-003**: For any `fix/*` or `chore/*` branch, the script MUST fail if the branch's diff
  (against its merge-base with `main`) touches a path matching any configured Lite-lane
  prohibition category: dependency manifests, auth code, schema/migrations, `contracts/`,
  or the configured domain-invariants path — and MUST report the specific file(s) and
  category matched.
- **FR-004**: For any `fix/*` or `chore/*` branch, the script MUST additionally fail
  (independent of FR-003) if the branch's diff touches any file matching the schema/
  migrations pattern, or if the number of changed files exceeds a configured threshold —
  reporting this as the abuse guard, distinct from a named prohibited category.
- **FR-005**: For any `NNN-*` branch whose `spec.md` declares `Delivery Level: Critical`,
  the script MUST fail if `specs/NNN-name/second-model-review.md` does not exist, or if it
  exists but was recorded less than 24 hours before the check runs; it MUST pass (or skip,
  for non-Critical features) otherwise.
- **FR-006**: For any `NNN-*` branch, the script MUST scan each commit on the branch and
  emit a non-blocking warning (not a failure, and not counted in the exit code) for any
  commit whose diff exceeds a configured line-count or file-count threshold.
- **FR-007**: Every threshold and path pattern used by FR-003, FR-004, and FR-006 MUST be
  defined in one place in the script (or a configuration it reads), not hardcoded in
  multiple locations, so an adopting project can retune them without editing check logic.
- **FR-008**: The pack MUST include a CI workflow (GitHub Actions) that runs the script from
  FR-001 on every push and pull request targeting `main`, and that fails the workflow run
  when the script's exit code is non-zero.
- **FR-009**: The pack MUST include a pull-request template that embeds the review checklist
  from `specs/_templates/human-pr-review-template.md` and an explicit field for the gate
  command's user-confirmed exit code.
- **FR-010**: The pack MUST include a branch-protection recipe document explaining how to
  configure GitHub branch protection on `main` so the workflow from FR-008 is a required
  status check before merge.
- **FR-011**: Every check's failure message MUST name the specific file, branch, or artifact
  that caused the failure — a generic "checks failed" message does not satisfy this
  requirement.
- **FR-012**: This repository's own CI MUST run the enforcement pack (FR-008) so the kit
  dogfoods its own enforcement, matching how `001-delivery-core-amendment` dogfooded the
  Standard lane.

### Key Entities

- **Fixture branch**: a throwaway branch created solely to exercise one check in a known-
  failing or known-passing state, used to verify FR-002 through FR-006 without depending on
  any real in-flight feature.
- **Check result**: one named check (per FR-002–FR-006) with a pass/fail/warn status and,
  on fail or warn, a human-readable reason naming the offending file/artifact.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A deliberately broken fixture branch missing `plan.md` fails the workflow with
  a message identifying the missing file, within the same CI run that would otherwise have
  been reviewed by a human.
- **SC-002**: A deliberately broken fixture branch declaring `Lite` (via `fix/`) but editing
  a schema/migration file fails the workflow, naming the file and category, with zero human
  review cycles spent noticing it first.
- **SC-003**: A deliberately broken fixture branch declaring `Critical` with no
  `second-model-review.md` fails the workflow, naming the missing artifact.
- **SC-004**: A clean fixture branch (complete spec artifacts, filled Delivery Level, no
  prohibited-category files, Critical evidence present and aged 24+ hours where applicable)
  passes the workflow with zero failures.
- **SC-005**: An oversized single-commit fixture branch produces a visible warning but the
  workflow still reports overall success (does not block).
- **SC-006**: On this repository, a PR targeting `main` with a failing enforcement-pack
  check cannot be merged through the GitHub UI once the branch-protection recipe has been
  applied.
- **SC-007**: Every new PR opened against this repository after this feature merges is
  pre-populated with the PR template's checklist and exit-code field, with no manual setup
  step per PR.

## Assumptions

- The enforcement script determines a branch's diff against `main` using its git
  merge-base, consistent with how `docs/sdlc/team-workflow.md` and `branch-strategy.md`
  already describe feature branches relating to `main`; no additional base-branch
  configuration is introduced.
- "Recorded" time for `second-model-review.md` (FR-005) is read from the file's first commit
  timestamp in git history (`git log --follow --format=%aI -- <path> | tail -1`), since the
  kit has no other artifact-dating mechanism; an explicit date line inside the file, if
  present, is treated as informational only, not authoritative — git history cannot be
  post-dated by editing the file's content.
- Default thresholds (file-count abuse guard, phase-commit diff-size warning) are chosen
  generously (documented in `plan.md`/`research.md`, not restated here) so the pack does not
  need per-project tuning to be useful on day one; adopting projects are expected to retune
  via FR-007's single configuration point.
- "Dependency manifests" and "auth code" (FR-003) are represented as configurable glob
  patterns with kit-shipped defaults (e.g. `package.json`, `*.csproj`, `requirements.txt`
  for manifests; a configurable auth-path glob) rather than a fixed list, since every
  adopting project's stack differs (see CLAUDE.md's Stack Profile).
- This feature does not attempt to check cross-repository consistency
  (`docs/sdlc/repository-strategy.md`) or team-workflow number-reservation races
  (`docs/sdlc/team-workflow.md` §2) — both are out of scope per `review/out/DECISION.md`'s
  v1 plan, which scopes 002 to the five non-negotiables only.
- GitHub Actions is the CI target (FR-008) because `origin` is now
  `https://github.com/anas-mattar/agentic-sdlc-kit.git`; the underlying script (FR-001)
  stays CI-agnostic so a different CI system could invoke it later without rewriting the
  checks themselves.
