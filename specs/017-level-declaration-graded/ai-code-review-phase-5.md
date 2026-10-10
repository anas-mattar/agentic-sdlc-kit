# AI Code Review — 017 Level Declaration Graded (Phase 5)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-11
**Branches**: agentic-sdlc-kit `017-level-declaration-graded` (phase-5 commit `c970b71`)
**Scope reviewed**: `git show c970b71` in full (5 files: `adoption/updating.md` +113/-, `docs/roadmap.md`
+27, `docs/digests/adoption-digest.md` 1 line, `notes.md` +71, `tasks.md` T029-T033 ticks). Read for
context: `spec.md` (FR-015, SC-001..006), `tasks.md` Phase 5, `notes.md`, constitution X (Level
declaration) and its template-sync list, `docs/sdlc/definition-of-done.md`, `critical-delivery.md`,
`branch-strategy.md` (roadmap bracket rule), the spec template, `scripts/enforcement-pack.ps1`
(`Invoke-LevelSurfaceCheck`, `Invoke-LevelRationaleCheck`, `Get-SurfaceExceptions`,
`Get-ConformingRecord`), `scripts/verify-kit.ps1` (doctor lines), the phase 1-4 reviews and notes.
**Feature contract**: phase 5 = T029-T033: flow-down note, adopted-project measurement, manifest
confirmation, digest and roadmap bookkeeping. Territory: `adoption/updating.md`, `docs/roadmap.md`,
`docs/digests/**`, `kit-manifest.json`, the feature's spec dir.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Inputs provided**: commit `c970b71` (`git show --stat` and full diff); the 017 feature documents
  (`spec.md`, `plan.md`, `tasks.md`, `notes.md`, `data-model.md`, `contracts/`); the kit's law
  (`CLAUDE.md`, constitution, `critical-delivery.md`, `branch-strategy.md`, the spec template); the
  phase 1-4 reviews for style; read and run access to the working tree; read-only clones of the three
  adopted projects. No repository file other than this review was modified; the scratch directory
  under `$env:TEMP` (three clones) was removed.
- **Implementer**: claude-sonnet-5-5 (the implementing session)
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVED WITH MINOR FINDINGS (no Blocker, no Major).** I reproduced the measurement end to end on
all three adopted projects and every number in the note, the decisions log and `notes.md` came out the
same. The ten-file list, the single surgical item, the `not armed` line, the unfilled-template
findings, the doctor lines and the digest deltas are all true of the shipped scripts. What remains
is wording that is slightly stronger than the code in one place (F1), one open item the decisions log
does not carry (F2), a status flip that reads as final before the owner's gate (F3), and three notes.
Nothing here changes a verdict or a script.

## What was verified (evidence)

