---
title: String literals & quoting
slug: strings
status: full
order: 30
summary: Single vs double quotes, the q/qq family, and heredocs.
---

Raku has a rich set of quoting constructs. The two you reach for most are single
quotes (literal) and double quotes (interpolating); the `q`/`qq` forms generalise
them with choosable delimiters and adverbs.

## Single vs double quotes

Single quotes are literal — only `\\` and `\'` are special. Double quotes
**interpolate** scalar variables and `{ }` code blocks.

```raku
my $n = 42;
say 'cost $n';
say "cost $n";
```
```output
cost $n
cost 42
```

## The q and qq forms

`q//` is single-quote semantics, `qq//` is double-quote semantics — but you choose
the delimiter, so quotes inside the text need no escaping. Bracketing delimiters
nest.

```raku
say q{a{b}c};
say qq[one and one is {1 + 1}];
```
```output
a{b}c
one and one is 2
```

> Pick a delimiter that isn't `{ }` when you want `{ }` interpolation inside a `qq`
> string — with brace delimiters the inner block is ambiguous with the delimiter.

## Heredocs

`qq:to/END/` starts a heredoc: the text runs until a line containing the
terminator. Leading indentation is stripped to match the terminator's, so the
source stays tidy.

```raku
my $name = "Ada";
say qq:to/END/.trim;
  Dear $name,
  Welcome.
  END
```
```output
Dear Ada,
Welcome.
```

## Notes

- Interpolation covers `$scalar`, `@array[...]`/`%hash{...}` with a postcircumfix,
  method calls like `$obj.method()`, and arbitrary `{ code }` blocks.
- A bare `@array` does **not** interpolate in a string unless followed by a
  postcircumfix (`@a[]` interpolates the whole array); this trips up newcomers.
- `Q//` is the no-escape, no-interpolation form — truly raw text.
