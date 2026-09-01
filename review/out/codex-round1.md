# codex — Round 1 Independent Review

## Verdict

The kit's main risk is that it substitutes attestations for controls: an agent and its owner can check boxes, paste an exit code, and satisfy most of the framework without proving the change is correct. I would not adopt it unchanged on a real project because the per-phase ceremony is too expensive for ordinary work, the cross-repository inheritance model knowingly leaves common authoring environments ungoverned, and the only CI control checks document paths. I would pilot a smaller core only after making artifact/CI checks executable, defining an agent security boundary, and measuring whether the ritual reduces defects enough to repay its interruption cost. The claimed 68-feature provenance demonstrates use by one author, not causal effectiveness or year-long adoption by an outside team (`README.md:3-5`; `docs/sdlc/team-workflow.md:3-5`).

## Findings
| # | Severity | Area | Finding | Evidence (path:line) | Recommendation |
|---|----------|------|---------|----------------------|----------------|
| 1 | BLOCKER | Trust boundary | The user-held gate is an unverifiable recital, not a durable control. The owner who drove the agent also runs and reports the gate; ordinary features retain no required evidence, and the template accepts a typed exit code. | `docs/sdlc/team-workflow.md:7-12`; `docs/sdlc/gate-command.md:60-68`; `specs/_templates/human-pr-review-template.md:26-32` | Make protected-branch CI the merge control and store job URL, commit SHA, command/version, and result. Keep a local owner-run gate as fast feedback, not certification. |
| 2 | BLOCKER | Agent security | There is no threat model for prompt injection, hostile repository/issue/web text, secret exposure to model context, or tool/MCP boundaries; the shipped local settings broadly allow checkout, add, and merge. | `.specify/memory/constitution.md:143-149`; `.claude/settings.local.json:1-8`; `docs/sdlc/deployment-standards.md:11-14` | Ship a deny-by-default agent-security policy, sanitized untrusted-input handling, secret redaction rules, tool/MCP allowlists, and a reviewed minimal settings example. |
| 3 | BLOCKER | Multi-repo governance | “One constitution” only works in a specially nested local checkout. The document concedes that standalone clones and cloud-agent authoring have no governance; parent-directory instruction discovery is also tool-specific. | `docs/sdlc/repository-strategy.md:65-92`; `.specify/memory/constitution.md:196-201` | Publish a versioned governance package/lockfile and verify the same digest in every repo's CI; place a native agent entry file in each repo. Do not depend on ancestor discovery. |
| 4 | MAJOR | Enforcement | CI validates only path existence and explicitly treats unresolved slots as informational. None of phase scope, approval, branch/spec mapping, evidence, review, or gate claims is enforced. | `scripts/doc-lint.ps1:11-25`; `scripts/doc-lint.ps1:126-145`; `.github/workflows/doc-lint.yml:11-16` | Add a machine-readable feature manifest and a PR check for branch/spec mapping, required artifacts, completed slots, gate CI, approvals, and risk level. |
| 5 | MAJOR | Ceremony | A four-phase Standard feature invokes six gates four times: 24 checklist decisions, including four full gates, four diff reviews, four AI reviews, four human reviews, and phase commits. The specification approval is redundantly reasserted each phase. | `docs/sdlc/definition-of-done.md:7-36`; `.specify/memory/constitution.md:50-54` | Gate per PR/merge by default; use phase checkpoints only at risk boundaries. Make phase-level human review optional for Standard and mandatory for Critical. |
| 6 | MAJOR | Delivery levels | Lite is not meaningfully lite for a small fix: it still requires a full user-run gate, scope check, and human review. A typo and a risky dependency upgrade occupy the same lane, while risk is declared by the feature author. | `docs/sdlc/branch-strategy.md:35-49`; `docs/sdlc/critical-delivery.md:12-23` | Define mechanically detectable escalation triggers and a truly trivial lane (CI + diff + normal PR policy); prohibit Lite for dependencies, auth, schema, contracts, and domain invariants. |
| 7 | MAJOR | Internal consistency | Stock tasks say tests are optional unless explicitly requested, while the constitution requires automated tests for business-critical behavior and Critical is triggered by domain invariants/auth/payment. This invites an agent to generate an under-tested plan that still looks template-compliant. | `.specify/templates/tasks-template.md:8-12`; `.specify/memory/constitution.md:168-175`; `docs/sdlc/critical-delivery.md:25-33` | Patch/fork the template: tests are required when risk triggers apply and any omission needs a recorded, CI-visible exception. |
| 8 | MAJOR | Adoption | The initializer automates names and copies but deliberately leaves the hard work—gates, invariants, rulebooks, stack profile—and the repository currently contains 124 slot/TODO occurrences. The shortest path still asks a new adopter to author a governance system before receiving value. | `README.md:43-58`; `scripts/init-kit.ps1:185-203`; `adoption/greenfield.md:24-54` | Provide opinionated runnable presets and an interactive validation report; reduce required initial decisions to project type, gate, risk profile, and owners. Defer craft rulebooks until measured mistakes recur. |
| 9 | MAJOR | Portability | Installation and Spec Kit automation are PowerShell-only. GitHub happens to install `pwsh`, but adopters need an extra runtime and non-Windows shell conventions are second-class. | `.specify/init-options.json:7-10`; `adoption/greenfield.md:21-22`; `.github/workflows/doc-lint.yml:9-16` | Provide one cross-platform entry command using a ubiquitous project runtime or POSIX shell plus PowerShell; test Windows, Linux, and macOS in CI. |
| 10 | MAJOR | Versioning | Spec Kit is copied and pinned to 0.4.4, but there is no update policy, compatibility test, changelog of local patches, or project-side lock/migration mechanism. The commands and templates can silently diverge from upstream and from constitutional mirrors. | `README.md:23-27`; `.specify/init-options.json:1-10`; `.specify/templates/plan-template.md:34-38` | Version this kit independently; record upstream version plus patch set in a lockfile; provide `check-update` and explicit migrations with fixture tests. Never overwrite adopted local policy files. |
| 11 | MAJOR | Deployment | The framework claims controlled delivery while deployment governance is explicitly a placeholder and says deployments are manual. Rollback is mostly `git revert`, which does not restore data, configuration, external effects, or compatibility. | `docs/sdlc/deployment-standards.md:1-20`; `docs/sdlc/deployment-standards.md:34-37`; `specs/_templates/rollback-template.md:15-30` | Remove deployment from the governed claim for v1 or ship minimum environment, migration, rollout, observability, rollback, and break-glass standards. |
| 12 | MAJOR | Architecture records | The bootstrap clause demands an ADR-style decision but stores it in a feature plan; there is no stable ADR index/home, so later agents must know which historical feature contains the current decision and how supersession works. | `.specify/memory/constitution.md:98-108`; `adoption/greenfield.md:63-69` | Add `docs/adr/NNNN-*.md` with status/supersedes metadata and an index; plans link to ADRs rather than becoming the permanent architecture registry. |
| 13 | MAJOR | Evidence | “68 features” is the sole effectiveness evidence. There is no baseline, comparator, escaped-defect count, rework rate, cycle time, abandonment rate, or agent-caused incident measure. | `README.md:3-5`; `README.md:86-92` | Reframe as a case-derived hypothesis and instrument a prospective pilot against a lighter control workflow. Publish negative results and attrition. |
| 14 | MINOR | Constitutional scope | Principles V, VI, X, and much of XI are project craft/quality policy, not stable governance. Their constitutional promotion forces template mirroring and semantic-version ceremony for changes such as primary-key strategy. | `.specify/memory/constitution.md:110-130`; `.specify/memory/constitution.md:159-175`; `.specify/memory/constitution.md:203-216` | Keep constitution to authority, evidence, risk, review, change control, and source precedence. Move data/audit/performance/test details into versioned domain or tier policies. |
| 15 | MINOR | Visual review | The visual loop rejects pixel diff categorically and requires recapture after every fix. It creates high manual cost while leaving “compare structure and specification” subjective and self-attested. | `docs/sdlc/review-process.md:9-29` | Require one final capture and automated screenshot/a11y checks where feasible; use human deviation review only for meaningful reference mismatches. |

