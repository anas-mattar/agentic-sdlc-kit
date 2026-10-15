# Feature Specification: Make an unreadable diff a named state, not an empty changed-file list

**Feature Branch**: `028-unreadable-diff-named-state`
**Created**: 2026-10-15
**Status**: Draft (awaiting owner approval)
**Delivery Level**: Standard
**Rationale Rule**: 1
**Input**: User description: "GAP-034: `Get-ChangedFiles` in `scripts/enforcement-pack.ps1` swallows a failing `git diff`, so a diff git cannot compute returns an empty list with no error and no message; the pack prints `N changed file(s)` as `0`, the Lite-lane abuse check grades an empty list, and feature 027's Lite amendment gate reads the same list. Make an unreadable diff a named state, not an empty changed-file list."

## Background

`Get-ChangedFiles` (`scripts/enforcement-pack.ps1`) is `git diff --name-only <base> HEAD 2>$null`, filtered. When git cannot compute the diff (an unreadable tree or commit
object on the branch, or any other failure), the command exits non-zero, the error text is discarded, and the function returns an **empty list**: the same value a branch
with no changes returns. Everything downstream reads that value as "nothing changed":

- the pack prints `enforcement-pack: branch '<b>', diff base '<sha>', 0 changed file(s)`, which reads as an empty branch;
- `Invoke-LiteAndAbuseCheck` (`fix/` and `chore/` branches) grades an empty list, so every prohibited-category change (dependency manifest, auth, migration, contracts) and the
  file-count guard pass;
