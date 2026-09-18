# AI Code Review — 014 Amendment Authority (phase 2 remediation)

**Reviewer**: fresh-context agent — claude-opus-5
**Date**: 2026-09-13
**Branches**: agentic-sdlc-kit `014-amendment-authority` (tip `f3e8ece`; amendment `61c57d5`,
remediation `4b846ae`, correction `f3e8ece`)
**Scope reviewed**: `git show 61c57d5`, `git show 4b846ae`, `git show f3e8ece` in full;
`scripts/enforcement-pack.ps1` at HEAD (lines 85-90 and 636-830 read line by line, plus the
dispatch at 849); `scripts/ritual-checks.ps1`; `scripts/scope-check.ps1` (`-All` path);
`scripts/claim-feature.ps1` (renumber block); `.github/workflows/ritual-checks.yml`,
`project-gate.yml.template`, `code-repo-scope-check.yml.template`;
`.specify/memory/constitution.md` Principle I (Amendment authority, Progress is not amendment,
What can be verified) + SYNC IMPACT REPORT; `specs/014-amendment-authority/{spec,plan,tasks,notes}.md`;
all three prior reviews. Executed: **17 fixture repositories of my own construction** under
`…/scratchpad/jrev/` (see "Fixtures" below), a real-history counterfactual replay of `61c57d5`,
a simulated `pull_request` merge-preview CI run, and a deterministic git-call instrumentation of
three pack versions. The implementer's `scratchpad/seed.ps1` and `scratchpad/attack-verify.ps1`
were **not executed and not relied on**; every verdict below was produced by a fixture I built.

**Feature contract**: read-only; `git` plumbing only; zero new dependencies; no new file in
`scripts/`; every pre-existing pack message byte-identical; the verdict for a given commit must
never change with the calendar or the machine (plan, Technical Context + D6).

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5
- **Implementer**: claude-opus-5 (the session that produced the remediation)
- **Inputs provided**: `61c57d5`, `4b846ae`, `f3e8ece`, `spec.md`, `plan.md`, `tasks.md`,
  `notes.md`, the three prior reviews (`ai-code-review-phase-1.md`,
  `ai-code-review-phase-1-remediation.md`, `ai-code-review-phase-2.md`), and both fixture
  suites (`scratchpad/seed.ps1`, `scratchpad/attack-verify.ps1`)
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — 6 blocking, 8 non-blocking.

The seven shapes the third review demonstrated **are** closed, and I confirmed each one
independently rather than taking the table in `notes.md` on trust: a record inside a closed HTML
comment now fails, a `**Territory**` bullet moved between phase blocks now fails, a
rename-plus-rewrite of a contract now fails (`R098`), a record parked in `notes.md` no longer
approves a change to `plan.md`, a recycled record line no longer counts (the `-contains` test is
case-insensitive, so the obvious case-flip bypass does not work either), an approver named only
by the mandated `Co-Authored-By` trailer now fails, and the date comparison is now pure text.
CRLF blobs, files with no trailing newline, and indented record lines are all handled. That is
real work and it is not cosmetic.

But the count is not the story and neither is the pass rate. Three of the six fixes bought their
closure by tightening a predicate one notch past the law, and each has produced a **demonstrated
false FAIL on a legitimate shape** — two of them regressions against `14cf1d6`, which was green
on exactly those inputs. The most serious is J1: the H5 rule "the record must be absent from the
parent" rejects an identical, conforming record from a second amendment by the same approver on
the same day. That is the kit's own convention (`013/plan.md` carries three identical lines), and
it already bites **this branch**: in `61c57d5`, the records added to `plan.md` and to `tasks.md`
are both discarded as "pre-existing", and the commit is green only because it happened to amend
`spec.md` too, where no filled record existed yet. Strip the `spec.md` hunk and the same
amendment goes red (J1, reproduced against real history).

The second serious class is J2: the SC-006 short-circuit. It tests `HEAD^` once and returns from
the whole check if the literal is absent — which makes the boundary non-monotonic in the *unsafe*
direction. On a `pull_request` event the checked-out HEAD is a merge preview whose first parent
is **`main`**, so until this feature lands on `main` the amendment member grades **nothing** on
the PR run of `ritual-checks` — the run that branch protection requires and that a ci-held gate
cites. Demonstrated: a silent amendment that `14cf1d6` catches is reported `OK` by the remediated
pack in that shape. It fails open, and it fails open in complete silence — no line, no warning,
no `n/a`. The prior review raised the silence as H11 (non-blocking); the remediation widened the
hole without addressing it.

Residual risk therefore sits where it sat last round — entirely in the classifier, not the
plumbing — but it has changed sign. The check now over-refuses as readily as it under-refuses,
and every finding below is a localized predicate with a concrete, cheap fix. Nothing in the
commit walk, the D2b concept, `-IgnoreAmendmentBoundary`'s reachability, the scope discipline or
the `f3e8ece` correction is wrong.

