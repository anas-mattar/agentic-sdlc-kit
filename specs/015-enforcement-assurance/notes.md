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

---

## Phase 2 — GAP-025 and GAP-026 close, test-first

### T013: GAP-025 demonstrated failing, before any fix (D11)

Rule `DIGEST-001` — "a digest on disk does not match what its sources produce" — with both
directions over one recipe (D10). The recipe's source document carries two markers with this
line of ordinary prose between them:

```text
A digest marker opens with `<!--` and closes with the matching arrow run.
```

The `<!--` is inside an inline code span and there is no `-->` later on the line, so
`Get-DocMarkers`' last statement sets `$inComment = $true` and every following line is skipped
until a `-->` appears. The second marker line contains one, so it is consumed as a comment
*close* and never tested against the marker grammar. It vanishes with no message.

Measured, on `4dbbcf5`-era `build-digests.ps1`:

```text
rule      : DIGEST-001
script    : build-digests.ps1
case      : tests/enforcement/cases/build-digests/DIGEST-001/pass
exit code : expected 0, observed 1
first diff at line 1:
  expected: digests: OK (1 digest(s) fresh, 2 marker(s))
  observed: digests: FAIL — stale or hand-edited digest: docs/digests/fixture-digest.md does
            not match its sources — regenerate: pwsh -File scripts/build-digests.ps1
```

**The pass direction is the demonstration, and that is the point of writing both.** A correct
two-bullet digest is called stale because the parser can only produce one bullet. In the kit's
own tree the same defect is silent instead of loud: the digest on disk was generated by the same
blind parser, so generator and checker agree with each other and the rule simply is not in the
digest. Nobody sees a failure. `build-digests.ps1` reports `OK`, and the marker count — the only
number that would give it away — is exactly as wrong as the file.

### A harness defect this case found on the way, and the phase 1 review's shape repeating

The first run of this case reported a diff whose expected and observed lines were *character for
character identical on screen*. They were not identical in bytes: `[Console]::OutputEncoding` in
a fresh `pwsh` on Windows is the console code page (`ibm437` here), and a redirected child
**transliterates every non-ASCII character as it writes** — the em dash in the kit's own message
reached the harness as a hyphen. No reader-side encoding recovers it; the data is gone before the
parent sees a byte.

So the harness could assert on the ASCII half of a message and silently ignore the rest. That is
the phase 1 review's F1 again — *a check that sees part of what it claims to see* — and it
survived phase 1 only because no phase 1 expectation happened to contain a non-ASCII character.
Every one of them would have passed either way.

Fixed in `tests/enforcement/lib/RunChild.ps1`: the child sets UTF-8 on itself before the script
under test runs. Array splatting could not carry the argument vector through — PowerShell splats
an array **positionally**, so `@rest` passes `-Check` as a value rather than as a switch
(measured, not assumed) — so the launcher reconstructs the call, parameter names bare and every
other token single-quoted so a temporary path with a space survives. Phase 1's 18 tests still
pass unchanged, which is what says the launcher changed nothing but the encoding.

### T016/T017: GAP-026 demonstrated failing, then closed

Rule `SCOPE-001` — "a phase commit touches a file outside the phase's declared Territory" — both
directions over one recipe whose phase 1 marker reads:

```text
**Territory** (widened by amendment 2026-01-02, approved by fixture):
```

That is the shape feature 014 wrote **twice** while amending its own territory (`ca88da5`,
`3a51f5c`). `Get-Territory` anchored on `^\*\*Territory\*\*:` — the colon fixed hard against the
marker — so the decorated line was not a declaration at all, the phase fell through to the
pre-006 compatibility WARN, and the check exited 0 having graded nothing. On the very branch that
was widening its scope.

Measured before the fix:

```text
case      : tests/enforcement/cases/scope-check/SCOPE-001/fail
exit code : expected 1, observed 0
  expected: scope-check: FAIL phase 1 commit <SHA>: src/other.ps1 not in territory
  observed: scope-check: WARN commit <SHA>: no territory declared for phase 1 in
            specs/001-thing/tasks.md (declare territory in tasks.md — non-blocking,
            pre-006 compatibility)
```

