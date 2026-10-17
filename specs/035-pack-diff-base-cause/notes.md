# Notes: the enforcement pack names the cause when its diff base cannot be read

Evidence for feature 035 (GAP-041). Nothing here is law; `spec.md`, `plan.md` and `tasks.md` are.

## Pre-spec measurement (2026-10-17, git 2.55.0.windows.5)

Method: the kit's own fixture `enforcement-pack/STRUCT-001/pass` materialised with `tests/enforcement/Run-Tests.ps1 -Case enforcement-pack/STRUCT-001/pass -KeepRepo` (a numbered branch `001-thing` on a trunk `main`), the pack run
against it with `-Root <fixture> -Branch <b>`, and a tip commit truncated to half its bytes (a copy kept, restored afterwards). A `docs/x` branch and a `002-orphan` branch were added to the kept fixture for the Lite lane and the
no-shared-history state. Nothing in the project was touched.

| # | Probe | Result |
|---|---|---|
| M1 | `-Branch 001-thing`, intact | `diff base '17952ff...', 3 changed file(s)`, `AmendmentAuthority: graded 0 of 1 commit(s) ...`, `enforcement-pack: OK`, exit 0 |
| M2 | the same, the tip commit **truncated** | `diff base ''`, `WARNING: enforcement-pack: no integration branch to diff against, so nothing on '001-thing' was compared ...`; `UNGRADED: ReviewProvenance: no diff base ... Fetch the full history ('fetch-depth: 0' on actions/checkout)`; `UNGRADED: PhaseSizeWarning: no diff base ...`; `enforcement-pack: FAIL (1 issue(s)): AmendmentAuthority: cannot grade '001-thing' — no integration branch to diff against. Either neither 'origin/main' nor 'main' resolves here, or one of them resolves but shares no commit with HEAD (a truncated clone, or unrelated histories) — this check does not distinguish them ...`, **exit 1** |
| M3 | `-Branch docs/x` (Lite lane), intact | `diff base '...', 1 changed file(s)`, `the lightweight docs/ lane`, `enforcement-pack: OK`, exit 0 |
| M4 | the same, the tip commit **truncated** | `diff base ''`, the same `WARNING`, `UNGRADED: ReviewProvenance ... Fetch the full history ('fetch-depth: 0' ...)`, `enforcement-pack: UNGRADED (1 check(s) formed no opinion)`, **exit 0** |
| M5 | `-Branch 002-orphan` (numbered, no shared history with `main`: legitimate), plus no spec directory | the same `WARNING` and `UNGRADED` lines, the four failures of a branch with no spec (three `Structure`, one `AmendmentAuthority: cannot grade ... no integration branch to diff against`), exit 1 |

So the numbered lane is already red for a damaged branch (the opposite of the scope check before feature 034), and the Lite lane is `UNGRADED` at exit 0 by standing decision (feature 014 FR-009, feature 015 D6). What a damaged branch gets is the
**wrong cause**: M2 and M4 are indistinguishable from M5 by their text, and the shallow-clone advice (`fetch-depth: 0`) is no remedy for a damaged object store. `AmendmentAuthority`'s own message says it does not distinguish the states.

Where it comes from: `scripts/enforcement-pack.ps1:186-200` (`Get-DiffBase`: `git merge-base HEAD $c 2>$null`, return the base only on exit 0), the dispatch warning at `:2401`, the `AmendmentAuthority` failure at `:2143`, and the `UNGRADED` lines
that say "no diff base" at `:908` (MicroLane), `:1316` (ReviewProvenance, the one that advises `fetch-depth: 0`), `:1375` (PhaseSizeWarning) and `:2426` (LiteAndAbuse).

Not measured here, and the plan must: the same probes on the CI image's git (feature 034's CI showed the `exit 128` of a truncated tip holds on Linux); whether the pack's other uses of the base (the `git diff` reads of feature 028) are affected;
and how the pack's own shallow-clone detection (`git rev-parse --is-shallow-repository`) interacts (the shallow state is answered separately and must keep its text).

## Phase 1 evidence (2026-10-17, working tree, before the phase commit)

