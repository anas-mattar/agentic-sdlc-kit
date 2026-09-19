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

### Phase 2 gate — CERTIFIED

> Gate 2 certified (ci-held): run
> <https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/35376670445>, conclusion success,
> commit `505f9f1` (phase 2) — approved, anas.m, 2026-09-19.

> **Superseded. Gate 2 re-certified (ci-held)**: run
> <https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/35377283515>, conclusion success,
> commit `8a0291b` (phase 2, T019a) — approved, anas.m, 2026-09-19.

The first certification was taken too early, and the sequence is the lesson: the gate was
certified on `505f9f1` while the review's two CONFIRM findings were still open, and deciding them
grew the phase by two commits. **A phase is not finished for gating purposes while any finding of
its own review is undecided**, even a non-blocking one — decide first, then certify. Both records
are kept rather than the first being edited away, because what was certified when is exactly the
kind of thing this feature exists to make unforgeable.

`enforcement-tests` on the same sha
(<https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/35376670461>, conclusion success)
is cited alongside it, as in phase 1 — the harness is not yet a `ritual-checks` member, so the
certifying run does not execute it. T045 folds it in.

The phase ends at `505f9f1`, the F1 remediation, not at `c5c7e26`.

### The two CONFIRM findings, decided

The owner adopted both recommendations as written (2026-09-19).

**F2 → GAP-028, filed, not fixed here.** The multi-line code-span case reaches
`enforcement-pack.ps1`'s `Get-VisibleFromText` through the same shared function, so it touches
amendment-authority grading and deserves its own demonstration and its own review rather than a
tail-end edit to a phase already reviewed.

**F3 → fixed here: the near-miss becomes loud.** Not by teaching the parser to join continuation
lines — a multi-line scanner is new machinery for a rare shape — but by refusing to stay silent
about a line that begins `**Territory**` and carries no colon. That is the pattern
`build-digests.ps1` already uses for a malformed digest marker (feature 014 review F6/F7): a line
that starts like a declaration and breaks the grammar FAILs rather than vanishing. Recorded as an
amendment to `tasks.md` because it is work the approved task list did not contain.

### T019a: the wrapped marker, demonstrated silent then made loud

Rule `SCOPE-003`, both directions over one recipe that differs only in whether the annotation
fits on the marker's own line. Before the fix:

```text
case      : tests/enforcement/cases/scope-check/SCOPE-003/fail
exit code : expected 1, observed 0
  observed: scope-check: WARN commit <SHA>: no territory declared for phase 1 in
            specs/001-thing/tasks.md (declare territory in tasks.md — non-blocking,
            pre-006 compatibility)
```

A perfectly good entry list sat two lines below the marker and the check said "no territory
declared", non-blocking, exit 0.

`Get-Territory` now records a line that begins `**Territory**` and carries no colon as a
**near miss** rather than ignoring it, and both graders refuse on it, naming the line number. The
parser is not taught to join continuation lines: a parser that guesses where a declaration ends
is a worse trade than one that asks the author to be plain, and the same judgement is already
made in `build-digests.ps1` for a malformed digest marker.

Tests 38 → 42. `ritual-checks: RESULT OK` — the kit's own current branch has no near miss.
`specs/014-amendment-authority/tasks.md:322` does, and would now be named rather than ignored;
that branch is merged and is not re-graded, so nothing turns red today.

---

## Phase 3 — the enforcement pack under test

### T020: Lite lane and Micro lane inventoried and covered

Eleven new rules with both directions each, on top of phase 1's three `Invoke-StructureCheck`
rules: `LITE-001..003` (prohibited category, abuse guard, migration path), `MICRO-001..007`
(halfway promotion, gate batching in a mini-spec, duplicate Territory block, territory cap, glob
entry, phase line bound, more than one phase) and `PHASE-001` (the phase-size warning).

**Expectations were predicted from the source strings, not copied from a run.** Six of six Lite
assertions and thirteen of fourteen Micro assertions matched first time. The one miss is recorded
below rather than quietly corrected.

**Four pairs now pin a boundary that was only ever a comment.** `LITE-002`'s pass case sits at
exactly 25 files, `MICRO-004`'s at exactly 5 territory entries, `MICRO-006`'s at exactly 400
lines, `PHASE-001`'s at exactly 400 lines. Each fail case is one past. A fixture, not a reading of
the code, now says the comparison is `>` and not `>=` — and an off-by-one in any of them stops
being invisible.

**The one wrong prediction, and why it is a good one to have made.** `MICRO-006`'s 401-line phase
also trips `PhaseSizeWarning`, which prints a `WARNING:` line before the `FAIL` block. My
expectation named only the Micro failure. The script is right and the expectation was incomplete,
so the expectation was corrected — and the pair of cases it produced is now the clearest statement
of the difference between the lanes: **the same 401 lines are a non-blocking warning on Standard
(`PHASE-001`, exit 0) and a hard failure on Micro (`MICRO-006`, exit 1).** Two rules read the same
number and disagree about what it means, and both are now held by fixtures.

### The coverage denominator was flattering itself, and that is fixed here

`emission-idioms.json` declared only `$script:failures +=` for `enforcement-pack.ps1`, with a note
saying warnings were deliberately excluded until phase 5 settled the vocabulary. That reasoning
does not survive contact with `PHASE-001`: the phase-size warning **is** a rule, it now has a
fixture pair, and leaving it out of the denominator improved the coverage percentage by hiding a
rule rather than by covering one. `$script:warnings +=` is now counted. Where WARN sits in the
verdict vocabulary is still phase 5's question (D4); whether it is a rule is not.

After T020: **86 tests, 0 failed**; coverage **19 of 92** declared sites, `enforcement-pack.ps1`
at **14 of 43** with one unclassified candidate left. The denominator grew from 89 to 92 because
warnings joined it — the number went down for an honest reason, which is the only kind of movement
worth trusting in a coverage report.

Runtime is now roughly two minutes locally, since every case builds a real git repository. T026's
git-reality cases will add more. If it becomes a problem the answer is parallel Pester containers,
not fewer fixtures — but it is not a problem yet, and this note exists so the first person to feel
it knows it was seen.

### T020a: the divergence phase 2 created, closed by deleting the copy

**This one is mine, and it was reported to the owner as absent before it was found.** Asked by the
phase 2 review to check for a second parser of the Territory marker, I ran a grep whose pattern
(`Territory\*\*`) could not match the escaped regex as it appears in the source, and reported that
`scope-lib.ps1` was the only parser. A search that cannot find a positive proves nothing when it
finds nothing. The correct result:

```text
enforcement-pack.ps1:514   '^\*\*Territory\*\*:'        strict, unchanged
scope-lib.ps1:96           '^\*\*Territory\*\*[^:]*:'   widened in phase 2
```

Before phase 2 both were blind and therefore agreed. My GAP-026 fix widened one and left the copy
strict, on the one lane whose entire meaning is its bounds.

Demonstrated first (D11) by moving `MICRO-004` onto a decorated marker in **both** directions — the
pair still differs only in the entry count, so D10 holds — and measuring what the check says about
a mini-spec declaring six files where five is the cap:

```text
case      : tests/enforcement/cases/enforcement-pack/MICRO-004/fail
exit code : expected 1, observed 0
  expected: enforcement-pack: FAIL (1 issue(s)):
  observed: enforcement-pack: OK
```

