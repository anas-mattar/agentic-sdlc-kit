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
