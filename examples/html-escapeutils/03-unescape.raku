#!/usr/bin/env rakupp
# HTML::EscapeUtils — Unescaping
# https://raku.online/modules/html-escapeutils/#unescaping
#
# Install what it needs, then run it:
#     rakupp install HTML::EscapeUtils
#     rakupp 03-unescape.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTML::EscapeUtils;

for '&amp;', '&lt;', '&nbsp;', '&copy;', '&hellip;', '&AMP;',
    '&#65;', '&#x41;', '&#8212;', '&#x1F600;', '&amp;;;', '&amp' -> $e {
    my $r = try unescape($e);
    say sprintf('  %-12s -> %s', $e.raku, $! ?? 'threw' !! $r.raku);
}
say '';
say 'the table has 2222 entries including 752 uppercase spellings, the';
say 'quantifier on the trailing semicolon eats every one of them, and an';
say 'entity with no semicolon is left alone.';

# Output:
#       "\&amp;"     -> "\&"
#       "\&lt;"      -> "<"
#       "\&nbsp;"    -> " "
#       "\&copy;"    -> "©"
#       "\&hellip;"  -> "…"
#       "\&AMP;"     -> "\&"
#       "\&#65;"     -> "A"
#       "\&#x41;"    -> "A"
#       "\&#8212;"   -> "—"
#       "\&#x1F600;" -> "😀"
#       "\&amp;;;"   -> "\&"
#       "\&amp"      -> "\&amp"
#     
#     the table has 2222 entries including 752 uppercase spellings, the
#     quantifier on the trailing semicolon eats every one of them, and an
#     entity with no semicolon is left alone.
