#!/usr/bin/env rakupp
# ML::Clustering — The properties you can ask for
# https://raku.online/modules/ml-clustering/#the-properties-you-can-ask-for
#
# Install what it needs, then run it:
#     rakupp install ML::Clustering
#     rakupp 02-props.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use ML::Clustering;

my @points = (^24).map({ [ ($_ % 2) * 20 + $_ % 3, ($_ div 2) % 4 ] });
say 'available : ', find-clusters(@points, 2, prop => 'Properties').list.sort.join(' ');
say '';
my %all = find-clusters(@points, 2, prop => 'All');
say 'prop => "All" gives : ', %all.keys.sort.join(', ');
say '';
say 'the names are CASE-SENSITIVE:';
my $r = try find-clusters(@points, 2, prop => 'clusters');
say '  prop => "clusters" -> ', $! ?? 'refused' !! 'accepted';
say '';
say 'options: :distance-function (default Euclidean), :max-steps (1000),';
say ':precision-goal (6), :learning-parameter (0.01),';
say ':min-reassignment-fraction (0.005).';
say '';
say 'and a custom distance function is just a Callable:';
my @l = find-clusters(@points, 2, prop => 'ClusterLabels',
                      distance-function => -> @a, @b { (@a Z- @b)>>.abs.sum }).list;
say '  with a Manhattan distance : ', @l.elems, ' labels';

# Output:
#     available : All ClusterLabels Clusters IndexClusters MeanPoints Properties
#     
#     prop => "All" gives : ClusterLabels, Clusters, IndexClusters, MeanPoints
#     
#     the names are CASE-SENSITIVE:
#       prop => "clusters" -> refused
#     
#     options: :distance-function (default Euclidean), :max-steps (1000),
#     :precision-goal (6), :learning-parameter (0.01),
#     :min-reassignment-fraction (0.005).
#     
#     and a custom distance function is just a Callable:
#       with a Manhattan distance : 24 labels
