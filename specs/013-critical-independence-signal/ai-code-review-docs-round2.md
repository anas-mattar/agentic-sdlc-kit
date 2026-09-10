# AI Code Review — 013 Critical Independence Signal — law and docs coherence (round 2, phase 4 remediation)

**Reviewer**: fresh-context agent — `claude-opus-5` (Agent tool, `general-purpose`, task "Review of 013 law and docs coherence (resumed)")
**Date**: 2026-09-10
**Branch**: `agentic-sdlc-kit` `013-critical-independence-signal`
**Under review**: phase 4, `20bda18..43e52cf` plus `a76e877`
**Scope reviewed**: the phase 4 diff, the shipped scripts, `origin/main`, and the three adopted projects' live records. Ten record shapes measured directly rather than reasoned from the code.
**Verdict**: APPROVE WITH COMMENTS — blocking findings: none

Everything below the rule is the reviewer's report, **verbatim**. It is evidence for
Definition of Done gate 5 and is not edited to match what was later fixed; where a finding
was wrong, the reviewer's own next round says so. What was done about each finding is
recorded in `tasks.md`, not here.

---

## Reviewer Provenance
- **Reviewer**: fresh-context agent — claude-opus-5
- **Implementer**: the main session that produced this diff
- **Inputs provided**: phase 4 diff (`20bda18..43e52cf`, plus `a76e877`), the shipped scripts, `origin/main`, the three adopted projects' records
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict
APPROVE WITH COMMENTS

All three BLOCKING findings are closed and independently verified. What remains is one new CONFIRM of the same family as B1, two artifact-consistency items that are one-line amendments, and residual nits. Nothing left makes any project weaker than today, and every degenerate input I could construct lands on the strict arm.

## Findings

### CLOSED — verified, not taken on trust

**B1 — law vs check on the malformed case. CLOSED, both halves.**
I rebuilt the fixture matrix and measured `enforcement-pack.ps1` directly on ten record shapes. Every one matches what the docs now say:

| record | measured mode |
|---|---|
| field absent | solo |
| `["ada"]` | solo |
| `["ada","grace"]` | team |
| `"ada"` (string) | solo |
| `[]` | solo |
| `["ada","  "]` | solo |
| `["Ada","ada"]` | **solo** (was team) |
| `["ada","grace"," "]` | **team** — matches updating.md's new sentence |
| `[{"developers":["a","b"]}]` | solo |
| `["ada",5,"grace"]` | team |

`critical-delivery.md:104-109` and `adoption/updating.md:378-386` no longer claim malformed records are "ignored"; both now state the count is taken after blanks are dropped and duplicates collapsed case-insensitively, and both worked examples are correct. The trap I flagged — an adopter reading "you are still solo" while the check had moved them to team — is gone.

**B2 — fabricated evidence row. CLOSED.**
`tasks.md:199` corrected and annotated; the new "measured 2026-09-10" table matches my independent measurements row for row, including the root-array row. The correction is recorded as a correction rather than silently overwritten, and the § "B2 — the row that was wrong, and why" names the actual cause (filled by reasoning from the doctor, not by running the check). That is the right shape for an evidence record.

**B3 — missing roadmap row. CLOSED.**
`git show origin/main:docs/roadmap.md` carries the GAP-020 inventory row (line 47), the `Critical independence signal` roadmap row at `in progress` (line 69), and a decisions-log entry (line 214). `pwsh -File scripts/roadmap-claim-check.ps1 -Branch main` → `OK (1 claim(s) visible with non-idea rows)` — i.e. it passes *without* the own-number exemption, which is the real test. The dangling `GAP-020` identifier in `spec.md:139` now resolves.

**C3 — unverified success criteria. CLOSED.**
I verified SC-006 myself rather than reading the claim: `D:/solutions/fitforge`, `D:/solutions/expense-tracker` and `D:/solutions/flowboard` all exist, none of their `kit-adoption.json` files contains `developers`, and all three are clean in `git status`. `tasks.md`'s SC-006 paragraph is accurate. SC-001 being recorded as outstanding-until-flow-down is the honest answer; it genuinely cannot be met from this repository.

**N2 — attestation missing from updating.md's team row. CLOSED.** The row now names the committed path, Reviewer, Owner, *and* the attestation.

**N4 (caveat half) — CLOSED.** `greenfield.md:159-161` now carries the bounded-strength sentence.

**Rendered structure of everything phase 4 touched — checked, clean.** I swept every table in the six touched files for non-uniform cell counts (escaped pipes discounted): zero mismatches. Both new `tasks.md` tables are well-formed 2-col and 3-col GFM with proper separators, at top level, not nested in a list. The relocated template comment now sits between the metadata block and `## Review Provenance`, blank line on each side — it severs nothing, and moving it outside the section is strictly better: a dropped `-->` there now swallows the heading too, so the check fails closed instead of blessing an invisible block. New task-list continuations are at 6 spaces, matching the file. `doc-lint` OK, `build-digests -Check` OK (5 digests, 73 markers), `scope-check` PASS on both phase 4 commits, full `ritual-checks: RESULT OK`.

### NOT CLOSED

**C1 — FR-007 ceiling. HALF closed; the plan now contradicts the shipped code.** *(CONFIRM)*
`scripts/enforcement-pack.ps1:42-48` is fixed and now reads "the strength of the Reviewer Provenance block, no more (FR-007)" — good, and it adds the roster-is-counted-never-compared disclosure. But `plan.md` D4 still opens **"D3 is deliberately stronger than the existing AI-review provenance check"**. So the approved plan and the shipped header now assert opposite things, and D4's headline still exceeds FR-007's explicit ceiling (its own body concedes the ceiling two sentences later, which makes D4 self-inconsistent as well). Consequence: the next person reading `plan.md` for *why* gets the claim FR-007 forbids. Fix is one line — reword the headline to something like "D3 compares two values where the AI-review check compares none: a different check, not a stronger claim" — and it needs the same `**Amendment approved by**` line the plan already models at line 98.