## Answers to the brief

1. Rules that changed my behavior immediately were: inspect instructions before acting, do not edit outside the named output, preserve scope, follow explicit source precedence, and stop on conflict. In implementation work, “one approved phase,” no unapproved dependencies/architecture, exact branch/spec mapping, and a user-confirmed gate would also create clear stop conditions (`CLAUDE.md:35-78`). Rules I would drift from by turn 30 are “performance/scalability considered,” generic security reminders, checking all 13 principles twice, exhaustive visual comparison, and repeated self-attested checklists; they lack triggers, observable outputs, or tool enforcement (`.specify/memory/constitution.md:143-175`; `.specify/memory/constitution.md:213-217`). From my perspective as the target agent, concise rules tied to a tool result or forbidden action survive; repeated rationale and broad “consider” language compete with the current task and fade after compaction.

2. The nominal always-loaded core is 112 lines/~758 whitespace-delimited tokens in `CLAUDE.md`, plus 219 lines/~1,443 such tokens if “The Law” causes the constitution to be loaded; any phase also requires the 51-line Definition of Done (`CLAUDE.md:19-21`; `CLAUDE.md:82-101`). That is roughly 2,600 whitespace tokens before task-specific rulebooks and feature artifacts—not ruinous once, but paid repeatedly and partly duplicative. The Task-Scoped Reading table does limit craft-doc loading during implementation, but full compliance at planning/review requires the constitution, DoD, review templates, relevant rulebooks/checklists, and potentially repository/rollback/critical documents. For this review, the framework itself required everything; for ordinary backend work it need not.

