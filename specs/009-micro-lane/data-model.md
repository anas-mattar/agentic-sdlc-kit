# Data Model: Micro Delivery Lane

No database — the "data" is declaration grammar in markdown and check behavior in
PowerShell.

## Delivery level declaration (mini-spec header)

```text
**Delivery Level**: Micro
```

- Lives in `specs/NNN-name/spec.md`. Read comment-stripped (`Get-VisiblePlanLines` idiom),
  first visible match wins, case-insensitive value.
- Legal values for the field anywhere: `Lite` (never on numbered features — Lite has no
  spec dir), `Micro`, `Standard`, `Critical`. On a numbered branch: `Micro`, `Standard`,
  `Critical`; **absent field or absent spec.md ⇒ Standard behavior** (backward compatible —
  every pre-009 feature).
- `Micro` switches: territory source (below), the MicroLane bounds, and the
  GateCertification declaration source to spec.md.

## Gate Certification on Micro

```text
**Gate Certification**: user-run | ci-held
```

Same grammar as plan.md (008 contract, case-insensitive, comment-stripped, empty = absent,
absent = `user-run`) — read from **spec.md** when the branch is Micro, from plan.md
otherwise. Critical exclusion unchanged.

## Territory on Micro

Same block format scope-check already parses (one contiguous backtick-wrapped list under
`**Territory**:`), but located in **spec.md** and not under a phase heading (Micro has
exactly one phase; the block is feature-global). Read from the phase commit's **parent**
(anti-widening preserved). `specs/NNN-name/**` stays implicitly in territory and does not
count against the cap.

## Eligibility bounds (constitutional constants, enforcement-pack $Config)

| Constant | Proposed value | Enforced as |
|---|---|---|
| MicroTerritoryMaxFiles | 5 | FAIL when the declared Territory lists more entries/expands to more files |
| MicroPhaseMaxLines | 400 | FAIL (not warn) when the phase's commits exceed it in total (summed across every commit carrying the phase token — owner-resolved phase 2 review F1) |
| MicroMaxPhases | 1 | FAIL on a second `phase N` commit while the branch is Micro |

Non-measurable bounds (no schema/migration, no new packages, no architecture change, no
domain-invariant surface, no visual-reference UI) are checklist-affirmed in the mini-spec
and human-reviewed — parity with how plan.md's package/architecture promises are policed.

## MicroLane check behavior (enforcement pack)

| Condition on a `NNN-*` branch | Verdict |
|---|---|
| spec.md absent or no Delivery Level field | not Micro — no MicroLane rules apply |
| `**Delivery Level**: Micro` + plan.md or tasks.md present in the tree | FAIL — promotion is all-or-nothing (full set + level Standard) |
| Micro + `**Gate Batching**` line in spec.md | FAIL — one phase, nothing to batch |
| Micro + >1 `phase N` commit on the branch | FAIL — promote to Standard before further phases |
| Micro + Territory over MicroTerritoryMaxFiles | FAIL naming the cap and promotion |
| Micro + the phase's commits over MicroPhaseMaxLines in total | FAIL (hard bound on Micro; per-commit warning elsewhere unchanged) |
| Malformed Delivery Level value | FAIL naming legal values |
| Micro, all bounds held | OK |

Every FAIL's remediation text names the promotion procedure (research D5).

## Promotion (state transition)

`Micro → Standard`, one-way, in place: spec.md expanded to the full template (level
re-declared Standard), plan.md + tasks.md added (Territory moves under phase headings),
committed **before** any further phase commit. After promotion the branch is an ordinary
Standard feature; Micro-era commits keep their attribution (scope-check reads each commit
against its parent's declaration — the history stays green).

## Mini-spec template (`.specify/templates/micro-spec-template.md`)

Sections, one page: header (branch/date/status/`Delivery Level: Micro`/optional Gate
Certification) · Intent (what + why, a few sentences) · Acceptance checks (numbered,
testable) · Eligibility checklist (the non-measurable bounds, owner-affirmed at approval)
· **Territory** block · Rollback note (one line: revert the phase commit). Verbatim class
via the existing `.specify/templates/**` manifest glob.
