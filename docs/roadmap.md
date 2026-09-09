# Roadmap — Agentic SDLC Kit

> **This file carries no implementation authority.** Agents implement only from an
> approved `specs/NNN-name/spec.md`; this roadmap only says what to spec next. A roadmap
> row is never a requirement — if an agent is asked to implement from this file, it must
> stop and ask for a spec (constitution I).

The kit is its own project: its "screens" are capability gaps and field lessons from
adoptions. The inventory below is regenerated from the field-feedback log and adoption
session findings; the roadmap is authored and never regenerated.

## Inventory *(generated — regenerate freely)*

**Generated from**: adoption flow-back session findings (2026-09-01), feature 003 AI
reviews, adoption field-lesson candidates (expense-tracker, flowboard), first kit-update
flow-down findings (2026-09-07, kit 005 → both adopted projects), framework
self-assessment — pros/cons review (2026-09-07), feature 010 phase-2 AI review, first
post-010 field use (expense-tracker session, 2026-09-09)
**Generated on**: 2026-09-09 — **by**: manual audit during the 005 flow-down + same-day
self-assessment session (2026-09-07), extended with the feature 010 review harvest and
the first post-010 field-use lessons (2026-09-09)

| Inv # | Gap / lesson | Source |
|---|---|---|
| GAP-001 | No defined mechanism for adopted projects to receive kit updates — the 0.3.0/0.4.0 flow-back was manual surgery (hand-classifying kit-owned vs project-instantiated files, hand-applied constitution amendments, citation sweeps) | 2026-09-01 flow-back session |
| GAP-002 | `scripts/enforcement-pack.ps1` not named in the constitution's template-sync list, though it encodes constitutional constants (batch cap, cooling-off hours) | 003 phase 4 AI review, finding F3 |
| GAP-003 | Adoption traps live only in session memory, not kit docs: create-next-app `.env*` gitignore swallows `.env.example`; create-next-app skips `git init` inside an existing repo tree; pre-existing database behind a reused connection string (the `Spc` incident); `--warnaserror` vs vulnerable transitive template deps; raw imported docs break doc-lint | expense-tracker 001/002, flowboard scaffolds |
| GAP-004 | Pipelining WIP conditions ("review formally requested") are socially checked; no machine check counts a developer's open `NNN-*` branches | 003 phase 3 AI review, finding F1 |
| GAP-005 | The batch-size cap (3) lives in two places — constitution X and `$Config.MaxBatchPhases` — kept in sync only by amendment discipline | 003 phase 4 AI review, finding F3 |
| GAP-006 | `scripts/init-kit.ps1` slot-fill spillover: it replaced `{{PROJECT_NAME}}` inside kit-owned verbatim docs (`adoption/greenfield.md` in flowboard), making them look locally modified and producing false conflicts on the first `update-kit.ps1` run — the initializer should fill slots only in project-instantiated (surgical) files, never in verbatim ones | 2026-09-07 flow-down, flowboard conflict triage |
| GAP-007 | Verbatim `adoption/` docs backtick-reference surgical rulebook-template files that adopters may legitimately delete (flowboard deleted them as "redundant" at instantiation) — deletion then breaks doc-lint after every update refreshes the adoption docs; kit needs a stated rule: either templates are undeletable kit files, or adoption docs must reference them in bold per the authoring convention | 2026-09-07 flow-down, both projects' doc-lint failures |
| GAP-008 | The scope check (gate 4) is eyeballed: the owner reads `git diff --stat` against intent held in their head — `tasks.md` declares no per-phase file territory, so nothing mechanical catches a drive-by refactor when the owner is busy or complacent | 2026-09-07 self-assessment |
| GAP-009 | The AI review (gate 5) is self-graded: the same agent, in the same context that wrote the code, fills the checklist — no fresh-context or second-model separation between implementer and reviewer except the periodic audits | 2026-09-07 self-assessment |
| GAP-010 | Ritual machine checks exist (`doc-lint.ps1`, `enforcement-pack.ps1`) but run by discipline, not as required CI checks on the feature branch — compliance still ultimately rests on agent obedience and owner attention | 2026-09-07 self-assessment |
| GAP-011 | No adoption doctor: nothing audits an adopted project's kit integrity (slots filled, structure law intact, gate defined and proven, rulebooks instantiated for declared tiers, `.kit-version` sane) — partial installs and post-flow-down damage are caught socially, one incident at a time (GAP-006/007 were instances of this class) | 2026-09-07 self-assessment |
| GAP-012 | Owner is the synchronous bottleneck: every Standard phase (or batch) blocks on the owner running the gate live; no CI-held certification path exists for Lite/Standard even though CI evidence is equally unforgeable | 2026-09-07 self-assessment |
| GAP-013 | No lane between Lite and Standard: a small-but-real feature (a few files, no schema/dependency/domain risk) pays the full spec/plan/tasks ritual or squeezes illegitimately into `fix/` | 2026-09-07 self-assessment |
| GAP-014 | Governance context cost: agents load large law documents per session; no generated per-pack digest exists, and a hand-written digest would drift (drift is what kills rule-based frameworks — README) | 2026-09-07 self-assessment |
| GAP-015 | No check sees a document's *rendered* structure: nothing in the kit renders markdown, so an inline HTML comment (e.g. a `digest:` marker) or a stray blank line placed inside a GFM block — between a table's rows, inside a list continuation — silently severs that block while doc-lint, the digest check and the whole ritual-checks chain stay green. The law still says the right thing and displays the wrong thing; only a human or fresh-context reviewer reading the diff catches it | 010 phase 2 AI review, finding F1 |
| GAP-016 | The machine scope check (gate 4) cannot reach nested code repos: in the nested-repo layout the code repositories carry no kit scripts, and `docs/sdlc/repository-strategy.md` is silent on it — so `scripts/scope-check.ps1` only ever governs the governance repo, while every phase commit that contains code lives in a repo the check cannot see. Territory declarations for code phases are reviewer-verified prose, not machine-verified. Candidate fix shapes: ship a thin scripts/ set into code repos at adoption, or a governance-side check that reads the code repos as sibling working trees | 2026-09-09 first post-010 field use (expense-tracker) |
| GAP-017 | A paused feature branch makes main's roadmap lie, and nothing checks it: an adopted project's feature 003 sat 13 days with an approved spec and a delivered, gated, AI-reviewed phase 1 on an unmerged branch while main's roadmap row still read idea with no spec link — any agent orienting from main would have concluded the feature was unstarted and re-specced it. The status flip lives on the branch, invisible until merge | 2026-09-09 first post-010 field use (expense-tracker) |

