# AI Code Review — 016 Multi-line Code Spans (Phase 3)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-10
**Branches**: agentic-sdlc-kit `016-multiline-code-spans` (tip `6fbee08`)
**Scope reviewed**: `git diff 08cbee9..6fbee08` (one commit, 4 files): the flow-down note in
`adoption/updating.md`, one added line in `docs/digests/adoption-digest.md`, the Phase 3 section of
`notes.md` (T022, T023, T025, T026 draft), `tasks.md`.
**Feature contract**: phase 3 = FR-011 / SC-005 / SC-007: tell adopters, and check the prediction.
Territory: `adoption/updating.md`, `docs/digests/*-digest.md`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-opus-5-5 (the implementing session)
- **Inputs provided**: `git diff 08cbee9..6fbee08`, `CLAUDE.md`, spec.md (FR-009, FR-011, FR-012,
  SC-005, SC-007, Out of Scope), research.md R1, tasks.md Phase 3, notes.md "Phase 3", the phase-2
  review (format), `docs/roadmap.md` GAP-025/028 rows, `scripts/enforcement-pack.ps1` and
  `markdown-lib.ps1` call sites. I did not re-read the constitution or `docs/sdlc/*` in full.
- **Commands run** (clones under `.../scratchpad/p3r`; the real adopted projects and the kit working
  tree were not modified except for this file):
  - `pwsh -File scripts/update-kit.ps1 -DryRun -Target D:\solutions\expense-tracker` from the tip.
  - Clean `git clone` of fitforge, flowboard, expense-tracker. Per clone: `ritual-checks.ps1`
    (before); copy the three scripts from the tip; `build-digests.ps1`; compare each digest to
    `git show HEAD:<file>` with `cmp`; then also copy the tip's `adoption/updating.md`, regenerate,
    `git diff --ignore-cr-at-eol --stat -- docs/digests`, `ritual-checks.ps1` (after).
  - `pwsh -File scripts/scope-check.ps1`, `scripts/ritual-checks.ps1`,
    `scripts/build-digests.ps1 -Check` on the kit.
  - `git diff --name-only`, grep of kit docs for GAP-025/028 and "per-line".
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES.** One adopter-facing sentence is false in the real update path (F1). The fix is
a wording change inside Territory. Everything else reproduces.

## Findings

### BLOCKING

- **F1. The note's "expect no diff" / "byte-identical" is true only for the scripts alone; the real
  update also changes the adopter's adoption digest.** `update-kit.ps1 -DryRun` from the tip applies
  **four** files, not three: the three scripts and `adoption/updating.md` itself (the dry-run at
  `08cbee9` predates the note, so T022 could not see it). `adoption/updating.md` is the adoption
  pack's only member (`digest-packs.json`), and the note adds a marker. I reproduced it in all three
  clones: scripts only gives 5 of 5 digests byte-identical to `HEAD` (the note's claim, true), but
  with the tip's `updating.md` as well, regeneration adds exactly one line to
  `adoption-digest.md` (`1 insertion`; markers 82 to 83 in fitforge, 59 to 60 in flowboard and
  expense-tracker). Verdicts stay `RESULT OK`. So "Apply the update, regenerate your digests, and
  expect no diff" is false: an adopter who skips the regeneration fails `-Check`, and one who
  regenerates sees a diff. Also "three scripts flow down verbatim, and nothing else" is not what the
  tool reports. Remedy (wording only): say the three scripts plus this document flow down, that the
  scripts alone change no digest and no verdict (what was measured), and that the adoption digest
  gains this note's one line (so regenerate and commit it). The T023 table in `notes.md` should say
  its "after" state is scripts-only.

### Non-blocking

- **F2. "The resulting loss of a marker is no longer silent: it is item 2" is slightly broad.** The
  report covers only a marker-shaped line that starts a line inside an open comment (phase-2 review
  F1: a marker after a same-line `-->` is neither harvested nor reported). Consider "a marker on its
  own line".
- **F3. FR-012 text outside Territory is still open, as expected for this phase.** `docs/roadmap.md`
  row GAP-028 (line 58) still says per-line and open, GAP-025's row (line 55) still reads as an
  unqualified single-line fix, and no new gap row exists yet (T026 is a draft in `notes.md` only,
  as the task says). The library comment is already corrected (`markdown-lib.ps1`). Report, not fix.
- **F4. T026 draft** is accurate against research R1 row 2 (2 of 3 harvested, line 3 plain text,
  `html_block`s) and spec Out of Scope, and it does not overclaim: it says the feature did not fix
  it, that the loss is loud, and leaves the open question to the owner. "round-2 F2, 2026-09-30" is
  the owner's acceptance date as I could trace it only loosely (the spec amendment dated 2026-09-30
  is round 3); confirm the label before filing.

## Focus answers

1. **Scope**: PASS. Changed files are `adoption/updating.md`, `docs/digests/adoption-digest.md`,
   `notes.md`, `tasks.md`. `scope-check.ps1`: `PASS phase 3 commit 6fbee08 (4 file(s))`. The
   `tasks.md` diff is ten lines, checkbox flips T022-T026 only; no amendment.
2. **Note claims**: true and measured, except F1. Reproduced: three scripts (plus `updating.md`, F1),
   no surgical file, no conflict (expense-tracker dry run); scripts-only digests byte-identical
   (15 of 15 via `cmp` against `git show HEAD:`); `RESULT OK` before and after; no skipped-marker
   report in any run. Remedies (delete the marker, or close the comment above it) match DIGEST-020.
   "The amendment check keeps its per-line reading" is true: `Get-VisibleFromText` in
   `enforcement-pack.ps1` calls `Convert-SpanText` (per-line), not `Convert-CodeSpanMarkers`. F2's
   shape (unpaired `<!--` in prose still opens a comment in the kit; the amendment check relies on
   it) is described accurately.
3. **Digest marker**: 117 characters of text, within the 120 bound; states the rule correctly.
   `build-digests.ps1 -Check`: `digests: OK (5 digest(s) fresh, 83 marker(s))`; the diff adds that
   one line only.
4. **T026**: see F4.
5. **Contradictions**: none inside `adoption/updating.md`. Outside Territory: F3 only.
6. **Checks**: `ritual-checks.ps1` `RESULT OK` (scope-repos and verify-kit `n/a`, expected for the
   kit); `scope-check.ps1` PASS.
