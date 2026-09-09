# AI Code Review — 012 Cross-Repo Scope-Check Reach (phase 1)

**Reviewer**: fresh-context agent — `claude-opus-5[1m]`
**Date**: 2026-09-09
**Branches**: `agentic-sdlc-kit` `012-cross-repo-scope-check` (commit under review `56c0068`; branch tip at review time `714ff75`)
**Scope reviewed**: `git show 56c0068` in full, then the resulting files read end-to-end — `scripts/scope-lib.ps1`, `scripts/scope-check-repos.ps1`, `scripts/scope-check.ps1`, `scripts/ritual-checks.ps1`, `specs/012-cross-repo-scope-check/contracts/scope-check-repos-cli.md`. Plus `spec.md`, `plan.md`, `research.md`, `tasks.md`, `CLAUDE.md`, `docs/sdlc/definition-of-done.md`, `docs/sdlc/review-process.md`. Behaviour probed by executing both graders against the seeded `fx` fixtures and four fixture sets built by the reviewer (`fx2`, `fx3`, `fx4`, `c8`/`c8b`).
**Feature contract**: read-only; zero new dependencies; PowerShell 7 only; backward compatible — no adopted project's CI may turn red (SC-004); the extraction into `scope-lib.ps1` must be behaviour-preserving for `scope-check.ps1`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — `claude-opus-5[1m]`
- **Implementer**: the session that authored `56c0068` (commit trailer: `Co-Authored-By: Claude Opus 5 (1M context)`) — a different session; none of its conversation, reasoning or notes were available to the reviewer.
- **Inputs provided**: commit sha `56c0068` and its diff, `spec.md`, `plan.md`, `research.md`, `tasks.md`, `contracts/scope-check-repos-cli.md`, the governing law documents, and a seeded fixture set.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — The extraction is clean and verifiably behaviour-preserving, the inertness contract holds in every malformed/absent configuration constructed, and the core grading logic is correct on the happy paths (repo-prefixing discriminates `api` from `api-v2`, renames and deletes are graded on both sides, timezone offsets resolve correctly, anti-retroactivity works in both directions on a clean history). But the D4 declaration-resolution mechanism has a false-negative that is reachable by **merging `main` into the governance feature branch** — the single most routine branch-hygiene action there is — and by governance CI's own `pull_request` merge HEAD (F1). When it fires, a real FAIL becomes a non-blocking WARN and gate 4 is silently off, which is exactly the "looks like a gate but isn't" failure the spec says is worse than no gate. Separately, the spec's own US2 acceptance scenario 2 / FR-004 (a code commit predating its declaration MUST FAIL) is not implemented — it WARNs — so the anti-retroactivity rule is defeated by simply committing the code before declaring the territory (F2). Residual risk concentrates entirely in declaration resolution; the matching/parsing half of the check is sound.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-001/002/003(partly)/005/006(partly)/010 exercised on fixtures — see Test coverage. **FR-004 not met** (F2); **FR-003 "without divergence" not met on the Micro lane** (F3). FR-007/008/009 are phases 2–3, out of scope here. |
| Visual-reference match | N/A — no `specs/012-cross-repo-scope-check/screenshots/`; PowerShell + Markdown only. |
| Feature contract held (no unapproved table/migration/permission/package) | Diff is 5 files, all PowerShell/Markdown. No package manifests, no network calls, no writes: every `git` invocation in `scope-check-repos.ps1` is `rev-parse`/`rev-list`/`show`/`log`/`merge-base` (read-only). Verified by reading all 311 lines. |
| Constitution / domain invariants | III Repository Separation held — nothing is written into any code repository; the grader only reads sibling trees. IV — dot-sourced library approved in plan D6. VII — contract `contracts/scope-check-repos-cli.md` is committed in this same commit alongside the implementation (see F8 note). |
| Security (authn/authz, secrets, sensitive logging) | No credentials, no secrets, no network. One note: `Join-Path $Root $repoName` with an unvalidated `codeRepos` entry can address a directory outside the governance root (F7) — read-only, so no write-side exposure. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | `pwsh -File scripts/ritual-checks.ps1 -Branch 012-cross-repo-scope-check` → `scope-check: PASS phase 1 commit 56c0068 (5 file(s))`, `ritual-checks: RESULT OK`. Files touched: the four scripts named in the phase-1 Territory block plus `specs/012-cross-repo-scope-check/contracts/…` (implicit spec-dir entry). Nothing unrelated. |
| Rollback safety | Reverting `56c0068` restores `scope-check.ps1`'s helpers inline and drops the `scope-repos` member — no state, no schema, no generated artifacts. Clean revert. |

