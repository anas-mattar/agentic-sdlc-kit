# AI Code Review — 024 Critical branch not red, phase 1, round 3

**Reviewer**: fresh-context agent, Claude Sonnet 5.5 (claude-sonnet-5-5)
**Date**: 2026-10-13
**Branches**: D:\solutions\agentic-sdlc-kit `024-critical-branch-not-red` (tip `20855f5`); delta reviewed `85e4e64..20855f5`
**Scope reviewed**: `git diff 85e4e64 20855f5` (scripts/enforcement-pack.ps1, plan.md, tasks.md, notes.md, 4 new CRIT-R01 fixtures); `Get-CriticalMergeReadiness` and `Invoke-CriticalEvidenceCheck` read in full; plan D1-D4 and Risks, tasks T004, notes round 2 table; CLAUDE.md; constitution I (Amendment authority) via grep.
**Feature contract**: Critical branch gets a WARN, not a FAIL, for a not-yet-due independence artifact only while provably mid-feature; strict (parent behaviour) otherwise; arms unedited; no new package.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5), the same session that wrote the 024 plan/tasks and the phase 1 remediations
- **Inputs provided**: the delta diff `85e4e64..20855f5`, spec.md, plan.md, tasks.md, notes.md, the two prior reviews' existence and the round 2 findings as summarised in notes.md, CLAUDE.md, the review template, and the code at `20855f5` in a detached worktree outside the repository
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The code delta is exactly one regex (`\bphase\s+(\d+)\b` to `\bphases?\s*(\d+)`) inside the Critical-only function, so non-Critical branches and merge-ready or undeterminable Critical branches cannot be affected. The widening does what the plan says: it reads `phase3`, `phase 3a`, `phases 3`. I found no direction in which the new regex makes a legitimate mid-feature branch wrongly red beyond the already-accepted noise, and no regression of the lax kind. What I did find is that the documented residual hole is described too narrowly (F1) and that the D1 amendment has no approver line beside it (F2). Neither blocks the merge. The amendment-authority check passes on the branch.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | Read `Get-CriticalMergeReadiness` (scripts/enforcement-pack.ps1 L332-396) and the gate (L397-424). End-to-end throwaway repos (below): phase 1 only gives WARN exit 0; phases 1,2 plus `phase 2: handle 3 users` gives WARN exit 0; phases 1,2 plus `phase 3.1` gives FAIL exit 1; lone `phase3: x` gives FAIL exit 1. |
| Visual-reference match | N/A: no UI. |
| Feature contract held | Delta touches no arm, no package. `git diff --stat`: 1 script file (+3/-2 lines), 4 fixture dirs, 3 spec docs. |
| Constitution / domain invariants | See re-check. `pwsh -File scripts/enforcement-pack.ps1 -Branch 024-critical-branch-not-red` in the worktree: `AmendmentAuthority: graded 13 of 14 commit(s) ... (1 not graded: 1 merge commit(s))`, only PhaseSizeWarning warnings, `enforcement-pack: OK`. |
| Security | No input reaches a shell; the regex is applied to `git log --format=%s` text, the number goes through `[long]::TryParse`. Overflow and non-ASCII digits resolve to MaxValue, which is strict. |
| Scope guard | `git diff --stat` read. The warning for commit 20855f5 (415 lines, 14 files) is non-blocking; it is mostly four recipe.json fixtures. |
| Rollback safety | Revert is a one-line regex plus fixtures; no schema. |

Regex trace (pwsh, `[regex]::Matches($s,'(?i)\bphases?\s*(\d+)')`; "loose" = digits captured):

- Not read as a phase (no capture): `phase-3`, `phase_3`, `phase #3`, `phase: 3`, `Phase III`, `biphase 3`, `phased 3`, `emphasis 3`, `rephase 3`, `multiphase 2`, `my_phase 3`, `x2phase 3`.
- Read as lower than the one meant: `phase 1 and 3` gives 1; `phases 2-3` gives 2; `phase 2/3` gives 2; `phase 1,000` gives 1.
- Read correctly: `phase<TAB>3`, `PHASE3`, `phase  3`, `phase 03`, `phase 3.1` all give 3. `phase 2: handle 3 users` gives only 2. `phase 1: remove phases 3 and 4 from scope` gives 1 and 3, so a final phase of 3 reads as landed.
- Non-ASCII digits: `\d` matches full-width `１２` and Arabic-Indic `٣` (Unicode). `[long]::TryParse` rejects them, so the value is MaxValue, which is at or above any final phase, so strict. Confirmed in the trace; the same MaxValue path applies to the anchored form, but the loose check for the same subject returns first.
- Anchored mid-feature form `^(?i)phase\s+(\d+)\b` is byte-unchanged; `phases 2-3` and `phase-3` do not count as a tip. Consistent with "mid-feature only on a subject that begins `phase k`".

