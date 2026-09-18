# AI Code Review — 014 Amendment Authority (phase 2)

**Reviewer**: fresh-context agent — claude-opus-5
**Date**: 2026-09-13
**Branches**: agentic-sdlc-kit `014-amendment-authority` (tip `a976f6d`; phase 2 commit `14cf1d6`)
**Scope reviewed**: `git show 14cf1d6` in full (`scripts/enforcement-pack.ps1` +128 lines:
`$script:AmendmentRecordPattern`/`Example`, `Test-AmendmentCheckPresent`, `Get-AddedLines`,
`Test-CheckboxOnlyChange`, `Get-ConformingRecord`, `Invoke-AmendmentAuthorityCheck`, and the
`NNN-*` dispatch wiring at line 773); `specs/014-amendment-authority/{spec,plan,tasks,notes}.md`;
`.specify/memory/constitution.md` Principle I + SYNC IMPACT REPORT; `ai-code-review-phase-1.md`
and `ai-code-review-phase-1-remediation.md`; `scripts/scope-lib.ps1`; `kit-manifest.json`;
`.github/workflows/ritual-checks.yml` and `project-gate.yml.template`. Executed: the supplied
seeder (S1–S14, S9b, N1–N3 — all 18 verdicts reproduced), 22 new adversarial fixtures of my own
(H-series, `scratchpad/attack.ps1` and `attack2.ps1`), an independent old-vs-new regression diff
across 20 repositories, and a runtime measurement.

