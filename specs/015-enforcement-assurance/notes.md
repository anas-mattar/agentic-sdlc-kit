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

### Phase 4 remediation: the harness was reading a stream the script never printed

Phase 4 was committed at `8778c06` after 740 local cases passed, and CI failed it: **724 passed,
16 failed on `ubuntu-latest`, 740 passed on `windows-latest`** (run 35437579942). Both legs ran
Pester 5.9.0 and pwsh 7.6.5 — same versions, same harness, same fixtures.

Every failure was one shape: a blank line the expectation contains and the observed output does
not. Sixteen cases in the suite have an interior blank line in `expected.txt`; sixteen failed;
they are the same sixteen. Their only source of a blank line is `Write-Host ''`, at
`ritual-checks.ps1:100` and `territory-check.ps1:112` and `:116`.

**That reasoning was sound and its conclusion was wrong.** The correlation was real — it just
identified the symptom class, not the layer. I concluded that `Write-Host ''` behaves differently
on Linux, obtained an owner-approved Territory amendment to reach the two scripts (`74f690e`),
changed all three sites to `Write-Host ([Environment]::NewLine) -NoNewline`, confirmed the bytes
were unchanged on Windows, and confirmed the sixteen cases still passed there.

**Every one of those confirmations was run on the platform where there was no bug.** The fix was a
no-op on Windows by construction — that is *why* the expectations still matched — so a green
Windows run said nothing whatsoever about whether it worked. It would have gone to CI and failed
again, and the second failure would have looked exactly like the first.

#### What settled it

A Linux `pwsh` — `ubuntu:24.04` plus the 7.6.5 tarball, the runtime CI actually uses. Four ways of
emitting a blank line, run as a script whose stdout is redirected by the shell:

