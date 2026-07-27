---
title: Subscript adverbs — :exists / :delete
slug: subscript-adverbs
status: full
order: 37
summary: Modify what a subscript does — test for a key, remove it, or ask for keys.
---

An adverb on a subscript changes what the access returns or does. `:exists` tests for
a key without creating it, `:delete` removes it and returns its value, and `:k`/`:v`/
`:kv`/`:p` choose what a slice yields.

## :exists and :delete

```raku
my %h = a => 1, b => 2;
say %h<a>:exists;
say %h<a>:delete;
say %h;
```
```output
True
1
{b => 2}
```

`:exists` reports the key is present; `:delete` removes `a` (returning its value `1`),
leaving just `b`.

## Shaping a slice — :kv / :p / :k

On a slice, these adverbs choose what comes back: `:kv` the keys *and* values flat,
`:p` them as pairs, `:k` just the keys.

```raku
my %h = a => 1, b => 2, c => 3;
say %h<a b>:kv;
say (%h<a c>:p).sort;
say %h<a b>:k;
```
```output
(a 1 b 2)
(a => 1 c => 3)
(a b)
```

## Deleting from an array

`:delete` works on an array element too, returning what it held and leaving a hole.

```raku
my @a = 10, 20, 30;
say @a[1]:delete;
say @a;
```
```output
20
[10 (Any) 30]
```

## Notes

- `:exists` does **not** autovivify — testing `%h<missing>:exists` won't create the
  key, unlike a bare `%h<missing>` in some lvalue contexts.
- `:delete` works on arrays too, removing the element (leaving a hole/`Nil`), and
  returns what it removed.
- The value-shape adverbs pair with slices: `%h<a b>:kv` gives `(a 1 b 2)`, `:p` gives
  pairs, `:k` just the keys that matched — the same family used by
  [grep/first :k](/methods/list-indexed/).
