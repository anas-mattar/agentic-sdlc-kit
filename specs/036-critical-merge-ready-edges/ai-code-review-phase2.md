# AI Code Review — 036 Critical merge-readiness open edges (phase 2)

**Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
**Date**: 2026-10-18
**Branches**: agentic-sdlc-kit `036-critical-merge-ready-edges` (phase 2 commit `94352c4`; parent `e8ac2e0`)
**Scope reviewed**: `git show 94352c4` and the diff against `e8ac2e0`, including whitespace-insensitive diffs: `docs/sdlc/critical-delivery.md`, `adoption/updating.md`, `docs/roadmap.md`, `docs/digests/critical-digest.md`, and this feature's `notes.md` (in full) and `tasks.md` (T007 to T011). Read for truth-checking: `Get-CriticalMergeReadiness`, `Get-TaskTickCount` and `Invoke-CriticalEvidenceCheck` in `scripts/enforcement-pack.ps1`. Re-derived: the FitForge tick counts, in a throwaway `--no-hardlinks` clone under the system temp directory.
**Feature contract**: documentation, digests, a roadmap update and a measurement record only; no script or test change; no approved spec, plan or task text rewritten; the prose must be true of the code shipped in phase 1; the measurement claims no more than it shows.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5), the session that produced commit `94352c4` on `036-critical-merge-ready-edges`
- **Inputs provided**: commit `94352c4`; `notes.md` in full; `tasks.md` T007 to T011; pieces of `scripts/enforcement-pack.ps1`; the phase 1 review (head and provenance format); a throwaway clone of FitForge; the output of `build-digests.ps1 -Check`, `ritual-checks.ps1` and `scope-check.ps1`. The reviewer did not read `spec.md` or `plan.md` in full, did not read `docs/sdlc/review-process.md` or the review template (it took the format from the phase 1 review), did not open or run the `CRIT-R04` fixtures, did not run the full harness, and replayed only the task counts, with its own reader, not the kit's before-and-after pack.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The reviewer found no false statement about the code; it re-derived the FitForge measurement independently and every number agrees. The follow-ups are one process defect (line endings) and two overstatements, none touching the code.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Prose true of the code | The `Why` text is quoted correctly (`enforcement-pack.ps1:513-515`); the `not treated as mid-feature` line is built from `$readiness.Why` and `$declareHint` (`:627-637`) and the suffix matches `:627` exactly, with the `item 5` anchor. The suffix appears only when `Marked` is false, at the heuristic's two sites; the declared-`pending` warning returns earlier and is byte for byte feature 025's, with an unticked task, no checkbox task or an unreadable `tasks.md`. A committed artifact returns before the new rule. The rule only turns a warning into a failure. Comments and fences are hidden, a glued box is not a task, an unterminated `<!--` hides later lines. |
| Measurement | Re-derived: 43 commits, 41 with a plan, 102 tasks / 102 unticked at the first plan commit (`d067570`), 106 / 1 at commit 32 (`5c740f1`), 128 / 6 at the tip (`b9e1d88`), minimum unticked 1, open at the tip T077, T078, T084, T085, T096, T100. Kit features at `HEAD`: 033 9/0, 034 10/0, 035 0/10. The before-and-after pack claim ("same warning at 41 commits") was taken from `notes.md`, not re-run by the reviewer. |
| Numbers and shape | 1875, 1907, 43, 128 and 6 agree across the roadmap row, the decisions-log entry, the flow-down note and `notes.md`; the 036 row is still `specified`; the log entry's shape matches features 034 and 035. |
| Digests and checks | `build-digests.ps1 -Check` OK (5 fresh, 121 markers); the two new markers are under 120 characters; `adoption/updating.md` carries none and the adoption digest is unchanged (at its 40-line cap); `ritual-checks.ps1` `RESULT OK`; `scope-check.ps1` PASS on `94352c4` (6 files). |
| Scope guard | Six files: the three documents, the critical digest, `notes.md`, `tasks.md` (T007 to T010 ticked, text byte-identical, T011 open). No script or test moved; no approved spec or plan text rewritten. |

## Findings

### F1 — `critical-delivery.md` was committed with CRLF line endings — FIXED

The blob had 0 CR bytes at `e8ac2e0` and 244 of 244 lines at `94352c4`, so `git diff` showed 244 insertions and 229 deletions for a 15-line change. It is the only `docs/**` or `adoption/**` file in the commit with CRLF, and it flows down verbatim to adopted projects. No gate caught it. (Verified by the implementer: same counts.)
*Action: done in the follow-up commit: converted back to LF; its diff against `e8ac2e0` is +15 lines again. Every file touched was checked for CR bytes after the edits.*

### F2 — "the feature's owner ticked honestly" is contradicted by FitForge's own list — FIXED

T078, T084 and T085 carry a later "Record corrected, phase 12 (F11): was `[x]`" note (T078: its test does not exist), so work was ticked before it was done. At commits 32 and 33 only one task was open (T100, the review filing; verified by the implementer with `git show`). The 0-of-43 result stands; the explanation did not.
*Action: done: `adoption/updating.md`, `docs/roadmap.md` and `notes.md` now say the unticked count never reached 0 and that the ticks were not reliable either, which is the proxy limit in a real history.*

### F3 — the roadmap log entry said the phase 2 gate was not recorded — FIXED

The entry was written before the gate ran.
*Action: done: the phase 2 gate (exit 0, anas.m) moved to "Certified so far"; the final isolated run, CI and the human review stay open.*

### F4 — the prose did not say that `*` and `+` bullets count — FIXED

The reader accepts `-`, `*` and `+` list items; a numbered `1. [ ]` item is not read.
*Action: done: stated in `critical-delivery.md` and in the flow-down note.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None.** No line of `spec.md`, `plan.md` or `contracts/` changed; `tasks.md` changed only task checkboxes (T007 to T010 ticked), which the amendment check exempts; `notes.md` is evidence.

## Constitution re-check (post-implementation)

**PASS**, as the reviewer found no violation: the phase touched only its own territory, no approved text was rewritten, and the claims it adds are true of the shipped code.

## Test coverage observed

No test changed. The reviewer ran `build-digests.ps1 -Check` (OK), `ritual-checks.ps1` (OK) and `scope-check.ps1` (PASS). The full harness is the implementer's run on an isolated checkout of the final commit (T011).

## Residual risk

The measured 0 of 43 shows the reader on a real file, not that an owner will leave `pending` in place; the proxy limit (ticks are not proof) is stated in all three documents. Merge after the owner's human review.
