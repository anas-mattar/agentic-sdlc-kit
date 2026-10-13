# AI Code Review — 024 Critical branch not red, phase 1, round 4

**Reviewer**: fresh-context agent, Claude Sonnet 5.5 (claude-sonnet-5-5), a separate session from the implementer's
**Date**: 2026-10-13
**Branches**: agentic-sdlc-kit `024-critical-branch-not-red` (tip `76879f2`); delta reviewed `git diff 7ca9be6 76879f2`
**Scope reviewed**: `scripts/enforcement-pack.ps1` (`ConvertTo-PhaseNumber`, `Get-CriticalMergeReadiness`, `Invoke-CriticalEvidenceCheck`, the header comment); `specs/024-critical-branch-not-red/` spec.md, plan.md (D1-D8, Risks), tasks.md, notes.md ("Phase 2", "Remediation of the measurement finding"); the three prior reviews; the five new fixtures (recipe.json, expected.txt, command.json); the uncommitted flow-down drafts in the main working tree (`adoption/updating.md`, `docs/sdlc/critical-delivery.md`) for agreement with the code; CLAUDE.md, review-process.md, definition-of-done.md
**Feature contract**: the two arms of the Critical-evidence check are not edited; a Critical branch warns, not fails, for a not-yet-due artifact only while provably mid-feature; everything else, and every non-Critical branch, is byte-identical to today.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5), the same session that wrote the 024 plan/tasks and the phase 1 remediations
- **Inputs provided**: `git diff 7ca9be6 76879f2`; spec.md, plan.md, tasks.md, notes.md; reviews phase-1, round-2, round-3; the script at `76879f2`; clones of FitForge, FlowBoard, ExpenseTracker (made outside the repos)
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The code change is small, correct and does what the amended plan text says: the distinct-heading test and the single `\bphases?\s*(\d+)` token behave correctly under strict mode on every edge I built (scalar `Sort-Object -Unique`, N=1, duplicates with a gap, headings starting at 0 or 2, huge numbers, a subject carrying both a low and a high number). I found no regression and no new false-laxity beyond what the owner's decision accepts. Two things need the owner's eyes; neither blocks the commit. (1) The real-data check shows the fix still does not deliver on FitForge 002 at the two probe states (`81d7424`, `398e75f`): both are strict, not WARN, because FitForge executed phase 11 out of order, which reads as "final landed". That is a third field-data mismatch the measurement did not predict. (2) Plan D3 still carries sentences that assert the anchored form as current. Residual risk sits in the deliberately weak mid-feature evidence (one incidental phase token is enough), which is bounded by the artifact being demanded once a final token lands or the artifact is committed, and by gate 6.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FR-001..FR-005) | Read the delta: only `Get-CriticalMergeReadiness` and its header comment changed in the script (23 lines in one function); the gate in `Invoke-CriticalEvidenceCheck` and both arms are untouched. |
| Heading test under strict mode | Built 28 throwaway Critical repos outside the kit and ran the pack from a `76879f2` worktree: headings 1,1 (N=1) strict, no crash; 1,2,2,3 + one `phase 1` subject = WARN tip=1 N=3; 1,1,2,4 strict, message "found 1, 1, 2, 4"; 2,3,4 strict "found 2, 3, 4"; 1,1,1,3 strict; 0,2,3 strict (the `$distinct[0] -eq 1` clause is what catches it: Count 3 = max 3); 0,1,2 strict; single heading 1 strict; 3,1,2 out of order = WARN; 1,2,3,3,3 = WARN. `@($declared \| Sort-Object -Unique)` keeps `.Count` and `[0]` valid with one element; long vs int comparisons held. |
| Token and finality interplay | Same repos: `spec: add phase 1 plan` = WARN; `Merge branch 'phase1-fix'` = WARN; `Revert "phase 3: x"` strict; `rephase 2`, `biphase 2`, `phase-2`, `phase 0` alone, `tasks: 3 phases defined`, no token = strict "no commit ... phase subject yet"; `phase 0` + `phase 1` = WARN; `phase 99999999999999999999` strict; `phase 03` (N=3) strict; `phase 1 then phase 3` and `phase 3 revisits phase 1` both strict (final); `phases 1-3 landed` = WARN (known limit, disclosed); `Phase2a` = WARN tip=2. |
| Real data, requested states | Cloned `D:\solutions\fitforge` into the scratchpad, branch at `origin/002-identity-member-profile`, `76879f2` scripts overlaid, `enforcement-pack.ps1 -Branch 002-identity-member-profile`: tip (overlay commit on `b9e1d88`) FAIL strict, correct ('phase 17' present); `81d7424` FAIL strict, no mid-feature WARNING; `398e75f` FAIL strict. NOT the expected WARN at the last two. See F1. |
| Real data, whole branch | Ran the pack at all 43 commits of `ff246ea..origin/002`: 17 WARN-mid, 4 strict-with-reason (no tasks.md committed / no phase subject yet, correct), 22 strict-final. Details in F1. |
| Non-Critical branches | ExpenseTracker `003-expense-entry` (non-Critical): output with the `7ca9be6` scripts and with the `76879f2` scripts is byte-identical (diff empty, exit 0 both). FlowBoard has no feature branch (only `main`, `docs/kit-update-*`). Code reading agrees: the level test returns before `Get-CriticalMergeReadiness` is reached. |
| Amendment authority | `enforcement-pack.ps1 -Branch 024-critical-branch-not-red` in a `76879f2` worktree: `AmendmentAuthority: graded 17 of 18 commit(s)`, `enforcement-pack: OK`, exit 0. |
| Harness | `Run-Tests.ps1 -Case enforcement-pack/CRIT-`: 164 passed, 0 failed (full harness not run, as instructed). |
| Constitution / domain invariants | See re-check below. |
| Scope guard | The delta touches the script, the 024 documents and five new fixture directories under `tests/enforcement/cases/enforcement-pack/CRIT-R01` and `CRIT-R02`; no unrelated file. Commit `76879f2` is 560 lines/17 files, flagged by the pack's own PhaseSizeWarning (non-blocking; fixtures dominate). |
| Rollback safety | One function body plus fixtures; reverting the commit restores round-3 behaviour. |