**Fixtures shown failing on the parent commit (T003).** The new `BASE-001` to `BASE-003` case directories were copied into a detached worktree of `37ea2c4` (outside the repository, removed afterwards) and run with
`-Case enforcement-pack/BASE-`: 8 cases selected. `BASE-001/fail`, `BASE-002/fail` and `BASE-003/fail` pass the exit-code check and **fail the output check** (the parent prints the old text); `BASE-001/pass`, `BASE-001/pass-orphan`,
`BASE-002/pass`, `BASE-002/pass-orphan` and `BASE-003/pass` pass. The failing output was not printed by the harness; the reason is inferred from the exit code matching (the verdicts are unchanged by design) and the output differing.

**Changed pre-existing expectation.** `enforcement-pack/GAP27-003/fail/expected.txt` truncates a commit, so on this branch it prints the new cause (`git merge-base failed with exit 128`) in the three messages. Verdict and exit code are
unchanged. This departs from tasks.md's "every pre-existing case unchanged" and awaits the owner's acceptance.

**Harness on the working tree (T006, partial).** `Run-Tests.ps1 -Case enforcement-pack/`: 819 passed, 0 failed, 0 skipped (the filter narrows fixture cases only; the other test files ran too), including the coverage sweep.
Not the full 1859-test baseline run on an isolated checkout of the final commit (T001, T010).

**`ritual-checks.ps1 -Branch 035-pack-diff-base-cause`:** doc-lint OK, enforcement-pack OK, digests OK, roadmap-claims OK, scope-repos n/a, verify-kit n/a; scope-check UNGRADED because no commit carries a `phase N` token yet.

**Not yet done:** T001 baseline counts and the saved no-base outputs, T002 probes (a to c), the byte-identical comparison of the legitimate no-base states, the CI confirmation on the CI image's git.

## T001, T002 and the byte comparison (2026-10-17, git 2.55.0.windows.5, pwsh 7.6.7)

**T001 baseline, parent commit `37ea2c4`, isolated detached worktree (removed afterwards):** full harness `1859 passed, 0 failed, 0 skipped` (matches the figure feature 034 left). Coverage: `270 of 287 declared emission site(s) owned
by a fixtured rule, 8 exempt, 9 declared not a rule, across 10 grading script(s)`; `enforcement-pack.ps1: 79 of 86 site(s) fixtured (3 exempt, 4 not a rule)`. **The plan's "exempt count stays 7" does not match this baseline (8 in
total, 3 in the pack); the figure to hold is the measured one.** The new run must show the same exempt counts.

**T002 probes (a, b, c), a scratch repository, git 2.55.0.windows.5:**

| Probe | Result |
|---|---|
| `rev-parse --verify --quiet origin/main`, ref absent | exit 1 |
| `merge-base HEAD main`, readable | exit 0, one line |
| `merge-base HEAD main`, orphan branch (no shared history) | exit 1, no output |
| `merge-base HEAD <no such ref>` | exit 128 |
| `merge-base HEAD main`, tip commit loose object truncated (read-only attribute cleared first) | exit 128, no output |
| `rev-parse --is-shallow-repository` on the truncated repository | `false` |

(b) The exit code read on the statement after a split `git merge-base` is git's own (0, 1, 128 as above). The comparison with the old pipeline read did not discriminate: `$LASTEXITCODE` was 128 after
`| Where-Object` too, so this probe does not show the old form was wrong, only that the split form is correct. (c) The `BASE-*` fixtures with `truncateCommit` `HEAD` take the no-base path on both lanes
(the harness run), and shallow detection stays `false`. The CI image's git (Linux) is not yet probed: the branch's CI run is the second probe (plan Risks).

**Byte comparison (FR-004, T006):** the parent commit's script and the working tree's script run through `Invoke-FixtureCase` against the same fixtures, every `enforcement-pack` case whose expectation names a no-base state (15 cases). 
11 print identical bytes and the same exit code: `AMEND-001/pass-lite-docs-readme-only-shallow`, `AMEND-003/fail`, `AMEND-004/fail`, `BASE-001/pass-orphan`, `BASE-002/pass-orphan`, `CRIT-R02/fail-shallow-clone`,
`CRIT-R03/pass-shallow-clone-declaration-needs-no-history`, `GAP27-001/fail`, `GAP27-002/fail`, `GAP27-004/fail`, `PACK-001/fail`. 4 differ in text, with the same exit code: `BASE-001/fail`, `BASE-002/fail`,
`BASE-003/fail` (the new states) and `GAP27-003/fail` (a truncated commit; see above). Every legitimate no-base state is byte-identical. The comparison script is a scratch file, not part of the kit.