**Feature contract**: read-only; `git` plumbing only; zero new dependencies; no new file in
`scripts/`; every pre-existing pack message byte-identical; verdict for a given commit must never
change with the calendar (plan, Technical Context + D6).

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5
- **Implementer**: claude-opus-5 (the session that produced phase 2)
- **Inputs provided**: phase 2 diff (`14cf1d6`), spec.md, plan.md, tasks.md, notes.md,
  `.specify/memory/constitution.md`, both prior reviews (`ai-code-review-phase-1.md`,
  `ai-code-review-phase-1-remediation.md`), the fixture seeder `scratchpad/seed.ps1`
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — 6 blocking, 10 non-blocking. The check is real: it walks commits, it
grades the shapes the fixture table names, it reproduces all 18 seeded verdicts, it adds no
message to any existing pack member (verified independently by diffing the parent blob's output
against the new one across 20 repositories), and it never fired on an innocent commit I could
construct — empty commits, `notes.md`-only, `screenshots/`-only, merge commits, renumbering,
CRLF blobs, Micro, the Lite lane and a shallow clone are all clean. But the fixture table is the
author's own audience, and against fixtures the author did **not** design the check gives the
wrong verdict in eight distinct shapes, seven of them **false PASS**. The two that matter most
are not exotic: a record line hidden inside an HTML comment is accepted (H1), and a `tasks.md`
change that moves a `**Territory**` entry out of a later phase and into the current one is
graded as "progress" (H2) — a silently widened Territory is one of the five FitForge 001
amendments SC-002 exists to catch, and it is exempted by construction. There is also one
**false FAIL** that will hit this repository's own owner: the author-date comparison is
evaluated in the *runner's* timezone, so a conforming amendment committed before 08:00 in
`+08:00` is green locally and red in CI (H6) — the precise property D6 says the comparison
exists to guarantee. Residual risk sits entirely in the classifier, not in the plumbing: the
commit walk, the D2b boundary and the regression discipline are sound, and every finding below
is a localized predicate with a cheap fix.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | Walked FR-004→FR-011 and SC-001→SC-006 below. Met: FR-004, FR-005, FR-009, FR-011, SC-001. Partly met: FR-002 (H4), FR-006 (H2), FR-007 (H6), FR-008 (H8), FR-010 (H3). Deferred to phase 3: SC-002, SC-003, SC-004. Unmeasured by the implementer, measured here: SC-006 (H10). |
| Fixture table reproduced | `pwsh -File scratchpad/seed.ps1` re-run 2026-09-13: S1 PASS, S2 PASS, S3–S8 FAIL, S9/S9b PASS, S10/S11 FAIL, S12/S13 PASS, S14 FAIL, N1/N2/N3 PASS — 18/18 identical to the table in `notes.md`. |
| Adversarial fixtures (mine) | 22 new scenarios under `scratchpad/atk*/`. 8 wrong verdicts: `A_htmlcomment`, `B_otherfile`, `C_movedrecord`, `D_territorymove`, `D2_taskswap`, `D3_taskmove`, `E_renamemodify`, `E2_renumber_edit`, `M_dashdash` PASS when they should FAIL; `F_timezone` FAILs when it should PASS. Clean: `H_crlf`, `I_innocent` (empty commit + `notes.md`/`screenshots/`), `K_binary`, `Q_delete`, `L_disable`. |
| Feature contract held (no new file, no package, read-only) | `git show 14cf1d6 --stat` = 3 files (`scripts/enforcement-pack.ps1`, `specs/014-.../notes.md`, `specs/014-.../tasks.md`). Every git call is `show`/`rev-list`; no writes, no network, no new dependency. `scripts/scope-lib.ps1` declared in Territory and untouched — permitted. |
| Regression: pre-existing messages byte-identical | Independent of the implementer's claim: `git show 370a28b:scripts/enforcement-pack.ps1` → `scratchpad/old/scripts/`, ran both packs over this repository and over 19 fixture repositories, diffing output with `AmendmentAuthority` lines filtered. Identical everywhere except the summary line (`OK` → `FAIL (1 issue(s))`) on repositories where the new member legitimately fires. On this branch the two outputs are byte-identical including the three `PhaseSizeWarning` lines. **Claim verified.** |
| Constitution / D-decisions | D1 commit walk (line 715), D2 creation (732), D2b boundary (719, 644–650), D3 multiset (664–678), D4 one record per commit (742), D5 message (751), D6 malformed/future (681–708), D7 merge skip (718), D8 lane scope (711, 731) — each implemented as written. Divergences from the *spec* (not the plan) are H2/H3/H4. |
| Security | Read-only; no secrets; no interpolation of untrusted text into a shell (`git` is invoked as a native command with array args, branch name never re-shelled). `$dir` is built from a branch already constrained to `^\d{3}-`. PASS. |
| Scope guard | Phase 2's declared Territory is `scripts/enforcement-pack.ps1` + `scripts/scope-lib.ps1`; `14cf1d6` touched the first plus `specs/014-amendment-authority/**` (excluded by kit convention). `tasks.md` in that commit is a single hunk of ten checkbox flips (T010–T019) — no amendment. **In scope.** But see H14: `scripts/scope-check.ps1` now grades `a976f6d`, not `14cf1d6`. |
| Rollback safety | Reverting `14cf1d6` removes the function and the dispatch line and restores the parent pack exactly (verified by the byte-identical diff above). No state, no schema. PASS. |
| PowerShell correctness | `$matches` reuse (685–687) is safe: `-notmatch` leaves `$matches` untouched only on the `continue` path, and both captures are read before any later `-match` overwrites them. `[bool]($blob | Where-Object …)` (649) is correct for the empty/one/many cases. `$parts[$parts.Count-1]` (728) yields the new path on `R`/`C` rows and the path on `A`/`M`/`D`. `$LASTEXITCODE` is left non-zero by failing `git show` calls but nothing downstream reads it (the script exits explicitly, 786/790). `$PSNativeCommandUseErrorActionPreference` is `False` on pwsh 7.6.6 here, so `$ErrorActionPreference='Stop'` does not turn a failing `git` into a terminating error; a host that sets it `$true` would make the D2b probe throw — worth a `try{}` but not demonstrated. Remaining defects: H6 (timezone), H13 (culture), H9 (diff-marker guards). |
| Runtime (SC-006) | Measured, because nothing in `notes.md` claims anything about it. `enforcement-pack` alone: 989/971 ms (parent blob) vs 2006/2175 ms (phase 2) on this 10-commit branch — **+1.0–1.2 s, i.e. the member more than doubles the pack**. Full `ritual-checks.ps1`: 9 711 ms, so ≈11 % today. See H10 for why almost all of it is paid by commits that are then skipped. |

## Findings

### H1 — A record hidden inside an HTML comment is accepted — BLOCKING

`scripts/enforcement-pack.ps1:653-659` (`Get-AddedLines`) and `:681-708`
(`Get-ConformingRecord`) read raw diff lines. Nothing strips HTML comments, so a record that
renders as **nothing** in the document turns the branch green.

