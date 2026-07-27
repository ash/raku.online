---
title: min / max / minmax
slug: minmax
status: full
order: 24
summary: The least and greatest element — by natural order or a computed key.
---

`.min` and `.max` return the extreme elements; with a block they compare by a
computed key. `.minmax` returns both ends at once as a range.

## By a computed key

Pass a key extractor to compare by something other than the value — here, string
length.

```raku
say <bb a ccc>.min(*.chars);
say <bb a ccc>.max(*.chars);
```
```output
a
ccc
```

`a` is shortest, `ccc` longest — the comparison is on `.chars`, not alphabetical
order.

## minmax — both ends

`.minmax` returns a `Range` from the least to the greatest element.

```raku
say (3, 1, 2).minmax;
```
```output
1..3
```

## Notes

- With no argument, `.min`/`.max` use the elements' natural `cmp` order (numeric for
  numbers, alphabetic for strings).
- `.minmax` is one pass over the data — cheaper than calling `.min` and `.max`
  separately when you need both.
- These pair with `.sort` (which takes the same key-extractor block) — see
  [map / grep / sort](/builtins/higher-order/).
