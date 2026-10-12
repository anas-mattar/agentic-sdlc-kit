# AI Code Review — 021 Load-bearing Developer Roster, phase 2 (the Critical reviewer)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-12
**Branches**: kit repository `021-developer-roster` (phase 2 commit `6fe88b6`, parent `1aad499`)
**Scope reviewed**: `git diff 1aad499 6fe88b6` in full: `scripts/enforcement-pack.ps1` (the `Invoke-CriticalEvidenceCheck` call site, the
`Invoke-CriticalTeamEvidence` block comment and new block), the nine fixtures under `tests/enforcement/cases/enforcement-pack/CRIT-T08/` and
`CRIT-T09/` (`command.json`, `expected.txt`, `recipe.json` each), the two `tests/enforcement/rules.json` entries, `specs/021-developer-roster/notes.md`
and `tasks.md`; against `spec.md` FR-006, `plan.md` D6/D9, and the reader in `scripts/adoption-lib.ps1` (`Roster`, `Name`, `CanApproveCritical`).
**Feature contract**: solo arm unchanged; no new script or package; exact case-insensitive membership through the reader's comparer; nothing
pre-existing changes verdict; territory is `scripts/enforcement-pack.ps1` and `tests/**` only.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-sonnet-5-5 (separate session that produced the phase 2 commit `6fe88b6`)
- **Inputs provided**: phase 2 diff (`1aad499` to `6fe88b6`), CLAUDE.md, review-process.md, the review template, spec.md, plan.md, tasks.md, notes.md, the phase 1 reviews as shape precedent
- **Attestation**: This reviewer did not produce the diff under review.
- **Prior involvement**: none. Fresh context; notes.md was read as a claim and checked.
- **Commands run**: `git diff --stat` and `git diff 1aad499 6fe88b6`; `pwsh -File tests/enforcement/Run-Tests.ps1 -Case CRIT-` on the working tree
  (6fe88b6); a detached worktree of `1aad499` outside the repository with the two new fixture directories and the new `rules.json` copied in, run with
  `-Case CRIT-T0`; the full harness in a detached worktree of `6fe88b6`; `pwsh -File scripts/scope-check.ps1`; `pwsh -File scripts/ritual-checks.ps1`.
  Both worktrees were removed afterwards; `git worktree list` shows only the main checkout.

## Verdict

**APPROVE with follow-ups.** The change does what FR-006 and D6 ask: after the reviewer-is-not-owner check, a Reviewer who is neither empty nor a
placeholder must be on the roster (exact, `OrdinalIgnoreCase`) and must not be denied, with two distinct messages; the solo arm is not touched and the new
code runs only in the team arm. The fixtures fail on the parent for the stated reason and pass now; counts in notes.md are accurate; the full harness,
`scope-check` and `ritual-checks` pass. The follow-ups are small: the exact-match rule has a practical consequence for how a Reviewer line is written
that phase 4 guidance should state (F1), and a few edge cases have no fixture of their own (F2). Certification of the gate is the owner's; nothing here
claims it passed.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FR-006) | Diff read. `Invoke-CriticalEvidenceCheck` passes `-Roster $mode.Roster`; the new block fails (a) a Reviewer with no roster entry and (b) one whose entry has `CanApproveCritical` false. The Reviewer-equals-Owner check is unchanged and precedes it. Solo arm: `Invoke-CriticalSoloEvidence` and its call are untouched in the diff. |
| Plan D6 / D9 | Two messages, each naming the reviewer; the stranger message also lists the roster names. The guard `$reviewer -and $reviewer -notmatch $placeholder` means empty and placeholder reviewers (already failed by the loop above) are not graded twice. The block comment is rewritten to the D9 statement (what membership proves and does not, why feature 013 declined the cross-check). |
| Comparer | Membership uses `[string]::Equals($d.Name, $reviewer, OrdinalIgnoreCase)`, the comparer the reader's `$seen` dictionary uses, so the reader's merged denial (any duplicate copy denies) is what is read here. `Roster` is already deduplicated, so the first match is the only match. |
| Flag not boolean | The reader treats a non-boolean `canApproveCritical` as not permitted; `fail-flag-not-boolean` (`"no"`) confirms it through the whole path. A missing flag is permitted by default (`pass-object-roster`, `pass` with a string roster). |
| Denied entry for another person | `pass-denied-other-person`: the denied developer is the Owner, not the Reviewer, and passes, matching the notes. |
| Pre-existing behaviour | The `enforcement-pack.ps1` diff is the call-site argument, the comment, a new `param` (defaults to `@()`) and one added block. No existing message string, order or condition changes. The only verdict that moves is a team-mode Critical feature whose Reviewer is not on, or is denied by, its own roster, which is the feature. |
| Fixtures fail on the parent | Worktree of `1aad499` with the nine fixtures and the new `rules.json` copied in: `-Case CRIT-T0` gives 77 passed, **8 failed**: the three `fail` cases (`CRIT-T08/fail`, `CRIT-T09/fail`, `CRIT-T09/fail-flag-not-boolean`) each fail on exit code and on output (6 assertions), plus the two inventory/anchor tests (the new rules name emission sites the parent lacks). The six `pass` cases pass on the parent, as notes.md says: those states were already accepted. |
| Fixtures pass on the new code | Working tree: `-Case CRIT-` **97 passed, 0 failed** (79 plus 18). Expected output of the `fail` fixtures read by hand against the script's message text: it matches, including the roster list `(ada, grace)`. `pass-solo-arm` is `OK` with one developer and a stranger-named review, and its 6-file count is right (the roster is in the base commit). |
| Fixtures differ only in the condition under test | `CRIT-T09/fail-flag-not-boolean` and `pass` recipes are the same record except for the flag value; the other recipes share one template. |
| rules.json | Entries `CRIT-T08` and `CRIT-T09`, with `emitAnchor` strings that appear once each in the script; the coverage test accepts them: `coverage: enforcement-pack.ps1 67 of 72 site(s) fixtured (1 exempt, 4 not a rule)`. |
| notes.md counts | `-Case CRIT-` 97 (observed 97); full harness **1255 passed, 0 failed, 0 skipped, `enforcement-tests: OK`** (detached worktree of `6fe88b6`, 834 s); 1255 = 1237 + 18 assertions; coverage 67 of 72 observed. The "seven changed files corrected to six" remark is consistent with the fixture. All rows match. |
| Scope | `git diff --stat`: `scripts/enforcement-pack.ps1`, `tests/**` (nine fixtures, `rules.json`), `specs/021-developer-roster/notes.md` and `tasks.md`. `pwsh -File scripts/scope-check.ps1`: **`scope-check: PASS phase 2 commit 6fe88b6 (31 file(s))`**. |
| Ritual | `pwsh -File scripts/ritual-checks.ps1`: doc-lint OK, enforcement-pack OK, scope-check OK, scope-repos n/a, digests OK, roadmap-claims OK, verify-kit n/a, **`RESULT OK`**. |
| Security | Roster names are interpolated only into failure strings, never evaluated; no secrets. Anyone who can edit the record can add a name; the comment says so (D9). |
| Rollback safety | One commit, no data or schema; a revert returns the parent behaviour. |

