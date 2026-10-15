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