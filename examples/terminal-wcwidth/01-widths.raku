#!/usr/bin/env rakupp
# Terminal::WCWidth — Two subs, one question
# https://raku.online/modules/terminal-wcwidth/#two-subs-one-question
#
# Install what it needs, then run it:
#     rakupp install Terminal::WCWidth
#     rakupp 01-widths.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Terminal::WCWidth;

say wcwidth('A'.ord);
say wcwidth('世'.ord);
say wcwidth("\c[COMBINING ACUTE ACCENT]".ord);
say wcwidth(7);

say wcswidth('hello 世界');
say 'hello 世界'.chars;

# Output:
#     1
#     2
#     0
#     -1
#     10
#     8
