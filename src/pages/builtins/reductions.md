---
title: Reductions — sum, min, max & [OP]
slug: reductions
status: full
order: 30
summary: Collapse a list to a single value with sum/min/max or the reduction metaoperator.
---

Reducing folds a list down to one value. Common reductions have named routines
(`sum`, `min`, `max`), and *any* infix operator can reduce via the `[ ]`
metaoperator.

## The reduction metaoperator `[OP]`

`[+]` inserts `+` between all the elements — `[+] 1..5` is `1 + 2 + 3 + 4 + 5`.
Any associative infix works: `[*]` multiplies.

```raku
say [+] 1..5;
say [*] 1..5;
```
```output
15
120
```

## Named reductions

`sum`, `min`, and `max` are the common ones as methods (or subs).

```raku
say (3, 7, 2, 9).max;
say (3, 7, 2, 9).min;
say (1..5).sum;
```
```output
9
2
15
```

## Notes

- `[+] ()` on an empty list returns the operator's identity — `0` for `+`, `1` for
  `*` — rather than failing.
- `[<]` reduces a comparison: `[<] 1, 2, 3` is `True` (the list is strictly
  increasing), a neat use of chaining.
- For a custom fold, `reduce` takes the operator explicitly:
  `(1..5).reduce(&infix:<+>)` equals `[+] 1..5`.
