# Cold-start prompt — taskboard install

Paste this as the first message of a **new** Claude Code session opened in
`D:\solutions\taskboard` (the governance root). It names no kit file beyond the kit's location:
whether the kit's own docs route the agent correctly is part of the test.

```text
Adopt the agentic-sdlc-kit into this existing system. The kit is at
D:\solutions\agentic-sdlc-kit-export-2d3e5bd (a clean export of main, commit 2d3e5bd). Follow the
kit's own adoption documentation for an existing system.

Project facts:
- Name: taskboard, a task/project board
- This directory is the governance repository. Two existing code repositories live inside it:
  taskboard-api (ASP.NET Core Web API on .NET 10 + EF Core + SQL Server; SQL Server LocalDB
  MSSQLLocalDB is installed; .NET SDK 10.0.400) and taskboard-web (Next.js, TypeScript, npm,
  Node 24). They are independent repositories, not submodules.
- One developer: anas.m (anas.m@dpointernational.com)

Stop when adoption is complete and the gate is proven on the untouched code, before any
feature. Ask me whenever a decision is mine; do not guess.
```

Tester notes (not part of the prompt):

- Open the session in `D:\solutions\taskboard`, not in the kit repo, and do not add
  `D:\solutions\agentic-sdlc-kit` to the session. Friction item 12 on A: the install agent knew
  it was in a field test. The export has no `field-test/` and no `docs/roadmap.md`; if the agent
  still mentions a field test, log it.
- Answer questions only after logging each one in `friction.md` (`missing-doc` if the docs
  should have answered it). Add the question to the table in `project.md` ("Questions asked
  during install", as on A).
- Do not correct the agent from kit knowledge. If it goes wrong, log it and let the kit's own
  checks (`doc-lint.ps1`, `verify-kit.ps1`) catch it, or log that they did not.
- Things to watch on B specifically: multi-repo init (`codeRepos`, nested `.gitignore` lines),
  the `AGENTS.md` clash in `taskboard-web`, a gate command that must cover both repos, whether
  the agent confuses which repository is active before committing, and principle III staying
  applicable (two code repos, unlike A).
- Check `~/.claude/CLAUDE.md` is still absent and record it in the install record.
- Design references are not given at install (the install stops before any feature). At the UI
  feature's specify step copy only `D:\solutions\taskboard-design\prototype.html` into
  `specs/NNN-name/screenshots/` and let the agent render the reference PNGs from it (see
  `project.md`, UI verification approach). Note whether it does so unprompted, cites them as the
  top source-of-truth rung, never edits the prototype, and runs the Visual Compliance Loop.