**The pass direction of this pair earned its keep in a way worth recording.** Its *exit code*
assertion passed — the check exits 0 either way — and only the golden-output comparison caught
that the 0 meant `WARN, nothing graded` rather than `PASS, one file checked`. An exit-code-only
harness would have called that case green. GAP-027 is exactly this, and here it was the fixture
design (compare the whole output, not the verdict) that made the difference rather than any rule.

Note the mirror with `DIGEST-001`: there the **pass** direction was the demonstration and the fail
direction was already correct; here the **fail** direction is the demonstration. Neither GAP is
visible from one direction alone, which is the whole argument for D10.

The fix (`Get-Territory`, `scripts/scope-lib.ps1`) accepts any annotation between the marker and
its colon. That is deliberately the permissive direction, because the two errors are not
symmetrical: reading a non-marker AS a marker ends in a loud duplicate-marker or empty-list FAIL
that names the line, while reading a real marker as prose ends in silence. Only one of them can
hide an undeclared change. Both directions pass; `ritual-checks` stays OK on the kit's own
history, which is what says the looser anchor changed no real verdict.

### T014/T015: the GAP-025 fix, and where the shared logic now lives

The owner's decision (2026-09-19) was the shared one: `Disable-CommentMarkers`,
`Convert-CodeSpanMarkers` and `Get-FencedLineMap` move out of `scripts/enforcement-pack.ps1`
into a new `scripts/markdown-lib.ps1`, dot-sourced by both it and `scripts/build-digests.ps1`.
The functions are unchanged; only their home is. This is the move `scripts/scope-lib.ps1` already
made for the two scope graders, for the reason its own docstring gives — one implementation
cannot drift from itself — and the case for it here is stronger, because this logic has now been
got wrong three times: 014's B7, 014's H1 (reopened by its own first fix), and GAP-025.

The phase's approved Territory did not reach that file or `scripts/enforcement-pack.ps1`, and
T018 needed `scope-check.ps1` and `scope-check-repos.ps1`, which it also did not list. Four paths
added by amendment `06b1b30`, approved by anas.m and recorded before the phase commit.

In `Get-DocMarkers` the disarming applies to the **comment-state update only**. The marker
grammar still reads `$rawLine`, and the `$inComment` branch is deliberately left alone: Markdown
renders nothing inside an HTML comment, so a backticked `-->` in there really does close it.

**T015's measurement is zero, and that is the interesting part.** Regenerating the kit's own
digests after the fix gives `digests: OK (5 digest(s) fresh, 80 marker(s))` — identical to
before. A scan of all five packs' source documents finds **no line at all** that would have
tripped the old parser: every prose mention of the syntax in the kit's law either sits inside a
fenced block (already skipped) or closes its arrow on the same line.

So GAP-025 was **latent here**. The fixture found a real defect that the repository's own content
happened never to trigger — which is the whole argument for fixtures over "run the checks on the
repo and see if they pass". The defect was found by reading, filed as a GAP, and would have
stayed unfalsifiable until the first adopted project wrote one sentence about marker syntax.

### T016/T018: FR-015, and the WARN that graded nothing

The pre-006 compatibility WARN was written for a `tasks.md` that predates the Territory
convention entirely. It was also reached by a document where phase 1 declares and phase 2 does
not — an omission, not a legacy — and there it returned `$true`, so a phase commit was graded
against nothing and the run exited 0. GAP-027's species, reached through GAP-026's door.

`Test-AnyTerritoryDeclared` lives in `scope-lib.ps1` beside `Get-Territory` and uses the same
anchor, so the two cannot disagree about what a declaration looks like. Both graders apply it:
`scope-check.ps1` for this repository's commits and `scope-check-repos.ps1` for the nested ones,
where it sits after the existing post-dating check that feature 012's review already added.

Rule `SCOPE-002`, both directions, demonstrated as a WARN first:

```text
case      : tests/enforcement/cases/scope-check/SCOPE-002/fail
exit code : expected 1, observed 0
  observed: scope-check: WARN commit <SHA>: no territory declared for phase 2 in
            specs/001-thing/tasks.md (declare territory in tasks.md — non-blocking,
            pre-006 compatibility)
```

**Flow-down note for phase 6 (T046).** This rule can newly FAIL an adopted project whose older
features have a partially-declared `tasks.md`. The kit's own history is clean (`ritual-checks`
stays OK), but the announcement that ships with the flow-down must say so plainly, the way
feature 011's stale-branch member did.

