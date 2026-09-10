<#
.SYNOPSIS
    Enforcement pack: mechanically checks the kit's delivery-level non-negotiables.

.DESCRIPTION
    Converts previously-prose rules into CI-agnostic checks, run against the current
    branch's diff versus main:

      - Structure       (NNN-* branches): spec.md/plan.md/tasks.md exist; Delivery Level
                         header, when present, is filled with Lite, Micro, Standard, or
                         Critical (not the template placeholder), read from VISIBLE text
                         (a commented-out decoy never sets the lane). A Micro feature
                         requires spec.md only (constitution X, Micro lane — the
                         mini-spec is the lane's whole specification).
      - MicroLane       (NNN-* branches declared Micro): exactly one phase (distinct
                         'phase N' numbers on the branch), no plan.md/tasks.md in the
                         tree (promotion is all-or-nothing), a **Territory** block of at
                         most $Config.MicroTerritoryMaxFiles literal file entries (no
                         globs — a glob defeats the cap), at most
                         $Config.MicroPhaseMaxLines changed lines in TOTAL across the
                         phase's commits (a hard failure where other lanes get a
                         per-commit PhaseSizeWarning — summed so remediation commits
                         cannot split the bound), and no '**Gate Batching**'
                         declaration (one phase — nothing to batch). Every failure names
                         the promotion remediation (constitution X, Micro lane).
      - LiteAndAbuse     (fix/*, chore/* branches): no changed file matches a prohibited
                         category (dependency manifest, auth, schema/migration, contracts,
                         domain invariants); migrations are always prohibited on this lane
                         regardless of file count; more than $Config.AbuseGuardFileCount
                         changed files fails as well, suggesting promotion to a feature.
      - CriticalEvidence (NNN-* branches declared Critical): the independence evidence
                         docs/sdlc/critical-delivery.md item 5 requires, in one of two
                         MODES selected by the 'developers' array in kit-adoption.json.
                         SOLO (one developer declared, or nothing usable declared):
                         second-model-review.md exists and was first committed at least
                         $Config.CoolingOffHours ago — the solo substitute, unchanged.
                         TEAM (two or more declared): human-pr-review.md carries a filled
                         '## Review Provenance' block naming a Reviewer who is not the
                         Owner, plus the verbatim attestation; no cooling-off applies,
                         because the independence is real rather than substituted.
                         Absence of any kind selects SOLO — the stricter branch — so a
                         project that declares nothing keeps the behaviour it has today.
                         How strong is TEAM? Two names written by the same team, in one
                         file: it converts a silent omission into a written claim a human
                         reviewer can falsify, and it is worth exactly that much — the
                         strength of the Reviewer Provenance block, no more (FR-007). The
                         declared roster is COUNTED to pick the mode and is never compared
                         against either name.
      - PhaseSizeWarning (NNN-* branches): non-blocking warning when a single commit's
                         diff exceeds the configured line/file thresholds.
      - GateCertification (NNN-* branches): the '**Gate Certification**' declaration —
                         read from plan.md, or from spec.md when the feature is Micro
                         (the lane has no plan.md; constitution X, Micro lane) — when
                         present, must be 'user-run' or 'ci-held', and 'ci-held' is
                         prohibited on Critical features (constitution X, CI-held
                         certification; docs/sdlc/critical-delivery.md item 4). An
                         absent line means 'user-run' — plans from before the clause
                         remain valid.
      - ReviewProvenance (all recognized lanes): every specs/**/ai-code-review*.md ADDED
                         (or arriving as a rename target) in the branch's diff must carry
                         a '## Reviewer Provenance' section whose OWN Reviewer line is
                         filled and is neither the implementer nor an unfilled
                         placeholder, plus the verbatim non-implementer attestation
                         (DoD gate 5, feature 006). Pre-existing reviews at their
                         historical paths are grandfathered by construction.
      - GateBatching     (NNN-* branches): the plan.md '**Gate Batching**' declaration,
                         when present, must be 'none' or 'phases N-M' spanning at most
                         $Config.MaxBatchPhases consecutive phases, and is prohibited
                         outright on Critical features (constitution X, Batched gates;
                         docs/sdlc/critical-delivery.md item 4). An absent line means
                         'none' — plans from before the clause remain valid.

    See specs/002-enforcement-pack/research.md for the rationale behind every default below.

.EXAMPLE
    pwsh -File scripts/enforcement-pack.ps1
    pwsh -File scripts/enforcement-pack.ps1 -Branch fix/my-branch
#>
[CmdletBinding()]
param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [string]$Branch
)

