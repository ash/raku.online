---
name: Math::Nearest
version: 0.0.7
auth: zef:antononcube
kind: Distribution · maths
summary: Nearest-neighbour search over a point set — the k closest or
  everything inside a radius — with a k-d tree or an exhaustive scan behind
  one callable finder.
status: divergent
suite: 5 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: Math::DistanceFunctions, Algorithm::KDimensionalTree
raku-land: https://raku.land/zef:antononcube/Math::Nearest
source: https://github.com/antononcube/Raku-Math-Nearest
---

## What it is for

"Which of my points is closest to this one" is the query under
classification by nearest neighbour, under snapping a click to a feature,
under deduplication, and under every recommendation that works by
similarity. Asked once, a scan over the whole set is the right answer.
Asked many times against the same set, it is worth building a structure
first — which is what a k-d tree is, and what makes the repeated query
logarithmic instead of linear.

This distribution wraps both strategies behind one object, so the choice is
an option rather than a rewrite.

## Building a finder and asking it

```raku name="nearest"
use Math::Nearest;

my @points = [0,0], [1,0], [0,1], [3,4], [5,5], [2,2], [-1,-1];

my &find = nearest(@points);
sub show(@pts) { @pts.map({ '(' ~ .join(',') ~ ')' }).join(' ') }

say show(&find([1,1]));
say show(&find([1,1], 3));
say show(nearest(@points, [1,1], 2));

say &find([1,1], 3, :prop<distance>).List.raku;
say &find([1,1], 3, :prop<index>).List.raku;

say &find([1,1], :r(1.5)).elems, ' within 1.5';
say &find([1,1], :r(0)).elems, ' within 0';
```

```output
(1,0)
(1,0) (0,1) (2,2)
(1,0) (0,1)
(1e0, 1e0, 1.4142135623730951e0)
(1, 2, 5)
4 within 1.5
0 within 0
```

The finder is callable, so it reads as a function once built. Asking for
`:prop<distance>` or `:prop<index>` gives you those instead of the points
themselves, and `:prop('All')` gives a record of all four. A radius query
takes `:r` instead of a count.

Points may carry labels, by handing in pairs instead of bare coordinates:

```raku name="labels"
use Math::Nearest;

my @places = 'origin' => [0,0], 'east' => [1,0],
             'north'  => [0,1], 'far'  => [5,5];

my &find = nearest(@places);
say &find([1,1], 2).map({ '(' ~ .join(',') ~ ')' }).join(' ');
say &find([1,1], 2, :prop<label>).map(*.head).join(' ');
say nearest(@places, :method<Scan>)([1,1], 2, :prop<label>).map(*.head).join(' ');
```

```output
(1,0) (0,1)
east north
east north
```

## The one thing to know

The distance function is pluggable and the default backend is a k-d tree,
and that combination is only valid for some distances. A k-d tree prunes by
comparing a single coordinate's gap against the best distance so far, which
is sound for Euclidean, Manhattan and Chebyshev and **unsound** for
Canberra and Bray–Curtis, whose per-axis contributions are scaled by the
values themselves.

Nothing warns you. You get a result of the right length, in ascending
order, with the wrong points in it. Measured over forty queries against a
hundred and twenty points, the tree was wrong on fourteen of them with
Bray–Curtis, and exact with Euclidean.

The fix is to name the other backend whenever the distance is not a plain
metric:

```raku name="backends"
use Math::Nearest;

my @points = [0,0], [1,0], [0,1], [3,4], [5,5], [2,2], [-1,-1];

for <Euclidean Manhattan BrayCurtis> -> $d {
    my &tree = nearest(@points, :distance-function($d));
    my &scan = nearest(@points, :distance-function($d), :method<Scan>);
    sub show(@pts) { @pts.map({ '(' ~ .join(',') ~ ')' }).join(' ') }
    say sprintf('%-11s tree=%-22s scan=%s', $d, show(&tree([1,1], 3)), show(&scan([1,1], 3)));
}
say (try nearest(@points, :method<kd-tree>)) // 'kd-tree: refused';
```

```output
Euclidean   tree=(1,0) (0,1) (2,2)      scan=(1,0) (0,1) (0,0)
Manhattan   tree=(1,0) (0,1) (2,2)      scan=(1,0) (0,1) (0,0)
BrayCurtis  tree=(2,2) (1,0) (0,1)      scan=(1,0) (0,1) (2,2)
kd-tree: refused
```

`:method<Scan>` is exact for every distance, at the cost of being linear.
Use the tree for the metrics it is valid for and the scan for the rest; the
spelling of `:method` is exact, and `KDTree` and `Scan` are the only two it
accepts.

## Where the two engines differ

The k-d tree's wrong answers are not the same wrong answers on both
engines. With Canberra it was wrong on twenty-three of forty queries under
Raku++ and correct on all forty under Rakudo, from byte-identical input —
so a program can pass its tests on one engine and return different
neighbours on the other. The exhaustive scan agreed with brute force in
every case on both.

That is a second reason to prefer `:method<Scan>` for a non-metric
distance: it is not only exact, it is the same on both engines.

Two smaller things. A radius query returns its hits unordered where a count
query returns them nearest-first, so sort it yourself if the order matters.
And `:prop` is case-sensitive, accepting only `distance`, `index`, `label`,
`point` and `All`.