Commands run (all read-only against the repo; all writes confined to the scratchpad):

```bash
git show 56c0068 --stat ; git show 56c0068 -- scripts/scope-check.ps1 scripts/ritual-checks.ps1
git show 56c0068^:scripts/scope-check.ps1 | sed -n '83,182p' | diff - <(sed -n '24,119p' scripts/scope-lib.ps1)
pwsh -File scripts/ritual-checks.ps1 -Branch 012-cross-repo-scope-check
# behaviour preservation: old vs new scope-check over 26 commits + -All
# contract scenarios C1–C11 on the seeded fixtures; C8 both directions on copies c8, c8b
# adversarial set fx2: stray-before-declaration, stray-after, TZ -0800, rename-out,
#   api vs api-v2, merge of main into the governance branch, CI detached-HEAD checkout
# fx3: Micro feature with no Territory block; fx4: code repo whose trunk is 'develop'
# inertness: missing / malformed / string / null / empty / traversal codeRepos
```

## Findings

### F1 — Declaration resolution walks the whole reachable graph, so merging `main` silences gate 4 — BLOCKING

`Get-BlobAsOf` asks for *the newest reachable commit at or before the code commit's date*, with no restriction to the line of history that carries the declaration and no restriction to commits that touch the declaration file. `git rev-list` returns the newest commit **by date across every reachable parent**, so as soon as the governance feature branch contains any commit from `main` dated between the declaration and the code commit, that commit wins — and it does not contain `specs/<branch>/tasks.md`. The caller then reports a **non-blocking WARN** instead of grading.

Reproduced on fixture `fx2`. Governance `020-x` declares `` `api/src/**` `` at 2026-09-02; `api`'s phase-1 commit adds `STRAY-LATE.txt` on 2026-09-04. Before merging main:

```text
scope-repos: api: FAIL phase 1 commit a9f9a8b: api/STRAY-LATE.txt not in territory      exit=1
```

Then the developer does the most ordinary thing on the governance branch — `git merge main`, dated 2026-09-05, where `main` had an unrelated `docs:` commit dated 2026-09-03:

```text
scope-repos: api: WARN phase 1 commit a9f9a8b: no specs/020-x/tasks.md in the governance
  repository as of 2026-09-04T10:00:00+08:00 (…non-blocking)                            exit=0

# why: git -C gov rev-list -1 --before="2026-09-04T10:00:00+08:00" 020-x
#      -> 440df28 2026-09-03T10:00:00+08:00 docs: unrelated main commit   (no tasks.md)
```

The same FAIL→WARN flip reproduces in a simulated governance CI checkout, and a `pull_request` checkout is always such a merge. The failure is silent in both directions: `ritual-checks` prints the member as `OK`.

Both candidate fixes resolve the fixture correctly:

```text
git -C gov rev-list -1 --before="…" 020-x -- specs/020-x/tasks.md   -> 39a33e9 plan: 020  OK
git -C gov rev-list -1 --first-parent --before="…" 020-x            -> 39a33e9 plan: 020  OK
```

*Action: implementer — resolve the declaring commit **by path**, keeping the `$null` → WARN fallback for the genuine "file never existed yet" case. Add a fixture scenario that merges `main` into the governance branch after the code commit; this class of bug is invisible to C1–C11 because none of those fixtures has a second line of history.*

### F2 — A code commit that predates its declaration WARNs instead of FAILing: FR-004 / US2-AS2 unimplemented — BLOCKING (spec/contract conflict — owner must adjudicate)

