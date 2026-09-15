---
name: Data::Transformers
version: 0.0.2
auth: zef:antononcube
kind: Distribution · data
summary: Numeric array reshaping — a running-total accumulator, a linear range
  remapper, and array padding and centring helpers — in three separately used
  units.
status: full
suite: 5 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: Data::TypeSystem
raku-land: https://raku.land/zef:antononcube/Data::Transformers
source: https://github.com/antononcube/Raku-Data-Transformers
---

## What it is for

Three small operations turn up constantly in data work and are annoying to
write correctly each time: turning a series into its running total, mapping a
range of values onto another range, and padding an array out to a length
without shifting its contents off centre.

This distribution is those three, split across three units you `use`
separately.

## Accumulating and rescaling

```raku name="basics"
use Data::Transformers;
use Data::Transformers::Rescale;

my @sales = 10, 5, 20, 5;
say 'accumulate             : ', accumulate(@sales).List.raku;
say 'the input is unchanged : ', @sales.List.raku;
say '';
say 'rescale a scalar into 0..1 : ', rescale(5, (0, 20), (0, 1));
say 'rescale a list, defaults   : ', rescale([2, 4, 6, 8]).List.raku;
say 'rescale a list to 0..100   : ', rescale([2, 4, 6, 8], (2, 8), (0, 100)).List.raku;
```

```output
accumulate             : (10, 15, 35, 40)
the input is unchanged : (10, 5, 20, 5)

rescale a scalar into 0..1 : 0.25
rescale a list, defaults   : (0.0, <1/3>, <2/3>, 1.0)
rescale a list to 0..100   : (0.0, <100/3>, <200/3>, 100.0)
```

`rescale` returns exact `Rat`s rather than `Num`s, which is worth knowing
before you compare the results against floating-point literals.

Note that `use Data::Transformers` alone gets you only `accumulate`; the other
two units must be named.

## Padding and centring

```raku name="arrays"
use Data::Transformers::Arrays;

my @a = 1, 2, 3;
say 'array-pad(@a, 6).elems    : ', array-pad(@a, 6).elems;
say 'center-array(@a, 6).elems : ', center-array(@a, 6).elems;
say 'center-array(@a, 6)       : ', center-array(@a, 6).List.raku;
say 'center-array(@a, 9)       : ', center-array(@a, 9).List.raku;
```

```output
array-pad(@a, 6).elems    : 15
center-array(@a, 6).elems : 6
center-array(@a, 6)       : (0, 1, 2, 3, 0, 0)
center-array(@a, 9)       : (0, 0, 0, 1, 2, 3, 0, 0, 0)
```

Those two element counts are the trap. `array-pad`'s second argument is
**padding per side**, so three elements padded by six gives fifteen.
`center-array`'s is a **target total length**, so three centred to six gives
six. The two routines sit next to each other with the same shape of signature
and mean opposite things by their second argument.

`center-array` with a target *smaller* than the input silently truncates, and
omitting the second argument matches a one-argument candidate and returns
nonsense rather than erroring.

## Purity

```raku name="purity"
use Data::Transformers;
use Data::Transformers::Arrays;
use Data::Transformers::Rescale;

my @a = 3, 1, 4, 1, 5;
my @snapshot = @a;

accumulate(@a);
array-pad(@a, 2);
center-array(@a, 9);
rescale(@a);

say 'after all four calls, the input is unchanged : ', @a eqv @snapshot;
say '';
my @out = |accumulate(@a);
@out[0] = -1;
say 'and the result is a fresh container:';
say '  input  : ', @a.List.raku;
say '  result : ', @out.List.raku;
```

```output
after all four calls, the input is unchanged : True

and the result is a fresh container:
  input  : (3, 1, 4, 1, 5)
  result : (-1, 4, 8, 9, 14)
```

All four are pure and return fresh containers, which is not something to take
for granted in a library that reshapes arrays.

## The one thing to know

Rescaling a constant series yields NaN dressed as a `Rat`, with no error.

```raku name="flat-trap"
use Data::Transformers::Rescale;

my @flat = 5, 5, 5;           # a flat sensor reading: perfectly ordinary
my @out = |rescale(@flat);

say 'rescale of a constant series : ', @out.List.raku;
say '  type of the first element  : ', @out[0].^name;
say '  numerator/denominator      : ', @out[0].numerator, '/', @out[0].denominator;
say '  is it NaN                  : ', @out[0].Num.isNaN;
say '';
say 'and the consequences:';
say '  [0] == [1]      : ', @out[0] == @out[1], '   — two identical values, unequal';
say '  the sum         : ', @out.sum.Num;
say '  compared to 0.5 : ', @out[0] > 0.5;
```

```output
rescale of a constant series : (<0/0>, <0/0>, <0/0>)
  type of the first element  : Rat
  numerator/denominator      : 0/0
  is it NaN                  : True

and the consequences:
  [0] == [1]      : False   — two identical values, unequal
  the sum         : NaN
  compared to 0.5 : False
```

The zero-width domain divides by zero and produces `Rat` values with
**denominator 0**. They pass a `Numeric` type check, poison every downstream
sum, and compare unequal to themselves — so a dedupe or an equality test over
rescaled data quietly goes wrong rather than failing.

A flat series is not an edge case: it is what a sensor reads when nothing is
happening. Check the domain width before rescaling.

## Where the two engines differ

Only in diagnostics. Raku++'s `X::Multi::NoMatch` message omits both the
actual arguments and the candidate list where Rakudo prints all three
signatures — which matters here, because the candidate list is how you
discover that `rescale` has three forms.

And `accumulate(1, 2, 3)`, with the arguments unwrapped, is a **compile-time**
error on Rakudo — `Calling accumulate(Int, Int, Int) will never work` — and a
runtime `X::Multi::NoMatch` on Raku++.

One thing that is the same on both and is simply broken: `list-convolve` is
exported and unusable. Its proto is defined with **zero candidates**, so any
call dies with `Routine does not have any candidates. Is only the proto
defined?` And `accumulate` on non-numeric data dies with an unusable message,
because the module is `die`ing with a `Block`.
