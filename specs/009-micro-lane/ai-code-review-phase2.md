# AI Code Review — 009 Micro Delivery Lane (Phase 2: machine checks)

**Reviewer**: fresh-context subagent session (claude-fable-5), spawned solely for this review
**Date**: 2026-09-09
**Branches**: agentic-sdlc-kit `009-micro-lane` (tip `46697d7`)
**Scope reviewed**: full post-change text of `scripts/scope-check.ps1` and
`scripts/enforcement-pack.ps1` at 46697d7; the phase-2 diff (`git show 46697d7`);
`specs/009-micro-lane/` spec.md (FR-004–FR-007), plan.md, tasks.md (phase 2 section,
Territory, recorded validation table + design note), research.md D3–D5, data-model.md,
contracts/micro-lane-checks.md; `.specify/templates/micro-spec-template.md`;
constitution 0.6.0 Micro-lane clause and sync list; `specs/002-enforcement-pack/spec.md`
header (regression surface). Both scripts were re-run live on the real repo and against
seeded fixtures in a scratch clone outside the repo (deleted after).
**Feature contract**: phase 2 touches only `scripts/scope-check.ps1` and
`scripts/enforcement-pack.ps1` (tasks.md Phase 2 Territory) plus the feature's own spec
dir; no new packages, no architecture change, no change to Lite branches, claims,
numbering, provenance checks, or the adoption doctor (contract non-goals).

## Reviewer Provenance

- **Reviewer**: fresh-context subagent session (claude-fable-5), spawned solely for this review
- **Implementer**: Claude Fable 5 session on branch 009-micro-lane (commit 46697d7,
  Co-Authored-By trailer) — a different session; this reviewer holds no context from it
