# Feature Specification: Rendered-structure lint

**Feature Branch**: `020-rendered-structure-lint`
**Created**: 2026-10-11
**Status**: Draft
**Delivery Level**: Standard
**Rationale Rule**: 1
**Input**: User description: "Block-structure check in doc-lint: tables and list blocks uninterrupted; table rows with uniform cell counts, escaped pipes not counted; not a markdown renderer (GAP-015)"

## Background

Nothing in the kit renders markdown. An HTML comment line (a `digest:` marker is one) or a blank line placed
inside a table splits it into a table and a stray paragraph of pipes, and no check notices: `doc-lint.ps1`
reads backtick spans and link targets, the digest check reads markers, and the ritual chain stays green. The
law says the right thing and displays the wrong thing. Feature 010's phase 2 review caught one by eye (GAP-015).

The defect is not hypothetical. A throwaway prototype run over the 37 governance documents `doc-lint.ps1`
already scans found 17 tables, **one severed** and none ragged: `docs/roadmap.md` has a blank line after the
GAP-024 row of the inventory table, so GAP-025 onward (and every later row) renders as plain text. Whether lists
suffer the same has not been measured; the plan owes that measurement before a list rule is trusted.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A severed table fails the lint (Priority: P1)

An author adds a `digest:` marker or a blank line between two rows of a table. `doc-lint.ps1` fails and names the
file and the line of the first row that no longer belongs to its table.

**Why this priority**: it is the recorded defect, it is silent today, and it already exists in the kit's own
roadmap.

**Independent Test**: a fixture document with a comment line between two rows fails with that line number; the
same document without the comment passes; a blank line between a table and an unrelated second table (each with
its own header and delimiter row) passes.

**Acceptance Scenarios**:

1. **Given** a table whose rows are separated by an HTML comment line or by a blank line, **When** `doc-lint.ps1`
   runs, **Then** it exits 1 and prints `<file>:<line>` of the orphaned row and why.
2. **Given** two adjacent tables, each with its own header and delimiter row, **When** it runs, **Then** neither is
   reported.
3. **Given** a table inside a fenced code block, **When** it runs, **Then** it is not examined.

---

### User Story 2 - A ragged table fails the lint (Priority: P1)

A row whose cell count differs from its header's renders with missing or merged cells. The lint reports it. A pipe
escaped as `\|` is not a cell boundary; an unescaped pipe inside a code span **is** one, as GitHub renders it, and
so counts.

**Why this priority**: same defect family, same mechanism, and the roadmap row names it.

**Independent Test**: a fixture with an extra cell fails; the same row with the pipe escaped passes.

**Acceptance Scenarios**:

1. **Given** a body row with more or fewer cells than the header row, **When** it runs, **Then** it exits 1 and
   names the row, its count and the header's.
2. **Given** a cell containing `\|`, **When** it runs, **Then** that pipe is not counted.

---

### User Story 3 - A severed list is reported, narrowly (Priority: P2)

A list whose items are split by an HTML comment line at column zero renders as two lists. The lint reports that,
and nothing else about lists: a blank line between list items is legal (a loose list) and is not a finding.

**Why this priority**: the roadmap names list blocks, but a rule with false positives on legal markdown costs
more trust than it earns, so the rule is the narrow one and is shipped only if the measurement in the plan shows
no false positive on the kit's own documents.

**Independent Test**: a fixture with a comment line between two items of one list fails; the same list with a
blank line between items passes.

**Acceptance Scenarios**:

1. **Given** two items of the same list separated by a comment-only line, **When** it runs, **Then** it exits 1
   and names the line.
2. **Given** a loose list (blank lines between items, no comment), **When** it runs, **Then** it passes.

---

### User Story 4 - The kit passes its own rule and adopters know what changes (Priority: P2)

The roadmap's severed table is repaired in the same feature, the guidance says what the check reads and how to
fix a finding, and the flow-down note says which adopted-project documents the check may newly flag, measured on
clones of the three adopted projects.

**Why this priority**: `doc-lint.ps1` runs in adopted projects over their own `docs/` (a project's roadmap is
one), so shipping a rule that fails them without saying so is the kind of surprise feature 018 spent a phase on.

**Independent Test**: `ritual-checks.ps1` is OK on the kit; the measurement table in `notes.md` names every
document in the three clones the new check flags.

**Acceptance Scenarios**:

1. **Given** the kit after this feature, **When** `doc-lint.ps1` runs, **Then** it reports no structure finding.
2. **Given** an adopted project with a severed table in its roadmap, **When** it takes the update, **Then** the
   flow-down note has told its owner what the finding means and what to change.

---

### Edge Cases

- A table row with leading indentation of up to three spaces is a table row; four spaces is a code block and is
  not examined.
