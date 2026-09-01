# External Review — running Claude and Codex against this kit

Three rounds. Both agents get repository access and the identical brief, answer blind, then
critique each other; the third round produces the one document you work from.

Run every command from the repository root, on a branch, with a clean working tree.

## Round 1 — independent, blind

Run each in a **separate session**, and do not let either see the other's output.

```bash
# Claude Code
claude "$(cat review/round1-review-brief.md)"   # then: replace <YOUR-NAME> with claude

# Codex CLI
codex "$(cat review/round1-review-brief.md)"    # then: replace <YOUR-NAME> with codex
```

Outputs: `review/out/claude-round1.md`, `review/out/codex-round1.md`.

If a session refuses to write files, add `--full-auto` (Codex) or accept the write permission
prompt (Claude); if it still refuses, ask for the markdown in-chat and save it yourself under
the same filename — Round 2 reads files, not chat history.

## Round 2 — cross-review

Only after both Round 1 files exist. Fresh sessions again.

```bash
claude "$(cat review/round2-cross-review.md)"   # <YOUR-NAME>=claude, <OTHER-NAME>=codex
codex  "$(cat review/round2-cross-review.md)"   # <YOUR-NAME>=codex,  <OTHER-NAME>=claude
```

Outputs: `review/out/claude-round2.md`, `review/out/codex-round2.md`.

## Round 3 — merge

```bash
claude "$(cat review/round3-merge.md)"          # or codex, or a third session
```

Output: `review/out/DECISION.md` — the only file you act on.

## Why it is shaped this way

- **Blind first.** Showing model B what model A said collapses them onto one answer; the
  disagreement is the signal you are paying for.
- **Adversarial by instruction.** Both models will default to praising a tidy document system.
  The brief spends several paragraphs forbidding that, and requires a cut list and citations,
  because unenforced criticism turns into agreement.
- **Files, not chat.** Each round reads the previous round's files, so the trail is auditable
  and you can re-run one round without re-running the others.
- **The kit reviews the kit.** Round 1 asks each model to plan the work as `NNN-name` features
  in this kit's own SDLC. Where that hurts, you have found a real defect — you are the first
  user of your own framework.

## Reading the results

Weight in this order: findings both models grounded in the same `path:line` > findings one
model grounded and the other verified in Round 2 > findings one model asserted and the other
rejected > anything neither could cite. Treat the "What neither of us saw" sections as the most
valuable pages in the set: two models of the same kind reading the same documents miss the same
things, and that is where a human reader is worth more than both.

Nothing in `review/` is part of the kit's governance layer. Delete the folder before using the
kit as a template for a real project, or keep it as the record of how the framework was audited.
