---
title: List methods
slug: list
status: full
order: 20
summary: Reshape and query lists — unique, reverse, rotor, head/tail, classify.
---

Positional values (`List`, `Array`, `Seq`) share a rich method set for reshaping and
summarising. A representative handful:

## unique and reverse

```raku
say (3, 1, 2, 1).unique;
say (1, 2, 3).reverse;
```
```output
(3 1 2)
(3 2 1)
```

`unique` drops later duplicates while keeping first-seen order; `reverse` flips the
sequence.

## rotor — fixed-size chunks

`rotor(n)` batches a list into sublists of `n` elements.

```raku
say (1..6).rotor(2);
```
```output
((1 2) (3 4) (5 6))
```

## head, tail, minmax

```raku
say (1, 2, 3, 4).head(2);
say (1, 2, 3, 4).tail(2);
say (5, 3, 8, 1).minmax;
```
```output
(1 2)
(3 4)
1..8
```

## classify — group by a key

`classify` runs a block per element and groups elements under the returned key,
producing a hash of lists.

```raku
my %g = (1..6).classify({ $_ %% 2 ?? "even" !! "odd" });
say %g<even>;
say %g<odd>;
```
```output
[2 4 6]
[1 3 5]
```

## Notes

- `minmax` returns a `Range` from the least to greatest element; `.min` and `.max`
  give the ends individually.
- `rotor` takes richer arguments too — overlapping windows (`rotor(3 => -1)`) and
  uneven batches — for sliding-window work.
- `categorize` is `classify`'s multi-key cousin: its block returns a *list* of keys,
  so an element can land in several groups.
