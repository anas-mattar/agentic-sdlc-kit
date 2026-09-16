# Notes: Amendment Authority (014)

Evidence for this feature: phase results, gate records and findings. Kept out of `tasks.md`
deliberately (plan D3b, owner decision 2026-09-13 on phase 1 review finding F5) — `tasks.md`
holds agreed work and completion state alone, so that a change to it is always either a
checkbox flip or a real amendment. Nothing here is agreed work; nothing here changes what any
task says.

## Phase 1 — wording reconciliation (T004)

Where the kit's clause differs from the FitForge 1.1.0 wording it adopts, and why. Recorded so
the flow-down reconciles instead of colliding (D9).

| Kit 0.7.0 | FitForge 1.1.0 | Why they differ |
|---|---|---|
| Adds **Progress is not amendment** | absent | FitForge wrote the rule against its 001 review, where every failing change was content. The kit's clause has to survive `tasks.md` being touched on nearly every phase commit, so the exemption is stated in the law rather than left to whatever grades it |
| **What can be verified, and what cannot** | **Enforcement, honestly stated** | FitForge's paragraph says the check cannot live in that project because `scripts/*.ps1` is verbatim. The kit can host it, so what survives is honesty about what a check can *see* — including that nothing enforces the self-approval prohibition. FitForge's paragraph stops being true at flow-down and is edited there, by its owner, under its own ritual (T029) |
| Rationale **rewritten**, provenance restored | original wording | Corrected in the phase 1 remediation (F4). The first draft paraphrased the rationale and dropped the date, the "feature 001 governance finding F3" attribution and the named checks — while this table claimed the text had been kept near-verbatim *to preserve provenance*. The record was wrong before the text was. The rationale now carries the date, the attribution and the four checks by name; the sentence order is the kit's, the facts are FitForge's |

The normative clause itself — scope, record shape, same-approver-in-the-commit, and the
self-approval prohibition — is byte-identical to FitForge 1.1.0. Both reviewers verified this
with a direct `diff` rather than by reading.

Two sentences in the kit's rationale have no FitForge counterpart, recorded here because the
first draft of this table did not (second review, G7): the sentence naming the four checks that
stayed green, and the closing "Getting the order right … is a check on retroactivity, not a
check on consent". The first is kit-specific by necessity — those are the kit's scripts. The
second is FitForge's sentence, kept verbatim. The sentence order is FitForge's; only the
opening clause was re-cast to read as the kit's own law rather than as an adopting project's
amendment note.

## Phase 1 — finding: evidence recording sat outside both categories (F5, resolved)

Discovered while executing phase 1, escalated by the phase 1 review, and resolved by the owner
the same day.

The clause exempts exactly one thing: task completion state. But this kit's convention had been
to record a phase's **results inside `tasks.md`** — 013 carries three such sections. Under the
clause as ratified, appending one is an amendment, and the rule would have demanded an approver
for writing down what happened. Worse, as the reviewer showed, this branch's own `ced1302` and
`f49ad61` already amended `tasks.md` with no record, so phase 2's T019 ("this branch must be
green under its own check") was unsatisfiable — and D5 puts half the record in an immutable
commit message, so it could never be retrofitted.

Three candidates were considered:

- **(a) An edit an approved task instructs is execution, not amendment.** Honest, and the
  reading phase 1 acted under, but not machine-checkable — the check would have to know which
  task asked for the edit.
- **(b) Exempt additions that add no task line and delete or modify nothing.** **Rejected**, and
  the reviewer independently confirmed why: a `**Territory**` bullet is a non-task line, so this
  would exempt a widened Territory — one of the five amendments SC-002 exists to catch.
- **(c) Move phase evidence out of `tasks.md`.** **Chosen** (D3b). Cleanest for a machine, and it
  makes the law true as written rather than true-with-an-asterisk. The cost is a kit convention
  change, documented in phase 4.

**This resolved F5 forward, not backward** — a correction to the first draft of this section,
which called F5 "resolved" without qualification. The second review (G2) pointed out what that
hid: `ced1302` and `f49ad61` were already on the branch, each amending `tasks.md` without a
record, and no rule bounded the range the check would grade — so the branch still failed its own
check and T019 was still unsatisfiable. The boundary is D2b, decided by the owner on the second
review: a commit is graded only if the check existed before it was made. Those two commits are
out of scope **by rule, not by exception**, and the same boundary is what makes an adopted
project's update day silent.

## Phase 1 — gate

Certified 2026-09-13 on `ced1302`. The plan declares `ci-held`; the owner also ran the gate
locally on the same commit, which is the stronger of the two and is what certifies the phase.

| | |
|---|---|
| Phase commit | `ced1302` |
| CI run | https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/34756014814 |
| CI conclusion | success |
| Owner-run gate | `pwsh -File scripts/ritual-checks.ps1` → RESULT OK, confirmed by anas.m |
| Scope check | PASS phase 1 commit `ced1302` (7 files) |

`PhaseSizeWarning` on `aa3b194` (the `plan:` commit, 407 lines over two documents) was noted in
that run: seven lines over the guideline, not a phase commit, documents rather than code.

## Phase 1 — review and remediation

The fresh-context review (`ai-code-review-phase-1.md`) returned **REQUEST CHANGES**: 6 blocking,
3 non-blocking. It confirmed clean: the normative clause byte-identical to FitForge 1.1.0, MINOR
correct under the versioning policy, prior history demoted intact, the SYNC IMPACT mirror list
matching the commit, the digest claim, and scope discipline.

The six blocking findings are remediated by T031–T039. Two are worth keeping visible beyond
this feature:

- **F1** — the clause asserted in the present tense that a check graded it, one phase before
  that check existed. The feature exists to end exactly that state, and reproduced it in its
  own first commit. The fix is that the constitution describes what *can* be verified, and the
  SYNC IMPACT REPORT alone says where the machine half lands.
- **F9** — the gate-record commit `f49ad61` carried the words "phase 1" in its subject, so
  `scope-check` treated it as the phase commit and graded it (1 file) instead of `ced1302`
  (7 files). **Rule worth remembering: a non-phase commit must never carry a `phase N` token in
  its subject.** History is not rewritten for this; the remediation commit re-establishes a
  correctly-scoped phase 1 commit, and both remain visible.

## Phase 1 — second review (the remediation of the remediation)

`ai-code-review-phase-1-remediation.md`: **REQUEST CHANGES**, 3 blocking, 10 non-blocking, with
a per-finding roll-up confirming F1, F2, F3, F4, F7, F8 fixed and F6, F9 fixed-as-scoped. It
verified clean: the normative clause still byte-identical to FitForge 1.1.0, the Territory
declaration parsing (`PASS phase 1 commit 0803049`, 10 files) with the warning comment placed
where it provably cannot break parsing, and both amendment commits conforming under D4/D5/D6.

Two findings worth carrying beyond this feature:

- **G1** — a duplicated sentence shipped in the constitution, inside the paragraph the
  remediation was written to repair. The mechanism is worth naming because it will recur: the
  edit anchored on the old paragraph's last sentence, so the sentence *after* it survived. An
  anchor that ends mid-paragraph silently keeps whatever follows.
- **G4** — the amendment commit `6fbffae` carries "phase 1" in its subject while its own
  message states it is not a phase commit. **F9 reproduced, one commit after being recorded.**
  It is already pushed, so history is not rewritten for it. Under `ritual-checks` every
  phase-token commit is graded individually and this one passes — see the correction at the end
  of this file; the defect is a mislabel, not a lost or displaced verdict. The durable lesson is that a rule written in a
  notes file is not a rule anything enforces, which is this feature's own thesis turned on
  itself.

## Phase 1 remediation — gate and the third review that was declined

Round 2 (`370a28b`) closed G1, G2 and G3 plus G6, G10, G11 and G12. `scope-check: PASS phase 1
commit 370a28b (2 file(s))`; local `ritual-checks` RESULT OK; CI green
(https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/34758019912).

**A third fresh-context review was recommended and declined by the owner** (2026-09-13), who
directed the feature to phase 2 instead. Recorded because the reasoning against it was not
weak: round 1 found six blocking findings, round 2 found three more *inside the fix for them*,
and that curve had not flattened. What stands behind the round-2 diff is therefore the owner's
judgement and gate 6's human review of the full feature diff at merge — not gate 5, which this
round does not have. Six non-blocking findings from the second review also remain open (G5 in
part, G9, G13 and the FR-012 reading-table mirror); they are in
`ai-code-review-phase-1-remediation.md` and none of them blocks phase 2.

## Phase 2 — scenario results (T018)

Seeder: `scratchpad/seed.ps1` (rebuildable, not hand-made). Each scenario is a throwaway repo
whose **main** branch already carries the check, so the commits under test have a parent
containing it and are actually graded (D2b). Run 2026-09-13 against `enforcement-pack.ps1`
with `Invoke-AmendmentAuthorityCheck` wired in.

| # | Scenario | Expected | Observed |
|---|---|---|---|
| S1 | creation only | PASS | PASS |
| S2 | conforming amendment | PASS | PASS |
| S3 | amendment, no record | FAIL, names `plan.md` | FAIL, names it |
| S4 | record and message disagree | FAIL | FAIL |
| S5 | empty approver name | FAIL | FAIL |
| S6 | placeholder name | FAIL | FAIL |
| S7 | impossible date | FAIL | FAIL |
| S8 | date after the commit | FAIL | FAIL |
| S9 | checkbox tick only | PASS | PASS |
| S9b | checkbox **un-tick** | PASS | PASS |
| S10 | tick plus a reworded task | FAIL | FAIL |
| S11 | `contracts/` amended, no record | FAIL, names the contract | FAIL, names it |
| S12 | merge commit | PASS (skipped) | PASS |
| S13 | renumbered branch | PASS (creation at new path) | PASS |
| S14 | Micro, `spec.md` alone | FAIL | FAIL |
| N1 | Lite lane, no `specs/` | PASS, silent | PASS |
| N2 | one record, two documents | PASS | PASS |
| N3 | parent predates the check (D2b) | PASS, not graded | PASS |

