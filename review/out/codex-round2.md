# codex — Round 2 Cross-Review of claude

## Where claude is right and I was wrong

I concede that the unit-of-review contradiction deserves to be the first repair, not merely part of my broader ceremony finding. The DoD defines every phase as incomplete until human approval and says only then may it be committed and merged, while the review process commits each successful phase before its separate human-review/merge section (`docs/sdlc/definition-of-done.md:3-8,30-36`; `docs/sdlc/review-process.md:31-43,60-79`). Claude's narrower diagnosis is more actionable than my recommendation to change the default gating unit without first repairing the contradiction.

I also missed an actual instance of the drift I discussed abstractly: constitution II includes project-wide UI guidelines between screenshots and the feature spec, while `CLAUDE.md` omits that rung (`.specify/memory/constitution.md:59-72`; `CLAUDE.md:27-36`). Claude is right that duplicated law has already diverged before adoption.

I concede that Lite's three controls can be normal PR hygiene when the gate is fast. My Round 1 claim that Lite is categorically too heavy was too broad; the stronger deadline failure is unpoliced downward classification, especially because a `chore/` may include a dependency upgrade and only behavior/schema growth explicitly triggers promotion (`docs/sdlc/branch-strategy.md:35-49`). I still want a truly trivial docs lane, but that is a design preference rather than a demonstrated blocker.

Claude is also right to elevate dogfooding. The decorated history shows all post-extraction topic branches are `docs/`, `fix/`, or `chore/`, and the tree has no completed `specs/NNN-*` trail; the Standard path therefore lacks an in-repository worked run (`git log --oneline --decorate --all`; `docs/sdlc/branch-strategy.md:35-53`).

## Where claude is wrong

| Their claim | Why it fails | Evidence (path:line) |
|---|---|---|
| Codex, Cursor, Copilot, and Gemini ingest `@CLAUDE.md` as 11 bytes of literal text, and the pointer breaks for everyone except Claude Code. | The repository cannot establish behavior for four changing products, and Claude later labels the same assertion an assumption. This Codex review followed the pointer and loaded `CLAUDE.md`, so the categorical Codex claim is false in at least this environment. The valid finding is that portability is untested, not that failure is proven. | `AGENTS.md:1`; `review/out/claude-round1.md` Q4 and “Assumptions and blind spots” |
| The nested layout's one physical constitution is a manageable solution, and copied/versioned governance would be the unmanageable alternative. | The proposed layout explicitly leaves standalone and cloud authoring ungoverned. A one-sentence pointer in each code repo still depends on access to an absent parent file. The evidence supports calling this a real operating-mode failure, not a mere edge case; a versioned generated contract plus digest checking is not the same as competing constitutions. | `docs/sdlc/repository-strategy.md:65-92`; `.specify/memory/constitution.md:196-201` |
| The gate command should append timestamp, command, and exit code to a committed gate log as evidence that the user ran it. | A committed text line is still self-authored evidence: it does not prove who ran the command, that it ran on the reviewed SHA, or that output was not fabricated. It also dirties the feature after the alleged run unless the logged commit itself is gated again. Protected CI bound to the merge SHA is the credible witness; Critical work can retain CI URLs/artifacts. | `docs/sdlc/gate-command.md:60-68`; `docs/sdlc/critical-delivery.md:46-51`; `specs/_templates/human-pr-review-template.md:26-32` |
| The permissions finding cites `.claude/settings.local.json:5` for `git merge *`. | Line 5 permits `git add *`; merge is line 6 and checkout is line 4. The substantive finding holds, but the cited line does not support the stated merge claim. | `.claude/settings.local.json:4-6` |
| “All 12 changes in the log rode the docs Lite lane” is established by `git log --oneline`. | The history supports that named topic branches are docs/fix/chore, but a plain commit log does not prove the branch on which every commit was authored, and the initial `feat:` extraction is not shown as a Lite topic branch. The exact “12” is neither defined nor derived. | `git log --oneline --decorate --all`; `review/out/claude-round1.md` finding 14 |

