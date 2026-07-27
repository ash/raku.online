---
title: Feed operators  ==> and <==
slug: feed
status: full
order: 92
summary: Pipe data through a chain of list operations, left-to-right or right-to-left.
---

The feed operators pass a list through a series of stages, like a shell pipeline.
`==>` flows left-to-right (data first, then each stage); `<==` flows right-to-left.
They make a `map`/`grep`/`sort` chain read in processing order.

## Forward feed — `==>`

Each `==>` feeds its left side as the final argument of the next stage; a terminal
`==> my @var` collects the result.

```raku
(1..10) ==> grep(* %% 2) ==> my @evens;
say @evens;
```
```output
[2 4 6 8 10]
```

Chain as many stages as you like:

```raku
<c a b> ==> map(*.uc) ==> sort() ==> my @s;
say @s;
```
```output
[A B C]
```

## Backward feed — `<==`

`<==` reads right-to-left — the source is on the right, and data flows *up* the
chain into the variable on the left.

```raku
my @r <== map(* * 10) <== (1, 2, 3);
say @r;
```
```output
[10 20 30]
```

## Notes

- Feeds bind very loosely, so an assignment `=` inside a feed source captures the
  source before the feed runs — use the terminal `==> my @var` form (as above)
  rather than `my @var = source ==> stage`.
- `==>` reads in data-flow order (source → transforms → sink); `<==` mirrors the way
  nested calls already nest, just spaced out.
- Each stage is an ordinary list routine; the feed only supplies the final argument,
  so `grep(* %% 2)` and `map(*.uc)` are written exactly as normal calls.
