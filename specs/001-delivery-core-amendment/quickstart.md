# Quickstart: Verifying the Delivery Core Amendment

Run after each phase (as the gate) and once more after the full feature merges. All commands
are PowerShell, run from the repository root.

## Gate: structural integrity (every phase)

```powershell
pwsh -NoProfile -File .\scripts\doc-lint.ps1
"EXIT: $LASTEXITCODE"
```

Expected: `EXIT: 0` and no new broken path references.

## Phase 1 checks — core contradiction fix

```powershell
# SC-001: no per-phase human-review language remains outside review/
git grep -n "human review" -- ':!review/**' | Select-String -Pattern 'each phase|per phase|every phase'
# Expected: no matches

# SC-002: tasks-template no longer calls tests optional
git grep -n "OPTIONAL" -- .specify/templates/tasks-template.md
# Expected: no matches, or matches with revised (non-"tests optional") meaning

# SC-003: Delivery Level field exists in spec-template
git grep -n "Delivery Level" -- .specify/templates/spec-template.md
# Expected: one match

# SC-004: source-of-truth ladder in exactly one file
git grep -rln "spec.md.*plan.md.*contracts\|screenshots.*spec.md.*plan.md" -- '*.md' ':!review/**'
# Expected: exactly one file (.specify/memory/constitution.md)
```

## Phase 2 checks — missing rule definitions

```powershell
# Phase-size rule present
git grep -n "independently revertible" -- .specify/templates/plan-template.md

# Critical-solo artifact and duration named
git grep -n "second-model-review.md\|cooling-off" -- docs/sdlc/critical-delivery.md
```

## Phase 3 checks — renumbering sweep

```powershell
# No stale references to deleted/renumbered principles
git grep -n "Principle X\|principle X\b" -- '*.md' ':!review/**'
# Expected: no matches

# Constitution version bumped
git grep -n "\*\*Version\*\*:" -- .specify/memory/constitution.md
# Expected: 0.3.0
```

## Full-feature check (after merge)

```powershell
pwsh -NoProfile -File .\scripts\doc-lint.ps1
"EXIT: $LASTEXITCODE"
```

Expected: `EXIT: 0`. This is `SC-006`. Combined with the phase-level checks above (SC-001–005,
007), this confirms every Success Criterion in `spec.md`.
