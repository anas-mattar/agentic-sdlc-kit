# AI Code Review — 007 Adoption Doctor (Phase 2: lifecycle hooks + Phase 1 addendum)

**Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
**Date**: 2026-09-08
**Branches**: agentic-sdlc-kit `007-adoption-doctor` (tip 61869bc)
**Scope reviewed**: full diffs of 61869bc and 8b033b7; `scripts/init-kit.ps1`, `scripts/update-kit.ps1`, `scripts/verify-kit.ps1` (complete, as at 61869bc); `adoption/greenfield.md`, `adoption/existing-system.md`, `adoption/updating.md`; `specs/007-adoption-doctor/` spec.md, research.md (D1/D6/D8), data-model.md, quickstart.md (L1–L6), contracts/verify-kit-cli.md (V8 as amended), tasks.md (T006–T012 + validation records); `specs/004-kit-update-channel/contracts/update-kit-cli.md`; `docs/roadmap.md` header; constitution `**Version**` line
**Feature contract**: doc+script phases only, no application code, no new dependencies; doctor read-only; update-kit exit codes unchanged

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
- **Implementer**: Claude Fable 5 (main session that produced commits 8b033b7/61869bc)
- **Inputs provided**: commits 8b033b7 + 61869bc diffs; specs/007-adoption-doctor/ governing artifacts (spec, research, data-model, quickstart, contract, tasks); full current text of the three touched scripts and three adoption docs; specs/004 update-kit contract; scratch-fixture re-runs (git archive of 61869bc + clone of the branch, under the session scratchpad — kit repo untouched)
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — the phase delivers what US2/FR-003/FR-005/FR-006 ask for (durable adoption record, doctor at both lifecycle moments, exit-code set unchanged, `-Json` purity preserved), and the doc amendments are largely accurate against actual behavior. But two empirically confirmed defects block: the phase-1 addendum's dim-5 rewrite crashes verify-kit with `ERROR` (suppressing every finding) on a `.kit-version` the amended contract V8 explicitly declares healthy (7–11-char `kitCommit`), and init-kit unconditionally overwrites an existing `kit-adoption.json`, silently destroying the human gate-proof attestation — a destruction path the existing-system track's own step ordering walks straight into. Residual risk sits in the record's lifecycle (F2, F3) and in stale exit-code documentation in the 004 contract (F4).

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-003: fixture init run wrote `kit-adoption.json` with name/topology/tiers/date/version, `gateProof: []`; single `-Tiers backend` produced a JSON **array** (`"tiers": ["backend"]`) — no ConvertTo-Json scalar collapse. FR-005: greenfield step 3 + existing-system step 1 now route the proof into the record; doctor FAILs until an exit-0 entry exists (observed in init output). FR-006: init ends with the doctor and exits 0 on red (observed); update-kit apply ends with the verdict, red ⇒ exit 2 (observed); DryRun runs no doctor (grep count 0, exit 0); `-Json` output parsed as pure JSON with no doctor lines. FR-006's "kitVersionAtInit" datum deviates from data-model — F3. |
| Visual-reference match | N/A — no UI surface in this feature. |
| Feature contract held (no unapproved table/migration/permission/package) | Diffs touch only the six declared files + specs/007 bookkeeping; child-`pwsh` invocations use existing tooling; no new dependencies. Doctor remains read-only (`verify-kit.ps1` has no write paths; only `Write-Host`/`exit`). Exit-code **set** {0,1,2} unchanged in update-kit (meaning of 2 extended per D6). |
| Constitution / domain invariants | Structure law untouched; territory (tasks.md Phase 2) matches the files changed in 61869bc; 8b033b7 stays inside phase-1 territory + its contract. Research D6 exit semantics implemented as written. |
| Security (authn/authz, secrets, sensitive logging) | Both new doc passages carry the "never paste secrets into the recorded command" caveat; scripts record no secrets (name/tiers/dates/version strings only). |
| Scope guard (`scope-check.ps1` PASS on the phase commit; `git diff --stat` read for intent) | `git show --stat` for both commits read: 61869bc = 6 files, exactly Phase 2 territory + tasks.md bookkeeping; 8b033b7 = verify-kit.ps1 + its contract. No stray files. |
| Rollback safety (phase reverts cleanly; schema additive?) | Each commit is self-contained and reverts cleanly; `kit-adoption.json` is a new project-owned artifact (kit repo never carries one — decline veto verified in code at verify-kit.ps1:106–117). |

