#!/usr/bin/env rakupp
# Algorithm::SetUnion — The one thing to know
# https://raku.online/modules/algorithm-setunion/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Algorithm::SetUnion
#     rakupp 04-root-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::SetUnion;

my $u = Algorithm::SetUnion.new(size => 6);

$u.union(0, 1);
say 'after union(0,1)               : find(0) = ', $u.find(0);

$u.union(2, 3); $u.union(4, 5); $u.union(2, 4);
say 'after three unions on the other side : find(0) = ', $u.find(0),
    '   find(2) = ', $u.find(2);

$u.union(0, 2);
say 'after union(0,2)               : find(0) = ', $u.find(0),
    '   find(2) = ', $u.find(2);
say '';
say 'element 0 never moved, and its root id changed anyway';

# Output:
#     after union(0,1)               : find(0) = 0
#     after three unions on the other side : find(0) = 0   find(2) = 2
#     after union(0,2)               : find(0) = 2   find(2) = 2
#     
#     element 0 never moved, and its root id changed anyway
