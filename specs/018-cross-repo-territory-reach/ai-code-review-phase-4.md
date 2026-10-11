# AI Code Review — 018 Cross-repo Territory Reach (Phase 4)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-11
**Branches**: agentic-sdlc-kit `018-cross-repo-territory-reach` (phase-4 commit `ddc11fd`, parent `7992bb4`)
**Scope reviewed**: `git show ddc11fd` in full (7 files: `docs/sdlc/team-workflow.md` +48/-, `adoption/updating.md` +87,
`docs/roadmap.md` +26/-2, `docs/digests/adoption-digest.md` +2, `docs/digests/branching-digest.md` +1/-1,
`specs/018-cross-repo-territory-reach/notes.md` +54, `specs/018-cross-repo-territory-reach/tasks.md` ticks). Read for
context: `CLAUDE.md`, `spec.md` (US4, FR-014, SC-004, SC-005, FR-013), `plan.md` (D4, D5), `tasks.md` (Phase 4, T024-T028
and its Territory), `contracts/territory-check-output.md`, `notes.md`, the phase 3 review for shape and its decisions,
the whole current `scripts/territory-check.ps1`, `Get-CodeRepos` (`scripts/adoption-lib.ps1`),
`Get-RepoTrunkCandidates` (`scripts/scope-lib.ps1`), `scripts/doc-lint.ps1` (path-span rules), the territory-check fixture
directory listing. The clone measurements themselves (`measure*`) were not touched or re-run.
**Feature contract**: phase 4 = T024-T028. Territory: `docs/sdlc/team-workflow.md`, `adoption/updating.md`,
`docs/roadmap.md`, `docs/digests/**`, `kit-manifest.json`. No script changes.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-sonnet-5-5 (the implementing session)
- **Inputs provided**: commit `ddc11fd` (stat, full diff, digest diff with trailing-whitespace differences ignored); the 018
  feature documents (`spec.md`, `plan.md`, `tasks.md`, `contracts/territory-check-output.md`, `notes.md`); the kit's law
  (`CLAUDE.md`, the review template); the phase 3 review for shape and for the owner decisions it carried; read and run
  access to the working tree and to throwaway repositories under the reviewer's scratchpad (a governance clone plus one code
  repository, each with a bare origin, two feature branches editing the same code file). No repository file other than this
  review was modified; nothing was committed.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES (one Major, documentation only; no Blocker).** The phase does what T024-T028 ask: section 5 now describes
