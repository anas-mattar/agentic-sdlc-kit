# AI Code Review — 017 Level Declaration Graded (Phase 1)

**Reviewer**: fresh-context agent — claude-sonnet-5-5
**Date**: 2026-10-11
**Branches**: agentic-sdlc-kit `017-level-declaration-graded` (phase-1 commit `f5bfab9`)
**Scope reviewed**: `git show f5bfab9` in full (8 files: `.specify/memory/constitution.md`,
`.specify/templates/spec-template.md`, `docs/sdlc/critical-delivery.md`,
`docs/sdlc/definition-of-done.md`, `docs/sdlc/branch-strategy.md`,
`docs/digests/critical-digest.md`, `specs/017-level-declaration-graded/notes.md`, `tasks.md`).
Read for context: `spec.md` (FR-001, FR-002, FR-015, assumptions), `plan.md` (D1, D7, D8),
`contracts/level-declaration-contract.md`, `data-model.md`, `tasks.md`, `notes.md`; `CLAUDE.md`;
constitution Principle I (Amendment authority) and X; `scripts/enforcement-pack.ps1`
(`Get-DeliveryLevel`, `Get-VisiblePlanLines`); `kit-manifest.json`; the 016 phase-1 review (house
style). I did not re-read `research.md` line by line.
**Feature contract**: phase 1 = T001-T006, documents only: constitution X Level declaration
(0.7.0 to 0.8.0), template marker and `## Level Rationale`, three mirrors, regenerated digest,
owner approval recorded before phase 2. Territory: constitution, spec template, the three docs,
`docs/digests/**`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-sonnet-5-5
- **Implementer**: claude-sonnet-5-5 (the implementing session)
- **Inputs provided**: commit `f5bfab9` (`git show --stat` and full diff); the 017 feature
  documents (`spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/`, `tasks.md`,
  `notes.md`); the kit's law (`CLAUDE.md`, constitution, Definition of Done, review process); the
  review template and the 016 phase-1 review for style; read and run access to the working tree.
  No repository file other than this review was modified.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**APPROVE with follow-ups.** The phase does what T001-T006 say and nothing else: documents only,
inside Territory, with the owner's approval recorded before phase 2. The four trigger keys, the
marker, the verdict words, the Critical-because rule, the "Critical is never failed by the floor"
rule and "unarmed project unaffected" agree across the constitution, template, mirrors, spec,
plan, data model and contract. The new template text reads safely under the kit's own readers.
There is no Blocker. The follow-ups are wording: two present-tense statements say a check "fails"
something that phases 3-4 have not built, one of them (the Definition of Done) is also wrong for
a spec that predates the marker; and the Surface Exception line shape lives only in a feature
contract that adopters do not receive.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FR-001, FR-015, US2 groundwork) | FR-001: template carries the block with the four keys, verdict alternatives, and reason placeholders (`spec-template.md` Level Rationale section). FR-015: the sync-list line now names the four keys and the `**Rationale Rule**` value (`constitution.md` sync block, "scripts/enforcement-pack.ps1 (encodes constitutional constants..."), and the DoD gate 1 names the rationale and the check. Nothing required of phase 1 is missing |
| Visual-reference match | N/A. No UI |
| Feature contract held | No script, package, schema or test touched. `git show --stat f5bfab9`: 8 files, all in Territory or the feature's own progress files |
| Constitution / domain invariants | Version line and Last Amended: `**Version**: 0.8.0`; sync report header `0.7.0 → 0.8.0`; the report says 0.8.0 throughout; no other principle's text changed (the constitution hunks are the report head, one sync-list line, the Principle X addition, and the version line only). The old 0.6.0 to 0.7.0 report is preserved under "Prior version history". Amendment record: see F5 |
| Cross-document consistency | Keys `domain-invariants`, `irreversible-data`, `authn-authz-payment`, `auditable-evidence` identical in constitution, template, `critical-delivery.md`, contract section 2 and data model. Marker `**Rationale Rule**: 1` identical in clause, template, plan D7, data model, contract. Verdicts `applies` / `does not apply` identical. Critical-because rule, Surface Exception plus approver, "never failed by the floor", and "unarmed project unaffected, floor reported as not armed" match plan D1 and contract sections 1-3 |
| Reader safety | I extracted `Get-DeliveryLevel`, `Get-VisiblePlanLines` and `ConvertTo-VisibleText` from `enforcement-pack.ps1` and ran them on the new template. `Get-DeliveryLevel` still returns `[Lite | Micro | Standard | Critical]`. Visible text keeps `**Rationale Rule**: 1 ` (with a trailing space) and `**Input**: ... "$ARGUMENTS"`; the two multi-line comments are fully stripped; the `**Critical because**:` placeholder line and the four bullets stay visible, as designed. No `-->` is misplaced and no comment holds a backtick or a nested opener |
| Kit checks | `pwsh -File scripts/scope-check.ps1`: `PASS phase 1 commit f5bfab9 (8 file(s))`. `scripts/doc-lint.ps1`: `OK — kit complete, every referenced path resolves`. `scripts/build-digests.ps1 -Check`: `digests: OK (5 digest(s) fresh, 84 marker(s))` |
| Sync-report comment | The report sits in one HTML comment closed by the existing `-->` at `constitution.md:205`; the inserted block holds no `-->` and no `--` run (searched: the only `-->` in lines 1-205 is that closer; the other hits at 303 and 334 are separate comments). The em dashes and the arrow are single characters |
| Digest hygiene | New marker at `critical-delivery.md` after "The level is a written claim"; generated line is 118 characters, under the 120 bound. `docs/digests/critical-digest.md` gains exactly one line; `adoption-digest.md` is untouched (not in `--stat`). The branch-strategy and DoD edits add no marker and leave existing markers in place |
| Scope guard | `scope-check` PASS above; `--stat` read for intent: 122 insertions, 11 deletions, all documents |
| Rollback safety | Documents only. Reverting restores 0.7.0 and the old template together; nothing else depends on the marker yet |
| `git show f5bfab9 -- specs/` | Only `tasks.md` (six `[ ]` to `[x]` flips, no other text change) and `notes.md` (a section appended under the existing `## Phase 1` heading). `spec.md`, `plan.md` and `contracts/` are unchanged: no amendment, no approver needed |
| Honesty of claims in notes/tasks | `notes.md` does not claim the gate passed: "the user-run gate exit code ... had not been reported ... is the owner's to certify ... not claimed here." Task ticks are progress only. The baseline suite count (899/0/0, 726 s) is on `b82e362` and I did not re-run it (about 12 minutes; no specific reason to) |