## Findings

### F1 — The Reviewer must be written exactly as the roster writes it, so a richer line in an existing review now fails — MINOR

`$reviewer` is the whole value of the `**Reviewer**:` line, compared exactly. A review that writes `Grace Hopper`, `grace (grace@example.com)` or a markdown
link against a roster entry `grace` fails with "not on the developer roster", where it passed before. That is the stated D3 behaviour (exact match) and the
message lists the roster so the fix is visible, but it is the likeliest way an adopted project's existing Critical review starts failing (SC-003 is measured in
phase 4). Nothing in the code or fixtures is wrong.
*Action: phase 4 guidance (`docs/sdlc/critical-delivery.md`, `team-workflow.md`) states that the Reviewer line carries the roster name and nothing else; the SC-003 measurement lists any verdict move of this kind.*

### F2 — Edge cases without a fixture of their own — MINOR

Covered: stranger, denied, non-boolean flag, string roster, object roster, case difference, solo arm, denied non-reviewer. Not covered: a placeholder or empty
Reviewer in team mode with a usable roster (the "not graded twice" guard rests on one `if` condition), a Reviewer equal to the Owner and absent from the roster
(two failures expected), and a denial written in a second duplicate spelling (the phase 1 round 2 review's R2-1; the reader fix is correct, and this check is its
first consumer). I read the code for each and it behaves as intended.
*Action: optional fixtures, the placeholder-Reviewer-with-roster case first; or record in notes.md that these are covered by reading only.*

### F3 — The stranger message lists the whole roster — MINOR

`($names)` joins every roster name into the failure line. For a large team the line is long, and it is useful; the names are already in the committed record.
*Action: none.*

## Amendments in this diff

- [x] **None.** `tasks.md` changes tick T007-T009 only; `spec.md`, `plan.md` and `contracts/` are untouched. Ticking boxes is progress, not an amendment of requirements or territory.

## Constitution re-check (post-implementation)

**PASS.** No new package, script or architecture; one-phase scope held; the comment states the limit of the check instead of overstating it. Nothing engaged late.

## Test coverage observed

`tests/enforcement`: `-Case CRIT-` 97 (was 79); full harness 1255 (was 1237); nine new fixtures with exit-code and output assertions each; the inventory and
anchor tests include the two new rules; coverage 67 of 72 sites. Critical assertions: a stranger fails with the roster named, a denied entry and a non-boolean
flag fail with the second message, a case difference and an object roster pass, the solo arm stays silent.

## Residual risk

Low. The check proves roster membership and permission, not identity, as the new comment says. Residual risk is the exact-match consequence for existing adopted
projects (F1), measured in phase 4. Gate certification and the human review remain the owner's.
