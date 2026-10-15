# AI Code Review — 028 Unreadable Diff Named State, Phase 2 (review-provenance and the Lite amendment gate)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-15
**Branches**: agentic-sdlc-kit `028-unreadable-diff-named-state` (code commit `89bb651`, reviewed as `git diff 088dd0d 89bb651`; `088dd0d` is phase 1's tip, certified by the owner's gate)
**Scope reviewed**: `scripts/enforcement-pack.ps1` (`Invoke-ReviewProvenanceCheck`, the Lite arm of `Invoke-AmendmentAuthorityCheck`, the LIMITS comment, the dispatch and the docs/ lane line, `Read-DiffLines`, `Add-DiffUnreadable`, `Get-ChangedFiles`); the new fixture `DIFF-002/fail-docs` and the three edited expectations (`DIFF-002/fail`, `fail-chore`, `fail-blob-rename-detection`); `tests/enforcement/rules.json` (unchanged by this commit); spec.md, plan.md D3-D5 and D9, tasks.md Phase 2 (T007-T012), notes.md (phase 1 sections; the phase 2 section is not written yet), the phase 1 review and its dispositions, the 027 phase 2 review (format).
**Feature contract**: a readable, empty, base-less, shallow or trunk input is byte-identical to the parent; the numbered lane fails once per run; a Lite branch is never newly failed on a condition it cannot compute (014 FR-009); no new package.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: the agent session that produced commit 89bb651 (a different session; not this reviewer)
- **Inputs provided**: the phase 2 diff (`git diff 088dd0d 89bb651`), CLAUDE.md, docs/sdlc/review-process.md, specs/_templates/ai-code-review-template.md, spec.md, plan.md, tasks.md, notes.md, the phase 1 review, the 027 phase 2 review (format)
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The behaviour matches plan D4 and D5 on every shape I could build. A readable diff produces the same output as the phase 1 script (a differential run over 36 repositories, below), both Lite reads and the review-provenance read enter the named state, the numbered once-only flag works, the four new or changed expectations are right and fail on the phase 1 script, and no pre-existing case regresses. Three things stop it being a clean approve, none a code defect: (1) T009 (the `rules.json` notes) was not done, so the `DIFF-002` note now states the opposite of the code ("the docs/ lane is NOT yet named in phase 1 ... phase 2 adds ..."); (2) two of the T008 fixtures are missing (a numbered branch with a truncated subtree and a review file added on it; a readable docs/ branch with a review file lacking provenance as a control), and the T008 exemption for the unreachable "second read fails alone" state is not yet in notes.md; (3) the author's mutation expectation is wrong for M12: it IS caught, by `fail-blob-rename-detection`. M10 and M11 are equivalent mutants in every reachable data state (my analysis below), so their exemption is sound, but it should be recorded as an equivalence, not as "the two reads fail together".

## What was verified (evidence)

Harness runs, all from my own detached worktree at `89bb651` (NOT the full harness): `-Case DIFF-` 82 passed / 0 failed; `-Case LITE-` 118 / 0; `-Case AMEND-` 272 / 0; `-Case GAP27` 78 / 0; `-Case PACK-` 78 / 0; `-Case CRIT-` 228 / 0. A second worktree at `89bb651` with the phase 1 script (`git show 088dd0d:scripts/enforcement-pack.ps1`) over `-Case DIFF-`: 78 passed / 4 failed.

