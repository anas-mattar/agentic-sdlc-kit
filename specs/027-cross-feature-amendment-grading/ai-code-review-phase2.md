# AI Code Review — 027 Cross-feature Amendment Grading, Phase 2 (the Lite lane)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-15
**Branches**: agentic-sdlc-kit `027-cross-feature-amendment-grading` (tip `8c52853`, reviewed as `git diff 4982b51 8c52853`)
**Scope reviewed**: `scripts/enforcement-pack.ps1` (entry `Invoke-AmendmentAuthorityCheck`, `Invoke-AmendmentAuthorityCore`, `Get-OtherFeatureNote`, the dispatch arms, `Get-ChangedFiles`, `Get-DiffBase`); `tests/enforcement/lib/FixtureRepo.psm1` and `Harness.Tests.ps1` (`shallowAllBranches` and its two self-tests); `tests/enforcement/rules.json` hunks; the new case directories (command.json, expected.txt, spot-read recipes for AMEND-009 and AMEND-001 Lite); the Phase 2 section of `notes.md`; spec.md US2/FR-003/FR-008/FR-009/FR-011 and plan.md D6-D9. Phase 1 reviews were not read.
**Feature contract**: the numbered lane is unchanged; a Lite branch that touches no spec document prints what it printed before (FR-009); a Lite branch is never newly failed on a condition the machine cannot compute (D8, 014 FR-009); no new package.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: the agent session that produced commit 8c52853 (a different session; not this reviewer)
- **Inputs provided**: the phase 2 diff (`git diff 4982b51 8c52853`), spec.md, plan.md, tasks.md Phase 2, notes.md, docs/sdlc/review-process.md, specs/_templates/ai-code-review-template.md
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The Lite arm does what D6, D7 and D8 say on every shape I could build: it is silent when no spec document is in the diff (including no base and a shallow clone), grades the same documents by the same rules when one is, never fails a Lite branch on a refusal, and leaves the numbered lane alone. The one-site conversion is sound and fails closed, not open; I found no path by which an amendment failure becomes UNGRADED. Residual issues are small: a pure-creation Lite branch in a shallow clone now prints UNGRADED where it printed OK (a literal FR-009 deviation, exit code unchanged), the gate reads the net diff so an amend-then-revert is silent, and the prefix coupling and the Lite-merge shape have no guard. Nothing blocks merge.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| D6 gate | Built throwaway repos outside the tree and ran the script with `-Root`/`-Branch`. A docs/ branch touching only README prints the old line and OK; a baseless Lite branch (no `main`) amending 001-a/plan.md is silent from this check and only the dispatch warning and ReviewProvenance UNGRADED print (the gate sees an empty list, as D6 states). A shallow clone with a base and no spec change is silent (fixture `pass-lite-docs-readme-only-shallow`). Roll-up is printed only on a touch of a base-existing document: create-then-amend of an unbased 009-z on fix/ prints just OK. |
| D7 | `-ReplayBase HEAD -ReplayTip HEAD` on a Lite branch whose diff touches a spec: silent, OK (line 1956 `if ($Lite) { return }`). Numbered lane still names it UNGRADED (unchanged line). |
| D8 / conversion | Enumerated all nine `$script:failures +=` in the core (lines 1925, 1929, 1965, 2001, 2004, 2017, 2045 refusals; 2108, 2124 amendment grades). Refusals start `AmendmentAuthority: cannot grade ` (6 incl. `$baseUnreadable`, line 1943) or `AmendmentAuthority: could not parse commit metadata `; the two grades start `AmendmentAuthority: commit `. The regex `^AmendmentAuthority: (cannot grade|could not parse commit metadata) ` therefore moves exactly the refusals. Core `return`s all follow a failure append, so a return never drops a recorded failure. `$failuresBefore` protects earlier LiteAndAbuse failures. Reproduced: real depth-2 `--no-single-branch` clone, docs/x amending 001-a/plan.md: `UNGRADED: ... shallow clone`, exit 0. Merge hand-merge on a Lite branch (record absent): two failures, exit 1 (graded, kept). |
| FR-009 numbered lane | The numbered dispatch call is unchanged; `$dir` is `specs/$Branch` for numbered; `Get-OtherFeatureNote` new arm only when `-not $Dir`. Status-only edit gives the same failure on 002-x and docs/x (parity). |
| Neighbours | docs/002-b: not matched by `^\d{3}-`, graded as Lite, no `specs/docs/002-b` path is formed (`$dir=''`). Non-ASCII `specs/005-é/plan.md` amended on docs/x: graded, fails correctly (second read uses `core.quotepath=off`). Rename of specs/001-a/plan.md to archive/plan.md: graded as an amendment, exit 1 (gate's rename-blind read works). Merge of main into a Lite branch where main changed 001-a and the branch touched README only: silent OK (net diff vs new merge base). |
| Harness | `Run-Tests.ps1 -Case lite`: 105 passed; `-Case AMEND-009`: 69 passed, 0 failed. Working tree untouched. |
| Territory | Changed files outside tests/** and the script: only `notes.md` (allowed). |
| Scope guard | Not run by me (the AI review is not the gate); `git diff --stat` read: 62 files, all in territory. |

## Findings

### F1 — A pure-creation Lite branch in a shallow clone with a base now prints UNGRADED, where it printed OK — CONFIRM

D6's gate is "the diff touches a graded path", and a created document is a graded path. So a docs/claim-* branch that only creates `specs/009-z/spec.md`, in a depth-N clone that still has `origin/main`, passes the gate, the core refuses on the shallow check, and the conversion emits UNGRADED. Reproduced (`s13c`: depth-2 clone, `docs/claim-9` creating a new feature directory): output was `UNGRADED: AmendmentAuthority: cannot grade ... shallow clone`, `enforcement-pack: UNGRADED (1 check(s) formed no opinion)`, exit 0; the parent printed OK. In an unshallow checkout the same branch prints only OK (fixture `pass-lite-docs-claim-creation`). FR-009 says output is byte-identical when no commit changes a spec document; here a creation was made and the output changes, which is arguably the spec's wording, but the roll-up rule (a creation prints nothing) suggests the intent was silence. The exit code is unchanged, so no Lite branch fails newly.
*Action: owner decides whether a gate that finds only creations (no path existing at the base) should stay silent in a refusal state too; if yes, the gate would need an existence test at the base, and a fixture pair (shallow+creation-only) should be added. Otherwise state the behaviour in the plan.*

### F2 — The gate reads the net diff, so amend-then-revert and a replay over a range the net diff does not hold are silent — MINOR

D6 says "when its diff touches a spec document". Reproduced: docs/x commits an unapproved edit of 001-a/plan.md, then `git revert`s it; `git diff main HEAD` is empty, the gate is silent and OK is printed. The numbered lane would grade commit 1. Same for `-ReplayBase/-ReplayTip` on a Lite branch: the gate reads Base..HEAD, not the replay range, so a replay of an older range whose net diff is empty measures nothing. This is the net-versus-commit gap the spec's FR-009 wording ("commits change no spec document") leaves open; the effect is low (the final tree is unchanged) but a replay measurement (FR-010) on Lite branches would under-count.
*Action: record the limit in the LIMITS comment and plan D6 (it states the GAP-034 limit only), or gate on `git log --name-only` over the range; no code change required for merge.*

### F3 — The conversion is correct today but is coupled to the text of the failure messages; the coupling is unguarded — MINOR

Fail-closed direction: a new refusal whose text does not begin with the two prefixes would stay a failure on a Lite branch (violating D8) rather than becoming UNGRADED; there is no fixture or comment at the emission sites that says so. Fail-open direction: none found, because the two grading messages start `AmendmentAuthority: commit`. Three of the seven refusal sites are not reachable on a Lite fixture: the no-base site (1929) is dead on Lite because a null base makes the gate silent, and the merge-unreadable (2004), base-tree (2001, 2045) and metadata (1965) sites have no Lite fixture (the notes say so for the last three; the plan D8's "a fail-direction fixture per condition that applies" is met for two). The mutations M12/M16 exercise the whole conversion, not per prefix, so dropping `could not parse commit metadata` from the regex is unmutated.
*Action: add a one-line comment at the numbered `failures +=` sites naming the prefix contract (or a harness check that every non-grade failure of the core matches the regex); optional.*

### F4 — No Lite fixture contains a merge commit; the `touchedApproved` merge site is unguarded — MINOR

`if (@($mp.Paths).Count -gt 0) { $touchedApproved = $true }` is in no mutation and no case reaches it: M13 only tests the unconditional print. A Lite branch whose only touch of an existing document is a merge that authored a conforming record would lose its roll-up line if this site were removed (a hand-merged amendment without a record still fails through the row path; I reproduced the failing case, not the passing one).
*Action: add one Lite merge pair (hand-merged conflict with and without record) or mutate the site; optional.*

### F5 — Small accuracy items — MINOR

(a) `tests/enforcement/Harness.Tests.ps1:474`: a literal `\n` sits inside a `#` comment line (the comment "main\n    # has three commits" is one physical line); harmless, untidy. (b) `AMEND-009/pass` is the numbered twin and exits 1, so a "pass" directory holds a failing exit; disclosed in notes (coverage requires the names) and in the rules.json notes. (c) After a UNGRADED conversion the docs/ line still reads "review-provenance is the only scripted check that applies", which is true (the roll-up did not print). (d) rules.json AMEND-009 note names the shallow and unreadable-parent states as reachable and the rest as unreached; that is accurate against what I ran, and its emitAnchor (`$script:ungraded += $f`) is the real site. AMEND-001, AMEND-006, PACK-004 and LITE-001 note text matches behaviour observed.
*Action: tidy (a) at the owner's convenience; otherwise none.*

## Amendments in this diff

**None.** No change to the feature's own spec.md, plan.md, tasks.md or contracts/ (notes.md only). The one-site conversion departs from D8's wording ("one `ungraded` per condition"); notes.md Decision 1 discloses it and states that a plan amendment is for the owner. The behaviour, not the mechanism, matches D8.

- [x] Amendments listed, or **none** stated explicitly

## Constitution re-check (post-implementation)

PASS. I (no self-approval): not engaged by this diff. II/X (Lite lane stays a lane): the Lite lane gains a grade only where it touches approved documents. 014 FR-009 holds: no Lite branch newly fails on an uncomputable condition (shown, shallow and unreadable parent). The departure from D8's emission-site wording is flagged for the owner, not hidden.

## Test coverage observed

Fixtures (19): AMEND-001 Lite variants differ in one condition from their twins (record absent/present, fix vs chore vs docs, creation-only, moved off specs, readme-only with and without shallow), AMEND-006 empty range, AMEND-009 four (shallow fail/numbered-twin pass, unreadable parent). The expected.txt files I read match what the script prints and are hand-shaped (placeholders `<SHA>`). `shallowAllBranches` is correct (`--no-single-branch`, the field read only when present) and its two self-tests assert both halves (no `origin/main` without it; with it, `origin/main` resolves and the clone stays shallow). Directory names satisfy coverage (the harness passed). Mutations M11-M18 in notes.md: plausible and consistent with what fixtures I ran catch (M11 would silence readme-only-shallow; M14 the moved-off fixture; M17/M18 the docs/ line and empty range); the "call the check on main" mutation is correctly declared degenerate. Unmutated: the merge `touchedApproved` site and per-prefix coverage of the regex (F3, F4).

## Residual risk

Concentrated in the Lite lane's gate semantics (F1, F2): where "touches a spec document" is read against the net diff and where a creation alone triggers a refusal state. Neither can newly fail a Lite branch. The conversion's text coupling (F3) is a maintenance risk, not a current defect. Throwaway repos were created under the scratchpad's `rv` folder and nothing was placed under `scripts/`.

### Implementer dispositions (appended; the reviewer's text above is unedited)

| Finding | Disposition |
|---|---|
| F1 | **Accepted as a limit by the owner.** Stated in the LIMITS comment of `scripts/enforcement-pack.ps1` and in `notes.md`; no code change. |
| F2 | **Recorded as a limit** in the LIMITS comment and `notes.md`. |
| F3 | **Fixed.** A guard in `Coverage.Tests.ps1` holds every refusal text of the core to the conversion pattern and every grading failure out of it (mutations M20, M21 fail it); two `AMEND-009` fixtures added (unreadable merge parent, and its twin showing a real failure kept beside the refusal). |
| F4 | **Fixed.** Lite merge pair added under `AMEND-001`; mutation M19 fails exactly its two fixtures. |
| F5 | **Fixed.** The stray `\n` in the `Harness.Tests.ps1` comment removed. `AMEND-009/pass` stays the numbered twin, disclosed in `notes.md`. |
