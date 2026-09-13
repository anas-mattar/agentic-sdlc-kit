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
post-010 field use (expense-tracker session, 2026-09-09), first multi-repo
two-developer adoption (FitForge — 001 governance AI review and parallel-work planning,
2026-09-10), first multi-developer working session (FitForge, 2026-09-13 — a framework
review of how levels get chosen and how work reaches a developer)
**Generated on**: 2026-09-13 — **by**: manual audit during the 005 flow-down + same-day
self-assessment session (2026-09-07), extended with the feature 010 review harvest
(2026-09-09), the first post-010 field-use lessons (2026-09-09), the first
multi-repo two-developer adoption (2026-09-10), and the first multi-developer working
session (2026-09-13)

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
| GAP-018 | The **pre-phase** territory check cannot reach nested code repositories — the same blindness GAP-016 closed for the post-commit scope check, now in the tool meant to *prevent* the collision rather than grade it after the fact. `scripts/territory-check.ps1` diffs the governance repo alone (`scripts/territory-check.ps1:63,90`) and has no `codeRepos` awareness. In a nested multi-repo project two feature branches touch their own `specs/NNN-name/` directories and little else the check can see, while the code that actually overlaps sits in repositories it never opens — so it reports clean and cannot produce a true positive in the one layout that needs it. `docs/sdlc/team-workflow.md` §5 mandates it before every phase, and `docs/sdlc/definition-of-done.md` does not, so the failure is silent: no gate goes red, the two owners simply discover the overlap at merge — which §5 itself calls a process failure. Candidate fix: extend it the way feature 012 extended the scope check, reading the declared code repos as sibling working trees | 2026-09-10 FitForge, planning the first two-developer parallel features |
| GAP-019 | Nothing records or checks **who approved a change to an already-approved feature document**. Constitution I says "create **or update**" `spec.md`, `plan.md` and `tasks.md` and stops there — the update needs no approver; the Governance section's "adopted only after human approval" binds amendments to the constitution, not to feature documents. Every enforcement-pack check grades paths, tokens, levels and dates; none grades authority. Observed: after one owner approval, five rule changes — a new package, a changed contract value, two widened Territory blocks, an added phase — were written and consumed by the same implementing session within minutes, one pair 29 seconds apart, with every machine check green throughout. Getting the order right (amend, then implement) is a check on retroactivity, not on consent. The adopting project amended its own constitution to require an amendment-approver line, but **cannot host the check**: `scripts/*.ps1` is `verbatim` in `kit-manifest.json`, so a project-side check is overwritten by the next `update-kit.ps1` run — leaving a constitutional rule whose enforcement had silently disappeared. The check belongs in `scripts/enforcement-pack.ps1` or nowhere | 2026-09-10 FitForge 001 governance AI review, finding F3 |
| GAP-020 | The Critical lane's independent-approval check enforces more than the law it cites, and in the direction that pushes teams out of the lane. `docs/sdlc/critical-delivery.md` item 5 requires that the human reviewer not be the feature's owner, and offers a second-model adversarial review plus a 24-hour cooling-off as **the solo developer's substitute** for that independence. `Invoke-CriticalEvidenceCheck` in `scripts/enforcement-pack.ps1` requires the substitute **unconditionally**, because nothing in `kit-adoption.json` records how many developers a project has — so a two-developer project whose cross-review already satisfies item 5 must either fabricate a substitution that did not happen or drop the feature to Standard to escape the check. This is the inverse of the failure feature 012's reviews taught the kit to hunt: not silently green, but loudly red where the law is satisfied — and a check that cannot legitimately pass teaches people to route around the strictest lane, which is worse than one that cannot fail. Whatever replaces the substitute for team projects must still be machine-checked, or the fix trades this gap for a GAP-019-shaped hole | 2026-09-10 FitForge feature 002, the first Critical feature declared in any adopted project |
| GAP-021 | The kit contradicts itself about what may live in a feature's spec directory, and the contradiction bites hardest in the strictest lane. `CLAUDE.md` ("Feature Structure") calls its list **"exactly these names"** — seven entries, excluding `rollback.md`, `ai-code-review*.md` and `human-pr-review.md`. `docs/sdlc/branch-strategy.md` ("Spec Directory Contents") lists fourteen and names all three as per-feature files from `specs/_templates/`. Neither cites the other and nothing checks either, so both read as law. The kit's own practice settles it in favour of branch-strategy — every kit feature since 006 carries `ai-code-review*.md` in its spec directory, a file `CLAUDE.md`'s list forbids — which means the always-loaded document is the wrong one, and it is wrong on every feature the kit has ever shipped. Two live consequences, not hypotheses: `docs/sdlc/critical-delivery.md` item 1 requires a filled rollback plan **before phase 1** and only branch-strategy says where it goes, so a Critical feature's first mandatory artifact has no agreed path; and an agent reading `CLAUDE.md` alone declines to create files the lane requires — observed in kit feature 013, whose `tasks.md` cites "`CLAUDE.md`'s Feature Structure fixes the file set" as the reason not to add one. Fix shape: `CLAUDE.md` summarises and points at branch-strategy for the full set, rather than asserting an exhaustive one | 2026-09-10 FitForge feature 002 planning, filing the Critical rollback plan |
| GAP-022 | A Critical feature's branch is red from its first commit to its last, so the branch signal is noise for the whole feature. `Invoke-CriticalEvidenceCheck` demands the independence artifact — `human-pr-review.md` in team mode, `second-model-review.md` plus the cooling-off in solo — on **every** commit to the branch, but that artifact cannot legitimately exist until the final phase is written and reviewed. Definition of Done says so itself: item 6 is "once per feature, **at merge**", after items 1–5. So `ritual-checks` fails from spec approval onward and the owner is trained, for ten phases, that red is normal — which is the state in which a *real* failure in any of the other six members goes unread. Observed on FitForge 002 (ten phases, Critical): the only member failing at phase 1 was the review artifact for a review of code that did not exist. Predates feature 013 — solo mode demanded its artifact from day one too, so 013 changed which artifact, not when. This is GAP-020's family (a check that cannot legitimately pass) in its milder form: it can pass, but only once, at the end. Candidate shapes, none obviously right: gate the check on the feature being merge-ready rather than on the branch existing; make it a WARN until the final phase and a FAIL at the merge commit; or move it out of `ritual-checks` into a merge-time check, at the cost of it no longer being the same command CI runs | 2026-09-10 FitForge 002 phase 1, the first Critical feature to reach implementation |
| GAP-023 | The **delivery level** is an input to every enforcement check and an output of none — the single decision that selects how much rigour a feature gets is the only one nothing grades. `Get-DeliveryLevel` (`scripts/enforcement-pack.ps1:157`) reads the declared value and the downstream arms dispatch on it: Structure requires `spec.md` alone when it reads Micro (`scripts/enforcement-pack.ps1:183`), and MicroLane, CriticalEvidence and GateCertification each follow that same declaration. The only validation is spelling — `scripts/enforcement-pack.ps1:194` fails an unfilled or off-menu value and nothing else — so a **Delivery Level** of Standard on a feature that rewrites authentication is green by construction. The prose criteria exist and are good (`docs/sdlc/critical-delivery.md:31` lists the four Critical triggers; `docs/sdlc/branch-strategy.md` states the Lite/Micro and Micro/Standard boundaries), but they are self-assessed by the implementing session at creation — before `plan.md`, before the Territory block, before `data-model.md` — and the incentive runs downhill, because every level up costs real ceremony. Enforcement is asymmetric in the same direction: Micro has a machine floor (5 territory files, 400 lines, one phase) that forces promotion, while Standard to Critical has no trigger at all, only the honour-system prose "stop and promote it" (`docs/sdlc/critical-delivery.md:22`). Recorded as a shape, not a sighting: FitForge 002 declared Critical correctly and no misdeclaration has yet been observed. GAP-020 taught that a check which cannot legitimately pass drives teams out of the strictest lane; under-declaration is the same loss arriving silently, from the other side — and it is the side no machine watches. Candidate fix: a **Level Rationale** block in `spec.md` answering the four Critical triggers explicitly (the Reviewer Provenance move, which turns a silent omission into a written claim a reviewer can falsify), plus a criticalSurfaces path-glob declaration in kit-adoption.json and a check that fails a sub-Critical level whose Territory intersects it, reusing feature 012's repo-aware path reading rather than inventing machinery | 2026-09-13 FitForge, first multi-developer working session — framework review of level selection |
| GAP-024 | Who implements a feature and who judges it are chosen by the same person, from a roster that carries one bit. The developers array in kit-adoption.json exists only to be counted: `docs/sdlc/critical-delivery.md:96` selects the CriticalEvidence arm by whether that count reaches two, and nothing else in the kit reads it. Three consequences, all live today. (a) **Names are never checked against the roster** — a feature's Owner and the Reviewer in its Review Provenance block are free text, and the team arm compares them to each other (`docs/sdlc/critical-delivery.md:100`) but neither of them to the declared developers, so the strictest lane's independence rests on two strings that need not name anyone the project has declared. (b) **The owner picks their own judge** — `docs/sdlc/team-workflow.md:54` has the owner choose the cross-reviewer at claim time, which is the judged party selecting the judge; feature 013 made the *arm* machine-checked and left the *choice* exactly where it was. (c) **Pull has no matching** — `docs/sdlc/team-workflow.md:42` orders picking by roadmap priority and then screens for dependencies and territory, never for fit, so in a multi-repo project (FitForge: a C# API repo and a Next.js web repo) the top row goes to whoever is free rather than to whoever owns that stack, and the strictest features are the ones that can least afford it. The WIP limit (`docs/sdlc/team-workflow.md:59`) is prose with no counter, which is GAP-004 unchanged — but `scripts/territory-check.ps1` already enumerates the open remote NNN-* branches and `scripts/roadmap-claim-check.ps1` already maps a claim to its roadmap row and Owner, so the missing count is a join over machinery that already exists. Candidate fix: promote the roster from strings to objects (name, repos, canApproveCritical), keeping string entries legal and keeping 013's absent-record-defaults-to-strict rule, then read it three ways — the Owner is in the roster, a Critical feature's reviewer is in the roster and is not the Owner and is permitted to approve, and at most one active claim per Owner. Deliberately NOT in the fix: assignment authority, skill matrices, capacity planning — the leaderless claim-by-push ledger is the kit's best team property, and buying out coordination-by-meeting is exactly what it is for | 2026-09-13 FitForge, first multi-developer working session — framework review of how work reaches a developer |

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
| Roadmap-claim visibility check (ritual-checks asserts every specs/NNN-* reachable on a remote branch has a non-idea row on main — or status flips move to a main-side docs commit at claim time) | GAP-017 | P1 | shipped | anas.m | `specs/011-roadmap-claim-check/` |
| Code-repo scope-check reach (governance-side `scope-check-repos.ps1` reads the nested code repos as sibling working trees and grades their phase commits against repo-prefixed Territory, resolved as of each code commit; `codeRepos` in the adoption record; code-repo CI template) | GAP-016 | P1 | shipped | anas.m | `specs/012-cross-repo-scope-check/` |
| Rendered-structure lint (block-structure check in doc-lint: tables and list blocks uninterrupted; table rows have uniform cell counts, escaped pipes not counted — not a markdown renderer) | GAP-015 | P2 | idea | — | — |
| Critical independence signal (the adoption record states the project's developers; the Critical evidence check requires the solo substitute only when the project is solo, and an equally machine-checked independence artifact when it is not — absent record defaults to strict, so no existing adoption changes behaviour) | GAP-020 | P1 | shipped | anas.m | `specs/013-critical-independence-signal/` |
| Amendment authority (constitution clause first: any change to an approved `spec.md`, `plan.md`, `tasks.md` or contract records who approved it, and an implementing agent may not approve its own; then an `enforcement-pack.ps1` check that grades it) | GAP-019 | P1 | idea | — | — |
| Cross-repo territory reach (`territory-check.ps1` reads the declared code repositories as sibling working trees and reports overlap across them, the way feature 012 extended the scope check) | GAP-018 | P2 | idea | — | — |

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
- 2026-09-09 GAP-016 raised P2 → P1 and claimed as feature 012: the first multi-developer,
  multi-repo adoption (FitForge — C# API + Next.js web, nested layout, two developers) is
  starting, which is exactly the condition the entry above named as the trigger ("its fix
  shape must be decided before adopting one"). Shape decided in the same sitting:
  **governance-side runner reading the code repos as sibling working trees**, not thin
  `scripts/` shipped into each code repo — a copied script set re-creates the update-kit
  sync ratchet GAP-006/GAP-007 already cost two flow-downs, and the territory declaration
  it must read lives in the governance repo either way. The claim's spec carries the
  reasoning; this row exists so a teammate orienting from main sees the work is live.
- 2026-09-09 Claim-time roadmap flips must write the Spec cell **bracketed**
  (`` `[specs/NNN-name/]` ``) until the feature merges. Fixed directly on this docs branch
  rather than promoted to a feature (GAP-002 precedent — one line of governance
  bookkeeping): feature 011's flip rule and doc-lint's resolvable-path rule collide by
  construction at claim time, because the spec directory exists only on the feature branch
  while the flip commit lands on main. CI caught it on the first claim made under the new
  rule (this one). `docs/sdlc/branch-strategy.md` now states it; the `specified` example row
  in `specs/_templates/roadmap-template.md` already used the bracketed form.
- 2026-09-09 Feature 012 shipped; GAP-016 closed. Gate 4 now reaches the nested code
  repositories: `scripts/scope-check-repos.ps1` grades each declared code repo's phase
  commits against repo-prefixed Territory read from the governance repo, resolved **as of
  the code commit's committer date and filtered by path** so a later `git merge main`
  cannot backdate a declaration. One asymmetry is deliberate and recorded in the Definition
  of Done: a missing in-repo declaration WARNs (pre-006 compatibility), while a code commit
  that predates its declaration FAILs — cross-repo territory has no legacy to protect.
  Three fresh-context reviews found four blocking defects the implementing session missed,
  and **every one was the same shape: a silent downgrade to WARN/exit 0** — green and
  blind. That is the failure mode to hunt for in any check this kit adds next; a check that
  cannot fail is worse than no check, because it also buys false confidence.
- 2026-09-09 First FitForge adoption caught a GAP-007-class violation in the kit's own
  verbatim file and it was fixed in place (GAP-002 precedent — one line, no feature):
  `adoption/greenfield.md` backtick-referenced `modules/finance/finance-invariants.md`,
  a **surgical** path the manifest itself describes as "worked examples; projects replace
  with their own domain modules". FitForge did exactly that — replaced it with
  **modules/training/** — and doc-lint then failed inside a verbatim kit document, which
  `update-kit.ps1` re-applies wholesale, so the adopter could never fix it locally without
  taking a permanent conflict. Now bold, per the authoring convention doc-lint's own header
  states. Why it went unseen for four adoptions: the two earlier projects left the finance
  example in place, so nobody had yet done the documented thing. **The lesson is not "one
  more sweep": a rule the kit states about itself should be machine-checked. A doc-lint
  rule that fails a backticked surgical path inside a verbatim document would have caught
  this at authoring time — recorded as a candidate, not fixed here.**
- 2026-09-10 GAP-018 and GAP-019 recorded from the first multi-repo two-developer
  adoption — **inventory only; the promotion decision is the owner's** (record before
  fixing, per the GAP-002/GAP-015/GAP-016 precedent). Both were found the same way, and
  it is not the way this kit is designed to find things: neither came from a check, a
  gate or a review, but from answering a plain process question ("can the two developers
  work in parallel?") and reading what the tooling would actually do. Every machine check
  was green over both.
- 2026-09-10 On promoting GAP-018 (pre-phase territory check): the trigger GAP-016's own
  entry named — "its fix shape must be decided before adopting one" — is not merely met
  but live, and this is the sibling script in the same blind spot. It is nonetheless
  recommended at **P2, not P1**, and the distinction is worth stating because it is the
  one that separates this gap from GAP-016. The scope check is a Definition-of-Done gate:
  when it cannot see a repository, a required verification silently returns nothing and
  the phase merges ungraded. `scripts/territory-check.ps1` grades nothing — it is
  advisory, mandated by `docs/sdlc/team-workflow.md` §5 alone, and its failure costs a
  rebase discovered at merge instead of a collision avoided before the phase. Real, but
  recoverable, and the manual fallback §5 already documents is two commands per code
  repository. What makes it a roadmap row rather than a GAP-015-style single sighting is
  that it needs no second sighting: the check **cannot** produce a true positive in the
  nested layout, so the field cannot teach us anything further by repeating it.
- 2026-09-10 On promoting GAP-019 (amendment authority): recommended as a roadmap row at
  **P1**, on a ground no other open gap shares — a constitutional rule is already live in
  an adopted project with nothing enforcing it, and the kit does not yet carry the clause
  at all. That is the GAP-002 shape (a constitutional constant kept true by discipline)
  with the discipline removed, and it is exactly the failure mode feature 012's review
  taught us to hunt: green and blind. The fix has two halves and the order matters — the
  kit's own constitution gains the rule first (Principle I, which today says "create **or
  update**" and asks nothing of the update), then `scripts/enforcement-pack.ps1` gains the
  check; a check without the clause enforces nothing, and the clause without the check is
  the state we are recording. Two design questions must be settled in the spec rather than
  waved at, because both are places this could quietly become a check that cannot fail:
  (1) **when does "after approval" begin?** — there is no approval marker in any kit
  artifact today, and the honest mechanical proxy is the first `phase N` commit on the
  branch, which catches amendment-during-implementation but not the sitting where plan and
  approval and first amendment all precede it; (2) **how strong is "not your own"?** — an
  approver name compared against the commit author is free text, and no stronger than the
  Reviewer Provenance block, but it converts a silent omission into a written claim that a
  human reviewer can falsify. Neither question has a clean answer; both have honest ones,
  and an unenforced rule with a stated limit beats an enforced-looking one without.
- 2026-09-10 GAP-018 and GAP-019 promoted to roadmap rows at the recommended priorities, owner approved the same day. Neither is claimed: the rows exist so that a teammate orienting from main sees two known blind spots rather than inferring from green checks that none exist. GAP-019 is sequenced ahead of GAP-018 and ahead of GAP-015 because it is the only open row whose rule is **already live in an adopted project** with nothing enforcing it — every other open gap is missing enforcement for a rule the kit has not yet written down.
- 2026-09-10 GAP-020 recorded and claimed as feature 013 in the same sitting, breaking the record-then-wait precedent deliberately: unlike GAP-015 (observed once, cost one fix commit) this gap **blocks a live feature in an adopted project** — FitForge's 002 is the first Critical feature anywhere and cannot merge green — and unlike GAP-018 it has no manual fallback, because the only ways past it are to fabricate the substitute or to leave the lane. It is P1 for the reason GAP-019 is: the failure is in the kit's strictest lane, where being wrong is least affordable. The fix must not become a downgrade — removing the substitute for team projects without putting an equally machine-checked independence artifact in its place would close this gap by opening GAP-019's, and the spec says so.

- 2026-09-10 013 shipped (main `6cccd24`), and the roadmap row flips in this main-side
  commit rather than on the branch — feature 011's claim-visibility rule cuts both ways.
  Six phases, six ci-held gates each pushed alone, six fresh-context reviews filed
  verbatim in the feature directory. Four of the six said REQUEST CHANGES. The number
  worth carrying forward is not that count but its shape: **every remediation round
  introduced something new** — phase 4 a fail-closed regression, phase 5 a fix that moved
  the hole rather than closing it — with severity falling each round and the rate flat.
  Phase 6 was therefore the last agent round by decision, not by exhaustion, and the next
  gate was a human reading the diff. A fifth defect of that shape does not want a fourth
  agent pass.
  Two facts the feature learned about itself and recorded rather than tidied: it shipped
  the record-reading logic twice in phase 1 and the two copies drifted **inside the same
  feature** (hence `scripts/adoption-lib.ps1`, the second shared library after 012's
  `scope-lib.ps1`); and one review round was misattributed in `spec.md` until the reviewer
  whose position it was said so.
  Still open by decision: the roster is **counted, never compared** — a review naming two
  people absent from the declared roster passes. Disclosed in the script header and in
  `spec.md`'s Edge Cases, so it is a known limit rather than an unmet MUST.
  SC-001 remains unmet from this repository by construction: it needs FitForge's 002 to
  pass on its real cross-review, which needs this flowed down.
- 2026-09-10 GAP-021 recorded while planning FitForge's 002, at the moment the Critical
  lane's first mandatory artifact needed a filename. Recorded rather than fixed in place
  because the conflict is between two kit documents and constitution II's conflict rule
  says to stop and report, never silently choose — and because the wrong one is
  `CLAUDE.md`, which every agent loads every session, so the change wants a reviewer
  rather than a drive-by. **Recommended priority P2, no row added pending the owner's
  call.** P2 rather than P3 because it has already produced one wrong decision inside the
  kit itself (013's `tasks.md`), and not P1 because nothing is unenforced: the failure is
  an agent reading the stricter document and declining to create a file, which a reviewer
  catches. FitForge 002 proceeded under branch-strategy's reading and says so in its
  `plan.md` §7 rather than leaving the choice implicit.

- 2026-09-10 GAP-022 recorded from FitForge 002's phase 1, and it is worth separating from
  GAP-020 rather than folding into it. GAP-020 was a check that could not pass *at all* for
  a two-developer project; this is a check that can pass exactly once, at the end, and is
  therefore red for every phase before it. The damage is different in kind: not a team
  routed out of the strictest lane, but an owner who stops reading a seven-member verdict
  because one member has cried wolf since the spec was approved. The other six members —
  doc-lint, scope-check, scope-repos, digests, roadmap-claims, verify-kit — are exactly the
  ones a Critical feature most needs read on every phase. Deliberately **not** claimed and
  **no row added**: unlike GAP-020 it has a working manual fallback (read the member lines,
  not the summary), and 002 will finish under it. Recording it now, while the friction is
  fresh and before habituation makes it invisible, is the point.

- 2026-09-13 GAP-023 and GAP-024 recorded from the first multi-developer working session,
  before any feature is claimed under either (record before fixing — the
  GAP-002/GAP-015/GAP-016 precedent). They are one observation seen twice: this kit has a
  mature **execution** layer and a thin **decision** layer. Everything that happens after
  the level and the owner are fixed is machine-graded or cross-human — scope-check,
  territory-check, the enforcement pack, digests, roadmap-claims, the fresh-context review,
  the owner-held gate. The three inputs that decide *which* of those apply — what level
  this is, who implements it, who reviews it — are declared by the implementing side and
  graded by nobody. GAP-019 (amendment authority) was the first member of that family;
  these are the second and third, and all three are cheaper to fix together than apart,
  because each one wants a recorded approver whose name means something.
- 2026-09-13 On GAP-023's priority: **recommended P1, no row added pending the owner's
  call.** P1 not because a level has been misdeclared — none has — but because the
  declaration is the dispatcher: a wrong value does not fail a check, it silently selects a
  weaker set of them. That is the failure shape this kit has consistently treated as P1
  (GAP-017, GAP-019, GAP-020), and it is the only open gap that can cost a feature the
  strictest lane without anything turning red. The fix splits cleanly if the owner wants it
  smaller: the **Level Rationale** block is a template-and-lint change on its own, and the
  criticalSurfaces intersection check is the half that needs a new declaration in the
  adoption record. Either half alone is worth more than the prose criteria, which no
  machine has ever read.
- 2026-09-13 On GAP-024's priority: **recommended P2, no row added pending the owner's
  call** — and with it, a recommendation to raise **GAP-004 from P3 to P2 and fold it in**.
  GAP-004 was deferred on 2026-09-01 "until field use shows actual pipelining abuse"; that
  condition is now testable for the first time rather than met, because FitForge is the
  first project with two developers, parallel claims and nested code repositories. P2
  rather than P1 because every consequence still has a working manual fallback while the
  team is two people who can read each other's branches — the roster's thinness is a
  scaling failure, not a present one. The honest promotion trigger is a third developer, or
  the first feature whose recorded reviewer is someone the project never declared.
  Sequenced behind GAP-023 because a roster only starts paying once there is a decision
  (the level) whose approver has to be a real, declared person.
