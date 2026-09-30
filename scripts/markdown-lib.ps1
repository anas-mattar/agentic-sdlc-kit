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
    paragraph, never beyond it, and only where pairing further than one line cannot disarm a
    real comment (Convert-CodeSpanMarkers says exactly what is modelled; its first version
    could, and the phase-1 review showed it). Still not modelled: a '<!--' opened mid-line in
    prose that runs on into later lines. That is the comment model's business; 016's phase 2
    is scoped to make build-digests report a marker it passes over inside one.

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
# onto the next line of its paragraph hides nothing, and a stray backtick in one block cannot
# pair into a later block and disarm a real comment there (014's H1). Pairing reaches past one
# line ONLY where that can never disarm more than per-line pairing would in a paragraph whose
# backticks the scan may misread; everywhere else the result is per-line pairing, the reviewed
# baseline, and every rule below moves toward it, never beyond it (016 D3, D9). What is modelled:
#   - A paragraph is a run of plain lines. It ends at a blank line and at any line that
#     begins a block. Block starts are read generously (016 D3): a heading, list item, block
#     quote, table row or HTML tag at any indentation, a thematic break or setext underline.
#   - A paragraph is paired as one text only when every backtick in it can be read as a span
#     delimiter (016 D9, phase-1 review F1). It keeps per-line pairing when a backslash touches
#     a backtick (backslash escapes do not apply inside a span, so the scan misreads a closer
#     such as the one in a quoted Windows path), or when a line has a '<' opening a tag,
#     autolink or comment, or a link destination '](', before a backtick (those bind first, so
#     their backticks delimit nothing). Paired across lines anyway, such a paragraph could
#     disarm a real comment between two backticks the renderer never pairs.
#   - Lines that join no paragraph keep per-line pairing, exactly as before 016: fenced
#     lines; an HTML comment block, from a line whose first text is '<!--' through the first
#     line whose raw text holds '-->' after the opener (016 D4); a raw HTML block, from a line
#     starting with a tag to its CommonMark end (a pre, script, style or textarea block at its
#     closing tag, a processing instruction at '?>', a declaration at '>', CDATA at ']]>', any
#     other tag at a blank line); a heading, thematic break, setext underline or table row; and
#     an indented line that does not continue a paragraph.
# What is NOT modelled: a '<!--' opened mid-line in prose that runs on into later lines. That
# is the comment model's business, not this function's; feature 016's phase 2 is scoped to make
# build-digests report a marker it passes over inside such a comment (016 D8). Nor does per-line
# pairing itself honour autolinks, raw HTML or backslashes, so a shape that fooled it on one line
# before 016 still does (recorded in specs/016-multiline-code-spans/notes.md).
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
    # A paragraph line whose backticks the run scan may misread (D9): a backslash touching a
    # backtick, or a tag, autolink, comment or link destination before a backtick.
    $doubtful = '\\`|`\\|<[A-Za-z/!?].*`|\]\(.*`'
    # Pair the pending paragraph's spans across its lines, then split it back in place. A
    # doubtful paragraph is paired line by line instead.
    $flush = {
        $whole = $para.Count -gt 1
        if ($whole) {
            foreach ($j in $para) { if ($Lines[$j] -match $doubtful) { $whole = $false; break } }
        }
        if ($whole) {
            $joined = ($para | ForEach-Object { $Lines[$_] }) -join "`n"
            $parts = (Convert-SpanText -Text $joined) -split "`n"
            for ($p = 0; $p -lt $para.Count; $p++) { $out[$para[$p]] = $parts[$p] }
        } else {
            foreach ($j in $para) { $out[$j] = Convert-SpanText -Text $Lines[$j] }
        }
        $para.Clear()
    }

    $inCommentBlock = $false
    # The end of the raw HTML block being read: $null outside one, 'blank' for a block that
    # ends at a blank line, otherwise the pattern of the line that ends it (D9).
    $htmlEnd = $null
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        $line = $Lines[$i]
        # An HTML comment block: its lines join no paragraph and keep per-line pairing (D4).
        if ($inCommentBlock) {
            if ($line.IndexOf('-->') -ge 0) { $inCommentBlock = $false }
            $out[$i] = Convert-SpanText -Text $line
            continue
        }
        # Inside a raw HTML block: per-line pairing to the block's CommonMark end (D9).
        if ($htmlEnd) {
            $out[$i] = Convert-SpanText -Text $line
            if ($htmlEnd -eq 'blank') { if ($line -match '^\s*$') { $htmlEnd = $null } }
            elseif ($line -match $htmlEnd) { $htmlEnd = $null }
            continue
        }
        $m = [regex]::Match($line, '^ {0,3}<!--')
        if ($m.Success -and -not $fenced[$i]) {
            . $flush
            $inCommentBlock = $line.IndexOf('-->', $m.Index + $m.Length) -lt 0
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
            continue
        }
        # A raw HTML block opens on a line starting with a tag. Its lines join no paragraph,
        # keep per-line pairing, and run to the block's CommonMark end (D9) — a pre block
        # does not end at a blank line, so a paragraph must not resume inside it.
        if ($line -match '^\s*</?[A-Za-z!?]') {
            . $flush
            $out[$i] = Convert-SpanText -Text $line
            $end = if ($line -match '(?i)^\s*<(pre|script|style|textarea)(\s|>|$)') { '(?i)</(pre|script|style|textarea)>' }
                   elseif ($line -match '^\s*<\?') { '\?>' }
                   elseif ($line -match '^\s*<!\[CDATA\[') { '\]\]>' }
                   elseif ($line -match '^\s*<![A-Za-z]') { '>' }
                   else { 'blank' }
            # A block whose end is on its own opening line is over already.
            if ($end -ne 'blank' -and $line -match $end) { $end = $null }
            $htmlEnd = $end
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
