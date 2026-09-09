# AI Code Review — 010 Law Digests, Phase 3 (the sweep)

**Reviewer**: fresh-context general-purpose subagent (Claude Fable 5, claude-fable-5)
**Date**: 2026-09-09
**Branches**: agentic-sdlc-kit `010-law-digests` (tip `0f4da69` — the commit under review; also the declared batch end, phases 1–3, ci-held)
**Scope reviewed**: full commit diff of `0f4da69` (`git show`, 4 files, +71/−4); the entire
current CLAUDE.md Task-Scoped Reading section and the entire updating.md §1–§4 read in
context (not only the hunks); governing docs
`specs/010-law-digests/{spec.md,plan.md,tasks.md,research.md,data-model.md,quickstart.md,contracts/digest-checks.md}`;
`scripts/build-digests.ps1`, `scripts/update-kit.ps1`, `scripts/ritual-checks.ps1`, and
`kit-manifest.json` read in full to verify every machine claim in the flow-down note;
`docs/digests/adoption-digest.md` read in full. Live runs:
`build-digests.ps1 -Check -Root <kit>` → `digests: OK (5 digest(s) fresh, 68 marker(s))`,
exit 0 (proves the note's fenced marker example is not harvested — the committed adoption
digest holds exactly its 9 real bullets); full `ritual-checks.ps1` → `RESULT OK`
(doc-lint OK "every referenced path resolves", enforcement-pack OK, scope-check
`PASS phase 3 commit 0f4da69 (4 file(s))`, digests OK); one seeded scratch simulation of
an adopted project immediately after a post-010 `update-kit.ps1` apply (verbatim pack
docs + digest-packs.json present, surgical docs unmarked, no digest files) →
`digests: RESULT FAIL (4 issue(s))`, exit 1 (F1's evidence). W4 authority sweep: grep
`digest` (case-insensitive) across the whole tree — hits only in the five sdlc pack
documents (marker comments, non-rendering), the five generated digests, CLAUDE.md,
adoption/updating.md, docs/roadmap.md, the scripts, kit-manifest.json, and the 010 spec
dir; zero hits in AGENTS.md, README.md, `.specify/**`, `specs/_templates/**`,
`docs/rulebooks/**`; constitution untouched.
**Feature contract**: plan.md phase 3 row — CLAUDE.md reading-table orientation pointers,
updating.md flow-down note, roadmap flip; Territory = CLAUDE.md, adoption/updating.md,
docs/roadmap.md (spec dir exempt); FR-006/FR-009 (digest never a rung, never satisfies
read-first, always-load row unchanged), SC-004; no script/manifest/constitution change.

## Reviewer Provenance

- **Reviewer**: fresh-context general-purpose subagent (separate context; second-model review lane) — Claude Fable 5 (claude-fable-5)
- **Implementer**: the agent session that produced commit `0f4da69` (unknown to this reviewer beyond the commit metadata)
- **Inputs provided**: review instructions naming the commit sha only; spec.md, plan.md, tasks.md, research.md, data-model.md, quickstart.md, and contracts/digest-checks.md read from the repo; the phase diff via `git show 0f4da69`
- **Attestation**: This reviewer did not produce the diff under review.
- **Context**: this reviewer was given only the review instructions and read the spec/plan/contract from the repo; no implementation conversation or reasoning was shared.

## Verdict

**REQUEST CHANGES** — the two pointer insertions are structurally clean (both render
checks pass; the phase-2 F1 table-severing class does not recur), the authority rule is
stated correctly everywhere it now appears, scope is exact, and every machine check is
green on the kit. But the flow-down note's central operational claim — "**Everything is
inert until you opt in**" — is false on the exact path the note governs, and I reproduced
the failure: the same `update-kit.ps1` apply that delivers the generator also delivers the
kit's marker-bearing **verbatim** pack documents (DoD, flow, branch-strategy,
team-workflow, critical-delivery, updating.md itself), so the adopted project's very next
`ritual-checks` run FAILs with four missing digests before the adopter has "opted in" to
anything (F1). The machine is behaving exactly as contracted (C5: markers without a
digest FAIL); it is the shipped adoption story that misdescribes it — the precise
"summary that quietly disagrees with the law" failure class this feature exists to kill,
landing in a verbatim-class instrument at the declared batch end. The fix is a
documentation amendment (make generate-and-commit a required step of the flow-down
commit), not a machine change. Everything else found is nit/observation grade.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-006: CLAUDE.md's "Orientation first (optional)" paragraph offers all five digests as the orientation read and keeps full documents as the acting read; the always-load row (line "Any phase (always)") is byte-identical to the pre-phase version and the paragraph explicitly says digests never replace it. FR-009: authority rule stated in bold ("never a source-of-truth rung and never satisfies a 'read first' obligation"), matching the digest headers and the updating.md note's closing bullet. SC-004: holds to the letter for a truly marker-free tree (C1/kit phase-1 record) but see F1 for the delivered-configuration contradiction. |
| W4 authority sweep (FR-009 beyond the diff) | Grep of every shipped instrument: no instrument presents a digest as a ladder rung or as satisfying read-first when acting. CLAUDE.md pointer, all five digest headers ("Non-authoritative … source documents prevail (constitution II is unchanged)"), and the updating.md note's final bullet all state the subordination; constitution II untouched (no `digest` hit in `.specify/memory/constitution.md`); AGENTS.md/README/templates carry no digest mention at all. Roadmap's GAP-014 row wording ("full doc read only when acting on that area") predates this phase and is consistent with the acting-read rule. |
| W2 note accuracy vs the actual machine | (a) `scripts/build-digests.ps1`, `docs/digests/digest-packs.json`, `scripts/*.ps1` (hence ritual-checks) are all `verbatim` in kit-manifest.json — "arrive verbatim" TRUE. (b) `generated` class: update-kit.ps1 builds work lists from classes `verbatim` and `surgical` only (lines 155–156) — `docs/digests/*-digest.md` is never copied, never reported; the §1 report table's "(never listed)" row exists — TRUE. (c) n/a wording: script line 214 prints exactly `digests: n/a (no digest markers)`; ritual-checks echoes the member's own n/a reason into the summary — TRUE as a string, but the *precondition* is unreachable via the normal update path (F1). (d) Fence exclusion: extractor opens a fence on `^\s{0,3}(`{3,}|~{3,})` and skips everything to the close; the note's example sits in a 2-space-indented ```` ```markdown ```` fence inside a bullet — live check on the kit stays `OK (5 digest(s) fresh, 68 marker(s))` with the example present, and the committed adoption digest carries only its 9 real markers — TRUE. (e) Bounds 40/120 match `MaxDigestContentLines`/`MaxDigestLineLength`; "standalone line, exact lowercase grammar, outside HTML comment blocks and code fences; a near-miss line fails rather than vanishing" matches the `-cmatch '^\s*<!--\s*digest:(.*)-->\s*$'` extraction plus the malformed-marker fail-closed branch — TRUE. One member-list slip: F2. |
| Markdown structure (phase-2 F1 render class) | CLAUDE.md: the new paragraph sits between the section intro and the table with blank lines on both sides; the table's 13 rows are contiguous and intact. updating.md: the note is its own `###` subsection ending immediately before `## 3.`; the §1 report table (including the "Adoption doctor" row restored by the phase-2 fix) is intact; the fenced example and its continuation paragraph are correctly indented list-item continuations. No new double-blank-line sites in the diff. |
| Feature contract held | Diff adds prose to two instruments, flips one roadmap cell (`specified` → `in progress`, nothing else on the row), and records W1–W4 + checkbox flips in tasks.md. No script, manifest, kit-manifest, constitution, or digest change (all five digests byte-identical — check OK without regeneration). |
| Scope guard | `scope-check: PASS phase 3 commit 0f4da69 (4 file(s))`; changed files = exactly the three Territory files + `specs/010-law-digests/tasks.md` (spec-dir exempt). `git show --stat` read for intent — nothing unrelated. |
| doc-lint / pointer reachability | doc-lint `OK — every referenced path resolves` (the five backticked digest paths exist in the kit). Adopted-project reachability reasoned: CLAUDE.md is surgical-class, so this text never auto-flows to an existing project (it arrives only as a surgical-report commit to hand-mirror — and doc-lint in that project would fail a hand-added pointer whose digest files don't exist yet, a self-correcting loop); a fresh adoption by copy takes the whole tree including the kit's digests, which match its then-identical documents. No broken-pointer path found. |
| Batch / ci-held mode consistency | Plan declares `Gate Batching: phases 1-3` + `Gate Certification: ci-held` before phase 1; Standard feature — eligible under constitution X; T011 instructs reporting the push-event evidence triplet at batch end and requesting owner approval; roadmap flip is to `in progress` (not `shipped`) — correct pre-merge. Nothing in the commit contradicts the plan's Constitution Check. |
| Rollback safety | Pure prose + one table cell + spec-dir bookkeeping; reverting `0f4da69` restores the pre-sweep state with no digest or machine impact. |

## Findings

### F1 — "Everything is inert until you opt in" is false on the update path the note governs — blocking

`adoption/updating.md` (the new note, third bullet) promises: "with no markers in your
documents and no digest files, the `digests` member reports `n/a (no digest markers)` and
changes no verdict. Opt in by adding markers…". But six of the ten pack documents are
**verbatim-class** (definition-of-done, flow, branch-strategy, team-workflow,
critical-delivery, and updating.md itself), and since phase 2 the kit's copies carry
markers — so the same `update-kit.ps1` apply that delivers the generator also delivers
marker-bearing documents. `build-digests.ps1 -Check` treats markers-without-digest as
FAIL (contract C5, by design), and digest files never flow (`generated` class). Reproduced
on a seeded scratch target shaped exactly like a post-update adopted project (kit verbatim
docs + digest-packs.json, surgical docs unmarked, no digests):

```
digests: FAIL - missing digest: docs/digests/delivery-digest.md - its pack's documents carry markers; regenerate: ...
digests: FAIL - missing digest: docs/digests/branching-digest.md - ...
digests: FAIL - missing digest: docs/digests/critical-digest.md - ...
digests: FAIL - missing digest: docs/digests/adoption-digest.md - ...
digests: RESULT FAIL (4 issue(s))   [exit 1]
```

The adopter's next ritual-checks run (their CI check) fails before any opt-in decision,
and neither the note, §1's "Commit the run" step, nor the update-end doctor (which does
not run ritual-checks) warns them. This also contradicts spec US3 acceptance scenario 2
("**Then** nothing fails") in the configuration actually delivered, and hollows SC-004
(its letter holds only for a tree the update channel can no longer produce). The failure
is loud and self-describing (each line names the exact fix command), so the *machine* is
fail-safe — but the shipped verbatim adoption story materially misdescribes it, which is
this feature's own named enemy: a summary that disagrees with the law it summarizes.
*Action: implementer — amend the note before the batch-end evidence is reported: state
that the kit-standard verbatim documents arrive already marked, so the flow-down commit
MUST include running `pwsh -File scripts/build-digests.ps1` and committing the generated
digests (opt-in then means *extending* markers into your own surgical law, not activating
the machine); mirror one line in §1's "Commit the run" step if the owner agrees. Flag the
US3-AS2/SC-004 tension to the owner for disposition at approval (spec wording vs delivered
behavior) — do not silently rewrite the spec.*

