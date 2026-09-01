# Research: Flow-Efficiency Pack

All Technical Context unknowns resolved. Decisions below; each records what was chosen,
why, and what was rejected.

## D1 — Flow page location, name, and diagram format

**Decision**: `docs/sdlc/flow.md`, containing one ASCII flow diagram in a fenced text
block plus a step table (`| Step | One line | Owning document |`).

**Rationale**: `docs/sdlc/` is where every other ritual document lives, so doc-lint and
the Task-Scoped Reading table cover it with zero new conventions. ASCII renders
identically in terminals, GitHub, and raw-markdown agent reads — the kit's three real
consumers — and the kit already uses fenced text trees everywhere.

**Alternatives considered**: Mermaid diagram (renders on GitHub but is noise in a
terminal and for agents reading raw text); a README at repo root (competes with
CLAUDE.md as an entry point); amending CLAUDE.md itself (CLAUDE.md must stay small — it
is always-loaded).

## D2 — Claim script: delegate vs reimplement

**Decision**: `scripts/claim-feature.ps1` computes the remote-aware number itself, then
delegates branch + spec-directory creation to the stock
`.specify/scripts/powershell/create-new-feature.ps1 -Number <n>` (parameter verified to
exist, overrides local auto-detection), then pushes with `-u`. Race detection = push
rejection or the branch appearing on the remote under another head; recovery = rename
branch and spec directory to the next free number, push again (bounded retries).
Preflight: working tree clean and current branch is `main`, else stop — mirrors the
kit's existing "stop if unrelated uncommitted changes exist" workflow rule. No remote
configured → allocate locally, skip push, print an explicit "claim is not team-visible"
warning (FR-004).

**Rationale**: The stock script already owns naming, spec-directory layout, and template
copying; duplicating that logic is drift waiting to happen (the kit's own lesson from
feedback #2). The only thing it cannot do is remote-aware allocation and the push —
exactly the gap the wrapper fills.

**Alternatives considered**: Reimplementing allocation + creation in one script
(duplicates stock logic); patching the stock script in place (it is vendored Spec Kit
material — local edits are lost on kit upgrades).

## D3 — Territory check: what counts as "touched files"

**Decision**: The current feature's touched set = files changed on the current branch
versus `main` (`git diff --name-only main...HEAD`), unioned with any not-yet-committed
tracked changes. Each open remote `NNN-*` branch's set = `git diff --name-only
main...origin/<branch>`. Overlap = set intersection, reported per branch. Exit codes:
`0` clean, `2` overlap found, `1` execution error — machine-distinguishable per FR-005
while the report text keeps team-workflow rule 5's stance (sequenced, not forbidden).
Branches with no commits beyond main are reported as "claimed, no work yet" (edge case:
plan.md may not exist on them). A branch whose last commit is older than the reclaim
window (14 days, matching team-workflow rule 3) is flagged "stale — reclaimable" instead
of being treated as a live conflict.

**Rationale**: Committed diffs are the only claim that exists in git (the kit's "the
claim lives in git" principle); parsing plan.md prose for intended paths is unreliable
and would make the check lie when plans are vague. Exit code `2` (not `1`) for overlap
keeps "found something" distinguishable from "the check itself broke", the same split
git and grep use.

**Alternatives considered**: Parsing plan.md for declared paths (prose parsing is
brittle; plans declare intent, diffs declare fact); failing (non-zero = block) on any
overlap (contradicts rule 5 — overlap is sequenced, not forbidden).

## D4 — Batch declaration format (machine-checkable)

**Decision**: One line in plan.md, same bold-field style the templates already use:
`**Gate Batching**: none` or `**Gate Batching**: phases 2-3`. Absent line ⇒ `none`
(backward compatible — 001/002 plans stay valid). The enforcement pack parses only this
line: FAIL if the feature's spec.md declares `Delivery Level: Critical` and the value is
not `none`/absent (FR-009); FAIL if the declared span exceeds 3 phases (FR-008); the
declaration must exist before the batch's first phase is implemented — checked socially
at plan approval, not mechanically (git-archaeology on when a line was added is not
worth the complexity).

**Rationale**: The enforcement pack already parses exactly this kind of bold-field line
(`Delivery Level`) from feature artifacts — same parser shape, same failure style.

**Alternatives considered**: YAML frontmatter in plan.md (new convention, rejected for
the same reason the kit rejected the YAML manifest in the improvement-proposal review);
a separate `batch.md` artifact (one more file to forget).

## D5 — Constitution X amendment wording and version

**Decision**: Append a **Batched gates** clause to principle X: for Lite and Standard
features, a run of at most 3 consecutive phases MAY be declared in the approved plan
(before the batch starts) to share one certifying user-run gate at batch end; each phase
still requires its own commit, scope check, and AI review, and the agent still runs the
gate per phase for feedback; Critical features are excluded. Version 0.3.0 → **0.4.0**
(MINOR — guidance materially expanded), SYNC IMPACT REPORT updated, mirror updates to
`plan-template.md` (Constitution Check X item + Gate Batching line) and
`definition-of-done.md` (gate 3), per the constitution's own template-sync list.

**Rationale**: Batching contradicts X's current unconditional per-phase wording; putting
the rule anywhere else creates a doc-vs-constitution conflict the kit forbids. MINOR is
correct under the stated versioning policy: no principle is removed or redefined
backward-incompatibly — the default (per-phase gate) is unchanged unless a plan opts in.

**Alternatives considered**: docs-only rule (conflict, see above); MAJOR bump (wrong —
existing behavior remains the default and remains compliant).

## D6 — Pipelining clause placement and mechanics

**Decision**: Amend team-workflow rule 3 only (plus a pointer from flow.md). Mechanics:
a developer MAY claim a second feature when the first has every phase committed
gate-green, is pushed, and human review is formally requested; hard cap one
awaiting-review + one active; the second feature's territory MUST be disjoint from the
first's (or explicitly sequenced behind it in both plans); when review returns change
requests, the developer finishes the current phase of the second feature to a clean
gate-green commit, then returns to the first before starting any further phase.

**Rationale**: The WIP limit lives only in team-workflow — no constitution change
needed. The territory-disjoint requirement exists because change requests reopen the
first feature's files; without it, pipelining manufactures the merge-order conflicts
rule 5 exists to prevent. Resolution order was chosen by the user (2026-09-01): no
half-done phases left behind; review turnaround waits at most one phase.

**Alternatives considered**: Cap of 3+ in flight (claims stop meaning "being worked
on" — the exact failure rule 3 was written against); drop-back-immediately on change
requests (leaves mid-phase WIP, rejected by the user).
