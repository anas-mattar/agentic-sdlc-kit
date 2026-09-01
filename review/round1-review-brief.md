# Round 1 — Independent Review Brief

> Paste this whole file as your first message to the agent (or run
> `claude "$(cat review/round1-review-brief.md)"` / `codex "$(cat review/round1-review-brief.md)"`)
> from the repository root. Replace `<YOUR-NAME>` with `claude` or `codex`.

---

You are reviewing a framework, not writing code. **Do not modify any file in this repository
except the single output file named at the end.** No refactors, no "helpful" fixes.

## What this repository is

`agentic-sdlc-kit` is a **document system** — a governance framework for delivering software
with AI coding agents under human control. It is not a library and ships almost no executable
code. Its claim: it converts an AI coding agent from an "enthusiastic liability" into a
controlled engineering assistant, by imposing spec-first work, one-phase-at-a-time delivery,
a human-held quality gate, an ordered source-of-truth hierarchy, and mandatory human review.
It was extracted in 2026-08 from one production deployment (a multi-entity financial
management system) that the author says shipped 68 features under it.

## Read before you judge (in this order)

1. `README.md` — the pitch, the layer anatomy, the five non-negotiables
2. `.specify/memory/constitution.md` — 13 principles, the supreme law
3. `CLAUDE.md` — the always-loaded agent entry point and its Task-Scoped Reading table
4. `AGENTS.md` — how non-Claude agents (you, if you are Codex) are supposed to inherit the law
5. `docs/sdlc/` — all nine process documents (definition-of-done, gate-command,
   review-process, branch-strategy, repository-strategy, critical-delivery, team-workflow,
   rollback-process, deployment-standards)
6. `docs/rulebooks/README.md` + the tier templates — the craft layer
7. `adoption/greenfield.md` and `adoption/existing-system.md` — the two adoption tracks
8. `specs/_templates/` and `modules/finance/finance-invariants.md` — the artifacts and a
   worked domain-invariants pack
9. `scripts/init-kit.ps1`, `scripts/doc-lint.ps1`, `.github/workflows/doc-lint.yml` — the only
   mechanical enforcement that exists today
10. `git log --oneline` — how the kit has evolved

Run `grep -rn "{{\|TODO(" --include="*.md" .` to see how much of the kit is unfilled slots.

## Ground rules for your review

- **Be adversarial, not agreeable.** Your value here is finding what is wrong, not confirming
  that the design is good. Praise costs the author nothing and teaches them nothing. If you
  find yourself writing "this is a well-structured framework", delete the sentence and find a
  failure mode instead.
- **Cite evidence.** Every finding must reference a concrete `path:line` or a quoted sentence.
  Anything you cannot ground in a file must be labelled `ASSUMPTION:`.
- **Judge against reality, not against ideals.** The measure is: would a real team of 1–5
  developers actually follow this for a year, or would they quietly stop after feature 3?
- **You must recommend removals.** Name at least **three** things to delete, merge, or
  downgrade from mandatory to optional. Frameworks die of accretion, not of gaps.
- **No fabricated authority.** Do not invent studies, benchmarks, or "industry standard"
  claims. If you are reasoning from your own experience of being an agent driven by documents
  like these, say so — that perspective is the most valuable thing you can offer here.

## The questions you must answer

Answer all of these explicitly. If a question does not apply, say why.

### A. Does it actually work on an agent?
1. You are the target of this framework. Reading `CLAUDE.md` + the constitution as your
   standing instructions, which rules would **actually change your behaviour**, and which are
   decorative prose you would drift from by turn 30 of a long session? Be specific and honest.
2. What is the context cost of the always-loaded core, and does the Task-Scoped Reading table
   in `CLAUDE.md` genuinely limit reading, or does compliance require reading everything anyway?
3. Which rules are **unfalsifiable** — i.e. an agent can claim compliance and no one can check?
4. `AGENTS.md` is an 11-byte pointer to `CLAUDE.md`. Does that actually work for Codex,
   Cursor, Copilot, Gemini CLI? What breaks?

### B. Governance design
5. Are the 13 constitutional principles the right 13? Which are governance, which are merely
   coding style that has been over-promoted to constitutional force (and what does that
   over-promotion cost)?
6. The trust boundary is "the user runs the gate and confirms the exit code". Is this
   defensible, or theatre a user will paste around within a week? What would make it hold?
