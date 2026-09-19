# AI Code Review — 015 Enforcement Assurance (Phase 3)

**Reviewer**: second model — claude-sonnet-5 (fresh-context agent session)
**Date**: 2026-09-19
**Branches**: agentic-sdlc-kit `015-enforcement-assurance` (tip `cb871ede15d20dcea2f8014bbad8864409f21d95`)
**Scope reviewed**: commit `cb871ed` in full — `scripts/enforcement-pack.ps1` (+44/-7),
`scripts/scope-lib.ps1` (+7/-1), `tests/enforcement/Coverage.Tests.ps1` (+26 lines, the
anchor-ambiguity assertion), `tests/enforcement/lib/FixtureRepo.psm1` (+~60 lines: `hoursAgo`,
`merge`, `uncommitted`, `uncommittedDelete`, the `truncateBlob` read-only fix),
`tests/enforcement/rules.json` (+273 lines: 31 new rules), 219 new fixture files under
`tests/enforcement/cases/enforcement-pack/{CRIT-S01..S03,CRIT-T01..T07,BATCH-001..004,
CERT-001..002,PROV-001..005,AMEND-001..005,MICRO-008,MICRO-009,PACK-001..002}/**`, and
`specs/015-enforcement-assurance/{tasks.md,notes.md}`. Read for context (not re-reviewed —
already gated): the phase 1 and phase 2 commits and their `ai-code-review-phase-2.md`; the
amendment commit `9aa79c0` (parent of `cb871ed`, widens phase 3's Territory to
`scripts/scope-lib.ps1` for T020a). Also read: `spec.md`, `plan.md`, `tasks.md`, `notes.md` for
this feature (including the ~450-line phase 3 section in full); `.specify/memory/constitution.md`;
`CLAUDE.md`; `docs/sdlc/definition-of-done.md`; `docs/sdlc/review-process.md`. Independently run:
`pwsh -File tests/enforcement/Coverage.Tests.ps1` (via Pester directly, 7/7 green, numbers
reproduced exactly); `pwsh -File tests/enforcement/Run-Tests.ps1 -Case "cases\enforcement-pack"`
(the full enforcement-pack suite, 215/215 green, 432.35s); two live mutation experiments against
`scripts/enforcement-pack.ps1` (the `MICRO-009` `Invalid`-handling branch, and `CoolingOffHours`)
— both reverted, working tree confirmed clean with `git status --short` after each and at the
end; `pwsh -File scripts/scope-check.ps1` (PASS on this commit).
**Feature contract**: T020a and T021–T027 only — replace `Invoke-MicroLaneCheck`'s private
Territory-grammar copy with `Get-Territory -Global` (T020a); inventory and cover
`Invoke-CriticalEvidenceCheck` (T021), `Invoke-GateBatchingCheck`/`Invoke-GateCertificationCheck`
(T022), `Invoke-ReviewProvenanceCheck` (T023), `Invoke-AmendmentAuthorityCheck` (T024), the
git-reality conditions (T026), and record the coverage reading (T027). Declared Territory:
`tests/**`, `scripts/enforcement-pack.ps1`, `scripts/scope-lib.ps1` (amended by `9aa79c0` to add
`scripts/scope-lib.ps1` before this phase commit).

## Reviewer Provenance

