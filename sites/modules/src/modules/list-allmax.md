---
name: List::Allmax
version: 0.0.1
auth: zef:thundergnat
kind: Distribution · lists
summary: `max` and `min` that return every tied winner — with a `:by` that is
  re-applied on both sides of every comparison.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:thundergnat/List::Allmax
source: https://github.com/thundergnat/List-Allmax.git
---

## What it is for

Core `max` returns one winner even when several elements tie. When the tie is
the interesting part — every student on the top mark, every file with the
newest timestamp — you want them all. This distribution returns them, as
values or as positions.

## Both forms

```raku name="basics"
use List::Allmax;

my @a = 3, 1, 4, 1, 5, 9, 2, 6;
say 'all-max(@a)      : ', all-max(@a).raku;
say 'all-min(@a)      : ', all-min(@a).raku;
say 'all-max(@a, :k)  : ', all-max(@a, :k).raku;
say 'all-min(@a, :k)  : ', all-min(@a, :k).raku;
say '';
say 'a genuine tie returns every winner:';
say '  all-max(7, 2, 7, 3, 7) = ', all-max(7, 2, 7, 3, 7).raku;
say '';
say 'edges:';
say '  all-max()   = ', all-max().raku;
say '  all-max(42) = ', all-max(42).raku;
say '  the result is always an Array.';
```

```output
all-max(@a)      : [9]
all-min(@a)      : [1, 1]
all-max(@a, :k)  : [5]
all-min(@a, :k)  : [1, 3]

a genuine tie returns every winner:
  all-max(7, 2, 7, 3, 7) = [7, 7, 7]

edges:
  all-max()   = []
  all-max(42) = [42]
  the result is always an Array.
```

## Comparing by a key

```raku name="by"
use List::Allmax;

my @words = <apple fig plum kiwi pear>;
say 'longest words  : ', all-max(@words, by => *.chars).raku;
say 'shortest words : ', all-min(@words, by => *.chars).raku;
say '';
say 'comparison is `cmp`, which is generic — so on Pairs it compares the';
say 'KEY first:';
my @pairs = (a => 1), (b => 3), (c => 3);
say '  all-max(@pairs)              = ', all-max(@pairs).raku;
say '  all-max(@pairs, by => +*.value) = ', all-max(@pairs, by => +*.value).raku;
say '';
say 'and a :by returning a Str compares lexicographically:';
say '  all-max(9, 10, 100, 2, by => *.Str) = ', all-max(9, 10, 100, 2, by => *.Str).raku;
say '  all-max(9, 10, 100, 2, by => +*)    = ', all-max(9, 10, 100, 2, by => +*).raku;
```

```output
longest words  : ["apple"]
shortest words : ["fig"]

comparison is `cmp`, which is generic — so on Pairs it compares the
KEY first:
  all-max(@pairs)              = [:c(3)]
  all-max(@pairs, by => +*.value) = [:b(3), :c(3)]

and a :by returning a Str compares lexicographically:
  all-max(9, 10, 100, 2, by => *.Str) = [9]
  all-max(9, 10, 100, 2, by => +*)    = [100]
```

## The one thing to know

`:by` is not a Schwartzian key function. It is re-applied on **both sides of
every comparison**, including over and over to the running maximum — about two
and a half times per element.

```raku name="by-calls"
use List::Allmax;

my @seen;
my @words = <pear fig plum kiwi>;
my @r = all-max(@words, by => -> $w { @seen.push($w); $w.chars });

say 'result              : ', @r.raku;
say '';
say ':by was applied to  : ', @seen.raku;
say '  ', @words.elems, ' elements, ', @seen.elems, ' applications';
say '';
say 'the comparator is { &by($^a) cmp &by($^b) } and each element is';
say 'compared twice — once for == 0 and once for > 0. "pear", the running';
say 'maximum, is passed to :by five times for a four-element list.';
say '';
say 'so a :by that is not a PURE function of its argument silently';
say 'returns a wrong answer, and one that costs money — a database lookup,';
say 'a hash miss — costs 2.5n rather than n. Memoise it, or precompute:';
my %len = @words.map({ $_ => .chars });
say '  precomputed : ', all-max(@words, by => { %len{$_} }).raku;
```

```output
result              : ["pear", "plum", "kiwi"]

:by was applied to  : ["pear", "pear", "fig", "pear", "fig", "pear", "plum", "pear", "kiwi", "pear"]
  4 elements, 10 applications

the comparator is { &by($^a) cmp &by($^b) } and each element is
compared twice — once for == 0 and once for > 0. "pear", the running
maximum, is passed to :by five times for a four-element list.

so a :by that is not a PURE function of its argument silently
returns a wrong answer, and one that costs money — a database lookup,
a hash miss — costs 2.5n rather than n. Memoise it, or precompute:
  precomputed : ["pear", "plum", "kiwi"]
```

## Everything is flattened

```raku name="flatten"
use List::Allmax;

say 'the *@list slurpy flattens, so sub-arrays never survive:';
say '  all-max([1,2], [3], [0,9,9]) = ', all-max([1,2], [3], [0,9,9]).raku;
say '';
say 'with :k the indices are into the FLATTENED list, not into anything';
say 'you passed:';
say '  all-max([1,2], [3], [0,9,9], :k) = ', all-max([1,2], [3], [0,9,9], :k).raku;
say '';
say 'if you want to compare the sub-lists themselves, compare by a key:';
my @lists = [1, 2], [3], [0, 9, 9];
say '  longest sub-list : ', all-max(@lists, by => *.elems).raku;
```

```output
the *@list slurpy flattens, so sub-arrays never survive:
  all-max([1,2], [3], [0,9,9]) = [9, 9]

with :k the indices are into the FLATTENED list, not into anything
you passed:
  all-max([1,2], [3], [0,9,9], :k) = [4, 5]

if you want to compare the sub-lists themselves, compare by a key:
  longest sub-list : [[0, 9, 9],]
```

## Where the two engines differ

The module's only safety net is a laziness guard, and it never fires on
Raku++ — a `*@` slurpy is always eager there and `is-lazy` is always `False`,
so an infinite source is silently truncated instead of being refused.

```raku name="lazy"
use List::Allmax;

say 'Rakudo refuses a lazy list outright:';
say '  all-max(1..Inf)  ->  X::Cannot::Lazy, "Cannot all-max a lazy list"';
say '';
say 'Raku++ materialises it and answers from whatever it happened to';
say 'collect — 10000 elements for a Range, 64 for an infinite gather, and';
say 'ZERO for an infinite .map, which comes back as an empty Array.';
say '';
say 'three different silent truncations, none of them an error.';
say '';
say 'bound the source yourself before you hand it over:';
say '  all-max((1..Inf).head(1000))          = ', all-max((1..Inf).head(1000)).raku;
say '  all-max((1..Inf).map(* * 2).head(10)) = ', all-max((1..Inf).map(* * 2).head(10)).raku;
say '';
say 'a finite list behaves identically on both engines, which is every';
say 'other example on this page.';
```

```output
Rakudo refuses a lazy list outright:
  all-max(1..Inf)  ->  X::Cannot::Lazy, "Cannot all-max a lazy list"

Raku++ materialises it and answers from whatever it happened to
collect — 10000 elements for a Range, 64 for an infinite gather, and
ZERO for an infinite .map, which comes back as an empty Array.

three different silent truncations, none of them an error.

bound the source yourself before you hand it over:
  all-max((1..Inf).head(1000))          = [1000]
  all-max((1..Inf).map(* * 2).head(10)) = [20]

a finite list behaves identically on both engines, which is every
other example on this page.
```
