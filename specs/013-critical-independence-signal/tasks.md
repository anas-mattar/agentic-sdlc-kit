# Tasks: Critical Independence Signal

**Input**: Design documents from `/specs/013-critical-independence-signal/`
**Prerequisites**: plan.md (decisions D1–D6), spec.md

**Tests**: business-critical governance logic (constitution VIII) — a wrong PASS removes the
independence requirement from the kit's strictest lane. Deterministic validation is the seeded
S1–S12 fixture scenarios below, plus byte-for-byte preservation of every solo-mode message. No
test framework (kit convention).

**Organization**: one delivery phase per plan-table row. **Gate Batching: none** and **Gate
Certification: ci-held** (both declared in plan.md). Phase commits carry `phase N` subjects;
Territory per phase (006 law).

## Current state (authoritative)

**Read this section, not the tables below it.** Everything after this point is chronological
history: five phases, three review rounds, and the corrections each produced. Earlier tables
were true when written and several have since been superseded — they are kept because how a
number changed is part of the evidence, not despite it.

### What the check does now

Measured 2026-09-10 against the head of this branch, by running the check — not inferred from
the doctor and not reasoned from the code.

| Record shape | Evidence mode | Doctor |
|---|---|---|
| field absent | solo | silent (the supported default) |
| `["ada"]` | solo | ok, 1 declared |
| `["ada","grace"]` | team | ok, 2 declared |
| `["ada","grace"," "]` | team | FAIL blank entry, ok 2 declared |
| `["ada",5,"grace"]` | team | FAIL non-string entry, ok 2 declared |
| `["Ada","ada"]` | solo | FAIL duplicate, ok 1 declared |
| `[]` | solo | FAIL empty, ok 0 declared |
| `null` | solo | FAIL null, ok 0 declared |
| `"ada"` (a string) | solo | FAIL not an array, ok 0 declared |
| `[{"developers":[…]}]` (root array) | solo | FAIL not a JSON object at its root |
| unreadable / unparsable / no record | solo | silent or other-dimension FAILs |

In team mode the check requires a **committed** `specs/NNN-name/human-pr-review.md` whose
visible `## Review Provenance` section names a Reviewer who is not the Owner, plus the verbatim
attestation. Comments, code fences and indented code blocks are not visible content; a nested
list item is. In solo mode it requires `second-model-review.md` committed at least 24 hours
before merge — byte-for-byte the behaviour that shipped before this feature.

### Requirements and success criteria

