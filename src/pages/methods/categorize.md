---
title: categorize — multi-key grouping
slug: categorize
status: full
order: 26
summary: Group elements under every key a block returns, so one element can land in several groups.
---

`categorize` is `classify`'s multi-key cousin: its block returns a **list** of keys
per element, and the element is filed under each of them. One value can therefore
appear in several groups at once.

## Filing into multiple groups

Here each number is categorised by parity *and* by size, so it lands in two lists.

```raku
my %g = (1..6).categorize({ ($_ %% 2 ?? "even" !! "odd", $_ > 3 ?? "big" !! "small") });
say %g<even>.sort;
say %g<small>.sort;
```
```output
(2 4 6)
(1 2 3)
```

`4` is in both `even` and `big`; `2` is in both `even` and `small`.

## Notes

- `classify` ([List methods](/methods/list/)) is the single-key form — its block
  returns one key, so each element lands in exactly one group.
- The result is a hash of arrays; iterate it with `.sort` for reproducible output
  (hash order is undefined).
- It's the natural tool for tag-style grouping, where items carry several independent
  labels.
