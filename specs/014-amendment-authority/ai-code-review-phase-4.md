# AI Code Review — 014 Amendment Authority, phase 4

**Reviewer**: fresh-context agent — claude-opus-5
**Date**: 2026-09-16
**Branches**: agentic-sdlc-kit `014-amendment-authority` (phase commit `fd07952`; branch tip at review time `0158308`)
**Scope reviewed**: the whole of `fd07952` (8 files) read as a diff and in the tree —
`adoption/updating.md` (lines 280–410 of the working tree), `adoption/greenfield.md`,
`docs/sdlc/branch-strategy.md`, `.specify/templates/tasks-template.md`,
`docs/digests/adoption-digest.md`, `docs/digests/branching-digest.md`,
`specs/014-amendment-authority/{tasks.md,notes.md}`; the preceding Territory repair `3a51f5c`;
and — as the ground truth the prose is graded against — `scripts/enforcement-pack.ps1`
(`Invoke-AmendmentAuthorityCheck` and every helper it calls, lines 641–1185),
`scripts/scope-lib.ps1`, `scripts/scope-check.ps1`, `scripts/update-kit.ps1`,
`kit-manifest.json`, `.github/workflows/ritual-checks.yml`. Not read line by line:
`scripts/doc-lint.ps1`, `scripts/verify-kit.ps1`, `scripts/build-digests.ps1` internals
(exercised via `-Check` only).
**Feature contract**: documentation phase — no script change, no packages, no architecture
change; Standard lane, `**Gate Batching**: none`, `**Gate Certification**: ci-held`
(plan.md:4–5). Phase 4's declared Territory is five entries (tasks.md:396–402).

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5
- **Implementer**: claude-opus-5[1m] (implementing session)
- **Inputs provided**: phase 4 diff `fd07952`, `specs/014-amendment-authority/spec.md`,
  `plan.md`, `tasks.md`; no `contracts/` — the feature has none. No implementer conversation
  or reasoning was provided, and none was requested.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — phase 4 rewrites the adopter-facing prose so it describes the check as
