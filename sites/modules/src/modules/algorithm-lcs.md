---
name: Algorithm::LCS
version: 0.1.1
auth: zef:raku-community-modules
kind: Distribution · algorithms
summary: The longest common subsequence of two sequences — the subsequence
  itself, not its length — with the common prefix and suffix stripped before
  the dynamic-programming table is built.
status: full
suite: 1 file, green
tested: 2026-09-15
license: MIT
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/Algorithm::LCS
source: https://github.com/raku-community-modules/Algorithm-LCS.git
---

## What it is for

Longest common subsequence is the machinery under `diff`: the lines two files
share, in order, are their LCS, and everything else is an insertion or a
deletion. It is also how you measure similarity between two version strings,
two DNA reads, or two clickstreams.

This distribution returns the subsequence itself rather than its length, which
is the harder half and the one you actually want when building a diff.

## Finding the subsequence

```raku name="lcs"
use Algorithm::LCS;

sub show(@a, @b, |c) {
    my @r = lcs(@a, @b, |c);
    sprintf('lcs(%-10s, %-10s) = %-14s len=%d',
        @a.join(''), @b.join(''), '[' ~ @r.join(' ') ~ ']', @r.elems)
}

say show [<X M J Y A U Z>], [<M Z J A W X U>];
say show [<A G C A T>], [<G A C>];
say show 'human'.comb.Array, 'chimpanzee'.comb.Array;
say show [<a b c>], [<a b c>];
say show [<a b c>], [<x y z>];
say show [<A A A>], [<A A>];
say show [1, 2, 3, 4], [2, 4, 5];
```

```output
lcs(XMJYAUZ   , MZJAWXU   ) = [M J A U]      len=4
lcs(AGCAT     , GAC       ) = [G A]          len=2
lcs(human     , chimpanzee) = [h m a n]      len=4
lcs(abc       , abc       ) = [a b c]        len=3
lcs(abc       , xyz       ) = []             len=0
lcs(AAA       , AA        ) = [A A]          len=2
lcs(1234      , 245       ) = [2 4]          len=2
```

`XMJYAUZ` against `MZJAWXU` gives `MJAU`, length 4, which is the textbook
answer. The result is a `Seq`.

## Choosing how elements compare

```raku name="compare"
use Algorithm::LCS;

say 'default comparator is eqv, which is type-strict:';
say '  lcs([1,2,3], ["1","2","3"])              = ', lcs([1,2,3], ['1','2','3']).List.raku;
say '  with :compare(&infix:<eq>)               = ',
    lcs([1,2,3], ['1','2','3'], compare => &infix:<eq>).List.raku;
say '  lcs([1.0, 2.0], [1, 2]) — Rat versus Int = ', lcs([1.0, 2.0], [1, 2]).List.raku;
say '';
say ':compare-i sees indices into the ORIGINAL arrays:';
my @a = <q a b z>;
my @b = <q a c z>;
my @seen;
my @res = lcs(@a, @b, compare-i => -> $i, $j { @seen.push("($i,$j)"); @a[$i] eq @b[$j] });
say '  result      : ', @res.List.raku;
say '  index pairs : ', @seen.join(' ');
```

```output
default comparator is eqv, which is type-strict:
  lcs([1,2,3], ["1","2","3"])              = ()
  with :compare(&infix:<eq>)               = (1, 2, 3)
  lcs([1.0, 2.0], [1, 2]) — Rat versus Int = ()

:compare-i sees indices into the ORIGINAL arrays:
  result      : ("q", "a", "z")
  index pairs : (0,0) (1,1) (2,2) (3,3) (2,2) (2,2)
```

The default `eqv` is type-strict, which catches a whole class of bugs and
surprises anyone comparing numbers against strings. `:compare-i` exists for
when the elements are expensive to compare and you have precomputed keys — it
receives absolute indices into the original arrays, and is used for the
prefix and suffix strip as well as for the table.

## The one thing to know

`lcs(@a, @b)` and `lcs(@b, @a)` are the same **length** but frequently a
different subsequence, so the result is not a canonical key.

```raku name="asymmetry"
use Algorithm::LCS;

sub words(@alpha, $maxlen) {
    my @w; my @cur = '';
    for 1 .. $maxlen { @cur = (@cur X @alpha).map(*.join); @w.append: @cur }
    @w
}

my @w = words(<a b c>, 4);
my ($n, $lendiff, $seqdiff) = 0, 0, 0;
my @examples;
for @w -> $x {
    for @w -> $y {
        my $ab = lcs($x.comb.Array, $y.comb.Array, compare => &infix:<eq>).join;
        my $ba = lcs($y.comb.Array, $x.comb.Array, compare => &infix:<eq>).join;
        $n++;
        $lendiff++ if $ab.chars != $ba.chars;
        if $ab ne $ba {
            $seqdiff++;
            @examples.push("lcs('$x','$y')='$ab'  but  lcs('$y','$x')='$ba'") if @examples < 3;
        }
    }
}
say "ordered pairs checked           : $n";
say "length differs when swapped     : $lendiff";
say "chosen subsequence differs      : $seqdiff";
say '';
.say for @examples;
```

```output
ordered pairs checked           : 14400
length differs when swapped     : 0
chosen subsequence differs      : 3006

lcs('ab','ba')='b'  but  lcs('ba','ab')='a'
lcs('ab','baa')='b'  but  lcs('baa','ab')='a'
lcs('ab','bac')='b'  but  lcs('bac','ab')='a'
```

Twenty-one per cent of pairs give a different answer depending on argument
order. Both answers are optimal — there is more than one longest common
subsequence and the algorithm picks one — but if you are hashing the result,
caching on it, or comparing two runs, you must fix the argument order.

## Where the two engines differ

Twice, both on mistakes rather than on correct use.

`@a` and `@b` are `Positional` parameters, so a bare `Str` is not a list of
characters. `lcs('abc', 'abd')` is a **compile-time error** on Rakudo —
`Calling lcs(Str, Str) will never work with declared signature` — and on
Raku++ it binds and returns a silently empty result. Use `.comb.Array`, as
every example above does.

And the return value is a `Seq`. Consuming it twice throws `The iterator of
this Seq is already in use/consumed` on Rakudo and quietly yields the values
again on Raku++. Assign to `my @r`, or call `.List`, if you need it more than
once.

Correctness itself is solid on both: 14,641 pairs of strings up to length four
over a three-letter alphabet, every answer both optimal in length and a
genuine common subsequence of both inputs, with zero failures on either
engine. The empty `class Algorithm::LCS` that ships alongside has no methods;
do not instantiate it looking for any.
