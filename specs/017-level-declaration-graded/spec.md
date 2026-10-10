# Feature Specification: Level Declaration Graded

**Feature Branch**: `017-level-declaration-graded`  
**Created**: 2026-10-11  
**Status**: Approved 2026-10-11 (owner: anas.m)  
**Delivery Level**: Standard  
**Input**: User description: "Close GAP-023: a Level Rationale block in spec.md answering the four Critical triggers explicitly; criticalSurfaces path globs in the adoption record; and an enforcement-pack check that fails a sub-Critical Delivery Level whose Territory intersects those surfaces, reusing feature 012's repo-aware path reading"

## Context

A feature's **Delivery Level** decides how much rigour it gets: Standard needs the owner's gate
and review; Critical adds a rollback plan, independent approval and a cooling-off
(`docs/sdlc/critical-delivery.md`). Every enforcement check reads the level and acts on it.
No check grades it. The only validation is spelling: an unfilled or off-menu value fails, and
nothing else does. A spec declaring Standard on a feature that rewrites authentication is green
by construction.

The criteria exist and are good. `docs/sdlc/critical-delivery.md` lists four Critical triggers:
domain-invariant rules, irreversible or destructive data operations, authentication,
authorization or payment flows, and anything a regulator, auditor or contract can ask evidence
for. But the implementing session applies them alone, at feature creation, before the plan,
the Territory block or the data model exist, and every level up costs real ceremony. The
incentive runs downhill.

Enforcement is lopsided the same way. Micro has a machine floor (five territory files, 400
lines, one phase) that forces promotion. Standard to Critical has no trigger at all, only the
prose instruction to stop and promote.

This is a shape, not a sighting. No misdeclaration has been observed; FitForge 002 declared
Critical correctly. Feature 013's lesson still applies from the other side: a check that
cannot legitimately pass pushes teams out of the strictest lane, and under-declaration is the
same loss arriving silently, from the side no machine watches. So this feature must add a
check that **can** pass honestly, with a written way to do it.

Two fixes, because a path check alone cannot see intent and a rationale alone cannot be
falsified:

- **A written claim.** The spec states, per trigger, whether it applies and why. A reviewer
  can falsify a written claim; they cannot falsify a silent omission (the move Reviewer
  Provenance made for gate 5).
- **A machine floor.** The adoption record names the project's critical surfaces as path
  globs. A sub-Critical feature whose Territory touches one fails, unless the spec carries a
  written, approved exception.

Feature 012 already taught a check to read the declared code repositories as sibling working
trees and to resolve repo-prefixed Territory paths. This feature reuses that reading rather
than building a second one.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A feature that touches a critical surface cannot sit below Critical unnoticed (Priority: P1)

An owner declares a feature Standard. Its Territory includes a path the project listed as a
critical surface, such as the authentication module. The ritual checks fail, naming the
feature, the level, the Territory path and the glob it matched, and saying how to proceed:
promote the feature to Critical, narrow the Territory, or record an approved exception.

**Why this priority**: This is the gap itself. Without it the declared level remains the only
rigour decision nothing grades.

**Independent Test**: In a fixture repository whose adoption record lists one surface glob,
declare a Standard feature with a Territory path under it and run the checks; the run fails
with the message above. Change the level to Critical, or move the path out; the run passes.

**Acceptance Scenarios**:

1. **Given** a Standard feature whose Territory contains a path matching a critical-surface
   glob, **When** the enforcement checks run, **Then** they fail and name the feature, the
   level, the offending path and the glob.
