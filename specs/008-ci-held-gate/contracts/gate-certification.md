# Contract: Gate Certification (declaration · evidence · machine check)

**Purpose**: the complete rule set for CI-held gate certification — what a plan may
declare, what evidence certifies, what the machine rejects (spec FR-001–FR-005).

## Declaration (plan.md header)

```markdown
**Gate Certification**: user-run
**Gate Certification**: ci-held
```

- Absent line ⇒ `user-run`. Legal values exactly those two (case-sensitive, comment
  stripped). Declared in the approved plan before the first governed phase.
- Composes with `**Gate Batching**`: under `ci-held`, a batch is certified by one owner
  approval on the batch-end commit's evidence.

## Certification semantics

| Mode | Gate 3 is satisfied by |
|---|---|
| `user-run` (default) | today's law, unchanged: the owner runs the gate and confirms the exit code (batched option unchanged) |
| `ci-held` (Lite/Standard only) | the owner's **recorded approval** citing the evidence triplet — run URL + green conclusion + exact phase-commit sha — in the feature's phase record |
| Critical | ALWAYS user-run, per phase, no agent runs, no batching, no ci-held — unchanged and machine-enforced |

Invariants preserved in both modes: the agent never claims success (under `ci-held` it
reports the triplet and requests approval); user-run evidence is always lawful regardless
of declaration; approval is per phase (or per declared batch), never blanket.

## Machine check (enforcement pack, `NNN-*` branches)

| Seeded scenario | Verdict |
|---|---|
| G1 Standard plan, no declaration | pass (user-run) |
| G2 Standard plan, `user-run` | pass |
| G3 Standard plan, `ci-held` | pass |
| G4 Critical spec, plan declares `ci-held` | FAIL citing constitution X's CI-held exclusion |
| G5 plan declares `ci-hold` (malformed) | FAIL naming legal values `user-run`/`ci-held` |
| G6 declaration with trailing HTML comment | value parsed correctly (Gate Batching idiom) |

## Project-gate workflow template

`.github/workflows/project-gate.yml.template` — inert in the kit (`.template`), copied by
adopters to `project-gate.yml`, slots `{{GATE_CHAIN}}` / `{{GATE_WORKDIR}}` filled per
gate-command.md. Runs the project gate on pushes to governed branches; the run page shows
command, conclusion, sha — the triplet's source. Kit repo's own evidence source is the
`ritual-checks` run (research D5). Manifest: specific surgical row for the template path
(out-ranks `.github/**` verbatim under most-specific-wins).

- W-G1: fixture instantiation — copy, fill a real chain, push a governed branch → run
  carries command + conclusion + sha.
- W-G2: kit repo — the `.template` file never appears as a workflow run.
