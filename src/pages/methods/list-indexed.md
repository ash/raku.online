---
title: Indexed list access
slug: list-indexed
status: full
order: 55
summary: Work with positions — kv, antipairs, and the :k adverb on grep/first.
---

Several methods surface a list's **indices** alongside (or instead of) its values —
for iterating with a counter, or finding *where* something is rather than *what*.

## kv and antipairs

`.kv` flattens to alternating index/value; `.antipairs` returns `value => index`
pairs.

```raku
say <a b c>.kv;
say <a b c>.antipairs;
```
```output
(0 a 1 b 2 c)
(a => 0 b => 1 c => 2)
```

`.kv` is what `for @a.kv -> $i, $v { … }` iterates.

## Indices with :k

The `:k` adverb makes `grep` and `first` return **positions** instead of values.

```raku
say (10, 20, 30).grep(* > 15, :k);
say (10, 20, 30).first(* > 15, :k);
```
```output
(1 2)
1
```

`grep(:k)` gives every matching index; `first(:k)` gives the first.

## Notes

- The adverb family is `:k` (keys/indices), `:v` (values, the default), `:kv`
  (both), and `:p` (pairs) — they work on `grep`, `first`, and hash access alike.
- `.pairs` on a list gives `index => value` (the opposite order to `.antipairs`).
- `.kv` on a hash yields key/value pairs instead of index/value — the same method,
  keyed by the container type.
