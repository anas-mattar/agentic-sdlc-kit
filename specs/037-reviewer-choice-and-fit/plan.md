# Implementation Plan: Reviewer choice and pull-time fit

**Branch**: `037-reviewer-choice-and-fit` | **Date**: 2026-10-18 | **Spec**: specs/037-reviewer-choice-and-fit/spec.md
**Input**: Approved feature specification (Q1 pull and Q2 advisory decided by the owner, 2026-10-18) + decisions P1 to P10 below
**Gate Batching**: none
**Gate Certification**: user-run
**Status**: Draft, awaiting the owner's approval of decisions P1 to P10

## Summary

Two things change, in four phases. A Critical team-arm feature's reviewer is no longer the owner's unilateral
pick: the reviewer **pulls** the review by pushing a claim ref under their own name (a new command,
`scripts/claim-review.ps1`), and the Critical evidence check refuses a review whose Reviewer has no valid claim.
And `repos`, which the roster has carried since feature 021 and nothing reads, gets its first and only reader:
`scripts/claim-feature.ps1` can be told which roadmap row the claim is for and prints one advisory note when the
row's declared repositories are outside the claimant's. Both ride the ledger a claim already lives on (remote
refs on `origin`), add no coordinator, and print nothing in a project with no roster. Phase 1 builds the claim
and its reader, phase 2 makes the check read it, phase 3 adds the fit note, phase 4 is guidance, flow-down,
measurement and the roadmap. The lessons of 013, 021, 029 and 036 govern: one shared reader, a named state for
every read that can fail, fixtures that differ in one condition, and a measurement on real clones.

## Technical Context

**Language/Version**: PowerShell 7+ (`pwsh`)
**Primary Dependencies**: none new
**Storage**: files and git refs on `origin` only; no database, no new file format outside `kit-adoption.json`'s
existing roster and an optional roadmap column
**Testing**: the enforcement harness (`tests/enforcement/`): real temporary git repositories, hand-written
expectations, a failing and a passing fixture per rule, the coverage sweep over every emission site. Every
existing case passes unchanged except where P5 names a line the team arm now prints.
**Target Platform**: any runner with `pwsh` and `git`
**Project Type**: governance tooling (scripts plus documents)
**Constraints**: the solo arm and a project with no roster print and fail exactly as before (spec FR-003, FR-011);
no coordinator and no queue (FR-013); every read of git that can fail has a named state (the GAP-027/034/035
lesson), never an empty list; the fit note never changes an exit code (Q2)
**Scale/Scope**: one reader and two helpers in `scripts/adoption-lib.ps1`, one new script, one parameter pair on
`scripts/claim-feature.ps1`, one function extended in `scripts/enforcement-pack.ps1`, about thirty fixture cases,
five documents, digests

## Constitution Check

- [x] **Specification First (I)**: the spec is approved (anas.m, 2026-10-18); this plan follows it; `tasks.md` follows once the plan is approved. No code before approval.
- [x] **Source of Truth (II)**: no conflict found. `docs/sdlc/team-workflow.md` section 3 step 4 and `docs/sdlc/critical-delivery.md` say the owner picks the reviewer and that `repos` is read by nothing; both are rewritten in phase 4 (spec FR-015), not silently chosen. The 021 notes record that (b) and (c) were deferred as assignment authority; this plan reads them as the spec does, a visible choice and not an assignment.
- [ ] **Repository Separation (III)**: not applicable, the kit is one repository.
- [x] **Architecture Consistency (IV)**: the roster stays read through `Get-DeveloperMode` (013, 021); ledger reads sit beside the existing ones (`roadmap-claim-check.ps1`, `claim-feature.ps1`, `territory-check.ps1`); the one new script follows `claim-feature.ps1`'s shape (`Stop-Refused`, preflight, push).
- [ ] **Domain Invariants (V)**: not applicable, the kit has no domain-invariants pack.
- [x] **Security (VI)**: nothing sensitive is read or written; a claim carries a name already in the roster and the git identity the committer already publishes. The plan states that a claim proves neither (P9).
- [ ] **External Integration Governance (VII)**: not applicable; `origin` is the claim ledger the kit already uses.
- [x] **Testing Requirements (VIII)**: every new behaviour has a failing and a passing fixture, written first and shown failing on the parent commit; new emission sites are covered by the sweep.
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI review with Reviewer Provenance.
- [x] **Controlled Delivery (X)**: four phases, one at a time; the change touches an enforcement member, so the owner runs the gate: no batching, no ci-held.

