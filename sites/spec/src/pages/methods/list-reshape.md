---
title: Reshaping lists — flat, rotor, scan
slug: list-reshape
status: full
order: 60
summary: Flatten nesting, slide a window, and produce running totals.
---

These methods change a list's shape rather than its contents: `.flat` removes
nesting, `.rotor` groups into (possibly overlapping) chunks, and the triangular
reduce `[\op]` produces running results.

## flat — remove nesting

`.flat` flattens nested lists into one flat sequence, however deep.

```raku
say ((1, 2), (3, 4)).flat;
say (1, (2, (3, 4))).flat;
```
```output
(1 2 3 4)
(1 2 3 4)
```

## rotor — sliding windows

`.rotor(n)` makes chunks of `n`; `.rotor(n => -k)` overlaps them by `k` — a sliding
window.

```raku
say (1..5).rotor(2 => -1);
```
```output
((1 2) (2 3) (3 4) (4 5))
```

## Triangular reduce — running totals

`[\op]` is the scan form of the [reduction metaoperator](/operators/reductions/):
it keeps every intermediate result, not just the final one.

```raku
say [\+] 1, 2, 3, 4;
```
```output
(1 3 6 10)
```

Each element is the running sum: `1`, `1+2`, `1+2+3`, `1+2+3+4`.

## Notes

- `.flat` only flattens *list* structure; a scalar holding a list (an itemised `$`)
  stays opaque, which is how nested data is kept intact when you want it.
- `.rotor` also takes uneven batch sizes and a `:partial` flag for handling a short
  final chunk.
- `[\*]`, `[\~]`, and any other associative operator work as scans too —
  `[\~] <a b c>` gives `(a ab abc)`.
