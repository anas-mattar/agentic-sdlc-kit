---

description: "Task list for feature 037 — GAP-024 (b) and (c): the reviewer pulls the review, and a claim can say whether a row fits the claimant's repositories"
---

# Tasks: Reviewer choice and pull-time fit

**Input**: `specs/037-reviewer-choice-and-fit/spec.md` (approved, anas.m, 2026-10-18; Q1 pull, Q2 advisory), `plan.md` (approved, anas.m, 2026-10-18; decisions P1–P10), `research.md`, `data-model.md`, `contracts/`, `quickstart.md`, `notes.md` (the measurements)
**Prerequisites**: spec.md and plan.md approved; tasks.md approved (pending); no new dependency; one new script file (`scripts/claim-review.ps1`) and, only if T003 proves the existing fields insufficient, new harness recipe fields.

**Amendment approved by**: anas.m, 2026-10-18

**Tests**: every new behaviour ships with a passing and a failing harness fixture in the same phase, expectations written by hand (feature 015). New fixtures are run against the parent commit before the code changes and must fail there, so each is shown to measure something. Phase evidence goes in `notes.md`, never here. New rule ids: `CRV-*` (the review claim command and reader), `CRIT-R05` to `CRIT-R09` (the claim reading in the Critical team arm), `FIT-*` (the fit note).

**Organization**: four phases, each independently revertible, reverted in the order 4, 3, 2, 1. Phase 3 does not depend on 1 or 2. The full harness is run on an isolated checkout of the final commit, never in a working directory someone is using. Every file is checked for carriage returns before it is committed (this working tree has tracked files that are CRLF on disk).

---

## Phase 1: The claim and its reader (US1; FR-001 first half, FR-006, FR-013)

**Purpose**: a reviewer can pull a Critical feature's review. `Get-ReviewClaims` and the slug rule in `scripts/adoption-lib.ps1` are the one reader of a claim; `scripts/claim-review.ps1` is the only writer, pushes `refs/heads/review/<feature>/<slug>`, refuses in its own words, and never selects or ranks a reviewer. No check calls the reader yet, so no verdict moves; and no existing ledger reader (the claim counter, the claim allocator, the territory check) counts a `review/` ref.

**Territory**:

- `scripts/adoption-lib.ps1`
- `scripts/claim-review.ps1`
- `tests/**`