3. Unfalsifiable or weakly falsifiable rules include “performance considered,” “scalability considered,” “security implications considered,” “business intent” verified, “domain correctness” verified, “architecture compliance,” “scope reviewed,” and the claim that the human actually ran the reported command (`.specify/memory/constitution.md:159-166`; `specs/_templates/human-pr-review-template.md:8-32`; `specs/_templates/ai-code-review-template.md:3-18`). A checkbox or prose assertion is not evidence unless bound to commit-addressed artifacts, test output, reviewer identity, and protected CI.

4. `AGENTS.md` contains only `@CLAUDE.md` (`AGENTS.md:1`). In this Codex session it prompted me to read `CLAUDE.md`, but that is evidence about this harness, not a portable include standard. A consumer that treats `AGENTS.md` as plain instructions may see only an unexplained token; a consumer that ignores `AGENTS.md` sees nothing; a consumer that searches only the repository being edited misses the parent governance file in the recommended multi-repo layout. The repository itself admits standalone/cloud-agent clones have no governance (`docs/sdlc/repository-strategy.md:89-92`). ASSUMPTION: Cursor, Copilot, and Gemini CLI do not all implement Claude-style `@` inclusion identically. Generate tested native entry files (or duplicate a short generated core with a digest), and run compatibility smoke tests for every claimed agent.

5. The constitutional set mixes two classes. Governance: I specification first, II precedence/conflict, IV architecture change approval, VII domain-invariant authority, IX contract governance, XII accountable human review, XIII controlled/risk-based delivery, and the amendment rules. Project craft: III repository topology, V primary keys, VI audit/soft-delete fields, VIII's generic coding controls, X performance advice, and XI test detail (`.specify/memory/constitution.md:19-32`). Security and testing deserve mandatory policy, but not necessarily constitutional wording. Over-promotion multiplies mirrors, amendments, checklist fatigue, and false constitutional violations whenever a technical convention changes (`.specify/memory/constitution.md:203-216`).

6. The boundary is defensible as a conversational brake—it stops me from self-certifying—but theatrical as proof. The owner both directs the agent and reports its exit code (`docs/sdlc/team-workflow.md:7-12`), and Standard work need not retain evidence. It holds only when protected CI reruns an immutable command against the exact commit, required checks cannot be bypassed without logged break-glass approval, and reviewer identity/approval are platform-enforced. Local gate output remains useful feedback.

