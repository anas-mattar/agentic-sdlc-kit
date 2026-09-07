# CLI Contract: scripts/scope-check.ps1

**Purpose**: mechanically verify that a phase commit's diff stays inside the territory the
feature's `tasks.md` declared for that phase (DoD gate 4; spec FR-002–FR-004).

## Invocation

```powershell
pwsh -File scripts/scope-check.ps1 [-Commit <sha>] [-Phase <int>] [-Branch <name>] [-All] [-Root <path>]
```

| Parameter | Default | Meaning |
|---|---|---|
| `-Commit` | `HEAD` | The phase commit to check (diffed against its first parent) |
| `-Phase` | parsed from commit subject (`phase N` token, research D2) | Overrides phase attribution |
| `-Branch` | current branch | Used only to classify the lane (`NNN-*` vs Lite) |
| `-All` | off | Check every commit from `merge-base HEAD origin/main` to `HEAD` (CI mode); ignores `-Commit` |
| `-Root` | repo root of the script | Repository to operate in |

## Behavior

1. Lane classification: on `fix/*`, `chore/*`, `docs/*` → print `scope-check: not applicable
   (<lane> lane)` and exit 0.
2. Resolve the feature directory from the branch name (`NNN-name` → `specs/NNN-name/`).
3. Read `tasks.md` from the commit's **parent** (`<commit>^:`), falling back to `<commit>:`
   when the parent lacks the file (the claim commit) — research D3.
4. Parse the `**Territory**:` list for the attributed phase (data-model rules).
5. Compare every changed path (renames: both sides; deletes: the deleted path) against the
   territory plus the implicit `specs/NNN-name/**` entry.

## Output & exit codes

| Condition | Output (one line per item) | Exit |
|---|---|---|
| All paths declared | `scope-check: PASS phase <N> commit <sha7> (<n> file(s))` | 0 |
| Undeclared path(s) | `scope-check: FAIL phase <N> commit <sha7>: <path> not in territory` per stray + remediation hint (revert the change, or amend tasks.md territory in a prior commit) | 1 |
| No territory declared / no phase token | `scope-check: WARN commit <sha7>: <reason> (declare territory in tasks.md — non-blocking, pre-006 compatibility)` | 0 |
| Not applicable | `scope-check: not applicable (<reason>)` | 0 |
| `-All` mode | verdict per commit; exit non-zero iff any commit FAILs | 0/1 |

## Guarantees

- Never writes to the repository; read-only over git history.
- Identical verdicts locally and in CI (invoked by `ritual-checks.ps1` both places).
- Deterministic: same repo state ⇒ same output.

## Seeded-violation acceptance (run at the phase gate — quickstart.md)

- S1: commit touching only declared paths → PASS, exit 0.
- S2: commit adding one undeclared file → FAIL naming exactly that file, exit 1.
- S3: territory widened in the same commit as the stray file → still FAIL (parent-read).
- S4: territory widened in a prior commit, then stray file committed → PASS.
- S5: `fix/*` branch → not-applicable, exit 0.
- S6: `NNN-*` commit without phase token → WARN, exit 0.
