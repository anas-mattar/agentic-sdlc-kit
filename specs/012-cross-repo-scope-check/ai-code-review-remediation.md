# AI Code Review — 012 Cross-Repo Scope-Check Reach (remediation re-review, DoD gate 5)

**Reviewer**: fresh-context agent — `claude-opus-5[1m]`
**Date**: 2026-09-09
**Branches**: `agentic-sdlc-kit` `012-cross-repo-scope-check` (tip `9fd86f5` at review time)
**Scope reviewed**: the remediation set `21c938c`, `03561c4`, `7aac1ec`, `12e6c3d`, `9fd86f5` — plus `363abae` ("phase 3 fixes: F1, F5, F6, F7, F10"), which carries the phases-2-3 F1 template half and both filed review documents. Files read end-to-end: `scripts/scope-check-repos.ps1`, `scripts/verify-kit.ps1` (dimension 4), `scripts/ritual-checks.ps1` (member wiring), `.github/workflows/code-repo-scope-check.yml.template`, `contracts/scope-check-repos-cli.md`, `specs/012-cross-repo-scope-check/{spec,tasks}.md`, both filed reviews, plus the touched law/adoption documents. Behaviour settled by execution against 14 fixture repositories built by the reviewer and 15 record shapes against a throwaway adopted-project copy — and, for every prior claim, against the pre-fix scripts extracted from `56c0068` / `714ff75`, so "fixed" means "the old code reproduced the reviewer's verdict on this fixture and the new code does not".
**Feature contract**: read-only; zero new dependencies; PowerShell 7 + Markdown/YAML/JSON; backward compatible (SC-004); no constitution amendment.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — `claude-opus-5[1m]`
- **Implementer**: the session credited in the `Co-Authored-By: Claude Opus 5 (1M context)` trailer of all six remediation commits — a different session; none of its conversation, reasoning or notes were available to this reviewer.
- **Inputs provided**: the six remediation commit shas and their diffs, both filed review documents, `spec.md`, `tasks.md`, `contracts/scope-check-repos-cli.md`, the kit's law documents, and the working tree.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE WITH FIXES** — Every finding in both filed reviews is fixed, correctly dispositioned, or explicitly referred, and the four BLOCKING ones are genuinely closed: the D4 declaration is now resolved **by path**, so a merged `main` can no longer mask a stray (fixture A: pre-fix WARN/exit 0 → post-fix FAIL/exit 1 on the identical fixture); FR-004 now FAILs a code commit that predates its declaration **while a genuinely legacy history still WARNs** (fixtures B/J/M vs C1/C2); the doctor no longer calls `[]`, `null`, `.` or `".."` a valid record; and the CI shape reaches the right verdict from a real clone sitting on the default branch (fixture G). The two verbatim enumerations were fixed *durably* — they no longer restate the member list at all — and `12e6c3d` correctly lands the Territory amendment before `9fd86f5` does the work. `ritual-checks.ps1` is green and all six commits PASS the machine scope check. Residual risk has moved out of the grader and into the shipped CI template (N1) and into adopter guidance (N2).

## (a) Disposition of prior findings

### `ai-code-review-phase1.md`

| # | Finding | Disposition | Evidence that settles it |
|---|---|---|---|
| F1 | Declaration resolved over the whole reachable graph; merging `main` silences gate 4 | **Fixed** | `rev-list -1 --before=… <ref> -- <path>`. Fixture A (declaration 09-02, unrelated `main` commit 09-03, code commit 09-04, `git merge main` 09-05): new code `FAIL … api/STRAY-LATE.txt not in territory` exit 1; the `56c0068` script on the *same* fixture `WARN … as of 2026-09-04` exit 0. Identical in `-All` and single-commit form. |
| F2 | FR-004 unimplemented (post-dating declaration WARNs) | **Fixed** (owner-adjudicated for the spec) | `Test-DeclaredAtTip` splits the two cases. Fixture B (code 09-01, declaration 09-02, file inside the territory): `FAIL … POST-DATES this commit` exit 1; pre-fix WARN exit 0. Legacy still WARNs: C1 (no declaration anywhere) and C2 (tip declares only phase 2, commit is phase 1) both exit 0. Also correct through a remote-tracking ref (J) and on the Micro lane (M). |
| F3 | Micro without Territory WARNs (in-repo grader FAILs) | **Fixed** | Fixture D: `FAIL … no usable **Territory** block … or promote to Standard` exit 1 — same rule and remediation as `scope-check.ps1`. |
| F4 | `-Commit HEAD` grades whatever branch the repo is parked on | **Fixed** | Fixture E (`api` parked on `099-other` carrying `QUARANTINE.txt`): default run `PASS phase 1 … (1 file(s))` on the branch tip; `-Commit HEAD` (opt-in) FAILs. Pre-fix default = FAIL. |
| F5 | `-All` checks nothing when the trunk is not `main` | **Fixed** (residual noted) | Fixture F (trunk `develop`): loud `NOTHING WAS GRADED … pass -BaseRef` + run-level `n/a`, exit 0; `-BaseRef develop` → FAIL exit 1. Residual: `develop` is not in the auto list and the shipped template passes no `-BaseRef`. |
| F6 | Run-level line not `n/a`-shaped | **Fixed for the reported case; residual → N3** | End-to-end in a throwaway adopted copy: summary reads `scope-repos n/a (nothing was graded …)`. |
| F7 | `codeRepos` entries used unvalidated as path segments | **Fixed** | 15 shapes probed: `.`, `..`, `....`, `a/b`, `C:\x`, a Unicode name → warned and dropped; scalar and object → not-an-array warning. Legitimate names survive: `api.v2` and `.config` both accepted and graded. |
| F8 | Contract omits ERROR; §4 implicit spec-dir wording | **Fixed** (small residual → N5) | ERROR row verified live (`-Repo nope` → exit 1); `-BaseRef` row, §5 and §6 added. |
| F9 | Phase-size guideline exceeded on `56c0068` | **Not applicable** (owner-awareness item) | Non-blocking warning persists; no remediation owed. |

