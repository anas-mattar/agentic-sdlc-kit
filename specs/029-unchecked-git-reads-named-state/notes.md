# Notes: 029 unchecked git reads named state (GAP-035)

## Owner decisions

- **Spec approved** (anas.m, 2026-10-15): Decision 1 option B (every unchecked read in both scripts, one phase per group), Decision 2 the 027/028 lane split.
- **Plan approved** (anas.m, 2026-10-15): D1-D9 and Needs-the-owner items 1-4 as recommended.
- **Tasks approved** (anas.m, 2026-10-15), commit `48ccb8f`.

## Phase 1

### Baseline (T001)

- Parent of the phase: `48ccb8f` (documents only; scripts identical to `ea1d393`). Full harness on an isolated detached worktree: **result recorded below when the run ends**.
- **Reproduction** (throwaway repository, `repro.ps1` in the session scratchpad: `main` with a README; `001-thing` declared Micro, one `phase 1` commit adding `src/thing.ps1` of 700 lines):

  | Blob `src/thing.ps1` | `git diff --name-only <base> HEAD` | `git show --numstat --format='' HEAD` | pack |
  |---|---|---|---|
  | readable | exit 0, 2 files | exit 0 | `MicroLane` failure (700 > 400), `PhaseSizeWarning` printed, **exit 1** |
  | truncated (loose object cut to half) | exit 0, 2 files | **exit 128, no lines** | no `MicroLane` failure, no `PhaseSizeWarning`, `enforcement-pack: OK`, **exit 0** |

  The hole is as 028's review described it (GAP-035): the diff still computes, because it needs trees, not blobs; the line count needs the blob.

### The probe (T002)

Every inventoried read, run directly against throwaway repositories, one per damage mode. Cell is `exit/lines`. `probe.ps1` and `probe2.ps1` are in the session scratchpad.
Damage: **blob** = the loose blob of `src/thing.ps1` cut to half; **tree** = the tree of `src/`; **commit** = the loose object of `HEAD`.

| Read | none | blob | tree | commit(HEAD) |
|---|---|---|---|---|
| G1 `show --numstat --format= HEAD` | 0/2 | **128/0** | **128/0** | 128/0 |
| G2a `rev-list --no-merges base..HEAD` | 0/1 | 0/1 | 0/1 | 128/0 |
| G2b `log -1 --format=%s HEAD` | 0/1 | 0/1 | 0/1 | 128/0 |
| G3 `rev-list base..HEAD` | 0/1 | 0/1 | 0/1 | 128/0 |
| G4 `log -z ...` | 0/2 | 0/2 | 0/2 | 128/0 |
| G5 `log --name-status` | 0/4 | 0/4 | **128/0** | 128/0 |
| G6 `rev-list --reverse range` | 0/1 | 0/1 | 0/1 | 128/0 |
| G7 `show HEAD:<path>` | 0/50 | **255/0** | 128/0 | 128/0 |
| G8 `show -U0 HEAD -- <path>` | 0/56 | **128/0** | 128/0 | 128/0 |
| G9 `rev-parse HEAD:<path>` | 0/1 | 0/1 | **128/0** | 128/0 |
| G10 `ls-tree -r --name-only HEAD -- src` | 0/1 | 0/1 | **128/0** | 128/0 |
| G11 `log --follow %aI -- <path>` | 0/1 | 0/1 | **128/0** | 128/0 |
| G12 `log -1 --date=format ... HEAD` | 0/1 | 0/1 | 0/1 | 128/0 |
| G13a `diff --name-only HEAD` | 0/0 | **128/0** | 0/0 | 128/0 |
| G13b `ls-remote --heads origin` | 0/2 | 0/2 | 0/2 | 0/2 (a local origin; needs an unreachable URL) |
| G14a `log -1 --format=%ct origin/other` | 0/1 | 0/1 | 0/1 | 128/0 |
| G14b `diff --name-only main...origin/other` | 0/2 | 0/2 | **128/0** | 128/0 |
| O1 `cat-file -e HEAD:./<path>` (present) | 0/0 | **0/0** | 128/0 | 128/0 |
| O2 `cat-file -e HEAD:./absent.md` | 128/0 | 128/0 | 128/0 | 128/0 |
| O3 `rev-parse --verify --quiet HEAD:<path>` | 0/1 | 0/1 | 128/0 | 128/0 |
| O4 `rev-parse --verify --quiet HEAD:absent` | 1/0 | 1/0 | 1/0 | 128/0 |
| O5 `rev-parse --is-shallow-repository` | 0/1 | 0/1 | 0/1 | 0/1 |
| O6 `rev-parse --abbrev-ref HEAD` | 0/1 | 0/1 | 0/1 | 0/1 |

A second probe damaged a commit **in the middle** of the branch (HEAD readable): `git merge-base main HEAD`, `rev-list`, `log` all exit **128**; `git diff --name-only main HEAD` still exits 0.