- **Inputs provided**: phase 2 diff (46697d7), full post-change scripts,
  specs/009-micro-lane/{spec.md, plan.md, tasks.md, research.md, data-model.md,
  contracts/micro-lane-checks.md}, .specify/templates/micro-spec-template.md,
  .specify/memory/constitution.md, specs/_templates/ai-code-review-template.md,
  live runs of both scripts on the repo and on scratch-clone fixtures
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups** — the phase delivers exactly the contracted machine half:
scope-check gains Micro detection (parent-read, comment-stripped spec.md Delivery Level),
a feature-global spec.md Territory source with unchanged semantics, and a spec.md deletion
guard; enforcement-pack gains the MicroLane check (one phase, no plan/tasks, ≤5 literal
territory entries, hard 400-line commit bound, no Gate Batching line), a Micro-aware
Structure check, a shared comment-stripped `Get-DeliveryLevel`, and GateCertification
reading spec.md on Micro. Every contract row M1–M13 was independently re-validated by this
reviewer against live fixtures in a scratch clone — all verdicts and message texts match
the recorded validation table — and every bypass probed fails closed across the composed
`ritual-checks` verdict. The residual risk sits in two places: the 400-line bound is
per-commit and therefore splittable across same-number remediation commits (F1 — the one
finding that needs an owner decision), and a handful of Micro FAIL messages fall short of
the error-message contract's remediation requirement (F4). Nothing blocks.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-004: scope-check.ps1:229–271 — Micro branch reads the feature-global Territory from the PARENT's spec.md, identical verdict semantics (implicit spec-dir entry line 259, -like matching, PASS/FAIL wording); reproduced M2/M3/M4 live. FR-005: enforcement-pack.ps1:313–383 `Invoke-MicroLaneCheck` — reproduced M5–M8, M10, M12 live with the exact recorded messages. FR-006: enforcement-pack.ps1:277–304 — declPath switches to spec.md on Micro; M9 reproduced (ci-held in mini-spec ⇒ OK). FR-007: the promotion remediation string (line 319) is verbatim the contract's procedure and appears in every MicroLane failure. |
| Visual-reference match | N/A — no UI, no `screenshots/`. |
| Feature contract held | `git show 46697d7 --stat`: exactly 3 files — the two Territory scripts + specs/009-micro-lane/tasks.md (implicit spec-dir). No new packages/architecture. Non-goals respected: LiteAndAbuse, ReviewProvenance, CriticalEvidence timing, claim scripts, verify-kit.ps1 untouched in the diff; Lite fixture (`fix/` lane) dispatch unchanged (scope-check.ps1:337, enforcement-pack.ps1:477). |
| Constitution / domain invariants | Constants match constitution 0.6.0 exactly: cap 5 / 400 lines / 1 phase (constitution.md:295–297, sync list :131–132 names them; $Config comment says sync-listed — verified true). Machine half lands next-phase-same-branch per phase-1 SYNC IMPACT. |
| Security | No secrets, no new surface; scripts remain read-only over git state; `2>$null` git fallbacks all guarded by `$LASTEXITCODE` checks (scope-check.ps1:234–242 walked line by line). |
| Scope guard | `scope-check.ps1 -All` re-run on the real branch at 46697d7: PASS phase 1 (66b3dff, 310e4ad), PASS phase 2 (46697d7, 3 files); enforcement-pack OK (only the pre-existing non-blocking bcf436e PhaseSizeWarning) — matches the recorded M1 row verbatim. Diff read for intent: all changes are the two declared checks. |
| Rollback safety | Revert of 46697d7 returns both scripts to their 008 state; the checks key off a `Micro` declaration no real feature uses yet (009 itself is Standard) — clean revert, no data. |
| Regression (001–008 shapes, Lite, this branch's CI) | Verified the riskiest switch — Structure/CriticalEvidence/GateBatching level reads moving from raw `Get-Content` to comment-stripped visible lines — against the one live spec with a multi-line comment opening ON the Delivery Level line (specs/002-enforcement-pack/spec.md:6–9): the (?s) lazy strip joins the line to `**Delivery Level**: Standard ` — parses identically. All other specs (001, 003–009) declare plainly on line 6. Real-repo runs above show zero verdict change. |
| Recorded validation table (tasks.md, M1–M13) | Spot-checked by re-execution, not trust: every quoted message text reproduced character-for-character where re-run (M2 PASS format incl. "Micro territory from spec.md", M3/M4 FAIL + remediation, M5/M6/M7/M8/M10/M12 failure texts, M9 OK, M13 decoy OK, Lite not-applicable text, M11 promotion flow). The table is credible. |

## Findings

### F1 — The 400-line hard bound is per-commit and splittable across same-number remediation commits — CONFIRM

Severity: MAJOR (as an intent gap), contract-conformant as written.
`enforcement-pack.ps1:361–378` bounds each commit carrying a `phase N` token separately.
Demonstrated live: `phase 1` (300 lines) + `phase 1 fixes: part two` (300 lines) on a Micro
fixture ⇒ `enforcement-pack: OK` — 600 lines of phase-1 work, no failure and (each commit
< 400) not even a PhaseSizeWarning. The contract row M12 says "single phase commit over
400" and the constitution (X, Micro lane) says "the single phase commit changes at most
400 lines", so the code implements the letter; but the lane's law also says the feature IS
one phase, and remediation commits (deliberately kept legal — the design note and the M6
message both celebrate this, correctly, for 006-parity) make the per-PHASE total
machine-unbounded. The 5-file territory cap and human review are the remaining backstops.
*Action: owner decision — either accept per-commit as the ratified meaning (record it in
the phase-3 docs as "per commit, not per phase"), or additionally bound the summed lines
across same-number commits in a follow-up.*

### F2 — Token-less commits are invisible to both the scope check and the MicroLane counters — MINOR

Severity: MINOR (inherited, parity with Standard). A commit whose subject carries no
`phase N` token is "not applicable" in scope-check (scope-check.ps1:224–227) and skipped
by MicroLane's phase/line counters (enforcement-pack.ps1:363). This is the 006 design
(claim/specify/review commits are legal) and is identical on Standard branches — no NEW
hole — but on a lane whose promise is hard boundedness, an agent can land arbitrary code
in a "tune X" commit that no machine check attributes. Verified live: a token-less commit
touching territory files passes silently. Human review of the full branch diff remains the
control, as it always was.
*Action: none (inherited design, parity held) — worth one sentence in the phase-3
review-process sweep so reviewers know token-less commits on Micro deserve the same
suspicion as on Standard.*

### F3 — spec.md RENAME evades scope-check's deletion guard; Structure catches it downstream — MINOR

Severity: MINOR (fail-closed via composition). The guard (scope-check.ps1:206–215) matches
only `^D\t` rows; `git mv specs/NNN/spec.md specs/NNN/spec-old.md` in a `phase 1 fixes`
commit reports `R100`, and scope-check PASSes the commit (both paths inside the implicit
spec-dir entry) — demonstrated live. The branch still goes red: enforcement-pack's
Structure check fails the tree (spec.md missing ⇒ level '' ⇒ all three files required), and
any LATER phase commit fails scope-check (parent lacks spec.md ⇒ not Micro ⇒ tasks.md
missing while the directory exists ⇒ FAIL). So the composed `ritual-checks` verdict holds,
but scope-check's own message ("must never be deleted") promises more than its D-only
match delivers, and a rename-based dodge produces a confusing failure far from the cause.
*Action: follow-up — extend the guard to rename SOURCES (`^R` rows whose old path is a
declaration file), mirroring ReviewProvenance's AR-filter precedent.*

### F4 — Several Micro FAIL paths omit the promotion remediation the error-message contract requires — MINOR

Severity: MINOR. The contract: "Every Micro FAIL names: the violated bound (with its
configured value), and the remediation — promote … or shrink." All MicroLane failures and
scope-check's stray-file failure comply (verified verbatim). Non-compliant Micro FAILs in
scope-check: duplicate **Territory** marker (line 246), invalid entry (line 251),
no-usable-Territory (line 256), and the declaration-file deletion FAIL (line 211) — none
names promotion; the first three name no configured value either (defensible — they are
malformed-declaration failures, not bound violations, and each says what to fix). Verified
live: all four fire correctly and fail closed.
*Action: follow-up — append the shared promotion sentence to the three Micro-specific
scope-check FAILs, or record in phase 3 that the error-message contract binds bound
violations only.*

