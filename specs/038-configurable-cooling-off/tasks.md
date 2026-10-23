---

description: "Task list for feature 038 — the Critical solo-mode cooling-off period is read from the adoption record instead of a constant"
---

# Tasks: Configurable cooling-off period

**Input**: `specs/038-configurable-cooling-off/spec.md` (approved, anas.m, 2026-10-22), `plan.md` (approved, anas.m, 2026-10-22; decisions P1–P9), `research.md`, `data-model.md`, `contracts/kit-adoption-cooling-off.md`, `quickstart.md`
**Amendment approved by**: anas.m, 2026-10-23
**Prerequisites**: spec.md and plan.md approved; tasks.md approved (anas.m, 2026-10-22); no new dependency; no new script; one new Pester file under `tests/enforcement/`

**Tests**: every new behaviour ships with a passing and a failing harness fixture in the same phase, expectations written by hand (feature 015). New fixtures are written first and run against the parent commit, where they must fail, before any script changes. The rule ids below (`CRIT-C*`, `VK-033` onward) are provisional: the coverage sweep decides how many emission sites there are, and the ids follow it.

**Organization**: four phases, each independently revertible, reverted in the order 4, 3, 2, 1. Phase 3 depends on phase 1 only. The full harness is run on an isolated checkout of the final commit of each phase, never in a working directory shared with another run. Each phase ends by stopping and asking the owner to run the gate; a phase is committed with `phase N` in the subject; nothing claims success.

---

## Phase 1: The reader (US3; FR-001 to FR-005, FR-011 first half)

**Purpose**: `Get-CoolingOff` in `scripts/adoption-lib.ps1` is the one reader of `coolingOffHours` and `coolingOffReason`, and the one home of the default (24) and the floor (1). Nothing calls it yet, so no verdict changes.

**Territory**:

- `scripts/adoption-lib.ps1`
- `tests/enforcement/**`

- [x] T001 Record the baseline on the parent commit in `specs/038-configurable-cooling-off/notes.md`: the full harness count on an isolated detached worktree, the coverage report's exempt-rule count and its site counts per script, and the saved output and exit code of `CRIT-S02` and `CRIT-S03`
- [x] T002 Probe the harness and the library's conventions (plan P2, P7), and record the answers in `notes.md`: how `tests/enforcement/ScopeLib.Tests.ps1` loads a library and builds a throwaway record on disk, how `Run-Tests.ps1` discovers a new `*.Tests.ps1`, and how `Get-DeveloperMode` names its constants and its `Problems` shape (`Message`, `Fix`, optional `Severity`). Reuse those conventions; invent none
- [x] T003 Write `tests/enforcement/CoolingOff.Tests.ps1` first, as a table (plan P3, `data-model.md` resolution table, `contracts/kit-adoption-cooling-off.md`), one row per shape, each asserting `Hours`, `Declared`, `Honored`, `Reason` and the problem list: absent key; `1`; `2`; `4`; `4.0`; `8`; `23`; `24`; `48`; `0`; `-3`; `1.5`; `0.5`; `"8"`; `true`; `null` (present as a key); `[]`; `{}`; a number too large to be finite; each of `2` and `23` with a usable reason, with no reason, with a blank reason, with a whitespace-only reason, with a non-string reason, and with a reason holding a line break; a reason with no value; a reason on a value of 24 or more; a missing record; an unreadable record; an unparsable record; a root that is a JSON array. Run it on the parent commit and confirm it fails because the function does not exist
- [x] T004 Add to `scripts/adoption-lib.ps1` (plan P2 to P4): the two constants (default 24, floor 1) and `Get-CoolingOff -Root`, returning `Hours`, `Declared`, `AnyDeclared`, `Honored`, `Reason`, `Why` and `Problems`. Read the record the way `Get-DeveloperMode` reads it (same read guard, same root-must-be-an-object test judged from the text, same `-ErrorAction Stop`), and return 24 with `Declared = $false` and no problem for a record that is missing, unreadable, unparsable or not an object, since `Get-DeveloperMode` already reports those. An explicit `null` is a problem only when the key is really present in the raw text. A usable reason has its line breaks read as spaces and is trimmed
- [x] T005 Update the header comment of `scripts/adoption-lib.ps1` so it names the new reader beside the other three, and says in one sentence why the constants live here and not in `scripts/enforcement-pack.ps1` (two constants drift)
- [x] T006 Run `tests/enforcement/CoolingOff.Tests.ps1`, the full harness, `pwsh -File scripts/doc-lint.ps1` and `pwsh -File scripts/ritual-checks.ps1`: every pre-existing case keeps its verdict, exit code and bytes, the new table passes, and the coverage sweep reports the same site counts as T001. Record the result in `notes.md`
- [x] T007 Stop. Review the working diff (`git diff --stat`), commit as `phase 1: cooling-off reader`, run `pwsh -File scripts/scope-check.ps1`, and ask the owner to run the gate

