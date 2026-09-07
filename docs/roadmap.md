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
flow-down findings (2026-09-07, kit 005 → both adopted projects)
**Generated on**: 2026-09-07 — **by**: manual audit during the 005 flow-down

| Inv # | Gap / lesson | Source |
|---|---|---|
| GAP-001 | No defined mechanism for adopted projects to receive kit updates — the 0.3.0/0.4.0 flow-back was manual surgery (hand-classifying kit-owned vs project-instantiated files, hand-applied constitution amendments, citation sweeps) | 2026-09-01 flow-back session |
| GAP-002 | `scripts/enforcement-pack.ps1` not named in the constitution's template-sync list, though it encodes constitutional constants (batch cap, cooling-off hours) | 003 phase 4 AI review, finding F3 |
| GAP-003 | Adoption traps live only in session memory, not kit docs: create-next-app `.env*` gitignore swallows `.env.example`; create-next-app skips `git init` inside an existing repo tree; pre-existing database behind a reused connection string (the `Spc` incident); `--warnaserror` vs vulnerable transitive template deps; raw imported docs break doc-lint | expense-tracker 001/002, flowboard scaffolds |
| GAP-004 | Pipelining WIP conditions ("review formally requested") are socially checked; no machine check counts a developer's open `NNN-*` branches | 003 phase 3 AI review, finding F1 |
| GAP-005 | The batch-size cap (3) lives in two places — constitution X and `$Config.MaxBatchPhases` — kept in sync only by amendment discipline | 003 phase 4 AI review, finding F3 |
| GAP-006 | `scripts/init-kit.ps1` slot-fill spillover: it replaced `{{PROJECT_NAME}}` inside kit-owned verbatim docs (`adoption/greenfield.md` in flowboard), making them look locally modified and producing false conflicts on the first `update-kit.ps1` run — the initializer should fill slots only in project-instantiated (surgical) files, never in verbatim ones | 2026-09-07 flow-down, flowboard conflict triage |
| GAP-007 | Verbatim `adoption/` docs backtick-reference surgical rulebook-template files that adopters may legitimately delete (flowboard deleted them as "redundant" at instantiation) — deletion then breaks doc-lint after every update refreshes the adoption docs; kit needs a stated rule: either templates are undeletable kit files, or adoption docs must reference them in bold per the authoring convention | 2026-09-07 flow-down, both projects' doc-lint failures |

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
| Verification pack (per-phase file territory declared in `tasks.md` + machine scope check; fresh-context/second-model AI review separation; ritual checks wired as required CI on feature branches) | GAP-008, GAP-009, GAP-010 | P1 | specified | anas.m | `specs/006-verification-pack/` |

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
- 2026-09-07 GAP-006 and GAP-007 fixed directly on `fix/flow-down-gaps` (GAP-002 precedent).
  GAP-006: init-kit's slot fill now resolves targets through `kit-manifest.json` and never
  touches verbatim files. GAP-007 resolved as the **bold-reference rule**, not undeletable
  templates: the tier templates/menu stay deletable (the tier-menu philosophy — an adopted
  project sees only what it picked); verbatim kit docs reference them in bold, and the
  authoring convention in `scripts/doc-lint.ps1`'s header states the rule.
