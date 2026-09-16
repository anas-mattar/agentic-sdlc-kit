# AI Code Review — 014 Amendment Authority (phase 3 remediation)

**Reviewer**: fresh-context agent — claude-opus-5
**Date**: 2026-09-16
**Branch/tip**: agentic-sdlc-kit `014-amendment-authority` (tip `fa396ee`; remediation `d606b2e`,
territory amendment `28d2f0a`, exemption `5d49cde`, records `0f76339` and `fa396ee`)

**Scope reviewed**: `git show d606b2e`, `git show 28d2f0a`, `git show 5d49cde`, `git show 0f76339`,
`git show fa396ee` in full, and `git diff 502cf55..5d49cde`; `scripts/enforcement-pack.ps1` at HEAD
— the `param` block at `:85-100` and the whole amendment member `:641-1068` read line by line,
plus `Get-VisiblePlanLines` (`:158-162`), `Invoke-ReviewProvenanceCheck` and the dispatch at
`:1077-1090`; `scripts/scope-check.ps1` (header "Matching", `:39-42`) and `scripts/ritual-checks.ps1`;
`scripts/doc-lint.ps1` scan scope; `.specify/memory/constitution.md` Principle I (Amendment
authority, Progress is not amendment, What can be verified) and the SYNC IMPACT REPORT `:5-31`;
`docs/sdlc/definition-of-done.md`, `docs/sdlc/review-process.md`, `docs/sdlc/gate-command.md`;
`specs/014-amendment-authority/{spec,plan,tasks,notes}.md` including the full 67-row B4 table
(`notes.md:668-760`) and the gate records (`notes.md:882-933`); all five prior reviews. In the
adopted project, **read-only**: `D:\solutions\fitforge` — `git show 3cb6e34` and a replay over
`bed2c26..db25cb7`. Nothing was written there.

**Executed**: **twenty-six fixture repositories of my own construction** under
`…\scratchpad\rev6\` (tables below); an independent re-derivation of both replays (my own
twelve branch ranges, derived from `main`'s merge commits); a whole-corpus cross-check of the
B4 table against my own flag list; two white-box differential tests of `Get-CheckPresenceSet`
(HEAD versus `502cf55`) in a shallow clone; a differential run of the pre-B7 pack
(`git show 502cf55:scripts/enforcement-pack.ps1`) over the comment fixtures; a CommonMark render
of every comment fixture through `marked`, so "a reader cannot see this" is a rendered fact and
not my assertion; a counterfactual scope-check in a throwaway clone; and
`pwsh -File scripts/ritual-checks.ps1` on a clean tree at `5d49cde`. I **did not read, execute or
rely on** the implementer's fixtures or harnesses under `…\scratchpad\{b1chk,b1fix,b2fix,d3d,p3rev}`,
`replay.ps1`, `classify.ps1` or `verify_ticks.ps1`. Every verdict below comes from something I built.

**Feature contract**: read-only; `git` plumbing only; zero new dependencies; no new file in
`scripts/`; every pre-existing pack message byte-identical; the verdict for a given commit must
never change with the calendar or the machine (plan, Technical Context + D6). **All of it holds** —
`git diff 502cf55..5d49cde --stat` touches four files, one of them a script that already existed,
no new git verb beyond `log -z`, `rev-list` and `grep`, and no message string changed.

## Reviewer Provenance

- **Reviewer**: fresh-context agent — claude-opus-5
- **Implementer**: claude-opus-5 — the session that produced the remediation
- **Inputs provided**: the three commits under review (`d606b2e`, `28d2f0a`, `5d49cde`) plus the
  two record commits (`0f76339`, `fa396ee`); `scripts/enforcement-pack.ps1` at HEAD;
  `specs/014-amendment-authority/{spec,plan,tasks,notes}.md`; all five prior reviews
  (`ai-code-review-phase-1.md`, `ai-code-review-phase-1-remediation.md`,
  `ai-code-review-phase-2.md`, `ai-code-review-phase-2-remediation.md`,
  `ai-code-review-phase-3.md`); `.specify/memory/constitution.md`;
  `docs/sdlc/{definition-of-done,review-process,gate-command}.md`;
  `scripts/{scope-check,ritual-checks}.ps1`
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — 4 blocking, 7 non-blocking.

Start with what this round actually closed, because it is the strongest engineering in the
feature so far and I confirmed every piece of it on inputs the implementer did not choose.

**B1 is closed, and closed at the root rather than patched.** A commit can no longer steer which
commits are graded: the set comes from `git rev-list` and a sha the metadata batch failed to parse
is a named failure, not a skip. I re-ran the fifth review's two attacks and two of my own —
self-hiding `0x1E`, targeted `0x1E`+sha overwrite, and `0x1F` field injection before and after the
sha — and all four are caught (fixtures `e1`–`e4`). The comment's central claim is true and I
tested it: `git commit -F` and `git commit-tree` both refuse a NUL with
`error: a NUL byte in commit log message not allowed`, so the record separator cannot be forged.

**B2 is closed.** `specs/060-p/contracts/café-api.md`, silently reinterpreted, is now flagged by
name — the check even prints the accented path correctly (fixture `f1`).

**B3 is closed, and I proved it differentially.** In a shallow clone with one unresolvable first
parent, `git grep` still aborts the whole search (exit 128, no output — reproduced). The
pre-batching function from `502cf55` returns a presence set of **0** on that input; HEAD's chunked
version with its per-ref fallback returns **2**, recovering both readable refs. The chunk
arithmetic is clean at n = 1, 2, 199, 200, 201, 400, 401 (no gap, no duplicate), and a 250-commit
branch whose silent amendment lands at commit 250 — past the first chunk boundary — grades
`250 of 250` and flags it.

**B4 is closed, and it is the best evidence artifact this feature has produced.** The 67-row table
exists, every row carries a verdict, and I cross-checked all 67 shas against my own replay rather
than reading them: the sha sets agree exactly, and the only two rows that no longer flag are
precisely the two the table itself marks **SPURIOUS**. My own independent replay — my own twelve
branch ranges, derived from `main`'s merge commits — returns **65 flags over 121 of 124 graded
commits**, matching the post-D3d figure feature by feature.

**And the classifier survived everything I threw at it.** D5, the trailer exclusion, the
subject-line approver (J4), and two identical same-day records (J1) all behave exactly as
specified on my fixtures.

So why REQUEST CHANGES.

**B7's fix reopened H1 — the oldest closed finding in this feature — and I can trigger it with one
line of prose.** `Get-VisibleFromText` now neutralises `<!--` inside anything its regex calls code,
and that regex treats *any* pair of triple-backticks as a fence, anywhere, across any distance.
Put one stray ` ``` ` in a sentence before a genuine block-level HTML comment and the comment's
markers are disarmed: the record inside it becomes "visible" to the check and invisible to every
reader. Demonstrated in a single commit, with a control that differs by exactly that one stray
marker and correctly FAILs, and with the rendered HTML showing the record living only inside
`<!-- … -->`. `502cf55` FAILs the same fixture. This is a regression introduced by `d606b2e`, it
fails **open**, and it is the same shape rounds 3 and 4 each closed once (K1).

