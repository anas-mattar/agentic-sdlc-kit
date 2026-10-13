# AI Code Review — 025 Critical merge-ready signal, phase 2

**Reviewer**: fresh-context agent, Claude Opus 5.5 (claude-opus-5-5)
**Date**: 2026-10-14
**Branches**: agentic-sdlc-kit `025-critical-merge-ready-signal` (phase 2 commit `ce047ac`, parent `07833f3`; feature base `54ecb0a`; branch tip at review start `ce047ac`)
**Scope reviewed**: `git show ce047ac` in full (`.specify/templates/plan-template.md`, `adoption/updating.md`, `docs/digests/adoption-digest.md`, `docs/digests/critical-digest.md`, `docs/roadmap.md`, `docs/sdlc/critical-delivery.md`, `docs/sdlc/definition-of-done.md`, `specs/025-critical-merge-ready-signal/notes.md`). I checked each against `Get-CriticalMergeReadiness` (lines 352-444), `Invoke-CriticalEvidenceCheck` (445-480), the header comment (305-343) and the amendment boundary (`Get-CheckPresenceSet`, around 1350-1385) in `scripts/enforcement-pack.ps1`. I also read: spec.md, plan.md (D1-D9, Risks, "Needs the owner"), tasks.md (T006-T011 and the phase 2 Territory), notes.md, `ai-code-review-phase-1.md` (F1, F7), `kit-manifest.json`, constitution IX and X (lines 366-425, plus a grep of the header-field sentences at 76-135), the 024 flow-down note in `adoption/updating.md`, `specs/_templates/ai-code-review-template.md`, `specs/024-critical-branch-not-red/ai-code-review-phase-2.md` (for shape), and the `CRIT-R03/pass-shallow-clone-declaration-needs-no-history` fixture. Not read in depth: `docs/sdlc/review-process.md` beyond the template it points to; the FlowBoard replay (not re-run).
**Feature contract**: phase 2 is prose, the template line, the roadmap, the digests and a measurement. No script, no test, no constitution amendment (tasks.md phase 2, plan D6 and D9). The template ships the line absent or commented out (D9).

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: Claude Sonnet 5.5 (claude-sonnet-5-5) session
- **Inputs provided**: the phase 2 diff (`git show ce047ac`, parent `07833f3`); specs/025-critical-merge-ready-signal/{spec.md, plan.md, tasks.md, notes.md}; ai-code-review-phase-1.md and ai-code-review-phase-1-round-2.md; scripts/enforcement-pack.ps1 (Get-CriticalMergeReadiness, Invoke-CriticalEvidenceCheck); docs/sdlc/critical-delivery.md; docs/sdlc/definition-of-done.md item 6; .specify/templates/plan-template.md; adoption/updating.md (the 025 note and the 024 note above it); docs/roadmap.md; docs/digests/*; kit-manifest.json; docs/sdlc/review-process.md; specs/_templates/ai-code-review-template.md; specs/024-critical-branch-not-red/ai-code-review-phase-2.md (for shape); scratch clones of D:\solutions\fitforge and D:\solutions\expense-tracker
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The commit changes the files that tasks.md phase 2 names, plus `notes.md`. It touches no script, no test and no approved feature document, and every machine check passes.

I tried to falsify every behavioural sentence in the guidance, the flow-down note, the template comment and the roadmap by running probes in a scratch repository, and all of them held:

- each value, including case sensitivity and the empty value;
- two marker lines;
- a comment, a fence or a code span hiding the marker;
- a Standard feature ignoring it;
- a committed artifact winning over `pending`;
- `pending` overriding a final-phase subject;
- `ready` failing on a missing artifact;
- an unapproved flip being graded;
- the warning text;
- the F7 point ("same verdict, different text").

The raw plan template declares nothing. I re-ran the whole FitForge 002 replay in both modes and it matches exactly: 17 WARN / 22 missing / 4 strict-with-reason with no marker, and 41 declared WARN at exit 0 plus 2 strict with `pending` injected. `ready` at the tip fails. ExpenseTracker's non-Critical branches are byte-identical before and after.

The defects are presentation and completeness, not false relief:

- **F1**: a literal `\n` in Definition of Done item 6. That file flows down verbatim, so this should be fixed before merge.
- **F2**: the replay's "exits 0 at each of those 41" holds only because FitForge's committed scripts predate the amendment check. I verified this; notes.md left it unverified, and updating.md omits it.
- **F3**: the decisions log does not record D7, which T009 requires.
- Three MINOR presentation points.

Residual risk stays where the feature put it: `pending` is a claim, merge commits are ungraded, and gate 6 stands behind both.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FR-008, FR-009, SC-002; the guidance's behavioural claims) | **Probes.** Minimal scratch repositories (`<scratchpad>/probe-*`, `scripts/*.ps1` copied from the working tree at `ce047ac` and committed, a Critical `001-thing` with 3 `## Phase N` headings and a `phase 1: a` commit, no `kit-adoption.json` so the solo arm applies), run with `pwsh -File scripts/enforcement-pack.ps1 -Branch 001-thing`. Results by plan variant:<br>• lower-case `pending`: declared WARN, exit 0.<br>• `Pending`: strict, `declares **Merge Readiness**: 'Pending', which is neither pending nor ready`, plus `second-model-review.md is missing`, exit 1.<br>• empty value: strict, `with no value`, exit 1.<br>• two lines: strict, `more than once`, exit 1.<br>• `` `**Merge Readiness**: pending` `` (code span): hidden, so the heuristic warns "at phase 1 of 3", exit 0.<br>• `` **Merge Readiness**: `pending` ``: strict, the value is quoted with its backticks, exit 1.<br>• `ready`: no reason line, `is missing`, exit 1.<br>• `pending <!-- flip at the end -->`: declared WARN, exit 0.<br>• CRLF `pending`: declared WARN, exit 0.<br>• a Standard spec with `Pending`: no CriticalEvidence line, exit 0.<br>• `pending` after a `phase 3: c` commit: still the declared WARN, exit 0. The same branch with no marker fails `is missing`, which is the override 024 could not do.<br>• the `pending` to `ready` flip with no approver: `AmendmentAuthority: commit e993ab8 amends specs/001-thing/plan.md after approval with no conforming approver record`, exit 1.<br>**Against the documents.** Every one of these matches critical-delivery.md lines 191-205, the updating.md "What it does now" paragraph, and the template comment. The code reads in the same order: committed artifact (358-359), then the marker (365-386, `switch -CaseSensitive`, `''` arm), then the history steps (387+). The warning text in both documents matches lines 458 and 460, and both arms use the same prefix. The shallow-clone and no-phase-heading claims match the fixtures `pass-shallow-clone-declaration-needs-no-history` and `pass-no-phase-headings-declaration-needs-none` (see F4 on the run's overall exit). |
| Template declares nothing (item 2) | `.specify/templates/plan-template.md` lines 18-24: the whole explanation sits inside one `<!-- ... -->`. No line in it starts `**Merge Readiness**`, because the mention at line 19 is mid-line inside a code span. Probe `probe-template`, a Critical plan that is the template verbatim: the heuristic decides (`is not yet due - the branch is at phase 1 of 3`), there is no declared line, exit 0. |
| Flow-down "five verbatim files" (item 3) | `git diff --stat 54ecb0a ce047ac -- . ':!tests' ':!specs/025-...'` shows 8 files. The manifest classes them as follows:<br>• `scripts/enforcement-pack.ps1`: `scripts/*.ps1` verbatim.<br>• `docs/sdlc/critical-delivery.md`: verbatim.<br>• `docs/sdlc/definition-of-done.md`: verbatim.<br>• `.specify/templates/plan-template.md`: `.specify/templates/**` verbatim.<br>• `adoption/updating.md`: `adoption/**` verbatim.<br>• `docs/digests/*-digest.md`: `generated`, so "update-kit never copies these".<br>• `docs/roadmap.md`: not in the manifest, so not shipped.<br>That is exactly five verbatim files, with nothing surgical and nothing kit-only. The "run build-digests after the update" instruction matches the generated class. The shape matches the 024 note: what was wrong, what it does now, what flows down, what may newly be seen, what does not change, limits, what was measured, what to do. |
| Digests and doc-lint (item 3) | Working repo (read-only modes):<br>• `pwsh -File scripts/build-digests.ps1 -Check`: `digests: OK (5 digest(s) fresh, 109 marker(s))`. That is 105 + 4, matching notes.md.<br>• `pwsh -File scripts/doc-lint.ps1`: `OK - kit complete, every referenced path resolves`.<br>Marker lengths, measured with awk on the diff: 116 and 115 (updating.md), 115 and 111 (critical-delivery.md). All are at most 120, which is `MaxDigestLineLength = 120` at build-digests.ps1 line 62. The 115/111 figures match notes.md T006. |
| Measurement claims (item 4) | **Full re-run, not a subset** (about 6 s per run). Two scratch clones of `D:\solutions\fitforge` (`core.autocrlf=false`), with this kit's `scripts/*.ps1` copied into an untracked `.kitprobe/scripts/`. Each run was `enforcement-pack.ps1 -Root . -Branch 002-identity-member-profile` after `git reset --hard` to each of the 43 commits of `main..002-identity-member-profile`. Driver: `<scratchpad>/replay.sh`. Results:<br>• **No marker**: 17 `warn-heuristic` (exit 0), 22 `missing` (exit 1), 4 `reason` (exit 1; commits 1-4). This is exactly notes.md / updating.md / the roadmap, and 22 + 4 = 024's 26 strict.<br>• **`pending` injected** (a throwaway commit inserting the line after `**Gate Certification**`): 41 `warn-declared` at exit 0. The other 2 are commits 1 and 2 (`886814a`, `b68b937`), which have no `plan.md`, so `tasks.md is not committed or cannot be read`, exit 1. This matches the documents.<br>• **`ready` at the tip** (`b9e1d88` + injection): `human-pr-review.md is missing — team mode`, exit 1. FitForge is team mode, so the solo arm is "not exercised", as the note says.<br>**ExpenseTracker.** Clone, `.kitold/scripts` from `git archive 54ecb0a scripts` and `.kitnew/scripts` from the working tree. `main` and `003-expense-entry`: `cmp` reports identical output, exit 0 for both. FlowBoard was not re-run.<br>**Simulation wording.** "a simulation" and "the marker does not exist in that history ... not that an owner will use it" are in notes.md T010, the updating.md "What was measured" paragraph, and the decisions log. The GAP-022 row says "injected". This is not overclaimed, except for the exit-0 point (F2).<br>**Counts.** Roadmap "21 new fixture cases (1478 to 1520)": `git diff --name-only 54ecb0a ce047ac -- tests/enforcement/cases` lists 21 case directories (14 CRIT-R03, 4 CRIT-R02, 3 AMEND-001). notes.md line 97 gives 1478 + 42 = 1520. These are consistent. |
| F7 / F1-limit / "claim" / retired phrase (item 5) | **F7** is stated in critical-delivery.md ("On a branch the heuristic already reads as mid-feature, `pending` gives the same verdict (a warning, not a failure) with different warning text") and in updating.md ("...same verdict with different warning text"). Probes `codespan` (heuristic WARN, exit 0) and `trailcomment` (declared WARN, exit 0) show the same verdict with different text.<br>**The merge-commit limit** is in critical-delivery.md, in the critical digest marker, in updating.md limit (3), in the GAP-022 update and in the decisions log ("merge commits are not graded"). The template comment does not repeat it, which is acceptable for a pointer (see F5).<br>**"`pending` is a claim"** appears in all five places and in the template.<br>**Retired phrase.** Grep `recorded (plan )?amendment` over the repo: hits only in phase 1 reviews, notes.md history (line 82) and the script header's negation ("not a recorded amendment"). There are none in any phase 2 document. |
| Constitution / domain invariants (item 6) | I read constitution X (lines 375-425) myself. It names `**Gate Batching**` and `**Gate Certification**` and their legal values, and the Micro `**Delivery Level**`. No sentence closes the set of plan header fields, and none fixes when the independence artifact is demanded. IX (366-373) requires human review before merge, which `pending` leaves intact. T006's "no amendment needed" holds. The domain-invariants slot is unfilled in the kit. |
| Security (authn/authz, secrets, sensitive logging) | Not applicable: prose, a template comment and generated digests. The replay clones were made from local directories and nothing was pushed. |
| Scope guard (item 7) | **Scope check.** `pwsh -File scripts/scope-check.ps1 -Commit ce047ac`: `PASS phase 2 commit ce047ac (8 file(s))`. The 7 non-notes files all sit under the phase 2 Territory (`docs/sdlc/critical-delivery.md`, `docs/sdlc/definition-of-done.md`, `.specify/templates/plan-template.md`, `adoption/updating.md`, `docs/roadmap.md`, `docs/digests/**`). `notes.md` is the feature's own spec directory, which is not graded, the same as 024.<br>**Untouched paths.** `git diff --stat ad2e084 ce047ac -- scripts tests` is empty, and `git diff --stat 07833f3 ce047ac -- spec.md plan.md tasks.md` is empty, so no approved document was changed.<br>**Ritual checks.** In a scratch clone at `ce047ac`, `pwsh -File scripts/ritual-checks.ps1 -Branch 025-critical-merge-ready-signal` gives exit 0 with `RESULT OK`: doc-lint OK, enforcement-pack OK (`AmendmentAuthority: graded 14 of 14`), scope-check OK (every phase commit PASS), digests OK, roadmap-claims OK. |
| Roadmap integrity (item 8) | The diff touches three places in `docs/roadmap.md`:<br>• GAP-022, which gains an "Update (2026-10-14)" sentence;<br>• the "better merge-ready signal" row, which goes from `idea \| — \| —` to `shipped \| anas.m \| specs/025-critical-merge-ready-signal/`;<br>• a new decisions-log entry, plus the missing final newline.<br>No other row changed. `pwsh -File scripts/roadmap-claim-check.ps1`: `OK (0 claim(s) visible with non-idea rows, own claim 025 exempt)`. The "shipped means built, reviewed and measured; gate and human review to come" caveat is the 024 convention. |
| Rollback safety | Prose, a template comment and generated digests. `git revert ce047ac` removes them, and the digests regenerate. Phase 1 code is untouched, and phase 2 reverts cleanly before phase 1 (tasks.md "Organization"). |

## Findings

### F1 — Definition of Done item 6 contains a literal `\n` — DOC DRIFT

`docs/sdlc/definition-of-done.md` line 151 reads `... settles the question\n   explicitly, as that item states.` The `\n` is two literal characters, a backslash and an `n` (confirmed with `grep -n 'settles the question' ... \| cat -A`). The intended line break was never applied. Markdown renders `\n` literally, so the sentence shows "question\n   explicitly" in a law document. That document is classed `verbatim` and flows down to every adopted project with this update. doc-lint does not catch it.

*Action: implementer replaces the `\n   ` with a real line break, keeping the same three-space indent, in a phase 2 remediation commit; DoD is in the phase 2 Territory, so no approver is needed. Then re-run `build-digests.ps1 -Check`, whose DoD markers are unchanged.*

### F2 — The replay's "exits 0 at each of those 41" holds only because FitForge's committed scripts predate the amendment check — DOC DRIFT

Plan D8 and T010 expected the throwaway injection commits to fail AmendmentAuthority, and said "not counted". None did. notes.md T010 says "I did not investigate why ... the likely cause [is the boundary] ... not verified".

I verified it. `git grep -F 'function Invoke-AmendmentAuthorityCheck' <c> -- scripts/enforcement-pack.ps1` finds nothing in any of the 43 commits of FitForge's `main..002-identity-member-profile` (43 × `n`). The pack's boundary (`Get-CheckPresenceSet`, the D2b self-bootstrap) therefore grades none of them. My injected runs print `AmendmentAuthority: graded 0 of 44 commit(s) ... (44 not graded: 1 merge commit(s); 43 made before the check existed (plan D2b))`, the throwaway commit included.

So the "exit 0" figure in updating.md ("the check warns at 41 of 43 and the run exits 0 at each of those 41") is true for this history only because the injected, unapproved amendment was never graded. In an adopted project whose committed scripts carry the check, the same unapproved addition fails AmendmentAuthority and exits 1 (`probe-lowpend` flip, and `AMEND-001/fail-merge-readiness-added-unapproved`). The updating.md paragraph a few lines above says adding the line needs an approver, so a careful reader is not misled about the law. A reader of the measurement alone could still take "exit 0" as what an unapproved addition gets.

*Action: implementer updates notes.md T010 to state the cause as verified (cite the `graded 0 of 44 ... made before the check existed` line). In the updating.md "What was measured" paragraph, add a short qualifier, for example: "(the injected commits are unapproved amendments; FitForge's committed scripts predate the amendment check, so they were not graded; in a project that has taken the update they would need an approver)". Optionally mirror it in the decisions-log "Measured" clause.*

### F3 — The decisions-log entry omits the owner's D7 decision, which T009 requires — DOC DRIFT

T009 says the 2026-10-14 entry records "the owner's decisions on D2, D7 and D9". The entry (`docs/roadmap.md`, last block) records option A, D2, D9, route 2, the empty-value amendment and F9. It never records D7 (`ready` means "owed now", not "approved"; plan "Needs the owner" item 3, "Accepted as 'owed now'"). The behaviour clause "`ready` grades the artifact as for a merge-ready branch" describes the code, not the owner's decision.

*Action: implementer adds "D7 (`ready` means owed now, not approved; no stricter same-commit flip) as recommended" to the "Decided by the owner" clause, in the phase 2 remediation commit; the roadmap is in the phase 2 Territory and is not an approved feature document.*

### F4 — "Works in a shallow clone" is true of the CriticalEvidence line, but the run still exits 1 there — MINOR

critical-delivery.md says the declaration "needs no history, so it works in a shallow clone". updating.md says "no failure for the missing artifact, whatever the subjects, headings or clone depth say". Both are accurately scoped to the artifact.

The committed fixture `CRIT-R03/pass-shallow-clone-declaration-needs-no-history`, however, expects `exitCode: 1`: `AmendmentAuthority: cannot grade '001-thing' — this is a shallow clone ...`. A depth-1 CI checkout of a Critical branch declaring `pending` is therefore still red, for a different member. GAP-022 is about the branch being red, so an adopter reading "works in a shallow clone" may expect green.

*Action: optional. Implementer may add a clause to critical-delivery.md and updating.md: "(the run as a whole still needs full history: AmendmentAuthority cannot grade a shallow clone)". None needed if the owner reads "it" as the declaration only.*

### F5 — Digest placement and stale neighbours — MINOR

(a) The two new critical-delivery.md markers are placed (lines 207-208) **before** the existing "Critical 5: the human reviewer is never the owner..." marker and before 024's "WARN until the final phase lands" marker. In `docs/digests/critical-digest.md`, "Critical 5: **Merge Readiness** ... overrides the phase-token heuristic" therefore appears before the reader has met Critical 5 or the heuristic it overrides. The second marker also lacks the `Critical 5:` prefix its neighbours carry.

(b) T006 says "add or amend the digest markers beside them". The neighbouring markers were not amended and are now incomplete for a declaring plan:
- the DoD marker "Gate 6 on Critical: the review artifact is a WARN until the final phase lands or it is committed, then required";
- the critical marker at line 212, which says the same.

Under `pending` the artifact remains a WARN after the final phase lands. Digests are orientation only (CLAUDE.md, "never a source-of-truth rung"), so this is not drift in law.

*Action: optional. Implementer moves the two new markers after line 213, prefixes the second with `Critical 5:`, and appends "unless the plan declares Merge Readiness" (or similar, within 120 characters) to the two neighbouring markers, then runs `build-digests.ps1` and commits the regenerated digests.*

### F6 — A visibly indented marker is silently ignored — MINOR

A line indented by 1 to 3 spaces (`   **Merge Readiness**: ready`) renders as ordinary paragraph text, but `^\*\*Merge Readiness\*\*:` does not match it. It falls through to the heuristic with no reason line (probe `indented`: heuristic WARN, exit 0). The guidance's "No marker, or one that is hidden: the heuristic" does not cover a visible-but-indented marker. The risky direction is an indented `ready` that leaves a branch on a 024 WARN.

This is the kit's existing convention for every plan header field: `Gate Batching` at line 654 and `Gate Certification` at line 696 use the same anchor. Header fields sit at column 0 in the template, so a real occurrence is unlikely.

*Action: none required in phase 2 (a code change would be phase 1 Territory and a separate decision). Recorded for the human reviewer; optionally say "at the start of a line" in critical-delivery.md.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None.** `git diff --stat 07833f3 ce047ac -- specs/025-critical-merge-ready-signal/{spec,plan,tasks}.md` is empty, and no `contracts/` exists. The only spec-directory file changed is `notes.md`, which is phase evidence and not an approved document. The tasks.md checkboxes T006-T011 remain unticked, consistent with the feature's practice. AmendmentAuthority on the branch: `graded 14 of 14 commit(s)`, OK. The earlier amendments in this feature (`9e9c8f9`, `e68fe6a`) predate this commit and carry `**Amendment approved by**: anas.m, 2026-10-14`.

## Constitution re-check (post-implementation)

**PASS.**

- **I (Amendment authority)**: no approved document changed. The guidance describes amendment of the marker the way the check grades it: single-parent commits, with the merge-commit limit stated.
- **II**: the guidance now matches the code (the source-of-truth ladder is consistent), apart from F1's typo.
- **III, V, VII**: N/A.
- **IV**: no new file. The template line is a comment in an existing verbatim file.
- **VI**: N/A.
- **VIII**: there are no new tests in phase 2. Phase 1's cases still pass: `Run-Tests.ps1 -Case CRIT-R` in a scratch clone at `ce047ac` gives 146 passed, 0 failed.
- **IX**: gate 6 is stated as standing behind `pending` everywhere it is described. This review carries provenance.
- **X**: T006's conclusion (no amendment) is verified above. The phase is one at a time, with a user-run gate and no batching or ci-held (plan header).

## Test coverage observed

- `tests/enforcement/Run-Tests.ps1 -Case CRIT-R` (scratch clone at `ce047ac`): `enforcement-tests: 146 passed, 0 failed`. This covers the 024 CRIT-R01/R02 cases and the 025 CRIT-R02 `fail-marker-*` and CRIT-R03 cases. I did not run the full harness, per instructions; T011's final full-harness run is not yet recorded in notes.md.
- Critical assertions relied on for the documents:
  - `CRIT-R03/pass-shallow-clone-declaration-needs-no-history`: declared WARN, run exit 1 from AmendmentAuthority (F4).
  - `CRIT-R03/pass-trailing-comment-is-stripped`, `fail-marker-in-multiline-comment-is-absent` and `fail-marker-in-code-span-is-absent`: the "a comment, a fenced block or a code span hides it" claim.
  - `CRIT-R02/fail-marker-case-variant`: the `Pending` claim.
  - `AMEND-001/fail-merge-readiness-added-unapproved`: the "adding it is an amendment" claim.
- My own probes: 13 throwaway repositories, listed in the evidence table. I also ran the 43-commit FitForge replay twice (no marker, and `pending`), `ready` at the tip, and ExpenseTracker before/after on 2 branches. All were in the scratchpad and nothing in place was touched.

## Residual risk

- The feature's accepted costs remain and are now stated consistently in all phase 2 documents:
  - `pending` is a claim an owner can leave in place, even past the final phase. My `lowpend` probe stays on the WARN after a `phase 3` subject.
  - Merge commits are not graded by the amendment check.
  - The approver is a written name.

  Gate 6 is the backstop for each.
- **Before merge**, fix F1 (it ships verbatim to adopters), and correct F2 and F3 in one small remediation commit. F4-F6 are optional.
- After that, T011 (full harness and ritual-checks on an isolated checkout of the final commit, recorded in notes.md) and the owner's gate.
