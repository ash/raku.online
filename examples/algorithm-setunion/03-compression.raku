#!/usr/bin/env rakupp
# Algorithm::SetUnion — Path compression
# https://raku.online/modules/algorithm-setunion/#path-compression
#
# Install what it needs, then run it:
#     rakupp install Algorithm::SetUnion
#     rakupp 03-compression.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::SetUnion;

my $u = Algorithm::SetUnion.new(size => 4);
$u.union(0, 1);         # root 0, size 2
$u.union(2, 3);         # root 2, size 2
$u.union(0, 2);         # equal sizes, so 2 hangs under 0 and 3 sits at depth 2

say 'parents before find(3) : ', (^4).map({ $u.nodes[$_].parent }).join(' ');
say 'find(3) = ', $u.find(3);
say 'parents after  find(3) : ', (^4).map({ $u.nodes[$_].parent }).join(' ');

# Output:
#     parents before find(3) : 0 0 0 2
#     find(3) = 0
#     parents after  find(3) : 0 0 0 0
