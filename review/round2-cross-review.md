# Round 2 — Cross-Review

> Run this **only after both Round 1 files exist** in `review/out/`. Give it to each agent in
> turn. Replace `<YOUR-NAME>` with `claude` or `codex`, and `<OTHER-NAME>` with the other one.

---

You reviewed this repository independently in `review/out/<YOUR-NAME>-round1.md`. A second
model, working from the identical brief (`review/round1-review-brief.md`), produced
`review/out/<OTHER-NAME>-round1.md`.

Read both, plus `review/round1-review-brief.md`, plus whatever files you need to re-check a
disputed claim. **Do not modify any file except your single output file.**

## What this round is for

Two models given the same documents produce overlapping and conflicting findings. Overlap is
weak evidence of a real problem; conflict is where the interesting information is. Your job is
to resolve conflict with evidence, not to be diplomatic.

Rules:
- **Verify before you agree.** For every point of the other review you endorse, open the cited
  file and confirm it. Report any citation that does not hold up — a wrong citation is itself a
  finding.
- **Defend or concede explicitly.** Where the other review contradicts yours, either defend
  your position with new evidence or concede in one clear sentence. "Both perspectives have
  merit" is a non-answer; do not write it.
- **Hunt the shared blind spot.** Name at least one thing **neither** review caught. You two
  are the same kind of system reading the same documents; assume a correlated miss and go
  looking for it. Candidates worth probing: what a human developer would hate on day 4, what
  breaks under a deadline, what breaks with 5 developers instead of 1, what breaks when the
  agent's model is swapped, what a non-author reader misreads on first contact.
- **No new scope.** Do not invent a different framework. Judge and improve this one.

## Output

Write to **`review/out/<YOUR-NAME>-round2.md`**, exactly this skeleton:

```markdown
# <YOUR-NAME> — Round 2 Cross-Review of <OTHER-NAME>

## Where <OTHER-NAME> is right and I was wrong
<Concessions. Be specific about what changed your mind.>

## Where <OTHER-NAME> is wrong
| Their claim | Why it fails | Evidence (path:line) |
|---|---|---|

## Citation check
<Any citation in their review that does not support the claim made from it. "All checked
citations hold" is a valid result — say so and list what you checked.>

## What neither of us saw
<At least one. More is better.>

## Merged priority list
| Rank | Item | Severity | Both agreed? | Rationale |
|---|---|---|---|---|
<Top 10 maximum, ordered by what the author should do first.>

## Merged build plan delta
<How the combined critique changes the v1 feature list from your Round 1: what moves, what is
added, what is dropped. Still capped at 7 features.>

## Remaining disagreement
<Anything genuinely unresolved after this round, stated as a decision the human author must
make, with the choice each of you would take and the cost of each.>
```

Do not write any other file. Do not commit.
