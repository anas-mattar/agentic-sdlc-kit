# AI Code Review — 015 Enforcement Assurance, Phase 5 (round 3)

**Reviewer**: fresh-context agent — claude-opus-5[1m]
**Date**: 2026-09-20
**Branches**: agentic-sdlc-kit `015-enforcement-assurance` (tip `0647a1a`, parent `24e7100`)
**Scope reviewed**: the whole of `0647a1a` (5 files) — `scripts/ritual-checks.ps1`,
`scripts/scope-check.ps1`, `scripts/scope-check-repos.ps1`,
`specs/015-enforcement-assurance/notes.md`,
`specs/015-enforcement-assurance/ai-code-review-phase-5-round-2.md`. Also read, not changed by
this commit: the other six grading scripts (`doc-lint.ps1`, `enforcement-pack.ps1`,
`verify-kit.ps1`, `build-digests.ps1`, `roadmap-claim-check.ps1`, `territory-check.ps1`),
`tests/enforcement/emission-idioms.json`, `kit-manifest.json`,
`.github/workflows/ritual-checks.yml`,
`specs/006-verification-pack/{data-model.md,contracts/scope-check-cli.md,contracts/ritual-checks-ci.md}`,
`specs/012-cross-repo-scope-check/contracts/scope-check-repos-cli.md`,
`specs/015-enforcement-assurance/{spec,plan,tasks,notes}.md`, the round-1 and round-2 reviews,
`docs/sdlc/{definition-of-done,review-process}.md`, `.specify/memory/constitution.md`.
**Feature contract**: plan D4 (the pass word stays `OK`), D5, D6 (`UNGRADED` changes the verdict,
never the exit code), D7 (`PENDING` reserved), D9, D10, D11; FR-009 to FR-012; US3 acceptance
scenarios 1–3; `**Gate Certification**: ci-held`; phase-5 Territory = `tests/**` plus the nine
grading scripts (`tasks.md:230-241`).

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5[1m]
- **Implementer**: Claude Opus 5 (1M context) — the main implementing session that authored
  `0647a1a` (named in the commit's `Co-Authored-By` trailer). Not this reviewer.
- **Inputs provided**: `git show 0647a1a`, `git diff 24e7100 0647a1a`, the round-1 review
  (`ai-code-review-phase-5.md`) and the round-2 review
  (`ai-code-review-phase-5-round-2.md`), `CLAUDE.md`, `.specify/memory/constitution.md`,
  `docs/sdlc/definition-of-done.md`, `docs/sdlc/review-process.md`,
  `specs/015-enforcement-assurance/{spec,plan,tasks,notes}.md`, plus read-only execution of
  `scripts/ritual-checks.ps1`, all seven wrapper members under a deliberately unreadable
  `-Root` and a malformed argument, and a purpose-built stub-member harness in a scratch
  directory used to exercise the wrapper's derivation table five ways.
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — but the distance travelled since round 2 is real and should be said first.
The diagnosis in the commit message is right and is the best thing in the commit: *"Three drafts
asserted a property of the KIT. No such property exists. The property that does exist belongs to
this wrapper's derivation and is four lines of code long."* That four-step table is **correct**,
and I did not take it on trust — I built a stub-member harness and drove all five of its
predictions (precedence, whole-output matching, `WARN` never lifted, non-capture members ignored,
non-zero exit overriding output) and every one behaved as documented. All four of round 2's
counterexamples are now named by path and all four descriptions are accurate, including the
`verify-kit` unreachability argument, whose branch conditions I traced on both sides and found
sound. The commit is comments-only, and I proved it mechanically rather than by reading line
numbers: every changed line on both sides of the diff falls inside a `<# … #>` block, and the
three scripts' bodies below `#>` are byte-identical to their parents. Round 2's CONFIRM item 1
(the two stale `.DESCRIPTION` tables) is closed, and fixing it was in-scope, not gold-plating.

What stops an APPROVE is that the diagnosis was **not applied to the whole block**. Two
sentences in the same doc comment still assert a property of the kit, and both are false:

1. `ritual-checks.ps1:43-46` — *"exit 1 also carries an invocation error that produced no verdict
   at all (an unreadable `-Root`, a malformed argument), which every member spells `ERROR`"*.
   Six of the seven members spell it **nothing at all**: they die on an unhandled
   `Resolve-Path` exception. This sentence was written to close round 1's F2 and it is the
   answer to it; round 2 read it and accepted it without running it. I ran it.
2. `ritual-checks.ps1:94-96` — *"`scripts/territory-check.ps1` … and `scripts/update-kit.ps1` …
   are outside feature 015's Territory"*. `tasks.md:241` lists `scripts/territory-check.ps1`
   **inside** phase 5's Territory, and `spec.md:274-277` lists it among "the nine that decide a
   verdict". The claim is false for one of the two scripts it covers, and it is the load-bearing
   half: it is the stated reason FR-009 is left unmet for that script.

That is the same species round 1 and round 2 each found once — a checkable conformance claim
about the kit, in the file `kit-manifest.json:40` classes `verbatim`, which phase 6 will quote
outward to three adopted projects. The fix is again two sentences and touches no code. Three
items need an owner decision (F3–F5) and five are cheap hygiene (F6).

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Claim (f): comments-only | **Proved mechanically, not read.** Doc-comment boundaries: `ritual-checks.ps1` `<#` at `:1`, `#>` at `:112` (parent `:88`); `scope-check.ps1` `:1`/`:61` (parent `:53`); `scope-check-repos.ps1` `:1`/`:47` (parent `:39`). `git diff -U0 24e7100 0647a1a -- scripts/` hunks: new-side `35-38, 43-45, 57-101` / `14, 45-55` / `29-31, 33-39`; old-side max touched line `77` / `47` / `30`. Every hunk on both sides is inside the block. Independently: I extracted each file from `#>` onward at both revisions and diffed — **`IDENTICAL body` for all three**. No emission, no rule, no fixture, no `command.json`. |
| Claim (b): the verdict block prints four of the six words | **True, exercised.** Built a scratch root with six stub members and the real `ritual-checks.ps1` (members resolve under `-Root/scripts`). `WARN`: stub printing `scope-check: WARN something advisory`, exit 0 → `ritual-checks: scope-check OK`, `RESULT OK`. `PENDING`: repo-wide `grep -rn "PENDING"` (not just `scripts/`) returns hits only in `docs/roadmap.md`, `review/*.md`, `specs/**`, and the header itself — **no emission site anywhere, including `.github/` and `.specify/`**. So the block's alphabet is `OK`, `FAIL`, `n/a`, `UNGRADED`. |
| Claim (c): whole-output match, first hit wins, never "the last line" | **True, exercised twice.** Stub printing `scope-check: UNGRADED (early)` then `scope-check: PASS phase 1 commit abc1234 (7 file(s))`, exit 0 → `ritual-checks: scope-check UNGRADED (early)`. And live on the real repo: `pwsh -NoProfile -File scripts/ritual-checks.ps1 -Branch 015-enforcement-assurance` ends `scope-check`'s section on `scope-check: PASS phase 5 commit 0647a1a (5 file(s))` and still lifts `OK` — the round-2 counterexample reproduced on this very commit. |
| The four-step derivation table, step by step | **All four correct.** (1) Stub printing `scope-check: UNGRADED x` and exiting 1 → `scope-check FAIL`, `RESULT FAIL`, exit 1 — output not consulted. (2)+(3) Stub printing `scope-check: n/a (earlier line)` *before* `scope-check: UNGRADED (later line)` → `UNGRADED (later line)` — **`UNGRADED` outranks `n/a` regardless of order**, which is the `:195-199` precedence, not the `:176`/`:181` scan order; the header states the precedence and is right to. (4) A non-capture member (`doc-lint`) printing `doc-lint: UNGRADED nothing was compared`, exit 0 → `doc-lint OK` — confirming the `$captureMembers` bullet at `:78-80`. |
| Claim (d): all four counterexamples named and accurate | **All four accurate.** `territory-check.ps1:52-53,105,108,121` — `CLEAN —`/`OVERLAP with`/`no remote —`, `exit 2` on live overlap. `verify-kit.ps1:114` — `verify-kit: not applicable (this is the kit template, not an adoption)`; I traced the reachability argument on both sides and it **holds**: the decline needs `-not $hasKitVersion` **and** `-not (Test-Path kit-adoption.json)` (`:107-114`), while wrapper membership needs `.kit-version` **or** `kit-adoption.json` (`:144`) — the two conditions are disjoint, so the line can never appear as a member's output. `scope-check.ps1:259` — reproduced live (above). `enforcement-pack.ps1:1260-1262` — verdict line, then indented `  - <issue>` bullets. |
| Claim (e): the two `.DESCRIPTION` tables are accurate | **Substantively yes, with one imprecision (F6a).** `scope-check.ps1:14` `not applicable` → `n/a` matches `:282`. `scope-check.ps1:45-55` and `scope-check-repos.ps1:29-39` now list `UNGRADED` and drop the spelled-out form. I grepped every emission site in both scripts and cross-checked: `scope-check` run-level `n/a` at `:282,286,290`, run-level `UNGRADED` at `:278,304,309,323`, per-commit `PASS`/`WARN`/`FAIL`/`not applicable` everywhere else; `scope-repos` run-level `n/a` at `:304,332,336,340`, run-level `UNGRADED` at `:328,415`, per-repo/per-commit detail elsewhere. Both new prose paragraphs describe those correctly. |
| Claim (g)/(h): suite and gate | `pwsh -NoProfile -File scripts/ritual-checks.ps1 -Branch 015-enforcement-assurance` → seven member lines, `scope-repos` and `verify-kit` `n/a`, five `OK`, **`ritual-checks: RESULT OK`, exit 0**. Suite: see "Test coverage observed". |
| Anchors cannot be matched by detail lines | Re-verified independently of round 2. `scope-repos` per-repo lines are `scope-repos: <repo>: n/a …` (`:349,357,363`) — the `^scope-repos: n/a` anchor does not match. `scope-check` per-commit skips spell `not applicable` (`:111,150`), not `n/a` — so the anchor cannot be tripped by a detail line. Both are load-bearing and both hold today; the header now makes the hazard visible, which is an improvement. |
| Scope guard / Territory | `scope-check: PASS phase 5 commit 0647a1a (5 file(s))` (live). All five paths are inside phase 5's Territory (`tasks.md:232-241`) or `specs/015-enforcement-assurance/**` (implicitly in territory). |
| Constitution I (Amendment authority) | **No amendment owed and none claimed.** `git diff --numstat 24e7100 0647a1a` lists five files; `spec.md`, `plan.md`, `tasks.md` and `contracts/` are not among them. `notes.md` is an evidence log, not one of the approved documents constitution I governs; `ai-code-review-phase-5-round-2.md` is the reviewer's own text placed on the record. No self-approval occurred. |
| Constitution X | Subject carries `phase 5`. Five files, 652 insertions / 34 deletions, of which 578 are the two `specs/` documents; the code-comment delta is 74/34. Comfortably inside the guideline. Revertible by construction (comments only). |
| Security | Nothing. No network, no credentials, no writes, no interpolation added — the commit adds no executable text of any kind. Round 1's F7 (`$name` interpolated unescaped at `:176,181`) is unchanged and still latent-but-correct: no member name contains a regex metacharacter. |
| Visual-reference match | **N/A — no visual references exist.** `specs/015-enforcement-assurance/` has no `screenshots/`; the plan declares none. The Visual Compliance Loop does not apply. |
| Machine consumers of the changed words | None moved, because no word moved. Re-confirmed that nothing parses a verdict: `.github/workflows/ritual-checks.yml:44` runs the script and reads its exit code only. `docs/digests/*.md` carry no verdict vocabulary (`grep` → no hits), so no digest drift and `digests: OK (5 digest(s) fresh, 80 marker(s))` in the live run. |

## Findings

### F1 — The block still asserts a kit-wide conformance, and its own example disproves it: six of seven members print no `ERROR` on an unreadable `-Root` — BLOCKING

`scripts/ritual-checks.ps1:43-46`:

```text
      FAIL      The check ran and found a violation. It is the only word in this block that
                exits 1; exit 1 also carries an invocation error that produced no verdict at
                all (an unreadable -Root, a malformed argument), which every member spells
                `ERROR` and no member counts as a grade.
```

This sentence is the round-1 remediation's answer to round 1's F2 (*"`scripts/doc-lint.ps1:228,
233, 247` print `ERROR: …` and `:251` exits 1 — a seventh word"*). Round 2 read it and recorded
it as covering `verify-kit`; nobody ran it. Both of its two cited examples disprove it:

```console
$ for s in doc-lint enforcement-pack scope-check scope-check-repos build-digests verify-kit roadmap-claim-check; do
    out=$(pwsh -NoProfile -File scripts/$s.ps1 -Root /nonexistent/zzz 2>&1); code=$?
    echo "$s exit=$code hasERROR=$(echo "$out" | grep -c 'ERROR')"; done
doc-lint             exit=1  hasERROR=0
enforcement-pack     exit=1  hasERROR=0
scope-check          exit=1  hasERROR=0
scope-check-repos    exit=1  hasERROR=0
build-digests        exit=1  hasERROR=0
verify-kit           exit=1  hasERROR=1
roadmap-claim-check  exit=1  hasERROR=0
```

Six of the seven die on the unhandled exception at `$Root = (Resolve-Path $Root).Path`
(`doc-lint.ps1:43`, `enforcement-pack.ps1:102`, `scope-check.ps1:72`,
`scope-check-repos.ps1:60`, `build-digests.ps1:55`, `roadmap-claim-check.ps1:39`) and print a
PowerShell stack trace, not the word `ERROR`. Only `verify-kit.ps1:99` handles it
(`verify-kit: ERROR root not found: …`). The second cited example fails the same way:

```console
$ pwsh -NoProfile -File scripts/doc-lint.ps1 -NoSuchSwitch
doc-lint.ps1: A parameter cannot be found that matches parameter name 'NoSuchSwitch'.
  → exit=1, hasERROR=0     (same for scope-check.ps1 and build-digests.ps1)
```

This is exactly what the commit message says it purged: *"Three drafts asserted a property of the
KIT. No such property exists."* The diagnosis is right; it was applied to two paragraphs and not
to this one, which sits four lines above them in the same block. It is also the more dangerous
half, because it tells a future implementer that an invocation error is already surfaced in a
recognisable form — a reader who trusts it will not add the handler that would make it true.

The fix costs a clause. Either state the mechanism (`an invocation error exits 1 with the
member's own diagnostic; only verify-kit.ps1 spells it 'ERROR', the rest surface PowerShell's
own message`), or drop the conformance clause and keep only what is true: *exit 1 also carries an
invocation error that produced no verdict at all, and no member counts one as a grade.*

*Action: implementer — reword `scripts/ritual-checks.ps1:43-46` so no sentence claims a
uniformity across members that does not exist. Inside Territory; comments only; no amendment
needed.*

### F2 — `territory-check.ps1` is declared inside phase 5's Territory, and the block says it is outside — the false half of the sentence that excuses FR-009 — BLOCKING

`scripts/ritual-checks.ps1:94-96`:

```text
      - `scripts/territory-check.ps1` (`CLEAN`/`OVERLAP`, exit 2) and `scripts/update-kit.ps1`
        (an installer) are graders-adjacent but are not members of this wrapper, do not
        speak this vocabulary, and are outside feature 015's Territory.
```

Three of the four clauses are true. The fourth is false for the first script, and two approved
documents say so:

```console
$ awk 'NR>=230 && NR<=241 {print NR": "$0}' specs/015-enforcement-assurance/tasks.md
230: **Territory**:
232: - `tests/**`
233: - `scripts/enforcement-pack.ps1`
...
241: - `scripts/territory-check.ps1`

$ sed -n '274,277p' specs/015-enforcement-assurance/spec.md
- The scripts in scope are the nine that decide a verdict: `enforcement-pack.ps1`,
  `scope-check.ps1`, `scope-check-repos.ps1`, `doc-lint.ps1`, `verify-kit.ps1`,
  `build-digests.ps1`, `roadmap-claim-check.ps1`, `territory-check.ps1` and
  `ritual-checks.ps1`.
```

`scripts/territory-check.ps1` is in phase 5's Territory (`tasks.md:241`) **and** phase 4's
(`tasks.md:172`), and the spec calls it one of the nine verdict-deciding scripts, not something
"graders-adjacent". `update-kit.ps1` genuinely is outside Territory and genuinely is an
installer — the sentence is correct about it and round 2 verified that half. Lumping the two
together is what produced the error.

This is not pedantry about a parenthesis. The Territory clause is the *justification*: it is why
`territory-check.ps1` can be described as a known divergence and left alone, and it is the
support beam under the next line, *"Reconciling anything further is not this feature's work and
no task claims it is"* (`:103`). Remove the false clause and the justification is gone: the
script is in Territory, it is one of the nine, and FR-009 says every grading script must report
in the shared vocabulary. Whether to reconcile it, amend FR-009, or defer it with an owner's
signature is F3 — but the header must not answer that question with a fact that is not true.

*Action: implementer — correct `scripts/ritual-checks.ps1:94-96`. `territory-check.ps1` is
**inside** feature 015's Territory and is one of the nine scripts `spec.md:274` names; the reason
it is not reconciled here is a deferral (F3), not a boundary. Keep the `update-kit.ps1` clause as
written.*

### F3 — With the Territory excuse removed, FR-009 is openly unmet and nothing records the decision — CONFIRM

FR-009 (`spec.md:206-208`) reads: *"Every grading script MUST report in one shared verdict
vocabulary."* The nine are named in `spec.md:274-277`. As of `0647a1a` the header itself states
that two of them do not comply: `territory-check.ps1` (`CLEAN`/`OVERLAP`, exit 2 — "do not speak
this vocabulary") and, by the `WHAT THIS BLOCK DOES NOT CLAIM` framing, the spelled-out
`not applicable` in `verify-kit.ps1:114`. `roadmap-claim-check.ps1:57` is a third (round 2's F4,
deferred in `notes.md`).

I want to be plain that **narrowing the claim was the right move** — a documentation block that
lies is worse than one that admits a gap, and rounds 1 and 2 both said so. But the narrowing has
turned an implementation gap into a documented policy: `:103` now says *"Reconciling anything
further is not this feature's work and no task claims it is"*, and that is a statement about
FR-009's scope that no rung on the ladder authorises. Constitution II's conflict rule applies —
`spec.md` (rung) says every grading script; the header (code comment) says not these three. Stop
and report, not silently choose.

Three dispositions are available and all are legitimate: reconcile the three sites in phase 6;
amend FR-009 to "every **wrapper member**" with the approver recorded (constitution I); or record
an owner-signed deferral in `notes.md` naming all three. What is not available is the header
deciding it.

*Action: owner — choose the disposition for FR-009 vs `territory-check.ps1`,
`verify-kit.ps1:114` and `roadmap-claim-check.ps1:57`, and have it written where the next reader
will find it. Implementer — once chosen, make `ritual-checks.ps1:103` cite it rather than assert
it.*

### F4 — Round 2's F3 is half-discharged: two prior contracts and a prior data-model still describe verdicts the code no longer prints, and the deferral list does not name them — CONFIRM

Round 2's F3 named four stale locations and asked for two things: fix the two inside Territory,
and *"extend `notes.md`'s deferral list to name all four so the record is the complete one round
1's F1 asked for."* The first half is done and done well (F6a aside). The second is not: the new
`notes.md` section's **"Still deferred, still needing an owner decision"** list names the three
prose lines, `roadmap-claim-check.ps1:57`, and "Round 1's F3-F7 and F9" — and drops the two
contracts entirely. They are still stale, and there is a fifth location neither round found:

```console
$ grep -n "not applicable\|WARN\|UNGRADED" specs/006-verification-pack/contracts/scope-check-cli.md
16:| `-Branch` | … (detached HEAD yields a WARN no-op) |        ← now UNGRADED (scope-check.ps1:278)
22:   … → print `scope-check: not applicable (<lane> lane)`      ← now n/a (scope-check.ps1:282)
60:- S5: `fix/*` branch → not-applicable, exit 0.

$ grep -n "not applicable\|WARN" specs/012-cross-repo-scope-check/contracts/scope-check-repos-cli.md
36:| WARN | … detached HEAD without `-Branch` | 0 |              ← now UNGRADED (:328)
100:| C16 | … | run-level `n/a`, exit 0 |                         ← now run-level UNGRADED (:415)
102:| C11 | detached HEAD without `-Branch` | WARN, exit 0 |      ← now UNGRADED

$ grep -n "not-applicable\|OK/FAIL" specs/006-verification-pack/data-model.md
27:| `not-applicable` | Lite-lane branch (`fix/`, `chore/`, `docs/`) … | 0 |   ← now n/a
52:| Verdict block | one line per member: `ritual-checks: <member> OK/FAIL/WARN` … |
```

The last one is the sharpest, because **the new table cites it**: `scope-check.ps1:45` now reads
*"Verdicts and exit codes (data-model.md)"* and the document it points at describes a verdict
block of `OK/FAIL/WARN` — a set that omits `n/a` and `UNGRADED` and includes a word the wrapper
never prints. A corrected table citing an uncorrected source is a smaller version of the same
problem. `specs/006-verification-pack/contracts/ritual-checks-ci.md:23` has the same shape
(*"one line per member (OK/FAIL …)"*), though its `WARN` sentence is now exactly right.

These are prior features' approved documents, outside phase 5's Territory, and their disposition
is genuinely the owner's — as round 2 said. What is owed by this commit is the *record*.

*Action: owner — decide the disposition of `006`'s contract and data-model and `012`'s contract
(amend with an approver, mark historical, or fold into a phase-6 task). Implementer — extend
`notes.md`'s deferral list to name all five so the ledger is complete, and consider whether
`scope-check.ps1:45`'s `(data-model.md)` citation should stay while the cited table is stale.*

### F5 — The `roadmap-claim-check.ps1:57` deferral is the right call made with a wrong reason — CONFIRM

Round 2's F4 asked for *"either convert `:57` to `UNGRADED` … or record the declension in
`notes.md` with a reason"*. The commit takes the second branch, which is legitimate, and the core
of the reason is sound: converting an emission in a review remediation, with no fixture pair
written first, is precisely what plan **D11** forbids (*"the fixture is written and demonstrated
failing against the current implementation before the fix lands"*). Shipping it unproven here
would have repeated the phase's own lesson. I endorse the decision.

The reason as written overstates one clause. `notes.md` and the commit message both say the
conversion has *"no task"*:

> `scripts/roadmap-claim-check.ps1:57` calls an unreadable ledger `n/a`. … converting it changes
> a member's emitted word, which is a behaviour change with no task, no fixture pair and no
> before/after record (D11).

But `tasks.md:248-249` is T039: *"Emit `UNGRADED` from every member that can return without
grading, starting with `Invoke-ReviewProvenanceCheck` (FR-010)"* — and it is marked `[x]`. A
member that has proved an `origin` exists (`:52`) and then cannot read it (`:55-57`) has run and
formed no opinion; that is the header's own definition of `UNGRADED` at `:51-53`. So the task
exists, it covers the site, it is ticked, and the site is unconverted. The honest statement is
"T039 is not complete for this site and phase 6 or a follow-up will finish it", which is a
different sentence with a different consequence — it means a `[x]` in `tasks.md` is currently
overclaiming.

*Action: owner — decide whether T039 stands complete with this site excepted (and record the
exception), or is un-ticked pending phase 6. Implementer — correct the "no task" clause in
`notes.md` either way; "no fixture pair and no before/after record (D11)" is reason enough on its
own.*

### F6 — Five smaller inaccuracies, four of them new — MINOR

**(a) Both `.DESCRIPTION` tables present per-commit words as things the wrapper reads.**
`scope-check.ps1:45-48`:

```text
    Verdicts and exit codes (data-model.md). The vocabulary itself is defined once, in
    scripts/ritual-checks.ps1, which is also what reads this script's RUN-LEVEL line:
      PASS (a commit graded clean) / n/a / UNGRADED / WARN  -> exit 0
```

The colon attaches the list to *"reads this script's RUN-LEVEL line"*, but only `n/a` and
`UNGRADED` are ever run-level words in this script — `PASS` (`:190,259`), `WARN` (`:215,250`) and
`FAIL` are all per-commit, and the wrapper looks for neither. The paragraph below rescues the
reader, but the table is the part that gets quoted. `scope-check-repos.ps1:29-32` has the same
shape. A blank line or a "(run-level: `n/a`, `UNGRADED`; per-commit: `PASS`, `WARN`, `FAIL`)"
split fixes it. Neither table mentions `ERROR` (`scope-check.ps1:103,274`;
`scope-check-repos.ps1:183,207,313,324`), which also exits 1 — defensible, since the central
block defines `ERROR` as a non-verdict, but it is why `notes.md`'s *"each table now lists the
five words its script can reach"* is not true: each script can reach six, or seven counting the
per-commit `not applicable`.

**(b) The four-step table is not quite "the whole of the mechanism".** `ritual-checks.ps1:64`
says so, and there is a fifth path: `:203-205` synthesises a `verify-kit  n/a (no adoption
markers …)` verdict-block line for a member that never ran and has no exit code. It fired on my
live run of this very repository, so it is not hypothetical. The header *does* acknowledge it
twice elsewhere (`:24-25`, `:99-100`), which is why this is MINOR and not F1's class — but
"which is the whole of the mechanism" is the kind of exhaustiveness word this block has been
burned by three times. "…for every member that runs" would settle it.

**(c) `OK` is not printed by nine scripts.** `ritual-checks.ps1:40-42`: *"nine scripts, three
adopted projects and every gate record written to date already say OK (plan D4)."*
`grep -c 'OK' scripts/{scope-check,scope-check-repos,territory-check}.ps1` → **0, 0, 0**; six of
the nine print it. This one is *not* new and not the implementer's invention — it paraphrases
plan D4 verbatim (`plan.md:70-72`), which is an approved rung. Correcting the header would put it
at odds with the plan, so it needs either a plan amendment or a rewording that is true of both
("the kit has printed `OK` since feature 002 and every gate record says it"). Flagged for
completeness, not as this commit's debt.

**(d) `notes.md` overstates the table fix** — see (a): *"each table now lists the five words its
script can reach."*

**(e) Carried, unchanged, all previously dispositioned**: round 1's F3
(`emission-idioms.json:109` still says the `ritual-checks.ps1` site count *"is five"*; the
harness prints `6 of 6` — verified, the note is now three commits stale), F5 (the header uses
ASCII hyphens while every runtime string in the same file uses em dashes, still unexplained), F6,
F7, F9; and round 2's F6 (`emission-idioms.json:63`'s `doc-lint` accumulator is still
`(manifest|OK)` and does not inventory the `FAIL` line added in `377e6f4`). Round 2 suggested
folding F3 and F6 into this commit; the commit did not touch `tests/` at all, which is a
defensible "comments only" boundary. They are cheap and T044 makes coverage blocking.

*Action: implementer — (a), (b) and (d) are one-line edits inside Territory; fold them into the
F1/F2 rewrite. (c) is the owner's (plan D4). (e) before phase 6.*

### F7 — Fixing the two `.DESCRIPTION` tables when only F2 was asked for was correct scope — ACCEPTED

Recorded because the question was raised. Round 2's F3 action line said explicitly:
*"Implementer — update the two script `.DESCRIPTION` verdict tables in this phase
(Territory-legal, zero cost)."* Both files are in phase 5's Territory (`tasks.md:235-236`), both
were already open in this remediation, both carried **the same false claim F2 is about** in a
second and third place, and both are `verbatim`-class (`kit-manifest.json:40`) so the staleness
would have flowed down. Fixing the whole instance of a defect rather than the one instance named
is the same instinct round 2 praised in the F1 conversion. The edits changed no behaviour — proved
byte-for-byte in the evidence table.

*Action: none.*

### F8 — The derivation table, the precedence, and the three scripts' bodies are correct — ACCEPTED

Recorded positively because it is the substance of the commit and I tried to break it. The
mechanism paragraph (`:64-84`) is the first version of this block that is checkable, and it
checks out: five stub experiments, all matching; the precedence claim matches `:195-199` rather
than the scan order at `:176,181`, which is the subtle half and is stated correctly; the
`$captureMembers` bullet is true and the historical claim behind it is true too — at `377e6f4`,
`$ungradedCapableMembers = @('enforcement-pack')` and `scope-check.ps1:288` printed
`WARN … nothing checked`, exactly as the comment at `:162-165` says. The bodies below `#>` are
byte-identical to their parents in all three files, so the "no behaviour change" claim needs no
trust at all.

*Action: none.*

### F9 — `notes.md`'s round-2 section is an honest record — ACCEPTED, with (d) above

The failure mode worth hunting in a remediation log is a section that claims more than the diff
did, and this one mostly claims less. The counterexample table is accurate in all four rows (I
checked each against the source). *"What proves this one: Nothing. This commit changes comments
only … The suite and the gate are evidence that it changed nothing, which is exactly the claim"*
is the correct epistemic statement and is what a reader needs. The diagnosis section is candid
about three failed drafts. The two defects in it are narrow and named above: the *"five words"*
overstatement (F6d) and the *"no task"* clause (F5). Neither is spin; both are slips of the same
kind the commit is trying to eliminate.

*Action: implementer — fold the two corrections into the same edit.*

## Amendments in this diff

- [x] Amendments listed, or **none** stated explicitly

**None.** `git diff --numstat 24e7100 0647a1a` lists five files: three `scripts/*.ps1`,
`specs/015-enforcement-assurance/notes.md` (an evidence log, not one of the approved documents
constitution I governs) and `specs/015-enforcement-assurance/ai-code-review-phase-5-round-2.md`
(the round-2 review placed on the record). `spec.md`, `plan.md`, `tasks.md` and `contracts/` are
not in the commit. No `**Amendment approved by**: <name>, <YYYY-MM-DD>` line is owed, none is
claimed, and no self-approval occurred.

Two of my findings would change that if acted on the wrong way: F3's second option (amending
FR-009) and F6c's plan-D4 wording are both amendments to approved documents and would need an
approver recorded, with the implementing agent never self-approving (constitution I).

## Constitution re-check (post-implementation)

**PASS, with F1 and F2 outstanding** (documentation-accuracy findings, not constitutional ones —
except as they bear on II below).

- **I Specification First / Amendment authority** — satisfied. No approved document changed; no
  approver record owed; the places where an amendment *would* be needed are escalated (F3, F4,
  F6c) rather than self-approved.
- **II Source of Truth** — **engaged and not resolved.** `spec.md`'s FR-009 says every grading
  script; `ritual-checks.ps1:94-103` says three of them are outside the vocabulary and that
  reconciling them is not this feature's work. That is a rung-versus-comment conflict the
  conflict rule says to stop and report, which is F3. Also engaged for the two prior contracts
  and `006`'s data-model (F4).
- **III Repository Separation** — N/A, single governance repository, no `codeRepos` (live run:
  `scope-repos: n/a (no codeRepos declared …)`).
- **IV Architecture Consistency** — satisfied. No dependency, no script, no manifest class, no
  executable line at all.
- **V Domain Invariants** — N/A, the kit declares no domain-invariants pack.
- **VI Security** — satisfied; nothing executable changed.
- **VII External Integration Governance** — engaged. `006`'s and `012`'s CLI contracts describe
  verdicts the implementation no longer prints (F4); owner's call.
- **VIII Testing Requirements** — satisfied for this commit by construction: it changes no
  behaviour, so it needs no new fixture, and the suite proves nothing moved.
- **IX Human Review** — this document is gate 5, round 3; gate 6 is owed once, at merge.
- **X Controlled Delivery** — satisfied. One phase, `phase 5` in the subject, `scope-check: PASS
  phase 5 commit 0647a1a (5 file(s))`, trivially revertible. `**Gate Certification**: ci-held`
  means the owner's recorded approval on the CI evidence triplet is still outstanding; this
  review does not and cannot substitute for it.

## Test coverage observed

- **No test changed, and none needed to.** The commit touches no file under `tests/`, no
  `expected.txt`, no `recipe.json`, no `command.json`, no `rules.json`. The three scripts'
  executable bodies are byte-identical to their parents, which I proved rather than inferred, so
  the suite's job here is to confirm a null result.
- **Suite green and unchanged, run by me on a clean tree at `0647a1a`.**
  `pwsh -NoProfile -Command "Invoke-Pester -Path tests/enforcement -Output Minimal"` →
  `Discovery found 782 tests`, **`Tests Passed: 782, Failed: 0, Skipped: 0`**, 1534s, exit 0.
  Coverage: **`187 of 200 declared failure-emission site(s) inventoried across 9 grading
  script(s)`** — `scope-check.ps1 28/28`, `scope-check-repos.ps1 31/32`, `ritual-checks.ps1
  6/6`, `enforcement-pack.ps1 48/54`, `doc-lint.ps1 10/10 (3 unclassified)`,
  `territory-check.ps1 7/12`, `verify-kit.ps1 30/31`, `build-digests.ps1 19/19`,
  `roadmap-claim-check.ps1 8/8`. Both figures match claim (g) and `notes.md` to the digit, and
  both are identical to round 2's measurement at `24e7100` — which is the correct result for a
  commit that changes no executable line.
- **The claim "the suite is evidence that it changed nothing" is the right claim.** A
  comments-only commit cannot be proved by a new fixture; it is proved by the absence of
  movement, and that is what the run shows.
- **Known gaps, unchanged by this commit**: `roadmap-claim-check.ps1:57` has no case (F5);
  `doc-lint.ps1:257` is asserted by eight `expected.txt` files but is still not inventoried
  (round 2's F6, `emission-idioms.json:63`); coverage stays reporting-only until T044 per D9.

## Residual risk

Narrow and entirely in the prose, which is also the product. Two sentences in
`scripts/ritual-checks.ps1` still assert a property of the kit rather than of this wrapper — the
exact thing the commit message correctly identifies as the root cause of three failed drafts —
and both are disproved in under a minute: six of seven members print no `ERROR` on the
invocation error the block says they all spell `ERROR`, and `territory-check.ps1` is listed in
phase 5's own Territory by the `tasks.md` this phase is being graded against. The file is
`verbatim`-class, so both reach FitForge, flowboard and expense-tracker unedited, and T049–T051
will quote this block into `adoption/updating.md` and `docs/sdlc/review-process.md`.

**F3, F4 and F5 are the owner's** and none changes behaviour: FR-009 is now openly unmet for
three sites with no recorded decision; three prior-feature documents (two contracts and the
data-model the corrected table cites) still describe verdicts the code no longer prints and are
missing from the deferral ledger; and the `roadmap-claim-check.ps1:57` declension is right but
rests partly on a "no task" claim that T039 contradicts.

What is genuinely fixed is worth restating, because two rounds of REQUEST CHANGES can obscure it.
The mechanism paragraph is the first honest description of this wrapper's derivation that anyone
has written, and it survives being driven five ways from a stub harness. The four counterexamples
are named and accurately described, including a reachability argument about `verify-kit` that is
correct on both branch conditions. The two `.DESCRIPTION` tables were the right thing to fix and
were fixed inside Territory at zero behavioural cost. The commit is comments-only and provably
so. Correct the two sentences in F1 and F2, decide F3–F5, and the paragraph is finally done.
Gate 3 remains outstanding under `ci-held`: the owner's recorded approval on the CI evidence
triplet for `0647a1a`, which this review does not and cannot supply.
