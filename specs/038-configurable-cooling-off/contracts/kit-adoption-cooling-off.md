# Contract: the cooling-off keys in `kit-adoption.json`

Two optional top-level keys. Read by `Get-CoolingOff` in `scripts/adoption-lib.ps1` and nowhere else.

**Amendment approved by**: anas.m, 2026-10-23

## Keys

- `coolingOffHours` — a JSON number. Project-wide hours between the first commit of a Critical feature's
  `second-model-review.md` and the merge. Solo arm only (zero or one declared developer).
- `coolingOffReason` — a JSON string. One line saying why a period under 24 hours is acceptable. Required when
  `coolingOffHours` is accepted and under 24; ignored otherwise.

```json
{ "coolingOffHours": 8, "coolingOffReason": "two-person-team-in-waiting; features are small and reviewed next morning" }
```

## Accepted `coolingOffHours`

A JSON number that is finite, equal to its own floor, and at least 1. `4`, `4.0`, `24` and `48` are accepted. The
documented presets are 2, 4, 8 and 24; any other whole number at or above 1 is a custom value and is equally valid.
There is no upper bound.

Not accepted, each read as 24: `0`, any negative number, any fractional number (`1.5`, `0.5`), a string (`"8"`), a
boolean, `null`, an array, an object, a number not representable as a finite value.

## Reading rules

- A missing, unreadable or unparsable record, or one whose root is not a JSON object, gives 24 and no finding from this
  reader.
- An absent `coolingOffHours` gives 24 and no finding. An explicit `null` is a finding only when the key is present.
- A value under 24 with a missing, blank or non-string `coolingOffReason` is set aside: 24 applies.
- A line break inside the reason is read as a single space.

## Outputs

Pack (`scripts/enforcement-pack.ps1`, CriticalEvidence, solo arm only), each a WARN that never changes the exit code:

1. An honored period under 24: names the period in effect and quotes the reason.
2. A declared value set aside: names the declared value, says 24 applies, and says why (not accepted, or no reason).

The existing failure for a review recorded too recently names the period in effect. At 24 it is word-for-word the
message in use before this feature; at any other value the clause `declared in kit-adoption.json coolingOffHours;`
opens the existing parenthesis, before the hours remaining (amended 2026-10-23 to match the code, review F6 and G4).

**Amendment approved by**: anas.m, 2026-10-23

Doctor (`scripts/verify-kit.ps1`):

- FAIL: an unaccepted value; a value under 24 with no usable reason. Each names the field, the value read, the period
  that applies and the fix.
- WARN: a reason with nothing to justify; either key declared in team mode (no effect there). In team mode every FAIL
  above is a WARN instead, because no period applies there; it still names the field, the value read and the fix.
- `ok`: an accepted declaration, stating the period and, under 24, quoting the reason.
- Nothing, when neither key is declared.

## Unchanged

The team arm. The clock (first commit of `second-model-review.md`; a later revision does not restart it). Every
message for a project that declares neither key.
