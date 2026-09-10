# Implementation Plan: Critical Independence Signal

**Branch**: `013-critical-independence-signal` | **Date**: 2026-09-10 | **Spec**: specs/013-critical-independence-signal/spec.md
**Input**: Feature specification + decisions D1–D6 below
**Gate Batching**: none
**Gate Certification**: ci-held

## Summary

`Invoke-CriticalEvidenceCheck` gains a **mode**, derived from a new optional `developers` array
in `kit-adoption.json` (D1). One developer or no usable declaration selects **solo**, whose rule
is today's, unchanged to the message (D2). Two or more selects **team**, which requires the
independence `docs/sdlc/critical-delivery.md` item 5 actually asks for: a completed
`human-pr-review.md` whose new provenance block names a reviewer who is not the feature's owner
(D3). Neither mode is satisfiable by silence, and no mode is weaker than today's for any project
that does not opt in.

No constitutional amendment. The constitution's body mentions Critical only to forbid batching,
`ci-held` and the Micro lane; the substitute is defined in `docs/sdlc/critical-delivery.md`, whose
*requirement* this feature does not touch — it makes the machine agree with the requirement.
`$Config.CoolingOffHours` stays 24 and stays sync-listed. Constitution stays 0.6.0.

## Technical Context

**Language**: PowerShell 7 (the kit's only scripting surface) + Markdown/JSON. **Testing**:
seeded fixture repositories under the scratchpad; no test framework (kit convention — 006, 010,
012). **Target**: the kit repo (solo — behaviour unchanged) and adopted projects via
`update-kit.ps1` plus a one-line record edit. **Constraints**: zero new dependencies; read-only
except for the record shape it validates; backward compatible by construction (D2).

## Decisions

- **D1 — the signal is `developers`, an array of strings in `kit-adoption.json`.** Rejected:
  a `soloDeveloper` boolean (carries strictly less information and would need replacing the
  moment GAP-004's pipelining check wants a roster); inferring team size from commit authorship
  (wrong in exactly the case that matters — an agent commits as its owner, so a two-developer
  project driving two agents looks like whatever git is configured to say). The record is where
  `codeRepos` and `gateProof` already live, it is surgical so `update-kit.ps1` never overwrites
  an adopter's copy, and `verify-kit.ps1` already validates that file.
- **D2 — the mode is derived, and absence is strict.** `solo` when the declaration is absent,
  empty, malformed, or names one entry; `team` only when it names two or more usable entries.
  Derived rather than declared so a project cannot assert team independence while naming one
  person. Strict-on-absence is the load-bearing half: three projects have adopted this kit and
  none carry the field, so any other default would turn a red check green in projects that never
  asked — the silent downgrade feature 012's reviews found four times in one feature.
- **D3 — team mode is proved by a provenance block in `human-pr-review.md`.** The file gains a
  `## Review Provenance` section carrying `**Reviewer**`, `**Owner**` and the verbatim
  attestation `This reviewer is not the owner of the feature under review.` Team mode requires
  the file, the section, both lines filled and non-placeholder, the attestation present, and
  **Reviewer ≠ Owner** compared case- and whitespace-insensitively.
- **D4 — D3 is deliberately stronger than the existing AI-review provenance check, and the
  difference is recorded rather than copied.** `Invoke-ReviewProvenanceCheck` never compares two
  values: it rejects an empty Reviewer, a `[placeholder]`, and a value that literally begins with
  the word "implementer". It cannot catch a reviewer who names themselves. Its header comment
  reads as though it compares; it does not. Two names in one file *can* be compared, so this
  check compares them. What that buys is still bounded and FR-007 requires saying so: both names
  are written by the same team, so the check converts a silent omission into a written claim a
  human can falsify — no more. GAP-019 is where the general problem stays recorded.
- **D5 — the check keeps its name and its home.** Extending `Invoke-CriticalEvidenceCheck` rather
  than adding a `ritual-checks` member: the failure is one rule inside one lane, the enumeration
  of members is the thing that has gone stale in three previous features (kit 011), and a new
  member would have to report `n/a` for every non-Critical feature — an inert row on every run.
- **D6 — `docs/sdlc/` changes ride inside this feature branch.** Team-workflow rule 7 (governance
  rides alone) does not bind this repository: `docs/sdlc/team-workflow.md` opens by stating that
  single-developer projects can ignore it, and the kit is one. Feature 012 set the precedent for
  a kit feature that states its own law in its final phase. **This exemption does not flow down**
  — an adopted project with two developers is exactly who rule 7 binds, and FitForge's own
  `docs/sdlc/` edits must ride alone.

## Constitution Check

- **I Specification First**: spec.md, plan.md and tasks.md exist before implementation. PASS.
- **II Source of Truth**: no ladder change. The check reads `kit-adoption.json` (project fact)
  and `human-pr-review.md` (feature artifact); neither is promoted above anything. PASS.
- **III Repository Separation**: single-repo kit; nothing lands outside it. N/A.
- **IV Architecture Consistency**: extends an existing check inside an existing script (D5); no
  new pattern, no new file in `scripts/`, no packages. PASS.
- **V Domain Invariants**: the kit's domain is its own governance; no invariant pack. N/A.
- **VI Security**: read-only; no secrets; the new record field holds names the project already
  publishes in its roadmap. PASS.
- **VII External Integration Governance**: no external integration. The record's shape is a
  documented contract and is specified in `adoption/updating.md` in phase 2 before any adopter
  writes it. PASS.
- **VIII Testing Requirements**: business-critical governance logic — a wrong PASS disables the
  independence requirement in the kit's strictest lane. Deterministic validation via seeded
  fixture repositories covering every mode and every degenerate record (S1–S12 in tasks.md),
  each with a recorded verdict. PASS.
- **IX Human Review**: fresh-context AI review per phase + human review at merge. The kit is
  solo, so its own Critical substitute would apply — but this feature is Standard, not Critical,
  so item 5 does not bind it. PASS.
- **X Controlled Delivery**: 3 phases, each independently revertible and testable.
  **Gate Batching: none** — deliberately unbatched though 012 batched three: phase 1 changes an
  enforcement rule, and the lesson recorded from FitForge 001 is that two phases in one push
  leave one of them with no CI evidence of its own. **Gate Certification: ci-held** — Standard
  feature, eligible, declared here before any phase. The agent reports the evidence triplet and
  never claims the gate. PASS.

**Phase-sizing**: each phase stands alone. Phase 1 makes the check correct and is provable on
fixtures with no adopter involved. Phase 2 makes the record and the doctor aware of the field.
Phase 3 states the law. Reverting any one leaves the others correct — phase 1 without phase 2
still behaves exactly as today for every project, because no record declares the field yet.

## Source Code (repository root)

```text
scripts/enforcement-pack.ps1                  # MOD  phase 1 — mode derivation + team rule (D1, D2, D3, D5)
specs/_templates/human-pr-review-template.md  # MOD  phase 1 — the Review Provenance block (D3)
scripts/verify-kit.ps1                        # MOD  phase 2 — validate the developers field (FR-009)
scripts/init-kit.ps1                          # MOD  phase 2 — write it at init when supplied
adoption/updating.md                          # MOD  phase 2 — how an existing project declares it
adoption/greenfield.md                        # MOD  phase 2 — how a new project declares it
docs/sdlc/critical-delivery.md                # MOD  phase 3 — item 5 states the two modes (FR-010, D6)
docs/digests/*.md                             # GEN  phase 3 — regenerated if a marker moved
```

## Testing Strategy

No test framework — the kit's convention since 006. Validation is seeded fixture repositories in
the scratchpad, each a throwaway git repo carrying a `specs/NNN-x/spec.md` declaring Critical, a
`kit-adoption.json`, and whichever review artifacts the scenario needs. Scenarios S1–S12 are
enumerated in `tasks.md` with their expected verdicts and are re-run at the end of every phase.

Two behaviour-preservation obligations, both explicit because this feature edits a check that
three projects already depend on:

1. Every solo scenario must produce today's message **byte for byte**, including the cooling-off
   remainder arithmetic. The current messages are captured before the edit and diffed after.
2. The kit's own `ritual-checks.ps1` must stay green at every phase, and the three adopted
   projects' records must be untouched (SC-006) — verified by reading them, not assumed.

## Complexity Tracking

One addition worth naming: this feature introduces the kit's first *conditional* enforcement
rule — a check whose requirement depends on a project-declared fact. That is a genuinely new
shape and it carries a matching risk, which D2 exists to bound: the conditional must never be
the reason something passes. Every degenerate input resolves to the stricter branch, and S1–S12
exist to prove it rather than to assert it.