7. `docs/sdlc/definition-of-done.md` requires six gates per **phase**, not per feature. Compute
   the realistic ceremony overhead for a 4-phase feature. Is the Lite level in
   `docs/sdlc/critical-delivery.md` actually lite enough to survive contact with a deadline?
8. Constitution: "exactly one constitution" vs `docs/sdlc/repository-strategy.md`: separate
   backend/frontend repos. How does one constitution govern three repos without drifting?
   Is this a real hole?

### C. Enforceability and drift
9. Today the only mechanical enforcement is a doc-lint. List what **could** be enforced
   mechanically (CI checks, git hooks, PR templates, agent hooks/settings, spec-artifact
   presence checks, slot-completeness checks) and rank by value/effort.
10. `scripts/*.ps1` and `.specify/scripts/powershell/` are PowerShell-only. What does that cost
    in adoption, and what is the minimum cross-platform story?
11. The kit pins stock Spec Kit 0.4.4 and `.claude/commands/speckit.*`. What happens on
    upstream drift, and how should the kit be versioned and updated in a project that copied it?
12. 100+ unfilled `{{SLOT}}`/`TODO()` markers stand between a clone and a usable kit. What is
    the realistic drop-off, and what is the smallest change that most reduces it?

### D. What is missing
13. Name the gaps that matter. Consider at minimum: agent-specific security (prompt injection
    via files/issues/web content the agent reads, secrets entering agent context, tool and MCP
    permission policy — see `.claude/settings.local.json`), ADR storage (constitution IV's
    bootstrap clause demands ADR-style decisions but no ADR home exists),
    `docs/sdlc/deployment-standards.md` being a stub, absence of any threat model, absence of
    any measurement of whether the framework works (escaped defects, rework rate, phase cycle
    time, agent-caused incidents), and onboarding a developer who has never used it.
14. What evidence would falsify the kit's central claim? Design the cheapest experiment that
    could show the kit does **not** improve outcomes.

### E. Positioning
15. Who is this for, precisely, and who should not use it? Where does it sit against the
    alternatives an informed team would compare it to (plain Spec Kit, AGENTS.md/CLAUDE.md
    conventions alone, PR-template-and-CI discipline, nothing at all)?
16. Give the one-sentence honest pitch — and the one-sentence honest warning label.

## Then: the plan

Produce a build plan to take the kit from "documented framework" to "thing a team outside the
author's own project can adopt and stay inside for a year". Constraints:

- Phrase it as numbered features in the kit's **own** SDLC shape (`NNN-name` branch ↔
  `specs/NNN-name/`) — the kit must be built with the kit, and where that is painful, say so:
  that pain is your best data.
- Maximum **7** features for the first release. If your critique implies more, cut scope and
  say what you cut.
- For each feature: goal, why it is in this position, phases, acceptance criteria that are
  mechanically checkable where possible, effort estimate (S/M/L), and what it would cost to
  skip it.
- Separate **v1 (must ship)** from **v1.1 (should)** and **someday/never (explicitly rejected)**.
  The rejected list is mandatory — it is where you prove you made choices.
- Include one **kill criterion**: what would have to be true for the author to abandon or
  radically reshape the kit rather than continue?

## Output

Write your review to **`review/out/<YOUR-NAME>-round1.md`** and change nothing else. Use exactly
this skeleton:

```markdown
# <YOUR-NAME> — Round 1 Independent Review

## Verdict
<3-5 sentences. Lead with the single most important thing the author should hear, even if
it is unwelcome. State plainly whether you would adopt this on a real project, and why.>

## Findings
| # | Severity | Area | Finding | Evidence (path:line) | Recommendation |
|---|----------|------|---------|----------------------|----------------|
<Severity: BLOCKER / MAJOR / MINOR. Ordered most severe first. No filler rows.>

## Answers to the brief
<Numbered 1-16, matching the questions above. Short and direct; no restating the question.>

## Cut list
<At least three things to delete, merge, or make optional — with the reason each survives today.>

## Build plan
### v1 — must ship (max 7 features)
<Per the constraints above.>
### v1.1 — should
### Rejected, deliberately
### Kill criterion

## Assumptions and blind spots
<What you could not verify from the repository, and where your own judgement is weakest.>
```

Do not write any other file. Do not commit. Do not run the gate.