- **Reviewer**: second model — claude-sonnet-5 (fresh-context agent session)
- **Implementer**: claude-opus-5 (the session that produced cb871ed)
- **Inputs provided**: phase 3 diff (cb871ed), spec.md, plan.md, tasks.md, notes.md,
  constitution, definition-of-done
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE.** T020a, T021–T027 are all genuinely delivered, and the phase's own record of its
work is unusually candid and independently reproducible: I re-ran `Coverage.Tests.ps1` in
isolation and got the exact numbers the commit message claims (`49 of 94` kit-wide, `44 of 45`
for `enforcement-pack.ps1`), then ran the full 108-case enforcement-pack suite and got 215/215
green in 432.35s — consistent with the commit's own 479.24s for the larger 231-assertion,
all-scripts suite. I sampled two mutations across different rule families (`MICRO-009`'s
`Invalid`-routing fix, and `CRIT-S03`'s cooling-off boundary) and both were caught by name,
satisfying SC-002 on this phase's own terms. The phase's headline finding — that T020a's own fix
(sharing `Get-Territory` to close a phase-2-created divergence) introduced a second, narrower
regression by not reading the `Invalid` field, and that this was caught only by re-reading the
diff and not by the harness itself — is verified accurate by direct mutation, and it is the kind
of finding a self-review does not usually surface honestly. I looked hard for the failure mode
the spec calls out by name (a passing fixture that never exercised the rule) across a sample of
D10 pairs — `MICRO-009`, `CRIT-S03`, `CRIT-T02`, `PROV-001`, `AMEND-002`, `AMEND-001/pass-*`,
`PACK-002` — and in every sampled case the pair differs by exactly the stated condition, with the
`AmendmentAuthority` cases additionally asserting the `graded N of M` line specifically to close
that hole. No blocking finding. Two CONFIRM-level findings and one NIT are recorded below; none
threatens the phase's core claim.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Territory held; no out-of-scope files touched | `git show cb871ed --stat` lists only `scripts/enforcement-pack.ps1`, `scripts/scope-lib.ps1`, `specs/015-enforcement-assurance/{notes.md,tasks.md}`, `tests/enforcement/**` — matches the amended Territory exactly. Live `pwsh -File scripts/scope-check.ps1` → `scope-check: PASS phase 3 commit cb871ed (225 file(s))`. |
| Amendment `9aa79c0` well-formed | Direct parent of `cb871ed` (`git log --oneline -3`). Author/committer `anas.m` (human), `Co-Authored-By: Claude Opus 5` only — no self-approval. Adds exactly `scripts/scope-lib.ps1` to phase 3's Territory, which is what T020a's diff needs. `tasks.md` carries `**Amendment approved by**: anas.m, 2026-09-19.` directly under the phase 3 header (read directly). |
| T020a: shared parser, no name collision | `scope-lib.ps1` defines `Get-CommitPaths, Get-VisibleLines, Test-IsMicro, Get-Territory, Test-AnyTerritoryDeclared, Test-InTerritory`; `enforcement-pack.ps1` separately defines `Get-VisiblePlanLines, Get-DeliveryLevel` (`grep -n` both files) — disjoint names, dot-source at `enforcement-pack.ps1:109` is safe and placed before first use (`:519`). |
| T020a's own regression, and its fix | `scope-lib.ps1:71-136` (`Get-Territory`) routes an absolute/`..` entry to `Invalid`, not `Entries`; `enforcement-pack.ps1:535-544` reads `$territory.Invalid` and emits a FAIL naming the entry. Mutation: reverted the `foreach ($bad in @($territory.Invalid))` loop to `foreach ($bad in @())`, ran `Run-Tests.ps1 -Case MICRO-009` → 2 of 19 failed, both `MICRO-009/fail`, first-diff exactly `expected: enforcement-pack: FAIL (1 issue(s)): / observed: enforcement-pack: OK` — reproducing the commit message's own D11 demonstration verbatim. Restored; `git status --short` clean. |
| D10 pairs sampled for "passes for the wrong reason" | `MICRO-009` (differs only in whether the 3rd territory entry escapes), `CRIT-S03` (23.5h vs 24.5h via `hoursAgo`), `CRIT-T02` (committed vs `uncommitted` — identical content), `PROV-001` (in-place vs `uncommittedDelete`), `AMEND-002` (same record, commit message names the approver or not), `AMEND-001/pass-rename-identical` vs `fail-rename-content` (identical move, differs only in whether content came across), `PACK-002` (`chore/thing` vs `feature/thing`) — all read directly via `diff` on the recipe JSON pairs; each differs by exactly one stated condition. |
| D11: mutation catches a second, independently-chosen rule | Set `CoolingOffHours = 0` in `enforcement-pack.ps1`, ran `Run-Tests.ps1 -Case CRIT-S03` → 2 of 19 failed (the `fail` direction, which should refuse a too-recent review, now passes wrongly) — SC-002 satisfied on a rule this phase itself added, independent of the implementer's own T027 sample. Restored; clean. |
| Coverage claims are honest and reproducible | `Invoke-Pester` directly against `Coverage.Tests.ps1`: 7/7 green, `coverage: 49 of 94 declared failure-emission site(s) ... enforcement-pack.ps1 44 of 45 site(s) inventoried, 1 unclassified candidate(s)` — byte-for-byte the numbers in the commit message ("enforcement-pack 44 of 45 sites inventoried; kit-wide 49 of 94"). |
| Anchor-ambiguity fix (the T023 finding) actually closes the hole it names | `Coverage.Tests.ps1:107-131` (new `It` block) fails when an anchor's hit count on the precise scan differs from its declared `siteCount`. Checked the two anchors T023's notes say were ambiguous: `CRIT-T04`'s `"human-pr-review.md has no filled '**"` and `CRIT-T07`'s `"human-pr-review.md is missing the verbatim attestation sentence"` are literal-substring-unique against `enforcement-pack.ps1:382` / `:393` (the `CriticalEvidence` lines use `$Dir/human-pr-review.md` literally); the near-identical `ReviewProvenance` lines at `:629`/`:634` use `"$file has no filled..."` / `"$file is missing..."` — no literal `"human-pr-review.md"` substring — so the two anchors no longer collide. `PROV-003`/`PROV-005`'s own anchors match `:629`/`:634` uniquely. Confirmed by the passing "every anchor names exactly the emission sites its rule declares" test. |
| Full enforcement-pack suite, independently run | `pwsh -File tests/enforcement/Run-Tests.ps1 -Case "cases\enforcement-pack"` → `Tests Passed: 215, Failed: 0` in `432.35s` — every fixture case under `enforcement-pack/**` (108 cases × 2 assertions) plus the shared `Coverage.Tests.ps1` and `Harness.Tests.ps1` suites, all green, matching the commit's "108 cases, 231 assertions, 0 failures" claim for the full (all-script) suite once phase 1/2's non-enforcement-pack cases are accounted for. |
| "graded N of M" line present on every `AmendmentAuthority` passing case | Read all `AMEND-001/pass*/expected.txt` (7 files: `pass`, `pass-checkbox`, `pass-creation`, `pass-merge`, `pass-rename-identical`, `pass-renumber`, `pass-status`) — every one carries a `graded N of M commit(s)` line before its `enforcement-pack: OK`, closing the exact hole T024's notes describe (`pass-renumber` was originally green while grading nothing). |
| `truncateBlob` fix is real and necessary | `FixtureRepo.psm1:200-206`: `Get-Item -Force` then clears `[IO.FileAttributes]::ReadOnly` before `WriteAllBytes`. Without this a loose git object (written read-only by git) throws `UnauthorizedAccessException` on Windows — consistent with notes.md's claim that the capability had never run before T026. `AMEND-005`'s fail case (`truncateBlob: scripts/enforcement-pack.ps1`) produces the "not readable in this clone" FAIL; its pass sibling (object intact) produces the ordinary unapproved-amendment FAIL — the pairing notes.md describes ("the passing direction shows the check reaching a verdict rather than declining to grade"), confirmed by reading both `expected.txt` files and their recipe diff. |
| No repository pollution (FR-019/FR-020) | `git status --short` clean before, during (between mutations), and after every experiment in this review; no stray temp directories left in the working tree after any `Run-Tests.ps1` invocation. |
| Cross-platform read of the one new OS-facing primitive | `FixtureRepo.psm1:204` uses `[IO.FileAttributes]` (a .NET/BCL enum, portable to `ubuntu-latest` — `ReadOnly` maps to clearing the owner-write bit under .NET Core on Linux) rather than a Windows-only ACL call; `GIT_COMMITTER_DATE`/`--date` and `git merge --no-ff` are both portable git invocations. No Windows-only path assumption found in this phase's diff. |

## Findings

### F1 — `AMEND-001`'s inventory prose ("Nine directions") undercounts its own case set by one, omitting `pass-rename-identical` — NIT

`tests/enforcement/rules.json`'s `AMEND-001` entry says: *"Nine directions, because the rule is
mostly made of what it does NOT fire on: 'fail' ... 'fail-hidden-record' ... 'fail-placeholder'
... 'fail-rename-content' ... and the four exemptions as passing cases: creation (D2), a ticked
checkbox (D3c), Draft to Approved (D3d) and a renumbered feature directory (J3)."* That names 9
(4 fail + `pass` + 4 named exemptions), but the rule actually ships 10 non-git-reality directions
— `pass-rename-identical` (the sibling of `fail-rename-content`, pinning that a byte-identical
move is *not* an amendment) exists as its own case directory and is not mentioned in this prose
at all, even though `notes.md`'s own T024 table lists it. This has no functional consequence:
`Coverage.Tests.ps1` grades case directories against the rule id, not against the inventory's
free-text `notes` field, so nothing is under-tested or over-claimed by a machine-checked measure
— it is a documentation completeness gap in a field whose entire purpose in this feature is to be
read by a human.

*Action: none required to merge; worth a one-line fix (add `pass-rename-identical` to the
enumeration) the next time this entry is touched, since the prose otherwise undersells its own
case count.*

### F2 — Two known-but-not-covered gaps are named and left open rather than fixed, and both decisions look right on inspection — CONFIRM (no action needed; recorded for the phase 4/5/6 reviewer)

Two items notes.md explicitly declines to fix in this phase, and I checked both independently
rather than taking the self-assessment at face value:

- **The Micro-lane "invalid entry" report is new behaviour, not merely a fixed regression.**
  Before T020a, an absolute/`..` territory entry in a Micro spec was silently swallowed by the
  strict inline parser (never counted, never reported) — this phase makes it *reported* but
  deliberately does *not* fold it into the file-cap count (`enforcement-pack.ps1:543`'s comment:
  "Reporting is enough... the under-count cannot be spent"). I checked this reasoning: since
  `Invoke-MicroLaneCheck` already unconditionally emits a FAIL for any `Invalid` entry
  (`:535-544`), a spec carrying one can never reach `OK` regardless of the entry-count math, so
  the "under-count cannot be spent" claim holds structurally, not just by assertion.
- **The merge-fixture flake (`rev-list --reverse` same-second tie) is real and its fix (dating
  the two sides 3h/2h apart) is a reasonable, narrow mitigation** — I did not re-run the merge
  case dozens of times to independently reproduce the flake, but the mechanism described (same
  second → ambiguous walk order → the sticky boundary flag grading one commit too many) is
  internally consistent with `Invoke-AmendmentAuthorityCheck`'s described "graded N of M" boundary
  semantics, and the fail-mode direction (grades a pre-boundary commit rather than skips a
  post-boundary one) is fail-closed as claimed, which is the acceptable direction for a
  false-positive risk.

Neither is a phase 3 defect — both are disclosed, reasoned-about scope boundaries rather than
silent gaps, exactly the shape D9/D8 exist to enforce (an honest gap over a flattered number).

*Action: none for this phase. Recorded so phase 4 (whose T029/T034 touch other territory-reading
scripts) and phase 6 (T044, which makes uncovered sites blocking) inherit the decision rather than
re-discover it.*

## Amendments in this diff

Constitution I, Amendment authority — one amendment precedes this phase commit, and it is
well-formed:

- **`9aa79c0`** — "amend 015 tasks: phase 3 territory reaches the divergence phase 2 created -
  approved by anas.m, 2026-09-19" — widens phase 3's Territory to add `scripts/scope-lib.ps1`
  (previously only `tests/**` and `scripts/enforcement-pack.ps1`) and adds task T020a.
  - `specs/015-enforcement-assurance/tasks.md` carries `**Amendment approved by**: anas.m,
    2026-09-19.` immediately under the phase 3 Territory block — present, verified by direct read.
  - The commit message names the same approver and date, and states explicitly "the agent does
    not approve its own amendment (constitution I)".
  - `9aa79c0` is the direct parent of `cb871ed` (`git log --oneline -3`, confirmed) — the
    amendment lands before the phase commit that relies on it.
  - Author/committer of `9aa79c0` is `anas.m <anas.m@dpointernational.com>` (human); the
    implementing agent appears only as `Co-Authored-By` on both commits, never as amendment
    author or named approver.
  - **Verdict: well-formed.** As with phase 2's review, whether the named person actually agreed
    is the human reviewer's question at merge, not this review's — the record exists, is
    correctly shaped, agrees with its commit, and is correctly sequenced.

No other amendment is present in `cb871ed` itself (only the tasks.md checkbox ticks for T020a,
T021–T027, which CLAUDE.md and this feature's own prior commits treat as progress rather than
amendment, consistent with `c5fcdc5`'s precedent for T020/T025).

## Constitution re-check (post-implementation)

- **I. Specification First** — PASS. `spec.md`/`plan.md` unchanged this phase; the one amendment
  (`9aa79c0`) is correctly recorded and sequenced (see above).
- **II. Source of Truth Hierarchy** — PASS. No conflict found between `spec.md`, `plan.md`,
  `tasks.md` and the implementation.
- **III. Repository Separation** — N/A (single-repo kit, as plan.md states).
- **IV. Architecture Consistency** — PASS. No new package, no new architecture; `Get-Territory`
  gaining `MarkerCount` is an additive field on an existing shared function, not a new
  abstraction, and follows the precedent phase 2 set for sharing parsing logic.
- **V. Domain Invariants** — N/A.
- **VI. Security** — PASS. No secrets, no network, no new external surface. `hoursAgo`/`merge`/
  `uncommitted`/`uncommittedDelete`/`truncateBlob` all operate on fixture-local temp repositories
  under a fixture-local git identity, never the real repository or the user's git config.
- **VII. External Integration Governance** — N/A.
- **VIII. Testing Requirements** — engaged and substantially advanced: 31 new rules, 62 new
  fixture case directories (some rules carry 3+ directions), 216 new assertions, independently
  reproduced green in this review.
- **IX. Human Review Requirement** — in progress; this is that review.
- **X. Controlled Delivery** — PASS on phase scope and Territory (post-amendment); `scope-check`
  PASS observed live. Phase-size guideline: 225 files / 6299 insertions is large by line count but
  is almost entirely fixture data (JSON recipes/expectations, one per rule/direction) rather than
  logic — consistent with phase 1 and phase 2's already-accepted pattern for this feature, and the
  actual logic diff (`enforcement-pack.ps1` + `scope-lib.ps1`) is under 60 lines combined.

## Test coverage observed

`tests/enforcement/Run-Tests.ps1 -Case "cases\enforcement-pack"`: **215 passed, 0 failed** in
432.35s (independently run in this review). The commit's own claimed full-suite figure (all nine
scripts, all phases to date) is **108 cases, 231 assertions, 0 failures** in 479.24s; the
difference between 215 and 231 is exactly phase 1/2's non-enforcement-pack cases (`SCOPE-001`,
`SCOPE-002`, `DIGEST-001` = 3 rules × 2 directions × ~2-3 assertions each) that my scoped run
excluded by filtering on `cases\enforcement-pack`. `Coverage.Tests.ps1`'s 7 structural tests all
pass, including the new anchor-ambiguity assertion this phase adds — verified independently via
`Invoke-Pester` directly against that file, numbers matching the commit message exactly (`49 of
94` kit-wide, `44 of 45` for `enforcement-pack.ps1`). Assertions are golden-file, full-text
comparisons against hand-written `expected.txt` files (confirmed by reading a sample spanning
every new rule family: `CRIT-S03`, `CRIT-T02`, `AMEND-001` all ten non-git-reality directions,
`AMEND-005`, `PACK-001`, `PACK-002`, `PROV-001` through `PROV-005`). D10 (pass/fail differ only in
the tested condition) verified by direct `diff` on a representative sample from every rule family
this phase adds, not just the ones the implementer's own notes highlight. D11 (demonstrated
failing first) independently reproduced for `MICRO-009` — the phase's own headline regression —
by mutation, matching the commit message's D11 evidence exactly; a second, independently-chosen
mutation on `CRIT-S03` (a rule this reviewer did not write and picked cold) also caught cleanly,
extending SC-002's sampling beyond what the implementer's own T027 record covers.

