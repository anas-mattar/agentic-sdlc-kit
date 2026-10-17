# Notes: the enforcement pack names the cause when its diff base cannot be read

Evidence for feature 035 (GAP-041). Nothing here is law; `spec.md`, `plan.md` and `tasks.md` are.

## Pre-spec measurement (2026-10-17, git 2.55.0.windows.5)

Method: the kit's own fixture `enforcement-pack/STRUCT-001/pass` materialised with `tests/enforcement/Run-Tests.ps1 -Case enforcement-pack/STRUCT-001/pass -KeepRepo` (a numbered branch `001-thing` on a trunk `main`), the pack run
against it with `-Root <fixture> -Branch <b>`, and a tip commit truncated to half its bytes (a copy kept, restored afterwards). A `docs/x` branch and a `002-orphan` branch were added to the kept fixture for the Lite lane and the
no-shared-history state. Nothing in the project was touched.

| # | Probe | Result |
|---|---|---|
| M1 | `-Branch 001-thing`, intact | `diff base '17952ff...', 3 changed file(s)`, `AmendmentAuthority: graded 0 of 1 commit(s) ...`, `enforcement-pack: OK`, exit 0 |
| M2 | the same, the tip commit **truncated** | `diff base ''`, `WARNING: enforcement-pack: no integration branch to diff against, so nothing on '001-thing' was compared ...`; `UNGRADED: ReviewProvenance: no diff base ... Fetch the full history ('fetch-depth: 0' on actions/checkout)`; `UNGRADED: PhaseSizeWarning: no diff base ...`; `enforcement-pack: FAIL (1 issue(s)): AmendmentAuthority: cannot grade '001-thing' — no integration branch to diff against. Either neither 'origin/main' nor 'main' resolves here, or one of them resolves but shares no commit with HEAD (a truncated clone, or unrelated histories) — this check does not distinguish them ...`, **exit 1** |
| M3 | `-Branch docs/x` (Lite lane), intact | `diff base '...', 1 changed file(s)`, `the lightweight docs/ lane`, `enforcement-pack: OK`, exit 0 |
| M4 | the same, the tip commit **truncated** | `diff base ''`, the same `WARNING`, `UNGRADED: ReviewProvenance ... Fetch the full history ('fetch-depth: 0' ...)`, `enforcement-pack: UNGRADED (1 check(s) formed no opinion)`, **exit 0** |
| M5 | `-Branch 002-orphan` (numbered, no shared history with `main`: legitimate), plus no spec directory | the same `WARNING` and `UNGRADED` lines, the four failures of a branch with no spec (three `Structure`, one `AmendmentAuthority: cannot grade ... no integration branch to diff against`), exit 1 |

So the numbered lane is already red for a damaged branch (the opposite of the scope check before feature 034), and the Lite lane is `UNGRADED` at exit 0 by standing decision (feature 014 FR-009, feature 015 D6). What a damaged branch gets is the
**wrong cause**: M2 and M4 are indistinguishable from M5 by their text, and the shallow-clone advice (`fetch-depth: 0`) is no remedy for a damaged object store. `AmendmentAuthority`'s own message says it does not distinguish the states.

Where it comes from: `scripts/enforcement-pack.ps1:186-200` (`Get-DiffBase`: `git merge-base HEAD $c 2>$null`, return the base only on exit 0), the dispatch warning at `:2401`, the `AmendmentAuthority` failure at `:2143`, and the `UNGRADED` lines
that say "no diff base" at `:908` (MicroLane), `:1316` (ReviewProvenance, the one that advises `fetch-depth: 0`), `:1375` (PhaseSizeWarning) and `:2426` (LiteAndAbuse).

Not measured here, and the plan must: the same probes on the CI image's git (feature 034's CI showed the `exit 128` of a truncated tip holds on Linux); whether the pack's other uses of the base (the `git diff` reads of feature 028) are affected;
and how the pack's own shallow-clone detection (`git rev-parse --is-shallow-repository`) interacts (the shallow state is answered separately and must keep its text).
