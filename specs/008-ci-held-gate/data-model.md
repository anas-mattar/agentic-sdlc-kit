# Data Model: CI-Held Certifying Gate

All state is law text and one plan-header declaration; no new files or records.

## Gate Certification declaration (in `plan.md`)

| Aspect | Rule |
|---|---|
| Field | `**Gate Certification**: <value>` header line (Gate Batching's shape; trailing HTML comment stripped before parsing) |
| Legal values | `user-run` (default) · `ci-held` |
| Absent line | means `user-run` — every pre-008 plan stays compliant |
| Timing | declared in the approved plan before the first phase it governs; never retroactive |
| Exclusion | a Critical feature declaring `ci-held` fails the enforcement pack |

## Evidence triplet (defined in `docs/sdlc/gate-command.md`)

| Element | Rule |
|---|---|
| Run URL | the CI run of the **project gate** (adopted projects: the project-gate workflow; the kit itself: `ritual-checks`) |
| Conclusion | green/success; a red-then-green re-run pair on the same sha certifies, visibly |
| Commit sha | the **exact phase commit** (batch: the batch-end commit) — a run on any other sha certifies nothing |

All three elements together, cited in the owner's recorded approval, constitute
certification under `ci-held`. Anything less does not certify.

## Approval-on-evidence record

Lives in the feature's existing phase record (PR conversation / phase notes) — no new
artifact. Worked example (ships in gate-command.md):

> Gate 3 certified (ci-held): run <URL>, conclusion success, commit `abc1234`
> (phase 2) — approved, <owner>, <date>.

Deliberately not machine-checked (parity with gate 6 — human layers audited by humans).

## Enforcement check (`GateCertification`, phase 2)

| Input state | Verdict |
|---|---|
| No declaration line | pass (user-run default) |
| `user-run` | pass |
| `ci-held` + Delivery Level Lite/Standard | pass |
| `ci-held` + Delivery Level Critical | FAIL citing constitution X's exclusion |
| any other value | FAIL naming the legal values |

## Project-gate workflow template (`.github/workflows/project-gate.yml.template`)

Slot-bearing (`{{GATE_CHAIN}}`, `{{GATE_WORKDIR}}`), inert in the kit repo (`.template`
suffix), **surgical** manifest class via a specific row out-ranking the `.github/**`
verbatim glob; adopters copy to `project-gate.yml` and fill (gate-command.md wiring
instructions). Secrets belong in the CI secret store, never in the file or the recorded
evidence.