## Findings

### F1 — The real Critical feature is still strict at the probe states: phase 11 ran out of order — CONFIRM

The delta's stated purpose is that FitForge 002 gets a WARN mid-feature. It does so for 17 of its 43 branch commits, and not at `81d7424` or `398e75f`. Measured with the `76879f2` scripts at every commit of `ff246ea..origin/002-identity-member-profile`:

- Early (declared N=11): `9a5bf35` (first `phase 1` subject) to `9956f59` (phase 3 implementation) = WARN, 8 commits. Correct.
- `bd6c737` (`tasks/plan: A4 approved - real SQL Server, and the CI wiring gets phase 11`) to `85ff3db` = strict, 19 commits, with no `not treated as mid-feature` line (the check judged "final landed"). Cause: tasks.md declares `## Phase 11: Test database wiring (runs next — before phases 4–10)`. The highest-numbered phase was executed before phases 4-9, so the first `phase 11` token reads as the final phase. At that point phases 4-10 were genuinely not done, so the artifact is NOT due and the check demands it: a false strict, in the safe direction, but exactly the red-mid-feature state 024 exists to remove. `81d7424` and `398e75f` are inside this window.
- `5c740f1` (`phase 10`, all eleven landed) strict: correct.
- `aef4c85` to `bfc2d8e` (amendment A6 declares phases 12-17, N=17) = WARN, 9 commits. Correct.
- `1d962af` (`docs: amend auth contract section 6, declare phase 17`) strict: a subject that merely DECLARES phase 17 reads as phase 17 landed. Early and noisy, safe direction.

