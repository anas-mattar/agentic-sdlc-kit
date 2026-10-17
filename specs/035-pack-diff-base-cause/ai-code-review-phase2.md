# AI Code Review — 035 the enforcement pack names the cause when its diff base cannot be read (phase 2)

**Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
**Date**: 2026-10-17
**Branches**: agentic-sdlc-kit `035-pack-diff-base-cause` (phase 2 commit `236e184`; parent `1844dc0`)
**Scope reviewed**: `git show 236e184` in full: the new flow-down note in `adoption/updating.md`, the GAP-041 status text, the tracker row and the new decisions-log entry in `docs/roadmap.md`, and the new phase 2 section of `specs/035-pack-diff-base-cause/notes.md` (T009). Also `spec.md`, `plan.md` (P6, P7), `tasks.md` (phase 2, T007-T010), `docs/sdlc/review-process.md`, `specs/_templates/ai-code-review-template.md`, the flow-down note of feature 034 (for shape), `scripts/enforcement-pack.ps1` (the three message sites, read to check what the note says it does), the `BASE-001` to `BASE-003` `expected.txt` files, and `kit-manifest.json`. Not read: the clone-level outputs of the measurement (the clones are scratch files; not redone).
**Feature contract**: Standard lane, two phases; documentation, the roadmap and a measurement only (phase 2 territory: `adoption/updating.md`, `docs/roadmap.md`, `docs/digests/**`); no digest marker changes; no script change; the note's every path resolves in an adopted project (doc-lint); the roadmap row closed without claiming certification that is not recorded (FR-006, SC-001 to SC-003).

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5), the session that produced the diff under review
- **Inputs provided**: the phase 2 commit `236e184` (diff against `1844dc0`); `spec.md`, `plan.md`, `tasks.md` (phase 2), `notes.md` (read as claims to verify); the feature 034 flow-down note for shape; the phase 1 script and fixtures; `docs/sdlc/review-process.md` and the review template
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The phase 2 commit documents what phase 1 shipped, accurately: the three message openings quoted in the note match the script and the fixtures, the numbered-red and Lite-`UNGRADED`-at-exit-0 claims match `BASE-001` to `BASE-003`, the stated limits are true (the corrupt-ref limit was reproduced), the roadmap diff is exactly the intended three added and two removed lines with the untouched rows' UTF-8 intact, and the decisions-log entry lists the phase 2 gate, its AI review and the human review as still open instead of claiming them. Nothing is blocking. The follow-ups are one omitted wording form (F1), one unqualified phrase (F2) and one unrecorded gate result (F3), all fixed after the review; the rest are notes. Residual risk is the clone measurement's outcomes, which the reviewer did not redo, and T010, which this commit does not deliver.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FR-006, SC-001 to SC-003) | The note follows the shape of feature 034's: what was wrong, what it does now, what flows down, what an owner may newly see, what does not change, stated limits, what was measured, what to do. The three quoted message openings match `scripts/enforcement-pack.ps1` (`:1330`, `:2162`, `:2425`) and the `BASE-*` `expected.txt` files; the `ReviewProvenance` line drops the `fetch-depth: 0` advice; "a later candidate's base wins" matches `Get-DiffBase`; "the shallow-clone failure is asked first" matches `:2150-2156`. The numbered-red and Lite-`UNGRADED`-exit-0 claims match `BASE-001`/`BASE-002`/`BASE-003` (asserted by the harness; not re-run by this reviewer). Limit (2), a corrupt ref file makes `git rev-parse --verify --quiet` exit 1, was reproduced with a garbage `refs/heads/main`. |
| What flows down | `kit-manifest.json` classes `scripts/*.ps1` as verbatim, so "one verbatim file, `scripts/enforcement-pack.ps1`, and this document" is true; every other file the note names is a kit-only fixture and the note says so. |
| Paths resolve in an adopted project | `pwsh -NoProfile -File scripts/doc-lint.ps1`: OK. The note names `scripts/enforcement-pack.ps1`, `scripts/ritual-checks.ps1` and `scripts/build-digests.ps1`, all verbatim files. |
| Roadmap | `git diff 236e184~1 236e184 -- docs/roadmap.md`: 3 added and 2 removed lines, exactly the GAP-041 status text, the tracker row (`in progress` to `shipped`, the bracketed claim form to the plain path) and the new decisions-log line; no CR characters; the em dashes of untouched rows intact. Figures (1859, 1875, 8 exempt, 3 in the pack), the CI claim (run 39022452441) and the phase 1 review verdict match `notes.md` and `ai-code-review-phase1.md`. |
| No overclaim of certification | The decisions-log entry states "Certified so far: the phase 1 gate and its fresh-context AI review" and lists the phase 2 gate, its AI review and the human review as still open. |
| Measurement method (T009) | Same clones for before and after, `--no-hardlinks`, no clone shared between a damaged and an intact probe, a damaged tip truncated only when probed, the branch name passed as a single `ArgumentList` element, a discarded first run disclosed, the real projects' `git status --porcelain` and `git branch -a` compared before and after. The BASE wording quoted in the table matches the fixtures; the exit codes 1/1 and 0/0 are consistent with the lanes. The clone-level results themselves were not redone. |
| Scope guard | `pwsh -File scripts/scope-check.ps1 -Commit 236e184`: `PASS phase 2 commit 236e184 (3 file(s))` (`adoption/updating.md`, `docs/roadmap.md`, `notes.md`). `pwsh -File scripts/build-digests.ps1 -Check`: `5 digest(s) fresh, 119 marker(s)`. |
| Tasks delivered | T007 (the note), T008 (the roadmap, the digest check) and T009 (the measurement) are delivered by the commit. T010 (the final isolated full-harness run, `ritual-checks -Branch`, `scope-check` on each phase commit, the numbers in `notes.md`) is not, and the notes and the log do not claim it. |
| Rollback safety | The diff is documentation only; `git revert 236e184` restores the parent. Phase 2 is reverted before phase 1. |
| Constitution / domain invariants; security; visual references | The kit has no domain-invariants pack; nothing is written or read beyond documents; no UI. |