## Findings

### F1 — The Definition of Done mirror says a check "fails an absent rationale" that the design exempts, and says it in the present tense — MINOR

`docs/sdlc/definition-of-done.md` (gate 1 addition): "`scripts/enforcement-pack.ps1` fails a
rationale that is absent, incomplete or contradicts the level, and a Standard or Micro Territory
that reaches a critical surface the project declared." Two problems. (a) Phases 3-4 have not
built these checks, so on the branch tip the sentence describes the future. (b) A spec without
`**Rationale Rule**: 1` has no rationale and is not failed (plan D7, data model "marker absent:
nothing"); the constitution says so ("one that predates the rule does not [owe it]"), the DoD does
not. A reader who takes the DoD alone would think every spec without the block fails. The same
tense issue touches the constitution ("`scripts/enforcement-pack.ps1` grades all of this") and
the digest line ("a sub-Critical Territory on a declared surface fails"). The constitution and the
sync report do frame the machine half as landing "in this same feature's later phases on the same
branch", so the whole merged result is true; the DoD and digest lines carry no such framing.
Within phase 1 to fix. Fix: in the DoD, add "on a spec that carries the `**Rationale Rule**`
marker" after "absent" (or rewrite as "fails, on a spec carrying the rule's marker, a rationale
that is..."). Optionally keep present tense, since it is correct at merge, and rely on the
constitution's "later phases" sentence. Do not touch it if the owner prefers the merged-state
voice, but the marker qualifier is a real accuracy fix.
*Action: implementer adds the marker qualifier to the DoD sentence in this phase or a follow-up
before merge; the tense question is the owner's call.*

### F2 — The Surface Exception line shape is defined only in a file adopters do not receive — MINOR

The exact strings a machine will read, `**Surface Exception**:` and `**Exception approved by**:`
(`contracts/level-declaration-contract.md` section 2, `data-model.md`), appear in no shipped
document. The constitution says only "a per-path statement with a recorded approver"
(`constitution.md:435-436`); `critical-delivery.md` and `branch-strategy.md` say "approved
Surface Exception" without a shape. The template comment points to "contracts/level-declaration-contract.md,
section 2 of feature 017" (`spec-template.md`, comment under `## Level Rationale`), but
`kit-manifest.json` ships `.specify/templates/**` and `specs/_templates/**` as verbatim and the
feature directory is not shipped, so in an adopted project that pointer resolves to nothing
(`doc-lint` passes because the reference sits in prose inside a comment, not as a resolvable path
token). An adopting agent asked to "record a Surface Exception" has no shipped description of how.
T002 asked for this pointer, so the diff follows its task; the defect is in the plan's choice of
home. Within phase 1 to fix. Fix: add two example lines (the two strings, the backticked path,
the `<name>, <YYYY-MM-DD>` form) to `critical-delivery.md` under "The level is a written claim",
or to the template's comment, and let the contract pointer remain as a kit-side reference.
*Action: implementer adds the shape to a shipped document in this phase (it is a mirror of the
contract, not an amendment of it).*

### F3 — The template's `**Critical because**:` line and bracketed verdicts are visible placeholders; the data model never says how a reader treats them — MINOR

The visible text of the template keeps `**Critical because**: [why this feature is Critical
regardless]` and four bullets whose verdict is the literal `[applies | does not apply]` (confirmed
by running the kit's own `Get-VisiblePlanLines`). The data model defines the reason as "at least
one word after the dash" and the verdict as `applies` or `does not apply`. A placeholder satisfies
"at least one word", the verdict placeholder contains both verdict words, and each reason
placeholder holds two further em dashes, so a reader that splits on the first dash or matches a
verdict substring could read an unfilled template as answered, or a Critical spec that left
`**Critical because**:` untouched as justified. The marker line also carries a trailing space in
visible text (`**Rationale Rule**: 1 `), so an exact-match reader would miss it. None of this can
fail today. It is a phase 3 reader-design point the law cannot settle later without another
amendment, because the template text is the shipped surface. Not a phase-1 fix to the template;
a note for phase 3 and the plan's reader. Optional phase-1 improvement: nothing.
*Action: carry into phase 3 as requirements for the reader: anchor the verdict at the start of the
text after the colon, treat a `[`-led verdict or reason as unfilled, treat a `[`-led Critical
because as absent, and trim the marker line.*

### F4 — The clause says a "numbered feature" carries a rationale, then limits it to marked specs; Micro's position is implicit — NOTE

`constitution.md:429`: "A numbered feature's `spec.md` carries a **Level Rationale**". A Micro
feature's `spec.md` comes from `micro-spec-template.md`, which this phase leaves unchanged and
which carries no marker, so a Micro feature owes none and meets only the surface floor (spec FR-002
says "Standard or Critical"). The next-to-last sentence of the clause restores this ("A
specification that carries the rule's marker ... owes the Level Rationale; one that predates the
rule does not") but never names Micro, and "a Standard feature MUST NOT answer *applies*" does not
cover a Micro feature that does so. No machine check is ambiguous (the marker decides), but a human
reader may take Micro to owe a block. Outside phase-1 necessity; decide in a later phase whether
the micro template stays unmarked, and consider one clause naming it.
*Action: owner decision at the next amendment or at ship; no phase-1 change required.*

### F5 — The amendment approval is recorded in prose, not in the `Amendment approved by` shape — NOTE

Constitution I's `**Amendment approved by**: <name>, <YYYY-MM-DD>` line governs a feature's
`spec.md`, `plan.md`, `tasks.md` and `contracts/`, not the constitution, so the form is not
required here. The record is: sync report, "the owner's approval (anas.m, 2026-10-11, at the
feature's phase 1 gate, task T006)"; commit message, "Amendment approved by anas.m, 2026-10-11";
`notes.md`, T006 paragraph. All three name the same approver and date, and the approver is not the
implementing session. What I could not verify is that the approval happened: no machine reads the
constitution's record, and the commit message is the implementer's own statement. That is the
known limit the clause itself states for approvals; the human reviewer at gate 6 should ask the
owner. The report says the approval was given "at the feature's phase 1 gate", while `notes.md`
says the gate exit code had not been reported at commit time; those are different events (approval
of the amendment at T006 versus certification of the gate) and the text keeps them apart.
*Action: none in this phase; the owner confirms at human review.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None** to the feature's own approved documents. `spec.md`, `plan.md` and `contracts/` are
unchanged by `f5bfab9`; `tasks.md` changes are checkbox flips only (progress, no approver
needed). `notes.md` is not an approved document under constitution I. The constitution itself
was amended in this commit; that amendment is the subject of the phase and is discussed in F5.

## Constitution re-check (post-implementation)

**PASS.** Principle I (specification first, amendment authority): the amendment is made before the
machine halves, the owner's approval is recorded, no approved feature document changed except
progress ticks. Principle X: nothing redefined, Micro bounds and the Lite abuse guard unchanged,
Critical never failed by the floor, an unarmed project unaffected. Other principles: no text
changed. The clause is honest about what a machine cannot verify (rationale truth, approver
agreement, self-approval, and the accepted marker omission), which is the property I weighed most
in the item 5 check; the only overclaim is F1's tense and marker omission.

## Test coverage observed

None in this phase (documents only). The checks that cover it: `doc-lint` OK, `digests` OK (84
markers), `scope-check` PASS, and the reader-safety run above. The enforcement harness fixtures
for the new rules (LEVEL-001 to LEVEL-010) belong to phases 3-4. `notes.md` records the
`b82e362` baseline of the 899-case suite; I did not re-run it.

## Residual risk

Concentrated in the wording the later phases will have to match, not in this commit's behaviour.
F1 and F2 should be closed before merge since both are documents that adopters will read. F3 is a
phase 3 design constraint to write down now. Nothing here blocks phase 2, subject to the owner's
certification of the phase-1 gate, which this review does not provide.
