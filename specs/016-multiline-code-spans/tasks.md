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

- [x] T001 [P] [US1] Write the digest cases under
      `tests/enforcement/cases/build-digests/DIGEST-001/`: `pass-wrapped-span` (a paragraph whose
      span opens on one line, holds `<!--`, and closes on the next; a marker in its own block
      after it; the committed digest contains every marker) and `fail-wrapped-span` (the same
      sources, the committed digest missing that marker's rule). Expectations are hand-written
      (plan D6, spec US1 scenarios 1-2).
- [x] T002 [P] [US1] Write `tests/enforcement/cases/build-digests/DIGEST-001/pass-comment-block-backticks/`:
      a line beginning with `<!--` that holds one backtick, a later line holding `-->` and two
      backticks, then a later paragraph quoting `<!--` in a span of its own, then a marker. Every
      marker is harvested. This is a guard: it passes today, and fails under a fix that pairs
      spans across the block (plan D6, D7, spec FR-007).
- [x] T003 [P] [US2] Write `tests/enforcement/cases/enforcement-pack/AMEND-001/pass-wrapped-span/`:
      an approved `plan.md` holding a wrapped span with `<!--`, then a commit adding a conforming
      approver record after it, named in the commit message. The check passes (spec US2
      scenario 1).
- [x] T004 [P] [US2] Write `tests/enforcement/cases/enforcement-pack/AMEND-001/fail-hidden-after-unpaired/`:
      a paragraph with an unpaired backtick, then a later block holding a real comment that
      contains a conforming record, then a backtick after the comment's `-->`. The record stays
      hidden and the check fails. This is the no-fail-open guard (spec US2 scenario 3, FR-006).
- [x] T005 [P] [US2] Write `tests/enforcement/cases/enforcement-pack/AMEND-001/pass-comment-block-backticks/`:
      an HTML comment block with a backtick on its first line and another on its closing line,
      then a conforming record after the block. The record is visible and the check passes. A
      fix that paired across the block would disarm its closing arrow and hide the record (guard,
      spec FR-007).

**Amendment approved by**: anas.m, 2026-09-30

T002 and T005 changed after approval because the guards as first written could not fail under
D7(b), so they measured nothing. The reasoning is in `notes.md`, phase 1.
- [x] T006 [US1] [US2] Run T001-T005 against the current scripts and record the result in
      `notes.md`: `pass-wrapped-span` in both rules must FAIL (the defect is real), and every
      guard must PASS (it holds today) (plan Testing Strategy, spec FR-005).
- [x] T007 [US1] [US2] Rewrite `Convert-CodeSpanMarkers` in `scripts/markdown-lib.ps1` to the
      whole-document form: `-Lines`, same count out as in, each line the same length (D1); the
      paragraph model with generous block starts (D3); HTML comment blocks found on the raw text
      and left on today's single-line treatment (D4); paragraph pairing through the existing
      algorithm over newline-joined lines (D2); early return for a document, and for a paragraph,
      with no backtick or no marker (research R5).
- [x] T008 [US2] Move `Get-VisibleFromText` in `scripts/enforcement-pack.ps1` to one
      whole-document call, keeping its fence handling and its comment rules unchanged.
- [x] T009 [US1] Move `Get-DocMarkers` in `scripts/build-digests.ps1` to precompute the scan
      lines once and index them, including the substring after a mid-line comment close (D5).
      The comment state machine, fence state machine and grammar checks do not change.
- [x] T010 [US1] [US2] Correct the comments that describe the rule as per-line: the header and the
      function comment in `scripts/markdown-lib.ps1`, the GAP-025 comment in
      `scripts/build-digests.ps1`, and the helper note in `scripts/enforcement-pack.ps1`. Each
      states what is and is not modelled (the comment model, F2's shape), not "closed" without
      qualification (spec FR-012).
- [x] T011 [US1] [US2] Update `tests/enforcement/rules.json`: the `notes` of DIGEST-001 and
      AMEND-001 count and name their new directions (plan D6).
- [x] T012 [US1] [US2] Run the full suite locally. Every pre-existing case passes unchanged and the
      five new cases pass. Record the counts in `notes.md` (SC-003).
- [x] T013 [US1] [US2] Mutation (a): revert T007-T009 locally and confirm both `pass-wrapped-span`
      cases fail. Mutation (b): remove the paragraph boundary (pair across the whole document)
      and confirm all three guards fail. Rewrite any guard that survives (b). Record both runs in
      `notes.md` (D7, SC-004).
- [x] T014 [US1] [US2] Record the deterministic cost in `notes.md`: child processes per check
      before and after (must be equal), and whether the wall-clock delta is inside this machine's
      noise (FR-010, SC-006).

**Phase-1 review remediation** (review F1 BLOCKING, F3; plan D9):

- [x] T014a [US2] Write three AMEND-001 fail directions from the review's F1 documents:
      `fail-hidden-backslash-closer`, `fail-hidden-autolink-backtick` and
      `fail-hidden-pre-block`. Each holds a record inside a real comment and expects FAIL. Run them
      on `7a770e5` and record in `notes.md` that each wrongly passes there (the fail-open is real).
- [x] T014b [US2] Implement D9 in `scripts/markdown-lib.ps1`: the per-line fallback for a
      paragraph with a backslash touching a backtick, or a tag, autolink, comment or link
      destination before a backtick on a line; and raw HTML block ends by CommonMark's rule.
- [x] T014c [US1] [US2] Correct the comments the review found overstated (F3): the phase-2 report
      described as present, the claim that a stray backtick cannot disarm a real comment, and the
      raw HTML description. Update AMEND-001's `notes` in `tests/enforcement/rules.json`.
- [x] T014d [US1] [US2] Run the full suite, then mutations (c) and (d) of D9, each failing the cases
      it guards. Record both, and the dispositions of review F2 and F4, in `notes.md`.

**Amendment approved by**: anas.m, 2026-09-30

**Phase-1 round-2 remediation** (round-2 review F1 BLOCKING, F3, F4; plan D10):

- [x] T014e [US2] Write four AMEND-001 fail directions: `fail-hidden-list-div`,
      `fail-hidden-list-pre` and `fail-hidden-comment-tick`, from the round-2 review's
      documents (a), (b) and (h); and `fail-hidden-html-block-open`, a comment opened inside a
      raw HTML block and left open across a blank line, before the record. Run them on
      `6f75415` and record in `notes.md` that the first three wrongly pass there, and that the
      guard holds there.
- [x] T014f [US1] Write the DIGEST-001 pass direction `pass-tail-after-close` from round-1 F2's
      second document (both markers harvested), and record that `6f75415` fails it.
- [x] T014g [US1] [US2] Rewrite `Convert-CodeSpanMarkers` in `scripts/markdown-lib.ps1` to D10.
      This removes paragraph pairing and the D9 doubt rule. Correct every comment that
      describes paragraph pairing, in `scripts/markdown-lib.ps1`, `scripts/build-digests.ps1`
      and `scripts/enforcement-pack.ps1` (round-2 F3). Update the DIGEST-001 and AMEND-001
      `notes` in `tests/enforcement/rules.json`.
- [x] T014h [US1] [US2] Run the full suite and mutations (a), (e) and (f), each failing the cases
      it guards. Check D1 over every kit `.md` file, and re-run the round-1 and round-2 review
      documents. Record all of it in `notes.md`.

**Amendment approved by**: anas.m, 2026-09-30

**Phase-1 round-3 remediation** (round-3 review F1, F3-F5; plan D11; spec US2 as amended):

- [x] T014i [US1] Write the five DIGEST-001 guards of D11, each a marker inside a real comment
      with a correct digest on disk that omits it: `pass-hidden-nbsp-line`,
      `pass-hidden-pre-under-tag-line`, `pass-hidden-pre-in-misread-fence`,
      `pass-hidden-html-block-open` and `pass-hidden-after-backslash-spans`. Run them on
      `8e45e37` and record which fail there.
- [x] T014j [US2] Replace AMEND-001 `pass-wrapped-span` with `fail-wrapped-span-hidden` (the
      same document, expecting FAIL), and point `Get-VisibleFromText` back at per-line
      `Convert-SpanText` (D11).
- [x] T014k [US1] Apply the round-3 F1 fixes to `Convert-CodeSpanMarkers`: a blank line is
      spaces and tabs only; a long-ending block start switches the tracker; and a document with
      no candidate opener returns early (FR-010 as amended). Correct every comment and note the
      round-3 review found overclaiming (F5). Update the DIGEST-001 and AMEND-001 `notes` in
      `tests/enforcement/rules.json`.
- [x] T014l [US1] [US2] Run the full suite and mutations (a), (e), (f), (g) and (h). Check D1.
      Compare `Get-VisibleFromText` with the parent's over every `.md` file in the kit and the
      three adopted projects. Record all of it in `notes.md`, with the GAP-028 limitation drafted
      for the owner's gap row beside T026's.

**Amendment approved by**: anas.m, 2026-09-30

**Phase-1 round-4 remediation** (round-4 review F1, F2, F4; FR-003 as amended, digest consumer):

- [x] T014m [US1] Fix the digest rule's raw HTML tracker in `scripts/markdown-lib.ps1`.
      - When a block with a longer end closes inside a block that ends at a blank line, the
        tracker returns to the enclosing block.
      - A start of a block ending at a blank line is honoured on a line the fence map calls
        fenced.
      - Write DIGEST-001 guards for the round-4 F1 documents (show each harvesting the hidden
        marker on `b45cff1`), and for the ends round-4 F2 found unguarded: the container
        markers, and the comment, processing-instruction, CDATA and declaration ends.
      - Correct the comments and notes round-4 F4 found overclaiming.
      - Run the full suite, a mutation for each newly guarded rule, and the amendment-reading
        parity check. Record all of it in `notes.md`.

**Amendment approved by**: anas.m, 2026-09-30

**Phase-1 round-5 remediation** (round-5 review F1, F3; FR-003 as amended, digest consumer;
plan D11 as amended after round 5):

- [x] T014n [US1] Fix the tag-line raw-text branch of the digest tracker in
      `scripts/markdown-lib.ps1`.
      - A tag line that opens a `pre`, `script`, `style` or `textarea` element after its first
        tag returns, when the element closes, to the blank-ending block the line itself starts.
      - Write DIGEST-001 `pass-hidden-*` guards for the round-5 F1 shapes: at least the
        same-line close (n3 `<div><script src="a.js"></script>`), the later-line close (n2) and
        a container form (n6 or n7). Show each harvesting the hidden marker on `c6d95a1`.
      - Record mutation (n) (the tag-line start returns to inline text) and show it fails those
        guards.
      - Correct the overclaiming sentences round-5 F1 names: the `markdown-lib.ps1` comment
        ("never fewer") and `notes.md` ("Each change disarms less, never more").
      - Run the full suite, mutations (e)-(n), the amendment-reading parity check and the corpus
        harvest comparison. Record all of it in `notes.md`.

**Amendment approved by**: anas.m, 2026-10-01

**Phase-1 round-6 follow-up** (round-6 review F1, F2; FR-003 as amended, digest consumer; plan
D11 as amended after round 6):

- [x] T014o [US1] Guard the exclusion and model a same-line reopen in `scripts/markdown-lib.ps1`.
      - Write a DIGEST-001 direction for round-6 `v05` (`<pre>x</pre>`, then a wrapped
        `` `<!--`` span, then a visible marker the digest must carry). Show it fails under
        mutation (o), the exclusion removed.
      - Write DIGEST-001 `pass-hidden-*` guards for round-6 `q01` (`<div><script>a</script><script>`),
        `q02` (top-level `<script>a</script><script>`) and `q03` (`</script><script>` on a later
        line). Show each harvesting the hidden marker on `517f9d2`.
      - Implement it: a raw-text end counts only when no raw-text element opens after the line's
        last raw-text close, on the start line and on a later line alike. Record mutation (p).
      - Name the other raw-text elements (`title`, `xmp`, `iframe`, `noembed`, `noframes`) in the
        library's "Not modelled" paragraph.
      - Run the full suite, mutations (e)-(p), the corpus and review-document harvest comparison,
        and the round-5/6 probe documents. Record all of it in `notes.md`.

**Amendment approved by**: anas.m, 2026-10-01

**Phase-1 round-7 remediation** (round-7 review F1, F2; FR-003 as amended, digest consumer; plan
D11 as amended after round 7):

- [x] T014p [US1] Withdraw the reopen rule from `scripts/markdown-lib.ps1`.
      - Write DIGEST-001 `pass-hidden-*` guards for round-7 `b04`, `b08` and `b09`. Show each
        harvesting the hidden marker on `c565240`.
      - Remove `Test-HtmlBlockEnd`; a raw-text end counts wherever it falls, as on `517f9d2`.
      - Replace the three reopen guards with one case, `fail-reopen-not-modelled` (round-6
        `q01`), that expects the visible-only digest to be read as stale and pins the limitation.
        Keep `pass-wrapped-after-closed-pre`.
      - Rewrite the "Not modelled" paragraph to name the reopen and the round-7 F2 forms.
      - Run the full suite, mutations (e)-(o), the corpus and review-document harvest comparison
        (against `517f9d2`), and the round-5/6/7 probe documents. Record all of it in `notes.md`.

**Amendment approved by**: anas.m, 2026-10-01

**Phase-1 round-8 remediation** (round-8 review F1, F2, F3; FR-003 as amended after round 8,
digest consumer; plan D11 as amended after round 8):

- [ ] T014q [US1] Record the three routes in `scripts/markdown-lib.ps1`; no behaviour change.
      - Write DIGEST-001 pins `fail-fence-long-end-not-modelled` (round-8 `c01`),
        `fail-indented-long-end-not-modelled` (`c02`) and `fail-container-long-end-not-modelled`
        (`c03`). Each expects the visible-only digest to be read as stale; show each so on
        `3ad7408`.
      - Extend the "Not modelled" paragraph with the three routes and the consequence that a real
        comment's opener may be disarmed. Replace the "only effect" sentence at the long-end start.
        Fix the F2 wording there and in `fail-reopen-not-modelled`'s description.
      - Confirm the library's non-comment token stream equals `3ad7408`'s.
      - Run the full suite, mutations (e)-(o), the corpus and review-document harvest comparison
        (against `3ad7408`), and the round-5 to round-8 probe documents. Record all of it, and F3
        (`j-long` unguarded, beside `c1`), in `notes.md`.

**Amendment approved by**: anas.m, 2026-10-02

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
