# 016 Multi-line Code Spans — phase evidence

Evidence and decisions that are not themselves law. This file is not graded by the amendment
rule (constitution I grades `spec.md`, `plan.md`, `tasks.md` and `contracts/` only), which is
why recording evidence here never costs an approver record.

## Approval

**2026-09-27 — the owner approved `spec.md` and `plan.md`.** The spec content was first approved
in session as "approved". The plan then corrected that Draft spec (research R1: F2's shape is a
comment-model loss, and HTML comment blocks need their own boundary), and the owner approved the
corrected spec and the plan together in session as "go ahead". The approval covers:

- the spec as corrected in `806db42`, including its Out of Scope list (full CommonMark
  conformance, the comment model and its unterminated-comment rule, other document readers);
- **D1** — `Convert-CodeSpanMarkers` changes signature to `-Lines`, with no single-line wrapper;
- **D8** — the new DIGEST-020 failure in a verbatim script, which fails rather than warns;
- the three-phase sequence and `**Gate Certification**: ci-held`;
- no new dependency. The CommonMark renderer used in research R1 was a scratch measuring tool,
  not a kit dependency.

The spec's `**Status**` line moved `Draft` → `Approved` in the same commit as this record. That
transition is the act that *starts* the amendment rule rather than a change to an approved
document, so it owes no approver record (constitution I, and the exemption feature 014 shipped
as D3d). The commit is kept to exactly that shape so the exemption applies as written.
