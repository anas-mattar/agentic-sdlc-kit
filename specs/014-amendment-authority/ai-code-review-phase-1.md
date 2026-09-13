# AI Code Review — 014 Amendment Authority — phase 1 ("the law states the rule")

**Reviewer**: fresh-context agent — claude-opus-5
**Date**: 2026-09-13
**Branches**: agentic-sdlc-kit `014-amendment-authority` (tip `f49ad61`; commit under review `ced1302`)
**Scope reviewed**: `git show ced1302` in full (7 files); `.specify/memory/constitution.md`
(SYNC IMPACT header + Principle I as amended + Governance/versioning policy);
`CLAUDE.md`; `docs/sdlc/definition-of-done.md`; `docs/sdlc/review-process.md`;
`docs/digests/{delivery,review}-digest.md` + `docs/digests/digest-packs.json`;
`specs/014-amendment-authority/{spec,plan,tasks}.md`;
`.specify/templates/tasks-template.md`; `.specify/templates/plan-template.md`;
`specs/_templates/{ai-code-review,human-pr-review}-template.md`;
`D:\solutions\fitforge\.specify\memory\constitution.md` Principle I (read-only).
Commands run read-only: `scripts/ritual-checks.ps1`, `scripts/scope-check.ps1`,
`scripts/build-digests.ps1 -Check`.
**Feature contract**: phase 1 is law only — no script change, no new dependency; Territory
`.specify/memory/constitution.md`, `CLAUDE.md`, `docs/sdlc/review-process.md`,
`docs/sdlc/definition-of-done.md`, `docs/digests/`; `**Gate Certification**: ci-held`,
`**Gate Batching**: none`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5
- **Implementer**: claude-opus-5 (the session that produced the phase 1 diff)
- **Inputs provided**: phase 1 diff (ced1302), spec.md, plan.md, tasks.md, constitution, definition-of-done.md, review-process.md, FitForge constitution (read-only)
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — the phase does the hard part well: the normative clause
(`.specify/memory/constitution.md:197-203`) is **byte-identical** to FitForge 1.1.0's
(`fitforge/.specify/memory/constitution.md:79-85`, verified by `diff`), so the flow-down
reconciles rather than collides; the bump is MINOR under the constitution's own policy
(`:405`), the prior 0.5.0 → 0.6.0 entry is demoted intact in the house style, the two new
digest markers are in pack-member documents and `build-digests.ps1 -Check` is clean, the
constitution correctly carries no markers (it is not a pack member), and the commit stays
inside its declared Territory (`scope-check: PASS phase 1 commit ced1302 (7 file(s))`).

The verdict is REQUEST CHANGES because of what the kit *added* to FitForge's wording and
what it left behind. Six blocking findings, and they cluster on one theme — **this phase
is about honesty about enforcement, and it is not honest about its own**. The clause
asserts in the present tense that `scripts/enforcement-pack.ps1` grades the record, when
this phase ships no script at all (F1), and that assertion directly contradicts the commit
message's own revert story. The one exemption the kit invented is ambiguous in exactly the
case its planned implementation decides the other way (F2). The honesty paragraph is
silent on the two things nothing verifies — the self-approval prohibition and the word
"approved" itself (F3), which is the second half of FR-003 left undelivered. The
reconciliation record that makes D9 auditable mis-describes the one paragraph it does not
flag (F4). The mirror sweep stopped one document short of the three places that actually
instruct someone to amend a Territory, including a sync-listed template (F6). And the
branch's own two tasks.md commits already violate the clause in a way that cannot be fixed
after the fact without rewriting history, with the decision deferred one phase past the
task that requires the branch to be green (F5).