**Still open:** the full harness and `ritual-checks.ps1` on an isolated checkout of the final commit (T010), the coverage line of the new tree (T004/T006 want the exempt counts stated), the CI run on the CI image's git, and the owner's decision on `GAP27-003/fail`.

**Owner decision (2026-10-17, anas.m):** the `GAP27-003/fail/expected.txt` change is accepted (a truncated-commit fixture now prints the new cause; verdict and exit code unchanged).

## Phase 1 final run (2026-10-17, isolated detached checkout of phase commit `0b88180`, removed afterwards)

- Full harness: `1875 passed, 0 failed, 0 skipped` (baseline 1859 plus the 16 assertions of the 8 new `BASE-*` cases).
- Coverage: `273 of 290 declared emission site(s) owned by a fixtured rule, 8 exempt, 9 declared not a rule`; `enforcement-pack.ps1: 82 of 89 site(s) fixtured (3 exempt, 4 not a rule)`. Exempt counts equal the baseline (8 total, 3 in the pack); the three new sites are owned by `BASE-001` to `BASE-003`, no unowned site.
- `ritual-checks.ps1 -Branch 035-pack-diff-base-cause`: doc-lint OK, enforcement-pack OK, scope-check OK, digests OK, roadmap-claims OK, scope-repos n/a, verify-kit n/a; RESULT OK.
- `scope-check.ps1` on `0b88180`: PASS (28 files).

Still open: fresh-context AI review with Reviewer Provenance, the CI run on the CI image's git, and the owner's gate run.

## Review follow-ups (2026-10-17, phase 1 AI review `ai-code-review-phase1.md`)

- **F1 (doc drift):** the implemented wording of the dispatch warning and the `AmendmentAuthority` failure joins the clauses with a full stop (`... . The object store may be damaged: run git fsck, or re-clone`), where `plan.md` P2 and P3 sketch a dash. The fixtures pin the implemented wording. `plan.md` is not rewritten by the phase that implements it; the owner may amend P2 and P3 (recording the approver) if the sketch should match.
- **F2 (doc drift):** the dispatch-warning rule in `rules.json` kept its meaning but its anchor moved (the old text occurs in both branches of the warning now); its `notes` now name `BASE-001` as the owner of the unreadable-base wording.
- **F3:** exit 128 on the CI image's git is the one remaining probe; the branch's CI run is it (needs a push by the owner).

## CI on the pushed branch (2026-10-17, run 39022452441 on `f543cf4`)

`enforcement-tests`: ubuntu-latest success, windows-latest success; `ritual-checks` success. The `BASE-*` fixtures (the exit-128 state through `truncateCommit HEAD`) therefore pass on the CI image's git on Linux as well as on Windows: the second probe of the plan's Risks holds. Then `main` (PR 109, the roadmap claim for 035) was merged into the branch (`046d769`); the merge touches only `docs/roadmap.md`.

## Phase 2: guidance, close and measurement

### T009 The measurement (plan P6, SC-001, SC-002), 2026-10-17

Method (features 030 to 034): the pack of the kit before this feature (`37ea2c4`, a detached worktree, removed afterwards) and as it stands (`1844dc0`), each run with `-Root <clone> -Branch <probe>` against **the same fresh clones** (`--no-hardlinks`, in the
scratchpad) of FitForge, FlowBoard and ExpenseTracker (the real projects never touched, no network, nothing pushed). Six probe branches per clone, made in the clone: a numbered branch `099-probe` (a spec commit), a Lite branch `docs/probe`
(one docs file), two orphans (`098-orphan`, `docs/orphan`, no history in common with `main`) and two branches with a fresh tip commit whose loose object was truncated to half its bytes when probed (`097-damaged`, `docs/damaged`). Lesson of
feature 034 held: no clone is shared between a damaged and an intact probe, and a damaged tip is truncated only when probed (git cannot switch away from a damaged HEAD; the first run of the script failed on that and was discarded, nothing was measured by it).
The branch name is passed as one argument (`ProcessStartInfo.ArgumentList`), so no argument array is splatted.

