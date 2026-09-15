---
name: Algorithm::KDimensionalTree
version: 0.1.2
auth: zef:antononcube
kind: Distribution · data structures
summary: A static k-d tree over numeric vectors, answering k-nearest-neighbour
  and radius queries, with a pluggable distance function.
status: divergent
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: Math::DistanceFunctions
raku-land: https://raku.land/zef:antononcube/Algorithm::KDimensionalTree
source: https://github.com/antononcube/Raku-Algorithm-KDimensionalTree.git
---

## What it is for

Asking "which of these points is nearest" once is a scan. Asking it thousands
of times against the same point set is worth building a structure for, and a
k-d tree is the classic one: recursively split on a cycling axis at the
median, and then prune whole subtrees whose axis gap already exceeds the best
distance found.

This distribution builds that tree and answers both kinds of query against it.

## Building and querying

```raku name="kd"
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
```

```output
gist : Algorithm::KDimensionalTree(points => 6, distance-function => &euclidean-distance)

k-nearest([9,2], 3) : (8,1) (7,2) (9,6)
k-nearest([9,2])    : (8,1)

  point (8, 1)   index 4  distance 1.414214
  point (7, 2)   index 5  distance 2.000000
  point (9, 6)   index 2  distance 4.000000
```

The queries return **coordinates**, not indices. To get an index you need
`:!values` and then `$_<point>.key`.

## Radius queries and labels

```raku name="radius"
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
```

```output
within radius 3 of [9,2] : (7,2) (8,1)
within radius 0 of [9,6] : (9,6)

labels     : ("alpha", "beta", "gamma")
a query still returns coordinates : (1,1)
the labels come back through .labels and the key:
  alpha gamma
```

Building from `Pair`s records the labels but does not make a query return
them. A radius of 0 is an exact-match query.

## Choosing a distance

```raku name="distance"
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
```

```output
euclidean    (8,1) (7,2) (9,6)
manhattan    (8,1) (7,2) (9,6)
chessboard   (8,1) (7,2) (9,6)

a hand-written L1 : (8,1) (7,2) (9,6)

an unknown name   : Unknown name of a distance function ⎡levenshtein⎦.
```

Those three are correct. Which brings up the reason this page is marked
divergent.

## The one thing to know

The pruning test applies your chosen distance to **axis-projected** vectors —
all components zeroed except the split axis. That is only a valid lower bound
for an axis-decomposable metric.

Euclidean, Manhattan and Chebyshev are fine, and were exact over four hundred
random queries. Cosine and squared Euclidean were exact too. **Bray-Curtis was
wrong on 30 of 400 queries on both engines**, and **Canberra was wrong on 184
of 400 under Raku++ and exact under Rakudo** — from byte-identical input.

The reason the two engines disagree is core Raku, not the module. For Canberra
the projected vectors produce a zero-over-zero `Rat`, and `<0/0> <= 1` is
`False` on Raku++ (which routes through `Num` and `NaN`) and `True` on Rakudo
(which cross-multiplies). So the "search the other branch too" test is always
false on one engine and always true on the other — wrong answers against an
accidental full scan.

Nothing warns you. You get a result of the right length, in ascending order,
with the wrong points in it. Use the tree only for the metrics it is valid
for.

## Where the two engines differ

That Canberra divergence is the one that changes answers. Two smaller ones:
`.points` comes back in a different **order** after construction on the two
engines, because the recursive build list-assigns to its own parameter; the
`Pair` keys stay correct so queries are unaffected, but never index `.points`
positionally. And `k-nearest(@p, 0)` emits an uninitialised-value warning on
Rakudo where Raku++ is silent, returning `()` on both.

Two things that are the same on both and are worth measuring before you
commit. `insert` calls a **full rebuild** — 399 inserts cost more than a
hundred times a single build of the same 400 points. And with a non-decomposable
distance the tree stops pruning entirely: a five-nearest query over 2048 points
took 105 distance evaluations with Euclidean and 2303 with cosine, which is a
linear scan plus overhead.
