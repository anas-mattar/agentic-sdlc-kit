# Notes: Cross-repo Territory Reach

Evidence and decisions that belong beside the feature but not in its approved documents.

## Approval record — 2026-10-11

The owner (anas.m) approved the spec and the plan on 2026-10-11. The Draft to Approved flip on
`spec.md` is the act that starts the amendment rule (constitution I); it is committed alone, so the
status-only exemption applies as written.

What the approval covers:

- `spec.md` as committed in 19592a9.
- `plan.md` as committed in 619f89c: decisions D1 to D8, the four-phase order, and
  `**Gate Certification**: user-run` (this feature changes an enforcement script).
- `research.md`, `data-model.md`, `contracts/territory-check-output.md` and `quickstart.md` as
  committed in the same commit, and `tasks.md` as committed after it, with each phase's Territory.

What it does **not** cover, stated plainly:

- **Plan D5 (research R6) is not decided.** Spec FR-013 and US3 scenario 2 say a project with no usable
  `codeRepos` sees its existing output unchanged; for a declaration that is present but unusable that
  means a warning and then `CLEAN`, which the spec's own constraint forbids. The plan recommends
  amending those two sentences so that an absent or empty declaration is unchanged and a present but
  unusable one is UNGRADED by name. Approving the spec and plan does not decide this: an amendment
  needs the owner's own approval line, and the spec sentences stand as written until it is given.
  Phases 1 and 2 do not depend on it. Task T016 stops phase 3 until it is decided.

## Phase 1

Written 2026-10-11. Implemented, not yet committed when this section was first written.

**T001, the baseline** (parent commit, `282beb9`, before any edit): `-Case REPOS-` 62 cases, 157
tests; `-Case SCOPE-` 116 cases, 265 tests; `-Case TERR-` 16 cases, 65 tests; 0 failed in each.

**What changed.** `Get-CodeRepos` is in `scripts/adoption-lib.ps1`; `Get-RepoTrunkCandidates` and
`Get-RepoMergeBase` are in `scripts/scope-lib.ps1`; `scripts/scope-check-repos.ps1` calls them
(`Get-DeclaredRepos` is now a thin caller that prints each returned warning with its own prefix, and
the inline trunk loop is one call). The messages are returned as data and each caller speaks in its own
voice. `Get-RepoMergeBase` also returns `Existing`, the candidates that exist at all, which phase 3
needs to tell "no trunk" from "this ref has no merge base"; the scope check does not use it and keeps
its single message.

**T005, after the change.** The same three suites: 157, 265 and 65 tests, **identical to the baseline,
0 failed**. `ritual-checks` has no failing member (`scope-check` is UNGRADED only because no phase
commit exists yet).

**A harness change this needed, stated plainly.** After the extraction, two inventory tests failed in
every run: `REPOS-002`, `REPOS-003` and `REPOS-004` are the three warnings for the record being
unparseable, not an array, or holding a rejected entry, and their anchors (the warning text) were no
longer in `scope-check-repos.ps1`, because the text now lives in the library. The cases themselves
passed, since the output is identical. Weakening the inventory tests, or leaving the messages behind
in the script that no longer owns them, were the wrong fixes. The harness now accepts an optional
`anchorFile` on a rule, naming the shared library file where its message lives; the rule is still graded
by running the script, and the anchor must name exactly `siteCount` non-comment lines of that file.
`tests/enforcement/Coverage.Tests.ps1` (two tests) and `rules.json` (a documented field, three rules)
changed, inside this phase's `tests/**` Territory.

**T005, the direct check, and a mistake of mine in making it.** I ran the original `Get-DeclaredRepos`
(taken verbatim from the parent commit) and the new path side by side over 21 throwaway records: no
file, empty object, unparseable, a root array, a null key, a string, a number, an object, an empty
array, one and two entries, dots and underscores, a path, a backslash, `..`, `.`, a drive, a mix of good
and bad, nulls and booleans inside the array, a duplicate, a space. **All 21 give identical returned
repositories and identical printed messages.** New `Unusable` is true exactly where a warning was
produced (unparseable, a non-array, any rejected entry) and false for an absent record, an absent or
null key, an empty array and a root array, which are the cases the original stayed silent about.

My first run of that comparison reported 11 differences, every one of them a case with a warning. They
were not real: `git show` was decoded through the console's `ibm437` code page, which turned the old
source's em dash into the mojibake `ΓÇö` before it ever ran, so the "original" side was corrupt. The
character codes (915, 199, 246) showed it, and the library string was confirmed to hold the real em
dash (U+2014). With the encoding set to UTF-8, as `scripts/enforcement-pack.ps1` does, the differences
were zero. The lesson is recorded because the same code page is why the owner's console shows `ΓÇö` in
this kit's output.

