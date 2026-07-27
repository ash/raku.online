---
title: Smartmatch  ~~
slug: smartmatch
status: full
order: 46
summary: One operator that asks "does this match that?" against types, ranges, and more.
---

The smartmatch operator `~~` asks whether the left value **matches** the right,
where "match" depends on what's on the right: a type tests membership, a range tests
containment, a regex tests a pattern, a code block tests a predicate. It is the
engine behind `when`, `grep`, and `given`.

## Against a type

```raku
say 5 ~~ Int;
say "x" ~~ Int;
say 3.5 ~~ Real;
```
```output
True
False
True
```

## Against a range

```raku
say 5 ~~ 1..10;
say 20 ~~ 1..10;
```
```output
True
False
```

## Against a predicate

A `Callable` on the right is called with the value; a `WhateverCode` makes a tidy
inline test. (Parenthesise it so the `*` curries only the predicate, not the whole
`~~` expression.)

```raku
say 5 ~~ (* > 2);
say 1 ~~ (* > 2);
```
```output
True
False
```

## Notes

- The result is always a plain `Bool` (unlike a bare regex match, which returns a
  `Match` — smartmatch Booleanises it).
- What "match" means is defined by the right-hand side's `ACCEPTS` method, so any
  type can define how it smartmatches.
- `when X` is `$_ ~~ X`, and `grep X` keeps elements where `$_ ~~ X` — the same
  operator throughout, which is why ranges, types, and regexes all work in a `when`.
