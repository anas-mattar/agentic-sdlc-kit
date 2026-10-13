# AI Code Review — 025 Critical merge-ready signal, phase 1 (round 2)

**Reviewer**: fresh-context agent, Claude Opus 5.5 (claude-opus-5-5)
**Date**: 2026-10-14
**Branches**: kit repository `025-critical-merge-ready-signal`. Phase 1 commit `003c96a`, then `1c876e5` (notes), `ad6e64c` (review remediation) and `9e9c8f9` (plan/tasks amendment, F4). Branch tip at review start: `9e9c8f9`.
**Scope reviewed**:
- The remediation diffs, read in full: `git show ad6e64c` and `git show 9e9c8f9`.
- `specs/025-critical-merge-ready-signal/`: `notes.md` (all of it, including "Phase 1 review remediation"), `plan.md` (all of it), `tasks.md` (T001-T005), `spec.md` (US2, FR-001 to FR-009, Assumptions), and the round-1 review `ai-code-review-phase-1.md`.
- `scripts/enforcement-pack.ps1` lines 320-390 (the header comment with the new LIMIT, `Get-CriticalMergeReadiness`) and lines 445-470 (`Invoke-CriticalEvidenceCheck`, both emission sites). Lines 650-710 (the Gate Batching and Gate Certification readers), for comparison.
- `tests/enforcement/rules.json`: CRIT-R01, CRIT-R02 and CRIT-R03.
- The four new cases (recipe, command and expected for each, each recipe diffed against its twin) and the five modified `expected.txt` files.
- `tests/enforcement/lib/FixtureRepo.psm1` lines 56-58 and 201-206.
- Constitution I, Amendment authority (`.specify/memory/constitution.md` lines 230-255).

Not read: phase 2 territory. The full harness was not run, per instructions.
**Feature contract**: option A. A Critical `plan.md` may declare `**Merge Readiness**: pending | ready`, read from the committed blob at `HEAD`. `pending` overrides feature 024's heuristic toward the WARN, but never past a committed artifact. `ready` hands over to the arm. A malformed value, now including an empty one (plan D1 as amended), is strict with a reason. An absent marker is feature 024 byte for byte. The arms and `Invoke-AmendmentAuthorityCheck` are unedited. No new script, library, package or recipe field.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5) session
- **Inputs provided**:
  - `git show ad6e64c` and `git show 9e9c8f9`; phase 1 commit `003c96a`.
  - The round-1 review `specs/025-critical-merge-ready-signal/ai-code-review-phase-1.md` (findings F1-F8).
  - `specs/025-critical-merge-ready-signal/{notes.md ("Phase 1 review remediation"), plan.md, tasks.md}`.
  - `scripts/enforcement-pack.ps1` (Get-CriticalMergeReadiness, Invoke-CriticalEvidenceCheck, the LIMIT comment).
  - `tests/enforcement/rules.json` (CRIT-R01, CRIT-R02, CRIT-R03).
  - The new fixture cases: CRIT-R03/{fail-marker-in-multiline-comment-is-absent, pass-trailing-comment-is-stripped, fail-marker-in-code-span-is-absent} and CRIT-R02/fail-marker-case-variant.
  - `specs/_templates/ai-code-review-template.md`.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The code side of round 1 is closed, and I reproduced every claim:

- **F2 and F3 (fixtures that measure nothing).** All three mutations fail exactly the new fixtures the notes name, and nothing else.
- **F1 (merge-commit gap).** The warning no longer claims "a recorded plan amendment". The merge-commit limit is recorded in the script header.
- **F4 (empty value).** `plan.md` D1 and `tasks.md` T004 now agree with the code. The amendment records conform, and AmendmentAuthority grades all 9 branch commits OK.
- **Regressions.** None: `-Case CRIT-` gives 208 of 208, `-Case merge-readiness` 48 of 48, `ritual-checks.ps1` RESULT OK, and `scope-check` PASS on `003c96a`, `1c876e5` and `ad6e64c`.

