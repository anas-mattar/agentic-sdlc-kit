# AI Code Review — 016 Multi-line Code Spans (Phase 2)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-10
**Branches**: agentic-sdlc-kit `016-multiline-code-spans` (tip `7158c4c`)
**Scope reviewed**: `git diff f240e21..7158c4c`: the amendment commits `2a51c55` (plan D6, T016a) and
`f4b544e` (plan D8/D11, T020a), and the phase-2 commit `7158c4c` (T015-T021): the DIGEST-020 report in
`Get-DocMarkers`, four DIGEST-020 cases, the 22 amended DIGEST-001 `pass-hidden-*` guards, the
`rules.json` inventory entry and notes, `notes.md`, `tasks.md`.
**Feature contract**: phase 2 = FR-009 / US3: a marker passed over because a comment is open fails the
run by file and line (D8). Territory: `scripts/build-digests.ps1` and `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-opus-5-5 (the implementing session)
- **Inputs provided**: `git diff f240e21..7158c4c` (scripts, rules.json, plan.md, tasks.md, notes.md,
  all case diffs), `git show --stat` of `2a51c55` and `f4b544e`, `CLAUDE.md`, the phase-1 round-10
  review (format), and the phase-2 section of `notes.md`. I did not re-read the constitution or
  `docs/sdlc/*` in full; I relied on the project instructions loaded with the task.
- **Commands run** (scratch copies under `.../scratchpad/p2` (`git archive 7158c4c`) and `p2m`; the
  working tree was not modified except for this file):
  - `pwsh -File tests/enforcement/Run-Tests.ps1` in `p2`: 899 passed, 0 failed, `enforcement-tests: OK`.
  - Mutation (a) in `p2m` (`scripts/build-digests.ps1` from `f240e21`, i.e. T018 reverted),
    `Run-Tests.ps1 -Case DIGEST-020`: 33 passed, 8 failed. `fail`, `fail-f2-shape` and
    `fail-d5-tail` each fail both assertions; `pass` passes; the inventory's two checks fail.
  - `pwsh -File scripts/build-digests.ps1 -Check -Root <root>` for the kit, fitforge, flowboard and
    expense-tracker: all `digests: OK`, no skipped-marker report.
  - Seven hand probes through `-Check` (tab and upper-case marker, no-space marker, trailing text,
    fence line inside a comment, marker after a close on the same line, two markers, plain marker).
  - `pwsh -File scripts/scope-check.ps1`: `PASS phase 2 commit 7158c4c (82 file(s))`.
  - `git diff --name-only` checks for scope, and a merge-base check that none of the 22 amended
    cases existed before this branch.
  - I did not run `scripts/ritual-checks.ps1` as a whole, and I did not re-run the implementer's
    mutations (e)-(o) and `p-reapply` on the 22 guards. I rely on notes.md for those (see F2).
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE.** The report is a 7-line fail-closed addition. The four DIGEST-020 cases are real guards.
The 22 guard amendments are scoped, approved by a named human, and still discriminate. No BLOCKING
finding.

## Findings

### BLOCKING

None.

### Non-blocking

- **F1. The report covers only marker-shaped lines that start a line inside an open comment.** A
  marker after a close on the same line (`--> <!-- digest: r -->`) is neither harvested nor
  reported: `-Check` printed `digests: n/a (no digest markers)`. This is the existing "not a
  standalone line" rule and the code comment states it, and it is outside D8's wording ("a line
  matching the marker grammar"). It is the same silent-loss class, though; consider naming it in
  the phase-3 adopter note or a later amendment.
- **F2. The 22 amended guards' descriptions still say "the check must say OK".** The appended
  sentence explains the new exit-1 expectation, but the earlier sentence in each `recipe.json`
  (e.g. `pass-hidden-nbsp-line`) is now stale and contradicts the expectation. Cosmetic; a later
  pass can reword it. Also, the guards now fail on their output assertion alone under a
  harvest-the-marker mutation (the exit code is 1 either way), which is why their discrimination
  rests on the exact two-line expected output. That holds: a mutant that harvests the marker drops
  the report and reads stale. I verified that logic and the 22 expectations by reading the diffs, but
  did not rerun mutations (e)-(o).
- **F3. `-match` for the report vs the grammar's `-cmatch`.** The report is case-insensitive
  (`<!-- Digest:` is reported, correct and the same test DIGEST-005 uses). Fine; noted only because
  the harvest grammar is case-sensitive.

## Focus answers

1. **Fail-open in `Get-DocMarkers`**: no new fail-open. Inside `$inComment` the report runs before
   the close is looked for, on the raw line, for any `^\s*<!--\s*digest\b` (tab, upper case, no
   space, trailing text, closed or not: all reported in probes). Fence lines inside a comment are
   not treated as fences, so a marker after one is still reported. Outside a comment nothing
   changed. The only silent skip left is F1. False positives: zero on the kit and the three adopted
   projects (T015's claim reproduced; the generator reads only the manifest's documents).
2. **DIGEST-020**: all four are real. Each pins the report line and `RESULT FAIL (1 issue(s))`; `pass`
   pins the nearest state (both markers harvested, OK). With the report reverted, three fail and
   `pass` passes (mutation a). `fail-f2-shape` is not wholly verbatim (lines 1 and 7 are the
   implementer's wording); notes.md and the description say so.
3. **22 guards**: each keeps its recipe, document and digest untouched (only `command.json`
   exit code, `expected.txt`, and one description sentence changed). Each now expects the report line
   at its hidden marker's line and exit 1. They still guard what phase 1 intended, as above.
4. **Scope**: changed files are `scripts/build-digests.ps1`, `tests/**` and feature documents
   only; `scope-check.ps1` PASS. Both amendments (`2a51c55`, `f4b544e`) are committed alone and carry
   "approved by anas.m, 2026-10-03" in message and in the plan and tasks records, with the T020 stop
   rule followed (the owner decided, not the implementer). SC-003: all 22 changed cases are
   branch-added phase-1 cases (none exists at the merge-base); DIGEST-005 and every other
   pre-feature case are untouched, and the full suite passes.
5. **Tests run**: 899/0; DIGEST-020 mutation (a) as above.
