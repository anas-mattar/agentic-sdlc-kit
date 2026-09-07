# AI Code Review — 006 Verification Pack (Phase 1: Machine scope check)

**Reviewer**: fresh-context agent — Claude Fable 5 (subagent, no implementation context)
**Date**: 2026-09-08
**Branches**: agentic-sdlc-kit `006-verification-pack` (tip `b0df0fa`)
**Scope reviewed**: full diff of `b0df0fa` (`git show`); `scripts/scope-check.ps1` read line by line (all 229 lines); `docs/sdlc/definition-of-done.md` gate 4; `docs/sdlc/review-process.md` (whole file); `.specify/templates/tasks-template.md` (Territory sections + all phase blocks); `specs/006-verification-pack/` spec.md (US1/FR-001..004), plan.md, research.md (D1–D3), data-model.md, quickstart.md, tasks.md incl. Phase 1 validation record; `kit-manifest.json` glob rows. Script executed read-only against `b0df0fa`, `-All` mode, an invalid sha, and seeded scenarios in a scratch repository (unicode paths, tasks.md delete/re-add, trailing-slash entries); `Get-Territory`/`Test-InTerritory` replicated verbatim in a probe harness and fed the real parent blob of `b0df0fa`.
**Feature contract**: doc+script phases only, no application code, no new dependencies (plan.md Technical Context: PowerShell 7 + git CLI only, no modules).

## Reviewer Provenance

<!-- Retrofitted in phase 2 when the provenance block became mandatory: this review WAS
  produced by a fresh-context subagent (see Reviewer header) — the block records what was
  already true. -->

- **Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
- **Implementer**: Claude Fable 5 (main session that produced commit `b0df0fa`)
- **Inputs provided**: phase 1 diff (`git show b0df0fa`), spec.md, plan.md, research.md D1–D3, data-model.md, quickstart.md, tasks.md, contracts/scope-check-cli.md; read-only script execution permitted
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — The phase delivers what tasks T001–T007 name: the Territory syntax in the template, a working `scope-check.ps1` whose S1–S7 verdicts I could reproduce, and mutually-referencing DoD/review-process amendments, all inside the declared territory. But the territory extractor demonstrably mis-parses the kit's own canonical `tasks.md` layout — it collects the task checklist as territory entries (F1), so the boundary the machine enforces is a silent superset of the boundary the owner approved, with a live false-FAIL path through the invalid-entry rule. Two further defects undercut the feature's core guarantees: the parent-read fallback can be sidestepped by deleting `tasks.md` in a prior in-territory commit (F2, defeats FR-004/SC-001), and non-ASCII paths false-FAIL via git quotepath (F3, relevant on the ubuntu CI this must run on). Residual risk sits entirely in the parser and matcher — the docs and template are sound apart from one sequencing drift (F5).

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-001: `tasks-template.md` diff adds "Phase Territory" rules section + placeholder in US1 phase block (but not the others — F6). FR-002: ran the script; seeded stray in scratch repo → `FAIL … not in territory`, exit 1; self-run `-Commit b0df0fa` → `PASS phase 1 commit b0df0fa (5 file(s))`, exit 0. FR-003: `-All` on this branch → WARN for `3e3214c`/`645fbf0` (no phase token), exit 0; dispatch code exits 0 with "not applicable" on `^(fix\|chore\|docs)/`. FR-004: S3 record in tasks.md + code reads `${Sha}^:$tasksRel` first — but bypassable (F2). |
| Visual-reference match (where references exist) | N/A — no `specs/006-verification-pack/screenshots/`; doc+script feature. |
| Feature contract held (no unapproved table/migration/permission/package) | Diff = 4 markdown files + 1 new .ps1; script invokes only `git` (`rev-parse`, `merge-base`, `show`, `rev-list`, `log`); no `Install-Module`/`Import-Module`, no network, no writes (only `Push-Location`/`Pop-Location` in try/finally). |
| Constitution / domain invariants | X: one phase, one commit (`b0df0fa`), subject carries `phase 1` token. II: DoD gate 4 and review-process amended in the same commit as the script per plan's resolution — one prose/code disagreement found (F5). D3 anti-retroactivity implemented as specified (with the F2 hole). |
| Security (authn/authz, secrets, sensitive logging) | Read every command in the script: read-only over git history per the contract's guarantee; no secrets, no logging of anything beyond paths/shas; `2>$null` suppression only. |
| Scope guard (`git diff --stat` — only intended files) | `git show b0df0fa --stat`: exactly the 4 declared territory files + `specs/006-verification-pack/tasks.md` (implicit spec-dir). `kit-manifest.json` declared but untouched — legal (territory is allowance). T006's no-edit claim verified: `kit-manifest.json` line 36 has `"scripts/*.ps1": verbatim`; `doc-lint.ps1` run now reports "62 shipped file(s) classified", matching the commit message. |
| Rollback safety (phase reverts cleanly; schema additive?) | Grep for `scope-check` outside the feature dir hits only the three docs amended in this same commit (+ pre-existing prose in 003 artifacts); reverting `b0df0fa` restores the eyeballed gate 4 with no dangling references, as plan.md's phase table claims. |