**Phase sizing rule**: phase 1 adds a command and a reader that no check calls yet, so it changes no verdict and
is useful alone (a reviewer can already pull). Phase 2 depends on 1 and is the only phase that moves a verdict.
Phase 3 is independent of 1 and 2 (it reads the roster and the roadmap, not the review ledger). Phase 4 is
documents and a measurement and depends on all three. Reverting 4, 3, 2, 1 in order leaves a consistent kit.

**Post-design re-check**: no new violation. P2 (the claim ref shape), P4 (which readings fail and which are
UNGRADED) and P8 (the roadmap column) are decisions of the owner, approved or changed by approving this plan.

## Decisions

**P1: the review claim is a remote ref, one per reviewer per feature (FR-001, FR-013).** The ledger is `origin`'s
branches, as for a feature claim. A review claim is the ref `refs/heads/review/<feature>/<slug>`, where
`<feature>` is the claim's `NNN-name` and `<slug>` is the claimant's roster name slugged (P3). It never matches
the pattern every existing ledger reader uses (`refs/heads/(\d{3,}-\S+)$`, in `roadmap-claim-check.ps1`,
`claim-feature.ps1` and `territory-check.ps1`), so no feature counter, number allocator or territory comparison
sees it; phase 1 pins that with a fixture per reader. The ref points at one commit whose tree is the feature
tip's tree and whose parent is the feature tip, with the message `review claim: <feature> by <roster name>`; its
author is the git identity of whoever pushed it. No coordinator, no queue, no file anyone must write for
others to proceed (FR-013): taking a review is one push, and nothing else changes.

**P2: the reader and the command (FR-001, FR-004, FR-006).** `scripts/adoption-lib.ps1` gains one reader,
`Get-ReviewClaims -Root -Feature`, so the check and the command cannot disagree about what a claim is (the 013
lesson). It returns `Failed`/`Cause` (named, never an empty list that reads as "no claims"; the GAP-036 recipe)
and `Claims`, each `@{ Slug; Sha; AuthorName; AuthorEmail }`. A tip it cannot read the author of (the commit is
not in the clone and a fetch of the ref does not supply it) makes the whole reading `Failed` with that cause.
`scripts/claim-review.ps1 -Feature <NNN-name> [-As <roster name>] [-Json]` is the only writer: it refuses (own
message, exit 1, through `Stop-Refused`) outside a repository, with no origin, when the ledger cannot be read,
when the feature is not on origin, when no team roster is declared (the solo arm has no use for a claim), when
`-As` (default: the git `user.name`) is not on the roster or is denied Critical approval, or when the push is
rejected; it exits 0 saying "already claimed" if the claim exists. It never selects or proposes a reviewer.

**P3: the slug, and the comparison it needs (FR-002, FR-005).** A ref name cannot hold every character a
roster name can. `slug(name)` is the name trimmed, lower-cased, every character outside `[a-z0-9._-]` replaced
by `-`, runs collapsed, leading and trailing `-` and `.` removed. A claim is the claim of the roster entry whose
slug equals the ref's. Two roster entries that slug alike are ambiguous: the reader marks both unusable for
claims and the check names them (a roster fix), never picks one. The 021 comparison is unchanged for the
Reviewer string in the review file (trim, exact, case-insensitive): the claim check runs after it, on the
roster entry it found.

**P4: where the grading sits and what each state is (FR-001 to FR-006a).** In `Invoke-CriticalTeamEvidence`
(`scripts/enforcement-pack.ps1`), after the 021 conditions, and only when the Reviewer passed them (a stranger,
the Owner and a denied reviewer are named as before and the claim is not graded a second time, FR-005). The
claim check is the only caller of the ledger read in the pack. States, in the pack's vocabulary:

| Reading | Verdict |
|---|---|
| a claim whose slug is the Reviewer's, whose slug is not the Owner's, and whose commit author is not the Owner (name or email local-part, slugged) | counts: nothing added |
| the only claim by the Reviewer names the Owner, or was authored under the Owner's name | failure: it does not count (FR-002), the line names which |
| no claim by the Reviewer | failure: names the feature, the Reviewer and `scripts/claim-review.ps1` as the repair |
| no claim by anyone and the artifact is missing | the existing "is missing" failure gains one clause: the review is unclaimed and how to claim it (FR-006a); nothing is assigned |
| no origin, or the ledger or a claim's author cannot be read | `UNGRADED` line with the cause, exit unchanged (FR-004); never read as a pass |
| ambiguous roster slugs | `UNGRADED` line naming both entries |

