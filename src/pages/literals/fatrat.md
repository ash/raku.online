---
title: FatRat — unlimited-precision rationals
slug: fatrat
status: full
order: 28
summary: A rational whose numerator and denominator grow without bound.
---

A `FatRat` is like a [`Rat`](/literals/rationals/) but with no limit on the size
of its denominator. Where a `Rat` degrades to floating point once its denominator
outgrows a machine word, a `FatRat` stays exact however large the parts become.

## Exact past the Rat limit

```raku
say (10 ** 20).FatRat / 3 + 1;
say (1/3).FatRat.WHAT;
```
```output
33333333333333333334.333333
(FatRat)
```

The value is held exactly as a big numerator over `3`; `say` still rounds the
*display* to six places, but the stored value is precise.

## Exactly reversible

Because nothing is lost to floating point, operations undo cleanly — a third times
three is exactly one, not `0.9999…`.

```raku
my $f = (1/3).FatRat;
say $f * 3;
say $f * 3 == 1;
```
```output
1
True
```

## Notes

- Coerce into the type with `.FatRat`; arithmetic that mixes a `FatRat` with other
  numbers promotes the result to `FatRat`, keeping it exact.
- Use it when you need exact rationals with very large or repeatedly-multiplied
  denominators (continued fractions, high-precision series); a plain `Rat` is fine for
  everyday decimals.
- The numeric tower is `Int` ⊂ `Rat` ⊂ `FatRat` ⊂ `Num`; `FatRat` sits above `Rat`
  precisely because it removes the denominator-size ceiling.
