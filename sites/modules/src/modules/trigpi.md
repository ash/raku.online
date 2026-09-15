---
name: TrigPi
version: 1.6.0
auth: github:grondilu
kind: Distribution · numbers
summary: sin(πx), cos(πx) and cis(πx) computed so the values that ought to be
  exactly 0 and ±1 are — including a negative zero.
status: divergent
suite: 2 files, green
tested: 2026-09-15
license: MIT
depends: none beyond the core
raku-land: https://raku.land/github:grondilu/TrigPi
source: git://github.com/grondilu/trigpi.git
---

## What it is for

`sin(pi)` is not 0, it is 1.22e-16, because `pi` is not π. Anywhere you
compute a trigonometric function of a *rational multiple* of π — rotations by
a quarter turn, roots of unity, a DFT twiddle factor — that residue is noise
you did not ask for.

This distribution takes the multiplier instead of the angle, reduces it into
[0, ½) with the reflection and periodicity identities, and only then calls the
core function.

## The win

```raku name="basics"
use TrigPi;

say 'sinPi(1)   == 0 exactly  : ', sinPi(1) == 0,   '      sin(pi)   = ', sin(pi);
say 'cosPi(1)   == -1 exactly : ', cosPi(1) == -1,  '      cos(pi)   = ', cos(pi);
say 'sinPi(1/2) == 1 exactly  : ', sinPi(1/2) == 1;
say 'cosPi(1/2) == 0 exactly  : ', cosPi(1/2) == 0, '      cos(pi/2) = ', cos(pi/2);
say 'sinPi(1e6) == 0 exactly  : ', sinPi(1e6) == 0;
say '  sin(pi*1e6) = ', sin(pi * 1e6);
say '';
say '|cisPi(x)| is exactly 1 at the quarter points:';
for 0, 1/4, 1/3, 1/2, 1 -> $x {
    say sprintf('  cisPi(%-4s) abs = %s', $x, cisPi($x).abs);
}
```

```output
sinPi(1)   == 0 exactly  : True      sin(pi)   = 1.2246467991473532e-16
cosPi(1)   == -1 exactly : True      cos(pi)   = -1
sinPi(1/2) == 1 exactly  : True
cosPi(1/2) == 0 exactly  : True      cos(pi/2) = 6.123233995736766e-17
sinPi(1e6) == 0 exactly  : True
  sin(pi*1e6) = -2.231912181360871e-10

|cisPi(x)| is exactly 1 at the quarter points:
  cisPi(0   ) abs = 1
  cisPi(0.25) abs = 1
  cisPi(0.333333) abs = 1
  cisPi(0.5 ) abs = 1
  cisPi(1   ) abs = 1
```

## The one thing to know

`sinPi` of an integer is **negative zero**, and `cisPi(1)` carries it into the
imaginary part.

```raku name="negative-zero"
use TrigPi;

for 0, 1, 2, 3, -1 -> $n {
    say sprintf('  sinPi(%-3d) gist = %s', $n, sinPi($n).gist);
}
say '';
say 'cisPi(1)        = ', cisPi(1);
say 'cisPi(1).im     = ', cisPi(1).im.gist;
say '';
say 'the reduction for 1 <= x < 2 is -sinPi($x - 1), and negating 0e0';
say 'gives -0e0.';
say '';
say 'ordinary comparisons are fine:';
say '  sinPi(1) == 0      : ', sinPi(1) == 0;
say '  sinPi(1).sign      : ', sinPi(1).sign;
say 'but identity and printing are not:';
say '  sinPi(1) === 0e0   : ', sinPi(1) === 0e0;
say '  it prints as       : ', sinPi(1).gist;
say '';
say 'anything that branches on the printed form, round-trips through a';
say 'string, or DIVIDES by the result will see the sign.';
```

```output
  sinPi(0  ) gist = 0
  sinPi(1  ) gist = -0
  sinPi(2  ) gist = 0
  sinPi(3  ) gist = -0
  sinPi(-1 ) gist = 0

cisPi(1)        = -1-0i
cisPi(1).im     = -0

the reduction for 1 <= x < 2 is -sinPi($x - 1), and negating 0e0
gives -0e0.

ordinary comparisons are fine:
  sinPi(1) == 0      : True
  sinPi(1).sign      : 0
but identity and printing are not:
  sinPi(1) === 0e0   : False
  it prints as       : -0

anything that branches on the printed form, round-trips through a
string, or DIVIDES by the result will see the sign.
```

