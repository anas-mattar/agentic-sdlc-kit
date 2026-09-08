# AI Code Review — 007 Adoption Doctor (Phase 1)

**Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
**Date**: 2026-09-08
**Branches**: agentic-sdlc-kit `007-adoption-doctor` (tip `6410ffb`)
**Scope reviewed**: `scripts/verify-kit.ps1` (all 253 lines), `scripts/doc-lint.ps1` (full, for the sync-note and glob-trio equivalence), `kit-manifest.json`, `.specify/memory/constitution.md` (marker sections), `docs/rulebooks/README.md` + tier templates (marker survey), `scripts/init-kit.ps1` (rulebook-instantiation block), `docs/roadmap.md` (header bytes), `adoption/updating.md` (pointer targets), and the full 007 spec pack (spec.md, plan.md, research.md D1–D8, data-model.md, contracts/verify-kit-cli.md, quickstart.md, tasks.md incl. Phase 1 validation record). Behavior verified by executing the doctor read-only against the kit repo and against a scratch fixture built from `git archive 6410ffb` in the session scratchpad (never inside the kit repo).
**Feature contract**: doc+script phases only, no application code, no new dependencies; doctor is read-only

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
- **Implementer**: Claude Fable 5 (main session that produced commit 6410ffb)
- **Inputs provided**: commit 6410ffb full diff; specs/007-adoption-doctor/ (spec, plan, research, data-model, CLI contract, quickstart, tasks incl. validation record); scripts/verify-kit.ps1, doc-lint.ps1, init-kit.ps1, kit-manifest.json, constitution, rulebook templates read on this branch; live runs of verify-kit.ps1, doc-lint.ps1, ritual-checks.ps1 and a scratch adopted fixture
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — The script is well-shaped: five dimensions that never short-circuit, correct exit semantics (exit 0 iff zero FAILs, WARNs never fail, decline exits 0 — all reproduced), clean cross-repo `-Root` handling (every path goes through `Join-Path $Root`), byte-identical manifest-glob resolution with doc-lint, and an honest V1–V10 record I could reproduce in shape. But three defects block: (F1) dimension 2 false-FAILs every *realistic* healthy adoption on kit-shipped template/menu prose — the recorded green V1 was achieved by dummy-filling files no real adopter edits; (F2) the decline check silently declines a genuinely adopted project (record present, constitution ratified) that kept the kit's roadmap header, contradicting research D5.3 and producing a false green; (F3) two zero-byte-file inputs crash the whole audit with a single opaque ERROR that swallows all other findings. The residual risk sits exactly where the product's value is: false verdicts from the tool whose job is to be the trustworthy verdict.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-001 five dimensions + fix pointers: read lines 116–222; no short-circuit confirmed by V10-style multi-FAIL run. FR-002 decline: ran on kit repo → `not applicable`, exit 0. FR-004 grandfather WARN: reproduced (record absent → WARN, exit 0). FR-005 proof shape check: reproduced FAIL on `gateProof: []` semantics (no exit-0 entry). FR-008 read-only: script contains only `Test-Path`/`Get-Content`/`Write-Host`; no write cmdlets; fixture tree unchanged after runs. Exceptions: F1, F2 below. |
| Visual-reference match | N/A |
| Feature contract held (no unapproved table/migration/permission/package) | Diff = 1 new ps1 + 2-line doc-lint comment + tasks.md record; PowerShell built-ins only (`ConvertFrom-Json`, `[regex]`); no modules imported, no network, no new files classes (`scripts/*.ps1` verbatim glob covers it — manifest read, doc-lint reports 63 classified, matching T004's claim). |
| Constitution / domain invariants | Ritual followed: claim → specify commits → single phase commit with territory declared (verify-kit, doc-lint, kit-manifest). One source-of-truth tension found (research D3 vs spec edge case) — see F1 and Constitution re-check. |
| Security | No secrets read or logged; gateProof `command` is echoed only via the record the owner wrote; no network. OK. |
| Scope guard | `ritual-checks.ps1` run: `scope-check: PASS phase 1 commit 6410ffb (3 file(s))`, RESULT OK, exit 0. Commit touches exactly the declared territory (kit-manifest.json declared, untouched — allowed). |
| Rollback safety | Nothing references verify-kit.ps1 yet (hooks are phase 2/3); reverting the single commit restores status quo. Verified doc-lint change is comment-only. |
| Sync-note accuracy (T002) | `$requiredKitPaths` lists in doc-lint.ps1:49–67 and verify-kit.ps1:50–68 compared entry-by-entry: identical 17 paths, same order. Cross-notes present in both headers. |
| Glob-trio equivalence | `ConvertTo-GlobRegex` / `Get-PatternSpecificity` / winner-selection logic compared line-by-line against doc-lint.ps1:74–88, 130–141: behaviorally identical (verify-kit returns `$null` on class conflict where doc-lint reports — deliberate, commented). |
| Slot regex vs kit reality | Grepped every `{{...}}` spelling in the kit: all are `[A-Z_]+` (no digits, hyphens, or mixed case), so `\{\{[A-Z_]+\}\}` misses nothing the kit ships. Constitution's only TODO forms are the three named ones (lines 85–87, 245) — but see F5 for speckit-generated constitutions. |
| Validation record reproducibility | Reproduced on a fresh scratch fixture: V9 (kit repo decline, exit 0), V1 shape (5 ok lines, exit 0 — but see F1 for what it took), V7 shape (`WARN record` + `OK … (1 warning(s))`, exit 0), V8b (WARN kit-version, exit 0), seeded FAILs for record-parse, schemaVersion, missing-tier paths (exit 1 each). Exit-code table of the contract holds in every reproduced case. |
| PowerShell pitfalls checked | `exit` inside `try` is NOT caught by `catch` (decline exit 0 observed working); `Where-Object level -eq 'FAIL'` on pscustomobject works (counts correct); `@($record.tiers)` scalar-string coercion works (tiers `"backend"` passes); `"0" -eq 0` string exitCode accepted (lenient, fine); ok-line condition at line 206 traced against all five FAIL branches — no contradictory FAIL+ok coexistence possible (schemaVersion-2-else-valid run: FAIL emitted, ok suppressed). Empty-file `-Raw` returns `$null` → crashes (F3). |

## Findings

### F1 — Dimension 2 false-FAILs every realistic adoption on kit-shipped template/menu prose — BLOCKING

`docs/rulebooks/**` is surgical-class, and dim 2 (verify-kit.ps1:134–152) FAILs on any `{{[A-Z_]+}}`/`TODO(` hit in an existing surgical file. But the kit *ships* marker-bearing files there that a by-the-book adoption keeps: `docs/rulebooks/README.md` (the tier menu — line 35 contains literal `` `{{SLOT}}` `` as permanent instructional prose; nobody "fills" the menu), `docs/rulebooks/stack-profile-template.md`, and the **selected** tiers' template files, which `init-kit.ps1 -DeleteUnusedTemplates` does not delete (init-kit.ps1:116–123 deletes only *unselected* tiers' templates). Reproduced: a fixture with every judgment slot filled, constitution ratified, valid record, and valid `.kit-version` still fails with `FAIL slots: docs/rulebooks/README.md has 1 unfilled marker(s), first: {{SLOT}}` plus one FAIL per surviving template — exit 1. Keeping *unselected* templates (explicitly legal per spec edge case "tier templates are a menu … never template presence") FAILs too. This violates SC-001 ("zero false findings on the healthy fixture") in substance: the recorded V1 went green only because the fixture "filled remaining surgical markers with dummies" — i.e., hand-edited kit-shipped menu/template prose that no real adopter (FlowBoard, expense-tracker) would touch. Research D3 ("scan every existing surgical file") and the spec's menu posture conflict here; the code silently chose D3 — the kit's own conflict rule says stop and report. Once phase 3 wires this into adopted-project CI, every adoption goes red on shipped prose.
*Action: implementer + owner — exclude `docs/rulebooks/*-template.md` and `docs/rulebooks/README.md` (and decide the kept-kit-`README.md`/`modules/**` example posture) from dim 2, pin the exception in research D3, and re-run V1 on a fixture that does NOT dummy kit-shipped prose before this phase is certified.*

