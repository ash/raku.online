---
name: Statistics::LinearRegression
version: 1.1.2
auth: zef:raku-community-modules
kind: Distribution · statistics
summary: Ordinary least-squares in exact Rat arithmetic — and a degenerate fit
  returns a defined Rat with denominator zero.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/Statistics::LinearRegression
source: https://github.com/raku-community-modules/Statistics-LinearRegression.git
---

## What it is for

Fitting a straight line to paired measurements: the slope and intercept that
minimise the squared vertical error. This distribution computes them with the
closed-form normal equations, keeping everything exact when the inputs are
integers.

## Fitting

```raku name="basics"
use Statistics::LinearRegression;

my @x = 1, 2, 3, 4, 5, 6;
my @y = 2, 4, 5, 4, 5, 7;

my $lr = LR.new(@x, @y);
my ($slope, $intercept) = $lr.get-parameters;
say 'slope      : ', $slope, '   (', $slope.WHAT.^name, ')';
say 'intercept  : ', $intercept;
say 'at x = 10  : ', $lr.at(10);
say '';
my $sx  = @x.sum;
my $sy  = @y.sum;
my $sxy = (@x Z* @y).sum;
my $sxx = (@x Z* @x).sum;
my $n   = @x.elems;
my $closed = ($n * $sxy - $sx * $sy) / ($n * $sxx - $sx * $sx);
say 'closed form: ', $closed;
say 'matches    : ', $slope == $closed;
say '';
say 'results are exact Rats, not Nums, when the inputs are integers.';
```

```output
slope      : 0.771429   (Rat)
intercept  : 1.8
at x = 10  : 9.514286

closed form: 0.771429
matches    : True

results are exact Rats, not Nums, when the inputs are integers.
```

`LR` takes either two lists or two numbers — data or parameters:

```raku name="two-forms"
use Statistics::LinearRegression;

my $fit = LR.new([1, 2, 3], [3, 2, 1]);
say 'from data       : ', $fit.get-parameters.raku;
my $line = LR.new(7, 3);
say 'from parameters : ', $line.get-parameters.raku, '  (slope 7, intercept 3)';
say '  at x = 2      : ', $line.at(2);
say '';
say 'two numbers are parameters, two lists are data, and nothing warns if';
say 'you mix them up.';
say '';
say 'the four helper subs are behind an import tag:';
say '  use Statistics::LinearRegression :ALL;';
say '  calc-slope, calc-intercept, get-parameters, value-at';
say 'a plain `use` gives you LR only.';
```

```output
from data       : (-1.0, 4.0)
from parameters : (7, 3)  (slope 7, intercept 3)
  at x = 2      : 17

two numbers are parameters, two lists are data, and nothing warns if
you mix them up.

the four helper subs are behind an import tag:
  use Statistics::LinearRegression :ALL;
  calc-slope, calc-intercept, get-parameters, value-at
a plain `use` gives you LR only.
```

## The one thing to know

A degenerate fit — one point, or every `x` the same — returns a **defined**
`Rat` with denominator 0. It does not throw, it is not `Nil`, and it is not
equal to 0. It detonates later, at the first stringification.

```raku name="degenerate"
use Statistics::LinearRegression;

my ($slope, $intercept) = LR.new([2, 2, 2], [1, 2, 3]).get-parameters;
say 'all x equal:';
say '  .WHAT        : ', $slope.WHAT.^name;
say '  .defined     : ', $slope.defined;
say '  .denominator : ', $slope.denominator;
say '  == 0         : ', $slope == 0;
say '  .Num         : ', $slope.Num;
my $s = try $slope.Str;
say '  .Str         : ', $! ?? 'throws X::Numeric::DivideByZero' !! $s;
say '';
say 'so `if $slope.defined { … }` passes, the bad value propagates through';
say '.at() unchanged, and the program dies at whatever line first PRINTS';
say 'it. Guard on the denominator:';
sub fit(@x, @y) {
    my ($m, $b) = LR.new(@x, @y).get-parameters;
    die 'degenerate fit: the x values do not vary' if $m.denominator == 0;
    ($m, $b)
}
for ([1, 2, 3], [3, 2, 1]), ([2, 2, 2], [1, 2, 3]) -> (@x, @y) {
    my $r = try fit(@x, @y);
    say sprintf('  fit(%-12s) -> %s', @x.raku, $! ?? $!.message !! $r.raku);
}
```