## Roadmap *(authored — humans only, never regenerated)*

Status flow: `idea → specified → in progress → shipped → dropped`

| Feature | Covers (Inv #) | Priority | Status | Owner | Spec |
|---|---|---|---|---|---|
| Delivery-core amendment | — | P1 | shipped | anas.m | `specs/001-delivery-core-amendment/` |
| Enforcement pack | — | P1 | shipped | anas.m | `specs/002-enforcement-pack/` |
| Flow-efficiency pack | — | P1 | shipped | anas.m | `specs/003-flow-efficiency-pack/` |
| Kit-update channel (manifest of kit-owned vs slot-bearing files; update script that copies the verbatim set and reports the surgical set; amendment flow-down guidance) | GAP-001 | P1 | shipped | anas.m | `specs/004-kit-update-channel/` |
| Field-lesson harvest (encode the adoption traps into `adoption/` steps and rulebook templates) | GAP-003 | P2 | shipped | anas.m | `specs/005-field-lesson-harvest/` |
| Pipelining WIP machine check (enforcement-pack counts a developer's open `NNN-*` branches) | GAP-004 | P3 | idea | — | — |
| Verification pack (per-phase file territory declared in `tasks.md` + machine scope check; fresh-context/second-model AI review separation; ritual checks wired as required CI on feature branches) | GAP-008, GAP-009, GAP-010 | P1 | shipped | anas.m | `specs/006-verification-pack/` |
| Adoption doctor (`verify-kit.ps1`: audits slots, structure, gate proof, tier rulebooks, `.kit-version`; runs post-init, post-update, and in adopted-project CI) | GAP-011 | P2 | shipped | anas.m | `specs/007-adoption-doctor/` |
| CI-held certifying gate for Lite/Standard (gate evidence = unforgeable CI run on the branch; owner approves on evidence asynchronously; user-run gate stays law for Critical) | GAP-012 | P2 | shipped | anas.m | `specs/008-ci-held-gate/` |
| Micro lane (single-page mini-spec, one phase, declared eligibility enforced by the scope check; outgrowing the lane promotes it in place to Standard) | GAP-013 | P3 | shipped | anas.m | `specs/009-micro-lane/` |
| Law digests (generated per-pack summaries kept in sync by CI; full doc read only when acting on that area) | GAP-014 | P3 | shipped | anas.m | `specs/010-law-digests/` |
| Roadmap-claim visibility check (ritual-checks asserts every specs/NNN-* reachable on a remote branch has a non-idea row on main — or status flips move to a main-side docs commit at claim time) | GAP-017 | P1 | idea | — | — |
| Code-repo scope-check reach (thin scripts/ shipped into code repos at adoption, or governance-side check reads sibling working trees; decide shape before adopting a multi-repo project) | GAP-016 | P2 | idea | — | — |
| Rendered-structure lint (block-structure check in doc-lint: tables and list blocks uninterrupted; table rows have uniform cell counts, escaped pipes not counted — not a markdown renderer) | GAP-015 | P2 | idea | — | — |

## Decisions log *(authored)*

- 2026-09-01 GAP-002 fixed directly on the `docs/kit-roadmap-and-sync-list` branch
  (constitution 0.4.1 PATCH — sync-list addition, no rule change), not promoted to a
  feature: one line of governance bookkeeping.
- 2026-09-01 GAP-005 accepted as-is: the constitution's sync list (after the GAP-002 fix)
  now names the enforcement pack, which is the mechanism that keeps the two locations
  aligned on future amendments. No further work planned.
- 2026-09-01 GAP-004 deliberately deferred until field use shows actual pipelining abuse
  (003 phase 3 review, F1) — encoding enforcement for a problem not yet observed is
  ceremony.
- 2026-09-07 A third flow-down finding — doc-lint's manifest completeness sweep failing in
  adopted projects on project-authored `docs/` files — was fixed directly the same day
  (PR #11, `fix/doc-lint-adopted-projects`: sweep skipped when `.kit-version` exists), per
  the GAP-002 direct-fix precedent; no open inventory row needed.
- 2026-09-07 Self-assessment gaps sequenced by dependency: verification pack first (GAP-008/009/010
  — machine checks make everything downstream safe), then adoption doctor (GAP-011) and CI-held
  gates (GAP-012, which relies on the verification pack's checks existing), then micro lane
  (GAP-013) and law digests (GAP-014). Deliberately NOT planned: removing human review or the
  Critical lane's synchronous user-run gate — those are the framework's identity.
- 2026-09-09 **The 2026-09-07 self-assessment roadmap is closed**: GAP-014 (law digests)
  shipped via PR #23, the last of the seven gaps that assessment opened. The digest
  machinery answers the gap's own objection — "a hand-written digest would drift" — by
  never letting a human write the digest: curated one-liners live beside the rules,
  `scripts/build-digests.ps1` assembles them, and `ritual-checks`' `digests` member fails
  the branch on any divergence. Digests are orientation only, never a source-of-truth
  rung; no constitutional amendment was needed (0.6.0 stands). Remaining open inventory
  row: GAP-004 (pipelining WIP check), still deliberately deferred — see the 2026-09-01
  entry.
- 2026-09-07 GAP-006 and GAP-007 fixed directly on `fix/flow-down-gaps` (GAP-002 precedent).
  GAP-006: init-kit's slot fill now resolves targets through `kit-manifest.json` and never
  touches verbatim files. GAP-007 resolved as the **bold-reference rule**, not undeletable
  templates: the tier templates/menu stay deletable (the tier-menu philosophy — an adopted
  project sees only what it picked); verbatim kit docs reference them in bold, and the
  authoring convention in `scripts/doc-lint.ps1`'s header states the rule.
- 2026-09-09 GAP-015 recorded in the inventory only — **no roadmap row, no feature
  planned**. It has been observed exactly once (010 phase 2, caught by the fresh-context
  reviewer before merge, cost one fix commit), and the 2026-09-01 GAP-004 precedent
  applies: encode enforcement after the field shows the problem recurs, not after its
  first sighting. Promote it if it appears a second time, or if a rendering break ever
  reaches `main`. Interim mitigation is the existing ritual, which already worked: review
  gates 5 and 6 read the diff, and the phase-3 W4 sweep re-read every marked document's
  rendered structure by eye. A future implementation would most likely be a
  block-structure lint in `doc-lint.ps1` (assert tables and list blocks are
  uninterrupted), not a full markdown renderer.
- 2026-09-09 **GAP-015's promotion trigger was met the same day it was recorded.** The
  entry above says "promote it if it appears a second time"; sighting #2 arrived hours
  later in an adopted project's phase-1 review record — two inline-code spans holding
  unescaped pipe characters turned a 2-column evidence row into 9 cells, scrambling the
  domain-invariants evidence a human reviewer had to read. Same mechanism, both sightings
  caught only by hand while every machine check stayed green. Roadmap row added
  (rendered-structure lint, P2); the implementation sketch in the entry above stands.
- 2026-09-09 First post-010 field use recorded GAP-016 and GAP-017 (this docs commit —
  record before fixing, per the GAP-002/GAP-015 precedent). Sequenced as the pre-test bar
  for the first multi-developer adoption: GAP-017's check is P1 because a stale roadmap
  actively misleads any teammate orienting from main (the only recorded edge that
  produces wrong decisions rather than missing enforcement); GAP-016 is P2 because it
  bites only nested-repo projects — its fix shape must be decided before adopting one,
  but a single-repo adoption is unaffected. GAP-004 stays deferred: a multi-developer
  test is exactly the field that will show whether pipelining abuse is real.
