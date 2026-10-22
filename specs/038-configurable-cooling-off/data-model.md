# Data Model: Configurable cooling-off period

The only stored data is two optional keys in `kit-adoption.json`. The rest is derived.

## Stored

| Key | Type | Required | Meaning |
|---|---|---|---|
| `coolingOffHours` | JSON number | no | Project-wide hours between the second-model review's first commit and the merge, solo arm only |
| `coolingOffReason` | JSON string | only when `coolingOffHours` is accepted and under 24 | One-line justification for a period under the 24-hour default |

## Derived: the period in effect

`Get-CoolingOff` returns:

| Field | Meaning |
|---|---|
| `Hours` | The period the check applies. An integer, at least 1; 24 whenever anything is absent, unusable or unjustified |
| `Declared` | Whether the record declares `coolingOffHours` at all |
| `AnyDeclared` | Whether the record carries either key, a reason with no value included; what the doctor gates on (phase 1 review F3, owner decision 2026-10-23) |
| `Honored` | False when a declared value was set aside (unaccepted, or under 24 with no usable reason) |
| `Reason` | The recorded reason with line breaks read as spaces, or `$null` |
| `Why` | One clause naming where the period came from, for the caller's message |
| `Problems` | Zero or more `@{ Message; Fix; Severity }` for the doctor; the check ignores them |

## Resolution table

| `coolingOffHours` | `coolingOffReason` | `Hours` | `Honored` | Pack output | Doctor |
|---|---|---|---|---|---|
| absent | any | 24 | n/a | nothing | nothing (a reason with no value: unused, warn) |
| accepted, ≥ 24 | absent or any | the value | true | nothing | `ok`; reason unused (warn) |
| accepted, 1 to 23 | non-blank string | the value | true | WARN: period and reason | `ok` stating period and reason |
| accepted, 1 to 23 | absent, blank or not a string | 24 | false | WARN: set aside, and why | FAIL: reason required |
| `0`, negative, fractional, string, boolean, `null`, array, object, not finite | any | 24 | false | WARN: set aside, and why | FAIL: name the value read |
| record missing, unreadable, unparsable, root not an object | n/a | 24 | n/a | nothing | nothing here (reported by the roster reader) |

Team mode (two or more developers): the check never calls the reader, so no row changes the pack's output; the doctor
adds one warning if either key is declared.

## State

None. The clock is the first commit of `second-model-review.md`, read from git as it is today; nothing about it is
stored or changed.
