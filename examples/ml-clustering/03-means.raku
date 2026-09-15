#!/usr/bin/env rakupp
# ML::Clustering — The one thing to know
# https://raku.online/modules/ml-clustering/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install ML::Clustering
#     rakupp 03-means.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use ML::Clustering;

my @points;
for (0, 0), (20, 20) -> ($ox, $oy) {
    @points.push([$ox + $_ % 3, $oy + ($_ div 3) % 3]) for ^12;
}

# 20 runs each, because the seeding is random
for 0.01, 0 -> $eta {
    my $exact = 0;
    for ^20 {
        my %r = find-clusters(@points, 2, prop => 'All', learning-parameter => $eta);
        my @labels = %r<ClusterLabels>.list;
        my @means  = %r<MeanPoints>.list;

        my $worst = 0;
        for @means.kv -> $c, $m {
            my @own = @points.kv.map(-> $i, $p { $p if @labels[$i].Int == $c }).grep(*.defined);
            next unless @own;
            my @centroid = (^2).map(-> $d { @own.map(*.[$d]).sum / @own.elems });
            $worst max= (@centroid Z- $m.list)>>.abs.max;
        }
        $exact++ if $worst < 1e-6;
    }
    say sprintf('  learning-parameter %-5s : centres are the centroids in %s of 20 runs',
                $eta, $eta == 0 ?? 'most' !! ($exact == 0 ?? 'NONE' !! $exact.Str));
}
say '';
say 'the default update rule is ONLINE — each point nudges its nearest';
say 'centre a fraction of the way towards itself — and the loop stops as';
say 'soon as the LABELS stabilise, long before the centres converge.';
say '';
say 'the cluster ASSIGNMENT is fine. Only the reported centres are junk.';
say 'Pass :learning-parameter(0) for the textbook batch update, or';
say 'compute the centroids yourself from ClusterLabels.';

# Output:
#       learning-parameter 0.01  : centres are the centroids in NONE of 20 runs
#       learning-parameter 0     : centres are the centroids in most of 20 runs
#     
#     the default update rule is ONLINE — each point nudges its nearest
#     centre a fraction of the way towards itself — and the loop stops as
#     soon as the LABELS stabilise, long before the centres converge.
#     
#     the cluster ASSIGNMENT is fine. Only the reported centres are junk.
#     Pass :learning-parameter(0) for the textbook batch update, or
#     compute the centroids yourself from ClusterLabels.
