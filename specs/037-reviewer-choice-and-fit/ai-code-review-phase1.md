# AI Code Review — 037 Reviewer choice and pull-time fit, phase 1

**Reviewer**: fresh-context agent (Claude, model Sonnet 5.5)
**Date**: 2026-10-18
**Branches**: agentic-sdlc-kit `037-reviewer-choice-and-fit` (commit `7ff7df1`, parent `b6b39d4`)
**Scope reviewed**: `scripts/claim-review.ps1` (all); the review-claim section appended to `scripts/adoption-lib.ps1` (`ConvertTo-ReviewSlug`, `Get-RosterBySlug`, `Get-ReviewClaims`); `tests/enforcement/lib/FixtureRepo.psm1` (`author` field); the new `CRV-*` entries in `tests/enforcement/rules.json` and `emission-idioms.json`; the `Coverage.Tests.ps1` list change; recipe/command/expected files of every `claim-review/CRV-00x` fail/pass pair (diffed pairwise for CRV-001/2/4/5/6/7/8) and the three `pass-review-ref-ignored` variants (listed, not read line by line); `tasks.md` diff (checkbox ticks only); `notes.md`. Probed by hand in a scratch repository with a bare origin under the system temp directory: the slug rule against `git check-ref-format`, a first and second claim (text and `-Json`), the reader with and without `-WithAuthors`, a reader pointed at a broken origin, glob and unknown feature names. Ran `-Case claim-review/CRV-008` (4 cases pass; the coverage line reads `claim-review.ps1 9 of 9 site(s) fixtured`). Not run: the full harness, `ritual-checks.ps1`, the parent-commit run of the new fails.
**Feature contract**: phase 1 changes no verdict; territory is `scripts/adoption-lib.ps1`, `scripts/claim-review.ps1`, `tests/**`; the claim is a remote ref `refs/heads/review/<feature>/<slug>` never matched by the three existing ledger regexes; the writer never selects, ranks or proposes a reviewer and never forces a push; a failed read is `Failed` with a cause, never an empty list.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5); Owner: anas.m
- **Implementer**: Claude Sonnet 5.5 session that produced commit `7ff7df1` (a different, earlier context from this reviewer)
- **Inputs provided**: commit `7ff7df1` (diff and tree), spec.md, plan.md, tasks.md, contracts/claim-review-cli.md, data-model.md, notes.md, tests/enforcement/README.md
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups** — the change adds one writer (`claim-review.ps1`) and one reader (`Get-ReviewClaims` plus the slug rule) and nothing existing is edited: `adoption-lib.ps1` is a pure append and no other script is touched. By hand I found no path where the command claims wrongly, pushes wrongly, forces, or reads a failed git call as success or as "no claims": every git read has its exit code taken from the right command, the push is a plain non-forced refspec, and the one-element-array unrolling that bit the first draft is handled. The slug rule produced a ref name `git check-ref-format` accepts for every name I tried that has any usable character. The residual risk is in the tests, not the code: the reader's `Failed` channel and the `-WithAuthors` path (the exact recurring defect class) have no fixture at all, the success fixtures never assert what was pushed, and task T004 is ticked although CRV-010, CRV-011 and CRV-012 as written do not exist and the CRV numbering was changed without a record. Phase 2 builds directly on the untested half, so F1 and F2 should be closed before it starts.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | Contract refusals 1-8 each map to a `Stop-Refused` site in `claim-review.ps1` (lines 62, 69, 76, 81, 87-100, 105-114, 117 for the build/push) and each has a fail fixture except the two inside `Stop-NotMade` (fetch, commit-tree), which notes.md says it does not fixture. Success output names the ref; second run prints `ALREADY CLAIMED` and skips the push (I ran both, text and `-Json`: exit 0, `ALREADY: true`). The pushed commit read back: parent = feature tip, message `review claim: 007-x by grace`, author = the pusher's git identity. |
| Visual-reference match | N/A (no UI). |
| Feature contract held (no unapproved table/migration/permission/package) | No package, no schema. `git show 7ff7df1 --name-only` outside `tests/**`: `scripts/adoption-lib.ps1`, `scripts/claim-review.ps1`, and the feature's own `notes.md` and `tasks.md` (checkbox ticks only). All within phase 1 Territory. `kit-manifest.json` untouched; notes.md says doc-lint classified the new script as shipped (not re-run by me). |
| Constitution / domain invariants | The command only writes and never compares the claimant with the Owner or selects a reviewer (code read end to end). Certification is not claimed anywhere. |
| Security (authn/authz, secrets, sensitive logging) | `-Feature` is used in a refspec and `git fetch origin $Feature` only after `ls-remote` proved a branch of exactly that name exists (a branch name cannot begin with `-`), and the match is an escaped exact regex; `-Feature '007-*'` is refused as not a branch. The claim carries no secret. A claim remains "a written claim" (the header says so). |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | `--stat` read: 83 files, 1091 insertions, 9 deletions (the deletions are the 8 tasks.md checkbox lines and the one `Coverage.Tests.ps1` line). `scope-check.ps1` not run by me. |
| Rollback safety | Pure append plus new files; reverting the commit removes the feature. The only external effect is a pushed `review/...` ref, which no existing reader matches (probed regex and the three `*-review-ref-ignored` controls). |

