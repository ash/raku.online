---
title: Blocks & placeholder parameters
slug: blocks
status: full
order: 50
summary: Anonymous code — pointy blocks, the implicit $_, and $^a placeholder parameters.
---

A block `{ … }` is an anonymous piece of code — a `Callable` you can store and
invoke. It gets its parameters in one of three ways: a pointy signature, the topic
`$_`, or placeholder variables.

## Pointy blocks

`-> $a, $b { … }` is a block with an explicit signature, just like a sub's.

```raku
my $add = -> $a, $b { $a + $b };
say $add(3, 4);
```
```output
7
```

## The topic — `$_`

A bare block with no signature receives a single argument as the topic `$_`.

```raku
my $sq = { $_ ** 2 };
say $sq(5);
```
```output
25
```

## Placeholder parameters — `$^a`

Inside a signature-less block, `$^a`-style variables auto-declare parameters. They
bind **in alphabetical order** of their names, regardless of the order they appear.

```raku
my $f = { $^a + $^b };
say $f(3, 4);
```
```output
7
```

## Notes

- Placeholders bind by sorted name: in `{ $^b - $^a }`, `$^a` is still the *first*
  argument and `$^b` the second, so calling it with `(10, 3)` gives `-7`.
- `$_`, `$^a`, and an explicit `->` signature are mutually exclusive within one
  block — pick whichever reads best.
- These same blocks are what `map`, `grep`, `sort`, and friends take as their
  argument.