```text
Write-Host ''                                    A-before<LF><LF>A-after
Write-Host ([Environment]::NewLine) -NoNewline   B-before<LF><LF>B-after
Write-Host "`n" -NoNewline                       C-before<LF><LF>C-after
Write-Output ''                                  D-before<LF><LF>D-after
```

**All four work on Linux. `Write-Host ''` was never the defect, and the kit scripts were innocent
the whole time.** Running the real failing case through `Invoke-FixtureCase` in that container
reproduced the failure with the *fixed* script in place — which is how the wrong fix was caught
before it was pushed rather than after.

Isolating each stage of the harness's own path found it:

```text
ConvertTo-NormalisedOutput on "a\n\nb\n"          a<LF><LF>b        blank preserved
Start-Process -RedirectStandardOutput             a<LF>b            BLANK GONE
Process + ReadToEndAsync                          a<LF><LF>b        blank preserved
```

**`Start-Process -RedirectStandardOutput` drops empty lines on Linux.** The harness was comparing
its hand-written expectation against a stream the script under test never printed. The expectation
side was read straight off disk and kept its blank lines; the observed side was mangled in
transit. The defect was in `tests/enforcement/lib/Harness.psm1` — inside phase 4's *original*
Territory — and the amendment reaching into `scripts/` was never needed.

`Invoke-FixtureCase` now starts the child through `System.Diagnostics.Process` and reads both
streams with `ReadToEndAsync` before waiting. Verified against ubuntu 24.04 + pwsh 7.6.5 with the
kit scripts reverted to their original `Write-Host ''`:

```text
territory-check/TERR-005/pass   OutputMatch True   ExitMatch True (2)
territory-check/TERR-004/fail   OutputMatch True   ExitMatch True (2)
ritual-checks/RIT-001/pass      OutputMatch True   ExitMatch True (0)
ritual-checks/RIT-004/fail      OutputMatch True   ExitMatch True (1)
```

`ConvertTo-ProcessArgument` went with it. It existed because `Start-Process` joins an argument
array with spaces and quotes nothing — the phase 2 review's F1 — and
`ProcessStartInfo.ArgumentList` passes each element as one argument, so the escaping stops being
ours to get wrong. Its two self-tests still guard the behaviour end to end.

#### Why this one is worse than the bug it was mistaken for

A script that prints different text on two platforms is a defect in that script. **A harness that
silently rewrites the output it is grading is a defect in the instrument**, and it had been there
since phase 1, on every Linux run, for every case. Here it produced false REDs, which is the
survivable direction — the expectation kept its blank lines and the observed lost them, so the
comparison failed loudly. But the instrument was not measuring what it claimed to measure, which
is the precise failure mode this feature exists to find in the kit's own checks. It was found in
the feature that grades the graders, by CI, on the fourth of six phases.

The self-test added for this drives `Invoke-FixtureCase` against a synthetic kit root rather than
building its own process. The first attempt re-implemented the launch inside the test, which would
have passed while the harness stayed broken — a check that sees part of what it claims to see, the
shape the phase 1 review named F1 and the shape T020a fixed in the Micro lane. It is easy to write
by accident, and this file now has three instances of it on record.

#### The amendment was unnecessary, and stays on the record

`74f690e` widened phase 4's Territory to `scripts/ritual-checks.ps1` and
`scripts/territory-check.ps1` on the strength of a diagnosis that turned out to be wrong. Both
scripts are reverted and neither is touched by this phase. The amendment is not being rewritten:
what was approved, when, and on what evidence is exactly the kind of thing this kit refuses to
tidy away after the fact — the same reasoning that kept both phase 2 gate records rather than
editing the superseded one. Narrowing it back is an owner's decision, not an implementer's.

### T036b: F1 was right, and it was bigger than its example

The phase 4 fresh-context review's one BLOCKING finding: `doc-lint.ps1:236` — the manifest sweep
declining in an adopted project — is a condition the script detects on its own `.kit-version`
branch at `:100`, not a printer of any accumulator. Verified independently before acting: none of
`doc-lint`'s four accumulators matches it, and none of the seven `DOC-*` anchors owns it.

It is also **invisible to both passes at once**. The recall sweep's patterns require a literal
`FAIL|ERROR` inside the string, so an inert verdict can never surface even as `UNCLASSIFIED`. The
precise pass did not declare it and the recall pass structurally could not see it. `doc-lint`
therefore reported **7 of 7** — a perfect score against a denominator built from the part already
covered, which is the exact sentence this feature's own phase 4 commit message wrote about T028's
old `13 of 13`. I applied the tri-register principle to four scripts and then missed the inert
register in the fifth: the one script where the denominator was narrowed.

So the fix began by asking whether the hole was bigger than its example. It was. Sweeping every
`Write-Host` line in all nine scripts against that script's own declaration turned up **nine
unowned conditions in three scripts**:

| script | line | register | what it is |
|---|---|---|---|
| `doc-lint.ps1` | `:236` | inert | the manifest sweep declines (F1 itself) |
| `doc-lint.ps1` | `:238` | affirmative | the sweep reports what it classified |
| `doc-lint.ps1` | `:252` | affirmative | the OK run verdict |
| `verify-kit.ps1` | `:330` | affirmative | the doctor's OK run verdict |
| `enforcement-pack.ps1` | `:1058` | inert | `AmendmentAuthority: no commits in range — nothing to grade` |
| `enforcement-pack.ps1` | `:1183` | affirmative | `AmendmentAuthority: graded N of M` |
| `enforcement-pack.ps1` | `:1209` | inert | the trunk is not graded |
| `enforcement-pack.ps1` | `:1224` | inert | the lightweight `docs/` lane is not graded |
| `enforcement-pack.ps1` | `:1235` | affirmative | `enforcement-pack: OK` |

`:1058` deserves its own sentence. **The check that grades amendments can decline to grade, print
`nothing to grade`, and nothing counted that as a condition** — GAP-027's own shape, sitting
inside the enforcement pack, in the register this feature widened four other declarations to
catch.

The principle that settles which of these count is the one already written in
`emission-idioms.json`: an `OK` line prints no accumulator — it asserts that the conditions above
it did not occur, and on a green run it is the entire output a reader sees. A `FAIL (N issue(s))`
line prints a count the accumulator already holds. So the affirmative run verdicts come in and
their FAIL counterparts stay out. The asymmetry looks odd written down; it is the same call
`roadmap-claim-check.ps1` already made in T033, and the alternative — counting both — would be
counting the printer a second time.

**The declaration was widened by all nine. Only four were covered.**

```text
doc-lint.ps1             7 of 7    ->  10 of 10     (denominator 7 -> 10)
verify-kit.ps1          29 of 30   ->  30 of 31
enforcement-pack.ps1    44 of 45   ->  44 of 50     (five declared, none covered)
--------------------------------------------------------------------------
kit total              177 of 185  -> 181 of 194      95.7%  ->  93.3%
```

The headline number went **down**, and that is the point. `enforcement-pack.ps1` is phase 3's
script and phase 3 is merged; writing ten fixture cases for it inside a phase 4 remediation would
be re-opening a closed phase, and the five conditions are real whether or not this branch covers
them. Declaring them lowers the percentage honestly and leaves a debt with a name on it — an
uncovered site is visible to T044 and to every future reader; an undeclared one is not a debt at
all. That is the same ruler as the T028 widening and the `doc-lint` narrowing, pointed in whatever
direction it sends the number.

Three rules and six cases close the four that belong to phase 4's own scripts. `DOC-008` owns the
two manifest arms through `siteCount: 2`, the idiom established in T031 so that a pair covers a
condition rather than duplicating it. `DOC-009` and `VK-027` own the two run verdicts, and both
are the first rules in the suite whose **exit code inverts against the direction name** — `fail`
exits 0 and `pass` exits 1 — because for an affirmative rule the state in which the condition
holds is the healthy one. The direction convention warned that it coincides with the exit code
only for adverse rules; these two are where that stops being a footnote.

Left open, deliberately, for phase 6 to decide rather than discover:

- The five declared-uncovered `enforcement-pack.ps1` sites. They join the eight already listed
  under T036, so **T044 now faces thirteen uncovered sites, of which five are unreachable by any
  fixture** and the remaining eight are ordinary work.
- The recall sweep's structural blindness. Its patterns want `FAIL|ERROR` inside the string, so
  the entire inert and affirmative registers are invisible to it — the net that exists to audit a
  short declaration cannot see the register this phase spent most of its effort on. Every hole
  found here was found by reading, not by the sweep. Widening it is `Coverage.Tests.ps1` work and
  belongs with T044/T045, where exemptions are declared anyway.

### The T036a fix carried its own defect, and the first guard for it was worthless

Running the full suite before committing the remediation: **752 passed, 1 failed** —
`doc-lint/DOC-008/fail`, on the em dash.

```text
expected  doc-lint: manifest — completeness sweep skipped ...   U+2014
observed  doc-lint: manifest ΓÇö completeness sweep skipped ...   915,199,246
```

`915,199,246` is the UTF-8 encoding of an em dash, `E2 80 94`, decoded one byte at a time as
CP437. **The T036a fix introduced this.** `Start-Process -RedirectStandardOutput <file>` wrote
bytes to disk and `[IO.File]::ReadAllText` decoded them as UTF-8; `System.Diagnostics.Process`
with `StandardOutputEncoding` left unset decodes the child with `[Console]::OutputEncoding`
instead — the OEM codepage on Windows. Every message this kit prints contains an em dash.

Both streams are now pinned to UTF-8 on the `ProcessStartInfo`, which is not a choice imposed on
the child but the encoding PowerShell 7 already writes when redirected.

#### It did not fail every time, which is the part that matters

`DOC-008/pass` **passed under Pester and failed when driven directly**, minutes apart, with no
edit in between. `DOC-009/pass` and `VK-027/pass` carry the same em dash and never failed at all.

The trigger is the *parent's* console encoding, not the case. `Run-Tests.ps1` leaves it at
`ibm437`; a bare `Invoke-Pester` normalises it for the duration of its own run. So the defect was
present on every case, all the time, and surfaced only through whichever door the suite was
entered by. `752 passed, 1 failed` was never a stable number, and a green CI leg would not have
meant the bug was gone — it would have meant that runner happened to start in UTF-8.

That is the same lesson as the blank line it was introduced while fixing, one layer down. The
blank-line bug was platform-dependent and at least *consistently* platform-dependent. This one
depended on the ambient state of the process that launched the grader.

#### The first version of the guard test proved nothing

A self-test was added that emits an em dash through `Invoke-FixtureCase` and asserts it survives.
Reverting the fix underneath it:

```text
pin in place      passed=19  failed=0
pin removed       passed=19  failed=0     <- the mutation proof does not fail
```

It inherited the ambient encoding from Pester, which is the one condition under which there is no
bug. **It asserted a property in the only environment where the property could not break**, and
it was written in the same sitting as the notes entry above about two prior instances of exactly
this shape. Writing the lesson down does not confer immunity from it.

The test now sets `[Console]::OutputEncoding` to `iso-8859-1` itself and restores it in a
`finally`. Latin-1 rather than CP437 because both mangle the bytes and only Latin-1 is built into
.NET on Linux, so the guard is real on both CI legs:

```text
pin in place      passed=19  failed=0
pin removed       passed=18  failed=1     <- fails for the reason it exists
```

#### There was already a test for this, and it was looking at the wrong object

`Harness.Tests.ps1` has carried an `It` called **'carries a non-ASCII character through
unchanged'** since phase 2, whose comment reads *"The reason this launcher exists"*. It was green
throughout. It drives `Invoke-Launcher` — a helper defined inside the test file — and not the
launch `Invoke-FixtureCase` actually performs, so when that launch changed the test had no
opinion about it.

This is the fourth instance on this record of a check that sees part of what it claims to see,
and the second in this phase. The pattern is now specific enough to name: **a self-test that
builds its own copy of the thing under test measures the copy.** T020a was this in the Micro
lane, the first blank-line self-test was this, and this one was this while sitting eight lines
above a comment explaining the danger. `Coverage.Tests.ps1` counts whether a rule has a case; it
cannot count whether the case is pointed at the real path. That is a T044 question and it is now
on the record as one.

### Phase 4 review round 2: the fixtures broke the rule the phase was written to defend

Verdict **REQUEST CHANGES**, one BLOCKING (F3), three CONFIRM, one DOC DRIFT, five MINOR.
`ai-code-review-phase-4-round-2.md`.

The reviewer re-derived the phase's headline numbers instead of reading them: its own sweep of all
nine scripts found **no tenth unowned condition** (nine is right), `181 of 194` reproduced exactly,
and `git diff origin/main..HEAD -- scripts/` is empty branch-wide — which proves the revised
blank-line diagnosis more directly than the container measurement did, because it shows the two
scripts are byte-identical to `main` while the ubuntu leg is green.

**F3, and it is the embarrassing one.** Plan D10: a rule whose pass and fail fixtures do not share
a recipe must state why. `VK-027/pass` said *"Differs only in the condition under test (plan
D10)"* and differed in two places — the `TODO(VERSION)` markers that are the condition, and
`"begins with a spec."` against `"begins with a specification."`, which is nothing. `DOC-009`
carried an unstated `kit-manifest.json` reshuffle beside its unresolvable reference. Both extra
halves were inert, which is worse rather than better: an inert difference is one a future reader
must prove inert before trusting the pair.

Round 1 raised this class twice — its F2 (D10's escape clause is used but never written down) and
its F8 (descriptions in the diff are inaccurate). Neither original was corrected, and this phase
added two more instances **in the same commit whose notes argue at length that a record nobody
checks drifts**. The fixtures for the feature that grades the graders were themselves ungraded on
the one property the plan asks of them.

Fixed by alignment rather than by rewording the claim: each pair now differs in exactly one line.
`DOC-008` was checked at the same time and was already clean. No expectation changed — both
`DOC-009` directions were already reporting `18 shipped file(s) classified`, so the manifest was
provably not load-bearing, and the manifest copied into the pass case is the one the fail case
already runs on the ubuntu leg.

**Left open for the owner and for phase 6:**

- **F2 — the T036b sweep was one-directional.** It asked what the declaration misses and never
  what it wrongly counts. `ritual-checks.ps1` still counts a per-member banner and a
  `RESULT FAIL (N of M)` summary as sites — the two categories this phase's own reasoning excludes
  everywhere else — so it reports a flattering `5 of 5`. The asymmetry is consistent across the
  three scripts this phase touched and contradicted by a fourth it did not.
- **F1 — the handover to T044 understates the problem.** It says five of thirteen uncovered sites
  are unreachable and eight are ordinary work; this same file, 180 lines earlier, classifies seven
  of those eight as unreachable or unpinnable. The five new `enforcement-pack` sites also have no
  task assigned.
- **F7 — the T036a amendment is well-formed and against the grain.** Constitution I permits it and
  the record satisfies the check, but D3c (`specs/014-amendment-authority/plan.md:194`) and
  `adoption/updating.md:329` — text this kit ships to adopters, quoted by
  `enforcement-pack.ps1:1162` as the remedy — both say to leave the task as agreed and record what
  was done here. This phase applied that convention to the Territory rationale and the opposite one
  to the task text ten lines below, with no rule stated to distinguish them.

## Phase 5 — a run that graded nothing says so

### T037: the fail-open, demonstrated three ways before anything was fixed (D11)

GAP-027 in one line: **`Invoke-ReviewProvenanceCheck` opens with `if (-not $Base) { return }`**
(`enforcement-pack.ps1:595`). The machine half of gate 5 returns before listing a single
candidate, and the run prints `OK`.

Each fixture therefore carries a review file that *would* fail — no `## Reviewer Provenance`
section, no attestation, and `**Reviewer**: the implementer, same context`. That is PROV-002,
PROV-004 and PROV-005 at once. The violation is present, detectable, and never looked at. A
fixture that merely lacked a base would prove the branch was quiet; this one proves it was wrong.