| | Status |
|---|---|
| FR-001…FR-002 (the field, and the mode derived from it) | met |
| FR-003 (every degenerate record is solo) | met — measured across the eleven shapes above |
| FR-004 (solo unchanged) | met — byte-identical to the pre-013 baseline, diffed three times |
| FR-005…FR-006 (team arm, committed artifacts) | met |
| FR-007 (honesty about the team check's strength) | met — stated in the script header, item 5, and both adoption docs |
| FR-008 (no mode leaves item 5 unenforced) | met |
| FR-009…FR-012 (doctor, law, adoption guidance, fixtures) | met |
| SC-001 (FitForge 002 passes on its real cross-review) | **outstanding** — needs this feature merged and flowed down; cannot be met from this repository |
| SC-002…SC-005, SC-007 | met |
| SC-006 (adopted projects untouched) | met — all three verified directly |

### Known and deliberately open

- **C2** — `docs/sdlc/review-process.md` still points at the template path rather than
  `specs/NNN-name/human-pr-review.md`. One pre-existing sentence, outside every phase's
  Territory; the docs reviewer ruled it a follow-up rather than a drive-by. Next Lite `fix/`.
- **The roster is counted, never compared.** A review naming two people absent from the
  declared roster passes. Disclosed in the script header and in `spec.md`'s Edge Cases, which
  records the decision rather than an unmet MUST.

## Fixture scenarios (S1–S12)

*Superseded in part — see **Current state (authoritative)** above. These were the expectations
written before phases 4 and 5; the verdicts still hold, but two messages have since changed and
the record shapes below are not the full set.*

Each is a throwaway git repository under the scratchpad with a `specs/007-x/spec.md` declaring
`**Delivery Level**: Critical`, plus whatever the row names. Expected verdict is what
`enforcement-pack.ps1` must say about the CriticalEvidence check alone.

| # | `developers` in the record | Review artifacts present | Expected |
|---|---|---|---|
| S1 | absent (no field) | none | FAIL — asks for `second-model-review.md` (today's message) |
| S2 | absent (no field) | `second-model-review.md`, committed 30h ago | PASS |
| S3 | absent (no field) | `second-model-review.md`, committed 2h ago | FAIL — cooling-off, with hours remaining |
| S4 | no `kit-adoption.json` at all | none | FAIL — solo rule, today's message |
| S5 | `["anas.m"]` | none | FAIL — solo rule |
| S6 | `["anas.m"]` | `second-model-review.md`, 30h ago | PASS |
| S7 | `["anas.m","ahmad"]` | none | FAIL — asks for `human-pr-review.md` with a filled provenance block |
| S8 | `["anas.m","ahmad"]` | `human-pr-review.md`, provenance complete, Reviewer ≠ Owner | PASS |
| S9 | `["anas.m","ahmad"]` | `human-pr-review.md`, provenance complete, **Reviewer = Owner** | FAIL — names the owner as reviewer |
| S10 | `["anas.m","ahmad"]` | `human-pr-review.md` with no `## Review Provenance` section | FAIL — section missing |
| S11 | `["anas.m","ahmad"]` | provenance present, `**Owner**` left as `[name]` | FAIL — placeholder unfilled |
| S12 | malformed (`"developers": "anas.m"`, or `[]`, or `[""]`) | none | FAIL — solo rule applies **and** `verify-kit.ps1` reports the malformation |

S12's two halves are checked in different phases: the solo fallback in phase 1, the doctor's
report in phase 2. Until phase 2 lands, a malformed field is strict but silent — which is the
right order, because strict-but-silent is safe and lenient-but-loud is not.

## Phase 1: The mode and the two rules (US1 + US2 + US3, P1) 🎯 MVP

**Goal**: `Invoke-CriticalEvidenceCheck` derives its mode from the record and enforces the rule
that mode actually calls for. Provable entirely on fixtures — no adopter, no record edit, and no
behaviour change for any project that has not declared the field.

**Independent Test**: S1–S11 plus S12's first half produce the verdicts tabled above; every
solo-mode message is byte-identical to the captured baseline; the kit's own `ritual-checks.ps1`
stays green.

**Territory**:

- `scripts/enforcement-pack.ps1`
- `specs/_templates/human-pr-review-template.md`

- [x] T001 Capture the baseline: run `enforcement-pack.ps1` against fixtures S1, S3 and S4 on
      the **unmodified** script and save the exact CriticalEvidence lines to the scratchpad.
      This is the artifact T007 diffs against, and it cannot be reconstructed after the edit
- [x] T002 Add a mode reader to `scripts/enforcement-pack.ps1`: read `developers` from
      `kit-adoption.json` at `$Root`, tolerate a missing file, missing field, non-array, empty
      array and non-string or blank entries, and return `solo` for every one of them (D1, D2).
      No caller yet — the reader lands and is exercised before the rule changes
- [x] T003 Split `Invoke-CriticalEvidenceCheck` into the mode selection plus a solo branch
      holding today's logic **moved, not rewritten** — same order, same conditions, same
      message strings. A rewrite here is how byte-for-byte preservation is lost
- [x] T004 Add the team branch: require `specs/<branch>/human-pr-review.md`; require a
      `## Review Provenance` section; parse `**Reviewer**` and `**Owner**` from **inside that
      section only** (the document header also carries a `**Reviewer**:` field and must never
      shadow the block — the same trap phase 2 of feature 006 recorded as F1); fail on an
      absent, blank or `[bracketed]` value; fail when the two match case- and
      whitespace-insensitively; require the verbatim attestation (D3)
- [x] T005 Make every failure message name the mode and why it applies, e.g. "team mode (2
      developers declared in kit-adoption.json)" — a conditional check that does not say which
      branch it took is unfalsifiable by the person reading its output
- [x] T006 Update the script's header comment block: state both modes, where the mode comes
      from, and that the team comparison is name-against-name of the same strength as the
      Reviewer Provenance block (FR-007, D4). Do not restate the law — point at
      `docs/sdlc/critical-delivery.md`
- [x] T007 Add the `## Review Provenance` block to
      `specs/_templates/human-pr-review-template.md`: `**Reviewer**`, `**Owner**`, the verbatim
      attestation, and a comment saying the block is required only in team mode and why
- [x] T008 Build fixtures S1–S12 and run them; diff the solo messages against T001's baseline;
      record every verdict in this file under a "Phase 1 — scenario results" section
- [x] T009 Run `pwsh -File scripts/ritual-checks.ps1` in this repository and confirm it is
      green (the kit declares no `developers`, so it is solo and nothing changes for it)

## Phase 2: The record and the doctor (US3, P1)

**Goal**: the field becomes a documented, validated part of the adoption record, so a
malformed declaration is reported instead of silently selecting strict mode.

**Independent Test**: S12's second half — `verify-kit.ps1` reports each malformed shape; a valid
declaration passes; an absent one is not even a warning, because absence is the supported
default for every project that adopted before this feature.

**Territory**:

- `scripts/verify-kit.ps1`
- `scripts/init-kit.ps1`
- `adoption/updating.md`
- `adoption/greenfield.md`

- [x] T010 `scripts/verify-kit.ps1` dimension 4: validate `developers` when present — array of
      non-blank strings, no duplicates after case-folding. FAIL on a wrong type or a bad entry,
      naming the shape; stay silent when the field is absent (FR-009)
- [x] T011 `scripts/init-kit.ps1`: accept an optional developer list and write it into the
      record it generates. Absent parameter writes no field — the initializer must not invent a
      roster, and a one-person default would be a claim the project did not make
- [x] T012 `adoption/updating.md`: a short section on declaring the field — the shape, that
      declaring one developer changes nothing, that declaring two or more switches Critical
      features to requiring an independent human review instead of the second-model substitute,
      and that declaring nothing keeps today's behaviour forever
- [x] T013 `adoption/greenfield.md`: the same, at the step that writes `kit-adoption.json`
- [x] T014 Re-run S12 end to end (strict **and** reported); re-run S1–S11 to confirm phase 2
      changed no verdict; append the results to this file

## Phase 3: The law says what the machine does (FR-010)

**Goal**: `docs/sdlc/critical-delivery.md` item 5 states the two modes and where the mode comes
from, so the law and the check can be read against each other — the failure this whole feature
exists to fix was exactly that they could not be.

**Independent Test**: `doc-lint` and the `digests` member stay green; item 5's requirement
sentence is unchanged (`git diff` shows additions around it, not edits to it).

**Territory**:

- `docs/sdlc/critical-delivery.md`
- `docs/digests/*.md`

- [x] T015 Rewrite item 5's *machinery*, not its requirement: keep the independence sentence and
      the solo-substitute sentence exactly as they are, and add which artifact each mode
      requires, that the mode comes from `kit-adoption.json`, and that an undeclared project is
      treated as solo. The honesty paragraph gains one clause: the team-mode comparison is two
      names in one file, written by the same team
- [x] T016 Check whether any `<!-- digest: -->` marker in the edited region moved or needs
      rewording; if so update the marker and run `pwsh -File scripts/build-digests.ps1`
- [x] T017 Search for every other place the substitute is described — `docs/sdlc/flow.md`,
      `docs/sdlc/definition-of-done.md`, `docs/sdlc/review-process.md`, `CLAUDE.md`, the
      constitution's sync list — and correct any that implies the substitute is unconditional.
      Kit 011's lesson is that this enumeration goes stale in exactly these files
- [x] T018 Full `pwsh -File scripts/ritual-checks.ps1`; re-run S1–S12 one last time; record the
      final verdict table in this file

## Phase 1 — scenario results (T008)

Run 2026-09-10 against `scripts/enforcement-pack.ps1` at this commit, fixtures rebuilt from
scratch. Verdict column is the CriticalEvidence finding only; "pass" means the check produced
none. Every row matches the expected column of the S1–S12 table above.

| # | Mode taken | Result |
|---|---|---|
| S1 | solo (no developers declared) | FAIL — second-model-review.md is missing |
| S2 | solo | pass |
| S3 | solo | FAIL — recorded 2h ago, 22h remaining |
| S4 | solo (no kit-adoption.json) | FAIL — second-model-review.md is missing |
| S5 | solo (1 declared) | FAIL — second-model-review.md is missing |
| S6 | solo (1 declared) | pass |
| S7 | team (2 declared) | FAIL — human-pr-review.md is missing |
| S8 | team | pass |
| S9 | team | FAIL — names 'anas.m' as both reviewer and owner |
| S10 | team | FAIL — no Review Provenance section |
| S11 | team | FAIL — Owner left as a template placeholder |
| S12 | solo (developers is a string, not an array) | FAIL — second-model-review.md is missing |

**S8 is the whole feature in one row.** Before this phase it failed asking for the solo
substitute — a two-developer project with a complete, genuine independent review, told to
produce evidence of a substitution that never happened. That was FitForge 002's exact position.

**Byte-for-byte preservation (T001 baseline vs. now)**: S1, S3, S4 and S5 were captured against
the unmodified script before any edit and re-run after; `diff -u` reports no difference. A solo
project cannot tell this feature happened, which is the point — the messages were moved, not
rewritten.

**Not yet true, and deliberately so**: S12's malformed record selects the strict branch but says
nothing about being malformed. `verify-kit.ps1` reports it in phase 2. Strict-and-silent is safe
in the interim; lenient-and-loud would not have been, which is why the order is this way round.

## Phase 1 — gate (ci-held)

| Run | Conclusion | Commit | Owner approval |
|---|---|---|---|
| [34458129073](https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/34458129073) | success | `c28e1f99a10c4e2bb436b5483d644e7dd60fcc6c` | recorded 2026-09-10 |

Pushed alone so the commit has a run of its own — FitForge 001's recorded lesson applied.

## Phase 2 — doctor results (T014)

*Superseded — see **Current state (authoritative)** above. One row in this table was wrong when
written (see B2 below) and the modes changed again in phases 4 and 5.*

`verify-kit.ps1` run against one minimal adopted-project fixture per record shape. The column
that matters is the last one: what `enforcement-pack.ps1` does with the same record.

| Record shape | Doctor says | Evidence mode |
|---|---|---|
| field absent | nothing at all | solo |
| `["ada"]` | ok — 1 developer declared | solo |
| `["ada","grace"]` | ok — 2 developers declared | team |
| `"ada"` (a string) | FAIL — not an array | solo |
| `[]` | FAIL — empty | solo |
| `["ada","  "]` | FAIL — blank entry, **and** ok — 1 developer declared | solo |
| `["Ada","ada"]` | FAIL — listed more than once | solo **(was TEAM before phase 4 — see B2 below)** |

**Absence is deliberately not a finding.** Three projects adopted this kit before the field
existed; warning them about a value whose absence produces the stricter behaviour would be
nagging about something working as intended.

**The blank-entry row is the one worth reading twice.** A record naming two developers, one of
them whitespace, is a *team declaration that silently becomes solo* — the count is taken after
blanks are dropped. The doctor prints both lines: the failure, and the mode the project actually
gets. Either alone would mislead.

The duplicate case matters for the opposite reason. `["Ada","ada"]` is one person written twice,
and it inflates the count into team mode — the only direction this feature must never move a
project by accident, because it is the direction that drops a requirement.

**S1–S12 re-run after phase 2: no verdict changed**, and two consecutive full runs are identical,
so the fixtures are deterministic rather than incidentally passing.

**T011's temptation, recorded because the next person will feel it**: `init-kit.ps1` could
default `developers` to the current user so the record looks complete. It must not. A one-person
default is a claim the project never made, and when a second developer joins, the stale
declaration keeps Critical features on the solo substitute while everyone believes the record is
accurate. An absent field is honest about not knowing; a guessed one is not.

## Phase 2 — gate (ci-held)

| Run | Conclusion | Commit | Owner approval |
|---|---|---|---|
| [34459430831](https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/34459430831) | success | `1b30e99a6a9fcfcab77539ed28fc744d7ec6938f` | recorded 2026-09-10 |

## Phase 3 — the sweep, and what it did not find (T017)

The enumeration T017 was written to distrust turned out to be clean, and that is worth
recording as a result rather than skipping in silence. Every mention of the substitute across
`docs/`, `CLAUDE.md`, the constitution and the templates:

- `docs/sdlc/critical-delivery.md` item 5 — **the only law statement**, and in this phase's
  Territory. Amended.
- `specs/_templates/human-pr-review-template.md` — already carries the conditional wording
  from phase 1.
- `.specify/memory/constitution.md` lines 64 and 137 — the sync list, naming "the Critical
  cooling-off hours" as a constant. Still true: the constant is 24 and this feature does not
  move it. **Not edited.**
- `.specify/memory/constitution.md` line 96 — the SYNC IMPACT REPORT of an earlier amendment,
  which already calls it "the Critical-**solo** review substitute". That is a historical
  record of what that amendment did, it is accurate, and rewriting history to match today
  would be the opposite of an audit trail. **Not edited** — and it is the strongest single
  piece of evidence that the unconditional check was a defect rather than a decision.
- `docs/roadmap.md` — GAP rows and shipped-feature descriptions; historical, nothing implies
  the substitute is unconditional. **Not edited.**

So Territory did not need widening, and no amendment was required. Kit 011's lesson was that
this enumeration goes stale in exactly these files; this time it had not.

**A GAP-015 near-miss, caught before commit.** The first draft of item 5's machine-check
paragraph used a markdown table nested inside numbered list item 5. GFM renders tables
inconsistently inside list continuations, and a table that fails to render degrades into a row
of raw pipes — the precise failure GAP-015 records, in a law document, introduced by the
session that recorded the gap twice today. Converted to a bulleted list, which renders
everywhere. No machine check would have caught it: `doc-lint` and the `digests` member were
green across both versions.

**Digest markers**: item 5 gains a second marker naming where the mode comes from. The first
draft was 194 characters and `build-digests.ps1` rejected it against its 120-character bound —
the generator refusing an unreadable one-liner is the bound doing its job. Rewritten to 115.
`build-digests.ps1` re-run; the `digests` member is green, so the digests match the law.

## Phase 3 — gate (ci-held)

| Run | Conclusion | Commit | Owner approval |
|---|---|---|---|
| [34459972572](https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/34459972572) | success | `20bda1883fb42f8cde9599ec9550324b3738d462` | recorded 2026-09-10 |

All three phases pushed separately, each with a CI run against its own commit — no phase
certified against a sha that CI never graded (FitForge 001's recorded lesson).

## Phase 4: Review remediation (added by amendment — approved by anas.m, 2026-09-10)

**Goal**: close every blocking finding from the two fresh-context reviews, and the two the
reviews exposed in the *evidence* rather than the code.

**Independent Test**: the reviewers' own reproduced scenarios flip from passing to failing —
an untracked review file, a commented-out provenance block, a duplicated developer name, a
root-array record; S1–S12 re-run unchanged; the doctor table re-measured rather than reasoned.

**Territory**:

- `scripts/enforcement-pack.ps1`
- `scripts/verify-kit.ps1`
- `specs/_templates/human-pr-review-template.md`
- `docs/sdlc/critical-delivery.md`
- `adoption/updating.md`
- `adoption/greenfield.md`

- [x] T019 (L1, BLOCKING) Team mode must require `human-pr-review.md` to be **committed**,
      mirroring the solo arm's git-history guard. A Critical feature cannot use `ci-held`, so
      the authoritative gate is a human's local run — exactly where an untracked file passes
- [x] T020 (L2, BLOCKING) Strip HTML comments before slicing the provenance section, and
      match the attestation against the **slice**, not the whole file (contract M13, the rule
      `Get-VisiblePlanLines` already states). Handle an **unterminated** `<!--` as commenting
      out the remainder, because that is what a renderer does
- [x] T021 (L2 corollary) Move the explanatory comment **out of** the provenance section in
      `specs/_templates/human-pr-review-template.md`. A dropped `-->` inside the block turns a
      filled block invisible while the check still blesses it — the template shipped the trap
- [x] T022 (B1 / CONFIRM 3, BLOCKING) De-duplicate case-insensitively in `Get-EvidenceMode`
      so the enforcing side agrees with the reporting side. `["Ada","ada"]` is one person and
      must not inflate a solo project into team mode — the only direction that drops a
      requirement
- [x] T023 (CONFIRM 4) Require the parsed record to be an object before reading `.developers`:
      PowerShell member enumeration makes `[{"developers":["a","b"]}]` return a real array from
      a record with no other field at all, selecting team in violation of FR-003
- [x] T024 (C1) Reword the script header's "one step stronger than ReviewProvenance" claim,
      which contradicts FR-007's explicit ceiling. State the roster's limit in the same place:
      it is counted, never compared against Reviewer or Owner (spec Edge Cases, CONFIRM 5)
- [x] T025 (C2, N2) Spell the artifact's path — `specs/NNN-name/human-pr-review.md` — in item 5
      and in `adoption/updating.md`, as the solo bullet already does for its artifact; and add
      the attestation to updating.md's team row, which omits a thing the check requires
- [x] T026 (B1 docs half, N1) Correct both places that call a duplicate or blank-entry record
      "ignored, falls back to solo"; fix "the first **row**" left over from the table→list
      conversion; add the missing honesty caveat to `adoption/greenfield.md` (N4)
- [x] T027 (N6, N7, N8, N9) Placeholder regex accepts a markdown link; fenced code inside the
      section no longer supplies values; drop the dead `$dir = $Dir` self-assignments; restructure
      the doctor so one defect reports once and the mode line always prints
- [x] T028 (B2) Re-measure the phase 2 doctor table with the evidence mode taken from
      `enforcement-pack.ps1` rather than inferred, and correct the fabricated row
- [x] T029 (C3) Verify SC-006 — the adopted projects' records untouched by this feature — and
      record the result, or record plainly which projects were not reachable from here

## Phase 4 — remediation results

### The two review verdicts

Both fresh-context reviews returned **REQUEST CHANGES**. Between them: two blocking defects in
the code that this session had not seen, one blocking defect both found independently, one more
FR-003 violation, and two failures in the *evidence and process* rather than the code.

### B2 — the row that was wrong, and why

The phase 2 doctor table recorded `["Ada","ada"] → solo`. The code produced **team**. The
column was filled by reasoning from what the doctor said, not by running the check — and the
paragraph directly beneath the table said the opposite of the table, which is what gave it
away. The table above is corrected and every mode below was **measured**:

| Record shape | Evidence mode (measured 2026-09-10, post-remediation) |
|---|---|
| field absent | solo |
| `["ada"]` | solo |
| `["ada","grace"]` | team |
| `"ada"` (a string) | solo |
| `[]` | solo |
| `["ada","  "]` | solo |
| `["Ada","ada"]` | solo |
| `[{"developers":["a","b"]}]` (root array) | solo |

Every degenerate shape now lands on the stricter arm. FR-003 holds — and this time that is a
measurement rather than an assertion.

### The reviewers' scenarios, flipped

Each of these was reproduced by a reviewer against the phase 3 code and passed when it should
have failed. Re-run against phase 4:

| # | Scenario | Now |
|---|---|---|
| R1 | `human-pr-review.md` present but never `git add`ed | FAIL — not committed |
| R2 | provenance block entirely inside `<!-- -->` | FAIL — no visible section |
| R3 | the template's own comment loses its closing `-->` | FAIL — names unreadable |
| R4 | attestation present only outside the section | FAIL — missing from the section |
| R5 | `["Ada","ada"]` | FAIL — solo arm, as it should always have been |
| R6 | names supplied only inside a fenced code block | FAIL — fenced content is illustration |
| R7 | a real, filled, committed review | **pass** |
| R8 | `**Reviewer**: [Alice](mailto:…)` — a markdown link | **pass** |
| R9 | root-array record | FAIL — solo arm |

R9 took two attempts, and the first one is worth recording. The obvious guard —
`$record -isnot [PSCustomObject]` — does not catch it: `ConvertFrom-Json` emits array elements
to the pipeline one at a time, so a **single-element** root array collapses to one
`PSCustomObject` indistinguishable from a real record. The shape has to be rejected from the
raw text. The regression fixture caught the bad fix immediately, which is the argument for
writing the fixture before trusting the patch.

### No regression

- **S1–S12**: verdicts unchanged from phase 2. One message differs by design — S10 now says
  "no **visible** `## Review Provenance` section" and explains that a commented-out section
  renders as nothing.
- **Solo mode**: still byte-identical to the pre-013 baseline captured at T001, diffed again
  after phase 4.
- **SC-006 (T029)**: all three adopted projects — expense-tracker, fitforge, flowboard —
  verified directly. Each `kit-adoption.json` is `clean` in git (untouched by this feature),
  none declares `developers`, and the new doctor is silent about the field for all three, which
  is the designed behaviour for a record that predates it. Verified, not assumed.
- **SC-001** remains the one unmet criterion. It cannot be met from this repository: it asks
  that FitForge 002 pass on its genuine cross-review, which requires this feature to merge and
  flow down first. Recorded as outstanding rather than quietly dropped.

### What the reviews cost, and what they were worth

Four blocking-class code defects, two evidence failures, nine nits — on a feature whose entire
subject is a check that was enforcing the wrong thing. Two of the four blocking defects were
invisible to every machine check in the kit: an untracked file and a commented-out block both
produced `RESULT OK`. The strongest single finding is L1, and it is worth stating plainly: the
check that exists to prove a human reviewed the code could be satisfied by a file that existed
only on the implementer's disk.

## Phase 4 — gate (ci-held)

| Run | Conclusion | Commit | Owner approval |
|---|---|---|---|
| [34464641137](https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/34464641137) | success | `43e52cfd4cd79c2bc24f050dbe039f13b864ee14` | recorded 2026-09-10 |

Four phases, four runs, four commits — each pushed alone.

## Phase 5: Re-review remediation (added by amendment — approved by anas.m, 2026-09-10)

**Goal**: close the residual of BLOCKING 1, the regression phase 4 introduced, and the second
drift between the two scripts — this time by removing the possibility of drift rather than
correcting it.

**Independent Test**: fixtures G3 (committed path, uncommitted content) and U1 (unreadable
record) flip; both scripts report the same mode for every record shape because they call the
same function; S1–S12 and R1–R9 unchanged; solo still byte-identical to the T001 baseline.

**Territory**:

- `scripts/adoption-lib.ps1`
- `scripts/enforcement-pack.ps1`
- `scripts/verify-kit.ps1`
- `docs/sdlc/critical-delivery.md`
- `adoption/updating.md`
- `adoption/greenfield.md`

- [x] T030 (logic N1) Read the review from the **committed blob** (`git show HEAD:<path>`), not
      the working tree. A committed path with uncommitted content passed — the natural
      workflow of copying the template in early and filling it at review time. Reading the
      blob makes the phase 4 history guard redundant and says the same thing the solo arm
      already says: your edits do not count until you commit them
- [x] T031 (logic N2 — a regression phase 4 introduced) Restore the `try` around the record
      read. Moving `Get-Content` outside it made an unreadable `kit-adoption.json` an
      unhandled terminating error that skipped **every check after CriticalEvidence**. FR-003
      names "unreadable" among the records that must resolve to solo
- [x] T032 (docs NEW-1, logic N6) Extract one `Get-DeveloperMode` into a dot-sourced
      `scripts/adoption-lib.ps1` and call it from both scripts, the `scope-lib.ps1` pattern
      from feature 012. The two copies had already drifted twice — the root-object guard
      landed in one, and the dedupe comparer differs between them. A comment claiming they
      match is not a mechanism; one function is
- [x] T033 (logic N3) Strip `~~~` fences and 4-space-indented code blocks inside the section,
      not only backtick fences — illustration must not read as declaration in any form
- [x] T034 (logic N4) `IndexOf('<!--', [StringComparison]::Ordinal)` — the culture-sensitive
      overload can find a marker a renderer never sees
- [x] T035 (logic N5) When the section is absent, say that an unterminated `<!--` anywhere
      earlier hides everything after it. The rule is right; the message left an author unable
      to work out why a visible block was called invisible
- [x] T036 (docs NEW-2, N1-residual, N4-placement) Document that non-string entries are dropped
      like blanks; make the mode line reachable on every branch; "the second row" → "arm";
      move the greenfield guidance to the step that writes the record
- [x] T037 Re-run every fixture family — S1–S12, R1–R9, the doctor shapes, G3, U1 — and record
      the results; re-diff solo against the T001 baseline

## Phase 5 — remediation results

### The two re-review verdicts

The docs reviewer returned **APPROVE WITH COMMENTS** — all three of its blocking findings
closed and independently re-measured. The logic reviewer returned **REQUEST CHANGES**: both
its blocking findings substantively closed, but phase 4's fix for the first one had **moved
the hole rather than shut it**, and phase 4 had **introduced a regression**.

### The two that mattered

**N1 — the hole moved.** Phase 4's guard proved the review file's *path* was in history; the
content was still read from the working tree. Commit the template early, fill it locally at
review time, never commit — and the check passed on content the branch does not carry. That
is the normal workflow, not a contrivance. Phase 5 reads the **committed blob**
(`git show HEAD:<path>`), which makes the history guard redundant and says what the solo arm
has always said: your edits do not count until you commit them.

| Fixture | Result |
|---|---|
| G3 — committed placeholder, filled only in the working tree | FAIL — grades the committed content |
| G3b — same content, committed | pass |

**N2 — a regression this feature introduced.** Fixing the root-array case in phase 4 moved
`Get-Content` outside its `try`. With `$ErrorActionPreference = 'Stop'` an unreadable record —
a directory, a lock, a permission denial — became an unhandled terminating error that skipped
**every check ordered after CriticalEvidence**: GateBatching, GateCertification,
ReviewProvenance, PhaseSizeWarning. Nothing passed wrongly, but four checks silently did not
run. FR-003 names "unreadable" among the records that must resolve to solo. Fixture U1 now
falls back to solo and the run summarises normally.

### The drift, removed rather than corrected

The two scripts diverged **twice inside one feature**: the root-object guard landed only in
the enforcing copy, and the two used different dedupe comparers. The second divergence was
found by a reviewer reading the phase 4 comment that asserted they matched exactly — a comment
is not a mechanism.

`scripts/adoption-lib.ps1` now holds one `Get-DeveloperMode`, dot-sourced by both, returning
the mode the check enforces *and* the problems the doctor reports. Neither script interprets
the record any more. This is the `scope-lib.ps1` pattern feature 012 established for exactly
this reason, and the case that proved it necessary is now green on both sides:

| Record | enforcement-pack | verify-kit |
|---|---|---|
| `[{"developers":["a","b"]}]` | solo | solo, FAIL "not a JSON object at its root" |

### No regression

- **R1–R9**: all nine still correct.
- **S1–S12**: verdicts unchanged from phase 4; one message differs by design (N5 — the
  absent-section message now says an unterminated `<!--` earlier in the file hides everything
  after it, because the previous wording left an author unable to diagnose a visible block
  being called invisible).
- **Solo mode**: still byte-identical to the pre-013 T001 baseline, diffed a third time.
- **Doctor**: one FAIL per defect, and the mode line now prints on every branch including
  not-an-array (docs NEW-2).

### Closed here, and what remains

Closed: logic N1, N2, N3 (`~~~` and indented code now stripped), N4 (ordinal `IndexOf`),
N5, N6 (one comparer, so the null-deref hazard cannot arise); docs NEW-1, NEW-2, N1-residual,
N4-placement; C1 and C4 by amendment, each with a recorded approver.

Left open deliberately: **C2** — `docs/sdlc/review-process.md` and
`docs/sdlc/definition-of-done.md` still point at the template path rather than
`specs/NNN-name/human-pr-review.md`. Both are pre-existing sentences outside this feature's
Territory, and the docs reviewer explicitly ruled it a follow-up rather than a blocker:
widening Territory post-hoc to sweep two sentences is the drive-by the scope check exists to
catch. Worth a Lite `fix/` branch soon — a team reading review-process.md alone can still put
the file where the check will not find it.

### The pattern worth carrying forward

Phase 4 closed four defects and introduced one; its fix for the most serious finding moved the
hole instead of closing it. Both facts were found by re-review, not by any check. Two rounds of
remediation each needed their own review, which is the argument against treating a fix as done
because it was written carefully.

## Phase 5 — gate (ci-held)

| Run | Conclusion | Commit | Owner approval |
|---|---|---|---|
| [34475481440](https://github.com/anas-mattar/agentic-sdlc-kit/actions/runs/34475481440) | success | `9054e97ad273c989d0e22933021144d078d6fd46` | recorded 2026-09-10 |

Five phases, five runs, five commits, each pushed alone.

## Phase 6: Third-pass remediation (added by amendment — approved by anas.m, 2026-09-10)

**Goal**: close the blocking defect and the fail-closed regression phase 5 introduced, correct
three inaccurate statements this feature made about itself, and give this file a current-state
entry point. The last remediation round before a human reads the diff.

**Independent Test**: `-Developers ada,grace` under `pwsh -File` yields two developers; a
governance repo in a subdirectory passes; a nested-list provenance line passes while a real
indented code block is still ignored; a committed-but-empty review is not called uncommitted;
every earlier fixture family unchanged.

**Territory**:

- `scripts/init-kit.ps1`
- `scripts/adoption-lib.ps1`
- `scripts/enforcement-pack.ps1`
- `scripts/verify-kit.ps1`
- `adoption/greenfield.md`
- `adoption/updating.md`
- `docs/digests/*.md`

- [x] T038 (NEW-3, BLOCKING) Split `-Developers` on commas in `init-kit.ps1`, so the
      invocation the kit's own onboarding prints cannot silently declare one developer named
      "ada,grace"
- [x] T039 (NEW-A) `git show "HEAD:./$Dir/..."` — the `./` makes git resolve against the
      working directory `Push-Location $Root` already set, instead of the repository root
- [x] T040 (NEW-C) Decide on `$LASTEXITCODE` alone; a committed but empty file must fail the
      section check, not be called uncommitted
- [x] T041 (NEW-B) Treat an indented run as code only when it opens after a blank line — four
      spaces inside a list is a nested item in CommonMark, not code
- [x] T042 (NEW-4) Narrow the header's justification for ignoring `Problems` to what is true:
      a problem never produces a *laxer* mode. It does not mean every problem lands on solo
- [x] T043 (NEW-5) Correct the drift account in all three places: one cross-copy drift, plus
      two comparers disagreeing inside the doctor — not two cross-copy drifts
- [x] T044 (NEW-6 / NEW-D) Return `Declared` from `Get-DeveloperMode` and gate the doctor on
      it, removing its private raw-text test and the last unguarded read in the new code
- [x] T045 (NEW-E) `-ErrorAction Stop` on the library's own read, so its `try` does not depend
      on the caller's preference
- [x] T046 Report an explicit `"developers": null` the way `[]` is reported — but only when the
      key is actually present, so an absent field stays silent
- [x] T047 (NIT-3) Correct `spec.md`'s account of what each reviewer judged
- [x] T048 (NIT-4, NIT-5) Rewrap the over-long line; blank line before the D4 amendment note
- [x] T049 Add `## Current state (authoritative)` and back-point the two superseded tables
- [x] T050 Re-run every fixture family and re-diff solo against the T001 baseline
