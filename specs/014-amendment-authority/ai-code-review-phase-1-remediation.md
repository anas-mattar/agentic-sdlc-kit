# AI Code Review — 014 Amendment Authority — phase 1 remediation

**Reviewer**: fresh-context agent — claude-opus-5
**Date**: 2026-09-13
**Branches**: agentic-sdlc-kit `014-amendment-authority` (tip `0803049`; commits under review
`6fbffae` the Territory amendment, `0803049` the remediation)
**Scope reviewed**: `git show 6fbffae` and `git show 0803049` in full (2 + 10 files);
`.specify/memory/constitution.md` (SYNC IMPACT header + Principle I as amended, read whole);
`CLAUDE.md`; `docs/sdlc/definition-of-done.md`; `docs/sdlc/review-process.md`;
`docs/sdlc/repository-strategy.md`; `docs/sdlc/branch-strategy.md`; `docs/sdlc/gate-command.md`;
`.specify/templates/tasks-template.md`; `.specify/templates/micro-spec-template.md`;
`specs/_templates/{ai-code-review,human-pr-review}-template.md`;
`specs/014-amendment-authority/{spec,plan,tasks,notes}.md` and
`ai-code-review-phase-1.md` (the first review);
`scripts/scope-lib.ps1` + `scripts/scope-check.ps1` (Territory parsing, spec-dir exclusion);
`D:\solutions\fitforge\.specify\memory\constitution.md` Principle I (read-only, never written).
Commands run read-only: `scripts/ritual-checks.ps1`, `scripts/scope-check.ps1 -All`,
`diff` of the kit's normative clause against FitForge 1.1.0's.
**Feature contract**: phase 1 is law only — no script change, no new dependency;
Territory as widened by `6fbffae` (eight entries); `**Gate Certification**: ci-held`,
`**Gate Batching**: none`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5
- **Implementer**: claude-opus-5 (the session that produced the remediation)
- **Inputs provided**: remediation diff (0803049), amendment (6fbffae), first review, spec.md, plan.md, tasks.md, notes.md, constitution, FitForge constitution (read-only)
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — the textual half of the remediation is genuinely good. F1's over-claim is
gone from the clause *and* from every mirror I could find; F2's un-tick ambiguity is closed in
both directions and now agrees with D3's multiset comparison; F3 delivers the second sentence of
FR-003 that was missing, stating plainly that **nothing** enforces the self-approval prohibition
and that "approved" is a first-appearance proxy; F4's provenance is restored (date, the feature
001 governance F3 attribution, the four checks by name) and the record that mis-described it is
corrected; F6's three amendment-procedure statements are swept and both review templates gained
the item; F7, F8 and F9 are all addressed. The normative clause is still **byte-identical** to
FitForge 1.1.0's (`diff` of `constitution.md:197-203` against
`fitforge/.specify/memory/constitution.md:79-85` → no output), so the flow-down still reconciles.
The Territory declaration parses — `scope-check: PASS phase 1 commit 0803049 (10 file(s))` — and
the warning comment is placed where it provably cannot break it. `ritual-checks.ps1` → `RESULT OK`.
Nothing was touched outside the amended Territory.

Three things block. **G1**: the rewritten Rationale ships a **duplicated sentence**
(`constitution.md:238-240`) — an editing artifact left in the top rung of the source-of-truth
ladder by the commit whose job was to raise that paragraph's quality, on a 113-character line in
a file that wraps at ~90. **G2**: F5 is only half fixed. D3b stops *future* evidence going into
`tasks.md`, but `ced1302` and `f49ad61` are still on the branch, each amending `tasks.md` with no
record and no approver in the message; nothing in D1/D2 bounds the commit range, so both still
FAIL the check phase 2 builds, and **T019 is still unsatisfiable** — the precise defect F5 named.
`notes.md:24-47` narrates that history and then declares the finding "resolved", which it is not.
**G3**: moving evidence out of `tasks.md` left live counter-instructions inside the same
documents — `tasks.md:186-188` (T018) still says "record all sixteen verdicts **in this file**",
and `plan.md:84` (D3a) still says a spurious one-off "earns a judgement recorded in `tasks.md`".
A phase-2 session that obeys T018 literally produces exactly the non-conforming commit D3b exists
to prevent.

