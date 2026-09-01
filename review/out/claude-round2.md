# claude — Round 2 Cross-Review of codex

> Every citation endorsed below was re-opened and verified against the file. Where I concede,
> I name the evidence that changed my mind; where I don't, I bring new evidence.

## Where codex is right and I was wrong

1. **The Spec Kit pin IS machine-readable — my Round 1 answer 11 was factually wrong.** I wrote
   that the 0.4.4 pin "exists only as a README sentence" and that neither the pin nor the file
   boundary "is recorded anywhere machine-readable." `.specify/init-options.json:10` records
   `"speckit_version": "0.4.4"` (and `"script": "ps"` at line 9, which codex correctly used as
   the portability receipt). My broader point — no update contract, no ownership manifest —
   stands and codex agrees with it, but the pin claim is retracted. My build-plan feature 005
   narrows accordingly: the lockfile half-exists; what's missing is the contract around it.
2. **The tasks-template test-policy contradiction (codex finding 7) is real, verified, and I
   missed it entirely.** `.specify/templates/tasks-template.md:11` says "Tests are OPTIONAL -
   only include them if explicitly requested in the feature specification" while constitution
   XI (`.specify/memory/constitution.md:168-175`) makes automated tests mandatory for
   business-critical functionality. This is worse than an ordinary conflict: the template is
   the document the agent is reading *at the moment it decides whether to generate test
   tasks*, and it points the wrong way. It also exposes a second defect neither of us named in
   Round 1: the constitution's SYNC IMPACT REPORT (lines 34-36) lists only `plan-template.md`
   and `CLAUDE.md` as mirrors to update, while the amendment procedure (line 204) names
   `tasks-template.md` too — the sync header's own mirror list is incomplete, which is how
   this contradiction survived. This belongs in the first amendment feature, not in a later
   cleanup.
3. **My claim about how Codex ingests `AGENTS.md` is contradicted by the only direct
   observation available.** I asserted Codex would see `@CLAUDE.md` as "11 bytes of literal
   text" with a strong model merely guessing. Codex reports (their answer 4) that in their
   actual session the pointer *did* prompt them to read `CLAUDE.md`. One harness, one version,
   one data point — codex themselves flag it as non-portable evidence — but it is one more
   data point than I had. The finding survives in weakened form: the mechanism is untested and
   unclaimed for Cursor/Copilot/Gemini, and both reviews agree the fix is a real sentence plus
   recorded smoke tests. My feature 006 drops from "the claim is fiction" to "the claim is
   unproven for most named agents."
4. **Codex's Lite-lane framing is sharper than mine.** I framed the deadline failure mode as
   "misclassification downward" — features dressed as `fix/` branches. Codex points out
   (finding 6) that no misclassification is even needed: `docs/sdlc/branch-strategy.md:41`
   ships `chore/upgrade-orm` as the *worked example* of the Lite lane. An ORM upgrade — a
   dependency change with schema-adjacent blast radius — rides the lane with no spec, no plan,
   no rollback doc, by the kit's own illustration. The Lite lane needs an explicit prohibition
   list (dependencies, auth, schema, contracts, invariants), not just the "promote if it
   grows" sentence at `branch-strategy.md:46-49`.
5. **Evidence retention is Critical-only, and I under-weighted that.** Codex finding 1 notes
   ordinary features retain no required evidence; verified — retention appears only as
   Critical addendum item 3 (`docs/sdlc/critical-delivery.md:46-48`). For Standard features
   the gate result exists solely as a typed `EXIT: ___` in a checklist
   (`specs/_templates/human-pr-review-template.md:28`). My gate-log proposal was aimed at
   this, but I filed it under "trust boundary" and left Standard-lane evidence unaddressed;
   codex is right that the retention rule, not just the ritual, is the gap.

## Where codex is wrong

