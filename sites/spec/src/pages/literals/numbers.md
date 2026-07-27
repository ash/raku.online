---
title: Number forms — Num & Complex
slug: numbers
status: full
order: 25
summary: Floating point via scientific notation, and complex numbers with the i postfix.
---

Beyond exact `Int` and `Rat`, Raku has `Num` (IEEE 754 floating point) and `Complex`.
Scientific notation produces a `Num`; the `i` postfix produces a `Complex`.

## Scientific notation is a Num

A number written with an `e` exponent is a `Num` — floating point, not a rational.

```raku
say 1e3;
say 1.5e-2;
say (1e0).^name;
```
```output
1000
0.015
Num
```

## Complex numbers

Append `i` for the imaginary unit. Complex literals print in `a+bi` form, and
`.abs` gives the magnitude.

```raku
say 2i;
say (1 + 2i);
say (1+2i).abs;
```
```output
0+2i
1+2i
2.23606797749979
```

Arithmetic follows the usual complex rules:

```raku
say (1+1i) * (1-1i);
```
```output
2+0i
```

## Notes

- `1e0` is the idiomatic way to write "the floating-point one" and to force a value
  into `Num` context.
- `Num` is inexact — prefer `Rat` (a plain decimal like `0.1`) when you need exact
  arithmetic; see [Rational literals](/literals/rationals/).
- The numeric tower is `Int` ⊂ `Rat` ⊂ `Num` ⊂ `Complex`; operations promote to the
  widest type involved.
