---

description: "Task list for feature 018 — cross-repo territory reach"
---

# Tasks: Cross-repo Territory Reach

**Input**: `specs/018-cross-repo-territory-reach/spec.md`, `plan.md` (decisions D1–D8), `research.md`
(R1–R10), `data-model.md`, `contracts/territory-check-output.md`
**Prerequisites**: spec.md and plan.md approved; no new dependency. Phase 3 additionally needs the
owner's decision on plan D5 (a present but unusable `codeRepos`), because it tightens two sentences of
the spec (T016 checks it before any code is written).

**Tests**: every rule ships with a passing and a failing harness fixture in the same phase as the
behaviour, expectations written by hand (spec FR-015; feature 015). New fixtures are run against the
parent commit before the code changes and must fail there, so each is shown to measure something.
Phase evidence goes in `notes.md`, never here.

**Organization**: four phases, each independently revertible. Phase 4 must be reverted before phase 3.
The full harness is run on an isolated checkout of the final commit, never in a working directory
someone is using.

---

## Phase 1: The two shared readers, with no change in behaviour (FR-003, FR-005)

**Purpose**: extract `Get-CodeRepos` and `Get-RepoMergeBase` from the scope check so the territory check
can share them. Nothing observable changes; the existing suites are the proof.

**Territory**:

- `scripts/adoption-lib.ps1`
- `scripts/scope-lib.ps1`
- `scripts/scope-check-repos.ps1`
- `tests/**`

- [ ] T001 Record the baseline on the parent commit in `notes.md`: the counts from
      `pwsh -File tests/enforcement/Run-Tests.ps1 -Case REPOS-`, `-Case SCOPE-` and `-Case TERR-`, so "no
      behaviour change" is measured against a number and not asserted.
- [ ] T002 Add `Get-CodeRepos` to `scripts/adoption-lib.ps1` returning `Repos`, `Warnings` and
      `Unusable` (data-model.md). It reads exactly what `Get-DeclaredRepos` in
      `scripts/scope-check-repos.ps1` reads and applies exactly its validation (a plain directory name,
      no path, no traversal, no drive; an absent record, an empty array and an absent key are silent;
      unparseable JSON, a non-array and a rejected entry each produce the warning text the scope check
      prints today, without its prefix). `Unusable` is true whenever the declaration was present and
      could not be read in full. Update the file's header, which names only the developer and surface
      readers.