**On the process**: this is the fourth REQUEST CHANGES on one feature. That curve is itself a
finding (J14), not a proof of diligence: the implementer's suite passed 18/18 before the third
review and, by the commit message, passes again now, because the same author still owns both the
check and its tests — the third review's own lesson, applied one round later. Every finding below
was produced by a fixture the implementer did not write.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-004/005/009/011 and SC-001 hold (fixtures `b1`, `b2`, `h4c`, `renum`, and the Lite-lane path, unchanged). **FR-002 violated** by J1 (a conforming record on the amended section is discarded). **FR-010 violated** by J3 (a renumbered branch is graded as an amendment — `renum` fixture, `R080` on `spec.md`). **FR-006** still partly open (J6, a task moved between phases while ticked). **FR-008** weakened by J1/J7 (the message tells the developer to add a line that is already there, or to a file that no longer exists). |
| The seven claimed closures, re-verified independently | Fixture `closed`: A1 record in a closed `<!-- … -->` → **FAIL** ✔; A2 `**Territory**` bullet moved phase 2 → phase 1 → **FAIL** ✔; A4 record parked in `notes.md` → **FAIL** ✔; A6b approver `Claude` named only by `Co-Authored-By` → **FAIL** ✔. Fixture `h3r`: contract renamed **and** rewritten → `R098` → **FAIL** ✔. Fixture `h5case`: a genuinely moved record line → **FAIL** ✔, and the case-flipped variant (`ada` → `Ada`) also **FAIL** ✔ (PowerShell `-contains` is case-insensitive; the obvious bypass is closed). Fixture `d5` C6: approver `Al` vs the word "Also" → **FAIL** ✔. H6: date comparison is now `%ad --date=short` string comparison, machine-independent by construction (read at `:748`). |
| New holes found | 6 blocking, demonstrated with runnable fixtures — J1 (false FAIL, real history), J2 (fail-open, regression), J3 (false FAIL, regression), J4 (false FAIL on the commit subject), J5 (H1 open for an unterminated `<!--`), J6 (H2 open for a moved-and-ticked task line). |
| False-FAIL regression sweep against `14cf1d6` | `git show 14cf1d6:scripts/enforcement-pack.ps1` saved and run against every fixture. Verdict *changed for the worse* in three: `renum` (OK → FAIL), `sc2` (FAIL → OK), the PR merge-preview shape (FAIL → OK). Verdict changed for the better in the seven A-shapes. No pre-existing pack message changed in any fixture. |
| `-IgnoreAmendmentBoundary` reachability (D2c) | `grep -rn IgnoreAmendmentBoundary` over the tree: five hits, **all** in `scripts/enforcement-pack.ps1` (`:89`, `:757`, `:767`, `:769`, `:849`). `scripts/ritual-checks.ps1` builds the member argv at lines 63-70 and passes only `-Root` and `-Branch`. `.github/workflows/ritual-checks.yml` invokes `./scripts/ritual-checks.ps1 -Branch $env:RITUAL_BRANCH` and nothing else; `project-gate.yml.template` and `code-repo-scope-check.yml.template` never invoke the pack at all. Semantics checked as well as reachability: the switch sets `$graded = $true` (`:769`), which **only widens** grading — it can add failures, never remove them, and it cannot reach the early-return path. **No gate path passes it; it cannot weaken enforcement.** PASS. |
| Scope discipline (`4b846ae`) | `git show --stat 4b846ae` = `scripts/enforcement-pack.ps1` + `specs/014-amendment-authority/notes.md`. Phase 2 Territory is `scripts/enforcement-pack.ps1` + `scripts/scope-lib.ps1`; the feature's own spec directory is implicitly in territory (`scripts/scope-check.ps1` header, "Matching"). `scope-check.ps1 -All` reports `PASS phase 2 commit 4b846ae (2 file(s))`. `scripts/scope-lib.ps1` declared and untouched — permitted, and `notes.md` says so. **In scope.** PASS. |
| The `f3e8ece` correction | Reproduced exactly: `pwsh -File scripts/scope-check.ps1 -All -Branch 014-amendment-authority` grades every phase-token commit individually and prints `PASS` for all eight, with the same shas and the same file counts as the table in `notes.md` (7, 1, 2, 10, 2, 3, 1, 2). `scripts/ritual-checks.ps1:66` passes `-All`, so CI runs that path. **The correction is accurate**; the earlier "displacement" claim was indeed wrong. See J13 for the one residual imprecision. |
| Runtime (SC-006) | **Not reproducible on this machine** — five runs of one pack version ranged 4 834–79 865 ms (16×). Substituted a deterministic proxy: an instrumented copy of each pack version counting `git` invocations on this branch. `370a28b` (no member): 18 calls / 0 pack-blob reads. `14cf1d6` (as shipped): 53 / 13. `4b846ae` (remediated): **60 / 11**. See J11. |
| Security | Read-only. No new git verb (`show`, `rev-list`, `rev-parse` only), no writes, no network, no shell interpolation of untrusted text. `$Parent` and `$Commit` are shas from `rev-list`; `$path` comes from `--name-status` and is passed as a native argument. `Get-VisibleFromText` uses a bounded non-backtracking pattern. PASS. |
| Rollback safety | Reverting `4b846ae` restores `14cf1d6`'s function set exactly (no signature reaches outside the file except the new `param` switch at `:89`, which is optional). No state, no schema. PASS. |
| PowerShell correctness | `$matches[1]` reuse at `:799` is safe: `'^R(\d+)?'` is the last successful `-match` before the read. `-contains`/`-notcontains` (`:685-686`) are case-insensitive — intended here, and it is what closes the H5 case-flip bypass. `Get-VisibleFromText` joining with `` `n `` then splitting on `` `r?`n `` is harmless: `.Trim()` downstream absorbs any residual `\r` (verified on a CRLF blob with no trailing newline, fixture `crlf` → PASS). `$IgnoreAmendmentBoundary.IsPresent` on an unbound switch is `$false`, correct. |
| Constitution / D-decisions | D1, D2, D2b, D2c, D4, D5, D6, D7, D8 each implemented as written. D2c's prohibition ("no gate, no ritual-checks, no CI workflow") holds — verified above. **D2's own rule** ("if F does not exist in C's first parent, C created it") is the one the code no longer implements: `:797-801` substitutes a rename-similarity heuristic, which is J3. |

### Fixtures

All under `C:\Users\anas.m\AppData\Local\Temp\claude\D--solutions-agentic-sdlc-kit\f9e8f8f3-6d4a-4900-87ea-3de06aeb8c9f\scratchpad\jrev\`.
`lib.sh` seeds a throwaway repo whose `main` already carries the pack (so the D2b boundary is
satisfied and commits are actually graded) with `specs/020-fixture/{spec,plan,tasks}.md`; each
fixture then builds its commit sequence and `runpack <name>` runs the pack against it.

| Fixture | Shape | Expected | Observed |
|---|---|---|---|
| `b1` | conforming amendment | PASS | PASS ✔ |
| `b2` | unrecorded amendment | FAIL | FAIL ✔ |
| `h5ff` | **two conforming amendments, same approver, same day** | PASS | **FAIL** ✘ J1 |
| `real` (`test61`) | `61c57d5` replayed without its `spec.md` hunk | PASS | **FAIL** ✘ J1 |
| `sc2` | function renamed then restored two commits later | FAIL | **OK, nothing graded** ✘ J2 |
| `real` (`prmerge2`) | `pull_request` merge-preview over a silent amendment | FAIL | **OK, nothing graded** ✘ J2 |
| `renum` | branch renumbered 019 → 020 with the mandated header fix | PASS (creation) | **FAIL** ✘ J3 |
| `d5` C4 | approver named in the subject `docs: …, approved by ada` | PASS | **FAIL** ✘ J4 |
| `d5` C5 | approver named in the body line `Note: approved by bob` | PASS | **FAIL** ✘ J4 |
| `h1a` | record after an **unterminated** `<!--` | FAIL | **OK** ✘ J5 |
| `h1b` | record only inside a fenced code block | FAIL | **OK** ✘ J8 |
| `h2a` | task moved phase 2 → phase 1 **and** ticked | FAIL | **OK** ✘ J6 |
| `del` | contract deleted, approver named in the message | reachable PASS | **FAIL, unfixable** ✘ J7 |
| `h4c` | record in an amended contract / in a created contract | PASS / FAIL | PASS / FAIL ✔ |
| `h2num` | `1. [ ]` → `1. [x]` tick | PASS | **FAIL** ✘ J9 |
| `d5` C10 | record written as a list item `- **Amendment approved by**: …` | PASS | **FAIL** ✘ J10 |
| `closed`, `h3r`, `h5case`, `h2ok`, `h2br`, `crlf`, `d5` C1-C3/C6-C9 | the seven closed shapes + name shapes + CRLF | as stated | all as stated ✔ |

## Findings

### J1 — A second amendment by the same approver on the same day is refused — BLOCKING

`scripts/enforcement-pack.ps1:686` — `if ($before -contains $t) { continue }` — discards any
added record line whose trimmed text already appears anywhere in the parent's visible text of
that same file. The record format is `**Amendment approved by**: <name>, <YYYY-MM-DD>`: two
amendments approved by the same person on the same day produce **byte-identical** lines. The
second one is therefore invisible to the check, and the commit is graded as having no record at
all.

This is the kit's own convention, not a hypothetical. `plan.md:23` states it:
"`specs/013-critical-independence-signal/plan.md` carries three
`**Amendment approved by**: anas.m, 2026-09-10.` lines, one per added phase."

Failing input (fixture `h5ff`): commit 1 amends `plan.md` with `**Amendment approved by**: ada,
2026-09-13.` and names `ada` in the message → PASS. Commit 2 amends a *different* decision in the
same file with an identical, equally conforming record and the same message line. Observed:

```text
AmendmentAuthority: commit 9c6768e amends specs/020-fixture/plan.md after approval with no
conforming approver record. Add '**Amendment approved by**: <name>, <YYYY-MM-DD>' to the amended
section and name the same approver in the commit message …
```

The instruction is unfollowable: the line is already there. The only ways to green are to
falsify the date or to alter the approver's name.

**It already applies to this branch.** In `61c57d5` the added record lines are:

| file | added record | present in parent `a976f6d`? | counted? |
|---|---|---|---|
| `spec.md` | `**Amendment approved by**: anas.m, 2026-09-13.` (indented, SC-002) | no | **yes** |
| `plan.md` | `**Amendment approved by**: anas.m, 2026-09-13.` (D2c) | yes (3×) | no |
| `tasks.md` | `**Amendment approved by**: anas.m, 2026-09-13.` (T047 block) | yes (6×) | no |

So `61c57d5` is green on **one** record, found in the one file that happened to lack a prior
filled one, covering two other files whose genuine records were thrown away. Reproduced against
real history:

```bash
git clone . /tmp/real && cd /tmp/real
git checkout -b test61 a976f6d
git checkout 61c57d5 -- specs/014-amendment-authority/plan.md specs/014-amendment-authority/tasks.md
git commit -m "amend 014: … (same message, minus the spec.md hunk)"
cp <HEAD>/scripts/enforcement-pack.ps1 scripts/          # the remediated check
pwsh -NoProfile -File scripts/enforcement-pack.ps1 -Root . -Branch 014-amendment-authority
# → AmendmentAuthority: commit 85d3b8b amends …/plan.md, …/tasks.md … with no conforming approver record
```

This also contradicts the ratified law, which says the amended section **carries** the line
(`.specify/memory/constitution.md:203-205`) and says nothing about the line being textually
absent from the rest of the document.

*Action: make H5 a **count** test, not a text-equality test. A record counts when the file's
visible occurrence count of that exact line is greater in the commit than in its parent — a pure
move leaves the count unchanged (H5 still closed), a genuine repeat increments it. Implementation
is two `Where-Object … Measure-Object` calls in `Get-AddedRecordLines`. Add both shapes to the
fixture table: "second amendment, same approver, same day" (PASS) beside the existing moved-record
case (FAIL).*

### J2 — The SC-006 short-circuit fails open, silently, on an ordinary CI run — BLOCKING

`scripts/enforcement-pack.ps1:770-773`:

```powershell
$headParent = (git rev-parse --verify --quiet "HEAD^" 2>$null)
if (-not (Test-AmendmentCheckPresent -Ref $headParent)) { return }
```

Monotonicity holds only on a linear history in which the check is added once and never moved. The
code returns from the **entire** check — not from one commit — whenever `HEAD^`'s blob of
`scripts/enforcement-pack.ps1` does not contain the literal `function
Invoke-AmendmentAuthorityCheck`. Two demonstrated triggers, one of them entirely non-adversarial:

**(a) Every `pull_request` run until this feature reaches `main`.** GitHub checks out
`refs/pull/N/merge`, whose **first parent is the base branch tip**, i.e. `main`. `main` does not
carry the check. `.github/workflows/ritual-checks.yml` runs on `pull_request` as well as `push`,
and `ritual-checks` is the required status check. Fixture (`…/jrev/real`, branch `prmerge2`): a
branch commit that silently appends a decision to `plan.md` with no record anywhere, merged into
`origin/main` with `--no-ff` to reproduce the merge preview.

```text
HEAD^ = ab847ca (origin/main); check present in HEAD^? 0
  remediated (4b846ae):   enforcement-pack: OK          <-- grades nothing
  pre-remediation (14cf1d6): enforcement-pack: FAIL (1 issue(s)):
      AmendmentAuthority: commit d3c2fb4 amends specs/014-amendment-authority/plan.md …
