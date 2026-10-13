# Feature Specification: A Critical feature's branch is not red from its first commit

**Feature Branch**: `024-critical-branch-not-red`
**Created**: 2026-10-13
**Status**: Approved (anas.m, 2026-10-13) — shape B chosen
**Amendment approved by**: anas.m, 2026-10-13
**Delivery Level**: Standard
**Rationale Rule**: 1
**Input**: User description: "GAP-022: a Critical feature's branch is red from its first commit to its last, because Invoke-CriticalEvidenceCheck demands the independence artifact (human-pr-review.md in team mode, second-model-review.md plus the cooling-off in solo mode) on every commit, though that artifact cannot legitimately exist until the final phase is written and reviewed. Decide the shape at spec: gate on merge-ready, WARN until the final phase and FAIL at the merge commit, or move to a merge-time check."

## Background

`Invoke-CriticalEvidenceCheck` (`scripts/enforcement-pack.ps1`) runs on every commit of a Critical feature's branch.
It selects an arm from the adoption record (`Get-EvidenceMode`): the **team** arm requires a committed
`specs/NNN-name/human-pr-review.md` with a Review Provenance block, and the **solo** arm requires a committed
`second-model-review.md` whose first commit is at least `CoolingOffHours` old. Both are demanded from the first commit.

Neither artifact can exist then. `docs/sdlc/definition-of-done.md` item 6 puts the human review "once per feature, at
merge", after the final phase and items 1 to 5; the solo substitute reviews the finished work. So `ritual-checks` fails
from spec approval onward, for every phase, on a member whose subject does not yet exist. Observed on FitForge 002 (ten
phases, Critical): the one member failing at phase 1 was the review artifact for code that had not been written. An owner
trained that red is normal stops reading a seven-member verdict, and the other six members (doc-lint, scope-check,
scope-repos, digests, roadmap-claims, verify-kit) are the ones a Critical feature most needs read on every phase.

This is GAP-020's family, a check that cannot legitimately pass, in its milder form: it can pass, but only once, at the end.
It predates feature 013, which changed *which* artifact the check wants and not *when*.

**The trap to avoid.** The whole kit's recorded lesson (012, 014, 015, 027) is that a check which goes quiet where it
should speak is worse than a noisy one. Any relaxation here must not become "Critical branches are never held to the
independence artifact": the artifact stays mandatory *at merge*, and a branch whose merge-readiness cannot be determined
stays strict.

## Decision for the owner

Three shapes are on the GAP-022 row. **Recommendation: B, with A's signal.**

| | Shape | What it costs |
|---|---|---|
| A | Gate the check on the branch being **merge-ready** (red only then) | Needs a mechanical merge-ready signal; silent before it, so a forgotten artifact is first seen at the end |
| B | **WARN** before merge-ready, **FAIL** at merge-ready | Same signal as A, plus one visible `WARN` line per run, so the pending artifact is audible on every phase without being red |
| C | Move it out of `ritual-checks` into a merge-time check | It is no longer the command CI runs on every push, and a new check is new machinery |

B is recommended because it keeps the check's subject visible (the owner is reminded each phase what the merge will need)
while giving back a trustworthy red. A is B without the reminder; C changes what `ritual-checks` means (constitution X
lists it as the one command CI runs) and is the largest change for no extra assurance.

**Merge-ready, as proposed.** A Critical feature's branch is merge-ready when its `tasks.md` declares N phases and the
branch carries a commit for phase N (the same `phase N` subject convention `scripts/scope-check.ps1` already reads). Before
that, the artifact is pending; from the final-phase commit on, it is owed. Unreadable or absent `tasks.md`, an
undeterminable final phase number, or a history the check cannot read: **strict** (the check behaves exactly as it does
today), and says why in its message.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Phases 1 to N-1 of a Critical feature can be green (Priority: P1)

An owner pushes phase 1 of a Critical feature. `ritual-checks` reports the six other members and the critical-evidence
member honestly: the independence artifact is *pending*, said once, as a `WARN`, and the run is not red for it.

**Why this priority**: the red signal is the product. Ten phases of a red member that means nothing is how a real failure
in another member goes unread.

**Independent Test**: a fixture Critical branch with `tasks.md` declaring 3 phases and a `phase 1` commit, no review
artifact: the evidence member emits `WARN` and the run exits 0 where it exited 1.

**Acceptance Scenarios**:

1. **Given** a Critical feature, `tasks.md` declaring 3 phases and a branch tip at `phase 2`, **When** the enforcement
   pack runs, **Then** the evidence member prints a `WARN` naming the pending artifact and the run does not fail on it.
2. **Given** the same feature at `phase 3` (the final phase) with no artifact, **When** it runs, **Then** it fails with the
   message it fails with today.
3. **Given** the final phase and a committed, valid artifact, **When** it runs, **Then** it passes, as it does today.

---

### User Story 2 - The relaxation cannot be used to skip the artifact (Priority: P1)

**Why this priority**: GAP-020's lesson and 014's: a relaxation that lets the strict lane pass without its evidence closes
this gap by opening a worse one.

**Independent Test**: each way of making merge-readiness *undeterminable* (no `tasks.md`, no phase numbers, unreadable
history) keeps today's FAIL.

**Acceptance Scenarios**:

1. **Given** a Critical feature with no `tasks.md`, **When** the enforcement pack runs without the artifact, **Then** it
   fails as today.
