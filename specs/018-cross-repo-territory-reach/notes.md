# Notes: Cross-repo Territory Reach

Evidence and decisions that belong beside the feature but not in its approved documents.

## Approval record — 2026-10-11

The owner (anas.m) approved the spec and the plan on 2026-10-11. The Draft to Approved flip on
`spec.md` is the act that starts the amendment rule (constitution I); it is committed alone, so the
status-only exemption applies as written.

What the approval covers:

- `spec.md` as committed in 19592a9.
- `plan.md` as committed in 619f89c: decisions D1 to D8, the four-phase order, and
  `**Gate Certification**: user-run` (this feature changes an enforcement script).
- `research.md`, `data-model.md`, `contracts/territory-check-output.md` and `quickstart.md` as
  committed in the same commit, and `tasks.md` as committed after it, with each phase's Territory.

What it does **not** cover, stated plainly:

- **Plan D5 (research R6) is not decided.** Spec FR-013 and US3 scenario 2 say a project with no usable
  `codeRepos` sees its existing output unchanged; for a declaration that is present but unusable that
  means a warning and then `CLEAN`, which the spec's own constraint forbids. The plan recommends
  amending those two sentences so that an absent or empty declaration is unchanged and a present but
  unusable one is UNGRADED by name. Approving the spec and plan does not decide this: an amendment
  needs the owner's own approval line, and the spec sentences stand as written until it is given.
  Phases 1 and 2 do not depend on it. Task T016 stops phase 3 until it is decided.

## Phase 1

Written 2026-10-11. Implemented, not yet committed when this section was first written.

**T001, the baseline** (parent commit, `282beb9`, before any edit): `-Case REPOS-` 62 cases, 157
tests; `-Case SCOPE-` 116 cases, 265 tests; `-Case TERR-` 16 cases, 65 tests; 0 failed in each.

**What changed.** `Get-CodeRepos` is in `scripts/adoption-lib.ps1`; `Get-RepoTrunkCandidates` and
`Get-RepoMergeBase` are in `scripts/scope-lib.ps1`; `scripts/scope-check-repos.ps1` calls them
(`Get-DeclaredRepos` is now a thin caller that prints each returned warning with its own prefix, and
the inline trunk loop is one call). The messages are returned as data and each caller speaks in its own
voice. `Get-RepoMergeBase` also returns `Existing`, the candidates that exist at all, which phase 3
needs to tell "no trunk" from "this ref has no merge base"; the scope check does not use it and keeps
its single message.

**T005, after the change.** The same three suites: 157, 265 and 65 tests, **identical to the baseline,
0 failed**. `ritual-checks` has no failing member (`scope-check` is UNGRADED only because no phase
commit exists yet).

**A harness change this needed, stated plainly.** After the extraction, two inventory tests failed in
every run: `REPOS-002`, `REPOS-003` and `REPOS-004` are the three warnings for the record being
unparseable, not an array, or holding a rejected entry, and their anchors (the warning text) were no
longer in `scope-check-repos.ps1`, because the text now lives in the library. The cases themselves
passed, since the output is identical. Weakening the inventory tests, or leaving the messages behind
in the script that no longer owns them, were the wrong fixes. The harness now accepts an optional
`anchorFile` on a rule, naming the shared library file where its message lives; the rule is still graded
by running the script, and the anchor must name exactly `siteCount` non-comment lines of that file.
`tests/enforcement/Coverage.Tests.ps1` (two tests) and `rules.json` (a documented field, three rules)
changed, inside this phase's `tests/**` Territory.

**T005, the direct check, and a mistake of mine in making it.** I ran the original `Get-DeclaredRepos`
(taken verbatim from the parent commit) and the new path side by side over 21 throwaway records: no
file, empty object, unparseable, a root array, a null key, a string, a number, an object, an empty
array, one and two entries, dots and underscores, a path, a backslash, `..`, `.`, a drive, a mix of good
and bad, nulls and booleans inside the array, a duplicate, a space. **All 21 give identical returned
repositories and identical printed messages.** New `Unusable` is true exactly where a warning was
produced (unparseable, a non-array, any rejected entry) and false for an absent record, an absent or
null key, an empty array and a root array, which are the cases the original stayed silent about.

My first run of that comparison reported 11 differences, every one of them a case with a warning. They
were not real: `git show` was decoded through the console's `ibm437` code page, which turned the old
source's em dash into the mojibake `ΓÇö` before it ever ran, so the "original" side was corrupt. The
character codes (915, 199, 246) showed it, and the library string was confirmed to hold the real em
dash (U+2014). With the encoding set to UTF-8, as `scripts/enforcement-pack.ps1` does, the differences
were zero. The lesson is recorded because the same code page is why the owner's console shows `ΓÇö` in
this kit's output.
