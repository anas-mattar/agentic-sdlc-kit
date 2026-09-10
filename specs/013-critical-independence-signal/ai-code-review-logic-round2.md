# AI Code Review — 013 Critical Independence Signal — check logic (round 2, phase 4 remediation)

**Reviewer**: fresh-context agent — `claude-opus-5` (Agent tool, `general-purpose`, task "Adversarial review of 013 check logic (resumed)")
**Date**: 2026-09-10
**Branch**: `agentic-sdlc-kit` `013-critical-independence-signal`
**Under review**: phase 4, `20bda18..43e52cf` plus `a76e877`
**Scope reviewed**: the phase 4 diff, re-tested against the reviewer's own round-1 fixtures — every prior finding re-run on the pre-fix and post-fix scripts, so "closed" means the old code reproduced the finding and the new code does not.
**Verdict**: REQUEST CHANGES — blocking findings: 1 regression + 1 residual

Everything below the rule is the reviewer's report, **verbatim**. It is evidence for
Definition of Done gate 5 and is not edited to match what was later fixed; where a finding
was wrong, the reviewer's own next round says so. What was done about each finding is
recorded in `tasks.md`, not here.

---

I re-ran every fixture from round one against `43e52cf`, plus new ones aimed at the fixes themselves.

## Reviewer Provenance
- **Reviewer**: fresh-context agent — claude-opus-5
- **Implementer**: the main session that produced this diff
- **Inputs provided**: 013 phase 4 diff (`20bda18..43e52cf`, scripts/ + specs/_templates/), my round-1 findings, spec.md, plan.md, critical-delivery.md
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict
REQUEST CHANGES — both BLOCKINGs are substantively closed and the fixes are good ones. What remains is one new regression and one residual of BLOCKING 1, each a small, well-scoped change.

## Status of my round-1 findings

| # | Round-1 finding | Status |
|---|---|---|
| BLOCKING 1 | untracked `human-pr-review.md` passes | **CLOSED with a residual** — see N1 below |
| BLOCKING 2 | commented-out provenance block passes | **CLOSED** |
| CONFIRM 3 | duplicate developers inflate into team mode | **CLOSED** |
| CONFIRM 4 | root-array record selects team | **CLOSED** |
| CONFIRM 5 | exact-string reviewer≠owner; roster never compared | **NOT fixed** (by design) — disclosure judged adequate, see below |
| NIT 6 | markdown-link name rejected as placeholder | **CLOSED** |
| NIT 7 | fenced code inside the section counts | **PARTIALLY closed** — see N3 |
| NIT 8 | dead `$dir = $Dir` | **CLOSED**, and verified not to break solo messages |
| NIT 9 | doctor double-reports / omits mode | **CLOSED** |

Evidence for the closures (all re-run, not taken on trust):

- **BLOCKING 2.** Fixture `A7` (whole block wrapped in `<!-- -->`) now fails with three findings instead of exit 0. `T_BROKENCOMMENT` — the shipped template, filled, with the explanatory comment's closing `-->` deleted — now fails with *"has no visible '## Review Provenance' section"*, where it previously passed. `A14` (attestation only in an unrelated comment) now fails, because the match moved to `$slice`. The shipped template unfilled still fails on both placeholders; filled, it passes.
- **I could not defeat `Get-VisibleText` in the fail-open direction.** Nested comments (`<!-- a <!-- b -->`) strip exactly where a renderer ends the comment (pass, correct). A stray `-->` inside a code fence with no preceding `<!--` strips nothing (pass, correct). CRLF throughout works. `<!-->` and `<!-- x --!>` (HTML5-only terminator) both truncate to EOF and fail closed. Every divergence I found between the stripper and a renderer errs toward seeing *less* text, never more.
- **CONFIRM 4.** `[{"developers":["a","b"]}]` and `[{"developers":["a","b"]},{"developers":["c"]}]` both resolve to solo now. **The text-level guard is sound and I do not think it can be defeated**: the root of a JSON document is whatever the first non-whitespace character opens, so if that character is `{` the value either is an object or the text does not parse (caught by the `try`). A `{` inside a string can never precede the root. BOM is doubly covered — `Get-Content -Raw` strips a real UTF-8 BOM, and the explicit `[char]0xFEFF` in `TrimStart` catches one that survives; a mis-decoded BOM (`ï»¿`) simply fails the `^\{` test and goes solo. Leading junk of any kind → solo. Your note about `-is [PSCustomObject]` is right, and keeping it as a second gate after the text test costs nothing.
- **CONFIRM 3.** `["alice","Alice"]` and `["alice"," alice "]` now both resolve to solo, and the doctor's mode line agrees with `Get-EvidenceMode` on every record I tried (empty, blank entry, numbers, dupes, valid pair).
- **Solo byte-identity: re-verified independently.** Five paths — no record / record with no field / one developer / review committed inside the window (remainder arithmetic) / review present but untracked — diffed `main`'s script against `43e52cf`. Identical strings and identical exit codes on all five. Removing `$dir = $Dir` is safe: `$dir` in the message strings resolves to the `$Dir` parameter (PowerShell variable names are case-insensitive), which I confirmed by output rather than by reading.
- **git-history guard.** Untracked → fails. Staged-but-not-committed → fails. Committed on main then deleted on the branch → fails at `Test-Path` with the "is missing" message (correct). Non-ASCII path (`specs/007-café/…`) → works; the backslash pathspec `Join-Path` produces is accepted by git here.

**On CONFIRM 5 (disclosure):** adequate. The header comment now says the roster is *"COUNTED and nothing more … never compared against Reviewer or Owner. A review naming two people who are not in the roster passes."* That is the exact statement the code needed, it names the limit rather than implying coverage, and FR-007 asked for honesty rather than a fix. The `.md` file's Edge Case is now answered in the place a reader of the check will look. No further change needed.

