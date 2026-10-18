# Feature Specification: Reviewer choice and pull-time fit

**Feature Branch**: `037-reviewer-choice-and-fit`
**Created**: 2026-10-18
**Status**: Draft (Q1 pull and Q2 advisory decided at the owner's go-ahead, 2026-10-18; awaiting approval)
**Delivery Level**: Standard
**Rationale Rule**: 1
**Input**: User description: "Close GAP-024 (b) and (c) from the roadmap inventory: (b) the Owner picks their own cross-reviewer at claim time, so the judged party selects the judge; feature 021 made the roster load-bearing for names but left the choice of reviewer with the owner. (c) Pull has no matching: picking is ordered by roadmap priority and screened only for dependencies and territory, never for fit, so in a multi-repo project the top row goes to whoever is free rather than whoever owns that stack. Deliberately NOT in scope: assignment authority, skill matrices, capacity planning; keep the leaderless claim-by-push ledger. Spec only."

## Background

Feature 021 (`specs/021-developer-roster/`) turned the adoption record's `developers` array into a roster three
checks read: a Critical feature's Reviewer must be on it and permitted, a claim's Owner must be on it, and an Owner
may not hold more than two active claims. It closed GAP-024 (a) and GAP-004 and left two parts of the row open on
purpose, because each, done carelessly, becomes assignment authority:

- **(b) The owner picks their own judge.** `docs/sdlc/team-workflow.md` section 3, step 4 says the picker "picks their
  cross-reviewer at claim time". Feature 021 checks that the Reviewer named in a Critical feature's
  `human-pr-review.md` is on the roster, is permitted, and is not the Owner. It does not check **how** that person
  came to be the Reviewer. Two strings in one file, both written by the team that owns the feature, still decide
  whether the strictest lane's independence rule is met. A friendly nominee satisfies every machine check.
- **(c) Pull has no matching.** Picking from the roadmap is ordered by priority and screened for dependencies and
  territory (`team-workflow.md` section 3, step 1), never for fit. In a multi-repo project (FitForge: a C# API
  repository and a Next.js web repository) the top row goes to whoever is free. The roster's `repos` field exists,
  is validated, and is **read by nothing** (feature 021, FR-003 and the guidance in `docs/sdlc/critical-delivery.md`).

The kit's best team property is the leaderless claim-by-push ledger: a remote `NNN-*` branch is the claim, with no
meeting and no assigner. This feature must not buy that out. Both halves are therefore framed as **making a choice
visible and falsifiable**, not as taking the choice away from the people who make it.

Deliberately **not** in this feature: assignment authority (nobody is told what to take or whom to review),
skill matrices, capacity planning, a central reviewer pool or queue, and any change to the priority ordering of the
roadmap.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A Critical feature's reviewer is not the owner's unilateral pick (Priority: P1)

On a team project, the person who judges a Critical feature has to be someone who took the review themselves, on
the ledger and under their own name, so the owner nominating a convenient teammate is no longer enough to satisfy the
independence rule. Review is pulled the way features are, not handed out.

**Why this priority**: it is the strictest lane's one independence rule, and feature 021 left the choice that decides
it entirely with the judged party. It is also the only reviewer check the kit grades by machine, so it is where a
fix has teeth.

**Independent Test**: fixtures of a Critical team-arm branch whose `human-pr-review.md` names a Reviewer who is on
the roster, permitted and not the Owner, with and without a review claim by that Reviewer, differ only in the verdict.

**Acceptance Scenarios**:

1. **Given** a team-arm Critical branch whose Reviewer is valid under feature 021 and has no review claim,
   **When** the Critical evidence check runs on the merge-ready branch, **Then** it reports the missing claim by name
   and the repair, in the verdict vocabulary the rest of the pack uses.
2. **Given** the same branch with the review claim present, **When** the check runs, **Then** it passes exactly as it
   does today.
3. **Given** a review claim made by the Owner (for themselves or on the Reviewer's behalf), **When** the check runs,
   **Then** it does not count.
4. **Given** a solo project (no roster, or one developer), **When** any check runs, **Then** no verdict, line or exit
   code moves: the solo arm never reads the claim.

---

### User Story 2 - A developer sees, before claiming, whether a feature fits their repositories (Priority: P2)

When a developer is about to claim a roadmap row whose declared repositories are not ones the roster says they work
in, the claim step tells them so, once, in plain words, and carries on. A developer who is in fact the right person
for it (a full-stack developer, a stack change of plan) is never blocked.

**Why this priority**: it removes the "top row goes to whoever is free" accident without removing anyone's choice,
and it is the first reader of the roster's `repos`, which the kit already collects and ignores.

**Independent Test**: fixtures of a roster with `repos`, a roadmap row that declares repositories and a claimant,
covering match, partial match, no match, no declaration and no roster, differ only in the note printed.

**Acceptance Scenarios**:

1. **Given** a roster entry with `repos` that cover every repository the row declares, **When** that developer
   claims it, **Then** nothing extra is printed.
2. **Given** a row that declares a repository outside the claimant's `repos`, **When** they claim it, **Then** one
   note names the row, the repositories not covered, and who on the roster does cover them, and the claim proceeds.
3. **Given** a row that declares no repositories, a roster entry with no `repos`, or no roster at all, **When** a
   claim is made, **Then** the output is byte-identical to today's.
4. **Given** a claimant the claim step cannot place on the roster, **When** a fit would otherwise be read, **Then**
   it says it cannot tell who is claiming and reads nothing, and it never reports a fit it did not compute.

---

### User Story 3 - The guidance says what the new reading does and does not prove (Priority: P3)

The kit's team documents state the new rule for the reviewer and the fit note, say where each stops, and the
adoption update note tells an adopted project which red or note it might meet first.

**Why this priority**: both halves are a written claim a person can falsify, not proof of identity or independence,
and the 021 precedent is that the guidance says so beside the rule.

**Independent Test**: a reader of `team-workflow.md`, `critical-delivery.md` and the update note finds the rule, its
limits and the repair for each new message, with no contradiction between the three.

**Acceptance Scenarios**:

1. **Given** the updated team documents, **When** a developer reads section 3 step 4, **Then** it no longer says the
   owner alone picks the reviewer, and it states that the reviewer pulls the review and who writes the claim.
2. **Given** an adopted project updating from the kit, **When** it reads the update note, **Then** it learns which
   new message a Critical team-arm feature can meet, and that a project with no roster sees none.

---

### Edge Cases

- The Reviewer leaves the roster, or loses `canApproveCritical`, after the claim was made: the feature 021 reading
  runs as it does today and the claim does not override it.
- The Owner changes after the claim was made (a reclaimed stale feature): the claim is graded against the Owner as
  they are now, not as they were.
- Two people pull the review of the same feature: the check accepts a Reviewer who matches any valid claim and does
  not pick between them.
- Nobody pulls: the feature is not mergeable, the message says the review is unclaimed, and nothing assigns anyone.
- The claim is made before the review artifact exists, or after: the check states which it found and does not infer
  order from timestamps it cannot trust.
- The Owner pulls their own feature's review: the claim does not count (FR-002).
- A feature spans two repositories and the claimant covers one: a partial cover is reported as partial, with the
  uncovered repository named, never as a match or as a total miss.
- A row declares a repository that no roster entry lists: the note says no one declared it, rather than naming no
  one as if that were an answer.
- A roster name that does not match the claimant's identity by the 021 rules (`Anas M.` against `anas.m`): the claim
  step says it cannot tell who is claiming, and names both strings.
- The ledger cannot be read, or the roadmap row cannot be bound to the claim: the fit reading is UNGRADED with its
  cause and never silently clean (the GAP-027 species).

## Level Rationale *(mandatory — answers the four Critical triggers, in writing)*

- **domain-invariants**: does not apply — the kit has no domain-invariants pack; this feature changes how the kit's own review and claim checks read a roster.
- **irreversible-data**: does not apply — no migration or operation drops or rewrites data; every change is a check, a document or a template.
- **authn-authz-payment**: does not apply — it reads names already declared in the adoption record and proves no identity; it adds no authentication, authorization or payment flow.
- **auditable-evidence**: does not apply — no regulator, auditor or contract asks the kit for evidence; the independence rule it grades is the kit's own, and the guidance states that a record is a written claim and not proof.

## Requirements *(mandatory)*

### Functional Requirements

**Reviewer choice (GAP-024 b)**

- **FR-001**: On a Critical feature in the team arm, the Critical evidence check MUST require, in addition to the
  feature 021 conditions, an review claim by the Reviewer: the Reviewer **pulls** the review of a named feature the way a developer
  takes a feature, by putting a claim on the ledger under their own name, and the Owner does not nominate
  (decided: pull, not nominate and not derive).
- **FR-002**: A review claim made by the Owner, for themselves or on the Reviewer's behalf, MUST NOT satisfy FR-001.
- **FR-003**: A project whose roster is absent, empty or one developer MUST see no change in any verdict, line or
  exit code (the solo arm and the absent-record-defaults-to-strict rule of feature 013 stand).
- **FR-004**: A failure under FR-001 MUST name the feature, the Reviewer, what review claim is missing and the one-line
  repair, in the pack's own verdict vocabulary; a ledger the check cannot read MUST be UNGRADED with the cause, never
  passed.
- **FR-005**: The feature 021 conditions (Reviewer on the roster, permitted, not the Owner, comparison after
  trimming, case-insensitive) MUST be unchanged and MUST be evaluated first, so a stranger is still named as a
  stranger rather than as a missing claim.
- **FR-006**: The check MUST NOT select, rank or propose a Reviewer. It grades the one that pulled and was named.
- **FR-006a**: A Critical feature whose review nobody has pulled MUST stay unmergeable by the same check, with the
  message saying the review is unclaimed and how to claim it. The kit MUST NOT assign a Reviewer to it, and a review
  claim with no commits for the stale period MUST be reclaimable, as a stale feature claim is.

**Pull-time fit (GAP-024 c)**

- **FR-007**: A roadmap row MAY declare the repositories its feature is expected to touch. A row that declares none
  MUST never be screened.
- **FR-008**: At claim time, when the claimant is placed on the roster, their entry has `repos`, and the row declares
  repositories, the claim step MUST say when any declared repository is not covered by the claimant's `repos`, naming
  the row, the uncovered repositories and the roster developers whose `repos` cover them. The note is **advisory
  only** (decided): it never stops, delays or alters the claim.
- **FR-009**: The fit reading MUST be the only reader of the roster's `repos`, and MUST NOT affect the roadmap's
  priority order, any other check's verdict or any developer's other claims.
- **FR-010**: A claimant the claim step cannot place on the roster (no identity, or a name that fails the 021
  comparison) MUST get a stated "cannot tell who is claiming" line with the strings compared, and no fit reading.
- **FR-011**: A project with no roster, or with a roster entry that has no `repos`, MUST see byte-identical claim
  output.
- **FR-012**: A fit reading the step could not complete (ledger unreadable, row not bindable, `repos` entry
  unusable) MUST say UNGRADED with the cause. It MUST never end as clean over a comparison it did not run.

**Both halves**

- **FR-013**: The leaderless claim-by-push ledger MUST be preserved: no central assigner, no queue and no file that
  one person must write for others to proceed; every new piece of state lives where a claim already lives.
- **FR-014**: Every new verdict MUST be covered by a failing and a passing fixture in the enforcement test library,
  and a measurement MUST show no verdict moves on clones of the three adopted projects (FitForge, FlowBoard,
  ExpenseTracker) before the update note is written.
- **FR-015**: `docs/sdlc/team-workflow.md` (section 3 step 4 and the roster section), `docs/sdlc/critical-delivery.md`
  (item 5 and the roster paragraph), `specs/_templates/roadmap-template.md`, the adoption update note, the digests
  and the roadmap row and decisions log MUST be updated to state the rule, its limits and the closure of GAP-024 (b)
  and (c); no document may still say the owner alone picks the reviewer or that `repos` is read by nothing.
- **FR-016**: The guidance MUST state that the review claim and the fit note are written claims: roster membership and a
  claim are not identity, do not show the review happened and do not show who is claiming.

### Key Entities

- **Roster entry**: a developer's name and, optionally, `repos` and `canApproveCritical` (feature 021). Unchanged
  here; `repos` gains its first reader.
- **Review claim**: the ledger-borne statement that a named person pulled the review of a named Critical feature.
  It carries a feature and a Reviewer, is made by a party who is not the Owner, and goes stale on the same rule as a
  feature claim. Its exact shape is for the plan.
- **Roadmap row repositories**: an optional declaration on a roadmap row of the repositories its feature is expected
  to touch, in the names `codeRepos` already uses.
- **Claimant**: whoever is making the claim, placed on the roster by the 021 name comparison or not placed at all.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On clones of FitForge, FlowBoard and ExpenseTracker, no verdict, line or exit code moves except where
  the update note says one will, and `ritual-checks` ends as it did before the change.
- **SC-002**: In every fixture of a Critical team-arm branch with a valid 021 Reviewer and no review claim, the
  check fails or reports UNGRADED naming the Reviewer and the missing claim; in every fixture with a valid claim
  it passes. There is no fixture where the Owner alone satisfies it.
- **SC-003**: In every fixture of a row declaring repositories the claimant does not cover, the fit note names the row
  and the uncovered repositories; in every fixture of a match, no declaration, no `repos` or no roster, the claim
  output is unchanged byte for byte.
- **SC-004**: No fixture ends `CLEAN` or `OK` over a fit or review-claim reading the check could not make.
- **SC-005**: A reader of the three updated documents can state, for each of the two halves, what is checked, what is
  only claimed, and the repair for each message, with no statement contradicted elsewhere.

## Assumptions

- The feature is Standard: it changes scripts and documents, touches no schema, dependency or domain rule, and a
  misjudgement in it costs a noisy check, not lost data.
- Both halves stay silent for a project with no roster, as feature 021 did, so no adopted project's output changes
  without its owner having declared one.
- (b) is graded on Critical team-arm features only, because the Critical evidence check is the only place the kit
  holds a reviewer artifact a machine can read. Section 4 of `team-workflow.md` already binds every feature's
  human reviewer, and this feature does not extend machine grading beyond Critical.
- The roadmap row gains an optional repositories field because, at pick time, the roadmap row is the only document
  a candidate feature has; a plan's Territory does not exist yet.
- The claimant is identified by the claim step's own knowledge of who is running it and the 021 name comparison; no
  new identity mechanism is introduced, and a failed match reads nothing.
- A review claim is a written claim, as the Reviewer Provenance block is: it turns a silent omission into something a
  reviewer can falsify, and does not prove who wrote it or that the review was independent.
- The mechanism, the file shapes, the verdict words and the phasing are for the plan to decide; this spec fixes
  only what must be true afterwards.