### Found, not fixed: the coverage number counts anchors, not tested sites

`not in territory` is emitted at two sites in `scope-check.ps1` — the Micro lane and the Standard
lane — and `SCOPE-001`'s anchor matches both, so the report counts two sites covered where only
the Standard lane has a fixture. The number is therefore an upper bound on what is tested, not a
measure of it.

Not fixed here: the repair belongs with T044, where coverage stops reporting and starts blocking,
and it is a change to what an inventory entry means (it must name the site it covers, not just a
string that appears in the script). Recorded now so that T044 cannot inherit the optimistic
number without noticing. This is the same failure shape as the phase 1 review's F1 — a count that
is plausible and wrong in the flattering direction — and it is being written down rather than
carried.

### The phase 2 fresh-context review, and what it changed

`ai-code-review-phase-2.md` (claude-sonnet-5, fresh context) returned **REQUEST CHANGES**: one
BLOCKING finding and two CONFIRMs. Every claim was reproduced before acting on it.

**F1 (BLOCKING) — the launcher reported exit 0 for a script that never ran.** `RunChild.ps1`
ended in `exit $LASTEXITCODE`, and a parameter-binding failure writes an error while leaving
`$LASTEXITCODE` untouched, so the launcher exited 0. Reproduced against the real script:

```text
pwsh -File tests/enforcement/lib/RunChild.ps1 scripts/build-digests.ps1 -Root -Check
build-digests.ps1: Missing an argument for parameter 'Root'.
exit=0
```

A case expecting exit 0 would have gone green against a script that produced nothing but an error
message. None of phase 2's three fixtures triggers it; phases 3–6 add roughly eighty more, all
through this one file. That is the feature's own thesis pointed at the feature: **a fail-open in
the thing that grades the graders.**

Closed by tracking whether the script ran separately from what it returned. The four shapes,
measured rather than assumed:

| shape | `$?` | `$LASTEXITCODE` | launcher exits |
|---|---|---|---|
| ran, returned normally | True | 0 | 0 |
| ran, called `exit 1` (a real FAIL verdict) | True | 1 | 1 |
| never ran — parameter binding failed | False | 0 | **97** |
| threw before returning a verdict | (caught) | 0 | **97** |

97 is not a verdict any kit script emits, so no case's expected exit code can collide with it, and
the launcher also prints a line saying it is the launcher speaking — a case fails on both channels.

**`tests/enforcement/Harness.Tests.ps1` is new**, because a fail-open in shared harness
infrastructure should not depend on a fixture happening to trip it. Eight tests assert the exit
shapes, argument binding, the non-ASCII round trip, and a single quote inside a value.

**Those self-tests immediately found a second defect, in `Harness.psm1` rather than the launcher.**
`Start-Process` joins an `-ArgumentList` **array** with spaces and quotes nothing, so
`-Root 'C:\Users\A B\Temp\fix'` reached the child as `-Root C:\Users\A`. Every fixture so far has
run from a temporary path with no space in it, so no case could have caught it. Fixed by quoting
elements that contain whitespace (`ConvertTo-ProcessArgument`). Tests 30 → 38.

**A correction to the phase 2 commit message (F3).** It says the decorated marker is what feature
014 wrote "TWICE", citing `ca88da5` and `3a51f5c`. Both citations are wrong, and I did not measure
them before writing the sentence — the same mistake as feature 014's G5:

- `ca88da5` touches no `**Territory**` line in `tasks.md` at all.
- `3a51f5c` is the **repair**, not an instance: it rewrites `**Territory** (widened …):` to
  `**Territory**: widened …` and says in the diff that the decorated spelling is invisible.
- `28d2f0a` is the uncited one, and it shows the form appearing **at least three times**: its
  parent line already read `**Territory** (unchanged):`, and it wrote the wrapped marker that is
  still standing in that file today.

The claim the fix rests on is unharmed and if anything stronger — 014 wrote the decorated form
repeatedly and had to hand-repair it once. Only my citation was wrong, and it is corrected here
because the commit message cannot be.

**F2 and F3 are CONFIRM, and stand open for the owner**, recorded in the review file with my
recommendation rather than decided unilaterally.