| Their claim | Why it fails | Evidence (path:line) |
|---|---|---|
| "Rollback is mostly `git revert`, which does not restore data, configuration, external effects, or compatibility" (finding 11) | Overstated, and the citation undercuts it: the cited lines are precisely the template's **Database Rollback** section (migration down-paths, protected-data rule) and **Deployment Rollback** section (config/env/permission changes), plus post-rollback verification. What the template genuinely lacks is external side effects (sent emails, third-party writes, webhooks) and any requirement that the plan be *drilled* — the finding should have been scoped to that. | `specs/_templates/rollback-template.md:15-30` (data/config sections exist); `:22-25` (config/env/permissions); `:27-30` (verification) |
| "The owner who drove the agent also runs and reports the gate" presented as the general trust model (finding 1) | True and damning for solo Standard work; false as stated for teams and for Critical. Team rule 4 forbids the owner approving their own feature; the review template allows the gate to be run by the reviewer; Critical item 5 mandates independent approval (with a second-model + cooling-off substitute for solo devs). The finding needed a scope qualifier — as written it erases the two independence mechanisms the kit does have. | `docs/sdlc/team-workflow.md:51-56`; `specs/_templates/human-pr-review-template.md:28` ("by the reviewer or user"); `docs/sdlc/critical-delivery.md:54-57` |
| "Make … second-model audits optional" (cut 5) | As scoped, this breaks Critical delivery for solo developers: the second-model adversarial review is not a periodic nicety there, it is the *substitute for independent approval* — the only independence mechanism a solo dev has on the highest-risk lane. The cut is defensible only for the periodic-audit cadence (`adoption/existing-system.md`, step 6), which is what codex cited; the recommendation as written sweeps in the Critical substitute too. | `docs/sdlc/critical-delivery.md:54-57` |
| "Eliminate mirrored 13-item Constitution Checks" (cut 6) | Two problems. First, it removes the only moment the full constitution is re-anchored into context at plan time — and codex's own answer 1 says broad principles "fade after compaction"; deleting the sole re-read trigger makes that worse, not better. The disease is manual synchronization; the cure is mechanizing the mirror check (my Q9 item 7), not amputating the mirror. Second, codex's own build plan contradicts the cut: feature 001's acceptance criteria include "a script verifies all pointers **and mirrors**" — you cannot verify mirrors you eliminated. | `.specify/templates/plan-template.md:30-52` (the re-anchor); codex-round1.md:94 (their own acceptance criterion); their own answer 1 (fade admission) |

## Citation check

**Result: 26 of 27 checked citations hold; one does not support the claim made from it**
(rollback-template.md:15-30 — see the table above: the cited lines contain the very
data/config rollback sections the claim says are absent).

Checked and holding: `.specify/init-options.json:1-10`; `.specify/templates/tasks-template.md:8-12`;
`specs/_templates/human-pr-review-template.md:26-32`; `docs/sdlc/definition-of-done.md:7-36`;
constitution `:50-54`, `:98-108`, `:110-130`, `:143-149`, `:159-175`, `:196-201`, `:203-216`;
`docs/sdlc/branch-strategy.md:35-49`; `docs/sdlc/critical-delivery.md:12-23`, `:25-33`;
`scripts/doc-lint.ps1:11-25`, `:103-109`, `:126-145`; `.github/workflows/doc-lint.yml:11-16`;
`docs/sdlc/deployment-standards.md:1-20`, `:34-37`; `docs/sdlc/review-process.md:9-29`;
`docs/sdlc/gate-command.md:60-68`; `docs/sdlc/team-workflow.md:7-12`;
`docs/sdlc/repository-strategy.md:65-92`; `AGENTS.md:1`; `README.md:3-5`, `:23-27`, `:86-92`;
`.specify/templates/plan-template.md:34-38`; `adoption/greenfield.md:21-22`, `:24-54`, `:63-69`;
`docs/rulebooks/backend-rules-template.md:35-39`; `docs/rulebooks/integration-rules-template.md:13-18`;
`.claude/settings.local.json:1-8`.

