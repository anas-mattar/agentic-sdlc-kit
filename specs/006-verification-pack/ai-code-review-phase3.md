# AI Code Review — 006 Verification Pack (Phase 3: Ritual Checks as CI)

**Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
**Date**: 2026-09-08
**Branches**: agentic-sdlc-kit `006-verification-pack` (tip `8fd95f6`)
**Scope reviewed**: `git show 7597c5d` / `f548b1b` / `d02c36f` (full diffs); `scripts/ritual-checks.ps1` (all 63 lines); `.github/workflows/ritual-checks.yml`; deleted `.github/workflows/doc-lint.yml` + `enforcement-pack.yml`; `docs/sdlc/branch-protection.md`; `adoption/greenfield.md`; `adoption/existing-system.md`; param blocks and dispatch of `scripts/doc-lint.ps1`, `scripts/enforcement-pack.ps1`, `scripts/scope-check.ps1` (full read of scope-check); `specs/006-verification-pack/` spec.md (US3, FR-007/008/009, SC-004), plan.md, research.md D5, contracts/ritual-checks-ci.md, quickstart.md R1–R4, tasks.md (territory + amendment note, T015–T021, Phase 3 validation); `kit-manifest.json` glob rows; repo-wide grep for the superseded workflow filenames and check names; live GitHub evidence via `gh run list` / `gh run view` (runs 34144751539, 34145125813, 34145110674) and `gh api …/branches/main/protection`; read-only wrapper execution on this branch and in a scratch repo whose path contains spaces.
**Feature contract**: doc+script phases only, no application code, no new dependencies

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
- **Implementer**: Claude Fable 5 (main session that produced commits 7597c5d/f548b1b)
- **Inputs provided**: phase 3 commits (7597c5d, f548b1b, d02c36f) and their full diffs; spec.md, plan.md, research.md, contracts/ritual-checks-ci.md, quickstart.md, tasks.md; the three member scripts; kit-manifest.json; live CI run logs and branch-protection settings via read-only `gh`; two local read-only wrapper executions (kit repo; scratch repo with spaces in the path)
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups** — the phase delivers exactly what the contract specifies: a 63-line wrapper that runs all three member scripts as child pwsh processes without ever short-circuiting, aggregates exit codes correctly, and prints the contracted verdict block; and a workflow that runs the identical command, proven live by three verified CI runs including a byte-identical local/CI FAIL verdict (R3-red). The doc amendments are accurate. Two things stand between this and a clean merge: the kit repository's **own branch protection still requires the two check names this commit deleted** (F1 — merge is mechanically impossible until the owner performs the migration the new docs themselves prescribe), and the workflow re-ships a known GitHub Actions script-injection anti-pattern (`${{ github.head_ref }}` interpolated into `run:`) in a public repo with a `pull_request` trigger, now in a verbatim file that will flow down to adopted projects (F2). Residual risk sits in repository configuration and in the flow-down surface, not in the wrapper logic.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-007: workflow triggers on `[0-9][0-9][0-9]-*`, `fix/**`, `chore/**`, `docs/**` + PR into main; character-class pattern proven live (pushes of `006-verification-pack` and `998-ci-red-demo` both triggered — runs 34144751539, 34145125813). FR-008: ran `pwsh -File scripts/ritual-checks.ps1` locally on this branch → 3 OK lines + `RESULT OK`, exit 0; CI log of run 34145125813 shows the same wrapper, and its FAIL line `scope-check: FAIL phase 1 commit 04bda2b: demo/stray.txt not in territory` matches the tasks.md evidence verbatim (extracted from `gh run view 34145125813 --log-failed`). FR-009: `kit-manifest.json` rows `scripts/*.ps1` (line 36) and `.github/**` (line 35), both `verbatim`, cover the two new files; doc-lint's manifest sweep reports 62 classified in both local and CI runs; research D6 confirms no sync-list addition needed. SC-004: runs triggered with zero human initiation on every push |
| Visual-reference match | N/A |
| Feature contract held (no unapproved table/migration/permission/package) | Diff is 2 workflow deletions, 1 workflow + 1 script added, 4 doc amendments, tasks/contract bookkeeping. No dependencies (git + pwsh only), workflow `permissions: contents: read`, no secrets referenced |
| Constitution / domain invariants | Wrapper member order and verdict format match the contract exactly (`{0,-16}` padding, `RESULT FAIL (N of 3 member(s) failed)`). Never-short-circuits: demonstrated in a scratch repo where doc-lint AND enforcement-pack both failed and scope-check still ran (`RESULT FAIL (2 of 3 …)`, exit 1). All three members accept `-Root`; `-Branch` is appended only to the two scripts that declare it (doc-lint has no `-Branch` param — verified all three param blocks) |
| Security (authn/authz, secrets, sensitive logging) | `permissions: contents: read`, no secrets — minimal. But see F2: `github.head_ref` interpolation into `run:` on a PUBLIC repo (`gh repo view` → `"visibility":"PUBLIC"`) with a `pull_request` trigger |
| Scope guard (`git diff --stat` — only intended files) | f548b1b touches 9 files: all inside the amended territory (workflows via `.github/workflows/**`, wrapper, 3 governance docs, spec-dir files implicit). 7597c5d touches tasks.md only. `scope-check -All` on the branch: `PASS phase 3 commit 7597c5d (1 file(s))`, `PASS phase 3 commit f548b1b (9 file(s))`, observed directly. Amendment committed BEFORE the phase commit per the sanctioned path (00:43 vs 00:45) |
| Rollback safety (phase reverts cleanly; schema additive?) | Reverting f548b1b restores 002's two workflows and removes the wrapper; phases 1–2 scripts untouched by phase 3. Caveat: once branch protection is migrated to `ritual-checks` (F1), a revert re-orphans the required check — migration is one-way in practice |

