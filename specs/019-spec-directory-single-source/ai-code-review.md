# AI Code Review — 019 Spec-directory single source (GAP-021)

**Reviewer**: fresh-context agent, claude-sonnet-5-5 (Claude Code)
**Date**: 2026-10-11
**Branches**: kit repo `019-spec-directory-single-source` (tip `6383e0e`; parent `2c3e5ac`; spec draft `b12e0a7`)
**Scope reviewed**: `git show 6383e0e` (CLAUDE.md, adoption/updating.md, docs/digests/adoption-digest.md, docs/roadmap.md); spec.md at `b12e0a7`/`2c3e5ac`; `docs/sdlc/branch-strategy.md` "Spec Directory Contents"; `kit-manifest.json`; `scripts/update-kit.ps1`, `verify-kit.ps1`, `enforcement-pack.ps1`; `tests/enforcement/rules.json`; repo-wide grep for the old sentences.
**Feature contract**: Micro, one phase, 4-file Territory, no script/check/fixture change; CLAUDE.md summarises and points at branch-strategy.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-sonnet-5-5 (separate session that produced commit 6383e0e)
- **Inputs provided**: phase 1 diff 6383e0e, spec.md (approved mini-spec), commits b12e0a7/2c3e5ac, repository at the branch tip
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups** — the phase does what the approved mini-spec asks, stays inside its 4-file Territory (about 43 changed lines), and `ritual-checks.ps1` is RESULT OK. Findings: one miscount carried from the spec into pre-existing prose (F1), one expected merge conflict (F2), and two minor notes. None blocks. This review is not the owner's gate; certification is the user-run exit code.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Check 1 — heading and retained content | `## Feature Structure` unchanged. grep finds four `rules.json` laws (lines 426, 822, 933, 1131) and `enforcement-pack.ps1:252` citing it by name. Mapping sentence, three core docs in the tree, fallback paragraph and Micro exception all still present. "exactly these names" now qualifies only "The core documents"; "That list is the core, not the whole set" drops the exhaustive claim. |
| Check 2 — pointer matches the real set | branch-strategy "Spec Directory Contents" lists spec, plan, tasks, research, data-model, contracts/, quickstart, notes, screenshots/, checklists/, ai-code-review, human-pr-review, rollback. The new paragraph names `notes.md`, `quickstart.md`, `checklists/`, review and rollback files from `specs/_templates/`: all present there. "Create whatever the lane requires; never decline a file" leaves no sentence forbidding a listed file. The fallback now says "create the core structure ... from `.specify/templates/`", consistently scoped. |
| Check 3 | `docs/sdlc/branch-strategy.md` was already referenced in CLAUDE.md and is a manifest verbatim file; doc-lint OK. |
| Check 4 — flow-down note | `kit-manifest.json` line 4: CLAUDE.md is class `surgical`. `update-kit.ps1` (header, lines 171, 250): surgical files are reported, never written; forcing is refused. The three hand edits quote the actual diff exactly (first-line change, inserted paragraph, the two phrase swaps). "Doctor does not check it": `verify-kit.ps1` checks CLAUDE.md only for existence (line 52) and unfilled slots (line 135); enforcement-pack cites the heading only in a failure message. "Nothing in the kit's behaviour changed" holds (no script or fixture in the diff). Digest marker is 114 chars (limit 120); `digests: OK (5 fresh, 88 markers)`. |
| Check 5 — roadmap | GAP-021 row reads `shipped`, owner `anas.m`, link unbracketed like neighbouring shipped rows. Precedent: 017 (c970b71, phase 5) and 018 (ddc11fd, phase 4) flipped the row to shipped inside the final phase commit on the branch, not at merge. Matches. `roadmap-claims: OK (own claim 019 exempt)`. |
| Check 6 — ritual | `pwsh -NoProfile -File scripts/ritual-checks.ps1`: doc-lint OK, enforcement-pack OK (AmendmentAuthority graded 3 of 3 commits), scope-check PASS phase 1 commit 6383e0e (4 files, Micro territory), scope-repos n/a, digests OK, roadmap-claims OK, verify-kit n/a, **RESULT OK**. |
| Feature contract held | No schema, package, architecture, invariant or UI change; eligibility boxes are honest for a docs-only diff. |
| Constitution / invariants | Constitution I amendment rule engaged and handled (see Amendments). Nothing else touched. |
| Security | N/A (documentation only). |
| Scope guard | `git diff --stat` read: CLAUDE.md 12 lines, updating.md +29, digest +1, roadmap 1 line. Micro bounds met (4 <= 5 files, about 43 lines <= 400). |
| Rollback safety | Single phase commit; `git revert 6383e0e` is clean. |

