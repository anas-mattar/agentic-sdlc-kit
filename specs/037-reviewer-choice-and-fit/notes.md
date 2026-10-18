# Notes: Reviewer choice and pull-time fit

Evidence for the phases, in order. Decisions are in `plan.md`; this file records what was measured.

## Phase 1: the claim and its reader (T001 to T008)

**Baseline on the parent commit (T001).** 906 case directories on `b6b39d4`. A full harness run on an isolated worktree
was started and then stopped unfinished (462 cases reached, none failing, the machine shared with the owner's own run), so
the parent's full pass count is **not recorded**; the owner's gate on the phase 1 working tree is the full-harness evidence
(below). The byte comparison of T001's saved states for `roadmap-claim-check.ps1`, `claim-feature.ps1` and
`territory-check.ps1` was done by the existing cases of those scripts passing unchanged, plus one new control variant for
each (below); no script other than `adoption-lib.ps1` (appended to, nothing existing edited) was touched.

**Probes (T002, T003).**

- A ref `review/007-pay/grace` on a bare origin is listed by `git ls-remote --heads origin 'refs/heads/review/007-pay/*'`
  and not matched by `refs/heads/(\d{3,}-\S+)$`, the pattern all three existing ledger readers use.
- A commit built with `git commit-tree <feature tree> -p <feature tip>` pushes to that ref and reads back its author name and
  email (`%an`, `%ae`).
- Slug: `git check-ref-format` rejects a space, a leading `.`, a trailing `.`, `..` and `.lock` and accepts the rest; the
  slug rule (trim, lower-case, other characters to `-`, collapse `-` and `..`, trim `-` and `.`, `.lock` to `-lock`) produces
  an accepted name for every one of those.
- The harness could plant a branch named `review/<feature>/<slug>` with `origin: "self"` (a branch name with `/` is fine) but
  could not set a commit's author: one field was added, `author: "Name <email>"` on a commit (refused when malformed). No
  phase 1 fixture uses it beyond `CRV-008/pass-already-claimed`; phase 2's author test needs it.
- Constitution I, IX and X say nothing that fixes who picks a reviewer or what an independent review must be beyond the
  independence rule `critical-delivery.md` item 5 already grades, so no amendment is needed (plan P10).

**New cases.** 25: 22 under `tests/enforcement/cases/claim-review/` (`CRV-001` to `CRV-009`, a fail and a pass each, plus
`CRV-005/fail-no-record`, `CRV-006/pass-slug-spaces-and-dots`, `CRV-008/pass-already-claimed`, `CRV-008/pass-json`) and three
control variants (`roadmap-claim-check/CLAIM-001/pass-review-ref-ignored`, `territory-check/TERR-001/pass-review-ref-ignored`,
`claim-feature/CLF-012/pass-review-ref-ignored`: a `review/` ref on the ledger changes nothing in the other readers, and a
ref named like a higher number does not move the allocator). **On the parent commit** the 22 `claim-review` cases all fail
(`names a script that does not exist: claim-review.ps1`); the three controls pass there by design (they pin that nothing moves).

**After.** `-Case claim-review/`: every case passes; the coverage report lists `claim-review.ps1  9 of 9 site(s) fixtured`;
931 case directories (906 + 25). `doc-lint.ps1` classifies 80 shipped files (79 + the new script), `build-digests.ps1 -Check`
OK, `ritual-checks.ps1` on the working tree: every member OK or n/a and `scope-check` UNGRADED (no phase commit yet).
**The owner's gate (the full harness and `ritual-checks.ps1`) exited 0** on the phase 1 working tree.

**Not fixtured, stated.** Two refusals inside the one `Stop-NotMade` site have no case: "the tip of the feature could not be
fetched" (it needs a fetch to fail on a ref `ls-remote` just listed) and "git could not create the claim commit" (it needs no
git identity, and a recipe cannot unset the fixture's own). The site's push-rejected path is fixtured (`CRV-008`); the helper's
text is one function, so a reworded message is caught there.

**Findings during the work.** The first draft built the claim tree as a one-element array assigned from an `if`
expression, which PowerShell unrolls to a string, so `$tree[0]` was one character; the success fixtures caught it before any
phase review. The working copy of `scripts/adoption-lib.ps1` and `tests/enforcement/emission-idioms.json` was CRLF on disk
while the index holds LF (the known state of this working tree); both were written LF so the diff is the change and nothing else.

### Phase 1 review follow-ups (`ai-code-review-phase1.md`: APPROVE with follow-ups, F1 to F8)

- **F1 (closed).** T004 named `CRV-010` (the reader's failure channel) and `CRV-011` (slug cases) and ticked without them: the work was folded into
  other rule ids and not recorded. Now recorded, and the gap closed: the reader's `Failed` channel behind the first read is `CRV-003/fail-claims-read`
  (origin's second read fails through `originFailCall: 2`, so the feature is found and the claims read fails: refused with the reader's cause, exit 1);
  the slug rule's edge cases are `CRV-006/pass-slug-spaces-and-dots`, `CRV-009/fail` (two names that slug alike) and the new
  `CRV-009/fail-no-usable-characters` (a name with no character a ref can hold). The `-WithAuthors` path has no phase 1 caller by design: its first
  fixtures are phase 2's `CRIT-R07` and `CRIT-R09` (an unreadable author), and phase 2 does not start without them.
- **F2 (recorded).** The numbering that shipped: `CRV-001` to `CRV-008` the eight refusals of the contract, `CRV-009` the slug collision (a ninth refusal
  the contract folds into refusal 6), and the three "other ledger readers ignore a review ref" controls filed as `pass-review-ref-ignored` variants under
  `CLAIM-001`, `TERR-001` and `CLF-012` (T004's `CRV-012`). The task text keeps its original numbering; this file is the record, the text was not edited
  (an edit to an approved task list needs an approver record).
- **F3 (deferred to phase 2).** No phase 1 fixture reads the pushed commit back (parent, tree, message, author) or proves an existing ref is never
  overwritten. Phase 2's fixtures read claims through `Get-ReviewClaims -WithAuthors`, which is the author and the ref shape; a non-fast-forward is refused by
  git (a push is never forced). A rival-ref case is added there if the phase 2 review asks for it.
- **F4 (fixed).** "already claimed" now compares slugs case-sensitively (`-ceq`); the slug is lower-case by construction. "Any ref at the slug is a claim" is
  the semantics and goes in the phase 4 guidance.
- **F5, F6, F7 (accepted).** The commit sha is taken from merged output and fails safe (a warning makes the push be refused); the slug rule is not
  injective and refuses clearly when two names collide or none is usable; a few twins differ in more than one condition but the extra difference cannot
  rescue a fail for a wrong reason.
- **F8 (recorded).** The T001 parent baseline was not recorded in full; stated above, and the append-only change to `adoption-lib.ps1` is why no verdict moves.

## Phase 2: the check reads the claim (T009 to T013)

**What changed.** `Invoke-CriticalTeamEvidence` (`scripts/enforcement-pack.ps1`) now calls a new `Invoke-ReviewClaimCheck` after the 021
conditions, and only when they hold (Reviewer on the roster, permitted, not the Owner, Owner named): a stranger, the Owner and a denied
reviewer are named as before and the claim is not graded a second time (FR-005). It reads the claims once with `Get-ReviewClaims -WithAuthors`
and says, in the pack's vocabulary: a failure when the Reviewer has no claim (the Owner's own claim is named as not counting), when the
claim's name slugs to the Owner's, or when its commit was authored under the Owner's name or email local part; an `UNGRADED` line (exit
unchanged) when there is no origin, the ledger or a claim's author cannot be read, or two roster names write as one ref name. The existing
"human-pr-review.md is missing" failure gains one clause, on the same line, when the ledger was read and holds no claim for the feature
(FR-006a). The solo arm never reaches the code; `Get-CriticalMergeReadiness` and every other member are untouched.

**New cases.** 16 under `enforcement-pack/CRIT-R05` to `CRIT-R09` (plan P4's table): R05 no claim (and the Owner's claim only), R06 a claim that
slugs to the Owner's, R07 a claim authored under the Owner's name and under the Owner's email, R08 the unclaimed clause, R09 the four
`UNGRADED` causes (no origin, ledger unreadable through `originFailCall`, author unreadable, ambiguous roster). Rules `CRIT-R05` to `CRIT-R09`
are in `rules.json`. Run against the unchanged check first: R05 fail, R06 fail, R07 fail and R07 fail-email were observed failing (their expected failure line is not printed by it);
R08 and R09 were run too but only their exit-code results were captured on the parent (they matched there, exit 0 or 1 being the same), so their parent-side
output mismatch is not recorded. The passes are the same fixtures with the one condition put right.

**Existing fixtures changed (T009/T013, plan P5).** Sixteen team-arm fixtures whose Reviewer is valid had no origin, so the new reading
printed an `UNGRADED` line and ended `enforcement-pack: UNGRADED` where they expected `OK`: `CRIT-R01/pass-artifact-committed-final-commit-unnamed`,
`CRIT-R01/pass-artifact-committed-mid-feature`, `CRIT-R04/pass-ready-all-ticked-unchanged`, `CRIT-T01/pass`, `CRIT-T02/pass` to `CRIT-T06/pass`,
`CRIT-T07/fail` and `/pass`, `CRIT-T08/pass`, `/pass-case-differs`, `/pass-object-roster`, `CRIT-T09/pass`, `/pass-denied-other-person`. Each recipe
gained `origin: "self"` and the Reviewer's claim as a branch; no `expected.txt` changed, so their output is byte-identical to before. Every other
existing case (including the solo arm, the stranger, Owner-as-Reviewer and denied-reviewer fixtures, and every pending/mid-feature case) passed unchanged.

**Honest limits, stated.** A claim shows that someone who can push to origin wrote a roster name; the author test catches the owner pushing
from their own identity and nothing more (the roster maps no name to an identity, plan P9). An unreadable ledger or author is `UNGRADED`, not red
(spec FR-004), so a Critical team feature can reach merge with that line on a CI that cannot read origin; gate 6 stands behind it. The check reads no
dates: an abandoned claim stays a claim until the Reviewer named in the review file differs from it. A real project whose claim is missing sees a
failure naming the command that fixes it; FitForge, the only adopted team-arm project, is the one whose first red run the update note will predict.

### Phase 2 review follow-ups (`ai-code-review-phase2.md`: APPROVE with follow-ups, F1 to F6)

- **F1 (fixed).** An Owner whose name slugs to empty (any name with no ASCII letter or digit) silently disabled both Owner tests, so a claim by that
  Owner passed with no failure and no `UNGRADED` line. The reading now says `UNGRADED` (the Owner cannot be told from the Reviewer by a ref name). New
  fixture `CRIT-R09/fail-owner-unslugged`: observed on the unchanged code printing `enforcement-pack: OK`, now `UNGRADED`.
- **F2 (fixed).** The author test missed `first.last@`: the email local part keeps its dot while the Owner's name slugs with a hyphen. Both forms are compared
  now. New fixture `CRIT-R07/fail-email-first-dot-last`, observed on the unchanged code printing `OK`, now the failure.
- **F3 (accepted).** A roster slug collision that includes the Owner's own entry is `UNGRADED`, not the Owner-claim failure; it is plan P3/P4 as written.
- **F4 (accepted, stated).** `-WithAuthors` reads the author of every claim on the feature, so one unreadable unrelated claim turns a decidable "no claim by the
  Reviewer" (red) into `UNGRADED` (exit 0). Reading only the Reviewer's claim would fix it; left, because the claim set of one feature is a handful of refs and the
  `UNGRADED` line names the claim whose author could not be read.
- **F5 (part fixed, part recorded).** The `CRIT-R08` rule's `function` now names `Invoke-CriticalTeamEvidence`, where the clause sits. The T010 extra fixtures for a
  stranger, the Owner as Reviewer, a denied reviewer, the solo arm and a pending feature were not added: the existing `CRIT-T08`, `CRIT-T06`, `CRIT-T09`,
  `CRIT-R01/R03` fail and pass-solo cases already pin them, and they stayed byte-identical (those without an origin print no claim line, which is the point). A
  one-developer fixture was not added either (the solo arm does not reach the code). The fetch-fallback success path of `Get-ReviewClaims -WithAuthors` has no
  fixture. The parent-side output of `CRIT-R08` and `CRIT-R09` was not recorded (stated above).
- **F6 (recorded for phase 4).** The fetch fallback writes objects and `FETCH_HEAD` into the clone being graded (plan P2 specifies it); the guidance says so.

## Phase 3: pull-time fit (T014 to T019)

**What changed.** `scripts/adoption-lib.ps1` gains `Get-RoadmapCells`, `Get-RoadmapRows` and `Get-ClaimFit`: the only reader of a roster entry's `repos`,
returning a kind (`None`, `Partial`, `Unplaced`, `RowCount`, `NoColumn`, `Unreadable`) and never anything that could stop a claim.
`scripts/claim-feature.ps1` gains `-Row <fragment>` and `-As <roster name>` (default the git `user.name`) and one `Write-Fit` section before the
number is allocated; without `-Row` nothing in it runs. `specs/_templates/roadmap-template.md` documents the optional `Repos` column.

**Probes (T015).** `roadmap-claim-check.ps1` finds `Status` and `Owner` by header name: a table with a `Repos` column leaves its verdict unchanged
(`CLAIM-001/pass-repos-column`, same expected text as `pass`). Inside the harness `git config user.name` is `Fixture Author`, and `-As` overrides it.
Names compare trimmed, exact and case-insensitive, as the roster's names do (021): `Ada L.` against `ada` is not a match, and the line says so.

**New cases.** 22 under `claim-feature/FIT-001` to `FIT-005` (hand-written expectations) plus `roadmap-claim-check/CLAIM-001/pass-repos-column`:
`FIT-001` the Fit note (fail, fail-nobody-lists, fail-two-repos, fail-partial-cover) against the cover (pass) and the silent cases (pass-row-declares-none,
pass-claimant-has-no-repos, pass-no-roster, pass-without-row, pass-names-compare-loosely); `FIT-002` an unplaced claimant (by `-As` and by git `user.name`);
`FIT-003` no row or several rows; `FIT-004` a table with no `Repos` column; `FIT-005` no `docs/roadmap.md`. Run on the unchanged script first, the `-Row`
cases failed there (an unknown parameter). The rules `FIT-001` to `FIT-005` are in `rules.json`, and the claim-feature idiom gained the `Write-Fit` accumulator;
the coverage report reads `claim-feature.ps1  21 of 24 site(s) fixtured (3 not a rule)` (16 before, plus the five).

**Pre-existing cases.** Every `claim-feature/` case (219 passed, 0 failed, with the coverage tests) and every `roadmap-claim-check/` case (207 passed, 0 failed)
pass unchanged: no `expected.txt` outside the new directories was touched, and a claim without `-Row` prints the bytes it printed.

**Found by the fixtures, before any review.** A local `$row` in `Get-ClaimFit` collided with the typed `[string]$Row` parameter (PowerShell variables are
case-insensitive), turning the matched row into the string "System.Collections.Hashtable": every case read `no Repos column` with an empty row name. It is now `$hit`.

**Deviations from the task text, recorded (the task list is not edited: an edit needs an approver record).**
- T016 numbers the cases `FIT-001` to `FIT-008`; what shipped is `FIT-001` to `FIT-005` (the contract's five outputs, one rule per emission site), with the
  silent cases as `pass-*` variants of `FIT-001`, and `FIT-008` is `roadmap-claim-check/CLAIM-001/pass-repos-column`.
- T016's `FIT-003` says a table with no `Repos` column prints nothing extra; the contract (`contracts/claim-feature-fit.md`) and plan P7 say it prints
  `Fit: not read - ...`. The contract and the plan were followed (FIT-004): a project that asks for a reading with `-Row` and whose table has no column is told so,
  and a project that never passes `-Row` sees nothing. Plan P8's "never screened" means no Partial note is made for it.
- T016's `FIT-007` (the claim itself identical with and without a note) is the `FIT-001/fail` expected text itself: the claim's four lines are the same bytes as
  the `pass` direction's, with the Fit line before them.
- A `-Json` variant of the fixture was written and removed: the harness normalises the fixture path in text, and a JSON-escaped Windows path is not normalised.
  That `-Json` stays free of the Fit line follows from `Write-Fit` going through `Write-Info`, which is silent under `-Json`; it was seen directly (the JSON object
  was the only output of that run) and is not pinned by a fixture.

**Limits, stated.** Fit is advisory: the claim, its number, its branch and the exit code are those of the same claim without the note. It depends on the claimant
being a roster name (`Anas M.` against `anas.m` reads nothing and says so). The roadmap reader here is a second one beside `roadmap-claim-check.ps1`'s own (plan,
risks): it needs the first cell and one column and does not copy the claim-binding rules. A roster entry's `repos` is compared by name only; it is not checked
against `codeRepos` here (the doctor validates it).

### Phase 3 review follow-ups (`ai-code-review-phase3.md`: APPROVE with follow-ups, F1 to F6)

- **F1 (OPEN, owner decision).** FR-011 says a claim without `-Row` is byte-identical. The new `-Row` and `-As` bind by prefix, and `FeatureDescription` takes remaining arguments, so a
  description that contains a dash-led word that is a prefix of one of them (`-A`, `-As`, `-R`, `-Row`) now binds as a parameter instead of staying in the description, and a description
  ending in one fails with "Missing an argument" (probed by the reviewer on stub param blocks; plain words, `Row` without a dash, `-Json`, `-NoPush` and exit codes are unchanged).
  PowerShell offers no switch that turns prefix binding off for a script's parameters. The choices are to accept it and say so in the phase 4 guidance, or to reword FR-011 (an
  amendment with an approver). Not decided here; no code changed for it.