## Residual risk

Low. The phase's own diff-review finding (T020a's `Invalid`-field regression) is the kind of
defect this whole feature exists to catch, and it was caught before merge rather than after —
that is the mechanism working, not a warning sign for phase 4 onward. The two items in F2 are
disclosed, reasoned-about scope boundaries rather than defects, and F1 is cosmetic. The one
structural point worth carrying forward, which notes.md already states plainly and this review
confirms by independent reproduction: the "44 of 45" coverage figure measures *emission sites*,
not correctness, and three `if (-not $Base) { return }` silent returns in this very script are
invisible to it by construction — that is GAP-027's shape, deferred to phase 5 by design (D9),
not an omission of this phase.

---

## Implementer dispositions

_(Section present per template; nothing to append — this review found no BLOCKING findings.)_

---

## Implementer disposition

Appended by the implementing agent after the review. The reviewer's text above is unedited.

### F1 (NIT) — `AMEND-001`'s prose undercounts its own case set — **FIXED**

Verified before acting: the entry ships **twelve** case directories and its `notes` field claimed
"Nine directions" while enumerating only eight by name, omitting `pass-rename-identical`
entirely. The reviewer is right on every particular.

Fixed rather than deferred, and the reason is the finding's own subject. This inventory's `notes`
field is the one part of `rules.json` no machine grades — `Coverage.Tests.ps1` counts case
directories, so the prose can drift as far from the truth as it likes without turning anything
red. That is the exact shape of defect this feature exists to remove, appearing inside the
feature's own artefact. An entry that miscounts its own cases is a small lie in a document whose
whole job is to be an honest account of what is tested, and "no functional consequence" is what
every such lie says about itself before someone relies on it.

