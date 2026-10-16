# Notes: claim-feature.ps1's ledger read and refused push are named states

Phase evidence for feature 030. Nothing here is law; `spec.md`, `plan.md` and `tasks.md` are.

## Phase 1: the ledger read and the rejected push

### T001 Baseline on the parent commit (`1d5914c`, the merge of PR #91)

Measured by running `pwsh -File scripts/claim-feature.ps1 -ShortName probe "a probe"` in a purpose-built repository (an
`origin` that is a second repository on disk, the stock-script stub the fixtures use) with a counting wrapper on
`remote.origin.uploadpack` (T002 a), and through the harness.

| State | Under `pwsh -File` | Through the harness launcher |
|---|---|---|
| first ledger read fails (`Get-RemoteFeatureHeads` throw, line 47) | a PowerShell exception record (`Exception: ...claim-feature.ps1:47 ... git ls-remote failed - cannot read the remote ledger.`), exit 1 | `RunChild: the script under test threw before returning a verdict`, **exit 128** (the last git call's code leaked) |
| read fails after a push that succeeded | the same exception record after `Allocating feature number 001`, exit 1, **and `001-probe` is on `origin`** | the same, exit 128 |
| push rejected, no rival (the old `CLF-007` fail) | three `WARNING: Number NNN was claimed concurrently ()` lines with an empty list, two `Renumbered:` lines, `Lost the allocation race 3 times`, exit 1 | the same text, exit 1 |
| successful claim, no origin / origin takes the push / `-NoPush` | the three outputs of the success fixtures (`CLF-004` pass cases, `CLF-012` pass, `CLF-007` pass) | exit 0 |

The spec left the throw's exit code unmeasured on purpose. It is **1 at a terminal and 128 through the harness's launcher**,
and, worse than the exit code, in the second row a claim is live on `origin` while the script reports an error.

Harness on the parent (isolated worktree, `git worktree add --detach` outside the repository): see "Numbers" below.
`-Case CLF-` before the change: 94 passed, 0 failed. The coverage report before the change: `claim-feature.ps1` 7 of 10 sites
fixtured (3 not a rule), exempt rules unchanged at the count the full run reports.

### T002 Probes of the harness fields (plan P5)

- **(a) `remote.origin.uploadpack` counting wrapper: works.** Every `git fetch origin` and `git ls-remote origin` runs the
  remote's upload-pack, so a wrapper that counts calls and exits non-zero on the Nth fails exactly that read. The call order a
  claim makes is fixed (first fetch 1, first read 2, read after the first push 3, then re-fetch and re-read on a lost race).
  Run as `sh '<path>'` so it needs no execute bit. Tried on Windows (Git for Windows' `sh`); the Linux runner is exercised by
  CI on the PR, not here. The `PATH` shim fallback was not needed. Implemented as the `originFailCall` recipe field, with its
  wrapper and counter under `.git/` so the working tree stays clean (a claim refuses a dirty one).
- **(b) A stub that creates a rival: works, no field needed.** The stub is test code the recipe places; it runs
  `git -C origin.git branch NNN-rival main` between allocation and the push.
- **(c) A rival at every attempt: not by a `pre-push` hook, but by a `receive-pack` wrapper.** A wrapper on
  `remote.origin.receivepack` runs the real `git-receive-pack` and then creates `<NNN>-rival` for every numbered branch just
  pushed; a claim then meets a rival after each of its three attempts and ends on `Lost the allocation race 3 times` with
  each of its own branches withdrawn. This is the third recipe field, `originRivalOnPush` (plan P5 said "one to three"), and it
  is why **`CLF-007` keeps its fixture and nothing becomes exempt** (plan P6 allowed it to).

### The work

- `scripts/claim-feature.ps1`: `Get-RemoteFeatureHeads` no longer throws; it sets `$script:LedgerReadFailed` (an empty
  ledger and a failed read cannot be told apart by the return value, because PowerShell unrolls an empty array to `$null`);
  each of its three callers checks it. The push's output is captured. The race loop follows plan P3: a rejection with no
  rival is refused once. Lines for the withdrawal (`git push origin --delete`) and the re-fetch are untouched (phase 2).
- Harness: fields `originFailCall` and `originRivalOnPush` in `tests/enforcement/lib/FixtureRepo.psm1` with self-tests in
  `tests/enforcement/Harness.Tests.ps1` (including the refusal without `origin`, the refusal of a bad call number, and that a
  push is not counted).
- Fixtures: `CLF-008` to `CLF-012` (a pair each, plus `CLF-011/fail-unpushed`), and `CLF-007` rebuilt through `originRivalOnPush`.
  Rules inventoried in `tests/enforcement/rules.json`.

### Corrections and deviations from the plan, found while writing the fixtures

1. **The rejected-push message is laid out on several lines.** Plan P2's row reads `git push of <branch> was rejected: <git's text>.
   Nothing was claimed; ...`. Git's text is five lines (a `fatal:` line, a second one, a blank line and two more), so inline it
   reads badly; the first line is `git push of <branch> was rejected:` and git's text follows on its own lines, then the closing
   sentence. The wording of every sentence is the plan's; only the placement of git's text is a layout choice.
2. **The rejected-push message gained the plan's Risks sentence.** `If the push may have landed, check origin (git ls-remote
   --heads origin <branch>) before claiming again.` is the Risks section's "the message therefore says to check origin".
3. **A fourth state of the re-read refusal.** Plan P2's row 4 says `<branch> was withdrawn from origin`. That is true only when our
   push landed. When our own push was rejected and a rival is also on `origin`, nothing of ours reached `origin`, so the message
   reads `<branch> never reached origin` instead, and the state has its own fixture (`CLF-011/fail-unpushed`). Plan P2 has
   one row for the state; this is a second wording of it, recorded here and not amended into the plan.
4. **`CLF-007` was re-expected, as the plan said it would be (P6).** The old fail (a push that fails) now reads as the rejected push
   and moved to `CLF-012` (`fail` and `pass`); `CLF-007`'s fail was rebuilt as a real rival after every push.
5. **`Stop-Refused "$rejection"`, with the quotes.** The coverage sweep's idiom is `Stop-Refused\s+['"]`, so a bare variable is not
   seen as an emission site; the quoted form is the same call and is seen. Nothing in `emission-idioms.json` changed.
6. **Line endings.** The working-tree copy of `scripts/claim-feature.ps1` was CRLF while the index is LF; it was normalised to LF
   before the change so the diff is the 37 lines changed and not the whole file.

### Results on the changed script

Hand-written expectations, run first on the parent and then on the change:

| Rule | On the parent | On the change |
|---|---|---|
| `CLF-008` fail | exit 128, `RunChild ... threw before returning a verdict` | refusal, exit 1 |
| `CLF-009` fail | exit 128 after `Allocating ...` | refusal naming the branch, exit 1, the claim left on `origin` |
| `CLF-010` fail, pass | fail: exit 128; pass: three lost-race warnings and the three-times refusal | fail: rejected push plus `The ledger could not be read either.`; pass: the rejected push alone |
| `CLF-011` fail, fail-unpushed | exit 128 | refusal naming what is and is not on `origin`, exit 1 |
| `CLF-012` fail | the three-times refusal (output differs, exit 1 both) | the rejected push, once, no warning |
| every pass, `CLF-007` | pass | pass (unchanged behaviour) |

`-Case claim-feature` on the change: 124 passed, 0 failed. Coverage: `claim-feature.ps1` 12 of 15 sites fixtured (3 not a
rule), no unowned site, no new exemption.

Under `pwsh -File` on the changed script (the T001 states): first read fails, `git ls-remote failed - cannot read the remote
ledger. Nothing was claimed.`, exit 1, nothing on `origin`; read fails after the push, `git ls-remote failed after pushing
001-probe ...`, exit 1, `001-probe` on `origin` and said so; the successful claim and the `-NoPush` claim print the same bytes
as before; `-Json` keeps the refusal on the error stream with no object.

### Numbers (T007)

| Measure | Parent `1d5914c` | Phase 1 commit `772a93d` |
|---|---|---|
| full harness, isolated detached worktree | 1744 passed, 0 failed | 1774 passed, 0 failed |
| `claim-feature.ps1` sites fixtured (coverage report) | 7 of 10 (3 not a rule) | 12 of 15 (3 not a rule) |
| rules exempt from a fixture pair | 6 | 6 (unchanged; `CLF-007` kept its fixture) |
| `-Case claim-feature` | 94 passed with `-Case CLF-` (the self-tests run too) | 124 passed |

`scope-check.ps1` on `772a93d`: PASS (42 files). `ritual-checks.ps1 -Branch 030-claim-ledger-read-named-state` in the isolated detached checkout: `doc-lint` OK, `digests` OK,
`roadmap-claims` OK, **`enforcement-pack` and `scope-check` UNGRADED**, result UNGRADED, nothing failed: a detached checkout of a commit already merged to `main` has no commits since the merge base, so those two
members have nothing to grade there. That is not a pass; their real grading is CI on the pull request (the phase 1 reviewer saw the ubuntu `enforcement-tests` job pass and the windows jobs pending on #92).

## Phase 2: the withdrawal, the re-fetch, guidance and measurement

### T008 Probe of `originDenyDeletes` (plan P5)

`receive.denyDeletes` set on the repository origin points at makes `git push origin --delete <branch>` fail with `remote rejected (deletion prohibited)` while an ordinary push of a new branch still lands. Implemented as the
`originDenyDeletes` recipe field (set after the nested repositories exist, because origin is usually one of them; refused without `origin`, and when the repository it points at does not exist), with self-tests.

### What was written and shown failing first

Fixtures `CLF-013` (a withdrawal that fails against one that works), `CLF-014` (a re-fetch that fails, call 4, against one that does not) and `CLF-014/fail-unpushed`. Run on the **phase 1 tip** before the script change: `CLF-013/fail` and
`CLF-014/fail` fail on exit code (expected 1, observed 0) and output (the claim renumbers to `002-probe`, past a stale branch or an unrefreshed ledger); `CLF-014/fail-unpushed` fails on output; the pass twins pass. After the change: `-Case claim-feature` 138 passed, 0 failed.

Two existing anchors were narrowed so the coverage sweep tells the new refusal lines apart from the old ones, which share their words: `CLF-004` (`git fetch origin failed` to `unreachable ledger.'`, the first fetch's closing quote) and `CLF-007`
(`Lost the allocation race` to `Lost the allocation race $MaxAttempts times`, because `CLF-013`'s message begins `Lost the allocation race but could not withdraw`). Neither rule's fixtures changed.

### T011 and T015: numbers on an isolated checkout of the final code commit

| Measure | Phase 2 final `0e1d252` |
|---|---|
| full harness, isolated detached worktree | **1788 passed, 0 failed** |
| `claim-feature.ps1` sites fixtured | 14 of 17 (3 not a rule), no unowned site |
| rules exempt from a fixture pair | 6 (unchanged) |
| `-Case claim-feature` | 138 passed, 0 failed |
| `scope-check.ps1` | PASS on `772a93d`, `53af25d` and `0e1d252` (42, 20 and 4 files) |
| `doc-lint.ps1`, `build-digests.ps1` | OK (5 digests, 119 markers) |
| `ritual-checks.ps1 -Branch 030-claim-ledger-read-named-state`, run on the branch after `main` had been merged in | `doc-lint`, `digests`, `roadmap-claims` OK; `enforcement-pack` and `scope-check` UNGRADED (no commits since the merge base), nothing failed |

As for phase 1, the two UNGRADED members are graded by CI on the pull request, not here.

### T014 The measurement (plan P8, SC-001)

Method: for each project a `git clone` from its local directory into a scratch area (the real projects never touched) and a **bare copy** of the project as that clone's `origin`, so a claim with a push could be run (feature 023's measurement could not
push). The kit before this feature (`1d5914c`) applied with `update-kit.ps1`, `build-digests.ps1` run, committed ("measure: kit before"); the kit as it stands applied the same way ("measure: kit now"), with an assertion that the clone's
script has `Stop-Refused`. Probes in each state on a fresh `main` (the clone, its branches and the bare origin's branches reset between runs): a successful claim with `-NoPush` and one with a push; three refusals of feature 023 (an untracked
file, a checkout of another branch, an `origin` that cannot be fetched); three states this feature names (the first ledger read fails, the read after a push that succeeded fails, a push rejected), each through a counting wrapper on
`remote.origin.uploadpack` or a push URL that does not exist; `doc-lint.ps1`; `ritual-checks.ps1 -Branch main`. States: S0 installed, S1 kit before, S2 kit now.

| Probe | S0, S1, S2 (all three projects) |
|---|---|
| successful claim, `-NoPush`; successful claim with a push | exit 0 in every state; **S1 and S2 byte-identical** in FitForge, FlowBoard and ExpenseTracker |
| dirty working tree, not on `main`, fetch of origin fails | exit 1 in every state; **S1 and S2 byte-identical** |
| first ledger read fails | exit 1 in every state; S1: PowerShell error record around the message; S2: `git ls-remote failed — cannot read the remote ledger. Nothing was claimed.` |
| read after a push that succeeded fails | exit 1 in every state; S1: the error record, **and the claim live on the bare origin**; S2: `git ls-remote failed after pushing <branch> — the claim may already be live on origin. Check origin ...` |
| push rejected (push URL does not exist) | exit 1 in every state; S1: three concurrent-claim warnings with an empty list, two `Renumbered:` lines, `Lost the allocation race 3 times`; S2: `git push of <branch> was rejected:` and git's five lines, once |
| `doc-lint.ps1` | exit 0, byte-identical S1 to S2 |
| `ritual-checks.ps1 -Branch main` | `RESULT OK` in every state of every project; the only line that moved is `verify-kit`'s recorded kit commit |

The three new states are identical across the three projects apart from the allocated number (`002`, `010`, `004`). **Second pass**, run on the committed final documents (`0e1d252`): every probe output of S1 and S2 is the same as
in the first pass once the scratch directory's name is set aside, and the clones end on "measure: kit now" with the recorded kit commit `0e1d252`. The real projects were checked afterwards: no `probe` branch in any of them and
the same working-tree state as before (FitForge 1 modified path, FlowBoard 2, ExpenseTracker 0, all there before). Not exercised: the withdrawal and re-fetch refusals (they need a rival to appear between allocation and the
push; the fixtures prove them), anything run through a wrapper that starts the script as a child process, a push refused for permission by a real remote, and the Linux platform.

### Findings of the two fresh-context AI reviews and what became of them

Reviews: `ai-code-review-phase1.md` (APPROVE with follow-ups) and `ai-code-review-phase2.md` (APPROVE with follow-ups), fresh-context agents, neither wrote the diff.

| Finding | Disposition |
|---|---|
| phase 1 F1: a push that exits non-zero but landed is reported as `rejected ... Nothing was claimed` although the ledger just read lists the branch | **Open, the owner's decision.** A one-line ledger check would fix it but is a behaviour change outside the approved plan; the message carries the plan's `check origin` hedge, and the spec lists the case as out of scope |
| phase 1 F2: `was withdrawn from origin` printed while the withdrawal result was unchecked | Closed by phase 2 (T010) |
| phase 1 F3, F4: `CLF-010/pass` and `CLF-012/fail` print identical bytes; no fixture measures the withdrawals `CLF-007` and `CLF-011` describe (`CLF-007` also passes on the parent) | Accepted, minor. `CLF-013` now measures a withdrawal; `CLF-007` shows the site is reachable, not new behaviour, as its rule note says |
| phase 1 F5: the three wording deviations from plan P2 are recorded only here, with no approver | **Open, the owner's decision**: the plan needs an amendment with the owner's approver record |
| phase 1 F6: `sh '<path>'` breaks on a path with an apostrophe; mixed line endings in some recipe files | Accepted, minor; recorded as a limit |
| phase 2 F1 (blocking, docs): the note pointed at evidence not in the repository | Closed by this section |
| phase 2 F2: the note said 023's note is not edited, but one digest marker of it was removed | Closed: the note now says so and why |
| phase 2 F3: roadmap `shipped` with T011/T014/T015 open | Closed by this section; the roadmap says built and measured, with the reviews, the gate and the human review still to come |
| phase 2 F4, F5: the note omitted the withdrawal and re-fetch refusals and called the loop unchanged | Closed: both added to the note |
| phase 2 F6, F7: git's reason is not shown for a failed withdrawal or re-fetch; no fixture covers the last-attempt ordering | Accepted, minor; stated in the note (reason not shown) and here (ordering) |

## Phase 3: a push that reports failure but landed (amendment of 2026-10-16)

Raised by the phase 1 review's finding F1 and F5; instructed by the owner ("fix F1 and amend the plan", anas.m), who also approved amending the spec (asked, because FR-003 and the spec's out-of-scope edge case
contradicted the fix). The amendment (commit `ac731a0`: spec FR-003, User Story 2 scenarios 1/4/5, the edge case and the stated limits; plan P2 to P6, Risks and Phases, recording the three wording deviations of F5 and the
`receive-pack` wrapper that replaced the planned `pre-push` hook; a Phase 3 in `tasks.md`) carries `**Amendment approved by**: anas.m, 2026-10-16` where amended and in the commit message. One refinement was the
implementer's, inside that approval and disclosed in the plan: the warning shows only git's `error:`, `fatal:` and `remote:` lines, because git's progress lines reach the capture in an order nothing fixes.

### Probe and fixtures

Probe: `remote.origin.receivepack` pointed at a wrapper that runs the real `git-receive-pack` and then exits 1 makes `git push` exit 1 **with the branch on origin and upstream tracking set**. Implemented as the
`originPushFailsAfterLanding` recipe field (counts every push to origin including deletions; refused without `origin`, with a bad number, and together with `originRivalOnPush`, which sets the same option), with self-tests.
Fixtures `CLF-015` (landed, no rival: a claim made, a warning, exit 0) and `CLF-016` (landed beside a rival and a remote that refuses deletions: the withdrawal is attempted). Run on the script of `d33e908` before the change:
`CLF-015/fail` observed `git push of 001-probe was rejected` with exit 1 (the review's F1 reproduced) and `CLF-016/fail` renumbered past a stale branch with exit 0; the pass twins passed.

### The phase 3 review said REQUEST CHANGES, and was right

`ai-code-review-phase3.md` (fresh-context, on `a26da6e`): **F1 (high, blocking)**: `landed` was decided by the branch **name**. The plan's premise (our number was free, so the branch can only be there if our push put it there)
holds for the number and not the name: a second claimant with the same number and short name allocates the same branch name, so their branch on origin at another commit was read as our landed push (a false `CLAIMED:`, exit 0),
and the withdrawal could delete their branch. The reviewer reproduced it with a hand-built probe. Fixed in `95d4725`: the ledger read keeps each branch's sha (`$script:LedgerShas`, no extra git call) and a push that errored is
landed only if origin's branch of our name is at our own commit. `CLF-017` (a foreign branch of our name: the rejected push, exit 1; and `fail-rival`: the same beside a rival on a remote that refuses deletions, where reading the
foreign branch as ours would attempt the withdrawal and end on `could not withdraw`) was written first and **shown failing on the script of `a26da6e`** (4 failures: `fail` observed `treating the claim as made`, exit 0; `fail-rival`
observed `could not withdraw`, exit 1). One expectation was corrected by reasoning, not by copying the output: git reports the rejection as `(non-fast-forward)` and not `(fetch first)` because the claim's first fetch has already
brought origin's `main` commit into the clone. The premise is corrected in the spec, plan, tasks, roadmap, adopter note and script comment, with the owner's approver record (the owner approved this correction in the session).

### The fix review (`ai-code-review-phase3-fix.md`, APPROVE with follow-ups)

Verified by the reviewer: the truth table over push exit x same-name branch x same sha x rival x ledger readable; `$script:LedgerShas` reset and refilled on every call with its one reader right after the per-attempt read;
`$LASTEXITCODE` read at the right moment; `CLF-017` failing on the old script and passing on the new (151 passed, 4 failed; then 155 passed).

| Finding | Disposition |
|---|---|
| F1 (minor, reasoning only): `create-new-feature.ps1` makes no commit, so two claimants with the same number and short name from the same `main` tip hold branches at the same commit; the commit test cannot tell them apart | Stated as a limit in the plan (Risks) and the adopter note |
| F2 (doc drift, verified): four code fences of `plan.md` damaged by a backtick clean-up | Restored |
| F3 (minor): a script comment still names the old premise, then corrects it | No action |
| phase 3 F2, F4 (nits): the warning drops git's `! [rejected]` lines (disclosed in the plan); a self-test only checks one config key | Accepted |
| phase 3 F3 (nit): `T017` lost its `$gone` token to shell expansion | Fixed |

### Numbers

| Measure | Phase 3 final code commit `95d4725` |
|---|---|
| full harness, isolated detached worktree | **1805 passed, 0 failed** (1788 before phase 3; the earlier run at `bf59a3f` was discarded, the code having changed) |
| `claim-feature.ps1` sites fixtured | 15 of 18 (3 not a rule), no unowned site |
| rules exempt from a fixture pair | 6 (unchanged) |
| `-Case claim-feature` | 155 passed, 0 failed |
| `scope-check.ps1` | PASS on `a26da6e`, `95d4725` and `1f80b49` (20, 17 and 3 files) |
| `ritual-checks.ps1 -Branch 030-claim-ledger-read-named-state` on the branch (32 changed files beyond `main`) | `RESULT OK`: `doc-lint`, `enforcement-pack`, `scope-check`, `digests`, `roadmap-claims` all OK, `scope-repos` and `verify-kit` n/a |

Not measured: the phase 3 behaviour in the three adopted-project clones (the landed-then-failed state needs a remote whose `receive-pack` errors after accepting, which a clone's bare copy does not do; the fixtures prove it), and the
Linux platform (the CI run on the pull request is its evidence). The three-project measurement of phase 2 stands: phase 3 changes nothing in the states it measured (a push that exits 0, a read that fails, a push that fails with no branch on origin).