# Implementation Plan: Amendment Authority

**Branch**: `014-amendment-authority` | **Date**: 2026-09-13 | **Spec**: specs/014-amendment-authority/spec.md
**Input**: Feature specification + decisions D1–D10 below
**Gate Batching**: none
**Gate Certification**: ci-held

## Summary

The constitution gains an **Amendment authority** clause in Principle I (D9), adopting the
wording FitForge ratified in its own 1.1.0 rather than writing a rival one, and
`scripts/enforcement-pack.ps1` gains `Invoke-AmendmentAuthorityCheck` to grade it (D1).

The check walks the branch's own commits, not the working tree (D1). For each commit it asks
one question per feature document the commit touched: *did this document already exist in the
commit's parent?* If not, the commit created it and nothing is owed (D2). If it did, the
commit amended an approved document, and the commit must carry a conforming record — an
`**Amendment approved by**: <name>, <YYYY-MM-DD>` line added in its diff, with the same name
in its message (D4, D5). One exemption, and only one: a change to `tasks.md` that alters
nothing but checkbox state is progress, not amendment (D3).

The kit already writes the record by hand — `specs/013-critical-independence-signal/plan.md`
carries three `**Amendment approved by**: anas.m, 2026-09-10.` lines, one per added phase.
The convention flowed back from FitForge and has been in use here since. This feature does not
introduce a format; it makes the format load-bearing.

Constitution 0.6.0 → **0.7.0** (MINOR — a new rule inside an existing principle; no principle
removed or redefined).

## Technical Context

**Language**: PowerShell 7 (the kit's only scripting surface) + Markdown. **Testing**: seeded
fixture repositories under the scratchpad, plus replay over real merged history (D6, SC-002,
SC-004); no test framework — kit convention since 006. **Target**: this repository and, through
the verbatim update channel, every adopted project with no per-project wiring (FR-011).
**Constraints**: zero new dependencies; read-only; `git` plumbing only, no network; the verdict
for a given commit must never change with the calendar (D7).

**Amendment — phase 1 remediation added 2026-09-13.** The fresh-context review of phase 1
(`specs/014-amendment-authority/ai-code-review-phase-1.md`) returned REQUEST CHANGES with six
blocking findings. They are remediated as a second `phase 1` commit rather than a new phase
number: the work corrects phase 1's own output and must not be revertible separately from it.
Three findings reach files outside phase 1's declared Territory, so this amendment widens that
Territory and lands **before** the remediation commit, per the mechanism in
`.specify/templates/tasks-template.md` — a stray file can never be legalised by the commit that
introduces it.

**Amendment approved by**: anas.m, 2026-09-13.

**Phase-sizing**: four phases, each independently revertible. Phase 1 states the law and leaves
the machine untouched — reverting anything later still leaves a ratified rule enforced by
review, which is where FitForge already stands. Phase 2 adds the check, provable on fixtures
with no history involved. Phase 3 proves it against real commits and fixes what that finds.
Phase 4 tells adopters what arrives before it arrives.

## Decisions

**D1 — The check grades commits, not the worktree.** Every other member of the pack grades the
branch's cumulative diff against its base. That is exactly wrong here: the record lives in a
*commit* (its diff and its message), and a cumulative diff has no commit messages and cannot
tell an amendment from a creation that was later edited. `Invoke-AmendmentAuthorityCheck`
therefore enumerates `base..HEAD` and grades each commit against its own parent. This is the
first pack member with per-commit granularity; `scripts/scope-lib.ps1` already resolves the
base, and that resolution is reused rather than re-derived.

**D2 — "Approved" begins at a document's first appearance.** For commit C and feature document
F, if F does not exist in C's first parent, C created it and owes nothing (FR-005). Otherwise C
amended it. The kit has no separate approval token and inventing one would make this a workflow
change rather than an enforcement change (spec, Assumptions). Two consequences, both wanted: a
feature's opening `spec:` commit is never graded, and a branch renumbered by a lost claim race
reads as creation at the new path, because the rename is a delete plus an add (FR-010).

**D3 — Checkbox state is the only exempt change.** For `tasks.md`, strip `- [ ]` / `- [x]` /
`- [X]` markers from the commit's removed and added lines; if the two multisets are then equal,
the commit changed nothing but completion state and owes no record (FR-006). Everything else —
reworded task text, an added or removed task, a widened Territory line, a correction annotation
that reopens a task — is an amendment. The exemption is deliberately the narrowest one a
machine can judge without inferring intent.

**D3a — The exemption set is validated, not guessed.** Phase 3 replays the detector over this
repository's merged history. If it flags a *class* of routine change that no reviewer would call
an amendment, that class is added to the exemption with its reason recorded — as an amendment to
this plan, carrying its own approver line. A one-off flag is not a class and does not earn an
exemption; it earns a judgement recorded in `notes.md` (D3b).

**D3b — Evidence lives outside `tasks.md`** (added by amendment; owner decision on the
phase 1 review, finding F5). Phase results, scenario tables and gate records are recorded in
`specs/NNN-name/notes.md`, not in `tasks.md`. `tasks.md` then holds agreed work and its
completion state alone, which makes the clause true as written: every change to it is either a
checkbox flip or an amendment. This supersedes D3a's deferral **for this question only** — D3a
still governs any other exemption class the phase 3 replay turns up. The kit convention this
changes is documented in phase 4; `notes.md` is already an allowed optional file
(`docs/sdlc/branch-strategy.md`, Spec Directory Contents), so nothing about the structure law
moves.

**Amendment approved by**: anas.m, 2026-09-13.

**D2b — The check binds from when the check exists** (added by amendment; owner decision on
the phase 1 remediation review, finding G2). A commit is graded only if
`Invoke-AmendmentAuthorityCheck` existed before that commit was made. Nothing earlier is
graded, in this repository or in any adopted one.

Three reasons, none of them convenience. The spec's Out of scope already says this feature
does not enforce retroactively. An adopted project's update day must be **silent**, not a day
on which every in-flight branch turns red at once — which is the surprise T027 exists to
prevent, and which no adopter could remedy anyway, because D5 puts half of every record in an
immutable commit message. And this feature's own branch carries two commits (`ced1302`,
`f49ad61`) made after the clause landed but before the evidence convention (D3b) was decided;
without a boundary they fail forever and T019 is unsatisfiable.

