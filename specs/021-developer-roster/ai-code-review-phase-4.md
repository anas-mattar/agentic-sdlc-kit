# AI Code Review — 021 Load-bearing Developer Roster, phase 4 (guidance, flow-down and bookkeeping)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-12
**Branches**: kit repository `021-developer-roster` (phase 4 commits `382f5da`, parent `666fddc`, and the notes commit `ee81ad9`)
**Scope reviewed**: `git diff 666fddc ee81ad9` in full: `docs/sdlc/critical-delivery.md`, `docs/sdlc/team-workflow.md`, `adoption/updating.md`,
`adoption/greenfield.md`, `docs/roadmap.md`, the three regenerated digests, `specs/021-developer-roster/notes.md` and `tasks.md`; against spec US5,
FR-010 to FR-012, SC-001, SC-003, SC-004, plan D9, D10 and Risks, and the shipped scripts as at `ee81ad9` (`adoption-lib.ps1`, `verify-kit.ps1`,
`enforcement-pack.ps1`, `roadmap-claim-check.ps1`, `ritual-checks.ps1`).
**Feature contract**: documents and bookkeeping only; no script change; Territory is the five guidance/bookkeeping paths plus `notes.md`/`tasks.md`;
every sentence about what a check does must match the script.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-sonnet-5-5 (separate session that produced the phase 4 commits `382f5da` and `ee81ad9`)
- **Inputs provided**: phase 4 diff (`666fddc` to `ee81ad9`), CLAUDE.md, review-process.md, the review template, spec.md, plan.md, tasks.md, notes.md,
  the five scripts above, the phase 2 review as shape precedent
- **Attestation**: This reviewer did not produce the diff under review.
- **Prior involvement**: none. Fresh context; notes.md was read as a claim and checked, including its measurement.
- **Commands run**: `git diff --stat` and `git diff 666fddc ee81ad9`; in a detached worktree of `ee81ad9` outside the repository: `pwsh -File scripts/doc-lint.ps1`,
  `scripts/build-digests.ps1 -Check`, `scripts/ritual-checks.ps1 -Branch 021-developer-roster`, `scripts/scope-check.ps1 -Branch 021-developer-roster`;
  a scratch git repository with a bare `origin` (scratchpad, deleted) running `scripts/roadmap-claim-check.ps1` with a two-name roster, a one-name roster
  and none, claims dated now, 13 days and 15 days ago; `Get-DeveloperMode` on a record with a non-boolean `canApproveCritical`; a local `git clone` of
  `D:\solutions\flowboard` into the scratchpad with `scripts/update-kit.ps1` from the detached worktree, then `ritual-checks.ps1`, `build-digests.ps1`
  and `doc-lint.ps1` in the clone (clone deleted afterwards; nothing pushed, the real project untouched). The worktree is removed at the end.

## Verdict

