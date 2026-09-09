# Tasks: Cross-Repo Scope-Check Reach

**Input**: Design documents from `/specs/012-cross-repo-scope-check/`
**Prerequisites**: plan.md, spec.md, research.md, contracts/

**Tests**: the grader is business-critical governance logic (constitution VIII) — a wrong PASS
silently disables gate 4 for every multi-repo adopter. Deterministic validation is the seeded
C1–C11 contract scenarios on throwaway fixture repositories, plus behavior preservation of the
existing check after the library extraction. No test framework (kit convention).

**Organization**: one delivery phase per plan-table row. **Gate Batching: phases 1-3** and
**Gate Certification: ci-held** (both declared in plan.md). Phase commits carry `phase N`
subjects; Territory per phase (006 law).

## Phase 1: The grader (US1 + US2, P1) 🎯 MVP

**Goal**: extract the shared semantics, add the cross-repo grader, wire it into the wrapper as
an inert-by-default member. Contract-validated on fixtures before any project declares
`codeRepos`.

**Independent Test**: contract C1–C11 on seeded fixture repositories; `ritual-checks.ps1` in
this kit repository reports `scope-repos n/a` and stays green; the 006 contract scenarios
re-run against `scope-check.ps1` with identical verdicts.

**Territory**:

- `scripts/scope-lib.ps1`
- `scripts/scope-check.ps1`
- `scripts/scope-check-repos.ps1`
- `scripts/ritual-checks.ps1`

- [ ] T001 Write `contracts/scope-check-repos-cli.md`: CLI surface (`-Root`, `-Branch`,
      `-Commit`, `-All`, `-Repo`), the verdict-to-exit-code table (PASS / not-applicable /
      WARN → 0; FAIL → 1), one line per C1–C11 scenario, and the exact FAIL message shapes
      (stray path named + remediation, per FR-010)
- [ ] T002 Create `scripts/scope-lib.ps1`: move `Get-VisibleLines`, `Test-IsMicro`,
      `Get-Territory`, `Test-InTerritory`, `Get-CommitPaths` out of `scope-check.ps1`
      unchanged (D6); no behavior edits in this task
- [ ] T003 Modify `scripts/scope-check.ps1` to dot-source `scripts/scope-lib.ps1` (path
      resolved from `$PSScriptRoot` so `-Root` portability is unaffected); verify the 006
      contract verdicts are byte-identical to before
- [ ] T004 Create `scripts/scope-check-repos.ps1`: read `codeRepos` from `kit-adoption.json`
      (D2); per repository resolve the matching `NNN-name` branch, collect its phase commits,
      prefix touched paths with the repository directory name (D3), resolve the declaration
      as of each code commit's committer date via `git rev-list -1 --before=` on the
      governance ref (D4), then grade with the shared helpers; Micro lane reads `spec.md`
      (FR-003); one verdict block per repository; overall exit 1 iff any repository FAILs
- [ ] T005 Handle the not-applicable and warning cases explicitly (C3–C6, C9–C11): no matching
      branch, absent directory, non-git directory, no `phase N` token, no declaration as of
      the commit, territory prefix naming an undeclared repository, detached HEAD without
      `-Branch` — each with its reason in the output, never a crash
- [ ] T006 Wire the `scope-repos` member into `scripts/ritual-checks.ps1`, reporting `n/a`
      (exit 0) when no `codeRepos` are declared or none of the declared trees is present —
      the kit repo, single-repo adoptions, and governance CI (FR-006, SC-004)
- [ ] T007 Run C1–C11 on seeded fixture repositories in the scratchpad; record each verdict in
      `contracts/scope-check-repos-cli.md`

## Phase 2: The record and the doctor (US3 support)

**Goal**: `codeRepos` becomes a first-class, validated part of the adoption record, written at
init and audited by the doctor.

**Independent Test**: `init-kit.ps1 -Topology multi` writes the field; `verify-kit.ps1` accepts
a valid record, FAILs a malformed one (non-array, nested path, absolute path), and WARNs a
`multi` adoption that declares none; a `single` adoption is untouched.

**Territory**:

- `scripts/init-kit.ps1`
- `scripts/verify-kit.ps1`
- `adoption/updating.md`

- [ ] T008 Modify `scripts/init-kit.ps1`: for `multi` topology write
      `"codeRepos": [<backend repo>, <frontend/app repo>]` into `kit-adoption.json`; `single`
      topology writes nothing (field stays optional)
- [ ] T009 Modify `scripts/verify-kit.ps1` dimension 4: validate `codeRepos` shape when present
      (array of single-segment names, no `..`, no drive/absolute paths) → FAIL on violation;
      WARN when `topology` is `multi` and the field is absent or empty, with the remediation
      naming the field (FR-008)
- [ ] T010 Modify `adoption/updating.md`: document the field in the record shape, and give
      existing multi-repo adopters the one-line manual addition (no automated migration —
      spec Assumptions)

## Phase 3: The law and the CI reach (US1 + US3, remainder)

**Goal**: state the multi-repo territory rule where territory is defined, name the new member
everywhere the member set is enumerated, and ship the code-repository CI template.

**Independent Test**: `doc-lint.ps1` and the `digests` check green; every enumeration of the
ritual-checks member set names `scope-repos`; the template is valid YAML and its slots are
listed in the adoption docs.

**Territory**:

- `.github/workflows/code-repo-scope-check.yml.template`
- `kit-manifest.json`
- `docs/sdlc/repository-strategy.md`
- `docs/sdlc/definition-of-done.md`
- `docs/sdlc/review-process.md`
- `docs/sdlc/flow.md`
- `CLAUDE.md`
- `adoption/greenfield.md`
- `docs/digests/`

- [ ] T011 Create `.github/workflows/code-repo-scope-check.yml.template`: checks out the code
      repository and the governance repository as a sibling, installs pwsh, runs
      `scope-check-repos.ps1 -Repo <this repo> -Branch <ref> -All`; slots for the governance
      repository and the token secret; header comment naming both (D5)
- [ ] T012 Modify `kit-manifest.json`: surgical entry for the new template, placed before the
      `.github/**` verbatim glob, with the same reason shape as `project-gate.yml.template`
- [ ] T013 Modify `docs/sdlc/repository-strategy.md`: new "Territory across repositories"
      section — repo-prefixed entries (D3), the matching-branch requirement, the check's name,
      and a digest marker
- [ ] T014 [P] Modify `docs/sdlc/definition-of-done.md` (gate 4 names both checks),
      `docs/sdlc/review-process.md` (verdict sources), `docs/sdlc/flow.md` (member set) —
      the three places 011's flow-down found stale enumerations
- [ ] T015 [P] Modify `CLAUDE.md`: workflow step 7 and the "Reviewing / finishing a phase"
      reading row name `scope-repos`; the Repositories section points at the new
      repository-strategy section
- [ ] T016 [P] Modify `adoption/greenfield.md` step 7: multi-repo adopters install the template
      and declare `codeRepos`
- [ ] T017 Regenerate digests (`pwsh -File scripts/build-digests.ps1`) — never hand-edited —
      and confirm `ritual-checks.ps1` green
