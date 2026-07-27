---
title: Splitting a string
slug: split
status: full
order: 25
summary: Break a string on a separator or regex, with a limit, :skip-empty, or into chunks.
---

`.split` breaks a string into a list on a separator, which can be a string or a
regex, with an optional limit and the `:skip-empty` adverb. `.comb` is the
complement — it keeps the pieces rather than the gaps.

## Split on a string or regex

```raku
say "a-b-c".split("-");
say "a1b2c".split(/\d/);
```
```output
(a b c)
(a b c)
```

## Limit the number of pieces

A second argument caps the number of fields; the last one keeps the remainder.

```raku
say "a-b-c".split("-", 2);
```
```output
(a b-c)
```

## Drop empties with :skip-empty

`:skip-empty` removes empty fields — such as the trailing empty left after a final
separator.

```raku
say "a1b2c3".split(/\d/, :skip-empty);
```
```output
(a b c)
```

## comb into fixed-size chunks

`.comb(n)` returns **n-character chunks** (the complement of splitting).

```raku
say "hello".comb(2);
```
```output
(he ll o)
```

## Notes

- `.words` splits on whitespace (dropping empty edges) and matches Rakudo — the right
  tool when the separator is "any run of spaces".
- `.lines` splits on line boundaries; `.comb` with no argument returns single
  characters (which matches Rakudo).
- A regex separator lets you split on patterns: `.split(/\s* ',' \s*/)` trims around
  commas.
