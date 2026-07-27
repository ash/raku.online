---
title: ENTER / LEAVE & FIRST / LAST
slug: block-loop
status: full
order: 20
summary: Block-entry/exit phasers and loop first/last-iteration phasers.
---

Some phasers fire around **blocks** and **loop iterations**. `ENTER`/`LEAVE` run each
time a block is entered and left; `FIRST`/`LAST` run on the first and last iteration
of a loop.

## ENTER and LEAVE

`ENTER` runs on entering the block, `LEAVE` on leaving it — including via an
exception or an early `return`, which makes `LEAVE` ideal for cleanup.

```raku
{
    ENTER say "enter";
    say "body";
    LEAVE say "leave";
}
```
```output
enter
body
leave
```

## FIRST and LAST

Inside a loop, `FIRST` runs only on the first iteration and `LAST` only on the last,
while the body runs every time.

```raku
for 1..3 {
    FIRST say "first";
    say $_;
    LAST say "last";
}
```
```output
first
1
2
3
last
```

## Notes

- `LEAVE` is guaranteed to run however the block is exited, so it is the structured
  way to release resources — the equivalent of `try`/`finally` elsewhere.
- The full loop set is `FIRST`, `NEXT` (after each iteration), and `LAST`; `NEXT`
  is handy for per-iteration bookkeeping.
- Phasers see the lexical scope they are written in, so they can read and update the
  surrounding block's variables.
