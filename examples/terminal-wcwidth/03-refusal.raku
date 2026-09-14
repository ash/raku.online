#!/usr/bin/env rakupp
# Terminal::WCWidth — The one thing to know
# https://raku.online/modules/terminal-wcwidth/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Terminal::WCWidth
#     rakupp 03-refusal.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Terminal::WCWidth;

say wcswidth("plain");
say wcswidth("a\tb");

# Output:
#     5
#     -1
