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
| F1 (BLOCKING) | **Route 2, accepted by the owner:** AmendmentAuthority skips merge commits (feature 014, D7), so a `pending` added inside a merge commit carries no approver check, and gate 6 is the only thing behind that case. Recorded as a LIMIT in the script header, and the warning no longer says "a recorded plan amendment": it now says the declaration is "a claim and not a verified approval; gate 6 stands behind it" (all emission sites and the 7 expectation files that print it). No change to `Invoke-AmendmentAuthorityCheck`. **Not yet written into `plan.md` Risks**, because that is an amendment of an approved plan and needs an approver record: the owner is asked whether to record it there. |
| F2 (BLOCKING) | Added `CRIT-R03/fail-marker-in-multiline-comment-is-absent` and `pass-trailing-comment-is-stripped`. Mutation shown: with `Get-VisibleFromText` removed from the marker read, exactly these two fail (and the one-line comment cases still pass, which is the review's point). |
| F3 | Added `CRIT-R02/fail-marker-case-variant` (`Pending`) and `CRIT-R03/fail-marker-in-code-span-is-absent`. Mutations shown: dropping `-CaseSensitive` fails the first; dropping the line-start anchor fails the second. All three mutations were restored byte for byte (`cmp`). |
| F4 (CONFIRM) | **Open.** The code takes D8's reading (an empty value is strict). If the owner confirms it, D1 and T004 need an amendment with the owner's approver record; if not, the code and three fixtures change. Not decided by this remediation. |
| F5 | Accepted as disclosed (the `CRIT-R01` anchor). |
| F6 | `rules.json` CRIT-R03 notes corrected (no "missing tasks.md" variant; two controls are byte-identical on the parent; the new variants listed). The full-harness counts are recorded above (T001, T005). **No `emission-idioms.json` entry was added, on purpose:** feature 024's warning has none either (`grep` for `not yet due`, `CriticalEvidence` and `CRIT` in that file finds nothing), so T003's "the way feature 024's warning is" means no entry. |
| F7 | Carried to phase 2: the guidance (T006, T008) must say that `pending` on a branch feature 024 already reads as mid-feature gives the same verdict with different warning text. |
| F8 | Noted: the phase-size warning is 51 fixture files against about 41 changed script lines, the same shape as feature 024's phase 1. |

Runs after the remediation: `-Case CRIT-` selects 83 cases (79 before, plus the 4 new): 208 assertions, 0 failed; `-Case
merge-readiness`: 0 failed. The full harness and `ritual-checks.ps1` are re-run before the remediation commit's gate.