## Findings

### F1 — "fourteen" file count is wrong — DOC DRIFT

The spec Intent and the pre-existing roadmap GAP-021 prose say branch-strategy "lists fourteen"; its tree lists thirteen entries. The phase's own flow-down note avoids that count ("seven-entry" for CLAUDE.md is correct), so nothing wrong shipped to adopters; the miscount lives in the approved spec and old roadmap prose.
*Action: none for merge; owner may correct the roadmap prose later (editing the approved spec.md would itself need recorded approval).*

### F2 — Expected merge conflict with open PR #59 — CONFIRM

PR #59 (`docs/claim-019-roadmap-row`) changes only `docs/roadmap.md`, flipping the same GAP-021 row to `in progress`. This branch sets the same row to `shipped`, so the second to merge conflicts on that one line. Precedent (e489fdf, 016) resolves it by keeping main's row and flipping it to shipped.
*Action: owner merges #59 first, then merge main into this branch, resolve the row as `shipped` with the unbracketed link, rerun ritual-checks (roadmap-claims then sees the claim on main).*

### F3 — No other contradicting exhaustive-list claims or adopted copies — MINOR

Searched CLAUDE.md, docs/, .specify/ (constitution, templates), adoption/, scripts and tests for "exactly these names", "exact structure", "This structure is law", "exhaustive". Remaining hits: CLAUDE.md line 40 (now qualified), the new updating.md note (quotes the old text on purpose), roadmap GAP-021 history, an unrelated speckit.analyze phrase, and `review/out/codex-round1.md` (a past review record). No template or adoption doc carries a copy of the old sentence; no constitution or sdlc document asserts an exhaustive spec-directory list.
*Action: none.*

### F4 — 013 tasks.md still cites CLAUDE.md as fixing the file set — MINOR

`specs/013-critical-independence-signal/tasks.md:712` is the recorded origin of GAP-021; a closed historical document, correctly untouched.
*Action: none.*

## Amendments in this diff

- [x] Amendments listed:
  - `2c3e5ac` (amended, unpushed) adds `**Amendment approved by**: anas.m, 2026-10-11` to the feature's own `spec.md` and sets Status to Approved (anas.m). The approver is the owner, not the implementing agent, and the record sits in a commit before the phase commit (`6383e0e` does not touch spec.md), so the agent did not approve its own amendment. The subject also carries the approver text. enforcement-pack AmendmentAuthority grades the three branch commits and passes. Rewriting an unpushed commit is acceptable; nothing downstream referenced the old sha.
  - Phase commit `6383e0e`: spec.md, plan.md, tasks.md unchanged — no amendment.

## Constitution re-check (post-implementation)

PASS. Principle I (spec first, owner approval recorded before the phase), X Micro lane bounds (<= 5 files, <= 400 lines, one phase) and the declared `user-run` gate certification are honoured. No principle engaged late.

## Test coverage observed

No code changed; no tests added or required. Mechanical coverage is `ritual-checks.ps1` (doc-lint, enforcement-pack incl. amendment authority and Structure law, scope-check, digest freshness, roadmap-claims), all green in this review.

## Residual risk

Low; the change is prose. Remaining items: resolve the roadmap-row conflict with PR #59 (F2); adopters who skip the hand edit keep the old wording (documented as harmless). The owner's gate exit code, not this review, certifies the phase.