The cap, the duplicate check and the glob check all passed vacuously while `scope-check`, sharing
the widened parser, enforced the very same block.

**Fixed by deleting the copy rather than widening it.** `Invoke-MicroLaneCheck` now calls
`Get-Territory -Global` from `scope-lib.ps1`, and nothing in `enforcement-pack.ps1` parses that
marker any more. Widening the copy would have restored agreement today and left two parsers to
diverge again at the next change; the comment on the old line had promised alignment and could not
deliver it, because a promise in a comment is not a mechanism.

`Get-Territory` gained `MarkerCount` rather than making do with `Duplicate`, because the Micro
message names the number. **A caller forced to soften its wording in order to reuse a shared
parser is a caller that will keep its own copy instead** — which is the defect being fixed, so the
shared function was made to fit the caller rather than the other way round.

`MICRO-008` carries the Micro half of T019a: both graders now say the same thing about the same
wrapped, colon-less marker line, because both now ask the same function.

One behaviour arrives with the shared parser that the copy did not have: an entry that is absolute
or contains `..` now lands in `Invalid` instead of `Entries`, so it no longer counts toward the
five-file cap. No rule reports it on this lane. It is not a regression — such an entry was always
illegal — but it is a gap in the Micro lane's reporting that phase 4 should either cover or
deliberately leave, and it is written here so the choice is made rather than inherited.

### T021: Critical evidence, both arms — and two harness gaps that had made these rules unprovable

Ten rules: `CRIT-S01..03` on the solo arm (the default — no `kit-adoption.json` means no roster)
and `CRIT-T01..07` on the team arm, selected by two names in the roster. All 20 cases green.

**The harness could not build the states these rules refuse.** Two of them were unprovable by
construction, which is worth saying plainly: a rule nobody can write a fixture for is a rule
nobody has ever tested, and it had been sitting in the kit since feature 013.

- **`hoursAgo`** back-dates a commit's author *and* committer date. The cooling-off rule measures
  elapsed time, so before this the only testable value was "0 hours ago" — the boundary itself was
  unreachable. `CRIT-S03` now sits either side of it at **23.5h (fails) and 24.5h (passes)**.
  Relative and resolved at build time, never absolute: an absolute date is a fixture that passes
  today and fails on some later Tuesday. Both dates are set, because which one a rule reads is the
  rule's business, and a fixture that set only the one today's rule happens to read would quietly
  stop testing anything the day that changed.
- **`uncommitted`** writes files after the last commit and leaves them unstaged. Two kit rules
  exist only to refuse that state — *evidence that exists only in a working tree is not evidence* —
  and no recipe could produce it. `CRIT-S02` and `CRIT-T02` are the first fixtures either has had.

**Every Critical case was wrong on the first run, in the same way, and the mistake was mine.** I
predicted the `AmendmentAuthority` commit count as the recipe's total. It grades `base..HEAD`, and
the merge base with `main` **is** the init commit, so it sees one fewer. Twenty expectations
corrected; the script was right every time. Worth recording because it is the failure mode
FR-006 is written against, arriving from the other direction: not a tool computing its own
evidence, but a human mis-modelling what the tool measures. The pass/fail pairs caught it
instantly because both directions carry the same frame.

The team arm's `CRIT-T02` is the one to keep an eye on in review: it proves the check reads the
**committed blob** rather than the working-tree file, which is the hole feature 013's phase 4
re-review found (copy the template in early, fill it locally at review time, never commit, pass).

### T022: gate batching and gate certification

Six rules: `BATCH-001..004` (unparseable value, reversed span, span past the cap, a batch declared
on a Critical feature) and `CERT-001..002` (an illegal certification value, `ci-held` declared on a
Critical feature).

`BATCH-003`'s pass case sits at exactly three phases and its fail case at four, so the cap joins
the other four boundaries a fixture now holds rather than a comment.

**Both Critical cases carry a valid, cooled-off second-model review in _both_ directions.** Without
it the Critical evidence check fires as well, and the case would be exercising two rules while
claiming to exercise one — a fixture that fails for the right reason by accident is not evidence
that the rule under test works. This is the practical cost of D10's "differ only in the condition
under test": the *rest* of the recipe has to be legal, and making it legal is where the reading
happens.

`CERT-001` covers the Standard arm, where the declaration lives in `plan.md`. On a Micro feature
its home is the mini-spec instead — the lane has no `plan.md` — and that arm is phase 4's.

### T023: review provenance — and an anchor that was counting the wrong lines

Five rules, `PROV-001..005`, over `Invoke-ReviewProvenanceCheck`: the machine half of gate 5.
Eleven cases, because `PROV-004` carries a third direction (below). Every expectation was right on
the first run.

Three of the five are worth naming for what the fixture pins rather than for the rule:

- **`PROV-003` holds the phase 2 review's F1 in place.** The template puts a `**Reviewer**:` field
  in the document header *and* one inside the provenance block, and the check slices the block out
  before reading, so the header cannot answer for it. Both directions of this case carry a
  **filled** header line; only the block's line differs. The fail case therefore looks answered to
  anyone skimming the top of the document and is refused by the check — which is the entire reason
  the slice exists, and it is now a fixture rather than a comment above the regex.
- **`PROV-004` is one emission site with two conditions**, so it has `pass`, `fail` and
  `fail-implementer`. `fail` is the bracketed template placeholder; `fail-implementer` is the
  implementing session named as its own reviewer — the condition gate 5 is actually about. A
  pass/fail pair alone would have covered the site while leaving the law untested, which is the
  coverage denominator being satisfied instead of the reader.
- **`PROV-005` paraphrases the attestation rather than deleting it** — "did not write the code
  under review" for "did not produce the diff under review." Deleting the sentence tests that
  something is checked; paraphrasing tests that the match is *verbatim*, which is the only thing
  the rule says.

**A harness gap, the mirror of T021's.** `uncommittedDelete` removes a file from the working tree
after the last commit without staging the removal. The commit-to-commit diff still names the file
and the disk does not have it, which is precisely the state `PROV-001`'s fail-closed branch exists
to refuse — and no recipe could build it, so that branch had never run. It is the mirror of
`uncommitted` from T021: one rule family refuses evidence that exists *only* in a working tree, the
other refuses evidence that has *left* one.

**The finding that mattered here was in the inventory, not in the script.** Two anchors written in
T021 were substrings of ReviewProvenance lines they have nothing to do with:

| Rule | Anchor as written | Also matched |
|---|---|---|
| `CRIT-T04` | `has no filled '**` | the `ReviewProvenance` line at `enforcement-pack.ps1:619` |
| `CRIT-T07` | `is missing the verbatim attestation sentence` | the same rule's line at `:624` |

Nothing was red. The coverage report simply counted those two provenance sites as **already
covered** — by Critical-evidence fixtures that never reach them. That is the inventory lying
*upward*, which is the one direction D8 exists to prevent: an honest zero gets fixed, an inflated
number gets believed. It also explains an arithmetic that looked wrong and was: adding five rules
moved the enforcement-pack count by three.

Both anchors now name their own document (`human-pr-review.md …`), and the ambiguity is closed by
assertion rather than by care — `Coverage.Tests.ps1` now fails when an anchor matches a number of
emission sites other than the number its rule declares. A rule may legitimately own more than one
site: `SCOPE-001`'s Micro arm and Standard arm print the same sentence from two places, because it
is one rule differing only in which document the territory came from. That is now written down as
`"siteCount": 2` — **declared, never inferred**, so the next duplicate has to be argued for rather
than absorbed.