### F5 — "at most 5 entries" hardcoded in scope-check's remediation text — MINOR

Severity: NIT. scope-check.ps1:269 embeds the literal `5` while the constant lives in
enforcement-pack `$Config.MicroTerritoryMaxFiles` and the constitution's sync list. A
future lockstep amendment of the cap must remember this string or the remediation will
lie. scope-check has no $Config; a comment tagging the literal as sync-listed would do.
*Action: follow-up — tag or centralize the literal; no behavior change.*

### F6 — `^Micro\b` accepts trailing junk in the Delivery Level value — MINOR

Severity: MINOR. Verified live: `**Delivery Level**: Micro-ish maybe` is simultaneously
legal (Structure's `^(Lite|Micro|Standard|Critical)\b`, enforcement-pack.ps1:173) and
Micro (Test-IsMicro / `^Micro\b` everywhere) — `\b` sits at the `o`/`-` boundary. There is
NO split-brain: all four readers (Test-IsMicro, Structure, MicroLane, GateCertification)
use the same anchor and agree, so behavior is coherent; and the lenience is inherited from
the pre-009 `(Lite|Standard|Critical)\b` pattern. But a sloppy value like `Micro
(proposed)` now silently selects the lane. Anchoring the post-strip value as
`^(Lite|Micro|Standard|Critical)$` in Structure would fail-close the sloppiness without
touching detection.
*Action: follow-up — tighten Structure's value anchor; keep detection anchors as-is.*

### F7 — Duplicate Territory markers: enforcement-pack concatenates, scope-check fails — MINOR

Severity: NIT. enforcement-pack's inline parser (lines 336–344) restarts collection at a
second `**Territory**:` marker and ACCUMULATES entries (two 3-entry blocks read as 6 ⇒ cap
FAIL — conservative), with no explicit duplicate failure; scope-check FAILs duplicates
outright (verified live: the phase commit after a duplicate-block commit FAILs with the
"more than one **Territory** marker" message). Both directions are red at the phase
commit, so no bypass — just two parsers with different opinions about the same malformed
file, which costs a future maintainer a puzzled minute.
*Action: none — divergence is fail-closed both ways; noted for awareness.*

### Checked and clean (explicit)

- **M1 regression**: both scripts re-run on the real repo at 46697d7 — verdicts and texts
  identical to pre-phase behavior for 009's own commits; 002's multi-line-comment header
  shape parses identically under the visible-lines switch (the riskiest regression surface,
  read and reasoned through, above).
- **M2 / template conformance**: a mini-spec authored from the REAL
  `.specify/templates/micro-spec-template.md` (marker, blank line, comment above the
  block, backtick entries) parses correctly in both scripts — PASS with "Micro territory
  from spec.md".
- **M13 decoys, both directions**: a closed-comment `Standard` decoy above the real
  `Micro` ⇒ still Micro (OK); an UNCLOSED comment decoy ⇒ the lazy `(?s)<!--.*?-->` strip
  swallows text up to the template's next `-->`, killing the header entirely ⇒ 3 Structure
  failures — fail-closed. A decoy AFTER the real line loses first-match by design.
- **Case variations**: `MICRO` detected as Micro consistently in both scripts
  (case-insensitive `-match`, per data-model).
- **`phase 10` subject**: counted as a distinct phase number ⇒ MicroLane FAIL "phases 1,
  10"; scope-check passes the commit individually (by design — enforcement holds the
  one-phase rule; ritual-checks composes to red).
