# Implementation Plan: Multi-line Code Spans

**Branch**: `016-multiline-code-spans` | **Date**: 2026-09-27 | **Spec**: specs/016-multiline-code-spans/spec.md
**Input**: Feature specification + research.md (R1–R5) + decisions D1–D8 below
**Gate Batching**: none
**Gate Certification**: ci-held

## Summary

Teach the one shared code-span function to see a span that wraps within a paragraph, and prove
it through both consumers before either trusts it. Then make the generator loud about any marker
it skips, so the next shape nobody modelled cannot cost a rule silently.

Three phases, each independently revertible. The fix and its proof land together in phase 1,
test-first in the sense 015's D11 defined: the cases are shown failing on the parent commit and
passing on the fix. Phase 2 adds the skipped-marker report, which is a new failure adopters can
see, so it is measured against all three adopted projects before it lands. Phase 3 tells
adopters and corrects the documents that describe the old behaviour.

The change reaches adopted projects as verbatim script updates. Research R2 predicts it changes
nothing they can see: one wrapped span holding a marker in 558 files, in a file neither consumer
reads. Phase 3 checks that prediction instead of assuming it.

## Technical Context

**Language**: PowerShell 7, the kit's only scripting surface. **Testing**: the feature-015
fixture harness (`tests/enforcement/`, Pester 5 pinned, real temporary git repositories,
hand-written literal expectations). **No new dependency.** The CommonMark renderer used in
research R1 was a measuring instrument in a scratch directory. It is not installed by the kit, and
no fixture expectation is computed with it. Every expectation is written by hand, as 015's D1
requires. **Target platform**: `ubuntu-latest` and `windows-latest`, both CI legs, as 015's SC-006
established. **Constraints**: every function in `scripts/markdown-lib.ps1` stays pure (no git, no
file system). A line with no backtick costs what it costs today. **Scale**: one shared library
(101 lines), two call sites, about ten new fixture directions.

**Phase-sizing**: three phases. Phase 1 is the whole behaviour change plus its proof, because a
fix without its cases cannot be reviewed and cases without their fix cannot be committed green.
Phase 2 is a separate new failure mode with its own adopter exposure, revertible without undoing
phase 1. Phase 3 changes no behaviour.

## Decisions

**D1 — One function, whole-document signature, length-preserving.** `Convert-CodeSpanMarkers`
changes from `-Line <string>` to `-Lines <string[]>`, returning the same number of lines, each the
same length as its input (research R3). There is no single-line wrapper. The only two callers
move to the new signature in the same phase, so no second implementation exists at any commit
(FR-001). Length preservation is what keeps `build-digests.ps1`'s substring arithmetic after a
comment closes correct.

**D2 — Paragraph pairing reuses today's pairing, over joined lines.** Within a paragraph that
holds both a backtick and a marker, the lines are joined with `"\n"` and today's algorithm runs
unchanged over the joined text: unescaped runs, pair with the next run of exactly the same
length, disarm between. The result is split back on `"\n"`. A backtick run cannot contain a
newline, so the join creates no false runs, and the reviewed pairing logic is reused rather than
rewritten.

**D3 — When in doubt, break the paragraph.** FR-003's block starts are recognised generously: any
indentation before a list marker, block quote or table row counts, and so do setext underlines
and any line beginning with an HTML tag. Every extra break moves the result back toward today's
per-line behaviour, which is the reviewed baseline, and never beyond it. A line where the
generous rule and a renderer disagree therefore costs at most what it costs today.

**D4 — HTML comment blocks are found on the raw text and left exactly as today.** A block opens on
a line whose first non-space text (at most three spaces of indent) is `<!--` and ends on the first
line, the opening line included, whose raw text holds `-->` after the opener (research R1, row 3).
Its lines join no paragraph. Each keeps today's single-line treatment, so every existing case that
touches such a line is unaffected (FR-004).

