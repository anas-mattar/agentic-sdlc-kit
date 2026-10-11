# Team Workflow — Multiple Developers, Multiple Agents

The kit was extracted from a single-developer deployment; this document is the layer that
makes it safe for N developers, each driving their own agent. Single-developer projects can
ignore this file — nothing else depends on it.

## 1. Feature ownership — who "the user" is

Every feature has exactly **one owner**: the developer whose agent implements it, and who
certifies its gate — by running it and confirming the exit code, or, under a declared
`ci-held` (Lite/Micro/Standard only, declared in the plan — or the Micro mini-spec —
constitution X), by recording approval on the CI evidence
triplet. Wherever this kit says "the user"
(gate-command, review-process, definition-of-done, CLAUDE.md), it means **the feature's
owner** — not any teammate, and never the agent.

<!-- digest: Every feature has exactly one owner — "the user" means the feature's owner, never a teammate and never the agent. -->

## 2. Number reservation — the remote is the ledger

Feature numbers are claimed on the remote, not computed locally
(see `docs/sdlc/branch-strategy.md`, "Number Allocation"). One command runs the whole
ritual — fetch, remote-aware allocation, branch + spec creation, immediate push, and
automatic renumbering on a lost race:

```powershell
pwsh -File scripts/claim-feature.ps1 -ShortName <name> "<feature description>"
```

The recipe it automates (kept as the manual fallback):

1. `git fetch origin` before allocating.
2. Take the next `NNN` unused by any local **or remote** branch or `specs/` directory.
3. `git push -u origin NNN-<name>` **immediately** — the number belongs to whichever
   branch reaches the remote first. Lose the race → renumber before any other work.

## 3. Picking up a feature — the claim lives in git, not in a conversation

How a developer takes a feature from the roadmap (**docs/roadmap.md**, see
`specs/_templates/roadmap-template.md`):

