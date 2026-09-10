# AI Code Review — 013 Critical Independence Signal — check logic (round 1)

**Reviewer**: fresh-context agent — `claude-opus-5` (Agent tool, `general-purpose`, task "Adversarial review of 013 check logic")
**Date**: 2026-09-10
**Branch**: `agentic-sdlc-kit` `013-critical-independence-signal`
**Under review**: phases 1-3, branch tip `b60b868`
**Scope reviewed**: `scripts/enforcement-pack.ps1`, `scripts/verify-kit.ps1`, `scripts/init-kit.ps1`, `specs/_templates/human-pr-review-template.md`, plus `spec.md`, `plan.md` and `docs/sdlc/critical-delivery.md` for the contract. Behaviour settled by building throwaway Critical-lane fixture repositories and running the check against them.
**Verdict**: REQUEST CHANGES — blocking findings: 2

Everything below the rule is the reviewer's report, **verbatim**. It is evidence for
Definition of Done gate 5 and is not edited to match what was later fixed; where a finding
was wrong, the reviewer's own next round says so. What was done about each finding is
recorded in `tasks.md`, not here.

---

I have everything I need. Here is the review.

## Reviewer Provenance
- **Reviewer**: fresh-context agent — claude-opus-5
- **Implementer**: the main session that produced this diff
- **Inputs provided**: 013 diff (scripts/), spec.md, plan.md, critical-delivery.md
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict
REQUEST CHANGES

## Findings

### BLOCKING 1 — Team mode accepts an uncommitted, untracked `human-pr-review.md`
`scripts/enforcement-pack.ps1:312-316` (`Invoke-CriticalTeamEvidence`)

The team arm reaches the artifact with `Test-Path` + `Get-Content` against the **working tree** and never asks git whether the file exists in history. The solo arm it replaces has an explicit guard for exactly this (`second-model-review.md has no git history — cannot verify the cooling-off period (commit it to start the clock)`, line 287-289). FR-006 says both identities "MUST be read from **committed** artifacts"; they are not.

This is not merely a local-run cosmetic. Critical features are forbidden from `ci-held` (critical-delivery.md item 4; `Invoke-GateCertificationCheck` enforces it), so a Critical feature's authoritative certification **is** a human-executed local run. That is precisely the run this hole is in.

Failure scenario (reproduced): fixture repo, `kit-adoption.json` = `{"developers":["a","b"]}`, `specs/007-x/spec.md` declares Critical, all phase files committed, then `specs/007-x/human-pr-review.md` written with a complete provenance block and **never `git add`ed** (`git status` shows `?? specs/007-x/human-pr-review.md`). `enforcement-pack.ps1 -Root <fixture> -Branch 007-x` → **exit 0, no CriticalEvidence line**. The independence evidence exists nowhere but one developer's disk.

Suggested fix: require the path to appear in `git ls-files -- <path>` (or `git log --format=%H -- <path>`) before parsing, mirroring the solo arm's history guard.

---

### BLOCKING 2 — A commented-out `## Review Provenance` block passes team mode
`scripts/enforcement-pack.ps1:316-341` (`Invoke-CriticalTeamEvidence`), `343-348` (`Get-ProvenanceValue`)

`$content` is the **raw** file. The kit already ruled on this class: `Get-VisiblePlanLines` (line 143) strips `<!--…-->` before parsing, and the header comment at line 149-152 states the rule as law — *"comment-stripped, so a commented-out 'Micro' (or 'Critical') decoy never sets the lane (contract M13)"*. The new team arm is the only machine enforcement of item 5 for team projects and it does not apply that rule. Separately, the attestation is matched against `$content` (line 338) rather than `$slice`, so it can be satisfied by text anywhere in the file — including inside a comment.

Failure scenario A (reproduced, fixture `A7`): team record; `human-pr-review.md` contains the heading `## Review Provenance` followed by the Reviewer/Owner/Attestation lines **entirely wrapped in `<!-- … -->`**. Rendered markdown shows no provenance whatsoever. → **exit 0**.