- **Same-commit spec.md widening (M4)**: parent-read holds — FAIL on the newly-declared
  file, demonstrated live.
- **`Gate Batching: none` in a mini-spec**: FAILs — stricter than contract row M8's
  example but exactly what data-model specifies ("Micro + line ⇒ FAIL"); message says
  "delete the line".
- **M9 / GateCertification**: ci-held read from the mini-spec on Micro ⇒ OK; the
  early-return restructure preserves the plan.md path for Standard/Critical byte-for-byte;
  Critical + ci-held still fails via the level check.
- **M11 / promotion**: level re-declared Standard + plan/tasks added ⇒ MicroLane exits,
  Standard rules apply, the Micro-era phase 1 commit stays attributed against the old
  spec.md territory (parent-read), and a STALE Territory block left in the promoted
  spec.md is inert — all demonstrated live.
- **One-shot claim+phase commit**: the parent-lacks-directory fallback self-declares
  territory from the commit's own spec.md — identical to the pre-existing tasks.md
  claim-commit rule (006), parity held, and MicroLane's caps + line bound still apply to
  that commit.
- **Empty/null pitfalls**: `@($null)` through Test-IsMicro returns false; `$LASTEXITCODE`
  is re-checked after every git fallback in the spec-blob ladder (scope-check.ps1:234–242);
  root-commit `^` references degrade to the fallback exactly as the tasks.md path does;
  binary-file `-` numstat columns are skipped (PhaseSizeWarning parity).
- **Glob/whitespace territory probes**: `src/**` and `docs/` entries FAIL naming the cap
  rationale; escaped `[`/`]`/`?` stay literal in Test-InTerritory, so a ≤5-entry list
  cannot match more than 5 files; entries with trailing comment residue end collection
  (fail-closed, fewer usable entries).
- **Non-goals**: the diff touches nothing in LiteAndAbuse, ReviewProvenance,
  CriticalEvidence timing, claims, numbering, or the adoption doctor; the fix/-lane
  dispatch is unchanged. The CriticalEvidence/GateBatching switch to comment-stripped
  reads means a COMMENTED-OUT Critical no longer triggers Critical protections — a
  deliberate, symmetric application of the 008-F1 visible-text rule (a spec that visibly
  downgrades its level is an owner-reviewed change); noted, accepted.

## Constitution re-check (post-implementation)