1. **Choose** from the top of the roadmap's priority order, checking two things first:
   dependencies (don't pick a feature whose foundations are unshipped) and territory —
   `git fetch origin`, list the open `NNN-*` remote branches, skim their `plan.md`s. If
   your candidate overlaps an in-flight feature, pick something else or agree merge order
   with that owner now (rule 5), not at merge time.
2. **Claim by pushing.** Run `/speckit.specify`, then `git push -u origin NNN-<name>`
   immediately. **A remote `NNN-*` branch IS the claim** — no meeting, no chat message.
   Everyone checks remote branches before picking, never the roadmap alone.
3. **Update the roadmap row in your first commit on the branch** — Owner, Status →
   `specified`, spec link — so the claim reaches `main`'s roadmap when the feature merges.
   Until then, the remote branch (step 2) is the authoritative claim.
4. From here the normal ritual applies unchanged; the picker is the feature's owner
   (rule 1), and picks their cross-reviewer (rule 4) at claim time — the owner of a
   neighboring feature is usually the best choice.

<!-- digest: A remote NNN-* branch IS the claim — check remote branches before picking, never the roadmap alone. -->

**WIP limit — one active feature per developer, with a pipelining exception.** Multiple
claimed branches are number squatting: claims stop meaning "being worked on." To park a
feature, push your progress and note it in the roadmap's decisions log so someone else
can adopt it.

**Pipelining — working through the review wait.** A developer MAY claim a second feature
while their first awaits review, under all of these conditions:

- The first feature is fully done from the owner's side: **every phase committed
  gate-green, the branch pushed, and human review formally requested** (a PR opened, or
  the reviewer explicitly asked). "Almost done" does not qualify.
- **Hard cap: one feature awaiting review + one active feature.** A third claim is
  number squatting, whatever the states.
- The second feature's territory is **disjoint** from the awaiting feature's
  (`scripts/territory-check.ps1`), or explicitly sequenced behind it in both features'
  `plan.md` — change requests may reopen the first feature's files at any time.
- **When change requests arrive** on the awaiting feature while the second is mid-phase:
  finish the current phase of the second feature to a clean gate-green commit, then
  return to the first feature and resolve the change requests **before starting any
  further phase**. No half-done phase is ever left behind; review turnaround waits at
  most one phase.

**Stale claims may be reclaimed.** A claimed branch with no commits for two weeks
(adjust to taste) is up for adoption: new owner, one line in the decisions log.

<!-- digest: WIP limit: one active feature each; pipelining: one awaiting-review + one active, territory disjoint or sequenced. -->

## 4. Cross-review — the owner never approves their own feature

With one developer, human review means reviewing your own agent's work. With a team there
is no excuse: **the human reviewer of a feature MUST NOT be its owner** (constitution IX
gains teeth). The owner initiates the fresh-context AI review (DoD gate 5 — produced by a
fresh-context agent or second model, never self-graded, with the Reviewer Provenance
block); a different developer completes
`human-pr-review.md` and holds the merge approval.

<!-- digest: Cross-review: the human reviewer of a feature must not be its owner. -->

## 5. Territory check — before a phase, not at merge

`plan.md` declares what the feature touches — on a Micro feature, its mini-spec
`spec.md`'s **Territory** block does (constitution X, Micro lane). Before starting each
phase, the owner (or
agent) checks that no *other open feature branch* claims the same files — one command:

```powershell
pwsh -File scripts/territory-check.ps1
```

It fetches, diffs the current branch and every open remote `NNN-*` branch against
`main`, and reports overlapping files per branch. Where `kit-adoption.json` declares
`codeRepos` (a nested multi-repo project), it reads each declared code repository too,
as a sibling working tree: the branch carrying the same name there, diffed against that
repository's own trunk (`main`, `master` or `origin/HEAD`, `origin/` forms first). Two
features whose `specs/` directories never meet but who both edit the same controller file
in a code repository are caught here, and the file is listed with its repository prefix,
`<repo>/<path>`, so it can be pasted into a Territory block unchanged. A feature's status
comes from its latest commit in **any** repository it has a branch in, so a stale spec
beside a live controller is live. Exit codes: `0` no live overlap, `2` live overlap found, `1` execution error. Stale
claims (no commits for two weeks) are flagged as reclaimable rather than treated as live
conflicts; freshly claimed branches with no work yet are noted, not errors.

**Read the verdict word, not only the exit code.** A comparison the check could not make
is listed as `UNGRADED: <repository>: <cause>`, the run ends on an `UNGRADED` line
instead of `CLEAN`, and the exit code is still `0`: it changes the verdict, not the exit
code, as in the other kit checks. An overlap keeps exit `2` and the ungraded lines print
beside it. In `-Json`, `CLEAN` is `false` whenever anything was not compared and
`UNGRADED` lists each entry (`repo`, `feature`, `cause`, `detail`). The causes, and what to
do about each:

| `UNGRADED` line | Meaning | Action |
|---|---|---|
| `<repo>: not present in this checkout` | declared in `codeRepos`, no such directory (a governance-only clone) | clone it beside the governance work, or run the check where it exists |
| `<repo>: not a repository of its own` | the directory exists but is not the root of its own git repository | make it the clone, or fix `codeRepos` |
| `<repo>: no resolvable trunk (tried …)` | none of `origin/main`, `main`, `origin/master`, `master`, `origin/HEAD` exists in it | fetch it, or create the trunk branch |
| `<repo>: fetch failed` | `git fetch origin` failed there; the stale local view is not passed off as current | fix the remote or credentials and re-run |
| `<repo>: cannot compare <feature> (…)` | that feature's branch there has no merge base with the trunk, or an unreadable ref | look at that branch; it may be an orphan or damaged |
| `governance: cannot compare <feature> (…)` | an open claim with no remote-tracking ref in this clone (usually a single-branch fetch refspec), or a branch that cannot be diffed against `main` (usually a shallow clone) | set `remote.origin.fetch` to `+refs/heads/*:refs/remotes/origin/*` and fetch, or `git fetch origin <feature>:refs/remotes/origin/<feature>` for one claim; deepen a shallow clone |
| `codeRepos: declaration unusable — …` | the record's `codeRepos` cannot be read in full: `kit-adoption.json` is not valid JSON, `codeRepos` is not an array, or an entry is a path | fix `kit-adoption.json`; `scripts/verify-kit.ps1` explains the shape. A bad entry skips only that entry; invalid JSON skips all code repositories |

A code repository with no `origin` is compared against its local branches only, and the
output says so (`compared <repo>: local branches only`); that note is not an ungraded
entry, and it appears in the text form only, not in `-Json`, so a `-Json` consumer should
not read `CLEAN: true` as a comparison against other developers' pushed work. On a fully
compared run, a project with no `codeRepos` (or an empty one) sees the original output
unchanged.

**Limits.** The check reads `codeRepos` from the working tree you run it in. A branch cut
before the declaration reached the trunk has none, gets the governance-only run and the
original `CLEAN` line, which does not say the code repositories were skipped; take the
trunk's declaration (rebase or merge) before relying on a clean result. `-Branch X` run from
another checkout reads that checkout's record. The check sees pushed work, plus a local
branch wherever a repository has no `origin` or `origin` has no ref for that feature: another developer's unpushed commits are invisible to any git-based check, which
is why a clean run names what it compared. A local branch that the remote no longer has
still counts as that feature's work in a repository, so a finished feature whose
governance branch is still open can keep reporting a live overlap until the stale local
branch is deleted. The manual equivalent (kept as the fallback):

```bash
git fetch origin
git diff --stat main...origin/<other-open-branch>   # per open feature branch, in each repository
```

Overlap is not forbidden — it is **sequenced**: the owners agree on merge order, and the
later feature rebases after the earlier one lands. Discovering overlap at merge time is a
process failure; record the agreed order in both features' `plan.md`.

<!-- digest: Run territory-check.ps1 before each phase, code repos too; UNGRADED is not clean; overlap is sequenced, never forbidden. -->

## 6. Rebase before gate

The gate certifies the phase **as it will land**, not as it was written. Before asking for
the gate on the final phase (and after any teammate's merge that touches your territory):
rebase the feature branch on current `main`, re-run the loop if UI was touched, then gate.

<!-- digest: Rebase on main before the final phase's gate, and after any teammate's merge touching your territory. -->

## 7. Governance changes ride alone

Constitution and `docs/sdlc/` changes never travel inside a feature branch. They get their
own `docs/<name>` branch and require team-lead (or whole-team) approval — a feature merge
must never silently change the law the next feature is judged by.

<!-- digest: Governance changes ride alone on a docs/ branch with team-lead approval — never inside a feature branch. -->

## 8. CI on main is the referee

With concurrent merges, two individually-green features can be jointly red. The CI gate
must run on `main` after every merge; a merge that turns `main` red is **reverted
immediately** via the `fix/` lane — no debugging on a red `main`. The owner-held certifying
gate (user-run — or plan-declared `ci-held`, `docs/sdlc/gate-command.md`) remains the
per-feature trust ritual; CI is the cross-feature one.

<!-- digest: A merge that turns main red is reverted immediately via the fix/ lane — no debugging on a red main. -->
