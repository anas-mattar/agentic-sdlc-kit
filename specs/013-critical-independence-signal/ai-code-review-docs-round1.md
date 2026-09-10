# AI Code Review — 013 Critical Independence Signal — law and docs coherence (round 1)

**Reviewer**: fresh-context agent — `claude-opus-5` (Agent tool, `general-purpose`, task "Review of 013 law and docs coherence")
**Date**: 2026-09-10
**Branch**: `agentic-sdlc-kit` `013-critical-independence-signal`
**Under review**: phases 1-3, branch tip `b60b868`
**Scope reviewed**: `docs/sdlc/critical-delivery.md`, `adoption/updating.md`, `adoption/greenfield.md`, `specs/_templates/human-pr-review-template.md`, `spec.md`, `plan.md`, `tasks.md`, `docs/roadmap.md` — every claim cross-checked against the shipped scripts and, where it was a behavioural claim, against a fixture.
**Verdict**: REQUEST CHANGES — blocking findings: 3

Everything below the rule is the reviewer's report, **verbatim**. It is evidence for
Definition of Done gate 5 and is not edited to match what was later fixed; where a finding
was wrong, the reviewer's own next round says so. What was done about each finding is
recorded in `tasks.md`, not here.

---

## Reviewer Provenance
- **Reviewer**: fresh-context agent — claude-opus-5
- **Implementer**: the main session that produced this diff
- **Inputs provided**: 013 diff (docs/, adoption/, specs/), the shipped scripts for cross-checking
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict
REQUEST CHANGES

## Findings

### BLOCKING

**B1 — The law and the check disagree again, on the malformed case.**
`docs/sdlc/critical-delivery.md:105` ("An absent, empty or malformed declaration selects the **first** row") and `adoption/updating.md:377-380` ("A malformed value (not an array, empty, **a blank entry, the same person twice**) is **ignored** and the project falls back to solo").

Both are false for two of the four listed shapes. `Get-EvidenceMode` (scripts/enforcement-pack.ps1) filters blanks and non-strings, then counts — it never de-duplicates. **Verified empirically on a fixture**, not reasoned:

- `"developers": ["Ada","ada"]` → `team mode (2 developers declared in kit-adoption.json)`
- `"developers": ["ada","grace","  "]` → `team mode (2 developers declared in kit-adoption.json)`

(Controls also run and correct: field absent → solo; `["ada"]` → solo.)

Consequence for an adopter: a record with a duplicated or fat-fingered name is exactly the case the docs promise is "safe" — and it is the one case that silently *drops* the second-model review and the 24-hour cooling-off from a solo project's Critical lane. `verify-kit.ps1` does FAIL on it, but updating.md tells the reader that FAIL means "you are still being checked as solo," which is the opposite of the truth, so the doctor's warning actively misleads. This is the same law-vs-machine divergence that justifies feature 013's existence, reintroduced by the feature's own documentation. Either de-duplicate case-insensitively in `Get-EvidenceMode` (which would make both sentences true and align it with the doctor), or rewrite both sentences to say the count is taken after blanks are dropped and duplicates are *not* collapsed.

**B2 — A recorded fixture result contradicts the shipped code and its own prose.**
`specs/013-critical-independence-signal/tasks.md`, Phase 2 doctor-results table, row `["Ada","ada"]`: Evidence mode recorded as **solo**.

The code produces **team** (verified above). Worse, the paragraph three lines below the table says the opposite: *"it inflates the count into team mode — the only direction this feature must never move a project by accident."* One of the two is fabricated or mis-transcribed. Under constitution VIII this table is the feature's test evidence for a business-critical governance rule; a wrong row here is the evidence record asserting a behaviour the machine does not have. It also means the S12/degenerate-record claim behind SC-003 ("Every degenerate record … selects the strict rule") is not actually demonstrated — it is contradicted.

**B3 — Feature 013 violates feature 011's own claim-time roadmap law, and main's CI is red as of this branch.**
`docs/roadmap.md` — unchanged by this diff.