Failing input (`scratchpad/atk/A_htmlcomment`, rebuildable with `pwsh -NoProfile -File
scratchpad/attack.ps1`): a commit appends to an approved `plan.md`

```text
The package list now includes leftpad.

<!--
**Amendment approved by**: ada, 2026-09-13.
-->
```

with `Amendment approved by: ada, 2026-09-13.` in the message. Observed: **PASS** (no
`AmendmentAuthority` line, exit 0). A reviewer reading the rendered `plan.md` sees a new package
and no approver anywhere.

This also contradicts an already-ratified rule of this very script: `Get-VisiblePlanLines`
(`:141-150`) and `scope-lib.ps1:46` exist precisely because "a declaration hidden in an HTML
comment block must never win first-match over the rendered one (008 phase 2 review, F1)". The
new member is the only declaration-reader in the pack that ignores that precedent.

*Action: strip comments before matching — pass the added lines through the existing
`Get-VisibleLines` semantics, or reject any candidate record line that falls inside an
unterminated `<!-- … -->` region of the added text. Add the scenario to the fixture table (S15)
so the precedent is held by a test, not by memory.*

### H2 — `tasks.md` moves and reorders are graded as "progress" — BLOCKING

`:664-678` (`Test-CheckboxOnlyChange`) strips the checkbox marker from every added and removed
line, sorts both, and calls the change exempt when the multisets are equal. A *move* of an
unchanged line produces exactly that shape: one deletion and one insertion of identical text.
So relocating agreed content inside `tasks.md` is exempt — including the `**Territory**` block,
which lives in `tasks.md` and is what `scope-check.ps1` grades.

Failing input (`scratchpad/atk/D_territorymove`): the fixture `tasks.md` declares phase 1
Territory `src/a.ts` and phase 2 Territory `src/b.ts`, `src/danger.ts`. One commit moves the
`- \`src/danger.ts\`` entry out of phase 2's block into phase 1's, message `phase 1: tidy the
territory lists`, no record anywhere. Observed: **PASS**. Phase 1 may now legally touch
`src/danger.ts` and both machine checks agree it is progress. This is the "two widened Territory
blocks" class of FitForge 001's finding F3 — the class SC-002 exists to catch.

Two further confirmations of the same predicate: `D2_taskswap` (swapping two task lines —
reordering agreed work) and `D3_taskmove` (moving `T002` from phase 1 into phase 2 — changing
which phase owns it) both PASS.

The exemption is stated in the constitution as "a `tasks.md` change that alters nothing but task
completion state"; a moved line alters more than completion state, so this is the *check*
disagreeing with the *clause*, not a gap in the clause.

*Action: compare position-aware, not as a bag. Cheapest correct form: require that after
stripping markers the removed and added sequences are equal **pairwise in diff order** and that
every pair differs only in the marker — i.e. derive the exemption from the paired
`-`/`+` lines within each hunk rather than from two sorted lists of the whole diff. Add S15b
(line move) and S15c (task reorder) to the table with expected FAIL.*

### H3 — Rename-plus-modify escapes the check entirely — BLOCKING

`:732` — `if ($status -match '^[AR]') { continue }` — skips every rename row regardless of
similarity index. D2's rationale only needs `R100` (a renumbered directory, content untouched)
to read as creation; `R087` is a rename *and* a content rewrite, and it is skipped too.

Failing inputs:

- `scratchpad/atk/E_renamemodify`: one commit does `git mv contracts/auth.md
  contracts/auth-v2.md` and rewrites two clauses ("single-use" → "reusable for 30 days",
  "bad credentials" → "anything at all"), no record. Observed: **PASS**.
- `scratchpad/atk/E2_renumber_edit`: the S13 renumbering shape (`git mv specs/001-fixture
  specs/002-fixture` after a lost claim race) *plus* `And while renaming, a brand new package:
  leftpad.` appended to `plan.md` in the same commit, no record. Observed: **PASS** — the whole
  approved plan is rewritten under cover of the rename that FR-010 protects.

*Action: read the similarity score git already prints (`R100`, `R087`) and skip only exact
renames; for `R<100` (and `C<100`), classify as an amendment and grade it. `git show
--name-status -M` gives the score in `$parts[0]`; the two-char test is `$status -match
'^R100$'`. Note that `scope-lib.ps1:33` already parses both sides of an `R` row, so the shape is
familiar to this codebase.*