Residual risk sits with G2: it is the one finding that was blocking in the first review, is still
blocking, and gets more expensive with every commit, because D5 puts half of every record in an
immutable commit message. G1 is a two-line fix. G3 is three lines and must land before T014/T018
are written.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-001 ✅ clause + rationale + honest limits, `constitution.md:197-242`, still FitForge-compatible. FR-002 ✅ `:197-203`, unchanged and byte-identical to FitForge. FR-003 ✅ **now delivered** — the prohibition (`:202`) and the precise statement of what is and is not verified (`:215-227`), including "that half of this rule is held by review alone". FR-012 ⚠️ **near-complete** — the three amendment-procedure statements and both review templates are swept; `docs/sdlc/repository-strategy.md:123-124` (the multi-repo twin) and the "task-scoped reading table" the FR names are not (G6, G13). FR-004..FR-011 are phases 2–4, not claimed here. |
| Fidelity to FitForge 1.1.0 (plan D9) | Normative paragraph `diff`ed against `fitforge/.specify/memory/constitution.md:79-85` → **identical**, unchanged by the remediation. Rationale is now near-verbatim FitForge with two kit-only insertions ("Five rule changes: …" and the scope-check-by-construction clause) — plus the duplicated sentence (G1). `notes.md:14-18` records the reconciliation; the row is materially honest now but still under-records the two additions (G7). |
| Versioning / SYNC IMPACT | 0.7.0 / MINOR unchanged and still correct; the header was **not** updated to match the amended clause, so `:13-15` still summarises "what the machine verifies … and what it does not (that the named person agreed)" — one limit where the clause now states three, in the machine-verifies framing F1 removed (G11). Nothing else in the header contradicts the diff; the machine half is still correctly future-tensed at `:20-23`. |
| F1 mirror sweep (does any normative text still assert a check that does not exist?) | **No.** `constitution.md:215` "a machine **can** grade"; `review-process.md:136` "A machine **can** grade"; `definition-of-done.md:85-87,127-130` state obligations, not checks; `tasks-template.md:52-57` states the requirement, names no script; `CLAUDE.md:92-94` is a pointer; `human-pr-review-template.md:49-50` "a machine can only check"; `ai-code-review-template.md:60-64` names constitution I, no script. The only `enforcement-pack.ps1` mentions are the future-tensed SYNC IMPACT line (`:21-23`), the rationale's list of checks that grade *other* things (`:235`), and `docs/roadmap.md:76` ("then an `enforcement-pack.ps1` check that grades it"). Digest markers (`review-process.md:122`, `definition-of-done.md:132,134`) assert nothing about an existing check. |
| Digests | `build-digests.ps1 -Check` inside ritual-checks → `OK (5 digest(s) fresh, 75 marker(s))`. The remediation edited prose adjacent to markers but no marker text, so no regeneration was needed and none was committed — consistent, not an omission. |
| Scope guard | `scope-check -All`: `PASS phase 1 commit ced1302 (7)`, `PASS f49ad61 (1)`, `PASS 6fbffae (2)`, `PASS 0803049 (10 file(s))`. `0803049`'s ten files = seven in the eight-entry Territory + three under `specs/014-amendment-authority/**`, which `scope-check.ps1:178,230` makes implicitly in-territory. **Nothing outside Territory.** The amendment `6fbffae` correctly precedes the commit that relies on it. |
| Territory parsing (the trap the implementer hit twice) | Parses. Proved two ways: `0803049` PASSes with files that are only legal under the three new entries; and by reading the parser — `scope-check.ps1:210` calls `Get-Territory` on the **raw** `tasks.md` blob (unlike the Micro path at `:161`, which pre-strips comments with `Get-VisibleLines`), so in `tasks.md` an HTML comment between marker and entries really would hit `scope-lib.ps1:104` (`$collecting = $false`) and empty the list. The comment at `tasks.md:57-61` sits **above** the marker, where `$collecting` is still `$false` and every line is skipped, so it cannot itself break parsing. Its embedded `` `**Territory**:` `` is backtick-prefixed mid-line and cannot match `^\*\*Territory\*\*:`. Correctly placed; see G9 for what it does not cover. |
| Whole-run verdict | `pwsh -File scripts/ritual-checks.ps1` → `RESULT OK` (doc-lint OK, enforcement-pack OK, scope-check OK, scope-repos n/a, digests OK, roadmap-claims OK, verify-kit n/a). Two non-blocking `PhaseSizeWarning`s: `0803049` (611 lines / 10 files — 336 of them the first review file being committed) and the pre-existing `aa3b194`. |
| Constitution / domain invariants | The amendment procedure (`constitution.md:397-400`) is followed: rationale present, SYNC IMPACT present, human adoption attributed to owner approval plus gate-6. The remediation amends the clause it ratified two commits earlier, under that clause's own ritual — see "Amendments in this diff". |
| Rollback safety | Documents only; no generated coupling (no digest regeneration in this commit). Reverts cleanly, and unlike `ced1302` the stated revert story now matches the diff — the clause no longer claims a check. |

