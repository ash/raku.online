---
title: polymod — successive division
slug: polymod
status: full
order: 70
summary: Break a number into mixed-radix parts in one call — seconds into h/m/s, etc.
---

`.polymod` divides a number by a series of moduli in turn, returning the remainder at
each step and the final quotient. It's the clean way to convert a total into
mixed-radix units.

## Time from seconds

`3723.polymod(60, 60)` peels off seconds, then minutes, leaving hours: `3` seconds,
`2` minutes, `1` hour.

```raku
say 3723.polymod(60, 60);
```
```output
(3 2 1)
```

## The general shape

Each modulus divides the running quotient; the last element is whatever remains.

```raku
say 10.polymod(3);
```
```output
(1 3)
```

`10 mod 3` is `1` (first element); the quotient `3` is the last.

## Notes

- The result has one more element than the number of moduli — the remainders, then
  the final quotient.
- Read it low-to-high: with `(60, 60)` the parts come out seconds, minutes, hours —
  reverse them for the usual h:m:s display.
- `.polymod` with an infinite/lazy list of moduli keeps going until the quotient
  reaches zero, handy for arbitrary-length digit extraction.
