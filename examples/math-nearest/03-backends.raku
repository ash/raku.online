#!/usr/bin/env rakupp
# Math::Nearest — The one thing to know
# https://raku.online/modules/math-nearest/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Math::Nearest
#     rakupp 03-backends.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::Nearest;

my @points = [0,0], [1,0], [0,1], [3,4], [5,5], [2,2], [-1,-1];

for <Euclidean Manhattan BrayCurtis> -> $d {
    my &tree = nearest(@points, :distance-function($d));
    my &scan = nearest(@points, :distance-function($d), :method<Scan>);
    sub show(@pts) { @pts.map({ '(' ~ .join(',') ~ ')' }).join(' ') }
    say sprintf('%-11s tree=%-22s scan=%s', $d, show(&tree([1,1], 3)), show(&scan([1,1], 3)));
}
say (try nearest(@points, :method<kd-tree>)) // 'kd-tree: refused';

# Output:
#     Euclidean   tree=(1,0) (0,1) (2,2)      scan=(1,0) (0,1) (0,0)
#     Manhattan   tree=(1,0) (0,1) (2,2)      scan=(1,0) (0,1) (0,0)
#     BrayCurtis  tree=(2,2) (1,0) (0,1)      scan=(1,0) (0,1) (2,2)
#     kd-tree: refused
