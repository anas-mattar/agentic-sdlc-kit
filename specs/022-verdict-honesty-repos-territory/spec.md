# Feature Specification: Verdicts that say what was compared (scope-repos and territory-check)

**Feature Branch**: `022-verdict-honesty-repos-territory`
**Created**: 2026-10-12
**Amendment approved by**: anas.m, 2026-10-12
**Status**: Approved (anas.m, 2026-10-12)
**Delivery Level**: Standard
**Rationale Rule**: 1
**Input**: User description: "GAP-030 with GAP-029: scope-check-repos.ps1 summarises a partly graded run as if it were whole, and prints a -BaseRef hint that does not work as written; territory-check.ps1 reports four refusals with a terminating Write-Error under ErrorActionPreference Stop, so its own exit and message are unreachable and four rules are exempt from fixtures."

## Background

Two of the kit's grading scripts still say more, or less, than they know. Both defects are the species GAP-027 named
and feature 015 and 018 closed elsewhere: a word that stands for a whole run when part of the run compared nothing, or a
refusal the script writes but cannot reach.

**`scripts/scope-check-repos.ps1` (GAP-030).** The run-level `UNGRADED` line is printed only when `$graded` is zero
(`scripts/scope-check-repos.ps1:390`). A declared code repository that applies to the feature but grades nothing prints
its own line (`<repo>: UNGRADED could not resolve a merge base ...`, `<repo>: UNGRADED (no commits since merge base ...)`,
or only `not applicable` / `WARN` lines when every commit it offers is skipped) and the run still ends silent, exit 0,
whenever **another** repository graded a commit. `scripts/ritual-checks.ps1` lifts a member's verdict from a line
beginning `scope-repos: UNGRADED`, so it reports `scope-repos OK` over a run part of which compared nothing. In FitForge
(a C# API repository and a Next.js web repository) one repository on a non-`main` trunk is exactly this case. The
hint printed when no trunk resolves says `pass -BaseRef <ref>`, but `-BaseRef` is read only under `-All` and, without
`-Repo`, replaces the trunk candidates of **every** declared repository; the form that works is
`-All -Repo <repo> -BaseRef <trunk>`. `ritual-checks.ps1` does not pass `-BaseRef` through at all. Both facts are disclosed
to adopters today as prose (`docs/sdlc/review-process.md` step 3, `adoption/updating.md`), which is a disclosure of the
defect rather than a fix.

**`scripts/territory-check.ps1` (GAP-029).** Four refusals are written with `Write-Error` under
`$ErrorActionPreference = 'Stop'` (`scripts/territory-check.ps1:58`, `:68`, `:79`, `:86`): outside a git repository, a
branch that is not `NNN-name`, a failed `git fetch origin`, a base that cannot be diffed against. `Stop` makes the write
terminating, so the `exit 1` after each is unreachable; the exit a caller sees is PowerShell's, and through the
enforcement harness's launcher the run reports exit 97 (did not run to a verdict). The four rules (`TERR-008` to
`TERR-011`) are therefore exempted from fixtures in `tests/enforcement/rules.json` with that as the written reason, and
`specs/015-enforcement-assurance/notes.md` (phase 6) records it as a finding. Feature 018 closed the other half of
GAP-029: a claim the script cannot compare is `UNGRADED` and the run no longer ends `CLEAN` over it. What remains is the
four refusals. Nothing is broken for a human at a terminal (`pwsh -File` still exits 1); what is missing is a script
that can be proved to say what it says.

Neither script is used by an adopted project's CI today beyond `scope-repos` inside `ritual-checks`; `territory-check`
is run by hand at claim time (`docs/sdlc/team-workflow.md`). Adopted projects with code repositories: FitForge declares
two (`codeRepos`); FlowBoard and ExpenseTracker declare none and are `n/a` for `scope-repos`.

