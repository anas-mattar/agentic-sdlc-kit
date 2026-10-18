# AI Code Review — 037 Reviewer choice and pull-time fit, phase 2 (the check reads the claim)

**Reviewer**: fresh-context agent, Claude Sonnet 5.5 (claude-sonnet-5-5)
**Date**: 2026-10-18
**Branches**: kit repo `037-reviewer-choice-and-fit` (tip `1682ca2`, parent `4fede57`)
**Scope reviewed**: `git show 1682ca2` (stat and full diff of `scripts/enforcement-pack.ps1`); the helpers `ConvertTo-ReviewSlug`, `Get-RosterBySlug`, `Get-ReviewClaims` in `scripts/adoption-lib.ps1`; `Invoke-CriticalEvidenceCheck` and `Invoke-CriticalTeamEvidence` as they stand; the 16 rewritten team-arm recipes (old and new parsed and compared key by key); all 16 new fixtures under `CRIT-R05` to `CRIT-R09` (recipe, command, expected); the `CRIT-R05` to `CRIT-R09` entries of `tests/enforcement/rules.json`; spec FRs, plan P3/P4/P5/P9, tasks Phase 2, `notes.md` phase 2 section, `ai-code-review-phase1.md`. Not read: the other 5 pack members, the rest of the harness, `claim-review.ps1` (phase 1).
**Feature contract**: the solo arm and a project with no roster print and fail exactly as before; no coordinator; every read of git that can fail has a named state (never an empty list); the claim check grades only after the 021 reviewer conditions hold; only `scripts/enforcement-pack.ps1`, `tests/**` and the feature's own specs directory change.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: Claude Sonnet 5.5, the session that produced commit 1682ca2 (Owner: anas.m)
- **Inputs provided**: commit 1682ca2 diff, spec.md, plan.md, tasks.md, data-model.md, ai-code-review-phase1.md, tests/enforcement/README.md, notes.md (read as a claim, not as evidence)
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The change adds `Invoke-ReviewClaimCheck`, called at the end of `Invoke-CriticalTeamEvidence` only when the Reviewer is on the roster, permitted, the Owner is named, and `$reviewer -ine $owner`; it also adds a clause to the existing missing-review failure. It grades the P4 table in the right order. Every git read goes through `Get-ReviewClaims`, which returns `Failed`/`Cause`, and both callers read `.Failed` before `.Claims`; a failed read is never treated as "no claims" and never as success. The 16 rewritten recipes are, on a parsed comparison, the old recipe plus `origin: "self"`, one appended claim commit and one appended description sentence. No `expected.txt` outside the new cases changed. The new case set ran green: `-Case enforcement-pack/CRIT-R0` selected 83 cases, harness 261 passed, 0 failed. The risk sits in the Owner comparison, which is only as strong as the free-text Owner string and ASCII slugging. A non-ASCII Owner disables it silently (F1). None of the findings blocks the phase; F1 is the one to fix before relying on the check.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FR-001 to FR-006a, SC-002, SC-004) | FR-001/002/004: `Invoke-ReviewClaimCheck` (`enforcement-pack.ps1` ~L808-847) emits no-claim, Owner-slug and Owner-author failures and UNGRADED lines. The no-claim message names feature, Reviewer and `claim-review.ps1`. FR-005: the call is guarded by `$entry -and $entry.CanApproveCritical -and $owner -and $owner -notmatch $placeholder -and $reviewer -ine $owner`; `$entry` is now initialised to `$null` outside the `if`. FR-006: nothing selects a reviewer. FR-006a: the missing-review clause is appended only when `Get-ReviewClaims` did not fail and returned zero claims; observed in `CRIT-R08/fail`. SC-004: all four unreadable readings print `UNGRADED` and exit 0 (CRIT-R09, 5 cases). |
| P4 table order and states | Read the code against the table. Order is: ambiguous or empty slug, read failure, no claim by the Reviewer, claim slug equals Owner slug, author is the Owner. The "no claim" line carries the Owner-claim hint only when the Owner holds a claim. Observed in `CRIT-R05/fail-owner-claim-only`. |
| Every git read | `Get-ReviewClaims`: `remote get-url` exit checked, `ls-remote` exit captured immediately into `$exit` and checked, `git log` exit checked, the fetch fallback re-runs `log` and checks again. `$LASTEXITCODE` is read right after the native call in each case, never after a pipeline that overwrites it. One-element unrolling is handled: `@(git ...)`, `@($read.Claims | Where-Object ...)`, `@($alike)`. UNGRADED is reachable: R09 no-origin, ledger-unreadable (origin path absent, git exit 128), author-unreadable (`originFailCall: 2` against a separate origin.git, so the commit is absent locally and the fetch fails), ambiguous roster. Each observed passing with the expected line. |
| PowerShell pitfalls | Ran `Get-RosterBySlug` by hand: an absent slug indexes to `$null` without error (`@($null).Count` is 1, so `-gt 1` is false, harmless); an empty slug indexes without error; a numeric-looking name `123` stays a string key; one hashtable roster entry gives count 1. Comparisons: slug against ref uses `-ceq` (both sides are already lower-case); Owner slug likewise. `$matches` use inside the lib is inside the same function scope. |
| Owner/author comparison routes | Case differences (slug lower-cases both sides), whitespace (trimmed), second claim (`$mine` can hold one ref per exact slug; `$mine[0]` is that one), claim slug equal to Owner's (R06), email-only match (R07 fail-email), Reviewer duplicated on roster with an identical slug (UNGRADED, see F3). Routes that do get through are F1, F2 and F4. |
| Solo arm and no roster | `Invoke-CriticalTeamEvidence` is reached only when `$mode.Mode -eq 'team'`; the solo function is untouched; `Get-ReviewClaims` is not called outside the team function. Existing solo and one-developer cases passed in the 83-case run. |
| The 16 rewritten recipes | Parsed old (`1682ca2~1`) and new JSON per file with `ConvertFrom-Json -AsHashtable`, compared every top-level key and every commit element. Result for all 16: only `origin` added, `description` extended by one sentence (old text is a strict prefix), `commits` gained exactly one trailing element `review/001-thing/grace` (or `GRACE` for `CRIT-T08/pass-case-differs`), with all earlier commits identical. `git diff --stat -- '*expected.txt'` shows none outside CRIT-R05 to R09. The raw diff is large only because the JSON was re-serialised with different whitespace and line endings. |
| New fixtures: wrong-reason risk | Compared parsed recipes of each pair. R05 pass/fail differ by the claim commit alone. R07 pass/fail differ by the author alone. R09 pass vs fail-author-unreadable differ in the origin setup. A pass that would also pass if the check returned early: R05 pass, R06 pass and R07 pass have discriminating fails beside them, so they do not hold a dead check up. R08/pass and R09/pass are controls that equal the parent's output (see F5). |
| Territory | `git diff --name-only 1682ca2~1 1682ca2` shows only `scripts/enforcement-pack.ps1`, `tests/**`, and `specs/037-.../notes.md` and `tasks.md` (five checkboxes ticked, no text change). Nothing outside. |
| Constitution / invariants | No new package, file format or architecture. |
| Security | No secrets. The only new side effect is a `git fetch` of one claim ref on the author-read fallback (F6). |
| Scope guard | Not run by this reviewer; the diff stat was read for intent. |
| Rollback safety | Pure code and fixtures; reverting restores the 021 behaviour. The 16 recipes revert with it. |

