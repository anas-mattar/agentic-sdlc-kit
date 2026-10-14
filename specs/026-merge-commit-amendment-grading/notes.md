# Notes: 026 — grade the content a merge commit authors in the amendment-authority check

Phase evidence, never law. The documents are `spec.md`, `plan.md`, `tasks.md`.

## Phase 1

### T001 — baseline on the parent commit (`fad21b7`, tasks committed)

- Full harness on an isolated detached worktree of the parent: **1520 passed, 0 failed, 0 skipped**.
- `tests/enforcement/lib/FixtureRepo.psm1` ran `git merge --no-ff --no-edit -m <message> <branch>` for a `merge` commit and then `continue`d: no `write`,
  `delete` or any other field was read, so the result of a merge always equalled what git's own merge produced. Feature 025's reproduction (an approved
  `plan.md` gaining a line **inside** a merge) could not be expressed, and a conflicting merge threw a raw `fixture git failed` with no way to resolve it.
  `AMEND-001/pass-merge` (a merge that authors nothing) is the only existing merge fixture for this check.

### T002 — self-tests first, shown failing on the parent

Nine tests in `tests/enforcement/Harness.Tests.ps1` ("merge commits that carry content (feature 026, plan D8)"), run against the unmodified library:
**8 failed, 1 passed**. The one that passes on the parent is the control that stops an over-change: "leaves a plain merge exactly as it was: two parents and
no content of its own". A first draft of "refuses a resolve that leaves a conflicted file unnamed" passed on the parent for the wrong reason (git's own
conflict error also names the file); its expected message was tightened to the library's own wording so it fails there and passes only on the new refusal.

### T003 — the change

`tests/enforcement/lib/FixtureRepo.psm1`: on a `merge` commit, optional `mergeWrite` (the shape of `write`, landing in the merge result), `mergeDelete`
(removing files from the merge result only) and `resolve` (the content taken for each file a conflicting merge leaves conflicted). A merge with none of
them runs the same command it always ran. With them, the merge runs `--no-commit`, the content goes in, and the commit is made with the recipe's message.
Refused, never ignored: a conflict `resolve` does not name; a `resolve` on a merge that did not conflict; any of the three fields on a commit that is not a
merge. The module header and `tests/enforcement/README.md` list the fields.

**Two details beyond the words of plan D8, recorded here and not written into the plan:**

1. `merge` may be an **array** of branch names, which makes an octopus merge. T006 needs an octopus fixture ("an octopus merge that authors `plan.md`"),
   and a recipe could not describe one. It is one field shape, covered by its own self-test; it is the library's `merge` field, not a new behaviour.
2. `resolve` on a merge with **nothing to resolve** is refused (plan D8 listed only the converse). It follows the library's rule that a field it cannot
   honour fails loud, and a silently ignored `resolve` would give a fixture that passes for the wrong reason.

### T004 — runs

Agent-run, feedback only; none of this certifies (the owner holds the gate).

- `-Case AMEND-`: 121 assertions passed, 0 failed (every existing amendment case unchanged, including `AMEND-001/pass-merge`).
- Full harness on the working tree with the phase 1 change: **1529 passed, 0 failed, 0 skipped**: 1520 baseline + 9 new self-tests. Every pre-existing
  case unchanged in outcome.
- No script under `scripts/` changed; no fixture case under `tests/enforcement/cases/` changed.

### Gate certification, phase 1 (user-run)

Gate certified (user-run): `pwsh -File scripts/ritual-checks.ps1` on the phase 1 commit `15a0e6f`, exit code **0**, confirmed by the owner (anas.m, 2026-10-14). The
owner's own run showed doc-lint, enforcement-pack, scope-check (`PASS phase 1 commit 15a0e6f (4 file(s))`), digests and roadmap-claims OK; scope-repos and
verify-kit n/a.

Awaiting: the fresh-context AI review of phase 1 (Reviewer Provenance) and the owner's go-ahead for phase 2.