### F2 — Decline check overrides stronger adoption signals; adopted project silently declined — BLOCKING

The decline (verify-kit.ps1:104–114) fires whenever `.kit-version` is absent, `kit-manifest.json` exists, and `docs/roadmap.md`'s first line matches the kit header — without checking for `kit-adoption.json` or filled slots. Research D5.3 pins the opposite priority: "Target looks adopted (slots filled / `kit-adoption.json` present) but has no `.kit-version` → audit anyway, with a warning." Reproduced: a fixture with ratified constitution, all slots filled, and a valid `kit-adoption.json`, but the kit's roadmap first line kept and no `.kit-version` → `verify-kit: not applicable (this is the kit template, not an adoption)`, exit 0. That is a false green from the integrity tool itself, and under phase 3's wrapper it becomes a permanent, silent `n/a` in that project's CI. The tasks.md validation record acknowledges the trap only as fixture-build rationale ("keeping the kit header would wrongly trigger the decline path in V8b") — it is not implemented per D5.3 nor documented anywhere an adopter would read (contract V8 promises WARN on absent `.kit-version` unconditionally). Mechanics verified while here: the regex handles the kit's real CRLF header and em-dash; empty roadmap (`-TotalCount 1` → `$null`) safely doesn't decline; `exit 0` inside `try` is not swallowed by `catch`.
*Action: implementer — add `-and -not (Test-Path (Join-Path $Root 'kit-adoption.json'))` to the `$isKit` conjunction (per D5.3), and document the residual roadmap-header caveat for pre-007 copy adoptions in the contract's V8 row or adoption/updating.md (phase 2).*

