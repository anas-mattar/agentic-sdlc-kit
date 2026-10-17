# AI Code Review — 035 the enforcement pack names the cause when its diff base cannot be read (phase 1)

**Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
**Date**: 2026-10-17
**Branches**: agentic-sdlc-kit `035-pack-diff-base-cause` (phase 1 commit `0b88180`; parent `37ea2c4`)
**Scope reviewed**: `git show 0b88180` in full: `scripts/enforcement-pack.ps1` (`Get-DiffBase` `:186-212`, the `ReviewProvenance` line `:1329`, the `AmendmentAuthority` failure `:2160`, the dispatch warning `:2423`, and the single caller of `Get-DiffBase` `:2401`), `tests/enforcement/rules.json` (the three new entries and the moved anchor of the dispatch-warning rule), the new case directories `enforcement-pack/BASE-001`, `BASE-002`, `BASE-003` (every file), the changed `enforcement-pack/GAP27-003/fail/expected.txt`, and `notes.md`. Also `spec.md`, `plan.md` (P1-P7), `tasks.md` (phase 1), `docs/sdlc/review-process.md` and `specs/_templates/ai-code-review-template.md`. Not read: phase 2 files (not in this diff). Not run by the reviewer: the full harness, and the parent-commit failing proof (the implementer's evidence in `notes.md`, re-run for this review's fixtures only: `-Case enforcement-pack/BASE-` at `0b88180`, 111 passed, 0 failed, the filter also matching other tests).
**Feature contract**: Standard lane, two phases; no new package, no new script, no new harness recipe field; both verdicts stay (numbered lane red, Lite lane `UNGRADED` at exit 0); a missing trunk, no shared history, a shallow clone and every readable repository print today's bytes and exit with today's code (FR-003, FR-004).

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5), the session that produced the diff under review
- **Inputs provided**: the phase 1 commit `0b88180` (diff against `37ea2c4`); `spec.md`, `plan.md`, `tasks.md` (phase 1), `notes.md` (claims to verify, read as such); `docs/sdlc/review-process.md` and the review template; the new fixtures and `rules.json` entries
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The change does what phase 1 set out to do: `Get-DiffBase` reads git's exit codes on the statement after each call, treats exit 1 of `rev-parse --verify --quiet` and `merge-base` as git's answer and any other non-zero exit as a failure to read, and the three messages name the unreadable base and the repair only when that failure is set; every other state keeps today's text. No correctness, scope or byte-identity problem was found. The two follow-ups are wording and inventory notes, not defects (F1, F2). The residual risk is the one the plan records: exit 128 for a missing object is measured on Windows git 2.55 and not yet on the CI image's git.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FR-001 to FR-005) | `Get-DiffBase` `:191-212`: `rev-parse` exit 1 continues, any other non-zero is remembered; `merge-base` is assigned and `$LASTEXITCODE` read on the next statement, before the `Where-Object` filter can reset it (the old code read it after the pipeline); exit 0 with output returns at once; the failure flag is assigned only after the loop, so a later candidate's base wins over an earlier failure; the flag is reset at `:192` on every call. Edge cases read: `origin/main` 128 with `main` readable returns `main`'s base and a null flag; `origin/main` absent with `main` 128 sets the flag; `origin/main` exit 1 then `main` 128 sets the flag; only the first failure is kept. `$script:` scope is consistent (written `:192`, `:210`; read `:1329`, `:2160`, `:2423`); `Get-DiffBase` has one caller (`:2401`). With git absent, `git` throws under `$ErrorActionPreference = 'Stop'` (`:139`) exactly as before. |
| The three messages (P2-P4) and what does not change (P7) | Each carries the new text only under `if ($script:DiffBaseFailure)`; the else branches are the old text unchanged. The shallow-clone failure at `:2139` is asked first and unchanged. `MicroLane`, `PhaseSizeWarning`, `LiteAndAbuse` and `Add-DiffUnreadable` are untouched. `-ReplayBase`/`-ReplayTip` cannot see the flag (the core returns on a null `$Base` before reading either; pre-existing). Lane verdicts: Lite `UNGRADED` at exit 0, numbered `FAIL` at exit 1, per the fixtures. |
| Fixtures | `BASE-001` and `BASE-003` `fail` expect the exit-128 state through `truncateCommit HEAD` on a branch with real history; `BASE-002` `fail` is the numbered twin; each `pass` is the same recipe with the damage removed; `pass-orphan` keeps today's wording and the `fetch-depth: 0` advice (`BASE-002` `pass-orphan` keeps the old `AmendmentAuthority` failure text, exit 1). `rules.json` anchors are unique substrings that match the new text. `GAP27-003/fail/expected.txt` changed only in the three cause sentences (dispatch warning, `ReviewProvenance`, `AmendmentAuthority`); every other byte is identical. The owner accepted that change (2026-10-17). |
| Feature contract held (no package, no new script, no new recipe field) | `git show --stat`: 28 files, all under `scripts/enforcement-pack.ps1`, `tests/enforcement/**` and `specs/035-pack-diff-base-cause/notes.md`; `FixtureRepo.psm1` untouched. |
| Constitution / domain invariants | The kit has no domain-invariants pack. Constitution I (spec first) held: the spec, plan and tasks were approved before the phase commit. |
| Security (authn/authz, secrets, sensitive logging) | The change only changes what is said; it reads git and writes only to the console. Git's stderr stays discarded, so no object content or path is newly echoed. |
| Scope guard | `pwsh -File scripts/scope-check.ps1`: `PASS phase 1 commit 0b88180 (28 file(s))`. `git diff --stat` read for intent: additions under `cases/`, 45 changed lines in the script, 29 in `rules.json`, no unrelated file. |
| Rollback safety | The diff is a script, fixtures, an inventory and a notes file; `git revert 0b88180` restores the parent. No schema, no migration. Phase 2 must be reverted first (`tasks.md`). |