The follow-ups are about documents. Route 2 was the owner's decision, but it is recorded only as a quoted phrase in `notes.md` and a script comment. The approved plan still states the pre-remediation position in four places, the warning text in D3 among them, and the spec's FR-006 still says "extend it". A reader of the plan sees no statement of the residual risk (F9). That is acceptable for closing phase 1's code review. It is not acceptable for merge, and it should land before phase 2 starts, because phase 2 writes the guidance and the flow-down note from this plan. `notes.md` is also stale in several small places (F10). Residual risk sits where the owner accepted it: a `pending` introduced in a merge commit is ungraded, and gate 6 stands behind it.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | **FR-001**:<br>- Line 371 is the anchor `^\*\*Merge Readiness\*\*:\s*(.*?)\s*$`, applied to `Get-VisibleFromText` output (line 365).<br>- Code spans are hidden by the line-start anchor, not by the reader. Under mutation 3 the code-span case read the value `` pending` ``, so `Get-VisibleFromText` keeps code-span text.<br>- `switch -CaseSensitive` is at line 379.<br><br>**FR-004 (empty value)**: the `''` arm at line 382 matches D1 as amended (plan line 63) and T004 as amended (tasks line 64).<br><br>**FR-006**: still not extended to merge commits. I re-ran the evil merge on the tip's script (kept fixture of `CRIT-R03/fail`, `ready`, strict). `git merge --no-ff --no-commit main` followed by `ready`→`pending` in `plan.md`, committed as `merge main`, gave `AmendmentAuthority: graded 0 of 4 ... (4 not graded: 1 merge commit(s); ...)`, the new WARN text and `enforcement-pack: OK`, exit 0. The first parent alone gives `FAIL ... human-pr-review.md is missing`, exit 1. The behaviour is unchanged, as route 2 intends. The warning text is now true, and the LIMIT is at lines 341-343. See F9 for the documents. |
| Visual-reference match | N/A: no UI. |
| Feature contract held | `git show ad6e64c -- scripts/` changes 3 comment lines (LIMIT) and the two warning strings (lines 458 and 460) only. The arms, the function signature, `Invoke-AmendmentAuthorityCheck` and `FixtureRepo.psm1` are untouched (not in either commit's `--stat`). |
| Constitution / domain invariants | See the re-check below. 9e9c8f9's amendment records conform to I in form. |
| Security | No new read and no new output beyond the reworded warning. The security-relevant surface is the accepted merge-commit gap (F1, F9). |
| Scope guard | `pwsh -File scripts/ritual-checks.ps1` on the working repo gave:<br>- `scope-check: PASS phase 1 commit 003c96a (54 file(s))`<br>- `PASS ... 1c876e5 (1 file(s))`<br>- `PASS ... ad6e64c (21 file(s))`<br>- 9e9c8f9 not a phase commit<br>- `RESULT OK`, exit 0<br><br>`pwsh -File scripts/enforcement-pack.ps1` gave `AmendmentAuthority: graded 9 of 9 commit(s)`, `enforcement-pack: OK`, with PhaseSizeWarning on `ad6e64c` (581 lines / 21 files) and `003c96a`. `git status` was clean afterwards. |
| Rollback safety | `ad6e64c` is text plus fixtures. `9e9c8f9` is text only. Both revert cleanly. There is no schema or data. |

## Round-1 findings: status

| Round 1 | Status | Evidence (reproduced, not taken from notes) |
|---|---|---|
| **F1** (BLOCKING): an unapproved `pending` in a merge commit relaxes the check, and the warning claimed "a recorded plan amendment" | **RESOLVED in code (route 2); documents STILL OPEN, carried as F9** | The warning text at lines 458 and 460 now reads "(the owner's declaration in the plan, a claim and not a verified approval; gate 6 stands behind it)". The LIMIT comment is at lines 341-343. The evil-merge reproduction (above) still gives OK, exit 0, by design, and the printed text no longer asserts a recorded amendment. Still open from the round-1 Action (b): there is no plan amendment recording the gap (Risks is unchanged, lines 186-199) and no fixture pins the limit (F12). |
| **F2** (BLOCKING): the comment fixtures did not measure the visibility reader | **RESOLVED** | Scratch clone of `9e9c8f9`, `$planVisible = @(Get-VisibleFromText -Lines $planBlob)` replaced by `@($planBlob)`, then `-Case CRIT-R0` (52 cases): `142 passed, 4 failed`. The failures are exactly `CRIT-R03/fail-marker-in-multiline-comment-is-absent` and `CRIT-R03/pass-trailing-comment-is-stripped`, both assertions each. The one-line comment cases still pass under the mutation, as the notes say. Restored and confirmed with `git diff --quiet`. |
| **F3** (MINOR): case sensitivity and code span had no fixture | **RESOLVED** | **Mutation 2**: `switch -CaseSensitive (...)` changed to `switch (...)`, then `-Case CRIT-R0`: `144 passed, 2 failed`, only `CRIT-R02/fail-marker-case-variant`.<br>**Mutation 3**: `-match '^\*\*Merge Readiness` changed to `-match '\*\*Merge Readiness`, then `-Case CRIT-R0`: `145 passed, 1 failed`, only `CRIT-R03/fail-marker-in-code-span-is-absent` (on output: the case read the value `` 'pending`' `` and printed the strict reason; exit 1 either way).<br><br>Each recipe differs from `CRIT-R03/pass` only in the marker line. `fail-marker-case-variant` also moves the last subject to `phase 2 done`, so that feature 024 would warn and the strictness comes from `Pending` alone. That is deliberate and described in its recipe. |
| **F4** (CONFIRM): the empty-value grammar deviated from D1 and T004 | **RESOLVED** | `9e9c8f9` changes D1 (plan line 63, `(.*?)`) and T004 (tasks line 64). Each has `**Amendment approved by**: anas.m, 2026-10-14` (plan line 71, tasks line 60), and the commit message carries `Amendment approved by: anas.m, 2026-10-14`. AmendmentAuthority grades the commit and passes (9 of 9). The machine cannot verify that the named person agreed; see "Amendments in this diff". `notes.md` still calls F4 "Open" (F10). |
| **F5** (ACCEPTED): CRIT-R01 anchor narrowed | **RESOLVED (unchanged, still holds)** | CRIT-R01's anchor `is not yet due - the branch is at phase` still matches only feature 024's two sites. The new text does not contain `the branch is at phase`. CRIT-R03's anchor `declares **Merge Readiness**: pending` matches lines 458 and 460. The comment at line 336 reads `carry '**Merge Readiness**: pending'`, not `declares`. The Coverage tests ("every anchor names exactly the emission sites its rule declares", "every declared emission site belongs to a rule") pass inside `-Case CRIT-` (208/208). |
| **F6** (DOC DRIFT): rules.json and notes text | **RESOLVED, with residual drift moved to F10** | **(a)** The CRIT-R03 `notes` in `rules.json` no longer claims a missing-tasks.md variant, and it names the two byte-identical controls and the four new variants. **(b)** notes.md line 87 records why there is no `emission-idioms.json` entry. **(c)** The full-harness counts are recorded (notes lines 11 and 71: 1478 and 1512). T001/T005's "throwaway FitForge-shaped branch, byte-identical re-run" is not recorded as such: notes line 14 substitutes the existing `CRIT-R01/*field-shaped*` fixtures, which pass unchanged on the tip (in my `-Case CRIT-` run), but never says it is a substitution (F10). |
| **F7** (MINOR): warning text differs when 024 would also warn | **RESOLVED as dispositioned** | Carried to phase 2 (notes line 88, T006 and T008). There is no code to check in phase 1. |
| **F8** (MINOR): PhaseSizeWarning | **RESOLVED as dispositioned** | Noted at notes line 89. `ad6e64c` now carries its own warning (581/21), almost all of it the committed round-1 review (152 lines) and four fixture directories. Non-blocking. |

## Findings

### F9 — The owner's route-2 decision is not in any approved document, and plan D3, D2, D5, Summary, Risks and spec FR-006 still state the pre-remediation position — CONFIRM

The route-2 decision is recorded only in two places:
- notes.md lines 78-79, quoting the session: "go with route 2 and fix the rest".
- `scripts/enforcement-pack.ps1` lines 341-343.

The approved documents still say otherwise:

- **plan.md D3 (lines 88-91)** dictates the warning text, and it still reads `(the owner's declaration, a recorded plan amendment)`. The code now prints different text (lines 458 and 460). This is the same class as round-1 F4: approved text the code is graded against says otherwise. It is **DOC DRIFT** in the code-is-right sense, but it needs an approver record to fix.
- **plan.md D5 (lines 99-107)** says the amendment check "already grades the flip" and that every commit changing an existing plan is graded. It does not mention merge commits. D2 line 85 justifies the shallow-clone choice with "a declaration the owner made and the approver recorded". The Summary (lines 14-15) says the declaration "needs no new approval machinery" because any plan change must name an approver.
- **plan.md Risks (lines 186-199)** lists `pending`-left-in-place and the first-appearance exemption, but not the merge-commit gap. notes.md line 82 says this was left deliberately for the owner. A reader of the plan therefore sees no statement of this residual risk anywhere.
- **spec.md FR-006 (lines 141-142)**: "If the check does not reach a plan header line, this feature MUST say so and extend it, not assume." Route 2 says so but does not extend it. That is a deliberate departure from an approved FR. It is recorded neither as a spec amendment nor in a review the owner signs. The spec Assumptions (line 168-169) carry the same promise.
- The script's own header still says, unqualified, "Flipping it is a plan amendment, so it carries a recorded approver" (lines 339-340), immediately before the LIMIT. That is tolerable because the LIMIT qualifies it, but it is worth folding into the same edit.

**Is this acceptable for phase 1?** For closing the phase 1 code review, yes. The code and the printed text are now honest, and the limit is disclosed beside the code. It is not acceptable at merge. It should also land **before phase 2 starts**: phase 2 (T006, T008, D9) writes `critical-delivery.md` and the `adoption/updating.md` flow-down note from this plan, and would otherwise copy the "recorded amendment" claim into documents that flow down to adopters.

*Action: owner, before phase 2 begins. The implementer may draft; the owner approves; the implementer may not approve its own amendment (constitution I).*
1. Amend plan D3's warning text to the shipped text.
2. Add a sentence to D5 naming the merge-commit gap (014 D7).
3. Add a Risks bullet stating it, beside the `pending` cost.
4. Either amend spec FR-006 to record that the gap is accepted and not extended, or record that acceptance in the gate-6 human review.

Each amended section needs `**Amendment approved by**: <name>, <date>`, and the commit must name the approver.

### F10 — notes.md is stale after the remediation and the F4 amendment — DOC DRIFT

- **F4 row** (line 85): still "**Open** ... Not decided by this remediation". `9e9c8f9` decided it.
- **"Deviations" item 1** (lines 42-48): still says the empty-value deviation is "not written into `plan.md`" and was "flagged to the owner". It is now amended.
- **F1 row** (line 82): says "all emission sites and the 7 expectation files that print it". `grep -rl "a claim and not a verified approval"` over `tests/` finds **6** `expected.txt` files: AMEND-001/fail-merge-readiness-added-unapproved and CRIT-R03/{pass, pass-solo-arm, pass-no-phase-headings-declaration-needs-none, pass-shallow-clone-declaration-needs-no-history, pass-trailing-comment-is-stripped}. No file anywhere in `tests/` or `scripts/` still carries the old text. The expectations are consistent; only the count is wrong.
- **The D5 paragraph** (lines 37-40): still concludes "the existing check does reach a plan header line ... no change ... was needed (FR-006)" with no reference to the merge-commit limit recorded later in the same file.
- **T001/T005 throwaway branch** (F6(c)): substituted by the `CRIT-R01/*field-shaped*` fixtures without saying so.
- **"Runs after the remediation"** (line 91): says the full harness and `ritual-checks.ps1` "are re-run before the remediation commit's gate", but records no result yet. My `ritual-checks.ps1` run is RESULT OK. The full-harness result is still owed.

*Action: implementer.*
- Update the F4 row and "Deviations" 1 to point at `9e9c8f9`.
- Correct "7" to 6.
- Qualify the D5 paragraph with the merge-commit limit.
- Say that the field-shaped fixtures stand in for T001/T005's throwaway branch.
- Append the full-harness result when the in-progress run finishes.

`notes.md` is phase evidence, not an approved document, so no approver record is needed.

### F11 — The T004 amendment note in tasks.md renders as part of T003 — MINOR

`9e9c8f9` inserts `T004 grammar follows plan D1 as amended (an empty value is strict).` at column 0 directly after T003's last continuation line (tasks.md line 57; the note is line 58), with no blank line. In CommonMark that is a lazy continuation line, so it renders inside T003's list item. The `**Amendment approved by**` line that follows also breaks the task list in two. AmendmentAuthority accepts the record, so this is cosmetic. The amended T004 text itself (line 64) is correct.

*Action: none now. Moving the note would itself be a tasks amendment needing a new approver record. Tidy it at the next approved tasks amendment (for example with F9's), placing the note indented under T004.*

### F12 — No fixture pins the accepted F1 limit — MINOR

Round 1's F1 Action asked for "an AMEND-001 or CRIT-R03 fixture for whichever route is taken". None was added, and notes.md does not say why. The reason is real. `FixtureRepo.psm1` builds merges with "no content of its own" (lines 201-206), so a merge that edits `plan.md` cannot be expressed without a new recipe field and its self-test, which the feature contract forbids without an amendment. Without a fixture, the "WARN, exit 0 on a merge-commit `pending`" behaviour is not pinned. A later fix to 014 D7 would change it silently, though in the safe direction.

*Action: owner. Either accept no fixture (recorded with F9's Risks bullet, ideally as a roadmap follow-up to grade merge-commit content), or approve a recipe field in a later feature. The implementer records the reason in notes.md.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

- **`9e9c8f9`**:
  - **plan.md D1**: grammar changed to `(.*?)`, with an empty value as a malformed marker. There is an explanatory paragraph, and `**Amendment approved by**: anas.m, 2026-10-14` sits in the amended section (lines 69-71).
  - **tasks.md T004**: grammar changed, with a note and `**Amendment approved by**: anas.m, 2026-10-14` immediately above T004 (lines 58 and 60; see F11).
  - **Commit message**: `Amendment approved by: anas.m, 2026-10-14`.
  - **Machine grading**: AmendmentAuthority grades it and passes (`graded 9 of 9`).
  - **Not machine-verifiable**: the commit is co-authored by the implementing model, and whether anas.m actually gave the approval is outside the machine's reach (constitution I, "What can be verified"). The human reviewer should confirm that the owner approved D1/T004. This review takes it as a written, falsifiable claim. notes.md records no session quote for F4, unlike F1.
- **`ad6e64c`**: changes no approved document. Its `--stat` under `specs/` lists only `notes.md` and the round-1 review file, both added or changed. spec.md, plan.md, tasks.md and contracts/ are untouched.
- **`1c876e5`**: `notes.md` only.
- **Unrecorded deviation**: the shipped warning text deviates from approved plan D3 without an amendment. Route 2 was the owner's decision, but it is not recorded as an amendment; see F9.

## Constitution re-check (post-implementation)

**PASS, with I engaged (F9).**

- **I (Amendment authority)**: 9e9c8f9 conforms in form. The F1 route-2 decision departs from approved D3 text and FR-006 without an approver record (F9). No self-approval is visible, but that half of I is held by review alone.
- **III, V, VII**: N/A.
- **IV**: no new file.
- **VI**: nothing sensitive.
- **VIII**: F2 and F3 closed by mutation-verified fixtures. The F1 limit is unpinned (F12).
- **IX**: provenance present on both review files. ReviewProvenance passes in `enforcement-pack` (OK).
- **X**: one phase, user-run gate. The remediation is a phase 1 commit and scope-check PASS.

## Test coverage observed

All runs were in a scratch clone of `9e9c8f9`. The working repository was never mutated: `git status` was clean after every run there, and only read-only `enforcement-pack`, `scope-check` and `ritual-checks` were run in it.

- **`-Case CRIT-`**: `208 passed, 0 failed` (83 cases). This includes all 34 feature 024 cases, CRIT-S*/T*, and the coverage suite (anchors equal declared site counts, every site owned).
- **`-Case merge-readiness`**: `48 passed, 0 failed`.
- **Mutations**, each restored by copy and confirmed with `git diff --quiet`:
  - Visibility reader removed: exactly the 2 F2 cases fail (4 assertions).
  - `-CaseSensitive` dropped: exactly `CRIT-R02/fail-marker-case-variant` fails (2 assertions).
  - Line-start anchor dropped: exactly `CRIT-R03/fail-marker-in-code-span-is-absent` fails (output assertion; exit is 1 in both readings).
- **Evil-merge reproduction**, on a kept `CRIT-R03/fail` fixture plus a hand-made merge commit: OK, exit 0, new WARN text. The first parent is FAIL, exit 1. Kept fixture repositories were deleted afterwards.
- **`enforcement-pack.ps1`** on the branch: OK, AmendmentAuthority 9 of 9.
- **`ritual-checks.ps1`**: RESULT OK, exit 0.
- **Full harness**: not run (per instructions; one run already in progress).

## Residual risk

- **The accepted merge-commit gap (F1 route 2).** A `pending` added or restored inside a merge commit is graded by nothing but gate 6. The warning now says so honestly ("a claim and not a verified approval"). It is disclosed in the script, but not yet in the approved plan or spec (F9), and not pinned by a fixture (F12).
- **The disclosed cost of option A.** `pending` can be left in place, and gate 6 holds it.
- **Before phase 2**:
  - The owner approves the F9 amendments (D3 text, D5, Risks, FR-006 disposition).
  - The implementer refreshes notes.md (F10) and records the full-harness result.
- **Before merge**: the owner runs the gate. The human reviewer confirms the anas.m approval on 9e9c8f9 and reads the F1 limit.