### F3 — Zero-byte files crash the audit and swallow all findings — BLOCKING

`Get-Content -Raw` returns `$null` for a 0-byte file (verified in this environment). Two reachable crashes: (a) empty `.kit-version` → `(Get-Content … -Raw).Trim()` at line 214 throws → outer catch prints `verify-kit: ERROR You cannot call a method on a null-valued expression`, exit 1, and **zero per-dimension findings are reported** (the catch exits before the report loop); reproduced. (b) any empty `.md` under a surgical surface — e.g. a project-created placeholder `docs/rulebooks/team-notes.md` — → `[regex]::Matches($null, …)` at line 146 throws the same way; reproduced (`ERROR … Value cannot be null. (Parameter 'input')`). Both are plausible hand-edit states, both violate FR-001's "reporting every failure in one run" and the spec's "a named finding, not a crash" posture, and (a) should be a dim-5 FAIL (an empty `.kit-version` is exactly "hand-edited nonsense"). Same latent issue for an empty constitution at line 161.
*Action: implementer — coerce reads to strings (e.g. `[string](Get-Content -LiteralPath … -Raw)` or `?? ''`) at lines 145, 160, 214; make empty `.kit-version` a dim-5 FAIL; add an empty-file row to the fixture scenarios.*

### F4 — `.kit-version` plausibility check accepts any single token; contract V8 overpromises — CONFIRM

Line 215's acceptance is `40-hex OR (non-empty AND no whitespace AND ≤64 chars)` — so `.kit-version` containing exactly `garbage` passes as ok (reproduced: `ok kit-version — .kit-version present (garbage…)`, exit 0). The FAIL branch is reachable only for whitespace-bearing or >64-char content (the recorded V8a honestly used "multiline garbage"). Research D5.2's "tag-like token" arguably permits this, but contract V8 says plainly "`.kit-version` containing garbage → FAIL dim 5", which the code does not deliver for the common single-token case. Either tighten (e.g. require 7–40 hex, or `^v?\d`-style tags — update-kit writes shas, so hex-only may be enough) or soften the contract's V8 wording to match D5.2.
*Action: owner decision — align code and contract V8; if the lenient token rule stands, reword V8 to "whitespace/oversized content" so the contract stops promising a check that doesn't exist.*