Failure scenario B — the accidental route (reproduced, fixture `D2`): take the shipped `specs/_templates/human-pr-review-template.md` verbatim, fill Reviewer=Alice / Owner=Bob, and delete the closing `-->` of the explanatory comment the template ships *inside that very section*. Everything after it renders as nothing. → **exit 0**. A single dropped `-->` in the template's own comment converts a filled block into an invisible one that the machine still blesses.

Failure scenario C (reproduced, fixture `A14`): provenance block filled with Reviewer/Owner but **no attestation line**; the sentence appears only inside an unrelated `<!-- reminder: … -->` at the top of the file. → **exit 0**.

Note: `Invoke-ReviewProvenanceCheck` (line 535-552) has the same comment-blindness, so this is a copied pattern rather than an invention — but 013 is where a *new* arm of a MUST-level rule was written on top of it, and contract M13 is the repository's stated position.

Suggested fix: run `$content` through the same `<!--…-->` strip before both the section slice and the attestation match; scope the attestation match to `$slice`.

---

### CONFIRM 3 — Duplicate developer names inflate the count into team mode; `Get-EvidenceMode` does not dedupe
`scripts/enforcement-pack.ps1:252` vs `scripts/verify-kit.ps1:269`

`verify-kit.ps1:269` deduplicates case-insensitively after `.Trim()` and its own remediation text names the hazard exactly: *"a duplicate inflates the count and can put a solo project into team mode, which is the one direction this feature must never move a project by accident."* `Get-EvidenceMode` does no such thing — it counts raw entries. `init-kit.ps1:282-283` also skips the `Select-Object -Unique` it applies to `codeRepos` (line 261).

Failure scenario (reproduced, fixtures `A3`/`A4`): `{"developers":["alice","Alice"]}` and `{"developers":["alice"," alice "]}` both put a genuinely solo project into **team mode** — the second-model review and the 24h cooling-off are dropped outright.

Mitigation that keeps this at CONFIRM rather than BLOCKING: team mode requires `kit-adoption.json` to exist, and `ritual-checks.ps1:73-77` adds `verify-kit` whenever that file is present, so the doctor's FAIL reddens the same run. But the two scripts disagree about what a developer is, `enforcement-pack.ps1` run on its own reports green, and the author fixed the hazard on the reporting side while leaving it on the enforcing side. The dedupe belongs in `Get-EvidenceMode`.

---

### CONFIRM 4 — A malformed top-level-array record selects team, contradicting FR-003
`scripts/enforcement-pack.ps1:243-253`

FR-003 and D2 say every degenerate record resolves to solo. PowerShell member enumeration defeats that for one shape: when the JSON root is an array, `$record.developers` flattens the property across elements and returns a real `[Array]`.

Failure scenario (reproduced, fixture `A5`): `kit-adoption.json` = `[{"developers":["a","b"]}]` — a record with no `schemaVersion`, `projectName`, `topology` or `gateProof` at all — selects **team mode**. A record this broken must, per FR-003, be solo.

Mitigation: the doctor FAILs such a record on the other required fields, so `ritual-checks` goes red. Still a direct violation of the feature's own load-bearing invariant, and cheap to close: require `$record -is [PSCustomObject]` before touching `.developers`.

Degenerate inputs I tried that **did** behave correctly (all → solo, all reproduced): no file; zero-byte file; unparsable JSON; `"developers": null`; `"developers": "alice"`; `{"developers":{"0":"a","1":"b"}}`; `[]`; `[1,2]`; `[{"name":"a"},{"name":"b"}]`; `[["a","b"]]`; record present with the field absent.

---

### CONFIRM 5 — Reviewer≠Owner is an exact string compare, and neither name is ever checked against the roster
`scripts/enforcement-pack.ps1:334`

`$reviewer.Trim() -ieq $owner.Trim()` catches only a byte-identical pair (modulo case/outer whitespace). Reproduced passes: `Reviewer: Alice` / `Owner: Alice.` (fixture `A9`, **exit 0**); `Reviewer: Alice Smith` / `Owner: Alice` (fixture `C4`, **exit 0**); `Reviewer: <U+200B>` / `Owner: Bob` (fixture `C5`, **exit 0** — a zero-width space is `\S`, so it survives the "filled" guard and is a legal reviewer name).

