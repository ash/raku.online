---
title: Combinations & permutations
slug: combinatorics
status: full
order: 50
summary: Generate every k-subset or every ordering of a list.
---

`.combinations` yields every subset (order doesn't matter); `.permutations` yields
every ordering (order does). Both are lazy and produced in a deterministic order.

## combinations

`.combinations(k)` returns every `k`-element subset, in order.

```raku
say (1, 2, 3).combinations(2);
```
```output
((1 2) (1 3) (2 3))
```

With no argument it returns subsets of *every* size, from empty to the whole list.

## permutations

`.permutations` returns every ordering — `n!` of them for `n` elements.

```raku
say <a b c>.permutations.elems;
say <a b c>.permutations.map(*.join).sort;
```
```output
6
(abc acb bac bca cab cba)
```

## Notes

- Both are lazy `Seq`s, so `.permutations` of a large list is fine to take from with
  `[^k]` without generating all `n!` up front.
- Each result is a sublist, so `say` shows them nested — `((1 2) (1 3) (2 3))`.
- For random selection instead of exhaustive generation, use `.pick` (without
  replacement) or `.roll` (with replacement).
