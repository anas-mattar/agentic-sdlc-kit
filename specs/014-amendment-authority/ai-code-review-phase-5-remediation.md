# AI Code Review — 014 Amendment Authority, phase 5 remediation

**Reviewer**: fresh-context agent — claude-opus-5[1m]
**Date**: 2026-09-17
**Branches**: agentic-sdlc-kit `014-amendment-authority` (remediation commit `8c1bdad`, branch tip)
**Scope reviewed**: the whole of `8c1bdad` (5 files) read as a diff and in the working tree —
`scripts/enforcement-pack.ps1` (`Get-DiffBase`, `Test-CheckAbsentForReal`,
`Get-CheckPresenceSet`, `Invoke-AmendmentAuthorityCheck`, and every member that takes `-Base`:
`Get-ChangedFiles`, `Invoke-LiteAndAbuseCheck`, `Invoke-MicroLaneCheck`,
`Invoke-ReviewProvenanceCheck`, `Invoke-PhaseSizeWarningCheck`, plus the Dispatch block),
`adoption/updating.md` (working-tree lines 395–440), and
`specs/014-amendment-authority/{tasks.md,notes.md,ai-code-review-phase-5.md}`; the prior version
of the script (`git show a57fe3c:scripts/enforcement-pack.ps1`) as the differential baseline; and
— as the standard the work is graded against — `specs/014-amendment-authority/{spec.md,plan.md,tasks.md}`,
the phase-5 review `ai-code-review-phase-5.md` (findings F1–F5),
`.specify/memory/constitution.md` (Principle I, Amendment authority), `scripts/doc-lint.ps1`
(scan scope), `scripts/scope-check.ps1`, `scripts/build-digests.ps1 -Check`, and `docs/roadmap.md`
(GAP-025 / GAP-026, to check nothing was quietly absorbed). Not read line by line:
`scripts/verify-kit.ps1`, `scripts/scope-lib.ps1` internals (exercised through `ritual-checks.ps1`).
**Feature contract**: Standard lane; `**Gate Batching**: none`, `**Gate Certification**: ci-held`;
zero new dependencies, read-only, `git` plumbing only, no network, verdict independent of the
calendar; "every existing pack message stays byte-identical; the new member only ever adds
failures of its own" (plan, Testing Strategy). Phase 5's Territory is three entries
(`scripts/enforcement-pack.ps1`, `adoption/updating.md`, `docs/digests/`), unchanged by this round.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5[1m]
- **Implementer**: claude-opus-5[1m] (implementing session)
- **Inputs provided**: the remediation commit `8c1bdad`, the phase-5 review it answers,
  `spec.md`, `plan.md`, `tasks.md`, `notes.md`, and the repository itself as ground truth; no
  `contracts/` — the feature has none. No implementer conversation or reasoning was provided,
  and none was requested.
- **Attestation**: This reviewer did not produce the diff under review.

