---
title: String operators  ~ and x
slug: string-ops
status: full
order: 30
summary: Concatenate with ~, repeat with x — and why they aren't + and *.
---

Raku keeps string and numeric operations on separate symbols, so a value's type is
never guessed from the operator. Strings concatenate with `~` and repeat with `x`.

## Concatenation — `~`

```raku
say "ab" ~ "cd";
say "foo" ~ 42;
```
```output
abcd
foo42
```

The second operand is coerced to `Str`, so `"foo" ~ 42` works and gives `foo42`.

## Repetition — `x`

`x` repeats a string a given number of times. (Its list cousin `xx` repeats a
*value into a list* — a different operator.)

```raku
say "ab" x 3;
say "=" x 10;
```
```output
ababab
==========
```

## Why not + and *

In Raku `+` and `*` are always numeric. `"3" + "4"` is `7` (the strings are coerced
to numbers), never `"34"`. Concatenation therefore needs its own operator, `~`,
and string repetition needs `x`.

```raku
say "3" + "4";
say "3" ~ "4";
```
```output
7
34
```

## Notes

- The unary/prefix `~` coerces to `Str`: `~42` is `"42"`. As an infix it
  concatenates.
- `x` requires a number on the right; `"ab" x 2.9` truncates the count to `2`.
