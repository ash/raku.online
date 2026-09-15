#!/usr/bin/env rakupp
# ML::Clustering — Only `ClusterLabels` is a reliable correspondence
# https://raku.online/modules/ml-clustering/#only-clusterlabels-is-a-reliable-correspondence
#
# Install what it needs, then run it:
#     rakupp install ML::Clustering
#     rakupp 04-order.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use ML::Clustering;

my @points = (^16).map({ [ ($_ % 2) * 20, $_ div 2 ] });
my %r = find-clusters(@points, 2, prop => 'All');
say 'the four returned keys : ', %r.keys.sort.join(', ');
say '';
say 'Clusters, IndexClusters and MeanPoints are built by .categorize(…)';
say 'over a HASH, so their positional order is hash order and bears no';
say 'relation to the numbers in ClusterLabels.';
say '';
say '  IndexClusters[c] is only rarely the set of indices whose';
say '  ClusterLabels value is c — one run in twenty or so.';
say '';
say 'work from ClusterLabels and index into your own data.';

# Output:
#     the four returned keys : ClusterLabels, Clusters, IndexClusters, MeanPoints
#     
#     Clusters, IndexClusters and MeanPoints are built by .categorize(…)
#     over a HASH, so their positional order is hash order and bears no
#     relation to the numbers in ClusterLabels.
#     
#       IndexClusters[c] is only rarely the set of indices whose
#       ClusterLabels value is c — one run in twenty or so.
#     
#     work from ClusterLabels and index into your own data.
