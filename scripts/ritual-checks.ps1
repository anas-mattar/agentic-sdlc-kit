<#
.SYNOPSIS
    Ritual checks wrapper: one entry point running every ritual machine check with
    identical verdicts locally and in CI.

.DESCRIPTION
    Contract: specs/006-verification-pack/contracts/ritual-checks-ci.md.

    Runs, in order, never short-circuiting (one run reports every problem):
      1. scripts/doc-lint.ps1
      2. scripts/enforcement-pack.ps1   (includes the ReviewProvenance check)
      3. scripts/scope-check.ps1 -All   (every phase commit since merge-base with main)
      3b. scripts/scope-check-repos.ps1 -All  (the same grading for the nested code
                                         repositories declared in kit-adoption.json —
                                         reports n/a, distinct from OK, when none are
                                         declared or none is present here, which is the
                                         kit repository, every single-repo adoption, and
                                         governance CI; 012)
      4. scripts/build-digests.ps1 -Check  (law-digest freshness — reports n/a, distinct
                                         from OK, until digest markers exist; 010)
      5. scripts/verify-kit.ps1         (the adoption doctor — ADOPTED PROJECTS ONLY,
                                         gated on .kit-version OR kit-adoption.json at
                                         -Root, mirroring the doctor's own discriminator;
                                         a tree with neither marker shows an explicit n/a
                                         line, excluded from the failure count — 007 US3)
      6. scripts/roadmap-claim-check.ps1  (every NNN-* claim on origin must have a
                                         non-idea roadmap row — GAP-017; reports n/a
                                         with no remote, an unreachable ledger, or no
                                         Status-bearing roadmap table — 011)

    Each member runs as a child pwsh process (the member scripts terminate with `exit`),
    and the wrapper ends with a verdict block, one line per member, then
    'ritual-checks: RESULT OK|UNGRADED|FAIL'. Exit 0 iff every member exits 0. Read-only.

    THE VERDICT VOCABULARY (feature 015, FR-009; plan D4, D5, D7). Every grading script in
    this kit ends its run on a VERDICT LINE - `<member>: <WORD> [reason]` - and the word is
    one of these six. They are defined here, once, because this script is the single entry
    point an adopted project runs (FR-012). Detail lines above a verdict line are prose and
    are not bound by it: `ERROR: 3 referenced path(s) do not resolve` followed by a list is
    a finding, not a verdict, and doc-lint.ps1 prints several of both. Read 'the check' below
    as 'the run of that member', since a member may grade many commits or many repositories:

      OK        The check ran, compared what it claims to compare, and found nothing. The
                word is 'OK' and not 'PASS' because nine scripts, three adopted projects
                and every gate record written to date already say OK (plan D4).
      FAIL      The check ran and found a violation. It is the only VERDICT that exits 1;
                exit 1 also carries an invocation error that produced no verdict at all
                (an unreadable -Root, a malformed argument), which every member spells
                `ERROR` and no member counts as a grade.
      WARN      The check ran, formed an opinion, and that opinion is advisory. It observed
                something real and is not blocking on it (e.g. PhaseSizeWarning).
      N/A       The check DOES NOT APPLY here - a doctor in an unadopted tree, a roadmap
                check with no roadmap table. A positive, honest claim about scope.
      UNGRADED  The check applies and RAN AND FORMED NO OPINION: no computable diff base,
                unreadable history, a depth-1 clone whose base is absent. It is not OK (it
                compared nothing), not N/A (it does apply), and not WARN (it observed
                nothing). Before feature 015 this state had no word, so it printed OK and a
                run that graded nothing was indistinguishable from a clean one - GAP-027.
                UNGRADED changes the VERDICT, never the exit code (plan D6, FR-011).
      PENDING   RESERVED, and emitted by nothing today (grep confirms it). It belongs to GAP-022 - a Critical
                branch red from its first commit to its last - which is out of scope here.
                Defined now so GAP-022's eventual fix is not also a vocabulary change (plan
                D7). A state nothing emits is documented as reserved rather than left
                implicit; if you are adding an emission of PENDING, the rule you are
                implementing needs its own feature first.

    KNOWN DIVERGENCES, stated rather than implied (phase 5 review, F2). The claim above is
    about verdict lines, and it is true of every member's verdict line as of this commit -
    the phase-5 remediation converted the last two, scope-check.ps1 and scope-check-repos.ps1,
    which reported ungraded runs as WARN, as n/a, and as PASS. What it is NOT is a claim that
    the whole kit speaks only these six words:

      - `scripts/update-kit.ps1` is an installer, not a grader, is not a member of this
        wrapper, and is outside feature 015's Territory. Its `ERROR` lines stay as they are.
      - Detail lines in doc-lint.ps1 (`ERROR:`, `INFO:`) and the per-commit and per-repository
        lines in the two scope checks carry their own prose, by design, per the paragraph
        above. Only the last line of a member's output is its verdict.

    Reconciling anything further is not this feature's work and no task claims it is.

    CI note: pass -Branch explicitly — a pull_request checkout is a detached-HEAD merge
    commit where branch detection returns the literal 'HEAD'
    (.github/workflows/ritual-checks.yml does this).

.EXAMPLE
    pwsh -File scripts/ritual-checks.ps1
    pwsh -File scripts/ritual-checks.ps1 -Branch 006-verification-pack
