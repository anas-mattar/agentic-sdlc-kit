# Quickstart: verifying the Flow-Efficiency Pack

Deterministic verification scenarios per phase — the checkpoint each phase must pass
before its gate is requested. All commands run from the repo root in pwsh.

## Phase 1 — Flow page

1. `pwsh -File scripts/doc-lint.ps1` → exit 0; `docs/sdlc/flow.md` present in the
   required-paths list (temporarily rename the file → doc-lint must fail).
2. Every backticked path on the flow page resolves (doc-lint enforces this).
3. Read test: the page names all five mandatory checkpoints (spec approval, per-phase
   gate, scope check, AI review, feature-level human review) exactly once each, in
   order, each linking to its owning document, and carries the "owning documents
   prevail" note (SC-001, FR-002).
4. CLAUDE.md references the page; `grep flow.md CLAUDE.md` is non-empty.

## Phase 2 — Scripts

Run against a scratch clone pair (e.g. `%TEMP%\claim-test\a` and `...\b`, sharing a bare
remote), never against the real remote:

1. **Happy path**: in clone A, `claim-feature.ps1 -ShortName test-a "x"` → exit 0,
   branch `NNN-test-a` exists on the remote, `specs/NNN-test-a/spec.md` exists.
2. **Remote-ahead ledger**: push `0NN+1-elsewhere` from clone B first; clone A's claim
   allocates `NN+2`, not `NN+1` (FR-003).
3. **Race**: create the target number on the remote after clone A's fetch (simulated by
   pushing from B between steps); A's push fails → A renumbers and succeeds, output
   shows `RENUMBERED_FROM` (FR-004).
4. **No remote**: in a repo without `origin`, claim → exit 0 + `not team-visible`
   warning, no push attempted (FR-004).
5. **Dirty tree / not on main**: claim → exit 1, nothing created.
6. **Territory overlap**: branches `010-x` and `011-y` both commit a change to the same
   file; on `011-y`, `territory-check.ps1` → exit 2, names `010-x` and the file. Disjoint
   branches → exit 0 `CLEAN` (FR-005).
7. **Stale claim**: backdate `010-x`'s last commit beyond 14 days (`GIT_COMMITTER_DATE`)
   → its overlap is flagged `stale — reclaimable`, and a claimed branch with no commits
   reports `claimed, no work yet` without crashing.

## Phase 3 — Pipelining clause

Walk the amended team-workflow rule 3 against the spec's three scenarios (US4) — each
must have one unambiguous answer in the text:

1. Feature awaiting review (all phases gate-green, pushed, review requested) → second
   claim permitted.
2. Feature mid-phase → second claim forbidden; one awaiting + one active → third claim
   forbidden.
3. Change requests arrive mid-phase on the second feature → text says: finish current
   phase to gate-green, then return to the first feature before any further phase.
4. `scripts/doc-lint.ps1` → exit 0.

## Phase 4 — Batched gate

1. Constitution shows version 0.4.0, SYNC IMPACT REPORT updated; the batching clause
   states: Lite/Standard only, declared in plan.md before the batch, max 3 consecutive
   phases, per-phase commit/scope-check/AI-review retained, Critical excluded.
2. Mirrors agree: `plan-template.md` Constitution Check X wording + `**Gate Batching**`
   line; `definition-of-done.md` gate 3; `gate-command.md` section; `critical-delivery.md`
   prohibition. No two documents state the rule differently (FR-011).
3. **Enforcement**: on a scratch branch, a plan with `Delivery Level: Critical` +
   `**Gate Batching**: phases 1-2` → `enforcement-pack.ps1` FAILS naming the rule
   (FR-009/SC-006); `phases 1-4` on a Standard feature → FAILS (span > 3);
   `**Gate Batching**: none` or an absent line → passes (backward compatible —
   run against `specs/001-*` and `specs/002-*` unchanged).
4. `scripts/doc-lint.ps1` and `scripts/enforcement-pack.ps1` → exit 0 on this feature's
   own branch (which itself declares no batch).
