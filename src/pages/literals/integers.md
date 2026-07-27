---
title: Integer literals
slug: integers
status: full
order: 10
summary: Whole numbers of unbounded size, written in decimal or any radix.
---

An integer literal denotes an `Int` — an arbitrary-precision signed integer. There
is no fixed width and no silent overflow: an integer grows as large as it needs to,
limited only by memory.

## Decimal literals

The plain form is a run of decimal digits. Underscores may be inserted between
digits as visual separators; they are ignored.

```raku
say 42;
say 1_000_000;
```
```output
42
1000000
```

> An underscore is only allowed *between* two digits — not leading, trailing, or
> doubled. `1_000` is fine; `_1`, `1_`, and `1__0` are parse errors.

## Radix prefixes

Binary, octal, and hexadecimal literals are written with a `0b`, `0o`, or `0x`
prefix. Hex digits are case-insensitive.

```raku
say 0xFF;
say 0o17;
say 0b1010;
```
```output
255
15
10
```

## Arbitrary radix

The `:radix<digits>` form writes a literal in any base from 2 to 36. The digits
above 9 are the letters `a`–`z`.

```raku
say :16<ff>;
say :2<1010>;
```
```output
255
10
```

## Unbounded size

Integer arithmetic never overflows into an approximate result — the value stays
exact however large it gets.

```raku
say 2 ** 100;
say (10 ** 30).WHAT;
```
```output
1267650600228229401496703205376
(Int)
```

## Notes

- The type is always `Int`; there is no separate machine-word integer type at the
  language level. (Native `int` exists only as an explicit container type.)
- A leading `-` is the numeric negation operator applied to the literal, not part
  of the literal itself — this matters only in rare precedence corners.
