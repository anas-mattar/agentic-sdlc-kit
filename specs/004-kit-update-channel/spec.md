# Feature Specification: Kit-Update Channel

**Feature Branch**: `004-kit-update-channel`
**Created**: 2026-09-01
**Status**: Draft
**Delivery Level**: Standard
**Input**: User description: "Kit-update channel: a defined mechanism for adopted projects to receive kit updates — a manifest classifying kit-owned (verbatim-copyable) vs slot-bearing/project-instantiated (surgical) files, an update script that copies the verbatim set and reports the surgical set with the pending kit amendments, and adoption documentation for constitution amendment flow-down."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Every kit file has a declared update class (Priority: P1)

A maintainer (or an agent) looking at any file the kit ships can tell, from one
machine-readable manifest in the kit, how that file updates in an adopted project:
**verbatim** (kit-owned prose or script, copy as-is), **surgical** (project-instantiated
— filled slots or ratified content; updating requires judgment, never a blind copy), or
**kit-internal** (never ships to adoptions at all). The 2026-09-01 flow-back required
reconstructing this classification by hand, per file, from memory and diffs.

**Why this priority**: The classification is the foundation — the update script (US2)
and the flow-down guidance (US3) are both consumers of it. It also pays for itself
standalone: even a human doing a manual update stops guessing which files are safe to
copy.

**Independent Test**: Take the full list of files the kit ships and check every one
appears in exactly one manifest class; spot-check the three known-surgical files
(constitution, CLAUDE.md, gate-command) and three known-verbatim files (flow.md, the
scripts, definition-of-done) land in the right class.

**Acceptance Scenarios**:

1. **Given** the manifest, **When** every kit-shipped file path is looked up, **Then**
   each resolves to exactly one class — no file is unclassified and none is in two
   classes.
2. **Given** a file with `{{SLOT}}` placeholders or per-project ratified content
   (constitution, CLAUDE.md, gate-command, rulebook templates), **When** looked up,
   **Then** its class is surgical — and the manifest entry says what makes it surgical
   (which slots / what project content).
