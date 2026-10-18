# Notes: Reviewer choice and pull-time fit

Evidence for the phases, in order. Decisions are in `plan.md`; this file records what was measured.

## Phase 1: the claim and its reader (T001 to T008)

**Baseline on the parent commit (T001).** 906 case directories on `b6b39d4`. A full harness run on an isolated worktree
was started and then stopped unfinished (462 cases reached, none failing, the machine shared with the owner's own run), so
the parent's full pass count is **not recorded**; the owner's gate on the phase 1 working tree is the full-harness evidence
(below). The byte comparison of T001's saved states for `roadmap-claim-check.ps1`, `claim-feature.ps1` and
`territory-check.ps1` was done by the existing cases of those scripts passing unchanged, plus one new control variant for
each (below); no script other than `adoption-lib.ps1` (appended to, nothing existing edited) was touched.

**Probes (T002, T003).**

- A ref `review/007-pay/grace` on a bare origin is listed by `git ls-remote --heads origin 'refs/heads/review/007-pay/*'`
  and not matched by `refs/heads/(\d{3,}-\S+)$`, the pattern all three existing ledger readers use.
- A commit built with `git commit-tree <feature tree> -p <feature tip>` pushes to that ref and reads back its author name and
  email (`%an`, `%ae`).
- Slug: `git check-ref-format` rejects a space, a leading `.`, a trailing `.`, `..` and `.lock` and accepts the rest; the
  slug rule (trim, lower-case, other characters to `-`, collapse `-` and `..`, trim `-` and `.`, `.lock` to `-lock`) produces
  an accepted name for every one of those.
- The harness could plant a branch named `review/<feature>/<slug>` with `origin: "self"` (a branch name with `/` is fine) but
  could not set a commit's author: one field was added, `author: "Name <email>"` on a commit (refused when malformed). No
  phase 1 fixture uses it beyond `CRV-008/pass-already-claimed`; phase 2's author test needs it.
- Constitution I, IX and X say nothing that fixes who picks a reviewer or what an independent review must be beyond the
  independence rule `critical-delivery.md` item 5 already grades, so no amendment is needed (plan P10).

**New cases.** 25: 22 under `tests/enforcement/cases/claim-review/` (`CRV-001` to `CRV-009`, a fail and a pass each, plus
`CRV-005/fail-no-record`, `CRV-006/pass-slug-spaces-and-dots`, `CRV-008/pass-already-claimed`, `CRV-008/pass-json`) and three
control variants (`roadmap-claim-check/CLAIM-001/pass-review-ref-ignored`, `territory-check/TERR-001/pass-review-ref-ignored`,
`claim-feature/CLF-012/pass-review-ref-ignored`: a `review/` ref on the ledger changes nothing in the other readers, and a
ref named like a higher number does not move the allocator). **On the parent commit** the 22 `claim-review` cases all fail
(`names a script that does not exist: claim-review.ps1`); the three controls pass there by design (they pin that nothing moves).

**After.** `-Case claim-review/`: every case passes; the coverage report lists `claim-review.ps1  9 of 9 site(s) fixtured`;
931 case directories (906 + 25). `doc-lint.ps1` classifies 80 shipped files (79 + the new script), `build-digests.ps1 -Check`
OK, `ritual-checks.ps1` on the working tree: every member OK or n/a and `scope-check` UNGRADED (no phase commit yet).
**The owner's gate (the full harness and `ritual-checks.ps1`) exited 0** on the phase 1 working tree.

**Not fixtured, stated.** Two refusals inside the one `Stop-NotMade` site have no case: "the tip of the feature could not be
fetched" (it needs a fetch to fail on a ref `ls-remote` just listed) and "git could not create the claim commit" (it needs no
git identity, and a recipe cannot unset the fixture's own). The site's push-rejected path is fixtured (`CRV-008`); the helper's
text is one function, so a reworded message is caught there.

**Findings during the work.** The first draft built the claim tree as a one-element array assigned from an `if`
expression, which PowerShell unrolls to a string, so `$tree[0]` was one character; the success fixtures caught it before any
phase review. The working copy of `scripts/adoption-lib.ps1` and `tests/enforcement/emission-idioms.json` was CRLF on disk
while the index holds LF (the known state of this working tree); both were written LF so the diff is the change and nothing else.

### Phase 1 review follow-ups (`ai-code-review-phase1.md`: APPROVE with follow-ups, F1 to F8)

- **F1 (closed).** T004 named `CRV-010` (the reader's failure channel) and `CRV-011` (slug cases) and ticked without them: the work was folded into
  other rule ids and not recorded. Now recorded, and the gap closed: the reader's `Failed` channel behind the first read is `CRV-003/fail-claims-read`
  (origin's second read fails through `originFailCall: 2`, so the feature is found and the claims read fails: refused with the reader's cause, exit 1);
  the slug rule's edge cases are `CRV-006/pass-slug-spaces-and-dots`, `CRV-009/fail` (two names that slug alike) and the new
  `CRV-009/fail-no-usable-characters` (a name with no character a ref can hold). The `-WithAuthors` path has no phase 1 caller by design: its first
  fixtures are phase 2's `CRIT-R07` and `CRIT-R09` (an unreadable author), and phase 2 does not start without them.
- **F2 (recorded).** The numbering that shipped: `CRV-001` to `CRV-008` the eight refusals of the contract, `CRV-009` the slug collision (a ninth refusal
  the contract folds into refusal 6), and the three "other ledger readers ignore a review ref" controls filed as `pass-review-ref-ignored` variants under
  `CLAIM-001`, `TERR-001` and `CLF-012` (T004's `CRV-012`). The task text keeps its original numbering; this file is the record, the text was not edited
  (an edit to an approved task list needs an approver record).
- **F3 (deferred to phase 2).** No phase 1 fixture reads the pushed commit back (parent, tree, message, author) or proves an existing ref is never
  overwritten. Phase 2's fixtures read claims through `Get-ReviewClaims -WithAuthors`, which is the author and the ref shape; a non-fast-forward is refused by
  git (a push is never forced). A rival-ref case is added there if the phase 2 review asks for it.
- **F4 (fixed).** "already claimed" now compares slugs case-sensitively (`-ceq`); the slug is lower-case by construction. "Any ref at the slug is a claim" is
  the semantics and goes in the phase 4 guidance.
- **F5, F6, F7 (accepted).** The commit sha is taken from merged output and fails safe (a warning makes the push be refused); the slug rule is not
  injective and refuses clearly when two names collide or none is usable; a few twins differ in more than one condition but the extra difference cannot
  rescue a fail for a wrong reason.
- **F8 (recorded).** The T001 parent baseline was not recorded in full; stated above, and the append-only change to `adoption-lib.ps1` is why no verdict moves.

## Phase 2: the check reads the claim (T009 to T013)

**What changed.** `Invoke-CriticalTeamEvidence` (`scripts/enforcement-pack.ps1`) now calls a new `Invoke-ReviewClaimCheck` after the 021
conditions, and only when they hold (Reviewer on the roster, permitted, not the Owner, Owner named): a stranger, the Owner and a denied
reviewer are named as before and the claim is not graded a second time (FR-005). It reads the claims once with `Get-ReviewClaims -WithAuthors`
and says, in the pack's vocabulary: a failure when the Reviewer has no claim (the Owner's own claim is named as not counting), when the
claim's name slugs to the Owner's, or when its commit was authored under the Owner's name or email local part; an `UNGRADED` line (exit
unchanged) when there is no origin, the ledger or a claim's author cannot be read, or two roster names write as one ref name. The existing
"human-pr-review.md is missing" failure gains one clause, on the same line, when the ledger was read and holds no claim for the feature
(FR-006a). The solo arm never reaches the code; `Get-CriticalMergeReadiness` and every other member are untouched.

**New cases.** 16 under `enforcement-pack/CRIT-R05` to `CRIT-R09` (plan P4's table): R05 no claim (and the Owner's claim only), R06 a claim that
slugs to the Owner's, R07 a claim authored under the Owner's name and under the Owner's email, R08 the unclaimed clause, R09 the four
`UNGRADED` causes (no origin, ledger unreadable through `originFailCall`, author unreadable, ambiguous roster). Rules `CRIT-R05` to `CRIT-R09`
are in `rules.json`. Run against the unchanged check first: R05 fail, R06 fail, R07 fail and R07 fail-email were observed failing (their expected failure line is not printed by it);
R08 and R09 were run too but only their exit-code results were captured on the parent (they matched there, exit 0 or 1 being the same), so their parent-side
output mismatch is not recorded. The passes are the same fixtures with the one condition put right.

**Existing fixtures changed (T009/T013, plan P5).** Sixteen team-arm fixtures whose Reviewer is valid had no origin, so the new reading
printed an `UNGRADED` line and ended `enforcement-pack: UNGRADED` where they expected `OK`: `CRIT-R01/pass-artifact-committed-final-commit-unnamed`,
`CRIT-R01/pass-artifact-committed-mid-feature`, `CRIT-R04/pass-ready-all-ticked-unchanged`, `CRIT-T01/pass`, `CRIT-T02/pass` to `CRIT-T06/pass`,
`CRIT-T07/fail` and `/pass`, `CRIT-T08/pass`, `/pass-case-differs`, `/pass-object-roster`, `CRIT-T09/pass`, `/pass-denied-other-person`. Each recipe
gained `origin: "self"` and the Reviewer's claim as a branch; no `expected.txt` changed, so their output is byte-identical to before. Every other
existing case (including the solo arm, the stranger, Owner-as-Reviewer and denied-reviewer fixtures, and every pending/mid-feature case) passed unchanged.

**Honest limits, stated.** A claim shows that someone who can push to origin wrote a roster name; the author test catches the owner pushing
from their own identity and nothing more (the roster maps no name to an identity, plan P9). An unreadable ledger or author is `UNGRADED`, not red
(spec FR-004), so a Critical team feature can reach merge with that line on a CI that cannot read origin; gate 6 stands behind it. The check reads no
dates: an abandoned claim stays a claim until the Reviewer named in the review file differs from it. A real project whose claim is missing sees a
failure naming the command that fixes it; FitForge, the only adopted team-arm project, is the one whose first red run the update note will predict.