---

## Phase 2: The check reads it (US1, US2, US3, US4; FR-001 to FR-010, SC-001 to SC-004)

**Purpose**: `Invoke-CriticalSoloEvidence` applies the period in effect, prints the two warnings, and names the period in its failure message. The constant `$Config.CoolingOffHours` is removed. The team arm, the clock and the default message are untouched.

**Territory**:

- `scripts/enforcement-pack.ps1`
- `tests/enforcement/**`

- [x] T008 Record the baseline on the phase 1 commit in `notes.md`: the full harness count, and the saved output and exit code of every existing `CRIT-S*`, `CRIT-R*` and `CRIT-T*` case, so SC-004 can be shown byte for byte at the end of the phase
- [x] T009 [US1] Write the fixtures first, under `tests/enforcement/cases/enforcement-pack/`, using the `hoursAgo` back-dating `CRIT-S03` uses (never an absolute date). `CRIT-C01`, the honored short period: pass with the review 5 hours old and `coolingOffHours: 4` with a reason, expecting the WARN naming 4 hours and quoting the reason and exit 0 for the Critical check; fail with the review 3 hours old, expecting the failure naming 4h, the elapsed time, the hours remaining and `(declared in kit-adoption.json coolingOffHours)`; a boundary pair either side of the period by half an hour
- [x] T010 [US2] Write `CRIT-C02`, the declared value set aside: `coolingOffHours: 4` with no reason, with a blank reason and with a non-string reason, each with the review 25 hours old (passes under 24, expecting the WARN saying the value was set aside and why) and 23.5 hours old (fails under 24, expecting the unchanged default message)
- [x] T011 [US3] Write one variant per unaccepted shape (shipped as the `fail-unaccepted-*` variants of `CRIT-C02`; no `CRIT-C03` exists): `0`, `-3`, `1.5`, `"8"`, `true`, `null`, `[]`, `{}`, each with a usable reason and the review 23.5 hours old, expecting the unchanged 24-hour failure and the set-aside WARN naming the value read; and an unreadable record and a root that is a JSON array (shipped as the `fail-record-unreadable`, `fail-record-unparsable` and `fail-record-root-array` variants of `CRIT-S03`), expecting the unchanged 24-hour failure and no cooling-off warning
- [x] T012 [US2] Write a period above the default (shipped as the `fail-declared-48` and `pass-declared-48` variants of `CRIT-S03`; no `CRIT-C04` exists): `coolingOffHours: 48` with no reason, the review 30 hours old, expecting a failure naming 48h and no warning; and the same review 49 hours old, expecting a pass and no warning
- [x] T013 [US4] Write the team arm (shipped as the `fail-cooling-keys-ignored` and `pass-cooling-keys-ignored` variants of `CRIT-T01`; no `CRIT-C05` exists): a roster of two developers with a committed, valid `human-pr-review.md`, once with `coolingOffHours: 2` and a reason and once with no key, expecting identical output apart from nothing at all: no cooling-off line, no warning, the same exit code. Run all of T009 to T013 on the parent commit and confirm each new failing case fails there; the team-arm variants pass on the parent and must keep passing
- [x] T014 Bring the rules into the coverage sweep: add each new rule to `tests/enforcement/rules.json` with its anchor (`declared in kit-adoption.json coolingOffHours`, the honored-period warning wording, the set-aside warning wording) and law (`docs/sdlc/critical-delivery.md` item 5), and the update to `CRIT-S03`'s `law` field, which still reads `CoolingOffHours = 24`; add to `tests/enforcement/emission-idioms.json` only if the sweep reports a new site. Run the sweep and classify every candidate it prints
- [x] T015 Edit `scripts/enforcement-pack.ps1` (plan P5): remove `CoolingOffHours` from `$Config` and say in its place, in one line, where the default now lives; in `Invoke-CriticalSoloEvidence` call `Get-CoolingOff -Root $Root` first, before the missing-file return; add the two WARNs to `$script:warnings`; compare with `$period.Hours`; keep the failure message's words and add the `(declared in kit-adoption.json coolingOffHours)` clause only when the period is not 24 so the default message is byte-identical. Do not edit `Invoke-CriticalTeamEvidence`, the clock read, or the merge-readiness code. Update the header comment near line 57 that names `$Config.CoolingOffHours`
- [x] T016 Run `-Case enforcement-pack/`, the full harness, `doc-lint.ps1` and `ritual-checks.ps1`: every pre-existing case keeps its verdict, exit code and bytes against T008, every new fixture passes as written, and the coverage sweep reports no uncovered site. Record the result in `notes.md`
- [x] T017 Stop. Review the working diff, commit as `phase 2: cooling-off period read by the check`, run `pwsh -File scripts/scope-check.ps1`, and ask the owner to run the gate

