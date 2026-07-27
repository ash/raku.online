---
title: Comparison & chaining
slug: comparison
status: full
order: 40
summary: Numeric vs string comparison, the three-way <=> / cmp, and chained relations.
---

Comparison operators come in two families: **numeric** (`==`, `!=`, `<`, `<=`,
`>`, `>=`) and **string** (`eq`, `ne`, `lt`, `le`, `gt`, `ge`). Choosing by
operator, not by value, keeps intent explicit.

## Numeric vs string equality

```raku
say 5 == 5.0;
say "5" eq "5.0";
say "a" eq "a";
```
```output
True
False
True
```

`5 == 5.0` is `True` (equal as numbers); `"5" eq "5.0"` is `False` (different as
text).

## Three-way comparison — `<=>` and `cmp`

`<=>` compares numerically, `cmp` compares in a type-sensible way (numbers
numerically, strings alphabetically). Both return `Less`, `Same`, or `More`.

```raku
say 3 <=> 5;
say "a" cmp "b";
```
```output
Less
Less
```

## Chained comparisons

Relations chain the way they do in mathematics: `1 < 2 < 3` means
`1 < 2 and 2 < 3`, and each operand is evaluated once.

```raku
say 1 < 2 < 3;
say 1 < 5 < 3;
```
```output
True
False
```

## Notes

- The `Less`/`Same`/`More` results are `Order` enum values; they numify to `-1`,
  `0`, `1` and are what `sort` uses under the hood.
- Chaining works for any mix of comparison operators: `$a <= $b < $c` is valid.
- Use `eqv` for structural equivalence (same type and value) and `===` for value
  identity.