- **F2 (fixed).** The fit block had no `try/catch` under `$ErrorActionPreference = 'Stop'`, so an exception in the reading would have aborted the claim before allocation. It is now the
  `Fit: not read - the fit reading failed: ...` line. No input that throws was found (the reviewer fed it about thirteen odd rosters and roadmaps), so this is a guard with no fixture.
- **F3 (fixed).** A `Repos` cell of an ASCII `-` was read as a repository named `-`, and `web, web` printed twice. An ASCII hyphen now declares nothing (with the empty cell and the em dash)
  and a name written twice is one name. Fixtures `FIT-001/pass-row-declares-none-ascii-dash` and `fail-duplicate-repo-named-once` failed on the committed phase 3 code and pass now. A pipe
  inside backticks in a cell still splits the cell (the roadmap reader splits on unescaped pipes as `roadmap-claim-check.ps1` does).
- **F4 (recorded, drift).** Plan P6 and T018 name a pure `Get-RepoFit -Roster -Claimant -Repos`. What shipped is `Get-ClaimFit -Root -Row -Claimant`, which reads the roster and the roadmap itself
  and returns the kind (`None`, `Partial`, `Unplaced`, `RowCount`, `NoColumn`, `Unreadable`). It is still the one reader of `repos`; the split into a pure comparison and a reader was
  not kept because the kinds decide on both. Not listed in the phase 3 deviations; listed here.