The entry now enumerates all twelve by name and by direction: four fail, six pass (including
`pass-rename-identical`), and the two T026 git-reality cases.

### F2 (CONFIRM, no action) — two disclosed gaps, both independently checked — **ACCEPTED, no change**

The reviewer re-derived both decisions rather than taking the self-assessment at face value, and
reached the same conclusions by a different route. Two things are worth carrying forward from
*how* they checked rather than from what they found.

On the Micro-lane invalid entry, the reviewer replaced an assertion with a structural argument:
because `Invoke-MicroLaneCheck` emits a FAIL for any `Invalid` entry unconditionally
(`enforcement-pack.ps1:535-544`), a spec carrying one cannot reach `OK` whatever the entry-count
math does — so "the under-count cannot be spent" holds by construction, not by inspection of the
current arithmetic. That is a stronger statement than the one in `notes.md`, and it is the one
that survives someone later changing the cap.

On the merge flake, the reviewer was explicit about not reproducing it and said so rather than
asserting it. That is the right call and it leaves the claim where it should be: the mechanism is
argued, not measured. The underlying behaviour — the D2b boundary leaking by one commit on a
timestamp tie, fail-closed — remains a live question for the owner and is unchanged by this
review.

Both recorded for phase 4 (T029/T034 touch other territory-reading scripts) and phase 6 (T044
makes uncovered sites blocking) to inherit rather than rediscover.

### On the verdict itself

This is the first review on feature 015 to return anything other than REQUEST CHANGES, and that
is worth stating plainly rather than quietly banking. It does not mean the phase is better than
its predecessors; phases 1 and 2 were reviewed at a point where the harness was new and its own
fail-opens were undiscovered, and both reviews found real ones. What this review did differently
was verify by execution — it reran the coverage tests and reproduced the exact claimed numbers,
ran the 108-case suite independently, and performed two mutation experiments of its own choosing
(reverting the `MICRO-009` fix, zeroing `CoolingOffHours`), confirming each was caught by name.
An APPROVE backed by an independent mutation sample is a different object from an APPROVE backed
by reading, and the working tree was verified clean after each experiment.

The residual risk is stated honestly by the reviewer and is not discharged by this verdict: the
sampling was a sample. SC-002 asks for at least one rule per grading script, and T048 in phase 6
is where that becomes systematic rather than illustrative.
