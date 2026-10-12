# AI Code Review — 023 claim-feature.ps1's refusals reach their own message and exit (phase 2)

**Reviewer**: fresh-context agent — claude-opus-5-5
**Date**: 2026-10-13
**Branches**: agentic-sdlc-kit `023-claim-feature-refusals` (tip `868cfc6`)
**Scope reviewed**: commit `868cfc6` in full (`git show 868cfc6`, 4 files): the new flow-down note in `adoption/updating.md`
(read beside feature 022's and 021's notes), the GAP-031 row, the feature row and the 2026-10-13 decisions-log entry in
`docs/roadmap.md`, the two new lines of `docs/digests/adoption-digest.md`, and the Phase 2 section of `notes.md`. I checked
every claim against `scripts/claim-feature.ps1` (whole, and `git diff 12e9a1f 868cfc6 -- scripts/claim-feature.ps1`), the
`CLF-007` and `CLF-003/fail-json` fixtures, `tests/enforcement/lib/RunChild.ps1`, `tests/enforcement/rules.json` (`CLF-007`),
`kit-manifest.json` and `docs/sdlc/branch-strategy.md` ("Number Allocation", the bracket rule). I graded against `spec.md`
(US3, FR-001 to FR-007, SC-001 to SC-004, Edge Cases), `plan.md` (D6, D7; D2 as amended), `tasks.md` (Phase 2, T006 to
T009, Territory), `docs/sdlc/review-process.md`, `docs/sdlc/definition-of-done.md` and the constitution. I also read the
phase 1 review (`ai-code-review-phase-1.md`) and feature 022's phase 2 review for format and prior findings.
**Feature contract**: phase 2 changes no script. It adds a flow-down note in the shape of 022's, closes GAP-031, marks the
row `shipped`, logs the owner's decisions (D7) and measures a `-NoPush` claim on clones of the three adopted projects (D6,
SC-001). Territory is `adoption/updating.md`, `docs/roadmap.md` and `docs/digests/**`, plus the feature's own `notes.md`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: claude-sonnet-5-5 (Claude Code session)
- **Inputs provided**: the phase 2 commit 868cfc6 diff, spec.md, plan.md, tasks.md, notes.md
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES**. The bookkeeping is in order. Territory passes, the digest moves by exactly its two markers, every
check is green on an isolated checkout of the tip, and I reproduced the core measurement on a FitForge clone: the
`-NoPush` claim is byte-identical before and after, each of the three refusals exits 1 in both states, and the marker count
goes from 97 to 99. The problem is the flow-down note, which is the phase's deliverable to adopters (FR-007, US3 scenario
1). It makes two claims that the kit's own evidence contradicts, and both are repeated in the roadmap.

- **F1.** The note says which callers see a difference, and gets it wrong. A child process started with `pwsh -File` or
  `pwsh -Command` got exit 1 before and still does. The 97 and 128 exits came only from the kit harness's launcher,
  which runs the script in-process inside a `try/catch`. The change the note leaves out is the one an in-process caller
  will actually notice: a refusal used to throw a terminating error that halted the caller or reached its `catch`. Now
  it throws nothing, sets `$LASTEXITCODE` to 1, and the caller carries on.
- **F2.** The second known limit misstates the loop. A failed push renumbers **twice**, not three times; the kit's own
  `CLF-007` fixture and plan D2 say twice. A network failure does not reach the lost-race message at all: the ledger
  read straight after the push fails first and ends in the `throw`.