**S9b and N3 were added during phase 2** and are the two that matter most. S9b is the F2 fix
under test: un-ticking is progress, and the multiset comparison exempts it without a special
case. N3 proves the D2b boundary does what the owner decided — a commit whose parent carries a
pack without the function is skipped, which is what makes an adopted project's update day
silent.

### Two corrections of fact

- **Plan D1 is wrong about novelty.** It says this is "the first pack member with per-commit
  granularity". `Invoke-PhaseSizeWarningCheck` already walks `git rev-list "$Base..HEAD"`. The
  *decision* D1 records — grade commits, not the cumulative diff — stands unchanged and is
  right for the stated reason; only the claim to be first is false. Recorded here rather than
  amended into the plan, because a decision's rationale is not changed by it.
- **T012 anticipated a shared helper in `scripts/scope-lib.ps1`.** None was needed: the commit
  walk is three lines of `git` plumbing already patterned in the same file, and extracting it
  would have coupled two checks for no gain. Phase 2's declared Territory included
  `scope-lib.ps1`; it was not touched.

### A known limit of the S4 message

The fixture table expected S4 to "name both" names. The check names the recorded approver and
states that the message does not name them — it cannot name the *other* name, because it has
no way to know which word in a commit message was meant as a person. Recorded as a limit of
the check rather than a defect of it; the failure is still unambiguous to the person reading it.

## Phase 2 — gate (ci-held)

Certified by the owner 2026-09-13 on the evidence triplet.

| | |
|---|---|
| Phase commit | `14cf1d6` |
| CI run | https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/34758348672 |
| CI conclusion | success |
| Scope check | PASS phase 2 commit `14cf1d6` (3 files) |
| Approved by | anas.m, 2026-09-13 |

**The check is now live on this branch**, which makes every commit from here a test of it. This
very commit is the first: it touches `notes.md` alone, and `notes.md` is not in the graded set
(`spec.md`, `plan.md`, `tasks.md`, `contracts/`). That is D3b working as intended rather than by
luck — evidence recording was moved here precisely so that writing down what happened never
requires an approval.

## Phase 2 remediation — the seven shapes, verified closed

The third fresh-context review (`ai-code-review-phase-2.md`) demonstrated seven false-PASS
shapes with runnable fixtures. The lesson is not the count: **my own suite still passed 18 of
18 throughout**, because I wrote both the check and its tests, so it proved only the cases I
had already imagined. Verification for this round therefore uses the reviewer's shapes, in
`scratchpad/attack-verify.ps1`.

| Attack | Was | Now |
|---|---|---|
| A1 record hidden in an HTML comment | PASS | **FAIL** |
| A2 `**Territory**` bullet moved between phases | PASS | **FAIL** |
| A3 contract renamed and rewritten in one commit | PASS | **FAIL** |
| A4 record parked in `notes.md`, `plan.md` amended | PASS | **FAIL** |
| A5 a pre-existing record recycled | PASS | **FAIL** |
| A6a approver `Al` "named" by the word *Also* | PASS | **FAIL** |
| A6b approver `Claude` named only by the mandated trailer | PASS | **FAIL** |
| A7 conforming same-day record on a `+08:00` commit | red in CI | **PASS everywhere** |

The original 18 scenarios were re-run unchanged and still produce their fixed verdicts — the
hardening cost no legitimate case.

### SC-006, measured at last

The review measured what I had left unmeasured: +1.0–1.2 s, about +110 % on the pack, because
a 39 KB parent blob was re-read for every commit — including commits D2b then discarded. The
boundary is monotonic along a linear history, so it is now tested once against `HEAD^` and
short-circuits when absent.

| | |
|---|---|
| Pack, phase 2 as shipped | 3743 ms |
| Pack, after the remediation | **2719 ms** |
| `ritual-checks` total | 18261 ms |

The check is now cheaper than the version that did not have it, because the short-circuit also
skips work the old code did per commit. Measured on this repository, both directions, not
estimated.

### The phase token, a third time

`a976f6d` ("docs: record the phase 2 gate") carries "phase 2" in its subject, so it is graded
as a phase commit although it is not one. F9 recorded the rule, G4 reproduced it, and this is
the third occurrence — by the same session that wrote the rule down. It is the feature's own
thesis applied to its author: **a rule written in a notes file is not a rule anything
enforces.** Recorded here as a candidate for a real check (a `phase N` token on a commit whose
diff declares no phase territory), not as another note promising to remember.

**Correction, 2026-09-13 — the consequence was overstated three times, including in the first
draft of this section.** It was claimed that `scope-check` grades `a976f6d` *instead of*
`14cf1d6`, displacing the real phase commit and making the gate row above irreproducible. That
is false. Under `scripts/ritual-checks.ps1` — the command CI runs — every phase-token commit on
the branch is graded individually, and all eight pass:

```text
PASS phase 1 commit ced1302 (7)   PASS phase 1 commit f49ad61 (1)
PASS phase 1 commit 6fbffae (2)   PASS phase 1 commit 0803049 (10)
PASS phase 1 commit 370a28b (2)   PASS phase 2 commit 14cf1d6 (3)
PASS phase 2 commit a976f6d (1)   PASS phase 2 commit 4b846ae (2)
```

The error came from reading `scope-check.ps1` standalone, which reports the latest phase commit
only, and generalising from that single line to a claim about what is graded. The real defect
of a stray token is a **mislabel** — a docs commit graded as a phase commit, which it then
passes — not a lost verdict. Both reviews' G4/H-class notes on this point inherit the same
overstatement.

## Phase 2 remediation round 2 — J1–J6 (fourth review)

The fourth fresh-context review confirmed the seven earlier shapes genuinely closed, using its
own 17 fixtures, and then found six blocking findings — **four of them regressions introduced
by my round-1 fixes**. That is the number worth remembering: fixing seven holes opened four
new ones, all in the same function, all by adding a condition to it. The owner's direction was
therefore to simplify rather than patch, and each fix below replaces a special case with a
rule that is total.

| | Was | Now |
|---|---|---|
| J1 | "absent from the parent" rejected an honest repeat record | occurrence counting — a record counts when the file gains one |
| J2 | `HEAD^` short-circuit; failed open on every PR run | boundary evaluated per commit again |
| J3 | `R100`-only; graded a renumbered branch as an amendment | renumbering = the feature directory moved (what FR-010 says) |
| J4 | dropped every `Word: ` line, subjects included | git's own `%(trailers:only)` decides what a trailer is |
| J5 | an unterminated `<!--` hid a record from readers, not from the check | it now hides everything after it, as renderers do |
| J6 | hunk pairing; a moved-and-ticked line read as progress | whole neutralised file compared in order |

J6 is the one that removes a class rather than a case. Reasoning about whole files instead of
paired hunks makes "moved between phase blocks while ticked" inexpressible as progress, rather
than merely detected.

### Verification — 33 scenarios, three suites

| Suite | What it covers | Result |
|---|---|---|
| S1–S14, N1–N3 | the original 18, fixed before any code existed | all unchanged |
| A1–A7 | the third review's seven false-PASS shapes | all still closed |
| J1–J7 | the fourth review's findings, incl. a PR merge preview | all correct |

Every mechanism the A-series tests was **rewritten** in this round (J1 replaced H5's rule, J5
replaced H1's, J6 replaced H2's, J3 replaced H3's, J4 replaced D5's), so re-running it was not
a formality: the occurrence-counting rule could have reopened the recycled-record hole while
fixing the repeat-record false FAIL. It did not.

### What could not be measured, and why

**SC-006 has no trustworthy number at this commit.** Removing the `HEAD^` short-circuit genuinely
costs git invocations back — that is real and expected. But during this round a single
`git rev-parse HEAD` on the development machine began taking **2.5–3.3 seconds**, where earlier
in the same session a full `ritual-checks` run — hundreds of git calls — completed in 18 s. The
pack makes roughly eighty git calls, which accounts for the 150 s readings taken afterwards.

Those readings were first reported as a severe regression in the check. **That was wrong**, and
the earlier figures (3743 ms → 2719 ms) are equally unreliable, having been taken before the
degradation. Removing fixture repositories did not restore speed, so the cause is system-level
and outside this feature. SC-006 is therefore **unmeasured**, deliberately, rather than
carrying a number that has already had to be retracted once.

### The verification that graded nothing, twice

The J2 fixture — a pull-request merge preview — was wrong twice before it was right. The first
version merged onto `main`, where the check correctly does not run at all; the second left
`merge-base..HEAD` empty, so there were no commits to walk. **Both printed a confident PASS.**

That is J2's own failure shape, reproduced in the thing built to detect it: a verification that
grades nothing is output-identical to a verification that passes. It is recorded here because
it argues for something this feature does not yet have — a check that reports *how many*
commits it graded, so that zero is visible instead of silent.

## Phase 2 (round 2) — gate, and the fifth review that was not held

Certified by the owner 2026-09-14: `pwsh -File scripts/ritual-checks.ps1` → RESULT OK on
`f9276fd`, with `scope-check: PASS phase 2 commit f9276fd (2 file(s))` and CI green
(https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/34770302683).

**No fifth fresh-context review was held.** Four rounds ran: 6, 3, 6, 6 blocking. The character
of the fourth differs from the third — it found no new attack on the check's *purpose*, only
regressions in how the third round's fixes were implemented — so the risk it was catching has
changed shape. Phase 3 replays the detector over real history under `-IgnoreAmendmentBoundary`,
which tests the same logic against commits nobody wrote for it, and is the strongest check
available short of another reviewer.

**The condition attached to that decision**: any logic error the replay surfaces is a **phase 2
finding**, remediated as such, not absorbed into phase 3's conclusions. Phase 3 must not be
allowed to quietly become the place where phase 2's defects are discovered and not recorded.

