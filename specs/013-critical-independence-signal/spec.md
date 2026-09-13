# Feature Specification: Critical Independence Signal

**Feature Branch**: `013-critical-independence-signal`
**Created**: 2026-09-10
**Status**: Approved 2026-09-10 (owner: anas.m)
**Delivery Level**: Standard
**Input**: User description: "Make the Critical independent-approval evidence match the law: second-model substitute only when the project is solo"

## Context

`docs/sdlc/critical-delivery.md` item 5 states one requirement and one accommodation:

> **Independent approval** — the human reviewer MUST NOT be the feature's owner
> (`docs/sdlc/team-workflow.md`). **A solo developer substitutes**: a written second-model
> adversarial review … and a minimum **24-hour cooling-off period** …

The requirement is independence. The second-model review and the cooling-off are what a solo
developer does *instead*, and the constitution's own amendment record names them "the
**Critical-solo** review substitute" — so the conditionality is not a reading, it is what the
law says.

`Invoke-CriticalEvidenceCheck` in `scripts/enforcement-pack.ps1` requires the substitute
**unconditionally** for any feature whose `spec.md` declares Critical. It has no way not to:
nothing in `kit-adoption.json` records how many developers a project has, so the check chose the
strict side and the consequence was never written down.

The consequence arrived with the first Critical feature declared in any adopted project —
FitForge 002, authentication and authorization, reviewed by the second of that project's two
developers. Its branch cannot go green. The only two ways past the check are to write a
`second-model-review.md` recording a substitution that did not happen, or to declare the feature
Standard and leave the lane. **Both are worse than the gap.**

This is the inverse of the failure feature 012's reviews taught the kit to hunt. That one was
silently green — a check that could not fail. This one is loudly red where the law is satisfied,
and it is the more dangerous shape: a check that cannot legitimately pass does not merely fail to
protect, it actively teaches people to route around the strictest lane in the kit.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A team project's Critical feature can go green honestly (Priority: P1)

A project with more than one developer runs a Critical feature. The owner writes it, a different
developer reviews it, and the branch's checks pass on that evidence — with no artifact describing
a substitution that did not occur.

**Why this priority**: it is the gap. Until this works, the kit's strictest lane is unusable as
written by exactly the projects best equipped to use it.

**Independent Test**: on a fabricated repository declaring two developers, a Critical feature with
a completed independent review passes `enforcement-pack.ps1`; the same feature without one fails.

**Acceptance Scenarios**:

1. **Given** an adoption record naming two or more developers, **When** a Critical feature has its
   independence artifact complete, **Then** the Critical-evidence check passes and does not ask
   for `second-model-review.md`.
2. **Given** the same record, **When** the independence artifact is absent, **Then** the check
   fails and names what is missing and why.
3. **Given** the same record, **When** the independence artifact records a reviewer who is the
   feature's owner, **Then** the check fails — this is the requirement item 5 actually makes.

### User Story 2 - A solo project is unchanged (Priority: P1)

A single-developer project runs a Critical feature and is asked for exactly what it is asked for
today: a second-model adversarial review, and 24 hours between recording it and merging.

**Why this priority**: the fix must not weaken the case the substitute was written for. A
regression here would be a silent downgrade — the failure shape 012 named.

**Independent Test**: on a fabricated repository declaring one developer, the existing behaviour
reproduces exactly, including the cooling-off arithmetic and its message.

**Acceptance Scenarios**:

1. **Given** an adoption record naming one developer, **When** a Critical feature lacks
   `second-model-review.md`, **Then** the check fails exactly as it does today.
2. **Given** that file recorded less than the cooling-off window ago, **Then** the check fails and
   reports the hours remaining, as today.

### User Story 3 - An adoption that says nothing keeps today's behaviour (Priority: P1)

An existing adopted project that has never heard of this feature updates the kit. Its Critical
features are checked exactly as before.

**Why this priority**: three projects have adopted this kit and none of their records carry the
new field. A default that relaxed the check would turn a red check green in projects that never
asked — the exact silent downgrade this kit has already been bitten by four times in one feature.

**Independent Test**: on a fabricated repository whose `kit-adoption.json` has no developer
information (and again with the field present but malformed), the check behaves as it does today.

**Acceptance Scenarios**:

1. **Given** no adoption record at all, **Then** the strict (solo) rule applies.
2. **Given** a record with no developer information, **Then** the strict rule applies.
3. **Given** a record whose developer information is malformed or empty, **Then** the strict rule
   applies **and** the doctor reports the malformation — silently falling back is how a project
   ends up in a mode nobody chose.

### Edge Cases

- A record naming exactly one developer — solo, unambiguously.
- A record naming two developers where both features are owned by the same person.
- A record naming developers whose handles do not match the identities used in the roadmap or the
  review document. **Decided 2026-09-10: this case is disclosed, not enforced.** The roster is
  counted to select the mode and is never compared against Reviewer or Owner, so a review naming
  two people absent from the roster passes. Cross-checking free text against free text would read
  as verification while providing none. Both fresh-context reviewers judged the **behaviour**
  correct; the logic reviewer judged the disclosure in `scripts/enforcement-pack.ps1`'s header
  sufficient on its own, while the docs reviewer required this entry to be amended rather than
  left standing as an unmet MUST — which is why it was. An earlier draft of this paragraph
  credited both reviewers with the first position; that was a misstatement of a reviewer's
  judgement in a document whose purpose is to record them. The original wording of this
  entry ("must fail loudly rather than pass by accident") described behaviour the feature does
  not have, and an unmet MUST is the wrong thing to leave standing in this feature of all
  features. **Amendment approved by**: anas.m, 2026-09-10.
