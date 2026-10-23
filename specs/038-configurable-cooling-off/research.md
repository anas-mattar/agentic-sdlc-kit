# Research: Configurable cooling-off period

No `NEEDS CLARIFICATION` remained after the spec. The decisions below are the ones with a real alternative.

## Decision: read the setting through one shared function

**Decision**: add `Get-CoolingOff` to `scripts/adoption-lib.ps1`; both the pack and the doctor call it and neither
interprets the record.

**Rationale**: that file's own header records why. Feature 013 shipped the roster logic twice, the copies drifted
inside one feature, and a reviewer found it by reading a comment asserting the copies matched. A comment is not a
mechanism; one function is.

**Alternatives considered**: reading the key inline in `Invoke-CriticalSoloEvidence` and again in the doctor —
rejected for the reason above. Putting the reader in `enforcement-pack.ps1` — rejected: `verify-kit.ps1` would have
to dot-source the grading script to reach it.

## Decision: two keys, `coolingOffHours` and `coolingOffReason`

**Decision**: a number and a string, top level, both optional.

**Rationale**: the record's existing keys (`developers`, `criticalSurfaces`, `codeRepos`) are flat and top level.
Keeping the reason next to the value means the one-line justification is in the same diff as the change it
justifies.

**Alternatives considered**: an object `{ "hours": 4, "reason": "…" }` — rejected: a second shape for the reader to
validate, and an object where a number is the only thing most projects will ever write. A reason in a comment —
rejected: JSON has none, and a record the machine cannot read is not a record.

## Decision: the floor is 1, and presets are documentation

**Decision**: any whole number at or above 1 is valid; 2, 4, 8 and 24 are the documented presets, not an enumeration
the reader checks.

**Rationale**: an enumeration would make "custom" a second code path for no gain, and would reject 12 or 48, which
nobody can argue is unsafe. The floor exists only to rule out 0 and negatives; accountability for short values is the
reason, not the number.

**Alternatives considered**: a closed enumeration of presets plus a separate custom key — rejected as above. A floor
of 2 or 4 — rejected: the owner chose "custom with a floor", and the floor's job is to stop silent disablement, which
1 already does. No ceiling: a larger value is stricter and the owner's choice.

## Decision: below 24 without a reason falls back to 24

**Decision**: set the declared value aside, apply 24, warn that it was set aside and why.

**Rationale**: the same fail-closed direction as every other degenerate input in the library. Honoring the value and
failing the check for the missing reason would leave the project red with a period it never validly chose.

**Alternatives considered**: honor the value and fail — rejected as above. Honor the value and warn only — rejected:
it would make the reason optional in practice, which is the opposite of the owner's decision.

## Decision: a warning, not a failure, for an honored short period

**Decision**: the period is a declared choice with a recorded reason; the output says so on every run, and it does not
turn a green run red.

**Rationale**: the owner asked for it to be "visible" and "auditable", not forbidden. A failure would make the feature
unusable by design. The cost of the warning is that a reader has to notice it; P9 of the plan says where review
catches it.

**Alternatives considered**: no warning — rejected, it is the silent weakening this feature exists to prevent.

## Decision: the declaration is read from the working tree

**Decision**: the record is read where it sits, as every other record key is; the same-branch limitation is disclosed
in the plan and the guidance, not closed.

**Rationale**: reading from the diff base would mean a different read path for one key than for the rest of the
record, a new git-read failure state to name (the GAP-027 lesson), and a behaviour change an adopter has to
understand. It is a coherent follow-up, not a part of this request.

**Alternatives considered**: read from the diff base — deferred, recorded in the plan as the repair if the owner wants
it. Require a recorded approver on the change — deferred for the same reason; the amendment-authority rule already
covers feature documents, not the record.

## Decision: no constitution amendment

**Decision**: none.

**Rationale**: the constitution names no hour count as a rule; it mentions 24 only in a historical bump rationale.
Principle IX and X's independence requirement is parameterised, not changed. The normative text is `critical-delivery.md`
item 5, an ordinary document.

**Alternatives considered**: amending the constitution to say "a declared period" — rejected, nothing normative there
to amend.

## Open points carried to tasks

- The exact warning and not-honored wording is fixed in `tasks.md` phase 2 and pinned by `expected.txt` in the
  fixtures; the plan fixes what each must contain, not the sentence.
- Whether any existing doc-lint rule keys on the "24-hour" phrase in item 5 is checked at the start of phase 4, since
  the digest marker and `critical-delivery.md` must change together.
