# Research: Micro Delivery Lane

Decisions made at specify time. Each records the choice, the why, and the rejected
alternatives.

## D1 — A fourth level, spec.md-only, same filename

**Decision**: Micro is a delivery level (Lite < Micro < Standard < Critical), declared as
`**Delivery Level**: Micro` in the feature's `spec.md`, which is a single-page mini-spec
from a new template. No plan.md, no tasks.md. The filename stays `spec.md`.

**Why**: the Feature Structure law ("exactly these names") survives unchanged — Micro is a
smaller spec.md, not a new layout. Every tool that keys off `specs/NNN-name/spec.md`
(claim script, doc references, reviewers' habits) keeps working.

**Rejected**: a `micro.md` filename (breaks the structure law for zero gain); a
`micro/NNN-name` branch prefix (breaks the NNN-* machinery — claims, scope-check dispatch,
branch protection).

## D2 — The amendment set (constitution 0.5.0 → 0.6.0, MINOR)

**Decision**: principles I and X gain the Micro arm in one atomic phase-1 commit together
with every mirror that states levels or assumes plan.md/tasks.md existence for numbered
features: spec-template's level comment, the new micro-spec template, DoD (gate 1
specification arm; gate 4 territory source), branch-strategy (level menu),
critical-delivery (exclusions restated: no Micro for Critical work), gate-command +
constitution X's CI-held clause (eligibility widens to "Lite, Micro, or Standard"),
CLAUDE.md. SYNC IMPACT names the machine half as landing next phase, same branch (008
precedent).

**Why**: the constitution's own sync rule; splitting law from mirrors across commits is
the defect class phase reviews keep catching.

**Rejected**: amending only X (principle I's "spec → plan → tasks" would contradict the
lane on its face).

## D3 — Machine detection and territory source

**Decision**: a branch is Micro when its `spec.md` (comment-stripped via the shared
`Get-VisiblePlanLines` idiom) carries `**Delivery Level**: Micro`. On Micro branches,
`scope-check.ps1` reads the **Territory** block from `spec.md` at the phase commit's
parent — same marker format, same anti-widening rule as tasks.md. `enforcement-pack.ps1`
gains a MicroLane check: exactly one `phase N` commit; no plan.md/tasks.md in the tree;
declared Territory within the cap; no `**Gate Batching**` line in spec.md; malformed level
values fail naming the legal set. The GateCertification check reads the declaration from
spec.md on Micro branches (plan.md remains the source otherwise).

**Why**: reuses every hardened parser and rule from 006/008 (comment stripping, first-match,
parent-read anti-widening) instead of inventing a second grammar.

**Rejected**: Territory in a separate file (more structure, no gain); trusting the
checklist without machine bounds (an honor-system lane below Standard becomes the
loophole).

## D4 — The constants (owner ratifies at spec approval)

**Decision**: Territory cap **5 files** (excluding `specs/NNN-name/**`, which is always
implicitly in territory); the existing 400-line phase-size guideline becomes a **hard
FAIL** for Micro (it stays a warning elsewhere). Both live in the enforcement pack's
$Config, named in the constitution as constants that change in lockstep (the batch-cap
precedent).

**Why**: 5 files ≈ the "few files" the gap names; a lane defined by smallness needs hard
edges or it isn't a lane. Adjustable at approval — the spec marks both as proposed.

**Rejected**: no line bound (territory alone doesn't stop a 2-file rewrite); counting
spec-directory files against the cap (penalizes the traceability the lane exists to buy).

## D5 — Promotion (outgrowing) is in-place and forward-only

**Decision**: outgrowing = promote on the same branch/number: spec.md expands to the full
template (level Standard), plan.md + tasks.md added (Territory moves to tasks.md), in a
promotion commit that precedes any further phase commit. Machine remediation messages name
this procedure. History is never rewritten; Micro-era commits stay attributed.

**Why**: the claim (number + branch) is the team-visible unit — re-claiming under a new
number would orphan the ledger entry and the pushed branch. Parent-read scope-check makes
the ordering self-enforcing.

**Rejected**: literal re-claim under a new number (ledger churn, lost history); demotion
Standard → Micro (no use case; one-way ratchet is simpler law).

## D6 — This feature's own delivery: 3 phases, batched

**Decision**: phase 1 = the law (amendment + mirrors + micro-spec template); phase 2 = the
machine half (scope-check + enforcement-pack + seeded fixtures); phase 3 = the governance
sweep (flow.md, review-process, PR/human-review templates, updating.md flow-down note,
roadmap flip). `**Gate Batching**: phases 1-3`.

**Why**: same safety ordering as 006/008 — police the law before summarizing it; each
phase reverts cleanly (law wholesale; checks key off markers nothing yet uses; sweep is
bookkeeping).

## D7 — Dogfooding: this feature certifies ci-held

**Decision**: `**Gate Certification**: ci-held` — the first real use of 008's clause. The
kit's project gate IS `ritual-checks`, so the evidence triplet is the push-event
ritual-checks run URL + green conclusion + the batch-end commit sha, and the owner records
approval on it (gate-command.md's worked example shape).

**Why**: 008's SC-001 promised an end-to-end demonstration "on a real phase of a kit
feature (009+)"; the law is ratified (PR #18 merged = human adoption), the enforcement
pack validates the declaration, and this plan is Standard — every precondition holds.
The agent's obligations are unchanged: report the triplet, request approval, never claim
success.

**Rejected**: user-run (lawful always, but it would leave 008's SC-001 undemonstrated for
no reason).

## D8 — What Micro does NOT change

Lite keeps its lane (non-behavior change, no spec dir). The adoption doctor is untouched
(it audits kit integrity, not levels). Claims, numbering, branch protection, AI-review
provenance, human review at merge: all unchanged. Adopted projects receive the amendment
by re-expression (updating.md §2, their own MINOR bump) and the template/scripts as
verbatim flow-down; nothing changes for them until ratified.