---

## Phase 3: The doctor reports it (US3; FR-011, SC-005)

**Purpose**: `scripts/verify-kit.ps1` reports each malformed or unjustified declaration, an unused reason, a setting with no effect in team mode, and an accepted declaration, all through `Get-CoolingOff`. A record that declares neither key prints nothing new.

**Territory**:

- `scripts/verify-kit.ps1`
- `tests/enforcement/**`

- [x] T018 Record the baseline on the phase 2 commit in `notes.md`: the full harness count, and the saved output and exit code of every existing `VK-*` case, so that "a record declaring neither key prints nothing new" is shown byte for byte
- [x] T019 [US3] Write the fixtures first, under `tests/enforcement/cases/verify-kit/`, continuing from `VK-033` (the highest existing id is `VK-032`; check for gaps before numbering): an unaccepted value is a FAIL naming the field, the value read, that 24 hours applies and the fix; a value under 24 with no usable reason is a FAIL naming the same; a reason with nothing to justify is a WARN; either key declared in team mode is a WARN that it has no effect there; an accepted declaration is an `ok` line stating the period, and under 24 quoting the reason; and one case whose record declares neither key, expecting no cooling-off line at all. Run them on the parent commit and confirm the new failing ones fail there
- [x] T020 Bring the rules into the coverage sweep: add each new `VK-*` rule to `tests/enforcement/rules.json` with its anchor and law; add to `tests/enforcement/emission-idioms.json` only if the sweep reports a new site. Note that problems from the reader travel through the same loop as the roster's, so they are not literal sites; the sweep decides which are
- [x] T021 Edit `scripts/verify-kit.ps1` (plan P6): after the `developers` block, call `Get-CoolingOff -Root $Root`, gated on its own `AnyDeclared`; report each problem with the severity it carries (the doctor never decides it); add the one warning for team mode, when either key is declared, using the existing `$devMode.Mode`; add the one `ok` line for an accepted declaration; print nothing when neither key is declared. Do not interpret the record in this script
- [x] T022 Run `-Case verify-kit/`, the full harness, `doc-lint.ps1` and `ritual-checks.ps1`: every pre-existing case keeps its verdict, exit code and bytes against T018, every new fixture passes as written, and the sweep reports no uncovered site. Record the result in `notes.md`
- [x] T023 Stop. Review the working diff, commit as `phase 3: doctor reports the cooling-off setting`, run `pwsh -File scripts/scope-check.ps1`, and ask the owner to run the gate

---

## Phase 4: Guidance, flow-down and digests (FR-012, FR-013; plan P8, P9)

**Purpose**: the rule text describes what now ships, the adopted project is told what it will and will not see, and the digests are rebuilt. No script changes.

**Territory**:

- `docs/sdlc/critical-delivery.md`
- `adoption/updating.md`
- `docs/digests/**`

