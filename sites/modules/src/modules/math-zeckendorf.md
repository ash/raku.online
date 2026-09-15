---
name: Math::Zeckendorf
version: 0.0.5
auth: zef:coke
kind: Distribution · numbers
summary: The unique sum of non-consecutive Fibonacci numbers, and its dual —
  as digits or as the numbers themselves, except through a list.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:coke/Math::Zeckendorf
source: https://github.com/coke/math-zeckendorf.git
---

## What it is for

Zeckendorf's theorem says every positive integer is a sum of non-consecutive
Fibonacci numbers, in exactly one way. That gives a positional representation
with a curious property — no two adjacent 1s — which shows up in Fibonacci
coding, in golden-ratio base conversions and in puzzle problems.

The dual ("lazy") representation is the other unique form: no two adjacent
zeros.

## Both representations

```raku name="basics"
use Math::Zeckendorf;

for 1, 4, 12, 20, 100 -> $n {
    my @d = zeckendorf-representation($n);
    my @f = zeckendorf-representation($n, :numbers);
    say sprintf('  %3d  digits %-14s numbers %-14s sum %d',
                $n, @d.join, @f.join(','), @f.sum);
}
say '';
say 'the defining property, over 1..500:';
say '  every one reconstructs   : ',
    so (1..500).all.map({ zeckendorf-representation($_, :numbers).sum == $_ });
say '  no two adjacent 1s       : ',
    so (1..500).all.map({ !(zeckendorf-representation($_).join ~~ /11/) });
```

```output
    1  digits 1              numbers 1              sum 1
    4  digits 101            numbers 3,1            sum 4
   12  digits 10101          numbers 8,3,1          sum 12
   20  digits 101010         numbers 13,5,2         sum 20
  100  digits 1000010100     numbers 89,8,3         sum 100

the defining property, over 1..500:
  every one reconstructs   : True
  no two adjacent 1s       : True
```

```raku name="dual"
use Math::Zeckendorf;

for 11, 19, 20 -> $n {
    my @d = dual-zeckendorf-representation($n);
    my @f = dual-zeckendorf-representation($n, :numbers);
    say sprintf('  %3d  digits %-12s numbers %-14s sum %d',
                $n, @d.join, @f.join(','), @f.sum);
}
say '';
say '  every one reconstructs   : ',
    so (1..500).all.map({ dual-zeckendorf-representation($_, :numbers).sum == $_ });
say '  no two adjacent 0s inside: ',
    so (1..500).all.map({ !(dual-zeckendorf-representation($_).join ~~ /00/) });
say '';
say 'big inputs are fine:';
my @big = zeckendorf-representation(10**30, :numbers);
say '  10**30 needs ', zeckendorf-representation(10**30).elems, ' digits';
say '  and its numbers sum back exactly : ', @big.sum == 10**30;
```

```output
   11  digits 1111         numbers 5,3,2,1        sum 11
   19  digits 11111        numbers 8,5,3,2,1      sum 19
   20  digits 101010       numbers 13,5,2         sum 20

  every one reconstructs   : True
  no two adjacent 0s inside: True

big inputs are fine:
  10**30 needs 144 digits
  and its numbers sum back exactly : True
```

## The one thing to know

`:numbers` is silently dropped whenever the argument is a list.

```raku name="numbers-lost"
use Math::Zeckendorf;

say 'a bare Int honours the flag:';
say '  zeckendorf-representation(12, :numbers)   = ',
    zeckendorf-representation(12, :numbers).raku;
say '';
say 'a ONE-ELEMENT list does not:';
say '  zeckendorf-representation((12,), :numbers) = ',
    zeckendorf-representation((12,), :numbers).raku;
say '';
say 'nor does a longer one:';
say '  zeckendorf-representation((4, 12), :numbers) = ',
    zeckendorf-representation((4, 12), :numbers).raku;
say '';
say 'the list candidate is  @nums>>.&zeckendorf-representation.List  —';
say 'it never forwards the named argument. The call succeeds, returns a';
say 'plausible nested structure, and gives you DIGITS where you asked for';
say 'Fibonacci numbers. Since both are arrays of small integers, a';
say 'downstream .sum produces a number rather than an error.';
say '';
say 'map it yourself:';
say '  ', (4, 12).map({ zeckendorf-representation($_, :numbers) }).raku;
```