The solo arm never reaches this code. Nothing in the check reads a date: an abandoned claim stays a claim, and
reclaiming one is a second person pulling (guidance, P10), as a stale feature claim is adopted by a new owner.

**P5: what existing output changes (FR-003, SC-001).** Only the team arm, and only where the claim is graded
(a Critical feature merge-ready on a project with a roster). A team-arm fixture whose review is valid under 021
now also needs a claim on origin or it prints the `UNGRADED` no-origin line (a fixture with no origin) or fails;
phase 2 updates each such fixture's recipe, with the pass fixtures gaining a claim and a new fail fixture per
reading in the table. A project with no roster, one developer, or no Critical feature sees no change, and the
adopted-project clones are measured to show it (P10). FitForge, the only adopted team-arm project, is the one
whose first red run the update note predicts.

**P6: the fit reading: one function, one reader of `repos` (FR-007 to FR-012).** `adoption-lib.ps1` gains
`Get-RepoFit -Roster -Claimant -Repos`, a pure function: given the roster, who is claiming and the row's declared
repositories it returns `Match`, `Partial` (with the uncovered names and the roster developers who cover them),
`NoDeclaration`, or `Unplaced` (with the strings compared, FR-010). It is the only place in the kit that reads a
roster entry's `repos`; the `roadmap-claim-check.ps1` and `enforcement-pack.ps1` readings stay as they are
(FR-009). A repository nobody lists is `Partial` with "no one declared it". Comparison is by name, trimmed and
case-insensitive, as the roster's names are.