## What the claim does and does not cover

```raku name="scope"
use TrigPi;

say 'the accuracy claim covers the REDUCTION, not the underlying sin:';
say '  sinPi(1/6) == 1/2 ? ', sinPi(1/6) == 1/2, '   value ', sinPi(1/6);
say '  cosPi(1/3) == 1/2 ? ', cosPi(1/3) == 1/2, '   value ', cosPi(1/3);
say '  those are bit-identical to sin(pi/6) and cos(pi/3).';
say '';
say 'and the return TYPE is not stable — at half-integers you get an Int:';
for 0, 0.5, 1, 1.5 -> $x {
    say sprintf('  sinPi(%-4s) %-4s   cosPi(%-4s) %s',
                $x, sinPi($x).WHAT.^name, $x, cosPi($x).WHAT.^name);
}
say '';
say 'the declared return type is Real, so this is legal — and it means';
say 'sinPi(1/2) is an exact Int 1 while sinPi(1) is a Num negative zero.';
say '';
say 'huge and exact arguments are both fine:';
say '  sinPi(10**20)      = ', sinPi(10**20);
say '  cosPi(FatRat.new(1, 3)).round(0.0001) = ',
    cosPi(FatRat.new(1, 3)).round(0.0001);
```

```output
the accuracy claim covers the REDUCTION, not the underlying sin:
  sinPi(1/6) == 1/2 ? False   value 0.49999999999999994
  cosPi(1/3) == 1/2 ? False   value 0.5000000000000001
  those are bit-identical to sin(pi/6) and cos(pi/3).

and the return TYPE is not stable — at half-integers you get an Int:
  sinPi(0   ) Num    cosPi(0   ) Num
  sinPi(0.5 ) Int    cosPi(0.5 ) Int
  sinPi(1   ) Num    cosPi(1   ) Num
  sinPi(1.5 ) Int    cosPi(1.5 ) Int

the declared return type is Real, so this is legal — and it means
sinPi(1/2) is an exact Int 1 while sinPi(1) is a Num negative zero.

huge and exact arguments are both fine:
  sinPi(10**20)      = 0
  cosPi(FatRat.new(1, 3)).round(0.0001) = 0.5
```

## Where the two engines differ

Two, and both are reached from this module's own output. Dividing by a
floating-point zero gives ±`Inf` under Raku++ and raises
`X::Numeric::DivideByZero` under Rakudo — and `sinPi` of an integer is exactly
such a zero. And `NaN` or `Inf` as an argument recurses forever: Raku++ has a
recursion guard and throws `X::Recursion`, Rakudo hangs.

```raku name="portable"
use TrigPi;

say 'guard both at the call site:';
sub cot-pi($x) {
    my $s = sinPi($x);
    die "cot(pi*$x) is undefined" if $s == 0;
    cosPi($x) / $s
}
for 1/4, 1 -> $x {
    my $r = try cot-pi($x);
    say sprintf('  cot-pi(%-4s) -> %s', $x, $! ?? $!.message !! $r.round(0.0001));
}
say '';
sub safe-sinPi($x) {
    die "sinPi needs a finite argument" unless $x.defined && $x != Inf && $x != -Inf && $x == $x;
    sinPi($x)
}
for 0.25, NaN -> $x {
    my $r = try safe-sinPi($x);
    say sprintf('  safe-sinPi(%-5s) -> %s', $x, $! ?? 'refused' !! $r.round(0.0001));
}
say '';
say 'without those two guards, the same program raises on one engine and';
say 'hangs or answers Inf on the other.';
```

```output
guard both at the call site:
  cot-pi(0.25) -> 1
  cot-pi(1   ) -> cot(pi*1) is undefined

  safe-sinPi(0.25 ) -> 0.7071
  safe-sinPi(NaN  ) -> refused

without those two guards, the same program raises on one engine and
hangs or answers Inf on the other.
```
