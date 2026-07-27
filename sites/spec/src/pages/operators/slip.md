---
title: The slip operator  |
slug: slip
status: full
order: 98
summary: Flatten a list into the surrounding list, in place.
---

Prefix `|` turns a list into a **Slip** — a list that dissolves into its container.
Where a nested list would stay nested, a slipped one merges its elements into the
enclosing list.

## Flattening in place

```raku
my @a = 1, |(2, 3), 4;
say @a;
say (1, |(2, 3), 4).elems;
```
```output
[1 2 3 4]
4
```

Without the `|`, `(2, 3)` would be one nested element; slipped, its `2` and `3` sit
directly in the list, so the total length is `4`.

## Notes

- `|` is also how you pass a list as separate arguments to a call: `f(|@args)` spreads
  `@args` into `f`'s parameters (the reverse of a slurpy `*@`).
- A `Slip` is a real value (`slip(2, 3)` or the `Slip` type) — returning one from a
  `map` block lets a single element expand into several results.
- It's the list-level analogue of the `|` in signatures/captures, and distinct from
  the numeric/junction `|` (an `any` junction on numbers).
