#!/usr/bin/env rakupp
# Algorithm::KDimensionalTree — Radius queries and labels
# https://raku.online/modules/algorithm-kdimensionaltree/#radius-queries-and-labels
#
# Install what it needs, then run it:
#     rakupp install Algorithm::KDimensionalTree
#     rakupp 02-radius.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::KDimensionalTree;

my @pts = [2,3], [5,4], [9,6], [4,7], [8,1], [7,2];
my $kd = Algorithm::KDimensionalTree.new(@pts);

say 'within radius 3 of [9,2] : ',
    $kd.nearest-within-ball([9,2], 3).map({ '(' ~ .join(',') ~ ')' }).sort.join(' ');
say 'within radius 0 of [9,6] : ',
    $kd.nearest-within-ball([9,6], 0).map({ '(' ~ .join(',') ~ ')' }).join(' ');
say '';
my $l = Algorithm::KDimensionalTree.new(['alpha' => [1,1], 'beta' => [9,9], 'gamma' => [1,9]]);
say 'labels     : ', $l.labels.List.raku;
say 'a query still returns coordinates : ',
    $l.k-nearest([2,2]).map({ '(' ~ .join(',') ~ ')' }).join(' ');
my @r = $l.k-nearest([2,2], 2, :!values);
say 'the labels come back through .labels and the key:';
say '  ', @r.map({ $l.labels[$_<point>.key] }).join(' ');

# Output:
#     within radius 3 of [9,2] : (7,2) (8,1)
#     within radius 0 of [9,6] : (9,6)
#     
#     labels     : ("alpha", "beta", "gamma")
#     a query still returns coordinates : (1,1)
#     the labels come back through .labels and the key:
#       alpha gamma
