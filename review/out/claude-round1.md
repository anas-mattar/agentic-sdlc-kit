# claude — Round 1 Independent Review

> Reviewer: Claude (Fable 5), reviewing as the literal target of this framework — an AI
> coding agent driven by these documents. Where I reason from that experience rather than
> from a file, I say so.

## Verdict

The single most important thing: **the kit's Definition of Done, read literally, will not be
followed by anyone — including you — and the first document a team learns to ignore teaches
them to ignore all the others.** DoD item 6 demands human review before each *phase* is
"committed and merged" (`docs/sdlc/definition-of-done.md:33-36`), while the branch strategy
commits phases freely and merges once per feature (`docs/sdlc/branch-strategy.md:62-71`).
Teams will batch review at the PR; from that day they are formally non-compliant with the
kit's central checklist, and non-compliance is normalized. Second: the kit's whole thesis is
"drift kills rule-based frameworks" (`README.md:83-84`), yet its only mechanical enforcement
is a path linter — every load-bearing rule (spec exists, phase scope, gate ran, lane not
abused) is honor-system. I would adopt the five non-negotiables and roughly half the documents
on a real project; I would not adopt the kit as shipped, because the gap between what it
mandates and what it can verify is where a real team quietly exits by feature 3.

## Findings

| # | Severity | Area | Finding | Evidence (path:line) | Recommendation |
|---|----------|------|---------|----------------------|----------------|
| 1 | BLOCKER | Definition of Done | Unit-of-review contradiction: DoD requires human review before a phase may be "committed and merged"; branch strategy commits each phase and merges once per feature after review. A 4-phase feature literally requires 4 human reviews pre-commit — no one will do this, so the DoD is dead on arrival. | `docs/sdlc/definition-of-done.md:33-36` vs `docs/sdlc/branch-strategy.md:62-71`; `docs/sdlc/review-process.md:31-43` (commit at step 5, human review only in the merge section) | Amend: gates 1–5 per phase, gate 6 (human review) per feature at merge. Version-bump the constitution's XII wording to match. |
| 2 | BLOCKER | Enforcement | Nothing mechanical checks the rules that matter: no CI check that an `NNN-*` branch has `specs/NNN-*/spec.md|plan.md|tasks.md`, no lite-lane abuse guard, no check that a Critical feature's evidence files exist, no branch protection guidance. The kit's own diagnosis ("drift kills rule-based frameworks") applies to itself. | Only `scripts/doc-lint.ps1` + `.github/workflows/doc-lint.yml` exist; `README.md:83-84` states the thesis | Ship an enforcement pack (see Q9 ranking and build-plan feature 002). |
| 3 | MAJOR | Internal drift | The source-of-truth ladder is duplicated and has **already diverged inside the kit**: constitution II has a UI-guidelines rung; CLAUDE.md's ladder omits it. The kit demonstrates the exact failure mode it warns about, pre-adoption. | `.specify/memory/constitution.md:63-72` (9 rungs incl. `{{UI_GUIDELINES_PATH}}`) vs `CLAUDE.md:28-36` (7 rungs, no UI-guidelines rung) | Make one ladder canonical (constitution II); CLAUDE.md points at it instead of restating. Or add a doc-lint rule comparing the two. |
| 4 | MAJOR | Agent permissions | The kit's own agent settings whitelist `git merge *` (and `git checkout *`, which can discard working-tree changes) — the exact action the law reserves for after human approval. The kit ships a permission policy that contradicts its constitution and offers no permission-policy guidance to adopters. | `.claude/settings.local.json:5` vs constitution XII (`.specify/memory/constitution.md:177-184`), `docs/sdlc/branch-strategy.md:59-62` | Remove the merge/checkout allows; ship a recommended `settings.json` (deny-by-default, merge and push behind prompts) as a kit artifact, not a local accident. |
| 5 | MAJOR | Security | No agent-threat model at all. The source-of-truth ladder instructs the agent to *trust* artifacts (research.md, screenshots, contracts) with no rule about where they came from — a poisoned research.md or a malicious string inside a referenced issue/web page is an injection channel with constitutional cover. Nothing on secrets entering agent context (only "not stored in source", constitution VIII), nothing on MCP/tool policy. | `CLAUDE.md:28-36`; `.specify/memory/constitution.md:144-149`; absence of any doc covering agent I/O trust | Add a one-page agent-security doc: ladder artifacts are trusted only after human approval; untrusted content (issues, web, pasted logs) never becomes an instruction; secrets never pasted into sessions; permission baseline per finding 4. |
| 6 | MAJOR | Architecture governance | Constitution IV's bootstrap clause demands ADR-style decisions, but there is no ADR home. After feature 001, "the existing architecture" = the scaffold plan.md **plus every approval buried in every subsequent plan.md**. Answering "what is our approved architecture?" requires archaeology across N feature directories; the agent (me) will answer it from the code instead, which is exactly what IV forbids. | `.specify/memory/constitution.md:92-108`; `adoption/greenfield.md:63-69`; no `docs/adr/` anywhere | `docs/adr/` + template; plan.md approvals that change architecture must land an ADR in the same feature. Cheap, closes a real hole. |
| 7 | MAJOR | Trust boundary | The gate ritual is honor-system and the kit already opened the drift door itself: agents MAY run the gate for feedback (`gate-command.md:60-68`), so "just tell me your run passed" is one lazy evening away. Nothing records or verifies the user's run; the CI second witness is mandatory only in team-workflow (which solo devs are told they can ignore) and a bullet in adoption step 7. | `docs/sdlc/gate-command.md:1-4,60-68`; `docs/sdlc/team-workflow.md:4-5,85-89`; `adoption/greenfield.md:96-98` | Make CI-on-push the constitutional second witness for all adopters (not a team-only rule), and have the gate command append to a `gate-log` file (timestamp, command, exit code) so "the gate ran" leaves evidence. |
| 8 | MAJOR | Cross-agent | `AGENTS.md` is `@CLAUDE.md` — an @-include convention that is Claude-specific. Codex/Cursor/Copilot/Gemini ingest that as 11 bytes of literal text; a strong model may guess, a weak one won't. The nested-repo inheritance claim ("agents read CLAUDE.md from ancestors") is likewise Claude Code behavior asserted as universal. Cross-agent inheritance is claimed, never tested. | `AGENTS.md:1`; `docs/sdlc/repository-strategy.md:80-83` | Make AGENTS.md a real sentence ("Read `CLAUDE.md` in this directory and obey it as your binding contract; it points to the constitution."), add a per-agent compatibility note, and place a pointer file in each nested code repo. |
| 9 | MAJOR | Versioning | The kit itself has no version, changelog, or update path. Adopters copy files in (`README.md:45`) and fork forever; when the kit or upstream Spec Kit 0.4.4 moves, there is no way to know what you have or how to take a fix. The constitution has semver; the kit that carries it doesn't. | `README.md:26,45`; no VERSION/CHANGELOG file in the tree | `KIT-VERSION` + CHANGELOG + a documented update procedure ("diff your copy against the new kit; kit-owned files vs project-owned files listed explicitly"). |
| 10 | MAJOR | Adoption cliff | 109 unfilled `{{SLOT}}`/`TODO(` markers across 19 files. `init-kit.ps1` handles the mechanical ~20%; the judgment slots (domain-invariants pack, descriptive rulebooks, gate proof, constitution ratification) are days of senior-person work with one worked example (finance) as the only guide. Realistic drop-off point: existing-system steps 2–4. | `grep -rn "{{\|TODO(" --include="*.md"` → 109; `scripts/init-kit.ps1:185-204` (prints what remains); `adoption/existing-system.md:30-52` | Define a "minimum viable ratification": constitution + gate + empty-but-instantiated rulebooks is enough to ship feature 001; invariants pack required only before the first write-slice feature. Sequence the cliff instead of fronting it. |
| 11 | MINOR | Portability | Everything executable is PowerShell-only, including the Spec Kit scripts (`.specify/scripts/powershell/` — the bash variants upstream offers were not taken). On macOS/Linux, `/speckit.*` breaks without installing pwsh; most JS/Python teams don't have it. | `scripts/*.ps1`; `.specify/scripts/powershell/` (only) | Document `pwsh` as a hard prerequisite in README + adoption step 0, or re-init Spec Kit with bash scripts and port doc-lint (it's ~100 lines of path checking). |
| 12 | MINOR | Constitution scope | V (PK standard), VI (audit fields), X (performance vibes) are schema/style conventions over-promoted to constitutional force. Cost: constitutional amendments for convention changes, and dilution — when everything is supreme law, the agent weighs the truly critical principles (VII, XII, XIII) the same as "avoid unnecessary queries". X is entirely unfalsifiable. | `.specify/memory/constitution.md:110-127,159-166` | Delete X; move V and VI into the database rulebook template; constitution drops to 10 principles. |
| 13 | MINOR | Honesty of claims | `deployment-standards.md` is a self-declared placeholder yet README lists it as part of "the process law", and the 68-features provenance is unverifiable from this repo. Team-workflow, Critical level, and the multi-repo nested layout are all untested outside the author's own hands (the kit admits the single-developer origin). | `docs/sdlc/deployment-standards.md:3-7` vs `README.md:28-30`; `docs/sdlc/team-workflow.md:3-5` | Label untested layers as such in README ("extracted from N=1; team layer and Critical level are designed, not proven"). Honesty here buys trust for the rest. |
| 14 | MINOR | Dogfooding | The kit is not built with the kit: all 12 changes in the log rode the `docs/*` Lite lane — legitimately per its own law, but it means the Standard lane (spec→plan→tasks→phase→gate) has never once run inside this repository, and there is no `specs/` trail here to learn from. | `git log --oneline` (all `docs/*`, `fix/*`, `chore/*` branches); no `specs/NNN-*` in the repo | Build the v1 features below through the Standard lane in this repo. The friction you hit is the roadmap. |

