---
name: Math::Polynomial::Chebyshev
version: 0.0.2
auth: zef:antononcube
kind: Distribution · numbers
summary: Chebyshev polynomials of the first and second kind — exact on exact
  input, until the denominator outgrows a Rat.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:antononcube/Math::Polynomial::Chebyshev
source: https://github.com/antononcube/Raku-Math-Polynomial-Chebyshev.git
---

## What it is for

Chebyshev polynomials are the workhorses of approximation theory: minimax
interpolation nodes, spectral methods, filter design. `T` is the first kind,
`U` the second, and both are defined by the same three-term recurrence.

## Evaluating

```raku name="basics"
use Math::Polynomial::Chebyshev;

say 'T_n(x) at x = 0.5:';
for 0 .. 5 -> $k {
    say sprintf('  T_%d(0.5) = %s', $k, chebyshev-t($k, 0.5));
}
say '';
say 'the identities, exactly:';
say '  T_n(1)     for n=0..8 : ', (0..8).map({ chebyshev-t($_, 1) }).join(', ');
say '  T_n(-1)    for n=0..6 : ', (0..6).map({ chebyshev-t($_, -1) }).join(', ');
say '  U_n(1)     for n=0..6 : ', (0..6).map({ chebyshev-u($_, 1) }).join(', ');
say '';
say 'and they hold far out:';
say '  T_200(1)  = ', chebyshev-t(200, 1);
say '  U_200(1)  = ', chebyshev-u(200, 1);
```

```output
T_n(x) at x = 0.5:
  T_0(0.5) = 1
  T_1(0.5) = 0.5
  T_2(0.5) = -0.5
  T_3(0.5) = -1
  T_4(0.5) = -0.5
  T_5(0.5) = 0.5

the identities, exactly:
  T_n(1)     for n=0..8 : 1, 1, 1, 1, 1, 1, 1, 1, 1
  T_n(-1)    for n=0..6 : 1, -1, 1, -1, 1, -1, 1
  U_n(1)     for n=0..6 : 1, 2, 3, 4, 5, 6, 7

and they hold far out:
  T_200(1)  = 1
  U_200(1)  = 201
```

## Three argument shapes

```raku name="shapes"
use Math::Polynomial::Chebyshev;

say 'a number  : ', chebyshev-t(3, 2);
say 'a list    : ', chebyshev-t(3, (0, 0.5, 1)).raku;
say 'Whatever  : ', chebyshev-t(4).WHAT.^name, ' — a closure of one variable';
say '  applied : ', chebyshev-t(4).(0.5);
say '  check   : 8x^4 - 8x^2 + 1 at 0.5 = ', (8 * 0.5**4 - 8 * 0.5**2 + 1);
say '';
say 'complex arguments work and are right:';
my $z = chebyshev-t(3, 1+1i);
say '  T_3(1+1i) = ', $z;
my $closed = 4 * (1+1i)**3 - 3 * (1+1i);
say '  matches 4z^3 - 3z at z=1+i : ', abs($z - $closed) < 1e-12;
```

```output
a number  : 26
a list    : [0, -1.0, 1]
Whatever  : Block — a closure of one variable
  applied : -0.5
  check   : 8x^4 - 8x^2 + 1 at 0.5 = -0.5

complex arguments work and are right:
  T_3(1+1i) = -11+5i
  matches 4z^3 - 3z at z=1+i : True
```

## The one thing to know

The default method is **exact** on exact input — until the denominator
outgrows a `Rat`, at which point the result type silently changes to `Num`
mid-sweep.

```raku name="exact"
use Math::Polynomial::Chebyshev;

my $r = chebyshev-t(30, 1/3);
say 'chebyshev-t(30, 1/3):';
say '  type        : ', $r.WHAT.^name;
say '  numerator   : ', $r.numerator;
say '  denominator : ', $r.denominator;
say '';
say 'so == against a float literal fails, and .denominator is meaningful.';
say '';
say 'and the exactness stops without warning:';
for 10, 20, 40, 60, 80 -> $k {
    my $v = chebyshev-t($k, 1/3);
    say sprintf('  k=%-3d %-4s %.15f', $k, $v.WHAT.^name, $v);
}
say '';
say 'once the denominator passes 2**64 a Rat degrades to Num, and the';
say 'result type changes under you. Decide up front: use FatRat inputs if';
say 'you need exactness at large k, or accept Num throughout.';
```

