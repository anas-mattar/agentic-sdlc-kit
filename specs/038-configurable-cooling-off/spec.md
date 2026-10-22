# Feature Specification: Configurable cooling-off period

**Feature Branch**: `038-configurable-cooling-off`
**Created**: 2026-10-22
**Status**: Approved (anas.m, 2026-10-22)
**Delivery Level**: Standard
**Rationale Rule**: 1
**Input**: User description: "Make the Critical solo-mode cooling-off period configurable instead of the hardcoded 24 hours. The project owner sets it project-wide in kit-adoption.json. Accepted values: presets 2, 4, 8, 24, or a custom whole number of hours at or above a minimum floor, so it cannot be set to 0 and silently disabled. Default when undeclared or unusable stays 24 (fail-closed, as the developers roster does). Any value below 24h must require a recorded one-line justification and print a visible warning in the CriticalEvidence output so the weaker control is auditable. Applies only to the solo arm; the team arm is unchanged. The cooling-off clock semantics are unchanged."

## Background

`docs/sdlc/critical-delivery.md` item 5 lets a solo developer substitute a written second-model review plus a
**24-hour cooling-off period** for the independent human reviewer a Critical feature otherwise needs. The 24 is a
single constant in the enforcement pack (`CoolingOffHours`); a project cannot change it without editing the kit's
own script, which an adopted project must not do (`adoption/updating.md`).

Twenty-four hours is the right default for regulated or high-risk work, but it is a blunt instrument for a project
whose Critical features are small, or whose solo developer works in a single sitting and would rather wait two hours
than a day. Today the only way to get a shorter wait is to hand-edit the script, which silently weakens the control
with no record. This feature gives the project owner a declared, bounded, auditable way to choose the period, and
keeps the strict value as what every undeclared or malformed record gets.

The period only ever applied to the **solo arm** (zero or one declared developer). The team arm requires a committed
`human-pr-review.md` by a Reviewer who is not the Owner and has no cooling-off. That arm is not touched.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Choose a shorter period and have it enforced (Priority: P1)

A project owner on a solo Critical feature declares a shorter cooling-off period, with a one-line reason, in the
project's adoption record. The enforcement pack then requires that many hours between the second-model review's first
commit and the merge, instead of 24.

**Why this priority**: this is the whole request. Without it the period is still a hardcoded constant.

**Independent Test**: on a solo Critical fixture with `second-model-review.md` first committed 5 hours ago, declare
`coolingOffHours: 4` with a reason and confirm the CriticalEvidence check passes; declare `8` and confirm it fails
naming 8h and the 3 hours remaining.

**Acceptance Scenarios**:

1. **Given** a solo Critical feature whose review was first committed 5 hours ago and a record declaring 4 hours with a
   reason, **When** the enforcement pack runs, **Then** CriticalEvidence passes.
2. **Given** the same feature and a record declaring 8 hours with a reason, **When** the pack runs, **Then**
   CriticalEvidence fails and the message names the declared period, the elapsed time and the hours remaining.
3. **Given** a record declaring 24 (or declaring nothing), **When** the pack runs, **Then** behaviour is identical to
   today, including the failure message text for a review under 24 hours old.

---

### User Story 2 - A weaker period is visible and justified (Priority: P1)

Anyone reading the pack output, including a reviewer or auditor, can see when a project is running below the 24-hour
default and why.

**Why this priority**: the control is being weakened on purpose. If it can be weakened silently, the change is a
regression in auditability rather than a feature.

**Independent Test**: declare `coolingOffHours: 2` with a reason and confirm the pack output carries a warning that
names the value and quotes the reason, and still exits as it would without the warning; remove the reason and confirm
the pack applies 24 and says the shorter value was not honored.

**Acceptance Scenarios**:

1. **Given** a declared value below 24 and a non-blank reason, **When** the pack runs on a solo Critical feature,
   **Then** the output contains a warning naming the period in effect and the recorded reason, and the warning does
   not by itself fail the run.
