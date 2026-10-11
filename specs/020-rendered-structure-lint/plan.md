# Implementation Plan: Rendered-structure lint

**Branch**: `020-rendered-structure-lint` | **Date**: 2026-10-11 | **Spec**: specs/020-rendered-structure-lint/spec.md
**Input**: Feature specification (approved, FR-011 decided) + decisions D1–D8 below
**Gate Batching**: none
**Gate Certification**: user-run

## Summary

Teach `doc-lint.ps1` to read a document's block structure, not just its path references, so a table or
list severed by a comment line or a blank line fails the run instead of rendering wrong behind a green
chain. Three phases, each independently revertible. First the table rules (severed row, severed delimiter,
ragged row) with the repair of the one severed table the kit already has. Then the list rule, which ships
only if a measurement says it is safe. Last the guidance, the flow-down and a measurement over the three
adopted projects.

## Technical Context

**Language/Version**: PowerShell 7+ (`pwsh`)
**Primary Dependencies**: none new. Reuses `Get-FencedLineMap` in `scripts/markdown-lib.ps1`
**Storage**: none; the check reads documents and writes nothing
**Testing**: the enforcement harness (`tests/enforcement/`): `doc-lint.ps1` fixtures are real temporary
directories with hand-written documents and expected output; a passing and a failing fixture per rule
**Target Platform**: any runner with `pwsh`; documents read the same with LF or CRLF endings
**Project Type**: governance tooling (scripts plus documents)
**Performance Goals**: not applicable; one linear pass per document over about 40 documents
**Constraints**: the existing path, slot and manifest checks and their output are untouched; a finding
exits 1 in every project (spec FR-011, decided); no new package, no new script file
**Scale/Scope**: one function added to an existing library, one script extended, one roadmap line repaired,
two documents updated, about 14 new fixtures

## Constitution Check

- [x] **Specification First (I)**: `spec.md` is approved; this plan follows it; `tasks.md` follows.
- [x] **Source of Truth (II)**: no conflict. FR-009's open question (which document owns the marker
  sentence) is resolved below (D7).
- [ ] **Repository Separation (III)**: not applicable, the kit is one repository.
- [x] **Architecture Consistency (IV)**: the scanner lives in `scripts/markdown-lib.ps1`, where the
  kit already keeps its markdown readers (shared by `enforcement-pack.ps1` and `build-digests.ps1`); no new
  file.
- [ ] **Domain Invariants (V)**: not applicable, the template's slot is unfilled.
- [x] **Security (VI)**: reads local documents only, logs paths and line numbers, nothing sensitive.
- [ ] **External Integration Governance (VII)**: not applicable.
- [x] **Testing Requirements (VIII)**: every rule has a passing and a failing fixture, hand-written.
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI review with
  Reviewer Provenance.
- [x] **Controlled Delivery (X)**: three phases, one at a time. This changes an enforcement script, so the
  owner runs the gate; no batching, no ci-held.

**Phase sizing rule**: phase 1 delivers a working table check on its own. Phase 2 adds a rule that can be
dropped without touching phase 1. Phase 3 is documents and measurement. Reverting 3 then 2 then 1 leaves a
consistent kit; reverting phase 1 alone must not leave phase 3's guidance describing a rule that is gone, so
phase 3 is reverted with it.

## Decisions

**D1 — One scanner, in the shared library.** `Get-StructureFindings` goes in `scripts/markdown-lib.ps1`,
next to `Get-FencedLineMap`, which it reuses to skip fenced code (backtick and tilde fences). `doc-lint.ps1`
dot-sources the library and calls the function for each document it already scans. No second document
walker is written; the document set is unchanged (spec assumption).

**D2 — What a table is.** A table starts at a header row directly followed by a delimiter row
(`|---|---|`, colons allowed) and runs while lines start with `|` after at most three spaces of
indentation. A run of `|` lines with no delimiter row is not a table and is never examined, so prose that
happens to start with a pipe is not a false positive. Cell count: the line trimmed, one leading and one
trailing `|` removed, `\|` removed, then the remaining `|` counted plus one. A `|` inside a code span is a
boundary, as GitHub renders it.

**D3 — Findings, in order of checking.**
1. *Severed row*: after a table's last row comes one or more blank or comment-only lines, then a `|` line
   that is not the header of a new table (not directly followed by a delimiter row). The finding names the
   `|` line.
2. *Severed delimiter*: a delimiter row whose preceding line is not a `|` row (a comment or blank line
   stands between the header and its delimiter, or there is no header). Named by the delimiter line.
3. *Ragged row*: a body row whose count differs from the header's; the header and delimiter rows must also
   agree. Named by the row, with both counts.
A comment-only line is a line holding nothing but one or more `<!-- … -->` spans. A multi-line comment
block is skipped as a unit, the way `build-digests.ps1` skips one.

**D4 — Lists, narrowly (spec FR-005).** A list item is a line starting, after at most three spaces, with
`-`, `*`, `+` or a number followed by `.` or `)`, then whitespace. Two items at the same indent separated
only by a comment-only line at column zero are a *severed list*, named by the second item. A blank line
between items is never a finding. Phase 2 starts by measuring the rule over every scanned document and over
the three adopted-project clones; if it reports anything that is not a genuinely severed list, the rule is
not shipped, the measurement goes in `notes.md`, and FR-005 is recorded as unmet by decision, not by
omission.

