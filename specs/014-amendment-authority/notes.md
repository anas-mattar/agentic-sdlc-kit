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
self-approval prohibition — is byte-identical to FitForge 1.1.0. The phase 1 reviewer verified
this with a direct `diff` rather than by reading.

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

## Phase 1 remediation — gate

To be recorded here once the remediation commit has been gated and re-reviewed.
