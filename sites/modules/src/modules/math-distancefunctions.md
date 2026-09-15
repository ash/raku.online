---
name: Math::DistanceFunctions
version: 0.1.4
auth: zef:antononcube
kind: Distribution · maths
summary: Ten ways to measure how far apart two numeric vectors are —
  Euclidean, Manhattan, Chebyshev, cosine, Canberra, Bray–Curtis, Hamming
  and the general p-norm — as plain subs over two lists.
status: full
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: Math::DistanceFunctions::Native
raku-land: https://raku.land/zef:antononcube/Math::DistanceFunctions
source: https://github.com/antononcube/Raku-Math-DistanceFunctions
---

## What it is for

Clustering, nearest-neighbour search, recommendation, anomaly detection and
half of statistics all reduce to one question asked many times: how far
apart are these two vectors? The answer depends on which distance you pick,
and the choice matters more than the code. Euclidean is the straight line.
Manhattan adds the per-axis gaps, which is what a grid of streets gives
you. Chebyshev takes the largest single gap. Cosine ignores magnitude and
compares direction, which is why it is the one for text. Canberra and
Bray–Curtis weight each axis by its own size, for data where a difference
of one matters more among small numbers than large.

This distribution is the kernels, one sub each, over two equal-length
lists. Thirteen distributions depend on it.

## Ten kernels

```raku name="kernels"
use Math::DistanceFunctions;

my @a = 1, 2, 3;
my @b = 4, 6, 8;

say 'euclidean   ', euclidean-distance(@a, @b);
say 'sq-euclid   ', squared-euclidean-distance(@a, @b);
say 'manhattan   ', manhattan-distance(@a, @b);
say 'chessboard  ', chessboard-distance(@a, @b);
say 'cosine      ', cosine-distance(@a, @b);
say 'bray-curtis ', bray-curtis-distance(@a, @b);
say 'hamming     ', hamming-distance(@a, @b);
say 'dot product ', dot-product(@a, @b);
say 'norm p=1    ', norm(@a, 1);
say 'norm p=2    ', norm(@a);
say 'self        ', euclidean-distance(@a, @a), ' ', cosine-distance(@a, @a);
```

```output
euclidean   7.0710678118654755
sq-euclid   50
manhattan   12
chessboard  5
cosine      0.007416666029069652
bray-curtis 0.5
hamming     3
dot product 40
norm p=1    6
norm p=2    3.7416573867739413
self        0 0
```

Every one takes two lists of the same length and answers a number.
`squared-euclidean-distance` exists because a great many algorithms only
compare distances, and skipping the square root is free. `hamming-distance`
counts positions that differ rather than measuring them, and takes two
strings as well as two lists.

## The one thing to know

`norm(@v, Inf)` is not the infinity norm. It should be the largest absolute
component; it is always 1:

```raku name="infinity-norm"
use Math::DistanceFunctions;

say norm([1, 2, 3], 2);
say norm([1, 2, 3], 10);
say norm([1, 2, 3], Inf);
say norm([7, 2], Inf);
say chessboard-distance([0, 0, 0], [1, 2, 3]);
```

```output
3.7416573867739413
3.005167303445029
1
1
3
```

The sub computes the general formula, the sum of the absolute values raised
to *p*, all raised to one over *p* — and at infinity that last step is
anything raised to the power zero, which is 1 whatever the vector was. The
sup-norm is available under another name: it is the Chebyshev distance from
the origin, the last line above.

Two smaller edges to watch. Canberra and Bray–Curtis divide by a sum that
can be zero, and when it is they return a rational with a zero denominator
rather than failing — which then throws when you print it, pointing the
backtrace at your `say` and not at the distance call. And
`get-distance-function`, the name-to-kernel lookup that would let a routine
take `:distance-function<cosine>` as an option, is not exported by this
unit: it lives on the `Math::DistanceFunctionish` role, which you compose
into a class of your own.
