# AI Code Review — 008 CI-Held Certifying Gate (Phase 3: project-gate workflow template)

**Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
**Date**: 2026-09-08
**Branches**: agentic-sdlc-kit `008-ci-held-gate` (tip c72b54c)
**Scope reviewed**: `git show c72b54c` in full; `.github/workflows/project-gate.yml.template`; `docs/sdlc/gate-command.md` (whole file, both amended sections in context); `docs/sdlc/branch-protection.md` (whole file); `kit-manifest.json` (whole file); `specs/008-ci-held-gate/` spec.md, research.md (D4–D5), data-model.md, contracts/gate-certification.md, quickstart.md, tasks.md, plan.md (header/territory), ai-code-review-phase1.md (F9–F11); `.github/workflows/ritual-checks.yml`; `scripts/doc-lint.ps1` (header convention, manifest sweep, `ConvertTo-GlobRegex`, `Get-PatternSpecificity`, `Get-PathRefs`); `scripts/update-kit.ps1` (`Resolve-Class`, verbatim + surgical passes, `-Force` refusal); `scripts/init-kit.ps1` (GAP-006 fill scoping); `scripts/verify-kit.ps1` (`Get-ManifestClass`, slot dimension); `adoption/updating.md` §3; `docs/roadmap.md` GAP-007 entry. Executed read-only: `scripts/doc-lint.ps1`, `scripts/ritual-checks.ps1 -Branch 008-ci-held-gate`, `gh workflow list`, and PyYAML validation of the template both unfilled and sed-filled in the scratchpad.
**Feature contract**: doc+template phase; no scripts changed; template inert in the kit

## Reviewer Provenance

- **Reviewer**: fresh-context agent — Claude Fable 5 (subagent spawned with no implementation context)
- **Implementer**: Claude Fable 5 (main session that produced commit c72b54c)
- **Inputs provided**: the phase 3 commit (c72b54c) and its full diff; specs/008-ci-held-gate design artifacts (spec, research, data-model, contract, quickstart, tasks, plan); the phase 1 review's F10; the kit's scripts and law documents read directly from the branch; live runs of doc-lint, ritual-checks, `gh workflow list`, and a scratch YAML instantiation of the template
- **Attestation**: This reviewer did not produce the diff under review.

## Verdict

**REQUEST CHANGES** — the phase delivers exactly what FR-006 asks: an inert, slot-bearing, correctly-classified workflow template plus wiring law, and the mechanical claims in its validation record all reproduce (YAML validity filled and unfilled, manifest most-specific-wins across all three resolver implementations, template invisible to `gh workflow list`, ritual-checks green). One finding blocks: the shipped law states, in two places, that "the kit refreshes the template on updates," but `update-kit.ps1` by contract never writes a surgical-class path — it only reports, and even refuses `-Force` on surgical files. That is a false statement about tool behavior in shipped law — the same defect class phase 1's review blocked on — and it will misdirect every adopter who relies on it. The fix is a wording edit inside this phase's own territory. Everything else is minor polish on an otherwise tight diff.

## What was verified (evidence)