2. **Given** a declared value below 24 and a missing or blank reason, **When** the pack runs, **Then** 24 hours
   applies, and the output says the declared value was not honored and why.
3. **Given** a declared value of 24 or more, **When** the pack runs, **Then** no warning is printed and no reason is
   required.

---

### User Story 3 - A malformed value can never switch the control off (Priority: P1)

A typo, a zero, a negative number, a fraction, a string or a null in the field cannot shorten or remove the wait.

**Why this priority**: the fail-closed fallback is what makes making the value configurable safe.

**Independent Test**: for each of `0`, `-3`, `1.5`, `"eight"`, `null`, `true`, an array and an object, run the pack and
confirm 24 hours applies and the doctor names the field as unusable.

**Acceptance Scenarios**:

1. **Given** a value that is not a whole number of hours at or above the floor, **When** the pack runs, **Then** 24
   hours applies.
2. **Given** the same record, **When** the adoption doctor runs, **Then** it reports the malformed field, states that
   24 hours is what applies, and says how to fix it.
3. **Given** a record that cannot be read at all, **When** the pack runs, **Then** 24 hours applies, as for the
   developers roster today.

---

### User Story 4 - The team arm and the clock are untouched (Priority: P2)

A project that declares two or more developers, or any project that never declares the field, sees no change.

**Why this priority**: guards against the feature widening beyond its brief.

**Independent Test**: run the existing team-arm and solo-arm fixtures unchanged and confirm identical output.

**Acceptance Scenarios**:

1. **Given** two or more declared developers and any value of the field, **When** the pack runs, **Then** the team arm
   is graded exactly as today, with no cooling-off applied and no warning printed.
2. **Given** any accepted value, **When** the period is computed, **Then** the clock still starts at the first commit
   of `second-model-review.md` and a later revision of that file does not restart it.

### Edge Cases

- A value above 24 (for example 48): accepted, stricter than the default, no reason required, no warning.
- A value exactly at the floor of 1: accepted, treated as below 24, so a reason is required and the warning prints.
- A decimal that is a whole number in value (`4.0`): read as the whole number 4.
- A value written as a string (`"8"`): not a number; unusable, so 24 applies.
- A reason present with a value of 24 or more, or with no value: ignored, and the doctor notes the reason is unused.
- A reason that is only whitespace: counts as blank.
- A Critical feature in a team-mode project that also has the field declared: the field is unused for grading; the
  doctor reports that it has no effect in team mode.
- `second-model-review.md` committed but period shortened afterwards: the new period is applied against the same
  first-commit time; no retroactive restart.

## Level Rationale *(mandatory — answers the four Critical triggers, in writing)*

- **domain-invariants**: does not apply — the kit has no domain-invariants pack; this feature changes one numeric setting read by the kit's own enforcement check.
- **irreversible-data**: does not apply — no migration or operation drops or rewrites data; every change is a check, a document, a fixture or a record field.
- **authn-authz-payment**: does not apply — it reads a number and a sentence from the adoption record and proves no identity; it adds no authentication, authorization or payment flow.
- **auditable-evidence**: does not apply — no regulator, auditor or contract asks the kit for evidence; the independence rule it grades is the kit's own, and the guidance states that the recorded reason is a written claim, not proof.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The solo-arm cooling-off period MUST be read from the project's adoption record as a single
  project-wide value of hours.
- **FR-002**: A value MUST be accepted when it is a whole number of hours at or above a floor of 1. The documented
  presets are 2, 4, 8 and 24; any other whole number at or above the floor is a custom value and is equally valid.
- **FR-003**: When the field is absent, null, or unusable (zero, negative, fractional, non-numeric, boolean, array,
  object, or below the floor), the period MUST be 24 hours.
