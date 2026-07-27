---
title: Pairs
slug: pairs
status: full
order: 40
summary: A single key-to-value association — the building block of hashes and named args.
---

A `Pair` links one key to one value, written `key => value`. Pairs are the elements
of a hash, the form of named arguments, and a value in their own right.

## The fat-arrow form

```raku
my $p = a => 1;
say $p;
say $p.key;
say $p.value;
```
```output
a => 1
a
1
```

## Colon-pair forms

`:key(value)` is the same Pair; `:key` alone means `key => True`, and `:key<word>`
uses a quoted-word value. These are exactly the forms used for named arguments.

```raku
say (:x(5));
say (:done);
my $q = :name<Ada>;
say $q;
```
```output
x => 5
done => True
name => Ada
```

## Notes

- `:$var` is shorthand for `var => $var` — the pattern behind
  [named arguments](/subs/named/).
- A list of Pairs is what initialises a [hash](/variables/sigils/):
  `my %h = a => 1, b => 2`.
- `:!key` is `key => False`, the negated colon-pair — common for turning a flag off.