The lane matters. On an `NNN-*` branch `AmendmentAuthority` now fails loudly for want of a base
(feature 014 phase 5, and case AMEND-003), so the run is already red. The fail-open survives on
the lanes where that check does not apply — `docs/` and `fix/` — which is where it is least
likely to be noticed.

| case | state | cause of the empty base |
|---|---|---|
| `GAP27-001` | depth-1 clone | history is not present |
| `GAP27-002` | trunk named `trunk` | neither `origin/main` nor `main` resolves |
| `GAP27-003` | parent commit truncated | the walk to the base cannot be completed |

All three print exactly this today:

```text
enforcement-pack: branch 'docs/thing', diff base '', 0 changed file(s)
enforcement-pack: 'docs/thing' is the lightweight docs/ lane — review-provenance is the only scripted check that applies
WARNING: enforcement-pack: no integration branch to diff against, so nothing on 'docs/thing' was compared — …
enforcement-pack: OK
```

**`enforcement-pack: OK`, exit 0.** The warning above it is not nothing — feature 014 phase 5 put
it there deliberately, and it says in plain words that nothing was compared. That is the whole
distinction this phase turns on: the condition is already **audible in the body** and still
**clean in the verdict** (D5). A reader skimming for the verdict, a `grep` for the last line, and
a status badge all see a pass. The fix is not to say more; it is to stop the last line lying.

`GAP27-003` needed a new fixture state. `truncateBlob` corrupts the object store copy of a
*file*, which is what a check that reads history out of a path meets (AMEND-005). A check that
walks the commit graph never touches a blob, so `truncateCommit` truncates a *commit* object
named by a rev — still referenced, still resolving by name, unreadable. Plan D12 anticipated
exactly this ("deliberately corrupt objects as first-class fixture states"). It refuses rather
than silently skipping when the named object is packed, for the same reason the nested `shallow`
recipe refuses: a corruption that quietly does not happen gives a case that passes for the wrong
reason.

### T038-T043: the word, the emitters, and the aggregator

**T038 — the vocabulary lives in `scripts/ritual-checks.ps1`'s header.** Not in `docs/`: phase 5's
Territory is `tests/**` plus the nine scripts, and the documents that carry this outward to
adopters and reviewers are phase 6's T049/T050/T051. The entry point an adopted project actually
runs is the honest place for the definition in the meantime, and FR-012 names it. Six words —
`OK`, `FAIL`, `WARN`, `N/A`, `UNGRADED`, `PENDING` — with `PENDING` written down as reserved,
emitted by nothing, and belonging to GAP-022 (D7), including a line telling the next
implementer that emitting it means the rule needs its own feature first.

**T039 — four emitters, not one.** The task names `Invoke-ReviewProvenanceCheck` as the start and
it is the canonical one, but three others reach the same state on a null base:

| member | what stopped |
|---|---|
| `ReviewProvenance` | no review file inspected — the machine half of gate 5 |
| `MicroLane` | the phase walk enforcing "exactly one phase" and the line bound |
| `PhaseSizeWarning` | no commit measured against the guideline |
| `LiteAndAbuse` | **graded an EMPTY file list** |

The last one is the odd entry and belongs in. It does not decline — it grades, and grades
nothing, which passes the way an empty accusation is never proved. The pack's own comment said so
before this phase did: *"On a baseless clone a 'fix/' branch touching anything at all therefore
went green."* A vacuous grade reaches the same wrong verdict as a skipped one.

`AmendmentAuthority` is deliberately not on the list. It already **fails** for want of a base —
feature 014 paid for that in review rounds — and downgrading it to `UNGRADED` would be a
regression dressed as consistency.

**T040 — the aggregator reuses the `n/a` idiom rather than inventing an exit code.** Members
already signal `n/a` by printing a line the wrapper reads back; `UNGRADED` is read the same way,
anchored on `^<member>: UNGRADED` so a sentence merely containing the word cannot be mistaken for
a verdict. The alternative — a dedicated exit code — would itself have been the exit-code change
FR-011 says must be stated explicitly and separately. There is not one. Precedence in the verdict
block is `UNGRADED` > `n/a` > `OK`: a member that formed no opinion must not be summarised by
whichever other word also fits.

