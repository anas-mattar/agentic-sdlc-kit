<#
.SYNOPSIS
    How Markdown renders a comment marker: shared by every kit script that reads a document.

.DESCRIPTION
    Feature 014 learned this the expensive way. A '<!--' inside a fenced block or an inline
    code span is LITERAL TEXT, not a comment opener, and a check that misses the distinction
    reads a document nobody can see: 014's B7 truncated tasks.md from the line that quoted the
    syntax onward, hiding every approver record after it, and its first fix (a '(?s)```.*?```'
    sweep over the whole blob) re-paired fence runs across line starts and put a REAL comment
    inside a region the check called code — H1, reopened by its own fix.

    Feature 015 found the same blindness a third time, in build-digests.ps1 (GAP-025): one
    backticked '<!--' in prose opened a phantom comment that swallowed every digest marker
    after it, so the generator wrote a digest missing real rules and reported OK.

    Feature 016 found the fix for both was per-line (GAP-028): a code span that wrapped onto
    the next line of its paragraph looked like an unpaired backtick, so its '<!--' stayed
    armed and hid everything after it, in both consumers. Its first two fixes paired spans
    across the lines of a paragraph, and two review rounds showed that pairing can disarm a
    REAL comment whenever the scan misreads a backtick — and Markdown has too many ways to
    hide one (autolinks, raw HTML, link titles, backslashes before a closer, containers) for a
    list of exceptions to be complete. So spans are still paired one line at a time, and the
    wrapped span is handled from the other side: an opener that no renderer can read as a
    comment is disarmed (Convert-CodeSpanMarkers says exactly when). Still not modelled: a
    '-->' inside a span that wraps, and a '<!--' opened mid-line in prose that runs on into
    later lines. That is the comment model's business; 016's phase 2 is scoped to make
    build-digests report a marker it passes over inside one.

    Three of these functions were enforcement-pack.ps1's. They live here because the next
    script to read a Markdown document should not be the fourth to learn it. Same reason
    scripts/scope-lib.ps1 exists for the two scope graders: one implementation cannot drift
    from itself.

.NOTES
    Not a runnable script — dot-source it:
        . (Join-Path $PSScriptRoot 'markdown-lib.ps1')

    Every function here is pure: no git, no file system, no working directory.
#>

# Disarm comment markers in one string. Both substitutions preserve length, which is what
# lets Convert-SpanText patch text in place by offset, and Convert-CodeSpanMarkers hand back
# lines of their input's lengths.
function Disable-CommentMarkers {
    param([string]$Text)
    return ($Text -replace '<!--', '<!@@') -replace '-->', '@@>'
}

# Disarm comment markers inside the inline code spans of ONE line. CommonMark pairs a run of
# N backticks with the next run of EXACTLY N, and a backslash-escaped backtick is literal and
# delimits nothing (K1's second trigger). A run with no partner on the line opens no span:
# an unrecognised span leaves its markers armed, which HIDES text rather than revealing it —
# the safe direction for a check whose job is to refuse an invisible record.
function Convert-SpanText {
    param([string]$Text)
    # Nothing to disarm, or nothing to disarm it with: the overwhelming majority of text, and
    # the reason this is a string scan rather than a character walk (a per-character loop over
    # every line of every graded blob cost ~9x the whole check's runtime — 014 SC-006).
    if ($Text -notmatch '`') { return $Text }
    if ($Text -notmatch '<!--' -and $Text -notmatch '-->') { return $Text }
    # Backtick runs, skipping any run a backslash escapes — '\`' is a literal backtick to
    # CommonMark and delimits nothing (K1's second trigger).
    $runs = @([regex]::Matches($Text, '(?<!\\)`+') | ForEach-Object { @{ Start = $_.Index; Len = $_.Length } })
    if ($runs.Count -lt 2) { return $Text }
    $result = $Text
    $r = 0
    while ($r -lt $runs.Count - 1) {
        $open = $runs[$r]
        $closeIdx = -1
        for ($k = $r + 1; $k -lt $runs.Count; $k++) {
            if ($runs[$k].Len -eq $open.Len) { $closeIdx = $k; break }
        }
        if ($closeIdx -lt 0) { $r++; continue }
        $from = $open.Start + $open.Len
        $len  = $runs[$closeIdx].Start - $from
        if ($len -gt 0) {
            $result = $result.Substring(0, $from) +
                      (Disable-CommentMarkers -Text $result.Substring($from, $len)) +
                      $result.Substring($from + $len)
        }
        $r = $closeIdx + 1
    }
    return $result
}

