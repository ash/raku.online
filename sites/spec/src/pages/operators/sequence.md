---
title: The sequence operator  ...
slug: sequence
status: full
order: 54
summary: Generate a series by inferring the step, or by giving a closure — even infinite ones.
---

The sequence operator `...` builds a list from a starting point to an endpoint,
**inferring the pattern** from the leading elements. Give it a closure instead of a
literal step and it can produce any series, including unbounded ones.

## Inferred arithmetic and geometric steps

From two or more leading terms, `...` infers a constant difference (arithmetic) or
ratio (geometric).

```raku
say (2, 4 ... 10);
say (1 ... 5);
say (10 ... 1);
```
```output
(2 4 6 8 10)
(1 2 3 4 5)
(10 9 8 7 6 5 4 3 2 1)
```

A ratio between the first terms gives a geometric sequence:

```raku
say (1, 2, 4 ... 64);
```
```output
(1 2 4 8 16 32 64)
```

## A closure as the generator

The right-hand generator can be a closure of the previous terms. `* + *` sums the
last two — the Fibonacci rule — and a `*` endpoint means "go forever" (taken lazily).

```raku
say (1, 1, * + * ... *)[^10];
```
```output
(1 1 2 3 5 8 13 21 34 55)
```

## Notes

- `...` is lazy: `1, 2 ... *` is an infinite sequence you take from without
  materialising, e.g. `(1, 2 ... *)[^5]`.
- The endpoint is matched with smartmatch; `... 10` stops when a term equals 10, so a
  step that would overshoot never terminates — pick endpoints the series actually
  hits.
- Use `...^` to exclude the endpoint, mirroring the `..^` range form.
