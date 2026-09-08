# AI Code Review — 007 Adoption Doctor (Phase 3: Wrapper Membership)

**Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
**Date**: 2026-09-08
**Branches**: agentic-sdlc-kit `007-adoption-doctor` (tip `2462b41`)
**Scope reviewed**: `git show 2462b41` (full diff); `scripts/ritual-checks.ps1` (entire current file); `scripts/verify-kit.ps1` (param block + decline/dim-5 reads); `specs/006-verification-pack/contracts/ritual-checks-ci.md`; `specs/007-adoption-doctor/spec.md` (US3, FR-007, SC-004, SC-005), `research.md` (D5, D7, D8), `quickstart.md` (W1–W3), `tasks.md` (T013–T016 + Phase 3 validation), `contracts/verify-kit-cli.md`, `plan.md` (Constitution Check); `kit-manifest.json` (scripts classification); `adoption/updating.md` §4. Empirical runs: wrapper on the kit repo; scratch `git archive 2462b41` fixture in the session scratchpad (adopted-marker run, missing-member run, record-without-`.kit-version` run, direct doctor run); `scope-check.ps1 -All` on the branch; isolated `pwsh -NoProfile -File <missing>` exit-code probe.
**Feature contract**: doc+script phases only; wrapper verdict-block format preserved; kit CI behavior unchanged except the explicit n/a line

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
- **Implementer**: Claude Fable 5 (main session that produced commit 2462b41)
- **Inputs provided**: phase 3 diff (`git show 2462b41`), spec.md, research.md, quickstart.md, tasks.md, both contracts (007 `verify-kit-cli.md`, amended 006 `ritual-checks-ci.md`), plan.md, `adoption/updating.md`, full current `scripts/ritual-checks.ps1` and `scripts/verify-kit.ps1`, `kit-manifest.json`, plus read-only empirical runs on this repo and scratch fixtures outside it
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups** — the diff adds `verify-kit` as a fourth ritual-checks member exactly as research D7 pins it: gated on `.kit-version` at `-Root`, resolved from the target's own `scripts/` dir, `-Branch` correctly not passed, the kit repo printing an explicit n/a line that never touches the failure count, and the living 006 contract amended in declared territory. Every mechanical claim in the Phase 3 validation table reproduced under fresh eyes. The residual risk sits in one design seam the diff faithfully implements but nowhere acknowledges: the wrapper's discriminator (`.kit-version` only) is strictly weaker than the doctor's own (which audits a `kit-adoption.json`-bearing project without `.kit-version`), so exactly the copy-adoption class the doctor's grandfather posture protects gets a green CI, a red direct doctor run, and a factually wrong "n/a (kit repository)" label — a conflict between two documents on this same branch (F1, CONFIRM). It must be dispositioned in-phase per 006 law before the batch merges; either resolution is a one-liner or a docs amendment.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-007 kit-side half verified live: wrapper on this repo printed 3 member OKs + `verify-kit       n/a (kit repository)` + `RESULT OK`, exit 0 (W1 reproduced). Adopted half verified on a scratch fixture with a bare-hex `.kit-version`: doctor ran as 4th member, `RESULT FAIL (1 of 4 member(s) failed)`, exit 1 when only verify-kit failed. FR-007's "adopted projects" coverage has a gap for record-only adoptions — F1. |
| Visual-reference match | N/A — no UI; no visual references exist for this feature. |
| Feature contract held (no unapproved table/migration/permission/package) | Diff touches only the 3 declared files; verdict-block format unchanged (`'{0,-16} {1}'` reused verbatim for the n/a line; `enforcement-pack` at exactly 16 chars still aligns — observed in live output); kit CI output differs from pre-007 only by the n/a line (W1 run). No packages, no workflow changes. |
| Constitution / domain invariants | Wrapper stays read-only (gate is a `Test-Path`; member invocation unchanged). One source-of-truth conflict found and reported per constitution II rather than silently resolved — F1. |
| Security (authn/authz, secrets, sensitive logging) | No secrets, no network; the new code reads one path and prints one line. `$Root` flows only into `Join-Path`/`Test-Path` and an argument array — no string-interpolated invocation. |
| Scope guard | `scope-check.ps1 -All -Branch 007-adoption-doctor` run by reviewer: `scope-check: PASS phase 3 commit 2462b41 (3 file(s))`, exit 0. `git show --stat` matches the 3 declared+bookkeeping files. |
| Rollback safety | Additive: reverting 2462b41 returns the exact 3-member wrapper and the pre-amendment contract; no data or schema. Plan's phase table says the same and it holds. |