```output
chebyshev-t(30, 1/3):
  type        : Rat
  numerator   : 147764231284649
  denominator : 205891132094649

so == against a float literal fails, and .denominator is meaningful.

and the exactness stops without warning:
  k=10  Rat  0.967213670002879
  k=20  Rat  0.871004566880876
  k=40  Rat  0.517297911054685
  k=60  Num  0.030133119052260
  k=80  Num  -0.464805742436918

once the denominator passes 2**64 a Rat degrades to Num, and the
result type changes under you. Decide up front: use FatRat inputs if
you need exactness at large k, or accept Num throughout.
```

## `:method<trig>` costs the exactness

```raku name="trig"
use Math::Polynomial::Chebyshev;

say 'the recursion is exact where it can be:';
say '  chebyshev-t(3, 2)                 = ', chebyshev-t(3, 2);
say '  chebyshev-t(3, 2, :method<trig>)  = ', chebyshev-t(3, 2, :method<trig>);
say '';
say 'the trigonometric identity is a float path, so you pay accuracy for';
say 'nothing. It is also T-only:';
my $r = try chebyshev-u(3, 0.5, :method<trig>);
say '  chebyshev-u(…, :method<trig>) -> ', $! ?? $!.message !! $r;
say '';
say 'an unrecognised method is a clean die, as is a non-numeric argument:';
for :method<bogus>, :method<rec> -> $m {
    my $v = try chebyshev-t(3, 0.5, |$m);
    say sprintf('  %-18s -> %s', $m.raku, $! ?? 'refused' !! $v);
}
```

```output
the recursion is exact where it can be:
  chebyshev-t(3, 2)                 = 26
  chebyshev-t(3, 2, :method<trig>)  = 25.99999999999999

the trigonometric identity is a float path, so you pay accuracy for
nothing. It is also T-only:
  chebyshev-u(…, :method<trig>) -> Trigonometric method is implemented only for Chebyshev T (first kind) polynomials.

an unrecognised method is a clean die, as is a non-numeric argument:
  :method("bogus")   -> refused
  :method("rec")     -> -1
```

## Where the two engines differ

Nothing in the polynomials: every value on this page is byte-identical on both
engines, and the identities hold to `k = 200` on both. Three core differences
sit nearby and are worth not stepping on.

```raku name="portable"
use Math::Polynomial::Chebyshev;

say 'keep these out of your own code around this module:';
say '';
say '  chebyshev-t(-1, 0.5) — the dispatch failure message differs:';
say '    Raku++ omits the argument types entirely, Rakudo names them.';
say '    Catch X::Multi::NoMatch / X::TypeCheck, never match the text.';
say '';
say '  .map on the Block that chebyshev-t(4) returns — Raku++ has no';
say '    Block.map. Call the block, then map:';
say '    ', (0, 0.5, 1).map({ chebyshev-t(4).($_) }).map(*.round(0.0001)).join(', ');
say '';
say '  .denominator on a Num — 1 on Raku++, a method-not-found on Rakudo.';
say '    Test the TYPE first:';
for 10, 80 -> $k {
    my $v = chebyshev-t($k, 1/3);
    say sprintf('    k=%-3d exact ? %s', $k, ($v ~~ Rat).so);
}
```

```output
keep these out of your own code around this module:

  chebyshev-t(-1, 0.5) — the dispatch failure message differs:
    Raku++ omits the argument types entirely, Rakudo names them.
    Catch X::Multi::NoMatch / X::TypeCheck, never match the text.

  .map on the Block that chebyshev-t(4) returns — Raku++ has no
    Block.map. Call the block, then map:
    1, -0.5, 1

  .denominator on a Num — 1 on Raku++, a method-not-found on Rakudo.
    Test the TYPE first:
    k=10  exact ? True
    k=80  exact ? False
```
