# 016 Multi-line Code Spans — phase evidence

Evidence and decisions that are not themselves law. This file is not graded by the amendment
rule (constitution I grades `spec.md`, `plan.md`, `tasks.md` and `contracts/` only), which is
why recording evidence here never costs an approver record.

## Approval

**2026-09-27 — the owner approved `spec.md` and `plan.md`.** The spec content was first approved
in session as "approved". The plan then corrected that Draft spec (research R1: F2's shape is a
comment-model loss, and HTML comment blocks need their own boundary), and the owner approved the
corrected spec and the plan together in session as "go ahead". The approval covers:

- the spec as corrected in `806db42`, including its Out of Scope list (full CommonMark
  conformance, the comment model and its unterminated-comment rule, other document readers);
- **D1** — `Convert-CodeSpanMarkers` changes signature to `-Lines`, with no single-line wrapper;
- **D8** — the new DIGEST-020 failure in a verbatim script, which fails rather than warns;
- the three-phase sequence and `**Gate Certification**: ci-held`;
- no new dependency. The CommonMark renderer used in research R1 was a scratch measuring tool,
  not a kit dependency.

The spec's `**Status**` line moved `Draft` → `Approved` in the same commit as this record. That
transition is the act that *starts* the amendment rule rather than a change to an approved
document, so it owes no approver record (constitution I, and the exemption feature 014 shipped
as D3d). The commit is kept to exactly that shape so the exemption applies as written.

## Phase 1 — a wrapped code span hides nothing

### The guards as planned could not see an over-reaching fix

Before any case was written, each planned guard was traced under D7(b), the mutation it exists
to catch (spans paired across the whole document). Two of the planned shapes would have passed
under it, and so measured nothing:

- **T005 as written** put the record *inside* the HTML comment block and expected FAIL. The
  over-reaching fix only hides more, so the record stays hidden and the case still passes. The
  shape that can fail puts the record *after* the block and expects PASS: a correct reader shows
  it, and the over-reaching fix disarms the block's `-->` so the unterminated-comment rule hides
  it. Built as `AMEND-001/pass-comment-block-backticks`.
- **T002 as written** (a comment block holding backticks, then a marker) cannot fail under
  D7(b) at all. `build-digests.ps1` closes a comment by reading the **raw** line, not the
  disarmed one, so pairing across the block changes nothing it harvests. The digest guard became
  sensitive by giving the block's closing line a second backtick: the over-reaching fix pairs
  the first-line backtick with the first closing-line one, leaves the second unpaired, pairs it
  into a later paragraph, and leaves that paragraph's `<!--` armed, so the last marker vanishes.

Both changes alter case names and one expected verdict in `tasks.md` (T002, T005) and plan D6,
so they need the owner's amendment record before the phase commit.

### T006 — the cases against the parent commit's scripts

Run on the unchanged scripts (`e10da18`) with `tests/enforcement/Run-Tests.ps1 -Case <filter>`:

| Case | Expected on the fix | On the parent | Meaning |
|---|---|---|---|
| DIGEST-001 `pass-wrapped-span` | OK, exit 0 | **FAIL** (exit and output) | the defect is real: a correct digest called stale |
| DIGEST-001 `fail-wrapped-span` | stale, exit 1 | **FAIL** (the check said OK) | the fail-open direction: a stale digest called fresh |
| AMEND-001 `pass-wrapped-span` | pass, exit 0 | **FAIL** | a visible record hidden: 014 B7's shape |
| DIGEST-001 `pass-comment-block-backticks` | OK | pass | guard holds today |
| AMEND-001 `pass-comment-block-backticks` | pass | pass | guard holds today |
| AMEND-001 `fail-hidden-after-unpaired` | FAIL, exit 1 | pass | guard holds today (no-fail-open) |

`-Case wrapped-span`: 33 passed, 6 failed (the three green-turning cases, two assertions each).
`-Case comment-block-backticks`: 37 passed, 0 failed. `-Case hidden-after-unpaired`: 35 passed,
0 failed. The other passes in each run are the harness's own self-tests and coverage checks,
which run on every filter.

