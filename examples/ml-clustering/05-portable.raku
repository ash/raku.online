#!/usr/bin/env rakupp
# ML::Clustering — Where the two engines differ
# https://raku.online/modules/ml-clustering/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install ML::Clustering
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use ML::Clustering;

my @points = (^18).map({ [ ($_ % 3) * 10, $_ div 3 ] });
my @labels = find-clusters(@points, 3, prop => 'ClusterLabels').list.map(*.Int);

say 'labels, .list-ed and .Int-ed : ', @labels.elems, ' of them';
say '  all Int   : ', so @labels.all ~~ Int;
say '  all in range : ', so @labels.all ~~ 0..^3;
say '';
say 'that .list.map(*.Int) is the whole portability fix.';
say '';
say 'three more things that behave the same on both engines and are worth';
say 'knowing: asking for k clusters can silently return FEWER;';
say 'method => "k-medoids" dies with "Only method K-means is implemented.';
say 'Continuing with K-means." and does NOT continue; and k = 0 produces';
say 'an internal hyperop error rather than a message.';

# Output:
#     labels, .list-ed and .Int-ed : 18 of them
#       all Int   : True
#       all in range : True
#     
#     that .list.map(*.Int) is the whole portability fix.
#     
#     three more things that behave the same on both engines and are worth
#     knowing: asking for k clusters can silently return FEWER;
#     method => "k-medoids" dies with "Only method K-means is implemented.
#     Continuing with K-means." and does NOT continue; and k = 0 produces
#     an internal hyperop error rather than a message.
