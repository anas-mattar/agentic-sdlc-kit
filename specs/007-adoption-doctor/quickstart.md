# Quickstart: Adoption Doctor

Seeded fixture scenarios — the feature's deterministic validation (constitution VIII;
002/006 precedent). Build the fixture once per validation round in a scratch directory
(never inside the kit repo): copy the kit tree, run
`pwsh -File scripts/init-kit.ps1 -ProjectName Demo -Topology single -Tiers backend,database -DeleteUnusedTemplates -NonInteractive`
(post-phase-2 this also writes `kit-adoption.json`), fill the judgment slots with dummy
values, add a `gateProof` exit-0 entry, create `.kit-version` with a plausible sha.
Scenario table = contracts/verify-kit-cli.md V1–V10; each row is run by breaking one
thing, running the doctor, recording verdict + exit, and restoring.

## Phase 1 (doctor alone)

Run V1–V10 with a hand-built fixture (init-kit not yet amended: create
`kit-adoption.json` manually per data-model.md). Fail paths first (V2–V6, V8-garbage,
V10), then healthy V1, then the grandfather/decline rows (V7, V8-absent, V9).

## Phase 2 (lifecycle hooks)

| # | Do | Expect |
|---|---|---|
| L1 | Fresh kit copy → `init-kit.ps1 … -NonInteractive` | `kit-adoption.json` written with exactly the chosen name/topology/tiers, `gateProof: []`; init output ends with the doctor verdict (red: open judgment slots + missing proof listed as the to-do); init exit 0 |
| L2 | Fill slots + record proof in the fixture → re-run doctor | OK, exit 0 |
| L3 | `update-kit.ps1 -Target <fixture>` after a kit change | apply report ends with the target's doctor verdict; clean apply + green doctor → exit 0 |
| L4 | Same, but fixture has a broken dimension | report ends with red verdict; exit 2 (attention needed) |
| L5 | `update-kit.ps1 -DryRun` | no doctor run, no writes (unchanged dry-run semantics) |
| L6 | Owner adds tier `frontend` to `kit-adoption.json` + instantiates the rulebook | doctor OK (record is owner-editable — US2 scenario 2) |

## Phase 3 (wrapper membership)

| # | Do | Expect |
|---|---|---|
| W1 | `ritual-checks.ps1` in the kit repo | fourth member line `verify-kit  n/a (kit repository)`; RESULT unchanged by it |
| W2 | `ritual-checks.ps1 -Root <adopted fixture>` — healthy | `verify-kit OK`, RESULT OK |
| W3 | Same with one broken dimension | `verify-kit FAIL`, RESULT FAIL, other members still ran |

## Phase gates

Phases 1–3 batched (plan.md): agent runs the phase's scenarios + ritual-checks per phase
and reports; owner certifies once at batch end (`pwsh -File scripts/ritual-checks.ps1`,
expect RESULT OK / exit 0, plus spot-checks V2, V5, L4 — the fail paths are the product).
Phase 4: owner runs ritual-checks alone.