- [ ] T003 [P] Add `Get-RepoMergeBase` to `scripts/scope-lib.ps1`: for a repository path and a ref, the
      merge base with the first trunk candidate that exists and shares a history with it, returning the
      base, the trunk used and the candidates tried. The candidate order is the scope check's
      (`origin/main`, `main`, `origin/master`, `master`, `origin/HEAD`), overridable by the caller (the
      scope check's `-BaseRef`). Keep a separate way to ask "does any candidate exist at all", because
      the territory check must tell "no trunk" from "this ref has no merge base" (research R3).
- [ ] T004 Edit `scripts/scope-check-repos.ps1` to call both: `Get-DeclaredRepos` becomes a thin caller of
      `Get-CodeRepos` that prints each warning with its own prefix, and the inline trunk loop becomes a
      call to `Get-RepoMergeBase`. Every message it prints stays byte-identical.
- [ ] T005 Re-run `-Case REPOS-`, `-Case SCOPE-`, `-Case TERR-` and `pwsh -File scripts/ritual-checks.ps1`.
      The counts equal T001's and nothing is red. Also call `Get-CodeRepos` directly on throwaway
      records (no file, unparseable, a string, an object, `[]`, a path entry, a traversal entry, a drive
      entry, a mix of good and bad entries) and record what it returns in `notes.md`.

---

## Phase 2: The ungraded verdict, applied to the comparison the check already skips (US2, governance half)

**Purpose**: `UNGRADED` becomes a result of `scripts/territory-check.ps1`, so the reach built in phase 3
sits on a check that already tells the truth. This is the governance half of GAP-029 the spec decided to
take; the four terminating-write refusal paths are not touched.

**Territory**:

- `scripts/territory-check.ps1`
- `tests/**`

- [ ] T006 [P] [US2] Write the fixtures for `TERR-013` under
      `tests/enforcement/cases/territory-check/TERR-013/`: `fail` (an open claim with no remote-tracking
      ref, the `originFetch` shape `TERR-012` uses, and no overlap: the verdict is UNGRADED, exit 0,
      and the line names the governance repository and the feature); `pass` (every claim compared, no
      overlap: `CLEAN`, text unchanged); `fail-overlap` (an overlap and a skipped claim together: exit 2,
      the overlap block and the ungraded line both printed); `fail-json` and `pass-json` (the `-Json`
      form: `CLEAN` false and `UNGRADED` listing the entry, against `CLEAN` true and `UNGRADED` empty).
      Expectations are hand-written from the contract.
- [ ] T007 [US2] Run T006 against the current script and record in `notes.md`: the `fail*` cases must
      fail today (the script prints `CLEAN` over the skipped claim), `pass` must already pass.
- [ ] T008 [US2] In `scripts/territory-check.ps1`, add an ungraded accumulator. The comparison it already
      skips with `Write-Warning` also adds an entry (`governance`, the feature, cause `claim-skipped`),
      and the warning stays. Compose the verdict as plan D2: an overlap keeps exit 2 and the ungraded
      lines are printed beside it; otherwise any entry makes the run `UNGRADED` and exit 0; otherwise
      `CLEAN` with its existing text. `-Json` keeps `BRANCH`, `CLEAN` and `OVERLAPS`, makes `CLEAN` false
      whenever anything was not compared, and gains `UNGRADED`. The `no remote` state is untouched.
- [ ] T009 [US2] Update the `TERR-012` expectation: the run now ends on the ungraded verdict where it
      ended on `CLEAN`, and the case's `rules.json` summary and notes say why. This is a changed
      expectation, and it is recorded in `notes.md` as the departure it is, with the old text.
- [ ] T010 [US2] Register the new line shapes as accumulator patterns in
      `tests/enforcement/emission-idioms.json` for this script, and add `TERR-013` (and the changed
      `TERR-012`) to `tests/enforcement/rules.json` with summary, law, emit anchor and notes.
- [ ] T011 [US2] Run `-Case TERR-` and `pwsh -File scripts/ritual-checks.ps1`: every case passes and the
      coverage test reports no rule without both directions.

---

## Phase 3: The reach — code repositories read as sibling working trees (US1, US2 code half, US3)

**Purpose**: the feature itself. Each declared code repository is compared for the branch under check and
every open claim; overlap is reported with repository-prefixed paths; every cause of a comparison not
made is named.

**Territory**:

- `scripts/territory-check.ps1`
- `tests/**`

- [ ] T012 [P] [US1] Write the fixtures for `TERR-014` (the overlap itself) under
      `tests/enforcement/cases/territory-check/TERR-014/`, using nested independent repositories with
      `origin: self`: `fail` (two features commit the same file in one code repository while their
      governance branches look disjoint: exit 2, the file listed as `<repo>/<path>`); `pass` (different
      files: `CLEAN`, and the line names the repository compared and the number of open claims);
      `fail-two-repos` (an overlap in each of two repositories); `pass-same-path-two-repos` (the same
      relative path in two repositories is not an overlap); `fail-rename` (a rename counts at both
      paths); `fail-own-uncommitted` (the branch under check has a tracked uncommitted change in a
      repository checked out on it); `pass-uncommitted-other-branch` (the repository is checked out on a
      different branch with uncommitted edits: not attributed to this feature); `pass-stale` (the other
      claim is past the stale window: reported reclaimable, exit 0); `fail-code-only-liveness` (the other
      feature has no governance commits but live code commits: a live overlap, not "claimed, no work").
- [ ] T013 [P] [US2] Write the fixtures for the causes, one rule each with a `pass` (the cause absent,
      `CLEAN`) and a `fail` (the cause present, UNGRADED naming repository and cause, exit 0, no `CLEAN`
      anywhere in the output): `TERR-015` repository not present; `TERR-016` present but not a
      repository of its own; `TERR-017` no resolvable trunk (the candidates named); `TERR-018` fetch
      failed; `TERR-019` another feature's branch cannot be compared; `TERR-020` a present but unusable
      `codeRepos`; `TERR-021` a code repository with no `origin`, compared against local branches only
      and saying so. Add to `TERR-014`'s family a `fail-overlap-and-ungraded` (an overlap found while one
      repository was not compared: exit 2, both printed).
- [ ] T014 [P] [US3] Write the fixtures that pin "no change" under `TERR-022`: `pass` (no `codeRepos` in
      the record: the original `CLEAN` text, byte for byte); `pass-empty` (`"codeRepos": []`: the same);
      `fail` (a declared repository that is compared: the new text appears). Every pre-existing `TERR-*`
      case, unmodified except `TERR-012`, is the larger guard.
- [ ] T015 Run T012–T014 against the phase 2 tip and record in `notes.md`: the `fail*` cases must fail
      (the script does not read code repositories), the `pass*` and no-change cases must already pass.
- [ ] T016 Before any code: confirm the owner has decided plan D5. If the amendment to spec FR-013 and US3
      scenario 2 is not approved, stop and ask; do not implement either reading by default.
- [ ] T017 In `scripts/territory-check.ps1`, dot-source `scripts/adoption-lib.ps1` and
      `scripts/scope-lib.ps1`, read the declaration with `Get-CodeRepos`, print its warnings in the scope
      check's own words, and make an unusable declaration an ungraded entry (`declaration-unusable`).
      With no usable repositories the code path is skipped entirely, so the existing output is
      unchanged.
- [ ] T018 [US2] Per declared repository, in order, each failure an ungraded entry naming the repository
      and the cause: the directory exists (`not-present`); it is the root of a repository of its own
      (`not-a-repository`, the check `scripts/scope-check-repos.ps1` uses); if it has an `origin`, fetch
      it (`fetch-failed`), and if it has none, note "compared against local branches only"; a trunk
      resolves through `Get-RepoMergeBase` (`no-trunk`, the candidates named).