3. **Given** kit-internal material (`specs/`, `review/`, the kit's own roadmap),
   **When** looked up, **Then** its class is kit-internal (or it is covered by an
   explicit exclusion rule), so no update ever copies it into an adoption.

---

### User Story 2 - One-command update for an adopted project (Priority: P1)

From an adopted project, an owner runs one command pointing at the kit. It copies every
verbatim-class file whose content differs, refuses to touch surgical-class files but
lists each one whose kit version changed (so a human or agent knows exactly where
judgment is needed), and warns — without overwriting — when a verbatim-class file was
locally modified in the project. It ends by reporting what changed, what needs surgery,
and what was skipped, and records which kit version the project is now on.

**Why this priority**: This is the gap that cost the most in the flow-back: the verbatim
copying is pure mechanics that a script does in seconds, and the surgical report turns
"read everything and guess" into a bounded checklist.

**Independent Test**: In a scratch adopted-project directory, run the update against a
newer kit: verbatim diffs are applied, surgical files are untouched but reported, a
locally-modified verbatim file is skipped with a warning, and the recorded kit version
advances.

**Acceptance Scenarios**:

1. **Given** an adopted project behind the kit, **When** the update runs, **Then** every
   changed verbatim-class file is copied, and no surgical-class file is modified.
2. **Given** a surgical-class file whose kit source changed since the project's recorded
   kit version, **When** the update runs, **Then** the report names the file and points
   at what changed (the kit's amendment notes), so the owner can apply it deliberately.
3. **Given** a verbatim-class file the project has locally modified, **When** the update
   runs, **Then** the file is NOT overwritten by default; the report flags the conflict
   and how to resolve it (accept kit version explicitly, or reclassify locally).
4. **Given** the update completes, **When** the owner checks the project, **Then** the
   project records the kit version it now tracks, and running the update again
   immediately reports "up to date" with no changes.
5. **Given** the command is run inside the kit repository itself, **When** it starts,
   **Then** it refuses — the kit is the source, never the target.

---

### User Story 3 - Constitution amendment flow-down guidance (Priority: P2)

An owner of an adopted project with a **ratified** constitution reads one adoption
document section that says exactly how an upstream kit constitution amendment reaches
their project: it is re-expressed as an amendment to *their* constitution (their own
version bump per their versioning policy, their own SYNC IMPACT entry naming the kit
versions adopted), their citations swept, and adopted only by their human approval — the
update script reports it, a human enacts it. The 13→10 renumbering flow-back of
2026-09-01 is the worked example.

**Why this priority**: The constitution is the one file that can never be copied, and
today the procedure exists only in this session's history. Without written guidance,
the next amendment flow-down reinvents it — or worse, blind-copies the kit template over
a ratified constitution.

**Independent Test**: Hand the section to someone with a ratified 10-principle project
constitution and a hypothetical kit 0.5.0 amendment; they can state, without asking
anything, what their version becomes, what their SYNC IMPACT entry must record, which
documents they must sweep, and who approves.

**Acceptance Scenarios**:

1. **Given** the guidance section, **When** followed for a kit amendment, **Then** the
   project ends with its own bumped version and SYNC IMPACT entry (never the kit's
   version string), and the amendment is only adopted on the project's human approval.
2. **Given** a kit amendment that renumbers or removes principles, **When** the guidance
   is followed, **Then** it requires verifying that any demoted content already lives in
   (or is moved to) the project's rulebooks before deletion, and sweeping stale
   principle citations across the project's documents — both steps named explicitly.

---

### Edge Cases

- Adopted project has a partial install (missing `.specify/` or `.claude/`): the update
  refuses and points at the existing kit-integrity check (doc-lint) rather than
  "updating" a broken base.
- Adopted project has files the manifest doesn't know (project-authored docs under
  scanned trees): ignored — the update only ever touches manifest-listed paths.
- A file changes class between kit versions (a template becomes slot-bearing): the
  manifest travels with the kit, so the update uses the new kit's classification; the
  report calls out class changes explicitly.
- No recorded kit version in the project (adoptions made before this feature): the
  update treats every surgical file as potentially changed (reports all of them once),
  then records the version so the next run is precise.
- The kit and project are on unrelated filesystems/paths with different line endings:
  content comparison must not report every file as changed due to CRLF/LF alone.
- The manifest itself drifts from reality (a kit file exists but is unclassified): the
  kit's own machine check fails — classification completeness is enforced in the kit's
  CI, not discovered by adopters.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The kit MUST ship a machine-readable manifest classifying every file it
  ships to adoptions as **verbatim** (copy as-is) or **surgical** (project-instantiated;
  judgment required), with kit-internal material excluded by explicit rule; each
  surgical entry states what makes it surgical.
- **FR-002**: The kit's own machine checks MUST fail when a kit-shipped file is missing
  from the manifest or listed in more than one class (completeness is the kit's job, not
  the adopter's discovery).
- **FR-003**: The kit MUST provide a one-command update runnable against an adopted
  project that: copies changed verbatim-class files, never modifies surgical-class
  files, and reports — per surgical file changed upstream — that judgment is needed and
  where the change is described.
- **FR-004**: The update MUST NOT overwrite a verbatim-class file that was locally
  modified in the adopted project; it reports the conflict and the explicit ways to
  resolve it. An explicit opt-in is required to take the kit version over local edits.
- **FR-005**: The update MUST record in the adopted project which kit version it now
  tracks, and use that record on later runs to scope its report; a project with no
  record is handled degraded-but-safely (full surgical report once).
- **FR-006**: The kit MUST carry an identifiable version for this purpose, advancing
  with changes that adoptions should receive.
- **FR-007**: The update MUST refuse to run against the kit repository itself, against a
  partial install (delegating detection to the existing kit-integrity check), and MUST
  ignore all paths not listed in the manifest.
- **FR-008**: Line-ending-only differences MUST NOT count as changes (Windows CRLF
  working copies vs kit LF must not produce false positives).
- **FR-009**: The adoption documentation MUST gain a flow-down section covering: running
  the update, resolving the surgical report, and — for constitution amendments — the
  re-expression procedure (project's own version bump and SYNC IMPACT entry, demoted-
  content verification before deletion, citation sweep, project human approval),
  using the 2026-09-01 kit 0.3.0/0.4.0 flow-back as the worked example.
- **FR-010**: Every new rule and artifact in this feature follows the kit's encode-gaps
  convention: stated in an owning document, surfaced in the always-loaded anchor where
  agents must see it, and covered by a machine check where one exists.

### Key Entities

- **Manifest entry**: a kit-shipped path (or glob), its class (verbatim | surgical), and
  for surgical entries the reason (slots, ratified content, project-filled gates).
- **Kit version record**: the version identifier the adopted project tracks, written by
  the update, read to scope the next report.
- **Update report**: applied verbatim copies; surgical files needing judgment (with
  pointers to what changed); conflicts (locally-modified verbatim files); skipped /
  unknown paths; resulting kit version.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A kit update that took hours of manual file classification and surgery on
  2026-09-01 completes its mechanical part in one command in under a minute, with the
  judgment part reduced to a written checklist of named files.
- **SC-002**: Zero project-instantiated content is ever overwritten by an update — the
  ratified constitution, filled gates, and filled rulebooks survive any update run,
  including a hostile "run it twice, then with force on one named file" sequence.
- **SC-003**: 100% of kit-shipped files are classified, enforced by the kit's own CI —
  an unclassified new file fails the kit's checks before it can ship.
- **SC-004**: An owner following the flow-down guidance produces a correct project
  constitution amendment (own version, own SYNC IMPACT, sweep, human approval) without
  consulting anything outside the kit's documentation.
- **SC-005**: Running the update on an already-current project changes nothing and says
  so — idempotence observable by a clean `git status` in the adopted project.

## Assumptions

- The manifest and update script live in the kit and ship to adoptions like other kit
  files (so an adopted project can also self-report its drift); the kit repository
  remains the single source.
- "Kit version" is the kit's existing constitution version string plus the kit commit —
  no new release ceremony is introduced; the constitution's SYNC IMPACT REPORT remains
  where amendments are described, and the update report points at it.
- The update transports kit files; it does not run migrations of project content. All
  surgical work stays human/agent judgment, guided by FR-009's documentation.
- The two existing adoptions (expense-tracker, flowboard) are already current as of kit
  0.4.1 via the manual 2026-09-01 flow-back; they become the first consumers of the
  scripted channel on the next kit change, and gain their kit-version record on their
  first update run (FR-005's degraded path).
- Nested code repositories inside adopted governance repos are out of scope — the update
  touches only the governance repo's kit surface.