**T041 — the exit code is held, and both directions of every case assert it.** `GAP27-001` and
`RIT-006` exit **0** while reporting `UNGRADED`; `RIT-006`'s pass direction exits 0 reporting
`OK`. The two states are distinguished by the verdict alone, which is the whole of D6. On
`GAP27-003` and `GAP27-004` the run both **fails and is ungraded** — `AmendmentAuthority` fails
for want of a base while three other members form no opinion — which is why the runner prints
`UNGRADED:` lines independently of the verdict word rather than as an alternative to it.

**T042 — nothing else moved.** The new `ritual-checks` run against the kit and all three adopted
projects:

```text
kit               doc-lint OK  enforcement-pack OK  scope-check OK  scope-repos n/a
                  digests OK  roadmap-claims OK  verify-kit n/a        RESULT OK
fitforge          every member OK, verify-kit OK                       RESULT OK
flowboard         every member OK, verify-kit OK                       RESULT OK
expense-tracker   roadmap-claims n/a (no origin remote), rest OK       RESULT OK
```

Member names unchanged, verdicts unchanged, exit codes unchanged (FR-012, SC-005).
expense-tracker's pre-existing `n/a` is worth its own line: it proves the older idiom still
resolves correctly now that a second word competes for the same slot.

**T043 — coverage.** Four new rules for the four emitters plus `RIT-006` for the aggregator
verdict. `enforcement-pack` 50 → 54 declared, 48 covered; `ritual-checks` 5 → 6 declared and
6 covered. Kit total **181 of 194 → 186 of 199**.

The two lines that PRINT the new accumulator — the `UNGRADED: <reason>` loop and the
`UNGRADED (N check(s) formed no opinion)` verdict — stay out of the denominator, by the rule this
file has applied throughout: they print a count the accumulator already holds, exactly as the
`FAIL` pair does. Worth stating the consequence plainly, because it reads oddly: the run verdict
`OK` is a site and the run verdict `UNGRADED` is not. `OK` asserts that conditions did not occur;
`UNGRADED` counts ones that did.

Each `GAP27-*` pair differs in exactly one thing — `shallow`, the trunk's name, or
`truncateCommit` — with the same bad review file on both sides, so the pass direction reports the
violation the fail direction let through. After round 2's F3 that was not a property to leave to
chance, and `GAP27-002`'s two-line trunk rename is stated in its own description rather than
waved past.

### Three existing cases changed, and one of them was written to

The full suite came back **771 passed, 3 failed** — `AMEND-003/fail`, `AMEND-004/fail` and
`PACK-001/fail`, all pinning output this phase deliberately changes.

`AMEND-003` and `AMEND-004` keep the same `FAIL` and the same exit code; they now carry the two
`UNGRADED:` lines naming what *else* did not grade beside the failure. That is the combined state
the runner prints ungraded lines independently of the verdict to support, and it is worth seeing
it arrive in cases written before the state existed.

`PACK-001` is the one that matters. Its recipe description, written in **phase 3**, reads:

> A Lite-lane branch on a clone with no integration branch. Every member either graded an empty
> file list or returned without grading, and the exit code is 0 — which is GAP-027 exactly. The
> run says so in the log body today; **phase 5 gives it a verdict state, and this case is what
> will show the difference.**

It now does, and the diff is the whole feature in three lines:

```text
-  enforcement-pack: OK
+  UNGRADED: LiteAndAbuse: … graded an EMPTY file list on 'fix/thing' …
+  UNGRADED: ReviewProvenance: … no review file on 'fix/thing' was inspected …
+  enforcement-pack: UNGRADED (2 check(s) formed no opinion)
```

Exit code 0 before and after, asserted by the case in both states. The description is left
exactly as phase 3 wrote it rather than updated to the past tense: a prediction that landed is
worth more on the record than a tidy sentence.

A fourth thing did not happen and is worth saying: no case outside `enforcement-pack` moved. The
other eight scripts emit no `UNGRADED` and their expectations are untouched, which is the
narrowest form of the FR-012 claim — the harness is additive, and here it is additive in one
script only.

**Correction, written after the phase-5 review.** The paragraph above is wrong in the way it
frames itself. "No case outside `enforcement-pack` moved" was true and was not restraint: two
of those eight scripts carried the identical GAP-027 fail-open, and not moving them left the
feature's own requirement unmet in the member a reader is most likely to run. The review caught
it as F1. What the paragraph should have said is recorded in the section below.

---

## Phase 5 review round 1 — F1 and F2

`ai-code-review-phase-5.md`, fresh context, **REQUEST CHANGES**: 2 BLOCKING, 1 CONFIRM,
4 MINOR, 1 ACCEPTED, 1 DOC DRIFT. Both blocking findings were reproduced before anything was
changed, and both were about the same thing from opposite ends — the phase closed GAP-027 in
one script and then wrote a definition claiming the whole kit conformed.

### F1 — the fail-open survived in two members inside this phase's own Territory

The reviewer built a two-commit repository, took a `--depth 1` clone of it, copied `scripts/`
in, and ran the wrapper:

```text
=== ritual-checks: scope-check ===
scope-check: WARN could not resolve a merge base with main — nothing checked
…
ritual-checks: scope-check      OK
```

That is FR-010 verbatim — *a member that cannot grade MUST NOT report the state that a fully
graded pass reports, in the verdict block* — unmet, on the same depth-1 clone `GAP27-001` and
`GAP27-004` build two directories away. `scope-check.ps1` and `scope-check-repos.ps1` are both
in phase 5's declared Territory, so this was not out of reach; it was out of mind.

Three shapes were involved, and the sweep found more than the three sites the review named:

| Site | Was | Is |
|---|---|---|
| `scope-check` detached HEAD | `WARN detached HEAD` | `UNGRADED detached HEAD` |
| `scope-check` no merge base | `WARN … nothing checked` | `UNGRADED … nothing checked` |
| `scope-check` empty range | `PASS (no commits since merge base)` | `UNGRADED (… no commit was examined)` |
| `scope-check` every commit skipped | *(nothing — exit 0)* | `UNGRADED no commit on '<branch>' was graded` |
| `scope-check` trunk / lane / not-numbered | `not applicable (…)` | `n/a (…)` |
| `scope-repos` detached HEAD | `WARN detached HEAD` | `UNGRADED detached HEAD` |
| `scope-repos` no merge base | `WARN … NOTHING WAS GRADED` | `UNGRADED … NOTHING WAS GRADED` |
| `scope-repos` empty range | `PASS (no commits since merge base)` | `UNGRADED (… no commit was examined)` |
| `scope-repos` graded nothing | `n/a (nothing was graded …)` | `UNGRADED (nothing was graded …)` |
| `scope-repos` trunk / lane / not-numbered | `not applicable (…)` | `n/a (…)` |

Four of these deserve a sentence each.