| Area | Evidence |
|---|---|
| Readable-diff equivalence (D5, FR-007) | Built 36 throwaway repositories (4 branch names `docs/x`, `fix/x`, `chore/x`, `002-b` by 9 scenarios: a review file added without provenance, added with valid provenance, a grandfathered review renamed into place, a non-ASCII feature directory `specs/001-é/`, an unrelated change only, an empty commit, two review files plus a spec (several rows), a spec document moved off `specs/`, a spec edit). Ran the phase 1 script and the phase 2 script with `-Root`/`-Branch` over each, compared stdout plus exit code: **36 of 36 identical**. That includes the one-row case (PowerShell's unrolling of a one-element `Lines`), the AR rename target, quotepath, and empty output. |
| Review-provenance named state (D5) | `Read-DiffLines` is called with the identical arguments the bare `git` call used; on a failed read the check calls `Add-DiffUnreadable -Reader 'ReviewProvenance'` and returns before the candidate loop, so no partial list is ever walked. `fail`, `fail-chore`, `fail-blob-rename-detection` and `fail-docs` each now carry the `UNGRADED: ReviewProvenance:` line. |
| Lite gate (D4) | Both reads enter the state: the dispatch's (via `$script:ChangedFilesRead`) and the second `--no-renames` read. The check returns before the core. A readable diff takes the same path as before: a moved spec document is seen (my `specmove` scenario, plus the AMEND-001/LITE cases, all green), a branch touching no spec document is silent, no base is silent (the `elseif ($Base)` leaves `$gateExit` null), shallow-clone fixtures are green (`-Case GAP27`, `-Case AMEND-` at 272). |
| Numbered lane, one line per run | In `DIFF-001/fail` the dispatch reports first; review-provenance then also fails to read and the flag suppresses its line. Dropping the flag (M4) adds a second `DiffUnreadable` line: caught (below). The numbered lane's amendment check does not use the new gate arm, so the flag is exercised by the dispatch plus review-provenance only. |
| A second reader failing alone | Not reachable. Dispatch `--name-only` and review-provenance `--name-status --diff-filter=AR` both run rename detection, so they read the same trees and blobs. The Lite gate's second read (`--no-renames`) reads a strict subset of what the dispatch read reads. Probed by hand with a truncated blob that rename detection must pair (`deps.json` moved to `specs-x.json` with a line added, `specs/001-a/spec.md` added): `diff --name-only` and `--name-status --diff-filter=AR` exit 128, the `--no-renames` forms exit 0 and list the files. I found no state in which a `--no-renames` read fails while the rename-detecting read succeeds. |
| AMEND-008 interplay | `AMEND-008/fail` (numbered, unreadable merge tree) is unchanged by phase 2 and passes (`-Case AMEND-`: 272 / 0). The dispatch's `DiffUnreadable` line precedes the amendment refusal as the phase 1 disposition decided; review-provenance adds nothing (flag). |
| docs/ lane | `fail-docs` as hand-written: count line, the lane line, two UNGRADED lines in `ReviewProvenance` then `AmendmentAuthority` order, verdict `UNGRADED (2 check(s) formed no opinion)`, exit 0. Order is right: dispatch order (review-provenance first), UNGRADED lines print after the lane line and before the verdict. `AmendRollupPrinted` is only set at the roll-up print, after the core, so an early return from the gate leaves it false and the lane line takes the "only scripted check" wording (F4). |
| Fixtures vs the phase 1 script | The 4 failures on the phase 1 script are the new `fail-docs` and the three edited expectations, as claimed; the controls (`pass`, `pass-lite-readable`, `pass-docs-readable`, `pass-lite-empty-diff`, `DIFF-001/*`) pass on both. Every other case in the six subsets is unchanged. |
| Mutations (my worktree, mutated copy restored from a pristine one each time) | See the table below. |
| Territory and strict rules | The commit changes 1 script and 6 files under `tests/**`; spec.md, plan.md, tasks.md and notes.md are untouched (T007-T012 unticked, phase 2 notes not written, as the brief says). No package, no unrelated file. One phase. |
| rules.json | Not modified by the commit (F1). `-Case DIFF-` includes the inventory tests and they pass, because the emission anchors are unchanged and the notes are free text. |

### Mutations (M4, M9, M10, M11, M12)

Each applied to a copy of the `89bb651` script, run over `-Case DIFF-`, `-Case AMEND-008` and `-Case LITE-` (which also selects the DIFF-002 Lite names).

| Mutation | Result | Caught by |
|---|---|---|
| M4: drop the numbered once-only flag | **caught** | `-Case DIFF-`: 2 failed (the numbered cases, where review-provenance is the second reader); `AMEND-008/fail`: 1 failed. `-Case LITE-`: 118 passed (no numbered name matches). |
| M9: review-provenance `if (-not $read.Ok)` made `if ($false)` | **caught** | `-Case DIFF-`: 4 failed (`fail`, `fail-chore`, `fail-blob-rename-detection`, `fail-docs`: each loses its `ReviewProvenance` UNGRADED line). Numbered cases do not see it (the dispatch already reported). |
| M10: drop `else { $gateExit = $second.Exit }` | **not caught** (DIFF- 82/0, AMEND-008 66/0, LITE- 118/0) | An equivalent mutant in every reachable state: the second read cannot fail unless the dispatch read failed first, and the first-read test enters the state before the second read runs. See F2. |
| M11: drop the `return` after the gate's `Add-DiffUnreadable` | **not caught** (all green) | Equivalent in every reachable state: with the first read failed the gate list is empty (silent anyway); with only the second failed (unreachable) the first list could hold a spec document and the core would run on a branch already named. See F2. |
| M12: drop the first-read test `if (-not $script:ChangedFilesRead.Ok) {...}` | **caught** (the author expected it not to be) | `-Case DIFF-`: 1 failed, `DIFF-002/fail-blob-rename-detection` (confirmed by running that case alone: the `UNGRADED: AmendmentAuthority:` line is missing). In that shape the dispatch read (rename detection) fails while the gate's `--no-renames` read succeeds, finds no spec document, and returns silently. Tree-damage fixtures do not catch it (both reads fail). `-Case LITE-`: 118 passed, because the case matches are by name. |

## Findings

### F1 — `rules.json` notes for `DIFF-001` and `DIFF-002` are stale and now contradict the code (T009 not done) — MINOR

`tests/enforcement/rules.json` is not in the diff. The `DIFF-002` note still says "Phase 1 reaches it for LiteAndAbuse (fix/ and chore/); phase 2 adds review-provenance and the Lite amendment gate" and "the docs/ lane is NOT yet named in phase 1 ... a docs/ branch ... prints the named count line and then OK, a stated intermediate state that phase 2's docs/ fixture flips". After `89bb651` that is false: `fail-docs` pins the opposite. The `DIFF-001` note describes "a second reader" in the abstract and does not name review-provenance, nor that it is the second reader that the flag actually serves in the fixtures. Tasks T009 says to update both notes and to run the recall sweep first. Also `fail-docs` and the new emission readers (three callers of the same two sites) are not named anywhere in the inventory.
*Suggested fix*: rewrite the two notes (phase 2 delivered, `fail-docs` is the docs/ case, the three readers, the flag serves review-provenance on numbered); run the recall sweep; keep the `emitAnchor` values (the sites did not move).

### F2 — The M10/M11 exemption is real, but it is an equivalent-mutant argument, not "the reads fail together"; no fixture is missing for it, and the missing-fixture question for M12 is already answered — MINOR (record)

The author expected M10 and M12 uncaught because "the gate's two reads fail together". That is true for tree damage and is why M10 is equivalent, but M12 is not: the blob-rename shape makes exactly the dispatch read fail (rename detection) while the gate's `--no-renames` read succeeds, and `fail-blob-rename-detection` catches M12 by its `AmendmentAuthority` UNGRADED line. The converse state (the second read fails while the first succeeds) is not constructible: `--no-renames` never reads more than the rename-detecting dispatch read. Hence M10 and M11 cannot be observed by any data state, and no fixture is missing. The risk in the code, not the fixtures, is that M10/M11 guard a branch that is dead today and will stay dead until someone changes the dispatch read (for example to `--no-renames`), at which point both become live and unguarded.
*Suggested fix*: record in notes.md (T008's exemption sentence) that M10 and M11 are equivalent mutants and why, and that M12 is caught by `fail-blob-rename-detection`; optionally add a one-line comment at the second read saying it cannot fail alone while the first read has rename detection.

### F3 — Two T008 fixtures are not in the commit — MINOR

T008 lists: (a) a numbered branch with a truncated subtree and a review file added on it, to show the failure is reported once by the dispatch and review-provenance adds nothing; (b) the readable control, a docs/ branch with a review file lacking provenance, byte-identical. Neither exists. Coverage of the numbered flag comes only from `DIFF-001/fail` (no review file on it), where review-provenance still executes and fails to read, so M4 is caught, but the "a review file added on the damaged branch" shape is not held. For (b), my 36-repository differential covers the same ground (all identical), and existing PROV-* cases cover a readable review file, but the docs/ lane with a provenance-less review file has no case that would flip if the read were moved wrongly.
*Suggested fix*: add the two cases or say in notes.md why they were dropped.

### F4 — On `docs/`, the lane line says "review-provenance is the only scripted check that applies" while review-provenance itself printed UNGRADED — INFO

The line is printed before the UNGRADED lines, and `AmendRollupPrinted` is correctly false when the gate returns early (it is only set at the roll-up). The line reads as true under its own wording ("applies", not "graded"), and the next two lines say what graded nothing, so it does not claim more than ran. It does leave a reader holding "applies" on a check that formed no opinion. Not a defect; spec US1 AS2 is met because the verdict line and both UNGRADED lines carry the truth.
*Suggested fix*: none required; optionally "review-provenance is the only scripted check that applies (see UNGRADED below)" is not worth a fixture churn.

### F5 — `Invoke-AmendmentAuthorityCheck` fails open (silently skips the second read) if `$script:ChangedFilesRead` is unset — INFO

`$script:ChangedFilesRead.Ok` on an unset variable is `$null` (the script sets no strict mode), so `-not $null.Ok` is true, `$gateExit` takes `$null.Exit` which is `$null`, the second read is skipped, and nothing is named: the gate falls back to `$ChangedFiles` alone, losing the rename-blind read. Unreachable today: the dispatch always calls `Get-ChangedFiles` before any check, and nothing else calls the function.
*Suggested fix*: initialise `$script:ChangedFilesRead = @{ Ok = $true; Exit = 0 }` next to `$script:DiffFailureReported`, or test `$script:ChangedFilesRead.Ok -eq $false`.

### F6 — The LIMITS comment is accurate after the edit — INFO

It says a Lite branch with no base says nothing for want of a gate (true: the dispatch warning and other members' UNGRADED lines name it), that a failed read of either gate list prints an UNGRADED line for this check and returns (true), and it keeps the net-diff and shallow-creation limits. The comment block is long and one clause ("the gate list is read a second time without rename detection ...") now sits after a sentence about the named state; readable, not wrong.
*Suggested fix*: none.

## Amendments in this diff

**None.** spec.md, plan.md and tasks.md are unchanged (tasks.md ticks for T007-T012 are pending and are not an amendment).

- [x] Amendments listed, or **none** stated explicitly

## Constitution re-check (post-implementation)

PASS on I (no self-approval engaged), II/X (no Lite branch newly fails: the new lines are UNGRADED, exit 0; the numbered lane keeps its single failure), IV (no new script or package). One phase; territory respected.

## Test coverage observed

Held: Lite unreadable via tree damage (`fail`, `fail-chore`), via blob damage (`fail-blob-rename-detection`), docs/ (`fail-docs`), the numbered twin and its once-only line (`DIFF-001/fail`, `DIFF-002/pass`), readable and empty controls. Not held: a numbered branch with a review file on the damaged diff (F3), a docs/ readable review-file control (F3), the dead-today second-read branch (F2), a trunk branch under damage (phase 1 F4).

## Residual risk

The dead second-read branch (M10, M11) and the unset-variable path (F5) are dormant, not live. The numbered flag is guarded only through review-provenance as the second reader; if that reader were reordered the flag would be unobserved by the DIFF- fixtures alone (AMEND-008/fail also catches M4, so there is a second guard). I did not run the full harness (the author's run is in progress elsewhere), the Linux job, or `ritual-checks.ps1`. Throwaway repositories and worktrees (four at `89bb651`/`088dd0d` under the scratchpad `review2` folder) were removed afterwards.

### Implementer dispositions (appended; the reviewer's text above is unedited)

| Finding | Disposition |
|---|---|
| F1 | **Fixed.** The `DIFF-001` and `DIFF-002` notes in `rules.json` are rewritten for phases 1 and 2 (the three readers, the docs/ lane named, what each fixture guards, and what no fixture can: a partial list, the gate's second read or review-provenance's read failing alone). The recall sweep passes. |
| F2 | **Fixed.** `notes.md` labels M10 and M11 equivalent mutants with the reason and records that M12 is caught by `fail-blob-rename-detection` (the one state in which only the first read fails). A comment at the gate's second read in the script says it cannot fail alone and that both branches become live and unguarded if the dispatch read changes. |
| F3 | **Fixed.** `DIFF-001/fail-with-review-file` and `DIFF-002/pass-docs-readable-review` are added. Both match the phase 1 script by design (controls); the first flips under M4, the second under any change that stops review-provenance grading a readable diff. |
| F4 | **Accepted** (information): the docs/ lane line names the checks that apply, the UNGRADED lines carry what graded nothing; recorded in `notes.md`. |
| F5 | **Fixed.** `$script:ChangedFilesRead` is initialised to `Ok` beside `$script:DiffFailureReported`. |
| F6 | Information; no change. |