7. Four phases produce 24 gate-item evaluations: specification approval asserted four times, four scope assertions, four full user gate runs, four diff reviews, four AI reviews, and four human approvals, plus four phase commits (`docs/sdlc/definition-of-done.md:10-36`). Realistically, with a 10–20 minute gate, 10–20 minute AI/evidence review, 15–30 minute human review, and 5–10 minute handoff/diff/commit, ceremony is about 160–320 minutes before queueing; asynchronous reviewer latency can stretch four phases across days. Lite removes spec artifacts but still keeps gate + diff + human review, so it is tolerable for a risky fix but not light enough for typos or low-risk docs (`docs/sdlc/critical-delivery.md:12-16`).

8. Yes, it is a real hole. The proposed solution is one parent specs repository with nested code repositories, relying on agents to inherit ancestor instructions (`docs/sdlc/repository-strategy.md:65-83`). The same document admits standalone clones and cloud authoring lose all governance (`docs/sdlc/repository-strategy.md:89-92`). Three repos need a canonical versioned policy artifact, a pinned digest in each repo, automated drift checks, and native entry points; physical “exactly one file” is less important than one authoritative version.

9. Ranked by value/effort:

   1. **High value / low-medium effort:** required CI gate on exact SHA; protected branch; CODEOWNERS/independent approval for Critical; branch `NNN-name` ↔ `specs/NNN-name/`; `-FailOnSlots` after adoption.
   2. **High / medium:** PR check for required `spec.md`/`plan.md`/`tasks.md`, declared risk level, Critical rollback/evidence, unresolved placeholders, and changed-file scope versus the plan.
   3. **High / medium-high:** secret scanning, dependency review, SAST, migration/destructive-SQL checks, contract/schema compatibility, and native agent permission policy validation.
   4. **Medium / low:** PR templates linking spec, CI run, review evidence, and exception; generated rather than manually copied checklists.
   5. **Medium / medium:** governance lock/digest checks across repos and Spec Kit compatibility fixtures.
   6. **Low-medium / low:** pre-commit hooks for fast feedback only; they are bypassable and should never be the authority.

   Today only required-path resolution exists and slots are informational by default (`scripts/doc-lint.ps1:11-25`; `.github/workflows/doc-lint.yml:12-16`).

10. PowerShell-only automation costs an extra runtime, unfamiliar syntax, corporate execution-policy friction, and weaker local parity on many Linux/macOS projects; even the gate guide must explain three shells (`docs/sdlc/gate-command.md:22-36`). Minimum viable portability is a single documented cross-platform command, CI on Windows/Linux/macOS, and equivalent init/lint behavior. A small Node/Python binary is acceptable only if the chosen preset already owns that runtime; otherwise ship POSIX shell plus PowerShell wrappers around a shared declarative schema.

11. Upstream changes can alter templates, command behavior, branch allocation, and expected artifacts while this kit's constitutional mirror stays frozen. The receipt pins `speckit_version` 0.4.4 (`.specify/init-options.json:1-10`), but no update contract exists. Give the kit its own semantic version, a lockfile containing upstream version and local patch hashes, compatibility fixtures, release notes, and idempotent migrations. Adopted projects should pin a kit version and explicitly merge migrations; never recopy the tree over locally authored constitution/rulebooks.

12. The exact repository count is 124 occurrences across 111 Markdown lines, including the review brief itself; the lint script reports them but passes by default (`scripts/doc-lint.ps1:133-145`). A motivated author may finish; an outside team will stall when it reaches domain invariants, descriptive rulebooks, gates, topology, and ratification before feature 001. The smallest high-leverage change is three runnable presets (single-repo web, service, frontend) that generate a minimal valid core, delete irrelevant templates, enable fail-on-slots, and leave no more than four explicit human decisions. Show a “ready/not ready” report rather than a search command.

