# AI Code Review — 013 Critical Independence Signal — check logic (round 3, phase 5 remediation)

**Reviewer**: fresh-context agent — `claude-opus-5` (Agent tool, `general-purpose`, task "Adversarial review of 013 check logic (resumed)")
**Date**: 2026-09-10
**Branch**: `agentic-sdlc-kit` `013-critical-independence-signal`
**Under review**: phase 5, `43e52cf..9054e97`
**Scope reviewed**: the phase 5 diff and the new `scripts/adoption-lib.ps1`, with the round-2 findings re-attacked on fixtures H1-H5 rather than re-read.
**Verdict**: APPROVE WITH COMMENTS — blocking findings: none

Everything below the rule is the reviewer's report, **verbatim**. It is evidence for
Definition of Done gate 5 and is not edited to match what was later fixed; where a finding
was wrong, the reviewer's own next round says so. What was done about each finding is
recorded in `tasks.md`, not here.

---

## Reviewer Provenance
- **Reviewer**: fresh-context agent — claude-opus-5
- **Implementer**: the main session that produced this diff
- **Inputs provided**: 013 phase 5 diff (`43e52cf..9054e97`, scripts/), my N1–N6 findings, new `scripts/adoption-lib.ps1`
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict
APPROVE WITH COMMENTS — N1 and N2 are closed and I could not defeat either. One new fail-closed regression (NEW-A) and four nits.

## 1. Committed-blob read (N1) — **CLOSED**, could not defeat

| fixture | result |
|---|---|
| H3 committed placeholder stub + filled working tree (the residual) | **fails** on the *committed* `[name]` placeholders — the working tree is genuinely never read |
| H4 committed on another branch, not reachable from HEAD | **fails** "is not committed" |
| H5 committed, then deleted in a later commit, restored in the working tree | **fails** "is not committed" |
| H1 untracked / H2 index-only | fail |
| H3b properly committed / H6 detached HEAD / H7 HEAD is a merge commit | pass correctly |

The two shapes you flagged are the two that mattered and both fail closed.

## 2. Unreadable record (N2) — **CLOSED**

`kit-adoption.json` as a **directory**, as a **zero-byte file**, and **exclusively locked** (`[IO.File]::Open(...,'None')` held open by another process) all now fall back to solo, run every later check, and print the normal `enforcement-pack: FAIL (1 issue(s))` summary with the correct solo message. No unhandled error, nothing skipped.

## 3. New regressions from phase 5

### CONFIRM NEW-A — `git show "HEAD:$Dir/…"` is repo-root-relative; every other path in the check is `$Root`-relative
`scripts/enforcement-pack.ps1:313`

The phase-4 form (`git log -- $reviewPath`) resolved against the current directory, which `Push-Location $Root` had already set. `git show HEAD:<path>` without a `./` prefix resolves against the **repository root** instead. When `-Root` is a subdirectory of the git repo, a correctly committed review is reported as uncommitted.

Reproduced (fixture `K2`): repo root containing `gov/`; review committed at `gov/specs/007-x/human-pr-review.md`; run with `-Root <repo>/gov -Branch 007-x` → *"specs/007-x/human-pr-review.md is not committed"*. Raw git from that cwd: `git show 'HEAD:specs/007-x/human-pr-review.md'` → `fatal: path 'gov/specs/…' exists, but not 'specs/…'`.

Fix verified in the same fixture: `git show "HEAD:./$Dir/human-pr-review.md"` returns the blob. The `./` prefix makes git resolve relative to cwd, which `Push-Location $Root` already set — one character, and it restores parity with the solo arm.

Fail-closed and needs an unusual layout, so not blocking — but it is a phase-5 introduction, which is what you asked about.

### NIT NEW-B — the indent stripper eats a legitimate nested-list provenance line
`scripts/enforcement-pack.ps1:325`

`^(?: {4,}|\t)\S` treats every 4-space or tab indent as a code block. In CommonMark, 4 spaces **inside a list** is a nested item, not code.

Reproduced (`P_nestlist`):
```
## Review Provenance

- Provenance:
    - **Reviewer**: Alice
    - **Owner**: Bob
```
→ both reported as missing. Tab-indented lines (`P_tab`) likewise. Fail-closed, and the fenced forms you added (` ``` `, `~~~`) all work correctly — N3 is otherwise closed. If you want to keep it tight, requiring a preceding blank line before treating an indent as code would fix the list case.

### NIT NEW-C — a committed-but-empty review says "is not committed"
`scripts/enforcement-pack.ps1:314` — `$null -eq $blob` conflates "no blob" with "empty blob". Reproduced (`H8`): a zero-byte `human-pr-review.md`, committed, reports *"is not committed"*. Fail-closed, wrong diagnosis. Test `$LASTEXITCODE` alone and let the empty content fail the section check.

### NIT NEW-D — the doctor's new gate is the one unguarded read in the new code
`scripts/verify-kit.ps1:263` — `if ($null -ne $record.developers -or (Get-Content -LiteralPath $recordPath -Raw) -match '"developers"')`. This is exactly the shape phase 5 just fixed in the lib, outside any try. Only a TOCTOU window (the same file parsed successfully ~70 lines earlier), so I could not trigger it — flagging it because the rule phase 5 adopted was "a read that can fail lives in a try", and this read does not.

### NIT NEW-E — `adoption-lib.ps1`'s try/catch depends on the caller's `$ErrorActionPreference`
`scripts/adoption-lib.ps1:52`. Demonstrated by dot-sourcing the lib into a default session (`Continue`): the `Get-Content` failure is non-terminating, the `catch` does **not** fire, and the raw error is printed. It still returns `Mode=solo` (the empty string falls through the root-object guard), so it is fail-safe, and both shipped callers set `'Stop'` — hence no impact today. `-ErrorAction Stop` on the lib's own read would make it self-contained.

### Also noted, not regressions
- **Dot-source vs `Push-Location`: no interaction.** The `. (Join-Path $PSScriptRoot 'adoption-lib.ps1')` at line 92 runs before `Push-Location $Root` and resolves against the script's own directory, and `Get-DeveloperMode -Root $Root` takes an absolute path, so cwd is irrelevant. Verified across every fixture (all invoked with `-Root` far from the kit). With the lib absent it exits 1 with a clean "not recognized" error, the same failure mode as `scope-lib.ps1`; `kit-manifest.json` ships `scripts/*.ps1` as `verbatim`, so `update-kit` carries it — no distribution gap.
- **The shared lib did what it was for.** Across ten record shapes (valid team, `null`, dupes, empty, blank entry, non-array, numbers, object-map, no field, root array) the doctor's stated mode matched `enforcement-pack`'s behaviour in every case, and every malformed record now draws exactly one FAIL plus the mode line. N6 is structurally closed — there is only one comparer left to disagree with itself.
- One inconsistency from the new gate: `"developers": null` prints `ok — 0 developer(s) — solo` with **no** FAIL, while `[]` draws a FAIL. An explicit null reads like the same unfinished edit.
- Pre-existing, not phase 5: the `$blob` check relies on `$LASTEXITCODE`, and under `$PSNativeCommandUseErrorActionPreference = $true` a non-zero `git show` throws instead (I reproduced the `NativeCommandExitException`). `Get-DiffBase` already depends on the same convention, so the script as a whole assumes it is off.