Deliberately **not** in this feature: adding a `-BaseRef` pass-through to `ritual-checks.ps1` (one trunk for every
repository is the wrong shape for a multi-repo project, and the per-repository form already exists); changing what
counts as a graded commit; changing the territory-overlap logic or its exit 2 on a live overlap; any new verdict
word in the kit's vocabulary (OK, FAIL, n/a, UNGRADED).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A partly graded run says UNGRADED at run level (Priority: P1)

When a declared code repository applies to the feature (the repository is present, is a repository of its own, and
carries the feature branch) and grades no commit, the run-level verdict says so, even if another repository graded.
`ritual-checks.ps1` then reports `UNGRADED` for the member, not `OK`.

**Why this priority**: it is the one defect of the two that turns a CI signal green over an unread repository, in the
only adopted project that has code repositories.

**Independent Test**: a fixture with two declared repositories on one feature, one graded `PASS` and the other with no
resolvable trunk, prints the run-level line beside the per-repository one and exits 0; the same fixture with both
graded prints no run-level line and is byte-identical to today.

**Acceptance Scenarios**:

1. **Given** repository A graded a phase commit and repository B applies but has no resolvable merge base, **When**
   the check runs, **Then** it prints B's own `UNGRADED` line and a run-level `scope-repos: UNGRADED` line naming B,
   and exits 0.
2. **Given** repository A graded and repository B applies but every commit it offers is skipped (`not applicable`, a
   merge commit, no `phase N` token), **Then** the run-level line names B too.
3. **Given** every applicable repository graded at least one commit, **When** the check runs, **Then** its output and
   exit code are byte-identical to the parent commit.
4. **Given** repository B is declared but absent, not a repository of its own, or carries no branch for the feature,
   **Then** it stays `n/a` / `not applicable` exactly as today and does not make the run `UNGRADED`.
5. **Given** a repository graded `FAIL` beside an ungraded one, **Then** the run still exits 1, and the run-level line
   does not claim a clean or fully graded run.

---

### User Story 2 - The hint names a command that works (Priority: P1)

When no trunk resolves for a repository, the line says the form that grades that one repository, not a flag that is
ignored or that replaces the trunk of every repository.

**Why this priority**: the reader of an `UNGRADED` line acts on its advice; advice that does nothing leaves the project
ungraded and looking attended to.

