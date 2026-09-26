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
# The same principle, for decoration rather than encoding: pwsh wraps a Write-Warning (and an
# error record) in ANSI colour escapes on the way to the host, redirected or not, and whether it
# does is the host's business - not the script's output. TERR-012 is the first case to assert
# a Write-Warning line (phase 6 review, F3); without this its expectation would have had to
# carry escape bytes. Nothing is stripped after capture: the child is asked to write plain text.
if ($PSStyle) { $PSStyle.OutputRendering = 'PlainText' }

if ($args.Count -lt 1) { Write-Error 'RunChild.ps1: no script to run'; exit 64 }

$target = $args[0]
$rest = if ($args.Count -gt 1) { @($args[1..($args.Count - 1)]) } else { @() }

$tokens = @("& '" + ($target -replace "'", "''") + "'")
foreach ($t in $rest) {
    if ($t -match '^-[A-Za-z]') { $tokens += $t }
    else { $tokens += "'" + ($t -replace "'", "''") + "'" }
}

# A script that never RAN must never look like a script that ran and passed. 'exit $LASTEXITCODE'
# alone did exactly that: a parameter-binding failure ('-Root -Check', where the switch is eaten
# as Root's argument) writes an error and leaves $LASTEXITCODE untouched, so the launcher exited
# 0 and a fixture expecting 0 went green against a script that printed nothing but an error.
# Found by the phase 2 fresh-context review, F1, and reproduced against the real
# build-digests.ps1 before this fix.
#
# So success is tracked separately from the exit code. $? distinguishes the three shapes that
# matter, measured rather than assumed:
#
#   ran, returned normally         $? True,  $LASTEXITCODE 0   -> 0
#   ran, called exit 1             $? True,  $LASTEXITCODE 1   -> 1   (a real FAIL verdict)
#   never ran (binding failure)    $? False, $LASTEXITCODE 0   -> 97
#   threw                          caught                      -> 97
#
# 97 is not a verdict any kit script emits, so no case's expected exit code can collide with it,
# and the printed line lands in the captured output as well — a case fails on both channels.
$global:LASTEXITCODE = 0
$ran = $true
try {
    & ([scriptblock]::Create($tokens -join ' '))
    $ran = $?
} catch {
    Write-Host "RunChild: the script under test threw before returning a verdict: $($_.Exception.Message)"
    $ran = $false
}
if (-not $ran -and $LASTEXITCODE -eq 0) {
    Write-Host "RunChild: $target did not run to a verdict (see the error above) — this is the launcher reporting, not the script"
    exit 97
}
exit $LASTEXITCODE
