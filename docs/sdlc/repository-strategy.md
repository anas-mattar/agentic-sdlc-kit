# Repository Strategy

## Rule

Every deployable project has its own repository. Do not mix tiers in one repository unless
explicitly approved in `plan.md`. *(Single-repo projects: delete this file's multi-repo
sections and constitution principle III, and keep everything in one repository — the rest of
the kit works unchanged.)*

Required repositories:

```text
{{BACKEND_REPO}}     # Backend repository
{{FRONTEND_REPO}}    # Frontend repository
```

Optional shared documentation/spec repository, when specs and governance need a home that is
neither tier:

```text
{{SPECS_REPO}}       # Optional shared specs/documentation repository
```

## {{BACKEND_REPO}}

Contains:

- {{BACKEND_STACK_ITEMS}} <!-- e.g. ASP.NET Core Web API, EF Core, SQL Server migrations -->
- Backend tests
- Database migrations

Does not contain:

- Frontend source code
- UI assets
- Frontend build tooling

## {{FRONTEND_REPO}}

Contains:

- {{FRONTEND_STACK_ITEMS}} <!-- e.g. Next.js App Router, TypeScript, tRPC client -->
- Frontend tests

Does not contain:

- Backend source code
- Database migrations
- Server-side secrets

## {{SPECS_REPO}} (optional)

Contains:

- The constitution, `CLAUDE.md`, `docs/`, and `specs/` feature trail
- No runnable source code

Use it when backend and frontend teams need one canonical place for governance; otherwise keep
specs in the primary repository.

## Cross-Repository Feature Rule

When a feature spans repositories:

1. Create matching branches (same `NNN-<name>`) in each affected repository.
2. Define the API contract in the feature's `contracts/` **before** frontend implementation.
3. Implement and gate the backend phase first.
4. Merge the backend after its gate passes and human review approves.
5. Merge the frontend after the contract is stable (or was mocked against the agreed contract),
   its own gate passes, and human review approves.

Always confirm which repository is active before changing files.