**Independent Test**: the fixture of Story 1 scenario 1 prints a hint; running the hint as written grades the
repository (or the same fixture's `-All -Repo <repo> -BaseRef <trunk>` run exits with a graded verdict).

**Acceptance Scenarios**:

1. **Given** an unresolved trunk in repository B, **Then** the `UNGRADED` line for B names
   `-All -Repo <B> -BaseRef <trunk>` and does not tell the reader to pass `-BaseRef` alone.
2. **Given** that command is run as printed with a real trunk, **Then** B is graded, and a repository the command did
   not name is not graded against that trunk.

---

### User Story 3 - territory-check's refusals reach their own message and exit (Priority: P1)

Each of the four refusals prints its message and ends with exit 1, reached by the script and not by PowerShell's
terminating error, so each is proved by a fixture through the harness like every other rule.

**Why this priority**: four rules the kit ships are unproved, and the stated reason for exempting them is a defect in
the script this feature may fix.

**Independent Test**: a `pass` and a `fail` fixture exist for each of `TERR-008` to `TERR-011`; the `fail` case shows
the script's own message and exit 1 (not exit 97), and the exemption entries are gone from `rules.json`.

**Acceptance Scenarios**:

1. **Given** a run outside a git repository, a branch that is not `NNN-name`, a failed fetch, or an undiffable base,
   **When** the script runs, **Then** it prints that refusal's message and exits 1, and the harness reports exit 1.
2. **Given** none of the four conditions, **Then** the output and exit code are unchanged from the parent commit,
   including exit 2 on a live overlap and the `UNGRADED` path feature 018 added.
3. **Given** the same four conditions as run today by `pwsh -File` at a terminal, **Then** a human sees the same
   wording and the same exit code 1.

---

### User Story 4 - Adopters are told what changes, with a measurement (Priority: P2)

The update note says which verdict can move (a multi-repository run that was silent over an ungraded repository now
says `UNGRADED`), says what did not move, and the prose that disclosed the defect stops describing a behaviour the
script no longer has.

**Why this priority**: both scripts are kit-owned and flow down verbatim; the one adopted project that can see the
change must be able to read it before it happens.

**Independent Test**: the measurement on clones of the three adopted projects lists every verdict that moves, or says
none did, with the old and new output for FitForge's `scope-repos` line.

**Acceptance Scenarios**:

1. **Given** the update applied to clones of FitForge, FlowBoard and ExpenseTracker, **Then** every moved verdict is
   listed with its cause, and a project that moved none says so.
2. **Given** `docs/sdlc/review-process.md` step 3 and `adoption/updating.md` today tell the reader to read the
   per-repository lines because the run-level verdict can be silent, **Then** after the change they say what the
   run-level verdict now guarantees and keep the advice that `UNGRADED` is not a pass.

---

### Edge Cases

- A project with no declared code repository: `scope-repos` is `n/a` and nothing here changes.
- A repository that graded at least one commit but also had skipped commits: it is graded; skipped commits are not
  ungraded repositories.
- `-Commit` or the non-`-All` path (tip of the branch): a repository whose tip is skipped (`not applicable`, no
  `phase N` token) graded nothing in that run; whether that is `UNGRADED` at run level is decided in the plan against
  the existing wording of the header and US3 acceptance scenario 3 of feature 015 (the plan records the answer; the
  default is that the run-level verdict follows the same rule in both modes).
- `territory-check.ps1` with `-Json`: the refusals print no JSON object today and stay that way.
- A refusal written to stderr today (`Write-Error`) versus stdout: which stream carries the message after the change
  is decided in the plan; the wording and the exit code are fixed here (FR-006).
- The repository the harness runs from is left alone, as for every fixture (feature 015 FR-020).

## Level Rationale *(mandatory — answers the four Critical triggers, in writing)*

- **domain-invariants**: does not apply — the kit has no domain-invariants pack; these are checks over git history and governance records.
- **irreversible-data**: does not apply — both scripts are read-only on the working tree and on every repository they read; nothing is migrated, dropped or rewritten.
- **authn-authz-payment**: does not apply — no product authentication, authorization or payment is touched.
- **auditable-evidence**: does not apply — the scope check is a CI signal, not the evidence of record for a Critical feature; its verdict words change for one multi-repository case and nothing here is evidence an auditor would read.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: When a declared code repository applies to the feature (present, a repository of its own, and carrying
  the feature branch) and grades no commit in the run, `scripts/scope-check-repos.ps1` MUST print a run-level
  `scope-repos: UNGRADED` line that names each such repository, whether or not another repository graded, and MUST
  exit 0 on that account alone.
- **FR-002**: A repository that is `n/a` or `not applicable` for the reasons it is today (declared but absent, not a
  repository of its own, no branch for the feature) MUST NOT make the run `UNGRADED`. A repository that graded at
  least one commit MUST NOT be named by the run-level line.
- **FR-003**: When every applicable repository graded, the output and exit code of `scope-check-repos.ps1` MUST be
  byte-identical to the parent commit, in both the `-All` mode and the tip mode (SC-001). The existing run-level line
  for a run that graded nothing keeps its words, or is replaced by a line that still begins `scope-repos: UNGRADED`
  and still says nothing was graded; the plan chooses, and `ritual-checks.ps1` keeps reading it.
- **FR-004**: The line printed for an unresolved trunk MUST name `-All -Repo <repo> -BaseRef <trunk>` for the
  repository concerned and MUST NOT suggest `-BaseRef` alone.
- **FR-005**: `scripts/ritual-checks.ps1` MUST continue to lift a member verdict from a line beginning
  `scope-repos: UNGRADED` and MUST NOT gain a `-BaseRef` pass-through. A partly graded run therefore reports the
  member `UNGRADED` through the existing path; no new ritual-checks word is added.
- **FR-006**: The four refusals of `scripts/territory-check.ps1` (outside a git repository; a branch that is not
  `NNN-name`; a failed `git fetch origin`; a base that cannot be diffed against) MUST each print their existing
  message, unchanged in wording, and MUST end with exit 1 reached by the script itself, so that a caller and the
  enforcement harness observe exit 1 and the message and never exit 97.
- **FR-007**: `TERR-008` to `TERR-011` MUST each gain a failing and a passing fixture that differ only in the
  condition under test, their exemptions MUST be removed from `tests/enforcement/rules.json`, and the coverage test
  MUST report them fixtured. No other territory-check behaviour changes: overlap detection, exit 2 on a live overlap,
  the `UNGRADED` accumulator of feature 018 and the no-remote note are byte-identical (SC-001).
- **FR-008**: `REPOS` and `TERR` rules this feature adds or changes MUST be written first as failing fixtures
  shown failing on the parent commit, then the behaviour lands (feature 015 convention); each new emission site MUST be
  inventoried in `tests/enforcement/rules.json` with its anchor.
- **FR-009**: `docs/sdlc/review-process.md` (step 3), `adoption/updating.md` (the feature 015 disclosure and the
  feature 018 territory paragraph) and `docs/roadmap.md` (GAP-029, GAP-030 and this feature's row) MUST say what the
  scripts now do, keep the advice that `UNGRADED` is not a pass, and name the one verdict that can move for an
  adopter. The update note follows the shape of the feature 021 note: what flows down, what may newly be seen, what
  was measured.
- **FR-010**: The measurement of SC-003 MUST be run on clones of the three adopted projects (never the real ones),
  before and after the update, and every verdict that moves MUST be listed with its cause.

### Key Entities

- **Applicable repository**: a declared code repository that is present, is the root of a repository of its own, and
  carries the feature branch. Only these can be ungraded; the others are `n/a` as today.
- **Graded repository**: an applicable repository for which at least one commit received `PASS` or `FAIL` in the run.
- **Refusal**: a condition under which `territory-check.ps1` makes no comparison and says so with its message and
  exit 1. A refusal is not a verdict word; it is an error, as today.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every output and exit code of `scope-check-repos.ps1` for a run in which every applicable repository
  graded, and of `territory-check.ps1` for a run that hits none of the four refusals, is byte-identical to the parent
  commit (the whole harness passes with only new fixtures added and exemptions removed).
- **SC-002**: Each of FR-001, FR-002, FR-004 and FR-006 has a failing fixture that fails for the stated reason and a
  passing fixture that differs only in the condition under test; the coverage test reports every new site fixtured and
  `TERR-008` to `TERR-011` are no longer exempt.
- **SC-003**: On clones of the three adopted projects, no verdict moves, or every one that moves is listed with its
  cause and its old and new output. FlowBoard and ExpenseTracker (no declared code repository) move nothing.
- **SC-004**: `ritual-checks.ps1` on a fixture of one graded and one ungraded repository reports the member
  `UNGRADED` and not `OK`, and on the same fixture with both graded reports `OK` as before.
- **SC-005**: Running the hint printed for an unresolved trunk, as written, grades that repository.

## Assumptions

- No constitution amendment is needed. Both scripts and their verdict words are kit-owned and documented in
  `docs/sdlc/review-process.md` and `adoption/updating.md`; Definition of Done item 1 (the gate) is unchanged.
- Both scripts are kit-owned verbatim files, so the change reaches adopters through `update-kit.ps1` with no slot or
  record change. No `kit-adoption.json` field is added.
- The wording of the four refusals is the wording a human reads today and is kept; only the way the script reaches its
  exit changes (FR-006). The stream (stdout or stderr) is a plan decision, bounded by the harness capturing what the
  script printed.
- A repository that applies and grades nothing is the right reading of "ungraded" for the run-level line even when
  the cause is a legitimate skip (a merge commit, no `phase N` token): the line says nothing was compared there, which
  is true, and the reader decides whether that matters. Whether a tip-mode run, where a skipped tip is common, should
  say the same is the edge case above, settled in the plan against feature 015's wording.
- GAP-004, GAP-022 and the roadmap's other open gaps are outside this feature.
