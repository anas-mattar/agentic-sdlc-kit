# Notes: Cross-repo Territory Reach

Evidence and decisions that belong beside the feature but not in its approved documents.

## Approval record — 2026-10-11

The owner (anas.m) approved the spec and the plan on 2026-10-11. The Draft to Approved flip on
`spec.md` is the act that starts the amendment rule (constitution I); it is committed alone, so the
status-only exemption applies as written.

What the approval covers:

- `spec.md` as committed in 19592a9.
- `plan.md` as committed in 619f89c: decisions D1 to D8, the four-phase order, and
  `**Gate Certification**: user-run` (this feature changes an enforcement script).
- `research.md`, `data-model.md`, `contracts/territory-check-output.md` and `quickstart.md` as
  committed in the same commit, and `tasks.md` as committed after it, with each phase's Territory.

What it does **not** cover, stated plainly:

- **Plan D5 (research R6) is not decided.** Spec FR-013 and US3 scenario 2 say a project with no usable
  `codeRepos` sees its existing output unchanged; for a declaration that is present but unusable that
  means a warning and then `CLEAN`, which the spec's own constraint forbids. The plan recommends
  amending those two sentences so that an absent or empty declaration is unchanged and a present but
  unusable one is UNGRADED by name. Approving the spec and plan does not decide this: an amendment
  needs the owner's own approval line, and the spec sentences stand as written until it is given.
  Phases 1 and 2 do not depend on it. Task T016 stops phase 3 until it is decided.
