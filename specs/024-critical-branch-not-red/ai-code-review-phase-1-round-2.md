# AI Code Review — 024 Critical branch not red, phase 1, round 2

**Reviewer**: fresh-context agent, claude-sonnet-5-5 (Sonnet 5.5)
**Date**: 2026-10-13
**Branches**: agentic-sdlc-kit `024-critical-branch-not-red` (reviewed commit `4c8fe99`)
**Scope reviewed**: `git diff 4c8fe99~1 4c8fe99` (35 files: `scripts/enforcement-pack.ps1`, notes.md, 11 new fixture cases under `tests/enforcement/cases/enforcement-pack/CRIT-R01` and `CRIT-R02`); `git show 169e93d` (plan D3 amendment); `Get-CriticalMergeReadiness`, `ConvertTo-PhaseNumber`, `Invoke-CriticalEvidenceCheck` as built; spec.md, plan.md (D1-D8, Risks), tasks.md, notes.md, the round-1 review (F1-F7), CLAUDE.md, constitution I (Amendment authority), `Get-DeveloperMode` in `scripts/adoption-lib.ps1`.
**Feature contract**: Shape B. A Critical branch gets a WARN, not a FAIL, for a not-yet-due independence artifact only while provably mid-feature. Strict (today's behaviour) otherwise. The two arms are not edited. No new package or file.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5 (Sonnet 5.5)
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5), the same session that wrote the 024 plan/tasks and the phase 1 remediation
- **Inputs provided**: commit 4c8fe99 diff and log back to 5fc1274; spec.md, plan.md, tasks.md, notes.md; round-1 review `ai-code-review-phase-1.md`; CLAUDE.md; constitution; `scripts/adoption-lib.ps1`; the recipes and expected.txt of every CRIT-R01/R02 case.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The remediation does what the amended D3 says. A committed artifact ends the pending state, so the arm runs and grades it. A phase token anywhere in a subject at or beyond the declared final phase reads as final. Phase numbers parse through `[long]::TryParse`, so overflow is strict and nothing crashes. I found no way the new rule turns a previously-FAIL state into a pass other than the intended mid-feature WARN: it only moves states toward strictness, and the arm always runs after it. My adversarial scenarios produced no false laxity beyond the already-disclosed limit family, no crash, and no change to merge-ready or non-Critical output. The `-Case enforcement-pack/CRIT-` run passed (146 passed, 0 failed). The follow-ups are one doc-drift defect (the plan Risks and tasks T004 now contradict the code) and three minor items. Residual risk sits in the heuristic: a final commit whose subject has a near-miss spelling (`phase3`, `phase 3a`, `phases 3`), with no artifact committed, still reads as mid-feature.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match | FR-001 (WARN mid-feature): `CRIT-R01/pass`. FR-002 (strict state unchanged): pre-existing `CRIT-S*`/`CRIT-T*` cases pass unchanged in my run. FR-003 (undeterminable stays strict with a reason): `CRIT-R02/fail*` cases. I read the code as built. |
| Visual-reference match | N/A, no UI. |
| Feature contract held | The two arms (`Invoke-CriticalSoloEvidence`, `Invoke-CriticalTeamEvidence`) are not in the diff. The gate returns before the arms only when `Pending`. No new file or package. |
| Constitution / domain invariants | See the re-check below. |
| Security | Nothing sensitive is read. Only committed blobs and commit subjects. The `git cat-file`/`git show` arguments are built from the branch name, already validated by `^\d{3}-`. |
| Scope guard | `git diff --stat` read: 1 script, 1 notes file, 33 fixture files. The size warning (1255 lines / 35 files) is non-blocking, and fixtures-first explains it. In my worktree at 4c8fe99 I ran `enforcement-pack.ps1 -Branch 024-critical-branch-not-red`: `enforcement-pack: OK`, AmendmentAuthority "graded 9 of 10 commit(s)" (the 10th is a merge commit). `scope-check.ps1` returned n/a on my scratch branch name, so I did not obtain a PASS from it. |
| Rollback safety | One function added and one parameter on one function. Reverting the commit restores the round-1 behaviour. |
| Tests run | Detached worktree outside the repo: `pwsh -File tests/enforcement/Run-Tests.ps1 -Case enforcement-pack/CRIT-` gave `Tests Passed: 146, Failed: 0`, `enforcement-tests: OK`. I did not run the full harness. |
| Adversarial scenarios | Throwaway repos outside the repo, run with `scripts/enforcement-pack.ps1 -Root <repo> -Branch 001-thing` (3-phase tasks.md, team mode unless stated, history `phase 1`, `phase 2`, then one more commit). Results under the resolution checks and F2-F3. |

