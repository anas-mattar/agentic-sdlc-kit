# AI Code Review — 008 CI-Held Certifying Gate (phase 2: GateCertification enforcement)

**Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
**Date**: 2026-09-08
**Branches**: agentic-sdlc-kit `008-ci-held-gate` (tip 31467cc)
**Scope reviewed**: `git show 31467cc` (full diff, all 3 files); `scripts/enforcement-pack.ps1` in full at the tip (the new `Invoke-GateCertificationCheck`, `Invoke-GateBatchingCheck`, `Invoke-StructureCheck`, `Invoke-CriticalEvidenceCheck`, dispatch, `.DESCRIPTION`); `specs/008-ci-held-gate/` spec.md, plan.md, research.md (D6, D7), data-model.md, contracts/gate-certification.md, quickstart.md, tasks.md; branch-tip `.specify/templates/plan-template.md` header and constitution X clause + sync list; `scripts/scope-check.ps1` territory conventions. Live runs: enforcement pack on the branch itself, seeded G1–G6, seven adversarial parser probes (E1–E7 + decoy inversion), full 001–007 regression, scope-check, doc-lint.
**Feature contract**: one enforcement check + plan/tasks bookkeeping; no law text changed

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
- **Implementer**: Claude Fable 5 (main session that produced commit 31467cc)
- **Inputs provided**: commit 31467cc diff and tip working tree; specs/008-ci-held-gate design set (spec, plan, research, data-model, contract, quickstart, tasks); enforcement-pack.ps1 read in full; branch-tip constitution X and plan-template; live executions of enforcement-pack.ps1 (branch run, seeded fixtures under a short-lived untracked `specs/999-gc-demo` fully removed afterward, 001–007 regressions), scope-check.ps1, doc-lint.ps1
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups** — the diff adds `Invoke-GateCertificationCheck` in exact parity with the Gate Batching idiom (verified line-for-line and empirically on identical input shapes), wires it into the `NNN-*` dispatch, documents it in the header, and dogfoods the field in this feature's own plan. All six contract scenarios reproduce exactly as recorded, the full 001–007 regression is green (wider than the recorded sample), and the live branch run — the field's first real parse, multi-line comment and all — exits 0. Residual risk sits in two places: a commented-out decoy declaration can defeat the Critical exclusion (a pre-existing idiom weakness this diff propagates into a new rule — F1, CONFIRM), and the contract claims case-sensitivity the code does not have (F2, DOC DRIFT).

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-003 / US3 acceptance scenarios and research D6 implemented verbatim: seeded G1–G6 reproduced live (`specs/999-gc-demo` fixture, removed after) — G1/G2/G3/G6 OK, G4 FAIL citing constitution X + critical-delivery item 4, G5 FAIL naming `'user-run' or 'ci-held'`; failure strings match the recorded Phase 2 validation table verbatim |
| Visual-reference match | N/A — no UI, no visual references |
| Feature contract held (no unapproved table/migration/permission/package) | Diff is exactly 3 files: `scripts/enforcement-pack.ps1` (+39), `specs/008-ci-held-gate/plan.md` (+2), `tasks.md` (bookkeeping). No law document touched, no dependency, no config change |
| Constitution / domain invariants | Legal values `user-run`/`ci-held` and the Critical exclusion are named in the constitution's sync list (phase 1 F6) and the check's comment cites them as sync-listed constants; check text mirrors X's CI-held clause (branch-tip constitution lines 237–247 read) |
| Security (authn/authz, secrets, sensitive logging) | No secrets, no network, read-only file parses; `$value` is only interpolated into a Write-Host failure string — no execution sink |
| Scope guard | `scope-check.ps1`: `PASS phase 2 commit 31467cc (3 file(s))`. plan.md/tasks.md edits are lawful under the always-implicit `specs/NNN-name/**` territory (scope-check.ps1 header, line 31); declared territory `scripts/enforcement-pack.ps1` covers the rest |
| Rollback safety | Reverting 31467cc removes one self-contained function, one dispatch line, one header block, one plan line, and checkbox flips — nothing else references the check (plan phase table: "revert returns to prose-only law" holds) |

