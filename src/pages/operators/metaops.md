---
title: Metaoperators — Z, X, R & hyper
slug: metaops
status: full
order: 80
summary: Operators that transform other operators — zip, cross, reverse, and hyper.
---

A **metaoperator** modifies another operator. `Z` and `X` pair up lists, `R`
reverses operands, and the hyper form `»OP«` applies an operator element-wise across
a list. They compose with almost any infix.

## Zip — `Z` and `ZOP`

`Z` interleaves two lists into pairs; gluing an operator on (`Z+`) combines each pair
with that operator instead.

```raku
say (1, 2, 3) Z (4, 5, 6);
say (1, 2, 3) Z+ (10, 20, 30);
```
```output
((1 4) (2 5) (3 6))
(11 22 33)
```

## Cross — `X` and `XOP`

`X` forms every combination across its lists; `XOP` applies an operator to each
combination.

```raku
say (1, 2) X (3, 4);
say (1, 2) X* (3, 4);
```
```output
((1 3) (1 4) (2 3) (2 4))
(3 4 6 8)
```

## Reverse — `ROP`

`R` swaps an operator's operands: `10 R- 3` means `3 - 10`.

```raku
say 10 R- 3;
```
```output
-7
```

## Hyper — `»OP«`

The hyper metaoperator applies an operator to every element of a list (pairing up
with a second list, or broadcasting a scalar).

```raku
say (1, 2, 3) >>+>> 10;
say (-1, 2, -3)>>.abs;
```
```output
(11 12 13)
(1 2 3)
```

## Notes

- These stack with the reduction metaoperator: `[Z+]` reduces with zip-plus, and so
  on.
- Hyper operations are explicitly parallel-friendly and may run in any order, so the
  operator should be side-effect-free; the `»«` "pointing" arrows show which side
  may be extended to match lengths.
- `>>.method` hypers a **method call** across a list — a concise map:
  `@words>>.uc` upper-cases each element.