### F5 — Dimension 3 misses speckit's generic `TODO(<FIELD_NAME>)` convention — CONFIRM

Dim 3 (line 161) matches only `TODO(RATIFICATION_DATE)`, `TODO(PROJECT_NAME)`, `TODO(SLOTS)`, and `{{[A-Z_]+}}` — exactly the kit's shipped constitution forms (verified lines 85–87, 245). But `.claude/commands/speckit.constitution.md:82` instructs writing any deferred constitution field as `TODO(<FIELD_NAME>)`, so a constitution carrying e.g. `TODO(LAST_AMENDED_DATE)` passes dim 3 — and since the constitution is deliberately excluded from dim 2's generic `TODO\(` scan, no dimension catches it. A generic `TODO\(` in dim 3 would be safe against the shipped template (its only paren-bearing TODOs are the three named ones) and closes the gap.
*Action: owner decision — widen dim 3's marker regex to generic `TODO\(`, or record in research D4 why the named-forms-only set is intentional.*

### F6 — Missing `tiers` field yields a misleading finding — MINOR

With `tiers` absent from the record, `@($record.tiers)` is `@($null)`, the loop runs once with `$null`, and the finding reads `declared tier '' is not a known tier (…)` (reproduced) — confusing when no tier was declared at all. An empty `tiers: []` passes silently. Posture (FAIL) is right per data-model (`tiers` is required); the message is the defect.
*Action: implementer — guard for missing/empty `tiers` with a dedicated "record declares no tiers" finding; low-risk fold into the F3 fix commit.*

### F7 — Fix pointers reference instructions that don't exist where the adopter reads them — DOC DRIFT