`spec.md` FR-004: "a code phase commit older than the governance commit declaring its territory **MUST FAIL**", and US2 acceptance scenario 2 requires the output to state that the declaration post-dates the commit. The implementation never produces that verdict. When no declaration resolves as of the code commit's date, both the no-`tasks.md` path and the no-`**Territory**` path emit a non-blocking WARN.

On `fx2`, `STRAY-EARLY.txt` committed on 2026-09-01, before the 2026-09-02 declaration:

```text
scope-repos: api: WARN phase 1 commit 7f2c8fb: no specs/020-x/tasks.md in the governance
  repository as of 2026-09-01T11:00:00+08:00 … (non-blocking)                           exit=0
```

A developer who writes the code first and the territory afterwards gets a permanently green gate 4 for that commit. Under the Definition of Done conflict rule this is a conflict between `spec.md` (a higher rung) and `contracts/` — reported rather than silently resolved.

*Action: owner decides which document is wrong, then implementer aligns the other. If the spec stands (recommended), distinguish the two cases: declaration exists at the governance ref but not as of the commit → FAIL with US2's wording; declaration exists nowhere in governance history → WARN.*

### F3 — Micro lane with no usable Territory block: WARN here, FAIL in the in-repo grader (FR-003 divergence) — MEDIUM

`scripts/scope-check.ps1` treats a Micro feature with no usable `**Territory**` block as a hard FAIL. `scripts/scope-check-repos.ps1` routes the same condition into the shared Standard-lane branch and WARNs. Reproduced on `fx3`:

```text
scope-repos: api: WARN phase 1 commit 71054e0: no territory declared for phase 1 in
  specs/030-m/spec.md as of 2026-09-03T09:00:00+08:00 (non-blocking)                    exit=0
scope-check: FAIL phase 1 commit 192b09e: this Micro feature declares no usable
  **Territory** block in specs/030-m/spec.md …                                          exit=1
```

*Action: implementer — apply the in-repo rule in the Micro branch, with the promotion remediation. Record it as a contract scenario.*

### F4 — Default `-Commit HEAD` grades whatever the code repo is checked out on, including a different feature's branch — MEDIUM (false FAIL)

The dispatch confirms `refs/heads/$Branch` exists in the repository, then grades `HEAD`, which may be on an entirely different branch. Reproduced on `fx2` with `api` parked on `099-other`:

```text
scope-repos: api: FAIL phase 1 commit 5fdc72a: api/QUARANTINE.txt not in territory       exit=1
```

The mirror risk is a false PASS when that other branch's tip happens to sit inside the territory.

*Action: implementer — default to the feature branch's tip; honour `-Commit` only when the caller passes it.*

### F5 — `-All` (the mode `ritual-checks` and CI use) checks nothing when the code repo's trunk is not `main` — MEDIUM

The merge base is resolved against `origin/main` then `main` only; failing both it WARNs and continues with exit 0. Code repositories are pre-existing independent repositories that frequently use `master` or `develop`. Reproduced on `fx4`:

```text
-All            : WARN could not resolve a merge base with main - nothing checked   exit=0
single-commit   : FAIL phase 1 commit df81875: api/STRAY.txt not in territory       exit=1
```

*Action: implementer — widen the candidate list and/or add a `-BaseRef` parameter; make "no merge base" louder, since it means the CI mode graded nothing.*

### F6 — `ritual-checks` reports `OK`, not `n/a`, in the governance-CI case FR-006 names — MINOR

The wrapper reads a member's n/a reason with `^scope-repos: n/a`. When `codeRepos` are declared but no tree is present, every n/a line is repo-prefixed and the run-level line reads "nothing to grade…", so the summary prints `OK`. Exit codes are correct (SC-004 holds); this hides "gate 4 graded nothing today" behind a green OK.

*Action: implementer — make the run-level line n/a-shaped.*

### F7 — `codeRepos` entries are used unvalidated as path segments — MINOR

`"../elsewhere"` addresses a directory outside the governance root and `"a/b"` a nested one; a non-array value is silently coerced. Everything downstream is read-only, so the blast radius is a wrong verdict, not damage. T009 puts this validation in the doctor, but the grader ships now and a code repo's CI may never invoke the doctor.

