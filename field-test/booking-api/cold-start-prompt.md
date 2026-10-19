# Cold-start prompt — booking-api install

Paste this as the first message of a **new** Claude Code session opened in
`D:\solutions\booking-api`. It is deliberately short and names no kit file beyond the kit's
location: whether the kit's own docs route the agent correctly is part of the test.

```text
Install the agentic-sdlc-kit into this empty repository. The kit is at
D:\solutions\agentic-sdlc-kit (use its main branch, commit 2d3e5bd). Follow the kit's own
adoption documentation for a new system.

Project facts:
- Name: booking-api
- A booking/reservation REST API: resources, time slots, bookings
- Stack: .NET 10 Web API + SQL Server (SQL Server LocalDB MSSQLLocalDB is installed; .NET SDK 10.0.400)
- One repository, one developer: anas.m (anas.m@dpointernational.com)

Stop when adoption is complete and the gate is proven on the empty scaffold, before any
feature. Ask me whenever a decision is mine; do not guess.
```

Tester notes (not part of the prompt):

- Answer questions only after logging each one in `friction.md` (type `missing-doc` if the
  docs should have answered it).
- Do not correct the agent from kit knowledge. If it goes wrong, log it and let the kit's
  own checks (`doc-lint.ps1`, `verify-kit.ps1`) catch it, or log that they did not.
- The session has no project memory (new path). A user-level `~/.claude/CLAUDE.md`, if any,
  still loads: note in the install record whether one exists.