2. **Given** a `tasks.md` that declares phases but a branch with no `phase N` commit at all, **When** it runs, **Then** it
   fails as today (nothing says the work is not already finished).
3. **Given** a branch merged or about to merge to `main` (the merge-time run), **When** it runs without the artifact,
   **Then** it fails.
4. **Given** the solo arm, **When** the branch is not merge-ready, **Then** the cooling-off is not demanded either, and
   when it is merge-ready both the file and the cooling-off are demanded exactly as today.

---

### User Story 3 - Adopters are told what changes (Priority: P2)

`scripts/enforcement-pack.ps1` flows down verbatim, and a Critical feature in an adopted project (FitForge 002) is the case
it changes. The update note says that a branch that used to be red mid-feature now warns, and what still fails.

**Independent Test**: the flow-down note exists in the shape of feature 022's and 023's, and a clone of each adopted
project's non-Critical branches grades identically before and after.

---

### Edge Cases

- A feature declared Critical whose `tasks.md` is amended mid-feature to add a phase: the final phase moves, the branch
  stops being merge-ready, the check goes back to `WARN`. That is correct, and the amendment-authority check (014) already
  grades who approved the added phase.
- Batched gates are not allowed on Critical, so phase numbers are one-to-one with commits.
- Standard, Lite and Micro features are untouched: the check returns for any level but Critical.
- Merge commits and remediation commits (`phase N: remediation …`) count as phase commits when they carry the subject, as
  they do for `scope-check.ps1`.
- A Critical feature on `main` itself is not a feature branch and is not graded (as today).

## Level Rationale *(mandatory — answers the four Critical triggers, in writing)*

- **domain-invariants**: does not apply — the kit has no domain-invariants pack; this changes when a script reports a verdict.
- **irreversible-data**: does not apply — no data is migrated, dropped or rewritten.
- **authn-authz-payment**: does not apply — no authentication, authorization or payment is touched.
- **auditable-evidence**: does not apply — the independence artifact stays mandatory at merge; this feature moves *when* the check reports it pending, not whether the evidence is required, and the check stays strict wherever merge-readiness cannot be shown. The reviewer should falsify this claim specifically (Reviewer Provenance, constitution IX).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: For a Critical feature in either arm, while the branch is **not** merge-ready, `Invoke-CriticalEvidenceCheck`
  MUST NOT fail for the absence or immaturity of the independence artifact, and MUST emit one `WARN` line naming the
  artifact the merge will need and the phase that makes the branch merge-ready.
- **FR-002**: Once the branch is merge-ready, the check MUST behave exactly as it does today: same conditions, same
  messages, same order, in both arms (the team arm's committed-blob, roster and attestation rules; the solo arm's file
  and cooling-off).
- **FR-003**: Merge-readiness MUST be derived mechanically from the committed `tasks.md` (declared phase count) and the
  branch's `phase N` commits, and MUST default to **not-proven-pending**: any case where it cannot be determined (no
  `tasks.md`, no phase numbers, unreadable history, shallow clone) MUST keep today's failure, with the reason in the message.
- **FR-004**: The change MUST NOT alter a non-Critical feature's grading or any other enforcement member.
- **FR-005**: Each of FR-001 to FR-003 MUST gain a failing and a passing fixture in `tests/enforcement/`, written first and
  shown failing on the parent commit, each new rule inventoried in `tests/enforcement/rules.json`; the `WARN` state is a
  fixtured outcome like any other (the harness's verdict vocabulary, feature 015).
- **FR-006**: `docs/sdlc/critical-delivery.md` (item 5 and the evidence paragraph), `docs/sdlc/definition-of-done.md`
  item 6 and any digest marker that states when the artifact is demanded MUST say what the check now does; digests are
  regenerated by `scripts/build-digests.ps1`, never by hand.
- **FR-007**: `adoption/updating.md` MUST gain a flow-down note (what was wrong, what it does now, what flows down, what
  may newly be seen, what does not change, what to do), and `docs/roadmap.md` MUST close GAP-022, record the decision, and
  mark this feature's row `shipped`.

### Key Entities

- **Merge-ready**: a Critical feature's branch whose `tasks.md` declares N phases and which carries a `phase N` commit.
- **Pending artifact**: the independence artifact of the active arm, required at merge and not yet due.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On a fixture Critical feature of three phases, the enforcement pack exits 0 with one `WARN` at phases 1 and
  2, and exits 1 at phase 3 without the artifact, in both arms.
- **SC-002**: Every way of making merge-readiness undeterminable (FR-003) keeps exit 1, each with a fixture.
- **SC-003**: With a valid artifact at the final phase, the run is byte-identical to today's.
- **SC-004**: The full harness passes with every pre-existing case unchanged, and the coverage report shows no unowned site.

## Assumptions

- `tasks.md` is where the phase count lives (`## Phase N:` headings), and the `phase N` commit subject is the convention
  `scripts/scope-check.ps1` already relies on; this feature reads them and does not invent a new marker. The plan
  confirms the exact heading and subject grammar against the existing readers and reuses them rather than adding a third.
- Whether the merge-time run (a PR into `main`) is distinguishable from a branch push is a plan question; if it is not,
  the final-phase commit is the only signal and the check is strict from there, which is the safe direction.
- The shape is B (WARN, then FAIL), approved by the owner on 2026-10-13. A change to A or C would change FR-001 and
  need a recorded re-approval before further work (constitution I, Amendment authority).
