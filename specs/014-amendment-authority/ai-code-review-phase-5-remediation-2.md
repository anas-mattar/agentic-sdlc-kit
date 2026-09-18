# AI Code Review — 014 Amendment Authority (phase 5, remediation round 2)

**Reviewer**: fresh-context agent — claude-opus-5[1m]
**Date**: 2026-09-18
**Branches**: agentic-sdlc-kit `014-amendment-authority` (tip `37e22ac`; commit under review
`9d6b01f`, the third phase-5 commit)
**Scope reviewed**: `git show 9d6b01f` in full (5 files), and each touched file in the working
tree: `scripts/enforcement-pack.ps1` (read end to end — `Get-DiffBase`, `Get-ChangedFiles`,
`Invoke-StructureCheck`, `Invoke-LiteAndAbuseCheck`, `Invoke-MicroLaneCheck`,
`Invoke-ReviewProvenanceCheck`, `Invoke-PhaseSizeWarningCheck`, `Get-CommitMetaBatch`,
`Get-NameStatusBatch`, `Test-CheckAbsentForReal`, `Get-CheckPresenceSet`,
`Invoke-AmendmentAuthorityCheck`, the Dispatch block and the exit-code tail),
`adoption/updating.md` §2 close, `specs/014-amendment-authority/{tasks.md, notes.md}` and the
round-2 review file this commit adds. Differential baselines
`git show 8c1bdad:scripts/enforcement-pack.ps1` and `git show a57fe3c:scripts/enforcement-pack.ps1`
were read and **executed** against my own fixtures. Also read: `spec.md`, `plan.md`,
`.specify/memory/constitution.md` (Principle I, Amendment authority), `CLAUDE.md`,
`docs/sdlc/definition-of-done.md`, `docs/sdlc/review-process.md`, `scripts/ritual-checks.ps1`,
`scripts/scope-lib.ps1`, `scripts/scope-check.ps1`, `docs/roadmap.md` rows GAP-025 / GAP-026, and
the two prior review rounds (`ai-code-review-phase-5.md`, `ai-code-review-phase-5-remediation.md`).
Not read line by line: phases 1–4 review files beyond the findings this round cites.
**Feature contract**: Standard feature, `**Gate Batching**: none`, `**Gate Certification**:
ci-held`; zero new dependencies; read-only; `git` plumbing only, no network; the verdict for a
given commit must never change with the calendar (plan, Technical Context + D7). Phase 5
Territory: `scripts/enforcement-pack.ps1`, `adoption/updating.md`, `docs/digests/`.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5[1m]
- **Implementer**: Claude Opus 5 (1M context) — the model/session that authored `9d6b01f`
  (co-author trailer `Co-Authored-By: Claude Opus 5 (1M context)`)
- **Inputs provided**: the phase diff (`git show 9d6b01f`, `--stat`), `spec.md`, `plan.md`,
  `tasks.md` (T089–T094 and the phase 5 Territory block), `notes.md`,
  `ai-code-review-phase-5.md` (F1–F6), `ai-code-review-phase-5-remediation.md` (G1–G6), the two
  differential baselines `8c1bdad` and `a57fe3c` of `scripts/enforcement-pack.ps1`,
  `.specify/memory/constitution.md`, `CLAUDE.md`, `docs/sdlc/definition-of-done.md`,
  `docs/sdlc/review-process.md`, `adoption/updating.md`, and
  `specs/_templates/ai-code-review-template.md`. No implementer conversation or reasoning was
  supplied or sought.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — one blocking finding, and it is prose, not logic.

The two substantive fixes are real and I proved both rather than accepting them. G1: replacing
`git cat-file -s` with `git cat-file blob` on the blob probe closes the third damage mode. On my
own fixture the round-1 script certifies a truncated object as `graded 0 of 2 … made before the
check existed`, `enforcement-pack: OK`, **exit 0**, letting an unrecorded amendment through; the
committed script fails it naming the unreadable parent, exit 1. Deleted and garbage are unchanged,
the intact fixture still grades `2 of 2` and names the unrecorded amendment, and my independently
measured probe table reproduces `notes.md`'s table cell for cell. G2: a baseless clone now emits a
warning saying nothing was compared, `fix/` stays exit 0 (FR-009 intact, measured), `NNN-*` still
fails in the check. G3 and G6 are closed as described. `ritual-checks` is green, `scope-check`
PASSes the phase commit, and the amendment record on `tasks.md` is well-formed, in the amended
section, named in the commit message, and graded green by the check itself.