phases 1–3 actually built it, and on the hard parts it succeeds: I executed the renderer-parity
cases, the approval-transition conditions and the boundary against the real
`scripts/enforcement-pack.ps1` in throwaway fixture repositories, and the prose matched the code
on every one of them. Two claims do not survive that treatment, and both are the kind this
feature exists to prevent. `adoption/updating.md:405–407` tells an adopter that when the check
cannot read what it needs "it now says so and fails rather than skipping quietly"; in the exact
scenario that paragraph is about — a depth-1 clone — the check prints nothing at all and the
pack exits 0 (demonstrated below), which is the sentence's own opposite and contradicts both the
paragraph's second sentence and the digest marker two lines beneath it.
`adoption/updating.md:282–287` lists `CLAUDE.md` and `docs/sdlc/review-process.md` as arriving
**verbatim**; `kit-manifest.json:4` and `:16` class both as **surgical**, and
`scripts/update-kit.ps1:12` never writes a surgical path — so an adopter who follows this
section will never hand-mirror the CLAUDE.md strict rule or the gate-5 reviewer check, and will
run a machine that enforces a rule their own agent instructions never state. A third surgical
file changed by phase 1 (`docs/sdlc/repository-strategy.md`) is not mentioned at all. Both are
prose-only fixes inside the existing Territory. Residual risk sits entirely in the flow-down
bullet: everything downstream of it is an adopter acting on a wrong list of files.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | **FR-011** (reaches adopters through the verbatim channel, no per-project wiring): the channel itself is untouched by this phase and `scripts/enforcement-pack.ps1` resolves to class `verbatim` via `kit-manifest.json:40` (`scripts/*.ps1`) — but the *description* of the channel in `adoption/updating.md:282–287` is wrong on two files (F2). **FR-012** (every place the kit restates the law is updated): `.specify/templates/tasks-template.md:14–18` now routes the tests determination to `notes.md`; `docs/sdlc/branch-strategy.md:142,154–164` states the `notes.md`/`tasks.md` split; two law digests regenerated. **US4 scenario 2** ("passes silently on a branch with no amendments"): confirmed on fixture `r2` — the three approval-flip commits produced no output beyond the graded-count line. |
| Visual-reference match (where references exist): Visual Compliance Loop deviation table attached, empty or user-approved (`docs/sdlc/review-process.md`) | **N/A, stated rather than skipped.** `ls specs/014-amendment-authority/` shows no `screenshots/` directory, and `fd07952` changes no UI surface — its 8 files are Markdown prose, one template and two generated digests. The Visual Compliance Loop has no input on this phase. |
| Feature contract held (no unapproved table/migration/permission/package) | `git show --stat fd07952`: 8 files, 288 insertions, 9 deletions. Nothing under `scripts/`, `.github/`, `.specify/memory/`, and no dependency manifest. The plan's Source Code map (plan.md, Project Structure) allots phase 4 exactly `adoption/updating.md`, `adoption/greenfield.md` and `docs/digests/*` — the two extra files (`docs/sdlc/branch-strategy.md`, `.specify/templates/tasks-template.md`) are the T041/T042 pair added by the tasks.md amendment of 2026-09-13 and are declared Territory entries. No script changed: `git show fd07952 -- scripts/` is empty. |
| Constitution / domain invariants | **I (Amendment authority)**: `fd07952`'s only touch of a graded document is six checkbox flips in `tasks.md` — see "Amendments in this diff". **II (Source of truth)**: the new prose is adopter guidance and law mirrors; it promotes nothing above the constitution, and `docs/digests/*` gained four markers that `build-digests.ps1` regenerated (digests are explicitly not a rung). **X (Controlled delivery)**: one phase, one commit, `phase 4` in the subject; `AmendmentAuthority: graded 21 of 30 commit(s)` and `PhaseSizeWarning` silent. The kit has no domain-invariant pack (plan Constitution Check, V: N/A). |
| Security (authn/authz, secrets, sensitive logging) | No code path changed, so no authn/authz surface moved. The prose adds no credential, token, URL or path outside the repository; the only names it publishes (`anas.m`) already appear throughout `specs/` and `docs/roadmap.md`. `git show fd07952 \| grep -i "secret\|token\|password\|key"` returns only the phrase "approval token". Matches plan Constitution Check VI. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | `pwsh -File scripts/scope-check.ps1 -Commit fd07952` → `scope-check: PASS phase 4 commit fd07952 (8 file(s))`. `-All` over the branch: every phase commit PASS, one WARN on `3a51f5c` (below), no FAIL. All 8 paths accounted for: 6 against the five declared entries (`docs/digests/` covers both digests), 2 under the implicit `specs/014-amendment-authority/**`. `pwsh -File scripts/ritual-checks.ps1` → `RESULT OK` (doc-lint, enforcement-pack, scope-check, digests, roadmap-claims all OK). |
| Rollback safety (phase reverts cleanly; schema additive?) | No schema, no migration, no data — a prose phase. `git show fd07952 -- adoption/ docs/ .specify/ \| git apply --check -R -` → clean; the same over `tasks.md` → clean. Only `notes.md` conflicts on a straight `git revert`, because the later gate-record commit `0158308` appended to the same tail; that is evidence, not product, and does not block reverting the phase's four product files. |

**Negative space — what I looked for and did not find.** So the silence is informative rather
than accidental, these were tested and held: (a) the renderer-parity example's four cases, each
executed against the real script in a fixture repository — a visible record counts, a record
below a paragraph that quotes a backticked comment opener still counts, a record inside a closed
comment does not, and an unterminated opener hides what follows; a fifth case I added (an
unterminated opener inside a fenced block) also behaves as the prose says. (b) Every clause of
the approval-transition condition list at `updating.md:321–326` — one differing line, first
`**Status**:` line, outside a fence, `Draft` on the old side, `Approved` plus at most a date, an
`(owner: …)` parenthetical and the template's trailing comment — each matches
`Test-StatusOnlyChange` (`enforcement-pack.ps1:979–1016`) exactly; a `Draft <!-- guidance -->`
old side really is allowed to drop its comment, and `Approved` → `Draft` really is not exempt.
(c) The graded set: `enforcement-pack.ps1:1122–1124` grades only `spec.md`, `plan.md`,
`tasks.md` and `contracts/*` inside `specs/<branch>/`, so the prose's "`notes.md`,
`research.md`, `screenshots/` … are ungraded" is right, and the `notes.md` split that
`branch-strategy.md` and `tasks-template.md` now teach rests on real behaviour. (d) The "what it
does not verify" paragraph (`updating.md:376–384`): nothing in the check links a commit to the
session that produced it, so "that half of the rule is held by review alone" is accurate and not
a hedge. (e) `fetch-depth: 0` is really in `.github/workflows/ritual-checks.yml:28–30`, with a
comment naming per-commit parent reads. (f) No file outside this repository is touched — the
diff is 8 kit paths; `D:\solutions\fitforge` was not read or written at any point in this
review.

