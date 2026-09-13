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

<!-- Widened by amendment 2026-09-13 for the phase 1 remediation — the last three entries.
  The marker line below must stay exactly `**Territory**:` with its entries immediately after:
  scripts/scope-lib.ps1 matches the marker literally and stops collecting at the first line
  that is not a backtick-wrapped entry, so an annotation on the marker line or a comment
  between marker and entries silently empties the declaration. -->

**Territory**:

- `.specify/memory/constitution.md`
- `CLAUDE.md`
- `docs/sdlc/review-process.md`
- `docs/sdlc/definition-of-done.md`
- `docs/digests/`
- `.specify/templates/tasks-template.md`
- `specs/_templates/ai-code-review-template.md`
- `specs/_templates/human-pr-review-template.md`
- `docs/sdlc/repository-strategy.md`

**Amendment approved by**: anas.m, 2026-09-13.

- [x] T001 Add **Amendment authority** to constitution Principle I, adopting FitForge 1.1.0's
      wording (D9): scope (`spec.md`, `plan.md`, `tasks.md`, `contracts/`), the record shape
      `**Amendment approved by**: <name>, <YYYY-MM-DD>`, the same approver named in the commit,
      and "an implementing agent MUST NOT approve its own amendment". Keep the sentence
      "Amending before implementing satisfies the sequence; it does not satisfy this rule" —
      it is the finding F3 lesson in one line
- [x] T002 Add the checkbox exemption to the clause (D3): completion state is progress, not
      amendment. It belongs in the law, not only in the script — a rule whose survivability
      lives in an implementation detail is one nobody can reason about
- [x] T003 Add the honesty paragraph (D10): the record is a written claim a reviewer can
      falsify, not an authentication; in a solo project the approver is the same human who ran
      the session. State it the way `docs/sdlc/critical-delivery.md` states it of the team arm
- [x] T004 Record where the kit's wording differs from FitForge 1.1.0 and why, in this file
      under a "Phase 1 — wording reconciliation" section, so the flow-down reconciles rather
      than collides (D9)
- [x] T005 Update the SYNC IMPACT REPORT header and bump the version to **0.7.0** (MINOR — a
      new rule inside an existing principle). Confirm `scripts/enforcement-pack.ps1` is already
      in the sync list (it is, since the GAP-002 fix) and that no other sync-listed file's
      reading changed
- [x] T006 `CLAUDE.md` Strict Rules: one line — an amendment to an approved feature document
      records its approver. Point at the constitution; do not restate the clause
- [x] T007 `docs/sdlc/review-process.md`: the human reviewer's checks gain "every amendment in
      the feature diff carries its record" (FR-012)
- [x] T008 `docs/sdlc/definition-of-done.md`: gates 5 and 6 read the amendment record as part
      of the full feature diff (FR-012)
- [x] T009 Add digest markers for the new rule where the pack conventions call for one, run
      `pwsh -File scripts/build-digests.ps1`, and confirm `ritual-checks.ps1` is green

### Phase 1 remediation, round 2 (added by amendment 2026-09-13 — second review, G1–G3)

Source: `specs/014-amendment-authority/ai-code-review-phase-1-remediation.md`. The second
fresh-context review confirmed F1, F2, F3, F4, F7, F8 fixed and F6, F9 fixed-as-scoped, and
raised three blocking findings of its own.

**Amendment approved by**: anas.m, 2026-09-13.

- [x] T043 **G1** — a duplicated sentence shipped in the constitution's rewritten rationale,
      in the paragraph the remediation existed to repair. Removed. The edit had anchored on
      the old paragraph's final sentence and left the sentence after it
- [x] T044 **G2** — bound the check's range (D2b, owner decision): a commit is graded only if
      the check existed before it was made. Updates T019 and T027, which were written against
      an unbounded rule that no adopter could have complied with
- [x] T045 **G3** — remove the counter-instructions left by the evidence move: T018's "record
      the verdicts in this file", D3a's and D9's "recorded in `tasks.md`"