The dim-4/dim-5 WARN pointers say "create it per `adoption/updating.md`", but updating.md at this commit contains no creation instructions for `kit-adoption.json` or `.kit-version` (that's T010, phase 2 — acceptable transiently inside the batch). Less acceptable: the record-shape pointers cite `specs/007-adoption-doctor/data-model.md`, a kit-internal path that is never shipped to adopted projects (specs/NNN dirs are outside every shipped surface), so an adopter reading the finding in their own repo can never resolve it — the shape must land in an adopter-visible doc (updating.md) and the pointer should target that.
*Action: implementer, in phase 2 (T010) — put the record shape in adoption/updating.md and retarget the two pointers; verify with a doctor run whose output is read from inside the fixture.*

### F8 — D8 grandfather matrix: pre-007 gateProof pointer collapsed — MINOR

Research D8's pre-007 row for "gateProof entry with exit 0" promises "WARN + pointer to adoption step 3", but with no record the code emits only the generic record-missing WARN pointing at updating.md (line 173). The collapse is defensible (the proof lives inside the record; you can't warn about a field of a file that doesn't exist), and the message does mention the gate proof — but the step-3 pointer from the matrix is absent. Every other matrix cell traced clean against the code (tier rulebook, `.kit-version`, always-law FAILs).
*Action: none required if the collapse is intended — add "(adoption step 3)" to the WARN's fix text or annotate D8; either side may move.*

### F9 — `-Json` decline shape inconsistent with the verdict object — MINOR

The decline emits `{ verdict: 'not-applicable', findings: [] }` without the `failures`/`warnings` keys the normal path emits (lines 111 vs 246–251), and the contract's `-Json` description ("in addition to nothing else on stdout") doesn't match the actual human-lines-plus-JSON output. Harmless until phase 3 consumes it.
*Action: none now; align the shape and the contract sentence when the wrapper starts parsing it (phase 3).*

## Constitution re-check (post-implementation)

**PASS with one caveat.** I/II: ritual followed, spec pack complete before the phase commit — but F1 exposes an unreported source-of-truth conflict (research D3's "scan every existing surgical file" vs the spec's tier-menu edge case and SC-001); constitution II's conflict rule ("stop and report — never silently choose") was not honored: the code silently chose D3. IV: no new patterns or dependencies — confirmed by read. VI: read-only, no secrets — confirmed. VIII: fail-paths-first fixture validation exists and is genuinely reproducible, but the healthy fixture (V1) was made healthy by unrealistic edits (F1), which weakens exactly the "zero false findings on the healthy fixture" assertion SC-001 needs. X: single phase, three declared files, scope-check PASS, cleanly revertible.

## Test coverage observed

No test framework (kit convention). Coverage = the V1–V10 seeded-fixture table recorded in tasks.md, which I spot-reproduced on an independent scratch fixture: V9 decline (exit 0), V1 all-ok (exit 0 — after the same prose-dummying the record used, see F1), V7 record-absent WARN with `OK … (1 warning(s))` (exit 0), V8b `.kit-version`-absent WARN (exit 0), plus seeded FAILs for record-parse-failure, schemaVersion≠1, missing/unknown tiers, and multi-FAIL runs (exit 1 each; all findings named in one run). Beyond the recorded suite I exercised: string-typed `exitCode "0"` (accepted), scalar `tiers` (accepted), `schemaVersion: 2` with everything else valid (FAIL, no contradictory ok line), empty `.kit-version` and empty surgical `.md` (both crash — F3), single-token garbage `.kit-version` (passes — F4), and the adopted-but-declined combination (F2). Not covered anywhere: empty files, kept templates, generic `TODO(` constitutions — the F1/F3/F4/F5 classes should become fixture rows.

## Residual risk

Concentrated in false verdicts, both directions: F1 makes healthy adoptions red (an integrity tool that cries wolf on every patient will be muted before phase 3 lands), F2 makes a real adoption silently green-by-decline, and F3 lets one empty file mask every other finding in the run. All three must be fixed and re-validated on a realism-corrected fixture before the phases 1–3 batch certification — phase 2 (init writes the record) and phase 3 (CI membership) will bake the current behavior into every adopted project's pipeline. F4/F5 need an owner ruling before the contract is cited as law; F7 has a natural phase-2 home (T010). After those, the design itself — manifest-driven scoping, sibling-checker boundary, grandfather matrix — is sound and matches its research.

---

## Implementer fix-response log (post-review, same phase territory)

*Appended by the implementing agent after acting on the review; the review text above is
unmodified. Fixes land in a `phase 1 fixes` commit.*

| Finding | Disposition |
|---|---|
| F1 | **Fixed in code + research pinned** — dim 2 now exempts kit-shipped example/menu prose: any `*-template.md`, `docs/rulebooks/README.md`, and `modules/**` (worked examples are replaced, not filled; the project's real invariants live at the CLAUDE.md-declared path). Instantiated rulebooks stay scanned — filling them IS the law (doc-lint `-FailOnSlots` posture). Research D3 amended to pin the exemptions and record the conflict resolution. Re-validated on a realism-corrected fixture (no kit prose dummied). |
| F2 | **Fixed in code** — `kit-adoption.json` presence now vetoes the decline (research D5.3 priority restored); residual roadmap-header caveat documented in the contract's V8/V9 rows, with the adopter-visible instructions landing in updating.md (T010). |
| F3 | **Fixed in code** — all raw reads string-coerced; empty `.kit-version` is a dim-5 FAIL; empty surgical `.md` scans clean (a finding-free file, not a crash); empty-file rows added to validation. |
| F4 | **Fixed in code (strict option, flagged for ratification)** — `.kit-version` must be 7–40 hex (update-kit writes shas) or a `v`-prefixed/dotted tag token; single-token garbage now FAILs; contract V8 aligned. |
| F5 | **Fixed in code** — dim 3 widened to generic `TODO\(` (safe against the shipped template; closes the speckit-generated-constitution gap). |
| F6 | **Fixed in code** — missing/empty `tiers` gets a dedicated "record declares no tiers" FAIL. |
| F7 | **Deferred to phase 2 (T010) as the review prescribes** — record shape lands in adoption/updating.md and both WARN pointers retarget it; tracked in the T010 task text. |
| F8 | **Fixed in text** — "(adoption step 3)" appended to the record-missing WARN's fix pointer. |
| F9 | **Deferred to phase 3** — JSON shape + contract sentence aligned when the wrapper consumes it; noted in T013's scope. |