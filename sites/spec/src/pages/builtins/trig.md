---
title: Trigonometry — sin, cos, tan & friends
slug: trig
status: full
order: 52
summary: Trigonometric and hyperbolic functions, in radians, as subs or methods.
---

Raku provides the full set of trigonometric functions — `sin`, `cos`, `tan`, their
inverses, reciprocals, and hyperbolic variants. Each works as a **sub** (`sin($x)`) or
a **method** (`$x.sin`), and all angles are in **radians**. The constants `pi`, `tau`
(`2·pi`), and `e` are built in.

## Sine, cosine, tangent

```raku
say sin(0);
say cos(pi);
say (pi/2).sin;
```
```output
0
-1
1
```

`cos(pi)` is `-1`, and the method form `(pi/2).sin` is `1` — a quarter turn's sine.

## Working in radians

Angles are radians, so convert from degrees by multiplying by `pi/180`. `sin` of 30°
is `0.5`.

```raku
say sin(30 * pi / 180).round(1e-9);
say cos(60 * pi / 180).round(1e-9);
```
```output
0.5
0.5
```

## Inverse functions

`asin`, `acos`, `atan`, and the two-argument `atan2` return an angle in radians.
`atan2(y, x)` is the angle of the point `(x, y)` — the robust way to get a bearing.

```raku
say atan2(1, 1);
say asin(1);
```
```output
0.7853981633974483
1.5707963267948966
```

`atan2(1, 1)` is `π/4` (45°) and `asin(1)` is `π/2` (90°), both in radians.

## Hyperbolic functions

`sinh`, `cosh`, and `tanh` (with inverses `asinh`, `acosh`, `atanh`) are the
hyperbolic counterparts.

```raku
say sinh(0);
say cosh(0);
say tanh(0);
```
```output
0
1
0
```

## Notes

- The reciprocal functions are `sec`, `cosec`/`csc`, and `cotan`/`cot`, each with an
  inverse (`asec`, …) and a hyperbolic form (`sech`, …) — the same naming throughout.
- Every function comes in sub form (`atan($x)`) and method form (`$x.atan`); use
  whichever reads better in context.
- Results are `Num` (floating point), so irrational values print in full precision;
  `.round(1e-9)` tidies a display without changing the maths.
- For the polar/rectangular bridge, `cis(θ)` gives `cos θ + i·sin θ` as a `Complex` —
  see [Complex methods](/methods/complex/).