Residual risk sits with F1 and F5: F1 is the worst state the spec itself names
("an unenforced law that people believe is enforced is worse than an absent one",
`spec.md:44-45`) and this commit creates it for the life of the branch; F5 is cheap now
and expensive after phase 2 is written.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-001 ✅ clause + rationale present, `constitution.md:197-232`, and compatible with FitForge (see below). FR-002 ✅ record shape and same-approver-in-commit stated verbatim, `:200-202`. FR-003 ⚠️ **partial** — the MUST NOT is present (`:202`) but the required statement of "what it verifies about this and what it does not" is absent (F3). FR-012 ⚠️ **partial** — three amendment-procedure statements and two review templates still carry the pre-amendment reading (F6). FR-004..FR-011 are phases 2–4, not claimed here. |
| Fidelity to FitForge 1.1.0 (plan D9) | `diff` of `constitution.md:197-203` against `fitforge/.specify/memory/constitution.md:79-85` → **identical**. Differences beyond that: "Progress is not amendment" (recorded, `tasks.md:210`), "What is verified" replacing "Enforcement, honestly stated" (recorded, `:211`), and the Rationale paragraph — rewritten, recorded as "near-verbatim / same" (F4). Paragraph order also differs (kit puts Rationale last); harmless, but `tasks.md:214` "No other difference" is literally false. |
| Versioning / SYNC IMPACT | MINOR is correct: "a new principle or section is added" (`constitution.md:405`); nothing removed or redefined, Principle I's workflow and Micro arm untouched. Prior history demoted as "Prior version history (0.5.0 → 0.6.0):" matching the existing 0.4.1/0.4.0/0.3.0 entries; the "(kit template — not yet ratified by a project)" note carried to the new top line; footer bumped to 0.7.0 (`:411`). Claimed mirrors (`:25-28`: CLAUDE.md, definition-of-done.md, review-process.md) all actually changed; nothing claimed-but-not-done. adoption/* correctly deferred to phase 4. |
| Digests | `digest-packs.json` lists delivery = {definition-of-done, gate-command, flow} and review = {review-process, rollback-process}; the two new markers sit in `definition-of-done.md:132` and `review-process.md:121`, both pack members. `.specify/memory/constitution.md` carries zero `digest:` markers — the commit message's "drafted and removed" claim holds, and the removal is correct: the constitution is in no pack, so the markers would never have been assembled or drift-checked. `build-digests.ps1 -Check` → `OK (5 digest(s) fresh, 75 marker(s))`; bullet counts 23 and 11, inside the 40-bullet bound. |
| Scope guard | `scope-check: PASS phase 1 commit ced1302 (7 file(s))`. Files: constitution, CLAUDE.md, DoD, review-process, two digests (under `docs/digests/`), and `specs/014-amendment-authority/tasks.md` (implicitly in territory by kit convention). **Nothing outside Territory.** `git show --stat` read for intent: no stray edits, no unrelated files. |
| Whole-run verdict | `pwsh -File scripts/ritual-checks.ps1` → `RESULT OK` (doc-lint OK, enforcement-pack OK, scope-check OK, scope-repos n/a, digests OK, roadmap-claims OK, verify-kit n/a). Working tree clean before and after this review's own file. |
| Constitution / domain invariants | This phase *is* a constitutional amendment; Governance's amendment procedure (`:397-400`) is followed as to rationale + SYNC IMPACT. Human adoption is attributed to the owner's spec/plan approval plus gate-6 at merge — the same formula the 0.5.0 and 0.6.0 entries use, so no new deviation. |
| Rollback safety | The diff reverts cleanly (documents only, no generated coupling beyond the two digests, which regenerate). But the revert *story* in the commit message is not what the diff says — see F1. |

## Findings

### F1 — The clause claims a machine check that this phase does not ship — BLOCKING

`.specify/memory/constitution.md:213-214`:

> **What is verified, and what is not**: `scripts/enforcement-pack.ps1` grades that a record
> exists, is well-formed, and names the same approver as the commit carrying it.

