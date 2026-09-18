<#
.SYNOPSIS
    Launch one kit script in this child process with UTF-8 stdout.

.DESCRIPTION
    Harness.psm1 runs every case as a child process. It cannot invoke the script under test
    directly, because of what Windows does to the output on the way out:

        [Console]::OutputEncoding in a fresh pwsh on Windows is the console code page
        (ibm437 on this machine). Redirect that child's stdout and every non-ASCII character
        is TRANSLITERATED AS IT IS WRITTEN — an em dash becomes a hyphen before the parent
        ever sees a byte. No reader-side encoding can recover it; the data is already gone.

    The kit's messages are full of em dashes, so a harness that cannot assert on one can only
    assert on the ASCII half of a message. That is the phase 1 review's F1 shape again — a
    check that sees part of what it claims to see — and it stayed invisible through phase 1
    only because no phase 1 expectation happened to contain a non-ASCII character.

    So the encoding is set HERE, inside the child, before the script under test runs.

    Arguments arrive as a flat vector, and PowerShell array splatting is positional: '@rest'
    would pass '-Check' as a VALUE, not as a switch (measured, not assumed). The call is
    therefore reconstructed: a token that looks like a parameter name (-Foo) is passed as one,
    and every other token is single-quoted so that spaces in a fixture's temporary path
    survive. A value that legitimately begins with '-' would need quoting support here; no
    case needs one today, and this comment is where to add it.

    This file imports nothing from the kit (FR-006). It is not a test and not a rule.
#>

[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
$OutputEncoding = [Console]::OutputEncoding

if ($args.Count -lt 1) { Write-Error 'RunChild.ps1: no script to run'; exit 64 }

$target = $args[0]
$rest = if ($args.Count -gt 1) { @($args[1..($args.Count - 1)]) } else { @() }

$tokens = @("& '" + ($target -replace "'", "''") + "'")
foreach ($t in $rest) {
    if ($t -match '^-[A-Za-z]') { $tokens += $t }
    else { $tokens += "'" + ($t -replace "'", "''") + "'" }
}

& ([scriptblock]::Create($tokens -join ' '))
exit $LASTEXITCODE