What blocks is H1, and it is the same species that blocked the last two rounds: the G2 fix ships
**two new assertions about the check, inside the check, that are not true of it** — "every check
that reads the diff graded an EMPTY file list" (true only on `fix/`/`chore/`; on `NNN-*` the
amendment check fails outright, and three other members return before grading anything) and "the
phase 5 fix that replaced the `Get-DiffBase` crash is what made that reachable" (true of the
truncated-clone shape only; in the no-`main` shape — the commonest CI shape — the same silence was
already reachable at `a57fe3c`, which I ran to confirm). Both were written by the round whose own
T090 declares that "an untrue sentence about the check, inside the check, is this feature's own
defect class", and both ship to every adopted project as the check's own account of what it just
did. The remedy is one sentence in one comment plus the matching string; no logic changes, no new
fixture. Residual risk otherwise sits where the implementer says it sits: F3 (unstated cost —
quantified below at 27 of 132 git calls), F4 (an unamended spec, now diverging in a second place),
and G5 (gate 6's to judge).

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | **FR-009 holds and I measured it**: on a baseless clone `fix/sneaky` (36 tracked files incl. `package.json`, `src/auth.ts`, a migration) exits **0** under the committed script — the added notice is a warning, not a failure — where `a57fe3c` exits 1 by crash. **FR-008 holds** for the new failure paths: every message I triggered names the branch, the condition and the remedy (`fetch-depth: 0` / `git fetch origin main`). **FR-004/FR-002 unchanged**: intact fixture grades `2 of 2` and names `specs/001-test/spec.md`. **FR-011 is where the drift sits** (F4, H2 below): "MUST pass silently on a project with no amendments" now has a second exception — any lane in a baseless clone prints a `WARNING` — recorded only in `tasks.md`/`notes.md`. **SC-006 still unstated** (F3). |
| Visual-reference match (where references exist): Visual Compliance Loop deviation table attached, empty or user-approved (`docs/sdlc/review-process.md`) | **N/A** — no UI, no `specs/014-amendment-authority/screenshots/` directory exists; the feature's surface is a PowerShell check and Markdown law. |
| Feature contract held (no unapproved table/migration/permission/package) | Held. `git show 9d6b01f --stat`: 5 files, +522/−10. No new file, no new function, no new dependency, no new git verb beyond `cat-file blob` (replacing `cat-file -s`) and `cat-file commit` (replacing `cat-file -s` on the commit probe). Read-only: every added statement is a `git` read, a string append to `$script:warnings`, or a comment. `GIT_TRACE` of a full run shows 132 git invocations, all of them `show`/`cat-file`/`ls-tree`/`rev-parse`/`rev-list`/`log`/`diff`/`merge-base`/`grep` — no write verb. |
| Constitution / domain invariants | **I (Amendment authority)**: one amendment, `tasks.md`'s `### Phase 5 remediation, round 2` block, carrying `**Amendment approved by**: anas.m, 2026-09-17.` inside the amended section; the commit message names the same approver ("approved by anas.m on 2026-09-17"). The check grades its own commit inside its own range and raises nothing (`AmendmentAuthority: graded 31 of 40 commit(s)` at tip, no failure). Approver is the human owner, not the implementing agent. **II (Source of truth)**: no digest marker text changed — the edited paragraph sits above `adoption/updating.md`'s two markers, which are byte-identical, and `build-digests.ps1 -Check` reports `digests: OK (5 digest(s) fresh, 80 marker(s))`, which is why `docs/digests/` is correctly absent from the diff despite being in Territory. **III**: N/A, single repo. **IV**: no architecture change. **V**: N/A. **VI**: read-only, no secrets; no shell interpolation — `${Ref}:path` is passed as a native argument. **VII**: N/A. **VIII/IX**: see Test coverage and H2/G5. GAP-025 and GAP-026 were **not** absorbed: `docs/roadmap.md` is untouched by the commit, and the two rows are (25) the `build-digests.ps1` inline-code-span marker parser and (26) `Get-Territory`'s line-start `**Territory**:` match — neither is anything this commit touches. |
| Security (authn/authz, secrets, sensitive logging) | No authn/authz surface. No secret is read or printed. The new warning string interpolates only `$Branch`, which comes from `git rev-parse --abbrev-ref HEAD` or the `-Branch` parameter; it is written to host output, not to a file or a network call. `git cat-file blob` inflates an untrusted blob but discards it through `*> $null` without parsing — strictly less parsing than `git grep`, which already read the same object. No new network surface beyond what a partial clone's lazy fetch already did under `-s`/`-e`. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | `pwsh -File scripts/ritual-checks.ps1` → `scope-check: PASS phase 5 commit 9d6b01f (5 file(s))`. The five: `scripts/enforcement-pack.ps1` and `adoption/updating.md` (both declared in phase 5's Territory) plus `specs/014-amendment-authority/{tasks.md, notes.md, ai-code-review-phase-5-remediation.md}`, covered by the implicit `specs/014-amendment-authority/**` glob (`scripts/scope-check.ps1:230`). `docs/digests/` is declared and untouched — permitted. Intent read from `--stat`: 28 changed lines of script (10 of them the G2 block), 4 of adopter prose, and 500 lines of record. No unrelated file. |
| Rollback safety (phase reverts cleanly; schema additive?) | No schema, no migration, no data. `git revert --no-commit 9d6b01f` in a throwaway clone of the branch: **both code files revert cleanly** (`adoption/updating.md`, `scripts/enforcement-pack.ps1` staged as modified, the review file deleted); `notes.md` and `tasks.md` conflict, because the later gate-record commit `37e22ac` appended into the same regions. That is the expected cost of append-only governance records, not a defect — a revert of the behaviour alone is clean. |