## Findings

### F1 — Wrapper discriminator is weaker than the doctor's own: record-bearing, `.kit-version`-less adoptions get green CI, a red direct run, and a wrong n/a label — CONFIRM

The gate is `Test-Path (Join-Path $Root '.kit-version')` (`scripts/ritual-checks.ps1:55`), per research D7. But the doctor itself (D5.3, implemented at `8b033b7`) deliberately audits a project that has `kit-adoption.json` and no `.kit-version` — the record vetoes the decline, absence degrades to a WARN, because (D5's own rationale) "its absence alone must not hide a real adoption from the audit — the copy-only case is exactly a partial-install risk." The wrapper does exactly that hiding, in the zero-human-initiation channel US3 exists to cover.

Reproduced empirically on one scratch tree (kit copy + `kit-adoption.json`, no `.kit-version`, broken slots): direct `verify-kit.ps1 -Root .` → `FAIL (10 failure(s), 1 warning(s))`, exit 1; `ritual-checks.ps1` on the same tree → `verify-kit       n/a (kit repository)` + `RESULT OK`, exit 0. Three documents on this branch are now in tension:

- `specs/007-adoption-doctor/contracts/verify-kit-cli.md` Guarantees: "Identical verdicts wherever run (local, init-end, update-end, **ritual-checks/CI**)" — violated for this project class, and the phase amended the 006 contract but not this one.
- `adoption/updating.md` §4 (phase 2, same branch): "runs … as part of the `ritual-checks` CI in adopted projects" (unqualified) and "creating **either** file … makes you auditable" — steering exactly this population into the gap (they create the record, stay invisible to CI).
- Spec SC-004 / US3: "integrity regressions turn the branch red with zero human initiation" — not for record-only adoptions.

The n/a label compounds it: `n/a (kit repository)` is asserted for any root lacking `.kit-version`, which for this class is factually false output in CI logs.

Mitigation that keeps this from BLOCKING: updating.md does tell copy adoptions to create `.kit-version` (bare sha, or one `update-kit` run), any project updated via `update-kit.ps1` gets it written automatically (L3 validation), and D7 is a pinned research decision this diff implements faithfully. But the conflict itself is unacknowledged anywhere (grepped plan/research/data-model), and the kit's own conflict rule says report, never silently choose.

*Action: owner decision, dispositioned in-phase before the batch gate — either (a) widen the gate to `.kit-version -or kit-adoption.json`, mirroring the doctor's D5.3 veto (one line; the label then only prints when neither exists), or (b) keep D7's gate and amend verify-kit-cli.md's Guarantees line, updating.md's "either file"/CI sentences, and the n/a label text (e.g. `n/a (no .kit-version)`) to tell the truth about the exception. Record the choice in research D7.*

### F2 — 006 contract's example verdict block now understates the kit repo's own output — DOC DRIFT

`specs/006-verification-pack/contracts/ritual-checks-ci.md:24-29`: the sample block still shows three lines and `RESULT FAIL (1 of 3 member(s) failed)`, and the framing sentence says "one line per member (OK/FAIL …)" — but after this diff the kit repository's block always carries a fourth line in a third verdict form (`n/a (kit repository)`), verified live. The amended step-4 bullet describes the rule, so a careful reader gets there; the example a skimmer copies does not. Cosmetically, the bullet's inline literal `` `verify-kit  n/a (kit repository)` `` (2 spaces) won't grep-match the real 16-column-padded output (`verify-kit      ` + space).

*Action: refresh the example block to show the n/a line (kit-repo variant) and pad the inline literal to match real output — a two-line contract edit, follow-up within the batch.*

### F3 — Missing `verify-kit.ps1` in an adopted project fails loud, not silent — ACCEPTED

Tested the partial-copy scenario the CI member creates: with `.kit-version` present and `scripts/verify-kit.ps1` deleted, `& pwsh -NoProfile -File <missing>` sets `$LASTEXITCODE` = **64**, so the wrapper records FAIL (observed: `verify-kit       FAIL`, `RESULT FAIL (2 of 4 member(s) failed)` — doc-lint co-failed on the adoption docs' now-dangling `scripts/verify-kit.ps1` references, its own correct angle). No silent-OK path exists: `$PSNativeCommandUseErrorActionPreference = $false` (line 39) also prevents the stderr from aborting the run before the verdict block. Flow-down is covered: `kit-manifest.json:36` classifies `scripts/*.ps1` verbatim (confirmed in tasks T004), so any `update-kit` that delivers the 4-member wrapper delivers the doctor beside it.

*Action: none — the failure mode is the desired one and delivery is coupled by the manifest.*

### F4 — `-Branch` correctly withheld from the doctor member — ACCEPTED

`verify-kit.ps1` takes only `-Root` and `-Json` (`scripts/verify-kit.ps1:34-38`); a passed-through `-Branch` would fail parameter binding in the child pwsh and turn every adopted CI run red. The diff builds the member as `@((Join-Path $scriptsDir 'verify-kit.ps1'), '-Root', $Root)` with no `+ $branchArgs`, unlike enforcement-pack/scope-check — deliberate and correct, including detached-HEAD CI checkouts where `-Branch` is always supplied to the wrapper.

*Action: none.*

## Constitution re-check (post-implementation)

**PASS with one reported conflict.** I — phase implements exactly tasks T013–T016 from an approved spec. II — one genuine source-of-truth conflict surfaced (F1: research D7's gate vs verify-kit-cli.md's identical-verdicts guarantee vs updating.md's CI sentence); reported here per the conflict rule rather than resolved unilaterally; everything else consistent, and the 006 living contract was amended in the same commit as the behavior (the kit's own anti-drift law, honored — modulo the stale example, F2). III — N/A. IV — no new patterns; the member joins the existing ordered-hashtable/child-pwsh shape unchanged. V — audits law, changes none. VI — read-only, no secrets. VII — N/A. VIII — W1–W3 fixture validation recorded and independently reproduced. X — single phase, single commit, clean revert.

## Test coverage observed

No test framework (kit convention); validation is the seeded-fixture record in `specs/007-adoption-doctor/tasks.md` Phase 3 table: W1 (kit repo: 3 OKs + n/a + RESULT OK), W2 (healthy adopted fixture: 4 OKs), W3 (broken tier rulebook: `verify-kit FAIL` named, all members ran, `RESULT FAIL (2 of 4)`, exit 1, with the honest note that doc-lint co-failed). Reviewer independently reproduced: W1 on this repo (exit 0, byte-identical verdict-block shape); an adopted-fixture run isolating the doctor as sole failure (`1 of 4`, exit 1 — confirming the n/a path never inflates the count and the denominator counts only real members); the missing-member case (exit 64 → FAIL); and the F1 divergence pair (wrapper OK/exit 0 vs direct doctor FAIL/exit 1 on the same tree). Column alignment of the new lines against the 16-char `enforcement-pack` verified in live output.

## Residual risk

Concentrated entirely in F1: until it is dispositioned, a documented adoption path (copy adoption + hand-created `kit-adoption.json`, no `.kit-version`) has CI that stays green through integrity regressions while advertising "n/a (kit repository)" about a project that isn't the kit — a false-PASS class, the worst kind for an integrity tool, though bounded to projects that ignore updating.md's `.kit-version` instruction and never run `update-kit`. Both resolutions are cheap; neither is the reviewer's to choose. F2 is a two-line contract touch-up. The batch gate (owner-run `ritual-checks`, expect RESULT OK) should follow F1's disposition, not precede it.

---

## Implementer fix-response log (post-review, same phase territory)

*Appended by the implementing agent after acting on the review; the review text above is
unmodified.*

| Finding | Disposition |
|---|---|
| F1 | **Fixed in code (option a, flagged for owner ratification)** — the wrapper's gate is now `.kit-version` OR `kit-adoption.json`, mirroring the doctor's own D5.3 discriminator; the n/a label tells the truth (`n/a (no adoption markers — kit repository or unadopted tree)`). Research D7 amended with the resolution. Validated: record-only tree now runs the doctor in the wrapper (divergence pair converges); neither-marker tree and the kit repo show the new n/a label. |
| F2 | **Fixed in docs** — 006 contract's example block shows the fourth line with an explanatory note; the step-4 bullet's inline literal padded to real output. |
| F3 | **Accepted** — loud failure verified by the reviewer; manifest couples delivery. |
| F4 | **Accepted** — deliberate `-Branch` omission confirmed correct. |