# AI Code Review — 029 Unchecked git reads named state (phase 1)

**Reviewer**: fresh-context agent, Claude Sonnet 5.5 (claude-sonnet-5-5)
**Date**: 2026-10-15
**Branches**: repo `agentic-sdlc-kit` `029-unchecked-git-reads-named-state` (phase 1 commits `18fc556`, `0595fc5`; tip `0595fc5`)
**Scope reviewed**: `git diff 48ccb8f..0595fc5 -- scripts tests` (`scripts/enforcement-pack.ps1`: `Read-GitLines`, `Add-GitReadUnreadable`, `Invoke-MicroLaneCheck`, `Invoke-PhaseSizeWarningCheck`; the six `GITREAD-*` fixtures; `tests/enforcement/rules.json`; the five edited `expected.txt`); the spec, plan (D1-D9, Amendment 1), tasks (Phase 1, Amendment 1), notes.md of the feature; the dispatch at `scripts/enforcement-pack.ps1:2305-2320`. Not read: phases 2-5 reads, the full harness (run elsewhere).
**Feature contract**: every unchecked `git` read the pack grades from becomes a named state, not "nothing"; numbered lane fails, Lite lane and advisory checks print one UNGRADED line; healthy repositories byte-identical; no new package; phase 1 Territory is `scripts/enforcement-pack.ps1` and `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5), the session that produced the diff
- **Inputs provided**: phase 1 diff (`48ccb8f..0595fc5`, scripts and tests), spec.md, plan.md, tasks.md, notes.md, definition-of-done and review-process docs, the AI review template; targeted harness runs in a detached worktree at `0595fc5`
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** Phase 1 adds `Read-GitLines` / `Add-GitReadUnreadable` and routes the Micro lane's `rev-list`, `log -1`, `show --numstat` and `PhaseSizeWarning`'s two reads through them. A failed read now returns no lines and a captured exit code, and is named instead of read as zero lines (the reproduced 700-line Micro phase that ended on `OK`). I found no code path where a failed read still reads as nothing, and no behaviour change on a healthy repository. The follow-ups are documentation and test-honesty items (F1-F4), none a defect in the code. Residual risk sits in the reads that only mutation (not fixtures) guards, and in the full-harness run and T007, still open.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | `Read-GitLines` (`enforcement-pack.ps1`, added near line 241): `$lines = @(& git @GitArguments 2>$null)` then `$code = $LASTEXITCODE` in the very next statement; non-zero returns `Lines = @()`, so partial output is discarded; zero returns `$lines` untouched. Micro walk: rev-list failure `return`s after naming (numbered-only function, line 804, so the early return skips only grading that cannot be trusted and a failure is already recorded); log/numstat failures `continue` after naming. `PhaseSizeWarning` uses `-Advisory`, giving one UNGRADED line. `$commit.Substring(0,7)` is only reached with 40-char rev-list output, and PS5.1/7 `foreach` over `$null` (empty `Where-Object`) iterates zero times, as before. |
| Visual-reference match | N/A: no UI. |
| Feature contract held (no unapproved table/migration/permission/package) | `git diff --name-only 48ccb8f..0595fc5` outside `GITREAD-*` fixtures: `scripts/enforcement-pack.ps1`, `tests/enforcement/rules.json`, five `expected.txt`, and the feature's own specs files. Nothing outside Territory; no package. `plan.md`/`tasks.md` appear only because the range starts before amendment commit `d2482e9` (approver recorded in plan.md:200 and the commit message). |
| Constitution / domain invariants | Lite lane never newly failed (014 FR-009): the only Lite-style output is the `-Advisory` UNGRADED arm; verdict stays exit 0 (`GITREAD-002/fail` expects exit 0, "UNGRADED (1 check(s) formed no opinion)"). |
| Security (authn/authz, secrets, sensitive logging) | N/A. git stderr is deliberately not echoed; only exit code and short SHA are printed. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | `git show 18fc556 0595fc5 --stat` read: 22 + 6 files, all in Territory. I did NOT run `scope-check.ps1` (owner/CI verdict). |
| Rollback safety (phase reverts cleanly; schema additive?) | Two commits touching one script and test data; no schema. Reverting both restores the parent byte for byte (rules.json entries and fixtures are additive). |
| Healthy-repo byte identity | `-Case GITREAD-` 74 passed; `-Case DIFF-001` 68, `DIFF-002` 80, `AMEND-005` 66, `AMEND-008` 66, all passed in my detached worktree at `0595fc5`. `GITREAD-001/pass-empty-phase-commit` (exit 0, empty numstat, expected `OK`, no extra line) and both `pass` twins (readable, WARNING / MicroLane failure unchanged) pin the exit-0 path. |
| Fixture truthfulness | Read each `expected.txt`: hand-written, `<SHA>` normalised, outputs match the code's strings. `GITREAD-001/fail` expects exit 1 with one `GitReadUnreadable` plus the advisory UNGRADED line; `fail-two-commits` shares one blob so both commits fail, and expects exactly one of each line (dedupe observed). `GITREAD-002/fail` is a numbered Standard branch, exit 0. |
| Five pre-existing expected.txt edits (0595fc5) | `git diff 18fc556..0595fc5 -- tests`: each is exactly one inserted `UNGRADED: PhaseSizeWarning: git show --numstat of <SHA> could not be read (git exited 128) ...` line, nothing removed. Justified: each of those fixtures damages a subtree, so the same read now fails; exit codes unchanged. All five re-pass. |
| rules.json | `GITREAD-001` (emitAnchor `GitReadUnreadable: `) and `GITREAD-002` (`could not be read (git exited `) are new ids with distinct anchors; the harness's inventory tests passed in the `GITREAD-` run. No siteCount field is used by either entry. |

## Findings

### F1 — GITREAD-002 rule text and fixtures overstate the Lite arm — DOC DRIFT

`rules.json` GITREAD-002 summary says "a read on a Lite branch that fails is named UNGRADED". In phase 1 both callers are numbered-only (`Invoke-MicroLaneCheck` returns at line 804 for a non-`NNN-` branch; `Invoke-PhaseSizeWarningCheck` likewise; dispatch at lines 2305-2320), so the only way into the UNGRADED arm is `-Advisory` on a numbered branch. The non-advisory Lite path of `Add-GitReadUnreadable` has no caller and no fixture yet.
*Action: implementer: reword the GITREAD-002 summary to "an advisory check's read" until a Lite caller exists (phases 2+), or state in notes.md that the non-advisory Lite arm is unexercised in phase 1.*

### F2 — Dedupe key hides a second different failure — ACCEPTED

`$Reader|$Key` collapses every failed `show --numstat` of a reader into one line (the first commit's SHA only), so a second damaged commit, or a different exit code, is not named. Plan D2 and the `fail-two-commits` fixture state this ("once per reader and read"), and the verdict already fails, so no grading is lost; the cost is less diagnostic detail.
*Action: none; deliberate per plan D2.*

### F3 — Fixtures prove reads G1 and G3 only; G2a/G2b/E-guards live in notes.md — MINOR

The rev-list and `log -1` failure branches (and the `-Advisory` rev-list branch) have no fixture; the notes record injected-failure runs (E1-E3) and mutation M2 is admitted uncatchable. This is the owner-approved Amendment 1, but the evidence is prose in notes.md, not reproducible by the harness, so a regression in those branches would pass CI. Also tasks.md T003 still names ids `GITREAD-001/-002/-003` per read while the implementation uses per-site ids (disclosed in notes.md).
*Action: owner: accept as Amendment 1 intends; optionally add a later-phase unit-level guard. Implementer: align tasks.md T003 wording with the per-site ids when next amended (owner-approved amendment, not a self-edit).*

### F4 — T007 still open; full harness not evidenced — CONFIRM

tasks.md T007 is unchecked and notes.md says the wider families and the full harness on the phase commit were pending. The baseline (1704 passed on the parent) is recorded; the after-number is not. The first commit `18fc556` alone left five fixtures red (fixed by `0595fc5`), so the pair, not either commit, is the phase.
*Action: owner: do not merge until the full-harness result on `0595fc5` and the user-run gate exit code are recorded; the implementer must not claim success.*

## Amendments in this diff

- [x] **None** by the phase 1 commits to `spec.md`, `plan.md` or `tasks.md` beyond ticking T001-T006 in tasks.md. Amendment 1 (plan.md and tasks.md) is commit `d2482e9`, before the phase, with `**Amendment approved by**: anas.m, 2026-10-15` in the document and the commit message.

## Constitution re-check (post-implementation)

PASS. The change is within the plan's approved architecture (D1-D3), adds no package, keeps the Lite lane unfailed, and states the numbered-lane failure with a deterministic message. Principle on machine-held checks engaged: a failed measurement no longer converts a hard bound into `OK`.

## Test coverage observed

Six new cases under two rules: `GITREAD-001/{fail, pass, fail-two-commits, pass-empty-phase-commit}`, `GITREAD-002/{fail, pass}`; 74 passed in `-Case GITREAD-` (includes the harness's structural checks), plus the five edited cases re-run green. Critical assertions: the 401-line Micro phase with a truncated blob now exits 1 naming `GitReadUnreadable` (while the readable twin keeps the MicroLane failure); an empty phase commit (exit 0, no rows) stays `OK`; the advisory case exits 0 with one UNGRADED line. I did not run the full harness or the mutations (M1-M8 are recorded in notes.md; I verified by reading that the cases cover M1, M3-M8 as claimed).

## Residual risk

Low in the code. It concentrates in F3 (branches guarded only by recorded mutation or injection, not by a fixture) and F4 (the full-harness result and gate exit code are still owed). Merge after the full harness on `0595fc5` is recorded and the owner accepts F1's wording fix.