```

The same commit on the `push`-event shape (HEAD = branch tip) fails under both versions, so the
two CI runs of the same required check now disagree — and the blind one is the one that gates the
merge. An adopted project whose `project-gate`/`ritual-checks` wiring keeps only the
`pull_request` trigger (which `project-gate.yml.template` explicitly suggests, "trim the
pull_request trigger if CI minutes matter") gets the blind one permanently, until the update that
delivers the check is itself on `main`.

**(b) Any commit in range that removes, renames or relocates the function or the script.**
Fixture `sc2`: commit 1 amends `plan.md` silently (FAIL under both versions when it is HEAD);
commit 2 renames the function; commit 3 restores it. `HEAD^` is now commit 2.

```text
pre-remediation (14cf1d6): FAIL — AmendmentAuthority: commit dc30005 amends …/plan.md …
remediated (4b846ae):      OK
```

Note what "fails open" means here in practice: the pack prints **nothing**. No warning, no
informational line, no `n/a`. A run that graded 0 of 13 commits is byte-identical, in the output,
to a clean branch — which is exactly H11 from the third review, left open and now load-bearing.

*Action: (1) delete the `HEAD^` early return. The per-commit test at `:779-781` already memoizes
(`$graded = $true`), so the common case — a branch whose base already carries the check — costs
**one** blob read anyway, which is all the short-circuit was buying. If a cheaper bound is still
wanted, resolve it from the branch **base** (`Test-AmendmentCheckPresent -Ref $Base`), the end of
the range where "absent" really does imply "absent for everything earlier", never from `HEAD^`.
(2) Implement H11's informational line: `AmendmentAuthority: N commit(s) predate the check and
were not graded (plan D2b)` — a check that can grade nothing must say so out loud. (3) Add the
merge-preview shape to the fixture table; it is the shape CI actually runs.*

### J3 — A renumbered branch is now graded as an unapproved amendment — BLOCKING

`scripts/enforcement-pack.ps1:797-801`:

```powershell
if ($status -match '^A') { continue }
if ($status -match '^R(\d+)?') {
    $sim = if ($matches[1]) { [int]$matches[1] } else { 100 }
    if ($sim -ge 100) { continue }
}
```

H3 asked for rename-plus-rewrite to stop escaping, and it does. But the fix replaced D2's stated
rule — *"if F does not exist in C's first parent, C created it"* — with a similarity threshold,
and that breaks the edge case the spec calls out by name:

> **A branch renumbered by a lost claim race.** `claim-feature.ps1` renames the branch and the
> spec directory; every feature document appears as added-at-a-new-path. **This MUST read as
> creation**, not as an unapproved amendment of the old path. — `spec.md`, Edge Cases

and FR-010 ("Branch renumbering, rebases and merge commits MUST NOT be graded as amendments") and
plan D2 ("a branch renumbered by a lost claim race reads as creation at the new path").

A pure directory rename is `R100` and still passes. But the renumber is not content-neutral: the
spec template's header line `**Feature Branch**: \`NNN-name\`` names the number, so the commit
that renumbers also fixes the header. Failing input (fixture `renum`): `specs/019-old/` →
`specs/020-fixture/` with the one header line corrected.

