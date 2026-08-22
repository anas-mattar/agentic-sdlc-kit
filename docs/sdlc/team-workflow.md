# Team Workflow — Multiple Developers, Multiple Agents

The kit was extracted from a single-developer deployment; this document is the layer that
makes it safe for N developers, each driving their own agent. Single-developer projects can
ignore this file — nothing else depends on it.

## 1. Feature ownership — who "the user" is

Every feature has exactly **one owner**: the developer whose agent implements it, who runs
the gate for it, and who confirms the exit code. Wherever this kit says "the user"
(gate-command, review-process, definition-of-done, CLAUDE.md), it means **the feature's
owner** — not any teammate, and never the agent.

## 2. Number reservation — the remote is the ledger

Feature numbers are claimed on the remote, not computed locally
(see `docs/sdlc/branch-strategy.md`, "Number Allocation"):

1. `git fetch origin` before allocating.
2. Take the next `NNN` unused by any local **or remote** branch or `specs/` directory.
3. `git push -u origin NNN-<name>` **immediately** — the number belongs to whichever
   branch reaches the remote first. Lose the race → renumber before any other work.

## 3. Cross-review — the owner never approves their own feature

With one developer, human review means reviewing your own agent's work. With a team there
is no excuse: **the human reviewer of a feature MUST NOT be its owner** (constitution XII
gains teeth). The owner completes the AI review; a different developer completes
`human-pr-review.md` and holds the merge approval.

## 4. Territory check — before a phase, not at merge

`plan.md` declares what the feature touches. Before starting each phase, the owner (or
agent) checks that no *other open feature branch* claims the same files:

```bash
git fetch origin
git diff --stat main...origin/<other-open-branch>   # per open feature branch
```

Overlap is not forbidden — it is **sequenced**: the owners agree on merge order, and the
later feature rebases after the earlier one lands. Discovering overlap at merge time is a
process failure; record the agreed order in both features' `plan.md`.

## 5. Rebase before gate

The gate certifies the phase **as it will land**, not as it was written. Before asking for
the gate on the final phase (and after any teammate's merge that touches your territory):
rebase the feature branch on current `main`, re-run the loop if UI was touched, then gate.

## 6. Governance changes ride alone

Constitution and `docs/sdlc/` changes never travel inside a feature branch. They get their
own `docs/<name>` branch and require team-lead (or whole-team) approval — a feature merge
must never silently change the law the next feature is judged by.

## 7. CI on main is the referee

With concurrent merges, two individually-green features can be jointly red. The CI gate
must run on `main` after every merge; a merge that turns `main` red is **reverted
immediately** via the `fix/` lane — no debugging on a red `main`. The user-run gate remains
the per-feature trust ritual; CI is the cross-feature one.
