---
title: List repetition  xx
slug: xx
status: full
order: 34
summary: Repeat a value into a list — the list cousin of string repetition x.
---

`xx` repeats its left side into a **list** of that many copies. It's distinct from
`x` (which repeats a string into a longer string): `xx` builds a list, `x`
concatenates.

## Building a list of copies

```raku
say "ab" xx 3;
my @a = 0 xx 5;
say @a;
```
```output
(ab ab ab)
[0 0 0 0 0]
```

`"ab" xx 3` is a three-element list (not the string `"ababab"` that `x` would give);
`0 xx 5` is the idiom for a zero-filled array.

## Notes

- Compare with [string repetition `x`](/operators/string-ops/): `"ab" x 3` is
  `"ababab"`, while `"ab" xx 3` is `("ab", "ab", "ab")`.
- The left side is re-evaluated each time if it's a block, so `{ rand } xx 3` gives
  three different numbers — handy for generating a list of computed values.
- Combined with a range: `"-" xx $n` then `.join` draws a separator line of length
  `$n` from list pieces.