## Answers to the brief

**1.** Rules that would genuinely change my behavior, because they sit at decision boundaries
and are cheap for the user to check: stop after one phase; never claim success without the
user's exit code (a concrete speech-act prohibition — I can comply with it mechanically);
stop-and-report on rung conflict (a concrete trigger); no new packages without plan.md; the
exact `specs/NNN-name/` structure; `git diff --stat` scope. These survive because violating
them is visible in a single artifact. Rules I would drift from by turn 30, honestly: the
Task-Scoped Reading discipline (I read what the task needs regardless of the table);
"walk the Visual Inventory item by item, recapture after every fix" (`review-process.md:9-28`
— I will do it rigorously once, then batch fixes and summarize); "cite the contract file in a
comment" (`backend-rules-template.md:36-39`); everything in constitution X; the rationale
paragraphs (I never re-read them). The design insight the kit gets right: the Strict Rules
live in the always-loaded file and are short — that is why they hold. Anything that lives
only in a task-scoped doc read at turn 5 has faded by turn 40 unless a re-read is triggered;
the "Reviewing / finishing a phase" row is a genuinely good re-anchoring trigger *if* the
agent honors it — which is itself unverifiable (see Q3).

**2.** Always-loaded core: CLAUDE.md is 112 lines (~1.2–1.5k tokens filled) plus the mandatory
DoD row (51 lines) ≈ **under 2k tokens — genuinely cheap**. A typical schema-touching phase
pulls DoD + gate-command + rollback-process + database rulebook + review templates ≈ 500–700
lines ≈ 6–9k tokens. The table does limit reading — the full governance corpus is ~1,960
lines plus ~1,600 lines of `/speckit.*` prompts, and no single phase needs more than a third
of it. But the real cost is not tokens, it's attention: a Critical schema phase legitimately
loads 7 documents of competing MUSTs, and MUSTs compete for the same finite compliance budget.
The table is the right mechanism; the corpus behind it needs to stay small for the mechanism
to matter.