FR-007/D4 bound this honestly and I am not asking for GAP-019's fix here. What I am flagging is that spec.md's own **Edge Cases** raise a case the implementation never addresses and the code never mentions: *"A record naming developers whose handles do not match the identities used in the roadmap or the review document — the comparison must fail loudly rather than pass by accident."* The check reads the `developers` array only to count it; the roster names are never compared to Reviewer or Owner, so `Reviewer: X` / `Owner: Y` with neither in the roster passes silently. Either cross-check membership, or record in the header comment that the roster is a count and nothing more, so the next reader does not assume the edge case is covered.

---

### NIT 6 — A markdown-link reviewer name is rejected as a template placeholder
`scripts/enforcement-pack.ps1:330` (`$pair.V -match '^\['`)

Reproduced (fixture `A8`): `- **Reviewer**: [Alice Smith](mailto:alice@x.com)` → *"leaves '…' as a template placeholder — team mode needs the actual name"*. Fails safe, but the message is wrong and a linked name is idiomatic markdown. Tightening to `^\[[^\]]*\]\s*$` (or excluding `](`) would keep the placeholder catch.

---

### NIT 7 — Provenance values inside a fenced code block count
`scripts/enforcement-pack.ps1:343-348`

Reproduced (fixture `A12`): Reviewer/Owner supplied only inside a ```` ```text ```` fence within the section → **exit 0**. Lower impact than finding 2 (fenced content is at least visible when rendered), but the same parsing looseness.

---

### NIT 8 — Dead self-assignments
`scripts/enforcement-pack.ps1:280` and `:308` — `$dir = $Dir`. PowerShell variable names are case-insensitive, so `$dir` and `$Dir` are the same variable; both lines are no-ops. Harmless, but they read as if a rename is happening.

---

### NIT 9 — Doctor double-reporting and a silent mode line
`scripts/verify-kit.ps1:266-278`

`{"developers":[" "]}` emits two FAILs for one defect ("contains a blank or non-string entry" **and** "is empty", since the empty test is an `elseif` off the dupe branch, not off the blank branch). And `{"developers":["a","b",""]}` emits the blank FAIL but never reaches the `else`, so the run reports no evidence mode at all for a record that *is* in team mode. Restructure so the mode line is always printed once the array is an array.

---

## What I tried and could not break

- **Solo-mode message identity (finding shape 3 in the brief): clean.** I diffed `main`'s `enforcement-pack.ps1` against the branch's over all four solo paths — file missing, file present but untracked (no git history), file committed inside the cooling-off window (remainder arithmetic and the `0h ago … 24 h remaining` rendering), and one-developer record. Output is byte-identical, including exit codes. The move into `Invoke-CriticalSoloEvidence` is faithful.
- **Team mode cannot pass on silence.** Missing file, missing section, heading present but section empty, both names blank, one name blank, both placeholders, shipped template verbatim unfilled, and an old `second-model-review.md` offered in place of the human review — all fail with an accurate message. Finding shape 2 (a check that cannot legitimately pass) is not reintroduced: a real, filled `human-pr-review.md` passes (fixture `A11`, exit 0).
- **Header shadowing.** A `**Reviewer**: HeaderName` in the document header outside the block does not shadow the block's value; the slice regex correctly excludes it.
- **Parsing robustness.** CRLF files, the provenance section being last in the file with no trailing newline, a lowercase `## review provenance` heading with lowercase field names, trailing whitespace on the heading, and `## Review Provenance Block` (fails closed with two "no filled line" errors) all behave correctly.
- **Root/record location.** `kit-adoption.json` only in a parent of `-Root`, or absent, resolves to solo. No path found where `$Root` diverging from the git root relaxes the check.
- **init-kit round-trip.** `-Developers alice` serializes as `["alice"]` (not a bare string) under `ConvertTo-Json -Depth 4` in PS7 and reads back as an `[Array]`; an unsupplied `-Developers` writes no field and prints the honest "no developers declared" note. The deliberate refusal to default to `@($env:USERNAME)` is correct and correctly argued.
