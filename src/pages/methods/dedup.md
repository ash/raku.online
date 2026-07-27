---
title: Deduplication — unique / squish / repeated
slug: dedup
status: full
order: 22
summary: Drop duplicates globally (unique), only when adjacent (squish), or find them (repeated).
---

Three methods handle repeated elements differently: `unique` removes all duplicates,
`squish` collapses only *adjacent* runs, and `repeated` returns the duplicates
themselves.

## squish — collapse adjacent runs

`squish` removes a duplicate only when it directly follows its twin, so a value can
reappear later.

```raku
say (1, 1, 2, 2, 3, 1).squish;
say (1, 2, 2, 3, 3, 3).repeated;
```
```output
(1 2 3 1)
(2 3 3)
```

The trailing `1` survives `squish` (it isn't adjacent to the first `1`); `repeated`
returns each element that has appeared before.

## unique by a key

`unique` drops all repeats; `:as` compares by a computed key instead of the value
itself — here, by absolute value.

```raku
say (1, -1, 2, -2, 3).unique(:as(*.abs));
```
```output
(1 2 3)
```

`-1` is dropped as a duplicate of `1` because their `.abs` match.

## Notes

- `unique` is `O(n)` with a seen-set and keeps first-seen order; `squish` is streaming
  and only remembers the previous element — cheaper, but only for sorted or grouped
  data.
- `repeated` is the complement of `unique`: together they partition a list into
  first-occurrences and later-occurrences.
- Sort first if you want `squish` to behave like `unique`: `@a.sort.squish`.
