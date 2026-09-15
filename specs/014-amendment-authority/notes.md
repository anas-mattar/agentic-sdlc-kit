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
they were actually committed**, identified by sha rather than by reconstruction:

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
`92455d6`, `3cb6e34` — are each still flagged, by sha. SC-002 and SC-004 stand exactly as
phase 3 first recorded them, which is the only evidence that matters here: 66 git calls and 20
git calls reached the same verdict on the 23 + 121 commits they graded, none of which
was written for this check.