**What T023 deliberately does not cover.** `Invoke-ReviewProvenanceCheck` opens with
`if (-not $Base) { return }`, and that silent return is the member GAP-027 named: on a depth-1
clone a review file with no provenance block passes green. Covering it needs the `UNGRADED` state
that does not exist yet, so the fixture belongs to T037 with the rest of phase 5 — recorded here so
the omission is a decision and not an oversight.

### T024: amendment authority — twelve cases, and a fixture that was green without testing anything

Two rules, `AMEND-001` (a document amended after approval with no conforming record) and
`AMEND-002` (a record whose commit message does not name its approver), across twelve cases.
`AMEND-001` carries ten directions, because this rule is mostly made of what it does **not** fire
on: four failing conditions and five exemptions, each of which is a decision feature 014 paid for
in a review round and none of which had a fixture until now.

| Direction | What it holds |
|---|---|
| `fail` | the plain case: an approved plan rewritten, nobody named |
| `fail-hidden-record` | a correct record inside an unterminated HTML comment (H1) |
| `fail-placeholder` | an unfilled `{{APPROVER}}` slot — the failure names what it rejected (D6) |
| `fail-rename-content` | a contract renamed and reinterpreted in one commit (H3) |
| `pass` | the same edit with a record and a message that names its approver |
| `pass-creation` | a document's first appearance (D2) |
| `pass-checkbox` | a task ticked off (D3c) |
| `pass-status` | Draft → Approved, the act that starts the rule (D3d) |
| `pass-renumber` | the whole feature directory moved by a lost claim race (J3) |
| `pass-rename-identical` | the same move within the directory, content intact (J3, other side) |

**Every fixture commits a stub `scripts/enforcement-pack.ps1`.** The D2b boundary asks a commit's
parent tree one question — does its copy of that path define `Invoke-AmendmentAuthorityCheck`? —
so a fixture without it has every commit report as pre-boundary. That is a fixture which grades
nothing while printing green, and it is the reason each expectation here asserts
`graded 1 of 2 commit(s)`: the count line is what distinguishes an exemption that was **evaluated**
from a commit that was never looked at. Five of these twelve cases are passing cases, and without
that line all five would be indistinguishable from a broken fixture.

**`pass-renumber` was green and testing nothing, and the fixture had to be read to find out.** The
first version built the pre-rename `spec.md` already carrying the new branch number, so git
reported `R100` on all three documents and the *blob-identity* shortcut exempted the move. The
feature-directory rule J3 exists for — a renumbered branch whose `spec.md` also gained the header
edit `claim-feature.ps1` mandates, which makes the move `R084` and not `R100` — was never reached.
Corrected, and confirmed by reading `git log --name-status` inside the kept fixture rather than by
trusting the green: `R084` on `spec.md`, `R100` on the other two.

That is the same species as T023's anchor finding and worth naming as a pattern, because it is the
failure mode this whole harness is exposed to: **a passing fixture proves the run was green, not
that the branch under test ran.** Two habits catch it, and both are now in use — assert the
graded-count line so an unevaluated commit cannot masquerade as an exempt one, and pair every
exemption with a failing case that differs only in the exempt condition. `fail-rename-content`
pins rename detection itself: were the move read as an add, the check would exempt it and that
case would go green for the wrong reason.

**What T024 leaves.** Four `AmendmentAuthority` emission sites remain uncovered — the shallow
clone, the absent base, unparseable commit metadata and an unreadable parent. All four are the
git-reality conditions of **T026**, which is where their fixtures belong. One arm of `AMEND-001`
is deliberately left out and not deferred: a record dated later than its own commit. Reaching it
needs a commit back-dated by a year, and the message then prints that commit's own date, which
makes the expectation a hand-written file that changes every day — the one shape a fixture must
never have (T021). The placeholder arm covers the same `Malformed` path.

### T026: the git-reality conditions, and a harness capability that had never run

Feature 014 spent nine review rounds on states that only a real repository can be in. Four of
them now have fixtures, and the last one turns out to be unreachable.

| Rule | State | Built with |
|---|---|---|
| `AMEND-003` | a depth-1 clone — the ordinary `actions/checkout` shape | `shallow: 1` |
| `AMEND-004` | no integration branch, so no range to walk | a repository with no `main` |
| `AMEND-005` | a parent whose blob is in the store and cannot be inflated | `truncateBlob` |
| `PACK-001` | a run with no base, reporting that nothing was compared | no `main`, on a `fix/` branch |

Plus three cases on rules that already existed: `AMEND-001/pass-merge` (a multi-parent commit,
D7), and `AMEND-001/fail-nonascii` and `PROV-002/fail-nonascii` — the same `core.quotepath`
problem read by two different graders. Both non-ASCII cases are **failing** directions on purpose:
without `-c core.quotepath=off` the path arrives octal-escaped and quoted, fails the directory or
filename filter, and the document is never graded at all. A passing case there would be
indistinguishable from not looking.

Every one of the three `cannot grade` rules is paired with a passing direction that carries the
**same unapproved amendment**. That is deliberate: the interesting claim is not that the check
declines on a broken clone, it is that declining is the only thing standing between it and a
verdict — so the pass direction shows it reaching that verdict.

**`truncateBlob` had never run.** It was documented in the recipe shape from phase 1, and the
first case to use it died with `UnauthorizedAccessException`: git writes loose objects read-only,
because nothing is ever meant to rewrite one. A capability nobody had exercised was a capability
that did not work — which is the argument for this whole feature, arriving from inside the harness
rather than from the kit. Fixed by clearing the attribute first.

**`merge` is new.** A merge has two parents and no content of its own, so it is the one commit a
recipe could not describe with files, and D7's "a merge authored nothing" skip had no fixture.

**The merge fixture was flaky, and the flake is worth keeping in the record.** It failed two runs
in four, alternating between `graded 1 of 3` and `graded 2 of 3`. The cause is not the harness:
`rev-list --reverse` orders by commit date, the two sides of the merge were committed inside the
same second, and the tie let the walk reach the post-boundary commit first. The boundary flag is
**sticky** — once a commit is graded, later ones skip the boundary test — so reaching the branch
in the other order grades the pre-boundary commit as well.

Two things follow. The fixture now dates its sides three and two hours ago, which pins the walk
order; six consecutive runs agree. And the behaviour itself is worth a reviewer's eye: on a real
branch whose commits share a second, the D2b boundary can leak by one commit. It leaks in the
**fail-closed** direction — the sticky flag only ever turns grading on, so the check can grade
more than it must and never less — but a commit made before the check existed is one nobody could
have complied with, so what it costs is a false positive rather than a miss. Not fixed here: it is
the check's semantics, not this phase's territory, and it is recorded so the decision is made
rather than inherited.

**One emission site is left uncovered on purpose.** `AmendmentAuthority: could not parse commit
metadata` is B1's guard — the assertion that a commit `rev-list` names but the metadata batch did
not parse is a parse failure rather than a commit to skip. It is unreachable by construction now
that the fix it guards is in place: git refuses a NUL in a commit message, records are split on
NUL, and the field order caps the split at five so an injected separator can only truncate the two
message-derived fields. No state a repository can be in produces a short record. It stays in the
count as uncovered, which T027 records and T045 is where a site may formally opt out with its
reason — inventing a fixture that faked it would be worse than the honest gap.

