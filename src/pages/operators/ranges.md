---
title: The range operator  ..
slug: ranges
status: full
order: 50
summary: Build ranges with .. and its endpoint-excluding variants; iterate or sum them.
---

`..` builds a `Range` — a lazy, ordered span between two endpoints. Ranges work on
numbers and on strings (which increment through their alphabet).

## Inclusive and exclusive endpoints

Plain `..` includes both ends. A `^` on either side excludes that end:
`..^` excludes the top, `^..` the bottom, `^..^` both.

```raku
say (1..5).list;
say (1..^5).list;
say (1..5).sum;
```
```output
(1 2 3 4 5)
(1 2 3 4)
15
```

A `Range` can report its own shape: `.excludes-min`/`.excludes-max` say whether each
end is open, and `.int-bounds` gives the first and last *integer* it contains.

```raku
my $r = 1 ^..^ 10;
say $r.excludes-min;
say $r.excludes-max;
say $r.int-bounds;
```
```output
True
True
(2 9)
```

Both ends are excluded, so the integers run from `2` to `9`.

## String ranges

Endpoints can be strings; the range walks the string-increment sequence.

```raku
say ("a".."e").list;
```
```output
(a b c d e)
```

## The prefix `^` shortcut

`^N` is shorthand for `0 ..^ N` — the first `N` integers from zero. It is the
idiomatic way to loop `N` times.

```raku
say (^5).list;
say [+] ^5;
```
```output
(0 1 2 3 4)
10
```

## Fractional endpoints

When an endpoint is not an integer, the range keeps its real endpoints and steps
by `1` from the low end — the fractional part carries through every element. The
top endpoint still bounds the sequence, so the last element is the largest one
that does not pass it.

```raku
say (1.1 .. 4).list;
say (1.5 .. 5).elems;
```
```output
(1.1 2.1 3.1)
4
```

## Notes

- Ranges are lazy: `1..Inf` is a valid, unbounded range you can take from without
  materialising it.
- For arithmetic and geometric progressions with a computed step, use the sequence
  operator `...` instead: `1, 3 ... 11` gives the odd numbers up to 11.
- A range in a Boolean/number context gives its element count; in list context it
  produces its elements.