| Check | Result |
|---|---|
| Scope | `git show --stat c970b71`: five files, all in Territory (`adoption/updating.md`, `docs/roadmap.md`, `docs/digests/adoption-digest.md`, the feature dir). No script, template, test, manifest or law document changed. `pwsh -File scripts/scope-check.ps1`: `PASS phase 5 commit c970b71 (5 file(s))`. |
| Amendment authority (constitution I) | `git show --stat c970b71 -- specs/`: `notes.md` (+71) and `tasks.md` (five ticks) only. `spec.md`, `plan.md`, `contracts/`, `data-model.md`, `research.md` untouched. Clean. |
| Lint / digests / roadmap | `doc-lint`: OK (79 shipped files classified, every path resolves). `build-digests.ps1 -Check`: OK, 5 digests fresh, 85 markers. `roadmap-claim-check`: OK. New digest marker is 116 characters (bound 120) and its text equals the line in the digest. The note holds exactly one `<!--`/`-->` pair (the marker); the fenced JSON example sits inside the numbered list and renders. |
| Ten files, one surgical item | `update-kit.ps1 -DryRun -Target <clone of fitforge>` from this branch: `Applied (10)`: spec template, `branch-strategy`, `critical-delivery`, `definition-of-done`, `adoption/updating.md`, `adoption-lib`, `build-digests`, `enforcement-pack`, `markdown-lib`, `verify-kit`. `Surgical (1)`: `.specify/memory/constitution.md`. No conflict. Matches the note exactly, including which five are 017 and which two are 016. |
| `LevelSurface: not armed` | Printed before Territory is read, for a Standard or Micro feature whose level is readable, when `criticalSurfaces` is absent or empty (`enforcement-pack.ps1` 791). Critical, Lite, an unreadable level and a missing spec return earlier and print nothing. The note says "each Standard or Micro feature", which is accurate; "Critical is never failed" is true (the early return). |
| Level Rationale statements | Applies only to Standard/Critical specs carrying `**Rationale Rule**: 1`; no marker is exempt and silent; an unknown value, or a near-miss line, is `UNGRADED` (lines 898-910). I ran the real new spec template (level set to Standard) in a clone: four findings, one per trigger. Matches "one finding per trigger". |
| Doctor line | `verify-kit.ps1` 291/293/295 print exactly the three forms quoted; all three are `ok` findings. One added line on all three projects; verdict unchanged. |
| Measurement, reproduced | Clones at `40ec9e2`, `3d7a472`, `4dca06a`. For every shipped feature: old pack, copy the ten files, new pack, compare. fitforge 1 feature: exit 0/0, one added line (`LevelSurface: not armed`). expense-tracker 3: `001`/`002` exit 1/1 identical (Structure), `003` exit 0/0 plus the one line. flowboard 9: all exit 1/1, zero lines different (`004` reads "no **Delivery Level** header"; `002` and `008` write `**Critical** (...)` and fail "unfilled or invalid"). Doctor: exit 0/0, one added line, all three. `ritual-checks`: `RESULT OK` before; `FAIL (1 of 7)`, the `digests` member, after the ten files; `RESULT OK` after `build-digests.ps1`; markers after: 85 (fitforge), 62 (expense-tracker, flowboard). `git diff --ignore-cr-at-eol --stat -- docs/digests`: adoption +2, critical +1, the other three untouched, in all three. Every figure in the note and in `notes.md` reproduces. |
| FlowBoard claim | True: seven of nine specs have no `**Delivery Level**` line; two have the bold form. Both old and new scripts fail Structure identically. |
| Decisions-log figures | `notes.md` 222-229: 33 patterns, 1,089 ordered pairs, 62 under-reports before, 0 after (and 160 over-reports, the stated direction). The three review-found defects are the ones phases 3 and 4 fixed. The log states them correctly. |
| FR-015 | Delivered earlier and still true: the constitution's template-sync list (line 198) names the four trigger keys and the marker; `definition-of-done.md` 35-37 names the rationale. |
| Roadmap row | Status `shipped`, owner `anas.m`, link unbracketed (the directory exists on this branch). `branch-strategy.md` 51-57 says to drop the brackets when the feature merges; the row ships in the same merge, and `roadmap-claim-check` accepts it. |

## Findings

### F1 — Minor: the note says an unfilled approver name does not count; a bare `TODO` is accepted

`adoption/updating.md` ("A Surface Exception is two lines...") says the exception is validated by
the amendment check's function and that "a reason that is a placeholder, an empty approver or an
unfilled name does not count". Reading `Get-ConformingRecord` (1413): it rejects an approver that is
`{{...}}`, `TODO(`, `[...]` or `<...>`. A name of plain `TODO`, `TBD` or `unknown` passes (the
pattern only needs `(.+?)` and a real date), and so does any invented name. The reason clause and
the empty-approver clause are true; "an unfilled name" is true only for four bracket forms. The
adopter-facing documents (`updating.md`, `critical-delivery.md`, constitution X) say nothing of this;
the only places it is disclosed are the decisions-log entry, `notes.md` and the phase 3 review F3.
The constitution does say that "a named approver agreed" is held by review alone, which covers
identity but not the placeholder word.

**In scope?** Yes (`adoption/updating.md`). **Fix**: replace "an unfilled name" with the four forms the
check rejects (`TODO(...)`, `[...]`, `<...>`, `{{...}}`) and add to "What these checks are not": "a
bare `TODO` approver is accepted; the approver is checked for shape, not identity." The code decision
(tighten the shared function, which the amendment check also uses) stays the owner's, as the log says.

### F2 — Minor: the decisions log omits the one open item that needs an amendment to approved documents

The log lists the `TODO` approver and the bullet syntax as open. It does not carry `LEVEL-011`: the
UNGRADED verdict for a marker the check cannot read is not in the approved `contracts/` section 3 or
the `data-model.md` verdict table, and a trailing prose annotation on the marker line (`1 see below`)
makes the check go UNGRADED with exit 0 (phase 4 F7; `notes.md` "Open, for the owner"). It is in
`notes.md` and the phase 4 review, so it is not hidden, but an owner reading the roadmap decisions log
as the closing record would not see it, and the row says "closed". The updating note does state the
adopter-visible half ("a value other than `1` ... is `UNGRADED`") but not that prose after the `1` has
the same effect.

**In scope?** The log sentence, yes (`docs/roadmap.md`). The contract and data-model additions are an
amendment to approved documents and need the owner's approval line (constitution I); do not make them
here. **Fix**: add one clause to the "Open by decision" list: "the contract and data-model do not yet
list `LEVEL-011` (owner approval pending), and prose after the marker's `1` leaves the spec
`UNGRADED`, not graded."

