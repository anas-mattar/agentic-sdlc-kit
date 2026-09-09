# AI Code Review — 010 Law Digests, Phase 2 (the content)

**Reviewer**: fresh-context general-purpose subagent (Claude Fable 5, claude-fable-5)
**Date**: 2026-09-09
**Branches**: agentic-sdlc-kit `010-law-digests` (tip `040dbd2` — the commit under review)
**Scope reviewed**: full commit diff of `040dbd2` (`git show`, 16 files, +270/−4); all 68
inserted markers read against their surrounding rule text — full-source context re-read
(beyond the diff hunks) in `adoption/updating.md` (§1 intro, report table, §2 steps 4–6),
`docs/sdlc/branch-strategy.md` (structure note, Number Allocation, levels, Rules),
`docs/sdlc/team-workflow.md` (rules 1–8 incl. the full pipelining conditions and rule 6),
`docs/sdlc/critical-delivery.md` (items 4–5 incl. the cooling-off clause, NOT section),
`docs/sdlc/definition-of-done.md` (Two units, gates 1–6, conflict rule),
`docs/sdlc/gate-command.md` (certification intro, agent-run rule, batched gates, ci-held
triplet, CI wiring, minimum gate, strict-flag triage), `docs/sdlc/flow.md` (diagram +
steps table), `docs/sdlc/review-process.md` (visual loop, After Each Phase, AI review,
human review), `docs/sdlc/rollback-process.md`, `docs/sdlc/repository-strategy.md`; all
five `docs/digests/*-digest.md` in full; governing docs
`specs/010-law-digests/{spec.md,plan.md,tasks.md,research.md,data-model.md,quickstart.md,contracts/digest-checks.md}`.
Live runs: `build-digests.ps1 -Check -Root <kit>` → `digests: OK (5 digest(s) fresh,
68 marker(s))`, exit 0; `scope-check.ps1` → `PASS phase 2 commit 040dbd2 (16 file(s))`;
full `ritual-checks.ps1` → `RESULT OK` (doc-lint OK, enforcement-pack OK, scope-check OK,
digests OK). Mechanical sweep: every added line in the ten pack documents is either a
`<!-- digest: … -->` line or a blank line, and zero lines were removed (grep over the
per-file diffs) — no law prose changed.
**Feature contract**: plan.md phase 2 row — markers beside the binding rules of the ten
pack documents + five generated digests committed under the live check; Territory = the
ten documents + `docs/digests/**` (spec-dir exempt); FR-001/003/008/009; SC-001 (≤40
content lines per digest); no generator/manifest/check changes in this phase.

## Reviewer Provenance

- **Reviewer**: fresh-context general-purpose subagent (separate context; second-model review lane) — Claude Fable 5 (claude-fable-5)
- **Implementer**: the agent session that produced commit `040dbd2` (unknown to this reviewer beyond the commit metadata)
- **Inputs provided**: review instructions naming the commit sha only; spec.md, plan.md, tasks.md, research.md, data-model.md, quickstart.md, and contracts/digest-checks.md read from the repo; the phase diff via `git show 040dbd2`
- **Attestation**: This reviewer did not produce the diff under review.
- **Context**: this reviewer was given only the review instructions and read the spec/plan/contract from the repo; no implementation conversation or reasoning was shared.

## Verdict

