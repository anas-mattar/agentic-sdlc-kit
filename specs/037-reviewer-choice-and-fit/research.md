# Research: Reviewer choice and pull-time fit

Each section records a decision the plan rests on, why, and what was weighed. Nothing here needed outside
research: every unknown was a question about the kit's own scripts and was answered by reading them.

## R1: Where a review claim lives (plan P1)

**Decision**: a remote ref `refs/heads/review/<feature>/<slug>` carrying one commit.

**Rationale**: the kit's best team property is that the remote ledger is the claim, with no assigner
(`docs/sdlc/team-workflow.md` sections 2 and 3). A feature claim is a remote branch, so a review claim is the same
kind of thing: pushed by the person taking it, readable by `git ls-remote`, owned by nobody. The ref prefix keeps
it out of every existing reader: `roadmap-claim-check.ps1`, `claim-feature.ps1` and `territory-check.ps1` all match
`refs/heads/(\d{3,}-\S+)$`, which a `review/` ref cannot satisfy.

**Alternatives considered**:

- A line in a committed file (a reviewer header in `plan.md`): the owner writes it, which is the problem.
- A file the reviewer commits to the feature branch: needs write access to the owner's branch and couples the
  claim to the branch it judges.
- A git tag: tags are not the ledger the kit reads, and a lightweight tag carries no author.
- A pull request review request: it lives in a hosting service the kit does not read (the 021 notes already say a
  pull request being open is invisible to git).

## R2: What the claim commit carries (plan P1, P9)

**Decision**: one commit whose tree is the feature tip's tree and whose parent is the feature tip; the message
names the feature and the roster name; the author is whoever pushed.

**Rationale**: a ref with no commit of its own would point at the feature tip and carry no author, so nothing could
tell the Owner pushing it from the Reviewer pushing it. An author is the only independent signal git offers. The
roster maps no name to an identity (021), so the signal is weak: it catches the owner pushing a claim for someone
else from their own identity and nothing more. That is stated, not hidden.

**Alternatives considered**: signed commits or tags (a key-management requirement no adopted project has);
adding handles to the roster (an identity mapping, which 021 deliberately did not add and which is assignment
adjacent).

## R3: Pull, not nominate, and what keeps it from becoming assignment (spec Q1)

**Decision**: the reviewer takes the review; the kit never proposes or ranks a reviewer, and a review nobody has
pulled keeps the feature unmergeable with a message that says how to claim it.

**Rationale**: the owner must not be able to pick the judge, and the kit must not pick either. Pulling is the
symmetric move to pulling a feature. The cost is that a feature can wait for a reviewer; that is true of any
review and is visible in the ledger (no `review/` ref) instead of in a chat.

**Alternatives considered**: nominee accepts (the owner still picks); a fixed rotation on the roster (the kit
picks, which is assignment authority).

## R4: Where the claim is graded (plan P4)

**Decision**: inside `Invoke-CriticalTeamEvidence`, after the 021 conditions.

**Rationale**: it is where the Reviewer is already read and graded. Grading in `roadmap-claim-check.ps1` was
rejected: that check exempts the branch being checked for its own claim and works over claims, not over a
branch's own review. Ordering after the 021 conditions keeps a stranger, the Owner and a denied reviewer named as
they are today (spec FR-005).

## R5: What an unreadable ledger is (plan P4, spec FR-004)

**Decision**: `UNGRADED` with the cause, exit unchanged, never a pass and never a silent skip.

**Rationale**: the spec says so, and it is the species GAP-027, GAP-034 and GAP-035 closed in other readers: a
read that fails must not become "no claims" (which would read as a failure for the wrong reason) or "no problem".
The reader returns a failure flag separate from the list for exactly that reason (GAP-036, feature 030).

## R6: Why `-Row` on `claim-feature.ps1` and not a new script (plan P7)

**Decision**: two optional parameters on the existing claim command.

**Rationale**: the claim is the moment the developer commits to a feature, which is when a fit note is useful, and
the command already prints advisory text. A separate pick-screen script would be a second place to remember to
run, and a new file to classify and sweep. Absent `-Row`, the script is byte-identical (FR-011).

**Alternatives considered**: extending `territory-check.ps1` (it grades overlap between claims, a different
question, and runs per phase, not at pick time); a new pick-check script (rejected above).

## R7: The roadmap column (plan P8)

**Decision**: an optional `Repos` column.

**Rationale**: at pick time the row is the only document the candidate has. `roadmap-claim-check.ps1` finds its
columns by header name, so an added column cannot move its readings. Free text in the feature cell would need a
fragile parser.

**Alternatives considered**: reading repositories from the plan's Territory (does not exist at pick time); a
separate file per feature (a coordinator-shaped artifact the owner of the row must write for others to proceed).

## R8: One roadmap reader or two (plan Risks)

**Decision**: add a small reader to the lib; leave `roadmap-claim-check.ps1`'s own parsing alone.

**Rationale**: that script's row binding (token rules, Owner column, preferring the `specs/<claim>` row) took
several review rounds in 021 and is graded against fixtures; the fit reading needs the first cell and one column.
The duplication is recorded for a later feature rather than risked here.
