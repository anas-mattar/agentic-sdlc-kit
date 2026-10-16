# Implementation Plan: claim-feature.ps1's ledger read and refused push are named states

**Branch**: `030-claim-ledger-read-named-state` | **Date**: 2026-10-16 | **Spec**: specs/030-claim-ledger-read-named-state/spec.md
**Input**: Feature specification (approved, anas.m, 2026-10-16; D1 A, D2 A, D3 A) + decisions P1–P8 below
**Gate Batching**: none
**Gate Certification**: user-run
**Amendment approved by**: anas.m, 2026-10-16

## Summary

`scripts/claim-feature.ps1` reads the remote ledger through `Get-RemoteFeatureHeads`, which ends in a terminating `throw`
when `git ls-remote` fails, and its race loop reads a rejected push as a lost race and ignores a failed withdrawal and a
failed re-fetch. Two phases, each independently revertible, as the owner decided (D3 A). Phase 1: the ledger read and the
rejected push (User Stories 1 and 2), with the harness's first way to fail a ledger read on a chosen call, fixtures first and
shown failing on the parent. Phase 2: the withdrawal and the re-fetch (User Story 3), the flow-down note, the roadmap and a
measurement over clones of the three adopted projects (User Story 4). No new script, no new library file, no verdict word
(the script has none); the harness gains recipe fields, and the plan fixes where each is probed before it is trusted.

## Technical Context

**Language/Version**: PowerShell 7+ (`pwsh`)
**Primary Dependencies**: none new
**Storage**: files and git state only
**Testing**: the enforcement harness (`tests/enforcement/`): real temporary git repositories, hand-written expectations, a
passing and a failing fixture per rule. Fixtures for this script run with the case's `noRoot` and the recipe fields feature
023 used (`origin` as a nested repository, `originPushUrl`, `copy`, a stub `create-new-feature.ps1`).
**Target Platform**: any runner with `pwsh` and `git`
**Project Type**: governance tooling (scripts plus documents)
**Constraints**: a successful claim and the seven refusals of feature 023 print the same bytes and exit the same way
(SC-001); the lane is Standard (spec, "Why this is Standard and not Micro")
**Scale/Scope**: one script changed, one to three recipe fields added (P5), about seven new rules' fixtures, one pre-existing
case re-expected (P6), three documents, digests

## Constitution Check

- [x] **Specification First (I)**: `spec.md` is approved (anas.m, 2026-10-16); this plan follows it; `tasks.md` follows.
- [ ] **Repository Separation (III)**: not applicable, the kit is one repository.
- [x] **Architecture Consistency (IV)**: no new file; `claim-feature.ps1` keeps its structure and stays standalone.
- [ ] **Domain Invariants (V)**: not applicable, the template's slot is unfilled.
- [x] **Security (VI)**: the script already pushes and may delete its own branch; the change touches only what it says and
  when it stops. A push the remote refuses for permission reasons is named and not retried, never worked around.
- [ ] **External Integration Governance (VII)**: not applicable.
- [x] **Testing Requirements (VIII)**: every reachable state has a passing and a failing fixture, hand-written; a state the
  harness cannot reach is exempt with a written reason (P6).
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI review with Reviewer
  Provenance. Constitution IX is unchanged.
- [x] **Controlled Delivery (X)**: two phases, one at a time. This changes an enforcement-adjacent script, so the owner runs
  the gate: no batching, no ci-held. No amendment of X is needed.

**Phase sizing rule**: phase 1 changes no output of a successful claim and is useful alone. Phase 2 depends on phase 1 (it
uses its harness fields and its message shape). Reverting 2, then 1, leaves a consistent kit.

**Post-design re-check**: no new violation. The plan has no decision left to the owner beyond approving it (see Needs the owner).

## Decisions

**P1 — A failed ledger read is reported as a value, not thrown (FR-001, FR-002).** `Get-RemoteFeatureHeads` stops throwing
and reports "could not read" distinctly from "read, and empty". The distinction matters: an empty ledger is a valid read
(a repository with no `NNN-*` branch), and PowerShell unrolls an empty array returned from a function to `$null`, so
`return @()` and a failure cannot be told apart by the return value alone. The function reports failure through a
separate channel (an `[ref]` out parameter or a script-scope flag the caller reads and resets; the choice is a task,
fixtured by both the empty-ledger `pass` and the failing read). The three callers each turn a failure into `Stop-Refused`
with the message their state calls for (P2). The existing `Stop-Refused` is reused; no new helper.

**P2 — The messages, fixed here so the fixtures can be written first (FR-001 to FR-004).** Each keeps the existing em-dash
register, goes to the error stream through `Stop-Refused`, and exits 1:

| State | Message |
|---|---|
| first read fails (105) | `git ls-remote failed — cannot read the remote ledger. Nothing was claimed.` |
| read fails after a push that succeeded (134) | `git ls-remote failed after pushing <branch> — the claim may already be live on origin. Check origin (git ls-remote --heads origin <branch>) before claiming again; nothing on origin was changed.` |
| read fails after a push that failed (134) | the rejected-push message below, followed by ` The ledger could not be read either.` |
| read fails after a re-fetch (145) | `git ls-remote failed — cannot read the remote ledger. <branch> was withdrawn from origin; nothing of ours is claimed, and the local branch and its spec directory remain.` |
| push rejected, no rival (136) | `git push of <branch> was rejected: <git's text>. Nothing was claimed; the local branch and its spec directory remain.` |
| withdrawal fails (140) | `Lost the allocation race but could not withdraw <branch> from origin — delete it by hand: git push origin --delete <branch>.` |
| re-fetch fails (144) | `git fetch origin failed — cannot claim against an unreachable ledger. <branch> was withdrawn from origin.` |

The wording of the first line of the re-fetch refusal is the first-fetch refusal's, unchanged (feature 023). Git's own text
for the rejected push is captured (the script discards it today) and printed as git wrote it.

**Amendment (2026-10-16): the wordings as built.** **Amendment approved by**: anas.m, 2026-10-16
The rejected-push row is laid out on several lines (the first line `git push of <branch> was rejected:`, then git's text on its own lines, then the closing sentence), because git's text is five lines; the sentences are as in the row, and the closing sentence also says to check `origin` for the branch (the Risks section's hedge). The re-read row has a second wording, `<branch> never reached origin`, for the state where our own push was rejected and a rival is also on `origin`; the re-fetch row uses the same two wordings. A new row for a push that reports failure but whose branch is on `origin` with no rival (a warning, then the claim is made): `git push of <branch> reported an error, but <branch> is on origin and no rival carries number <NNN> — treating the claim as made. git said:` followed by git's complaint on its own lines: its `error:`, `fatal:` and `remote:` lines, or all its text when it has none (git's progress lines reach the capture in an order nothing fixes, so a fixture cannot pin them).
**Amendment approved by**: anas.m, 2026-10-16

**P3 — The race loop's decision table (FR-003).** With `pushOk` and the rival list as the two inputs: push ok and no rival
is a success (unchanged); a rival with our number, whatever the push did, is the lost race, with the warning, the
withdrawal (only when the push landed), the renumber and the retry (unchanged, including the `claimed concurrently (...)`
line, whose list is now never empty); push failed and no rival is the rejected push, refused once with no warning and no
renumber. A failed ledger read in the failed-push row is the third row of P2.

**Amendment (2026-10-16): `landed`.** **Amendment approved by**: anas.m, 2026-10-16
**Amendment approved by**: anas.m, 2026-10-16
The first input is not `pushOk` alone but `landed`: the push exited 0, **or** the ledger just read shows `origin`'s branch of our name at our own commit (a push can exit non-zero after the remote accepted it). **The test is the commit, not the name** (phase 3 review finding F1): our number was free when it was allocated, but our branch **name** is not ours alone, because a second claimant with the same number and short name allocates the same name; a branch of that name at another commit is their push's, so it is not landed, is not a rival (the rival filter excludes our own name), and is never withdrawn. The sha comes from the same ledger read (no extra call), compared with our local branch tip. Landed and no rival is a success, with the new P2 warning when the exit code was non-zero; a rival is the lost race, with the withdrawal whenever the push landed (by either evidence) and `<branch> was withdrawn from origin` in the re-read and re-fetch wordings; not landed and no rival is the rejected push, refused once. When the ledger cannot be read the exit code is the only evidence, as before.

**P4 — Withdrawal and re-fetch are checked in phase 2, not phase 1 (D1 A, D3 A).** Phase 1 leaves lines 140 and 144 as
they are; phase 2 gives each its refusal (P2). This keeps phase 1's diff to the read and the rejected push, so a reviewer
can grade them apart.

**P5 — Harness fields, each probed before it is trusted (FR-006).** Three states need a field the recipe does not have.
Each is first tried in a throwaway fixture and the result recorded in `notes.md`, before any rule depends on it:
- *Fail the ledger read on the nth call*: `remote.origin.uploadpack` pointed at a small counting wrapper in the case
  directory that runs the real `git-upload-pack` and exits non-zero on the chosen call. A fetch and an `ls-remote` both
  go through it, a push does not, so the call count is deterministic (first fetch, first read, then each later read and
  re-fetch). Fallback if it misbehaves on Windows or on a runner: a `git` shim earlier on `PATH`, which the plan
  rejects as a first choice because it replaces every git call the script makes. Field name `originFailCall`, refused
  without `origin`, with a self-test.
- *Fail the withdrawal*: `receive.denyDeletes` set on the nested origin repository, so `git push origin --delete` is
  refused by git itself. Phase 2. Field name `originDenyDeletes`, refused without `origin`, with a self-test.
- *A rival that appears after allocation* (for the genuine lost race and for the re-fetch case): the case's stub
  `create-new-feature.ps1` creates a branch with our number in the nested origin as a side effect, which needs no new field
  because the stub is test code the recipe already places. The three-rivals state of line 142 would need a rival at every
  attempt; it is tried with a `pre-push` hook in the fixture and, if the harness cannot build it, left exempt (P6).
- *Amendment (2026-10-16), as built:* the three-rivals state was built not by a `pre-push` hook but by a `receive-pack` wrapper that runs the real one and then creates `<NNN>-rival` (field `originRivalOnPush`), so `CLF-007` kept its fixture. **Amendment approved by**: anas.m, 2026-10-16
- *Amendment (2026-10-16): a push that exits non-zero after the remote accepted it:* `remote.origin.receivepack` pointed at a counting wrapper that runs the real `git-receive-pack` and exits 1 on the chosen call (probed: the branch lands, upstream tracking is set, `git push` exits 1). Field `originPushFailsAfterLanding`, refused without `origin` and refused together with `originRivalOnPush` (both set `receivepack`), with a self-test.

**P6 — Rule ids, the pre-existing case, and the exempt count (FR-006, SC-005).** New rules, each with a pair differing in
one condition: `CLF-008` (first read fails), `CLF-009` (read fails after a push that succeeded), `CLF-010` (read fails after a
push that failed), `CLF-011` (read fails after a re-fetch), `CLF-012` (rejected push, no rival), `CLF-013` (withdrawal fails),
`CLF-014` (re-fetch fails). **`CLF-007`'s existing `fail` is re-expected by this feature**: it builds a push that fails with
no rival, which today prints three concurrent-claim warnings and the three-times refusal and, after phase 1, prints the
rejected-push refusal. That fixture moves to `CLF-012`, and `CLF-007` keeps site 142 only if a genuine rival at every
attempt can be built (P5, the `pre-push` hook); if it cannot, `CLF-007` becomes exempt with a written reason, the exempt count
rises by one and SC-005 allows it. Amendment (2026-10-16): `CLF-015` (a push that reports failure but whose branch is on origin, no rival, is a claim made) and `CLF-016` (the same beside a rival is withdrawn and renumbered), each a pair differing in one condition. The re-expectation is recorded in `notes.md` as a pre-existing case changed by the work, in
the way feature 028 recorded `AMEND-008/fail`.

**P7 — A baseline measures the parent before anything changes (spec, Assumptions).** Phase 1's first task records, on the
parent commit, what the `throw` exits with under `pwsh -File` and through the harness, the rejected-push output (the three
warnings and the refusal) and a successful claim's exact output in each state (no origin, an origin that takes the push,
`-NoPush`, one genuine renumbering), as saved text for the byte comparison. The spec leaves the throw's exit code unmeasured
on purpose; this is where it is measured.

**P8 — Adopter guidance, measurement, roadmap (FR-008).** `adoption/updating.md` gains a flow-down note in the shape of
feature 023's. `scripts/claim-feature.ps1` flows verbatim, so nothing is surgical. The measurement clones FitForge, FlowBoard
and ExpenseTracker from their local directories (never the real projects, nothing pushed), applies the kit before this
feature, then the kit as it stands, and runs a claim with `-NoPush` in each state on a fresh clone, plus `doc-lint.ps1` and
`ritual-checks.ps1`; every line that moves is listed with its cause. `docs/roadmap.md` closes GAP-036, marks the row
`shipped` and adds a decisions-log entry dated the day the feature ships, recording D1 A, D2 A, D3 A and what the work corrected.

## Phases

Detailed tasks and the per-phase **Territory** blocks are in `tasks.md`.

1. **The ledger read and the rejected push.** P1, P2 (rows 1 to 5), P3, P5 (the failing read), P6 (`CLF-008` to `CLF-012`,
   and the `CLF-007` decision), P7. Delivers User Stories 1 and 2 and FR-001 to FR-003: fixtures first and shown failing on the
   parent, the script, the harness field and its self-test.
2. **The withdrawal, the re-fetch, guidance and measurement.** P4, P5 (the denied withdrawal), P6 (`CLF-013`, `CLF-014`), P8.
   Delivers User Stories 3 and 4 and FR-004, FR-006 (the rest), FR-008, SC-001.
3. **A push that reports failure but landed (amendment, 2026-10-16).** P3 (`landed`), P5 (`originPushFailsAfterLanding`), P6 (`CLF-015`, `CLF-016`), the User Story 2 scenarios 4 and 5 and FR-003 as amended. **Amendment approved by**: anas.m, 2026-10-16

## Project Structure

### Documentation (this feature)

``text
specs/030-claim-ledger-read-named-state/
├── spec.md
├── plan.md              # this file
├── tasks.md
├── notes.md             # baseline, probes, the re-expected case, the measurement
└── checklists/requirements.md
``

No `research.md`, `data-model.md` or `contracts/`: the script has no data model, and its CLI contract
(`specs/003-flow-efficiency-pack/contracts/claim-feature-cli.md`) is unchanged: exit codes and the `-Json` object stay, only
the refusal text of states that previously died in a `throw` or in the three-times message is new.

### Source Code (repository root)

``text
scripts/claim-feature.ps1                 # phase 1: P1, P2, P3; phase 2: P4 (140, 144)
tests/enforcement/rules.json              # phase 1: CLF-008..CLF-012 and CLF-007; phase 2: CLF-013, CLF-014
tests/enforcement/lib/FixtureRepo.psm1    # phase 1: originFailCall; phase 2: originDenyDeletes
tests/enforcement/Harness.Tests.ps1       # phase 1 and 2: self-tests for the fields
tests/enforcement/cases/claim-feature/    # phases 1 and 2: fixtures, stubs, the counting wrapper
tests/enforcement/emission-idioms.json    # only if the sweep reports a new site
adoption/updating.md                      # phase 2: flow-down note
docs/roadmap.md                           # phase 2
docs/digests/**                           # phase 2, if a digest-marked document changes
``

**Structure Decision**: no new script and no new library file; `scripts/claim-feature.ps1` already ships verbatim, so
`kit-manifest.json` needs no entry. `scripts/territory-check.ps1` and `scripts/roadmap-claim-check.ps1` are untouched.

## Testing Strategy

- Each rule is first written as a failing fixture and shown failing on the parent commit, then the behaviour lands. The
  harness runs the script with the case's working directory set to the fixture (`noRoot`).
- Phase 1 fixtures: a `fail` and a `pass` for each of `CLF-008` to `CLF-012`. The `fail` expects the P2 message and exit 1
  (not the launcher's 97 or 128, and not a PowerShell error record); each `pass` differs only in the one condition (the read
  succeeds, the push is accepted). Success-path `pass` cases pin the output a successful claim prints today, including one
  genuine renumbering built by a stub that creates a rival; every `CLF-001` to `CLF-006` case is unchanged.
- The full harness runs on an isolated checkout of the final commit (feature 022's method); `-Case CLF-`, `-Case TERR-` and
  `-Case RIT-` per phase. Every pre-existing case is unchanged except the one named in P6.
- The baseline of P7 and the measurement of P8 are recorded in `notes.md`.

## Risks

- **The counting `uploadpack` wrapper may behave differently on Windows and on a Linux runner.** The probe (P5) runs on
  both before a rule depends on it; the fallback is a `PATH` shim, recorded in `notes.md` if taken.
- **PowerShell unrolls an empty array to `$null`.** A function that reports failure by returning `$null` is
  indistinguishable from one that read an empty ledger; P1 names the separate channel and the empty-ledger `pass` pins it.
- **`CLF-007` may lose its fixture.** If a rival at every attempt cannot be built, the rule is exempt with a written reason
  and the exempt count rises by one (P6); the plan says so now so it is not discovered at the gate.
- **A push that fails but landed.** *Amendment (2026-10-16), review finding F1 of phase 1:* the ledger read after the push shows it, and the script reads the push as landed (P3). The residual case is a push that fails and landed while the ledger cannot be read: the exit code is then the only evidence, and the rejected-push message keeps its hedge to check origin for the branch. **Amendment approved by**: anas.m, 2026-10-16
- **Message text with line breaks.** Git's rejection text is multi-line; the expectation is written by hand with those
  breaks and a fixture whose rejection text is fixed.
- **The stub is test code the harness runs.** A stub that drifts from the real script's output contract (`BRANCH_NAME`)
  would make success cases pass for a script that cannot claim; its contract stays a comment in each stub, and the real
  script is exercised in phase 2's measurement.

## Needs the owner

1. **Decided (anas.m, 2026-10-16, by approving the plan as written): P1 to P8.** There were no open options: D1, D2 and D3 were
   decided with the spec. `tasks.md` follows.
2. **Worth a look before approving**: P2's message wording (the fixtures will pin it byte for byte), and P6's admission that
   `CLF-007` may become exempt.

## Complexity Tracking

No constitution violation to justify. One pre-existing case is re-expected (P6), disclosed here and in `notes.md`.
