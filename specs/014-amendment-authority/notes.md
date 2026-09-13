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
  It is already pushed, so history is not rewritten for it; `scope-check` grades the last
  phase-token commit, which is the real phase commit, so nothing is mis-graded — but the
  subject is wrong and the record says so. The durable lesson is that a rule written in a
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
