# Implementation Plan: Configurable cooling-off period

**Branch**: `038-configurable-cooling-off` | **Date**: 2026-10-22 | **Spec**: specs/038-configurable-cooling-off/spec.md
**Input**: Approved feature specification (anas.m, 2026-10-22) + decisions P1 to P9 below
**Gate Batching**: none
**Gate Certification**: user-run
**Status**: Approved (anas.m, 2026-10-22) — decisions P1–P9 approved as written
**Amendment approved by**: anas.m, 2026-10-23

## Summary

The solo arm of the Critical evidence check stops reading a constant and starts reading the project's declaration.
The record gains two optional keys, `coolingOffHours` and `coolingOffReason`. One new reader in
`scripts/adoption-lib.ps1`, `Get-CoolingOff`, is the only place that interprets them, so the check that enforces the
period and the doctor that reports it cannot disagree (the 013 lesson). Every unusable shape resolves to 24; a value
below 24 is honored only with a non-blank reason and always prints a warning that quotes it. The team arm, the clock
and the default message are untouched. Four phases: the reader, the check, the doctor, then guidance, flow-down and
digests. No package, no new script, no constitution amendment.

## Technical Context

**Language/Version**: PowerShell 7+ (`pwsh`)
**Primary Dependencies**: none new
**Storage**: `kit-adoption.json` only; two new optional keys, no new file
**Testing**: the enforcement harness (`tests/enforcement/`): real temporary git repositories, a failing and a passing
fixture per rule, the coverage sweep over every emission site, plus a Pester file for the reader in the manner of
`ScopeLib.Tests.ps1`. Every existing case passes unchanged.
**Target Platform**: any runner with `pwsh` and `git`
**Project Type**: governance tooling (scripts plus documents)
**Constraints**: absent, unusable or unjustified means 24 (spec FR-003 to FR-005); the default message is
word-for-word unchanged (FR-008); the team arm is untouched (FR-010); a warning never changes an exit code (FR-006);
the doctor and the check read one function (FR-011)
**Scale/Scope**: one reader in `scripts/adoption-lib.ps1`, one function edited in `scripts/enforcement-pack.ps1`, one
block added to `scripts/verify-kit.ps1`, about twenty fixture cases, a Pester file, four documents, digests

## Constitution Check

- [x] **Specification First (I)**: the spec is approved (anas.m, 2026-10-22); this plan follows it; `tasks.md` follows once the plan is approved. No code before approval.
- [x] **Source of Truth (II)**: no conflict found. The constitution mentions 24 hours only in a historical bump rationale, not as a rule; the normative rule is `docs/sdlc/critical-delivery.md` item 5, rewritten in phase 4. `scripts/enforcement-pack.ps1` carries the constant today and is changed to read the record.
- [ ] **Repository Separation (III)**: not applicable, the kit is one repository.
- [x] **Architecture Consistency (IV)**: the new reader sits beside `Get-DeveloperMode` and `Get-CriticalSurfaces` in `scripts/adoption-lib.ps1` and is read by the same two callers; no new pattern, script or dependency.
- [ ] **Domain Invariants (V)**: not applicable, the kit has no domain-invariants pack.
- [x] **Security (VI)**: nothing sensitive is read or written. The plan states what the declaration is and is not (P9): a written claim in a file whoever can edit the branch can edit.
- [ ] **External Integration Governance (VII)**: not applicable, no external integration.
- [x] **Testing Requirements (VIII)**: every new behaviour has a failing and a passing fixture, written first and shown failing on the parent commit; new emission sites are covered by the sweep.
- [x] **Human Review (IX)**: gate-6 human review at merge; each phase has a fresh-context AI review with Reviewer Provenance.
- [x] **Controlled Delivery (X)**: four phases, one at a time; the change touches an enforcement member, so the owner runs the gate: no batching, no ci-held.

**Phase sizing rule**: phase 1 adds a reader that nothing calls yet, so it changes no verdict and is useful alone.
Phase 2 depends on 1 and is the only phase that moves a pack verdict. Phase 3 depends on 1 only (it reads the same
function) and moves no pack verdict. Phase 4 is documents and digests and depends on all three. Reverting 4, 3, 2, 1
in order leaves a consistent kit at each step; a revert of phase 2 alone leaves the constant gone, so phase 2's
revert restores `$Config.CoolingOffHours` with it (P2).

