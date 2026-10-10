# Feature Specification: Cross-repo Territory Reach

**Feature Branch**: `018-cross-repo-territory-reach`  
**Created**: 2026-10-11  
**Status**: Approved 2026-10-11 (owner: anas.m)  
**Delivery Level**: Standard  
**Rationale Rule**: 1  
**Input**: User description: "Close GAP-018: the pre-phase territory check reads the declared code repositories as sibling working trees and reports file overlap between the current feature and every other open feature claim across them, the way feature 012 extended the scope check; and never says CLEAN over a comparison it did not make"

## Context

`docs/sdlc/team-workflow.md` section 5 tells an owner to run `scripts/territory-check.ps1` before each
phase, so that two features that want the same file agree a merge order **before** they collide. The
check answers one question: does any other open feature claim a file this feature touches? It
answers it from git. A claim is an open remote `NNN-*` branch, and what a branch touches is its
committed diff against the trunk.

It reads one repository. In the nested multi-repo layout (`docs/sdlc/repository-strategy.md`) the
governance repository holds the specs and the code lives in independent repositories cloned inside
it and ignored by it. Two features that both change the same controller each commit a spec directory
of their own in the governance repository and the controller in the code repository. The check opens
the first and never the second, so it reports `CLEAN`. It cannot produce a true positive in the one
layout that needs it, and nothing goes red: the owners discover the overlap at merge, which section 5
itself calls a process failure. GAP-016 was the same blindness in the post-commit scope check, and
feature 012 closed it by reading the declared code repositories as sibling working trees. This
feature does the same for the pre-phase check.

Feature 012 settled the conventions this reuses: the code repositories are declared in
`kit-adoption.json` (`codeRepos`), a code repository's branch carries the same name as the
governance branch, paths are written governance-root-relative and prefixed with the repository's
directory name, and a code repository's trunk is whatever it is (often `master` or `develop`), so it
is resolved rather than assumed.