> Disclosed rather than buried: reviewer and implementer carry the **same model id**. The
> separation here is a fresh context — no implementation history — which is the minimum
> `docs/sdlc/review-process.md` sets and what DoD gate 5 permits ("fresh-context agent session
> **or** a second model"). A second model would be stronger; the owner should weigh that.

## Verdict

**REQUEST CHANGES** — F2 and F5's substance are closed, F1 is closed only for the corruption mode
the previous review happened to build. I re-proved every claim on my own fixtures rather than
reading the record: the old script and the new one were run side by side over a deleted blob, a
fully-garbage blob, a **truncated** blob, an unrelated-histories repository, a real
`--depth 5 --no-single-branch` clone of this repository, and the repository itself. F2 is
genuinely fixed — the crash at `Get-DiffBase` becomes a named condition and the NNN lane stays
red (`EXIT=1` both before and after). F1's fix is real but stops one step short, and that is the
blocking finding: **`git cat-file -s` reads only the object *header***, so a loose object whose
header still inflates while its body is truncated exits **0** under `-s` while `git grep`,
`git show` and `git cat-file blob` all fail — the ref lands in `skipBoundary` again, the run
prints "3 made before the check existed (plan D2b)" and exits **0** with an unrecorded amendment
in the range. That is F1's exact shape with a narrower trigger, and the code comment, `notes.md`
and the commit message all assert the property I measured to be false ("`-s` reads the header, so
it fails exactly when a reader would fail"). The remedy is again one word — `git cat-file blob` —
which I ran against all four fixtures and this repository: it closes every corruption mode, moves
no verdict, and costs nothing measurable on a 41-commit arrival-day fixture (13.7 s / 14.8 s
against the committed script's 14.2 s / 14.5 s). Secondly, the basis the owner's approval of T086
is recorded on — "no member's verdict moves" — is false as written, and the same paragraph
demonstrates it: on a baseless clone a Lite branch moves from `EXIT=1` (the crash) to `EXIT=0`
with `LiteAndAbuse` grading an empty file list (G2, CONFIRM). Residual risk sits on G1: a silent
green in the exact family this phase exists to abolish.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | **FR-008** (name the condition, say what to do): all three conditions reproduced against the committed script — shallow (`--depth 5 --no-single-branch` clone of this repository: `cannot grade … this is a shallow clone …`, `EXIT=1`), no reachable base (unrelated-histories fixture: `cannot grade … no integration branch to diff against … does not distinguish them …`, `EXIT=1`), unreadable parent (deleted-blob and garbage-blob fixtures: `parent commit e813659 of f995e1f is not readable in this clone`, `EXIT=1`). Held — **except** for the truncated-object case, where nothing is named and the run is green (G1). **FR-009** (never fires on the Lite lane): on the same shallow clone, `fix/probe` → `enforcement-pack: OK`, `EXIT=0`, no `AmendmentAuthority` line; `Invoke-AmendmentAuthorityCheck` returns on `$Branch -notmatch '^\d{3}-'` before any history call (line 1079). Held — and it is the demonstration of G2. **FR-010 / D2c** (replay unaffected): `-IgnoreAmendmentBoundary` still sets `$graded = $true` before the presence set is built (line 1135), so neither changed probe is reachable on a replay; code path read, not re-run. |
| Visual-reference match (where references exist): Visual Compliance Loop deviation table attached, empty or user-approved (`docs/sdlc/review-process.md`) | **N/A, stated rather than skipped.** No `screenshots/` directory, no Visual Inventory, no UI surface: `8c1bdad` touches one PowerShell script and four Markdown files. The loop has no input on this round. |
| Feature contract held (no unapproved table/migration/permission/package) | `git show 8c1bdad --stat`: 5 files, 570 insertions, 13 deletions; the script itself is +20/−12. No new file, no new script, no dependency manifest, no new function — two probes changed and one comment block moved. Calls remain `git rev-parse`, `git merge-base`, `git ls-tree`, `git cat-file`, `git grep`: read-only plumbing, no calendar input. Verdict-preservation measured, not assumed: old and new run over this repository produce **byte-identical** output (`diff` of the two captures is empty), `graded 29 of 38 commit(s) … 9 made before the check existed`, `EXIT=0`. One property of the paragraph is looser than the code: a blobless partial clone with a reachable promisor grades **correctly** rather than failing, at ~31 s instead of ~10 s, because the probes lazily fetch (G6). |
| Constitution / domain invariants | **I (Amendment authority)**: this commit amends `tasks.md` (a new `### Phase 5 remediation` section, T085–T088) and carries `**Amendment approved by**: anas.m, 2026-09-17.` with the same approver named in the commit body ("Approved by anas.m on the basis that…"). The check grades its own commit and passes (`graded 29 of 38`, no failure). Constitution I explicitly does *not* require a separate earlier commit — "Amending before implementing satisfies the sequence; it does not satisfy this rule" — so this is lawful in form; the substance (G5) is a gate-6 question because the amendment ships inside the commit it authorises, with its tasks already ticked. **II (Source of truth)**: no digest marker text changed (`adoption/updating.md:437–438` untouched), and `build-digests.ps1 -Check` → `digests: OK (5 digest(s) fresh, 80 marker(s))`, which is why `docs/digests/` is correctly absent from this diff. **X**: one commit, `phase 5` in the subject, `Gate Certification: ci-held`. Nothing from GAP-025 / GAP-026 was absorbed (`docs/roadmap.md` untouched). |
| Security (authn/authz, secrets, sensitive logging) | No authn/authz surface. `$Ref` and `$c` reach `git` as argument array elements, never through a shell; `$Ref` is still a `%P` first-parent sha, ahead of the message-derived fields the 5-way split cap protects. `*> $null` widens *suppression*, never exposure. No secret, token, URL or path outside the repository added. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | `pwsh -File scripts/scope-check.ps1 -Commit 8c1bdad` → `scope-check: PASS phase 5 commit 8c1bdad (5 file(s))`. All five paths lawful: `scripts/enforcement-pack.ps1` and `adoption/updating.md` are declared Territory; `tasks.md`, `notes.md` and the review file sit under the implicit `specs/014-amendment-authority/**`. `-All` over the branch: every phase commit PASS, one pre-existing `not applicable` set, no FAIL. Diff read for intent: no unrelated refactor, no drive-by edit. |
| Rollback safety (phase reverts cleanly; schema additive?) | No schema, no migration, no data. `git show 8c1bdad -- scripts/ adoption/ \| git apply --check -R -` → clean; `git show 8c1bdad -- specs/ \| git apply --check -R -` → also clean (nothing has appended to those tails yet). Reverting restores `a57fe3c` exactly, including the prose, which is the property the Territory decision was made to get. |
| Gate evidence (ci-held) | **None yet for this round.** `notes.md` records no `ritual-checks` result and no evidence triplet for `8c1bdad`, and no gate-record commit follows it — yet T088, which asks for both, is ticked (G4). My own run is reported at the end of this review; it is not a gate. |

**The two blocking findings, re-proved rather than accepted.** Both fixtures live in the session
scratchpad; no file outside this repository's own review file was written.

```text
F1 — the fixture: main(root) → 001-test: [A create spec/plan/tasks] → [B adds the check]
     → [C amends spec.md with no approver record].  Then B's script blob is damaged three ways.

probe on B:scripts/enforcement-pack.ps1     deleted   garbage   truncated(50/101 bytes)
  git cat-file -e                           exit 1    exit 0    exit 0      ← the old probe
  git cat-file -s                           exit 128  exit 128  exit 0      ← the new probe
  git cat-file blob / git show / git grep   exit 1/128  exit 128  exit 128  ← what a READER does

end-to-end, a57fe3c script vs 8c1bdad script, same fixture:
  deleted    old: cannot grade … parent e813659 … not readable   EXIT=1  |  new: identical  EXIT=1
  garbage    old: graded 0 of 3 … 3 made before the check        EXIT=0  |  new: cannot grade  EXIT=1
  truncated  old: graded 0 of 3 … 3 made before the check        EXIT=0  |  new: graded 0 of 3 … EXIT=0
  intact     old: graded 1 of 3, names the amendment             EXIT=1  |  new: identical  EXIT=1
```

```text
F2 — git clone --depth 5 --no-single-branch --branch 014-amendment-authority file://…/agentic-sdlc-kit
  is-shallow-repository = true, origin/main resolves (ab847ca), merge-base exits 1 printing nothing
  NNN lane   old: "You cannot call a method on a null-valued expression."          EXIT=1
             new: "AmendmentAuthority: cannot grade … this is a shallow clone …"   EXIT=1   ← closed
  Lite lane  old: "You cannot call a method on a null-valued expression."          EXIT=1
             new: "enforcement-pack: OK"                                           EXIT=0   ← G2

unrelated-histories repository (not shallow; main resolves, no common ancestor)
  NNN lane   old: crash EXIT=1  |  new: "no integration branch to diff against … does not
                                        distinguish them …"                        EXIT=1   ← closed
  Lite lane, branch touching package.json and 31 files
             old: crash EXIT=1  |  new: "enforcement-pack: OK"                      EXIT=0   ← G2
  control, same branch content on a SHARED history: both versions FAIL with the two
             LiteAndAbuse messages (prohibited category + abuse guard), EXIT=1 — so the
             silence above is the missing base, not a broken check.
```

**Negative space — what I looked for and did not find.** (a) A reopened earlier finding: the two
changed probes are strictly stricter than what they replace (`-e` → `-s` on both the commit and
the blob), so nothing that used to be graded is now skipped; B3's `>= 2` fallback, B1's
rev-list-sourced commit set, D2b's sticky flag and D2c's replay bypass are untouched, and on this
repository the two versions' outputs are byte-identical. (b) A new fail-closed regression:
`Test-CheckAbsentForReal` returning `$false` more often can only *add* red, and no fixture with a
readable history produced a new failure. (c) `Get-DiffBase`'s loop: when `origin/main` resolves
with no merge base the loop now continues to `main` instead of dying, so a repository where the
second candidate *does* share history gets a base it previously never reached — an improvement,
read at lines 134–147. (d) `$LASTEXITCODE` survives the new `| Where-Object` pipeline: verified
behaviourally on every fixture, where a base is returned when one exists and `$null` when none
does. (e) Digest drift: none, because no marker line changed. (f) GAP-025 / GAP-026: not absorbed.

## Findings

### G1 — the F1 fix stops at the object header: a truncated blob still certifies "made before the check existed", green — BLOCKING

`scripts/enforcement-pack.ps1:738–744`:

```powershell
    # `-s` and not `-e`: `cat-file -e` answers "is this object named in the store" …
    # `-s` reads the header, so it fails exactly when a reader would fail.
    git cat-file -s "${Ref}:scripts/enforcement-pack.ps1" *> $null
    return ($LASTEXITCODE -eq 0)                                     # readable and without it
```

The comment's second sentence is the claim the fix rests on, and it is false. `cat-file -s`
inflates **only the header** — enough to print the size — and stops. A loose object whose zlib
stream is truncated part-way therefore answers `-s` successfully while every consumer that must
inflate the body fails. Measured on the fixture described above, truncating the boundary commit's
39 KB-class script blob from 101 bytes to 50:

```text
$ git cat-file -e 5878e58:…/enforcement-pack.ps1 ; echo exit=$?      → exit=0
$ git cat-file -s 5878e58:…/enforcement-pack.ps1 ; echo exit=$?      → 93, exit=0   ← the NEW probe
$ git grep -l -F -e 'function Invoke-AmendmentAuthorityCheck' 5878e58 -- …  → exit=128
$ git show 5878e58:…/enforcement-pack.ps1 >/dev/null                        → exit=255
$ git cat-file blob 5878e58:…/enforcement-pack.ps1 >/dev/null                → exit=128
```

and the check itself, on that fixture, with the **committed** script:

```text
enforcement-pack: branch '001-test', diff base '359c2f0…', 4 changed file(s)
AmendmentAuthority: graded 0 of 3 commit(s) in 359c2f0…..HEAD (3 not graded: 3 made before the check existed (plan D2b))
enforcement-pack: OK
EXIT=0
```

With the object intact the same fixture prints `graded 1 of 3` and names the unrecorded amendment
in `specs/001-test/spec.md`. So the unrecorded amendment passes, the count line prints the
affirmatively wrong reason T080 exists to eliminate, and the pack exits 0 — F1 reproduced inside
F1's own fix. It is narrower than the garbage-blob case the previous round closed (the damage has
to spare the header), and that narrowness is the only thing separating this from an unfixed
finding; it is not a reason to leave it, because the phase's Goal is unconditional and because
three artifacts now assert a property that does not hold (the code comment above, `notes.md`'s
"`-s` reads the header and so fails exactly where a reader fails", and the commit message's
"Probing with -s reads the header and so fails exactly where a reader fails").

The remedy is one word, and I ran it rather than proposing it — `git cat-file blob` in place of
`git cat-file -s` on the **blob** probe (the commit probe at line 733 is fine as `-s`; a commit
object is its own header):

```text
truncated fixture → AmendmentAuthority: cannot grade '001-test' — parent commit e813659 … not readable   (was: OK, exit 0)
garbage fixture   → same failure                                                                          (unchanged)
deleted fixture   → same failure                                                                          (unchanged)
intact fixture    → graded 1 of 3 … commit f995e1f amends specs/001-test/spec.md … no conforming record   (unchanged)
this repository   → output byte-identical to the committed script, graded 29 of 38, EXIT=0               (unchanged)
```

The cost objection F3 would raise does not survive measurement either: on a 41-commit arrival-day
fixture (every commit pre-boundary, a 38 KB script blob in each tree) the committed script runs
14.20 s / 14.48 s and the `blob` variant 13.67 s / 14.78 s — process spawn dominates, not the
inflate. If F3 is later closed by batching, the correct batched form reads the blob shas from one
`git ls-tree` pass and pipes them through a single `git cat-file --batch`, which is a reader and
so keeps this property; `--batch-check` would reintroduce exactly this defect.

*Action: implementer — change the blob probe at `scripts/enforcement-pack.ps1:743` from
`git cat-file -s` to `git cat-file blob` (keep `*> $null`), correct the comment at lines 738–741,
`notes.md`'s probe table and the "reads the header" sentence, and add the truncated-object case to
the fixture record. `scripts/enforcement-pack.ps1` is already in Territory; no amendment needed.*

### G2 — the widening's recorded basis is false: on a baseless clone a Lite branch moves from crash-red to silent green — CONFIRM

`tasks.md` (Phase 5 remediation preamble) and `notes.md` record the owner's approval of T086 —
the deliberate crossing of T081's "keep the blast radius inside this check" — on this basis:

> Approved knowingly on that basis — it replaces a crash that killed the whole run, so **no
> member's verdict moves**, and the alternative is a pack that dies before any check speaks.

No member's verdict moves *on the NNN lane*, which is where I confirmed it. On the Lite lane the
pack's verdict moves from red to green, and the very next sentence of `notes.md` is the proof
without naming it as one: "FR-009 re-checked on the shallow clone afterwards: `fix/probe` exits 0
with no `AmendmentAuthority` line." On the same clone the pre-fix script exits **1**. Measured
twice, once on a real `--depth 5 --no-single-branch` clone of this repository and once on an
unrelated-histories fixture where a `fix/` branch touches `package.json` and 31 files:

```text
fix/probe on the depth-5 clone            old EXIT=1 (crash)   new EXIT=0  enforcement-pack: OK
fix/sneaky, 31 files + package.json       old EXIT=1 (crash)   new EXIT=0  enforcement-pack: OK
   same branch content, shared history    old EXIT=1           new EXIT=1  (both LiteAndAbuse messages)
```

The mechanism: `Get-ChangedFiles` returns `@()` for a null base, so `Invoke-LiteAndAbuseCheck`
grades an empty list — no prohibited category, no abuse guard — while `Invoke-MicroLaneCheck`,
`Invoke-ReviewProvenanceCheck` and `Invoke-PhaseSizeWarningCheck` return at their own
`if (-not $Base) { return }`. Two things keep this off the blocking list. It is not new *behaviour*
so much as newly *reachable* behaviour: a clone where neither `origin/main` nor `main` resolves
already produced exactly this silence in both script versions (verified — `fix/solo` in a
main-less repository: `EXIT=0` old and new), so the change makes two broken-clone shapes consistent
rather than inventing one. And T081's own words are "a null base must not newly **fail** a Lite
branch", which the fix honours. What is wrong is the record: an approval justified by "no member's
verdict moves" was given for a change that moves the pack's verdict from 1 to 0 for three lanes in
a shape the prose specifically addresses (the build agent), and this feature's whole argument is
that a check which passes quietly is worse than one that speaks. Note too that
`Invoke-MicroLaneCheck`'s Micro-specific arms (promotion, `Gate Batching`, Territory cap) now do
run under a null base where the crash previously pre-empted them — that direction only adds red.

*Action: owner — re-confirm the T086 approval against the accurate statement (the amendment text
and `notes.md` both need the correction), and decide whether a baseless clone should print one
line on every lane ("no diff base — N members graded nothing") instead of passing silently. If it
should, that is a roadmap row, not phase 5: it is the pre-existing no-`main` silence, not
something this commit created.*

### G3 — F5 is half-closed: the batching comment now hugs the wrong brace — MINOR

F5 asked for the phase-5 function to stop sitting between `Get-CheckPresenceSet`'s doc comment and
`Get-CheckPresenceSet`. The comment moved instead, and landed one line off: it is now flush
against `Test-CheckAbsentForReal`'s closing brace with **no** blank line, and separated from the
function it documents by one. Before phase 5 (`ca88da5`) it was attached directly to
`function Get-CheckPresenceSet`, which is the file's universal convention: a scan of all 1271 lines
finds `Get-CheckPresenceSet` is the **only** function in the file whose doc comment is separated
from it by a blank line. A reader arriving at the closing brace of the un-batched function now
reads a paragraph about batching. Cosmetic, in a file whose comments are load-bearing
documentation for three projects — and the same defect F5 named, inverted.

*Action: implementer — move the blank line to the other side of the comment block
(`scripts/enforcement-pack.ps1:745–751`), restoring the `ca88da5` spelling.*

### G4 — T088 is ticked, and half of what it asks for exists nowhere — MINOR

T088 reads "…record both in `notes.md`, **then run `pwsh -File scripts/ritual-checks.ps1` and
report the ci-held evidence triplet**". The fixtures are recorded; the run and the triplet are
not. `notes.md`'s remediation section ends at "What this round does not close" — no
`ritual-checks` result, no run URL, no conclusion, no sha — and no gate-record commit follows
`8c1bdad`. The branch's own precedent is the counter-example: T084 stayed `- [ ]` in the phase
commit `a57fe3c` and was ticked by the gate-record commit `d48ca10`, after the evidence existed.
A ticked box that outruns its evidence is the same species of inaccurate record this feature
exists to make visible, and it is the box a later reader will trust.

*Action: implementer — un-tick T088 until the gate is held, or record the run and the triplet in
`notes.md` in the commit that holds it. Un-ticking is progress, not amendment (constitution I), so
it owes no approver.*

### G5 — the amendment that authorises this round ships inside the commit it authorises, with its tasks pre-ticked — MINOR

`8c1bdad` adds `### Phase 5 remediation`, its `**Amendment approved by**: anas.m, 2026-09-17.`
line, T085–T088 **already ticked**, and the code those tasks describe, in one commit. Constitution
I permits this in as many words ("Amending before implementing satisfies the sequence; it does not
satisfy this rule"), the record is well-formed, the commit message names the same approver, and
the check grades its own commit and passes — so there is nothing here for a machine to catch, and
nothing unlawful. It is still worth a reviewer's eye for two reasons. The branch's three earlier
amendments (`1cff420`, `ca88da5`, `3a51f5c`) each landed as their own commit *before* the work,
which is what let the phase-5 reviewer write "lawful rather than self-legalised". And `tasks.md`
never existed in a state where this round's agreed work was pending, so the only evidence that the
owner's approval of T086 preceded the code is the commit message. Territory did not change, so
`scope-check` is unaffected either way.

*Action: gate-6 human reviewer — confirm the 2026-09-17 approval of T086's widening was given
before the code was written, since no artifact orders them. Nothing for the implementer.*

### G6 — "a shallow or partial clone" over-promises for the partial half — DOC DRIFT

`adoption/updating.md:426–431` (the sentence group this commit edited) tells the adopter that in
"a shallow or **partial** clone … those objects are not there" and that the check "fails, and
names the condition it met". Measured against the code as built, on a real
`git clone --filter=blob:none` of this repository with the promisor remote reachable: the check
does not fail and names nothing — it grades correctly, `graded 29 of 38 commit(s)`,
`enforcement-pack: OK`, identical to the full clone, because `git grep` and `cat-file` lazily
fetch what they need (at ~31 s against ~10 s for the full clone). The failure direction is safe —
when the promisor is *unreachable* the probes fail and the unreadable-parent message fires — so
this is drift in the prose, not a hole in the check, and the drift predates this commit. It sits
in the paragraph this round rewrote, which is the natural moment to fix it. (The plan's "no
network" property is likewise a full-clone property, not a partial-clone one; unchanged by this
round, since `-e` lazily fetched too.)

*Action: implementer, when F4's spec question is resolved — narrow the sentence to the shallow
case, or say what a partial clone actually does (grades, by fetching, if the promisor is
reachable; fails naming the unreadable parent if it is not). No amendment needed:
`adoption/updating.md` is in Territory.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**One, and it carries its record.**

| Commit | Document | What changed | Record |
|---|---|---|---|
| `8c1bdad` | `specs/014-amendment-authority/tasks.md` | New `### Phase 5 remediation` section: the preamble stating that T086 crosses T081 and why, plus tasks T085–T088 (added already ticked) | `**Amendment approved by**: anas.m, 2026-09-17.` in the section; the commit body names "Approved by anas.m" for the same widening |

The record is well-formed, sits in the amended section, and agrees with the commit message; the
amendment check grades `8c1bdad` inside its own range and raises nothing. Two qualifications a
machine cannot make, both carried above rather than hidden here: the amendment ships inside the
commit it authorises (G5), and the *basis* the approval is recorded on is contradicted by the
evidence in the same paragraph (G2). `notes.md` is ungraded by design (D3b); `spec.md` and
`plan.md` are untouched — which leaves F4's divergence exactly where the previous review left it.

## Constitution re-check (post-implementation)

**PASS with one blocking finding outstanding** — re-evaluated against the code as built.

- **I Specification First / Amendment authority**: PASS on form (record present, well-formed,
  agrees with the message, graded green by the check itself). Two open questions of substance:
  G5's ordering, and F4 — `spec.md`'s FR-011 and US4 scenario 2 still promise unconditional
  arrival-day silence while `adoption/updating.md` documents the exception. F4 was explicitly
  excluded from this round; it remains for the owner.
- **II Source of Truth**: PASS. No digest marker changed, `build-digests.ps1 -Check` reports
  `5 digest(s) fresh, 80 marker(s)`, and the prose follows the code rather than leading it — with
  G6's pre-existing over-promise as the one exception.
- **III Repository Separation**: N/A, single-repo kit.
- **IV Architecture Consistency**: PASS. No new file, no new function, no new pattern, no package.
- **V Domain Invariants**: N/A — the kit's domain is its own governance.
- **VI Security**: PASS — read-only plumbing, argument-array invocation, no secrets, no new
  network surface (the lazy-fetch behaviour of a partial clone predates this round).
- **VII External Integration Governance**: N/A.
- **VIII Testing Requirements**: **engaged, and generalised one step short again.** Two new
  fixtures were built and they are real; the corrupt-object class was generalised from *one* way
  an object goes unreadable (garbage) to *the* way, exactly as the previous round generalised
  from deletion. G1 is the third instance of that same pattern on this feature, which is worth
  saying plainly: the fixture set keeps being one corruption mode behind the probe.
- **IX Human Review**: in progress — this is gate 5; gate 6 outstanding, and G5 is addressed to it.
- **X Controlled Delivery**: PASS on form — one commit, `phase 5` token, Territory respected,
  `scope-check` PASS. Note the non-blocking `PhaseSizeWarning` on `8c1bdad` (583 lines across 5
  files), driven by the 432-line review file and the notes, not by code: the script itself is
  +20/−12.

## Test coverage observed

No test framework — the kit's convention since 006. What exists for this round, and what I did:

- **The implementer's record (`notes.md`, phase 5 remediation):** a `cat-file` behaviour table
  (three probes × two damage modes) and two end-to-end reproductions. **Every cell of that table
  reproduced** on my own fixtures — deleted: `-e` 1, `-s` 128, `grep` 1; garbage: `-e` 0, `-s`
  128, `grep` 128 — as did both reproductions, including the `--depth 5 --no-single-branch`
  crash-versus-named-condition pair and the FR-009 arm. The claims are accurate as far as they go;
  the two that are not are "`-s` … fails exactly where a reader fails" (G1) and "no member's
  verdict moves" (G2).
- **Differential coverage I added, and what it found:** a **third** damage mode — a loose object
  truncated to 50 of 101 bytes — which the table does not carry and which defeats the new probe
  (G1); an unrelated-histories repository exercised on **both** lanes, which is how the Lite-lane
  verdict move surfaced (G2); a main-less repository as the control proving that silence
  pre-exists this change; a blobless partial clone with a reachable promisor (G6); and a
  41-commit arrival-day fixture used to price the proposed remedy against F3.
- **Regression coverage:** old script versus new over this repository — byte-identical output;
  the candidate remedy over this repository — byte-identical again; `scope-check -All` over the
  branch with no FAIL; `build-digests.ps1 -Check` fresh.
- **Not re-executed:** SC-002's replay over FitForge 001 and the S1–S14 fixture suite from phase
  2. Both changed probes are unreachable on a replay (`$graded = $true` before the presence set is
  built), so this round cannot have moved SC-002's result.

## Residual risk

The risk is concentrated in **G1**, and it is the same risk the previous review named: a condition
under which the amendment check prints a confident wrong reason and exits 0. It is real
(demonstrated end-to-end, not argued), narrower than last round's (the damage must spare the
object header), and one word from closed at no measurable cost. Until it is fixed the honest
sentence about the check is "it fails loudly when it cannot read history, **except** when the
object's header survives" — and three artifacts currently say otherwise, which is the part that
compounds it: a future reader of that comment has no reason to re-test the claim.

**G2** carries no correctness risk on the NNN lane and a narrow one on the Lite lane, where a
broken clone now buys silence instead of a crash. Its real weight is governance: an owner approval
is recorded on a basis the evidence contradicts, on the one feature whose subject is that records
must be true.

**G3**, **G4** and **G6** are small and independent. **F3** (batching cost, still unmeasured
against SC-006 in `notes.md`) and **F4** (the unamended spec) remain open from the previous review
by design, and gate 6 must still resolve F4 one way or the other.

Before merge: fix G1 (inside Territory, re-gradeable with the three-mode fixture above), correct
the two inaccurate records (G1's comment/notes wording, G2's approval basis), settle G3 and G4,
and let gate 6 judge G5 and F4 — including the one thing no machine here reaches, whether the
recorded approvals were real agreement rather than the implementing session's own convenience.