## Findings

### F1 — `updating.md:405–407` promises a failure the check does not produce — BLOCKING

The "Give CI the whole history" paragraph ends: *"Where the check cannot read what it needs it
now says so and fails rather than skipping quietly, but the cheapest fix is to not put it in
that position."* That is false in the scenario the same paragraph opens with
(`actions/checkout` at its default depth 1), and it contradicts its own second sentence
("green, and meaningless") and the digest marker at `updating.md:410` ("or it grades nothing and
**looks green**").

Measured, not reasoned. I cloned a fixture repository at `--depth 1` and ran the real script
against it:

```text
enforcement-pack: branch '015-test', diff base '', 0 changed file(s)
enforcement-pack: OK
EXIT=0
```

The `AmendmentAuthority:` line never prints. `Get-DiffBase` (`enforcement-pack.ps1:134–145`)
finds no `origin/main`/`main` and returns `$null`; `Invoke-AmendmentAuthorityCheck` returns at
line 1055 (`if (-not $Base) { return }`) before it emits anything. Silence plus exit 0 — the
precise shape the paragraph warns about.

The partial-clone variant is no better. `Get-CheckPresenceSet` (lines 727–756) was hardened in
review B3 to *fall back* on a `git grep` error exit, not to fail: each unreadable ref simply
never enters the presence set, every commit is then skipped at line 1108, and line 1182 reports
them as *"made before the check existed (plan D2b)"* — an affirmatively wrong reason, still
exit 0. The only path that does fail is the metadata assertion at lines 1072–1076, which fires
when `git rev-list` succeeds and `git log -z` does not — a disagreement a shallow clone does not
produce, since both read the same truncated graph.

Why it is blocking rather than cosmetic: the sentence is the reassurance that makes the
preceding instruction optional. An adopter who wrote their own workflow reads "set it there too"
and then reads that they will be told if they get it wrong. They will not be. The commit message
for `fd07952` states the true behaviour correctly ("Neither presence-set path can read objects a
shallow clone lacks, and grading nothing looks exactly like a legitimately pre-boundary
branch"), and so does the digest marker — only the document an adopter actually reads says the
opposite.

*Action: implementer — delete the final sentence of `adoption/updating.md:405–407` or replace it
with what is true, e.g. that the check cannot detect a shallow clone and will report every
commit as pre-boundary, so `fetch-depth: 0` is the only defence. Prose-only, inside phase 4's
Territory. If a real fail-closed guard is wanted instead, that is a `scripts/` change and a
different phase.*

### F2 — two surgical files are listed as arriving verbatim, and a third is missing — BLOCKING

`adoption/updating.md:282–287`:

```text
Arriving verbatim: `scripts/enforcement-pack.ps1` (the new `Invoke-AmendmentAuthorityCheck`),
`.specify/templates/tasks-template.md`, and the kit-side mirrors in `CLAUDE.md`,
`docs/sdlc/definition-of-done.md`, `docs/sdlc/review-process.md` and
`docs/sdlc/branch-strategy.md`.
```

Against `kit-manifest.json`, which is what `scripts/update-kit.ps1` actually classifies with
(`Resolve-Class`, lines 119–127):

- `CLAUDE.md` — **surgical** (`kit-manifest.json:4`)
- `docs/sdlc/review-process.md` — **surgical** (`kit-manifest.json:16`)
- `scripts/enforcement-pack.ps1` — verbatim (`:40`), `.specify/templates/tasks-template.md` —
  verbatim (`:36`), `docs/sdlc/definition-of-done.md` — verbatim (`:33`),
  `docs/sdlc/branch-strategy.md` — verbatim (`:31`)

`scripts/update-kit.ps1:12` states the consequence plainly: the update "never writ[es] to
surgical-class paths". Both misclassified files carry real phase-1 content: `ced1302` added the
CLAUDE.md Strict Rules bullet ("you never approve your own amendment") and the review-process
human-reviewer check plus a digest marker. An adopter told these arrive verbatim will not
hand-mirror them, and will end up running the machine while their agent instructions and their
gate-5 checklist never mention the rule — the exact "live and unenforced" state spec.md US4
calls "the worst state in the kit".

Two supporting points. First, `adoption/updating.md` already contradicts itself: line 209–211
says the CLAUDE.md orientation wording "is surgical-class; copy the kit's wording into your own
CLAUDE.md". Second, the document's own convention is to flag a surgical item inline — the 012
entry at line 255 reads "`.github/workflows/code-repo-scope-check.yml.template` (surgical — you
copy it)". This bullet was written without that treatment.

Also omitted, and worth the same bullet: `docs/sdlc/repository-strategy.md` — **surgical**
(`kit-manifest.json:14`) — gained the multi-repo twin of the clause in `370a28b`; and
`specs/_templates/ai-code-review-template.md` and `specs/_templates/human-pr-review-template.md`
(both verbatim, `:41`) gained the gate-5/gate-6 amendment prompts in `0803049`, which is what
makes an adopter's reviewer see amendments at all.

*Action: implementer — correct `adoption/updating.md:282–287` to separate what the update writes
from what it only reports: move `CLAUDE.md`, `docs/sdlc/review-process.md` and
`docs/sdlc/repository-strategy.md` into a "mirror by hand (surgical)" clause, and add the two
`specs/_templates/` review templates to the verbatim list. Prose-only, inside Territory. Verify
against `kit-manifest.json`, not against memory.*

### F3 — the approval-transition exemption is described without its document restriction — MINOR

`updating.md:318–326` and `greenfield.md` both describe the exemption as applying to "the
document" / "approving a document in the first place", with no statement of which documents.
The code applies it only to `spec.md` and `plan.md`:

```text
enforcement-pack.ps1:1146
if ($leaf -in @('spec.md', 'plan.md') -and (Test-StatusOnlyChange ...)) { continue }
```

Demonstrated on fixture `r2`, where three commits each flip one document's status line alone:
`spec.md` and `plan.md` pass silently, and

```text
AmendmentAuthority: commit 07f609e amends specs/015-test/tasks.md after approval with no
conforming approver record. …
```

Practical risk is low — neither `.specify/templates/tasks-template.md` nor the plan template
carries a `**Status**:` line, so only `spec-template.md` and `micro-spec-template.md` mandate
the edit, and the code's restriction follows the constitution's own scope sentence ("a feature's
`spec.md` or `plan.md`"). But an adopter whose `tasks.md` carries a status header meets a
failure the document told them could not happen, and the exemption list is exactly where this
phase set out to be exact.

*Action: implementer — add four words to the bullet ("on `spec.md` or `plan.md`"). Optional; may
be folded into the F1/F2 fix rather than carried as its own change.*

### F4 — the "counts" example line would not, in fact, count — MINOR

`updating.md:355` (first line of the renderer-parity block):

```text
**Amendment approved by**: anas.m, 2026-09-13    <- counts
```

`$script:AmendmentRecordPattern` (`enforcement-pack.ps1:651`) anchors at `$` after the date:
`'^\*\*Amendment approved by\*\*:\s*(.+?)\s*,\s*(\d{4}-\d{2}-\d{2})\s*\.?\s*$'`. Anything
following the date defeats it. Executed on fixture `r1`, a commit whose record line carries a
trailing annotation fails:

```text
AmendmentAuthority: commit 8fdb296 amends specs/015-test/plan.md after approval with no
conforming approver record. …
```

The arrows are plainly a margin convention and the canonical record at `updating.md:331` is
clean, so this is not a correctness claim gone wrong — but it teaches the wrong silhouette of a
record whose failure mode is silent, and the kit paid for this lesson one commit earlier:
`3a51f5c`'s own message records that "an explanatory clause appended to [the record] is not a
record at all", after a first attempt failed for exactly that reason.

*Action: implementer — move the annotations off the record lines (a comment column above the
block, or `#`-prefixed lines), or add one sentence noting that the arrows are annotations and
that a real record line ends at the date. Prose-only.*

### F5 — the quoted failure messages are not faithful transcripts — MINOR

`updating.md:339–345` presents two `AmendmentAuthority:` failures as sample output. Neither is
what the script prints:

- Both say "amends **plan.md**" / "its change to **plan.md**". `$files` is built from the
  name-status path (`enforcement-pack.ps1:1159`), so real output names the full path — observed:
  `amends specs/015-test/plan.md after approval`. An adopter grepping their CI log for
  `plan.md` will find it, but one matching the sample shape will not.
- The first sample is elided with `…`; the second silently drops the trailing
  `(constitution I; plan D5)` with no elision mark, so it reads as complete and is not.
- `61c57d5` is used as the sha in both. It is a real commit on this branch — "amend 014: the
  boundary bounds enforcement, not analysis (D2c)" — and it is *compliant*: it carries its
  approver record and passes. Illustrating two failures with the sha of a passing commit invites
  a reader who looks it up to conclude the check is wrong.

*Action: implementer — paste real output (a fixture run is enough), or use an obviously
synthetic sha and keep the elision marks consistent. Prose-only. Low priority against F1/F2.*

### F6 — the "two exemptions" count omits the rename carve-outs — MINOR

`updating.md:314` says "**Two exemptions, both narrow**". Beyond creation, checkbox-only and the
approval transition, `Invoke-AmendmentAuthorityCheck` carries two rename rules
(`enforcement-pack.ps1:1130–1143`): a rename whose old path lies in a *different*
`specs/NNN-*` directory is skipped outright — the renumbered-branch case of FR-010, where
`claim-feature.ps1`'s mandated header edits ride along and the content is *not* identical — and
a rename within the same feature directory is skipped only when the blobs match.

The second is fairly read as the prose's "first appearance is creation" bullet. The first is a
genuine third exemption with no mention anywhere in the new section, and it exempts a document
whose text changed. It errs toward passing, it is rare (a lost claim race), and D2 already
frames renumbering as creation — which is why this is MINOR rather than blocking — but a
document that has just spent a paragraph being precise about exemption counts should either say
"three" or say why the rename case is not one.

*Action: implementer or owner — decide whether to name the renumbering carve-out in
`updating.md` or to leave it to plan D2/FR-010. Either is defensible; the current text quietly
undercounts.*

### F7 — the Territory repair `3a51f5c` is legitimate, and worth recording as an observation — MINOR

Asked to judge the repair this phase sits on, I confirmed it rather than assumed it.

- **The entry list is unchanged.** `git diff 3a51f5c^ 3a51f5c` touches one line only —
  `**Territory** (widened by amendment 2026-09-13 — …):` becomes
  `**Territory**: widened by amendment 2026-09-13 — …` — plus a new explanatory paragraph and
  record. The five backticked bullets are untouched by the diff. The claim in the commit message
  is true.
- **The repair narrows, it does not widen.** `Get-Territory` (`scope-lib.ps1:79`) matches
  `^\*\*Territory\*\*:`, so before the repair phase 4 declared *nothing* and degraded to a
  non-blocking WARN — effectively unbounded. After it, five entries bind. `scope-check.ps1`'s
  anti-widening rule (declaration read as of the parent) is respected: the repair precedes the
  phase commit in its own commit, which is why `fd07952` grades PASS.
- **It is properly recorded.** `tasks.md:410` carries a bare
  `**Amendment approved by**: anas.m, 2026-09-16.` in its own paragraph, and the commit message
  names anas.m — graded live: the branch's `AmendmentAuthority: graded 21 of 30 commit(s)` run
  raises no failure on `3a51f5c`.

The observation: `3a51f5c`'s subject contains the literal token "phase 4", so `scope-check`
treats a `docs:` commit as a phase commit and emits
`scope-check: WARN commit 3a51f5c: no territory declared for phase 4 …`. Harmless here (the
commit touches only `tasks.md`, which is implicitly in territory), already disclosed in
`notes.md` and in the gate record — but it is a second instance of the habit the branch has
twice been bitten by, and the WARN will sit in the merge evidence.

*Action: none for this phase — recorded so gate 6 is not surprised by the WARN in the CI log.
The underlying `Get-Territory` brittleness (a decorated marker silently declares nothing, and a
phase with no declaration WARNs rather than FAILs even when sibling phases declare) is already
written up in `notes.md` as a `scripts/` follow-up; it belongs with the parser work, not here.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None.** `fd07952` touches exactly one graded document, `specs/014-amendment-authority/tasks.md`,
and the change is six `- [ ]` → `- [x]` flips (T026, T027, T028, T029, T041, T042) with no other
text altered — read from `git show fd07952 -- specs/014-amendment-authority/tasks.md`, whose two
hunks contain no non-checkbox insertion or deletion. That is D3's exemption
(`Test-CheckboxOnlyChange`, `enforcement-pack.ps1:932–951`, whole-file comparison with markers
neutralised), and the live run confirms it: `AmendmentAuthority: graded 21 of 30 commit(s)`
raises no failure on `fd07952`. `spec.md`, `plan.md` and `contracts/` are untouched by this
commit. `notes.md` gained 105 lines and is ungraded by design (D3b).

The self-approval prohibition is therefore **not engaged by this phase** — there is no amendment
to approve. It is engaged by the immediately preceding commit `3a51f5c`, whose approver is
`anas.m`, the human owner, named both in the amended section and in the commit message; the
implementing agent did not name itself. Whether anas.m actually agreed is gate 6's to judge —
which is what `updating.md:376–384` and `docs/sdlc/review-process.md` both now say out loud.

## Constitution re-check (post-implementation)

**PASS**, with the two blocking findings being documentation accuracy rather than constitutional
breaches.

- **I Specification First / Amendment authority** — PASS. spec/plan/tasks all predate the phase;
  no amendment made (above). The feature is being graded by its own rule and stayed green.
- **II Source of Truth** — PASS. The new prose sits below the constitution in the ladder and
  cites it rather than restating law; the four new digest markers feed `docs/digests/`, which the
  kit is explicit is not a rung. Note F2 is a *conflict* between two documents
  (`updating.md:282–287` vs `kit-manifest.json`) in which the manifest prevails — reported here
  rather than silently resolved, per CLAUDE.md's conflict rule.
- **III Repository Separation** — N/A (single-repo kit), as planned. Confirmed no other
  repository is touched (T029).
- **IV Architecture Consistency** — PASS. No code, no new file in `scripts/`, no packages.
- **V Domain Invariants** — N/A, as planned.
- **VI Security** — PASS. Read-only prose; no secrets or new surface.
- **VII External Integration Governance** — N/A.
- **VIII Testing Requirements** — PASS with nuance, see below.
- **IX Human Review** — engaged now: this is the fresh-context gate-5 review; gate 6 outstanding.
- **X Controlled Delivery** — PASS. One phase, one commit, `phase 4` token present, size well
  under the warning thresholds (288/9 lines across 8 files vs 400/15), `**Gate Batching**: none`
  honoured, `ci-held` certification reported rather than claimed (the owner-approved triplet for
  `fd07952` is recorded in `0158308`).

## Test coverage observed

No test framework, by plan ("No test framework — the kit's convention since 006"), and a prose
phase adds no assertions. What exists for this phase is executable verification, which I ran
myself rather than inheriting from `notes.md`:

- `pwsh -File scripts/ritual-checks.ps1` → `RESULT OK` across doc-lint, enforcement-pack,
  scope-check, scope-repos (n/a), digests, roadmap-claims, verify-kit (n/a).
- `pwsh -File scripts/build-digests.ps1 -Check` → `digests: OK (5 digest(s) fresh, 80 marker(s))`
  — the non-mutating form, flag name confirmed in the script's parameter block before running.
  The four new markers in `updating.md` and the one in `branch-strategy.md` are present in the
  committed `adoption-digest.md`/`branching-digest.md` and match their surrounding prose; the 80
  count corroborates `notes.md`'s account of the `build-digests.ps1` parser near-miss (79 when
  the syntax example sat in prose, 80 once it was routed into a fenced block).
- `pwsh -File scripts/scope-check.ps1 -Commit fd07952` → PASS; `-All` → no FAIL.
- Two throwaway fixture repositories built under the scratchpad (never inside this repository),
  each carrying a copy of the real `scripts/enforcement-pack.ps1` so the D2b boundary is
  satisfied, run with `-Root` pointed at the fixture: **r1** — eight commits covering a record
  with trailing text (fails), a clean record (passes), a record below a backticked `<!--`
  (passes), a record inside a closed comment (fails), a record below an unterminated opener
  (fails), and a record below an unterminated opener *inside a fenced block* (passes). **r2** —
  approval-transition flips on `spec.md` (exempt), `plan.md` with
  `Draft <!-- guidance -->` → `Approved 2026-09-16 (owner: ada)` (exempt) and `tasks.md`
  (**not** exempt, F3). Plus a `--depth 1` clone of r2 for F1.

The gap worth naming: nothing in the repository tests the *prose* against the code, which is
precisely how F1 and F2 survived to this review. Both would have been caught by running the
scenario each sentence describes, which is a reviewer discipline rather than a test suite.

## Residual risk

Concentrated in one bullet and one sentence, both in `adoption/updating.md`, and both carried by
F2 and F1 respectively. They are dangerous in proportion to how much an adopter trusts the
document: F2 sends a project into an update believing three surgical files will be written for
them, and the failure is silent — the update reports the surgical backlog, they read this
section instead, and their `CLAUDE.md` never gains the rule their CI now enforces. F1 removes the
reason to act on the `fetch-depth: 0` instruction that immediately precedes it, and the failure
is also silent: a green check that graded nothing. Neither risk exists inside this repository —
the kit's own workflow sets `fetch-depth: 0` and the kit is not an adopter — so both are
merge-blocking for the adopter surface, not branch-breaking here.

Everything else I tested held, including every claim the phase's own commit message advertises
as its reason for existing (exemption count and shape, renderer parity, the boundary). Fix F1
and F2 as prose inside the declared Territory, re-run `ritual-checks`, and this phase is a
straightforward APPROVE. F3–F6 are one-sentence improvements that can ride along or be deferred;
F7 needs nothing before merge beyond gate 6 not being surprised by the `3a51f5c` WARN in the CI
log.

---

## Dispositions (implementer, 2026-09-16)

Appended below the reviewer's text; nothing above this line was edited. All six actionable
findings are fixed in the remediation commit; F7 is an observation and needs no change. Every
fix is prose inside phase 4's declared Territory — no script changed.

### F1 — BLOCKING — **fixed**

The closing sentence claimed a failure the check does not produce. Confirmed independently
against the code before acting: `Invoke-AmendmentAuthorityCheck` (`enforcement-pack.ps1:1054`)
is `if (-not $Base) { return }` — a bare return, no output, exit 0. Replaced with what is true:
the check cannot detect that it is in that position, an unreadable-ref run reports commits as
pre-boundary, and `fetch-depth: 0` is the only defence because no failure is waiting to catch
you. The paragraph now agrees with its own second sentence and with the digest marker below it.

### F2 — BLOCKING — **fixed**

Confirmed against `kit-manifest.json`, not memory: `CLAUDE.md` (`:4`),
`docs/sdlc/review-process.md` (`:16`) and `docs/sdlc/repository-strategy.md` (`:14`) are all
surgical, and all three are changed by this branch. The single "arriving verbatim" bullet is now
two: what the update writes (with both `specs/_templates/` review templates added, per the
finding) and what you mirror by hand, in the document's own inline-flagging convention. The
self-contradiction with line 209 is gone.

### F3 — MINOR — **fixed**

`enforcement-pack.ps1:1146` restricts the status exemption to `spec.md` and `plan.md`. Added the
restriction to the bullet in `adoption/updating.md`, plus one sentence that a `tasks.md` status
line is not exempt, and made the same correction in `adoption/greenfield.md`, which described
the exemption as applying to "a document".

### F4 — MINOR — **fixed**

Took the second of the two offered actions: the example block keeps its margin arrows, and the
paragraph beneath now says they are annotations and that a record line ends at the date —
anything appended defeats the pattern. That is the lesson `3a51f5c` paid for one commit earlier,
so it is worth stating where a reader meets the silhouette rather than only in a commit message.

### F5 — MINOR — **fixed**

Both sample failures replaced with the text the script actually emits: full repo-relative paths
from `$files` (`:1159`), the first tail-elided with `…`, the second complete through
`(constitution I; plan D5)`. The sha is now the plainly synthetic `a1b2c3d` — `61c57d5` is a
real, compliant commit on this branch and should never have illustrated a failure.

### F6 — MINOR — **fixed, by the second of the two options offered**

The count stays at two. The renumbering carve-out (`:1136`) is now named in the *creation*
bullet, where D2 and FR-010 already place it conceptually, with the honest note that it is the
one exempted case in which a document's text did change. Saying "three" would have split a rule
the plan deliberately treats as one.

### F7 — MINOR, observation — **no change**

Concurred, and already recorded independently: the `3a51f5c` WARN and why it is cosmetic are in
`notes.md` under the phase 4 gate record, which is where gate 6 will meet it. The repair's
legitimacy findings — entry list unchanged, narrowing not widening, ordered before the phase
commit — match the record there.

### Not fixed here, and why

Making the check fail closed on an unreadable history is a `scripts/` change, outside phase 4's
Territory. It joins the two findings already homeless in `notes.md` — `build-digests.ps1`
sharing the B7 inline-code defect, and `Get-Territory`'s decorated-marker blind spot. Three
fail-open defects in the same feature's tooling now want one phase between them.
