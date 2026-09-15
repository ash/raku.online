#!/usr/bin/env rakupp
# DateTime::Grammar — A dozen shapes
# https://raku.online/modules/datetime-grammar/#a-dozen-shapes
#
# Install what it needs, then run it:
#     rakupp install DateTime::Grammar
#     rakupp 01-shapes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DateTime::Grammar;

for '2026-09-14',
    '2026-09-14T12:30:45Z',
    'Mon, 14 Sep 2026 12:30:45 GMT',
    'Mon Sep 14 12:30:45 2026',
    'September 14, 2026',
    '14 September 2026',
    '09/14/2026' -> $text
{
    say sprintf('%-32s %s', "'$text'", datetime-interpret($text));
}

say datetime-interpret('not a date at all').raku;
say datetime-parse('2026-09-14').defined;
say datetime-subparse('2026-09-14 and then some junk').Str;

# Output:
#     '2026-09-14'                     2026-09-14T00:00:00Z
#     '2026-09-14T12:30:45Z'           2026-09-14T12:30:45Z
#     'Mon, 14 Sep 2026 12:30:45 GMT'  2026-09-14T12:30:45Z
#     'Mon Sep 14 12:30:45 2026'       2026-09-14T12:30:45Z
#     'September 14, 2026'             2026-09-14T00:00:00Z
#     '14 September 2026'              2026-09-14T00:00:00Z
#     '09/14/2026'                     2026-09-14T00:00:00Z
#     Nil
#     True
#     2026-09-14
