# Quickstart: verifying the Kit-Update Channel

Deterministic verification per phase, run from the repo root in pwsh. Scratch fixtures
live under the session scratchpad — never a real adoption.

## Phase 1 — Manifest + completeness check

1. `pwsh -File scripts/doc-lint.ps1` → exit 0; the manifest section reports the
   classified-file count.
2. **Unclassified fails**: add a scratch `docs/sdlc/zz-test.md`, run doc-lint → exit 1
   naming the file; remove it → exit 0.
3. **Double-class fails**: temporarily add a second entry for `docs/sdlc/flow.md` with
   class `surgical` → doc-lint exit 1; revert.
4. **Spot-checks**: constitution, CLAUDE.md, gate-command.md resolve surgical (with
   reasons); flow.md, definition-of-done.md, `scripts/*.ps1` resolve verbatim;
   `specs/003-*` and `review/` resolve to no entry and are outside shipped surfaces
   (not an error).

## Phase 2 — Update script

Fixture: clone the kit to `<scratch>/kit` (full history); build `<scratch>/proj` as a
git repo holding a pre-004-style adoption (copy the kit-integrity essential paths from
an older kit commit; no `.kit-version`); commit.

1. **Degraded first run**: `update-kit.ps1 -Target proj` → exit 2; per the data-model
   three-way table: verbatim files that DIFFER are skipped + reported "no baseline";
   verbatim files ABSENT in proj are copied (nothing local to protect); `.kit-version`
   is written, so a second run reports precise three-way states (FR-005).
2. **Clean update**: make proj current (accept kit versions of reported files, commit),
   advance the kit clone with a new commit touching one verbatim file → run → exit 0 on
   rerun after the apply run; file copied; `.kit-version` sha advanced (SC-005
   idempotence: immediate rerun → "up to date", clean `git status` in proj).
3. **Surgical never touched (SC-002 hostile sequence)**: in the kit clone, commit a
   change to `docs/sdlc/gate-command.md` (surgical); in proj, note its content hash. Run
   update twice, then `-Force docs/sdlc/gate-command.md` (a surgical path) → the file's
   hash in proj is unchanged all three times; `-Force` on a surgical path is refused
   with an error naming the class; the surgical report names the file and its upstream
   commit each run (exit 2).
4. **Conflict on verbatim**: locally edit `docs/sdlc/flow.md` in proj + commit; advance
   it in the kit too → run → not overwritten, conflict reported (exit 2); run with
   `-Force docs/sdlc/flow.md` → kit version applied, exit reflects remaining state.
5. **Preflights**: `-Target` = the kit itself → exit 1; proj with `.specify/` renamed
   away → exit 1 (partial install); dirty proj working tree → exit 1; `-DryRun` on a
   behind proj → full report, zero writes (`git status` clean, no `.kit-version`
   change).
6. **CRLF immunity**: rewrite one verbatim file in proj with CRLF endings (same
   content) → run → reported up to date for that file (FR-008).
7. **doc-lint**: `scripts/update-kit.ps1` and `kit-manifest.json` in the required-paths
   list (rename test fails doc-lint).

## Phase 3 — Flow-down guidance

1. `adoption/updating.md` exists; doc-lint exit 0 (every backticked path resolves —
   note branch-protection portability lesson: no kit-internal `specs/NNN-*` backticks).
2. Content walk: the section answers, without external context — what a project's
   constitution version becomes after adopting a kit amendment (their own bump, never
   the kit's string), what their SYNC IMPACT entry records, the demoted-content
   verification step, the citation sweep, and who approves (FR-009 / SC-004), with the
   2026-09-01 flow-back as the worked example.
3. CLAUDE.md Task-Scoped Reading has the updating row; `grep updating.md CLAUDE.md`
   non-empty.
4. Full-channel dress rehearsal (optional but recommended before merge): run
   `update-kit.ps1 -DryRun -Target D:\solutions\expense-tracker` — expect "up to date /
   no baseline" states and a sane surgical report, zero writes.