## Findings

### F1 — Get-Territory swallows the task checklist as territory entries — BLOCKING

`Get-Territory` (scripts/scope-check.ps1) treats blank lines as list continuations and only stops at the "first non-list, non-blank line". In the kit's own canonical `tasks.md` layout the territory list is followed by a blank line and then the `- [ ] T00x …` task items — which are list items. Replicating the function verbatim and feeding it the exact blob the self-run used (`git show b0df0fa^:specs/006-verification-pack/tasks.md`, phase 1) yields **12 entries: the 5 declared paths plus all 7 task lines T001–T007** ingested as globs. Consequences: (a) the enforced territory is a silent superset of what the owner approved — task text containing `*`/`[x]` becomes live `-like` patterns (data-model defines entries as "list items, one path/glob each, backtick-wrapped"; whole task sentences are neither); (b) any task sub-bullet starting with `/` or a drive letter trips the invalid-entry rule and **FAILs the phase naming a task description as a bad territory entry**. The Phase 1 validation record never caught this because the quickstart's `999-scope-demo` tasks.md contained no task list, and the self-run's junk patterns happened to match nothing.
*Action: implementer terminates collection at the end of the markdown list (blank line + next item is a checkbox/task, or simply: stop at the first blank line, or accept only backtick-wrapped bare-path entries and reject `[ ]`/`[x]` items); re-run S1–S7 plus a new scenario using the kit's real tasks.md layout before the batch gate.*

### F2 — FR-004 anti-retroactivity bypassed by deleting tasks.md in a prior commit — CONFIRM

The parent-read fallback (`if ($LASTEXITCODE -ne 0) { $tasksBlob = git show "${Sha}:$tasksRel" … }`) triggers whenever the parent lacks `tasks.md` — not only at the claim commit the contract names. Demonstrated in a scratch repo: commit A `phase 1: tidy` deletes `specs/NNN/tasks.md` → **PASS** (the deletion is inside the implicit spec-dir territory); commit B `phase 1: work` re-adds `tasks.md` with a widened territory **plus the stray file in the same commit** → **PASS, exit 0**. (Variant: never re-add it — every later commit gets WARN, exit 0.) A stray file is thus legalized in the very commit that introduces it, through a two-commit sequence that stays green throughout — SC-001's "rejected 100% of the time" does not hold. The contract's own wording sanctions a fallback "when the parent lacks the file", so the fix is a design decision, not just a patch.
*Action: owner decides the tightening — restrict the fallback to commits whose parent lacks the entire `specs/NNN-name/` directory (true claim commits), and/or make a phase commit that deletes or re-creates `tasks.md` an automatic FAIL/loud WARN. Should land before phase 3 wires this into CI.*

### F3 — Non-ASCII paths false-FAIL via git quotepath — CONFIRM

`Get-CommitPaths` parses `git show --name-status` text without disabling `core.quotepath`. Scratch-repo test: committing `demo/allowed/héllo café.txt` inside declared `demo/allowed/**` produces `scope-check: FAIL … "demo/allowed/h\303\251llo caf\303\251.txt" not in territory`, exit 1 — a legitimate in-territory file is rejected because git emitted the path in quoted-octal form. Plan requires this script to run on `ubuntu-latest` CI where UTF-8 filenames are ordinary; any adopter with an accented filename gets a hard false block.
*Action: implementer adds `-c core.quotepath=off` to the `git show --name-status` call (and any future path-emitting call), or switches to `-z` parsing; add a unicode-path scenario to quickstart.*

### F4 — Invalid `-Commit` crashes with a raw null-method exception — MINOR

`pwsh -File scripts/scope-check.ps1 -Commit deadbeef123` → `You cannot call a method on a null-valued expression`, exit 1: `(git rev-parse --short $Sha 2>$null).Trim()` calls `.Trim()` on `$null` when the sha doesn't resolve. Same pattern in `Get-CurrentBranch` and `Get-DiffBase`. Exit code happens to be non-zero, but the output is a stack-trace line instead of any contract verdict, and the contract's determinism guarantee reads poorly next to an unhandled exception.
*Action: implementer null-guards the three `.Trim()` sites and emits a named error line (e.g. `scope-check: ERROR '<sha>' does not resolve`) with a deliberate exit code.*