# Disarm comment markers inside the inline code spans of a whole document, and disarm every
# comment opener that no renderer can read as a comment (016 D1, D10). Returns the same number
# of lines, each the same length as its input, so a caller may index the result by line and
# take substrings of it by the raw line's offsets.
#
# The result is the per-line pairing every line had before 016 (Convert-SpanText), plus one
# change: a '<!--' that result left armed is disarmed when it CANNOT be a comment. Such an
# opener sits inline, and no '-->' follows it before the next blank line. An inline comment
# cannot cross a blank line, so no renderer hides anything behind it. That is GAP-028's
# wrapped span: its quoted opener has no closer in its paragraph. The change only ever
# reveals text a reader sees, so the result is never less strict than the per-line reading
# about a real comment. "Inline" excludes:
#   - fenced lines (their markers are the caller's, and literal);
#   - raw HTML blocks, an HTML comment block included, found on the raw text after any list
#     or block-quote markers and run to their CommonMark end: a pre, script, style or
#     textarea block at its closing tag, a comment at its closer, a processing instruction at
#     '?>', a declaration at '>', CDATA at ']]>', any other tag at a blank line. Raw HTML
#     passes through to the browser, where a comment DOES cross a blank line.
# Line starts are read generously: any line whose first text after container markers is a
# tag counts as a block start, so more lines stay on the per-line result, never fewer.
# What is NOT modelled, and keeps the per-line result: a code span that wraps is not
# recognised, so a '-->' inside one stays armed, and so does the '<!--' of one whose
# paragraph holds a '-->' later.
function Convert-CodeSpanMarkers {
    param([string[]]$Lines)
    $out = [string[]]::new($Lines.Count)
    for ($i = 0; $i -lt $Lines.Count; $i++) { $out[$i] = Convert-SpanText -Text $Lines[$i] }
    # No opener anywhere means nothing more to disarm (016 R5).
    if (($Lines -join "`n") -notmatch '<!--') { return ,$out }

    $fenced = Get-FencedLineMap -Lines $Lines
    # Container markers before a block's first text: indentation, list markers, block quotes.
    $container = '^(?:[ \t]*(?:[-*+]|\d{1,9}[.)])(?=[ \t]|$)|[ \t]*>)*[ \t]*'
    # The end of the raw HTML block being read: $null outside one, 'blank' for a block that
    # ends at a blank line, otherwise the pattern of the line that ends it.
    $htmlEnd = $null
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        $raw = $Lines[$i]
        $blank = $raw -match '^\s*$'
        $inHtml = $false
        if ($htmlEnd) {
            $inHtml = $true
            if ($htmlEnd -eq 'blank') { if ($blank) { $htmlEnd = $null } }
            elseif ($raw -match $htmlEnd) { $htmlEnd = $null }
        } elseif (-not $fenced[$i]) {
            $body = [regex]::Replace($raw, $container, '', 1)
            if ($body -match '^<[A-Za-z/?!]') {
                $inHtml = $true
                $end = if ($body -match '(?i)^<(pre|script|style|textarea)(\s|>|$)') { '(?i)</(pre|script|style|textarea)>' }
                       elseif ($body -match '^<!--') { '-->' }
                       elseif ($body -match '^<\?') { '\?>' }
                       elseif ($body -match '^<!\[CDATA\[') { '\]\]>' }
                       elseif ($body -match '^<![A-Za-z]') { '>' }
                       else { 'blank' }
                # A block whose end is on its own opening line is over already.
                if ($end -ne 'blank' -and $body -match $end) { $end = $null }
                $htmlEnd = $end
            }
        }
        if ($inHtml -or $fenced[$i] -or $blank) { continue }
        # Each opener the per-line result left armed: disarmed only if nothing after it, up to
        # the next blank line, could close it. The search reads the RAW text, so a closer the
        # per-line pairing disarmed still counts, which keeps the opener armed.
        $from = 0
        while (($p = $out[$i].IndexOf('<!--', $from)) -ge 0) {
            $from = $p + 4
            # From the opener's third character, so '<!-->' and '<!--->' close themselves.
            $closed = $raw.IndexOf('-->', $p + 2) -ge 0
            for ($k = $i + 1; -not $closed -and $k -lt $Lines.Count; $k++) {
                if ($Lines[$k] -match '^\s*$') { break }
                if ($Lines[$k].IndexOf('-->') -ge 0) { $closed = $true }
            }
            if (-not $closed) { $out[$i] = $out[$i].Substring(0, $p) + '<!@@' + $out[$i].Substring($p + 4) }
        }
    }
    return ,$out
}

# True for each line that Markdown renders as CODE rather than as content: the lines of a
# fenced block, fences included. A fence OPENS on a line whose first non-space run (at most
# three spaces of indent) is three or more backticks or tildes, and CLOSES on a later line
# whose run is the same character and at least as long — CommonMark's rule, line by line.
# An unclosed fence runs to the end of the document, exactly as a renderer treats it.
function Get-FencedLineMap {
    param([string[]]$Lines)
    $map = New-Object 'bool[]' $Lines.Count
    # A document with no fence run at all has no fenced lines, and most do not.
    if (($Lines -join "`n") -notmatch '(?m)^ {0,3}(`{3,}|~{3,})') { return $map }
    $fenceChar = ''
    $fenceLen = 0
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        $m = [regex]::Match($Lines[$i], '^ {0,3}(`{3,}|~{3,})')
        if ($fenceLen -gt 0) {
            $map[$i] = $true
            if ($m.Success -and $m.Groups[1].Value[0] -eq $fenceChar -and $m.Groups[1].Value.Length -ge $fenceLen) {
                $fenceChar = ''; $fenceLen = 0
            }
            continue
        }
        if ($m.Success) {
            $fenceChar = $m.Groups[1].Value[0]
            $fenceLen = $m.Groups[1].Value.Length
            $map[$i] = $true
        }
    }
    return $map
}