### Phase 1 review remediation (review `ai-code-review-phase-1.md`, REQUEST CHANGES; owner decision of 2026-10-14)

Owner decision, in the owner's words in the session: "leave it as is, commit the remediation" (on F3).

| Finding | What was done |
|---|---|
| F1 (BLOCKING) | When the merged branch was already an ancestor, `git merge --no-ff --no-commit` started no merge and the library committed an ordinary one-parent commit titled "merge" carrying the `mergeWrite` content (the plain path silently made no commit at all). Both paths now refuse: the content path when `MERGE_HEAD` does not exist, the plain path when `HEAD` has fewer than two parents afterwards. Two self-tests. Mutation shown for each guard (removing it fails exactly its test); the library was restored byte for byte (`cmp`). |
| F2 | A `resolve` naming a file that did not conflict, beside one that did, is refused (was silently treated as a write). Self-test and mutation shown. The earlier "leaves a conflicted file unnamed" test now uses two conflicted files, so it still isolates its own refusal. |
| F3 (CONFIRM) | **Owner decision: leave it as is.** `hoursAgo` on a merge is ignored on both paths, as it always was; `REPOS-016`, `REPOS-018` and `REPOS-034` carry it. Stated in the module header so it is no longer silent. |
| F4 | A file named by both `resolve` and `mergeWrite` is refused (was: `mergeWrite` silently won). Self-test and mutation shown. |
| F5 | The module header now says what cannot be expressed: an octopus merge with a conflict (git itself refuses one) and a conflict resolved by deleting the file (`resolve` always writes content). |
| F6 | **Recorded, not changed (pre-dates the phase and is library-wide):** a refusal leaves the temporary fixture repository on disk, and `%TEMP%` held 1280 `kit-fixture-*` directories when the reviewer looked. Not fixed here: cleaning up on every throw changes the whole library and is its own piece of work. |
| F7 | The plain-merge control now pins the default message ("merge main") and a second test builds a merge with no message; the `mergeDelete` test now asserts two parents. **Not addressed, said plainly:** removing the `merge --abort` is unobservable from a test (the repository is thrown away when New-FixtureRepo throws), and "routing a plain merge through the new path" cannot fail a test because both paths build the same merge. |
| F8 | Accepted: the octopus array and refusing a `resolve` on a non-conflicting merge are within D8. |
| F9 | `notes.md` now carries T001's exact output below. **Plan D8 drift, carried to the next owner-approved amendment of the plan, not edited here:** it says the old code ran `--no-commit`; it ran `--no-edit`. |
| F10 | Accepted, as for the existing `delete`: `mergeDelete` of a missing path is ignored; `"mergeDelete": []` and `"resolve": ""` on a non-merge commit are accepted as empty. |

**T001's exact output (`AMEND-001/pass-merge`, a merge that authors nothing; exit 0):**

```text
enforcement-pack: branch '001-thing', diff base '<SHA>', 4 changed file(s)
LevelSurface: not armed — kit-adoption.json declares no critical surfaces, so 001-thing (Standard) was not checked against any (adoption/updating.md)
AmendmentAuthority: graded 1 of 3 commit(s) in <SHA>..HEAD (2 not graded: 1 merge commit(s); 1 made before the check existed (plan D2b))
enforcement-pack: OK
```

Runs after the remediation: `-Case NOTHING` (the harness self-tests): 58 passed, 0 failed (53 before the remediation, 5 added); `-Case AMEND-`: 126 passed, 0 failed.
The full-harness count for the remediated tree is recorded below when its run finishes.

### Gate certification, phase 1 after the review remediation (user-run)

Gate certified (user-run): `pwsh -File scripts/ritual-checks.ps1` on `8d3badf` (the phase 1 commit `15a0e6f` and its review remediation), exit code **0**, confirmed
by the owner (anas.m, 2026-10-14).

### Round 2 review (`ai-code-review-phase-1-round-2.md`, APPROVE with follow-ups) and its remediation