13. Material gaps are:

   - Agent threat model: prompt injection through repo/issues/web, instruction provenance, secret/context handling, tool and MCP allow/deny policy, network/exfiltration boundaries, and malicious generated commands. Constitution VIII only covers application security (`.specify/memory/constitution.md:143-149`), while local settings authorize mutation commands (`.claude/settings.local.json:1-8`).
   - Stable ADR storage and supersession; the only prescribed architecture record is a historical scaffold `plan.md` (`adoption/greenfield.md:63-69`).
   - Real deployment governance, environment promotion, observability, feature flags, compatibility windows, migration order, and practiced rollback; the document calls itself a placeholder (`docs/sdlc/deployment-standards.md:1-20`).
   - A system/product/agent threat model and risk register.
   - Outcome measurement: escaped defects, rework, cycle/queue time, gate failure causes, agent-caused incidents, exceptions, checklist completion quality, and abandonment.
   - Beginner onboarding: a 30-minute runnable tutorial, example completed feature, roles glossary, failure recovery, and a “why did CI reject this?” guide. Current onboarding starts with ratifying and authoring policy (`adoption/greenfield.md:24-54`).
   - Exception lifecycle: owner, expiry, compensating control, and debt tracking. “Justified in Complexity Tracking” has no expiry (`.specify/memory/constitution.md:213-217`).

14. The central claim is falsified if comparable agent-assisted work under this kit has no meaningful reduction in escaped defects/rework/agent-caused incidents, or if any gain is outweighed by cycle time and teams bypass/abandon it. Cheapest credible experiment: take 12–20 small, representative tasks from one maintained codebase; stratify by risk and randomly assign within pairs to (A) minimal Spec Kit + protected CI/PR review and (B) this kit. Use the same models, developers, repository, tests, and reviewer pool. Blind reviewers score acceptance defects, unrelated changes, security/domain misses, and rework; record active minutes, queue time, tokens, gate runs, exceptions, and compliance. Predefine failure as no defect/rework improvement plus >25% median active-time increase, or >20% material bypass after four weeks. A crossover design reduces developer/model skill bias. This will not prove year-long retention, so follow with a three-team, 90-day external pilot.

15. Best fit: a 1–5 person team using capable coding agents on a long-lived, domain-heavy system where mistakes are costly, specs can be written, CI exists, and a human domain reviewer is genuinely available. Poor fit: prototypes, throwaway scripts, solo hobby work, high-volume tiny changes, teams without reliable tests/review capacity, monorepos that reject one-phase-per-commit, or organizations already enforcing equivalent controls in an internal platform. Against alternatives: plain Spec Kit supplies artifact generation without this governance burden; `AGENTS.md`/`CLAUDE.md` alone supplies behavioral conventions but weak evidence; PR template + protected CI supplies stronger enforcement with less domain guidance; nothing is fastest and least controlled. The kit should position itself as a risk overlay on Spec Kit and CI, not as a replacement for CI or proof of correctness (`README.md:7-18`).

16. Honest pitch: **A configurable, case-derived set of repository instructions and review artifacts that can slow coding agents down at explicit risk boundaries while preserving human approval.** Honest warning label: **Most controls are currently prose and self-attestation, adoption requires substantial policy authoring, and there is no evidence yet that outside teams get fewer defects than they would from protected CI, a PR template, and plain Spec Kit.**

## Cut list

1. **Delete constitutional principles III, V, VI, and X as universal principles; move them to topology/domain/tier policy.** They survive because they reflect the source financial system's architecture and concerns, not because every adopter needs constitutional repository separation, primary keys, soft delete, or generic performance prose (`.specify/memory/constitution.md:81-130`; `.specify/memory/constitution.md:159-166`).
2. **Merge `gate-command.md`, `definition-of-done.md`, and the process section of `review-process.md` into one short delivery policy.** They survive as separate documents because the framework was extracted layer-by-layer, but they repeat the same gate/diff/review/merge sequence (`docs/sdlc/definition-of-done.md:10-36`; `docs/sdlc/review-process.md:31-43`). Keep visual review separate and optional.
3. **Downgrade per-phase human review and full gates to Critical/risk-boundary phases; Standard reviews once per PR.** The rule survives because small phases were the reference deployment's safety mechanism, but four-phase work creates four queues without showing that each queue catches defects (`.specify/memory/constitution.md:186-194`).
4. **Delete mandatory code comments that cite contract files.** They survive as a workaround for weak traceability (`docs/rulebooks/backend-rules-template.md:35-39`; `docs/rulebooks/integration-rules-template.md:13-18`). Generate traceability from feature manifest/paths and contract tests; comments rot.
5. **Make the roadmap template and second-model audits optional.** They survive as practices from the source deployment, but neither is needed to enforce a feature and periodic second-model review has no defined cadence, quality bar, or evidence of benefit (`adoption/existing-system.md:60-66`; `specs/_templates/roadmap-template.md:1-11`).
6. **Delete most rationale prose from always-consumed policy and eliminate mirrored 13-item Constitution Checks.** Rationale belongs in author documentation; runtime controls should name trigger, required artifact, and verifier. The mirror currently creates synchronization work by design (`.specify/templates/plan-template.md:30-52`).

