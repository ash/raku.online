---
title: min / max / ≅
slug: min-max
status: full
order: 25
summary: Infix operators that pick the smaller or larger value, and compare with tolerance.
---

Besides the `.min`/`.max` [methods](/methods/minmax/), `min` and `max` are also
**infix operators** that return the lesser or greater of two values. `≅`
(approximately-equal) compares with a small tolerance — useful for floating point.

## min and max

```raku
say 5 min 3;
say 5 max 3;
say 2 min 8 min 5;
```
```output
3
5
2
```

They chain, so `2 min 8 min 5` is the smallest of the three.

## Approximately-equal — ≅

`≅` (or its ASCII spelling `=~=`) is true when two numbers are within a small
relative tolerance — the right test for floating-point results that should be "equal"
but for rounding.

```raku
say (0.1 + 0.2) ≅ 0.3;
say 1.0 ≅ 1.0000001;
```
```output
True
False
```

## Notes

- The infix `min`/`max` are handy inline (`$x = $lo max $n min $hi` clamps `$n`),
  while the methods reduce a whole list.
- `≅` matters for `Num` (floating point); exact `Rat` arithmetic (like `0.1 + 0.2`)
  is already exactly `0.3`, so there `==` suffices — see
  [Rational literals](/literals/rationals/).
- There are matching `minmax` reductions: `[min] @xs` and `[max] @xs` fold a list to
  its extreme with the [reduction metaoperator](/operators/reductions/).