**3.** Unfalsifiable rules (agent can claim compliance, nobody can check): constitution X
in its entirety ("performance MUST be considered"); "scalability MUST be considered"; DoD
item 5 — the AI review is **self-graded**: I write the evidence table, I write the verdict,
and a fabricated "Evidence" cell reads identically to a real one (`ai-code-review-template.md:17-29`
mitigates but cannot verify); the Visual Compliance Loop's "empty deviation table" — I author
the table (`review-process.md:19-29`); Task-Scoped Reading (no trace that I read anything);
the territory check "skim their plan.mds" (`team-workflow.md:29-33`); the plan-time
Constitution Check boxes (I tick them). Checkable: exit code (by the user), diff-stat, spec
files existing, human approval. Note the pattern: everything checkable is an artifact;
everything unfalsifiable is a claimed mental act. Convert or delete the mental acts.

**4.** It works for Claude Code (which reads CLAUDE.md natively and ignores AGENTS.md's
indirection) and breaks to varying degrees for everyone else. `@CLAUDE.md` is a Claude Code
include convention; Codex, Cursor, Copilot, and Gemini CLI ingest AGENTS.md (where they read
it at all) as literal text — an 11-byte cryptic token, not an instruction. ASSUMPTION (from my
knowledge of these tools, not testable in this repo): a frontier model will often *guess* and
open CLAUDE.md; a cheaper one won't; none of them inherit ancestor CLAUDE.md files across the
nested-repo boundary the way `repository-strategy.md:80-83` assumes. Fix costs one sentence
(finding 8) plus an actual test against at least Codex — which the author has access to,
per this review process itself.

