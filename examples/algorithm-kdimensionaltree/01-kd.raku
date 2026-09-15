#!/usr/bin/env rakupp
# Algorithm::KDimensionalTree — Building and querying
# https://raku.online/modules/algorithm-kdimensionaltree/#building-and-querying
#
# Install what it needs, then run it:
#     rakupp install Algorithm::KDimensionalTree
#     rakupp 01-kd.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::KDimensionalTree;

my @pts = [2,3], [5,4], [9,6], [4,7], [8,1], [7,2];
my $kd = Algorithm::KDimensionalTree.new(@pts);

say 'gist : ', $kd.gist;
say '';
say 'k-nearest([9,2], 3) : ', $kd.k-nearest([9,2], 3).map({ '(' ~ .join(',') ~ ')' }).join(' ');
say 'k-nearest([9,2])    : ', $kd.k-nearest([9,2]).map({ '(' ~ .join(',') ~ ')' }).join(' ');
say '';
for $kd.k-nearest([9,2], 3, :!values) -> %h {
    say sprintf('  point %-8s index %d  distance %.6f',
        %h<point>.value.List.raku, %h<point>.key, %h<distance>);
}

# Output:
#     gist : Algorithm::KDimensionalTree(points => 6, distance-function => &euclidean-distance)
#     
#     k-nearest([9,2], 3) : (8,1) (7,2) (9,6)
#     k-nearest([9,2])    : (8,1)
#     
#       point (8, 1)   index 4  distance 1.414214
#       point (7, 2)   index 5  distance 2.000000
#       point (9, 6)   index 2  distance 4.000000