- feature 027's Lite amendment gate (`Invoke-AmendmentAuthorityCheck`) reads the list, and then reads the diff a second time with its own `git diff ... 2>$null`, so a Lite
  branch with an unreadable diff is not graded and says nothing. 027 states this as a limit (flow-down note, limit 3; the script's `LIMITS` comment) and names this gap.

The **missing-base** case is already named: a `WARNING` that nothing was compared and, on the Lite lane, an `UNGRADED` line (feature 015, FR-009; D6). This is the same silence
reached by a different cause: git ran, failed, and nothing said so.

**Reproduced (2026-10-15, this feature's evidence; the roadmap row said "not reproduced on a `fix/` branch").** A throwaway repository: `main` with a README; branch `fix/x`
adding `package.json` and `src/db/migrations/001.sql` in one commit.

| State of the branch's tree object | `git diff --name-only main HEAD` | pack output | exit |
|---|---|---|---|
| readable | `package.json`, `src/db/migrations/001.sql` | `2 changed file(s)`, three `LiteAndAbuse` failures (dependency manifest, migration, migration path) | **1** |
| the tree object of `HEAD` emptied on disk | `fatal: unable to read tree`, exit 128 | `0 changed file(s)`, `enforcement-pack: OK` | **0** |

The same repository on a `docs/x` branch prints `0 changed file(s)` and the lane line, `OK`. So a `fix/` branch carrying a dependency manifest and a migration goes green when
its diff cannot be read.

**Other readers of the same kind (inventoried, not all in scope; see the decision below).** By reading the code, not reproduced:

| Site | What it reads | Behaviour on a failing `git diff` |
|---|---|---|
| `Get-ChangedFiles`, `scripts/enforcement-pack.ps1` | the list the dispatch passes to `LiteAndAbuse` and to the Lite amendment gate | empty list, count line `0` |
| `Invoke-ReviewProvenanceCheck`, same file, `git diff --name-status --diff-filter=AR` | review files added or renamed on **every** lane | empty rows: no review file is seen, so none is graded |
| the Lite amendment gate's second read, same file, `git diff --name-only --no-renames` | spec documents moved off `specs/` | empty: not graded |
| `scripts/territory-check.ps1`, `git diff --name-only HEAD` (uncommitted) and `git diff --name-only <base>...origin/<other>` | the files an open branch touches | empty: the overlap with that branch is read as none |
| `scripts/territory-check.ps1`, `Read-CodeRef` and the own-branch read | the same, for code repositories and the own branch | **already named**: `Ok = $false` with a reason, and `Stop-Refused` |

## Decision for the owner

Two decisions. Recommendations first, alternatives after.

**Decision 1 (what the pack does with a diff it cannot read). Recommendation: B, the numbered lane fails and the Lite lane names it UNGRADED.**

| | Shape | What it does | Cost |
|---|---|---|---|
| A | Name it on every lane, never fail | The count line says the diff was unreadable (not `0`); a `WARNING` and an `UNGRADED` line say what graded nothing; exit codes unchanged. | A numbered branch whose diff cannot be read exits 0, while the same branch's other uncomputable states (a shallow clone, an unreadable commit) fail. The numbered lane stays the odd one out. |
| B (recommended) | Numbered lane: a failure naming the cause. Lite lane (`fix/`, `chore/`, `docs/`): an `UNGRADED` line per check that graded nothing, exit code unchanged. | Mirrors feature 027's D8, which is the same split for the amendment check: the numbered lane keeps its refusals as failures, and a Lite branch is never newly failed on a condition the machine cannot compute (feature 014, FR-009). The run reads as "not graded", never clean. | A numbered branch with a damaged object newly fails with a clear message. It could not have passed the amendment check on the same damage (an unreadable commit already fails there), so the new failure adds a name to a failure that was already coming. |
| C | Fail on every lane | Strongest verdict. | Contradicts feature 014's FR-009 (no new hard failure on the Lite lane for an uncomputable condition); needs an owner amendment of that rule. Not recommended. |
| D | Leave the code, keep the stated limit | Nothing built. | The hole reproduced above stays: a prohibited change goes green. |

**Decision 2 (which readers). Recommendation: the three in `scripts/enforcement-pack.ps1` only** (`Get-ChangedFiles`, the review-provenance row read, the Lite amendment
gate's second read), because they share one fix and one fixture shape. `scripts/territory-check.ps1`'s two unchecked reads (the uncommitted-tree diff and the other branch's
diff) are inventoried above and **left as a stated limit**, with a roadmap row recorded at merge if the owner wants it. Alternative: include them, which adds a second script and
a second fixture family to a feature whose point is one small, provable change.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A Lite branch whose diff cannot be read is not reported clean (Priority: P1)

An owner or an agent runs the pack on a `fix/` or `chore/` branch whose diff git cannot compute. The run says so, and does not print an `OK` the Lite-lane guards never earned.

**Why this priority**: it is the hole, reproduced: a dependency manifest and a migration passed a lane that exists to refuse them.

**Independent Test**: a fixture built from the reproduction (a `fix/` branch adding `package.json` and a migration, the object the diff needs unreadable): the run prints
an `UNGRADED` line naming `LiteAndAbuse` and the cause, ends on `enforcement-pack: UNGRADED`, never `OK`, and exits 0; the same branch with a readable diff still fails
with three `LiteAndAbuse` lines.

**Acceptance Scenarios**:

1. **Given** a `fix/` branch whose `git diff` fails, **Then** the count line does not read `0 changed file(s)`, an `UNGRADED` line names `LiteAndAbuse` and says its prohibited-category and file-count guards graded nothing, the verdict is `UNGRADED`, and the exit code is 0.
2. **Given** a `docs/` branch whose `git diff` fails, **Then** the count line is named, an `UNGRADED` line says the Lite amendment gate graded nothing, and the lane line does not claim more than ran.
3. **Given** the same branches with a readable diff, **Then** the output is byte-identical to today's.

---

### User Story 2 - A numbered branch whose diff cannot be read fails with a name (Priority: P1)

On an `NNN-*` branch the unreadable diff is a failure that names the cause, as the other uncomputable states of that lane already are.

**Why this priority**: the count line is the first thing a reader of the run sees, and `0 changed file(s)` is false; and the review-provenance read behind it grades nothing.

**Independent Test**: a fixture built from feature 026's reproduction (a merge whose second parent has an unreadable tree, which printed `diff base '<sha>', 0 changed file(s)`): the run fails with a line that names the unreadable diff and the base, instead of `0`.

**Acceptance Scenarios**:

1. **Given** a numbered branch whose `git diff` fails, **Then** the count line is named, one `enforcement-pack` failure says the diff could not be read and why it matters, and the exit code is 1.
2. **Given** a numbered branch with a readable diff, an empty diff, or no base, **Then** the output is byte-identical to today's.

---

### User Story 3 - A diff that is simply empty, and everything healthy, is unchanged (Priority: P1)

A branch with no changes still prints `0 changed file(s)` and `OK`. A readable diff, a missing base, a shallow clone and a trunk branch keep their existing output.

**Why this priority**: the new state must be told apart from the old, true one, and every green run on real history must stay green.

**Independent Test**: the existing harness passes unchanged; a replay of the kit's and the three adopted projects' histories (FR-010) shows no output differing.

**Acceptance Scenarios**:

1. **Given** a branch whose base equals `HEAD`, **Then** it prints `0 changed file(s)` exactly as today.
2. **Given** the missing-base and shallow-clone states, **Then** their existing warnings, `UNGRADED` lines and failures are byte-identical.

---

### User Story 4 - The limit is retired in the documents, and adopters are told (Priority: P2)

Every place that states the limit says what is now named and what stays open: the script's `LIMITS` comments, feature 027's flow-down limit (3), and the roadmap row. Adopters get a flow-down note.

**Why this priority**: 027 wrote the limit into the adopter-facing note; leaving it there would be a document that says the opposite of the code.

**Independent Test**: grep the documents named in FR-012 for the limit's wording; none states the old behaviour as current; `scripts/ritual-checks.ps1` is green.

**Acceptance Scenarios**:

1. **Given** the feature merged, **Then** `adoption/updating.md` carries a flow-down note in the shape of 026's and 027's (what was wrong, what it does now, what flows down, what an owner may newly see, what does not change, the known limits, what was measured, what to do).

---

### Edge Cases

- **A diff that git computes and that is empty** (base equals `HEAD`, or only ignored changes): unchanged, `0 changed file(s)` and no new line. The new state is entered on a non-zero exit of `git diff`, never on an empty result.
- **A diff that prints some rows and then fails:** the partial list is **discarded**, not graded; a partial list is the more dangerous case, because it looks like a short branch.
- **No diff base:** unchanged. The existing `WARNING` and the Lite `UNGRADED` line already name it; the new state is entered only when a base exists and the diff against it fails. Nothing prints twice for one cause.
- **A shallow clone:** unchanged. `AmendmentAuthority` already fails or (on the Lite lane) names it; a diff that fails because the history is not there is the same cause, and the pack names it once.
- **A `docs/` branch:** the only scripted checks are review-provenance and the Lite amendment gate; both are named when the diff cannot be read, and the lane line says which ran.
- **A `-ReplayBase`/`-ReplayTip` replay** (analysis only): the replay reads ranges git can compute; behaviour with a readable range is unchanged.
- **A trunk branch (`main`, `master`):** no scripted checks apply and no diff is read, as today.
- **The Lite amendment gate's own second read** fails while the first read succeeded (or the reverse): either failure enters the same named state; a gate that cannot be computed never reads as "no spec document changed".
- **`git` not on the path or not a repository:** the pack already stops before any member runs; unchanged.
- **Feature 027's flow-down limit (3)** ("a Lite branch with an unreadable diff is not graded and prints as before") is **superseded** by this feature; 027's documents are history and are not edited, and the new flow-down note says so, in the shape 026 used for 014's D7.

## Level Rationale *(mandatory — answers the four Critical triggers, in writing)*

- **domain-invariants**: does not apply — the kit has no domain-invariants pack; this changes what a script says when a git command fails.
- **irreversible-data**: does not apply — nothing is migrated, dropped or rewritten; commits are read, never changed.
- **authn-authz-payment**: does not apply — no authentication, authorization or payment is touched.
- **auditable-evidence**: does not apply — the pack's verdict is a machine aid behind gate 6 (human review at merge), which is unchanged and stands behind it; this feature makes a verdict
  *honest about what it graded*, adds no evidence a regulator would rely on. The counter-argument (the pack is part of the evidence trail) is the one 026 and 027 answered the same way: Standard.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The pack MUST tell a diff git could not compute apart from a diff that is empty. A failing `git diff` MUST NOT be returned as an empty list.
- **FR-002**: When the diff cannot be read, the `enforcement-pack: branch '<b>', diff base '<sha>', N changed file(s)` line MUST NOT read `0 changed file(s)`; it MUST say the diff could not be read.
- **FR-003**: On the Lite lane (`fix/`, `chore/`, `docs/`), each check that depended on the unreadable diff MUST print one `UNGRADED:` line naming the check and the cause (`LiteAndAbuse` on `fix/` and `chore/`, the Lite amendment gate on all three), the verdict MUST NOT be `OK`, and the exit code MUST NOT change (feature 014, FR-009).
- **FR-004**: On a numbered branch, an unreadable diff MUST be a failure that names the cause and the diff base (Decision 1, option B).
- **FR-005**: `Invoke-ReviewProvenanceCheck`'s own `git diff --name-status` read MUST enter the same named state on every lane, so a review file cannot pass because its diff was never read.
- **FR-006**: The Lite amendment gate's second `git diff --name-only --no-renames` read MUST enter the same named state; a gate that cannot be computed MUST NOT read as "no spec document changed".
- **FR-007**: The state MUST be entered only on a non-zero exit of `git diff`, with a base present. An empty readable diff, a missing base, a shallow clone and a trunk branch MUST print exactly what they print today.
- **FR-008**: A partial result from a failing `git diff` MUST be discarded, never graded.
- **FR-009**: Every behaviour here MUST have a failing and a passing fixture written first and shown failing on the parent commit, built from field shapes (the `fix/` reproduction above, 026's unreadable-parent merge on a numbered branch, a `docs/` branch, an empty diff as a control). Each new emission site is owned by a rule inventoried in `tests/enforcement/rules.json`. Every pre-existing case MUST pass unchanged.
- **FR-010**: The measurement MUST be re-run per merge, in the shape CI grades a pull request, on this kit's history and on clones of the three adopted projects, old script against new, Lite branches included, and report: how many outputs differ (expected: none, because a diff that cannot be read has never occurred in these histories), and MUST say plainly that this shows no healthy branch changes and does **not** show how the new state reads on a damaged repository (the fixtures show that).
- **FR-011**: `scripts/territory-check.ps1` and every other reader outside `scripts/enforcement-pack.ps1` are **not changed** by this feature (Decision 2); the stated limit names them.
- **FR-012**: Every document that states the limit MUST say what is now named and what stays open: the script's `LIMITS` comments (the amendment check's header and the changed-file reader), `docs/roadmap.md` (GAP-034: shipped, with the owner and spec path), `adoption/updating.md` (a flow-down note that supersedes 027's limit 3), and any sentence in `docs/sdlc/` that says an unreadable diff is graded as empty (a task greps and edits only the sentence that is now false); digests are regenerated by `scripts/build-digests.ps1`, never by hand.

### Key Entities

- **Unreadable diff**: the state in which `git diff` against a present base exits non-zero. It is a property of the run, carried alongside the changed-file list, not a value of it.
- **Changed-file list**: the files a branch changes against the base, when git can compute it.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The reproduction above (a `fix/` branch adding a dependency manifest and a migration, the diff unreadable) no longer ends on `OK`: the run says `UNGRADED`, names `LiteAndAbuse`, exits 0; with a readable diff it still fails with three lines.
- **SC-002**: A numbered branch whose diff cannot be read fails and names the cause; the count line never reads `0` for an unreadable diff on any lane.
- **SC-003**: An empty readable diff, a missing base, a shallow clone and a trunk branch print byte-identically to the parent commit.
- **SC-004**: Across the kit's history and the three adopted projects, the replay (FR-010) reports its counts, and no output differs.
- **SC-005**: The full harness passes with every pre-existing case unchanged and no unowned emission site.

## Assumptions

- A non-zero exit of `git diff --name-only <base> HEAD` (or its `--name-status` form) is the machine's definition of "unreadable"; git's own message is not parsed.
- The fixture library can already reach the state (`truncateCommit` names a commit object, which `git diff` needs; 026 used it), so no harness capability is expected; the plan confirms by writing the first fixture.
- The verdict vocabulary (`OK`, `FAIL`, `WARN`, `N/A`, `UNGRADED`, `PENDING`) is defined once, in `scripts/ritual-checks.ps1`; this feature adds no word to it.
- Feature 014's FR-009 (the Lite lane is never newly failed on a condition the machine cannot compute) stands; feature 027's D8 is the precedent for the lane split.
- Feature 026's and 027's documents are history and are not edited; this spec records the supersession of 027's limit 3.
- The pack's other `git` reads (`git log`, `git show --numstat`, `ls-tree`) are not changed here; the replay and the fixtures say whether any of them shows the same silence, and a finding becomes its own roadmap row.