Verified by running the check: `pwsh -File scripts/roadmap-claim-check.ps1 -Branch main` →
`roadmap-claims: claim '013-critical-independence-signal' is on origin but no roadmap row mentions it … roadmap-claims: FAIL`.

`origin/013-critical-independence-signal` exists; `docs/roadmap.md` has no row for it and no `GAP-020` entry, even though `spec.md:139` cites GAP-020 as the gap this feature closes (grep: GAP-020 appears exactly once in the repo, in that spec line — it is a dangling identifier). Every feature 001–012 has a roadmap row. The branch's own CI passes only because of the own-number exemption; anyone on `main` or on any other feature branch gets a red `ritual-checks` today. Consequence: this is precisely GAP-017 — a teammate orienting from main sees no trace of the in-flight feature — committed by the feature that exists to make the machine agree with the law.

### CONFIRM

**C1 — FR-007's explicit ceiling is exceeded by the shipped self-description.**
`spec.md` FR-007: *"Comparing two names written by the same team is evidence of **the same strength as the Reviewer Provenance block** … and it MUST NOT be described as more than that."* The shipped header comment in `scripts/enforcement-pack.ps1` says the team check *"is deliberately **one step stronger** than ReviewProvenance below, which compares nothing"*, and `plan.md` D4 says the same. FR-007 says "in its own documentation," and a script header is exactly that. Either D4's reasoning is right and FR-007 should have been amended before implementation (the spec was Approved 2026-09-10; nothing records an amendment), or the header oversells. The two prose docs I was asked to review (`critical-delivery.md` and the template) are *not* oversold — both say "two names written by the same team, in one file … does not verify that the review happened," which I read as honest and correctly hedged. The contradiction is spec-vs-plan-vs-script, and the plan does not acknowledge it as an FR change.

**C2 — Nothing states where `human-pr-review.md` must live, and the closest process doc points at the wrong path.**
`docs/sdlc/critical-delivery.md:100` says `human-pr-review.md` bare; `adoption/updating.md:369` likewise. The check requires `specs/<branch>/human-pr-review.md`. Item 5's *solo* bullet spells its artifact out fully (`specs/NNN-name/second-model-review.md`) — the new team bullet does not. Meanwhile `docs/sdlc/review-process.md:121` says "record in `specs/_templates/human-pr-review-template.md`" (the template path), and `docs/sdlc/definition-of-done.md:131` names only the template. Consequence: 013 promotes this file from convention to machine-required for team Critical features, and a team following review-process.md can put it somewhere the check will never find, discovering it as a red CI run. T017's sweep looked for "descriptions of the substitute" and would not have caught this class.

