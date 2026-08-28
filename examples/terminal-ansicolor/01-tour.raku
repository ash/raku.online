#!/usr/bin/env rakupp
# Terminal::ANSIColor — What it is for
# https://raku.online/modules/terminal-ansicolor/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install Terminal::ANSIColor
#     rakupp 01-tour.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Terminal::ANSIColor;

say colored('warning', 'bold yellow').raku;
say colored('ok', 'green').raku;
say color('reset').raku;

# Output:
#     "\x[1B][1;33mwarning\x[1B][0m"
#     "\x[1B][32mok\x[1B][0m"
#     "\x[1B][0m"
