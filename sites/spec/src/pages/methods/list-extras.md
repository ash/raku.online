---
title: minpairs / maxpairs / pairup / flatmap
slug: list-extras
status: full
order: 22
summary: Extreme-value pairs, pairing a flat list, and mapping each element to several.
---

Beyond the everyday [List methods](/methods/list/), a few extras handle common
shaping tasks: finding *where* the extreme values are, pairing up a flat list, and
expanding each element into many.

## minpairs and maxpairs

`.minpairs`/`.maxpairs` return the `index => value` pairs of the minimum (or maximum)
elements — every one, if the extreme is tied.

```raku
say (3, 1, 2, 1).minpairs;
say (5, 9, 9, 2).maxpairs;
```
```output
(1 => 1 3 => 1)
(1 => 9 2 => 9)
```

Both `1`s are the minimum, so `minpairs` reports positions 1 and 3.

## pairup

`.pairup` reads a flat list as alternating keys and values and builds `Pair`s — the
quick way to turn `a, 1, b, 2` into a list of pairs.

```raku
say <a 1 b 2 c 3>.pairup;
```
```output
(a => 1 b => 2 c => 3)
```

## flatmap

`.flatmap` maps each element and flattens one level of the results — so a block that
returns several values per element produces one flat list.

```raku
say (1, 2, 3).flatmap({ ($_, $_ * 10) });
```
```output
(1 10 2 20 3 30)
```

## Finding positions — :k

`.first` and `.grep` take a `:k` adverb to return **indices** instead of values —
`first :k` the position of the first match, `grep :k` all matching positions.

```raku
say <a b c d>.first(* eq "c", :k);
say (5, 2, 8, 1, 9).grep(* > 4, :k);
```
```output
2
(0 2 4)
```

## Notes

- `.minpairs`/`.maxpairs` pair with `.min`/`.max` (just the value) and `.minmax`
  (a `Range`) — see [min / max / minmax](/methods/minmax/).
- The `:k`/`:v`/`:kv`/`:p` adverbs work on `.first`, `.grep`, and subscript slices
  alike — see [Subscript adverbs](/operators/subscript-adverbs/).
- `.flatmap` is `.map` followed by one level of `.flat`; for deeper flattening use
  `.map` with an explicit `.flat`.