## Round-1 findings: resolution check

- **Round-1 F1 (final commit not named `phase N`): RESOLVED.** Both options are built and observed.
  - Phase token anywhere (final=3, history `phase 1`, `phase 2`, then X, no artifact): X=`Phase  3: c` (two spaces) FAIL; X=`phase 03: c` FAIL; X=`Revert "phase 3: x"` FAIL; X=`phase ٣: c` (Arabic-Indic digit) FAIL (`TryParse` rejects it, so it reads as beyond the final phase, which is strict); X=`phase 10: c` FAIL; with final=1 and X=`phase 3: c` FAIL.
  - A lower phase never reads as final: X=`phase 1 of 3 cleanup`, X=`PHASE 2 done`, X=`feat: add thing (phase 2)` all stay WARN with "at phase 2 of 3". With final=12 and X=`phase 3: c`: WARN, "phase 3 of 12".
  - Artifact committed: a committed garbage `human-pr-review.md` at tip phase 2 gives FAIL with the arm's own "no visible '## Review Provenance' section" message (scenario b1, and fixture `fail-artifact-committed-invalid-mid-feature`).
  - A committed valid artifact with an unnamed final commit gives OK and no WARN (fixture `pass-artifact-committed-final-commit-unnamed`).
  - The remaining limit is asserted by fixture `pass-limit-final-commit-names-no-phase`.
- **Round-1 F2 ([long] overflow): RESOLVED.** Subject `phase 99999999999999999999: c` gave a normal FAIL (final reached) with no crash. The heading overflow is covered by `CRIT-R02/fail-heading-number-overflow`, which passed in my run. In the code, `ConvertTo-PhaseNumber` returns `[long]::MaxValue` on failure; the heading path treats that as a strict reason and the subject path as beyond-final. Under StrictMode I saw no type error: `$declared.Count -eq $final` and the sort/unique contiguity expression behaved correctly with `Measure-Object` output (10-phase and 12-phase files). The `$matches` use is safe: the `[regex]::Matches` loop does not touch `$matches`, and each `-match` result is consumed in the next statement.
- **Round-1 F3 (invalid artifact ungraded mid-feature): RESOLVED.** Same evidence as F1 (b1). Solo, artifact committed then deleted from the working tree (b2): FAIL from the arm ("missing"), so the arm always runs after the new rule.
- **Round-1 F4 (solo cooling-off fixtures): RESOLVED.** `pass-solo-artifact-old-mid-feature` and `fail-solo-artifact-young-mid-feature` differ in exactly one line, `hoursAgo` 25.0 vs 23.5 (diff observed). The fail expects the arm's own cooling-off message, a real assertion that the arm runs mid-feature.
- **Round-1 F5 (unfixtured states): RESOLVED for comment heading and two-digit phases; the `git log`-failure claim is ACCEPTED.** `fail-comment-heading-not-counted` differs from `pass` only by the `## Phase 3` block moved inside `<!-- -->`; `pass-two-digit-phases`/`fail-two-digit-final` differ by exactly one `phase 10` commit. On the claim: the base is a verified `merge-base` result, so no recipe makes `git log base..HEAD` fail while the rest of the pack runs; the strict reason is a one-line branch and the notes say it is read, not proved. I judge that acceptable.
- **Round-1 F6 (two-rule layout): STILL OPEN, owner's call.** Notes still record the owner's confirmation as outstanding.
- **Round-1 F7 (strict reasons add a WARNING line): the notes' explanation is VERIFIED.** Pre-existing `CRIT-S*`/`CRIT-T*` cases pass unchanged because their branches are ready (a one-phase `tasks.md`, a phase-1 commit) or already carry the artifact, so `Why` is null. Caveat for the brief: undeterminable Critical branches are NOT byte-identical to before 2300e44; they carry the extra `WARNING: CriticalEvidence: not treated as mid-feature - ...` line (visible in the `CRIT-R02/fail*` expected output and in my shallow-clone run). That is accepted round-1 F7 and FR-003. Merge-ready output is unchanged by reading (`Why = $null`, no line), and non-Critical returns before the new code.

