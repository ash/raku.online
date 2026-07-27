---
title: join / split / words / first
slug: list-tools
status: full
order: 40
summary: Convert between strings and lists, and pluck the first matching element.
---

These routines bridge strings and lists: `split` and `words` break a string apart,
`join` puts a list back together, and `first` returns the earliest element matching
a test.

## join and split

`join` glues a list into a string with a separator; `split` is the inverse.

```raku
say <a b c>.join("-");
say "a,b,c".split(",");
```
```output
a-b-c
(a b c)
```

## words

`words` splits on runs of whitespace, ignoring leading and trailing space — the
right tool for tokenising text.

```raku
say "the quick fox".words;
```
```output
(the quick fox)
```

## first

`first` returns the earliest element for which the block is true (not the index).

```raku
say (1..10).first(* > 4);
```
```output
5
```

## Notes

- `split` returns a `Seq`; `join` always returns a `Str`. `split` can also take a
  regex, and `:skip-empty` drops empty fields.
- `words` is roughly `split(/\s+/)` with the empty edges removed; use it in
  preference when you just want the non-space chunks.
- Related pluckers: `first` (element), `first(:k, …)` (its key/index), and `grep`
  (all matches instead of just the first).