**REQUEST CHANGES.** The guidance is, sentence for sentence, almost entirely true to the scripts, the digests are fresh and within 120 characters, the
flow-down file list is exact, the roadmap flip is right and SC-004 is met. But one defect breaks the feature's own promise (SC-003, FR-011, "no verdict
moves"): `adoption/updating.md` line 883 names `specs/021-developer-roster/notes.md` in backticks, a path that exists only in the kit repository. In an
adopted project that path does not resolve, so `doc-lint` fails and `ritual-checks` is `RESULT FAIL` on the very run the update note tells the adopter to
make (F1). I reproduced it on a clone of FlowBoard. It also falsifies the measurement paragraph. It is a one-line fix in a document, then re-run. The
remaining findings are minor. Certification of the gate is the owner's; nothing here claims it passed.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Non-boolean `canApproveCritical` denies | `Get-DeveloperMode` on `["ada",{"name":"grace","canApproveCritical":"no"}]`: grace `CanApproveCritical = False`, Mode `team`, and a problem naming entry 2. Matches critical-delivery and the update note. |
| Reviewer reading, team arm only | `Invoke-CriticalTeamEvidence` fails a Reviewer not on the roster (message names the Reviewer and the declared names) and one whose entry does not permit, via `OrdinalIgnoreCase`; `Invoke-CriticalSoloEvidence` is not passed the roster. `Grace Hopper` against `grace` is a mismatch. All as documented. |
| One-name roster grades Owners | Scratch repo, `["ada"]`: `Grace H.` fails "not on the developer roster ... (ada)"; the WIP finding also fires. A roster of one name is a roster. With `{}`: output `OK (4 claim(s) ..., own claim 099 exempt)`, no suffix, no new line. |
| WIP boundary and stale rule | Three claims for `ada`, tips now, 13 days, 13 days: FAIL "holds 3 active claims". With the third tip 15 days old: only two counted, the note is printed, `OK`. Exactly two prints the note and exits 0. Code uses `now - ct <= 14 days`, so "a commit in the last 14 days" is right (the boundary second is not separately fixtured by me). |
| Owner reading details | Owner cell `Grace H.` is a stranger; blank and em-dash are skipped (`$_.Owner -ne '—'`); the own-number claim is exempt; rows with different Owners print "not graded" and set UNGRADED; a missing tip object triggers one `git fetch` then UNGRADED. A claim is bound by a delimited token, preferring the row holding `specs/<claim>`. All as `team-workflow.md` says. |
| OK-line suffix | The suffix `, Owners and claim counts graded against the declared roster` is printed only when a roster is usable, an Owner column exists and no claim was skipped for lack of one; the `{}` run shows it absent. |
| Doctor line | `verify-kit.ps1` prints `roster read from kit-adoption.json: ...` only when `HasObjectEntries`; a strings-only record adds nothing. True. |
| `ritual-checks` lifts UNGRADED | `ritual-checks.ps1` documents and implements the `<member>: UNGRADED` roll-up; `CLAIM-014` exists in `rules.json`. True. |
| Digests | `build-digests.ps1 -Check`: `OK (5 digest(s) fresh, 96 marker(s))`. The seven new markers measure 118, 116, 115, 119 and 120 characters or fewer (the two in `team-workflow.md`/`critical-delivery.md` checked; all within 120). `doc-lint`: `OK` on the kit; markers sit after paragraphs, none inside a table or list. |
| Flow-down list | `kit-manifest.json`: `scripts/*.ps1` verbatim, `adoption/**` verbatim, `docs/sdlc/critical-delivery.md` and `team-workflow.md` verbatim, `docs/digests/*-digest.md` generated (never copied), `digest-packs.json` verbatim. The note's file list (five scripts, four documents) equals `git diff --name-only 85b944f ee81ad9` over `scripts adoption docs/sdlc`. No manifest entry is needed. The clone run listed exactly these as `copied`. |
| Roadmap row | Status `shipped`, Owner `anas.m`, spec link `specs/021-developer-roster/` unbracketed; row text otherwise unchanged (see F4). Decisions-log entry: states what stays open by decision (membership is not identity, `repos` read by nothing, GAP-024 (b) and (c) open, one-name-roster and exact-cell caveats) and ends "the owner's gate and the human review at merge are still to come". GAP-024 (a)/(b)/(c) match the register. No overclaim found. |
| SC-004 | `team-workflow.md` "What the machine counts, and what it cannot see" is one page-local subsection: what is counted, the cap, the note, the UNGRADED case, and a paragraph headed "What only a human can see" (pull request open, territory disjointness, identity). Met. |
| Scope | `git diff --stat 666fddc ee81ad9`: ten files, all in Territory (nine documents/digests and `notes.md`/`tasks.md`); no script, no test, no manifest change. `scope-check.ps1 -Branch 021-developer-roster`: `PASS phase 4 commit ee81ad9 (2 file(s))`; notes.md reports PASS (10 files) on `382f5da`, consistent with the file list. |
| Ritual | `ritual-checks.ps1 -Branch 021-developer-roster` on `ee81ad9`: doc-lint OK, enforcement-pack OK, scope-check OK, scope-repos n/a, digests OK, roadmap-claims OK, verify-kit n/a, `RESULT OK`. This is the kit; see F1 for the adopted case. |
| Measurement re-run, one clone | FlowBoard clone, baseline (`git stash` of the update) `doc-lint` OK. After `update-kit.ps1` from `ee81ad9`: `ritual-checks` `RESULT FAIL (2 of 7)`: `digests` stale and **`doc-lint` FAIL** (`adoption/updating.md:883 specs/021-developer-roster/notes.md` does not resolve). After `build-digests.ps1`: `digests` OK, **`doc-lint` still FAIL**, `RESULT FAIL (1 of 7)`. `verify-kit` OK, `enforcement-pack` OK, `roadmap-claims` OK. (I applied the current kit in one step, not via `85b944f` first; the failing line is in the current kit's `updating.md`, so the order does not matter.) |

## Findings

### F1 — The update note's dangling spec path makes `doc-lint`, and so `ritual-checks`, fail in every adopted project after the update — MAJOR (blocks)

`adoption/updating.md:883` reads "Every line that changed between the two states is listed in `specs/021-developer-roster/notes.md`". `adoption/updating.md` is
verbatim and flows down, but `specs/021-developer-roster/` does not. In an adopted project `doc-lint` resolves every backticked path, finds none, and reports
`ERROR: 1 referenced path(s) do not resolve`, exit 1; I reproduced it on a FlowBoard clone before and after the digest rebuild. The kit's own run is green
because the file exists there, which is why nothing in the kit's CI caught it. This contradicts the claim in the same note that `ritual-checks.ps1` "was
`RESULT OK` once the digests were rebuilt", the update note's promise of what to do ("take the update, run `build-digests.ps1`, run `ritual-checks.ps1`"),
SC-003 and FR-011 ("no verdict moves", a moved verdict is a finding), and the measurement in notes.md, which records `RESULT OK` for all three projects in
S2. (Presumably the measurement ran before this sentence was added; it was not re-run after.) The existing precedent at `updating.md:354,360` mentions a
`specs/014-...` path only inside an example block, which `doc-lint` exempts.
*Action: remove the path-shaped token. Name the file without backticks as a path (for example "the feature's `notes.md` in the kit repository") or put it in an
exempt context; check every other kit-only path in the five flowing documents the same way. Then re-run the T018 measurement on at least one clone,
including `doc-lint.ps1`, and correct notes.md's T018 table and the update note's "What was measured" paragraph to what that run shows.*

### F2 — "Every member was OK in every state" overstates what notes.md itself records — MINOR

The "What was measured" paragraph says every member was `OK` in every state of every project, and `RESULT OK` once the digests were rebuilt. notes.md says
`ritual-checks` was `RESULT FAIL` as applied (stale digests) in S1 and S2, and its table row says `RESULT OK, all three states` while the prose below says
otherwise. The prose is the honest one; the table row and the update note's first sentence are not. The same note does tell the adopter to rebuild the digests
(so the failure is documented elsewhere in it), and the failure is the pre-existing flow-down step, not new. Fold into F1's re-measurement.
*Action: state, in both places, that the `digests` member fails as applied and is OK after `build-digests.ps1`.*

### F3 — "A non-empty `developers` after blank and non-string entries are dropped" is no longer exact — MINOR

`team-workflow.md` ("Everything below is graded only where ... a non-empty `developers` list after blank and non-string entries are dropped") and the update
note ("a non-empty `developers` after blank and non-string entries are dropped") repeat the pre-021 wording. Since this feature an **object** entry with a usable
name is a developer, so "non-string entries are dropped" is false for it; an object without a usable `name` is dropped (and reported by the doctor). The
unchanged sentence in `critical-delivery.md` ("The count is taken after non-string and blank entries are dropped") has the same drift, and sits two paragraphs
above the new text describing object entries. The behaviour is right; the sentence misdescribes the reader.
*Action: say "blank entries and objects without a usable name are dropped" in the three places.*

### F4 — The shipped roadmap row still says "at most one active claim per Owner" — MINOR

The brief for T019 keeps the row text unchanged and it is, but the row now reads `shipped` while describing a rule the shipped checks do not implement (the
counter fails above two). The decisions-log entry says so ("Corrected by the work"), and notes.md records it, so the record is honest; a reader of the row
alone is misled.
*Action: owner's call. Either leave it with the log entry as the correction (current state), or amend the row's parenthesis to "at most two active claims per
Owner, exactly two being a note" in a recorded amendment.*

### F5 — The "Observation for the owner" on SC-001 is accurate but narrower than the truth and asks for no decision — MINOR

SC-001 (every verdict a string-only roster produced is byte-identical) against FR-005 to FR-007 is correctly identified as a conflict, and the stated remedy
(the update note does not claim byte-identity for every roster) is fair. But the observation names only "a team project with a string roster whose Reviewer
or roadmap Owner is not on it". Three further classes also move verdict, all proved by my scratch runs and partly named in the update note: a **one-name**
roster whose Owners are spelled differently (the likeliest first red run, per the update note itself), a string roster with a **third active claim** for one
Owner, and a string roster whose Owner cell holds more than one name. The roadmap entry says "a project that ... keeps to names that match, sees no verdict
move" and is accurate. The observation is addressed "for the owner" yet requests nothing; SC-001 as written remains false as a statement and no spec amendment
is proposed (the Owner amendment of 2026-10-11 covered only the no-roster silence).
*Action: list all four classes in the observation and propose, for the owner's approval, the rewording of SC-001 ("... byte-identical except where a declared
roster does not match the Reviewer, Owner or claim count the new checks read").*

### F6 — Minor omissions in the "does not change" paragraph — NIT

The update note's roadmap-claims paragraph says the OK line gains the suffix "only when it graded them". True, but a roster with no `Owner` column prints
`roadmap-claims: not graded — ... no Owner column` and still exits 0 with OK (no UNGRADED verdict, no suffix); that line is not documented anywhere in the
guidance. The doctor line is printed for an object entry that has a usable name, not for any object (an unnamed object sets no flag); the guidance says "an
entry is an object". The file `roadmap.md` and `notes.md` also lose their trailing newline in these commits. None affects a verdict.
*Action: optional.*

## Amendments in this diff

None. No approved feature document (`spec.md`, `plan.md`, `tasks.md` scope) is amended; `tasks.md` has only the T015 to T020 boxes ticked. Nothing is claimed
as approved by the implementer.

## Constitution re-check (post-implementation)

Constitution I (amendment authority): unchanged, none made. IV (spec first): the guidance follows the approved spec and plan; FR-012 (`repos` read by nothing)
is stated three times and is true. VIII (testing): no script change, the harness is not affected; notes.md's 1327-passed run was on `382f5da` and the diff
since is documents only (confirmed by `git diff --stat`). X (controlled delivery): phase 4 only, no gate claimed; the notes end "the owner's gate ... still to
come". No violation, subject to F1 being corrected before the gate.

## Test coverage observed

I did not re-run the full 1327-case harness (phase 4 changes no script or fixture; verified by `git diff --stat 666fddc ee81ad9` showing no `scripts/` or
`tests/` path). `doc-lint`, `build-digests -Check`, `ritual-checks -Branch 021-developer-roster` and `scope-check` pass on the kit at `ee81ad9`. The one gap that
produced F1 is that nothing in the kit's CI runs `doc-lint` as an adopted project would see it; the T018 measurement was the only such check, and it did not
cover the final text of `updating.md`.

## Residual risk

After F1 is fixed, the residual risks are the ones the documents name: roster membership is not identity; an Owner cell must be exactly one roster name; a
solo project with a one-name roster may see a first red run; and the Reviewer, counter and UNGRADED paths are proved by fixtures, not by an adopter's case.
A further risk worth a sentence in the next flow-down note: any later edit to a verbatim document that mentions a kit-only path will fail adopted CI the same
way; a cheap guard would be a kit-side check that the verbatim documents contain no path that resolves only in the kit (candidate for a roadmap gap, not
this phase).
