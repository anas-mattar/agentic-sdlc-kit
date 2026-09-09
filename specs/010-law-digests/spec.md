# Feature Specification: Law Digests

**Feature Branch**: `010-law-digests`
**Created**: 2026-09-09
**Status**: Draft
**Delivery Level**: Standard
**Input**: User description: "Generated per-pack law digests: a machine-generated one-page
digest per governance pack, kept in sync by CI so it can never drift from the documents it
summarizes; agents load the digest per session and read the full document only when acting
on that area (roadmap GAP-014)"

## Problem

Every agent session pays a context tax to know the law: the Task-Scoped Reading table
sends the agent to full governance documents (several hundred lines each) even when the
session only needs orientation — "what are this pack's rules, roughly, and where do they
live?" A hand-written summary would solve the cost and create a worse problem: drift. A
summary that quietly disagrees with the law it summarizes teaches the agent wrong rules
with full confidence — and drift is exactly what kills rule-based frameworks (README).
The kit's own history proves the risk: every governance sweep in features 003–009 has
found stale restatements of rules in secondary documents.

The missing piece is a digest that is **generated, not authored**: its every line
originates in the source document itself, assembled deterministically by a script, with
CI failing the branch whenever the committed digest no longer matches what regeneration
produces. Then editing the law without updating its digest is machine-impossible.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Agent orients from a digest, acts from the law (Priority: P1)

An AI agent starting a task reads the one-page digest for the pack it is about to touch
(instead of the full documents), learns the pack's binding rules in compressed form, and
follows the digest's pointer into the full document only when it is about to act on that
area.

**Why this priority**: the whole point of the gap — cut per-session context cost without
cutting law. Nothing else in this feature matters if the digest is not genuinely cheaper
to load and safe to trust for orientation.

**Independent Test**: open any generated digest; verify it is one page or less, that every
rule line carries a pointer to its source document (and the digest names the full-read
rule), and that its content matches the source documents' marked rules verbatim.

**Acceptance Scenarios**:

1. **Given** a governance pack with a generated digest, **When** an agent reads only the
   digest, **Then** every rule it learns is a verbatim-marked rule from a source document
   with the source path attached, and the digest states that acting on the area requires
   the full document.
2. **Given** the Task-Scoped Reading table, **When** an agent looks up a pack, **Then**
   the digest is offered as the orientation read and the full documents remain the
   acting read.

### User Story 2 - Drift is machine-impossible (Priority: P1)

A maintainer edits a governance document's marked rule but forgets to regenerate the
digest. CI (and the local ritual checks) fail the branch, naming the stale digest and the
command that fixes it.

**Why this priority**: the gap explicitly rejects hand-written digests because they
drift. Without the freshness check the feature is a liability, not an asset.

**Independent Test**: seeded fixture — edit a marked rule without regenerating; run the
ritual checks; verify a FAIL naming the digest and the regeneration command. Regenerate;
verify OK.

**Acceptance Scenarios**:

1. **Given** a source document whose marked rule changed, **When** ritual-checks runs
   with the digest not regenerated, **Then** the run FAILs, naming the digest file and
   the regeneration command.
2. **Given** a hand-edit to a generated digest file itself, **When** ritual-checks runs,
   **Then** the run FAILs the same way (regeneration is the only lawful writer).
3. **Given** all digests regenerated after a law edit, **When** ritual-checks runs,
   **Then** the digest check reports OK.

### User Story 3 - Adopted projects generate their own digests (Priority: P2)

An adopted project (whose surgical law documents are project-filled — its own gate
chains, its own review customizations) runs the same generator against its own documents
and gets digests of ITS law, not the kit's; the freshness check arrives through the same
ritual-checks channel.

**Why this priority**: digests of the kit's template text would be wrong in every adopted
project; the generator must be portable or the feature stops at the kit boundary.

**Independent Test**: run the generator in an adopted project; verify the digest content
comes from the project's own document text and the project's ritual checks enforce
freshness.

**Acceptance Scenarios**:

1. **Given** an adopted project with project-filled law documents, **When** the generator
   runs there, **Then** each digest line quotes the project's own text.
2. **Given** a kit update delivering the generator to a tree with no digest markers,
   **When** the project has not yet generated digests, **Then** nothing fails — the check
   activates only once markers (or digests) exist. *(Amended at phase 3 review F1, for
   owner ratification at batch-end approval: a post-010 update also delivers the kit's
   marker-bearing **verbatim** pack documents, so the flow-down itself includes running
   the generator and committing the digests with the update — skipping that step FAILs
   ritual-checks loudly, naming the exact files and fix command, never silently.)*

### Edge Cases

- A marked rule inside an HTML comment block MUST NOT be extracted (comment-stripped
  parsing — the 008/009 precedent; a commented-out decoy must not reach the digest).