### T027: the coverage reading, and what a coverage number structurally cannot see

The reporter at the end of phase 3:

```text
coverage: 48 of 93 declared failure-emission site(s) inventoried across 9 grading script(s)
coverage: build-digests.ps1        1 of 10 site(s) inventoried, 7 unclassified candidate(s)
coverage: doc-lint.ps1             0 of 8 site(s) inventoried
coverage: enforcement-pack.ps1     43 of 44 site(s) inventoried, 1 unclassified candidate(s)
coverage: ritual-checks.ps1        IDIOM UNDECLARED — 1 unclassified candidate line(s)
coverage: roadmap-claim-check.ps1  0 of 2 site(s) inventoried, 1 unclassified candidate(s)
coverage: scope-check-repos.ps1    IDIOM UNDECLARED — 12 unclassified candidate line(s)
coverage: scope-check.ps1          4 of 13 site(s) inventoried, 2 unclassified candidate(s)
coverage: territory-check.ps1      IDIOM UNDECLARED — 4 unclassified candidate line(s)
coverage: verify-kit.ps1           0 of 16 site(s) inventoried, 4 unclassified candidate(s)
coverage: 32 unclassified candidate line(s) in total
```

47 rules, 106 cases. (Superseded by the diff review below, which found a regression and added a
rule: the phase closes at **48 rules, 108 cases, `enforcement-pack.ps1` 44 of 45**. The reading
above is left as it stood, because it is the reading T027 actually took.)

Phase 3 owns `enforcement-pack.ps1`; the 45 sites outstanding in the other
eight scripts are phases 4's tasks T028–T035, and T036 is where their full list is recorded.

**One site was uncovered for no reason at all, so it is covered instead of excused.** The
branch-naming arm at `enforcement-pack.ps1:1216` — `Branch naming: '<branch>' does not match a
known taxonomy` — had no rule because nobody had written one, and "uncovered because nobody wrote
it" is a task doing its own paperwork rather than its job. It is now **PACK-002**, with the
dispatch chain's own shape as its argument: a branch named `feature/thing` reaches no lane, so
every scripted check is skipped and the run is otherwise indistinguishable from a clean one. The
pass direction is `chore/thing` over a byte-identical tree, so the two differ only in the branch
name (D10).

**One site stays uncovered, deliberately.** `AmendmentAuthority: could not parse commit metadata`
at `:1056` — B1's guard — is unreachable by construction, for the reasons set out in the T026
section above. It remains in the denominator as an honest gap. T045 is where a site may opt out
with a written reason; until that exists, faking a fixture for it would be worse than the gap.

**The one UNCLASSIFIED line in this script is a false positive, and stays one.** `:1221` is
`enforcement-pack: FAIL (N issue(s)):` — the header that prints the count, not a rule that can
fail. The recall sweep is built to over-report rather than miss, so a header matching
`Write-Host "...FAIL..."` is the sweep working. Resolving it means writing down which of the two
it is, not silencing it.

**What 43 of 44 does not mean, and this is the part for the review.** The denominator is built
from emission lines: the scanner counts the ways a script can *speak*. Every check that returns
without grading says nothing, so no scan can see it. In this script that is at least
`Invoke-MicroLaneCheck:551`, `Invoke-ReviewProvenanceCheck:585` and
`Invoke-PhaseSizeWarningCheck:633` — three `if (-not $Base) { return }` returns — alongside the
level and lane guards that legitimately skip. So the reading is "43 of the 44 ways this script can
speak", never "43 of the 44 ways it can be wrong". A coverage figure that measures emissions is
structurally blind to silence, and silence is precisely GAP-027.

Two consequences, both worth stating before phase 5 rather than during it. The measure must not be
read as completeness — that is why D9 keeps it reporting-only until T044, and why the unclassified
count is the number to watch. And when T039 turns those silent returns into `UNGRADED` emissions,
they enter the denominator and **this percentage will fall**. That fall is the instrument getting
better, not the coverage getting worse; recorded here so phase 5's review reads it that way.

**A timing measurement, and a first figure against SC-007.** The phase's verifying run reported
`Tests completed in 479.24s` for 231 assertions over 108 cases, on an otherwise quiet machine.
An earlier run had read 3202.8s, but two other harness runs were competing for the machine
throughout it; that number is discarded rather than averaged, because a contended measurement is
not a slow one, it is not a measurement.

So: roughly 480s against `ritual-checks`'s measured 82.2s / 80.0s — call it six times the current
local gate, or about 4.4s per case, which is what forking a child `pwsh` and building a real git
repository costs. That is the honest number for a developer deciding whether to run the harness
before pushing, and it is offered as phase 3's data point rather than as SC-007 discharged: T047
owns the criterion, and the figure will move as phases 4 and 5 roughly double the case count.
The decision it sets up, which phase 6 should not inherit unexamined, is whether CI runs the full
suite on every push or only the cases a change touches.

### The phase 3 diff review: a regression this phase introduced, caught by reading the diff

Reviewing the working diff for intent before committing — CLAUDE.md step 6 — turned up a defect
in T020a, and it is the most useful thing in this phase's record.

`Get-Territory` sorts a territory entry into one of two fields: `Entries` for a repo-relative
path, `Invalid` for one that is absolute or contains `..`. The inline parser T020a deleted had no
such split — it collected every backtick-wrapped item into one list. So replacing the copy with
the shared function silently moved escaping entries out of the caller's view: after T020a,
`- ``../outside/a3.ps1``` in a Micro spec no longer counted toward the five-file cap and was
reported by **nobody**, while `scope-check.ps1` — the same function, the same block — still
FAILed it.

That is precisely the divergence T020a was written to remove, reappearing one field over. The task
was satisfied (the copy is gone) and the check was worse.

Demonstrated failing first, as D11 requires. Before the fix, `MICRO-009/fail` — a Micro spec whose
Territory escapes the repository — exited 0 and printed:

```text
enforcement-pack: branch '001-thing', diff base '<SHA>', 2 changed file(s)
enforcement-pack: OK
```

The fix reads the field the shared parser fills. Reporting is enough without also counting the
entry against the cap: no spec carrying an invalid entry can reach the cap check green, so the
under-count cannot be spent. The rule is **MICRO-009**; pass and fail differ only in whether the
third entry escapes (D10).

**What this says about how the phase was graded, which is the part worth carrying forward.**
T020a's success criterion was "the inline copy is gone, both graders share the parser". That
criterion was met in full by a change that narrowed the check. A criterion phrased as *the edit I
intend to make* cannot detect a side effect of making it; only a criterion phrased as *what the
check must still refuse* can. The harness did not catch this either — every existing MICRO case
passed throughout, because none of them declared an escaping entry, and a fixture suite only
refuses what someone thought to write down. What caught it was reading the diff and asking what
`Get-Territory` returns that the old loop did not.

Two things follow for the review. This is an argument for the phase-6 direction rather than
against it: T044 makes an uncovered site blocking, and the gap here was an *uncovered site* in a
function the phase had just edited. And it is a caution about the remaining shared-parser work —
T029's `scope-check-repos.ps1` and T034's `territory-check.ps1` both read territory, and the
question to ask of each is not "does it call the shared function" but "which of its fields does
it read, and what happens to the rest".

