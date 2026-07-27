---
title: Booleans
slug: booleans
status: full
order: 5
summary: True and False, how any value becomes Boolean, and that Bool is a number.
---

`Bool` has two values, `True` and `False`. Any value can be viewed as a Boolean —
its "truthiness" — and `Bool` is itself an `Int` enum, so it participates in
arithmetic.

## The two values

```raku
say True;
say False;
say True.Int;
```
```output
True
False
1
```

## Truthiness — `so` / `?`

`so` (and the prefix `?`) coerces any value to `Bool`. Zero, the empty string, and
empty collections are false; almost everything else is true.

```raku
say so 5;
say so 0;
say so "";
```
```output
True
False
False
```

## Bool is a number

`True` and `False` are the enum values `1` and `0`, so they add up — handy for
counting matches.

```raku
say True + True;
say (5 > 3);
```
```output
2
True
```

## Notes

- Because `Bool` numifies, `+@matches.grep(...)` or `[+] @flags` counts true values
  directly.
- Comparison and logic operators return `Bool`; a bare regex match returns a truthy
  `Match`, which `so`/`?` collapse to `True`/`False`.
- The negation `!` and the low-precedence `not` produce `Bool` from any value:
  `!0` is `True`.