This is not a code defect: the code does exactly what D3 says. It is a plan-level gap: "final = token >= max heading" assumes ascending execution. The fixtures were built from the kit's convention (phases landing in order, N fixed); the field differs (out-of-order execution, N raised by amendment). The notes' framing that the remediation fixes the one real Critical feature "at every point of its history" is not what the data shows, and the flow-down and the phase 2 record should not say so.
*Action: owner decision, not a code change in this review. Either accept and record in notes.md ("WARN on 17 of 43 commits of FitForge 002; the out-of-order phase 11 window stays strict") or amend D3, for example reading final as "a token >= N AND every phase 1..N-1 also has a token". That variant is laxer for a branch whose commits do not name every phase, so it needs its own owner-approved amendment and its own fixtures. Either way, rerun the T009 measurement to confirm what it claims.*

### F2 — Plan D3 and Risks still assert the withdrawn anchored form as current — DOC DRIFT

The new D3 paragraph says "the anchored `^phase\s+k` form is withdrawn", but older text was not marked superseded:
1. D3's note after the first paragraph reads "*Superseded in part by the two amended paragraphs below.* The anchored form ... now apply only to showing that the branch is mid-feature at all". There are now three amended paragraphs, and the anchored form applies to nothing.
2. The "phase 1 AI review (F1, F3)" paragraph says "the anchored `^phase\s+k` form is kept only to establish that the branch is mid-feature at all".
3. The "round 2 (F2)" paragraph says "The anchored mid-feature form is unchanged."
4. The new paragraph sits between 2 and 3 and uses the token `\bphases?\s*(\d+)` that paragraph 3 introduces afterwards, so a linear reader meets "withdrawn" and then "unchanged".
5. Risks, first bullet: "only a branch that already carries phase commits `1..k`, `k < N`, qualifies"; the code needs one token below N, not a run 1..k. The first D3 paragraph says the same.
6. Script header: the changed paragraph has a stray sentence appended mid-line ("One token reads both evidence and finality (plan D3 as amended).") making one very long comment line; cosmetic.
Code, tasks T004 and the uncommitted flow-down drafts say the right thing. D2 is clean: its first paragraph no longer lists "a duplicate", and the new paragraph carries the rule.
*Action: implementer, in an approver-recorded amendment of D3: change the note to say the anchored form is withdrawn by the latest amendment, add "(superseded by the phase 2 amendment)" to items 2 and 3, move the new paragraph after the round-2 one, reword the `1..k` phrases in D3 and Risks to "at least one phase token below N", and re-flow the header comment.*

### F3 — Mid-feature evidence is now one phase token anywhere, including incidental and merge subjects — MINOR (accepted by the owner)

Plain statement of which loosened states earn the WARN (all verified above):
- `spec: add phase 1 plan`, `plan: ... phase 2`, `notes: see phase 2`, `Merge branch 'phase1-fix'` (a merge subject): WARN. Acceptable: the artifact is still owed and is demanded the moment a subject names phase N or beyond or the artifact is committed; gate 6 stands behind it. A branch with only claim/spec/plan/tasks commits that mention a phase also WARNs, arguably right (nothing is due yet).
- Tokens inside other words (`rephase 2`, `biphase 2`), `phase-2`, `phase: 2`, `phase 0` alone, no token: strict. Good.
- Big numbers and `phase 03` for N=3: strict (read as >= N). A subject with both a low and a high number is strict in either order (the loop returns on the first token >= N whatever precedes it).
- `phases 1-3 landed`, `phase 1 and 3`: WARN while a final lands unrecognised. This is the already-disclosed hole of Risks bullet 1, no wider in kind; its population is wider because any single token now earns the WARN. The WARN prints on every run, so the artifact cannot be forgotten silently.
- A subject that merely declares the final phase (`declare phase 17`) makes the branch strict early: noisy, safe (F1).
No real hole beyond the disclosed one. One theoretical vector: a non-phase heading numbered N+1 (e.g. `## Phase 12 amendment request` with real phases 1-11) invents a final phase and holds the branch on WARN until a `phase 12` token appears; contiguity cannot see it because the number is contiguous. It needs a hand-written heading, shows on every run, and gate 6 stands behind it.
*Action: none; optionally add the N+1 amendment-heading sentence to Risks.*