## Findings

### F1 — The implemented wording joins the clauses with a full stop, not the plan's dash — DOC DRIFT

`plan.md` P2 and P3 sketch the new messages as `... - the object store may be damaged: run git fsck, or re-clone`. The code (`:2423`, `:2160`) and the fixtures use `... . The object store may be damaged: run git fsck, or re-clone` (and `AmendmentAuthority` puts its clause before the constitution reference). The fixtures pin the implemented wording byte for byte, the plan names the wording as a review item, and the messages say the same thing, so this is a plan-versus-code mismatch only. The plan is an approved document and is not rewritten by the phase that implements it.
*Action: none to the code. Recorded in `notes.md` (done in the follow-up commit); the owner may amend `plan.md` P2-P3, recording the approver, if the sketch should match.*

### F2 — The dispatch-warning rule's anchor moved and its notes did not say why — DOC DRIFT

In `rules.json` the existing rule whose summary is "a run with no computable base says that nothing was compared" had its `emitAnchor` changed, because the old anchor text now occurs in both branches of the warning (the old and the new) and would match two rules' sites. The new anchor is unique and covers the no-integration-branch branch; coverage holds (the full-harness run at `0b88180` reports no unowned site). That rule's `notes` did not mention that the unreadable-base wording is now owned by `BASE-001`. The reviewer did not itself verify the exempt count: the plan's "stays 7" is not the measured figure (8 in total, 3 in the pack, unchanged from the parent; recorded in `notes.md`).
*Action: a sentence added to that rule's `notes` naming `BASE-001` as the owner of the unreadable-base wording (done in the follow-up commit).*

### F3 — Exit 128 for a missing object is measured on Windows git only — MINOR

Inferred, not tested here: git exits 128 (`die()`) for a missing or corrupt object on Linux as on Windows, and a git that exits 1 for a failure falls back to today's text, never to a false cause (plan Risks). The branch's CI run on the CI image's git is the second probe.
*Action: the owner pushes the branch and reads the CI result; recorded as open in `notes.md`.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None.** The phase commit changes no line of `spec.md`, `plan.md`, `tasks.md` or `contracts/`; its only document change is `notes.md`, which is evidence and not law. (F1 records a wording difference from the plan and does not amend it.)

## Constitution re-check (post-implementation)

**PASS.** Specification First (I): satisfied. Architecture Consistency (IV): satisfied, no new file, `enforcement-pack.ps1` stays standalone. Security (VI): satisfied, nothing is written and no secret is read. Testing Requirements (VIII): satisfied, every new reachable site has a passing and a failing hand-written fixture, shown failing on the parent commit. Human Review (IX): engaged by this review and the owner's gate. Controlled Delivery (X): one phase, user-run gate, no batching. Repository Separation (III), Domain Invariants (V) and External Integration (VII): not applicable.

## Test coverage observed

The enforcement harness (Pester, real temporary git repositories, hand-written expectations). New: `BASE-001` (fail, pass, pass-orphan), `BASE-002` (fail, pass, pass-orphan), `BASE-003` (fail, pass). The critical assertions are the `fail` outputs pinning the three new messages, the `pass-orphan` outputs pinning that no history in common keeps today's text, and the unchanged existing cases (`AMEND-001/pass-lite-docs-readme-only-shallow`, `AMEND-003`, `CRIT-R02`, `CRIT-R03`, `GAP27-001`, `GAP27-002`, `GAP27-004`, `PACK-001`) pinning byte-identical output. The implementer's record (`notes.md`): full harness 1859 on the parent, 1875 at the phase commit, exit-code probes on git 2.55.0.windows.5, a byte comparison of 15 no-base cases between the parent and the new script (11 identical, 4 differing in the damaged-commit text only). The reviewer re-ran the `BASE-` selection only.

## Residual risk

Small. The behaviour change is confined to text on a state that was previously mislabelled; both verdicts are unchanged and every legitimate no-base state prints identical bytes. What remains is F3 (the CI image's git) and the owner's gate run.
