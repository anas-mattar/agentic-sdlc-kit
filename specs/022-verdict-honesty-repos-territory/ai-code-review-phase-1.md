# AI Code Review — 022 Verdicts that say what was compared (phase 1)

**Reviewer**: fresh-context agent — claude-opus-5-5
**Date**: 2026-10-12
**Branches**: agentic-sdlc-kit `022-verdict-honesty-repos-territory` (tip `cea8cce`)
**Scope reviewed**: commit `cea8cce` in full (`git show cea8cce`): `scripts/scope-check-repos.ps1` (whole file read,
not only the hunks), the seven `REPOS-034` / `REPOS-015` cases and the two `RIT-009` cases (`recipe.json`,
`command.json`, `expected.txt`, recipes diffed pairwise), the two `tests/enforcement/rules.json` entries, the
`scope-check-repos.ps1` entry of `tests/enforcement/emission-idioms.json`, `specs/022-verdict-honesty-repos-territory/notes.md`;
against `spec.md` (US1, US2, FR-001 to FR-005, FR-008, SC-001, SC-004, SC-005), `plan.md` (D1 to D5, Testing
Strategy), `tasks.md` (Phase 1, T001 to T005), the scope-repos member lifting in `scripts/ritual-checks.ps1`
(lines 151, 173-205), and the `merge` recipe field of `tests/enforcement/lib/FixtureRepo.psm1`.
**Feature contract**: no new script, no new library file, no new package; `scripts/ritual-checks.ps1` untouched
(D5); `-BaseRef` semantics unchanged (D4); output byte-identical whenever every applicable repository graded, in
`-All` and tip mode (FR-003, SC-001); the partly graded run-level line is an `-All` reading only (D2, FR-001 as amended).

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5-5
- **Implementer**: claude-sonnet-5-5 (Claude Code session)
- **Inputs provided**: the phase 1 commit cea8cce diff, spec.md, plan.md, tasks.md, notes.md
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups** — The phase does what FR-001 to FR-005 ask. Under `-All`, `scope-check-repos.ps1` now
keeps a per-repository counter and an `$ungradedRepos` list. It joins the list at both `UNGRADED ... continue` sites
and after a repository's loop that graded nothing. It prints one run-level `scope-repos: UNGRADED (...)` line only
when `-All` is set, something graded and the list is non-empty, and it prints it beside a `FAIL` too. The
nothing-graded line is unchanged and the no-trunk hint names a command that works. I checked this three ways: by
reading the code, with the targeted harness cases (`REPOS-034`, `REPOS-015`, `RIT-009`, `-Case REPOS-` 175 and
`-Case RIT-` 129+4 = 133, all green), and by running the parent and the phase-1 script side by side on the new
fixtures. Eight adversarial probes found no logic defect. Two items that T003/T004 listed explicitly were not done:
the script's header description of the run-level verdict was not updated (F1), and the `REPOS-015` entry in
`rules.json` was not touched (F2). Neither changes behaviour, but both are written tasks, and F1 leaves the
script's own documentation describing behaviour it no longer has. Three gaps in fixture coverage are smaller (F3
to F5). The behaviour in those gaps is correct, as the probes below show, but no committed fixture guards it.
Residual risk is low and sits in documentation accuracy, not in the verdict logic.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | **FR-001 / US1 sc.1**: `REPOS-034/fail` passes in the harness; I ran the parent script (`c300851`, detached temp worktree, since removed) and the phase-1 script on the same built fixture: the parent prints B's line and stops (exit 0), phase 1 adds `scope-repos: UNGRADED (1 declared code repository applied to '001-thing' and graded nothing: web-repo — ...; graded: code-repo)`, exit 0. **US1 sc.2**: `fail-skipped-commits`, same side-by-side, parent silent, phase 1 names `web-repo`; tip mode unchanged (`pass-tip-mode`; probe P2-tip with three repositories, one skipped tip: no run-level line). **US1 sc.3 / FR-003**: `REPOS-034/pass`, parent and phase-1 output identical apart from the build-time SHAs, which match between the two runs on one fixture. **US1 sc.4 / FR-002**: the three `n/a` / `not applicable` guards (`scope-check-repos.ps1:331-353`) `continue` before any list is touched; `pass-absent-repository` passes. **US1 sc.5**: `fail-beside-a-failure`, exit 1 on both parent and phase 1, line present only on phase 1; the line says `graded:`, not clean. **FR-003 nothing-graded line**: `:397` is byte-identical to the parent (diff shows no change on that line); the new line is an `elseif`, so the two never print together. **FR-004 / US2 sc.1**: `:364` hint now `to grade it, run: pwsh -File scripts/scope-check-repos.ps1 -All -Repo <repo> -BaseRef <trunk>`; `REPOS-015/fail` expected updated. **SC-005**: `REPOS-015/pass-hint-as-printed` runs `-All -Repo code-repo -BaseRef develop` and gets a `PASS`. **FR-005 / SC-004**: `ritual-checks.ps1:205` matches `^scope-repos: UNGRADED`, so it lifts the run-level line and not the per-repository lines (`scope-repos: <repo>: UNGRADED ...`); `RIT-009/fail` → member and RESULT `UNGRADED`, `RIT-009/pass` → `OK`; `ritual-checks.ps1` is not in the diff. |
| Visual-reference match (where references exist): Visual Compliance Loop deviation table attached, empty or user-approved (`docs/sdlc/review-process.md`) | Not applicable: no UI, no visual references. |
| Feature contract held (no unapproved table/migration/permission/package) | `git show --stat cea8cce`: 31 files: `scripts/scope-check-repos.ps1`, `tests/**` (cases, `rules.json`), `specs/022-.../notes.md`. No new script or library file, no package, `ritual-checks.ps1` and `emission-idioms.json` untouched. `-BaseRef` still replaces every repository's candidates when `-Repo` is absent (probe P2 `-All -BaseRef develop`: `code-repo` and `app-repo` go UNGRADED with candidates `(develop)`), as D4 says it should. |
| Constitution / domain invariants | I (no spec/plan/tasks change in the commit: `git show cea8cce --stat -- spec.md plan.md tasks.md` empty); VIII (fixtures hand-written, fail cases shown failing on the parent, see below); X (one phase, commit subject `phase 1`). No domain-invariants pack. |
| Security (authn/authz, secrets, sensitive logging) | Read-only script; the new line names only repository directory names and the branch, both already printed on the per-repository lines. Nothing new is read or written. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | `pwsh -File scripts/scope-check.ps1 -Commit cea8cce` → `scope-check: PASS phase 1 commit cea8cce (31 file(s))`, exit 0. Stat read: every file is inside the Phase 1 Territory (`scripts/scope-check-repos.ps1`, `tests/**`) or is the feature's own `notes.md`. |
| Rollback safety (phase reverts cleanly; schema additive?) | Pure additions plus one hint string and one expected.txt line; `git revert cea8cce` restores the parent's behaviour and its `REPOS-015/fail` expectation together. No schema. Phase 2 does not depend on it (tasks.md ordering note). |

