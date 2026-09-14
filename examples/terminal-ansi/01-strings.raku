#!/usr/bin/env rakupp
# Terminal::ANSI — Two units, and the difference matters
# https://raku.online/modules/terminal-ansi/#two-units-and-the-difference-matters
#
# Install what it needs, then run it:
#     rakupp install Terminal::ANSI
#     rakupp 01-strings.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Terminal::ANSI::OO;

say t.bold.raku;
say t.red.raku;
say t.text-reset.raku;

say (t.bold ~ 'shouted' ~ t.text-reset).raku;

# Output:
#     "\x[1B][1m"
#     "\x[1B][38;5;1m"
#     "\x[1B][0m"
#     "\x[1B][1mshouted\x[1B][0m"