```text
R100  specs/019-old/plan.md   specs/020-fixture/plan.md
R080  specs/019-old/spec.md   specs/020-fixture/spec.md
R100  specs/019-old/tasks.md  specs/020-fixture/tasks.md

remediated (4b846ae):      FAIL — AmendmentAuthority: commit 8aef28e amends
                                   specs/020-fixture/spec.md … with no conforming approver record
pre-remediation (14cf1d6): OK
```

There is no legal way to green it: the developer must record an approver for a document that has
never been approved at that path, on a rename forced on them by someone else's claim.

*Action: restore D2's rule and disambiguate by **source path**, not by similarity. A rename row is
an amendment when the old path is inside this feature's own `specs/<branch>/` directory (the H3
attack: `contracts/auth.md` → `contracts/authz.md`); it is creation when the old path lies outside
it (a renumber, or a document moved in from `docs/`). Equivalently, keep asking D2's question —
does the **new** path exist in the parent? — and treat an intra-directory rename as a same-document
amendment. Both fixtures then pass: `h3r` FAILs and `renum` PASSes.*

### J4 — The D5 body filter discards the commit subject — BLOCKING

`scripts/enforcement-pack.ps1:825-826`:

```powershell
$message = (@(git show -s --format=%B $commit 2>$null) |
    Where-Object { $_ -notmatch '^[A-Za-z-]+:\s' -or $_ -match '^\s*$' }) -join "`n"