**5.** The right constitutional core is 8, not 13: I (spec first), II (ladder), IV
(architecture consistency), VII (domain invariants), VIII (security), XI (testing), XII
(human review), XIII (controlled delivery) — these are genuine governance: they allocate
authority and define the trust boundary. IX (integration contracts) is defensible, keep it.
III is topology configuration, not principle — it belongs in repository-strategy.md. V and VI
are database conventions over-promoted; X is aspiration. The cost of over-promotion is real:
constitutional force is a currency, and paying it out for PK naming debases it exactly where
you need it — an agent that has seen five mundane constitutional rules bent "just this once"
has learned the constitution bends (and a PK-standard change now requires a MAJOR version
amendment ritual).

**6.** Defensible in intent, theatre in mechanism. The rule's actual content is "the agent may
not self-certify" — that part is enforceable and I can comply with it. But "the user ran it"
is unverifiable, agent-run gates are already permitted for feedback (`gate-command.md:60-68`),
and within a week a busy user will read the agent's green run and type "gate passed". What
would make it hold: (a) evidence — the gate command appends timestamp/command/exit-code to a
committed `gate-log`, so a claimed run leaves a diff; (b) CI on every push as the second
witness, constitutional for *all* adopters, not just teams (`team-workflow.md:85-89` currently
scopes it); (c) branch protection making merge impossible without the CI status + a human
approval — which converts the ritual from ceremony into a physical property of the repo.

**7.** Per phase, user-side: gate run 2–10 min + diff read 5–15 + skimming the agent's AI
review 5–10 ≈ 15–35 min. A 4-phase Standard feature: ~1–2.5 h of per-phase attention + 1–4 h
spec/plan/tasks approval + 30–60 min final human review — call it **3–7 hours of human
governance per feature**, and if DoD item 6 is read literally (per-phase human review), add
2+ hours more. For small features that exceeds implementation time. The Lite level itself is
fine — gate + diff + review is just normal PR hygiene, it survives deadlines. The failure
mode under deadline is not Lite being heavy; it is **misclassification downward**: features
shipped as `fix/` branches. Nothing detects that today; a trivial CI rule (fix/chore PR
touching a migration or >N files fails) would. The missing middle: a single-phase Standard
feature still owes three documents; allow spec+plan as one document for single-phase features.