## Findings

### F1 — An Owner whose name slugs to empty (any non-ASCII name) silently disables every Owner test — CONFIRM

`enforcement-pack.ps1`, `Invoke-ReviewClaimCheck`: `$ownerSlug = ConvertTo-ReviewSlug $Owner`, and the Owner-slug test and the author test are both guarded by `$ownerSlug -and ...`. `ConvertTo-ReviewSlug` replaces every character outside `[a-z0-9._-]` with `-` and then trims, so an Owner written with no ASCII letters or digits slugs to `''`. I ran it: a CJK name gives `''`, and `José` gives `jos`. With an empty `$ownerSlug` the check ends with no failure and no UNGRADED line: a claim authored by that Owner passes, silently. A Reviewer whose own name slugs to empty is correctly UNGRADED ("has no character a ref can hold"); the Owner has no such state. The same gap applies to an Owner written as a full name while the roster and git identity use another form: `Ada Lovelace` slugs to `ada-lovelace`, which never equals the roster name `ada` or an author named `ada`. The plan P9 accepts that the author test is weak; it does not accept a case where the check cannot run and says nothing.
*Action: implementer, in a follow-up inside phase 2 territory: when the Owner is named, not a placeholder, and slugs to empty, add an UNGRADED line ("the Owner '<x>' has no character a ref can hold, so the claim could not be compared with the Owner") rather than skipping; add one fixture (failing on the parent). Owner decision on whether to widen the Owner match to the roster entry (alias) is for phase 4 guidance; not blocking.*

### F2 — The author test misses the usual `first.last@` email form — MINOR

`enforcement-pack.ps1`, last block of `Invoke-ReviewClaimCheck`: the email local part is slugged, which keeps dots, and compared with the Owner's slug, in which spaces became `-`. An Owner `Ada Lovelace` (`ada-lovelace`) pushing under a git name that is not hers but an email `ada.lovelace@corp` gives `ada.lovelace` and is not caught. When the author name is hers (`Ada Lovelace`) it is caught. This is the case the check says it catches ("name or email local-part, slugged"). Probable but low impact since the name usually matches.
*Action: none required for phase 2; consider comparing with `.`, `_` and `-` folded together (and say so in phase 4 guidance). Do not widen without a fixture for the false-positive side.*

### F3 — A roster slug collision that involves the Owner's own entry becomes UNGRADED, not a failure — MINOR