The cost is stated rather than hidden: between the clause landing (phase 1) and the check
landing (phase 2) the rule is law and ungraded — the state this feature dislikes — bounded to
one phase, on one branch, and recorded here.

**Amendment approved by**: anas.m, 2026-09-13.

**D4 — One record per commit, not per file.** A single approval covers everything the commit
amends (spec, Edge Cases). The commit's diff across the feature's documents must add at least
one conforming record line. Requiring the line in each amended file would make a plan-plus-tasks
amendment paste the same sentence five times, and a rule that is tedious in its common case is a
rule that gets routed around (GAP-020's lesson, applied before the fact).

**D5 — The commit message must name the same approver.** Presence, not format: the message must
contain the approver's name from the record line, matched case-insensitively after trimming.
This is the half a reviewer cannot fake by editing a file later — the message is fixed at commit
time — and it is why the clause asks for both.

**D6 — A malformed record is no record.** An empty name, an unreplaced `{{SLOT}}`, a `TODO(...)`
marker, a date that is not a real `YYYY-MM-DD`, or a date later than the commit's own author
date all fail (FR-007). Comparing against the commit's author date rather than against "now" is
what keeps a verdict stable: the same commit must grade the same way on every future run, which
is the property 012 established when it resolved Territory as of each code commit.

**D7 — Merge commits are skipped; replayed commits are not special.** A commit with more than
one parent authored none of its content and is skipped outright, so team-workflow rule 6 (rebase
before gate) and rule 8 (merge to main) stay obeyable (FR-010). A rebased commit keeps its
message and its diff, so a conforming amendment stays conforming after replay — no special case
needed, which is the point of putting the record in the commit rather than in a side file.

**D8 — Scope: numbered branches, whatever documents they have.** The check fires only on
`NNN-*` branches and reads `specs/<branch>/{spec.md,plan.md,tasks.md,contracts/**}`. The Lite
lane has no such directory and is untouched; a Micro feature has `spec.md` alone and is graded
on it without the caller special-casing the lane (FR-009).

**D9 — Law first, in its own phase.** The roadmap row states the order and it is not
negotiable: the constitution states the rule (phase 1), the machine grades it (phase 2). The
reverse order would have the kit enforcing something it had not yet ratified — the precise
failure this feature exists to end. The clause adopts FitForge's wording; where the kit's
version must differ it is only to speak in the kit's voice about adopted projects, and the
difference is recorded in `notes.md` so the flow-down reconciles instead of colliding.

**D10 — The check records; it does not authenticate.** It verifies that a name and a date are
present, well-formed, and consistent between document and commit. It cannot verify that the
named person agreed, and in a solo project the approver will be the same human who ran the
session. The clause says this in its own text, the way `docs/sdlc/critical-delivery.md` is
honest about its team arm. When the declared-developer roster (GAP-024) exists, "is this a real
declared person" becomes checkable and slots in without reshaping anything here.

## Constitution Check

- **I Specification First**: spec.md approved 2026-09-13; plan.md and tasks.md exist before
  implementation. This feature amends Principle I itself, in phase 1, under its own rule. PASS.
- **II Source of Truth**: no ladder change. The check reads commits and feature documents;
  nothing is promoted above anything. PASS.
- **III Repository Separation**: single-repo kit. N/A.
- **IV Architecture Consistency**: a new function inside an existing script, reusing the
  existing base resolution (D1). No new pattern, no new file in `scripts/`, no packages. PASS.
- **V Domain Invariants**: the kit's domain is its own governance; no invariant pack. N/A.
- **VI Security**: read-only; no secrets; the record holds names the project already publishes
  in its roadmap and its review artifacts. PASS.
- **VII External Integration Governance**: no external integration. The record's shape is
  documented in the constitution clause (phase 1) before any check reads it (phase 2). PASS.
- **VIII Testing Requirements**: business-critical governance logic — a wrong PASS leaves the
  rule exactly as unenforced as it is today, and a wrong FAIL blocks every branch in every
  adopted project. Deterministic fixtures S1–S14 in `tasks.md`, plus replay over real merged
  history (D3a, SC-002, SC-004). PASS.
- **IX Human Review**: fresh-context AI review per phase + human review at merge. Standard, not
  Critical, so `critical-delivery.md` item 5 does not bind. PASS.
- **X Controlled Delivery**: 4 phases, each independently revertible and testable.
  **Gate Batching: none** — phases 1 and 2 change the law and the machine respectively, and the
  FitForge 001 lesson is that two phases in one push leave one with no CI evidence of its own.
  **Gate Certification: ci-held** — Standard feature, eligible, declared here before any phase.
  The agent reports the evidence triplet and never claims the gate. PASS.

## Project Structure

### Documentation (this feature)

```text
specs/014-amendment-authority/
├── spec.md
├── plan.md              # this file
├── tasks.md
├── ai-code-review.md    # per phase, from specs/_templates/
├── human-pr-review.md   # at merge, from specs/_templates/
└── rollback.md          # from specs/_templates/
```

### Source Code (repository root)

```text
.specify/memory/constitution.md     # MOD  phase 1 — Principle I clause, SYNC IMPACT REPORT, 0.7.0 (D9, FR-001)
CLAUDE.md                           # MOD  phase 1 — Strict Rules: an amendment records its approver
docs/sdlc/review-process.md         # MOD  phase 1 — the reviewer checks the record (FR-012)
docs/sdlc/definition-of-done.md     # MOD  phase 1 — gate 5/6 read the amendment record (FR-012)
docs/digests/*.md                   # GEN  phase 1 — regenerated if a marker moved
.specify/templates/tasks-template.md          # MOD  phase 1R — Territory amendment wording (F6; sync-listed)
specs/_templates/ai-code-review-template.md   # MOD  phase 1R — gate 5 reads amendments (F6)
specs/_templates/human-pr-review-template.md  # MOD  phase 1R — gate 6 judges the approval (F6)
specs/014-amendment-authority/notes.md        # NEW  phase 1R — evidence leaves tasks.md (F5, D3b)
scripts/enforcement-pack.ps1        # MOD  phase 2 — Invoke-AmendmentAuthorityCheck (D1–D8, FR-004)
scripts/scope-lib.ps1               # MOD  phase 2 — base resolution reused, only if a shared helper is needed
scripts/enforcement-pack.ps1        # MOD  phase 3 — exemption set and message wording from replay (D3a, FR-008)
adoption/updating.md                # MOD  phase 4 — what arrives, and what newly fails (FR-011)
adoption/greenfield.md              # MOD  phase 4 — the record a new project will be asked for
docs/digests/*.md                   # GEN  phase 4 — regenerated if a marker moved
```

## Testing Strategy

No test framework — the kit's convention since 006. Two layers, and the second is the one that
matters:

1. **Fixtures (phase 2).** Seeded throwaway git repositories under the scratchpad, each with a
   `specs/NNN-x/` and a commit sequence built to order: creation, conforming amendment,
   unrecorded amendment, mismatched name, malformed date, future date, checkbox-only,
   checkbox-plus-rewording, contracts change, merge commit, renumbered branch, Micro spec-only,
   Lite lane, clean branch. S1–S14 are enumerated in `tasks.md` with expected verdicts and
   re-run at the end of every phase.
2. **Replay over real history (phase 3).** The detector runs over this repository's merged
   feature branches and over FitForge 001's commits. Two obligations: **SC-002** — each of the
   five amendments in finding F3 fails as actually committed; **SC-004** — every other flag is
   one a reviewer judges real. A spurious *class* revises D3 under D3a; a spurious one-off is
   recorded and left flagged.

Behaviour preservation is explicit because this edits a script three projects depend on: the
kit's own `ritual-checks.ps1` stays green at every phase, and every existing pack message stays
byte-identical — the new member only ever adds failures of its own.

## Complexity Tracking

Two things worth naming rather than discovering in review.

**Per-commit granularity is new to the pack (D1).** Every existing member grades a cumulative
diff, and that shape is load-bearing for them. Walking commits costs one `git` call per commit
on the branch; on this kit's longest feature (013, six phases) that is trivial, and on FitForge
002 (seventeen phases) it is still well under the cost of `doc-lint`'s document scan. If replay
in phase 3 shows otherwise, the fix is to batch the plumbing calls, not to abandon the
granularity — without it the commit message is unreadable and D5 dies.

**This feature is graded by its own rule from phase 1 onward.** The moment the clause lands,
any further amendment to this spec, plan or tasks needs its own approver line. That is
deliberate: if the rule is too tedious to obey on the feature that introduces it, it is too
tedious to ship.