### F4 — Fixture pairs are sound; some wrong implementations are not pinned and the field's out-of-order shape has no fixture — MINOR

Read all five recipes. `pass-duplicate-headings-mid-feature` differs from the control `pass` only in the two extra headings; `pass-loose-phase-subjects-mid-feature` only in the subjects; `pass-field-shaped-mid-feature` in both (by design); `fail-field-shaped-final` from it only in a third commit (`tasks: phase 3 done`); `fail-gap-with-duplicate-headings` (1,1,2,4) fails on the one condition that a gap is present. Wrong implementations they catch: still anchored (loose-subjects and field-shaped fail), still rejecting duplicates (duplicate-headings and field-shaped fail), "any duplicate is fine" or skipping contiguity when a duplicate exists (the gap-with-duplicate case would WARN instead of FAIL). Not pinned: dropping the `$distinct[0] -eq 1` clause (headings 0,2,3 pass the count test alone; strict today only through that clause); N=1 / duplicate-only headings; phase 0; and, per F1, out-of-order declaration with the top phase landing early. None is broken today (verified by hand).
*Action: implementer, with F1: add a fixture for the out-of-order shape whatever the owner decides, and optionally one for headings 0,2,3.*

## Amendments in this diff

- [x] Amendments listed:
  - `plan.md` D2: new "Amended after the phase 2 measurement (FitForge 002)" paragraph (distinct numbers 1..N; "a duplicate" removed from the first paragraph). Record: `**Amendment approved by**: anas.m, 2026-10-13`. Conforming.
  - `plan.md` D3: new "Mid-feature evidence is read with the same token as the final phase" paragraph. Record: `**Amendment approved by**: anas.m, 2026-10-13`. Conforming. Stale older paragraphs: F2.
  - `plan.md` Risks: the "Mid-feature is anchored, final is not" bullet rewritten to "Mid-feature and final are read with one token". No approver line of its own (the section has none; the commit trailer covers it). Acceptable, noted.
  - `tasks.md` T004 reworded, with a second `**Amendment approved by**: anas.m, 2026-10-13 (T004 reworded after the phase 2 measurement)` line beside the first. Conforming.
  - Commits `b1e5271` (plan and tasks amendment) and `76879f2` both carry `Amendment approved by: anas.m, 2026-10-13`; the amendment-authority check passes (graded 17 of 18, OK).
  - `notes.md` additions are a record, not an amendment.

## Constitution re-check (post-implementation)

PASS. I (amendment authority): both decisions amended in their own commit before the code, approver recorded, not self-approved. II (ladder): code, plan and tasks agree on the rule; the older D3 paragraphs are the only stale text (F2). VII/VIII (evidence, never claim success): the check still certifies nothing; the WARN says "a WARN, not a pass" on every run. X (Critical): the arms and the artifact requirement are unchanged; the artifact is still demanded from the final token or its commit. No package, no schema, no new member.

## Test coverage observed

`Run-Tests.ps1 -Case enforcement-pack/CRIT-`: 164 passed, 0 failed (includes the five new cases and every pre-existing CRIT-R01/R02 case). The implementer reports the full harness at 1470 passed, 0 failed; I did not re-run it. Beyond the harness: 28 adversarial repos plus 4 further heading shapes, a 43-commit sweep of the real FitForge 002 history, and a before/after byte-compare on ExpenseTracker `003-expense-entry`.

## Residual risk

1. F1: on the one real Critical feature, 19 of 43 commits (the whole phases 4-9 stretch) stay strict, so an owner on FitForge-like work would still see a red Critical branch for much of its life. That is what 024 was written to stop; it needs an owner decision (accept and record, or amend D3 and add a fixture).
2. The mid-feature evidence is weak by design (F3); the hole it can widen is the already-disclosed final-commit-names-no-phase one, backstopped by the printed WARN and gate 6.
3. D3's stale paragraphs (F2) can mislead the next maintainer into restoring the anchored form; fix before merge.
Merge after F2 is repaired and the owner has recorded a decision on F1.