**8.** The nested layout (`repository-strategy.md:65-92`) is a genuinely clever answer — one
physical constitution, inherited by cwd — but it holds only for Claude Code (Q4) and only for
local work. The acknowledged hole ("a standalone clone has no governance", :89-92) has no
enforcement: nothing stops a cloud agent or a teammate's bare clone from authoring changes
ungoverned. Partial fixes: a pointer AGENTS.md committed in each code repo; a CI check on code
repos that agent-authored PRs reference a spec path (commit trailer). It is a real hole, but a
manageable one — the unmanageable version would be copied constitutions, which the kit rightly
forbids.

**9.** Ranked by value/effort (value first):
1. **Spec-artifact presence check** — CI on `NNN-*` branches: matching `specs/NNN-*/` with
   spec/plan/tasks present, delivery level declared in spec.md. Low effort, kills the single
   most likely drift.
2. **Branch protection recipe** — required CI status + required human approval + no direct
   push to main. Zero code; a README section. Converts constitution XII/XIII from prose to
   physics.
3. **Lite-lane abuse guard** — `fix/`/`chore/` PR touching migrations or >N files fails CI.
4. **PR template** embedding the human-review checklist — trivial; makes DoD item 6 the
   default path instead of a separate document nobody opens.
5. **Gate log** — gate wrapper appends command+exit+timestamp to a committed file; Critical
   evidence check (rollback.md + both review docs exist in the feature dir before merge).
6. **Agent settings baseline** — kit-shipped `settings.json` deny-by-default (fixes finding 4)
   + a pre-commit hook refusing commits on main.
7. **Constitution↔plan-template mirror check** — parse principle headings vs Constitution
   Check items; catches the finding-3 class mechanically. Medium effort.
8. `-FailOnSlots` turned on post-ratification (exists; make the workflow flip automatic when
   `Ratified:` has a date).

**10.** PowerShell costs you every macOS/Linux adopter's first hour, and worse: the Spec Kit
scripts themselves are the powershell variant only, so `/speckit.specify` dies without pwsh —
that's not a linter inconvenience, it's the tooling layer gone. Minimum story: state `pwsh` as
a hard prerequisite in README and adoption step 0 (one paragraph), and note that CI is
unaffected (ubuntu runners ship pwsh — `doc-lint.yml` already relies on this). Better story:
re-init Spec Kit with the bash script variant alongside, and port doc-lint (~100 lines of
path checks — an afternoon).