## Findings

### F1 — The reader's `Failed` channel and the `-WithAuthors` path have no fixture; T004 is ticked without CRV-010/011 — CONFIRM (not blocking the commit, must be closed before phase 2)

`tasks.md` T004 names `CRV-010` (the reader's failure channel: unreadable ledger or author is `Failed` with a cause, never an empty list) and `CRV-011` (slug cases including a name that slugs to empty). Neither exists under `tests/enforcement/cases/`. `Get-ReviewClaims -WithAuthors` (`scripts/adoption-lib.ps1`, the `$meta`/fetch-retry block) is exercised by no case and has no caller yet, so a defect there would first appear in phase 2's grading. In `claim-review.ps1` the only fixtured read failure (CRV-003) trips on the feature `ls-remote` at line 61, before `Get-ReviewClaims` runs, so the `$existing.Failed` branch (line 69) and the lib's own `ls-remote` failure are unreached by any test: a regression turning either into "no claims" would pass the whole harness. By hand the code is right (I broke origin and got `Failed=True`, cause `git ls-remote --heads origin failed (git exited 128)`; a fresh clone with the claim commit absent returned the author via the fetch fallback). notes.md says "25 new cases" and lists what is not fixtured (the two `Stop-NotMade` sub-paths) but does not say CRV-010/011 were dropped.
*Action: implementer adds the CRV-010 and CRV-011 fixtures (or amends T004 with an owner-recorded approval that they move to phase 2, and states it in notes.md) before phase 2; owner decides.*

### F2 — CRV numbering diverges from tasks.md and the contract-to-case mapping is unrecorded — DOC DRIFT

T004 defines `CRV-009` as the success with its idempotent second run. `rules.json` and the fixtures define `CRV-009` as the roster-slug-collision refusal (`claim-review/CRV-009/fail`), while the success is carried by every `pass` twin, and idempotence by `CRV-008/pass-already-claimed`. `CRV-012` (three readers byte-identical with a `review/` ref present) exists only as three `pass-review-ref-ignored` variants filed under other rules' ids (`CLF-012`, `CLAIM-001`, `TERR-001`) with no `CRV-` rule. Behaviour is covered; the paper trail is not.
*Action: implementer reconciles T004's wording (or notes.md) with the numbering actually used; no code change.*

### F3 — Success fixtures assert only stdout; nothing pins what was pushed or that a push is never forced — MINOR

All `pass` fixtures and `pass-json` compare output text. No fixture reads back the pushed ref's commit (parent, tree, message, author), and none proves a rival or already-existing ref is refused rather than overwritten (the harness has `originRivalOnPush` for this). The first draft's tree bug (notes.md) shows the build step can go wrong while the push still succeeds; only the author check in phase 2 would notice. CRV-008/fail is a transport failure (push URL does not exist), not a non-fast-forward rejection. I confirmed by reading line 115 that the refspec is `<sha>:refs/heads/<ref>` with no `+` and no `--force`, so the property holds today.
*Action: add one success fixture that asserts the ref's parent and message, and one rival-ref case, in phase 2 or as a follow-up; not blocking.*

### F4 — "Already claimed" counts any ref with the slug, compared case-insensitively — MINOR

`claim-review.ps1:112` uses `-eq` on `$_.Slug`, which is case-insensitive in PowerShell, and `Get-ReviewClaims` accepts any ref `review/<feature>/<segment>` without checking it is a commit built by this tool. A hand-pushed `review/007-x/Grace` (on a case-sensitive server) or an unrelated commit at `review/007-x/grace` makes the command print `ALREADY CLAIMED` and push nothing, though the claimant has not made a conforming claim. This is consistent with "a pushed ref is the claim" and phase 2 reads authors, so the exposure is small.
*Action: none required; use `-ceq` when convenient, and note the "any ref is a claim" semantics in the phase 4 guidance.*

### F5 — `commit-tree` output taken as `$commit[0]` with stderr merged — MINOR

`claim-review.ps1:113-114`: `@(git commit-tree ... 2>&1)` merges stderr into the result and the sha is `$commit[0]`. If git emits a warning on stderr before the sha (a signing or hook message), `$commit[0]` is an error record, not the sha; the push then fails and is refused (it fails safe, with a confusing message). In the probe the output was clean.
*Action: none required; capture stdout and stderr separately if a warning ever appears.*

### F6 — Slug rule is not injective and some roster names have no slug — MINOR (design limitation, refused clearly)

`José` and `Jos` both slug to `jos`; `@{u}` and `u` to `u`; an all-non-Latin or all-punctuation name slugs to empty (`李`, `@`, `..` probed). Both cases are refused by name with "have no unique ref name", so no wrong claim is possible, but a team whose roster names are non-Latin cannot use the command at all, and the refusal wording ("no usable characters") is the only hint. Case: `a.-.lock` becomes `a.--lock` (accepted by git, just unnormalised).
*Action: none for phase 1; mention in phase 4 guidance that roster names should contain ASCII letters or digits.*

### F7 — Fixture twins differ in more than one condition in places — MINOR

Pairwise recipe diffs: CRV-005 changes the roster and the `-As` argument (`ada` vs `grace`); CRV-008 swaps the whole origin topology (nested bare origin with a bad push URL vs `self`); CRV-004 changes `-Feature`. In each the extra difference cannot rescue the fail for a wrong reason (the fail text asserted is specific to the intended refusal), so the cases are sound, but they are not a single-condition twin as the README asks. CRV-001, 002, 006, 007 are clean one-condition twins.
*Action: none.*

### F8 — T001 baseline was not recorded as written — ACCEPTED (stated in notes.md)

T001 requires a full harness count on the parent and a saved-bytes comparison of three scripts; notes.md says the parent run was stopped, the full pass count is not recorded, and the byte comparison was replaced by existing cases passing plus control variants. The task is nonetheless ticked. The substitute is reasonable here because the diff to existing code is a pure append (verified: the `adoption-lib.ps1` hunk is `@@ -363,3 +363,85 @@`, additions only; no other script touched), so "no verdict moved" follows from the diff itself. I did not run the full harness.
*Action: none beyond the owner's gate on the full harness, as notes.md says.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly — **None.** `git show 7ff7df1 -- specs/` changes `tasks.md` only by ticking T001-T008 (task text unchanged on every line) and adds `notes.md` (new file). `spec.md`, `plan.md`, `contracts/` and `data-model.md` are untouched. Ticking checkboxes is not an amendment, but see F1 and F8 on whether the ticks match the task text.

## Constitution re-check (post-implementation)

PASS. Constitution I (no self-approved amendment): none made. VII (contract before implementation): the command follows `contracts/claim-review-cli.md`; its refusal order differs slightly (the "not on origin" check precedes the roster checks) but the contract fixes no order. IX/X: the new script is a shipped file with a header and the emission-idiom entry; phase scope respected (one phase, no check changed). The review-independence of claims is explicitly left to the check in phase 2.

## Test coverage observed

New: 22 cases under `claim-review/` (CRV-001 to CRV-009, a fail and pass each, plus `CRV-005/fail-no-record`, `CRV-006/pass-slug-spaces-and-dots`, `CRV-008/pass-already-claimed`, `CRV-008/pass-json`) and three controls that a `review/` ref does not move `roadmap-claim-check`, `territory-check` or `claim-feature`. Expectations are hand-written exact strings including exit codes. Coverage sweep reports `claim-review.ps1 9 of 9 site(s) fixtured`. Observed: `-Case claim-review/CRV-008` passed (the harness ran its whole Pester suite, 103 passed, 0 failed). Gaps: F1 (reader `Failed`, `-WithAuthors`, fetch fallback, slug unit cases, `Stop-NotMade` fetch and commit-tree sites), F3 (pushed content, non-fast-forward).

## Residual risk

The code looks correct; the risk concentrates in untested reader paths that phase 2 will start depending on (F1) and in the success path not asserting its pushed content (F3). Before phase 2: close F1 and reconcile F2. After merge: nothing in phase 1 changes a verdict, so a revert is clean.