### Review and remediation — phase 1

Fresh-context AI review: `ai-code-review-phase-1.md`, verdict APPROVE WITH FOLLOW-UPS, no Blocker, no
Major. The reviewer compared `Get-CodeRepos` with the original `Get-DeclaredRepos` over 30 record
shapes (a UTF-8 BOM, CRLF, 5,000 entries, `CodeRepos` in another case, duplicate keys, a trailing comma,
comments, null/empty/array/string roots, a directory named `kit-adoption.json`, invalid UTF-8, 5,000-deep
nesting), under `$ErrorActionPreference = 'Stop'`: no difference in repositories or printed bytes, and
nothing threw. It compared `Get-RepoMergeBase` with the original inline loop on 9 real repository
situations (`-BaseRef`, an orphan trunk, no candidates, a missing ref): identical. It confirmed the
code-repository CI template copies nothing and runs `scope-check-repos.ps1` from a full governance
checkout, so the library is always present. It deleted one message line in a throwaway worktree and both
the case and the exactness test failed, so `anchorFile` cannot pass vacuously. Coverage went from 210 of
221 sites to 207 of 218, and `scope-check-repos.ps1` from 31 of 32 to 28 of 29: the three sites left the
numerator and the denominator together, so the figure is not flattered.

- **F1 (Minor): fixed.** Three comments overclaimed ("the one reader", and that the territory check
  already reads it). `scripts/verify-kit.ps1` still validates `codeRepos` itself for the doctor
  (feature 012 phase 2), and `scripts/territory-check.ps1` calls the library only from phase 3. The
  comments now say what is true, and that this function does not replace the doctor's check.
- **F2 (Minor): fixed.** The coverage sweep could not see code that moved into a library: a fourth
  warning added to `adoption-lib.ps1` passed every test. `emission-idioms.json` now declares the library
  and its accumulator, and a new test counts the library's emission lines against the sites the rules
  that anchor on it declare. Shown to bite: a fourth unowned warning added temporarily fails it with
  "4 emission line(s) match its accumulator, but the rules that anchor on it declare 3", and the file
  was restored. `REPOS-` is now 158 tests, all passing.
- **F3 (doc drift): fixed.** The `function` field of `REPOS-002/003/004` and the
  `scope-check-repos.ps1` idiom note no longer name a function and a site that moved.
- **F4 (Minor): fixed.** The `Existing` contract now says what it returns: on success the candidates up
  to and including the one that resolved, and when no base resolved, every candidate that exists. Phase 3
  reads it only in the second case.
- **F7 (doc drift): fixed.** The `adoption-lib.ps1` header lists its consumers.
- **F8 (Minor): fixed.** The T005 table the task asked for, below. The sentence that the owner's console
  shows `ΓÇö` for the same reason is an inference I did not measure, and is withdrawn as a claim; the
  character codes (915, 199, 246) establish the mojibake in my comparison only.
- **F9 (accepted).** The `anchorFile` design is sound; its limits (block-comment lines, here-strings, two
  messages on one line, an unvalidated field) are theoretical.

**Carried to the owner's D5 conversation (task T016), not changed here:**

- **F5.** `Get-CodeRepos` reads the record with `Test-Path` and `Get-Content -Path`, which interpret
  wildcards, as the original did. A governance root whose path contains `[1]` therefore reads an
  existing record as absent, with `Unusable` false and no warning. Harmless to the scope check as it
  stands (it grades nothing for a project it believes has no code repositories, and says so), but phase 3
  would turn it into `CLEAN`. The fix is `-LiteralPath`, a behaviour change for the scope check, so it is
  the owner's call and belongs with D5.
- **F6.** `Unusable` is false for a null, string or number root, for falsy entries dropped silently (an
  empty string, `0`, `false`, `null`) and for numeric entries, which are accepted as directory names.
  All of this matches the original. D5 should say whether any of it is "present but unusable".

### T005: what `Get-CodeRepos` returns, per shape