### F2 — Surgical-member parenthetical omits repository-strategy.md — nit

The note says "gate-command, review-process, and rollback-process are your surgical
copies, so you are marking your own law" — but `docs/sdlc/repository-strategy.md`
(branching pack member) is also surgical per kit-manifest.json, the fourth of four. As
written the list implies the other seven members are kit-owned, undercounting the "own
law" surface by one and slightly reinforcing F1's framing.
*Action: implementer — add repository-strategy.md to the parenthetical (fits the line);
can ride the F1 fix.*

### F3 — No-amendment note filed under "When the surgical report names the constitution" — nit

The 010 note opens "**No constitutional change is involved** … there is nothing to
re-express", yet sits as the final `###` of §2, whose premise is a surgical report naming
the constitution and whose procedure (re-expression) explicitly does not apply. The 008
and 009 notes live there because they ARE amendments. Readers scanning §2 for amendment
work will find a note telling them the section doesn't apply; readers of §3 (where
non-constitutional surgical guidance lives) won't find it.
*Action: implementer/owner — either move the note to §3 or accept placement for series
continuity ("all flow-down notes in one place") with no text change; a one-line rationale
in the disposition suffices.*

### F4 — The "whole adoption story" names no CLAUDE.md mirror for the orientation pointer — should-fix

