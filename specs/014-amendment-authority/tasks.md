# Tasks: Amendment Authority

**Input**: Design documents from `/specs/014-amendment-authority/`
**Prerequisites**: plan.md (decisions D1–D10), spec.md

**Tests**: business-critical governance logic (constitution VIII). A wrong PASS leaves the rule
exactly as unenforced as it is today; a wrong FAIL blocks every branch in every adopted project.
Deterministic validation is the seeded S1–S14 fixtures below plus replay over real merged
history (phase 3). No test framework (kit convention since 006).

**Organization**: one delivery phase per plan-table row. **Gate Batching: none** and **Gate
Certification: ci-held** (both declared in plan.md). Phase commits carry `phase N` subjects;
Territory per phase (006 law).

**This feature is graded by its own rule from phase 1 onward.** Once the clause lands, any
further change to this file, `plan.md` or `spec.md` carries its own
`**Amendment approved by**: <name>, <YYYY-MM-DD>` line and names the approver in the commit.

## Fixture scenarios (S1–S14)

Each is a throwaway git repository under the scratchpad with a `specs/NNN-x/` and a built
commit sequence. Expected verdicts are fixed here, before the check exists.

| # | Scenario | Expected |
|---|---|---|
| S1 | Branch whose only commit creates `spec.md`, `plan.md`, `tasks.md` | PASS (creation, D2) |
| S2 | Later commit amends `plan.md` with a conforming record line and the name in the message | PASS |
| S3 | Later commit amends `plan.md` with no record anywhere | FAIL, names `plan.md` |
| S4 | Record line present, commit message names a different person | FAIL, names both |
| S5 | Record line with an empty name | FAIL (D6) |
| S6 | Record line with an unreplaced slot or a `TODO(...)` marker | FAIL (D6) |
| S7 | Record date `2026-13-45` (not a real date) | FAIL (D6) |
| S8 | Record date later than the commit's author date | FAIL (D6) |
| S9 | Commit flips `- [ ]` to `- [x]` in `tasks.md` and nothing else | PASS (D3) |
| S10 | Commit flips checkboxes **and** rewords a task | FAIL (D3, spec US3 scenario 3) |
| S11 | Commit amends `contracts/auth.md` with no record | FAIL, names the contract |
| S12 | Merge commit touching every feature document | PASS, skipped (D7) |
| S13 | Branch renumbered — documents appear at a new path | PASS (creation at the new path, D2) |
| S14 | Micro feature: `spec.md` only, amended without a record | FAIL (D8) |

Plus two negative-space checks: a `fix/` branch with no `specs/` directory PASSES silently
(D8), and one commit amending `plan.md` and `tasks.md` together with a **single** record line
PASSES (D4).

---

## Phase 1: The law states the rule 🎯 MVP

**Goal**: the constitution carries the Amendment authority clause, and every kit document that
restates the law agrees with it. No machine change — reverting everything after this phase
still leaves a ratified rule enforced by review, which is exactly where FitForge stands today.

**Independent Test**: a reader who knows nothing of this feature can find, in the constitution,
what a conforming amendment record looks like and what the kit does and does not verify about
it; `ritual-checks.ps1` is green; the digests match their markers.

**Territory**:

- `.specify/memory/constitution.md`
- `CLAUDE.md`
- `docs/sdlc/review-process.md`
- `docs/sdlc/definition-of-done.md`
- `docs/digests/`

- [ ] T001 Add **Amendment authority** to constitution Principle I, adopting FitForge 1.1.0's
      wording (D9): scope (`spec.md`, `plan.md`, `tasks.md`, `contracts/`), the record shape
      `**Amendment approved by**: <name>, <YYYY-MM-DD>`, the same approver named in the commit,
      and "an implementing agent MUST NOT approve its own amendment". Keep the sentence
      "Amending before implementing satisfies the sequence; it does not satisfy this rule" —
      it is the finding F3 lesson in one line
- [ ] T002 Add the checkbox exemption to the clause (D3): completion state is progress, not
      amendment. It belongs in the law, not only in the script — a rule whose survivability
      lives in an implementation detail is one nobody can reason about
- [ ] T003 Add the honesty paragraph (D10): the record is a written claim a reviewer can
      falsify, not an authentication; in a solo project the approver is the same human who ran
      the session. State it the way `docs/sdlc/critical-delivery.md` states it of the team arm
- [ ] T004 Record where the kit's wording differs from FitForge 1.1.0 and why, in this file
      under a "Phase 1 — wording reconciliation" section, so the flow-down reconciles rather
      than collides (D9)
- [ ] T005 Update the SYNC IMPACT REPORT header and bump the version to **0.7.0** (MINOR — a
      new rule inside an existing principle). Confirm `scripts/enforcement-pack.ps1` is already
      in the sync list (it is, since the GAP-002 fix) and that no other sync-listed file's
      reading changed
- [ ] T006 `CLAUDE.md` Strict Rules: one line — an amendment to an approved feature document
      records its approver. Point at the constitution; do not restate the clause
- [ ] T007 `docs/sdlc/review-process.md`: the human reviewer's checks gain "every amendment in
      the feature diff carries its record" (FR-012)
- [ ] T008 `docs/sdlc/definition-of-done.md`: gates 5 and 6 read the amendment record as part
      of the full feature diff (FR-012)
- [ ] T009 Add digest markers for the new rule where the pack conventions call for one, run
      `pwsh -File scripts/build-digests.ps1`, and confirm `ritual-checks.ps1` is green

---