### `ai-code-review-phase2-3.md`

| # | Finding | Disposition | Evidence that settles it |
|---|---|---|---|
| F1 | CI template grades nothing and reports green | **Fixed, both halves** (new risk → N1) | Fixture G is a real clone of a governance repo on `main`, feature branch only remote-tracking, code repo nested → `FAIL … exit 1`; the `56c0068` script on the same layout → WARN exit 0. |
| F2 | `"codeRepos": []` / `null` called valid | **Fixed** | absent / `[]` / `null` / `["",""]` → WARN; the `714ff75` doctor on the same records → `ok record — adoption record valid` with no warning. |
| F3 | `..` unenforced; `.` spurious PASS; scalar coerced | **Fixed** | `.` / `..` / `....` / `a/b` → FAIL exit 1; scalar and object → not-an-array FAIL; pre-fix all five returned "adoption record valid". `api.v2` and `.config` still accepted. |
| F4 | Three enumerations omit `scope-repos` | **Fixed, and durably** | Territory amendment (`12e6c3d`) landed before the work (`9fd86f5`); the two verbatim files now point at the wrapper. Repo-wide grep leaves only three enumerations, all correct, all declared as known residual. |
| F5 | "Both checks must PASS" stricter than the contract | **Fixed** | Both documents now read "Neither check may FAIL; `n/a`, `not applicable` and `WARN` are lawful non-blocking verdicts". |
| F6 | CLAUDE.md Repositories pointer | **Fixed** | Routes to "Territory across repositories" and names the script. |
| F7 | Header overstates leniency of a `CODE_REPO_DIR` mismatch | **Partially fixed → N4** | Step 2 corrected; the READING A RUN paragraph still listed it as a WARN cause. |
| F8 | `updating.md` overstates the doctor; dimension list; snippet | **Fixed** | Dimension summary names the code-repository audit; snippet has an insertion point; empty-array sentence added. |
| F9 | Existing multi-repo adopters told nothing | **Fixed** | `existing-system.md` §7b + the `updating.md` §2 feature-012 flow-down note. |
| F10 | Governance PAT persists in the checkout | **Fixed** | `persist-credentials: false`. |
| F11 | (a) master-trunk repo; (b) fork PR check run | (a) **Fixed** by the F5 fix; (b) **Not fixed — accepted** | (b) unchanged deliberately: the template stays push-only per F12. |
| F12 | Push-only decision is sound | **Not applicable** (accepted) | Reconfirmed. |

## (b) New findings

### N1 — `ref: ${{ github.ref_name }}` on the governance checkout turns a missing branch into an opaque job failure, and is not needed — MEDIUM

The script-side fallback resolves `refs/remotes/origin/<branch>`, and `actions/checkout` with `fetch-depth: 0` populates every remote-tracking ref — the layout of fixture G, where the fixed script returns the correct FAIL **without** any `ref:`. Pinning adds a failure mode: checkout errors before the check runs if the governance repo has no branch of that name. Scenario: governance merges `014-plans` and deletes the branch (the normal end of a feature) while the code repository pushes one more commit to its own `014-plans` — the job dies at checkout with `Remote branch 014-plans not found in upstream origin`, and re-running never helps.

*Action: implementer — drop `ref:` and let the script's ref search do the work (contract §3, fixture-proven), and correct the header lines describing a missing governance branch.*

### N2 — Nothing tells an adopter what happens when they declare territory over phases already committed — MEDIUM

FR-004 as implemented FAILs a phase commit whenever a usable declaration exists at the tip but did not exist at the commit's date — **regardless of whether the files are inside that territory** (fixture B: `api/src/early.txt` matches `api/src/**` perfectly and still FAILs, purely on ordering). A project turning this on mid-flight, doing the obvious honest thing and writing Territory for phases already committed, makes its code-repo CI red for that branch until it is rewritten or merged. The flow-down note states the rule but never the consequence or the remedy.