The 008 and 009 notes each enumerate the hand-applied mirrors, ending "…and CLAUDE.md".
The 010 note — which declares itself "the whole adoption story" — never mentions that the
Task-Scoped Reading orientation paragraph (this phase's FR-006 instrument) is
surgical-class and reaches an existing project only by hand-mirroring from the surgical
report on CLAUDE.md. A project that opts in per the note gets working digests that no
instrument points its agents at. The surgical report will list CLAUDE.md's commit, so the
channel isn't silent — but the note's own completeness claim is what breaks.
*Action: implementer — one bullet or clause: "optionally mirror the CLAUDE.md
'Orientation first' paragraph into your own CLAUDE.md once your digests exist"; can ride
the F1 fix.*

### F5 — CLAUDE.md hand-restates pack composition, unchecked — nit

The new paragraph enumerates digest→member mappings ("delivery-digest.md (DoD +
gate-command + flow)", "branching-digest.md (branch/repository strategy + team
workflow)", …). Pack composition's single source is `docs/digests/digest-packs.json`
(FR-002 "declared in exactly one place"); this prose duplicate is exactly the
stale-restatement class the feature's Problem section indicts, and no machine check
covers CLAUDE.md prose (it is deliberately not a pack member). A future pack
recomposition will drift this paragraph silently.
*Action: none required now (the mapping is correct today); owner may prefer trimming the
parentheticals to bare digest names, trading a little orientation for zero drift surface.
Record the choice.*

### F6 — "a digest is always current with its law" mildly overstates — observation

The CLAUDE.md paragraph reasons "CI fails on any drift, so a digest is always current with
its law." Strictly, that holds on any tree where ritual-checks is green — locally a digest
can be stale until the check runs. The claim's purpose (trust the digest for orientation)
is legitimate and the same sentence's bolded authority rule dominates, so no behavioral
risk; the digest headers themselves phrase it more carefully.
*Action: none.*

### F7 — Plan said "reading table orientation column"; delivered as a preamble paragraph — observation

plan.md's Source Code section describes the CLAUDE.md change as "reading table orientation
column"; the implementation is a paragraph above the table (the plan's own Phases row
says "orientation pointers", and T009 says "offered as the orientation read" — both
satisfied). The paragraph form keeps the table small and the always-load row literally
untouched; FR-006's substance is met. Noted only as a plan-wording deviation.
*Action: none.*