**C3 — Two success criteria have no recorded result.**
`spec.md` SC-001 (FitForge 002 passes on its genuine cross-review, no `second-model-review.md` present) and SC-006 (the three adopted projects' records untouched and unchanged — *"verified, not assumed"*). `tasks.md` records S1–S12, the doctor table, the T017 sweep, and three gate triplets, but nothing for either SC. SC-001 is the stated motivating case for the whole feature. Consequence: the feature's own evidence record does not demonstrate the outcome it was specified to produce.

**C4 — A spec edge case is neither implemented nor addressed anywhere.**
`spec.md` Edge Cases: *"A record naming developers whose handles do not match the identities used in the roadmap or the review document — the comparison **must fail loudly** rather than pass by accident."* The team check compares Reviewer against Owner only, both read from the same file; it never compares either against the `developers` array. A record declaring `["ada","grace"]` and a review naming `bob`/`carol` passes. Neither `plan.md` D1–D6 nor `tasks.md` records a decision to drop this edge case (contrast the "Assumptions" section, which covers *false* declarations but not *mismatched* ones). Reasoning from code, not fixture-tested.

### NIT

**N1 — `critical-delivery.md:105` says "selects the **first** row"** but the thing above it is a bulleted list, not a table. Residue from the table→list conversion tasks.md describes. Say "the first bullet" or "the solo arm."

**N2 — `adoption/updating.md:369`, the two-or-more table row, omits the verbatim attestation** that `critical-delivery.md:101-102` and the check both require. An adopter configuring from updating.md's table alone fills Reviewer and Owner, ships, and fails CI on the missing attestation sentence.

**N3 — `## Review Provenance` (new, human-pr-review-template.md:9) vs `## Reviewer Provenance` (existing, ai-code-review-template.md:10).** Two sibling templates in the same directory, two exact-match-enforced headings, one word apart. A human who writes the more familiar "Reviewer Provenance" into `human-pr-review.md` gets a failure. The failure message names the correct heading, so it is recoverable — but the collision is avoidable.

**N4 — `adoption/greenfield.md:154-161` places the `-Developers` guidance in step 7 ("Keep the framework honest"), after `init-kit.ps1` has already run in steps 1–2 (line 44).** T013 specified "the same, at the step that writes `kit-adoption.json`." A greenfield adopter reading in order writes the record before learning the flag exists, and must hand-edit. Also, unlike updating.md and critical-delivery.md, this bullet carries no honesty caveat about the team check's strength — it calls team mode "the real thing" unqualified. Mitigated by its pointers to both other documents.

### What I actively checked and found correct

- **Item 5's requirement is untouched.** `git diff --numstat` on `docs/sdlc/critical-delivery.md` = `22 0` — additions only. The independence sentence, both substitute sub-bullets, the original **Honesty** paragraph and the **Why** are byte-identical. No weakening.
- **Rendered structure (GAP-015) of every new block.** The new bullets in item 5 sit at 3-space indent inside ordered item `5.`, matching the existing sub-bullets, with a blank line before the list — they render as list continuations. Both `<!-- digest: -->` markers are standalone lines at the same indent with a blank line separating them from the preceding paragraph; neither sits inside a table or mid-paragraph. `adoption/updating.md`'s new table is uniform 2/2/2/2 cells with a matching `|---|---|` separator and blank lines on both sides, and is *not* nested in a list. The `adoption/greenfield.md` bullet's continuation lines are at 2 spaces, matching its siblings. The template's HTML comment sits between the `##` heading and the list, which is inert. I found no severed block anywhere in the diff; the author's recorded table→list conversion in item 5 was the right call.
- **Backtick-path rule.** `pwsh -File scripts/doc-lint.ps1` → OK. Every new backticked multi-segment path resolves (`docs/sdlc/critical-delivery.md`, `scripts/enforcement-pack.ps1`, `scripts/verify-kit.ps1`); the bare filenames (`kit-adoption.json`, `human-pr-review.md`, `second-model-review.md`, `init-kit.ps1`, `-Developers`) are correctly outside doc-lint's path shape.
- **Digests match their markers.** `pwsh -File scripts/build-digests.ps1 -Check` → `OK (5 digest(s) fresh, 73 marker(s))`. The new `critical-digest.md` bullet is in document order (after Critical 5, before "Critical adds nothing") and within the 120-char bound.
- **"Declaring nothing changes nothing" — the load-bearing claim — is true.** Verified on fixtures: no `kit-adoption.json`, and a record with no `developers` field, both take the solo arm with the pre-013 message text. `["ada"]` likewise. Every adoption predating this feature is genuinely unaffected.
- **T017's sweep is accurate.** I re-ran the enumeration independently: `.specify/memory/constitution.md:64,137` name the cooling-off hours as a sync-listed constant (still 24, correct), and line 96 does read "the Critical-**solo** review substitute" in a historical SYNC IMPACT REPORT. No document outside item 5 states the substitute unconditionally. Not editing those was right.
- **`Get-ProvenanceValue` cannot be shadowed by the template's header `**Reviewer**: [name]` line** — the slice regex bounds the search to the `## Review Provenance` section, and the section's HTML comment contains no `**Reviewer**:` line and no copy of the attestation sentence. The trap T004 called out is genuinely avoided.