## Phase 3 — the replay over real history (T020, T021)

Run 2026-09-14 with `-IgnoreAmendmentBoundary` (D2c) and the new `-ReplayBase`/`-ReplayTip`
analysis parameters, over commits nobody wrote for this feature.

### SC-002 — MET

FitForge 001, range `bed2c26..db25cb7`: **23 of 25 commits graded**, 14 flagged. The five
amendments recorded in that feature's governance review as finding F3 each fail the check **as
they were actually committed**, identified by sha rather than by reconstruction.

> **Superseded — the sha list below is wrong.** `3cb6e34` is not one of F3's five and `cff8c57`
> is; see B6 below for the corrected table, which is the one to read. The rows are left in place
> because the correction is part of this feature's record.

| Commit | What F3 recorded | Flagged on |
|---|---|---|
| `26d9108` | the §5 **new package** amendment | `plan.md` |
| `7d3f297` | the amendment made **two seconds** before the phase | `contracts/health.md`, `tasks.md` |
| `8785678` | widened Territory (a `scope-check` WARN "correct-by-parent") | `contracts/health.md`, `plan.md`, `tasks.md` |
| `92455d6` | widened Territory (the second WARN) | `plan.md`, `tasks.md` |
| `3cb6e34` | the added phase | `plan.md`, `spec.md` |

This is the criterion the whole feature was aimed at, and it is the one result here that no
fixture could have produced.

### SC-004 — 67 flags across the merged kit features, and they are NOT spurious

| | |
|---|---|
| Features replayed | 12 (002 → 013) |
| Flags | 67 |
| On `tasks.md` | 51 |
| On `contracts/**` | 11 |
| On `spec.md` / `plan.md` | 4 |
| D5 violations (record present, commit message silent) | 1 — `e1dcf0c`, feature 013 |

**The concentration on `tasks.md` looked like a spurious class and is not one.** Sampling the
diffs (`66b3dff`: 22 lines added, 7 removed; `dc6bbd6`: 37 added, 5 removed; `aad06e1`: 23
added, 7 removed) shows these commits did not tick tasks — they **rewrote the task text while
ticking it**, expanding each line to describe what had actually been done. That changes what
the approved document says the work was. It is the benign form of exactly the failure this
feature exists to catch, and the check is right to flag it.

So D3a does **not** apply: this is not a class of routine change a reviewer would wave through,
it is a practice that the rule is incompatible with. The kit did it on essentially every
feature it has ever shipped, including the three whose reviews caught nothing.

**Correction, 2026-09-16.** This section first said thirteen features. The replay covers the
twelve merged feature branches from 002 to 013 — 121 graded commits. The flag count, 67, was
and is right; the feature count was one too many. `plan.md` D3c and the commit message that
carried it inherited the same figure. The decision does not turn on it, and correcting an
approved document needs an approver who is not me (constitution I), so it is recorded here and
left for the owner to fold in if they think it worth an amendment.

The single D5 flag is worth naming separately: feature 013's `e1dcf0c` carries three genuine
`**Amendment approved by**: anas.m` lines in `plan.md` — the kit's own best-practice
amendments — and its commit message names nobody. Half-recorded, by the feature that
established the convention.

### The decision (T022)

Two ways forward, and it was the owner's call, not the agent's:

- **(a) The practice changes.** `tasks.md` holds agreed work and completion state only; what
  was actually done goes to `notes.md`, exactly as phase evidence already did under D3b. The
  rule then costs nothing in normal work. This is consistent with D3b and needs no exemption.
- **(b) An exemption is carved** for appending to a task line while ticking it. Cheaper for
  habit, and it reopens the smuggling vector deliberately: "expand the task text to match what
  the code does" is how an agent rewrites the standard it is judged against.

**Decided 2026-09-14: (a).** Recorded as plan decision D3c, amended into `plan.md` with the
owner's approver line (`4d0dbb9`). `tasks.md` holds the agreed work and its completion state;
what was actually done goes to `notes.md`. No exemption is added, so the rule stays sharp and
the habit changes — the cost lands on the kit's own practice rather than on the check's
precision. The failure message now says so in the sentence a reader meets at the moment they
trip on it (T023).

### SC-006 (T024) — the cost was real, and it was all plumbing

Wall-clock is still unusable on this machine: the process-spawn degradation recorded under
"What could not be measured, and why" has not gone away. Ten bare `cmd /c echo` spawns cost
**22 s** — 2.2 s to start a process that does nothing. Within one session the pack was timed at
15.7 s, 18.3 s and 22.2 s before the batching below, and at **201 s** after it, while making
half as many git calls. That last number measures the machine, not the check, and it is the
reason nothing here is reported in seconds.

So the check was measured in the unit that actually drives its cost and does not vary with the
machine: **child processes**. Every git question is one spawn.

| On this branch (17 commits, 8 graded) | git calls | share of the pack |
|---|---|---|
| Amendment check, as phase 2 shipped it | 66 | 74 % of 89 |
| Amendment check, after batching (T024) | **20** | 47 % of 43 |

Seventy-four per cent of every git call the whole enforcement pack made was this one check.
The one timing that is worth anything is a *ratio* taken back to back in the same minute: the
pack ran in 15.7 s and 18.3 s with the check and 4.5 s and 5.0 s with it disabled — three
quarters of its time, matching three quarters of its git calls, and about a third of the 35.5 s
`ritual-checks` run measured beside them. **SC-006 asks for "a small, stated fraction". That
was not one**, and the plan named the remedy in advance: batch the plumbing, never the
granularity (Complexity Tracking).

Three questions now cover the range instead of being asked commit by commit:

| Batch | Replaced | Calls |
|---|---|---|
| `git log --format=<sha,parents,date,body,trailers>` | one `rev-list --parents` per commit, plus `%ad`, `%B` and `%(trailers:only)` per amendment | 27 → 1 |
| `git log --name-status` | one `show --name-status` per graded commit | 8 → 1 |
| `git grep -l <function> <every first parent>` | one 39 KB blob read per ungraded commit (the D2b boundary) | 10 → 1 |
| a per-run blob cache | the same two `tasks.md` blobs read twice — once for visibility, once for the checkbox comparison | 16 → 12 |

What is graded did not change. The walk is still per commit, the boundary is still evaluated
per commit against that commit's own parent (J2), and the sticky flag still stops re-testing
once crossed. The batches change **who is asked**, not what for. The remaining 20 calls are
five per-file diffs and twelve blob reads — proportionate to the documents actually amended,
not to the length of the branch, which is the shape the plan wanted.

`Test-AmendmentCheckPresent` is gone: the batched presence set makes the same content test, and
a second implementation of a boundary this feature has already got wrong once is a liability.

### The control character that "started" every line

The name-status batch parsed as one enormous record on its first run. `String.StartsWith`
defaults to a **culture-sensitive** comparison, which treats an ASCII record separator as
ignorable — so every line, the empty ones included, started with it. The fix is an ordinal
test on the first character.

It is the same lesson as the H6 timezone finding and the J4 trailer finding: the failure was
never in the rule, it was in a library default that is *helpful* about text. Worth naming
because this check now has three of them.


### Verification after the batching (T025) — 33 scenarios, three suites, no change

Re-run in full against the batched check, on 2026-09-16. Every scenario returned the verdict
fixed for it before the code existed.

| Suite | Scenarios | Result |
|---|---|---|
| S1–S14, S9b, N1–N3 | the originals, written before any code | every verdict as specified |
| A1–A7 | the third review's false-PASS shapes | A1–A6b still fail, A7 still passes |
| J1–J7 | the fourth review's findings, incl. the PR merge preview | all seven correct |

J2 is the one to look at twice. It is the merge-preview case whose whole point is that the
boundary must be judged per commit and not from `HEAD^`, and it is the case the batching had
most room to break, because the presence test now runs once for the whole range instead of
commit by commit. It still fails the silent amendment, which is what it must do.

The suites needed one change themselves: their pass/fail filter matched **any** line mentioning
`AmendmentAuthority`, and the check now prints a line on every run saying how many commits it
graded. Narrowed to the failure lines the pack indents under `enforcement-pack: FAIL`. Worth
recording as its own small lesson — a harness that greps for a name rather than for a verdict
breaks the moment the thing it grades learns to talk.


### The replays, re-run against the batched check (T020, T021)

The fixtures were designed by the author; the replay was not. Both ranges were re-run after the
batching and reproduce to the commit:

| | before | after |
|---|---|---|
| FitForge 001, `bed2c26..db25cb7` | 23 of 25 graded, 14 flags | **identical** |
| This repository, 12 merged features | 67 flags | **identical** |

The five amendments recorded as finding F3 in FitForge 001 — `26d9108`, `7d3f297`, `8785678`,
`92455d6` and `cff8c57` — corrected under B6 below, where `3cb6e34` turns out to be a sixth
flagged commit rather than one of F3's five — are each still flagged, by sha. SC-002 and
SC-004 stand exactly as
phase 3 first recorded them, which is the only evidence that matters here: 66 git calls and 20
git calls reached the same verdict on the 23 + 121 commits they graded, none of which
was written for this check.


## Phase 3 — gate (ci-held)

Certified by the owner 2026-09-16 on the evidence triplet.

| | |
|---|---|
| Phase commit | `502cf55` |
| CI run | https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/35059554648 |
| CI conclusion | success |
| Run event | push — the run executed the phase commit itself, not a merge preview |
| Scope check | PASS phase 3 commit `502cf55` (1 file) |
| Approved by | anas.m, 2026-09-16 |

The agent-run `pwsh -File scripts/ritual-checks.ps1` returned RESULT OK / EXIT 0 on `593c5e3`.
That is corroboration and nothing more: an agent-run gate never certifies, in either mode
(`docs/sdlc/gate-command.md`).