- [x] T024 Before editing, search `scripts/`, `tests/enforcement/` and every governance doc for any rule that keys on the phrase "24-hour", "24h" or "cooling-off" in item 5 (doc-lint, the digest marker comparison, `rules.json` `law` fields), and list each in `notes.md`. If one lives outside this phase's Territory, stop and ask for an amendment with an approver record before touching it
- [x] T025 Edit `docs/sdlc/critical-delivery.md` item 5: the rule text (24 hours is the default; a project may declare a shorter period or a longer one; the floor; the reason requirement; the warning), "What the machine checks" (the solo arm reads `coolingOffHours`; the fallbacks), and the honesty sentence, kept and extended to say a shorter period is a further weakening that the record and the output show and does not remove. State in one sentence that the declaration sits in the same repository as the feature and is checked by review at gate 6 (plan P9). Keep every existing mention of the team arm unchanged
- [x] T026 Update the item 5 digest marker in `docs/sdlc/critical-delivery.md` to say the period is configurable, defaults to 24 hours, and needs a reason below it, in the one-line shape the existing markers use
- [x] T027 Edit `adoption/updating.md`: document the two keys beside the `developers` and `criticalSurfaces` shape (accepted values, the presets, the floor, the reason, the fallback to 24), update the arm table row for the solo substitute so it no longer says a fixed 24 hours, update the two passages that describe a solo project's wait as 24 hours old so each says "by default", and add a flow-down note in the existing manner: what was wrong, which files flow, what a project that declares neither key sees (nothing), what a project that declares one sees, and the one first-run surprise to expect. Add the digest markers the note needs, placed after the block, never inside one
- [x] T028 Run `pwsh -File scripts/build-digests.ps1` (the only writer of `docs/digests/`), then `pwsh -File scripts/build-digests.ps1 -Check`, `doc-lint.ps1`, the full harness and `ritual-checks.ps1`. Confirm `docs/digests/critical-digest.md` changed only through the build and that no other digest changed except where a marker in `adoption/updating.md` feeds the adoption digest. Record the result in `notes.md`
- [x] T029 In `notes.md`, record: the determination that no constitution amendment is needed and why (plan P8); the limit stated in plan P9 (same-branch declaration, later shortening against an unchanged clock, a reason is a claim); and the follow-up the owner may want (read the declaration from the diff base), as a note and not as work
- [ ] T030 Stop. Review the working diff, commit as `phase 4: cooling-off guidance and digests`, run `pwsh -File scripts/scope-check.ps1`, and ask the owner to run the gate. Then request the fresh-context AI review (never self-graded, with the Reviewer Provenance block) and the human review

---

## Phase 5: The owner's decisions on the AI review (F1, F5, and the overclaim in two comments)

**Purpose**: the owner decided (2026-10-23, on `ai-code-review-phases-2-4.md`) that a malformed `coolingOffHours` or a missing reason is a **warning, not a failure, in team mode**, where no period applies (F5); that the constitution's sync-list entry that calls the Critical cooling-off hours a constant of `scripts/enforcement-pack.ps1` is corrected as a **PATCH, 0.8.0 to 0.8.1** (F1); and that the "a typo can never shorten the wait" claim is corrected in the two code comments that carry it (the spec's wording was amended with this phase). No principle text changes. Solo-mode verdicts and every pre-existing case keep their bytes.

**Territory**:

- `scripts/verify-kit.ps1`
- `scripts/adoption-lib.ps1`
- `tests/enforcement/**`
- `.specify/memory/constitution.md`
- `adoption/updating.md`

**Amendment approved by**: anas.m, 2026-10-23.

`scripts/adoption-lib.ps1` is in the Territory for its two comments only (T037). An annotation on a Territory bullet is not read by the scope check, so the note sits here.

