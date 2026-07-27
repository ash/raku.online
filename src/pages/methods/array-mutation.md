---
title: Array mutation — push / pop / splice
slug: array-mutation
status: full
order: 65
summary: Grow, shrink, and edit an array in place at either end or in the middle.
---

An `@` array is mutable. `push`/`pop` work at the end, `shift`/`unshift` at the
front, and `splice` edits any range in the middle.

## Both ends

`push` and `unshift` add (to the end and front); the array grows in place.

```raku
my @a = 1, 2, 3;
@a.push(4);
@a.unshift(0);
say @a;
```
```output
[0 1 2 3 4]
```

`pop` and `shift` remove and **return** the removed element.

```raku
my @a = 1, 2, 3;
say @a.pop;
say @a.shift;
say @a;
```
```output
3
1
[2]
```

## splice — edit the middle

`splice(start, count, replacement…)` removes `count` elements at `start` and inserts
the replacements.

```raku
my @a = <a b c d e>;
@a.splice(1, 2, "X");
say @a;
```
```output
[a X d e]
```

Two elements (`b`, `c`) are removed and one (`X`) inserted.

## Notes

- `push`/`unshift` take multiple arguments (`@a.push(1, 2, 3)`) and flatten a list
  argument; use `.append`/`.prepend` for the list-flattening variants explicitly.
- These mutate the array — for a non-destructive "array plus an element" use list
  construction (`(|@a, 4)`) instead.
- `splice` returns the removed elements, so it doubles as a "cut this range out" that
  hands you what it removed.