### F3 — Minor: "shipped" and "closed" are written before the owner's gate and merge

The roadmap row is `shipped`, the log entry opens "Feature 017 shipped; GAP-023 closed", and the
GAP-023 inventory row says "closed by feature 017". The branch is unmerged and `notes.md` itself says
the phase 5 full-harness run "follows". `CLAUDE.md` says the agent never claims success and ci-held
certification belongs to the owner. This is what T032 asked for and what earlier features did on
their branches, so it is process-conformant; but the prose is final-sounding. Also: the status
sentence is joined to the end of the row's candidate-fix text with no full stop ("...rather than
inventing machinery **Status (2026-10-11)**:"); the GAP-025 row, the model it follows, ends its
candidate fix with a period first.

**In scope?** Yes. **Fix**: add the period before `**Status`; optionally prefix the log entry with
"On merge:" or reword to "ships with the owner's gate", so the record is true if the owner rejects.
Not required to merge.

### F4 — Note: the update takes effect on the adopter's next new spec whether or not they have ratified 0.8.0

The note orders the steps correctly (apply, re-express the amendment, `build-digests`, commit) and
says new specs owe the Level Rationale. It does not say plainly that the two checks run from the
moment the scripts land, so an adopter who defers the constitution item is enforcing a rule they have
not ratified, and their own constitution's sync-list line will lack the new constants. It also does
not say that a Micro spec (mini-spec template carries no marker) and a Lite branch do not owe the
rationale; the "applies only to a spec carrying the marker" sentence implies it. Both are small:
the note is true, just not exhaustive. **Fix (optional)**: one sentence under "What to do about it".
Also: the first measure of the note's wrapped text, the "over-reports by design" paragraph, has one
line of about 150 characters among 100-column lines; cosmetic.

### F5 — Note: measurement limits that `notes.md` could name

(a) Each pack run was `-Branch <feature>` at trunk HEAD, so the diff base equals HEAD, zero files
changed and `AmendmentAuthority` prints UNGRADED in every run (seen in the flowboard `002` run).
That is correct for "same run, old script vs new script", but the measurement therefore says nothing
about diff-based members under the new scripts; they are unchanged by this feature. (b) SC-004 says
"exactly one new informational line where no surfaces are declared". FlowBoard gets none (every level
is unreadable) and expense-tracker `001`/`002` get none; the note reports this honestly instead of
rounding, and the verdicts did not move, which is the criterion's substance. (c) No adopter has a
readable Critical spec, so the Critical exemption is from the harness only, which the note states.
(d) The "before" marker counts (82; 59) I did not reproduce separately; the "after" counts (85; 62)
and the deltas (+2, +1) I did. `tasks.md` T030 still says "no surgical file is touched", which the
dry run contradicts (the constitution is surgical); the note and `notes.md` state the true position.
Ticking is right; a remark in `notes.md` would close the loop. No action needed.

### F6 — Note: housekeeping

`docs/roadmap.md` ends without a trailing newline after the new log entry (the file lacked one
before this commit). `git diff --check` reports nothing.

## Checked and clean

- The note's ten-file list, the one surgical item and the "re-express by hand" instruction (section 2
  is the right pointer).
- Surface floor: opt-in, one line when absent or empty, Territory is the union of phases (Micro: the
  spec block), Critical never failed, unusable `criticalSurfaces` / unreadable record / unreadable
  Territory are UNGRADED by name. The "over-reports by design" and "path form, repo prefix" guidance
  matches the contract and the constitution.
- Limits are stated: a claim not proof, the marker can be omitted, the approver's agreement is held by
  review alone, prefix over-reports.
- Order of adopter actions and the first thing that breaks (the `digests` member), both true as
  reproduced.
- Digest marker length and text, digest freshness, doc-lint path resolution (fenced example is why).
- No script, template, test, manifest or approved feature document changed.

## Out of scope, stated not graded

The full harness (`tests/enforcement/Run-Tests.ps1`) was not run here by instruction; `notes.md`
records that a run on the phase 5 commit follows. SC-001..SC-003 and SC-006 are delivered and
reviewed in phases 3-4 (fixtures); SC-005 is a reviewer-time property, not machine-checkable; I did
not re-grade them.

## Recommended disposition

Fix F1 and F2 (wording only, inside Phase 5's Territory) and the F3 punctuation, commit as
`phase 5` remediation, then the owner runs the gate. The `LEVEL-011` contract/data-model amendment
and the decision on tightening the shared approver validator are the owner's, not the implementer's.
