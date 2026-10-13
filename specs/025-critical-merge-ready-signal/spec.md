# Feature Specification: A merge-ready signal for a Critical feature that a commit subject cannot give

**Feature Branch**: `025-critical-merge-ready-signal`
**Created**: 2026-10-13
**Status**: Approved (anas.m, 2026-10-13) — option A chosen
**Amendment approved by**: anas.m, 2026-10-13
**Delivery Level**: Standard
**Rationale Rule**: 1
**Input**: User description: "The roadmap row opened by feature 024: a better merge-ready signal for a Critical feature than commit-subject phase tokens (an explicit owner-set marker in the plan, or the completeness of tasks.md's ticks, or the review artifact's own commit). Feature 024's heuristic misreads phases that land out of order or are never named, so it reaches only part of the one real Critical feature's history."

## Background

Feature 024 (GAP-022) stopped a Critical feature's branch being red from its first commit by reading, from commit subjects, whether the
final phase has landed: a phase token at or above the highest declared phase means "final landed", a token below it means
"mid-feature". It was measured on clones of the three adopted projects and found to reach only part of the one real Critical feature,
FitForge 002: warns at 17 of its 43 commits, is wrongly strict at 19 (its phase 11 was done before phases 4 to 9), strict with a printed
reason at 4, and strict at 3 others. The harness was green throughout; the fixtures had been built from the kit's own conventions and the
field has neither (`specs/024-critical-branch-not-red/notes.md`, "T009").

This feature replaces the guess with a statement. The question the check cannot answer from subjects, "has the work finished?", is one
the owner can answer in one line, and an owner's answer can carry a recorded approver.

**What the real data says about the candidates** (FitForge 002, `tasks.md` at each of its 43 commits, read-only):

| Candidate signal | What FitForge 002 shows | Verdict |
|---|---|---|
| All tasks ticked (`- [x]`, no `- [ ]`) | Open tasks fall 102 → 1 across phases 1 to 10, rise when amendments add phases 12 to 17, and **end at 6, never 0**: six tasks stay open on purpose (two Vitest cases, two route-protection items, a Visual Compliance Loop, and T100, "file the human review", which is the independence artifact itself). | Rejected: it would never fire on the one real Critical feature at its end. |
| Every declared phase has tasks | Phases 14, 15 and 16 are **declared with no tasks at all** (placeholders for work not yet written), and phases 1 to 6, 11, 12, 13 and 17 are fully ticked. | Rejected: "declared" and "to do" are different things in a real `tasks.md`. |
| The review artifact is committed | Already used by feature 024: once `human-pr-review.md` exists the arm grades it. | Kept, but it is the last step, so it cannot be the only signal. |
| An explicit owner declaration | Not measurable, because no feature has one; but it is the only candidate that does not depend on how a team happens to write its commits or its task list. | Proposed. |

## Decision for the owner

**Recommendation: a `**Merge Readiness**` line in `plan.md`'s header** (the place `**Gate Batching**` and `**Gate Certification**`
already live, read by the same pack), with two values: `pending` and `ready`. It is read from the **committed** `plan.md` at `HEAD`.

| Marker | The check does |
|---|---|
| absent | Exactly what feature 024 does today. No existing feature changes. |
| `pending` | The independence artifact is not yet due: one `WARNING: CriticalEvidence: ... is not yet due` line while the arm's artifact is not committed; once it is committed the arm grades it, as today. **Overrides** the commit-subject heuristic in both directions, so a feature that runs phases out of order is not read as final early. |
| `ready` | The arm grades the artifact exactly as for a merge-ready branch, whatever the commit subjects say. |
| anything else, or two lines | Strict, with a `not treated as mid-feature` line naming the problem. |

**Why this is not a new honour system.** A change to an approved `plan.md` already requires a recorded approver
(`**Amendment approved by**: <name>, <date>` in the amended section and the same name in the commit message; constitution I, Amendment
authority; `scripts/enforcement-pack.ps1`, AmendmentAuthority). Flipping `pending` to `ready` is therefore a plan amendment, so "this feature is
done and the independence review is now owed" becomes a **recorded human act**, not a pattern in a subject. Nothing new has to be built to
carry the approval; the spec's job is to prove it does (a fixture where an unapproved flip fails). This holds for every commit the check grades; a merge commit is not graded (FR-006).