**D5 — Output.** Each finding is one line under an `ERROR:` block in the shape the script already prints:
`<file>:<line>  <rule>: <why>`. The run verdict line counts findings with the existing issues, and the
`doc-lint: FAIL (N issue(s)…)` roll-up needs no change beyond including them. The OK line is unchanged and
now also means no structure finding. Nothing about the path, slot or manifest output moves.

**D6 — Fixtures.** Rule ids `DOC-010` onward in `tests/enforcement/rules.json`, one `pass` and one `fail`
recipe each: severed row (comment), severed row (blank), severed delimiter, ragged row, escaped pipe not
counted, two adjacent tables, a fenced table skipped, and the list pair (phase 2). `emission-idioms.json`
gains the accumulator for the new findings so the coverage test sees every new site. Expectations are
written by hand.

**D7 — Where the marker sentence goes (FR-009).** `docs/sdlc/review-process.md`, in the part that tells a
reviewer what to check in a diff: a `digest:` marker belongs on its own line **after** a block, never inside
a table or a list. Authors read it there, reviewers check it there, and the new check enforces it. The
sentence is also in the flow-down note. `scripts/build-digests.ps1` is not touched (its header already
states the marker grammar).

**D8 — Repairing the kit.** The one existing finding is `docs/roadmap.md` (the blank line after the
GAP-024 row of the inventory table). The repair is deleting that line, in phase 1 together with the rule, so
the commit that arms the check leaves the kit green. A repair of any other document is made only if the
phase 1 or 2 measurement shows a finding the rule is right about; a finding the rule is wrong about is a
rule bug, fixed in the rule.

## Phases

Detailed tasks and the per-phase **Territory** blocks are written by `/speckit.tasks`.

1. **The table rules.** D1–D3, D5, D6 for the table rules, D8's roadmap repair. Delivers US1 and US2 and
   SC-001 for the kit.
2. **The list rule.** D4: measurement first, then the rule and its fixtures if it is safe. Delivers US3 or
   a recorded decision not to.
3. **Guidance and flow-down.** `docs/sdlc/review-process.md` (D7), the `adoption/updating.md` note,
   digests, the roadmap row and decisions-log entry, and a measurement over clones of the three adopted
   projects listing every document flagged (SC-004).

## Project Structure

### Documentation (this feature)

```text
specs/020-rendered-structure-lint/
├── spec.md
├── plan.md              # this file
├── tasks.md             # /speckit.tasks, not this command
└── notes.md             # phase evidence, measurements
```

### Source Code (repository root)

```text
scripts/markdown-lib.ps1                 # phases 1-2: Get-StructureFindings
scripts/doc-lint.ps1                     # phases 1-2: calls it, prints findings
tests/enforcement/rules.json             # phases 1-2: DOC-010 onward
tests/enforcement/emission-idioms.json   # phases 1-2: the new accumulator
tests/enforcement/cases/doc-lint/        # phases 1-2: fixtures
docs/roadmap.md                          # phase 1: the repair; phase 3: row and decisions log
docs/sdlc/review-process.md              # phase 3: the marker sentence
adoption/updating.md                     # phase 3: flow-down note
docs/digests/**                          # phase 3: regenerated
```

**Structure Decision**: no new script and no new library file. `markdown-lib.ps1` and `doc-lint.ps1` already
ship verbatim to every adopter, so nothing new enters the flow-down and `kit-manifest.json` needs no entry.

## Testing Strategy

- Each rule: a passing and a failing fixture in a real temporary directory, expectations by hand, coverage
  graded by the harness's own coverage test.
- Every existing `DOC-*` fixture and every other verdict is unchanged (SC-003): the whole harness passes with
  only fixtures added. The new rule is first written as failing fixtures, shown failing, then the scanner
  lands.
- Phase 1 also runs the scanner, unapplied, over the kit before arming it, so the one expected finding
  (`docs/roadmap.md`) is confirmed and any other is understood before the rule can fail the kit.
- Phase 3 measures over clones of the three adopted projects (never the real ones): `doc-lint.ps1` old and
  new, every flagged document listed, each judged a true or false positive (SC-004). A false positive is a
  rule bug and returns to phase 1 or 2.
- `pwsh -File scripts/ritual-checks.ps1` and `pwsh -File tests/enforcement/Run-Tests.ps1` are the gate. The
  full harness is run on an isolated checkout of the final commit.

## Risks

- **A new hard failure in adopted projects.** Their own `docs/` (a roadmap is one) is scanned, and a finding
  fails their run (decided, FR-011). Mitigation: the phase 3 measurement lists every flagged document before
  release, and the flow-down note says what a finding means and the one-line fix.
- **Renderer differences.** GFM is the target; where renderers disagree the rule is silent (D2, D4 are
  conservative). A rule that cannot be stated without a false positive is dropped, not loosened.
- **A finding the rule is wrong about** blocks every adopter's CI. Mitigation: the false-positive check in
  the testing strategy, and fixtures for the edge cases in the spec (indent, fence, adjacent tables, marker
  after a table).
- **Line endings.** Documents on Windows carry CRLF; the scanner trims line ends and fixtures cover one CRLF
  document.

## Needs the owner

1. **The plan's approval**, then `tasks.md`.
2. **D4's fallback**: if the list measurement finds a false positive, the plan drops the rule and records FR-005
   as unmet by decision. Say now if you would rather block the feature on it.

## Complexity Tracking

No Constitution Check violation to justify.