### H4 — The record need not be in, or anywhere near, the amended document — BLOCKING

`:742` — `Get-AddedLines -Commit $commit -Paths @("$dir")` — searches every added line under
`specs/<branch>/`, including files that are **not** in the graded set (`notes.md`,
`research.md`, `data-model.md`, `screenshots/*`) and files created by the same commit. FR-002
requires the record "on the amended section"; the failure message at `:748` tells the developer
exactly that. The check verifies neither.

Failing input (`scratchpad/atk/B_otherfile`): one commit appends `The package list now includes
leftpad.` to the approved `plan.md` and creates `notes.md` containing
`**Amendment approved by**: ada, 2026-09-13.`, with the name in the message. Observed:
**PASS** — and `plan.md`, the amended document, carries no record at all. `notes.md` is
precisely the file D3b told this feature to use for evidence, so the collision is not
hypothetical.

This is not D4: requiring the record in at least one of the *amended* files still lets one
record cover a plan-plus-tasks amendment, which is all D4 asks for.

*Action: pass `$amended` (the graded paths this commit actually amended) to `Get-AddedLines`
instead of `@("$dir")`. Optionally tighten further to "the record line is inside one of the
diff hunks of an amended file", but the path restriction alone closes the demonstrated hole.*

### H5 — An existing record line that merely moved counts as a new record — BLOCKING

`Get-ConformingRecord` asks only whether a conforming line appears among the commit's **added**
lines. A line that already existed and was relocated appears as an addition, so a commit can
satisfy the rule with a record nobody wrote for it. Combined with `:751` — the message test is
an unanchored, case-insensitive substring (`$message -notmatch [regex]::Escape($record.Name)`)
— the whole rule can be satisfied by an incidental mention.

Failing input (`scratchpad/atk/C_movedrecord`): commit 1 is an honest, recorded amendment by
`ada`. Commit 2 rewrites the plan's substantive sentence (`Original text.` → `Original text, now
meaning something else entirely.`) **and** moves the existing record line to the end of the file;
message: `tidy the plan layout, following on from ada's earlier change`. Observed: **PASS** — a
silent rewrite of an approved plan, green, with no approval of any kind.

*Action: ignore a candidate record whose identical text already exists in the parent blob of the
file it was added to (one extra `git show <parent>:<path>` per candidate, or reuse the diff's
removed lines: a record that is both removed and added in the same commit is a move, not a
record). Separately, anchor the message test — see H7.*

### H6 — The author-date comparison is evaluated in the runner's timezone (false FAIL) — BLOCKING

`:740-741`:

```powershell
$dateText = (git show -s --format=%aI $commit 2>$null)
if ($dateText) { $commitDate = [datetime]::Parse($dateText) }
```

