---
name: ML::Clustering
version: 0.2.0
auth: zef:antononcube
kind: Distribution · machine learning
summary: k-means over numeric vectors with eleven distance functions — and
  by default the reported centres are not the clusters' centroids.
status: divergent
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: Math::DistanceFunctions, Data::TypeSystem
raku-land: https://raku.land/zef:antononcube/ML::Clustering
source: https://github.com/antononcube/Raku-ML-Clustering.git
---

## What it is for

Grouping points that are near each other, without being told the groups.
k-means is the default answer: pick k centres, assign each point to its
nearest, move the centres, repeat.

This distribution does that for lists of equal-length numeric vectors, with a
choice of eleven distance functions or your own callable.

## Clustering

```raku name="basics"
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
```

```output
points : 36
labels : 36
  every label in 0..^3 : True
  distinct labels used : 3

  each label maps to one blob : True
```

Nothing above asserts a value — the seeding is random, and these are the
properties that hold every run.

## The properties you can ask for

```raku name="props"
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
```

```output
available : All ClusterLabels Clusters IndexClusters MeanPoints Properties

prop => "All" gives : ClusterLabels, Clusters, IndexClusters, MeanPoints

the names are CASE-SENSITIVE:
  prop => "clusters" -> refused

options: :distance-function (default Euclidean), :max-steps (1000),
:precision-goal (6), :learning-parameter (0.01),
:min-reassignment-fraction (0.005).

and a custom distance function is just a Callable:
  with a Manhattan distance : 24 labels
```

## The one thing to know

With the default `learning-parameter` the returned `MeanPoints` are **not** the
centroids of the clusters they label.

```raku name="means"
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
```

```output
  learning-parameter 0.01  : centres are the centroids in NONE of 20 runs
  learning-parameter 0     : centres are the centroids in most of 20 runs

the default update rule is ONLINE — each point nudges its nearest
centre a fraction of the way towards itself — and the loop stops as
soon as the LABELS stabilise, long before the centres converge.

the cluster ASSIGNMENT is fine. Only the reported centres are junk.
Pass :learning-parameter(0) for the textbook batch update, or
compute the centroids yourself from ClusterLabels.
```

## Only `ClusterLabels` is a reliable correspondence

```raku name="order"
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
```

```output
the four returned keys : ClusterLabels, Clusters, IndexClusters, MeanPoints

Clusters, IndexClusters and MeanPoints are built by .categorize(…)
over a HASH, so their positional order is hash order and bears no
relation to the numbers in ClusterLabels.

  IndexClusters[c] is only rarely the set of indices whose
  ClusterLabels value is c — one run in twenty or so.

work from ClusterLabels and index into your own data.
```

## Where the two engines differ

Two, and both are about the shape of the answer rather than the clustering.
`find-clusters` returns an **itemized** `Array`, so `my @labels = find-clusters(…)`
gets one element under Rakudo and all of them under Raku++ — call `.list`.
And the labels come back as `Str` under Raku++ and `Int` under Rakudo, because
`.minpairs` stringifies its keys there.

```raku name="portable"
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
```

```output
labels, .list-ed and .Int-ed : 18 of them
  all Int   : True
  all in range : True

that .list.map(*.Int) is the whole portability fix.

three more things that behave the same on both engines and are worth
knowing: asking for k clusters can silently return FEWER;
method => "k-medoids" dies with "Only method K-means is implemented.
Continuing with K-means." and does NOT continue; and k = 0 produces
an internal hyperop error rather than a message.
```