**REQUEST CHANGES** — one blocking structural defect, otherwise a faithful content phase.
The 68 one-liners are, with the minor exceptions below, accurate compressions of the
rules they sit beside: I read every marker against its surrounding source text (not only
the diff hunks) and found no inversion, no dropped MUST/never, and no marker placed away
from its rule. The five committed digests regenerate byte-identically (`digests: OK`),
each opens with the exact non-authoritative header (FR-009), every bullet carries its
backticked source path, and the largest pack (delivery, 21 bullets) is well under the
40-line bound. The one real defect is structural, not semantic: the marker inserted into
the middle of `adoption/updating.md`'s report table severs the "Adoption doctor" row from
the table, so a shipped governance document now renders broken (F1). The fix is a
one-line move that leaves the digest bytes unchanged. Residual risk after that fix sits
in two mildly overstated one-liners in the branching pack (F2, F3) — both err in the
strict direction, which misleads toward extra ceremony, never toward rule-breaking.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-001: marker text (not paraphrase of nothing) sits beside each rule; all 68 verified adjacent to the rule they summarize. FR-003: all five digest headers carry the generated notice, regeneration command, non-authoritative statement, and full-read rule verbatim per data-model; every bullet ends with its `(`source path`)`. FR-008: kit dogfood delivered — markers in all ten pack documents, five digests committed. FR-009: no digest presents itself as a rung; headers state "the source documents prevail (constitution II is unchanged)". SC-001: bullet counts adoption 9 / branching 20 / critical 8 / delivery 21 / review 10 = 68 (matches the check's count); all ≤ 40 content lines. |
| Visual-reference match | N/A — no UI, no `specs/010-law-digests/screenshots/`. |
| Feature contract held (no unapproved table/migration/permission/package) | Diff adds only marker lines, blank lines, five digest files, and the tasks.md validation record. No script, manifest, kit-manifest, or constitution change (0.6.0 untouched). Mechanical sweep confirmed zero non-marker additions and zero removals across the ten documents — the phase added markers and changed no law. |
| Constitution / domain invariants | II: digests carry the source-prevails header; no ladder change. X: one phase, one commit, `phase 2` token present. Faithfulness spot-checks (two+ per pack) beyond the tasks.md L1 record: Critical 5's "24h cooling-off" confirmed against the source's "minimum 24-hour cooling-off period"; batched-gates one-liners confirmed against the "what changes and what doesn't" list (per-phase commits/scope checks/AI reviews stay); claim-feature.ps1 one-liner confirmed against Number Allocation; Gate 1/2 Micro arms confirmed against DoD items 1–2; adoption "runs from a kit clone" confirmed against "From a clone of the kit (not from your project)". |
| Security (authn/authz, secrets, sensitive logging) | N/A — markdown comments and generated markdown only; no code, no secrets, no execution paths touched. |
| Scope guard | `scope-check: PASS phase 2 commit 040dbd2 (16 file(s))`. Changed files = the ten Territory documents + 5 files under `docs/digests/**` + `specs/010-law-digests/tasks.md` (spec-dir exempt). `git show --stat` read for intent — nothing unrelated. |
| Rollback safety | Purely additive comment lines + new files; reverting `040dbd2` removes markers and digests together, returning the `digests` member to its phase-1 `n/a` state. No data, no schema. |
| Digest freshness (this phase's own check) | `pwsh -File scripts/build-digests.ps1 -Check -Root D:\solutions\agentic-sdlc-kit` → `digests: OK (5 digest(s) fresh, 68 marker(s))`, exit 0; full `ritual-checks.ps1` → `RESULT OK`. The tasks.md Phase 2 validation record (L1–L4 incl. the live drift tripwire) is consistent with what I observed independently. |
| Coverage / misleading-by-omission | Judged against the packs' purpose (orientation, ≤40 lines, deliberately not exhaustive): every rule the tasks (T005–T007) name is marked; I found no major-weight binding rule left unmarked while a lesser one was marked. Unmarked items I checked and accept as below the orientation bar: stale-claim reclamation (team-workflow), conflict resolution via `-Force` (updating.md §1), the visual-loop capture mechanics (review-process step 1), branch-protection recommendation (gate-command CI wiring step 5). |

## Findings

### F1 — Marker inserted mid-table breaks `adoption/updating.md`'s report table — blocking

`adoption/updating.md` lines 30–33: the marker
`<!-- digest: generated-class paths (docs/digests/*-digest.md) never flow down — … -->`
was inserted, with a preceding blank line, between the `| (never listed) |` row and the
`| Adoption doctor |` row of the "Reading the report" table. In GFM/CommonMark a blank
line terminates the table, so the "Adoption doctor" row — governance content about the
doctor's exit-2 verdict and the get-green-before-committing rule — is severed from the
table and renders as a raw pipe-delimited paragraph. This is exactly the structural
damage this phase must not cause: a shipped law document now renders visibly broken. The
L1–L4 checklist could not catch it (the generator only reads marker lines; doc-lint does
not render tables).
*Action: implementer — move the marker to below the table's last row (after the
"Adoption doctor" line, before "**Resolving a conflict**"). The one-liner text and its
position in the document's marker order are unchanged, so the committed
`adoption-digest.md` stays byte-identical — re-run `build-digests.ps1 -Check` to confirm
`digests: OK` still holds, and land the fix before the phase stands.*

### F2 — Rebase one-liner overstates the rule's scope — nit

`docs/sdlc/team-workflow.md` rule 6 requires the rebase "Before asking for the gate **on
the final phase** (and after any teammate's merge that touches your territory)". The
marker — `Rebase on current main before the certifying gate — the gate certifies the
phase as it will land.` — reads, under default per-phase certification where every gate
certifies, as a rebase mandate before *every* phase's gate, and drops the
teammate-merge trigger. The error direction is safe (extra rebases, never skipped ones),
and the digest header sends the agent to the full document before acting.
*Action: implementer — optionally tighten toward the source (e.g. "Rebase on current main
before the final phase's gate and after any territory-touching teammate merge…") within
the 120-char bound, and regenerate; acceptable to leave with a recorded rationale.*

### F3 — Pipelining one-liner states the territory condition stricter than the law — nit

`docs/sdlc/team-workflow.md` pipelining allows the second feature's territory to be
disjoint **or explicitly sequenced behind the awaiting feature in both features'
plan.md**; it also preconditions pipelining on the first feature being fully done with
review formally requested. The marker — `WIP limit: one active feature each; pipelining
allows at most one awaiting-review + one active, territory disjoint.` — drops the
sequencing alternative (and the formally-requested precondition), presenting a
stricter-than-law rule. Same safe error direction as F2; the hard cap and WIP limit are
faithful.
*Action: implementer — optionally reword (e.g. "…territory disjoint or explicitly
sequenced") within the bound and regenerate; acceptable to leave with a recorded
rationale.*

### F4 — Double blank lines introduced at four marker sites — nit

Cosmetic whitespace noise from the insertions: two consecutive blank lines now follow the
markers after DoD gate 6 (`docs/sdlc/definition-of-done.md`), the ci-held triplet item 3
(`docs/sdlc/gate-command.md`), Critical item 5 (`docs/sdlc/critical-delivery.md`), and
re-expression step 6 (`adoption/updating.md`). No renderer or kit check flags it
(doc-lint passed), but it is avoidable diff noise in law documents (markdownlint MD012
class).
*Action: implementer — collapse to single blank lines whenever these files are next
touched (may ride the F1 fix commit); no regeneration impact (blank lines are not
markers).*

### F5 — Two branching one-liners quietly drop a qualifier — observation

(a) `Claim with scripts/claim-feature.ps1: … the remote is the ledger.` — the source
qualifies "With more than one developer, the remote is the ledger" and offers the manual
recipe as a kept fallback; the marker states both as unconditional. (b) The same
strengthening pattern is deliberate elsewhere and harmless here: claiming via the script
is correct for solo developers too, and the fallback remains in the full document. Noted
for completeness; no distortion of obligation direction.
*Action: none — orientation-level compression within the design's intent; the full-read
rule covers the nuance.*

### F6 — PhaseSizeWarning on file count, as the plan predicted — observation

`enforcement-pack` reports `PhaseSizeWarning: commit 040dbd2 changes 274 line(s) across
16 file(s)` (guideline: 15 files). plan.md's Phase-sizing note declared exactly this
outcome in advance ("expect a non-blocking PhaseSizeWarning on file count at most") and
the slice is genuinely atomic — markers and their generated digests must land together or
the freshness check fails the branch.
*Action: none — pre-declared, non-blocking, coherent slice.*

## Constitution re-check (post-implementation)

PASS with F1 outstanding. **I** — content authored under the approved spec/plan/tasks.
**II** — no ladder change; every digest header states non-authoritative + source-prevails;
no shipped text presents a digest as a rung. **IV** — no new patterns; pure content.
**VIII** — the phase's deterministic validation (L1–L4) is recorded in tasks.md and I
reproduced its load-bearing verdicts live (freshness OK, 68 markers, scope PASS,
ritual-checks RESULT OK). **IX** — pending at merge, as designed. **X** — one phase, one
commit, `phase 2` token, ci-held + batch declared in the approved plan before phase 1;
the F1 fix must land as a further commit on the branch before the batch-end evidence is
reported.

## Test coverage observed

No test framework (kit convention). Phase-appropriate validation: the L1–L4 checklist in
tasks.md with quoted verdicts — L1 quote pairs (two per pack; all eight pairs re-verified
against current sources by this review, plus independent pairs: Critical 5 cooling-off,
batched-gates invariants, Gate 1/2 Micro arms, claim-feature command), L2 header/bound/
source-path properties (re-verified on all five digests), L3 freshness + byte-stability
(reproduced: `digests: OK (5 digest(s) fresh, 68 marker(s))`), L4 live drift tripwire
(recorded verdict matches the C3 message shape contract; the armed check demonstrably
covers these exact files — regeneration OK reproduced here). The one gap in the
checklist's power is rendering (F1): no L-check renders markdown, which is how a broken
table passed a green validation record.

## Residual risk

Concentrated in F1 until fixed — a law document that renders broken invites exactly the
misreading the feature exists to prevent; the fix is one moved line with zero digest
impact. After that: the two strict-direction compressions (F2, F3) can cost ceremony but
never permit a violation, and the digest header's full-read rule bounds their blast
radius. The structural class F1 represents (markers adjacent to tables/lists) is worth a
render glance whenever future markers are authored near block constructs — consider it at
the phase 3 sweep.

---

## Dispositions (implementer — appended after the review; reviewer text above unedited)

| # | Disposition |
|---|---|
| F1 | **Fixed (blocking).** The generated-class marker moved below the "Reading the report" table — the "Adoption doctor" row is back inside the table. Marker order in the document is unchanged, so the adoption digest is byte-identical; verified by regenerate + `digests: OK`. |
| F2 | **Fixed.** Rebase one-liner now mirrors the rule's actual scope: "Rebase on main before the final phase's gate, and after any teammate's merge touching your territory." |
| F3 | **Fixed.** Pipelining one-liner now carries the alternative: "territory disjoint or sequenced." |
| F4 | **Fixed.** All four double-blank-line sites collapsed to single blanks (DoD gate 6, gate-command triplet, Critical 5, updating.md step 6). |
| F5 | **Acknowledged, no change.** The "remote is the ledger" strengthening is deliberate: claim-feature.ps1 is the standard ritual even solo (branch-strategy names it "the standard way"), and the digest is orientation, erring stricter than law in the safe direction — same reasoning the reviewer applied to F2/F3's direction test. |
| F6 | **No action.** PhaseSizeWarning is non-blocking and the plan pre-declared the content phase's size; the slice is one coherent unit (markers + their digests). |

Post-fix validation: regenerate + `digests: OK (5 digest(s) fresh, 68 marker(s))`; full
ritual-checks `RESULT OK`. The F1 defect class (markdown structural damage no machine
check renders) is carried into phase 3's W4 sweep as a manual render-spot-check item.