- A Critical feature on a branch whose main-side roadmap row is missing or still reads `idea`
  (feature 011 makes this an error, but the two checks must not deadlock each other).
- A project that grows from one developer to two mid-feature, or shrinks.
- A `second-model-review.md` present in a team project — permitted extra evidence, never a
  substitute for the independent review, and never a reason to skip it.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `kit-adoption.json` MUST gain an optional field naming the project's developers. Its
  exact name and shape are a `plan.md` decision; it MUST be an array so that a later feature can
  use the same field for a roster (GAP-004's pipelining WIP check needs one) without a second
  source of truth.
- **FR-002**: The Critical-evidence check MUST select its evidence mode from that field: **solo**
  when the project declares one developer, **team** when it declares two or more.
- **FR-003**: When the field is absent, empty, malformed, or unreadable, the check MUST apply the
  **solo** rule — the strict one. No configuration, and no absence of configuration, may relax the
  check relative to today's behaviour.
- **FR-004**: In solo mode the check MUST behave exactly as it does today: `second-model-review.md`
  exists, has git history, and was first committed at least the configured cooling-off hours ago,
  with the same messages.
- **FR-005**: In team mode the check MUST require a machine-checked independence artifact and MUST
  NOT require `second-model-review.md` or any cooling-off period.
- **FR-006**: The team-mode artifact MUST establish that **the human reviewer is not the feature's
  owner** — item 5's actual requirement. Where the reviewer identity and the owner identity are
  read from is a `plan.md` decision; both MUST be read from committed artifacts, never inferred
  from the identity of whoever runs the check.
- **FR-007**: The check MUST state honestly, in its own documentation, how strong the team-mode
  comparison is. Comparing two names written by the same team is evidence of the same strength as
  the Reviewer Provenance block — it converts a silent omission into a written claim a human can
  falsify — and it MUST NOT be described as more than that.
- **FR-008**: No mode may leave item 5 unenforced by any machine. Removing the substitute for team
  projects without putting a checked artifact in its place would close GAP-020 by opening a
  GAP-019-shaped hole, and is explicitly out of bounds.
- **FR-009**: `scripts/verify-kit.ps1` MUST validate the new field when present — type, shape, and
  entry format — and MUST report a malformed value rather than let it silently select strict mode.
- **FR-010**: `docs/sdlc/critical-delivery.md` item 5 MUST state which artifact each mode requires
  and where the mode comes from, so the law and the check can be read against each other. The
  wording of the requirement itself MUST NOT change — this feature enforces item 5 correctly, it
  does not amend it.
- **FR-011**: `adoption/updating.md` MUST tell an existing adopted project how to declare the field
  and what changes when it does, including that declaring one developer changes nothing.
- **FR-012**: The change MUST be provable against fabricated repositories covering every mode and
  every degenerate record, as feature 012's cross-repo check was.

### Key Entities

- **Adoption record** (`kit-adoption.json`) — already carries `topology`, `tiers`, `codeRepos` and
  `gateProof`; gains the developer declaration. Project-owned (surgical), so an adopter edits it
  and `update-kit.ps1` never overwrites it.
- **Evidence mode** — solo or team, derived from the record and never stored. Derived rather than
  declared so a project cannot claim team independence while naming one developer.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: FitForge's feature 002 — a Critical feature in a two-developer project — passes the
  Critical-evidence check on its genuine cross-review, with no `second-model-review.md` present.
- **SC-002**: A fabricated solo project reproduces today's behaviour exactly, message for message,
  including the cooling-off remainder arithmetic.
- **SC-003**: Every degenerate record (absent file, absent field, empty array, wrong type, entries
  of the wrong shape) selects the strict rule, and the malformed cases are reported by the doctor.
- **SC-004**: No path through the new code can make a Critical feature pass with neither a
  second-model review nor an independent-review artifact. Demonstrated by a fabricated case for
  each mode with its artifact removed.
- **SC-005**: `pwsh -File scripts/ritual-checks.ps1` exits 0 locally and in CI, with digests
  regenerated if any digest marker moved.
- **SC-006**: The three adopted projects' existing records are untouched by this feature and their
  behaviour is unchanged — verified, not assumed.

## Assumptions

- The developer declaration is trusted the way `codeRepos` and `gateProof` are trusted: it is a
  statement the project makes about itself. A project that declares two developers and has one has
  weakened its own Critical lane, and no check the kit can write would detect that. This is stated
  rather than solved, because the alternative — inferring team size from commit authorship — is
  wrong in exactly the case that matters, an agent committing as its owner.
- Cooling-off hours remain a constitutional constant at 24 and are not touched here.
- No constitutional amendment is expected: item 5's requirement is unchanged, and the constant the
  constitution sync-lists is unchanged. If `plan.md` finds otherwise, the amendment rides alone on
  its own `docs/` branch before implementation, per team-workflow rule 7.

## Out of scope

- Any use of the developer roster beyond selecting this check's mode. GAP-004's pipelining WIP
  check is the obvious second consumer and is deliberately left to its own feature — FR-001 only
  requires that the field's shape not preclude it.
- Strengthening the reviewer-versus-owner comparison beyond the Reviewer Provenance block's
  strength. That is GAP-019's territory, and FR-007 requires honesty about the limit rather than
  a fix for it here.
- Any change to what Critical requires. This feature makes the machine agree with the law; it does
  not move the law.