## Findings

### F1 — Plan Risks and tasks T004 contradict the amended D3 and the code — DOC DRIFT

The D3 amendment (commit 169e93d) rewrote D3, but left stale statements in the same plan.
- plan.md Risks bullet 1 (line 181) still says "a final commit that does not begin `phase N` is not seen as final". Its first sentence (line 179) already carries the new wording, so the bullet states both. The code and amended D3 read a phase token anywhere in the subject.
- Risks bullet 2, "Anchoring is narrower than scope-check", says `feat: phase 4` is not read. Observed otherwise: `feat: phase 3 step` is read as final (fixture `fail-phase-token-mid-subject`).
- tasks.md T004 still describes subjects "anchored at `^(?i)phase\s+N\b`". Plan D1 still names `Ready`/`FinalPhase` where the code returns `Pending`/`Final`/`Tip`, and D6 still lists R01 to R06 (the round-1 F6 deviation).
A reader applying the plan would predict the wrong outcome for `feat: phase 3`. The "Amendment approved by" line sits after the Risks section, so an edit to these lines needs its own approver record.
*Action: implementer corrects Risks bullets 1 and 2, T004 and D1 through a recorded amendment (an `**Amendment approved by**` line, the same approver in the commit message), approved by the owner; I did not make this change.*

### F2 — Near-miss final-commit spellings still leave the branch on the WARN — MINOR

The token regex is `\bphase\s+(\d+)\b`. Observed (final=3, history `phase 1`, `phase 2`, then X, no artifact committed): X=`phase3: c`, X=`phase 3a: c` and X=`phases 3: c` each print the WARN, exit 0, "at phase 2 of 3", though the final phase has landed. This is false laxity of the same family as the disclosed limit, but the disclosed wording is "names no phase" while these do name one. The safe direction is unaffected, and gate 6 stands behind it.
*Action: owner decides whether to widen the token (for example `phase\s*(\d+)` and a letter suffix) or keep the limit and have the phase 2 guidance tell authors to write `phase N` with a space and no suffix. No code change is needed for approval.*

### F3 — Committing the artifact early turns the whole branch red; an uncommitted artifact stays on the WARN — MINOR (design consequence)

Both observed.
- A committed artifact (even a template stub) at tip phase 2 makes the arm grade it now (b1: FAIL). An author who commits the stub early is red from then on, the situation 024 exists to remove. It follows from the amended D3 and is the author's act, but the guidance does not say it.
- An artifact that exists only in the working tree (solo, tip phase 2) gives WARN, exit 0 (b7), where the parent commit failed it ("no git history"). That is inherent in shape B.
- Related, consistent: with an unparsable `kit-adoption.json` (`{bad`), `Get-DeveloperMode` resolves to solo (b4). A committed team `human-pr-review.md` then does not end the pending state, because the solo artifact is the one checked. The same mode picks both the artifact and the arm.
- Also fine, observed: a governance repo in a subdirectory `gov/` resolves `HEAD:./specs/...` correctly (committed garbage artifact graded; without it, WARN). A shallow clone with the artifact committed is graded by the arm with no extra WARNING line (output equals the pre-024 output); without it, the strict shallow-clone reason is printed. So checking the artifact before the base/shallow checks is right.
*Action: implementer states the commit-early consequence in the phase 2 guidance (`critical-delivery.md` item 5 and the flow-down note); no code change.*

