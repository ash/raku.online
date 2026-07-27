---
title: Hash methods
slug: hash
status: full
order: 30
summary: Inspect and order associative data — keys, values, pairs, :exists, sorting.
---

A `Hash` maps keys to values. Its methods let you pull the keys, values, or
key/value pairs, test membership, and order the entries (hash iteration itself is
unordered, so sort when you need determinism).

## keys and values

```raku
my %h = a => 1, b => 2, c => 3;
say %h.keys.sort;
say %h.values.sort;
```
```output
(a b c)
(1 2 3)
```

## pairs

`pairs` yields `key => value` `Pair` objects — handy for iterating entries together.

```raku
my %h = a => 1, b => 2, c => 3;
say %h.pairs.sort;
```
```output
(a => 1 b => 2 c => 3)
```

## Testing membership — `:exists`

The `:exists` adverb on a subscript asks whether a key is present, without
autovivifying it.

```raku
my %h = a => 1, b => 2;
say %h<a>:exists;
say %h<z>:exists;
```
```output
True
False
```

## Sorting by value

`sort` with a key extractor orders the pairs; here by value, descending, taking the
keys.

```raku
my %h = a => 1, b => 2;
say %h.sort(*.value).reverse.map(*.key);
```
```output
(b a)
```

## Notes

- `.keys`, `.values`, and `.pairs` return their results in a **matching but
  unspecified** order — `%h.keys Z %h.values` stays aligned, but sort for
  reproducible output.
- `:delete` is the sibling adverb of `:exists`: `%h<a>:delete` removes the key and
  returns its value.
- `.kv` flattens to an alternating `key, value, key, value…` list — convenient for
  `for %h.kv -> $k, $v { … }`.
