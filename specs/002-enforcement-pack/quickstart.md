# Quickstart: Enforcement Pack Verification

Run by the user at each phase gate, per `docs/sdlc/gate-command.md` — an AI agent proposes
these commands but never claims success without the user confirming the exit code / output.

All fixture branches use the `999-fixture-*` / `fix/fixture-*` naming to avoid colliding with
real feature numbers, and are deleted after verification (never merged, never pushed).

## Phase 1 — Structure check + Lite-lane/abuse-guard check (SC-001, SC-002, SC-004 partial)

```powershell
# SC-001: missing plan.md fails
git checkout -b 999-fixture-missing-plan
New-Item -ItemType Directory -Force specs/999-fixture-missing-plan | Out-Null
"**Delivery Level**: Standard" | Out-File specs/999-fixture-missing-plan/spec.md
git add specs/999-fixture-missing-plan/spec.md
git commit -m "fixture: missing plan.md"
pwsh -File scripts/enforcement-pack.ps1   # expect: FAIL, names missing plan.md/tasks.md
git checkout 002-enforcement-pack
git branch -D 999-fixture-missing-plan

# SC-002: Lite branch touching a migration file fails
git checkout -b fix/fixture-lite-schema
New-Item -ItemType Directory -Force migrations | Out-Null
"-- test" | Out-File migrations/0001_fixture.sql
git add migrations/0001_fixture.sql
git commit -m "fixture: lite branch touching migration"
pwsh -File scripts/enforcement-pack.ps1   # expect: FAIL, names the file + "schema/migration"
git checkout 002-enforcement-pack
git branch -D fix/fixture-lite-schema

# SC-004 (partial): clean fixture passes
git checkout -b 999-fixture-clean
New-Item -ItemType Directory -Force specs/999-fixture-clean | Out-Null
"**Delivery Level**: Standard" | Out-File specs/999-fixture-clean/spec.md
"# plan" | Out-File specs/999-fixture-clean/plan.md
"# tasks" | Out-File specs/999-fixture-clean/tasks.md
git add specs/999-fixture-clean
git commit -m "fixture: clean"
pwsh -File scripts/enforcement-pack.ps1   # expect: PASS
git checkout 002-enforcement-pack
git branch -D 999-fixture-clean
```

Also confirm: pushing this phase's commit triggers `.github/workflows/enforcement-pack.yml`
on GitHub and the run appears in the Actions tab (does not need to pass yet if fixtures
above haven't been pushed — just confirm the workflow fires).

## Phase 2 — Critical-evidence check + phase-size warning (SC-003, SC-005)

```powershell
# SC-003: Critical branch missing second-model-review.md fails
git checkout -b 999-fixture-critical-missing
New-Item -ItemType Directory -Force specs/999-fixture-critical-missing | Out-Null
"**Delivery Level**: Critical" | Out-File specs/999-fixture-critical-missing/spec.md
"# plan" | Out-File specs/999-fixture-critical-missing/plan.md
"# tasks" | Out-File specs/999-fixture-critical-missing/tasks.md
git add specs/999-fixture-critical-missing
git commit -m "fixture: critical missing second-model-review"
pwsh -File scripts/enforcement-pack.ps1   # expect: FAIL, names missing second-model-review.md
git checkout 002-enforcement-pack
git branch -D 999-fixture-critical-missing

# SC-005: oversized single commit warns but does not block
git checkout -b 999-fixture-oversized
New-Item -ItemType Directory -Force specs/999-fixture-oversized | Out-Null
"**Delivery Level**: Standard" | Out-File specs/999-fixture-oversized/spec.md
"# plan" | Out-File specs/999-fixture-oversized/plan.md
"# tasks" | Out-File specs/999-fixture-oversized/tasks.md
1..500 | ForEach-Object { "line $_" } | Out-File specs/999-fixture-oversized/big.md
git add specs/999-fixture-oversized
git commit -m "fixture: oversized phase commit"
pwsh -File scripts/enforcement-pack.ps1   # expect: WARNING printed, exit code still 0
git checkout 002-enforcement-pack
git branch -D 999-fixture-oversized
```

## Phase 3 — Merge-gate wiring (SC-006, SC-007)

Manual verification against the live GitHub repository (no fixture branch can simulate
GitHub's own merge-button UI):

1. Apply `docs/sdlc/branch-protection.md`'s steps to `main`.
2. Open a throwaway PR from a branch with a deliberately failing check (e.g. Phase 1's
   `999-fixture-missing-plan` pushed and opened as a PR). Confirm the merge button is
   disabled while the check is red. **SC-006**.
3. Confirm the PR description was pre-populated from `.github/PULL_REQUEST_TEMPLATE.md`,
   including the human-review checklist and the gate exit-code field. **SC-007**.
4. Close the throwaway PR without merging; delete the remote branch.
