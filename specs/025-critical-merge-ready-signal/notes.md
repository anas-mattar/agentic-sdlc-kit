# Notes: 025 — a merge-ready signal for a Critical feature that a commit subject cannot give

Phase evidence, never law. The documents are `spec.md`, `plan.md`, `tasks.md`.

## Phase 1

### T001 — baseline on the parent commit (`890b5e4`, tasks committed)

- `pwsh -File scripts/ritual-checks.ps1` on the untouched tree: doc-lint, enforcement-pack, digests, roadmap-claims OK;
  scope-check UNGRADED (no phase commit yet); scope-repos and verify-kit n/a. Exit 0.
- Full harness on an isolated detached worktree of the parent (`890b5e4`): **1478 passed, 0 failed**.
- Recipe check: a recipe commit carries `branch`, `message`, `write` and `shallow`, and an `AMEND-001` recipe carries the
  boundary stub. **No recipe field was added.**
- The FitForge 002 shape already exists in the harness as `CRIT-R01/fail-field-shaped-final` and
  `pass-field-shaped-mid-feature` (024's T009 lesson). The 025 fixtures are built from those recipes, with the final phase
  landing before phase 2 (`CRIT-R01/fail-out-of-order-final-phase-lands-early` is the same case without a marker).

### T002 / T003 — fixtures first, shown failing on the parent

Run against the parent's `scripts/enforcement-pack.ps1` before any code change. A case that reads `-` on the parent measures
something; a `+` is a control that stops an over-relaxation.

| Case | On the parent |
|---|---|
| `CRIT-R03/pass`, `pass-solo-arm`, `pass-no-phase-headings-declaration-needs-none` | exit code and output both fail (parent exits 1, strict) |
| `CRIT-R03/pass-shallow-clone-declaration-needs-no-history` | exit code matches (1, from AmendmentAuthority on a shallow clone), output fails: the parent prints the `not treated as mid-feature` reason instead of the deferral line |
| `CRIT-R03/fail`, `fail-solo-arm`, `fail-artifact-committed-invalid-under-pending`, `fail-marker-in-comment-is-absent`, `fail-marker-in-fence-is-absent` | pass, by design: controls (ready, a committed artifact, and a hidden marker all leave today's behaviour) |
| `CRIT-R03/pass-marker-in-comment-falls-back-to-heuristic`, `pass-standard-feature-ignores-marker` | pass, by design: a hidden marker and a non-Critical feature are byte-identical to the parent |
| `CRIT-R02/fail-marker-two-lines`, `fail-marker-unknown-value`, `fail-marker-empty-value` | exit code and output both fail (parent ignores the marker, reads mid-feature and warns, exit 0) |
| `AMEND-001/fail-merge-readiness-flip-unapproved`, `pass-merge-readiness-flip-approved`, `fail-merge-readiness-added-unapproved` | exit code matches, output fails: the amendment grading is the same on the parent (see D5 below), the difference is the CriticalEvidence line (`ready` prints no strict reason; `pending` prints the deferral) |

Expectations were written by hand from the plan's wording (D3's warning text, D1's reasons) before the code existed. Three
were corrected after the first run against the parent, each for a reason in the output and not to fit the code: a Standard
feature prints a `LevelSurface: not armed` line; the `AMEND-001` added-unapproved case warns for `pending` where I had
omitted the line; and a case with no `tasks.md` at all cannot exit 0 because the Structure check fails it first, so it
became `pass-no-phase-headings-declaration-needs-none` (a `tasks.md` that declares no phase heading).

**Plan D5, read and shown, not assumed:** `AMEND-001/fail-merge-readiness-flip-unapproved` fails AmendmentAuthority on the
parent's unchanged check, and `pass-merge-readiness-flip-approved` passes it. So the existing check does reach a plan header
line, and **no change to `Invoke-AmendmentAuthorityCheck` was needed** (FR-006, SC-003). No plan amendment was made.

**Deviations, recorded here and not written into `plan.md` or `tasks.md`:**

1. **Empty value.** D1 gives the grammar `^\*\*Merge Readiness\*\*:\s*(\S.*?)\s*$`, which would read an empty value as an
   absent marker (feature 024's behaviour, a WARN on a mid-feature branch). D8 lists "an empty value" as a strict variant.
   The code detects the line with `(.*?)` so an empty value is a malformed marker, strict with a reason, as D8 says.
   Flagged to the owner in the phase report as a point where D1's literal grammar and D8's variants disagree.
2. **`CRIT-R01`'s `emitAnchor`** moved from `is not yet due` to `is not yet due - the branch is at phase`. The new deferral
   warning also contains `is not yet due` (the spec's FR-002 wording), which would have made the anchor match four sites
   instead of its declared two. The narrower anchor still matches exactly feature 024's two sites.
3. Plan D8 listed a `CRIT-R03` solo-arm and the `AMEND-*` variants "as variants of the existing rules"; the three AMEND
   cases sit under `AMEND-001` (its pass and fail already exist), with no new rule id.

### T004 — the change

`scripts/enforcement-pack.ps1`: in `Get-CriticalMergeReadiness`, after the "artifact committed at HEAD" step and before the
diff-base and `tasks.md` steps, the committed `plan.md` is read (`git show "HEAD:./specs/$Branch/plan.md"`), made visible by
`Get-VisibleFromText`, fenced lines are dropped by `Get-FencedLineMap` (as the heading reader does), and the
`**Merge Readiness**` line decides: `ready` returns not pending with no reason, `pending` returns pending with
`Declared = $true`, two lines, an unknown value or an empty value return not pending with a reason (the existing
`not treated as mid-feature` site), absent or hidden falls through. `Invoke-CriticalEvidenceCheck` gained the two
deferral emission sites (one per arm) ahead of feature 024's two. The two evidence arms, the function signature and the
amendment check are not edited. The residual limit (`pending` is a claim) is stated in the comment above
`ConvertTo-PhaseNumber`.

### T005 — runs

Agent-run, feedback only; none of this certifies (the owner holds the gate).

- Targeted run (`-Case CRIT-R03`, `fail-marker`, `merge-readiness`): 64 passed, 0 failed.
- Full harness on the working tree with the phase 1 change (before the commit `003c96a`): **1512 passed, 0 failed**. 1478 baseline + 34 = 17 new cases (11 `CRIT-R03`, 3 `CRIT-R02`, 3 `AMEND-001`) at two assertions each. Every pre-existing case unchanged in outcome, including the 34 feature 024 cases and all `CRIT-S*` and `CRIT-T*`.
- `ritual-checks.ps1` on the uncommitted tree: exit 0, doc-lint, enforcement-pack, digests and roadmap-claims OK, scope-check UNGRADED until the commit existed. `scope-check.ps1` on `003c96a`: PASS (54 files).
- Coverage: no unowned emission site (`Coverage.Tests.ps1` inside the full run); `CRIT-R01` keeps `siteCount: 2` on its narrowed anchor, `CRIT-R03` owns the two new sites.

### Phase 1 review remediation (review F1–F8, owner decision of 2026-10-14)

Review: `ai-code-review-phase-1.md` (REQUEST CHANGES). Owner decision, in the owner's words in the session: "go with route 2
and fix the rest".

| Finding | What was done |
|---|---|
| F1 (BLOCKING) | **Route 2, accepted by the owner:** AmendmentAuthority skips merge commits (feature 014, D7), so a `pending` added inside a merge commit carries no approver check, and gate 6 is the only thing behind that case. Recorded as a LIMIT in the script header, and the warning no longer says "a recorded plan amendment": it now says the declaration is "a claim and not a verified approval; gate 6 stands behind it" (both emission sites and the 6 expectation files that print it). No change to `Invoke-AmendmentAuthorityCheck`. **Not yet written into `plan.md` Risks**, because that is an amendment of an approved plan and needs an approver record: the owner is asked whether to record it there. |
| F2 (BLOCKING) | Added `CRIT-R03/fail-marker-in-multiline-comment-is-absent` and `pass-trailing-comment-is-stripped`. Mutation shown: with `Get-VisibleFromText` removed from the marker read, exactly these two fail (and the one-line comment cases still pass, which is the review's point). |
| F3 | Added `CRIT-R02/fail-marker-case-variant` (`Pending`) and `CRIT-R03/fail-marker-in-code-span-is-absent`. Mutations shown: dropping `-CaseSensitive` fails the first; dropping the line-start anchor fails the second. All three mutations were restored byte for byte (`cmp`). |
| F4 (CONFIRM) | **Resolved.** The owner confirmed the strict reading on 2026-10-14; plan D1 and tasks T004 were amended with the approver record (`9e9c8f9`, `**Amendment approved by**: anas.m, 2026-10-14`). |
| F5 | Accepted as disclosed (the `CRIT-R01` anchor). |
| F6 | `rules.json` CRIT-R03 notes corrected (no "missing tasks.md" variant; two controls are byte-identical on the parent; the new variants listed). The full-harness counts are recorded above (T001, T005). **No `emission-idioms.json` entry was added, on purpose:** feature 024's warning has none either (`grep` for `not yet due`, `CriticalEvidence` and `CRIT` in that file finds nothing), so T003's "the way feature 024's warning is" means no entry. |
| F7 | Carried to phase 2: the guidance (T006, T008) must say that `pending` on a branch feature 024 already reads as mid-feature gives the same verdict with different warning text. |
| F8 | Noted: the phase-size warning is 51 fixture files against about 41 changed script lines, the same shape as feature 024's phase 1. |

Runs after the remediation: `-Case CRIT-` selects 83 cases (79 before, plus the 4 new): 208 assertions, 0 failed; `-Case
merge-readiness`: 0 failed. The full harness and `ritual-checks.ps1` are re-run before the remediation commit's gate.

### Round 2 review and what stays open (review `ai-code-review-phase-1-round-2.md`, APPROVE with follow-ups)

- Round 2 re-ran the three mutations itself and confirmed F1 to F8 as dispositioned; F4 is resolved by `9e9c8f9`.
- Full harness after the remediation (`ad6e64c`): **1520 passed, 0 failed** (1478 baseline + 42 = 21 new cases at two assertions each).
- T001 and T005 asked for a throwaway FitForge-shaped branch with no marker, before and after. It was **not built**: the existing 024
  fixtures `CRIT-R01/fail-field-shaped-final`, `pass-field-shaped-mid-feature` and
  `fail-out-of-order-final-phase-lands-early` are that branch, and all 34 feature 024 cases pass unchanged in both full runs, which is
  the byte-identical claim (SC-001) as the harness measures it.
- **Plan D5 and the merge-commit limit:** D5's reading that the amendment check grades every plan change holds for non-merge commits only;
  the check skips merge commits (feature 014, D7), so a `pending` added inside a merge carries no approver check. The code and the script
  header say so; the approved documents do not yet (F9, below). **No fixture pins the limit (F12):** the fixture library can only build merges
  with no content of their own, so the evil-merge case cannot be written without a recipe field; accepted, and the round 2 reviewer's manual
  reproduction stands in for it.
- **F9, owner decision pending:** plan D3 (the old warning text), D5, D2 line 85, the Summary and Risks, and spec FR-006 still describe the
  pre-route-2 design. Each needs an amendment with the owner's approver record before merge, and before phase 2 writes guidance from them.
- **F11:** the T004 amendment note in `tasks.md` sits directly after T003 with no blank line and so renders as part of it; fix it at the next
  approved tasks amendment.
### F9 and F11 closed (`e68fe6a`, owner approval 2026-10-14)

The owner approved the drafted amendments as written: plan Summary, D2, D3 (the warning text now matches the code), D5 (the accepted
merge-commit limit) and Risks; spec FR-006 and the "Why this is not a new honour system" paragraph; the `tasks.md` T004 note moved onto
its own paragraph (F11). Each document carries `**Amendment approved by**: anas.m, 2026-10-14` and the commit message names anas.m.
`ritual-checks.ps1`: RESULT OK; `enforcement-pack.ps1`: AmendmentAuthority graded 11 of 11, OK.

### Gate certification, phase 1 (user-run)

Gate certified (user-run): `pwsh -File scripts/ritual-checks.ps1` on `ad2e084` (the phase 1 commit `003c96a`, its review remediation, the F4 and F9
amendments and the notes), exit code **0**, confirmed by the owner (anas.m, 2026-10-14).

Awaiting: the owner's go-ahead for phase 2. The AI review (rounds 1 and 2) is filed; the human review at merge is still to come.

## Phase 2

### T006 — constitution X, and the guidance

Constitution X (and the sentences that mention `**Gate Batching**` and `**Gate Certification**`, lines 76 to 135 and 383 to 419) names those two
fields and their legal values as constants; **no sentence fixes the set of plan header fields**, and none fixes when the independence artifact is
demanded (the second point is item 6 of the Definition of Done, "at merge", which feature 024 already read). **No amendment is needed**, as plan D6
expected. `docs/sdlc/critical-delivery.md` gained an "explicit declaration" paragraph under item 5 and two digest markers (115 and 111 characters),
and `docs/sdlc/definition-of-done.md` item 6 now points to the declaration. The F7 point (`pending` on a branch the heuristic already reads as
mid-feature gives the same verdict with different warning text) is stated in both places that describe the check.

### T007 — the template

`.specify/templates/plan-template.md` gained an optional, **commented-out** `**Merge Readiness**` explanation after the `**Gate Certification**`
comment (plan D9). It declares nothing: a comment hides it from the check, which `CRIT-R03/pass-marker-in-comment-falls-back-to-heuristic` shows.
`kit-manifest.json` already classes `.specify/templates/**` as `verbatim`, so it flows down with `update-kit.ps1` and needs no entry.

### T008 / T009 — flow-down note, roadmap, digests

`adoption/updating.md` has a flow-down note shaped like 024's (what was wrong, what it does now, what flows down, what an owner may newly see,
what does not change, the known limits, what was measured, what to do) and two digest markers. `docs/roadmap.md`: the GAP-022 row carries an update,
the "better merge-ready signal" row is `shipped` (owner anas.m, `specs/025-critical-merge-ready-signal/`), and the decisions log has a 2026-10-14
entry recording the owner's decisions. `scripts/build-digests.ps1` rewrote the digests (109 markers, up from 105 plus four new).

### T010 — the measurement (plan D8, FR-009, SC-002)

**This is a simulation, said plainly.** The `**Merge Readiness**` line does not exist in any real history, so the replay injects it. An injection
shows the mechanism on real shapes. It does not show that an owner will use it.

**Method.** A scratch clone of FitForge made from its local directory (`core.autocrlf=false`; nothing in place touched, nothing pushed). The
branch's 43 commits (`git rev-list main..002-identity-member-profile`) were walked oldest to newest; at each, the branch was reset to that
commit, this kit's `scripts/` (as of `ad2e084`) was overlaid in an untracked directory inside the clone (the pack takes its project root
from its own location), and `enforcement-pack.ps1 -Branch 002-identity-member-profile` was run. Three modes, three clones, run in parallel:
no injection; `pending` injected by a throwaway commit at each commit that has a `plan.md`; `ready` injected at the last commit only.

**First-pass defects, found and discarded**: the first driver left the clone's autocrlf at its default, so the checkout aborted and zero commits
were walked; the second overwrote its own `-Out` parameter (PowerShell variable names are case-insensitive) and lost its rows. Both are
driver bugs, not kit behaviour. The non-Critical driver's first pass ran each pack version from a directory outside the project, so both
versions read the kit as the project; it was discarded and rerun with each version inside the clone.

| Mode | Result over FitForge 002's 43 commits |
|---|---|
| No marker (the current kit) | `WARN` (heuristic) at **17**, failure ("is missing") at **22**, strict with a printed reason at **4**. Identical to feature 024's measurement (17 warn, 26 strict), as it must be: an absent marker leaves feature 024 byte for byte. |
| `pending` injected | `WARN` (declared) at **41 of 43**, exit 0 at each of the 41. The other two are commits 1 and 2 (`spec: 002 ...`, `spec: record owner approval of 002`), before `plan.md` exists, so no line can be injected: strict, `tasks.md is not committed or cannot be read`, exit 1. |
| `ready` injected at the tip (commit 43, `b9e1d88`) | Failure: the missing review is demanded, exit 1, as intended. |

SC-002 reads "warns at every commit that does not carry the artifact, where feature 024 warned at 17 of 43": with the declaration at plan
creation the check warns at every commit from the third on (41), and 17 where the heuristic alone could. The injected throwaway commits are
amendments of an approved plan; no run exited 1 for that (41 of 41 injected runs exited 0). I did not investigate why, so I do not claim a reason:
those throwaway commits sit under the clone's older `scripts/` boundary (plan D2b), which is the likely cause and is not verified here.

**Non-Critical branches** (same method, clones of FlowBoard and ExpenseTracker, the kit's `enforcement-pack.ps1` as of the parent `54ecb0a`
against the kit as it stands, each version run inside the clone): FlowBoard `main`, ExpenseTracker `main` and `003-expense-entry` (8 changed
files, exit 0) printed **byte-identical output and exit codes** before and after. FlowBoard has no feature branch. Not exercised: a Critical
branch in the solo arm on a real project, and any run in an adopted project's own CI. Nothing moved, so there is no line to explain.