| Area | Evidence |
|---|---|
| Spec match (FRs implemented as specified) | FR-006 fully: template with `{{GATE_CHAIN}}`/`{{GATE_WORKDIR}}` slots, surgical manifest row, gate-command wiring section, "loses nothing" arm in both amended docs (gate-command.md:139–141, branch-protection.md:76–77). US2 scenario 2/3 language present; scenario 1 statically verified (quickstart W-G1's declared static-verification concession). Phase 1 F10's dangling reference resolved: gate-command.md:101 now names "Wiring the project gate in CI", which exists. |
| Visual-reference match | N/A — no visual references; doc/template feature. |
| Feature contract held | Diff touches only the 4 declared territory files + tasks.md bookkeeping; no scripts changed (`git show --stat`); template inert confirmed live — `gh workflow list` returns only `ritual-checks`. |
| Constitution / domain invariants | Phase 3 of the declared batch (plan.md `**Gate Batching**: phases 1-3`, `**Gate Certification**: user-run`); T014 correctly ends the batch by asking the owner for the user-run gate (research D7). One phase, one commit, no packages, no architecture change. |
| Security | `permissions: contents: read` (minimal); no attacker-controlled context interpolated into `run:` — both slots are owner-filled at copy time, unlike ritual-checks.yml's branch-name case, so T011's "no injection surface" claim is sound; secrets rule stated in the header (lines 14–15) and gate-command.md step 2. |
| Scope guard | `scripts/ritual-checks.ps1 -Branch 008-ci-held-gate` re-run by this reviewer: `scope-check: PASS phase 3 commit c72b54c (5 file(s))`, RESULT OK. `git diff --stat`: 5 files, +93/−5, all in-territory. |
| Rollback safety | Fully additive: one new file, one manifest row, two appended doc sections, tasks bookkeeping. `git revert c72b54c` restores the pre-phase state cleanly; nothing else depends on the template yet (first ci-held use is 009+/adopters). |

## Findings

### F1 — Shipped law claims kit updates "refresh" the template; update-kit never writes surgical paths — BLOCKING

Two shipped statements assert an update behavior the tool refuses to perform. Template header, `.github/workflows/project-gate.yml.template:8`: "the kit refreshes the template on updates"; `docs/sdlc/gate-command.md:130`: "the template stays untouched and is refreshed by kit updates." But the surgical pass in `scripts/update-kit.ps1` (lines 228–240) only lists upstream commits — its own report header reads "Surgical - upstream changes, **never applied**" — its synopsis says "never writing to surgical-class paths," and `-Force` on a surgical path is explicitly refused (lines 151–157). `adoption/updating.md` §3 confirms the contract: surgical changes are "re-appl[ied] by hand." Consequences: (a) an adopter who trusts the sentence never hand-refreshes, and their template silently drifts while update-kit exits 2 telling them the opposite of what their law says; (b) an adoption that pre-dates 008 never receives the template file *at all* through update-kit (the surgical pass reports the new file's commits but the verbatim missing-file copy branch, update-kit.ps1:188–195, applies only to verbatim paths) — yet the wiring section says "The kit ships a workflow template" and "Copy the template" as if it were already in their tree. `research.md` D4's "still flows down verbatim in practice" is the same error at the spec layer (first adoption gets it by whole-kit copy; the update channel never re-delivers it). Note the class choice itself is right — verbatim would resurrect a deleted template on every update, defeating the stated deletability — so the fix is wording, not reclassification.
*Action: implementer, in-phase (both files are phase 3 territory) — reword both statements to match the tool: kit updates REPORT changes to the template; refresh (or first-install, for pre-008 adoptions) by copying it from the kit clone by hand, per `adoption/updating.md` §3. Fix research.md D4's sentence in the same pass, and have phase 4's T016 (updating.md) name the template among the surgical files while it is in that file anyway.*

### F2 — Manifest most-specific-wins verified across all three resolvers; surgical is the right class — ACCEPTED

Verified in code, not by assertion: `Get-PatternSpecificity` (identical in `doc-lint.ps1:83`, `update-kit.ps1:102`, `verify-kit.ps1:80`) scores a literal path at 1000000+length (1000042 here) and a glob at its first `*` index — `.github/**` scores 8 — so the new literal row always out-ranks the verbatim glob; both entries match the file, one winner, no "conflict" error. Empirically: doc-lint re-run reports `manifest - 64 shipped file(s) classified`, matching W-G3. The surgical class correctly (a) keeps the adopter-side template deletable (update-kit never resurrects surgical files — see F1 evidence) and (b) protects an adopter who edited the template in place from being clobbered. `init-kit.ps1`'s slot fill can never touch it (it fills only `{{PROJECT_NAME}}`/repo slots in *.md surfaces — the template is neither), and `verify-kit.ps1`'s slot dimension scans only *.md files, so the template's permanently-unfilled slots never trip the adoption doctor. Clean interaction check all round.
*Action: none — verified correct.*

### F3 — GAP-007 bold discipline: half machine-enforced, half convention; W-G3 slightly overstates what doc-lint verified — MINOR

`Get-PathRefs` (doc-lint.ps1:169–189) lints only backtick spans and markdown links, so bold references are invisible to it — that is the mechanism of the convention. Two different bolds are doing two different jobs here: **.github/workflows/project-gate.yml** (gate-command.md:129, branch-protection.md:73) is *machine-load-bearing today* — a backticked form would fail the kit's own doc-lint right now, since the copy does not exist in the kit; **.github/workflows/project-gate.yml.template** (gate-command.md:125) is *convention-only in the kit* — a backticked form would pass kit CI (the file exists) and only break a template-deleting adopter later. The verbatim doc (branch-protection.md) is fully safe: it references the template only as prose ("the kit's template") plus a backtick to always-present gate-command.md. So the discipline is genuinely load-bearing, correctly applied in both docs — but W-G3's record ("every referenced path resolves (bold references for the deletable template per GAP-007)") implies doc-lint verified the bold convention; for the `.template` path it cannot: kit CI would be equally green with a backtick there. This is the known GAP-007 residue (convention stated in doc-lint's header, unenforceable for files that exist in the kit).
*Action: none in-phase — the references are correct. Noting for the roadmap: the convention remains machine-uncheckable for deletable-but-present files; a future doc-lint rule (backtick refs to surgical/deletable-classified paths inside verbatim docs) would close it.*

### F4 — Trigger set mirrors ritual-checks, but the template drops ritual-checks' explanatory comments — MINOR

The `on:` block is byte-for-byte the governed-branch set of `ritual-checks.yml` (main, `[0-9][0-9][0-9]-*`, `fix/**`, `chore/**`, `docs/**`, plus PR→main) — consistent and precedented. Two things ritual-checks.yml explains that the template does not: (a) why `main` is on push ("post-merge trunk safety net") — for a *project gate* main-on-push is arguably even more valuable (post-merge build/test regression net), but the header's step 4 says only "Push a governed branch," leaving an adopter to wonder whether main belongs there; (b) a governed branch with an open PR runs the gate twice per push (push + pull_request events) — cheap for ritual checks, potentially expensive for a real build/test chain, and unexplained. Neither is wrong; both are the kind of comment this template's otherwise-thorough header would carry.
*Action: implementer — optional one-line header additions ("main = post-merge safety net"; "expect push+PR double-runs on branches with open PRs — trim the pull_request trigger if CI minutes matter"); acceptable to accept as-is given the ritual-checks precedent.*

### F5 — pull_request-event runs are merge-preview runs, not triplet evidence; the template that creates them doesn't say so — MINOR

The template's PR trigger produces runs that execute on an ephemeral merge commit, not the phase commit. The law already disqualifies them — gate-command.md:107–108 ("the run executed on the phase commit itself … A run on any other commit certifies nothing") and spec.md's edge case names "merge preview" explicitly — so no rule is missing. But the run an owner is most likely to click from a PR page is exactly the pull_request run, and neither the template header (step 4 speaks only of push) nor the wiring section warns that only the push-event run supplies the triplet's sha. One clause would prevent the most likely first-use citation mistake.
*Action: implementer — optionally add to the header's step 4 or gate-command step 3: "cite the push-event run — a pull_request-event run executes a merge preview, not the phase commit, and certifies nothing." Law is already correct; this is usability.*

### F6 — Template YAML robustness verified empirically; unfilled copy fails red (safe); blind sed-fill mangles the header comment — MINOR

Validated with PyYAML in the scratchpad: the *unfilled* template parses as valid YAML — the single quotes around `'{{GATE_WORKDIR}}'` are load-bearing (unquoted, `{{…}}` is a YAML flow-mapping parse error), and `{{GATE_CHAIN}}` sits inside a literal block scalar, so it is inert text. A sed-fill with a realistic chain (`npm run build && npm run "type check" && npm test`) and a workdir containing a space (`apps/web app`) round-trips exactly: `&&` and double quotes survive the block scalar; spaces survive the single quotes. Failure modes: an adopter who copies without filling gets a red run (checkout succeeds, the step aborts on the nonexistent literal `'{{GATE_WORKDIR}}'` directory) — cryptic-ish but fail-safe: no false green is possible, which is the property that matters for evidence. Residual edges, all acceptable: a workdir containing a single quote breaks the quoting; a hand-pasted multi-line chain must keep the 10-space block-scalar indent. The one avoidable wart is W-G1's honestly-recorded note: a blind global fill also rewrites the slot mentions inside header lines 10–11, turning the copy's own instructions into nonsense ("Fill . — the directory…"). Writing the header mentions brace-free ("Fill the GATE_WORKDIR slot…") would make blind fills clean without weakening the instructions.
*Action: implementer — optionally de-brace the two slot mentions in the header comment; otherwise none — the recorded behavior is harmless and was disclosed in the validation record.*

### F7 — "The run page shows the command" — accurate via the step log, not the step name — ACCEPTED

The run step is generically named "Run the project gate", so the chain never appears in the run summary or check name; it appears in the step's log, where the Actions runner prints the executed script verbatim at the top of the step. The docs' claim ("the run page shows the command, the conclusion, and the commit sha" — template header step 4, gate-command step 3) therefore holds: all three elements are readable off the run page, one click deep for the command. The kit's-own-evidence note is consistent across gate-command.md:101–103, contract line 55, and research D5.
*Action: none.*

## Constitution re-check (post-implementation)

**PASS.** X (Controlled Delivery): phase 3 of the declared 1–3 batch, single commit, cleanly revertible, territory declared before the commit and held (scope-check PASS); batch end correctly hands certification to the owner under the current user-run law (research D7 — the feature does not certify itself with the mode it introduces). II (source of truth): the wiring section defers to constitution X and branch-protection.md rather than restating; the "recommended, never mandated" boundary (spec assumption, 006 precedent) is stated identically in both amended docs and the template header. VIII (validation): W-G1–W-G3 executed and recorded, honestly including the sed-fill caveat. No packages, no architecture, no script changes. The one constitutional-culture defect is F1 — law text that misstates a tool's behavior — which is why it blocks despite being a wording fix.

## Test coverage observed

No test framework (kit convention); validation is the seeded/recorded W-G scenarios, all independently reproduced by this reviewer: **W-G1** — template instantiated in the scratchpad; PyYAML confirms valid YAML unfilled *and* filled (chain with `&&` + quotes, workdir with a space); zero `{{` markers post-fill; the header-comment mangling matches the record's disclosed note. **W-G2** — `gh workflow list` returns only `ritual-checks` (template inert). **W-G3** — doc-lint re-run: 64 shipped files classified (was 63), no conflict — and the resolution algorithm read in all three scripts (doc-lint `Get-PatternSpecificity`, update-kit `Resolve-Class`, verify-kit `Get-ManifestClass`) proves the literal row (specificity 1000042) beats `.github/**` (specificity 8). **Regression** — full `ritual-checks.ps1 -Branch 008-ci-held-gate`: doc-lint OK · enforcement-pack OK · scope-check OK (phase 3 commit, 5 files) · verify-kit n/a · RESULT OK. Not covered by any check, by design: the bold-reference convention for the `.template` path (F3) and a live push of a filled copy (quickstart's accepted static-verification concession).

## Residual risk

The risk concentrates in F1: two shipped sentences promise an update behavior `update-kit.ps1` will never perform, and pre-008 adoptions will never receive the template through the update channel at all — left unfixed, the first real flow-down of 008 reproduces exactly the doc-vs-tool drift the kit exists to prevent. Fix is a two-file wording edit inside phase 3's own territory; merge should wait for it. Everything else is low: F5's PR-run citation mistake is caught by the law's exact-sha rule at approval time; F3's convention gap is a known roadmap-class residue, not a regression; F4/F6/F7 are polish. After the F1 rewording, this phase is safe to certify at the declared batch end (owner's user-run gate) and merge under gate 6.

---

## Implementer fix-response log (post-review, same phase territory)

*Appended by the implementing agent after acting on the review; the review text above is
unmodified.*

| Finding | Disposition |
|---|---|
| F1 | **Fixed** — template header and gate-command wiring step 1 now state the truth: kit updates REPORT changes to the surgical-class template; refresh (or first-install for pre-008 adoptions) is a hand copy from the kit clone per adoption/updating.md §3. Research D4's sentence corrected with the F1 attribution. T016 (phase 4) extended: updating.md §3 will name the template among the surgical files. |
| F2 | **Accepted** — resolver verification stands on record. |
| F3 | **Accepted** — references correct; the machine-uncheckable convention residue noted as a roadmap-class candidate (doc-lint rule: backtick refs to deletable-classified paths in verbatim docs). |
| F4 | **Fixed (polish taken)** — header gains the trigger notes: main-on-push = post-merge safety net; push+PR double-run caveat with the trim suggestion. |
| F5 | **Fixed (polish taken)** — "cite the PUSH-event run … a pull_request-event run executes a merge preview … certifies nothing" added to the template's step 4 and gate-command's step 3. |
| F6 | **Fixed (polish taken)** — header slot mentions de-braced ("the GATE_WORKDIR slot / the GATE_CHAIN slot") so blind fills leave the copy's instructions intact. |
| F7 | **Accepted** — claim verified accurate via the step log. |