**The fourth row is the one the review did not ask for.** `Invoke-ScopeCheck` returns a skip for
a merge commit, for a commit carrying no `phase N` token, and for a pre-006 tree with no
`tasks.md`. A branch made only of those exits 0 having graded nothing and printed no run-level
line at all, so the wrapper said `OK` with nothing to lift. Fixing only the three named sites
would have left the general case open and reproduced, in miniature, exactly the defect F1 is
about. It is counted the way `scope-check-repos.ps1` has counted since feature 012 (`$graded`):
the pattern was already in the kit, in the sibling script, and was not copied across when it
should have been.

**`scope-repos` was reporting an ungraded run as `n/a`.** That shaping was deliberate in feature
012 — phase 1 review F6 asked for it, so the wrapper would lift *some* reason rather than print
a bare `OK`, and with five words available `n/a` was the closest. It is still the wrong one.
A declared code repository *does* apply — declaring it is what that means — so the claim
"nothing was graded" is `UNGRADED`, and US3 acceptance scenario 3 says in terms that the two
must not be blurred. The right instinct reached for the only word there was; phase 5 is what
gave it the right one.

**The `not applicable` → `n/a` respelling is not cosmetic.** The wrapper lifts `^<member>: n/a`.
Spelled out, those three states — trunk, `fix/` lane, unnumbered branch — were correct claims
that no reader of the verdict block ever saw, because the wrapper rendered every one of them
as `OK`. This is the second half of F2's second bullet.

**The per-commit and per-repository lines were left alone.** `not applicable (commit <sha> is a
merge commit)` still says that. The rule adopted here and written into the header is that a
member's *verdict line* — its last — carries the vocabulary, and the lines above it are prose
that explains. Without that line the alternative was to respell forty detail messages, which
buys nothing a reader needs.

### F2 — the definition asserted conformance that did not exist

The header said *"Every grading script in this kit reports in these six words and no others"*
and *"FAIL … is the only state that exits 1"*. Both checkable, both false: `doc-lint.ps1` prints
`ERROR:` and `INFO:` and exits 1 at `:251` without printing any verdict word at all, and four
other scripts emit `ERROR` too. Phase 6 was going to carry that sentence to three adopted
projects.

Two changes, in opposite directions:

- **Narrow the claim to what it is about.** The vocabulary governs the verdict line,
  `<member>: <WORD> [reason]`. Detail lines are prose. This is stated in the header rather than
  left to be inferred, because inferring it is what produced the overclaim.
- **Make the claim true where it was cheap to.** `doc-lint.ps1` now prints
  `doc-lint: FAIL (N issue(s) — see the ERROR block(s) above)` before `exit 1`. It was the only
  member that exited 1 having printed no verdict at all: a reader looking for the answer found
  that the last line was a detail too. Eight expectations gained that line; not one exit code
  moved.

What is left is named in the header under KNOWN DIVERGENCES rather than implied — `update-kit.ps1`
is an installer, not a member of this wrapper, and is outside this feature's Territory; the
detail lines are prose by the rule above. **No task claims further reconciliation and none is
owed by this feature.** That sentence is in the header too, because an unstated intention is how
F1 happened.

### What proves it

- `SCOPE-027` — the general all-skips case (new rule). The pair differs in one commit's
  **subject line**, `work: the thing` against `phase 1: the thing`, and in nothing else (D10).
- `RIT-007` — the aggregator lifts the word for `scope-check`, not only for the first member
  that could reach the state (new rule). `$ungradedCapableMembers` is an allow-list, so the
  mechanism `RIT-006` proves is silently inert for any member left out of it — which is
  precisely how this defect shipped. **Mutation-proved**: with `'scope-check'` removed from that
  list the case fails; with it present, green.
- Twenty existing expectations changed word and nothing else, and seven inventory anchors moved
  with them (`SCOPE-021`, `SCOPE-025`, `SCOPE-026`, `REPOS-007`, `REPOS-015`, `REPOS-016`,
  `REPOS-032`). Their previous revisions are the before-state, which is this conversion's D11
  record: the harness said `WARN`/`PASS`/`n/a` in git and says `UNGRADED` now.

The expectations were **not** regenerated from what the scripts printed. Each substitution was
written a second time, by hand, and the suite is what proves the two agree. Regenerating would
have made expectation and code agree by construction — the instrument grading its own output,
which is the defect this feature has already hit twice (T036a, and the guard test for it).

### Doc drift this remediation creates, and does not fix

Three prose lines enumerate the lawful non-blocking verdicts and now omit the one they are
most likely to meet:

- `docs/sdlc/definition-of-done.md:103` — "`n/a`, `not applicable` and `WARN` are lawful
  non-blocking verdicts of the cross-repo check"
- `docs/sdlc/review-process.md:59` — the same list, same sentence shape
- `.github/workflows/code-repo-scope-check.yml.template:37` — "The job PASSES WITHOUT
  GRADING — WARN, n/a or 'not applicable' on every line"

None of the three is machine-read: no workflow greps a verdict word, and the template line is
a comment addressed to a human wiring up a code repository. They are incomplete, not wrong.

They are also outside phase 5's **Territory**, which is `tests/**` and the nine grading
scripts. Editing them in this commit would fail `scope-check.ps1` — the check this very
commit is amending — and widening the Territory to reach them is an amendment the implementing
agent may not approve for itself (constitution I). So this is recorded rather than done. It
needs an owner decision: an approved Territory amendment, or a phase-6 task, or a follow-up.
Naming it here is the point; F1 is what happens when the same situation is met with silence.

### What flow-down will actually look like, measured

T042 ran `ritual-checks.ps1 -Root <project>` against the three adopted projects and recorded
that nothing moved. That is true and it is weaker evidence than it reads as: `-Root` makes the
wrapper resolve its members from **the project's own `scripts/`**, so a run like that exercises
the kit's aggregator against the projects' *older* member scripts. It says the aggregator is
compatible. It says nothing about the members.

Re-run after this remediation, all three are still `RESULT OK`, exit 0, member names and
verdicts unchanged — and `scope-check` still prints `not applicable`, which is the tell: those
are their copies, not these.

So the real question was answered the way the reviewer answered F1 — by building the state.
A scratch copy of `flowboard` with this branch's `scripts/*.ps1` copied in:

```text
scope-check: n/a ('main' is the trunk)
ritual-checks: scope-check      n/a ('main' is the trunk)
ritual-checks: scope-repos      n/a ('main' is the trunk)
ritual-checks: RESULT OK
exit=0
```

Two member lines change on a trunk run, from `OK` to `n/a ('main' is the trunk)`. `RESULT OK`
and exit 0 are unchanged, and no workflow, badge or branch-protection rule reads a member's
verdict word — they read the exit code (the reviewer verified the `RESULT OK` consumers
independently; these two lines are downstream of the same finding). The change is visible and
strictly more informative: a trunk run never graded a feature's territory, and now says so
instead of borrowing the word a graded pass uses.


## Phase 5 review round 2 — F2 again, and why it took three attempts

`ai-code-review-phase-5-round-2.md`, fresh context, **REQUEST CHANGES**: 1 BLOCKING,
3 CONFIRM, 2 MINOR, 4 ACCEPTED. **F1 is closed** — the reviewer rebuilt round 1's failing
state (two-commit repository, `--depth 1` clone, `scripts/` copied in) and got
`ritual-checks: scope-check UNGRADED could not resolve a merge base with main` where round 1
recorded `scope-check OK`. **F2 is not.**

