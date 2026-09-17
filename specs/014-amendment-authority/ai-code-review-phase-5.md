# AI Code Review — 014 Amendment Authority, phase 5

**Reviewer**: fresh-context agent — claude-opus-5[1m]
**Date**: 2026-09-17
**Branches**: agentic-sdlc-kit `014-amendment-authority` (phase commit `a57fe3c`; branch tip at review time `d48ca10`)
**Scope reviewed**: the whole of `a57fe3c` (5 files) read as a diff and in the working tree —
`scripts/enforcement-pack.ps1` (`Test-CheckAbsentForReal`, `Get-CheckPresenceSet`,
`Invoke-AmendmentAuthorityCheck`, `Get-DiffBase`, the Dispatch block), `adoption/updating.md`
(working-tree lines 395–440), `docs/digests/adoption-digest.md`,
`specs/014-amendment-authority/{tasks.md,notes.md}`; the two amendment commits that set this
phase's standard (`1cff420`, `ca88da5`) and the gate record `d48ca10`; and — as ground truth the
prose is graded against — `specs/014-amendment-authority/{spec.md,plan.md,tasks.md}`,
`docs/sdlc/definition-of-done.md`, `docs/sdlc/review-process.md`, `kit-manifest.json`,
`.github/workflows/ritual-checks.yml`, `.github/workflows/project-gate.yml.template`,
`scripts/doc-lint.ps1` (scan scope only), and
`specs/014-amendment-authority/ai-code-review-phase-4.md` (finding F1, the phase's premise).
Not read line by line: `scripts/build-digests.ps1`, `scripts/verify-kit.ps1`,
`scripts/scope-lib.ps1` internals (exercised through `ritual-checks.ps1` only).
**Feature contract**: Standard lane; `**Gate Batching**: none`, `**Gate Certification**: ci-held`
(plan.md:4–5); zero new dependencies, read-only, `git` plumbing only, no network, and a verdict
that never changes with the calendar (plan, Technical Context); behaviour preservation is
explicit — "every existing pack message stays byte-identical; the new member only ever adds
failures of its own" (plan, Testing Strategy). Phase 5's declared Territory is three entries
(tasks.md:474–480).

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5[1m]
- **Implementer**: claude-opus-5[1m] (implementing session)
- **Inputs provided**: phase 5 diff `a57fe3c`, branch tip `d48ca10`,
  `specs/014-amendment-authority/spec.md`, `plan.md`, `tasks.md`, and the repository itself as
  ground truth; no `contracts/` — the feature has none. No implementer conversation, reasoning
  or commentary was provided, and none was requested.
- **Attestation**: This reviewer did not produce the diff under review.

> Disclosed rather than buried: the reviewer and the implementer carry the **same model id**.
> The separation held here is a fresh context — a session with no implementation history, which
> is what `docs/sdlc/review-process.md` (AI Review, step 1) sets as the minimum and what DoD
> gate 5 permits ("fresh-context agent session **or** a second model"). A second model would be
> stronger and the owner should weigh that when reading the verdict.

## Verdict

**REQUEST CHANGES** — the phase does the thing it set out to do, and it does it on measurement
rather than argument: I reproduced all four of its fixtures against the real script and the
Independent Test passes exactly as written (a `--depth 1` clone fails naming the shallow clone;
the full clone's verdict is unmoved; `fix/` and `docs/` on the same shallow clone still exit 0
with no `AmendmentAuthority` line). The unreadable-parent fix is real and I proved it by running
the pre-phase-5 script and the phase-5 script over the same deleted-blob fixture: the old one
graded 0 of 3 and let an unrecorded amendment through, the new one fails naming the parent. Two
findings stop it from merging, and both are members of the very family this phase exists to
close. **F1**: `Test-CheckAbsentForReal` proves *existence*, not *readability* — `git cat-file -e`
exits 0 on a present-but-corrupt object — so an object that `git grep` cannot read still lands in
`skipBoundary` and the run prints "3 made before the check existed (plan D2b)" and exits 0 with an
unrecorded amendment in the range; I have that as a fully green run on a structurally valid
fixture, and a one-character remedy (`-e` → `-s`) that closes it with no regression anywhere.
**F2**: in a shallow clone that *also* carries `origin/main` — the "build agent" configuration the
new message itself addresses — the pack dies at `Get-DiffBase` (`enforcement-pack.ps1:139`,
`.Trim()` on a null `merge-base` result) *before* `Invoke-AmendmentAuthorityCheck` is ever
called, so the adopter gets `You cannot call a method on a null-valued expression` instead of any
of the three named conditions, which falsifies the sentence this phase wrote into
`adoption/updating.md:428–430`. Neither fix leaves the declared Territory. Residual risk sits on
F1 (a silent green in the exact shape F1-of-phase-4 named) and on the untested arrival-day cost
(F3, measured at ~4x).

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | **FR-008** (a failure message names the condition and what to do): the three new messages each name the condition, the plan decision (D2b) and a remedy — held for the shallow and no-base conditions (runs below), **not** held for the shallow-plus-`origin/main` condition (F2) and **not** reached at all for a corrupt object (F1). **FR-009** (never fires on the Lite lane): run on the `--depth 1` clone with `-Branch fix/something` → `enforcement-pack: OK`, `EXIT=0`, no `AmendmentAuthority` line; same for `docs/something`. **FR-010 / D2c** (replay unaffected): the new probe sits inside `if (-not $graded)`, and `-IgnoreAmendmentBoundary` sets `$graded = $true` at line 1128, so the presence set is never built and `Test-CheckAbsentForReal` is never called on a replay — read at `enforcement-pack.ps1:1128–1135`. **FR-011 / US4 scenario 2**: now carries an exception the spec does not record (F4). |
| Visual-reference match (where references exist): Visual Compliance Loop deviation table attached, empty or user-approved (`docs/sdlc/review-process.md`) | **N/A, stated rather than skipped.** `ls specs/014-amendment-authority/` shows no `screenshots/` directory and the feature declares no Visual Inventory; `a57fe3c` touches one PowerShell script, two Markdown documents and two spec-directory files, and no UI surface. The loop has no input on this phase. |
| Feature contract held (no unapproved table/migration/permission/package) | `git show a57fe3c --stat`: 5 files, 138 insertions, 18 deletions. No dependency manifest, no new file under `scripts/`, no new script — `Test-CheckAbsentForReal` is a function added inside the existing `enforcement-pack.ps1`, matching plan Constitution Check IV. The added code calls only `git rev-parse`, `git cat-file`, `git ls-tree` — plumbing, read-only, no network, no calendar input, so D7's stability property is untouched. Plan's Source Code map allots phase 5 exactly `scripts/enforcement-pack.ps1` + `adoption/updating.md`; `docs/digests/` was added to Territory by the owner-approved amendment `ca88da5` before the phase commit. **One contract clause is bent, not broken**: "every existing pack message stays byte-identical" holds for the messages, but the *count line* now reports a different denominator in one condition (F1's corrupt-object case reports `graded 0 of 3` where the intact repository reports `graded 1 of 3`) — that is the pre-existing fail-open surfacing, not a new message. |
| Constitution / domain invariants | **I (Amendment authority)**: `a57fe3c`'s only touch of a graded document is six checkbox flips in `tasks.md` (T078–T083) — `git show a57fe3c -- specs/014-amendment-authority/tasks.md` filtered for non-checkbox changed lines returns nothing — so it is exempt under D3/FR-006 and owes no record. The two commits that changed the standard land **before** it and both carry records; see "Amendments in this diff". **II (Source of truth)**: `docs/digests/adoption-digest.md` changed by regeneration only (`ritual-checks` reports `digests: OK (5 digest(s) fresh, 80 marker(s))`); a digest is explicitly not a rung. **X (Controlled delivery)**: one phase, one commit, `phase 5` in the subject, independently revertible for its product files (below). The kit has no domain-invariant pack (plan Constitution Check, V: N/A). |
| Security (authn/authz, secrets, sensitive logging) | No authn/authz surface exists in this script. The new code passes `$Ref` to `git` as an **argument array**, never through a shell, so no injection path is opened; `$Ref` itself is a first-parent sha from `%P`, which is field index 1 of the `Get-CommitMetaBatch` format and therefore sits *before* the two message-derived fields the 5-way split cap protects (comment at `enforcement-pack.ps1:669–674`) — a crafted commit message cannot reach it. No secret, token, URL or path outside the repository is added; `git show a57fe3c \| grep -iE "secret\|token\|password\|api[_-]?key"` returns only the phrase "approval token" in prose. Matches plan Constitution Check VI. |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | `pwsh -File scripts/scope-check.ps1 -Commit a57fe3c` → `scope-check: PASS phase 5 commit a57fe3c (5 file(s))`. All 5 paths accounted for: 3 against the declared entries (`scripts/enforcement-pack.ps1`, `adoption/updating.md`, `docs/digests/`), 2 under the implicit `specs/014-amendment-authority/**`. `-All` over the branch: every phase commit PASS, the one pre-existing WARN on `3a51f5c`, no FAIL. `pwsh -File scripts/ritual-checks.ps1` → `RESULT OK` in 28.5 s (doc-lint, enforcement-pack, scope-check, digests, roadmap-claims all OK; scope-repos `n/a`; verify-kit `n/a`). |
| Rollback safety (phase reverts cleanly; schema additive?) | No schema, no migration, no data. `git show a57fe3c -- scripts/ adoption/ docs/ \| git apply --check -R -` → clean, so the three product files revert as a unit. `git show a57fe3c -- specs/ \| git apply --check -R -` fails on both `tasks.md` and `notes.md`, because `d48ca10` appended to the same tails; that is evidence and completion state, not product, and does not block reverting the phase. Reverting restores the phase-4 fail-open *and* the phase-4 prose together, which is the property the Territory decision was made to get. |
| Gate 3 evidence (ci-held) | Verified against GitHub rather than taken from `notes.md`: `gh run view 35230522696 --json headSha,conclusion,event,status,workflowName` → `{"conclusion":"success","event":"push","headSha":"a57fe3ce7a8f3df2df11163cdd6f9a7177e662e5","status":"completed","workflowName":"ritual-checks"}`. The triplet cites the phase commit itself on a push event, exactly as `docs/sdlc/gate-command.md` requires, and the split-push reasoning in `notes.md` is corroborated by `headSha`. |

**The Independent Test, executed rather than taken on trust.** tasks.md:466–468 states it: *"clone
the repository at `--depth 1`, run `scripts/enforcement-pack.ps1` on an `NNN-*` branch, and the run
fails naming the shallow clone. The same run on a full clone is unchanged, and the kit's own CI
verdict does not move."* All three arms, run in the scratchpad against the working-tree script
(identical to `a57fe3c` for all three product files — `git diff a57fe3c -- scripts/enforcement-pack.ps1 adoption/updating.md docs/digests/adoption-digest.md` is empty):

```text
git clone --depth 1 --branch 014-amendment-authority file://D:/solutions/agentic-sdlc-kit shallow
  enforcement-pack: branch '014-amendment-authority', diff base '', 0 changed file(s)
  enforcement-pack: FAIL (1 issue(s)):
    - AmendmentAuthority: cannot grade '014-amendment-authority' — this is a shallow clone, …
  EXIT=1                                                              ← arm 1 PASSES

git clone file://D:/solutions/agentic-sdlc-kit full   (branch 014-amendment-authority)
  AmendmentAuthority: graded 28 of 37 commit(s) … (9 not graded: 9 made before the check existed)
  enforcement-pack: OK   EXIT=0                                       ← arm 2 PASSES (9 ungraded,
                                                    the same 9 as 24/33, 26/35 and 27/36 elsewhere)

pwsh -File scripts/ritual-checks.ps1  →  RESULT OK                    ← arm 3 PASSES
```

**Negative space — what I looked for and did not find.** So the silence is informative rather than
accidental, these were tested and held. (a) The other two conditions the phase claims: a
repository with no `main` ref at all produces `no integration branch to diff against: neither
'origin/main' nor 'main' resolves here` and a repository with a parent commit whose blob was
deleted from `.git/objects` produces `parent commit 21e08f5 of fcdb750 is not readable in this
clone` — both exit non-zero. (b) The regression the fix could have caused: on an intact fixture
with a real unrecorded amendment after a real boundary commit, the check still grades 1 of 3 and
still names `fcdb750` — the boundary logic is unchanged for readable history. (c) The
before/after, on one fixture, with the actual pre-phase-5 script (`git show ca88da5:scripts/enforcement-pack.ps1`):
old → `graded 0 of 3 … 3 made before the check existed`, exit 0, amendment through; new → the
unreadable-parent failure. The commit message's claim is accurate and I could not find a way to
overstate it. (d) `git grep -l -F -e 'function Invoke-AmendmentAuthorityCheck' <ref> -- scripts/enforcement-pack.ps1`
on a deleted blob really does print `error: … unable to read …` to stderr **and exit 1**, not ≥ 2
— the premise of the whole fix, confirmed directly. (e) Blast radius: `fix/`, `chore/` and `docs/`
branches on the shallow clone exit 0 with no `AmendmentAuthority` line, so T081/FR-009 hold; and
`-IgnoreAmendmentBoundary`'s replay path never reaches the new probe (read, not run — SC-002's
replay is not re-executed by this phase). (f) Arrival-day exposure for adopters who use the kit's
own CI: `kit-manifest.json:23` classes `.github/**` **verbatim** and
`.github/workflows/ritual-checks.yml:26–29` carries `fetch-depth: 0`, so `update-kit.ps1` delivers
the full-history checkout with the check — the new failure cannot surprise an adopter running the
shipped workflow. (g) No file outside this repository was written at any point in this review;
fixtures live under the session scratchpad.

## Findings

### F1 — `Test-CheckAbsentForReal` proves existence, not readability: an unreadable object still reports "made before the check existed", green — BLOCKING

`enforcement-pack.ps1:741` is the readability probe the whole fix rests on:

```powershell
    git cat-file -e "${Ref}:scripts/enforcement-pack.ps1" 2>$null
    return ($LASTEXITCODE -eq 0)                                     # readable and without it, or unknown
```

`git cat-file -e` answers *"does an object with this name exist and is it of the expected type"*.
It does **not** inflate the object, so a loose object that is present but corrupt passes it while
every reader that must actually decompress the blob fails. Measured on a fixture built for the
purpose (a 4-commit repository: root on `main`, a `spec:` creation commit, a boundary commit that
introduces `function Invoke-AmendmentAuthorityCheck`, and an unrecorded `spec.md` amendment after
it), with the boundary commit's script blob overwritten by 7 bytes of garbage:

```text
$ git cat-file -e 21e08f5:scripts/enforcement-pack.ps1 ; echo exit=$?
exit=0                                        ← the probe says "readable"
$ git grep -l -F -e 'function Invoke-AmendmentAuthorityCheck' 21e08f5 -- scripts/enforcement-pack.ps1
error: inflate: data stream error (incorrect header check)
fatal: loose object 09e2e8d… is corrupt       ← exit 128; the presence set never gets the ref
$ git cat-file -s 21e08f5:scripts/enforcement-pack.ps1 ; echo exit=$?
fatal: git cat-file: could not get object info
exit=128                                      ← the probe that would have caught it
```

and the check, run on that fixture with the phase-5 script:

```text
enforcement-pack: branch '015-test', diff base '5b0659f…', 4 changed file(s)
AmendmentAuthority: graded 0 of 3 commit(s) in 5b0659f…..HEAD (3 not graded: 3 made before the check existed (plan D2b))
enforcement-pack: OK
EXIT=0
```

On the same fixture with the object intact, the run is `graded 1 of 3` and
`AmendmentAuthority: commit fcdb750 amends specs/015-test/spec.md after approval with no
conforming approver record`. So: an unrecorded amendment passes, the count line prints the
affirmatively wrong reason T080 was written to eliminate, and the pack exits 0 — F1-of-phase-4's
shape, reproduced inside the fix for F1-of-phase-4, with a narrower trigger. It is narrower
(object corruption rather than object absence), and that is the only thing separating this from a
straight regression; it is not a reason to leave it, because the phase's Goal is unconditional:
*"Where it cannot establish the boundary … it says which condition it met and fails."*

`Get-CheckPresenceSet`'s own fallback does not save it either: `git grep` exits 128 here, so the
`>= 2` branch **does** fire, but its per-ref probe is `git show`, which also fails, so the ref
still never enters the set — and then `Test-CheckAbsentForReal` affirmatively certifies the
absence.

The remedy is one character and I ran it rather than proposing it. Replacing the probe with
`git cat-file -s "${Ref}:scripts/enforcement-pack.ps1" *> $null` (it reads the object header and
therefore inflates) on a copy of the script:

```text
corrupt fixture  → AmendmentAuthority: cannot grade '015-test' — parent commit 21e08f5 of fcdb750
                   is not readable in this clone …                      (was: OK, exit 0)
intact fixture   → graded 1 of 3 … commit fcdb750 amends … no conforming approver record  (unchanged)
this repository  → graded 28 of 37 … enforcement-pack: OK                                 (unchanged)
```

*Action: implementer — change the blob probe from `git cat-file -e` to a reader that inflates
(`git cat-file -s`, redirecting both streams), and add the corrupt-object fixture alongside the
deleted-blob one in `notes.md`. `scripts/enforcement-pack.ps1` is already in phase 5's Territory,
so no amendment is needed.*

### F2 — a shallow clone that also carries `origin/main` crashes the pack before the new message can speak, and the message it would have printed names the wrong cause — BLOCKING

`adoption/updating.md:428–430`, written by this phase, tells the adopter:

> So on an `NNN-*` branch the check refuses to guess. **It fails, and names the condition it met**:
> a shallow clone, an `origin/main` that does not resolve, or a parent commit this clone cannot read.

There is a fourth condition, it is inside the first one, and it names nothing. `Get-DiffBase`
(`enforcement-pack.ps1:135–145`) runs in the Dispatch block at line 1227 — *before* any check
function — and line 139 is:

```powershell
            $base = (git merge-base HEAD $c 2>$null).Trim()
```

When `origin/main` (or `main`) **resolves** but `git merge-base` finds no common ancestor — the
shape a shallow fetch of two refs produces — `merge-base` prints nothing and exits 1, the
expression is `$null`, and `.Trim()` throws. Measured twice:

```text
$ git clone --depth 5 --no-single-branch file://D:/solutions/agentic-sdlc-kit depth5
$ git -C depth5 rev-parse --is-shallow-repository      → true
$ git -C depth5 rev-parse --verify --quiet origin/main → ab847ca…   (resolves)
$ git -C depth5 merge-base HEAD origin/main            → (nothing), exit 1
$ pwsh -File scripts/enforcement-pack.ps1 -Root …/depth5 -Branch 014-amendment-authority
enforcement-pack.ps1: You cannot call a method on a null-valued expression.
EXIT=1
   ScriptStackTrace: at Get-DiffBase, …\enforcement-pack.ps1: line 139
                     at <ScriptBlock>, …\enforcement-pack.ps1: line 1227
```

The second reproduction is a repository whose `main` and `NNN-*` branch have unrelated histories
— same crash, same line, and there the repository is not even shallow.

Two things follow, and both are this feature's signature defect class rather than a general
robustness gripe. **(a)** The sentence above is false for that checkout: nothing names a
condition, the operator sees a PowerShell null-reference error with no mention of fetch depth,
and FR-008's promise — "a developer must never have to read the script to learn what the check
wants" — is exactly inverted. The message the phase wrote for a build agent (*"or `git fetch
--unshallow` on a build agent"*) addresses precisely the agent that fetches `main` and the branch
shallowly, which is the configuration that crashes. **(b)** Even when the crash does not happen,
the no-base message asserts a cause it did not establish: *"neither `origin/main` nor `main`
resolves here"*. `Get-DiffBase` returns `$null` on two distinct conditions — no candidate ref, and
a candidate ref with no merge base — and the message states the first as fact. That is the same
N3/B1 lesson this branch has already learned twice ("state the condition you met, do not assert
one you never tested"), reappearing in a message added to close N3's cousin.

The safety property does hold: the run is red, not green, so nothing merges on a wrong pass. That
is why this is a defect in what the phase *promises* rather than in what it *protects*.

*Action: implementer — guard line 139 (`$base = "$(git merge-base HEAD $c 2>$null)".Trim()`, the
same `"$(...)"` idiom the phase already used for `--is-shallow-repository` at line 1077), and let
the null base fall through to the guards; then either split the no-base message into its two real
causes or reword it to say what it actually observed ("no merge base with 'origin/main' or
'main'"). `scripts/enforcement-pack.ps1` is in Territory. If the owner prefers to keep phase 5
minimal, the alternative is a roadmap row plus a correction to `adoption/updating.md:428–430` so
the prose stops promising a naming the code does not deliver — but leaving both as they are is the
one option this feature's own standard forbids.*

### F3 — the per-commit boundary probe undoes T024's batching for the pre-boundary segment; arrival day costs ~4x — CONFIRM

`Test-CheckAbsentForReal` runs up to three `git` child processes, once per commit, for every
commit before the boundary (`enforcement-pack.ps1:1139–1147`, inside `if (-not $graded)`). On this
branch that is 9 commits and the cost is small; on **arrival day in an adopted project every
commit on every in-flight branch is pre-boundary**, which is the case T024/SC-006 was written
about. Measured on a fixture with 61 commits on an `NNN-*` branch and no check anywhere in its
history (the literal arrival-day shape), pre-phase-5 script vs phase-5 script, two runs each:

```text
pre-phase-5: 4.02s, 3.73s
phase-5:    13.13s, 16.80s          ← same verdict: graded 0 of 61 (61 made before the check existed)
```

On this repository the same comparison is 9.50/9.35/8.49 s → 10.69/10.68/10.51 s, i.e. +1.6 s on a
28.5 s `ritual-checks` run (~5.6 %) — defensible on its own, and the number nobody has stated.
SC-006 asks for "no more than a small, **stated** fraction", and phase 5's `notes.md` records four
correctness fixtures and no timing. The cost is structural, not constant: three processes per
pre-boundary commit, linear in branch length, and it lands hardest on the exact run the D2b
boundary exists to keep quiet.

The fix is the one the plan already prescribes for this situation ("batch the plumbing calls, not
the granularity"): the probe is a pure function of a ref set known up front, so one
`git cat-file --batch-check` fed every unmatched parent, or one `git ls-tree` per unmatched
parent only when `git grep` actually reported an error, replaces N×3 processes with O(1).

*Action: owner decides — accept the cost with a measured line in `notes.md` against SC-006, or ask
for the probe to be batched. Either way SC-006 should not be signed off on the four correctness
fixtures alone.*

### F4 — `spec.md`'s FR-011 and US4 scenario 2 now have an exception that only `adoption/updating.md` records — CONFIRM

spec.md:215–217 (FR-011): *"MUST reach adopted projects through the existing verbatim update
channel, **requiring no per-project wiring**, and MUST pass silently on a project with no
amendments."* spec.md, US4 acceptance scenario 2: *"When the check runs over a branch with no
amendments, Then it passes silently — **arrival never turns an innocent project red**."*

After this phase, an adopted project whose CI fetches shallowly goes red on its first `NNN-*`
branch with zero amendments anywhere — which is why the phase had to add the "One exception"
paragraph at `adoption/updating.md:411–414`. `grep -i "shallow\|fetch-depth" specs/014-amendment-authority/spec.md`
returns nothing: the spec still promises unconditional silence, and neither `1cff420` nor
`ca88da5` amended it. The plan amendment that created phase 5 is owner-approved, but the plan's
own D3d reasoning applies against it — *"A plan decision may read the rule; it may not subtract a
class the rule says is in."*

This is narrower than it sounds and I checked the mitigation rather than assuming it:
`kit-manifest.json:23` classes `.github/**` **verbatim** and
`.github/workflows/ritual-checks.yml:26–29` ships `fetch-depth: 0`, so every adopter who uses the
kit's own workflow receives the full-history checkout in the same update that delivers the
failure. The exposure is the adopter who wrote their own workflow or fetches shallowly on a build
agent — precisely the reader the new paragraph addresses. (`project-gate.yml.template` has a bare
`actions/checkout@v4` with no `fetch-depth`, but it runs the project's gate chain, not
`ritual-checks`, so it is not a trigger.)

*Action: owner decides — either amend `spec.md` (FR-011 and US4 scenario 2) with the recorded
exception, carrying its own `**Amendment approved by**` line as constitution I requires, or accept
the divergence explicitly in the gate-6 human review. It should not merge with the spec and the
adopter documentation saying opposite things about arrival day.*

### F5 — `Get-CheckPresenceSet`'s doc comment is now orphaned above a different function — MINOR

The new function was inserted between an existing comment block and the function it documents.
`enforcement-pack.ps1:719–723` ends *"…one git call. `git grep` searches many trees at once and
prints `<rev>:<path>` per hit, so the boundary question that cost one 39 KB blob read per ungraded
commit now costs one process for the whole branch. Self-bootstrapping, as the per-ref version was:
the test is whether that tree's copy of THIS script defines the check function."* — and the next
thing in the file is the phase-5 comment and `function Test-CheckAbsentForReal`, with
`Get-CheckPresenceSet` following at line 745 with no separating blank line. A reader arriving at
line 719 now reads a description of batching immediately above a function that is deliberately
un-batched. Cosmetic, and in a file whose comments are load-bearing documentation for three
projects.

*Action: implementer — move `Test-CheckAbsentForReal` (with its own comment) below
`Get-CheckPresenceSet`, or re-head the batching comment so it sits against its function.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**In `a57fe3c` itself: none that owe a record.** The only graded document it touches is
`specs/014-amendment-authority/tasks.md`, and the change is six checkbox flips (T078–T083,
`- [ ]` → `- [x]`); filtering the diff for changed lines that are not checkbox lines returns
nothing, so the change is exempt under plan D3 / FR-006 and requires no approver. The check agrees
with me: `a57fe3c` is inside the graded range and `ritual-checks` is green.

**The standard phase 5 is graded against was changed by two earlier commits on this branch**, and
DoD gate 5 requires the review to say so:

| Commit | Document(s) | What changed | Record |
|---|---|---|---|
| `1cff420` | `plan.md`, `tasks.md` | Added the fifth phase: plan's phase-sizing paragraph, the Source Code map's two phase-5 rows, and the whole `## Phase 5` section (Goal, Independent Test, Territory, T078–T084) | `**Amendment approved by**: anas.m, 2026-09-16.` in both documents; subject names "approved by anas.m, 2026-09-16" |
| `ca88da5` | `tasks.md` | Phase 5 Territory gains `docs/digests/` | `**Amendment approved by**: anas.m, 2026-09-16.`; subject names "approved by anas.m, 2026-09-16" |

Both land **before** the phase commit, which is what the scope check requires and what makes the
`docs/digests/adoption-digest.md` path in `a57fe3c` lawful rather than self-legalised. `notes.md`
records the Territory miss in the implementer's own words and says "it needs a one-line amendment,
and not one I can approve" — the honest disclosure the clause is for. The half no machine reaches
stays with gate 6: the approver named is the owner, who is also the git author of every commit on
this branch, and nothing links a commit to the session that produced it (plan D10,
`adoption/updating.md:395–403`). That is a stated limit, not a finding.

**A related-but-separate note for the gate-6 reviewer**: `d48ca10` (the gate record, not part of
this phase's diff) flips T084 and appends the gate section to `notes.md`. Ticking T084 is exempt
under the same rule; `notes.md` is ungraded by design (D3b). Nothing owed.

## Constitution re-check (post-implementation)

**PASS with the two blocking findings outstanding** — re-evaluated against the code as built, not
against the plan-time check.

- **I Specification First / Amendment authority**: PASS on form — both amendments precede the
  phase commit and carry records with matching commit messages. F4 is the open question of
  substance: the spec was *not* amended where the behaviour now diverges from it.
- **II Source of Truth**: PASS. The digest changed by regeneration (`digests: OK … 80 marker(s)`),
  and the prose change in `adoption/updating.md` follows the code rather than leading it — which
  is the ordering phase 4's F1 got wrong and this phase got right, F2's sentence excepted.
- **III Repository Separation**: N/A, single-repo kit; `scope-repos` reports `n/a`.
- **IV Architecture Consistency**: PASS. One function added inside an existing script, no new
  file, no new pattern, no package.
- **V Domain Invariants**: N/A — the kit's domain is its own governance.
- **VI Security**: PASS — read-only plumbing, argument-array invocation, no secrets, no network.
- **VII External Integration Governance**: N/A — no external integration.
- **VIII Testing Requirements**: **engaged late.** The plan calls this business-critical
  governance logic where "a wrong PASS leaves the rule exactly as unenforced as it is today". Four
  deterministic fixtures were built and run, which is the convention; the two classes the fixtures
  did not cover are the two blocking findings (a present-but-unreadable object, and a shallow
  clone that carries `origin/main`). The fixture set generalised from *one* way a ref goes
  unreadable — deletion — to *the* way, which is the same generalisation error `notes.md` records
  the phase already making once ("a missing commit object is not the only way a ref goes
  unreadable") and stopping one step too early.
- **IX Human Review**: in progress — this is gate 5; gate 6 outstanding at merge.
- **X Controlled Delivery**: PASS. One phase, one commit, `phase 5` token, `Gate Batching: none`,
  `Gate Certification: ci-held` with the triplet verified against GitHub above.

## Test coverage observed

No test framework — the kit's convention since 006. What exists for this phase, and what I
re-executed:

- **`notes.md` phase-5 fixture table (4 scenarios, all re-run by me against the real script):**
  full clone (control, verdict unchanged), `--depth 1` (fails naming the shallow clone), no `main`
  ref (fails naming the unreachable base), deleted blob (fails naming the unreadable parent), plus
  the FR-009 arm (`fix/` on the shallow clone, exit 0, no `AmendmentAuthority` line). Every one
  reproduced; the counts are internally consistent (24/33, 26/35, 27/36, 28/37 all leave the same
  9 ungraded).
- **Differential coverage I added, and the two gaps it found:** the pre-phase-5 script vs the
  phase-5 script over the same deleted-blob fixture (proves the fix, and proves the old fail-open
  was real — old: `graded 0 of 3`, amendment through); a **corrupt-object** fixture (F1, not
  covered — green, exit 0); a `--depth 5 --no-single-branch` clone and an unrelated-histories
  repository (F2, not covered — crash); a 61-commit arrival-day fixture (F3, timing).
- **Regression coverage:** `ritual-checks.ps1` green on this repository (28.5 s, all members);
  `scope-check -All` over the branch with no FAIL; the candidate F1 remedy re-run against the
  intact fixture and this repository with identical verdicts.
- **Not re-executed:** SC-002's replay over FitForge 001 (`-IgnoreAmendmentBoundary`) and the
  S1–S14 fixture suite from phase 2. I read the code path instead and established that
  `-IgnoreAmendmentBoundary` sets `$graded = $true` before the presence set is built, so this
  phase's new code is unreachable on a replay and cannot have moved SC-002's result.

## Residual risk

The risk is concentrated in **F1**, and it is the specific risk this feature exists to abolish: a
condition under which the amendment check prints a confident wrong reason and exits 0. It is real
(demonstrated, not argued), narrow (a present-but-corrupt object rather than a missing one), and
one character from closed. Until it is fixed, the honest statement about the check is "it fails
loudly when it cannot read history, **except** when the object is there but unreadable" — which is
a sentence nobody would have written on purpose, and which the current `adoption/updating.md` does
not say.

**F2** carries no correctness risk — the build is red either way — and all of its risk is operator
cost: an adopter meeting a null-reference stack trace has no path from the message to
`fetch-depth`, which is the failure mode FR-008 exists to prevent, and the phase's own prose tells
them they will be told.

**F3** is a cost, not a defect, but it lands on the one day the feature promised would be
uneventful, and it is unmeasured in the record.

**F4** is a governance mismatch that gate 6 must resolve one way or the other: the spec and the
adopter documentation currently disagree about whether arrival day can turn a project red.

Before merge: fix F1 and F2 (both inside the declared Territory; both re-gradeable by re-running
the fixtures above plus the two I added), decide F3 and F4 at owner level, and let gate 6 judge the
one thing no machine here reaches — whether anas.m's recorded approvals on `1cff420` and `ca88da5`
were real agreement rather than the implementing session's own convenience.