- A document with no digest markers contributes nothing and is not an error; a pack whose
  documents carry no markers yields no digest file (and the check does not demand one).
- A marker whose rule text is empty, or a digest file in the output directory that no
  pack manifest explains, FAILs the check (fail-closed on malformed state).
- Slot placeholders (`{{...}}`) inside marked rules are carried verbatim in the kit
  (template state) and resolve naturally in adopted projects, whose doctor already
  polices unfilled slots in project-owned files.
- Line-ending differences (CRLF/LF) between generation environments MUST NOT cause false
  drift failures (normalized comparison).
- The digests themselves MUST NOT become a source-of-truth rung: constitution II is
  untouched, and every digest carries a standing header stating it is generated,
  non-authoritative, and that the source documents prevail.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Governance documents MAY mark individual rule statements with an in-document
  digest marker; the marked text itself (not a paraphrase) is what a digest carries, each
  line attributed to its source document path.
- **FR-002**: A generator script MUST deterministically assemble one digest file per
  governance pack from the marked rules of that pack's documents — same inputs, byte-same
  output — into a dedicated digests directory; packs and their member documents are
  declared in exactly one place.
- **FR-003**: Every generated digest MUST fit on one page (bounded lines, enforced by the
  generator), MUST open with a generated-file header naming the generator, the
  non-authoritative status, and the full-read rule ("digest for orientation; read the
  source document before acting on its area"), and MUST point each rule at its source.
- **FR-004**: The ritual checks (local and CI — the same command) MUST fail a branch
  whose committed digests differ from what regeneration produces — covering source edits
  without regeneration, hand-edits to digest files, stale deletions, and unexplained
  extra digest files.
- **FR-005**: Marker extraction MUST parse visible text only (comment-stripped, the
  shared idiom): a marker inside an HTML comment never reaches a digest.
- **FR-006**: The Task-Scoped Reading table (CLAUDE.md) MUST offer digests as the
  orientation read while keeping full documents as the acting read; the always-loaded
  core (CLAUDE.md + definition-of-done.md) stays as it is — digests never replace the
  always-load set.
- **FR-007**: The generator and check MUST be portable to adopted projects through the
  existing update channel (verbatim class), operate on the project's own document text,
  and stay inert where no markers or digests exist yet (backward compatible).
- **FR-008**: The kit's own governance documents MUST ship with markers on their binding
  rules and generated digests committed, so the kit dogfoods the feature and adopters see
  a worked example.
- **FR-009**: Documentation MUST state the authority rule: digests are generated
  artifacts outside the constitution II ladder; on any conflict the source document
  prevails and the conflict is itself a freshness-check failure to fix by regeneration.

### Key Entities

- **Digest marker**: an in-document annotation attaching one-line digest text to the rule
  it sits beside; lives in the source document so a law edit physically touches it.
- **Pack manifest**: the single declaration of packs → member documents → digest file.
- **Generated digest**: one page per pack in the digests directory; machine-written only.
- **Freshness check**: regenerate-and-compare verdict inside ritual-checks.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Orientation cost drops: for every pack, the digest is at most one page
  (≤ 40 content lines), at least 5× smaller than the pack's combined source documents.
- **SC-002**: Drift is impossible to commit quietly: 100% of seeded drift scenarios
  (source edit without regeneration; digest hand-edit; digest deletion; orphan digest)
  FAIL ritual-checks with a message naming the digest and the fix command.
- **SC-003**: Regeneration is one command with zero required arguments in both the kit
  and adopted projects, and produces byte-identical output on repeated runs.
- **SC-004**: Existing behavior unchanged where no markers are present: an adopted
  project without markers/digests passes ritual-checks exactly as before the update. A
  post-010 flow-down delivers marked verbatim law and therefore pairs it with generated
  digests in the same flow-down commit — the check enforces the pairing, never fails
  silently. *(Scope clarified at phase 3 review F1, for owner ratification at batch-end
  approval.)*

## Assumptions

- Digest text is curated at authoring time (the marker's one-liner is written by the
  document's author beside the rule), but the digest FILE is assembled only by the
  generator — "generated" means no hand-authored artifact can drift silently, not that
  prose is machine-summarized. This is the drift-killing property the gap asks for; an
  LLM summarizer in CI would be non-deterministic and is out of scope.
- Pack composition follows the Task-Scoped Reading table's shape (delivery / branching /
  review / critical / adoption groupings) — exact membership is a plan-time decision
  recorded in the pack manifest, adjustable at spec approval.
- The one-page bound (≤ 40 content lines per digest) is proposed here and ratified at
  owner approval, like 009's constants.
- No constitutional amendment is expected: digests sit below the ladder (FR-009) and the
  freshness check is an ordinary machine check — constitution stays at 0.6.0 unless plan
  review finds a clause that must change (report if so).