*Action: implementer — one sentence in the `updating.md` flow-down note and in repository-strategy.md's "Declare before you commit" bullet: territory is never back-declared; re-commit the phase on top of the declaration, or leave it undeclared (a lawful WARN) and declare from the next phase forward.*

### N3 — The "graded nothing" counter counts attempts, not gradings — MINOR

`$graded++` fires before the grading call, which then returns `SKIP` for a merge commit or a commit with no `phase N` token. A run in which nothing was graded but something was attempted suppresses the run-level `n/a` and summarises as a bare `scope-repos OK` — the shape F6 set out to remove. Reproduced on fixture L.

*Action: implementer — increment only on a PASS/FAIL verdict, and add "not applicable" to the template's READING A RUN sentence.*

### N4 — Template header contradicts itself and the FR-004 change — MINOR (doc drift)

The READING A RUN paragraph names "a mismatched `CODE_REPO_DIR`" as a WARN cause while the same commit's step 2 correctly says it fails the job (verified exit 1); it names "a governance branch that does not exist", which with N1's `ref:` can never reach the script; and it says a phase with no declaration "does not fail the run", which the FR-004 change made false for the post-dating case.

*Action: implementer — rewrite the two paragraphs against the shipped behaviour.*

### N5 — `-Commit`'s default documented two ways in one file — MINOR (doc drift)

The contract's parameter table still gives `HEAD`, contradicting §6 of the same document and the code; the usage comments are stale for the same reason.

*Action: implementer — three one-line edits.*

### N6 — The two graders now answer differently for the same situation — MINOR (owner CONFIRM)

`scope-check.ps1` WARNs when a phase commit's parent carries no Territory for that phase; `scope-check-repos.ps1` FAILs the equivalent cross-repo case whenever the declaration exists at the tip. Live evidence on this branch: `scope-check: WARN commit 12e6c3d: no territory declared for phase 4 …`. A single-repo project and a multi-repo project doing the same thing get opposite gate-4 verdicts. FR-003 asks for the semantics to be reused "without divergence"; the remediation closed the Micro divergence and opened this one by owner adjudication of F2.

*Action: owner — accept the asymmetry and record it in `definition-of-done.md` gate 4 (recommended: the cross-repo check is stricter because it has no parent-read structural guarantee), or schedule alignment of the in-repo grader.*

## (c) Territory containment, ordering and gate state

- All six remediation commits are inside their declared Territory: `PASS phase 1 commit 21c938c (2 file(s))`, `PASS phase 2 commit 03561c4 (2 file(s))`, `PASS phase 1 commit 7aac1ec (2 file(s))`, `PASS phase 3 commit 363abae (6 file(s))`, `PASS phase 4 commit 9fd86f5 (4 file(s))`.
- `12e6c3d` **precedes** `9fd86f5` and is a tasks-only commit — the Territory amendment lands before the work it governs (constitution X).
- `scripts/scope-lib.ps1`, `scripts/scope-check.ps1` and `scripts/ritual-checks.ps1` are **byte-identical to `56c0068`**, so the earlier review's 26-commit behaviour-preservation result still stands.
- Whole run: `ritual-checks: RESULT OK` — `doc-lint OK`, `enforcement-pack OK` (the `56c0068` phase-size warning persists, non-blocking), `scope-check OK`, `scope-repos n/a`, `digests OK (5 fresh, 72 markers)`, `roadmap-claims OK`, `verify-kit n/a`. SC-004 holds.
- Both filed review documents carry an intact Reviewer Provenance section with the attestation sentence verbatim; the enforcement pack passes. Their substance is faithful: every prior claim re-tested reproduced exactly, including verdict and exit code, when the pre-fix scripts were run against independently-built fixtures.

## (d) Commands run

```bash
git log --oneline -20 ; git show --stat 21c938c 03561c4 7aac1ec 363abae 12e6c3d 9fd86f5
git diff --stat 56c0068..HEAD -- scripts/scope-lib.ps1 scripts/scope-check.ps1 scripts/ritual-checks.ps1   # empty
git show 56c0068:scripts/scope-check-repos.ps1 > <scratch>/old-scope-check-repos.ps1
git show 714ff75:scripts/verify-kit.ps1        > <scratch>/proj/scripts/old-verify-kit.ps1
grep -rn "scope-repos|scope-check-repos" --include=*.md --include=*.yml --include=*.json --include=*.template .
pwsh -File scripts/ritual-checks.ps1 -Branch 012-cross-repo-scope-check          # RESULT OK
# fixtures A,B,C1,C2,D,E,F,G/G-ci,H,I,J,K,L,M (bash, fixed commit dates), each run against
# both the pre-fix and post-fix scripts, in -All, single-commit, -Repo, -BaseRef and Micro forms
# 15 codeRepos shapes against the grader and the doctor, pre-fix and post-fix
```

All writes were confined to the scratchpad; the kit repository was not modified by the reviewer.
