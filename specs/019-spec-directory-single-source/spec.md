# Micro Spec: Spec-directory single source

**Feature Branch**: `019-spec-directory-single-source`
**Created**: 2026-10-11
**Amendment approved by**: anas.m, 2026-10-11
**Status**: Approved (anas.m, 2026-10-11) <!-- Draft → Approved (owner) before the phase begins — constitution I, Micro arm -->
**Delivery Level**: Micro
**Gate Certification**: user-run

## Intent

Closes GAP-021. `CLAUDE.md` ("Feature Structure") calls its seven-entry list "exactly these
names", while `docs/sdlc/branch-strategy.md` ("Spec Directory Contents") lists fourteen, including
`notes.md`, `ai-code-review*.md`, `human-pr-review.md` and `rollback.md`. Every kit feature since 006
carries files the always-loaded document forbids, and an agent that reads `CLAUDE.md` alone has
declined to create files a lane requires (feature 013). Make `CLAUDE.md` summarise the layout and
point at `docs/sdlc/branch-strategy.md` for the authoritative file set, so there is one source and
no exhaustive list to contradict it. Adopted projects receive `CLAUDE.md` as a surgical file, so the
flow-down note says what to change in theirs.

## Acceptance checks

1. `CLAUDE.md` "Feature Structure" keeps its `## Feature Structure` heading (four `rules.json` laws
   cite it by name), the branch-to-directory mapping, the three core documents in order
   (`spec.md`, `plan.md`, `tasks.md`), the fallback instruction for a partly installed kit, and the
   Micro exception; it no longer claims an exhaustive list or "exactly these names" for the file set.
2. It states that `docs/sdlc/branch-strategy.md` ("Spec Directory Contents") is the authoritative
   file set and that the per-feature files from `specs/_templates/` (review files, `rollback.md`)
   and `notes.md` belong in the directory; no sentence in `CLAUDE.md` forbids a file that
   branch-strategy lists.
3. The path `docs/sdlc/branch-strategy.md` in `CLAUDE.md` resolves in an adopted project (it is a
   verbatim manifest file), and doc-lint passes.
4. `adoption/updating.md` carries a flow-down note: `CLAUDE.md` is surgical, so the note gives the
   replacement text for an adopted copy and says nothing else in it changes; its digest marker is at
   most 120 characters, and the digests are regenerated and fresh.
5. The GAP-021 roadmap row reads `shipped` with its spec link unbracketed.
6. `pwsh -File scripts/ritual-checks.ps1` is `RESULT OK`, and `scope-check` passes on the phase
   commit.

## Eligibility checklist *(all boxes MUST be checkable — one unchecked box means this is not a Micro feature)*

- [x] No schema change or migration
- [x] No new packages or dependencies
- [x] No architecture change
- [x] No domain-invariant surface (constitution V)
- [x] No UI with visual references (`screenshots/`)

**Territory**:

- `CLAUDE.md`
- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/digests/adoption-digest.md`

## Rollback

Revert the single phase commit (`git revert <sha>`).
