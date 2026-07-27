---
title: The Whatever star  *
slug: whatever
status: full
order: 88
summary: A lone * that builds a one-argument function, or stands for "the end" in an index.
---

A bare `*` is the **Whatever** star. In most expressions it curries into a
`WhateverCode` — a compact one-argument function — and in a subscript it means "from
the end". It's what makes `* > 2` and `[*-1]` read so cleanly.

## Currying into a function

An expression containing `*` becomes a function of the `*`s. `* * 2` is
"multiply by two"; `* + *` is a two-argument adder.

```raku
my &double = * * 2;
say double(5);
say (* + *)(3, 4);
```
```output
10
7
```

## In a subscript — from the end

Inside `[ ]`, `*` stands for the number of elements, so `*-1` is the last index.

```raku
say [10, 20, 30, 40][*-1];
say (1..10)[*-2];
```
```output
40
9
```

## As a predicate

Because `* > 2` is a function, it drops straight into `grep`, `map`, `sort`, and
`when`.

```raku
say (1..5).grep(* > 2);
```
```output
(3 4 5)
```

## Notes

- The currying is per-expression: each `*` becomes one parameter, bound left to
  right, so `* - *` called with `(10, 3)` is `7`.
- Currying stops at a `,` or a statement boundary; to use `*` across a wider
  expression (like a whole `~~`), parenthesise the part you want curried —
  `~~ (* > 2)`, not `~~ * > 2`.
- A standalone `*` in list context is a different beast — `Inf`-like "whatever the
  callee wants" — e.g. `1, 2 ... *` for an unbounded sequence.