- **F5 (part fixed).** Added `FIT-001/pass-claimant-case-and-padding` (`-As '  GRACE  '`) and `pass-row-declares-none-empty-cell`. Not added: a `-Json` silence fixture (the harness cannot
  normalise a JSON-escaped Windows path, stated above), a roadmap that exists but cannot be read, and the lib-not-found branch (neither can be built by a recipe).
- **F6 (recorded for phase 4).** The fit reads `docs/roadmap.md` and the roster from the working tree after the claim's fetch and no merge, so a tree behind origin can give a wrong match count or
  cover. The guidance says to claim from an up-to-date `main`, which `claim-feature.ps1` already requires of the branch it starts from.

## Phase 4: guidance, flow-down, roadmap, measurement (T020 to T025)

**Guidance (T020, T021).** `docs/sdlc/team-workflow.md`: section 3 step 4 no longer says the owner picks the reviewer (the reviewer pulls the review with
`scripts/claim-review.ps1`; the kit proposes, ranks and assigns no one; rule 4 stands for other features); the roster paragraph's "`repos` is recorded and read by
nothing" now says it has one reader, the advisory Fit note; a new subsection "Who judges a Critical feature, and whether a feature fits you (feature 037)" beside
the 021 one states the claim (ref shape, who writes it, what the check requires and in what order, the unclaimed-review message, reclaiming, any ref at the slug is a
claim, no dates), what it does not prove, the fetch into the graded clone (review F6 of phase 2), the fit note, the `Repos` column, the working-tree read (review F6 of
phase 3) and the prefix-binding limit of `-Row`/`-As` (review F1 of phase 3, documented as the recommended handling). `docs/sdlc/critical-delivery.md`: the team-arm bullet
of item 5 adds the claim, the roster paragraph's "read by no check" now names its one advisory reader, and a "review claim" paragraph states the rule and its honesty.
No sentence in either file still says the owner alone picks the reviewer or that `repos` is read by nothing (grep). Three digest markers were added and tightened to the
120-character bound; the adoption pack digest is at its 40-line bound, so the flow-down note carries no marker of its own (it would have been the 41st).