## Constitution re-check (post-implementation)

PASS with F1 outstanding. **I** — sweep executed under the approved spec/plan/tasks.
**II** — no ladder change; every instrument that mentions digests subordinates them
(verified by tree-wide sweep); the conflict F1 names is between a shipped doc and machine
behavior, which the kit's own conflict rule says to report, not silently resolve — hence
the owner-disposition action. **IV** — no new patterns; prose only. **VIII** — W1–W4
recorded in tasks.md; I reproduced the load-bearing verdicts live (ritual-checks RESULT
OK, digests OK 5/68, scope PASS 4 files) and extended W2's verification to the seeded
adopted-project simulation the record lacks (which is how F1 surfaced). **IX** — pending
at merge, as designed. **X** — one phase, one commit, `phase 3` token; ci-held + batching
declared in the approved plan before phase 1; this is the batch end, so the F1 fix must
land as a further commit on the branch **before** the evidence triplet is reported —
under ci-held the owner approves on the batch-end commit, and certifying an adoption
story known to be wrong would put the owner's recorded approval on misinformation.

## Test coverage observed

No test framework (kit convention). Phase-appropriate validation = the W1–W4 record in
tasks.md: W1 and W3 reproduced exactly (paragraph text, always-load row unchanged,
roadmap cell, RESULT OK); W4's authority sweep reproduced tree-wide with zero authority
leaks found, and its render spot-checks confirmed (both insertions structurally sound —
the phase-2 defect class did not recur). The gap is in W2's power: it verified the note's
claims against the *kit's* state (where markers and digests coexist, so the check is OK)
but never against the state the note actually describes — an adopted project right after
the update — which is a four-command simulation and FAILs (F1). Same shape as phase 2's
lesson (a green checklist that never exercised the failing dimension).

