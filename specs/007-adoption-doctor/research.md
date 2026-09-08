# Research: Adoption Doctor

Decisions pinning every open design question. No NEEDS CLARIFICATION markers remained in
the spec; the record/proof formats and checker boundaries were explicitly deferred here.

## D1 — The adoption record: one JSON file at the project root

**Decision**: `kit-adoption.json` at the adopted project's root, written by
`init-kit.ps1`, owner-editable thereafter:

```json
{
  "schemaVersion": 1,
  "projectName": "Expenses",
  "topology": "single",
  "tiers": ["backend", "database"],
  "initDate": "2026-09-08",
  "kitVersionAtInit": "<kit commit sha or 'copy'>",
  "gateProof": [
    { "gate": "backend", "command": "dotnet build && dotnet test",
      "exitCode": 0, "date": "2026-09-08", "recordedBy": "anas.m" }
  ]
}
```

The gate proof lives **inside** the record (FR-005), not in a second file: both are
"facts about this adoption a human attested", both are owner-edited, and one file is one
thing to grandfather. `gateProof` is an array (multi-repo projects prove per gate).

**Rationale**: JSON matches the kit's existing machine-read records (`kit-manifest.json`,
`.specify/init-options.json`); a root-level file is discoverable and cheap to document.
Owner-editable-by-hand is the kit philosophy (judgment stays human — recording a gate
proof is an attestation, so no helper writes it for you).

**Post-review amendments (phase 2 review)**: `kitVersionAtInit` = the kit constitution's
version string when init runs against the still-unratified kit-shipped constitution, else
`copy` (F3 — an adopted copy has no kit clone to ask for a sha, and after ratification the
constitution's version line is the *project's* semver, the wrong datum). Init **never
overwrites** an existing `kit-adoption.json` (F2 — the record carries the owner's
attestation; re-init keeps it, same semantics as instantiated rulebooks).

**Alternatives considered**: extending `.kit-version` (rejected: update-kit owns that file
wholesale and rewrites it every flow-down — owner edits would be clobbered); a markdown
record (rejected: the doctor must parse it reliably; prose invites drift); separate
gate-proof file (rejected: two files, two grandfather paths, no gain). Never audited the
kit itself, so the kit repo never carries `kit-adoption.json` and the manifest never
classifies it.

## D2 — Doctor/doc-lint boundary

