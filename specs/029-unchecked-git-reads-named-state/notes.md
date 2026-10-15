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
