#!/usr/bin/env rakupp
# Algorithm::KDimensionalTree — Choosing a distance
# https://raku.online/modules/algorithm-kdimensionaltree/#choosing-a-distance
#
# Install what it needs, then run it:
#     rakupp install Algorithm::KDimensionalTree
#     rakupp 03-distance.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::KDimensionalTree;
use Math::DistanceFunctions;

my @pts = [2,3], [5,4], [9,6], [4,7], [8,1], [7,2];

for 'euclidean', 'manhattan', 'chessboard' -> $spec {
    my $kd = Algorithm::KDimensionalTree.new(@pts, distance-function => $spec);
    say sprintf('%-12s %s', $spec,
        $kd.k-nearest([9,2], 3).map({ '(' ~ .join(',') ~ ')' }).join(' '));
}
say '';
my $c = Algorithm::KDimensionalTree.new(@pts,
    distance-function => -> @a, @b { (@a Z- @b)>>.abs.sum });
say 'a hand-written L1 : ',
    $c.k-nearest([9,2], 3).map({ '(' ~ .join(',') ~ ')' }).join(' ');
say '';
my $r = try Algorithm::KDimensionalTree.new([[1,2],], distance-function => 'levenshtein');
say 'an unknown name   : ', $! ?? $!.message !! 'accepted';

# Output:
#     euclidean    (8,1) (7,2) (9,6)
#     manhattan    (8,1) (7,2) (9,6)
#     chessboard   (8,1) (7,2) (9,6)
#     
#     a hand-written L1 : (8,1) (7,2) (9,6)
#     
#     an unknown name   : Unknown name of a distance function ⎡levenshtein⎦.