**D5 — `build-digests.ps1` precomputes, then indexes.** `Get-DocMarkers` reads the file once, calls
the function once for the whole document, and inside its loop reads `$scanLines[$i]` in place of
calling the function per line. After a comment closes mid-line, it takes the same substring of the
precomputed line (`$scanLines[$i].Substring($close + 3)`). The comment state machine, the fence
state machine and the grammar checks that read `$rawLine` do not change.

**D6 — Cases join existing rules as named directions, and the one new failure is a new rule.** The
digest cases are new directions under DIGEST-001, beside GAP-025's pair: the wrapped-span document
with a correct digest (`pass-wrapped-span`) and with the rule missing (`fail-wrapped-span`). The
amendment cases are new directions under AMEND-001: a visible record after a wrapped span
(`pass-wrapped-span`), and two guards, `fail-hidden-after-unpaired` (no-fail-open, FR-006) and
`fail-comment-block-backticks` (the HTML comment block, FR-007). The digest consumer's comment-block
guard is `pass-comment-block-backticks` under DIGEST-001. The skipped-marker report of phase 2 is a
new rule, **DIGEST-020**, with `pass` and `fail` directions and F2's document as a third direction
(`fail-f2-shape`). Each rule's `notes` field in `rules.json` is updated to count and name its
directions, as AMEND-001's already does.

**D7 — Two mutations, recorded.** SC-004 is shown with two local mutation runs recorded in
`notes.md`: (a) the fix reverted, where every case the fix turns green must fail; (b) the paragraph
boundary removed, where every guard must fail, which proves the guards can see an over-reaching
fix. A guard that passes under (b) is rewritten until it fails there.

**D8 — The skipped-marker report fails, and names itself distinctly.** A line matching the digest
marker grammar that `Get-DocMarkers` passes over because `$inComment` is set produces
`skipped digest marker: <path>:<line> — it sits inside a comment opened earlier in the file`.
The run fails, following the fail-closed precedent of DIGEST-005 (015 review F6/F7). The message
does not begin with `malformed digest marker:`, so the two rules keep distinct emit anchors for the
coverage check (FR-008, FR-009). A marker commented out on purpose is deleted instead, and the
flow-down note says so.

## Constitution Check

Source: `.specify/memory/constitution.md` (version 0.7.0).

- [x] **Specification First (I)**: `spec.md` is written, and the owner approved its content on
      2026-09-27. The Draft → Approved flip is deferred to the joint spec-and-plan approval
      commit, as 015 did, so the correction this plan made to the spec (see Complexity
      Tracking) lands before the amendment rule starts. `tasks.md` follows this file.
- [x] **Source of Truth (II)**: No conflict. Research R1 corrects a claim in 015's review (F2's
      reproduction). A review is not a rung, and the correction is stated openly in the spec.
- [x] **Repository Separation (III)**: N/A. The kit is a single governance repository with no
      `codeRepos` declared.
- [x] **Architecture Consistency (IV)**: No new dependency, no new manifest class, no new script.
      One shared function changes signature, and both callers move with it in one phase.
- [x] **Domain Invariants (V)**: N/A. The kit declares no domain-invariants pack.
- [x] **Security (VI)**: No secrets, no network at run time. The one hazard is a fail-open in
      amendment grading, which FR-006's guard and D7(b)'s mutation exist to exclude.
- [x] **External Integration Governance (VII)**: N/A. No external integration.
- [x] **Testing Requirements (VIII)**: Every behaviour change arrives with pass and fail cases in
      the harness, shown failing on the parent commit and backed by two recorded mutation runs.
- [x] **Human Review (IX)**: Every phase takes a fresh-context AI review with the Reviewer
      Provenance block, then human review before merge. Phase 1's review brief names the
      fail-open direction explicitly.
- [x] **Controlled Delivery (X)**: Three phases, one at a time, each its own commit with a declared
      Territory. `ci-held` certification, declared here before the first phase.

## Project Structure

### Documentation (this feature)