```

The predicate is meant to drop git trailers. It drops any line of the form `Word: …`, and the
**subject line** of most commits in this repository is exactly that shape: `docs:`, `spec:`,
`plan:`, `fix:`, `chore:`, `feat:`. The law says "the amendment commit names the same approver"
(`.specify/memory/constitution.md:204-205`) — the subject is part of the message, and it is the
one part every commit has.

Failing inputs (fixture `d5`, ten amendments in one branch, one pack run):

| # | record name | commit message | expected | observed |
|---|---|---|---|---|
| C4 | `ada` | subject `docs: widen the plan, approved by ada`, no body | PASS | **FAIL** |
| C5 | `bob` | body line `Note: approved by bob on a call.` | PASS | **FAIL** |
| C6 | `Al` | body `Also widened the decision block.` | FAIL | FAIL ✔ |
| C7 | `carol` | body `Approved by: carol, in writing.` | PASS | PASS ✔ |
| C8 | `dave` | only `Signed-off-by: dave <…>` | FAIL | FAIL ✔ |

```text
AmendmentAuthority: commit c9abee4 records 'ada' as the approver of its change to
specs/020-fixture/plan.md, but its commit message does not name them …
```

The message is false — the commit message names `ada` in its subject — which makes the failure
undiagnosable without reading the script, the thing FR-008 exists to prevent.

The whole-word boundary itself is sound and I could not break it: names with spaces
(`Ada Lovelace`), an apostrophe (`O'Neil`) and non-ASCII letters (`José García`) all match
correctly (C1-C3 PASS), and `.NET`'s `\w` is Unicode-aware so the lookarounds behave for accented
names. The filter, not the boundary, is the defect.

*Action: never filter the subject — apply the trailer filter to the message body only
(`%B` minus its first line, or better `git show -s --format=%s` matched separately from
`--format=%b`). Tighten the trailer predicate to git's own definition (`^[A-Za-z][A-Za-z-]*:\s`
appearing in the final paragraph of the message) instead of to every line in the message. Add C4
and C5 to the fixture table as PASS cases.*

### J5 — H1 is open for an **unterminated** `<!--` — BLOCKING

`scripts/enforcement-pack.ps1:659-664`:

```powershell
$raw = ($Lines -join "`n")
return ([regex]::Replace($raw, '(?s)<!--.*?-->', '')) -split "`r?`n"
```

The non-greedy pattern requires a closing `-->`. An HTML comment opened and never closed hides
**everything after it** in every markdown renderer, GitHub included — but strips nothing here, so
the text stays "visible" to the check.

Failing input (fixture `h1a`): a commit appends to an approved `plan.md`

```text
**D3 — a silently widened decision.** Nobody approved this.