## Phase 2: The check grades it

**Goal**: `Invoke-AmendmentAuthorityCheck` exists, walks commits, and produces the S1–S14
verdicts. Provable entirely on fixtures — no real history involved yet.

**Independent Test**: every S1–S14 verdict matches the table above; every pre-existing
enforcement-pack message is byte-identical to a baseline captured before the edit; the kit's own
`ritual-checks.ps1` is green.

**Territory**:

- `scripts/enforcement-pack.ps1`
- `scripts/scope-lib.ps1`

- [ ] T010 Capture the baseline: run `enforcement-pack.ps1` on this branch and on two seeded
      fixtures, and save every existing message to the scratchpad. It cannot be reconstructed
      after the edit, and it is what T018 diffs against
- [ ] T011 Build fixtures S1–S14 plus the two negative-space cases as a scripted seeder, so they
      are rebuildable rather than hand-made once
- [ ] T012 Add commit enumeration (D1): resolve the base with the existing helper in
      `scripts/scope-lib.ps1`, list `base..HEAD`, and skip any commit with more than one parent
      (D7). If a shared helper is needed, it lands in `scope-lib.ps1` — not a new script file
- [ ] T013 Add creation-vs-amendment classification (D2): for each feature document a commit
      touches, test existence in the commit's first parent. Absent → creation, exempt
- [ ] T014 Add the checkbox exemption (D3): strip `- [ ]` / `- [x]` / `- [X]` from the commit's
      removed and added lines for `tasks.md`; equal multisets → progress, exempt. A commit that
      also changes other text is **not** exempt (S10)
- [ ] T015 Add record parsing and validation (D4, D6): at least one conforming
      `**Amendment approved by**: <name>, <YYYY-MM-DD>` line added anywhere in the commit's
      diff across the feature's documents; reject empty names, slots, `TODO(...)`, malformed
      dates, and dates later than the commit's author date
- [ ] T016 Add the commit-message consistency rule (D5): the message contains the approver's
      name, matched case-insensitively after trimming
- [ ] T017 Make every failure message name the file, the class of change detected, and a
      conforming record verbatim (FR-008). A developer must never have to read the script to
      learn what the check wants
- [ ] T018 Run S1–S14 and the two negative-space cases; diff every pre-existing message against
      T010's baseline; record all sixteen verdicts in this file under "Phase 2 — scenario
      results"
- [ ] T019 Run `pwsh -File scripts/ritual-checks.ps1` here and confirm green — this branch's own
      commits must satisfy the rule the check now grades

---

## Phase 3: Replay over real history

**Goal**: the check is proven against commits nobody wrote for it, and what that finds is fixed
or recorded. This is the phase that decides whether the exemption set is right (D3a).

**Independent Test**: SC-002 — each of the five amendments in FitForge 001's finding F3 fails as
actually committed; SC-004 — every other flag over this repository's merged history is one a
reviewer judges real, with the judgement written down per flag.

**Territory**:

- `scripts/enforcement-pack.ps1`
- `specs/014-amendment-authority/tasks.md`

- [ ] T020 Replay the detector over this repository's merged feature branches (006 onward) and
      table every flag: commit, file, class of change, and a verdict — real amendment, or
      spurious
- [ ] T021 Replay over FitForge 001's commits and confirm the five F3 amendments each fail
      (SC-002). Read-only: the kit never writes into the adopted project's repository
- [ ] T022 Decide the exemption set from T020 (D3a): a spurious **class** earns an exemption
      recorded with its reason — and, since this plan is approved, an amendment to `plan.md`
      carrying its own approver line. A spurious one-off earns a recorded judgement, not an
      exemption
- [ ] T023 Tune the failure wording against the real flags — the messages T017 wrote were
      judged against fixtures the author designed, which is the weakest possible audience
- [ ] T024 Measure the check's contribution to `ritual-checks` runtime on the longest branch
      available and record it (SC-006). If it is material, batch the plumbing calls; do not
      abandon per-commit granularity (plan, Complexity Tracking)
- [ ] T025 Re-run S1–S14 after any change from T022–T024 and record the results

---

## Phase 4: The adoption surface

**Goal**: adopters learn what arrives before it arrives. After the next `update-kit.ps1`, an
adopted project's CI starts failing silent amendments — that must be an announcement, not a
surprise.

**Independent Test**: an adopter reading `adoption/updating.md` alone can predict exactly which
of their branches will newly go red and what to write to fix one; a project with no amendments
passes silently (FR-011, spec US4 scenario 2).

**Territory**:

- `adoption/updating.md`
- `adoption/greenfield.md`
- `docs/digests/`

- [ ] T026 `adoption/updating.md`: what the check grades, what a conforming record looks like,
      and the honest statement of what it does not verify (D10)
- [ ] T027 `adoption/updating.md`: the newly-failing case, stated plainly — a project with an
      in-flight feature whose documents were amended without records will go red on its next
      push, and the remediation is to record the approver, not to edit history
- [ ] T028 `adoption/greenfield.md`: one line, so a new project meets the rule at feature 001
      rather than discovering it at feature 004
- [ ] T029 Note the FitForge follow-up as a flow-down task, **not** a task of this branch: its
      constitution 1.1.0 clause carries an "Enforcement, honestly stated" paragraph that stops
      being true, and it is edited in that repository, by its owner, under its own ritual
      (SC-005)
- [ ] T030 Regenerate digests, run `pwsh -File scripts/ritual-checks.ps1`, and report the
      ci-held evidence triplet for the final phase