**Amendment approved by**: anas.m, 2026-10-14

**The cost, stated up front.** `pending` is a claim. An owner who sets it and never flips it merges with only a warning on this check:
the machine does not demand the artifact, and gate 6, the human review at merge, is the only thing that does. That is feature 024's
disclosed hole in a different form (there: a final commit that names no phase). It is made visible rather than closed: the warning prints
on every run, the declaration and its approver are in the diff the human reviewer reads, and the flip to `ready` is the moment the
approval is recorded. Alternatives the owner may prefer:

| | Shape | Cost |
|---|---|---|
| A (recommended) | The marker, as above, overriding the heuristic | An owner can leave `pending`; gate 6 stands behind it |
| B | The marker, but a final-phase token still forces strict even under `pending` | Safer, and it re-breaks FitForge 002 (its phase 11 read as final too soon is exactly this case) |
| C | No marker; keep 024 and accept it reaches part of the history | Nothing built; the known limit stays |

## User Scenarios & Testing *(mandatory)*

### User Story 1 - An owner declares the feature mid-flight and the branch stops being red for it (Priority: P1)

An owner of a Critical feature whose phases land out of order adds `**Merge Readiness**: pending` to the plan (with the recorded
approver). From then on the branch warns, not fails, for the not-yet-due artifact, whatever the commit subjects look like.

**Why this priority**: it is the case feature 024 could not reach: 19 of FitForge 002's 43 commits.

**Independent Test**: a fixture shaped like FitForge 002 (a high-numbered phase done early, `tasks:`-style subjects, duplicate amendment
headings) with the marker `pending`: `WARN`, exit 0; the same fixture without the marker: strict, as feature 024 left it.

**Acceptance Scenarios**:

1. **Given** a Critical branch whose plan declares `pending` and whose subjects name the final phase, **When** the pack runs, **Then** it
   prints the not-yet-due warning and does not fail on the artifact.
2. **Given** the same branch with the marker removed, **Then** it is strict, as today.
3. **Given** `pending` and a committed artifact that is invalid, **Then** the arm fails it, as today.

---

### User Story 2 - Flipping to `ready` is a recorded approval, and cannot be done by the agent alone (Priority: P1)

**Why this priority**: the marker is only worth having if turning the relaxation off, or on, cannot be done silently.

**Independent Test**: a fixture where `pending` becomes `ready` in a commit with no approver record fails the amendment-authority check;
with the record it passes.

**Acceptance Scenarios**:

1. **Given** a plan amended from `pending` to `ready` without an approver, **When** the pack runs, **Then** AmendmentAuthority fails on that commit.
2. **Given** the amendment with `**Amendment approved by**: <name>, <date>` and the name in the commit message, **Then** it passes and the
   arm grades the artifact (missing: fails).

---

### User Story 3 - Nothing changes for a feature that declares nothing, and adopters are told (Priority: P2)

**Independent Test**: every feature 024 fixture passes unchanged; a flow-down note exists in the shape of 024's.

**Acceptance Scenarios**:

1. **Given** a Critical branch with no marker, **Then** its output is byte-identical to feature 024's.
2. **Given** a Standard, Lite or Micro feature carrying the marker, **Then** it is ignored and the output is unchanged.

---

### Edge Cases

