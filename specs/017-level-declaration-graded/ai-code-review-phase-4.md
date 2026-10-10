# AI Code Review — 017 Level Declaration Graded (Phase 4)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-11
**Branches**: agentic-sdlc-kit `017-level-declaration-graded` (phase-4 commit `75779c2`)
**Scope reviewed**: `git show 75779c2` in full (68 files: `scripts/enforcement-pack.ps1` +108,
`tests/enforcement/rules.json`, `tests/enforcement/emission-idioms.json`, 25 fixtures under
`tests/enforcement/cases/enforcement-pack/LEVEL-008..011`, `notes.md` +51, `tasks.md` T024-T028
ticks). Read for context: `spec.md` (US2, FR-001/002/003/008/012/014), `plan.md` D7, `research.md`
R4/R6, `data-model.md`, `contracts/level-declaration-contract.md` sections 2-3, `tasks.md`
Phase 4, `notes.md` Phase 1 review and Phase 4 sections, the spec template, constitution X
(Level declaration), `docs/sdlc/critical-delivery.md`, `Get-DeliveryLevel`,
`Get-VisiblePlanLines`, `Invoke-StructureCheck`, the verdict tail of the pack, and the phase-3
review for style.
**Feature contract**: phase 4 = T024-T028 (US2): `Invoke-LevelRationaleCheck`, the written half of
the level claim. Territory: `scripts/enforcement-pack.ps1`, `tests/**`, the feature's own spec dir.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-sonnet-5-5 (the implementing session)
- **Inputs provided**: commit `75779c2` (`git show --stat` and full diff of the pack, rules,
  idioms and the LEVEL-008..011 fixtures); the 017 feature documents (`spec.md`, `plan.md`,
  `research.md`, `data-model.md`, `contracts/`, `tasks.md`, `notes.md`); the kit's law
  (`CLAUDE.md`, constitution, `critical-delivery.md`, the spec template); the phase-3 review for
  style; read and run access to the working tree. No repository file other than this review was
  modified; about 100 scratch git repos were built under `$env:TEMP` and removed.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVED WITH MINOR FINDINGS (no Blocker, no Major).** I looked hard for the phase-3 kind of