*Action: implementer — guard in `Get-DeclaredRepos`, belt-and-braces with T009.*

### F8 — Contract omits the ERROR verdict the script actually emits — DOC DRIFT

The verdict table lists PASS / not applicable / n/a / WARN / FAIL; the script emits a sixth shape, `ERROR`, in three places that all exit 1. Also: §4 says the feature's own spec directory "is implicitly in territory, as in the governance check" — the cross-repo grader does not add that implicit entry at all (correctly, since it would be inert).

*Action: implementer — add the ERROR row and reword §4.*

### F9 — Phase-size guideline exceeded — MINOR (owner awareness, gate 2)

`enforcement-pack`: `PhaseSizeWarning: commit 56c0068 changes 634 line(s) across 5 file(s) — exceeds the phase-size guideline (400 lines / 15 files, constitution X). Non-blocking`. The feature is Standard and ~100 of those lines are the pure move into `scope-lib.ps1`, so the slice is coherent.

*Action: owner — note and accept, or split.*

## Constitution re-check (post-implementation)

**PASS with the F1/F2 caveats.**

- **I Specification First** — satisfied; spec/plan/tasks/research and the CLI contract all precede the implementation commit in branch history.
- **II Source of Truth** — engaged unfavourably: the ladder places `spec.md` above `contracts/`, and F2 is the code following the contract where the contract contradicts the spec. Reported, not chosen between.
- **III Repository Separation** — satisfied and strengthened.
- **IV Architecture Consistency** — satisfied; the dot-sourced library was approved in plan D6.
- **V Domain Invariants** — N/A.
- **VI Security** — satisfied; F7 is a robustness note, not an exposure.
- **VII External Integration Governance** — satisfied in substance (F8 aside).
- **VIII Testing Requirements** — the principle under strain: every fixture has a single linear governance history, which is precisely why F1 survived them.
- **IX Human Review** — this review satisfies the fresh-context half; human review remains owed at merge.
- **X Controlled Delivery** — one phase, independently revertible; batching and ci-held declared before phase 1.

## Test coverage observed

- **Contract C1–C11 against the seeded fixtures**: all eleven reproduce exactly as recorded, including message text. **The recorded verdicts are honest.**
- **C8 in both directions**: widening after the code commit leaves it FAIL exit 1; the identical widening dated before it flips to PASS exit 0. D4 is genuinely enforced on a clean history.
- **Behaviour preservation of the extraction**: the removed block and `scope-lib.ps1` are byte-identical in executable code (only comment strings gained a `006` qualifier). Pre- and post-commit `scope-check.ps1` compared over **26 commits** spanning the Standard and Micro paths plus `-All`: **26 identical, 0 differ**. `$PSScriptRoot` portability confirmed from an unrelated cwd.
- **Inertness (SC-004)**: exit 0 in every configuration constructed — no record, malformed JSON, null, empty, string, traversal. Full `ritual-checks` in the kit repo: `scope-repos n/a`, `RESULT OK`.
- **Adversarial grading**: prefix-sibling repository names, rename out of territory, distant-timezone committer date, stray after declaration — all correct.
- **Not covered by any fixture, and the source of F1**: a governance history with more than one line of ancestry. Also uncovered: non-`main` trunk (F5), code repo on another branch (F4), Micro without Territory (F3).

## Residual risk

The risk sits entirely in **declaration resolution**. `scope-lib.ps1` is the same code that has graded this repository since 006 and is verifiably unchanged; the repo-prefixing scheme is simple and could not be broken. What is new and unproven is the date-based reach across repository boundaries, and both blocking findings live there. Their shared signature is a **silent downgrade to WARN with exit 0**, which reads as a green gate. Until F1 and F2 are fixed, an adopter enabling `codeRepos` would be entitled to believe gate 4 covers their code when, on a branch that has merged `main`, it does not. Because `Gate Certification: ci-held` is declared, the batch-end evidence triplet must be recorded on the **post-remediation** batch-end commit. This reviewer makes no claim about the gate; that certification is the owner's.