### The same paragraph, wrong for the third time

Round 1's header said *"Every grading script in this kit reports in these six words and no
others"*. The remediation replaced it with *"Every grading script in this kit ends its run on
a VERDICT LINE — `<member>: <WORD> [reason]` — and the word is one of these six"* plus
*"Only the last line of a member's output is its verdict."* Four counterexamples, all
confirmed by grep before anything was changed:

| Counterexample | What it prints |
|---|---|
| `scripts/territory-check.ps1` | `CLEAN — ...` / `OVERLAP with ...`, and **exit 2** |
| `scripts/verify-kit.ps1:114` | `verify-kit: not applicable (...)`, spelled out |
| `scripts/scope-check.ps1` on a graded run | last line is `scope-check: PASS phase N commit <sha> (N file(s))` |
| `scripts/enforcement-pack.ps1` on a FAIL | last line is an indented issue bullet, `  - <issue>` |

The third is the one that should have stopped the first draft. `scope-check: PASS phase 5
commit 24e7100 (52 file(s))` was printed by this very phase's own gate run, in the member the
commit was about, and `PASS` is the word plan D4 explicitly rejected in favour of `OK`. The
fourth breaks the same sentence in the member `RIT-006` is built on.

And that second sentence was load-bearing, not decorative: it is what licensed the KNOWN
DIVERGENCES block to leave forty detail lines alone. The excuse rested on a rule the code
disproves.

### The diagnosis, which is not "be more careful"

All three drafts asserted a property of **the kit** — that its scripts conform to a
vocabulary. No such property exists, and none is worth manufacturing: `territory-check.ps1`
answers a different question and exits 2 to say so.

The property that does exist is a property of **this wrapper's derivation**, and it is four
lines of code long. So the header now states that and stops:

1. member exit code non-zero -> `FAIL`, output not read;
2. exit 0, member in `$captureMembers`, output contains `^<member>: UNGRADED` -> `UNGRADED`;
3. exit 0, same condition, `^<member>: n/a` -> `n/a`;
4. exit 0, anything else -> `OK`.

Two facts fall straight out of writing it down, and neither was visible while the paragraph
was making claims about scripts:

- **The verdict block can print four of the six words.** `WARN` is never lifted — a member
  that warns exits 0 and reads as `OK` here, with the warning in its own output above.
  `PENDING` is emitted by nothing. The six-word list is a set of meanings; the block renders a
  subset, and saying so costs nothing.
- **The match is scanned over the whole of a member's output, first hit wins.** It was never
  "the last line". Once that is on the page, `scope-check`'s trailing `PASS` line is not a
  divergence to be excused — it is a line the wrapper does not look at.

`WHAT THIS BLOCK DOES NOT CLAIM` now names all four counterexamples by path, including the two
the reviewer had to find.

### Two stale verdict tables, inside the Territory, that the deferral missed

Round 2's F3 is that round 1's deferral list was short, and that two of the misses are *wrong*
rather than incomplete: `scripts/scope-check.ps1` and `scripts/scope-check-repos.ps1` each
carry their own `.DESCRIPTION` verdict table, and both still listed the pre-remediation words.

```text
scope-check.ps1        PASS / not-applicable / WARN  -> exit 0
scope-check-repos.ps1  PASS / not applicable / n/a / WARN -> 0
```

Neither mentions `UNGRADED`; the first still calls the `fix|chore|docs` lane `not applicable`
after the emission was respelled `n/a`. Both are inside phase 5's **Territory**, in the two
files this remediation exists to change, and both flow down verbatim. There was no Territory
argument for deferring them and no amendment needed to reach them, so they are fixed here
rather than recorded: each table now lists the five words its script can reach, and each says
which of its lines the wrapper actually reads.

That is the same fix as F2, in the two other places the same false claim was written.

### Still deferred, still needing an owner decision

- The three prose lines in the section above (`definition-of-done.md:103`,
  `review-process.md:59`, `code-repo-scope-check.yml.template:37`). Outside Territory,
  none machine-read.
- `scripts/roadmap-claim-check.ps1:57` calls an unreadable ledger `n/a`. It is the identical
  argument that converted `scope-repos`, in a Territory script — but converting it changes
  a member's emitted word, which is a behaviour change with no task, no fixture pair and no
  before/after record (D11). It belongs in a phase or a follow-up, not in a review remediation
  that would be shipping it unproven.
- Round 1's F3-F7 and F9, unchanged.

### What proves this one

Nothing. This commit changes comments only: the header block in `scripts/ritual-checks.ps1`
and the two `.DESCRIPTION` tables. No emission moved, no expectation moved, no rule moved.
The suite and the gate are evidence that it changed nothing, which is exactly the claim.


## Phase 5 review round 3 — the third false universal, and the excuse that was not one

`ai-code-review-phase-5-round-3.md`, fresh context, **REQUEST CHANGES**: 2 BLOCKING,
3 CONFIRM, 1 MINOR (five sub-items), 3 ACCEPTED. Round 2's F2 remediation was verified sound
in every mechanical respect — the derivation table driven through a stub-member harness,
all five predictions confirmed, the three scripts' bodies below `#>` byte-identical to their
parents, suite 782/0 and coverage 187 of 200 unchanged. Both blocking findings are about
sentences, and both sentences are ones the previous two rounds read past.

### F1 — the claim I did not test was the one directly above the two I rewrote

Round 2's rewrite removed the two kit-wide assertions the reviewer named. It left a third,
inside the `FAIL` definition, unchanged since round 1: an invocation error *"which every
member spells `ERROR`"*. One command settles it:

```text
$ for s in <the seven members>; do pwsh -File scripts/$s.ps1 -Root /nonexistent/zzz; done
doc-lint.ps1            NO ERROR line   Resolve-Path: ...doc-lint.ps1:43
enforcement-pack.ps1    NO ERROR line   ...enforcement-pack.ps1:102
scope-check.ps1         NO ERROR line   ...scope-check.ps1:72
scope-check-repos.ps1   NO ERROR line   ...scope-check-repos.ps1:60
build-digests.ps1       NO ERROR line   ...build-digests.ps1:55
roadmap-claim-check.ps1 NO ERROR line   ...roadmap-claim-check.ps1:39
verify-kit.ps1          prints ERROR    verify-kit: ERROR root not found: ...
```

Six of seven surface PowerShell's own unhandled-error output from the `Resolve-Path` on
`-Root`. One conforms. All seven exit 1, which is the only part the derivation actually uses.

The universal is deleted rather than reworded. What replaces it says what the derivation does
— exit code read, output not read, so an aborted run and a real violation are one word here
— and hands the divergence to WHAT THIS BLOCK DOES NOT CLAIM, where it is now stated with
the split measured (one member, then six).

The lesson is narrower than "be careful" and worth writing down: **three rounds each fixed the
sentences that had been pointed at and left their neighbours unread.** A reviewer's finding
names an instance; it does not bound the defect. Round 1's F1 had already taught this
(the fourth fail-open shape nobody asked about), and the lesson was applied to code and not to
prose.

### F2 — the excuse clause was false, and it was load-bearing