Round 2 reproduced F1 to F10 (each resolved or accepted as dispositioned, all nine existing merge recipes still build, the seven named mutations each fail
exactly their intended test) and found five more. Owner instruction, in the owner's words: "yes, apply all of those and commit".

| Finding | What was done |
|---|---|
| F11 (MINOR) | The plain-path guard counted parents, so a second plain merge of an already-merged branch onto a `HEAD` that is already a merge made no commit and nothing complained. One shared check, `Assert-FixtureMergeShape`, now runs after both paths: `HEAD` must have moved and its parent count must equal 1 plus the number of distinct branches named. Self-test; mutation shown (dropping the "HEAD moved" half fails exactly that test). **A first draft of that test passed for the wrong reason**: its recipe created `two` and `feat` from the tip of `one`, so the first merge was already refused; the mutation (which failed nothing) exposed it, and the recipe now returns to `main` between branches so the second merge is the refused one. |
| F12 (MINOR) | An octopus naming an already-merged branch quietly became a two-parent merge, on both paths. The same check refuses it (2 parents where 3 were expected). Self-test for the plain and the content path; mutation shown (dropping the parent-count half fails it). A merge of the current branch into itself is refused too (self-test). |
| F13 (MINOR) | The "started no merge" message no longer says `mergeWrite` when the content is `mergeDelete`, the plain refusal no longer always says "one-parent" (it now reports the real parent count), and the missing blank line between two tests is restored. |
| F14 (DOC DRIFT) | **Correction to the F7 row above:** routing a plain merge through the new path is not unfailable: it fails one test, by message text. And the default message is pinned by its own test ("keeps the default merge message..."), not by the plain-merge control. |
| F15 (ACCEPTED) | An identical-content `mergeWrite` authors nothing, and a falsy `merge` with no content field builds an ordinary commit. Same class as F10 and the parent library's existing rule. |

Runs after this remediation: `-Case NOTHING` (the harness self-tests): 61 passed, 0 failed (58 before, 3 added); `-Case AMEND-`: 129 passed; `SCOPE-014`, `SCOPE-026`,
`REPOS-016`, `REPOS-018`, `REPOS-034` (every existing recipe that merges): all passed. The full-harness count for this tree is recorded below when its run finishes.

### Gate certification, phase 1 after the round 2 remediation (user-run)

Gate certified (user-run): `pwsh -File scripts/ritual-checks.ps1` on `78bf472` (the phase 1 commit, its review remediation and the round 2 remediation), exit code **0**, confirmed
by the owner (anas.m, 2026-10-14).

## Phase 2

### T005 — baseline on the parent commit (`2977ca5`)

- Full harness on an isolated detached worktree of the parent: recorded below ("Full harness, parent and phase 2").
- Feature 025's reproduction inside a merge (a Critical branch, an approved `plan.md` gaining `**Merge Readiness**: pending` in a merge that has a second
  parent of its own, no record), built with the phase 1 field `mergeWrite`: on the parent the run prints
  `AmendmentAuthority: graded 1 of 3 commit(s) ... (2 not graded: 1 merge commit(s); 1 made before the check existed (plan D2b))`, the CriticalEvidence
  deferral WARNING, and `enforcement-pack: OK`, **exit 0**. That is the gap this phase closes (fixture
  `AMEND-001/fail-merge-readiness-added-in-merge-unapproved`).

### T006 — fixtures first (plan D9), and how each behaves on the parent

Nineteen cases, built by a generator kept outside the repository (its expectations are literal text written by hand in it, never computed from the script
under test). Each pair differs in one condition. Run against the unmodified `scripts/enforcement-pack.ps1` before the change:

| Case | On the parent | Why |
|---|---|---|
| `AMEND-001/pass-merge-main-into-branch` | PASS (control, by design) | a `Merge branch 'main' into 001-thing` after main brought another feature's documents, a roadmap change and a script; authored nothing, output byte-identical |
| `AMEND-001/pass-merge-conflict-take-branch-side`, `pass-merge-conflict-take-side-whole` | PASS (controls, by design) | both sides amended `plan.md`, each with its own record; the conflict is resolved by taking one side whole |
| `AMEND-001/pass-merge-clean-automatic` | PASS (control, by design) | two parents amended different places, git merges cleanly (plan D2) |
| `AMEND-001/pass-merge-tick-only-both-parents`, `pass-merge-status-only` | PASS (controls, by design) | the exemptions hold against every parent (plan D3) |
| `AMEND-001/fail-merge-readiness-added-in-merge-unapproved` | FAIL: observed `OK`, exit 0 | feature 025's reproduction (SC-002) |
| `AMEND-001/pass-merge-readiness-added-in-merge-approved` | FAIL: graded 1 of 3, not 2 of 3 | the merge was skipped, so the count differs |
| `AMEND-002/fail-merge`, `AMEND-002/pass-merge` | FAIL (count line) | the merge was skipped |
| `AMEND-001/fail-merge-hand-merged-conflict`, `pass-merge-hand-merged-conflict-record` | FAIL: observed `OK` / count line | a conflict resolved by hand |
| `AMEND-001/fail-merge-combines-approved-amendments` | FAIL: observed `OK`, exit 0 | two approved amendments combined, no fresh record (D4) |
| `AMEND-001/fail-merge-octopus-clean-combination`, `pass-merge-octopus-record`, `fail-merge-octopus-authors-plan` | FAIL | an octopus merge (the fail-closed fallback, D2) |
| `AMEND-001/fail-merge-tick-vs-rewrite`, `fail-merge-status-plus-text` | FAIL: observed `OK`, exit 0 | an exemption that fails against one parent (D3) |
| `AMEND-001/fail-merge-deletes-approved-document` | FAIL: count line differs | a deleted contract; the first draft deleted `tasks.md`, which also fails Structure, so it deletes a contract instead |

Six controls pass and thirteen fail on the parent, as written. **Two fixture mistakes the work found, both mine:** the deleted-document case (above), and
`pass-merge-status-only`, whose first version passed the status text into the `readiness` parameter of the generator, so the first parent already held the
approved status and the merge equalled it: the control passed for the wrong reason. The mutation below exposed it (dropping the exemption failed only the
tick control); it is fixed, and the same mutation now fails both.

**`AMEND-008` has no fixture, and is an inventoried exemption** (the plan and tasks named a depth-1 clone). A depth-1 clone is refused first by AMEND-003 (the
shallow guard). Truncating the second parent of a merge (`truncateCommit: HEAD^2`, measured) makes `git merge-base` fail, so the run prints an empty diff base
and ends on AMEND-004 before any merge is read; `rev-list` over the range fails the same way. No recipe state reaches the new refusal with the earlier guards
intact, so a case would pin AMEND-003 or AMEND-004 under this rule's name. It is exempted in `rules.json` with that reasoning, the way AMEND-007 is (feature
015 FR-004), and the site stays inventoried so it cannot be reworded away.

### T007 — the inventory

`AMEND-008` added (an exemption, as above); the `AMEND-001` and `AMEND-002` notes describe the merge variants. The coverage report names no unowned site
and the recall sweep reports no new unclassified candidate: the `$script:failures +=` form it already knows is the one the new site uses.

### T008 — the change (`scripts/enforcement-pack.ps1`)

- `Get-FeatureDocMap`: one `git ls-tree -r -z` per commit gives path to blob id for the feature's graded documents (D1).
- `Get-AutoMergeTree`: `git merge-tree --write-tree --no-messages` of the two parents; exit 0 and exit 1 (a conflict, markers in the tree) both name a tree, any
  other exit (an old git's unknown option, any failure) returns nothing and the merge falls back to the unrefined rule (D2).
- `Get-MergeAuthoredPaths`: per candidate document, not authored if absent in every parent (first appearance), equal to any parent's blob (absence counts as a
  value), or equal to git's automatic merge; otherwise exempt only if the tick-only or Status-only test holds against **every** parent (D3); otherwise authored.
  A parent or tree that cannot be read comes back as unreadable.
