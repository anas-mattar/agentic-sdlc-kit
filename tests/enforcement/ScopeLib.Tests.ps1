<#
    scripts/scope-lib.ps1's changed-file read, tested directly (feature 032, GAP-038, plan P1).

    The scope check learned what a commit touched from `git show --name-status` with the error stream discarded, so a commit git
    could not read looked exactly like a commit that touches nothing: an empty list. Get-CommitStatusRows now reports the failure on
    a channel of its own, $script:CommitReadFailed, and PowerShell unrolls an empty array to $null, so a return value could not
    carry it. The fixtures (SCOPE-028 to SCOPE-030) prove what scope-check.ps1 prints; these tests pin the function they rest on,
    in a throwaway repository built here with plain git, so a change to the function that clears the flag at the wrong moment, or
    reads $LASTEXITCODE one statement late, is caught at its source.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot '../../scripts/scope-lib.ps1')

    $script:Repo = Join-Path ([IO.Path]::GetTempPath()) ("kit-scopelib-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
    New-Item -ItemType Directory -Path $script:Repo -Force | Out-Null
    function script:Invoke-RepoGit {
        param([string[]]$Arguments)
        $out = & git -C $script:Repo @Arguments 2>&1
        if ($LASTEXITCODE -ne 0) { throw "git $($Arguments -join ' ') failed: $out" }
        return $out
    }
    Invoke-RepoGit @('init', '--quiet', '-b', 'main') | Out-Null
    Invoke-RepoGit @('config', 'user.email', 'fixture@example.invalid') | Out-Null
    Invoke-RepoGit @('config', 'user.name', 'fixture') | Out-Null
    Invoke-RepoGit @('config', 'core.autocrlf', 'false') | Out-Null
    [IO.File]::WriteAllText((Join-Path $script:Repo 'a.txt'), "one`n")
    Invoke-RepoGit @('add', '-A') | Out-Null
    Invoke-RepoGit @('commit', '--quiet', '-m', 'first') | Out-Null
    $script:Readable = ((Invoke-RepoGit @('rev-parse', 'HEAD')) -join '').Trim()
    Invoke-RepoGit @('commit', '--quiet', '--allow-empty', '-m', 'empty') | Out-Null
    $script:Empty = ((Invoke-RepoGit @('rev-parse', 'HEAD')) -join '').Trim()
    [IO.File]::WriteAllText((Join-Path $script:Repo 'b.txt'), "two`n")
    Invoke-RepoGit @('add', '-A') | Out-Null
    Invoke-RepoGit @('commit', '--quiet', '-m', 'third') | Out-Null
    $script:Damaged = ((Invoke-RepoGit @('rev-parse', 'HEAD')) -join '').Trim()
    # The damage the harness's truncateCommit makes: the commit's tree object, cut to half its bytes.
    $tree = ((Invoke-RepoGit @('rev-parse', 'HEAD^{tree}')) -join '').Trim()
    $object = Join-Path $script:Repo (".git/objects/{0}/{1}" -f $tree.Substring(0, 2), $tree.Substring(2))
    $item = Get-Item -LiteralPath $object -Force
    $item.Attributes = $item.Attributes -band -bnot [IO.FileAttributes]::ReadOnly
    $bytes = [IO.File]::ReadAllBytes($object)
    [IO.File]::WriteAllBytes($object, $bytes[0..([Math]::Max(0, [int]($bytes.Length / 2)))])
    Push-Location $script:Repo
}

AfterAll {
    Pop-Location
    if ($script:Repo -and (Test-Path $script:Repo)) { Remove-Item $script:Repo -Recurse -Force -ErrorAction SilentlyContinue }
}

Describe 'Get-CommitStatusRows (feature 032, plan P1)' {
    It 'returns the rows of a readable commit with the failure flag clear' {
        $rows = @(Get-CommitStatusRows -Sha $script:Readable)
        $script:CommitReadFailed | Should -BeFalse
        $rows.Count | Should -Be 1
        $rows[0] | Should -Match '^A\s+a\.txt$'
    }

    It 'returns no rows for a readable empty commit and leaves the flag clear: an empty list git returned is not a failed read' {
        $rows = @(Get-CommitStatusRows -Sha $script:Empty)
        $script:CommitReadFailed | Should -BeFalse
        $rows.Count | Should -Be 0
    }

    It 'returns no rows for a commit whose tree git cannot read and sets the flag' {
        $rows = @(Get-CommitStatusRows -Sha $script:Damaged)
        $script:CommitReadFailed | Should -BeTrue
        $rows.Count | Should -Be 0
    }

    It 'clears the flag on the next call, so a failure is never carried into a later read' {
        Get-CommitStatusRows -Sha $script:Damaged | Out-Null
        $script:CommitReadFailed | Should -BeTrue
        Get-CommitStatusRows -Sha $script:Readable | Out-Null
        $script:CommitReadFailed | Should -BeFalse
    }

    It 'is the flag Get-CommitPaths leaves behind: no paths and the flag set for the damaged commit, the path and the flag clear for a readable one' {
        $paths = @(Get-CommitPaths -Sha $script:Damaged)
        $script:CommitReadFailed | Should -BeTrue
        $paths.Count | Should -Be 0
        $paths = @(Get-CommitPaths -Sha $script:Readable)
        $script:CommitReadFailed | Should -BeFalse
        $paths | Should -Be @('a.txt')
    }
}
