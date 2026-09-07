# Feature Specification: Adoption Doctor

**Feature Branch**: `007-adoption-doctor`
**Created**: 2026-09-08
**Status**: Draft
**Delivery Level**: Standard
**Input**: User description: "Adoption doctor — verify-kit.ps1, a machine audit of an adopted
project's kit integrity: slots filled, structure intact, gate proven, tier rulebooks
instantiated, .kit-version sane; runs post-init, post-update, and in adopted-project CI
(GAP-011)"

## Problem

An adopted project's kit integrity is currently verified socially, one incident at a time
(roadmap GAP-011). The field record shows what that costs:

- **Partial installs drift silently** (field-feedback #2): a copy that skipped
  dot-directories loses the `/speckit.*` commands and the agent improvises its own
  structure. `doc-lint.ps1` now fails fast on missing kit essentials, but only when someone
  runs it.
- **Instantiation quality is a failure surface**: `init-kit.ps1` fills the mechanical slots
  and prints the judgment slots that remain — but nothing ever comes back to check that a
  human actually filled them. A project can run features for weeks with an unratified
  constitution, an undefined gate, or an empty stack profile, and every governance document
  that references those slots silently lies.
- **Post-flow-down damage is caught by the next incident** (GAP-006/GAP-007 were both
  instances): after `update-kit.ps1` refreshes verbatim files, nothing audits that the
  project as a whole still hangs together — that adoption-doc references still resolve
  against locally deleted templates, that `.kit-version` matches reality.
- **Declared tiers are recorded nowhere**: `init-kit.ps1` asks for the project's tiers,
  instantiates rulebooks, wires CLAUDE.md — and forgets the answer. No later check can ask
  "does every declared tier still have its rulebook?" because the declaration lives only in
  the long-gone interactive session.

The kit's own thesis applies: an integrity rule that is checked only by discipline
eventually isn't checked. The verification pack (006) machine-checked the *feature ritual*;
this feature machine-checks the *adoption itself*.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - One-command integrity audit of an adopted project (Priority: P1)

As the owner of an adopted project, I want a single command that audits my project's kit
integrity — structure essentials present, every slot filled where law requires it,
constitution ratified, gate defined and proven, a rulebook for every declared tier,
`.kit-version` sane — and reports every failure at once with a fix pointer per finding, so
that a broken adoption is a red verdict I can act on, not a surprise three features later.

**Why this priority**: The audit is the product; the hooks (US2) and CI wiring (US3) only
decide *when* it runs. Alone, it already converts every known adoption-integrity incident
class from "discovered socially" to "named by a machine".

**Independent Test**: Run the doctor against a healthy adopted fixture → green verdict,
exit 0. Break one dimension at a time (delete a kit essential; leave a `{{SLOT}}` in a
project-owned governance file; leave the constitution unratified; remove a declared tier's
rulebook; corrupt `.kit-version`) → each produces a named finding with a fix pointer and a
non-zero exit, and multiple simultaneous breaks are all reported in one run.

**Acceptance Scenarios**:

1. **Given** a fully adopted project (slots filled, constitution ratified, gate proof
   recorded, rulebooks present, `.kit-version` valid), **When** the doctor runs, **Then**
   it reports every dimension as healthy and exits clean.
2. **Given** a project-owned governance file with an unfilled `{{SLOT}}` or `TODO(...)`,
   **When** the doctor runs, **Then** it fails naming the file, the slot, and the adoption
   step that owns filling it.
3. **Given** a constitution whose version/ratification fields are still template
   placeholders, **When** the doctor runs, **Then** it fails with a pointer to the
   ratification step — and a filled constitution passes regardless of its version number.
4. **Given** a declared tier with no instantiated rulebook (deleted or never created),
   **When** the doctor runs, **Then** it fails naming the tier and the expected rulebook
   path.
5. **Given** no recorded gate proof, **When** the doctor runs, **Then** it fails pointing
   at the "define and PROVE the gate" adoption step; **Given** a recorded proof (command +
   exit code + date), **Then** that dimension passes.
6. **Given** the kit repository itself (no `.kit-version`), **When** the doctor runs,
   **Then** it declines with a clear "this is the kit, not an adoption" message rather
   than reporting false findings.

---

### User Story 2 - The lifecycle hooks: init writes the record, init and update end with the doctor (Priority: P2)

As an adopter, I want `init-kit.ps1` to durably record the decisions it asked me for
(project name, topology, tiers) in a machine-readable adoption record, and I want both
`init-kit.ps1` and `update-kit.ps1` to finish by telling me the doctor's verdict, so the
audit has a source of truth for "declared" and runs at exactly the moments integrity is
most likely to have changed.

**Why this priority**: Without a durable declaration record, US1's tier check has nothing
trustworthy to compare against; without the hooks, the doctor joins the pile of checks run
by discipline. P2 only because the record format and the audit must exist first.

**Independent Test**: Run `init-kit.ps1` non-interactively on a fresh kit copy → the
adoption record exists with the chosen name/topology/tiers, and the init output ends with
a doctor verdict (red at this moment — judgment slots are deliberately still open, and the
verdict says which). Run `update-kit.ps1` against an adopted fixture → the report ends
with the doctor's verdict for the target.

**Acceptance Scenarios**:

1. **Given** an init run selecting tiers backend+database, **When** it completes, **Then**
   the adoption record holds exactly those tiers plus name/topology/date, and the doctor
   later verifies rulebooks against that record.
2. **Given** an adopted project whose owner adds a tier later, **When** they update the
   adoption record and instantiate the rulebook, **Then** the doctor passes — the record
   is owner-editable, not init-only.
3. **Given** an `update-kit.ps1` apply run, **When** it finishes, **Then** the target's
   doctor verdict is part of the output, so flow-down damage (the GAP-006/007 class)
   surfaces in the same terminal session that caused it.
4. **Given** a pre-007 adopted project (no adoption record), **When** the doctor runs,
   **Then** the tier check degrades to a warning telling the owner how to create the
   record — never a hard failure for existing adoptions (grandfather posture).

---

### User Story 3 - The doctor in the adopted project's CI (Priority: P3)

As an adopting team, I want the ritual-checks CI (which the kit already ships) to include
the doctor in adopted projects, so integrity regressions — someone deletes a rulebook,
reverts a slot fill, hand-edits `.kit-version` — turn the branch red with zero human
initiation.

**Why this priority**: The delivery vehicle for US1, same relationship as 006's US3 to its
US1. P3 because local + hooked runs already close most of the gap.

**Independent Test**: In an adopted fixture with the kit's CI wrapper, break one integrity
dimension on a branch → the ritual checks fail naming the doctor's finding; in the kit
repository itself, the wrapper's behavior is unchanged (doctor not applicable).

**Acceptance Scenarios**:

1. **Given** an adopted project running the kit's ritual-checks wrapper, **When** any
   integrity dimension regresses, **Then** the wrapper's verdict block includes the doctor
   as a failing member.
2. **Given** the kit repository itself, **When** ritual-checks runs, **Then** the doctor
   is skipped as not-applicable and the wrapper's member list says so — kit CI behavior is
   otherwise unchanged.

---

### Edge Cases

- **The kit repo vs adopted project**: `.kit-version` presence is the discriminator the
  kit already uses (doc-lint's manifest sweep). The doctor must not produce findings
  against the kit template, where unfilled slots are the product.
- **Deliberately deleted optional content**: tier templates are a menu — deleting
  unselected templates is legal (GAP-007 resolution). The doctor checks only *declared*
  tiers' instantiated rulebooks, never template presence.
- **Single-repo projects that removed constitution principle III**: legal manual edit
  (init-kit prints it as a human step) — the doctor must not require any particular
  principle count.
- **Judgment slots immediately after init**: a red verdict at init-end is correct and
  expected (the human steps are still open); the doctor's output must read as a to-do
  list, not a malfunction.
- **Gate proof staleness**: the proof records that the gate was green at least once
  (adoption step 3's "a gate that has never been green is not a gate") — the doctor
  verifies existence and shape, not freshness; CI green on every push is the freshness
  mechanism.
- **Adoption record edited by hand into an invalid state** (unknown tier name, missing
  field): a named finding, not a crash.
- **Multi-repo adoptions**: the doctor audits the repository it runs in (the governance
  repo carries the kit); cross-repo checks are out of scope, matching update-kit's
  single-target model.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The kit MUST ship a doctor script that audits an adopted project across five
  dimensions — structure essentials, slot completeness in project-owned governance files,
  constitution ratification fields, gate proof, declared-tier rulebooks, and
  `.kit-version` sanity — reporting every failure in one run, each with the owning
  adoption step or document as a fix pointer, exit non-zero on any failure.
- **FR-002**: The doctor MUST refuse to audit the kit repository itself (no
  `.kit-version` and kit-identity present), with a message, not findings.
- **FR-003**: `init-kit.ps1` MUST write a machine-readable adoption record (project name,
  topology, declared tiers, init date, kit version at init) at a documented path, and the
  record MUST be owner-editable with its shape documented.
- **FR-004**: The doctor MUST verify a rulebook exists for every tier declared in the
  adoption record; absent the record (pre-007 adoption), this dimension degrades to a
  warning with creation instructions.
- **FR-005**: Adoption step 3's "prove the gate" MUST gain a recorded artifact (gate
  command, exit code, date, recorded-by) at a documented location, and the doctor MUST
  verify its existence and shape.
- **FR-006**: `init-kit.ps1` MUST finish by running the doctor (replacing today's
  doc-lint-only finish) and `update-kit.ps1` MUST end its apply-mode report with the
  target's doctor verdict; both surface the verdict without masking their own exit
  semantics (update-kit's documented exit codes are unchanged).
- **FR-007**: The ritual-checks wrapper MUST include the doctor as a member in adopted
  projects and skip it as not-applicable in the kit repository; local and CI verdicts stay
  identical by construction (006 FR-008 inherited).
- **FR-008**: The doctor MUST remain read-only over the audited project — it reports; it
  never repairs.
- **FR-009**: All new files and amendments MUST be classified in `kit-manifest.json`
  (verbatim vs surgical), and adoption docs (greenfield, existing-system, updating) MUST
  name the doctor at the steps where it runs.
- **FR-010**: Every check dimension MUST be exercised by seeded healthy/broken fixtures
  with recorded verdicts (constitution VIII posture, 002/006 precedent).

### Key Entities

- **Adoption record**: machine-readable file written by init (name, topology, tiers, init
  date, kit version), owner-editable thereafter; the source of truth for "declared".
- **Gate proof**: recorded evidence that the project gate was green at least once
  (command, exit code, date, recorded-by).
- **Doctor verdict**: per-dimension findings (healthy / finding + fix pointer / warning /
  not-applicable) plus one overall exit code.
- **Kit-integrity essentials**: the existing required-paths set (doc-lint) — reused, not
  redefined.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every adoption-integrity incident class in the field record to date (partial
  install, unfilled judgment slots, deleted declared-tier rulebook, post-flow-down
  breakage) is detected by the doctor in seeded-fixture tests, each finding carrying a fix
  pointer — 100% of seeded breaks named, zero false findings on the healthy fixture.
- **SC-002**: An adopter can go from "something feels off" to a complete named list of
  integrity problems with one command in under a minute, instead of discovering issues one
  incident at a time.
- **SC-003**: Both lifecycle moments that change integrity (init, kit update) end with a
  doctor verdict in the same terminal session — demonstrated on fixtures for both.
- **SC-004**: In an adopted project's CI, an integrity regression turns the existing
  ritual-checks verdict red with the doctor named as the failing member; the kit
  repository's own CI behavior is unchanged (member list shows the doctor as
  not-applicable).
- **SC-005**: Pre-007 adoptions run the doctor without hard failures caused solely by the
  feature's new artifacts (missing adoption record / gate proof degrade to warnings with
  instructions), so the next kit flow-down cannot break existing projects' CI.

## Assumptions

- The doctor is a kit-shipped verbatim script like its siblings (PowerShell 7, git +
  built-ins only, no new dependencies), named `scripts/verify-kit.ps1` per the roadmap row.
- `.kit-version` presence remains the adopted-project discriminator (doc-lint precedent);
  a project adopted by copy without ever running update-kit may create it per documented
  instructions — the doctor's message covers this case.
- The adoption record and gate proof are new project-owned (surgical-class) files; their
  paths and shapes are design decisions for plan/research, not spec-level commitments.
- "Project-owned governance files" for slot completeness = the surgical-class set in
  `kit-manifest.json` — the doctor reuses the manifest classification rather than
  inventing a second list (single source of truth).
- Existing doc-lint checks are not duplicated: the doctor may invoke or subsume them, but
  path resolution and manifest completeness remain doc-lint's job; the boundary is pinned
  in research.
- Grandfather posture throughout: new artifacts warn (with instructions) on pre-007
  adoptions; hard failures are reserved for things that were always law (structure,
  slots, tier rulebooks against an existing record).
- The CI story rides the existing `ritual-checks` wrapper/workflow rather than shipping a
  second workflow (006 supersession lesson: one check name, one code path).