## Citation check

I checked every citation underlying Claude's 14 finding rows and the disputed Q4, Q6–Q12, cut-list, and build-plan claims against the cited files. The DoD/branch/review contradiction, ladder divergence, missing agent-security policy, absent ADR home, gate ownership, standalone-clone hole, missing kit version/update path, PowerShell-only implementation, constitution-scope critique, deployment placeholder, and roadmap-template claims all hold.

Two citations fail or overclaim: `.claude/settings.local.json:5` is `git add *`, not `git merge *` (merge is line 6), and `git log --oneline` does not prove the exact “all 12 changes” branch-history claim. The 109 unresolved-marker figure does hold when the brief's recursive search is applied to repository Markdown including hidden directories but excluding the newly produced review outputs; the linter itself counts occurrences, not lines (`scripts/doc-lint.ps1:101-109,133-143`). The cross-agent behavior claim has only `AGENTS.md:1` as repository evidence and must remain an explicit compatibility hypothesis pending tests.

## What neither of us saw

The delivery-level control has no source artifact. `critical-delivery.md` says the level is chosen at feature creation and declared in the `spec.md` header, and both reviews propose CI that parses or enforces it (`docs/sdlc/critical-delivery.md:18-23`). But the shipped stock spec template's header contains only branch, date, status, and input—no delivery level (`.specify/templates/spec-template.md:1-6`). An adopter following `/speckit.specify` therefore starts every numbered feature without the required declaration, and an enforcement pack has no stable field to validate. This belongs inside the first consistency repair: add a required `Delivery Level: Standard | Critical` field and make creation/checks reject its absence. Lite has no spec and is inferred from branch taxonomy.

Neither review caught that Critical solo approval is undefined operationally. The addendum replaces an independent human with “a second-model adversarial review plus a cooling-off period,” but the cited adoption step describes a broad codebase/governance audit, not per-feature approval, and no document defines the cooling-off duration, required artifact, approver, or merge control (`docs/sdlc/critical-delivery.md:54-57`; `adoption/existing-system.md:60-66`). This makes the highest-risk solo path less falsifiable than Standard. Define a per-feature second-model review artifact and an explicit delay, or state honestly that solo Critical work requires an external human.

At five developers, feature claiming is also a race protocol without atomic reservation. The script fetches and computes max+1, then creates only a local branch; ownership is not acquired until a later push (`.specify/scripts/powershell/create-new-feature.ps1:95-117,199-217,241-280`; `docs/sdlc/team-workflow.md:14-22`). Two developers can generate the same number and one must rename both branch and spec directory after losing. That is recoverable but exactly the day-4 friction that encourages hand-created branches. The v1 enforcement/creation feature should either reserve remotely as one command or use collision-free identifiers.

## Merged priority list

