---
title: Rational literals
slug: rationals
status: full
order: 20
summary: Decimals and fractions are exact rationals (Rat), not floating point.
---

A number written with a decimal point, or produced by dividing two integers, is a
`Rat` — an exact rational held as a numerator/denominator pair. This is why Raku
does not suffer the classic floating-point surprise.

## Division yields a Rat

```raku
say 1/3;
say (1/3).^name;
```
```output
0.333333
Rat
```

The value is stored exactly as 1/3; only its *display* is rounded to six decimal
places by `say`. To see the exact value, ask for it:

```raku
say (1/3).raku;
say (3/4).nude;
```
```output
<1/3>
(3 4)
```

`.nude` returns the "nude" numerator and denominator as a list; `.raku` shows the
literal form that would reconstruct the value.

## Decimal literals are exact

Because decimals are rationals, sums that famously misbehave in floating point are
exact here.

```raku
say 0.1 + 0.2;
```
```output
0.3
```

## Comparison with the same thing in floating point

| Expression      | Rat (Raku default) | Num / IEEE 754 |
| --------------- | ------------------ | -------------- |
| `0.1 + 0.2`     | `0.3` (exact)      | `0.30000000000000004` |
| `(1/3) * 3`     | `1` (exact)        | `0.9999999999999999`  |

> To opt into floating point, write a number in scientific notation (`1e0`) or
> coerce with `.Num`. See [Number literals](/literals/numbers/) once written.

## Notes

- A `Rat` keeps its denominator in a machine word. When a denominator would grow
  past that, the value degrades to a `Num` (floating point) rather than slowing to
  a crawl — a deliberate performance trade also made by Rakudo.
- Equality is exact: `0.1 + 0.2 == 0.3` is `True`, unlike in most languages.