## New findings

### CONFIRM N1 — Residual of BLOCKING 1: a committed *path* with uncommitted *content* passes
`scripts/enforcement-pack.ps1:350` (guard) vs `:355` (`Get-VisibleText -Path $reviewPath` reads the working tree)

The guard proves the path appears somewhere in history; the content is still read from disk. So the hole moved rather than closed: commit the file, then fill it locally.

Reproduced (fixture `G3`): team record; `specs/007-x/human-pr-review.md` committed in phase 2 containing only `- **Reviewer**: [name]` / `- **Owner**: [name]` — content that, read from git, fails on both placeholders. Then the file is filled in the working tree with real names and the attestation and **not committed**. `enforcement-pack.ps1` → **exit 0**. `git status` shows the file modified.

This is the natural workflow, not a contrivance: copy the template in early, fill it at review time. And it lands in the same place as the original finding — Critical forbids `ci-held`, so the authoritative gate is the human's local run, and that run says green while the branch does not carry the evidence.

Fix: read the committed blob instead of the working tree — `git show HEAD:<path>` (fall back to the "not committed" message when it errors), then feed that text to `Get-VisibleText`. Same one-call shape as the guard it replaces, and it makes the guard redundant. The behaviour it produces — "your edits don't count until you commit them" — is exactly what the solo arm already says with *"commit it to start the clock"*.

### CONFIRM N2 — New regression: an unreadable `kit-adoption.json` now crashes the whole enforcement pack
`scripts/enforcement-pack.ps1:245`

The remediation moved `Get-Content` **out of** the `try` that used to wrap it:

```powershell
$rawRecord = "$(Get-Content -LiteralPath $recordPath -Raw)"   # line 245 — outside the try
...
try { $record = $rawRecord | ConvertFrom-Json } catch { ...solo... }
```

With `$ErrorActionPreference = 'Stop'`, any read failure on a path that `Test-Path` accepts is now unhandled. FR-003 lists "unreadable" among the degenerate records that MUST resolve to solo.

Reproduced (fixture `U1`): make `kit-adoption.json` a directory. Pre-remediation script → falls back to solo, runs every check, prints `enforcement-pack: FAIL (1 issue(s))` with the correct CriticalEvidence line. Remediated script → `Get-Content: … Unable to get content because it is a directory`, **no check summary at all**, and CriticalEvidence plus every check ordered after it (GateBatching, GateCertification, ReviewProvenance, PhaseSizeWarning) never run. Realistic triggers beyond a directory: a file locked by an editor on Windows, a permission denial, a dangling symlink.

Exit code is still 1, so nothing passes wrongly — but a whole check suite is silently skipped behind an undiagnosable error. Fix: move line 245 back inside the `try` (or wrap it in its own), returning the existing `'kit-adoption.json does not parse'` / an `'is not readable'` solo result.

### NIT N3 — Residual of NIT 7: only ``` fences are stripped
`scripts/enforcement-pack.ps1:362`

Reproduced: a `~~~`-fenced block (fixture `V8`) and a 4-space-indented code block (fixture `V7`) inside the section, each carrying `- **Reviewer**: Alice` / `- **Owner**: Bob` / the attestation, both → **exit 0**. Illustration still counts as declaration in those two forms. Lower severity than the original since the text is at least visible when rendered; `^(?:```|~~~)` plus a leading-indent guard on the field regex would finish it.

### NIT N4 — `IndexOf('<!--')` is culture-sensitive
`scripts/enforcement-pack.ps1:396`

`String.IndexOf(String)` uses `CurrentCulture`, not ordinal. Demonstrated: `"x<`u{00AD}!--y".IndexOf('<!--')` returns **1** under culture comparison and **-1** ordinal — a soft hyphen splitting the marker makes the check truncate the document at a comment start no renderer sees. Direction is fail-closed, and I found no fail-open counterpart (a culture search still finds every literal). Use `IndexOf('<!--', [StringComparison]::Ordinal)` so the behaviour is not locale-dependent.

### NIT N5 — A `<!--` in an inline code span before the section causes a false failure with a misleading message
`scripts/enforcement-pack.ps1:392-398`

Reproduced (fixture `V3`): a review whose header text reads ``Use the `<!--` marker sparingly.`` above a perfectly good provenance block → **exit 1**, *"has no visible '## Review Provenance' section … A section inside an HTML comment does not count: it renders as nothing"*. A renderer shows both the code span and the section. Same class as `<!-->` (fixture `V5`). Fail-closed, so no security impact, but the author of that review will not be able to work out what is wrong from the message. If you keep the dangling-comment rule as-is (and I think you should — it is the right rule), consider adding to the message that an unterminated `<!--` anywhere earlier in the file hides everything after it.

### NIT N6 — Doctor's duplicate-name extraction could null-deref if its two comparers diverge
`scripts/verify-kit.ps1:280` vs `:282`

The dupe is *detected* with `Sort-Object -Unique -CaseSensitive:$false` (culture-aware collation) and then *named* with `Group-Object { $_.ToLowerInvariant() }` (ordinal). If the first ever collapses a pair the second does not group, `@(…)[0].Group[0]` dereferences `$null` under `$ErrorActionPreference = 'Stop'`. **I could not produce a divergence** — I tried `co-op`/`coop`, `ada`/`a-da`, `O'Brien`/`OBrien`, `an as`/`anas` on en-US and all four kept two entries in both comparers. Reporting it as a latent hazard only: using one comparer for both would remove the question.
