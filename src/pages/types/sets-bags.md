---
title: Sets & Bags
slug: sets-bags
status: full
order: 80
summary: Immutable collections — a Set of distinct elements, a Bag with counts.
---

A `Set` is an unordered collection of distinct elements; a `Bag` is the same but
keeps a **count** of each. Both are immutable and pair with the
[set operators](/operators/set-ops/).

## Set — distinct elements

`set(...)` deduplicates. Membership and size are `O(1)`; iteration order is
undefined, so sort when you need determinism.

```raku
my $s = set(1, 2, 2, 3);
say $s.elems;
say $s.keys.sort;
```
```output
3
(1 2 3)
```

## Bag — elements with counts

`bag(...)` counts occurrences. Subscripting returns an element's count, `.total` the
sum of all counts.

```raku
my $b = bag(<a a b>);
say $b.elems;
say $b<a>;
say $b.total;
```
```output
2
2
3
```

`.elems` is the number of *distinct* keys (2: `a` and `b`); `.total` is the number of
items counted (3).

## Notes

- Any list coerces with `.Set` / `.Bag`: `<a b b c>.Bag` builds the bag directly.
- `Mix` is the third member — like a `Bag` but with fractional/real weights instead
  of integer counts.
- These are immutable; their mutable cousins are `SetHash` and `BagHash`, which you
  can add to and remove from.