Count reconciliation, since our numbers differed: codex's "124 occurrences across 111 lines"
counts regex *occurrences* including `review/`; my "109" is the brief's exact `grep -rn` command
(*lines*), which at my run predated the review outputs. Both are correct in their units. Today,
excluding `review/`: 109 matching lines, 117 `{{SLOT}}`/`TODO(` occurrences. Neither number is a
finding against the other review.

## What neither of us saw

1. **The unit of the kit's central control is defined by the controlled party.** "One approved
   phase at a time" is the load-bearing rule of the entire framework — and nothing anywhere
   defines or bounds what a phase *is*. The only sizing language in the tree is stock Spec
   Kit's "Each phase should be a complete, independently testable increment"
   (`.claude/commands/speckit.tasks.md:199`), which is unbounded. The agent authors `plan.md`
   and `tasks.md`, and therefore draws its own phase boundaries: a single 2,000-line "Phase 1:
   implement the feature" satisfies DoD, constitution XIII, the diff-stat check, and every
   review gate. Both Round 1 reviews carefully costed the ceremony of a 4-phase feature
   (codex: 24 gate-item evaluations; me: 3–7 hours) — and neither noticed that the rational
   move under deadline is not skipping gates but *drawing fewer, fatter phases*, which the
   framework cannot see and which silently destroys the revert-clean property
   (`docs/sdlc/branch-strategy.md:70-71`) that the whole rollback story depends on. Cheap fix:
   a phase-size rule evaluated at plan approval (reviewable in the Constitution Check) plus a
   CI warning on phase-commit diff size.
2. **Specs have no lifecycle after merge.** Every `spec.md` is per-feature and frozen at merge,
   yet ladder rung 2 declares spec.md a source of truth. After the reference deployment's 68
   features there are 68 spec directories and *no living document describing current
   behavior*: when feature 069 touches feature 012's surface, no rule says whether 012's spec
   still binds, and nothing marks it superseded. The ADR home both of us proposed fixes this
   for architecture decisions only — functional truth has no supersession mechanism at all.
   The same hole has a mid-flight face: DoD item 1 requires approval "before implementation
   begins" (`docs/sdlc/definition-of-done.md:12-13`), so an approved spec edited during phase
   3 re-satisfies the letter of the gate with no re-approval procedure and no rule about
   re-validating phases 1–2. The constitution has an amendment procedure for itself
   (`:203-206`); specs — the documents amended weekly — have none.
3. **The kit's own quick-start command fails on the platform the kit targets.** `README.md:62-64`
   tells the adopter to find remaining slots with `grep -rn "{{\|TODO(" --include="*.md" .` —
   POSIX grep, which does not exist in the cmd/PowerShell environments that the kit's
   all-PowerShell script layer (finding of both reviews) is built for. It is a papercut, but
   it is the *first command* a Windows adopter pastes, on day one, from the kit that chose
   PowerShell precisely for that audience — and doc-lint reports only the slot count, not
   locations, so there is no in-kit substitute. One `Select-String` line in the README fixes it.
4. *(Bonus, extends my Round 1 finding 3)* **The source-of-truth ladder now exists in three
   divergent forms, not two.** Constitution II has 9 rungs (`:63-72`), CLAUDE.md has 7
   (`CLAUDE.md:28-36`), and the plan-template's Constitution Check item II compresses it to 5
   ("visual references → spec → plan → contracts → data model",
   `.specify/templates/plan-template.md:41`), dropping UI guidelines, tasks, research, and
   notes. Three copies, three shapes — the canonical-ladder fix is more urgent than my Round 1
   rated it.

## Merged priority list

