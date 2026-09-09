# Implementation Plan: Cross-Repo Scope-Check Reach

**Branch**: `012-cross-repo-scope-check` | **Date**: 2026-09-09 | **Spec**: specs/012-cross-repo-scope-check/spec.md
**Input**: Feature specification + research.md decisions D1–D6
**Gate Batching**: phases 1-3
**Gate Certification**: ci-held

## Summary

Machine gate 4 gains reach into the nested code repositories. A new
`scripts/scope-check-repos.ps1`, run from the governance repository, grades each declared code
repository's phase commits against the Territory the governance repository declares for that
phase — paths repo-prefixed (D3), the declaration read as it stood when the code was committed
(D4), the repository list taken from `kit-adoption.json`'s new optional `codeRepos` array (D2).
The parsing and matching semantics are extracted verbatim into `scripts/scope-lib.ps1` and
shared with the existing check so the two graders cannot drift (D6). `ritual-checks.ps1` gains a
`scope-repos` member that reports `n/a` wherever the sibling trees are absent — the kit's own
repository, single-repo adoptions, and governance CI — so no existing green run turns red. A
code repository reaches the same verdict in its own CI by checking out the governance repository
as a sibling (D5, shipped as a workflow template).

No constitutional amendment: gate 4 already requires the scope check; this feature makes the
existing requirement reach the code it always claimed to govern. Constitution stays 0.6.0.

## Technical Context

**Language**: PowerShell 7 (the kit's only scripting surface) + Markdown/JSON/YAML template.
**Testing**: seeded fixture repositories under the scratchpad + kit self-run; no test framework
(kit convention — same as 006, 010). **Target**: the kit repo (inert — no `codeRepos`) and
adopted multi-repo projects via `update-kit.ps1`. **Constraints**: zero new dependencies;
Windows + POSIX shells; backward compatible (SC-004); read-only — the check never writes.

## Constitution Check

- **I Specification First**: spec.md, plan.md, tasks.md exist before implementation. PASS.
- **II Source of Truth**: no ladder change; the check reads the declaration the ladder already
  names as truth (`tasks.md`, `spec.md` on Micro). PASS.
- **III Repository Separation**: the feature is *about* the separation — it adds no code to any
  code repository (D1); the only artifact that lands outside the governance repo is a workflow
  template the adopter copies. PASS.
- **IV Architecture Consistency**: extends the existing script + manifest + ritual-checks member
  pattern; no new patterns, no packages. The one structural addition, a dot-sourced library, is
  approved here (D6). PASS.
- **V Domain Invariants**: the kit's domain is its own governance; no invariant pack applies.
  N/A.
- **VI Security**: read-only; no secrets. The CI template names a token *secret reference* for
  private governance repositories and never inlines a credential. PASS.
- **VII External Integration Governance**: the CLI contract is written before implementation
  (`contracts/scope-check-repos-cli.md`), as 006 did for the original check. PASS.
- **VIII Testing Requirements**: this is business-critical governance logic — a wrong PASS
  silently disables gate 4 for every multi-repo adopter. Deterministic validation via seeded
  fixture scenarios C1–C11 with recorded verdicts, plus the behavior-preservation check that
  the existing scope-check's verdicts are unchanged after extraction. PASS.
- **IX Human Review**: fresh-context AI review per phase + human review at merge. PASS.
- **X Controlled Delivery**: 3 phases, each independently revertible and testable.
  **Gate Batching: phases 1-3** (max 3, declared before phase 1). **Gate Certification:
  ci-held** — Standard feature, eligible, declared here before any phase. Certification is the
  owner's recorded approval on the batch-end evidence triplet; the agent reports the evidence
  and never claims the gate. PASS.

**Phase-sizing**: each phase stands alone. Phase 1 delivers a working check nothing yet calls in
anger; phase 2 makes the record and doctor aware of it; phase 3 states the law and ships the CI
template. Reverting any one leaves the others correct.

## Source Code (repository root)

```text
scripts/scope-lib.ps1                              # NEW  phase 1 — shared parse/match helpers (D6)
scripts/scope-check.ps1                            # MOD  phase 1 — dot-source the lib, behavior unchanged
scripts/scope-check-repos.ps1                      # NEW  phase 1 — the cross-repo grader
scripts/ritual-checks.ps1                          # MOD  phase 1 — 'scope-repos' member
scripts/init-kit.ps1                               # MOD  phase 2 — write codeRepos for multi topology
scripts/verify-kit.ps1                             # MOD  phase 2 — validate codeRepos, warn when multi declares none
adoption/updating.md                               # MOD  phase 2 — record shape + how existing adopters add codeRepos
.github/workflows/code-repo-scope-check.yml.template  # NEW phase 3 — code-repo CI (D5)
kit-manifest.json                                  # MOD  phase 3 — surgical entry for the template
docs/sdlc/repository-strategy.md                   # MOD  phase 3 — "Territory across repositories"
docs/sdlc/definition-of-done.md                    # MOD  phase 3 — gate 4 names the cross-repo check
docs/sdlc/review-process.md                        # MOD  phase 3 — verdict sources
docs/sdlc/flow.md                                  # MOD  phase 3 — member set
CLAUDE.md                                          # MOD  phase 3 — workflow step 7 + reading row
adoption/greenfield.md                             # MOD  phase 3 — step 7 wiring
docs/digests/*.md                                  # MOD  phase 3 — regenerated (never hand-edited)
```

## Testing Strategy

Fixture scenarios live under the scratchpad (throwaway repositories, never committed) and their
verdicts are recorded in `contracts/scope-check-repos-cli.md`:

| # | Scenario | Expected |
|---|---|---|
| C1 | in-territory code phase commit | PASS, exit 0 |
| C2 | out-of-territory path | FAIL, exit 1, path named |
| C3 | code repo has no matching branch | not applicable, exit 0 |
| C4 | declared repo directory absent | n/a, exit 0 |
| C5 | declared directory is not a git repo | n/a with reason, exit 0 |
| C6 | commit without a `phase N` token | not applicable |
| C7 | Micro feature — territory from `spec.md` | graded, PASS/FAIL |
| C8 | declaration widened after the code commit | FAIL (D4) |
| C9 | no declaration as of the code commit | WARN, exit 0 |
| C10 | territory names an undeclared repo prefix | config warning, still graded |
| C11 | detached HEAD without `-Branch` | WARN, exit 0 |

Behavior preservation for the extraction: the existing 006 contract scenarios re-run against
`scripts/scope-check.ps1` after phase 1 with identical verdicts, plus `ritual-checks.ps1` green
on this branch.

## Complexity Tracking

| Addition | Why necessary | Simpler alternative rejected because |
|---|---|---|
| A dot-sourced library file | two graders must share one implementation | copying the helpers guarantees the drift the whole feature exists to prevent (D6) |
| A new `kit-adoption.json` field | the repository list must be durable and machine-readable | auto-discovery makes the verdict depend on what is parked in the working directory (D2) |
| A second CI template | code phase commits are pushed to code repositories, where governance CI cannot see them | governance CI cloning N code repos inverts the dependency and multiplies credentials (D5) |