**D3d is materially wider than the plan that authorises it says it is.** The exemption neutralises
*everything after* `**Status**:`, on *every* line that starts that way, in `spec.md` and `plan.md`,
at any point in the document's life. So an approved `plan.md` can gain "D2 is withdrawn; phase 2
Territory is now the whole repository" with no record, no approver and no mention in the commit
message — because it rode in on the status line. `plan.md:150-151` says "a commit that flips the
status **and** changes anything else still fails" and `notes.md:874` says "it cannot carry a
payload". Both are false, and I have the runs (K2). Worse, the exemption is not only broader than
the plan describes — it is broader than the constitution permits anything to be: Principle I states
its **one** exemption inside the rule "rather than left to the implementation" and says "Every
other change to an approved document is an amendment" (K3).

**And the gate record re-commits the error the round was fixing.** `fa396ee`, the newest commit on
the branch and the one that carries the ci-held evidence, names the five FitForge F3 amendments as
"`26d9108`, `7d3f297`, `8785678`, `92455d6`, `3cb6e34`" — `3cb6e34` again, `cff8c57` missing —
contradicting this round's own B6 correction 120 lines earlier in the same file (K4).

Residual risk has moved once more. The plumbing layer that held every finding last round is now
sound; I could not break `Get-CommitMetaBatch`, `Get-NameStatusBatch` or `Get-CheckPresenceSet` on
any input I could construct. The risk is back in the **text classifier** — the two places this round
touched it — and it is in the fail-open direction in both.