### What the probe shows

1. **Confirmed, reachable**: G1 (blob or tree), G5, G9, G10, G11, G14b (tree), G7, G8, G13a (blob). Each fails with a non-zero exit on a state `truncateBlob` reaches (a file path for a blob, a directory path for a tree).
2. **Not reachable as a verdict-changing failure in the pack** — G2a, G2b, G3, G4, G6, G12, G14a: they fail only when a **commit object** of the range is damaged, and a damaged commit breaks `git merge-base` first (exit 128), which puts the pack in the already-named *no base* state (the same finding 028 made about `truncateCommit`). The `blob` and `tree` columns show them exiting 0 with correct output. They stay unchecked reads, but there is **no data state** in which a fixture can show them swallowing a failure while the pack still has a base; a failure of one of them can only come from a fault outside object damage (a transient I/O error, a permission failure, a killed process).
3. **O1 cannot be graded on its exit code**: `cat-file -e` of a present file with a damaged blob exits **0** (it names the object, it does not inflate it), and an absent path and a damaged tree both exit **128**. This confirms the plan's out-of-scope reason for O1. O3/O4 are the same: exit 1 for "absent", 128 for an unreadable object in some modes but 1 for a damaged tree on a missing path (O4 `tree` column), so absent and unreadable overlap.
4. O5 and O6 exit 0 in every mode: out of scope as predicted.
5. G13b, `ls-remote`, is not reached by object damage at all; it needs an unreachable `origin` URL, which a fixture can build.

### Stop: the plan's D8 asks for the owner

Per T002, the probe contradicts a prediction and the plan is not amended by the author. Open questions for the owner, recorded here and answered in the owner's own words below:

