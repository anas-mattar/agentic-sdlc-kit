# Research: Level Declaration Graded

**Feature**: `017-level-declaration-graded` | **Date**: 2026-10-11

Every decision below resolves a question the spec left to planning. None needed outside
research: the answers come from reading the kit's own scripts.

## R1 — What "Territory intersects a surface" means

**Decision**: two path patterns intersect when either one, read as a path, matches the other,
or when the literal directory prefix of one is a prefix of the other's.

Territory entries are literal paths or globs (`scripts/scope-lib.ps1`, `Get-Territory`), and
surfaces are globs, so "do these two glob sets overlap" is the real question, and it has no
exact answer with the `-like` matcher the kit uses. The rule is conservative on purpose:

- A literal Territory path is tested with the kit's existing matcher (`Test-InTerritory`)
  against the surface list. Exact.
- A Territory glob such as `src/**` is reduced to its literal prefix (`src/`), and so is each
  surface (`src/auth/**` becomes `src/auth/`). They intersect when one prefix starts with the
  other. `src/**` therefore intersects `src/auth/**`, correctly, since that Territory can
  touch the surface.
- A pattern with no literal prefix (`**/*.ps1`) intersects everything. Over-reporting is the
  safe direction; the exception mechanism (R5) is how an owner says it is fine.

**Rationale**: under-reporting is the failure this feature exists to close. A false positive
costs one written exception; a false negative costs the whole point.

**Alternatives considered**: expanding both globs against the working tree (rejected: a
surface path need not exist yet, and a code repository's tree is not present in the
governance checkout); a real glob-intersection algorithm (rejected: machinery for a case the
prefix rule already errs safely on); matching only literal Territory paths (rejected:
`src/**` would then slip past every surface).

## R2 — "Reusing feature 012's repo-aware path reading"

**Decision**: reuse the *convention*, not a tree reader. Feature 012 writes Territory
governance-root-relative and repo-prefixed (`scripts/scope-check-repos.ps1`: each repository's
touched paths are prefixed with its directory name). Surfaces are written the same way, so
one matcher serves the governance repository and every nested code repository, and no sibling
working tree is opened. The check compares two lists of strings.

**Rationale**: the spec's FR-007 asks for one matching rule. Reading code trees would add a
dependency on layout that the check does not need and that a code repository's CI may lack.

