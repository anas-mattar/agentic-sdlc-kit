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

Three scripts are **declared undeclared** in `emission-idioms.json` — their emission idiom has
not been worked out, they say so in writing with the task that resolves them, and a test asserts
that the writing exists. `scope-check-repos.ps1` emits through a `Write-Line` wrapper that also
carries informational and WARN lines, so naming the wrapper would inflate the denominator with
non-rules (T029). `territory-check.ps1` reports `CLEAN`/`OVERLAP` and may emit no `FAIL` rule at
all — which of the two is true is itself T034's question. `ritual-checks.ps1` is an aggregator
whose only failure is "a member failed" (T035).

Coverage after the F1 remediation: **3 of 88 declared failure-emission sites** across 9 grading
scripts, with **31 unclassified candidate lines** across 6 of them. The second number is the one
to watch — see the review record below for why it exists.

### The phase 1 fresh-context review, and what it changed

`ai-code-review-phase-1.md` (claude-sonnet-5, fresh context) returned **REQUEST CHANGES** with
one BLOCKING finding, F1. Every count in it was reproduced before acting on it, and every count
held: the coverage scanner's six hard-coded regexes — modelled on `enforcement-pack.ps1`'s idiom
and applied to all nine scripts — silently undercounted three of them. `verify-kit.ps1` 11 of 16
(six sites single-quoted). `doc-lint.ps1` missed its own headline rule, which accumulates a
`PSCustomObject` rather than a string. `build-digests.ps1` found **0 of its 10 real rules** while
counting the wrapper that prints them — it measured the printer.

The finding's framing is the part worth keeping: **partial blindness is worse than total
blindness.** A script the scanner cannot see at all reports `IDIOM UNDECLARED` and provokes a
question; one it half-sees reports a plausible number nobody questions. The original guard caught
only total blindness, which is why the first commit's message congratulated itself on it.

Remediated in `c488560`, taking both halves of the suggested action rather than choosing:
`emission-idioms.json` declares per script how that script actually emits (patterns stop before
the message, so quote style no longer decides whether a rule exists), and a deliberately broad
recall sweep runs alongside, its hits minus the declared ones printed as unclassified candidates.
That difference is what gives partial blindness a number. Two tests were added to assert the
declaration is complete and that any undeclared script says so with a reason.

**The recall sweep was itself blind on its first run, and that is how it was caught.** Written as
`Write-Host`, it reported **0** candidates for `scope-check-repos.ps1` — whose `Write-Line`
wrapper is the exact reason that script is undeclared. The recall pass had reproduced the precise
pass's blindness, which defeats its entire purpose. Broadened to `Write-\w+`, it reports 10.

Fixed now rather than deferred to phase 6, per the reviewer's own sequencing argument: phase 2
fixes `build-digests.ps1`, the script whose real rules were 100% invisible, and a baseline that
reads 0 would have made that phase's before/after meaningless.

Two non-blocking findings stand **unremediated by choice**, and are the owner's call at the gate:
both phase 1 commits exceed the phase-size guideline (1,272 and 531 lines). The phase is one
harness that cannot be usefully halved — a fixture runner without cases asserts nothing.

### Phase 1 verification

- `pwsh -File tests/enforcement/Run-Tests.ps1` — **18 passed, 0 failed** (Pester 5.7.1, pwsh
  7.6.6, Windows 11), and green on `ubuntu-latest` for the first time on this phase's push.
- `pwsh -File scripts/ritual-checks.ps1` — all members OK, including
  `scope-check: PASS phase 1 commit c488560` and the `enforcement-pack` Reviewer Provenance
  check accepting `ai-code-review-phase-1.md`.

### Phase 1 gate evidence (ci-held, plan `**Gate Certification**: ci-held`)

Phase commit **`c488560e393a7cc0d391b2ae4df2d9694f74b467`**. Both required workflows completed
with conclusion `success` on that exact sha:

| Workflow | Run | Conclusion |
|---|---|---|
| `enforcement-tests` | <https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/35371015704> | success |
| `ritual-checks` | <https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/35371015826> | success |

The triplet is reported here; **certification is the owner's**, and is recorded in a separate
commit once given (`docs/sdlc/gate-command.md`).

### Phase 1 gate — CERTIFIED

> Gate 1 certified (ci-held): run
> <https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/35371015826>, conclusion success,
> commit `c488560` (phase 1) — approved, anas.m, 2026-09-19.

The `enforcement-tests` run on the same sha
(<https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/35371015704>, conclusion success)
is cited alongside it: the harness this phase builds is not yet a member of `ritual-checks`, so
its own green is evidence the ritual-checks run does not carry. Phase 6 (T045) folds it in, after
which one run will.

The two non-blocking phase-size findings were before the owner at certification and are accepted
as they stand. A second review round on the `c488560` remediation was declined; phase 2 opens.