## Findings

### F1 — verify-kit dim 5 crashes with ERROR on a contract-healthy short `kitCommit` — BLOCKING

`scripts/verify-kit.ps1:240` (introduced by 8b033b7) formats the ok line with a hardcoded `"$kvCommit".Substring(0, 12)`, while contract V8 (as amended by the same commit) declares "update-kit's JSON record … with a **7–40-hex** `kitCommit`" healthy. Any `kitCommit` of 7–11 hex chars — e.g. a hand-created or hand-edited record using git's default short sha — throws `ArgumentOutOfRangeException`, is caught by the script-level catch, and the entire run collapses to `verify-kit: ERROR Exception calling "Substring" … exit 1` with **zero** dimension findings reported. Empirically confirmed in a scratch fixture: `{"kitCommit":"8f43d74",…}` → ERROR exit 1, all findings suppressed; 12-char value → ok. This violates FR-001's "every failure reported in one run" and the spec's "named finding, not a crash" edge-case law, and is a regression of the exact crash class already fixed once in phase 1 (review F3 / V12). The adjacent bare-token branch (line 242) does it right with `[Math]::Min(12, $kv.Length)`. Update-kit itself always writes 40-hex, which is why L3 passed — the crash lives on the documented hand-creation path.
*Action: implementer — use `Substring(0, [Math]::Min(12, "$kvCommit".Length))` (or truncate via `-replace`), add the short-JSON-kitCommit case to the V-scenario table, re-validate.*

### F2 — init-kit silently overwrites an existing `kit-adoption.json`, destroying the gate-proof attestation — BLOCKING

`scripts/init-kit.ps1:247–248` writes the record with `[IO.File]::WriteAllText` unconditionally. Empirically confirmed: after adding a `gateProof` entry and a hand-declared `frontend` tier to a fixture's record, re-running init with the original arguments reset the file to `gateProof: []`, `tiers: ["backend"]` — no warning, exit 0. This contradicts the feature's own law three ways: data-model.md — "Attestation is human: **no tool writes entries**" (deleting them is writing them); spec US2 scenario 2 — the record is owner-editable; and the script's own idempotency convention, which carefully preserves existing rulebooks ("keep: … already exists") two sections earlier. The existing-system track walks into it by design: step 1 records the baseline proof in `kit-adoption.json`, step 7 says run `init-kit.ps1` — which then destroys the step-1 proof. Nothing documents re-init as destructive.
*Action: implementer — preserve an existing record (skip-with-"keep:" message like the rulebook path, or merge: keep `gateProof`/owner tiers, refresh nothing silently); alternatively refuse to overwrite without an explicit flag. Then reconcile existing-system.md step 1/7 ordering language.*

### F3 — `kitVersionAtInit` records the constitution's semver, not the "kit commit sha or 'copy'" the design docs define — CONFIRM

Research D1 and data-model.md both define `kitVersionAtInit` as "kit commit sha, or `copy`". The implementation (`init-kit.ps1:232–237`) instead scrapes the constitution's `**Version**:` line — fixture run recorded `"kitVersionAtInit": "0.4.1"`, which is neither a sha nor `copy`. tasks.md T006 re-decided this mid-flight, but the canonical shape docs (research D1, data-model.md) were never amended, and updating.md's now-canonical adopter-visible shape (F7 target) shows `"copy"` in the example with no prose defining the field's allowed values — an adopter comparing their init-written `"0.4.1"` against the doc has no way to know which is right. Deeper datum problem: after ratification the constitution's version is the **project's** own number (field record: adopted projects at 2.0.0), so any re-init — or an existing-system adoption that writes its constitution (step 2) before running init (step 7) — records the project's constitution version as "kit version at init", a wrong datum. Mitigating: the doctor never validates this field, so no false reds today.
*Action: owner decision — either bless the constitution-version source (then amend research D1, data-model.md, and updating.md prose to match, noting the post-ratification caveat) or fall back to `copy` whenever the constitution is already ratified/non-kit-versioned.*