`%aI` carries the author's own UTC offset; `[datetime]::Parse` converts it to the **runner's**
local time, and `:703` then compares `$parsed.Date -gt $CommitDate.Date`. A commit authored
early in the morning in a positive offset lands on the previous calendar day once the runner is
further west — and the standard case is a developer at `+08:00` (this repository's owner) with
CI at UTC.

Failing input (`scratchpad/atk/F_timezone`): a conforming, recorded amendment
(`**Amendment approved by**: ada, 2026-09-13.`, same name in the message) committed with
`GIT_AUTHOR_DATE=2026-09-13T01:00:00+1400`. `git show -s --format=%aI` returns
`2026-09-13T01:00:00+14:00`. Observed on a `+08:00` runner:

```text
AmendmentAuthority: commit 07ef591 amends specs/001-fixture/plan.md after approval with no
conforming approver record. Rejected record(s): date '2026-09-13' is later than the commit's
own author date (2026-09-12). …
```

The message asserts a date the commit does not have. The same commit passes on a `+14:00`
runner: the verdict depends on the machine, which is exactly what D6 says the author-date
comparison exists to prevent ("the same commit must grade the same way on every future run").
The green-local/red-in-CI direction is the credibility-destroying one.

*Action: never parse `%aI` into local time. Take the date as the author wrote it —
`git show -s --format=%ad --date=format:%Y-%m-%d` (or the first ten characters of `%aI`) — and
compare the two `yyyy-MM-dd` strings, or `TryParseExact` both with `InvariantCulture`. This also
disposes of H13.*

### H7 — The D5 name test is an unanchored substring over the whole message — NON-BLOCKING

`:751`. The name is matched anywhere in the message, with no word boundary and no required
shape, so the "half a later edit cannot fake" is weaker than the clause implies.

- `scratchpad/atk/G_substring`: record `**Amendment approved by**: Al, 2026-09-13.`, message
  `amend the plan` / `Also re-ran the checks.` Observed: **PASS**. `Al` matched `Also`.
- `scratchpad/atk/G2_coauthor`: record `**Amendment approved by**: Claude, 2026-09-13.`,
  message carrying nothing but this repository's mandated trailer
  `Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>`. Observed: **PASS** — an
  implementing agent naming itself as approver is auto-satisfied by the commit convention
  `CLAUDE.md` requires. FR-003 says nothing verifies self-approval, so this is a documented
  limit rather than a surprise, but it is worth the clause knowing that the trailer alone
  greens it.
- `scratchpad/atk/J_nbsp`: record name `ada lovelace` (non-breaking space), message
  `ada lovelace`. Observed: **FAIL** with "commit message does not name them", over two strings
  that are visually identical. Correct strictness, unhelpful message.

*Action: require a word-boundary match (`(?<!\w)` … `(?!\w)`) and normalize whitespace
(collapse Unicode spaces to `' '`) on both sides before comparing; consider requiring the
message to carry the record shape rather than the bare name, which is what `notes.md` already
says the S4 message cannot otherwise disambiguate.*

### H8 — A near-miss record is rejected silently, with a message that says none was found — NON-BLOCKING

`$script:AmendmentRecordPattern` (`:640`) is anchored at both ends and permits only an optional
trailing period. A line that does not match is skipped at `:685` **before** the malformed-record
bookkeeping, so it never reaches `$result.Malformed` and the developer is told there is no
record at all — with no hint that the line they wrote was read and rejected. FR-008 says a
developer must never have to read the script to learn what the check wants.

Failing inputs, all with a correct name and date in both file and message, all reported as
"no conforming approver record" with **no** `Rejected record(s)` clause:

- `atk2/N_trailing`: `**Amendment approved by**: ada, 2026-09-13 (owner).`
- `atk2/O_colon`: `**Amendment approved by:** ada, 2026-09-13.` (the colon inside the bold —
  the commonest markdown slip)
- `atk2/P_indent`: the same line indented two spaces (as a nested list item)

*Action: match a looser "looks like a record" probe (`^\s*\*\*Amendment approved by[:*]`) first
and, when it matches but the strict pattern does not, push
`"line '<text>' is close to a record but does not match <example>"` into `$result.Malformed`.
Zero risk to the pass path.*

### H9 — The diff-marker guards are content-blind — NON-BLOCKING

`:657` (`-notmatch '^\+\+\+'`) and `:668-669` (`if ($line -match '^---' -or $line -match
'^\+\+\+') { continue }`) intend to skip `--- a/path` / `+++ b/path` headers but test the diff
line, not its position, so a *removed* content line beginning with `--` and an *added* content
line beginning with `++` are dropped from the multisets and from the record search.

Failing input (`atk2/M_dashdash`): a `tasks.md` containing the line `-- a stray note line` is
committed, then a later commit deletes that line and nothing else. `$removed` ends up empty,
`$added` empty, `Test-CheckboxOnlyChange` returns `$true` at `:673`. Observed: **PASS** — a
content deletion graded as progress. Narrow (markdown rarely starts a line with `--`), but it is
the same predicate H2 lives in.

*Action: skip the file headers by position — drop lines until the first `@@` of each hunk, or
match `^\+\+\+ [ab]/` and `^--- [ab]/` rather than the bare prefix.*

### H10 — SC-006 is unmeasured by the implementer; measured here it doubles the pack — NON-BLOCKING

`notes.md` claims nothing about runtime, and T024 defers the measurement to phase 3. Measured on
this branch (10 commits in `base..HEAD`), two runs each: parent pack 989 / 971 ms, phase 2 pack
2 006 / 2 175 ms — **+1.0 to 1.2 s, +110 %**. Full `ritual-checks.ps1` is 9 711 ms, so the member
is ≈11 % of the ritual today.

The shape of the cost matters more than the number. Only **one** of those ten commits is
actually graded (D2b skips the nine whose parent predates the function), yet each of the ten
pays `git rev-list --parents` plus a `git show <parent>:scripts/enforcement-pack.ps1` that reads
and pipes the whole 39 KB pack blob (`:647-649`). Cost is therefore ≈110 ms per commit
*independent of whether anything is graded*, and linear in branch length: FitForge 002
(seventeen phases) will pay several seconds for commits the boundary discards.

*Action (phase 3, T024): hoist the boundary. The answer changes at exactly one commit, so
resolve it once — e.g. `git log --format=%H -S'function Invoke-AmendmentAuthorityCheck'
--diff-filter=A -- scripts/enforcement-pack.ps1` or a single probe on the base — and compare
each commit against that instead of re-reading the blob per commit. Record the result against
SC-006 either way; "a small, stated fraction" is not satisfied by a fraction nobody stated.*

### H11 — The D2b boundary fails open in silence — NON-BLOCKING

`:644-650` returns `$false` whenever `git show "${Ref}:scripts/enforcement-pack.ps1"` yields
nothing — an absent path, a reorganized project, a `-Root` pointed at a repository that vendors
the pack elsewhere, or a grafted parent in a shallow clone. `:719` then `continue`s, and nothing
is printed. A run that grades 0 of 40 commits is indistinguishable, in the output, from a clean
branch. The plan says the silence on update day is deliberate; being unable to tell "nothing to
report" from "the probe is broken" is not the same property.

Two related observations, neither a defect on its own: the probe's own pattern literal at `:649`
contains the string it searches for, so the test really answers "does the parent's pack *mention*
`function Invoke-AmendmentAuthorityCheck`" rather than "does it define it" (this is why my
`atk/L_disable` fixture — breaking the `function` line's whitespace in an earlier commit — did
**not** disable the check, which is the lucky direction); and the path is a hard-coded literal
rather than being derived from `$PSCommandPath`, which is safe here only because
`kit-manifest.json` classes `scripts/*.ps1` as `verbatim`, so every adopted project has the pack
at exactly that path.

