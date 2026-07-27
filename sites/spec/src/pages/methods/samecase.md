---
title: samecase
slug: samecase
status: full
order: 28
summary: Recase a string to follow the case pattern of another.
---

`.samecase(pattern)` rewrites a string's letters to match the upper/lower **case
pattern** of a second string, position by position (the last case carries onward).

## Matching a case pattern

```raku
say "hello".samecase("AB");
```
```output
HELLO
```

The pattern `"AB"` is all uppercase, so `hello` becomes `HELLO`.

## Following a mixed pattern

The case is copied position by position, and the *last* case in the pattern carries
on to the rest of the string — so `"Ab"` gives an initial capital then lowercase.

```raku
say "world".samecase("Ab");
say "WORLD".samecase("abc");
```
```output
World
world
```

`"Ab"` title-cases (`W` upper, the rest lower); `"abc"` is all lowercase, so `WORLD`
becomes `world`.

## Notes

- It's handy for preserving the casing of a word you're substituting — recase the
  replacement to `.samecase` the original.
- Related case methods (`.uc`, `.lc`, `.tc`, `.tclc`) are on the
  [Case methods](/methods/case/) page; `.samecase` differs by taking its casing
  from another string rather than a fixed rule.
- `.indent(n)` is a related layout method — it adds `n` leading spaces to each line
  (a negative `n` removes indentation).