## Findings

Numbered from G1 to avoid collision with the first review's F1–F9.

### G1 — The rewritten Rationale ships a duplicated sentence into the constitution — BLOCKING

`.specify/memory/constitution.md:238-240`, verbatim:

> Every one of those amendments happened to be correct, which is exactly why the mechanism
> would have survived one that was not. Each of those amendments happened to be correct, which is precisely why the
> mechanism would have survived one that was not.

The same sentence twice, in two paraphrases — FitForge's original ("Every one … exactly why",
`fitforge/.specify/memory/constitution.md:92-93`) and the kit's first draft's version ("Each of
those … precisely why", `ced1302`). The rewrite spliced the restored FitForge text in front of
the old sentence instead of replacing it. Line 239 is **113 characters** against a file that
wraps at 87–92, which is the tell.

Blocking rather than cosmetic for three reasons. It is in the **top rung of the source-of-truth
ladder** — the one document every adopted project re-expresses. It is in the paragraph
`0803049` exists to repair, so the fix carries a defect of the same class as the thing it fixed.
And it breaks the D9 fidelity story the feature is built on: a flow-down reader diffing the kit's
rationale against FitForge's will find a stutter nobody recorded, in the paragraph `notes.md:18`
describes as "the sentence order is the kit's, the facts are FitForge's".

*Action: implementer — delete the second copy (keep FitForge's "Every one of those amendments happened to be correct, which is exactly why the mechanism would have survived one that was not.") and re-wrap lines 238-242 to the file's width. One amendment record covers this and G3 together (D4).*

### G2 — F5 is half fixed: two commits on this branch still fail the check, and T019 is still unsatisfiable — BLOCKING

D3b changes where evidence goes **from now on**. It does nothing about the two commits that
already put evidence in `tasks.md`, and nothing in the plan bounds the check's commit range.

Replaying the specified check (D1 per-commit over `base..HEAD`, D2 creation test, D3 checkbox
exemption, D4 record in diff, D5 name in message) against this branch's six commits
(base `49d56aa`, file lists from `git show --name-status`):

| Commit | Feature documents touched | Verdict under D1–D6 |
|---|---|---|
| `be7f36d` | A `spec.md` | PASS — creation (D2) |
| `aa3b194` | A `plan.md`, A `tasks.md` | PASS — creation (D2) |
| `ced1302` | M `tasks.md` — ticks T001–T009 **and** appends the reconciliation + finding sections | **FAIL** — not checkbox-only (D3/S10), no record line, no approver in the message |
| `f49ad61` | M `tasks.md` — appends the "Phase 1 — gate" section | **FAIL** — no record line, no approver in the message |
| `6fbffae` | M `plan.md`, M `tasks.md` | PASS — record lines at `plan.md:48,96` and `tasks.md:74,109`, "Amendment approved by: anas.m, 2026-09-13." in the message |
| `0803049` | M `tasks.md` | PASS — record line added at `tasks.md:264` in this commit's own diff, same name in the message |

`tasks.md:189-190` (T019) still requires "`ritual-checks.ps1` here … green — this branch's own
commits must satisfy the rule the check now grades". Two of them cannot, and cannot be made to:
D5 puts the approver's name in the commit message, which is fixed at commit time, and
`0803049` removing those sections changes `0803049`'s diff, not `ced1302`'s.

`notes.md:32-35` states the problem exactly right and then `:45-47` chooses resolution (c) as
if it settled it. It does not: (c) is forward-looking only. The first review's suggested bound
("grade only commits whose first parent already contains the clause") would not have cleared
`f49ad61` either — its parent *is* the clause commit — so the boundary genuinely needs
deciding, not inheriting.

The kit already has the precedent for the shape of the fix: `definition-of-done.md:123`
grandfathers review files "committed before the verification pack … at their historical paths",
and `repository-strategy.md:126-129` states the same idea for Territory ("leave those phases
undeclared … and declare from the next phase forward").

*Action: implementer + owner, in phase 2 and before T014 — amend `plan.md` D1 (with its own approver line) to state the grading boundary explicitly: grade only commits authored after the clause's ratification commit, or grandfather commits that predate it by sha, naming `ced1302` and `f49ad61` in `notes.md` as the grandfathered pair with the reason. Add the boundary as fixture S15 with its verdict fixed before the check is written. Do not leave this to phase 3 and do not rewrite history.*

### G3 — D3b left live counter-instructions inside the documents it amended — BLOCKING

Evidence moved to `notes.md`, but three statements still send it back to `tasks.md`:

- **`tasks.md:186-188`** (T018, phase 2): "record all sixteen verdicts **in this file** under
  'Phase 2 — scenario results'". This is the next phase's own task. A session that obeys it
  literally appends a results table to `tasks.md` — a non-checkbox change to an approved
  document — and produces exactly the unrecorded amendment D3b was chosen to make impossible,
  in the same commit range T019 requires to be green.
- **`plan.md:84`** (D3a): "A one-off flag is not a class and does not earn an exemption; it earns
  a judgement recorded in `tasks.md`." D3b (`:86-94`) says it supersedes D3a "for this question
  only" — but this *is* that question, and the two decisions now name different files for the
  same artefact.
- **`tasks.md:203-206`** (phase 3 Territory) lists `specs/014-amendment-authority/tasks.md` and
  not `notes.md`. Harmless mechanically — `scope-check.ps1:178,230` makes `specs/<branch>/**`
  implicitly in-territory, so both files pass either way — but it is the declaration a reader
  consults to learn where phase 3 writes, and it still says `tasks.md`.

`tasks.md:258-262` and `notes.md:3-7` both state the new convention clearly; the defect is that
the tasks and the older decision were not swept to match. T020 and T025 say "table every flag"
and "record the results" without naming a file, so they are fine as written.

*Action: implementer + owner — one amendment (carrying its own approver line) that rewrites T018 to name `notes.md`, adds the same to T020/T025 for clarity, edits D3a's last sentence to `notes.md`, and replaces phase 3's redundant `tasks.md` Territory entry with `notes.md` or drops it.*

### G4 — The amendment commit carries a `phase 1` token and its message denies it — NON-BLOCKING

`6fbffae`'s subject is "amend 014 plan and tasks: **phase 1** remediation, approved by anas.m",
and its body asserts "Not a phase commit - no phase token in this subject." That claim is false:
`scope-check.ps1`'s attribution regex matches it, and `scope-check -All` reports
`PASS phase 1 commit 6fbffae (2 file(s))`. The branch now carries four commits attributed to
phase 1 (`ced1302`, `f49ad61`, `6fbffae`, `0803049`).

This is F9 reproduced by the very commit that set up F9's remediation, and it is a commit-message
claim contradicted by the tool the message is reasoning about. Consequences here are nil (both
commits PASS, and phase-size is warned per commit). On a Micro feature the same habit folds
bookkeeping commits into the 400-line hard bound.

*Action: implementer — no history rewrite; record in `notes.md` alongside the F9 note that the amendment commit itself tripped the rule, since that is the second instance in four commits and argues for a machine check rather than a remembered convention. Consider a roadmap GAP row: `scope-check` could warn when a non-`phase`-verbed subject carries a phase token.*

### G5 — D3b's convention has nowhere to land: phase 4 cannot reach the documents that would state it — NON-BLOCKING

D3b (`plan.md:91-94`) says "The kit convention this changes is documented in phase 4", and rests
on `notes.md` already being "an allowed optional file". The second half is true —
`docs/sdlc/branch-strategy.md:142` lists `notes.md               (optional)`. But it is listed
with no purpose, and:

- Phase 4's Territory (`tasks.md:236-240`) is `adoption/updating.md`, `adoption/greenfield.md`,
  `docs/digests/`. None of the documents where this convention would be written —
  `branch-strategy.md`, `tasks-template.md`, `review-process.md` — is in it, and T026–T030
  contain no task about it.
- `.specify/templates/tasks-template.md:14` still instructs the opposite in miniature: "record
  that determination **in this file**" (of a skipped-tests judgement). That template is in phase
  1's widened Territory and was edited by this very commit.

So today the kit tells a future feature nothing about where evidence belongs, and the phase that
is supposed to say so has neither a task nor the Territory to do it. The gap between "this
feature does it" and "the kit expects it" is real and currently unscheduled — the same shape as
F6, one phase later.

*Action: implementer + owner — either add the documents and a task to phase 4 (Territory amendment with an approver line), or state the convention now in `branch-strategy.md`'s Spec Directory Contents and `tasks-template.md`, which are one line each. Whichever is chosen, fix `tasks-template.md:14` to point at `notes.md`.*

### G6 — The F6 sweep missed the multi-repo twin of the same instruction — NON-BLOCKING

`docs/sdlc/repository-strategy.md:123-124`:

> Legitimate scope discovery is amended in a governance commit made **before** the code phase
> commit that relies on it.

This is the fourth statement of the instruction whose other three were swept
(`tasks-template.md:52`, `definition-of-done.md:85`, `review-process.md:65`), and it is the one a
multi-repo project actually follows — `CLAUDE.md:149-152` and `definition-of-done.md:96` both
route the reader here. It does not assert the pre-amendment rule as loudly as the other three did
(it is silent on approval rather than saying "owner approval" and stopping), which is why this is
non-blocking; but FR-012 asks that "no document keeps the pre-amendment reading", and a developer
following this sentence writes an unrecorded Territory amendment.

`specs/012-cross-repo-scope-check/contracts/scope-check-repos-cli.md:70` carries the old wording
too; that is a shipped feature's historical artifact and should be left alone.

*Action: implementer — add "…, carrying the record constitution I requires" to `repository-strategy.md:123-124`. In Territory already? No — it needs the Territory amendment, so fold it into whichever amendment lands G3.*

### G7 — The corrected reconciliation row still under-records the kit's additions — NON-BLOCKING

`notes.md:18` now says the rationale was "rewritten, provenance restored … the sentence order is
the kit's, the facts are FitForge's". Comparing `constitution.md:229-242` against
`fitforge/.specify/memory/constitution.md:87-95`:

- The **sentence order is FitForge's**, not the kit's — the paragraphs now track each other
  clause for clause.
- Two sentences are **kit-only** and are not in FitForge: "Five rule changes: a new package, a
  changed contract value, two widened Territory blocks, an added phase." and the
  scope-check-by-construction clause ("— so an agent that widens its own Territory passes the
  scope check by construction, because the check reads the Territory that same agent just
  wrote"). Both are good additions; neither is a FitForge fact, so "the facts are FitForge's"
  sends the flow-down reader looking for text that is not there.
- The duplicated sentence (G1) is unrecorded, for the obvious reason that it is a defect.

This is a much smaller error than the one F4 caught, and the row is now materially honest about
the important part (the rewrite, and that the record was wrong before the text was). But the row
exists for exactly one reader — whoever reconciles at flow-down — and it is still not a
description they can rely on without diffing.

*Action: implementer — replace the last clause with "the order follows FitForge's; the kit adds two sentences FitForge does not have (the enumeration of the five changes, and the scope-check-by-construction argument), and drops nothing".*

### G8 — The adopter remediation the plan promises is already known-false under D5 — NON-BLOCKING

`tasks.md:244-246` (T027, phase 4) tells adopters that when an in-flight feature's documents were
amended without records, "the remediation is to record the approver, not to edit history".
Under D1 + D5 that does not work: the check grades each commit against its own parent and
requires the approver's name **in that commit's message**. A record added by a later commit
rescues the later commit, never the earlier one. The adopter's branch stays red until the
offending commits are rewritten or grandfathered.

This is phase 4 work and not due now, but the decision behind it is the same one G2 forces, so it
should be settled once rather than twice — and an adoption document that promises a remediation
that does not work is the FR-011 "no surprises" promise failing in the opposite direction.

*Action: implementer — settle with G2; whatever boundary is chosen (grandfathering by date or by ratification sha) is what T027 must describe.*

### G9 — The parser trap is fixed for this feature only, and behaves differently across lanes — NON-BLOCKING

The five-line warning at `tasks.md:57-61` is well-placed and accurate for `tasks.md` — I verified
both claims against `scope-lib.ps1:83-105` and `scope-check.ps1:210`. Two things it does not do:

- It protects **this feature alone**. `.specify/templates/tasks-template.md:42-47` — in Territory,
  and edited by this very commit — says only "Keep the exact `**Territory**:` marker" and
  "Exactly one `**Territory**:` marker per phase", without naming the failure mode the
  implementer hit twice in one afternoon. The next feature's `tasks.md` is born without the
  warning.
- The behaviour is **not uniform across lanes**, and nothing says so. `scope-check.ps1:161`
  passes a Micro feature's `spec.md` through `Get-VisibleLines` (HTML comments stripped);
  `:210` passes `tasks.md` raw. So the identical annotation is harmless in a Micro `spec.md`
  and silently empties the declaration in a Standard `tasks.md`. A reader of the warning comment
  will generalise the wrong way.

Note also that a five-line commentary about a script's internals is not "agreed work or
completion state", which is what `tasks.md:260-262` now says this file holds. It arrived under an
approved amendment so it is lawful; it is mildly in tension with the convention it sits next to.

*Action: implementer — move the substance into `tasks-template.md`'s Phase Territory rules as one bullet ("no line between the marker and the first entry — not even an HTML comment: the parser reads tasks.md raw and stops collecting"), and, separately, consider making `scope-check.ps1:210` strip comments the way `:161` does so the two lanes agree. The second is a phase-2 script change, not a phase-1 edit.*

### G10 — The new exemption sentence imports an intent test no machine can grade — NON-BLOCKING

`constitution.md:209-210`:

> Every other change to an approved document is an amendment, including any task whose **text**
> changes — re-worded, re-scoped, or re-opened by an annotation **that changes what the task
> means**.

The last qualifier is the only ungradeable phrase in the clause. D3 (`plan.md:73-78`) strips
checkbox markers and compares multisets: *any* text difference is an amendment, including a typo
fix that changes no meaning at all. So the law is narrower than its implementation on the precise
axis F2 was raised about — a reader could argue a meaning-preserving annotation is exempt, and
the check will fail it.

The catch-all immediately before it ("Every other change to an approved document is an
amendment") already covers the case, so the qualifier buys nothing and costs the clause its one
machine-checkable boundary.

*Action: implementer — cut four words: "…re-worded, re-scoped, or re-opened by an annotation." Then the clause and D3 grade the same thing.*

### G11 — The SYNC IMPACT header still describes the pre-remediation clause — NON-BLOCKING

`constitution.md:13-15` summarises the clause as stating "plainly what **the machine verifies**
(a record exists, is well-formed, and agrees with its commit) and what it does not (that the
named person agreed)". The clause now says "a machine **can** grade" and lists **three** limits,
the second of which — that nothing enforces the self-approval prohibition — is the FR-003 text
the remediation added. The header keeps the machine-verifies framing F1 removed and omits two of
three limits.

The header is not the law and `:20-23` still correctly future-tenses the machine half, so nothing
here is false about sequencing. But the header is the first thing an adopting project reads at
update time, and it is the mirror of the clause that was not swept with it.

*Action: implementer — one sentence: "…states plainly what a machine can grade (a record exists, is well-formed, agrees with its commit) and the three things it cannot (that the named person agreed; the self-approval prohibition, which review alone holds; and approval itself, proxied by a document's first appearance)."*

### G12 — One absolute replaced another in the honesty paragraph — NON-BLOCKING

F8 softened "a *silent* amendment becomes impossible"; the same rewrite introduced
`constitution.md:218-219`: "It cannot enforce the self-approval prohibition at all: **no check
can tell which session produced a diff**".

"No check can" is a claim about all possible checks, in the paragraph whose authority comes from
hedging. The kit already extracts implementer identity from a written attestation — the Reviewer
Provenance block (`definition-of-done.md:113-125`), which `enforcement-pack.ps1` grades for
consistency — and `plan.md:137-138` anticipates GAP-024's declared-developer roster making
"is this a real declared person" checkable. The honest version is that nothing *in this kit*
identifies the implementing session, and that the record's strength is falsifiability, not
detection.

*Action: implementer — "no check in this kit can tell which session produced a diff, and none is planned", or "nothing the kit records identifies the implementing session". Wording only.*

### G13 — Two nits in the new review-template items, and one FR-012 mirror with nothing in it — NON-BLOCKING

- `specs/_templates/ai-code-review-template.md:58-66` adds an "Amendments in this diff" section
  whose comment asks the reviewer to **list** every amendment with its approver, but whose only
  body is a checkbox: `- [ ] Amendments listed, or **none** stated explicitly`. It is the one
  checkbox in an otherwise narrative template (every other section is a prose or table prompt),
  and ticking it is not the same artefact as writing the list. Not unfalsifiable — the list
  either exists or it does not — but the prompt and the affordance disagree.
  *Fix: replace the checkbox with a table stub (`| Document | What changed | Approver recorded |`)
  plus "or **none**".*
- `specs/_templates/human-pr-review-template.md:48-51` is a single checkbox carrying three
  distinct judgements (record present; consent real; not self-approved). It mirrors
  `review-process.md:135-139` faithfully and duplicates no existing item, so this is style only;
  a reviewer who can only tick or not tick cannot signal "two of three".
- FR-012 (`spec.md:218-220`) names four mirrors: "the sync list, the affected templates, the
  **task-scoped reading table**, and the relevant law digest". The sync list, templates and
  digests all received something; `CLAUDE.md`'s task-scoped reading table received no row, and no
  task in any phase claims it. Arguably there is no natural "Touching…" trigger for an amendment,
  in which case the FR should say so — but as it stands an enumerated mirror is silently
  undelivered.

## Amendments in this diff

Constitution I, Amendment authority — every change these two commits made to this feature's own
approved documents, and the approver each records:

| Document | What changed | Record | Commit message names approver |
|---|---|---|---|
| `plan.md` | Technical Context gains the "Amendment — phase 1 remediation" paragraph; new decision **D3b**; four rows added to the Source Code file table (`6fbffae`) | `plan.md:48` and `plan.md:96` — `**Amendment approved by**: anas.m, 2026-09-13.` | `6fbffae`: "Amendment approved by: anas.m, 2026-09-13." ✅ |
| `tasks.md` | Phase 1 Territory widened by three entries + the parser warning comment; the "Phase 1 remediation" task block T031–T040 added (`6fbffae`) | `tasks.md:74` and `tasks.md:109` | `6fbffae` ✅ |
| `tasks.md` | T031–T040 ticked; the reconciliation, finding and gate sections removed; the "Evidence lives in `notes.md`" paragraph added (`0803049`) | `tasks.md:264` — added in `0803049`'s own diff | `0803049`: "Amendment approved by: anas.m, 2026-09-13." ✅ |
| `spec.md` | not touched | n/a | n/a |
| `contracts/` | none exists | n/a | n/a |
| `notes.md` | new file (`0803049`) | not required — outside the clause's scope (`spec.md`/`plan.md`/`tasks.md`/`contracts/`), and a first appearance under D2 either way | n/a |

**Are these records conforming under the clause as now written?** Yes, both, on every limb I can
test: the amended sections carry `**Amendment approved by**: <name>, <YYYY-MM-DD>` (D4 — one
record per commit is satisfied, and in fact exceeded, since `6fbffae` carries one per document);
the approver's name appears in each commit message (D5); the names are non-empty with no slot or
`TODO` marker and the dates are real and equal to, not later than, each commit's author date
(2026-09-13 — D6); and the approver `anas.m` is the repository owner, not the implementing agent
(the implementing agent appears only as the `Co-Authored-By` trailer). The amendment precedes the
commit that relies on it, which is the sequence `tasks-template.md:52-57` requires.

**Would the planned check pass them?** `6fbffae` and `0803049` — PASS. `ced1302` and `f49ad61` —
**FAIL**, see G2. That is the blocking part: the feature's own branch is not green under the
check phase 2 is about to build, and T019 makes that a hard requirement.

**Does reviewing against amended documents change this verdict?** It changes the marking scheme
honestly: the plan I graded against (D3b) and the tasks I graded against (T031–T040) were both
written after the first review and by the same session that then implemented them, with the
owner's recorded approval on each. I read `6fbffae` before `0803049` for that reason. The
amendments are narrow, they are what the first review asked for, and none of them weakens a
success criterion or removes an obligation — D3b *adds* one. The one thing the amendment did
quietly is re-scope F5 from "the branch must become green" to "evidence moves out of tasks.md",
and that re-scope is why G2 exists.

## Constitution re-check (post-implementation)

**PASS, with the findings above.**

- **I Specification First** — spec, plan and tasks all precede the work; the remediation is
  itself an amendment made under I's new clause, with records, in the right order. The feature
  still does not obey its own rule across its whole history (G2), which is where I is engaged
  rather than satisfied.
- **II Source of Truth** — no ladder change. G1 puts a defect *in* the top rung but adds no rung.
- **III / V** — N/A (single-repo kit; no invariant pack).
- **IV Architecture Consistency** — no script, no new file in `scripts/`, no package. PASS.
- **VI Security** — documents only; the records hold a name already published across the
  roadmap and review artifacts. PASS.
- **VII External Integration** — N/A. The record's shape is still stated in the law before any
  check reads it, which is D9's point and remains intact. PASS.
- **VIII Testing** — no test surface in a law-only phase. The phase's Independent Test
  (`tasks.md:53-55`) now passes on all three limbs: a reader can find the record shape, is told
  what can and cannot be verified (the F1/F3 fix), `ritual-checks.ps1` is green, and the digests
  match their markers. G1 does not defeat it — a duplicated sentence is embarrassing, not
  misleading.
- **IX Human Review** — this is the gate-5 half for the remediation, produced fresh-context by a
  reviewer who did not write the diff and is not the first reviewer; gate 6 at merge.
- **X Controlled Delivery** — still one phase, `ci-held`, `Gate Batching: none`. The remediation
  landing as a **second `phase 1` commit** rather than a new phase number is defensible and is
  recorded in `plan.md:39-46`; it does mean phase 1 is now four commits and 611 lines on the
  last one (`PhaseSizeWarning`, non-blocking). The phase-1 gate record in `notes.md:85-87` is
  correctly left open pending this review. PASS.

## Test coverage observed

No test surface — law-only phase by design. Verification available was machine-check replay plus
manual replay of the *specified* check, all read-only:

- `pwsh -File scripts/ritual-checks.ps1` → `RESULT OK` (doc-lint, enforcement-pack, scope-check,
  digests, roadmap-claims OK; scope-repos and verify-kit `n/a`; two non-blocking
  `PhaseSizeWarning`s).
- `pwsh -File scripts/scope-check.ps1 -All` → four PASS lines, including
  `PASS phase 1 commit 0803049 (10 file(s))`, which is what proves the widened Territory parses.
- `diff` of `constitution.md:197-203` against `fitforge/.specify/memory/constitution.md:79-85`
  → identical (D9 fidelity for the normative paragraph, re-verified after the rewrite).
- Manual replay of D1–D6 over all six branch commits (table in G2) — the only way to test a
  check that does not exist yet.

For whoever writes phase 2's fixtures: the first review asked for **S15 (un-tick only)** and
**S16 (evidence append)**. Both are still missing from `tasks.md:24-43`. Add a third — **S17: a
commit whose parent predates the clause** — because G2 forces that boundary to be decided, and
the verdict should be fixed before the check is written, not discovered by running it on this
branch.

## Residual risk

G2 carries it. The branch cannot go green under its own check as the plan currently specifies,
the two failing commits are immutable in the half that matters, and phase 2 is where T014 and
T019 both land — so the decision is due in the next phase, not the one after. Everything else is
recoverable cheaply: G1 is a deletion, G3 is three sentences, and G4–G13 are wording or
scheduling. The one to watch beyond this feature is G5 — D3b is a kit-wide convention change
that currently exists only inside this feature's `plan.md`, with no phase scheduled that can
reach the documents where it would become law; that is F6's shape repeating, and if it is not
scheduled now it ships undelivered.
