# Research: CI-Held Certifying Gate

Decisions pinning every open design question.

## D1 — Declaration grammar: Gate Batching's exact shape

**Decision**: one header field in `plan.md`, beside Gate Batching:

```markdown
**Gate Certification**: user-run <!-- or: ci-held (Lite/Standard only; constitution X,
  CI-held certification). Absent line = user-run. Critical MUST be user-run. -->
```

Legal values `user-run` | `ci-held`; absent line means `user-run` (every existing plan
stays compliant); declared before the first phase it governs, never retroactively; the
plan template ships the field defaulted to `user-run`.

**Rationale**: Gate Batching proved the shape — one greppable header, enforcement-parsed
with the same comment-stripping idiom, backward compatible by absence.

**Alternatives considered**: per-phase declarations in tasks.md (rejected: certification
mode is a feature-level trust decision the owner approves once, like batching); a
kit-adoption.json field (rejected: this is per-feature, not per-project — a project may
run Critical and Standard features side by side).

## D2 — The constitutional amendment (X, 0.4.1 → 0.5.0, MINOR)

**Decision**: a **CI-held certification** clause appended to X after the Batched-gates
clause, with a SYNC IMPACT entry. Mirror set updated in the same commit (the sync rule):

- `.specify/templates/plan-template.md` — Constitution Check X row + the new header field
- `docs/sdlc/definition-of-done.md` — gate 3 option
- `docs/sdlc/gate-command.md` — the CI-held section (evidence triplet, record example)
- `docs/sdlc/critical-delivery.md` — explicit exclusion mirror
- `CLAUDE.md` — strict-rule wording (agent obligations under ci-held)
- `scripts/enforcement-pack.ps1` — already sync-listed; gains the check in phase 2 (the
  clause's machine half; the SYNC IMPACT entry names it as landing next phase, same
  branch)

Clause boundaries (the law's text): Lite/Standard only; requires the plan declaration;
certification = the owner's recorded approval on the evidence triplet; the agent's
obligations unchanged (never claims success; reports evidence, requests approval);
Critical MUST NOT declare or use it; user-run remains lawful always and is the default.

**Amendment adoption (human approval)**: the owner's explicit approval of phase 1 plus the
gate-6 human review at merge constitute the amendment's required human approval; recorded
in the SYNC IMPACT entry.

**Rationale for MINOR**: a new certification option materially expands X's guidance;
nothing is removed or redefined (user-run stays the default and Critical is unchanged) —
same class as 0.4.0's Batched-gates clause.

## D3 — The evidence triplet and where approval lives

**Decision**: evidence = all three of (1) the CI run's URL, (2) its green conclusion,
(3) the exact phase-commit sha it ran on — for a batch, the batch-end commit. The owner's
approval citing the triplet is recorded **in the feature's existing phase record** (the PR
conversation or phase notes) — no new artifact, no machine check of the approval itself
(parity with gate 6: human layers are audited by humans). gate-command.md ships a worked
example record. A red-then-green re-run pair on the same sha certifies (deterministic
gates are the project's own law; the owner sees both runs and approves knowingly).

**Alternatives considered**: recording approvals in kit-adoption.json (rejected:
per-project file, per-phase fact; and it would make a tool write into the attestation
file); a machine check that the approval exists (rejected as scope: the approval is the
human layer — checking its presence mechanically invites checkbox theater, the same reason
gate 6 is unmachined).

## D4 — The project-gate workflow template: inert, slot-bearing, surgical

**Decision**: ship `.github/workflows/project-gate.yml.template` — the `.template` suffix
keeps GitHub from executing it in the kit repo (the kit's gate is `ritual-checks`;
US2 scenario 3). Adopters copy to `project-gate.yml`, fill `{{GATE_CHAIN}}` (and a
`{{GATE_WORKDIR}}` slot for nested-repo topologies), per instructions in gate-command.md.
`kit-manifest.json` gains a specific **surgical** row for the template path — it out-ranks
the `.github/**` verbatim glob under most-specific-wins. **Corrected by the phase 3 review
(F1)**: surgical class means update-kit only *reports* upstream template changes and never
rewrites (or first-delivers) the file — an adoption gets the template with the whole-kit
copy at adoption time, and refreshes it by hand per adoption/updating.md §3. That is the
intended trade: verbatim class would resurrect a deleted template on every update,
defeating the menu-style deletability.

**Rationale**: mirrors the tier-rulebook pattern exactly (template shipped, instance
project-owned); inertness in the kit repo avoids a permanently-red or vacuous kit check.

**Alternatives considered**: a live workflow with a no-op default gate (rejected: a green
check named "project-gate" that tests nothing is evidence-shaped noise — worse than
absence); putting the template under `.specify/templates/` (rejected: that surface is
stock Spec Kit, kept unmodified per README).

## D5 — The kit's own evidence source

**Decision**: for kit features 009+ declaring `ci-held`, the `ritual-checks` run on the
phase commit IS the project-gate evidence (the kit's gate has been doc-lint+enforcement
since 005; 006 wired it to CI). Stated in gate-command.md's CI-held section.

## D6 — Enforcement check shape (phase 2)

**Decision**: `Invoke-GateCertificationCheck` in the enforcement pack, GateBatching's
parser idiom: read `plan.md`'s `**Gate Certification**:` line; strip trailing HTML
comment; absent/empty ⇒ `user-run` (pass); value not in {user-run, ci-held} ⇒ FAIL naming
the legal values; `ci-held` + spec Delivery Level Critical ⇒ FAIL citing the exclusion.
Runs on `NNN-*` branches in the existing dispatch.

## D7 — Composition with batching, and what this feature itself uses

**Decision**: batching composes — under `ci-held`, a declared batch is certified by one
owner approval on the batch-end commit's evidence; per-phase commits/scope checks/AI
reviews unchanged. Batching stays in the law (not deprecated: user-run owners still
benefit). **This feature is delivered under the current law** — its own phases certify
user-run/batched (constitution X as it stands until merge + flow-down); the first ci-held
use is 009+ or an adopted project after re-expression.
