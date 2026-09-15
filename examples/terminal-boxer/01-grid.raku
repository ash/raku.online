#!/usr/bin/env rakupp
# Terminal::Boxer — Drawing a grid
# https://raku.online/modules/terminal-boxer/#drawing-a-grid
#
# Install what it needs, then run it:
#     rakupp install Terminal::Boxer
#     rakupp 01-grid.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Terminal::Boxer;

my @cells = <id name qty 1 apple 7 2 pear 12>;

print ss-box(:col(3), @cells);
print ascii-box(:col(3), @cells);
print dd-box(:col(3), @cells);

# Output:
#     ┌─────┬─────┬─────┐
#     │  id │ name│ qty │
#     ├─────┼─────┼─────┤
#     │  1  │apple│  7  │
#     ├─────┼─────┼─────┤
#     │  2  │ pear│  12 │
#     └─────┴─────┴─────┘
#     +-----+-----+-----+
#     |  id | name| qty |
#     +-----+-----+-----+
#     |  1  |apple|  7  |
#     +-----+-----+-----+
#     |  2  | pear|  12 |
#     +-----+-----+-----+
#     ╔═════╦═════╦═════╗
#     ║  id ║ name║ qty ║
#     ╠═════╬═════╬═════╣
#     ║  1  ║apple║  7  ║
#     ╠═════╬═════╬═════╣
#     ║  2  ║ pear║  12 ║
#     ╚═════╩═════╩═════╝