the reach, the verdict word and a cause table; the flow-down note lists what flows down and what an owner will see; the
digests are fresh; the roadmap row, GAP-029 sentence and decisions-log entry are present and, with the one exception below,
accurate; the measurement is honestly framed, including the verdict that moved wider than SC-004's literal wording. Territory
is held and `ritual-checks.ps1` is `RESULT OK`. The Major is that the flow-down note tells adopters a branch cut before
`codeRepos` was declared will "print `UNGRADED` every time". I ran that case: it prints the original `CLEAN`, with no hint
that the code repositories were not read. That is the one remaining way the check says `CLEAN` over code it did not open, and
it is mislabelled in the adopter-facing note and absent from section 5. The fix is a few sentences. The owner's gate has not
been reported and nothing here claims it.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FR-014, US4, SC-005) | Section 5 states the reach, the prefixed path, any-repository liveness, exit codes, the verdict word, the `-Json` shape, a seven-row cause table with meaning and action, the local-only note and the limits. US4 scenario 1 (each cause and an action) holds for six of the seven causes as written; see F3 and F4 for the gaps. SC-005 holds for the output; the working-tree reading of `codeRepos` is the gap (F1). |
| Accuracy of causes and wording | Compared every table row against `territory-check.ps1:166-205, 233, 264-274`: `not present in this checkout` (`:169`, also true for a file where a directory is declared), `not a repository of its own` (`:181`), `no resolvable trunk (tried …)` with the five candidates `origin/main, main, origin/master, master, origin/HEAD` (`scope-lib.ps1:169`; matches the table), `fetch failed` with `continue`, so a stale view is not graded (`:191`), `cannot compare <feature> (…)` (`:233`, `:203`; the own-branch variant names the branch under check), `governance: cannot compare` (`:216`), `declaration unusable — …` (`:161`). Exit codes `0/2/1`, overlap keeps 2 beside ungraded lines, verdict `UNGRADED` never an exit code: `:275-294`. |
| Ran in throwaway repositories | Overlap in `api/src/A.cs`: `OVERLAP with 012-b [live]:` / `  api/src/A.cs`, exit 2. Invalid `kit-adoption.json`: `UNGRADED: codeRepos: declaration unusable - kit-adoption.json is not valid JSON …` then the closing `UNGRADED — … NOT fully compared` line, exit 0. `codeRepos: ["api","x/y"]`: overlap still printed, plus `UNGRADED: codeRepos: declaration unusable - ignoring codeRepos entry 'x/y' …`, exit 2. `-Json` with `{}`: `{"BRANCH":…,"CLEAN":true,"OVERLAPS":[],"UNGRADED":[]}`. `-Branch 011-a` run from `main` read `main`'s record and reached `api` (the record comes from the checked-out tree). Branch with `kit-adoption.json` removed: `CLEAN - '011-a' shares no files with any open feature branch.` although `api/src/A.cs` overlaps (F1). |
| Unchanged-output guarantee | True for a fully compared run in a project with no or empty `codeRepos` (`$comparedNote = ''`, `:285`); not true as the team-workflow sentence is worded (F2). The flow-down note words it correctly ("with every claim compared"). |
| `-Json` shape and what it omits | Flow-down and section 5 match the code: `UNGRADED` always present except in the `no remote` state (`:74`, which has none); `CLEAN` false whenever anything is not compared; `files` carry the prefix; the `local branches only` note is in `$notes`, written only in the text branch (`:259`). Both documents say it is text-only. Correct. |
| Liveness across repositories; local fallback | `:231-239, 244-245` take the max epoch over every repository; the stale-spec-beside-live-controller sentence is true. The "stale local branch keeps a finished feature live" caveat is true (phase 3 round 1 reproduced it; `:228` falls back to `refs/heads/$other`). The sentence "pushed work, plus local branches where a repository has no `origin`" understates the fallback, which also applies when `origin` exists but has no remote-tracking ref for the feature; the next sentence covers the surviving-local-branch case (F8). |
| Measurement (T026) | Read against the method and table in `notes.md`: states are installed, kit main `2221879` (the merge base of this branch and `main`, confirmed with `git merge-base`) and kit HEAD; the delta is main-to-HEAD only. Every number in `updating.md` appears in the notes table: exit 0 in every cell, `CLEAN` to `CLEAN` plus the `compared …` clause with the code repositories present, `CLEAN` to `UNGRADED` (2 entries) with them absent, the no-`codeRepos` branch unchanged, `ritual-checks` `RESULT OK` for FlowBoard and ExpenseTracker, FitForge the same two failing members at kit main and HEAD. Supportable as written. Caveats in F6. Not re-run: the clones are the owner's session's. |
| Discarded passes; no overlap exercised | Both discarded passes are recorded in `notes.md` with the reason, and the second one's tell (a `CLEAN` without the `compared …` clause) is named. `updating.md` says "Not exercised, and said so: no clone had another open feature, so no real overlap was reported". Honest. All claims are at 0 open claims; the document says so. |
| SC-004 framing | The notes, the flow-down note and the decisions log all say the move is wider than "a skipped claim" and why (a declared repository the old check never opened). That is a fair statement of a real difference from SC-004's sentence; spec FR-008/US2 list `not present` as an ungraded cause, so the move is specified behaviour, only the SC wording is narrower. Recommend the owner confirm the reading rather than the document defend it (F6). |
| Bookkeeping | `docs/roadmap.md`: GAP-018 row `shipped`, `anas.m`, link `specs/018-cross-repo-territory-reach/` unbracketed, as T027 requires. GAP-029: status sentence says governance half closed by 018, four refusals "still open", matches the unchanged first half of the row and TERR-008..011. Decisions-log entry states what stays open by decision; claims checked in F7. `roadmap-claims: OK (… own claim 018 exempt)`. |
| Digests | `pwsh -NoProfile -File scripts/ritual-checks.ps1`: `digests: OK (5 digest(s) fresh, 87 marker(s))`. `git show ddc11fd --ignore-space-at-eol -- docs/digests` is identical to the plain diff and contains no carriage returns: no line-ending churn, and the content change is exactly the three marker lines (one reworded, two added). New marker texts measure 106 and 118 characters (limit 120). |
| doc-lint, path-like spans | `doc-lint: OK` inside ritual-checks. New spans in `updating.md` and `team-workflow.md` that are path-shaped: `scripts/territory-check.ps1`, `scripts/adoption-lib.ps1`, `scripts/scope-lib.ps1`, `scripts/scope-check-repos.ps1`, `scripts/verify-kit.ps1`, `docs/sdlc/team-workflow.md`, `kit-adoption.json` (no slash, not graded). Each is a `verbatim` manifest entry (`scripts/*.ps1`, `docs/sdlc/team-workflow.md`), so each resolves in an adopted project after the update. `<repo>/<path>` contains angle brackets and is not path-shaped, so it cannot fail. No new unresolvable span. The notes' pre-existing `adoption/updating.md:255` template reference is not in this diff. |
| Scope guard | `git show --stat ddc11fd`: the five Territory entries (four touched; `kit-manifest.json` not touched, and nothing in it needs to change since the files are covered by existing `scripts/*.ps1` and `docs/sdlc/team-workflow.md` entries) plus the feature's own `notes.md` and `tasks.md` ticks, the same set phases 1-3 committed. `scope-check: PASS phase 4 commit ddc11fd (7 file(s))`. No script, test or fixture changed. `tasks.md` diff is four `[ ]` to `[x]` flips (T024-T027) and nothing else. |
| Rollback | Documents and digests only; reverting restores the phase 3 state with the guidance absent. |

