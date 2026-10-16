# Notes: update-kit.ps1 names a recorded kit commit its kit clone does not know

Evidence for feature 033 (GAP-039). Nothing here is law; `spec.md`, `plan.md` and `tasks.md` are.

## Pre-spec measurement (2026-10-16, git 2.55.0.windows.5)

Method: a fresh `git clone` of FitForge (`D:/solutions/fitforge`) per probe into a scratch area (the real project never touched, nothing pushed),
`.kit-version` edited and committed where the probe says so, and the kit as it stands (`main` at `1b031b9`) run against it:
`pwsh -File scripts/update-kit.ps1 -Kit <kit> -Target <clone> [-DryRun] [-Json]`.

| # | Probe | Result |
|---|---|---|
| P1 | `.kit-version` names a commit the kit clone has (the project's real `kitCommit`), `-DryRun` | `Surgical - upstream changes, never applied (3)`, each `upstream commits since your recorded kit version - see adoption/updating.md`; `Result: kit 0.8.0 @ 1b031b9...`; exit 2 |
| P2 | `.kit-version` removed, `-DryRun` | `Surgical - ... (20)`, each `no baseline - review all`; exit 2 |
| P3 | `.kit-version` names a commit the kit clone does not have (`0000...0001`), `-DryRun` | **no Surgical section**; `Conflicts - locally modified, not applied (21)`, each `differs - no baseline (unknown provenance)`; `Result: ...`; exit 2 |
| P3b | the same, a real run | the same 21 conflicts, no Surgical section, exit 2; **`.kit-version` rewritten to the kit's HEAD** (`kitCommit` `1b031b9...`, `updatedOn` 2026-10-16) |
| P3c | the same, `-DryRun -Json` | keys `applied, surgical, conflicts, dryRun, result`; `surgical` has **0** entries, `conflicts` 21 |
| P4 | `.kit-version` is `{ not json` (a `try`/`catch {}` at `:185` swallows the parse error), `-DryRun` | the same as P2: `(20)`, `no baseline - review all` |

Where the silence comes from: `scripts/update-kit.ps1:258` runs `git -C $Kit log "$recordedCommit..HEAD" --oneline -- <path> 2>$null` and counts the lines. With a recorded commit the kit
clone does not have, `git log` exits non-zero ("bad revision") and prints nothing, which is also what a file with no upstream commit prints. The note that tells the adopter the report is delivered
once (`:320`, "NOTE: this surgical report is delivered once - the record now advances to kit HEAD") is printed only when the report is non-empty, so in P3b the adopter is given no warning that
a report existed.

Why the exit code is 2 in P3: the 21 verbatim files cannot be compared to a baseline and are conflicts, and a conflict means "attention needed". A project whose verbatim files were already at the kit's
current content would have no conflict and no surgical section, and the run would exit 0: not measured here (it needs a project in that state), stated in the spec.

The harness has no `update-kit.ps1` case (no case directory, no rule in `tests/enforcement/rules.json`); the script is reached only by the adopted-project measurements of earlier features.

## Plan-time measurement: the fully silent case (2026-10-16, git 2.55.0.windows.5)

A small kit and target built with plain git in a scratch area (the design of the test of plan P5): the kit has a manifest with one verbatim file (`docs/a.md`) and
one surgical file (`docs/sdlc/gate-command.md`), a constitution with `**Version**: 0.9.0`, and two commits, the second changing the surgical file; the target has the 14
kit-integrity essentials, the verbatim file at the kit's current content, the surgical file project-filled, and a committed `.kit-version` naming the kit's first commit.

| Probe (`update-kit.ps1 -Kit <kit> -Target <target>`) | Result |
|---|---|
| `.kit-version` names the kit's first commit, `-DryRun` | `Surgical - upstream changes, never applied (1)`: `docs/sdlc/gate-command.md`, `6ff634e kit two: gate command`, `upstream commits since your recorded kit version`; exit 2 |
| `.kit-version` absent, `-DryRun` | `Surgical ... (1)`: `docs/sdlc/gate-command.md`, `no baseline - review all`; exit 2 |
| `.kit-version` names an unknown commit (`0000...0001`), `-DryRun` | **`Result: up to date`, exit 0**: no Surgical section, no conflict (every verbatim file is current) |
| the same, a real run | **`Result: up to date`, exit 0**, and `.kit-version` is rewritten to the kit's HEAD (`6ff634e...`): the upstream change to the surgical file is lost with no word of it |

This is the state the FitForge measurement above could not show, because there the 21 verbatim files differed and surfaced as conflicts (exit 2). Here the run says the project
is up to date when it has a pending hand-edit. The state is reachable in practice when a project's verbatim files are current but its recorded commit is not the kit clone's
(a shallow clone, a rewritten history, another fork).

## Phase 1: an unknown recorded commit is reported

### T001 Baseline on the parent commit (`f2d1b1b`)

The saved text of the states is the test itself, written first (T003): on the parent commit the four states that must not change pass
(a recorded commit the kit has, one equal to the kit's HEAD, `.kit-version` absent, `.kit-version` malformed) and the three unknown-commit
cases fail. The full-harness count on an isolated detached worktree of the parent is in T005.

### T002 The probe of `git cat-file -e "<value>^{commit}"` against `git log "<value>..HEAD"` (git 2.55.0.windows.5)

Run against this repository (full history) and against a `--depth 1` clone of it:

| Value | `cat-file -e` | `git log` | Verdict |
|---|---|---|---|
| a full sha the kit has | 0 | 0 | known |
| the same, abbreviated to 9 characters | 0 | 0 | known |
| an unknown sha (`0000...0001`) | 128 | 128 | unknown |
| a branch name (`main`), `HEAD~1` | 0 | 0 | known |
| a tag that does not exist | 128 | 128 | unknown |
| `-oops` (an option-shaped value) | 129 | 128 | unknown |
| a **tree** sha | 128 | 0 | unknown (not a commit; `git log` happens to accept a tree-ish) |
| an empty string | 128 | 0 | never reaches the call: `-not $recordedCommit` takes the absent branch first |
| a full sha **beyond the boundary** of a shallow kit clone | 128 | 128 | unknown |
| the shallow clone's own HEAD | 0 | 0 | known |

The two disagree only for a tree sha and an empty string, neither a recorded kit commit; for every value `git log` could read as a commit, `cat-file` agrees. The CI image's
git is the CI run of the branch (the second git).

### T003 The test, written first; shown failing on the parent

`tests/enforcement/UpdateKit.Tests.ps1` (7 cases, a small kit and target built with plain git in a temporary directory, so it does not depend on the depth of the CI checkout). On the parent
commit the four unchanged states pass; `unknown, dry run` fails on `Expected 'Result: up to date' to not match` (the run printed `Result: up to date`, exit 0), `unknown, real run` on
`Expected 'Surgical - upstream changes, never applied \(1\):' to match`, and `-Json` on `Expected 1, but got 0` (the `surgical` array was empty).

### T004 The script

`scripts/update-kit.ps1` (12 insertions, 1 deletion): `$recordedKnown` from `git -C $Kit cat-file -e "${recordedCommit}^{commit}"` (taken only when `$recordedCommit` is set), the baseline condition of the
surgical pass becomes `-not $recordedCommit -or -not $recordedKnown`, and one `NOTE:` line in text mode names the unknown commit. All seven cases pass. On a clone of FitForge with an unknown
recorded commit, a dry run now prints the NOTE, `Surgical ... (20)` each `no baseline - review all`, and the 22 verbatim conflicts as before; `-Json` has 20 `surgical` entries where it had 0.

Environmental note: several tracked files of this working tree are CRLF on disk while the index holds LF (`git ls-files --eol`), and a script edit once left `update-kit.ps1` CRLF
(the whole file showed as changed). It was restored with `git checkout` and edited again, and every file of the commit is checked for CR before it is committed (the lesson of feature 032's review, finding F1).

### T005 Numbers (isolated detached worktrees outside the repository; the changed files copied into the second)

| | Parent `f2d1b1b` | Phase 1 working tree |
|---|---|---|
| full harness | 1828 passed, 0 failed, exit 0 | **1835 passed, 0 failed, exit 0** (the 7 more are the cases of `UpdateKit.Tests.ps1`) |
| coverage | 7 rules exempt from a fixture pair | 7 (unchanged); no new site, `update-kit.ps1` is outside the emission sweep |
| `UpdateKit.Tests.ps1` | not present | 7 passed; on the parent its three unknown-commit cases fail |
| the four states that must not change | pass on the parent | pass at the tip (known, equal to HEAD, absent, malformed) |
| clone of FitForge, unknown recorded commit, `-DryRun -Json` | `surgical` 0 entries | `surgical` 20 entries |
| `ritual-checks.ps1` | n/a | `RESULT OK` once the commit exists (`scope-check` is UNGRADED until then) |

Every pre-existing case passes unchanged; no case was re-expected.

### Phase 1 review follow-ups (`ai-code-review-phase1.md`, APPROVE with follow-ups, no blocking finding)

- **F1 (a real defect of the phase 1 commit), fixed with tests:** the "delivered once" NOTE built `$recordedCommit.Substring(0,7)`. Before this feature an unknown recorded commit never reached that
  line (the surgical report was empty); now it does, and a hand-edited `.kit-version` holding a value shorter than seven characters (`abc`) or a non-string (`123`) threw there, after `.kit-version`
  had been rewritten, exit 1. Two new cases of `UpdateKit.Tests.ps1` (a short value and a number, each a real run) failed on the phase 1 commit for exactly that reason and pass now; `$recordedShort`
  is computed once, with `[Math]::Min`. A third new case pins that a dry run leaves `.kit-version` as it was (the review's F5). The file now holds 10 cases.
- **F2 (accepted):** with an unknown commit and no surgical file in the manifest, the output is the NOTE then `Result: up to date`, exit 0: the plan allows it (P3: the verbatim pass lacks its
  baseline too, and the NOTE says so), and a project whose verbatim files are current has nothing to apply. No real manifest has no surgical file, and the case is not built.
- **F3 (accepted):** a tree sha as the recorded value changes from "listed with commits" to unknown; it is not a commit, and T002 above records the disagreement. The plan's sentence that a
  value `git log` could read is never called unknown holds for every value that is a commit.
- **F4 (wording):** the 22 conflicts of T004 and the 21 of the pre-spec measurement are the same state on different kit commits (the kit gained a verbatim file between them; both were measured). T001
  refers to "T006" where T005 is meant; the saved text of the byte comparison is the test itself (the four unchanged states pass on both commits, and the same cases were run on the parent script and the tip script
  by the reviewer, in text, `-DryRun` and `-Json`); the unguarded `rev-parse HEAD` the spec cites at `:186` is at `:194` after the added lines (the spec keeps the line of the parent). The CI image's git
  re-measurement of T002 is the CI run of the branch, recorded when it finishes.