#>
[CmdletBinding()]
param(
    [string]$Branch,
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
# A caller's PS 7.4+ profile may set this to $true, which would throw on the first failing
# member and lose the verdict block — the contract requires all members to run (review F3).
$PSNativeCommandUseErrorActionPreference = $false
$Root = (Resolve-Path $Root).Path
$scriptsDir = Join-Path $Root 'scripts'

$branchArgs = @()
if ($Branch) { $branchArgs = @('-Branch', $Branch) }

$members = [ordered]@{
    'doc-lint'         = @((Join-Path $scriptsDir 'doc-lint.ps1'), '-Root', $Root)
    'enforcement-pack' = @((Join-Path $scriptsDir 'enforcement-pack.ps1'), '-Root', $Root) + $branchArgs
    'scope-check'      = @((Join-Path $scriptsDir 'scope-check.ps1'), '-All', '-Root', $Root) + $branchArgs
    'scope-repos'      = @((Join-Path $scriptsDir 'scope-check-repos.ps1'), '-All', '-Root', $Root) + $branchArgs
    'digests'          = @((Join-Path $scriptsDir 'build-digests.ps1'), '-Check', '-Root', $Root)
    'roadmap-claims'   = @((Join-Path $scriptsDir 'roadmap-claim-check.ps1'), '-Root', $Root) + $branchArgs
}

# The adoption doctor joins for adopted projects. The gate mirrors the doctor's OWN
# discriminator (007 research D5.3/D7, phase 3 review F1): .kit-version OR
# kit-adoption.json — a record-bearing copy adoption without .kit-version must not be
# invisible to CI while a direct doctor run would be red. The kit repo (neither marker)
# gets an explicit n/a line, never a silent omission.
$doctorNA = $true
if ((Test-Path (Join-Path $Root '.kit-version')) -or (Test-Path (Join-Path $Root 'kit-adoption.json'))) {
    $members['verify-kit'] = @((Join-Path $scriptsDir 'verify-kit.ps1'), '-Root', $Root)
    $doctorNA = $false
}

$results = [ordered]@{}
$naReasons = @{}
$ungradedReasons = @{}
# Members whose n/a states (010 SC-004; 011 no-ledger/no-table) are distinct verdicts,
# not OK: capture their output (re-echoed verbatim) to read the n/a line while keeping
# the exit-code contract identical to the other members.
$naCapableMembers = @('digests', 'roadmap-claims', 'scope-repos')
# Members that can report UNGRADED - they RAN and formed no opinion (feature 015, FR-010).
# Captured for the same reason and by the same mechanism as an n/a line: reading the
# member's own words keeps every member exit code byte-identical to today, which is what
# plan D6 requires. A dedicated exit code would itself have been an exit-code change, and
# FR-011 says any such change is stated explicitly and separately - so there is not one.
#
# scope-check and scope-repos joined in the phase-5 remediation (review F1). They carried
# the identical GAP-027 fail-open: on the same depth-1 clone GAP27-001 and GAP27-004 build,
# scope-check printed 'WARN ... nothing checked' and this block summarised it OK. Being
# left out of this list was half of that defect - the other half was the member's own word.
$ungradedCapableMembers = @('enforcement-pack', 'scope-check', 'scope-repos')
$captureMembers = @($naCapableMembers + $ungradedCapableMembers | Select-Object -Unique)
foreach ($name in $members.Keys) {
    Write-Host "=== ritual-checks: $name ==="
    if ($name -in $captureMembers) {
        $out = & pwsh -NoProfile -File @($members[$name]) 2>&1
        $results[$name] = $LASTEXITCODE
        $out | ForEach-Object { Write-Host $_ }
        if ($results[$name] -eq 0) {
            # Echo the member's own n/a reason into the summary (phase 1 review F5).
            $naLine = @($out | ForEach-Object { "$_" } | Where-Object { $_ -match "^${name}: n/a" }) | Select-Object -First 1
            if ($naLine) { $naReasons[$name] = $naLine.Substring("${name}: ".Length) }
            # The same idiom for the state this feature adds. Anchored on the member's own
            # name so a line that merely quotes the word inside a longer sentence - a
            # failure message explaining UNGRADED, say - cannot be read as the verdict.
            $ungradedLine = @($out | ForEach-Object { "$_" } | Where-Object { $_ -match "^${name}: UNGRADED" }) | Select-Object -First 1
            if ($ungradedLine) { $ungradedReasons[$name] = $ungradedLine.Substring("${name}: ".Length) }
        }
    } else {
        & pwsh -NoProfile -File @($members[$name])
        $results[$name] = $LASTEXITCODE
    }
    Write-Host ''
}

$failedCount = 0
$ungradedCount = 0
foreach ($name in $results.Keys) {
    $verdict = if ($results[$name] -eq 0) {
        # Order matters: UNGRADED outranks n/a outranks OK. A member that formed no opinion
        # must not be summarised by whichever other word also happens to fit.
        if ($ungradedReasons.ContainsKey($name)) { $ungradedCount++; $ungradedReasons[$name] }
        elseif ($naReasons.ContainsKey($name)) { $naReasons[$name] }
        else { 'OK' }
    } else { $failedCount++; 'FAIL' }
    Write-Host ('ritual-checks: {0,-16} {1}' -f $name, $verdict)
}
if ($doctorNA) {
    Write-Host ('ritual-checks: {0,-16} {1}' -f 'verify-kit', 'n/a (no adoption markers — kit repository or unadopted tree)')
}
if ($failedCount -gt 0) {
    Write-Host "ritual-checks: RESULT FAIL ($failedCount of $($results.Count) member(s) failed)"
    exit 1
}
if ($ungradedCount -gt 0) {
    # Exit 0: the run did not fail, and FR-011 forbids making it fail. What it must not do
    # is print RESULT OK over the top of a member that compared nothing - that last line is
    # what a reader, a grep, and a status badge all take as the answer.
    Write-Host "ritual-checks: RESULT UNGRADED ($ungradedCount of $($results.Count) member(s) formed no opinion; nothing failed)"
    exit 0
}
Write-Host 'ritual-checks: RESULT OK'
exit 0