$ErrorActionPreference = 'Stop'
# git emits UTF-8 paths (quotepath is disabled where needed); align pwsh's native-output
# decoding so non-ASCII filenames round-trip on Windows consoles too (phase 2 review, F2).
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new() } catch {}
$Root = (Resolve-Path $Root).Path
Push-Location $Root
try {

$Config = @{
    DependencyManifestGlobs = @('package.json', 'package-lock.json', '*.csproj', 'requirements*.txt', 'Pipfile*', 'go.mod', 'go.sum', 'Gemfile*')
    AuthPathGlobs           = @('*auth*')
    SchemaMigrationGlobs    = @('*migrations*', '*migration*.sql', '*migration*.ps1', '*migration*.py')
    ContractsGlob           = '*contracts*'
    DomainInvariantsPath    = '{{DOMAIN_INVARIANTS_PATH}}'
    AbuseGuardFileCount     = 25
    CoolingOffHours         = 24
    PhaseWarnLines          = 400
    PhaseWarnFiles          = 15
    MaxBatchPhases          = 3
    # Micro-lane bounds — constitutional constants (constitution X, Micro lane; sync-listed
    # in the constitution's mirror list — change only in lockstep with an amendment).
    MicroTerritoryMaxFiles  = 5
    MicroPhaseMaxLines      = 400
    MicroMaxPhases          = 1
}

$failures = @()
$warnings = @()

function Get-CurrentBranch {
    param([string]$Override)
    if ($Override) { return $Override }
    (git rev-parse --abbrev-ref HEAD 2>$null).Trim()
}

function Get-DiffBase {
    $candidates = @('origin/main', 'main')
    foreach ($c in $candidates) {
        git rev-parse --verify --quiet $c *> $null
        if ($LASTEXITCODE -eq 0) {
            $base = (git merge-base HEAD $c 2>$null).Trim()
            if ($LASTEXITCODE -eq 0 -and $base) { return $base }
        }
    }
    return $null
}

function Get-ChangedFiles {
    param([string]$Base)
    if (-not $Base) { return @() }
    (git diff --name-only $Base HEAD 2>$null) | Where-Object { $_ }
}

# Plan-header declarations must be parsed from VISIBLE text only: a declaration hidden in
# an HTML comment block must never win first-match over the rendered one (008 phase 2
# review, F1 — a commented-out decoy could otherwise defeat the Critical exclusions of
# both Gate Batching and Gate Certification). Closed comment blocks are removed wholesale;
# the per-line trailing strip in each parser still handles the template's own same-line
# comment openings.
function Get-VisiblePlanLines {
    param([string]$PlanPath)
    $raw = "$(Get-Content -LiteralPath $PlanPath -Raw)"
    return ([regex]::Replace($raw, '(?s)<!--.*?-->', '')) -split "`r?`n"
}

# Delivery Level of a numbered feature, from spec.md's first VISIBLE '**Delivery Level**:'
# line — comment-stripped, so a commented-out 'Micro' (or 'Critical') decoy never sets the
# lane (contract M13; same rule as the plan-header parsers above). Returns the trimmed
# value string, '' when the file or the line is absent.
function Get-DeliveryLevel {
    param([string]$SpecPath)
    if (-not (Test-Path -LiteralPath $SpecPath)) { return '' }
    $line = (Get-VisiblePlanLines -PlanPath $SpecPath | Where-Object { $_ -match '^\*\*Delivery Level\*\*:' } | Select-Object -First 1)
    if (-not $line) { return '' }
    return ($line -replace '^\*\*Delivery Level\*\*:\s*', '' -replace '<!--.*$', '').Trim()
}

function Test-GlobAny {
    param([string]$Path, [string[]]$Globs)
    foreach ($g in $Globs) {
        if ($Path -like $g) { return $true }
        if (($Path -split '/') -contains ($g -replace '\*', '')) { return $true }
    }
    return $false
}

# --- Structure check (FR-002) ---
function Invoke-StructureCheck {
    param([string]$Branch)
    if ($Branch -notmatch '^\d{3}-') { return }
    $dir = "specs/$Branch"
    $specPath = Join-Path $dir 'spec.md'
    $level = Get-DeliveryLevel -SpecPath $specPath
    # A Micro feature's whole specification is the mini-spec: spec.md alone is required
    # here; MicroLane separately fails plan.md/tasks.md PRESENCE on the lane (contract M7).
    $required = if ($level -match '^Micro\b') { @('spec.md') } else { @('spec.md', 'plan.md', 'tasks.md') }
    foreach ($f in $required) {
        $p = Join-Path $dir $f
        if (-not (Test-Path $p)) {
            $script:failures += "Structure: $dir/$f is missing (every NNN-* branch requires spec.md, plan.md, and tasks.md — or spec.md alone when declared Micro; CLAUDE.md Feature Structure)"
        }
    }
    if (Test-Path $specPath) {
        $line = (Get-VisiblePlanLines -PlanPath $specPath | Where-Object { $_ -match '^\*\*Delivery Level\*\*:' } | Select-Object -First 1)
        if (-not $line) {
            $script:failures += "Structure: $dir/spec.md has no **Delivery Level** header"
        } elseif ($level -notmatch '^(Lite|Micro|Standard|Critical)\b') {
            $script:failures += "Structure: $dir/spec.md's **Delivery Level** header is unfilled or invalid: '$level' (legal values: Lite, Micro, Standard, Critical — constitution X)"
        }
    }
}

# --- Lite-lane prohibition + abuse guard (FR-003, FR-004) ---
function Invoke-LiteAndAbuseCheck {
    param([string]$Branch, [string[]]$ChangedFiles)
    if ($Branch -notmatch '^(fix|chore)/') { return }

    $categories = [ordered]@{
        'dependency manifest' = $Config.DependencyManifestGlobs
        'auth code'           = $Config.AuthPathGlobs
        'schema/migration'    = $Config.SchemaMigrationGlobs
        'contracts'           = @($Config.ContractsGlob)
    }
    if ($Config.DomainInvariantsPath -and $Config.DomainInvariantsPath -notmatch '^\{\{') {
        $categories['domain invariants'] = @($Config.DomainInvariantsPath)
    }

    $migrationHit = $false
    foreach ($file in $ChangedFiles) {
        foreach ($cat in $categories.Keys) {
            if (Test-GlobAny -Path $file -Globs $categories[$cat]) {
                $script:failures += "LiteAndAbuse: $Branch touches '$file', a prohibited category for the Lite lane ($cat) — promote to a numbered feature (docs/sdlc/critical-delivery.md)"
            }
        }
        if (Test-GlobAny -Path $file -Globs $Config.SchemaMigrationGlobs) { $migrationHit = $true }
    }

    if ($ChangedFiles.Count -gt $Config.AbuseGuardFileCount) {
        $script:failures += "LiteAndAbuse: $Branch changes $($ChangedFiles.Count) files, exceeding the Lite-lane abuse guard ($($Config.AbuseGuardFileCount)) — promote to a numbered feature"
    }
    if ($migrationHit) {
        $script:failures += "LiteAndAbuse: $Branch touches a migration path — migrations are always prohibited on the Lite lane regardless of file count"
    }
}

# Evidence mode for the Critical lane (013 D1/D2): 'solo' or 'team', DERIVED from the
# adoption record's 'developers' array and never declared directly — a project must not be
# able to assert team independence while naming one person.
#
# Every degenerate input resolves to 'solo', the stricter branch: no record, no field, a
# non-array, an empty array, an array of blanks, or a file that will not parse. That is the
# load-bearing half of this feature. Adoptions that predate it declare nothing, and a
# default of 'team' would silently drop the substitute requirement in projects that never
# asked — the silent-downgrade shape feature 012's reviews found four times in one feature.
#
# Malformation is strict here but SILENT here; scripts/verify-kit.ps1 is what reports it
# (013 phase 2). Strict-and-silent is safe; lenient-and-loud would not be.
function Get-EvidenceMode {
    $recordPath = Join-Path $Root 'kit-adoption.json'
    if (-not (Test-Path -LiteralPath $recordPath)) { return @{ Mode = 'solo'; Count = 0; Why = 'no kit-adoption.json' } }
    $rawRecord = "$(Get-Content -LiteralPath $recordPath -Raw)"
    # The record must be a JSON OBJECT at the root, and that has to be judged from the TEXT.
    # Testing the parsed value is not enough: ConvertFrom-Json emits array elements to the
    # pipeline one at a time, so `[{"developers":["a","b"]}]` — a record carrying no
    # schemaVersion, projectName or topology at all — collapses to a single PSCustomObject
    # indistinguishable from a real record, and selected team. FR-003 says every degenerate
    # record is solo (013 phase 3 review, CONFIRM 4; the type guard that missed it was the
    # phase 4 fix's own first attempt, caught by the regression fixture).
    if ($rawRecord.TrimStart([char]0xFEFF, ' ', "`t", "`r", "`n") -notmatch '^\{') {
        return @{ Mode = 'solo'; Count = 0; Why = 'kit-adoption.json is not a JSON object at its root' }
    }
    try {
        $record = $rawRecord | ConvertFrom-Json
    } catch {
        return @{ Mode = 'solo'; Count = 0; Why = 'kit-adoption.json does not parse' }
    }
    if ($record -isnot [PSCustomObject]) { return @{ Mode = 'solo'; Count = 0; Why = 'kit-adoption.json is not a JSON object' } }
    if ($null -eq $record.developers) { return @{ Mode = 'solo'; Count = 0; Why = 'no developers declared in kit-adoption.json' } }
    if ($record.developers -isnot [Array]) { return @{ Mode = 'solo'; Count = 0; Why = 'developers in kit-adoption.json is not an array' } }

    # De-duplicated case-insensitively, exactly as scripts/verify-kit.ps1 does. Counting raw
    # entries let one person written twice — ["Ada","ada"] — inflate a solo project into team
    # mode, dropping the second-model review and the cooling-off. That is the only direction
    # this feature must never move a project by accident, and the doctor already refused it
    # while the enforcing side allowed it: the two scripts disagreed about what a developer
    # is (013 phase 3 reviews, docs B1 / logic CONFIRM 3).
    $named = @($record.developers |
        Where-Object { $_ -is [string] -and -not [string]::IsNullOrWhiteSpace($_) } |
        ForEach-Object { $_.Trim() } |
        Sort-Object -Unique -CaseSensitive:$false)
    if ($named.Count -ge 2) {
        return @{ Mode = 'team'; Count = $named.Count; Why = "$($named.Count) developers declared in kit-adoption.json" }
    }
    return @{ Mode = 'solo'; Count = $named.Count; Why = "$($named.Count) developer(s) declared in kit-adoption.json" }
}

# --- Critical-evidence check (FR-005; modes added by 013) ---
function Invoke-CriticalEvidenceCheck {
    param([string]$Branch)
    if ($Branch -notmatch '^\d{3}-') { return }
    $dir = "specs/$Branch"
    $specPath = Join-Path $dir 'spec.md'
    if (-not (Test-Path $specPath)) { return }
    if ((Get-DeliveryLevel -SpecPath $specPath) -notmatch '^Critical\b') { return }

    $mode = Get-EvidenceMode
    if ($mode.Mode -eq 'team') {
        Invoke-CriticalTeamEvidence -Dir $dir -Why $mode.Why
    } else {
        Invoke-CriticalSoloEvidence -Dir $dir
    }
}

# SOLO: the substitute. Moved verbatim from the pre-013 check — same order, same
# conditions, same message strings, so a solo project cannot tell this feature happened.
function Invoke-CriticalSoloEvidence {
    param([string]$Dir)
    $reviewPath = Join-Path $Dir 'second-model-review.md'
    if (-not (Test-Path $reviewPath)) {
        $script:failures += "CriticalEvidence: $dir/second-model-review.md is missing (required for Critical features — docs/sdlc/critical-delivery.md item 5)"
        return
    }
    $recorded = (git log --follow --format=%aI -- $reviewPath 2>$null) | Select-Object -Last 1
    if (-not $recorded) {
        $script:failures += "CriticalEvidence: $dir/second-model-review.md has no git history — cannot verify the cooling-off period (commit it to start the clock)"
        return
    }
    $recordedTime = [DateTimeOffset]::Parse($recorded)
    $elapsedHours = ([DateTimeOffset]::UtcNow - $recordedTime).TotalHours
    if ($elapsedHours -lt $Config.CoolingOffHours) {
        $remaining = [math]::Ceiling($Config.CoolingOffHours - $elapsedHours)
        $script:failures += "CriticalEvidence: $dir/second-model-review.md was recorded $([math]::Round($elapsedHours, 1))h ago — cooling-off requires $($Config.CoolingOffHours)h ($remaining h remaining, docs/sdlc/critical-delivery.md item 5)"
    }
}

# TEAM: the real thing rather than the substitute — item 5's actual requirement, that the
# human reviewer is not the feature's owner. No cooling-off: the period exists to give a
# solo developer distance from their own work, and a second person already is that.
#
# Three parsing rules, each of which a phase-3 fresh-context review demonstrated was needed:
#   1. The file must be COMMITTED. A Critical feature cannot use ci-held, so its authoritative
#      gate is a human's local run — precisely where an untracked file on one developer's disk
#      would otherwise satisfy the only machine enforcement of item 5. The solo arm has always
#      had this guard; the team arm shipped without it (logic review, BLOCKING 1).
#   2. HTML comments are stripped FIRST, including an unterminated one, because that is what a
#      renderer does. A provenance block wrapped in <!-- --> renders as nothing and used to
#      pass — contract M13's rule, which Get-VisiblePlanLines already states, applied here
#      (logic review, BLOCKING 2).
#   3. Both names AND the attestation are read from inside the section slice only. The document
#      header carries its own '**Reviewer**:' field (006 phase-2 F1), and matching the
#      attestation against the whole file let it be satisfied from an unrelated comment.
#
# The roster in kit-adoption.json is COUNTED and nothing more: it selects the mode, and is
# never compared against Reviewer or Owner. A review naming two people who are not in the
# roster passes. That limit is deliberate and recorded rather than hidden — cross-checking
# free-text names against a free-text roster would read as verification while providing none.
function Invoke-CriticalTeamEvidence {
    param([string]$Dir, [string]$Why)
    $attestation = 'This reviewer is not the owner of the feature under review.'
    $reviewPath = Join-Path $Dir 'human-pr-review.md'

    if (-not (Test-Path -LiteralPath $reviewPath)) {
        $script:failures += "CriticalEvidence: $Dir/human-pr-review.md is missing — team mode ($Why) requires the independent human review itself, not the solo substitute (docs/sdlc/critical-delivery.md item 5)"
        return
    }
    if (-not ((git log --format=%H -- $reviewPath 2>$null) | Select-Object -First 1)) {
        $script:failures += "CriticalEvidence: $Dir/human-pr-review.md is not committed — evidence that exists only in a working tree is not evidence (commit it; FR-006 requires the identities to be read from committed artifacts)"
        return
    }

    $content = Get-VisibleText -Path $reviewPath
    if ($content -notmatch '(?m)^##\s+Review Provenance') {
        $script:failures += "CriticalEvidence: $Dir/human-pr-review.md has no visible '## Review Provenance' section — team mode ($Why) needs the reviewer and owner named in the review itself (specs/_templates/human-pr-review-template.md). A section inside an HTML comment does not count: it renders as nothing"
        return
    }
    $slice = if ($content -match '(?ms)^##\s+Review Provenance\s*$(.*?)(?=^##\s|\z)') { $matches[1] } else { '' }
    # Fenced code inside the section is illustration, not a declaration (logic review, NIT 7).
    $slice = [regex]::Replace($slice, '(?ms)^```.*?(^```|\z)', '')

    $reviewer = Get-ProvenanceValue -Slice $slice -Field 'Reviewer'
    $owner = Get-ProvenanceValue -Slice $slice -Field 'Owner'

    # A bare [bracketed] value is the template placeholder; '[Name](mailto:...)' is a
    # perfectly ordinary markdown link and must not be mistaken for one (logic review, NIT 6).
    $placeholder = '^\[[^\]]*\]\s*$'
    foreach ($pair in @(@{ N = 'Reviewer'; V = $reviewer }, @{ N = 'Owner'; V = $owner })) {
        if (-not $pair.V) {
            $script:failures += "CriticalEvidence: $Dir/human-pr-review.md has no filled '**$($pair.N)**:' line inside its Review Provenance section (team mode — $Why)"
        } elseif ($pair.V -match $placeholder) {
            $script:failures += "CriticalEvidence: $Dir/human-pr-review.md leaves '**$($pair.N)**: $($pair.V)' as a template placeholder — team mode ($Why) needs the actual name"
        }
    }
    if ($reviewer -and $owner -and $reviewer -notmatch $placeholder -and $owner -notmatch $placeholder) {
        if ($reviewer -ieq $owner) {
            $script:failures += "CriticalEvidence: $Dir/human-pr-review.md names '$reviewer' as both reviewer and owner — the human reviewer of a Critical feature MUST NOT be its owner (docs/sdlc/critical-delivery.md item 5; docs/sdlc/team-workflow.md rule 4)"
        }
    }
    if ($slice -notmatch [regex]::Escape($attestation)) {
        $script:failures += "CriticalEvidence: $Dir/human-pr-review.md is missing the verbatim attestation sentence '$attestation' from its Review Provenance section (team mode — $Why)"
    }
}

# A file as a reader sees it: HTML comments removed, closed ones first and then an
# UNTERMINATED '<!--' through to end of file — a renderer swallows the rest of the document,
# so a check that keeps reading is reading text nobody can see. Get-VisiblePlanLines applies
# the same rule line-wise for plan headers (contract M13); this returns whole text because
# the provenance parser needs to slice sections out of it.
function Get-VisibleText {
    param([string]$Path)
    $raw = "$(Get-Content -LiteralPath $Path -Raw)"
    $stripped = [regex]::Replace($raw, '(?s)<!--.*?-->', '')
    $dangling = $stripped.IndexOf('<!--')
    if ($dangling -ge 0) { $stripped = $stripped.Substring(0, $dangling) }
    return $stripped
}

function Get-ProvenanceValue {
    param([string]$Slice, [string]$Field)
    $line = $Slice -split "`n" | Where-Object { $_ -match "^\s*[-*]?\s*\*\*$Field\*\*:\s*(\S.*)$" } | Select-Object -First 1
    if ($line -match "\*\*$Field\*\*:\s*(.+)$") { return $matches[1].Trim() }
    return ''
}

# --- Gate-batching check (003 FR-008/FR-009: constitution X, Batched gates) ---
function Invoke-GateBatchingCheck {
    param([string]$Branch)
    if ($Branch -notmatch '^\d{3}-') { return }
    $dir = "specs/$Branch"
    $planPath = Join-Path $dir 'plan.md'
    if (-not (Test-Path $planPath)) { return }   # missing plan.md is StructureCheck's failure

    $line = (Get-VisiblePlanLines -PlanPath $planPath | Where-Object { $_ -match '^\*\*Gate Batching\*\*:' } | Select-Object -First 1)
    if (-not $line) { return }                   # absent line means 'none' (backward compatible)

    # Strip any trailing HTML comment (the template ships one) before parsing the value.
    $value = ($line -replace '^\*\*Gate Batching\*\*:\s*', '' -replace '<!--.*$', '').Trim()
    if ($value -eq '' -or $value -eq 'none') { return }

    if ($value -notmatch '^phases\s+(\d+)\s*[-–]\s*(\d+)$') {
        $script:failures += "GateBatching: $dir/plan.md declares '**Gate Batching**: $value' — must be 'none' or 'phases N-M' (constitution X, Batched gates)"
        return
    }
    $from = [int]$matches[1]; $to = [int]$matches[2]
    if ($to -lt $from) {
        $script:failures += "GateBatching: $dir/plan.md declares 'phases $from-$to' — the span is reversed (N must not exceed M)"
        return
    }
    $span = $to - $from + 1
    if ($span -gt $Config.MaxBatchPhases) {
        $script:failures += "GateBatching: $dir/plan.md declares 'phases $from-$to' ($span phases) — a batch covers at most $($Config.MaxBatchPhases) consecutive phases (constitution X, Batched gates)"
    }

    if ((Get-DeliveryLevel -SpecPath (Join-Path $dir 'spec.md')) -match '^Critical\b') {
        $script:failures += "GateBatching: $dir declares a gate batch on a Critical feature — Critical features never batch; every phase keeps its own human-executed gate (docs/sdlc/critical-delivery.md item 4)"
    }
}

# --- Gate-certification check (008: constitution X, CI-held certification) ---
# Legal values are constitutional constants (sync-listed): 'user-run' | 'ci-held'.
# Absent line means 'user-run' (plans from before the clause remain valid). Critical
# features MUST NOT declare ci-held (constitution X; docs/sdlc/critical-delivery.md item 4).
function Invoke-GateCertificationCheck {
    param([string]$Branch)
    if ($Branch -notmatch '^\d{3}-') { return }
    $dir = "specs/$Branch"
    $specPath = Join-Path $dir 'spec.md'
    $level = Get-DeliveryLevel -SpecPath $specPath
    # On a Micro feature the mini-spec is the declaration's home — the lane has no plan.md
    # (constitution X, Micro lane; contract M9).
    $declPath = if ($level -match '^Micro\b') { $specPath } else { Join-Path $dir 'plan.md' }
    $declName = "$dir/$(Split-Path -Leaf $declPath)"
    if (-not (Test-Path $declPath)) { return }   # a missing declaration file is StructureCheck's failure

    $line = (Get-VisiblePlanLines -PlanPath $declPath | Where-Object { $_ -match '^\*\*Gate Certification\*\*:' } | Select-Object -First 1)
    if (-not $line) { return }                   # absent line means 'user-run' (backward compatible)

    # Strip any trailing HTML comment (the template ships one) before parsing the value.
    $value = ($line -replace '^\*\*Gate Certification\*\*:\s*', '' -replace '<!--.*$', '').Trim()
    if ($value -eq '' -or $value -eq 'user-run') { return }

    if ($value -ne 'ci-held') {
        $script:failures += "GateCertification: $declName declares '**Gate Certification**: $value' — must be 'user-run' or 'ci-held' (constitution X, CI-held certification)"
        return
    }

    if ($level -match '^Critical\b') {
        $script:failures += "GateCertification: $dir declares '**Gate Certification**: ci-held' on a Critical feature — Critical features MUST NOT use CI-held certification; every certifying gate stays human-executed, locally (constitution X, CI-held certification; docs/sdlc/critical-delivery.md item 4)"
    }
}

# --- Micro-lane check (009: constitution X, Micro lane) ---
# Applies only when spec.md's VISIBLE Delivery Level is Micro (a commented-out decoy never
# sets the lane — contract M13). The bounds are constitutional constants ($Config above);
# every failure names the promotion remediation. Reads the branch's CURRENT tree state, so
# a promoted branch (level re-declared Standard) exits these rules from the promotion
# commit onward (contract M11) — scope-check separately attributes each historical commit
# against its parent's declaration.
function Invoke-MicroLaneCheck {
    param([string]$Branch, [string]$Base)
    if ($Branch -notmatch '^\d{3}-') { return }
    $dir = "specs/$Branch"
    $specPath = Join-Path $dir 'spec.md'
    if ((Get-DeliveryLevel -SpecPath $specPath) -notmatch '^Micro\b') { return }
    $promote = 'promote to Standard — expand spec.md to the full template (level re-declared Standard), add plan.md + tasks.md (Territory moves there), in a commit before the next phase commit (constitution X, Micro lane)'

    # Halfway promotion is illegal: the full set arrives together or not at all (M7).
    foreach ($f in @('plan.md', 'tasks.md')) {
        if (Test-Path (Join-Path $dir $f)) {
            $script:failures += "MicroLane: $dir/$f exists while spec.md still declares Micro — promotion is all-or-nothing; $promote"
        }
    }

    # One phase means nothing to batch (M8).
    $batchLine = (Get-VisiblePlanLines -PlanPath $specPath | Where-Object { $_ -match '^\*\*Gate Batching\*\*:' } | Select-Object -First 1)
    if ($batchLine) {
        $script:failures += "MicroLane: $dir/spec.md declares '**Gate Batching**' — a Micro feature is exactly one phase; there is nothing to batch (constitution X, Micro lane); delete the line, or $promote"
    }

    # Territory cap (M5). Same block grammar scope-check parses; entries must be literal
    # file paths — one glob or subtree entry would defeat the file cap outright.
    $tEntries = @()
    $tMarkers = 0
    $collecting = $false; $started = $false
    foreach ($line in (Get-VisiblePlanLines -PlanPath $specPath)) {
        if ($line -match '^\*\*Territory\*\*:') { $tMarkers++; $collecting = $true; $started = $false; continue }
        if (-not $collecting) { continue }
        if ($line -match '^\s*$') { if ($started) { $collecting = $false }; continue }
        if ($line -match '^\s*[-*]\s+`([^`]+)`\s*$') { $started = $true; $tEntries += $matches[1].Trim(); continue }
        $collecting = $false
    }
    if ($tMarkers -gt 1) {
        # scope-check FAILs duplicates too — kept aligned so the two scripts never diverge
        # on the same spec (phase 2 review, F7).
        $script:failures += "MicroLane: $dir/spec.md carries $tMarkers **Territory** markers — a Micro feature declares exactly one feature-global block; merge them, or $promote"
    }
    if ($tEntries.Count -gt $Config.MicroTerritoryMaxFiles) {
        $script:failures += "MicroLane: $dir/spec.md declares $($tEntries.Count) territory entries — a Micro feature's Territory covers at most $($Config.MicroTerritoryMaxFiles) files (constitution X, Micro lane); shrink the territory, or $promote"
    }
    foreach ($e in $tEntries) {
        if ($e -match '\*' -or $e -match '/\s*$') {
            $script:failures += "MicroLane: territory entry '$e' in $dir/spec.md is a glob or subtree — Micro territory entries must be literal file paths, or the $($Config.MicroTerritoryMaxFiles)-file cap is unenforceable; list the files, or $promote"
        }
    }

    # Exactly one phase (M6) + the hard size bound (M12 — PhaseSizeWarning stays a
    # non-blocking per-commit warning on every other lane). Distinct phase NUMBERS are
    # counted, not commits, so in-phase remediation commits ('phase 1 fixes: …') stay
    # legal exactly as they are on Standard features — but their lines COUNT: the bound
    # is the phase's TOTAL across every commit carrying its token, so splitting a change
    # over remediation commits cannot defeat it (phase 2 review, F1 — owner-resolved
    # 2026-09-09; constitution X wording matches).
    if (-not $Base) { return }
    $phaseNums = @{}
    $phaseTotal = 0
    $phaseCommitCount = 0
    $commits = (git rev-list --no-merges "$Base..HEAD" 2>$null) | Where-Object { $_ }
    foreach ($commit in $commits) {
        $subject = (git log -1 --format=%s $commit 2>$null)
        if ($subject -notmatch '(?i)\bphase\s+(\d+)\b') { continue }
        $phaseNums[[int]$matches[1]] = $true
        $phaseCommitCount++
        $numstat = git show --numstat --format='' $commit 2>$null
        foreach ($row in $numstat) {
            if (-not $row) { continue }
            $parts = $row -split "`t"
            if ($parts.Count -lt 3) { continue }
            if ($parts[0] -match '^\d+$') { $phaseTotal += [int]$parts[0] }
            if ($parts[1] -match '^\d+$') { $phaseTotal += [int]$parts[1] }
        }
    }
    if ($phaseTotal -gt $Config.MicroPhaseMaxLines) {
        $script:failures += "MicroLane: the phase's $phaseCommitCount commit(s) change $phaseTotal line(s) in total — a Micro phase changes at most $($Config.MicroPhaseMaxLines) lines across all its commits, a hard bound on this lane (constitution X, Micro lane); shrink the change, or $promote"
    }
    if ($phaseNums.Keys.Count -gt $Config.MicroMaxPhases) {
        $nums = ($phaseNums.Keys | Sort-Object) -join ', '
        $script:failures += "MicroLane: the branch carries commits for phases $nums — a Micro feature has exactly $($Config.MicroMaxPhases) phase; $promote"
    }
}

# --- Review-provenance check (006 FR-006: DoD gate 5, reviewer separation) ---
# Inspects only AI-review files ADDED in the branch's diff vs base (--diff-filter=A), so
# reviews shipped before the verification pack — and every adopted project's history —
# are grandfathered automatically (006 research D4). Templates are exempt.
function Invoke-ReviewProvenanceCheck {
    param([string]$Branch, [string]$Base)
    if (-not $Base) { return }
    # Runs on every recognized lane (self-scoping via the diff filter) so a review file
    # cannot be smuggled in through fix/chore/docs branches (phase 2 review, F7).
    # AR filter: rename TARGETS are inspected like additions — moving a grandfathered
    # review into the feature is not legitimate grandfathering (phase 2 review, F3).
    # quotepath=off so non-ASCII filenames cannot dodge the pattern (phase 2 review, F2).
    $rows = git -c core.quotepath=off diff --name-status --diff-filter=AR $Base HEAD 2>$null
    $candidates = @()
    foreach ($row in $rows) {
        if (-not $row) { continue }
        $parts = $row -split "`t"
        if ($parts.Count -lt 2) { continue }
        $target = if ($parts[0] -match '^R' -and $parts.Count -ge 3) { $parts[2] } else { $parts[1] }
        if ($target -match '^specs/' -and $target -notmatch '^specs/_templates/' -and $target -match 'ai-code-review[^/]*\.md$') {
            $candidates += $target
        }
    }
    $attestation = 'This reviewer did not produce the diff under review.'
    foreach ($file in $candidates) {
        if (-not (Test-Path -LiteralPath $file)) {
            $script:failures += "ReviewProvenance: $file is in the branch diff but missing from the working tree — cannot verify provenance (fail-closed)"
            continue
        }
        $content = Get-Content -LiteralPath $file -Raw
        if ($content -notmatch '(?m)^##\s+Reviewer Provenance') {
            $script:failures += "ReviewProvenance: $file has no '## Reviewer Provenance' section — the AI review must be produced by a fresh-context agent or second model and say so (DoD gate 5; specs/_templates/ai-code-review-template.md)"
            continue
        }
        # Inspect ONLY the provenance section: the template's document header also carries
        # a '**Reviewer**:' field, which must never shadow the block's (phase 2 review, F1).
        $slice = if ($content -match '(?ms)^##\s+Reviewer Provenance\s*$(.*?)(?=^##\s|\z)') { $matches[1] } else { '' }
        $reviewerLine = $slice -split "`n" | Where-Object { $_ -match '^\s*[-*]?\s*\*\*Reviewer\*\*:\s*(\S.*)$' } | Select-Object -First 1
        $reviewerValue = if ($reviewerLine -match '\*\*Reviewer\*\*:\s*(.+)$') { $matches[1].Trim() } else { '' }
        if (-not $reviewerValue) {
            $script:failures += "ReviewProvenance: $file has no filled '**Reviewer**:' line inside its Reviewer Provenance section"
        } elseif ($reviewerValue -match '^(?i)implementer\b' -or $reviewerValue -match '^\[') {
            $script:failures += "ReviewProvenance: $file attests '$reviewerValue' as reviewer — the implementing agent must not review its own diff, and template placeholders must be filled (DoD gate 5)"
        }
        if ($content -notmatch [regex]::Escape($attestation)) {
            $script:failures += "ReviewProvenance: $file is missing the verbatim attestation sentence '$attestation'"
        }
    }
}

# --- Phase-commit diff-size warning (FR-006, non-blocking) ---
function Invoke-PhaseSizeWarningCheck {
    param([string]$Branch, [string]$Base)
    if ($Branch -notmatch '^\d{3}-') { return }
    if (-not $Base) { return }
    $commits = (git rev-list "$Base..HEAD" 2>$null) | Where-Object { $_ }
    foreach ($commit in $commits) {
        $numstat = git show --numstat --format='' $commit 2>$null
        $fileCount = 0
        $lineCount = 0
        foreach ($row in $numstat) {
            if (-not $row) { continue }
            $parts = $row -split "`t"
            if ($parts.Count -lt 3) { continue }
            $fileCount++
            if ($parts[0] -match '^\d+$') { $lineCount += [int]$parts[0] }
            if ($parts[1] -match '^\d+$') { $lineCount += [int]$parts[1] }
        }
        if ($lineCount -gt $Config.PhaseWarnLines -or $fileCount -gt $Config.PhaseWarnFiles) {
            $short = $commit.Substring(0, 7)
            $script:warnings += "PhaseSizeWarning: commit $short changes $lineCount line(s) across $fileCount file(s) — exceeds the phase-size guideline ($($Config.PhaseWarnLines) lines / $($Config.PhaseWarnFiles) files, constitution X). Non-blocking; consider whether this is one coherent slice."
        }
    }
}

# --- Dispatch ---
$Branch = Get-CurrentBranch -Override $Branch
$diffBase = Get-DiffBase
$changedFiles = Get-ChangedFiles -Base $diffBase

Write-Host "enforcement-pack: branch '$Branch', diff base '$diffBase', $($changedFiles.Count) changed file(s)"

if ($Branch -in @('main', 'master')) {
    Write-Host "enforcement-pack: '$Branch' is the trunk, not a feature/fix/chore/docs branch — no scripted checks apply"
} elseif ($Branch -match '^\d{3}-') {
    Invoke-StructureCheck -Branch $Branch
    Invoke-MicroLaneCheck -Branch $Branch -Base $diffBase
    Invoke-CriticalEvidenceCheck -Branch $Branch
    Invoke-GateBatchingCheck -Branch $Branch
    Invoke-GateCertificationCheck -Branch $Branch
    Invoke-ReviewProvenanceCheck -Branch $Branch -Base $diffBase
    Invoke-PhaseSizeWarningCheck -Branch $Branch -Base $diffBase
} elseif ($Branch -match '^(fix|chore)/') {
    Invoke-LiteAndAbuseCheck -Branch $Branch -ChangedFiles $changedFiles
    Invoke-ReviewProvenanceCheck -Branch $Branch -Base $diffBase
} elseif ($Branch -match '^docs/') {
    Invoke-ReviewProvenanceCheck -Branch $Branch -Base $diffBase
    Write-Host "enforcement-pack: '$Branch' is the lightweight docs/ lane — review-provenance is the only scripted check that applies"
} else {
    $script:failures += "Branch naming: '$Branch' does not match a known taxonomy (NNN-*, fix/*, chore/*, docs/*) — see docs/sdlc/branch-strategy.md"
}

foreach ($w in $warnings) { Write-Host "WARNING: $w" }
if ($failures.Count -gt 0) {
    Write-Host "enforcement-pack: FAIL ($($failures.Count) issue(s)):"
    foreach ($f in $failures) { Write-Host "  - $f" }
    exit 1
}
Write-Host 'enforcement-pack: OK'
exit 0

} finally {
    Pop-Location
}
