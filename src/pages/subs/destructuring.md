---
title: Destructuring parameters
slug: destructuring
status: full
order: 45
summary: Unpack a list or structure directly in the signature with a sub-signature.
---

A parameter can be a **sub-signature** in parentheses, which unpacks the incoming
structure into named pieces. It works in sub signatures and in pointy blocks, so
`for` loops can destructure each element.

## Unpacking a pair of coordinates

```raku
sub dist(($x, $y)) {
    sqrt($x*$x + $y*$y);
}
say dist((3, 4));
```
```output
5
```

The single argument `(3, 4)` is destructured into `$x` and `$y` inside the signature.

## Destructuring in a for loop

`-> ($a, $b) { … }` unpacks each element the loop hands it.

```raku
for (1, 2), (3, 4) -> ($a, $b) {
    say $a + $b;
}
```
```output
3
7
```

## Notes

- The sub-signature is a full signature, so it can name, default, and slurp:
  `-> ($first, *@rest) { … }` takes the head and tail of each element.
- Destructuring pairs by their parts (`-> (:$key, :$value) { … }`) is how you iterate
  a hash's entries with names instead of `.key`/`.value`.
- It's the same mechanism as a parameter list — a sub-signature is just a signature
  nested inside another.
