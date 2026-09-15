---
name: Algorithm::BinaryIndexedTree
version: 0.0.8
auth: zef:titsuki
kind: Distribution · data structures
summary: A Fenwick tree — an array of cumulative counts supporting a bucket
  increment and a prefix sum, each in logarithmic time.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:titsuki/Algorithm::BinaryIndexedTree
source: https://github.com/titsuki/raku-Algorithm-BinaryIndexedTree.git
---

## What it is for

Keeping a running total over a mutable array is a choice between two bad
options: store the values and pay linearly for every prefix sum, or store the
prefix sums and pay linearly for every update. A Fenwick tree does both in
logarithmic time by storing partial sums over ranges whose lengths are powers
of two.

It is the structure under order statistics, under "how many events before this
timestamp", and under any histogram that is read and written at the same rate.

## Building and querying

```raku name="fenwick"
use Algorithm::BinaryIndexedTree;

my $t = Algorithm::BinaryIndexedTree.new(size => 8);
my @freq = 0, 3, 1, 4, 1, 5, 9, 2, 6;     # index 0 unused for now
$t.add($_, @freq[$_]) for 1 .. 8;

say 'get  1..8 : ', (1..8).map({ $t.get($_) }).join(' ');
say 'sum  1..8 : ', (1..8).map({ $t.sum($_) }).join(' ');
say 'reference : ', [\+](@freq[1..8]).join(' ');
say '';
say 'a range query, sum(3..6) : ', $t.sum(6) - $t.sum(2);
say 'which should be          : ', @freq[3..6].sum;
```

```output
get  1..8 : 3 1 4 1 5 9 2 6
sum  1..8 : 3 4 8 9 14 23 25 31
reference : 3 4 8 9 14 23 25 31

a range query, sum(3..6) : 19
which should be          : 19
```

The prefix sums match a plain triangular reduce exactly.

## Updating

```raku name="update"
use Algorithm::BinaryIndexedTree;

my $t = Algorithm::BinaryIndexedTree.new(size => 8);
$t.add($_, 1) for 1 .. 8;

say 'before : get(5)=', $t.get(5), ' sum(8)=', $t.sum(8);
$t.add(5, 100);
say 'after add(5, 100) : get(5)=', $t.get(5), ' sum(8)=', $t.sum(8);
say '';
say 'add is an INCREMENT, not a store — there is no setter:';
$t.add(5, 100);
say 'after a second add(5, 100) : get(5)=', $t.get(5);
```

```output
before : get(5)=1 sum(8)=8
after add(5, 100) : get(5)=101 sum(8)=108

add is an INCREMENT, not a store — there is no setter:
after a second add(5, 100) : get(5)=201
```

There is no way to set a bucket to a value, no way to clear it and no way to
resize the table. To overwrite a bucket you must read it and add the
difference.

## The bounds

```raku name="bounds"
use Algorithm::BinaryIndexedTree;

my $t = Algorithm::BinaryIndexedTree.new(size => 8);

for 8, 9, -1 -> $i {
    my $r = try $t.sum($i);
    say sprintf('sum(%2d) -> %s', $i, $! ?? $!.message !! $r.Str);
}
say '';
say 'note that index == size is accepted, so new(size => 8) has NINE slots';
say 'the default new() allocates 1001 of them';
```

```output
sum( 8) -> 0
sum( 9) -> Error: index must be smaller than table size
sum(-1) -> Error: index must be larger or equal to 0

note that index == size is accepted, so new(size => 8) has NINE slots
the default new() allocates 1001 of them
```

The message says the index must be *smaller* than the table size, and the
check is `$index > $!size` — so index equal to size is allowed. Out-of-range
indices `die`; they do not return an undefined value.

## The one thing to know

Index 0 is not part of the tree at all. It is a separate accumulator that is
added to **every** prefix sum, including `sum(0)`.

```raku name="zero-trap"
use Algorithm::BinaryIndexedTree;

my $t = Algorithm::BinaryIndexedTree.new(size => 8);
$t.add($_, 1) for 1 .. 8;

say 'eight buckets holding one each';
say '  sum(0)  : ', $t.sum(0);
say '  sum(1)  : ', $t.sum(1);
say '  sum(8)  : ', $t.sum(8);
say '';
$t.add(0, 1000);
say 'after add(0, 1000):';
say '  get(0)     : ', $t.get(0);
say '  sum(0)     : ', $t.sum(0);
say '  sum(1)     : ', $t.sum(1), '   but get(1) is still ', $t.get(1);
say '  sum(8)     : ', $t.sum(8);
say '  get(1..8)  : ', (1..8).map({ $t.get($_) }).join(' ');
say '';
say 'it does cancel in a range query:';
say '  sum(6) - sum(2) : ', $t.sum(6) - $t.sum(2);
```

```output
eight buckets holding one each
  sum(0)  : 0
  sum(1)  : 1
  sum(8)  : 8

after add(0, 1000):
  get(0)     : 1000
  sum(0)     : 1000
  sum(1)     : 1001   but get(1) is still 1
  sum(8)     : 1008
  get(1..8)  : 1 1 1 1 1 1 1 1

it does cancel in a range query:
  sum(6) - sum(2) : 4
```

Every real bucket still reads 1, and yet `sum(1)` jumped from 1 to 1001. A
programmer reaching for a cumulative-frequency table will assume either
0-based buckets, so that `sum(0)` covers the first element, or 1-based with
`sum(0)` as the empty prefix returning 0. Neither is what happens.

The saving grace is that the extra term cancels in a range query, so
`sum(b) - sum(a)` stays correct. Use range queries, or simply never touch
index 0.

## Where the two engines differ

In two messages and one return value, none of which changes an answer.

A positional `new(8)` is rejected on both engines, with `No matching multi
candidate for method BUILD` on Raku++ and `Default constructor for
'Algorithm::BinaryIndexedTree' only takes named arguments` on Rakudo. And
`add(0, 5)` — which takes an early `return;` — hands back `Any` on Raku++ and
`Nil` on Rakudo; that is an engine-wide difference in what a bare `return`
yields, not something this module does.

One thing that is not an engine difference: `$value` is untyped, so
`add(1, "7")` quietly coerces the string, and `add(1, 2.5)` turns your integer
table into `Rat`s from that point on.