- [ ] T001 Record the baseline on the parent commit in `notes.md`: the full harness count on an isolated detached worktree, the coverage report's exempt-rule count and its site counts per script, and the saved output and exit code of `roadmap-claim-check.ps1`, `claim-feature.ps1` and `territory-check.ps1` on one fixture each that has branches on `origin`, for the byte comparison of T008.
- [ ] T002 Read constitution I, IX and X and `docs/sdlc/team-workflow.md` sections 3 and 4 for any sentence that fixes who picks the reviewer or what an independent review must be (plan P10); record the answer in `notes.md`. Probe the design before code depends on it: (a) that `git ls-remote --heads origin "refs/heads/review/<feature>/*"` returns the ref and that none of the three ledger regexes (`refs/heads/(\d{3,}-\S+)$`) match a `review/...` ref, including one whose last segment starts with digits; (b) that a commit built on the feature tip's tree with the feature tip as parent can be pushed and read back with its author name and email; (c) what the harness does with a branch name containing `/` in a nested origin; (d) which characters the slug rule must handle (spaces, dots, `@`, a leading `-`), and that `git check-ref-format` accepts every slug the rule can produce.
- [ ] T003 Probe the harness (plan P2, P10): can a recipe plant `review/<feature>/<slug>` on `origin` with a chosen commit author, and make `git ls-remote` or the author read fail? Record what exists. If a field is missing, add the smallest one to `tests/enforcement/lib/FixtureRepo.psm1` with a header-comment entry and a refusal when used without `origin`, in the pattern of `originRivalOnPush`; do not add a field the fixtures can do without.
- [ ] T004 Write the fixtures first, under `tests/enforcement/cases/claim-review/` and `tests/enforcement/cases/adoption-lib/` or the harness's equivalent for a library reader: `CRV-001` to `CRV-008`, one fail and one pass each, for the eight refusals of `contracts/claim-review-cli.md` (not a repository; no origin; ledger unreadable; feature not on origin; no team roster; `-As` not on the roster or two entries slugging alike; `-As` denied Critical approval; push rejected); `CRV-009` the success (the ref exists, named in the output) with its idempotent second run (`already claimed`, nothing pushed); `CRV-010` the reader's failure channel (an unreadable ledger or author is `Failed` with a cause, never an empty list); `CRV-011` slug cases (`Anas M.`, `ada`, `Grace Hopper`, a name that slugs to empty); and `CRV-012` the three ledger readers each given a ledger holding a `review/` ref: output byte-identical to the same ledger without it. Expectations by hand. Run them on the parent commit and record that each new fail fails there for the stated reason.
- [ ] T005 Bring the new rules into the coverage sweep: add each `CRV-*` to `tests/enforcement/rules.json` with its anchor and law, and the `claim-review.ps1` entry to `tests/enforcement/emission-idioms.json` in the idiom `claim-feature.ps1` uses (`Stop-Refused`); run the sweep and classify anything else it reports.
- [ ] T006 Add to `scripts/adoption-lib.ps1` (plan P2, P3): the slug function, `Get-ReviewClaims -Root -Feature` returning `Failed`, `Cause` and `Claims` (`Slug`, `Sha`, `AuthorName`, `AuthorEmail`), with a failed ledger read and an unreadable author each a named `Failed`, and a roster-ambiguity result for two entries that slug alike. Update the header comment. No other function changes.
- [ ] T007 Write `scripts/claim-review.ps1` (plan P1, P2; `contracts/claim-review-cli.md`): preflight, `Stop-Refused` for all eight refusals with their own text, the claim commit (feature tip's tree, feature tip as parent, message `review claim: <feature> by <roster name>`), a push that is never forced, `already claimed` when the ref exists, `-Json`. It does not compare the claimant with the Owner and does not select a reviewer.
- [ ] T008 Run `-Case claim-review/`, the full harness, `doc-lint.ps1` (the new script must be classified as shipped; if `kit-manifest.json` needs an entry, stop and amend this phase's Territory with an approver record before editing it), `build-digests.ps1 -Check` and `ritual-checks.ps1`: every pre-existing case keeps its verdict, exit code and bytes, every new fixture as written, the coverage report lists no unowned site. Re-run T001's saved states and diff: nothing moved. Record the numbers in `notes.md`.

---

## Phase 2: The check reads the claim (US1; FR-001–FR-006a, SC-002, SC-004)

**Purpose**: on a Critical team-arm feature whose review is owed, the Critical evidence check also requires a valid review claim by the Reviewer, after the feature 021 conditions have passed. A claim by or authored under the Owner does not count; a missing claim fails naming the repair; a review nobody pulled says so in the existing "missing" failure; an unreadable ledger or author is `UNGRADED`. The solo arm and a project with no roster print and fail exactly as before.

**Territory**:

- `scripts/enforcement-pack.ps1`
- `tests/**`

- [ ] T009 Record the baseline on the phase 1 commit in `notes.md`: the full harness count, and the saved output and exit code of every existing `CRIT-*` team-arm case (the ones whose Reviewer passes the 021 conditions), listing which `expected.txt` files will need a claim on `origin` or a new line (plan P5).
- [ ] T010 Write the fixtures first (plan P4 table), under `tests/enforcement/cases/enforcement-pack/`: `CRIT-R05` a claim by the Reviewer counts (pass) and its absence fails naming the feature, the Reviewer and `scripts/claim-review.ps1` (fail); `CRIT-R06` the only claim names the Owner (fail) against one by another developer (pass); `CRIT-R07` a claim by the Reviewer whose commit author is the Owner, by name and by email local part (fail) against the same claim authored by the Reviewer (pass); `CRIT-R08` no claim by anyone and no review file: the existing "missing" failure gains the unclaimed clause (fail) against the same with a claim (pass); `CRIT-R09` no origin, an unreadable ledger, an unreadable author and two roster entries that slug alike each print one `UNGRADED` line with the cause and leave the exit unchanged, against a readable ledger (pass). Add: a stranger Reviewer, the Owner as Reviewer and a denied Reviewer print only their 021 failures and no claim line (FR-005); a solo-arm and a one-developer fixture byte-identical to the parent; a Critical feature mid-feature (`pending`) prints no claim line. Expectations by hand; remember the harness reads stdout and then stderr. Run on the parent commit and record that each new fail fails there for the stated reason and each pass passes.
- [ ] T011 Bring the rules into the coverage sweep: add `CRIT-R05` to `CRIT-R09` to `tests/enforcement/rules.json` with anchors and law; add an entry to `tests/enforcement/emission-idioms.json` only if the sweep reports a new site. Run the sweep and classify anything else it reports.
- [ ] T012 Edit `scripts/enforcement-pack.ps1` (plan P4): dot-source nothing new (the lib is already loaded); in `Invoke-CriticalTeamEvidence`, after the 021 reviewer conditions and only when the Reviewer passed them, read the claims with `Get-ReviewClaims`, apply the counting rule of `data-model.md`, and emit the failure, the unclaimed clause or the `UNGRADED` line per the table; add the unclaimed clause to the "is missing" failure. The solo arm, `Get-CriticalMergeReadiness` and every other member stay untouched. Update the comment above the function.
- [ ] T013 Update the pre-existing team-arm fixtures T009 listed (a claim on `origin` for the passes, the new line for the others) and nothing else. Run `-Case enforcement-pack/`, the full harness and `ritual-checks.ps1`: every pre-existing case keeps its verdict and exit code outside the listed team-arm fixtures, every new fixture as written, the coverage report lists no unowned site. Re-run T009's saved states and diff: the only moved bytes are the ones T009 listed. Record the numbers in `notes.md`.

---

## Phase 3: Pull-time fit (US2; FR-007–FR-012, SC-003, SC-004)

**Purpose**: a claim can be told which roadmap row it is for. When the row's declared repositories are outside the claimant's roster `repos`, `claim-feature.ps1` prints one advisory `Fit` note and proceeds; every case where the reading cannot be made says so in one line. Without `-Row` the script is byte-identical, and with no roster nothing is printed. `Get-RepoFit` is the one reader of `repos`.

**Territory**:

- `scripts/adoption-lib.ps1`
- `scripts/claim-feature.ps1`
- `specs/_templates/roadmap-template.md`
- `tests/**`

- [ ] T014 Record the baseline on the phase 2 commit in `notes.md`: the full harness count, and the saved output and exit code of every existing `CLF-*` and `CLAIM-*` case and of `roadmap-claim-check.ps1` on a table with an extra column, for the byte comparison of T019.
- [ ] T015 Probe the design (plan P6 to P8): (a) that the roadmap table's header can carry a `Repos` column and `roadmap-claim-check.ps1` reads `Status` and `Owner` unchanged (a fixture built from the kit's own table with one column added); (b) what `git config user.name` returns inside the harness's temporary repositories and that `-As` overrides it; (c) how a row fragment matches the kit's own roadmap (one match, none, several); (d) that the roster's `repos` values compare to `codeRepos` names as plan P6 says. Record what is found.
- [ ] T016 Write the fixtures first, under `tests/enforcement/cases/claim-feature/`: `FIT-001` a declared repository outside the claimant's `repos` prints the `Fit` note naming the row, the uncovered repositories and who covers them (fail direction: note present) against a full cover (pass: byte-identical to a run with no `-Row`); `FIT-002` a repository nobody lists says `no one declared it`; `FIT-003` no `Repos` column, an empty or em-dash cell, a claimant with no `repos` and no roster each print nothing extra; `FIT-004` `-As` and `user.name` not on the roster print `Fit: not read - cannot tell who is claiming` with both strings; `FIT-005` no row and several rows each print the `not read` line with the count; `FIT-006` an unreadable roadmap prints `not read` with the cause; `FIT-007` the claim itself (number allocated, branch, exit code) is identical with and without a `Partial` note; `FIT-008` a roadmap table with the `Repos` column leaves `roadmap-claim-check.ps1`'s verdict unchanged. Expectations by hand. Run on the parent commit and record that each new fail fails there for the stated reason.
- [ ] T017 Bring the rules into the coverage sweep: add `FIT-*` to `tests/enforcement/rules.json` with anchors and law; add to `tests/enforcement/emission-idioms.json` only if the sweep reports a new site. Run the sweep and classify anything else it reports.
- [ ] T018 Add to `scripts/adoption-lib.ps1`: `Get-RepoFit -Roster -Claimant -Repos` (pure; `Match`, `Partial` with the uncovered names and who covers them, `NoDeclaration`, `Unplaced` with the strings compared) and the small roadmap row reader the fit needs (first cell and the `Repos` column; the first cell fragment match). Edit `scripts/claim-feature.ps1`: `-Row` and `-As`, the single `Fit` line before allocation per `contracts/claim-feature-fit.md`, nothing else changed; update its header. Add the optional `Repos` column and its one-line explanation to `specs/_templates/roadmap-template.md`.
- [ ] T019 Run `-Case claim-feature/`, the full harness, `doc-lint.ps1`, `build-digests.ps1 -Check` and `ritual-checks.ps1`: every pre-existing case keeps its verdict, exit code and bytes, every new fixture as written, the coverage report lists no unowned site. Re-run T014's saved states and diff: nothing moved. Record the numbers in `notes.md`.

---

## Phase 4: Guidance, flow-down, roadmap, measurement (US3; FR-014–FR-016, SC-001, SC-005)

**Purpose**: owners and adopters are told the rule, its limits and the first red run; the roadmap and the GAP-024 row record what closes and what stays open; the measurement shows whether any verdict moved on real clones.

**Territory**:

- `docs/sdlc/team-workflow.md`
- `docs/sdlc/critical-delivery.md`
- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/digests/**`

- [ ] T020 Rewrite `docs/sdlc/team-workflow.md` section 3 step 4 (the owner no longer alone picks the reviewer; the reviewer pulls with `scripts/claim-review.ps1`) and add a subsection beside feature 021's: the review claim (what it is, where it lives, who writes it, that an abandoned claim is replaced by another person pulling, that the kit never proposes a reviewer), the `Repos` column and the `Fit` note (advisory, read by one function), and the stated limits (a claim is a written claim, the author test catches only the owner's own identity, an unreadable ledger is `UNGRADED`). Digest markers per `docs/digests/digest-packs.json` bounds. Note in `notes.md` that this edits a `docs/sdlc/` document inside the feature branch as features 021 and 036 did, and that section 7 of the same document asks for team-lead approval of governance changes: the owner's approval of this task list stands for it unless they say otherwise.
- [ ] T021 Update `docs/sdlc/critical-delivery.md` item 5 and the roster paragraph: the team arm requires the claim after the 021 conditions, `repos` now has one reader (the fit note), and the honest paragraph says what the claim does and does not prove. No sentence may still say the owner alone picks the reviewer or that `repos` is read by nothing (spec FR-015).
- [ ] T022 Add a flow-down note to `adoption/updating.md` shaped like feature 036's: what was wrong, what the check and the commands do now, what flows down (two scripts, one new, the lib, three documents), what may newly be seen (a failure or a `UNGRADED` line on a team-arm Critical feature with no claim; nothing for a project with no roster), what does not change, the stated limits, what was measured, what to do. Every path in it resolves in an adopted project (doc-lint).
- [ ] T023 Update `docs/roadmap.md`: this feature's row to `shipped` only after the human review at merge; the GAP-024 inventory row records what 037 closes, that (b) closes by pull and (c) as an advisory note, and what stays open; a decisions-log entry dated the day the feature ships (Q1, Q2 and the plan decisions the owner changed, if any). Edit with a tool that keeps UTF-8. Run `pwsh -File scripts/build-digests.ps1 -Check` and regenerate with the script only if a digest-marked document changed.
- [ ] T024 Measurement (plan P10, SC-001): on fresh `--no-hardlinks` clones of FitForge, FlowBoard and ExpenseTracker (nothing in place touched, nothing pushed), run `enforcement-pack.ps1`, `roadmap-claim-check.ps1` and `ritual-checks.ps1` as of the phase 3 commit and report every verdict that moved, with FitForge's Critical features named by the line they now meet. Say plainly what the run shows and does not (it is the check on real files, not a claim that a reviewer will pull). If a clone is not available on this machine, record the measurement as not made with the reason; do not substitute a synthetic number.
- [ ] T025 Final run on an isolated checkout of the final commit (a detached `git worktree` outside the repository, removed afterwards): the full harness, `ritual-checks.ps1 -Branch 037-reviewer-choice-and-fit`, and `scope-check.ps1` on each phase commit. Record the numbers in `notes.md`. The owner then runs the gate.

---

## Dependencies & Execution Order

- Phase 1: T002 and T003 before T004 and T006 (the fixtures and the reader use what the probes proved); T004 before T006 and T007 (fixtures first, shown failing); T005 before the sweep run in T008; T008 last.
- Phase 2 needs phase 1: the check calls the reader. T010 before T012.
- Phase 3 is independent of phases 1 and 2 (it reads the roster and the roadmap, not the review ledger) but follows them in order, because one phase is implemented at a time. T015 before T016; T016 before T018.
- Phase 4 needs phases 1 to 3: the guidance describes what shipped and the measurement runs the changed scripts.
- Within a phase, fixtures are written and shown failing before the behaviour lands.

## Implementation Strategy

MVP is phases 1 and 2: a reviewer can pull and the check refuses an unpulled review; that closes GAP-024 (b) and is useful alone. Phase 3 (c) can be dropped without touching them, and phase 4 can follow either. Stop after each phase for the owner's gate; one phase at a time, never ahead.