| Rank | Item | Severity | Both agreed? | Rationale |
|---|---|---|---|---|
| 1 | One delivery-core amendment: resolve the unit-of-review contradiction (gates 1–5 per phase, human review per feature at merge) **and define phase size** in the same stroke | BLOCKER | Converged (me: contradiction, F1; codex: ceremony cost, #5 and cut 3) | Every later feature is reviewed under this rule; the phase-size hole (blind spot 1) is the same amendment touching the same lines — do it once. |
| 2 | Patch `tasks-template.md` test policy to obey constitution XI, and complete the SYNC header's mirror list | BLOCKER | No — codex only (#7), verified by me | The template actively instructs the agent against the constitution at the exact decision moment; cheapest fix in the whole list. |
| 3 | Enforcement pack: spec-artifact presence CI, branch↔spec mapping, Lite-lane prohibition list (deps/auth/schema/contracts/invariants) + abuse guard, branch-protection recipe, PR template | BLOCKER | Yes (my F2, codex #4/#6) | Converts the five non-negotiables from prose to physics; the `chore/upgrade-orm` example shows the Lite hole is authored in, not just drift. |
| 4 | Agent-security baseline: threat one-pager, deny-by-default settings shipped as a kit artifact, fix `.claude/settings.local.json` (merge/checkout allows) | MAJOR | Yes (my F4/F5, codex #2) | The kit governs agents and says nothing about the attack class unique to agents; the shipped settings contradict constitution XII today. |
| 5 | Trust-boundary evidence: CI-on-push as second witness for all adopters, gate evidence retained for Standard (not Critical-only) | MAJOR | Yes (my F7, codex #1) | "The user ran it" must leave a diff; retention scoped to Critical means the ordinary lane runs on memory. |
| 6 | One canonical source-of-truth ladder + mechanized mirror check (three divergent copies exist) | MAJOR | No — mine (F3), now with a third instance found this round | The kit demonstrates its own diagnosed failure mode pre-adoption; a doc-lint rule comparing the copies is an afternoon. |
| 7 | ADR home + **spec supersession convention** (blind spot 2) | MAJOR | Yes on ADR (my F6, codex #12); supersession is new | Same feature: both are "where does truth live after merge". |
| 8 | Kit update contract: ownership manifest (kit/Spec-Kit/project-owned), CHANGELOG, documented update procedure — the version pin itself already exists | MAJOR | Yes (my F9 as corrected, codex #10) | Every adoption is currently an orphaned fork; narrow scope since `init-options.json` already pins upstream. |
| 9 | Adoption sequencing: minimum viable ratification (constitution + proven gate → read-only features; invariants pack before first write feature), `-FailOnSlots` auto-on after ratification | MAJOR | Partially (my F10; codex #8 agrees on the cliff, differs on mechanism) | The judgment-slot cliff is where adopters die; sequencing it costs prose, presets cost an L feature (see Remaining disagreement 3). |
| 10 | Cross-agent contract: real AGENTS.md sentence + recorded smoke tests per claimed agent | MINOR (downgraded) | Yes (my F8, codex #3/answer 4) | Downgraded from my Round 1: codex's session is one observed success of the pointer; the fix is still one sentence plus tests, so it stays on the list. |

Dropped from top-10: my finding 13 (label untested layers) — folds into README wording during
rank 8; visual-loop cost (codex #15) — real but risk-scoped and behind everything above;
deployment-standards expansion — both reviews agree it stays a labeled placeholder for v1
(codex #11's recommendation "remove it from the governed claim" is already what
`deployment-standards.md:34-37` does).

## Merged build plan delta

My Round 1 v1 list survives with these changes (still 7 features):

- **001-dod-unit-fix → 001-delivery-core-amendment** (absorbs the round's converged findings):
  unit-of-review fix, **phase-size definition** (blind spot 1), **tasks-template test-policy
  patch + SYNC-header mirror-list completion** (codex #7), **single canonical ladder** across
  all three current copies (F3 + third instance), and the constitution demotions (V, VI → db
  rulebook; X deleted) both reviews independently proposed. One amendment, one version bump,
  instead of four sequential ones. Effort: M (was S).
- **002-enforcement-pack** gains the **Lite-lane prohibition list** (deps/auth/schema/contracts/
  invariants — from codex #6 and the `chore/upgrade-orm` example), **Standard-lane gate-evidence
  retention** (PR description embeds gate command + exit code), and a **settings-validation
  check** (no allow-rules for merge/push on kit repos), lifted from codex's 002/003 acceptance
  criteria. Effort: M→M/L.
- **003-agent-security-baseline**: unchanged scope; adopts codex's **adversarial fixtures** idea
  as acceptance criteria (malicious repo text, secret-like values, destructive commands).
- **004-adr-home** gains the **spec-supersession convention** (blind spot 2): a `Superseded-by:`
  header convention for shipped specs plus a one-paragraph mid-flight spec-amendment rule
  (re-approval required; completed phases re-validated or explicitly accepted). Still S.
- **005-kit-versioning** narrows (my concession 1): the upstream pin exists in
  `init-options.json`; the feature is now ownership manifest + CHANGELOG + update procedure
  only. S.
- **006-cross-agent-contract** simplifies (my concession 3): real sentence + per-agent smoke
  tests; drops the "claim is fiction" framing. S.
- **007-adoption-sequencing**: unchanged (minimum viable ratification + metrics ledger). The
  README grep papercut (blind spot 3) rides along as a one-line fix here.

**Added:** nothing as a new feature — all new material folded into existing seven.
**Moved:** cross-agent work de-prioritized within the set (rank 10).
**Dropped/kept out of v1:** codex's runnable presets (their 004) and running the outcome
experiment as a feature (their 007) — see Remaining disagreement 3 and 4; my Round 1's
metrics *instrumentation* stays in 007, the experiment itself remains post-v1. Cross-platform
(bash ports) stays v1.1, as in both Round 1 plans.

## Remaining disagreement

Four genuine forks, each a decision for the author:

1. **Constitution Check mirror: keep-and-mechanize (me) vs eliminate (codex, cut 6).**
   My choice: keep the 13-item mirror in plan-template and add a doc-lint rule that fails when
   it diverges from the constitution's principle headings. Cost: adopters tick 13 boxes per
   plan, some ritually. Codex's choice: single-source pointers, no mirrored list. Cost: the
   constitution is never re-anchored into agent context at plan time, and by codex's own
   answer 1, unanchored principles fade after compaction. Note their build plan already
   half-concedes (001 acceptance verifies "mirrors").
2. **Per-phase gates for Standard features: keep gates 1–5 per phase (me) vs gate-per-merge
   with risk-boundary checkpoints only (codex, cut 3).** We agree human review moves to the
   feature/PR level. My choice keeps the per-phase user gate and diff check because
   phase-per-commit reverts (`branch-strategy.md:70-71`) are only trustworthy if each commit
   was individually green; cost: N gate runs per feature. Codex's choice cuts interruption
   cost roughly N-fold; cost: a 4-phase branch is first verified whole at the end, and a bad
   phase-2 commit is no longer independently known-good — the rollback story quietly weakens.
3. **Adoption mechanism: sequenced minimum ratification (me) vs three runnable presets
   (codex, their 004).** Presets attack the cliff harder but are an L-effort feature sitting
   on the same rot-slope as the content libraries *both* of us rejected; sequencing is prose
   but leaves the drop-off higher. This is a real resource decision, not a resolvable fact.
4. **When to run the falsification experiment: v1 feature (codex, their 007) vs
   instrument-in-v1, run post-v1 (me).** Codex's cost: evaluating a moving target and spending
   an M/L feature before outside adoption exists to measure. My cost: one more release cycle
   shipped on anecdote. Both of us agree the metrics must be *collected* from v1 — the
   disagreement is only about who runs the trial and when.