<!--

**Amendment approved by**: ada, 2026-09-13.
```

with `Amendment approved by: ada, 2026-09-13.` in the message. Observed: `enforcement-pack: OK`.
The rendered `plan.md` shows a widened decision and no approver anywhere — the H1 shape, one
character cheaper than the version that was fixed.

This is inherited from `Get-VisiblePlanLines` (`:152-156`), so the same one-character evasion
applies to the `**Delivery Level**`, `**Gate Batching**` and `**Gate Certification**` readers —
worth fixing in one place.

*Action: treat an unterminated opener as running to end of text — `'(?s)<!--.*?(-->|$)'` — and,
since `Get-VisibleFromText` and `Get-VisiblePlanLines` are now the same two lines twice, collapse
them into one helper so the rule cannot drift again. Add the unterminated-comment scenario to the
fixture table beside the closed one.*

### J6 — H2 is open for a task line moved between phases while ticked — BLOCKING

`scripts/enforcement-pack.ps1:714-719`. The pairwise test exempts a pair whose stripped text
matches and whose raw text differs. A task line *moved into another phase's block* and *ticked in
the same commit* produces exactly that: one deletion and one insertion of the same task with a
different marker.

Failing input (fixture `h2a`): `tasks.md` declares `T003` under phase 2; one commit moves it into
phase 1's block and ticks it, subject `phase 1: tick T003`, no record anywhere.

```text
@@ -11,0 +12 @@
+- [x] T003 Do the third thing
@@ -19 +19,0 @@
-- [ ] T003 Do the third thing

enforcement-pack: OK
```

Phase 1 now owns a task phase 2 was approved to own. The constitution's exemption is "a change to
`tasks.md` that alters nothing but task completion state" (`:208-210`); this alters which phase
the work belongs to, and on a Micro feature it also moves work across the lane's one-phase bound.
The `**Territory**` variant of the same shape *is* closed (verified, fixture `closed` A2) —
because a Territory bullet has no marker, so its raw text cannot differ while its stripped text
matches. Task lines are the residue.

*Action: pair by position **within each hunk**, not across the whole diff, and require every pair
to come from the same hunk. A move is one hunk with a lone `-` and another with a lone `+`; a tick
is a `-`/`+` pair inside one hunk. `git show -U0` already gives the hunk boundaries (`@@` lines)
— the parser at `:700-708` currently discards them.*

### J7 — A deletion-only amendment has no legal way to be green — NON-BLOCKING

H4 narrowed the record search to `$amended` (`:813`). A file the commit **deleted** is in
`$amended` (status `D` matches neither `^A` nor `^R`) but contributes no added lines, so a commit
whose only graded change is a deletion can never supply a record.

Failing input (fixture `del`): a commit that retires `specs/020-fixture/contracts/auth.md`, with
`Amendment approved by: ada, 2026-09-13.` in its message.

```text
D  specs/020-fixture/contracts/auth.md
AmendmentAuthority: commit 370a570 amends specs/020-fixture/contracts/auth.md after approval with
no conforming approver record. Add '…' to the amended section …
```

"The amended section" no longer exists. A workaround does exist — amend `plan.md` in the same
commit and put the record there, which is arguably the right thing to do anyway — so this is
non-blocking, but the message points at an impossibility. The neighbouring case behaves the same
way for the same reason: a record placed in a contract the commit *created* is not searched
(fixture `h4c`, second commit → FAIL), while a record in a contract it *amended* correctly covers
the whole commit (first commit → PASS).

*Action: when the commit's graded set contains only deletions, search the record across the
feature's other graded files the commit touched (including created ones), or state the constraint
in the failure message: "the record must be added to a file this commit modifies".*

### J8 — A record inside a fenced code block counts as a grant — NON-BLOCKING

`Get-VisibleFromText` strips HTML comments and nothing else, and
`$script:AmendmentRecordPattern` anchors at the start of the line. A filled example inside a
```` ```text ```` fence therefore reads as a real record. Fixture `h1b`: a commit silently widens
a decision and, in the same diff, adds a fenced block "Example of the record format:" containing
`**Amendment approved by**: ada, 2026-09-13.` → `enforcement-pack: OK`.

Lower severity than J5 because the text *is* rendered, but this is how documentation of the record
format becomes an approval — plausible in `plan.md`, in `adoption/updating.md`'s future examples,
and in the templates.

