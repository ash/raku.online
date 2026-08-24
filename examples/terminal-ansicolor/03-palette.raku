#!/usr/bin/env rakupp
# Terminal::ANSIColor — 256 colours
# https://raku.online/ecosystem/terminal-ansicolor/#256-colours
#
# Install what it needs, then run it:
#     rakupp install Terminal::ANSIColor
#     rakupp 03-palette.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Terminal::ANSIColor;

say color('202').raku;
say color('on_17').raku;
say colored('cool', '39').raku;

# Output:
#     "\x[1B][38;5;202m"
#     "\x[1B][48;5;17m"
#     "\x[1B][38;5;39mcool\x[1B][0m"
