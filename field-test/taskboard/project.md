# Project B — taskboard

| Field | Value |
|---|---|
| Shape | Backend + frontend, two code repositories under one governance root (multi-repo) |
| Adoption path | **brownfield** (`adoption/existing-system.md`): the seed code exists and is committed before the kit is installed |
| Domain | Task / project board: projects, tasks, status columns (Todo / InProgress / Done) |
| Stack | Backend: ASP.NET Core Web API (.NET 10, SDK `10.0.400`) + EF Core + SQL Server (LocalDB `MSSQLLocalDB`). Frontend: Next.js (App Router, TypeScript, ESLint, no Tailwind), npm, Node 24 |
| Developers | solo (anas.m) |
| Governance repo | `D:\solutions\taskboard` (1 commit, README only; the kit installs here) |
| Code repos (nested, independent, never submodules) | `D:\solutions\taskboard\taskboard-api` (`TaskBoard.slnx`; src `TaskBoard.Api`, tests `TaskBoard.Api.Tests`) and `D:\solutions\taskboard\taskboard-web` |
| Remotes | none yet; the install session asks (as on A, question 4) |
| Kit installed from | `2d3e5bd` (kit `main`), via a clean export without `field-test/` and `docs/roadmap.md`: `D:\solutions\agentic-sdlc-kit-export-2d3e5bd` |
| Installer | cold-start session, prompt in `cold-start-prompt.md` |
| Set up | 2026-10-20 |

## Seed codebase (what exists before adoption)

- `taskboard-api` (`5075c6c`): minimal API, `BoardContext` (EF Core), models `Project` and
  `TaskItem`, `Initial` migration applied to LocalDB `TaskBoardDev`, 1 unit test. Gate that was
  green when seeded: `dotnet build TaskBoard.slnx --warnaserror && dotnet test TaskBoard.slnx --no-build`.
  The first build failed twice on transitive-package vulnerabilities (NU1902/NU1903 on
  `System.Security.Cryptography.Pkcs`) and an EF version skew; both fixed by pinning 10.0.13.
- `taskboard-web` (`a863b8c`): Next.js board page (`app/page.tsx`), API client (`lib/api.ts`).
  `npm run lint` and `npm run build` green when seeded. **No tests, no formatter config.**
- Deliberate brownfield traits, left as they are: `create-next-app` shipped its own
  `AGENTS.md` and `README.md` in `taskboard-web` (the kit also ships an `AGENTS.md`); no CORS or
  auth hardening; no frontend test runner; the API port is assumed (`http://localhost:5080`,
  `NEXT_PUBLIC_API_URL`), not pinned in `launchSettings.json`; no CI anywhere.
- Seeded by the tester, not by the cold-start agent, so the code is not kit-shaped.

## Planned coverage

- Lanes: Standard (with visual refs: the board UI), Lite. Micro optional if a small feature fits.
- Multi-repo: Territory entries repo-prefixed (`taskboard-api/...`, `taskboard-web/...`),
  `kit-adoption.json` `codeRepos`, matching `NNN-name` branches in all repos,
  `scripts/scope-check-repos.ps1` on at least one cross-repo feature. **Out of scope in the plan
  until amended (see `plan.md`, amendment of 2026-10-20).**
- Cross-repo feature: one feature touches API contract and UI together (contract first,
  constitution VII).
- Visual Compliance Loop: design references exist (added 2026-10-20 after the install prompt was
  written): prototype and 4 screenshots in `D:\solutions\taskboard-design` (README there). Copy them
  into `specs/NNN-name/screenshots/` when the UI feature is specified; the tester
  supplies them (done).
- Brownfield track steps: baseline audit feature (documents only), descriptive constitution,
  golden-fixture tests before touching critical logic, read-only features first.

## UI verification approach (decided 2026-10-20)

How the UI feature proves it matches the design references. Every point is something the
feature's `plan.md` must carry; this record is not a substitute for that approval.

- **Source of truth:** the prototype and screenshots in `D:\solutions\taskboard-design`.
  The agent ports the prototype's CSS verbatim; it does not re-implement the look from the
  screenshots.
- **Visual check (the gate evidence):** Playwright screenshots of the running app at 1280 and
  500 px with the prototype's data, diffed against the reference PNGs with `pixelmatch`. The
  agent reports the diff percentage and attaches the diff image. Threshold and viewports are
  stated in the plan before implementation. The reference screenshots are 1280 px wide, plus
  500 px because headless Edge cannot render narrower.
- **Behaviour check:** Playwright tests for create project, add task, change status (task moves
  column), API error banner, empty state. Run against a **mocked API** (route interception) as
  the gate. One **full-stack smoke test** (real API + LocalDB) belongs to the cross-repo feature.
- **Claude in Chrome:** debugging aid only (find which element differs when the diff fails). It
  never declares a pass; a "looks the same" claim without the diff number is logged as
  `agent-faked` in the claim audit.
- **Backend logic:** stays in xUnit tests in `taskboard-api`; Playwright does not replace them.
- **Approvals needed in `plan.md` before implementation:** Playwright and `pixelmatch` as new
  packages (CLAUDE.md, Strict Rules); the gate command gains the web tests; Territory lists
  test paths in `taskboard-web`, and the smoke test lists both repos.
- **Known gap:** `taskboard-web` has no test runner today, so the first UI feature adds one.
  Log it as friction if the kit gives no guidance for a brownfield repo with no tests.

## Kit versions used

| Date | Kit sha | Why |
|---|---|---|
| 2026-10-20 | `2d3e5bd` | initial install (clean export) |

## Install record

Not started. Filled in after the cold-start session.