## Findings

### F1 — Kit repo's live branch protection still requires the deleted check names; the feature's own merge is currently impossible — BLOCKING

`gh api repos/anas-mattar/agentic-sdlc-kit/branches/main/protection` returns `required_status_checks.contexts = ["doc-lint","enforcement-pack"]`. This commit deleted the only workflows that produce those two check names, so every new head SHA (including this branch's PR) will show them as "Expected — waiting for status" forever, and the merge button stays disabled. This is precisely the failure mode 002's own phase-3 review (F2 there) documented, and precisely what the new migration note in `docs/sdlc/branch-protection.md` warns about — the doc is right; the repository configuration action it prescribes has not been performed. Nothing in the diff is wrong; the diff and the live host configuration are out of step.
*Action: owner (repository admin) updates `main` branch protection before opening/merging the 006 PR: add `ritual-checks` (it has run — prerequisite satisfied), remove `doc-lint` and `enforcement-pack`. No code change.*

### F2 — Script injection surface: `${{ github.head_ref || github.ref_name }}` interpolated directly into `run:` — CONFIRM

`.github/workflows/ritual-checks.yml` line 36: `run: ./scripts/ritual-checks.ps1 -Branch "${{ github.head_ref || github.ref_name }}"`. GitHub expands `${{ }}` textually into the shell script before pwsh sees it; `github.head_ref` is attacker-controlled on `pull_request` events from forks, and this repo is public. Git refnames legally contain `$`, `(`, `)`, backticks and quotes, so a fork branch named e.g. `006-x$(curl …)` executes arbitrary code in the runner. GitHub's security-hardening guide names this exact pattern and prescribes env-var indirection (`env: RITUAL_BRANCH: ${{ … }}` then `-Branch $env:RITUAL_BRANCH`). Mitigations already present: `permissions: contents: read`, no secrets, ephemeral runner — blast radius on this public repo is low. But the pattern is inherited verbatim from 002's deleted `enforcement-pack.yml` and is now re-shipped in a **verbatim manifest file that flows down to adopted projects** (private repos, other workflow ecosystems), where the calculus is worse. This phase authored the file fresh and had the chance to close it.
*Action: owner decides — recommended: two-line fix (env indirection) before this file flows down via update-kit; the check name and behavior are unaffected.*

### F3 — Wrapper can short-circuit and lose the verdict block under `$PSNativeCommandUseErrorActionPreference = $true` — MINOR

`scripts/ritual-checks.ps1` sets `$ErrorActionPreference = 'Stop'` and invokes members via `& pwsh -File …` without `-NoProfile`. If a contributor's profile (or calling session) sets `$PSNativeCommandUseErrorActionPreference = $true` (a documented PS 7.4 knob), the first failing member throws `NativeCommandExitException` at line 48 — reproduced in a scratch repo: doc-lint failed, enforcement-pack and scope-check never ran, no verdict block printed. The failure stays fail-closed (non-zero exit), so CI safety holds and GitHub's runner has no profile, but the contract's "all members always run so one push reports every problem" breaks for exactly the local users FR-008 exists for. Separately verified as fine: the `& pwsh -File @(array)` argument flattening works correctly, including paths with spaces (scratch repo `…\kit with spaces` — child received script path and `-Root` intact) and with empty `$branchArgs`.
*Action: implementer adds `$PSNativeCommandUseErrorActionPreference = $false` beside the existing preference line (and optionally `-NoProfile` on the child invocations); one line, wrapper-local.*

### F4 — Trigger coverage narrows vs 002: no run on `main` itself; double-run on PR branches — MINOR

The deleted 002 workflows triggered on bare `push` + `pull_request` (every branch, including post-merge `main`); the new workflow covers only the four governed lane patterns plus PRs into main. Consequences: (a) post-merge `main` never runs doc-lint, so a semantically bad merge (two independently-green branches whose doc references conflict) surfaces only on the next feature branch — mitigated where the branch-protection recipe's `strict: true` ("require up to date") is applied; (b) a branch outside the four lanes gets no CI at all (enforcement-pack would fail it as an unrecognized lane, but only if something runs it); (c) a governed branch with an open PR runs the job twice per push (push + pull_request) — cost/noise only, both produce the `ritual-checks` context. All three follow the contract and FR-007 as written, so this is a design note, not a deviation.
*Action: owner considers adding `main` to the push branch list (doc-lint on trunk is cheap and was previously covered); otherwise none — spec-conformant.*

### F5 — Territory amendment broader than its stated need — MINOR

7597c5d widens phase 3 territory from `.github/workflows/ritual-checks.yml` to `.github/workflows/**`, and the amendment note says the phase "needs the directory glob rather than the single file." It doesn't: deleting the two named 002 workflows needs exactly two more named entries. The glob additionally licenses any workflow change in `.github/workflows/` for the rest of phase 3 without further approval — harmless here (only the three intended files were touched, verified in the diff), but the amendment mechanism's value is least-territory, and the first-ever use of the sanctioned amendment path sets precedent.
*Action: none for this merge (owner approved it and the diff stayed minimal); note for future amendments — name files when the need is enumerable.*

### F6 — T017 marked complete in f548b1b before its R3/R4 evidence could exist; phase 3 spans two `phase 3` commits — ACCEPTED

T017 requires verifying R3–R4 "on the actual GitHub check" of this branch's push, but it is checked `[x]` inside f548b1b — the very commit whose push creates that evidence. The follow-up commit d02c36f records the runs (all three IDs, statuses, and the R3-red verdict line verified against `gh` — accurate, including durations 18s/16s), which is the only causally possible ordering, but it makes a second `phase 3`-token commit against the "every phase ends in exactly one commit" convention (both pass scope-check via the implicit spec-dir territory; the precedent of `phase N fixes` commits already exists on this branch).
*Action: none — chicken-and-egg handled reasonably; owner may want the ritual docs to name "evidence commits" as a sanctioned pattern so this stops being ad-hoc.*

### F7 — Contract's "nothing else" step description drifted from the actual workflow step — DOC DRIFT

`contracts/ritual-checks-ci.md` Steps row: "checkout → `pwsh -File scripts/ritual-checks.ps1` — nothing else, so CI can never drift from the local command." The actual step (correctly, per the phase-1 detached-HEAD lesson) passes `-Branch "${{ … }}"` — a real, needed difference from the bare local command that the contract table doesn't acknowledge, even though the same commit amended the contract for supersession. The wrapper's help and the workflow comment both document it; only the contract table is stale. Also noted: remaining references to `doc-lint.yml`/`enforcement-pack.yml` exist only in historical artifacts (specs/002/**, review/out/**) and in explanatory prose (this feature's contract/tasks, the workflow header) — none in doc-lint's scanned governance set; `docs/sdlc/branch-protection.md` was fully re-pointed (verified by grep).
*Action: implementer adds "-Branch passed explicitly (detached-HEAD)" to the contract's Steps row — one line, phase 4 bookkeeping window is still open.*

## Constitution re-check (post-implementation)

**PASS.** (I) spec/plan/tasks preceded implementation; the mid-flight discovery (002's workflows) was handled through the sanctioned amendment path, committed before use. (II) prose and machine agree at the commit boundary — branch-protection.md, adoption docs, and the contract were amended in the same commit that changed the machinery; the one out-of-step artifact is host configuration, not a repository document (F1). (IV) no new patterns or dependencies; wrapper mirrors existing script conventions. (VI) engaged with nuance: permissions are minimal but F2 is a genuine hardening gap in a shipped file. (VIII) R1–R4 executed with live, independently re-verified evidence — fail paths included. (X) phase independently revertible (with the F1 one-way-migration caveat noted under rollback).

## Test coverage observed

No test framework (kit convention). Deterministic validation = quickstart R1–R4, all four executed and recorded in tasks.md "Phase 3 validation", and independently re-verified by this review: R1 re-run locally (3 OK + `RESULT OK`, exit 0); R2's never-short-circuit property reproduced in a scratch repo (2 members FAIL, third still ran, exit 1); R3-green = run 34144751539 (success, 18s, push-triggered); R3-red = run 34145125813 (failure, verdict line matches local byte-for-byte); R4 = run 34145110674 (success, 16s). Edge probes beyond quickstart: repo path with spaces (pass), empty `-Branch` args (pass), preference-variable interaction (F3).

## Residual risk

Concentrated in F1 and F2. F1 is a hard merge-stopper until the owner performs the documented branch-protection migration — do it before opening the PR, or the PR will sit blocked exactly as 002's review predicted. F2 rides the update channel: the injection pattern will be stamped verbatim into every adopted project on the next flow-down; fix it in the kit first (two lines) and it never propagates. F3/F4 are quality-of-life: local contributors with customized PowerShell profiles may see truncated wrapper output, and trunk loses its post-merge doc-lint safety net unless `main` is added to the push triggers or `strict: true` protection is applied everywhere. The wrapper logic itself — invocation mechanics, exit aggregation, verdict format, member parameter routing — checked clean against the contract under both normal and adversarial conditions.

---

## Implementer fix-response log (post-review, same phase territory)

*Appended by the implementing agent after acting on the review; the review text above is
unmodified. Fixes land in a `phase 3 fixes` commit.*

| Finding | Disposition |
|---|---|
| F1 | **Repository configuration performed** — `main` branch protection migrated via `gh api` per the recipe in `docs/sdlc/branch-protection.md`: required contexts now `["ritual-checks"]` (old `doc-lint`/`enforcement-pack` removed), `strict` and `enforce_admins` preserved. Flagged in the batch-gate report for owner confirmation. |
| F2 | **Fixed in code** — env-var indirection: the workflow passes the branch through `env: RITUAL_BRANCH` and the run line reads `$env:RITUAL_BRANCH`; no `${{ }}` interpolation inside `run:`. |
| F3 | **Fixed in code** — `$PSNativeCommandUseErrorActionPreference = $false` set beside the preference line, and child invocations run with `-NoProfile`. |
| F4 | **Fixed in code (recommended option)** — `main` added to the push branch list, restoring 002's post-merge trunk coverage; PR double-run accepted as cost/noise. |
| F5 | **Accepted** — noted as precedent guidance: future territory amendments name files when the need is enumerable. |
| F6 | **Accepted** — evidence commits acknowledged; candidate for a ritual-docs clarification in a future feature, not this one. |
| F7 | **Fixed in docs** — contract Steps row now says the wrapper is invoked with `-Branch` passed explicitly (detached-HEAD note). |