```output
all x equal:
  .WHAT        : Rat
  .defined     : True
  .denominator : 0
  == 0         : False
  .Num         : NaN
  .Str         : throws X::Numeric::DivideByZero

so `if $slope.defined { … }` passes, the bad value propagates through
.at() unchanged, and the program dies at whatever line first PRINTS
it. Guard on the denominator:
  fit([1, 2, 3]   ) -> $(-1.0, 4.0)
  fit([2, 2, 2]   ) -> degenerate fit: the x values do not vary
```

## No length check

```raku name="mismatch"
use Statistics::LinearRegression;

say 'mismatched list lengths are NOT checked:';
say '  LR.new([1,2,3], [1,2]).get-parameters = ',
    LR.new([1, 2, 3], [1, 2]).get-parameters.raku;
say '  LR.new([1,2], [1,2,3]).get-parameters = ',
    LR.new([1, 2], [1, 2, 3]).get-parameters.raku;
say '';
say 'N comes from +@x while only min(@x, @y) cross terms exist, so you';
say 'get a silently wrong fit rather than an error. Check first:';
sub fit(@x, @y) {
    die "x has {+@x} points, y has {+@y}" unless @x.elems == @y.elems;
    LR.new(@x, @y).get-parameters
}
my $r = try fit([1, 2, 3], [1, 2]);
say '  ', $! ?? $!.message !! $r.raku;
say '';
say 'and empty lists give the same <0/0> as the degenerate case:';
say '  LR.new([], []).get-parameters = ', LR.new([], []).get-parameters.raku;
```

```output
mismatched list lengths are NOT checked:
  LR.new([1,2,3], [1,2]).get-parameters = (-0.5, 2.0)
  LR.new([1,2], [1,2,3]).get-parameters = (-8.0, 15.0)

N comes from +@x while only min(@x, @y) cross terms exist, so you
get a silently wrong fit rather than an error. Check first:
  x has 3 points, y has 2

and empty lists give the same <0/0> as the degenerate case:
  LR.new([], []).get-parameters = (<0/0>, <0/0>)
```

## Where the two engines differ

Nothing. Every coefficient, every type and every degenerate case above is
identical on both engines — this is exact rational arithmetic with no
container, hash or laziness question in it, which is the shape that ports
cleanly.

```raku name="portable"
use Statistics::LinearRegression;

# a fit that reports what it did, and refuses what it cannot do
sub regress(@x, @y) {
    die "x has {+@x} points, y has {+@y}" unless @x.elems == @y.elems;
    die 'need at least two points'        unless @x.elems >= 2;
    my $lr = LR.new(@x, @y);
    my ($m, $b) = $lr.get-parameters;
    die 'the x values do not vary'        if $m.denominator == 0;
    %( slope => $m, intercept => $b, predict => -> $x { $lr.at($x) } )
}
my %f = regress([1, 2, 3, 4], [2, 4, 6, 8]);
say 'slope     : ', %f<slope>;
say 'intercept : ', %f<intercept>;
say 'predict 10: ', %f<predict>(10);
say '';
say 'the class`s full name is Statistics::LinearRegression::LR; `LR` is';
say 'what a plain `use` exports it as.';
```

```output
slope     : 2
intercept : 0
predict 10: 20

the class`s full name is Statistics::LinearRegression::LR; `LR` is
what a plain `use` exports it as.
```