**C4 — mismatched-handles edge case. NOT closed; disclosure is in the wrong document.** *(CONFIRM)*
The header comment's disclosure is well written and I'm satisfied the *behaviour* is the right call — cross-checking free-text names against a free-text roster would read as verification while providing none. But `spec.md` Edge Cases still says the comparison **"must fail loudly rather than pass by accident"**, and the code deliberately does not. A spec containing an unmet MUST, in the feature whose entire subject is a check enforcing something its law did not say, is the wrong artifact to leave standing. My judgement: disclosure alone is not enough — amend the Edge Cases entry to record the decision and point at the header comment. Same one-line cost, same approver line. I would want this settled before merge, but I am not blocking on it: the limit is disclosed where the enforcement lives, and the direction is conservative.

**C2 residual — `review-process.md` and `definition-of-done.md`. NOT a blocker; follow-up.** *(you asked me to rule)*
`review-process.md:121` still reads "Human reviewer checks (record in `specs/_templates/human-pr-review-template.md`)" and `definition-of-done.md:131` cites only the template. Both are **pre-existing** (I confirmed 013's whole `docs/sdlc/` footprint is `critical-delivery.md` alone) and both are outside phase 4's declared Territory. Item 5 — the only place the path is machine-enforced — now spells `specs/NNN-name/human-pr-review.md`, **committed**, and `updating.md` agrees. Widening Territory post-hoc to sweep two pre-existing sentences is exactly the drive-by the scope check exists to catch, and it would cost the phase its clean scope-check for a wording fix that changes no enforcement. **Follow-up**, as a Lite `fix/` branch or folded into the next docs feature. Worth doing soon: a team reading review-process.md in isolation can still put the file in the wrong place and learn it from a red CI run.

**N1 — "row" wording. HALF closed.** *(NIT)* `critical-delivery.md:106` now correctly says "selects the **solo arm**", but line 111 still opens **"Honesty about the second row too"** where the structure is a two-bullet arm list. Same table→list residue, one word.

**N3 — `Review Provenance` vs `Reviewer Provenance`. NOT fixed; I no longer think it should be.** *(NIT, withdraw)* You kept the distinct heading and I agree on reflection: the template ships the correct heading pre-written, the failure message names it exactly, and renaming either would either collide with the AI-review check's established heading or churn a live artifact. If you want cheap insurance, the "no visible `## Review Provenance` section" message could add *"(this is Review Provenance — not the AI review's Reviewer Provenance)"*. Optional; I would not hold merge for it.

**N4 (placement half) — NOT fixed.** *(NIT)* `greenfield.md` still introduces `-Developers` in step 7, after `init-kit.ps1` runs in steps 1–2 (line 44). A greenfield adopter reading in order writes the record before learning the flag exists and must hand-edit. Cosmetic; the guidance is correct wherever it sits.

### NEW

**NEW-1 — the two scripts disagree again, on the very case T023 was written for.** *(CONFIRM)*
`scripts/verify-kit.ps1:261` reads `$record.developers` with no root-object guard. The phase 4 fix added that guard to `Get-EvidenceMode` **only**. For a root-array record, PowerShell's single-element unrolling gives the doctor a real `PSCustomObject`, so:

- `enforcement-pack.ps1` → **solo** (verified on a fixture)
- `verify-kit.ps1` → would emit `OK … 2 developer(s) declared — Critical features use the **team** evidence rule` (verified: `'[{"developers":["a","b"]}]' | ConvertFrom-Json` yields `PSCustomObject` with `.developers` = a 2-element array, `-is [Array]` true, unique count 2)

The consequence is bounded and in the safe direction — the enforcing side is strict, and such a record already fails the doctor on schemaVersion, projectName, topology and tiers, so nobody ships it. What makes it worth fixing is the comment the fix itself added at `verify-kit.ps1:265-270`: *"Deduplication matches scripts/enforcement-pack.ps1's Get-EvidenceMode exactly; if these two ever disagree about what a developer is, the doctor is reporting a mode the enforcing side does not use."* That is now false, and it is precisely the assertion that will stop the next maintainer from re-checking. Either apply the same raw-text root guard in `verify-kit.ps1`, or extract one shared mode function. Given the whole feature is about two artifacts disagreeing, I'd take the shared function.

**NEW-2 — a doc claim the doctor does not quite honour for the non-array case.** *(NIT)*
`adoption/updating.md:383-386` now promises "the doctor reports each as a FAIL *and* prints the mode the record actually produces." True for every path inside the array branch (the mode line is now unconditional — good fix). Not true for `"developers": "ada"`, which takes the `-isnot [Array]` branch and emits the FAIL with no mode line; the mode only appears inside that finding's fix-hint prose ("silently treated as solo"). Either move the mode line outside the if/else or soften "each". Also, neither doc mentions that **non-string** entries are dropped alongside blanks — `["ada",5,"grace"]` measures as **team**, which surprised me until I read the filter.

### Summary for merge
Closed: B1, B2, B3, C3, N2, N4-caveat. Not closed: C1 (plan D4 — recommend amending before merge), C4 (spec Edge Cases — recommend amending before merge), C2-residual (follow-up, explicitly not a blocker), N1-residual, N4-placement. New: NEW-1 (CONFIRM, safe direction but the "matches exactly" comment is now false), NEW-2 (NIT). No blocking findings remain, and I could not construct any record shape that produces a weaker configuration than pre-013 behaviour.