**On the process.** This round is the first where the branch's own check caught a defect five human
reviews had missed (B7), and the first where the evidence layer (B4) is verifiable end to end by a
stranger. Both are real progress. The pattern that persists is narrower and more specific: each
round's fix is validated against the shape that prompted it, and generalises worse than its comment
claims. B7's comment says "as a renderer would"; it is not what a renderer does, in either
direction. D3d's comment says "verified narrow"; it is narrow against the one payload shape the
author tried.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| **B1 — commit-set provenance** | **Closed.** Fixtures `e1`–`e4`: control silent amendment FAILs; the same amendment whose own message carries a bare `0x1E` FAILs (was a silent PASS); a `0x1F` field injection carrying a fake sha, empty parents and a date FAILs; a targeted `0x1E`+sha record aimed at an earlier commit leaves **both** commits flagged. The NUL claim is true — `git commit -F` and `git commit-tree` each print `error: a NUL byte in commit log message not allowed`. The field cap at 5 puts both message-derived fields last, so an injected `0x1F` can only shorten the message, and a shorter message can only make the D5 name test fail. The `$missing` assertion at `:955-960` is correct and, by construction, unreachable without a forged object. |
| **B2 — non-ASCII paths** | **Closed.** Fixture `f1`: `git log --name-status` emits `"specs/060-p/contracts/caf\303\251-api.md"` without the flag and the verbatim path with it; the reinterpreted contract is now flagged, and the failure message prints `café-api.md` correctly. The `Test-CheckboxOnlyChange` rider (`:857-860`) is present and matched in `Test-StatusOnlyChange` (`:889-890`). **Residual**: a path git quotes for reasons other than the high bit (an embedded `"`, `\`, or a control character) is still dropped by the `"$dir/*"` filter. I could not build one — Windows git refuses `Invalid path` at `update-index` — so it is analytic, cross-platform only, and not raised as a finding. |
| **B3 — presence batch** | **Closed, verified differentially.** `git grep` exit contract confirmed on this machine: 0 on match, **1** on no match, **1** on an unmatched pathspec, **128** on an unresolvable ref — so `-ge 2` is the right threshold and `$PSNativeCommandUseErrorActionPreference` is `False` under `pwsh -NoProfile` 7.6.6, so exit 1 does not throw. White-box test of `Get-CheckPresenceSet` in a shallow clone with refs `HEAD`, a missing object, `HEAD~1`: **`502cf55` → 0 present; HEAD → 2 present.** Chunk arithmetic exhaustive at n = 1, 2, 199, 200, 201, 400, 401 — full coverage, no duplicates. Fixture `g1`: 250 commits, silent amendment at commit 250, `graded 250 of 250` and flagged. |
| **B4 — per-flag judgement** | **Closed, cross-checked.** `notes.md:668-760` carries 67 rows, 67 unique shas, a verdict on every row. I extracted the shas and compared them against my own replay's flag list: identical, and the only two in the table not flagged today are `a9ddeb7` and `4e87018` — exactly the two rows marked **SPURIOUS**. (I did not re-derive each row's `+/-` figures or class label; I verified the sha set, the verdict coverage, and the two that matter.) |
| **B6 — SC-002 table** | **Partly closed.** The corrected table at `notes.md:786-790` is right: `cff8c57` present, `3cb6e34` removed and separately explained. But the uncorrected table at `:371` and `:517` still stands, and `fa396ee` added a **third** statement at `:912` that reverts to the wrong set. See K4. |
| **B7 — comment stripping** | **Not closed; the fix opened a new hole.** H1 (record in a closed comment) and J5 (record after an unterminated `<!--`) both still FAIL correctly on my fixtures `c1`/`c2`. The bug B7 was written for is fixed for the even-backtick case (`c3` PASSes). But `c9` is a demonstrated fail-open (K1) and `c4`/`c6` are demonstrated false FAILs (N1). Renderer verdicts come from `marked`, not from me. |
| **D3d — the status exemption** | **Implemented far wider than plan D3d describes.** The honest approval commit passes (`d1`) and a status flip carrying a smuggled `FR-002` on its own line fails (`d2`) — the two claims `notes.md` makes. But the payload rides on the status line itself (`d3`, `d10`), every `**Status**:`-prefixed line in the file is neutralised including one inside a fenced code block (`d11`, `d12`), and the exemption applies at any time, not only at the approval act. See K2/K3. The correctly narrow parts: a silent `plan.md` amendment in the same commit as an exempt `spec.md` flip is still flagged (`d7`); removing the status line does not qualify (`d9`); a rename of a `contracts/**` file whose only change is a status line is still graded (`d13`). |
| **D5 (record present, message silent)** | **Holds.** Fixture `h1`: the D5 message fires with its exact text. Fixture `h2`: an approver named **only** by a mandated `Co-Authored-By` trailer is rejected. Fixture `h3`: an approver named only in a `docs: …` subject is accepted (J4 stays closed). Fixture `h4`: two identical records, same approver, same day, two commits — both PASS (J1 stays closed). |
| **D10 (the check records; it does not authenticate)** | **Nothing in this round over-claims, with one exception of omission.** `plan.md` D3d explicitly leans on D10 for its residual-risk argument ("approval is proxied by a document's first appearance (D10) and never by this line"), which is correct. `notes.md`'s gate section states plainly that gate 5 is unheld. What is missing is the reverse implication: D3d now makes an *un-recorded* class of edit legal, and D10's "the record has the strength of a written claim" is a weaker guarantee than "no record needed at all". That gap is K2/K3, not a D10 overreach. |
| **`28d2f0a` ordering argument** | **The mechanism is right and the amendment was unnecessary.** `scripts/scope-check.ps1:41-42` states "The feature's own spec directory (`specs/NNN-name/**`) is always implicitly in territory", and constitution X says the same for the Micro bound. Counterfactual, run in a throwaway clone of the kit: a phase-3 commit touching `enforcement-pack.ps1`, `plan.md` and `notes.md`, whose parent's Territory names only `enforcement-pack.ps1` and `tasks.md`, returns `scope-check: PASS phase 3 commit b9aa74f (3 file(s))`. See N4. The ordering claim itself (territory read from the parent) is correct, and `0f76339` honestly corrects the "no phase token" error in `28d2f0a`'s own message. |
| **Does the branch pass its own check?** | **Yes, and for the right reason.** `graded 16 of 25` on the branch, no failure. Each of the three commits graded individually: `d606b2e`, `28d2f0a` and `5d49cde` each `graded 1 of 1`, no failure. The records are genuinely counted rather than accidentally carried: `tasks.md`'s `**Amendment approved by**: anas.m, 2026-09-16.` count goes `be27bbc` 0 → `d606b2e` 1 → `28d2f0a` 2, and `plan.md`'s record count goes 7 → 8 at `5d49cde` — so the J1 occurrence-count rule is what carries two of the three, exactly as designed. `5d49cde`'s `tasks.md` hunk (T069 tick) is checkbox-only and exempt; `fa396ee`'s (T070 tick) likewise. |
| **T063–T071 and the two records** | Conforming. Both `**Amendment approved by**: anas.m, 2026-09-16.` lines sit in the amended block, and all three commit messages name `anas.m` in body text that is not a trailer. `d606b2e`'s message states the approval in prose ("approved by anas.m on 2026-09-16 in session"); `28d2f0a`'s subject carries it; `5d49cde`'s body carries it. |
| **Gate / ritual-checks** | Reproduced. `ritual-checks` on a **clean** tree at `5d49cde` in my own clone: `RESULT OK`, all members green (`AmendmentAuthority: graded 16 of 25`, `scope-check` PASS on all three commits). This confirms `notes.md`'s own correction that the round's first local green was taken against a tree holding phase-4 edits. I could not verify CI run 35067823536 (no network access from this session); the triplet's shape and the push-event reasoning are correct on their face. |
| **Security** | Read-only. No new git verb beyond `log -z` (B1) and `show` in the B3 fallback. No writes, no network, no shell interpolation — `@chunk` is splatted as native arguments and its members are shas. The new `[regex]::Replace` callbacks are bounded and non-backtracking on the inputs I fed them (a 40 KB document with 200 fence markers returned in under a second). PASS. |
| **Rollback safety** | Reverting `5d49cde` removes `Test-StatusOnlyChange` and its two call sites cleanly; reverting `d606b2e` as well restores `502cf55`'s function set exactly. No signature reaches outside the file. No state, no schema. PASS. |
| **PowerShell correctness** | `-split $FS, 5` caps correctly (the 5th element absorbs the remainder), `$meta.Contains` on an `[ordered]` dictionary is case-insensitive and both sides are lowercase hex, `$LASTEXITCODE` is read immediately after each native call with nothing in between, `[Math]::Min` bounds the chunk slice, and `$unique[$i..$j]` on a single-element array is safe. The inline-span pattern embeds a literal newline inside its character class (`:786-787`) — valid, and it is what confines an inline span to one line. |
| **Pre-existing messages** | `git diff 502cf55..5d49cde -- scripts/enforcement-pack.ps1` changes no existing `$script:failures` string. The "not graded" line is the one string that changed, and it was changed deliberately under N3 of the fifth review. |

### Fixtures

All built by me under
`C:\Users\anas.m\AppData\Local\Temp\claude\D--solutions-agentic-sdlc-kit\83fd0c56-d853-4821-8090-0f47028ca0d3\scratchpad\rev6\`.
Each is a fresh `git init` whose `main` already carries the HEAD pack, so the D2b boundary is
genuinely crossed rather than lifted. `render.js` renders a fixture's `plan.md` through `marked`
and reports whether the record survives stripping every HTML comment from the rendered HTML —
so "a reader can/cannot see this" is measured, not asserted.

| Fixture | Shape | Reader sees the record? | Expected | Observed |
|---|---|---|---|---|
| `r0`, `e1` | silent amendment, plain message | — | FAIL | FAIL ✔ |
| `c1` | record inside a **closed** `<!-- … -->` | no | FAIL | FAIL ✔ (H1 holds) |
| `c2` | record after an **unterminated** `<!--` | no | FAIL | FAIL ✔ (J5 holds) |
| `c3` | honest record + a backticked `` `<!--` `` (even backticks) | yes | PASS | PASS ✔ (B7's own case) |
| `c4` | honest record + **odd** backtick count on the `<!--` line | yes | PASS | **FAIL** ✘ N1 |
| `c6` | honest record + `` `` <!-- `` `` (double-backtick run) | yes | PASS | **FAIL** ✘ N1 |
| `c5b` | record in an inline comment opened between **escaped** backticks | no | FAIL | **OK** ✘ K1 |
| `c7` | mid-line ` ``` ` pair around `<!--`, blank lines after | yes | PASS | PASS ✔ |
| `c8` | record only inside a ` ```text ` fence | yes (as code) | — | OK — J8, carried forward |
| **`c9`** | **one stray ` ``` ` in prose, then a genuine block-level comment holding the record** | **no** | **FAIL** | **OK** ✘ **K1** |
| `c10` | `c9` control — identical minus the stray ` ``` ` | no | FAIL | FAIL ✔ |
| `c11` | four-backtick quote before the comment | no | FAIL | FAIL ✔ |
| `d1` | owner's honest approval commit | — | PASS | PASS ✔ (D3d's purpose) |
| `d2` | status flip + smuggled `FR-002` on its own line | — | FAIL | FAIL ✔ |
| **`d3`, `d10`** | **payload written onto the status line itself** | — | FAIL | **OK** ✘ **K2** |
| `d11` | two status lines; flip one, rewrite the other's content | — | FAIL | **OK** ✘ K2 |
| `d12` | a `**Status**:` line inside a fenced block, rewritten | — | FAIL | **OK** ✘ K2 |
| `d5` | `Approved` → `Draft` | — | PASS (disclosed) | PASS ✔ |
| `d7` | exempt status flip + silent `plan.md` amendment, one commit | — | FAIL | FAIL ✔ |
| `d8` | status flip + trailing whitespace elsewhere | — | — | OK — N7 |
| `d9` | status line deleted + silent decision | — | FAIL | FAIL ✔ |
| `d13` | contract renamed, only the status line changed | — | FAIL | FAIL ✔ |
| `e2`, `e3`, `e4` | `0x1E` self-hiding / `0x1F` injection / targeted overwrite | — | FAIL | FAIL ✔ (B1) |
| `f1` | `contracts/café-api.md` reinterpreted | — | FAIL | FAIL ✔ (B2) |
| `g1` | 250 commits, amendment past the chunk boundary | — | FAIL | FAIL ✔ (B3) |
| `g2` | shallow clone, one unresolvable parent | — | — | presence 0 → **2** ✔ (B3); pack silent — N3 |
| `h1`–`h4` | D5 / trailer-only approver / subject approver / twin records | — | FAIL/FAIL/PASS/PASS | as expected ✔ |
| `kitclone` | counterfactual scope-check without the territory widening | — | — | PASS — N4 |

## Findings

### K1 — B7's neutralisation reopens H1: one stray triple backtick makes a record inside a genuine HTML comment count — BLOCKING

`scripts/enforcement-pack.ps1:784-787`:

````powershell
$neutralise = { param($m) ($m.Value -replace '<!--', '<!@@') -replace '-->', '@@>' }
$raw = [regex]::Replace($raw, '(?s)```.*?```', $neutralise)
$raw = [regex]::Replace($raw, '`[^`
]*`', $neutralise)
````

The fence pattern does not require a line start, does not require the two markers to be the same
length, and with `(?s)` will span any distance and any number of blank lines. It pairs triple
backticks strictly left to right, so a document with an **odd** number of triple-backtick runs
before a comment puts that comment *inside* a region the check calls code — and both of its
markers are disarmed. CommonMark does none of this: a stray ` ``` ` in a paragraph with no
partner in the same paragraph is literal text, and an HTML block of type 2 (a line beginning
`<!--`) interrupts a paragraph and hides everything through the line carrying `-->`.

**Reproduction** (fixture `c9`). One commit appends to an approved `plan.md`:

````text
**D3 — widened.** Nobody visible approved this.

A fence is opened with ``` and closed the same way.

<!--
**Amendment approved by**: ada, 2026-09-16.
-->

Here is a real block:

```text
foo
```
````

with `Amendment approved by: ada, 2026-09-16.` in the commit message. What a reader sees, from
`marked`'s own output:

````html
<p><strong>D3 — widened.</strong> Nobody visible approved this.</p>
<p>A fence is opened with ``` and closed the same way.</p>
<!--
**Amendment approved by**: ada, 2026-09-16.
--><p>Here is a real block:</p>
<pre><code class="language-text">foo
</code></pre>
````

The record exists only inside `<!-- … -->`. `render.js` reports `rendered-visible: NO`. What the
check says:

```text
### c9
    renderer: rendered-visible: NO
    pack:     enforcement-pack: OK
```

**Control** (fixture `c10`), byte-identical except that the sentence reads "A fence is opened and
closed the same way" — one stray ` ``` ` removed:

```text
### c10
    renderer: rendered-visible: NO
    pack:     enforcement-pack: FAIL (1 issue(s)):
              AmendmentAuthority: commit 2809970 amends specs/030-c/plan.
```

**This is a regression, not a pre-existing gap.** The same `c9` fixture under
`git show 502cf55:scripts/enforcement-pack.ps1`:

```text
=== c9 under the pre-B7 pack (502cf55) ===
AmendmentAuthority: graded 2 of 2 commit(s) in 642eb55…..HEAD
enforcement-pack: FAIL (1 issue(s)):
  - AmendmentAuthority: commit e6f45e8 amends specs/030-c/plan.md after approval with no
    conforming approver record. …
```

A second, independent trigger exists (fixture `c5b`): CommonMark treats `` \` `` as a literal
backtick, not a code-span delimiter, so a comment opened between two escaped backticks is a real
comment to a renderer and "code" to this regex. `rendered-visible: NO`, `enforcement-pack: OK`.

**Severity.** Fail-open, and it defeats the finding this feature has closed twice (H1 in round 3,
J5 in round 4). The evasion is a single line of ordinary prose in the same commit as the
amendment; it needs no unusual syntax, no control characters and no second commit. It is latent
rather than live — I scanned all 50 graded documents in this repository and all 9 in FitForge and
found **0** block-level comment openers that the neutraliser disarms today — but latency is not a
defence for a check whose purpose is to catch a change someone wants to slip past.

*Remedy: make the code regions structural rather than textual. A fenced block opens on a line
whose first non-space run is three or more backticks (or tildes) and closes on a later line whose
run is at least as long; an inline span pairs equal-length backtick runs on one line and honours a
preceding backslash. Then neutralise inside those regions only. Cheaper alternative that closes
both triggers without a parser: only neutralise a `<!--`/`-->` that is **not** at the start of its
line, since a line-initial marker is the only form that can open or close an HTML block — which is
exactly the form both K1 triggers rely on. Add `c9`, `c10` and `c5b` to the fixture table, and
pair every comment fixture with a rendered verdict so "what a reader sees" stops being an
assertion.*

### K2 — D3d exempts far more than the approval act: any content on any `**Status**:` line, at any time — BLOCKING

`scripts/enforcement-pack.ps1:884`:

```powershell
foreach ($l in $lines) { $out.Add(($l -replace '^(\s*\*\*Status\*\*:).*$', '${1}<status>').TrimEnd()) }
```

Everything after `**Status**:` is discarded before the whole-file comparison, on **every** line
that begins that way, in `spec.md` and `plan.md`, for the whole life of the document. Three
consequences, none of them stated in `plan.md` D3d or `notes.md`:

**(a) The status line can carry a payload.** Fixture `d10` — an already-approved `plan.md`, two
commits after its approval, amended with no record, no approver and nothing in the commit message:

```diff
-**Status**: Approved 2026-09-16 (owner: ada)
+**Status**: Approved 2026-09-16 (owner: ada). D2 is withdrawn; phase 2 Territory is now the whole repository; no approver was asked.
```

```text
### d10
    enforcement-pack: OK
```

Fixture `d3` does the same on `spec.md` at the approval commit ("FR-002 is withdrawn; the phase-2
Territory now covers the whole repository; the gate is ci-held") — also `OK`.

**(b) Every `**Status**:` line qualifies, not the header.** Fixture `d11`: a `spec.md` with two
status lines, one flipped to Approved and the other rewritten from "of the data model — draft,
pending review" to "the data model is normative and supersedes FR-001 entirely" → `OK`. Fixture
`d12`: a `**Status**:` line inside a ` ```text ` block in `plan.md`, rewritten to
"Approved - and D2 above is void" → `OK`. This is not hypothetical geometry: FitForge's own
`specs/001-solution-scaffold/plan.md` carries a `**Status**:` line for ADR-001 in section 4, which
this exemption now covers.

**(c) The exemption has no relationship to approving anything.** It fires on a commit made at any
time, in any direction, on any of those lines. `plan.md:153-154` discloses one half of this
("`Approved` → `Draft` is exempt too"); it does not disclose that the exemption is not tied to the
approval act at all.

`plan.md:150-152` states: *"Scope is deliberately narrow, and verified narrow: the exemption is a
whole-file comparison with the status value neutralised, so a commit that flips the status **and**
changes anything else still fails."* `notes.md:874` states: *"it cannot carry a payload."* Both
claims are falsified by `d3`, `d10`, `d11` and `d12`. The one payload shape the implementer tested
— a smuggled `FR-002` on its **own line** — is indeed caught (I reproduced it, fixture `d2`), and
it is the only shape the fixture table contains.

**Severity.** Fail-open, on `spec.md` and `plan.md`, the two documents the constitution names
first. It is less silent than K1 — the diff shows a changed status line — but a reviewer told by
the approved plan that such a diff "cannot carry a payload" is exactly the reviewer who will not
read it.

*Remedy: neutralise to a bounded token rather than to nothing. Either (i) require the new value to
match an approval vocabulary — `^(Draft|Approved|In Review|Superseded)\b` plus an optional
date/owner parenthetical — which is option (1) as the fifth review actually offered it, or (ii)
compare the status line's first word only and require the rest to be unchanged. Either closes (a)
and (c). For (b), confine the exemption to the first `**Status**:` line in the document's header
block, so an ADR's or a sub-section's status is graded like any other prose. Then correct
`plan.md:150-152` and `notes.md:874` to describe what the code does, and add `d3`, `d10`, `d11`
and `d12` to the fixture table as FAIL cases.*

### K3 — the D3d exemption is not ratified: constitution I states its exemptions in the rule, not in a feature plan — BLOCKING

`.specify/memory/constitution.md:200-217`, the clause this check exists to enforce:

> **Amendment authority**: once a feature's `spec.md` or `plan.md` has been approved, any later
> change to that feature's `spec.md`, `plan.md`, `tasks.md` or `contracts/` … MUST record who
> approved it.
>
> **Progress is not amendment**: a change to `tasks.md` that alters nothing but task completion
> state … requires no approver. … **Every other change to an approved document is an amendment**
> … This exemption is part of the rule rather than a detail of whatever grades it: without it the
> rule would demand an approval for finishing a task …

and the SYNC IMPACT REPORT at `:5-31`, which is the ratification record for this very clause:
*"One exemption, stated in the rule rather than left to the implementation."*

D3d adds a **second** exemption to a rule whose own text says there is one, and adds it in
`specs/014-amendment-authority/plan.md` — a rung below the constitution on the ladder
constitution II defines and `CLAUDE.md` restates ("Constitution … supersedes everything, including
this file"). The mechanism D3d invokes, plan decision D3a, is itself only a plan decision; it can
choose *how* the implementation reads the rule, but it cannot subtract a class the rule says is in.

The plan's legal argument is not frivolous and I want to record it fairly: the clause's scope
sentence binds changes made *after* approval, so the approval act may sit outside it. I accept
that reading **for the approval act**. But the code does not implement the approval act — it
implements "any change confined to a `**Status**:` line", which by K2 fires long after approval,
in either direction, on lines that have nothing to do with approval. Those are unambiguously
"later change[s] to that feature's `spec.md`, `plan.md`", and the constitution calls them
amendments.

This matters most because of where the feature is. Phase 4 is the adoption surface: whatever this
branch ships becomes the enforced reading of Principle I in every adopted project, and the rule
those projects ratified does not contain this exemption.

**Severity.** Fail-open against the ratified law rather than against the code's own spec, which is
the more serious of the two. It is also the cheapest to fix, because 014 has already amended the
constitution once and the mechanism is in place.

*Remedy (owner's choice, and it pairs with K2's): either (1) narrow the code to the approval act —
the first `Draft` → an approved form transition on the header status line — so it falls inside the
clause's existing scope sentence and needs no ratification, and say so in D3d; or (2) ratify the
exemption in constitution I with a MINOR bump, mirrored into `CLAUDE.md`,
`docs/sdlc/definition-of-done.md` and `docs/sdlc/review-process.md` as the SYNC IMPACT REPORT
requires, and record the human adoption. Option (1) is strictly less work and is what the fifth
review's B5 option (1) described. Either way, the sentence "This exemption is part of the rule
rather than a detail of whatever grades it" should gain a companion telling a future implementer
that D3a may not add exemption classes on its own.*

### K4 — the gate record re-commits the B6 error this round corrected — BLOCKING

`specs/014-amendment-authority/notes.md:912`, added by `fa396ee`, the branch tip and the commit
that carries the ci-held evidence for this remediation round:

| FitForge 001, `bed2c26..db25cb7` | **23 of 25 graded, 14 flags** | unchanged from the 2026-09-14 run; all five F3 amendments still fail, by sha — `26d9108`, `7d3f297`, `8785678`, `92455d6`, `3cb6e34` |

That is the pre-correction set. `notes.md:786-792`, written 120 lines earlier **in the same
round**, says the opposite and says it correctly: *"`3cb6e34` is removed from the table and is
**not** one of F3's five … F3's actual fifth, `cff8c57`, is absent from the table."* `fa396ee`'s
own commit message repeats the error ("all five F3 amendments still failing by sha").

My replay, read-only over FitForge:

```text
AmendmentAuthority: graded 23 of 25 commit(s) in bed2c26..db25cb7 (2 not graded: 2 merge commit(s))
AmendmentAuthority: commit 3cb6e34
AmendmentAuthority: commit cff8c57
AmendmentAuthority: commit 26d9108
…  (14 flags total)
```

`cff8c57` is flagged, so SC-002 remains substantively met — as it did last round. What is wrong is
again the record, and it is now self-contradictory within one file.

A second, newer error rides with it. `notes.md:792` explains the retained `3cb6e34` flag as *"It
does still fail the check — it touches `plan.md` and `spec.md` **beyond the status line**"*. After
D3d that is false for `spec.md`: the `spec.md` hunk is `Status: Draft` → `Status: Approved
2026-09-10 (owner: anas.m)` and nothing else, so it is now exempt. The flag survives on `plan.md`
alone, which I confirmed by reading the flag itself:

```text
- AmendmentAuthority: commit 3cb6e34 amends specs/001-solution-scaffold/plan.md
- AmendmentAuthority: commit cff8c57 amends specs/001-solution-scaffold/tasks.md
```

So `fa396ee`'s "unchanged from the 2026-09-14 run" is true of the totals and false of the detail:
D3d did change that flag's file list, which is the single most interesting thing the FitForge
re-run had to say about the new exemption, and it went unrecorded.

**Severity.** Blocking on the same ground the fifth review made B6 blocking: this is the evidence
the ci-held certification points at for the feature's headline criterion, and it is wrong in the
newest, most authoritative place it appears. It is also the cheapest finding here to fix — three
sentences.

*Remedy: correct `notes.md:912` to the five real shas; correct `:792` to say the `spec.md` hunk is
now exempt under D3d and the flag rests on `plan.md`; record that D3d changed `3cb6e34`'s flagged
file set, which is a real observation about the exemption and belongs in the evidence. Mark the
superseded tables at `:365-371` and `:509-519` as superseded, or drop the sha list from them, so a
reader arriving at either one is not left with the wrong set.*

---

### N1 — B7 is incomplete in the fail-closed direction: an odd backtick count still truncates the document — NON-BLOCKING

The same regex that causes K1 also fails to fire where it should. `` `[^`\n]*` `` pairs single
backticks left to right, so a line carrying an odd number of them leaves the last one unpaired and
any `<!--` after it un-neutralised — and the unterminated-comment rule at `:791` then discards the
rest of the file. Fixture `c4`, an honest record in a document that mentions the syntax:

```text
Use a ` to quote, and note that `<!--` is an opener.

**Amendment approved by**: ada, 2026-09-16.
```

```text
### c4
    renderer: rendered-visible: YES
    pack:     enforcement-pack: FAIL — commit 0693a0b amends specs/030-c/plan.md … with no
              conforming approver record
```

Fixture `c6` is the same shape via CommonMark's equal-run rule: `` `` <!-- `` `` is a genuine code
span to a renderer (run of 2 closed by a run of 2) and two empty spans to this regex, so the
`<!--` between them survives → `rendered-visible: YES`, pack `FAIL`.

This is exactly the bug B7 was written for, one backtick away, and it has the same consequence:
the rule becomes unsatisfiable in a document that discusses markdown syntax — which describes this
feature's own `tasks.md` and `notes.md`. I scanned all 50 graded documents at HEAD and **none**
currently loses content to the truncation rule, so it is latent today.

*Action: the structural fix in K1's remedy closes this at the same time. If only the cheap fix is
taken, add the equal-run requirement (`` (`+)[^`\n]*?\1 ``) and a backslash guard.*

### N2 — `Get-VisibleFromText` and `Get-VisiblePlanLines` have now diverged twice, under a comment saying they are the same — NON-BLOCKING

`:772-773` still reads *"Visible lines of a text blob — HTML comments stripped, same rule as
`Get-VisiblePlanLines` (008 phase-2 F1)"*. They are not the same rule and have not been since
phase 2: `Get-VisiblePlanLines` (`:158-162`) is still two lines with neither the
unterminated-comment rule (J5) nor the code neutralisation (B7). The practical consequence is the
one J5 named and left open — the `**Delivery Level**`, `**Gate Batching**` and
`**Gate Certification**` readers still take the one-character unterminated-comment evasion — and
the new consequence is that the two readers now disagree about the same file, which is how a rule
drifts silently.

*Action: J5's original action stands — collapse them into one helper. It is now more valuable than
when it was first raised, because there are two divergences to reconcile rather than one.*

### N3 — `-ReplayBase`/`-ReplayTip` are silently ignored when the diff base cannot be resolved — NON-BLOCKING

`:938`, `if (-not $Base) { return }`, runs before `:940` builds `$range`, which does not use
`$Base` at all when `-ReplayTip` is given. In a shallow clone `Get-DiffBase` returns empty, so an
explicitly requested replay grades nothing and says nothing:

```text
$ pwsh -File …/enforcement-pack.ps1 -Root <shallow clone> -Branch 070-c -ReplayBase <sha> -ReplayTip <sha>
enforcement-pack: branch '070-c', diff base '', 0 changed file(s)
enforcement-pack: OK
```

Not even the `no commits in range — nothing to grade` line appears. The replay is this feature's
evidence instrument for SC-002 and SC-004, and `notes.md:917-919` already warns about one silent
way to get a meaningless replay (the `-Root` trap); this is a second one it does not mention.
Analysis-only, so it cannot weaken a gate.

*Action: when `-ReplayTip` is supplied, skip the `$Base` guard (the range does not need it) and
require `-ReplayBase` alongside it. The whole-pack degradation in a shallow clone is pre-existing
and belongs to `Get-DiffBase`, not to this member.*

### N4 — the `28d2f0a` Territory amendment was unnecessary, and nobody tested the premise — NON-BLOCKING

`scripts/scope-check.ps1:41-42`: *"The feature's own spec directory (`specs/NNN-name/**`) is
always implicitly in territory."* Constitution X says the same where it excludes
`specs/NNN-name/**` from the Micro Territory bound. So phase 3 never needed `plan.md` declared,
reviewer N10's premise was wrong, and the amendment bought nothing.

Reproduced in a throwaway clone of this repository — a phase-3 commit touching
`scripts/enforcement-pack.ps1`, `specs/014-amendment-authority/plan.md` and `notes.md`, whose
parent's Territory block reads `**Territory** (unchanged): scripts/enforcement-pack.ps1,
specs/014-amendment-authority/tasks.md`:

```text
scope-check: PASS phase 3 commit b9aa74f (3 file(s))
```

Nothing harmful followed — the amendment is conforming, it was approved, and `0f76339` honestly
corrects the "no phase token" claim in its own message. What is worth recording is the pattern: a
reviewer's assertion was taken as fact and acted on with an owner approval, in the round whose
central lesson is that assertions get verified. `tasks.md:322-324` and `:355` and
`notes.md:850-853` now carry the false premise as settled fact, inside an approved document.

*Action: implementer — add one line to `notes.md` recording that the widening turned out to be
unnecessary and why, so the next person does not amend a plan to declare something the tool
already grants. Reviewer error, recorded against the review that made it.*

### N5 — the presence-batch fallback reports an unreadable parent as "made before the check existed" — NON-BLOCKING

`:742-750` falls back to a per-ref `git show` on an error exit, and a ref that fails there is
simply absent from `$presence`; `:991` then counts its child under `$skipBoundary`, and `:1065`
renders that as `N made before the check existed (plan D2b)`. In a shallow clone that sentence is
false — the parent may well carry the check; its object is merely missing. The fifth review's N3
asked for skip reasons to be *counted*, which this round did well for merges and roots; the fourth
reason it created in the same commit is folded into the third.

*Action: count a fourth reason — `N parent(s) unreadable` — and consider making it a failure
rather than a skip, since an unreadable parent is exactly the state where the boundary answer is
unknown rather than negative.*

### N6 — J7, J8, J9 and J10 remain open; a record inside a fenced block still counts — NON-BLOCKING

Re-confirmed rather than re-argued. Fixture `c8`: a commit silently widens `plan.md` and, in the
same diff, adds "Example of the record format:" with a filled record inside a ` ```text ` fence →
`enforcement-pack: OK`. J8 is unchanged and is now adjacent to K1, since both live in the same
function; a fix that makes fence detection structural should also decide whether fenced text is a
record at all. J7 (a deletion-only amendment has no legal way to be green), J9 (`\d+)` and `+` list
markers) and J10 (a record written as a list item) are untouched by this round and were not tasked
in it.

*Action: owner — these are law-surface questions as much as code ones and have now been carried
for two rounds. Phase 4 or a follow-up row, but a decision either way.*

### N7 — `.TrimEnd()` lets a trailing-whitespace change ride along on either exemption — NON-BLOCKING

Both `Test-CheckboxOnlyChange` (`:852`) and `Test-StatusOnlyChange` (`:884`) trim the end of every
line before comparing, so a commit may also add or remove trailing whitespace anywhere in the file
and stay exempt (fixture `d8`: a status flip plus three trailing spaces on the `FR-001` line →
`OK`). Trailing whitespace is not content and this is almost certainly the right behaviour; it is
simply undocumented, and "whole-file comparison" reads stricter than it is.

*Action: one clause in each comment. No code change.*

## Amendments in this diff

Two, both conforming, both graded rather than skipped.

| Commit | Amended document | Change | Record | Approver in the message | Graded |
|---|---|---|---|---|---|
| `d606b2e` | `tasks.md` | phase 3 remediation block, T063–T071 | `**Amendment approved by**: anas.m, 2026-09-16.` (count 0 → 1) | yes — "approved by anas.m on 2026-09-16 in session" | `graded 1 of 1`, no failure ✔ |
| `28d2f0a` | `tasks.md` | phase 3 Territory widened to `plan.md` | the same line (count 1 → 2) | yes — in the subject | `graded 1 of 1`, no failure ✔ |
| `5d49cde` | `plan.md` | D3d added | `**Amendment approved by**: anas.m, 2026-09-16.` (count 7 → 8) | yes — "the plan amendment approved by anas.m" | `graded 1 of 1`, no failure ✔ |
| `5d49cde`, `fa396ee` | `tasks.md` | T069 / T070 ticked | n/a — checkbox-only, D3 | n/a | exempt ✔ |
| `d606b2e`, `0f76339`, `fa396ee` | `notes.md`, `ai-code-review-phase-3.md` | not graded documents | n/a | n/a | n/a |

**Does the amendment conform to the rule it amends?** Yes, and — unlike round four — for the right
reason. Two of the three records are byte-identical to lines already in the file, and it is J1's
occurrence-count rule, introduced precisely for this, that carries them. I verified the counts
directly (`tasks.md` 0 → 1 → 2; `plan.md` 7 → 8) rather than inferring them from the green result.

**Ordering.** `28d2f0a` lands before `5d49cde`, which is correct for a Territory widening, and the
argument in its message about `scope-check` reading the parent is right. The widening itself was
not needed (N4), and its own message's claim to carry no phase token is false — which the
implementer found and corrected in `0f76339` rather than leaving. That correction is the right
instinct and should be read as such.

**What the records verify.** A written, well-formed claim that `anas.m` approved these changes,
agreeing with three immutable commit messages. Not that they did (D10, constitution I, "What can
be verified"). Gate 6 is where that is judged — and K3 is squarely a gate-6 question as well as a
code one, because the owner approving D3d in a feature plan is not the same act as the project
ratifying a second exemption to Principle I.

## Constitution re-check (post-implementation)

**FAIL** — on I and on VIII.

- **I Specification First** — the workflow order held, the amendments carry conforming records,
  and the implementer again refused to approve its own amendment (T069 was left `[ ]` in
  `d606b2e` and ticked only after the owner decided). That is the feature obeying its own law
  under real inconvenience, for the second round running, and it deserves recording. But the
  check now **exempts a class the ratified clause calls an amendment**, on the authority of a
  feature plan (K3), and it exempts far more of that class than the plan describes (K2). FAIL,
  remediable.
- **II Source of Truth** — the ladder is exactly what K3 is about: `plan.md` D3d subtracts from
  `.specify/memory/constitution.md` I. Conflict rule says stop and report, which is this finding.
  FAIL pending K3.
- **III Repository Separation** — single-repo kit; FitForge read, never written. PASS.
- **IV Architecture Consistency** — one new helper (`Test-StatusOnlyChange`) inside the existing
  script, no new file in `scripts/`, no packages. PASS, with N2's drift as the one note.
- **V Domain Invariants** — N/A.
- **VI Security** — read-only, no network, no secrets, no shell interpolation; the untrusted-input
  path the fifth review flagged (message text as delimited data) is now structurally closed. PASS.
- **VII External Integration Governance** — N/A.
- **VIII Testing Requirements** — "a wrong PASS leaves the rule exactly as unenforced as it is
  today." K1 and K2 are two wrong PASSes, and the round's own regression evidence — the replays —
  could not have caught either: neither shape occurs in the history replayed, which is precisely
  why the 33-scenario fixture layer was worth keeping. FAIL.
- **IX Human Review** — this review is gate 5 for the remediation round; gate 6 at merge.
  `notes.md:930-933` states plainly that gate 5 was unheld when the gate-3 evidence was recorded,
  which is the correct disclosure. PASS in process.
- **X Controlled Delivery** — one phase, revertible, `Gate Batching: none` and
  `Gate Certification: ci-held` honoured; the triplet names run 35067823536 on `5d49cde` with a
  push event. `ritual-checks` reproduces green on a clean tree at that commit (I ran it). PASS.

## Test coverage observed

No test framework (kit convention since 006). Three layers, and the balance between them has
shifted in a way worth naming.

- **Replay (T020/T021/T067).** Now the strongest layer by a distance, and the only one not
  authored by the implementer. I re-derived the twelve branch ranges from `main`'s merge commits
  myself and got **65 flags over 121 of 124 graded commits**, matching feature for feature; the
  FitForge replay gives **23 of 25 graded, 14 flags**, matching. The B4 table's 67 shas match my
  own flag list exactly, and the two it marks SPURIOUS are exactly the two D3d removed. This is
  the first round where a stranger can check the evidence end to end without rebuilding it.
- **Fixtures.** The 33-scenario suite is **gone** — `d606b2e`'s own message says so: "the
  33-scenario suite lived in a session scratchpad and no longer exists". That is the load-bearing
  gap this round. The replay cannot substitute for it: K1 and K2 are both absent from merged
  history by construction, because nobody has yet written a document to evade this check. Both of
  my blocking code findings came from fixtures, and neither could have come from a replay.
- **Instrumentation (T024).** Not re-measured this round and not claimed to be; the batching was
  not touched except at `Get-CheckPresenceSet`, whose fallback only fires on error.

The single most valuable artifact this feature could still produce is a **committed** fixture
corpus — even as a shell script under `specs/014-amendment-authority/` — so that "no verdict
changed" becomes a statement someone else can re-run. Three rounds have now lost their suites to
session scratchpads.

## Residual risk

**In the classifier, fail-open, in both places this round touched it.** K1 lets an author hide a
record from every reader while showing it to the check, for the cost of one stray ` ``` `. K2 lets
an author write anything at all onto a status line and have it exempted. Neither is reachable from
any document that exists today — I checked all 59 graded documents in both repositories — and both
are one commit away for anyone who wants them. Their common root is the same one the fifth review
named for the plumbing layer, applied one level up: a rule was written against the shape that
prompted it and a comment was written claiming it generalises.

**In the law.** K3 is the finding that should be settled first, because it decides K2's remedy. If
the exemption narrows to the approval act it needs no ratification and K2 largely dissolves with
it; if it stays as broad as the code makes it, it needs to be in constitution I, mirrored, and
adopted — and phase 4 is the phase that would carry it into every adopted project.

**In the record.** K4 is three sentences, and it is the second time the same table has been wrong
in the same way. The rest of the evidence layer is now genuinely good, which is what makes the
remaining error conspicuous rather than excusable.

**What must happen before merge**: K1 fixed and re-verified against a renderer, not against
intuition; K2 narrowed to match what `plan.md` claims, or `plan.md` and `notes.md` corrected to
match the code; K3 decided by the owner and, if the exemption stands as written, ratified in the
constitution with its mirrors; K4 written into `notes.md`. Then a fixture corpus committed, so the
next round's "no verdict changed" is checkable.

**What can follow merge**: every N finding. N2 and N3 are each a couple of lines and both remove a
silent failure mode from the tool that produces this feature's evidence.

---

## Dispositions (implementer, 2026-09-16)

Appended, not edited into the reviewer's text (`docs/sdlc/review-process.md` step 4).

| Finding | Disposition |
|---|---|
| **K1** — the B7 fix reopened H1 | **Fixed.** Code regions are now found structurally: `Get-FencedLineMap` walks lines as CommonMark does, `Convert-CodeSpanMarkers` pairs equal-length backtick runs within one line and skips a backslash-escaped run. Both triggers reproduced against the gated pack (`5d49cde`) and closed; `b7-quoted-marker`, `h1-comment` and `j5-unterminated` verified unchanged. |
| **K2** — D3d exempts more than the approval act | **Fixed.** The exemption is now the Draft → Approved transition on the document's first `**Status**:` line outside a fence, with the new value bounded to an approval form. All four fail-open fixtures (`d10`, `d11`, `d12`, reverse) now flag; both approval forms this repository has used still pass. |
| **K3** — the exemption is not ratified | **Fixed by K2's narrowing, not by ratification.** Narrowed to the transition that *starts* the rule, D3d subtracts no class from constitution I, so no amendment, MINOR bump or sync sweep is needed. Recorded in `plan.md` D3d. |
| **K4** — the gate record repeats the B6 error | **Fixed.** The sha list is corrected, the two superseded tables are marked, and the reviewer's second observation — that after D3d `3cb6e34` fails on `plan.md` alone — is recorded as evidence about the exemption. |
| **N1** — B7 incomplete in the fail-closed direction | **Fixed by K1's remedy**, which replaced the regex the finding is about. |
| **N4** — the `28d2f0a` Territory amendment was unnecessary | **Accepted, not reverted.** The counterfactual is convincing; the commit is immutable and harmless, and the correction is already recorded. |
| **N2, N3, N5, N6, N7** | **Open, deferred to the owner with the J-series.** None is fail-open on the amendment rule; N3 (`-Root`/replay parameters silently ignored) is the one I would take next, having hit it twice in one session. |

The reviewer's fixtures were not read or run while remediating; the fixtures behind the tables
above (`…/scratchpad/kfix.ps1`, `kfix-c5b2.ps1`) were built from the findings' descriptions, and
each fail-open case is reported as a differential against the pack as gated, so a fixture that
proves nothing shows up as "clean under both".
