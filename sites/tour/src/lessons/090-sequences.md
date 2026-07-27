---
title: Ranges and sequences
chapter: Data structures
summary: Ranges count for you; the ... operator deduces whole sequences — even infinite ones.
---

You've met ranges in loops; they're values in their own right, and they work
on letters too:

```raku
say (1..10).sum;
say ('a'..'e').list;
say (^5).list;
```
```output
55
(a b c d e)
(0 1 2 3 4)
```

## The sequence operator

`...` builds a sequence from examples. Give it enough terms to spot the
pattern and an end point:

```raku
say 1, 3, 5 ... 15;
say 1, 2, 4 ... 1024;
```
```output
(1 3 5 7 9 11 13 15)
(1 2 4 8 16 32 64 128 256 512 1024)
```

Arithmetic from two terms, geometric from three. For anything fancier, give it
the rule yourself — `* + *` means "add the previous two":

```raku
say (1, 1, * + * ... *).head(10);
```
```output
(1 1 2 3 5 8 13 21 34 55)
```

That `... *` means the sequence never ends — it's **lazy**, computed only as
far as you ask. `.head(10)` asks for the first ten Fibonacci numbers, so
that's all that gets computed.

## Try it

Print the first 8 powers of 3 — starting from 1 — using the sequence
operator and `.head`.

```raku exercise
say (...).head(8);
```

```solution
say (1, 3, 9 ... *).head(8);
```
```output
(1 3 9 27 81 243 729 2187)
```