Five `PhaseSizeWarning`s appear in the run — `69b17cf`, `61c57d5`, `9c7fb00`, `0803049`,
`aa3b194`. All five are amendment or remediation commits from phases 1 and 2, all documents
rather than code, and none is new to this phase. Non-blocking, as they were when each was made.

**A note on assembling the triplet.** The branch stood four commits ahead of `origin` when the
gate was called, so the only CI evidence in existence was the phase 2 round-2 run on `f9276fd`.
Pushing the whole branch would have produced a run on the tip, `593c5e3` — a green run on the
wrong commit, which certifies nothing (triplet element 3). `502cf55` was therefore pushed alone,
its run allowed to complete, and `593c5e3` pushed after. Worth writing down because the mistake
is invisible when it happens: the run is green, the branch is right, the sha is silently one
commit off, and the evidence reads as valid to anyone who does not check the third element.

**Gate 5 is not held.** The fresh-context AI review of phase 3 has not been run. The phase 2
round-2 decision to skip a fifth review rested on the replay standing in its place; the replay
has now happened, so that argument is spent and does not carry forward to this phase's own
findings — the exemption decision (D3a, T022) and the rewritten failure wording (T023) are
author judgements no second reader has yet seen.


## Phase 3 — the fifth review, and the remediation it forced (B1–B6)

`ai-code-review-phase-3.md`: **REQUEST CHANGES**, 6 blocking, 10 non-blocking. The reviewer
built seventeen fixtures of its own and declined to run mine, which is the only reason B1 was
found: my suite could not have produced it, because I wrote both the check and the suite.

**The accounting matters here.** The phase 2 round-2 note attached a condition to skipping the
fifth review: any logic error the replay surfaced would be a *phase 2* finding. B1, B2 and B3
are not that. They are defects in the **batching** — phase 3's own T024 work — so they are
phase 3 findings. Skipping the fifth review did not cost us something the replay was meant to
catch. It cost us review of the optimisation the replay motivated, which is the one piece of
this feature no fixture suite had ever seen.

All three blocking code defects **fail open**: each returns a clean PASS on a branch carrying a
silent amendment.

### B1 — a commit could delete itself from the graded set

`Get-CommitMetaBatch` split its record stream on `0x1E`, under a comment asserting that byte
"cannot occur in a commit message". It can. Demonstrated here, not taken on trust:

```text
$ printf 'subject\n\nbody with \036 separator\n' > m.txt ; git commit -F m.txt
$ git log -1 --format=%B | od -c   →   b o d y   w i t h   036   s e p a r a t o r
```

git carries `0x1E` through untouched. It **refuses** a NUL: `error: a NUL byte in commit log
message not allowed`. So the fix is not a better rare byte, it is the byte git guarantees:
records are now separated with `-z`, the two message-derived fields moved **last**, and the
field split is capped at five — so an injected `0x1F` can only truncate message text, and lost
message text can only make the D5 name test fail, never pass.

The set of commits no longer comes from the message stream at all. It comes from
`git rev-list --reverse`, which reads commit objects; and any sha rev-list lists that the batch
did not parse is now a **named failure**, not a skip. That assertion is the thing whose absence
made B1 work.

| Fixture: a silent `plan.md` widening, message carrying one `0x1E` | Verdict |
|---|---|
| Pre-fix (`502cf55`) | `no commits in <range> — nothing to grade` — **clean pass** |
| Post-fix | `commit 8018ef8 amends specs/014-x/plan.md after approval with no conforming approver record` |

### B2 — a non-ASCII path was never graded

`Get-NameStatusBatch` omitted `-c core.quotepath=off`, so `contracts/café-api.md` arrived
quoted-octal, failed the `"$dir/*"` filter, and was skipped. This is spec US1 scenario 3
verbatim, and the third appearance of this shape in the kit: `scope-lib.ps1` carries the flag
citing 006 review F3, and `enforcement-pack.ps1:577` carries it citing phase 2 review F2. The
batching lifted the read into a new function and left the flag behind.

| Fixture: `contracts/café-api.md`, rate limit 100 → 10000, no record | Verdict |
|---|---|
| Pre-fix | `graded 1 of 1 commit(s)` — **no failure** |
| Post-fix | `commit a862aec amends specs/014-x/contracts/café-api.md after approval …` |

A rider from the same finding: `Test-CheckboxOnlyChange` returned `$true` when both blob reads
came back empty, so an unreadable `tasks.md` read as "checkbox-only" and was exempted.
`--name-status` said the path was modified, so two empty reads are a failed read. Now `$false`.

### B3 — one bad ref disabled the check for the whole branch

`git grep` aborts the entire search on a single unresolvable ref, and the empty presence set
that follows grades **nothing** while printing what a legitimately pre-boundary branch prints.
J2's fail-open shape with a new trigger. Measured:

```text
raw git grep exit: 128        (one bogus sha alongside one good ref)
pre-fix  presence set size: 0    good ref present: False   → nothing graded, silently
post-fix presence set size: 1    good ref present: True
```

The batch is now chunked at 200 refs (a ~32 767-byte Windows command line puts the ceiling near
700 shas) and checks `$LASTEXITCODE`; on an error exit it falls back to the pre-batching
per-ref probe for that chunk. Slower on the error path, never silent.

### Regression evidence — the replay is the test

The 33-scenario suite from phases 2–3 lived in a session scratchpad and no longer exists, which
is its own lesson: **a fixture suite that is never committed cannot be re-run by the next
session**, and T025's "re-run the suites" is unverifiable today. The replay is committed
history and reproduces exactly, so it is what stands in:

| | phase 3 recorded | after B1–B3 |
|---|---|---|
| Merged features replayed | 12 (002 → 013) | **12** |
| Commits graded | 121 | **121** |
| Flags | 67 | **67** |

Per-feature graded counts and flag counts are identical branch by branch. The three fixes
changed no verdict on any commit anyone actually wrote.

### B4 — the per-flag judgement SC-004 asks for

The reviewer was right that this did not exist: `notes.md` had a six-row aggregate, three
sampled diffs and one named flag, and sampling three of fifty-one is exactly how B5 got past
T022. Two independent verifications came first.

**No flag is a pure tick.** Re-implementing the D3 neutralise test outside the pack — strip
every checkbox marker from both blobs, compare in order — over all 60 `tasks.md` flags:

```text
tasks.md flags with real text change: 60 ; pure-tick false positives: 0
```

**Two flags are status-only**, found by asking of every flag whether its whole diff is a
`**Status**` line: `a9ddeb7` ("spec: approve 011-roadmap-claim-check mini-spec") and `4e87018`
(the 013 plan approval), both `+1/-1`. That is B5, and it is a class, not a one-off.

The table: 67 rows, one per flag, every sha present, every sha carrying a verdict.

| # | Feature | Commit | File(s) flagged | +/- | Class | Verdict |
|---|---|---|---|---|---|---|
| 1 | field-lesson-harvest | `42b9cd9` | tasks.md | +13/-3 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 2 | verification-pack | `b0df0fa` | tasks.md | +23/-7 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 3 | verification-pack | `632d958` | scope-check-cli.md, tasks.md | +19/-5, +23/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 4 | verification-pack | `24103a0` | tasks.md | +26/-7 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 5 | verification-pack | `7597c5d` | tasks.md | +8/-1 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 6 | verification-pack | `f548b1b` | ritual-checks-ci.md, tasks.md | +6/-1, +7/-7 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 7 | verification-pack | `b91bdde` | tasks.md | +15/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 8 | verification-pack | `d02c36f` | tasks.md | +13/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 9 | verification-pack | `327ce02` | tasks.md | +8/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 10 | verification-pack | `8fd95f6` | tasks.md | +4/-4 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 11 | verification-pack | `5c8e456` | tasks.md | +13/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 12 | verification-pack | `29e6988` | ritual-checks-ci.md | +1/-1 | contract text changed | **REAL** - a reinterpreted contract clause |
| 13 | verification-pack | `ce3c3ce` | tasks.md | +10/-7 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 14 | adoption-doctor | `6410ffb` | tasks.md | +32/-5 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 15 | adoption-doctor | `9530fd4` | verify-kit-cli.md, tasks.md | +6/-2, +22/-1 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 16 | adoption-doctor | `8b033b7` | verify-kit-cli.md | +1/-1 | contract text changed | **REAL** - a reinterpreted contract clause |
| 17 | adoption-doctor | `61869bc` | tasks.md | +33/-7 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 18 | adoption-doctor | `2462b41` | tasks.md | +12/-4 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 19 | adoption-doctor | `3a37d57` | tasks.md | +6/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 20 | adoption-doctor | `dddcf1f` | tasks.md | +13/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 21 | adoption-doctor | `1fe7b9b` | tasks.md | +11/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 22 | adoption-doctor | `b0fe413` | tasks.md | +3/-3 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 23 | adoption-doctor | `7463076` | tasks.md | +9/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 24 | adoption-doctor | `316f4f0` | tasks.md | +14/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 25 | ci-held-gate | `aad06e1` | tasks.md | +23/-7 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 26 | ci-held-gate | `583f573` | tasks.md | +35/-2 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 27 | ci-held-gate | `31467cc` | plan.md, tasks.md | +2/-0, +18/-3 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 28 | ci-held-gate | `45a924e` | gate-certification.md, tasks.md | +10/-2, +18/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 29 | ci-held-gate | `c72b54c` | tasks.md | +13/-4 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 30 | ci-held-gate | `dc11b12` | tasks.md | +14/-1 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 31 | ci-held-gate | `63fed28` | tasks.md | +24/-4 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 32 | ci-held-gate | `1fa3a04` | tasks.md | +11/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 33 | ci-held-gate | `18b4749` | tasks.md | +7/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 34 | ci-held-gate | `4429624` | tasks.md | +3/-2 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 35 | ci-held-gate | `3d10915` | tasks.md | +10/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 36 | micro-lane | `66b3dff` | tasks.md | +22/-7 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 37 | micro-lane | `46697d7` | tasks.md | +37/-5 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 38 | micro-lane | `d5dfad5` | tasks.md | +11/-6 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 39 | micro-lane | `c7a5287` | tasks.md | +1/-1 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 40 | micro-lane | `84e47ba` | tasks.md | +8/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 41 | micro-lane | `d9e45e8` | micro-lane-checks.md, tasks.md | +1/-1, +1/-1 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 42 | micro-lane | `ba32a24` | tasks.md | +6/-1 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 43 | micro-lane | `79a3b86` | tasks.md | +7/-2 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 44 | law-digests | `dc6bbd6` | tasks.md | +37/-5 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 45 | law-digests | `374163c` | digest-checks.md, tasks.md | +15/-0, +20/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 46 | law-digests | `040dbd2` | tasks.md | +31/-4 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 47 | law-digests | `0b0627c` | tasks.md | +11/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 48 | law-digests | `0f4da69` | tasks.md | +27/-3 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 49 | law-digests | `2d1c691` | spec.md, tasks.md | +13/-5, +15/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 50 | law-digests | `c1fc834` | tasks.md | +25/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 51 | roadmap-claim-check | `a9ddeb7` | spec.md | +1/-1 | `**Status**` Draft -> Approved | **SPURIOUS** - the approval edit the templates mandate |
| 52 | cross-repo-scope-check | `21c938c` | scope-check-repos-cli.md | +11/-3 | contract text changed | **REAL** - a reinterpreted contract clause |
| 53 | cross-repo-scope-check | `7aac1ec` | scope-check-repos-cli.md | +14/-6 | contract text changed | **REAL** - a reinterpreted contract clause |
| 54 | cross-repo-scope-check | `12e6c3d` | tasks.md | +35/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 55 | cross-repo-scope-check | `dedd0ab` | scope-check-repos-cli.md | +3/-2 | contract text changed | **REAL** - a reinterpreted contract clause |
| 56 | critical-independence-signal | `4e87018` | spec.md | +1/-1 | `**Status**` Draft -> Approved | **SPURIOUS** - the approval edit the templates mandate |
| 57 | critical-independence-signal | `c28e1f9` | tasks.md | +43/-9 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 58 | critical-independence-signal | `1b30e99` | tasks.md | +50/-5 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 59 | critical-independence-signal | `20bda18` | tasks.md | +47/-4 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 60 | critical-independence-signal | `b60b868` | tasks.md | +9/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 61 | critical-independence-signal | `43e52cf` | tasks.md | +89/-12 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 62 | critical-independence-signal | `a76e877` | tasks.md | +8/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 63 | critical-independence-signal | `e1dcf0c` | plan.md, spec.md, tasks.md | +15/-2, +8/-1, +46/-0 | record present, commit message silent | **REAL** - D5 half-recorded |
| 64 | critical-independence-signal | `9054e97` | tasks.md | +87/-8 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 65 | critical-independence-signal | `7ef6e8d` | tasks.md | +8/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 66 | critical-independence-signal | `aeac7f8` | tasks.md | +67/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |
| 67 | critical-independence-signal | `bcee4e5` | tasks.md | +33/-0 | task text rewritten while ticking | **REAL** - changes what the document says was agreed |