Three smaller findings: F3, the lost-race premise survives in parts of spec, plan and tasks even though the roadmap says
they were amended; F4, the roadmap entry generalises "every refusal" from three measured refusals; F5, SC-001's
renumber-once case had no recorded evidence, which I supplied. F6 is an observation about feature 022's row. The residual
risk is in the guidance an adopter reads. The script is unchanged in this phase and was confirmed again here.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | **FR-007, shape.** The note has 022's sections in 022's order: what was wrong, what it does now, what flows down, what an owner may newly see, what does not change, what was measured, what to do. It adds a "Known limits" paragraph, which is fine. **The seven refusals and their order** match the script's call order (lines 82, 89, 93, 104, 116, 119, 142 of `868cfc6`). **"Unchanged wording"**: `git diff 12e9a1f 868cfc6 -- scripts/claim-feature.ps1` changes only the seven call sites (`Write-Error` to `Stop-Refused`, same literal) plus the new function, and phase 1's review compared the literals byte for byte. **"Exit 1 from the script itself"**: `Stop-Refused` ends in `exit 1` (line 78). **`-Json`**: the `CLF-003/fail-json` expectation is the bare message, exit 1, with no object. **The `throw` limit**: `Get-RemoteFeatureHeads` (line 47) is called at line 105 (after the first fetch), line 134 (after every push) and line 145 (after the in-loop re-fetch), so "also right after a push that succeeded" is true. **The push limit**: wrong in two respects (F2). **"What an owner may newly see"**: the in-process redirection sentence is true, but the wrapper sentence is wrong and the try/catch change is missing (F1). **What flows down**: `kit-manifest.json` classifies `scripts/*.ps1` and `adoption/**` as `verbatim` and `docs/digests/*-digest.md` as `generated`. So "one verbatim file and this document; nothing surgical; run `build-digests.ps1`" is right. **Digest markers**: 110 and 107 characters (limit 120). The first is accurate. The second ("a failed push reads as a lost race") is true only for a push the remote refuses while its ledger can still be read (F2). **Paths**: every backticked path in the note is `scripts/...` or a bare file name. No `tests/` or `specs/023...` path is cited; the kit notes are named in prose. `doc-lint.ps1` is `OK` on the tip worktree and on my FitForge clone after the update. **Advice "check `git ls-remote --heads origin` before retrying"**: it is the right test of whether the claim landed. It leaves out that the throw leaves the working copy on the new branch with its uncommitted spec directory, so a retry from that state is refused as not on `main` (see F2's action). |
| Visual-reference match | N/A: no UI. |
| Feature contract held (no unapproved table/migration/permission/package) | No script, package or recipe change in `868cfc6`. `git show --stat 868cfc6` lists `adoption/updating.md` (+61), `docs/digests/adoption-digest.md` (+2), `docs/roadmap.md` (+27/−3) and `notes.md` (+62). |
| Constitution / domain invariants | **Amendment authority (I)**: no spec, plan, tasks or contracts change in this commit, and `AmendmentAuthority: graded 8 of 8 commit(s)` passes in `ritual-checks`. **D7**: the entry is dated 2026-10-13, the day the feature ships as D7 and T007 require. The owner's decisions are attributed to 2026-10-12, matching the spec and plan approval lines (`Status: Approved (anas.m, 2026-10-12)`, the plan's "Needs the owner" 1 and 2, the D2 amendment line). Dating the entry by the ship day and the decisions by the decision day is coherent. **The entry's numbers**: 10 grading scripts and three exempt rules match `notes.md` T005 and the remediation table. `originPushUrl` and the `<ROOT>` slash substitution match phase 1's deviations 1 and F1. The open items (eighth terminating site, the failed-push misreport, process stderr, the Linux leg not run) are all real. The failed-push item carries F2's error. |
| Security (authn/authz, secrets, sensitive logging) | N/A: documents only. The note names no credential. My measurement clone's `origin` was the project's local directory, I used `-NoPush` only and pushed nothing. The real projects were only read by `git clone`. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | In a detached worktree of `868cfc6`: `scope-check.ps1 -Branch 023-claim-feature-refusals` gives `scope-check: PASS phase 2 commit 868cfc6 (4 file(s))`, and `-All` gives PASS for `d10a37a`, `6f5e0b7` and `868cfc6`. `build-digests.ps1 -Check` gives `digests: OK (5 digest(s) fresh, 100 marker(s))`. The digest diff is exactly the two marker lines, in the note's order. `doc-lint.ps1` gives `OK - kit complete, every referenced path resolves`. `ritual-checks.ps1 -Branch 023-claim-feature-refusals`: every member OK, `scope-repos` and `verify-kit` n/a, `RESULT OK`. There are two non-blocking `PhaseSizeWarning`s, both on phase 1 commits. I did not run the full harness, because T009 owns it and phase 2 changes no script or test. |
| Rollback safety (phase reverts cleanly; schema additive?) | The commit is documents plus one regenerated digest. Reverting it removes the note, the roadmap edits and the two digest markers, with no other effect. Phase 2 reverts before phase 1, as the tasks require. |