**Alternatives considered**: calling `scope-check-repos.ps1` (rejected: it grades commits, not
declarations); a second prefix parser (rejected: GAP-018's lesson on copied helpers).

## R3 — Where each Territory lives, and when it exists

**Decision**: the check reads the Territory from the working tree of the branch.

- Standard: the union of every phase's block in `tasks.md`, phases found by the same
  `## Phase N` heading `Get-Territory` already keys on.
- Micro: the single feature-global block in `spec.md` (`Get-Territory -Global`).
- No `tasks.md` yet (Standard) or no block found: the check reports **UNGRADED** for that
  feature rather than passing. A `NearMiss` (a marker with no colon) is also UNGRADED, since
  the parser cannot say what was declared.

**Rationale**: at spec time there is no Territory, so a spec-only branch cannot be graded and
must not look clean (FR-012, the GAP-027 lesson). The Structure check already fails a
Standard branch without `tasks.md`, so the UNGRADED line adds information, not noise.

**Discrepancy to report, not fix**: the spec's Edge Cases say a decorated Territory marker
(GAP-026) is invisible to the parser. `scope-lib.ps1` now accepts decorated markers (feature
015). The spec's behaviour is unaffected, because an unreadable Territory is UNGRADED either
way, but its premise is stale. `spec.md` is not edited here: it is an approved document, so
an edit is an amendment and needs the owner's recorded approval. The owner decides.

## R4 — Marking which specs owe a Level Rationale

**Decision**: the updated spec template carries a header line `**Rationale Rule**: 1`. The
rationale check applies only to a spec that carries it. A spec without the line predates the
rule and is exempt.

**Rationale**: the rule must survive rebases and shallow clones, so not git history; and it
must work in adopted projects whose feature numbers are their own, so not a number floor. A
marker the template stamps is the one signal that travels with the document.

**Weakness, stated**: deleting the line evades the rule, exactly as deleting `**Delivery
Level**` evades the lane today (absent means Standard). Two things limit it: the deletion
shows in the diff, and the path check (R1) does not depend on the marker at all.

**Alternatives considered**: a feature-number floor (rejected: wrong in every adopted
project); a first-commit boundary the way the amendment check does it (rejected: a git
dependency the spec's Assumptions exclude); requiring the block on every spec (rejected:
fails every shipped feature, which FR-008 forbids).

## R5 — Surface Exception shape and approval

**Decision**: in `spec.md`, one line per exception plus an approval line:

```text
**Surface Exception**: `path` — reason
**Exception approved by**: <name>, <YYYY-MM-DD>
```

The approval line is validated by the function that validates amendment approvals
(`Get-ConformingRecord`: not a placeholder, a real date, not later than the commit). That
function reads its pattern from a script variable, so the plan parameterises the pattern
instead of copying the validation.

**Rationale**: feature 014 already decided what a well-formed approver record is. A second
definition would drift. The self-approval prohibition stays held by review alone, and the
spec says so rather than pretending otherwise (constitution I).

**Note**: an exception added after the spec's first appearance is also an amendment to
`spec.md`, so it needs an `**Amendment approved by**` line too. That is correct, not a
duplication: one record approves the exception, the other approves the document change. The
plan's quickstart shows both.

## R6 — Level Rationale block shape

**Decision**: a `## Level Rationale` section with exactly four bullet lines, keyed by stable
names so a machine can find them and a human can read them:

```text
- **domain-invariants**: does not apply — <reason>
- **irreversible-data**: does not apply — <reason>
- **authn-authz-payment**: does not apply — <reason>
- **auditable-evidence**: does not apply — <reason>
```

Verdicts are `applies` or `does not apply`; a reason of at least one word is required. A
Critical feature with every trigger `does not apply` must carry a `**Critical because**:`
line. A Standard feature with any trigger `applies` fails as contradictory.

**Rationale**: these are the four triggers in `docs/sdlc/critical-delivery.md`; naming the keys
fixes the vocabulary so the check cannot drift from the doc. Reviewer Provenance is the
precedent: a written claim that turns a silent omission into something falsifiable.

## R7 — Unarmed, empty and malformed surface lists

**Decision**:

| Record state | Path check | Output |
|---|---|---|
| no key | not armed | one informational line, verdict unchanged |
| key present, not an array, or blank or non-string entry | cannot run | UNGRADED line; the doctor reports the problem by key |
| empty array | not armed | informational line (an empty list is an unfinished edit, as for developers) |
| valid, non-empty | armed | grades as in R1 |

**Rationale**: SC-004 allows no verdict change for projects that declared nothing, so the
unarmed state is informational, not UNGRADED. A declared-but-unusable list is different: the
owner asked for the floor and did not get it, which is the case UNGRADED exists to name.

## R8 — The constitution

**Decision**: amend the constitution first, as a MINOR bump (0.7.0 to 0.8.0), adding a *Level
declaration* clause to Principle X. Feature 014 set the order: the kit must not enforce a rule
it has not ratified. The clause states the written-claim rule, the surface floor and the
exception, and says plainly what a machine cannot verify: that the rationale is *true*, and
that the approver agreed.

The sync-list in the constitution's header already names `scripts/enforcement-pack.ps1` and
its constitutional constants; the new constants (the four trigger keys, the marker value) join
that list in the same phase.

**Alternatives considered**: no amendment, docs only (rejected: Micro's "no domain-invariant
surface" bound is constitutional, and this feature makes part of it machine-checked, so the
rule belongs with the law it mirrors).

## R9 — Agent-context update

**Decision**: skip `update-agent-context.ps1`. It rewrites an agent file such as `CLAUDE.md`,
which here is kit law (the always-loaded document) and sits outside this feature's Territory,
and the feature adds no technology to record: it is PowerShell, already the kit's stack.
`CLAUDE.md` gets at most a one-line Strict-Rules mirror if phase 1's review finds the rule
needs one, as an owner-approved amendment.

## R10 — Test surface

**Decision**: every rule is a harness case under `tests/enforcement/cases/enforcement-pack/`
with a passing and a failing fixture, indexed in `tests/enforcement/rules.json`, with
expectations written by hand (feature 015). The doctor line is covered by whichever harness
member already covers `verify-kit.ps1`; if none does, the doctor change is verified by the
plan's quickstart and named as exempt with a written reason, the way feature 015 exempted
unreachable paths.