- Two `**Merge Readiness**` lines, a value other than `pending` or `ready`, or the line inside a comment, a fence or a code span: strict
  with a reason (a comment hides the line the way a renderer would, so it is read as absent, and absent means feature 024's behaviour).
- The marker on a Critical feature in a shallow clone: it is read from the committed blob and needs no history, so `pending` still warns
  and `ready` still grades; the history-dependent states of feature 024 are bypassed by an explicit declaration, and the notes say so.
- `ready` with no artifact committed fails exactly as today. `ready` is not "approved", only "owed now".
- A `plan.md` that is not committed or unreadable: feature 024's behaviour.
- A feature that sets `pending` and the heuristic would have warned anyway: no difference.
- The roadmap row, the digests and the flow-down note are updated as for every kit feature.

## Level Rationale *(mandatory — answers the four Critical triggers, in writing)*

- **domain-invariants**: does not apply — the kit has no domain-invariants pack; this changes when a script reports a verdict.
- **irreversible-data**: does not apply — nothing is migrated, dropped or rewritten.
- **authn-authz-payment**: does not apply — no authentication, authorization or payment is touched.
- **auditable-evidence**: does not apply — the independence artifact stays mandatory at merge and the arm that grades it is not edited; the feature changes how the check learns that the artifact is owed, and puts that declaration under the existing amendment-authority record. The reviewer should falsify this claim specifically, as for feature 024: `pending` is a claim the owner makes and can leave in place.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A Critical feature's `plan.md` MAY declare `**Merge Readiness**: pending` or `**Merge Readiness**: ready` as one header line.
  `scripts/enforcement-pack.ps1` MUST read it from the committed `plan.md` at `HEAD`, through the visibility reader the pack already uses for
  plan headers (comments, fences and code spans hide it).
- **FR-002**: `pending` MUST make the check warn, not fail, for the arm's missing artifact, with one `WARNING: CriticalEvidence: ... is not
  yet due` line, whatever the commit subjects, the heading numbers or the history say; and MUST NOT suppress the arm's grading of an
  artifact that is committed.
- **FR-003**: `ready` MUST make the check behave exactly as for a merge-ready branch: the arm's own grading, with its existing messages.
- **FR-004**: An absent marker MUST leave feature 024's behaviour byte-identical (SC-001). A malformed marker (an unknown value, two lines)
  MUST be strict and say why.
- **FR-005**: The marker MUST be ignored on a feature that is not Critical.
- **FR-006**: Changing the marker MUST be graded by the existing amendment-authority check: a fixture MUST show an unapproved change failing
  and an approved one passing. If the check does not reach a plan header line, this feature MUST say so and extend it, not assume. The check reaches the line for every commit it grades; it does not grade merge commits (feature 014, D7), and this feature states that limit instead of extending the check (owner decision, phase 1 review F1).
- **FR-007**: Each of FR-001 to FR-006 MUST gain a failing and a passing fixture written first and shown failing on the parent, including a
  fixture shaped like FitForge 002; each new rule is inventoried in `tests/enforcement/rules.json`.
- **FR-008**: `docs/sdlc/critical-delivery.md`, `docs/sdlc/definition-of-done.md` (if it states when the artifact is demanded),
  `adoption/updating.md` (a flow-down note) and `docs/roadmap.md` MUST say what the check now does and what stays open; digests are
  regenerated by `scripts/build-digests.ps1`, never by hand.
- **FR-009**: The measurement MUST be run on clones of the three adopted projects with the real FitForge 002 history, and MUST say plainly
  what it does and does not show: the marker does not exist in that history, so the replay injects it, and an injected marker proves the
  mechanism works on real shapes, not that the owner will use it.

### Key Entities

- **Merge-readiness declaration**: the `**Merge Readiness**` header line of a Critical feature's `plan.md`, `pending` or `ready`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every feature 024 fixture (34 cases) passes unchanged, and a Critical branch with no marker prints byte-identical output.
- **SC-002**: On FitForge 002's real history, with `pending` injected at plan approval, the check warns at every commit that does not
  carry the artifact, where feature 024 warned at 17 of 43; and with `ready` injected at the last commit it demands the artifact.
- **SC-003**: An unapproved `pending` to `ready` change fails the amendment-authority check; an approved one passes.
- **SC-004**: The full harness passes with every pre-existing case unchanged and no unowned emission site.

## Assumptions

- The amendment-authority check grades a change to a `plan.md` header line as it grades any other change to an approved plan. The plan
  verifies this first; if it does not, extending it is in scope (FR-006).
- `**Merge Readiness**` is a new plan header field, like `**Gate Certification**`; no constitution amendment is expected, and the plan
  confirms by reading constitution X for any sentence that fixes the set of plan header fields.
- A project that does not want the marker loses nothing: absence is feature 024.
- Feature 024's heuristic stays as the default for features that declare nothing, deliberately; replacing it would change every adopted
  project at once for no measured gain.