Present tense, in the top rung of the source-of-truth ladder. At `ced1302` — and at the
branch tip — `scripts/enforcement-pack.ps1` contains no such logic; `Invoke-AmendmentAuthorityCheck`
is phase 2 (plan `:165`, tasks T012–T017, all `- [ ]`). The mirror repeats it:
`docs/sdlc/review-process.md:136-137` ("The machine grades that a record exists and agrees
with its commit").

Three reasons this is blocking rather than a tense quibble:

1. **The commit message asserts the opposite.** "No script change. Reverting everything
   after this phase still leaves a ratified rule enforced by review, which is where
   FitForge stands today." The diff does not leave that — it leaves a ratified rule whose
   own text says a script enforces it. If phases 2–3 are abandoned or reverted, the
   constitution states a falsehood permanently, and the plan's whole phase-1-is-safe
   argument (`plan.md:39-41`) rests on the claim the diff contradicts.
2. **It is the exact failure the feature exists to end.** `spec.md:44-45`: "an unenforced
   law that people believe is enforced is worse than an absent one." FitForge's paragraph
   was titled "Enforcement, honestly stated" and said plainly "this clause is enforced by
   review, not by machine" (`fitforge/...:97`). The kit replaced honest under-claiming with
   an over-claim, in the paragraph whose entire job is honesty.
3. The SYNC IMPACT header discloses the sequencing (`:20-23`), but a header comment is not
   the law, and adopted projects re-express the clause, not the header.

*Action: implementer — make the tense match reality until phase 2 lands. E.g. "`scripts/enforcement-pack.ps1` grades (from this feature's phase 2 onward) …" plus one sentence of FitForge's honesty — "until that check exists, this clause is enforced by review" — and drop it when phase 2 commits. Same fix at `review-process.md:136-137`.*

### F2 — The exemption's boundary is ambiguous in the one case the planned check decides the other way — BLOCKING

`.specify/memory/constitution.md:205-208`:

> a change to `tasks.md` that alters nothing but task completion state — a checkbox moving
> from unchecked to checked — records progress against work already approved and requires no
> approver. Every other change to an approved document is an amendment, including a task that
> is re-worded, re-scoped or re-opened.

I probed the four cases the boundary has to survive. Three are clear: a **re-worded** task
is named explicitly; an **added** or **deleted** task and a **widened Territory bullet** are
caught by "Every other change … is an amendment" (and Territory is named in the headline
list at `:199`). The fourth is not: **un-ticking a box** (`- [x]` → `- [ ]`). It "alters
nothing but task completion state" (exempt) *and* it re-opens a task (`:208`, amendment).
The parenthetical only describes one direction. Two readers land on opposite verdicts, and
so do the law and its own implementation — plan D3 (`:62-64`) strips `- [ ]`/`- [x]`/`- [X]`
from both sides and compares multisets, which **exempts** an un-tick, while `:208` reads as
forbidding it. `spec.md:130-132` resolves "re-opens" as a *text* change, but adopted
projects receive the constitution, never the kit's spec, so the ambiguity is live for the
audience that matters. Phase 2 will bake one reading into the check; better to fix the
sentence than to let the check settle the law.

*Action: implementer — "a checkbox moving between unchecked and checked, in either direction" and disambiguate `re-opened` as "re-opened by changing its text". One line; do it before T014 is written.*

### F3 — The honesty paragraph omits the two things nothing verifies — FR-003 half-delivered — BLOCKING

FR-003 (`spec.md:198-199`) has two sentences: the prohibition, and "**The system MUST state
precisely what it verifies about this and what it does not.**" The clause delivers the
first (`:202`) and not the second. `:213-219` discloses exactly one limit — that the check
cannot verify the named person agreed — and is silent on:

- **The self-approval prohibition itself.** Nothing in the kit can identify "the
  implementing agent": the commit author is the human owner, the model appears only in a
  `Co-Authored-By` trailer, and the record holds a free-text name. So the clause's one
  bolded MUST NOT is graded by nothing at all, and a reader of `:213-214` — which lists
  three things the machine *does* grade, immediately after the MUST NOT — will reasonably
  infer it is covered. That is the same conflation (a rule believed enforced) the feature
  was written to break.
- **The word "approved".** The clause triggers "once a feature's `spec.md` or `plan.md` has
  been approved" (`:197`), but approval is not observable; plan D2 (`:55-60`) proxies it by
  a document's *first appearance*. The consequence is real and immediate for other
  features: revisions made during the spec/clarify loop, **before** the owner approves,
  will be graded as amendments. `spec.md:252-254` records this as an assumption; the law
  does not, so a reader cannot predict when the obligation begins.

*Action: implementer — add two sentences to `:213-219`: (a) "Nothing verifies that the approver is not the implementing agent; that is the human reviewer's judgement (`docs/sdlc/review-process.md`)." (b) "A document is treated as approved from its first commit — the kit has no separate approval token." Both are cheap, and (a) is the FR-003 text that is currently missing.*

### F4 — The reconciliation record mis-describes the one paragraph it leaves unflagged — BLOCKING

`specs/014-amendment-authority/tasks.md:212` records the third and last difference as:

> | Rationale kept near-verbatim, including "quietly conflated" | same | it is the finding
> in one sentence; rewriting it would lose the provenance |

Neither column is true. Comparing `constitution.md:221-232` with
`fitforge/.specify/memory/constitution.md:87-95`: the final two sentences are near-verbatim
("exactly" → "precisely"); the **first half is entirely rewritten**, and the rewrite drops
every element of the provenance the row says it is protecting — the date ("added
2026-09-10"), the source ("after the AI review of feature 001 (governance F3)"), and the
four scripts FitForge names. The kit's version says only "Observed in the field", citing
nothing. It also *adds* material FitForge does not have (the scope-check-by-construction
argument, "five rule changes"). The FitForge column says "same"; the paragraphs are not the
same, and `tasks.md:214` then asserts "No other difference".

This matters because T004/D9 exist for exactly one reader: whoever reconciles the kit's
clause against FitForge's at flow-down. That reader, told the rationale is "the same", will
not diff it — and will either silently lose FitForge's provenance or create a divergence
nobody recorded. T004 is ticked `[x]` (`tasks.md:77`) on a record that is wrong.

*Action: implementer — either restore the provenance sentence into the kit's rationale (cheapest: "Observed in the field — an adopting project's feature 001 governance review, 2026-09-10 (finding F3)"), or correct the table row to state honestly that the rationale's first half was rewritten and what was dropped. Also fix "No other difference" to note the paragraph ordering.*

### F5 — The branch already violates the clause it ratifies, and the fix is deferred one phase too late — BLOCKING

`tasks.md:15-17` declares "This feature is graded by its own rule from phase 1 onward."
Measured against the check the plan specifies (D1 per-commit, D2 creation test, D3 checkbox
exemption, D5 name-in-message):

- **`ced1302` itself** amends `tasks.md` (existed in parent `aa3b194`) by appending the
  reconciliation section and the finding — not checkbox-only, so not exempt — with no
  `**Amendment approved by**` line and no approver in the message. → FAIL.
- **`f49ad61`**, the very next commit, appends the "Phase 1 — gate" section. Same shape. → FAIL.

Neither is repairable later: D5 requires the approver's name **in the commit message**, which
is fixed at commit time, and `tasks.md:190-191` (T027) tells adopters the remediation is "to
record the approver, not to edit history". Yet **T019** (phase 2) requires
"`ritual-checks.ps1` here … green — this branch's own commits must satisfy the rule the
check now grades". As the branch stands, T019 is unsatisfiable.

The recorded finding (`tasks.md:217-245`) sees the class and defers it to **phase 3** under
D3a. The reasoning inside it is sound — I checked resolution (b) independently and the
rejection is correct: a `**Territory**` bullet is a non-task line added without deleting or
modifying anything, so (b) would exempt a widened Territory, one of the five changes SC-002
requires the check to catch. Deferring the *exemption-set* question to replay data is also
right in principle. But the **sequencing** is wrong: the decision is needed in phase 2 (T014
writes the exemption, T019 demands green), not phase 3, and the two failing commits exist
now. One nit on the write-up: the heading "sits outside both categories" (`:217`) is
inaccurate — the clause's catch-all (`:207-208`) puts evidence-recording squarely inside the
amendment category, which the body concedes at `:225-226`.

*Action: implementer + owner — move the decision from phase 3 to phase 2 (amend `plan.md` D3a with its own approver line, which is the ritual this feature installs). Two workable resolutions: grade only commits whose first parent already contains the clause (bounds the rule to "from ratification onward", matching `tasks.md:15-17`'s own wording and clearing both commits), or adopt resolution (a) narrowly. Do not leave it to phase 3.*

### F6 — FR-012's mirror sweep stopped short of the three places that actually instruct an amendment, and of both review templates — BLOCKING

FR-012 (`spec.md:218-220`) requires the amendment be reflected "wherever the kit already
restates the law … so that no document keeps the pre-amendment reading." Four documents
still keep it:

- **`.specify/templates/tasks-template.md:52`** — "Territory may be amended only with owner
  approval and only in a commit made **before** the phase commit that relies on it." This is
  the template every project's `tasks.md` is born from, it is **on the constitution's own
  sync list** (`constitution.md:160`), and a widened Territory is the first example the new
  clause names (`:199`). T005 (`tasks.md:80-83`) is ticked `[x]` on the confirmation "no
  other sync-listed file's reading changed" — that confirmation is wrong.
- **`docs/sdlc/definition-of-done.md:85`** — gate 4: "the territory is amended with owner
  approval in a commit made **before** the phase commit". Same omission, in the gate the
  amendment class most often travels through.
- **`docs/sdlc/review-process.md:65-66`** — step 4: "amend the phase's **Territory** in
  `tasks.md` (owner approval) in a commit made **before** the re-committed phase."

A developer who follows any of these three literally produces a non-conforming amendment and
goes red on phase 2's check, having obeyed the kit's written instructions.

- **`specs/_templates/human-pr-review-template.md`** gained nothing, though
  `review-process.md:134-138` adds a ninth human-reviewer check and `definition-of-done.md:139-140`
  says of that very template "the template is where the shape lives". The checklist a human
  actually fills in (Technical Review, `:135-139` of the template) never mentions the
  amendment record, so the new obligation is invisible at the moment it is discharged.
  `specs/_templates/ai-code-review-template.md`'s evidence table has the same gap against the
  new gate-5 paragraph (`definition-of-done.md:125-128`).

Note the phase-1 Territory legitimately excludes all five paths — which is why this is a
finding about the *plan's* mirror list (`plan.md:160-171` names no template in any phase),
not about the implementer exceeding scope. Fixing it correctly means amending the Territory
with an approver line, which is the ritual this feature installs.

*Action: implementer + owner — add one clause to each of the three amendment-procedure statements ("…with owner approval, **recorded as constitution I requires**") and one checkbox to each review template; land them under an owner-approved Territory amendment (phase 1 follow-up or an extended phase 4), and update `plan.md`'s file table so FR-012 has a home.*

### F7 — CLAUDE.md restates the clause instead of pointing at it — NON-BLOCKING

`CLAUDE.md:92-96` reproduces the scope list, the normative format token
`**Amendment approved by**: <name>, <YYYY-MM-DD>`, the same-name-in-commit rule and the
exemption — five lines. T006 (`tasks.md:84-85`) asked for "one line … Point at the
constitution; do not restate the clause", and the box is ticked `[x]`. The kit's own rule is
point-don't-restate, and the format token now has two homes in two always-loaded documents.
Today they agree; the failure mode when they stop agreeing is precisely GAP-021 (the
always-loaded document holding the wrong version of a rule), recorded in this repository
three days ago. Non-blocking because the restatement is currently accurate.

*Action: implementer — cut to one line: "Amending an approved `spec.md`, `plan.md`, `tasks.md` or `contracts/` file records who approved it, and you never approve your own amendment (constitution I, Amendment authority)."*

### F8 — "the rule's teeth are that a *silent* amendment becomes impossible" overstates — NON-BLOCKING

`constitution.md:218-219`. With the check in place, an unrecorded amendment becomes *visible*,
not impossible — and a fabricated record (an agent writing the owner's name without asking)
is neither silent nor approved, which the same paragraph concedes two sentences earlier.
"Impossible" is the one absolute in an otherwise carefully hedged paragraph, and the hedging
is what gives the paragraph its authority.

*Action: implementer — "a *silent* amendment stops being possible to make unnoticed" or "the rule's teeth are visibility, not consent". Wording only.*

### F9 — The gate-record commit carries a `phase 1` token — NON-BLOCKING

`f49ad61` ("docs: record the phase 1 gate — owner-run OK on `ced1302`") matches
`scope-check.ps1`'s phase attribution regex (`:139`), so the branch now has two "phase 1"
commits: default (HEAD) mode reports `PASS phase 1 commit f49ad61 (1 file(s))`, and only
`-All` reproduces the `PASS phase 1 commit ced1302 (7 file(s))` recorded at `tasks.md:259`.
Harmless here (both PASS, and CI runs `-All`), but on a Micro feature the same habit would
fold a bookkeeping commit into the 400-line phase total. Outside the reviewed commit; noted
so it is not re-discovered.

*Action: implementer — keep `phase N` out of non-phase commit subjects (e.g. "docs: record the gate for `ced1302`"). No change to this branch's history.*

## Constitution re-check (post-implementation)

**PASS, with the caveats above.**

- **I Specification First** — spec approved 2026-09-13, plan and tasks precede the phase.
  The feature amends I under I's own procedure; F5 is where it does not yet obey its own new
  clause. Engaged, not violated.
- **II Source of Truth** — no ladder change. The clause adds no rung; digests remain
  orientation aids. PASS.
- **III / V** — N/A (single-repo kit; no invariant pack).
- **IV Architecture Consistency** — no new file, no script, no package. PASS.
- **VI Security** — documents only; the record holds names already published in the roadmap
  and review artifacts. PASS.
- **VII External Integration** — N/A. The record's shape is stated in the law before any
  check reads it, which is the ordering VII asks for and D9's whole point. PASS.
- **VIII Testing** — no test surface in a law-only phase; the phase's Independent Test
  (`tasks.md:53-55`) is met on two of its three limbs (`ritual-checks` green; digests match
  markers) and **fails the first**: a reader who knows nothing of this feature can find what
  a conforming record looks like, but is told something untrue about what the kit verifies
  (F1) and is not told the two limits that matter (F3).
- **IX Human Review** — this review is the gate-5 half, produced fresh-context; gate 6 at
  merge.
- **X Controlled Delivery** — one phase, declared `ci-held`, `Gate Batching: none`, evidence
  triplet recorded at `tasks.md:253-259` plus an owner-run gate. The phase is revertible in
  fact; F1 breaks the *stated* revert story, not the mechanics. PASS.

## Test coverage observed

No test surface — law-only phase, by design (plan `:39-41`). The verification available was
machine-check replay, all run read-only for this review:

- `pwsh -File scripts/ritual-checks.ps1` → `RESULT OK` (doc-lint, enforcement-pack,
  scope-check, digests, roadmap-claims all OK; scope-repos and verify-kit `n/a`).
- `pwsh -File scripts/build-digests.ps1 -Check` → `OK (5 digests fresh, 75 markers)` —
  proves the committed digests match their markers and that no marker was added to a
  non-member document.
- `pwsh -File scripts/scope-check.ps1` (+ the `-All` pass inside ritual-checks) →
  `PASS phase 1 commit ced1302 (7 file(s))`.
- `diff` of the kit clause against FitForge 1.1.0's → identical (the D9 fidelity claim, for
  the normative paragraph only).

The fixture set S1–S14 (`tasks.md:24-43`) is phase 2's and was not exercised. Worth flagging
for whoever writes it: **no fixture covers an un-tick** (F2) or **an evidence-section
append** (F5) — the two cases this review found the law ambiguous or self-violating on. Both
should become S15/S16 with verdicts fixed *before* the check is written.

## Residual risk

Concentrated in F1 and F5. F1 puts a false statement in the top rung of the source-of-truth
ladder for the life of the branch, and permanently if phases 2–3 are abandoned — the precise
state `spec.md:44-45` calls worse than having no rule; the fix is one clause and should land
before this branch is pushed again. F5 is the cheapest finding to fix now and the most
expensive to fix later, because D5 puts half the record in an immutable commit message: once
phase 2 is written around the phase-3 deferral, the branch has no green path that does not
involve rewriting history the kit tells adopters not to rewrite. F6 is the one that escapes
this feature entirely if not scheduled — no phase in the approved plan touches those five
files, so FR-012 would ship undelivered. F2, F3 and F4 are all one-to-three-sentence edits to
text this branch already owns; none needs new design, and each needs its own
`**Amendment approved by**` line, which is a useful rehearsal of the rule under review.
