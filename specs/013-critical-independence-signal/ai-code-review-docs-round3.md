# AI Code Review — 013 Critical Independence Signal — law and docs coherence (round 3, phase 5 remediation)

**Reviewer**: fresh-context agent — `claude-opus-5` (Agent tool, `general-purpose`, task "Review of 013 law and docs coherence (resumed)")
**Date**: 2026-09-10
**Branch**: `agentic-sdlc-kit` `013-critical-independence-signal`
**Under review**: phase 5, `43e52cf..9054e97`
**Scope reviewed**: the phase 5 diff, `scripts/adoption-lib.ps1` read as a document, the phase 4 blobs for comparison, and live fixtures.
**Verdict**: REQUEST CHANGES — blocking findings: 1

Everything below the rule is the reviewer's report, **verbatim**. It is evidence for
Definition of Done gate 5 and is not edited to match what was later fixed; where a finding
was wrong, the reviewer's own next round says so. What was done about each finding is
recorded in `tasks.md`, not here.

---

## Reviewer Provenance
- **Reviewer**: fresh-context agent — claude-opus-5
- **Implementer**: the main session that produced this diff
- **Inputs provided**: phase 5 diff (`43e52cf..9054e97`), `scripts/adoption-lib.ps1` read as a document, the phase 4 blobs for comparison, live fixtures
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict
REQUEST CHANGES

One new BLOCKING defect, introduced by phase 5 while fixing N4-placement: `adoption/greenfield.md` now tells every new adopter to run a command that silently produces the wrong record. Everything else you asked about is closed and verified, and the shared-library refactor is the right call — but its header makes one claim that is false today.

## Findings

### CLOSED — verified

**NEW-1 — the two scripts disagreeing. CLOSED, structurally.** Verified on live fixtures, both sides, on the exact case that exposed it:

| record | `enforcement-pack.ps1` | `verify-kit.ps1` |
|---|---|---|
| `[{"developers":["a","b"]}]` | solo | `FAIL … not a JSON object at its root` + `ok … 0 developer(s) — solo` |

They agree now because there is one function, not because a comment says so. `scripts/adoption-lib.ps1` is dot-sourced by both (`enforcement-pack.ps1:92`, `verify-kit.ps1:42`), `Get-EvidenceMode` is a one-line forwarder, and the doctor's whole rules block is gone. I also verified the `scope-lib.ps1` precedent the header cites is real: it is dot-sourced by both `scope-check.ps1:68` and `scope-check-repos.ps1:55`. This is the right fix — patching the second copy would have left the same hazard.

**NEW-2 — CLOSED, both halves verified.** `adoption/updating.md:378-381` now names non-string entries with `["ada",5,"grace"]` as the worked example, and I measured that shape as **team, count 2** — the doc is correct. The mode line now prints on the not-an-array branch: fixture `"developers": "ada"` produces `FAIL … not an array` **and** `ok … 0 developer(s) declared — solo`. Also confirmed `Add-Finding`'s ValidateSet is `'FAIL','WARN','ok'`, so the lowercase `ok` at the call site is the canonical value, not a typo.

**C1 — CLOSED.** `plan.md` D4's headline now reads "a different check, not a stronger claim", which matches the shipped header at `enforcement-pack.ps1:44-48` ("the strength of the Reviewer Provenance block, no more (FR-007)") and no longer exceeds FR-007's ceiling. The approver line is present and the superseded wording is preserved in the amendment note rather than erased — correct for an audit trail.

**C4 — CLOSED, and the wording is honest about what the code does.** `spec.md:104-112` states plainly that the roster is counted and never compared, that a review naming two people absent from the roster passes, and why. That is exactly what I measured. It replaces an unmet MUST with a recorded decision plus an approver. (One misattribution in it — see NIT-3.)

**N1-residual — CLOSED.** "the second row" → "the team arm" at `critical-delivery.md:111`.

**Rendered structure across everything phase 5 touched — checked, clean.** Zero non-uniform table rows across all six touched markdown files (escaped pipes discounted). The three new tables in `tasks.md`'s phase 5 section (2-col, 2-col, 3-col) are well-formed, at top level, blank-line delimited. Both new fenced/inline code spans are intact. No HTML comment sits inside a list, table, or paragraph anywhere in the diff. Full chain green: `doc-lint` OK, `digests` OK (5 digests / 73 markers), `scope-check` PASS, `ritual-checks: RESULT OK`.

