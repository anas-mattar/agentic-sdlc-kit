# Tasks: Law Digests

**Input**: Design documents from `/specs/010-law-digests/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: the generator/check is business-critical governance logic (constitution VIII);
its deterministic validation is the seeded C1–C12 contract scenarios. The content phase's
validation is the read-verified L-checklist with quotes recorded. No test framework (kit
convention).

**Organization**: one delivery phase per plan-table row. **Gate Batching: phases 1-3** and
**Gate Certification: ci-held** (both declared in plan.md). Phase commits carry `phase N`
subjects; Territory per phase (006 law).

## Phase 1: The machine (US2, P1 + US3 machine half) 🎯 MVP

**Goal**: generator + `-Check`, pack manifest, ritual-checks wiring, manifest classes —
contract-validated before any marker exists.

**Independent Test**: contract C1–C12 on seeded fixtures; kit self-run shows `digests`
n/a; D7 update-kit class behavior recorded.

**Territory**:

- `scripts/build-digests.ps1`
- `scripts/ritual-checks.ps1`
- `docs/digests/digest-packs.json`
- `kit-manifest.json`
- `adoption/updating.md`

- [x] T001 [US2] Create `scripts/build-digests.ps1`: manifest load; per-doc marker
      extraction (standalone line, in-comment state exclusion — D6; empty-text FAIL);
      deterministic assembly (data-model header + bullets, LF); bounds constants
      MaxDigestContentLines=40 / MaxDigestLineLength=120 (D4, FAIL); `-Check` mode
      (normalized compare; stale/hand-edit/missing/orphan/absent-doc FAILs; n/a
      inertness — D5); `-Root` portability; error-message contract
- [x] T002 [P] [US2] Create `docs/digests/digest-packs.json` per data-model (five packs,
      D2)
- [x] T003 [P] [US2] Wire ritual-checks member `digests` (n/a distinct from OK);
      kit-manifest.json: verbatim entries for the script + manifest, `generated` class
      for `docs/digests/*-digest.md`; adoption/updating.md gains the `generated` class
      one-liner in its class table (full flow-down note is phase 3)
- [x] T004 [US2] Execute contract C1–C12 on seeded fixtures (scratch clone, deleted
      after); verify D7 (update-kit run against a fixture target — `generated` never
      copied; record actual handling); kit self-run n/a; record under Phase 1
      validation; commit as `phase 1: digest generator + freshness check`

**Checkpoint**: the machine exists and is armed; no digest content exists yet.

---

## Phase 2: The content (US1, P1 — kit dogfood, FR-008)

**Goal**: markers beside the binding rules of all ten pack documents; five digests
generated and committed under the live check.

**Independent Test**: quickstart L1–L4 with quotes recorded.

**Territory**:

- `docs/sdlc/definition-of-done.md`
- `docs/sdlc/gate-command.md`
- `docs/sdlc/flow.md`
- `docs/sdlc/branch-strategy.md`
- `docs/sdlc/repository-strategy.md`
- `docs/sdlc/team-workflow.md`
- `docs/sdlc/review-process.md`
- `docs/sdlc/rollback-process.md`
- `docs/sdlc/critical-delivery.md`
- `adoption/updating.md`
- `docs/digests/**`

- [x] T005 [P] [US1] Author digest markers beside the binding rules: delivery pack (DoD
      gates 1–6 essentials, gate-command certification law, flow checkpoints)
- [x] T006 [P] [US1] Author markers: branching pack (taxonomy, levels incl. Micro,
      claim/number rules, merge rules; team-workflow ownership/territory/pipelining;
      repository-strategy cross-repo rule)
- [x] T007 [P] [US1] Author markers: review pack (visual loop exit rule, after-each-phase
      steps, reviewer separation, human review), critical pack (the five additions +
      exclusions), adoption pack (verbatim/surgical/generated classes, re-expression
      rule, once-only surgical report)
- [x] T008 [US1] Run the generator; commit digests with the markers; execute quickstart
      L1–L4 (including the live drift tripwire); record under Phase 2 validation; commit
      as `phase 2: kit law digests — markers + generated digests`

**Checkpoint**: the kit's own digests exist and cannot drift; nothing points agents at
them yet.

---

## Phase 3: The sweep (US1 pointer half + US3 doc half)

**Goal**: reading-table orientation pointers; flow-down note; bookkeeping.

**Independent Test**: quickstart W1–W4.

**Territory**:

- `CLAUDE.md`
- `adoption/updating.md`
- `docs/roadmap.md`

- [x] T009 [P] Amend CLAUDE.md Task-Scoped Reading: per-pack digest offered as the
      orientation read (`docs/digests/<pack>-digest.md`), full documents remain the
      acting read; always-load row untouched; authority note (digest never a ladder rung
      — FR-009)
- [x] T010 [P] Amend adoption/updating.md: flow-down note for 010 (generator + manifest
      verbatim; digests generated per project, never synced; opt-in by marking own docs;
      inert until then — SC-004)
- [x] T011 Flip roadmap GAP-014 → in progress; W4 authority sweep; ritual-checks; commit
      as `phase 3: digest pointers + flow-down note` — **batch end: report the ci-held
      evidence triplet (push-event ritual-checks run on this commit) and request the
      owner's recorded approval**

---

## Dependencies & Execution Order

Phases strictly sequential (machine → content → pointers: content must land under an
armed check — D8; pointers must not precede content). AI review per phase: fresh-context
reviewer with provenance block, findings dispositioned in-phase (006 law). Human review
once at merge (constitution IX).

## Implementation Strategy

MVP = phase 1 (an armed, inert checker is independently valuable and fully testable).
All three phases batched; certification once, at batch end, on CI evidence (ci-held —
the plan's declared mode).

## Phase validation records

### Phase 1 (T004) — 2026-09-09, contract C1–C12 on seeded fixtures + D7 + kit self-run

Fixtures: scratch trees outside the repo (deleted after), fixture manifest with packs
`alpha`/`beta`, two fixture docs; each contract row's mutation applied and the verdict
quoted from the actual run.

| # | Verdict (quoted) | Exit |
|---|---|---|
| C1 | `digests: n/a (no digest markers)` | 0 |
| C2 | generate wrote both digests; re-run byte-stable (`C2 byte-stable: True`); `digests: OK (2 digest(s) fresh, 3 marker(s))` | 0 |
| C3 | `digests: FAIL — stale or hand-edited digest: docs/digests/alpha-digest.md does not match its sources — regenerate: pwsh -File scripts/build-digests.ps1` | 1 |
| C4 | same FAIL shape as C3 (hand-edited digest) | 1 |
| C5 | `digests: FAIL — missing digest: docs/digests/alpha-digest.md — its pack's documents carry markers; regenerate: …` | 1 |
| C6 | `digests: FAIL — orphan digest: docs/digests/rogue-digest.md — no manifest pack with markers produces it; delete it or add markers to its pack's documents` | 1 |
| C7 | decoy inside comment block NOT extracted (digest carries only `- Live rule after the block.`); check OK | 0 |
| C8 | `… FAIL — empty digest marker: docs/alpha.md:3 — write the one-line rule statement or remove the marker` (check AND generate; generate wrote nothing) | 1 |
| C9 | `digests: FAIL — missing document: docs/beta.md is named by docs/digests/digest-packs.json but does not exist on disk — fix the manifest or restore the file` | 1 |
| C10 | generate AND check: `FAIL — digest too long: pack 'alpha' has 41 content lines (bound: MaxDigestContentLines = 40) — tighten or drop markers until the digest is one page` | 1 |
| C11 | `digests: FAIL — digest line too long: docs/alpha.md:3 is 121 chars (bound: MaxDigestLineLength = 120) — tighten the one-liner` | 1 |
| C12 | digest rewritten with CRLF endings; `digests: OK (2 digest(s) fresh, 3 marker(s))` — normalized compare, no false drift | 0 |

**D7 (update-kit `generated`-class handling, recorded)**: scratch kit clone (phase-1 files
overlaid + a fake committed `docs/digests/delivery-digest.md`) run against a clean scratch
target clone. Actual handling: the `generated` entry is **silently skipped by
construction** — update-kit builds its work lists by filtering classes `verbatim` and
`surgical`, so a `generated` path is never copied, never reported, never conflict-checked.
Observed: report showed `Applied (2): docs/digests/digest-packs.json … scripts/build-digests.ps1`
(both verbatim, copied); `delivery-digest.md` appeared in NO section and
`target has docs/digests/delivery-digest.md: False` after the run.

**Kit self-run**: `ritual-checks` verdict block shows the new member as
`ritual-checks: digests          n/a (no digest markers)` (distinct from OK) with
`ritual-checks: RESULT OK` — no digest content exists until phase 2 (SC-004 inertness).

### Phase 1 fixes (fresh-context AI review F1–F8) — 2026-09-09

All eight findings fixed (dispositions in `ai-code-review-phase1.md`); hardening
contracted as scenarios A1–A7 in `contracts/digest-checks.md` and validated on fresh
scratch fixtures:

| # | Verdict (quoted) | Exit |
|---|---|---|
| A1 | over-bound pack with committed digest → the bound FAIL is the ONLY issue (`RESULT FAIL (1 issue(s))`, no orphan line) | 1 |
| A2 | generate: `build-digests: FAIL — docs/digests/digest-packs.json not found — restore the pack manifest (it ships verbatim with the kit)`; check w/ digests: `… not found but 2 *-digest.md file(s) exist — restore … or delete the digest files`; check w/ nothing: `digests: n/a (no digest manifest)` | 1/1/0 |
| A3 | markers inside ``` and ~~~ fences NOT harvested (digest carries only `- Live alpha rule.`); check OK | 0 |
| A4 | `FAIL — invalid pack name: '../evil' … must match ^[A-Za-z0-9][A-Za-z0-9._-]*$` + `FAIL — duplicate pack name: 'Alpha' … collides with 'alpha'`; nothing written, `A4 escaped file exists: False` | 1 |
| A5 | ritual-checks summary echoes the member's own n/a reason (kit self-run: `digests          n/a (no digest markers)`) | — |
| A6 | four `FAIL — malformed digest marker: docs/alpha.md:{3,4,5,6} — exact grammar is '<!-- digest: <text> -->' (lowercase, one line, closed, no '-->' inside the text)` for wrong case / missing colon / internal `-->` / unclosed | 1 |
| A7 | `FAIL — orphan digest: docs/digests/sub/rogue-digest.md …` (recursive scan) | 1 |

**Regression**: full C1–C12 harness re-run after the fixes — every exit code and the
C2 byte-stability + C7 decoy + C12 CRLF results unchanged. Kit self-run of ritual-checks:
`RESULT OK` with `digests n/a (no digest markers)`.

### Phase 2 (T008) — 2026-09-09, quickstart L1–L4

Markers authored beside the binding rules of all ten pack documents; the generator wrote
all five digests: `build-digests: OK (5 digest(s), 68 marker(s))`. Six first-draft
one-liners exceeded the 120-char bound and were FAILed by the generator naming each
file:line and the bound — tightened; the bound worked as designed before any digest
existed.

- **L1** (quote pairs, two per pack, marker ↔ adjacent rule):
  - *delivery*: "AI MUST NOT claim success without that confirmation" ↔ `Gate 3: the user runs the gate and confirms the exit code — the AI never claims success on its own runs.`; "Cite the **push-event** run: a pull_request-event run executes a merge preview" ↔ `Cite the push-event CI run — a pull_request run executes a merge preview, not the phase commit, and certifies nothing.`
  - *branching*: "the number belongs to whichever branch reaches the remote first" ↔ `Claim with scripts/claim-feature.ps1: remote-aware number allocation and an immediate push — the remote is the ledger.`; "the human reviewer of a feature MUST NOT be its owner" ↔ `Cross-review: the human reviewer of a feature must not be its owner.`
  - *review*: "Exit rule: empty table, or user-approved rows only." ↔ `Visual loop exit: deviation table empty, or every remaining row user-approved; attach table + both screenshots.`; "Never `DELETE` or `DROP` protected records to undo a change." ↔ `Never DELETE or DROP protected domain records to undo a change — correct through additive, auditable mechanisms.`
  - *critical*: "filled for this feature **before phase 1 begins**, not at review time" ↔ `Critical 1: the rollback plan is filled before phase 1 begins, not at review time.`; "Every phase's gate run that counts toward Done is executed by a human, locally." ↔ `Critical 4: human-executed gates only, one per phase — never agent-run gates, batching, ci-held, or the Micro lane.`
  - *adoption*: "An amendment never gets copied in. It gets **re-expressed**" ↔ `Constitution amendments are re-expressed, never copied: your own version bump, your own SYNC IMPACT, citation sweep.`; "The surgical report is delivered **once**" ↔ `The surgical report is delivered once — handle it in the session that produced it; the record advances to kit HEAD.`
- **L2**: five digests generated and committed; every pack under the 40-content-line
  bound (largest: delivery); header carries the generated notice, the regeneration
  command, the non-authoritative statement, and the full-read rule; every bullet carries
  its backticked source path (adoption digest quoted in full during validation).
- **L3**: `digests: OK (5 digest(s) fresh, 68 marker(s))`; regenerate re-run byte-stable
  (`byte-stable: True` on SHA-256); full ritual-checks `RESULT OK` with
  `ritual-checks: digests          OK` (no longer n/a).
- **L4** (live drift tripwire on the kit itself): one marker in
  `docs/sdlc/rollback-process.md` mutated → `digests: FAIL — stale or hand-edited digest:
  docs/digests/review-digest.md does not match its sources — regenerate: pwsh -File
  scripts/build-digests.ps1` (exit 1); reverted → `digests: OK (5 digest(s) fresh,
  68 marker(s))` (exit 0).

### Phase 2 fixes (fresh-context AI review F1–F6) — 2026-09-09

F1 (blocking): a marker placed mid-table in `adoption/updating.md` severed the "Adoption
doctor" row from the report table — marker moved below the table (document marker order
unchanged, adoption digest byte-identical). F2/F3: two team-workflow one-liners tightened
to mirror their rules' actual scope (final-phase rebase wording; pipelining's
"disjoint or sequenced"). F4: four double-blank-line sites collapsed. F5/F6:
acknowledged, no change (dispositions in `ai-code-review-phase2.md`). Post-fix:
regenerate + `digests: OK (5 digest(s) fresh, 68 marker(s))`, ritual-checks `RESULT OK`.
The unrendered-markdown defect class (F1's) is added to phase 3's W4 sweep.

### Phase 3 (T011) — 2026-09-09, quickstart W1–W4

- **W1**: CLAUDE.md Task-Scoped Reading gained an "Orientation first (optional)"
  paragraph naming all five digests as the orientation read; it states the digest "is
  never a source-of-truth rung and never satisfies a 'read first' obligation — before
  acting on an area, read the full document"; the always-load row is untouched and
  explicitly declared unchanged.
- **W2**: updating.md gained the 010 flow-down note ("no constitution amendment" —
  nothing to re-express): generator + digest-packs.json + ritual-checks arrive verbatim;
  the kit's digests never flow (`generated` class, report-table row); opt-in by marking
  the project's OWN documents, with the marker syntax shown safely inside a code fence
  (fence exclusion — phase 1 F3 fix); inert until then (`n/a (no digest markers)`,
  SC-004).
- **W3**: roadmap GAP-014 → `in progress`; ritual-checks `RESULT OK` (doc-lint,
  enforcement-pack, scope-check, digests all OK).
- **W4** (authority sweep + the phase-2 F1 render class): grep of every shipped
  instrument for "digest" — every mention presents digests as generated,
  orientation-only, non-authoritative (CLAUDE.md pointer, digest headers, updating.md
  note); no instrument presents a digest as a ladder rung or as satisfying a read-first
  obligation; constitution II untouched. Render spot-check of the two amended
  instruments: the CLAUDE.md paragraph sits between the section intro and the table
  (table intact); the updating.md note is its own `###` subsection (report table intact
  after the phase-2 F1 fix, verified in the current file).

### Phase 3 fixes (fresh-context AI review F1–F7) — 2026-09-09

F1 (blocking): the reviewer proved on a seeded target that a post-010 flow-down delivers
the kit's marker-bearing **verbatim** pack docs, so ritual-checks demands digests before
any "opt-in" — the note's inertness claim was false on the very path it governs. Fixed:
the note now makes **generate + commit the digests part of the flow-down step** (loud,
exact-command FAIL if skipped), scopes `n/a` to marker-free trees, and the spec's
US3-AS2 + SC-004 are amended in place, **marked for owner ratification at batch-end
approval**. F2 repository-strategy.md added to the surgical list; F4 new "Mirror by
hand" bullet (CLAUDE.md orientation paragraph is a surgical mirror); F5 CLAUDE.md points
at digest-packs.json instead of restating composition; F6 "always current" softened to
green-branch wording; F3/F7 rejected/accepted with rationale (dispositions in
`ai-code-review-phase3.md`). Post-fix: digests byte-unchanged (`digests: OK`),
ritual-checks `RESULT OK`.

### Batch-end certification (gate 3, ci-held — phases 1–3)

Mode declared in `plan.md` before phase 1: **Gate Batching: phases 1-3** and
**Gate Certification: ci-held** (constitution X; `docs/sdlc/gate-command.md`, CI-held
certification). The kit repository's project gate IS the ritual checks, so the
`ritual-checks` push-event run is the evidence. Evidence triplet, as reported to the
owner and approved by them:

> Gate 3 certified (ci-held): run
> https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/34306506727, conclusion
> success, commit `2d1c691` (batch end, phases 1–3) — approved, anas.m, 2026-09-09.

The same approval **ratifies the phase 3 review F1 amendment** to `spec.md` (US3-AS2 and
SC-004): a post-010 flow-down delivers the kit's marker-bearing verbatim pack documents,
so generating and committing the receiving project's own digests is part of the flow-down
step; the `n/a (no digest markers)` inert state is scoped to marker-free trees. The
machine was not changed by that finding — it already failed loudly, naming the exact
files and the fix command.

Gates 1–5 now stand for every phase in the batch (specification approved before phase 1;
one approved phase per commit; this certification; `scope-check` PASS on each of
`dc6bbd6`, `374163c`, `040dbd2`, `0b0627c`, `0f4da69`, `2d1c691`; a fresh-context AI
review per phase with every finding dispositioned). Gate 6 (human review of the full
feature diff) remains, at merge.