| Record | Repos | Warnings | Unusable |
|---|---|---|---|
| no file | none | 0 | false |
| `{}` | none | 0 | false |
| unparseable | none | 1 | true |
| root array | none | 0 | false |
| `codeRepos: null` | none | 0 | false |
| a string | none | 1 | true |
| a number | none | 1 | true |
| an object | none | 1 | true |
| `[]` | none | 0 | false |
| `["api"]` | api | 0 | false |
| `["api", "web"]` | api, web | 0 | false |
| dots, underscores, hyphens | both kept | 0 | false |
| a path, a backslash, `..`, `.`, a drive, a space | none | 1 each | true |
| a mix of good and bad | api, web | 2 | true |
| nulls and booleans among entries | api | 0 | false |
| a duplicate | api, api | 0 | false |

Each row is identical to what the original function returned and printed.

## Phase 2: the ungraded verdict

### T007: `TERR-013` against the unchanged script

Run on the phase 1 tip before `scripts/territory-check.ps1` was touched (`-Case TERR-013`, 5 cases):
`pass` passed. `fail`, `fail-json` and `pass-json` failed on output (the script printed `CLEAN`, or
the JSON without `UNGRADED`). `fail-overlap` exited 2 as expected but failed on output (no ungraded
line). The `fail*` cases therefore fail today for the reason the rule names, and `pass` already passes.
(`pass-json` fails today only because the JSON gains the always-present `UNGRADED` field.)

### T009: changed expectations, with the old text

- **`TERR-012/fail`** (the departure D3 names). Old: `WARNING: Skipping origin/012-other: cannot compare
  with main.` then `CLEAN — '011-thing' shares no files with any open feature branch.` New: the same
  warning, then `UNGRADED: governance: cannot compare 012-other (no remote-tracking ref origin/012-other)`,
  then `UNGRADED — '011-thing' was NOT fully compared (1 comparison(s) not made, listed above), so this is
  not a clean result.` Exit code unchanged (0). The recipe is unchanged; its description and the rule's
  summary and notes say why.
- **`TERR-006/pass` and `TERR-007/pass`** (not named in the task; found by the run). Old JSON:
  `{"BRANCH":"011-thing","CLEAN":false,"OVERLAPS":[...]}`. New: the same with `,"UNGRADED":[]` appended.
  The contract makes `UNGRADED` always present in `-Json`, so this is the additive field, not a change of
  verdict. The `fail` directions of both (the `no remote` state) are untouched, as D3 requires.
- Output order when an overlap and an ungraded entry coexist: overlap blocks, then the ungraded lines,
  then the sequencing guidance (pinned by `TERR-013/fail-overlap`). The contract fixes the anchors, not
  this order.

### Phase 2 review remediation (F1–F6)

- **F1.** The verdict now branches on `$liveOverlap`, not on whether any overlap exists. A run with a
  stale-only overlap and an ungraded entry prints the overlap block, the `UNGRADED:` line, the `UNGRADED —`
  verdict, then the stale hint (exit 0). Reading of D2 adopted: `OVERLAP` as the verdict means a live
  overlap; the owner may overrule it. Pinned by `TERR-013/fail-stale`.
- **F2.** The entry's detail is now chosen by `git rev-parse --verify origin/<feature>`: the missing ref
  keeps `no remote-tracking ref origin/<feature>`; any other failure says `cannot compare with <base>`.
  Only the missing-ref cause has a fixture.
- **F3.** `TERR-013/fail-two` and `fail-two-json`: two skipped claims, the count `2` and the order pinned.
- **F4/F5.** The `TERR-012` rule notes no longer say both directions print CLEAN; the script's
  `.DESCRIPTION` states the ungraded outcome and the `-Json` shape.
- **F6.** Reading recorded: "`UNGRADED` is always present" in the contract means on every run that
  compares. The `no remote` state is deliberately untouched (plan D3; `TERR-006/007` `fail` directions), so
  its JSON still has no `UNGRADED`. Phase 3 must not change it as a side effect.

## Phase 3: the reach

### T015: the fixtures against the phase 2 tip

Run before `scripts/territory-check.ps1` was touched in this phase (`-Case territory-check/`, the 24 new
cases). Every `fail*` case failed on output: nothing reads a code repository, so the script printed
`CLEAN` over each overlap and over each cause. Seven `fail*` cases and `TERR-014/pass-stale` exited as
expected and failed on text only. `TERR-022/pass` and `pass-empty` (no `codeRepos` / an empty one) and
`TERR-014/pass-json` already passed. **The task's expectation "the `pass*` cases already pass" held only
for those three.** Every other `pass` prints the new `CLEAN ... (compared governance and api against 1
open claim(s))` text, which the phase 2 script cannot print, so those fail today for the reason the
feature adds. That is the contract's text, not a fixture defect.

