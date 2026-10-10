# Notes: Level Declaration Graded

Evidence and decisions that belong beside the feature but not in its approved documents.

## Approval record — 2026-10-11

The owner (anas.m) approved the spec and the plan on 2026-10-11. The Draft to Approved flip on
`spec.md` is the act that starts the amendment rule (constitution I); it is committed alone
so the status-only exemption applies as written.

What the approval covers:

- `spec.md` as committed in eb4e071, including its Edge Cases note on decorated Territory
  markers, which `research.md` R3 records as stale. The note is approved as written; it changes
  no behaviour, because an unreadable Territory is UNGRADED either way. It is not amended here.
- `plan.md` as committed in 26f72d6: decisions D1 to D9, the five-phase order, and
  `**Gate Certification**: user-run` (this feature changes enforcement scripts).
- `tasks.md` as committed in 60719c2, with each phase's Territory.
- D1's consequence: phase 1 amends constitution Principle X (0.7.0 to 0.8.0). That amendment
  needs its own approval at T006 before phase 2 begins. This approval does not stand in for it.

## Phase 1

Written 2026-10-11. T001-T005 were implemented and checked before the commit: `doc-lint` OK,
`digests` OK (84 markers; one digest line shortened to the 120-character bound),
`enforcement-pack` OK. `scope-check` was UNGRADED until the phase commit existed, as expected.

T006: the owner (anas.m) approved the constitution 0.8.0 amendment on 2026-10-11; the
approval is recorded in the SYNC IMPACT REPORT ("Human adoption of this amendment").

Baseline for later phases: `tests/enforcement/Run-Tests.ps1` on the tree at `b82e362`,
before any phase 1 edit — 899 passed, 0 failed, 0 skipped (726 s).

Gate: the user-run gate exit code for this phase had not been reported when the phase was
committed; it is the owner's to certify (constitution X) and is not claimed here.