### F5 — review-process runs the scope check before the phase commit exists — DOC DRIFT

`docs/sdlc/review-process.md` "After Each Phase" now reads: step 2 run `scope-check.ps1` (+ `git diff --stat`), step 5 "Commit successful phase". The script only reads committed history (default `-Commit HEAD`); it cannot see the working tree. Followed literally, step 2 checks the *previous* commit while the phase's uncommitted changes are invisible to the machine — the stray file the section's step 4 tells you to revert would never have been flagged. DoD gate 4 uses the correct post-commit framing ("the phase commit passes the machine scope check"), so the two amended documents disagree on when the check can run. In kit practice the agent commits first (T007 pattern), which makes step 5 stale instead.
*Action: implementer reorders the section — commit the phase, run `scope-check.ps1` against it, remediate by amend/redo (territory amendment commit first) — in a follow-up inside phase 1's territory.*

### F6 — Template placeholder contradicts its own MUST — MINOR

The new "Phase Territory" section states "**Every** phase heading MUST be followed by a `**Territory**:` list", but the placeholder block was added only to the Phase 3 (User Story 1) block (line 115); Setup, Foundational, US2, US3, and Polish blocks carry none. Agents generating `tasks.md` from the template will predictably declare territory for one phase and omit the rest, producing WARN verdicts that DoD gate 4 declares unacceptable for post-006 features.
*Action: implementer adds the placeholder to every phase block of `.specify/templates/tasks-template.md` (file is in phase 1 territory; a small follow-up commit suffices).*

### F7 — `-like` matching footguns undocumented: bracket paths, case, trailing slashes — MINOR

Verified by probe/scratch runs: (a) a declared literal path containing `[` never matches itself — `src/app/[id]/page.tsx` vs its own declaration → no match (character-class semantics), so Next.js-style dynamic-route paths false-FAIL unless hidden under a `**` glob (relevant to the known frontend adoptions); (b) matching is case-insensitive even for Linux CI — `DOCS/x.md` matches territory `docs/**`, so a stray differing only in case is silently legalized on a case-sensitive filesystem; (c) a trailing-slash entry (`demo/allowed/`) matches nothing — scratch test false-FAILed `demo/allowed/plain.txt`, exit 1. All are consistent with the data-model's chosen "`-like` semantics" but none are stated in the template's rules, which mention only `*`/`**`.
*Action: implementer documents (a)–(c) in the tasks-template "Phase Territory" rules, or normalizes in code (escape `[`/`?` since D1 promises globs, not character classes; treat trailing `/` as `/**`). Owner picks doc vs code.*

### F8 — Declaration validation and verdict taxonomy laxer than data-model — MINOR

Three divergences from `data-model.md`: (1) "Exactly one [Territory marker] per phase" — a second marker in the same phase silently merges both entry lists (probe verified), no error; (2) "An empty list after the marker is invalid" — the script maps marker-with-no-entries to the pre-006 compatibility WARN, so a post-006 feature declaring a bare marker exits 0; (3) data-model's verdict table calls a "non-phase commit" `not-applicable`, but the script emits `warning-undeclared` for any commit lacking a phase token (only merge commits get not-applicable) — so under `-All`, every post-006 branch's claim/specify commits WARN (observed on this branch), making DoD's "WARN acceptable only for features specified before the verification pack" strictly unsatisfiable as worded. The script follows the CLI contract (S6 says WARN), so this is artifact-vs-artifact inconsistency more than a code bug. Related contract nit: the parameter table says `-Branch` is "used only to classify the lane", but behavior step 2 (and the code) also derives the feature directory from it.
*Action: implementer reconciles data-model/contract/DoD wording in a later phase (the artifacts are not in this diff); consider making an empty declaration a FAIL per data-model.*

## Constitution re-check (post-implementation)

**PASS** (with the findings above as caveats). **I** — spec/plan/tasks preceded the code; territory approved at plan time. **II** — the designed-for prose/machine tension was resolved as planned by amending DoD and review-process in the same commit; F5 is one residual disagreement between those two docs, reported rather than silently chosen. **IV** — no new patterns or dependencies: one script beside its siblings, git-only, matching enforcement-pack conventions. **VIII** — the check is the business-critical logic and shipped with deterministic seeded scenarios, fail paths exercised (verified re-runnable; but see Test coverage — the suite missed F1–F3 because its fixture tasks.md was minimal). **X** — one phase, one revertible commit, batch declared in plan before implementation; revertibility confirmed by reference sweep. **VI** — read-only over git, no secrets. D6's no-constitution-amendment call holds: the script encodes no constitutional constants.