- A delimiter row (`|---|---|`) that is not directly beneath a header row is a severed header and is reported.
- A table whose header and delimiter rows disagree on the cell count is ragged.
- A table at the very end of a file, with no trailing blank line, is examined like any other.
- Fenced code blocks (backtick and tilde fences) are skipped, and so are the contents of a fence opened inside a
  list item.
- A `digest:` marker directly after a table, separated by a blank line, is the intended use and is not a finding;
  only a comment or blank line **inside** a table is.
- A document `doc-lint.ps1` cannot read is reported, never skipped silently.

## Level Rationale *(mandatory — answers the four Critical triggers, in writing)*

- **domain-invariants**: does not apply — the kit has no domain-invariants pack; this is a documentation lint.
- **irreversible-data**: does not apply — nothing is migrated, dropped or rewritten; the only data edit is one blank line in `docs/roadmap.md`.
- **authn-authz-payment**: does not apply — no authentication, authorization or payment flow.
- **auditable-evidence**: does not apply — the check grades documents' layout, not evidence a regulator or contract can ask for.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `scripts/doc-lint.ps1` MUST examine the same document set it already scans for path references,
  and MUST NOT examine the contents of fenced code blocks.
- **FR-002**: A table is a run of consecutive lines that start with `|` after at most three spaces of
  indentation. A table row that follows a blank line or a comment-only line inside what was a table, and is not
  the header of a new table (a row directly followed by a delimiter row), MUST be a finding that names the file
  and the line of that row.
- **FR-003**: A delimiter row that is not directly beneath a header row MUST be a finding.
- **FR-004**: Every row of a table MUST have the header row's number of cells, else a finding names the row and
  both counts. A cell boundary is an unescaped `|`; a `\|` is not one; a `|` inside a code span is one.
- **FR-005**: Two items of one list separated by a comment-only line MUST be a finding; a blank line between
  list items MUST NOT be. This rule ships only if the measurement in the plan shows no finding on the kit's own
  documents beyond the repaired one and no false positive on the fixtures.
- **FR-006**: A finding MUST fail the run (exit 1) with the verdict line and a `<file>:<line>` detail, in the
  shape `doc-lint.ps1` already prints for a broken path; nothing here changes the existing path, slot and
  manifest checks or their output.
- **FR-007**: `docs/roadmap.md` MUST be repaired so the inventory table is one table, and no other document is
  rewritten to satisfy the rule except to remove a finding the rule is right about.
- **FR-008**: Every new rule MUST have a passing and a failing fixture in the enforcement harness, anchored in
  `tests/enforcement/rules.json`, so the coverage test grades it (feature 015).
- **FR-009**: `docs/sdlc/review-process.md` or the document that tells authors how to place a `digest:` marker
  MUST say that a marker belongs after a block, never inside one. [NEEDS CLARIFICATION: which document owns this
  sentence today — the plan names it after reading `docs/sdlc/` and `docs/digests/digest-packs.json`.]
- **FR-010**: `adoption/updating.md` MUST carry a flow-down note: what the check reads, what it newly fails,
  what to do, and the measured result on clones of the three adopted projects, including every document flagged.
- **FR-011**: The check MUST NOT claim to render markdown. Its guidance and output MUST say it grades the
  structure rules above and nothing more. [NEEDS CLARIFICATION: in an adopted project, does a finding fail the
  run or print as information for one release? Failing matches every other `doc-lint.ps1` rule and keeps the
  verdict honest; information avoids breaking an adopter's CI on an update. Owner's call.]

### Key Entities

- **Block**: a table (header row, delimiter row, body rows) or a list (items at one indent level) in a
  governance document, outside fenced code.
- **Finding**: `<file>:<line>` plus the rule broken (severed row, severed delimiter, ragged row, severed list).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The kit's own documents produce no finding after the roadmap repair, and the roadmap's inventory
  table renders as one table (one header, GAP-001 to GAP-030 under it).
- **SC-002**: Each rule has a failing fixture that fails for the stated reason and a passing fixture that
  differs from it only in the condition under test, and the coverage test reports every new site fixtured.
- **SC-003**: No existing fixture or verdict changes: the whole enforcement harness passes with only the new
  fixtures added.
- **SC-004**: On clones of the three adopted projects, the check's findings are listed in full, and no finding
  is a false positive (every one is a block that genuinely renders broken).

## Assumptions

- GitHub-flavoured markdown is the rendering target, because that is where these documents are read. Other
  renderers differ at the margins; the rules are the ones GFM and its common relatives agree on.
- A prototype's measurement (17 tables, 1 severed, 0 ragged across 37 documents) is representative enough to
  scope the work; the plan re-measures with the real implementation.
- The scanned document set stays the one `doc-lint.ps1` already uses; widening it is a separate decision.
- A blank line inside a list is legal and common; only the comment-line split is a list finding.