**Also seen in the diff review, deliberately not changed here.** Two recipe capabilities skip
silently when their target is absent: `uncommittedDelete` deletes only `if (Test-Path)`, and
`truncateBlob` truncates only `if (Test-Path $objectPath)` — which is false whenever git has
packed the object rather than left it loose. Neither can make a case pass wrongly today, because
the expectation still has to match and a no-op produces the wrong output. But it produces it as a
mystifying expectation diff rather than as "this recipe names a path that is not there", and the
diagnosis cost is real: the `truncateBlob` read-only defect above took a `-KeepRepo` session to
find for exactly this reason. T046 is the task that makes a harness failure name what went wrong,
and this is a case for it. Left alone here rather than re-opening a verified suite for a
diagnostics improvement that changes no verdict.

### The phase 3 CI result: green on Windows, red on ubuntu, and why that is the important half

`ritual-checks` passed on `cb871ed`. `enforcement-tests` **failed** — and only on one leg:

```text
enforcement-tests (ubuntu-latest): failure     229 passed, 2 failed
enforcement-tests (windows-latest): success
```

The failure is a `Describe` whose `BeforeAll` threw, so Pester could not even expand the case
name and reported it as the literal template `fixture case <_.Relative>`:

```text
RuntimeException: fixture shallow clone failed for /tmp/kit-fixture-f239c6341c48
  at New-FixtureRepo, tests/enforcement/lib/FixtureRepo.psm1
```

The case is `AMEND-003/fail`, the depth-1 clone, and it is **the only case in the suite that uses
the `shallow` recipe state**. So this is `truncateBlob` all over again, in the same phase: a
capability documented in the recipe shape since phase 1, shipped, never once exercised, and
broken. Two for two on the harness's own untested features.

**The defect.** The clone URI was built by concatenation:

```powershell
$uri = ([uri]("file:///" + ($root -replace '\', '/'))).AbsoluteUri
```

A Windows path carries no leading slash, so three are right. A POSIX path brings its own, making
`file:////tmp/kit-fixture-abc` — and the URI parser reads that run of slashes as an empty
authority followed by `//tmp/...`, then normalises the whole thing to `file://tmp/kit-fixture-abc`,
where **`tmp` is now the host**. git dutifully tried to reach a machine called `tmp`. Measured
rather than reasoned:

```text
C:\Users\x\Temp\kit-fixture-abc  ->  file:///C:/Users/x/Temp/kit-fixture-abc
/tmp/kit-fixture-f239c6341c48    ->  file://tmp/kit-fixture-f239c6341c48
```

What made it durable is that the wrong answer is not malformed. A concatenated URI that means
something else entirely still parses, still looks right in a log, and fails somewhere far away —
in git's resolver, not in the code that built it.

**Fixed** by extracting `ConvertTo-FileUri` and choosing the prefix from the path's shape, with
three self-tests in `Harness.Tests.ps1` asserting **both** platform shapes from either platform,
plus the property that failed — *the first path segment must never become a host*. Asserting the
property rather than the two paths is the point: the reason this survived is that every runner
that executed it only ever saw its own platform's shape.

**The part worth carrying, because it is about how this phase was verified, not about slashes.**
Four independent verifications passed this defect through:

- the local full suite (231 assertions, green),
- CI's `windows-latest` leg (green),
- the fresh-context review's own independently-run 108-case suite (215/215 green),
- and the review's two self-chosen mutation experiments.

All four ran on a platform where the bug is invisible. The review was thorough and its APPROVE was
honestly earned on the evidence available to it; the evidence available to it was single-platform.
**SC-006 is not a portability nicety — on this phase it was the only check that worked.** It is
worth asking of phase 4 and 5 whether any new fixture state is platform-shaped before CI is the
thing that finds out, and worth noting that `shallow` remains a sample of one: a second case using
it would have halved the odds of shipping it untested.

### Merge timing, decided at phase 3 so it is not re-litigated at phases 4 and 5

PR #46 is open and ready for review; it does **not** merge at phase 3, and the reason is law
rather than judgement. `docs/sdlc/branch-strategy.md` sets the merge trigger at *feature
complete* — "Once a feature is complete (gate green + human review approved), push the feature
branch ... Then merge to `main` with `--no-ff`" — and pairs it with "one branch per feature".
Phases are commits on the branch; the branch merges once, at the end. A phase-3 merge is not a
lawful option that the value of the fixtures could outweigh.

The engineering argument points the same way, and is worth writing down because it is the one a
future reader will reach for. Merging now would put into `main` a CI leg named
`enforcement-tests` whose green does not yet mean what the feature intends it to mean: coverage
is reporting-only until T044, so 49 of 94 blocks nothing, and a check that returns without
grading is still silent until `UNGRADED` exists in phase 5. Shipping a green signal that is
weaker than it looks, in the repository whose entire subject is checks that report green having
graded nothing, would be this feature refuting itself in its own delivery.

What is outstanding is therefore owner work, not implementation work: phase 2's re-certification
on `8a0291b` (the recorded certification still names `505f9f1`), phase 3's ci-held certification
on `45b0dfd`, and the human review's half that no machine reaches — whether each amendment's
named approver actually agreed (`06b1b30`, `d7a1939`, `9aa79c0`).

> **Superseded by events, 2026-09-19.** The section above says this branch does not merge at
> phase 3. It did: PR #46 was merged by the owner as `2af8503` (`--no-ff`, merge commit
> preserved), with phases 4–6 unbuilt and the feature branch kept on origin for them. The record
> is superseded rather than corrected in place, on the same reasoning the phase 2 gate record
> used — what was decided when is exactly the thing this feature exists to make unforgeable, and
> a note quietly rewritten to agree with the outcome is worth less than one that shows the
> argument and then shows what happened.

The merge is the owner's to make and is not second-guessed here. Two consequences are recorded
because they are facts about the repository rather than opinions about the decision:

- **`main` now carries a CI leg whose green is weaker than it reads.** `enforcement-tests` passing
  on `main` means 108 fixtures pass. It does not mean the kit is covered — coverage is
  reporting-only until T044 — and it does not mean a member that graded nothing said so, because
  `UNGRADED` does not exist until phase 5. Anyone reading that badge between now and phase 6
  should read it as "the covered rules still behave", nothing wider.
- **Phases 4–6 continue on the same branch**, which is now fully merged into `main` and will run
  ahead of it again at the first phase 4 commit. A second PR carries the rest.

### Phase 3 gate — evidence recorded, owner certification NOT recorded

Phases 1 and 2 each carry a certification line in this file. Phase 3 does not, and that absence is
written down rather than left to be inferred from a merged PR — the feature's own rule that an
absence must be proven rather than assumed applies to its own paperwork first.

The evidence exists and is verifiable:

> **Gate 3 evidence (ci-held, NOT yet certified)**: run
> <https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/35426871546>, conclusion success,
> commit `45b0dfd` (phase 3, T020a + T021–T027). `enforcement-tests` green on both legs on the
> same commit (run 35426871531). **No owner approval is recorded against this triplet.** The
> implementing agent does not supply one; under `ci-held` the certification is the owner's
> recorded approval and nothing else stands in for it — a merge is not a certification, and
> reading one as the other is the substitution this feature exists to prevent.

Also outstanding: no `human-pr-review.md` exists for this feature, so constitution IX's half —
whether each amendment's named approver actually agreed (`06b1b30`, `d7a1939`, `9aa79c0`) — has no
artefact either. Both gaps are the owner's to close and are listed here so they are visible rather
than quiet.

