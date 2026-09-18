# 015 Enforcement Assurance — phase evidence

Evidence and decisions that are not themselves law. This file is not graded by the amendment
rule (constitution I grades `spec.md`, `plan.md`, `tasks.md` and `contracts/` only), which is
why recording evidence here never costs an approver record.

## Approval

**2026-09-19 — the owner approved `spec.md` and `plan.md`.** Given in session as "approve the
spec and plan, then start phase 1". The approval covers:

- the spec as written, including its Out of Scope list (GAP-022, GAP-023, GAP-024/GAP-004,
  GAP-018, the 016/017 proposals, and the message-shape rewrite);
- **D2** — Pester 5, pinned: this feature's one new dependency, which `plan.md` is the only
  document able to approve (CLAUDE.md, Strict Rules);
- **D3** — the fourth `kit-manifest.json` class, `kit-only`;
- **D4** — the pass word stays `OK` rather than the proposal's `PASS`;
- the six-phase sequence and `**Gate Certification**: ci-held`.

The spec's `**Status**` line moved `Draft` → `Approved` in the same commit as this record. That
transition is the act that *starts* the amendment rule rather than a change to an approved
document, so it owes no approver record (constitution I, and the exemption feature 014 shipped
as D3d) — it is exempt only in that exact shape, and the commit was kept to that shape
deliberately.

## Phase 1

### T011 — the mutation proof

`Invoke-StructureCheck`'s missing-document condition was inverted in place
(`if (-not (Test-Path $p))` → `if ($false)`), the harness run, and the script restored from a
copy taken first. Under the mutation:

```text
Describing fixture case enforcement-pack/STRUCT-001/fail
  [-] exits with the expected code
   rule      : STRUCT-001
   script    : enforcement-pack.ps1
   case      : …/tests/enforcement/cases/enforcement-pack/STRUCT-001/fail
   exit code : expected 1, observed 0
   first diff at line 3:
     expected: enforcement-pack: FAIL (2 issue(s)):
     observed: enforcement-pack: OK
   reproduce : pwsh -File tests/enforcement/Run-Tests.ps1 -Case enforcement-pack/STRUCT-001/fail -KeepRepo
```

Restored: 16 passed, 0 failed. SC-002 holds for this rule.

### Two fail-opens the mutation proof found — in the harness itself

Both were the feature's own subject matter, committed by the tool built to close it. Recording
them because they are the phase's most useful evidence, not despite being embarrassing.

1. **`-Case` selected zero tests and the run reported `OK`, exit 0.** Pester's `Filter.FullName`
   matches the *unexpanded* `Describe` template, so a templated name filter silently selects
   nothing. Fixed twice over: the filter now narrows discovery through the environment, and
   `Run-Tests.ps1` fails when nothing ran.
2. **The first fix was not enough, and the same proof caught that too.** With `-Case` matching
   no case, the four coverage tests still ran and carried the run to green — so a typo in a
   case name reported `OK` having asserted nothing about any rule. `Run-Tests.ps1` now resolves
   the filter against the case directories *before* Pester starts and fails if it matches none.

### What the hand-written expectations got wrong, and what that proves

Of the six expectations written by hand from the scripts' source strings, five matched on the
first run. The sixth was wrong in one line: the amendment check reports
`graded 0 of 1 commit(s) … (1 not graded: 1 made before the check existed (plan D2b))` on a
fixture repository, because a fixture carries no boundary commit, so every commit predates the
check. My prediction said `graded 1 of 1`. The expectation was corrected to the observed line
after confirming the behaviour is D2b working as designed — not the script corrected to the
expectation.

The em-dash in the Structure messages survives the child-process capture as U+2014 on Windows
(verified by character code, not by eye — the terminal renders it as a hyphen).

### T012 — the harness does not flow down

```text
update-kit: D:\solutions\agentic-sdlc-kit -> D:\solutions\fitforge (dry run - zero writes)
Applied (3):
  kit-manifest.json  [clean update -> copied]
  scripts/doc-lint.ps1  [clean update -> copied]
  scripts/update-kit.ps1  [clean update -> copied]
```

Neither `tests/**` nor `.github/workflows/enforcement-tests.yml` appears. `tests/` is invisible
because it is not one of doc-lint's shipped surfaces; the workflow is skipped because of its
`kit-only` class. D3 holds.

### An implementation detail the plan does not name

Expectations are **golden files compared in full**, not "must contain" assertions, with exactly
two volatile substitutions (`<ROOT>`, `<SHA>`). Full comparison catches a spurious extra
failure line that a contains-check would miss. Deliberately **not** implemented: an
`-UpdateExpectations` switch. Regenerating an expectation from the tool is how a failing test
becomes a passing one without anybody deciding that it should, and this harness's entire claim
is that the tool cannot be its own witness (FR-006). If the maintenance cost proves real, it
arrives as a plan amendment with an owner's approval, not as a convenience.

### Found while inventorying, not fixed (out of this phase's Territory)

The coverage scanner finds **no** failure-emission site in `scope-check-repos.ps1` or
`territory-check.ps1`. For `scope-check-repos.ps1` this is the scanner's blindness, not the
script's silence: it emits through a `Write-Line` wrapper that none of the scanner's patterns
match. `territory-check.ps1` may genuinely emit no `FAIL` — it reports `CLEAN`/`OVERLAP`. Both
are printed as `NO EMISSION SITE FOUND` rather than omitted from the report, and both must be
resolved while inventorying those scripts in phase 4 (T029, T034).

Current coverage: **3 of 78 failure-emission sites** across 9 grading scripts.

### Phase 1 verification

- `pwsh -File tests/enforcement/Run-Tests.ps1` — 16 passed, 0 failed (Pester 5.7.1, pwsh 7.6.6,
  Windows 11). The `ubuntu-latest` leg runs for the first time on this phase's push.
- `pwsh -File scripts/ritual-checks.ps1` — all members OK.