The block said `scripts/territory-check.ps1` is *"outside feature 015's Territory"*.
`tasks.md:241` declares it INSIDE phase 5's Territory; `tasks.md:172` declares it inside phase
4's; `spec.md:274-277` counts it among "the nine that decide a verdict" and puts only
`init-kit.ps1`, `update-kit.ps1`, `claim-feature.ps1` and `create-new-feature.ps1` outside.
The `update-kit.ps1` half of the same sentence is correct; pairing the two is what carried the
error, and the paired form is exactly what made it read as settled.

It mattered because it was the stated reason FR-009 goes unmet for that script. An
out-of-scope file needs no justification; an in-Territory one needs a decision. The sentence
manufactured the first to avoid the second.

Now split in two. `update-kit.ps1` keeps its (true) exclusion. `territory-check.ps1` gets the
correction in the file that got it wrong: it prints `CLEAN`/`OVERLAP`, exits 0, 1 or 2 (not
0 or 2 — `:36`, `:47`, `:57`, `:64` all exit 1), is not a member of this wrapper, and is
**unfinished business against FR-009 awaiting an owner decision**, not a boundary.

The closing sentence went with it. *"Reconciling anything further is not this feature's work
and no task claims it is"* was false twice over: T039 is ticked and says "emit `UNGRADED` from
every member that can return without grading", and F3 is a live question. It now records the
question instead of closing it.

### What this commit does not do

F3, F4 and F5 are owner decisions and are untouched. F4 deserves naming here because the
round-1 deferral list missed it and so did round 2:

- `specs/006-verification-pack/data-model.md:27` still calls the Lite lane `not-applicable`,
  and `:52` describes this wrapper's verdict block as `OK/FAIL/WARN` — wrong in both
  directions now. **It is the document the corrected `.DESCRIPTION` table in
  `scope-check.ps1` cites as its authority.**
- `specs/006-verification-pack/contracts/scope-check-cli.md:16,22` and
  `specs/012-cross-repo-scope-check/contracts/scope-check-repos-cli.md:36,100,102`. C16 in
  the latter specifies a run-level `n/a` for an all-skips run, which is precisely what phase 5
  changed to `UNGRADED`.

These are approved contracts of features 006 and 012, outside phase 5's Territory, now
contradicted by shipped code. Constitution II's conflict rule says report, never silently
choose — so they are reported.

F5 is accepted as written: the `roadmap-claim-check.ps1:57` deferral is right for the D11
reason and the "no task" clause was wrong, since T039 covers it.

### What proves this one

Nothing again. Comments only, every changed line inside the `<# ... #>` block that closes at
`:130`, last changed line `:121`. The four facts asserted in the new text were each run or
grepped before being written: the seven exit codes, the `ERROR` split, `territory-check.ps1`'s
three exit paths, and `spec.md:277`.


## Phase 6 — coverage blocks, and adopters are told (US4, US5)

The last phase, and the one that turns the number into a verdict. Until now
`Coverage.Tests.ps1` printed a percentage: plan D9 held it to reporting while fixtures arrived
over five phases, because asserting completeness earlier would have left the branch red from
its first commit to its last — GAP-022's disease, which this feature has complained about
twice. T044 closes that window.

### What "blocking" had to mean before it could be honest

The reporting number on the phase-5 tip was **187 of 200**, with **11 unclassified candidate
lines** printed beneath it. Thirteen sites owned by nothing, eleven more that the broad recall
sweep found and the precise pass did not. Making that a hard failure needed all twenty-four
resolved, and there were only three honest ways to resolve one:

| | |
|---|---|
| a rule with both fixture directions | the ordinary case |
| a rule with a written `exemption` (FR-004) | a faithful fixture cannot be built, and the reason says what would be needed instead |
| a `notRules` entry in `emission-idioms.json` | the line is not a distinct failure condition |

**The third category is the one worth defending, because it looks like a loophole.** Without
it there were two ways to make the number reach the total: invent a rule for every verdict
roll-up line, or tighten the accumulator regex until the remainder vanished. The second is
faster, invisible in the diff, and produces a green run — and it is the instrument being
adjusted until it agrees with itself, which is the defect this feature has hit three times
(T036a, the guard test written for it, and the phase-5 vocabulary block). A declared
`notRules` entry costs a written reason and is printed on every run. That is the difference.

Fifteen lines are declared not-rules: `enforcement-pack: OK` (the success verdict, asserted by
49 expectations), `enforcement-pack: FAIL (N issue(s)):` (the roll-up over the per-issue lines,
56), `AmendmentAuthority: graded N of M` (89), the per-issue renderers and `RESULT FAIL`
roll-ups in `build-digests.ps1`, `doc-lint.ps1`, `verify-kit.ps1` and
`roadmap-claim-check.ps1`. None of them decides anything; each one counts or renders what the
rules above it decided.

### Two rules the sweep found that reading had not

Both had existed for features and neither had a fixture.

- **`AMEND-006`** — `AmendmentAuthority: no commits in <range> — nothing to grade`. A
  return that grades nothing, inside the check that grades amendments: **GAP-027's own shape,
  in enforcement-pack, surviving the feature that was written to close GAP-027**. Phase 4's
  T036b found nine unowned conditions by sweeping `Write-Host` against the declaration; this is
  what the same sweep finds when the declaration is made to block. The pair reaches it through
  `-ReplayBase`/`-ReplayTip` (014 plan D2c): `HEAD..HEAD` is the empty range and `HEAD~1..HEAD`
  the nearest non-empty one, which is the whole of the difference (D10).
- **`PACK-003`** — the trunk dispatch line. Forty-nine expectations end on
  `enforcement-pack: OK` and **not one of them was a trunk run**, so a dispatch that stopped
  saying why it declined would have changed nothing visible.

### Eight exemptions, and what an exemption is allowed to be

FR-004 lets a rule opt out of the fixture pair with a written reason. The danger is obvious: an
exemption is a way to make a failing coverage check green by typing. Three guards, all
asserted:

1. The reason must exist and be more than a gesture (a length floor — not to grade prose,
   but because an empty string satisfies a presence test, which is exactly the shape of
   exemption the rule exists to refuse).
2. An exempted rule **must not also have cases**. Writing an exemption over a covered rule
   would quietly stop its fixtures being required, and the pair could then be deleted with
   nothing going red. That is the likelier future mistake and it now fails.
3. Every exemption is **printed on every run**, grouped by reason. A reason nobody reads again
   is the same as no reason.

Three of the eight are one-offs where the fixture model can only reach a *different* failure
and call it this one: `AMEND-007` (rev-list and the metadata batch would have to disagree about
the same object store), `REPOS-033` (an unreadable committer date on a commit every earlier
guard accepted), `VK-028` (a defensive catch whose message is whatever exception reached it).

**The other five are one finding wearing five hats, and it is a real defect in the kit.**

### `territory-check.ps1` cannot report a verdict at all

Its four error paths are written `Write-Error '...'; exit 1`, under the script's own
`$ErrorActionPreference = 'Stop'`. Under `Stop`, `Write-Error` is TERMINATING: the script dies
at that line and **the `exit 1` after it is unreachable**. Measured through the harness:

```text
territory-check.ps1 -Branch notanumber
  RunChild: the script under test threw before returning a verdict:
    Branch 'notanumber' is not a numbered feature branch (NNN-name) ...
  exit 97
```