| Probe | FitForge | FlowBoard | ExpenseTracker |
|---|---|---|---|
| `099-probe` (numbered, intact) | identical, exit 1/1 | identical, exit 1/1 | identical, exit 1/1 |
| `docs/probe` (Lite, intact) | identical, exit 0/0 | identical, exit 0/0 | identical, exit 0/0 |
| `098-orphan` (numbered, no shared history) | identical, exit 1/1 | identical, exit 1/1 | identical, exit 1/1 |
| `docs/orphan` (Lite, no shared history) | identical, exit 0/0 | identical, exit 0/0 | identical, exit 0/0 |
| `097-damaged` (numbered, tip truncated) | differs, exit 1/1 | differs, exit 1/1 | differs, exit 1/1 |
| `docs/damaged` (Lite, tip truncated) | differs, exit 0/0 | differs, exit 0/0 | differs, exit 0/0 |

(The numbered probes exit 1 before and after because a bare probe spec is not a complete feature; what the measurement compares is the bytes and the code, which are equal.) **Every line that moves, and its cause**, identical in the three projects:
on the damaged numbered branch, three lines: the dispatch `WARNING` (`no integration branch to diff against ... Fetch the full history` becomes `the diff base could not be read (git merge-base failed with exit 128) ... run git fsck, or re-clone`),
the `UNGRADED: ReviewProvenance` line (`no diff base ... Fetch the full history ('fetch-depth: 0' ...)` becomes `the diff base could not be read (...) ... run git fsck, or re-clone`) and the `AmendmentAuthority` failure (`cannot grade ... no integration branch to
diff against. Either neither ...` becomes `cannot grade ... the diff base could not be read (...), so what the branch changed is unknown ...`); on the damaged Lite branch, the first two of these (the numbered-lane failure does not apply). Cause: `git merge-base`
exits 128 on a truncated tip, which `Get-DiffBase` now classifies as a failure to read. No other line moved.
The real projects were checked afterwards: `git status --porcelain` and `git branch -a` of each equal to the lines taken before (no probe branch, same working-tree state). Not exercised, and said so: the commit-graph shape (the pack's base read is
`git merge-base` alone, so it is not a separate state here).

### T007, T008 The documents

`adoption/updating.md` gains the flow-down note of feature 035 (no digest marker, so no digest changes; `build-digests.ps1 -Check`: 5 digests fresh, 119 markers). `docs/roadmap.md`: the GAP-041 status text, the row set to `shipped`, a decisions-log entry
(D1 A, D2 A, D3 A; the exempt-count correction; what was measured; what is still open).

### Gate records (reported to the agent by the owner in conversation, not machine-verified)

- Phase 1 gate: exit 0, reported by anas.m on 2026-10-17 (after the phase 1 commits, the review and CI on `1844dc0` were green).
- Phase 2 gate: not yet reported.

### Phase 2 review follow-ups (2026-10-17, `ai-code-review-phase2.md`)

- **F1:** the flow-down note now says the cause may read `git rev-parse of <ref> failed with exit <n>` when `rev-parse` itself failed.
- **F2:** "No verdict moves" is qualified in the note: in the states measured and by construction.
- **F3:** the phase 1 gate result is recorded above, as reported by the owner.
- **F4, F5:** noted, no change (the `shipped` row follows the 033/034 precedent and the log lists what is open; the measured script `1844dc0` is the tip's script, Phase 2 changing none; the Linux confirmation is CI's).

### T010 Final run (2026-10-17, isolated detached checkout of phase 2 commit `236e184`, removed afterwards)

- Full harness: `1875 passed, 0 failed, 0 skipped`; coverage `273 of 290 declared emission site(s) owned by a fixtured rule, 8 exempt, 9 declared not a rule`; `enforcement-pack.ps1: 82 of 89 site(s) fixtured (3 exempt, 4 not a rule)` (equal to the phase 1 run: phase 2 changes no script, fixture or harness file).
- `ritual-checks.ps1 -Branch 035-pack-diff-base-cause`: doc-lint OK, enforcement-pack OK, scope-check OK, digests OK, roadmap-claims OK, scope-repos n/a, verify-kit n/a; RESULT OK. (`scope-check.ps1` run bare in a detached checkout prints `UNGRADED detached HEAD`, as designed; the commits were graded in the repository itself, below.)
- `scope-check.ps1 -Commit` in the repository: `PASS phase 1 commit 0b88180 (28 file(s))` and `PASS phase 2 commit 236e184 (3 file(s))`.
- The follow-up commit after the review (the two note fixes, `notes.md`, `ai-code-review-phase2.md`) touches documents only; `ritual-checks.ps1` is re-run on it.
- Still open: the owner's phase 2 gate, and the human review at merge.