- [x] T046 **G6, G10, G11, G12** — sweep the multi-repo twin in
      `docs/sdlc/repository-strategy.md`; drop the intent test ("an annotation that changes
      what the task means") the check cannot grade, in favour of the text test it can; correct
      the SYNC IMPACT header, which still described the pre-remediation clause; and replace
      the new absolute ("no check can tell which session produced a diff") with what is
      actually true — the kit records no link between a commit and the session behind it

### Phase 1 remediation (added by amendment 2026-09-13 — six blocking findings)

Source: `specs/014-amendment-authority/ai-code-review-phase-1.md`. Lands as a second
`phase 1` commit; the Territory above was widened first, in its own commit.

**Amendment approved by**: anas.m, 2026-09-13.

- [x] T031 **F1** — the clause asserts in the present tense that `scripts/enforcement-pack.ps1`
      grades the record, but no such check exists until phase 2. Remove the claim from the
      normative sentence: state what *can* and *cannot* be verified about a record, and leave
      where the machine half lands to the SYNC IMPACT REPORT, which already says it. Same fix
      in the `docs/sdlc/review-process.md` mirror. A constitution that describes a check it
      does not yet have is the state this whole feature exists to end
- [x] T032 **F2** — un-ticking a checkbox is currently both exempt (completion state) and an
      amendment (a task "re-opened"). State that completion state moving in **either**
      direction is progress, and that "re-opened" means the task's **text** changed — which is
      also what D3's multiset comparison actually implements
- [x] T033 **F3** — FR-003 is undelivered. The honesty paragraph must say that **nothing**
      verifies the self-approval prohibition (no machine can identify the implementing agent),
      and that "approved" is proxied by a document's first appearance (D2), not observed
- [x] T034 **F4** — restore the provenance the rationale dropped: the date, the "feature 001
      governance review, finding F3" attribution, and the named checks. Then correct the
      reconciliation row, which claims the rationale was kept near-verbatim *to preserve
      provenance* while the committed text had rewritten it away
- [x] T035 **F5** — create `specs/014-amendment-authority/notes.md` and move the "wording
      reconciliation" and "gate" sections into it (D3b). `tasks.md` keeps agreed work and
      checkboxes alone
- [x] T036 **F6** — sweep the three documents that still say a Territory amendment needs only
      "owner approval": `.specify/templates/tasks-template.md` (**on the constitution's sync
      list** — T005's claim that no other sync-listed file changed reading was wrong),
      `docs/sdlc/definition-of-done.md`, `docs/sdlc/review-process.md`. Add the amendment item
      to both review templates in `specs/_templates/`
- [x] T037 **F7** — `CLAUDE.md` restates the clause in five lines against T006's own "point, do
      not restate". Cut it to a pointer; restating law in the always-loaded file is the drift
      GAP-021 is a row about
- [x] T038 **F8** — "a silent amendment becomes impossible" overstates. It becomes visible in
      the diff and gradeable by a machine; a determined implementer can still write a name
- [x] T039 **F9** — the gate-record commit `f49ad61` carries a `phase 1` token in its subject,
      so `scope-check` now grades it instead of `ced1302`. Record the rule that non-phase
      commits must not carry a phase token; the remediation commit re-establishes the real one
- [x] T040 Rebuild digests, run `pwsh -File scripts/ritual-checks.ps1`, and request a second
      fresh-context review of the remediation — the first reviewer graded a diff this one
      replaces

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

- [x] T010 Capture the baseline: run `enforcement-pack.ps1` on this branch and on two seeded
      fixtures, and save every existing message to the scratchpad. It cannot be reconstructed
      after the edit, and it is what T018 diffs against
- [x] T011 Build fixtures S1–S14 plus the two negative-space cases as a scripted seeder, so they
      are rebuildable rather than hand-made once
- [x] T012 Add commit enumeration (D1): resolve the base with the existing helper in
      `scripts/scope-lib.ps1`, list `base..HEAD`, and skip any commit with more than one parent
      (D7). If a shared helper is needed, it lands in `scope-lib.ps1` — not a new script file
- [x] T013 Add creation-vs-amendment classification (D2): for each feature document a commit
      touches, test existence in the commit's first parent. Absent → creation, exempt
- [x] T014 Add the checkbox exemption (D3): strip `- [ ]` / `- [x]` / `- [X]` from the commit's
      removed and added lines for `tasks.md`; equal multisets → progress, exempt. A commit that
      also changes other text is **not** exempt (S10)
- [x] T015 Add record parsing and validation (D4, D6): at least one conforming
      `**Amendment approved by**: <name>, <YYYY-MM-DD>` line added anywhere in the commit's
      diff across the feature's documents; reject empty names, slots, `TODO(...)`, malformed
      dates, and dates later than the commit's author date
- [x] T016 Add the commit-message consistency rule (D5): the message contains the approver's
      name, matched case-insensitively after trimming
- [x] T017 Make every failure message name the file, the class of change detected, and a
      conforming record verbatim (FR-008). A developer must never have to read the script to
      learn what the check wants
- [x] T018 Run S1–S14 and the two negative-space cases; diff every pre-existing message against
      T010's baseline; record all sixteen verdicts in `notes.md` under "Phase 2 — scenario
      results" (D3b — evidence never lands in this file)
- [x] T019 Run `pwsh -File scripts/ritual-checks.ps1` here and confirm green — every commit
      the check grades must satisfy it. Under D2b that is the commits made after the check
      lands; `ced1302` and `f49ad61` predate it and are out of scope by rule, not by exception

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

**Independent Test**: an adopter reading `adoption/updating.md` alone can predict exactly what
the boundary means for their in-flight branches (D2b — nothing before the update is graded),
and a future feature reading the kit's own docs can tell where evidence belongs without
reading this feature (FR-011, spec US4 scenario 2).

**Territory** (widened by amendment 2026-09-13 — the last two entries, for G5):

- `adoption/updating.md`
- `adoption/greenfield.md`
- `docs/digests/`
- `docs/sdlc/branch-strategy.md`
- `.specify/templates/tasks-template.md`

**Amendment approved by**: anas.m, 2026-09-13.

- [ ] T026 `adoption/updating.md`: what the check grades, what a conforming record looks like,
      and the honest statement of what it does not verify (D10)
- [ ] T027 `adoption/updating.md`: state the boundary (D2b) — nothing committed before the
      update that delivers the check is graded, so arrival day is silent and no in-flight
      branch turns red. Say why the boundary exists rather than only that it does: half of
      every record lives in an immutable commit message, so a retroactive rule would be one
      no adopter could comply with
- [ ] T028 `adoption/greenfield.md`: one line, so a new project meets the rule at feature 001
      rather than discovering it at feature 004
- [ ] T029 Note the FitForge follow-up as a flow-down task, **not** a task of this branch: its
      constitution 1.1.0 clause carries an "Enforcement, honestly stated" paragraph that stops
      being true, and it is edited in that repository, by its owner, under its own ritual
      (SC-005)
- [ ] T030 Regenerate digests, run `pwsh -File scripts/ritual-checks.ps1`, and report the
      ci-held evidence triplet for the final phase

#### Added by amendment 2026-09-13 (G5 — the convention needs a home outside this feature)

- [ ] T041 `docs/sdlc/branch-strategy.md` (Spec Directory Contents): say what `notes.md` is
      for — phase results, gate records and findings — and that `tasks.md` holds agreed work
      and completion state alone. Today `notes.md` is listed as an optional file with no
      stated purpose, so D3b is a convention this feature follows and the kit never states
- [ ] T042 `.specify/templates/tasks-template.md:14` still tells an author to "record that
      determination in this file". Point it at `notes.md` instead, or the next feature
      reproduces F5 exactly

**Amendment approved by**: anas.m, 2026-09-13.

---

**Evidence lives in `notes.md`** (D3b, owner decision 2026-09-13 on review finding F5): phase
results, scenario tables, gate records and findings are recorded in
`specs/014-amendment-authority/notes.md`. This file holds agreed work and its completion state
alone, so that every change to it is either a checkbox flip or an amendment — which is what
makes the clause true as written.

**Amendment approved by**: anas.m, 2026-09-13.