```text
specs/016-multiline-code-spans/
├── spec.md
├── plan.md              # this file
├── research.md          # R1-R5, the measured evidence
├── tasks.md
├── notes.md             # per-phase evidence: parent-commit runs, mutation runs, flow-down measurements
├── checklists/requirements.md
├── ai-code-review-phase-N.md   # per phase, from specs/_templates/
└── human-pr-review.md          # at merge, from specs/_templates/
```

No `data-model.md`, `contracts/` or `quickstart.md`. The feature adds no data, no external
interface and no new command. The function's contract is D1, and the key entities are defined in
the spec.

### Source Code (repository root)

```text
scripts/markdown-lib.ps1                 # MOD  phase 1 — paragraph-aware Convert-CodeSpanMarkers (D1-D4); header corrected (FR-012)
scripts/enforcement-pack.ps1             # MOD  phase 1 — Get-VisibleFromText calls the whole-document form
scripts/build-digests.ps1                # MOD  phase 1 — precompute and index (D5); phase 2 — the skipped-marker report (D8)
tests/enforcement/cases/enforcement-pack/AMEND-001/**   # NEW directions, phase 1 (D6)
tests/enforcement/cases/build-digests/DIGEST-001/**     # NEW directions, phase 1 (D6)
tests/enforcement/cases/build-digests/DIGEST-020/**     # NEW rule, phase 2 (D6, D8)
tests/enforcement/rules.json             # MOD  phases 1-2 — direction notes; DIGEST-020
adoption/updating.md                     # MOD  phase 3 — the flow-down note (FR-011)
```

**Structure Decision**: Everything the feature changes already exists, except the DIGEST-020 case
directory. `tests/` is `kit-only` (015's D3) and never flows down. The three scripts do, as
verbatim files.

## Testing Strategy

- **Proved against the parent commit, not against itself.** Phase 1's green-turning cases are run
  against the parent commit's scripts and shown failing, then against the fix and shown passing
  (015's D11). Both runs go in `notes.md`.
- **Guards proved by the mutation they guard against** (D7(b)). A no-fail-open guard that cannot
  fail under an over-reaching fix measures nothing.
- **Expectations are hand-written.** No expected output is produced by running the code under
  test or the research renderer (015's D1).
- **The whole suite, both platforms.** Every pre-existing case must stay green on both CI legs
  (SC-003). 015's keeper is that a check green on one platform proved nothing about the other.
- **Adopter reality before shipping.** Phase 2 runs the generator against all three adopted
  projects before its commit (SC-007). Phase 3 regenerates their digests and runs `ritual-checks`
  (SC-005, FR-011).

## Complexity Tracking

| Addition | Why needed | Simpler alternative rejected because |
|---|---|---|
| A paragraph model inside the shared function (D3, D4) | A span may only pair within its paragraph, or it disarms real comments in later blocks (FR-003, 014's H1) | Pairing across the whole document is the H1 fail-open. Pairing across adjacent lines without a boundary rule breaks multi-line HTML comments that work today (research R1, row 3) |
| The skipped-marker report (D8) | F2's shape stays a comment-model disagreement after the fix. Without the report it keeps costing a rule silently | Fixing the comment model to agree with a renderer changes the unterminated-comment rule amendment grading relies on (research R1, alternatives) |

**A spec correction this plan made, before approval.** Research R1 showed that the spec's first
draft promised 3 of 3 markers on F2's document, which a code-span fix cannot deliver: that
document's loss comes from the comment model. It also showed the HTML comment block needs its own
boundary. The spec was corrected on this branch while still Draft (US1 scenario 3, FR-003,
FR-005, FR-007, SC-001, SC-004, Context, Edge Cases, Out of Scope). The owner's approval of the
joint spec and plan covers the corrected text.

**The risk this plan carries knowingly.** D8 introduces a new failure in a verbatim script. An
adopted project with a digest marker inside a comment would go red on its next update. Phase 2
measures all three before landing, and phase 3's flow-down note names the rule and the remedy.
