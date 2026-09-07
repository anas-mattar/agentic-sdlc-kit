# CLI Contract: scripts/verify-kit.ps1

**Purpose**: read-only audit of an adopted project's kit integrity across the five
dimensions in data-model.md, every failure reported in one run with a fix pointer
(spec FR-001, FR-002, FR-008).

## Invocation

```powershell
pwsh -File scripts/verify-kit.ps1 [-Root <path>] [-Json]
```

| Parameter | Default | Meaning |
|---|---|---|
| `-Root` | repo root of the script | Project to audit — update-kit passes the target's root; the script must work when its own copy lives in a different repo than `-Root` |
| `-Json` | off | Machine-readable verdict (findings array + summary) in addition to nothing else on stdout |

## Behavior

1. **Decline check** (research D5.1): `-Root` is the kit template itself → print
   `verify-kit: not applicable (this is the kit template, not an adoption)`, exit 0.
2. Run all five dimensions (data-model.md), never short-circuiting — one run reports
   every problem (ritual-checks wrapper precedent).
3. Findings print as `verify-kit: FAIL <dimension>: <detail> — fix: <adoption step/doc>`;
   warnings as `verify-kit: WARN …` with instructions; healthy dimensions one `ok` line
   each.
4. Summary: `verify-kit: OK — adoption integrity verified` or
   `verify-kit: FAIL (<n> failure(s), <m> warning(s))`.

## Exit codes

| Condition | Exit |
|---|---|
| No FAIL findings (warnings allowed — grandfather posture) | 0 |
| ≥1 FAIL finding | 1 |
| Decline (kit repository) | 0 |
| Execution error (unreadable root, malformed manifest) | 1 with `verify-kit: ERROR <reason>` |

## Guarantees

- **Read-only**: never writes, repairs, or creates files in the audited project (FR-008).
- Deterministic: same tree ⇒ same output; no network; git + built-ins only.
- Identical verdicts wherever run (local, init-end, update-end, ritual-checks/CI).

## Seeded-fixture acceptance (quickstart.md; run at phase gates)

- V1 healthy adopted fixture → all dimensions ok, exit 0.
- V2 missing kit essential (e.g. `.specify/templates/` deleted) → FAIL dim 1 naming path.
- V3 unfilled `{{GATE}}` slot in `docs/sdlc/gate-command.md` → FAIL dim 2 naming file+marker.
- V4 constitution with `TODO(RATIFICATION_DATE)` → FAIL dim 3.
- V5 record declares `frontend` but `docs/rulebooks/frontend-rules.md` deleted → FAIL dim 4 naming tier+path.
- V6 record present, `gateProof: []` → FAIL dim 4 (proof required post-record).
- V7 no `kit-adoption.json` at all (pre-007 adoption) → WARN dim 4 with creation instructions, exit 0 (if nothing else broken).
- V8 `.kit-version` containing garbage → FAIL dim 5; absent → WARN dim 5.
- V9 kit repository itself → decline message, exit 0, zero findings.
- V10 three breaks at once → all three named in one run.