## Findings

### F1 — The note quotes one form of the cause and the script has two — MINOR

`adoption/updating.md`, "What it does now", quotes the dispatch warning as `(git merge-base failed with exit <n>)`. The script (`Get-DiffBase`, `:208`) can instead set the cause to `git rev-parse of <ref> failed with exit <n>` when `rev-parse` of the trunk ref exits with something other than 0 or 1. An owner in that state would see wording the note did not list. Verified in code, not reproduced.
*Action: the note now says the cause reads `git rev-parse of <ref> failed with exit <n>` when `rev-parse`, not `merge-base`, failed (done in the follow-up commit).*

### F2 — "No verdict moves" is stated unconditionally — MINOR

True for the states measured, and by construction (the code only changes the text printed once no base was found), but stated without that qualifier.
*Action: the note now reads "No verdict moves, in the states measured and by construction (the code changes only the text printed once no base was found)" (done in the follow-up commit).*

### F3 — The decisions-log entry cites the phase 1 gate result and `notes.md` records none — DOC DRIFT

The entry says "the phase 1 gate (exit 0, anas.m)". The gate result was given to the implementing agent in conversation and is not machine-verifiable; `notes.md` held no record of it.
*Action: `notes.md` now records it as reported to the agent by the owner on 2026-10-17, and the phase 2 gate as not yet reported (done in the follow-up commit).*

### F4 — The tracker row reads `shipped` before phase 2 is certified — MINOR

Matches the feature 033 and 034 precedent and `tasks.md` T008, and the decisions-log entry states what is still open; but the row and its own log can be read against each other.
*Action: none.*

### F5 — Two statements of the measurement's reach — MINOR

The measured "as it stands" script is `1844dc0`; phase 2 changed no script, so it is the script of the tip. The Linux confirmation of exit 128 is CI's, not the clone measurement's (which is Windows only). Both are stated or implied in `notes.md`.
*Action: none.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None.** The phase 2 commit changes no line of `spec.md`, `plan.md`, `tasks.md` or `contracts/`; its document changes are the flow-down note, the roadmap and `notes.md` (evidence, not law).

## Constitution re-check (post-implementation)

**PASS.** Specification First (I): satisfied; no amendment. Architecture Consistency (IV): satisfied; no script changed. Testing Requirements (VIII): satisfied by phase 1 and measured on clones in phase 2. Human Review (IX): engaged by this review, the owner's gate and the human review at merge. Controlled Delivery (X): phase 2 after the phase 1 gate, one phase at a time, user-run gate, no batching. Repository Separation (III), Domain Invariants (V), Security (VI) and External Integration (VII): not applicable.

## Test coverage observed

Phase 2 adds no test; it adds documentation and a measurement. The measurement (`notes.md` T009) compares the pack before (`37ea2c4`) and as it stands (`1844dc0`) on clones of FitForge, FlowBoard and ExpenseTracker: six probe branches each (numbered and Lite, intact, orphan, truncated tip); the intact and orphan probes are byte-identical with equal exit codes, the damaged probes move in the three named messages only. The reviewer ran `scope-check -Commit 236e184`, `doc-lint` and `build-digests -Check`; the full harness (T010) is the implementer's record.

## Residual risk

Small and confined to the record: the clone-level outcomes were not independently re-run, and T010 (the final isolated run) and the owner's phase 2 gate are still to be recorded before the roadmap's `shipped` can be read as certified.