97 is the launcher's own code for *did not run to a verdict*, documented as one no kit script
emits. A fixture could pin that, but it would be asserting `RunChild.ps1`'s behaviour rather
than the rule's. Under `pwsh -File` a human still sees exit 1, because PowerShell exits 1 on an
uncaught terminating error, so nothing is broken in production — but the script's error
paths are unassertable, its exit codes are PowerShell's rather than its own, and it speaks none
of the verdict vocabulary (`CLEAN`/`OVERLAP`, exits 0, 1 or 2).

This is the same finding round 3 of the phase-5 review reached from the other end (F2, F3), and
it is now measured rather than argued. **`scripts/territory-check.ps1` is outside phase 6's
Territory and this phase may not touch it**, so it is recorded here and the five sites are
exempted with this as their written reason. It needs a roadmap GAP row, which
`docs/roadmap.md` is outside this Territory to write — an owner action, named rather than
quietly carried.

### The coverage report now

```text
coverage: 189 of 200 declared emission site(s) owned by a fixtured rule, 8 exempt,
          3 declared not a rule, across 9 grading script(s)
coverage: build-digests.ps1        19 of 19 site(s) fixtured
coverage: doc-lint.ps1             10 of 10 site(s) fixtured
coverage: enforcement-pack.ps1     50 of 54 site(s) fixtured (1 exempt, 3 not a rule)
coverage: ritual-checks.ps1         6 of 6  site(s) fixtured
coverage: roadmap-claim-check.ps1   8 of 8  site(s) fixtured
coverage: scope-check-repos.ps1    31 of 32 site(s) fixtured (1 exempt)
coverage: scope-check.ps1          28 of 28 site(s) fixtured
coverage: territory-check.ps1       7 of 12 site(s) fixtured (5 exempt)
coverage: verify-kit.ps1           30 of 31 site(s) fixtured (1 exempt)
```

189 + 8 + 3 = 200, and the eleven unclassified candidates are zero — every one of them was a
roll-up or a renderer, now declared. **There is no remainder.** A new emission site added to
any of the nine scripts fails the suite until someone says, in writing, what it is.

### T048 — SC-002 by sampling, one rule per grading script

SC-002 says deliberately breaking a covered rule must make a named fixture fail, *verified by
sampling, not asserted*. Nine samples, one per script: locate the rule's `emitAnchor`, walk up
to the nearest enclosing `if (`, invert that condition, run the rule's `fail` case, revert with
`git checkout --`.

| script | rule | guard | result |
|---|---|---|---|
| `build-digests.ps1` | DIGEST-001 | `:231` | FAILS (output differs) |
| `doc-lint.ps1` | DOC-001 | `:227` | FAILS (output differs) |
| `enforcement-pack.ps1` | LITE-001 | `:242` | FAILS (output differs) |
| `ritual-checks.ps1` | RIT-003 | `:221` | FAILS (output differs) |
| `roadmap-claim-check.ps1` | CLAIM-001 | `:51` | FAILS (output differs) |
| `scope-check-repos.ps1` | REPOS-001 | `:303` | FAILS (output differs) |
| `scope-check.ps1` | SCOPE-002 | `:246` | FAILS (exit 1->0, output differs) |
| `territory-check.ps1` | TERR-001 | `:51` | FAILS (exit 0->128, output differs) |
| `verify-kit.ps1` | VK-001 | `:122` | FAILS (exit 1->0, output differs) |

Nine of nine caught; `git status scripts/` clean afterwards, checked by the sampler itself
before and after.

**The first run of this sample reported eight false negatives** — `MUTATION NOT UNIQUE,
0 match(es)` — because the guards had been hand-copied out of a context listing that indents
by four spaces. The sampler was wrong about the thing it was measuring, which is this feature's
own recurring defect appearing in the tool written to verify the feature. The fix is why the
guard is now found by LINE (anchor, then walk upwards) instead of by matching a string a human
retyped.

### T047 — FR-020, asserted rather than assumed

Two halves, failing differently. A harness that WRITES to the repository under it corrupts what
it measures and stays green while doing so. A harness that READS that repository's branch,
working tree or identity passes here and fails on someone else's machine. Both were true by
construction and by nobody's promise. Now: the working tree, HEAD and branch are snapshotted
around a real case (`--untracked-files=all`, so a stray file in an ignored directory cannot
fold into an unchanged-looking line); every fixture commit is asserted to carry the fixture
identity and not this repository's; and no `command.json` may name the branch this repository
happens to be on — which would be green here and red for everyone else the day it merges.

### T046 — the failure report names the verdict

`Format-CaseFailure` printed the rule, the script, the case, the exit codes and the first
differing line. A reader was handed the evidence and left to derive the finding. It now names
both verdicts as words:

```text
verdict   : expected 'enforcement-pack: FAIL (1 issue(s)):'
            observed 'enforcement-pack: OK'
```

`<none>` is itself a finding: a run that printed no verdict-shaped line at all is how
`doc-lint.ps1` exited 1 for four features without naming a verdict.

### T053 — what it costs, and where it runs (SC-007)

| | runtime |
|---|---|
| `ritual-checks` job, CI | **16s** (run 35518845272) |
| `enforcement-tests (ubuntu-latest)`, CI | **3m 46s** (run 35518845283) |
| `enforcement-tests (windows-latest)`, CI | **12m 12s** (same run) |
| `ritual-checks.ps1` local, warm, Windows 11 / pwsh 7 | **122s** |
| full harness local, warm | **35-61 min**, load-dependent |

The SC-007 baseline was 82.2s / 80.0s for a local `ritual-checks` run. It is now **122s** on
this machine, and the growth is not the harness: `scope-check -All` grades every phase commit
since the merge base, and this branch has eight of them. The figure to carry forward is the CI
one — 16s — because that is what a gate actually waits for.

**The harness runs BESIDE `ritual-checks`, not inside it, and the numbers are the argument.**
Folding it in would take the gate from 16 seconds to over twelve minutes on Windows: a 45x
increase on the command a developer runs before every phase commit, to re-answer a question
that has not changed since the last time the scripts did. So `enforcement-tests.yml` is its own
workflow, on both OS legs, and `ritual-checks.ps1` keeps its six members and its member names
unchanged (FR-012).

The Windows leg is **3.2x** the ubuntu leg. Process startup: every case spawns a child `pwsh`
and builds a real git repository, and Windows charges more for both. It is not a reason to mock
git (FR-005 forbids it, and the two harness defects this feature found were both in the child-
process boundary that mocking would have hidden).

### What phase 6 does not do

- **`scripts/territory-check.ps1`** — the finding above. Outside Territory.
- **`docs/roadmap.md`** — the GAP row that finding needs. Outside Territory.
- **The phase-5 review's F4 documents** — `specs/006-verification-pack/data-model.md:27,52`
  and the two contracts still describe verdicts the code no longer prints. Outside Territory.
  One of the three prose lines phase 5 recorded WAS reachable here and is fixed:
  `docs/sdlc/review-process.md` now lists `UNGRADED` among the cross-repo check's lawful
  non-blocking verdicts, and says what a reviewer must do about one.
- **`docs/sdlc/definition-of-done.md:103`** and
  **`.github/workflows/code-repo-scope-check.yml.template:37`** — the other two. Outside
  Territory.
