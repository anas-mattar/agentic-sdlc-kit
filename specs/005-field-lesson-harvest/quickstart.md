# Quickstart: Field-Lesson Harvest Verification

Five re-walk scenarios (spec SC-002). Each re-creates the exact conditions of the original
incident and checks that the *updated* guidance now surfaces the trap before its original
downstream effect. These are manual read-throughs against the amended files, not automated
tests — there is no code here, only guidance (plan.md Constitution Check, Testing
Requirements).

Run all five after Phase 3 lands (or per-phase, for the traps that phase covers), then run
`pwsh -File scripts/doc-lint.ps1` once at the end — it must stay green.

## Scenario 1 — `.env*` gitignore swallow (US1, Phase 1)

1. Open `adoption/greenfield.md` step 3.
2. Confirm a bullet exists naming the trap: a scaffolding tool's generated `.gitignore` uses a
   blanket `.env*` pattern that also excludes `.env.example`.
3. Confirm the bullet gives a concrete check: after scaffolding, run `git status
   --ignored` (or equivalent) and verify `.env.example` is not listed as ignored; if it is,
   add a `!.env.example` negation line.
4. **Pass condition**: a reader who has never seen the flowboard/expense-tracker incidents can
   follow the bullet and would have caught `.env.example` missing from `git add -A` output
   before the first commit.

## Scenario 2 — skipped `git init` in an existing tree (US1, Phase 1)

1. Open `adoption/greenfield.md` step 3 (same location as Scenario 1).
2. Confirm a bullet exists naming the trap: some scaffolding CLIs skip `git init` when run
   inside a directory that is already part of a git repository, which can also silently
   re-initialize a nested repo instead.
3. Confirm the bullet gives a concrete check: run `git status` immediately after scaffolding
   and confirm the new files appear as untracked additions in the *parent* repo (`git rev-
   parse --show-toplevel` matches the expected root) — not inside a stray nested `.git`.
4. **Pass condition**: following the bullet would have caught flowboard's `create-next-app`
   nested-repo surprise (commit history shows a manual `git init` fix was needed) before the
   first commit.

## Scenario 3 — reused connection string / `Spc` incident (US2, Phase 2)

1. Open `docs/rulebooks/database-rules-template.md` and confirm the new Setup bullet exists:
   verify the migration's target database is dedicated to the project before the first
   migration runs.
2. Open `adoption/greenfield.md` step 5 and `adoption/existing-system.md` step 4 and confirm
   each cross-references that bullet at the first-write-slice point.
3. **Pass condition**: re-creating the expense-tracker 002 sequence (a local SQL Server
   instance with a pre-existing unrelated database named after the connection string default)
   against the updated guidance would have prompted an explicit "which database does this
   resolve to, and is it ours?" check before `dotnet ef database update` ran — the same check
   that led to the real rename-and-re-gate fix, but performed *before* the migration instead
   of after.

## Scenario 4 — `--warnaserror` vs transitive-dependency vulnerability (US3, Phase 3)

1. Open `docs/sdlc/gate-command.md` and confirm the new section after "Minimum Gate" documents
   the triage pattern: upgrade the dependency, pin a patched transitive version, or record a
   narrowly-scoped, reasoned suppression — never a blanket disable of the strict flag.
2. Open `adoption/greenfield.md` step 3 and confirm it cross-references this section.
3. **Pass condition**: re-creating flowboard's `Microsoft.OpenApi` GHSA-v5pm-xwqc-g5wc failure
   against the updated guidance leads to the same resolution actually used (pin to a patched
   version) via a documented decision path, not ad-hoc trial and error.

## Scenario 5 — raw imported docs break doc-lint (US3, Phase 3)

1. Open `adoption/greenfield.md` step 2 and `adoption/existing-system.md` step 7 and confirm
   each has a short paragraph on normalizing externally authored rulebook content before it is
   added: repo-code paths written in **bold**, not backticks; `{{SLOT}}`-looking placeholders
   filled or removed.
2. **Pass condition**: re-creating flowboard's rulebook import (external shop rule packs
   containing backticked repo paths) against the updated guidance would have caught the
   doc-lint failure before the content was committed, not after a red doc-lint run.

## Final check

```powershell
pwsh -File scripts/doc-lint.ps1
```

Expected: exit 0. All five scenarios above pass by inspection (this feature adds guidance, it
does not add machine-checkable rules beyond what doc-lint already asserts — path references
introduced by the new prose must resolve, which doc-lint verifies).
