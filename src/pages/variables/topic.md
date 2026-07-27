---
title: The topic  $_
slug: topic
status: full
order: 30
summary: The implicit variable that blocks, loops, and method calls default to.
---

`$_` is the **topic** — the "it" of the current block. Many constructs set it
implicitly, and a leading-dot method call (`.method`) or a bare `given`/`when`
operates on it, so you rarely have to name it.

## Set by a for loop

Without a pointy signature, `for` sets `$_` to each element.

```raku
for 1..3 { say $_ * 10 }
```
```output
10
20
30
```

## The dot shorthand

`.method` is `$_.method`, so you can call methods on the topic with no variable at
all.

```raku
for <a b c> { .say }
```
```output
a
b
c
```

## Set by given

`given` topicalises its argument for the block, which pairs with `when` and the dot
shorthand.

```raku
given "hello" { say .uc; say .chars }
```
```output
HELLO
5
```

## Notes

- `$_` is an ordinary variable — you can name it, assign it, or take it as a block
  parameter with `-> $_ { … }`.
- `map`, `grep`, and `sort` blocks with no signature receive their argument as `$_`,
  which is why `map { .uc }` works.
- The topic is dynamically scoped by the block that sets it; nesting a `for` inside a
  `given` rebinds `$_` for the inner block.