**11.** Upstream drift: `/speckit.*` prompts and `.specify/scripts` co-evolve; a project that
runs a newer `specify init` over its copy risks clobbering templates the kit customized
(plan-template's Constitution Check) — and a project that never updates slowly diverges from
the commands' expectations. Today neither the pin ("0.4.4" exists only as a README sentence,
`README.md:26`) nor the boundary (which files are kit-owned vs Spec-Kit-owned vs
project-owned) is recorded anywhere machine-readable. Fix: KIT-VERSION + a manifest of the
three ownership classes + an update procedure ("fetch new kit, diff kit-owned files, re-apply,
bump"). Without it, every adoption is an orphaned fork on day one.

**12.** Realistic drop-off: the mechanical slots are solved by init-kit.ps1; the cliff is the
judgment work — descriptive constitution, invariants pack, descriptive rulebooks, gate proof —
which on an existing system is days of senior effort before the first feature ships. My
prediction: a meaningful share of adopters stall between existing-system steps 2 and 4 with a
half-ratified constitution, which is *worse* than no kit (the agent now reads law full of
`{{SLOTS}}` and learns the law is decorative). Smallest change with the biggest effect:
**sequence the cliff** — define minimum viable ratification (constitution + proven gate only)
sufficient for read-only features, and require the invariants pack only before the first
write-slice feature (the kit already sequences reads-before-writes; align the paperwork with
it). Second smallest: `-FailOnSlots` in CI once ratified, so a stalled adoption is loudly red
instead of quietly rotting.

**13.** The gaps that matter, in order: (a) **agent security** — no injection model for the
artifacts the ladder trusts, no secrets-in-context rule, no permission baseline, and the
shipped settings actively contradict the law (findings 4, 5); (b) **no ADR home** (finding 6);
(c) **no measurement** — the kit cannot tell an adopter whether it is working; not one number
is collected (escaped defects, fix-lane follow-ups, phase cycle time, review findings that
changed code); (d) **deployment-standards is a stub** while being advertised as process law
(finding 13); (e) **no human onboarding** — every document addresses the agent or the adopter;
a developer joining a kit-governed team in month 6 has no "start here, here's why we do this"
page, and a framework the new hire experiences only as friction gets quietly routed around;
(f) no threat model beyond the six generic lines of constitution VIII.

**14.** Falsifiable central claim: "this document system produces better outcomes than
lightweight discipline." Cheapest experiment: **alternate within one real backlog** — ten
comparable small features; odd ones through the full kit, even ones through a baseline of
CLAUDE.md conventions + CI + ordinary PR review. Track three numbers per feature: human
governance minutes, fix-lane follow-up commits touching that feature's files within 14 days,
and review findings that actually changed code. If the kit's features are not measurably
cheaper to review or less defect-prone, the middle layers aren't earning rent. Retrospective
version, nearly free: the 68-feature reference deployment's history already contains the
answer — plot fix-follow-ups per feature over time; if the rate did not fall as the rulebooks
grew, the reactive-rulebook mechanism (the kit's proudest loop) is not doing what it claims.

**15.** For: a 1–5 developer team, heavy agent use, building a system where wrongness is
expensive (money, health, compliance), with one senior person willing to *own* the governance
and hold the gate. Not for: prototypes, teams that don't already do PR review (this kit will
not install discipline that isn't there — it assumes it), or large orgs with an existing
compliance apparatus this would duplicate. Against alternatives: vs plain Spec Kit, the kit
adds the delivery-control layer Spec Kit genuinely lacks (gate, phase discipline, review
artifacts, rollback, invariants) — that is its real value-add. Vs "good CLAUDE.md + PR
template + CI": today, honestly, the kit *is* that plus ~1,500 lines of prose, because the
enforcement is equivalent (one linter). The enforcement pack is what would separate them.
Vs nothing: nothing is better than a half-adopted kit (see Q12).

**16.** Pitch: *a copy-in document system that makes an AI agent ship one reviewed, gated,
reversible phase at a time, with a human holding the only pen that writes "Done".* Warning
label: *~2,000 lines of law enforced by one path-linter and your own discipline — if you
won't personally hold the gate ritual past feature 3, this will be slower than no framework,
because you'll be pretending.*

## Cut list

1. **Delete constitution X (Performance Responsibility).** Wholly unfalsifiable ("MUST be
   considered"); it survives today because deleting a principle feels like losing coverage,
   but vibes-law dilutes the enforceable principles around it. A performance question in
   plan-template does the same job checkably.
2. **Demote constitution V (PK standard) and VI (audit fields) to the database rulebook.**
   They are schema conventions, already parameterized like rulebook content; they survive as
   principles only because they came from the reference deployment's constitution. Cutting
   them takes the constitution to 10 and makes VII (invariants) visibly special again.
3. **Merge `review-process.md` into `definition-of-done.md`** as one "phase-close protocol".
   They cover the same event with ~60% overlap (compare `definition-of-done.md:10-36` with
   `review-process.md:31-79`); two documents describing one moment is how finding 1's
   contradiction was born. One document, one unit of review, one checklist.
4. **Delete `speckit.taskstoissues`** (`.claude/commands/speckit.taskstoissues.md`) — a
   GitHub-specific 30-line convenience no kit document references; it survives because it
   arrived with stock Spec Kit. Ship the kit's curated command set, not upstream's whole bag.
5. **Downgrade the roadmap template's generated Inventory section to optional.** It encodes
   the reference deployment's prototype-driven workflow (`roadmap-template.md:13-24`); most
   adopters have no prototype corpus to "generate" from, and a mandatory-looking empty section
   invites cargo-culting. Keep the authored roadmap + decisions log as the required core.

## Build plan

The pain of phrasing this in the kit's own shape, first, because it is data: **this repo has
never run its own Standard lane** — every one of its 12 changes legitimately took the `docs/`
Lite lane, so the kit's spec→plan→phase→gate machinery has zero self-applied mileage, and this
plan's features are the first things heavy enough to force it. Second pain: the kit's gate is
undefined for the kit itself (`gate-command.md` slots are unfilled here) — the honest gate for
a document system is `doc-lint.ps1 -FailOnSlots` plus the new checks feature 002 adds, and
that had to be *decided*, which proves adoption step 3 ("define and prove the gate") is real
work even for the kit's own author.

### v1 — must ship (max 7 features)

**001-dod-unit-fix** — resolve the phase-vs-feature review contradiction (finding 1).
*Why first:* every later feature is reviewed under the rule this fixes; and it forces the
kit's first constitutional amendment through its own amendment procedure — rehearsal with
stakes. *Phases:* (1) amend DoD + merge review-process into it (cut list #3) + align
constitution XII wording and SYNC IMPACT REPORT; (2) sweep every cross-reference. *Acceptance
(mechanical where possible):* doc-lint green; zero occurrences of per-phase human-review
language (`grep` for it); constitution version bumped with amendment recorded. *Effort:* S.
*Cost to skip:* the central checklist stays impossible to follow; everything else is built on
sand.

**002-enforcement-pack** — CI checks: spec-artifact presence for `NNN-*` branches, delivery
level declared, lite-lane abuse guard, Critical-evidence presence, `-FailOnSlots` auto-on
after ratification; plus a PR template embedding the human-review checklist and a documented
branch-protection recipe. *Why here:* converts the kit's core promises from prose to physics;
highest value per effort of anything in this review. *Phases:* (1) checks as a script (make it
runnable by any CI, not just Actions); (2) workflow + PR template; (3) adoption-doc wiring.
*Acceptance:* a deliberately broken fixture branch fails each check; a clean one passes; kit's
own CI runs the pack. *Effort:* M. *Cost to skip:* the kit remains an honor system and finding
2 stands.

**003-agent-security-baseline** — one-page threat doc (ladder artifacts trusted only after
human approval; untrusted content never becomes instructions; secrets never in session
context), kit-shipped deny-by-default agent `settings.json`, fix `.claude/settings.local.json`.
*Why here:* the kit governs agents and currently says nothing about the one attack class
unique to agents; also repairs the shipped contradiction (finding 4). *Phases:* (1) doc +
settings; (2) wire into CLAUDE.md's always row and adoption step 0. *Acceptance:* doc-lint
green; settings file contains no allow rule for merge/push/checkout; CLAUDE.md references the
doc. *Effort:* M. *Cost to skip:* first prompt-injection incident lands on a framework that
claimed to be the adult in the room.

**004-adr-home** — `docs/adr/` + template; constitution IV amended: architecture-changing
plan.md approvals must land an ADR in the same feature; scaffold guidance copies its decision
to ADR-0001. *Phases:* one. *Acceptance:* doc-lint green; constitution IV references the path;
greenfield step 4 updated. *Effort:* S. *Cost to skip:* "the existing architecture" degrades
into archaeology and principle IV quietly becomes "whatever the code does" (finding 6).

**005-kit-versioning** — KIT-VERSION, CHANGELOG, ownership manifest (kit-owned / Spec-Kit-owned
/ project-owned files), documented update procedure, recorded Spec Kit pin. *Phases:* one.
*Acceptance:* manifest lists every top-level path exactly once; update procedure tested by
diffing against a scratch copy. *Effort:* S. *Cost to skip:* every adoption is an orphaned
fork; the first upstream Spec Kit change strands them all (finding 9).

**006-cross-agent-contract** — real AGENTS.md (imperative sentence, not `@`-token), per-agent
compatibility notes, pointer files for nested code repos, and an actual smoke test of at least
one non-Claude agent following the pointer. *Phases:* (1) files; (2) test + record results
honestly, including failures. *Acceptance:* AGENTS.md contains an imperative instruction;
repository-strategy's inheritance claim rewritten to state which agents it holds for.
*Effort:* S/M. *Cost to skip:* the "cross-agent" claim in README stays fiction (finding 8).

**007-adoption-sequencing** — define minimum viable ratification (constitution + proven gate →
read-only features allowed; invariants pack gated before first write feature), restructure
both adoption tracks around it, and add a `docs/metrics.md` ledger template (per feature:
governance minutes, fix-lane follow-ups in 14 days, review findings that changed code) so
adopters collect the kill-criterion data from day one. *Phases:* (1) adoption docs; (2)
metrics template + wiring. *Acceptance:* doc-lint green; both tracks name the minimum
ratification point; metrics template referenced from DoD. *Effort:* M. *Cost to skip:*
the 109-slot cliff keeps eating adopters (finding 10) and the kit stays unmeasurable (Q13/Q14).

### v1.1 — should

- Cross-platform story: bash variant of Spec Kit scripts + doc-lint port (finding 11).
- Human onboarding page ("why we work this way", for the month-6 hire).
- Expand deployment-standards past placeholder (it already mandates its own spec-first
  expansion — honor that).
- Second worked domain-invariants module (non-finance) to prove the shape generalizes.
- Constitution↔plan-template mirror check (Q9 item 7).
- Gate-log wrapper (Q9 item 5) — should, not must, because branch protection (002) covers
  most of the trust gap first.

### Rejected, deliberately

- **Stack profile/recipe libraries and pre-filled rulebooks** — they rot and lie; the kit's
  own stated reasoning (`stack-profile-template.md:6-9`) is correct. Stays rejected.
- **A YAML/manifest-driven config layer or web-based kit generator** — the kit's medium is
  markdown read by agents; a second machine layer doubles the drift surface for zero agent
  benefit.
- **Pixel-diff visual testing tooling** — the review process already argues correctly that
  prototypes never pixel-match real renders (`review-process.md:14-18`).
- **Multi-constitution federation for multi-repo** — the one-constitution rule is the kit's
  best idea; complicating it to solve finding 8's edge cases would trade a real principle for
  a hypothetical convenience.
- **More delivery levels** — three is already one more than most teams will classify
  correctly; the fix for misclassification is CI detection (002), not taxonomy.
- **Agent-run gate elimination** — tempting after Q6, but the fast-feedback loop is what makes
  one-phase delivery bearable; the fix is evidence, not prohibition.

### Kill criterion

If, after two adoptions outside the author's own hands each shipping ≥10 features, the
evidence trail shows both teams abandoned the per-phase ritual (no per-phase commits, no
recorded gate results, batched multi-phase reviews) **and** the metrics ledger shows no
improvement in fix-lane follow-ups or review cost against the team's own pre-kit baseline —
then the middle layers are dead weight: collapse the kit to the five non-negotiables plus the
enforcement pack, archive the rest, and stop calling it a framework.

## Assumptions and blind spots

- **ASSUMPTION:** exact ingestion behavior of Codex/Cursor/Copilot/Gemini for `AGENTS.md` and
  `@`-includes is from my general knowledge of these tools, not tested here; versions change
  fast. Feature 006 exists to replace this assumption with a recorded test.
- **Unverifiable from this repo:** the 68-feature provenance, the reference deployment's
  defect history, and every claim about what "battle-tested" means (`README.md:87-92`). My Q14
  retrospective assumes that history is accessible to the author; if it isn't, the cheapest
  falsification is the alternating-features experiment only.
- **My weakest ground:** ceremony-hour estimates in Q7 are reasoned, not measured — real
  numbers depend on gate runtime and reviewer familiarity; treat them as order-of-magnitude.
  Likewise "drop-off at existing-system steps 2–4" is a prediction from my experience of how
  teams treat unfilled templates, with N of exactly the author's own trial adoptions to check
  it against — which are not independent evidence.
- **Perspective bias:** I am an agent reviewing a framework for governing agents. I am most
  credible on Q1–Q3 (what actually changes my behavior) and least credible on how much
  ceremony a human team will tolerate — I don't feel the friction of running a gate at 6pm.
- I did not execute `init-kit.ps1` or `doc-lint.ps1` (the brief forbids modifying the repo and
  init rewrites files in place); my reading of their behavior is static analysis of the
  scripts.