- [ ] T019 [US1] Compute touched sets in each repository for the branch under check and for every open
      claim from the governance ledger: the ref is `origin/<branch>` falling back to a local head; no ref
      means no work there; a ref whose merge base or diff cannot be had is ungraded
      (`branch-uncomparable`, the feature and repository named). Reads use `core.quotepath=off`, renames
      count at both paths, and tracked uncommitted changes count only when the repository's current
      branch is the branch under check (research R7). The existing governance read is left exactly as it
      is.
- [ ] T020 [US1] Judge each claim's status from its latest commit in any repository it has a branch in
      (research R4), assemble each overlap with governance paths as today and code paths prefixed by the
      repository directory name, and fold the code repositories into the existing per-claim loop so a
      claim is reported once.
- [ ] T021 [US1] [US2] Print per the contract: the new `UNGRADED:` lines and the verdict line; a `CLEAN`
      line that names the repositories compared and the open claims in a project that declares code
      repositories (and the unchanged line in one that does not); `-Json` with prefixed `files`, `CLEAN`
      false when anything was not compared, and the `UNGRADED` list. Exit codes as plan D2.
- [ ] T022 Register the new line shapes in `tests/enforcement/emission-idioms.json` and add `TERR-014`
      through `TERR-022` to `tests/enforcement/rules.json`, then run `-Case TERR-`, `-Case REPOS-` and
      `pwsh -File scripts/ritual-checks.ps1`. Everything passes, the coverage test reports no rule
      without both directions (SC-006), and every pre-existing case is unchanged except `TERR-012`.
- [ ] T023 Build one throwaway nested layout by hand outside the harness, following `quickstart.md`
      (two features, one code repository, a shared file), and run the script end to end, then remove the
      repository, rename it, and break its remote in turn. Record what each run printed in `notes.md`.

---

## Phase 4: Guidance, flow-down and bookkeeping

**Purpose**: tell owners what the check now reads and what `UNGRADED` means, tell adopters what flows
down, prove no adopted project's verdict moves except where it was reporting `CLEAN` over a skip, and
close the roadmap row. No script changes.

**Territory**:

- `docs/sdlc/team-workflow.md`
- `adoption/updating.md`
- `docs/roadmap.md`
- `docs/digests/**`
- `kit-manifest.json`

- [ ] T024 [P] [US4] Update `docs/sdlc/team-workflow.md` section 5: the check also reads the declared code
      repositories; what an overlap there looks like (paths prefixed with the repository); what each
      ungraded cause means and the action for it; that a malformed `codeRepos` is ungraded; that it sees
      pushed work only. Keep the digest marker for the section, within 120 characters.
- [ ] T025 [P] Add a flow-down note to `adoption/updating.md`: which files flow down (the territory check,
      the two libraries, the scope check, the team-workflow document), that nothing surgical changes,
      what an owner will see change (`UNGRADED` where `CLEAN` used to cover a skipped comparison, the
      JSON `CLEAN` field, the `TERR-012` shape), and the measurement.
- [ ] T026 Measure on clones of the three adopted projects, never touching the real ones: dry-run
      `scripts/update-kit.ps1`, apply the files it names, run the old and the new `territory-check.ps1`
      on a feature branch of each (and, where a project declares code repositories, against those), and
      compare verdicts and exit codes; run `ritual-checks.ps1` before and after, and regenerate the
      digests. A verdict that moved is a finding to report, not to round. Record the table in
      `notes.md`.
- [ ] T027 Regenerate the digests (`pwsh -File scripts/build-digests.ps1`). Flip the roadmap row for
      GAP-018 to `shipped` with its spec link unbracketed, add a status sentence to the GAP-029 row (the
      governance half closed; the four terminating-write refusal paths still open), and add the
      decisions-log entry, stating what stays open by decision.
- [ ] T028 Run `pwsh -File scripts/ritual-checks.ps1`, and the full
      `pwsh -File tests/enforcement/Run-Tests.ps1` on an isolated checkout of the final commit. Every
      member OK. Then stop and ask the owner to run the gate.

---

## Dependencies & Execution Order

- Phase 1 first; it changes no behaviour and must be green before anything depends on it.
- Phase 2 needs phase 1 only for the shared files it does not use; it can be reviewed on its own.
- Phase 3 needs phase 2's verdict machinery and phase 1's readers, and needs the owner's answer on D5
  (T016) before any code.
- Phase 4 needs phases 1–3.
- Within a phase, fixtures are written and shown failing before the behaviour lands. `[P]` tasks touch
  different files.

## Implementation Strategy

MVP is phases 1–3: the readers, the honest verdict, and the reach. Phase 2 is worth shipping even on its
own, because it closes a fail-open the check already has. Stop after each phase for the owner's gate; one
phase at a time, never ahead.
