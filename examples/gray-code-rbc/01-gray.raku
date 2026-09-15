#!/usr/bin/env rakupp
# Gray::Code::RBC — Encoding and decoding
# https://raku.online/modules/gray-code-rbc/#encoding-and-decoding
#
# Install what it needs, then run it:
#     rakupp install Gray::Code::RBC
#     rakupp 01-gray.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Gray::Code::RBC;

for ^8 -> $n {
    my $g = gray-encode($n);
    printf "%d -> %s (%d) -> %d\n", $n, $g.base(2).fmt('%03s'), $g, gray-decode($g);
}

# Output:
#     0 -> 000 (0) -> 0
#     1 -> 001 (1) -> 1
#     2 -> 011 (3) -> 2
#     3 -> 010 (2) -> 3
#     4 -> 110 (6) -> 4
#     5 -> 111 (7) -> 5
#     6 -> 101 (5) -> 6
#     7 -> 100 (4) -> 7
