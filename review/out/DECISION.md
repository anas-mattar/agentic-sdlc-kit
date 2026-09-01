# Agentic SDLC Kit — External Review Decision Document
*Sources: review/out/*.md — Round 1 (independent) and Round 2 (cross-review), merged 2026-09-01.
Every BLOCKER below was re-verified against the repository during the merge.*

## The three things that matter

1. **The delivery core contradicts itself, and the contradiction sits on the rule everything
   else depends on.** The Definition of Done requires all six gates — including human review —
   before a phase may be "committed and merged" (`docs/sdlc/definition-of-done.md:35-36`),
   while the branch strategy commits each phase freely and merges once per feature
   (`docs/sdlc/branch-strategy.md:70-71`). A 4-phase feature literally owes four pre-commit
   human reviews; nobody will do that, so the central checklist is dead on arrival and teaches
   teams to ignore the rest. The same amendment must also fix three companion defects verified
   this round: the stock tasks template tells the agent "Tests are OPTIONAL"
   (`.specify/templates/tasks-template.md:11`) against constitution XI; the source-of-truth
   ladder now exists in **three divergent copies** (constitution II: 9 rungs; CLAUDE.md: 7;
   `plan-template.md:41`: 5); and the delivery level the whole risk model hangs on has **no
   field in the spec template** to be declared in (`spec-template.md:1-6` vs
   `branch-strategy.md:51-55`). One amendment, one version bump — do it first, this week.

2. **Every load-bearing rule is honor-system.** The only mechanical enforcement in the tree is
   a path linter (`scripts/doc-lint.ps1` + one workflow). Spec-artifact presence, phase scope,
   gate evidence, Lite-lane abuse, Critical evidence — all unverifiable claims. The kit's own
   thesis is "drift kills rule-based frameworks" (`README.md:83-84`); it applies to itself.
   Both models independently ranked an enforcement pack as the highest value-per-effort work
   in the entire review.

3. **The kit governs agents and says nothing about the attack class unique to agents — while
   shipping settings that contradict its own law.** No threat model for prompt injection via
   the artifacts the ladder tells the agent to trust, no secrets-in-context rule, no tool/MCP
   policy — and `.claude/settings.local.json:4-6` whitelists `git checkout`, `git add`, and
   `git merge`, the exact action constitution XII reserves for after human approval.

## Confirmed findings

| # | Severity | Finding | Evidence | Agreed by | Action |
|---|---|---|---|---|---|
| 1 | BLOCKER | Unit-of-review contradiction: DoD demands human review before each phase commit; branch strategy commits phases and reviews once per feature | `definition-of-done.md:35-36` vs `branch-strategy.md:70-71`; `review-process.md:31-43` | Both (codex conceded R2) | 001: gates 1–5 per phase, gate 6 per feature at merge; align constitution XII |
| 2 | BLOCKER | Tasks template instructs against constitution XI at the moment the agent decides whether to write tests; the SYNC header's mirror list omits `tasks-template.md`, which is how it survived | `tasks-template.md:11` vs constitution `:168-172`; sync header `:34-36` vs amendment rule `:204` | codex; verified by claude R2 and re-verified in merge | 001: patch template, complete mirror list |
| 3 | BLOCKER | No mechanical enforcement of anything that matters — only doc-lint (path existence; slots informational) | `scripts/doc-lint.ps1:11-25,126-145`; `.github/workflows/doc-lint.yml` is the only workflow | Both | 002: enforcement pack |
| 4 | BLOCKER | Delivery level must be declared in `spec.md` but the spec template has no field for it — risk classification has no artifact and nothing for CI to check | `branch-strategy.md:51-55`, `critical-delivery.md:18-23` vs `spec-template.md:1-6` | codex R2 blind spot; re-verified in merge | 001: required `Delivery Level:` header |
| 5 | MAJOR | No agent threat model (injection via trusted ladder artifacts, secrets in context, tool/MCP policy) and shipped settings allow checkout/add/merge | `.claude/settings.local.json:4-6`; constitution VIII `:143-149` covers app security only | Both | 003: security baseline + fixed settings |
| 6 | MAJOR | "One approved phase at a time" is the central control, and nothing bounds what a phase is — the agent that is being controlled draws its own phase boundaries; under deadline the rational move is fewer, fatter phases, which silently destroys the revert-clean property | `speckit.tasks.md:199` (only sizing language, unbounded); `branch-strategy.md:70-71` | claude R2 blind spot | 001: phase-size rule checked at plan approval; 002: diff-size warning |
| 7 | MAJOR | Source-of-truth ladder exists in three divergent shapes — the kit demonstrates its own diagnosed failure mode pre-adoption | Constitution `:63-72` (9 rungs) vs `CLAUDE.md:28-36` (7) vs `plan-template.md:41` (5) | claude; third copy found R2; re-verified | 001: one canonical ladder, others point at it |
| 8 | MAJOR | Gate trust is theatre for Standard work: evidence retention is Critical-only, the exit code is a typed field, CI second witness is scoped to teams | `human-pr-review-template.md:28`; `critical-delivery.md:46-48`; `team-workflow.md:85-89` | Both | 002: CI-on-push for all adopters; gate evidence in PR description (protected CI, not a committed gate-log — see Rejected) |
| 9 | MAJOR | Lite lane hole is authored in, not drift: `chore/upgrade-orm` is the worked example — a dependency upgrade rides with no spec, no plan, no rollback doc | `branch-strategy.md:41,46-49` | codex; claude conceded R2 | 002: prohibition list (deps/auth/schema/contracts/invariants) + CI abuse guard |
| 10 | MAJOR | No ADR home; constitution IV's bootstrap clause stores architecture decisions in historical feature plans — "approved architecture" degrades into archaeology | Constitution `:92-108`; `adoption/greenfield.md:63-69`; no `docs/adr/` | Both | 004 |
| 11 | MAJOR | Specs have no post-merge lifecycle: no supersession marker, no mid-flight amendment/re-approval rule — an approved spec edited during phase 3 re-satisfies the gate's letter | `definition-of-done.md:12-13`; ladder rung 2; constitution has amendment rules for itself only (`:203-206`) | claude R2 blind spot | 004: supersession header + amendment paragraph |
| 12 | MAJOR | No kit version, changelog, ownership manifest, or update procedure — every adoption is an orphaned fork (the upstream pin itself DOES exist: `init-options.json:10`) | `README.md:45`; `.specify/init-options.json:9-10` | Both (claude's "pin not machine-readable" retracted R2) | 005 |
| 13 | MAJOR | Adoption cliff: ~109 unfilled slot lines; init handles the mechanical ~20%, the judgment slots (invariants, rulebooks, ratification) are days of senior work fronted before feature 001; a half-ratified kit is worse than no kit | grep count reconciled R2 (109 lines / 117–124 occurrences); `init-kit.ps1:185-204` | Both | 007: sequence the cliff (minimum viable ratification) |
| 14 | MAJOR | Critical solo approval is operationally undefined: "second-model review plus cooling-off" cites a broad audit procedure, with no artifact, duration, or merge control — the highest-risk solo lane is less falsifiable than Standard | `critical-delivery.md:54-57` vs `adoption/existing-system.md:60-66` | codex R2 blind spot | 001: define artifact + delay (see Open decision 5) |
| 15 | MINOR | Constitution over-promotion: V (PK standard) and VI (audit fields) are schema conventions; X is unfalsifiable vibes — dilutes the principles that matter | Constitution `:110-127,159-166` | Both | 001: demote V/VI to database rulebook, delete X |
| 16 | MINOR | Cross-agent contract untested: `AGENTS.md` is an `@CLAUDE.md` pointer; it worked in the one Codex session observed, unproven for Cursor/Copilot/Gemini; nested-repo ancestor inheritance is asserted, standalone/cloud clones admittedly ungoverned | `AGENTS.md:1`; `repository-strategy.md:80-92` | Both (claude's "fiction" framing withdrawn R2) | 006 |
| 17 | MINOR | PowerShell-only tooling incl. Spec Kit scripts; README's own quick-start `grep` fails on the Windows platforms the kit targets | `.specify/scripts/powershell/` (only variant); `README.md:62-64` | Both; grep papercut claude R2 | v1.1 for ports; README one-liner rides in 007 |
| 18 | MINOR | Feature-number allocation races with >1 developer (local max+1, ownership only at push) | `create-new-feature.ps1:95-117`; `team-workflow.md:14-22` | codex R2 blind spot | v1.1 |
| 19 | MINOR | Untested layers presented as proven: team-workflow, Critical level, nested multi-repo have N=1 (author) mileage; deployment-standards is a placeholder listed as process law; the kit itself has never run its own Standard lane | `team-workflow.md:3-5`; `deployment-standards.md:3-7` vs `README.md:28-30`; no `specs/NNN-*` in tree | Both | README honesty pass in 005; dogfood v1 through the Standard lane |

## Rejected findings

Raised in review, deliberately not acted on. This list prevents relitigation.

- **"Rollback is mostly `git revert`" (codex R1 #11).** The cited template lines contain the
  very database/config rollback sections the claim says are absent
  (`rollback-template.md:15-30`). The salvageable residue — external side effects and drilled
  rollbacks — is real but v1.1 material, not a v1 finding.
- **Committed gate-log as run evidence (claude R1).** Codex's rebuttal stands: a self-authored
  text line proves nothing about who ran what on which SHA, and dirties the branch after the
  run. Protected CI bound to the merge SHA is the witness; 002 implements that instead.
- **Eliminate the mirrored Constitution Check (codex cut 6).** Rejected: it is the only
  plan-time re-anchor of the constitution into agent context, and codex's own answer 1 concedes
  unanchored principles fade. The disease is manual sync; the cure is a mechanized mirror check
  (v1.1), not amputation. Codex's own 001 acceptance criterion ("script verifies mirrors")
  half-conceded this.
- **Make second-model audits optional as scoped (codex cut 5).** As written it sweeps in the
  Critical-solo independence substitute — the only independence a solo dev has on the
  highest-risk lane. The periodic audit cadence may go optional; the Critical substitute gets
  *defined*, not deleted (finding 14).
- **"`@CLAUDE.md` is 11 bytes of literal text to every non-Claude agent" (claude R1, categorical
  form).** Contradicted by the one direct observation available: the Codex review session
  followed the pointer. Survives only as "untested for most named agents" (finding 16).
- **"Lite is categorically too heavy" (codex R1 #6, first half).** Conceded in R2: gate + diff
  + review is normal PR hygiene. The lane's real defect is the missing prohibition list
  (finding 9).
- **"All 12 changes rode the Lite lane" as a precise claim (claude R1 F14).** The commit log
  shows docs/fix/chore topic branches but does not prove per-commit branch history; the exact
  count is underivable. The dogfooding *point* survives as finding 19.
- **Deployment-standards expansion in v1.** Both reviews converged: it stays a labeled
  placeholder; `deployment-standards.md:34-37` already mandates its own spec-first expansion.
  v1.1.
- **One wrong citation each, corrected, findings intact:** claude cited
  `settings.local.json:5` for `git merge` (it is line 6); codex cited
  `rollback-template.md:15-30` for an absence those lines disprove.

## Open decisions for the author

| Decision | Option A (cost) | Option B (cost) | Recommendation |
|---|---|---|---|
| Standard-feature review unit | Gates 1–5 per phase, human review per feature — claude (cost: N gate runs per feature; interruptions remain) | Gate + review once per PR, phase checkpoints only at declared risk boundaries — codex (cost: a bad phase-2 commit is never independently known-good; revert-clean property quietly weakens) | **A.** The rollback story is the kit's spine; per-phase user gates are what make phase commits individually trustworthy. Human review already moves to the feature level, which removes the part nobody would do. |
| Multi-repo authority model | One physical parent constitution + pointer files in code repos — claude (cost: standalone/cloud clones stay ungoverned, acknowledged) | Generated, digest-pinned governance contracts materialized per repo — codex (cost: real tooling to prove copies haven't drifted; a second machine layer) | **A for v1** (006 ships the pointers), and record the standalone-clone hole honestly in `repository-strategy.md`. Revisit B only if a real adoption hits the cloud-agent case. |
| Adoption mechanism | Sequenced minimum ratification, prose only — claude (cost: drop-off stays higher than presets would leave it) | Three runnable presets — codex (cost: an L feature on the same rot-slope as the content libraries both reviews rejected) | **A for v1** (007). If two external adoptions still stall at the same step, presets become the proven need they currently aren't. |
| Falsification experiment timing | Run the paired trial as a v1 feature — codex (cost: an M/L feature evaluating a moving target, before any outside adoption exists) | Instrument metrics in v1, run the trial post-v1 — claude (cost: one more release shipped on anecdote) | **B.** One person with limited evenings cannot run a preregistered trial and build v1; the metrics ledger (007) makes the trial possible the day v1 is stable. |
| Solo Critical delivery | Keep it, but define the second-model review artifact and cooling-off duration as merge requirements (cost: independence is still simulated, and honesty requires saying so) | Require an external human for Critical until a mechanical exception exists — codex (cost: excludes the kit's core solo audience from its highest-risk lane) | **A**, defined in 001 with an explicit honesty sentence: "this is a mitigation, not independence." The kit's audience is solo devs; option B amputates the lane they most need. |

## v1 plan — max 7 features

Build these through the kit's **own Standard lane** in this repository — it has never run once
here (finding 19), and the friction is data. All seven are executable solo, evenings-scale.

| NNN | Feature | Goal | Phases | Acceptance criterion | Effort | Cost of skipping |
|---|---|---|---|---|---|---|
| 001 | delivery-core-amendment | One constitutional amendment fixing every verified internal contradiction: unit-of-review (gates 1–5/phase, human review/feature), phase-size rule evaluated at plan approval, `Delivery Level:` required in spec header, tasks-template test-policy patch + complete SYNC mirror list, one canonical ladder (others point or lint-compared), demote V/VI to db rulebook, delete X, define Critical-solo artifact + cooling-off | (1) amend constitution + DoD + merge review-process into it; (2) sweep templates and cross-references | doc-lint green; `grep` finds zero per-phase human-review language; spec-template contains `Delivery Level:`; tasks-template no longer says tests optional; constitution version bumped with amendment recorded; exactly one full ladder exists in the tree | M | Every later feature is reviewed under contradictory law; the checklist stays impossible to follow and teaches non-compliance |
| 002 | enforcement-pack | Convert the five non-negotiables from prose to physics: CI checks for spec-artifact presence on `NNN-*` branches, declared delivery level, Lite prohibition list (deps/auth/schema/contracts/invariants) + abuse guard (fix/chore touching migrations or >N files fails), Critical-evidence presence, phase-commit diff-size warning, `-FailOnSlots` auto-on post-ratification; PR template embedding the review checklist + gate command/exit code; branch-protection recipe | (1) checks as a CI-agnostic script; (2) workflow + PR template; (3) adoption-doc wiring | A deliberately broken fixture branch fails each check; a clean one passes; this repo's own CI runs the pack | M/L | The kit remains an honor system and its own thesis convicts it |
| 003 | agent-security-baseline | One-page threat model (ladder artifacts trusted only after human approval; untrusted content never becomes instructions; secrets never in session context; tool/MCP allowlist stance), kit-shipped deny-by-default `settings.json`, fix `.claude/settings.local.json` | (1) doc + settings; (2) wire into CLAUDE.md always-row and adoption step 0 | Settings contain no allow rule for merge/push/checkout; CLAUDE.md references the doc; adversarial fixtures (malicious repo text, secret-like value, destructive command) documented with expected agent behavior | M | First injection incident lands on the framework that claimed to be the adult in the room, which today ships permissions contradicting its own constitution |
| 004 | adr-and-supersession | `docs/adr/` + template + index; constitution IV amended so architecture-changing plan approvals land an ADR; spec `Superseded-by:` header convention + one-paragraph mid-flight spec-amendment rule (re-approval required, completed phases re-validated or explicitly accepted) | one | doc-lint green; constitution IV references the path; greenfield step 4 updated; spec-template documents the supersession header | S | "Approved architecture" and "current behavior" both degrade into archaeology across N feature directories |
| 005 | kit-versioning | KIT-VERSION + CHANGELOG + ownership manifest (kit-owned / Spec-Kit-owned / project-owned) + documented update procedure; README honesty pass labeling N=1 layers (team, Critical, nested multi-repo) as designed-not-proven | one | Manifest lists every top-level path exactly once; update procedure tested by diffing a scratch copy; README labels present | S | Every adoption is an orphaned fork; the first upstream Spec Kit change strands them all |
| 006 | cross-agent-contract | Real imperative AGENTS.md sentence (not a bare `@`-token), per-agent compatibility notes, pointer files for nested code repos, recorded smoke test of at least one non-Claude agent following the pointer — failures recorded honestly | (1) files; (2) test + record | AGENTS.md contains an imperative instruction; `repository-strategy.md` inheritance claim rewritten to name which agents it is tested for; at least one recorded non-Claude smoke test exists in the tree | S | The "cross-agent" README claim stays an untested hypothesis |
| 007 | adoption-sequencing-and-metrics | Minimum viable ratification (constitution + proven gate → read-only features allowed; invariants pack gated before first write feature); restructure both adoption tracks around it; `docs/metrics.md` ledger template (per feature: governance minutes, fix-lane follow-ups within 14 days, review findings that changed code); fix the README grep one-liner for PowerShell | (1) adoption docs; (2) metrics template + wiring | Both adoption tracks name the minimum ratification point; metrics template referenced from DoD; README quick-start command runs on Windows PowerShell | M | The judgment-slot cliff keeps eating adopters, and the kit stays permanently unmeasurable — no kill-criterion data ever accrues |

## v1.1 and beyond

- Cross-platform: bash variants of the Spec Kit scripts + doc-lint port (~100 lines of path checks).
- Runnable adoption presets — only if two external adoptions stall at the same sequencing step.
- Constitution↔plan-template mirror check mechanized in doc-lint.
- Atomic feature-number reservation (or collision-free IDs) for teams (finding 18).
- Human onboarding page for the month-6 hire who experiences the kit only as friction.
- Deployment-standards expansion past placeholder, via its own mandated spec-first path;
  rollback template gains external-side-effects section and a drill requirement.
- Second worked domain-invariants module (non-finance) to prove the shape generalizes.
- The falsification experiment itself: paired/alternating tasks against a baseline of
  CLAUDE.md conventions + protected CI + PR review, using the 007 metrics; and the
  retrospective on the 68-feature reference history (fix-follow-ups per feature over time)
  if that history is accessible.

## Explicitly out of scope, permanently

- **Stack profile / recipe libraries and pre-filled rulebooks** — they rot and lie; the kit's
  own reasoning (`stack-profile-template.md`) is correct. Both models, both rounds.
- **YAML/manifest config layer, GUI, or web generator** — the kit's medium is markdown read by
  agents; a second machine layer doubles the drift surface.
- **Pixel-diff visual testing** — the review process's own argument stands
  (`review-process.md:14-18`).
- **Multi-constitution federation** — one constitution is the kit's best idea; the
  digest-contract variant remains a recorded option (Open decision 2), federated copies do not.
- **More delivery levels** — misclassification is fixed by CI detection (002), not taxonomy.
- **Autonomous merge/deploy agent** — contradicts the human-accountability premise.
- **Eliminating the agent-run gate** — the fast feedback loop is what makes one-phase delivery
  bearable; the fix is evidence (002), not prohibition.
- **Signed/cryptographic attestations of the gate ritual** — protected CI and platform audit
  logs solve the actual evidence problem more simply.
- **Governing every deployment platform** — v1.1 defines required properties and evidence only.

## Kill criterion

If, after **two adoptions outside the author's own hands, each shipping ≥10 features**, the
evidence trail shows both teams abandoned the per-phase ritual (no per-phase commits, no
retained gate evidence, batched multi-phase reviews) **and** the 007 metrics ledger shows no
improvement in fix-lane follow-ups or review cost against each team's own pre-kit baseline —
or if a later paired trial shows no defect/rework reduction while median active delivery time
rises >25% or >20% of features materially bypass required controls — then the middle layers
are dead weight. Do not respond by adding documents: collapse the kit to the five
non-negotiables plus the enforcement pack, archive the rest, and stop calling it a framework.
