---
name: Numeric::Nearest
version: 0.5.1
auth: cpan:DRCLAW
kind: Distribution · numbers
summary: Binary-search a sorted list for the closest element — and the plural
  form crashes on any list of two, three or four.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/cpan:DRCLAW/Numeric::Nearest
source: git://github.com/drclaw1394/nearestp6.git
---

## What it is for

Snapping a measurement to a calibration table, a timestamp to a sample grid, a
price to a tick size. The list is sorted and long, the key is arbitrary, and
you want the closest entry plus its index.

## Finding

```raku name="basics"
use Numeric::Nearest;

my @grid = 0, 10, 20, 30, 40, 50;
for -5, 4, 5, 14, 15, 99 -> $key {
    say sprintf('  key %3d -> %s', $key, nearestPair($key, @grid).raku);
}
say '';
say 'the result is an index => value Pair, and it clamps at both ends.';
say 'an exact tie goes to the HIGHER index:';
say '  nearestPair(5, (0, 10)) = ', nearestPair(5, (0, 10)).raku;
say '';
my $r = try nearestPair(1, ());
say '  an empty list -> ', $! ?? 'throws X::OutOfRange' !! $r.raku;
```

```output
  key  -5 -> 0 => 0
  key   4 -> 0 => 0
  key   5 -> 1 => 10
  key  14 -> 1 => 10
  key  15 -> 2 => 20
  key  99 -> 5 => 50

the result is an index => value Pair, and it clamps at both ends.
an exact tie goes to the HIGHER index:
  nearestPair(5, (0, 10)) = 1 => 10

  an empty list -> throws X::OutOfRange
```

## Many keys at once

```raku name="plural"
use Numeric::Nearest;

my @grid = 0, 10, 20, 30, 40;
say 'nearestPairs over ascending keys:';
say '  ', nearestPairs((0, 12, 19, 41), @grid).map(*.raku).join('  ');
say '';
say 'and over unsorted ones — it feeds each search the previous answer`s';
say 'index as a starting hint, so order affects the work but not the';
say 'answer:';
my @keys = 41, 0, 19, 12;
say '  ', nearestPairs(@keys, @grid).map(*.raku).join('  ');
say '';
say 'return type : ', nearestPairs((1,), @grid).WHAT.^name;
```

```output
nearestPairs over ascending keys:
  0 => 0  1 => 10  2 => 20  4 => 40

and over unsorted ones — it feeds each search the previous answer`s
index as a starting hint, so order affects the work but not the
answer:
  4 => 40  0 => 0  2 => 20  1 => 10

return type : Seq
```

## The one thing to know

`nearestPairs` — the plural entry point — crashes on any list of two, three or
four elements.

```raku name="small"
use Numeric::Nearest;

for 2, 3, 4, 5, 6 -> $n {
    my @grid = (^$n).map(* * 10);
    my $r = try nearestPairs((5, 15), @grid).map(*.raku).join(' ');
    say sprintf('  a %d-element list -> %s', $n, $! ?? 'DIES' !! $r);
}
say '';
say 'it threads the previous key`s index in as :start, and the search';
say 'loop is bounded by $list.elems iterations — one probe short once a';
say 'start hint has been consumed. The search then falls off the end';
say 'without assigning a result, and nearestPairs calls .key on it.';
say '';
say 'nearestPair on its own is correct for EVERY list length; only the';
say 'plural form is affected, and only below five elements — which is';
say 'exactly the size you reach for when writing a first test.';
say '';
say 'map the singular form yourself:';
my @grid = 0, 10, 20;
say '  ', (5, 15).map({ nearestPair($_, @grid) }).map(*.raku).join('  ');
```

```output
  a 2-element list -> 1 => 10 1 => 10
  a 3-element list -> DIES
  a 4-element list -> 1 => 10 2 => 20
  a 5-element list -> 1 => 10 2 => 20
  a 6-element list -> 1 => 10 2 => 20

it threads the previous key`s index in as :start, and the search
loop is bounded by $list.elems iterations — one probe short once a
start hint has been consumed. The search then falls off the end
without assigning a result, and nearestPairs calls .key on it.

nearestPair on its own is correct for EVERY list length; only the
plural form is affected, and only below five elements — which is
exactly the size you reach for when writing a first test.

map the singular form yourself:
  1 => 10  2 => 20
```

## Two shapes to know

```raku name="shapes"
use Numeric::Nearest;

say 'the list must be SORTED — nothing checks it, and an unsorted list';
say 'gives a silently wrong answer:';
say '  sorted   : ', nearestPair(15, (0, 10, 20, 30)).raku;
say '  unsorted : ', nearestPair(15, (30, 0, 20, 10)).raku;
say '';
say 'and the unit inside lib/Numeric/Nearest.pm6 is declared';
say '`unit module Nearest;` — so after `use Numeric::Nearest` the package';
say 'Numeric::Nearest does NOT exist and `Nearest` does:';
say '  ::("Numeric::Nearest").defined : ', ::('Numeric::Nearest').defined;
say '  ::("Nearest").defined          : ', ::('Nearest').defined;
say '';
say 'the two subs are exported, so you rarely need either name.';
```

```output
the list must be SORTED — nothing checks it, and an unsorted list
gives a silently wrong answer:
  sorted   : 2 => 20
  unsorted : 0 => 30

and the unit inside lib/Numeric/Nearest.pm6 is declared
`unit module Nearest;` — so after `use Numeric::Nearest` the package
Numeric::Nearest does NOT exist and `Nearest` does:
  ::("Numeric::Nearest").defined : False
  ::("Nearest").defined          : False

the two subs are exported, so you rarely need either name.
```

## Where the two engines differ

Nothing in the search: an exhaustive sweep over every integer key against
lists of 2 to 12 elements gives identical results on both engines, including
the small-list crash and the tie convention.

Only the empty-list failure differs in wording — Raku++ says `Index out of
range. Is: -1, should be in 0..^Inf` and Rakudo adds a `Use of uninitialized
value` warning of its own first.

```raku name="portable"
use Numeric::Nearest;

# the wrapper worth having
sub nearest($key, @sorted) {
    die 'nearest: empty list' unless @sorted;
    nearestPair($key, @sorted)
}
sub nearest-all(@keys, @sorted) {
    @keys.map({ nearest($_, @sorted) })
}

my @grid = 0, 10, 20;
say 'nearest-all over a 3-element grid : ',
    nearest-all((5, 15, 99), @grid).map(*.raku).join('  ');
my $r = try nearest(1, ());
say 'nearest(1, ())                    : ', $! ?? $!.message !! $r.raku;
say '';
say 'that avoids both the small-list crash and the empty-list wording,';
say 'and costs one .map.';
```

```output
nearest-all over a 3-element grid : 1 => 10  2 => 20  2 => 20
nearest(1, ())                    : nearest: empty list

that avoids both the small-list crash and the empty-list wording,
and costs one .map.
```
