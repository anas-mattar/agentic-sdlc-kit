# Quickstart: Law Digests — validation script

Per-phase seeded scenarios; executed at each phase's gate (agent feedback runs) and
recorded under "Phase validation records" in tasks.md.

## Phase 1 — the machine (contract C1–C12)

Seeded fixtures in a scratch clone OUTSIDE the repo (deleted after): a fixture manifest +
two fixture docs with markers, then each contract row's mutation; run
`build-digests.ps1` / `build-digests.ps1 -Check` / `ritual-checks.ps1` per scenario and
record verdict quotes. Also record D7's verification: what update-kit actually does with
a `generated`-class entry (must not copy; report-only or skip both acceptable — quote the
run) — plus a kit self-run of ritual-checks showing the `digests` member reporting n/a
(no markers exist until phase 2).

## Phase 2 — the content (checklist L)

- **L1** Every pack document carries markers beside its binding rules; each one-liner
  agrees with the rule text it sits beside (spot-verified quote pairs recorded for at
  least two rules per pack).
- **L2** All five digests generated and committed; each ≤ 40 content lines, header
  present (generated notice + regeneration command + non-authoritative + full-read rule),
  every bullet carries its source path.
- **L3** `build-digests.ps1 -Check` OK; re-run byte-stable; ritual-checks RESULT OK with
  `digests` member OK (no longer n/a).
- **L4** Drift tripwire live on the kit itself: mutate one marker, check FAILs naming the
  digest + fix command; revert, check OK (recorded quotes).

## Phase 3 — the sweep (checklist W)

- **W1** CLAUDE.md Task-Scoped Reading offers each pack's digest as the orientation read
  and keeps the full documents as the acting read; always-load row unchanged.
- **W2** updating.md flow-down note: generator + manifest verbatim; digests never flow
  (generated class); adopted projects opt in by adding markers to their OWN documents and
  generating; inert until then.
- **W3** roadmap GAP-014 → in progress; ritual-checks RESULT OK.
- **W4** Authority sweep: no shipped instrument presents a digest as a source-of-truth
  rung or as satisfying a "read first" obligation when ACTING on an area.

## Batch-end certification (ci-held — plan declaration)

After phase 3's commit: push; cite the push-event `ritual-checks` run on the batch-end
commit (URL + green conclusion + sha) and request the owner's recorded approval
(gate-command.md worked example). The agent never claims success.
