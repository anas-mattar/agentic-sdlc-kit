# Notes: claim-feature.ps1's refusals reach their own message and exit (023)

Phase evidence, measurements and decisions. Not an approved document: `tasks.md` holds the agreed work, this
holds what happened.

## Phase 1: the refusals and their proof

### T001: baseline on the parent commit

Taken on an isolated detached worktree of the parent commit (`3fa9b45`, the plan-approval commit), so no edit of the
working tree could reach it.

| Measurement | Value |
|---|---|
| Full harness | **1373 passed**, 0 failed, 0 skipped, `enforcement-tests: OK` |
| Coverage report | 9 grading scripts, 235 of 244 sites fixtured, **3 exempt** rules, 6 declared not a rule; `claim-feature.ps1` is not in it |

What a human sees from each refusal, and from each successful claim, run as `pwsh -File scripts/claim-feature.ps1
-ShortName probe "a probe"` from purpose-built directories (a git repository on `main` with a stub stock script; a bare
repository as `origin` where one is named):

| Case | Exit under `pwsh -File` | Output |
|---|---|---|
| line 72, not a git repository | **1** | a PowerShell error record (`Write-Error: <script path>:72`, a `Line |` excerpt with a caret rule), the message last |
| line 79, dirty working tree | **1** | the same record shape; the message and the dirty path on one line |
| line 84, not on main | **1** | the same |
| line 96, fetch of origin fails | **1** | the same |
| line 108, stock script missing | **1** | `WARNING` (no origin), `Allocating ...`, then the record |
| line 112, stock script fails | **1** | `WARNING`, `Allocating ...`, then the record with `create-new-feature.ps1 failed:` and the stub's line |
| a claim with no origin | 0 | `WARNING: No origin ...`, `Allocating ...`, `CLAIMED LOCALLY ...`, `SPEC_FILE`, `NEXT` |
| a claim with an origin that takes the push | 0 | `Allocating ...`, `CLAIMED: ... (pushed to origin ...)`, `SPEC_FILE`, `NEXT` |
| a claim with `-NoPush` | 0 | `Allocating ...`, `WARNING: Push skipped ...`, `CLAIMED LOCALLY ...`, `SPEC_FILE`, `NEXT` |

This measures the spec's premise on this script (the spec had it only from `territory-check.ps1`): at a terminal the
exit is already 1 for all six. The text of the three successful claims was saved and compared in T005.

### T002: the fixtures, shown failing on the parent

Fourteen cases under `tests/enforcement/cases/claim-feature/`, hand-written expectations, generated from one script so
that each pair differs only in the condition under test: a `fail` and a `pass` for each of `CLF-001` to `CLF-006`, plus
`CLF-003/fail-json` (the refusal under `-Json`, spec US1 scenario 7) and `CLF-004/pass-nopush`. Run through the real
harness on a second detached worktree of `3fa9b45` carrying the new cases and the new `Harness.psm1` normaliser but the
parent's `claim-feature.ps1`:

| Case | On the parent | Observed |
|---|---|---|
| `CLF-001/fail` | fails | exit **128**, not 1; the launcher's line `RunChild: the script under test threw before returning a verdict: Not inside a git repository.` |
| `CLF-002/fail` | fails | exit **97**, not 1; the launcher's line with the working-tree message |
| `CLF-003/fail` and `fail-json` | fail | exit **97**, not 1; the launcher's line with the main-branch message |
| `CLF-004/fail` | fails | exit **128**, not 1; the launcher's line with the fetch message |
| `CLF-005/fail` | fails | exit **97**, not 1; the launcher's line with the stock-script message |
| `CLF-006/fail` | fails | the exit-code check **passes** (the stub's own exit 1 leaks through, so 1 is observed by accident); the output check fails: the launcher's line, not the message |
| the seven `pass` cases and `pass-nopush` | pass | as designed |

Deviation from the plan's wording ("the launcher's line, exit 97 or 128"): for `CLF-006` the exit is 1 on the parent too,
by leakage from the stub's `exit 1`, so only its output check proves the defect. Same family as the `TERR-` finding in
feature 022 (the exit is whatever the last native command left behind).

### T003 and T004: the sweep and the script

- `rules.json`: `CLF-001` to `CLF-006`, and `CLF-007` (the lost race, site 135) exempt with the written reason of plan D2.
- `emission-idioms.json`: the script's entry, accumulators `Stop-Refused\s+['"]` and `Write-Warning\s`, three warnings
  declared not-a-rule with reasons (no origin and `-NoPush`, asserted verbatim by `CLF-001/pass` and `CLF-004/pass-nopush`;
  the per-attempt race warning, covered by `CLF-007`'s exemption).
- `Coverage.Tests.ps1`: `claim-feature.ps1` joins the list of grading scripts.
- `scripts/claim-feature.ps1`: `Stop-Refused` (error stream via `[Console]::Error.WriteLine`, then `exit 1`; plan D1, a copy)
  and the seven `Write-Error ...; exit 1` sites call it with the same message text, including the embedded dirty paths
  and the stock script's output. 17 insertions, 11 deletions; nothing else in the script changed.

**Deviations from the plan, each forced by running it.**

1. **The normaliser gained one substitution** (`tests/enforcement/lib/Harness.psm1`, with two self-tests in
   `Harness.Tests.ps1`): the rest of a path that follows `<ROOT>` is written with forward slashes. The script joins paths
   with `Join-Path`, so the `SPEC_FILE:` line and the `Stock script not found:` message print backslashes on Windows and
   slashes on Linux, and a hand-written expectation could only match one runner. No existing expectation had a
   backslash after `<ROOT>` (none found), so no pre-existing case moves. Not in the plan, which said no harness change.
2. **The pass cases that push use a nested repository as `origin`**, not `origin: self` (the plan's Risks named this
   as untested). With `origin: self` the stock stub checks out the new branch in the very repository that would receive
   the push, which git refuses; the nested repository (`origin.git`, ignored by a committed `.gitignore` so the working
   tree stays clean) takes the push. `CLF-004/fail` carries the same nested repository and `.gitignore` and differs only in
   where `origin` points. The risk is resolved by the passing cases, on Windows; the Linux CI leg is not exercised here.
3. **The stubs are written inline by the recipe's `write` field**, not placed by `copy` as the plan said: no existing case
   uses `copy`, `write` keeps the stub readable in the recipe, and the tree stays clean either way.
4. **Fourteen cases, not twelve**: `fail-json` and `pass-nopush` are variants the spec asked for (US1 scenario 7, the
   `-NoPush` warning's owner).

### T005: working tree after T002-T004

| Measurement | Value |
|---|---|
| `-Case CLF-` | 67 passed, 0 failed (14 cases, the coverage tests and the harness's own self-tests, which run under every filter) |
| Full harness | **1403 passed**, 0 failed, 0 skipped, `enforcement-tests: OK` (parent: 1373; 30 more: the 14 cases at two checks each, plus the 2 normaliser self-tests) |
| Coverage | 10 grading scripts, 241 of 254 sites fixtured; `claim-feature.ps1` **6 of 10** (1 exempt, 3 not a rule); exempt rules **4** (parent: 3, the one added is `CLF-007`) |
| `ritual-checks.ps1` | `doc-lint`, `enforcement-pack`, `digests`, `roadmap-claims` OK; `scope-check` `UNGRADED` (no phase commit on the branch yet, expected); `scope-repos` and `verify-kit` n/a; `RESULT UNGRADED`, nothing failed |
| The probe's three successful claims, new against the saved parent text | **byte-identical** (no origin; an origin that takes the push; `-NoPush`) |
| The probe's six refusals | the same message text and exit 1; what goes is PowerShell's error-record header (script path, line number, caret rule) around the message; the line-79 message now prints the dirty path on its own line (the record had flattened it onto the message's line) |

Every pre-existing case passes unchanged.

### Findings recorded, not fixed

- **An eighth terminating site, outside the spec's seven.** `scripts/claim-feature.ps1` line 47, in `Get-RemoteFeatureHeads`:
  `throw "git ls-remote failed — cannot read the remote ledger."`. It is the same species (a terminating write under
  `$ErrorActionPreference = 'Stop'`: the process exits through PowerShell's error path, not through the script's own exit),
  but a `throw`, so the spec's grep for `Write-Error` missed it and the coverage sweep does not report it (`throw` matches no
  candidate pattern of the recall sweep; confirmed by the phase 1 review). *Corrected after that review (F3):* it is not reachable
  only after the first fetch. `Get-RemoteFeatureHeads` has three callers: after the first fetch, after **every push** (the rival
  check), and after the in-loop re-fetch. After a push that succeeded the claim is already live on origin, so a wrapper sees a
  failure for a claim that was in fact taken, the misreading the spec's US1 priority note warns about. A fixture would need
  `git ls-remote` to fail after a successful fetch or push, which no recipe field builds. Left unchanged: FR-006 forbids other behaviour changes, and widening the spec mid-phase needs an approved amendment.
  Decision (the owner's go-ahead, 2026-10-12, "go with your recommendation"): record it, do not widen; it goes in the phase 2
  decisions-log entry as open. A later feature can convert it and add the field.

### Phase 1 AI review and its remediation

Review: `ai-code-review-phase-1.md` (fresh-context reviewer, REQUEST CHANGES; the script change itself was confirmed correct:
the seven messages byte-identical, the three successful claims identical, the remote branch withdrawn before the refusal on a
forced race, two mutations turning their cases red).

**F1 (blocking): the exemption of site 135 rested on a false premise, and the plan approval had accepted it.** The plan,
`rules.json` and `emission-idioms.json` said the site could only be reached by a rival claim appearing between allocation and the
check. The loop treats `-not $pushOk` as a lost race, so a push that fails with no rival reaches it too: the reviewer reached it
with one `git config remote.origin.pushurl <missing path>` on the `CLF-004/pass` fixture. The owner re-decided on 2026-10-12
(option (a), "go with your recommendation"): fixture it.

- `originPushUrl`, a new recipe field in `FixtureRepo.psm1` shaped like `originFetch`: a push URL under the fixture that does not
  exist while the fetch URL is untouched; refused without `origin`; three self-tests in `Harness.Tests.ps1` (it sets the push URL
  and leaves the fetch URL alone; it leaves none when not asked; it is refused without `origin`). README and header documented.
- `CLF-007` fail/pass: the `CLF-004/pass` recipe with and without the field. The fail expects `Allocating ...`, three `WARNING: Number
  NNN was claimed concurrently () — renumbering.` lines, two `Renumbered: NNN-probe -> NNN-probe` lines and the refusal, exit 1.
  The expectation was written by hand before the first run and matched on the first run. On the parent's script the `fail`
  fails (exit **97**, the launcher's line) and the `pass` passes.
- The exemption is gone from `rules.json` (the summary and law rewritten, F4), the race warning's not-a-rule reason now cites
  the `CLF-007` fail, the idiom `note` no longer says anything is exempt.
- Amendments, each carrying `Amendment approved by: anas.m, 2026-10-12`: spec (the site-135 row of Background, US2 scenario 3, the
  Assumptions bullets), plan (D2, summary, the Technical Context and Constitution lines that follow, the file list now naming
  `FixtureRepo.psm1`, `Harness.psm1` and `Harness.Tests.ps1`, Testing Strategy, Needs the owner, Complexity Tracking), tasks
  (the phase 1 purpose, T002, T003, T005). Nothing was ticked or approved by this session.

**F2** fixed: `CLF-003/pass` keeps the `feature-x` commit, so the pair differs only in `checkout` (and the description). **F3** fixed
in the section above (the `throw` also fires after a successful push). **F4** fixed with F1: `CLF-007`'s summary says the remote claim
is withdrawn (nothing landed in the failing-push fixture, and the refusal leaves the local branch and spec directory in place,
renumbered twice) and its law cites FR-004. **F5** recorded, not fixed (FR-006): a push the remote refuses while it can still be
read (no write permission, a server-side hook) is reported as `Number NNN was claimed concurrently ()` with an empty rival list; the
script renumbers twice and refuses on the third attempt, passing over three numbers, and ends with the lost-race message, which
misdiagnoses the cause. *Corrected after the phase 2 review (F2): this text first said "an authentication or network failure" and
"renumbers three times". A push that fails because origin is unreachable never gets there: the ledger read straight after the push hits
the line-47 `throw` (exit 1, no renumber).* A candidate roadmap gap next to the line-47 `throw`,
for phase 2's decisions-log entry. **F6**: no action; the refusal is on the process's stderr, as in feature 022's F5, and the owner's
answer to that applies here.

| Measurement after the remediation | Value |
|---|---|
| `-Case CLF-` | 74 passed, 0 failed (16 cases) |
| Full harness | **1410 passed**, 0 failed, 0 skipped (1403 before; 7 more: the `CLF-007` pair at two checks each, plus the 3 `originPushUrl` self-tests) |
| Coverage | `claim-feature.ps1` **7 of 10** sites fixtured (3 not a rule, nothing exempt); exempt rules **3** (the parent's three; the `CLF-007` exemption added and withdrawn within phase 1) |
| `ritual-checks.ps1` | `RESULT OK` |

Not exercised: the Linux CI leg (the reviewer read the stub, line endings, default branch and the nested push for Linux risks and
found none; nothing was run there). Left for the owner: the reviewer created an empty directory `D:\LongDirectoryNameForShortTest_cr`
outside the repository while testing Windows short temp paths; a safety check blocked its removal.

## Phase 2: guidance, flow-down and bookkeeping

### T006: `adoption/updating.md`

A flow-down note shaped like feature 022's, placed after it and before "3. Other surgical files": what was wrong (seven refusals,
terminating `Write-Error`), what it does now, what flows down (the verbatim `scripts/claim-feature.ps1` and the document itself;
nothing surgical), what an owner may newly see (the bare message at a terminal; exactly exit 1 and the message through a wrapper;
the in-process stderr property), what does not change, the two known limits (below), what was measured, what to do. Two digest
markers (110 and 107 characters of content, limit 120). Every backticked path resolves in an adopted project (`doc-lint` `OK` in
all three measured states).

The note states the two behaviours found while fixing this script that are **not** changed, so adopters are not surprised by
them: the terminating `throw` in `Get-RemoteFeatureHeads` (also after a push that succeeded: check the remote before retrying), and
a failed `git push` being reported as a lost race that burns three numbers (F5 of the phase 1 review).

### T007: `docs/roadmap.md` and the digests

GAP-031 gained a 2026-10-13 status (closed by feature 023, with what stays open); its feature row is `shipped` with the spec path
unbracketed (the directory is on the branch), and the row's "candidate for the Micro lane" wording now says Standard, not Micro, and why;
a decisions-log entry dated 2026-10-13 records what shipped, what was measured, what the owner decided (lane, D1, D2 as amended),
what the work corrected (the false lost-race premise), and what stays open. `build-digests.ps1` rebuilt the digests: 100 markers, only
`docs/digests/adoption-digest.md` changed (the two new markers).

### T008: the measurement (US3, SC-001)

Method: for each project, `git clone` from its local directory into the scratchpad (never the real project; the clone's `origin` is
the project on disk), the kit before this feature applied (a detached worktree of `12e9a1f`, the merge of PR #69, the parent of the
feature's first commit) with `update-kit.ps1`, `build-digests.ps1` run, committed; the kit as it stands applied the same way, digests
rebuilt, committed. Probes in each state on `main`, resetting the clone to a clean `main` between runs: a successful claim
(`claim-feature.ps1 -NoPush -ShortName probe "a probe"`), three refusals (an untracked file, a checkout of another branch, `origin`
set to a path that does not exist), `doc-lint.ps1`, `ritual-checks.ps1 -Branch main`. States: S0 installed, S1 kit before (rebuilt),
S2 kit now (rebuilt). Nothing was pushed.

| Probe | S0 -> S1 -> S2 (all three projects) |
|---|---|
| successful claim, `-NoPush` | exit 0 in every state; **S1 and S2 byte-identical** in FitForge, FlowBoard and ExpenseTracker |
| dirty working tree (line 79) | exit 1 in every state; S1: the PowerShell error record with the message and the dirty path on its last line; S2: the message, then the dirty path on its own line |
| not on main (line 84) | exit 1 in every state; S1: error record; S2: the message alone |
| fetch of origin fails (line 96) | exit 1 in every state; S1: error record; S2: the message alone |
| `doc-lint.ps1` | exit 0 and byte-identical S1 to S2 in all three |
| `ritual-checks.ps1 -Branch main` | `RESULT OK` in every state of every project; no member word moved |

Every other line that differs between S1 and S2 in the `ritual-checks` output is the second update's own bookkeeping: the
`enforcement-pack` line's changed-file count (22 to 23, one more commit), the `digests` line's marker count (two more: 97 to 99 in
FitForge, 74 to 76 in FlowBoard and ExpenseTracker) and the `verify-kit` line's recorded kit commit (`12e9a1f` to `6f5e0b7`). Not
exercised: the other four refusals in an adopted project, anything run through a wrapper that starts the script as a child, and a
claim with a push (it would push to the project's real origin); the kit's fixtures cover those through the enforcement harness.

**A defect in the first measurement driver, found and fixed before any number was used.** The first pass reported S1 and S2
identical on everything, including the refusals, which is impossible: the refusal text must differ. The driver's reset between
runs used `git checkout -f main`, which discarded the uncommitted second update during the "as applied" probe, so every later state
silently ran the first kit. It was caught because the refusal output was byte-identical across the two kits and the digest count did
not move; the clone's last commit was "measure: kit before" and its script still had `Write-Error`. The driver was fixed (no forced
checkout, no probe of the uncommitted state, and an assertion that the "kit now" commit exists), the clones were re-made, and the
first pass was discarded. The numbers above are from the corrected driver, whose clones end on "measure: kit now" with
`Stop-Refused` in the script and the recorded kit commit `6f5e0b7`. A second pass, on the final documents (the measured paragraph
was written after the first corrected pass), is recorded below.

Second pass, on the final documents (the measured paragraph and the roadmap entry written): all 36 outputs of S1-rebuilt and S2-rebuilt
(three projects, six probes, two states) are byte-identical to the first corrected pass once the scratch directory's name is set
aside, and each clone ends on "measure: kit now" with `Stop-Refused` in the script and the recorded kit commit `6f5e0b7`.

### Phase 2 AI review and its remediation

Review: `ai-code-review-phase-2.md` (fresh-context reviewer, REQUEST CHANGES). The bookkeeping was confirmed clean (scope check PASS, the
digest changing by exactly the two markers, no spec/plan/tasks change in the phase commit, `doc-lint` and `ritual-checks` OK) and the
reviewer re-ran the measurement on FitForge and got the same results; the blocking findings were two claims in the adopter-facing note,
both mine.

- **F1 (blocking), fixed.** The flow-down note said a wrapper, CI job or agent starting the script as a child process could get 97 or a
  leaked 128 and now gets 1. False: started with `pwsh -File` (or `pwsh -Command`) the exit was already 1 (this session's own T001
  measured it); the 97 and 128 are particular to the harness's launcher, which runs the script in-process inside a try/catch. What the
  note had left out is the change an in-process caller actually meets, measured by the reviewer: before, a refusal threw (the caller's
  `catch` fired, `$LASTEXITCODE` stayed 0); now nothing is thrown, `$LASTEXITCODE` is 1, and a caller under
  `$ErrorActionPreference = 'Stop'` carries on past the refused claim. The note's "what was wrong", "what an owner may newly see" and
  "what to do" now say that, and the roadmap entry carries it.
- **F2 (blocking), fixed.** The "failed push" limit said "an authentication or network failure ... renumbers three times". It renumbers
  twice (three `WARNING` lines, two `Renumbered:` lines; passing over three numbers), and a network failure never gets there: the
  ledger read straight after the push hits the line-47 `throw`. Only a push the remote refuses while it can still be read (no write
  permission, a server-side hook, a push URL that differs from the fetch URL, which is what `originPushUrl` builds) takes the lost-race
  path. The note, the roadmap entries, the second digest marker and the phase 1 F5 text above are corrected, and the retry advice now
  says what state the failed claim leaves (the working copy on the new branch with its spec directory).
- **F3 (doc drift), fixed with the owner's approval.** The withdrawn lost-race premise survived in `spec.md` (the US2 intro, US2
  scenario 1, FR-003, SC-002), `plan.md` (the Summary's "no new recipe field") and `tasks.md` (Prerequisites: "site 135 exempt"). Each
  now says seven fixtured sites, one new recipe field, site 135 fixtured; each amended document carries `Amendment approved by: anas.m,
  2026-10-13`, and the remediation commit names the same approver. Nothing was ticked or approved by this session.
- **F4 (minor), fixed.** The decisions-log entry said "every refusal exits 1 in both states"; only three of the seven were run on the
  clones. It now says "each of the three refusals run", and the note's measured paragraph says the same.
- **F5 (minor), recorded.** SC-001's "one renumbering" success had no evidence. The reviewer built a fixture by hand (a bare origin and a
  stub stock script that pushes `001-rival` between allocation and the push) and ran the `12e9a1f` and `868cfc6` scripts with
  `pwsh -File`: both printed `Allocating 001`, `WARNING: Number 001 was claimed concurrently (001-rival)`, `Renumbered: 001-probe ->
  002-probe`, `CLAIMED: 002-probe (pushed ...)`, `SPEC_FILE` and `NEXT`, exit 0, byte-identical; the loop body is unchanged, so the
  result was expected. Not run on an adopted project and not a harness fixture.
- **F6 (minor), not ours.** Feature 022's roadmap row still has a bracketed spec path although 022 is on `main`; the owner may unbracket
  it in a main-side docs commit. 023's row is unbracketed before its merge, as 020 and 021 did.

**A finding about feature 022's merged note, not fixed here.** The review says feature 022's flow-down note used the same "a caller that
was not a terminal" framing for the exit code of its refusals, which this review found inaccurate for 023. Whether 022's note
overstates a child-process difference the same way has not been checked in this session; it is on `main` and any fix is a separate
docs commit, the owner's call.

### T009: the final run on an isolated checkout

Run on a detached `git worktree` of `5b1d659` (the phase 2 remediation commit) outside the repository, removed afterwards; nothing in
this repository was written by it. An earlier run on `868cfc6` (the phase 2 commit before its remediation) was superseded by this one
and gave the same harness result, as expected: everything after `6f5e0b7` changed documents only.

| Check | Result |
|---|---|
| `scope-check.ps1 -Commit <sha> -Branch 023-claim-feature-refusals` on each commit since `12e9a1f` | the five spec, plan and tasks commits (`52e58c7`, `da2792f`, `c55317d`, `aab831c`, `3fa9b45`): `UNGRADED`, no `phase N` token, as expected; the four phase commits: **PASS**: `d10a37a` (49 files), `6f5e0b7` (17), `868cfc6` (4), `5b1d659` (8) |
| `ritual-checks.ps1 -Branch 023-claim-feature-refusals` | **RESULT OK**: `doc-lint`, `enforcement-pack`, `scope-check`, `digests` (100 markers), `roadmap-claims` OK; `scope-repos` and `verify-kit` n/a |
| Full harness | **1410 passed**, 0 failed, 0 skipped, `enforcement-tests: OK` |
| Coverage | 10 grading scripts, 242 of 254 sites fixtured; `claim-feature.ps1` **7 of 10** (3 declared not a rule, nothing exempt); exempt rules **3** |

Counts across the feature: full harness 1373 on the parent of phase 1, 1403 after phase 1, 1410 after its remediation (the `CLF-007`
pair and the `originPushUrl` self-tests), unchanged by phase 2 (documents only). This section is the only change of this commit; it
carries no `phase N` token and is not graded by the scope check. Remaining: the owner's gate on the final state, the human review of
both phases, and the merge. Open for the owner, none blocking: the line-47 `throw` and the refused-push misreport (recorded, not
rows); feature 022's roadmap row still bracketed and whether its flow-down note shares 023's child-process framing; the reviewer's
stray empty directory `D:\LongDirectoryNameForShortTest_cr`; and the Linux CI leg, which no session has run for this feature.
