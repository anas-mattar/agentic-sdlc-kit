# Review Process

## After Each Phase

1. User runs the gate command (`docs/sdlc/gate-command.md`).
2. User checks:

```bash
git diff --stat
```

3. Fix only current phase issues.
4. Revert unrelated changes.
5. Commit successful phase.
6. Do not start next phase without approval.

## AI Review

Complete `specs/_templates/ai-code-review-template.md`. Check:

- Spec match
- Visual-reference match (where visual references exist)
- Backend rules
- Frontend rules
- Security
- Tests
- Migrations
- Unrelated changes
- Rollback safety

## Human Review

AI review alone is insufficient. **Human review is required before merge**, and a
change MUST NOT be merged until a human reviewer approves it (constitution XII).

Human reviewer checks (record in `specs/_templates/human-pr-review-template.md`):

- Actual UI vs visual references
- Business behavior
- Domain correctness (business-critical calculations against `{{DOMAIN_INVARIANTS_PATH}}`)
- Security implications
- Architectural compliance
- Code diff
- Gate result
- No unrelated changes

## Merge

Merge only after the human reviewer approves. See the consolidated gates in
`docs/sdlc/definition-of-done.md`.
