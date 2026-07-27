---
title: Hash operations
slug: hash-ops
status: full
order: 35
summary: Accumulate multiple values per key with .push, and the (Hash-backed) Map type.
---

Beyond plain key/value storage, `.push` accumulates several values under one key,
turning it into an array. Raku's immutable `Map` type also exists, though Raku++
backs it with a `Hash` (see the note).

## push — multiple values per key

`.push` on a hash adds to a key; pushing a second value under the same key promotes
it to an array of values.

```raku
my %h;
%h.push("a" => 1);
%h.push("a" => 2);
say %h<a>;
```
```output
[1 2]
```

This is the idiom for grouping — collect everything that shares a key.

## Map — the immutable hash

`Map` is the immutable sibling of `Hash`: build it once and read from it. Its type is
distinct from `Hash`.

```raku
my $m = Map.new("a", 1, "b", 2);
say $m<a>;
say $m.^name;
```
```output
1
Map
```

## Notes

- `.push` differs from assignment: `%h<a> = 2` *replaces*, while `%h.push("a" => 2)`
  *accumulates* into an array once there's more than one value.
- `classify` (see [List methods](/methods/list/)) is the higher-level grouping
  tool built on this idea.
- `%h.kv`, `%h.pairs`, `%h.keys`, `%h.values` iterate a hash — see
  [Hash methods](/methods/hash/).
