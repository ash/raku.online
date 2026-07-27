---
title: Scalars, arrays & hashes
slug: sigils
status: full
order: 10
summary: The three sigils — $ for one item, @ for ordered lists, % for key/value maps.
---

A variable's **sigil** announces its shape. `$` holds a single item (even if that
item is itself a list), `@` is a positional (ordered) container, and `%` is an
associative (key/value) container.

## Scalars — `$`

A `$` variable holds exactly one thing. Assigning a list to it stores the list *as
one item*, so `.elems` on the container is not what you might expect.

```raku
my $x = (1, 2, 3);
say $x.WHAT;
say $x.elems;
```
```output
(List)
3
```

## Arrays — `@`

An `@` variable flattens an assigned list into an ordered container. `say` shows it
in brackets; `put` prints the elements space-separated. Index with `[ ]`
(zero-based).

```raku
my @a = 1, 2, 3;
say @a;
put @a;
say @a.elems;
say @a[1];
```
```output
[1 2 3]
1 2 3
3
2
```

## Hashes — `%`

A `%` variable maps keys to values. Index with `{ }`, or `< >` for constant string
keys. Iteration order is not defined, so sort keys when you need determinism.

```raku
my %h = apple => 3, pear => 5;
say %h<apple>;
say %h.elems;
say %h.keys.sort;
```
```output
3
2
(apple pear)
```

## Notes

- The sigil is part of the name: `$x`, `@x`, and `%x` are three different
  variables.
- `@a[1]` and `%h<k>` return the element; the sigil of the *access* follows the
  container, not the element.
- Because a `$` scalar holds a list as a single item, passing `$x` where a list is
  wanted keeps it un-flattened — useful for nested data.