**The measurement, reproduced (US3, SC-001; one project).** I cloned `D:\solutions\fitforge` into the scratchpad, leaving
the real project untouched. I applied `update-kit.ps1` from a detached worktree of `12e9a1f`, ran `build-digests.ps1` and
committed ("rv: kit before", 7 `Write-Error` in the script). I then did the same from a worktree of `868cfc6` ("rv: kit
now", `Stop-Refused` present, `.kit-version` recording `868cfc6`). With no forced checkout between runs, the results
were:

- The `-NoPush` claim's output files are byte-identical (`cmp`), exit 0, allocating `003-probe`.
- Dirty tree, not on `main` and unfetchable `origin` all exit 1 in both states. Before, the output is a `Write-Error:
  <path>:79` record with `Line |` and a caret, and the dirty path flattened onto the message line. After, it is the bare
  message, and the dirty path is on its own line.
- Digests go from 97 to 99 markers.
- After the update: `doc-lint.ps1` is OK, `ritual-checks.ps1 -Branch main` is `RESULT OK`, and `enforcement-pack` reports
  23 changed files, matching the notes' "22 to 23".

The notes' "recorded kit commit `6f5e0b7`" is the HEAD at the time of their measurement, with the phase 2 documents not
yet committed. My run against the committed `868cfc6` gives the same results, so nothing turns on it. The disclosed driver
defect (`git checkout -f main` discarding the uncommitted second update) is the mechanism the brief describes. It is
described honestly, with how it was caught, how it was fixed and that the first pass was discarded. "No `ritual-checks`
member word moved" holds for FitForge in my run. I did not repeat FlowBoard or ExpenseTracker.

## Findings

### F1 — The note misplaces who sees a difference, and omits the change an in-process caller meets — BLOCKING

`adoption/updating.md`, "What was wrong" says that "a caller that was not a terminal ... through a wrapper that starts the
script as a child" got "97, or a leaked 128". "What an owner may newly see" then says that "a wrapper, CI job or agent
that starts the script as a child process now gets exactly exit 1 ... where it could get 97 or a leaked git exit code".
Neither statement matches the evidence:

- **A child process already got 1.** T001 in `notes.md` measured exit **1** for all six refusals under `pwsh -File`,
  which is how a CI job or an agent starts a script, terminal or not. I ran the old and new scripts as a child with
  `pwsh -NoProfile -Command "& '<script>' ..."` on the not-`main` refusal, and both exit **1**.
- **97 and 128 come from the kit's own launcher.** The values were measured only through
  `tests/enforcement/lib/RunChild.ps1`. That launcher invokes the script **in-process** inside `try { & ... } catch { ... exit 97 }`
  and otherwise exits `$LASTEXITCODE`, which is how 128 leaks from `git`. That shape is particular to the harness, and an
  adopter has no reason to have it.
- **The change an in-process caller will meet is missing.** I measured it on the FitForge clone, old script then new, with
  an in-process caller (`try { & ./scripts/claim-feature.ps1 ... 2>$null } catch { ... }`) on a dirty tree:
  - Before: the `catch` fired and `$LASTEXITCODE` was **0**.
  - After: no exception, `$LASTEXITCODE` **1**, and the message printed despite `2>$null`.
  - A caller under `$ErrorActionPreference = 'Stop'` with no `try`: before, it halted at the refusal. After, it **continued**
    to its next statement.

  The note covers only the `2>$null` / `2>&1` part. A wrapper that relied on the throw to stop it, or on its `catch`, will
  now run on past a refused claim unless it checks `$LASTEXITCODE`. That is the "refusal read wrongly is a claim not taken,
  or taken twice" risk the spec's US1 priority note names.

Feature 022's note used the same "not a terminal" framing and was not challenged. That framing is no more accurate here.

*Action: implementer rewrites the two sentences (still within phase 2's Territory).*

- *"What was wrong" says: under `pwsh -File` (terminal or CI) the exit was already 1, with an error record around the
  message. Run in-process, the refusal was a terminating error, so the exit a launcher reported was its own choice (the
  kit's harness saw 97 or a leaked 128).*
- *"What an owner may newly see" states the in-process change: no exception to catch, `$LASTEXITCODE` 1, and a caller that
  relied on the throw now continues unless it checks `$LASTEXITCODE`.*
- *The GAP-031 row's "through the enforcement harness's launcher" wording is already accurate and can stay.*

### F2 — The failed-push limit renumbers twice, not three times, and a network failure ends in the `throw` instead — BLOCKING

The note says a failed `git push` "(an authentication or network failure) ... renumbers three times". The GAP-031 status,
the decisions-log entry and `notes.md` (from phase 1 review F5) repeat it. Two parts of that are wrong:

- **Two renumbers, not three.** The loop renumbers on attempts 1 and 2 and refuses on attempt 3 before renumbering (lines
  141 to 143 come before 149). `tests/enforcement/cases/claim-feature/CLF-007/fail/expected.txt` shows three `WARNING`
  lines and **two** `Renumbered:` lines. The recipe's description, plan D2 and `rules.json` `CLF-007` all say "renumbered
  twice". "Burns three numbers" is defensible: N and N+1 are passed over, and N+2 is left as a local branch.
- **Not every push failure takes this path.** It needs the push to fail while `git ls-remote` still works, because line
  134 reads the ledger immediately after the push. Examples are no write permission, a pre-receive hook rejecting the
  push, or a push URL that differs from the fetch URL (which is what `originPushUrl` builds).

  I made `origin` unreachable after allocation by having a stub stock script move the bare origin away. Old and new scripts
  alike print `Allocating ...` and then the terminating `throw "git ls-remote failed ..."` at line 47, exit 1, with no
  renumber. So a network failure, or an authentication failure that also blocks reads, lands in the first limit and not
  the second.

The second digest marker ("a failed push reads as a lost race") is acceptable only with that scope.

*Action: implementer corrects the note and the decisions-log entry (both in Territory). The GAP-031 status sentence can
stay as it is, since "a failed push is reported as a lost race that burns three numbers" is true for the push-refused
case.*

- *Corrected wording: "a push the remote refuses while it can still be read (no write permission, a server-side hook) is
  reported as the claim having been made concurrently, is renumbered twice and ends in the lost-race message, passing over
  three numbers; a push that fails because `origin` is unreachable usually ends in the `git ls-remote failed` throw instead".*
- *Optionally, extend the retry advice: after either limit the working copy is left on the new branch with its spec
  directory, so return to `main` and delete the local branch if `git ls-remote --heads origin` shows the claim did not land.*
- *Fix the `notes.md` F5 line to "renumbers twice".*

### F3 — The withdrawn lost-race premise survives in spec, plan and tasks, though the roadmap says they were amended — DOC DRIFT

The decisions-log entry says the exemption "was withdrawn with the plan, spec and tasks amended". The amendments
covered the passages listed in `notes.md`. Other passages still state the premise or its consequence:

- `spec.md:80-81`: "the one that is not reachable is accounted for in writing" (US2 intro).
- `spec.md:91`: "the six reachable refusals" (US2 scenario 1).
- FR-003: "Each refusal that a fixture can reach (sites 72, 79, 84, 96, 108, 112)".
- `spec.md:172` (SC-002): "Each of the six reachable refusals".
- `plan.md:16` (Summary): "No new script, no new library file, **no new recipe field**". The sentence before it now says
  the lost-race site is reached "through one new recipe field", so the paragraph contradicts itself.
- `tasks.md:10` (Prerequisites): "D2 (site 135 exempt) before phase 1 starts".

`rules.json` and `emission-idioms.json` are clean: `CLF-007`'s notes tell the history accurately.

None of this changes what was built. But a reader grading against FR-003 and SC-002 sees six reachable sites where seven
are fixtured. Under constitution I, these documents can only be changed with a recorded approval, so this phase was right
not to edit them.

*Action: implementer drafts the wording fixes as an amendment (seven reachable and fixtured sites; "one new recipe field";
"D2 as amended"). The owner approves and records the approval line, or decides they stay as history. Until then, the
roadmap entry says "the passages that carried the premise were amended" rather than implying the documents are clean.*

### F4 — The roadmap entry generalises from three measured refusals to "every refusal" — MINOR

The 2026-10-13 decisions-log entry and the commit message say "every refusal exits 1 in both states with the PowerShell
error record around the message gone". Only three of the seven refusals were run on the clones. The note's own "What
was measured" paragraph scopes this correctly ("Every refusal exited 1" after naming the three, then a "Not exercised"
list), but the roadmap entry carries no such qualifier. The fixtures prove the other four through the harness, but not
"in both states" on an adopted project.

*Action: implementer changes the roadmap sentence to "each of the three refusals run on the clones exits 1 in both
states ...". The commit message can stay as it is.*

### F5 — SC-001's renumber-once success had no recorded evidence; measured here and identical — MINOR

SC-001 and FR-002 include "one renumbering" among the successful claims that must print the same bytes. Neither the
fixtures (no origin, push, `-NoPush`) nor the phase 2 measurement (`-NoPush` only) ran it, and the note's success sentence
lists only the three other cases.

I built a fixture by hand with a bare origin and a stub stock script that pushes `001-rival` to `origin` between
allocation and the push, then ran the `12e9a1f` and `868cfc6` scripts with `pwsh -File`. Both printed:

- `Allocating 001`;
- `WARNING: Number 001 was claimed concurrently (001-rival)`;
- `Renumbered: 001-probe -> 002-probe`;
- `CLAIMED: 002-probe (pushed ...)`, `SPEC_FILE` and `NEXT`;
- exit 0, with remote heads `001-rival`, `002-probe` and `main`.

The two outputs are byte-identical apart from the commit sha in my own `ls-remote` dump. FR-002 holds for this case, and
it was expected to, since the loop body is unchanged.

*Action: implementer records this reviewer measurement in `notes.md` as SC-001's renumber evidence, or states that the
case was proved by inspection of an unchanged loop. No code or fixture change is required.*

### F6 — Feature 022's row stays bracketed after its merge; 023's unbracketing follows precedent — MINOR

`docs/sdlc/branch-strategy.md:51-57` says to drop the brackets "when the feature merges". 023 drops them in its last phase
commit, before the merge. That is what 020 (`427a538`) and 021 (`382f5da`) did. The directory exists on the branch, so
`doc-lint` resolves it, and it will exist on `main` after the merge. No doc-lint or roadmap-claim issue arises:
`roadmap-claims: OK`. Meanwhile 022's row still reads `` `[specs/022-verdict-honesty-repos-territory/]` ``, although
`specs/022-verdict-honesty-repos-territory` is on `main` (`git ls-tree main specs/`). That is stale, but outside this
feature.

*Action: none for 023. The owner may unbracket 022's cell in a main-side docs commit.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None.** `git show --stat 868cfc6` touches no `spec.md`, `plan.md`, `tasks.md` or `contracts/` file. The only file under
`specs/` is `notes.md`, which is evidence. `AmendmentAuthority` grades 8 of 8 commits on the branch as passing. The phase 1
remediation's amendments (`6f5e0b7`) carry `Amendment approved by: anas.m, 2026-10-12` and are outside this review.

## Constitution re-check (post-implementation)

**PASS, subject to F1 and F2.**

- **I (Specification First)**: met. No feature document was edited, and the amendment drift is reported rather than
  self-fixed (F3).
- **II (source of truth)**: the note follows the script and fixtures except where F1 and F2 say otherwise. Those are
  conflicts with a higher rung, reported here.
- **III, V, VII**: N/A.
- **VIII (Testing)**: no test change in this phase. The fixtures of phase 1 stand.
- **IX (Human Review)**: this fresh-context review, then the human review at merge.
- **X (Controlled Delivery)**: one phase, inside its Territory. Gate certification is `user-run`. The decisions-log
  entry says that "shipped" still awaits the owner's gate and merge review, which is honest.

## Test coverage observed

No test changed in `868cfc6`. Feature-level coverage, from phase 1 and spot-checked here:

- **Rules**: `CLF-001` to `CLF-007`, each with a fail and a pass, plus `CLF-003/fail-json` and `CLF-004/pass-nopush`.
  Nothing is exempt, and the coverage report lists 10 grading scripts (phase 1 notes).
- **Critical assertions**:
  - the bare message with exit 1 for each refusal;
  - `CLF-007/fail`'s three warnings, two renumbers and the refusal;
  - the three success outputs pinned byte for byte.
- **Not covered by any fixture**: the line-47 `throw` (no recipe field makes `ls-remote` fail after a successful fetch or
  push) and the renumber-once success (F5, measured by this reviewer).
- **Not run**: the full harness (T009, the owner's run) and the Linux CI leg.

**FR-001 to FR-007 and SC-001 to SC-004 against the two phases:**

| Requirement | Status |
|---|---|
| FR-001, FR-002 | Met (phase 1 review; F5) |
| FR-003, FR-004, FR-005 | Met (phase 1 remediation, `CLF-007` through `originPushUrl`) |
| FR-006 | Met (the script diff is the seven call sites plus the function) |
| FR-007 | Met in form; its content needs F1 and F2 |
| SC-001 | Met: fixtures, three clones per the notes, FitForge re-run here, renumber-once here |
| SC-002 | Met, for seven sites rather than the six it names (F3) |
| SC-003 | Met at its lower bound (exempt count three) |
| SC-004 | Rests on phase 1's 1410-pass run and the owner's T009 |

## Residual risk

The risk sits in the adopter-facing text, not the code:

- **F1**: an in-process wrapper that relied on the old throw now continues past a refused claim, and the note does not
  say so.
- **F2**: adopters are told a network failure will renumber, when it actually ends in a `throw`, and the renumber count is
  wrong.

Both are text fixes inside phase 2's Territory, followed by `build-digests.ps1` if the second marker is reworded. Then a
re-review of the changed paragraphs. F3 needs an owner-approved amendment or an explicit decision to leave the wording as
history. Before merge: the owner's T009 run (full harness on the final commit) and the gate, then human review. The Linux
CI leg remains unexercised by any session.
