# AI Code Review — 012 Cross-Repo Scope-Check Reach (phases 2 and 3)

**Reviewer**: fresh-context agent — `claude-opus-5[1m]`
**Date**: 2026-09-09
**Branches**: `agentic-sdlc-kit` `012-cross-repo-scope-check` (tip `714ff75`)
**Scope reviewed**: commits `d287879` (phase 2) and `714ff75` (phase 3) in full. Files read: `scripts/verify-kit.ps1` (dimensions 2 and 4), `scripts/init-kit.ps1` (slots + record writer), `scripts/scope-check-repos.ps1`, `scripts/scope-lib.ps1`, `adoption/updating.md`, `adoption/greenfield.md`, `adoption/existing-system.md`, `.github/workflows/code-repo-scope-check.yml.template`, `.github/workflows/ritual-checks.yml`, `kit-manifest.json`, `docs/sdlc/{repository-strategy,definition-of-done,review-process,flow,branch-protection}.md`, `CLAUDE.md`, `docs/digests/*`, and `specs/012-cross-repo-scope-check/{spec,plan,tasks,contracts/scope-check-repos-cli}.md`. Phase 1 (`56c0068`) reviewed only where phases 2–3 depend on it; findings there are referred, not graded.
**Feature contract**: read-only checks; zero new dependencies; PowerShell 7 + Markdown/JSON/YAML only; backward compatible (SC-004 — no existing green run turns red); no constitutional amendment (stays 0.6.0); no code added to any code repository.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — `claude-opus-5[1m]`
- **Implementer**: Claude Opus 5 (1M context) — the session credited in the `Co-Authored-By` trailer of `d287879` and `714ff75`
- **Inputs provided**: phase 2 and phase 3 diffs, spec.md, plan.md, tasks.md, contracts/scope-check-repos-cli.md, the kit's law documents, and the working tree
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — Phase 2 and phase 3 do what they say at the structural level: `codeRepos` is written only for a `multi` topology and never into an existing record, the doctor gained a real validation block that suppresses the "record valid" line on FAIL, the new law sections are well-written and land where territory is actually defined, the manifest entry is correctly ordered before the `.github/**` verbatim glob, both commits sit exactly inside their declared Territory, and the digests are generator-fresh. But the feature's headline promise — that a code repository can reach the same verdict in its own CI — does not hold as shipped: **the CI template checks out the governance repository at its default branch, where the feature's Territory declaration does not exist, so the check emits a non-blocking WARN and exits 0 for every in-flight feature** (F1, reproduced end-to-end: exit 1 locally, exit 0 in the CI-shaped layout, same commit). Two doctor validation gaps make the record's own guarantees narrower than their messages claim (F2, F3), and three kit-shipped enumerations of the ritual-checks member set still omit `scope-repos` (F4).

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match | FR-005 ✓ — `codeRepos` written only for `multi` with names; a `-Topology single` run omits it entirely. FR-008 **partially** ✓ — shape validation present, but the "declares none" WARN misses the empty/null case (F2) and the `..` prohibition is unenforced (F3). FR-007 ✗ as shipped (F1). FR-009 ✓ for the five documents the FR names; ✗ for phase 3's own broader Independent Test (F4). FR-002 ✓ — the documented Territory example graded **PASS** on real commits, so `**` and the parenthesised Next.js route group both survive `Test-InTerritory`'s escaping. |
| Visual-reference match | N/A — no visual references in this feature. |
| Feature contract held | ✓ No new packages, no constitution edit, no code added to any code repository, both scripts read-only. |
| Security | Template never inlines a credential (`token: ${{ secrets.GOVERNANCE_TOKEN }}` only); the refname reaches `run:` through `env:` and is never interpolated into the shell; `permissions: contents: read`. One hardening gap: `persist-credentials` left at its default (F10). |
| Scope guard | ✓ `PASS phase 2 commit d287879 (3 file(s))`, `PASS phase 3 commit 714ff75 (10 file(s))`; hand-checked against both Territory blocks. No unrelated change in either commit. |
| Rollback safety | ✓ Both phases revert cleanly and independently. No schema migration, no data. |
| Doctor robustness | 18 record shapes probed on a throwaway kit copy: absent, `null`, `[]`, string, object, nested array, number, boolean, `a/b`, `C:\…`, `..`, `.`, `....`, `-Force`, `CON`. **The doctor never throws and never aborts.** A FAIL correctly suppresses the "adoption record valid" line; a WARN correctly does not. |
| `init-kit` record writing | ✓ `Contains('codeRepos')` works on `[ordered]@{}` in PowerShell 7; JSON valid and stable, key order preserved, single-element list still serialises as an array; re-running init over an existing record leaves the field untouched. |
| Digests | ✓ `build-digests.ps1 -Check` → `OK (5 digest(s) fresh, 72 marker(s))`; the three added markers land in the right packs, in source order, no hand-editing. |
| Whole-run verdict | ✓ `ritual-checks.ps1` → `RESULT OK` with `scope-repos: n/a (no codeRepos declared…)` — SC-004 holds. |

