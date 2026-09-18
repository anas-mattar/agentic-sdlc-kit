# AI Code Review — 014 Amendment Authority (phase 3)

**Reviewer**: fresh-context agent — claude-opus-5
**Date**: 2026-09-16
**Branches**: agentic-sdlc-kit `014-amendment-authority` (tip `be27bbc`; amendment `4d0dbb9`,
phase commit `502cf55`, evidence `593c5e3`, gate record `be27bbc`)
**Scope reviewed**: `git show 4d0dbb9`, `git show 502cf55`, `git show 593c5e3`,
`git show be27bbc` in full; `scripts/enforcement-pack.ps1` at HEAD (the `param` block at
`:85-97` and the whole amendment member, `:640-964`, read line by line, plus the dispatch at
`:982`); `scripts/ritual-checks.ps1` argv construction; `.github/workflows/ritual-checks.yml`
and `project-gate.yml.template`; `.specify/memory/constitution.md` Principle I
(Amendment authority, Progress is not amendment) + SYNC IMPACT REPORT `:5-31`;
`docs/sdlc/definition-of-done.md` gates 5 and 6; `docs/sdlc/gate-command.md`;
`docs/sdlc/review-process.md`; `specs/014-amendment-authority/{spec,plan,tasks,notes}.md`;
`.specify/templates/{spec,micro-spec}-template.md`; all four prior reviews. In the adopted
project, **read-only**: `D:\solutions\fitforge` — `specs/001-solution-scaffold/`
`ai-code-review-governance.md` (finding F3 in full) and `ai-code-review-api.md`, plus
`git show`/`git log` over `bed2c26..db25cb7`. Nothing was written into that repository.