## Findings

### F1 — The flow-down note says a branch cut before `codeRepos` "prints UNGRADED every time"; it prints `CLEAN`, and section 5 never says so — MAJOR

`adoption/updating.md:112-122` (the "What to do about it" paragraph): "Two situations will make a healthy project print
`UNGRADED` every time". The second bullet is "A feature branch cut before `codeRepos` was declared … the reach does not
apply to it". That branch does not print `UNGRADED`: `Get-CodeRepos` reads the record from the checked-out working tree, finds
no `codeRepos`, and the run is the original no-code-repositories run. I removed `kit-adoption.json` from a feature branch whose
`api` repository overlaps with an open claim and got `CLEAN - '011-a' shares no files with any open feature branch.`, exit 0
(`notes.md`'s own table agrees: ExpenseTracker `003-expense-entry` "`CLEAN`, same text"). So the bullet is wrong about the word
the owner will see, and the case it describes is the one place the check still reports a clean verdict over code repositories it
did not open, with no signal. An adopter reading "UNGRADED every time" will not know to look for a `CLEAN` that means "did not
look". Section 5 (`docs/sdlc/team-workflow.md`), the document an owner reads when the output is unexpected, does not mention that
the declaration is read from the checked-out working tree at all, and `-Branch X` run from another checkout reads that
checkout's record (verified), which is the same limit; the digest and the roadmap entry do not mention it either. SC-005
("tell from one run whether the answer means nothing overlaps or I could not look") is not met for this case by output or guidance.
*Action: author (documents only, inside Territory). Move the second bullet out of the "print `UNGRADED`" list and word it as a
limit: "the check reads `codeRepos` from the working tree you run it in; a branch without the declaration gets the governance-only
run and the original `CLEAN` line, which does not say the code repositories were skipped. Rebase or merge the trunk's
declaration before relying on a clean result." Add the same two sentences to section 5 beside the `no codeRepos` sentence. If the
owner wants it audible rather than documented, that is a script change (for example, a note when the trunk's record declares
`codeRepos` and the working tree's does not) and belongs to a follow-up feature or an approved amendment, not this phase.*

### F2 — "A project with no `codeRepos` sees the original output unchanged" is overstated — MINOR

`docs/sdlc/team-workflow.md` (section 5, last sentence of the local-branches paragraph). It is true of a fully compared run;
the contract says exactly that ("sees the same text on a fully compared run"). It is not true of a project with no `codeRepos`
whose clone cannot compare an open claim (any single-branch fetch refspec): that now ends `UNGRADED` (the flow-down note says so
correctly, item 1 of "What you will newly see"), and a record that is not valid JSON gives `UNGRADED: codeRepos: declaration
unusable` (verified). An owner who reads the unconditional sentence and then sees `UNGRADED` in a project without `codeRepos`
will think the check is broken.
*Action: author. "On a fully compared run, a project with no (or an empty) `codeRepos` sees the original output unchanged."*

### F3 — The cause table omits "not valid JSON" from the `codeRepos` row — MINOR

`docs/sdlc/team-workflow.md`, row `codeRepos: declaration unusable — …`: "not an array, or an entry that is a path". The code
(`adoption-lib.ps1:267-273`) has a third reason, an unparsable `kit-adoption.json`, which is the most likely one in practice
(a merge-conflict marker or a trailing comma); its line reads `declaration unusable - kit-adoption.json is not valid JSON - no
code repositories read`. With an unparsable record nothing is compared in the code repositories at all, whereas with a bad entry
the other entries still are (verified: the overlap printed beside the ungraded line); the row does not distinguish the two.
*Action: author. Add "is not valid JSON" to the meaning column and "a bad entry skips only that entry; invalid JSON skips all
code repositories" to the action.*

### F4 — The action for `governance: cannot compare` is not actionable, and one detail variant is uncovered — MINOR

`docs/sdlc/team-workflow.md`, row `governance: cannot compare <feature> (…)`: "`git fetch origin` with the full refspec, then
re-run". The script already runs `git fetch origin --prune` on every run (`:78`), and under a single-branch refspec that is
exactly what does not create the missing ref, so the instruction reads as "do what already did not work". The concrete fix is the
remote's fetch configuration (`git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'`, then fetch), or
`git fetch origin <feature>:refs/remotes/origin/<feature>` for one claim. The same row's second variant, `cannot compare with
main` (`:215`, a branch that exists but cannot be diffed against the base), is not described.
*Action: author. Put the refspec setting in the action and a clause for the base-cannot-diff variant (usually a shallow clone).*

### F5 — `<repo>/<path>` is bare in section 5 and long lines break the paragraph's wrapping — NIT

`docs/sdlc/team-workflow.md` (the sentence "the file is listed with its repository prefix, <repo>/<path>, so it can be pasted").
Outside a code span, a Markdown renderer reads `<repo>` and `<path>` as HTML tags and drops them, so the example vanishes on
GitHub. The same text is in a code span in `updating.md` and in the table. The paragraph also has two lines far over the file's
~90 column wrap (the "Two features whose specs/ directories never meet …" line), and `specs/` there is not in backticks.
*Action: author. Back-tick it and re-wrap.*

### F6 — Measurement write-up: statements the flow-down note leaves in the notes only — MINOR

(a) `updating.md` says "every project that declares `codeRepos` went from `CLEAN` to `UNGRADED`" and "in all three projects"; the
table behind it is three projects, one throwaway branch (FlowBoard `099-measure`, a branch that does not exist in the project)
and two `-Branch` runs from `main`; the note's "Each of FitForge, FlowBoard and ExpenseTracker was cloned" does not say which
branch carried which result. "Each of the three projects measured" and one clause naming the branch shapes would let a reader
reproduce it. (b) The two discarded passes are recorded in `notes.md` only; `updating.md` presents one method with no mention
that the first two attempts were thrown away, which is honest enough for an adopter document but the sentence "The delta is this
feature's alone" is true only because of that discard and the owner reading only `updating.md` would not know. (c) FitForge's
`ritual-checks` is `RESULT FAIL (2 of 7)` at kit main and kit HEAD, and `scope-check` is the member that went from passing
(installed) to failing between the installed 0.7.0 state and kit main; `updating.md` says "neither is this feature's" with no cause
for the scope-check failure. It is out of this feature's delta, but a project that updates the kit and finds its own
`scope-check` red deserves a pointer to whichever earlier feature did it. (d) T026 asks for a dry-run of `update-kit.ps1`; the
notes say the kit was "applied with `update-kit.ps1`" and do not mention the dry-run. (e) SC-004's sentence ("no verdict changes
except where the check was previously reporting `CLEAN` over a comparison it had skipped") is read widely, and the reading is
disclosed in three places; the spec still carries the narrower sentence. This is a judgement for the owner, not a defect in the write-up.
*Action: author for (a)-(d), a few clauses; owner for (e): confirm the reading, and amend SC-004 only if they want the spec to say it
(an amendment, approved by someone other than the implementer).*

### F7 — Decisions-log "open by decision" claims: accurate, with two omissions — MINOR

`docs/roadmap.md`, entry dated 2026-10-11. Each stated item matches the record: the four terminating-write refusals stay
(GAP-029 row, TERR-008..011 exempt); the `not-a-repository` test is a copy of `scope-check-repos.ps1`'s because that script and
`scope-lib.ps1` were outside the phase 3 Territory (phase 3 review F6 and `territory-check.ps1:171-179` comment); the local branch
the remote no longer has still counts, with an `origin`, per plan D4 and phase 3 review F2, the owner's call; `local branches only`
is text-only (phase 3 review F4, a contract change); unpushed work is invisible; and the bracket-root remark is consistent with
phase 3 review F7 (`Push-Location` interprets `[` as a wildcard, exits 1 before `Get-CodeRepos` runs; I relied on that review's
reproduction and on `Get-CodeRepos` still using `Test-Path $recordPath`, which I read, and did not re-run it). Omissions: (1) the
shared-test follow-up for `not-a-repository` is "open by decision" only in this prose; it has no `tasks.md` task and no `GAP-` row
(the entry itself says "needs a task"), so nothing will pick it up and the two tests can drift; (2) the phase 3 round 2 notes
that two behaviours remain unfixtured (the own branch existing only as `origin/<branch>`; a claim with no branch in a declared code
repository, asserted) are not listed among what stays open.
*Action: owner decides whether (1) becomes a new `GAP-0xx` row (the roadmap's own convention for recorded-not-claimed work) or a
phase 5; author adds (2) as one clause.*

### F8 — Minor wording and file-hygiene points — NIT

(a) `team-workflow.md`: "The check sees pushed work, plus local branches where a repository has no `origin`" understates the
fallback, which also reads a local head when `origin` exists but has no remote-tracking ref for that feature (`:228`); the next
sentence states the consequence, so only the first is imprecise. (b) The trunk note "(`main` or `master`, `origin/` forms first)"
omits `origin/HEAD`, which the table row lists. (c) `docs/roadmap.md` lost its trailing newline (the diff ends `\ No newline at
end of file`; the file ended with one before); doc-lint does not mind. (d) The decisions-log entry has one very long unwrapped
line (the `Get-CodeRepos` sentence) against the wrapped style of the entries above it. (e) The shipped/closed wording: the
decisions log carries the same caveat as the 017 entry ("built, reviewed and measured: the owner's gate and the human review at
merge are still to come"), the roadmap row says `shipped` as the 015-017 rows do, and the GAP-029 sentence says "closed by kit
feature 018" without the caveat. That is consistent with the project's precedent and not an overstatement, but the status flip
precedes the owner's gate and the human review; nothing in the roadmap row is wrong if the owner wants it left until merge.
*Action: author for (a)-(d); (e) none unless the owner wants the status held to merge.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None.** `tasks.md` changes are four checkbox ticks (T024-T027; T028 is not ticked: it is the ritual-checks and
isolated full-harness run, still pending, correctly left open). No change to `spec.md`, `plan.md`, `contracts/` or any task's
wording. The roadmap and `updating.md` edits are the T025/T027 deliverables.

## Constitution re-check (post-implementation)

**PASS.** No script, package, schema or constitution text changed. Constitution I (amendment authority): none made. Principle on
guidance matching behaviour (the documents are the law's interface for adopters): satisfied except F1/F2, which are inaccuracies
in prose, not a missing rule. `docs/sdlc/team-workflow.md` is a verbatim file, so F1 and F2 flow to adopters as written.

## Test coverage observed

No code or fixtures in this phase. Checks run: `pwsh -NoProfile -File scripts/ritual-checks.ps1`: `RESULT OK` (doc-lint,
enforcement-pack, scope-check including `PASS phase 4 commit ddc11fd`, digests `5 fresh, 87 markers`, roadmap-claims OK;
scope-repos and verify-kit not applicable to the kit repository). The whole enforcement harness was not run (the owner's session
is running it; T028 stays open). The behaviours the guidance describes are pinned by the TERR-001..022 fixtures except the
no-`codeRepos`-in-the-checked-out-tree case, which the harness has no fixture for as a case of "code repositories not read" (the
existing TERR-022 pass fixtures cover the declaration-absent text, not the trunk-has-it-but-the-branch-does-not shape of F1).

## Residual risk

The risk concentrates in F1: the guidance and the output are silent on the one case where a `CLEAN` still means "did not look
at the code repositories", and the flow-down note currently mislabels it, so an adopter in an old branch is the person the new
check does not protect and the documents do not warn. Fix F1 and F2 (both a sentence or two) before merge; F3 and F4 are small
accuracy gains in the table an owner uses when the output is unexpected. Everything else is wording. After merge the owner's
remaining decisions are the ones the phase 3 review left open and the decisions log records (the local-head fallback, the
`-Json` note, the shared `not-a-repository` test), plus whether SC-004's wording should be amended to the reading the notes
report. This review does not claim the gate passed; certification is the owner's.

---

## Round 2 — remediation commit `466f99c` (parent `ddc11fd`)

### Reviewer Provenance (Round 2)

- **Reviewer**: fresh-context agent — claude-sonnet-5-5 (a new session, not the round 1 reviewer's context)
- **Implementer**: claude-sonnet-5-5 (the implementing session)
- **Inputs provided**: `git show 466f99c` (stat and full diff of `adoption/updating.md`, `docs/sdlc/team-workflow.md`,
  `docs/roadmap.md`, `notes.md`, `tasks.md`); this review's round 1 findings F1-F8; the current
  `scripts/territory-check.ps1`; the recorded measurement material (`measure.ps1`, `measure2.ps1`, `measure2/rows.json`) from
  the implementing session's scratchpad; read and run access to throwaway repositories under the reviewer's scratchpad (a bare
  origin, a governance clone, a depth-1 clone). Nothing in the repository was modified except appending this section; nothing
  was committed.
- **Attestation**: This reviewer did not produce the diff under review.

### Verdict (Round 2)

**APPROVE.** F1-F8 are fixed as claimed, in documents only; the two items deliberately left to the owner (F6(e), F7(1)) are
stated as open, not dropped. No Blocker or Major remains. Two new, small inaccuracies were found (N1 Minor, N2 Nit); neither
blocks. This review does not claim the owner's gate passed; certification is the owner's.

### Evidence (Round 2)

| Area | Evidence |
|---|---|
| F1 (CLEAN over unread code) | `updating.md` now moves the case out of the "print UNGRADED" list ("One situation will make a healthy project print UNGRADED every time") and states it as a limit that prints `CLEAN` and "does not say the code repositories were skipped"; section 5 **Limits** says the same and that `-Branch X` reads the running checkout's record. Matches the code: `Get-CodeRepos -Root $repoRoot` reads the working tree; with nothing declared `$comparedNote = ''` and the original line prints. Re-ran: a branch with no `kit-adoption.json` prints `CLEAN - '011-a' shares no files ...` with no `compared` clause. `notes.md` stays honest that an audible warning is a script change for a follow-up. |
| F2 | "On a fully compared run, a project with no `codeRepos` (or an empty one) sees the original output unchanged": true. Item 1 of "What you will newly see" adds "Beside an unreadable `kit-adoption.json`" (wording: N2). |
| F3 | Row now names "not valid JSON" and "a bad entry skips only that entry; invalid JSON skips all code repositories". Re-ran invalid JSON in a project with no `codeRepos`: `UNGRADED: codeRepos: declaration unusable - kit-adoption.json is not valid JSON - no code repositories read ...`, closing UNGRADED line, exit 0. Bad-entry behaviour was verified in round 1. |
| F4 | Refspec action verified in a throwaway: with `remote.origin.fetch` narrowed to `main`, a claim prints `UNGRADED: governance: cannot compare 012-b (no remote-tracking ref origin/012-b)`; after `git fetch origin 012-b:refs/remotes/origin/012-b` the next run (which does `fetch --prune`) is `CLEAN`, so the ref survives prune; after restoring `+refs/heads/*:refs/remotes/origin/*` and fetching, also `CLEAN`. Both actions work. The second-variant clause is not supported as worded (N1). |
| F5 | `<repo>/<path>` and `specs/` are now in code spans. Re-wrap is partial: one line in section 5 is 117 columns and the Limits line still runs long; some updating.md and roadmap lines are long too. Cosmetic. |
| F6 (a)-(d) | (a) `updating.md` and `notes.md` now name the branch shapes (FlowBoard throwaway `099-measure` from `main`; ExpenseTracker once on `003-expense-entry`, once `-Branch` from `main`; FitForge `002-identity-member-profile`): matches `measure2.ps1`. "each of the three projects" is supported by `rows.json`: kit-head code-repos-absent is `UNGRADED` in all three. (b) discarded passes now stated in `updating.md` (wording: N2). (c) FitForge `ritual-checks` in `rows.json`: installed `enforcement-pack FAIL, scope-check OK` (1 of 7); kit-main and kit-head both `enforcement-pack FAIL, scope-check FAIL` (2 of 7). So "scope-check passing with the installed 0.7.0 scripts and failing once the kit before 018 was applied" and "the same two failing members at kit main and HEAD" are both exactly right. (d) "dry run taken in the discarded first pass only": `measure.ps1` runs `update-kit.ps1 -DryRun`, `measure2.ps1` does not. True. |
| F6(e), F7(1) left open | Commit message, `notes.md` ("Left for the owner: F6(e) ... F7(1) ..."), the roadmap decisions-log ("needs a task") and `updating.md` ("can drift until the shared test is built") all say so. Not silently dropped. Still the owner's. |
| F7(2) | Roadmap entry and `updating.md` Limits now list the two fixture-less behaviours (own branch existing only as `origin/<branch>`; a claim with no branch in a declared code repository). |
| F8 | (a) "a local branch wherever a repository has no `origin` or `origin` has no ref for that feature" matches the script (candidates `refs/remotes/origin/$other`, then `refs/heads/$other`, independent of `origin`). (b) trunk note "`main`, `master` or `origin/HEAD`, `origin/` forms first": right set; "origin/ forms first" is not quite true of `origin/HEAD` (actual order `origin/main, main, origin/master, master, origin/HEAD`; the table row lists it exactly). Nit. (c) the roadmap trailing newline is restored. (d) long lines remain, cosmetic. (e) GAP-029 now carries "Built, reviewed and measured; the owner's gate and the human review at merge are still to come." |
| Digests / doc-lint / checks | `git show 466f99c --stat`: no `docs/digests` file touched and no `<!-- digest: -->` line changed, so digests are as in round 1 (markers 106 and 118 characters, limit 120). `pwsh -NoProfile -File scripts/ritual-checks.ps1`: doc-lint OK, enforcement-pack OK, scope-check OK (`PASS phase 4 commit 466f99c (6 file(s))`), digests `OK (5 digest(s) fresh, 87 marker(s))`, roadmap-claims OK, `RESULT OK`. |
| Territory / tasks.md | The commit touches `adoption/updating.md`, `docs/sdlc/team-workflow.md`, `docs/roadmap.md` (Territory), plus the feature's own `notes.md`, `tasks.md` and this review file, the same set earlier phases committed; scope-check PASS. No script, test, fixture, `spec.md`, `plan.md` or `contracts/` change. The `tasks.md` diff is one line: `[ ] T028` to `[x] T028`. |
| T028 tick | Requires `ritual-checks` (re-run by me: `RESULT OK`) and the full harness on an isolated checkout of the final commit. The notes record the isolated harness as "1147 passed". **I did not re-run the harness and cannot confirm that figure**; I accepted it as recorded in the implementing session. The tick is not a claim of gate success. |

### New findings (Round 2)

**N1 — MINOR — `governance: cannot compare` row: the "branch that cannot be diffed against `main` (usually a shallow clone) ... deepen a shallow clone" clause is unsupported.**
`docs/sdlc/team-workflow.md`, cause table. The `cannot compare with main` detail arises only when `git rev-list --count main..origin/<feature>` fails while `origin/<feature>` exists, i.e. the base ref is unresolvable; but the own-branch diff against the same base runs earlier and exits 1 (a refusal, not an ungraded line), so this variant is effectively unreachable in a normal run. In a `--depth 1 --no-single-branch` clone the `rev-list` succeeds and the run printed `CLEAN`, not this variant; a plain `--depth 1` clone (single-branch refspec) prints the first variant, which the refspec action fixes and deepening does not. So "usually a shallow clone / deepen" is a guess presented as cause and action. (Separately, in a shallow clone a missing merge base makes the diff fail silently and the claim compares as empty: existing behaviour, outside this phase, and not addressed either way in the guidance.)
*Action: author, optional before merge. Drop "(usually a shallow clone)" and "deepen a shallow clone", or say only that the base branch cannot be resolved.*

**N2 — NIT — Two wording slips in `adoption/updating.md`.**
(a) "Two earlier passes were discarded because they folded in other features' changes (the kit before 018 versus the kit now, then a checkout that reverted the update)": `notes.md` says the first pass folded in other features' changes (installed to HEAD) and the second had a script defect (`git checkout -f` threw away the uncommitted apply). The sentence gives the first reason for both. (b) "Beside an unreadable `kit-adoption.json`": the case is a record that is not valid JSON (a missing file is not ungraded and prints `CLEAN`); "invalid JSON" is the precise word.
*Action: author, wording only.*

### Residual risk (Round 2)

The F1 limit is now documented, not audible: a branch without the trunk's `codeRepos` still prints `CLEAN` with no signal, and only the missing `compared ...` clause shows it. The remaining owner decisions are unchanged: SC-004 wording (F6(e)), the shared `not-a-repository` test as a task or GAP row (F7(1)), the local-head fallback, and the text-only `local branches only` note. The full enforcement harness result (1147 passed) is the implementer's record, not re-run here. This review does not claim the gate passed.