**P7: how a claim is told which row (FR-007, FR-008, FR-011).** At pick time the roadmap row is the only document
a candidate feature has, and `claim-feature.ps1` is given a description, not a row. It gains two optional
parameters: `-Row <text>` (a fragment of the row's first cell; exactly one row must match) and `-As <roster
name>` (default: the git `user.name`). Without `-Row` the script is byte-identical (FR-011), including its
output and its exit codes. With `-Row`, and a roster with `repos` for the claimant, it prints at most one note
before it allocates and then proceeds exactly as today: `Fit`, naming the row, the uncovered repositories and
who covers them. A `-Row` that matches no row or several, a table with no `Repos` column, a roadmap that cannot be
read, or a claimant not on the roster are each one named line (`UNGRADED`-style: the reading was not made and
the line says why, FR-010, FR-012), never a clean silence. No exit code of the claim changes.

**P8: the roadmap `Repos` column (FR-007).** An optional column named `Repos` in the roadmap table; a cell holds
repository names separated by commas, in the names `codeRepos` uses. A row with an empty or `—` cell, and a
table with no such column, declare nothing and are never screened. `roadmap-claim-check.ps1` finds `Status` and
`Owner` by header name, so an extra column changes none of its readings; phase 3 proves it with a fixture on a
table that has the column. `specs/_templates/roadmap-template.md` documents it. The kit's own roadmap does not
need the column (a single repository).

**P9: what a claim and a fit note are, and are not (FR-016, spec Assumptions).** Both are written claims. A claim
shows that someone with write access to `origin` pushed a ref carrying a roster name; the author test catches the
careless shape (the owner pushing it from their own identity) and nothing more, because the roster has no
mapping from a name to a git identity and this plan adds none. It does not show who the person is, that the
review happened or that it was independent; the fit note does not show who is claiming. The guidance says so
beside the rule, in the 021 manner, and the limit is recorded in `notes.md`.

**P10: guidance, flow-down, roadmap, digests, measurement (FR-014, FR-015, SC-001, SC-005).**
`docs/sdlc/team-workflow.md` (section 3 step 4 rewritten, a subsection beside the 021 one for the claim and the
fit note), `docs/sdlc/critical-delivery.md` (item 5 and the roster paragraph, including that `repos` now has a
reader), `specs/_templates/roadmap-template.md` (the `Repos` column), `adoption/updating.md` (a flow-down note:
which files flow, the first red run for a team-arm project, that no roster means no change), `docs/roadmap.md`
(the row shipped, the GAP-024 inventory row closed with what stays open, a decisions-log entry). Digests
rebuilt by `scripts/build-digests.ps1` only. The measurement runs the checks on fresh clones of FitForge,
FlowBoard and ExpenseTracker (the 021 method) and reports every verdict that moved; if a clone is unavailable
the measurement is reported as not made, with the reason, and is not replaced by a synthetic number. No
constitution amendment: the independence rule of IX and X is graded more tightly, not changed (recorded in
`notes.md` as a T-level check).

## Phases

Detailed tasks and the per-phase **Territory** blocks go in `tasks.md`.

1. **The claim and its reader.** P1 to P3. `Get-ReviewClaims` and the slug in `scripts/adoption-lib.ps1`,
   `scripts/claim-review.ps1`, the harness recipe fields it needs, fixtures `CRV-*` for every refusal and the
   success, and the fixtures that pin that no existing ledger reader sees a `review/` ref. Delivers FR-013, the
   first half of FR-001 and FR-006. Changes no verdict.
2. **The check reads the claim.** P4 and P5. The team arm of the Critical evidence check grades the claim and
   the unclaimed-review clause; existing team-arm fixtures updated, one failing and one passing fixture per
   row of the P4 table. Delivers FR-001 to FR-006a and SC-002 and SC-004 for (b).
3. **Pull-time fit.** P6 to P8. `Get-RepoFit`, the roadmap row reader, `-Row` and `-As` on
   `scripts/claim-feature.ps1`, the template's `Repos` column, fixtures `FIT-*`. Delivers FR-007 to FR-012 and
   SC-003 and SC-004 for (c).
4. **Guidance, flow-down, roadmap, measurement.** P9 and P10. Delivers FR-014 to FR-016, SC-001, SC-005.

## Risks and limits, stated rather than hidden

- A claim is a written claim: anyone with push access can write any slug, and the roster maps no name to a git
  identity, so the author test catches only the owner's own identity. Said in the guidance (P9).
- An unreadable ledger is `UNGRADED`, not red (spec FR-004): a Critical team feature can reach merge with that
  line on an offline CI. The line names the cause; gate 6, the human review, stands behind it, as for
  `roadmap-claims`.
- An abandoned claim keeps counting until another person's review replaces it. The check reads no dates.
- `Get-Roadmap`-style table reading now exists in two places (`roadmap-claim-check.ps1` and the new reader in
  the lib). They are not merged here: 021's binding rules are subtle and the new reader needs only the first
  cell and one column. Recorded for a later feature.
- The fit note depends on the claimant being placed on the roster by name; a git `user.name` that is not a roster
  name (`Anas M.` against `anas.m`) reads nothing and says so.
- `scripts/claim-review.ps1` does not compare the claimant with the feature's Owner: the Owner is named in the
  roadmap row and the review file, and binding the row at claim time would copy 021's binder. The check refuses
  the Owner's own claim at grading time instead (P4).
- The update-agent-context step of the plan workflow was not run: it rewrites `CLAUDE.md`, a kit-owned law
  document, and this plan adds no technology to record.

## Project Structure

### Documentation (this feature)

```text
specs/037-reviewer-choice-and-fit/
├── spec.md
├── plan.md              # this file
├── research.md          # alternatives weighed for P1, P4, P7
├── data-model.md        # claim, slug, fit result
├── quickstart.md        # how to see each behaviour working
├── contracts/           # claim-review CLI, claim-feature -Row/-As, roadmap Repos column
├── checklists/
├── tasks.md             # next, via /speckit.tasks
└── notes.md             # baseline, probes, the measurement
```

### Source Code (repository root)

```text
scripts/adoption-lib.ps1                         # Get-ReviewClaims, slug, Get-RepoFit, roadmap row reader
scripts/claim-review.ps1                         # new: the only writer of a review claim
scripts/claim-feature.ps1                        # -Row and -As, the advisory Fit note
scripts/enforcement-pack.ps1                     # Invoke-CriticalTeamEvidence reads the claim
tests/enforcement/rules.json                     # CRV-*, FIT-*, the changed team-arm anchors
tests/enforcement/cases/                         # new and updated fixtures
tests/enforcement/lib/FixtureRepo.psm1           # recipe fields for planting review claims
specs/_templates/roadmap-template.md             # the optional Repos column
docs/sdlc/team-workflow.md                       # guidance
docs/sdlc/critical-delivery.md                   # guidance
adoption/updating.md                             # flow-down note
docs/roadmap.md                                  # row, GAP-024 row, decisions log
docs/digests/                                    # regenerated by scripts/build-digests.ps1
```

**Structure Decision**: one new script, in the place and shape of `claim-feature.ps1`; every shared reading
lives in `scripts/adoption-lib.ps1`, where the roster already does, so the command, the check and the doctor
cannot drift (013, 021).

## Complexity Tracking

No constitution violations.