**Flow-down note (T022).** `adoption/updating.md`, "Flow-down note: the 2026-10-18 review claim and the fit note (kit feature 037 — no constitution amendment)", shaped
like feature 036's: what was wrong, what it does now, what flows down (verbatim: the four scripts, two documents and this one; surgical: the roadmap template paragraph),
what an owner may newly see (only a team-arm project, only a Critical feature whose review is owed), what does not change, seven stated limits, what was measured, what to
do. `doc-lint.ps1` passes, so every path in it resolves in an adopted project.

**Roadmap (T023).** The GAP-024 inventory row records what 037 closes and what stays open; this feature's row is `in progress` (it becomes `shipped` only after the human
review at merge, as the task says); a decisions-log entry dated 2026-10-18 records Q1, Q2, the plan approval, what the work found, the measurement and the open decisions.
`roadmap-claim-check.ps1` passes, with the claim 037 exempt as the branch checked. `build-digests.ps1` regenerated the branching and critical digests; `-Check` is OK.

**Measurement (T024, SC-001).** Fresh `--no-hardlinks` clones of FitForge, FlowBoard and ExpenseTracker, each with the kit's `scripts/` overlaid as an update would, once as of
`b6b39d4` (the tip before this feature's first phase commit) and once as of the branch tip `fbd02c8`; `enforcement-pack.ps1` and `roadmap-claim-check.ps1` run each way
(`ritual-checks.ps1` was not run). Nothing in place was touched and nothing pushed. Results: **`main` is byte-identical before and after in all three projects**
(FitForge `roadmap-claims: OK (1 claim(s) visible with non-idea rows, Owners and claim counts graded against the declared roster)`, FlowBoard `OK (no NNN-* claims on origin)`,
ExpenseTracker `OK (1 claim(s) visible with non-idea rows)`). The pack applies no scripted checks to the trunk, so this shows no script broke and no verdict moved, not that a
claim was graded. On FitForge's real Critical branch `002-identity-member-profile` (43 commits, team arm by `["anas.m","ahmad"]`) the verdict is the same `FAIL` with exit 1 before and
after, and the only difference is one clause appended to the existing missing-review failure (`; nobody has pulled the review of 002-identity-member-profile yet - a reviewer takes
it with: pwsh -File scripts/claim-review.ps1 -Feature 002-identity-member-profile -As <roster name> (docs/sdlc/team-workflow.md)`). A reviewed Critical feature carrying a claim
was not available in any of the three, so **the claim grading itself rests on the kit's fixtures (`CRIT-R05` to `CRIT-R09`), not on a real history**; SC-001 is met for
"no verdict, line or exit code moves except where the update note says one will", and SC-002 is shown by fixtures only. SC-003's fit note was likewise measured on fixtures only
(none of the three rosters declares `repos`, and none of their roadmaps has a `Repos` column, so a claim there prints nothing).

**Open for the owner: F1 of the phase 3 review.** The prefix-binding limit of `-Row` and `-As` is documented (guidance, update note, roadmap) and the spec's FR-011 is not reworded;
rewording it is an amendment and needs the owner's approver record. Recorded in the roadmap log as open.

### Phase 4 review follow-ups (`ai-code-review-phase4.md`: APPROVE with follow-ups, F1 to F8)

- **F1 (fixed; closes the phase 3 review's F1).** The prefix-binding limit of `-Row` and `-As` was overstated as applying to every description. Probed on a stub of the real
  `param` block (five invocations): a description passed as one quoted argument is unaffected, including one that contains `-Row` or `-A` as a word and one that starts with
  `-Row`; only unquoted words bind (`-ShortName x fix the -Row handling` binds `handling` to `-Row`). The documented form quotes the description, so a claim made as documented and
  without `-Row` is byte-identical and **FR-011 holds for it**. The guidance, the flow-down note, the GAP-024 row and the roadmap log now say "pass the description as one quoted
  argument"; the earlier entries in this file that call it an open owner decision to reword FR-011 are superseded: no amendment is needed.
- **F2 (fixed).** `specs/_templates/**` is `verbatim` in `kit-manifest.json`, not surgical; the flow-down note said "surgical, never applied for you". It now says the template is
  verbatim, gained a paragraph about the optional `Repos` column, and that the adopter's own `docs/roadmap.md` is not touched. `scripts/claim-review.ps1` is covered by `scripts/*.ps1`.
- **F3 (recorded).** T020 edits `docs/sdlc/team-workflow.md` and `docs/sdlc/critical-delivery.md` inside the feature branch, where section 7 of `team-workflow.md` asks governance
  changes to ride alone on a `docs/` branch with team-lead approval. Features 021 and 036 did the same for guidance that describes shipped behaviour. The owner's approval of the task
  list, whose T020 names the edit, is read as covering it; the owner can still ask for the two documents to be split onto a `docs/` branch before merge.
- **F4 (closed by re-running).** T024 and SC-001 name `ritual-checks.ps1` and the first measurement did not run it. Re-run on fresh `--no-hardlinks` clones with `ritual-checks.ps1` added
  (the kit's scripts overlaid as of `b6b39d4` and as of `8c23b42`): the output is **byte-identical on `main` in all three projects**, now including `ritual-checks`; on FitForge's
  `002-identity-member-profile` the only difference is the clause appended to the existing missing-review failure, and it appears in the pack's own output and in the pack member inside
  `ritual-checks`; the verdict is `FAIL` before and after. The first run's statement "ritual-checks was not run" stands for that run; this one supersedes it as the T024 evidence.
- **F5 (now true).** The roadmap log's "four phases, each with a fresh-context AI review" holds with `ai-code-review-phase4.md` (all four: APPROVE with follow-ups).
- **F6 (fixed).** `critical-delivery.md` said `repos` is "read by no check: its one reader is ..." in one sentence; it now says "graded by no check".
- **F7 (fixed in the guidance and note).** Roster names should hold ASCII letters or digits (a name with none cannot claim); with the review file missing and the ledger unreadable, the
  missing-review failure stands alone, with neither the clause nor an `UNGRADED` line.
- **F8 (accepted).** "After the conditions above hold" skips the attestation line (the claim is graded whether or not the attestation is present, as the code does) and the GAP-024
  `**Status**` is appended without a full stop; cosmetic.