**Post-design re-check**: no new violation. P1 (the key names), P3 (the floor and the accepted shapes) and P4 (a
warning, not a failure, for an honored short period) are decisions of the owner, approved or changed by approving
this plan.

## Decisions

**P1: two keys, project-wide (FR-001, FR-005).** `kit-adoption.json` gains, at the top level beside `developers` and
`criticalSurfaces`, `coolingOffHours` (a JSON number) and `coolingOffReason` (a JSON string). Both are optional; an
adoption predating this feature declares neither and is unchanged. The shape is pinned in
`contracts/kit-adoption-cooling-off.md`.

```json
{ "coolingOffHours": 4, "coolingOffReason": "single-developer tooling repo; features are small and reviewed same day" }
```

**P2: one reader, one place for the constants (FR-001 to FR-005, FR-011).** `scripts/adoption-lib.ps1` gains
`Get-CoolingOff -Root`, returning `Hours` (the period in effect, always an integer of at least 1), `Declared`,
`AnyDeclared` (true when the record carries either key, a reason with no value included),
`Honored` (false when a declared value was set aside), `Reason`, `Why` (one clause, for a caller's message) and
`Problems` (`@{ Message; Fix; Severity }` for the doctor, the shape `Get-DeveloperMode` already uses). The default
(24) and the floor (1) live in that file and nowhere else; `$Config.CoolingOffHours` is removed from
`scripts/enforcement-pack.ps1` so two constants cannot drift. A record that is missing, unreadable, unparsable or
whose root is not an object returns 24 with `Declared = $false` and no problem of its own: `Get-DeveloperMode`
already reports those and the doctor does not say it twice.

**P3: which values are accepted (FR-002, FR-003).** A value is accepted when it is a JSON number, finite, equal to
its own floor, and at least 1. So `4`, `4.0` and `48` are accepted; `0`, `-3`, `1.5`, `0.5`, `"8"`, `true`, `null`,
an array and an object are not, and a number too large to represent as a finite double is not. Presets are
documentation only: 2, 4, 8 and 24 are named in the guidance, and any whole number at or above the floor is equally a
valid custom value (spec FR-002). An unaccepted declared value resolves to 24 and is a doctor failure that names the
field, the value read and the fix (FR-011). An explicit `null` is reported only when the key is really present (the
013 rule); an absent key is silent.

**P4: below 24 needs a reason, and always warns (FR-005 to FR-007).** For an accepted value under 24 the reason must
be a JSON string that is non-blank after trimming; a line break inside it is read as a space so the warning stays on
one line. With a usable reason the period applies as declared and the pack prints one WARN naming the period and
quoting the reason. Without one the period is 24, the declared value is set aside, and the pack prints one WARN
saying so and why. A value of 24 or more needs no reason and prints nothing. Neither line fails the run: the
failure, if any, is the existing "recorded too recently" line, which now names the period in effect. A reason on a
value that does not need one is ignored and the doctor says so.

**P5: where the pack reads it (FR-006 to FR-010).** In `Invoke-CriticalSoloEvidence` (`scripts/enforcement-pack.ps1`),
first, before the missing-file return, so the warning is printed whenever the solo arm is graded and a short period
is in effect. The period used in the comparison is `$period.Hours`. The failure message keeps its words; when the
period is not 24 it gains one clause, `(declared in kit-adoption.json coolingOffHours)`, so a reader knows where the
number came from, and at 24 it is byte-identical to today. `Invoke-CriticalTeamEvidence` is not edited and never
calls the reader, so the team arm cannot change. The clock is not edited: still the last line of `git log --follow
--format=%aI` for `second-model-review.md`, the first commit of the file.

**P6: what the doctor says (FR-011).** `scripts/verify-kit.ps1` gains one block after the `developers` block, gated on
the library's own `AnyDeclared` and reading `Get-CoolingOff` only. Problems from the reader are reported as failures
(an unaccepted value, a value under 24 with no usable reason) or warnings (a reason that is unused); each states the
period that applies and the fix. When either key is declared and the project is in team mode (read from the existing
`$devMode`) the doctor adds one warning that the setting has no effect there. An accepted declaration prints one
`ok` line stating the period and, below 24, quoting the reason. A project that declares neither key prints nothing:
absence is information, never a finding.

**P7: fixtures and the sweep (FR-014, SC-001 to SC-005).** Every new emission site gets a rule in
`tests/enforcement/rules.json` with a failing and a passing case, and the coverage sweep must stay green. Cases
differ in one condition each and reuse the `hoursAgo` back-dating the CRIT-S03 pair already uses (23.5 and 24.5 for
the default). The reader has its own Pester file covering every shape in P3 as a table. CRIT-S03 and every existing
case pass unchanged, which is SC-004; any that does not is a defect in the change, not a fixture to update.

**P8: guidance, flow-down, digests (FR-012, FR-013).** `docs/sdlc/critical-delivery.md` item 5 (the rule text, "What
the machine checks", the honesty sentence kept and extended to say a shorter period is a further weakening the
record shows), its digest marker; `adoption/updating.md` (the record shape, the row in the arm table, and a
flow-down note: which files flow, that nothing changes for a project that declares neither key, and what a project
sees when it declares one). `docs/digests/critical-digest.md` is rebuilt by `scripts/build-digests.ps1` only and
never edited by hand. `scripts/init-kit.ps1` is not changed: both keys are optional and a fresh adoption writes
neither. No constitution amendment: the independence rule of IX and X is parameterised, not changed (recorded in
`notes.md`).

**P9: what the declaration is, and is not (spec Assumptions).** The reason is a written claim: the pack can show it
exists and is not blank, not that it is a good one, and a reviewer reads it at gate 6. The record sits in the same
repository, and usually on the same branch, as the feature it governs, so an owner can shorten their own wait in
the same pull request. This plan does not close that: the warning prints on every run and the change shows in the
diff, which is where review catches it, and the guidance says so beside the rule. If the owner wants it closed, the
repair is to read the declaration from the diff base rather than the working tree; that is a separate feature with
its own spec, not scope here. The same disclosure covers shortening the period after the review is committed: the
clock does not restart (FR-009), so a later shortening takes effect against the original first-commit time.

## Phases

Detailed tasks and the per-phase **Territory** blocks go in `tasks.md`.

1. **The reader.** P2, P3 and P4's reading rules. `Get-CoolingOff` and the two constants in
   `scripts/adoption-lib.ps1`; a Pester table of every shape; no caller yet. Changes no verdict.
2. **The check reads it.** P4 and P5. `Invoke-CriticalSoloEvidence` uses the reader, prints the two warnings and the
   clause; `$Config.CoolingOffHours` removed; new rules and fixtures; CRIT-S03 and all existing cases unchanged.
   Delivers FR-001 to FR-010 and SC-001 to SC-004.
3. **The doctor reports it.** P6. One block in `scripts/verify-kit.ps1`; fixtures per finding. Delivers FR-011 and
   SC-005.
4. **Guidance, flow-down and digests.** P8 and P9. `docs/sdlc/critical-delivery.md`, `adoption/updating.md`, the
   digest marker, `scripts/build-digests.ps1`, the doc-lint run, `notes.md`. Delivers FR-012 and FR-013.

## Project Structure

### Documentation (this feature)

```text
specs/038-configurable-cooling-off/
├── plan.md              # This file
├── research.md          # Phase 0: decisions and alternatives
├── data-model.md        # Phase 1: the setting, the reason and the period in effect
├── quickstart.md        # Phase 1: how to verify by hand
├── contracts/
│   └── kit-adoption-cooling-off.md   # the two record keys, accepted shapes, outputs
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output (/speckit.tasks — NOT created by this command)
```

### Source Code (repository root)

```text
scripts/
├── adoption-lib.ps1        # + Get-CoolingOff, the two constants          (phase 1)
├── enforcement-pack.ps1    # Invoke-CriticalSoloEvidence reads it         (phase 2)
└── verify-kit.ps1          # one doctor block                             (phase 3)

tests/enforcement/
├── CoolingOff.Tests.ps1    # the reader as a table                        (phase 1)
├── rules.json              # new rules                                    (phases 2, 3)
└── cases/{enforcement-pack,verify-kit}/…   # fixtures                     (phases 2, 3)

docs/sdlc/critical-delivery.md     # item 5                                 (phase 4)
docs/digests/critical-digest.md    # rebuilt, never edited                  (phase 4)
adoption/updating.md               # record shape + flow-down note          (phase 4)
```

**Structure Decision**: no new script and no new directory. The reader joins its two siblings in
`scripts/adoption-lib.ps1`, and the fixtures use the harness layout every enforcement rule already uses.

## Complexity Tracking

No constitution violation to justify.