## Findings

### H1 — the G2 fix ships two new untrue assertions about the check, in the check's own comment, message and output string — BLOCKING

`scripts/enforcement-pack.ps1:1241–1250` (the block this commit adds) and the matching sentences
in the commit message and `notes.md`:

```powershell
# Silence is not compliance in the other lanes either (review G2). With no computable base,
# every member that reads the diff grades an EMPTY file list and passes: on a baseless clone a
# 'fix/' branch touching anything at all went green, and the phase 5 fix that replaced the
# Get-DiffBase crash is what made that reachable rather than fatal. …
    $script:warnings += "enforcement-pack: no integration branch to diff against, so every check that reads the diff graded an EMPTY file list on '$Branch'. …"
```

Two claims, both false as written, both new in this commit.

**(a) "every check that reads the diff graded an EMPTY file list" is true on one lane of four.**
`Get-ChangedFiles` returns `@()` on a null base, and the only member handed that list is
`Invoke-LiteAndAbuseCheck` — `fix/`/`chore/` only. Every other diff-reading member takes `-Base`
and guards it: `Invoke-ReviewProvenanceCheck:574` and `Invoke-PhaseSizeWarningCheck:623` return at
`if (-not $Base) { return }`, `Invoke-MicroLaneCheck:541` returns before the phase walk (its
tree-based arms do still run), and `Invoke-AmendmentAuthorityCheck` does not grade an empty list at
all — it **fails**. So on an `NNN-*` branch the string is emitted three lines above a failure that
contradicts it, and on `docs/` the one applicable member skipped rather than graded. Observed, four
runs on purpose-built baseless fixtures:

```text
fix/sneaky   → WARNING … graded an EMPTY file list on 'fix/sneaky'      enforcement-pack: OK    EXIT=0
001-orphan   → WARNING … graded an EMPTY file list on '001-orphan'      FAIL: AmendmentAuthority: cannot grade … no integration branch   EXIT=1
docs/x       → WARNING … graded an EMPTY file list on 'docs/x'          enforcement-pack: OK    EXIT=0
weird/x      → WARNING … graded an EMPTY file list on 'weird/x'         FAIL: Branch naming …   EXIT=1
```

**(b) "the phase 5 fix … is what made that reachable rather than fatal" is true of one of the two
baseless shapes.** It is true where `origin/main` resolves but shares no commit (the `--depth N
--no-single-branch` shape F2 was about). It is false where neither `main` nor `origin/main` exists
— the ordinary `actions/checkout` depth-1 shape — because there was never a crash there to replace.
Measured on a repository with no `main` at all, one `fix/` branch, 33 tracked files including
`package.json`:

```text
a57fe3c (pre-remediation) → enforcement-pack: OK   EXIT=0      ← already silent, no crash
8c1bdad (round 1)         → enforcement-pack: OK   EXIT=0
9d6b01f (round 2)         → WARNING … + enforcement-pack: OK   EXIT=0
```

The round-2 review said exactly this ("a clone where neither `origin/main` nor `main` resolves
already produced exactly this silence in both script versions"), and the sentence written in
response drops the qualification. The same two claims appear in the commit message ("in it every
member that reads the diff grades an EMPTY file list"; "Replacing the Get-DiffBase crash made a
previously fatal state reachable") and in `notes.md:1600–1604`.

Neither error is a fail-open: both over-state, and the sentence's conclusion — "it is evidence that
nothing was compared" — is true on every lane. That is why the remedy is small. It blocks because
this feature's entire deliverable is that a check's own account of itself is true, because this
string ships verbatim to every adopted project through the update channel, and because T090 — in
this very commit — sets the standard it fails: *an untrue sentence about the check, inside the
check, is this feature's own defect class.* Two rounds have now been spent on that class and this
round introduces the third instance of it.

*Action: implementer — narrow both sentences in the comment at `scripts/enforcement-pack.ps1:1241–1246`,
in the warning string at `:1248`, and in `notes.md`'s G2 section. Suggested shape for the string:
"no integration branch to diff against, so nothing on '$Branch' was compared: the Lite-lane checks
graded an empty file list and the members that read the diff returned without grading." No
amendment needed — `scripts/enforcement-pack.ps1` is in Territory, `notes.md` is ungraded by D3b.*

### H2 — T093 says "correct the T086 record"; the record in `tasks.md` still carries the disproved basis — CONFIRM

T093 (ticked `[x]` in this commit) reads: "Correct the T086 record, whose approval basis ('no
member's verdict moves') this disproves." The correction landed in `notes.md` §"G2 — the T086
approval rests on a statement that is not true". `tasks.md:531–535` — the amendment preamble the
owner actually approved, and the document the amendment check grades — is untouched and still reads:

> Approved knowingly on that basis — it replaces a crash that killed the whole run, so **no
> member's verdict moves**, and the alternative is a pack that dies before any check speaks.

Ten lines below it the new round-2 preamble says the widening happens "for the same reason T086
did", which re-endorses the basis rather than marking it disproved. `notes.md:1546–1548` likewise
keeps the original sentence in place, corrected only by the appended section — which is that file's
established convention (see the "**Correction, same day.**" precedent at `notes.md:864`) and is
fine there.

Two defensible readings, and the choice is the owner's, not mine: either `notes.md` is the record
and T093 is complete, or the approval preamble in `tasks.md` is the record — in which case a reader
of the standard still meets a justification this branch disproved, with nothing at the site to say
so. I lean to the second, because `tasks.md` is what the check grades and what a later reader
treats as the agreed standard, and because the fix is one appended sentence rather than a rewrite
of the historical approval.

*Action: owner — decide whether the T086 preamble in `tasks.md` gains a one-line "superseded: see
round 2 / G2" note (itself an amendment, needing a record), or whether `notes.md` is accepted as
the correction surface and T093's wording was simply broader than its intent.*

### H3 — the round says `notes.md` carried the untrue sentence; it did not — MINOR

T090, the commit message ("The comment, notes.md and the 8c1bdad message each said `-s` 'fails
exactly where a reader fails'") and `notes.md:1584–1586` ("The round-1 comment, **the paragraph
above it in this file**, and the commit message for `8c1bdad` each stated that…") all name three
surfaces. There were two. I searched the whole of `notes.md` as `8c1bdad` left it: the only
`-s` sentences are the probe table at `:1486–1490` (four rows, two damage modes — accurate for what
it measured) and `:1513` ("`-s` prints the size, so the probe redirects stdout as well as stderr").
Neither asserts the equivalence; `git show 8c1bdad -- notes.md` adds no such line. The same
paragraph then says "The earlier table in this file stands as written", which contradicts the claim
made four sentences earlier.

The misattribution was inherited from the round-2 review's own G1 text and carried into three new
surfaces without being checked against the file — in a round whose stated method (`notes.md:1472–1474`)
is that "a finding accepted on its description is a finding graded the way this feature exists to
forbid". Harmless in effect: it over-attributes an error to the record rather than hiding one.

*Action: implementer — when H1's sentences are corrected, drop `notes.md` from the list of surfaces
that carried the claim, or say what it actually carried (a table accurate for two modes of three).*

### H4 — "ungraded" is a warning only: the verdict block, the exit code and the adopter document all still say clean — MINOR

Traced end to end, as asked. The warning appends to `$script:warnings`; the dispatch tail prints
`WARNING: …` lines and then, with no failures, `enforcement-pack: OK` / `exit 0`; `ritual-checks.ps1`
re-echoes the child's stdout but derives its own summary purely from the exit code, so the run I
executed on a baseless `fix/` clone would print `ritual-checks: enforcement-pack OK` and
`ritual-checks: RESULT OK`. An adopter reading the verdict block, a GitHub check conclusion, or a
required-status badge sees nothing; only a human scrolling the log body sees the notice. That is the
correct trade under FR-009 — a new hard failure on the Lite lane is forbidden, and I verified none
was introduced — but it leaves the pre-existing hole open rather than closed: on a `docs/` branch
with no computable base, `Invoke-ReviewProvenanceCheck` returns at `:574` and a review file added
with no provenance block passes green. Pre-existing (both `a57fe3c` and `8c1bdad` behave the same, measured), now at least audible.

Two smaller gaps in the same area. The script's own `.DESCRIPTION` header (`:1–80`) enumerates every
member and its behaviour and says nothing about the ungraded state. And `adoption/updating.md:431–433`
— the paragraph this commit edited for G6 — still tells the adopter "A Lite branch (`fix/`, `chore/`,
`docs/`) is unaffected — the check returns before it consults history at all", which is true of the
amendment check and no longer true of the run: in exactly the clone shapes that paragraph is about,
a Lite branch now prints a warning the document does not mention.

*Action: owner decides whether an ungraded run should reach the verdict (a distinct
`enforcement-pack: UNGRADED` line, or a member-level n/a of the kind `ritual-checks` already renders
for `digests`/`scope-repos`) — that is a roadmap row, not phase 5. Implementer, in this round's
follow-up: add the state to the `.DESCRIPTION` header and one clause to `adoption/updating.md`'s
Lite-lane sentence, both already in Territory.*

### H5 — "at no measurable cost" is asserted in the comment and measured nowhere in `notes.md` — MINOR

`scripts/enforcement-pack.ps1:1244` ends "…measured across all three damage modes (deleted /
garbage / truncated) **at no measurable cost**." The damage modes are measured and recorded
(`notes.md:1563–1575`, and I reproduced the table exactly). The cost is not: this round's `notes.md`
section records no timing, and the only measurement in the repository is the round-2 reviewer's
(14.20/14.48 s vs 13.67/14.78 s on a 41-commit fixture) — in the review file this commit adds, so
the evidence is at least in-repo. My own attempt on this machine: 8 295 / 15 575 / 12 381 ms for the
committed script and 10 384 / 10 124 / 11 118 ms for a probe-free variant — noise swamps the signal,
exactly as `notes.md:316–321` already records of this machine. The claim is *consistent* with every
measurement I can make; it is simply the implementer asserting someone else's number as their own.

