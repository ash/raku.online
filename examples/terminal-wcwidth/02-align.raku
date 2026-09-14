#!/usr/bin/env rakupp
# Terminal::WCWidth — Two subs, one question
# https://raku.online/modules/terminal-wcwidth/#two-subs-one-question
#
# Install what it needs, then run it:
#     rakupp install Terminal::WCWidth
#     rakupp 02-align.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Terminal::WCWidth;

sub pad(Str $s, Int $w) { $s ~ ' ' x ($w - wcswidth($s)) }

for 'apple', '世界', 'café' -> $label {
    say '|', pad($label, 8), '| ', $label.chars, ' chars';
}

# Output:
#     |apple   | 5 chars
#     |世界    | 2 chars
#     |café    | 4 chars
