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
  written): prototype and 4 screenshots in `D:\solutions\taskboard-design` (README there). The tester
  copies `prototype.html` into `specs/NNN-name/screenshots/` when the UI feature is specified and
  the agent renders the PNGs from it (see "UI verification approach").
- Brownfield track steps: baseline audit feature (documents only), descriptive constitution,
  golden-fixture tests before touching critical logic, read-only features first.

## UI verification approach (decided 2026-10-20, revised the same day)

How the UI feature proves it matches the design. Revised after reading the kit's Visual
Compliance Loop (`docs/sdlc/review-process.md`), which says to compare structure and
specification against the Visual Inventory, "not pixels", and that pixel-diff tooling does not
apply. The first version of this section made a pixel diff the gate; that contradicted the kit.
Every point below is something the feature's `plan.md` must carry; this record is not a
substitute for that approval.

- **Source of truth:** `D:\solutions\taskboard-design\prototype.html`, owned by the tester. One
  file renders every state: `#board` (default), `#empty`, `#error`, at 1280 and 500 px. The agent
  never edits it; a change is an approved amendment recorded with the tester as approver.
- **Hand-over at the UI feature's specify step:** the tester copies only `prototype.html` into
  `specs/NNN-name/screenshots/`. When the agent writes `spec.md` for a feature with UI, it
  **renders the reference PNGs from the prototype** (one per state and viewport, same folder),
  then writes the Visual Inventory from them. The kit allows this: constitution II rung 1 reads
  "screenshots / prototype captures". Headless Edge can hang after writing a screenshot, so the
  capture needs a timeout. The four PNGs already in `taskboard-design/screenshots/` are what a
  correct render looks like (byte-identical to renders from the current prototype).
- **Gate evidence (kit as written):** at the end of each UI phase the agent captures the
  implemented screens at the same viewports, compares against the Visual Inventory item by item,
  keeps the deviation table until it is empty or user-approved, and attaches the table and both
  screenshots to the phase notes. The agent ports the prototype's CSS verbatim.
- **Pixel diff (tester addition, not the gate):** if the tester wants an exact-match number,
  run `pixelmatch` over the same captures as a non-gating extra and label it a tester addition.
  Its packages need approval in `plan.md`. The tension (owner wants an exact match, the kit rules
  pixel diff out) is logged in `friction.md`.
- **Behaviour check:** Playwright tests for create project, add task, change status (task moves
  column), API error banner, empty state, run against a **mocked API** as the gate; one
  **full-stack smoke test** (real API + LocalDB) belongs to the cross-repo feature.
- **Claude in Chrome / Playwright as the camera:** either can capture; neither declares a pass.
  A "looks the same" claim with no deviation table is logged as `agent-faked` in the claim audit.
- **Backend logic:** stays in xUnit tests in `taskboard-api`; Playwright does not replace them.
- **Approvals needed in `plan.md` before implementation:** Playwright (and `pixelmatch` if used)
  as new packages (CLAUDE.md, Strict Rules); the gate command gains the web tests; Territory
  lists test paths in `taskboard-web`, and the smoke test lists both repos.
- **Watch:** does the agent render the references itself without being told, cite them as
  rung 1, edit the prototype (it must not), and run the loop unprompted? The kit does not
  mention HTML prototypes; if the agent asks how to treat the file, log `missing-doc`.
- **Known gap:** `taskboard-web` has no test runner today, so the first UI feature adds one.
  Log it as friction if the kit gives no guidance for a brownfield repo with no tests.

## Kit versions used

| Date | Kit sha | Why |
|---|---|---|
| 2026-10-20 | `2d3e5bd` | initial install (clean export) |

## Install record

Not started. Filled in after the cold-start session.

## Questions asked during install (attempt 3: clean prompt-only run)

Attempts 1 and 2 are void (tester notes leaked; see `friction.md`).