| Rank | Item | Severity | Both agreed? | Rationale |
|---|---|---|---|---|
| 1 | Repair DoD/review unit, add delivery-level header, and align all mirrors | BLOCKER | Partial | The governing checklist contradicts the workflow, the ladder has already drifted, and risk classification has no template field. Every later control depends on a coherent artifact model. |
| 2 | Ship protected-CI enforcement for exact SHA, branch/spec mapping, artifacts, risk triggers, slots, and approvals | BLOCKER | Yes | The central promises remain attestations until merge can be physically blocked. |
| 3 | Define agent security and ship least-privilege permission baselines | BLOCKER | Yes | The framework governs agents but omits hostile-input, secret-context, tool/MCP, and mutation boundaries while shipping broad git allows. |
| 4 | Fix cross-repository/cross-agent governance with tested native entry contracts and digest checks | BLOCKER | Yes | Recommended standalone/cloud workflows can otherwise author code without the law. Compatibility claims must be tested rather than guessed. |
| 5 | Reduce and sequence adoption; provide a ready/not-ready path with runnable defaults | MAJOR | Yes | The mechanical initializer leaves days of senior judgment before value, and half-ratified law is worse than no law. |
| 6 | Version the kit and define ownership-safe updates from Spec Kit | MAJOR | Yes | Copy-in adoption otherwise creates an orphaned fork with no migration boundary. |
| 7 | Add stable ADR storage and supersession | MAJOR | Yes | Architecture authority cannot remain discoverable if decisions are buried across feature plans. |
| 8 | Define verifiable Critical solo review and evidence | MAJOR | No | The highest-risk solo lane currently substitutes an unrelated audit procedure and an undefined delay for independence. |
| 9 | Instrument an external pilot and publish kill criteria | MAJOR | Yes | The 68-feature provenance cannot establish benefit or sustainable ceremony. |
| 10 | Patch the tests-optional template conflict | MAJOR | Codex only | Stock tasks can omit tests even when constitution XI and Critical triggers require them. |

## Merged build plan delta

The combined critique keeps seven v1 features but changes my Round 1 ordering and boundaries:

1. `001-governance-consistency` moves to first and expands: resolve phase-vs-feature review, remove the duplicated ladder or mechanically mirror it, add the required delivery-level header, patch tests-optional behavior, and define the Critical solo rule. This replaces my narrower ceremony-only treatment.
2. `002-enforcement-pack` stays second but absorbs branch protection, exact-SHA CI evidence, risk-trigger/lane checks, required artifact checks, post-ratification slots, PR approval, and atomic feature-number reservation. I drop the committed gate-log idea.
3. `003-agent-security-boundary` stays: threat model, untrusted-content rules, secret/context policy, tool/MCP policy, and least-privilege agent settings.
4. `004-cross-agent-governance` moves ahead of versioning and expands from entry-file smoke tests to generated native contracts plus a pinned governance digest in each code repo.
5. `005-adoption-presets-and-sequencing` replaces my generic adoption preset feature: minimum viable ratification, runnable small defaults, a readiness report, and a completed Standard example produced by dogfooding features 001–004.
6. `006-kit-versioning-and-update` stays, including kit version, upstream receipt/patch ownership, compatibility fixtures, changelog, and non-destructive migrations.
7. `007-adr-and-measurement` combines the small ADR-home feature with pilot metrics, exception expiry, and kill-criterion collection.

Cross-platform parity and deployment standards move to v1.1. I concede that they matter, but neither should displace a coherent, enforceable core in the seven-feature cap. I drop my separate visual-review feature; its useful automation can enter later through tier checks. I also drop a separate gate-evidence feature because exact-SHA protected CI belongs in `002`.

## Remaining disagreement

The human author must decide whether Standard work is phase-reviewed or feature-reviewed. Claude would make DoD gates 1–5 per phase and human review once before feature merge. I would go further: run fast automated feedback during phases, but make the protected CI gate and accountable human approval authoritative once per PR by default, with phase-level human checkpoints only at declared risk boundaries. Claude's choice preserves tighter incremental control but retains repeated handoffs; mine reduces abandonment risk but allows several phase commits to accumulate before independent review.

The author must also choose the multi-repo authority model. Claude would retain one physical parent constitution and add pointers/compatibility notes. I would publish one canonical version but materialize generated, digest-pinned native contracts in every code repo. Claude's choice minimizes duplicate files but fails when the parent checkout is absent; mine supports standalone/cloud work but requires tooling that proves generated copies have not drifted.

Finally, the author must decide whether solo Critical delivery is permitted. Claude's plan implicitly keeps second-model review plus cooling-off. I would require an external human for Critical changes until a mechanically defined solo exception exists. Allowing solo work preserves usability for the target one-developer audience; forbidding it makes the risk claim honest but excludes that audience from its highest-risk lane.