defect, a spec whose rationale is actually missing or contradictory and that still runs clean,
and found none that an honest author reaches by accident. `$matches` is correct everywhere, the
verdict is anchored, the template as shipped can never read as four answers, a spec without the
marker is silent, Micro/Lite are not touched, and every unanswerable condition fails by name. What
remains is a set of deliberate-evasion and robustness gaps (F1-F5: the reader ignores code fences,
reads only the first marker and the first section, and does not complain about a mangled marker),
one fixture gap that matters (F6: no Micro/Lite-with-marker case), and one decision for the owner
(F7: LEVEL-011 is real behaviour that the approved documents do not list). All 12 enforcement-pack
prefixes pass with 0 failures.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Scope | `pwsh -File scripts/scope-check.ps1`: `PASS phase 4 commit 75779c2 (68 file(s))`. Changed paths: the pack, `tests/**`, the feature's own `notes.md` and `tasks.md` |
| Amendment authority (constitution I) | `git show --stat 75779c2 -- specs/`: `notes.md` (+51) and `tasks.md` (5 ticks) only. `spec.md`, `plan.md`, `contracts/`, `data-model.md`, `research.md` untouched. Clean |
| Harness, targeted | `-Case LEVEL-`: 135 passed, 0 failed (51 cases). `AMEND-` 97, `BATCH-` 49, `CERT-` 41, `CRIT-` 73, `GAP27-` 49, `LITE-` 45, `MICRO-` 69, `PACK-` 49, `PHASE-` 37, `PROV-` 57, `STRUCT-` 45: all 0 failed, 0 skipped. The earlier fixtures carry no marker, so none of their expectations moved |
| This branch's own spec | `Select-String '^\*\*Rationale Rule'` in `spec.md`: none. `enforcement-pack.ps1 -Branch 017-...`: no `LevelRationale` line, `enforcement-pack: OK`. Silent, as FR-008 requires |
| `$matches` (the explicit worry) | Verified by behaviour, not just by reading. Line 912 (`-notmatch $script:RationaleVerdictPattern -or (Test-RationalePlaceholder $matches[2])`): `-notmatch` populates `$matches` on a successful match (PS 5.1 and 7); the `-or` right side runs only when the verdict matched, so `$matches[2]` is the reason (group 2 of `^(applies\|does not apply)\s*(?:...)\s*(\S.*)$`). The helper runs its own `-match` in its own function scope, so it cannot overwrite the caller's `$matches`. The `else` branch therefore reads the caller's `$matches[1]`. Probes: one `applies` hidden in the third bullet of four, with `domain-invariants`/`irreversible-data`/`auditable-evidence` answered `does not apply`, produced `1 apply` and named `'authn-authz-payment'` only; two applying triggers produced `2 apply` and a finding listing both. `$levelName` (line 888) follows a `-notmatch` that did not return, so it is fresh. In the `Where-Object` for Critical because, `$matches` is set and read inside the same scriptblock: a real reason passes, a bracketed or empty one fails (probes below) |
| Empty reason | A verdict with nothing after the dash (`does not apply — ` and trailing space) fails the verdict pattern (`(\S.*)` needs a character), reported as `'does not apply —' is not ... followed by a reason`. A bullet whose value is empty (`- **k**:`) yields `@('')`, one entry, fails the same way. No exception |
| Marker reading | `**Rationale Rule**:1`, `**rationale rule**: 1` (`-match` is case-insensitive) and the template's own line (value then a multi-line HTML comment) all grade as `1`. `1.0`, `1 see below`, an empty value, `2`: UNGRADED by name (exit 0). Marker only inside an HTML comment: exempt and silent (correct: comments are invisible). Marker after the section: graded (order-independent, good). Marker in a CRLF file: graded |
| Section reading | `## Level rationale`, `## Level Rationale (draft)`: read (case-insensitive, `\b`). `##Level Rationale`, `### Level Rationale`, `## Level Rationales`: "has no Level Rationale" (fails closed). A section inside an HTML comment: "has no Level Rationale" (correct). A `# ` or `## ` heading ends the section (leftover keys then "no bullet for it", fails closed); `###`, `---` and blank lines do not end it (fine, nothing leaks) |
| Bullet reading | `-`, `*` and indented bullets read; `+`, numbered, table, `__key__`, unbolded, `**key:**` (colon inside the bold) all fail closed with "no bullet for it" and the corrective form. Key case is folded (`**DOMAIN-INVARIANTS**` reads). An unknown extra key is ignored. The same key twice, in any case, is "answered more than once" |
| Verdict reading | `Applies`, `DOES NOT APPLY` read. `does not apply.` and `does not applies` fail. `-`, `--`, `—`, `–` separators and even no spaces (`does not apply-r`) read. Placeholder reasons fail: `[reason]`, `<reason>`, `<none>`, `TODO`, `[a] and [b]` (starts `[`, ends `]`). Mid-text `—`, `]`, `[see ADR-4] for the reason`, `TODOS later`: accepted as reasons (correct) |
| Critical because | A real reason passes; `[why]`, empty, `TODO`, an HTML-commented line, an indented line and a bullet form all leave the Critical-with-nothing-applying case failing with the contradiction. A reason with `[` in the middle (`see [ADR 4] and [ADR 5]`) passes. Critical with some triggers applying needs none. Critical with all four applying: graded, no finding. Critical with a missing trigger: unanswered finding |
| Interplay | Output order verified: the `LevelRationale: graded ...` line prints before the contradiction finding, and only when all four are answered. A Critical spec still gets the Critical lane's own `CriticalEvidence` finding independently. Micro with the marker and `applies` everywhere: no `LevelRationale` output at all (the only findings are the Micro lane's own). Lite with the marker: silent. Absent Delivery Level: the rationale check is silent and Structure fails ("has no **Delivery Level** header"), so nothing is lost. `Standardish`: Structure fails, rationale silent |
| Fixture wording | Every `expected.txt` I read matches the emitting strings (lines 876-935 of the pack) and the contract section 3 anchors (`has no Level Rationale`, `leaves trigger`, `contradicts its level`). The hand-written expectation for `fail-template-placeholder` (four findings, one per trigger) and `fail-duplicate` (the second answer does not win and does not turn into a contradiction) are honest |
| Advice works when pasted | The message says `- **k**: applies — <reason>`. Substituting a real reason (em dash, `-` or `--`) gives a passing run; pasting `<reason>` literally is rejected as a placeholder, which is the right outcome |
| Robustness / performance | No input threw. A 5,000-line spec and a section with 5,000 extra bullets each graded in under 2 s end to end; a 120,000-character reason line and a 100,000-character non-matching line graded in about 1.2 s (the patterns are linear: one `\s*`, one `(\S.*)$`, no nested quantifiers). Loops are bounded by the line count |
| Non-ASCII | `[—–]` in the pattern follows the existing precedent in the pack (line 640 and the phase-3 review's note); `[Console]::OutputEncoding` is set at the top. Em dashes in the new `Write-Host` strings are the same style as the existing lines |
| Wording vs law | `.DESCRIPTION` block, the messages, the template, the constitution clause and `critical-delivery.md` agree on: the four keys, applies / does not apply plus a reason, Standard none applying, Critical at least one or a Critical because, Micro owes none, the marker exempts. The `.DESCRIPTION` and the message both say it is a claim a reviewer can falsify, not proof; nothing claims the rationale is verified true |

## Findings

### F1 — Minor: the reader is not code-fence aware, in both directions (in scope)

`Get-VisiblePlanLines` strips HTML comments only. Consequences I reproduced:
- A **fenced** `**Critical because**: owner says so` satisfies the Critical-because requirement.
- A **whole fenced** `## Level Rationale` block (four answers inside a code fence) satisfies the
  section check.
- A marker line quoted inside a code fence (a spec that documents this rule, for example) makes
  the spec "carry the marker", so a real spec with no section then fails with "has no Level
  Rationale". That one fails closed and is fixable by indenting, but it is a false positive.

The first two are fail-opens that need a deliberate act, like the commented-out decoy the
phase-3 review accepted; the third is the reverse. Note the phase-3 review accepted the same
fence blindness for Territory as a safe over-report; here two of the three directions are
under-reports.
**Fix**: in `Invoke-LevelRationaleCheck` only, drop lines between ``` fences before the marker,
section and Critical-because reads (a three-line state machine over `$lines`). If the owner prefers
to leave it, record it as an accepted limit in the notes.

### F2 — Minor: a second `## Level Rationale` section is ignored (in scope)

The loop breaks on the first heading match. A spec with a compliant first section and a second
section answering `applies` is graded on the first only (reproduced: second section with
`applies` on a Standard feature, exit 0, `0 apply`). Likewise any trigger answered after a `# `
or `## ` heading ends the section is dropped (fails closed, "no bullet for it", so not a
fail-open). The first is the hole: two sections is a contradiction nobody sees.
**Fix**: count the `## Level Rationale` headings; more than one adds the same failure shape as a
duplicate key ("has more than one Level Rationale section"). Add a `fail-two-sections` fixture.

### F3 — Minor: two marker lines are graded by the first only, so the verdict depends on order (in scope)

`**Rationale Rule**: 1` then `: 2` grades under rule 1 and says nothing; `2` then `1` is UNGRADED.
Neither is a fail-open of the section itself, but a spec that carries a second, higher marker is
read as version 1 without a word.
**Fix**: when more than one marker line is visible and the values differ, add an UNGRADED line
naming both (or fail); same-valued duplicates can stay silent.

### F4 — Minor: a marker that is mangled is silently exempt (in scope; or accept as the stated evasion)

`  **Rationale Rule**: 1` (indented), `> **Rationale Rule**: 1` (quoted), `**Rationale Rule** : 1`,
`__Rationale Rule__: 1`: all read as "no marker", exempt and silent, exit 0. The constitution
accepts that deleting the marker evades the rule and says the omission shows in the diff; a
*near-miss* is different, because it looks like compliance in review. The kit already treats
near-misses as UNGRADED for Territory (data-model.md, "a near-miss marker makes the feature
UNGRADED").
**Fix**: a visible line that mentions `Rationale Rule` but does not match the strict marker
pattern adds `UNGRADED: LevelRationale: ... a line that looks like the rule marker but is not one`.
Cheap, and it needs no change to any approved document; add one fixture. Owner may decline.

### F5 — Minor/Note: "a reason" is any non-space character (in scope; cosmetic)

`does not apply — x`, `does not apply — -`, `does not apply — n/a` all read as answered, and the
punctuation set accepts `does not apply-r`. The data-model says "at least one word after the
dash" and the template says "a reason". This is the stated limit (a claim, not proof), and a
stricter regex only moves the boundary. Worth one line: require `\w` in the reason
(`(?=.*\w)`), which turns `—`/`-`/`...` into unanswered at no cost to real reasons.

### F6 — Minor: fixtures cannot tell a correct implementation from three plausible wrong ones (in scope)

The suite has 4 + 9 + 6 + 2 cases. A plausible wrong implementation that survives it:
1. **Requires the section on Micro (or Lite) when the marker is present.** No fixture carries the
   marker on a Micro or Lite spec; `LEVEL-008` has `fail`, `pass-no-marker`, `pass-template-marker`,
   `pass`. The Micro exemption is a stated decision (notes.md, constitution, `critical-delivery.md`)
   with no test behind it. This is the one that matters.
2. **A marker placed after the section** (probed: works today, but unpinned).
3. **A Critical because reason that contains brackets** (`see [ADR 4]`, works today, unpinned), and
   a Standard spec with **two** applying triggers (the message lists both, probed, unpinned).
   `LEVEL-009` also has no Critical-with-a-missing-trigger case (Critical goes through the same
   code, but "exempting Critical from the completeness rule" would pass the suite).
**Fix**: add `LEVEL-008/pass-micro-marker` (Micro, marker, no section: no `LevelRationale` line;
the Micro lane's own expectation otherwise), `LEVEL-009/fail-critical-missing-trigger`,
`LEVEL-010/fail-standard-two-apply`, `LEVEL-010/pass-critical-because-brackets`,
`LEVEL-008/pass-marker-after-section`, plus fixtures for whichever of F1-F4 are fixed. Update
`siteCount`/notes only if a new site is added.

### F7 — Note, owner decision: LEVEL-011 (unknown marker value is UNGRADED) is behaviour the approved documents do not list

`tasks.md` stops at LEVEL-010, `contracts/...` section 3 has no anchor for it, and `data-model.md`'s
verdict table has no row for "marker present, value unknown". The behaviour is defensible and
I judge UNGRADED the right verdict: FR-012 requires that a spec the check cannot read be said so
by name without a clean grade; FR-008 is not affected (it concerns a spec that predates the rule,
and this one carries a marker); failing would be a new hard failure on a spec written under a
rule the script has never heard of; silent exemption would defeat the marker's point. The
ungraded line says in plain words that it is "not the same as passing it", and the run prints
`enforcement-pack: UNGRADED`, never `OK`. But two consequences are worth the owner's eye:
(a) any trailing text on the marker (`1 see below`, `1.0`) is UNGRADED, not graded, so an author
who annotates the marker line turns the check off with exit 0; and (b) the contract's anchor
table and the data-model's verdict table are approved documents that now lag the code.
**Fix (owner)**: approve a one-line addition to `contracts/` section 3 (`LEVEL-011 | UNGRADED |
LevelRationale: ... a version this check does not know`) and one row to the data-model verdict
table, recorded per constitution I; the implementing session must not approve its own amendment.
Optionally decide whether a trailing comment after the `1` should be tolerated (the template itself
puts an HTML comment there, which is stripped; prose is not).

### F8 — Note: documentation gaps that are not contradictions (in scope, optional)

- `docs/sdlc/critical-delivery.md` and the constitution name the keys, the verdicts and the
  Critical-because requirement, but not the exact line syntax (`- **key**: verdict — reason`,
  `**Critical because**: reason` as its own non-indented, non-bullet line). That form lives in the
  template, the messages and the script header; they agree with each other and with the check,
  and I found no stated rule the check does not enforce, nor an enforced rule the docs contradict.
- A reason or Critical because that is wholly bracketed (`[owner decision 2026-01]`) is treated as
  an unfilled placeholder (reproduced). The check fails closed with a message that says "is not
  applies or does not apply followed by a reason", which is misleading for that input. The
  `fail-template-placeholder` rationale justifies the rule; the message could name the cause.
- The spec template comment says "Absent the field, a numbered feature is Standard", but
  `Invoke-StructureCheck` fails an absent Delivery Level and the rationale check is silent on it.
  Pre-existing and not caused by this commit; a spec with the marker and no level still fails (by
  Structure), so there is no hole.

## Checked and clean

Scope (phase 4's Territory only); no approved document changed; `$matches` (stale, overwritten
by the helper, `[2]` as reason, `[1]` as verdict, `$levelName`, the Where-Object): clean;
empty-after-trim reasons: fail by name, no exception; marker value matching, comment decoys,
CRLF, order of the graded line vs findings; Micro/Lite not graded and not misread; exit codes
(findings exit 1, UNGRADED exit 0 and prints UNGRADED, as D6 requires); the pre-existing
expectations unchanged; placeholder handling of the shipped template (four findings, never four
answers); duplicates (neither wins); ASCII hyphen and `--` accepted; pasted-message form works;
no unbounded loop, no swallowed exception, no catastrophic backtracking, 5,000-line spec in under
2 s; `-match`/`-notmatch` semantics identical on PowerShell 5.1 and 7; non-ASCII usage follows
existing precedent in the pack; the rationale check does not interact with the phase-3 surface
check (separate functions, separate lines, independent findings; the Critical case is not
graded by the surface floor, matching FR-011).

## Out of scope, stated not graded

A Standard feature whose answers are all `does not apply` while the spec text elsewhere describes
an authentication change passes. That is the documented limit, written in the script header,
constitution X and `critical-delivery.md`: the rationale is a claim a reviewer can falsify, not
proof. The path floor (phase 3, needs `criticalSurfaces`) is the backstop for the case a claim
cannot see.

## Recommended disposition

Approve phase 4. Fix F6 (fixtures) in this phase; F1-F4 are cheap enough to take at the same time
and each needs one fixture, but none blocks. F7 needs an owner decision and a recorded approval
before the approved contract and data-model are edited.