## Build plan

### v1 — must ship (max 7 features)

1. **`001-minimal-governance-core` ↔ `specs/001-minimal-governance-core/`**
   - **Goal:** reduce the constitution to enforceable governance, consolidate delivery documents, define Standard/Critical risk triggers, and make phase checkpoints risk-based.
   - **Why first:** automation would otherwise encode the current contradictions and ceremony.
   - **Phases:** (1) decision matrix and cuts; (2) rewrite core/pointers/templates; (3) migration guide and completed example.
   - **Acceptance:** no rule is stated in more than one authoritative file; a script verifies all pointers and mirrors; Standard needs one merge gate/review; Critical triggers are enumerated; runtime core has a measured token budget and no unresolved slots in the example.
   - **Effort:** M.
   - **Skip cost:** every later feature institutionalizes ambiguity and adoption fatigue.

2. **`002-agent-security-boundary` ↔ `specs/002-agent-security-boundary/`**
   - **Goal:** add the missing threat model and minimum tool/context/MCP/secrets policy.
   - **Why here:** running external pilots before defining the agent trust boundary is negligent.
   - **Phases:** (1) assets/threats/trust boundaries; (2) policy and safe settings examples; (3) adversarial fixtures.
   - **Acceptance:** fixtures cover malicious repo instructions, issue/web prompt injection, secret-like values, unapproved network/tool calls, and destructive commands; CI validates settings against an allowlist; no shipped example grants merge rights by default.
   - **Effort:** M.
   - **Skip cost:** the framework governs code style while leaving the agent itself as an unmodeled attack surface.

3. **`003-enforceable-pr-gate` ↔ `specs/003-enforceable-pr-gate/`**
   - **Goal:** replace self-attestation with protected-CI-verifiable feature evidence.
   - **Why third:** it turns the reduced policy into controls before improving packaging.
   - **Phases:** (1) machine-readable feature manifest/schema; (2) PR validator; (3) GitHub reference workflow and bypass audit.
   - **Acceptance:** test fixtures prove rejection of branch/spec mismatch, missing required artifacts, unresolved slots, undeclared Critical changes, missing rollback, failed exact-SHA CI, and owner self-approval where independence is required; positive fixtures pass on Windows/Linux.
   - **Effort:** L.
   - **Skip cost:** the kit remains a checklist that cooperative users can simulate.

4. **`004-cross-platform-adopter` ↔ `specs/004-cross-platform-adopter/`**
   - **Goal:** make a fresh project usable through one command and opinionated presets.
   - **Why fourth:** onboarding should target the now-enforceable v1 shape, not the old 124-marker tree.
   - **Phases:** (1) declarative config and three presets; (2) init/lint/migrate commands; (3) Windows/Linux/macOS CI and 30-minute tutorial.
   - **Acceptance:** clean fixtures for service, single-repo web, and frontend initialize non-interactively; zero unresolved mandatory slots; repeated init is idempotent; all three OS jobs produce identical normalized output; tutorial completion is timed by a novice tester.
   - **Effort:** L.
   - **Skip cost:** external teams drop before the first feature and PowerShell remains a selection filter.

5. **`005-versioned-distribution` ↔ `specs/005-versioned-distribution/`**
   - **Goal:** package the kit and patched Spec Kit with a lockfile, compatibility contract, upgrades, and multi-repo governance digest.
   - **Why fifth:** distribution/versioning should stabilize only after core and installer behavior stabilize.
   - **Phases:** (1) kit/upstream lock schema and patch inventory; (2) install/check/update/migrate; (3) cross-repo/native-agent compatibility matrix.
   - **Acceptance:** each repo can verify the same governance digest; update dry-run reports local conflicts and never overwrites authored policy; fixtures migrate n-1 to current; native entry smoke tests cover each officially claimed agent; standalone/cloud clones receive governance.
   - **Effort:** L.
   - **Skip cost:** copied projects fork silently and upstream drift becomes unrepairable.