### T016: plan D5

Decided before this phase: the amendment to spec FR-013 and US3 scenario 2 is approved (commit
`e686026`, "Amendment approved by: anas.m, 2026-10-11"; plan D5 carries the same line). Implemented as
amended: an absent or empty `codeRepos` is unchanged, a present but unusable one is UNGRADED by name.

### Decisions taken while implementing (each inside the plan; recorded because a reviewer may differ)

- **`not-a-repository` is a copy, not a share.** `scripts/scope-check-repos.ps1` tests that a declared
  directory is the root of its own repository (`rev-parse --show-toplevel` against the path). Sharing it
  means editing that script, which is outside this phase's Territory, so the territory check carries the
  same five lines with a comment. This is the duplication feature 013 paid for; the follow-up is to move
  it into `scripts/scope-lib.ps1` next to `Get-RepoMergeBase` and call it from both.
- **The branch under check reads both refs.** Plan D4 says `origin/<branch>` falling back to a local head.
  For the branch under check the check reads both when both exist and unions them: a developer's unpushed
  commits are in the local head and a colleague's pushed ones in the remote-tracking ref, and either alone
  would miss one. Other features keep D4's order.
- **`TERR-021`'s note is not an ungraded entry.** Spec Assumptions: a repository with no `origin` "is
  compared against its local branches only, and the output says so". The task's `fail` wording for
  `TERR-021` ("UNGRADED ... no CLEAN anywhere") reads as a template for the other six, and plan Risks says
  only a failed fetch makes the run ungraded. Implemented as a `compared <repo>: local branches only`
  line before the verdict; the run can still end `CLEAN`. If the owner wants the stronger reading it is a
  one-line change and a changed expectation in `TERR-019`, `TERR-021` and `TERR-017`.
- **`origin/HEAD` is not a trunk in a fixture whose remote is itself.** `git fetch` (2.48 and later)
  creates `refs/remotes/origin/HEAD`, and for `origin: self` it names the checked-out feature branch, so a
  repository whose only branch is the feature branch still "has" the trunk candidate `origin/HEAD`. In a
  real clone `origin/HEAD` names the remote's default branch. `TERR-017` therefore has no origin in either
  direction. Not a defect in the check; a limit of the self-origin fixture.
- **The corrupt-ref cases have no origin either**, so the truncated commit is not carried through a fetch,
  which would make the repository `fetch-failed` instead of `branch-uncomparable`.
- **`fail-code-only-liveness`** uses a governance commit 450 hours old and a code commit 2 hours old. A
  governance branch with zero commits ahead of the trunk cannot be built (a recipe commit is always a
  commit), so "claimed, no work yet" is reached only by the pre-existing governance path.

### T023: a throwaway layout built by hand, outside the harness

Two features, `api` as a code repository with its own `origin` (itself), `kit-adoption.json` declaring it,
run from the governance root on `011-thing`:

| State | Printed | Exit |
|---|---|---|
| both features edit `api/src/Orders.cs` | `OVERLAP with 012-other [live]:` / `api/src/Orders.cs` and the sequencing guidance | 2 |
| the other feature drops its edit | `CLEAN - '011-thing' shares no files ... (compared governance and api against 1 open claim(s)).` | 0 |
| `api` renamed to `api-moved` | `UNGRADED: api: not present in this checkout`, then the `UNGRADED -` verdict | 0 |
| `api` removed | the same | 0 |
| `api` rebuilt, `origin` a path that does not exist, `-Json` | `{"BRANCH":"011-thing","CLEAN":false,"OVERLAPS":[],"UNGRADED":[{"repo":"api","feature":null,"cause":"fetch-failed","detail":"git fetch origin failed in the repository"}]}` | 0 |
| `api` with no `origin` | `compared api: local branches only`, then `CLEAN ... (compared governance and api against 1 open claim(s))` | 0 |

(The em dash prints as a hyphen in this console; the harness pins the real character.)

### Carried forward

- **Phase 1 review F5 is not reachable through this script** (corrected after the phase 3 review, F7;
  this note first said it was live). `Get-CodeRepos` reads the record with `Test-Path` and `Get-Content
  -Path`, which interpret wildcards, so a governance root containing `[` or `]` would read an existing
  record as absent. But the territory check never gets there: `Push-Location $repoRoot` treats the same
  characters as a wildcard and the script dies at that line with exit 1 and a PowerShell error, as it did
  before this feature. That is loud, not a false `CLEAN`. The `-LiteralPath` fix in
  `scripts/adoption-lib.ps1` still matters for the scope check; it is outside this phase's Territory and
  remains the owner's call.