*Action: implementer — cite the measurement ("measured by the round-2 review at …") or drop the
clause. Nothing else.*

### F3 — the per-commit probe undoes T024's batching, and SC-006's fraction is still unstated — CONFIRM, genuinely open, now quantifiable

Still open, unchanged by this commit, and I can now put a number on it that neither prior round did.
`GIT_TRACE` over a full `enforcement-pack` run on this branch: **132 git invocations**, of which
`Test-CheckAbsentForReal` accounts for **27** — nine `cat-file commit`, nine `ls-tree`, nine
`cat-file blob`, one triple per pre-boundary commit — i.e. **20 %** of every git process the pack
starts, spent entirely in the region T024 batched down to a single `git grep`. The shape is the
concern rather than today's number: the probe fires once per commit whose parent is not in the
presence set, so on an arrival-day branch (every commit pre-boundary — the case T024 was written
for) it is three processes per commit, and since `9d6b01f` each third process inflates the whole
78 KB blob instead of its header. Runtime on this machine cannot resolve it (H5). `notes.md` states
no fraction, in seconds or in calls, for the post-phase-5 pack; SC-006 asks for "a small, **stated**
fraction".

*Action: owner — accept the cost with a stated line in `notes.md` against SC-006 (the call-count
unit phase 3 already established is enough: "27 of 132 pack invocations on this branch, 3 per
pre-boundary commit"), or ask for the batched form the round-2 review sketched (`ls-tree` for the
blob shas, one `cat-file --batch` — a reader, so it keeps G1's property; `--batch-check` would
reintroduce G1 exactly).*

