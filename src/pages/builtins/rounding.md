---
title: Rounding — floor / ceiling / round / truncate
slug: rounding
status: full
order: 60
summary: Round to integers or a precision, with the half-way rule Rakudo uses.
---

Four routines turn a fractional number into a whole one: `floor` (down), `ceiling`
(up), `truncate` (toward zero), and `round` (to nearest).

## floor, ceiling, truncate

```raku
say 3.7.floor;
say 3.2.ceiling;
say 3.7.truncate;
say (-3.7).floor;
```
```output
3
4
3
-4
```

`floor` goes toward −∞, `ceiling` toward +∞, `truncate` toward zero (so
`(-3.7).truncate` is `-3`, while `(-3.7).floor` is `-4`).

## round to a precision

`round` takes an optional scale — round to the nearest multiple of it.

```raku
say 3.5.round;
say 3.14159.round(0.01);
```
```output
4
3.14
```

## Halves round toward +∞

For a value exactly halfway, `round` rounds **toward +∞** — so a positive `.5` goes
up and a negative `.5` goes toward zero.

```raku
say 3.5.round;
say (-3.5).round;
say (-2.5).round;
```
```output
4
-3
-2
```

`3.5` rounds up to `4`; `-3.5` rounds up to `-3` (not `-4`).

## Notes

- The half-way rule only matters for values ending exactly in `.5`; every other
  value rounds to the genuinely nearest integer.
- `floor`, `ceiling`, and `truncate` have no half-way ambiguity.
- `.Int` on a fractional number truncates toward zero — the same as `.truncate`.