### Phase 3 review remediation (F1–F9)

Review: `ai-code-review-phase-3.md` (APPROVE WITH FOLLOW-UPS; no Blocker, no Major).

- **F1: fixed.** A repeated `codeRepos` entry is one repository (`Select-Object -Unique`), for the
  comparison, the ungraded count and the `CLEAN` note. `TERR-014/fail-duplicate-declaration`.
- **F3: fixed.** The detail for a ref whose merge base cannot be had now says what git cannot
  distinguish: `no merge base with main: unrelated history or an unreadable ref`. The three later failures
  each have their own wording (`diff against the merge base failed`, `commit count against the merge base
  failed`, `last commit unreadable`); they are not reachable by any fixture, since a ref that passes
  `merge-base` and then fails those reads would need an object corrupted between two reads, and are stated
  here as untested. The genuine no-shared-history case now has a fixture: a new recipe knob `orphan`
  (`checkout --orphan`) in `tests/enforcement/lib/FixtureRepo.psm1`, used by `TERR-019/fail-orphan`.
  `TERR-019/fail` and `fail-own-branch` changed their expected detail text to match; the old text was
  `(no merge base with main)`.
- **F5: documented.** The script header says a code repository's uncommitted edits count when it is checked
  out on the branch under check even if `-Branch` names a branch the governance repository is not on, and
  that the union of the local head and the remote-tracking ref can over-report, never miss.
- **F7: corrected** (the note above).
- **F8: partly fixed.** `TERR-017/fail` now keeps both feature branches and differs from `pass` only in
  having no `main`. Added `TERR-014/pass-rename`, `fail-local-only` (the local-head fallback),
  `fail-non-ascii` and `fail-overlap-and-ungraded-json`. Not added: an own branch that exists only as
  `origin/<branch>` (the fixture builder always leaves a local head; it would need another knob).
- **F9: fixed.** T012–T023 ticked; T016 is satisfied by `e686026`.

**Carried to the owner, not changed here:**

- **F2.** For a repository with a successfully fetched `origin`, the fallback to a local head can bring back
  a claim whose remote branch was deleted (a merged or abandoned feature whose governance branch is still
  open), and report it live. It is plan D4 as written. Options: keep D4 and say so in the phase 4 guidance,
  or restrict the fallback to repositories with no `origin` (a changed expectation plus a fixture pair).
- **F4.** `-Json` does not carry the "local branches only" limit; `CLEAN: true` there reads as the stronger
  claim. Fixing it adds a field to the contract, which is an approved document, so it needs the owner:
  an additive `NOTES` array in the JSON and a fixture, or a recorded decision that the limit is text-only.
- **F6.** The shared repository-root test (`Test-IsRepoRoot` in `scope-lib.ps1`, both scripts calling it) is
  not in `tasks.md`; adding a task or widening phase 4's Territory is an amendment to an approved document, so
  it is left for the owner. It remains the follow-up recorded under "Decisions taken while implementing".

### Round 2 review remediation (R2-F1 to R2-F3)

Review: the "Round 2" section of `ai-code-review-phase-3.md` (APPROVE WITH FOLLOW-UPS; no Blocker, no Major).

- **R2-F1: fixed, without a harness fixture.** The de-duplication of the declaration was case-sensitive, so
  `["api","API"]` compared one repository twice on a case-insensitive filesystem. Identity is now read from
  git's canonical git directory (`rev-parse --absolute-git-dir`), so the same repository under two spellings
  is one comparison. Verified by hand on this Windows host (`api` and `API` over one repository printed the
  overlap file once). There is **no fixture**: on a case-sensitive filesystem `API` is a different, absent
  directory and the case would print a different verdict on the ubuntu CI leg, so the fixture would be
  platform-dependent. That is a coverage gap, stated here rather than hidden.
- **R2-F2: fixed.** The `orphan` recipe knob throws when it names a branch that already exists
  (`Harness.Tests.ps1` pins it), instead of being silently ignored.
- **R2-F3: corrected.** F8 above left more undone than it listed. Not covered by any fixture: an own branch
  that exists only as `origin/<branch>`; a claim that has no branch in a declared code repository (it is
  skipped as "no work there" in several cases but never asserted on its own); the case-variant duplicate
  (R2-F1); and the three read failures after a successful merge base (F3).

## Phase 4: guidance, flow-down and bookkeeping

### T026: the measurement on clones of the three adopted projects