### F4 — the spec still promises what the code no longer does, and this commit widened the gap — CONFIRM, open and worse than stated

Confirmed open: `spec.md` FR-011 ("MUST pass silently on a project with no amendments") and US4
acceptance scenario 2 ("it passes silently — arrival never turns an innocent project red") are
unamended, while `adoption/updating.md:412–415` documents the shallow-clone exception. It is worse
than `notes.md` records it, in one direction and arguably two:

1. Before this commit the divergence was one lane deep — an `NNN-*` branch failing on a shallow
   clone. After it, **every** lane in a baseless clone emits output attributable to this feature,
   including the Lite lane the spec's FR-009 says the check "MUST NOT fire on". I verified the
   emission on `fix/`, `docs/`, `NNN-*` and an unrecognised branch name.
2. Read strictly, that is a second FR-011 deviation ("silently") and a brush with FR-009 ("MUST NOT
   fire on the Lite lane"). Read by US4's own gloss — "never turns an innocent project red" — both
   still hold, because the exit code does not move (measured). The spec does not adjudicate between
   the two readings, which is precisely why it needs the owner.

The remedy remains a spec amendment, which constitution I reserves to the owner; no implementer
action is available here.

*Action: owner — amend `spec.md` FR-011 / US4 scenario 2 (with its own approver record) to state
both exceptions: an `NNN-*` branch fails on an ungradable clone, and any non-trunk branch on a
baseless clone reports itself ungraded. Or rule that "silently" means "without turning red", and say
so in the spec so the next reviewer does not re-raise it.*

### G5 — the authorising amendment ships inside the commit it authorises, for the second round running — MINOR, carried, for gate 6

Unchanged and still lawful. `9d6b01f` adds `### Phase 5 remediation, round 2`, its
`**Amendment approved by**: anas.m, 2026-09-17.` line, T089–T093 **already ticked**, and the code
those tasks describe, in one commit. Constitution I permits it in as many words ("Amending before
implementing satisfies the sequence; it does not satisfy this rule"); the record is well-formed, the
message names the same approver, the check grades the commit inside its own range and passes, and
Territory did not change so `scope-check` is indifferent. What a machine cannot see: `tasks.md`
never existed in a state where this round's work was pending, so the only artifact ordering the
owner's approval before the code is the commit message — now twice in a row, where the branch's
three earlier amendments (`1cff420`, `ca88da5`, `3a51f5c`) each landed as their own commit first.
Note this round's approval also covers a *decision* ("G2 is fixed rather than merely recorded"),
which is more than a scope widening.

*Action: gate-6 human reviewer — confirm the 2026-09-17 approval of the round-2 block, including the
decision to fix G2 rather than record it, was given before the code was written. Nothing for the
implementer.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**One amendment, and it carries its record.**

| Commit | Document | What changed | Approver recorded |
|---|---|---|---|
| `9d6b01f` | `specs/014-amendment-authority/tasks.md` | New `### Phase 5 remediation, round 2 (added by amendment 2026-09-17 — second review, G1–G3, G6)` section: a preamble stating that G2 is fixed rather than recorded and that this widens phase 5 a second time past T081, plus T089–T094 (T089–T093 added already ticked, T094 added unticked) | `**Amendment approved by**: anas.m, 2026-09-17.` inside the added section; the commit message names the same approver ("approved by anas.m on 2026-09-17, including the decision to fix G2 rather than only record it") |

No change to `spec.md`, `plan.md`, `contracts/` (the feature has no `contracts/` directory), or the
phase 5 **Territory** block — I diffed all of them: `git show 9d6b01f --stat` lists five files and
none of the first three. `notes.md` is ungraded by design (plan D3b). Machine verdict on the
record: the amendment check grades `9d6b01f` inside its own range and raises nothing
(`AmendmentAuthority: graded 31 of 40 commit(s) … (9 not graded: 9 made before the check existed)`,
no failure line).

Two qualifications a machine cannot make, both carried as findings rather than buried here: the
amendment ships inside the commit it authorises with its tasks pre-ticked (G5), and the *stated
basis* of the previous round's amendment — which this round disproves — still stands uncorrected in
the same file (H2). The approval basis recorded for **this** round ("the round-1 fix turned a crash
into a reachable state, and a reachable state that grades nothing must say so") is accurate in
substance, with the one qualification H1(b) records: in the no-`main` shape the state was reachable
before the round-1 fix too.

## Constitution re-check (post-implementation)

**PASS on every principle, with one blocking finding outstanding against Principle II.**
Re-evaluated against the code as built, not against the plan's own check.

- **I Specification First / Amendment authority** — PASS on form: one amendment, well-formed record
  in the amended section, same approver in the message, approver is the human owner and not the
  implementing agent, graded green by the check itself. Two open questions of substance, both for a
  human: G5's ordering, and H2's uncorrected basis. F4's spec divergence is an I question too — the
  standard the work is graded against no longer describes the work — and it is the owner's to close.
- **II Source of Truth** — **PASS with H1 outstanding.** Digests are fresh (`5 digest(s) fresh, 80
  marker(s)`), no marker text moved, `doc-lint` resolves every referenced path, and the adopter prose
  follows the code rather than leading it for G6. H1 is a II failure in the narrow sense that matters
  most here: the check's own comment and output no longer describe the check.
- **III Repository Separation** — N/A, single-repo kit; `scope-repos` reports `n/a` as expected.
- **IV Architecture Consistency** — PASS. No new file, function, pattern, dependency or git verb
  class; the G2 block is ten lines in the existing dispatch, using the existing `$script:warnings`
  channel that `PhaseSizeWarningCheck` already uses.
- **V Domain Invariants** — N/A; the kit's domain is its own governance, and the invariants path is
  still the unfilled `{{DOMAIN_INVARIANTS_PATH}}` slot, correctly skipped by `Invoke-LiteAndAbuseCheck`.
- **VI Security** — PASS. Read-only, no secrets, no shell interpolation, no new network surface
  beyond the lazy fetch a partial clone already performed under `-e`/`-s`. `cat-file blob` discards
  the inflated object without parsing it.
- **VII External Integration Governance** — N/A.
- **VIII Testing Requirements** — **engaged, and this time the generalisation held.** The fixture set
  finally covers the class rather than one member of it: deleted, garbage **and** truncated, which is
  the three-of-three the last two rounds each missed by one. I built the fixtures independently and
  they reproduce. The gap that remains is the other axis — the G2 change shipped with its behaviour
  recorded in prose (`notes.md`'s two-line `text` block) rather than as a reproducible fixture record
  of all four lanes; I had to build those runs myself to find H1.
- **IX Human Review** — in progress. This is gate 5, and it returns REQUEST CHANGES; gate 6 is
  outstanding, with G5 and H2 addressed to it.
- **X Delivery levels / gates** — PASS. Standard feature, `**Gate Batching**: none`,
  `**Gate Certification**: ci-held` declared in `plan.md` before any phase; the commit carries the
  `phase 5` token; the gate record for `9d6b01f` (run 35242954023, success, push event) is in
  `notes.md`. Note for the record that this gate was certified before gate 5 ran, which the gate
  record itself states plainly ("No fresh-context reviewer has seen `9d6b01f`").

## Test coverage observed

No test framework — kit convention since 006 is seeded fixture repositories plus replay over real
history. What exists for this round, and what I ran independently:

- **The implementer's evidence** (`notes.md`, "Phase 5 remediation, round 2"): a four-probe × three-mode
  exit-code table, a statement that the intact fixture grades `2 of 2`, a two-line transcript of the
  `fix/` and `NNN-*` verdicts on a baseless clone, and the repository's own unchanged `graded 29 of 38`
  (which I confirmed is the count at `8c1bdad`: `git rev-list --count 49d56aa..8c1bdad` = 38).
- **My replication of the probe table**, on a fresh repository whose 78 381-byte loose object I damaged
  three ways. Every cell matches `notes.md` exactly: `-e` → 1 / **0** / **0**; `-s` → 128 / 128 / **0**;
  `cat-file blob` → 128 / 128 / 128; `git grep` → 1 / 128 / 128 (deleted / garbage / truncated).
  `cat-file blob` is nonzero in exactly the columns a reader is nonzero, and zero where it is zero.
- **My end-to-end fixture**, a `main` carrying the check and a `001-test` branch whose second commit
  amends `spec.md` with no record, run against the committed script and against `8c1bdad`:

  ```text
  intact     NEW: graded 2 of 2, names specs/001-test/spec.md (exit 1)   OLD: identical
  garbage    NEW: cannot grade — parent … not readable (exit 1)          OLD: identical
  truncated  NEW: cannot grade — parent … not readable (exit 1)          OLD: graded 0 of 2 … made before the check existed, enforcement-pack: OK (exit 0)
  deleted    NEW: cannot grade — parent … not readable (exit 1)          OLD: identical
  ```

  The truncated row is G1 reproduced and G1 closed, in one table.
- **My lane fixtures for G2**: a baseless `fix/` branch with 36 tracked files including
  `package.json`, `src/auth.ts` and a migration (exit 0 + warning, FR-009 intact); the same clone's
  `001-orphan` (exit 1, the amendment check's no-base failure + warning); `docs/x` (exit 0 +
  warning); an unrecognised `weird/x` (exit 1, branch-naming + warning); a no-`main` repository run
  against all three script generations (`a57fe3c`/`8c1bdad`/`9d6b01f` → 0 / 0 / 0).
- **Whole-run verdict**, verbatim: `doc-lint OK`, `enforcement-pack OK`
  (`AmendmentAuthority: graded 31 of 40 commit(s) in 49d56aa…..HEAD (9 not graded: 9 made before the
  check existed (plan D2b))`, eleven non-blocking `PhaseSizeWarning` lines), `scope-check OK`
  (`PASS phase 5 commit 9d6b01f (5 file(s))`), `scope-repos n/a`, `digests OK (5 digest(s) fresh, 80
  marker(s))`, `roadmap-claims OK`, `verify-kit n/a`, **`ritual-checks: RESULT OK`**.

Not covered anywhere, and the gap H1 fell through: no fixture record asserts what each *member*
does under a null base, which is the claim the new warning makes.

## Residual risk

The behaviour is in good shape; the risk is concentrated in what the feature says about itself, and
that is this feature's product.

- **H1 (blocking)** — an untrue self-description shipping to every adopted project through the
  verbatim update channel. One-sentence fix, no logic, no new fixture; it must land before merge
  because the next reader of that comment is an adopter reasoning about a green run.
- **H2, G5 (gate 6)** — the two halves no machine reaches: whether the approver really approved, and
  whether the record a later reader meets is the corrected one. Both are addressed to the human
  reviewer, who should read `tasks.md:531–535` beside `notes.md`'s G2 section before approving.
- **F4 (owner, before merge)** — the spec is now two exceptions behind the code. Merging leaves the
  feature's own standard describing behaviour the feature does not have, which is the state 014 exists
  to end; it should not survive to merge unamended in either direction (amend, or rule the reading).
- **F3 (owner, can follow)** — a stated fraction for SC-006. Quantified here at 27 of 132 git calls
  and three processes per pre-boundary commit; it needs a line in `notes.md`, not new work.
- **H4's pre-existing hole (roadmap, not this phase)** — on a baseless clone the review-provenance
  check, which is the machine half of gate 5 itself, still returns without grading, and the run's
  verdict still reads `OK`. This commit made it audible; nothing yet makes it visible in a verdict
  block or an exit code. A roadmap row, and worth one, because the check that goes quiet is the one
  that polices reviews.
- **Merge sequence I would ask for**: fix H1, rule H2 and F4, re-run `ritual-checks`, re-certify the
  gate on the new phase commit, then gate 6. A fourth fresh-context round is not warranted for a
  prose fix — the diff can be read by the gate-6 human against this review.
