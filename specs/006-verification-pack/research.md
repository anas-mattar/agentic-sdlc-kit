# Research: Verification Pack

Decisions resolving every open design question in the Technical Context. No NEEDS
CLARIFICATION markers remained in the spec; these decisions pin the mechanics.

## D1 — Territory declaration syntax

**Decision**: A `**Territory**:` list under each phase heading in `tasks.md`, one path or glob
per line, matched with PowerShell `-like` semantics against repo-relative paths. The feature's
own spec directory (`specs/NNN-name/**`) is always implicitly in territory.

```markdown
## Phase 2: Entry form (US2)

**Territory**:
- `frontend/src/components/expense-form/**`
- `frontend/src/pages/expenses.tsx`
```

**Rationale**: Lives where phases are defined and approved (tasks.md is already on the
source-of-truth ladder); trivially parseable with the same regex style enforcement-pack already
uses for `**Gate Batching**`; globs keep declarations short without being vague. The implicit
spec-dir rule avoids every phase declaring its own paperwork (checkbox updates, AI reviews).

**Alternatives considered**: a separate `territory.json` (rejected: second file to keep in sync
with tasks.md, violates single-source); YAML frontmatter in tasks.md (rejected: kit avoids
structured-config formats in prose docs — the rejected-YAML-manifest precedent from the
2026-08-27 proposal review).

## D2 — How the scope check maps a commit to a phase

**Decision**: Phase commits MUST carry a `phase N` token in the commit subject (e.g.
`phase 2: expense entry form`). `scope-check.ps1` parses the subject; `-Phase N` overrides. A
commit on an `NNN-*` branch with no parseable phase token gets the non-blocking
`warning-undeclared` verdict, not a failure.

**Rationale**: The one-commit-per-phase rule already exists (branch-strategy, DoD); naming the
phase in the subject is the smallest addition that makes commits machine-attributable, and the
warning fallback keeps history and mid-migration branches green. The kit's own features have
informally used `phase N` subjects since 001.

**Alternatives considered**: git trailers (`Phase: 2`) — cleaner but invisible in `--oneline`
listings and easy to forget; inferring the phase from which files changed — circular (the check
would derive the answer from the thing it is checking).

## D3 — Reading the declaration "as of the commit under test" (FR-004)

**Decision**: The check reads `git show <commit>^:specs/NNN-name/tasks.md` — the declaration as
it stood **before** the commit under test — falling back to `<commit>:` only when the parent
predates the feature directory (the claim commit itself).

**Rationale**: Reading the parent's version makes retroactive legalization structurally
impossible: a territory amendment only takes effect for commits made after it lands, which is
exactly the sanctioned remediation path (amend first, then commit the phase).

**Alternatives considered**: reading the declaration at HEAD (rejected: a stray file plus a
same-commit territory widening would pass); requiring amendments in dedicated commits verified
by message convention (rejected: more convention for no additional safety over parent-read).

## D4 — Provenance enforcement scope (grandfathering, FR-006)

**Decision**: The enforcement pack's new `ReviewProvenance` check inspects only AI-review files
**added in the branch's diff versus its base** (`git diff --diff-filter=A`). Each such file must
contain a `## Reviewer Provenance` section with a `Reviewer:` line whose value is not
`implementer` (or empty) and the literal attestation sentence.

**Rationale**: Diff-scoped inspection grandfathers 001–005 and every adopted project's history
automatically — no dates, no version flags. What the machine can verify is the block's presence
and internal consistency; the truth of the attestation is the owner's to audit, but a false
attestation is now a falsifiable written statement rather than an unstated assumption.

**Alternatives considered**: checking all review files in the repo (rejected: retroactively
fails shipped features); a kit-version cutoff date (rejected: more state, same effect as
diff-scoping).

**Post-review amendments (phase 2 review)**: the diff filter is `AR`, not `A` — rename
targets are inspected like additions, because moving a grandfathered review into the
feature under review is not legitimate grandfathering (F3); the check runs on every
recognized lane, self-scoped by the filter (F7). **Stated residual (F5)**: matching is
purely textual and does not strip markdown code fences, so a document quoting the block in
a fence can satisfy the presence check — the machine verifies presence and internal
consistency; the truth (and honest placement) of the attestation remains the owner's to
audit at human review.

## D5 — CI shape and the single local command (FR-007, FR-008)

**Decision**: One workflow, `.github/workflows/ritual-checks.yml`, `runs-on: ubuntu-latest`
(pwsh is preinstalled), `fetch-depth: 0` (merge-base and per-commit diffs need history),
triggered on pushes to `[0-9][0-9][0-9]-*`, `fix/**`, `chore/**`, `docs/**`. It runs exactly one
command: `pwsh -File scripts/ritual-checks.ps1`, which invokes doc-lint, enforcement-pack, and
scope-check (every phase commit since merge-base) and prints one verdict block. CI and local
runs are therefore the same code path by construction.

**Rationale**: A wrapper script rather than per-check workflow steps keeps FR-008 honest — a
contributor without CI runs the identical entry point. Ubuntu runner keeps CI fast and proves
the scripts' cross-platform claim on every push.

**Alternatives considered**: separate workflow jobs per check (rejected: verdict parity with
local runs would depend on workflow YAML, not on a script anyone can run); `windows-latest`
(rejected: slower queues, and cross-platform coverage is better tested by *not* matching the
maintainer's OS).

## D6 — Does this feature amend the constitution?

**Decision**: No constitution amendment. Gate 4 and gate 5 are defined in
`docs/sdlc/definition-of-done.md`; constitution X requires "its own scope check" and "its own
AI review" without defining their mechanics, and this feature changes mechanics only — who
certifies what is untouched. The sync list also gains nothing: `scope-check.ps1` and
`ritual-checks.ps1` encode no constitutional constants (verified against the 0.4.1 sync-list
criterion: the constants are the batch cap and cooling-off hours, both already owned by
enforcement-pack). If implementation surfaces wording in constitution X that contradicts the
amended DoD, work stops and reports per the conflict rule.

**Rationale**: GAP-002's lesson is *scripts encoding constitutional constants must be in the
sync list* — not *every script change is constitutional*. Keeping this at the DoD layer keeps
the constitution stable and the amendment procedure meaningful.

**Post-sweep note (phase 4 review, F4)**: constitution I's numbered workflow — "(6) review
changes; (7) commit the approved phase" — maps to the owner's **pre-commit intent review**
(`git diff --stat`), preserved in review-process.md step 2, CLAUDE.md step 6, and flow.md
row 3c. The machine scope check and the fresh-context AI review are **verification of the
committed phase** (DoD gates 4–5), an additional layer this feature adds, not a relocation
of constitution I's step (6). Recorded as the governing reading rather than a constitutional
amendment; if the owner prefers the constitution to name post-commit verification
explicitly, that is a PATCH amendment to I as a follow-up.

## D7 — Skipping `update-agent-context.ps1`

**Decision**: The stock plan flow's agent-context update is skipped, recorded here and in the
plan's Complexity Tracking.

**Rationale**: In an adopted project that script maintains the project's agent file; in the kit
repository `CLAUDE.md` **is the shipped template** — writing "active technologies: PowerShell"
into it would ship session noise to every adopter. The same reasoning governed features 001–005
(none carry an injected context block).

**Alternatives considered**: running it and reverting the diff (pointless churn); adding a kit
sentinel to the script (out of scope — upstream Spec Kit file, kept stock per README).