**PASS.** I (Micro arm) — the machine now enforces exactly what the amended principle
grants, nothing wider. II — constants in $Config match the constitution's sync-listed
values (5/400/1) and the $Config comment binds them to lockstep amendment. IV — the check
reuses the established idioms (comment-stripped first-match parser, parent-read
anti-widening, $Config constants); MicroLane joins the existing function set; no new
patterns. V/VI/VII — N/A (no domain surface, no secrets, no integrations). VIII — the
business-critical checks carry seeded deterministic validation (M1–M13, recorded), and
this review re-executed it independently. X — phase 2 is one coherent slice (309 changed
lines, under the guideline), independently revertible; the plan's declared batching
(phases 1–3) and ci-held certification are lawful for this Standard feature; certification
remains pending at batch end — nothing here claims success. IX — this review is the
fresh-context layer; human review follows at merge.

## Test coverage observed

No test framework (kit convention). Coverage is the seeded M-contract validation recorded
in tasks.md (M1–M13 + Lite regression, fixture branches 989–998 in a scratch clone,
deleted after) — every row carries a quoted verdict. This review independently re-created
the fixtures in its own scratch clone (outside the repo, deleted after) and re-executed:
M2, M3, M4, M5, M6 (incl. `phase 10`), M7, M8 (+ `none` variant), M9, M10, M12, M13
(closed + unclosed decoys), M11 (full promotion flow), the Micro no-Territory FAIL, the
duplicate-marker FAIL, the spec.md delete guard, the spec.md rename probe, the `MICRO`
case probe, the `Micro-ish` value probe, the one-shot claim probe, and the 300+300 split
probe — plus M1 on the real repository. Every recorded quote that was re-run reproduced
exactly. The critical assertions are the anti-widening parent-read (M4) and the fail-closed
behavior of every malformed-declaration state — both hold.

## Residual risk

Concentrated in F1: the 400-line bound binds commits, not phases, so a Micro phase's true
size is bounded only by the 5-file cap and human review once remediation commits enter —
the owner should ratify or close that reading before the lane sees real use (it can ride
the phase-3 doc sweep either way). Secondary: F3's rename dodge produces its failure in
the wrong check (confusing, not unsafe), and F2 is the standing token-less-commit
blindness every lane already carries. Everything else found is message polish. Merge risk
after the batch-end gate: low.

---

## Disposition (implementing session, 2026-09-09)

| # | Severity | Disposition |
|---|---|---|
| F1 | CONFIRM (MAJOR intent gap) | **Held for owner decision** — the approved spec/data-model/contract all define the 400-line bound per phase COMMIT, which remediation commits can split. Options at batch end: (a) ratify the per-commit meaning as-is, or (b) bound the phase's SUM across all its `phase N` commits (recommended; needs a one-line law wording tweak plus the enforcement change). Requested in the phase report with phase-1 F3. |
| F2 | MINOR | **Accepted** — token-less commits are invisible by inherited 006 design, exact parity with Standard; the composed tree-state checks (Structure/MicroLane) still bind the branch. |
| F3 | MINOR | **Fixed** — the declaration-file guard now also FAILs a rename away (`R` rows' source), not just deletion. |
| F4 | MINOR | **Fixed** — scope-check's Micro FAIL paths (duplicate marker, invalid entry, no-usable-Territory) now name the promotion remediation; the deletion/rename guard stays lane-agnostic by design (it fires before lane detection, protecting Standard too). |
| F5 | MINOR/NIT | **Fixed** — scope-check's remediation no longer hardcodes "5"; it defers to the cap enforcement-pack's $Config owns. |
| F6 | MINOR | **Accepted** — `^Micro\b` trailing-junk lenience is consistent across all four readers (no split-brain) and matches the pre-009 `\b` idiom; tightening to `$` could break adopted projects' existing spec headers through verbatim script flow-down. Documented here for a future amendment. |
| F7 | MINOR/NIT | **Fixed** — enforcement-pack now FAILs duplicate **Territory** markers instead of concatenating them, aligned with scope-check. |
