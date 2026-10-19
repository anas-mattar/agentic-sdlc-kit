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
- Visual Compliance Loop: needs screenshots as references before the UI feature; the tester
  supplies them.
- Brownfield track steps: baseline audit feature (documents only), descriptive constitution,
  golden-fixture tests before touching critical logic, read-only features first.

## Kit versions used

| Date | Kit sha | Why |
|---|---|---|
| 2026-10-20 | `2d3e5bd` | initial install (clean export) |

## Install record

Not started. Filled in after the cold-start session.
