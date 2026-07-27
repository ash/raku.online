---
title: Shaped arrays  @a[i;j]
slug: shaped-arrays
status: full
order: 25
summary: Fixed-dimension multidimensional arrays declared with a shape, indexed by a semicolon list.
---

A trailing `[…]` on an array declaration fixes its **shape** — the number of
dimensions and the size of each. The array is then indexed by a semicolon-separated
list of subscripts, one per dimension, and its bounds are fixed for its lifetime.

## Declaring and indexing

`my @a[2;3]` is a 2×3 grid. Assigning a list of lists fills it row by row, and
`@a[i;j]` reads one cell.

```raku
my @a[2;3] = (1,2,3),(4,5,6);
say @a[1;2];
say @a.shape;
```
```output
6
(2 3)
```

`.shape` reports the declared dimensions. `.elems` is the size of the **first**
dimension (the number of rows), not the total cell count.

```raku
my @a[2;3] = (1,2,3),(4,5,6);
say @a.elems;
say @a[0;1] + @a[1;0];
```
```output
2
6
```

## Any number of dimensions

The shape can have as many dimensions as you like. Cells start empty and are
addressed by a subscript per dimension.

```raku
my @c[2;2;2];
@c[1;0;1] = 42;
say @c[1;0;1];
say @c.shape;
```
```output
42
(2 2 2)
```

## Where Raku++ excels

Indexing a shaped array with **fewer** subscripts than it has dimensions takes a
*partial view* — here, a whole row. Raku++ returns it. Rakudo compiles the same
code but throws at runtime (*"Partially dimensioned views of shaped arrays not yet
implemented. Sorry."*), so this is a Raku++ extension.

```raku
my @a[2;3] = (1,2,3),(4,5,6);
say @a[1];      # Raku++: [4 5 6]   ·   Rakudo: not yet implemented
```

The official suite tests exactly this and Rakudo *fudges it out* — in
[`S09-multidim/indexing.t`](https://github.com/Raku/roast/blob/master/S09-multidim/indexing.t#L21):

```
#?rakudo todo "partially dimensioned NYI"
lives-ok { @arr[*;0] }, 'Partially dimensioned view lives';
```

The `#?rakudo todo` directive marks a test Rakudo itself cannot yet pass. Raku++
runs it — `@arr[*;0]` returns the column view.

## Notes

- The shape is a fixed allocation: the dimension sizes never change, so
  length-changing methods (`push`, `pop`, `shift`, `splice`, …) are disallowed on
  a shaped array.
- Assigning a nested list validates against the shape — a row of the wrong width,
  or a flat list where a nested one is expected, is an error rather than a silent
  reshape.
- `@a.shape` is a list of the dimension sizes; a plain (unshaped) array reports a
  shape of `(*)`, meaning "one dimension, any length".