## Findings

### F1 — The script header still describes the run-level verdict as it was before this phase — DOC DRIFT

T004 says "Update the script header's description of the run-level verdict." The commit does not touch the
`.DESCRIPTION` block. `scripts/scope-check-repos.ps1:34-39` still says the run-level line is `'UNGRADED ...' when
it applies but nothing was graded in the declared repositories`. After this phase that is incomplete: under `-All`
the run-level line is also `UNGRADED` when something graded and an applicable repository did not, including beside
a `FAIL`, and that reading is `-All`-only. The header is what `Get-Help` and a reader of the kit-owned file see,
and the file flows down to adopters verbatim. Evidence: `git show cea8cce -- scripts/scope-check-repos.ps1` has
only three hunks (`:327`, `:364-371`, `:381-405`), none in the comment block. The code is correct. Only the
documentation is stale.
*Action: implementer adds two or three header sentences (the partly graded run-level line, `-All` only, printed
beside a FAIL, exit unchanged) in a phase-1 remediation commit, then re-runs `-Case REPOS-` (no expectation changes).*

### F2 — `REPOS-015` in `rules.json` was not updated although T003 lists it — MINOR

T003 says "Add `REPOS-034` and update `REPOS-015` in `tests/enforcement/rules.json` (anchors, law, summary)". The
commit adds `REPOS-034` and `RIT-009` but leaves `REPOS-015` (`rules.json:992-999`) unchanged. The anchor `UNGRADED
could not resolve a merge base with a trunk` still matches, so coverage passes. But the entry's `law` does not cite
022 FR-004 / SC-005. Its `notes` still say "The case is unchanged except for the verdict word it expects", which
stopped being true when this commit changed `REPOS-015/fail/expected.txt` (the hint) and added
`pass-hint-as-printed`. The rule inventory is where the kit records the before-state of a changed expectation
(the D11 record its own notes cite), so leaving it out loses that record.
*Action: implementer extends `REPOS-015`'s `law` (022 FR-004, SC-005) and `notes` (the hint changed in 022 phase 1,
the before-state is the previous revision of `fail/expected.txt`, and `pass-hint-as-printed` proves the printed
command grades) in the same remediation commit as F1.*

