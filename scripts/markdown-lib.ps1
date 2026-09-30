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
    armed and hid everything after it, in both consumers. Spans now pair within their
    paragraph, never beyond it (Convert-CodeSpanMarkers says exactly what is modelled). Still
    not modelled: a '<!--' opened mid-line in prose that runs on into later lines. That is the
    comment model's business; build-digests reports a marker it passes over inside one.

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

# Disarm comment markers inside the inline code spans of ONE piece of text: a line, or the
# lines of one paragraph joined with "`n". CommonMark pairs a run of N backticks with the next
# run of EXACTLY N, and a backslash-escaped backtick is literal and delimits nothing (K1's
# second trigger). A run with no partner in the text opens no span: an unrecognised span
# leaves its markers armed, which HIDES text rather than revealing it — the safe direction for
# a check whose job is to refuse an invisible record. A backtick run cannot hold a newline, so
# joining lines creates no false run (016 D2).
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

# Disarm comment markers inside the inline code spans of a whole document (016 D1). Returns
# the same number of lines, each the same length as its input, so a caller may index the
# result by line and take substrings of it by the raw line's offsets.
#
# A code span pairs within its PARAGRAPH, never beyond it (016 FR-003): a span that wraps
# onto the next line of its paragraph hides nothing, and a stray backtick cannot pair into a
# later block and disarm a real comment there (014's H1). What is modelled:
#   - A paragraph is a run of plain lines. It ends at a blank line and at any line that
#     begins a block. Block starts are read generously (016 D3): a heading, list item, block
#     quote, table row or HTML tag at any indentation, a thematic break or setext underline.
#     Every extra break moves the result toward per-line pairing, the reviewed baseline.
#   - Lines that join no paragraph keep per-line pairing, exactly as before 016: fenced
#     lines; an HTML comment block, from a line whose first text is '<!--' through the first
#     line whose raw text holds '-->' after the opener (016 D4); a line starting with an HTML
#     tag and the lines after it up to a blank line; a heading, thematic break, setext
#     underline or table row; and an indented line that does not continue a paragraph.
# What is NOT modelled: a '<!--' opened mid-line in prose that runs on into later lines. That
# is the comment model's business, not this function's, and build-digests reports a marker it
# passes over inside such a comment (016 D8).
function Convert-CodeSpanMarkers {
    param([string[]]$Lines)
    $out = [string[]]::new($Lines.Count)
    [Array]::Copy([string[]]$Lines, $out, $Lines.Count)
    # A document with no backtick or no marker has nothing to disarm (016 R5).
    $all = $Lines -join "`n"
    if ($all -notmatch '`') { return ,$out }
    if ($all -notmatch '<!--' -and $all -notmatch '-->') { return ,$out }

    $fenced = Get-FencedLineMap -Lines $Lines
    $para = [System.Collections.Generic.List[int]]::new()
    # Pair the pending paragraph's spans across its lines, then split it back in place.
    $flush = {
        if ($para.Count -gt 1) {
            $joined = ($para | ForEach-Object { $Lines[$_] }) -join "`n"
            $parts = (Convert-SpanText -Text $joined) -split "`n"
            for ($p = 0; $p -lt $para.Count; $p++) { $out[$para[$p]] = $parts[$p] }
        } elseif ($para.Count -eq 1) {
            $out[$para[0]] = Convert-SpanText -Text $Lines[$para[0]]
        }
        $para.Clear()
    }

    $inCommentBlock = $false
    $inHtmlBlock = $false
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        $line = $Lines[$i]
        # An HTML comment block: its lines join no paragraph and keep per-line pairing (D4).
        if (-not $inCommentBlock) {
            $m = [regex]::Match($line, '^ {0,3}<!--')
            if ($m.Success -and -not $fenced[$i]) {
                . $flush
                $inCommentBlock = $line.IndexOf('-->', $m.Index + $m.Length) -lt 0
                $out[$i] = Convert-SpanText -Text $line
                continue
            }
        } else {
            if ($line.IndexOf('-->') -ge 0) { $inCommentBlock = $false }
            $out[$i] = Convert-SpanText -Text $line
            continue
        }
        if ($fenced[$i]) {
            . $flush
            $out[$i] = Convert-SpanText -Text $line
            continue
        }
        if ($line -match '^\s*$') {
            . $flush
            $inHtmlBlock = $false
            continue
        }
        # Raw HTML runs to the next blank line, and spans do not apply inside it.
        if ($inHtmlBlock -or $line -match '^\s*</?[A-Za-z!?]') {
            . $flush
            $inHtmlBlock = $true
            $out[$i] = Convert-SpanText -Text $line
            continue
        }
        # Blocks of one line: heading, thematic break, setext underline, table row.
        if ($line -match '^\s*#{1,6}(\s|$)' -or
            $line -match '^\s*([-*_])(\s*\1){2,}\s*$' -or
            $line -match '^\s*(=+|-+)\s*$' -or
            $line -match '^\s*\|') {
            . $flush
            $out[$i] = Convert-SpanText -Text $line
            continue
        }
        # A list item or block quote opens a new paragraph that plain lines may continue.
        if ($line -match '^\s*([-*+]|\d{1,9}[.)])(\s|$)' -or $line -match '^\s*>') {
            . $flush
            $para.Add($i)
            continue
        }
        # An indented line that continues nothing is indented code, or content whose
        # container this model does not track: per-line, the baseline.
        if ($para.Count -eq 0 -and $line -match '^( {4}|\t)') {
            $out[$i] = Convert-SpanText -Text $line
            continue
        }
        $para.Add($i)
    }
    . $flush
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
