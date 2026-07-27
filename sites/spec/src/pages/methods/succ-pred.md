---
title: succ & pred — increment
slug: succ-pred
status: full
order: 42
summary: The next and previous value — numbers step by one, strings increment magically.
---

`.succ` returns the successor (next value) and `.pred` the predecessor. For numbers
that's ±1; for strings it's Raku's **magic increment**, which carries across letters
and digits the way an odometer would.

## Numbers

`.succ`/`.pred` step by one; the `++`/`--` operators are the mutating shorthands.

```raku
say 5.succ;
say 5.pred;
my $x = 10; $x++; say $x;
```
```output
6
4
11
```

## String increment

`.succ` on a string increments the rightmost alphanumeric run, carrying into the next
position and preserving case and width.

```raku
say "az".succ;
say "Az".succ;
say "a9".succ;
say "zz".succ;
```
```output
ba
Ba
b0
aaa
```

`"zz"` carries all the way and **grows** to `"aaa"`, just like `99 → 100`.

## Notes

- This is what drives string [ranges](/operators/ranges/): `"a".."e"` walks the
  `.succ` sequence.
- The carry propagates through the whole trailing alphanumeric run: `"a9".succ` is
  `"b0"` (the `9` wraps to `0` and carries into the `a`), the same odometer logic as
  numbers.
- `++`/`--` use `.succ`/`.pred` under the hood, so they work on any type that defines
  them, not just numbers.
