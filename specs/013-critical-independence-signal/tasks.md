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

## Fixture scenarios (S1–S12)

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
| `["Ada","ada"]` | FAIL — listed more than once | solo |

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
