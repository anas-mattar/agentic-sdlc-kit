# Data Model: Verification Pack

All state is files in the repository; "entities" are document structures and script verdicts.

## Territory declaration (in `tasks.md`)

| Field | Form | Rules |
|---|---|---|
| Phase anchor | `## Phase N:` heading | Declaration binds to the nearest preceding phase heading |
| Marker | `**Territory**:` line | Exactly one per phase; absent ⇒ `warning-undeclared` for that phase's commits (backward compatible) |
| Entries | list items, one path/glob each, backtick-wrapped | Repo-relative; PowerShell `-like` glob semantics (`*`, `**` treated as `*` across separators); may repeat across phases (overlap legal) |
| Implicit entry | `specs/NNN-name/**` | Always in territory; never needs declaring |

**Validation**: entries must not be absolute paths and must not contain `..`. An empty list
after the marker is invalid (declare the marker only with entries).

**State transitions**: a declaration may be amended only by a commit that precedes the phase
commit relying on it (enforced by parent-read, research D3).

## Scope verdict (per phase commit)

| Verdict | Meaning | Exit contribution |
|---|---|---|
| `pass` | Every changed path matches the phase's territory (or implicit entry) | 0 |
| `fail` | ≥1 undeclared path; each is named with the phase and declaration quoted | non-zero |
| `warning-undeclared` | `NNN-*` branch, but no territory for the phase / no parseable phase token | 0, warning printed |
| `not-applicable` | Lite-lane branch (`fix/`, `chore/`, `docs/`) or non-phase commit | 0 |

Rename = both old and new path must be in territory; delete = deleted path must be in territory.

## Reviewer Provenance block (in each AI review document)

```markdown
## Reviewer Provenance

- **Reviewer**: fresh-context agent — <model id> | second model — <model id>
- **Implementer**: <model id / session of the agent that produced the diff>
- **Inputs provided**: phase N diff, spec.md, plan.md[, tasks.md]
- **Attestation**: This reviewer did not produce the diff under review.
```

**Machine-checked** (enforcement pack, on review files *added* in the branch diff — research D4):
section heading present; `Reviewer:` line present, non-empty, not `implementer`; attestation
sentence present verbatim. **Human-audited**: the truth of the attestation.

## Ritual check run (CI or local)

| Field | Value |
|---|---|
| Entry point | `scripts/ritual-checks.ps1` (identical local and CI — research D5) |
| Members | doc-lint → enforcement-pack → scope-check (every phase commit since merge-base) |
| Verdict block | one line per member: `ritual-checks: <member> OK/FAIL/WARN` + member output above |
| Exit code | 0 iff every member exits 0 |

## Kit-manifest classification (new rows)

| File | Class |
|---|---|
| `scripts/scope-check.ps1` | verbatim |
| `scripts/ritual-checks.ps1` | verbatim |
| `.github/workflows/ritual-checks.yml` | verbatim |
| (amended) `.specify/templates/tasks-template.md`, `specs/_templates/ai-code-review-template.md`, `scripts/enforcement-pack.ps1`, `docs/sdlc/*.md` | keep existing classification |