- `Get-MergeRecordLines`: a record line is new when its visible count in the merged file exceeds its count in **every** parent (D4). It counts occurrences in
  the file directly rather than through `git diff -U0`: a line whose count rose against a parent is necessarily a line that parent's diff added, so it is the
  same set as `Get-AddedRecordLines` applied per parent and intersected, with no combined-diff output to parse. `Get-AddedRecordLines` is not edited.
- The loop: the unconditional merge skip becomes the grading branch. A merge that authored nothing is skipped and counted under `merge commit(s)` exactly as
  before (D6); one that authored something goes through the same boundary test, record test and approver-in-the-message test as any commit, and the two failure
  sentences gain one appended clause for a merge (D5). An unreadable merge or parent is refused with the existing "fetch the full history" shape (D7).
- The `LIMIT` comment above `ConvertTo-PhaseNumber` (feature 025's limit) says what is now graded and what stays open.

One behaviour to know: a merge whose first parent predates the check and that authored something is counted under "made before the check existed", as an
ordinary commit would be; a merge that authored nothing is counted as a merge whether it is before or after the boundary, so no existing count line moves.

### T009 — mutations, each failing exactly the fixtures meant to catch it, the script restored byte for byte (`cmp`)

| Mutation | Fixtures that fail (`-Case merge`) |
|---|---|
| drop the exemptions (`$exempt = $false`) | `pass-merge-status-only`, `pass-merge-tick-only-both-parents` |
| the exemption against the first parent only | `fail-merge-tick-vs-rewrite` |
| a record new against the first parent only | `fail-merge-combines-approved-amendments`, `fail-merge-hand-merged-conflict`, `fail-merge-octopus-clean-combination` |
| skip the automatic-merge comparison | `pass-merge-clean-automatic` |
| compare with the first parent only | `pass-merge-conflict-take-side-whole` |
| compare with the last parent only | `pass-merge-conflict-take-branch-side` |
| never accept equality with a parent | `fail-merge-octopus-authors-plan`, `fail-merge-octopus-clean-combination`, `pass-merge-conflict-take-branch-side`, `pass-merge-conflict-take-side-whole` |

The "record new against the first parent only" mutation fails those three through the other failure sentence (the record counted, so the message half failed
instead): each is pinned by its text.

### T010 — runs on the working tree

`-Case AMEND-`: 167 passed, 0 failed (54 cases). `-Case CRIT-`: 225 passed, 0 failed (83 cases). `ritual-checks.ps1`: RESULT OK. Every pre-existing `AMEND-*`
case is unchanged. The coverage report names no unowned site (enforcement-pack.ps1: 72 of 78 sites fixtured, 2 exempt, 4 not a rule) and prints no unclassified candidate. The full-harness count for the phase 2 commit is recorded below when its run finishes.

### Gate certification, phase 2 (user-run)

Gate certified (user-run): `pwsh -File scripts/ritual-checks.ps1` on `bb08af7` (the phase 2 commit), exit code **0**, confirmed by the owner (anas.m,
2026-10-14).

### Full harness, parent and phase 2 (isolated detached worktrees, removed afterwards)

- Parent `2977ca5`: **1537 passed, 0 failed, 0 skipped**.
- Phase 2 commit `bb08af7`: **1575 passed, 0 failed, 0 skipped**.
- Difference: 38 = the 19 new cases, two tests each (exit code, output). No pre-existing test changed.

### Phase 2 review (`ai-code-review-phase-2.md`, REQUEST CHANGES) and its remediation

Fresh-context review of `bb08af7`: REQUEST CHANGES (F1 blocking, F2 and F3 major). Owner instruction, in the owner's words: "yes, apply all of those and commit",
given after the findings and the three decisions were put to the owner (F1 follow plan D3/D9, F2 fix or accept and document, F3 to F8 apply). The owner did not
say which of the two F2 options; the one taken is stated in the table.

| Finding | What was done |
|---|---|
| F1 (BLOCKING) | A removal was "equal to a parent" when a parent never had the file, so a main merged into the branch exempted every deletion, and the old path of a rename. Now only a document the merge KEEPS can equal a parent's blob; a removal is silent only when git's automatic merge removes it too (a deletion on one side stays a non-event). Reading taken: **plan D3 and D9** (a deletion is graded), which the phase 1 and 2 documents state; spec FR-002 and its Assumption can be read the other way, so this is recorded here as the reading chosen by the owner's instruction, not as a silent pick. Two fixtures in the field shape (main merged into the branch: `fail-merge-deletes-contract-main-into-branch`, `fail-merge-renames-and-rewrites-contract`), shown failing on `bb08af7` (observed `OK`, exit 0) and passing now; mutation (reverting the guard) fails exactly those two. |
| F2 (MAJOR) | **Accepted and documented, not fixed.** A parent's version is trusted even when its only grading was a creation exemption, so taking that side whole replaces an approved plan with no record. Not a regression (before 026 every merge was skipped), and narrowing D1 for two-parent merges is a design change beyond the approved plan. The script comment now states it precisely. **Carried to phase 3:** the `critical-delivery.md` paragraph and the `adoption/updating.md` flow-down note must name it as a known limit. The owner may still ask for the narrowing, which would be its own change with a fixture. |
| F3 (MAJOR) | **Correction to T006 above:** `AMEND-008` is reachable. `truncateCommit: "HEAD^2^{tree}"` leaves the commit intact (so merge-base and rev-list succeed) and truncates the tree. The exemption is removed; `AMEND-008/fail` and `AMEND-008/pass` (the same merge, every object readable) are in; the `rules.json` text is rewritten; the message now also says "if the history is complete, an object is damaged". Shown failing on `bb08af7` (the old message text). The silent `0 changed file(s)` the review saw in that state (`Get-ChangedFiles` swallowing an unreadable tree) is outside this feature and is logged as a follow-up. |
| F4 (MINOR) | **Correction to T008 above:** the merge record helper was not "the same set": it pattern-matched the visible text, so a record with a trailing inline comment counted in a merge and not in an ordinary commit. It now takes candidates from the raw trimmed lines of the merged file and requires the same text to be visible, as `Get-AddedRecordLines` does. Fixture `fail-merge-record-with-inline-comment`, shown failing on `bb08af7`; mutation (candidates from visible text) fails exactly it. The plan and tasks name `git diff -U0` per parent; the counting method stands (a line whose count rose against a parent is a line that parent's diff added) and this is the deliberate deviation. |
| F5 (MINOR) | The commit message of `bb08af7` says five mutations; the T009 table lists seven (and nine now with the two above). The table is right; the commit message cannot be amended. The full-harness counts are in (`22ac126`). |
| F6 (DOC DRIFT) | The `AMEND-001` inventory note said "Twenty-two directions"; it was stale since feature 025 (25 before 026) and is now 45. **Not done:** plan D11 puts the script header `LIMIT` comment in phase 3 while tasks T008 (followed) puts it in phase 2. Amending an approved plan needs the owner's approver record, so the drift is flagged here and left for the owner: tasks T008 is what was followed. |
| F7 (MINOR) | **Accepted.** About 170 ms per merge (40 merges: 4.6 s before, 11.5 s after, the reviewer's measurement). Phase 3's replay reports the run time on the largest history. |
| F8 (NIT) | No code change. The claim is "the ordinary path's behaviour is unchanged": the `foreach` header and `$mergeNote` are the only lines touched there, inert for an ordinary commit. |

Runs after the remediation: `-Case AMEND-`: 177 passed, 0 failed (24 cases added over the phase). The full-harness count for the remediated tree is recorded
below when its run finishes.

### Gate certification, phase 2 after the review remediation (user-run)

Gate certified (user-run): `pwsh -File scripts/ritual-checks.ps1` on `e661139` (the phase 2 commit and its review remediation), exit code **0**, confirmed by
the owner (anas.m, 2026-10-14). The full-harness count for this tree has not been run; the gate and `-Case AMEND-` (177 passed) are the evidence so far.

## Phase 3

### T011 — constitution I

Read in full. The Amendment authority clause says a later change to an approved `spec.md`, `plan.md`, `tasks.md` or `contracts/` "MUST record who approved it", that
the amended section carries the record and "the amendment commit names the same approver". It says nothing about merge commits or about who authors a merge,
and a merge is a commit that can name an approver. **No constitution amendment is needed** (plan D11, as expected).

### T012 — `docs/sdlc/critical-delivery.md`

The limits sentence of the merge-readiness declaration ("the amendment check does not grade merge commits ... at all") is replaced: a merge is graded for what it
authored, with what stays open (a parent's version taken whole is trusted, the strict fallback, the record as a written claim). The digest marker "ungraded in a
merge commit" is replaced and one marker added (each within 120 characters, checked). `docs/digests/**` regenerated by `scripts/build-digests.ps1`, never by hand:
`build-digests: OK (5 digest(s), 112 marker(s))` (109 before).

### T014 — `adoption/updating.md`

A flow-down note shaped like feature 025's (what was wrong, what it does now, what flows down, what an owner may newly see, what does not change, known limits,
what was measured, what to do) and two digest markers. It states the narrowing of feature 014's D7, the git 2.38 requirement and the strict fallback, the object
database side effect of `git merge-tree --write-tree`, that a hand-merge of two approved parents needs a fresh record, that a removal inside a merge is graded
(phase 2 review F1), the F2 limit (a parent's version taken whole is trusted), the per-merge cost, and that the record remains a written claim. It names only
paths that resolve in an adopted project (`doc-lint` OK).

### T015 — `docs/roadmap.md`

The GAP-032 inventory row gains a "Closed by feature 026" sentence with what stays open; its roadmap row is `shipped`, owner `anas.m`, spec
`specs/026-merge-commit-amendment-grading/`; a decisions-log entry dated 2026-10-14 records the owner's decisions (shape A and the hand-merged-conflict
sub-decision, D2, D3, D4, three phases), what the work corrected, the measurement and what stays open. "Shipped" means built, reviewed and measured, the same
reading as feature 025's entry.

### T016 — measurement on real history (plan D10, FR-009, SC-001)

Method: clones of FitForge, FlowBoard and ExpenseTracker made from their local directories (`git clone --local --no-hardlinks`, `core.autocrlf=false`; the real
projects untouched, nothing pushed), and of this repository. For **every merge commit reachable from any ref**, in the shape CI grades a pull request: range
`<merge>^1..<merge>`, the branch being each `specs/NNN-*` feature the second parent's side touched (relative to the merge base), the boundary lifted with
`-IgnoreAmendmentBoundary` (analysis only), the parent kit's `enforcement-pack.ps1` (`2977ca5`) against this one (`fa23d5b`), each version run from a scratch
directory with `-Root` the clone, so each reads the clone as its project and not the kit. The driver and its summary are kept outside the repository. A merge that
touches no feature directory (kit updates, claims, docs) has no branch to grade and is counted as such.

| History | Merge commits | Merged a side touching no feature | Feature runs | Merge commits inside those ranges | Merges newly graded | New failures | Outputs that differ | Slowest new run (old) |
|---|---|---|---|---|---|---|---|---|
| FitForge | 10 | 9 | 1 | 3 | 0 | 0 | 0 | 5.3 s (6.0 s), 26 commits |
| FlowBoard | 10 | 6 | 4 | 4 | 0 | 0 | 0 | 3.7 s (4.5 s), 18 commits |
| ExpenseTracker | 10 | 7 | 3 | 3 | 0 | 0 | 0 | 2.8 s (2.7 s), 8 commits |
| this kit | 103 | 65 | 38 | 62 | 0 | 0 | 0 | 5.3 s (5.0 s), 49 commits |
| **Total** | **133** | **87** | **46** | **72** | **0** | **0** | **0** | |

**What it shows:** on 133 real merges, no run's `AmendmentAuthority` output differs between the two versions, no merge that was skipped is now graded and no
failure is new, so SC-001 (no real history newly fails) holds and the per-merge cost is small (the slowest run is 0.3 s slower, within noise). **What it does not
show,** said plainly: none of these merges authored a spec document (every one was counted under `merge commit(s)` before and after), because history before
this feature carries no merge approver record. So "none newly failed" is true because those merges authored nothing, as the earlier combined-diff count over 131
merges also found; it is not evidence that an owner will find a newly failing merge easy to satisfy, nor of how often a hand-merged conflict will occur. No
octopus merge exists in these histories. The first launch of the driver aborted on a parse error in its own last line (a `$name:` read as a drive path) and was
rerun in full; nothing from it is reported.

### T013 — feature 025's `plan.md` (not done)

Waits for the owner's approval of the wording before it is committed, and carries `**Amendment approved by**` only when the owner gives it (constitution I: the
agent never approves its own amendment). The wording is put to the owner in the session.

### T017 — final run on an isolated checkout

Not yet run: it needs the final commit, which needs T013.

### T013 — the plan amendments (done, on the owner's approval)

Owner approval, in the owner's words: "yes, approve both and apply them" (anas.m, 2026-10-14), given after the wording was put to the owner in the session.

- **Feature 025's `plan.md`:** the Summary sentence ("not graded") now says a merge is graded since feature 026 when it authored the change; a "Retired by feature 026"
  paragraph follows the D5 limit paragraph (the original text stays as history) with what remains; the Risks bullet is replaced. One record, `**Amendment approved
  by**: anas.m, 2026-10-14`, closes the new D5 paragraph and covers the Summary and Risks changes it names.
- **Feature 026's own `plan.md`, D11:** the script header `LIMIT` comment is stated as updated in phase 2 (task T008, with the code), the other four in phase 3,
  closing the drift the phase 2 review found (F6). Its own record follows the amended decision.

Both commits name the approver. The amendment check grades them like any amendment (`ritual-checks.ps1` RESULT OK).

### T017 and gate certification, phase 3 (user-run)

On an isolated detached worktree of `c64348c` (the phase 3 commit with the plan amendments): `ritual-checks.ps1 -Branch 026-merge-commit-amendment-grading`
RESULT OK, and `scope-check` PASS on every phase commit (phase 1: `15a0e6f`, `61bd6ed`, `8d3badf`, `a7868d2`, `78bf472`, `2977ca5`; phase 2: `bb08af7`, `9d899c9`,
`22ac126`, `e661139`, `fa23d5b`; phase 3: `3fd1b2e`, `c64348c`). The full-harness count of that tree is recorded below when its run finishes.

Gate certified (user-run): `pwsh -File scripts/ritual-checks.ps1` on `c64348c`, exit code **0**, confirmed by the owner (anas.m, 2026-10-14).

### Full harness, final tree (T017)

Isolated detached worktree of `c64348c` (removed afterwards): **1585 passed, 0 failed, 0 skipped**. Over the phase 2 commit `bb08af7` (1575) the difference is 10, the five
cases added by the phase 2 review remediation (`fail-merge-deletes-contract-main-into-branch`, `fail-merge-renames-and-rewrites-contract`,
`fail-merge-record-with-inline-comment`, `AMEND-008/fail`, `AMEND-008/pass`), two tests each. Over the parent of the feature (`fad21b7`, 1520) the total is 65 more tests:
the phase 1 self-tests and the 24 merge cases of phase 2.