**Reading the table.** 65 of 67 are real: 60 `tasks.md` flags where the task text was rewritten
while being ticked, 11 file-level flags on `contracts/**` (a reinterpreted contract clause is
the rule's own worked example), 4 on `spec.md`/`plan.md`, and one D5 case — feature 013's
`e1dcf0c`, which carries three genuine `**Amendment approved by**: anas.m` lines in `plan.md`
and a commit message naming nobody. Half-recorded, by the feature that established the
convention. (Flag counts and file counts differ because one commit can flag several files: 67
flags span 77 flagged files.)

### B5 — the one spurious class, NOT decided here

`a9ddeb7` and `4e87018` flip `**Status**: Draft` → `**Status**: Approved` and change nothing
else. That edit is **mandated** by the kit's own `spec-template.md` and `micro-spec-template.md`,
and the constitution's own scope sentence — "once a feature's `spec.md` or `plan.md` has been
**approved**" — places the approval act outside the rule it starts. The check currently grades
the commit that begins approval as an amendment to an already-approved document.

Demonstrated forward, not just historically: the next feature's approval commit turns its
branch red. This is D3a's exemption route exactly — a spurious **class**, not a one-off — and
T022's conclusion that "D3a does not apply" was reached from a three-flag sample that did not
include either of these.

**This is the owner's decision and it is not made here.** Recording an exemption amends an
approved `plan.md` (D3a lives there), and an implementing agent must not approve its own
amendment (constitution I). The options, stated without a recommendation dressed as a finding:
exempt a diff whose only change is the `**Status**` line; or require the approval commit to
carry its own record; or accept the flag and let every future approval commit fail.

Phase 3's **Territory** names `tasks.md` but not `plan.md` (reviewer N10), so recording the
decision needs a Territory amendment too — also the owner's, also before the commit that uses it.

### B6 — SC-002's table names the wrong commit

`3cb6e34` is titled "spec: owner approves 001 and accepts ADR-001". It is an approval commit,
not one of finding F3's five amendments; F3's actual fifth, `cff8c57`, is absent from the table.
The reviewer verified independently that all five real shas do fail the check, so **SC-002 is
substantively met** — but the evidence table for the feature's headline criterion cites the
wrong commit, and one row's gap is given as "two seconds" where F3 records twenty-nine.

The corrected table belongs in this file and the correction is mine to make; the row that
inherited the same error into approved `plan.md` prose is not. Left for the owner with B6.

**The corrected SC-002 table**, re-run 2026-09-16 over `bed2c26..db25cb7` (23 of 25 graded, 14
flags — identical to the original run):

| Commit | What F3 recorded | Flagged on |
|---|---|---|
| `26d9108` | the §5 **new package** amendment | `plan.md` |
| `7d3f297` | the readiness bound moved onto the document | `contracts/health.md`, `tasks.md` |
| `8785678` | widened Territory (a `scope-check` WARN "correct-by-parent") | `contracts/health.md`, `plan.md`, `tasks.md` |
| `92455d6` | widened Territory (the second WARN) | `plan.md`, `tasks.md` |
| `cff8c57` | the changed decision — host wiring to `Api/Hosting`, not `Api/Infrastructure` | `tasks.md` |

`3cb6e34` is removed from the table and is **not** one of F3's five: it is "spec: owner approves
001 and accepts ADR-001". It does still fail the check, though after D3d it fails on `plan.md`
alone: its `spec.md` hunk is
a lone `Draft` -> `Approved 2026-09-10 (owner: anas.m)` flip, which is exactly what the
exemption covers. So nothing about the replay changes; only the claim about what that sha
*is*. Note what the corrected row exposes: the same B5 class is present in FitForge too, where
the approval act and an accepted ADR travel in one commit.

I have not verified the "twenty-nine seconds" figure the reviewer cites against F3's own text —
the "two seconds" phrase in this file came from `7d3f297`'s own commit subject, so the two may
be describing different commits. Left as the reviewer recorded it, unresolved, for the owner.

### B7 — the check hid this round's own approver record

Not from the review. Found because the remediation commit **failed its own check**: the
`tasks.md` amendment above carried a conforming `**Amendment approved by**: anas.m, 2026-09-16`
line and the commit message named her, and the check still reported "no conforming approver
record".

The cause is T060's own description. Closing J5 taught the check that an **unterminated** `<!--`
hides everything after it, because that is what every renderer does. T060 documents that fix,
and in documenting it, quotes the syntax in backticks. Markdown renders a backticked `<!--` as
literal text; the check read it as a comment opener:

```text
lines in tasks.md:          411
after paired-comment strip: 407
after unterminated strip:   277   <- truncated from T060's own line onward
record still visible?       False
```

Every approver record added below line 277 was invisible. The rule had become impossible to
comply with in any graded document that mentions the syntax — including the document belonging
to the feature that introduced the rule.

The fix neutralises `<!--` and `-->` inside fenced blocks and inline code spans before either
comment rule runs, which is what a renderer does. Verified against all four cases, because the
risk of this fix is reopening the two findings that produced the rule:

| Case | Required | Result |
|---|---|---|
| Real `tasks.md`, backticked `<!--` at T060 | record visible | visible |
| H1 — record inside a closed comment | invisible | invisible |
| J5 — genuine unterminated comment | hides what follows | hides |
| Fenced example containing `<!--` | record visible | visible |

**This one fails closed.** It never passed a silent amendment; it refused to accept an honest
record. That is the safe direction, and it is still a defect — a rule nobody can satisfy gets
routed around, which is the reasoning the constitution's own checkbox exemption rests on.

Worth naming the mechanism that caught it: the check was pointed at the commit that was
remediating the check, and the feature's own compliance was the test. Five fresh-context reviews
did not find this. The branch grading itself did, on the first commit where it mattered.

### B5 — decided: the status line is exempt (D3d, owner, 2026-09-16)

The owner exempted a diff whose only change is the `**Status**` line, and approved the `plan.md`
amendment that records it. D3a's exemption route, used for the first time and for the reason it
exists: the replay surfaced a class.

Ordering, because this is the part that is easy to get wrong. Phase 3's **Territory** named
`enforcement-pack.ps1` and `tasks.md` only (reviewer N10), and the decision had to be recorded
in `plan.md`. `scripts/scope-check.ps1` reads a phase commit's territory from its **parent**, so
the widening landed in its own commit, `28d2f0a`. Same-commit widening never passes, which is
the whole point of reading the parent.

**Correction, same day.** That commit's message claims it carries no `phase N` token. It does:
the subject reads "widen **phase 3** territory", and the matcher is `phase\s+(\d+)`, so
scope-check graded it as a phase 3 commit — `PASS phase 3 commit 28d2f0a (1 file(s))`. It passed
because the only file it touched, `tasks.md`, was already in the territory it was widening, so
nothing about the ordering argument changes. But the commit message asserts a fact that is
false, and the immutable half of a record is the half worth correcting out loud. This is the
sixth occurrence of this trap in this feature, and the first one written by an agent that had
just finished documenting it.

Verification, three ways:

| Case | Required | Result |
|---|---|---|
| Replay over 12 merged features | the two approval commits stop flagging, nothing else moves | **65 flags**, from 67: 011 `1 → 0`, 013 `12 → 11`, all others identical |
| A new feature's honest approval commit | passes | passes, no flag |
| The same status flip carrying one smuggled `FR-002` | fails | fails |

That third row is the one that matters. The exemption is a whole-file comparison with the status
value neutralised, so it cannot carry a payload: flip the status and touch anything else and the
commit is graded exactly as before. A file with no status line cannot qualify at all — without
that guard, neutralising nothing on both sides would make every unchanged file look exempt.

The residual risk is written into D3d rather than left for the next reviewer to find: the
exemption keys on the line, so `Approved` → `Draft` is exempt too. It buys nothing. Approval is
proxied by a document's first appearance (D10) and never by this line, so un-setting it
un-approves nothing the check believes.


## Phase 3 — gate, re-run after the remediation (T070)

Certified by the owner 2026-09-16 on the evidence triplet, for the phase's final state.

| | |
|---|---|
| Phase commit | `5d49cde` (`5d49cde307665346046ac16a2ec4ea262f7ef468`) |
| CI run | https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/35067823536 |
| CI conclusion | success |
| Run event | push — the run executed the phase commit itself, not a merge preview |
| Scope check | PASS phase 3 commits `d606b2e` (4 files), `28d2f0a` (1 file), `5d49cde` (4 files) |
| Approved by | anas.m, 2026-09-16 |

`**Gate Batching**: none`, so this is not a batch end. It is phase 3's gate held a second time,
on the commit that carries the phase's final state after the fifth review's remediation. The
three remediation commits were each graded individually inside the one run — the batching
declaration governs whether the *gate* may be deferred across phases, not how many commits a
single phase took to reach its end.

`502cf55`'s certification above stands as the record of what was gated then. It is not
superseded, and it is not sufficient either: `d606b2e` changed the check's core in five places
after it.

### The re-runs, and what they proved

| Re-run | Result | Reading |
|---|---|---|
| Kit replay, 12 merged features, 121 graded commits | **65 flags** | identical to the post-D3d figure: 011 `0`, 013 `11`, every other feature commit-for-commit unchanged |
| FitForge 001, `bed2c26..db25cb7` | **23 of 25 graded, 14 flags** | unchanged from the 2026-09-14 run; all five F3 amendments still fail, by sha — `26d9108`, `7d3f297`, `8785678`, `92455d6`, `cff8c57` |

SC-002 therefore survives B1, B2, B3, B7 and the D3d exemption. The FitForge replay exits 1 by
design: it is analysis over history full of real violations, `-IgnoreAmendmentBoundary` (D2c),
and FitForge was read and never written. Both replays need `-Root` pointed at the repository
being replayed; without it the pack runs against the kit and reports "no commits in range",
which looks like a clean result and is not one.

### The local run that proved less than it appeared to

The first local `ritual-checks: RESULT OK` of this round was taken against a working tree that
still held phase 4's uncommitted edits. Every member reads the working tree, so that verdict was
about a tree CI would never see — green there implies nothing about green on the pushed commit.
Re-run in a detached worktree at `5d49cde`, the committed tree alone, it was green as well, and
that is the run worth citing. Recorded because the failure mode is silent: the command is right,
the output is right, and the subject of the sentence is wrong.

**Gate 5 is still not held.** No fresh-context reviewer has seen this remediation round. Five
rounds have now returned 6, 3, 6, 6 and 6+1 blocking findings, and this round rewrote the
commit-set provenance, the name-status batch, the presence batch, the comment stripper and the
exemption set. The gate above is gate 3, and it certifies that the checks pass — not that the
changes are right.


## Phase 3 — the sixth review, and what it caught (K1–K4)

REQUEST CHANGES, 4 blocking and 7 non-blocking, by a fresh-context agent that built 26 fixtures
of its own and checked every comment-visibility claim against a real CommonMark render rather
than against this file. Six rounds have now returned 6, 3, 6, 6, 6+1 and 4 blocking findings.

### K1 — the B7 fix reopened H1

`(?s)```.*?``` ` over the whole blob pairs triple-backtick runs left to right. It does not
require a line start, does not require the two runs to be the same length, and spans any
distance. So an **odd** number of fence runs before a comment puts that comment inside a region
the check calls code, disarms both its markers, and makes a record no reader can see count as a
grant. A second trigger: `\`` is a literal backtick to CommonMark and a delimiter to the old
inline-span regex, so a comment opened between two escaped backticks was "code" to the check and
a real comment to a renderer.

Both are closed by finding the code regions **structurally** instead of textually —
`Get-FencedLineMap` walks lines the way CommonMark does (a fence opens on a line whose first
non-space run is three or more backticks or tildes and closes on a later line whose run is at
least as long), and `Convert-CodeSpanMarkers` pairs equal-length backtick runs within one line,
skipping any run a backslash escapes.

Differential against the pack as gated (`5d49cde`), same fixtures, both directions:

| Fixture | 5d49cde | now | must be |
|---|---|---|---|
| `k1-c9` — a stray fence run, then a genuine block comment holding the record | clean | **FLAG** | FLAG |
| `k1-c10` — the same file with the stray run removed (control) | FLAG | FLAG | FLAG |
| `k1-c5b2` — a mid-line `<!--` between two escaped backticks | clean | **FLAG** | FLAG |
| `h1-comment` — the plain H1 case | FLAG | FLAG | FLAG |
| `j5-unterminated` — an unterminated `<!--` hides the record | FLAG | FLAG | FLAG |
| `b7-quoted-marker` — a backticked `<!--` quoted in prose, record visible after it | clean | clean | clean |

The last row is the one that matters in the other direction: B7 stays closed. A document may
still discuss the syntax without becoming impossible to comply with.

### K2 — D3d exempted far more than the approval act

Neutralising everything after `**Status**:` meant the status line could carry a payload on its
own line-end, any `**Status**:` line qualified (a second one in the body, an ADR's, one inside a
fenced block), and it fired in either direction at any time. The claim in `plan.md` that such a
diff "cannot carry a payload" was false; the single shape tested — a smuggled `FR-002` on its
own line — was the only shape that failed.

The exemption is now the **approval transition**: exactly one differing line, which must be the
document's first `**Status**:` line outside a fence, `Draft` on the old side, and on the new side
`Approved` plus at most an ISO date, an `(owner: …)` parenthetical and the template's trailing
comment. Differential, same fixtures:

| Fixture | 5d49cde | now | must be |
|---|---|---|---|
| `k2-d10-payload` — normative text appended to an approved plan's status line | clean | **FLAG** | FLAG |
| `k2-d11-second-line` — a second `**Status**:` line rewritten while the first is flipped | clean | **FLAG** | FLAG |
| `k2-d12-fenced` — a `**Status**:` line inside a fenced block rewritten | clean | **FLAG** | FLAG |
| `k2-reverse` — `Approved` → `Draft` | clean | **FLAG** | FLAG |
| `k2-d2-own-line` — the flip carrying a smuggled `FR-002` (the shape already tested) | FLAG | FLAG | FLAG |
| `ok-011-form` — `Draft <!-- guidance -->` → `Approved (owner, 2026-09-16)` | clean | clean | clean |
| `ok-013-form` — `Draft — awaiting owner approval` → `Approved 2026-09-16 (owner: anas.m)` | clean | clean | clean |

The last two are the forms this repository has actually used (011's `a9ddeb7`, 013's `4e87018`).
Narrowing that broke them would have traded a hole for a rule nobody can obey.

### K3 — and why the narrowing settles it

The constitution says its one exemption is "part of the rule rather than a detail of whatever
grades it", and that **every other change** to an approved document is an amendment. A plan
decision may read that rule; it may not subtract a class from it. Narrowed to the Draft →
Approved transition, D3d no longer subtracts anything: the clause binds changes made *once a
document has been approved*, and this is the act that starts it. No constitutional amendment,
no MINOR bump, no sync sweep.

### K4 — the gate record repeated the error the same round corrected

The FitForge row written into the certification record named `3cb6e34` as one of F3's five and
omitted `cff8c57` — the exact error B6 raised, re-committed 120 lines below the correction, in
the newest and most authoritative place it appears, and repeated in `fa396ee`'s commit message.
Corrected here; the two superseded tables are now marked as superseded rather than left to be
read as current.

The reviewer also caught a second error riding with it, which is a real observation about the
exemption rather than a typo: after D3d, `3cb6e34` fails on `plan.md` **alone** — its `spec.md`
hunk is a lone `Draft` → `Approved 2026-09-10 (owner: anas.m)` flip, which is precisely what the
exemption covers. "Unchanged from the 2026-09-14 run" was true of the totals and false of the
detail, and the detail was the most interesting thing the FitForge re-run had to say.

### What the sixth review confirmed rather than found

B1, B2, B3 and B4 were each independently reproduced as closed — NUL genuinely refused by
`git commit-tree`, four injection attacks caught, a non-ASCII path flagged, a presence-set
differential of 0 → 2 in a shallow clone, chunk arithmetic exhaustive to n=401, and all 67 rows
of the B4 table cross-checked against the reviewer's own replay. The two rows that stopped
flagging are exactly the two the table marks spurious.

### Cost

`Get-VisibleFromText` is called for every graded path of every graded commit, so a per-character
walk over each line was affordable in a fixture and not in a replay: it made one feature's replay
9x slower before the short-circuits went in (a line with no backtick, or no comment marker, is
returned untouched; a blob with no `<!--` skips the machinery entirely; a document with no fence
run gets an all-false map). Measured after, on 006 (15 commits), interleaved: **119.3 s before,
120.9 s after** — no regression.

That 9x was also nearly mismeasured. The first "before" number was 13 s, taken by running the
gated pack from a scratchpad copy **without `-Root`**, so it graded the scratchpad instead of the
kit and reported a clean, fast, meaningless result. It is the same trap the reviewer filed as N3,
hit twice in one session by the person who wrote the note about it.

## Phase 3 remediation round 2 — gate (T077)

Certified by the owner 2026-09-16 on the evidence triplet, for the phase's final state after the
sixth review.

| | |
|---|---|
| Phase commit | `43ab9d2` (`43ab9d2101212d3b9597d847890fad81dfe39eaa`) |
| CI run | https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/35079222815 |
| CI conclusion | success |
| Run event | push — the run executed the phase commit itself, not a merge preview |
| Scope check | PASS phase 3 commit `43ab9d2` (5 files) |
| Approved by | anas.m, 2026-09-16 |

`**Gate Batching**: none`. This is phase 3's gate held a third time, on the commit carrying K1–K4.
`5d49cde`'s certification above stands as the record of what was gated then, and is not
sufficient: `43ab9d2` changed the check's core again — comment visibility is now structural, and
the status exemption is narrowed to the approval transition.

The branch was ahead by exactly one commit, so `43ab9d2` pushed alone and the push-event run
landed on it with nothing else in the way.

### The local run, done the way the last one had to be corrected

Phase 4's edits are still uncommitted, so the working tree is again not the tree CI grades. The
local `ritual-checks: RESULT OK` cited here was taken in a detached worktree at `43ab9d2`, with
`-Root` pointed at that worktree: doc-lint OK, enforcement-pack OK, scope-check OK, digests OK
(5 fresh, 75 markers), roadmap-claims OK, scope-repos and verify-kit `n/a` as they are for this
repository. Both of the failure modes this feature has recorded — grading the working tree, and
omitting `-Root` — are silent, so the guard against them is procedural, not a warning the tools
will give.

## Phase 4 — the adopter-facing prose (T026–T029, T041, T042)

The phase 4 draft was written before the fifth and sixth reviews, so its job here was less
"write the docs" than "make the docs describe the check that now exists". Three things had
changed under it.

**The exemption count.** The draft said "One exemption" and described the checkbox flip. D3d
added a second, and K2 narrowed that second one to the approval transition alone. The bullet
now says two, and spells out the exact shape the second is limited to — one differing line, the
document's first `**Status**:` line outside any fence, `Draft` on the old side, `Approved` plus
at most a date, an `(owner: …)` parenthetical and the template's trailing comment on the new
one. An adopter who learns the exemption as "status-line changes are free" would learn the
thing that was wrong for one round, so the conditions are stated rather than summarised.

**What "not inside a comment" means.** B7 and K1 made comment visibility a renderer question,
and the answer is adopter-facing: a graded document may discuss comment syntax and still carry
a visible record. `adoption/updating.md` now shows the four cases in a fenced example, with the
kit's own near-miss named — the rule was briefly impossible to comply with in any document that
mentioned it, which is the kind of failure an adopter should be able to recognise in one look.
The troubleshooting line is the practical half: if a record you can see is reported missing,
look upward for an opener that was never closed.

**Full history in CI.** B3's chunked presence set falls back rather than aborting, but neither
path can read objects a shallow clone does not have, and grading nothing looks exactly like a
legitimately pre-boundary branch — green, and meaningless. The kit's own workflow already sets
`fetch-depth: 0`; an adopter who wrote their own workflow has no way to know that matters, so
the boundary section now says it.

`adoption/greenfield.md` gained the two non-amendments (approval flip, checkbox tick) for the
same reason: 001 is where they are free to learn. T041 and T042 stand as drafted — the
`notes.md`/`tasks.md` split they state is unchanged by either review.

### Finding: `build-digests.ps1` makes the B7 mistake (P3, not fixed here)

Writing the sentence about a quoted comment opener being mistaken for a real one caused exactly
that mistake, in a different tool. The digest parser is line-based: any line holding `<!--`
with no `-->` after it opens a comment (`scripts/build-digests.ps1:123`), and it honours fenced
blocks but not inline code spans. The prose paragraph mentioning the opener in backticks
therefore opened a comment, and the next marker line was consumed as its closer:

```text
markers harvested, prose version:  79   (the 'grades spec.md …' marker silently dropped)
markers harvested, fenced version: 80
```

Silent, and symmetrical: the generator and the `-Check` share the parser, so both agree the
marker was never there and CI stays green. The blast radius is small — digests are explicitly
not a source-of-truth rung, and a lost line is a lost orientation note, not a lost rule — which
is why this is recorded rather than fixed. `scripts/` is outside phase 4's Territory, and the
fix belongs with the other parser work, not smuggled into a prose phase. The prose was routed
around it instead: the syntax examples live in a fenced block, which the parser skips.

### Finding: phase 4 was never graded — a decorated `**Territory**` marker (P2)

`scope-check` on the phase 4 commit returned **WARN, not PASS**:

```text
scope-check: WARN commit 3e9b7d5: no territory declared for phase 4 in
specs/014-amendment-authority/tasks.md (declare territory in tasks.md — non-blocking,
pre-006 compatibility)
```

`Get-Territory` (`scripts/scope-lib.ps1:84`) matches `^\*\*Territory\*\*:` — the colon
immediately after the bold run. Phase 4's marker reads `**Territory** (widened by amendment
2026-09-13 — the last two entries, for G5):`, with the colon at the end of the decoration, so
no marker was found and the phase declared nothing. Both of this feature's *widening
amendments* used that decorated spelling; phase 3's (line 322) is harmless only because the
paths it adds are inside the implicit `specs/NNN-name/**` glob, so the phase still graded
correctly on its real territory.

Two things make this worth more than a typo note.

**It fails open, and quietly.** A phase with no parsed territory degrades to a non-blocking
WARN carrying a pre-006 compatibility excuse, in a `tasks.md` whose other three phases all
declare territory properly — which is positive evidence that this is not a pre-006 file. A
phase commit could have touched anything. Verified by hand that this one did not: of its 8
paths, 6 are declared entries and 2 are the feature's own spec directory.

**The amendment that widened the territory is what disabled the check on it.** That is
GAP-019's own shape — an agent's edit removing the grading of its own scope — arrived at by
accident rather than intent, which is the version no rule about approval can catch. The
approver record is present and correct on both amendments; the machine simply stopped reading
the block they approved.

Remediation, proven in a sandbox clone before being proposed (`scope-check` reads the
declaration **as of the parent** — D3, anti-widening — so the repair cannot ride in the phase
commit; it must precede it):

```text
docs: repair the phase 4 Territory marker   →  enforcement-pack: OK
phase 4: <the prose commit, rebuilt on top> →  scope-check: PASS phase 4 commit (8 file(s))
                                               ritual-checks: RESULT OK
```

Two details the sandbox settled rather than assumed. The repair commit is itself an amendment
to an approved `tasks.md`, so it needs its own record — the 2026-09-13 line already in the
block does not carry it. And that record must be a **bare** line: `AmendmentRecordPattern`
(`scripts/enforcement-pack.ps1:651`) anchors at `$` after the date, so an explanatory clause
appended to it is not a record at all. The first attempt failed for exactly that reason; the
explanation now sits in its own paragraph above the record.

The fix to `Get-Territory` — accept a decorated marker, or fail rather than WARN when sibling
phases declare territory — is a check change, outside phase 4's territory, and belongs with the
other parser work.

## Phase 4 — gate (T030)

Certified by the owner 2026-09-16 on the evidence triplet. This is the last phase of the
feature, and the first whose phase commit was graded against a `**Territory**` block the
parser could actually read.

| | |
|---|---|
| Phase commit | `fd07952` (`fd07952a2d69b9c365392333799a8f131f6c284a`) |
| CI run | https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/35083906952 |
| CI conclusion | success |
| Run event | push — the run executed the phase commit itself, not a merge preview |
| Scope check | PASS phase 4 commit `fd07952` (8 files) |
| Approved by | anas.m, 2026-09-16 |

`**Gate Batching**: none`, so the triplet cites phase 4's final commit rather than a batch end.
Three commits pushed together — `c359429` (the round-2 gate record), `3a51f5c` (the approved
Territory repair) and `fd07952` (the phase) — and the push-event run landed on the phase commit
as branch head. CI also reported `AmendmentAuthority: graded 20 of 29 commit(s)`, the nine
ungraded ones being those made before the check existed (D2b).

Digests were regenerated as part of the phase commit: 5 fresh, 80 markers, four of them new in
`adoption/updating.md`.

### The WARN this gate produced, and why it is cosmetic

```text
scope-check: WARN commit 3a51f5c: no territory declared for phase 4 ...
```

The repair commit's own subject reads `docs: repair the phase 4 Territory marker`, and
`scope-check` matches `\bphase\s+(\d+)\b` in the subject, so the repair is read as a phase 4
commit and graded against its parent `c359429` — which still carries the decorated marker the
commit exists to fix. The `phase N`-in-a-`docs:`-subject trap, walked into while fixing the
neighbouring one.

It is cosmetic in substance: the commit touches one file,
`specs/014-amendment-authority/tasks.md`, inside the implicit `specs/NNN-name/**` glob, so a
correctly-read grading passes it too. Left as-is rather than rewritten, because the commit is
pushed and the subject is the honest description of what it does.

It does sharpen the P2 finding above. `Get-Territory`'s blind spot now fails open twice on this
one branch — once through a decorated marker, once through a stale parent — and in both cases
the WARN's "pre-006 compatibility" wording reads as reassurance rather than as a gap. A phase
that declares no territory in a `tasks.md` whose sibling phases all declare it is not a pre-006
file, and the check has the evidence to know that.

## Phase 4 — the review, and what it caught (F1–F7)

Gate 5, held by a fresh-context reviewer with no session context: the phase diff `fd07952`,
`spec.md`, `plan.md` and phase 4's `tasks.md` block, and nothing else. Verdict **REQUEST
CHANGES** — 2 blocking, 5 minor. Filed at `ai-code-review-phase-4.md`; dispositions appended
below the reviewer's text, which was not edited.

Both blocking findings were the same class, and it is the class this feature exists to fight:
**prose an adopter trusts, describing behaviour the code does not have.** Neither was findable
by reading the prose for plausibility. Both required running the scenario the sentence
describes.

### F1 — the document promised a fail-closed the code does not implement

`adoption/updating.md` warned that a shallow clone makes the check grade nothing and look
green — then closed by reassuring the reader that "where the check cannot read what it needs it
now says so and fails rather than skipping quietly." It does not.
`Invoke-AmendmentAuthorityCheck` (`scripts/enforcement-pack.ps1:1054`) is
`if (-not $Base) { return }` — a bare return, nothing printed, exit 0. The reviewer measured it
against a `--depth 1` clone rather than reasoning about it. The partial-clone path is no better:
`Get-CheckPresenceSet`'s B3 hardening *falls back* rather than failing, so unreadable refs make
every commit report as "made before the check existed (plan D2b)" — an affirmatively wrong
reason, still green.

The sentence was the reassurance that made the preceding instruction optional. An adopter who
writes their own workflow reads "set `fetch-depth: 0` there too", then reads that they will be
told if they get it wrong, and they will not be. Fixed by saying the true thing: there is no
failure waiting to catch you, which is exactly why the instruction is not optional.

### F2 — two surgical files listed as arriving verbatim

The flow-down bullet promised `CLAUDE.md` and `docs/sdlc/review-process.md` would arrive with
the update. `kit-manifest.json:4` and `:16` class both **surgical**, and `update-kit.ps1` never
writes a surgical path; `docs/sdlc/repository-strategy.md` is surgical too, changed by this
branch, and was missing from the bullet entirely. All three carry real content — the CLAUDE.md
strict rule, the gate-5 reviewer check, the multi-repo twin of the clause.

An adopter following that bullet ends up running the machine while their agent instructions and
their review checklist never mention the rule: live and unenforced, which `spec.md` US4 names as
the worst state in the kit. The document also already contradicted itself — line 209 calls
CLAUDE.md surgical — and the house convention for flagging a surgical item inline was sitting
twenty lines above in the 012 entry, unused here.

### F3–F6, and F7

Four one-sentence corrections, each verified against the code before acting: the status
exemption is `spec.md`/`plan.md` only (`:1146` — a `tasks.md` status flip fails, demonstrated);
the example block's margin arrows needed naming as annotations, because a record line ends at
the date and the kit had already paid for that lesson one commit earlier in `3a51f5c`; the two
sample failure messages were not faithful transcripts and used `61c57d5`, a real *passing*
commit, as the example of a failure; and the "two exemptions" count omitted the FR-010
renumbering carve-out, now named in the *creation* bullet where D2 already places it rather than
inflating the count. F7 was an observation concurring with the `3a51f5c` WARN already recorded
above, and needed no change.

### What it verified clean, which is half the value

All four renderer-parity cases plus a fifth the reviewer invented; every clause of the
approval-transition condition against `Test-StatusOnlyChange`; the boundary claim and
`fetch-depth: 0` in the workflow; the graded-path set; that T029 touches no other repository;
and that this phase's diff contains **no amendment at all** — `tasks.md` carries six checkbox
flips and nothing else, so the self-approval prohibition is not engaged by phase 4.

The reviewer named the gap that let F1 and F2 through: nothing in the repository tests the prose
against the code. That is reviewer discipline, not a test suite, and it is the third fail-open
this feature has surfaced in its own tooling.

## Phase 4 — gate, re-run after the review (T030)

| | |
|---|---|
| Phase commit | `819abaa` (`819abaa16029c563853c73ca94452c0928f782a8`) |
| CI run | https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/35096709772 |
| CI conclusion | success |
| Run event | push — the run executed the phase commit itself, not a merge preview |
| Scope check | PASS phase 4 commit `819abaa` (3 files) |
| Approved by | anas.m, 2026-09-16 |

`**Gate Batching**: none`. The `fd07952` certification above stands as the record of what was
gated before the review, and is not sufficient for the phase's final state: `819abaa` changed
two statements an adopter acts on. Same shape as phase 3, where `43ab9d2` superseded `5d49cde`.

A timing note, recorded because it is now consistent rather than incidental: the `ritual-checks`
wrapper completes in roughly eight seconds in CI and stalls past ten minutes locally on the same
commit, while its members' own timings add to about four and a half minutes. The verdicts agree;
the stall is in the wrapper's exit on Windows, not in the checks.

### Still homeless — three fail-opens in this feature's own tooling

None is fixable inside any phase's Territory; all three are `scripts/` changes.

| | Defect | Found by |
|---|---|---|
| F1 | `enforcement-pack.ps1:1054` returns bare on an unreadable history; a run that graded nothing is indistinguishable from a legitimately pre-boundary branch | phase 4 review |
| — | `build-digests.ps1` opens a comment on a `<!--` inside an inline code span, silently swallowing the next marker | phase 4 implementation |
| — | `Get-Territory` matches `**Territory**:` at line start only; a decorated marker degrades a phase to a non-blocking WARN carrying a pre-006 excuse | phase 4 implementation |

They are one family: each passes quietly where it should speak. A feature arguing that a check
which fails open is worse than one that is noisy should not leave three of them in the drawer.

## Phase 5 — the check speaks when it cannot grade (T078–T084)

Phase 4's review found F1 by measuring rather than reasoning, and phase 5 was built the same
way: every claim below is a run, and two of them overturned a design I had already written.

### What the check did before

| Condition | Old behaviour | Now |
|---|---|---|
| Shallow clone (`--depth 1`) | `return` with nothing printed, exit 0 | FAIL naming the shallow clone |
| No `origin/main` or `main` | `return` with nothing printed, exit 0 | FAIL naming the unreachable base |
| Parent commit unreadable | counted into `skipBoundary`, reported as "made before the check existed", exit 0 | FAIL naming the parent |
| Lite branch (`fix/`, `chore/`, `docs/`) | returns before the base is consulted | unchanged (FR-009) |

### The four fixtures

Run with the modified script against each tree via `-Root`, which is the omission that made an
earlier local verdict meaningless on this branch.

```text
full clone      exit 0   graded 24 of 33 commit(s) … (9 made before the check existed)   ← control, unchanged
--depth 1       exit 1   cannot grade '014-…' — this is a shallow clone …
no main ref     exit 1   cannot grade '014-…' — no integration branch to diff against …
deleted blob    exit 1   cannot grade '015-test' — parent commit 197418c of 1f13d76 is not readable …
fix/ on shallow exit 0   no AmendmentAuthority line at all                                ← FR-009 held
```

### Two things the fixtures overturned

**`git grep` exits 1 for "unreadable", not 2.** The B3 hardening in `Get-CheckPresenceSet`
assumes an unresolvable ref aborts the search with exit ≥ 2 and falls back to a per-ref probe.
Measured on the deleted-blob fixture, `git grep` prints `error: … unable to read <blob>` to
**stderr and exits 1** — indistinguishable from "searched it, found nothing". So the fallback
never ran, the ref never entered the presence set, and absence from that set was never evidence
of absence. My first attempt at T080 guarded the fallback and changed nothing: the fixture still
graded 0 of 2 commits, let an unapproved amendment through, and reported "made before the check
existed" about a tree that contained the check. Replaced with `Test-CheckAbsentForReal`, which
proves absence at the point of use instead of inferring it.

**A missing commit object is not the only way a ref goes unreadable.** The first discriminator
tested `git cat-file -e <ref>^{commit}` alone. In the fixture the commit and tree are intact and
only the blob is gone, so that test passed and the ref was still treated as pre-boundary. The
helper now asks three questions in order — is the commit here, does the tree list the script,
can the blob be read — and only the middle answer ("the tree does not list it") means the script
genuinely did not exist yet.

The fixture that settled both: a throwaway repository with two commits on an `NNN-*` branch, an
unapproved `plan.md` amendment, and the base commit's copy of `scripts/enforcement-pack.ps1`
deleted from `.git/objects` by hand. Commit and tree readable, blob not — the state a partial
clone produces and the one `--depth 1` hides behind an earlier failure.

### What is deliberately unchanged

The guards live inside `Invoke-AmendmentAuthorityCheck`, after the branch-name return. Other
pack members read the same diff base and were left alone: a null base is a real condition for
checks that legitimately grade a worktree, and turning it into a pack-wide failure would be a
scope change this phase did not declare and did not need. Proven rather than assumed — a `fix/`
branch on the shallow fixture still exits 0 with no `AmendmentAuthority` line.

### The adopter paragraph, corrected a second time

Phase 4 was made to write, truthfully, that no failure was waiting to catch a shallow fetch.
Phase 5 makes that false, so `adoption/updating.md` says what the check now does, and two other
statements in the same section had to move with it: the "arrival day is silent" promise now
carries its one exception (a shallow CI clone fails immediately, which is a verdict on the
checkout and not on the adopter's history), and the digest marker that read *"it grades nothing
and looks green"* now reads *"it fails naming the shallow clone"*. Leaving either would have
reproduced F1 in a new paragraph, which is the specific mistake this phase exists to answer.

### A miss in this phase's own Territory declaration

Changing a digest marker forces `scripts/build-digests.ps1` to rewrite
`docs/digests/adoption-digest.md`, and CI fails on any drift between a rule and its digest — so
the regeneration is not optional. Phase 5's Territory declared `scripts/enforcement-pack.ps1`
and `adoption/updating.md` and not `docs/digests/`, which phase 4's Territory did declare. The
gap is mine: I wrote the Territory before knowing the marker text would have to change. It needs
a one-line amendment, and not one I can approve.
