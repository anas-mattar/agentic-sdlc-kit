# Project A — booking-api

| Field | Value |
|---|---|
| Shape | Backend / API |
| Adoption path | greenfield |
| Domain | Booking / reservation: resources, time slots, bookings |
| Stack | .NET 10 Web API + SQL Server (local: SQL Server LocalDB `MSSQLLocalDB`; SDK `10.0.400`) |
| Developers | solo (anas.m) |
| Repository | `D:\solutions\booking-api` (local, `main`; no remote yet) |
| Kit installed from | `2d3e5bd` (kit `main`). Its shipped surface is identical to the plan's starting point `99ebb2c`: the only changes between them are `docs/roadmap.md` (kit-internal) and `field-test/` (not shipped) |
| Installer | cold-start session (no memory, no kit context), prompt in `cold-start-prompt.md` |
| Set up | 2026-10-18 |

## Planned coverage

- Lanes: Standard, Micro.
- Probe: one Lite or Standard feature declares `**Gate Certification**: ci-held`. This needs a
  CI remote (GitHub repository) before that feature starts.
- Probe: after the first round of kit fixes, update this project with `update-kit.ps1` and
  run `verify-kit.ps1`.

## Kit versions used

| Date | Kit sha | Why |
|---|---|---|
| 2026-10-18 | `2d3e5bd` | initial install |

## Install record

To be filled after the cold-start session finishes adoption steps 0-3:

- `verify-kit.ps1` result at install end: ____
- Baseline gate (command, exit code, date): ____
- User-level `~/.claude/CLAUDE.md`: none (checked 2026-10-18), so the session loads no
  instructions beyond what the install puts in the project.
- Questions the agent asked that the docs should have answered: logged in `friction.md`
  as `missing-doc`.