**C2 — I confirm the follow-up ruling, and I looked again specifically because you asked.** Phase 5 did not widen the gap in the place that matters: item 5 still names `specs/NNN-name/human-pr-review.md`, **committed**, and the template now says "The file must also be COMMITTED — evidence in a working tree is not evidence", so the new committed-blob semantics are documented where a team will meet them. Re-reading the two untouched sentences: `definition-of-done.md:131` cites the template as the *checklist source*, which is correct usage and not misleading; the only genuinely wrong sentence is `review-process.md:121` — "Human reviewer checks (record in `specs/_templates/human-pr-review-template.md`)". That is **one sentence**, pre-existing, outside Territory. Follow-up stands. I would put it in the next Lite `fix/` rather than "soon" — the requirement is now strict enough (right path *and* committed) that a team landing the file wrong has two ways to fail.

### NEW — BLOCKING

**NEW-3 — `adoption/greenfield.md:48` instructs every new adopter to run a command that silently declares one developer named `ada,grace`.**

Line 44 establishes the invocation as `pwsh -File scripts/init-kit.ps1`. Line 48 then says: *"**Two or more developers? Pass `-Developers ada,grace` now**"*. Under `-File`, PowerShell passes arguments as literal strings; a `[string[]]` parameter receives **one** element. Measured, not reasoned:

```
pwsh -File <script> -Developers ada,grace   ->  count=1  ["ada,grace"]
pwsh -File <script> -Developers ada grace   ->  count=1  ["ada"]
pwsh -Command "& <script> -Developers ada,grace"  ->  count=2  ["ada"] ["grace"]
```

`init-kit.ps1` does no comma-splitting, so the record is written as `"developers": ["ada,grace"]`. I then ran that record through `Get-DeveloperMode`:

```
["ada,grace"]  ->  mode=solo  count=1  problems=0
```

**Zero problems.** A one-element array of a non-blank string is perfectly well-formed, so the doctor emits no FAIL — only `ok … 1 developer declared — solo`. Consequence: a genuine two-developer greenfield project follows the kit's own onboarding instruction, believes it has declared a team, and is silently held to the solo arm with no machine complaint anywhere. That is verbatim the failure `adoption/updating.md:384-389` says the doctor exists to prevent — *"a project could believe it declared a team for months while being checked as solo"* — reachable by following the instructions correctly.

The mode it lands on is the *safe* one, so this is not a security downgrade. It is BLOCKING because `greenfield.md` is a verbatim kit document shipped to every adopter, the instruction is copy-pasteable and wrong, its failure is silent by construction, and phase 5 introduced it (the phase 4 text said only "when you pass `-Developers`", with no invocation). Two fixes, either sufficient: split on commas inside `init-kit.ps1` (`$Developers -split ','`), which keeps the doc's `-File` idiom intact and is what I'd choose; or change the doc to the `-Command` form, which I verified works.

### NEW — CONFIRM / NIT

**NEW-4 (CONFIRM) — `scripts/adoption-lib.ps1:33-34` states a reason that is false.** The header says of `Problems`: *"the check ignores these, **because every problem already resolves to the strict arm**."* Measured counterexamples:

| record | problems | mode |
|---|---|---|
| `["ada","grace"," "]` | 1 (blank entry) | **team** |
| `["ada","grace","Ada"]` | 1 (duplicate) | **team** |
| `["ada",5,"grace"]` | 1 (non-string) | **team** |

Three of the seven shapes I measured produce a problem *and* team mode. The behaviour is right — a malformed-but-usable record still yields a definite mode, and `updating.md` describes that correctly. The *justification* is wrong, and it is load-bearing prose: it tells the next maintainer that ignoring `Problems` in the enforcing path is always safe, which is only true for the subset of problems that reduce the count below two. You asked me to name claims that will read as false in six months — this one reads as false today. Suggested: *"the check ignores these: a problem never makes a record produce a laxer mode than it would without the malformation, and the doctor is where malformation is reported."*

**NEW-5 (NIT) — the "different dedupe comparers" account is inaccurate, in three places.** `adoption-lib.ps1:12-13`, `verify-kit.ps1:255-257`, and `tasks.md` §"The drift, removed rather than corrected" all say the two copies *"used different dedupe comparers."* I checked the phase 4 blobs: `enforcement-pack.ps1@43e52cf:274` and `verify-kit.ps1@43e52cf:280` both used the byte-identical `Sort-Object -Unique -CaseSensitive:$false` for the count. The disagreeing comparers were both **inside `verify-kit.ps1`** — `Sort-Object -Unique` for counting versus `Group-Object { $_.ToLowerInvariant() }` for naming the duplicate (that was logic-review N6). So the cross-copy drift was one thing, the root-object guard, not two. The argument for the shared library is unaffected, but a maintainer who checks this story will find it does not hold and will trust the surrounding prose less. Fix: *"the root-object guard landed in the enforcing copy only, and the reporting copy used two comparers that disagreed with each other."*