## Test coverage observed

No test framework (by design). Validation = quickstart S1–S7 + backward-compat run, recorded verbatim in `specs/006-verification-pack/tasks.md` Phase 1 validation (8 rows, fail paths S2/S3/S7 exercised, exits recorded). I independently reproduced the suite's shape read-only: S1/S2-equivalents, S5 lane dispatch, S6/BC WARNs (`-All` on this branch), FR-004 parent-read (S3 per record), plus T007's gate claims (doc-lint OK/62 classified; enforcement-pack OK). **Coverage gap**: every scenario used a minimal fixture `tasks.md` (territory list only, no task checklist) and ASCII paths — exactly the blind spots where F1 (real tasks.md layout), F2 (tasks.md deletion), and F3 (unicode) live. The suite validates the contract's happy grammar, not the kit's own dominant document shape.

## Residual risk

Concentrated in the parser/matcher, not the docs: F1 means every territory verdict on real tasks.md files is computed against a polluted entry set — correct so far by luck, not construction — and must be fixed before phase 3 makes this check CI-blocking. F2 is the one hole in the feature's headline guarantee (same-commit legalization); it needs an owner decision because the contract's own fallback wording permits it. F3 will bite the first adopter with a non-ASCII filename, on the exact ubuntu runner D5 chose. Two forward-looking notes for phase 3: CI checkouts run detached-HEAD, where `Get-CurrentBranch` returns `HEAD` and the script exits "not applicable" — the wrapper must pass `-Branch` explicitly or the CI scope check is a no-op; and F8's inevitable WARNs on claim/specify commits will train owners to ignore WARN lines in `-All` output. Recommend: fix F1+F3 (and F4 trivially) inside phase 1 before the batch gate, put F2 and the F5 reorder to the owner now, and fold F6–F8 into the phase 2/4 doc territory.

---

## Implementer fix-response log (post-review, same phase)

*Appended by the implementing agent after acting on the review; the review text above is
unmodified. All fixes land in a `phase 1` follow-up commit inside the declared territory.*

| Finding | Disposition |
|---|---|
| F1 | **Fixed in code** — collection accepts only backtick-wrapped entries, starts at the first entry after the marker, and terminates at the first blank line or non-entry line after entries begin; checkbox items never parse as entries. Re-validated against the kit's real tasks.md layout (new scenario S8). |
| F2 | **Fixed in code (strict option)** — ANY commit that deletes `specs/NNN-name/tasks.md` FAILs (checked before phase attribution, so a token-less "cleanup" commit cannot hide the deletion); the fallback to the commit's own blob applies only when the parent lacks the entire `specs/NNN-name/` directory (true claim commit). Residual edge: if the whole spec dir is deleted and re-added, the re-add alone reads its own blob — but the deleting commit itself always FAILs, so `-All`/CI keeps the branch red for the full sequence (validated, S10). Flagged for owner ratification at the batch gate since the reviewer marked it an owner decision; contract updated to the strict wording. |
| F3 | **Fixed in code** — `-c core.quotepath=off` on the path-emitting git call; unicode scenario added (S9). |
| F4 | **Fixed in code** — null-guards on the three `.Trim()` sites; unresolvable `-Commit` emits `scope-check: ERROR '<ref>' does not resolve to a commit`, exit 1. |
| F5 | **Fixed in docs** — review-process "After Each Phase" reordered: commit the phase → run the scope check against it → remediate (territory amendment commit precedes the re-committed phase). |
| F6 | **Fixed in template** — every sample phase block now carries a Territory placeholder. |
| F7 | **Fixed in code + docs** — `[`, `]`, `?` are escaped before matching (D1 promises globs, not character classes); a trailing `/` matches the whole subtree; case-insensitivity documented as intentional in the template rules. |
| F8 | **Fixed in code + artifacts** — duplicate marker in one phase = FAIL; empty declaration = FAIL (per data-model); commits without a `phase N` token are now `not applicable`, reserving WARN for attributed phases lacking territory (matches data-model taxonomy; contract S6 and quickstart updated accordingly, resolving the DoD wording tension). `-Branch` description corrected in the contract. |
| Detached-HEAD note | **Deferred to phase 3** — the wrapper/workflow will pass `-Branch` explicitly; a WARN hint added when the current branch resolves to `HEAD`. |