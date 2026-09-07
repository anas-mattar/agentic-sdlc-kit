# Quickstart: Verification Pack

How to exercise each check after implementation — these seeded scenarios ARE the feature's
deterministic validation (constitution VIII; the kit has no test framework, 002 precedent).
Run them from a scratch clone or a throwaway branch; every scenario states its expected verdict.

## Scope check (phase 1)

Setup once: a throwaway feature branch `999-scope-demo` with `specs/999-scope-demo/tasks.md`
declaring for Phase 1:

```markdown
## Phase 1: demo

**Territory**:
- `demo/allowed/**`
```

| # | Do | Expect |
|---|---|---|
| S1 | Commit `demo/allowed/a.txt` with subject `phase 1: in territory` → `pwsh -File scripts/scope-check.ps1` | `PASS`, exit 0 |
| S2 | Commit `demo/stray.txt` with subject `phase 1: stray` → run | `FAIL … demo/stray.txt not in territory`, exit 1 |
| S3 | One commit that both adds `demo/stray2.txt` and widens Territory to include it → run | still `FAIL` (declaration read from parent) |
| S4 | Commit widening Territory alone, then commit `demo/stray2.txt` → run | `PASS` |
| S5 | On a `fix/anything` branch → run | `not applicable`, exit 0 |
| S6 | Commit on `999-*` with subject lacking a `phase N` token → run | `not applicable` (not a phase commit — review F8), exit 0 |
| S7 | `git mv demo/allowed/a.txt demo/moved.txt`, commit as phase 1 → run | `FAIL` (rename target undeclared) |
| S8 | tasks.md in the kit's real layout — territory list followed by a `- [ ] T00x` checklist → phase commit inside territory → run | `PASS`; the checklist is never parsed as territory (review F1) |
| S9 | Commit `demo/allowed/héllo café.txt` as phase 1 → run | `PASS`, exit 0 (quotepath — review F3) |
| S10 | Any commit deleting `specs/999-scope-demo/tasks.md` (with or without a `phase N` token) → run; then a phase commit re-adding it widened + a stray file → run `-All` | deleting commit `FAIL`, exit 1 (checked before phase attribution); `-All` over the branch stays red, so the re-add can never launder the stray. The re-add also FAILs in isolation whenever the feature dir survives at the parent — i.e. every real feature, whose dir holds spec.md/plan.md (anti-bypass — review F2) |
| S11 | `**Territory**:` marker with an empty entry list → phase commit → run | `FAIL`, exit 1 (review F8) |

Also verify backward compatibility: runs against a pre-006 feature's phase commits
(e.g. `-Commit <sha> -Branch 003-flow-efficiency-pack`) must produce only WARNs, never FAILs.

## Review provenance (phase 2)

On the same throwaway branch:

| # | Do | Expect from `enforcement-pack.ps1` |
|---|---|---|
| P1 | Add `specs/999-scope-demo/ai-code-review-phase1.md` from the amended template, provenance block filled, `Reviewer:` = `fresh-context agent — <model>` | OK |
| P2 | Add a review file with no `## Reviewer Provenance` section | FAIL naming the file |
| P3 | Add a review with `Reviewer: implementer` | FAIL |
| P4 | Delete the throwaway reviews; branch diff adds no review files | OK (checks only added files) |
| P5 | Run on `main` (001–005 reviews present, none added in diff) | OK (grandfathering) |

## Ritual wrapper + CI (phase 3)

| # | Do | Expect |
|---|---|---|
| R1 | `pwsh -File scripts/ritual-checks.ps1` on a clean feature branch | three `OK` lines, `RESULT OK`, exit 0 |
| R2 | Introduce any single violation (e.g. S2) → rerun | that member `FAIL`, others still run, `RESULT FAIL`, exit ≠ 0 |
| R3 | Push a branch with R2's state | GitHub check `ritual-checks` goes red with the same member verdicts as R2 |
| R4 | Fix and push | check goes green with no human initiation |

## Phase gates

- Phases 1–3 (batched, plan.md): after each phase the agent runs the phase's scenarios above
  plus doc-lint + enforcement-pack and reports output; the owner runs the certifying gate once
  at batch end: `pwsh -File scripts/ritual-checks.ps1` then `"EXIT: $LASTEXITCODE"` (expect 0)
  plus scenario spot-checks S2, S3, P2 at minimum (the fail paths are the product).
- Phase 4: owner runs `pwsh -File scripts/ritual-checks.ps1` (expect `RESULT OK`, exit 0).
