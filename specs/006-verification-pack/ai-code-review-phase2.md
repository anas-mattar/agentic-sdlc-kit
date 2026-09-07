# AI Code Review — 006 Verification Pack (Phase 2: Reviewer separation)

**Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
**Date**: 2026-09-08
**Branches**: agentic-sdlc-kit `006-verification-pack` (tip `24103a0`)
**Scope reviewed**: full diff of `24103a0` (`git show`); `scripts/enforcement-pack.ps1` read whole (all 311 lines, dispatch included); `docs/sdlc/definition-of-done.md` gate 5; `docs/sdlc/review-process.md` (whole file); `specs/_templates/ai-code-review-template.md` (whole file); `specs/006-verification-pack/` spec.md (US2, FR-005/FR-006, SC-003), plan.md (phase table, Technical Context), research.md D4, data-model.md (provenance block), quickstart.md P1–P5, tasks.md T008–T014 + Phase 2 validation record; `specs/006-verification-pack/ai-code-review-phase1.md` retrofit; `scripts/scope-check.ps1` quotepath handling (lines 77–81, for cross-check); `docs/sdlc/branch-strategy.md` line 96. `enforcement-pack.ps1` executed read-only in a scratch git repository under the session scratchpad against nine seeded review files (header/block Reviewer divergence, CRLF, code fence, bracket filename, non-ASCII filename, `git mv` from a grandfathered path, plain missing-section, header-placeholder, unfilled template); the kit repository itself was not modified and no branches or commits were created in it.
**Feature contract**: doc+script phases only, no application code, no new dependencies

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
- **Implementer**: Claude Fable 5 (main session that produced commit 24103a0)
- **Inputs provided**: phase 2 diff (`git show 24103a0`), spec.md, plan.md, research.md D4, data-model.md, quickstart.md P1–P5, tasks.md incl. Phase 2 validation record, the amended template/DoD/review-process files at HEAD of the branch, and read-only script execution in a scratch repository
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — The phase delivers what T008–T014 name: a mandatory provenance block in the template, an `Invoke-ReviewProvenanceCheck` wired into the `NNN-*` dispatch, mutually-referencing DoD/review-process amendments, a truthful retrofit of the phase-1 review, and a recorded P1–P5 validation whose verdicts I reproduced. But the check's Reviewer extraction demonstrably reads the wrong line: `Select-Object -First 1` over the whole document picks the template's *header* `**Reviewer**:` field, never the provenance block's — so a review whose provenance block openly attests `implementer` passes when its header says "fresh-context agent" (confirmed by execution, F1), the exact self-graded-review-undetected outcome SC-003 promises is impossible, plus a false-FAIL mirror case. Two further escape routes weaken the same guarantee: non-ASCII filenames drop out via git quotepath (F2 — the same defect class this branch's own phase-1 review flagged as F3 and fixed in scope-check, regressed here in new code), and a `git mv` of a grandfathered pre-006 review into the current feature arrives as R-status, invisible to `--diff-filter=A` (F3). The docs and template are sound and mutually consistent apart from data-model.md describing a check the code does not quite perform (F1's doc face) and an unmandated filename convention the whole check keys on (F6). Residual risk sits entirely in the enforcement function; the prose amendments need no rework.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-005: template diff adds the four-field block + MANDATORY comment — shape matches data-model.md lines 33–40. FR-006: seeded a plain review with no section → `FAIL … has no '## Reviewer Provenance' section` naming the file, exit 1; unfilled placeholder → `FAIL … attests '[agent + model]' as reviewer`; reworded/missing attestation fails via `[regex]::Escape` verbatim match; `main` with legacy reviews at base → no failure (grandfathering reproduced). **But** the "attests the implementer as reviewer" leg is satisfiable falsely — see F1. |
| Visual-reference match | N/A — no `specs/006-verification-pack/screenshots/`; doc+script feature. |
| Feature contract held (no unapproved table/migration/permission/package) | Diff = 5 markdown files + 1 amended .ps1; new function invokes only `git diff` and PowerShell built-ins; no modules, no network, no writes. |
| Constitution / domain invariants | Research D6 honored: no constitution edit in the diff; who certifies is unchanged (DoD gate 5 text keeps the owner auditing attestation truth). Check placement in dispatch mirrors existing `NNN-*` checks. |
| Security (authn/authz, secrets, sensitive logging) | No secrets, no sensitive logging; failure messages echo file paths and the reviewer value only. |
| Scope guard (`git diff --stat` — only intended files) | 6 files, all named by the Phase 2 territory list in tasks.md (template, enforcement-pack, DoD, review-process, kit-manifest verification only — no manifest change needed, plus the feature's own spec dir which is implicit territory per D1). No unrelated changes. |
| Rollback safety | Phase 2 reverts cleanly per plan: the check keys off newly-added reviews only; reverting restores the old template and check set. Retrofitted provenance in the phase-1 review would revert with it (same commit family). |
| CRLF robustness (hunted explicitly) | Probed a CRLF review file: the line split leaves `\r` on each line, but .NET `.` matches `\r`, `$` anchors at end-of-string, and `.Trim()` strips it before comparison — filled CRLF review passes, no false failure. Not a defect. |
| Recorded validation (tasks.md P1–P5, P3b/P3c) | P2/P3/P3b/P3c-equivalent verdicts and the multi-failure single run reproduced in the scratch repo; P5 consistent with the retrofit file's inspected content (header and block both filled fresh-context, attestation verbatim at line 18). |

## Findings

### F1 — Reviewer extraction reads the document header, not the provenance block — BLOCKING

`scripts/enforcement-pack.ps1` line 239: `Select-Object -First 1` over the whole document picks the template's *header* `**Reviewer**:` field (template line 3), which always shadows the provenance block's line. Confirmed by execution in a scratch repo: a review whose header says `**Reviewer**: fresh-context agent — SomeModel` while its provenance block says `- **Reviewer**: implementer` exits **0** (`enforcement-pack: OK`) — a review that *openly attests self-grading* passes, defeating FR-006 and SC-003 ("100% of reviews … attesting the implementer as reviewer fail the branch"). Mirror case also confirmed: a correctly filled provenance block with the header left as the template placeholder fails with the misleading message "attests '[agent + model]' as reviewer". This also contradicts data-model.md ("Machine-checked … `Reviewer:` line present, non-empty, not `implementer`" — describing the block) and the DoD/review-process prose, which both say the check inspects the provenance block. The recorded P1/P3 validation missed it because those seeds kept header and block consistent.
*Action: implementer — scope the Reviewer-line search to the text between the `## Reviewer Provenance` heading and the next `## ` heading (e.g. capture that slice first, then apply the existing line regex), keeping the placeholder and implementer rules on that slice; add the two divergence cases (header-fresh/block-implementer, block-fresh/header-placeholder) to quickstart's P-table and rerun.*

### F2 — Non-ASCII review filenames escape the check via git quotepath — CONFIRM

The file list comes from `git diff --name-only --diff-filter=A` **without** `-c core.quotepath=off`. A review named `ai-code-review-phasé2.md` is emitted quoted-octal — the leading quote fails `-match '^specs/'` and the trailing quote fails `'\.md$'`, so the file is silently never inspected. Confirmed by execution: such a file with no provenance at all → `enforcement-pack: OK`, exit 0. This is fail-open (an evasion route for exactly the adversary this feature targets), and it is the identical defect class this branch's own phase-1 review flagged as its F3 — fixed in `scope-check.ps1` but regressed in this new function on the same branch.
*Action: implementer — use `git -c core.quotepath=off diff --name-only --diff-filter=A $Base HEAD`, matching the scope-check precedent; add a unicode-filename row to the P-table.*

### F3 — Rename detection (R status) bypasses `--diff-filter=A`: a grandfathered review can be moved into the current feature unchecked — CONFIRM

Confirmed by execution: seed a pre-006-style review (no provenance) at `specs/003-old/ai-code-review.md` on the base, then on the feature branch `git mv` it to a new feature path — the diff reports `R100`, not `A`, so the "new" review of the current feature carries no provenance and the branch exits 0. Research D4 chose A-only for grandfathering, but grandfathering was meant to protect reviews *at their historical paths*, not reviews newly *appearing in the feature under review*. Partial backstop exists: phase 1's scope check fails the `mv` commit because the old path is out of territory — but only when the commit carries a `phase N` token; a `chore:`-subject commit on the same branch gets `warning-undeclared` (research D2) and escapes both checks.
*Action: owner decision — either switch to `git … diff --name-status --diff-filter=AR` and inspect rename targets (renames of old reviews into new locations are not legitimate grandfathering), or document this as an accepted residual with the scope-check backstop rationale in research D4.*

### F4 — `Test-Path` wildcard interpretation and working-tree read silently skip files — MINOR

Line 233 uses `Test-Path $file` (wildcard-interpreting) with `continue`: a review named `ai-code-review-[x].md` fails its own `Test-Path` (`[x]` parsed as a character class) and is skipped without any failure — confirmed by execution (file with no provenance → OK). The `continue` branch also means a review present at HEAD but deleted/renamed in the working tree passes silently, and `Get-Content` reads the working tree rather than the committed blob (consistent with the pack's existing checks, divergent from scope-check's read-from-history stance in review-process step 3).
*Action: implementer — `Test-Path -LiteralPath $file` (and `Get-Content -LiteralPath`); optionally read `git show HEAD:$file` for commit/working-tree parity. Low urgency given the filenames involved, but it is fail-open.*

### F5 — Purely textual matching: a fenced mock block satisfies all three checks — MINOR

Confirmed by execution: a fully self-graded review containing the heading and a filled Reviewer line only **inside a fenced code block**, plus the attestation sentence quoted in prose, exits 0. Unlike a false attestation (human-audited by design, research D4), here the machine's own claim — "the block is present" — is spoofed without the document ever asserting anything false. Related: the implementer test is a prefix match (`'^(?i)implementer\b'`), so values like "the implementer" or "same session as implementer" pass. Both are within the by-design limit that attestation truth is the owner's to audit, and the template's own HTML comment does not contain the attestation sentence, so no vacuous pass from template text.
*Action: none beyond awareness, unless the owner wants fence-stripping before matching — recommend recording this residual in research D4 so the limit is a stated decision.*

### F6 — The filename convention the whole check keys on is not mandated anywhere — DOC DRIFT

The check inspects only files matching `ai-code-review[^/]*\.md` under `specs/` — but no governing document mandates that name. `docs/sdlc/branch-strategy.md` line 96 shows `ai-code-review.md` in an illustrative tree; DoD gate 5 and review-process say "complete the template" without naming the artifact file. A review filed as `specs/NNN-x/review-phase2.md` satisfies the prose ritual, looks complete to the human, and is invisible to the machine — and nothing checks that a review file exists at all. SC-003's "100%" therefore holds only under an unwritten convention. Code correct for the convention; docs don't establish the convention as law.
*Action: implementer — one sentence in DoD gate 5 and/or review-process step 3 mandating the `specs/NNN-name/ai-code-review*.md` naming that the enforcement pack keys on (phase 4's governance sweep is a natural home).*

### F7 — Reviews introduced on `fix/`, `chore/`, or `docs/` branches are never provenance-checked — MINOR

Dispatch runs `Invoke-ReviewProvenanceCheck` only on `NNN-*` branches. The Lite lane's prohibited categories do not cover `specs/` paths, and the docs lane runs no checks, so a review file added to `specs/NNN-x/` via a Lite/docs branch merges unchecked and becomes grandfathered at the feature branch's next rebase onto main. Requires deliberately misusing the branch taxonomy, and human PR review of an off-lane specs addition is a plausible catch — but SC-003 is stated as a machine guarantee.
*Action: owner decision — either run the provenance check on all lanes (it is cheap and self-scoping via `--diff-filter=A`), or add `specs/*/ai-code-review*` additions to the Lite-lane prohibited categories.*

## Constitution re-check (post-implementation)

**PASS with the F1 caveat.** I (Specification First): phase implements T008–T014 as tasked. II (Source of Truth): the designed-for prose/machine sync mostly holds — DoD, review-process, and template agree with each other; data-model.md's "Machine-checked" description disagrees with the code's actual line selection (F1) — resolved by fixing the code, not the doc. IV (Architecture Consistency): new check mirrors the existing check functions' shape and dispatch; no dependencies. VIII (Testing): seeded scenarios P1–P5 + 2 hardening cases executed and recorded — but the seed set never diverged header from block, non-ASCII names, fences, or renames, which is where the defects live. X (Controlled Delivery): one phase, one commit, revertible as the plan's phase table claims; batch phases 1–3 declared plan-side before implementation.

## Test coverage observed

No test framework (kit convention, 002 precedent). Phase 2 validation record in tasks.md: P1–P5 plus P3b (placeholder) and P3c (reworded attestation), run on a throwaway `999-prov-demo` branch, all verdicts recorded with exit codes, multi-failure single-run behavior noted. I reproduced the P2/P3b-class failures, the grandfathering pass, and the multi-failure run in a scratch repository. Gaps in the seed set (now demonstrated as live defects or escapes): header/block Reviewer divergence (F1), quotepath filenames (F2), R-status renames (F3), bracket filenames (F4), fenced mock blocks (F5). CRLF was not seeded but I verified it is handled correctly.

## Residual risk

Concentrated in `Invoke-ReviewProvenanceCheck`'s file selection and line extraction, not in the prose: F1 makes the check certifiable-around today (an openly self-attested review passes), and F2/F3/F4 are quieter escape hatches for the same adversary the feature exists to catch. F1 and F2 are small, precedent-following fixes (slice-scoped extraction; `core.quotepath=off` exactly as scope-check already does) and should land before this phase is called done — ideally before phase 3 wires the check into CI, where a green `ritual-checks` badge would lend these gaps false authority. F3/F6/F7 need an owner decision on how far the machine guarantee is meant to reach versus what stays documented residual; whichever way, research D4 and SC-003's "100%" wording should end up telling the same story as the code.

---

## Implementer fix-response log (post-review, same phase territory)

*Appended by the implementing agent after acting on the review; the review text above is
unmodified. Fixes land in a `phase 2 fixes` commit.*

| Finding | Disposition |
|---|---|
| F1 | **Fixed in code** — the Reviewer line is now extracted from the slice between `## Reviewer Provenance` and the next `## ` heading only; both divergence cases added to the validation set (header-fresh/block-implementer now FAILs; block-fresh/header-placeholder now passes). |
| F2 | **Fixed in code** — `-c core.quotepath=off` on the diff call (scope-check precedent); unicode-filename scenario added. |
| F3 | **Fixed in code (strict option)** — the diff filter is now `AR` with `--name-status` parsing, so rename *targets* matching the review pattern are inspected like additions; renaming a grandfathered review into the feature no longer evades the check. Flagged for owner ratification (reviewer marked it an owner decision). |
| F4 | **Fixed in code** — `-LiteralPath` on both `Test-Path` and `Get-Content`; a listed review file missing from the working tree is now a FAIL (fail-closed), not a silent skip. |
| F5 | **Accepted residual** — recorded in research D4: textual matching does not strip code fences; the machine verifies presence and consistency, the owner audits truth. The implementer-prefix rule stands. |
| F6 | **Fixed in docs** — DoD gate 5 now mandates the `specs/NNN-name/ai-code-review*.md` filename the machine keys on; review-process step 3 names it too. |
| F7 | **Fixed in code (strict option)** — the provenance check now runs on every recognized lane (`NNN-*`, `fix/*`, `chore/*`, `docs/*`); it is self-scoping via the diff filter, so lanes that add no review files are unaffected. Flagged for owner ratification. |