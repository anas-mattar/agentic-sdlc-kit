# Notes: claim-feature.ps1's ledger read and refused push are named states

Phase evidence for feature 030. Nothing here is law; `spec.md`, `plan.md` and `tasks.md` are.

## Phase 1: the ledger read and the rejected push

### T001 Baseline on the parent commit (`1d5914c`, the merge of PR #91)

Measured by running `pwsh -File scripts/claim-feature.ps1 -ShortName probe "a probe"` in a purpose-built repository (an
`origin` that is a second repository on disk, the stock-script stub the fixtures use) with a counting wrapper on
`remote.origin.uploadpack` (T002 a), and through the harness.

| State | Under `pwsh -File` | Through the harness launcher |
|---|---|---|
| first ledger read fails (`Get-RemoteFeatureHeads` throw, line 47) | a PowerShell exception record (`Exception: ...claim-feature.ps1:47 ... git ls-remote failed - cannot read the remote ledger.`), exit 1 | `RunChild: the script under test threw before returning a verdict`, **exit 128** (the last git call's code leaked) |
| read fails after a push that succeeded | the same exception record after `Allocating feature number 001`, exit 1, **and `001-probe` is on `origin`** | the same, exit 128 |
| push rejected, no rival (the old `CLF-007` fail) | three `WARNING: Number NNN was claimed concurrently ()` lines with an empty list, two `Renumbered:` lines, `Lost the allocation race 3 times`, exit 1 | the same text, exit 1 |
| successful claim, no origin / origin takes the push / `-NoPush` | the three outputs of the success fixtures (`CLF-004` pass cases, `CLF-012` pass, `CLF-007` pass) | exit 0 |

The spec left the throw's exit code unmeasured on purpose. It is **1 at a terminal and 128 through the harness's launcher**,
and, worse than the exit code, in the second row a claim is live on `origin` while the script reports an error.

Harness on the parent (isolated worktree, `git worktree add --detach` outside the repository): see "Numbers" below.
`-Case CLF-` before the change: 94 passed, 0 failed. The coverage report before the change: `claim-feature.ps1` 7 of 10 sites
fixtured (3 not a rule), exempt rules unchanged at the count the full run reports.

### T002 Probes of the harness fields (plan P5)

- **(a) `remote.origin.uploadpack` counting wrapper: works.** Every `git fetch origin` and `git ls-remote origin` runs the
  remote's upload-pack, so a wrapper that counts calls and exits non-zero on the Nth fails exactly that read. The call order a
  claim makes is fixed (first fetch 1, first read 2, read after the first push 3, then re-fetch and re-read on a lost race).
  Run as `sh '<path>'` so it needs no execute bit. Tried on Windows (Git for Windows' `sh`); the Linux runner is exercised by
  CI on the PR, not here. The `PATH` shim fallback was not needed. Implemented as the `originFailCall` recipe field, with its
  wrapper and counter under `.git/` so the working tree stays clean (a claim refuses a dirty one).
- **(b) A stub that creates a rival: works, no field needed.** The stub is test code the recipe places; it runs
  `git -C origin.git branch NNN-rival main` between allocation and the push.
- **(c) A rival at every attempt: not by a `pre-push` hook, but by a `receive-pack` wrapper.** A wrapper on
  `remote.origin.receivepack` runs the real `git-receive-pack` and then creates `<NNN>-rival` for every numbered branch just
  pushed; a claim then meets a rival after each of its three attempts and ends on `Lost the allocation race 3 times` with
  each of its own branches withdrawn. This is the third recipe field, `originRivalOnPush` (plan P5 said "one to three"), and it
  is why **`CLF-007` keeps its fixture and nothing becomes exempt** (plan P6 allowed it to).

### The work

- `scripts/claim-feature.ps1`: `Get-RemoteFeatureHeads` no longer throws; it sets `$script:LedgerReadFailed` (an empty
  ledger and a failed read cannot be told apart by the return value, because PowerShell unrolls an empty array to `$null`);
  each of its three callers checks it. The push's output is captured. The race loop follows plan P3: a rejection with no
  rival is refused once. Lines for the withdrawal (`git push origin --delete`) and the re-fetch are untouched (phase 2).
- Harness: fields `originFailCall` and `originRivalOnPush` in `tests/enforcement/lib/FixtureRepo.psm1` with self-tests in
  `tests/enforcement/Harness.Tests.ps1` (including the refusal without `origin`, the refusal of a bad call number, and that a
  push is not counted).
- Fixtures: `CLF-008` to `CLF-012` (a pair each, plus `CLF-011/fail-unpushed`), and `CLF-007` rebuilt through `originRivalOnPush`.
  Rules inventoried in `tests/enforcement/rules.json`.

### Corrections and deviations from the plan, found while writing the fixtures

1. **The rejected-push message is laid out on several lines.** Plan P2's row reads `git push of <branch> was rejected: <git's text>.
   Nothing was claimed; ...`. Git's text is five lines (a `fatal:` line, a second one, a blank line and two more), so inline it
   reads badly; the first line is `git push of <branch> was rejected:` and git's text follows on its own lines, then the closing
   sentence. The wording of every sentence is the plan's; only the placement of git's text is a layout choice.
2. **The rejected-push message gained the plan's Risks sentence.** `If the push may have landed, check origin (git ls-remote
   --heads origin <branch>) before claiming again.` is the Risks section's "the message therefore says to check origin".
3. **A fourth state of the re-read refusal.** Plan P2's row 4 says `<branch> was withdrawn from origin`. That is true only when our
   push landed. When our own push was rejected and a rival is also on `origin`, nothing of ours reached `origin`, so the message
   reads `<branch> never reached origin` instead, and the state has its own fixture (`CLF-011/fail-unpushed`). Plan P2 has
   one row for the state; this is a second wording of it, recorded here and not amended into the plan.
4. **`CLF-007` was re-expected, as the plan said it would be (P6).** The old fail (a push that fails) now reads as the rejected push
   and moved to `CLF-012` (`fail` and `pass`); `CLF-007`'s fail was rebuilt as a real rival after every push.
5. **`Stop-Refused "$rejection"`, with the quotes.** The coverage sweep's idiom is `Stop-Refused\s+['"]`, so a bare variable is not
   seen as an emission site; the quoted form is the same call and is seen. Nothing in `emission-idioms.json` changed.
6. **Line endings.** The working-tree copy of `scripts/claim-feature.ps1` was CRLF while the index is LF; it was normalised to LF
   before the change so the diff is the 37 lines changed and not the whole file.

### Results on the changed script

Hand-written expectations, run first on the parent and then on the change:

| Rule | On the parent | On the change |
|---|---|---|
| `CLF-008` fail | exit 128, `RunChild ... threw before returning a verdict` | refusal, exit 1 |
| `CLF-009` fail | exit 128 after `Allocating ...` | refusal naming the branch, exit 1, the claim left on `origin` |
| `CLF-010` fail, pass | fail: exit 128; pass: three lost-race warnings and the three-times refusal | fail: rejected push plus `The ledger could not be read either.`; pass: the rejected push alone |
| `CLF-011` fail, fail-unpushed | exit 128 | refusal naming what is and is not on `origin`, exit 1 |
| `CLF-012` fail | the three-times refusal (output differs, exit 1 both) | the rejected push, once, no warning |
| every pass, `CLF-007` | pass | pass (unchanged behaviour) |

`-Case claim-feature` on the change: 124 passed, 0 failed. Coverage: `claim-feature.ps1` 12 of 15 sites fixtured (3 not a
rule), no unowned site, no new exemption.

Under `pwsh -File` on the changed script (the T001 states): first read fails, `git ls-remote failed - cannot read the remote
ledger. Nothing was claimed.`, exit 1, nothing on `origin`; read fails after the push, `git ls-remote failed after pushing
001-probe ...`, exit 1, `001-probe` on `origin` and said so; the successful claim and the `-NoPush` claim print the same bytes
as before; `-Json` keeps the refusal on the error stream with no object.

### Numbers

(Filled in after the full harness and `ritual-checks.ps1` run on an isolated checkout of the phase 1 commit.)
