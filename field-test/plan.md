# Kit Field-Test Plan (DRAFT)

Purpose: test the agentic-sdlc-kit on its own, on real projects, before building any
runner/automation around it. Output: a ranked list of kit fixes, a list of what is worth
automating, and a go/no-go decision on the runner.

Scope: **solo developer**. Team workflow (`docs/sdlc/team-workflow.md`, `claim-feature.ps1`
races) and multi-repo projects (`scope-check-repos.ps1`) are **out of scope** for this
round. Nothing here claims they were tested.

## Ground rules

1. **Pin the kit version.** Each project records the kit commit sha (or tag) it was
   installed from, and every metrics and friction row is read against that version.
   Starting point: `99ebb2c` (main, after feature 037).
2. Each project starts from a clean install (adoption flow, then
   `pwsh -File scripts/verify-kit.ps1`).
3. Do NOT fix the kit mid-project. Log friction and carry on. Fix the kit between projects.
   **Escape hatch:** a `high`-severity item that *blocks* the project (no way forward) may
   get a minimal hotfix. Log it as `hotfix` in the friction log, bump the pinned version
   in the project's record, and keep the hotfix as small as possible.
4. Every lane must be used at least once: Micro, Lite, Standard (Critical only if a project
   warrants it).
5. The kit's own rules apply unchanged: one phase at a time, gate certified by the owner,
   AI review by a fresh-context reviewer, human review at merge.
6. **Cold-start agent.** The kit author is also the tester, so author knowledge is a bias.
   Run the implementing agent with no memory and no kit context beyond what the adoption
   leaves in the project. Every question the agent asks that the docs should have
   answered is logged as `missing-doc`. Do not answer from your own knowledge of the kit
   without logging it first.

## Projects (pick 3, different shapes)

Use **new** projects. FitForge, FlowBoard and ExpenseTracker have already been used to
measure kit changes, so the kit is partly tuned to them. One of them may serve as the
brownfield project (B2 below).

| # | Type | Adoption path | Size | Lanes / paths to cover | Why |
|---|------|---------------|------|------------------------|-----|
| A | Backend / API | greenfield | 3-5 features | Standard, Micro, `ci-held` gate on one feature | Tests backend rules, data model, contracts, CI-held certification |
| B | UI-heavy app | **brownfield** (`adoption/existing-system.md`) | 3-5 features | Standard (with visual refs), Lite | Tests Visual Compliance Loop and adoption into existing code |
| C | Small utility / script | greenfield | 1-2 features | Micro, Lite, a planned Micro promotion | Tests that the process is not too heavy for small work |

Projects: A = `booking-api` (booking/reservation API, .NET 10 Web API + SQL Server; record in `field-test/booking-api/project.md`) B = ____ C = ____

Deliberate probes, built into the projects:

- **Micro promotion (C):** one feature declared Micro but sized to outgrow its bounds
  (more than 5 territory files or more than 400 lines). Pass: the agent stops and promotes
  in place to Standard. Fail: it stretches the lane.
- **Update path (A):** after the first round of kit fixes, update project A to the new kit
  with `update-kit.ps1` (`adoption/updating.md`), run `verify-kit.ps1`, and log anything
  that breaks. This costs almost nothing because the kit changes between projects anyway.
- **`ci-held` (A):** one Lite or Standard feature declares `**Gate Certification**: ci-held`
  and is certified on the CI evidence triplet instead of a local exit code.

## Per-project procedure

1. Install the kit in a fresh repo (B: into the existing repo); run `scripts/verify-kit.ps1`.
   Record the pinned kit sha and the result.
2. Run baseline gate on untouched code.
3. For each feature: claim branch, specify (spec/plan/tasks), then phase loop (implement,
   gate, commit, scope check, AI review), human review, merge.
4. **Claim audit, after every phase:** pick 2-3 claims from the agent's phase report (e.g.
   "gate ran", "scope-check PASS", "reviewer was fresh-context") and check each against
   real evidence: exit code, commit sha, Reviewer Provenance block. A claim with no
   matching evidence is logged as `agent-faked`.
5. After each feature, fill in the metrics row and review the friction log.
6. After each project, write a 1-page retro (template below) and list kit fixes.

## Where things live

All field-test evidence lives in this kit repository, under `field-test/`, so it survives
deletion of the test projects. `field-test/` is outside the shipped surfaces, so it is
never copied into adopted projects.