## Phase 4 — the remaining grading scripts under test

### T028: scope-check, and the phase 3 assertion earning its keep on its first outing

Nine rules with both directions each — `SCOPE-004..SCOPE-012` — taking `scope-check.ps1` from
4 of 13 emission sites to 13 of 13. Kit-wide: **58 of 94**, 57 rules, 126 cases.

Expectations were predicted from the source strings again, and **14 of 18 matched first time**.
The three misses were all the same miss: the Micro lane's PASS line carries a provenance suffix,
`(1 file(s), Micro territory from spec.md)`, which my prediction omitted. Script right,
expectation incomplete — corrected in the expectation, and the corrected pair now states something
worth having: the same PASS says *where the territory came from*, which is the one visible
difference between a Micro grading and a Standard one.

**The harness grew a `rename` recipe state, and it had to.** `SCOPE-005` is the rule that a
declaration file renamed **away** is refused — "a delete wearing a costume". A fixture built from
a delete plus an add would have exercised `SCOPE-004`'s arm instead and reported coverage for a
rule it never reached, so the recipe now stages the move with `git mv` and git records `R`. That
is the third time this feature has needed a new recipe state to make a rule provable at all
(`uncommitted`, `merge`, now `rename`), and each time the alternative was a fixture that passes
without testing anything.

**The anchor-ambiguity assertion caught its first real case, in the phase after the one that built
it.** `SCOPE-011`'s natural anchor — `(entries must be repo-relative, no '..')` — is printed
verbatim by *both* the Micro arm (`:170`) and the Standard arm (`:217`), because the Micro line
simply continues into the promotion remediation afterwards. The suite went red on:

```text
SCOPE-011: anchor matches 2 emission site(s) [scope-check.ps1:170, scope-check.ps1:217], declared 1
```

Without that assertion the entry would have marked the Micro site covered by a Standard fixture
that never reaches it — the inventory flattering itself by exactly one site, silently, which is
the failure T023 was written after. The anchor now carries its closing quote so it names `:217`
alone. Two things follow. A rule whose message is a **prefix** of another rule's message needs a
deliberate anchor, and the check is what tells you which ones those are rather than a reading of
the source. And a guard written in one phase found its first defect in the next: worth
remembering when phase 6 weighs whether T044's blocking coverage is worth the friction.

**`SCOPE-009` is the one to read.** T028 names the anti-retroactivity rule and it is the
load-bearing rule in the whole scope check: the declaration is read from the commit's **parent**,
so an amendment only ever governs commits made after it lands. The fail case deletes `tasks.md` in
one commit and **restores it inside the phase commit**, declaring a territory that covers what
that same commit changes — a declaration post-dating the commit it would legalise. The pass case
does the identical restoration in *its own commit first*, which is the remediation the failure
message names. The pair is the difference between "the rule exists" and "the bypass is closed".

### T029: `scope-check-repos.ps1`, and what a coverage number counts as a rule

The task list says "including a code repository on the wrong branch, a missing repository, and a
trunk that is not `main`" — and every one of those three is an **inert** verdict. Nothing fails.
That is what made the idiom question real rather than clerical.

`scope-check-repos.ps1` emits everything through one `Write-Line` wrapper, and the idiom file had
said so since phase 1, with the reason it was left undeclared: *"naming the wrapper alone would
inflate the denominator with non-rules."* The resolution is that the idiom is not the wrapper, it
is **the verdict word the message opens with**. Three registers, and all three are counted:

| register | words | why it is in the denominator |
|---|---|---|
| adverse | `FAIL`, `ERROR`, `WARN` | uncontroversial — the same choice phase 3 made for warnings |
| inert | `n/a`, `not applicable` | **SC-004 and GAP-027 are about precisely these lines** |
| affirmative | `PASS` | a pass over nothing is the failure mode, so the pass is a rule |

Counting the inert register is the decision worth defending. This script's entire risk surface is
*deciding not to grade*: thirteen of its thirty-two lines are a reason to grade nothing, and the
last of them (`n/a (nothing was graded …)`) exists only to catch a run made entirely of reasons.
A denominator that excluded them would have scored this script on the part of it nobody worries
about. Two `Write-Line` calls stay out: the wrapper's own definition, and `remediation —`, which
is a continuation of the FAIL above it rather than a verdict of its own.

