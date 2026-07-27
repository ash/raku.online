---
title: Complex methods
slug: complex
status: full
order: 48
summary: Pull apart a complex number — real & imaginary parts, conjugate, magnitude.
---

A `Complex` (see [Number forms](/literals/numbers/)) carries a real and an
imaginary part, and offers the usual methods to inspect and transform it.

## Parts, conjugate, magnitude

`.re` and `.im` are the real and imaginary parts; `.conj` flips the sign of the
imaginary part; `.abs` is the magnitude.

```raku
say (3 + 4i).re;
say (3 + 4i).im;
say (3 + 4i).conj;
say (3 + 4i).abs;
```
```output
3
4
3-4i
5
```

`(3 + 4i).abs` is `5` — the hypotenuse of the 3–4 right triangle.

## Polar form

`.polar` returns the number as a `(magnitude, angle)` pair — the magnitude is `.abs`,
and the angle is measured in radians from the positive real axis.

```raku
my ($mag, $ang) = (3 + 4i).polar;
say $mag;
say $ang.round(0.0001);
```
```output
5
0.9273
```

## Arithmetic

The usual operators work on `Complex` values directly, combining real and imaginary
parts for you.

```raku
say (1 + 1i) * (1 + 1i);
say (2 + 3i) + (1 - 1i);
```
```output
0+2i
3+2i
```

`(1 + 1i)²` is `0 + 2i` — the imaginary parts multiply to `-1`, cancelling the real
part.

## Notes

- `.re`/`.im` are the parts, `.conj` the conjugate, `.abs` the magnitude, and
  `.polar` the `(magnitude, angle)` form.
- The imaginary unit is the `i` postfix: `2i` is `0+2i` — see
  [Number forms](/literals/numbers/).
- `sqrt` extends to `Complex`, so `(1 + 0i).sqrt` is `1+0i`; taking `sqrt` of a real
  negative (`(-1).sqrt`) gives `NaN`, so start from a `Complex` for an imaginary root.