**Executed**: twelve fixture repositories **of my own construction** under
`…\scratchpad\p3rev\` (see "Fixtures"); an independent re-derivation of both replays; an
independent git-call instrumentation of the pre-batching pack (`f9276fd`) and the post-batching
pack (HEAD) via a `git.cmd` shim on `PATH`; `pwsh -File scripts/ritual-checks.ps1` on the
working tree. The implementer's seeder and `attack-verify.ps1` were **not executed and not
relied on** — every verdict below comes from a fixture or a replay I built myself.

**Feature contract**: read-only; `git` plumbing only; zero new dependencies; no new file in
`scripts/`; per-commit granularity preserved (plan, Complexity Tracking: "batch the plumbing
calls, not the granularity"); the verdict for a given commit must never change with the
calendar or the machine (plan, Technical Context + D6).

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5
- **Implementer**: claude-opus-5 (the session that produced the diff under review)
- **Inputs provided**: the phase-3 commit range `f9276fd..HEAD` (`4d0dbb9`, `502cf55`,
  `593c5e3`, `be27bbc`), `spec.md`, `plan.md`, `tasks.md`, `notes.md`,
  `scripts/enforcement-pack.ps1` at HEAD, the four prior reviews
  (`ai-code-review-phase-1.md`, `ai-code-review-phase-1-remediation.md`,
  `ai-code-review-phase-2.md`, `ai-code-review-phase-2-remediation.md`),
  `.specify/memory/constitution.md`, `docs/sdlc/definition-of-done.md`,
  `docs/sdlc/review-process.md`, `docs/sdlc/gate-command.md`, and
  `specs/_templates/ai-code-review-template.md`
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — 6 blocking, 10 non-blocking.

Start with what is genuinely proven, because it is the best evidence this feature has produced
and none of it came from a fixture the author designed.

**SC-002 holds on the substance.** I ran the check myself over FitForge 001
(`bed2c26..db25cb7`, `-IgnoreAmendmentBoundary`, read-only) and reproduced 23 of 25 commits
graded and 14 flags, to the commit and to the file list. Every amendment FitForge's governance
review names in finding F3 fails the check as actually committed. The check really does catch,
by sha, the failure this whole feature was built for.

**SC-004's numbers reproduce exactly.** My own replay — my own branch-range derivation, from
the merge commits on `main` — returns **67 flags over 121 graded commits across 002–013**, and
my own categorisation returns 51 on `tasks.md` alone, 11 touching `contracts/**`, 4 touching
`spec.md`/`plan.md`, and the single D5 flag on `e1dcf0c`. Not one figure in that table is off.
The D3c decision the replay drove is also correct on its merits: I read three of the flagged
diffs cold (`8fd95f6`, `c7a5287`, `29e6988` — none of them among the notes' three samples) and
they do exactly what the notes say: they rewrite the task's text while ticking it. Refusing the
exemption was the right call and the reasoning in D3c is sound.

**SC-006's measurement is now reproducible, which is what the fourth review asked for.** I
instrumented both pack versions with a shim that logs every `git` invocation. Pre-batching
(`f9276fd`) on this branch: **97** pack calls, of which **71 (73%)** are the amendment member.
Post-batching (HEAD): **45** pack calls, of which **exactly 20 (44%)** are the amendment
member. The notes claim 66 of 89 → 20 of 43 on a branch that was three commits shorter. That is
a match, and J11's "not reproducible" complaint is closed.

**And per-commit granularity did survive.** I built the `pull_request` merge-preview shape from
scratch (`git commit-tree` with `main` as the first parent) — the case the brief flags as the one
the batching had most room to break — and the check still grades 2 of 3 and still fails the
silent amendment. S9, S10, S13, H3 and the D4 single-record case all behave as specified after
the batching, verified on my own fixtures.

So why REQUEST CHANGES.

**The batching introduced two new silent false PASSes and one new silent fail-open**, all three
of the same shape the plan promised it would not create ("the batches change *who* is asked, not
*what for*"). A single ASCII record separator (0x1E) anywhere in a commit message removes that
commit from the graded set **and from the denominator** — `AmendmentAuthority: graded 1 of 1`,
the output of a perfectly healthy run (B1, demonstrated with a control). A non-ASCII path in a
graded document is emitted quoted-octal by the new `git log --name-status` batch, which omits the
`core.quotepath=off` the rest of the kit has used since 006, so the file falls out of the path
filter and its amendment is never graded (B2, demonstrated). And the presence batch is
all-or-nothing: one unresolvable ref aborts the whole `git grep` (exit 128, no output), leaving
an empty presence set and a check that grades **nothing** for the entire branch while printing
what a clean branch prints (B3). The comment at `:661` asserts that 0x1E "cannot occur in a
commit message". It can.

**The evidence layer is the other half.** SC-004 asks for "no failure that a reviewer judges
spurious" and T020 asks the phase to "table every flag: commit, file, class of change, and a
verdict". There is no such table — `notes.md` records aggregates, three sampled diffs and one
named D5 flag, so 66 of 67 flags have no individual recorded judgement (B4). And the flag the
sampling would have caught is the one that matters: the replay surfaced a **class** the phase did
not adjudicate at all. `a9ddeb7` and `4e87018` are the commits in which the owner changed
`**Status**: Draft` to `**Status**: Approved`. That is the granting of approval, and the
constitution's own wording binds "any later change to that feature's … documents" *after*
approval — yet the check flags it, and will flag it on every future feature, because the kit's
own spec and mini-spec templates instruct exactly that edit (B5, demonstrated on a fixture). D3a
existed for precisely this decision and T022 concluded "D3a does not apply".

**Which leads to the finding I did not expect.** The SC-002 evidence table names
`3cb6e34` as one of F3's five amendments — "the added phase". It is not. FitForge's governance
review says, in the F3 section itself, "**The owner approved once: `3cb6e34`**", and its
`spec.md` diff at that commit is `Status: Draft` → `Status: Approved 2026-09-10 (owner: anas.m)`.
F3's five-row table names `cff8c57`, `26d9108`, `8785678`, `7d3f297`, `92455d6`. `cff8c57` is
missing from the notes and `3cb6e34` — the approval — has been substituted for it (B6). SC-002 is
substantively met either way, because the check flags all five real shas (I verified), but the
feature's headline criterion is recorded against the wrong commit, and the substitution
inadvertently certifies B5's false-positive class as a success.

Residual risk therefore sits in two places. In the code it is entirely in the new plumbing layer
(`:661-735`), not in the classifier — the classifier was heavily worked over in rounds 3 and 4
and I could not break it. In the evidence it is in the per-flag judgement that SC-004 requires
and that does not exist; without it, a class this replay actually surfaced went unadjudicated,
which is the one thing phase 3 was declared to decide.

**Two things this phase did right that deserve recording.** When the "thirteen features" figure
in the approved `plan.md` turned out to be wrong, the implementer recorded the correction in
`notes.md` and explicitly declined to edit the approved document — "correcting an approved
document needs an approver who is not me (constitution I)". That is the feature obeying its own
law under mild inconvenience, which is the test the plan set itself. And the gate-triplet note in
`notes.md` — pushing `502cf55` alone so the CI run lands on the phase commit rather than on the
branch tip — is the correct reading of `gate-command.md`'s third element, written down so the next
person does not get it wrong.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | **FR-002 defeated** on a non-ASCII graded path (B2, fixture `f4`: a silently reinterpreted `contracts/café-api.md` returns clean) and on any commit whose message carries 0x1E (B1, fixtures `f3`/`f3b` with control `f3c`). **FR-004 defeated wholesale** when the presence batch's `git grep` aborts (B3). FR-005/006/009/010 hold: verified on my own fixtures `f6` (S9 PASS, S10 FAIL, D4 PASS) and `f7` (S13 renumber PASS, H3 rename-plus-rewrite FAIL). **FR-008 partly regressed** by T023's wording (N2). SC-002 met on substance, mis-recorded (B6). **SC-004 not met**: no per-flag judgement (B4) and a spurious class unadjudicated (B5). SC-006 measured and reproducible, unit substituted (N1). |
| SC-002, re-derived independently | `pwsh -File scripts/enforcement-pack.ps1 -Root D:/solutions/fitforge -Branch 001-solution-scaffold -ReplayBase bed2c26 -ReplayTip db25cb7 -IgnoreAmendmentBoundary` → `graded 23 of 25`, **14 flags**. Flagged shas include all five F3 amendments — `cff8c57`, `26d9108`, `8785678`, `7d3f297`, `92455d6` — and the file lists match `notes.md:367-371` row for row for the four shas the notes get right. **Reproduced. See B6 for the fifth row.** |
| SC-004, re-derived independently | I derived the twelve branch ranges myself from `main`'s merge commits (`git log --format=%P` on each merge, `git merge-base` on the two parents) and ran the pack once per range. Totals: **67 flags**, **121 of 124 commits graded** (3 merge commits skipped). Per feature: 002 0, 003 0, 004 0, 005 1, 006 12, 007 11, 008 11, 009 8, 010 7, 011 1, 012 4, 013 12. Categorised by the flag's own file set: `tasks.md` alone **51**, `contracts/**` **11** (6 with `tasks.md`, 5 alone), `spec.md`/`plan.md` **4**, D5 **1**. **Every number in `notes.md:379-385` reproduces exactly.** |
| The D3c judgement (T022), re-derived on a fresh sample | Read cold: `8fd95f6` (006 phase 4) rewrites all four of T022–T025's task bodies while ticking them, adding "— also synced Workflow steps 6–7", "this exposed the stale DoD preamble clause", "verified complete with zero edits: …"; `c7a5287` rewrites a W4 evidence row mid-table; `29e6988` rewrites a contract's CI step description. **The notes' characterisation is correct and the refusal to exempt is right.** |
| Per-commit granularity after batching (the brief's headline risk) | Fixture `f5b`, built with `git commit-tree "$(git rev-parse $BR^{tree})" -p $MAIN -p $BR` to reproduce GitHub's merge preview exactly: `graded 2 of 3` and the silent `plan.md` amendment still **FAILS**. The presence batch runs once for the range, but the sticky flag is still consulted per commit against that commit's own parent. **J2 stays closed.** ✔ |
| Regression sweep of the phase-2 behaviours I could reach | Fixture `f1` silent amendment → FAIL ✔. `f6`: checkbox-only → PASS ✔, tick+reword → FAIL ✔, one record in `plan.md` covering `plan.md`+`tasks.md` → PASS ✔. `f7`: whole-directory renumber (`D`+`A`+`R100` rows) → PASS ✔; contract renamed and rewritten → FAIL ✔. 6 of the claimed 33 scenarios verified on fixtures I built; **no verdict I could check had changed**. |
| SC-006, instrumented independently | A `git.cmd` shim on `PATH` logging every invocation, run against both pack versions on this branch (20 commits, 11 graded). `f9276fd`: **97** calls total — amendment member **71** (20 `rev-list --parents -n 1`, 11 `show --name-status`, 10 `show <ref>:scripts/enforcement-pack.ps1`, 10+4+2 document blobs, 3+3+3 `show -s`, 2+2+1 `show -U0`, 1 `rev-list --reverse`) = **73%**. HEAD: **45** calls total — amendment member **20** (1 `log` meta, 1 `log --name-status`, 1 `git grep`, 6+4+2 blobs, 2+2+1 `show -U0`) = **44%**. **The 66→20 / 89→43 claim reproduces.** The residual 20 calls are proportionate to documents amended, not to branch length — the shape the plan asked for. |
| `-IgnoreAmendmentBoundary` / `-ReplayBase` / `-ReplayTip` reachability (D2c) | `grep -rn 'IgnoreAmendmentBoundary\|ReplayBase\|ReplayTip'` over the tree: every hit is inside `scripts/enforcement-pack.ps1` (`:89`, `:94-96`, `:851`, `:856`, `:876`, `:982`). `scripts/ritual-checks.ps1` passes only `-Root` and `-Branch`; `.github/workflows/ritual-checks.yml` invokes `./scripts/ritual-checks.ps1 -Branch $env:RITUAL_BRANCH` and nothing else. Semantics: `-IgnoreAmendmentBoundary` sets `$graded = $true` (`:876`), which only widens grading; `-ReplayTip` only changes the range and cannot suppress a failure on the branch's own range. **No gate path passes any of them.** PASS. |
| Scope discipline | `git show --stat 502cf55` = `scripts/enforcement-pack.ps1` only; phase 3 Territory is `scripts/enforcement-pack.ps1` + `specs/014-amendment-authority/tasks.md`. Live `scope-check` in the ritual run: `PASS phase 3 commit 502cf55 (1 file(s))`. `4d0dbb9`, `593c5e3`, `be27bbc` carry no phase token and are reported "not applicable". **In scope** — with the observation at N10 that `plan.md`, which T022 *required* be amended, is not in the declared Territory. |
| Amendment authority applied to this phase's own amendment | `4d0dbb9` amends `plan.md` with `**Amendment approved by**: anas.m, 2026-09-14.` and its message body carries "Amendment approved by: anas.m, 2026-09-14."; its `tasks.md` hunk is checkbox-only. Graded, not skipped: `-ReplayBase 4d0dbb9^ -ReplayTip 4d0dbb9` → `graded 1 of 1`, no failure. The whole phase-3 arc: `-ReplayBase f9276fd -ReplayTip HEAD` → `graded 5 of 5`, no failure. **The feature obeys its own law.** ✔ (What that verifies is a record, not a consent — D10; see N11.) |
| The `593c5e3` correction of fact | `main`'s first-parent history carries **thirteen** merged `NNN-*` feature branches (001 through 013 — `61a4f09` merges `001-delivery-core-amendment`). The replay covered **twelve** (002–013). I replayed 001 as well: `graded 3 of 3`, **0 flags**, so the omission costs SC-004 nothing. The corrected figure is right *about the replay's coverage*; see N4 for why it is still not the figure D3c's sentence needs. |
| Ritual checks on the working tree | `pwsh -File scripts/ritual-checks.ps1` → `RESULT OK`, exit 0. Members: doc-lint OK, enforcement-pack OK (`AmendmentAuthority: graded 11 of 20`), scope-check OK (`PASS phase 2 e1f5e46`, `PASS phase 3 502cf55`), scope-repos n/a, digests OK (5 fresh, 78 markers), roadmap-claims OK, verify-kit n/a. Five `PhaseSizeWarning`s, all pre-existing. **Note**: the tree is **not clean** — `.specify/templates/tasks-template.md`, `adoption/greenfield.md`, `adoption/updating.md`, `docs/sdlc/branch-strategy.md` and `specs/014-amendment-authority/tasks.md` carry uncommitted phase-4 work. My verdicts come from commits, never from the tree. |
| Security | Read-only. New git verbs: `log` (twice) and `grep -l`. No writes, no network. No shell interpolation: `@unique` is splatted as native arguments and its elements are shas from `%P`. **One new untrusted-input path**: commit-message text now flows into a record parser as field-delimited data (`:668-678`), which is B1. |
| Rollback safety | Reverting `502cf55` restores `f9276fd`'s function set exactly; the only signature change reaching outside the member is the two optional `param` strings at `:94-96`. No state, no schema. PASS. |
| PowerShell correctness | `[ordered]` preserves `git log --reverse` order, so `$commits` is oldest-first as the sticky flag requires ✔. `$line[0] -eq [char]30` is an ordinal `char` comparison and is the correct fix for the culture-sensitive `StartsWith` bug the commit message describes ✔ (I confirmed the failure mode is real: `"`u{1e}x".StartsWith("x")` is `$true` under culture-sensitive comparison). `$PSNativeCommandUseErrorActionPreference` is `$False` on pwsh 7.6.6, so `git grep`'s exit-1-on-no-match does not throw under `$ErrorActionPreference = 'Stop'` — but this is luck, not design, and it is not asserted anywhere. `Get-BlobLines` caching a failed read as `@()` makes `Test-CheckboxOnlyChange` return `$true` when both blobs are unreadable; I could not reach it independently of B2's path filter, so it is folded into B2's fix. |
| Constitution / D-decisions | D1 (per-commit walk) preserved ✔. D2, D3, D4, D5, D6, D7, D8 unchanged and re-verified on fixtures ✔. D2b: the boundary is still per-commit ✔ but now all-or-nothing across the range (B3). D2c honoured ✔. D3a **not discharged** (B5). D3c implemented in the wording, over-broadly (N2). **Constitution I's own scope sentence** — "once a feature's `spec.md` or `plan.md` **has been approved**" — is the rung the check contradicts in B5. |

### Fixtures

All built by me under
`C:\Users\anas.m\AppData\Local\Temp\claude\D--solutions-agentic-sdlc-kit\83fd0c56-d853-4821-8090-0f47028ca0d3\scratchpad\p3rev\`.
Each is a fresh `git init` with the HEAD copy of `scripts/enforcement-pack.ps1` committed on
`main` first, so the D2b boundary is genuinely crossed rather than lifted; the real script is
then run with `-Root <fixture> -Branch <NNN-name>`.

| Fixture | Shape | Purpose |
|---|---|---|
| `f1` | create, then silently widen `plan.md` | baseline — the check works in my hands |
| `f2` | mini-spec `Status: Draft` → `Status: Approved (owner…)` | B5 |
| `f3` | silent amendment, then a commit whose message injects `0x1E<target-sha>0x1F…` | B1 (targeted) |
| `f3b` | silent amendment whose **own** message contains one bare `0x1E` | B1 (self-hiding) |
| `f3c` | byte-identical commits, plain messages | B1 control |
| `f4` | `contracts/café-api.md` reinterpreted with no record | B2 |
| `f5`/`f5b` | GitHub `pull_request` merge preview via `git commit-tree` | J2 re-verification |
| `f6` | tick only; tick+reword; one record covering two files | S9 / S10 / D4 |
| `f7` | whole-directory renumber; contract renamed **and** rewritten | S13 / H3 |
| `f8`/`f9` | shallow clones at depth 2 and 3 | B3 (trigger not reached — see B3) |

## Findings

### B1 — One ASCII record separator in a commit message deletes that commit from the graded set, silently — BLOCKING

`Get-CommitMetaBatch` (`:666-682`) asks `git log` for every commit's sha, parents, date, **body**
and trailers in one call, delimited by `0x1E` between records and `0x1F` between fields. The
comment at `:661` states that `0x1E` "cannot occur in a commit message". Git places no such
constraint on a message, and `git commit -F <file>` will carry one through.

Two consequences, both silent, both a false PASS.

**Self-hiding.** A commit whose own message contains a bare `0x1E` splits its own record: the
body is cut before the fourth `0x1F`, the record parses to four fields, and `:674`
(`if ($f.Count -lt 5) { continue }`) drops it. The commit is absent from `$meta`, so it is absent
from `$commits` — it is missing from the **numerator and the denominator** of the count line
phase 3 added specifically so that silence would be impossible.

Fixture `f3b` — a commit that adds `- rule B smuggled in` to an approved `plan.md`, message
`phase 1: implement\n\nnothing to see here \x1e`:

```text
AmendmentAuthority: graded 1 of 1 commit(s) in 8644dda..HEAD
```

No failure, and the count line reads exactly like a clean two-commit branch.

**Targeted.** `$meta[$f[0].Trim()] = …` at `:675` is an unconditional assignment, so an injected
record overwrites a real one. A later commit whose message contains
`0x1E<earlier-sha>0x1F0x1F0x1F0x1F` gives that earlier commit an empty `Parents`, and `:890`
(`if ($parents.Count -eq 0) { continue }`) skips it as a root commit.

Fixture `f3` (target `fd57a04`, a silent `plan.md` widening) against control `f3c` — identical
trees and diffs, only the third commit's message differs:

```text
f3c (control):  AmendmentAuthority: graded 3 of 3 commit(s) …
                  - AmendmentAuthority: commit 0b60995 amends …/plan.md …
                  - AmendmentAuthority: commit fb6d431 amends …/tasks.md …
f3  (injected): AmendmentAuthority: graded 1 of 2 commit(s) … (1 not graded: merge commits,
                or made before the check existed — plan D2b)
```

Two flags become zero. The injecting commit hides itself *and* its predecessor, and the
explanation string blames merges or D2b, neither of which applies.

This is new in `502cf55`. The phase-2 shape asked `git rev-list --parents -n 1 $commit` per
commit, which reads the object graph and is immune to message content. The plan's promise for
this work was "the batches change **who** is asked, not **what for**"; here the *what* changed —
a commit's parentage is now taken from its own message stream.

*Action: implementer — do not let message text decide which commits exist. Enumerate the range
with `git rev-list --reverse` (one extra call, and the pre-batching code already did it), then
require `$meta` to cover exactly that set and raise a **failure** — not a skip — on any sha it
does not. Belt and braces: use `-z`/`%x00` record separation, or reject any message containing a
C0 control character other than tab/newline with a named failure. The "not graded" string at
`:962` must also stop asserting a cause it has not established.*

### B2 — A non-ASCII path in a graded document is never graded — BLOCKING

`Get-NameStatusBatch` (`:688-704`) reads `git log --reverse --format=… --name-status` **without**
`-c core.quotepath=off`. Git therefore emits a non-ASCII path in quoted-octal form, surrounded by
literal double quotes, and `:907` (`if ($path -notlike "$dir/*") { continue }`) drops it, because
the string now starts with `"` rather than with `specs/`.

Fixture `f4` — `specs/046-v/contracts/café-api.md` created, then reinterpreted
(`the value is 30 seconds` → `300 seconds`) with no record anywhere:

```text
$ git log --format='%H' --name-status -1 HEAD
e36d79f
M       "specs/046-v/contracts/caf\303\251-api.md"

$ enforcement-pack -Branch 046-v
AmendmentAuthority: graded 2 of 2 commit(s) in 30aa7c9..HEAD
```

Clean. This is spec US1 acceptance scenario 3 verbatim — "a commit reinterprets one of its
clauses without an approver line **Then** the checks fail and name the file" — and it does not
fail.

The kit has fixed this exact shape twice and knows it by name: `scripts/scope-lib.ps1:25-29`
("quotepath=off so non-ASCII paths arrive verbatim, not quoted-octal — 006 review F3"),
`scripts/scope-check.ps1:115`, and `scripts/enforcement-pack.ps1:577-578` itself
("quotepath=off so non-ASCII filenames cannot dodge the pattern — phase 2 review, F2"). The
amendment member is the one `--name-status` reader in the pack that omits it. The omission is
inherited from phase 2, but `502cf55` is the commit that lifted that read into a new function
and is the right place to close it.

A related consequence rides on the same fix: `Get-BlobLines` caches a failed read as `@()`, and
`Test-CheckboxOnlyChange` (`:802-815`) returns `$true` when both blobs are empty — so a
`tasks.md` whose path git quotes would read as "checkbox-only" rather than merely be skipped. I
could not reach that independently of the path filter, so it is not a separate finding, but the
guard is worth adding.

*Action: implementer — add `-c core.quotepath=off` to the `git log --name-status` call at `:692`,
and make `Test-CheckboxOnlyChange` return `$false` (not `$true`) when both blob reads come back
empty for a path `--name-status` says was modified.*

### B3 — The presence batch is all-or-nothing: one bad ref disables the check for the whole branch, silently — BLOCKING

`Get-CheckPresenceSet` (`:712-720`) replaces N per-ref blob reads with one
`git grep -l -F -e 'function Invoke-AmendmentAuthorityCheck' @unique -- 'scripts/enforcement-pack.ps1'`.
`git grep` over multiple revisions is atomic: if **any** revision in the list cannot be parsed,
the whole command aborts and prints nothing.

```text
$ git grep -l -F -e 'function Invoke-AmendmentAuthorityCheck' 502cf55 4d0dbb9 -- 'scripts/enforcement-pack.ps1'
502cf55:scripts/enforcement-pack.ps1
4d0dbb9:scripts/enforcement-pack.ps1
exit=0

$ git grep -l -F -e 'function Invoke-AmendmentAuthorityCheck' 502cf55 deadbeef…beef 4d0dbb9 -- 'scripts/enforcement-pack.ps1'
fatal: unable to parse object: deadbeefdeadbeefdeadbeefdeadbeefdeadbeef
exit=128
```

With `2>$null` the error is discarded, `$set` stays empty, every commit fails
`$presence.ContainsKey($parent)` at `:888`, and the run prints
`graded 0 of N (N not graded: merge commits, or made before the check existed — plan D2b)` — the
output of a legitimately pre-boundary branch. The old per-ref probe degraded one commit at a
time; this degrades the entire branch at once, without a word. It is J2's shape with a different
trigger, and J2 was blocking.

Two triggers I can name. **(a)** any first parent whose object is absent or unparseable — a
shallow or partial clone, a grafted or replaced history, a corrupt object. The kit's own
`ritual-checks.yml:33` sets `fetch-depth: 0`, so CI here is safe today; `project-gate.yml.template:51`
checks out at the default depth 1, and nothing in the script asserts the invariant it now depends
on. **(b)** argument-list length: ~41 bytes per sha against a 32 767-byte Windows command line
puts the ceiling near 700 commits on one branch — remote for this kit, not for an adopted project
with a long-lived feature branch. Both end in the same silent empty set.

Honesty about what I proved: I demonstrated the **mechanism** (the `git grep` abort above) and
the **failure semantics** (empty `$presence` ⇒ nothing graded, by reading `:888` and by observing
that shape on pre-boundary ranges). My shallow-clone fixtures `f8`/`f9` did not reach it, because
`Get-DiffBase` fails first in a shallow clone and the member returns at `:854`. So the trigger is
analytic, the consequence is demonstrated, and the check has no defence against either.

*Action: implementer — make the batch fail loud rather than fail open. Capture
`$LASTEXITCODE` (`git grep` exits 0 on a match, 1 on none, ≥128 on error) and, on ≥2, either fall
back to the per-ref `git show` probe or emit a named failure; chunk `$unique` into batches of,
say, 200 refs. A one-line assertion that `$unique.Count -gt 0 -and $hits.Count -eq 0` is a
*possible* legitimate state but an error exit is not would have caught this.*

### B4 — SC-004 has no per-flag judgement; 66 of 67 flags carry none — BLOCKING

SC-004 requires "no failure that a reviewer judges spurious". Phase 3's own Independent Test
sharpens it: "every other flag over this repository's merged history is one a reviewer judges
real, **with the judgement written down per flag**". T020 spells out the artifact: "table every
flag: commit, file, class of change, and a verdict — real amendment, or spurious".

`notes.md:376-408` records, in place of that table: a six-row aggregate count; one sentence of
class reasoning; three sampled diffs quoted by numstat (`66b3dff`, `dc6bbd6`, `aad06e1`); and one
named flag (`e1dcf0c`, the D5 case). Grepping the whole feature directory for any other flagged
sha returns nothing. Sixty-six of sixty-seven flags have no recorded verdict, so the criterion's
own artifact does not exist and T020 is ticked against work that was not produced.

This is not bookkeeping. The judgement is what converts "the check fired 67 times" into "the
check is right"; sampling three of fifty-one is how B5 — a class the replay *did* surface — got
past T022. My own pass over the flag list took one command (`git diff <sha>^ <sha> --numstat` per
flagged file, with the subject line) and is what turned up B5 within two minutes of reading it;
the commits where the sample would have hurt are the small ones the notes never look at
(`a9ddeb7` 1/1, `4e87018` 1/1, `c7a5287` 1/1, `29e6988` 1/1, `8fd95f6` 4/4, `b0fe413` 3/3).

*Action: implementer — write the T020 table into `notes.md`: one row per flag (commit, files,
class, verdict, one-line reason), 67 rows. Grouping identical classes is fine — "these 38
`tasks.md` flags are the tick-and-rewrite class, see the three sampled diffs" is a written
judgement per flag — but every sha must appear and every sha must carry a verdict. The aggregate
table stays as the summary it is.*

### B5 — The replay surfaced a spurious class and T022 did not adjudicate it: the owner's own approval commit is flagged — BLOCKING

Two of the four `spec.md`/`plan.md` flags are the same commit shape:

```text
a9ddeb7  1 1 specs/011-roadmap-claim-check/spec.md      | spec: approve 011-roadmap-claim-check mini-spec
4e87018  1 1 specs/013-critical-independence-signal/spec.md | plan: 013 plan and tasks — …
```

Both diffs are one line:

```diff
-**Status**: Draft <!-- Draft → Approved (owner) before the phase begins — constitution I, Micro arm -->
+**Status**: Approved (owner, 2026-09-09)
```

```diff
-**Status**: Draft — awaiting owner approval
+**Status**: Approved 2026-09-10 (owner: anas.m)
```

That edit is not a change to agreed content; it **is** the approval. And the kit mandates it:
`.specify/templates/spec-template.md:5` ships `**Status**: Draft`, and
`.specify/templates/micro-spec-template.md:5` ships `**Status**: Draft <!-- Draft → Approved
(owner) before the phase begins — constitution I, Micro arm -->`. Constitution I's own scope
sentence (`:200`) binds "once a feature's `spec.md` or `plan.md` **has been approved**, any
**later** change" — so by the law's words the approval commit is not in scope. The check's D2
proxy ("approved begins at first appearance") puts it in scope anyway.

Demonstrated forward, not just historically — fixture `f2`, the kit's own template text, the
owner's own commit, nothing hostile:

```text
AmendmentAuthority: graded 2 of 2 commit(s) …
  - AmendmentAuthority: commit 3911a0c amends specs/043-y/spec.md after approval with no
    conforming approver record. Add '**Amendment approved by**: <name>, <YYYY-MM-DD>' to the
    amended section … Ticking a task off is exempt — in either direction — but rewriting a
    task's text while ticking it is not: record what was done in notes.md …
```

So on the next feature that follows the kit's documented flow, the commit in which the owner
records their approval turns the branch red, and the message it turns red with talks about
ticking tasks.

D3a is the mechanism for exactly this: "if it flags a **class** of routine change that no
reviewer would call an amendment, that class is added to the exemption with its reason
recorded". This is a class by every test D3a sets — template-mandated, twice in twelve features,
certain to recur, and not a change to agreed content. `notes.md:410-426` concludes "D3a does
**not** apply" having considered only the `tasks.md` concentration; the `spec.md` flags are
counted in the aggregate table and never looked at. I judge them spurious, which falsifies SC-004
as recorded.

The fix is not necessarily an exemption. Three defensible resolutions, and the choice is the
owner's:

1. **Exempt the approval edit** — a change confined to the `**Status**:` header line of `spec.md`
   whose new value matches an "approved" form. Narrow, machine-judgeable, and it is the line the
   templates tell people to edit.
2. **Move the D2 proxy** — "approved" begins at the commit that sets `Status: Approved`, not at
   first appearance. Strictly better semantics, materially more work, and it would need a
   fallback for documents that never carry the header.
3. **Change the practice** — create `spec.md` already stamped `Approved`, as this feature's own
   `be7f36d` does, and say so in phase 4. Cheapest, consistent with D3c's "the habit changes"
   precedent, and it makes the template's own instruction wrong until phase 4 fixes it.

*Action: owner — decide between (1), (2) and (3). Implementer — record the class and the decision
in `notes.md` under T022, and if (1) or (2), amend `plan.md` under D3a with its own approver line,
as T022 requires. Either way `.specify/templates/{spec,micro-spec}-template.md` must stop
instructing an edit the check refuses.*

### B6 — SC-002's evidence table names the owner's approval commit as one of F3's five amendments, and omits the real one — BLOCKING

`notes.md:365-371` presents the criterion this whole feature was aimed at:

| notes.md row | What FitForge's F3 actually says |
|---|---|
| `26d9108` "the §5 new package amendment" | ✔ "plan §5 package list swapped", 10:20:34 |
| `7d3f297` "the amendment made **two seconds** before the phase" | "contract §1 reinterpreted; T047's value 3s → 2s" — the gap is **29 seconds**, not two; F3's own prose calls it "the 29-second margin", and the kit's `spec.md` Context says "one pair **29 seconds** apart" |
| `8785678` "widened Territory (a `scope-check` WARN…)" | "contract §1 gains a new provider MUST; phase 6 created" |
| `92455d6` "widened Territory (the second WARN)" | "phase 7 created" |
| `3cb6e34` "**the added phase**" | **not an amendment at all** — F3's opening sentence is "The owner approved once: `3cb6e34` at 10:02:57, stamping `spec.md` `**Status**: Approved 2026-09-10 (owner: anas.m)`" |
| *(absent)* | `cff8c57` "T007: host wiring moves to `Api/Hosting/`", 10:04:05 — **row 1 of F3's table**, and named again in F3's action line as one of "the four post-approval amendments" |

Verified read-only in the adopted project:
`git log -1 --format='%s' 3cb6e34` → `spec: owner approves 001 and accepts ADR-001`, and its
`spec.md` diff is `Status: Draft` → `Status: Approved 2026-09-10 (owner: anas.m)`.

The substance is fine — `cff8c57` **is** flagged by the check (it appears in my 14-flag replay),
so all five of F3's real amendments fail as actually committed and SC-002 is met. What is wrong is
the record: the feature's headline criterion is evidenced against the wrong sha, with one row's
timing off by an order of magnitude and two rows' descriptions borrowed from a different finding.
And the error is not neutral — by presenting `3cb6e34` as an amendment the check correctly
refuses, the table certifies B5's false-positive class as a success. The same figure was carried
into `502cf55`'s commit message ("the five F3 amendments still named by sha").

*Action: implementer — correct the `notes.md` table: `cff8c57`, `26d9108`, `8785678`, `7d3f297`,
`92455d6`, each with F3's own description and F3's own gap figure; record `3cb6e34` separately as
the owner's approval commit, flagged, and cross-reference B5. Re-state SC-002 against the
corrected set. `notes.md` is not an approved document, so no approver line is owed for the fix.*

---

### N1 — SC-006's unit substitution is legitimate; the post-fix runtime claim is not made — NON-BLOCKING

SC-006 asks for "no more than a small, **stated** fraction to the **runtime** of `ritual-checks`".
The substitution of git-call count for wall-clock is defensible and I would have made it: the
notes calibrate the proxy against wall-clock *before* the change (15.7 s / 18.3 s with the check
vs 4.5 s / 5.0 s without — three quarters of the time against three quarters of the calls), the
proxy is machine-independent, and I reproduced it exactly (71/97 → 20/45). That is a better
answer than the fourth review got.

The gap is that the proxy is never re-calibrated **after** the change. We know the calls halved;
we do not know what the runtime share became, and the one figure reported for the batched pack
(201 s) is discarded as machine noise. The residual is stated honestly ("47% of 43"), and my own
count makes it 44% of 45 — still the joint-largest git-call consumer in the pack, alongside
`PhaseSizeWarning`'s 20 per-commit `show --numstat` calls. Calling that "a small fraction" of the
pack would be a stretch; of `ritual-checks` as a whole it is roughly a sixth, which is defensible
and should be the number stated.

*Action: implementer — state the criterion as met in the proxy unit, with the residual share of
`ritual-checks` (not of the pack) as the number, and one back-to-back with/without ratio on the
batched pack if any machine can produce one. Do not leave SC-006 reading as though runtime was
measured after the fix.*

### N2 — T023's tuned failure message appends `tasks.md` guidance to every failure — NON-BLOCKING

`:946` ends every no-record failure with "Ticking a task off is exempt — in either direction — but
rewriting a task's text while ticking it is not: record what was done in `notes.md`, and leave the
task saying what was agreed (plan D3c)". T023 tuned the wording against the real flags, and 51 of
67 are the `tasks.md` class, so the sentence fits the majority. It does not fit the other 16, and
it is the first thing a developer reads when a `contracts/**`, `spec.md` or `plan.md` amendment
goes red — see B5's fixture output, where a one-line `spec.md` status edit is answered with advice
about ticking tasks.

FR-008 also asks the message to name "what **class** of change was detected". "amends `<files>`
after approval" is the only class statement, and it is the same for a reworded task, a deleted
contract and a widened Territory.

*Action: implementer — make the tail conditional on the amended set containing `tasks.md`, and
consider naming the detected class per file (`text changed` / `added` / `removed` / `renamed and
rewritten`), which the walk already knows.*

### N3 — The "not graded" explanation asserts causes it has not established — NON-BLOCKING

`:962` renders every skipped commit as "merge commits, or made before the check existed — plan
D2b". Three other paths land in the same bucket: a root commit (`:890`), a commit dropped by the
meta parse (B1), and — when the presence batch aborts — the entire branch (B3). In B1's targeted
fixture the line blamed D2b for a commit whose parent carries the check.

*Action: implementer — count the skip reasons separately (merge / no parent / pre-boundary) and
report them as counted, not as a disjunction. Anything that does not fit a counted reason is a
failure, not a skip.*

### N4 — "Thirteen features" and "twelve features" are both the wrong number for the sentence they appear in — NON-BLOCKING

D3c (`plan.md:135`) and `4d0dbb9`'s message say the decision "overturns **thirteen** features of
the kit's own practice". `notes.md:397-403` corrects this to twelve, on the ground that the replay
covered 002–013.

Both are wrong for the claim. `main` carries **thirteen** merged `NNN-*` branches (001 through
013); the replay covered **twelve** of them; and only **nine** produced a single flag (005–013
minus none — 002, 003, 004 and 001 are all clean). So: thirteen features exist, twelve were
replayed, nine exhibit the practice D3c overturns. "Twelve" is right about coverage and wrong
about practice, which is what the sentence is about.

Two things are right here and should not be lost in the fix. The implementer replayed 001 out of
scope for T020 ("006 onward") and found nothing, so the omission costs SC-004 nothing — I
confirmed 001 independently: `graded 3 of 3`, 0 flags. And the refusal to self-amend the approved
plan, with constitution I cited as the reason, is the correct call and the right precedent.

*Action: owner — fold the correction into `plan.md` D3c with an approver line if you think it
worth an amendment, using "nine of the thirteen merged features" or "the twelve features
replayed", whichever the sentence means. Implementer — state the three numbers separately in
`notes.md` so the next reader cannot conflate coverage with practice.*

### N5 — The replay's scope deviates from T020 in both directions, unrecorded — NON-BLOCKING

T020 says "this repository's merged feature branches (**006 onward**)" — eight features. The
replay covered 002–013 — twelve, four more than asked and one fewer than exist. Widening is
strictly better and needs no permission; both deviations should nonetheless be one line in
`notes.md`, because SC-004's subject is "this repository's merged history" and a reader currently
cannot tell which history was read. The branch-range derivation is also unrecorded: I had to
re-derive the twelve base/tip pairs from `main`'s merge commits to check the numbers, and they are
the premise of every figure in the SC-004 section.

*Action: implementer — record the twelve ranges (feature, base, tip, commits) in `notes.md`, note
that 001 was replayed separately with 0 flags, and note that T020's "006 onward" was widened.*

### N6 — `4d0dbb9` ticked T020–T025 two days before the commit that did T023–T025 — NON-BLOCKING

`4d0dbb9` (2026-09-14) flips all six of T020–T025 to `[x]`. `502cf55`, which performed T023
(wording), T024 (batching) and T025 (re-run), is dated 2026-09-16 and `notes.md:485` dates the
T025 re-run to 2026-09-16. So for two days `tasks.md` asserted completion of work that had not
happened, in a commit whose exemption from the approver rule rests on its `tasks.md` hunk being
nothing but completion state.

The check is right to exempt it — D3/D3c are about text, not truthfulness, and the constitution's
"Progress is not amendment" says so. But this feature's own argument for the checkbox exemption is
that a tick is "unambiguous to a machine"; a tick that runs ahead of the work is the case where
that stops being true, and it happened on the feature that makes the argument.

*Action: implementer — tick a task in the commit that completes it. No change to the check.*

### N7 — J12 persists: the D2b probe still asks whether the parent *mentions* the function — NON-BLOCKING

The fourth review's J12 asked for `-match '^\s*function\s+Invoke-AmendmentAuthorityCheck\b'` per
line. `:717` is `git grep -l -F -e 'function Invoke-AmendmentAuthorityCheck'` — the same
substring test, at the same hard-coded path. A mention in a comment, a doc block or a
`notes.md`-style quotation inside the pack satisfies it; a whitespace change inside the `function`
line defeats it. Previously reported and still open; recorded so it is not lost, not re-argued.

*Action: implementer — `git grep -l -E '^[[:space:]]*function[[:space:]]+Invoke-AmendmentAuthorityCheck\b'`
costs nothing and is the fix J12 already specified.*

### N8 — J7, J8, J9 and J10 remain open — NON-BLOCKING

The fourth review's four non-blocking classifier findings are untouched by `502cf55` and I
re-confirmed each by reading the code rather than re-running fixtures: a deletion-only amendment
still has no legal way to be green (`:906-913` puts a `D` row in `$amended`, and
`Get-AddedRecordLines` can find nothing there — J7, and the message N2 complains about now makes
it worse); `Get-VisibleFromText` (`:740-750`) still strips only HTML comments, so a filled record
inside a ``` fence is a grant (J8); `:809`'s neutraliser now accepts `\d+\.` but not `\d+)` or
`+` (J9 — partly closed); and `$script:AmendmentRecordPattern` (`:651`) still rejects a record
written as a list item (J10). None was tasked in phase 3, so this is a carry-forward note, not a
defect of this phase.

*Action: owner — decide whether these land in phase 4 or a follow-up row; they are law-surface
questions as much as code ones.*

### N9 — `-ReplayTip` without `-ReplayBase` silently grades `HEAD..<tip>` — NON-BLOCKING

`:856` builds `$range = "$ReplayBase..$ReplayTip"`. With `-ReplayTip` given and `-ReplayBase`
omitted the range is `..<tip>`, which git reads as `HEAD..<tip>` — a quietly different analysis
from the one the caller asked for. Analysis-only, so it cannot weaken a gate, but a replay is
evidence and a footgun in the tool that produces evidence is worth one guard.

*Action: implementer — require both or neither, and say which range is being graded (the count
line already prints `$range`, which is how this is visible at all).*

### N10 — Phase 3's Territory names `tasks.md` but not `plan.md`, which T022 required it to amend — NON-BLOCKING

Phase 3's declared Territory is `scripts/enforcement-pack.ps1` and
`specs/014-amendment-authority/tasks.md`. T022 requires the exemption decision to land "as an
amendment to `plan.md` carrying its own approver line", which `4d0dbb9` duly does — a file the
phase never declared. It passes only because `4d0dbb9` carries no `phase N` token and
`scope-check` reports "not applicable", so the 006 mechanism never looks. The kit's own rule
(`.specify/templates/tasks-template.md`) is that a Territory widening lands in its own commit
before the work that needs it; here the work the plan *mandated* sat outside the declaration from
the start.

*Action: implementer — when a task's text requires touching a file, declare it. No re-work needed
for this phase.*

## Amendments in this diff

Not "none". One amendment, and it is load-bearing.

- **`4d0dbb9` — `specs/014-amendment-authority/plan.md`**, adding decision **D3c** ("A task's
  text is fixed at approval"). Record: `**Amendment approved by**: anas.m, 2026-09-14.`, and the
  commit message body carries "Amendment approved by: anas.m, 2026-09-14." — conforming, and
  graded rather than skipped (I confirmed: `-ReplayBase 4d0dbb9^ -ReplayTip 4d0dbb9` →
  `graded 1 of 1`, no failure).
- The same commit's `tasks.md` hunk is checkbox-only (T020–T025 ticked) and is exempt under D3.
  See N6 on *when* it ticked them.
- **What the record verifies and what it does not.** D3c reverses the kit's practice across every
  feature it has shipped, on the strength of a replay the same session ran, classified and
  decided. The approver name is the repository owner and is also the commit author, because the
  agent commits as its owner; the kit records no link between a commit and the session behind it
  (constitution I, "What can be verified"). So the record is a written claim, correctly formed,
  and gate 6 is where someone judges whether the owner actually agreed to overturn thirteen
  features of practice. This reviewer verified the record's form, the evidence behind it (B4/B5
  notwithstanding, the `tasks.md` class judgement is right), and nothing about the consent.
- `593c5e3` and `be27bbc` touch `notes.md` only, which is not a graded document.
- **Not an amendment, but it should be visible to gate 6**: `notes.md:397-403` records a
  correction to an approved document (`plan.md` D3c's "thirteen") that the implementer
  deliberately did **not** apply, citing constitution I. The approved plan therefore carries a
  figure its own author believes wrong. That is the right process and an open item for the owner
  (N4).

## Constitution re-check (post-implementation)

**FAIL** — on I, and on VIII.

- **I Specification First** — the workflow order held and the phase's own amendment carries a
  conforming record ✔. But the check the feature ships **contradicts this principle's own scope
  sentence** for the approval commit (B5), and the approved `plan.md` carries a factual claim its
  author has recorded as wrong (N4). FAIL, remediable.
- **II Source of Truth** — no ladder change; the check reads commits and feature documents.
  PASS.
- **III Repository Separation** — single-repo kit; FitForge was read and never written. PASS.
- **IV Architecture Consistency** — four new helpers inside the existing script, no new file in
  `scripts/`, no packages, and `Test-AmendmentCheckPresent` retired rather than duplicated.
  PASS, and the retirement is the right call.
- **V Domain Invariants** — N/A.
- **VI Security** — read-only, no secrets, no network, no shell interpolation. One new
  untrusted-input path: commit-message text is now parsed as delimited data (B1). PASS with B1
  as a robustness defect rather than a security one.
- **VII External Integration Governance** — N/A.
- **VIII Testing Requirements** — "a wrong PASS leaves the rule exactly as unenforced as it is
  today". B1, B2 and B3 are three wrong PASSes, and the 33-scenario suite returned no verdict
  change across a rewrite that introduced all three. FAIL.
- **IX Human Review** — this review is gate 5, held for the first time on this phase; gate 6 at
  merge. PASS in process.
- **X Controlled Delivery** — one phase, one file, revertible; `Gate Batching: none` and
  `Gate Certification: ci-held` honoured; the triplet in `notes.md:523-535` names run
  35059554648 on `502cf55` with a push event, and the note on assembling it is exactly right.
  PASS.

## Test coverage observed

No test framework (kit convention since 006). Three layers, and the middle one is where the gap
is.

- **Fixtures (33 scenarios: S1–S14 + S9b + N1–N3, A1–A7, J1–J7).** Re-run by the implementer
  after the batching with no verdict change, per `notes.md:483-504`. I did not execute that
  suite. I independently rebuilt six of its scenarios on my own fixtures — S9, S10, S13, D4, H3
  and J2 — and all six return the specified verdict after the batching. The suite's own
  pass/fail filter had to be narrowed during this phase because the check learned to print a
  status line; that is the second time this suite has had a harness bug, and it is worth noting
  that a harness which greps for a name rather than a verdict was passing 33 of 33 while B1, B2
  and B3 were live. **The suite contains no fixture whose input is malformed rather than
  merely wrong** — no control characters, no non-ASCII paths, no unreadable refs — which is
  exactly the space the batching moved into.
- **Replay (T020/T021).** The strongest layer and the only one not authored by the implementer.
  Both ranges reproduce to the commit under my own derivation: FitForge 001 at 23/25 graded and
  14 flags, this repository at 67 flags over 121 graded commits. Its weakness is not the run but
  the record (B4, B5, B6).
- **Instrumentation (T024).** Reproducible and correct: 71/97 → 20/45 by my own shim, against
  66/89 → 20/43 claimed on a shorter branch. This closes J11.

## Residual risk

The risk has moved. Rounds 3 and 4 found it in the classifier; after four rounds of work there I
could not break the classifier on any well-formed input. It now sits in two places.

**In the new plumbing layer (`:661-735`).** All three code findings live there, and all three
share one root cause: the batched reads trust their inputs and discard their errors. Message text
decides which commits exist (B1), path text decides which files are graded (B2), and one git
error decides whether the check runs at all (B3) — each with `2>$null` over the top. The common
fix is the same in all three: enumerate the truth from the object graph, then assert that the
batch covered it, and fail rather than skip on any gap. That is cheaper than the three individual
patches and it is what would make a fourth instance of this class impossible.

**In the evidence.** SC-002 and SC-004 are the criteria that justify shipping, and both are
recorded in a form a reader cannot check: no per-flag judgement (B4), one class never adjudicated
(B5), the headline table naming the wrong commit (B6). The substance behind them is sound — I
verified it — which is precisely why the record should match it. Fixing the record is a
`notes.md` edit and costs nothing but care; B5 is the only one that may need an owner decision and
a plan amendment.

**What must happen before merge**: B1, B2 and B3 fixed and re-verified on inputs the implementer
did not choose; B4 and B6 written into `notes.md`; B5 decided by the owner and recorded under
T022. Phase 4 then has one extra obligation it does not currently carry: if B5 resolves as (3),
the spec templates must stop telling authors to make an edit the check refuses.

**What can follow merge**: every N finding, though N2 and N3 are near-free and would improve the
first message an adopter ever sees from this check.