**NEW-6 (NIT) — one piece of record interpretation still lives outside the shared function, in the file whose header says none does.** `adoption-lib.ps1:17-18` asserts *"Neither script interprets the record itself."* But `verify-kit.ps1:266` gates the whole block on `$null -ne $record.developers -or (Get-Content -LiteralPath $recordPath -Raw) -match '"developers"'` — a second, independent, raw-text notion of "does this record declare developers", living exactly where the previous drift lived. Two consequences today, both small: a record whose `projectName` is `"developers"` triggers a spurious `ok … 0 developer(s) declared` line; and a root-array record with no `developers` key never reaches `Get-DeveloperMode`, so the "not a JSON object at its root" problem the library computes is never reported (other dimensions still fail it, so nothing ships). Cleanest fix: return a `Declared` boolean from `Get-DeveloperMode` and gate on that, so the presence test is in the library too.

**NIT-3 — `spec.md:107-108` misstates a reviewer's position.** It says *"both fresh-context reviewers judged the disclosure in `scripts/enforcement-pack.ps1`'s header the right resolution."* I judged the **behaviour** right and the disclosure well written, but said explicitly that *"disclosure alone is not enough — amend the Edge Cases entry."* The amendment is what I asked for; the sentence credits me with a position I did not hold. In a governance artifact that records reviewer judgements, that matters. Suggested: *"both reviewers judged the behaviour correct; the docs reviewer required this entry to be amended rather than left as an unmet MUST."* I cannot speak for the logic reviewer's position.

**NIT-4 — `adoption/updating.md:388` is a 152-character run-on** in a file that wraps at ~90. Rewrap; purely cosmetic.

**NIT-5 — `plan.md` D4's amendment note runs inline into the decision headline.** No blank line separates `**D4 — …claim.**` from `**Amendment approved by**: …`, so GFM renders headline, amendment note, and the original reasoning as one continuous paragraph. A blank line plus a 2-space indent would make it a second paragraph inside the same bullet, matching how the phase 4/5 plan amendments are set. Renders, does not break — readability only.

### Your question: is `tasks.md` still usable as an evidence record?

**As an audit trail, yes — as a reviewer's entry point, no.** 543 lines, 32 KB, 27 headings. I say "yes" to the first half with evidence: every claim I spot-checked in it was findable and correct, the corrections are annotated rather than overwritten, and §"The pattern worth carrying forward" is the single most valuable paragraph in the feature. Do not delete any of it.

The problem is not length, it is **ordering plus the absence of a current-state view**. The file runs plan-1, plan-2, plan-3, results-1, gate-1, results-2, gate-2, results-3, gate-3, plan-4, results-4, gate-4, plan-5, results-5, gate-5. A reader asking the only question that matters at merge — *what does the code do now?* — must reconcile four tables written at four different times, and two of them are stale-by-design: the S1–S12 expectations table at line 15 predates two rounds of change, and the phase 2 doctor table at line 186 is still the document's primary "doctor results" table while carrying a row annotated `(was TEAM before phase 4)`, with the authoritative measurements 200 lines further down. I found the B2 defect on the first pass precisely because a table contradicted prose near it; a reviewer arriving cold at this file now has three more chances to make that mistake.

**Recommendation — do not restructure, add one section.** Insert a `## Current state (authoritative)` block immediately after the S1–S12 table containing: the measured record-shape → mode table (the phase 5 one), one line per FR and SC with its status, and a sentence saying everything below is chronological history in which earlier tables may have been superseded. Roughly 25 lines. Then add a back-pointer on the two superseded tables: "*superseded — see Current state*".

I deliberately do not suggest splitting the results into a sibling file: `CLAUDE.md`'s Feature Structure fixes the file set for `specs/NNN-name/` (spec/plan/tasks plus screenshots, contracts, data-model, research), and a `results.md` would be a layout the structure law does not sanction — the exact improvisation that law exists to prevent. Keeping the history in `tasks.md` behind a current-state header is both cheaper and compliant.

### Summary
Closed and verified: NEW-1, NEW-2, C1, C4, N1-residual, N4-placement (as a placement — see NEW-3 for what the move introduced). C2 confirmed as follow-up. Blocking: NEW-3 (`greenfield.md` invocation). New non-blocking: NEW-4 (false header justification), NEW-5 (inaccurate drift account in three places), NEW-6 (record interpretation outside the shared lib), NIT-3/4/5. The library refactor is the right response to NEW-1 and I would keep it exactly as structured.