- [x] T031 Record the baseline on the last commit of phase 4 and its review fixes in `notes.md`: the full harness count and the coverage report's site counts
- [x] T032 [US3] Write the fixtures first, under `tests/enforcement/cases/verify-kit/`: new rule `VK-037`, a malformed value or a missing reason in team mode is a warning that names the field and the value read and says the 24-hour default applies if the project goes solo, exit 0: `fail` (team, `coolingOffHours: 0` with a reason), `fail-no-reason` (team, `coolingOffHours: 4`, no reason), and `pass` (team, an accepted `48`). Move `VK-035/fail-unaccepted-value` under `VK-037` (its expectation changes from a failure to a warning), and keep the solo failures in `VK-033` byte for byte. Run them on the parent commit and confirm the new failing ones fail there
- [x] T033 Bring the rule into the coverage sweep: add `VK-037` to `tests/enforcement/rules.json` with its anchor and law, and update the `VK-035` note that listed the unusable-value direction. Run the sweep and classify every candidate it prints
- [x] T034 Edit `scripts/verify-kit.ps1` (plan P6, amended): when `$devMode.Mode` is `team`, report each reader problem that would be a failure as a warning that carries the reader's message and a team-mode fix; leave the solo path and the reader's own warnings as they are. Do not interpret the record in this script
- [x] T035 Edit `.specify/memory/constitution.md`: version 0.8.0 to 0.8.1 (the footer and a new SYNC IMPACT entry above the existing one, which moves down as prior history); correct the "Templates requiring updates" entry so the Critical cooling-off hours are no longer named a constant of `scripts/enforcement-pack.ps1` and `scripts/adoption-lib.ps1` is named for the default and the floor, with the period stated as a project declaration; change no principle and no historical rationale
- [x] T036 Edit `adoption/updating.md` to match: the feature 038 flow-down note's heading and its "What flows down", "What an owner may newly see" and "What does NOT change" passages no longer say "no constitution amendment" or "nothing in your constitution" (a PATCH: re-express the sync-list entry only if your constitution carries it), and the section that declares the keys and the note say a malformed value in team mode is a warning
- [x] T037 Edit the two comments in `scripts/adoption-lib.ps1` (the header paragraph and the line in the number test) that say a typo can only get the longer wait or can never shorten it, so they say every fallback lands on 24 hours and never below it. Comments only: `git diff` for that file shows no code line
- [x] T038 Run `-Case verify-kit/`, the full harness, `doc-lint.ps1`, `build-digests.ps1 -Check` and `ritual-checks.ps1`: every pre-existing case keeps its verdict, exit code and bytes against T031 apart from the one moved case, every new fixture passes as written, and the sweep reports no uncovered site. Record the result in `notes.md`
- [ ] T039 Stop. Review the working diff, commit as `phase 5: review decisions - team-mode doctor, constitution PATCH`, run `pwsh -File scripts/scope-check.ps1`, and ask the owner to run the gate. Then request the fresh-context AI review of phase 5 (never self-graded, with the Reviewer Provenance block) and the human review

---

## Dependencies and order

- Phase 1 before 2 and 3. Phase 2 and phase 3 are independent of each other and are still run in order, one at a time. Phase 4 follows all three, so the guidance describes behaviour that exists. Phase 5 follows phase 4: it corrects the doctor and the guidance after the review.
- Within a phase, fixtures come first and are shown failing on the parent commit; the script change follows.
- Parallel work within a phase is limited to writing fixtures (T009 to T013) and is not needed.

## Coverage of the spec

| Spec | Tasks |
|---|---|
| FR-001 to FR-005 | T003, T004 |
| FR-006, FR-007 | T009, T010, T012, T015 |
| FR-008, FR-009 | T009, T010, T015, T016 |
| FR-010 | T013, T015 |
| FR-011 | T003, T019, T021, T032 to T034 |
| FR-012, FR-013 | T025 to T028 |
| FR-014 | T003, T009 to T014, T019, T020 |
| SC-001 | T009, T015 |
| SC-002 | T003, T010, T011 |
| SC-003 | T009, T010, T014 |
| SC-004 | T008, T016, T018, T022 |
| SC-005 | T019, T021 |

## Implementation strategy

The smallest useful increment is phase 2, but it needs phase 1's reader, so the order above is also the MVP order: after phase 2 a project can already shorten its period and the pack enforces and warns; phase 3 gives the doctor's view of the same declaration; phase 4 is what an adopter reads. Stop at the end of each phase and wait for the owner's gate.
