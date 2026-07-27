---
title: rotate
slug: rotate
status: full
order: 62
summary: Cyclically shift a list's elements left or right.
---

`.rotate(n)` moves each element `n` places, wrapping around the ends — a cyclic
shift. Positive `n` rotates left (toward the front), negative `n` rotates right.

## Rotate left and right

```raku
say <a b c d>.rotate(1);
say <a b c d>.rotate(-1);
```
```output
(b c d a)
(d a b c)
```

`rotate(1)` moves the first element to the back; `rotate(-1)` moves the last to the
front.

## Notes

- Nothing is lost — `rotate` is a permutation, so the result always has the same
  elements, just cyclically shifted.
- The count wraps: `rotate(n)` on a list of length `L` is the same as `rotate(n % L)`.
- Related reshapers: [`rotor`](/methods/list-reshape/) (chunks/windows) and
  `reverse` (flip); `rotate` alone shifts without reordering within the cycle.