Method. Each project (FitForge, FlowBoard, ExpenseTracker) was cloned `--no-hardlinks` from its local
directory, and so were its two code repositories, beside the governance clone; the clone's `origin` is the
project on disk (read-only, no network), so the real projects were never touched and the clones' claim
ledger holds no feature the real remote might. Three states per clone: **installed** (what the project has
today, kit 0.7.0), **kit main** (`2221879`, the parent of this feature, applied with `update-kit.ps1`, digests
regenerated, committed) and **kit HEAD** (`7992bb4` plus the working tree, applied on top the same way). The
territory check ran in each state on a feature branch, with the code repositories present and then renamed
away; `ritual-checks.ps1` ran in each state. The kit-main to kit-head step is this feature's delta; the
installed to kit-main step is features 015 to 017 and is not this feature's.

A first pass applied kit HEAD straight to the installed state, which folds all of that in, and was discarded
for the delta. A second pass had a script defect (`git checkout -f` threw away the uncommitted kit-head apply
before the checks ran, so its "new" state still held the old script), and was also discarded. Both are
recorded because the second one looked like a clean result: it printed `CLEAN` for a project that now says
`UNGRADED`, and only the missing `compared …` clause gave it away.

| Project / checkout | Code repos | Installed | Kit main | Kit HEAD (this feature) |
|---|---|---|---|---|
| ExpenseTracker `003-expense-entry` | present or absent | `CLEAN` | `CLEAN` | `CLEAN`, same text (no `codeRepos` on this branch) |
| ExpenseTracker `main`, `-Branch 003-expense-entry` | present | `CLEAN` | `CLEAN` | `CLEAN (compared governance and expense-tracker-api, expense-tracker-web against 0 open claim(s))` |
| ExpenseTracker `main`, `-Branch 003-expense-entry` | absent | `CLEAN` | `CLEAN` | **`UNGRADED`**, 2 entries `not present in this checkout` |
| FitForge `002-identity-member-profile` | present | `CLEAN` | `CLEAN` | `CLEAN (compared … fitforge-api, fitforge-web against 0 open claim(s))` |
| FitForge `002-identity-member-profile` | absent | `CLEAN` | `CLEAN` | **`UNGRADED`**, 2 entries |
| FlowBoard `main`, `-Branch 099-measure` (a throwaway) | present | `CLEAN` | `CLEAN` | `CLEAN (compared … flowboard-api, flowboard-web against 0 open claim(s))` |
| FlowBoard `main`, `-Branch 099-measure` | absent | `CLEAN` | `CLEAN` | **`UNGRADED`**, 2 entries |

Exit codes: `0` in every cell. `ritual-checks.ps1`, kit main to kit HEAD: ExpenseTracker `RESULT OK` to `RESULT
OK` on both checkouts; FlowBoard `RESULT OK` to `RESULT OK`; FitForge `RESULT FAIL (2 of 7)` to the same
two members (`enforcement-pack`, `scope-check`), both already failing with the kit before this feature
(installed: `enforcement-pack` alone). No member moved because of this feature.

**The verdict that moved, as a finding and not rounded.** SC-004 allows a verdict to change "where the check
was previously reporting `CLEAN` over a comparison it had skipped". What moved is that case in a wider
sense: a project that declares code repositories, run where they are absent, now says `UNGRADED` where it said
`CLEAN` without looking in them. No claim was skipped, because there were no open claims in any clone; the
check was blind to a declared repository. The sentence of SC-004 reads naturally either way, but the owner
should know the move is wider than "a skipped claim", and the flow-down note says so (governance-only CI).

**Not exercised.** No clone had another open feature branch, so no real overlap was reported; the overlap,
and every cause, are proved by the harness's fixtures. The clones' claim ledger was the local project on disk,
not the project's GitHub remote. `-Json` was captured in the controlled pass but not tabulated.

**A doc-lint result from the first pass.** Applying kit HEAD straight to the installed 0.7.0 state, `doc-lint`
failed in the adopted project on three unresolved paths: two were this phase's own examples in
`docs/sdlc/team-workflow.md` (fixed: the section now uses `<repo>/<path>`), and one was
`adoption/updating.md:255`, the feature 012 reference to `.github/workflows/code-repo-scope-check.yml.template`,
a surgical file `update-kit.ps1` does not copy. In the controlled pass that file was present in the clone and
`doc-lint` passed, so the cause (the order of the two applies, or the 0.7.0 starting point) is not
established. It is not this feature's text, and it is recorded rather than changed here.
