---

description: "Task list for feature 016 — multi-line code spans"
---

# Tasks: Multi-line Code Spans

**Input**: `specs/016-multiline-code-spans/spec.md`, `plan.md` (decisions D1–D8) and `research.md` (R1–R5)
**Prerequisites**: spec.md and plan.md approved (joint Draft → Approved commit); no new dependency

**Tests**: The fix is proved through the feature-015 harness. Every behaviour change arrives
with its cases in the same phase. Phase evidence (parent-commit runs, the two mutation runs of
D7, adopter measurements) goes in `notes.md`, never here.

**Organization**: Three phases, each independently revertible, each mapped to the user stories
it serves. Phase order is value-first: the defect closes and is proved, then the next unmodelled
shape is made loud, then adopters are told.

---

## Phase 1: A wrapped code span hides nothing, proved on both consumers (US1, US2)

**Purpose**: GAP-028 proper. The shared function learns paragraphs, both callers move to it in
the same commit, and the cases that prove it land beside it, shown failing on the parent commit.

**Territory**:

- `scripts/markdown-lib.ps1`
- `scripts/enforcement-pack.ps1`
- `scripts/build-digests.ps1`
- `tests/**`

- [ ] T001 [P] [US1] Write the digest cases under
      `tests/enforcement/cases/build-digests/DIGEST-001/`: `pass-wrapped-span` (a paragraph whose
      span opens on one line, holds `<!--`, and closes on the next; a marker in its own block
      after it; the committed digest contains every marker) and `fail-wrapped-span` (the same
      sources, the committed digest missing that marker's rule). Expectations are hand-written
      (plan D6, spec US1 scenarios 1-2).
- [ ] T002 [P] [US1] Write `tests/enforcement/cases/build-digests/DIGEST-001/pass-comment-block-backticks/`:
      a line beginning with `<!--` that holds a backtick, a later line holding `-->` and a second
      backtick, then a marker. Every marker is harvested. This is a guard: it passes today (plan
      D6, spec FR-007).
- [ ] T003 [P] [US2] Write `tests/enforcement/cases/enforcement-pack/AMEND-001/pass-wrapped-span/`:
      an approved `plan.md` holding a wrapped span with `<!--`, then a commit adding a conforming
      approver record after it, named in the commit message. The check passes (spec US2
      scenario 1).
- [ ] T004 [P] [US2] Write `tests/enforcement/cases/enforcement-pack/AMEND-001/fail-hidden-after-unpaired/`:
      a paragraph with an unpaired backtick, then a later block holding a real comment that
      contains a conforming record, then a backtick after the comment's `-->`. The record stays
      hidden and the check fails. This is the no-fail-open guard (spec US2 scenario 3, FR-006).
- [ ] T005 [P] [US2] Write `tests/enforcement/cases/enforcement-pack/AMEND-001/fail-comment-block-backticks/`:
      the HTML-comment-block shape of T002, with the record inside the block. The record stays
      hidden and the check fails (guard, spec FR-007).
- [ ] T006 [US1] [US2] Run T001-T005 against the current scripts and record the result in
      `notes.md`: `pass-wrapped-span` in both rules must FAIL (the defect is real), and every
      guard must PASS (it holds today) (plan Testing Strategy, spec FR-005).
- [ ] T007 [US1] [US2] Rewrite `Convert-CodeSpanMarkers` in `scripts/markdown-lib.ps1` to the
      whole-document form: `-Lines`, same count out as in, each line the same length (D1); the
      paragraph model with generous block starts (D3); HTML comment blocks found on the raw text
      and left on today's single-line treatment (D4); paragraph pairing through the existing
      algorithm over newline-joined lines (D2); early return for a document, and for a paragraph,
      with no backtick or no marker (research R5).
- [ ] T008 [US2] Move `Get-VisibleFromText` in `scripts/enforcement-pack.ps1` to one
      whole-document call, keeping its fence handling and its comment rules unchanged.
- [ ] T009 [US1] Move `Get-DocMarkers` in `scripts/build-digests.ps1` to precompute the scan
      lines once and index them, including the substring after a mid-line comment close (D5).
      The comment state machine, fence state machine and grammar checks do not change.
- [ ] T010 [US1] [US2] Correct the comments that describe the rule as per-line: the header and the
      function comment in `scripts/markdown-lib.ps1`, the GAP-025 comment in
      `scripts/build-digests.ps1`, and the helper note in `scripts/enforcement-pack.ps1`. Each
      states what is and is not modelled (the comment model, F2's shape), not "closed" without
      qualification (spec FR-012).
- [ ] T011 [US1] [US2] Update `tests/enforcement/rules.json`: the `notes` of DIGEST-001 and
      AMEND-001 count and name their new directions (plan D6).
- [ ] T012 [US1] [US2] Run the full suite locally. Every pre-existing case passes unchanged and the
      five new cases pass. Record the counts in `notes.md` (SC-003).
- [ ] T013 [US1] [US2] Mutation (a): revert T007-T009 locally and confirm both `pass-wrapped-span`
      cases fail. Mutation (b): remove the paragraph boundary (pair across the whole document)
      and confirm all three guards fail. Rewrite any guard that survives (b). Record both runs in
      `notes.md` (D7, SC-004).
- [ ] T014 [US1] [US2] Record the deterministic cost in `notes.md`: child processes per check
      before and after (must be equal), and whether the wall-clock delta is inside this machine's
      noise (FR-010, SC-006).

---

## Phase 2: A skipped marker is never skipped silently (US3)

**Purpose**: Defence in depth for the shape the fix does not model. The generator names any
marker it passes over inside a comment, and F2's document becomes a loud failure.

**Territory**:

- `scripts/build-digests.ps1`
- `tests/**`

- [ ] T015 [US3] Measure first: run the phase-2 build of `scripts/build-digests.ps1` in a scratch
      copy against the kit and all three adopted projects (`D:/solutions/fitforge`,
      `D:/solutions/flowboard`, `D:/solutions/expense-tracker`) and record every skipped-marker
      hit in `notes.md`. Expected zero. A hit is resolved with the owner before this phase
      commits (SC-007).
- [ ] T016 [P] [US3] Write `tests/enforcement/cases/build-digests/DIGEST-020/` with `fail` (a
      marker inside a comment opened earlier; the run fails and names the file and line),
      `pass` (the nearest state: the comment closes before the marker; no report) and
      `fail-f2-shape` (015 review F2's three-marker document verbatim) (plan D6, spec US1
      scenario 3, US3).
- [ ] T017 [US3] Run T016 against the phase-1 scripts and record in `notes.md` that `fail` and
      `fail-f2-shape` do not produce the report today (spec FR-005).
- [ ] T018 [US3] Implement the report in `Get-DocMarkers` in `scripts/build-digests.ps1`: a line
      matching the marker grammar, passed over because a comment is open, adds
      `skipped digest marker: <path>:<line> — it sits inside a comment opened earlier in the file`
      to the issues, and the run fails (D8, FR-009).
- [ ] T019 [US3] Add DIGEST-020 to `tests/enforcement/rules.json` with its emit anchor
      `skipped digest marker:`, the law it enforces, and notes naming its three directions, and
      confirm the coverage check counts it (FR-008).
- [ ] T020 [US3] Check DIGEST-005's cases: its unclosed malformed marker deliberately opens a
      comment block, so a marker after it may now also be reported. If any pre-existing expectation
      changes, stop and raise it with the owner before editing it, because SC-003 promises the
      existing cases pass unchanged. Record the outcome in `notes.md`.
- [ ] T021 [US3] Run the full suite and mutation (a) for this phase: with T018 reverted, `fail`
      and `fail-f2-shape` must fail. Record both in `notes.md` (SC-004).

---

## Phase 3: Adopters are told, and the prediction is checked (FR-011)

**Purpose**: Confirm on real repositories that nothing an adopter sees changes except where it
should, and write the flow-down note.

**Territory**:

- `adoption/updating.md`
- `docs/digests/*-digest.md`

- [ ] T022 Run `pwsh -File scripts/update-kit.ps1 -DryRun -Target <project>` from this branch
      against each adopted project and record what would flow down (the three scripts, verbatim;
      no surgical file expected) in `notes.md`.
- [ ] T023 In a scratch copy of each adopted project with this branch's three scripts applied,
      regenerate digests and run `ritual-checks`. Record in `notes.md` whether every digest is
      byte-identical and every verdict unchanged (SC-005, FR-011).
- [ ] T024 Write the flow-down note in `adoption/updating.md`: what changed (a span wrapping within
      a paragraph now hides nothing), the new DIGEST-020 failure and its remedy (delete a marker
      commented out on purpose, or close the comment above it), what T023 measured, and that F2's
      shape is reported, not fixed (FR-011).
- [ ] T025 Regenerate the kit's digests (`pwsh -File scripts/build-digests.ps1`) and confirm the
      freshness check is green.
- [ ] T026 Draft the new gap for the owner in `notes.md`, for a main-side docs PR after merge: the
      kit's comment model disagrees with a renderer on an unpaired `<!--` in prose (research R1,
      row 2), with the measured evidence (spec Out of Scope).

---

## Dependencies

- Phase 1 blocks phase 2: the skipped-marker report is only meaningful once the span fix stops
  wrapped spans from producing it.
- Phase 3 depends on phases 1 and 2, because it measures and describes what they changed.
- Within phase 1, T001-T005 are independent of each other ([P]) and must all exist before T006.
  T007 precedes T008 and T009, which change the callers of the new signature. T012-T014 follow
  T007-T011.
- Within phase 2, T015 comes first, because a hit in an adopted project changes what the phase
  may land.

## Notes

- A defect found in a script outside the current phase's Territory is **recorded in `notes.md`,
  not fixed in place**. Widening Territory mid-phase requires an owner-approved amendment
  committed before the phase commit that relies on it (constitution I; the check reads the
  declaration from the commit's parent).
- Every phase commit carries a `phase N` token in its subject so the scope check can attribute
  it. A `docs:` commit on this branch writes "gate N", never "phase N".
- Every phase takes a fresh-context AI review with the Reviewer Provenance block before human
  review. Phase 1's brief names the fail-open direction explicitly: does any case let a record
  inside a real comment count?
- Under ci-held, a phase commit is pushed alone so the CI run certifies that exact sha.
- This feature's own documents quote `<!--` inside code spans. Before each commit, confirm none of
  those spans wraps across lines, or the defect this feature closes would hide the feature's own
  approval records from the amendment check.