`Invoke-ReviewClaimCheck`: the ambiguity branch runs before the Owner-slug test. With roster `ada`, `ada.` (both slug to `ada`), Owner `ada` and Reviewer `ada.`, the 021 conditions hold (different strings), the check reports UNGRADED with exit 0, where the precise reading is "the claim is the Owner's". This is what plan P3 and P4 specify ("ambiguous roster slugs: UNGRADED"), and it is no weaker than 021 alone, but it lets a roster edit that adds a look-alike entry convert the Owner-claim failure into a non-failing line. The roster is reviewed code.
*Action: none; optionally, in the ambiguity branch, fail instead when one of the colliding entries slugs the same as the Owner's.*

### F4 — A claim for the Reviewer is read with the authors of every claim on the feature, so one unreadable unrelated claim hides a missing claim — MINOR

`Get-ReviewClaims -WithAuthors` (`adoption-lib.ps1` ~L429-443) reads the author of each ref and fails the whole reading on the first one it cannot read. Scenario: the Reviewer has no claim, a stale claim by a third person cannot be fetched on this runner: the result is UNGRADED, exit 0, where "no claim by the Reviewer" (red) is decidable from the ref names alone. Fail-safe in the sense that the line names the cause, but it converts a red into exit 0 on a transient condition.
*Action: none required; optionally read authors only for the Reviewer's slug (and the Owner's, for the hint). A one-line change plus a fixture.*

### F5 — Controls and the tasks T010 list not fully covered — MINOR

(a) `CRIT-R08/pass` and `CRIT-R09/pass` produce byte-identical output to the parent, so they pin only the absence of the new text, which is the stated purpose; `CRIT-R08/pass` records exit 1. (b) T010 asked for a stranger, an Owner-as-Reviewer and a denied-Reviewer fixture that print "no claim line", a solo-arm and a one-developer fixture, and a `pending` fixture. No new fixture was added for these; the notes say the existing `CRIT-T0x` and pending cases cover them. They do: those fixtures have no origin, so a claim line (UNGRADED) would have changed their `expected.txt`, and the 83-case run was green. This is an adequate substitute, but it is by inheritance and the notes should say so as the reason rather than "passed unchanged". (c) The parent-side result of R08 and R09 was not recorded, as the notes admit. (d) `rules.json` lists the `CRIT-R08` emission anchor under function `Invoke-ReviewClaimCheck`, but the clause sits in `Invoke-CriticalTeamEvidence`. The pair `CRIT-R06` pass/fail differ in both Reviewer name and claim author, which is acceptable.
*Action: none blocking; correct the `function` field of CRIT-R08 or leave it; optionally add one fixture with an origin and a stranger Reviewer to pin FR-005 with a readable ledger.*

### F6 — The check mutates the repository it grades (fetch fallback) — MINOR

`Get-ReviewClaims` runs `git fetch --quiet origin refs/heads/review/...` when a claim commit is absent locally, writing objects and `FETCH_HEAD` in the clone under check. Plan P2 specifies it. On a CI checkout this is harmless. Local runs of `ritual-checks.ps1` gain objects, and a credential prompt can block on an interactive terminal (as the other ledger readers can).
*Action: none; mention in the phase 4 guidance.*

## Amendments in this diff

- [x] None. The commit changes `tasks.md` only by ticking T009 to T013 and `notes.md` by appending the phase 2 record; neither alters a requirement, decision or task text, and `plan.md` and `spec.md` are untouched.

## Constitution re-check (post-implementation)

PASS. Specification First (I): implemented to the approved plan P4/P5. Testing (VIII): a failing and a passing fixture per P4 row (with F5 caveats). Human Review (IX): this review; the independence rule is graded more tightly, not changed. Controlled Delivery (X): one phase; territory held. Source of Truth (II): no conflict found; the plan P4 table and the code agree. Not applicable: III, V, VII.

## Test coverage observed

New: 16 cases in `enforcement-pack/CRIT-R05` to `CRIT-R09` (fail and pass per P4 row; four UNGRADED causes). Hand-written expectations, exact strings with exit codes. Changed: 16 existing team-arm recipes given a claim (input only). Observed run: `-Case enforcement-pack/CRIT-R0` selected 83 cases (the new ones plus the existing `CRIT-R01` to `CRIT-R04` cases); with the always-run suites, 261 passed, 0 failed, 0 skipped. I did not run the whole harness, the `CRIT-T*` cases individually, `ritual-checks.ps1` or the digests. Gaps: F1 (empty Owner slug), F4 (unrelated unreadable claim), the fetch-fallback success path (the claim author read after a successful fetch) has no fixture.

## Residual risk

Concentrated in F1: an Owner string the slug cannot represent makes the Owner tests a silent no-op, which is the exact shape of defect the kit tracks (a check that cannot run reading as a pass). Fix it with one UNGRADED line and a fixture before this check is adopted by a project with non-ASCII names. The rest is the stated limit (P9): a claim is a written claim, and the author test catches only the owner's own identity; F2 narrows that further for the email-only case. After merge, FitForge's first run will go red until the Reviewer claims; the update note in phase 4 must say so.
