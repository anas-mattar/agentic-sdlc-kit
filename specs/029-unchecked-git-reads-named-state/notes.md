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