```text
field-test/
├── plan.md                 # this file
├── triage.md               # cross-project triage and ranking (after the last project)
└── <project>/
    ├── metrics.md          # one row per feature
    ├── friction.md         # append-only during work
    └── retro.md            # 1 page, after the project
```

## Metrics (one row per feature)

| Project | Kit sha | Feature | Lane | Phases | Gate pass on 1st run? | Scope-check fails | AI review: real issues | AI review: false positives | Claim audit: mismatches | Agent time | Human active time | Ritual overhead time | Human wait time | Tokens / cost | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| | | | | | | | | | | | | | | | |

Definitions:

- **AI review: real issues**: findings that led to a code or document change.
- **AI review: false positives**: findings rejected as wrong or not applicable. Review
  noise is a cost too.
- **Ritual overhead time**: time spent on spec/plan/tasks, reviews, checks and records,
  as opposed to building the feature. **Overhead share** = ritual overhead / (agent time +
  human active time). This is the number that answers "is the process too heavy?".
- **Human wait time**: time the work sat waiting for a human step (gate, review, approval).
- **Tokens / cost**: from the agent's usage report, if available; feeds the runner
  cost estimate.

## Friction log (append during work, do not fix mid-project)

| Date | Kit sha | Project/Feature | Step | What happened | Type | Severity |
|---|---|---|---|---|---|---|
| | | | | | agent-skipped / agent-faked / rule-too-costly / missing-doc / missing-template / install-bug / update-bug / human-rubber-stamp / hotfix / other | low / med / high |

Severity:

- **high**: the work was blocked, or the kit produced or allowed a wrong result.
- **med**: cost more than about 30 minutes, or needed a workaround.
- **low**: annoyance; no real cost.

Types to watch for:
- Steps the agent skipped or faked (the claim audit is the detector)
- Rules that cost more time than they save
- Missing templates or docs (agent invented its own layout, or asked a question the
  docs should answer)
- Install/adoption failures on a fresh or existing repo
- Update failures when moving a project to a newer kit
- Human steps that are only a rubber stamp (automation candidates). The tester is also
  the human: note honestly every approval given without reading the evidence.

## Retro template (1 page per project)

1. Project, shape, adoption path, kit sha(s) used.
2. What went well: what the kit caught or prevented.
3. Top 3 friction items, with friction-log references.
4. Overhead share across the project's features; was it worth it for this project size?
5. Kit fixes proposed (each: problem, friction-log refs, rough size).
6. Automation candidates seen (each: which human or agent step, how often, how mechanical).

## Triage and ranking (after the last project)

- Every friction item is classified: **fix kit**, **document**, or **ignore** (with a reason).
- Kit fixes are ranked by **severity × frequency**, then by **number of projects hit**
  (an item seen in 2-3 projects outranks one seen once at the same score).
  Score: high = 3, med = 2, low = 1; frequency = number of occurrences.
- Automation candidates are ranked by **how often the step occurred × how mechanical it
  was** (evidence from the rubber-stamp and wait-time data), with no list of expected
  candidates written in advance.

## Exit criteria

The field test is done when:
- [ ] 3 projects completed through merge (A greenfield, B brownfield, C small)
- [ ] All of Micro, Lite, Standard exercised at least once
- [ ] Micro promotion probe run (pass or fail recorded)
- [ ] `ci-held` certification exercised on at least one feature
- [ ] Fresh-install path verified on A and C; brownfield adoption verified on B
- [ ] Update path verified on A (`update-kit.ps1` + `verify-kit.ps1` after the first round of fixes)
- [ ] Friction log triaged: each item is "fix kit", "document", or "ignore"
- [ ] Kit fixes and automation candidates ranked (method above)

## Runner go/no-go

Set the overhead threshold **before** project A starts, and do not move it afterwards.

Go only if all hold:
- [ ] No open `high`-severity kit fixes
- [ ] Claim audit: no unresolved `agent-faked` mismatches in the last project
- [ ] Overhead share per feature at or below **40 %** (set 2026-10-18, before project A, by anas.m)
- [ ] The top automation candidate is backed by occurrence data from at least 2 projects

Otherwise: apply the fixes and run another round, or narrow the runner's scope.

## After the test

- Apply kit fixes via normal kit features (spec first), citing the friction-log rows.
- Only then design the runner (picks up issues, claims branch, runs phase loop, stops at
  gate and review points for a human).
- Reference model: ZadLoop "software factory" stages 1-3 (signal, intake, triage), 5 (keep
  green), plus a morning digest. Treat it as a reference, not a target: the triage data
  decides which stages to build first.