*Action: emit one informational line when the boundary skips at least one commit, e.g.
`AmendmentAuthority: N commit(s) predate the check and were not graded (plan D2b)`. It is not a
failure and it makes an update day legible instead of merely quiet.*

### H12 — The shipped check cannot perform phase 3's own replay — NON-BLOCKING

T020/T021 and SC-002 require replaying the detector over this repository's merged history and
over FitForge 001's commits. Every one of those commits has a parent whose pack predates
`Invoke-AmendmentAuthorityCheck`, so `Test-AmendmentCheckPresent` returns `$false` and
`Invoke-AmendmentAuthorityCheck` grades **nothing** — demonstrated by the `N3` fixture, which is
exactly that shape. There is no `-Since`, `-All` or `-IgnoreBoundary` seam, and the boundary
test is not a parameter.

*Action: add an opt-in switch (e.g. `-GradeHistory`) used by the phase 3 harness only, or accept
that phase 3 will run a copied function and say so in `notes.md`. Flagging now because SC-002 is
this feature's strongest evidence and it currently has no way to be produced by the code that
ships.*

### H13 — `[datetime]::Parse` uses the runner's culture — NON-BLOCKING

`:741` parses with the ambient culture while `:697-700` (three lines above) correctly uses
`TryParseExact` with `InvariantCulture`. Verdicts are unaffected — `DateTime` comparison is
calendar-agnostic — but the message at `:705` renders `$CommitDate.ToString('yyyy-MM-dd')` in
the current calendar. Measured: under `ar-SA` the same instant prints `1448-04-02`, under
`th-TH` `2569-09-13`. A failure message quoting a Hijri date as "the commit's own author date"
is not the message FR-008 asks for.

*Action: subsumed by H6's fix (compare the `%ad`/`%aI` date string directly). If the parse is
kept, pass `[globalization.cultureinfo]::InvariantCulture` and format with it too.*

### H14 — The phase 2 gate-record commit reproduces F9/G4 for the third time — NON-BLOCKING

`a976f6d`'s subject is `docs: record the phase 2 gate — owner-approved on 14cf1d6`. It contains
the token `phase 2`, so `scripts/scope-check.ps1` now grades *it* rather than the phase commit.
Observed on the branch tip today:

```text
scope-check: PASS phase 2 commit a976f6d (1 file(s))
```

`notes.md` records `Scope check | PASS phase 2 commit 14cf1d6 (3 files)` — true when written,
not reproducible now. F9 recorded this rule ("a non-phase commit must never carry a `phase N`
token in its subject"), G4 recorded its first reproduction, and this is the second. Outside the
reviewed diff, and history should not be rewritten for it, but the recorded gate evidence should
say which commit the branch's scope-check grades today.

*Action: add one line to the phase 2 gate table in `notes.md` noting that `a976f6d` now carries
the token; for the remaining phases, keep phase tokens out of non-phase subjects (the durable
fix — a machine check for it — is a roadmap row, not this feature's work).*

### H15 — Plan D1 still asserts a fact `notes.md` records as false — NON-BLOCKING / CONFIRM

Both corrections in `notes.md` are **confirmed**:

1. D1's "This is the first pack member with per-commit granularity" is false —
   `Invoke-PhaseSizeWarningCheck` (`:606-611`) already does `git rev-list "$Base..HEAD"` and
   walks commits. The *decision* D1 records is untouched by this; only the novelty claim is
   wrong.
2. T012's anticipated helper was genuinely unnecessary — `scripts/scope-lib.ps1` contains
   `Get-CommitPaths`, `Get-VisibleLines`, `Test-IsMicro`, `Get-Territory`, `Test-InTerritory`
   and **no** base resolution at all (`Get-DiffBase` lives in `enforcement-pack.ps1:123`), so
   T012's premise ("resolve the base with the existing helper in `scripts/scope-lib.ps1`") was
   itself mistaken. `scope-lib.ps1` is untouched by the commit, as claimed.

Recording them in `notes.md` is the right call under D3b — they are findings, not agreed work,
and neither changes a decision. The residual is small and worth an owner decision: `plan.md` is
a source-of-truth rung (constitution II) and still states, in the present tense, something the
feature knows to be untrue, where a reader of `plan.md` alone will not see the correction. Under
this feature's own rule the fix is cheap — strike four words, carry an approver line.

*Action: owner decides. Either amend D1's sentence with its own `**Amendment approved by**` line,
or leave it and accept that the plan carries a known-false clause that only `notes.md` corrects.*

### H16 — Deliberate scope limits worth stating rather than discovering — NON-BLOCKING

Verified behaviours that follow from D8 and are correct as designed, but that no document states
plainly:

- A branch may amend **another** feature's approved documents freely: `atk2/R_otherfeature`
  rewrites `specs/000-neighbour/plan.md` with no record and PASSES, because `:724` only matches
  `specs/<this branch>/*`.
- `data-model.md`, `research.md` and `screenshots/` are never graded (`:731`) even though
  `CLAUDE.md`'s Feature Structure lists the first two as feature documents. This matches FR-002's
  enumeration; the divergence between the two lists is the kind of thing GAP-021 is a row about.
- A binary contract (`atk/K_binary`) cannot carry a record line at all, so the only way to record
  its amendment is a record in another file — which H4's fix would forbid unless the graded set
  is used rather than the amended file.
- A shallow clone yields `diff base ''` and the whole pack, not just this member, grades nothing
  (`:737`, `Get-DiffBase:123-133`). Pre-existing behaviour, no new risk: `.github/**` is
  `verbatim` and `ritual-checks.yml` pins `fetch-depth: 0`, and `project-gate.yml.template`
  runs the project gate, not the ritual.

*Action: none required for phase 2. Fold the first two bullets into phase 4's adoption text so an
adopter knows what the check does not look at.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None.** `14cf1d6` touches two files under `specs/014-amendment-authority/`:

- `tasks.md` — a single hunk (`@@ -185,32 +185,32 @@`) of ten `- [ ]` → `- [x]` flips for
  T010–T019. No text of any agreed task changed; exempt under constitution I's progress clause
  and under D3.
- `notes.md` — new evidence (phase 2 scenario table, the two corrections of fact, the S4 message
  limit). Not one of the graded documents (`spec.md`, `plan.md`, `tasks.md`, `contracts/`), by
  D3b's deliberate design.

The commit message carries `Amendment approved by: anas.m, 2026-09-13.` although the diff
contains no amendment; harmless, but a reviewer looking for the amended text will not find any.
No change was made to `spec.md`, `plan.md` or `contracts/` in this phase, so the standard this
phase is graded against is the one that was approved before it started.

## Constitution re-check (post-implementation)

**PASS with the findings above outstanding.**

- **I Specification First** — spec, plan and tasks predate the phase; the phase implements
  T010–T019 and nothing else. The feature is now graded by its own rule from `14cf1d6`'s child
  onward, and the first such commit (`a976f6d`) is clean. PASS.
- **II Source of Truth** — no ladder change. One nuance: `plan.md` retains a sentence the
  implementer knows to be false and corrected only in `notes.md` (H15), which is a rung
  disagreeing with a non-rung.
- **III / V** — N/A (single repo; no invariant pack).
- **IV Architecture Consistency** — a new function in an existing script, no new file, no
  package, base resolution reused. PASS. The one architectural drift is H1: the pack has a
  ratified "visible text only" convention that this member does not follow.
- **VI Security** — read-only, no secrets, no untrusted interpolation. PASS.
- **VII External Integration** — N/A.
- **VIII Testing Requirements** — the fixture suite exists, is scripted and rebuildable, and all
  18 verdicts reproduce. But the constitution calls this business-critical because "a wrong PASS
  leaves the rule exactly as unenforced as it is today": seven demonstrated false-PASS shapes say
  the suite is not yet adversarial enough. The fixtures were designed by the same session that
  designed the predicates, which is the weakest possible audience — T023 already says so about
  the messages; it applies to the verdicts too. **Engaged, not yet satisfied.**
- **IX Human Review** — this review is gate 5 for phase 2; gate 6 at merge. PASS.
- **X Controlled Delivery** — one phase, `ci-held` declared before any phase, evidence triplet
  recorded in `notes.md`, agent claimed no gate. PASS (see H14 on the scope-check row).

## Test coverage observed

No test framework (kit convention since 006). Two layers exist today:

- **Seeded fixtures** — `scratchpad/seed.ps1`, 18 throwaway repositories, each with the check
  present on `main` so that D2b actually grades the commits under test. Re-run here: 18/18 match
  the table in `notes.md`, including the two scenarios added during the phase (S9b un-ticking,
  N3 the D2b boundary), which are the two that carry the most weight.
- **Regression** — the implementer's byte-identical claim is real. My independent reproduction
  (parent blob extracted with `git show 370a28b:scripts/enforcement-pack.ps1`, both packs run
  over this repository and 19 fixtures, `AmendmentAuthority` lines filtered) found no message
  text difference anywhere; the only deltas are the summary line where the new member
  legitimately fires.

What is missing is negative coverage of the classifier: there is no fixture in which a record is
present but should not count (comment, moved line, wrong file), none in which a `tasks.md` change
is a move rather than a flip, none for `R<100`, and none for a timezone other than the author's.
Seven of my 22 adversarial fixtures are in those four gaps and all seven give the wrong verdict.

## Residual risk

The risk is concentrated in five predicates, not in the architecture: what counts as a record
(H1, H4, H5), what counts as progress (H2, H9), what counts as a creation (H3), what counts as
"later than the commit" (H6, H13), and what counts as the approver being named (H7). All five are
local, and each fix is a few lines with a fixture to hold it.

Two consequences deserve the owner's attention before merge. First, the dangerous direction
dominates: seven of the eight wrong verdicts are false PASSes, and H1 plus H2 together mean a
determined or merely careless amendment can be made invisible with no unusual effort — a
commented-out record, or a Territory line dragged one section upward. A check that greens those
is, for exactly those shapes, worse than no check, because it converts "nobody is grading this"
into "the machine says it is fine". Second, H6 is the credibility risk in the other direction:
it will fire on the owner's own conforming amendments whenever CI's timezone trails the author's,
and a governance check that is green locally and red in CI for no visible reason is the kind of
check people learn to route around — GAP-020's lesson, which this feature's own spec cites.

Before merge: fix H1–H6, and extend the S-table with a fixture per fix so the next reviewer
grades a suite that includes cases its author did not want to pass. Phase 3's T020–T025 should
then run against the corrected classifier — and note H12: as shipped, the D2b boundary means
that replay grades nothing at all until a seam exists.
