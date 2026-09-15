#!/usr/bin/env rakupp
# Terminal::Boxer — Where the two engines differ
# https://raku.online/modules/terminal-boxer/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Terminal::Boxer
#     rakupp 04-aoa.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Terminal::Boxer;

my @rows = ['id','name'], ['1','apple'];
print ss-box(:col(2), |@rows.map(*.Slip));

# Output:
#     ┌─────┬─────┐
#     │  id │ name│
#     ├─────┼─────┤
#     │  1  │apple│
#     └─────┴─────┘
