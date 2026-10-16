# AI Code Review — 033 update-kit.ps1 names a recorded kit commit its kit clone does not know (phase 2)

**Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
**Date**: 2026-10-17
**Branches**: agentic-sdlc-kit `033-update-kit-unknown-recorded-commit` (tip `fe9a02d`, phase 2 commit; parent `574b958`)
**Scope reviewed**: `git diff 574b958..fe9a02d` in full (`adoption/updating.md`, `docs/roadmap.md`, `specs/033-update-kit-unknown-recorded-commit/notes.md`, `specs/033-update-kit-unknown-recorded-commit/tasks.md`); `scripts/update-kit.ps1` lines 180-345 as it stands; `tests/enforcement/UpdateKit.Tests.ps1` (run, 10 cases); the 45 scratch result files of the clone measurement (`...\scratchpad\meas33\results\*.txt`), diffed by hand; `spec.md`, `plan.md`, `tasks.md`, the phase 1 review, `docs/sdlc/definition-of-done.md`, `docs/sdlc/review-process.md`, `specs/_templates/ai-code-review-template.md`, and feature 032's flow-down note for the shape. Not read: the full harness (a run is in progress elsewhere, not repeated).
**Feature contract**: Standard lane, two phases; phase 2 is documentation, the roadmap close and the measurement, with Territory `adoption/updating.md`, `docs/roadmap.md`, `docs/digests/**`; no script change; no digest marker added (the adoption digest is at its 40-bullet bound).

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Sonnet 5.5 (claude-sonnet-5-5)
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5), the session that produced the diff under review
- **Inputs provided**: the phase 2 diff `574b958..fe9a02d`; `spec.md`, `plan.md`, `tasks.md` (Phase 2, T006-T009), `ai-code-review-phase1.md`, `notes.md` (read after the diff); `scripts/update-kit.ps1` and `tests/enforcement/UpdateKit.Tests.ps1` as they stand; the scratch measurement results; `docs/sdlc/definition-of-done.md`, `docs/sdlc/review-process.md`, the review template, feature 032's flow-down note
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The phase is documentation and a measurement; the script is untouched (`git diff 574b958 fe9a02d -- scripts` is empty). I diffed the scratch results myself: the known and absent states are byte-identical before and after in all three projects, dry run and `-Json` (12 `cmp` pairs, all equal); the unknown state moves exactly as stated (22 conflicts, `Surgical (20)` where there was none, `surgical` 0 entries to 20, the NOTE on line 3, exit 2, the delivered-once note on the real run, `.kit-version` rewritten to `574b958...`), and the Surgical section of the unknown state equals the absent state's in all three. The roadmap and notes are consistent with the spec, plan and phase 1 review and claim nothing still pending. Nothing is BLOCKING. The follow-ups are all in the flow-down note: its "What to do" advice is wrong after a real run (F1), limit (3) overstates what counts as unknown (F2), the quoted entry text uses a hyphen where the script prints an em dash (F3), and a few measurement caveats are unstated (F4, F5, F6). Residual risk sits in F1: an adopter who follows the advice literally after a real run gets nothing.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FR-007: flow-down note in 032's shape, roadmap close, row `shipped`) | The note at `adoption/updating.md:1482-1499` has the same sections as feature 032's (`What was wrong`, `What it does now`, `What flows down`, `What an owner may newly see`, `What does NOT change`, `Known limits`, `What was measured`, `What to do about it`). `docs/roadmap.md`: GAP-039 `Status (2026-10-17)`, row `shipped` with the unbracketed `specs/033-update-kit-unknown-recorded-commit/`, and a dated 2026-10-17 decisions-log entry. |
| NOTE text and behaviour claims vs the script | The NOTE quoted in the note is character-for-character `update-kit.ps1:310` (ASCII hyphen in `- the verbatim files below`). Surgical entry, exit 2, and the delivered-once note come from `:265-267`, `:309-311` and `:333-335`; the measured real runs show exit 2 and the delivered-once line. The check is `git cat-file -e` (`:192`). `.kit-version` is written at `:276-282` regardless (ratchet). `-Json` keys: `applied, surgical, conflicts, dryRun, result` unchanged (`:288-294`); the NOTE is in the text branch only. |
| "20 files on the three adopted projects", "22 conflicts" | `unknown-now-dry`: `Surgical - upstream changes, never applied (20)` and `Conflicts ... (22)` in FitForge, FlowBoard and ExpenseTracker; `-Json` has 42 `"Path"` rows now (20 surgical + 22 conflicts) against 22 before. The 21 of the spec is the earlier kit commit (notes F4, accepted wording). |
| Byte identity, known and absent | `cmp <p>-<known/absent>-before-<dry/json>.txt <p>-...-now-...` for 3 projects x 2 states x 2 modes: all 12 equal (sizes 2153-7977 bytes). The statement is scoped to dry run and `-Json`, as the note says. |
| Unknown state, before to now | FlowBoard and ExpenseTracker: `diff before now` has 0 removed lines, 42 added (20 surgical rows + the NOTE etc.); `-Json` removes only `"surgical": []`. FitForge shows 23 removed lines, all of them the 22 conflict rows and the header, differing only in encoding (F5). The Surgical section of `unknown-now` equals that of `absent-now` in all three (`diff` empty). Real run: both exit 2, both rewrite `.kit-version` to `574b9589...`. |
| Method statement | `git diff 280be34 574b958 -- scripts/update-kit.ps1` is the phase 1 change alone (16 insertions, 2 deletions), so the two scripts differ only by this feature; both runs take `-Kit` at the same kit content, so the verbatim copy of the script itself does not differ (22 applied in both). The two discarded runs are described in `notes.md` T008 and in the roadmap entry. |
| Roadmap numbers | 1828 on the parent and 1835 on the phase 1 commit: `notes.md` T005 table (the 7 more are the 7 cases `debca9c` shipped). "10 cases of the new test at the tip": notes F1 (10 cases) and my run, `Tests Passed: 10, Failed: 0`. The tip's harness total (1838) is not claimed and not measured, which is right; T009 is open (F7). |
| Does the entry claim anything not yet true | The roadmap entry lists as open: the owner's gate run on phase 2, the human review, the Linux CI run. It does not claim a gate, CI or review result. "Corrected by the work" states who found what correctly: the spec's FitForge measurement vs the plan's small kit (the implementer's own), the `Substring(0,7)` defect (the fresh-context review of phase 1, `ai-code-review-phase1.md` F1, fixed with tests that failed first), the two discarded runs (implementer). |
| Digests and paths | `pwsh -File scripts/build-digests.ps1 -Check`: `digests: OK (5 digest(s) fresh, 119 marker(s))`. `pwsh -File scripts/doc-lint.ps1`: `OK - kit complete, every referenced path resolves`. The note adds no digest marker. Paths named: `scripts/update-kit.ps1` and `adoption/updating.md` are verbatim (both listed among the 22 files of the measurement); the test file stays in the kit (`UpdateKit.Tests.ps1` is under `tests/`, not shipped; `kit-manifest.json` ships no `tests/`); `scripts/ritual-checks.ps1` not cited. |
| Scope guard | `pwsh -File scripts/scope-check.ps1`: `PASS phase 2 commit fe9a02d (4 file(s))`. The 4 files are 2 in Territory and 2 of the feature's own specs. `git diff --stat` read for intent: 18 lines in `updating.md`, 6 in `roadmap.md` (1 status text, 1 row, 1 entry), 28 in `notes.md`, the checkbox and nothing else in `tasks.md`. |
| Tick discipline | `tasks.md` diff: `[ ]` to `[x]` on T006, T007, T008 only; no task text changed; T009 stays `[ ]`. |
| Line endings | `git show fe9a02d:<path> \| tr -cd '\r' \| wc -c` is 0 for all four files (and 0 at `574b958`, so no conversion). |
| Tests | `Invoke-Pester -Path tests/enforcement/UpdateKit.Tests.ps1`: 10 passed, 0 failed. |
| Wrapper-breaking change announced | `What an owner may newly see` names a wrapper that matched `Result: up to date` or read an empty `surgical` array, and says it now sees entries and exit 2. It does not say that `-Json`'s `result` changes from the string `up to date` to an object in that state, which follows from the same condition (F6). |

