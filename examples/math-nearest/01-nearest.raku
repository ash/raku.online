#!/usr/bin/env rakupp
# Math::Nearest — Building a finder and asking it
# https://raku.online/modules/math-nearest/#building-a-finder-and-asking-it
#
# Install what it needs, then run it:
#     rakupp install Math::Nearest
#     rakupp 01-nearest.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::Nearest;

my @points = [0,0], [1,0], [0,1], [3,4], [5,5], [2,2], [-1,-1];

my &find = nearest(@points);
sub show(@pts) { @pts.map({ '(' ~ .join(',') ~ ')' }).join(' ') }

say show(&find([1,1]));
say show(&find([1,1], 3));
say show(nearest(@points, [1,1], 2));

say &find([1,1], 3, :prop<distance>).List.raku;
say &find([1,1], 3, :prop<index>).List.raku;

say &find([1,1], :r(1.5)).elems, ' within 1.5';
say &find([1,1], :r(0)).elems, ' within 0';

# Output:
#     (1,0)
#     (1,0) (0,1) (2,2)
#     (1,0) (0,1)
#     (1e0, 1e0, 1.4142135623730951e0)
#     (1, 2, 5)
#     4 within 1.5
#     0 within 0
