# Implementation Plan: claim-feature.ps1 tells a same-base rival from our own claim

**Branch**: `031-claim-same-base-rival` | **Date**: 2026-10-16 | **Spec**: specs/031-claim-same-base-rival/spec.md
**Input**: Feature specification (approved, anas.m, 2026-10-16; D1 B' as amended, D2 A, D3 A) + decisions P1–P8 below
**Gate Batching**: none
**Gate Certification**: user-run

## Summary

A claim leaves the branch at `main`'s sha, so two claimants of one number and short name push the same ref value, and the
second push is `Everything up-to-date` with exit 0: the script reports a claim it did not make (measured, `notes.md`). The
plan reads the push's own status instead: `git push --porcelain` reports `*  [new branch]` for the claimant that created the
ref and `=  [up to date]` for one whose branch already existed at its sha. That second case is a same-base rival: the script
treats it as a lost race (D2 A), renumbers through its existing loop and withdraws nothing, because the branch on `origin`
is not ours. The change is in `scripts/claim-feature.ps1` alone; the claim stays uncommitted. The fixtures plant the rival with
the stub `create-new-feature.ps1` that `CLF-017` already uses, so the harness gains no recipe field (see Needs the owner).

## Technical Context

**Language/Version**: PowerShell 7 (`pwsh`), git 2.55 (measured; the plan's first task re-measures on the CI image's git)
**Primary Dependencies**: none new; `git push --porcelain` is a documented, stable git interface
**Storage**: N/A (a branch on a remote is the claim)
**Testing**: the fixture harness (`tests/enforcement/`, Pester), real temporary git repositories, hand-written expectations
**Target Platform**: Windows and Linux runners (the kit's CI)
**Project Type**: governance kit; command-line script
**Performance Goals**: N/A
**Constraints**: a claim without a rival, `-NoPush`, no `origin`, and the refusals of features 023 and 030 print what they print
today (spec FR-003, FR-004), except the one carve-out named in Needs the owner
**Scale/Scope**: one script, two to three fixtures, one flow-down note

## Constitution Check

- [x] **Specification First (I)**: `spec.md` is approved (anas.m, 2026-10-16, D1 amended to B'); this plan follows it; `tasks.md` follows.
- [ ] **Repository Separation (III)**: not applicable, the kit is one repository.
- [x] **Architecture Consistency (IV)**: no new file; `claim-feature.ps1` keeps its structure and stays standalone.
- [ ] **Domain Invariants (V)**: not applicable, the template's slot is unfilled.
- [x] **Security (VI)**: the script may delete only a branch it pushed, and after this change it still never touches one it did not (FR-002); nothing is worked around.
- [ ] **External Integration Governance (VII)**: not applicable.
- [x] **Testing Requirements (VIII)**: the new state has a passing and a failing fixture, hand-written, the failing one shown failing on the parent commit (P5).
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI review with Reviewer Provenance.
- [x] **Controlled Delivery (X)**: two phases, one at a time. This changes a script the team runs to claim every feature, so the owner runs the gate: no batching, no ci-held.

**Phase sizing rule**: phase 1 changes the script and proves it, and is useful alone. Phase 2 is documentation, the roadmap and the
measurement on adopted-project clones, and depends on phase 1 only for the text it describes. Reverting 2, then 1, leaves a consistent kit.

**Post-design re-check**: no new violation. Two points need the owner before phase 1 (Needs the owner).

## Decisions

- **P1 - how a claim is told from a rival's (D1 B').** Push with `git push --porcelain -u origin $branch`, keep `$pushText`, and
  call the push a **same-name rival** when it exited 0 and a line matches `^=\s+refs/heads/<branch>:` (an up-to-date ref of our
  own name). The exact line shape is measured in task 1 and pinned by the fixtures; the match is anchored on the flag and the
  ref, not on git's bracketed words.
- **P2 - what the script does with it (D2 A).** `$landed` becomes `$pushOk -and -not $sameName`, so the withdrawal at the existing
  `if ($landed)` is never run for it: the branch is not ours. The warning is a sentence of its own naming the branch ("a claimant
  of the same number and short name already pushed it; it is theirs and is left alone"), then the loop's existing steps: fetch,
  re-read the ledger, allocate the next number, rename, push again. The `$gone` text for this state says the branch on `origin`
  is the other claimant's and was left alone; the "never reached origin" wording is not true of it. After the third loss the
  existing `Lost the allocation race 3 times` refusal ends it.
- **P3 - the upstream.** `-u` set the local branch's upstream to the rival's `origin/<branch>` before the script knew. When the
  same-name rival is detected the script runs `git branch --unset-upstream` so the local branch never tracks a branch it does
  not own, whether the next attempt succeeds or the loop ends in a refusal. A failure of that command is not a refusal: the next
  push sets the upstream anew.
- **P4 - no other reading changes.** The `$rivals` filter (`$_ -ne $branch`) stays: a same-name branch is classified by P1, not
  by the ledger, because only the push can tell ours from theirs. Feature 030's landed-by-commit rule (`:162-165`) stays for a
  push that exited non-zero. A same-name, same-sha branch that appears **before** the ledger read needs no change: allocation
  already sees the name and takes the next number.
- **P5 - tests (FR-005).** Written first, shown failing on the parent commit:
  - **`CLF-018`** (`fail`, `pass`): the stub `create-new-feature.ps1` pushes `NNN-S` to `origin` at `main`'s sha after the
    ledger read and before the push (the `CLF-017` mechanism: `git -C origin.git branch $b main`). `fail` (this feature's
    behaviour) is the claim renumbered to the next number with the same-name branch left on `origin`, exit 0; `pass` is the same
    fixture without the rival, a claim that succeeds with the output of today. On the parent the first prints `CLAIMED:` for a
    branch it did not push.
  - **`CLF-019`**: the stub plants the rival on every attempt, so the loop ends in `Lost the allocation race 3 times`, exit 1,
    and every planted branch is still on `origin` (FR-002).
  - A genuine rival of another short name and one renumbering are pinned by the existing cases, unchanged.
  Each rule is inventoried in `tests/enforcement/rules.json` with its `emitAnchor`; the coverage report must show no unowned site.
- **P6 - the rejected-push text (the carve-out).** `--porcelain` moves git's `! [remote rejected] ...` line from stderr to stdout
  in a tab-separated form, so the git text quoted inside feature 030's rejected-push refusal changes its layout (measured,
  `notes.md`). The script's own sentences do not change. The fixtures that quote it (`CLF-012` and `CLF-017`, and any other whose
  `expected.txt` carries git's rejection lines; task 2 lists them) are re-expected by hand and disclosed, as feature 030 did
  for `CLF-007`. This needs the owner's approval because the spec's FR-004 says those states keep their text.
- **P7 - the harness field.** Spec FR-005 and Assumptions call for a recipe field that plants the rival. `CLF-017` shows the stub
  can do it with no harness change, so no field is built unless the owner wants one (Needs the owner).
- **P8 - guidance and close (FR-007, phase 2).** `adoption/updating.md` gains a flow-down note in the shape of feature 030's;
  `docs/roadmap.md` closes GAP-037, records the decision and marks the row `shipped`; digests are regenerated only if a
  digest-marked document changed (`scripts/build-digests.ps1`, which CI checks).

## Phases

Detailed tasks and the per-phase **Territory** blocks are in `tasks.md`.

1. **Measure, prove, change.** Baseline harness and the measurement of P1 on the parent commit; P5 fixtures first and shown
   failing; P1 to P4 and P6 in the script. Delivers User Story 1 and FR-001 to FR-006.
2. **Guidance, close, measure on clones.** P8, the measurement of SC-002 on clones of each adopted project (each clone's
   origin a bare copy; nothing pushed to the real projects), and the full harness on an isolated checkout. Delivers User Story 2's
   guidance, FR-007 and SC-001 to SC-003.

## Project Structure

### Documentation (this feature)

```text
specs/031-claim-same-base-rival/
├── spec.md
├── plan.md              # this file
├── tasks.md
├── notes.md             # the measurements, the baseline, the re-expected cases
└── checklists/requirements.md
```

No `research.md`, `data-model.md` or `contracts/`: the script has no data model, and its CLI contract
(`specs/003-flow-efficiency-pack/contracts/claim-feature-cli.md`) is unchanged: arguments, exit codes and the `-Json` object stay.

### Source Code (repository root)

```text
scripts/claim-feature.ps1                 # phase 1: P1 to P4 (the push at the claim loop)
tests/enforcement/rules.json              # phase 1: CLF-018, CLF-019 (and the re-expected cases of P6)
tests/enforcement/cases/claim-feature/    # phase 1: CLF-018, CLF-019; P6's re-expected expectations
adoption/updating.md                      # phase 2: flow-down note
docs/roadmap.md                           # phase 2
docs/digests/**                           # phase 2, only if a digest-marked document changes
```

**Structure Decision**: no new script and no new library file; `scripts/claim-feature.ps1` ships verbatim, so
`kit-manifest.json` needs no entry. `tests/enforcement/lib/FixtureRepo.psm1` is untouched unless the owner asks for the field (P7).

## Testing Strategy

- Each rule is written as a failing fixture and shown failing on the parent commit, then the behaviour lands. The harness runs
  the script with the case's working directory set to the fixture (`noRoot`).
- `CLF-018` and `CLF-019` differ from their neighbours only in the planted branch; the `CLF-004` success cases and every other
  `CLF-001` to `CLF-017` case are unchanged except the ones P6 names.
- The full harness runs on an isolated checkout of the final commit (feature 022's method); `-Case CLF-` and `-Case TERR-` and
  `-Case RIT-` per phase. The baseline (1805 on `95d4725`, as feature 030 left it) is re-taken on the parent commit and recorded.
- The measurement of SC-001 repeats the throwaway-`origin` run of `notes.md` against the changed script, with the same `git` shim.

## Risks

- **`--porcelain` output shape.** The `=` and `*` lines are documented, but the bracketed words and the order of stdout and stderr
  are not. The match is anchored on the flag and the ref (P1), and a fixture of each shape pins it; the first task re-measures on
  the CI image's git as well as the local one.
- **The git text of a rejected push changes** (P6): disclosed and hand re-expected; approved by the owner, 2026-10-16.
- **An up-to-date push that is not a rival.** A branch of our name at our sha on `origin` that we pushed ourselves in an earlier
  run would read as `=`. A rerun after a landed claim allocates the next number, so the script cannot reach it in one run; the
  plan names it so a reviewer does not rediscover it.
- **`git branch --unset-upstream` on a branch with no upstream** exits non-zero; P3 treats it as not a refusal.
- **The stub is test code the harness runs.** The planted branch lives in the stub (`git -C origin.git branch $b main`); its
  contract stays a comment in each stub, as in `CLF-017`.

## Needs the owner

1. **Decided (anas.m, 2026-10-16), and recorded in the spec by an amendment (`**Amendment approved by**: anas.m, 2026-10-16`):**
   - **FR-004 carve-out (P6).** The git text quoted inside feature 030's rejected-push refusal may change its layout, because
     `--porcelain` moves it; the script's own sentences and every other refusal stay byte for byte.
   - **FR-005 and Assumptions (P7).** No recipe field: the stub plants the rival, as `CLF-017` does.
2. **Still open, worth a look before approving the plan**: the wording of P2's warning (the fixtures pin it byte for byte).
## Complexity Tracking

No constitution violation to justify. The re-expected cases of P6 are disclosed here and in `notes.md` once measured.