## Findings

### F1 — Commented-out decoy declaration defeats the Critical exclusion — CONFIRM

The parser takes the **first** line matching `^\*\*Gate Certification\*\*:` (`Select-Object -First 1`, enforcement-pack.ps1 line 242) with no awareness of HTML comment *blocks* — it only strips a comment opening on the value line itself. Verified empirically: a plan containing

```markdown
<!--
**Gate Certification**: user-run
-->
**Gate Certification**: ci-held
```

on a **Critical** spec passes the GateCertification check (the hidden decoy parses as `user-run`; the only failure emitted was the unrelated CriticalEvidence one). Rendered markdown hides the decoy, so a human sees `ci-held` while the machine certifies `user-run` — precisely the "quietly adopt ci-held" path the phase checkpoint claims to close. The inverse (commented `ci-held` above a real `user-run`) produces a false FAIL, also verified. **Proportionality**: this is not an implementation defect against the spec — research D6 and T008 mandate "GateBatching's parser idiom", and I verified GateBatching false-passes on the exact same decoy shape (accepted law since constitution 0.4.0); the raw diff at gate-6 human review shows the decoy. But this diff extends the weakness to a new constitutional exclusion, and the fix is cheap and shared (strip `<!-- ... -->` blocks from the content before line-matching, in one helper used by both checks).
*Action: owner decides — either accept as the known shared idiom limit (document it beside GateBatching's) or open a small hardening task (one comment-block-strip preprocessing step for both parsers, with the decoy shapes as seeded scenarios). Not blocking for this phase.*

### F2 — Contract says "case-sensitive"; the check is case-insensitive — DOC DRIFT

`contracts/gate-certification.md` (Declaration section): "Legal values exactly those two (**case-sensitive**, comment stripped)." The code uses PowerShell's default case-insensitive `-eq`/`-ne`/`-match`: verified `CI-HELD` on a Standard spec **passes** as ci-held (E3a) and on a Critical spec **fails** as ci-held (E3b). So the code is more permissive than the contract claims — but there is no enforcement hole: any casing of `ci-held` still trips the Critical exclusion, and any string that is neither value in any casing still fails malformed. Case-insensitivity is also exact GateBatching parity (`Phases 1-3` is likewise accepted), so tightening the code to `-cne` would *diverge* from the idiom the design mandates. One of the two must move, and the contract is the cheaper, safer side.
*Action: implementer amends `contracts/gate-certification.md` to say "case-insensitive (GateBatching idiom)" — a spec-doc edit inside the feature's own directory, lawful in any phase commit; optionally add a G-row for a cased value.*

### F3 — Present-but-empty value silently treated as `user-run` — MINOR

`**Gate Certification**:` with no value passes as the default (verified, E5): line 247 treats `''` like `user-run`. The contract only defines "absent **line** ⇒ user-run"; a present-but-valueless line is arguably a malformed declaration (someone deleted the value). Exact GateBatching parity (empty ⇒ `none`), and fail-safe: an empty value can never smuggle `ci-held`.
*Action: none required (idiom parity, safe direction); if F2's contract edit happens anyway, one clause — "empty value = absent" — closes the gap.*

### F4 — Recorded regression narrower than quickstart's promised sweep — MINOR

quickstart.md phase 2 promises "regression: enforcement-pack on this branch and on **001–007**"; the recorded T009 table (and the edited T009 task text) ran only "this branch, 003, 007". The narrowing is honest — the task text was visibly amended in the same diff, and sampling is defensible since no 001–007 plan contains the field (grep verified: only 008's plan does, so all seven take the identical absent-line early return). I closed the gap regardless: ran enforcement-pack against all of 001–007 plus the live branch — **all OK**, so the promised sweep holds in fact.
*Action: none — this review's full-sweep result stands as the missing evidence; keep quickstart and validation records phrased identically next time.*

### F5 — `ci-held` with spec.md absent skips the Critical test — ACCEPTED

Lines 254–260: when `spec.md` is missing, the Delivery Level test is silently skipped, so a `ci-held` declaration on an unknown level passes this check. The branch still fails overall — StructureCheck independently fails any `NNN-*` branch missing spec.md (line 117), so the state cannot reach green. This is the exact layering GateBatchingCheck uses (line 223), and the in-code comment on the plan.md guard documents the division of labor. Delivery Level parsing parity also verified: the regex `^\*\*Delivery Level\*\*:\s*Critical\b` is character-identical across GateCertification, GateBatching, and CriticalEvidence, and lowercase `critical` is treated as Critical consistently by all readers including StructureCheck (E6 verified).
*Action: none — deliberate layering, fail-closed at branch level, documented in-code.*

## Constitution re-check (post-implementation)

**PASS.** IV (architecture consistency): the check is a byte-level sibling of GateBatching — same guard, same first-match/comment-strip/trim sequence, same missing-plan comment, same dispatch position pattern; parity verified empirically on identical input shapes (E1/E2/E7). VIII (testing): the seeded G1–G6 scenarios exist, reproduce, and their recorded verdict strings are accurate; this review added seven adversarial probes. X (controlled delivery): phase 2 sits inside the declared phases 1–3 batch; commit is one coherent slice (3 files, +59/−3); the plan's own new declaration line — shipped with the template's multi-line-comment shape — parses as `user-run` in the live run (D7 dogfooding confirmed working). II (source of truth): the one prose/machine divergence found is F2, on the feature's own contract, dispositioned above.

## Test coverage observed

No test framework (kit convention — constitution VIII satisfied by seeded deterministic scenarios). Observed and reproduced: contract G1–G6 (6/6 verdicts match the recorded Phase 2 validation table, including exact failure strings); this review's additional probes — template-verbatim multi-line comment (parses `user-run`, OK), `ci-held` + same-line-opening multi-line comment on Critical (FAILs correctly), uppercase values (case-insensitive both directions), commented-decoy shapes in both directions for both GateCertification and GateBatching (F1), empty value, lowercase `critical` level; regression: enforcement-pack green on all of 001–007 and on the live 008 branch (exit 0, ritual companions scope-check PASS and doc-lint OK).

## Residual risk

Concentrated in F1: a deliberately crafted plan can hide the machine-parsed declaration inside an HTML comment, making the rendered document and the enforcement verdict disagree — the one path by which a Critical feature could still "quietly" declare ci-held. It is mitigated today by gate-6 human review of the raw diff, and it predates this feature (GateBatching, constitution 0.4.0). Everything else is documentation truing-up (F2 contract wording, F3/F4 record hygiene). Merge-safe once the owner dispositions F1 (accept-and-document or schedule the shared parser hardening) and the F2 contract line is corrected on this branch before the feature closes.

---

## Implementer fix-response log (post-review, same phase territory)

*Appended by the implementing agent after acting on the review; the review text above is
unmodified.*

| Finding | Disposition |
|---|---|
| F1 | **Fixed in code (hardening option, flagged for owner ratification)** — new shared `Get-VisiblePlanLines` helper strips closed `<!-- … -->` blocks before line-matching, used by BOTH GateCertification and GateBatching (the weakness predated 008; both close together). Validated: G7 (decoy user-run + real ci-held on Critical) now FAILs; G8/G9 (commented ci-held / bad-batching decoys above real values) produce no false failures; the template's own multi-line-comment shape (this branch's live plan) still parses correctly. Contract gains G7–G9 rows. |
| F2 | **Fixed in docs** — contract now says case-insensitive (GateBatching idiom; any casing of ci-held still trips the Critical exclusion). |
| F3 | **Fixed in docs** — contract states "a present-but-empty value is treated as absent" (idiom parity, fail-safe direction kept in code). |
| F4 | **Accepted** — the reviewer's full 001–007 sweep stands as the evidence; noted for record hygiene. |
| F5 | **Accepted** — deliberate layering with StructureCheck, fail-closed at branch level. |