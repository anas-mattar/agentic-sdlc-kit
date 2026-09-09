# Research — 012 Cross-Repo Scope-Check Reach

Decisions taken before planning. Each records the options considered, the choice, and why.

## D1 — Fix shape: governance-side sibling reader

**Options**: (a) ship a thin `scripts/` set into each code repository at adoption;
(b) a governance-side runner that reads the code repositories as sibling working trees.

**Decision**: (b).

**Why**: the Territory declaration lives in the governance repository
(`specs/NNN-name/tasks.md`), so (a) still has to reach back across the boundary — it buys
nothing and costs a copied script set in repositories that `scripts/update-kit.ps1` does not
manage. That is precisely the sync ratchet GAP-006 and GAP-007 cost two flow-downs to unwind:
a kit-owned file living where no update channel reaches it drifts, and every later amendment
must be hand-applied per code repository. (b) keeps one implementation, one place to amend, and
one source for the declaration.

**Consequence**: the check runs where the nested layout exists — a developer's machine, or a CI
job that deliberately checks out both. Governance CI (which clones the governance repo alone)
reports `n/a`; D5 covers the CI reach.

## D2 — Which repositories: declared, not discovered

**Options**: (a) auto-discover every child directory containing `.git`; (b) an explicit
`codeRepos` array in `kit-adoption.json`.

**Decision**: (b), with a doctor warning when a `multi` topology declares none.

**Why**: auto-discovery grades whatever happens to be sitting in the working directory — a
scratch clone, a vendor checkout, an unrelated project a developer parked there — and its
verdict then depends on the machine rather than on the repository. `kit-adoption.json` is
already the durable record of topology and tiers and already the doctor's source of truth
(`scripts/verify-kit.ps1`, dimension 4), so the repository list belongs beside them. Explicit
declaration also makes the "declared repo is missing" case detectable, which discovery cannot
distinguish from "no code repos".

**Shape**: `"codeRepos": ["fitforge-api", "fitforge-web"]` — single-segment directory names
under the governance root. Nested or absolute paths are rejected by the doctor; the nested
layout the kit documents puts code repositories exactly one level down.

## D3 — Territory paths: repo-prefixed, governance-root-relative

**Options**: (a) per-repository territory sub-blocks in `tasks.md`; (b) one flat list whose
entries carry the repository directory as their first segment.

**Decision**: (b) — `` `fitforge-api/src/Training/**` ``, `` `fitforge-web/app/(training)/**` ``.

**Why**: (b) needs no new declaration syntax, no template change, and no second parser — the
existing `Get-Territory` and `Test-InTerritory` grade it unchanged once each code repository's
paths are prefixed with its directory name. It also reads the way the developer sees the tree
from the governance root, which is where they run the command. (a) would fork the declaration
format between single- and multi-repo projects, and every document that explains Territory
would need two versions of the explanation.

**Consequence**: a territory entry whose first segment names a repository that is not declared
in `codeRepos` is a probable typo (`fitforge_api/…`) and is reported as a configuration
warning rather than silently matching nothing.

## D4 — Anti-retroactivity across repositories: read the declaration as of the code commit

**Options**: (a) read the declaration from the governance branch tip (no protection);
(b) compare timestamps and FAIL when the declaring commit is newer than the code commit;
(c) read the declaration from the newest governance commit whose commit date is not after the
code commit's — the declaration *as it stood when the code was committed*.

**Decision**: (c).

**Why**: (a) makes the gate passable retroactively — commit the stray file, widen the
declaration, re-run green — which is worse than no gate because it looks like one. (b) is the
right instinct but the wrong instrument: it FAILs whenever `tasks.md` is touched after a phase
commit for any reason at all (ticking a checkbox, declaring the *next* phase's territory), so
it would fire constantly on legitimate work and be disabled within a week. (c) is the exact
cross-repository analogue of the in-repo rule — which reads the declaration from the commit's
parent, i.e. as it stood when the commit was made (`scripts/scope-check.ps1`,
anti-retroactivity) — and it has no false-positive mode: later edits are simply not visible to
an earlier commit's verdict.

**Mechanics**: `git rev-list -1 --before=<code commit's committer date> <governance ref>` gives
the governance commit to read `tasks.md` (or `spec.md` on Micro) from. No commit at or before
that time (the code repository has history predating the feature's spec) → the same
non-blocking WARN the in-repo check gives for a missing declaration.

**Accepted limit**: this orders two clocks. On one developer's machine and inside one CI run
they are the same clock; a rewritten committer date defeats it, as it defeats every date-based
rule in git. The rule is a guard against after-the-fact widening, not against forgery — stated
in the spec's Assumptions.

## D5 — CI reach: a code-repository workflow template

**Options**: (a) governance CI clones the code repositories (needs credentials for every code
repo, and the governance run then depends on N other repositories' availability); (b) each code
repository's own CI checks out the governance repository as a sibling and runs the check for
itself; (c) local-only.

**Decision**: (b), shipped as `.github/workflows/code-repo-scope-check.yml.template` — the
same "template the adopter copies and fills" pattern as the existing
`project-gate.yml.template`.

**Why**: the code repository's CI already runs on exactly the event that matters (a push of the
code phase commit), and it needs read access to one repository — the governance one — which the
team already has. (a) inverts the dependency and multiplies credentials. (c) leaves the check
running only by discipline, which the kit's own README calls the disease that kills rule-based
frameworks.

**Consequence**: the template carries two slots — the governance repository and, for a private
one, the token secret — and the run's `-Branch` is passed explicitly because a CI checkout is a
detached HEAD.

## D6 — Shared implementation: one library, dot-sourced

**Options**: (a) copy the parsing/matching helpers into the new script; (b) extract them into a
library both scripts dot-source; (c) make the existing script multi-repo aware with a switch.

**Decision**: (b) — `scripts/scope-lib.ps1`, holding `Get-VisibleLines`, `Test-IsMicro`,
`Get-Territory`, `Test-InTerritory`, and `Get-CommitPaths`, dot-sourced by
`scripts/scope-check.ps1` and the new `scripts/scope-check-repos.ps1`.

**Why**: (a) guarantees the two graders drift — the Micro lane, the rename handling and the
literal-bracket matching each arrived as a separate fix, and each would now need applying twice.
(c) would bury two different traversals (this repo's commits vs N repos' commits, two different
declaration-resolution rules) in one dispatch, and every existing caller and CI wrapper would
inherit the risk of a regression in a check that already works.

**Placement**: flat in `scripts/`, not `scripts/lib/` — the manifest's `scripts/*.ps1` verbatim
glob does not descend into subdirectories, and a kit-owned file outside the manifest is exactly
the class of drift `doc-lint`'s completeness sweep exists to catch.

**Compatibility**: the extraction is behavior-preserving; `scripts/scope-check.ps1` keeps its
CLI, verdicts and exit codes unchanged (contract `specs/006-verification-pack/contracts/`).
