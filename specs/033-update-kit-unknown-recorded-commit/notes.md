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