There is a second reason to be careful here, and it is why this feature carries a constraint of its
own. Feature 015 found that a check can run, compare nothing, and print the word a clean run prints.
`scripts/territory-check.ps1` already does it once (GAP-029): when it cannot compare a branch it warns,
skips it and still ends on `CLEAN`. A cross-repository check adds several new ways to be unable to
compare (a code repository that is not cloned, one with no trunk, one whose remote will not answer,
another feature's branch that cannot be read). If each of them ends on `CLEAN`, the feature would
widen the check's reach and its blind spot at the same time.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Two features that want the same code file are told, before the phase (Priority: P1)

A project has a governance repository and a declared code repository. Feature 004 has committed a
change to a file in the code repository. The owner of feature 005 is about to start a phase that
touches the same file, and runs the territory check from the governance repository. The check
reports an overlap with feature 004, names the file with its repository prefix, says how live the
other claim is, and exits with the overlap code, so the owners can agree a merge order now.

**Why this priority**: this is the gap. Without it the check has no true positive in the layout that
needs it.

**Independent Test**: build a throwaway governance repository with one declared code repository,
two feature branches that each commit to the same code file, and run the check from each; both
report the other and exit 2. Move one feature's change to a different file; both report clean.

**Acceptance Scenarios**:

1. **Given** two open features that each commit the same file in a declared code repository,
   **When** the owner of either runs the check, **Then** it reports an overlap with the other
   feature naming the file as it is written in a Territory block (prefixed with the repository's
   directory name) and exits with the overlap code.
2. **Given** the same two features touching different files in the code repository, **When** the
   check runs, **Then** it reports no overlap and says which repositories it compared.
3. **Given** an overlap only in the governance repository (the specs), **When** the check runs,
   **Then** it behaves exactly as before.
4. **Given** an overlap in two different code repositories at once, **When** the check runs,
   **Then** it reports both, each file under its own repository prefix.
5. **Given** another feature whose code-repository branch has no commits for the stale window,
   **When** the check runs, **Then** the overlap is reported as reclaimable and does not by itself
   cause the overlap exit code, as for a stale governance claim (team-workflow rule 3).

---

### User Story 2 - A comparison that was not made is never reported as a clean one (Priority: P1)

The owner runs the check and one of the declared code repositories is not cloned here, or has no
branch to compare against, or its remote does not answer, or another feature's branch in it cannot
be read. The check says so, by repository and by cause, and ends on a verdict that is not `CLEAN`.
A run that did compare everything says `CLEAN` and says what it compared.

**Why this priority**: it is the constraint that stops this feature from widening the blind spot it
exists to close. A clean verdict that can mean "I looked" or "I could not look" is worth nothing.

**Independent Test**: for each cause, build a fixture in which exactly that comparison cannot be
made, with no overlap anywhere else, and confirm the verdict is the ungraded one, naming the
repository and the cause. Remove the cause; confirm `CLEAN`.

**Acceptance Scenarios**:

1. **Given** a declared code repository that is not present in this checkout, **When** the check
   runs, **Then** the verdict is ungraded, names that repository and the cause, and is not
   `CLEAN`.
2. **Given** a code repository with no resolvable trunk to diff against, **Then** the same, naming
   the trunk candidates that were tried.
3. **Given** a code repository whose remote cannot be fetched, **Then** the same; the check does
   not fall back to a stale local view and call it complete.
4. **Given** another feature's branch that exists in a code repository but cannot be compared,
   **Then** the same, naming the feature and the repository.
5. **Given** a fully compared run with no overlap, **Then** the verdict is `CLEAN` and the output
   names every repository compared and the open claims it was compared against.
6. **Given** an ungraded run that also found an overlap, **Then** both are reported: the overlap
   exit code is kept, and the ungraded lines are printed beside it, not instead of it.

---

### User Story 3 - A project that has no code repositories sees no change (Priority: P2)

A single-repository project, or a multi-repository project that has not declared `codeRepos`, runs
the check exactly as before: same output on a clean run, same overlap report, same exit codes.

**Why this priority**: the kit ships to projects it cannot edit, and one of its rules is that
updating must not turn an adopted project red or change a verdict it did not ask to change.

**Independent Test**: every existing territory-check fixture, unmodified, still passes.

**Acceptance Scenarios**:

1. **Given** no `codeRepos` in the adoption record, **When** the check runs, **Then** the output and
   exit code are those the existing fixtures assert.
2. **Given** an empty or malformed `codeRepos`, **Then** the check says so in the same words the
   scope check uses and compares the governance repository alone; it does not guess.

---

### User Story 4 - The guidance says what the check now reads and what UNGRADED means (Priority: P3)

`docs/sdlc/team-workflow.md` section 5 describes a check that reads the governance repository.
After this feature it states that it also reads the declared code repositories, what an overlap
there looks like, and what the ungraded verdict means and what to do about it.

**Why this priority**: the document is what an owner reads when the check says something they did
not expect.

**Independent Test**: the section names the new behaviour, the ungraded verdict and its causes, and
`scripts/doc-lint.ps1` passes.

**Acceptance Scenarios**:

1. **Given** the updated section, **When** an owner reads an ungraded line, **Then** the document
   explains each cause the check can name and the action for it.

---

### Edge Cases

- A code repository on a trunk that is neither `main` nor `master`: the trunk is resolved the way
  the scope check resolves it, and an unresolvable trunk is ungraded, not guessed.
- A feature that exists in the governance repository and has no branch in a given code repository:
  it did no work there, which is not an error and not an overlap.
- A feature whose governance branch has no commits yet but whose code-repository branch does: its
  liveness is judged from its latest commit in **any** repository, so it is not mistaken for a
  freshly claimed branch with nothing to compare.
- The branch under check has uncommitted tracked changes in a code repository: they count as
  touched, as they do in the governance repository today.
- Renames: both the old and the new path are touched.
- A declared code repository whose directory exists but is not a git repository: ungraded, by name.
- The same relative path in two different code repositories: not an overlap, because the repository
  prefix distinguishes them.
- Work that exists only on another developer's machine, never pushed, cannot be seen by any
  git-based check. The output says what it compared, so the limit is visible rather than implied.
- The check is asked about a branch that is not a numbered feature: unchanged, it refuses.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: When `codeRepos` is declared, the territory check MUST compute, for the branch under
  check and for every other open remote `NNN-*` feature claim, the set of files touched in **each
  declared code repository**, and report an overlap wherever two features touch the same file in the
  same repository.
- **FR-002**: Every reported path MUST be written governance-root-relative and prefixed with the code
  repository's directory name, so that a reported overlap can be copied into a Territory block
  unchanged and two repositories never collide on a shared relative path.
- **FR-003**: The declaration MUST be read by the one reader the scope check uses, with the same
  validation (plain directory names, no paths, no traversal); this check MUST NOT carry a second
  interpretation of `codeRepos`.
- **FR-004**: A code repository's branch for a feature MUST be the branch carrying the governance
  branch's name; a repository with no such branch for a feature means that feature did no work there,
  which is neither an overlap nor a failure.
- **FR-005**: A code repository's trunk MUST be resolved by the same candidate order the scope check
  uses; a repository with no resolvable trunk MUST be ungraded, naming the candidates tried.
- **FR-006**: The branch under check MUST include tracked uncommitted changes in a code repository,
  as it does in the governance repository today.
- **FR-007**: A feature's status (live, stale and reclaimable, or claimed with no work yet) MUST be
  judged from its latest commit in **any** repository it has a branch in, using the existing stale
  window; a stale overlap MUST NOT by itself cause the overlap exit code.
- **FR-008**: The check MUST NOT report `CLEAN` unless every comparison it was asked to make was
  made: every declared code repository against every open claim, **and** the governance repository.
  Any comparison it could not make MUST be named, by repository, feature and cause, and the verdict
  MUST be a distinct ungraded one, never `CLEAN`.
- **FR-009**: The causes the check MUST name are at least: a declared repository that is not present
  or not a git repository; no resolvable trunk; a remote that cannot be fetched; another feature's
  branch that cannot be compared. Each MUST have its own wording.
- **FR-010**: The ungraded verdict MUST leave the exit code at 0 when nothing overlaps (the kit's
  convention, feature 015: it changes the verdict, not the exit code) and MUST NOT mask an overlap:
  an overlap keeps its exit code and the ungraded lines are printed beside it.
- **FR-011**: The `-Json` output MUST keep its existing fields and meanings except that `CLEAN` MUST
  be false whenever any comparison was not made; it MUST gain a field listing the comparisons not
  made, and each overlap MUST carry its repository.
- **FR-012**: A clean, fully compared run MUST say which repositories it compared and how many open
  claims it compared them against.
- **FR-013**: A project that declares no usable `codeRepos` MUST see its existing output and exit
  codes unchanged, except where FR-008 applies to the governance comparison (see Assumptions).
- **FR-014**: `docs/sdlc/team-workflow.md` section 5 MUST describe the extended reach, the ungraded
  verdict and its causes.
- **FR-015**: Every rule above MUST be proved by the enforcement harness (feature 015) with a passing
  and a failing fixture, using real temporary git repositories for the governance repository and each
  code repository, with expectations written by hand rather than through the script's own helpers.

### Key Entities

- **Open claim**: a remote `NNN-*` branch of the governance repository, the ledger of who is working
  on what.
- **Touched set**: the files a branch changes against its trunk, in one repository, plus (for the
  branch under check) tracked uncommitted changes.
- **Declared code repository**: an entry in `codeRepos`, a plain directory name directly under the
  governance root.
- **Comparison**: one open claim (or the branch under check) against one repository. Each is made,
  or named as not made.
- **Verdict**: `CLEAN` only when every comparison was made and none overlaps; an overlap; or ungraded.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In a fixtured nested layout, two features that change the same file in a code
  repository are reported as overlapping, by both owners' runs, in 100 per cent of fixtured cases,
  including the case where the governance repositories look disjoint.
- **SC-002**: For each named cause of a comparison not being made, the verdict is not `CLEAN` in 100
  per cent of fixtured cases, and each names its repository and cause.
- **SC-003**: Every pre-existing territory-check fixture passes unchanged, so a project declaring no
  code repositories sees no new behaviour.
- **SC-004**: Run against clones of the three adopted projects with nothing else open, no verdict
  changes except where the check was previously reporting `CLEAN` over a comparison it had skipped,
  and the output states what it compared.
- **SC-005**: An owner can tell from a single run's output whether the answer means "nothing
  overlaps" or "I could not look", without reading the script.
- **SC-006**: The harness's coverage check reports no rule of this feature without both a passing and
  a failing fixture.

## Level Rationale

- **domain-invariants**: does not apply — this is kit tooling with no domain-invariants pack of its own
- **irreversible-data**: does not apply — the check only reads git state and writes nothing
- **authn-authz-payment**: does not apply — no authentication, authorization or payment flow
- **auditable-evidence**: does not apply — the output is a coordination aid, not evidence a regulator or contract asks for

## Assumptions

- **Scope: what overlaps means.** A claim is the committed diff of a branch against its trunk, as
  today. Comparing *declared* Territory blocks from `tasks.md` across features, which would warn
  before any code exists, is a different feature and is out of scope; the check keeps its stance
  that the claim lives in git.
- **Scope: GAP-029, decided here.** The ungraded verdict is a property of the whole run, because one
  verdict line cannot be honest about half of it. So a **governance** comparison that is skipped (a
  claim with no remote-tracking ref, the case GAP-029 records) also ends the run ungraded and no
  longer on `CLEAN`. That closes the second defect GAP-029 names. The four refusal paths that
  `scripts/territory-check.ps1` reports with a terminating write (not a repository, not a numbered
  branch, a failed fetch, an uncomparable base), which GAP-029 also records and which cannot be
  asserted through the harness, are **not** changed here. The owner confirms this split when
  approving the spec.
- **Pushed work only.** Another developer's unpushed commits are invisible to any git-based check,
  in the governance repository today and in the code repositories after this. The output states
  what was compared; it does not claim more.
- **Branch naming.** A code repository's branch for a feature carries the governance branch's name,
  feature 012's convention, which is what makes the mapping decidable without new configuration.
- **The remote of a code repository** is its own `origin`. A code repository with no remote is
  compared against its local branches only, and the output says so; it is not reported as fully
  compared against other developers' work.
- **Verdict vocabulary.** The ungraded verdict uses the word and the exit-code behaviour feature 015
  defined for the other members; `scripts/territory-check.ps1` adopts it for the cases above and
  keeps `CLEAN` and the overlap code for the rest.
- **Level.** Standard: it changes an enforcement script and its harness cases, touching no domain
  invariant, irreversible operation, authentication or auditable evidence (the Level Rationale).
- **Out of scope**: `scripts/scope-check-repos.ps1` (GAP-030), the developer roster (GAP-024), a new
  adoption-record key, and any change to how claims are made.
