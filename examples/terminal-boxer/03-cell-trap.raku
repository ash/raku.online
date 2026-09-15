#!/usr/bin/env rakupp
# Terminal::Boxer — The one thing to know
# https://raku.online/modules/terminal-boxer/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Terminal::Boxer
#     rakupp 03-cell-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Terminal::Boxer;

print ss-box(:col(2), :cell(3), 'ok', 'a much longer value', 'x', 'y');

# Output:
#     ┌───┬───┐
#     │ ok│a much longer value│
#     ├───┼───┤
#     │ x │ y │
#     └───┴───┘