## Findings

### F1 — "What to do" tells the adopter to re-run for the real list, which an advanced record no longer gives — DOC DRIFT

`adoption/updating.md:1498`: "fetch the kit's full history (`git fetch --unshallow`, or a fresh clone of the same fork) and run it again to get the real list". After a **real** run `.kit-version` already holds the kit's HEAD (`update-kit.ps1:276-282`, the measured real runs rewrite it to `574b958...`), so a second run computes `recorded..HEAD` over an empty range and prints nothing; the list is only obtainable on a dry run, or after restoring the old `.kit-version` (`git checkout -- .kit-version` in the project), or with `git log <old recorded>..<new recorded>` in the full clone. The delivered-once note that the script prints in this very state says `recover it later with: git log 0000000..574b958 in the kit clone` (`:334`), which fails in the shallow or foreign clone the NOTE just said lacks `0000000`. Both texts are accurate for the sibling states and misleading in this one. In addition "a fresh clone of the same fork" does not help the case the NOTE also names, a rewritten history, and "same fork" is ambiguous (the fork that last updated the project, not necessarily the one the adopter holds).
*Action: reword the advice to say: on a dry run, deepen the clone and run again; after a real run, restore `.kit-version` from git (or read the old value from the project's history) and re-run, or run `git log <old recorded>..<new recorded>` in a clone that has both; name "the fork that last updated your project"; and say that a rewritten history needs the clone the project was last updated from. The script's delivered-once line is out of this phase's Territory; mention it as a limit rather than changing it here.*

### F2 — Limit (3) says a short value counts as unknown; a resolvable short value does not — DOC DRIFT

`adoption/updating.md:1494`, limit (3): "a hand-edited `.kit-version` whose `kitCommit` is a tree sha, a short value or not a string counts as unknown". I ran `git cat-file -e "<v>^{commit}"` and `git log <v>..HEAD` on this repository: a 7-character and a 4-character prefix of a commit are accepted by both (known, as `notes.md` T002 records for 9 characters), a branch name is accepted, a tree sha and `123` are not. Only a short value that does not resolve is unknown. As written the limit would send an adopter with a valid abbreviated sha to look for a problem that does not exist, and it contradicts the plan's rule that a value `git log` can read is never called unknown.
*Action: reword to "a tree sha, a value that resolves to no commit, or a non-string"; keep the tree-sha change (previously listed with commits, now unknown) explicit, since it is a behaviour change in a state that otherwise says "unchanged".*

### F3 — The quoted entry text uses a hyphen where the script prints an em dash — MINOR

The note and the roadmap write `no baseline - review all` (like the spec). The script's entry text is `no baseline — review all` with an em dash (`update-kit.ps1:266`, the measured `now` files show it as the em dash); the NOTE and the conflict reason (`differs — no baseline (unknown provenance)`, `:253`) are the same: the NOTE line is ASCII, the entry and the reason are not. A wrapper that greps the documented text will miss the em-dash text. Limit (5) says the wording is not machine-parsed, which covers it in principle.
*Action: either quote the em dash exactly or state once that the dash in the quoted entry text is an em dash; no code change.*

### F4 — "Not exercised" omits the real runs of the known and absent states and the `-Force` path — MINOR

`notes.md` T008 and the note compare known and absent only as dry run and `-Json`; the real runs were captured and compared for the unknown state alone (file list: `*-unknown-{before,now}-real.txt` only). The sentence "byte-identical before and after ... as a dry run and as `-Json`" is correctly scoped, but "Not exercised" lists the small current kit, the shallow clone and Linux, and not the real run of the unchanged states, nor `-Force` with an unknown commit. The test (`UpdateKit.Tests.ps1`) pins the known, absent and malformed states, which is the evidence for them, but it is not stated as the reason.
*Action: add the two items to "Not exercised" in the note and in `notes.md` T008, or cite the test as the evidence for the real runs.*

### F5 — The FitForge unknown-before captures are text-normalised, the other captures are not — MINOR

`fitforge-unknown-before-{dry,real,json}.txt` carry an ASCII hyphen where every other capture (including `fitforge-unknown-now-*`, and both FlowBoard and ExpenseTracker sets) carries the mojibake of the em dash, so a raw `diff before now` for FitForge shows 23 removed lines that are encoding only; the content comparison holds (same 22 rows, same header). "identically in the three" is therefore true after normalisation, which neither the note nor `notes.md` says. The known and absent FitForge pairs are byte-identical raw, so SC-002 is unaffected.
*Action: one sentence in `notes.md` T008 saying how the FitForge unknown-before files were normalised, or re-capture them raw. No change to the conclusion.*

### F6 — `-Json`'s `result` changes type in the old "up to date" state and the note does not say so — MINOR

In the fully silent state (every verbatim file current, no surgical file reported), `-Json` printed `"result": "up to date"`; `$upToDate` now requires an empty surgical report (`:297`), so it prints the object `{kitVersion, kitCommit}`. The note covers a wrapper that read an empty `surgical` array and one that matched `Result: up to date` in text, but not one that compared `result` to the string. The keys are unchanged (FR-004), so "`-Json` keeps its keys" stays true.
*Action: add the `result` string-to-object change to the "What an owner may newly see" paragraph.*

### F7 — The GAP-039 status text and the roadmap entry state no open limit, and the harness total at the tip is not yet measured — MINOR

The status text records no "Open, by decision" (GAP-036 and GAP-037 do): the tree-sha change, the no-surgical-file manifest and the dead recovery hint (F1) are limits. The entry says "1835 on the phase 1 commit (10 cases of the new test at the tip)"; 1835 was measured with 7 cases and the tip's total (1838 expected) is T009's to measure on the isolated checkout, which is open and correctly not ticked.
*Action: none required before the gate; record the tip total under T009 and, if the owner agrees, add the limits to the status text.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly: **none.** The diff to `tasks.md` is three checkbox ticks (T006-T008) and nothing else; `spec.md` and `plan.md` are not in the diff; T009 stays open.

## Constitution re-check (post-implementation)

**PASS.** Specification First (I): no spec or plan amendment. Architecture Consistency (IV): no script touched. Security (VI): no secret read or written; the measurement used clones of local directories, nothing pushed. Testing (VIII): the unchanged and unknown states are pinned by the 10-case test, and the measurement is recorded with its method. Human Review (IX): this file, then human review at merge. Controlled Delivery (X): phase 2 only, T009 and the owner's gate still to come; no `ci-held`. Repository Separation (III), Domain Invariants (V), External Integration (VII): N/A.

## Test coverage observed

`tests/enforcement/UpdateKit.Tests.ps1` (not in this diff): 10 cases, 10 passed on my run: known, equal to HEAD, absent, malformed, unknown as dry run, real run and `-Json -DryRun`, plus the short value, the number and the dry-run-leaves-the-record cases from the phase 1 review. Phase 2 adds no test; its evidence is the clone measurement (12 byte-identical pairs, the unknown state moving as stated in three projects), `doc-lint.ps1` OK and `build-digests.ps1 -Check` OK. The full harness is not run in this review.

## Residual risk

Concentrated in F1: the note, and the script's own delivered-once line, send an adopter in this state to a recovery that does not work after a real run, which is the very situation the feature exists for; fix the note before or at merge (the script line is a candidate for a later fix, stated as a limit). F2, F3 and F6 are wording. F4, F5 and F7 are measurement caveats that do not change a conclusion. Before merge: T009 (the isolated final run), the owner's gate, the CI run on the Linux runner (the second git) and the human review.
