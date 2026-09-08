# Quickstart: CI-Held Certifying Gate

Seeded scenarios — the feature's deterministic validation (constitution VIII; kit
convention). Law scenarios are read-verified against the amended texts; check scenarios
run against seeded fixture plans; the template scenario instantiates in a scratch fixture.

## Phase 1 (the law)

Read-verification checklist, recorded with quotes in the validation record:

| # | Assertion | Where |
|---|---|---|
| L1 | X's CI-held clause states: Lite/Standard only · plan declaration required · owner approval on the triplet · agent obligations unchanged · Critical excluded · absent = user-run | constitution X |
| L2 | SYNC IMPACT entry: 0.4.1 → 0.5.0 MINOR, rationale, mirror list incl. the phase-2 enforcement half | constitution header |
| L3 | Gate 3 carries the ci-held option with identical boundaries | definition-of-done.md |
| L4 | Evidence triplet + worked approval-record example + kit's-own-evidence note (`ritual-checks`) + re-run visibility rule | gate-command.md |
| L5 | Critical exclusion mirrored | critical-delivery.md item list |
| L6 | Plan template ships the field (`user-run` default) and the X check row mentions certification mode | plan-template.md |
| L7 | CLAUDE.md strict rule: never claim success; under ci-held, report the triplet + request approval | CLAUDE.md |
| L8 | doc-lint + ritual-checks green after the amendment commit | run |

## Phase 2 (the machine check)

Contract G1–G6 on seeded fixture plans (throwaway `999-*` branch or scratch tree):
no-declaration pass · `user-run` pass · `ci-held` on Standard pass · `ci-held` on
Critical FAIL · malformed value FAIL · comment-carrying line parsed. Plus regression:
enforcement-pack on this branch and on 001–007 specs stays green (absent lines
everywhere).

## Phase 3 (the template)

- W-G1: scratch fixture — copy `project-gate.yml.template` → `project-gate.yml`, fill
  `{{GATE_CHAIN}}` with a trivial real command, verify YAML validity and that the filled
  copy would trigger on governed branches (static read; a live push needs a remote
  fixture repo — static verification + the kit's own ritual-checks precedent accepted).
- W-G2: kit repo — `.template` file present, no workflow named project-gate ever runs
  (check `gh workflow list`).
- W-G3: manifest — doc-lint classifies the template as surgical (specific row wins over
  `.github/**` verbatim); update-kit would report, not clobber, a modified copy (resolve
  via `Get-ManifestClass` semantics — read-verified).

## Phase gates

Phases 1–3 batched (plan.md): agent runs each phase's scenarios + ritual-checks and
reports; owner certifies once at batch end — **under the current user-run law** (this
feature does not certify itself with the mode it introduces; research D7). Phase 4:
owner runs ritual-checks alone.
