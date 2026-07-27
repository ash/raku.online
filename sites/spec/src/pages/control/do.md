---
title: do — everything is an expression
slug: do
status: full
order: 35
summary: Turn a block or a control structure into a value with do.
---

In Raku almost everything is an expression that yields a value. `do` makes that
explicit: it runs a block — or an `if`, `for`, `given` — and returns its result, so
you can assign or pass it.

## do a block

`do { … }` runs the block and returns its last expression.

```raku
my $x = do { my $a = 5; $a * 2 }
say $x;
```
```output
10
```

## do a conditional

`do if … else …` turns a two-way branch into a value — an alternative to the
[ternary](/operators/ternary/) when the branches are blocks.

```raku
my $y = do if 3 > 2 { "yes" } else { "no" }
say $y;
```
```output
yes
```

## do a loop

`do for` collects the value of each iteration into a list.

```raku
say do for 1..3 { $_ * $_ }
```
```output
(1 4 9)
```

## Notes

- `do` is only needed where the parser expects a term but sees a statement keyword;
  a block already in expression position (like a sub's body) returns its last value
  without it.
- `do for` is a compact map: `do for @xs { … }` is close to `@xs.map({ … })`.
- The last statement's value is what's returned — a trailing `;` after it would make
  the block yield `Nil` (an empty final statement).