### F4 — One new fixture pair is not a one-condition pair — MINOR

`pass-artifact-committed-final-commit-unnamed` and `fail-artifact-committed-invalid-mid-feature` differ in three conditions at once (the final commit present or absent, the heading text `Review Provenance` vs `Provenance Of The Review`, and the attestation sentence). The other new pairs differ in exactly one condition (age 25h vs 23.5h; heading hidden vs shown; a `phase 10` commit present or absent). There is also no team-arm case with a VALID artifact committed while mid-feature (tip phase 2) expecting OK and no WARN; the solo `pass-solo-artifact-old-mid-feature` covers that path for solo only. The plausible wrong implementation (ending the pending state only when a final-phase commit also exists) is still caught by the invalid-artifact fail case, so this is minor.
*Action: implementer may add a team-arm valid-artifact-at-phase-2 case in phase 2 or leave as is; owner's call.*

## Amendments in this diff

- [x] Amendments listed. The remediation commit itself touches no `spec.md`, `plan.md`, `tasks.md` or `contracts/` (only `notes.md`, which is evidence). The D3 amendment it relies on is the earlier commit 169e93d. I checked it: plan.md carries "**Amendment approved by**: anas.m, 2026-10-13" and the commit message carries "Amendment approved by: anas.m, 2026-10-13", the same approver, in the form constitution I requires. The pack's AmendmentAuthority check graded 9 of 10 commits on my run with no failure (the 10th is a merge commit, not graded). Limits, per the constitution: a machine cannot verify that the named person agreed, and the self-approval prohibition is held by review. All commits carry the owner's git identity with an agent co-author line, and the notes cite "the owner's words in the session". F1 above (stale text next to the amended D3) would need its own recorded approver.

## Constitution re-check (post-implementation)

PASS. I (Specification First): spec and plan approved first; the D3 amendment carries an approver. IV (Architecture Consistency): no new file, the check stays beside its arms. VI: nothing sensitive read. VIII (Testing): hand-written fixtures, pass/fail pairs, 146 passing in my run, pre-existing `CRIT-S*`/`CRIT-T*` unchanged. IX (Human Review): the independence artifact is still required before merge; the amended D3 only tightens when it is graded. X (Controlled Delivery): phase 1 only; the size warning is non-blocking. III, V, VII: not applicable. Nuance: the plan text still describes the old rule in two places (F1).

## Test coverage observed

- `-Case enforcement-pack/CRIT-`: 146 passed, 0 failed. This includes the earlier `CRIT-S*`/`CRIT-T*` and the new `CRIT-R01` (15 variants) and `CRIT-R02` (6 variants). Expectations are hand-written: the exact WARNING line for each pass case and the arm's own FAIL text for each fail case.
- My own repos (outside the repo): subject spellings (14 scenarios), committed, deleted and uncommitted artifacts (several), a governance repo in a subdirectory, two shallow clones.
- Not covered by any case: the `git log`-failure branch (round-1 F5, accepted), near-miss spellings (F2), a valid team artifact committed mid-feature (F4).

## Residual risk

The heuristic cannot see a final commit written in a spelling it does not read (F2) or one that names no phase, when no artifact is committed yet; gate 6 (human review at merge) is the backstop, and the WARN is printed on every run. The new rule is monotone toward strictness: it never turns a previously-FAIL state into a pass other than the intended mid-feature WARN. Before merge: correct the plan Risks, T004 and D1 drift by recorded amendment (F1), and have the owner confirm the two-rule layout (round-1 F6). After merge: the phase 2 guidance should state the commit-early consequence (F3).
