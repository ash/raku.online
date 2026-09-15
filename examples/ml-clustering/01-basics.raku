#!/usr/bin/env rakupp
# ML::Clustering — Clustering
# https://raku.online/modules/ml-clustering/#clustering
#
# Install what it needs, then run it:
#     rakupp install ML::Clustering
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use ML::Clustering;

# three well-separated blobs
my @points;
for (0, 0), (20, 0), (10, 20) -> ($ox, $oy) {
    @points.push([$ox + $_ % 3, $oy + ($_ div 3) % 3]) for ^12;
}

my @labels = find-clusters(@points, 3, prop => 'ClusterLabels').list;
say 'points : ', @points.elems;
say 'labels : ', @labels.elems;
say '  every label in 0..^3 : ', so @labels.all.map({ .Int ~~ 0..^3 });
say '  distinct labels used : ', @labels.unique.elems;
say '';
my %group;
for @points.kv -> $i, $p { %group{@labels[$i]}.push($p[0] div 10) }
say '  each label maps to one blob : ',
    so %group.values.all.map({ .unique.elems == 1 });

# Output:
#     points : 36
#     labels : 36
#       every label in 0..^3 : True
#       distinct labels used : 3
#     
#       each label maps to one blob : True
