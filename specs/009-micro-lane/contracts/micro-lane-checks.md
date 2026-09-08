# Contract: Micro-lane machine checks

Contract for the phase-2 amendments to `scripts/scope-check.ps1` and
`scripts/enforcement-pack.ps1`. Verified by seeded fixtures (quickstart) at the phase gate
and re-verified by the fresh-context review.

## Inputs

- Branch `NNN-*`; `specs/NNN-name/spec.md` read comment-stripped at the relevant commit's
  parent (declarations) or branch tree (structure). Absent spec.md or absent
  `**Delivery Level**` field ⇒ NOT Micro ⇒ zero new behavior (M1).

## Scenarios

| # | Fixture state | Expected verdict |
|---|---|---|
| M1 | Standard feature, no Delivery Level field (001–008 shape) | all verdicts unchanged (regression) |
| M2 | `Delivery Level: Micro`, mini-spec with Territory (3 files), one `phase 1` commit inside territory | scope-check PASS (territory read from spec.md); enforcement-pack OK |
| M3 | Micro, phase commit touches a file outside the spec.md Territory | scope-check FAIL (same semantics as tasks.md territory) |
| M4 | Micro, Territory widened in the phase commit itself | scope-check FAIL — declaration read from the commit's parent (anti-widening) |
| M5 | Micro, Territory lists more than MicroTerritoryMaxFiles (5) | enforcement-pack FAIL naming the cap + promotion |
| M6 | Micro, second `phase 2` commit | enforcement-pack FAIL — one phase; promote to Standard first |
| M7 | Micro branch also carrying plan.md (or tasks.md) | enforcement-pack FAIL — halfway promotion is illegal |
| M8 | Micro spec.md carrying `**Gate Batching**: phases 1-2` | enforcement-pack FAIL — nothing to batch |
| M9 | Micro spec.md carrying `**Gate Certification**: ci-held`, Standard-legal otherwise | GateCertification OK — declaration read from spec.md on Micro |
| M10 | `Delivery Level: Micr0` (malformed) | enforcement-pack FAIL naming legal values |
| M11 | Promotion commit (full spec.md level Standard + plan.md + tasks.md), then `phase 2` commit in tasks.md territory | all checks OK — Standard rules from the promotion commit onward; M2-era `phase 1` commit still attributed against the old spec.md Territory (parent-read) |
| M12 | Micro, single phase commit over MicroPhaseMaxLines (400) | enforcement-pack FAIL (hard bound on Micro; PhaseSizeWarning behavior elsewhere unchanged) |
| M13 | Commented-out `Delivery Level: Micro` decoy inside an HTML comment block | not Micro — shared comment-stripping parser (008 G7–G9 precedent) |

## Error-message contract

Every Micro FAIL names: the violated bound (with its configured value), and the remediation
— "promote to Standard: expand spec.md to the full template, add plan.md + tasks.md
(Territory moves there), in a commit before the next phase commit" — or "shrink to the
declared bounds". Malformed values name the legal set.

## Non-goals

No check of the non-measurable eligibility items (schema/packages/architecture/domain/
visual-reference) — checklist-affirmed, human-reviewed (parity with plan.md promises).
No change to Lite branches, claims, numbering, provenance checks, or the adoption doctor.