- Q1: the seven commit-object reads (G2a, G2b, G3, G4, G6, G12, G14a) have no data state a fixture can reach. Grade them anyway (cheap, same helper, guarded by a mutation and a unit-level check instead of a fixture) or reclassify as *out of scope: unreachable by damage; a failure needs a non-corruption fault*?
- Q2: G12 (`Get-SurfaceExceptions`'s date) is in this set; it also means phase 3's second fixture (`GITREAD-012`) cannot exist as planned.

*Owner's answer*: option A (anas.m, 2026-10-15) — grade the seven reads anyway, guard them by mutation, record each as an exemption; plan and tasks amended (Amendment 1).

### What was built (T003-T005)

- Fixtures (hand-written expectations), 6 cases in 2 rules: `GITREAD-001/{fail,pass,fail-two-commits,pass-empty-phase-commit}` and `GITREAD-002/{fail,pass}`. The plan's D7 named one rule id per read
  (`GITREAD-001..014`); the harness inventories **emission sites**, so the ids are per site (`GITREAD-001` the numbered failure arm of `Add-GitReadUnreadable`, `GITREAD-002` its UNGRADED arm) and
  each read is a variant directory. No behaviour differs from the plan; later phases add variants under these two ids.
- On the parent commit (a detached worktree at `48ccb8f` with only the new cases and `rules.json` copied in): `GITREAD-001/fail`, `fail-two-commits` and `GITREAD-002/fail` fail (exit code
  and/or output: the parent prints `enforcement-pack: OK`, exit 0, and no warning); the controls `GITREAD-001/pass`, `pass-empty-phase-commit` and `GITREAD-002/pass` pass there by design.
- `scripts/enforcement-pack.ps1`: `Read-GitLines` and `Add-GitReadUnreadable` beside the 028 helpers; the Micro walk (`rev-list`, `log -1`, `show --numstat`: G1, G2) and
  `Invoke-PhaseSizeWarningCheck` (`rev-list`, `show --numstat`: G3, advisory so UNGRADED) read through them. `Read-DiffLines` and every other member are unchanged. No `LIMITS` comment
  described these reads as unchecked (the statement of the limit is in `adoption/updating.md`, phase 5), so none was edited.
- Amendment commit: the first message did not carry the approver record, and the kit's own amendment check caught it (`AmendmentAuthority: commit 963e313 records 'anas.m' ... but its commit
  message does not name them`). The commit was local and unpushed, so it was amended (now `d2482e9`); the pack is `OK` on the branch.

### Mutations (T006)

Each applied to the script, run over `-Case GITREAD-`, restored byte for byte (hash compared).

| Mutation | Caught by |
|---|---|
| M1 read the exit code a statement late | 5 failing expectations: `GITREAD-001/fail`, `fail-two-commits`, `GITREAD-002/fail` |
| M2 keep the partial output on a failed read | **not caught, and no fixture can catch it**: a failing `git show --numstat` prints nothing, so there is no partial output to grade (the same limit as 028's M2) |
| M3 enter the state on empty output instead of a non-zero exit | `GITREAD-001/pass-empty-phase-commit` |
| M4 drop the per-read dedupe | `GITREAD-001/fail-two-commits` |
| M5 an advisory check fails like a numbered one | `GITREAD-001/fail`, `fail-two-commits`, `GITREAD-002/fail` |
| M6 the numbered lane prints UNGRADED instead of failing | `GITREAD-001/fail`, `fail-two-commits` |
| M7 the Micro numstat failure ignored | `GITREAD-001/fail`, `fail-two-commits` |
| M8 the PhaseSize numstat failure ignored | `GITREAD-001/fail`, `fail-two-commits`, `GITREAD-002/fail` |

Exemption guards (Amendment 1: no reachable data state): each read is made to fail by pointing it at a missing ref, and the site must name it. Run on the readable 700-line Micro reproduction.

| Injected failure | Result |
|---|---|
| E1 the Micro walk's `rev-list` (G2a) | `GitReadUnreadable: git rev-list of <base>..HEAD failed on '001-thing' (git exited 128), so the phase's size could not be measured ...` |
| E2 the Micro walk's `git log -1` (G2b) | `GitReadUnreadable: git log of a43d266 failed on '001-thing' (git exited 128) ...` |
| E3 `PhaseSizeWarning`'s `rev-list` (G3) | `UNGRADED: PhaseSizeWarning: git rev-list of <base>..HEAD could not be read (git exited 128), so no commit on the branch was measured ...` |

### Run results (T007, partial at the time of the phase commit)

- `-Case GITREAD-`: 74 passed, 0 failed. `-Case MICRO-`: 100 passed. `-Case PHASE-`: 86 passed.
- `ritual-checks.ps1` on the working tree: doc-lint OK, digests OK, roadmap-claims OK, enforcement-pack OK after the amendment-message fix (the pre-fix FAIL is the defect above).
- The wider families (`DIFF-`, `LITE-`, `AMEND-`, `CRIT-`, `PACK-`, `PROV-`), the baseline full-harness count on the parent and the full harness on an isolated checkout of the phase commit were still
  running when the phase was committed; their numbers are recorded below when they finish, and T007 stays open until they do.

### Correction found by the wider families (after the first phase commit `18fc556`)

`-Case DIFF-` and `-Case AMEND-` failed 3 and 2 expectations: five **pre-existing** fixtures (`DIFF-001/fail`, `DIFF-001/fail-with-review-file`, `DIFF-002/pass`, `AMEND-005/fail`,
`AMEND-008/fail`) damage a subtree of the branch (028's `truncateBlob` on a directory). That damage also makes `git show --numstat` fail, so `PhaseSizeWarning` now names itself once
(`UNGRADED: PhaseSizeWarning: git show --numstat of <sha> could not be read (git exited 128), so that commit was not measured ...`) where it used to print nothing. The new line is the
phase's intended effect on a damaged repository (the same read, the same lane policy), and it is the only difference: exit codes and every other line are unchanged. The five expectations
were updated by hand (one inserted line each) in the follow-up commit; every readable, empty, no-base, shallow and trunk case is byte-identical, and the baseline full harness on the
parent is **1704 passed, 0 failed**. Lesson recorded: the families to run per phase are the ones whose fixtures damage a tree or blob (`DIFF-`, `AMEND-`), not only the rule's own.

### AI review of phase 1 (fresh-context agent, `ai-code-review-phase1.md`): APPROVE with follow-ups

- **F1 (DOC DRIFT), fixed**: the `GITREAD-002` summary in `rules.json` said "a read on a Lite branch"; in phase 1 only the advisory arm is reached (both callers are numbered-only), so the summary now says so and names phase 2 for the Lite path.
- **F2 (ACCEPTED)**: the per-read dedupe hides a second damaged commit of the same kind; by plan D2, and the verdict still fails.
- **F3 (MINOR), recorded**: the `rev-list` and `log -1` failure branches and the advisory `rev-list` branch are guarded by the injected-failure checks above (Amendment 1), not by a fixture, so CI does not run them. `tasks.md` T003 still names per-read ids; the implementation uses per-site ids (noted under "What was built"); not amended, because the ids are a label and the text of T003 was written before the harness's per-site rule was met.
- **F4 (CONFIRM), open**: T007's full-harness count on the isolated phase checkout and the user-run gate are owed before this phase counts as done.

### Phase 1 close-out (T007)

- Full harness on an isolated detached checkout of `0595fc5` (the phase code and fixtures; the later commit `98dcf94` adds only the review file and a `rules.json` summary wording): **1716 passed, 0 failed, 0 skipped**
  (parent baseline 1704: +12 = 6 new cases times two expectations each, the new cases being `GITREAD-001/{fail,pass,fail-two-commits,pass-empty-phase-commit}` and `GITREAD-002/{fail,pass}`).
- `ritual-checks.ps1` on the branch: doc-lint OK, enforcement-pack OK, scope-check PASS on the phase commits, digests OK, roadmap-claims OK.
- **The owner's gate** (anas.m, 2026-10-15, run on `029-unchecked-git-reads-named-state` at `98dcf94` or later): `tests/enforcement/Run-Tests.ps1` exit **0** and `scripts/ritual-checks.ps1` exit **0**,
  as reported by the owner. Phase 1 is certified on that report; phase 2 may start on the owner's go-ahead.

## Phase 2: the amendment and history reads (G4-G10)

### Baseline (T008)

- Parent of the phase: `08b1c49` plus the merge of `main` (the roadmap row only): the full harness count on it is **1716 passed, 0 failed** (phase 1's result; the owner's gate ran it, exit 0).
- Reproduced on the parent, by the new fixtures run against the unchanged script (each failed there):
  - `AMEND-011/fail-name-status` (a middle commit's subtree truncated): `git log --name-status` exits 128; the check printed `AmendmentAuthority: graded 1 of 2 commit(s)` and **exit 0**: nothing was graded and the count line did not say so (G5).
  - `AMEND-011/fail-lite-show-record` (a `docs/` branch, an amendment of another feature's plan WITH a record, the blob unreadable): the parent **failed the Lite branch** (exit 1) with `no conforming approver record`, a wrong cause and a NEW hard failure on a condition the check cannot compute (014 FR-009). Found by the fixture, not predicted by the plan.
  - `AMEND-011/fail` and `fail-tick-blob` (numbered): the same wrong-cause "no record" failure, for an amendment that carries a record, and for a tick-only change that is exempt.

### What was built (T009-T011)

- `scripts/enforcement-pack.ps1`: `Read-AmendmentGit` (goes through `Read-GitLines`, records the FIRST failure), `Set-AmendmentReadFailure`, `Test-AmendmentReadFailed` (prints the refusal `AmendmentAuthority: cannot grade '<b>' - <read> failed (git exited N), so what the branch's commits changed is unknown; ...` and stops the walk), `Test-SameBlobContent` (G9: a failed read is never "the same", so the path is graded). Reads moved behind them: the metadata batch (G4), the name-status batch (G5), the range `rev-list` (G6), `Get-BlobLines` (G7), `git show -U0` (G8), the rename compare (G9) and the renumbering `ls-tree` (G10). Checks sit at the boundaries of the walk (after each batch, at the top of each commit, after the amended-paths stage, before the verdict, after the loop). The numbered lane fails; the Lite lane converts the refusal to UNGRADED by the existing prefix rule (027 D8), so nothing is newly failed there.
- **A regression the wider families found before the commit**: `git show <rev>:<path>` exits 128 for a path the commit does not hold (a deleted document), so the first version of `Get-BlobLines` refused four existing merge fixtures (`AMEND-001/fail-merge-deletes-approved-document`, `fail-merge-deletes-contract-main-into-branch`, `fail-merge-other-feature-deletes-contract`, `fail-merge-renames-and-rewrites-contract`). A truncated blob exits 255 and a damaged tree 128, so the exit code cannot separate "absent" from "unreadable"; `Get-BlobLines` now probes a failed show with `git ls-tree <ref> -- <path>` (exit 0 and no output = absent = an empty body, as before). Those four fixtures are the controls that guard the probe.
- Fixtures: `AMEND-011` (8 cases, hand-written expectations): `fail` and `pass` (a record-bearing amendment of `plan.md` with its blob truncated, and the readable twin), `fail-name-status`/`pass-name-status`, `fail-tick-blob`/`pass-tick`, `fail-lite-show-record`/`pass-lite-show-record`. I first chose `AMEND-010`, which was already an exempted rule (the metadata-parse site), so this rule is `AMEND-011` (the plan names per-read ids `GITREAD-004..010`; as in phase 1 the harness inventories emission sites, so the reads are variants of one rule). **Two predictions of mine were wrong and were corrected by hand from the code's order**: for an amended `plan.md` the first failing read is the BLOB read (`git show <sha>:<path>`, exit **255**) made by the status-only check, not `git show -U0` (128), so `git show -U0` (G8) has no fixture state either.
- Reachability, as in phase 1's probe: fixtures reach G5 (a subtree of a middle commit, `truncateCommit` naming `HEAD~1:specs/001-thing`) and G7 (blobs of `plan.md` and `tasks.md`). G4, G6, G8, G9 and G10 read objects a successful read has just read, so they are guarded by injected failures (Amendment 1).

### Mutations (T011)

Fixture-caught, over `-Case AMEND-011`, script restored byte for byte (hash compared):

| Mutation | Result |
|---|---|
| P1 the failure is never recorded | caught: `fail`, `fail-lite-show-record`, `fail-name-status`, `fail-tick-blob` |
| P2 the refusal is never printed | caught: the same four |
| P3 the check after the name-status batch dropped | **not caught**: equivalent for these fixtures (the check at the top of the first commit prints the same refusal from the same flag) |
| P4 the amended-stage check dropped | **not caught alone**; Q2 below |
| P5 the flag is not cleared after printing | **not caught**: equivalent (the walk returns right after the refusal; the clear is hygiene for a second invocation) |
| P6 last failure wins instead of first | **not caught**: no fixture has two failing reads inside one stage |
| Q2 amended-stage AND verdict-stage checks both dropped | shown by hand: the wrong-cause `no conforming approver record` failure prints beside the refusal, so `AMEND-011/fail` would differ |
| the `ls-tree` absent probe dropped | caught by the four deleted-document merge fixtures (the regression above) |

Injected failures (Amendment 1), each read made to fail by pointing it at a missing ref, on a real fixture repository, the site must name it:

| Injection | Fixture repository | Result |
|---|---|---|
| E4 metadata batch (G4) | `AMEND-001/pass` | `cannot grade '001-thing' - git log of <base>..HEAD failed (git exited 128) ...` |
| E5 range rev-list (G6) | `AMEND-001/pass` | `... git rev-list of <base>..HEAD failed (git exited 128) ...` |
| E6 `git show -U0` (G8) | `AMEND-001/pass` | `... git show -U0 of adf7334 -- specs/001-thing/plan.md failed ...` |
| E7 rename `rev-parse` (G9) | `AMEND-001/fail-rename-content` | `... git rev-parse 8042218:specs/001-thing/contracts/api-v2.md failed ...` |
| E8 renumbering `ls-tree` (G10) | `AMEND-001/fail-other-feature-single-doc-moved` | `cannot grade '002-b' - git ls-tree of 7338950 -- specs/001-a failed ...` |
| E6 + verdict-stage check dropped | `AMEND-001/pass` | the wrong-cause failure prints beside the refusal (so the verdict-stage check is what stops it) |

### AI review of phase 2 (fresh-context agent, `ai-code-review-phase2.md`): APPROVE with follow-ups

- **F1 (DOC DRIFT), fixed**: the `AMEND-011` recipe descriptions and the rule note named `git show -U0` (G8) and exit 128; the expectations (right) show the blob read, exit 255. Descriptions and the note corrected; a dangling twin name removed.
- **F2 (DOC DRIFT), recorded**: T009/T010 name `GITREAD-004..010` while the work used one rule, `AMEND-011` (the id note above; the task text is not amended, the id is a label). T011 asks for the amendment check's `LIMITS` comments to be updated: none changed, because the script has no comment that describes these reads as unchecked (the same finding as phase 1); T011 stays ticked on that reading, and the statement of the limit is `adoption/updating.md`, phase 5.
- **F3 (CONFIRM), resolved by Amendment 2 (approved by anas.m, 2026-10-16)**: the injection-only guards for G8, G9 and G10 are cited to plan Amendment 1, which names G2, G3, G4, G6, G12, G14a. G8, G9 and G10 are the same class found later (no data state reaches them: they read objects a successful read has just read, or run only after the blob read that already failed). They need the owner's approval as a short Amendment 2, or fixtures if the owner prefers; the author does not approve it.
- **F4 (MINOR)**: P6 (last failure wins) and the `$null -eq $null` arm of G9 have no guard that CI runs; P3 and P5 are equivalent, as stated above.
- **F5 (MINOR)**: the check after the name-status batch and the amended-stage check are redundant with later ones; harmless, kept for early refusal.
### Correction to phase 2 after the full harness (the first phase 2 commit `02a065d` was broken)

- **What was wrong.** The full harness on an isolated checkout of `02a065d` gave **1726 passed, 6 failed**, in five pre-existing fixtures: `DIFF-001/fail`, `DIFF-001/fail-with-review-file`, `DIFF-002/pass`,
  `AMEND-009/fail-lite-failure-kept-beside-refusal` and `AMEND-009/fail-lite-unreadable-merge-parent`. The wider-family run I started before the commit had been stopped after its first family, so
  `DIFF-` and `AMEND-009` were never run on the phase 2 code before it was committed, and the AI review (which ran `AMEND-011`) did not run them either. The cause was the name-status check: it refused
  at a boundary BEFORE the walk, so (a) a damaged-subtree branch whose commits are all pre-boundary lost its `graded 0 of N` line, and (b) **027's pinned behaviour, a genuine amendment failure kept
  beside a refusal on the Lite lane, was lost** (`fail-lite-failure-kept-beside-refusal` exited 0 where it exits 1): a real fail-open on a damaged repository.
- **The owner's report.** The owner reported "both exit 0" for the phase 2 gate on `da6b16f` or later; the isolated run above says the harness cannot have been green at that state. The discrepancy is not
  explained here (a gate run on another state, or on a subset, are the possibilities I can name); **that report is not recorded as certifying phase 2**. A new commit follows, and the gate is asked again on it.
- **The fix.** `Get-NameStatusBatch` keeps the rows git printed before it failed (`Read-GitLines -KeepPartial`; git builds a commit's whole output before printing it, so the commit it fails on prints
  nothing, shown on `AMEND-009`'s fixture); the walk grades the commits that have a record, notes a graded commit with none, and refuses **after the walk** (`git log --name-status of <range> failed ...`)
  unless a refusal of its own already ended the walk. All five fixtures pass unchanged (no expectation was edited); `AMEND-009` 74, `AMEND-011` 78, `DIFF-` 86 passed.
- **Mutations of the new logic** (script restored byte for byte): R1 partial rows discarded: caught by `AMEND-009/fail-lite-failure-kept-beside-refusal`; R2 the after-walk refusal dropped: caught by
  `AMEND-011/fail-name-status`; R3 a missing record never noted: caught by `AMEND-011/fail-name-status`. The earlier mutation P3 (the check after the batch) no longer applies: that check is gone.
- **Lesson.** Run the families whose fixtures damage a tree or blob (`DIFF-`, `AMEND-`) on the phase code BEFORE committing, and do not stop a run to commit.

### AI review of the phase 2 fix (fresh-context agent, `ai-code-review-phase2-fix.md`) and the close-out count

- **Verdict: APPROVE with follow-ups.** The reviewer ran the families on a detached worktree of `92c2371`: DIFF- 86, AMEND- 288, GITREAD- 74, LITE- 122, CRIT- 228, MICRO- 100, PHASE- 88, PACK- 78,
  PROV- 86: **1150 passed, 0 failed**. The five fixtures that `02a065d` broke pass on their original expectations (no `expected.txt` is in `git diff 02a065d 92c2371`).
- **Full harness on an isolated checkout of `92c2371`: 1732 passed, 0 failed, 0 skipped** (parent 1704, +12 for phase 1's six cases, +16 for phase 2's eight: matches the case counts).
- **F1 (MINOR), closed by a probe**: could a record whose header git printed but whose rows it did not finish be graded as complete? The reviewer probed one damage mode; the implementer probed five on throwaway
  repositories with auto-maintenance disabled (an earlier probe run had packed the objects and damaged nothing, so it was discarded): the subtree of a middle, the newest and the oldest commit (30 commits of 200 files,
  6 KB per record, beyond the pipe buffer), a damaged blob hit by rename detection, and a side commit's subtree inside a merge range. In every mode git printed only COMPLETE records (**0 incomplete records
  in all five**; for example 14 of 30 records printed when commit 15 failed): it builds a commit's whole output before printing it. A damaged commit object breaks the walk before any output. So the
  "keep the partial rows" claim holds and no further hardening is added.
- **F2 (ACCEPTED)**: when every commit without a record is a root, merge or pre-boundary commit, nothing is refused; those commits need no rows. **F3 (DOC DRIFT)**: R2 and R3 share one fixture
  (`AMEND-011/fail-name-status`), so they are not independent guards; recorded, not split. **F4 (MINOR)**: the label changes of the earlier round are cosmetic; the exit code 255 is the one measured in the probe table. **F5 (DOC DRIFT)**: `ai-code-review-phase2.md` approved `02a065d`;
  this file and the correction section above supersede it for the final state of phase 2.
- **The owner's gate for phase 2** on `92c2371` (the state the counts above describe) is still to be confirmed; the earlier report ("both exit 0") predates the fix and is not recorded as certifying.

## Phase 3: the Critical-arm and surface-exception reads (G11, G12)

### Baseline (T014)

- Parent of the phase: `1d5613a` (documents on top of `92c2371`); the full harness on `92c2371` is **1732 passed, 0 failed**.
- Reproduced on the parent by the new fixture: a Critical solo feature whose second-model review is committed 24.5 hours ago (past the window) with the tree of its feature directory unreadable
  (`git log --follow` exits 128) fails with `CriticalEvidence: ... has no git history - cannot verify the cooling-off period (commit it to start the clock)`: a wrong cause (the file IS committed) that sends the owner
  to commit a file that is committed (G11). The parent output differs from the expectation in exactly that one line.

### What was built (T015-T017)

- `scripts/enforcement-pack.ps1`: `Invoke-CriticalSoloEvidence` reads `git log --follow` through `Read-GitLines`; a failed read is `Add-GitReadUnreadable` (the numbered lane: `GitReadUnreadable: git log --follow of
  <dir>/second-model-review.md failed on '<b>' (git exited N), so the cooling-off period of the independence review could not be verified - ...`). `Get-SurfaceExceptions` reads `git log -1` through it; a failed read is an
  advisory `UNGRADED: LevelSurface: git log of HEAD could not be read (git exited N), so a Surface Exception was dated against the runner's clock, not the author's day` on every lane, and the author's-day-else-clock fallback
  stays for git printing no date. No new emission site: both reuse the two sites of phase 1 (`GITREAD-001`, `GITREAD-002`), so `rules.json` changes only their notes (the plan's `GITREAD-011`/`-012` ids are labels, as in phases 1 and 2).
- Fixtures: `GITREAD-001/fail-cooling-off-history` and `pass-cooling-off-history` (the readable twin: the review 24.5 h old, OK), expectations hand-written. The fail case also prints 028's `DiffUnreadable` (the damaged tree breaks the diff
  too) and the phase 1 `PhaseSizeWarning` UNGRADED line; the only new line is the named read. G12 has no fixture (Amendment 1).

### Mutations and injection (T018)

| Mutation | Caught by |
|---|---|
| S1 the cooling-off read failure ignored (falls to "no history") | `GITREAD-001/fail-cooling-off-history` |
| S2 the cooling-off failure printed as an advisory UNGRADED line | `GITREAD-001/fail-cooling-off-history` |
| E9 injected: `git log` of HEAD made to fail on `LEVEL-005/pass` (G12) | `UNGRADED: LevelSurface: git log of HEAD could not be read (git exited 128), so a Surface Exception was dated against the runner's clock, not the author's day`, verdict UNGRADED |

Script restored byte for byte after each (hash compared). Before the commit, on the working tree: `-Case GITREAD-` 78 passed, `-Case CRIT-` 228, `DIFF-` 86, `AMEND-` 288; the rest of the families were stopped to commit (a lesson of phase 2:
the count that counts is the full harness on an isolated checkout of the commit, recorded below).

### AI review of phase 3 (fresh-context agent, `ai-code-review-phase3.md`): APPROVE with follow-ups

- **Families run by the reviewer** on a detached worktree of `1554148`, one at a time, all exit 0: GITREAD- 78, CRIT- 228, LEVEL- 194, DIFF- 86, AMEND- 288, LITE- 122, MICRO- 100, PHASE- 88, PACK- 78, PROV- 86: **1348 passed, 0 failed**.
  The reviewer also re-ran S1 (the G11 failure branch disabled: `GITREAD-001` 73 passed, 1 failed, the fail fixture) and made the G12 read fail (all 3 `LEVEL-005` cases fail, so the existing `LEVEL-` fixtures notice any change on that path,
  which is more than the injected-failure check above claims); the old `has no git history` message for an uncommitted review file is byte-identical (`CRIT-S02/fail` unchanged).
- **F1 (MINOR)**: the G12 UNGRADED line prints whenever the date read fails, even if the spec has no Surface Exception (the read happens before any exception is looked for); advisory, near-unreachable, kept.
- **F2 (DOC DRIFT)**: T015 and T017 are ticked but there is no G12 fixture (plan Amendment 1) and no `LIMITS` comment changed (none describes these reads as unchecked); the substance is met, as recorded above.
- **F3 (ACCEPTED)**: the fail fixture also pins 028's `DiffUnreadable` line and phase 1's `PhaseSizeWarning` UNGRADED line; brittle coupling, but the guard bites and the readable twin is meaningful.
- **F4 (MINOR)**: both functions read `$Branch` by dynamic scope without declaring it; a future caller without it would downgrade the G11 failure to UNGRADED. Unreachable today (the dispatch always sets it); not changed.
- **F5 (MINOR)**: the reviewer did not re-run S2 or check the restore hash; the implementer's hash check is recorded above.
- **Still open for phase 3**: the full-harness count on an isolated checkout of `1554148` (running) and the owner's gate.

### Owner's gate for phases 2 and 3

- **Owner's gate** (anas.m, 2026-10-16), run once on the current tip of `029-unchecked-git-reads-named-state` (`4aa9b45`, which contains `92c2371` for phase 2 and `1554148` for phase 3): `tests/enforcement/Run-Tests.ps1` exit **0** and
  `scripts/ritual-checks.ps1` exit **0**, as reported by the owner. This certifies phase 2 in its final state (the earlier report of exit 0 predated the fix and is not the certifying one) and, with the isolated full-harness
  count below once recorded, phase 3. T013 is ticked on it; T019 awaits the isolated count of `1554148`.

### Phase 3 close-out (T019)

- Full harness on an isolated checkout of `1554148`: **1736 passed, 0 failed, 0 skipped** (1732 on `92c2371` plus the two new `GITREAD-001` cases at two expectations each). The owner's gate for phases 2 and 3 is recorded above (both exit 0, on `4aa9b45`).

## Phase 4: `scripts/territory-check.ps1` (G13, G14)

### Baseline (T020)

- Parent of the phase: `a82fa24` (documents on top of phase 3's `1554148`); full harness **1736 passed, 0 failed**. The territory cases are under `tests/enforcement/cases/territory-check/` (confirmed).
- Reproduced on the unchanged script by the new fixtures: (a) an open branch whose diff cannot be read (`TERR-025/fail`: the tree of `src` on `012-other` truncated, the two branches sharing `src/shared.txt`) prints **CLEAN**, a missed
  real overlap; (b) a branch under check whose working-tree diff cannot be read (`TERR-023/fail`) prints **CLEAN**.
- **Two things the first fixture design got wrong, found by running it** (not predicted): `truncateBlob` silently does nothing when the object is not loose (it has no error branch), so `truncateCommit` naming `HEAD:src/shared.txt` is used
  to prove the damage lands; and `git diff --name-only HEAD` reads the committed blob only when the working copy is stat-dirty AND the same length as it (`diffcore_skip_stat_unmatch`) and the fixtures run with `core.autocrlf false` (this machine's
  global config is `true`, under which git reads the blob in more states, which is why a scratch probe failed where the fixture did not). So the fixture edits the working copy to the same length (`mine\n` to `mind\n`).

### The four exit paths (T021, plan D6)

| Read | On failure | Output | Exit |
|---|---|---|---|
| own committed diff `main...HEAD` (existing, TERR-011) | refusal | `Cannot diff main...HEAD ...` | 1 |
| own uncommitted diff `git diff --name-only HEAD` (G13a, new) | refusal | `Cannot read the uncommitted changes of '<b>' - git diff --name-only HEAD failed (git exited N), so the branch's own uncommitted files would drop out of the overlap check.` | 1 |
| `git ls-remote --heads origin` (G13b, new) | refusal | `Cannot list the open feature branches - git ls-remote --heads origin failed (git exited N), so no open claim would be compared.` | 1 |
| another branch's `git diff main...origin/<other>` (G14b, new) | an `ungraded` record, cause `diff-failed`, the branch still compared in the code repositories | `UNGRADED: governance: cannot compare <other> (git diff of main...origin/<other> failed, git exited N)`, then the run-level UNGRADED line | 0 (2 if a live overlap is found elsewhere) |
| another branch's `git log -1 --format=%ct` (G14a, new) | an `ungraded` record, cause `last-commit-failed`, the branch NOT compared (an epoch of 0 would call it stale) | `UNGRADED: governance: cannot compare <other> (git log of origin/<other> failed (git exited N))` | 0 (2 on a live overlap) |

No exit code is new and no kit verdict word is added (GAP-029 stays open).

### What was built (T022-T024)

- `scripts/territory-check.ps1`: the four reads above check their exit codes (the file's working copy was CRLF while the repository stores LF, hidden by a stale stat cache; it was normalised to LF so the commit diff is the 21 lines of the change). `Read-CodeRef` and the other named paths are not edited.
- Fixtures (hand-written expectations): `TERR-023/{fail,pass}` (G13a; the twin is readable, CLEAN) and `TERR-025/{fail,pass}` (G14b; the twin is readable and finds the overlap, exit 2). Rules in `rules.json`: `TERR-023` and `TERR-025` with fixtures, and `TERR-024` (G13b) and `TERR-026` (G14a) as written exemptions.
- **Resolved by Amendment 3 (approved by anas.m, 2026-10-16):** G13b (`ls-remote`) is NOT among the reads plan Amendments 1 and 2 name. It has no reachable state either: it fails only after `git fetch origin --prune` succeeded against the same remote, and a fixture that broke it
  would break the fetch (TERR-010) first. It is guarded by an injected failure (below) and `TERR-024` carries the written exemption, but the author cannot approve that exemption: it needs the owner's approval as a short Amendment 3 (G14a is covered by Amendment 1).

### Mutations and injection (T025)

| Mutation | Caught by |
|---|---|
| U1 the uncommitted-diff failure ignored (G13a) | `TERR-023/fail` |
| U2 the other-branch diff failure not recorded (G14b) | `TERR-025/fail` |
| U3 a diff failure also drops the branch's code-repository comparison (`continue`) | **not caught**: no fixture declares code repositories alongside a damaged governance diff, so "the code repositories are still compared" is not shown |
| E10 injected: `ls-remote` made to fail (G13b), on `TERR-002/fail` | `Cannot list the open feature branches - git ls-remote --heads origin failed (git exited 128), ...`, exit 1 |
| E11 injected: the tip's `git log -1` made to fail (G14a), on `TERR-002/fail` | `UNGRADED: governance: cannot compare 012-other (git log of origin/012-other failed (git exited 128))`, exit 0 |

Script restored byte for byte after each (hash compared). Before the commit, on the working tree (the families run before it was stopped to commit): `TERR-` 208 passed, `RIT-` 264, `REPOS-` 204, 0 failed. The full harness on an isolated checkout of the commit is recorded below when it finishes.