```output
a bare Int honours the flag:
  zeckendorf-representation(12, :numbers)   = [8, 3, 1]

a ONE-ELEMENT list does not:
  zeckendorf-representation((12,), :numbers) = ([1, 0, 1, 0, 1],)

nor does a longer one:
  zeckendorf-representation((4, 12), :numbers) = ([1, 0, 1], [1, 0, 1, 0, 1])

the list candidate is  @nums>>.&zeckendorf-representation.List  —
it never forwards the named argument. The call succeeds, returns a
plausible nested structure, and gives you DIGITS where you asked for
Fibonacci numbers. Since both are arrays of small integers, a
downstream .sum produces a number rather than an error.

map it yourself:
  ([3, 1], [8, 3, 1]).Seq
```

## Two shapes to know

```raku name="shapes"
use Math::Zeckendorf;

say 'the two functions return different ELEMENT types:';
my @z = zeckendorf-representation(12);
my @d = dual-zeckendorf-representation(12);
say '  zeckendorf      : ', @z.raku, '  element type ', @z[0].WHAT.^name;
say '  dual            : ', @d.raku, '  element type ', @d[0].WHAT.^name;
say '  @z eqv @d       : ', (@z eqv @d), '   <- never true, even for equal digits';
say '  joined          : ', @z.join.raku, ' vs ', @d.join.raku;
say '';
say 'the dual builds a string and .combs it; the primary pushes Ints.';
say '.join hides the difference; eqv, == and any numeric use do not.';
say '';
say 'and zero and negatives return an empty array, not [0] and not a';
say 'failure:';
for 0, -5 -> $n {
    say sprintf('  %3d -> %s', $n, zeckendorf-representation($n).raku);
}
say '';
say 'the two aliases `zeckendorf` and `dual-zeckendorf` ARE importable,';
say 'though introspection tools tend not to list them:';
say '  zeckendorf(12)      = ', zeckendorf(12).join;
say '  dual-zeckendorf(12) = ', dual-zeckendorf(12).join;
```

```output
the two functions return different ELEMENT types:
  zeckendorf      : [1, 0, 1, 0, 1]  element type Int
  dual            : ["1", "0", "1", "0", "1"]  element type Str
  @z eqv @d       : False   <- never true, even for equal digits
  joined          : "10101" vs "10101"

the dual builds a string and .combs it; the primary pushes Ints.
.join hides the difference; eqv, == and any numeric use do not.

and zero and negatives return an empty array, not [0] and not a
failure:
    0 -> []
   -5 -> []

the two aliases `zeckendorf` and `dual-zeckendorf` ARE importable,
though introspection tools tend not to list them:
  zeckendorf(12)      = 10101
  dual-zeckendorf(12) = 10101
```

## Where the two engines differ

Nothing in the representations — every digit string, every Fibonacci list and
every round trip above is identical on both engines. Only *when* a bad
argument type is reported: Raku++ raises `X::Multi::NoMatch` at run time while
Rakudo refuses the whole file at compile time with `Calling
zeckendorf-representation(Rat) will never work`.

```raku name="portable"
use Math::Zeckendorf;

# coerce at the call site and the two agree
sub zeck($n) {
    my $i = $n.Int;
    die "zeckendorf needs a positive integer, got $n" unless $i > 0;
    zeckendorf-representation($i, :numbers)
}
for 12, 12.0, 0 -> $n {
    my $r = try zeck($n);
    say sprintf('  zeck(%-5s) -> %s', $n.raku, $! ?? $!.message !! $r.join(','));
}
say '';
say 'the class Math::Zeckendorf itself is an empty shell — the two protos';
say 'and their aliases are the whole distribution.';
```

```output
  zeck(12   ) -> 8,3,1
  zeck(12.0 ) -> 8,3,1
  zeck(0    ) -> zeckendorf needs a positive integer, got 0

the class Math::Zeckendorf itself is an empty shell — the two protos
and their aliases are the whole distribution.
```