**Decision**: doc-lint keeps exactly its current jobs (referenced-path resolution;
manifest completeness in the kit repo; slot *counting*). The doctor owns the
adoption-semantics checks: structure essentials (fail-fast on partial install), slot
completeness as a **failure** scoped to project-owned files, constitution ratification
fields, record/tier/proof checks, `.kit-version` sanity. The doctor does NOT invoke
doc-lint; in every context where both matter (ritual-checks, init-kit's finish) the
caller runs both as siblings.

The structure-essentials list is deliberately duplicated from doc-lint's
`$requiredKitPaths` with a header cross-note in **both** scripts ("keep in sync with…").

**Rationale**: the same file set fails for different reasons in the two tools (doc-lint:
"the kit shipped these"; doctor: "your adoption lost these — re-copy, see adoption step
0"), and the fix pointers differ. A shared include file for one 10-line list is more
machinery than the kit wants (no module imports by convention).

**Alternatives considered**: doctor shells out to `doc-lint -FailOnSlots` (rejected:
double-runs path checks in ritual-checks, and doc-lint's slot scan covers kit-template
files where slots are the product — wrong semantics for an adoption audit); extracting a
shared list file (rejected: new file class for 10 lines; the sync-note convention already
exists for enforcement-pack constants).

## D3 — Slot completeness scope: surgical-class files via the manifest

**Decision**: the doctor scans for `{{SLOT}}` / `TODO(` only in files the kit manifest
classifies as **surgical** (project-owned: CLAUDE.md, constitution, gate-command,
review/rollback/deployment docs, rulebooks, modules) and that exist in the target. Any
hit is a failure naming file, marker, and the adoption step that owns filling it.
Verbatim-class files are skipped (kit prose legitimately carries no slots after 006's
fixes; if one appears there it is update-kit's conflict problem, not the adopter's).

**Rationale**: the manifest is the single source of truth for ownership (spec assumption);
reusing it means a future re-classification automatically retargets the doctor.

**Alternatives considered**: scanning everything (rejected: false findings on
kit-template remnants the project never owned); a hand-kept file list (rejected: second
source of truth, the exact drift disease).

**Post-review amendment (phase 1 review, F1)**: "every existing surgical file" conflicted
with the spec's tier-menu edge case — the kit *ships* marker-bearing surgical prose a
by-the-book adoption keeps (the tier menu `docs/rulebooks/README.md`, every
`*-template.md`, and `modules/**` worked examples, which projects replace rather than
fill). Resolution, reported here per constitution II: dim 2 exempts exactly those three
shapes; **instantiated rulebooks stay scanned** — filling them is existing law (doc-lint
`-FailOnSlots` posture). A project storing its real domain pack under `modules/` escapes
the slot scan (accepted: the CLAUDE.md-declared invariants path is the canonical home).

## D4 — Constitution ratification check

**Decision**: the ratification dimension fails when the constitution still contains
`TODO(RATIFICATION_DATE)` or `TODO(PROJECT_NAME)` markers or an unfilled `{{...}}` slot;
it does not parse or validate the version number (any filled `**Version**:` line
passes). Spec US1 scenario 3 pins this: filled ⇒ pass regardless of version value.

**Rationale**: ratification is a human act; the machine can only verify the paperwork of
it. Version-number semantics belong to the amendment procedure, not an audit.

## D5 — `.kit-version` sanity and the decline rule

**Decision**: discriminator logic, in order:

1. Target has `kit-manifest.json` + `specs/_templates/` + **no** `.kit-version` **and**
   `docs/roadmap.md` names the kit itself → decline: "this is the kit template, not an
   adoption" (FR-002), exit 0 with the decline message (not a finding).
2. Target has `.kit-version` → audit. Sanity = file parses to a non-empty version/commit
   token; a value that is not a 40-char sha and not a tag-like token is a finding
   ("hand-edited?").
3. Target looks adopted (slots filled / `kit-adoption.json` present) but has no
   `.kit-version` → audit anyway, with a warning naming the documented instruction to
   create it (spec assumption: copy-only adoptions).

**Rationale**: `.kit-version` stays the discriminator (doc-lint precedent) but its
absence alone must not hide a real adoption from the audit — the copy-only case is
exactly a partial-install risk.

## D6 — Lifecycle hooks and exit semantics

**Decision**: `init-kit.ps1` writes `kit-adoption.json` (gateProof empty) and finishes by
running the doctor **instead of** bare doc-lint, printing the verdict; init still exits 0
when the only findings are the expected open judgment items — the doctor's output is the
to-do list, and init's own success is "mechanical work done". `update-kit.ps1` apply mode
ends by running the kit clone's doctor with the target as root and folding the verdict
into the report; a red doctor on an otherwise clean apply exits **2** ("attention
needed" — within the documented code's meaning; clean stays 0 only when the doctor is
green or declined). DryRun never runs the doctor (zero side effects and the target is
untouched anyway — nothing new to audit).

**Rationale**: init-end red is expected (spec edge case) so it must not fail init;
update-end red is precisely "attention needed", the code that already means that.

**Alternatives considered**: init exits non-zero on doctor red (rejected: would make
every fresh init "fail"); a new exit code for update-kit (rejected: FR-006 freezes the
documented set).

## D7 — ritual-checks membership

**Decision**: the wrapper adds `verify-kit` as a fourth member. Applicability: if
`.kit-version` exists at root → run `verify-kit.ps1 -Root $Root`; else print
`ritual-checks: verify-kit       n/a (kit repository)` and exclude it from the
failure count. Verdict-block format unchanged otherwise; contract updated.

**Rationale**: one check name, one code path (006 lesson); the kit's own CI output
changes only by one explicit n/a line, so SC-004's "kit CI unchanged" holds in substance
and the member list stays honest.

## D8 — Grandfathering matrix

| Artifact missing | Pre-007 adoption (no record) | Post-007 (record exists) |
|---|---|---|
| `kit-adoption.json` | WARN + creation instructions (shape in adoption/updating.md) | — |
| Tier rulebook for declared tier | (no record ⇒ dimension is the WARN above) | FAIL naming tier + expected path |
| `gateProof` entry with exit 0 | WARN + pointer to adoption step 3 | FAIL (post-init to-do until recorded) |
| `.kit-version` | WARN + creation instructions (D5.3) | WARN (same) |
| Structure essentials / unfilled surgical slots / unratified constitution | FAIL — these were always law | FAIL |

**Rationale**: hard failures only for what was always required (SC-005: the next
flow-down cannot break existing projects' CI); everything introduced by 007 warns until
the owner opts in by creating the record.
