---
title: Junctions  any / all / none
slug: junctions
status: full
order: 60
summary: Superpositions of values that test many possibilities at once and autothread.
---

A **junction** is several values held in one slot, combined by a logical mode: `any`
(`|`), `all` (`&`), `one` (`^`), or `none`. Comparing against a junction tests all
its members at once and collapses to a single Boolean.

## any — does one match?

The infix `|` builds an `any` junction; a comparison against it is true if *any*
member matches.

```raku
say so 3 == (1 | 2 | 3);
say so 5 == (1 | 2 | 3);
```
```output
True
False
```

## all and none

`all(…)` is true when *every* member satisfies the test; `none(…)` when *no* member
does.

```raku
say so all(2, 4, 6) %% 2;
say so 4 == none(1, 2, 3);
```
```output
True
True
```

## Autothreading

Using a junction anywhere else **autothreads**: the operation applies to each
member and the result is a junction of the results.

```raku
say (1 | 2 | 3) + 1;
```
```output
any(2, 3, 4)
```

## Notes

- Junctions are meant for *asking questions*, not storing data — collapse them in
  Boolean context (`if $x == any(@valid) { … }`) rather than passing them around.
- The order in which autothreaded members are evaluated is unspecified, and may even
  be parallel, so junction operands should be side-effect-free.
- `so` (or any Boolean context) collapses a junction to a plain `Bool`; that is why
  the examples wrap the comparisons in `so`.
