---

description: "Task list for feature 020 — rendered-structure lint"
---

# Tasks: Rendered-structure Lint

**Input**: `specs/020-rendered-structure-lint/spec.md`, `plan.md` (decisions D1–D8)
**Prerequisites**: spec.md and plan.md approved; no new dependency, no new file outside fixtures.

**Tests**: every rule ships with a passing and a failing harness fixture in the same phase as the
behaviour, expectations written by hand (feature 015). New fixtures are run against the parent commit
before the code changes and must fail there, so each is shown to measure something. Phase evidence goes in
`notes.md`, never here.

**Organization**: three phases, each independently revertible. Phase 3 must be reverted before phase 1 or 2.
The full harness is run on an isolated checkout of the final commit, never in a working directory someone is
using.

---

## Phase 1: The table rules (US1, US2; FR-001–FR-004, FR-006–FR-008)

**Purpose**: a table severed by a comment or blank line, a delimiter row with no header, and a ragged row each
fail `doc-lint.ps1`; the one table the kit has already severed is repaired in the same commit so the check
arms on a green kit.

**Territory**:

- `scripts/markdown-lib.ps1`
- `scripts/doc-lint.ps1`
- `tests/**`
- `docs/roadmap.md`

- [ ] T001 Record the baseline on the parent commit in `notes.md`: the counts from
      `pwsh -File tests/enforcement/Run-Tests.ps1 -Case DOC-` and the full run, and the output of
      `doc-lint.ps1`. Run the table scanner as a throwaway prototype over the 37 scanned documents (not
      committed) and record that it reports exactly one finding, the roadmap's inventory table, so the
      rule is armed with its expected result known.
- [ ] T002 Write the fixtures first, `DOC-010` onward, in `tests/enforcement/cases/doc-lint/`: a severed
      row (comment line), a severed row (blank line), a severed delimiter, a ragged row (extra cell and
      missing cell), each as a `fail`; and as `pass` the same document differing only in the condition
      (rows contiguous; delimiter directly under its header; equal counts), a `\|` not counted, two adjacent
      tables with their own headers, a table inside a backtick fence and inside a tilde fence, a row
      indented four spaces, a table at end of file with no trailing blank line, a marker comment after a
      table, and one CRLF document. Expectations by hand. Run them on the parent commit and record that
      each `fail` fails there for the stated reason and each `pass` passes.
- [ ] T003 Add the `DOC-010` onward entries to `tests/enforcement/rules.json` (anchors, law, summary) and the
      new accumulator to the `doc-lint.ps1` entry of `tests/enforcement/emission-idioms.json`, so the
      coverage test sees every new site.
- [ ] T004 Add `Get-StructureFindings` to `scripts/markdown-lib.ps1` (plan D1–D3): given a document's lines
      it returns findings (`Line`, `Rule`, `Detail`), skipping fenced code through `Get-FencedLineMap` and
      multi-line comment blocks as a unit. Update the file's header.
- [ ] T005 Edit `scripts/doc-lint.ps1`: dot-source the library, call the function per scanned document, print
      each finding under an `ERROR:` block as `<file>:<line>  <rule>: <why>`, and count findings into the
      existing issue total and `FAIL` roll-up. The path, slot and manifest checks and their output are
      untouched; update the header's list of what the script grades.
- [ ] T006 Repair `docs/roadmap.md`: remove the blank line inside the inventory table so it is one table
      (plan D8). Confirm no other document is flagged; if one is and the rule is right, repair it and say so
      in `notes.md`.
- [ ] T007 Run `-Case DOC-` and the full harness: every pre-existing case unchanged, every new fixture as
      written, coverage reports each new site fixtured. Run `pwsh -File scripts/ritual-checks.ps1`.

---

## Phase 2: The list rule (US3; FR-005)

**Purpose**: two items of one list split by a comment-only line at column zero fail the lint, and a blank
line between items never does, **if** the measurement says the rule is safe; otherwise the rule is not
shipped and the decision is recorded.

**Territory**:

- `scripts/markdown-lib.ps1`
- `tests/**`

- [ ] T008 Measure the list rule as a throwaway prototype over the 37 scanned documents and over the three
      adopted-project clones (never the real projects): every finding, and for each whether it is a list that
      genuinely renders split. Record the table in `notes.md`.
- [ ] T009 Decide from T008 and record it in `notes.md`: any finding that is not a genuinely severed list
      means the rule is not shipped (plan D4); FR-005 is then recorded as unmet by decision, T010–T012 are
      not done, and the owner is told before the phase closes.
- [ ] T010 Fixtures first, as T002: `fail` a comment line between two items; `pass` the same list with a
      blank line between items, a loose list, a comment indented into an item, a numbered list with `)`, a
      list inside a fence. Run them on the parent commit.
- [ ] T011 Add the list rule to `Get-StructureFindings` (plan D4), with its `rules.json` entry and
      accumulator if the first does not already cover it.
- [ ] T012 Run `-Case DOC-`, the full harness and `ritual-checks.ps1`; nothing pre-existing moves.

---

## Phase 3: Guidance, flow-down and bookkeeping (US4; FR-009–FR-011)

**Purpose**: tell authors where a marker goes, tell adopters what changes and that a finding fails their run,
prove with a measurement that no finding is a false positive, and close the roadmap row. No script changes.

**Territory**:

- `docs/sdlc/review-process.md`
- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/digests/**`
- `kit-manifest.json`

- [ ] T013 [P] Add the marker sentence to `docs/sdlc/review-process.md` (plan D7): a `digest:` marker goes on
      its own line after a block, never inside a table or list, and the check enforces it. Keep any digest
      marker within 120 characters.
- [ ] T014 [P] Add a flow-down note to `adoption/updating.md`: what the check reads and does not (it is not a
      renderer), the findings and the one-line fix for each, that a finding fails an adopted project's run
      (decided, FR-011), which files flow down (`scripts/markdown-lib.ps1`, `scripts/doc-lint.ps1`, and the
      review-process document), and the measurement.
- [ ] T015 Measure on clones of the three adopted projects, never touching the real ones: apply the update,
      run old and new `doc-lint.ps1`, list every document flagged with a true-or-false-positive verdict, and
      run `ritual-checks.ps1` before and after. A false positive is a rule bug and returns to phase 1 or 2.
      Record the table in `notes.md`.
- [ ] T016 Regenerate the digests (`pwsh -File scripts/build-digests.ps1`). Flip the roadmap row for GAP-015
      to `shipped` with its spec link unbracketed, and add the decisions-log entry, stating what stays open
      by decision (including FR-005 if T009 dropped it).
- [ ] T017 Run `pwsh -File scripts/ritual-checks.ps1`, and the full
      `pwsh -File tests/enforcement/Run-Tests.ps1` on an isolated checkout of the final commit. Every member
      OK. Then stop and ask the owner to run the gate.

---

## Dependencies & Execution Order

- Phase 1 first; the table scanner is useful alone and arms the check on a green kit.
- Phase 2 needs phase 1's scanner and can be dropped without touching it.
- Phase 3 needs phases 1 and 2 (the guidance describes what shipped).
- Within a phase, fixtures are written and shown failing before the behaviour lands. `[P]` tasks touch
  different files.

## Implementation Strategy

MVP is phase 1: the recorded defect, detected, and the kit's own instance repaired. Stop after each phase for
the owner's gate; one phase at a time, never ahead.
