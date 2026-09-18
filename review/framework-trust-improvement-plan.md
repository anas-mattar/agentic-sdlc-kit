# Framework Trust Improvement Plan

> **Status:** Non-authoritative review proposal  
> This document does not authorize implementation. Its recommendations must be reviewed,
> converted into approved feature specifications, and delivered through the framework's normal
> phase-gated workflow.

## Summary

Improve the framework through three staged features while preserving compatibility with existing
adopters. Finish and release feature 014 first, then use FitForge as the reference
multi-repository pilot.

Success means developers can trust that:

- `PASS` represents verified evidence, not completed checkboxes.
- Expected unfinished work is `PENDING`, not `FAIL`.
- Every failure explains the cause and next action.
- Governance, API, and frontend commits are certified together.
- Multi-developer collisions are detected before implementation.

## Prerequisite — Complete Amendment Authority

Before beginning the work below:

1. Complete feature 014 and its independent review.
2. Merge it into the kit's protected main branch.
3. Publish a new kit version.
4. Update FitForge through the supported update process rather than copying files from an
   in-progress kit branch.

## Feature 015 — Enforcement Assurance

Create an automated fixture-based test harness for every enforcement script before adding more
rules.

### Changes

- Test valid and deliberately invalid single-repository and multi-repository fixtures.
- Cover document parsing, phase detection, territory, amendments, Critical evidence, Git history,
  dirty repositories, and malformed records.
- Standardize verdicts as `PASS`, `FAIL`, `WARN`, `PENDING`, and `N/A`.
- Keep `scripts/ritual-checks.ps1` compatible, while separating its internal phase,
  branch-health, adoption, and merge-readiness results.
- Report final Critical human review as `PENDING` during implementation and `FAIL` only at merge
  readiness.
- Require every failure to report the governing rule, inspected evidence, affected path or
  commit, and a safe remediation action.
- Run the enforcement test harness in kit CI on Windows PowerShell.

### Acceptance criteria

- Every enforcement rule has at least one passing and one failing fixture.
- Removing or corrupting required evidence makes the corresponding test fail.
- Expected in-progress Critical work does not produce a false-red merge signal.
- Existing adopted projects continue to run the current entry-point command.
- Test output identifies the exact rule and fixture responsible for a failure.

## Feature 016 — Evidence-Backed Completion

Add a machine-readable evidence record to each Standard or Critical feature.

### Evidence interface

Introduce `specs/NNN-name/evidence.json` containing:

- Feature and phase identifiers.
- Requirement and task identifiers.
- Automated test names or manual-evidence references.
- Gate command, exit code, timestamp, and runner identity.
- Exact governance and code-repository commit SHAs.
- Visual and contract evidence references.
- Approval identity and the exact approved commit.

### Behavior

- Reject completed tasks whose declared evidence is missing, stale, or belongs to another commit.
- Add executable contract checks where a feature declares API contracts.
- Generate gate, repository, commit, and diff evidence automatically.
- Keep human-authored decisions and approvals separate from generated evidence.
- Update the adoption doctor to produce a migration report for existing Markdown evidence.
- Keep legacy evidence readable with warnings until an adopter explicitly enables evidence schema
  version 1; enable the schema by default for new adoptions.

### Acceptance criteria

- Every completed requirement and task resolves to existing evidence.
- Evidence is bound to immutable commit SHAs across every participating repository.
- A stale test result or evidence record from another commit fails validation.
- Manual evidence identifies its reviewer and the artifact reviewed.
- Contract divergence causes the full check to fail.

## Feature 017 — Developer and Team Confidence

Provide one developer-facing entry point with read-only diagnostics before adding automatic fixes.

```powershell
pwsh -File scripts/dev.ps1 status
pwsh -File scripts/dev.ps1 check --fast
pwsh -File scripts/dev.ps1 check --full
pwsh -File scripts/dev.ps1 explain <check>
pwsh -File scripts/dev.ps1 submit
```

### Developer workflow

- `status` reports the feature, phase, owner, repository alignment, current state, blockers,
  pending work, and exact next action.
- `check --fast` validates branch alignment, repository cleanliness, specifications, approvals,
  territory, and changed files without running project builds.
- `check --full` runs project gates, scope checks, contract checks, security checks, and evidence
  validation.
- `explain` shows the governing rule, why it applies, evidence searched, verdict reason, and safe
  remediation choices.
- `submit` generates an evidence draft but never supplies or impersonates human approval.

### Team workflow

- Expand the developer roster to include name, repository permissions, and Critical-review
  eligibility while continuing to read legacy string entries.
- Validate feature owners and reviewers against that roster.
- Enforce at most one active feature and one awaiting-review feature per developer.
- Detect territory overlap across all declared code repositories before a phase starts.
- Treat migrations, dependency manifests, shared navigation, global configuration, and design
  tokens as explicitly lockable shared territory.
- Add an immutable phase manifest binding governance, API, and frontend commit SHAs.

### Acceptance criteria

- A developer can determine the correct next action from one `status` command.
- Fast checks complete within five seconds on the FitForge governance repository without project
  builds.
- Dirty or branch-misaligned nested repositories are reported.
- Missing final review is `PENDING` during implementation and blocking at merge readiness.
- Two features with overlapping cross-repository territory cannot both report implementation-ready.
- Every blocking verdict includes an actionable remediation path.
- No developer command modifies plans, territory, application code, or approvals automatically.

## Test and Rollout Plan

1. Use adversarial fixtures to prove that every check changes from green to red when its evidence
   is removed or corrupted.
2. Pilot features 015–017 on one unfinished FitForge 002 remediation phase.
3. Verify detection of FitForge's dirty frontend repository, missing human review,
   cross-repository branches, unbuilt phases, and evidence gaps.
4. Update FitForge through the supported kit update process and review the migration report.
5. Enable strict evidence mode in FitForge only after its generated evidence draft is reviewed.
6. Gather feedback from both FitForge developers before releasing the workflow broadly.

## Compatibility and Safety Defaults

- Existing adopted projects remain readable and receive an explicit migration path.
- FitForge is the first real-world acceptance project.
- Diagnostics and evidence generation ship before any automatic remediation.
- Protected hosting-platform identities should become the source of human approval; local
  free-text approval remains legacy evidence during migration.
- Break-glass exceptions, if later introduced, must remain visible, expire automatically, and
  never convert an unverified result into `PASS`.

## External Review Request — Fabel

Please review this proposal independently and report findings by severity. In particular, assess:

1. Missing trust, integrity, or security risks.
2. Whether the developer workflow is unnecessarily complex.
3. Multi-developer and multi-repository collision handling.
4. Evidence integrity and approval authenticity.
5. Backward-compatibility and migration risks.
6. Whether the three-feature sequence is appropriately scoped and ordered.
7. Checks that could produce false confidence, false-red results, or easy bypasses.
8. Any blocking concern that should be resolved before feature 015 is specified.

Fabel's review is advisory evidence, not implementation authority. Accepted changes must be
incorporated into the relevant approved feature specification before implementation.
