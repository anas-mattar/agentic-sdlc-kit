# AI Code Review — 018 Cross-repo Territory Reach (Phase 3)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-11
**Branches**: agentic-sdlc-kit `018-cross-repo-territory-reach` (phase-3 commit `554e6e2`, parent `e686026`)
**Scope reviewed**: `git show 554e6e2` in full (97 files: `scripts/territory-check.ps1` +174/-19, `notes.md` +71,
`tests/enforcement/rules.json` TERR-014..022, `emission-idioms.json`, 25 new fixture directories under
`tests/enforcement/cases/territory-check/TERR-014..022`). Read for context: `CLAUDE.md`, the review template,
`spec.md`, `plan.md`, `research.md`, `tasks.md` (Phase 3, T012-T023, Territory), `contracts/territory-check-output.md`,
`notes.md`, the phase 2 review for shape, the whole current `scripts/territory-check.ps1`, and
`Get-RepoMergeBase`/`Get-RepoTrunkCandidates` in `scripts/scope-lib.ps1`.
**Feature contract**: phase 3 = T012-T023. Territory: `scripts/territory-check.ps1`, `tests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-sonnet-5-5 (the implementing session)
- **Inputs provided**: commit `554e6e2` (stat, full script, harness registrations, a diff of every fixture pair, the
  expected output and command of the cause fixtures, notes); the 018 feature documents (`spec.md`, `plan.md`,
  `research.md`, `tasks.md`, `contracts/territory-check-output.md`, `notes.md`); the kit's law (`CLAUDE.md`, the review
  template); the phase 2 review for style; read and run access to the working tree and throwaway repositories under the
  reviewer's scratchpad. No repository file other than this review was modified; nothing was committed.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE WITH FOLLOW-UPS (no Blocker, no Major).** The reach is implemented as the spec, plan D2/D4/D5/D6/D7 and the
contract say: each declared code repository is read as a sibling working tree, overlap is reported with repository
prefixes in the claim's one block, status comes from the latest commit in any repository, every cause of a comparison not
made is its own named `UNGRADED` entry, an overlap keeps exit 2 beside the ungraded lines, and a project with no (or an
empty) `codeRepos` prints the original text. I could not make it report a wrong verdict in the main paths (overlap,
no-overlap, each of the six causes, rename, uncommitted changes, stale, code-only liveness, non-ASCII and spaced paths).
What I did find is small: a duplicated declaration is compared twice, a stale local head can resurrect a claim whose
remote branch was deleted, the `no merge base` wording is used for a corrupt ref, the local-only limit is not in `-Json`,
and a few fixtures that the decisions lean on are missing. The owner's gate has not been reported and nothing here
claims it.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Harness | `pwsh -NoProfile -File tests/enforcement/Run-Tests.ps1 -Case territory-check/`: 144 passed, 0 failed, 0 skipped. `pwsh -NoProfile -File scripts/ritual-checks.ps1`: `RESULT OK` (doc-lint, enforcement-pack incl. coverage tests, scope-check, digests, roadmap-claims OK; scope-repos and verify-kit n/a). Not the full harness run; the certification is the owner's. |
| Spec FR-001/002/004 | Own throwaway layout (governance + `api`, both with bare origins, `012-other` and `011-thing` each editing `api/src/Orders.cs` while the governance specs are disjoint): `OVERLAP with 012-other [live]:` / `  api/src/Orders.cs`, exit 2. `-Json` carries the prefixed `files`, `CLEAN:false`, `UNGRADED:[]`. |
| Non-ASCII / spaced paths | `api/src/Caf é/Ünï.cs` compared equal on both sides and printed verbatim, text and JSON (`core.quotepath=off` works on this host). |
| FR-005/007, D6 | Trunk order is `Get-RepoTrunkCandidates` (`origin/main` first, so a fetched trunk beats a stale local one). Liveness: `$latestEpoch` is the max of the governance tip and every code ref tip with commits (`territory-check.ps1:221-224`, `231`); `TERR-014/fail-code-only-liveness` pins it. |
| FR-006/R7 | `Get-OwnCodeTouched` (`:136-151`) adds `git diff --name-only HEAD` only when `branch --show-current` equals the branch under check; the `fail-own-uncommitted` / `pass-uncommitted-other-branch` pair differs only in `checkout` and the edit text. |
| FR-008/009/010 | Six causes have their own `Add-Ungraded` sites (`:155,161,173,178,188,190,220`) and wording (`:252-259`); the verdict is `UNGRADED` and exit 0 with no overlap, exit 2 with one (`TERR-014/fail-overlap-and-ungraded`). `CLEAN` appears only when `$ungraded.Count -eq 0` (`:267-274`). |
| FR-013 / US3 | `TERR-022/pass` and `pass-empty` differ from `fail` only in the `codeRepos` line and run over a layout in which `api` exists and would overlap, so they prove the repository is not read. Original `CLEAN` text is emitted with `$comparedNote = ''`. Pre-existing TERR-001..013 are unchanged (the whole directory passes). |
| Fixture independence | Every `expected.txt` is literal text matching the contract anchors; none is produced by the script or its helpers. Fixture-pair diffs (run, not just read): 015, 016, 018, 020, 021, 022, 014 pass/fail, fail-json/pass-json, stale, own-uncommitted, two-repos differ in the one condition under test. Exceptions: F8. |
| Territory | `git show --stat`: `scripts/territory-check.ps1`, `tests/**` (`rules.json`, `emission-idioms.json`, `cases/territory-check/**`) and the feature's own `notes.md`. No other file; `scripts/scope-check-repos.ps1`, both libraries, `spec.md`, `plan.md`, `contracts/` untouched. `tasks.md` is not touched (F9). |
| Registrations | Anchors `'not-present'`, `'not-a-repository'`, `'no-trunk'`, `'fetch-failed'`, `'declaration-unusable'`, `local branches only` each match one emission line; `'branch-uncomparable'` matches two (`:190`, `:220`) and the rule declares `siteCount: 2`; the switch arms at `:253-257` carry the same words but are not accumulator-pattern lines, so the count is honest. The per-entry printer is carried as a `notRule` with a stated reason. `TERR-014`'s anchor (`Write-Host "  $_"`, the shared-file printer) and `TERR-022`'s (`open feature branch$comparedNote`, the CLEAN site it shares with TERR-002) are real sites and are described as shared. |
| Rollback | One script plus tests; reverting the commit restores the phase 2 script and fixtures. Phase 4 (guidance) has not been written, so there is no document yet that depends on this phase. |

## Findings

### F1 — A duplicated `codeRepos` entry is compared twice and every overlap file prints twice — MINOR

`scripts/territory-check.ps1:158` iterates `$declared.Repos` as returned. `Get-CodeRepos` accepts duplicates (the phase 1
table in `notes.md` says "a duplicate: api, api"). With `"codeRepos": ["api","api"]` I got
`OVERLAP with 012-other [live]:` / `  api/src/Orders.cs` / `  api/src/Orders.cs`; an ungraded repository would be listed
twice, the count in `UNGRADED — ... (2 comparison(s) ...)` would be 2 for one cause, and the CLEAN note would read
`compared governance and api, api`. Not wrong, but it prints a duplicated Territory-ready list and inflates the
"comparisons not made" figure the verdict line is built on.
*Action: author. `foreach ($name in @($declared.Repos | Select-Object -Unique))`, and one fixture (a duplicate in the
declaration, one overlap line, no repeated entry). `tests/**` and the script only.*

### F2 — The local-head fallback can resurrect a claim whose remote branch was deleted — MINOR

`:215` looks for `refs/remotes/origin/$other` and falls back to `refs/heads/$other` even when the repository has an
`origin` that was just fetched with `--prune`. I deleted `origin/012-other` in `api` (as a merged/abandoned feature
would be after its pull request) while a stale local `012-other` remained and the governance claim was still open:
the check still reported `OVERLAP with 012-other [live]` from the local head. A feature that is finished in the code
repository but whose governance branch is not yet deleted therefore keeps a live claim for as long as any developer's
clone holds the old local branch, and the status is judged from that stale tip. This is what plan D4 says ("falling back
to a local head"), so it is within the plan, but D4 and research R2 justify the fallback for the no-origin case; for a
repository with a successfully fetched `origin` a missing remote-tracking ref is information, not a gap.
*Action: owner decision (CONFIRM-shaped, recorded here as a Minor). Either keep D4 and add a sentence to the guidance in
phase 4 ("a local branch that the remote no longer has still counts"), or restrict the fallback to repositories with no
`origin`. If restricted, a fixture pair for it.*

### F3 — "no merge base with <trunk>" is printed for a corrupt ref, and the genuine no-shared-history case has no fixture — MINOR

`Read-CodeRef` (`:116-130`) turns any failure of `Get-RepoMergeBase` into `no merge base with <candidates>`, and three
different later failures (diff, `rev-list`, `log`) into the single detail `diff failed`. `TERR-019/fail` truncates the
tip commit of `012-other`; the expected output is `UNGRADED: api: cannot compare 012-other (no merge base with main)`,
which tells the owner the history is unrelated when it is a damaged object (`git merge-base` exits non-zero in both
cases, so the wrapper cannot tell). The research R3 distinction the contract relies on ("that feature's ref has no merge
base, or its diff failed") is therefore pinned only through corruption. No fixture builds a branch that shares no history
with the trunk (an orphan branch), which is the common real cause and the one the wording describes.
*Action: author. Add a `TERR-019` case (`fail-orphan`, with a passing counterpart already present) whose other branch is
an orphan, hand-written expectation `no merge base with main`. If the wrapper cannot distinguish the cases, soften the
corrupt-ref detail to "cannot compare with <candidates> (no merge base or unreadable ref)". The `diff failed` arms have
no fixture and are three lines that report one message for three conditions; either say which one in the detail or note
it as untestable in `notes.md`.*

### F4 — `-Json` does not carry the "local branches only" limit — MINOR

`$notes` is printed only in the text branch (`:246`). A `-Json` run over a repository with no `origin` returns
`"CLEAN":true,"UNGRADED":[]` with nothing machine-readable saying the code repository was compared against local branches
only; the text form says so on its own line. The spec's Assumptions require that "the output says so", and SC-005 is about
telling "nothing overlaps" from "I could not look" from a single run. A consumer of the JSON (the only one that exists is
a person or a script reading `CLEAN`) gets the stronger claim. The contract is silent, so this is a gap in the contract
as much as in the script.
*Action: author with the owner. Add a `NOTES` (or `COMPARED`) array to the JSON object, additive, and pin it with a hand
written `-Json` fixture next to `TERR-021`; or record in `notes.md` that the limit is text-only by decision.*

### F5 — With `-Branch X` that is not the current branch, a code repository's uncommitted edits count and the governance ones do not — MINOR

`Get-OwnCodeTouched` includes the working-tree diff whenever the repository is checked out on `$Branch`
(`:145-149`); the governance read includes `git diff --name-only HEAD` only when `$checkingCurrent` (`:81-83`). When the
governance repository is on one branch and an owner asks about another that the code repository is on, the two halves
of one run use different rules. Spec FR-006 says "as it does in the governance repository today", and R7's rationale
is that the working tree belongs to the checked-out branch, which supports the code-repository behaviour. The
unequal treatment is not wrong, only undocumented. Same family: for the branch under check the union of the local head and
`origin/$Branch` (notes decision 2, which I agree with) means a stale remote-tracking ref that still lists a file the
developer has since dropped locally keeps that file in the touched set; the check can over-report but not miss.
*Action: author. One sentence in the script header; no code change required.*

### F6 — `not-a-repository` is a copy of the scope check's test, with no mechanism to keep the two equal — MINOR

`territory-check.ps1:166-171` repeats the five lines of `scripts/scope-check-repos.ps1:336-343`, including
`Resolve-Path` without `-LiteralPath`. Plan D1 and spec FR-003/FR-005 exist because a copied helper is the defect feature
013 paid for. I agree with the implementer's decision: the shared place (`scope-lib.ps1`) and the other consumer are
outside this phase's Territory, so the copy is forced, and it is honestly commented and recorded in `notes.md`.
What is missing is the follow-up: it appears only in `notes.md`, not in `tasks.md` or the phase 4 task list, so it can be
lost. A comment is not a mechanism.
*Action: owner/author. Add the extraction (a `Test-IsRepoRoot` in `scope-lib.ps1`, both scripts calling it) as a task in
phase 4 (add its two files to that phase's Territory by approved amendment) or as a roadmap item; failing that, a harness
test that the two scripts declare the same condition.*

### F7 — Phase 1 review F5 (wildcards in the record path) is not reachable through this script, so the notes overstate it — DOC DRIFT

`notes.md` "Carried forward" says F5 "is live in this phase": a governance root containing `[` reads an existing record
as absent and the check prints the original `CLEAN`. I tried a root named `b[1]`: the script dies at
`territory-check.ps1:53` (`Push-Location $repoRoot`, which treats `[1]` as a wildcard) with exit 1 and a PowerShell
error, before `Get-CodeRepos` is ever called. That is the pre-existing behaviour for such a root and is loud, not a
silent `CLEAN`. The `-LiteralPath` fix in `adoption-lib.ps1` is still worth making for the scope check, but it does not
turn this check into a false `CLEAN`.
*Action: author. Correct the note (the failure mode is an exit-1 crash, pre-existing, at `Push-Location`); the
`-LiteralPath` work stays the owner's call.*

### F8 — A few fixture pairs differ by more than the condition, and several behaviours the decisions rely on have no fixture — MINOR

- `TERR-017` `fail` vs `pass` differ in the default branch, in the commits on `main` and in the existence of
  `012-other` (the failing repository has only the feature branch). The condition (no trunk) is the main difference,
  but the pair is not a minimal one; a no-trunk repository that still has `012-other` would keep everything else equal.
- `TERR-014/fail-rename` vs `pass` differ in the file each side edits as well as in the rename, and there is no
  passing counterpart for the rename condition itself (a rename where the old path is not edited by the other side).
- Not covered by any fixture: the `refs/heads` fallback for another feature (F2), a branch under check that exists only as
  `origin/<branch>`, the non-ASCII/`core.quotepath` claim in plan D4 (works, per my run, but unpinned), `-Json` with a
  code-repository ungraded entry other than `TERR-015/fail-json`, an ungraded entry in one repository with an overlap in
  another in `-Json`, and a claim that has no branch in a declared code repository (implicit in some cases, not asserted).
*Action: author. Tighten `TERR-017` and add the cheapest missing cases (the local-head fallback, a non-ASCII path, a
rename pass). `tests/**` only.*

### F9 — `tasks.md` T012-T023 are not ticked — DOC DRIFT

The phase 3 commit does not touch `tasks.md`; all twelve boxes are still `[ ]` although the work is done and recorded in
`notes.md`. Phases 1 and 2 ticked theirs in the same commit.
*Action: author. Tick T012-T023 (ticks only, as in phases 1 and 2), with T016 noted as satisfied by commit `e686026`.*

## Decisions recorded in `notes.md` ("Decisions taken while implementing")

1. **`not-a-repository` copied, not shared** — AGREE, forced by Territory; see F6 for the missing follow-up.
2. **The branch under check reads both `refs/heads/<branch>` and `refs/remotes/origin/<branch>`** — AGREE. Either alone
   would miss a developer's unpushed commit or a colleague's pushed one, and over-reporting by a stale remote-tracking
   ref is the safe direction (F5).
3. **`TERR-021`'s no-`origin` case is a note, not an ungraded entry** — AGREE with the reading, with one caveat. The spec
   Assumptions say "compared against its local branches only, and the output says so" and plan Risks says a failed fetch
   makes the run ungraded, so a note is the faithful reading and the run may legitimately end `CLEAN`. The caveat is
   F4: the limit exists only in the text form, and the `CLEAN` line itself reads as the broader claim. If the owner
   wants the stronger reading it is, as the implementer says, one line plus three changed expectations.
4. **`origin/HEAD` is not a trunk in a self-origin fixture, so `TERR-017` has no origin** — AGREE; it is a limit of the
   self-origin fixture. A related, unguarded case in the shared library is a trunk candidate that resolves to the very
   ref being compared (`Get-RepoMergeBase` does not exclude it), which would give an empty touched set that reads as
   compared; it needs a clone whose `origin/HEAD` names a feature branch and no `main`/`master`, so it is rare and I do
   not raise it as a finding, but the guidance in phase 4 should not describe `origin/HEAD` as always safe.
5. **The corrupt-ref cases have no origin** — AGREE, with F3 (the printed detail for a corrupt object says "no merge base").
6. **`fail-code-only-liveness` uses a 450-hour-old governance commit** — AGREE; the "claimed, no work yet" state is
   reached through the pre-existing governance path only, as the note says.

The `notes.md` T015 account (only `TERR-022/pass`, `pass-empty` and `TERR-014/pass-json` passed against the phase 2 script)
is plausible and is the honest correction of the task's wording. T023 matches what I reproduced.

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly. **None.** The commit adds `notes.md` text only; `spec.md`,
  `plan.md`, `contracts/` and `tasks.md` are untouched. The D5 amendment was committed earlier (`e686026`) with an
  approval line.

## Constitution re-check (post-implementation)

**PASS.** Specification First (I): the code follows the approved spec as amended. Honest verdicts: no path in the
reviewed script ends `CLEAN` after a comparison it skipped; the one limit still stated only in text is F4. Controlled
delivery (X): one phase, one script, tests only; Territory held. Gate-claim discipline: the notes and commit claim no
certification. The kit's no-new-package and no-architecture-change rules are held (two libraries already dot-sourced by
the other scripts).

## Test coverage observed

`-Case territory-check/`: 144 tests, 0 failed. `scripts/ritual-checks.ps1`: `RESULT OK`. My own runs outside the harness:
two-repository overlap, duplicated declaration (F1), non-ASCII path, remote branch deleted with a stale local head (F2),
bracketed governance root (F7). Not covered by the harness: see F8.

## Residual risk

Low. The overlap and every named cause are correct and pinned in both directions with hand-written expectations. What
could still surprise an owner: a duplicated declaration (F1), a stale local branch counted as a live claim (F2), an
unrelated-history message printed for a corrupt ref (F3), and a `-Json` consumer that cannot see the local-only limit
(F4). None changes an exit code or turns an overlap into `CLEAN`. F2 and F4 deserve the owner's eye before phase 4 writes
the guidance, because the guidance will describe both.