2. **Given** the same feature declared Critical, **When** the checks run, **Then** this check
   passes (the Critical lane's own checks apply as before).
3. **Given** a Micro feature whose Territory matches a critical-surface glob, **When** the
   checks run, **Then** it fails the same way (Micro is sub-Critical).
4. **Given** a Standard feature whose Territory matches no glob, **When** the checks run,
   **Then** this check passes and prints nothing it did not print before.
5. **Given** a multi-repo project whose Territory is repo-prefixed and whose globs are written
   in the same form, **When** the checks run, **Then** a path in a nested code repository is
   matched exactly as it is for the governance repository.

---

### User Story 2 - The level choice is a written claim a reviewer can falsify (Priority: P1)

A new spec carries a **Level Rationale** block that answers each of the four Critical triggers
with applies or does not apply, and one sentence of reason. An owner who calls a feature
Standard has to write, in the spec, why it touches no domain invariant, no irreversible data
operation, no authentication, authorization or payment flow, and nothing an auditor can ask
about. A reviewer reading the spec sees the claim next to the level.

**Why this priority**: The path check cannot see intent. A feature may be Critical in kind and
sit under no declared glob. The rationale is the only place that kind of misdeclaration
becomes a statement someone can dispute.

**Independent Test**: Run the checks on a spec with no Level Rationale, an incomplete one, and
a complete one; the first two fail and name what is missing, the third passes.

**Acceptance Scenarios**:

1. **Given** a numbered feature on the Standard template with no Level Rationale block,
   **When** the checks run, **Then** they fail and say the block is required.
2. **Given** a Level Rationale that answers three of the four triggers, **When** the checks
   run, **Then** they fail and name the unanswered trigger.
3. **Given** a rationale that says every trigger does not apply on a feature declared Critical,
   **When** the checks run, **Then** they fail as inconsistent: Critical needs at least one
   trigger that applies, or a stated reason for choosing it anyway.
4. **Given** a rationale answering a trigger as applies on a feature declared Standard,
   **When** the checks run, **Then** they fail as inconsistent: the claim and the level
   disagree.
5. **Given** a feature specified before this feature merged, **When** the checks run, **Then**
   it is not failed for lacking the block (see FR-008).

---

### User Story 3 - An adopted project declares its critical surfaces and nothing changes until it does (Priority: P2)

An adopting project adds a list of path globs to its adoption record, naming where its
critical code lives. Projects that have not done so see no new failure from the path check.
They see one line saying the floor is not armed, so the absence is audible rather than a
quiet pass.

**Why this priority**: The kit ships to projects it cannot edit. A change that fails every
existing adoption on the day it updates is the shape feature 013 refused (absent record
defaults to strict only where strict costs nothing). Here the safe default is the opposite
one, and it must still be loud.

**Independent Test**: Run the checks against an adoption record with no surface list, an empty
one, a malformed one and a valid one; only the valid one arms the path check, and the others
each print a distinct line.

**Acceptance Scenarios**:

1. **Given** no surface list in the adoption record, **When** the checks run, **Then** the path
   check is skipped, the run reports that it is not armed, and the exit code is unchanged.
2. **Given** a surface list that is not an array of non-empty strings, **When** the checks run,
   **Then** the run reports the record as malformed by key, in the same words the existing
   adoption-record validation uses, and does not treat the list as empty.
3. **Given** the adoption doctor (`verify-kit.ps1`) runs on a project whose list is valid,
   **Then** it reports the surfaces as declared; on a project with none, it reports them as
   not declared, as an informational line rather than a failure.

---

### User Story 4 - An honest exception has a way to pass (Priority: P2)

Some features legitimately touch a critical-surface path without being Critical: a rename, a
comment fix, a documentation change inside the module. The owner records a **Surface
Exception** in the spec, naming the path and the reason, and the check passes for that path.
Because an exception is a change to a rule, it needs a recorded approver, and an implementing
agent may not approve its own (constitution I, Amendment authority).

**Why this priority**: GAP-020's lesson. A check with no legitimate way to pass trains people
to route around it. This is what keeps the check honest rather than merely strict.

**Independent Test**: A Standard feature matching a glob fails; adding an approved exception
for exactly that path passes; an exception naming a different path, or one with no approver,
does not.

**Acceptance Scenarios**:

1. **Given** a matching path and a Surface Exception naming that path with an approver,
   **When** the checks run, **Then** the check passes for that path and the run still lists
   the exception, so it is visible rather than silent.
2. **Given** an exception with no approver, **or** approved by the feature's own implementing
   agent, **When** the checks run, **Then** it does not count and the path fails as in US1.
3. **Given** an exception naming a path that is no longer in the Territory, **When** the
   checks run, **Then** the run reports it as stale and does not fail on it.

---

### Edge Cases

- The Territory is not written until `tasks.md`, after the spec is approved. A check that
  needs the Territory cannot run at specification time. It must run once a Territory exists,
  and a feature with no Territory yet must neither fail nor be reported as clean.
- A feature whose Territory grows by amendment after approval (feature 014's flow) must be
  re-graded against the surfaces; the check runs on every push, so a widened Territory that
  newly matches a surface fails then.
- A glob that matches nothing in a project is legal (a project may list a path before it
  exists); a glob that is the empty string is malformed.
- A Territory path reached through a decorated marker (GAP-026) is invisible to the parser.
  This feature does not fix GAP-026, and must not claim a clean grade over a Territory it
  could not read; it reports a feature whose Territory it cannot read as not graded.
- Upper and lower case, backslash and forward-slash path forms must match the same way on
  Windows and Linux runners.
- A feature declared Lite has no `spec.md`; the Lite lane and its abuse guard are untouched.
- A Critical feature is never failed by this check, including one that matches no surface.
  Over-declaring is allowed; the lopsided direction is the only one graded.
- The check itself must not fail open: if it cannot read the record, the spec or the
  Territory, it says so by name rather than passing quietly (the lesson of GAP-027).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The kit MUST define a **Level Rationale** block in the spec template, answering
  the four Critical triggers of `docs/sdlc/critical-delivery.md` one by one, each as applies or
  does not apply with a one-sentence reason.
- **FR-002**: For a numbered feature specified after this feature merges and declared Standard
  or Critical, the enforcement checks MUST fail when the Level Rationale is absent, or when it
  leaves any of the four triggers unanswered, naming the trigger.
- **FR-003**: The checks MUST fail when the Level Rationale contradicts the declared level: a
  trigger answered as applies on a Standard feature, or a Critical feature with every trigger
  answered as does not apply and no stated reason for choosing Critical.
- **FR-004**: The adoption record MUST accept an optional list of critical-surface path globs,
  validated in the same style as the existing record keys (not an array, blank entry, wrong
  type), with each problem reported by key and with a fix.
- **FR-005**: A project that declares no critical surfaces MUST see no new failure from the
  path check and MUST see one line stating the check is not armed. Absence is never read as an
  empty armed list.
- **FR-006**: When surfaces are declared, the checks MUST fail a feature declared Standard or
  Micro whose Territory contains a path matching a surface glob, naming the feature, its level,
  the path and the glob, and naming the three ways forward: promote, narrow, or record an
  exception.
- **FR-007**: The path check MUST read Territory and surfaces in repo-prefixed form and MUST
  resolve a path in a nested code repository the way feature 012's reading does, so one
  matching rule governs both the governance repository and the code repositories.
- **FR-008**: The checks MUST NOT retroactively fail a feature whose spec predates this
  feature's merge, for lacking a Level Rationale. The path check (FR-006) applies to every
  numbered feature on any branch the moment surfaces are declared, since it grades the
  Territory rather than the spec's age.
- **FR-009**: A **Surface Exception** MUST be a recorded, per-path statement in the spec, with
  a recorded approver in the shape constitution I defines for amendments, and an exception
  approved by the implementing agent MUST NOT count. A passing exception MUST be listed in the
  run's output.
- **FR-010**: A stale exception (naming a path no longer in the Territory) MUST be reported
  and MUST NOT fail the run.
- **FR-011**: A Critical feature MUST NOT be failed by the path check. The Lite lane, the
  Micro floor and the Critical evidence check MUST behave exactly as before.
- **FR-012**: When the record, the spec or the Territory cannot be read, the check MUST say so
  by name and MUST NOT report a clean grade; it must use the kit's vocabulary for a run that
  graded nothing (feature 015) and must not introduce a new hard failure on the Lite lane.
- **FR-013**: The adoption doctor MUST report declared surfaces as an informational line, and
  a malformed list as a finding, without failing a project that declares none.
- **FR-014**: Every rule above MUST be proved by the enforcement harness (feature 015) with a
  passing and a failing fixture, with expectations written by hand and not through the check's
  own helpers.
- **FR-015**: The constitution's template-sync list and the Definition of Done MUST name the
  new check and the rationale block, so the rule has one stated home and the documents that
  teach the levels do not drift from it. If the constitution needs an amendment to do that,
  the amendment is made first and approved by the owner before the check is built.

### Key Entities

- **Delivery Level**: the declared rigour of a feature (Lite, Micro, Standard, Critical). The
  value this feature grades.
- **Level Rationale**: a block in `spec.md` answering the four Critical triggers, each with a
  verdict and a reason.
- **Critical Surface**: a path glob in the adoption record naming where a project's critical
  code lives.
- **Territory**: the paths a phase may touch, declared per phase in `tasks.md`, which this
  feature reads and does not change.
- **Surface Exception**: a per-path, approved statement that a sub-Critical feature may touch
  a critical surface, with its reason and approver.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A Standard or Micro feature whose Territory touches a declared critical surface
  fails the ritual checks in 100 per cent of fixtured cases, in both the single-repo and the
  nested multi-repo layouts.
- **SC-002**: A feature declared Critical is never failed by this check, in every fixtured
  case.
- **SC-003**: Every one of the four triggers has a fixture in which leaving it unanswered
  fails the run and names it.
- **SC-004**: Running the updated kit against each of the three adopted projects changes no
  verdict: no new failure, and exactly one new informational line where no surfaces are
  declared.
- **SC-005**: A reviewer can tell, from the spec alone and without opening the plan or the
  tasks, why the level was chosen, in under a minute for any feature.
- **SC-006**: The harness's coverage check reports no rule of this feature without both a
  passing and a failing fixture.

## Assumptions

- The level of a feature stays chosen by the owner at creation. This feature grades the
  choice; it does not assign it, and does not take the choice away.
- Only a path-glob floor and a written claim are in scope. Content analysis of the code a
  feature changes, and inference of intent from the diff, are not.
- The surface list is an optional adoption-record key; a project that has none loses nothing
  (FR-005). Whether a project should be pushed to declare one is a later, separate decision.
- "Specified after this feature merges" (FR-002, FR-008) is decided by a marker the template
  carries, not by git history, so the rule survives rebases and shallow clones. The marker's
  shape is a planning decision.
- Standard to Critical promotion mid-flight is existing prose (`docs/sdlc/critical-delivery.md`)
  and is unchanged except that the path check makes one case of it machine-triggered.
- This feature is declared Standard on its own terms, and its Level Rationale is the first to
  be written under the new rule: it touches no domain invariant, no irreversible data
  operation, no authentication or payment flow, and no evidence an auditor can ask for. It
  does change enforcement scripts, which is why its fixtures (FR-014) are mandatory.
- Out of scope: GAP-026 (decorated Territory markers), GAP-018 (cross-repo territory overlap),
  GAP-024 (the developer roster), and any change to how the owner or reviewer is chosen.
