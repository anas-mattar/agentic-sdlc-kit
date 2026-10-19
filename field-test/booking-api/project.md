# Project A — booking-api

| Field | Value |
|---|---|
| Shape | Backend / API |
| Adoption path | greenfield |
| Domain | Booking / reservation: resources, time slots, bookings |
| Stack | .NET 10 Web API + SQL Server (local: SQL Server LocalDB `MSSQLLocalDB`; SDK `10.0.400`) |
| Developers | solo (anas.m) |
| Repository | `D:\solutions\booking-api`, remote `anas-mattar/booking-api`: created private (question 4), made **public** to finish adoption step 7, since GitHub Free offers no branch protection on private repos (friction) |
| Kit installed from | `2d3e5bd` (kit `main`). Its shipped surface is identical to the plan's starting point `99ebb2c`: the only changes between them are `docs/roadmap.md` (kit-internal) and `field-test/` (not shipped) |
| Installer | cold-start session (no memory, no kit context), prompt in `cold-start-prompt.md` |
| Set up | 2026-10-18 |

## Planned coverage

- Lanes: Standard, Micro.
- Integration tier (question 1): at least one feature calls an external system, planned as a
  booking confirmation email (local fake SMTP, e.g. smtp4dev in Docker), so the contract-first
  rule (constitution VII) is exercised. Without it the integration rulebook would be a tier with
  nothing behind it.
- Probe: one Lite or Standard feature declares `**Gate Certification**: ci-held`. This needs a
  CI remote (GitHub repository) before that feature starts.
- Probe: after the first round of kit fixes, update this project with `update-kit.ps1` and
  run `verify-kit.ps1`.

## Kit versions used

| Date | Kit sha | Why |
|---|---|---|
| 2026-10-18 | `2d3e5bd` | initial install |

## Install record

Adoption finished 2026-10-18: PR #1 (`chore/adopt-agentic-sdlc-kit`) merged as `8646426`
(merge `--no-ff`) on top of an empty root commit `cdac91c`.

- `verify-kit.ps1` result at install end: OK (CI `ritual-checks` on PR #1, member `verify-kit`).
- Baseline gate: `dotnet build BookingApi.slnx --warnaserror && dotnet test BookingApi.slnx --no-build`,
  exit 0, 2026-10-18, recorded in `kit-adoption.json` `gateProof` (`recordedBy: anas.m`);
  `project-gate` green in CI on both PR #1 runs.
- `ritual-checks` on PR #1: **FAIL**, `enforcement-pack` Lite-lane guards (2 `.csproj`, 96 files
  > 25). Merged as a recorded exception (question 10, PR #1 comment); friction, high.
- Branch protection on `main` (checked with the GitHub API, 2026-10-18): required checks
  `ritual-checks` and `project-gate`, strict (up to date with `main`), enforced for admins,
  force-push and deletion blocked. The kit's negative test (a PR meant to fail, merge button
  disabled; `docs/sdlc/branch-protection.md`) not yet run.
- Claim audit of the install agent's final report: protection settings, visibility, gate
  proof and the three failing findings all match the evidence; the agent corrected its own
  earlier local `RESULT OK` (graded 0 files) in the PR #1 comment. Open: the owner to confirm
  the gate proof was the owner's own run, as the agent states.
- Commit metadata is public: `anas.m@dpointernational.com` (agent commits, repo-local
  identity) and `anasmater@live.com` (the GitHub web merge commit `8646426`, from the
  owner's GitHub account email). History cannot be rewritten under the protection rules.
- User-level `~/.claude/CLAUDE.md`: none (checked 2026-10-18), so the session loads no
  instructions beyond what the install puts in the project.
- Questions the agent asked that the docs should have answered: logged in `friction.md`
  as `missing-doc`.

## Questions asked during install

| # | Question | Owner's decision by design? | Answer |
|---|---|---|---|
| 1 | Which rulebook tiers does booking-api have? (backend + database, or + integration) | yes (`adoption/greenfield.md` step 2) | backend + database + integration |
| 2 | What should the gate chain be? (build `--warnaserror` + test; + format check; plain build + test) | yes (`docs/sdlc/gate-command.md` slots) | build `--warnaserror` + test (`dotnet build BookingApi.slnx --warnaserror && dotnet test BookingApi.slnx --no-build`) |
| 3 | How much should the empty scaffold contain? (minimal API + test project, or layered projects now) | partly: answered by constitution IV, not stated in `adoption/greenfield.md` step 3 (friction, low) | minimal: API + test project (one smoke test); layering waits for feature 001's plan |
| 4 | The repo has no remote; step 7 needs `ritual-checks` as a required status check on GitHub. Create a private GitHub repo, stay local only, or use a given remote? | yes (publishing code is the owner's call) | create a private GitHub repo (`anas-mattar/booking-api`) |
| 5 | Domain invariants (constitution V, 4-8 asked): accept the 5-invariant draft, or keep only 1, 2 and 4? | yes (`adoption/greenfield.md` step 1: the owner writes the invariants pack) | accepted the agent's 5-invariant draft |
| 6 | Database rulebook conventions bundle: INT IDENTITY PKs or GUID PKs (plus the bundle's other schema standards) | yes (`adoption/greenfield.md` step 1: PK standard and audit fields are constitution slots) | INT IDENTITY PKs bundle (accepted as drafted) |
| 7 | Fills for the backend, integration and deployment slots: accept, or accept without a break-glass procedure yet | yes (rulebook and `CLAUDE.md` slots are the owner's) | accepted these fills, break-glass included |
| 8 | How to commit the adoption in an empty repo with no git identity: empty root commit + adoption branch and PR, or one bootstrap commit on `main` | partly: the choice is the owner's, but the kit gives no guidance (friction, low) | empty root commit on `main` + adoption branch `chore/adopt-agentic-sdlc-kit`, PR, merge `--no-ff`; repo-local identity `anas.m <anas.m@dpointernational.com>` |
| 9 | Principle III on a single repo: keep the numbering and stub III, or delete and renumber as `init-kit.ps1` instructs | no: the kit's own instruction is wrong (friction, med) | keep the numbering, stub III as not applicable (re-ratified if a second repository is added) |
| 10 | PR #1 fails `enforcement-pack`'s Lite-lane guards (2 `.csproj` manifests, 96 files > 25) and the kit names no lane for adoption: merge as a recorded exception, split, or bootstrap commit on `main` | no: the kit gives no lane (friction, high) | merge as a recorded exception: PR comment quoting the three findings, human review, merge `--no-ff`, then branch protection |
