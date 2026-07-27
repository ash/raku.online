---
title: Bitwise operators — +& +| +^ +< +>
slug: bitwise
status: full
order: 25
summary: Integer bit manipulation — and, or, xor, and shifts, all with a + prefix.
---

Raku's bitwise operators work on the binary representation of integers. They all
carry a `+` prefix to mark them as the *numeric* (bit) versions — `+&`, `+|`, `+^`
for and/or/xor, and `+<`, `+>` for left and right shifts. (The `?`-prefixed forms
`?&`, `?|`, `?^` are the boolean versions, and `~&`/`~|`/`~^` are the string ones.)

## and, or, xor

Each operator combines the bits of its two operands.

```raku
say 0b1100 +& 0b1010;
say 0b1100 +| 0b1010;
say 0b1100 +^ 0b1010;
```
```output
8
14
6
```

Reading the bits: `1100 +& 1010` keeps only bits set in *both* → `1000` (8); `+|`
keeps bits set in *either* → `1110` (14); `+^` keeps bits set in exactly one →
`0110` (6). The `0b…` literals are just a readable way to write the same integers
(see [Integer literals](/literals/integers/)).

## Shifting

`+<` shifts the bits left (multiply by a power of two); `+>` shifts right (integer
divide).

```raku
say 1 +< 8;
say 256 +> 2;
```
```output
256
64
```

`1 +< 8` moves the single bit eight places left — `2⁸` = 256; `256 +> 2` drops two
low bits — `256 / 4` = 64.

## Notes

- The operands are `Int`s of arbitrary width, so shifts never overflow: `1 +< 100`
  is an exact 31-digit integer.
- These are the `+`-prefixed *numeric* bitwise ops. The boolean set `?&`, `?|`, `?^`
  coerces operands to `Bool` first; the string set `~&`, `~|`, `~^` works on the
  byte values of strings.
- To *see* the bits, `.base(2)` renders an integer in binary — `12.base(2)` is
  `"1100"` — the inverse of the `0b…` literal.