The consequence for the case directories is a convention that had to be written down (now in
`rules.json`'s `_comment`): **`fail` is the state in which the rule's condition holds, `pass` is
the nearest state in which it does not** — which coincides with the exit code only for the adverse
rules. `REPOS-011/fail` exits 0, because the rule under test *is* the `n/a`. The alternative was
to name the directions after the exit code and thereby leave the inert verdicts out of the
inventory entirely, which is the same flattery in a different place.

**31 of 32 sites, 62 cases, all 62 expectations right on the first run.** Better than T028's 14 of
18, and for a dull reason: the one miss in T028 was a message suffix I had not transcribed, so
this time every expectation was copied from the source line rather than recalled.

**The uncovered one is a finding, not a gap.** `:199`, `ERROR cannot read the committer date of
$sha7`, is unreachable by construction: it can only fire when `git show -s --format=%cI` fails on
a sha that `rev-parse --verify …^{commit}` has already peeled, and peeling reads the object. No
fixture can produce it, and I have not invented one. **T044 therefore needs a declared category
for a defensive line that no repository state can reach**, or the line has to go — because a
blocking "every site is covered" assertion, run against a site that cannot be covered, leaves the
branch permanently red for being correct. Recorded here so phase 6 decides it deliberately.

A second observation while reading the same function: the fallback territory literal at
`scope-check-repos.ps1:224` is `@{ Found; Duplicate; Entries; Invalid }` — it does not carry the
`NearMiss` key `Get-Territory` returns. `$territory.NearMiss.Count` on that literal is `0` today
only because the script does not `Set-StrictMode`. It is benign now (the path that reaches it
FAILs earlier, and `REPOS-027` covers that path), and it is exactly the kind of latent divergence
between a real parser and a hand-written stand-in that this feature exists to notice. Not fixed —
phase 4's territory is `tests/**`, and changing a grading script here would be the scope creep the
harness is supposed to make unnecessary.

### Two harness capabilities this rule set could not be written without

`nestedRepos` builds an independent git repository **inside** the fixture repository, recursively
through the same builder, after the outer one is finished — so no outer commit can contain it,
which is the actual relationship the nested layout has. Three of this script's rules exist only to
refuse a directory that *looks* nested and is not (not a repository, part of the outer repository,
no such branch), and a recipe state that quietly produced an ordinary subdirectory would have made
all three pass for the wrong reason. So the shape is asserted in `Harness.Tests.ps1` rather than
inferred from a green case, and a nested recipe asking for `shallow` throws instead of being
ignored — T046's rule, applied at the moment it first mattered.

`<DATE>` is a **third** output substitution, and it was forced by a rule that could not otherwise
be pinned at all. The cross-repository anti-retroactivity message quotes the code commit's own
committer date back to the reader, so its output differs in every run. The boundary is the whole
of the design: an ISO-8601 *instant* is run-varying noise; a calendar date a human wrote in a
document is content, and normalising that would quietly stop the Critical-lane approval fixtures
from pinning anything. Both halves are asserted.

### T028 was reported as 13 of 13 and was 13 of 27

Resolving the idiom by verdict word made the same question ask itself of `scope-check.ps1`, whose
declaration T028 had written as `Write-Host "scope-check: FAIL`. That is **one of six verdict
words**. The reporter had been answering "13 of 13 site(s) inventoried" — a perfect score against
a denominator built from the part of the script already covered.

It was not invisible. The recall sweep had been printing two of the missing sites as
`UNCLASSIFIED` in every coverage report since phase 3:

```text
UNCLASSIFIED scope-check.ps1:95   Write-Host "scope-check: ERROR '$Sha' does not resolve to a commit"
UNCLASSIFIED scope-check.ps1:264  Write-Host "scope-check: ERROR cannot determine the current branch …"
```

I read those lines when I wrote T028 and treated them as noise from a deliberately broad net,
which is what the recall pass is documented to produce. The lesson is narrower than "read the
output": **an UNCLASSIFIED line in the script you are currently inventorying is never sweep noise**
— it is either a rule the declaration misses or a line the declaration should say it excludes, and
saying which is part of the task. The other twelve sites were invisible to both passes, because
the sweep looks for `FAIL|ERROR` and eight of them say `PASS`, `WARN` or `not applicable`.

So T028 was re-opened inside the same phase: fourteen rules added (`SCOPE-013`…`SCOPE-026`),
twenty-eight cases, and `scope-check.ps1` now reads **27 of 27** against a denominator that counts
what the script can actually say. Two graders that share `scope-lib.ps1` are now measured by the
same ruler, which they were not an hour ago.

**A fixture that passed for the wrong reason, caught by the expectation and not by the run.**
`SCOPE-020/fail` is the unborn-HEAD case — a repository with no commits, where the branch cannot be
read at all. My first recipe left the harness's default init commit in place and simply omitted the
checkout, and the script answered:

```text
expected: scope-check: ERROR cannot determine the current branch (pass -Branch <NNN-name>)
observed: scope-check: not applicable ('main' is the trunk)
```

Exit 0 either way is not what saved it — `SCOPE-023` is that rule, and it already has its own
fixture. What saved it is that the expectation was **written before the run**: a generated
expectation would have recorded the trunk line as SCOPE-020's truth, and the ERROR site would have
been marked covered by a fixture that never reaches it. That is the third time this feature has
caught the same shape (T020a, `SCOPE-011`, now this), and all three were caught by a different
guard. The recipe now carries the story in its own `description`, where the next reader of that
fixture will meet it.

### T031–T033: three more graders, and a principle that had to cut both ways

`verify-kit.ps1` (**29 of 30**, 52 cases), `build-digests.ps1` (**19 of 19**, 36 new cases beside
phase 2's GAP-025 pair), `roadmap-claim-check.ps1` (**8 of 8**, 16 cases). Every expectation right
on the first run except one, which is in T034 below.

Each of the three needed its declaration widened, and the widening was the work. The principle
settled in T029 — **a site is a condition the script detects, never a line it prints** — decided
all three, and it did not always point the same way:

- `verify-kit.ps1` went from 16 to **30**. `Add-Finding FAIL` alone counted one of the doctor's
  three registers. Its WARNs carry the grandfather posture (an adoption older than the check is
  reported, never failed) and its `ok` findings are the only thing a green run prints — the only
  thing most readers ever see it say. Where an `ok` is simply the other arm of a FAIL, one rule
  owns both sites through `siteCount`, so the fixture pair covers the condition instead of
  duplicating it.
- `build-digests.ps1` went from 10 to **19**, and the nine added matter more than their count.
  Two are the INERT states feature 010 SC-004 exists for — the machinery ships disarmed and arms
  itself the moment a project marks its own law — and four are the generate-mode half of
  conditions whose check-mode half already had a rule, with **deliberately different verdicts**.
  An orphan digest FAILs under `-Check` and is a NOTE while generating; that asymmetry is the
  script's design and was untested until now.
- `doc-lint.ps1` went the other way, 8 to **7**, because three of its `ERROR:` lines are the
  printers for accumulators counted above them. A denominator is only honest if it moves in
  whichever direction the principle sends it, and a narrowing is the harder half to write down —
  it looks like the number being managed. It is recorded in `emission-idioms.json` with the
  reason, beside the widenings, so the two can be judged together.

`roadmap-claim-check.ps1` is the one where the inert half **is** the interesting half. It is the
only kit check whose input is the claim ledger rather than the tree, so it declines for reasons
that are entirely ordinary — no remote, offline, an adopter-authored roadmap in another shape —
and an unspoken exit 0 there reads exactly like a roadmap that is honest. Four n/a states, two
OKs, and both failure arms of GAP-017: a claim no row mentions, and the subtler one, a row that
mentions the claim and still says `idea`. The second is worse, because a human skimming the
roadmap sees the row and believes it, where an absence at least looks like a gap.

### A real defect, found by the fixtures rather than by reading: `verify-kit.ps1` tier names

`VK-011` was written to pin the rule that refuses a tier name which cannot address a rulebook
file. The obvious fixture is `"tiers": ["Backend"]`, because the message promises *lowercase
letters/digits/hyphens*. The doctor passed it:

```text
expected: verify-kit: FAIL record: declared tier 'Backend' is not a valid tier name (lowercase letters/digits/hyphens) …
observed: verify-kit: ok record — adoption record valid — tiers: Backend; gate proven
```

The guard is `if ("$tier" -notmatch '^[a-z][a-z0-9-]*$')`, and **PowerShell's `-match` family is
case-insensitive by default**. Measured, not inferred:

```text
'Backend' -notmatch '^[a-z][a-z0-9-]*$'   ->  False     (accepted)
'Backend' -cnotmatch '^[a-z][a-z0-9-]*$'  ->  True      (refused)
```

So the character class says lowercase and the operator does not enforce it. The one-character fix
is `-cnotmatch`.

**What makes it worth more than a typo is the second half.** Having accepted `Backend`, the next
rule looks for `docs/rulebooks/Backend-rules.md`, and `Test-Path` is case-insensitive on Windows
and case-sensitive on Linux. The same `kit-adoption.json` therefore gets **two different verdicts
from the adoption doctor depending on the platform CI runs on** — OK on a Windows runner, `FAIL
record: declared tier 'Backend' has no instantiated rulebook` on ubuntu. That is SC-006's concern
arriving from a direction the criterion did not anticipate: not the harness disagreeing between
platforms, but a *kit script* doing it, in a project's CI, silently.

It is the third defect this feature has found in the thing it was pointed at, and the first found
by a fixture that simply expected the documented behaviour. The pattern is now familiar enough to
name: **the earlier two were also a mismatch between what a check says it does and what its
implementation actually compares** (GAP-025's code-span comment opener, T020a's territory entries
routed to `Invalid` and read by nobody).

Not fixed here. Phase 4's Territory is `tests/**`, and `scripts/verify-kit.ps1` is not in it —
amending the territory to reach a script mid-phase is the move constitution I's amendment clause
exists to make expensive, and this defect is not urgent enough to spend that. So `VK-011` pins the
rule with a name the check does refuse on both platforms (`back_end`, for its underscore), its
recipe description carries the whole story, and the fix is proposed as a GAP. The coverage number
is unaffected either way: the site is covered; what was wrong was the fixture's belief about which
inputs reach it.

**And the near miss is the lesson.** Had I written `Backend` into the expectation *after* running
the case — the generated-expectation habit this harness refuses on principle (plan D1, FR-006) —
the suite would now contain a green fixture asserting that a tier called `Backend` is valid, and
the defect would have been locked in by the very test written to catch it. Two other cases in this
phase were saved by the same discipline (`SCOPE-020`, `CLAIM-007`); this is the first where the
script was wrong rather than the fixture.

### T034: `territory-check.ps1` is not a gate, and its diagnostics are not its own

The idiom entry had been asking a question since phase 1: *"Reports CLEAN/OVERLAP and may emit no
FAIL rule at all — which of the two is true is itself the question T034 must answer."*

**It emits no FAIL rule at all.** `ritual-checks.ps1` runs six members, seven in an adopted
project, and this is not one of them. Its exit 2 asks two owners to agree a merge order; it does
not refuse a commit. That is team-workflow rule 5 working as designed — *overlap is sequenced,
not forbidden* — and a check that simply refused would push two owners into working around it.

Two findings came out of inventorying it, and neither is fixed here, because phase 4's territory
is `tests/**` and a grading script is not in it.

**It is the only script in scope with no `-Root`.** It finds the repository with `git rev-parse
--show-toplevel` from the *current directory*, so the harness could not aim it at a fixture at
all: passing `-Root` fails to bind (the launcher answers 97), and not passing it would have
pointed the script at the kit checkout the suite runs from — every case green, about the wrong
tree. The harness now carries a `noRoot` flag that runs such a case with its working directory in
the fixture. The accommodation is in `tests/**` where it belongs; the inconsistency is a finding:
eight grading scripts can be aimed at another tree with `-Root ../my-project` and the ninth
cannot, which also means `ritual-checks.ps1` could never have included it.

**Five of its twelve sites cannot be pinned by any expectation, and they are counted anyway.**
Four are `Write-Error` and one is `Write-Warning`. Under `$ErrorActionPreference = 'Stop'`,
`Write-Error` throws before the `exit 1` written beneath it, and what reaches the reader is a
PowerShell **error record** — measured, not assumed:

```text
Write-Error: D:\solutions\agentic-sdlc-kit\scripts\territory-check.ps1:46
Line |
  46 |      Write-Error "Branch '$Branch' is not a numbered feature branch (N …
     |      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | Branch 'main' is not a numbered feature branch (NNN-name) — the territory check applies…
```

That text is the host's, not the kit's: it carries an absolute path from the machine that ran it,
a line number that moves whenever the file is edited, a caret rule, and ANSI colour. No
hand-written expectation can pin it, it differs between hosts and versions, and it is the one
place in the kit where **SC-008 cannot be met** — a reader cannot name the rule from the report,
because the report is not the rule's. Every other grading script writes its own message with
`Write-Host` and chooses its own exit code.

### T035: the aggregator, tested as an aggregator

`ritual-checks.ps1` resolves its members under `-Root` — `$scriptsDir = Join-Path $Root 'scripts'`
— not under its own directory. That is what lets a kit clone run an adopted project's checks, and
it is what makes the wrapper testable: a fixture supplies **stub members**, and the cases assert
the aggregation rather than re-running six checks that have hundreds of cases of their own.

Five sites, ten cases: the member announcement, the per-member verdict, the doctor's n/a line, and
the two run verdicts. The case the task actually asks for is `RIT-004/fail` — **two inert members
and one failing one** — which pins three claims at once: each n/a carries its own reason, lifted
out of the member's own output; an n/a is neither a pass nor a failure; and the count reads
`1 of 6`, not `1 of 4`. An inert member does not mask a failing one, and it does not dilute the
denominator either.

The stubs print ASCII deliberately. The wrapper spawns each member as a *grandchild* process whose
console encoding the harness does not control — `RunChild.ps1` sets UTF-8 one level up, in the
child — so a non-ASCII character in a member's output would be at the mercy of the platform's code
page and the case would pass on one runner and fail on the other. The wrapper's own lines keep
their em dashes and are asserted with them. That is a fixture-design choice, not a defect, and it
is written down because the reasoning is invisible from the fixture.

### T036: the coverage record — 177 of 185, and every one of the eight

**No script is `IDIOM UNDECLARED` any more.** All nine declare how they emit, and every
declaration carries its reasoning.

| script | covered | notes |
|---|---|---|
| `enforcement-pack.ps1` | 44 of 45 | |
| `scope-check.ps1` | 27 of 27 | was reported 13 of 13 against a denominator of 13 |
| `scope-check-repos.ps1` | 31 of 32 | was `IDIOM UNDECLARED` |
| `doc-lint.ps1` | 7 of 7 | denominator narrowed from 8 |
| `verify-kit.ps1` | 29 of 30 | denominator widened from 16 |
| `build-digests.ps1` | 19 of 19 | denominator widened from 10 |
| `roadmap-claim-check.ps1` | 8 of 8 | denominator widened from 2 |
| `territory-check.ps1` | 7 of 12 | was `IDIOM UNDECLARED` |
| `ritual-checks.ps1` | 5 of 5 | was `IDIOM UNDECLARED` |

The eight uncovered sites, each with the reason it is uncovered — because **T044 turns this
report into a blocking assertion, and three of the four reasons below cannot be fixed by writing
a fixture**:

1. `enforcement-pack.ps1:1066` — AmendmentAuthority cannot parse commit metadata for part of a
   range. **Reachable in principle, unreached.** It needs a commit whose `%H`/`%an` metadata is
   unreadable while the range around it is readable; no recipe state produces that today, and
   inventing one is phase 6's call, not phase 4's.
2. `scope-check-repos.ps1:199` — the committer date cannot be read for a sha that
   `rev-parse --verify …^{commit}` has already peeled. **Unreachable by construction**: peeling
   reads the object.
3. `verify-kit.ps1:311` — the catch-all. **Reachable and unpinnable**: its text is
   `$_.Exception.Message`, composed by .NET, which differs between runtimes. Pinning it would make
   the suite's verdict depend on the PowerShell version, which SC-006 forbids.
4. `territory-check.ps1:36, :46, :57, :64` and `:81` — **reachable and unpinnable**, for the
   reason set out under T034: the text belongs to the host, not the kit.

So **T044 needs a declared category for a site no fixture can cover, with its reason recorded in
`rules.json` and checked** — otherwise the blocking assertion leaves the branch permanently red
for being correct, which is GAP-022's disease in a new place. The alternative for cases 3 and 4 is
to change the scripts so they write their own messages and choose their own exit codes, which is a
behaviour change and belongs in a feature of its own. Recorded here so phase 6 chooses
deliberately rather than discovering it.

**The ten unclassified candidates are now all accounted for**, which is the number the two-pass
design says to watch rather than the percentage. Every one is a printer the declaration excludes
on purpose:

- `build-digests.ps1:241, :242, :251, :252` — the two issue loops and their two RESULT lines.
- `doc-lint.ps1:233, :247` — the manifest-completeness and unresolved-path headers, which print
  `$manifestErrors` and `$broken`.
- `enforcement-pack.ps1:1231` — the failure header printing `$failures`.
- `roadmap-claim-check.ps1:124` — the FAIL count printing `$failures`.
- `verify-kit.ps1:320, :326` — the report loop's FAIL arm and the run summary.

None is a missed rule. The recall sweep is doing exactly what it was built to do: it looks for
anything FAIL-shaped, it finds the printers, and the declaration has to say in writing why each
one is not a condition. That is the difference between a number nobody questions and a number
somebody has answered for.