| # | Question | Owner's decision by design? | Answer |
|---|---|---|---|
| 1 | Constitution rungs 1-2 of the source-of-truth ladder: does taskboard have, or will it have, per-feature screenshots and/or a project-wide UI guidelines doc? (Both / screenshots only / neither) | yes (constitution II slot, `adoption/existing-system.md`) | screenshots, no guidelines: keep rung 1, delete rung 2 (the design references exist in `D:\solutions\taskboard-design`, handed over at the UI feature; no UI guidelines doc exists) |
| 2 | Domain-invariants pack (constitution V): accept the agent's six-invariant draft (status set, new task starts Todo, task belongs to existing project, cascade delete, required + max lengths, no state machine), or edit | yes (`adoption/existing-system.md` step 2: the owner approves the descriptive pack) | accept with edits. The tester checked the draft against the seed code first: (4) cascade is in the database only (no API delete endpoint); (5) max lengths are enforced only by the database columns, the API checks "required" only; (1) the API probably accepts enum values outside the three (not run). Edits ask the agent to describe these gaps as current behaviour without fixing them. Good catch by the agent: the draft read the code, but stated three guarantees more strongly than the code enforces them |
| 3 | Step 7b (per-repo scope-check workflow) needs a GitHub owner/name and no repo has a GitHub remote: defer and record it, or add it with a placeholder | yes (publishing the repos is the owner call) | defer: machine scope checks run locally with `scripts/scope-check-repos.ps1` until the repos have GitHub remotes (friction, missing-doc low). Wiring is done before the first feature merges, or the deviation is kept on record |
| 2b | Follow-up: "Accept, but edit" arrived with no edit text (the tester selected the option without typing in the free-text field). Agent offered: no edits, or drop item 6 | yes | tester resends the edits as free text and keeps item 6: in a descriptive pack, "no state machine" is a fact worth recording (it stops a later agent from adding transitions). Tester-side interface slip, not a kit issue; the agent asked rather than guessing, correct behaviour |
| 4 | `deployment-standards.md` break-glass slots (conditions, approver, revert window): accept the proposed values (production outage AND no gate-passing fix within 4 hours; anas.m; 48 h), or mark not applicable since nothing is deployed | yes (deployment slots are the owner's) | mark not applicable: no production deployment exists, break-glass unavailable until deployment-standards is expanded through a feature; approver anas.m. Contrast with A (Q7), which accepted break-glass: B is brownfield with nothing deployed, and an invented procedure would be aspirational (`adoption/existing-system.md` step 2) |
| 5 | Brownfield track step 1 calls the baseline audit (inventory, gate proof, as-is handover doc) the first "feature"; the prompt said stop before any feature. Do the handover doc and inventory as part of adoption (agent's recommendation), or as feature 001 afterwards | yes | feature 001, later: adoption covers governance and the gate proof only. Against the agent's recommendation. Reasons: the kit's own wording ("first feature"), the prompt, and A's friction (high): adoption has no lane, so a docs-only change outside a numbered feature fails `enforcement-pack`; feature 001 uses a real lane (Lite expected) and yields the first metrics row |
| 6 | How to commit the adoption: `docs/` branches in the governance repo (`docs/adopt-sdlc-kit`) and in taskboard-web (`docs/governance-pointer`, the AGENTS.md pointer), unmerged and unpushed, or leave everything uncommitted for the owner | yes (commit shape is the owner's) | branches, unmerged, unpushed (agent's recommendation). The agent calls it the "Lite lane"; watch whether `ritual-checks`/`enforcement-pack` fails on the adoption branch as on A (friction, high: no adoption lane). Tester checks `git log` in each of the three repos for commits landing in the right one |
| 7 | Should `kit-adoption.json` declare `criticalSurfaces` (path globs that force Critical delivery or an approved exception)? None, or migrations + data folders of taskboard-api | yes | none for now (agent's recommendation): the plan covers Critical only if a project warrants it, and forcing it on schema work would inflate the overhead measurement behind the 40 % runner threshold. Doctor expected to report the floor as "not armed" and OK; check that `verify-kit.ps1` agrees |