## Findings

### F1 — The shipped CI template grades nothing and reports green — PHASE 3 — BLOCKING

The governance checkout supplies no `ref:`, so `actions/checkout` checks out the governance repository's **default branch**. In that clone the feature branch exists only as `refs/remotes/origin/NNN-name`, never as `refs/heads/NNN-name`. `Get-GovernanceRef` tests `refs/heads/$FeatureBranch`, fails, and falls back to `HEAD` — i.e. `main`. The Territory declaration for an in-flight feature lives on the **unmerged governance feature branch**, so no `specs/NNN-name/tasks.md` is found and the run degrades to the non-blocking warning path.

Reproduced on a fixture with one code phase commit touching a declared `src/a.cs` **and** an undeclared `STRAY.md`:

```text
=== governance ON the feature branch (developer local) ===
scope-repos: demo-api: FAIL phase 1 commit aa329ec: demo-api/STRAY.md not in territory      EXIT=1
=== governance cloned, feature branch not a local head (what the template gives) ===
scope-repos: demo-api: WARN phase 1 commit aa329ec: no specs/012-demo/tasks.md in the
governance repository as of 2026-09-09T22:22:38+08:00 (… non-blocking)                       EXIT=0
```

Same commit, same declaration, opposite verdict. This breaks FR-007 and US3 acceptance scenario 3, and an adopter who wires this and requires the status check gets a permanently green, permanently blind gate 4.

*Action: implementer — try `refs/remotes/origin/$FeatureBranch` before falling back to `HEAD`, and/or add `ref: ${{ github.ref_name }}` to the governance checkout. Add a header line telling the adopter that a first run reporting WARN rather than PASS/FAIL means the wiring is wrong.*

### F2 — A multi-repo adoption that declares `"codeRepos": []` is called valid, with no warning — PHASE 2 — BLOCKING

The presence test is `$record.PSObject.Properties.Name -contains 'codeRepos'`, so a present-but-empty or present-but-null field takes the `if` branch, iterates zero entries, and never reaches the `multi` warning:

```text
=== C empty-array-multi ===  verify-kit: ok record — adoption record valid — tiers: backend; gate proven
=== D null-multi ===         verify-kit: ok record — adoption record valid — tiers: backend; gate proven
=== E absent-multi ===       verify-kit: WARN record: multi-repo adoption declares no codeRepos …
```

This contradicts T009 verbatim, FR-008, and phase 2's own Independent Test. A project can sit in the GAP-016 silence the field exists to break while its doctor prints "adoption record valid".

*Action: implementer — key the branch on the declared count, keeping a separate FAIL/WARN for a present-but-malformed value.*

### F3 — The `..` prohibition the FAIL message states is not enforced; `.` produces a spurious PASS — PHASE 2 — BLOCKING

The regex `'^[A-Za-z0-9._-]+$'` includes `.`, so `.`, `..` and `....` all pass validation while the message promises "no paths, no '..'":

```text
=== B dotdot ===  verify-kit: ok record — adoption record valid — … codeRepos: ..; gate proven
=== H4 dot ===    verify-kit: ok record — adoption record valid — … codeRepos: .; gate proven
```

Not inert downstream: with `["."]` the grader treats the governance root as a code repository and prints a PASS attributed to a repository that does not exist. A JSON **string** instead of an array is also silently accepted. For a governance kit, a validation message promising a rule the regex does not implement is the "claim of enforcement that nothing enforces" failure mode, in the one script whose job is to catch exactly that.

*Action: implementer — require at least one non-dot character and add an explicit non-array FAIL.*

### F4 — Three kit-shipped enumerations of the ritual-checks member set still omit `scope-repos` — PHASE 3 — BLOCKING

Phase 3's Independent Test is "every enumeration of the ritual-checks member set names `scope-repos`". Four were updated; three were not:

- `.github/workflows/ritual-checks.yml` (header comment) — **verbatim** class, so it flows down to every adopted project.
- `docs/sdlc/branch-protection.md` — **verbatim**, and the document an adopter reads while deciding what to require as a status check.
- `adoption/existing-system.md` — the step telling an existing adopter what CI runs.

These are the same three files `45967b3` swept earlier the same day to close this exact drift for `verify-kit`. FR-009 lists only five documents and all five were updated, so the *spec* is satisfied; the *phase's own declared test* is not. None of the three is inside phase 3's declared Territory.

*Action: owner + implementer — amend the Territory (owner approval), then land a phase 4 commit. Consider the durable fix: drop the parenthetical list from the two verbatim files and point at the wrapper instead.*

### F5 — "Both checks must PASS" is stricter than the contract and unachievable for a docs-only phase — PHASE 3 — CONFIRM

`definition-of-done.md` and `review-process.md` state a rule the code does not implement and the spec does not intend: the contract makes `PASS / not applicable / n/a / WARN` all exit 0, and C9/C11 *require* WARN to be non-blocking. A multi-repo project's governance-only phase yields `not applicable`, never PASS — so read literally, gate 4 would be unsatisfiable for that phase.

