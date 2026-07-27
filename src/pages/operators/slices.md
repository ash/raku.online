---
title: Slices
slug: slices
status: full
order: 35
summary: Index an array or hash with several keys at once to get several values.
---

Subscripting with a **list** of keys returns a list of values — a *slice*. It works
on arrays (by position) and hashes (by key), and the index list can itself be a range
or use the [Whatever star](/operators/whatever/).

## Array slices

```raku
my @a = 10, 20, 30, 40;
say @a[1, 3];
say @a[1..2];
say @a[*-1, 0];
```
```output
(20 40)
(20 30)
(40 10)
```

Any list of indices works — explicit (`1, 3`), a range (`1..2`), or computed
(`*-1` for the last).

## Hash slices

Subscript a hash with several keys to pull several values, in the order asked.

```raku
my %h = a => 1, b => 2, c => 3;
say %h<a c>;
say %h{"a", "b"};
```
```output
(1 3)
(1 2)
```

`<a c>` is the quoted-word form (constant keys); `{"a", "b"}` takes an expression
list.

## Notes

- A slice returns values in the order of the index list, so `@a[3, 1]` and `@a[1, 3]`
  differ — slices can reorder.
- Assigning to a slice updates several elements at once: `@a[0, 1] = 100, 200`.
- The result is a list even for a single-element slice (`@a[1,]`), unlike a plain
  scalar subscript `@a[1]`.
