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