### F4 — specs/004 update-kit contract now stale on exit-2 meaning, behavior sequence, and idempotence — DOC DRIFT

`specs/004-kit-update-channel/contracts/update-kit-cli.md` documents the living script: its behavior list ends at step 6 with `exit 0 clean / 2 attention needed / 1 error`, and its Idempotence section promises "a second run immediately after a clean run reports 'up to date' … and exits 0". Both are now false in the doctor-red case: the apply run gains a step 7 (doctor), exit 2 now also means "red adoption-doctor verdict" (script header and updating.md say so; the contract doesn't), and an up-to-date re-run exits 2 for as long as the doctor is red — empirically confirmed (`Result: up to date` + `verify-kit: FAIL (10 …)` → exit 2). tasks.md T014 applies exactly this argument to 006's contract ("leaving it stale would be exactly the drift the kit hunts") but no task covers 004's, and it sits in no phase's territory.
*Action: implementer — add a "amended by 007" step + exit-2 clause + idempotence caveat to the 004 contract in phase 3 or 4 (territory declaration required), mirroring T014's treatment of the 006 contract.*

### F5 — init-kit's doctor invocation unguarded: missing verify-kit.ps1 yields a misleading "findings above" note — MINOR

`update-kit.ps1:306` guards the doctor call with `Test-Path $doctorScript`; `init-kit.ps1:277` does not. On a partial install missing `scripts/verify-kit.ps1`, the child `pwsh -File <missing>` prints a file-not-found error and sets a non-zero `$LASTEXITCODE`, upon which init prints "the doctor findings above are the remaining human work" — there are no findings above — and exits 0. Same code path also means a verify-kit execution `ERROR` (exit 1, e.g. F1's crash) is presented as ordinary remaining-work red. Low likelihood (init itself lives next to the doctor in the same copy), but the message actively misleads exactly the partial-install audience the doctor exists for.
*Action: implementer — mirror update-kit's `Test-Path` guard and print an explicit "verify-kit.ps1 missing (partial install — adoption step 0)" line instead of the to-do note.*

### F6 — update-kit conflates doctor execution errors with a red verdict — MINOR

`update-kit.ps1:310` maps any non-zero doctor exit to `$doctorRed` → exit 2. verify-kit's contract distinguishes exit 1 "≥1 FAIL finding" from exit 1 `ERROR` (execution error) — both land as "attention needed" here, which is defensible — but combined with F1, a hand-created short-sha `.kit-version` makes every future apply run end in a single opaque `ERROR` line and exit 2, with no dimensional findings to act on. Fixing F1 removes the sting; the conflation itself is acceptable within D6's semantics.
*Action: none beyond F1 — exit 2 as the umbrella for "doctor did not come back green" is within the documented meaning; revisit only if verify-kit ever gains a distinct error exit code.*

### F7 — `-Json` apply run exits 0 where the identical non-Json run exits 2 — ACCEPTED

Verified: with the fixture's doctor red, `update-kit -Target <fixture> -Json` emitted pure JSON and exited 0, while the non-Json run exited 2. This divergence is deliberate and documented in three places (script header, the doctor-block comment, updating.md's report-table row: "`-Json` callers run `verify-kit.ps1 -Json -Root <project>` themselves"), and it preserves `-Json` output purity, which this reviewer confirmed byte-for-byte parseable. Machine callers that forget the second call get a weaker signal than terminal users — worth remembering when phase 3 wires CI.
*Action: none — documented deviation; phase 3's ritual-checks membership (T013) is the systematic answer for CI callers.*

### F8 — updating.md section 4, greenfield step 3, and the decline caveat verified accurate — MINOR

Field-for-field check of updating.md's record shape against data-model.md: `schemaVersion`/`projectName`/`topology` (`single`|`multi`)/`tiers` (five-value menu)/`initDate`/`gateProof` entry (`gate`,`command`,`exitCode`,`date`,`recordedBy`) all match, including the no-secrets and human-attestation rules (`kitVersionAtInit` prose gap folded into F3). The roadmap-header decline caveat matches the implemented logic exactly (verify-kit.ps1:106–117: decline requires no `.kit-version` AND no `kit-adoption.json` AND kit-manifest present AND the kit's own `# Roadmap — Agentic SDLC Kit` first line; creating either file or retitling vetoes — as the doc says). Greenfield's machine-assist paragraph matches observed init behavior (record write + doctor finish + "red is your to-do list"). Recorded here so the verification is on file, not as a defect.
*Action: none.*

