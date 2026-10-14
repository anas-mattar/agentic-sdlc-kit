# Notes: feature 027 — grade amendments of another feature's approved documents

Evidence and decisions, kept out of the graded documents (a `Status` line takes only the bounded form `Approved <date> (owner: <name>)`, so the detail lives here).

## Owner decisions

- **Spec approved** (anas.m, 2026-10-14): option B (grade another feature's approved documents on numbered branches **and** the Lite lane, only for documents that exist at the diff base), with the removal sub-decision as recommended (a removal of another feature's approved document is graded and has no passing path in an ordinary commit). The owner's words: "option B, accept the removal, push the claim and write the plan".
- **Plan approved** (anas.m, 2026-10-14): decisions D1-D11 as recommended, and the three phases (D2 exists at the diff base; D3 a whole-directory move is a renumbering, a single moved document a removal; D6 the Lite gate is the changed-file list; D8 UNGRADED on the Lite lane; D11 the documents edited). The owner's words: "approve the plan, flip the roadmap row and push".

## Process note

The first approval commits of this feature carried a free-text `Status` line ("Approved (anas.m, ...) — option B chosen ..."). The status-only exemption of the amendment check (`StatusApprovedPattern`) accepts only the bounded form, so the check graded both commits as unapproved amendments and the branch failed `enforcement-pack`. A later commit cannot repair an earlier commit's grade, so the five commits were rebuilt with the bounded form and the detail moved here. This is the exemption working as specified (014 K2), not a defect in it.