*Action: owner decides the intended rule; suggested restatement: "the second must not FAIL; `n/a` / `not applicable` / `WARN` are lawful non-blocking verdicts".*

### F6 — CLAUDE.md's Repositories section was not pointed at the new law section — PHASE 3 — MINOR

T015's third clause did not land: a multi-repo agent reading "Repositories" gets no route to "Territory across repositories". `CLAUDE.md` is in phase 3's Territory.

### F7 — Template header overstates the leniency of a `CODE_REPO_DIR` mismatch — PHASE 3 — DOC DRIFT

The header says a mismatch "grades nothing"; the script actually errors and exits 1. The adopter is told to expect silence and will get a failure.

### F8 — `adoption/updating.md` overstates the doctor and does not list its new dimension — PHASE 2 — DOC DRIFT

"Until it is there, the doctor WARNs" is true only for an *absent* field (per F2). The dimension summary does not name the `codeRepos` audit. The hand-add snippet is a comma-terminated fragment with no stated insertion point.

### F9 — Existing multi-repo adopters are not told about any of this — PHASE 3 — CONFIRM

`adoption/greenfield.md` gained a clear multi-repo bullet; `adoption/existing-system.md` step 8, its stated twin, gained nothing, and `adoption/updating.md` §2 has no flow-down note for feature 012 despite the 008/009/010/011 precedent. Both currently adopted projects use the nested multi-repo layout — the entire audience for this feature reads the files that were not updated. Neither file is in phase 3's Territory.

### F10 — Governance PAT persists in the checkout for the remainder of the job — PHASE 3 — MINOR

`actions/checkout` defaults to `persist-credentials: true`, so the token is written into `governance/.git/config` and stays there while later steps run. The checker never fetches, so nothing needs it.

### F11 — Referred to the phase 1 reviewer — MINOR

(a) The merge-base fallback tries only `origin/main` and `main`, so a `master`-trunk code repository gets a green run that graded nothing — the same silent-green shape as F1. (b) A push-only trigger never produces a check run for a fork PR's head SHA, which would block such PRs permanently if the check is required.

### F12 — The push-events-only decision is sound and does not hide a script defect — PHASE 3 — ACCEPTED

On `pull_request`, checkout produces a detached merge preview and the code repository would have no local `NNN-name` head, so the grader would pass without grading. Restricting to `push` avoids a second false-green rather than papering over a bug, and a push to a feature branch still produces a check run on the SHA the PR carries.

## Constitution re-check (post-implementation)

**PASS with one qualification.**

- **I / VII** — spec, plan, tasks and the CLI contract all predate implementation. Satisfied.
- **II** — no ladder change. Satisfied.
- **III** — no code added to any code repository; the only artifact crossing the boundary is an inert `.template`. Satisfied.
- **IV** — manifest entry, ritual-checks member and doctor dimension all follow existing patterns. Satisfied.
- **V** — N/A.
- **VI** — no credential inlined, refnames env-passed, checks read-only; qualified by F10.
- **VIII** — phase 3's central artifact, the CI template, was **not** exercised against a fixture before shipping; F1 is the direct consequence. Phase 2's doctor changes were exercised, but the malformed-record space was under-explored — F2 and F3 both fall inside T009's own wording.
- **IX / X** — one phase per commit, each independently revertible, both inside declared Territory.

## Test coverage observed

- Phase 2: the three attested verdicts reproduce and are real, but the attested set omits the empty-array, null, dot, dot-dot and scalar shapes — exactly where F2 and F3 live. No phase-2 verdicts are recorded in any contract artifact.
- Phase 3: the CI template has no recorded run and no fixture. The only assertion made about it — valid YAML, slots listed in the adoption docs — is true, but nothing tested the layout it produces, which is where F1 lives.
- Re-run rather than trusted: the documented Territory example against real commits (PASS on both repos, including the `(training)` route group); the anti-retroactivity and stray-path paths; `-Repo`/`-Branch`/`-All` in the CI-shaped invocation; and the local-vs-CI verdict divergence in F1.

## Residual risk

Concentrated in **F1**: the feature ships a mechanism whose most visible artifact — the workflow an adopter copies into every code repository — currently produces a green run that grades nothing, and reports its blindness as a non-blocking WARN. Everything else is recoverable by editing text; this one converts the feature's own thesis into a property of the shipped kit. **F2** and **F3** are narrower but sit in the adoption doctor, whose entire purpose is catching unstated drift. **F4** is drift the kit has now paid for three times.

Before merge: fix F1 (with a fixture run recorded in the contract, in the CI-shaped layout), F2 and F3 (with the probe shapes recorded); land F4 and F9 in a phase 4 commit preceded by an owner-approved Territory amendment; settle F5 with the owner. F6, F7, F8 and F10 are small enough to ride the same follow-up commits. F11 is referred to the phase 1 reviewer.