### v1.1 — should

6. **`006-architecture-deployment-records` ↔ `specs/006-architecture-deployment-records/`**
   - **Goal:** add durable ADR indexing and a minimum real deployment/rollback standard.
   - **Why after v1:** important for mature use, but not needed to test whether the core workflow changes agent outcomes.
   - **Phases:** (1) ADR schema/index/supersession; (2) environment/promotion/migration/observability/rollback policy; (3) validation fixtures and one rollback drill.
   - **Acceptance:** every architecture-changing plan links an accepted ADR; superseded ADRs resolve to successors; Critical deployment fixtures require rollout, monitoring, data/config rollback, and break-glass evidence; placeholder status is gone.
   - **Effort:** M.
   - **Skip cost:** architecture history stays buried and “controlled delivery” stops at merge.

7. **`007-outcome-evaluation` ↔ `specs/007-outcome-evaluation/`**
   - **Goal:** run and publish the paired-task experiment plus a 90-day external-pilot protocol.
   - **Why last:** evaluate a stable, adoptable v1 rather than today's moving target.
   - **Phases:** (1) preregister measures/thresholds; (2) paired trial; (3) analyze, publish, decide continuation.
   - **Acceptance:** raw anonymized task-level data and analysis are reproducible; comparator is protected CI + PR template + plain Spec Kit; defects/rework/time/bypass are reported including negative results; three external teams are recruited or the lack is reported as a failed adoption signal.
   - **Effort:** M.
   - **Skip cost:** positioning remains an anecdote and accretion has no feedback brake.

### Rejected, deliberately

- **No GUI/configurator in v1.** Three presets and a deterministic CLI test adoption more cheaply.
- **No library of stack-specific rulebooks.** It would rot quickly and recreate the slot burden; projects add rules only from observed failures.
- **No support claim for every coding agent.** Claim only agents with automated entry-file/permission smoke tests.
- **No autonomous merge/deploy agent.** It contradicts the human-accountability premise and expands the threat surface before controls mature.
- **No blockchain/signed conversational attestations.** Protected CI and repository audit logs solve the actual evidence problem more simply.
- **No mandatory roadmap, second-model audit, visual deviation table, or phase-per-commit for all work.** These remain opt-in techniques selected by risk.
- **No attempt to govern every deployment platform.** v1.1 defines required properties and evidence, not vendor-specific pipelines.

### Kill criterion

Abandon or radically reshape the kit if the preregistered paired trial plus 90-day pilots show no statistically or operationally meaningful reduction in escaped defects/rework/agent-caused incidents while median active delivery time rises more than 25%, **or** if more than 20% of sampled features materially bypass required controls. Do not answer that result by adding more mandatory documents; collapse the product to the controls that correlated with outcomes—likely protected CI, risk triggers, a short agent policy, and PR evidence.

## Assumptions and blind spots

- I did not inspect the claimed production system, its 68 feature artifacts, incidents, reviewers, or outcome data; the provenance claim is therefore unverified beyond this repository (`README.md:86-92`).
- I did not execute the gate, initializer, or doc-lint, as the brief explicitly prohibited running the gate and asked for review rather than mutation. Script behavior was assessed statically.
- The 124 marker count includes templates and two occurrences in `review/round1-review-brief.md`; it measures adoption surface, not 124 distinct decisions. The repository's own lint counts occurrences across its selected governance documents (`scripts/doc-lint.ps1:103-109`).
- Cross-agent behavior changes by product/version. I directly observed only this Codex harness honoring the repository-provided `AGENTS.md` context; claims about Cursor, Copilot, and Gemini CLI are assumptions pending the compatibility fixtures recommended above.
- Ceremony estimates assume a 10–20 minute full gate and substantive reviews; very fast gates or synchronous pairing lower elapsed time, while reviewer queues raise it substantially.
- My judgment is strongest on agent instruction adherence, enforceability, and developer workflow. It is weaker on regulatory evidence-retention requirements in specific jurisdictions; those require named legal/compliance owners rather than generic “Critical” wording.
