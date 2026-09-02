# Research: Kit-Update Channel

## D1 — Manifest format and location

**Decision**: `kit-manifest.json` at the kit root. Shape: a `version` field for the
manifest schema itself, plus `entries`: array of `{ "path": "<path or glob>", "class":
"verbatim" | "surgical", "reason": "<surgical only>" }`. Anything not matched by an
entry does not ship (kit-internal by omission), with the shipped surfaces enumerated in
the completeness check, not the manifest.

**Rationale**: JSON parses natively in PowerShell (`ConvertFrom-Json`), needs no
dependency, and is readable by any future tooling. Root placement lets the update
script resolve it relative to its own location and ships it into adoptions like any
other kit file. The improvement-proposal review's rejected YAML manifest was a
doc-*reading* manifest duplicating the Task-Scoped Reading table; this is file-transport
classification with no reading semantics — the earlier rejection does not apply.

**Alternatives**: .psd1 (PowerShell-only, unfriendly to other tooling); a markdown table
(human-first, brittle to parse); classifying inside doc-lint config (hides the manifest
from adoptions, which need it to self-report drift).

## D2 — Kit version identity and the project-side record

**Decision**: kit version = the kit constitution's version string (parsed from the
`**Version**:` footer) + the kit's HEAD commit sha at update time. Project record =
`.kit-version` JSON at the adopted project root: `{ "kitVersion", "kitCommit",
"updatedOn" }`, written by every successful update run.

**Rationale**: The constitution version already advances with every governance
amendment (the changes adoptions care about), and the commit sha gives `git log`/`git
show` an exact baseline — no new release ceremony (spec assumption). A dotfile keeps it
out of doc-lint's scanned trees.

**Alternatives**: git tags (ceremony the kit doesn't have); a version file maintained by
hand (drifts); embedding the record in the project constitution (pollutes ratified law).

## D3 — Update script invocation model

**Decision**: `scripts/update-kit.ps1` runs FROM the kit clone (default `-Kit` = the
script's own repo root) with `-Target <adopted project root>` required. Preflight
refuses when: Target resolves to the Kit root (FR-007); Target is missing kit-integrity
essentials (delegate the definition to the same required-paths list doc-lint uses);
Target's git working tree is dirty (updates land reviewable, on a clean tree).
`-DryRun` prints the full report without writing; `-Force <path[]>` takes the kit
version of specific conflicted verbatim files (FR-004's explicit opt-in).

**Rationale**: Running from the kit guarantees access to the kit's git history for
baselines and reports (D5/D6); requiring `-Target` makes accidental self-update
impossible even before the preflight.

**Alternatives**: running from the project against `-Kit` (works, but the project copy
of the script may itself be stale — the kit-side copy is always current); a copied
standalone updater in each adoption (self-update paradox).

## D4 — Change detection and line endings

**Decision**: compare normalized text — read both files, normalize `\r\n` → `\n`,
compare strings (hash of normalized content for the report). Binary-safe fallback: if a
file fails text reading, compare raw bytes.

**Rationale**: FR-008 — Windows working copies are CRLF (every commit this week warned
about it); byte or git-hash comparison would report every file changed forever.

**Alternatives**: `git hash-object` on both sides (still CRLF-sensitive across repos
with different autocrlf); enforcing .gitattributes in adoptions (out of scope, invasive).

## D5 — Detecting local modification of verbatim files

**Decision**: baseline = the kit's own content at the project's recorded `kitCommit`
(`git -C <kit> show <kitCommit>:<path>`, normalized per D4). A verbatim target file is:
**unchanged** (target == kit HEAD → skip), **cleanly updatable** (target == baseline ≠
HEAD → copy), or **conflicted** (target ≠ baseline and ≠ HEAD → skip + report, FR-004).
No record (pre-004 adoptions): no baseline exists, so any target ≠ HEAD is reported as
"differs — no baseline" and skipped; the run still writes `.kit-version`, so the next
run has a baseline (FR-005 degraded path).

**Rationale**: The kit's git history is always present in the clone the script runs
from — no per-file hash bookkeeping in the project, and the three-way logic is the
minimal correct merge-avoidance.

**Alternatives**: storing per-file hashes in `.kit-version` (duplicate of git state,
grows stale); overwriting with backup files (litter, and silently loses the signal that
someone edited a kit-owned file).

## D6 — Surgical report content

**Decision**: for each surgical-class entry, if `git -C <kit> log <kitCommit>..HEAD --
<path>` is non-empty, report the file, the one-line commits touching it, and the
standing pointer: constitution amendments are described in the constitution's SYNC
IMPACT REPORT; procedure in `adoption/updating.md`. No record → list every surgical file
once with "no baseline — review all" (FR-005).

**Rationale**: The kit's commit messages are already the amendment log (house
convention); reusing them costs nothing and is always current.

## D7 — Where the completeness check lives

**Decision**: extend `scripts/doc-lint.ps1` (a "manifest" section after kit-integrity):
enumerate the kit's shipped surfaces (`CLAUDE.md`, `AGENTS.md`, `README.md`,
`.specify/memory/constitution.md`, `.specify/templates/**`, `.specify/scripts/**`,
`.claude/commands/**`, `docs/**`, `adoption/**`, `modules/**`, `specs/_templates/**`,
`scripts/*.ps1`, `.github/**`, `kit-manifest.json`) and fail when any shipped file
matches no manifest entry or more than one class (FR-002). Kit-internal trees
(`specs/NNN-*`, `review/`, `docs/roadmap.md`) are excluded from the shipped surfaces
by the same enumeration.

**Rationale**: doc-lint is already the kit's integrity checker, runs in the kit's CI on
every branch, and adoptions carry it — one surface, per the kit's encode-gaps lesson.

**Alternatives**: a separate check script (one more thing to wire into CI);
enforcement-pack (wrong scope — it checks branch/diff law, not repository integrity).