### F3 — `fail-skipped-commits` has no merge commit, and no fixture covers the empty-range join site — MINOR

T002 describes `fail-skipped-commits` as "B's only commits are a merge commit and a commit with no `phase N`
token", and US1 scenario 2 names merge commits. The recipe has only a `chore: setup` commit (recipe diffed
against `fail`), and the harness does support merges (`FixtureRepo.psm1:56-58`, the `merge` field). Under `-All` a
merge never reaches the per-commit check because the range uses `rev-list --no-merges` (`:368`). A branch whose
only new commit is a merge, or one already merged into the trunk, therefore takes the other join site: `UNGRADED
(no commits since merge base ...)` at `:370-371`. No committed fixture exercises that site together with a graded
repository, so the `$ungradedRepos += $repoName` on `:371` could be deleted and every case would stay green. Probe
P1b (B's phase commit merged into `main`, so the range is empty) printed B's `UNGRADED (no commits since merge
base ...)` line and the run-level line naming `web-repo`, exit 0, so the behaviour is correct today.
*Action: implementer adds a `REPOS-034/fail-empty-range` case (B's branch merged into its trunk, or a merge-only
branch, via the `merge` recipe field), shows it failing on the parent, and records it in `notes.md`. Alternatively,
the owner accepts the gap and the T002 wording is noted as not followed.*

### F4 — The second clause of US2 scenario 2 has no fixture — MINOR

US2 scenario 2 says "a repository the command did not name is not graded against that trunk". `REPOS-015/pass-hint-as-printed`
declares one repository, so it cannot show this. The code holds it, because `-Repo` narrows `$toGrade` to one
entry (`:292-298`). Probe P2 (three repositories, `-All -Repo web-repo -BaseRef develop`) printed only
`web-repo: PASS`. Neither `code-repo` nor `app-repo` was mentioned or graded.
*Action: none required for the merge. Optional: a two-repository variant of `pass-hint-as-printed` that asserts the
unnamed repository prints nothing. The owner decides whether SC-005's "grades that repository" is enough.*

### F5 — The implementer's T001 baseline worktree was left registered — MINOR

`git worktree list` shows `C:/Users/anas.m/AppData/Local/Temp/wt-base c300851 (detached HEAD)`, the parent commit
`notes.md` says the baseline was taken on. tasks.md requires removal only for T016, and the worktree does not
affect the branch. A stale registration can still confuse the later T016 isolated-checkout run, and it holds a
lock on the temp directory. (My own worktree for this review was added and removed. That one is not mine.)
*Action: implementer or owner runs `git worktree remove --force C:/Users/anas.m/AppData/Local/Temp/wt-base` and
`git worktree prune`.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None.** `git show cea8cce --stat -- specs/022-verdict-honesty-repos-territory/spec.md .../plan.md .../tasks.md`
lists no file. The only file under `specs/` is the new `notes.md`, an evidence record and not an approved
document. The FR-001 amendment to `-All` landed earlier in `a5ac721` with its approver (anas.m, 2026-10-12)
recorded, and that is the standard this phase was graded against. (The T001 to T005 checkboxes in `tasks.md` are
still unticked. That is not an amendment.)

## Constitution re-check (post-implementation)

PASS. I (Specification First): the code follows the amended FR-001 and plan D1 to D4, and the phase changed no
governing document. II: no conflict between rungs found. The one difference between the D1 wording and the code is
not a conflict: D1 lists "an unresolvable commit" among skips, but `Invoke-RepoScopeCheck` returns `FAIL` for an
unresolvable SHA (`:163-166`), so it counts as graded. Under `-All` every commit comes from `rev-list`, so the case
cannot arise there. III, V, VII: not applicable (as at plan time). IV: no new file, existing structure and
libraries kept. VI: read-only, nothing sensitive printed. VIII: every new rule has hand-written pass and fail
fixtures, and the `REPOS` fail cases fail on the parent for the stated reason (re-verified independently, see
Test coverage). F3 and F4 are coverage gaps, not missing pairs. IX: this review, then human review. X: one phase,
`phase 1` subject, owner-run gate (no ci-held, no batching), and the scope check passes.

## Test coverage observed

- `Run-Tests.ps1 -Case REPOS-034`: 47 passed, 0 failed. `-Case REPOS-015`: 41 passed. `-Case RIT-009`: 39 passed
  (each count includes the harness's global coverage tests).
- `-Case REPOS-`: **175** passed, 0 failed. `-Case RIT-`: **133** passed, 0 failed. Both match `notes.md` T005
  exactly. The deltas from the notes' parent baseline (161 → 175, +14; 129 → 133, +4) equal two tests per new case
  (seven new `REPOS` cases, two new `RIT` cases). Together they explain the claimed full-harness delta of 1335 → 1353
  (+18). I did not re-run the full harness (about 10 minutes). The targeted counts and the arithmetic are consistent with it.
- Parent-versus-phase side by side, run by me on a detached temp worktree of `c300851` (removed afterwards), with the
  real recipes:
  - `REPOS-034/fail`: the parent has no run-level line and the old hint; phase 1 has both new texts.
  - `fail-skipped-commits`: the parent has no run-level line.
  - `fail-beside-a-failure`: the parent has no run-level line and exits 1; phase 1 has the line and exits 1.
  - `pass`: identical on both.

  This confirms the notes' T002 table for the `REPOS-034` rows. The `RIT-009` pair passes on the parent too, which the
  notes disclose (the member is a stub). It pins the aggregator's existing `^scope-repos: UNGRADED` lift against this line's exact shape.
- The critical assertions are `REPOS-034/pass` (FR-003: both graded gives no new line, under `-All`), `pass-tip-mode`
  (D2: tip mode untouched) and `REPOS-015/fail` (the exact hint text with the repository name filled in).
- Adversarial probes (fixtures built with `FixtureRepo.psm1` in temp, script run with `-Root`, all removed):
  - P1 (B carries only a non-phase commit and a merge): B is named.
  - P1b (empty range, so the `:371` join site): B is named.
  - P2, three repositories under `-All` (one graded, one with no trunk, one skipped): `2 declared code repositories
    ... web-repo, app-repo`, plural noun correct, order is declaration order.
  - P2 tip mode: no new line.
  - P2 `-All -Repo web-repo` (no trunk): only the nothing-graded line; the new line never fires with a single graded set.
  - P2 hint as printed: `PASS`.
  - P2 `-All -BaseRef develop` without `-Repo`: the other two repositories are named UNGRADED, which is the D4
    behaviour `notes`/phase 3 must disclose.
  - P3 (B's commit is `phase 2` with no phase-2 territory): FAIL, exit 1, no run-level line, correctly, because B graded.

## Residual risk

Low. The verdict logic is small and correct on every path I could reach, including the two join sites, the
post-loop join, the `-Repo` filter, tip mode and the `FAIL` exit. The risk sits in three places:

- **Documentation drift** (F1, F2). The kit-owned script header and the rule inventory under-describe what shipped.
  Fix both in a phase-1 remediation commit before the gate is run, because the header flows to adopters verbatim.
- **Unguarded join site** (F3). A future edit could drop the empty-range join without a fixture noticing. Add the
  case, or have the owner accept the gap explicitly.
- **Adopter verdict movement.** Under `-All`, FitForge's CI can newly report `scope-repos UNGRADED` when one of its
  two repositories carries the feature branch but has no phase commit, has only skipped commits, or has an
  unresolvable trunk. That is the intended effect, and it is phase 3's measurement (T015) to quantify and disclose.
  It is not a phase-1 defect.

Merge after F1 and F2 are remediated (or F2 accepted by the owner), F3 is decided, the owner runs the gate and
confirms the exit code, and the human review is complete.
