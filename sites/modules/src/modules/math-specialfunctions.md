---
name: Math::SpecialFunctions
version: 0.1.1
auth: zef:antononcube
kind: Distribution · maths
summary: Gamma, factorial, binomial coefficients, Bernoulli numbers and the
  Euler–Mascheroni constant — exact integers and rationals where the answer
  is exact, floating point where it cannot be.
status: full
suite: 4 files, green
tested: 2026-09-15
license: Artistic-2.0
raku-land: https://raku.land/zef:antononcube/Math::SpecialFunctions
source: https://github.com/antononcube/Raku-Math-SpecialFunctions
---

## What it is for

The handful of functions that turn up the moment a program does analysis
rather than arithmetic: the gamma function that extends the factorial to
the whole plane, the exact factorial and binomial coefficient a
combinatorial count needs, the Bernoulli numbers behind Euler–Maclaurin
summation and the zeta function at even integers, and γ, the constant that
relates the harmonic numbers to the logarithm.

Raku's own arithmetic makes an unusual split possible here, and this
distribution takes it: the answers that are exact come back exact —
`factorial` as an `Int` of any size, the Bernoulli numbers as `FatRat`
fractions — and only `gamma` is floating point, because it must be.

## Exact where it can be

```raku name="exact"
use Math::SpecialFunctions;

say factorial(20);
say factorial(30);
say binomial(52, 5);
say bernoulli-b(12), ' = ', bernoulli-b(12).nude.join('/');
say bernoulli-b(2).^name, ' ', bernoulli-b(0).^name;

say gamma(0.5);
say gamma(0.5) ** 2;
say gamma(5);
say factorial(4);
```

```output
2432902008176640000
265252859812191058636308480000000
2598960
-0.253114 = -691/2730
FatRat Int
1.7724538509055163
3.1415926535897944
23.999999999999986
24
```

`Γ(½)` is the square root of π, and squaring it back gets π to fifteen
digits. The last two lines are the same quantity computed two ways:
`gamma(5)` is 4 factorial, and it is not 24 — it is a floating
approximation of 24. Reach for `factorial` whenever the argument is a
non-negative integer and you want the exact value; reach for `gamma` when
it is not.

## The one thing to know

Every Bernoulli number with an odd index above 1 is exactly zero. This
implementation returns the previous even one instead:

```raku name="bernoulli"
use Math::SpecialFunctions;

for 2..9 -> $n {
    say $n, ' -> ', bernoulli-b($n).nude.join('/'),
        ($n %% 2 ?? '' !! '   (should be 0)');
}
say bernoulli-b(3) == bernoulli-b(2);
say bernoulli-b(7) == bernoulli-b(6);
```

```output
2 -> 1/6
3 -> 1/6   (should be 0)
4 -> -1/30
5 -> -1/30   (should be 0)
6 -> 1/42
7 -> 1/42   (should be 0)
8 -> -1/30
9 -> -1/30   (should be 0)
True
True
```

The even-index values are all correct, and every odd one from 3 up is the
even one below it repeated. It is a quiet wrong answer — a plausible
rational, not a `NaN` and not an exception — so a Euler–Maclaurin sum that
runs over every index silently picks up terms that should have vanished.
Sum over even indices only, or test `$n %% 2` yourself and substitute zero.

Two smaller traps in the same family. `factorial(-1)` returns `1` rather
than failing, and `binomial` returns `0` for every case it does not like,
including `binomial(-5, 2)`, whose generalised value is 15. And
`euler-gamma`'s `:prec` is really a two-state switch: up to 16 it answers a
`Num`, and from 17 up it answers one fixed `Rat` whatever you ask for.