## Constitution re-check (post-implementation)

**PASS with the F2/F3 caveats.** Read-only doctor (FR-008) holds — verify-kit still never writes. Init's new write (FR-003) is spec-mandated. Exit-code freeze (FR-006) holds in the code **set**; the extended meaning of 2 is per research D6 but leaves the 004 contract stale (F4) — a constitution-II "two rungs conflict" hazard the kit itself hunts. The record's human-attestation invariant (data-model.md) is violated by init's overwrite (F2). Territory discipline: both commits stayed inside declared territory; 8b033b7 correctly reported the mid-phase D5/V8 amendment in the contract rather than silently choosing. Grandfather posture (D8) intact: absent record/`.kit-version` still WARN, verified in the fixture run.

## Test coverage observed

No test framework (kit convention); validation is the seeded-fixture ritual. Phase 2 validation record (tasks.md L1–L6) is plausible and reproduces in shape: this review independently re-ran the L1 shape (init → record + red doctor + exit 0; 10 FAILs + 1 WARN with one tier vs the record's 11 with two tiers — the delta is the extra rulebook, consistent), L5 (DryRun: no doctor, exit 0), the L4 exit path (up-to-date + red doctor → exit 2), and `-Json` purity, all in a scratch fixture built from `git archive 61869bc` plus a branch clone. Gaps the recorded scenarios never exercise: re-init on an existing record (F2), short-hex `kitCommit` inside the JSON `.kit-version` (F1 — V8's healthy range is only validated at 40 hex), and a missing verify-kit.ps1 at init end (F5). Those three should join the scenario tables with the fixes.

## Residual risk

Concentrated in the adoption record's lifecycle: F2 destroys the one artifact the doctor treats as a human attestation, via a path the kit's own adoption doc recommends — must fix before merge. F1 turns a documented-healthy `.kit-version` into a findings-suppressing ERROR in local runs, at update-end (exit 2 with no diagnosis), and — once phase 3 lands — in every adopted project's CI; also must fix before merge. F3 needs an owner ruling before the record shape ossifies in adopted projects (schemaVersion 1 is already in the wild once this merges). F4 is cheap and should ride phase 3/4 with a territory declaration. After F1/F2 fixes plus re-validation of the affected scenarios, this phase is sound to proceed to the batched gate.

---

## Implementer fix-response log (post-review)

*Appended by the implementing agent after acting on the review; the review text above is
unmodified.*

| Finding | Disposition |
|---|---|
| F1 | **Fixed in code** (`phase 1 fix` commit — verify-kit is phase-1 territory): `Substring` guarded with `[Math]::Min`; short-hex `kitCommit` validated ok with no crash. |
| F2 | **Fixed in code** — init never overwrites an existing `kit-adoption.json` (`keep:` message, rulebook semantics); validated by re-init on a fixture with proof + hand-declared tier (record byte-identical, proof survived). existing-system step 1 now says the file may be hand-created before init and survives it. |
| F3 | **Fixed in code (flagged for owner ratification)** — constitution version is trusted only while the constitution is still the unratified kit-shipped one (`TODO(RATIFICATION_DATE)` present), else `copy`; research D1, data-model.md, and updating.md prose amended to define the field (informational, never validated). |
| F4 | **Fixed in docs (territory amendment, named file)** — 004's contract gains step 7 (doctor), the extended exit-2 clause, and the idempotence caveat, all marked "amended by 007". |
| F5 | **Fixed in code** — init guards the doctor invocation with `Test-Path` and prints an explicit partial-install line instead of the to-do note. |
| F6 | **Accepted** — exit 2 as the umbrella for "doctor not green" is within D6; the sting was F1, now fixed. |
| F7 | **Accepted (documented deviation)** — `-Json` purity preserved; CI callers are served by phase 3's wrapper membership. |
| F8 | **No action** — accuracy verification recorded by the reviewer. |