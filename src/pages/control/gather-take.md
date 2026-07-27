---
title: gather / take
slug: gather-take
status: full
order: 70
summary: Build a lazy list by taking values from anywhere inside a block.
---

`gather` runs a block and collects every value handed to `take` inside it — however
deeply nested — into a single lazy list. It decouples *producing* values from the
loop or logic that decides which to emit.

## gather over a loop

```raku
my @evens = gather for 1..10 { take $_ if $_ %% 2 }
say @evens;
```
```output
[2 4 6 8 10]
```

Only the numbers that reach a `take` end up in the list — the `if` filters inline.

## take from nested code

`take` can appear anywhere the `gather` block reaches, including inside called
blocks, so production logic can be spread out.

```raku
my @out = gather {
    take "start";
    take $_ for <a b>;
    take "end";
}
say @out;
```
```output
[start a b end]
```

## Notes

- The result is lazy: `gather` doesn't run the block until the list is consumed, so
  `gather { … take … }` can even be infinite and taken from with `[^n]`.
- `take` returns its argument, so `my $v = take $x` both emits and keeps the value.
- Assigning the result to an `@array` reifies it; a bare `gather` is the lazy `Seq`,
  which you take from with `[^n]` or reify with `.list`/`.Array`.