## Residual risk

Concentrated in F1 until the note is amended: every adopted project that runs the next
update will hit a red CI on the flow-down commit while holding a verbatim document that
told them nothing would change. The failure is loud, exactly diagnosed, and one command
from green, so the cost is confusion and trust, not wrong law — but trust in shipped
instruments is precisely this kit's currency, and the note flows verbatim everywhere.
After F1 (with F2/F4 riding along), residual risk is the unchecked CLAUDE.md pack-map
prose (F5), which is drift-latent rather than wrong. Batch-end reminder: under the
declared ci-held mode, report the push-event ritual-checks triplet only after the fix
commit, and let the owner also disposition the US3-AS2/SC-004 wording tension.

---

## Dispositions (implementer — appended after the review; reviewer text above unedited)

| # | Disposition |
|---|---|
| F1 | **Fixed (blocking).** The note's inertness bullet replaced with "The flow-down includes generating your digests": the kit's verbatim pack docs carry markers down, so the flow-down step is generate + commit the digests with the update; the n/a state is scoped to marker-free trees. The spec tension is amended in place — US3-AS2 and SC-004 now carry the corrected scope, explicitly marked *for owner ratification at batch-end approval* (the certification request names this). The machine itself is untouched: fail-safe, loud, exact fix command — as the reviewer verified. |
| F2 | **Fixed.** `repository-strategy.md` added to the surgical-copies parenthetical. |
| F3 | **Rejected — placement kept, with rationale.** The flow-down notes form a chronological series adopters scan in one place under §2; this note's title states "no constitution amendment" in its first line, which corrects the section's default assumption more reliably than a different filing spot would. |
| F4 | **Fixed.** New "Mirror by hand (surgical)" bullet: the CLAUDE.md orientation paragraph must be hand-mirrored (as with the 008/009 mirrors), or the digests exist with nothing pointing agents at them. |
| F5 | **Fixed.** CLAUDE.md no longer restates pack composition; it names the five packs and points at `docs/digests/digest-packs.json` as the single source of composition. |
| F6 | **Fixed.** "always current with its law" softened to "CI fails on any drift — on a green branch a digest matches its law." |
| F7 | **Accepted, no change.** FR-006's substance (per-pack orientation offer, full docs remain the acting read, always-load untouched) is delivered; a preamble paragraph serves the table better than a per-row column that would repeat five times. Recorded here as the plan-wording deviation. |

Post-fix validation: `digests: OK (5 digest(s) fresh, 68 marker(s))` (the note edits add
no markers; digests byte-unchanged), full ritual-checks `RESULT OK`.
