# Round 3 — Merge into one decision document

> Run this once, in whichever agent you trust more as an editor (or hand it to a third
> session). It reads all four Round 1/2 files and produces the only document you will actually
> work from.

---

Read every file in `review/out/` (both Round 1 reviews and both Round 2 cross-reviews), plus
the briefs in `review/`. Re-check any finding you intend to rank as BLOCKER against the actual
repository files — a merge that propagates an unverified claim is worse than no merge.

You are not summarising. You are producing the author's decision document: the single artifact
that says what is true, what to do, in what order, and what has been rejected so it stops
coming back.

Rules:
- Drop anything neither review could ground in a file, unless you can ground it yourself now.
- Where the two models disagreed and Round 2 did not resolve it, do **not** average them.
  Present it as an open decision with the two options, their costs, and your recommendation.
- Deduplicate hard. If both models said the same thing five ways, it is one row.
- The plan must be executable by one person with limited evenings. Seven features maximum for
  v1, and each one must have an acceptance criterion someone could check without your help.

## Output

Write to **`review/out/DECISION.md`**:

```markdown
# Agentic SDLC Kit — External Review Decision Document
*Sources: review/out/*.md — Round 1 (independent) and Round 2 (cross-review), <date>*

## The three things that matter
<The findings that should change what the author does this week. No more than three.>

## Confirmed findings
| # | Severity | Finding | Evidence | Agreed by | Action |
|---|---|---|---|---|---|

## Rejected findings
<Raised in review, deliberately not acted on, with the reason. This section prevents relitigation.>

## Open decisions for the author
| Decision | Option A (cost) | Option B (cost) | Recommendation |
|---|---|---|---|

## v1 plan — max 7 features
| NNN | Feature | Goal | Phases | Acceptance criterion | Effort | Cost of skipping |
|---|---|---|---|---|---|---|

## v1.1 and beyond
## Explicitly out of scope, permanently
## Kill criterion
<What would have to be true to stop working on this kit.>
```

Do not write any other file. Do not commit.
