---
title: Enums
slug: enums
status: full
order: 40
summary: Named constants with underlying values, introspectable as a group.
---

An `enum` declares a set of named constants. Each name becomes a value you can use
directly; by default the names take integer values counting from zero.

## Declaring an enum

```raku
enum Color <Red Green Blue>;
say Red;
say Green.value;
say Blue.value;
```
```output
Red
1
2
```

`Red`, `Green`, `Blue` are usable as bare terms. `.value` gives the underlying
number — `Red` is `0`, `Green` is `1`, `Blue` is `2`.

## Introspecting the group

The enum type knows all its members. `.enums` returns them as a name-to-value map.

```raku
enum Suit <hearts diamonds clubs spades>;
say hearts.value;
say Suit.enums.sort;
```
```output
0
(clubs => 2 diamonds => 1 hearts => 0 spades => 3)
```

## Notes

- Assign explicit values with pairs: `enum HttpStatus (OK => 200, NotFound => 404)`.
- An enum value knows its name (`.key`) and number (`.value`), and stringifies to
  its name — which is why `say Red` prints `Red`, not `0`.
- Enum names are ordinary constants in scope, so they smartmatch in `when` clauses
  and compare with `==`/`cmp`.
