---
title: map / grep / sort
slug: higher-order
status: full
order: 20
summary: Transform, filter, and order a list by passing it a block.
---

The workhorse list routines each take a **block** and apply it across a list: `map`
transforms every element, `grep` keeps the ones that match, and `sort` orders them.

## map — transform

```raku
say (1..5).map(* * 2);
```
```output
(2 4 6 8 10)
```

`* * 2` is a `Whatever` block — a one-argument function that doubles its input.

## grep — filter

`grep` keeps elements for which the block is true. Here `* %% 2` tests divisibility
by two.

```raku
say (1..10).grep(* %% 2);
```
```output
(2 4 6 8 10)
```

## sort — order

With no argument, `sort` orders by the elements' natural `cmp`. Pass a block to sort
by a computed key instead.

```raku
say <banana apple cherry>.sort;
say <ccc a bb>.sort(*.chars);
```
```output
(apple banana cherry)
(a bb ccc)
```

## Notes

- These compose in a pipeline: `(1..10).grep(* %% 2).map(* ** 2)` filters then
  transforms, reading left to right.
- All three are lazy-friendly and return a `Seq`; assign to an `@array` or call
  `.list`/`.Array` to reify.
- A `sort` block of one parameter is a **key extractor** (sort by its result); a
  block of two parameters is a **comparator** returning `Order`.