End-to-end (throwaway team-mode repos built outside the repo with the worktree's script; tasks.md with phases 1-3; commits `phase 1: a`, `phase 2: b`, then the final subject; branch `001-thing`):

| Final subject | Result |
|---|---|
| `phase 1 and 3`, `phases 2-3`, `phase 2/3`, `phase-3`, `phase: 3`, `phase #3`, `Phase III`, `biphase 3` | WARN "not yet due ... phase 2 of 3", exit 0 (final commit reads as mid-feature) |
| `phase 2: handle 3 users` | WARN, exit 0 (correct: 3 is not read as a phase) |
| `phase 3.1`, `phase3: x` | FAIL, human-pr-review.md missing, exit 1 (read as final: correct) |
| Only commit `phase3: x` (no `phase k` anchored commit) | FAIL exit 1: tip stays 0, "no commit on the branch carries a phase subject yet", strict |
| Only commit `feat: phase3 x` plus `chore: y` | FAIL exit 1, same reason |
| `phase 1: remove phases 3 and 4 from scope` then `phase 2: b` | FAIL exit 1 (strict early: accepted noise) |
| `phase 1: a` only | WARN "phase 1 of 3", exit 0 |

## Findings

### F1 — The residual hole is wider than plan Risks says — DOC DRIFT

plan.md Risks bullet 1 (as amended in this delta) says the branch stays on the WARN only when "a final commit names no phase (no `phase N`, `phaseN`, `phase Na` or `phases N` token anywhere in its subject)". The trace above shows final commits that do name phase 3 and still read as mid-feature: `phase 1 and 3`, `phases 2-3`, `phase 2/3` (the regex reads the first number only), and `phase-3`, `phase: 3`, `phase #3`, `Phase III` (a separator between the word and the digits). These end-to-end runs exited 0 with the WARN. This is not a regression: the old token was strictly narrower (it never saw `phases 2-3`, `phase3`, `phase 3a`), and it is the same disclosed hole (gate 6, the human review at merge, stands behind it). The widening is harmless in the lax direction: I found no subject that the new regex reads as a lower number when the old one read a correct one. It is a statement that is slightly false, in the document the owner approved. Of the spellings tried, `phase: 3` and `phase-3` are the plausible ones for a kit that writes `phase N:` subjects; a loose `[\s:#_-]*` between word and digits would close them, at the price of more noise, and is a choice for the owner, not required.
*Action: owner decides: either reword Risks bullet 1 and D3 to "a final commit whose subject does not give the phase number directly after the word `phase`/`phases`" (one-line amendment with approver), or widen the separator class. No code change required for approval. Resolution check of round 2 F2 (token widening): resolved; the three spellings it named are read and each fixture fails on the old regex.*

### F2 — D1 amendment has no approver line beside it — DOC DRIFT

notes.md says each rewritten section (D1, D3, Risks, T004) has an approver line. In plan.md the approver lines are at L95 and L102 (after the two D3 paragraphs), L198 (inside Risks, after bullet 2) and L205 (end of the Risks list), and tasks.md L34 (Phase 1 block). The D1 paragraph (plan L57-62, rewritten in this delta: return shape `Pending; Why; Final; Tip` and the `WARNING` naming `Why`) has no approver line of its own, and L198 sits mid-list between two bullets. The commit messages of `ef8284a` and `20855f5` name anas.m, and `scripts/enforcement-pack.ps1` passes the amendment-authority check (13 of 14 graded), so the machine rule is satisfied; this is about the human-readable record the constitution describes (one record per amended section). T004 in tasks.md has no approver line immediately after it either; the one at L34 is in the Phase 1 block above T001.
*Action: add `**Amendment approved by**: anas.m, 2026-10-13` under D1 (and move the L198 line to the end of the bullet it belongs to, or drop it in favour of L205). Owner-approved amendment recorded by the owner, not the implementer.*

### F3 — D3's first paragraph still says the opposite of the code — MINOR

plan D3's first paragraph still says merge-ready is read by `^(?i)phase\s+N\b` anchored at the start and that scope-check's loose token "is not reused". The two amendment paragraphs below it supersede that, and the code (L378-381, L387) is the loose token for final and the anchored form for tip, exactly as the second amended paragraph and Risks bullet 2 say. Sentence-by-sentence: D1, D3 (both amended paragraphs), Risks bullet 2, T004 all match the code (final token `\bphases?\s*(\d+)` anywhere, case-insensitive, `[long]`-safe; anchored form only for the tip; committed artifact ends the pending state; the arms are not edited; undeterminable states are strict with a `WARNING` naming `Why`). A reader who stops at the first paragraph of D3 is misled.
*Action: none required for merge; at the next plan amendment, mark the first paragraph "(superseded below)".*

### F4 — Fixtures and the noise cases — ACCEPTED

The three new `fail-phase-token-*` fixtures differ from `pass-limit-final-commit-names-no-phase` only in the final subject (I diffed `fail-phase-token-plural` against it: description and message only). Each catches a distinct wrong implementation: `phase3` fails a `\s+` regex, `phase 3a` fails a trailing `\b`, `phases 3` fails a singular regex. The CRIT harness cases all pass (below). `pass-artifact-committed-mid-feature` differs from its fail pair in the commit message, the heading (`## Review Provenance` vs `## Provenance Of The Review`) and the added Attestation line: three edits, all one condition (validity of the review), so a gate that ignored the artifact's content would fail it. No fixture covers `phase: 3`, a non-ASCII digit or `phase 2: handle 3 users`; that is not required. Acceptable noise (strict early, no action): `phases 3 and 4 reordered`, `phase 1: remove phases 3 and 4 from scope`. Words containing `phase` (`biphase 3`, `phased 3`, `emphasis 3`, `rephase 3`, `multiphase 2`, `my_phase 3`, `x2phase 3`) are not read: `\b` blocks them. `phase 2: handle 3 users` does not read 3. Trace of `phase3: x` as the only phase commit: the loose form sees 3, which is final here (so strict via not-pending) for a one-phase tasks.md; for a three-phase tasks.md the anchored form does not see it, the loose form reads 3 and returns Pending=false at once (the subject names the final phase), so the branch is strict (FAIL exit 1 as observed), the safe direction.
*Action: none.*

## Amendments in this diff

- [x] Amendments listed:
  - plan.md D1 (return shape and gate text) — approver record: commit `ef8284a` names anas.m; no per-section approver line (F2).
  - plan.md D3, second amended paragraph (token widened) — `**Amendment approved by**: anas.m, 2026-10-13` at L102; commit `20855f5` names "Amendment approved by: anas.m, 2026-10-13".
  - plan.md Risks bullets 1 and 2 — approver lines at L198 and L205; commit `ef8284a` names anas.m.
  - tasks.md T004 text and an approver line in the Phase 1 block (L34); commit `ef8284a` names anas.m.
  - notes.md round 2 table: not a graded feature document under the rule.
  The amendment-authority check on the branch passes (see above). The implementer did not self-approve: each record names anas.m.

## Constitution re-check (post-implementation)

PASS. Principle I (amendment authority): satisfied mechanically, with the F2 record-shape nit. The relaxation stays narrow (a WARN only while provably mid-feature; every undeterminable state strict with a reason). No new package, no architecture change. Non-Critical: `Invoke-CriticalEvidenceCheck` returns before the changed code unless the spec declares Critical, so that path is byte-identical. Merge-ready Critical: `Pending=false` with `Why=$null` calls the arm unchanged and emits nothing extra. Undeterminable Critical: unchanged (those return before the loop).

## Test coverage observed

`pwsh -File tests/enforcement/Run-Tests.ps1 -Case enforcement-pack/CRIT-` in the detached worktree at `20855f5`: Tests Passed 154, Failed 0, Skipped 0 (122.5 s), `enforcement-tests: OK`. I did not run the full harness (~18 min, as instructed). Additionally ran: the regex over 27 subject spellings in pwsh, and 15 throwaway repos built outside the repository (table above). The throwaway worktree branch I created for the run (`rv3tmp`) was deleted with the worktree; `git worktree list` shows only the main checkout and `git status` is clean.

## Residual risk

Concentrated in the single disclosed hole (a final commit not recognised as final, with the artifact not yet committed): now narrower than the parent and than round 2, but wider than Risks bullet 1 now claims (F1). Behind it stands gate 6, a human review at merge, not a machine check. The plausible bad outcome is a team that writes `phase: 3` or `phase-3` and keeps a warning-only branch up to merge; the printed WARN on every run is the mitigation. This delta introduced nothing new in the lax or the wrongly-strict direction.