- **FR-004**: When the adoption record is missing, unreadable or malformed as a whole, the period MUST be 24 hours.
- **FR-005**: A declared value below 24 MUST be accompanied by a non-blank one-line reason in the adoption record. When
  the reason is missing or blank, the period MUST be 24 hours and the pack output MUST say that the declared value was
  not honored and why.
- **FR-006**: When a value below 24 is in effect, the CriticalEvidence output MUST print a warning naming the period in
  effect and quoting the recorded reason. The warning MUST NOT by itself change the pass or fail result.
- **FR-007**: A value of 24 or more MUST require no reason and print no warning.
- **FR-008**: The CriticalEvidence failure message for a review that is too recent MUST name the period in effect, the
  elapsed time and the hours remaining. With the default 24 it MUST be word-for-word the message in use today.
- **FR-009**: The clock MUST be unchanged: it starts at the first commit of `second-model-review.md`, and revising that
  file does not restart it.
- **FR-010**: The team arm (two or more declared developers) MUST be unchanged: no cooling-off, no warning, no new
  requirement.
- **FR-011**: The adoption doctor MUST report a malformed field, a below-24 value with a missing reason, an unused
  reason, and a field that has no effect because the project is in team mode. Each report states the period that
  applies and the fix.
- **FR-012**: `docs/sdlc/critical-delivery.md` item 5, its "What the machine checks" paragraph and its digest marker
  MUST describe the configurable period, the floor, the default, the reason requirement and the warning, and MUST keep
  the honesty sentence that the solo substitute is a mitigation and not independence. `docs/digests/critical-digest.md`
  MUST be regenerated, not hand-edited.
- **FR-013**: `adoption/updating.md` MUST document the field, its accepted values, the reason field and the fallback,
  and MUST say what an adopted project sees on its first run after updating.
- **FR-014**: Fixtures MUST cover every accepted and rejected shape named in FR-002 to FR-007 and the edge cases above,
  and the existing solo-arm and team-arm fixtures MUST still pass unchanged.

### Key Entities

- **Cooling-off setting**: the project-wide number of hours, held in the adoption record. Attributes: value, optional
  reason. Meaningful only in the solo arm.
- **Cooling-off reason**: a one-line written justification for a period below 24. Required below 24, ignored otherwise.
- **Period in effect**: the hours the pack actually applies after the fallbacks above; always at least 1 and
  equal to 24 whenever anything is missing or unusable.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A project owner can move a solo project from 24 hours to any accepted value by editing one field and one
  reason in a single file, with no change to any kit script.
- **SC-002**: In every fixture where the field is absent, unusable or unjustified, the period applied is 24 hours
  (100% of the unusable shapes listed in User Story 3 and FR-003).
- **SC-003**: Every pack run that applies a period below 24 hours prints a warning that quotes the reason; there is no
  passing run below 24 hours whose output omits it.
- **SC-004**: All fixtures that existed before this feature produce byte-identical pack output after it.
- **SC-005**: The doctor, run on a record with each malformed shape, names the field and the period that applies in
  every case.

## Assumptions

- The kit's own constitution mentions 24 hours only in a historical bump rationale, not as a normative rule, so no
  constitution amendment is needed. The normative rule lives in `docs/sdlc/critical-delivery.md` item 5.
- The setting is project-wide, as decided by the owner; there is no per-feature override.
- The floor of 1 hour is a design choice of this feature; its only job is to rule out 0 and negatives, and the reason
  requirement is what makes shorter values accountable.
- There is no upper bound. A larger value is stricter than the default and is the owner's choice.
- A written reason is a claim, not proof. The doctor and pack can check that one exists and is not blank, not that it
  is a good reason; that remains for human review.
- Who may edit the adoption record is a matter of the project's own review process, not this feature.
- Field names and exact message wording are decided in `plan.md`.
- Out of scope: per-feature periods, changing the team arm, changing what the second-model review must contain, and
  any other constant in the enforcement pack's configuration.