*Action: skip lines inside fenced code blocks when collecting record candidates (track ``` / ~~~
state while walking the visible lines). Cheap and self-contained.*

### J9 — An ordered-list checkbox tick is not exempt — NON-BLOCKING

`:704`/`:707` strip only `^(\s*[-*]\s*)\[[ xX]\]`. GitHub-flavoured Markdown also accepts task
items in ordered lists. Fixture `h2num`: `1. [ ] T001 …` → `1. [x] T001 …` is graded as an
amendment. Pre-existing (D3's regex is unchanged by this diff), and the kit's own templates use
`- [ ]`.

*Action: widen to `^(\s*(?:[-*+]|\d+[.)])\s*)\[[ xX]\]`, or state in the constitution that a task
item is a `-`/`*` list item.*

### J10 — A record written as a list item is not recognised — NON-BLOCKING

`$script:AmendmentRecordPattern` anchors on `^\*\*Amendment approved by\*\*`. Indentation is fine
(`Get-AddedRecordLines` trims — fixture `d5` C9 PASSes, and `61c57d5`'s own indented `spec.md`
record is what carries that commit), but a leading list marker is not: `- **Amendment approved
by**: fred, 2026-09-13.` fails (fixture `d5` C10). Neither the constitution
(`:203-205`) nor the failure message says the line must be its own unmarked paragraph.

*Action: allow an optional leading list marker in the pattern, or say so in the clause and in
`$script:AmendmentRecordExample`.*

### J11 — The SC-006 claim is not reproducible and the stated mechanism does not account for it — NON-BLOCKING

`notes.md` ("SC-006, measured at last") and `tasks.md` T054 record **3743 ms → 2719 ms** as fact,
attributing the saving to "the boundary is monotonic, so it is now tested once against `HEAD^`".

I could not reproduce any timing on this machine: five runs of a single pack version ranged
4 834 – 79 865 ms. So I substituted a deterministic proxy — an instrumented copy of each version
counting its own `git` invocations and its 39 KB pack-blob reads, over the same branch and the
same 13-commit range:

| pack version | `git` calls | pack-blob reads |
|---|---|---|
| `370a28b` (no amendment member) | 18 | 0 |
| `14cf1d6` (phase 2 as shipped) | 53 | 13 |
| `4b846ae` (remediated) | **60** | **11** |

Three observations. (1) The mechanism cited saves **2** of 13 blob reads on this branch, because
the per-commit probe at `:779-781` still runs until the first graded commit; a ~1 000 ms saving
from two blob reads contradicts the third review's own measurement of ≈110 ms per commit. (2)
Total `git` invocations went **up**, 53 → 60, because `Get-AddedRecordLines` now issues three
`git show` calls per amended path instead of one per commit. (3) The claim "the check is now
cheaper than the version that did not have it" is not supported by any measurement I can make:
the member still costs 42 extra `git` processes over the pack without it.

The mechanism *is* right for the common case — on a branch whose base already carries the check,
the memoized probe costs one blob read instead of N — but that is a different claim from the one
recorded, and the recorded one is now the feature's evidence for SC-006. (Method, separately: no
run count, no repetition, no variance, and the two versions compared do not do the same work — the
old pack reports FAIL on this branch and the new one OK.)

*Action: re-measure with a stated method (N runs, median, same machine, same HEAD), or downgrade
the claim in `notes.md` and T054 to "the per-commit boundary probe is memoized; blob reads on this
branch fell 13 → 11 and are O(1) on a branch whose base carries the check". T024 is still open in
phase 3 and is the right place for the real number.*

### J12 — The D2b probe still asks whether the parent *mentions* the function — NON-BLOCKING

`:650-655` greps the parent blob for the literal `function Invoke-AmendmentAuthorityCheck` at a
hard-coded path. Carried over from `14cf1d6` and flagged as H11's second observation; unchanged.
It is now more consequential, because J2 made a single negative answer disable the whole check
rather than one commit. A comment, a doc string or a `notes.md`-style mention inside the pack
would satisfy it; a whitespace change inside the `function` line would defeat it.

*Action: fold into J2's fix — once the early return is gone this is back to one commit's worth of
damage. If a stronger probe is wanted, `-match '^\s*function\s+Invoke-AmendmentAuthorityCheck\b'`
per line is one character more expensive.*

### J13 — One residual imprecision in the `f3e8ece` correction — NON-BLOCKING

The correction is **accurate** on its substance and I reproduced its table exactly. One sentence
is still slightly off: *"reading `scope-check.ps1` standalone, which reports the latest phase
commit only"*. Run standalone, `scope-check.ps1` reports on `-Commit` (default `HEAD`) — which on
this branch is `f3e8ece`, a docs commit it calls "not applicable" — not on "the latest phase
commit". The distinction matters only because the sentence is the correction's account of how the
original error arose.

*Action: reword to "reading `scope-check.ps1` standalone, which grades the single commit it is
given (`HEAD` by default)". Non-blocking; the corrected claim itself is right.*

### J14 — Fourth round, same author owning both the check and its tests — NON-BLOCKING / CONFIRM

`notes.md` states the lesson of round three plainly — "my own suite still passed 18 of 18
throughout, because I wrote both the check and its tests" — and then round four was verified with
`scratchpad/attack-verify.ps1`, "my rebuild of the reviewer's shapes", written by the same author.
It reproduces the seven shapes faithfully (I confirmed all seven independently) and finds nothing
else, which is the same structural limitation one level up: a suite built from last round's
findings proves last round's findings.

Every one of J1-J6 came from a fixture built by asking what the *law* permits rather than what the
*fix* forbids, and three of them are simple negations of a fixture the suite already contains
(a second same-day record; a rename that is a renumber; a `word:` subject).

*Action (owner decision): before phase 3, move the fixture table from "scenarios the author
imagined" to a differential harness — run the pre-change and post-change packs over the same
corpus and require that every verdict that changes be justified in `notes.md`. That converts each
round's fixtures into a permanent regression net and would have caught J2 and J3 automatically,
since both are verdict flips against `14cf1d6`. Consider also that phases 3 and 4 will each need a
review; the curve flattens when the tests stop being written by the author of the code.*

## Amendments in this diff

Three commits are under review; `61c57d5` is the amendment, and it lands **before** the
implementation commit it authorises — the correct order, and the mechanism `tasks-template.md`
prescribes.

| Commit | Amended document | Change | Record | Approver named in the commit |
|---|---|---|---|---|
| `61c57d5` | `spec.md` | SC-002 extended: the FitForge-001 replay runs with the boundary lifted; `-IgnoreAmendmentBoundary` named, "no gate ever passes it" | `**Amendment approved by**: anas.m, 2026-09-13.` (indented, inside the SC-002 bullet) | yes — "Amendment approved by: anas.m, 2026-09-13." |
| `61c57d5` | `plan.md` | D2c added (the boundary bounds enforcement, not analysis) | `**Amendment approved by**: anas.m, 2026-09-13.` | yes |
| `61c57d5` | `tasks.md` | phase 2 remediation block added, T047-T055 | `**Amendment approved by**: anas.m, 2026-09-13.` | yes |
| `61c57d5` | `ai-code-review-phase-2.md` (added) | not a graded document | n/a | n/a |
| `4b846ae` | none | `scripts/enforcement-pack.ps1` + `notes.md`; `notes.md` is not in the graded set (D3b) | n/a | n/a |
| `f3e8ece` | none | `notes.md` only | n/a | n/a |

**Does the amendment conform to the rule it amends?** It passes, but not for the right reason.
All three records are genuine, conforming and visible; only the `spec.md` one is *counted*, because
`plan.md` and `tasks.md` already contained byte-identical lines and J1 discards those. D4 ("one
record per commit") then lets that single surviving record legalise all three files. Remove the
`spec.md` hunk and the identical amendment goes red (reproduced above). So the branch's own
compliance is currently an accident of which file had a prior record — which is the sharpest
available statement of why J1 must be fixed before this ships.

The substance of each amendment is sound: D2c is a real owner decision, honestly scoped, and I
verified its central promise independently — no gate, no `ritual-checks` invocation and no CI
workflow passes `-IgnoreAmendmentBoundary`, and the switch can only widen grading.

## Constitution re-check (post-implementation)

**FAIL (remediable).** I PASS as at plan time; II, III, V, VI, VII, IX, X unchanged and
satisfied. **IV Architecture Consistency**: still a function inside an existing script, no new
file, no package — PASS, with one note: `Get-VisibleFromText` duplicates `Get-VisiblePlanLines`
verbatim rather than reusing it, which is how J5's evasion will drift between the two.
**VIII Testing Requirements** is the failing one: the clause names this "business-critical
governance logic — a wrong PASS leaves the rule as unenforced as today, and a wrong FAIL blocks
every branch in every adopted project." This round produced three demonstrated wrong FAILs (J1,
J3, J4) and three demonstrated wrong PASSes (J2, J5, J6), and the validation layer did not find
any of them because it is still authored by the implementer.

## Test coverage observed

No test framework (kit convention since 006). Two suites exist, neither executed by me: the
original 18 scenarios (`scratchpad/seed.ps1`) and the seven-shape attack rebuild
(`scratchpad/attack-verify.ps1`). I built 17 independent fixture repositories under
`…/scratchpad/jrev/` (table above), covering the seven claimed closures, five name/message shapes,
CRLF and no-trailing-newline blobs, two rename topologies, a deletion, a PR merge preview, and a
non-monotonic history. 14 of the 17 reproduce a stated expectation; the other three are J1, J2 and
J3 — each of which I also ran against `git show 14cf1d6:scripts/enforcement-pack.ps1` to
establish that the verdict is a regression rather than a pre-existing gap.

The fixture table in `tasks.md` (S1-S14 + N1-N3 + the A-series) remains the right artifact; it is
missing the six shapes above and the merge-preview topology.

## Residual risk

Concentrated in two places, in opposite directions.

**The check refuses legitimate work** (J1, J3, J4, and J7/J9/J10 at the margin). This is the more
damaging direction on flow-down day: every one of them reds a branch whose author did exactly what
the constitution asks, with a message that describes something other than what happened. J1 is
live on this branch today.

**The check grades nothing and says nothing** (J2, with J12 as its amplifier). Until this feature
is on `main`, the `pull_request` run of the required `ritual-checks` check does not grade
amendments at all — including the run whose URL would be cited as the ci-held evidence for this
very phase. That must be fixed before the gate evidence is recorded, or the evidence certifies a
check that did not run.

Before merge: J1, J2, J3 and J4 are mechanical and localized (a count instead of an equality; a
deleted early return; a source-path test instead of a similarity threshold; a filter applied to
the body instead of the whole message). J5 and J6 are each a few lines. After the fixes, re-run a
**differential** sweep against `14cf1d6` and against `370a28b` over the whole fixture corpus and
record every verdict that changes — that is the artifact this feature has been missing for four
rounds, and it is worth more than the next round of scenarios.