On the fix: `wrapped-span` 39/0, `comment-block-backticks` 37/0, `hidden-after-unpaired` 35/0.

### T010 — comments, and the FR-012 text outside Territory

The per-line descriptions are corrected in the `scripts/markdown-lib.ps1` header and the
`Disable-CommentMarkers` / `Convert-CodeSpanMarkers` comments, the GAP-025 comment in
`scripts/build-digests.ps1`, and the helper note in `scripts/enforcement-pack.ps1`. Each says
what is modelled (pairing within a paragraph) and what is not (a `<!--` opened mid-line in
prose that runs on into later lines).

FR-012 also asks, on ship, for GAP-028 to be recorded as closed and for kit text claiming
GAP-025 closed without qualification to be corrected. The only live text is the GAP-028 row
in `docs/roadmap.md` (line 58), which is already the qualification. The 015 documents that say
"GAP-025 closed" are that feature's records and are not rewritten. `docs/roadmap.md` is in no
phase's Territory, so closing the row needs either an owner-approved Territory amendment for
phase 3 or the main-side docs PR that T026 already plans. Not edited here.

### T012 — the full suite on the fix

`pwsh -File tests/enforcement/Run-Tests.ps1`, run by the owner on 2026-09-30 against the working
tree holding T007-T011 (PowerShell 7, Pester 5.7.1): **817 passed, 0 failed, 0 skipped**,
`enforcement-tests: OK`, 586 s. The six 016 cases are in that count, and no pre-existing
expectation was edited in this phase (`git diff` touches no existing `expected.txt`), so every
pre-existing case passed unchanged (SC-003). The exit code was not captured separately; the
runner's `OK` verdict is what it prints only on exit 0.

### T013 — the two mutations (D7, SC-004)

Run 2026-09-30 through the harness (pwsh 7.6.6, Pester 5.7.1) by a scratch script that backs up
the three scripts, applies each mutation, runs the named cases and restores them; the restore was
hash-checked against the backup (`True`).

| Mutation | What changes | Cases | Result |
|---|---|---|---|
| (a) | the three scripts reverted to `e10da18` (T007-T009 undone), today's tests | `-Case wrapped-span`: 3 cases | **all 3 fail**, both assertions each; 33 passed, 6 failed, exit 1 |
| (b) | no paragraph boundary: `Convert-CodeSpanMarkers` pairs spans over the whole document joined | `-Case comment-block-backticks`: 2 cases | **both fail**; 33 passed, 4 failed, exit 1 |
| (b) | as above | `-Case hidden-after-unpaired`: 1 case | **fails**; 33 passed, 2 failed, exit 1 |

Every green-turning case fails without the fix, and every guard fails under the over-reaching
fix, so no guard survived (b) and none needed rewriting. Under (b) `fail-hidden-after-unpaired`
fails by counting the hidden record as a grant, which is the fail-open direction it guards. The
33 passes in each run are the harness's own self-tests and coverage checks.

### T014 — cost (FR-010, SC-006)

Deterministic cost: child processes per check are unchanged. `scripts/markdown-lib.ps1` starts no
process, `Get-VisibleFromText` and `Get-DocMarkers` each make one call where they made one per
line, and neither caller gained a git or process call.

Wall clock, `pwsh -File scripts/build-digests.ps1 -Check` on the kit, three runs each on this
machine: parent `0.57 0.54 0.51` s, fix `0.64 0.58 0.59` s. The means differ by about 0.06 s,
which is the same size as the spread within each set of three. Three samples cannot separate a
cost that small from noise, so it is reported as at most tens of milliseconds on the digest
check, not as zero. The amendment check was not timed separately; it calls the same function.

The T002/T005 and D6 amendment was approved by the owner on 2026-09-30 and committed alone as
`85c8650`, before this phase's commit; `enforcement-pack.ps1` graded it (4 of 4 commits, OK).
