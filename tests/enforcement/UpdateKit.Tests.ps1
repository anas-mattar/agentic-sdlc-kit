<#
    scripts/update-kit.ps1's surgical report and the recorded kit commit (feature 033, GAP-039, plan P5).

    The surgical pass reads the log of each surgical file from the project's recorded kit commit to the kit's HEAD. When the recorded commit
    is not a commit of the kit clone, `git log` failed with its errors discarded, the list was empty, and the file was reported as
    unchanged: the run could end `Result: up to date`, exit 0, and a real run then advanced `.kit-version` past a report that was never
    made. The fixture harness has no update-kit case (the script is not a grading script), so this file builds a small kit and a target
    with plain git, in a temporary directory, and runs the script on them. It does not depend on the depth of the CI checkout, which is
    exactly the state the feature reports.

    The kit has one verbatim file and one surgical file and two commits, the second changing the surgical file; the target has the
    kit-integrity essentials, the verbatim file at the kit's current content (so no conflict can mask the surgical section) and the
    surgical file filled in by the project.
#>

BeforeAll {
    $script:UpdateKit = (Resolve-Path (Join-Path $PSScriptRoot '../../scripts/update-kit.ps1')).Path
    $script:Root = Join-Path ([IO.Path]::GetTempPath()) ("kit-updatekit-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
    New-Item -ItemType Directory -Path $script:Root -Force | Out-Null

    function script:Invoke-RepoGit {
        param([string]$Repo, [string[]]$Arguments)
        $out = & git -C $Repo @Arguments 2>&1
        if ($LASTEXITCODE -ne 0) { throw "git -C $Repo $($Arguments -join ' ') failed: $out" }
        return $out
    }
    function script:New-GitRepo {
        param([string]$Path)
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Invoke-RepoGit $Path @('init', '--quiet', '-b', 'main') | Out-Null
        Invoke-RepoGit $Path @('config', 'user.email', 'fixture@example.invalid') | Out-Null
        Invoke-RepoGit $Path @('config', 'user.name', 'fixture') | Out-Null
        Invoke-RepoGit $Path @('config', 'core.autocrlf', 'false') | Out-Null
    }
    function script:Write-Lf {
        param([string]$Path, [string]$Text)
        New-Item -ItemType Directory -Path (Split-Path $Path) -Force | Out-Null
        [IO.File]::WriteAllText($Path, $Text)
    }

    # The kit: two commits, the second changing the surgical file.
    $script:Kit = Join-Path $script:Root 'kit'
    New-GitRepo $script:Kit
    Write-Lf (Join-Path $script:Kit '.specify/memory/constitution.md') "# Constitution`n**Version**: 0.9.0`n"
    Write-Lf (Join-Path $script:Kit 'docs/a.md') "verbatim v1`n"
    Write-Lf (Join-Path $script:Kit 'docs/sdlc/gate-command.md') "gate v1`n"
    Write-Lf (Join-Path $script:Kit 'kit-manifest.json') '{ "entries": [ { "path": "docs/a.md", "class": "verbatim" }, { "path": "docs/sdlc/gate-command.md", "class": "surgical" } ] }'
    Invoke-RepoGit $script:Kit @('add', '-A') | Out-Null
    Invoke-RepoGit $script:Kit @('commit', '--quiet', '-m', 'kit one') | Out-Null
    $script:KitFirst = ((Invoke-RepoGit $script:Kit @('rev-parse', 'HEAD')) -join '').Trim()
    Write-Lf (Join-Path $script:Kit 'docs/sdlc/gate-command.md') "gate v2`n"
    Invoke-RepoGit $script:Kit @('add', '-A') | Out-Null
    Invoke-RepoGit $script:Kit @('commit', '--quiet', '-m', 'kit two: gate command') | Out-Null
    $script:KitHead = ((Invoke-RepoGit $script:Kit @('rev-parse', 'HEAD')) -join '').Trim()
    $script:Unknown = '0000000000000000000000000000000000000001'

    $script:Counter = 0
    # A fresh target per case. -Recorded: a sha for a committed .kit-version, 'absent' for none, 'malformed' for one that is not JSON.
    function script:New-Target {
        param([string]$Recorded)
        $script:Counter++
        $target = Join-Path $script:Root ("target-" + $script:Counter)
        New-GitRepo $target
        $essentials = 'CLAUDE.md', 'AGENTS.md', '.specify/memory/constitution.md', '.specify/templates/t.md', '.specify/scripts/s.ps1',
            '.claude/commands/c.md', 'docs/sdlc/definition-of-done.md', 'docs/sdlc/flow.md', 'docs/sdlc/review-process.md',
            'docs/sdlc/gate-command.md', 'docs/rulebooks/r.md', 'specs/_templates/t.md', 'scripts/claim-feature.ps1', 'scripts/territory-check.ps1'
        foreach ($e in $essentials) { Write-Lf (Join-Path $target $e) "x`n" }
        Write-Lf (Join-Path $target 'docs/a.md') "verbatim v1`n"
        Write-Lf (Join-Path $target 'docs/sdlc/gate-command.md') "my project's gate`n"
        if ($Recorded -eq 'malformed') { Write-Lf (Join-Path $target '.kit-version') '{ not json' }
        elseif ($Recorded -ne 'absent') {
            Write-Lf (Join-Path $target '.kit-version') ('{ "kitVersion": "0.9.0", "kitCommit": "' + $Recorded + '", "updatedOn": "2026-01-01" }')
        }
        Invoke-RepoGit $target @('add', '-A') | Out-Null
        Invoke-RepoGit $target @('commit', '--quiet', '-m', 'adopted') | Out-Null
        return $target
    }
    function script:Invoke-UpdateKit {
        param([string]$Target, [string[]]$Arguments)
        $raw = & pwsh -NoProfile -File $script:UpdateKit -Kit $script:Kit -Target $Target @Arguments 2>&1
        $code = $LASTEXITCODE
        $text = (($raw | ForEach-Object { "$_" }) -join "`n") -replace "\x1b\[[0-9;]*m", ''
        return [pscustomobject]@{ Exit = $code; Text = $text }
    }
}

AfterAll {
    if ($script:Root -and (Test-Path $script:Root)) { Remove-Item $script:Root -Recurse -Force -ErrorAction SilentlyContinue }
}

Describe 'update-kit.ps1 and the recorded kit commit (feature 033, plan P5)' {
    Context 'states that print the same before and after (FR-002)' {
        It 'a recorded commit the kit clone has: the surgical file is listed with the upstream commit, exit 2' {
            $r = Invoke-UpdateKit (New-Target $script:KitFirst) @('-DryRun')
            $r.Text | Should -Match 'Surgical - upstream changes, never applied \(1\):'
            $r.Text | Should -Match 'docs/sdlc/gate-command\.md'
            $r.Text | Should -Match 'kit two: gate command'
            $r.Text | Should -Match 'upstream commits since your recorded kit version'
            $r.Text | Should -Not -Match 'NOTE: the recorded kit commit'
            $r.Exit | Should -Be 2
        }

        It 'a recorded commit equal to the kit''s HEAD: nothing upstream, up to date, exit 0' {
            $r = Invoke-UpdateKit (New-Target $script:KitHead) @('-DryRun')
            $r.Text | Should -Match 'Result: up to date'
            $r.Text | Should -Not -Match 'Surgical'
            $r.Exit | Should -Be 0
        }

        It 'no .kit-version: every surgical file is listed with no baseline, and no NOTE about a recorded commit, exit 2' {
            $r = Invoke-UpdateKit (New-Target 'absent') @('-DryRun')
            $r.Text | Should -Match 'Surgical - upstream changes, never applied \(1\):'
            $r.Text | Should -Match 'no baseline.{1,8}review all'
            $r.Text | Should -Not -Match 'NOTE: the recorded kit commit'
            $r.Exit | Should -Be 2
        }

        It 'a .kit-version that is not JSON is read as absent: the same report, exit 2' {
            $r = Invoke-UpdateKit (New-Target 'malformed') @('-DryRun')
            $r.Text | Should -Match 'Surgical - upstream changes, never applied \(1\):'
            $r.Text | Should -Match 'no baseline.{1,8}review all'
            $r.Text | Should -Not -Match 'NOTE: the recorded kit commit'
            $r.Exit | Should -Be 2
        }
    }

    Context 'a recorded commit the kit clone does not have (FR-001, FR-004)' {
        It 'a dry run lists the surgical file with no baseline and names the unknown commit, exit 2: not "up to date"' {
            $r = Invoke-UpdateKit (New-Target $script:Unknown) @('-DryRun')
            $r.Text | Should -Not -Match 'Result: up to date'
            $r.Text | Should -Match 'Surgical - upstream changes, never applied \(1\):'
            $r.Text | Should -Match 'docs/sdlc/gate-command\.md'
            $r.Text | Should -Match 'no baseline.{1,8}review all'
            $r.Text | Should -Match ('NOTE: the recorded kit commit ' + $script:Unknown + ' is not in the kit clone')
            $r.Exit | Should -Be 2
        }

        It 'a real run reports the same, advances .kit-version to the kit''s HEAD, and says the report is delivered once' {
            $target = New-Target $script:Unknown
            $r = Invoke-UpdateKit $target @()
            $r.Text | Should -Match 'Surgical - upstream changes, never applied \(1\):'
            $r.Text | Should -Match ('NOTE: the recorded kit commit ' + $script:Unknown + ' is not in the kit clone')
            $r.Text | Should -Match 'delivered once'
            $r.Exit | Should -Be 2
            (Get-Content (Join-Path $target '.kit-version') -Raw | ConvertFrom-Json).kitCommit | Should -Be $script:KitHead
        }

        It '-Json keeps its keys and carries the surgical entry; the cause line is text mode only' {
            $r = Invoke-UpdateKit (New-Target $script:Unknown) @('-DryRun', '-Json')
            $j = $r.Text | ConvertFrom-Json
            ($j.PSObject.Properties.Name) | Should -Be @('applied', 'surgical', 'conflicts', 'dryRun', 'result')
            @($j.surgical).Count | Should -Be 1
            $j.surgical[0].Path | Should -Be 'docs/sdlc/gate-command.md'
            $j.surgical[0].Note | Should -Match 'no baseline.{1,8}review all'
            $j.result | Should -Not -Be 'up to date'
            $r.Text | Should -Not -Match 'NOTE:'
            $r.Exit | Should -Be 2
        }
    }
}
